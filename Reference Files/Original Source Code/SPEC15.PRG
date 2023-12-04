************
* Program.: SPEC15.PRG
* Author..: GRACE KELLER
* Date....:
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SPECIAL15 - SPECIAL LEDGER DETAIL LISTINGS
*
* ---SET environment.
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

SET CENTURY ON
SET DELETED ON
SET TALK OFF
SET ECHO OFF
SET BELL OFF
SET MENU OFF
SET SAFETY OFF
SET ESCAPE ON
SET SCOREBOARD ON
SET STATUS OFF
SET EXCLUSIVE OFF
SET PATH TO \AMERIFOX   
SET DECIMALS TO 5
SET DEVICE TO SCREEN

CLIPPER = .F.
FOXBASE = .T.
MMONO   = .F.

* ---SET COLOR TO values.   (If changed, change other one farther down too)
IF .NOT. MMONO .AND. ISCOLOR()
   SET COLOR TO W+/B,W+/R
ELSE
   SET COLOR TO W/N,N/W
ENDIF

CLOSE ALL
SET DEVICE TO SCREEN

**** FINISHES THE READ WHEN DOING A PAGE DOWN

SELECT A
DO FOX_USE WITH "C:\COMPINFO\SCREEN", .F.
MSCRNSIZE = SCRNSIZE
USE

DO CASE
   *** TEST
CASE MSCRNSIZE = 'T'
   DEFINE WINDOW MWINDOW ;
      FROM 2,24 TO 40,252 ;
      FONT "LUCIDA CONSOLE", 18 ;
      COLOR W+/B, W+/R ;
      NONE
   *** Jeni
CASE MSCRNSIZE = 'J'
   **GOOD - FROM 2,10 TO 35,200  
   **BETTER-  FROM 2,5 TO 35,210
   DEFINE WINDOW MWINDOW ;
      FROM 2,5 TO 40,210 ;
      FONT "LUCIDA CONSOLE", 16 ;
      COLOR W+/B, W+/R ;
      NONE
   *** WIDESCREEN
CASE MSCRNSIZE = 'W'
   DEFINE WINDOW MWINDOW ;
      FROM 5,30 TO 57,272 ;
      FONT "LUCIDA CONSOLE", 20 ;
      COLOR W+/B, W+/R ;
      NONE
   *** LAPTOP
CASE MSCRNSIZE = 'L'
   DEFINE WINDOW MWINDOW ;
      FROM 2,23 TO 54,265 ;
      FONT "LUCIDA CONSOLE", 20 ;
      COLOR W+/B, W+/R ;
      NONE
   *** OTHER - SQUARE 
OTHERWISE
   DEFINE WINDOW MWINDOW ;
      FROM 5,4 TO 57,200 ;
      FONT "LUCIDA CONSOLE", 19 ;
      COLOR W+/B, W+/R ;
      NONE
ENDCASE

ACTIVATE WINDOW "MWINDOW"

* ---MAIN PROCESSING LOOP
CLEAR
SET COLOR TO W/W,W/W
SET COLOR TO W+/B+,W+/R+
CLEAR


**********************************************************************
**** THIS WORKS - BUT GIVES AN EXTRA EJECT AT THE END OF JOB**********
**** ORIGINALLY HAD THIS WAY FOR STODDARD COUNTY
**MPRINTIT = "PRINT.EXE /D:" + MPRINTER + " C:\COMPINFO\PRT_FILE.TXT"
**********************************************************************

****TESTING************
****MPRINTIT = "PRINT.EXE /D:\\GRACE64-HP\HP4250 \COMPINFO\PRTFILE.TXT"
****MPRINTIT = "PRINT.EXE /D:\\GINGER-PC\HP940C \REPORTS\PRTFILE.TXT"
*** END OF TESTING*****
************************************************************************

* ---Initialize global variables.
SELECT A
DO FOX_USE WITH "COMPANY", .F.
MCOMPANY = TRIM(COMPANY)
MMASTDBF = TRIM(MASTDBF)
MDBFLOC = TRIM(DBFLOC)
USE

SELECT A
DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
MPROGRAM = TRIM(PROGRAM)
MPROG_CODE = PROG_CODE
USE

IF FILE("C:\COMPINFO\PRINTERS.DBF")
   SELECT A
   DO FOX_USE WITH "C:\COMPINFO\PRINTERS", .F.
   MPRINTER  = TRIM(PRINTER1)
   MPRINTER2 = TRIM(PRINTER2)
   MPRINTER3 = TRIM(PRINTER3)
   USE
ELSE
   MPRINTER  = 'DONOTPRINT'
   MPRINTER2 = 'DONOTPRINT'
   MPRINTER3 = 'DONOTPRINT'
ENDIF  

MPRINTIT  = 'COPY C:\COMPINFO\PRT_FILE.TXT ' + MPRINTER
MPRINTIT2 = 'COPY C:\COMPINFO\PRT_FILE.TXT ' + MPRINTER2
MPRINTIT3 = 'COPY C:\COMPINFO\PRT_FILE.TXT ' + MPRINTER3


**********************************************************************
**** THIS WORKS - BUT GIVES AN EXTRA EJECT AT THE END OF JOB**********
**** ORIGINALLY HAD THIS WAY FOR STODDARD COUNTY
**MPRINTIT = "PRINT.EXE /D:" + MPRINTER + " C:\COMPINFO\PRT_FILE.TXT"
**********************************************************************

****TESTING************
****MPRINTIT = "PRINT.EXE /D:\\GRACE64-HP\HP4250 \COMPINFO\PRTFILE.TXT"
****MPRINTIT = "PRINT.EXE /D:\\GINGER-PC\HP940C \REPORTS\PRTFILE.TXT"
*** END OF TESTING*****
************************************************************************

STORE 'BROKER SYSTEM' TO MPROGRAM

STORE .T. TO MONO

MPASSWORD = 'ADM99'
MUSER = 'SUPERVISOR'
MSECURITY = .T.

