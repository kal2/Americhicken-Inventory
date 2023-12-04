*************
* Program.: END_BAL.PRG
* Author..: Grace Keller
* Date....: 02/15/88
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINT LEDGER BEGINNING/ENDING BALANCES
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MTITLE = ' - PRINT LEDGER ENDING BALANCES'
CLEAR
@ 01,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@  2,0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
STORE ' ' TO MFRT_SEL, MSUP_SEL, MCUS_SEL, MCOM_SEL, MBBK_SEL
STORE 0 TO MTRAN_MO, MTRAN_YR
STORE 2 TO MACTION
DO WHILE MACTION = 2
   @ 04,5 SAY "SELECT WITH AN 'X' THE REPORT DESIRED (CAN SELECT ALL AT ONCE)"
   @ 05,5 SAY '    FREIGHT LEDGER: ' GET MFRT_SEL PICTURE '@!'
   @ 07,5 SAY '   PURCHASE LEDGER: ' GET MSUP_SEL PICTURE '@!'
   @ 09,5 SAY '      SALES LEDGER: ' GET MCUS_SEL PICTURE '@!'
   IF MCOMPANY <> 'DIVISION'
      @ 11,5 SAY 'COMMISSIONS LEDGER: ' GET MCOM_SEL PICTURE '@!'
   ENDIF
   @ 13,5 SAY '   BILLBACK LEDGER: ' GET MBBK_SEL PICTURE '@!'
   @ 15,5 SAY '      REPORT MONTH: ' GET MTRAN_MO PICTURE '##' RANGE 1,12
   @ 16,5 SAY '       REPORT YEAR: ' GET MTRAN_YR PICTURE '####' RANGE 1988,2099
   STORE 1 TO MACTION
   @ 24,0 SAY 'Action: ' + STR(MACTION,1)
   @ 24,12 SAY '1. Continue      2. Edit     3. Cancel'
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
   
   READ
   IF   MFRT_SEL <> ' ' .AND. MFRT_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "FREIGHT REPORT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
   ENDIF
   
   IF MSUP_SEL <> ' ' .AND. MSUP_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "PURCHASE LEDGER SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
   ENDIF
   
   IF MCUS_SEL <> ' ' .AND. MCUS_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "SALES LEDGER SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
   ENDIF
   
   IF MCOM_SEL <> ' ' .AND. MCOM_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "COMMISSION LEDGER SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
   ENDIF   
   IF MBBK_SEL <> ' ' .AND. MBBK_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "BILLBACK LEDGER SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
   ENDIF   
ENDDO

STORE SUBSTR(STR(MTRAN_MO + 100,3),2) TO MTRAN_MO
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
STORE STR(MTRAN_YR,4) TO MTRAN_YR
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

