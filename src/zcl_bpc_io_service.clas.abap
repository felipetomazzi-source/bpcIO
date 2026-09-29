class zcl_bpc_io_service definition public final create public.
  public section.
    types: begin of ty_environment,
             id type uj_appset_id,
           end of ty_environment,
           ty_environments type standard table of ty_environment with default key.
    types: begin of ty_model,
             id type uj_appl_id,
           end of ty_model,
           ty_models type standard table of ty_model with default key.
    types: begin of ty_script,
             name type uj_docname,
             docname type uj_docname,
             content type xstring,
           end of ty_script,
           ty_scripts type standard table of ty_script with default key.
    types: begin of ty_import,
             name type uj_docname,
             content type xstring,
             action type string,
             message type string,
           end of ty_import,
           ty_imports type standard table of ty_import with default key.
    types: begin of ty_package,
             group type uj_pack_grp_id,
             id type uj_package_id,
             descr type uj_desc,
             type type uj_pack_type,
             user_group type uj_user_group,
             chain type rspc_chain,
             team type uj_team_id,
           end of ty_package,
           ty_packages type standard table of ty_package with default key.
    types: begin of ty_package_detail,
             group type uj_pack_grp_id,
             id type uj_package_id,
             descr type uj_desc,
             type type uj_pack_type,
             user_group type uj_user_group,
             chain type rspc_chain,
             team type uj_team_id,
             script type string,
           end of ty_package_detail.
    types: begin of ty_package_import,
             group type uj_pack_grp_id,
             id type uj_package_id,
             descr type uj_desc,
             type type uj_pack_type,
             user_group type uj_user_group,
             chain type rspc_chain,
             team type uj_team_id,
             script type string,
             action type string,
             message type string,
           end of ty_package_import,
           ty_package_imports type standard table of ty_package_import with default key.
    type-pools uje0 .
    " Import results. WRITTEN and REPLACED scripts were stored in SAP,
    " SKIPPED ones already existed and FAILED ones were refused by BPC.
    constants:
      begin of c_action,
        written type string value 'WRITTEN',
        replaced type string value 'REPLACED',
        skipped type string value 'SKIPPED',
        failed type string value 'FAILED',
      end of c_action.
    methods get_scripts
      importing iv_environment type uj_appset_id iv_model type uj_appl_id
      returning value(rt_scripts) type ty_scripts
      raising cx_uj_static_check.
    methods get_script
      importing iv_environment type uj_appset_id iv_model type uj_appl_id
                iv_name type uj_docname
      returning value(rs_script) type ty_script
      raising cx_uj_static_check.
    methods get_models
      importing iv_environment type uj_appset_id
      returning value(rt_models) type ty_models
      raising cx_uj_static_check.
    methods get_environments
      returning value(rt_environments) type ty_environments
      raising cx_uj_static_check.
    "! Writes Logic Script sources into the model's admin folder. It requires
    "! the same task authorization as the BPC script editor. Scripts that
    "! already exist are only overwritten when iv_replace is set.
    methods import_scripts
      importing iv_environment type uj_appset_id iv_model type uj_appl_id
                it_scripts type ty_imports iv_replace type abap_bool default abap_false
      returning value(rt_results) type ty_imports
      raising cx_uj_no_auth cx_uj_input_error cx_uj_static_check.
    methods get_packages
      importing iv_environment type uj_appset_id iv_model type uj_appl_id
      returning value(rt_packages) type ty_packages
      raising cx_uj_static_check.
    methods get_package
      importing iv_environment type uj_appset_id iv_model type uj_appl_id
                iv_group type uj_pack_grp_id iv_package type uj_package_id
      returning value(rs_package) type ty_package_detail
      raising cx_uj_static_check.
    "! Writes Data Manager Package definitions into the model. It requires the
    "! same authorization as the BPC package editor. Packages that already
    "! exist are only overwritten when iv_replace is set.
    methods import_packages
      importing iv_environment type uj_appset_id iv_model type uj_appl_id
                it_packages type ty_package_imports
                iv_replace type abap_bool default abap_false
      returning value(rt_results) type ty_package_imports
      raising cx_uj_no_auth cx_uj_input_error cx_uj_static_check.

  private section.
    "! Logic Script documents live in the model's admin folder.
    constants c_script_folder type string value 'ADMINAPP' ##NO_TEXT.
    "! Document names are CHAR255, so the full document path must fit the type.
    constants c_docname_length type i value 255.
    "! Only bare uppercase .LGF names can become document names.
    constants c_script_pattern type string value '^[A-Z0-9_][A-Z0-9_.-]*\.LGF$' ##NO_TEXT.
    "! Directory holding the Logic Scripts of a model.
    methods get_directory
      importing iv_environment type uj_appset_id iv_model type uj_appl_id
      returning value(rv_directory) type string.