ON KEY LABEL PGUP CLEAR READ
ON KEY LABEL PGDN CLEAR READ

MTITLE = ' - REPORT SPEC15 - LEDGER DETAIL LISTINGS'

CLEAR
@ 01,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@  2,0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
store 'Y' TO MSEP_PAGE
STORE ' ' TO MFRT_X, MSUP_X, MCUS_X, MCOM_X, MBBK_X
STORE 0 TO MTRAN_MO, MTRAN_YR, MEND_MO, MEND_YR
STORE 2 TO MACTION
DO WHILE MACTION = 2
   @ 05,5 SAY "SELECT WITH AN 'X' THE REPORT DESIRED (CAN SELECT MORE THAN ONE)"
   @ 07,5 SAY '    FREIGHT LEDGER: ' GET MFRT_X PICTURE '@!'
   @ 09,5 SAY '   PURCHASE LEDGER: ' GET MSUP_X PICTURE '@!'
   @ 11,5 SAY '      SALES LEDGER: ' GET MCUS_X PICTURE '@!'
   @ 13,5 SAY 'COMMISSIONS LEDGER: ' GET MCOM_X PICTURE '@!'
   @ 15,5 SAY '   BILLBACK LEDGER: ' GET MBBK_X PICTURE '@!'
   @ 17,5 SAY 'BEGIN REPORT MO/YR:   /'
   @ 18,5 SAY 'END   REPORT MO/YR:   /'
   @ 17,25 GET MTRAN_MO PICTURE '##' RANGE 1,12
   @ 17,28 GET MTRAN_YR PICTURE '####' RANGE 1988,2099
   @ 18,25 GET MEND_MO PICTURE '##' RANGE 1,12
   @ 18,28 GET MEND_YR PICTURE '####' RANGE 1988,2099
   STORE 1 TO MACTION
   @ 24,0 SAY 'Action: ' + STR(MACTION,1)
   @ 24,12 SAY '1. Continue      2. Edit     3. Cancel'
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
   READ
   
   IF MFRT_X <> ' ' .AND. MFRT_X <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "FREIGHT REPORT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
   ENDIF
   
   IF MSUP_X <> ' ' .AND. MSUP_X <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "PURCHASE REPORT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
   ENDIF
   
   IF MCUS_X <> ' ' .AND. MCUS_X <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "SALES REPORT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
   ENDIF
   
   IF MCOM_X <> ' ' .AND. MCOM_X <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "COMMISSION REPORT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
   ENDIF  
   
   IF MBBK_X <> ' ' .AND. MBBK_X <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "BILLBACK  REPORT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
   ENDIF  
ENDDO

STORE SUBSTR(STR(MTRAN_MO + 100,3),2) TO MTRAN_MO
STORE STR(MTRAN_YR,4) TO MTRAN_YR        

STORE SUBSTR(STR(MEND_MO + 100,3),2) TO MEND_MO
STORE STR(MEND_YR,4) TO MEND_YR        

IF MFRT_X = 'X'
   @ 4,1 CLEAR TO 21,78
   STORE 'Y' TO MYES_NO
   @ 10,5 SAY 'Print activity only for a specific freight carrier (Y/N) ? ' get myes_no picture '@!'
   READ
   IF MYES_NO <> 'N'
      MNAME_FD = .F.
      DO FRT_SEL1
      IF .NOT. MNAME_FD
         RETURN
      ENDIF
      STORE FRT_CODE TO SFRT_CODE
   ELSE
      STORE SPACE(4) TO SFRT_CODE
   ENDIF
ENDIF

IF MSUP_X = 'X'
   @ 4,1 CLEAR TO 21,78
   STORE 'Y' TO MYES_NO
   @ 10,5 SAY 'Print activity only for a specific supplier (Y/N) ? ' get myes_no picture '@!'
   READ
   IF MYES_NO <> 'N'
      MNAME_FD = .F.
      DO RSUPSEL3
      IF .NOT. MNAME_FD
         RETURN
      ENDIF
      IF LED_CODE = SPACE(4)
         STORE RSUPCODE TO SRSUPCODE
      ELSE
         STORE LED_CODE TO SRSUPCODE
      ENDIF
   ELSE
      STORE SPACE(4) TO SRSUPCODE
   ENDIF
ENDIF

IF MCUS_X = 'X'
   @ 4,1 CLEAR TO 21,78
   STORE 'Y' TO MYES_NO
   @ 10,5 SAY 'Print activity only for a specific customer (Y/N) ? ' get myes_no picture '@!'
   READ
   IF MYES_NO <> 'N'
      MNAME_FD = .F.
      DO BBUYSEL3
      IF .NOT. MNAME_FD
         RETURN
      ENDIF
      IF LED_CODE = SPACE(4) 
         STORE BBUYCODE TO SBBUYCODE
      ELSE
         STORE LED_CODE TO SBBUYCODE
      ENDIF
   ELSE
      STORE SPACE(4) TO SBBUYCODE
   ENDIF
ENDIF