*** FREIGHT LEDGER
IF MFRT_SEL = 'X'
   MBEG_BAL = 0
   MACTIVITY = 0
   MRECEIPTS = 0
   MDISBURSE = 0
   MTOTAL = 0
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   MBEG_BAL = 0
   SELECT A
   DO FOX_USE WITH "FRTLED INDEX FRTLED", .F.
   
   SEEK MTRAN_YR + MTRAN_MO
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
   DO WHILE .NOT. EOF()
      STORE FRT_CODE TO MFRT_CODE
      STORE NAME TO MNAME
      MEND_BAL = 0
      MBEGIN = .F.
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + MFRT_CODE
      DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. FRT_CODE = MFRT_CODE
         MEND_BAL = MEND_BAL + AMOUNT
         IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
            MBEG_BAL = MBEG_BAL + AMOUNT
         ELSE  
            IF CK_NBR = SPACE(6)
               DO CASE
               CASE COR_FLG = 'R'
                  MRECEIPTS = MRECEIPTS + AMOUNT
               CASE COR_FLG = 'D'
                  MDISBURSE = MDISBURSE + AMOUNT 
               OTHERWISE
                  MACTIVITY = MACTIVITY + AMOUNT 
               ENDCASE
            ELSE
               DO CASE
               CASE COR_FLG = 'R'
                  MRECEIPTS = MRECEIPTS + AMOUNT
               OTHERWISE
                  MDISBURSE = MDISBURSE + AMOUNT   
               ENDCASE
            ENDIF
         ENDIF
         SKIP
      ENDDO
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
         @ 5,72 SAY 'ENDING BALANCE'
         @ 5,01 SAY REPLICATE('_',88)
         MLINE = 7
      ENDIF
      IF MEND_BAL <> 0
         @ MLINE,1 SAY MNAME
         @ MLINE,74 SAY MEND_BAL PICTURE '9,999,999.99'
         MTOTAL = MTOTAL + MEND_BAL
         MLINE = MLINE + 1
      ENDIF
      SELECT B
      SKIP
   ENDDO
   IF MTOTAL <> 0
      MLINE = MLINE + 1
      @ MLINE,5 SAY '   ENDING BALANCES: ' 
      @ MLINE,73 SAY MTOTAL PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,73 SAY '============='
   ENDIF
   IF MLINE + 8 >  MPAGE_LEN
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
      @ 5,72 SAY 'ENDING BALANCE'
      @ 5,01 SAY REPLICATE('_',88)
      MLINE = 7
   ENDIF
   MLINE = MLINE + 2
   @ MLINE,1 SAY 'LEDGER RECONCILIATION'
   @ MLINE,1 SAY REPLICATE('_',21)
   MLINE = MLINE + 2
   @ MLINE,8 SAY 'Beginning Balance Total: '
   @ MLINE,50  SAY MBEG_BAL PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,8 SAY 'Monthly Freight:'
   @ MLINE,50 SAY MACTIVITY PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,8 SAY 'Monthly Disbursements:'
   @ MLINE,49 say MDISBURSE PICTURE '999,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,8 say 'Monthly Receipts/Repayments:'
   @ MLINE,49 SAY MRECEIPTS PICTURE '999,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,8 SAY 'ENDING BALANCE TOTAL: '
   @ MLINE,73 SAY MBEG_BAL + MACTIVITY + MDISBURSE + MRECEIPTS PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,73 SAY '============='
   *ENDIF
   CLOSE DATA
ENDIF

