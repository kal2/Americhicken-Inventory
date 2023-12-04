*************
* Program.: LED_NOT.PRG
* Author..: Grace Keller
* Date....: 02/15/88
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: LEDGER LISTINGS     
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MTITLE = ' - UNMATCHED LEDGER LISTINGS/TOTALS'

CLEAR
@ 01,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@  2,0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
STORE ' ' TO MFRT_X, MSUP_X, MCUS_X, MCOM_X        
STORE 'N' TO MTOT_X
STORE 2 TO MACTION
DO WHILE MACTION = 2
   @ 05,5 SAY "SELECT WITH AN 'X' THE REPORT DESIRED (CAN SELECT MORE THAN ONE AT A TIME)"
   @ 07,5 SAY '    FREIGHT LEDGER: ' GET MFRT_X PICTURE '@!'
   @ 09,5 SAY '   PURCHASE LEDGER: ' GET MSUP_X PICTURE '@!'
   @ 11,5 SAY '      SALES LEDGER: ' GET MCUS_X PICTURE '@!'
   ***@ 13,5 SAY 'COMMISSIONS LEDGER: ' GET MCOM_X PICTURE '@!'
   @ 16,5 SAY ' TOTALS ONLY (Y/N): ' GET MTOT_X PICTURE '@!'
   STORE 1 TO MACTION
   @ 24,0 SAY 'Action: ' + STR(MACTION,1)
   @ 24,12 SAY '1. Continue      2. Edit     3. Cancel'
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
   
   READ
   DO CASE
   CASE MFRT_X <> ' ' .AND. MFRT_X <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "FREIGHT REPORT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MSUP_X <> ' ' .AND. MSUP_X <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "PURCHASE REPORT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MCUS_X <> ' ' .AND. MCUS_X <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "SALES REPORT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MCOM_X <> ' ' .AND. MCOM_X <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "COMMISSIONS REPORT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   ENDCASE
ENDDO
IF MTOT_X = 'Y'
   @ 17,5 SAY 'PROCESSING .... PLEASE WAIT....'
ENDIF


