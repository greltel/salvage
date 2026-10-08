" SALVage demo 05: traffic lights, row and cell colours, a start filter, text above and
" below the list, average and maximum totals, a currency column for a field of a local
" structure, and columns hidden while they are empty.
REPORT zsalvage_demo_05.

DATA carrier_id TYPE s_carr_id.

SELECT-OPTIONS carriers FOR carrier_id.


CLASS lcl_demo DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES carrier_range TYPE RANGE OF s_carr_id.

    METHODS run
      IMPORTING carriers TYPE carrier_range.

  PRIVATE SECTION.
    TYPES load_percent TYPE p LENGTH 4 DECIMALS 1.

    TYPES:
      BEGIN OF flight,
        light    TYPE c LENGTH 1,
        carrid   TYPE sflight-carrid,
        connid   TYPE sflight-connid,
        fldate   TYPE sflight-fldate,
        seatsmax TYPE sflight-seatsmax,
        seatsocc TYPE sflight-seatsocc,
        load     TYPE load_percent,
        revenue  TYPE sflight-paymentsum,
        currency TYPE sflight-currency,
        remark   TYPE c LENGTH 30,
        colors   TYPE lvc_t_scol,
      END OF flight.
    TYPES flight_rows TYPE STANDARD TABLE OF flight WITH EMPTY KEY.

    CONSTANTS:
      BEGIN OF column,
        light          TYPE lvc_fname VALUE 'LIGHT',
        airline        TYPE lvc_fname VALUE 'CARRID',
        connection     TYPE lvc_fname VALUE 'CONNID',
        seats_occupied TYPE lvc_fname VALUE 'SEATSOCC',
        load           TYPE lvc_fname VALUE 'LOAD',
        revenue        TYPE lvc_fname VALUE 'REVENUE',
        currency       TYPE lvc_fname VALUE 'CURRENCY',
        remark         TYPE lvc_fname VALUE 'REMARK',
        colors         TYPE lvc_fname VALUE 'COLORS',
      END OF column.

    " Values of an ALV exception column
    CONSTANTS:
      BEGIN OF light,
        red    TYPE c LENGTH 1 VALUE '1',
        yellow TYPE c LENGTH 1 VALUE '2',
        green  TYPE c LENGTH 1 VALUE '3',
      END OF light.

    CONSTANTS percent TYPE i VALUE 100.

    CONSTANTS:
      BEGIN OF load_limit,
        high TYPE load_percent VALUE '90',
        low  TYPE load_percent VALUE '50',
        full TYPE load_percent VALUE '100',
      END OF load_limit.

    CONSTANTS:
      BEGIN OF no_bookings,
        option TYPE salv_de_selopt_option VALUE 'GT',
        low    TYPE salv_de_selopt_low    VALUE '0',
      END OF no_bookings.

    CONSTANTS:
      BEGIN OF message_type,
        status TYPE sy-msgty VALUE 'S',
        error  TYPE sy-msgty VALUE 'E',
      END OF message_type.

    METHODS read_flights
      IMPORTING carriers      TYPE carrier_range
      RETURNING VALUE(result) TYPE flight_rows.

    METHODS rate
      CHANGING flight TYPE flight.

    METHODS show_flights
      CHANGING flights TYPE flight_rows
      RAISING  zcx_salvage_error.
ENDCLASS.


CLASS lcl_demo IMPLEMENTATION.
  METHOD run.
    DATA(flights) = read_flights( carriers ).
    TRY.
        show_flights( CHANGING flights = flights ).
      CATCH zcx_salvage_error INTO DATA(error).
        MESSAGE error TYPE message_type-status DISPLAY LIKE message_type-error.
    ENDTRY.
  ENDMETHOD.

  METHOD read_flights.
    SELECT FROM sflight
      FIELDS carrid, connid, fldate, seatsmax, seatsocc, paymentsum AS revenue, currency
      WHERE carrid IN @carriers
      ORDER BY carrid, connid, fldate
      INTO CORRESPONDING FIELDS OF TABLE @result.
    LOOP AT result ASSIGNING FIELD-SYMBOL(<flight>).
      rate( CHANGING flight = <flight> ).
    ENDLOOP.
  ENDMETHOD.

  METHOD rate.
    IF flight-seatsmax > 0.
      flight-load = flight-seatsocc * percent / flight-seatsmax.
    ENDIF.
    flight-light = COND #( WHEN flight-load > load_limit-high THEN light-red
                           WHEN flight-load < load_limit-low  THEN light-green
                           ELSE light-yellow ).
    IF flight-load > load_limit-full.
      flight-remark = TEXT-r01.
    ENDIF.
    " An empty FNAME colours the row, a column name only that cell
    IF flight-load >= load_limit-full.
      INSERT VALUE #( color = VALUE #( col = col_negative ) ) INTO TABLE flight-colors.
    ELSEIF flight-load < load_limit-low.
      INSERT VALUE #( fname = column-load
                      color = VALUE #( col = col_positive ) ) INTO TABLE flight-colors.
    ENDIF.
  ENDMETHOD.

  METHOD show_flights.
    zcl_salvage=>create( REF #( flights )
               )->title( TEXT-t01
               )->optimized(
               )->top_of_list( VALUE #( heading = TEXT-h01
                                        lines   = VALUE #( ( |{ TEXT-h02 } { sy-datum DATE = USER }| ) ) )
               )->end_of_list( VALUE #( lines = VALUE #( ( CONV #( TEXT-e01 ) )
                                                         ( CONV #( TEXT-e02 ) ) ) )
               )->lights_from( column-light
               )->colors_from( column-colors
               )->hide_empty_columns(
               )->column( name     = column-airline
                          settings = VALUE #( is_key = abap_true )
               )->column( name     = column-connection
                          settings = VALUE #( is_key = abap_true )
               )->column( name     = column-load
                          settings = VALUE #( text = TEXT-c01 )
               )->column( name     = column-revenue
                          settings = VALUE #( text            = TEXT-c02
                                              currency_column = column-currency
                                              color           = VALUE #( col = col_total ) )
               )->column( name     = column-remark
                          settings = VALUE #( text = TEXT-c03 )
               )->filter_by( name     = column-seats_occupied
                             settings = VALUE #( option = no_bookings-option
                                                 low    = no_bookings-low )
               )->total( name = column-load
                         kind = if_salv_c_aggregation=>average
               )->total( name = column-seats_occupied
                         kind = if_salv_c_aggregation=>maximum
               )->total( column-revenue
               )->display( ).
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  NEW lcl_demo( )->run( carriers[] ).
