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
             "! Parent per hierarchy (id = hierarchy, e.g. PARENTH1); none for a root.
             parents TYPE ty_properties,
           END OF ty_member,
           ty_members TYPE STANDARD TABLE OF ty_member WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_filter,
             dimension TYPE uj_dim_name,
             members TYPE STANDARD TABLE OF uj_dim_member WITH DEFAULT KEY,
           END OF ty_filter,
           ty_filters TYPE STANDARD TABLE OF ty_filter WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_data_import_result,
             submitted TYPE i,
             success TYPE i,
             failed TYPE i,
             messages TYPE string_table,
           END OF ty_data_import_result.
    TYPES: BEGIN OF ty_comment_import_result,
             submitted TYPE i,
             success TYPE i,
             skipped TYPE i,
             failed TYPE i,
             messages TYPE string_table,
           END OF ty_comment_import_result.
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
    "! Reads the model's comment table (the BPC comment store) and returns
    "! the rows that match the given dimension filters as CSV.
    "! Columns: all dimensions + SCOMMENT + USER_ID + DATEWRITTEN + KEYWORD + PRIORITY.
    METHODS get_comments
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                it_filters TYPE ty_filters
      RETURNING VALUE(rv_csv) TYPE string
      RAISING cx_uj_static_check.
    "! Writes CSV fact records (one column per dimension plus SIGNEDDATA, the
    "! format export_data produces) into a model through the BPC write-back
    "! API. Each value overwrites the stored value at its intersection.
    METHODS import_data
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_csv TYPE string
      RETURNING VALUE(rs_result) TYPE ty_data_import_result
      RAISING cx_uj_static_check.
    "! Adds CSV comments (the format get_comments produces) to a model through
    "! the BPC comment manager. Comments whose intersection, author and text
    "! already exist are skipped. With iv_keep_author the USER_ID and
    "! DATEWRITTEN columns are kept, otherwise the importing user and time.
    METHODS import_comments
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
                iv_csv TYPE string iv_keep_author TYPE abap_bool
      RETURNING VALUE(rs_result) TYPE ty_comment_import_result
      RAISING cx_uj_static_check.

  PRIVATE SECTION.
    METHODS csv_field IMPORTING iv_value TYPE string RETURNING VALUE(rv_field) TYPE string.
    "! Splits one CSV line into its fields (double-quoted fields may hold commas).
    METHODS parse_csv_line IMPORTING iv_line TYPE string RETURNING VALUE(rt_fields) TYPE string_table.
    "! Splits CSV text into records; a double-quoted field may hold line breaks.
    METHODS split_csv_records IMPORTING iv_csv TYPE string RETURNING VALUE(rt_records) TYPE string_table.
    "! DDIC name of the model's comment table, e.g. /1CPMB/BSJY1CMT.
    METHODS comment_table_name
      IMPORTING iv_environment TYPE uj_appset_id iv_model TYPE uj_appl_id
      RETURNING VALUE(rv_tabname) TYPE tabname
      RAISING cx_uj_static_check.
    "! Adds a message to an import result unless it is already there or the list is full.
    METHODS add_import_message IMPORTING iv_text TYPE string CHANGING ct_messages TYPE string_table.
    "! A data import reports at most this many distinct messages.
    CONSTANTS c_max_import_messages TYPE i VALUE 100 ##NO_TEXT.
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
* Each hierarchy (PARENTH1, PARENTH2, ...) adds a column with the member's parent.
    DATA lt_hier TYPE uja_t_hier.
    DATA lt_hier_name TYPE uja_t_hier_name.
    IF lo_dim->has_hier( ) = abap_true.
      TRY.
          lo_dim->get_hier_list( IMPORTING et_hier_info = lt_hier ).
        CATCH cx_uja_admin_error.
          CLEAR lt_hier.
      ENDTRY.
    ENDIF.
    LOOP AT lt_hier INTO DATA(ls_hier).
      APPEND ls_hier-hier_name TO lt_hier_name.
    ENDLOOP.
    DATA lt_attr_name TYPE uja_t_attr_name.
    LOOP AT lt_attr INTO DATA(ls_attr).
      READ TABLE lt_hier_name TRANSPORTING NO FIELDS WITH KEY table_line = ls_attr-attribute_name.
      IF sy-subrc <> 0.
        APPEND ls_attr-attribute_name TO lt_attr_name.
      ENDIF.
    ENDLOOP.
    DATA lr_data TYPE REF TO data.
    TRY.
        lo_dim->read_mbr_data(
          EXPORTING it_attr_list = lt_attr_name it_hier_list = lt_hier_name if_inc_txt = abap_true
          IMPORTING er_data = lr_data ).
      CATCH cx_uja_admin_error.
        RAISE EXCEPTION TYPE cx_uj_static_check.
    ENDTRY.
    FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.
    ASSIGN lr_data->* TO <lt_data>.
    IF <lt_data> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