IF MFRT_X = 'X'
   @ 4,1 CLEAR TO 21,78
   IF MTOT_X = 'N'
      STORE 'N' TO MYES_NO
      @ 10,5 SAY 'Print activity only for a specific freight carrier (Y/N) ? ' get myes_no picture '@!'
      READ
      IF MYES_NO <> 'N'
         MNAME_FD = .F.
         DO FRT_SEL1
         IF .NOT. MNAME_FD
            RETURN
         ENDIF
         STORE FRT_CODE TO SFRT_CODE
         STORE 'N' TO MPAGE_SEP
      ELSE
         STORE SPACE(4) TO SFRT_CODE
         STORE 'N' TO MPAGE_SEP
         @ 13,5 SAY 'Print each account on a separate page (Y/N)? ' get MPAGE_SEP PICTURE '@!'
         READ
      ENDIF
   ELSE
      STORE SPACE(4) TO SFRT_CODE
   ENDIF
   
   **** NOW DO ALL THE PRINTS
   MMORE = .T.
   MGRAND_TOT = 0
   MFIRST_TM = .T.
   MLINE = 99
   DO WHILE MMORE
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
      
      MPAGE_NO = 0
      MPAGE_LEN = 56
      SELECT A
      USE
      SELECT B
      USE
      SELECT A
      DO FOX_USE WITH "FRTLED INDEX FRTNOMAT", .F.
      
      SELECT B
      DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
      
      IF SFRT_CODE <> SPACE(4)
         DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
         SEEK SFRT_CODE
         STORE RECNO() TO MRECNO
         DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
         GOTO MRECNO
      ELSE
         DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
      ENDIF
      
      SELECT B
      DO WHILE .NOT. EOF()
         STORE FRT_CODE TO MLED_CODE 
         STORE NAME TO MNAME
         SELECT A
         SEEK ' ' + MLED_CODE    
         MDO_NM = .T. 
         MACTIVITY = .F.
         MTOTAL = 0
         DO WHILE .NOT. EOF() .AND. MATCH_FLG = ' ' .AND. FRT_CODE = MLED_CODE
            MACTIVITY = .T.
            IF MLINE > MPAGE_LEN 
               IF MLINE <> 99
                  EJECT         
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 2,36 SAY MCOMPANY
               @ 3,1 SAY 'Page'
               @ 3,06 say mpage_no picture '99'
               @ 3,31 SAY 'FREIGHT LEDGER UNMATCHED LISTING '
               @ 3,84  SAY DTOC(DATE())
               @ 5,1 SAY 'ACCOUNT/YEAR/MONTH'
               @ 5,31 SAY 'INVOICE '
               @ 5,42 SAY 'P.O. NBR'
               @ 5,57 SAY '  DEBITS'  
               @ 5,70 SAY '  CREDITS'
               @ 5,84 SAY '   BALANCE'
               @ 5,01 SAY REPLICATE('_',93)
               MLINE = 7
               MDO_NM = .T.
            ENDIF
            MTOTAL = MTOTAL + AMOUNT
            IF MDO_NM
               @ MLINE,1 SAY MNAME
               MDO_NM = .F.
               IF MTOT_X <> 'Y' 
                  MLINE = MLINE + 1
               ENDIF
            ENDIF
            IF MTOT_X = 'N'
               @ MLINE,5 SAY STR(RECNO(),5)
               @ MLINE,12 SAY TRAN_MO   
               @ MLINE,14 SAY '/'
               @ MLINE,15 SAY TRAN_YR
               IF CK_NBR = SPACE(6)
                  DO CASE
                  CASE COR_FLG = 'I' .OR. COR_FLG = ' '
                     @ MLINE,20 SAY 'INVOICE'
                  CASE COR_FLG = 'R'
                     @ MLINE,20 SAY 'RECEIPT'
                  CASE COR_FLG = 'D'
                     @ MLINE,20 SAY 'AR REIMBURSE'
                  OTHERWISE
                     @ MLINE,20 SAY 'CORRECTION'
                  ENDCASE
               ELSE
                  @ MLINE,20 SAY 'CK #: ' + CK_NBR
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
               ELSE
                  @ MLINE,53 SAY AMOUNT PICTURE '9,999,999.99'
               ENDIF
               MLINE = MLINE + 1
            ENDIF
            SKIP
         ENDDO
         IF MACTIVITY
            IF MTOT_X = 'N'
               @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
               @ MLINE,5 SAY '______________________'
               @ MLINE,82 SAY MTOTAL PICTURE '9,999,999.99'
               @ MLINE,82 SAY '____________'
               IF MPAGE_SEP = 'Y'
                  EJECT
                  MLINE = 99
               ELSE
                  MLINE = MLINE + 2
               ENDIF
            ELSE
               @ MLINE,82 SAY MTOTAL PICTURE '9,999,999.99'
               MLINE = MLINE + 1
            ENDIF
            MGRAND_TOT = MGRAND_TOT + MTOTAL
         ENDIF
         IF SFRT_CODE <> SPACE(4)
            SELECT B
            GOTO BOTTOM
            SKIP
         ELSE
            SELECT B
            SKIP
         ENDIF
      ENDDO
      
      IF SFRT_CODE = SPACE(4)
         MMORE = .F.
         IF MTOT_X = 'Y'
            MLINE = MLINE + 1
            @ MLINE,5 SAY 'TOTAL OF OUTSTANDING FREIGHT:'
            @ MLINE,82 SAY MGRAND_TOT PICTURE '9,999,999.99'
            @ MLINE,82 SAY REPLICATE('_',12)
            EJECT
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
      ELSE
         @ MLINE+1,1 SAY ' '
         EJECT
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
         
         CLOSE DATA
         MTITLE = ' - UNMATCHED LEDGER LISTINGS/TOTALS'
         CLEAR
         @ 01,00 SAY MCOMPANY
         @ 01,68 SAY DATE()
         @  2,0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         
         STORE 'N' TO MYES_NO
         @ 10,5 SAY 'Select another freight carrier (Y/N) ? ' get myes_no picture '@!'
         READ
         
         IF MYES_NO <> 'N'
            MNAME_FD = .F.
            DO FRT_SEL1
            IF .NOT. MNAME_FD
               MMORE = .F.
               LOOP
            ENDIF
            STORE FRT_CODE TO SFRT_CODE
         ELSE
            MMORE = .F.                   
         ENDIF
      ENDIF
   ENDDO
   CLOSE DATA 
