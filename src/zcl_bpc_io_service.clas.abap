CLASS zcl_bpc_io_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_environment,
             id TYPE uj_appset_id,
           END OF ty_environment,
           ty_environments TYPE STANDARD TABLE OF ty_environment WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_model,
             id TYPE uj_appl_id,
           END OF ty_model,
           ty_models TYPE STANDARD TABLE OF ty_model WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_script,
             name TYPE uj_docname,
             docname TYPE uj_docname,
             content TYPE xstring,
           END OF ty_script,
           ty_scripts TYPE STANDARD TABLE OF ty_script WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_import,
             name TYPE uj_docname,
             content TYPE xstring,
             action TYPE string,
             message TYPE string,
           END OF ty_import,
           ty_imports TYPE STANDARD TABLE OF ty_import WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_package,
             group TYPE uj_pack_grp_id,
             id TYPE uj_package_id,
             descr TYPE uj_desc,
             type TYPE uj_pack_type,
             user_group TYPE uj_user_group,
             chain TYPE rspc_chain,
             team TYPE uj_team_id,
           END OF ty_package,
           ty_packages TYPE STANDARD TABLE OF ty_package WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_package_detail,
             group TYPE uj_pack_grp_id,
             id TYPE uj_package_id,
             descr TYPE uj_desc,
             type TYPE uj_pack_type,
             user_group TYPE uj_user_group,
             chain TYPE rspc_chain,
             team TYPE uj_team_id,
             script TYPE string,
           END OF ty_package_detail.
    TYPES: BEGIN OF ty_package_import,
             group TYPE uj_pack_grp_id,
             id TYPE uj_package_id,
             descr TYPE uj_desc,
             type TYPE uj_pack_type,
             user_group TYPE uj_user_group,
             chain TYPE rspc_chain,
             team TYPE uj_team_id,
             script TYPE string,
             action TYPE string,
             message TYPE string,
           END OF ty_package_import,
           ty_package_imports TYPE STANDARD TABLE OF ty_package_import WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_dm_file,
             name TYPE uj_docname,
             content TYPE xstring,
             workbook TYPE xstring,
           END OF ty_dm_file,
           ty_dm_files TYPE STANDARD TABLE OF ty_dm_file WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_dm_import,
             name TYPE uj_docname,
             content TYPE xstring,
             workbook TYPE xstring,
             action TYPE string,
             message TYPE string,
           END OF ty_dm_import,
           ty_dm_imports TYPE STANDARD TABLE OF ty_dm_import WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_workbook,
             name TYPE uj_docname,
             folder TYPE string,
             content TYPE xstring,
           END OF ty_workbook,
           ty_workbooks TYPE STANDARD TABLE OF ty_workbook WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_workbook_import,
             name TYPE uj_docname,
             folder TYPE string,
             content TYPE xstring,
             action TYPE string,
             message TYPE string,
           END OF ty_workbook_import,
           ty_workbook_imports TYPE STANDARD TABLE OF ty_workbook_import WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_dimension,
             id TYPE uj_dim_name,
             description TYPE uj_desc,
             dim_type TYPE uj_dim_type,
           END OF ty_dimension,
           ty_dimensions TYPE STANDARD TABLE OF ty_dimension WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_property,
             id TYPE uj_attr_name,
             value TYPE string,
           END OF ty_property,
           ty_properties TYPE STANDARD TABLE OF ty_property WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_member,
             id TYPE uj_dim_member,
             description TYPE uj_desc,
             properties TYPE ty_properties,
           END OF ty_member,
           ty_members TYPE STANDARD TABLE OF ty_member WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_filter,
             dimension TYPE uj_dim_name,
             members TYPE STANDARD TABLE OF uj_dim_member WITH DEFAULT KEY,
           END OF ty_filter,
           ty_filters TYPE STANDARD TABLE OF ty_filter WITH DEFAULT KEY.
    TYPE-POOLS uje0 .
    " Import results. WRITTEN and REPLACED scripts were stored in SAP,
    " SKIPPED ones already existed and FAILED ones were refused by BPC.
    CONSTANTS:
      BEGIN OF c_action,
        written TYPE string VALUE 'WRITTEN',
        replaced TYPE string VALUE 'REPLACED',
        skipped TYPE string VALUE 'SKIPPED',
        failed TYPE string VALUE 'FAILED',
      END OF c_action.
    METHODS get_scripts
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
      RETURNING VALUE(rt_scripts) TYPE ty_scripts
      RAISING cx_uj_static_check.
    METHODS get_script
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_name TYPE uj_docname
      RETURNING VALUE(rs_script) TYPE ty_script
      RAISING cx_uj_static_check.
    METHODS get_models
      IMPORTING iv_environment TYPE uj_appset_id
      RETURNING VALUE(rt_models) TYPE ty_models
      RAISING cx_uj_static_check.
    METHODS get_environments
      RETURNING VALUE(rt_environments) TYPE ty_environments
      RAISING cx_uj_static_check.
    "! Writes Logic Script sources into the model's admin folder. It requires
    "! the same task authorization as the BPC script editor. Scripts that
    "! already exist are only overwritten when iv_replace is set.
    METHODS import_scripts
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                it_scripts TYPE ty_imports iv_replace TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_results) TYPE ty_imports
      RAISING cx_uj_no_auth cx_uj_input_error cx_uj_static_check.
    METHODS get_packages
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
      RETURNING VALUE(rt_packages) TYPE ty_packages
      RAISING cx_uj_static_check.
    METHODS get_package
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_group TYPE uj_pack_grp_id iv_package TYPE uj_package_id
      RETURNING VALUE(rs_package) TYPE ty_package_detail
      RAISING cx_uj_static_check.
    "! Writes Data Manager Package definitions into the model. It requires the
    "! same authorization as the BPC package editor. Packages that already
    "! exist are only overwritten when iv_replace is set.
    METHODS import_packages
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                it_packages TYPE ty_package_imports
                iv_replace TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_results) TYPE ty_package_imports
      RAISING cx_uj_no_auth cx_uj_input_error cx_uj_static_check.
    "! Lists the Data Manager transformation files (.TDM) of a model.
    METHODS get_transformations
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
      RETURNING VALUE(rt_files) TYPE ty_dm_files
      RAISING cx_uj_static_check.
    METHODS get_transformation
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_name TYPE uj_docname
      RETURNING VALUE(rs_file) TYPE ty_dm_file
      RAISING cx_uj_static_check.
    "! Writes Data Manager transformation files (.TDM and their .xls workbook).
    METHODS import_transformations
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                it_files TYPE ty_dm_imports
                iv_replace TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_results) TYPE ty_dm_imports
      RAISING cx_uj_no_auth cx_uj_input_error cx_uj_static_check.
    "! Lists the Data Manager conversion files (.CDM) of a model.
    METHODS get_conversions
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
      RETURNING VALUE(rt_files) TYPE ty_dm_files
      RAISING cx_uj_static_check.
    METHODS get_conversion
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_name TYPE uj_docname
      RETURNING VALUE(rs_file) TYPE ty_dm_file
      RAISING cx_uj_static_check.
    "! Writes Data Manager conversion files (.CDM and their .xls workbook).
    METHODS import_conversions
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                it_files TYPE ty_dm_imports
                iv_replace TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_results) TYPE ty_dm_imports
      RAISING cx_uj_no_auth cx_uj_input_error cx_uj_static_check.
    "! Lists the EPM Add-in workbooks (reports and input schedules) of a model.
    "! Reports live under EEXCEL\REPORTS and input schedules under
    "! EEXCEL\INPUT SCHEDULES. The returned folder distinguishes the two.
    METHODS get_workbooks
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
      RETURNING VALUE(rt_files) TYPE ty_workbooks
      RAISING cx_uj_static_check.
    METHODS get_workbook
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_folder TYPE string iv_name TYPE uj_docname
      RETURNING VALUE(rs_file) TYPE ty_workbook
      RAISING cx_uj_static_check.
    "! Writes EPM Add-in workbooks into the model's report or input schedule
    "! library. Workbooks that already exist are only overwritten when
    "! iv_replace is set.
    METHODS import_workbooks
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                it_files TYPE ty_workbook_imports
                iv_replace TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_results) TYPE ty_workbook_imports
      RAISING cx_uj_no_auth cx_uj_input_error cx_uj_static_check.

    "! Lists the dimensions of a model (id, description, type).
    METHODS get_dimensions
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
      RETURNING VALUE(rt_dimensions) TYPE ty_dimensions
      RAISING cx_uj_static_check.
    "! Lists the members of one dimension with their property values.
    METHODS get_dimension_members
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_dimension TYPE uj_dim_name
      RETURNING VALUE(rt_members) TYPE ty_members
      RAISING cx_uj_static_check.
    "! Reads the fact data of a model for the given member filters and
    "! returns it as CSV (one column per dimension plus SIGNEDDATA).
    METHODS export_data
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                it_filters TYPE ty_filters
      RETURNING VALUE(rv_csv) TYPE string
      RAISING cx_uj_static_check.

  PRIVATE SECTION.
    METHODS csv_field IMPORTING iv_value TYPE string RETURNING VALUE(rv_field) TYPE string.
    "! Logic Script documents live in the model's admin folder.
    CONSTANTS c_script_folder TYPE string VALUE 'ADMINAPP' ##NO_TEXT.
    "! Document names are CHAR255, so the full document path must fit the type.
    CONSTANTS c_docname_length TYPE i VALUE 255.
    "! Only bare uppercase .LGF names can become document names.
    CONSTANTS c_script_pattern TYPE string VALUE '^[A-Z0-9_][A-Z0-9_.-]*\.LGF$' ##NO_TEXT.
    "! Data Manager transformation and conversion files live under the
    "! model's Data Manager folder.
    CONSTANTS c_dm_folder TYPE string VALUE 'DATAMANAGER' ##NO_TEXT.
    CONSTANTS c_transformation_folder TYPE string VALUE 'TRANSFORMATIONFILES' ##NO_TEXT.
    CONSTANTS c_conversion_folder TYPE string VALUE 'CONVERSIONFILES' ##NO_TEXT.
    CONSTANTS c_transformation_ext TYPE string VALUE '.TDM' ##NO_TEXT.
    CONSTANTS c_conversion_ext TYPE string VALUE '.CDM' ##NO_TEXT.
    "! EPM Add-in workbooks live under the model's WebExcel libraries:
    "! reports under EEXCEL\REPORTS and input schedules under
    "! EEXCEL\INPUT SCHEDULES (the physical file-service folder names, which
    "! differ from the logical library names shown in the BPC web client).
    CONSTANTS c_webexcel_folder TYPE string VALUE 'EEXCEL' ##NO_TEXT.
    CONSTANTS c_report_library TYPE string VALUE 'REPORTS' ##NO_TEXT.
    CONSTANTS c_schedule_library TYPE string VALUE 'INPUT SCHEDULES' ##NO_TEXT.
    "! Recognised workbook file extensions, checked in this order.
    CONSTANTS c_workbook_ext_xlsm TYPE string VALUE '.XLSM' ##NO_TEXT.
    CONSTANTS c_workbook_ext_xlsx TYPE string VALUE '.XLSX' ##NO_TEXT.
    CONSTANTS c_workbook_ext_xls TYPE string VALUE '.XLS' ##NO_TEXT.
    "! Resolves the directory holding one EPM WebExcel library of a model.
    "! The physical file-service layout is {env}\{model}\EEXCEL\{library}
    "! (e.g. \ROOT\WEBFOLDERS\CH_PLANNING\AGGR_OPEX\EEXCEL\REPORTS\). To stay
    "! resilient to layout variations, both the model-before-category and
    "! category-before-model candidates are probed and the existing one is
    "! returned; if neither exists the first candidate is returned so callers
    "! surface a consistent "not found".
    METHODS get_webexcel_directory
      IMPORTING io_files TYPE REF TO cl_ujf_file_service_mgr
                iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_library TYPE string
      RETURNING VALUE(rv_directory) TYPE string.
    "! Maps a client folder token ('REPORT' / 'SCHEDULE') to its library folder.
    METHODS workbook_library
      IMPORTING iv_folder TYPE string
      RETURNING VALUE(rv_library) TYPE string.
    "! True when the (upper-cased) name ends in a recognised workbook extension.
    METHODS is_workbook_name
      IMPORTING iv_name TYPE string
      RETURNING VALUE(rv_ok) TYPE abap_bool.
    "! Lists one WebExcel library, tagging each file with the client folder token.
    METHODS list_workbooks
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_library TYPE string iv_folder TYPE string
      RETURNING VALUE(rt_files) TYPE ty_workbooks
      RAISING cx_uj_static_check.
    "! Directory holding one Data Manager file category of a model.
    METHODS get_dm_directory
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_folder TYPE string
      RETURNING VALUE(rv_directory) TYPE string.
    "! Shared list / read / write helpers for transformation and conversion files.
    METHODS list_dm_files
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_folder TYPE string iv_ext TYPE string
      RETURNING VALUE(rt_files) TYPE ty_dm_files
      RAISING cx_uj_static_check.
    METHODS get_dm_file
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_folder TYPE string iv_ext TYPE string iv_name TYPE uj_docname
      RETURNING VALUE(rs_file) TYPE ty_dm_file
      RAISING cx_uj_static_check.
    METHODS import_dm_files
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_folder TYPE string iv_ext TYPE string
                it_files TYPE ty_dm_imports
                iv_replace TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_results) TYPE ty_dm_imports
      RAISING cx_uj_no_auth cx_uj_input_error cx_uj_static_check.
    "! Paired workbook name for a .TDM/.CDM definition file.
    METHODS dm_workbook_name
      IMPORTING iv_name TYPE string iv_ext TYPE string
      RETURNING VALUE(rv_workbook) TYPE string.
    "! Directory holding the Logic Scripts of a model.
    METHODS get_directory
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
      RETURNING VALUE(rv_directory) TYPE string.

