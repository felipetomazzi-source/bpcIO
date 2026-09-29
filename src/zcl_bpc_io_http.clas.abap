class zcl_bpc_io_http definition public final create public.
  public section.
    interfaces if_http_extension.
  private section.
    "! Request and response of the current call.
    data mo_server type ref to if_http_server.
    " Resources served by this handler.
    constants:
      begin of c_resource,
        environments    type string value '/environments',
        models          type string value '/models',
        scripts         type string value '/scripts',
        script          type string value '/script',
        packages        type string value '/packages',
        package         type string value '/package',
        import          type string value '/import',
        packages_import type string value '/packages/import',
      end of c_resource.
    constants:
      begin of c_method,
        get  type string value 'GET',
        post type string value 'POST',
      end of c_method.
    "! One import request accepts at most this many scripts
    constants c_max_scripts type i value 2000 ##NO_TEXT.
    "! and this much decoded script content (20 MB).
    constants c_max_content type i value 20971520 ##NO_TEXT.
    "! One package import accepts at most this many packages
    constants c_max_packages type i value 1000 ##NO_TEXT.
    "! and this much decoded package script content (5 MB).
    constants c_max_package_content type i value 5242880 ##NO_TEXT.

    "! Sends 405 unless the request uses the expected method.
    methods require_method
      importing iv_method type string
      returning value(rv_allowed) type abap_bool.
    "! Read and validate the environment, model or script name of a request.
    "! An invalid value is answered with 400 and returned as initial.
    methods read_environment
      returning value(rv_environment) type uj_appset_id.
    methods read_model
      returning value(rv_model) type uj_appl_id.
    methods read_script_name
      returning value(rv_name) type uj_docname.
    methods read_group
      returning value(rv_group) type uj_pack_grp_id.
    methods read_package
      returning value(rv_package) type uj_package_id.
    methods handle_environments
      importing io_service type ref to zcl_bpc_io_service
      raising cx_uj_static_check.
    methods handle_models
      importing io_service type ref to zcl_bpc_io_service
      raising cx_uj_static_check.
    methods handle_scripts
      importing io_service type ref to zcl_bpc_io_service
      raising cx_uj_static_check.
    methods handle_script
      importing io_service type ref to zcl_bpc_io_service
      raising cx_uj_static_check.
    methods handle_packages
      importing io_service type ref to zcl_bpc_io_service
      raising cx_uj_static_check.
    methods handle_package
      importing io_service type ref to zcl_bpc_io_service
      raising cx_uj_static_check.
    "! Reads the uploaded Data Manager Packages and writes them into the model.
    methods handle_import_packages
      importing io_service type ref to zcl_bpc_io_service
      raising cx_uj_static_check.
    "! Reads the uploaded Logic Scripts and writes them into the given model.
    methods handle_import
      importing io_service type ref to zcl_bpc_io_service
      raising cx_uj_static_check.
    methods respond
      importing iv_code type i iv_reason type string iv_json type string
                iv_allow type string optional.
    methods respond_error
      importing iv_code type i iv_reason type string iv_message type string
                iv_allow type string optional.
    "! JSON string literal, without the padding of fixed length fields.
    methods quote
      importing iv_value type clike
      returning value(rv_json) type string.
endclass.