IF MCOM_X = 'X'
   STORE ' ' TO MSEL_TYPE
   STORE SPACE(2) TO MSEL_CODE
   @ 4,1 CLEAR TO 21,78
   STORE 'Y' TO MYES_NO
   @ 10,5 SAY 'Print activity only for specific commission account(s) (Y/N) ? ' get myes_no picture '@!'
   READ 
   
   IF MYES_NO <> 'N'
      @ 4,1 clear to 21,78
      STORE SPACE(32) TO MNAME
      STORE SPACE(1) TO MSALE_SEL, MTHIRD_SEL, MSEL_TYPE
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 10,5 SAY 'COMMISSIONS PAYEE NAME: '
         @ 10,29 GET MNAME PICTURE '@!'
         @ 11,5 SAY " (LEAVE BLANK IF REPORT DESIRED FOR ALL COMMISSIONS)"
         @ 13,5 SAY "'X' THE APPROPRIATE COMMISSIONS CATEGORY IF NAME ENTERED ABOVE"
         @ 14,5 SAY 'MIDWEST SALESPERSON:             THIRD PARTY COMMISSION:'
         @ 14,26 GET MSALE_SEL PICTURE '@!'
         @ 14,62 GET MTHIRD_SEL PICTURE '@!'
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue      2.  Edit      3. Cancel Report'
         READ
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF MSALE_SEL = 'X'
               STORE 'S' TO MSEL_TYPE
            ELSE
               IF MTHIRD_SEL = 'X'
                  STORE 'T' TO MSEL_TYPE
               ENDIF
            ENDIF
            IF MNAME <>  SPACE(32)
               IF MSALE_SEL = 'X'
                  SELECT A
                  DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
                  SEEK TRIM(MNAME)
                  IF .NOT. EOF()
                     STORE SALE_CODE TO MSEL_CODE
                     STORE 'S' TO MSEL_TYPE
                  ELSE
                     @ 24,0 CLEAR
                     mwait = ' '
                     @ 24,1 SAY 'SALESPERSON NAME NOT ON FILE - PRESS ANY KEY TO REENTER' GET MWAIT
                     READ
                     MACTION = 2
                     @ 24,0 CLEAR
                     LOOP 
                  ENDIF
               ELSE
                  SELECT A
                  DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
                  SEEK TRIM(MNAME)
                  IF .NOT. EOF()
                     STORE COM_CODE TO MSEL_CODE
                     STORE 'T' TO MSEL_TYPE
                  ELSE
                     @ 24,0 CLEAR
                     mwait = ' '
                     @ 24,1 SAY 'THIRD PARTY NAME NOT ON FILE - PRESS ANY KEY TO REENTER' GET MWAIT
                     READ
                     MACTION = 2
                     @ 24,0 CLEAR
                     LOOP 
                  ENDIF
                  
               ENDIF
            ENDIF
         ENDIF
      ENDDO
      IF MACTION = 3
         CLOSE DATA
         RETURN
      ENDIF  
   ENDIF
ENDIF  

IF MBBK_X = 'X'
   STORE ' ' TO MSEL_TYPE
   STORE SPACE(2) TO MSBB_CODE
   @ 4,1 CLEAR TO 21,78
   STORE 'Y' TO MYES_NO
   @ 10,5 SAY 'Print activity only for specific BillBack account(s) (Y/N) ? ' get myes_no picture '@!'
   READ 
   IF MYES_NO <> 'N'
      @ 4,1 clear to 21,78
      STORE SPACE(32) TO MBB_NAME
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 10,5 SAY 'BILLBACK PAYEE NAME: '
         @ 10,26 GET MBB_NAME PICTURE '@!'
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue      2.  Edit      3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         
         IF MACTION = 1
            
            IF MBB_NAME <>  SPACE(32)
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
               SEEK TRIM(MBB_NAME)
               IF .NOT. EOF()
                  STORE COM_CODE TO MSBB_CODE
               ELSE
                  @ 24,0 CLEAR
                  mwait = ' '
                  @ 24,1 SAY 'BILLBACK NAME NOT ON FILE - PRESS ANY KEY TO REENTER' GET MWAIT
                  READ
                  MACTION = 2
                  @ 24,0 CLEAR
                  LOOP 
               ENDIF
            ENDIF
         ENDIF
      ENDDO
      
      IF MACTION = 3
         CLOSE DATA
         RETURN
      ENDIF  
   ENDIF
ENDIF

STORE ' ' TO MACTION
DO PRT_SET
IF MACTION <> 'C'
   RETURN
ENDIF 
SET CONSOLE OFF
IF FILE("C:\COMPINFO\PRINTERS.DBF")
   SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
ELSE
   SET PRINT TO LPT3
ENDIF
SET DEVICE TO PRINT
SET PRINT ON

*** PRINT IN 12 CPI
?? chr(27) + '&k4S'

*** BOLDED PRINT
?? CHR(27) + '(s4B'

*** LETTER SIZE PAPER
?? CHR(27) + '&l2A'

*** PORTRAIT MODE
?? CHR(27) + '&l0O'