ENDCLASS.

CLASS zcl_bpc_io_service IMPLEMENTATION.
  METHOD get_scripts.
    DATA(lt_models) = get_models( iv_environment ).
    READ TABLE lt_models TRANSPORTING NO FIELDS WITH KEY id = iv_model.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA(ls_user) = VALUE uj0_s_user( user_id = sy-uname langu = sy-langu ).
    DATA(lo_files) = cl_ujf_file_service_mgr=>factory(
      i_appset = iv_environment is_user = ls_user ).
    DATA lv_directory TYPE ujf_doctree-docname.
    lv_directory = get_directory( iv_environment = iv_environment iv_model = iv_model ).
    lo_files->list_directory(
      EXPORTING i_dirname = lv_directory i_doctype = 'LGF'
                i_sort = abap_true i_include_subfldrs = abap_false
      IMPORTING et_document_list = DATA(lt_documents) ).
    LOOP AT lt_documents INTO DATA(ls_document).
      DATA lt_parts TYPE string_table.
      SPLIT ls_document-docname AT '\' INTO TABLE lt_parts.
      READ TABLE lt_parts INTO DATA(lv_name) INDEX lines( lt_parts ).
      IF sy-subrc = 0 AND lv_name CP '*.LGF'.
        APPEND VALUE #( name = lv_name docname = ls_document-docname ) TO rt_scripts.
      ENDIF.
    ENDLOOP.
    SORT rt_scripts BY name.
    DELETE ADJACENT DUPLICATES FROM rt_scripts COMPARING name.
  ENDMETHOD.

  METHOD get_script.