class zcl_bpc_io_http implementation.
  method if_http_extension~handle_request.
    mo_server = server.
    server->response->set_content_type( 'application/json; charset=utf-8' ).
    server->response->set_header_field( name = 'Cache-Control' value = 'no-store' ).
    server->response->set_header_field( name = 'X-Content-Type-Options' value = 'nosniff' ).

    data(lv_path) = server->request->get_header_field( '~path_info' ).
    replace regex '/$' in lv_path with ''.
    try.
        data(lo_service) = new zcl_bpc_io_service( ).
        case lv_path.
          when c_resource-environments.
            if require_method( c_method-get ).
              handle_environments( lo_service ).
            endif.
          when c_resource-models.
            if require_method( c_method-get ).
              handle_models( lo_service ).
            endif.
          when c_resource-scripts.
            if require_method( c_method-get ).
              handle_scripts( lo_service ).
            endif.
          when c_resource-script.
            if require_method( c_method-get ).
              handle_script( lo_service ).
            endif.
          when c_resource-packages.
            if require_method( c_method-get ).
              handle_packages( lo_service ).
            endif.
          when c_resource-package.
            if require_method( c_method-get ).
              handle_package( lo_service ).
            endif.
          when c_resource-packages_import.
            if require_method( c_method-post ).
              handle_import_packages( lo_service ).
            endif.
          when c_resource-import.
            if require_method( c_method-post ).
              handle_import( lo_service ).
            endif.
          when others.
            respond_error( iv_code = 404 iv_reason = 'Not Found'
                           iv_message = 'Unknown resource' ).
        endcase.
      catch cx_uj_input_error into data(lx_input).
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = lx_input->get_text( ) ).
      catch cx_uj_no_auth.
        respond_error( iv_code = 403 iv_reason = 'Forbidden'
                       iv_message = 'BPC access denied' ).
      catch cx_uj_static_check.
        respond_error(
          iv_code = 500 iv_reason = 'Internal Server Error'
          iv_message = cond #( when lv_path = c_resource-import
                               then 'Cannot write BPC Logic Scripts'
                               when lv_path = c_resource-packages_import
                               then 'Cannot write BPC Data Manager Packages'
                               else 'Cannot load BPC metadata' ) ).
    endtry.
  endmethod.

  method handle_environments.
    data(lt_environments) = io_service->get_environments( ).
    data lv_json type string.
    data lv_separator type string.
    lv_json = `{"environments":[`.
    loop at lt_environments into data(ls_environment).
      lv_json = lv_json && lv_separator && `{"id":` && quote( ls_environment-id ) && `}`.
      lv_separator = ','.
    endloop.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  endmethod.

  method handle_models.
    data(lv_environment_id) = read_environment( ).
    if lv_environment_id is initial.
      return.
    endif.
    data(lt_models) = io_service->get_models( lv_environment_id ).
    data lv_json type string.
    data lv_separator type string.
    lv_json = `{"models":[`.
    loop at lt_models into data(ls_model).
      lv_json = lv_json && lv_separator && `{"id":` && quote( ls_model-id ) && `}`.
      lv_separator = ','.
    endloop.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  endmethod.

  method handle_scripts.
    data(lv_environment_id) = read_environment( ).
    if lv_environment_id is initial.
      return.
    endif.
    data(lv_model_id) = read_model( ).
    if lv_model_id is initial.
      return.
    endif.
    data(lt_scripts) = io_service->get_scripts(
      iv_environment = lv_environment_id iv_model = lv_model_id ).
    data lv_json type string.
    data lv_separator type string.
    lv_json = `{"scripts":[`.
    loop at lt_scripts into data(ls_script).
      lv_json = lv_json && lv_separator && `{"name":` && quote( ls_script-name ) && `}`.
      lv_separator = ','.
    endloop.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  endmethod.

  method handle_script.
    data(lv_environment_id) = read_environment( ).
    if lv_environment_id is initial.
      return.
    endif.
    data(lv_model_id) = read_model( ).
    if lv_model_id is initial.
      return.
    endif.
    data(lv_script_name) = read_script_name( ).
    if lv_script_name is initial.
      return.
    endif.
    data(ls_content) = io_service->get_script(
      iv_environment = lv_environment_id iv_model = lv_model_id iv_name = lv_script_name ).
    if ls_content-name is initial.
      respond_error( iv_code = 404 iv_reason = 'Not Found'
                     iv_message = 'Script not found' ).
      return.
    endif.
    respond(
      iv_code = 200 iv_reason = 'OK'
      iv_json = `{"name":` && quote( ls_content-name ) &&
        `,"content":"` && cl_http_utility=>encode_x_base64( ls_content-content ) &&
        `","byteLength":` && |{ xstrlen( ls_content-content ) }| && `}` ).
  endmethod.

  method handle_import.
    data(lv_environment_id) = read_environment( ).
    if lv_environment_id is initial.
      return.
    endif.
    data(lv_model_id) = read_model( ).
    if lv_model_id is initial.
      return.
    endif.
    data(lv_count) = mo_server->request->get_form_field( 'count' ).
    if lv_count is initial or strlen( lv_count ) > 4 or not lv_count co '0123456789'.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid number of scripts is required' ).
      return.
    endif.
    data lv_number type i.
    lv_number = lv_count.
    if lv_number > c_max_scripts.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = |At most { c_max_scripts } scripts can be imported at once| ).
      return.
    endif.
    data: ls_import type zcl_bpc_io_service=>ty_import,
          lt_imports type zcl_bpc_io_service=>ty_imports,
          lv_index type i,
          lv_name type string,
          lv_base64 type string,
          lv_total type i.
    do lv_number times.
      lv_index = sy-index.
      lv_name = mo_server->request->get_form_field( |name{ lv_index }| ).
      lv_base64 = mo_server->request->get_form_field( |content{ lv_index }| ).
      if lv_name is initial.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = 'A valid script name is required' ).
        return.
      endif.
      clear ls_import.
      ls_import-name = lv_name.
      try.
          ls_import-content = cl_http_utility=>decode_x_base64( lv_base64 ).
        catch cx_root.
          respond_error( iv_code = 400 iv_reason = 'Bad Request'
                         iv_message = |Invalid Base64 content for { lv_name }| ).
          return.
      endtry.
      if cl_http_utility=>encode_x_base64( ls_import-content ) <> lv_base64.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = |Invalid Base64 content for { lv_name }| ).
        return.
      endif.
      lv_total = lv_total + xstrlen( ls_import-content ).
      if lv_total > c_max_content.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = 'The import exceeds 20 MB of script content' ).
        return.
      endif.
      append ls_import to lt_imports.
    enddo.
    data(lv_replace) = mo_server->request->get_form_field( 'replace' ).
    data(lt_results) = io_service->import_scripts(
      iv_environment = lv_environment_id iv_model = lv_model_id it_scripts = lt_imports
      iv_replace = boolc( lv_replace is not initial ) ).
    data lv_json type string.
    data lv_separator type string.
    data: lv_changed type i, lv_skipped type i, lv_failed type i.
    loop at lt_results into data(ls_result).
      lv_json = lv_json && lv_separator && `{"name":` && quote( ls_result-name ) &&
        `,"action":` && quote( ls_result-action ) &&
        `,"message":` && quote( ls_result-message ) && `}`.
      lv_separator = ','.
      case ls_result-action.
        when zcl_bpc_io_service=>c_action-written or zcl_bpc_io_service=>c_action-replaced.
          lv_changed = lv_changed + 1.
        when zcl_bpc_io_service=>c_action-failed.
          lv_failed = lv_failed + 1.
        when others.
          lv_skipped = lv_skipped + 1.
      endcase.
    endloop.
    respond(
      iv_code = 200 iv_reason = 'OK'
      iv_json = `{"results":[` && lv_json && `],"changed":` && |{ lv_changed }| &&
        `,"skipped":` && |{ lv_skipped }| && `,"failed":` && |{ lv_failed }| && `}` ).
  endmethod.

  method handle_packages.
    data(lv_environment_id) = read_environment( ).
    if lv_environment_id is initial.
      return.
    endif.
    data(lv_model_id) = read_model( ).
    if lv_model_id is initial.
      return.
    endif.
    data(lt_packages) = io_service->get_packages(
      iv_environment = lv_environment_id iv_model = lv_model_id ).
    data lv_json type string.
    data lv_separator type string.
    lv_json = `{"packages":[`.
    loop at lt_packages into data(ls_package).
      lv_json = lv_json && lv_separator && `{"group":` && quote( ls_package-group ) &&
        `,"id":` && quote( ls_package-id ) &&
        `,"description":` && quote( ls_package-descr ) &&
        `,"type":` && quote( ls_package-type ) &&
        `,"userGroup":` && quote( ls_package-user_group ) &&
        `,"chain":` && quote( ls_package-chain ) &&
        `,"team":` && quote( ls_package-team ) && `}`.
      lv_separator = ','.
    endloop.
    respond( iv_code = 200 iv_reason = 'OK' iv_json = lv_json && `]}` ).
  endmethod.

  method handle_package.
    data(lv_environment_id) = read_environment( ).
    if lv_environment_id is initial.
      return.
    endif.
    data(lv_model_id) = read_model( ).
    if lv_model_id is initial.
      return.
    endif.
    data(lv_group) = read_group( ).
    if lv_group is initial.
      return.
    endif.
    data(lv_package) = read_package( ).
    if lv_package is initial.
      return.
    endif.
    data(ls_package) = io_service->get_package(
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
  endmethod.

  method handle_import_packages.
    data(lv_environment_id) = read_environment( ).
    if lv_environment_id is initial.
      return.
    endif.
    data(lv_model_id) = read_model( ).
    if lv_model_id is initial.
      return.
    endif.
    data(lv_count) = mo_server->request->get_form_field( 'count' ).
    if lv_count is initial or strlen( lv_count ) > 4 or not lv_count co '0123456789'.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid number of packages is required' ).
      return.
    endif.
    data lv_number type i.
    lv_number = lv_count.
    if lv_number > c_max_packages.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = |At most { c_max_packages } packages can be imported at once| ).
      return.
    endif.
    data: ls_package type zcl_bpc_io_service=>ty_package_import,
          lt_packages type zcl_bpc_io_service=>ty_package_imports,
          lv_index type i.
    do lv_number times.
      lv_index = sy-index.
      clear ls_package.
      ls_package-group = mo_server->request->get_form_field( |group{ lv_index }| ).
      ls_package-id = mo_server->request->get_form_field( |id{ lv_index }| ).
      if ls_package-group is initial or ls_package-id is initial.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = 'A valid group and id are required' ).
        return.
      endif.
      ls_package-descr = mo_server->request->get_form_field( |description{ lv_index }| ).
      ls_package-type = mo_server->request->get_form_field( |type{ lv_index }| ).
      ls_package-user_group = mo_server->request->get_form_field( |userGroup{ lv_index }| ).
      ls_package-chain = mo_server->request->get_form_field( |chain{ lv_index }| ).
      ls_package-team = mo_server->request->get_form_field( |team{ lv_index }| ).
      ls_package-script = mo_server->request->get_form_field( |script{ lv_index }| ).
      if strlen( ls_package-script ) > c_max_package_content.
        respond_error( iv_code = 400 iv_reason = 'Bad Request'
                       iv_message = |Package { ls_package-id } exceeds the script size limit| ).
        return.
      endif.
      append ls_package to lt_packages.
    enddo.
    data(lv_replace) = mo_server->request->get_form_field( 'replace' ).
    data(lt_results) = io_service->import_packages(
      iv_environment = lv_environment_id iv_model = lv_model_id it_packages = lt_packages
      iv_replace = boolc( lv_replace is not initial ) ).
    data lv_json type string.
    data lv_separator type string.
    data: lv_changed type i, lv_skipped type i, lv_failed type i.
    loop at lt_results into data(ls_result).
      lv_json = lv_json && lv_separator && `{"group":` && quote( ls_result-group ) &&
        `,"id":` && quote( ls_result-id ) &&
        `,"action":` && quote( ls_result-action ) &&
        `,"message":` && quote( ls_result-message ) && `}`.
      lv_separator = ','.
      case ls_result-action.
        when zcl_bpc_io_service=>c_action-written or zcl_bpc_io_service=>c_action-replaced.
          lv_changed = lv_changed + 1.
        when zcl_bpc_io_service=>c_action-failed.
          lv_failed = lv_failed + 1.
        when others.
          lv_skipped = lv_skipped + 1.
      endcase.
    endloop.
    respond(
      iv_code = 200 iv_reason = 'OK'
      iv_json = `{"results":[` && lv_json && `],"changed":` && |{ lv_changed }| &&
        `,"skipped":` && |{ lv_skipped }| && `,"failed":` && |{ lv_failed }| && `}` ).
  endmethod.

  method read_environment.
    data(lv_environment) = mo_server->request->get_form_field( 'environment' ).
    data lv_environment_id type uj_appset_id.
    describe field lv_environment_id length data(lv_length) in character mode.
    if lv_environment is initial or strlen( lv_environment ) > lv_length.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid environment is required' ).
      return.
    endif.
    rv_environment = lv_environment.
  endmethod.

  method read_model.
    data(lv_model) = mo_server->request->get_form_field( 'model' ).
    data lv_model_id type uj_appl_id.
    describe field lv_model_id length data(lv_length) in character mode.
    if lv_model is initial or strlen( lv_model ) > lv_length.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid model is required' ).
      return.
    endif.
    rv_model = lv_model.
  endmethod.

  method read_script_name.
    data(lv_name) = mo_server->request->get_form_field( 'name' ).
    data lv_script_name type uj_docname.
    describe field lv_script_name length data(lv_length) in character mode.
    if lv_name is initial or strlen( lv_name ) > lv_length.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid script name is required' ).
      return.
    endif.
    rv_name = lv_name.
  endmethod.

  method read_group.
    data(lv_group) = mo_server->request->get_form_field( 'group' ).
    data lv_group_id type uj_pack_grp_id.
    describe field lv_group_id length data(lv_length) in character mode.
    if lv_group is initial or strlen( lv_group ) > lv_length.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid group is required' ).
      return.
    endif.
    rv_group = lv_group.
  endmethod.

  method read_package.
    data(lv_package) = mo_server->request->get_form_field( 'id' ).
    data lv_package_id type uj_package_id.
    describe field lv_package_id length data(lv_length) in character mode.
    if lv_package is initial or strlen( lv_package ) > lv_length.
      respond_error( iv_code = 400 iv_reason = 'Bad Request'
                     iv_message = 'A valid package id is required' ).
      return.
    endif.
    rv_package = lv_package.
  endmethod.

  method require_method.
    if mo_server->request->get_method( ) = iv_method.
      rv_allowed = abap_true.
      return.
    endif.
    respond_error( iv_code = 405 iv_reason = 'Method Not Allowed'
                   iv_message = |Only { iv_method } is supported| iv_allow = iv_method ).
  endmethod.

  method respond.
    if iv_allow is not initial.
      mo_server->response->set_header_field( name = 'Allow' value = iv_allow ).
    endif.
    mo_server->response->set_status( code = iv_code reason = iv_reason ).
    mo_server->response->set_cdata( iv_json ).
  endmethod.

  method respond_error.
    respond( iv_code = iv_code iv_reason = iv_reason iv_allow = iv_allow
             iv_json = `{"error":{"message":` && quote( iv_message ) && `}}` ).
  endmethod.

  method quote.
    data(lv_value) = |{ iv_value }|.
    rv_json = `"` && escape( val = lv_value format = cl_abap_format=>e_json_string ) && `"`.
  endmethod.
endclass.

