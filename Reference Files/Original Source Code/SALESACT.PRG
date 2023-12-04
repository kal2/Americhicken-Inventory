****************
* Program.: SALESACT.PRG
* Author..: GRACE KELLER
* Date....: 07/07/2010
* Notice..: Copyright (C) 1991, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SALES DOLLARS/LBS ACTIVITY
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion      
MTITLE = ' - DOLLAR/POUNDS ACTIVITY FOR CUSTOMERS' 
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
**** GET FIRST AND LAST DATES FOR THIS REPORT
STORE CTOD(' ') TO MSTART, MLAST
STORE 'P' TO MDISP_PRT
STORE SPACE(2) TO MSTATE
STORE 2 TO MACTION      
DO WHILE MACTION = 2      
   @ 09,2 say ' DELIV  BEGINNING DATE: '
   @ 09,27 GET MSTART
   @ 11,2 SAY ' DELIV     ENDING DATE: '
   @ 11,27 GET MLAST
   @ 13,2 SAY 'OPTIONAL: CUSTOMER DESTINATION STATE: ' GET MSTATE PICTURE '@!'
   STORE 1 TO MACTION
   @ 24,00 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'                     
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   IF MACTION = 1
      IF DTOC(MSTART) = '  /  /  ' .AND. DTOC(MLAST) = '  /  /  '
         MACTION = 3
      ENDIF
   ENDIF
   
   IF MACTION = 1
      IF (DTOC(MSTART) <> '  /  /  ' .AND. DTOC(MLAST) = '  /  /  ') .OR. (DTOC(MSTART) = '  /  /  ' .AND. DTOC(MLAST) <> '  /  /  ')
         @ 23,0 CLEAR
         mwait = ' '
         @ 23,1 SAY 'Only One Date Entered - Both Begin and End Dates Must be Entered'
         @ 24,1 say 'Press Any Key to Reenter ' get mwait
         READ
         MACTION = 2
         @ 23,0 clear
         LOOP 
      ENDIF
   ENDIF
ENDDO
IF MACTION = 3
   RETURN 
ENDIF  

MPRT_ACT = 'C'

IF MDISP_PRT = 'P'
   DO PRT_SET
   
   IF MPRT_ACT <> 'C'
      RETURN
   ENDIF
   MPAGE_LEN = 56
ELSE
   MPAGE_LEN = 20
ENDIF

SELECT C
USE TEMPPROD EXCLUSIVE
DELETE ALL
PACK
INDEX ON BUY_CODE TO TEMPPROD

DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .F.
DO FILELOCK

SELECT B
DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.

SELECT A
DO FOX_USE WITH "PO_HEAD", .F.
SET FILTER TO DEL_REQD >= MSTART .AND. DEL_REQD <= MLAST .AND. BBUYCODE <> 'INVN'
GOTO TOP

MPAGE_NO = 0
MLINE = 99 
@ 19,16 SAY 'PROCESSING........'
IF MDISP_PRT = 'P'
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

ENDIF
MTOT_SELL = 0
DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MLAST
   SELECT B
   SEEK A->BUY_CODE
   IF MSTATE <> SPACE(2)
      IF MSTATE <> STATE
         SELECT A
         SKIP
         LOOP
      ENDIF
   ENDIF
   SELECT C
   SEEK A->BUY_CODE
   IF EOF()
      APPEND BLANK
      REPLACE BUY_CODE WITH A->BUY_CODE
      REPLACE NAME WITH B->NAME
      REPLACE CITY WITH B->CITY
      REPLACE STATE WITH B->STATE
   ENDIF
   REPLACE TOT_SELL WITH TOT_SELL + A->TOT_SELL+A->CUS_PALL
   SELECT A
   SKIP
ENDDO

SELECT C
INDEX ON NAME +CITY+STATE TO TEMPPROD

DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .F.
DO FILELOCK
DO WHILE .NOT. EOF()
   IF MLINE > MPAGE_LEN
      IF MDISP_PRT <> 'P'
         IF MLINE = 99 
            CLEAR
         ELSE
            STORE ' ' TO MWAIT
            @ 24,0 SAY 'Press Return to Continue to Next Page ' GET MWAIT
            READ
            CLEAR    
         ENDIF
      ENDIF
      MPAGE_NO = MPAGE_NO + 1
      @ 1,1 SAY DTOC(DATE())
      @ 1,27 SAY MCOMPANY
      @ 1,70 SAY TIME()
      @ 2,1 SAY 'Page'
      @ 2,06 say mpage_no picture '99'
      @ 2,11 SAY 'CUSTOMER SALES/DELIVERED ACTIVITY TOTAL FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
      IF MDISP_PRT = 'P'
         @ 3,01 SAY REPLICATE('_',77)
      ENDIF
      @ 05,05 SAY 'CUSTOMER                             TOTAL SALES DOLLARS '
      MLINE = 7
   ENDIF
   @ MLINE,1 SAY  NAME
   @ MLINE,44 SAY TOT_SELL PICTURE '999,999,999.99'
   MTOT_SELL = MTOT_SELL + TOT_SELL
   MLINE = MLINE + 1
   @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE
   MLINE = MLINE + 2
   SKIP
ENDDO
IF MLINE > MPAGE_LEN
   IF MDISP_PRT <> 'P'
      IF MLINE = 99 
         CLEAR
      ELSE
         STORE ' ' TO MWAIT
         @ 24,0 SAY 'Press Return to Continue to Next Page ' GET MWAIT
         READ
         CLEAR    
      ENDIF
   ENDIF
   MPAGE_NO = MPAGE_NO + 1
   @ 1,1 SAY DTOC(DATE())
   @ 1,27 SAY MCOMPANY
   @ 1,70 SAY TIME()
   @ 2,1 SAY 'Page'
   @ 2,06 say mpage_no picture '99'
   @ 2,13 SAY 'CUSTOMER SALES ACTIVITY TOTAL FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
   IF MDISP_PRT = 'P'
      @ 3,01 SAY REPLICATE('_',77)
   ENDIF
   @ 05,05 SAY 'CUSTOMER                             TOTAL SALES DOLLARS '
   MLINE = 7
ENDIF
@ MLINE,1 SAY  'GRAND TOTALS:'
@ MLINE,44 SAY MTOT_SELL PICTURE '999,999,999.99'

IF MDISP_PRT = 'P'
   MLINE = MLINE + 1
   @ mline+1,1 say ' '
   EJECT
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
ELSE
   MPRT_SEL = ' '
   @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
   READ
ENDIF

CLOSE DATA
*Formatted by: ToolBox Ver. 1.2  on 7/23/14 at 1:44 PM.