**** SUPPLIER LEDGER
IF MSUP_SEL = 'X'
   MBEG_BAL = 0
   MACTIVITY = 0
   MRECEIPTS = 0
   MDISBURSE = 0
   MTOTAL = 0
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   MBEG_BAL = 0
   SELECT A
   DO FOX_USE WITH "SUPLED INDEX SUPLED", .F.
   
   SEEK MTRAN_YR + MTRAN_MO
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
   
   DO WHILE .NOT. EOF()
      IF RSUPCODE = 'I'
         SKIP
         LOOP
      ENDIF
      STORE RSUPCODE TO MRSUPCODE
      STORE NAME TO MNAME
      MEND_BAL = 0
      MBEGIN = .F.
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + MRSUPCODE
      DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. LED_CODE = MRSUPCODE
         MEND_BAL = MEND_BAL + AMOUNT
         IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
            MBEG_BAL = MBEG_BAL + AMOUNT
         ELSE  
            **IF CK_NBR = SPACE(6)
            DO CASE
            CASE COR_FLG = 'R'
               MRECEIPTS = MRECEIPTS + AMOUNT
            CASE COR_FLG = 'D'
               MDISBURSE = MDISBURSE + AMOUNT 
            OTHERWISE
               MACTIVITY = MACTIVITY + AMOUNT 
            ENDCASE
            **ELSE
            **   MDISBURSE = MDISBURSE + AMOUNT   
            **ENDIF
         ENDIF
         SKIP
      ENDDO
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
         @ 5,72 SAY 'ENDING BALANCE'
         @ 5,01 SAY REPLICATE('_',88)
         MLINE = 7
      ENDIF
      IF MEND_BAL <> 0
         @ MLINE,1 SAY MNAME
         @ MLINE,74 SAY MEND_BAL PICTURE '9,999,999.99'
         MTOTAL = MTOTAL + MEND_BAL
         MLINE = MLINE + 1
      ENDIF
      SELECT B
      SKIP
   ENDDO
   IF MTOTAL <> 0
      MLINE = MLINE + 1
      @ MLINE,5 SAY '   ENDING BALANCES: ' 
      @ MLINE,73 SAY MTOTAL PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,73 SAY '============='
   ENDIF
   IF MLINE + 8 >  MPAGE_LEN
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
      @ 5,72 SAY 'ENDING BALANCE'
      @ 5,01 SAY REPLICATE('_',88)
      MLINE = 7
   ENDIF
   MLINE = MLINE + 2
   @ MLINE,1 SAY 'LEDGER RECONCILIATION'
   @ MLINE,1 SAY REPLICATE('_',21)
   MLINE = MLINE + 2
   @ MLINE,8 SAY 'Beginning Balance Total: '
   @ MLINE,50  SAY MBEG_BAL PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,8 SAY 'Monthly Purchases:'
   @ MLINE,50 SAY MACTIVITY PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,8 SAY 'Monthly Disbursements:'
   @ MLINE,49 say MDISBURSE PICTURE '999,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,8 say 'Monthly Receipts/Repayments:'
   @ MLINE,49 SAY MRECEIPTS PICTURE '999,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,8 SAY 'ENDING BALANCE TOTAL: '
   @ MLINE,73 SAY MBEG_BAL + MACTIVITY + MDISBURSE + MRECEIPTS PICTURE '99,999,999.99'
   MLINE = MLINE + 1
   @ MLINE,73 SAY '============='
   MLINE = MLINE + 3
   MTOTAL_TR = 0
   MFIRST = .T.
   SELECT B
   GOTO TOP
   SEEK 'ID'
   DO WHILE .NOT. EOF() .AND. RSUPCODE = 'ID'
      STORE RSUPCODE TO MRSUPCODE
      STORE NAME TO MNAME
      MEND_BAL = 0
      SELECT A
      SEEK MTRAN_YR + MTRAN_MO + MRSUPCODE
      IF EOF()
         SELECT B
         SKIP
         LOOP
      ENDIF
      DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. LED_CODE = MRSUPCODE
         MEND_BAL = MEND_BAL + AMOUNT
         SKIP
      ENDDO
      
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
         @ 5,72 SAY 'ENDING BALANCE'
         @ 5,01 SAY REPLICATE('_',88)
         MLINE = 7
      ENDIF
      IF MFIRST
         @ MLINE,1 SAY 'TRANSFER PURCHASES'
         @ MLINE,1 SAY REPLICATE('_',18)
         MLINE = MLINE + 2
         MFIRST = .F.
      ENDIF
      @ MLINE,8 SAY MNAME
      @ MLINE,50  SAY MEND_BAL PICTURE '99,999,999.99'
      MTOTAL_TR = MTOTAL_TR + MEND_BAL
      MLINE = MLINE + 1
      SELECT B
      SKIP
   ENDDO
   IF MTOTAL_TR <> 0
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
         @ 5,72 SAY 'ENDING BALANCE'
         @ 5,01 SAY REPLICATE('_',88)
         MLINE = 7
      ENDIF
      @ MLINE,8 SAY 'TOTAL PURCHASE TRANSFERS: '
      @ MLINE,50  SAY MTOTAL_TR PICTURE '99,999,999.99'
      MLINE = MLINE + 1
   ENDIF
   CLOSE ALL
ENDIF