* Resolve names from the authorized model directory, never from a supplied path.
    DATA(lt_scripts) = get_scripts( iv_environment = iv_environment iv_model = iv_model ).
    READ TABLE lt_scripts INTO rs_script WITH KEY name = iv_name.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    DATA(ls_user) = VALUE uj0_s_user( user_id = sy-uname langu = sy-langu ).
    DATA(lo_files) = cl_ujf_file_service_mgr=>factory(
      i_appset = iv_environment is_user = ls_user ).
    lo_files->get_document(
      EXPORTING i_docname = rs_script-docname i_retzip = abap_false
      IMPORTING e_document_content = rs_script-content ).
  ENDMETHOD.

  METHOD get_models.
* Reject environments outside the current user's accessible list.
    DATA(lt_environments) = get_environments( ).
    READ TABLE lt_environments TRANSPORTING NO FIELDS WITH KEY id = iv_environment.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA ls_user TYPE uj0_s_user.
    ls_user-user_id = sy-uname.
    ls_user-langu = sy-langu.
    cl_uj_context=>set_cur_context( i_appset_id = iv_environment is_user = ls_user ).
    DATA(lo_manager) = cl_uja_bpc_admin_factory=>get_appset_manager(
      i_appset_id = iv_environment if_disable_security = abap_false ).
    lo_manager->get_applications( IMPORTING et_applications = DATA(lt_applications) ).
    LOOP AT lt_applications INTO DATA(ls_application).
      APPEND VALUE #( id = ls_application-application_id ) TO rt_models.
    ENDLOOP.
    SORT rt_models BY id.
    DELETE ADJACENT DUPLICATES FROM rt_models COMPARING id.
  ENDMETHOD.

  METHOD get_environments.
    DATA(lo_manager) = cl_uja_bpc_admin_factory=>get_appset_manager(
      if_disable_security = abap_false ).
    lo_manager->get_appsets(
      EXPORTING i_user_id = CONV uj_user_id( sy-uname )
      IMPORTING et_appsets = DATA(lt_appsets) ).
    LOOP AT lt_appsets INTO DATA(ls_appset).
      APPEND VALUE #( id = ls_appset-appset_id ) TO rt_environments.
    ENDLOOP.
    SORT rt_environments BY id.
    DELETE ADJACENT DUPLICATES FROM rt_environments COMPARING id.
  ENDMETHOD.
  METHOD get_directory.
    rv_directory = |\\ROOT\\WEBFOLDERS\\{ iv_environment }\\{ c_script_folder }\\{ iv_model }\\|.
  ENDMETHOD.

  METHOD import_scripts.
* The listing rejects models outside the user's environment and sets the BPC context.
    DATA(lt_existing) = get_scripts( iv_environment = iv_environment iv_model = iv_model ).
* Saving a Logic Script in the BPC script editor requires the same task.
    DATA(lo_context) = cl_uj_context=>get_cur_context( ).
    lo_context->check_task_access( i_task_name = uje0_cs_task_id-p0008 ).
    DATA(ls_user) = VALUE uj0_s_user( user_id = sy-uname langu = sy-langu ).
    DATA(lo_files) = cl_ujf_file_service_mgr=>factory(
      i_appset = iv_environment is_user = ls_user ).
    DATA lv_directory TYPE string.
    lv_directory = get_directory( iv_environment = iv_environment iv_model = iv_model ).
    DATA: ls_result TYPE ty_import,
          lt_written TYPE ty_scripts,
          lv_name TYPE string,
          lv_docname TYPE uj_docname,
          lv_path TYPE string,
          lv_exists TYPE abap_bool,
          lv_written TYPE i.
    LOOP AT it_scripts INTO DATA(ls_script).
      CLEAR ls_result.
      lv_name = condense( ls_script-name ).
      ls_result-name = lv_name.
      IF cl_abap_matcher=>matches( pattern = c_script_pattern text = lv_name ) = abap_false.
        RAISE EXCEPTION TYPE cx_uj_input_error
          EXPORTING object = 'Logic Script' key = lv_name.
      ENDIF.
      READ TABLE lt_written TRANSPORTING NO FIELDS WITH KEY name = lv_name.
      IF sy-subrc = 0.
        ls_result-action = c_action-skipped.
        ls_result-message = 'The script is contained twice in the import'.
        APPEND ls_result TO rt_results.
        CONTINUE.
      ENDIF.
      READ TABLE lt_existing TRANSPORTING NO FIELDS WITH KEY name = lv_name.
      lv_exists = boolc( sy-subrc = 0 ).
      IF lv_exists = abap_true AND iv_replace = abap_false.
        ls_result-action = c_action-skipped.
        ls_result-message = 'The script already exists in this model'.
        APPEND ls_result TO rt_results.
        CONTINUE.
      ENDIF.
      lv_path = |{ lv_directory }{ lv_name }|.
      IF strlen( lv_path ) > c_docname_length.
        RAISE EXCEPTION TYPE cx_uj_input_error
          EXPORTING object = 'Logic Script Path' key = lv_name.
      ENDIF.
      lv_docname = lv_path.
      TRY.
          lo_files->put_document(
            i_docname = lv_docname i_doc_content = ls_script-content
            i_compression = abap_false i_splice_zip = abap_false ).
        CATCH cx_ujf_file_service_error INTO DATA(lx_file).
