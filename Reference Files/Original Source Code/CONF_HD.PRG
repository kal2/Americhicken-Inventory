*************
* Program.: CONF_HD.PRG
* Author..: Grace Keller
* Date....: 10/26/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: ORDER CONFIRMATION/NOTIFICATION HEADER
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     


? space(5) + SPACE(13) + '-->> CONFIRMATION CONTINUED ON NEXT PAGE <<--'
EJECT

MPAGE_NBR = MPAGE_NBR + 1
DO AMER_BOX

? SPACE(5) + 'Phone: ' + '573-651-6485' + SPACE(37) + '1330 Copper Dr.'
? SPACE(5) + 'Fax:   ' + '573-651-4669' + SPACE(37) + 'Cape Girardeau, MO  63701'
? SPACE(5) + 'Email: customerservice@americhicken.com'
?
? SPACE(5) + REPLICATE('=',88)
IF MTYPE3 = 'X'
ELSE
   ?  SPACE(5) + SPACE(25) +  SPACE(27) + SPACE(21) + 'DATE'
ENDIF

DO CASE
CASE MTYPE1 = 'X'
   ?  SPACE(4) + 'PAGE: ' + STR(MPAGE_NBR,2) + SPACE(16) + 'PURCHASE ORDER CONFIRMATION' + SPACE(18) + DTOC(DATE())
   ?
   ?
   ?  SPACE(4) + 'PO #:        '
   
   IF PSALESMAN <> '  '
      ?? PSALESMAN 
      ?? MPO_NBR
      IF MPO_SUFFIX = ' '
         ?? SPACE(2)
      ELSE
         ?? '-' + MPO_SUFFIX
      ENDIF
      ?? ' '
   ELSE
      ?? MPO_NBR
      IF MPO_SUFFIX = ' '
         ?? SPACE(2)
      ELSE
         ?? '-' + MPO_SUFFIX
      ENDIF
      ?? SPACE(3)
   ENDIF
   ?
   ?
   
CASE MTYPE2 = 'X'
   DO CASE
   CASE MBIL_NAME = 'INVENTORY'
      ?  SPACE(5) + 'PAGE: ' + STR(MPAGE_NBR,2) + SPACE(16) + 'FREEZER INBOUND CONFIRMATION' + SPACE(18) + DTOC(DATE())
      ?
      ?
      ?  SPACE(5) + 'AMERI PO #: '
      
      IF PSALESMAN <> '  '
         ?? PSALESMAN 
         ?? MPO_NBR
         IF MPO_SUFFIX = ' '
            ?? SPACE(2)
         ELSE
            ?? '-' + MPO_SUFFIX
         ENDIF
         ?? ' '
      ELSE
         ?? MPO_NBR
         IF MPO_SUFFIX = ' '
            ?? SPACE(2)
         ELSE
            ?? '-' + MPO_SUFFIX
         ENDIF
         ?? SPACE(3)
      ENDIF
      ?
      ?
      
   OTHERWISE
      *** CUSTOMER CONFIRMATIONS
      ?  SPACE(5) + 'PAGE: ' + STR(MPAGE_NBR,2) + SPACE(17) + 'CUSTOMER SALES CONFIRMATION' + SPACE(18) + DTOC(DATE())
      ?
      ?
      ?  SPACE(5) + 'AMERI PO #: '
      
      IF PSALESMAN <> '  '
         ?? PSALESMAN 
         ?? MPO_NBR
         IF MPO_SUFFIX = ' '
            ?? SPACE(2)
         ELSE
            ?? '-' + MPO_SUFFIX
         ENDIF
         ?? ' '
      ELSE
         ?? MPO_NBR
         IF MPO_SUFFIX = ' '
            ?? SPACE(2)
         ELSE
            ?? '-' + MPO_SUFFIX
         ENDIF
         ?? SPACE(3)
      ENDIF
      ?
      ?
   ENDCASE
   
CASE MTYPE3 = 'X'
   IF A->BBUYCODE = 'INVN' .AND. A->PU_LOC = 'TRANSFER'
      ?  SPACE(5) + 'PAGE: ' + STR(MPAGE_NBR,2) + SPACE(13) + 'FREEZER TRANSFER IN STORAGE NOTIFICATION' + SPACE(10) + 'DATE: ' + DTOC(DATE())
   ELSE
      ?  SPACE(5) + 'PAGE: ' + STR(MPAGE_NBR,2) + SPACE(17) + '       FREEZER NOTIFICATION' + SPACE(12) + 'DATE: ' + DTOC(DATE())
   ENDIF
   ?
   ?
   ?  SPACE(5) + 'AMERI PO #: '
   IF PSALESMAN <> '  '
      ?? PSALESMAN 
      ?? MPO_NBR
      IF MPO_SUFFIX = ' '
         ?? SPACE(2)
      ELSE
         ?? '-' + MPO_SUFFIX
      ENDIF
      ?? ' '
   ELSE
      ?? MPO_NBR
      IF MPO_SUFFIX = ' '
         ?? SPACE(2)
      ELSE
         ?? '-' + MPO_SUFFIX
      ENDIF
      ?? SPACE(3)
   ENDIF
   ?
   ?
ENDCASE
*******************************************************************

?  SPACE(5) + 'CODE' + SPACE(2) + '  QTY' + SPACE(2) + 'DESCRIPTION' + SPACE(34) + 'CASE WT     TOTAL WT  '
IF MTYPE3 <> 'X'
   IF MTYPE2 = 'X' .AND. MBIL_NAME = 'INVENTORY'
      *** LEAVE THIS BLANK
   ELSE
      ?? ' PRICE/CS'
   ENDIF
ELSE
   ?? ' LOT NBR'
ENDIF
?  SPACE(5) + '======' + SPACE(1) + '====' + SPACE(2) + '===================================' + SPACE(10) + '=======   ==========  '
IF MTYPE2 = 'X' .AND. MBIL_NAME = 'INVENTORY'
   *** LEAVE THIS BLANK
ELSE
   ?? ' ========'
ENDIF
?
RETURN
*Formatted by: ToolBox Ver. 1.2  on 10/5/16 at 4:55 PM.