ENDIF

IF MSUP_X = 'X'
   @ 4,1 CLEAR TO 21,78
   IF MTOT_X = 'N'
      STORE 'N' TO MYES_NO
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
         STORE 'Y' TO MPAGE_SEP
      ELSE
         STORE SPACE(4) TO SRSUPCODE
         STORE 'N' TO MPAGE_SEP
         @ 13,5 SAY 'Print each account on a separate page (Y/N)? ' get MPAGE_SEP PICTURE '@!'
         READ
      ENDIF
   ELSE
      STORE SPACE(4) TO SRSUPCODE
   ENDIF
   
   *** DO THE UNMATCHED SUPPLIER PRINT
   MMORE = .T.
   MGRAND_TOT = 0
   MFIRST_TM = .T.
   MLINE = 99
   DO WHILE MMORE
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
      
      MPAGE_NO = 0
      MPAGE_LEN = 56
      SELECT A
      USE
      SELECT B
      USE
      SELECT A
      DO FOX_USE WITH "SUPLED INDEX SUPNOMAT", .F.
      
      SELECT B
      
      IF SRSUPCODE <> SPACE(4)
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
         SEEK SRSUPCODE
         STORE RECNO() TO MRECNO
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
         GOTO MRECNO
      ELSE
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
      ENDIF
      
      SELECT B
      DO WHILE .NOT. EOF()
         IF RSUPCODE = 'I'
            SKIP
            LOOP
         ENDIF
         STORE RSUPCODE TO MLED_CODE 
         STORE NAME TO MNAME
         SELECT A
         SEEK ' ' + MLED_CODE    
         MDO_NM = .T. 
         MACTIVITY = .F.
         MTOTAL = 0
         DO WHILE .NOT. EOF() .AND. MATCH_FLG = ' ' .AND. LED_CODE = MLED_CODE
            MACTIVITY = .T.
            IF MLINE > MPAGE_LEN 
               IF MLINE <> 99
                  EJECT         
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 2,36 SAY MCOMPANY
               @ 3,1 SAY 'Page'
               @ 3,06 say mpage_no picture '99'
               @ 3,31 SAY 'PURCHASE LEDGER UNMATCHED LISTING '
               @ 3,84  SAY DTOC(DATE())
               @ 5,1 SAY 'ACCOUNT/YEAR/MONTH'
               @ 5,31 SAY 'INVOICE '
               @ 5,42 SAY 'P.O. NBR'
               @ 5,57 SAY '  DEBITS'  
               @ 5,70 SAY '  CREDITS'
               @ 5,84 SAY '   BALANCE'
               @ 5,01 SAY REPLICATE('_',93)
               MLINE = 7
               MDO_NM = .T.
            ENDIF
            MTOTAL = MTOTAL + AMOUNT
            IF MDO_NM
               @ MLINE,1 SAY MNAME
               MDO_NM = .F.
               IF MTOT_X <> 'Y' 
                  MLINE = MLINE + 1
               ENDIF
            ENDIF
            IF MTOT_X = 'N'
               @ MLINE,5 SAY STR(RECNO(),5)
               @ MLINE,12 SAY TRAN_MO   
               @ MLINE,14 SAY '/'
               @ MLINE,15 SAY TRAN_YR
               IF CK_NBR = SPACE(6)
                  DO CASE
                  CASE COR_FLG = 'I' .OR. COR_FLG = ' '
                     @ MLINE,20 SAY 'INVOICE'
                  CASE COR_FLG = 'R'
                     @ MLINE,20 SAY 'RECEIPT'
                  CASE COR_FLG = 'D'
                     @ MLINE,20 SAY 'AR REIMBURSE'
                  OTHERWISE
                     @ MLINE,20 SAY 'CORRECTION'
                  ENDCASE
               ELSE
                  @ MLINE,20 SAY 'CK #: ' + CK_NBR
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
               ELSE
                  @ MLINE,53 SAY AMOUNT PICTURE '9,999,999.99'
               ENDIF
               MLINE = MLINE + 1
            ENDIF
            SKIP
         ENDDO
         IF MACTIVITY
            IF MTOT_X = 'N'
               @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
               @ MLINE,5 SAY '______________________'
               @ MLINE,82 SAY MTOTAL PICTURE '9,999,999.99'
               @ MLINE,82 SAY '____________'
               IF MPAGE_SEP = 'Y'
                  EJECT
                  MLINE = 99
               ELSE
                  MLINE = MLINE + 2
               ENDIF
            ELSE
               @ MLINE,82 SAY MTOTAL PICTURE '9,999,999.99'
               MLINE = MLINE + 1
            ENDIF
            MGRAND_TOT = MGRAND_TOT + MTOTAL
         ENDIF
         IF SRSUPCODE <> SPACE(4)
            SELECT B
            GOTO BOTTOM
            SKIP
         ELSE
            SELECT B
            SKIP
         ENDIF
      ENDDO
      
      IF SRSUPCODE = SPACE(4)
         MMORE = .F.
         IF MTOT_X = 'Y'
            MLINE = MLINE + 1
            @ MLINE,5 SAY 'TOTAL OF OUTSTANDING PAYABLES:'
            @ MLINE,82 SAY MGRAND_TOT PICTURE '9,999,999.99'
            @ MLINE,82 SAY REPLICATE('_',12)
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
      ELSE
         @ MLINE+1,1 SAY ' '
         EJECT
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
         
         CLOSE DATA
         MTITLE = ' - UNMATCHED LEDGER LISTINGS/TOTALS'
         CLEAR
         @ 01,00 SAY MCOMPANY
         @ 01,68 SAY DATE()
         @  2,0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         
         STORE 'N' TO MYES_NO
         @ 10,5 SAY 'Select another supplier (Y/N) ? ' get myes_no picture '@!'
         READ
         
         IF MYES_NO <> 'N'
            MNAME_FD = .F.
            DO RSUPSEL3
            IF .NOT. MNAME_FD
               MMORE = .F.
               LOOP
            ENDIF
            IF LED_CODE = SPACE(4) 
               STORE RSUPCODE TO SRSUPCODE
            ELSE
               STORE LED_CODE TO SRSUPCODE
            ENDIF
         ELSE
            MMORE = .F.                   
         ENDIF
      ENDIF
   ENDDO
   CLOSE DATA 