endclass.

class zcl_bpc_io_service implementation.
  method get_scripts.
    data(lt_models) = get_models( iv_environment ).
    read table lt_models transporting no fields with key id = iv_model.
    if sy-subrc <> 0.
      raise exception type cx_uj_no_auth.
    endif.
    data(ls_user) = value uj0_s_user( user_id = sy-uname langu = sy-langu ).
    data(lo_files) = cl_ujf_file_service_mgr=>factory(
      i_appset = iv_environment is_user = ls_user ).
    data lv_directory type ujf_doctree-docname.
    lv_directory = get_directory( iv_environment = iv_environment iv_model = iv_model ).
    lo_files->list_directory(
      exporting i_dirname = lv_directory i_doctype = 'LGF'
                i_sort = abap_true i_include_subfldrs = abap_false
      importing et_document_list = data(lt_documents) ).
    loop at lt_documents into data(ls_document).
      data lt_parts type string_table.
      split ls_document-docname at '\' into table lt_parts.
      read table lt_parts into data(lv_name) index lines( lt_parts ).
      if sy-subrc = 0 and lv_name cp '*.LGF'.
        append value #( name = lv_name docname = ls_document-docname ) to rt_scripts.
      endif.
    endloop.
    sort rt_scripts by name.
    delete adjacent duplicates from rt_scripts comparing name.
  endmethod.

  method get_script.
* Resolve names from the authorized model directory, never from a supplied path.
    data(lt_scripts) = get_scripts( iv_environment = iv_environment iv_model = iv_model ).
    read table lt_scripts into rs_script with key name = iv_name.
    if sy-subrc <> 0.
      return.
    endif.
    data(ls_user) = value uj0_s_user( user_id = sy-uname langu = sy-langu ).
    data(lo_files) = cl_ujf_file_service_mgr=>factory(
      i_appset = iv_environment is_user = ls_user ).
    lo_files->get_document(
      exporting i_docname = rs_script-docname i_retzip = abap_false
      importing e_document_content = rs_script-content ).
  endmethod.

  method get_models.
* Reject environments outside the current user's accessible list.
    data(lt_environments) = get_environments( ).
    read table lt_environments transporting no fields with key id = iv_environment.
    if sy-subrc <> 0.
      raise exception type cx_uj_no_auth.
    endif.
    data ls_user type uj0_s_user.
    ls_user-user_id = sy-uname.
    ls_user-langu = sy-langu.
    cl_uj_context=>set_cur_context( i_appset_id = iv_environment is_user = ls_user ).
    data(lo_manager) = cl_uja_bpc_admin_factory=>get_appset_manager(
      i_appset_id = iv_environment if_disable_security = abap_false ).
    lo_manager->get_applications( importing et_applications = data(lt_applications) ).
    loop at lt_applications into data(ls_application).
      append value #( id = ls_application-application_id ) to rt_models.
    endloop.
    sort rt_models by id.
    delete adjacent duplicates from rt_models comparing id.
  endmethod.

  method get_environments.
    data(lo_manager) = cl_uja_bpc_admin_factory=>get_appset_manager(
      if_disable_security = abap_false ).
    lo_manager->get_appsets(
      exporting i_user_id = conv uj_user_id( sy-uname )
      importing et_appsets = data(lt_appsets) ).
    loop at lt_appsets into data(ls_appset).
      append value #( id = ls_appset-appset_id ) to rt_environments.
    endloop.
    sort rt_environments by id.
    delete adjacent duplicates from rt_environments comparing id.
  endmethod.
  method get_directory.
    rv_directory = |\\ROOT\\WEBFOLDERS\\{ iv_environment }\\{ c_script_folder }\\{ iv_model }\\|.
  endmethod.

  method import_scripts.
