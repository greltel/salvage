*"* use this source file for your ABAP unit test classes

CLASS ltc_salvage DEFINITION DEFERRED.
CLASS zcl_salvage DEFINITION LOCAL FRIENDS ltc_salvage.

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

    METHODS when_slot_then_button_name    FOR TESTING.
    METHODS when_container_then_same_name FOR TESTING.
    METHODS when_unused_slot_then_no_text FOR TESTING.
    METHODS when_slot_text_then_dyntxt    FOR TESTING.
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
ENDCLASS.