* A locked or unreadable document is reported per script, the others are kept.
          ls_result-action = c_action-failed.
          ls_result-message = lx_file->get_text( ).
          APPEND ls_result TO rt_results.
          CONTINUE.
      ENDTRY.
      ls_result-action = COND #( WHEN lv_exists = abap_true
                                 THEN c_action-replaced ELSE c_action-written ).
      APPEND ls_result TO rt_results.
      APPEND VALUE #( name = lv_name ) TO lt_written.
      lv_written = lv_written + 1.
    ENDLOOP.
    IF lv_written > 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDMETHOD.

  METHOD get_packages.
    DATA(lt_models) = get_models( iv_environment ).
    READ TABLE lt_models TRANSPORTING NO FIELDS WITH KEY id = iv_model.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA lt_list TYPE ujd_t_packages_list.
    SELECT a~group_id, a~package_id, b~package_desc, a~package_type,
           a~user_group, a~chain_id, a~team_id, a~guid
      INTO CORRESPONDING FIELDS OF TABLE @lt_list
      FROM ujd_packages2 AS a
      LEFT OUTER JOIN ujd_packagest2 AS b ON a~guid = b~guid
      WHERE a~appset_id = @iv_environment AND a~app_id = @iv_model.
    SORT lt_list BY guid.
    DELETE ADJACENT DUPLICATES FROM lt_list COMPARING guid.
    SORT lt_list BY group_id package_id.
    LOOP AT lt_list INTO DATA(ls_list) WHERE package_id IS NOT INITIAL.
      APPEND VALUE #( group = ls_list-group_id
                      id = ls_list-package_id
                      descr = ls_list-package_desc
                      type = ls_list-package_type
                      user_group = ls_list-user_group
                      chain = ls_list-chain_id
                      team = ls_list-team_id ) TO rt_packages.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_package.
    DATA(lt_models) = get_models( iv_environment ).
    READ TABLE lt_models TRANSPORTING NO FIELDS WITH KEY id = iv_model.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA ls_package TYPE ujd_packages2.
    SELECT SINGLE * INTO @ls_package FROM ujd_packages2
      WHERE appset_id = @iv_environment AND app_id = @iv_model
        AND group_id = @iv_group AND package_id = @iv_package.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_input_error
        EXPORTING object = 'Data Manager Package' key = |{ iv_package }|.
    ENDIF.
    rs_package = VALUE #( group = ls_package-group_id
                          id = ls_package-package_id
                          type = ls_package-package_type
                          user_group = ls_package-user_group
                          chain = ls_package-chain_id
                          team = ls_package-team_id ).
    DATA(lv_guid) = ls_package-guid.
    DATA lv_desc TYPE uj_desc.
    SELECT SINGLE package_desc FROM ujd_packagest2
      INTO @lv_desc WHERE guid = @lv_guid.
    rs_package-descr = lv_desc.
    DATA lv_script TYPE string.
    SELECT SINGLE content FROM ujd_instruction2
      INTO @lv_script WHERE guid = @lv_guid.
    rs_package-script = lv_script.
  ENDMETHOD.

  METHOD import_packages.
    DATA(lt_models) = get_models( iv_environment ).
    READ TABLE lt_models TRANSPORTING NO FIELDS WITH KEY id = iv_model.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA(lo_package) = NEW cl_ujd_package( ).
    DATA: ls_result TYPE ty_package_import,
          lt_written TYPE ty_packages,
          lv_group TYPE uj_pack_grp_id,
          lv_name TYPE uj_package_id,
          lv_exists TYPE abap_bool,
          lv_written TYPE i.
    LOOP AT it_packages INTO DATA(ls_package).
      CLEAR ls_result.
      lv_group = condense( ls_package-group ).
      lv_name = condense( ls_package-id ).
      ls_result-group = lv_group.
      ls_result-id = lv_name.
      IF lv_group IS INITIAL OR lv_name IS INITIAL.
        RAISE EXCEPTION TYPE cx_uj_input_error
          EXPORTING object = 'Data Manager Package' key = |{ lv_group }/{ lv_name }|.
      ENDIF.
      READ TABLE lt_written TRANSPORTING NO FIELDS WITH KEY group = lv_group id = lv_name.
      IF sy-subrc = 0.
        ls_result-action = c_action-skipped.
        ls_result-message = 'The package is contained twice in the import'.
        APPEND ls_result TO rt_results.
        CONTINUE.
      ENDIF.
      lv_exists = boolc( lo_package->check_package_exist(
        i_appset = iv_environment i_appl = iv_model i_team = ls_package-team
        i_group = lv_group i_package = lv_name ) = abap_true ).
      IF lv_exists = abap_true AND iv_replace = abap_false.
        ls_result-action = c_action-skipped.
        ls_result-message = 'The package already exists in this model'.
        APPEND ls_result TO rt_results.
        CONTINUE.
      ENDIF.
      TRY.
          IF lv_exists = abap_false.
            lo_package->add_package(
              i_appset = iv_environment i_appl = iv_model i_team = ls_package-team
              i_group = lv_group i_package = lv_name i_package_desc = ls_package-descr
              i_package_type = ls_package-type i_user_group = ls_package-user_group
              i_chain = ls_package-chain ).
          ELSE.
            lo_package->modify_package(
              i_appset = iv_environment i_appl = iv_model i_team = ls_package-team
              i_group = lv_group i_package = lv_name i_package_desc = ls_package-descr
              i_package_type = ls_package-type i_user_group = ls_package-user_group
              i_chain = ls_package-chain
              i_original_group = lv_group i_original_package = lv_name ).
          ENDIF.
          lo_package->save_package_info(
            i_appset = iv_environment i_appl = iv_model i_team = ls_package-team
            i_group = lv_group i_package = lv_name i_script = ls_package-script ).
        CATCH cx_ujd_datamgr_error INTO DATA(lx_dm).
          ls_result-action = c_action-failed.
          ls_result-message = lx_dm->get_text( ).
          APPEND ls_result TO rt_results.
          CONTINUE.
        CATCH cx_uj_db_error INTO DATA(lx_db).
          ls_result-action = c_action-failed.
          ls_result-message = lx_db->get_text( ).
          APPEND ls_result TO rt_results.
          CONTINUE.
      ENDTRY.
      ls_result-action = COND #( WHEN lv_exists = abap_true
                                 THEN c_action-replaced ELSE c_action-written ).
      APPEND ls_result TO rt_results.
      APPEND VALUE #( group = lv_group id = lv_name ) TO lt_written.
      lv_written = lv_written + 1.
    ENDLOOP.
    IF lv_written > 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDMETHOD.

  METHOD get_transformations.
    rt_files = list_dm_files( iv_environment = iv_environment iv_model = iv_model
                              iv_folder = c_transformation_folder iv_ext = c_transformation_ext ).
  ENDMETHOD.

  METHOD get_transformation.
    rs_file = get_dm_file( iv_environment = iv_environment iv_model = iv_model
                           iv_folder = c_transformation_folder iv_ext = c_transformation_ext
                           iv_name = iv_name ).
  ENDMETHOD.

  METHOD import_transformations.
    rt_results = import_dm_files( iv_environment = iv_environment iv_model = iv_model
                                  iv_folder = c_transformation_folder iv_ext = c_transformation_ext
                                  it_files = it_files iv_replace = iv_replace ).
  ENDMETHOD.

  METHOD get_conversions.
    rt_files = list_dm_files( iv_environment = iv_environment iv_model = iv_model
                              iv_folder = c_conversion_folder iv_ext = c_conversion_ext ).
  ENDMETHOD.

  METHOD get_conversion.
    rs_file = get_dm_file( iv_environment = iv_environment iv_model = iv_model
                           iv_folder = c_conversion_folder iv_ext = c_conversion_ext
                           iv_name = iv_name ).
  ENDMETHOD.

  METHOD import_conversions.
    rt_results = import_dm_files( iv_environment = iv_environment iv_model = iv_model
                                  iv_folder = c_conversion_folder iv_ext = c_conversion_ext
                                  it_files = it_files iv_replace = iv_replace ).
  ENDMETHOD.

  METHOD get_dm_directory.
    rv_directory = |\\ROOT\\WEBFOLDERS\\{ iv_environment }\\{ iv_model }\\{ c_dm_folder }\\{ iv_folder }\\|.
  ENDMETHOD.

  METHOD dm_workbook_name.
    DATA(lv_base) = substring( val = iv_name len = strlen( iv_name ) - strlen( iv_ext ) ).
    rv_workbook = |{ lv_base }.xls|.
  ENDMETHOD.

  METHOD list_dm_files.
    DATA(lt_models) = get_models( iv_environment ).
    READ TABLE lt_models TRANSPORTING NO FIELDS WITH KEY id = iv_model.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA(ls_user) = VALUE uj0_s_user( user_id = sy-uname langu = sy-langu ).
    DATA(lo_files) = cl_ujf_file_service_mgr=>factory(
      i_appset = iv_environment is_user = ls_user ).
    DATA lv_directory TYPE ujf_doctree-docname.
    lv_directory = get_dm_directory( iv_environment = iv_environment
                                     iv_model = iv_model iv_folder = iv_folder ).
    DATA lv_doctype TYPE ujf_doc-doctype.
    lv_doctype = substring( val = iv_ext off = 1 ).
    lo_files->list_directory(
      EXPORTING i_dirname = lv_directory i_doctype = lv_doctype
                i_sort = abap_true i_include_subfldrs = abap_false
      IMPORTING et_document_list = DATA(lt_documents) ).
    LOOP AT lt_documents INTO DATA(ls_document).
      DATA lt_parts TYPE string_table.
      SPLIT ls_document-docname AT '\' INTO TABLE lt_parts.
      READ TABLE lt_parts INTO DATA(lv_name) INDEX lines( lt_parts ).
      IF sy-subrc = 0 AND to_upper( lv_name ) CP |*{ iv_ext }|.
        APPEND VALUE #( name = lv_name ) TO rt_files.
      ENDIF.
    ENDLOOP.
    SORT rt_files BY name.
    DELETE ADJACENT DUPLICATES FROM rt_files COMPARING name.
  ENDMETHOD.

  METHOD get_dm_file.
    DATA(lt_files) = list_dm_files( iv_environment = iv_environment iv_model = iv_model
                                    iv_folder = iv_folder iv_ext = iv_ext ).
    READ TABLE lt_files INTO DATA(ls_list) WITH KEY name = iv_name.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    DATA(ls_user) = VALUE uj0_s_user( user_id = sy-uname langu = sy-langu ).
    DATA(lo_files) = cl_ujf_file_service_mgr=>factory(
      i_appset = iv_environment is_user = ls_user ).
    DATA(lv_directory) = get_dm_directory( iv_environment = iv_environment
                                           iv_model = iv_model iv_folder = iv_folder ).
    lo_files->get_document(
      EXPORTING i_docname = |{ lv_directory }{ iv_name }| i_retzip = abap_false
      IMPORTING e_document_content = rs_file-content ).
    rs_file-name = iv_name.
