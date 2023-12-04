*************
* Program.: LED_BAL.PRG
* Author..: Grace Keller
* Date....: 02/15/88
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINT LEDGER BEGINNING/ENDING BALANCES
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MTITLE = ' - PRINT LEDGER BEGINNING/ENDING BALANCES'

CLEAR
@ 01,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@  2,0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
STORE 'Y' TO MYES_NO
@ 10,5 SAY 'Print Only Ending Balances (Y/N)? ' GET MYES_NO PICTURE '@!'
READ
IF MYES_NO <> 'N'
   DO END_BAL
   RETURN
ENDIF
@ 10,1 SAY SPACE(77)
STORE ' ' TO MFRT_SEL, MSUP_SEL, MCUS_SEL, MCOM_SEL, MBBK_SEL
STORE 0 TO MTRAN_MO, MTRAN_YR
STORE 2 TO MACTION
DO WHILE MACTION = 2
   @ 05,5 SAY "SELECT WITH AN 'X' THE REPORT DESIRED (ONLY SELECT ONE AT A TIME)"
   @ 07,5 SAY '    FREIGHT LEDGER: ' GET MFRT_SEL PICTURE '@!'
   @ 09,5 SAY '   PURCHASE LEDGER: ' GET MSUP_SEL PICTURE '@!'
   @ 11,5 SAY '      SALES LEDGER: ' GET MCUS_SEL PICTURE '@!'
   IF MCOMPANY <> 'DIVISION'
      @ 13,5 SAY 'COMMISSIONS LEDGER: ' GET MCOM_SEL PICTURE '@!'
   ENDIF
   @ 15,5 SAY '   BILLBACK LEDGER: ' GET MBBK_SEL PICTURE '@!'
   @ 17,5 SAY '      REPORT MONTH: ' GET MTRAN_MO PICTURE '##' RANGE 1,12
   @ 18,5 SAY '       REPORT YEAR: ' GET MTRAN_YR PICTURE '####' RANGE 1988,2099
   STORE 1 TO MACTION
   @ 24,0 SAY 'Action: ' + STR(MACTION,1)
   @ 24,12 SAY '1. Continue      2. Edit     3. Cancel'
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
   
   READ
   DO CASE
   CASE MFRT_SEL <> ' ' .AND. MFRT_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "FREIGHT REPORT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MSUP_SEL <> ' ' .AND. MSUP_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "PURCHASE LEDGER SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MCUS_SEL <> ' ' .AND. MCUS_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "SALES LEDGER SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MCOM_SEL <> ' ' .AND. MCOM_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "COMMISSION LEDGER SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MBBK_SEL <> ' ' .AND. MBBK_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "BILLBACK LEDGER SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
   ENDCASE
ENDDO

STORE SUBSTR(STR(MTRAN_MO + 100,3),2) TO MTRAN_MO
STORE STR(MTRAN_YR,4) TO MTRAN_YR         

DO CASE
CASE MTRAN_MO = '01'
   STORE 'JANUARY' TO MMONTH
CASE MTRAN_MO = '02'
   STORE 'FEBRUARY' TO MMONTH
CASE MTRAN_MO = '03'
   STORE 'MARCH' TO MMONTH
CASE MTRAN_MO = '04'
   STORE 'APRIL' TO MMONTH
CASE MTRAN_MO = '05'
   STORE 'MAY' TO MMONTH
CASE MTRAN_MO = '06'
   STORE 'JUNE' TO MMONTH
CASE MTRAN_MO = '07'
   STORE 'JULY' TO MMONTH
CASE MTRAN_MO = '08'
   STORE 'AUGUST' TO MMONTH
CASE MTRAN_MO = '09'
   STORE 'SEPTEMBER' TO MMONTH
CASE MTRAN_MO = '10'
   STORE 'OCTOBER' TO MMONTH
CASE MTRAN_MO = '11'
   STORE 'NOVEMBER' TO MMONTH
CASE MTRAN_MO = '12'
   STORE 'DECEMBER' TO MMONTH
OTHERWISE
   STORE ' ' TO MMONTH
ENDCASE

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

*** LETTER GOTHIC AND BOLDED PRINT
?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'

*** LETTER SIZE PAPER
?? CHR(27) + '&l2A'

*** PORTRAIT MODE
?? CHR(27) + '&l0O'