* The listing rejects models outside the user's environment and sets the BPC context.
    data(lt_existing) = get_scripts( iv_environment = iv_environment iv_model = iv_model ).
* Saving a Logic Script in the BPC script editor requires the same task.
    data(lo_context) = cl_uj_context=>get_cur_context( ).
    lo_context->check_task_access( i_task_name = uje0_cs_task_id-p0008 ).
    data(ls_user) = value uj0_s_user( user_id = sy-uname langu = sy-langu ).
    data(lo_files) = cl_ujf_file_service_mgr=>factory(
      i_appset = iv_environment is_user = ls_user ).
    data lv_directory type string.
    lv_directory = get_directory( iv_environment = iv_environment iv_model = iv_model ).
    data: ls_result type ty_import,
          lt_written type ty_scripts,
          lv_name type string,
          lv_docname type uj_docname,
          lv_path type string,
          lv_exists type abap_bool,
          lv_written type i.
    loop at it_scripts into data(ls_script).
      clear ls_result.
      lv_name = condense( ls_script-name ).
      ls_result-name = lv_name.
      if cl_abap_matcher=>matches( pattern = c_script_pattern text = lv_name ) = abap_false.
        raise exception type cx_uj_input_error
          exporting object = 'Logic Script' key = lv_name.
      endif.
      read table lt_written transporting no fields with key name = lv_name.
      if sy-subrc = 0.
        ls_result-action = c_action-skipped.
        ls_result-message = 'The script is contained twice in the import'.
        append ls_result to rt_results.
        continue.
      endif.
      read table lt_existing transporting no fields with key name = lv_name.
      lv_exists = boolc( sy-subrc = 0 ).
      if lv_exists = abap_true and iv_replace = abap_false.
        ls_result-action = c_action-skipped.
        ls_result-message = 'The script already exists in this model'.
        append ls_result to rt_results.
        continue.
      endif.
      lv_path = |{ lv_directory }{ lv_name }|.
      if strlen( lv_path ) > c_docname_length.
        raise exception type cx_uj_input_error
          exporting object = 'Logic Script Path' key = lv_name.
      endif.
      lv_docname = lv_path.
      try.
          lo_files->put_document(
            i_docname = lv_docname i_doc_content = ls_script-content
            i_compression = abap_false i_splice_zip = abap_false ).
        catch cx_ujf_file_service_error into data(lx_file).