* Read the paired workbook when present; its absence is not an error.
    DATA(lv_base) = substring( val = iv_name len = strlen( iv_name ) - strlen( iv_ext ) ).
    DATA(lv_workbook) = |{ lv_base }.xls|.
    DATA(lv_workbook_uc) = |{ lv_base }.XLS|.
    TRY.
        lo_files->get_document(
          EXPORTING i_docname = |{ lv_directory }{ lv_workbook }| i_retzip = abap_false
          IMPORTING e_document_content = rs_file-workbook ).
      CATCH cx_ujf_file_service_error.
        CLEAR rs_file-workbook.
        TRY.
            lo_files->get_document(
              EXPORTING i_docname = |{ lv_directory }{ lv_workbook_uc }| i_retzip = abap_false
              IMPORTING e_document_content = rs_file-workbook ).
          CATCH cx_ujf_file_service_error.
            CLEAR rs_file-workbook.
        ENDTRY.
    ENDTRY.
  ENDMETHOD.

  METHOD import_dm_files.
    DATA(lt_existing) = list_dm_files( iv_environment = iv_environment iv_model = iv_model
                                       iv_folder = iv_folder iv_ext = iv_ext ).
    DATA(ls_user) = VALUE uj0_s_user( user_id = sy-uname langu = sy-langu ).
    DATA(lo_files) = cl_ujf_file_service_mgr=>factory(
      i_appset = iv_environment is_user = ls_user ).
    DATA(lv_directory) = get_dm_directory( iv_environment = iv_environment
                                           iv_model = iv_model iv_folder = iv_folder ).
    DATA: ls_result TYPE ty_dm_import,
          lt_written TYPE ty_dm_files,
          lv_name TYPE string,
          lv_docname TYPE uj_docname,
          lv_workbook TYPE uj_docname,
          lv_path TYPE string,
          lv_exists TYPE abap_bool,
          lv_written TYPE i.
    LOOP AT it_files INTO DATA(ls_file).
      CLEAR ls_result.
      lv_name = condense( ls_file-name ).
      ls_result-name = lv_name.
      IF lv_name IS INITIAL.
        RAISE EXCEPTION TYPE cx_uj_input_error
          EXPORTING object = 'Data Manager File' key = lv_name.
      ENDIF.
      IF lv_name CA '/' OR lv_name CA '\'
         OR NOT ( to_upper( lv_name ) CP |*{ iv_ext }| ).
        RAISE EXCEPTION TYPE cx_uj_input_error
          EXPORTING object = 'Data Manager File' key = lv_name.
      ENDIF.
      READ TABLE lt_written TRANSPORTING NO FIELDS WITH KEY name = lv_name.
      IF sy-subrc = 0.
        ls_result-action = c_action-skipped.
        ls_result-message = 'The file is contained twice in the import'.
        APPEND ls_result TO rt_results.
        CONTINUE.
      ENDIF.
      READ TABLE lt_existing TRANSPORTING NO FIELDS WITH KEY name = lv_name.
      lv_exists = boolc( sy-subrc = 0 ).
      IF lv_exists = abap_true AND iv_replace = abap_false.
        ls_result-action = c_action-skipped.
        ls_result-message = 'The file already exists in this model'.
        APPEND ls_result TO rt_results.
        CONTINUE.
      ENDIF.
      lv_path = |{ lv_directory }{ lv_name }|.
      IF strlen( lv_path ) > c_docname_length.
        RAISE EXCEPTION TYPE cx_uj_input_error
          EXPORTING object = 'Data Manager File Path' key = lv_name.
      ENDIF.
      lv_docname = lv_path.
      TRY.
          lo_files->put_document(
            i_docname = lv_docname i_doc_content = ls_file-content
            i_compression = abap_false i_splice_zip = abap_false ).
          IF ls_file-workbook IS NOT INITIAL.
            lv_workbook = |{ lv_directory }{ dm_workbook_name( iv_name = lv_name iv_ext = iv_ext ) }|.
            lo_files->put_document(
              i_docname = lv_workbook i_doc_content = ls_file-workbook
              i_compression = abap_false i_splice_zip = abap_false ).
          ENDIF.
        CATCH cx_ujf_file_service_error INTO DATA(lx_file).
          ls_result-action = c_action-failed.
          ls_result-message = lx_file->get_text( ).
          APPEND ls_result TO rt_results.
          CONTINUE.
      ENDTRY.
      ls_result-action = COND #( WHEN lv_exists = abap_true
                                 THEN c_action-replaced ELSE c_action-written ).
      APPEND ls_result TO rt_results.
      APPEND VALUE #( name = lv_name ) TO lt_written.
      lv_written = lv_written + 1.
    ENDLOOP.
    IF lv_written > 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDMETHOD.

  METHOD get_webexcel_directory.
    DATA lt_candidates TYPE string_table.
