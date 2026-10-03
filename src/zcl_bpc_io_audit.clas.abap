CLASS zcl_bpc_io_audit DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_user,
             user_id TYPE syst_uname,
             license TYPE string,
             account_status TYPE string,
             source TYPE string,
             activity TYPE rsbpc_value,
             activity_date TYPE dats,
             activity_time TYPE rstimestmp,
             environment TYPE rsbpc_value,
             last_access_date TYPE dats,
             last_access_time TYPE rstimestmp,
             priority TYPE i,
           END OF ty_user,
           ty_users TYPE STANDARD TABLE OF ty_user WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_result,
             start_date TYPE dats,
             end_date TYPE dats,
             client TYPE mandt,
             professional TYPE i,
             standard TYPE i,
             inactive_professional TYPE i,
             inactive_standard TYPE i,
             users TYPE ty_users,
           END OF ty_result.
    CLASS-METHODS analyse
      IMPORTING iv_start TYPE dats OPTIONAL
      RETURNING VALUE(rs_result) TYPE ty_result
      RAISING cx_uj_no_auth cx_uj_input_error.
  PRIVATE SECTION.
    CLASS-METHODS append_usage
      IMPORTING it_usage TYPE rsbpc0_t_usage iv_status TYPE string iv_source TYPE string
      CHANGING ct_users TYPE ty_users.
ENDCLASS.