* A locked or unreadable document is reported per script, the others are kept.
          ls_result-action = c_action-failed.
          ls_result-message = lx_file->get_text( ).
          append ls_result to rt_results.
          continue.
      endtry.
      ls_result-action = cond #( when lv_exists = abap_true
                                 then c_action-replaced else c_action-written ).
      append ls_result to rt_results.
      append value #( name = lv_name ) to lt_written.
      lv_written = lv_written + 1.
    endloop.
    if lv_written > 0.
      commit work and wait.
    endif.
  endmethod.

  method get_packages.
    data(lt_models) = get_models( iv_environment ).
    read table lt_models transporting no fields with key id = iv_model.
    if sy-subrc <> 0.
      raise exception type cx_uj_no_auth.
    endif.
    data lt_list type ujd_t_packages_list.
    select a~group_id, a~package_id, b~package_desc, a~package_type,
           a~user_group, a~chain_id, a~team_id, a~guid
      into corresponding fields of table @lt_list
      from ujd_packages2 as a
      left outer join ujd_packagest2 as b on a~guid = b~guid
      where a~appset_id = @iv_environment and a~app_id = @iv_model.
    sort lt_list by guid.
    delete adjacent duplicates from lt_list comparing guid.
    sort lt_list by group_id package_id.
    loop at lt_list into data(ls_list) where package_id is not initial.
      append value #( group = ls_list-group_id
                      id = ls_list-package_id
                      descr = ls_list-package_desc
                      type = ls_list-package_type
                      user_group = ls_list-user_group
                      chain = ls_list-chain_id
                      team = ls_list-team_id ) to rt_packages.
    endloop.
  endmethod.

  method get_package.
    data(lt_models) = get_models( iv_environment ).
    read table lt_models transporting no fields with key id = iv_model.
    if sy-subrc <> 0.
      raise exception type cx_uj_no_auth.
    endif.
    data ls_package type ujd_packages2.
    select single * into @ls_package from ujd_packages2
      where appset_id = @iv_environment and app_id = @iv_model
        and group_id = @iv_group and package_id = @iv_package.
    if sy-subrc <> 0.
      raise exception type cx_uj_input_error
        exporting object = 'Data Manager Package' key = |{ iv_package }|.
    endif.
    rs_package = value #( group = ls_package-group_id
                          id = ls_package-package_id
                          type = ls_package-package_type
                          user_group = ls_package-user_group
                          chain = ls_package-chain_id
                          team = ls_package-team_id ).
    data(lv_guid) = ls_package-guid.
    data lv_desc type uj_desc.
    select single package_desc from ujd_packagest2
      into @lv_desc where guid = @lv_guid.
    rs_package-descr = lv_desc.
    data lv_script type string.
    select single content from ujd_instruction2
      into @lv_script where guid = @lv_guid.
    rs_package-script = lv_script.
  endmethod.

  method import_packages.
    data(lt_models) = get_models( iv_environment ).
    read table lt_models transporting no fields with key id = iv_model.
    if sy-subrc <> 0.
      raise exception type cx_uj_no_auth.
    endif.
    data(lo_package) = new cl_ujd_package( ).
    data: ls_result type ty_package_import,
          lt_written type ty_packages,
          lv_group type uj_pack_grp_id,
          lv_name type uj_package_id,
          lv_exists type abap_bool,
          lv_written type i.
    loop at it_packages into data(ls_package).
      clear ls_result.
      lv_group = condense( ls_package-group ).
      lv_name = condense( ls_package-id ).
      ls_result-group = lv_group.
      ls_result-id = lv_name.
      if lv_group is initial or lv_name is initial.
        raise exception type cx_uj_input_error
          exporting object = 'Data Manager Package' key = |{ lv_group }/{ lv_name }|.
      endif.
      read table lt_written transporting no fields with key group = lv_group id = lv_name.
      if sy-subrc = 0.
        ls_result-action = c_action-skipped.
        ls_result-message = 'The package is contained twice in the import'.
        append ls_result to rt_results.
        continue.
      endif.
      lv_exists = boolc( lo_package->check_package_exist(
        i_appset = iv_environment i_appl = iv_model i_team = ls_package-team
        i_group = lv_group i_package = lv_name ) = abap_true ).
      if lv_exists = abap_true and iv_replace = abap_false.
        ls_result-action = c_action-skipped.
        ls_result-message = 'The package already exists in this model'.
        append ls_result to rt_results.
        continue.
      endif.
      try.
          if lv_exists = abap_false.
            lo_package->add_package(
              i_appset = iv_environment i_appl = iv_model i_team = ls_package-team
              i_group = lv_group i_package = lv_name i_package_desc = ls_package-descr
              i_package_type = ls_package-type i_user_group = ls_package-user_group
              i_chain = ls_package-chain ).
          else.
            lo_package->modify_package(
              i_appset = iv_environment i_appl = iv_model i_team = ls_package-team
              i_group = lv_group i_package = lv_name i_package_desc = ls_package-descr
              i_package_type = ls_package-type i_user_group = ls_package-user_group
              i_chain = ls_package-chain
              i_original_group = lv_group i_original_package = lv_name ).
          endif.
          lo_package->save_package_info(
            i_appset = iv_environment i_appl = iv_model i_team = ls_package-team
            i_group = lv_group i_package = lv_name i_script = ls_package-script ).
        catch cx_ujd_datamgr_error into data(lx_dm).
          ls_result-action = c_action-failed.
          ls_result-message = lx_dm->get_text( ).
          append ls_result to rt_results.
          continue.
        catch cx_uj_db_error into data(lx_db).
          ls_result-action = c_action-failed.
          ls_result-message = lx_db->get_text( ).
          append ls_result to rt_results.
          continue.
      endtry.
      ls_result-action = cond #( when lv_exists = abap_true
                                 then c_action-replaced else c_action-written ).
      append ls_result to rt_results.
      append value #( group = lv_group id = lv_name ) to lt_written.
      lv_written = lv_written + 1.
    endloop.
    if lv_written > 0.
      commit work and wait.
    endif.
  endmethod.

endclass.