* Confirmed layout first: model before category, i.e.
* {env}\{model}\EEXCEL\{library}. Category-before-model kept as a fallback.
    APPEND |\\ROOT\\WEBFOLDERS\\{ iv_environment }\\{ iv_model }\\{ c_webexcel_folder }\\{ iv_library }\\| TO lt_candidates.
    APPEND |\\ROOT\\WEBFOLDERS\\{ iv_environment }\\{ c_webexcel_folder }\\{ iv_model }\\{ iv_library }\\| TO lt_candidates.
    LOOP AT lt_candidates INTO DATA(lv_candidate).
      IF rv_directory IS INITIAL.
        rv_directory = lv_candidate.
      ENDIF.
      DATA lv_dirname TYPE ujf_doctree-docname.
      DATA lv_exists TYPE uj_flg.
      lv_dirname = lv_candidate.
      CLEAR lv_exists.
      TRY.
          io_files->check_directory_exist(
            EXPORTING i_dirname = lv_dirname i_appset_id = iv_environment
            IMPORTING e_result = lv_exists ).
        CATCH cx_ujf_file_service_error.
          CLEAR lv_exists.
      ENDTRY.
      IF lv_exists = abap_true.
        rv_directory = lv_candidate.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD workbook_library.
    rv_library = COND #( WHEN iv_folder = 'SCHEDULE' THEN c_schedule_library
                         ELSE c_report_library ).
  ENDMETHOD.

  METHOD is_workbook_name.
    DATA(lv_upper) = to_upper( iv_name ).
    rv_ok = boolc( lv_upper CP |*{ c_workbook_ext_xlsm }|
                OR lv_upper CP |*{ c_workbook_ext_xlsx }|
                OR lv_upper CP |*{ c_workbook_ext_xls }| ).
  ENDMETHOD.

  METHOD list_workbooks.
    DATA(ls_user) = VALUE uj0_s_user( user_id = sy-uname langu = sy-langu ).
    DATA(lo_files) = cl_ujf_file_service_mgr=>factory(
      i_appset = iv_environment is_user = ls_user ).
    DATA lv_directory TYPE ujf_doctree-docname.
    lv_directory = get_webexcel_directory( io_files = lo_files iv_environment = iv_environment
                                           iv_model = iv_model iv_library = iv_library ).
* The file service lists one document type at a time, so query each
* recognised workbook extension and merge the results.
    DATA lt_ext TYPE string_table.
    lt_ext = VALUE #( ( c_workbook_ext_xlsm ) ( c_workbook_ext_xlsx ) ( c_workbook_ext_xls ) ).
    LOOP AT lt_ext INTO DATA(lv_ext).
      DATA lv_doctype TYPE ujf_doc-doctype.
      lv_doctype = substring( val = lv_ext off = 1 ).
      DATA lt_documents TYPE ujf_t_doc.
      CLEAR lt_documents.
* A model may have a report library but no input schedule library (or vice
* versa); an absent or empty library must yield no rows, not an error.
      TRY.
          lo_files->list_directory(
            EXPORTING i_dirname = lv_directory i_doctype = lv_doctype
                      i_sort = abap_true i_include_subfldrs = abap_false
            IMPORTING et_document_list = lt_documents ).
        CATCH cx_ujf_file_service_error.
          CLEAR lt_documents.
      ENDTRY.
      LOOP AT lt_documents INTO DATA(ls_document).
        DATA lt_parts TYPE string_table.
        SPLIT ls_document-docname AT '\' INTO TABLE lt_parts.
        READ TABLE lt_parts INTO DATA(lv_name) INDEX lines( lt_parts ).
        IF sy-subrc = 0 AND to_upper( lv_name ) CP |*{ lv_ext }|.
          APPEND VALUE #( name = lv_name folder = iv_folder ) TO rt_files.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
    SORT rt_files BY name.
    DELETE ADJACENT DUPLICATES FROM rt_files COMPARING name.
  ENDMETHOD.

  METHOD get_workbooks.
    DATA(lt_models) = get_models( iv_environment ).
    READ TABLE lt_models TRANSPORTING NO FIELDS WITH KEY id = iv_model.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
* Reports and input schedules are two separate WebExcel libraries; list both
* and tag each entry with a client-facing folder token.
    APPEND LINES OF list_workbooks( iv_environment = iv_environment iv_model = iv_model
                                    iv_library = c_report_library iv_folder = 'REPORT' ) TO rt_files.
    APPEND LINES OF list_workbooks( iv_environment = iv_environment iv_model = iv_model
                                    iv_library = c_schedule_library iv_folder = 'SCHEDULE' ) TO rt_files.
  ENDMETHOD.

  METHOD get_workbook.
    DATA(lv_library) = workbook_library( iv_folder ).
    DATA(lt_files) = list_workbooks( iv_environment = iv_environment iv_model = iv_model
                                     iv_library = lv_library iv_folder = iv_folder ).
    READ TABLE lt_files TRANSPORTING NO FIELDS WITH KEY name = iv_name.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    DATA(ls_user) = VALUE uj0_s_user( user_id = sy-uname langu = sy-langu ).
    DATA(lo_files) = cl_ujf_file_service_mgr=>factory(
      i_appset = iv_environment is_user = ls_user ).
    DATA(lv_directory) = get_webexcel_directory( io_files = lo_files iv_environment = iv_environment
                                                 iv_model = iv_model iv_library = lv_library ).
    lo_files->get_document(
      EXPORTING i_docname = |{ lv_directory }{ iv_name }| i_retzip = abap_false
      IMPORTING e_document_content = rs_file-content ).
    rs_file-name = iv_name.
    rs_file-folder = iv_folder.
  ENDMETHOD.

  METHOD import_workbooks.