* The row structure read_mbr_data builds names its columns after the
* attributes; the member id is the 'ID' attribute and the text is
* 'EVDESCRIPTION'. Resolve those column names defensively (several BPC
* releases have used ID / MEMBER_NAME / the dimension id, and
* EVDESCRIPTION / DESCRIPTION) so members are never silently dropped.
    DATA lv_id_col TYPE string.
    DATA lv_desc_col TYPE string.
    DATA(lo_line) = CAST cl_abap_structdescr(
      CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( <lt_data> ) )->get_table_line_type( ) ).
    LOOP AT lo_line->components INTO DATA(ls_comp).
      DATA(lv_col) = to_upper( ls_comp-name ).
      IF lv_id_col IS INITIAL AND ( lv_col = 'ID' OR lv_col = 'MEMBER_NAME'
          OR lv_col = 'MEMBER' OR lv_col = iv_dimension ).
        lv_id_col = ls_comp-name.
      ENDIF.
      IF lv_desc_col IS INITIAL AND ( lv_col = 'EVDESCRIPTION' OR lv_col = 'DESCRIPTION' ).
        lv_desc_col = ls_comp-name.
      ENDIF.
    ENDLOOP.
    IF lv_id_col IS INITIAL.
      lv_id_col = 'ID'.
    ENDIF.
    FIELD-SYMBOLS <ls_row> TYPE any.
    FIELD-SYMBOLS <lv_val> TYPE any.
    LOOP AT <lt_data> ASSIGNING <ls_row>.
      DATA ls_member TYPE ty_member.
      CLEAR ls_member.
      ASSIGN COMPONENT lv_id_col OF STRUCTURE <ls_row> TO <lv_val>.
      IF sy-subrc = 0.
        ls_member-id = <lv_val>.
      ENDIF.
      IF lv_desc_col IS NOT INITIAL.
        ASSIGN COMPONENT lv_desc_col OF STRUCTURE <ls_row> TO <lv_val>.
        IF sy-subrc = 0.
          ls_member-description = <lv_val>.
        ENDIF.
      ENDIF.
      LOOP AT lt_attr_name INTO DATA(lv_attr_name).
        IF to_upper( lv_attr_name ) = 'ID' OR to_upper( lv_attr_name ) = 'EVDESCRIPTION'.
          CONTINUE.
        ENDIF.
        ASSIGN COMPONENT lv_attr_name OF STRUCTURE <ls_row> TO <lv_val>.
        IF sy-subrc = 0 AND <lv_val> IS NOT INITIAL.
          APPEND VALUE #( id = lv_attr_name value = |{ <lv_val> }| ) TO ls_member-properties.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_hier_name INTO DATA(lv_hier_name).
        ASSIGN COMPONENT lv_hier_name OF STRUCTURE <ls_row> TO <lv_val>.
        IF sy-subrc = 0 AND <lv_val> IS NOT INITIAL.
          APPEND VALUE #( id = lv_hier_name value = |{ <lv_val> }| ) TO ls_member-parents.
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


  METHOD import_data.
* Read the model's dimensions (this also rejects models outside the user's
* environment), parse the CSV into a write-back record table and post it
* through the BPC write-back API, which checks work status, data access
* and base members per record.
    TYPES: BEGIN OF ty_col,
             index TYPE i,
             name TYPE string,
           END OF ty_col.
    DATA lt_cols TYPE STANDARD TABLE OF ty_col WITH DEFAULT KEY.
    DATA ls_col TYPE ty_col.
    DATA lt_header TYPE string_table.
    DATA lt_fields TYPE string_table.
    DATA lv_head TYPE string.
    DATA lv_line TYPE string.
    DATA lv_line_no TYPE i.
    DATA lv_value TYPE string.
    DATA lv_number TYPE string.
    DATA lv_float TYPE f.
    DATA lv_row_ok TYPE abap_bool.
    DATA lv_header_read TYPE abap_bool.
    DATA lv_header_error TYPE abap_bool.
    DATA lv_parsed_fail TYPE i.
    DATA lv_text TYPE string.
    DATA lr_records TYPE REF TO data.
    DATA lr_line TYPE REF TO data.
    DATA lr_errors TYPE REF TO data.
    DATA ls_status TYPE ujo_s_wb_status.
    DATA lt_message TYPE uj0_t_message.
    DATA ls_message TYPE uj0_s_message.
    DATA lf_success TYPE uj_flg.
    DATA lo_appl TYPE REF TO if_uja_application_manager.
    DATA lo_wb TYPE REF TO if_ujo_write_back.
    DATA lx_wb TYPE REF TO cx_ujo_write_back.
    FIELD-SYMBOLS <lt_records> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <lt_errors> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_record> TYPE any.
    FIELD-SYMBOLS <lv_target> TYPE any.

    DATA(lt_dimensions) = get_dimensions( iv_environment = iv_environment iv_model = iv_model ).
    IF lt_dimensions IS INITIAL.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA(ls_user) = VALUE uj0_s_user( user_id = sy-uname langu = sy-langu ).
    TRY.
        cl_uj_context=>set_cur_context( i_appset_id = iv_environment is_user = ls_user
                                        i_appl_id = iv_model ).
        lo_appl = cl_uja_bpc_admin_factory=>get_application_manager(
          i_appset_id = iv_environment i_application_id = iv_model ).