CLASS zcl_bpc_io_audit IMPLEMENTATION.
  METHOD analyse.
    " Same authorization and period semantics as RSBPCA_NW_AUDIT.
    AUTHORITY-CHECK OBJECT 'S_RS_ADMWB'
      ID 'RSADMWBOBJ' FIELD 'Monitor'
      ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_uj_no_auth.
    ENDIF.
    rs_result-start_date = iv_start.
    IF rs_result-start_date IS INITIAL.
      rs_result-start_date = sy-datum - 365.
    ENDIF.
    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
      EXPORTING date = rs_result-start_date
      EXCEPTIONS plausibility_check_failed = 1 OTHERS = 2.
    IF sy-subrc <> 0 OR rs_result-start_date > sy-datum.
      RAISE EXCEPTION TYPE cx_uj_input_error.
    ENDIF.
    rs_result-end_date = sy-datum.
    rs_result-client = sy-mandt.
    DATA lt_period TYPE rsbpc0_t_period.
    APPEND VALUE #( per_start = rs_result-start_date per_end = rs_result-end_date ) TO lt_period.
    DATA lt_active TYPE rsbpc0_t_usage.
    DATA lt_inactive TYPE rsbpc0_t_usage.
    " Both engines contribute, as in SAP's audit report. No custom activity rules.
    CALL FUNCTION 'RSBPCA_GET_USAGE_UNIFIED'
      EXPORTING i_t_period = lt_period i_f_usage_detail = abap_true
      IMPORTING e_t_usage_a = lt_active e_t_usage_i = lt_inactive.
    append_usage( EXPORTING it_usage = lt_active iv_status = 'Active' iv_source = 'Embedded'
                  CHANGING ct_users = rs_result-users ).
    append_usage( EXPORTING it_usage = lt_inactive iv_status = 'Inactive' iv_source = 'Embedded'
                  CHANGING ct_users = rs_result-users ).
    CLEAR: lt_active, lt_inactive.
    CALL FUNCTION 'UJ0_GET_USAGE_CLASSIC'
      EXPORTING i_t_period = lt_period i_f_usage_detail = abap_true
      IMPORTING e_t_usage_a = lt_active e_t_usage_i = lt_inactive.
    append_usage( EXPORTING it_usage = lt_active iv_status = 'Active' iv_source = 'Classic'
                  CHANGING ct_users = rs_result-users ).
    append_usage( EXPORTING it_usage = lt_inactive iv_status = 'Inactive' iv_source = 'Classic'
                  CHANGING ct_users = rs_result-users ).
    " One license per user in this client; Professional wins across both engines.
    SORT rs_result-users BY user_id priority activity_date DESCENDING activity_time DESCENDING source activity.
    DELETE ADJACENT DUPLICATES FROM rs_result-users COMPARING user_id.
    IF rs_result-users IS NOT INITIAL.
      DATA lt_user_range TYPE RANGE OF xubname.
      LOOP AT rs_result-users INTO DATA(ls_counted_user).
        APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_counted_user-user_id ) TO lt_user_range.
      ENDLOOP.
      " Last access is distinct from the last qualifying Professional activity.
      SELECT user_id, MAX( last_logon_date ) AS last_access_date,
             MAX( last_act_timestmp ) AS last_access_time
        FROM uja_logged_on_a
        WHERE user_id IN @lt_user_range AND appset_id <> ''
          AND last_logon_date >= @rs_result-start_date AND last_logon_date <= @rs_result-end_date
        GROUP BY user_id
        INTO TABLE @DATA(lt_classic_access).
      SELECT user_id, MAX( last_logon_date ) AS last_access_date,
             MAX( last_act_timestmp ) AS last_access_time
        FROM rsbpc0_logon_a
        WHERE user_id IN @lt_user_range AND appset_id <> ''
          AND last_logon_date >= @rs_result-start_date AND last_logon_date <= @rs_result-end_date
        GROUP BY user_id
        INTO TABLE @DATA(lt_embedded_access).
      APPEND LINES OF lt_embedded_access TO lt_classic_access.
      SELECT user_id, MAX( logon_date ) AS last_access_date
        FROM uja_logged_on
        WHERE user_id IN @lt_user_range
          AND logon_date >= @rs_result-start_date AND logon_date <= @rs_result-end_date
        GROUP BY user_id
        INTO TABLE @DATA(lt_logons).
      SELECT username AS user_id, lastdate AS last_access_date
        FROM rspls_usage_log
        WHERE username IN @lt_user_range AND product = 'U'
          AND lastdate >= @rs_result-start_date AND lastdate <= @rs_result-end_date
        INTO TABLE @DATA(lt_bw_access).
      APPEND LINES OF lt_bw_access TO lt_logons.
      SORT lt_classic_access BY user_id last_access_date DESCENDING last_access_time DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_classic_access COMPARING user_id.
      SORT lt_logons BY user_id last_access_date DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_logons COMPARING user_id.
      LOOP AT rs_result-users ASSIGNING FIELD-SYMBOL(<user>).
        READ TABLE lt_classic_access INTO DATA(ls_access) WITH KEY user_id = <user>-user_id BINARY SEARCH.
        IF sy-subrc = 0 AND ls_access-last_access_date >= <user>-last_access_date.
          <user>-last_access_date = ls_access-last_access_date.
          <user>-last_access_time = ls_access-last_access_time.
        ENDIF.
        READ TABLE lt_logons INTO DATA(ls_logon) WITH KEY user_id = <user>-user_id BINARY SEARCH.
        IF sy-subrc = 0 AND ls_logon-last_access_date > <user>-last_access_date.
          <user>-last_access_date = ls_logon-last_access_date.
          CLEAR <user>-last_access_time.
        ENDIF.
      ENDLOOP.
    ENDIF.
    LOOP AT rs_result-users INTO DATA(ls_user).
      IF ls_user-account_status = 'Active'.
        IF ls_user-license = 'Professional'.
          rs_result-professional = rs_result-professional + 1.
        ELSE.
          rs_result-standard = rs_result-standard + 1.
        ENDIF.
      ELSEIF ls_user-license = 'Professional'.
        rs_result-inactive_professional = rs_result-inactive_professional + 1.
      ELSE.
        rs_result-inactive_standard = rs_result-inactive_standard + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD append_usage.
    LOOP AT it_usage INTO DATA(ls_usage) WHERE mandt = sy-mandt.
      DO 2 TIMES.
        DATA lt_users TYPE rsbpc0_t_usr_usage.
        DATA lv_license TYPE string.
        DATA lv_priority TYPE i.
        IF sy-index = 1.
          lt_users = ls_usage-t_p_user.
          lv_license = 'Professional'.
          lv_priority = 0.
        ELSE.
          lt_users = ls_usage-t_s_user.
          lv_license = 'Standard'.
          lv_priority = 1.
        ENDIF.
        LOOP AT lt_users INTO DATA(ls_usage_user).
          APPEND VALUE #( user_id = ls_usage_user-user_id license = lv_license
            priority = lv_priority account_status = iv_status source = iv_source
            activity = ls_usage_user-last_act activity_date = ls_usage_user-last_act_date
            activity_time = ls_usage_user-last_act_time environment = ls_usage_user-last_act_appset
            last_access_date = ls_usage_user-last_act_date last_access_time = ls_usage_user-last_act_time ) TO ct_users.
        ENDLOOP.
      ENDDO.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
