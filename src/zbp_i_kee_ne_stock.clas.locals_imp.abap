CLASS lhc_ZI_kee_NE_STOCK DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS CalculateRemainingDays
      FOR DETERMINE ON MODIFY
      IMPORTING keys
      FOR Stock~CalculateRemainingDays.

    METHODS validateDates
      FOR VALIDATE ON SAVE
      IMPORTING keys
      FOR Stock~validateDates.

ENDCLASS.


CLASS lhc_ZI_kee_NE_STOCK IMPLEMENTATION.


  METHOD CalculateRemainingDays.

    "---------------------------------------------------------------
    " Get current system date
    "---------------------------------------------------------------

    DATA(lv_current_date) =
      cl_abap_context_info=>get_system_date( ).


    "---------------------------------------------------------------
    " Read affected Stock instances
    "---------------------------------------------------------------

    READ ENTITIES OF ZI_kee_NE_STOCK IN LOCAL MODE
      ENTITY ZI_kee_NE_STOCK
      FIELDS (
        ExpiryDate
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_stock).


    "---------------------------------------------------------------
    " Prepare update table
    "---------------------------------------------------------------

    DATA lt_update
      TYPE TABLE FOR UPDATE ZI_kee_NE_STOCK.


    "---------------------------------------------------------------
    " Calculate Remaining Days and classification
    "---------------------------------------------------------------

    LOOP AT lt_stock INTO DATA(ls_stock).

      "-------------------------------------------------------------
      " No expiry date -> nothing to calculate
      "-------------------------------------------------------------

      IF ls_stock-ExpiryDate IS INITIAL.
        CONTINUE.
      ENDIF.


      "-------------------------------------------------------------
      " Remaining Days = Expiry Date - Current System Date
      "-------------------------------------------------------------

      DATA(lv_remaining_days) =
        ls_stock-ExpiryDate - lv_current_date.


      "-------------------------------------------------------------
      " More than 30 days -> SAFE
      "-------------------------------------------------------------

      IF lv_remaining_days > 30.

        APPEND VALUE #(
          %tky              = ls_stock-%tky
          RemainingDays     = lv_remaining_days
          ExpiryStatus      = 'SAFE'
          Priority          = 'LOW'
          RecommendedAction = 'NORMAL USAGE'
        ) TO lt_update.


      "-------------------------------------------------------------
      " 16 to 30 days -> HIGH
      "-------------------------------------------------------------

      ELSEIF lv_remaining_days >= 16.

        APPEND VALUE #(
          %tky              = ls_stock-%tky
          RemainingDays     = lv_remaining_days
          ExpiryStatus      = 'HIGH'
          Priority          = 'MEDIUM'
          RecommendedAction = 'PRIORITIZE USAGE'
        ) TO lt_update.


      "-------------------------------------------------------------
      " 8 to 15 days -> VERY HIGH
      "-------------------------------------------------------------

      ELSEIF lv_remaining_days >= 8.

        APPEND VALUE #(
          %tky              = ls_stock-%tky
          RemainingDays     = lv_remaining_days
          ExpiryStatus      = 'VERY HIGH'
          Priority          = 'HIGH'
          RecommendedAction = 'USE SOON'
        ) TO lt_update.


      "-------------------------------------------------------------
      " 0 to 7 days -> CRITICAL
      "-------------------------------------------------------------

      ELSEIF lv_remaining_days >= 0.

        APPEND VALUE #(
          %tky              = ls_stock-%tky
          RemainingDays     = lv_remaining_days
          ExpiryStatus      = 'CRITICAL'
          Priority          = 'URGENT'
          RecommendedAction = 'IMMEDIATE ACTION'
        ) TO lt_update.


      "-------------------------------------------------------------
      " Negative days -> EXPIRED
      "-------------------------------------------------------------

      ELSE.

        APPEND VALUE #(
          %tky              = ls_stock-%tky
          RemainingDays     = lv_remaining_days
          ExpiryStatus      = 'CRITICAL'
          Priority          = 'URGENT'
          RecommendedAction = 'REMOVE / DISPOSE'
        ) TO lt_update.

      ENDIF.

    ENDLOOP.


    "---------------------------------------------------------------
    " Update calculated fields in local transactional buffer
    "---------------------------------------------------------------

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF ZI_kee_NE_STOCK IN LOCAL MODE
        ENTITY ZI_kee_NE_STOCK
        UPDATE FIELDS (
          RemainingDays
          ExpiryStatus
          Priority
          RecommendedAction
        )
        WITH lt_update.

    ENDIF.

  ENDMETHOD.



  METHOD validateDates.

    "---------------------------------------------------------------
    " Read Manufacture Date and Expiry Date
    "---------------------------------------------------------------

    READ ENTITIES OF ZI_kee_NE_STOCK IN LOCAL MODE
      ENTITY ZI_kee_NE_STOCK
      FIELDS (
        ManufactureDate
        ExpiryDate
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_stock).


    "---------------------------------------------------------------
    " Validate date relationship
    "---------------------------------------------------------------

    LOOP AT lt_stock INTO DATA(ls_stock).

      "-------------------------------------------------------------
      " Expiry Date must not be earlier than Manufacture Date
      "-------------------------------------------------------------

      IF ls_stock-ManufactureDate IS NOT INITIAL
         AND ls_stock-ExpiryDate IS NOT INITIAL
         AND ls_stock-ExpiryDate < ls_stock-ManufactureDate.


        "-----------------------------------------------------------
        " Mark Stock instance as failed
        "-----------------------------------------------------------

        APPEND VALUE #(
          %tky = ls_stock-%tky
        ) TO failed-stock.


        "-----------------------------------------------------------
        " Report validation error
        " Highlight ExpiryDate field in Fiori
        "-----------------------------------------------------------

        APPEND VALUE #(
          %tky = ls_stock-%tky

          %element-ExpiryDate = if_abap_behv=>mk-on

          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Expiry Date cannot be earlier than Manufacture Date.'
          )

        ) TO reported-stock.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


ENDCLASS.