* Business-name record table: one column per dimension plus SIGNEDDATA.
        lo_appl->create_data_ref( EXPORTING i_data_type = 'T' if_tech_name = abap_false
                                  IMPORTING er_data = lr_records ).
      CATCH cx_root.
        RAISE EXCEPTION TYPE cx_uj_static_check.
    ENDTRY.
* Writing data needs the same task as sending data from the EPM add-in.
    cl_uj_context=>get_cur_context( )->check_task_access( i_task_name = uje0_cs_task_id-p0038 ).
    ASSIGN lr_records->* TO <lt_records>.
    IF <lt_records> IS NOT ASSIGNED.
      RAISE EXCEPTION TYPE cx_uj_static_check.
    ENDIF.
    CREATE DATA lr_line LIKE LINE OF <lt_records>.
    ASSIGN lr_line->* TO <ls_record>.

    DATA(lv_cr) = substring( val = cl_abap_char_utilities=>cr_lf len = 1 ).
    SPLIT iv_csv AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_lines).
    LOOP AT lt_lines INTO lv_line.
      lv_line_no = sy-tabix.
      REPLACE ALL OCCURRENCES OF lv_cr IN lv_line WITH ``.
      IF strlen( condense( lv_line ) ) = 0.
        CONTINUE.
      ENDIF.
      IF lv_header_read = abap_false.
* Header: every model dimension and SIGNEDDATA, in any order.
        lv_header_read = abap_true.
        lt_header = parse_csv_line( lv_line ).
        LOOP AT lt_header INTO lv_head.
          ls_col-index = sy-tabix.
          ls_col-name = to_upper( condense( lv_head ) ).
          APPEND ls_col TO lt_cols.
        ENDLOOP.
        LOOP AT lt_dimensions INTO DATA(ls_dim).
          READ TABLE lt_cols TRANSPORTING NO FIELDS WITH KEY name = ls_dim-id.
          IF sy-subrc <> 0.
            APPEND |Missing column { ls_dim-id }| TO rs_result-messages.
          ENDIF.
        ENDLOOP.
        READ TABLE lt_cols TRANSPORTING NO FIELDS WITH KEY name = 'SIGNEDDATA'.
        IF sy-subrc <> 0.
          APPEND `Missing column SIGNEDDATA` TO rs_result-messages.
        ENDIF.
        LOOP AT lt_cols INTO ls_col WHERE name <> 'SIGNEDDATA'.
          READ TABLE lt_dimensions TRANSPORTING NO FIELDS WITH KEY id = ls_col-name.
          IF sy-subrc <> 0.
            APPEND |Unknown column { ls_col-name }| TO rs_result-messages.
          ENDIF.
        ENDLOOP.
        lv_header_error = boolc( rs_result-messages IS NOT INITIAL ).
        CONTINUE.
      ENDIF.
      rs_result-submitted = rs_result-submitted + 1.
      IF lv_header_error = abap_true.
        rs_result-failed = rs_result-failed + 1.
        CONTINUE.
      ENDIF.
      lt_fields = parse_csv_line( lv_line ).
      CLEAR <ls_record>.
      lv_row_ok = abap_true.
      LOOP AT lt_cols INTO ls_col.
        CLEAR lv_value.
        READ TABLE lt_fields INTO lv_value INDEX ls_col-index.
        ASSIGN COMPONENT ls_col-name OF STRUCTURE <ls_record> TO <lv_target>.
        IF sy-subrc <> 0.
          lv_row_ok = abap_false.
          EXIT.
        ENDIF.
        IF ls_col-name = 'SIGNEDDATA'.
          lv_number = lv_value.
          CONDENSE lv_number NO-GAPS.
          TRY.
              <lv_target> = lv_number.
            CATCH cx_sy_conversion_error.
* Scientific notation is accepted with the precision of a float.
              TRY.
                  lv_float = lv_number.
                  <lv_target> = lv_float.
                CATCH cx_sy_conversion_error.
                  lv_row_ok = abap_false.
              ENDTRY.
          ENDTRY.
        ELSE.
          <lv_target> = condense( lv_value ).
          IF <lv_target> IS INITIAL.
            lv_row_ok = abap_false.
          ENDIF.
        ENDIF.
      ENDLOOP.
      IF lv_row_ok = abap_true.
        APPEND <ls_record> TO <lt_records>.
      ELSE.
        rs_result-failed = rs_result-failed + 1.
        IF lines( rs_result-messages ) < c_max_import_messages.
          APPEND |Line { lv_line_no }: missing member or invalid SIGNEDDATA value| TO rs_result-messages.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF <lt_records> IS INITIAL.
      RETURN.
    ENDIF.