DO CASE
CASE MFRT_SEL = 'X'
   MTOTAL = 0
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   MBEG_BAL = 0
   SELECT A
   DO FOX_USE WITH "FRTLED INDEX FRTLED", .F.
   
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      SET DEVICE TO SCREEN
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
   DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
   DO WHILE .NOT. EOF()
      STORE FRT_CODE TO MFRT_CODE
      STORE NAME TO MNAME
      MDO_NM = .T. 
      MEND_BAL = 0
      MACTIVITY = .F.
      MBEGIN = .F.
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + MFRT_CODE
      IF .NOT. EOF() .AND. MLINE <> 99
         MLINE = MLINE + 1
      ENDIF
      DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. FRT_CODE = MFRT_CODE
         MACTIVITY = .T.
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,20 SAY 'FREIGHT LEDGER LISTING FOR ' + MMONTH 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT'
            @ 5,50 SAY '  DEBITS'  
            @ 5,63 SAY '  CREDITS'
            @ 5,76 SAY '   BALANCE'
            @ 5,01 SAY REPLICATE('_',88)
            MLINE = 7
         ENDIF
         IF MDO_NM    
            @ MLINE,1 SAY MNAME
            MDO_NM = .F.
            MLINE = MLINE + 1
         ENDIF
         IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,74 SAY AMOUNT PICTURE '9,999,999.99'
            MBEG_BAL = MBEG_BAL + AMOUNT
            MLINE = MLINE + 1
            MBEGIN = .T.
         ENDIF 
         MEND_BAL = MEND_BAL + AMOUNT
         SKIP
      ENDDO
      IF MACTIVITY
         IF .NOT. MBEGIN
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,76 SAY '      0.00'
            MLINE = MLINE + 1
         ENDIF
         @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
         @ MLINE,5 SAY '______________________'
         @ MLINE,74 SAY MEND_BAL PICTURE '9,999,999.99'
         @ MLINE,74 SAY '____________'
         MTOTAL = MTOTAL + MEND_BAL
         MLINE = MLINE + 1
      ENDIF
      SELECT B
      SKIP
   ENDDO
   MLINE = MLINE + 1
   @ MLINE,5 SAY 'BEGINNING BALANCES: '
   @ MLINE,73 SAY MBEG_BAL PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,5 SAY '  MONTHLY ACTIVITY:'
   @ MLINE,73 SAY (MTOTAL - MBEG_BAL) PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,5 SAY '   ENDING BALANCES: ' 
   @ MLINE,73 SAY MTOTAL PICTURE '99,999,999.99'
   
CASE MSUP_SEL = 'X'
   MTOTAL = 0
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   MBEG_BAL = 0
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
      @ 10,1 SAY 'THERE IS NO LEDGER ACTIVITY ON FILE FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
      RETURN
   ENDIF
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
   
   DO WHILE .NOT. EOF()
      IF RUSUPCODE = 'I'
         SKIP
         LOOP
      ENDIF
      STORE RSUPCODE TO MRSUPCODE
      STORE NAME TO MNAME
      MEND_BAL = 0
      MBEGIN = .F.
      MACTIVITY = .F.
      MDO_NM = .T.
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + MRSUPCODE
      IF .NOT. EOF() .AND. MLINE <> 99
         MLINE = MLINE + 1
      ENDIF
      DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. LED_CODE = MRSUPCODE
         MACTIVITY = .T.
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,20 SAY 'PURCHASE LEDGER LISTING FOR ' + MMONTH 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT'
            @ 5,50 SAY '  DEBITS'  
            @ 5,63 SAY '  CREDITS'
            @ 5,76 SAY '   BALANCE'
            @ 5,01 SAY REPLICATE('_',88)
            MLINE = 7
         ENDIF
         IF MDO_NM    
            @ MLINE,1 SAY MNAME
            MDO_NM = .F.
            MLINE = MLINE + 1
         ENDIF
         IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,74 SAY AMOUNT PICTURE '9,999,999.99'
            MBEG_BAL = MBEG_BAL + AMOUNT
            MLINE = MLINE + 1
            MBEGIN = .T.
         ENDIF 
         MEND_BAL = MEND_BAL + AMOUNT
         SKIP
      ENDDO
      IF MACTIVITY
         IF .NOT. MBEGIN
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,76 SAY '      0.00'
            MLINE = MLINE + 1
         ENDIF
         @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
         @ MLINE,5 SAY '______________________'
         @ MLINE,74 SAY MEND_BAL PICTURE '9,999,999.99'
         @ MLINE,74 SAY '____________'
         MTOTAL = MTOTAL + MEND_BAL
         MLINE = MLINE + 1
      ENDIF
      SELECT B
      SKIP
   ENDDO
   MLINE = MLINE + 1
   @ MLINE,5 SAY 'BEGINNING BALANCES: '
   @ MLINE,73 SAY MBEG_BAL PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,5 SAY '  MONTHLY ACTIVITY:'
   @ MLINE,73 SAY (MTOTAL - MBEG_BAL) PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,5 SAY '   ENDING BALANCES: ' 
   @ MLINE,73 SAY MTOTAL PICTURE '99,999,999.99'
   