IF MFRT_X = 'X'
   MTOTAL = 0
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   SELECT A
   DO FOX_USE WITH "FRTLED INDEX FRTLED", .F.
   
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO LEDGER ACTIVITY ON FILE FOR BEGIN MONTH - PRESS RETURN ' GET MWAIT
      READ
      RETURN
   ENDIF
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
   DO WHILE .NOT. EOF()
      IF SFRT_CODE <> SPACE(4)
         IF FRT_CODE <> SFRT_CODE
            SKIP
            LOOP
         ENDIF
      ENDIF
      STORE FRT_CODE TO MFRT_CODE
      STORE NAME TO MNAME
      MACCT_PAGE = 0
      MDO_NM = .T. 
      MEND_BAL = 0
      MBEG_BAL = 0
      MCREDITS = 0
      MDEBITS  = 0
      MACTIVITY = .F.
      MDTL = .F.
      M1ST_BAL = 0
      IF MSEP_PAGE = 'Y' .AND. MLINE <> 99
         MLINE = 70
      ENDIF
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + MFRT_CODE
      IF .NOT. EOF() .AND. MLINE <> 99
         MLINE = MLINE + 1
      ENDIF
      
      DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR+TRAN_MO) <= VAL(MEND_YR+MEND_MO)
         IF FRT_CODE <> MFRT_CODE
            SKIP
            LOOP
         ENDIF
         MACTIVITY = .T.
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,40 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,6 SAY MTRAN_MO + '-' + STR(MACCT_PAGE,2)
            @ 3,28 SAY ' FREIGHT LEDGER LISTING FOR ' + MTRAN_MO + '/'+MTRAN_YR + ' THRU ' + MEND_MO + '/' + MEND_YR 
            @ 3,84  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT/DATE/ITEM'
            @ 5,31 SAY 'INVOICE '
            @ 5,42 SAY 'P.O. NBR'
            @ 5,57 SAY '  DEBITS'  
            @ 5,70 SAY '  CREDITS'
            @ 5,84 SAY '   BALANCE'
            @ 5,01 SAY REPLICATE('_',93)
            @ 7,1 SAY MNAME
            MLINE = 8
            MDO_NM = .F.
         ENDIF
         
         IF MDO_NM
            @ MLINE,1 SAY MNAME
            MDO_NM = .F.
            MLINE = MLINE + 1
         ENDIF
         
         IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
            IF TRAN_MO = MTRAN_MO .AND. TRAN_YR = MTRAN_YR
               @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
               @ MLINE,81 SAY AMOUNT PICTURE '9,999,999.99'
               MBEG_BAL = AMOUNT
            ELSE
               @ MLINE,81 SAY AMOUNT PICTURE '9,999,999.99'
            ENDIF
         ELSE
            @ MLINE,5 SAY TRAN_DATE
            IF CK_NBR = SPACE(6)
               DO CASE
               CASE COR_FLG = 'I' .OR. COR_FLG = ' '
                  @ MLINE,16 SAY 'INVOICE'
               CASE COR_FLG = 'R'
                  @ MLINE,16 SAY 'RECEIPT'
               CASE COR_FLG = 'D'
                  @ MLINE,16 SAY 'A/R REIMBURSE'
               OTHERWISE
                  @ MLINE,16 SAY 'CORRECTION'
               ENDCASE
            ELSE
               @ MLINE,16 SAY 'CK #: ' + CK_NBR
            ENDIF
            IF INV_NBR <> SPACE(5) 
               @ MLINE,32 SAY INV_NBR
            ENDIF
            IF SALESMAN <> '  '
               IF PO_SUFFIX <> ' '
                  @ MLINE,42 SAY  SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
               ELSE
                  @ MLINE,42 SAY SALESMAN + '-' + PO_NBR 
               ENDIF
            ELSE
               IF PO_SUFFIX <> ' '
                  @ MLINE,42 SAY PO_NBR + '-' + PO_SUFFIX
               ELSE
                  @ MLINE,42 SAY PO_NBR 
               ENDIF
            ENDIF
            IF AMOUNT > 0
               @ MLINE,67 SAY AMOUNT PICTURE '9,999,999.99'
               MCREDITS = MCREDITS + AMOUNT
            ELSE
               @ MLINE,53 SAY AMOUNT PICTURE '9,999,999.99'
               MDEBITS = MDEBITS + AMOUNT
            ENDIF
         ENDIF
         MLINE = MLINE + 1
         SKIP
      ENDDO
      IF MACTIVITY
         @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
         @ MLINE,5 SAY '______________________'
         @ MLINE,51 SAY MDEBITS PICTURE '999,999,999.99'
         @ MLINE,65 SAY MCREDITS PICTURE '999,999,999.99'
         MEND_BAL = MBEG_BAL + MDEBITS + MCREDITS
         @ MLINE,81 SAY MEND_BAL PICTURE '9,999,999.99'
         @ MLINE,81 SAY '____________'
         MLINE = MLINE + 1
      ENDIF
      SELECT B
      SKIP
   ENDDO
ENDIF



IF MSUP_X = 'X'
   MTOTAL = 0
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   SELECT A
   DO FOX_USE WITH "SUPLED INDEX SUPLED", .F.
   
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO LEDGER ACTIVITY ON FILE FOR BEGIN MONTH - PRESS RETURN ' GET MWAIT
      READ
      RETURN
   ENDIF
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
   
   DO WHILE .NOT. EOF()
      IF RSUPCODE = 'I'
         SKIP
         LOOP
      ENDIF
      IF SRSUPCODE <> SPACE(4)
         IF RSUPCODE <> SRSUPCODE
            SKIP
            LOOP
         ENDIF
      ENDIF
      STORE RSUPCODE TO MRSUPCODE
      STORE NAME TO MNAME
      MDO_NM = .T. 
      MEND_BAL = 0
      MBEG_BAL = 0
      MDEBITS = 0
      MCREDITS = 0
      MACTIVITY = .F.
      MDTL = .F.
      M1ST_BAL = 0
      MACCT_PAGE = 0
      IF MSEP_PAGE = 'Y' .AND. MLINE <> 99
         MLINE = 70
      ENDIF
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + MRSUPCODE
      IF .NOT. EOF() .AND. MLINE <> 99
         MLINE = MLINE + 1
      ENDIF
      DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR +TRAN_MO) <= VAL(MEND_YR+MEND_MO)
         IF LED_CODE <> MRSUPCODE
            SKIP
            LOOP
         ENDIF
         
         MACTIVITY = .T.
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,40 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,6 SAY MTRAN_MO + '-' + STR(MACCT_PAGE,2)
            @ 3,28 SAY 'PURCHASE LEDGER LISTING FOR ' + MTRAN_MO + '/'+MTRAN_YR + ' THRU ' + MEND_MO + '/' + MEND_YR 
            @ 3,84  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT/DATE/ITEM'
            @ 5,31 SAY 'INVOICE '
            @ 5,42 SAY 'P.O. NBR'
            @ 5,57 SAY '  DEBITS'  
            @ 5,70 SAY '  CREDITS'
            @ 5,84 SAY '   BALANCE'
            @ 5,01 SAY REPLICATE('_',93)
            @ 7,1 SAY MNAME
            MLINE = 8
            MDO_NM = .F.
         ENDIF
         
         IF MDO_NM
            @ MLINE,1 SAY MNAME
            MDO_NM = .F.
            MLINE = MLINE + 1
         ENDIF
         
         IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
            IF TRAN_MO = MTRAN_MO .AND. TRAN_YR = MTRAN_YR
               @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
               @ MLINE,81 SAY AMOUNT PICTURE '9,999,999.99'
               MBEG_BAL = AMOUNT
            ELSE
               @ MLINE,81 SAY AMOUNT PICTURE '9,999,999.99'
            ENDIF
         ELSE
            @ MLINE,5 SAY TRAN_DATE
            IF CK_NBR = SPACE(6)
               DO CASE
               CASE COR_FLG = 'I' .OR. COR_FLG = ' '
                  @ MLINE,16 SAY 'INVOICE'
               CASE COR_FLG = 'R'
                  @ MLINE,16 SAY 'RECEIPT'
               CASE COR_FLG = 'D'
                  @ MLINE,16 SAY 'A/R REIMBURSE'
               OTHERWISE
                  @ MLINE,16 SAY 'CORRECTION'
               ENDCASE
            ELSE
               @ MLINE,16 SAY 'CK #: ' + CK_NBR
            ENDIF
            IF INV_NBR <> SPACE(5) 
               @ MLINE,32 SAY INV_NBR
            ENDIF
            IF SALESMAN <> '  '
               IF PO_SUFFIX <> ' '
                  @ MLINE,42 SAY  SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
               ELSE
                  @ MLINE,42 SAY SALESMAN + '-' + PO_NBR 
               ENDIF
            ELSE
               IF PO_SUFFIX <> ' '
                  @ MLINE,42 SAY PO_NBR + '-' + PO_SUFFIX
               ELSE
                  @ MLINE,42 SAY PO_NBR 
               ENDIF
            ENDIF
            IF AMOUNT > 0
               @ MLINE,67 SAY AMOUNT PICTURE '9,999,999.99'
               MCREDITS = MCREDITS + AMOUNT
            ELSE
               @ MLINE,53 SAY AMOUNT PICTURE '9,999,999.99'
               MDEBITS = MDEBITS + AMOUNT
            ENDIF
         ENDIF
         MLINE = MLINE + 1
         SKIP
      ENDDO
      IF MACTIVITY
         @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
         @ MLINE,5 SAY '______________________'
         @ MLINE,51 SAY MDEBITS PICTURE '999,999,999.99'
         @ MLINE,65 SAY MCREDITS PICTURE '999,999,999.99'
         MEND_BAL = MBEG_BAL + MDEBITS + MCREDITS
         @ MLINE,81 SAY MEND_BAL PICTURE '9,999,999.99'
         @ MLINE,81 SAY '____________'
         MTOTAL = MTOTAL + MEND_BAL
         MLINE = MLINE + 1
      ENDIF
      SELECT B
      SKIP
   ENDDO
   @ MLINE,1 SAY ' '
