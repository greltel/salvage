*"* use this source file for your ABAP unit test classes

CLASS ltc_salvage DEFINITION DEFERRED.
CLASS zcl_salvage DEFINITION LOCAL FRIENDS ltc_salvage.

" Records what ZCL_SALVAGE passes on to the handler of a list
CLASS ltd_handler DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_salvage_events.

    DATA row    TYPE i READ-ONLY.
    DATA column TYPE lvc_fname READ-ONLY.
    DATA button TYPE salv_de_function READ-ONLY.
ENDCLASS.


CLASS ltd_handler IMPLEMENTATION.
  METHOD zif_salvage_events~on_double_click.
    me->row    = row.
    me->column = column.
  ENDMETHOD.

  METHOD zif_salvage_events~on_link_click.
    me->row    = row.
    me->column = column.
  ENDMETHOD.

  METHOD zif_salvage_events~on_button_click.
    me->button = button.
  ENDMETHOD.
ENDCLASS.


" Runs everything DISPLAY does before the screen (method PREPARE) and checks the outcome:
" the configuration errors ZCL_SALVAGE must reject, the settings it hands to the CL_SALV_TABLE,
" and the mapping of full screen button slots. No test opens a list or reads business data.
CLASS ltc_salvage DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF flight,
        carrid   TYPE s_carr_id,
        connid   TYPE s_conn_id,
        price    TYPE s_price,
        currency TYPE s_currcode,
        seatsocc TYPE s_seatsocc,
        load     TYPE p LENGTH 5 DECIMALS 1,
        light    TYPE c LENGTH 1,
        colors   TYPE lvc_t_scol,
        remark   TYPE c LENGTH 20,
        picked   TYPE abap_bool,
      END OF flight.
    TYPES flight_rows TYPE STANDARD TABLE OF flight WITH EMPTY KEY.
    TYPES sorted_flights TYPE SORTED TABLE OF flight WITH UNIQUE KEY carrid connid.
    TYPES hashed_flights TYPE HASHED TABLE OF flight WITH UNIQUE KEY carrid connid.

    CONSTANTS:
      BEGIN OF columns,
        airline  TYPE lvc_fname VALUE 'CARRID',
        flight   TYPE lvc_fname VALUE 'CONNID',
        price    TYPE lvc_fname VALUE 'PRICE',
        currency TYPE lvc_fname VALUE 'CURRENCY',
        occupied TYPE lvc_fname VALUE 'SEATSOCC',
        load     TYPE lvc_fname VALUE 'LOAD',
        light    TYPE lvc_fname VALUE 'LIGHT',
        colors   TYPE lvc_fname VALUE 'COLORS',
        remark   TYPE lvc_fname VALUE 'REMARK',
        picked   TYPE lvc_fname VALUE 'PICKED',
        unknown  TYPE lvc_fname VALUE 'NO_SUCH_COLUMN',
      END OF columns.

    " Messages of class ZSALVAGE
    CONSTANTS:
      BEGIN OF messages,
        unknown_column    TYPE symsgno VALUE '001',
        sort_error        TYPE symsgno VALUE '003',
        total_error       TYPE symsgno VALUE '004',
        too_many_buttons  TYPE symsgno VALUE '006',
        buttons_in_popup  TYPE symsgno VALUE '007',
        duplicate_button  TYPE symsgno VALUE '008',
        displayed_twice   TYPE symsgno VALUE '009',
        selection_mode    TYPE symsgno VALUE '010',
        unsupported_table TYPE symsgno VALUE '011',
        color_column      TYPE symsgno VALUE '013',
        reference_column  TYPE symsgno VALUE '014',
        light_column      TYPE symsgno VALUE '015',
        filter_option     TYPE symsgno VALUE '016',
        no_container      TYPE symsgno VALUE '017',
        total_kind        TYPE symsgno VALUE '018',
        popup_size        TYPE symsgno VALUE '019',
        fixed_and_column  TYPE symsgno VALUE '020',
        no_button_name    TYPE symsgno VALUE '022',
        filter_value      TYPE symsgno VALUE '023',
        missing_status    TYPE symsgno VALUE '024',
        checkbox_column   TYPE symsgno VALUE '025',
        missing_exit      TYPE symsgno VALUE '026',
      END OF messages.

    CONSTANTS:
      BEGIN OF buttons,
        first  TYPE salv_de_function VALUE 'FIRST',
        second TYPE salv_de_function VALUE 'SECOND',
      END OF buttons.

    " Functions of GUI status SALVAGE_FULLSCREEN for the second and the third own button
    CONSTANTS:
      BEGIN OF slots,
        second TYPE salv_de_function VALUE 'SALVAGE02',
        third  TYPE salv_de_function VALUE 'SALVAGE03',
      END OF slots.

    " A function code that is no own button, as a user may type it into the command field
    CONSTANTS typed_code TYPE salv_de_function VALUE 'FOO'.

    " A GUI status that program ZSALVAGE_GUI does not have
    CONSTANTS no_status TYPE sypfkey VALUE 'NO_SUCH_STATUS'.

    " Signs and comparisons of a filter condition
    CONSTANTS:
      BEGIN OF filter_values,
        excluding TYPE salv_de_selopt_sign   VALUE 'E',
        equal     TYPE salv_de_selopt_option VALUE 'EQ',
      END OF filter_values.

    CONSTANTS:
      BEGIN OF layout_values,
        name    TYPE slis_vari  VALUE '/TEST',
        handle  TYPE slis_handl VALUE 'HEAD',
        missing TYPE slis_vari  VALUE '/NO_LAYOUT',
        program TYPE syrepid    VALUE 'ZSALVAGE_SHARED_LIST',
      END OF layout_values.

    " Conversion exit ALPHA exists in every system; no system has a function module
    " CONVERSION_EXIT_ZZZZZ_OUTPUT. A template may hold text in lower case
    CONSTANTS alpha_mask TYPE lvc_edtmsk VALUE '==ALPHA'.
    CONSTANTS lower_alpha_mask TYPE lvc_edtmsk VALUE '==alpha'.
    CONSTANTS missing_exit_mask TYPE lvc_edtmsk VALUE '==ZZZZZ'.
    CONSTANTS long_exit_mask TYPE lvc_edtmsk VALUE '==ALPHA_OUTPUT_AND_SOME_MORE_TEXT'.
    CONSTANTS template_mask TYPE lvc_edtmsk VALUE '___ pcs'.

    CONSTANTS:
      BEGIN OF fixed_values,
        currency TYPE lvc_curr VALUE 'JPY',
        unit     TYPE lvc_quan VALUE 'ST',
      END OF fixed_values.

    " A filter condition with an upper value
    CONSTANTS:
      BEGIN OF between,
        option TYPE salv_de_selopt_option VALUE 'BT',
        low    TYPE salv_de_selopt_low    VALUE 'AA',
        high   TYPE salv_de_selopt_high   VALUE 'LH',
      END OF between.

    " ZCL_SALVAGE=>VERSION is major.minor.patch, the release tag without the leading v
    CONSTANTS:
      BEGIN OF version_format,
        separator TYPE c LENGTH 1 VALUE '.',
        parts     TYPE i VALUE 3,
        digits    TYPE c LENGTH 10 VALUE '0123456789',
      END OF version_format.

    DATA flights TYPE flight_rows.

    METHODS setup.

    METHODS new_list
      RETURNING VALUE(result) TYPE REF TO zcl_salvage.

    METHODS two_button_list
      RETURNING VALUE(result) TYPE REF TO zcl_salvage.

    METHODS rejection_of
      IMPORTING list          TYPE REF TO zcl_salvage
      RETURNING VALUE(result) TYPE symsgno.

    METHODS column_of
      IMPORTING list          TYPE REF TO zcl_salvage
                name          TYPE lvc_fname
      RETURNING VALUE(result) TYPE REF TO cl_salv_column_table
      RAISING   cx_salv_not_found.

    METHODS function_of
      IMPORTING list          TYPE REF TO zcl_salvage
                name          TYPE salv_de_function
      RETURNING VALUE(result) TYPE REF TO cl_salv_function.

    METHODS first_condition_of
      IMPORTING list          TYPE REF TO zcl_salvage
      RETURNING VALUE(result) TYPE REF TO cl_salv_selopt
      RAISING   cx_salv_not_found.

    METHODS is_offered
      IMPORTING list          TYPE REF TO zcl_salvage
                function      TYPE salv_de_function
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS when_sorted_table_then_raises FOR TESTING.
    METHODS when_string_lines_then_raises FOR TESTING.
    METHODS when_no_table_then_raises     FOR TESTING.
    METHODS when_displayed_then_raises    FOR TESTING.
    METHODS when_11_buttons_then_raises   FOR TESTING.
    METHODS when_popup_button_then_raises FOR TESTING.
    METHODS when_button_twice_then_raises FOR TESTING.
    METHODS when_bad_column_then_raises   FOR TESTING.
    METHODS when_bad_sort_then_raises     FOR TESTING.
    METHODS when_bad_filter_then_raises   FOR TESTING.
    METHODS when_sorted_twice_then_raises FOR TESTING.
    METHODS when_text_total_then_raises   FOR TESTING.
    METHODS when_bad_kind_then_raises     FOR TESTING.
    METHODS when_kind_none_then_raises    FOR TESTING.
    METHODS when_bad_option_then_raises   FOR TESTING.
    METHODS when_part_option_then_raises  FOR TESTING.
    METHODS when_bad_unit_then_raises     FOR TESTING.
    METHODS when_text_colors_then_raises  FOR TESTING.
    METHODS when_packed_lights_then_raises FOR TESTING.
    METHODS when_bad_selection_then_raises FOR TESTING.
    METHODS when_no_container_then_raises FOR TESTING.
    METHODS when_bad_popup_then_raises    FOR TESTING.
    METHODS when_popup_partial_then_raises FOR TESTING.
    METHODS when_fixed_and_ref_then_raises FOR TESTING.
    METHODS when_fixed_split_then_raises  FOR TESTING.
    METHODS when_batch_then_full_screen   FOR TESTING.

    METHODS when_text_then_all_headers    FOR TESTING RAISING cx_static_check.
    METHODS when_hidden_then_invisible    FOR TESTING RAISING cx_static_check.
    METHODS when_width_then_output_length FOR TESTING RAISING cx_static_check.
    METHODS when_no_ddic_then_name_header FOR TESTING RAISING cx_static_check.
    METHODS when_lower_case_then_found    FOR TESTING RAISING cx_static_check.
    METHODS when_currency_then_reference  FOR TESTING RAISING cx_static_check.
    METHODS when_two_conditions_then_one  FOR TESTING RAISING cx_static_check.
    METHODS when_average_then_kind_set    FOR TESTING RAISING cx_static_check.
    METHODS when_colors_from_then_set     FOR TESTING.
    METHODS when_lights_from_then_set     FOR TESTING.
    METHODS when_multiple_then_row_column FOR TESTING.
    METHODS when_top_of_list_then_set     FOR TESTING.
    METHODS when_not_shown_then_no_cells  FOR TESTING.
    METHODS when_hotspot_then_cell_type   FOR TESTING RAISING cx_static_check.
    METHODS when_checkbox_then_cell_type  FOR TESTING RAISING cx_static_check.
    METHODS when_check_hotspot_then_type  FOR TESTING RAISING cx_static_check.
    METHODS when_hotspot_later_then_both  FOR TESTING RAISING cx_static_check.
    METHODS when_checkbox_later_then_both FOR TESTING RAISING cx_static_check.
    METHODS when_column_format_then_set   FOR TESTING RAISING cx_static_check.
    METHODS when_position_then_moved      FOR TESTING RAISING cx_static_check.
    METHODS when_technical_then_technical FOR TESTING RAISING cx_static_check.
    METHODS when_display_set_then_applied FOR TESTING.
    METHODS when_layout_then_key_and_name FOR TESTING.
    METHODS when_end_of_list_then_set     FOR TESTING.
    METHODS when_excluded_then_sign_e     FOR TESTING RAISING cx_static_check.
    METHODS when_no_option_then_eq        FOR TESTING RAISING cx_static_check.
    METHODS when_empty_column_then_hidden FOR TESTING RAISING cx_static_check.
    METHODS when_no_rows_then_none_hidden FOR TESTING RAISING cx_static_check.
    METHODS when_error_then_column_in_msg FOR TESTING.
    METHODS when_not_shown_then_no_rows   FOR TESTING.
    METHODS when_unknown_color_then_raises FOR TESTING.
    METHODS when_case_twice_then_raises   FOR TESTING.
    METHODS when_fixed_currency_then_set  FOR TESTING RAISING cx_static_check.
    METHODS when_fixed_unit_then_set      FOR TESTING RAISING cx_static_check.
    METHODS when_fixed_keys_then_frozen   FOR TESTING.
    METHODS when_save_off_then_default    FOR TESTING.
    METHODS when_subtotals_then_set       FOR TESTING RAISING cx_static_check.
    METHODS when_single_then_single_mode  FOR TESTING.
    METHODS when_cells_then_cell_mode     FOR TESTING.
    METHODS when_between_then_high        FOR TESTING RAISING cx_static_check.
    METHODS when_export_off_then_hidden   FOR TESTING.
    METHODS when_print_off_then_hidden    FOR TESTING.
    METHODS when_toolbar_then_others_kept FOR TESTING.
    METHODS when_not_shown_then_no_columns FOR TESTING.
    METHODS when_unknown_layout_then_false FOR TESTING.
    METHODS when_no_layout_name_then_false FOR TESTING.
    METHODS when_closed_then_shown_again  FOR TESTING.
    METHODS when_shown_again_then_new_salv FOR TESTING.
    METHODS when_blank_button_then_raises FOR TESTING.
    METHODS when_descending_then_sort_down FOR TESTING RAISING cx_static_check.
    METHODS when_no_order_then_sort_up    FOR TESTING RAISING cx_static_check.
    METHODS when_layout_program_then_key  FOR TESTING.
    METHODS when_no_program_then_own_key  FOR TESTING.
    METHODS when_select_rows_then_existing FOR TESTING.
    METHODS when_select_rows_then_accepted FOR TESTING.

    METHODS when_slot_then_button_name    FOR TESTING.
    METHODS when_container_then_same_name FOR TESTING.
    METHODS when_unused_slot_then_no_text FOR TESTING.
    METHODS when_slot_text_then_dyntxt    FOR TESTING.
    METHODS when_icon_only_then_menu_tip  FOR TESTING.
    METHODS when_no_text_then_menu_name   FOR TESTING.
    METHODS when_buttons_then_slots_known FOR TESTING.
    METHODS when_link_click_then_handler  FOR TESTING.
    METHODS when_double_click_then_handler FOR TESTING.
    METHODS when_slot_click_then_button   FOR TESTING.
    METHODS when_no_handler_then_no_dump  FOR TESTING.
    METHODS when_total_click_then_ignored FOR TESTING.

    METHODS when_version_then_semantic    FOR TESTING.

    METHODS when_no_number_then_raises     FOR TESTING.
    METHODS when_bad_high_then_raises      FOR TESTING.
    METHODS when_numc_letters_then_raises  FOR TESTING.
    METHODS when_number_filter_then_valid  FOR TESTING.
    METHODS when_pattern_then_not_checked  FOR TESTING.
    METHODS when_no_status_then_raises     FOR TESTING.
    METHODS when_unchecked_box_then_shown  FOR TESTING RAISING cx_static_check.
    METHODS when_unknown_code_then_ignored FOR TESTING.
    METHODS when_position_beyond_then_last FOR TESTING RAISING cx_static_check.
    METHODS when_two_positions_then_both   FOR TESTING RAISING cx_static_check.
    METHODS when_left_moves_then_both_fit  FOR TESTING RAISING cx_static_check.
    METHODS when_position_twice_then_last  FOR TESTING RAISING cx_static_check.
    METHODS when_unit_and_curr_then_raises FOR TESTING.
    METHODS when_both_ref_cols_then_raises FOR TESTING.
    METHODS when_wide_checkbox_then_raises FOR TESTING.
    METHODS when_stale_row_then_ignored    FOR TESTING.
    METHODS when_no_text_icon_then_tooltip FOR TESTING.
    METHODS when_name_only_then_name_text  FOR TESTING.
    METHODS when_icon_only_then_no_text    FOR TESTING.
    METHODS when_batch_then_no_buttons     FOR TESTING.
    METHODS when_missing_exit_then_raises  FOR TESTING.
    METHODS when_long_exit_then_raises     FOR TESTING.
    METHODS when_lower_exit_then_upper     FOR TESTING RAISING cx_static_check.
    METHODS when_template_mask_then_kept   FOR TESTING RAISING cx_static_check.

    METHODS when_hashed_table_then_raises  FOR TESTING.
    METHODS when_structure_ref_then_raises FOR TESTING.
    METHODS when_bad_total_col_then_raises FOR TESTING.
    METHODS when_unknown_light_then_raises FOR TESTING.
    METHODS when_total_twice_then_raises   FOR TESTING.
    METHODS when_lower_option_then_valid   FOR TESTING RAISING cx_static_check.
    METHODS when_buttons_then_ten_slots    FOR TESTING.
    METHODS when_late_handler_then_no_dump FOR TESTING.
    METHODS when_lower_program_then_upper  FOR TESTING.