CASE MCUS_SEL = 'X'
   MTOTAL = 0
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   MBEG_BAL = 0          
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
      STORE BBUYCODE TO MBBUYCODE
      STORE NAME TO MNAME
      MBEGIN = .F. 
      MDO_NM = .T.
      MEND_BAL = 0
      MACTIVITY = .F.
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + MBBUYCODE
      IF .NOT. EOF() .AND. MLINE <> 99
         MLINE = MLINE + 1
      ENDIF
      DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. LED_CODE = MBBUYCODE
         MACTIVITY = .T.
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,20 SAY 'SALES LEDGER LISTING FOR ' + MMONTH 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT'
            @ 5,50 SAY '  DEBITS'  
            @ 5,63 SAY '  CREDITS'
            @ 5,76 SAY '   BALANCE'
            @ 5,01 SAY REPLICATE('_',88)
            MLINE = 7
         ENDIF
         IF MDO_NM    
            @ MLINE,1 SAY MNAME
            MDO_NM = .F.
            MLINE = MLINE + 1
         ENDIF
         IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,74 SAY AMOUNT PICTURE '9,999,999.99'
            MBEG_BAL = MBEG_BAL + AMOUNT
            MLINE = MLINE + 1
            MBEGIN = .T.
         ENDIF 
         MEND_BAL = MEND_BAL + AMOUNT
         SKIP
      ENDDO
      IF MACTIVITY
         IF .NOT. MBEGIN
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,76 SAY '      0.00'
            MLINE = MLINE + 1
         ENDIF
         @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
         @ MLINE,5 SAY '______________________'
         @ MLINE,74 SAY MEND_BAL PICTURE '9,999,999.99'
         @ MLINE,74 SAY '____________'
         MTOTAL = MTOTAL + MEND_BAL
         MLINE = MLINE + 1
      ENDIF
      SELECT B
      SKIP
   ENDDO
   MLINE = MLINE + 1
   @ MLINE,5 SAY 'BEGINNING BALANCES: '
   @ MLINE,73 SAY MBEG_BAL PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,5 SAY '  MONTHLY ACTIVITY:'
   @ MLINE,73 SAY (MTOTAL - MBEG_BAL) PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,5 SAY '   ENDING BALANCES: ' 
   @ MLINE,73 SAY MTOTAL PICTURE '99,999,999.99'
   
   
CASE MCOM_SEL = 'X'
   MTOTAL = 0
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   SELECT A
   DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED", .F.
   
   SEEK MTRAN_YR + MTRAN_MO  
   IF EOF()
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO LEDGER ACTIVITY ON FILE FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
      RETURN
   ENDIF
   SELECT B
   DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
   
   DO WHILE .NOT. EOF()
      STORE SALE_CODE TO MCOM_CODE
      STORE NAME TO MNAME
      MBEGIN = .F. 
      MEND_BAL = 0
      MDO_NM = .T.
      MACTIVITY = .F.
      MBEG_BAL = 0
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + 'S' + MCOM_CODE
      IF .NOT. EOF() .AND. MLINE <> 99
         MLINE = MLINE + 1
      ENDIF
      DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. COM_TYPE = 'S' .AND. COM_CODE = MCOM_CODE
         MACTIVITY = .T.
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,18 SAY 'COMMISSIONS LEDGER LISTING FOR ' + MMONTH 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT'
            @ 5,42 SAY '  DEBITS'  
            @ 5,55 SAY '  CREDITS'
            @ 5,68 SAY '   BALANCE'
            @ 5,01 SAY REPLICATE('_',80)
            MLINE = 7
            MDO_NM = .T.
         ENDIF
         IF MDO_NM    
            @ MLINE,1 SAY MNAME
            MDO_NM = .F.
            MLINE = MLINE + 1
         ENDIF
         IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,66 SAY AMOUNT PICTURE '9,999,999.99'
            MBEG_BAL = MBEG_BAL + AMOUNT
            MLINE = MLINE + 1
            MBEGIN = .T.
         ENDIF 
         MEND_BAL = MEND_BAL + AMOUNT
         SKIP
      ENDDO
      IF MACTIVITY
         IF .NOT. MBEGIN
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,76 SAY '      0.00'
            MLINE = MLINE + 1
         ENDIF
         @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
         @ MLINE,5 SAY '______________________'
         @ MLINE,66 SAY MEND_BAL PICTURE '9,999,999.99'
         @ MLINE,66 SAY '____________'
         MTOTAL = MTOTAL + MEND_BAL
         MLINE = MLINE + 1
      ENDIF
      SELECT B
      SKIP
   ENDDO
   ***** NOW DO THIRD PARTY COMMISSIONS
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
   
   DO WHILE .NOT. EOF()
      STORE COM_CODE TO MCOM_CODE
      STORE NAME TO MNAME
      MBEGIN = .F. 
      MEND_BAL = 0
      MDO_NM = .T.
      MACTIVITY = .F.
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + 'T' + MCOM_CODE
      IF .NOT. EOF() .AND. MLINE <> 99
         MLINE = MLINE + 1
      ENDIF
      DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. COM_TYPE = 'T' .AND. COM_CODE = MCOM_CODE
         MACTIVITY = .T.
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,18 SAY 'COMMISSIONS LEDGER LISTING FOR ' + MMONTH 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT'
            @ 5,42 SAY '  DEBITS'  
            @ 5,55 SAY '  CREDITS'
            @ 5,68 SAY '   BALANCE'
            @ 5,01 SAY REPLICATE('_',80)
            MLINE = 7
         ENDIF
         IF MDO_NM    
            @ MLINE,1 SAY MNAME
            MDO_NM = .F.
            MLINE = MLINE + 1
         ENDIF
         IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,66 SAY AMOUNT PICTURE '9,999,999.99'
            MBEG_BAL = MBEG_BAL + AMOUNT
            MLINE = MLINE + 1
            MBEGIN = .T.
         ENDIF 
         MEND_BAL = MEND_BAL + AMOUNT
         SKIP
      ENDDO
      IF MACTIVITY
         IF .NOT. MBEGIN
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,76 SAY '      0.00'
            MLINE = MLINE + 1
         ENDIF
         @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
         @ MLINE,5 SAY '______________________'
         @ MLINE,66 SAY MEND_BAL PICTURE '9,999,999.99'
         @ MLINE,66 SAY '____________'
         MTOTAL = MTOTAL + MEND_BAL
         MLINE = MLINE + 1
      ENDIF
      SELECT B
      SKIP
   ENDDO
   
   MLINE = MLINE + 1
   @ MLINE,5 SAY 'BEGINNING BALANCES: '
   @ MLINE,73 SAY MBEG_BAL PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,5 SAY '  MONTHLY ACTIVITY:'
   @ MLINE,73 SAY (MTOTAL - MBEG_BAL) PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,5 SAY '   ENDING BALANCES: ' 
   @ MLINE,73 SAY MTOTAL PICTURE '99,999,999.99'
   
