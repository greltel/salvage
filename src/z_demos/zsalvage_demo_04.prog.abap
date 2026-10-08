" SALVage demo 04: a list in a docking container below the selection screen, with an own
" button in the toolbar of the list. Execute (F8) shows the flights of the airline entered.
REPORT zsalvage_demo_04.

PARAMETERS carrier TYPE s_carr_id.


CLASS lcl_cockpit DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salvage_events.

    METHODS show_carriers.

    METHODS show_flights
      IMPORTING airline TYPE s_carr_id.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF carrier,
        carrid   TYPE scarr-carrid,
        carrname TYPE scarr-carrname,
        url      TYPE scarr-url,
      END OF carrier.
    TYPES carrier_rows TYPE STANDARD TABLE OF carrier WITH EMPTY KEY.

    TYPES:
      BEGIN OF flight,
        connid   TYPE sflight-connid,
        fldate   TYPE sflight-fldate,
        price    TYPE sflight-price,
        currency TYPE sflight-currency,
        seatsmax TYPE sflight-seatsmax,
        seatsocc TYPE sflight-seatsocc,
      END OF flight.
    TYPES flight_rows TYPE STANDARD TABLE OF flight WITH EMPTY KEY.

    CONSTANTS flights_button TYPE salv_de_function VALUE 'FLIGHTS'.

    CONSTANTS:
      BEGIN OF list_handle,
        carriers TYPE slis_handl VALUE 'CARR',
        flights  TYPE slis_handl VALUE 'FLTS',
      END OF list_handle.

    " Height of the docking container in pixels
    CONSTANTS dock_height TYPE i VALUE 300.

    CONSTANTS:
      BEGIN OF message_type,
        status TYPE sy-msgty VALUE 'S',
        error  TYPE sy-msgty VALUE 'E',
      END OF message_type.

    DATA dock     TYPE REF TO cl_gui_docking_container.
    DATA carriers TYPE carrier_rows.
    DATA alv      TYPE REF TO zcl_salvage.

    METHODS read_carriers
      RETURNING VALUE(result) TYPE carrier_rows.

    METHODS read_flights
      IMPORTING airline       TYPE s_carr_id
      RETURNING VALUE(result) TYPE flight_rows.

    METHODS flights_list
      IMPORTING airline       TYPE s_carr_id
                flights       TYPE REF TO flight_rows
      RETURNING VALUE(result) TYPE REF TO zcl_salvage.

    METHODS show_flights_in_popup
      IMPORTING airline TYPE s_carr_id.

    METHODS show
      IMPORTING list TYPE REF TO zcl_salvage.
ENDCLASS.


CLASS lcl_cockpit IMPLEMENTATION.
  METHOD show_carriers.
    " Called at every display of the selection screen; the container is built once
    IF dock IS BOUND.
      RETURN.
    ENDIF.
    dock = NEW #( repid     = sy-repid
                  dynnr     = sy-dynnr
                  side      = cl_gui_docking_container=>dock_at_bottom
                  extension = dock_height ).
    carriers = read_carriers( ).
    alv = zcl_salvage=>create( REF #( carriers )
                     )->title( TEXT-t01
                     )->selection( zcl_salvage=>selection_modes-single
                     )->button( name     = flights_button
                                settings = VALUE #( text    = TEXT-b01
                                                    icon    = icon_display
                                                    tooltip = TEXT-q01 )
                     )->layout( VALUE #( handle = list_handle-carriers )
                     )->handled_by( me
                     )->in_container( dock ).
    show( alv ).
  ENDMETHOD.

  METHOD show_flights.
    DATA(flights) = read_flights( airline ).
    show( flights_list( airline = airline
                        flights = REF #( flights ) ) ).
  ENDMETHOD.

  METHOD zif_salvage_events~on_button_click.
    " Selection mode single: the selected row is the one the user clicked last
    DATA(rows) = alv->selected_rows( ).
    IF button = flights_button AND rows IS NOT INITIAL.
      show_flights_in_popup( carriers[ rows[ 1 ] ]-carrid ).
    ENDIF.
  ENDMETHOD.

  METHOD show_flights_in_popup.
    DATA(flights) = read_flights( airline ).
    show( flights_list( airline = airline
                        flights = REF #( flights ) )->popup( ) ).
  ENDMETHOD.

  METHOD flights_list.
    result = zcl_salvage=>create( flights
                        )->title( |{ TEXT-t02 } { airline }|
                        )->layout( VALUE #( handle = list_handle-flights ) ).
  ENDMETHOD.

  METHOD show.
    TRY.
        list->display( ).
      CATCH zcx_salvage_error INTO DATA(error).
        MESSAGE error TYPE message_type-status DISPLAY LIKE message_type-error.
    ENDTRY.
  ENDMETHOD.

  METHOD read_carriers.
    SELECT FROM scarr
      FIELDS carrid, carrname, url
      ORDER BY carrid
      INTO TABLE @result.
  ENDMETHOD.

  METHOD read_flights.
    SELECT FROM sflight
      FIELDS connid, fldate, price, currency, seatsmax, seatsocc
      WHERE carrid = @airline
      ORDER BY connid, fldate
      INTO TABLE @result.
  ENDMETHOD.
ENDCLASS.


DATA cockpit TYPE REF TO lcl_cockpit.

INITIALIZATION.
  cockpit = NEW #( ).

AT SELECTION-SCREEN OUTPUT.
  cockpit->show_carriers( ).

START-OF-SELECTION.
  cockpit->show_flights( carrier ).