ENDCLASS.


CLASS ltc_salvage IMPLEMENTATION.
  METHOD setup.
    flights = VALUE #( ( carrid   = 'LH'
                         connid   = '0400'
                         price    = '666.00'
                         currency = 'EUR'
                         seatsocc = 130
                         load     = '27.4'
                         light    = '3' )
                       ( carrid   = 'UA'
                         connid   = '3504'
                         price    = '879.82'
                         currency = 'USD'
                         seatsocc = 270
                         load     = '56.8'
                         light    = '2' ) ).
  ENDMETHOD.

  METHOD new_list.
    result = zcl_salvage=>create( REF #( flights ) ).
    " ABAP Unit may run in a background job, where a list has no own buttons and no container
    result->in_background = abap_false.
  ENDMETHOD.

  METHOD two_button_list.
    result = new_list( )->button( name     = buttons-first
                                  settings = VALUE #( text    = `First`
                                                      icon    = icon_okay
                                                      tooltip = `Quick info of the first button` )
                       )->button( name     = buttons-second
                                  settings = VALUE #( text = `Second` ) ).
  ENDMETHOD.

  METHOD rejection_of.
    TRY.
        list->prepare( ).
      CATCH zcx_salvage_error INTO DATA(error).
        result = error->if_t100_message~t100key-msgno.
    ENDTRY.
  ENDMETHOD.

  METHOD column_of.
    result = CAST #( list->salv->get_columns( )->get_column( name ) ).
  ENDMETHOD.

  METHOD function_of.
    DATA(functions) = list->salv->get_functions( )->get_functions( ).
    LOOP AT functions INTO DATA(entry).
      IF entry-r_function->get_name( ) = name.
        result = entry-r_function.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD first_condition_of.
    DATA(conditions) = list->salv->get_filters( )->get_filter( columns-airline )->get( ).
    result = conditions[ 1 ].
  ENDMETHOD.

  METHOD is_offered.
    " The function codes come from IF_SALV_C_FUNCTION, which is not classic API; test class only
    result = list->salv->get_functions( )->is_visible( function ).
  ENDMETHOD.

  METHOD when_sorted_table_then_raises.
    " Given
    DATA(sorted) = VALUE sorted_flights( ).
    DATA(list) = zcl_salvage=>create( REF #( sorted ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-unsupported_table
                                        msg = `A sorted table must be rejected` ).
  ENDMETHOD.

  METHOD when_string_lines_then_raises.
    " Given
    DATA(texts) = VALUE string_table( ( `alpha` ) ).
    DATA(list) = zcl_salvage=>create( REF #( texts ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-unsupported_table
                                        msg = `A table whose lines are not structures must be rejected` ).
  ENDMETHOD.

  METHOD when_no_table_then_raises.
    " Given
    DATA nothing TYPE REF TO data.
    DATA(list) = zcl_salvage=>create( nothing ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-unsupported_table
                                        msg = `An initial reference must be rejected` ).
  ENDMETHOD.

  METHOD when_displayed_then_raises.
    " Given a list that is on the screen
    DATA(list) = new_list( ).
    list->is_open = abap_true.
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-displayed_twice
                                        msg = `A list on the screen must not be displayed again` ).
  ENDMETHOD.

  METHOD when_11_buttons_then_raises.
    " Given a full screen list with one button more than the GUI status has slots
    DATA(list) = new_list( ).
    DO 11 TIMES.
      list->button( name     = |BUTTON_{ sy-index }|
                    settings = VALUE #( text = |{ sy-index }| ) ).
    ENDDO.
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-too_many_buttons
                                        msg = `Eleven buttons in full screen must be rejected` ).
  ENDMETHOD.

  METHOD when_popup_button_then_raises.
    " Given
    DATA(list) = two_button_list( )->popup( ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-buttons_in_popup
                                        msg = `Own buttons in a dialog box must be rejected` ).
  ENDMETHOD.

  METHOD when_button_twice_then_raises.
    " Given
    DATA(list) = two_button_list( )->button( name     = buttons-first
                                             settings = VALUE #( text = `Again` ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-duplicate_button
                                        msg = `A button name used twice must be rejected` ).
  ENDMETHOD.

  METHOD when_bad_column_then_raises.
    " Given
    DATA(list) = new_list( )->column( name     = columns-unknown
                                      settings = VALUE #( is_key = abap_true ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-unknown_column
                                        msg = `COLUMN with an unknown name must be rejected` ).
  ENDMETHOD.

  METHOD when_bad_sort_then_raises.
    " Given
    DATA(list) = new_list( )->sort_by( columns-unknown ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-unknown_column
                                        msg = `SORT_BY an unknown column must be rejected` ).
  ENDMETHOD.

  METHOD when_bad_filter_then_raises.
    " Given
    DATA(list) = new_list( )->filter_by( name     = columns-unknown
                                         settings = VALUE #( low = 'X' ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-unknown_column
                                        msg = `FILTER_BY an unknown column must be rejected` ).
  ENDMETHOD.

  METHOD when_sorted_twice_then_raises.
    " Given
    DATA(list) = new_list( )->sort_by( columns-airline )->sort_by( columns-airline ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-sort_error
                                        msg = `Sorting by the same column twice must be rejected` ).
  ENDMETHOD.

  METHOD when_text_total_then_raises.
    " Given
    DATA(list) = new_list( )->total( columns-airline ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-total_error
                                        msg = `A total of a text column must be rejected` ).
  ENDMETHOD.

  METHOD when_bad_kind_then_raises.
    " Given a kind outside the constants 0 to 4 of IF_SALV_C_AGGREGATION
    DATA(list) = new_list( )->total( name = columns-occupied
                                     kind = 9 ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-total_kind
                                        msg = `An unknown total kind must be rejected` ).
  ENDMETHOD.

  METHOD when_kind_none_then_raises.
    " Given
    DATA(list) = new_list( )->total( name = columns-occupied
                                     kind = if_salv_c_aggregation=>none ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-total_kind
                                        msg = `A total of kind NONE must be rejected` ).
  ENDMETHOD.

  METHOD when_bad_option_then_raises.
    " Given
    DATA(list) = new_list( )->filter_by( name     = columns-airline
                                         settings = VALUE #( option = 'XX'
                                                             low    = 'LH' ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-filter_option
                                        msg = `An unknown filter comparison must be rejected` ).
  ENDMETHOD.

  METHOD when_part_option_then_raises.
    " Given a comparison that is only part of one, as ' N' is of 'NE'
    DATA(list) = new_list( )->filter_by( name     = columns-airline
                                         settings = VALUE #( option = ' N'
                                                             low    = 'LH' ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-filter_option
                                        msg = `Part of a comparison must be rejected` ).
  ENDMETHOD.

  METHOD when_bad_unit_then_raises.
    " Given
    DATA(list) = new_list( )->column( name     = columns-occupied
                                      settings = VALUE #( unit_column = 'NO_SUCH_UNIT' ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-reference_column
                                        msg = `A unit column that does not exist must be rejected` ).
  ENDMETHOD.

  METHOD when_text_colors_then_raises.
    " Given
    DATA(list) = new_list( )->colors_from( columns-airline ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-color_column
                                        msg = `Colours from a column not of type LVC_T_SCOL must be rejected` ).
  ENDMETHOD.

  METHOD when_packed_lights_then_raises.
    " Given
    DATA(list) = new_list( )->lights_from( columns-price ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-light_column
                                        msg = `Lights from a column not of type C length 1 must be rejected` ).
  ENDMETHOD.

  METHOD when_bad_selection_then_raises.
    " Given
    DATA(list) = new_list( )->selection( 99 ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-selection_mode
                                        msg = `An unknown selection mode must be rejected` ).
  ENDMETHOD.

  METHOD when_no_container_then_raises.
    " Given
    DATA no_container TYPE REF TO cl_gui_container.
    DATA(list) = new_list( )->in_container( no_container ).
    " ABAP Unit may run in a background job, where a container list falls back to full screen
    list->in_background = abap_false.
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-no_container
                                        msg = `IN_CONTAINER without a container must be rejected` ).
  ENDMETHOD.

  METHOD when_bad_popup_then_raises.
    " Given coordinates the wrong way round
    DATA(list) = new_list( )->popup( VALUE #( start_column = 100
                                              end_column   = 10
                                              start_line   = 20
                                              end_line     = 5 ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-popup_size
                                        msg = `A dialog box with inverted coordinates must be rejected` ).
  ENDMETHOD.

  METHOD when_popup_partial_then_raises.
    " Given only two of the four coordinates
    DATA(list) = new_list( )->popup( VALUE #( end_column = 80
                                              end_line   = 20 ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-popup_size
                                        msg = `A dialog box without start coordinates must be rejected` ).
  ENDMETHOD.

  METHOD when_text_then_all_headers.
    " Given a text that is longer than a short header
    DATA(header) = `Airline of the flight`.
    DATA(list) = new_list( )->column( name     = columns-airline
                                      settings = VALUE #( text = header ) ).
    " When
    list->prepare( ).
    " Then
    DATA(column) = column_of( list = list
                              name = columns-airline ).
    cl_abap_unit_assert=>assert_equals( act = column->get_long_text( )
                                        exp = CONV scrtext_l( header )
                                        msg = `The text must be the long header` ).
    cl_abap_unit_assert=>assert_equals( act = column->get_short_text( )
                                        exp = CONV scrtext_s( header )
                                        msg = `The text, cut to 10 characters, must be the short header` ).
  ENDMETHOD.

  METHOD when_hidden_then_invisible.
    " Given
    DATA(list) = new_list( )->column( name     = columns-price
                                      settings = VALUE #( is_hidden = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_false( act = column_of( list = list
                                                        name = columns-price )->is_visible( )
                                       msg = `A hidden column must not be visible at start` ).
  ENDMETHOD.

  METHOD when_width_then_output_length.
    " Given
    DATA(list) = new_list( )->column( name     = columns-price
                                      settings = VALUE #( width = 15 ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = column_of( list = list
                                                         name = columns-price )->get_output_length( )
                                        exp = CONV lvc_outlen( 15 )
                                        msg = `The width must be the output length` ).
  ENDMETHOD.

  METHOD when_no_ddic_then_name_header.
    " Given LOAD, a component typed without a data element
    DATA(list) = new_list( ).
    " When
    list->prepare( ).
    " Then
    DATA(column) = column_of( list = list
                              name = columns-load ).
    cl_abap_unit_assert=>assert_equals( act = column->get_long_text( )
                                        exp = CONV scrtext_l( columns-load )
                                        msg = `A column without data element must be headed by its name` ).
    cl_abap_unit_assert=>assert_true( act = column->is_optimized( )
                                      msg = `A column without data element must fit its content` ).
  ENDMETHOD.

  METHOD when_lower_case_then_found.
    " Given a column name in lower case
    DATA(list) = new_list( )->column( name     = `carrid`
                                      settings = VALUE #( is_key = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_true( act = column_of( list = list
                                                       name = columns-airline )->is_key( )
                                      msg = `A column name in lower case must find the column` ).
  ENDMETHOD.

  METHOD when_currency_then_reference.
    " Given
    DATA(list) = new_list( )->column( name     = columns-price
                                      settings = VALUE #( currency_column = columns-currency ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = column_of( list = list
                                                         name = columns-price )->get_currency_column( )
                                        exp = columns-currency
                                        msg = `The amount must take its currency from CURRENCY` ).
  ENDMETHOD.

  METHOD when_two_conditions_then_one.
    " Given two conditions for the same column
    DATA(list) = new_list( )->filter_by( name     = columns-airline
                                         settings = VALUE #( low = 'LH' )
                           )->filter_by( name     = columns-airline
                                         settings = VALUE #( low = 'UA' ) ).
    " When
    list->prepare( ).
    " Then
    DATA(filters) = list->salv->get_filters( ).
    cl_abap_unit_assert=>assert_equals( act = lines( filters->get( ) )
                                        exp = 1
                                        msg = `Both conditions must belong to one filter` ).
    cl_abap_unit_assert=>assert_equals( act = lines( filters->get_filter( columns-airline )->get( ) )
                                        exp = 2
                                        msg = `The filter must hold both conditions` ).
  ENDMETHOD.

  METHOD when_average_then_kind_set.
    " Given
    DATA(list) = new_list( )->total( name = columns-occupied
                                     kind = if_salv_c_aggregation=>average ).
    " When
    list->prepare( ).
    " Then
    DATA(aggregation) = list->salv->get_aggregations( )->get_aggregation( columns-occupied ).
    cl_abap_unit_assert=>assert_equals( act = aggregation->get( )
                                        exp = if_salv_c_aggregation=>average
                                        msg = `The total must be an average` ).
  ENDMETHOD.

  METHOD when_colors_from_then_set.
    " Given
    DATA(list) = new_list( )->colors_from( columns-colors ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = list->salv->get_columns( )->get_color_column( )
                                        exp = columns-colors
                                        msg = `COLORS must be the colour column` ).
  ENDMETHOD.

  METHOD when_lights_from_then_set.
    " Given
    DATA(list) = new_list( )->lights_from( columns-light ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = list->salv->get_columns( )->get_exception_column( )
                                        exp = columns-light
                                        msg = `LIGHT must be the traffic light column` ).
  ENDMETHOD.

  METHOD when_multiple_then_row_column.
    " Given
    DATA(list) = new_list( )->selection( zcl_salvage=>selection_modes-multiple ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = list->salv->get_selections( )->get_selection_mode( )
                                        exp = if_salv_c_selection_mode=>row_column
                                        msg = `Multiple selection must use the selection column` ).
  ENDMETHOD.

  METHOD when_top_of_list_then_set.
    " Given
    DATA(list) = new_list( )->top_of_list( VALUE #( heading = `Heading`
                                                    lines   = VALUE #( ( `First line` ) ) ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_bound( act = list->salv->get_top_of_list( )
                                       msg = `The text above the list must be set` ).
  ENDMETHOD.

  METHOD when_not_shown_then_no_cells.
    " Given a list with cell selection that is not shown yet
    DATA(list) = new_list( )->selection( zcl_salvage=>selection_modes-cells ).
    " When
    DATA(cells) = list->selected_cells( ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = cells
                                         msg = `Before DISPLAY no cell can be selected` ).
  ENDMETHOD.

  METHOD when_hotspot_then_cell_type.
    " Given
    DATA(list) = new_list( )->column( name     = columns-airline
                                      settings = VALUE #( is_hotspot = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = column_of( list = list
                                                         name = columns-airline )->get_cell_type( )
                                        exp = if_salv_c_cell_type=>hotspot
                                        msg = `A hotspot column must have cells that are links` ).
  ENDMETHOD.

  METHOD when_checkbox_then_cell_type.
    " Given
    DATA(list) = new_list( )->column( name     = columns-light
                                      settings = VALUE #( is_checkbox = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = column_of( list = list
                                                         name = columns-light )->get_cell_type( )
                                        exp = if_salv_c_cell_type=>checkbox
                                        msg = `A checkbox column must show checkboxes` ).
  ENDMETHOD.

  METHOD when_check_hotspot_then_type.
    " Given
    DATA(list) = new_list( )->column( name     = columns-light
                                      settings = VALUE #( is_checkbox = abap_true
                                                          is_hotspot  = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = column_of( list = list
                                                         name = columns-light )->get_cell_type( )
                                        exp = if_salv_c_cell_type=>checkbox_hotspot
                                        msg = `Checkbox and hotspot must give clickable checkboxes` ).
  ENDMETHOD.

  METHOD when_column_format_then_set.
    " Given
    DATA(list) = new_list( )->column( name     = columns-airline
                                      settings = VALUE #( tooltip   = `Code of the airline`
                                                          edit_mask = alpha_mask
                                                          color     = VALUE #( col = col_positive ) ) ).
    " When
    list->prepare( ).
    " Then
    DATA(column) = column_of( list = list
                              name = columns-airline ).
    cl_abap_unit_assert=>assert_equals( act = column->get_tooltip( )
                                        exp = CONV lvc_tip( `Code of the airline` )
                                        msg = `The tooltip must be the quick info of the header` ).
    cl_abap_unit_assert=>assert_equals( act = column->get_edit_mask( )
                                        exp = alpha_mask
                                        msg = `The edit mask must be handed to SALV` ).
    cl_abap_unit_assert=>assert_equals( act = column->get_color( )-col
                                        exp = col_positive
                                        msg = `The colour must be the colour of the column` ).
  ENDMETHOD.

  METHOD when_position_then_moved.
    " Given
    DATA(list) = new_list( )->column( name     = columns-price
                                      settings = VALUE #( position = 1 ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = list->salv->get_columns( )->get_column_position( columns-price )
                                        exp = 1
                                        msg = `PRICE must be moved to the first position` ).
  ENDMETHOD.

  METHOD when_technical_then_technical.
    " Given
    DATA(list) = new_list( )->column( name     = columns-price
                                      settings = VALUE #( is_technical = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_true( act = column_of( list = list
                                                       name = columns-price )->is_technical( )
                                      msg = `A technical column must never be shown` ).
  ENDMETHOD.

  METHOD when_display_set_then_applied.
    " Given
    DATA(list) = new_list( )->title( `Flights` )->striped( )->optimized( ).
    " When
    list->prepare( ).
    " Then
    DATA(display_settings) = list->salv->get_display_settings( ).
    cl_abap_unit_assert=>assert_equals( act = display_settings->get_list_header( )
                                        exp = CONV lvc_title( `Flights` )
                                        msg = `The title must be the list header` ).
    cl_abap_unit_assert=>assert_true( act = display_settings->is_striped_pattern( )
                                      msg = `STRIPED must give alternating colours` ).
    cl_abap_unit_assert=>assert_true( act = list->salv->get_columns( )->is_optimized( )
                                      msg = `OPTIMIZED must fit the widths of all columns` ).
  ENDMETHOD.

  METHOD when_layout_then_key_and_name.
    " Given
    DATA(list) = new_list( )->layout( VALUE #( name   = layout_values-name
                                               handle = layout_values-handle ) ).
    " When
    list->prepare( ).
    " Then
    DATA(layout) = list->salv->get_layout( ).
    cl_abap_unit_assert=>assert_equals( act = layout->get_key( )-handle
                                        exp = layout_values-handle
                                        msg = `The handle must be part of the layout key` ).
    cl_abap_unit_assert=>assert_equals( act = layout->get_initial_layout( )
                                        exp = layout_values-name
                                        msg = `The named layout must be shown at start` ).
  ENDMETHOD.

  METHOD when_end_of_list_then_set.
    " Given
    DATA(list) = new_list( )->end_of_list( VALUE #( lines = VALUE #( ( `Last line` ) ) ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_bound( act = list->salv->get_end_of_list( )
                                       msg = `The text below the list must be set` ).
  ENDMETHOD.

  METHOD when_excluded_then_sign_e.
    " Given
    DATA(list) = new_list( )->filter_by( name     = columns-airline
                                         settings = VALUE #( is_excluded = abap_true
                                                             low         = 'LH' ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = first_condition_of( list )->get_sign( )
                                        exp = filter_values-excluding
                                        msg = `An excluding condition must have sign E` ).
  ENDMETHOD.

  METHOD when_no_option_then_eq.
    " Given a condition without comparison
    DATA(list) = new_list( )->filter_by( name     = columns-airline
                                         settings = VALUE #( low = 'LH' ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = first_condition_of( list )->get_option( )
                                        exp = filter_values-equal
                                        msg = `A condition without comparison must compare with EQ` ).
  ENDMETHOD.

  METHOD when_empty_column_then_hidden.
    " Given REMARK, which is empty in every row
    DATA(list) = new_list( )->hide_empty_columns( ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_false( act = column_of( list = list
                                                        name = columns-remark )->is_visible( )
                                       msg = `A column empty in all rows must be hidden` ).
    cl_abap_unit_assert=>assert_true( act = column_of( list = list
                                                       name = columns-airline )->is_visible( )
                                      msg = `A column with values must stay visible` ).
  ENDMETHOD.

  METHOD when_no_rows_then_none_hidden.
    " Given a table without rows
    CLEAR flights.
    DATA(list) = new_list( )->hide_empty_columns( ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_true( act = column_of( list = list
                                                       name = columns-remark )->is_visible( )
                                      msg = `An empty table must not hide its columns` ).
  ENDMETHOD.

  METHOD when_error_then_column_in_msg.
    " Given
    DATA(list) = new_list( )->column( name     = columns-unknown
                                      settings = VALUE #( is_key = abap_true ) ).
    " When
    TRY.
        list->prepare( ).
        cl_abap_unit_assert=>fail( msg = `An unknown column must be rejected` ).
      CATCH zcx_salvage_error INTO DATA(error).
        " Then
        cl_abap_unit_assert=>assert_equals( act = CONV lvc_fname( error->if_t100_dyn_msg~msgv1 )
                                            exp = columns-unknown
                                            msg = `The message must name the unknown column` ).
        cl_abap_unit_assert=>assert_bound( act = error->previous
                                           msg = `The exception of SALV must be kept as PREVIOUS` ).
    ENDTRY.
  ENDMETHOD.

  METHOD when_not_shown_then_no_rows.
    " Given a list whose SALV exists but was never shown
    DATA(list) = new_list( )->selection( zcl_salvage=>selection_modes-multiple ).
    list->prepare( ).
    " When
    list->refresh( ).
    DATA(rows) = list->selected_rows( ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = rows
                                         msg = `Before DISPLAY no row can be selected` ).
  ENDMETHOD.

  METHOD when_unknown_color_then_raises.
    " Given
    DATA(list) = new_list( )->colors_from( columns-unknown ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-unknown_column
                                        msg = `An unknown colour column must be reported as unknown` ).
  ENDMETHOD.

  METHOD when_case_twice_then_raises.
    " Given the same button name in lower and in upper case
    DATA(list) = new_list( )->button( name     = 'first'
                                      settings = VALUE #( text = `Lower` )
                           )->button( name     = buttons-first
                                      settings = VALUE #( text = `Upper` ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-duplicate_button
                                        msg = `Button names must not depend on case` ).
  ENDMETHOD.

  METHOD when_buttons_then_slots_known.
    " Given a full screen list with two own buttons
    DATA(list) = two_button_list( ).
    " When
    list->prepare( ).
    " Then the functions of GUI status SALVAGE_FULLSCREEN are known to SALV; whether a slot is
    " hidden cannot be read back, CL_SALV_FUNCTION has no getter for it
    cl_abap_unit_assert=>assert_bound( act = function_of( list = list
                                                          name = slots-second )
                                       msg = `GUI status SALVAGE_FULLSCREEN of ZSALVAGE_GUI must be set` ).
    cl_abap_unit_assert=>assert_bound( act = function_of( list = list
                                                          name = slots-third )
                                       msg = `The status must offer the unused slots too` ).
  ENDMETHOD.

  METHOD when_link_click_then_handler.
    " Given
    DATA(handler) = NEW ltd_handler( ).
    DATA(list) = new_list( )->handled_by( handler ).
    " When SALV reports a click on a hotspot
    list->on_salv_link_click( row    = 2
                              column = columns-airline ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = handler->row
                                        exp = 2
                                        msg = `The handler must get the row` ).
    cl_abap_unit_assert=>assert_equals( act = handler->column
                                        exp = columns-airline
                                        msg = `The handler must get the column` ).
  ENDMETHOD.

  METHOD when_slot_click_then_button.
    " Given a full screen list with two own buttons
    DATA(handler) = NEW ltd_handler( ).
    DATA(list) = two_button_list( )->handled_by( handler ).
    " When SALV reports the function of the second slot
    list->on_salv_added_function( slots-second ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = handler->button
                                        exp = buttons-second
                                        msg = `The handler must get the name of the second button` ).
  ENDMETHOD.

  METHOD when_total_click_then_ignored.
    " Given
    DATA(handler) = NEW ltd_handler( ).
    DATA(list) = new_list( )->handled_by( handler ).
    " When SALV reports clicks on a total line, which come as row 0
    list->on_salv_link_click( row    = 0
                              column = columns-occupied ).
    list->on_salv_double_click( row    = 0
                                column = columns-occupied ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = handler->column
                                         msg = `A click on a total line must not reach the handler` ).
  ENDMETHOD.

  METHOD when_no_handler_then_no_dump.
    " Given a list whose handler was cleared
    DATA no_handler TYPE REF TO zif_salvage_events.
    DATA(list) = new_list( )->handled_by( no_handler ).
    " When SALV reports a double-click
    TRY.
        list->on_salv_double_click( row    = 1
                                    column = columns-airline ).
      CATCH cx_sy_ref_is_initial.
        " Then
        cl_abap_unit_assert=>fail( msg = `An event without handler must do nothing` ).
    ENDTRY.
  ENDMETHOD.

  METHOD when_slot_then_button_name.
    " Given a full screen list with two own buttons
    DATA(list) = two_button_list( ).
    " When the function of the second slot of GUI status SALVAGE_FULLSCREEN comes
    DATA(name) = list->button_name( 'SALVAGE02' ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = name
                                        exp = buttons-second
                                        msg = `Slot 2 must be reported as the second button` ).
  ENDMETHOD.

  METHOD when_container_then_same_name.
    " Given a list in a container, where SALV reports own buttons by their own names
    DATA no_container TYPE REF TO cl_gui_container.
    DATA(list) = two_button_list( )->in_container( no_container ).
    " When
    DATA(name) = list->button_name( buttons-second ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = name
                                        exp = buttons-second
                                        msg = `A button name in a container must pass unchanged` ).
  ENDMETHOD.

  METHOD when_unused_slot_then_no_text.
    " Given
    DATA(list) = two_button_list( ).
    " When
    DATA(text) = list->slot_text( 3 ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = text
                                         msg = `A slot without button must have no text` ).
  ENDMETHOD.

  METHOD when_slot_text_then_dyntxt.
    DATA dynamic_text TYPE smp_dyntxt.

    " Given
    DATA(list) = two_button_list( ).
    " When the text of the first slot is laid out like SMP_DYNTXT
    dynamic_text = list->slot_text( 1 ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = CONV string( dynamic_text-text )
                                        exp = `First`
                                        msg = `The slot must show the button text` ).
    cl_abap_unit_assert=>assert_equals( act = dynamic_text-icon_id
                                        exp = icon_okay
                                        msg = `The slot must show the button icon` ).
    cl_abap_unit_assert=>assert_equals( act = CONV string( dynamic_text-quickinfo )
                                        exp = `Quick info of the first button`
                                        msg = `The slot must show the quick info` ).
  ENDMETHOD.

  METHOD when_version_then_semantic.
    DATA numbers TYPE string_table.

    " Given the version of this release
    DATA(version) = zcl_salvage=>version.
    " When it is split into its numbers
    SPLIT version AT version_format-separator INTO TABLE numbers.
    " Then
    cl_abap_unit_assert=>assert_equals( act = lines( numbers )
                                        exp = version_format-parts
                                        msg = |VERSION { version } must be major.minor.patch| ).
    LOOP AT numbers INTO DATA(number).
      cl_abap_unit_assert=>assert_true(
          act = xsdbool( number IS NOT INITIAL AND number CO version_format-digits )
          msg = |VERSION { version } must hold only numbers between the dots| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD when_fixed_and_ref_then_raises.
    " Given a fixed currency and a currency column for the same column
    DATA(list) = new_list( )->column( name     = columns-price
                                      settings = VALUE #( currency_column = columns-currency
                                                          currency        = fixed_values-currency ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-fixed_and_column
                                        msg = `A fixed currency next to a currency column must be rejected` ).
  ENDMETHOD.

  METHOD when_fixed_split_then_raises.
    " Given a unit column and a fixed unit in two calls for the same column
    DATA(list) = new_list( )->column( name     = columns-occupied
                                      settings = VALUE #( unit_column = columns-currency )
                           )->column( name     = columns-occupied
                                      settings = VALUE #( unit = fixed_values-unit ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-fixed_and_column
                                        msg = `A fixed unit next to a unit column of another call must be rejected` ).
  ENDMETHOD.

  METHOD when_batch_then_full_screen.
    " Given a list for a container that runs in a background job, with more buttons than full
    " screen offers and without a container, as on a selection screen that was never shown
    DATA no_container TYPE REF TO cl_gui_container.
    DATA(list) = new_list( )->in_container( no_container ).
    DO 11 TIMES.
      list->button( name     = |BUTTON_{ sy-index }|
                    settings = VALUE #( text = |{ sy-index }| ) ).
    ENDDO.
    list->in_background = abap_true.
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = message
                                         msg = `A container list in a background job must not be rejected` ).
    cl_abap_unit_assert=>assert_equals( act = list->output
                                        exp = zcl_salvage=>output_modes-fullscreen
                                        msg = `A container list in a background job must be shown in full screen` ).
  ENDMETHOD.

  METHOD when_fixed_currency_then_set.
    " Given
    DATA(list) = new_list( )->column( name     = columns-price
                                      settings = VALUE #( currency = fixed_values-currency ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = column_of( list = list
                                                         name = columns-price )->get_currency( )
                                        exp = fixed_values-currency
                                        msg = `The fixed currency must be the currency of the column` ).
  ENDMETHOD.

  METHOD when_fixed_unit_then_set.
    " Given
    DATA(list) = new_list( )->column( name     = columns-occupied
                                      settings = VALUE #( unit = fixed_values-unit ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = column_of( list = list
                                                         name = columns-occupied )->get_quantity( )
                                        exp = fixed_values-unit
                                        msg = `The fixed unit must be the unit of the column` ).
  ENDMETHOD.

  METHOD when_fixed_keys_then_frozen.
    " Given
    DATA(list) = new_list( )->fixed_key_columns( ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_true( act = list->salv->get_columns( )->has_key_fixation( )
                                      msg = `The key columns must stay in place when scrolling` ).
  ENDMETHOD.

  METHOD when_save_off_then_default.
    " Given a list whose layouts cannot be saved
    DATA(list) = new_list( )->layout( VALUE #( is_save_disabled = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_true( act = list->salv->get_layout( )->has_default( )
                                      msg = `The default layout of the user must still be loaded` ).
  ENDMETHOD.

  METHOD when_subtotals_then_set.
    " Given
    DATA(list) = new_list( )->sort_by( name     = columns-airline
                                       settings = VALUE #( has_subtotals = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_true( act = list->salv->get_sorts( )->get_sort( columns-airline )->is_subtotalled( )
                                      msg = `The sort criterion must have subtotals` ).
  ENDMETHOD.

  METHOD when_single_then_single_mode.
    " Given
    DATA(list) = new_list( )->selection( zcl_salvage=>selection_modes-single ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = list->salv->get_selections( )->get_selection_mode( )
                                        exp = if_salv_c_selection_mode=>single
                                        msg = `Single selection must select one row at a time` ).
  ENDMETHOD.

  METHOD when_cells_then_cell_mode.
    " Given
    DATA(list) = new_list( )->selection( zcl_salvage=>selection_modes-cells ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = list->salv->get_selections( )->get_selection_mode( )
                                        exp = if_salv_c_selection_mode=>cell
                                        msg = `Cell selection must select cells` ).
  ENDMETHOD.

  METHOD when_between_then_high.
    " Given
    DATA(list) = new_list( )->filter_by( name     = columns-airline
                                         settings = VALUE #( option = between-option
                                                             low    = between-low
                                                             high   = between-high ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = first_condition_of( list )->get_high( )
                                        exp = between-high
                                        msg = `The upper value must be handed to the filter` ).
  ENDMETHOD.

  METHOD when_hotspot_later_then_both.
    " Given a checkbox column that a later call makes a hotspot too
    DATA(list) = new_list( )->column( name     = columns-light
                                      settings = VALUE #( is_checkbox = abap_true )
                           )->column( name     = columns-light
                                      settings = VALUE #( is_hotspot = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = column_of( list = list
                                                         name = columns-light )->get_cell_type( )
                                        exp = if_salv_c_cell_type=>checkbox_hotspot
                                        msg = `A hotspot from a later call must keep the checkbox` ).
  ENDMETHOD.

  METHOD when_checkbox_later_then_both.
    " Given a hotspot column that a later call makes a checkbox too
    DATA(list) = new_list( )->column( name     = columns-light
                                      settings = VALUE #( is_hotspot = abap_true )
                           )->column( name     = columns-light
                                      settings = VALUE #( is_checkbox = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = column_of( list = list
                                                         name = columns-light )->get_cell_type( )
                                        exp = if_salv_c_cell_type=>checkbox_hotspot
                                        msg = `A checkbox from a later call must keep the hotspot` ).
  ENDMETHOD.

  METHOD when_double_click_then_handler.
    " Given
    DATA(handler) = NEW ltd_handler( ).
    DATA(list) = new_list( )->handled_by( handler ).
    " When SALV reports a double-click
    list->on_salv_double_click( row    = 1
                                column = columns-occupied ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = handler->row
                                        exp = 1
                                        msg = `The handler must get the row` ).
    cl_abap_unit_assert=>assert_equals( act = handler->column
                                        exp = columns-occupied
                                        msg = `The handler must get the column` ).
  ENDMETHOD.

  METHOD when_icon_only_then_menu_tip.
    DATA dynamic_text TYPE smp_dyntxt.

    " Given a button with an icon and a quick info, but without text
    DATA(list) = new_list( )->button( name     = buttons-first
                                      settings = VALUE #( icon    = icon_okay
                                                          tooltip = `Quick info only` ) ).
    " When
    dynamic_text = list->slot_text( 1 ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = CONV string( dynamic_text-text )
                                        exp = `Quick info only`
                                        msg = `The menu must show the quick info of a button without text` ).
    cl_abap_unit_assert=>assert_initial( act = dynamic_text-icon_text
                                         msg = `The toolbar must show the icon without text` ).
  ENDMETHOD.

  METHOD when_no_text_then_menu_name.
    DATA dynamic_text TYPE smp_dyntxt.

    " Given a button with an icon only
    DATA(list) = new_list( )->button( name     = buttons-first
                                      settings = VALUE #( icon = icon_okay ) ).
    " When
    dynamic_text = list->slot_text( 1 ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = CONV salv_de_function( dynamic_text-text )
                                        exp = buttons-first
                                        msg = `The menu must show the name of a button without text and quick info` ).
  ENDMETHOD.

  METHOD when_export_off_then_hidden.
    " Given
    DATA(list) = new_list( )->toolbar( VALUE #( is_export_disabled = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_false( act = is_offered( list     = list
                                                         function = if_salv_c_function=>export_spreadsheet )
                                       msg = `The spreadsheet export must be hidden` ).
    cl_abap_unit_assert=>assert_false( act = is_offered( list     = list
                                                         function = if_salv_c_function=>export_localfile )
                                       msg = `The local file export must be hidden` ).
    cl_abap_unit_assert=>assert_false( act = is_offered( list     = list
                                                         function = if_salv_c_function=>view_excel )
                                       msg = `The view in Excel must be hidden` ).
    cl_abap_unit_assert=>assert_true( act = is_offered( list     = list
                                                        function = if_salv_c_function=>print_preview )
                                      msg = `The print preview must stay when only the export is off` ).
  ENDMETHOD.

  METHOD when_print_off_then_hidden.
    " Given
    DATA(list) = new_list( )->toolbar( VALUE #( is_print_disabled = abap_true ) ).
    " When
    list->prepare( ).
    " Then the print preview is hidden. Printing itself cannot be checked here: the function
    " list of SALV does not know it, IS_VISIBLE raises CX_SALV_OBJECT_NOT_FOUND for it
    cl_abap_unit_assert=>assert_false( act = is_offered( list     = list
                                                         function = if_salv_c_function=>print_preview )
                                       msg = `The print preview must be hidden` ).
    cl_abap_unit_assert=>assert_true( act = is_offered( list     = list
                                                        function = if_salv_c_function=>export_spreadsheet )
                                      msg = `The export must stay when only printing is off` ).
  ENDMETHOD.

  METHOD when_toolbar_then_others_kept.
    " Given a full screen list with own buttons and neither export nor printing
    DATA(list) = two_button_list( )->toolbar( VALUE #( is_export_disabled = abap_true
                                                       is_print_disabled  = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_true( act = is_offered( list     = list
                                                        function = if_salv_c_function=>sort_asc )
                                      msg = `Sorting must stay` ).
    cl_abap_unit_assert=>assert_true( act = is_offered( list     = list
                                                        function = if_salv_c_function=>filter )
                                      msg = `Filtering must stay` ).
    cl_abap_unit_assert=>assert_bound( act = function_of( list = list
                                                          name = slots-second )
                                       msg = `The own buttons must stay` ).
  ENDMETHOD.

  METHOD when_not_shown_then_no_columns.
    " Given a list whose SALV exists but was never shown
    DATA(list) = new_list( )->selection( zcl_salvage=>selection_modes-cells ).
    list->prepare( ).
    " When
    DATA(selected) = list->selected_columns( ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = selected
                                         msg = `Before DISPLAY no column can be selected` ).
  ENDMETHOD.

  METHOD when_unknown_layout_then_false.
    " When
    DATA(exists) = zcl_salvage=>layout_exists( layout_values-missing ).
    " Then
    cl_abap_unit_assert=>assert_false( act = exists
                                       msg = `A layout that was never saved must not exist` ).
  ENDMETHOD.

  METHOD when_no_layout_name_then_false.
    DATA no_name TYPE slis_vari.

    " When
    DATA(exists) = zcl_salvage=>layout_exists( no_name ).
    " Then
    cl_abap_unit_assert=>assert_false( act = exists
                                       msg = `An initial name must not count as a saved layout` ).
  ENDMETHOD.

  METHOD when_closed_then_shown_again.
    " Given a fullscreen list that was shown and that the user has left
    DATA(list) = new_list( ).
    list->is_displayed = abap_true.
    list->is_open = abap_false.
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = message
                                         msg = `A list the user has left must be displayable again` ).
  ENDMETHOD.

  METHOD when_shown_again_then_new_salv.
    " Given a list that was shown and that the user has left
    DATA(list) = new_list( ).
    list->is_displayed = abap_true.
    " When it is prepared for another display
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_false( act = list->is_displayed
                                       msg = `The SALV of another DISPLAY was not shown yet` ).
  ENDMETHOD.

  METHOD when_blank_button_then_raises.
    " Given
    DATA(list) = new_list( )->button( name     = ``
                                      settings = VALUE #( text = `No name` ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-no_button_name
                                        msg = `A button without a name must be rejected` ).
  ENDMETHOD.

  METHOD when_descending_then_sort_down.
    " Given
    DATA(list) = new_list( )->sort_by( name     = columns-airline
                                       settings = VALUE #( is_descending = abap_true ) ).
    " When
    list->prepare( ).
    " Then SALV got the order its own constant stands for. IF_SALV_C_SORT is not classic API;
    " test class only
    DATA(criterion) = list->salv->get_sorts( )->get_sort( columns-airline ).
    cl_abap_unit_assert=>assert_equals( act = criterion->get_sequence( )
                                        exp = if_salv_c_sort=>sort_down
                                        msg = `The sort criterion must be descending` ).
  ENDMETHOD.

  METHOD when_no_order_then_sort_up.
    " Given
    DATA(list) = new_list( )->sort_by( columns-airline ).
    " When
    list->prepare( ).
    " Then
    DATA(criterion) = list->salv->get_sorts( )->get_sort( columns-airline ).
    cl_abap_unit_assert=>assert_equals( act = criterion->get_sequence( )
                                        exp = if_salv_c_sort=>sort_up
                                        msg = `Without a setting the sort criterion must be ascending` ).
  ENDMETHOD.

  METHOD when_layout_program_then_key.
    " Given
    DATA(list) = new_list( )->layout( VALUE #( program = layout_values-program ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = list->salv->get_layout( )->get_key( )-report
                                        exp = layout_values-program
                                        msg = `The layouts must be kept for the program given` ).
  ENDMETHOD.

  METHOD when_no_program_then_own_key.
    " Given
    DATA(list) = new_list( ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = list->salv->get_layout( )->get_key( )-report
                                        exp = sy-cprog
                                        msg = `Without a program the layouts must be kept for the calling one` ).
  ENDMETHOD.

  METHOD when_select_rows_then_existing.
    " Given a table of two rows and a selection with an index before and one after them
    DATA(list) = new_list( )->select_rows( VALUE #( ( 0 ) ( 2 ) ( 3 ) ) ).
    " When
    DATA(selectable) = list->selectable_rows( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = selectable
                                        exp = VALUE salv_t_row( ( 2 ) )
                                        msg = `Only indexes of rows of the table must be selected` ).
  ENDMETHOD.

  METHOD when_select_rows_then_accepted.
    " Given
    DATA(list) = new_list( )->selection( zcl_salvage=>selection_modes-multiple
                           )->select_rows( VALUE #( ( 1 ) ( 2 ) ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = message
                                         msg = `Rows selected before DISPLAY must not be rejected` ).
  ENDMETHOD.

  METHOD when_no_number_then_raises.
    " Given a filter on a number column with a value that is no number
    DATA(list) = new_list( )->filter_by( name     = columns-occupied
                                         settings = VALUE #( option = 'GT'
                                                             low    = 'ABC' ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-filter_value
                                        msg = `Text as filter value of a number column must be rejected` ).
  ENDMETHOD.

  METHOD when_bad_high_then_raises.
    " Given a range whose upper value has a decimal comma
    DATA(list) = new_list( )->filter_by( name     = columns-load
                                         settings = VALUE #( option = between-option
                                                             low    = '10'
                                                             high   = '12,5' ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-filter_value
                                        msg = `An upper value that is no number must be rejected` ).
  ENDMETHOD.

  METHOD when_numc_letters_then_raises.
    " Given a filter on CONNID, a column of type N
    DATA(list) = new_list( )->filter_by( name     = columns-flight
                                         settings = VALUE #( low = '04A0' ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-filter_value
                                        msg = `A letter in the filter value of a column of type N must be rejected` ).
  ENDMETHOD.

  METHOD when_number_filter_then_valid.
    " Given a number as filter value, and no upper value
    DATA(list) = new_list( )->filter_by( name     = columns-occupied
                                         settings = VALUE #( option = 'GT'
                                                             low    = '100' ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = message
                                         msg = `A number as filter value must not be rejected` ).
  ENDMETHOD.

  METHOD when_pattern_then_not_checked.
    " Given a pattern for a number column, in lower case
    DATA(list) = new_list( )->filter_by( name     = columns-occupied
                                         settings = VALUE #( option = 'cp'
                                                             low    = '1*' ) ).
    " When only the values are checked; what SALV does with the pattern is not the point here
    TRY.
        list->check_filter_values( ).
      CATCH zcx_salvage_error.
        " Then
        cl_abap_unit_assert=>fail( msg = `The pattern of a CP comparison must not be checked as a number` ).
    ENDTRY.
  ENDMETHOD.

  METHOD when_no_status_then_raises.
    " Given a full screen list with own buttons, and a GUI status that does not exist
    DATA(list) = two_button_list( ).
    list->fullscreen_status = no_status.
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-missing_status
                                        msg = `A missing GUI status must be reported with a message, not a dump` ).
  ENDMETHOD.

  METHOD when_unchecked_box_then_shown.
    " Given PICKED, a checkbox that is ticked in no row
    DATA(list) = new_list( )->hide_empty_columns( )->column( name     = columns-picked
                                                             settings = VALUE #( is_checkbox = abap_true ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_true( act = column_of( list = list
                                                       name = columns-picked )->is_visible( )
                                      msg = `A checkbox column without a tick must not be hidden as empty` ).
  ENDMETHOD.

  METHOD when_unknown_code_then_ignored.
    " Given a full screen list with two own buttons
    DATA(handler) = NEW ltd_handler( ).
    DATA(list) = two_button_list( )->handled_by( handler ).
    " When SALV reports a code that is no own button, and the function of an unused slot
    list->on_salv_added_function( typed_code ).
    list->on_salv_added_function( slots-third ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = handler->button
                                         msg = `A function code that is no own button must not reach the handler` ).
  ENDMETHOD.

  METHOD when_position_beyond_then_last.
    " Given a position after the last column
    DATA(list) = new_list( )->column( name     = columns-price
                                      settings = VALUE #( position = 99 ) ).
    " When
    list->prepare( ).
    " Then
    DATA(columns_of_list) = list->salv->get_columns( ).
    cl_abap_unit_assert=>assert_equals( act = columns_of_list->get_column_position( columns-price )
                                        exp = lines( columns_of_list->get( ) )
                                        msg = `A position after the last column must be the last one` ).
  ENDMETHOD.

  METHOD when_two_positions_then_both.
    " Given the second position before the first
    DATA(list) = new_list( )->column( name     = columns-remark
                                      settings = VALUE #( position = 2 )
                           )->column( name     = columns-price
                                      settings = VALUE #( position = 1 ) ).
    " When
    list->prepare( ).
    " Then
    DATA(columns_of_list) = list->salv->get_columns( ).
    cl_abap_unit_assert=>assert_equals( act = columns_of_list->get_column_position( columns-price )
                                        exp = 1
                                        msg = `PRICE must be the first column` ).
    cl_abap_unit_assert=>assert_equals( act = columns_of_list->get_column_position( columns-remark )
                                        exp = 2
                                        msg = `REMARK must stay the second column, whatever the order of the calls` ).
  ENDMETHOD.

  METHOD when_left_moves_then_both_fit.
    " Given CARRID, the first column, moved to the right of another column with a position
    DATA(list) = new_list( )->column( name     = columns-airline
                                      settings = VALUE #( position = 4 )
                           )->column( name     = columns-price
                                      settings = VALUE #( position = 2 ) ).
    " When
    list->prepare( ).
    " Then
    DATA(columns_of_list) = list->salv->get_columns( ).
    cl_abap_unit_assert=>assert_equals( act = columns_of_list->get_column_position( columns-price )
                                        exp = 2
                                        msg = `PRICE must not move when CARRID leaves the first position` ).
    cl_abap_unit_assert=>assert_equals( act = columns_of_list->get_column_position( columns-airline )
                                        exp = 4
                                        msg = `CARRID must be the fourth column` ).
  ENDMETHOD.

  METHOD when_position_twice_then_last.
    " Given two positions for the same column, the lower one in the later call
    DATA(list) = new_list( )->column( name     = columns-price
                                      settings = VALUE #( position = 5 )
                           )->column( name     = columns-price
                                      settings = VALUE #( position = 2 ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = list->salv->get_columns( )->get_column_position( columns-price )
                                        exp = 2
                                        msg = `The position of the last call must count` ).
  ENDMETHOD.

  METHOD when_unit_and_curr_then_raises.
    " Given a fixed unit and a fixed currency for the same column
    DATA(list) = new_list( )->column( name     = columns-occupied
                                      settings = VALUE #( unit     = fixed_values-unit
                                                          currency = fixed_values-currency ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-fixed_and_column
                                        msg = `A column with a unit and a currency must be rejected` ).
  ENDMETHOD.

  METHOD when_both_ref_cols_then_raises.
    " Given a unit column and a currency column in two calls for the same column
    DATA(list) = new_list( )->column( name     = columns-price
                                      settings = VALUE #( unit_column = columns-currency )
                           )->column( name     = columns-price
                                      settings = VALUE #( currency_column = columns-currency ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-fixed_and_column
                                        msg = `A unit column next to a currency column must be rejected` ).
  ENDMETHOD.

  METHOD when_wide_checkbox_then_raises.
    " Given REMARK, a column of type C length 20
    DATA(list) = new_list( )->column( name     = columns-remark
                                      settings = VALUE #( is_checkbox = abap_true ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-checkbox_column
                                        msg = `A checkbox column not of type C length 1 must be rejected` ).
  ENDMETHOD.

  METHOD when_stale_row_then_ignored.
    " Given a table of two rows
    DATA(handler) = NEW ltd_handler( ).
    DATA(list) = new_list( )->handled_by( handler ).
    " When SALV reports clicks on a third row, as after a row was deleted without a refresh
    list->on_salv_link_click( row    = 3
                              column = columns-airline ).
    list->on_salv_double_click( row    = 3
                                column = columns-airline ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = handler->column
                                         msg = `A click on a row the table does not have must not reach the handler` ).
  ENDMETHOD.

  METHOD when_no_text_icon_then_tooltip.
    " Given a button for a container with a quick info only
    DATA(list) = new_list( ).
    " When
    DATA(text) = list->container_button_text( VALUE #( name     = buttons-first
                                                       settings = VALUE #( tooltip = `Quick info only` ) ) ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = text
                                        exp = `Quick info only`
                                        msg = `A button without text and icon must show its quick info as text` ).
  ENDMETHOD.

  METHOD when_name_only_then_name_text.
    " Given a button for a container with a name only
    DATA(list) = new_list( ).
    " When
    DATA(text) = list->container_button_text( VALUE #( name = buttons-first ) ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = text
                                        exp = CONV string( buttons-first )
                                        msg = `A button without text, icon and quick info must show its name` ).
  ENDMETHOD.

  METHOD when_icon_only_then_no_text.
    " Given a button for a container with an icon and a quick info
    DATA(list) = new_list( ).
    " When
    DATA(text) = list->container_button_text( VALUE #( name     = buttons-first
                                                       settings = VALUE #( icon    = icon_okay
                                                                           tooltip = `Quick info only` ) ) ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = text
                                         msg = `A button with an icon must stay a button with the icon only` ).
  ENDMETHOD.

  METHOD when_batch_then_no_buttons.
    " Given a full screen list with own buttons that runs in a background job
    DATA(list) = two_button_list( ).
    list->in_background = abap_true.
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_initial( act = message
                                         msg = `A list with own buttons in a background job must not be rejected` ).
    cl_abap_unit_assert=>assert_initial( act = list->buttons
                                         msg = `In a background job a list must have no own buttons` ).
  ENDMETHOD.

  METHOD when_missing_exit_then_raises.
    " Given a conversion exit that has no function module
    DATA(list) = new_list( )->column( name     = columns-airline
                                      settings = VALUE #( edit_mask = missing_exit_mask ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-missing_exit
                                        msg = `A conversion exit without function module must be rejected` ).
  ENDMETHOD.

  METHOD when_long_exit_then_raises.
    " Given a name that starts like the exit ALPHA but is longer than a function module name
    DATA(list) = new_list( )->column( name     = columns-airline
                                      settings = VALUE #( edit_mask = long_exit_mask ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-missing_exit
                                        msg = `An exit name that is too long must not be cut to one that exists` ).
  ENDMETHOD.

  METHOD when_lower_exit_then_upper.
    " Given
    DATA(list) = new_list( )->column( name     = columns-airline
                                      settings = VALUE #( edit_mask = lower_alpha_mask ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = column_of( list = list
                                                         name = columns-airline )->get_edit_mask( )
                                        exp = alpha_mask
                                        msg = `The name of a conversion exit must reach SALV in upper case` ).
  ENDMETHOD.

  METHOD when_template_mask_then_kept.
    " Given a template, which names no conversion exit
    DATA(list) = new_list( )->column( name     = columns-airline
                                      settings = VALUE #( edit_mask = template_mask ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = column_of( list = list
                                                         name = columns-airline )->get_edit_mask( )
                                        exp = template_mask
                                        msg = `A template must reach SALV as it was written` ).
  ENDMETHOD.

  METHOD when_hashed_table_then_raises.
    " Given
    DATA(hashed) = VALUE hashed_flights( ).
    DATA(list) = zcl_salvage=>create( REF #( hashed ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-unsupported_table
                                        msg = `A hashed table must be rejected` ).
  ENDMETHOD.

  METHOD when_structure_ref_then_raises.
    " Given a reference to one row instead of a table
    DATA(one_flight) = VALUE flight( ).
    DATA(list) = zcl_salvage=>create( REF #( one_flight ) ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-unsupported_table
                                        msg = `A reference to a structure must be rejected` ).
  ENDMETHOD.

  METHOD when_bad_total_col_then_raises.
    " Given
    DATA(list) = new_list( )->total( columns-unknown ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-unknown_column
                                        msg = `TOTAL of an unknown column must be rejected` ).
  ENDMETHOD.

  METHOD when_unknown_light_then_raises.
    " Given
    DATA(list) = new_list( )->lights_from( columns-unknown ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-unknown_column
                                        msg = `An unknown light column must be reported as unknown` ).
  ENDMETHOD.

  METHOD when_total_twice_then_raises.
    " Given
    DATA(list) = new_list( )->total( columns-occupied )->total( columns-occupied ).
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-total_error
                                        msg = `Two totals of the same column must be rejected` ).
  ENDMETHOD.

  METHOD when_lower_option_then_valid.
    " Given a comparison in lower case
    DATA(list) = new_list( )->filter_by( name     = columns-airline
                                         settings = VALUE #( option = 'bt'
                                                             low    = between-low
                                                             high   = between-high ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = first_condition_of( list )->get_option( )
                                        exp = between-option
                                        msg = `A comparison in lower case must be handed to SALV in upper case` ).
  ENDMETHOD.

  METHOD when_buttons_then_ten_slots.
    " Given a full screen list with two own buttons
    DATA(list) = two_button_list( ).
    " When the texts of all slots of GUI status SALVAGE_FULLSCREEN are built
    DATA(texts) = list->fullscreen_texts( ).
    " Then
    cl_abap_unit_assert=>assert_not_initial( act = texts-f02
                                             msg = `The slot of the second button must have its text` ).
    cl_abap_unit_assert=>assert_initial( act = texts-f03
                                         msg = `The first slot without button must have no text` ).
    cl_abap_unit_assert=>assert_initial( act = texts-f10
                                         msg = `The last slot of the status must exist and have no text` ).
  ENDMETHOD.

  METHOD when_late_handler_then_no_dump.
    " Given a list that is on the screen, as a list in a container after DISPLAY
    DATA(handler) = NEW ltd_handler( ).
    DATA(list) = new_list( ).
    list->prepare( ).
    list->is_open = abap_true.
    " When the handler is set only now, and SALV reports a click
    list->handled_by( handler ).
    list->on_salv_link_click( row    = 1
                              column = columns-airline ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = handler->column
                                        exp = columns-airline
                                        msg = `A handler set after DISPLAY must get the clicks` ).
  ENDMETHOD.

  METHOD when_lower_program_then_upper.
    " Given the program of the layouts in lower case
    DATA(list) = new_list( )->layout( VALUE #( program = 'zsalvage_shared_list' ) ).
    " When
    list->prepare( ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = list->salv->get_layout( )->get_key( )-report
                                        exp = layout_values-program
                                        msg = `The program of the layout key must be in upper case` ).
  ENDMETHOD.
ENDCLASS.