CASE MBBK_SEL = 'X'
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
      @ 10,1 SAY 'THERE IS NO LEDGER ACTIVITY ON FILE FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
      RETURN
   ENDIF
   
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
   
   DO WHILE .NOT. EOF()
      STORE COM_CODE TO MCOM_CODE
      STORE NAME TO MNAME
      MBEGIN = .F. 
      MEND_BAL = 0
      MDO_NM = .T.
      MACTIVITY = .F.
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + 'T' + MCOM_CODE
      IF .NOT. EOF() .AND. MLINE <> 99
         MLINE = MLINE + 1
      ENDIF
      DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. COM_TYPE = 'T' .AND. LED_CODE = MCOM_CODE
         MACTIVITY = .T.
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,18 SAY 'BILLBACK LEDGER LISTING FOR ' + MMONTH 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT'
            @ 5,42 SAY '  DEBITS'  
            @ 5,55 SAY '  CREDITS'
            @ 5,68 SAY '   BALANCE'
            @ 5,01 SAY REPLICATE('_',80)
            MLINE = 7
         ENDIF
         IF MDO_NM    
            @ MLINE,1 SAY MNAME
            MDO_NM = .F.
            MLINE = MLINE + 1
         ENDIF
         IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,66 SAY AMOUNT PICTURE '9,999,999.99'
            MBEG_BAL = MBEG_BAL + AMOUNT
            MLINE = MLINE + 1
            MBEGIN = .T.
         ENDIF 
         MEND_BAL = MEND_BAL + AMOUNT
         SKIP
      ENDDO
      IF MACTIVITY
         IF .NOT. MBEGIN
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,76 SAY '      0.00'
            MLINE = MLINE + 1
         ENDIF
         @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
         @ MLINE,5 SAY '______________________'
         @ MLINE,66 SAY MEND_BAL PICTURE '9,999,999.99'
         @ MLINE,66 SAY '____________'
         MTOTAL = MTOTAL + MEND_BAL
         MLINE = MLINE + 1
      ENDIF
      SELECT B
      SKIP
   ENDDO
   
   MLINE = MLINE + 1
   @ MLINE,5 SAY 'BEGINNING BALANCES: '
   @ MLINE,73 SAY MBEG_BAL PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,5 SAY '  MONTHLY ACTIVITY:'
   @ MLINE,73 SAY (MTOTAL - MBEG_BAL) PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,5 SAY '   ENDING BALANCES: ' 
   @ MLINE,73 SAY MTOTAL PICTURE '99,999,999.99'
ENDCASE
EJECT
SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON
IF MPRINTER3 <> 'DONOTPRINT'
   RUN &MPRINTIT3
ENDIF
RETURN
* EOF: LED_BAL.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 11:03 AM.