* Authorise the model up front; also fixes the BPC context for the file service.
    DATA(lt_models) = get_models( iv_environment ).
    READ TABLE lt_models TRANSPORTING NO FIELDS WITH KEY id = iv_model.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA(ls_user) = VALUE uj0_s_user( user_id = sy-uname langu = sy-langu ).
    DATA(lo_files) = cl_ujf_file_service_mgr=>factory(
      i_appset = iv_environment is_user = ls_user ).
* Existing files per library, resolved once so repeated imports stay cheap.
    DATA(lt_existing_rep) = list_workbooks( iv_environment = iv_environment iv_model = iv_model
                                            iv_library = c_report_library iv_folder = 'REPORT' ).
    DATA(lt_existing_sch) = list_workbooks( iv_environment = iv_environment iv_model = iv_model
                                            iv_library = c_schedule_library iv_folder = 'SCHEDULE' ).
    DATA: ls_result TYPE ty_workbook_import,
          lt_written TYPE ty_workbooks,
          lv_name TYPE string,
          lv_library TYPE string,
          lv_directory TYPE string,
          lv_docname TYPE uj_docname,
          lv_path TYPE string,
          lv_exists TYPE abap_bool,
          lv_written TYPE i.
    LOOP AT it_files INTO DATA(ls_file).
      CLEAR ls_result.
      lv_name = condense( ls_file-name ).
      ls_result-name = lv_name.
      ls_result-folder = ls_file-folder.
      IF lv_name IS INITIAL.
        RAISE EXCEPTION TYPE cx_uj_input_error
          EXPORTING object = 'Workbook' key = lv_name.
      ENDIF.
      IF lv_name CA '/' OR lv_name CA '\'
         OR is_workbook_name( lv_name ) = abap_false.
        RAISE EXCEPTION TYPE cx_uj_input_error
          EXPORTING object = 'Workbook' key = lv_name.
      ENDIF.
      READ TABLE lt_written TRANSPORTING NO FIELDS
        WITH KEY name = lv_name folder = ls_file-folder.
      IF sy-subrc = 0.
        ls_result-action = c_action-skipped.
        ls_result-message = 'The workbook is contained twice in the import'.
        APPEND ls_result TO rt_results.
        CONTINUE.
      ENDIF.
      lv_library = workbook_library( ls_file-folder ).
      IF ls_file-folder = 'SCHEDULE'.
        READ TABLE lt_existing_sch TRANSPORTING NO FIELDS WITH KEY name = lv_name.
      ELSE.
        READ TABLE lt_existing_rep TRANSPORTING NO FIELDS WITH KEY name = lv_name.
      ENDIF.
      lv_exists = boolc( sy-subrc = 0 ).
      IF lv_exists = abap_true AND iv_replace = abap_false.
        ls_result-action = c_action-skipped.
        ls_result-message = 'The workbook already exists in this model'.
        APPEND ls_result TO rt_results.
        CONTINUE.
      ENDIF.
      lv_directory = get_webexcel_directory( io_files = lo_files iv_environment = iv_environment
                                             iv_model = iv_model iv_library = lv_library ).
      lv_path = |{ lv_directory }{ lv_name }|.
      IF strlen( lv_path ) > c_docname_length.
        RAISE EXCEPTION TYPE cx_uj_input_error
          EXPORTING object = 'Workbook Path' key = lv_name.
      ENDIF.
      lv_docname = lv_path.
      TRY.
          lo_files->put_document(
            i_docname = lv_docname i_doc_content = ls_file-content
            i_compression = abap_false i_splice_zip = abap_false ).
        CATCH cx_ujf_file_service_error INTO DATA(lx_file).
          ls_result-action = c_action-failed.
          ls_result-message = lx_file->get_text( ).
          APPEND ls_result TO rt_results.
          CONTINUE.
      ENDTRY.
      ls_result-action = COND #( WHEN lv_exists = abap_true
                                 THEN c_action-replaced ELSE c_action-written ).
      APPEND ls_result TO rt_results.
      APPEND VALUE #( name = lv_name folder = ls_file-folder ) TO lt_written.
      lv_written = lv_written + 1.
    ENDLOOP.
    IF lv_written > 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDMETHOD.

  METHOD get_dimensions.
* Reject models outside the user's environment and set the BPC context.
    DATA(lt_models) = get_models( iv_environment ).
    READ TABLE lt_models TRANSPORTING NO FIELDS WITH KEY id = iv_model.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA(lo_manager) = cl_uja_bpc_admin_factory=>get_appset_manager(
      i_appset_id = iv_environment if_disable_security = abap_false ).
    lo_manager->get_applications(
      EXPORTING if_summary = abap_false
      IMPORTING et_applications = DATA(lt_applications) ).
    READ TABLE lt_applications INTO DATA(ls_application)
      WITH KEY application_id = iv_model.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    LOOP AT ls_application-dimensions INTO DATA(ls_dimension).
      APPEND VALUE #( id = ls_dimension-dimension
                      description = ls_dimension-description
                      dim_type = ls_dimension-dim_type ) TO rt_dimensions.
    ENDLOOP.
    SORT rt_dimensions BY id.
  ENDMETHOD.

  METHOD get_dimension_members.