ENDIF

IF MCUS_X = 'X'
   MTOTAL = 0
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   SELECT A
   DO FOX_USE WITH "CUSLED INDEX CUSLED", .F.
   
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO LEDGER ACTIVITY ON FILE FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
      RETURN
   ENDIF
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
   
   DO WHILE .NOT. EOF()
      IF BBUYCODE = 'I'
         SKIP
         LOOP
      ENDIF
      IF SBBUYCODE <> SPACE(4)
         IF BBUYCODE <> SBBUYCODE
            SKIP
            LOOP
         ENDIF
      ENDIF
      STORE BBUYCODE TO MBBUYCODE
      STORE NAME TO MNAME
      MDO_NM = .T. 
      MEND_BAL = 0
      MBEG_BAL = 0
      MACTIVITY = .F.
      MDTL = .F.
      M1ST_BAL = 0
      MACCT_PAGE = 0
      IF MSEP_PAGE = 'Y' .AND. MLINE <> 99
         MLINE = 70
      ENDIF
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + MBBUYCODE
      IF .NOT. EOF() .AND. MLINE <> 99
         MLINE = MLINE + 1
      ENDIF
      DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR+TRAN_MO) <= VAL(MEND_YR+MEND_MO)
         IF LED_CODE <> MBBUYCODE
            SKIP
            LOOP
         ENDIF
         MACTIVITY = .T.
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,40 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,6 SAY MTRAN_MO + '-' + STR(MACCT_PAGE,2)
            @ 3,28 SAY 'SALES LEDGER LISTING FOR ' + MTRAN_MO + '/'+MTRAN_YR + ' THRU ' + MEND_MO + '/' + MEND_YR 
            @ 3,84  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT/DATE/ITEM'
            @ 5,31 SAY 'INVOICE '
            @ 5,42 SAY 'P.O. NBR'
            @ 5,57 SAY '  DEBITS'  
            @ 5,70 SAY '  CREDITS'
            @ 5,84 SAY '   BALANCE'
            @ 5,01 SAY REPLICATE('_',93)
            @ 7,1 SAY MNAME
            MLINE = 8
            MDO_NM = .F.
         ENDIF
         
         IF MDO_NM
            @ MLINE,1 SAY MNAME
            MDO_NM = .F.
            MLINE = MLINE + 1
         ENDIF
         
         IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
            IF TRAN_MO = MTRAN_MO .AND. TRAN_YR = MTRAN_YR
               @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
               @ MLINE,81 SAY AMOUNT PICTURE '9,999,999.99'
               MBEG_BAL = AMOUNT
            ELSE
               @ MLINE,81 SAY AMOUNT PICTURE '9,999,999.99'
            ENDIF
         ELSE
            @ MLINE,5 SAY TRAN_DATE
            IF CK_NBR = SPACE(7)
               DO CASE
               CASE COR_FLG = 'I' .OR. COR_FLG = ' '
                  @ MLINE,16 SAY 'INVOICE'
               CASE COR_FLG = 'R'
                  @ MLINE,16 SAY 'RECEIPT'
               CASE COR_FLG = 'D'
                  @ MLINE,16 SAY 'A/R REIMBURSE'
               OTHERWISE
                  @ MLINE,16 SAY 'CORRECTION'
               ENDCASE
            ELSE
               @ MLINE,16 SAY 'CK #: ' + CK_NBR
            ENDIF
            IF INV_NBR <> SPACE(5) 
               @ MLINE,32 SAY INV_NBR
            ENDIF
            IF SALESMAN <> '  '
               IF PO_SUFFIX <> ' '
                  @ MLINE,42 SAY  SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
               ELSE
                  @ MLINE,42 SAY SALESMAN + '-' + PO_NBR 
               ENDIF
            ELSE
               IF PO_SUFFIX <> ' '
                  @ MLINE,42 SAY PO_NBR + '-' + PO_SUFFIX
               ELSE
                  @ MLINE,42 SAY PO_NBR 
               ENDIF
            ENDIF
            IF AMOUNT > 0
               @ MLINE,53 SAY AMOUNT PICTURE '9,999,999.99'
               MDEBITS = MDEBITS + AMOUNT
            ELSE
               @ MLINE,67 SAY AMOUNT PICTURE '9,999,999.99'
               MCREDITS = MCREDITS + AMOUNT
            ENDIF
         ENDIF
         MLINE = MLINE + 1
         SKIP
      ENDDO
      IF MACTIVITY
         @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
         @ MLINE,5 SAY '______________________'
         @ MLINE,51 SAY MDEBITS PICTURE '999,999,999.99'
         @ MLINE,65 SAY MCREDITS PICTURE '999,999,999.99'
         MEND_BAL = MBEG_BAL + MDEBITS + MCREDITS
         @ MLINE,81 SAY MEND_BAL PICTURE '9,999,999.99'
         @ MLINE,81 SAY '____________'
         MTOTAL = MTOTAL + MEND_BAL
         MLINE = MLINE + 1
      ENDIF
      SELECT B
      SKIP
   ENDDO
   @ MLINE,1 SAY ' '
