"! <p>Raised by {@link zcl_salvage.METH:display} when the configuration of a list cannot be
"! applied, for example a column name the table does not have. That is a mistake in the calling
"! program, which is why the class inherits from CX_DYNAMIC_CHECK.</p>
"! <p>The text comes from message class ZSALVAGE. Where SALV reported the problem, its exception
"! is in attribute PREVIOUS.</p>
CLASS zcx_salvage_error DEFINITION
  PUBLIC
  INHERITING FROM cx_dynamic_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg.
    INTERFACES if_t100_message.

    "! Creates the exception. {@link zcl_salvage} raises it with RAISE EXCEPTION TYPE and the
    "! MESSAGE addition, which fills the message and its variables.
    "!
    "! @parameter textid   | Message of class ZSALVAGE; initial: the generic text of the class
    "! @parameter previous | Exception that caused this one
    METHODS constructor
      IMPORTING textid   LIKE if_t100_message=>t100key OPTIONAL
                previous LIKE previous OPTIONAL.
ENDCLASS.


CLASS zcx_salvage_error IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