* Validate the dimension belongs to the model, then read its members
* together with all of their attribute (property) values.
    DATA(lt_dimensions) = get_dimensions( iv_environment = iv_environment iv_model = iv_model ).
    READ TABLE lt_dimensions TRANSPORTING NO FIELDS WITH KEY id = iv_dimension.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA lo_dim TYPE REF TO cl_uja_dim.
    TRY.
        CREATE OBJECT lo_dim
          EXPORTING i_appset_id = iv_environment i_dimension = iv_dimension.
      CATCH cx_uja_admin_error.
        RAISE EXCEPTION TYPE cx_uj_static_check.
    ENDTRY.
    DATA lt_attr TYPE uja_t_attr.
    TRY.
        lo_dim->get_attr_list( IMPORTING et_attr_list = lt_attr ).
      CATCH cx_root.
        CLEAR lt_attr.
    ENDTRY.
    DATA lt_attr_name TYPE uja_t_attr_name.
    LOOP AT lt_attr INTO DATA(ls_attr).
      APPEND ls_attr-attribute_name TO lt_attr_name.
    ENDLOOP.
    DATA lr_data TYPE REF TO data.
    TRY.
        lo_dim->read_mbr_data(
          EXPORTING it_attr_list = lt_attr_name if_inc_txt = abap_true
          IMPORTING er_data = lr_data ).
      CATCH cx_uja_admin_error.
        RAISE EXCEPTION TYPE cx_uj_static_check.
    ENDTRY.
    FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.
    ASSIGN lr_data->* TO <lt_data>.
    IF <lt_data> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
    FIELD-SYMBOLS <ls_row> TYPE any.
    FIELD-SYMBOLS <lv_val> TYPE any.
    LOOP AT <lt_data> ASSIGNING <ls_row>.
      DATA ls_member TYPE ty_member.
      CLEAR ls_member.
      ASSIGN COMPONENT 'DIMENSION' OF STRUCTURE <ls_row> TO <lv_val>.
      IF sy-subrc = 0.
        ls_member-id = <lv_val>.
      ENDIF.
      ASSIGN COMPONENT 'DESCRIPTION' OF STRUCTURE <ls_row> TO <lv_val>.
      IF sy-subrc = 0.
        ls_member-description = <lv_val>.
      ENDIF.
      LOOP AT lt_attr_name INTO DATA(lv_attr_name).
        ASSIGN COMPONENT lv_attr_name OF STRUCTURE <ls_row> TO <lv_val>.
        IF sy-subrc = 0 AND <lv_val> IS NOT INITIAL.
          APPEND VALUE #( id = lv_attr_name value = |{ <lv_val> }| ) TO ls_member-properties.
        ENDIF.
      ENDLOOP.
      IF ls_member-id IS NOT INITIAL.
        APPEND ls_member TO rt_members.
      ENDIF.
    ENDLOOP.
    SORT rt_members BY id.
    DELETE ADJACENT DUPLICATES FROM rt_members COMPARING id.
  ENDMETHOD.

  METHOD export_data.
* Read the model's dimensions to shape the query and the CSV columns,
* build the member selections, run the flat RSDRI query and format CSV.
    DATA(lt_dimensions) = get_dimensions( iv_environment = iv_environment iv_model = iv_model ).
    IF lt_dimensions IS INITIAL.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA lt_dim_name TYPE uja_t_dim_list.
    LOOP AT lt_dimensions INTO DATA(ls_dim).
      APPEND ls_dim-id TO lt_dim_name.
    ENDLOOP.
* Build a dynamic result table: one CHAR column per dimension (named after
* the dimension) plus a SIGNEDDATA amount column, matching RSDRI output.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA(lo_member_type) = cl_abap_elemdescr=>get_c( 32 ).
    LOOP AT lt_dimensions INTO ls_dim.
      APPEND VALUE #( name = ls_dim-id type = lo_member_type ) TO lt_components.
    ENDLOOP.
    APPEND VALUE #( name = 'SIGNEDDATA'
                    type = CAST cl_abap_datadescr(
                             cl_abap_elemdescr=>describe_by_name( 'UJ_SDATA' ) ) ) TO lt_components.
    DATA(lo_struct) = cl_abap_structdescr=>get( lt_components ).
    DATA(lo_table) = cl_abap_tabledescr=>get( p_line_type = lo_struct ).
    DATA lr_result TYPE REF TO data.
    CREATE DATA lr_result TYPE HANDLE lo_table.
    FIELD-SYMBOLS <lt_result> TYPE STANDARD TABLE.
    ASSIGN lr_result->* TO <lt_result>.
* Member filters -> UJ0_T_SEL selection (sign I, option EQ per member).
    DATA lt_sel TYPE uj0_t_sel.
    LOOP AT it_filters INTO DATA(ls_filter).
      READ TABLE lt_dimensions TRANSPORTING NO FIELDS WITH KEY id = ls_filter-dimension.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      LOOP AT ls_filter-members INTO DATA(lv_member).
        IF lv_member IS INITIAL.
          CONTINUE.
        ENDIF.
        APPEND VALUE #( dimension = ls_filter-dimension
                        sign = 'I' option = 'EQ' low = lv_member ) TO lt_sel.
      ENDLOOP.
    ENDLOOP.
    DATA lo_query TYPE REF TO if_ujo_query.
    TRY.
        lo_query = cl_ujo_query_factory=>get_query_adapter(
          i_appset_id = iv_environment i_appl_id = iv_model ).
      CATCH cx_ujo_read.
        RAISE EXCEPTION TYPE cx_uj_static_check.
    ENDTRY.
    DATA lt_message TYPE uj0_t_message.
    DATA lf_eod TYPE rs_bool.
    TRY.
        lo_query->run_rsdri_query(
          EXPORTING it_dim_name = lt_dim_name it_range = lt_sel
                    if_check_security = abap_true
          IMPORTING et_data = <lt_result> e_end_of_data = lf_eod
                    et_message = lt_message ).
      CATCH cx_ujo_read.
        RAISE EXCEPTION TYPE cx_uj_static_check.
    ENDTRY.
* Header row: every dimension plus the signed data value.
    DATA lv_header TYPE string.
    LOOP AT lt_dimensions INTO ls_dim.
      IF lv_header IS NOT INITIAL.
        lv_header = lv_header && ','.
      ENDIF.
      lv_header = lv_header && csv_field( |{ ls_dim-id }| ).
    ENDLOOP.
    lv_header = lv_header && ',SIGNEDDATA'.
    rv_csv = lv_header.
    IF <lt_result> IS NOT ASSIGNED.
      rv_csv = rv_csv && cl_abap_char_utilities=>cr_lf.
      RETURN.
    ENDIF.
    FIELD-SYMBOLS <ls_row> TYPE any.
    FIELD-SYMBOLS <lv_val> TYPE any.
    LOOP AT <lt_result> ASSIGNING <ls_row>.
      DATA lv_line TYPE string.
      CLEAR lv_line.
      LOOP AT lt_dimensions INTO ls_dim.
        IF lv_line IS NOT INITIAL.
          lv_line = lv_line && ','.
        ENDIF.
        ASSIGN COMPONENT ls_dim-id OF STRUCTURE <ls_row> TO <lv_val>.
        IF sy-subrc = 0.
          lv_line = lv_line && csv_field( |{ <lv_val> }| ).
        ENDIF.
      ENDLOOP.
      ASSIGN COMPONENT 'SIGNEDDATA' OF STRUCTURE <ls_row> TO <lv_val>.
      IF sy-subrc = 0.
        lv_line = lv_line && ',' && condense( |{ <lv_val> }| ).
      ELSE.
        lv_line = lv_line && ','.
      ENDIF.
      rv_csv = rv_csv && cl_abap_char_utilities=>cr_lf && lv_line.
    ENDLOOP.
    rv_csv = rv_csv && cl_abap_char_utilities=>cr_lf.
  ENDMETHOD.

  METHOD csv_field.
* Quote a CSV field when it contains a comma, quote or line break.
    rv_field = iv_value.
    IF rv_field CA ',"' OR rv_field CA cl_abap_char_utilities=>cr_lf.
      REPLACE ALL OCCURRENCES OF '"' IN rv_field WITH '""'.
      rv_field = |"{ rv_field }"|.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
