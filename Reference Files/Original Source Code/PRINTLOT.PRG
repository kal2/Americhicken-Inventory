******************
* Program.: PRINTLOT.PRG
* Author..: GRACE KELLER
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PURCHASE ORDER MENU     
*
* ---PROCESSING LOOP
*  MULTI-USER RECORD/FILE LOCKING  +(M4)  CLIPPER                             

CLOSE ALL

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON

* ---Initialize global variables.
MTITLE = 'PRINT LOT ACTIVITY/HISTORY'
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 24,79

MFREEZ_LOC = 'INVENTORY' + SPACE(23)
MLOT_NBR = SPACE(10)
MLINE = 99
SET CONFIRM ON
@ 06,1 SAY 'Leave Lot Number Blank when Finished.'
@ 10,1 say 'Enter Lot Number: ' GET MLOT_NBR PICTURE '@!'
READ
SET CONFIRM OFF

SELECT B
DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.

SELECT A
DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT", .F.

DO WHILE MLOT_NBR <> SPACE(10) 
   
   SET CONSOLE OFF
   IF FILE("C:\COMPINFO\PRINTERS.DBF")
      SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
   ELSE
      SET PRINT TO LPT3
   ENDIF
   SET DEVICE TO PRINT
   SET PRINT ON
   
   *** PRINT IN 10 CPI
   ?? chr(27) + '&k0S'
   
   *** LETTER GOTHIC AND BOLDED PRINT
   ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
   
   *** LETTER SIZE PAPER
   ?? CHR(27) + '&l2A'
   
   *** PORTRAIT MODE
   ?? CHR(27) + '&l0O'
   
   SEEK MFREEZ_LOC + MLOT_NBR
   MLEFT = 0
   MACTIVITY = .F. 
   IF EOF() 
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      
      MWAIT = ' '
      @ 24,1 SAY 'LOT NUMBER NOT ON FILE - PRESS RETURN TO CONTINUE ' GET MWAIT
      READ
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
   ELSE
      IF MLINE > 55
         IF MLINE <> 99
            EJECT
         ENDIF
         ? SPACE(10) + 'CASE COUNT' + SPACE(3) + '   POUNDS   PO NUMBER  SHIP DT'
         ?
         MLINE = 5
      ENDIF
      SELECT B
      SEEK MFREEZ_LOC + MLOT_NBR
      IF EOF() 
         MX = 0         
      ELSE
         IF SUBSTR(PACKED,1,1) = 'B'
            MX = VAL(SUBSTR(PACKED,2))
         ELSE
            MX = 0
         ENDIF
      ENDIF
      
      SELECT A
      IF MX <> 0
         MLBS = MX * QTY
      ELSE
         MLBS = LBS
      ENDIF
      ? LOT_NBR + SPACE(2) + TRANSFORM(QTY, '999,999.99') + SPACE(2) + TRANSFORM(MLBS, '999,999.99') + SPACE(3) + SALESMAN + '-' + PO_NBR+ '-' + PO_SUFFIX 
      ?? SPACE(2) + DTOC(ACT_DATE)
      MLINE = MLINE + 1
      MLEFT = MLEFT + QTY
      MACTIVITY = .T.
      SKIP
   ENDIF
   DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT_NBR
      IF MX <> 0
         MLBS = MX * QTY
      ELSE
         MLBS = LBS
      ENDIF
      ? SPACE(8) + SPACE(2) + TRANSFORM(QTY, '999,999.99') + SPACE(2) + TRANSFORM(MLBS, '999,999.99') + SPACE(3) + SALESMAN + '-' + PO_NBR+ '-' + PO_SUFFIX 
      ?? SPACE(2) + DTOC(ACT_DATE)
      MLINE = MLINE + 1
      MLEFT = MLEFT + QTY
      SKIP
   ENDDO
   IF MACTIVITY 
      ? 'CS. LEFT' + SPACE(2) + TRANSFORM(MLEFT, '999,999.99')
      MLINE = MLINE + 1
   ENDIF
   
   ?
   ?
   ?
   MLINE = MLINE + 3
   
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
   
   MLOT_NBR = SPACE(10)
   SET CONFIRM ON
   @ 06,1 SAY 'Leave Lot Number Blank when Finished.'
   @ 10,1 say 'Enter Lot Number: ' GET MLOT_NBR PICTURE '@!'
   READ
   SET CONFIRM OFF
ENDDO

CLOSE ALL
RETURN

*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 1:57 PM.