**** CUSTOMER LEDGER
IF MCUS_SEL = 'X'
   MBEG_BAL = 0
   MACTIVITY = 0
   MRECEIPTS = 0
   MDISBURSE = 0
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
   ELSE  
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
         SELECT A
         SEEK MTRAN_YR + MTRAN_MO + MBBUYCODE
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. LED_CODE = MBBUYCODE
            MEND_BAL = MEND_BAL + AMOUNT
            IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
               MBEG_BAL = MBEG_BAL + AMOUNT
            ELSE  
               IF COR_FLG = 'D'
                  MDISBURSE = MDISBURSE + AMOUNT
               ELSE
                  IF CK_NBR = SPACE(6)
                     DO CASE
                     CASE COR_FLG = 'R'
                        MRECEIPTS = MRECEIPTS + AMOUNT
                     CASE COR_FLG = 'D'
                        MDISBURSE = MDISBURSE + AMOUNT 
                     CASE COR_FLG = 'N'
                     OTHERWISE
                        MACTIVITY = MACTIVITY + AMOUNT 
                     ENDCASE
                  ELSE
                     MRECEIPTS = MRECEIPTS + AMOUNT   
                  ENDIF
               ENDIF
            ENDIF
            
            SKIP
         ENDDO
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,25 SAY 'SALES LEDGER LISTING FOR ' + MMONTH 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT'
            @ 5,72 SAY 'ENDING BALANCE'
            @ 5,01 SAY REPLICATE('_',88)
            MLINE = 7
         ENDIF
         IF MEND_BAL <> 0
            @ MLINE,1 SAY MNAME
            @ MLINE,74 SAY MEND_BAL PICTURE '9,999,999.99'
            MTOTAL = MTOTAL + MEND_BAL
            MLINE = MLINE + 1
         ENDIF
         SELECT B
         SKIP
      ENDDO
      MLINE = MLINE + 1
      @ MLINE,5 SAY '   ENDING BALANCES: ' 
      @ MLINE,73 SAY MTOTAL PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,73 SAY '============='
      IF MLINE + 8 >  MPAGE_LEN
         IF MLINE <> 99
            EJECT         
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 2,30 SAY MCOMPANY
         @ 3,1 SAY 'Page'
         @ 3,06 say mpage_no picture '99'
         @ 3,25 SAY 'SALES LEDGER LISTING FOR ' + MMONTH 
         @ 3,72  SAY DTOC(DATE())
         @ 5,1 SAY 'ACCOUNT'
         @ 5,72 SAY 'ENDING BALANCE'
         @ 5,01 SAY REPLICATE('_',88)
         MLINE = 7
      ENDIF
      MLINE = MLINE + 2
      @ MLINE,1 SAY 'LEDGER RECONCILIATION'
      @ MLINE,1 SAY REPLICATE('_',21)
      MLINE = MLINE + 2
      @ MLINE,8 SAY 'Beginning Balance Total: '
      @ MLINE,50  SAY MBEG_BAL PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,8 SAY 'Monthly Sales:'
      @ MLINE,49 SAY MACTIVITY PICTURE '999,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,8 say 'Monthly Receipts:'
      @ MLINE,49 SAY MRECEIPTS PICTURE '999,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,8 SAY 'Monthly Disbursements/Repayments:'
      @ MLINE,49 say MDISBURSE PICTURE '999,999,999.99'
      MLINE = MLINE + 1
      IF MTRAN_YR = '2005' .AND. MTRAN_MO = '01' .AND. MCOMPANY = 'MIDWEST FOOD & POULTRY'
         @ MLINE,8  SAY 'FMDC Account Moved to Notes Recveivable: '
         MFMDC = -72709.30
         @ MLINE,50 SAY MFMDC  PICTURE '99,999,999.99'
         MBEG_BAL = MBEG_BAL + MFMDC  
         MLINE = MLINE + 1
      ENDIF
      @ MLINE,8 SAY 'ENDING BALANCE TOTAL: '
      @ MLINE,73 SAY MBEG_BAL + MACTIVITY + MDISBURSE + MRECEIPTS PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,73 SAY '============='
      
      MLINE = MLINE + 3
      MTOTAL_TR = 0
      MFIRST = .T.
      SELECT B
      GOTO TOP
      SEEK 'ID'
      DO WHILE .NOT. EOF() .AND. BBUYCODE = 'ID'
         STORE BBUYCODE TO MBBUYCODE
         STORE NAME TO MNAME
         MEND_BAL = 0
         SELECT A
         SEEK MTRAN_YR + MTRAN_MO + MBBUYCODE
         IF EOF()
            SELECT B
            SKIP
            LOOP
         ENDIF
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. LED_CODE = MBBUYCODE
            MEND_BAL = MEND_BAL + AMOUNT
            SKIP
         ENDDO
         
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,25 SAY 'SALES LEDGER LISTING FOR ' + MMONTH 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT'
            @ 5,72 SAY 'ENDING BALANCE'
            @ 5,01 SAY REPLICATE('_',88)
            MLINE = 7
         ENDIF
         IF MFIRST
            @ MLINE,1 SAY 'TRANSFER SALES'
            @ MLINE,1 SAY REPLICATE('_',14)
            MLINE = MLINE + 2
            MFIRST = .F.
         ENDIF
         @ MLINE,8 SAY MNAME
         @ MLINE,50  SAY MEND_BAL PICTURE '99,999,999.99'
         MTOTAL_TR = MTOTAL_TR + MEND_BAL
         MLINE = MLINE + 1
         SELECT B
         SKIP
      ENDDO
      IF MTOTAL_TR <> 0
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,25 SAY 'SALES LEDGER LISTING FOR ' + MMONTH 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT'
            @ 5,72 SAY 'ENDING BALANCE'
            @ 5,01 SAY REPLICATE('_',88)
            MLINE = 7
         ENDIF
         @ MLINE,8 SAY 'TOTAL SALE TRANSFERS: '
         @ MLINE,50  SAY MTOTAL_TR PICTURE '99,999,999.99'
         MLINE = MLINE + 1
      ENDIF
   ENDIF
   CLOSE ALL
