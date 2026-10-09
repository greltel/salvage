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
      END OF flight.
    TYPES flight_rows TYPE STANDARD TABLE OF flight WITH EMPTY KEY.
    TYPES sorted_flights TYPE SORTED TABLE OF flight WITH UNIQUE KEY carrid connid.

    CONSTANTS:
      BEGIN OF columns,
        airline  TYPE lvc_fname VALUE 'CARRID',
        price    TYPE lvc_fname VALUE 'PRICE',
        currency TYPE lvc_fname VALUE 'CURRENCY',
        occupied TYPE lvc_fname VALUE 'SEATSOCC',
        load     TYPE lvc_fname VALUE 'LOAD',
        light    TYPE lvc_fname VALUE 'LIGHT',
        colors   TYPE lvc_fname VALUE 'COLORS',
        remark   TYPE lvc_fname VALUE 'REMARK',
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

    " Signs and comparisons of a filter condition
    CONSTANTS:
      BEGIN OF filter_values,
        excluding TYPE salv_de_selopt_sign   VALUE 'E',
        equal     TYPE salv_de_selopt_option VALUE 'EQ',
      END OF filter_values.

    CONSTANTS:
      BEGIN OF layout_values,
        name   TYPE slis_vari  VALUE '/TEST',
        handle TYPE slis_handl VALUE 'HEAD',
      END OF layout_values.

    CONSTANTS alpha_mask TYPE lvc_edtmsk VALUE '==ALPHA'.

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

    METHODS when_slot_then_button_name    FOR TESTING.
    METHODS when_container_then_same_name FOR TESTING.
    METHODS when_unused_slot_then_no_text FOR TESTING.
    METHODS when_slot_text_then_dyntxt    FOR TESTING.
    METHODS when_buttons_then_slots_known FOR TESTING.
    METHODS when_link_click_then_handler  FOR TESTING.
    METHODS when_slot_click_then_button   FOR TESTING.
    METHODS when_no_handler_then_no_dump  FOR TESTING.
    METHODS when_total_click_then_ignored FOR TESTING.

    METHODS when_version_then_semantic    FOR TESTING.
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
    " Given a list that is already shown
    DATA(list) = new_list( ).
    list->is_displayed = abap_true.
    " When
    DATA(message) = rejection_of( list ).
    " Then
    cl_abap_unit_assert=>assert_equals( act = message
                                        exp = messages-displayed_twice
                                        msg = `A list must not be displayed twice` ).
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
    " Given
    DATA(list) = new_list( )->column( name     = columns-airline
                                      settings = VALUE #( text = `Airline of the flight` ) ).
    " When
    list->prepare( ).
    " Then
    DATA(column) = column_of( list = list
                              name = columns-airline ).
    cl_abap_unit_assert=>assert_equals( act = column->get_long_text( )
                                        exp = CONV scrtext_l( `Airline of the flight` )
                                        msg = `The text must be the long header` ).
    cl_abap_unit_assert=>assert_equals( act = column->get_short_text( )
                                        exp = CONV scrtext_s( `Airline of the flight` )
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
ENDCLASS.