* Records carry the stored values (as exported via RSDRI), so INC/LEQ
* accounts must not be sign-reversed; calc_delta (default) makes each value
* overwrite the stored value at its intersection. No default logic runs.
    DATA(ls_param) = cl_ujo_wb_factory=>default_wb_param( ).
    ls_param-sign_trans = abap_false.
    ls_param-default_logic = abap_false.
    CREATE DATA lr_errors LIKE <lt_records>.
    ASSIGN lr_errors->* TO <lt_errors>.
    lv_parsed_fail = rs_result-failed.
    TRY.
        lo_wb = cl_ujo_wb_factory=>create_write_back( ).
        lo_wb->write_back(
          EXPORTING i_appset_id = iv_environment i_appl_id = iv_model
                    is_wb_param = ls_param it_records = <lt_records>
          IMPORTING es_wb_status = ls_status et_error_records = <lt_errors>
                    et_message = lt_message ef_success = lf_success ).
      CATCH cx_ujo_write_back INTO lx_wb.
* The whole batch was refused (e.g. locked by work status).
        ROLLBACK WORK.
        rs_result-failed = lv_parsed_fail + lines( <lt_records> ).
        APPEND lx_wb->get_text( ) TO rs_result-messages.
        RETURN.
    ENDTRY.
    rs_result-failed = lv_parsed_fail + ls_status-nr_fail.
    rs_result-success = nmax( val1 = 0 val2 = lines( <lt_records> ) - ls_status-nr_fail ).
    LOOP AT lt_message INTO ls_message.
      IF lines( rs_result-messages ) >= c_max_import_messages.
        EXIT.
      ENDIF.
      lv_text = ls_message-message.
      IF lv_text IS INITIAL AND ls_message-msgid IS NOT INITIAL.
        MESSAGE ID ls_message-msgid TYPE 'I' NUMBER ls_message-msgno
          WITH ls_message-msgv1 ls_message-msgv2 ls_message-msgv3 ls_message-msgv4
          INTO lv_text.
      ENDIF.
      IF lv_text IS NOT INITIAL.
        READ TABLE rs_result-messages TRANSPORTING NO FIELDS WITH KEY table_line = lv_text.
        IF sy-subrc <> 0.
          APPEND lv_text TO rs_result-messages.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF rs_result-success > 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDMETHOD.

  METHOD parse_csv_line.
* Fields are separated by commas; a double-quoted field may contain commas,
* and "" inside a quoted field stands for one quote.
    DATA lv_field TYPE string.
    DATA lv_char TYPE string.
    DATA lv_quoted TYPE abap_bool.
    DATA lv_pos TYPE i.
    DATA lv_next TYPE i.
    DATA(lv_len) = strlen( iv_line ).
    WHILE lv_pos < lv_len.
      lv_char = substring( val = iv_line off = lv_pos len = 1 ).
      lv_next = lv_pos + 1.
      IF lv_quoted = abap_true.
        IF lv_char = '"'.
          IF lv_next < lv_len AND substring( val = iv_line off = lv_next len = 1 ) = '"'.
            lv_field = lv_field && '"'.
            lv_next = lv_next + 1.
          ELSE.
            lv_quoted = abap_false.
          ENDIF.
        ELSE.
          lv_field = lv_field && lv_char.
        ENDIF.
      ELSEIF lv_char = '"'.
        lv_quoted = abap_true.
      ELSEIF lv_char = ','.
        APPEND lv_field TO rt_fields.
        CLEAR lv_field.
      ELSE.
        lv_field = lv_field && lv_char.
      ENDIF.
      lv_pos = lv_next.
    ENDWHILE.
    APPEND lv_field TO rt_fields.
  ENDMETHOD.


  METHOD get_comments.
* Resolve the comment table name for this environment/model, then SELECT
* all rows, optionally filtered by dimension members.
    DATA(lt_dimensions) = get_dimensions( iv_environment = iv_environment iv_model = iv_model ).
    IF lt_dimensions IS INITIAL.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA(lv_tabname) = comment_table_name( iv_environment = iv_environment iv_model = iv_model ).
* Build a WHERE clause from the dimension filters (sign I, option EQ).
    DATA lt_where TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_clause TYPE string.
    LOOP AT it_filters INTO DATA(ls_filter).
      READ TABLE lt_dimensions TRANSPORTING NO FIELDS WITH KEY id = ls_filter-dimension.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      DATA lv_sub TYPE string.
      CLEAR lv_sub.
      LOOP AT ls_filter-members INTO DATA(lv_member).
        IF lv_sub IS NOT INITIAL.
          lv_sub = lv_sub && ` OR `.
        ENDIF.
        lv_sub = lv_sub && ls_filter-dimension && ` = '` && lv_member && `'`.
      ENDLOOP.
      IF lv_sub IS NOT INITIAL.
        lv_clause = `( ` && lv_sub && ` )`.
        APPEND lv_clause TO lt_where.
      ENDIF.
    ENDLOOP.