ENDIF

*** COMMISSION LEDGER
IF MCOM_SEL = 'X'
   MBEG_BAL = 0
   MACTIVITY = 0
   MRECEIPTS = 0
   MDISBURSE = 0
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
   ELSE  
      SELECT B
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
      
      DO WHILE .NOT. EOF()
         STORE SALE_CODE TO MCOM_CODE
         STORE NAME TO MNAME
         MBEGIN = .F. 
         MEND_BAL = 0
         SELECT A
         SEEK MTRAN_YR + MTRAN_MO + 'S' + MCOM_CODE
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. COM_TYPE = 'S' .AND. COM_CODE = MCOM_CODE
            MEND_BAL = MEND_BAL + AMOUNT
            IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
               MBEG_BAL = MBEG_BAL + AMOUNT
            ELSE  
               IF CK_NBR = SPACE(6)
                  DO CASE
                  CASE COR_FLG = 'R'
                     MRECEIPTS = MRECEIPTS + AMOUNT
                  CASE COR_FLG = 'D'
                     IF ADV_REP = 'R'
                        MRECEIPTS = MRECEIPTS + AMOUNT
                     ELSE
                        MDISBURSE = MDISBURSE + AMOUNT 
                     ENDIF
                  OTHERWISE
                     MACTIVITY = MACTIVITY + AMOUNT 
                  ENDCASE
               ELSE
                  IF ADV_REP = 'R'
                     MRECEIPTS = MRECEIPTS + AMOUNT
                  ELSE
                     MDISBURSE = MDISBURSE + AMOUNT   
                  ENDIF
               ENDIF
            ENDIF
            SKIP
         ENDDO
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,18 SAY 'COMMISSIONS LEDGER LISTING FOR ' + MMONTH 
            @ 3,70  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT'
            @ 5,64 SAY 'ENDING BALANCE'
            @ 5,01 SAY REPLICATE('_',80)
            MLINE = 7
            MDO_NM = .T.
         ENDIF
         IF MEND_BAL <> 0
            @ MLINE,1 SAY MNAME
            @ MLINE,66 SAY MEND_BAL PICTURE '9,999,999.99'
            MTOTAL = MTOTAL + MEND_BAL
            MLINE = MLINE + 2
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
         SELECT A
         SEEK MTRAN_YR + MTRAN_MO + 'T' + MCOM_CODE
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. COM_TYPE = 'T' .AND. COM_CODE = MCOM_CODE
            MEND_BAL = MEND_BAL + AMOUNT
            IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
               MBEG_BAL = MBEG_BAL + AMOUNT
            ELSE  
               IF CK_NBR = SPACE(6)
                  DO CASE
                  CASE COR_FLG = 'R'
                     MRECEIPTS = MRECEIPTS + AMOUNT
                  CASE COR_FLG = 'D'
                     MDISBURSE = MDISBURSE + AMOUNT 
                  OTHERWISE
                     MACTIVITY = MACTIVITY + AMOUNT 
                  ENDCASE
               ELSE
                  MDISBURSE = MDISBURSE + AMOUNT   
               ENDIF
            ENDIF
            SKIP
         ENDDO
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,18 SAY 'COMMISSIONS LEDGER LISTING FOR ' + MMONTH 
            @ 3,70  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT'
            @ 5,64 SAY 'ENDING BALANCE'
            @ 5,01 SAY REPLICATE('_',80)
            MLINE = 7
         ENDIF
         IF MEND_BAL <> 0
            @ MLINE,1 SAY MNAME
            @ MLINE,66 SAY MEND_BAL PICTURE '9,999,999.99'
            MTOTAL = MTOTAL + MEND_BAL
            MLINE = MLINE + 2
         ENDIF
         SELECT B
         SKIP
      ENDDO
      
      MLINE = MLINE + 1
      @ MLINE,5 SAY '   ENDING BALANCES: ' 
      @ MLINE,65 SAY MTOTAL PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,65 SAY '============='
      IF MLINE + 8 >  MPAGE_LEN
         IF MLINE <> 99
            EJECT         
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 2,30 SAY MCOMPANY
         @ 3,1 SAY 'Page'
         @ 3,06 say mpage_no picture '99'
         @ 3,20 SAY 'COMMISSION LEDGER LISTING FOR ' + MMONTH 
         @ 3,72  SAY DTOC(DATE())
         @ 5,1 SAY 'ACCOUNT'
         @ 5,72 SAY 'ENDING BALANCE'
         @ 5,01 SAY REPLICATE('_',88)
         MLINE = 7
      ENDIF
      MLINE = MLINE + 2
      @ MLINE,1 SAY 'LEDGER RECONCILIATION'
      @ MLINE,1 SAY REPLICATE('_',21)
      MLINE = MLINE + 2
      @ MLINE,8 SAY 'Beginning Balance Total: '
      @ MLINE,50  SAY MBEG_BAL PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,8 SAY 'Monthly Commissions:'
      @ MLINE,50 SAY MACTIVITY PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,8 SAY 'Monthly Disbursements:'
      @ MLINE,49 say MDISBURSE PICTURE '999,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,8 say 'Monthly Receipts/Repayments:'
      @ MLINE,49 SAY MRECEIPTS PICTURE '999,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,8 SAY 'ENDING BALANCE TOTAL: '
      @ MLINE,65 SAY MBEG_BAL + MACTIVITY + MDISBURSE + MRECEIPTS PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,65 SAY '============='
   ENDIF
   CLOSE ALL
