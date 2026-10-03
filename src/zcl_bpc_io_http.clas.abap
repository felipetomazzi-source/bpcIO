CLASS zcl_bpc_io_http DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_extension.
  PRIVATE SECTION.
    "! Request and response of the current call.
    DATA mo_server TYPE REF TO if_http_server.
    " Resources served by this handler.
    CONSTANTS:
      BEGIN OF c_resource,
        environments    TYPE string VALUE '/environments',
        license_audit   TYPE string VALUE '/licenses/audit',
        models          TYPE string VALUE '/models',
        scripts         TYPE string VALUE '/scripts',
        script          TYPE string VALUE '/script',
        packages        TYPE string VALUE '/packages',
        package         TYPE string VALUE '/package',
        import          TYPE string VALUE '/import',
        packages_import TYPE string VALUE '/packages/import',
        transformations  TYPE string VALUE '/transformations',
        transformation   TYPE string VALUE '/transformation',
        transforms_import TYPE string VALUE '/transformations/import',
        conversions      TYPE string VALUE '/conversions',
        conversion       TYPE string VALUE '/conversion',
        convers_import   TYPE string VALUE '/conversions/import',
        workbooks        TYPE string VALUE '/workbooks',
        workbook         TYPE string VALUE '/workbook',
        workbooks_import TYPE string VALUE '/workbooks/import',
        dimensions       TYPE string VALUE '/dimensions',
        members          TYPE string VALUE '/members',
        data_export      TYPE string VALUE '/data/export',
        data_import      TYPE string VALUE '/data/import',
        data_comments    TYPE string VALUE '/data/comments',
        comments_import  TYPE string VALUE '/data/comments/import',
      END OF c_resource.
    CONSTANTS:
      BEGIN OF c_method,
        get  TYPE string VALUE 'GET',
        post TYPE string VALUE 'POST',
      END OF c_method.
    "! One import request accepts at most this many scripts
    CONSTANTS c_max_scripts TYPE i VALUE 2000 ##NO_TEXT.
    "! and this much decoded script content (20 MB).
    CONSTANTS c_max_content TYPE i VALUE 20971520 ##NO_TEXT.
    "! One package import accepts at most this many packages
    CONSTANTS c_max_packages TYPE i VALUE 1000 ##NO_TEXT.
    "! and this much decoded package script content (5 MB).
    CONSTANTS c_max_package_content TYPE i VALUE 5242880 ##NO_TEXT.
    "! One transformation/conversion import accepts at most this many files
    CONSTANTS c_max_dm_files TYPE i VALUE 1000 ##NO_TEXT.
    "! and this much decoded definition + workbook content (20 MB).
    CONSTANTS c_max_dm_content TYPE i VALUE 20971520 ##NO_TEXT.
    "! One workbook import accepts at most this many workbooks
    CONSTANTS c_max_workbooks TYPE i VALUE 500 ##NO_TEXT.
    "! and this much decoded workbook content (50 MB); .xlsm reports are large.
    CONSTANTS c_max_workbook_content TYPE i VALUE 52428800 ##NO_TEXT.
    "! One data export accepts at most this many filter members in total.
    CONSTANTS c_max_filter_members TYPE i VALUE 100000 ##NO_TEXT.
    "! One data import request accepts at most this many CSV lines
    CONSTANTS c_max_import_rows TYPE i VALUE 50000 ##NO_TEXT.
    "! and this much CSV text (20 MB).
    CONSTANTS c_max_import_csv TYPE i VALUE 20971520 ##NO_TEXT.

    "! Sends 405 unless the request uses the expected method.
    METHODS require_method
      IMPORTING iv_method TYPE string
      RETURNING VALUE(rv_allowed) TYPE abap_bool.
    "! Read and validate the environment, model or script name of a request.
    "! An invalid value is answered with 400 and returned as initial.
    METHODS read_environment
      RETURNING VALUE(rv_environment) TYPE uj_appset_id.
    METHODS read_model
      RETURNING VALUE(rv_model) TYPE uj_appl_id.
    METHODS read_script_name
      RETURNING VALUE(rv_name) TYPE uj_docname.
    METHODS read_group
      RETURNING VALUE(rv_group) TYPE uj_pack_grp_id.
    METHODS read_package
      RETURNING VALUE(rv_package) TYPE uj_package_id.
    METHODS read_dm_name
      RETURNING VALUE(rv_name) TYPE uj_docname.
    METHODS handle_environments
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_license_audit
      RAISING cx_uj_no_auth cx_uj_input_error.
    METHODS handle_models
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_scripts
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_script
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_packages
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_package
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    "! Reads the uploaded Data Manager Packages and writes them into the model.
    METHODS handle_import_packages
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    "! Reads the uploaded Logic Scripts and writes them into the given model.
    METHODS handle_import
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_transformations
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_transformation
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_import_transformations
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_conversions
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_conversion
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_import_conversions
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    "! Shared writer for transformation and conversion file imports.
    METHODS handle_import_dm
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
                iv_ext TYPE string
      RAISING cx_uj_static_check.
    METHODS handle_workbooks
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_workbook
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_import_workbooks
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_dimensions
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_members
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    METHODS handle_export_data
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    "! Reads an uploaded CSV batch and writes its records into the model.
    METHODS handle_import_data
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    "! Reads the model's comment table, filtered by dimension selections.
    METHODS handle_comments
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    "! Reads an uploaded CSV batch of comments and adds them to the model.
    METHODS handle_import_comments
      IMPORTING io_service TYPE REF TO zcl_bpc_io_service
      RAISING cx_uj_static_check.
    "! Reads and validates the dimension id form field.
    METHODS read_dimension
      RETURNING VALUE(rv_dimension) TYPE uj_dim_name.
    "! Reads and validates the workbook library token ('REPORT' / 'SCHEDULE').
    METHODS read_folder
      RETURNING VALUE(rv_folder) TYPE string.
    METHODS respond
      IMPORTING iv_code TYPE i iv_reason TYPE string iv_json TYPE string
                iv_allow TYPE string OPTIONAL.
    METHODS respond_error
      IMPORTING iv_code TYPE i iv_reason TYPE string iv_message TYPE string
                iv_allow TYPE string OPTIONAL.
    "! JSON string literal, without the padding of fixed length fields.
    METHODS quote
      IMPORTING iv_value TYPE clike
      RETURNING VALUE(rv_json) TYPE string.
ENDCLASS.