ENDIF

IF MCUS_X = 'X'
   @ 4,1 CLEAR TO 21,78
   IF MTOT_X = 'N'
      STORE 'N' TO MYES_NO
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
         STORE 'Y' TO MPAGE_SEP
      ELSE
         STORE SPACE(4) TO SBBUYCODE
         STORE 'N' TO MPAGE_SEP
         @ 13,5 SAY 'Print each account on a separate page (Y/N)? ' get MPAGE_SEP PICTURE '@!'
         READ
      ENDIF
   ELSE
      STORE SPACE(4) TO SBBUYCODE
   ENDIF
   MMORE = .T.
   MGRAND_TOT = 0
   MLINE = 99
   DO WHILE MMORE
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO lpt3
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
      
      MFIRST_TM = .T.
      MPAGE_NO = 0
      MPAGE_LEN = 56
      SELECT A
      USE
      SELECT B
      USE
      SELECT A
      DO FOX_USE WITH "CUSLED INDEX CUSNOMAT", .F.
      
      SELECT B
      
      IF SBBUYCODE <> SPACE(4)
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         SEEK SBBUYCODE
         STORE RECNO() TO MRECNO
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
         GOTO MRECNO
      ELSE
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
      ENDIF
      
      SELECT B
      DO WHILE .NOT. EOF()
         IF BBUYCODE = 'I'
            SKIP
            LOOP
         ENDIF
         STORE BBUYCODE TO MLED_CODE 
         STORE NAME TO MNAME
         SELECT A
         SEEK ' ' + MLED_CODE    
         MDO_NM = .T. 
         MACTIVITY = .F.
         MTOTAL = 0
         DO WHILE .NOT. EOF() .AND. MATCH_FLG = ' ' .AND. LED_CODE = MLED_CODE
            MACTIVITY = .T.
            IF MLINE > MPAGE_LEN 
               IF MLINE <> 99
                  EJECT         
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 2,36 SAY MCOMPANY
               @ 3,1 SAY 'Page'
               @ 3,06 say mpage_no picture '99'
               @ 3,32 SAY 'SALES LEDGER UNMATCHED LISTING '
               @ 3,84  SAY DTOC(DATE())
               @ 5,1 SAY 'ACCOUNT/YEAR/MONTH'
               @ 5,31 SAY 'INVOICE '
               @ 5,42 SAY 'P.O. NBR'
               @ 5,57 SAY '  DEBITS'  
               @ 5,70 SAY '  CREDITS'
               @ 5,84 SAY '   BALANCE'
               @ 5,01 SAY REPLICATE('_',93)
               MLINE = 7
               MDO_NM = .T.
            ENDIF
            MTOTAL = MTOTAL + AMOUNT
            IF MDO_NM
               @ MLINE,1 SAY MNAME
               MDO_NM = .F.
               IF MTOT_X <> 'Y' 
                  MLINE = MLINE + 1
               ENDIF
            ENDIF
            IF MTOT_X = 'N'
               @ MLINE,5 SAY STR(RECNO(),5)
               @ MLINE,12 SAY TRAN_MO   
               @ MLINE,14 SAY '/'
               @ MLINE,15 SAY TRAN_YR
               IF CK_NBR = SPACE(7)
                  DO CASE
                  CASE COR_FLG = 'I' .OR. COR_FLG = ' '
                     @ MLINE,20 SAY 'INVOICE'
                  CASE COR_FLG = 'R'
                     @ MLINE,20 SAY 'RECEIPT'
                  CASE COR_FLG = 'D'
                     @ MLINE,20 SAY 'AR REIMBURSE'
                  OTHERWISE
                     @ MLINE,20 SAY 'CORRECTION'
                  ENDCASE
               ELSE
                  @ MLINE,20 SAY 'CK #: ' + CK_NBR
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
               ELSE
                  @ MLINE,67 SAY AMOUNT PICTURE '9,999,999.99'
               ENDIF
               MLINE = MLINE + 1
            ENDIF
            SKIP
         ENDDO
         IF MACTIVITY
            IF MTOT_X = 'N'
               @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
               @ MLINE,5 SAY '______________________'
               @ MLINE,82 SAY MTOTAL PICTURE '9,999,999.99'
               @ MLINE,82 SAY '____________'
               IF MPAGE_SEP = 'Y'
                  EJECT
                  MLINE = 99
               ELSE
                  MLINE = MLINE + 2
               ENDIF
            ELSE
               @ MLINE,82 SAY MTOTAL PICTURE '9,999,999.99'
               MLINE = MLINE + 1
            ENDIF
            MGRAND_TOT = MGRAND_TOT + MTOTAL
         ENDIF
         IF SBBUYCODE <> SPACE(4)
            SELECT B
            GOTO BOTTOM
            SKIP
         ELSE
            SELECT B
            SKIP
         ENDIF
      ENDDO
      
      IF SBBUYCODE = SPACE(4)
         MMORE = .F.
         IF MTOT_X = 'Y'
            MLINE = MLINE + 1
            @ MLINE,5 SAY 'TOTAL OF OUTSTANDING RECEIVABLES:'
            @ MLINE,81 SAY MGRAND_TOT PICTURE '9,999,999.99'
            @ MLINE,81 SAY REPLICATE('_',12)
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
      ELSE
         @ MLINE+1,1 SAY ' '
         EJECT
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
         CLOSE DATA
         MTITLE = ' - UNMATCHED LEDGER LISTINGS/TOTALS'
         CLEAR
         @ 01,00 SAY MCOMPANY
         @ 01,68 SAY DATE()
         @  2,0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         
         STORE 'N' TO MYES_NO
         @ 10,5 SAY 'Select another customer (Y/N) ? ' get myes_no picture '@!'
         READ
         
         IF MYES_NO <> 'N'
            MNAME_FD = .F.
            DO BBUYSEL3
            IF .NOT. MNAME_FD
               MMORE = .F.
               LOOP
            ENDIF
            IF LED_CODE = SPACE(4) 
               STORE BBUYCODE TO SBBUYCODE
            ELSE
               STORE LED_CODE TO SBBUYCODE
            ENDIF
         ELSE
            MMORE = .F.                   
         ENDIF
      ENDIF
   ENDDO
   CLOSE DATA 
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
         @ 11,5 SAY " (LEAVE BLANK IF ALL COMMISSION REPORTS DESIRED)"
         @ 13,5 SAY "'X' THE APPROPRIATE COMMISSIONS CATEGORY ONLY IF NAME ENTERED ABOVE"
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
   STORE DTOC(DATE()) TO MEND_DATE
   STORE SUBSTR(MEND_DATE,7) TO MEND_YR
   STORE SUBSTR(MEND_DATE,1,2) TO MEND_MO               
   IF MEND_MO = '01'
      MEND_YR = STR(VAL(MEND_YR) - 1,2)
      MEND_MO = '12'
   ELSE
      MEND_MO = VAL(MEND_MO)-1 
      MEND_MO = SUBSTR(STR(MEND_MO+100,3),2)
   ENDIF
   STORE VAL(MEND_YR+MEND_MO) TO MEND_DATE
   MMORE = .T.
   MGRAND_TOT = 0
   MLINE = 99
   DO WHILE MMORE
      IF MTOT_X = 'N'
         STORE ' ' TO MACTION
         DO PRT_SET
         IF MACTION <> 'C'
            RETURN 
         ENDIF 
         
         SET CONSOLE OFF
         IF FILE("C:\COMPINFO\PRINTERS.DBF")
            SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
         ELSE
            SET PRINT TO lpt3
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
         
      ENDIF
      
      MFIRST_TM = .T.
      MPAGE_NO = 0
      MPAGE_LEN = 56
      SELECT A
      USE
      SELECT B
      USE
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMPD", .F.
      
      SELECT B
      
      IF MSEL_CODE = '  ' .OR. MSEL_TYPE = 'S'
         SELECT B
         IF MSEL_CODE <> SPACE(2)
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
            SEEK MSEL_CODE
            STORE RECNO() TO MRECNO
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
            GOTO MRECNO
         ELSE
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
         ENDIF
         DO WHILE .NOT. EOF()
            STORE SALE_CODE TO MCOM_CODE 
            STORE NAME TO MNAME
            SELECT A
            SEEK ' S' + MCOM_CODE    
            MDO_NM = .T. 
            MACTIVITY = .F.
            MTOTAL = 0
            DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. COM_TYPE = 'S' .AND. COM_CODE = MCOM_CODE
               MACTIVITY = .T.
               IF MLINE > MPAGE_LEN 
                  IF MLINE <> 99
                     EJECT         
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,36 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  @ 3,06 say mpage_no picture '99'
                  @ 3,30 SAY 'COMMISSION LEDGER UNMATCHED LISTING '
                  @ 3,84  SAY DTOC(DATE())
                  @ 5,1 SAY 'ACCOUNT/YEAR/MONTH'
                  @ 5,31 SAY 'INVOICE '
                  @ 5,42 SAY 'P.O. NBR'
                  @ 5,57 SAY '  DEBITS'  
                  @ 5,70 SAY '  CREDITS'
                  @ 5,84 SAY '   BALANCE'
                  @ 5,01 SAY REPLICATE('_',93)
                  MLINE = 7
                  MDO_NM = .T.
               ENDIF
               MTOTAL = MTOTAL + AMOUNT
               IF MDO_NM
                  @ MLINE,1 SAY MNAME
                  MDO_NM = .F.
                  IF MTOT_X <> 'Y' 
                     MLINE = MLINE + 1
                  ENDIF
               ENDIF
               IF MTOT_X = 'N'
                  @ MLINE,5 SAY STR(RECNO(),5)
                  @ MLINE,12 SAY TRAN_MO   
                  @ MLINE,14 SAY '/'
                  @ MLINE,15 SAY TRAN_YR
                  IF CK_NBR = SPACE(6)
                     DO CASE
                     CASE COR_FLG = 'I' .OR. COR_FLG = ' '
                        @ MLINE,20 SAY 'INVOICE'
                     CASE COR_FLG = 'R'
                        @ MLINE,20 SAY 'RECEIPT'
                     CASE COR_FLG = 'D'
                        @ MLINE,20 SAY 'AR REIMBURSE'
                     OTHERWISE
                        @ MLINE,20 SAY 'CORRECTION'
                     ENDCASE
                  ELSE
                     @ MLINE,20 SAY 'CK #: ' + CK_NBR
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
                  ELSE
                     @ MLINE,53 SAY AMOUNT PICTURE '9,999,999.99'
                  ENDIF
                  MLINE = MLINE + 1
               ENDIF
               SKIP
            ENDDO
            
            IF MACTIVITY
               IF MTOT_X = 'N'
                  @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
                  @ MLINE,5 SAY '______________________'
                  @ MLINE,82 SAY MTOTAL PICTURE '9,999,999.99'
                  @ MLINE,82 SAY '____________'
                  EJECT
                  MLINE = 99
               ELSE
                  @ MLINE,82 SAY MTOTAL PICTURE '9,999,999.99'
                  MLINE = MLINE + 1
               ENDIF
               MGRAND_TOT = MGRAND_TOT + MTOTAL
            ENDIF
            IF MSEL_CODE <> '  '    
               SELECT B
               GOTO BOTTOM
               SKIP
            ELSE
               SELECT B
               SKIP
            ENDIF
         ENDDO
      ENDIF
      
      IF MSEL_CODE = '  ' .OR. MSEL_TYPE = 'T'
         SELECT B
         IF MSEL_CODE <> SPACE(2)
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
            SEEK MSEL_CODE
            STORE RECNO() TO MRECNO
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
            GOTO MRECNO
         ELSE
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
         ENDIF
         DO WHILE .NOT. EOF()
            STORE COM_CODE TO MCOM_CODE 
            STORE NAME TO MNAME
            SELECT A
            SEEK ' S' + MCOM_CODE    
            MDO_NM = .T. 
            MACTIVITY = .F.
            MTOTAL = 0
            DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. COM_TYPE = 'T' .AND. COM_CODE = MCOM_CODE
               MACTIVITY = .T.
               IF MLINE > MPAGE_LEN 
                  IF MLINE <> 99
                     EJECT         
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,36 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  @ 3,06 say mpage_no picture '99'
                  @ 3,30 SAY 'COMMISSION LEDGER UNMATCHED LISTING '
                  @ 3,84  SAY DTOC(DATE())
                  @ 5,1 SAY 'ACCOUNT/YEAR/MONTH'
                  @ 5,31 SAY 'INVOICE '
                  @ 5,42 SAY 'P.O. NBR'
                  @ 5,57 SAY '  DEBITS'  
                  @ 5,70 SAY '  CREDITS'
                  @ 5,84 SAY '   BALANCE'
                  @ 5,01 SAY REPLICATE('_',93)
                  MLINE = 7
                  MDO_NM = .T.
               ENDIF
               MTOTAL = MTOTAL + AMOUNT
               IF MDO_NM
                  @ MLINE,1 SAY MNAME
                  MDO_NM = .F.
                  IF MTOT_X <> 'Y' 
                     MLINE = MLINE + 1
                  ENDIF
               ENDIF
               IF MTOT_X = 'N'
                  @ MLINE,5 SAY STR(RECNO(),5)
                  @ MLINE,12 SAY TRAN_MO   
                  @ MLINE,14 SAY '/'
                  @ MLINE,15 SAY TRAN_YR
                  IF CK_NBR = SPACE(6)
                     DO CASE
                     CASE COR_FLG = 'I' .OR. COR_FLG = ' '
                        @ MLINE,20 SAY 'INVOICE'
                     CASE COR_FLG = 'R'
                        @ MLINE,20 SAY 'RECEIPT'
                     CASE COR_FLG = 'D'
                        @ MLINE,20 SAY 'AR REIMBURSE'
                     OTHERWISE
                        @ MLINE,20 SAY 'CORRECTION'
                     ENDCASE
                  ELSE
                     @ MLINE,20 SAY 'CK #: ' + CK_NBR
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
                  ELSE
                     @ MLINE,53 SAY AMOUNT PICTURE '9,999,999.99'
                  ENDIF
                  MLINE = MLINE + 1
               ENDIF
               SKIP
            ENDDO
            
            IF MACTIVITY
               IF MTOT_X = 'N'
                  @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
                  @ MLINE,5 SAY '______________________'
                  @ MLINE,82 SAY MTOTAL PICTURE '9,999,999.99'
                  @ MLINE,82 SAY '____________'
                  EJECT
                  MLINE = 99
               ELSE
                  @ MLINE,82 SAY MTOTAL PICTURE '9,999,999.99'
                  MLINE = MLINE + 1
               ENDIF
               MGRAND_TOT = MGRAND_TOT + MTOTAL
            ENDIF
            IF MSEL_CODE <> '  '    
               SELECT B
               GOTO BOTTOM
               SKIP
            ELSE
               SELECT B
               SKIP
            ENDIF
         ENDDO
      ENDIF
      
      IF MSEL_CODE = '  '     
         MMORE = .F.
         IF MTOT_X = 'Y'
            MLINE = MLINE + 1
            @ MLINE,5 SAY 'TOTAL OF OUTSTANDING COMMISSIONS:'
            @ MLINE,81 SAY MGRAND_TOT PICTURE '9,999,999.99'
            @ MLINE,81 SAY REPLICATE('_',12)
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
         
      ELSE
         @ MLINE+1,1 SAY ' '
         EJECT
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
         
         CLOSE DATA
         MTITLE = ' - UNMATCHED LEDGER LISTINGS/TOTALS'
         CLEAR
         @ 01,00 SAY MCOMPANY
         @ 01,68 SAY DATE()
         @  2,0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         
         STORE 'N' TO MYES_NO
         @ 10,5 SAY 'Select another commission payee (Y/N) ? ' get myes_no picture '@!'
         READ
         
         IF MYES_NO <> 'N'
            
            @ 4,1 clear to 21,78
            STORE SPACE(32) TO MNAME
            STORE SPACE(1) TO MSALE_SEL, MTHIRD_SEL, MSEL_TYPE
            STORE 2 TO MACTION      
            DO WHILE MACTION = 2      
               @ 10,5 SAY 'COMMISSIONS PAYEE NAME: '
               @ 10,29 GET MNAME PICTURE '@!'
               @ 11,5 SAY " (LEAVE BLANK IF ALL COMMISSION REPORTS DESIRED)"
               @ 13,5 SAY "'X' THE APPROPRIATE COMMISSIONS CATEGORY ONLY IF NAME ENTERED ABOVE"
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
               MMORE = .F.
            ENDIF  
         ELSE
            MMORE = .F.                   
         ENDIF
      ENDIF
   ENDDO
   CLOSE DATA 
   
ENDIF

CLOSE DATA

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON

RETURN
* EOF: LED_NOT.PRG


*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 11:13 AM.