ENDIF       

*** BILLBACK LEDGER
IF MBBK_SEL = 'X'
   MBEG_BAL = 0
   MACTIVITY = 0
   MRECEIPTS = 0
   MDISBURSE = 0
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
      @ 10,1 SAY 'THERE IS NO BILLBACK ACTIVITY ON FILE FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
   ELSE  
      SELECT B
      DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
      
      DO WHILE .NOT. EOF()
         STORE COM_CODE TO MCOM_CODE
         STORE NAME TO MNAME
         MBEGIN = .F. 
         MEND_BAL = 0
         SELECT A
         SEEK MTRAN_YR + MTRAN_MO + 'T' + MCOM_CODE
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. COM_TYPE = 'T' .AND. LED_CODE = MCOM_CODE
            MEND_BAL = MEND_BAL + AMOUNT
            IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
               MBEG_BAL = MBEG_BAL + AMOUNT
            ELSE  
               IF CK_NBR = SPACE(6)
                  DO CASE
                  CASE COR_FLG = 'R'
                     MRECEIPTS = MRECEIPTS + AMOUNT
                  CASE COR_FLG = 'D'
                     MDISBURSE = MDISBURSE + AMOUNT 
                  OTHERWISE
                     MACTIVITY = MACTIVITY + AMOUNT 
                  ENDCASE
               ELSE
                  MDISBURSE = MDISBURSE + AMOUNT   
               ENDIF
            ENDIF
            SKIP
         ENDDO
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,18 SAY 'BILLBACK LEDGER LISTING FOR ' + MMONTH 
            @ 3,70  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT'
            @ 5,64 SAY 'ENDING BALANCE'
            @ 5,01 SAY REPLICATE('_',80)
            MLINE = 7
         ENDIF
         IF MEND_BAL <> 0
            @ MLINE,1 SAY MNAME
            @ MLINE,66 SAY MEND_BAL PICTURE '9,999,999.99'
            MTOTAL = MTOTAL + MEND_BAL
            MLINE = MLINE + 2
         ENDIF
         SELECT B
         SKIP
      ENDDO
      
      MLINE = MLINE + 1
      @ MLINE,5 SAY '   ENDING BALANCES: ' 
      @ MLINE,65 SAY MTOTAL PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,65 SAY '============='
      IF MLINE + 8 >  MPAGE_LEN
         IF MLINE <> 99
            EJECT         
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 2,30 SAY MCOMPANY
         @ 3,1 SAY 'Page'
         @ 3,06 say mpage_no picture '99'
         @ 3,20 SAY 'BILLBACK LEDGER LISTING FOR ' + MMONTH 
         @ 3,72  SAY DTOC(DATE())
         @ 5,1 SAY 'ACCOUNT'
         @ 5,72 SAY 'ENDING BALANCE'
         @ 5,01 SAY REPLICATE('_',88)
         MLINE = 7
      ENDIF
      MLINE = MLINE + 2
      @ MLINE,1 SAY 'LEDGER RECONCILIATION'
      @ MLINE,1 SAY REPLICATE('_',21)
      MLINE = MLINE + 2
      @ MLINE,8 SAY 'Beginning Balance Total: '
      @ MLINE,50  SAY MBEG_BAL PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,8 SAY 'Monthly Billbacks:'
      @ MLINE,50 SAY MACTIVITY PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,8 SAY 'Monthly Disbursements:'
      @ MLINE,49 say MDISBURSE PICTURE '999,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,8 say 'Monthly Receipts/Repayments:'
      @ MLINE,49 SAY MRECEIPTS PICTURE '999,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,8 SAY 'ENDING BALANCE TOTAL: '
      @ MLINE,65 SAY MBEG_BAL + MACTIVITY + MDISBURSE + MRECEIPTS PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,65 SAY '============='
   ENDIF
   CLOSE ALL
ENDIF       
@ MLINE+1,1 SAY ' '
EJECT

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON
IF MPRINTER3 <> 'DONOTPRINT'
   RUN &MPRINTIT3
ENDIF

RETURN
* EOF: END_BAL.PRG

*Formatted by: ToolBox Ver. 1.2  on 12/9/15 at 10:03 AM.