* CSV header: all dimensions, then the metadata and comment columns.
    DATA lv_header TYPE string.
    LOOP AT lt_dimensions INTO DATA(ls_dim).
      IF lv_header IS NOT INITIAL.
        lv_header = lv_header && ','.
      ENDIF.
      lv_header = lv_header && csv_field( |{ ls_dim-id }| ).
    ENDLOOP.
    lv_header = lv_header && ',SCOMMENT,USER_ID,DATEWRITTEN,KEYWORD,PRIORITY'.
    rv_csv = lv_header.
* Dynamic SELECT into a generic table.
    DATA lr_data TYPE REF TO data.
    CREATE DATA lr_data TYPE STANDARD TABLE OF (lv_tabname).
    FIELD-SYMBOLS <lt_rows> TYPE STANDARD TABLE.
    ASSIGN lr_data->* TO <lt_rows>.
    IF lt_where IS INITIAL.
      SELECT * FROM (lv_tabname) INTO TABLE <lt_rows>.
    ELSE.
      SELECT * FROM (lv_tabname) INTO TABLE <lt_rows>
        WHERE (lt_where).
    ENDIF.
    FIELD-SYMBOLS <ls_row> TYPE any.
    FIELD-SYMBOLS <lv_val> TYPE any.
    DATA lv_line TYPE string.
    DATA lv_ts TYPE string.
    LOOP AT <lt_rows> ASSIGNING <ls_row>.
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
* SCOMMENT
      ASSIGN COMPONENT 'SCOMMENT' OF STRUCTURE <ls_row> TO <lv_val>.
      lv_line = lv_line && ',' && csv_field( COND #( WHEN sy-subrc = 0 THEN |{ <lv_val> }| ) ).
* USER_ID
      ASSIGN COMPONENT 'USER_ID' OF STRUCTURE <ls_row> TO <lv_val>.
      lv_line = lv_line && ',' && csv_field( COND #( WHEN sy-subrc = 0 THEN |{ <lv_val> }| ) ).
* DATEWRITTEN (timestamp -> ISO string)
      ASSIGN COMPONENT 'DATEWRITTEN' OF STRUCTURE <ls_row> TO <lv_val>.
      IF sy-subrc = 0.
        lv_ts = |{ <lv_val> }|.
        CONDENSE lv_ts NO-GAPS.
        lv_line = lv_line && ',' && csv_field( lv_ts ).
      ELSE.
        lv_line = lv_line && ','.
      ENDIF.
* KEYWORD
      ASSIGN COMPONENT 'KEYWORD' OF STRUCTURE <ls_row> TO <lv_val>.
      lv_line = lv_line && ',' && csv_field( COND #( WHEN sy-subrc = 0 THEN |{ <lv_val> }| ) ).
* PRIORITY
      ASSIGN COMPONENT 'PRIORITY' OF STRUCTURE <ls_row> TO <lv_val>.
      IF sy-subrc = 0.
        lv_line = lv_line && ',' && condense( |{ <lv_val> }| ).
      ELSE.
        lv_line = lv_line && ','.
      ENDIF.
      rv_csv = rv_csv && cl_abap_char_utilities=>cr_lf && lv_line.
    ENDLOOP.
    rv_csv = rv_csv && cl_abap_char_utilities=>cr_lf.
  ENDMETHOD.


  METHOD comment_table_name.
* Get the prefix pair (appset + appl) needed by CL_UJ_GEN_TABLE.
    DATA ls_prefix TYPE uja_s_prefix.
    SELECT SINGLE appset_prefix INTO ls_prefix-appset_prefix
      FROM uja_appset_info WHERE appset_id = iv_environment.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    DATA(lo_app_mgr) = cl_uja_bpc_admin_factory=>get_application_manager(
      i_appset_id = iv_environment i_application_id = iv_model ).
    DATA ls_app TYPE uja_s_application.
    TRY.
        lo_app_mgr->get( IMPORTING es_application = ls_app ).
      CATCH cx_uja_admin_error cx_uj_no_auth cx_uj_static_check.
        RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDTRY.
    ls_prefix-appl_prefix = ls_app-appl_prefix.
* Resolve the actual DDIC table name.
    DATA lo_gentab TYPE REF TO cl_uj_gen_table.
    cl_uj_gen_table=>get_instance( IMPORTING eo_instance = lo_gentab ).
    DATA lv_gotstate TYPE ddgotstate.
    TRY.
        lo_gentab->get_ddic_table_name(
          EXPORTING i_table = cl_uj_gen_table=>gc_table_comment is_prefix = ls_prefix
          IMPORTING e_tabname = rv_tabname e_gotstate = lv_gotstate ).
      CATCH cx_uj_gen_ddic_error.
        RAISE EXCEPTION TYPE cx_uj_static_check.
    ENDTRY.
    IF lv_gotstate <> uj00_cs_gotstate-active OR rv_tabname IS INITIAL.
      RAISE EXCEPTION TYPE cx_uj_static_check.
    ENDIF.
  ENDMETHOD.


  METHOD split_csv_records.
* A line belongs to the previous one while that record has an odd number
* of double quotes, i.e. a quoted field is still open.
    DATA lv_record TYPE string.
    DATA lv_quotes TYPE i.
    DATA lv_open TYPE abap_bool.
    DATA(lv_cr) = substring( val = cl_abap_char_utilities=>cr_lf len = 1 ).
    SPLIT iv_csv AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_lines).
    LOOP AT lt_lines INTO DATA(lv_line).
      IF lv_open = abap_true.
        lv_record = lv_record && cl_abap_char_utilities=>newline && lv_line.
      ELSE.
        lv_record = lv_line.
      ENDIF.
      lv_quotes = lv_quotes + count( val = lv_line sub = '"' ).
      lv_open = boolc( lv_quotes MOD 2 = 1 ).
      IF lv_open = abap_true.
        CONTINUE.
      ENDIF.
      IF lv_record CP |*{ lv_cr }|.
        lv_record = substring( val = lv_record len = strlen( lv_record ) - 1 ).
      ENDIF.
      IF strlen( condense( lv_record ) ) > 0.
        APPEND lv_record TO rt_records.
      ENDIF.
      CLEAR: lv_record, lv_quotes.
    ENDLOOP.
    IF strlen( condense( lv_record ) ) > 0.
      APPEND lv_record TO rt_records.
    ENDIF.
  ENDMETHOD.


  METHOD add_import_message.
    IF lines( ct_messages ) >= c_max_import_messages.
      RETURN.
    ENDIF.
    READ TABLE ct_messages TRANSPORTING NO FIELDS WITH KEY table_line = iv_text.
    IF sy-subrc <> 0.
      APPEND iv_text TO ct_messages.
    ENDIF.
  ENDMETHOD.


  METHOD import_comments.
* Parse the CSV into BPC comments and add them through the comment manager,
* which checks the comment tasks, member write access and work status per
* comment. Blank dimension members leave the comment on a partial
* intersection. Comments whose intersection, author and text already exist
* (in the model or earlier in the file) are skipped.
    TYPES: BEGIN OF ty_dim_col,
             dimension TYPE uj_dim_name,
             index TYPE i,
           END OF ty_dim_col.
    TYPES: BEGIN OF ty_group,
             signature TYPE string,
             comments TYPE ujc_t_compact_cmtbl,
           END OF ty_group.
    DATA lt_dim_cols TYPE SORTED TABLE OF ty_dim_col WITH UNIQUE KEY dimension.
    DATA lt_groups TYPE HASHED TABLE OF ty_group WITH UNIQUE KEY signature.
    DATA lt_keys TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.
    DATA lt_header TYPE string_table.
    DATA lt_fields TYPE string_table.
    DATA lt_errors TYPE ujc_t_compact_cmtbl.
    DATA lt_message TYPE uj0_t_message.
    DATA ls_message TYPE uj0_s_message.
    DATA ls_comment TYPE ujc_s_compact_cmtbl.
    DATA lv_comment_col TYPE i.
    DATA lv_user_col TYPE i.
    DATA lv_date_col TYPE i.
    DATA lv_keyword_col TYPE i.
    DATA lv_priority_col TYPE i.
    DATA lv_row TYPE i.
    DATA lv_value TYPE string.
    DATA lv_key TYPE string.
    DATA lv_signature TYPE string.
    DATA lv_author TYPE string.
    DATA lv_error TYPE string.
    DATA lv_text TYPE string.
    DATA lr_rows TYPE REF TO data.
    DATA lo_manager TYPE REF TO cl_ujc_cmtmanager.
    DATA lx_comment TYPE REF TO cx_ujc_exception.
    FIELD-SYMBOLS <lt_rows> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_row> TYPE any.
    FIELD-SYMBOLS <lv_val> TYPE any.
    FIELD-SYMBOLS <ls_group> TYPE ty_group.
    FIELD-SYMBOLS <ls_error> TYPE ujc_s_compact_cmtbl.

    DATA(lt_dimensions) = get_dimensions( iv_environment = iv_environment iv_model = iv_model ).
    IF lt_dimensions IS INITIAL.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
* The comment manager reads the current BPC context in its constructor.
    DATA(ls_user) = VALUE uj0_s_user( user_id = sy-uname langu = sy-langu ).
    TRY.
        cl_uj_context=>set_cur_context( i_appset_id = iv_environment is_user = ls_user
                                        i_appl_id = iv_model ).
      CATCH cx_root.
        RAISE EXCEPTION TYPE cx_uj_static_check.
    ENDTRY.

* Header: every model dimension and SCOMMENT; USER_ID, DATEWRITTEN, KEYWORD
* and PRIORITY are optional.
    DATA(lt_records) = split_csv_records( iv_csv ).
    IF lt_records IS INITIAL.
      RETURN.
    ENDIF.
    READ TABLE lt_records INTO DATA(lv_header) INDEX 1.
    lt_header = parse_csv_line( lv_header ).
    LOOP AT lt_header INTO lv_value.
      DATA(lv_col) = sy-tabix.
      DATA(lv_name) = to_upper( condense( lv_value ) ).
      CASE lv_name.
        WHEN 'SCOMMENT'.
          lv_comment_col = lv_col.
        WHEN 'USER_ID'.
          lv_user_col = lv_col.
        WHEN 'DATEWRITTEN'.
          lv_date_col = lv_col.
        WHEN 'KEYWORD'.
          lv_keyword_col = lv_col.
        WHEN 'PRIORITY'.
          lv_priority_col = lv_col.
        WHEN OTHERS.
          READ TABLE lt_dimensions TRANSPORTING NO FIELDS WITH KEY id = lv_name.
          IF sy-subrc = 0.
            INSERT VALUE #( dimension = lv_name index = lv_col ) INTO TABLE lt_dim_cols.
          ELSE.
            add_import_message( EXPORTING iv_text = |Unknown column { lv_name }|
                                CHANGING ct_messages = rs_result-messages ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
    LOOP AT lt_dimensions INTO DATA(ls_dim).
      READ TABLE lt_dim_cols TRANSPORTING NO FIELDS WITH TABLE KEY dimension = ls_dim-id.
      IF sy-subrc <> 0.
        add_import_message( EXPORTING iv_text = |Missing column { ls_dim-id }|
                            CHANGING ct_messages = rs_result-messages ).
      ENDIF.
    ENDLOOP.
    IF lv_comment_col = 0.
      add_import_message( EXPORTING iv_text = `Missing column SCOMMENT`
                          CHANGING ct_messages = rs_result-messages ).
    ENDIF.
    rs_result-submitted = lines( lt_records ) - 1.
    IF rs_result-messages IS NOT INITIAL.
      rs_result-failed = rs_result-submitted.
      RETURN.
    ENDIF.

* Keys of the comments already stored: members of the intersection (in
* dimension order), author and text.
    DATA(lv_tabname) = comment_table_name( iv_environment = iv_environment iv_model = iv_model ).
    CREATE DATA lr_rows TYPE STANDARD TABLE OF (lv_tabname).
    ASSIGN lr_rows->* TO <lt_rows>.
    SELECT * FROM (lv_tabname) INTO TABLE <lt_rows>.
    LOOP AT <lt_rows> ASSIGNING <ls_row>.
      CLEAR lv_key.
      LOOP AT lt_dim_cols INTO DATA(ls_dim_col).
        ASSIGN COMPONENT ls_dim_col-dimension OF STRUCTURE <ls_row> TO <lv_val>.
        IF sy-subrc = 0 AND <lv_val> IS NOT INITIAL.
          lv_key = |{ lv_key }{ ls_dim_col-dimension }={ <lv_val> };|.
        ENDIF.
      ENDLOOP.
      ASSIGN COMPONENT 'USER_ID' OF STRUCTURE <ls_row> TO <lv_val>.
      IF sy-subrc = 0.
        lv_key = |{ lv_key }\|{ <lv_val> }|.
      ENDIF.
      ASSIGN COMPONENT 'SCOMMENT' OF STRUCTURE <ls_row> TO <lv_val>.
      IF sy-subrc = 0.
        lv_key = |{ lv_key }\|{ <lv_val> }|.
      ENDIF.
      INSERT lv_key INTO TABLE lt_keys.
    ENDLOOP.
    FREE <lt_rows>.

* Rows become comments, grouped by the set of dimensions they name: the
* manager builds its work status check from the first comment of a call.
    LOOP AT lt_records INTO DATA(lv_record) FROM 2.
      lv_row = sy-tabix - 1.
      lt_fields = parse_csv_line( lv_record ).
      CLEAR: ls_comment, lv_key, lv_signature, lv_error.
      LOOP AT lt_dim_cols INTO ls_dim_col.
        CLEAR lv_value.
        READ TABLE lt_fields INTO lv_value INDEX ls_dim_col-index.
        lv_value = to_upper( condense( lv_value ) ).
        IF lv_value IS NOT INITIAL.
          APPEND VALUE #( dim_name = ls_dim_col-dimension dim_value = lv_value ) TO ls_comment-dim_list.
          lv_signature = |{ lv_signature }{ ls_dim_col-dimension };|.
          lv_key = |{ lv_key }{ ls_dim_col-dimension }={ lv_value };|.
        ENDIF.
      ENDLOOP.
      IF ls_comment-dim_list IS INITIAL.
        lv_error = `no dimension members`.
      ENDIF.
      READ TABLE lt_fields INTO ls_comment-scomment INDEX lv_comment_col.
      IF strlen( condense( ls_comment-scomment ) ) = 0.
        lv_error = `empty comment`.
      ENDIF.
      IF lv_keyword_col > 0.
        CLEAR lv_value.
        READ TABLE lt_fields INTO lv_value INDEX lv_keyword_col.
        ls_comment-keyword = condense( lv_value ).
      ENDIF.
      IF lv_priority_col > 0.
        CLEAR lv_value.
        READ TABLE lt_fields INTO lv_value INDEX lv_priority_col.
        CONDENSE lv_value NO-GAPS.
        IF lv_value IS NOT INITIAL.
          IF lv_value CO '0123456789' AND strlen( lv_value ) <= 9.
            ls_comment-priority = lv_value.
          ELSE.
            lv_error = `invalid PRIORITY`.
          ENDIF.
        ENDIF.
      ENDIF.
      IF iv_keep_author = abap_true.
* Blank author or date falls back to the importing user and time.
        CLEAR lv_value.
        IF lv_user_col > 0.
          READ TABLE lt_fields INTO lv_value INDEX lv_user_col.
        ENDIF.
        ls_comment-user_id = to_upper( condense( lv_value ) ).
        IF ls_comment-user_id IS INITIAL.
          ls_comment-user_id = sy-uname.
        ENDIF.
        CLEAR lv_value.
        IF lv_date_col > 0.
          READ TABLE lt_fields INTO lv_value INDEX lv_date_col.
          CONDENSE lv_value NO-GAPS.
        ENDIF.
        IF lv_value IS INITIAL.
          GET TIME STAMP FIELD ls_comment-datewritten.
        ELSEIF lv_value CO '0123456789' AND strlen( lv_value ) <= 15.
          ls_comment-datewritten = lv_value.
        ELSE.
          lv_error = `invalid DATEWRITTEN`.
        ENDIF.
        lv_author = ls_comment-user_id.
      ELSE.
        lv_author = sy-uname.
      ENDIF.
      IF lv_error IS NOT INITIAL.
        rs_result-failed = rs_result-failed + 1.
        add_import_message( EXPORTING iv_text = |Row { lv_row }: { lv_error }|
                            CHANGING ct_messages = rs_result-messages ).
        CONTINUE.
      ENDIF.
      lv_key = |{ lv_key }\|{ lv_author }\|{ ls_comment-scomment }|.
      INSERT lv_key INTO TABLE lt_keys.
      IF sy-subrc <> 0.
        rs_result-skipped = rs_result-skipped + 1.
        CONTINUE.
      ENDIF.
* The manager matches rejected comments by record id; the DAO assigns the stored id.
      ls_comment-recordid = condense( |{ lv_row }| ).
      READ TABLE lt_groups ASSIGNING <ls_group> WITH TABLE KEY signature = lv_signature.
      IF sy-subrc <> 0.
        INSERT VALUE #( signature = lv_signature ) INTO TABLE lt_groups ASSIGNING <ls_group>.
      ENDIF.
      APPEND ls_comment TO <ls_group>-comments.
    ENDLOOP.

* IF_TIME_USER stamps the context user and the current time.
    DATA lv_time_user TYPE uj_flg.
    lv_time_user = boolc( iv_keep_author = abap_false ).
    LOOP AT lt_groups ASSIGNING <ls_group>.
      CLEAR: lt_errors, lt_message.
      TRY.
* A fresh manager per group: its work status check keeps state between calls.
          CREATE OBJECT lo_manager
            EXPORTING i_appset_id = iv_environment i_appl_id = iv_model.
          lo_manager->add_cmt(
            EXPORTING it_compact_cmtbl = <ls_group>-comments
                      if_time_user = lv_time_user
                      if_check_workstatus = abap_true
            IMPORTING et_error_cmtbl = lt_errors
            CHANGING ct_message = lt_message ).
        CATCH cx_ujc_exception INTO lx_comment.
          ROLLBACK WORK.
          rs_result-failed = rs_result-failed + lines( <ls_group>-comments ).
          add_import_message( EXPORTING iv_text = lx_comment->get_text( )
                              CHANGING ct_messages = rs_result-messages ).
          CONTINUE.
      ENDTRY.
      rs_result-failed = rs_result-failed + lines( lt_errors ).
      rs_result-success = rs_result-success + lines( <ls_group>-comments ) - lines( lt_errors ).
      LOOP AT lt_errors ASSIGNING <ls_error>.
        add_import_message(
          EXPORTING iv_text = |Row { condense( <ls_error>-recordid ) }: no write access to a member, or locked by work status|
          CHANGING ct_messages = rs_result-messages ).
      ENDLOOP.
      LOOP AT lt_message INTO ls_message.
        lv_text = ls_message-message.
        IF lv_text IS INITIAL AND ls_message-msgid IS NOT INITIAL.
          MESSAGE ID ls_message-msgid TYPE 'I' NUMBER ls_message-msgno
            WITH ls_message-msgv1 ls_message-msgv2 ls_message-msgv3 ls_message-msgv4
            INTO lv_text.
        ENDIF.
        IF lv_text IS NOT INITIAL.
          add_import_message( EXPORTING iv_text = lv_text CHANGING ct_messages = rs_result-messages ).
        ENDIF.
      ENDLOOP.
* ADD_CMT leaves the commit to its caller.
      IF lines( <ls_group>-comments ) > lines( lt_errors ).
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