CLASS zcl_bpc_io_http IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    mo_server = server.
    server->response->set_content_type( 'application/json; charset=utf-8' ).
    server->response->set_header_field( name = 'Cache-Control' value = 'no-store' ).
    server->response->set_header_field( name = 'X-Content-Type-Options' value = 'nosniff' ).

    DATA(lv_path) = server->request->get_header_field( '~path_info' ).
    REPLACE REGEX '/$' IN lv_path WITH ''.
    TRY.
        DATA(lo_service) = NEW zcl_bpc_io_service( ).
        CASE lv_path.
          WHEN c_resource-license_audit.
            IF require_method( c_method-get ).
              handle_license_audit( ).
            ENDIF.
          WHEN c_resource-environments.
            IF require_method( c_method-get ).
              handle_environments( lo_service ).
            ENDIF.
          WHEN c_resource-models.
            IF require_method( c_method-get ).
              handle_models( lo_service ).
            ENDIF.
          WHEN c_resource-scripts.
            IF require_method( c_method-get ).
              handle_scripts( lo_service ).
            ENDIF.
          WHEN c_resource-script.
            IF require_method( c_method-get ).
              handle_script( lo_service ).
            ENDIF.
          WHEN c_resource-packages.
            IF require_method( c_method-get ).
              handle_packages( lo_service ).
            ENDIF.
          WHEN c_resource-package.
            IF require_method( c_method-get ).
              handle_package( lo_service ).
            ENDIF.
          WHEN c_resource-packages_import.
            IF require_method( c_method-post ).
              handle_import_packages( lo_service ).
            ENDIF.
          WHEN c_resource-import.
            IF require_method( c_method-post ).
              handle_import( lo_service ).
            ENDIF.
          WHEN c_resource-transformations.
            IF require_method( c_method-get ).
              handle_transformations( lo_service ).
            ENDIF.
          WHEN c_resource-transformation.
            IF require_method( c_method-get ).
              handle_transformation( lo_service ).
            ENDIF.
          WHEN c_resource-transforms_import.
            IF require_method( c_method-post ).
              handle_import_transformations( lo_service ).
            ENDIF.
          WHEN c_resource-conversions.
            IF require_method( c_method-get ).
              handle_conversions( lo_service ).
            ENDIF.
          WHEN c_resource-conversion.
            IF require_method( c_method-get ).
              handle_conversion( lo_service ).
            ENDIF.
          WHEN c_resource-convers_import.
            IF require_method( c_method-post ).
              handle_import_conversions( lo_service ).
            ENDIF.
          WHEN c_resource-workbooks.
            IF require_method( c_method-get ).
              handle_workbooks( lo_service ).
            ENDIF.
          WHEN c_resource-workbook.
            IF require_method( c_method-get ).
              handle_workbook( lo_service ).
            ENDIF.
          WHEN c_resource-workbooks_import.
            IF require_method( c_method-post ).
              handle_import_workbooks( lo_service ).
            ENDIF.
          WHEN c_resource-dimensions.
            IF require_method( c_method-get ).
              handle_dimensions( lo_service ).
            ENDIF.
          WHEN c_resource-members.
            IF require_method( c_method-get ).
              handle_members( lo_service ).
            ENDIF.
          WHEN c_resource-data_export.
            IF require_method( c_method-post ).
              handle_export_data( lo_service ).
            ENDIF.
          WHEN c_resource-data_import.
            IF require_method( c_method-post ).
              handle_import_data( lo_service ).
            ENDIF.
          WHEN c_resource-data_comments.
            IF require_method( c_method-get ).
              handle_comments( lo_service ).
            ENDIF.
          WHEN c_resource-comments_import.
            IF require_method( c_method-post ).
              handle_import_comments( lo_service ).
            ENDIF.
          WHEN OTHERS.
            respond_error( iv_code = 404 iv_reason = 'Not Found'
                           iv_message = 'Unknown resource' ).
        ENDCASE.
      CATCH cx_uj_input_error INTO DATA(lx_input).
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = lx_input->get_text( ) ).
      CATCH cx_uj_no_auth.
        respond_error( iv_code = 403 iv_reason = 'Forbidden'
                       iv_message = 'BPC access denied' ).
      CATCH cx_uj_static_check.
        respond_error(
          iv_code = 500 iv_reason = 'Internal Server Error'
          iv_message = COND #( WHEN lv_path = c_resource-import
                               THEN 'Cannot write BPC Logic Scripts'
                               WHEN lv_path = c_resource-packages_import
                               THEN 'Cannot write BPC Data Manager Packages'
                               WHEN lv_path = c_resource-transforms_import
                               THEN 'Cannot write BPC transformation files'
                               WHEN lv_path = c_resource-convers_import
                               THEN 'Cannot write BPC conversion files'
                               WHEN lv_path = c_resource-workbooks_import
                               THEN 'Cannot write BPC workbooks'
                               WHEN lv_path = c_resource-data_export
                               THEN 'Cannot read BPC data'
                               WHEN lv_path = c_resource-data_import
                               THEN 'Cannot write BPC data'
                               WHEN lv_path = c_resource-data_comments
                               THEN 'Cannot read BPC comments'
                               WHEN lv_path = c_resource-comments_import
                               THEN 'Cannot write BPC comments'
                               ELSE 'Cannot load BPC metadata' ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD handle_license_audit.
    DATA(lv_start_text) = mo_server->request->get_form_field( 'startDate' ).
    IF lv_start_text IS NOT INITIAL AND
       ( strlen( lv_start_text ) <> 8 OR NOT lv_start_text CO '0123456789' ).
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
        iv_message = 'Start date must be YYYYMMDD' ).
      RETURN.
    ENDIF.
    DATA lv_start TYPE dats.
    lv_start = lv_start_text.
    IF lv_start_text IS NOT INITIAL.
      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING date = lv_start
        EXCEPTIONS plausibility_check_failed = 1 OTHERS = 2.
      IF sy-subrc <> 0 OR lv_start > sy-datum OR lv_start IS INITIAL.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
          iv_message = 'Choose a valid start date no later than today' ).
        RETURN.
      ENDIF.
    ENDIF.
    DATA(ls_audit) = zcl_bpc_io_audit=>analyse( lv_start ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    lv_json = `{"client":` && quote( ls_audit-client ) &&
      `,"startDate":` && quote( ls_audit-start_date ) && `,"endDate":` && quote( ls_audit-end_date ) &&
      `,"professional":` && |{ ls_audit-professional }| && `,"standard":` && |{ ls_audit-standard }| &&
      `,"inactiveProfessional":` && |{ ls_audit-inactive_professional }| &&
      `,"inactiveStandard":` && |{ ls_audit-inactive_standard }| && `,"users":[`.
    LOOP AT ls_audit-users INTO DATA(ls_user).
      lv_json = lv_json && lv_separator && `{"userId":` && quote( ls_user-user_id ) &&
        `,"license":` && quote( ls_user-license ) && `,"accountStatus":` && quote( ls_user-account_status ) &&
        `,"source":` && quote( ls_user-source ) && `,"activity":` && quote( ls_user-activity ) &&
        `,"activityDate":` && quote( ls_user-activity_date ) &&
        `,"activityTime":` && quote( |{ ls_user-activity_time NUMBER = RAW }| ) &&
        `,"environment":` && quote( ls_user-environment ) &&
        `,"lastAccessDate":` && quote( ls_user-last_access_date ) &&
        `,"lastAccessTime":` && quote( |{ ls_user-last_access_time NUMBER = RAW }| ) && `}`.
      lv_separator = ','.
    ENDLOOP.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  ENDMETHOD.

  METHOD handle_environments.
    DATA(lt_environments) = io_service->get_environments( ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    lv_json = `{"environments":[`.
    LOOP AT lt_environments INTO DATA(ls_environment).
      lv_json = lv_json && lv_separator && `{"id":` && quote( ls_environment-id ) && `}`.
      lv_separator = ','.
    ENDLOOP.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  ENDMETHOD.

  METHOD handle_models.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lt_models) = io_service->get_models( lv_environment_id ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    lv_json = `{"models":[`.
    LOOP AT lt_models INTO DATA(ls_model).
      lv_json = lv_json && lv_separator && `{"id":` && quote( ls_model-id ) && `}`.
      lv_separator = ','.
    ENDLOOP.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  ENDMETHOD.

  METHOD handle_scripts.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lt_scripts) = io_service->get_scripts(
      iv_environment = lv_environment_id iv_model = lv_model_id ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    lv_json = `{"scripts":[`.
    LOOP AT lt_scripts INTO DATA(ls_script).
      lv_json = lv_json && lv_separator && `{"name":` && quote( ls_script-name ) && `}`.
      lv_separator = ','.
    ENDLOOP.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  ENDMETHOD.

  METHOD handle_script.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_script_name) = read_script_name( ).
    IF lv_script_name IS INITIAL.
      RETURN.
    ENDIF.
    DATA(ls_content) = io_service->get_script(
      iv_environment = lv_environment_id iv_model = lv_model_id iv_name = lv_script_name ).
    IF ls_content-name IS INITIAL.
      respond_error( iv_code = 404 iv_reason = 'Not Found'
                     iv_message = 'Script not found' ).
      RETURN.
    ENDIF.
    respond(
      iv_code = 200 iv_reason = 'OK'
      iv_json = `{"name":` && quote( ls_content-name ) &&
        `,"content":"` && cl_http_utility=>encode_x_base64( ls_content-content ) &&
        `","byteLength":` && |{ xstrlen( ls_content-content ) }| && `}` ).
  ENDMETHOD.

  METHOD handle_import.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_count) = mo_server->request->get_form_field( 'count' ).
    IF lv_count IS INITIAL OR strlen( lv_count ) > 4 OR NOT lv_count CO '0123456789'.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid number of scripts is required' ).
      RETURN.
    ENDIF.
    DATA lv_number TYPE i.
    lv_number = lv_count.
    IF lv_number > c_max_scripts.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = |At most { c_max_scripts } scripts can be imported at once| ).
      RETURN.
    ENDIF.
    DATA: ls_import TYPE zcl_bpc_io_service=>ty_import,
          lt_imports TYPE zcl_bpc_io_service=>ty_imports,
          lv_index TYPE i,
          lv_name TYPE string,
          lv_base64 TYPE string,
          lv_total TYPE i.
    DO lv_number TIMES.
      lv_index = sy-index.
      lv_name = mo_server->request->get_form_field( |name{ lv_index }| ).
      lv_base64 = mo_server->request->get_form_field( |content{ lv_index }| ).
      IF lv_name IS INITIAL.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = 'A valid script name is required' ).
        RETURN.
      ENDIF.
      CLEAR ls_import.
      ls_import-name = lv_name.
      TRY.
          ls_import-content = cl_http_utility=>decode_x_base64( lv_base64 ).
        CATCH cx_root.
          respond_error( iv_code = 400 iv_reason = 'Bad Request'
                         iv_message = |Invalid Base64 content for { lv_name }| ).
          RETURN.
      ENDTRY.
      IF cl_http_utility=>encode_x_base64( ls_import-content ) <> lv_base64.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = |Invalid Base64 content for { lv_name }| ).
        RETURN.
      ENDIF.
      lv_total = lv_total + xstrlen( ls_import-content ).
      IF lv_total > c_max_content.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = 'The import exceeds 20 MB of script content' ).
        RETURN.
      ENDIF.
      APPEND ls_import TO lt_imports.
    ENDDO.
    DATA(lv_replace) = mo_server->request->get_form_field( 'replace' ).
    DATA(lt_results) = io_service->import_scripts(
      iv_environment = lv_environment_id iv_model = lv_model_id it_scripts = lt_imports
      iv_replace = boolc( lv_replace IS NOT INITIAL ) ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    DATA: lv_changed TYPE i, lv_skipped TYPE i, lv_failed TYPE i.
    LOOP AT lt_results INTO DATA(ls_result).
      lv_json = lv_json && lv_separator && `{"name":` && quote( ls_result-name ) &&
        `,"action":` && quote( ls_result-action ) &&
        `,"message":` && quote( ls_result-message ) && `}`.
      lv_separator = ','.
      CASE ls_result-action.
        WHEN zcl_bpc_io_service=>c_action-written OR zcl_bpc_io_service=>c_action-replaced.
          lv_changed = lv_changed + 1.
        WHEN zcl_bpc_io_service=>c_action-failed.
          lv_failed = lv_failed + 1.
        WHEN OTHERS.
          lv_skipped = lv_skipped + 1.
      ENDCASE.
    ENDLOOP.
    respond(
      iv_code = 200 iv_reason = 'OK'
      iv_json = `{"results":[` && lv_json && `],"changed":` && |{ lv_changed }| &&
        `,"skipped":` && |{ lv_skipped }| && `,"failed":` && |{ lv_failed }| && `}` ).
  ENDMETHOD.

  METHOD handle_packages.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lt_packages) = io_service->get_packages(
      iv_environment = lv_environment_id iv_model = lv_model_id ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    lv_json = `{"packages":[`.
    LOOP AT lt_packages INTO DATA(ls_package).
      lv_json = lv_json && lv_separator && `{"group":` && quote( ls_package-group ) &&
        `,"id":` && quote( ls_package-id ) &&
        `,"description":` && quote( ls_package-descr ) &&
        `,"type":` && quote( ls_package-type ) &&
        `,"userGroup":` && quote( ls_package-user_group ) &&
        `,"chain":` && quote( ls_package-chain ) &&
        `,"team":` && quote( ls_package-team ) && `}`.
      lv_separator = ','.
    ENDLOOP.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  ENDMETHOD.

  METHOD handle_package.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_group) = read_group( ).
    IF lv_group IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_package) = read_package( ).
    IF lv_package IS INITIAL.
      RETURN.
    ENDIF.
    DATA(ls_package) = io_service->get_package(
      iv_environment = lv_environment_id iv_model = lv_model_id
      iv_group = lv_group iv_package = lv_package ).
    respond(
      iv_code = 200 iv_reason = 'OK'
      iv_json = `{"group":` && quote( ls_package-group ) &&
        `,"id":` && quote( ls_package-id ) &&
        `,"description":` && quote( ls_package-descr ) &&
        `,"type":` && quote( ls_package-type ) &&
        `,"userGroup":` && quote( ls_package-user_group ) &&
        `,"chain":` && quote( ls_package-chain ) &&
        `,"team":` && quote( ls_package-team ) &&
        `,"script":` && quote( ls_package-script ) && `}` ).
  ENDMETHOD.

  METHOD handle_import_packages.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_count) = mo_server->request->get_form_field( 'count' ).
    IF lv_count IS INITIAL OR strlen( lv_count ) > 4 OR NOT lv_count CO '0123456789'.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid number of packages is required' ).
      RETURN.
    ENDIF.
    DATA lv_number TYPE i.
    lv_number = lv_count.
    IF lv_number > c_max_packages.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = |At most { c_max_packages } packages can be imported at once| ).
      RETURN.
    ENDIF.
    DATA: ls_package TYPE zcl_bpc_io_service=>ty_package_import,
          lt_packages TYPE zcl_bpc_io_service=>ty_package_imports,
          lv_index TYPE i.
    DO lv_number TIMES.
      lv_index = sy-index.
      CLEAR ls_package.
      ls_package-group = mo_server->request->get_form_field( |group{ lv_index }| ).
      ls_package-id = mo_server->request->get_form_field( |id{ lv_index }| ).
      IF ls_package-group IS INITIAL OR ls_package-id IS INITIAL.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = 'A valid group and id are required' ).
        RETURN.
      ENDIF.
      ls_package-descr = mo_server->request->get_form_field( |description{ lv_index }| ).
      ls_package-type = mo_server->request->get_form_field( |type{ lv_index }| ).
      ls_package-user_group = mo_server->request->get_form_field( |userGroup{ lv_index }| ).
      ls_package-chain = mo_server->request->get_form_field( |chain{ lv_index }| ).
      ls_package-team = mo_server->request->get_form_field( |team{ lv_index }| ).
      ls_package-script = mo_server->request->get_form_field( |script{ lv_index }| ).
      IF strlen( ls_package-script ) > c_max_package_content.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = |Package { ls_package-id } exceeds the script size limit| ).
        RETURN.
      ENDIF.
      APPEND ls_package TO lt_packages.
    ENDDO.
    DATA(lv_replace) = mo_server->request->get_form_field( 'replace' ).
    DATA(lt_results) = io_service->import_packages(
      iv_environment = lv_environment_id iv_model = lv_model_id it_packages = lt_packages
      iv_replace = boolc( lv_replace IS NOT INITIAL ) ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    DATA: lv_changed TYPE i, lv_skipped TYPE i, lv_failed TYPE i.
    LOOP AT lt_results INTO DATA(ls_result).
      lv_json = lv_json && lv_separator && `{"group":` && quote( ls_result-group ) &&
        `,"id":` && quote( ls_result-id ) &&
        `,"action":` && quote( ls_result-action ) &&
        `,"message":` && quote( ls_result-message ) && `}`.
      lv_separator = ','.
      CASE ls_result-action.
        WHEN zcl_bpc_io_service=>c_action-written OR zcl_bpc_io_service=>c_action-replaced.
          lv_changed = lv_changed + 1.
        WHEN zcl_bpc_io_service=>c_action-failed.
          lv_failed = lv_failed + 1.
        WHEN OTHERS.
          lv_skipped = lv_skipped + 1.
      ENDCASE.
    ENDLOOP.
    respond(
      iv_code = 200 iv_reason = 'OK'
      iv_json = `{"results":[` && lv_json && `],"changed":` && |{ lv_changed }| &&
        `,"skipped":` && |{ lv_skipped }| && `,"failed":` && |{ lv_failed }| && `}` ).
  ENDMETHOD.

  METHOD handle_transformations.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lt_files) = io_service->get_transformations(
      iv_environment = lv_environment_id iv_model = lv_model_id ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    lv_json = `{"transformations":[`.
    LOOP AT lt_files INTO DATA(ls_file).
      lv_json = lv_json && lv_separator && `{"name":` && quote( ls_file-name ) && `}`.
      lv_separator = ','.
    ENDLOOP.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  ENDMETHOD.

  METHOD handle_transformation.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_name) = read_dm_name( ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.
    DATA(ls_file) = io_service->get_transformation(
      iv_environment = lv_environment_id iv_model = lv_model_id iv_name = lv_name ).
    IF ls_file-name IS INITIAL.
      respond_error( iv_code = 404 iv_reason = 'Not Found'
                     iv_message = 'Transformation file not found' ).
      RETURN.
    ENDIF.
    respond(
      iv_code = 200 iv_reason = 'OK'
      iv_json = `{"name":` && quote( ls_file-name ) &&
        `,"content":"` && cl_http_utility=>encode_x_base64( ls_file-content ) &&
        `","byteLength":` && |{ xstrlen( ls_file-content ) }| &&
        `,"workbook":"` && cl_http_utility=>encode_x_base64( ls_file-workbook ) &&
        `","workbookByteLength":` && |{ xstrlen( ls_file-workbook ) }| && `}` ).
  ENDMETHOD.

  METHOD handle_conversions.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lt_files) = io_service->get_conversions(
      iv_environment = lv_environment_id iv_model = lv_model_id ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    lv_json = `{"conversions":[`.
    LOOP AT lt_files INTO DATA(ls_file).
      lv_json = lv_json && lv_separator && `{"name":` && quote( ls_file-name ) && `}`.
      lv_separator = ','.
    ENDLOOP.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  ENDMETHOD.

  METHOD handle_conversion.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_name) = read_dm_name( ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.
    DATA(ls_file) = io_service->get_conversion(
      iv_environment = lv_environment_id iv_model = lv_model_id iv_name = lv_name ).
    IF ls_file-name IS INITIAL.
      respond_error( iv_code = 404 iv_reason = 'Not Found'
                     iv_message = 'Conversion file not found' ).
      RETURN.
    ENDIF.
    respond(
      iv_code = 200 iv_reason = 'OK'
      iv_json = `{"name":` && quote( ls_file-name ) &&
        `,"content":"` && cl_http_utility=>encode_x_base64( ls_file-content ) &&
        `","byteLength":` && |{ xstrlen( ls_file-content ) }| &&
        `,"workbook":"` && cl_http_utility=>encode_x_base64( ls_file-workbook ) &&
        `","workbookByteLength":` && |{ xstrlen( ls_file-workbook ) }| && `}` ).
  ENDMETHOD.

  METHOD handle_import_transformations.
    handle_import_dm( io_service = io_service iv_ext = '.TDM' ).
  ENDMETHOD.

  METHOD handle_import_conversions.
    handle_import_dm( io_service = io_service iv_ext = '.CDM' ).
  ENDMETHOD.

  METHOD handle_import_dm.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_count) = mo_server->request->get_form_field( 'count' ).
    IF lv_count IS INITIAL OR strlen( lv_count ) > 4 OR NOT lv_count CO '0123456789'.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid number of files is required' ).
      RETURN.
    ENDIF.
    DATA lv_number TYPE i.
    lv_number = lv_count.
    IF lv_number > c_max_dm_files.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = |At most { c_max_dm_files } files can be imported at once| ).
      RETURN.
    ENDIF.
    DATA: ls_file TYPE zcl_bpc_io_service=>ty_dm_import,
          lt_files TYPE zcl_bpc_io_service=>ty_dm_imports,
          lv_index TYPE i,
          lv_name TYPE string,
          lv_base64 TYPE string,
          lv_workbook64 TYPE string,
          lv_total TYPE i.
    DO lv_number TIMES.
      lv_index = sy-index.
      lv_name = mo_server->request->get_form_field( |name{ lv_index }| ).
      lv_base64 = mo_server->request->get_form_field( |content{ lv_index }| ).
      lv_workbook64 = mo_server->request->get_form_field( |workbook{ lv_index }| ).
      IF lv_name IS INITIAL.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = 'A valid file name is required' ).
        RETURN.
      ENDIF.
      CLEAR ls_file.
      ls_file-name = lv_name.
      TRY.
          ls_file-content = cl_http_utility=>decode_x_base64( lv_base64 ).
        CATCH cx_root.
          respond_error( iv_code = 400 iv_reason = 'Bad Request'
                         iv_message = |Invalid Base64 content for { lv_name }| ).
          RETURN.
      ENDTRY.
      IF lv_workbook64 IS NOT INITIAL.
        TRY.
            ls_file-workbook = cl_http_utility=>decode_x_base64( lv_workbook64 ).
          CATCH cx_root.
            respond_error( iv_code = 400 iv_reason = 'Bad Request'
                           iv_message = |Invalid Base64 workbook for { lv_name }| ).
            RETURN.
        ENDTRY.
      ENDIF.
      lv_total = lv_total + xstrlen( ls_file-content ) + xstrlen( ls_file-workbook ).
      IF lv_total > c_max_dm_content.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = 'The import exceeds 20 MB of file content' ).
        RETURN.
      ENDIF.
      APPEND ls_file TO lt_files.
    ENDDO.
    DATA(lv_replace) = mo_server->request->get_form_field( 'replace' ).
    DATA lt_results TYPE zcl_bpc_io_service=>ty_dm_imports.
    IF iv_ext = '.TDM'.
      lt_results = io_service->import_transformations(
        iv_environment = lv_environment_id iv_model = lv_model_id
        it_files = lt_files iv_replace = boolc( lv_replace IS NOT INITIAL ) ).
    ELSE.
      lt_results = io_service->import_conversions(
        iv_environment = lv_environment_id iv_model = lv_model_id
        it_files = lt_files iv_replace = boolc( lv_replace IS NOT INITIAL ) ).
    ENDIF.
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    DATA: lv_changed TYPE i, lv_skipped TYPE i, lv_failed TYPE i.
    LOOP AT lt_results INTO DATA(ls_result).
      lv_json = lv_json && lv_separator && `{"name":` && quote( ls_result-name ) &&
        `,"action":` && quote( ls_result-action ) &&
        `,"message":` && quote( ls_result-message ) && `}`.
      lv_separator = ','.
      CASE ls_result-action.
        WHEN zcl_bpc_io_service=>c_action-written OR zcl_bpc_io_service=>c_action-replaced.
          lv_changed = lv_changed + 1.
        WHEN zcl_bpc_io_service=>c_action-failed.
          lv_failed = lv_failed + 1.
        WHEN OTHERS.
          lv_skipped = lv_skipped + 1.
      ENDCASE.
    ENDLOOP.
    respond(
      iv_code = 200 iv_reason = 'OK'
      iv_json = `{"results":[` && lv_json && `],"changed":` && |{ lv_changed }| &&
        `,"skipped":` && |{ lv_skipped }| && `,"failed":` && |{ lv_failed }| && `}` ).
  ENDMETHOD.

  METHOD handle_workbooks.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lt_files) = io_service->get_workbooks(
      iv_environment = lv_environment_id iv_model = lv_model_id ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    lv_json = `{"workbooks":[`.
    LOOP AT lt_files INTO DATA(ls_file).
      lv_json = lv_json && lv_separator && `{"name":` && quote( ls_file-name ) &&
        `,"folder":` && quote( ls_file-folder ) && `}`.
      lv_separator = ','.
    ENDLOOP.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  ENDMETHOD.

  METHOD handle_workbook.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_folder) = read_folder( ).
    IF lv_folder IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_name) = read_dm_name( ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.
    DATA(ls_file) = io_service->get_workbook(
      iv_environment = lv_environment_id iv_model = lv_model_id
      iv_folder = lv_folder iv_name = lv_name ).
    IF ls_file-name IS INITIAL.
      respond_error( iv_code = 404 iv_reason = 'Not Found'
                     iv_message = 'Workbook not found' ).
      RETURN.
    ENDIF.
    respond(
      iv_code = 200 iv_reason = 'OK'
      iv_json = `{"name":` && quote( ls_file-name ) &&
        `,"folder":` && quote( ls_file-folder ) &&
        `,"content":"` && cl_http_utility=>encode_x_base64( ls_file-content ) &&
        `","byteLength":` && |{ xstrlen( ls_file-content ) }| && `}` ).
  ENDMETHOD.

  METHOD handle_import_workbooks.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_count) = mo_server->request->get_form_field( 'count' ).
    IF lv_count IS INITIAL OR strlen( lv_count ) > 4 OR NOT lv_count CO '0123456789'.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid number of workbooks is required' ).
      RETURN.
    ENDIF.
    DATA lv_number TYPE i.
    lv_number = lv_count.
    IF lv_number > c_max_workbooks.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = |At most { c_max_workbooks } workbooks can be imported at once| ).
      RETURN.
    ENDIF.
    DATA: ls_file TYPE zcl_bpc_io_service=>ty_workbook_import,
          lt_files TYPE zcl_bpc_io_service=>ty_workbook_imports,
          lv_index TYPE i,
          lv_name TYPE string,
          lv_folder TYPE string,
          lv_base64 TYPE string,
          lv_total TYPE i.
    DO lv_number TIMES.
      lv_index = sy-index.
      lv_name = mo_server->request->get_form_field( |name{ lv_index }| ).
      lv_folder = to_upper( mo_server->request->get_form_field( |folder{ lv_index }| ) ).
      lv_base64 = mo_server->request->get_form_field( |content{ lv_index }| ).
      IF lv_name IS INITIAL.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = 'A valid workbook name is required' ).
        RETURN.
      ENDIF.
      IF lv_folder <> 'REPORT' AND lv_folder <> 'SCHEDULE'.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = |A valid library (REPORT or SCHEDULE) is required for { lv_name }| ).
        RETURN.
      ENDIF.
      CLEAR ls_file.
      ls_file-name = lv_name.
      ls_file-folder = lv_folder.
      TRY.
          ls_file-content = cl_http_utility=>decode_x_base64( lv_base64 ).
        CATCH cx_root.
          respond_error( iv_code = 400 iv_reason = 'Bad Request'
                         iv_message = |Invalid Base64 content for { lv_name }| ).
          RETURN.
      ENDTRY.
      IF cl_http_utility=>encode_x_base64( ls_file-content ) <> lv_base64.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = |Invalid Base64 content for { lv_name }| ).
        RETURN.
      ENDIF.
      lv_total = lv_total + xstrlen( ls_file-content ).
      IF lv_total > c_max_workbook_content.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = 'The import exceeds 50 MB of workbook content' ).
        RETURN.
      ENDIF.
      APPEND ls_file TO lt_files.
    ENDDO.
    DATA(lv_replace) = mo_server->request->get_form_field( 'replace' ).
    DATA(lt_results) = io_service->import_workbooks(
      iv_environment = lv_environment_id iv_model = lv_model_id it_files = lt_files
      iv_replace = boolc( lv_replace IS NOT INITIAL ) ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    DATA: lv_changed TYPE i, lv_skipped TYPE i, lv_failed TYPE i.
    LOOP AT lt_results INTO DATA(ls_result).
      lv_json = lv_json && lv_separator && `{"name":` && quote( ls_result-name ) &&
        `,"folder":` && quote( ls_result-folder ) &&
        `,"action":` && quote( ls_result-action ) &&
        `,"message":` && quote( ls_result-message ) && `}`.
      lv_separator = ','.
      CASE ls_result-action.
        WHEN zcl_bpc_io_service=>c_action-written OR zcl_bpc_io_service=>c_action-replaced.
          lv_changed = lv_changed + 1.
        WHEN zcl_bpc_io_service=>c_action-failed.
          lv_failed = lv_failed + 1.
        WHEN OTHERS.
          lv_skipped = lv_skipped + 1.
      ENDCASE.
    ENDLOOP.
    respond(
      iv_code = 200 iv_reason = 'OK'
      iv_json = `{"results":[` && lv_json && `],"changed":` && |{ lv_changed }| &&
        `,"skipped":` && |{ lv_skipped }| && `,"failed":` && |{ lv_failed }| && `}` ).
  ENDMETHOD.

  METHOD read_folder.
    DATA(lv_folder) = to_upper( mo_server->request->get_form_field( 'folder' ) ).
    IF lv_folder <> 'REPORT' AND lv_folder <> 'SCHEDULE'.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid library (REPORT or SCHEDULE) is required' ).
      RETURN.
    ENDIF.
    rv_folder = lv_folder.
  ENDMETHOD.

  METHOD read_dm_name.
    DATA(lv_name) = mo_server->request->get_form_field( 'name' ).
    DATA lv_dm_name TYPE uj_docname.
    DESCRIBE FIELD lv_dm_name LENGTH DATA(lv_length) IN CHARACTER MODE.
    IF lv_name IS INITIAL OR strlen( lv_name ) > lv_length.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid file name is required' ).
      RETURN.
    ENDIF.
    rv_name = lv_name.
  ENDMETHOD.

  METHOD read_environment.
    DATA(lv_environment) = mo_server->request->get_form_field( 'environment' ).
    DATA lv_environment_id TYPE uj_appset_id.
    DESCRIBE FIELD lv_environment_id LENGTH DATA(lv_length) IN CHARACTER MODE.
    IF lv_environment IS INITIAL OR strlen( lv_environment ) > lv_length.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid environment is required' ).
      RETURN.
    ENDIF.
    rv_environment = lv_environment.
  ENDMETHOD.

  METHOD read_model.
    DATA(lv_model) = mo_server->request->get_form_field( 'model' ).
    DATA lv_model_id TYPE uj_appl_id.
    DESCRIBE FIELD lv_model_id LENGTH DATA(lv_length) IN CHARACTER MODE.
    IF lv_model IS INITIAL OR strlen( lv_model ) > lv_length.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid model is required' ).
      RETURN.
    ENDIF.
    rv_model = lv_model.
  ENDMETHOD.

  METHOD read_script_name.
    DATA(lv_name) = mo_server->request->get_form_field( 'name' ).
    DATA lv_script_name TYPE uj_docname.
    DESCRIBE FIELD lv_script_name LENGTH DATA(lv_length) IN CHARACTER MODE.
    IF lv_name IS INITIAL OR strlen( lv_name ) > lv_length.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid script name is required' ).
      RETURN.
    ENDIF.
    rv_name = lv_name.
  ENDMETHOD.

  METHOD read_group.
    DATA(lv_group) = mo_server->request->get_form_field( 'group' ).
    DATA lv_group_id TYPE uj_pack_grp_id.
    DESCRIBE FIELD lv_group_id LENGTH DATA(lv_length) IN CHARACTER MODE.
    IF lv_group IS INITIAL OR strlen( lv_group ) > lv_length.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid group is required' ).
      RETURN.
    ENDIF.
    rv_group = lv_group.
  ENDMETHOD.

  METHOD read_package.
    DATA(lv_package) = mo_server->request->get_form_field( 'id' ).
    DATA lv_package_id TYPE uj_package_id.
    DESCRIBE FIELD lv_package_id LENGTH DATA(lv_length) IN CHARACTER MODE.
    IF lv_package IS INITIAL OR strlen( lv_package ) > lv_length.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid package id is required' ).
      RETURN.
    ENDIF.
    rv_package = lv_package.
  ENDMETHOD.

  METHOD require_method.
    IF mo_server->request->get_method( ) = iv_method.
      rv_allowed = abap_true.
      RETURN.
    ENDIF.
    respond_error( iv_code = 405 iv_reason = 'Method Not Allowed'
                   iv_message = |Only { iv_method } is supported| iv_allow = iv_method ).
  ENDMETHOD.

  METHOD respond.
    IF iv_allow IS NOT INITIAL.
      mo_server->response->set_header_field( name = 'Allow' value = iv_allow ).
    ENDIF.
    mo_server->response->set_status( code = iv_code reason = iv_reason ).
    mo_server->response->set_cdata( iv_json ).
  ENDMETHOD.

  METHOD respond_error.
    respond( iv_code = iv_code iv_reason = iv_reason iv_allow = iv_allow
             iv_json = `{"error":{"message":` && quote( iv_message ) && `}}` ).
  ENDMETHOD.

  METHOD quote.
    DATA(lv_value) = |{ iv_value }|.
    rv_json = `"` && escape( val = lv_value format = cl_abap_format=>e_json_string ) && `"`.
  ENDMETHOD.
  METHOD handle_dimensions.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lt_dimensions) = io_service->get_dimensions(
      iv_environment = lv_environment_id iv_model = lv_model_id ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    lv_json = `{"dimensions":[`.
    LOOP AT lt_dimensions INTO DATA(ls_dimension).
      lv_json = lv_json && lv_separator && `{"id":` && quote( ls_dimension-id ) &&
        `,"description":` && quote( ls_dimension-description ) &&
        `,"type":` && quote( ls_dimension-dim_type ) && `}`.
      lv_separator = ','.
    ENDLOOP.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  ENDMETHOD.

  METHOD handle_members.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_dimension_id) = read_dimension( ).
    IF lv_dimension_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lt_members) = io_service->get_dimension_members(
      iv_environment = lv_environment_id iv_model = lv_model_id
      iv_dimension = lv_dimension_id ).
    DATA lv_json TYPE string.
    DATA lv_separator TYPE string.
    lv_json = `{"members":[`.
    LOOP AT lt_members INTO DATA(ls_member).
      DATA lv_props TYPE string.
      DATA lv_psep TYPE string.
      CLEAR lv_props.
      CLEAR lv_psep.
      LOOP AT ls_member-properties INTO DATA(ls_prop).
        lv_props = lv_props && lv_psep && quote( ls_prop-id ) && `:` && quote( ls_prop-value ).
        lv_psep = ','.
      ENDLOOP.
      DATA lv_parents TYPE string.
      CLEAR: lv_parents, lv_psep.
      LOOP AT ls_member-parents INTO DATA(ls_parent).
        lv_parents = lv_parents && lv_psep && quote( ls_parent-id ) && `:` && quote( ls_parent-value ).
        lv_psep = ','.
      ENDLOOP.
      lv_json = lv_json && lv_separator && `{"id":` && quote( ls_member-id ) &&
        `,"description":` && quote( ls_member-description ) &&
        `,"properties":{` && lv_props && `}` &&
        `,"parents":{` && lv_parents && `}}`.
      lv_separator = ','.
    ENDLOOP.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  ENDMETHOD.

  METHOD handle_export_data.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_count) = mo_server->request->get_form_field( 'filterCount' ).
    IF lv_count IS NOT INITIAL AND ( strlen( lv_count ) > 4 OR NOT lv_count CO '0123456789' ).
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid filter count is required' ).
      RETURN.
    ENDIF.
    DATA lv_number TYPE i.
    lv_number = lv_count.
    DATA lt_filters TYPE zcl_bpc_io_service=>ty_filters.
    DATA lv_total_members TYPE i.
    DATA lv_index TYPE i.
    DO lv_number TIMES.
      lv_index = sy-index.
      DATA(lv_dim) = to_upper( mo_server->request->get_form_field( |filterDimension{ lv_index }| ) ).
      DATA(lv_members) = mo_server->request->get_form_field( |filterMembers{ lv_index }| ).
      IF lv_dim IS INITIAL.
        CONTINUE.
      ENDIF.
      DATA ls_filter TYPE zcl_bpc_io_service=>ty_filter.
      CLEAR ls_filter.
      ls_filter-dimension = lv_dim.
      SPLIT lv_members AT ',' INTO TABLE DATA(lt_member_ids).
      LOOP AT lt_member_ids INTO DATA(lv_member_id).
        IF lv_member_id IS NOT INITIAL.
          APPEND CONV uj_dim_member( to_upper( lv_member_id ) ) TO ls_filter-members.
          lv_total_members = lv_total_members + 1.
        ENDIF.
      ENDLOOP.
      IF lv_total_members > c_max_filter_members.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = 'The export selects too many filter members' ).
        RETURN.
      ENDIF.
      IF ls_filter-members IS NOT INITIAL.
        APPEND ls_filter TO lt_filters.
      ENDIF.
    ENDDO.
    DATA(lv_preview) = mo_server->request->get_form_field( 'preview' ).
    IF lv_preview = 'X'.
      DATA(ls_preview) = io_service->preview_data(
        iv_environment = lv_environment_id iv_model = lv_model_id it_filters = lt_filters ).
      respond( iv_code = 200 iv_reason = 'OK'
        iv_json = `{"csv":` && quote( ls_preview-csv ) && `,"truncated":` &&
          COND string( WHEN ls_preview-truncated = abap_true THEN 'true' ELSE 'false' ) && `}` ).
      RETURN.
    ENDIF.
    DATA(lv_csv) = io_service->export_data(
      iv_environment = lv_environment_id iv_model = lv_model_id it_filters = lt_filters ).
    respond( iv_code = 200 iv_reason = 'OK'
             iv_json = `{"csv":` && quote( lv_csv ) && `}` ).
  ENDMETHOD.

  METHOD read_dimension.
    DATA(lv_dimension) = to_upper( mo_server->request->get_form_field( 'dimension' ) ).
    DATA lv_dimension_id TYPE uj_dim_name.
    DESCRIBE FIELD lv_dimension_id LENGTH DATA(lv_length) IN CHARACTER MODE.
    IF lv_dimension IS INITIAL OR strlen( lv_dimension ) > lv_length.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid dimension is required' ).
      RETURN.
    ENDIF.
    rv_dimension = lv_dimension.
  ENDMETHOD.


  METHOD handle_import_data.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_csv) = mo_server->request->get_form_field( 'csv' ).
    IF lv_csv IS INITIAL.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'CSV data is required' ).
      RETURN.
    ENDIF.
    IF strlen( lv_csv ) > c_max_import_csv.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'The import exceeds 20 MB of CSV per request' ).
      RETURN.
    ENDIF.
    IF count( val = lv_csv sub = cl_abap_char_utilities=>newline ) > c_max_import_rows.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = |At most { c_max_import_rows } lines can be imported per request| ).
      RETURN.
    ENDIF.
    DATA(ls_result) = io_service->import_data(
      iv_environment = lv_environment_id iv_model = lv_model_id iv_csv = lv_csv ).
    DATA lv_messages TYPE string.
    DATA lv_separator TYPE string.
    LOOP AT ls_result-messages INTO DATA(lv_message).
      lv_messages = lv_messages && lv_separator && quote( lv_message ).
      lv_separator = ','.
    ENDLOOP.
    respond( iv_code = 200 iv_reason = 'OK'
             iv_json = `{"submitted":` && |{ ls_result-submitted }| &&
                       `,"success":` && |{ ls_result-success }| &&
                       `,"failed":` && |{ ls_result-failed }| &&
                       `,"messages":[` && lv_messages && `]}` ).
  ENDMETHOD.


  METHOD handle_import_comments.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_csv) = mo_server->request->get_form_field( 'csv' ).
    IF lv_csv IS INITIAL.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'CSV data is required' ).
      RETURN.
    ENDIF.
    IF strlen( lv_csv ) > c_max_import_csv.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'The import exceeds 20 MB of CSV per request' ).
      RETURN.
    ENDIF.
    IF count( val = lv_csv sub = cl_abap_char_utilities=>newline ) > c_max_import_rows.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = |At most { c_max_import_rows } lines can be imported per request| ).
      RETURN.
    ENDIF.
    DATA(lv_keep_author) = xsdbool( mo_server->request->get_form_field( 'keepAuthor' ) = 'X' ).
    DATA(ls_result) = io_service->import_comments(
      iv_environment = lv_environment_id iv_model = lv_model_id iv_csv = lv_csv
      iv_keep_author = lv_keep_author ).
    DATA lv_messages TYPE string.
    DATA lv_separator TYPE string.
    LOOP AT ls_result-messages INTO DATA(lv_message).
      lv_messages = lv_messages && lv_separator && quote( lv_message ).
      lv_separator = ','.
    ENDLOOP.
    respond( iv_code = 200 iv_reason = 'OK'
             iv_json = `{"submitted":` && |{ ls_result-submitted }| &&
                       `,"success":` && |{ ls_result-success }| &&
                       `,"skipped":` && |{ ls_result-skipped }| &&
                       `,"failed":` && |{ ls_result-failed }| &&
                       `,"messages":[` && lv_messages && `]}` ).
  ENDMETHOD.


  METHOD handle_comments.
    DATA(lv_environment_id) = read_environment( ).
    IF lv_environment_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_model_id) = read_model( ).
    IF lv_model_id IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_count) = mo_server->request->get_form_field( 'filterCount' ).
    DATA lv_number TYPE i.
    IF lv_count IS NOT INITIAL.
      IF strlen( lv_count ) > 4 OR NOT lv_count CO '0123456789'.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = 'A valid filter count is required' ).
        RETURN.
      ENDIF.
      lv_number = lv_count.
    ENDIF.
    DATA lt_filters TYPE zcl_bpc_io_service=>ty_filters.
    DATA lv_index TYPE i.
    DO lv_number TIMES.
      lv_index = sy-index.
      DATA(lv_dim) = to_upper( mo_server->request->get_form_field( |filterDimension{ lv_index }| ) ).
      DATA(lv_members) = mo_server->request->get_form_field( |filterMembers{ lv_index }| ).
      IF lv_dim IS INITIAL.
        CONTINUE.
      ENDIF.
      DATA ls_filter TYPE zcl_bpc_io_service=>ty_filter.
      CLEAR ls_filter.
      ls_filter-dimension = lv_dim.
      SPLIT lv_members AT ',' INTO TABLE DATA(lt_member_ids).
      LOOP AT lt_member_ids INTO DATA(lv_member_id).
        IF lv_member_id IS NOT INITIAL.
          APPEND CONV uj_dim_member( to_upper( lv_member_id ) ) TO ls_filter-members.
        ENDIF.
      ENDLOOP.
      IF ls_filter-members IS NOT INITIAL.
        APPEND ls_filter TO lt_filters.
      ENDIF.
    ENDDO.
    DATA(lv_csv) = io_service->get_comments(
      iv_environment = lv_environment_id iv_model = lv_model_id it_filters = lt_filters ).
    respond( iv_code = 200 iv_reason = 'OK'
             iv_json = `{"csv":` && quote( lv_csv ) && `}` ).
  ENDMETHOD.

ENDCLASS.