ENDIF

IF MCOM_X = 'X'
   MTOTAL = 0
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   
   SELECT A
   DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED", .F.
   
   SEEK MTRAN_YR + MTRAN_MO  
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO LEDGER ACTIVITY ON FILE FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
      RETURN
   ENDIF
   
   IF MSEL_TYPE = ' ' .OR. MSEL_TYPE = 'S'
      SELECT B
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
      
      DO WHILE .NOT. EOF()
         IF MSEL_CODE <> SPACE(2)
            IF MSEL_CODE <> SALE_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
         STORE SALE_CODE TO MCOM_CODE
         STORE NAME TO MNAME
         MDO_NM = .T. 
         MEND_BAL = 0
         MBEG_BAL = 0
         MCREDITS = 0
         MDEBITS = 0
         MACTIVITY = .F.
         MACCT_PAGE = 0
         SELECT A
         SEEK MTRAN_YR + MTRAN_MO + 'S' + MCOM_CODE
         IF .NOT. EOF() .AND. MLINE <> 99
            MLINE = 79
         ENDIF
         
         STORE 0 TO MCHECKS, MINVOICES, MADVANCE, MREPAID
         
         DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR + TRAN_MO) <= VAL(MEND_YR+MEND_MO) 
            IF COM_TYPE <> 'S' .OR. COM_CODE <> MCOM_CODE
               SKIP
               LOOP
            ENDIF
            MACTIVITY = .T.
            IF MLINE > MPAGE_LEN 
               IF MLINE <> 99
                  EJECT         
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 2,40 SAY MCOMPANY
               @ 3,1 SAY 'Page'
               @ 3,6 SAY MTRAN_MO + '-' + STR(MACCT_PAGE,2)
               @ 3,28 SAY 'COMMISSIONS LEDGER LISTING FOR ' + MTRAN_MO + '/'+MTRAN_YR + ' THRU ' + MEND_MO + '/' + MEND_YR 
               @ 3,84  SAY DTOC(DATE())
               @ 5,1 SAY 'ACCOUNT/DATE/ITEM'
               @ 5,31 SAY 'INVOICE '
               @ 5,42 SAY 'P.O. NBR'
               @ 5,57 SAY '  DEBITS'  
               @ 5,70 SAY '  CREDITS'
               @ 5,84 SAY '   BALANCE'
               @ 5,01 SAY REPLICATE('_',93)
               @ 7,1 SAY MNAME
               MLINE = 8
               MDO_NM = .F.
            ENDIF
            IF MDO_NM
               @ MLINE,1 SAY MNAME
               MDO_NM = .F.
               MLINE = MLINE + 1
            ENDIF
            IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
               IF TRAN_MO = MTRAN_MO .AND. TRAN_YR = MTRAN_YR
                  @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
                  @ MLINE,81 SAY AMOUNT PICTURE '9,999,999.99'
                  MBEG_BAL = AMOUNT
               ELSE
                  @ MLINE,81 SAY AMOUNT PICTURE '9,999,999.99'
               ENDIF
            ELSE
               @ MLINE,5 SAY TRAN_DATE
               IF CK_NBR = SPACE(6)
                  DO CASE
                  CASE COR_FLG = 'I' .OR. COR_FLG = ' '
                     @ MLINE,16 SAY 'INVOICE'
                  CASE COR_FLG = 'R'
                     @ MLINE,16 SAY 'RECEIPT'
                  CASE COR_FLG = 'D'
                     @ MLINE,16 SAY 'A/R REIMBURSE'
                  OTHERWISE
                     @ MLINE,16 SAY 'CORRECTION'
                  ENDCASE
                  MINVOICES = MINVOICES + AMOUNT
               ELSE
                  @ MLINE,16 SAY 'CK #: ' + CK_NBR
                  DO CASE
                  CASE ADV_REP = ' '
                     MCHECKS = MCHECKS + AMOUNT 
                  CASE ADV_REP = 'A'
                     MADVANCE = MADVANCE + AMOUNT 
                  CASE ADV_REP = 'R'
                     MREPAID = MREPAID + AMOUNT 
                  ENDCASE
               ENDIF
               IF INV_NBR <> SPACE(5) 
                  @ MLINE,32 SAY INV_NBR
               ENDIF
               IF SALESMAN <> '  '
                  IF PO_SUFFIX <> ' '
                     @ MLINE,42 SAY  SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
                  ELSE
                     @ MLINE,42 SAY SALESMAN + '-' + PO_NBR 
                  ENDIF
               ELSE
                  IF PO_SUFFIX <> ' '
                     @ MLINE,42 SAY PO_NBR + '-' + PO_SUFFIX
                  ELSE
                     @ MLINE,42 SAY PO_NBR 
                  ENDIF
               ENDIF
               IF AMOUNT > 0
                  @ MLINE,69 SAY AMOUNT PICTURE '999,999.99'
                  MCREDITS = MCREDITS + AMOUNT
               ELSE
                  @ MLINE,55 SAY AMOUNT PICTURE '999,999.99'
                  MDEBITS = MDEBITS + AMOUNT
               ENDIF
            ENDIF
            MLINE = MLINE + 1
            SKIP
         ENDDO
         ***HERE
      ENDDO
      
      IF MACTIVITY
         @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
         @ MLINE,5 SAY '______________________'
         @ MLINE,51 SAY MDEBITS PICTURE '999,999,999.99'
         @ MLINE,65 SAY MCREDITS PICTURE '999,999,999.99'
         MEND_BAL = MBEG_BAL + MDEBITS + MCREDITS
         @ MLINE,81 SAY MEND_BAL PICTURE '9,999,999.99'
         @ MLINE,81 SAY '____________'
      ENDIF
      
      IF MSEL_TYPE = ' ' .OR. MSEL_TYPE = 'T'
         MPAGE_NO = 0
         ***** NOW DO THIRD PARTY COMMISSIONS
         SELECT B
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
         
         DO WHILE .NOT. EOF()
            IF MSEL_CODE <> SPACE(2)
               IF MSEL_CODE <> COM_CODE 
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            STORE COM_CODE TO MCOM_CODE
            STORE NAME TO MNAME
            MDO_NM = .T. 
            MEND_BAL = 0
            MBEG_BAL = 0
            MACTIVITY = .F.
            MACCT_PAGE = 0
            SELECT A
            SEEK MTRAN_YR + MTRAN_MO + 'T' + MCOM_CODE
            IF .NOT. EOF() .AND. MLINE <> 99
               MLINE = 79
            ENDIF
            MPAGE_NO = 0
            STORE 0 TO MCHECKS, MINVOICES
            DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR+TRAN_MO) <= VAL(MEND_YR+MEND_MO) .AND. COM_TYPE = 'T' .AND. COM_CODE = MCOM_CODE
               MACTIVITY = .T.
               IF MLINE > MPAGE_LEN 
                  IF MLINE <> 99
                     EJECT         
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,40 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  @ 3,6 SAY MTRAN_MO + '-' + STR(MACCT_PAGE,2)
                  @ 3,28 SAY 'COMMISSIONS LEDGER LISTING FOR ' + MTRAN_MO + '/'+MTRAN_YR + ' THRU ' + MEND_MO + '/' + MEND_YR 
                  @ 3,84  SAY DTOC(DATE())
                  @ 5,1 SAY 'ACCOUNT/DATE/ITEM'
                  @ 5,31 SAY 'INVOICE '
                  @ 5,42 SAY 'P.O. NBR'
                  @ 5,57 SAY '  DEBITS'  
                  @ 5,70 SAY '  CREDITS'
                  @ 5,84 SAY '   BALANCE'
                  @ 5,01 SAY REPLICATE('_',93)
                  @ 7,1 SAY MNAME
                  MLINE = 8
                  MDO_NM = .F.
               ENDIF
               IF MDO_NM
                  @ MLINE,1 SAY MNAME
                  MDO_NM = .F.
                  MLINE = MLINE + 1
               ENDIF
               IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
                  IF TRAN_MO = MTRAN_MO .AND. TRAN_YR = MTRAN_YR
                     @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
                     @ MLINE,81 SAY AMOUNT PICTURE '9,999,999.99'
                     MBEG_BAL = MBEG_BAL + AMOUNT
                  ENDIF
               ELSE
                  @ MLINE,5 SAY TRAN_DATE
                  IF CK_NBR = SPACE(6)
                     DO CASE
                     CASE COR_FLG = 'I' .OR. COR_FLG = ' '
                        @ MLINE,16 SAY 'INVOICE'
                     CASE COR_FLG = 'R'
                        @ MLINE,16 SAY 'RECEIPT'
                     CASE COR_FLG = 'D'
                        @ MLINE,16 SAY 'A/R REIMBURSE'
                     OTHERWISE
                        @ MLINE,16 SAY 'CORRECTION'
                     ENDCASE
                  ELSE
                     @ MLINE,16 SAY 'CK #: ' + CK_NBR
                  ENDIF
                  IF INV_NBR <> SPACE(5) 
                     @ MLINE,32 SAY INV_NBR
                  ENDIF
                  IF SALESMAN <> '  '
                     IF PO_SUFFIX <> ' '
                        @ MLINE,42 SAY  SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
                     ELSE
                        @ MLINE,42 SAY SALESMAN + '-' + PO_NBR 
                     ENDIF
                  ELSE
                     IF PO_SUFFIX <> ' '
                        @ MLINE,42 SAY PO_NBR + '-' + PO_SUFFIX
                     ELSE
                        @ MLINE,42 SAY PO_NBR 
                     ENDIF
                  ENDIF
                  IF AMOUNT > 0
                     @ MLINE,69 SAY AMOUNT PICTURE '999,999.99'
                  ELSE
                     @ MLINE,55 SAY AMOUNT PICTURE '999,999.99'
                  ENDIF
               ENDIF
               MEND_BAL = MEND_BAL + AMOUNT
               MLINE = MLINE + 1
               SKIP
            ENDDO
            IF MACTIVITY
               @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
               @ MLINE,5 SAY '______________________'
               @ MLINE,81 SAY MEND_BAL PICTURE '9,999,999.99'
               @ MLINE,81 SAY '____________'
               MTOTAL = MTOTAL + MEND_BAL
               MLINE = MLINE + 1
            ENDIF
            SELECT B
            SKIP
         ENDDO
      ENDIF
      @ MLINE,1 SAY ' '
   ENDIF  
