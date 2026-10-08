" SALVage demo 03: events and own buttons in a fullscreen list. A click on an airline, or the
" button Flights, shows the flights in a dialog box; the button Remove takes rows off the list.
REPORT zsalvage_demo_03.

CLASS lcl_demo DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salvage_events.

    METHODS run
      RAISING zcx_salvage_error.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF carrier,
        carrid   TYPE scarr-carrid,
        carrname TYPE scarr-carrname,
        currcode TYPE scarr-currcode,
      END OF carrier.
    TYPES carrier_rows TYPE STANDARD TABLE OF carrier WITH EMPTY KEY.

    TYPES:
      BEGIN OF flight,
        carrid   TYPE sflight-carrid,
        connid   TYPE sflight-connid,
        fldate   TYPE sflight-fldate,
        price    TYPE sflight-price,
        currency TYPE sflight-currency,
        seatsocc TYPE sflight-seatsocc,
      END OF flight.
    TYPES flight_rows TYPE STANDARD TABLE OF flight WITH EMPTY KEY.

    TYPES airline_range TYPE RANGE OF s_carr_id.

    CONSTANTS:
      BEGIN OF button_name,
        flights TYPE salv_de_function VALUE 'FLIGHTS',
        remove  TYPE salv_de_function VALUE 'REMOVE',
      END OF button_name.

    CONSTANTS airline_column TYPE lvc_fname VALUE 'CARRID'.

    CONSTANTS:
      BEGIN OF select_option,
        including TYPE ddsign   VALUE 'I',
        equal     TYPE ddoption VALUE 'EQ',
      END OF select_option.

    CONSTANTS:
      BEGIN OF message_type,
        status TYPE sy-msgty VALUE 'S',
        error  TYPE sy-msgty VALUE 'E',
      END OF message_type.

    DATA carriers TYPE carrier_rows.
    DATA alv      TYPE REF TO zcl_salvage.

    METHODS read_carriers
      RETURNING VALUE(result) TYPE carrier_rows.

    METHODS read_flights
      IMPORTING airlines      TYPE airline_range
      RETURNING VALUE(result) TYPE flight_rows.

    METHODS airlines_of_rows
      IMPORTING rows          TYPE zcl_salvage=>row_indexes
      RETURNING VALUE(result) TYPE airline_range.

    METHODS show_flights
      IMPORTING airlines TYPE airline_range.

    METHODS remove_rows
      IMPORTING rows TYPE zcl_salvage=>row_indexes.
ENDCLASS.


CLASS lcl_demo IMPLEMENTATION.
  METHOD run.
    carriers = read_carriers( ).
    alv = zcl_salvage=>create( REF #( carriers )
                     )->title( TEXT-t01
                     )->column( name     = airline_column
                                settings = VALUE #( is_hotspot = abap_true )
                     )->selection( zcl_salvage=>selection_modes-multiple
                     )->button( name     = button_name-flights
                                settings = VALUE #( text    = TEXT-b01
                                                    icon    = icon_display
                                                    tooltip = TEXT-q01 )
                     )->button( name     = button_name-remove
                                settings = VALUE #( text    = TEXT-b02
                                                    icon    = icon_delete_row
                                                    tooltip = TEXT-q02 )
                     )->handled_by( me ).
    alv->display( ).
  ENDMETHOD.

  METHOD zif_salvage_events~on_link_click.
    IF column = airline_column.
      show_flights( airlines_of_rows( VALUE #( ( row ) ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_salvage_events~on_button_click.
    " Without a selection, Flights shows the flights of all airlines and Remove does nothing
    DATA(rows) = alv->selected_rows( ).
    CASE button.
      WHEN button_name-flights.
        show_flights( airlines_of_rows( rows ) ).
      WHEN button_name-remove.
        remove_rows( rows ).
    ENDCASE.
  ENDMETHOD.

  METHOD read_carriers.
    " All airlines are wanted; SCARR holds a few dozen rows
    SELECT FROM scarr
      FIELDS carrid, carrname, currcode
      ORDER BY carrid
      INTO TABLE @result.                               "#EC CI_NOWHERE
  ENDMETHOD.

  METHOD read_flights.
    SELECT FROM sflight
      FIELDS carrid, connid, fldate, price, currency, seatsocc
      WHERE carrid IN @airlines
      ORDER BY carrid, connid, fldate
      INTO TABLE @result.
  ENDMETHOD.

  METHOD airlines_of_rows.
    result = VALUE #( FOR row IN rows
                      ( sign   = select_option-including
                        option = select_option-equal
                        low    = carriers[ row ]-carrid ) ).
  ENDMETHOD.

  METHOD show_flights.
    DATA(flights) = read_flights( airlines ).
    TRY.
        zcl_salvage=>create( REF #( flights ) )->title( TEXT-t02 )->popup( )->display( ).
      CATCH zcx_salvage_error INTO DATA(error).
        MESSAGE error TYPE message_type-status DISPLAY LIKE message_type-error.
    ENDTRY.
  ENDMETHOD.

  METHOD remove_rows.
    DATA(descending_rows) = rows.
    SORT descending_rows BY table_line DESCENDING.
    LOOP AT descending_rows INTO DATA(row).
      DELETE carriers INDEX row.
    ENDLOOP.
    alv->refresh( ).
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  NEW lcl_demo( )->run( ).
