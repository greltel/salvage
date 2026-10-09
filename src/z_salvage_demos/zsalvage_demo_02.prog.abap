" SALVage demo 02: columns, sorting with subtotals, totals and saved layouts.
REPORT zsalvage_demo_02.

DATA carrier_id TYPE s_carr_id.

SELECT-OPTIONS carriers FOR carrier_id.
PARAMETERS layout TYPE slis_vari.


CLASS lcl_demo DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES carrier_range TYPE RANGE OF s_carr_id.

    METHODS run
      IMPORTING carriers TYPE carrier_range
                layout   TYPE slis_vari.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF flight,
        carrid    TYPE sflight-carrid,
        connid    TYPE sflight-connid,
        fldate    TYPE sflight-fldate,
        planetype TYPE sflight-planetype,
        price     TYPE sflight-price,
        currency  TYPE sflight-currency,
        seatsmax  TYPE sflight-seatsmax,
        seatsocc  TYPE sflight-seatsocc,
      END OF flight.
    TYPES flight_rows TYPE STANDARD TABLE OF flight WITH EMPTY KEY.

    CONSTANTS:
      BEGIN OF column,
        airline        TYPE lvc_fname VALUE 'CARRID',
        connection     TYPE lvc_fname VALUE 'CONNID',
        plane_type     TYPE lvc_fname VALUE 'PLANETYPE',
        price          TYPE lvc_fname VALUE 'PRICE',
        currency       TYPE lvc_fname VALUE 'CURRENCY',
        seats_maximum  TYPE lvc_fname VALUE 'SEATSMAX',
        seats_occupied TYPE lvc_fname VALUE 'SEATSOCC',
      END OF column.

    CONSTANTS:
      BEGIN OF message_type,
        status TYPE sy-msgty VALUE 'S',
        error  TYPE sy-msgty VALUE 'E',
      END OF message_type.

    METHODS read_flights
      IMPORTING carriers      TYPE carrier_range
      RETURNING VALUE(result) TYPE flight_rows.

    METHODS show_flights
      IMPORTING layout  TYPE slis_vari
      CHANGING  flights TYPE flight_rows
      RAISING   zcx_salvage_error.
ENDCLASS.


CLASS lcl_demo IMPLEMENTATION.
  METHOD run.
    DATA(flights) = read_flights( carriers ).
    TRY.
        show_flights( EXPORTING layout  = layout
                      CHANGING  flights = flights ).
      CATCH zcx_salvage_error INTO DATA(error).
        MESSAGE error TYPE message_type-status DISPLAY LIKE message_type-error.
    ENDTRY.
  ENDMETHOD.

  METHOD read_flights.
    SELECT FROM sflight
      FIELDS carrid, connid, fldate, planetype, price, currency, seatsmax, seatsocc
      WHERE carrid IN @carriers
      ORDER BY carrid, connid, fldate
      INTO TABLE @result.
  ENDMETHOD.

  METHOD show_flights.
    zcl_salvage=>create( REF #( flights )
               )->title( TEXT-t01
               )->striped(
               )->optimized(
               )->column( name     = column-airline
                          settings = VALUE #( is_key = abap_true )
               )->column( name     = column-connection
                          settings = VALUE #( is_key = abap_true )
               )->column( name     = column-plane_type
                          settings = VALUE #( is_hidden = abap_true )
               )->column( name     = column-price
                          settings = VALUE #( currency_column = column-currency )
               )->column( name     = column-seats_occupied
                          settings = VALUE #( text = TEXT-c01 )
               )->sort_by( name     = column-airline
                           settings = VALUE #( has_subtotals = abap_true )
               )->sort_by( column-connection
               )->total( column-seats_maximum
               )->total( column-seats_occupied
               )->layout( VALUE #( name = layout )
               )->display( ).
  ENDMETHOD.
ENDCLASS.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR layout.
  layout = zcl_salvage=>layout_f4( layout ).

START-OF-SELECTION.
  NEW lcl_demo( )->run( carriers = carriers[]
                        layout   = layout ).