ENDIF   
IF MBBK_X = 'X'
   MTOTAL = 0
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   
   SELECT A
   DO FOX_USE WITH "&MMASTDBF.BBKLED INDEX &MMASTDBF.BBKLED", .F.
   
   SEEK MTRAN_YR + MTRAN_MO  
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO BILLBK ACTIVITY ON FILE FOR BEGIN MONTH - PRESS RETURN ' GET MWAIT
      READ
      RETURN
   ENDIF
   
   MPAGE_NO = 0
   ***** NOW DO THIRD PARTY COMM BILLBACKS
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
   
   DO WHILE .NOT. EOF()
      IF MSBB_CODE <> SPACE(2)
         IF MSBB_CODE <> COM_CODE 
            SKIP
            LOOP
         ENDIF
      ENDIF
      STORE COM_CODE TO MCOM_CODE
      STORE NAME TO MNAME
      MDO_NM = .T. 
      MEND_BAL = 0
      
      MBEG_BAL = 0
      MDEBITS = 0
      MCREDITS = 0
      
      MACTIVITY = .F.
      MACCT_PAGE = 0
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + 'T' + MCOM_CODE
      IF .NOT. EOF() .AND. MLINE <> 99
         MLINE = 79
      ENDIF
      MPAGE_NO = 0
      STORE 0 TO MCHECKS, MINVOICES
      
      DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR+TRAN_MO) <= VAL(MEND_YR+MEND_MO)
         IF COM_TYPE <> 'T' .OR. COM_CODE <> MCOM_CODE
            SKIP
            LOOP
         ENDIF
         IF VAL(CK_NBR) = 107
            SKIP
            LOOP
         ENDIF
         MACTIVITY = .T.
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,40 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,6 SAY MTRAN_MO + '-' + STR(MACCT_PAGE,2)
            @ 3,28 SAY ' BILLBACK LEDGER LISTING FOR ' + MTRAN_MO + '/'+MTRAN_YR + ' THRU ' + MEND_MO + '/' + MEND_YR 
            @ 3,84  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT/DATE/ITEM'
            @ 5,31 SAY 'INVOICE '
            @ 5,42 SAY 'P.O. NBR'
            @ 5,57 SAY '  DEBITS'  
            @ 5,70 SAY '  CREDITS'
            @ 5,84 SAY '   BALANCE'
            @ 5,01 SAY REPLICATE('_',93)
            @ 7,1 SAY MNAME
            MLINE = 8
            MDO_NM = .F.
         ENDIF
         IF MDO_NM
            @ MLINE,1 SAY MNAME
            MDO_NM = .F.
            MLINE = MLINE + 1
         ENDIF
         IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
            IF TRAN_MO = MTRAN_MO .AND. TRAN_YR = MTRAN_YR
               @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
               @ MLINE,81 SAY AMOUNT PICTURE '9,999,999.99'
               MBEG_BAL = AMOUNT
            ELSE
               @ MLINE,81 SAY AMOUNT PICTURE '9,999,999.99'
            ENDIF
         ELSE
            @ MLINE,5 SAY TRAN_DATE
            IF CK_NBR = SPACE(6)
               DO CASE
               CASE COR_FLG = 'I' .OR. COR_FLG = ' '
                  @ MLINE,16 SAY 'INVOICE'
               CASE COR_FLG = 'R'
                  @ MLINE,16 SAY 'RECEIPT'
               CASE COR_FLG = 'D'
                  @ MLINE,16 SAY 'A/R REIMBURSE'
               OTHERWISE
                  @ MLINE,16 SAY 'CORRECTION'
               ENDCASE
            ELSE
               @ MLINE,16 SAY 'CK #: ' + CK_NBR
            ENDIF
            IF INV_NBR <> SPACE(5) 
               @ MLINE,32 SAY INV_NBR
            ENDIF
            IF SALESMAN <> '  '
               IF PO_SUFFIX <> ' '
                  @ MLINE,42 SAY  SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
               ELSE
                  @ MLINE,42 SAY SALESMAN + '-' + PO_NBR 
               ENDIF
            ELSE
               IF PO_SUFFIX <> ' '
                  @ MLINE,42 SAY PO_NBR + '-' + PO_SUFFIX
               ELSE
                  @ MLINE,42 SAY PO_NBR 
               ENDIF
            ENDIF
            IF AMOUNT > 0
               @ MLINE,69 SAY AMOUNT PICTURE '999,999.99'
               MCREDITS = MCREDITS + AMOUNT
            ELSE
               @ MLINE,55 SAY AMOUNT PICTURE '999,999.99'
               MDEBITS = MDEBITS + AMOUNT
            ENDIF
         ENDIF
         MLINE = MLINE + 1
         SKIP
      ENDDO
      IF MACTIVITY
         @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
         @ MLINE,5 SAY '______________________'
         @ MLINE,51 SAY MDEBITS PICTURE '999,999,999.99'
         @ MLINE,65 SAY MCREDITS PICTURE '999,999,999.99'
         MEND_BAL = MBEG_BAL + MDEBITS + MCREDITS
         @ MLINE,81 SAY MEND_BAL PICTURE '9,999,999.99'
         @ MLINE,81 SAY '____________'
         MLINE = MLINE + 1
      ENDIF
      SELECT B
      SKIP
   ENDDO
   @ MLINE,1 SAY ' '
ENDIF  

EJECT

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON
IF MPRINTER3 <> 'DONOTPRINT'
   RUN &MPRINTIT3
ENDIF
CLOSE DATA

RETURN
* EOF: SPEC15.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/17/15 at 9:30 AM.
