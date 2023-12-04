**********
* Program.: COM_MENU.PRG
* Author..: GRACE KELLER
* Date....: 01/22/88
* Notice..: Copyright 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: COMMISSIONS MENU   
*
* ---PROCESSING LOOP
STORE '  ' TO MSEL

DO WHILE VAL(MSEL) <> 99
   SET PROC TO PO_PROC
   
   CLEAR
   @ 1,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 02,00 SAY MPROGRAM + ' - COMMISSIONS MENU'
   @ 03,00 TO 24,79 
   
   @ 04,09 SAY '1 - APPROVE ALL SALESPERSON COMMISSIONS THAT CAN BE PAID'
   @ 05,09 SAY '2 - SELECTIVELY APPROVE SALESPERSON COMMISSIONS FOR PAYMENT'
   @ 06,09 SAY '3 - UN-APPROVE ALL MIDWEST COMMISSIONS'      
   
   @ 08,09 say '4 - PRINT COMMISSIONS APPROVED FOR PAYMENT (OR PAID) REPORT'
   @ 09,09 say '     (Note: If approved for payment, run BEFORE Check Print)'
   @ 10,09 SAY '5 - UPDATE MISC. ADJUSTMENTS TO MIDWEST MONTHLY COMMISSION CHECKS'
   
   @ 12,09 SAY '6 - PRINT MIDWEST COMMISSION CHECKS / PROCESS WIRES / MARK PAID'      
   @ 13,09 SAY '7 - PRINT MONTHLY COMMISSION STATEMENTS/LEDGERS (MIDWEST ONLY)'
   @ 14,09 SAY '8 - INTEREST/WITHDRAWALS / ACTIVITY LIST FOR RESERVE ACCOUNTS'
   
   @ 16,09 SAY '9 - APPROVE THIRD PARTY COMMISSIONS FOR PAYMENT'
   @ 17,09 SAY '9A- UPDATE THIRD PARTY ADJUSTMENTS/DEDUCTIONS TO COMMISSION CHECKS'
   @ 18,09 SAY '10- PRINT THIRD PARTY COMMISSION CHECKS'
   @ 20,09 SAY '11- PRINT DATE-TO-DATE COMMISSIONS PAID REPORT (1099 INFO)'
   @ 21,09 SAY '12- PRINT 1099-MISC FORMS'
   @ 22,09 SAY '99- EXIT TO MENU'
   STORE '  ' TO MSEL
   @ 24,01 SAY 'CHOICE: '
   @ 24,09 get MSEL picture '@!'
   READ
   
   DO CASE
      
   CASE VAL(MSEL) = 1
      DO BUILDCOM
   CASE VAL(MSEL) = 2
      DO APRV_COM
   CASE VAL(MSEL) = 3
      SELECT C
      DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
      DO FILELOCK
      REPLACE ALL APRVD_FLG WITH ' ' FOR COM_PD = ' ' .and. COM_TYPE = 'S'
      UNLOCK
      
   CASE VAL(MSEL) = 4 
      
      MTITLE = ' - PRINT REPORT OF COMMISSIONS TO BE OR ALREADY PAID'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      STORE SPACE(1) TO MSALE_SEL, MTHIRD_SEL
      
      STORE 2 TO MACTION
      DO WHILE MACTION = 2      
         @ 12,5 SAY "'X' THE APPROPRIATE COMMISSIONS CATEGORY"
         @ 14,5 SAY 'COMPANY SALESPERSON:             THIRD PARTY COMMISSION:'
         @ 14,26 GET MSALE_SEL PICTURE '@!'
         @ 14,62 GET MTHIRD_SEL PICTURE '@!'
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue      2.  Edit      3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
      ENDDO
      
      IF MACTION = 3
         LOOP
      ENDIF
      IF MTHIRD_SEL = ' ' .AND. MSALE_SEL = ' '
         LOOP
      ENDIF
      
      IF MTHIRD_SEL = 'X'
         ***IF MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
         DO ACOM_RPT
         LOOP
      ENDIF
      
      **** DO ALL THE PRINT ROUTINE STUFF
      MTITLE = ' - PRINT REPORT OF COMMISSIONS TO BE OR ALREADY PAID'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      STORE SPACE(32) TO MNAME
      STORE SPACE(1) TO MSEL_TYPE
      STORE SPACE(2) TO MSEL_CODE
      STORE 'Y' TO MYES_NO
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 10,5 SAY 'COMMISSIONS PAYEE NAME: '
         @ 10,29 GET MNAME PICTURE '@!'
         @ 11,5 SAY " (LEAVE BLANK IF REPORT DESIRED FOR ALL COMMISSIONS)"
         @ 16,5 SAY 'Is This Report Before Check Print (Y/N)? ' GET MYES_NO PICTURE '@!'
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue      2.  Edit      3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1 .AND. MNAME <> SPACE(32)
            IF MSALE_SEL = 'X'
               STORE 'S' TO MSEL_TYPE
               SELECT A
               DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
               SEEK TRIM(MNAME)
               IF .NOT. EOF()
                  STORE RECNO() TO MFST_REC
                  SKIP
                  STORE TRIM(MNAME) TO SRCH_ARG
                  IF NAME = SRCH_ARG    
                     MNAME_FD = .F.
                     DO MULTSAL
                     IF MNAME_FD
                        STORE NAME TO MNAME
                        STORE SALE_CODE TO MSEL_CODE
                        MACTION = 1
                     ELSE
                        MACTION = 3
                        LOOP
                     ENDIF
                  ELSE
                     GOTO MFST_REC
                     STORE NAME TO MNAME
                     STORE SALE_CODE TO MSEL_CODE
                  ENDIF
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
               STORE 'T' TO MSEL_TYPE
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
               SEEK TRIM(MNAME)
               IF .NOT. EOF()
                  STORE RECNO() TO MFST_REC
                  SKIP
                  STORE TRIM(MNAME) TO SRCH_ARG
                  IF NAME = SRCH_ARG    
                     MNAME_FD = .F.
                     DO MULTCOM
                     IF MNAME_FD
                        STORE NAME TO MNAME
                        STORE COM_CODE TO MSEL_CODE
                        MACTION = 1
                     ELSE
                        MACTION = 3
                        LOOP
                     ENDIF
                  ELSE
                     GOTO MFST_REC
                     STORE NAME TO MNAME
                     STORE COM_CODE TO MSEL_CODE
                  ENDIF
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
      ENDDO
      IF MACTION = 3
         LOOP  
      ENDIF  
      STORE CTOD(' ') TO MDATE
      IF MYES_NO = 'N'
         @ 18,23 SAY 'Enter Check Paid Date: '                         
         @ 18,46 GET MDATE
         READ
         STORE .F. TO MBEFORE
      ELSE
         STORE .T. TO MBEFORE
      ENDIF
      
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP   
      ENDIF
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 10 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
      MPAGE_LEN = 54
      MLINE = 99
      MPAGE_NO = 0
      SELECT C 
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      SELECT D 
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      SELECT B 
      DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMPD", .F.
      DO CASE 
      CASE MBEFORE   
         SEEK ' '
         DO WHILE .NOT. EOF() .AND. COM_PD = ' '
            IF APRVD_FLG = ' '
               SKIP
               LOOP
            ENDIF
            IF MSEL_CODE <> SPACE(2)
               IF MSEL_CODE <> COM_CODE .OR. MSEL_TYPE <> COM_TYPE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            STORE COM_CODE TO MCOM_CODE
            STORE COM_TYPE TO MCOM_TYPE
            MTOTAL = 0
            IF MCOM_TYPE = 'S'
               SELECT A
               DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               SEEK MCOM_CODE  
               IF .NOT. EOF()
                  STORE NAME TO MNAME     
               ELSE
                  STORE 'SALESPERSON NOT ON FILE' TO MNAME
               ENDIF
               MPAGE_NO = 0
               USE RESERVE
               SUM AMOUNT TO MADVANCE FOR SALESMAN = MCOM_CODE .AND. CATEGORY = '7301'                         
               SUM AMOUNT TO MREPAID FOR SALESMAN = MCOM_CODE .AND. CATEGORY = '7350'                           
            ELSE
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               SEEK MCOM_CODE  
               IF .NOT. EOF()
                  STORE NAME TO MNAME
               ELSE
                  STORE 'THIRD PARTY NOT ON FILE' TO MNAME
               ENDIF
               MPAGE_NO = 0
            ENDIF
            MAMT99 = 0
            MAMT98 = 0
            SELECT B
            DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. COM_CODE = MCOM_CODE .AND. COM_TYPE = MCOM_TYPE
               IF APRVD_FLG = ' '
                  SKIP
                  LOOP
               ENDIF
               IF MSEL_CODE <> SPACE(2)
                  IF MSEL_CODE <> COM_CODE .OR. MSEL_TYPE <> COM_TYPE
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,3-2 SAY 'PAGE ' + STR(MPAGE_NO,2) 
                  @ 2,32-2 SAY MCOMPANY
                  @ 2,69 SAY DATE()
                  @ 3,32-2 SAY 'COMMISSIONS REPORT'
                  @ 4,32-2 SAY MNAME
                  IF MCOM_TYPE = 'T'
                     @ 6,14-2 SAY 'SHIP DATE'
                     @ 6,27-2 SAY 'PO NUMBER'
                     *@ 6,38 SAY 'CUST PO'
                  ELSE
                     @ 6,3-2 SAY 'SHIP DATE'
                     @ 6,14-2 SAY 'SOLD TO'
                     @ 6,43-2 SAY 'PO NUMBER'
                  ENDIF
                  @ 6,57-2 SAY 'INVOICE NBR'
                  @ 6,76-2 SAY 'AMOUNT'
                  @ 6,14-2 SAY REPLICATE('_',68)
                  MLINE = 8
                  
               ENDIF
               STORE SPACE(5) TO MBROK_NAME
               STORE CTOD(' ') TO MSHIP_DATE
               SELECT C
               IF B->SALESMAN = '72'
                  DO FOX_USE WITH "L:PO_HEAD INDEX L:PO_HEAD", .F.
               ELSE
                  DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
               ENDIF
               
               SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
               IF .NOT. EOF()
                  STORE BBUYCODE TO MBBUYCODE
                  STORE BROK_NAME TO MBROK_NAME
                  STORE SHIP_DATE TO MSHIP_DATE
                  STORE BUYER_PO TO MBUYER_PO
                  IF MBBUYCODE = 'NONE'
                     STORE 'NONE' TO MBBUYNAME
                  ELSE
                     SELECT D
                     SEEK MBBUYCODE
                     IF .NOT. EOF()
                        STORE NAME TO MBBUYNAME
                     ELSE
                        STORE 'SOLD TO NOT ON FILE' TO MBBUYNAME
                     ENDIF
                  ENDIF
               ELSE 
                  STORE SPACE(32) TO MBBUYNAME
                  STORE SPACE(15) TO MBUYER_PO
                  MSHIP_DATE = CTOD('')
               ENDIF
               
               
               SELECT B
               IF MCOM_TYPE = 'T'
                  @ MLINE,14-2 SAY MSHIP_DATE
               ELSE
                  @ MLINE,3-2 SAY MSHIP_DATE
                  IF MCOM_CODE <> SALESMAN
                     @ MLINE,14-2 SAY 'INTRA-COMPANY:'
                     IF SALESMAN <> SPACE(2)
                        @ MLINE,29-2 SAY SALESMAN
                     ELSE
                        @ MLINE,29-2 SAY MBROK_NAME
                     ENDIF
                  ELSE
                     @ MLINE,14-2 SAY SUBSTR(MBBUYNAME,1,20)
                  ENDIF
               ENDIF
               IF MCOM_TYPE = 'T'
                  @ MLINE,27-2 SAY SALESMAN
                  IF SALESMAN <> SPACE(2)
                     @ MLINE,29-2 SAY '-'
                  ENDIF
                  
                  @ MLINE,30-2 SAY PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,34-2 SAY '-'
                     @ MLINE,35-2 SAY PO_SUFFIX
                  ENDIF
                  *@ MLINE,38-2 SAY MBUYER_PO
               ELSE
                  @ MLINE,43-2 SAY SALESMAN
                  IF SALESMAN <> SPACE(2)
                     @ MLINE,45-2 SAY '-'
                  ENDIF
                  
                  @ MLINE,46-2 SAY PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,50-2 SAY '-'
                     @ MLINE,51-2 SAY PO_SUFFIX
                  ENDIF
               ENDIF
               @ MLINE,57-2 SAY SALESMAN
               IF SALESMAN <> '  '
                  @ MLINE,59-2 SAY '-'
               ENDIF
               @ MLINE,60-2 SAY INV_NBR
               IF COM_CODE = '99' .AND. MSHIP_DATE < CTOD('12/05/94')
                  MX = ROUND(AMOUNT/2,2)
                  MTOTAL = MTOTAL + MX
                  MAMT98 = MAMT98 + (AMOUNT-MX)
               ELSE
                  MTOTAL = MTOTAL + AMOUNT
               ENDIF
               @ MLINE,72-2 SAY AMOUNT PICTURE '999,999.99'
               
               MLINE = MLINE + 1
               SKIP
            ENDDO
            MLINE = MLINE + 1
            @ MLINE,3-2 SAY 'TOTAL: '
            @ MLINE,70-2 SAY MTOTAL PICTURE '9,999,999.99'
            IF MAMT98 <> 0
               MLINE = MLINE + 1
               @ MLINE,3-2 SAY 'TOTAL 98: '
               @ MLINE,70-2 SAY MAMT98 PICTURE '9,999,999.99'
            ENDIF
            IF MSEL_TYPE = 'S'
               IF MADVANCE + MREPAID <> 0
                  MLINE = MLINE + 3
                  @ MLINE,3-2 SAY 'COMMISSIONS ADVANCED:'
                  @ MLINE,70-2 SAY MADVANCE PICTURE '9,999,999.99'
                  MLINE = MLINE + 1
                  @ MLINE,3-2 SAY '     ADVANCES REPAID:'
                  @ MLINE,70-2 SAY MREPAID PICTURE '9,999,999.99'
                  MLINE = MLINE + 1
                  @ MLINE,3-2 SAY '    ADVANCES BALANCE:'
                  @ MLINE,70-2 SAY MADVANCE + MREPAID PICTURE '9,999,999.99'
               ENDIF
            ENDIF
            MLINE = 70
         ENDDO
      OTHERWISE
         MLINE = 99
         SEEK 'Y'
         DO WHILE .NOT. EOF() .AND. COM_PD = 'Y'
            IF MSEL_CODE <> SPACE(2)
               IF MSEL_CODE <> COM_CODE .OR. MSEL_TYPE <> COM_TYPE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            STORE COM_CODE TO MCOM_CODE
            STORE COM_TYPE TO MCOM_TYPE
            IF MLINE <> 99
               MLINE = 70
            ENDIF
            MTOTAL = 0
            IF MCOM_TYPE = 'S'
               SELECT A
               DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               SEEK MCOM_CODE  
               IF .NOT. EOF()
                  STORE NAME TO MNAME     
               ELSE
                  STORE 'SALESPERSON NOT ON FILE' TO MNAME
               ENDIF
               MPAGE_NO = 0
               USE RESERVE
               SUM AMOUNT TO MADVANCE FOR SALESMAN = MCOM_CODE .AND. CATEGORY = '7301' .AND. MDATE <= TRAN_DATE
               SUM AMOUNT TO MREPAID FOR SALESMAN = MCOM_CODE .AND. CATEGORY = '7350' .AND. MDATE <= TRAN_DATE
            ELSE
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               SEEK MCOM_CODE  
               IF .NOT. EOF()
                  STORE NAME TO MNAME
               ELSE
                  STORE 'THIRD PARTY NOT ON FILE' TO MNAME
               ENDIF
               MPAGE_NO = 0
            ENDIF
            SELECT B
            DO WHILE .NOT. EOF() .AND. COM_PD = 'Y' .AND. COM_CODE = MCOM_CODE .AND. COM_TYPE = MCOM_TYPE
               IF MDATE <> PAID_DATE
                  SKIP
                  LOOP
               ENDIF
               IF MSEL_CODE <> SPACE(2)
                  IF MSEL_CODE <> COM_CODE .OR. MSEL_TYPE <> COM_TYPE
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,3-2 SAY 'PAGE ' + STR(MPAGE_NO,2) 
                  @ 2,32-2 SAY MCOMPANY
                  @ 2,69 SAY DATE()
                  @ 3,32-2 SAY 'COMMISSIONS REPORT'
                  @ 4,32-2 SAY MNAME
                  IF MCOM_TYPE = 'T'
                     @ 6,14-2 SAY 'SHIP DATE'
                     @ 6,27-2 SAY 'PO NUMBER'
                     *@ 5,38-2 SAY 'CUST PO'
                  ELSE
                     @ 6,3-2 SAY 'SHIP DATE'
                     @ 6,14-2 SAY 'SOLD TO'
                     @ 6,43-2 SAY 'PO NUMBER'
                  ENDIF
                  @ 6,57-2 SAY 'INVOICE NBR'
                  @ 6,76-2 SAY 'AMOUNT'
                  @ 6,3-2 SAY REPLICATE('_',79)
                  MLINE = 8
                  
               ENDIF
               STORE SPACE(5) TO MBROK_NAME
               STORE CTOD(' ') TO MSHIP_DATE
               SELECT C
               IF B->SALESMAN = '72'
                  DO FOX_USE WITH "L:PO_HEAD INDEX L:PO_HEAD", .F.
               ELSE
                  DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
               ENDIF
               SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
               IF .NOT. EOF()
                  STORE BBUYCODE TO MBBUYCODE
                  STORE BROK_NAME TO MBROK_NAME
                  STORE SHIP_DATE TO MSHIP_DATE
                  STORE BUYER_PO TO MBUYER_PO
                  IF MBBUYCODE = 'NONE'
                     STORE 'NONE' TO MBBUYNAME
                  ELSE
                     SELECT D
                     SEEK MBBUYCODE
                     IF .NOT. EOF()
                        STORE NAME TO MBBUYNAME
                     ELSE
                        STORE 'SOLD TO NOT ON FILE' TO MBBUYNAME
                     ENDIF
                  ENDIF
               ELSE 
                  STORE SPACE(32) TO MBBUYNAME
                  STORE SPACE(15) TO MBUYER_PO
               ENDIF
               SELECT B
               IF MCOM_TYPE = 'T'
                  @ MLINE,14-2 SAY MSHIP_DATE
               ELSE
                  @ MLINE,3-2 SAY MSHIP_DATE
                  IF MCOM_CODE <> SALESMAN
                     @ MLINE,14-2 SAY 'INTRA-COMPANY:'
                     IF SALESMAN <> SPACE(2)
                        @ MLINE,29-2 SAY SALESMAN
                     ELSE
                        @ MLINE,29-2 SAY MBROK_NAME
                     ENDIF
                  ELSE
                     @ MLINE,14-2 SAY SUBSTR(MBBUYNAME,1,20)
                  ENDIF
               ENDIF
               IF MCOM_TYPE = 'T'
                  @ MLINE,27-2 SAY SALESMAN
                  IF SALESMAN <> SPACE(2)
                     @ MLINE,29-2 SAY '-'
                  ENDIF
                  
                  @ MLINE,30-2 SAY PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,34-2 SAY '-'
                     @ MLINE,35-2 SAY PO_SUFFIX
                  ENDIF
                  *@ MLINE,38-2 SAY MBUYER_PO                  
               ELSE
                  @ MLINE,43-2 SAY SALESMAN
                  IF SALESMAN <> SPACE(2)
                     @ MLINE,45-2 SAY '-'
                  ENDIF
                  
                  @ MLINE,46-2 SAY PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,50-2 SAY '-'
                     @ MLINE,51-2 SAY PO_SUFFIX
                  ENDIF
               ENDIF
               @ MLINE,57-2 SAY SALESMAN
               IF SALESMAN <> '  '
                  @ MLINE,59-2 SAY '-'
               ENDIF
               @ MLINE,60-2 SAY INV_NBR
               @ MLINE,72-2 SAY AMOUNT PICTURE '999,999.99'
               MTOTAL = MTOTAL + AMOUNT
               MLINE = MLINE + 1
               SKIP
            ENDDO
            MLINE = MLINE + 1
            @ MLINE,3-2 SAY 'TOTAL: '
            @ MLINE,70-2 SAY MTOTAL PICTURE '9,999,999.99'
            IF MSEL_TYPE = 'S'
               IF MADVANCE + MREPAID <> 0
                  MLINE = MLINE + 3
                  @ MLINE,3-2 SAY 'COMMISSIONS ADVANCED:'
                  @ MLINE,70-2 SAY MADVANCE PICTURE '9,999,999.99'
                  MLINE = MLINE + 1
                  @ MLINE,3-2 SAY '     ADVANCES REPAID:'
                  @ MLINE,70-2 SAY MREPAID PICTURE '9,999,999.99'
                  MLINE = MLINE + 1
                  @ MLINE,3-2 SAY '    ADVANCES BALANCE:'
                  @ MLINE,70-2 SAY MADVANCE + MREPAID PICTURE '9,999,999.99'
               ENDIF
            ENDIF
         ENDDO
      ENDCASE
      IF MLINE <> 99
         @ MLINE+1,1 SAY ' '
         EJECT
      ENDIF
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
   CASE VAL(MSEL) = 5
      **********
      * Program.: COM_ADJ.PRG
      * Author..: GRACE KELLER
      * Date....: 04/11/88
      * Notice..: CopyRight 1988, Solid Software, Inc., All Rights Reserved
      * Version.: FOXPRO
      * Notes...: MISCELLANEOUS ADJUSTMENTS TO COMMISSION CHECKS
      *
      * ---PROCESSING LOOP
      SELECT A
      DO FOX_USE WITH "COM_ADJ INDEX COM_ADJ", .F.
      CLEAR
      @ 1,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 02,00 SAY MPROGRAM + ' - UPDATE ADJUSTMENTS TO COMMISSION CHECKS'
      @ 03,00 TO 24,79 
      
      @ 6,1 SAY 'SALESPERSON: ' 
      @ 10,1 SAY '1. AMOUNT:              ACCOUNT:'
      @ 12,1 SAY '2. AMOUNT:              ACCOUNT:'
      @ 14,1 SAY '3. AMOUNT:              ACCOUNT:'
      @ 16,1 SAY '4. AMOUNT:              ACCOUNT:'
      @ 18,1 SAY '5. AMOUNT:              ACCOUNT:'
      @ 20,1 SAY 'NOTE: DEDUCTIONS MUST BE ENTERED AS NEGATIVE AMOUNTS !'
      STORE 1 TO MACTION
      @ 24,0 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Save/Update Another    2. Edit   3. Save/Finished    4. Cancel'
      
      MMORE = .T.
      DO WHILE MMORE
         STORE SPACE(32) TO MNAME
         STORE 0 TO MAMOUNT1, MAMOUNT2, MAMOUNT3, MAMOUNT4, MAMOUNT5
         STORE SPACE(4) TO MACCOUNT1, MACCOUNT2, MACCOUNT3, MACCOUNT4, MACCOUNT5
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 21,1 CLEAR TO 21,78
            @ 6,14 GET MNAME PICTURE '@!'
            
            @ 10,12 GET MAMOUNT1 PICTURE '###,###.##'
            @ 10,35 GET MACCOUNT1 PICTURE '#####'
            
            @ 12,12 GET MAMOUNT2 PICTURE '###,###.##'
            @ 12,35 GET MACCOUNT2 PICTURE '#####'
            
            @ 14,12 GET MAMOUNT3 PICTURE '###,###.##'
            @ 14,35 GET MACCOUNT3 PICTURE '#####'
            
            @ 16,12 GET MAMOUNT4 PICTURE '###,###.##'
            @ 16,35 GET MACCOUNT4 PICTURE '#####'
            
            @ 18,12 GET MAMOUNT5 PICTURE '###,###.##'
            @ 18,35 GET MACCOUNT5 PICTURE '#####'
            
            CLEAR GETS
            @ 6,14 GET MNAME PICTURE '@!'
            READ
            IF MNAME = SPACE(32)
               MACTION = 4
               LOOP
            ENDIF
            SELECT B
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
            SEEK TRIM(MNAME)
            IF EOF()
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT
               @ 24,0 SAY 'SALESPERSON NAME NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
               READ
               MACTION = 2
               LOOP
            ENDIF
            STORE SALE_CODE TO MCOM_CODE 
            STORE NAME TO MNAME
            SELECT A
            SEEK 'S' + MCOM_CODE
            IF .NOT. EOF()
               STORE AMOUNT1 TO MAMOUNT1
               STORE AMOUNT2 TO MAMOUNT2
               STORE AMOUNT3 TO MAMOUNT3
               STORE AMOUNT4 TO MAMOUNT4
               STORE AMOUNT5 TO MAMOUNT5
               STORE ACCOUNT1 TO MACCOUNT1
               STORE ACCOUNT2 TO MACCOUNT2
               STORE ACCOUNT3 TO MACCOUNT3
               STORE ACCOUNT4 TO MACCOUNT4
               STORE ACCOUNT5 TO MACCOUNT5
               @ 4,14 SAY MNAME PICTURE '@!'
               MNEW_RCD = .F.
            ELSE
               MNEW_RCD = .T.
            ENDIF
            @ 6,14 SAY MNAME PICTURE '@!'
            
            @ 10,12 GET MAMOUNT1 PICTURE '###,###.##'
            @ 10,35 GET MACCOUNT1 PICTURE '#####'
            
            @ 12,12 GET MAMOUNT2 PICTURE '###,###.##'
            @ 12,35 GET MACCOUNT2 PICTURE '#####'
            
            @ 14,12 GET MAMOUNT3 PICTURE '###,###.##'
            @ 14,35 GET MACCOUNT3 PICTURE '#####'
            
            @ 16,12 GET MAMOUNT4 PICTURE '###,###.##'
            @ 16,35 GET MACCOUNT4 PICTURE '#####'
            
            @ 18,12 GET MAMOUNT5 PICTURE '###,###.##'
            @ 18,35 GET MACCOUNT5 PICTURE '#####'
            
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Save/Update Another    2. Edit   3. Save/Finished    4. Cancel'
            READ
            MTOT = MAMOUNT1 + MAMOUNT2 + MAMOUNT3 + MAMOUNT4 + MAMOUNT5
            @ 21,1 SAY 'TOTAL ADJUSTMENTS:'
            @ 21,20 SAY MTOT PICTURE '###,###.##'
            
            @ 24,9 GET MACTION PICTURE '#' RANGE 1,4
            READ
            
            IF MACTION = 1 .OR. MACTION = 3
               IF SUBSTR(MACCOUNT1,1,2) = '84'
                  IF VAL(MACCOUNT1) < 8401 .OR. VAL(MACCOUNT1) > 8424
                     @ 24,0 CLEAR
                     STORE 'ACCOUNT 1 IS NOT ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT ' TO MJUNK
                     @ 24,1 GET MJUNK
                     READ
                     @ 24,1 CLEAR
                     MACTION = 2
                     LOOP
                  ENDIF
               ENDIF
               
               IF SUBSTR(MACCOUNT2,1,2) = '84'
                  IF VAL(MACCOUNT2) < 8401 .OR. VAL(MACCOUNT2) > 8424
                     @ 24,0 CLEAR
                     STORE 'ACCOUNT 2 IS NOT ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT ' TO MJUNK
                     @ 24,1 GET MJUNK
                     READ
                     @ 24,1 CLEAR
                     MACTION = 2
                     LOOP
                  ENDIF
               ENDIF
               
               IF SUBSTR(MACCOUNT3,1,2) = '84'
                  IF VAL(MACCOUNT3) < 8401 .OR. VAL(MACCOUNT3) > 8424
                     @ 24,0 CLEAR
                     STORE 'ACCOUNT 3 IS NOT ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT ' TO MJUNK
                     @ 24,1 GET MJUNK
                     READ
                     @ 24,1 CLEAR
                     MACTION = 2
                     LOOP
                  ENDIF
               ENDIF
               
               IF SUBSTR(MACCOUNT4,1,2) = '84'
                  IF VAL(MACCOUNT4) < 8401 .OR. VAL(MACCOUNT4) > 8424
                     @ 24,0 CLEAR
                     STORE 'ACCOUNT 4 IS NOT ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT ' TO MJUNK
                     @ 24,1 GET MJUNK
                     READ
                     @ 24,1 CLEAR
                     MACTION = 2
                     LOOP
                  ENDIF
               ENDIF
               
               IF SUBSTR(MACCOUNT5,1,2) = '84'
                  IF VAL(MACCOUNT5) < 8401 .OR. VAL(MACCOUNT5) > 8424
                     @ 24,0 CLEAR
                     STORE 'ACCOUNT 5 IS NOT ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT ' TO MJUNK
                     @ 24,1 GET MJUNK
                     READ
                     @ 24,1 CLEAR
                     MACTION = 2
                     LOOP
                  ENDIF
               ENDIF
               
            ENDIF
         ENDDO
         IF MACTION = 4
            MMORE = .F.
         ENDIF
         
         IF MNAME = SPACE(32)
            MMORE = .F.
            LOOP
         ENDIF
         
         IF MNEW_RCD       
            IF MTOT = 0
               LOOP
            ENDIF
            DO FILELOCK
            APPEND BLANK
            REPLACE COM_CODE WITH MCOM_CODE 
            REPLACE COM_TYPE WITH 'S'
            UNLOCK
         ELSE
            IF MTOT = 0
               DELETE
               LOOP
            ENDIF
         ENDIF
         DO RECLOCK
         REPLACE AMOUNT1 WITH MAMOUNT1
         REPLACE AMOUNT2 WITH MAMOUNT2
         REPLACE AMOUNT3 WITH MAMOUNT3
         REPLACE AMOUNT4 WITH MAMOUNT4
         REPLACE AMOUNT5 WITH MAMOUNT5
         REPLACE ACCOUNT1 WITH MACCOUNT1
         REPLACE ACCOUNT2 WITH MACCOUNT2
         REPLACE ACCOUNT3 WITH MACCOUNT3
         REPLACE ACCOUNT4 WITH MACCOUNT4
         REPLACE ACCOUNT5 WITH MACCOUNT5
         UNLOCK
         
      ENDDO
      
      CLOSE DATA
   CASE VAL(MSEL) = 6 
      *MTITLE = ' - PROCESS COMMISSION CHECKS/WIRES OR MARK ENTRIES SALARY PAID'
      *CLEAR
      *@  1, 0 SAY MCOMPANY
      *@  1,68 SAY DATE()
      *@  2, 0 SAY MPROGRAM + MTITLE
      *@ 3,0 to 24,79
      *MCHOICE = SPACE(6)
      *@ 10,5 SAY 'Do you want to process commission checks/wires (CHECKS)'
      *@ 12,5 SAY 'or mark entries paid by salary (SALARY) ? ' get mchoice picture '@!'
      *READ
      *DO CASE
      *CASE MCHOICE = 'CHECKS'
      DO MCOM_CHK 
      LOOP
      ***** DO NOT DO THIS SALARY MARKING ANYMORE. . AS OF 10/24/94
      *CASE MCHOICE = 'SALARY'
      MTITLE = ' - MARK APPROVED COMMISSIONS PAID BY SALARY'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      @ 4,5 SAY 'The following salespersons have approved order amounts:'
      MLINE = 6
      MNEGATIVE = .F.
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMPD", .F.
      SEEK ' S'
      DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. COM_TYPE = 'S'
         STORE COM_CODE TO MCOM_CODE
         
         MTOT = 0
         MACT_FLG = .F.
         
         DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. COM_TYPE = 'S' .AND. COM_CODE = MCOM_CODE
            IF APRVD_FLG <> 'Y'
               SKIP
               LOOP
            ENDIF
            MTOT = MTOT + AMOUNT 
            MACT_FLG = .T.
            SKIP
         ENDDO
         *IF MTOT <> 0
         IF MACT_FLG
            @ MLINE,5 SAY 'Salesperson - ' + mcom_code + SPACE(5) + TRANSFORM(MTOT, '9,999,999.99')
            MLINE = MLINE + 1
            IF MTOT < 0
               MNEGATIVE = .T.
            ENDIF
         ENDIF
         
      ENDDO
      IF MLINE = 6   
         STORE ' ' TO MWAIT
         @ MLINE,1 SAY 'There are NO orders approved - press return to continue ' get mwait
         READ
         CLOSE DATA
         LOOP  
      ELSE  
         MLINE = MLINE + 1
         IF MNEGATIVE
            STORE ' ' TO MWAIT
            @ MLINE,5 SAY 'Cannot continue.  At least one person has a negative amount' 
            @ mline+1,5 say 'approved.  Unapprove until they have zero or positive amount. ' GET MWAIT
            READ
            CLOSE DATA
            LOOP  
         ELSE
            store '   ' to myes_no
            DO WHILE MYES_NO <> 'YES' .AND. MYES_NO <> 'NO'
               @ MLINE,5 SAY 'Do you want to continue (YES/NO)? ' get myes_no picture '@!'
               READ
            ENDDO
            IF MYES_NO <> 'YES'
               CLOSE DATA
               LOOP  
            ENDIF
         ENDIF
      ENDIF
      MTITLE = ' - PROCESS COMMISSION CHECKS/WIRES OR MARK ENTRIES SALARY PAID'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      MDATE = CTOD(' ')
      @ 10,5 SAY 'Enter date of Salary/Payroll Check: ' GET MDATE
      READ
      @ 14,5 SAY 'Please wait..... processing...'
      
      CLOSE DATA
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
      DO WHILE .NOT. EOF()
         IF COM_PD <> ' ' .OR. COM_TYPE <> 'S'
            SKIP
            LOOP
         ENDIF
         IF APRVD_FLG = 'Y'
            DO FILELOCK 
            REPLACE COM_PD WITH 'Y'
            REPLACE PAID_DATE WITH MDATE 
            UNLOCK
         ENDIF
         SKIP
      ENDDO
      CLOSE DATA
      LOOP   
      *ENDCASE
      
      
      
   CASE VAL(MSEL) = 7 
      *     DO COM_STMT
      STORE SPACE(2) TO MTRAN_MO, MOPT_CODE
      STORE SPACE(4) TO MTRAN_YR
      *** THIS COMMISSION STATEMENT TEMPORARILY SUSPEND PRINT
      *** DO NEW_COM
      *******************************************************
      *
      MTITLE = ' - PRINT MONTHLY SALESPERSON LEDGER STATEMENTS'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 24,79
      STORE CTOD(' ') TO MDATE
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 7,5 say '(OPTIONAL) SALESPERSON CODE: ' GET MOPT_CODE                              
         @ 8,5 SAY '(If salesperson not selected, all ledgers will be printed)'
         @ 11,5 SAY 'ENTER LEDGER MONTH: ' GET MTRAN_MO PICTURE '##'
         @ 13,5 SAY ' ENTER LEDGER YEAR: ' GET MTRAN_YR PICTURE '####'
         
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2. Edit    3. Cancel'    
         READ   
         @ 24,9 GET MACTION PICTURE '9' RANGE 1,3
         READ
      ENDDO
      IF MACTION = 3
         LOOP   
      ENDIF
      MACTION = ' '
      DO PRT_SET
      
      IF MACTION <> 'C'
         LOOP
      ENDIF
      
      @ 17,5 say 'PROCESSING........ PLEASE WAIT'
      
      CLOSE DATA
      MTOTAL = 0
      MFIRST_TM = .T.
      MLINE = 1 
      MPAGE_NO = 0
      MPAGE_LEN = 56
      
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
      
      SELECT C
      DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED", .F.
      SELECT B
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
      
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
      
      DO WHILE .NOT. EOF()
         IF MOPT_CODE <> '  '
            IF SALE_CODE <> MOPT_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
         STORE SALE_CODE TO MCOM_CODE
         STORE NAME TO MNAME
         MDO_NM = .T. 
         MEND_BAL = 0
         MBEG_BAL = 0
         MACTIVITY = .F.
         MACCT_PAGE = 0
         STORE 0 TO MCHECKS, MINVOICES, MADVANCE, MREPAID
         SELECT A
         SEEK MTRAN_YR + MTRAN_MO + 'S' + MCOM_CODE
         
         IF .NOT. EOF() .AND. AMOUNT = 0
            SKIP 
         ENDIF
         IF .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. COM_TYPE = 'S' .AND. COM_CODE = MCOM_CODE .AND. MLINE <> 99
            MLINE = 79
         ENDIF
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. COM_TYPE = 'S' .AND. COM_CODE = MCOM_CODE
            MACTIVITY = .T.
            IF MLINE > MPAGE_LEN 
               IF MLINE <> 99
                  EJECT         
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               MACCT_PAGE = MACCT_PAGE + 1
               @ 2,40 SAY MCOMPANY
               @ 3,1 SAY 'Page'
               @ 3,6 SAY MTRAN_MO + '-' + STR(MACCT_PAGE,2)
               @ 3,28 SAY 'COMMISSIONS LEDGER LISTING FOR ' + MMONTH + " '" + MTRAN_YR
               @ 3,82  SAY DTOC(DATE())
               @ 5,1 SAY 'ACCOUNT/DATE/ITEM'
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
               @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
               @ MLINE,83 SAY AMOUNT PICTURE '999,999.99'
               STORE AMOUNT TO MBEG_BAL
            ELSE  
               @ MLINE,5 SAY TRAN_DATE
               IF CK_NBR = SPACE(6)
                  DO CASE
                  CASE COR_FLG = 'R'
                     @ MLINE,16 SAY 'RECEIPT'
                  CASE COR_FLG = 'D'
                     @ MLINE,16 SAY 'A/R REIMBURSE'
                  OTHERWISE
                     IF COR_FLG = 'I' .OR. COR_FLG = ' '
                        IF COM_CODE = SALESMAN   
                           @ MLINE,16 SAY 'INVOICE'
                        ELSE
                           @ MLINE,16 SAY 'INTRACOMPANY-INVOICE'
                        ENDIF
                     ELSE
                        IF COM_CODE = SALESMAN  
                           @ MLINE,16 SAY 'CORRECTION'
                        ELSE
                           @ MLINE,16 SAY 'INTRACOMPANY-CORRECTION'
                        ENDIF
                     ENDIF
                     MINVOICES = MINVOICES + AMOUNT
                  ENDCASE
               ELSE
                  IF INV_NBR = SPACE(4)
                     @ MLINE,16 SAY 'CK #: ' + CK_NBR
                  ELSE
                     SELECT C
                     SEEK SUBSTR(A->INV_NBR,1,4)
                     IF EOF()
                        @ MLINE,16 SAY 'CK #: ' + CK_NBR
                     ELSE
                        @ MLINE,16 SAY DESCRIP           
                     ENDIF
                     SELECT A
                  ENDIF
                  STORE CK_NBR TO MCK_NBR
                  DO CASE
                  CASE ADV_REP = ' '
                     MCHECKS = MCHECKS + AMOUNT 
                  CASE ADV_REP = 'A'
                     MADVANCE = MADVANCE + AMOUNT 
                  CASE ADV_REP = 'R'
                     MREPAID = MREPAID + AMOUNT 
                  ENDCASE
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
            @ MLINE,83 SAY MEND_BAL PICTURE '999,999.99'
            @ MLINE,83 SAY '__________'
            MTOTAL = MTOTAL + MEND_BAL
            MLINE = MLINE + 1
            IF MLINE > 48
               IF MLINE <> 99
                  EJECT         
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               MACCT_PAGE = MACCT_PAGE + 1
               @ 2,40 SAY MCOMPANY
               @ 3,1 SAY 'Page'
               @ 3,6 SAY MTRAN_MO + '-' + STR(MACCT_PAGE,2)
               @ 3,28 SAY 'COMMISSIONS LEDGER LISTING FOR ' + MMONTH + " '" + MTRAN_YR
               @ 3,82  SAY DTOC(DATE())
               @ 5,1 SAY 'ACCOUNT/DATE/ITEM'
               @ 5,42 SAY 'P.O. NBR'
               @ 5,57 SAY '  DEBITS'  
               @ 5,70 SAY '  CREDITS'
               @ 5,84 SAY '   BALANCE'
               @ 5,01 SAY REPLICATE('_',93)
               @ 7,1 SAY MNAME
               MLINE = 8
               MDO_NM = .F.
            ENDIF
            mline = mline + 2
            @ mline,5 say 'Month beginning balance: '
            @ mline,39 say mbeg_bal picture '9,999,999.99'
            mline = mline + 1
            @ mline,5 say 'Total monthly invoice activity:'
            @ mline,39 say minvoices picture '9,999,999.99'
            mline = mline + 1
            @ mline,5 say 'Commissions paid this month:'
            @ mline,39 say mchecks picture '9,999,999.99'
            mline = mline + 1
            IF MADVANCE <> 0
               @ MLINE,5 SAY 'Commissions advanced this month:'
               @ mline,39 say madvance picture '9,999,999.99'
               MLINE = MLINE + 1
            ENDIF
            IF MREPAID <> 0
               @ MLINE,5 SAY 'Commissions repaid this month:'
               @ mline,39 say mrepaid picture '9,999,999.99'
               MLINE = MLINE + 1
            ENDIF
            @ mline,5 say 'Month ending balance: ' 
            @ mline,39 say mend_bal picture '9,999,999.99'
         ENDIF
         SELECT B
         SKIP
      ENDDO
      
      EJECT
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      
   CASE VAL(MSEL) = 8
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - INTEREST/WITHDRAWALS ACTIVITY LISTS FOR RESERVE ACCTS'
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      STORE ' ' TO MCHOICE
      @ 10,1 SAY '(E)nter interest/withdrawals  OR  (P)rint activity list (E/P) ? ' get mchoice picture '@!'
      READ
      DO CASE
      CASE MCHOICE = 'E'
         STORE 0 TO MTRAN_MO
         **STORE SPACE(4)    TO MCATEGORY
         STORE SPACE(2) TO MSALESMAN
         STORE 0    TO MAMOUNT    
         STORE ' ' TO MACT_CODE
         STORE CTOD(' ') TO MTRAN_DATE
         SELECT B
         DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
         
         *     SELECT B
         *     DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.RESERVE INDEX &MDBFLOC.RESERVE", .F.
         STORE 1 TO MACTION
         MRE_UPD = .T.
         DO WHILE MRE_UPD
            
            CLEAR 
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            MTITLE = ' - ENTER INTEREST/WITHDRAWALS TO RESERVE ACCTS'
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            @  5,5 SAY  ' Bank Transaction Date:'
            @  8, 5 SAY '      Salesperson Code:'
            @ 11,5 say  '                Amount:'
            @ 14,5 say '          Activity Code:'
            @ 16,5 say '(Note: Activity Codes:)'   
            @ 17,5 say "(    'I' - Interest   )"  
            @ 18,5 say "(    'W' - Withdrawal )"
            @ 19,5 say "(    'R' - Re-Deposit )"
            @ 5,30 GET MTRAN_DATE                          
            @ 8,30 GET Msalesman PICTURE '##'
            @ 11,30 GET MAMOUNT PICTURE '999999.99'
            @ 14,30 GET MACT_CODE PICTURE '@!' 
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
            @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
            
            DO CASE
               
            CASE MACTION = 1
               IF msalesman  = SPACE(2)
                  MRE_UPD = .F.
                  LOOP
               ENDIF
               IF MACT_CODE <> 'W' .AND. MACT_CODE <> 'I' .AND. MACT_CODE <> 'R'
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  @ 24,1 SAY 'INVALID ACTIVITY CODE - PRESS RETURN TO REENTER ' GET MWAIT
                  READ
                  @ 24,0      
                  LOOP
               ENDIF
               
               SELECT B
               SEEK MSALESMAN
               IF EOF()
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  @ 24,1 SAY 'INVALID SALESPERSON CODE - PRESS RETURN TO REENTER ' GET MWAIT
                  READ
                  @ 24,0      
                  LOOP
               ENDIF
               STORE RES_PAID TO MCATEGORY
               
               SELECT A
               DO FILELOCK
               APPEND BLANK
               STORE MONTH(MTRAN_DATE) TO MTRAN_MO
               STORE SUBSTR(STR(MTRAN_MO + 100,3),2) TO MTRAN_MO
               REPLACE TRAN_MO WITH MTRAN_MO
               REPLACE TRAN_DATE WITH MTRAN_DATE
               STORE YEAR(MTRAN_DATE) TO MTRAN_YR
               REPLACE TRAN_YR WITH STR(MTRAN_YR,4)
               REPLACE CATEGORY WITH MCATEGORY
               IF MAMOUNT < 0
                  MAMOUNT = MAMOUNT * -1
               ENDIF
               REPLACE AMOUNT WITH MAMOUNT      
               REPLACE ACT_CODE WITH MACT_CODE
               REPLACE SALESMAN WITH MSALESMAN
               UNLOCK
               
               SELECT B
               DO RECLOCK
               DO CASE
               CASE MACT_CODE = 'I'
                  REPLACE INTEREST WITH INTEREST + MAMOUNT
                  *              DO CASE
                  *              CASE MCATEGORY = '8405'
                  *                 REPLACE INT44 WITH INT44 + MAMOUNT
                  *              CASE MCATEGORY = '8406'
                  *                 REPLACE INT55 WITH INT55 + MAMOUNT
                  *              CASE MCATEGORY = '8407'
                  *                 REPLACE INT66 WITH INT66 + MAMOUNT
                  *              CASE MCATEGORY = '8408'
                  *                 REPLACE INT77 WITH INT77 + MAMOUNT
                  *              CASE MCATEGORY = '8409'
                  *                 REPLACE INT88 WITH INT88 + MAMOUNT
                  *              ENDCASE
               CASE MACT_CODE = 'W' 
                  REPLACE WITHDRAW WITH WITHDRAW + MAMOUNT
               CASE MACT_CODE = 'R'
                  REPLACE WITHDRAW WITH WITHDRAW - MAMOUNT      
                  *              DO CASE
                  *              CASE MCATEGORY = '8405'
                  *                 REPLACE WITH44 WITH WITH44 + MAMOUNT
                  *              CASE MCATEGORY = '8406'
                  *                 REPLACE WITH55 WITH WITH55 + MAMOUNT
                  *              CASE MCATEGORY = '8407'
                  *                 REPLACE WITH66 WITH WITH66 + MAMOUNT
                  *              CASE MCATEGORY = '8408'
                  *                 REPLACE WITH77 WITH WITH77 + MAMOUNT
                  *              CASE MCATEGORY = '8409'
                  *                 REPLACE WITH88 WITH WITH88 + MAMOUNT
                  *              ENDCASE
               ENDCASE
               STORE CTOD(' ') TO MTRAN_DATE
               STORE SPACE(2)    TO MSALESMAN
               STORE 0    TO MAMOUNT    
               STORE ' ' TO MACT_CODE
               
            CASE MACTION = 2
               LOOP
               
            CASE MACTION = 3
               MRE_UPD = .F.
               
            ENDCASE
            
         ENDDO
      CASE MCHOICE = 'P'
         MTITLE = ' - PRINT MONTHLY SALESPERSON RESERVE BANK STATEMENTS'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         STORE CTOD(' ') TO MDATE
         STORE SPACE(2) TO MOPT_SALE
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 10,5 SAY 'ENTER STATEMENT MONTH ENDING DATE: ' GET MDATE
            @ 12,5 SAY '(OPTIONAL)       SALESPERSON CODE: ' GET MOPT_SALE PICTURE '##'
            
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2. Edit    3. Cancel'    
            READ   
            @ 24,9 GET MACTION PICTURE '9' RANGE 1,3
            READ
         ENDDO
         IF MACTION = 3
            LOOP  
         ENDIF
         MACTION = ' '
         DO PRT_SET
         IF MACTION <> 'C'
            LOOP
         ENDIF
         MLINE = 99
         @ 15,5 say 'PROCESSING........ PLEASE WAIT'
         STORE DTOC(MDATE) TO MCHAR_DATE
         STORE SUBSTR(MCHAR_DATE,1,2) + '/01/' + SUBSTR(MCHAR_DATE,7) TO MBEG_DATE
         STORE CTOD(MBEG_DATE) TO MBEG_DATE
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
         ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
         
         *** LETTER SIZE PAPER
         ?? CHR(27) + '&l2A'
         
         *** PORTRAIT MODE
         ?? CHR(27) + '&l0O'
         
         SELECT B
         DO FOX_USE WITH "&MDBFLOC.RESERVE INDEX &MDBFLOC.RESERVE", .F.
         
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
         DO WHILE .NOT. EOF()
            IF RPT_PRT = ' ' 
               SKIP
               LOOP
            ENDIF
            IF MOPT_SALE <> SPACE(2)
               IF MOPT_SALE <> SALE_CODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            STORE SALE_CODE TO MSALESMAN 
            STORE NAME TO MNAME
            SELECT B
            SEEK MSALESMAN
            IF MLINE <> 99
               MLINE = 60
            ENDIF
            MBEG_BAL = 0
            DO WHILE .NOT. EOF() .AND. TRAN_DATE < MBEG_DATE .AND. SALESMAN = MSALESMAN
               IF ACT_CODE <> ' '
                  IF ACT_CODE = 'W'
                     MBEG_BAL = MBEG_BAL - AMOUNT
                  ELSE
                     MBEG_BAL = MBEG_BAL + AMOUNT
                  ENDIF
               ENDIF
               SKIP
            ENDDO 
            *** NOW THAT I HAVE BEGINNING BALANCE - SEE WHETHER THERE IS ANY
            *** ACTIVITY FOR THIS TIME PERIOD
            
            MPRT = .F.
            DO WHILE .NOT. EOF() .AND. TRAN_DATE <= MDATE .AND. SALESMAN = MSALESMAN
               
               IF MLINE > 56
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  
                  @ 06,30 SAY MCOMPANY                       
                  @ 08,25 SAY 'RESERVE ACCOUNT STATEMENT ENDING ' + DTOC(MDATE)
                  @ 10,33 SAY MNAME
                  @ 13,5 SAY MBEG_DATE
                  @ 13,25 SAY 'BEGINNING BALANCE'
                  @ 13,50 SAY MBEG_BAL PICTURE '999,999.99'
                  MLINE = 15
               ENDIF
               MPRT = .T.
               
               IF ACT_CODE <> ' '
                  @ MLINE,5 SAY TRAN_DATE
                  DO CASE
                  CASE ACT_CODE = 'D'
                     @ MLINE,25 SAY 'DEPOSIT'
                     MBEG_BAL = MBEG_BAL + AMOUNT
                  CASE ACT_CODE  = 'I'
                     @ MLINE,25 SAY 'INTEREST'
                     MBEG_BAL = MBEG_BAL + AMOUNT
                  CASE ACT_CODE  = 'R'
                     @ MLINE,25 SAY 'RE-DEPOSIT'          
                     MBEG_BAL = MBEG_BAL + AMOUNT
                  CASE ACT_CODE = 'W'
                     @ MLINE,25 SAY 'WITHDRAWAL'
                     MBEG_BAL = MBEG_BAL - AMOUNT
                  ENDCASE
                  @ MLINE,50 SAY AMOUNT PICTURE '999,999.99'
                  MLINE = MLINE + 2
               ENDIF
               SKIP
            ENDDO
            DO CASE
            CASE MPRT
               @ MLINE,5 SAY MDATE           
               @ MLINE,25 SAY 'ENDING BALANCE'
               @ MLINE,50 SAY MBEG_BAL PICTURE '999,999.99'
               
            CASE .NOT. MPRT
               IF MBEG_BAL <> 0
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  
                  @ 06,30 SAY MCOMPANY                       
                  @ 08,25 SAY 'RESERVE ACCOUNT STATEMENT ENDING ' + DTOC(MDATE)
                  @ 10,33 SAY MNAME
                  @ 13,5 SAY MBEG_DATE
                  @ 13,25 SAY 'BEGINNING BALANCE'
                  @ 13,50 SAY MBEG_BAL PICTURE '999,999.99'
                  MLINE = 15
                  
                  @ MLINE,5 SAY MDATE           
                  @ MLINE,25 SAY 'ENDING BALANCE'
                  @ MLINE,50 SAY MBEG_BAL PICTURE '999,999.99'
               ENDIF
            ENDCASE  
            
            SELECT A
            SKIP
         ENDDO
         IF MLINE  <> 99
            @ MLINE + 1,1 SAY ' '
            EJECT
         ENDIF
         
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
         
      ENDCASE
      CLOSE DATA
      
   CASE MSEL = '9 ' .OR. MSEL = ' 9' 
      DO APRV_AM
   CASE MSEL = '9A'
      SELECT A
      DO FOX_USE WITH "THD_ADJ INDEX THD_ADJ", .F.
      CLEAR
      @ 1,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 02,00 SAY MPROGRAM + ' - UPDATE THIRD PARTY ADJUSTMENTS/DEDUCTIONS'
      @ 03,00 TO 24,79 
      
      @ 6,1 SAY '       NAME: ' 
      @ 10,1 SAY '1. AMOUNT:              ACCOUNT:'
      @ 12,1 SAY '2. AMOUNT:              ACCOUNT:'
      @ 14,1 SAY '3. AMOUNT:              ACCOUNT:'
      @ 16,1 SAY '4. AMOUNT:              ACCOUNT:'
      @ 18,1 SAY '5. AMOUNT:              ACCOUNT:'
      @ 20,1 SAY 'NOTE: DEDUCTIONS MUST BE ENTERED AS NEGATIVE AMOUNTS !'
      STORE 1 TO MACTION
      @ 24,0 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Save/Update Another    2. Edit   3. Save/Finished    4. Cancel'
      
      MMORE = .T.
      DO WHILE MMORE
         STORE SPACE(32) TO MNAME
         STORE 0 TO MAMOUNT1, MAMOUNT2, MAMOUNT3, MAMOUNT4, MAMOUNT5
         STORE SPACE(4) TO MACCOUNT1, MACCOUNT2, MACCOUNT3, MACCOUNT4, MACCOUNT5
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 21,1 CLEAR TO 21,78
            @ 6,14 GET MNAME PICTURE '@!'
            
            @ 10,12 GET MAMOUNT1 PICTURE '###,###.##'
            @ 10,35 GET MACCOUNT1 PICTURE '#####'
            
            @ 12,12 GET MAMOUNT2 PICTURE '###,###.##'
            @ 12,35 GET MACCOUNT2 PICTURE '#####'
            
            @ 14,12 GET MAMOUNT3 PICTURE '###,###.##'
            @ 14,35 GET MACCOUNT3 PICTURE '#####'
            
            @ 16,12 GET MAMOUNT4 PICTURE '###,###.##'
            @ 16,35 GET MACCOUNT4 PICTURE '#####'
            
            @ 18,12 GET MAMOUNT5 PICTURE '###,###.##'
            @ 18,35 GET MACCOUNT5 PICTURE '#####'
            
            CLEAR GETS
            @ 6,14 GET MNAME PICTURE '@!'
            READ
            IF MNAME = SPACE(32)
               MACTION = 4
               LOOP
            ENDIF
            SELECT B
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
            SEEK TRIM(MNAME)
            IF EOF()
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT
               @ 24,0 SAY 'THIRD PARTY NAME NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
               READ
               MACTION = 2
               @ 24,0 CLEAR
               LOOP
            ENDIF
            STORE COM_CODE TO MCOM_CODE 
            STORE NAME TO MNAME
            SELECT A
            SEEK 'T' + MCOM_CODE
            IF .NOT. EOF()
               STORE AMOUNT1 TO MAMOUNT1
               STORE AMOUNT2 TO MAMOUNT2
               STORE AMOUNT3 TO MAMOUNT3
               STORE AMOUNT4 TO MAMOUNT4
               STORE AMOUNT5 TO MAMOUNT5
               STORE ACCOUNT1 TO MACCOUNT1
               STORE ACCOUNT2 TO MACCOUNT2
               STORE ACCOUNT3 TO MACCOUNT3
               STORE ACCOUNT4 TO MACCOUNT4
               STORE ACCOUNT5 TO MACCOUNT5
               @ 4,14 SAY MNAME PICTURE '@!'
               MNEW_RCD = .F.
            ELSE
               MNEW_RCD = .T.
            ENDIF
            @ 6,14 SAY MNAME PICTURE '@!'
            
            @ 10,12 GET MAMOUNT1 PICTURE '###,###.##'
            @ 10,35 GET MACCOUNT1 PICTURE '#####'
            
            @ 12,12 GET MAMOUNT2 PICTURE '###,###.##'
            @ 12,35 GET MACCOUNT2 PICTURE '#####'
            
            @ 14,12 GET MAMOUNT3 PICTURE '###,###.##'
            @ 14,35 GET MACCOUNT3 PICTURE '#####'
            
            @ 16,12 GET MAMOUNT4 PICTURE '###,###.##'
            @ 16,35 GET MACCOUNT4 PICTURE '#####'
            
            @ 18,12 GET MAMOUNT5 PICTURE '###,###.##'
            @ 18,35 GET MACCOUNT5 PICTURE '#####'
            
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Save/Update Another    2. Edit   3. Save/Finished    4. Cancel'
            READ
            MTOT = MAMOUNT1 + MAMOUNT2 + MAMOUNT3 + MAMOUNT4 + MAMOUNT5
            @ 21,1 SAY 'TOTAL ADJUSTMENTS:'
            @ 21,20 SAY MTOT PICTURE '###,###.##'
            
            @ 24,9 GET MACTION PICTURE '#' RANGE 1,4
            READ
            
         ENDDO
         IF MACTION = 4
            MMORE = .F.
         ENDIF
         
         IF MNAME = SPACE(32)
            MMORE = .F.
            LOOP
         ENDIF
         
         IF MNEW_RCD       
            IF MTOT = 0
               LOOP
            ENDIF
            DO FILELOCK
            APPEND BLANK
            REPLACE COM_CODE WITH MCOM_CODE 
            REPLACE COM_TYPE WITH 'T'
            UNLOCK
         ELSE
            IF MTOT = 0
               DELETE
               LOOP
            ENDIF
         ENDIF
         DO RECLOCK
         REPLACE AMOUNT1 WITH MAMOUNT1
         REPLACE AMOUNT2 WITH MAMOUNT2
         REPLACE AMOUNT3 WITH MAMOUNT3
         REPLACE AMOUNT4 WITH MAMOUNT4
         REPLACE AMOUNT5 WITH MAMOUNT5
         REPLACE ACCOUNT1 WITH MACCOUNT1
         REPLACE ACCOUNT2 WITH MACCOUNT2
         REPLACE ACCOUNT3 WITH MACCOUNT3
         REPLACE ACCOUNT4 WITH MACCOUNT4
         REPLACE ACCOUNT5 WITH MACCOUNT5
         UNLOCK
         
      ENDDO
      
      CLOSE DATA
      
      
   CASE VAL(MSEL) = 10
      DO ACOM_CHK

   CASE VAL(MSEL) = 11
      MTITLE = ' - PRINT DATE-TO-DATE COMMISSIONS DISBURSED REPORT'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      STORE SPACE(32) TO MOPT_NAME
      STORE SPACE(1) TO MSAL_TYPE, MTHD_TYPE
      STORE CTOD(' ') TO MBEG_DATE, MEND_DATE
      ** HERE
      STORE 'S' TO MRPT_TYPE

      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 06,5 SAY 'SUMMARY (S) -OR- DETAIL (D) REPORT: ' GET MRPT_TYPE PICTURE '@!' VALID(MRPT_TYPE = 'S' .OR. MRPT_TYPE = 'D') 
         @ 08,5 SAY 'REPORT BEGINNING DATE: ' GET MBEG_DATE
         @ 10,5 SAY '   REPORT ENDING DATE: ' GET MEND_DATE
         
         @ 13,5 SAY 'Note:  If optional name is left blank -'
         @ 14,5 SAY "       ALL 1099'S will be printed."
         @ 16,5 SAY 'Optional Payee Name:' GET MOPT_NAME PICTURE '@!'
         @ 17,5 SAY "If Payee Name entered - Select Payee Type with an 'X'"
         @ 18,5 SAY 'Company Salesperson:     or    Third Party:'
         @ 18,26 GET MSAL_TYPE PICTURE '@!'
         @ 18,49 GET MTHD_TYPE PICTURE '@!'
         
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2. Edit    3. Cancel'    
         READ   
         @ 24,9 GET MACTION PICTURE '9' RANGE 1,3
         READ
      ENDDO
      IF MACTION = 3
         LOOP  
      ENDIF
      MACTION = ' '

      DO PRT_SET

      @ 4,1 CLEAR TO 22,78
      @ 5,5 SAY 'In order to continue, a temporary file must be created. '
      @ 6,5 SAY 'To create this temporary file, NO ONE can be posting commissions,'
      @ 7,5 say 'disbursements or running a commissions report.  When you have'
      @ 8,5 say 'determined NO ONE is doing any of the above functions, you are'
      @ 9,5 say 'ready to proceed with the next step of this report.'
      STORE 'NO ' TO MANSWER
      SET CONFIRM ON
      @ 12,5 SAY 'Are you ready to continue (YES/NO)? ' get manswer PICTURE '@!'
      READ
      SET CONFIRM OFF
      IF MANSWER <> 'YES'
         LOOP  
      ENDIF
      @ 15,5 say 'PROCESSING........ PLEASE WAIT'
      IF MRPT_TYPE = 'S'
         DO SUM_1099
         LOOP
      ENDIF


      USE &MMASTDBF.COMLED EXCLUSIVE
      INDEX ON COM_TYPE + COM_CODE + SUBSTR(DTOC(TRAN_DATE),7) + SUBSTR(DTOC(TRAN_DATE),1,2) + SUBSTR(DTOC(TRAN_DATE),4,2) TO TMPIDX
      UNLOCK
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.COMLED INDEX TMPIDX", .F.
      STORE DTOC(MBEG_DATE) TO M1_DATE
      STORE DTOC(MEND_DATE) TO M2_DATE
      STORE SUBSTR(M1_DATE,1,2) TO MBEG_MO   
      STORE SUBSTR(M1_DATE,7) TO MBEG_YEAR
      STORE SUBSTR(M2_DATE,1,2) TO MEND_MO   
      STORE SUBSTR(M2_DATE,7) TO MEND_YEAR         
      MPAGE_LEN = 56
      
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
      
      MLINE = 99
      MPAGE_NO= 0
      MBB_TOT = 0
      
      SELECT F
      DO FOX_USE WITH "1099INFO", .T.
      DELETE ALL
      PACK
      
      SELECT E
      DO FOX_USE WITH "DISBJRN INDEX DISBJRN", .F.
      SELECT D
      DO FOX_USE WITH "CK_REG INDEX CK_REG", .F.
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE, &MDBFLOC.COM_NAME", .F.
      SELECT B
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE, &MMASTDBF.SAL_NAME", .F.
      
      STORE SPACE(2) TO MOPT_CODE
      
      IF MOPT_NAME <> SPACE(32)
         DO CASE
         CASE MSAL_TYPE = 'X'
            SELECT B
            SET ORDER TO 2
            SEEK TRIM(MOPT_NAME)
            IF EOF()
               SET DEVICE TO SCREEN
               SET PRINT OFF
               SET PRINT TO
               SET CONSOLE ON
               
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT
               @ 24,0 SAY 'SALESPERSON NOT ON FILE - CANNOT CONTINUE - PRESS ENTER TO RETURN' GET MWAIT
               READ
               CLOSE DATA
               LOOP
            ELSE
               STORE SALE_CODE TO MOPT_CODE
            ENDIF
            SET ORDER TO 1
            
         OTHERWISE
            SELECT C
            SET ORDER TO 2
            SEEK TRIM(MOPT_NAME)
            IF EOF()
               SET DEVICE TO SCREEN
               SET PRINT OFF
               SET PRINT TO
               SET CONSOLE ON
               
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT
               @ 24,0 SAY 'THD PARTY NOT ON FILE - CANNOT CONTINUE - PRESS ENTER TO RETURN' GET MWAIT
               READ
               CLOSE DATA
               LOOP
            ELSE
               STORE COM_CODE TO MOPT_CODE
            ENDIF
            SET ORDER TO 1
         ENDCASE
      ENDIF
      
      
      SELECT B
      GOTO TOP
      
      IF MTHD_TYPE = ' '
         DO WHILE .NOT. EOF()
            IF RPT_PRT = ' ' 
               SKIP
               LOOP
            ENDIF
            
            IF MSAL_TYPE = 'X'
               IF MOPT_CODE <> '  '
                  IF SALE_CODE <> MOPT_CODE
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
            ENDIF
            
            STORE SALE_CODE TO MSALE_CODE
            STORE NAME TO MNAME
            STORE STREET TO MSTREET
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            STORE ZIP TO MZIP
            STORE SALE_SSN TO MCOM_SSN
            STORE FED_TAXID TO MFED_TAXID
            MLINE = 99
            SELECT A
            SEEK 'S' + MSALE_CODE
            IF EOF()
               SELECT B
               SKIP
               LOOP
            ENDIF
            STORE 0 TO MTOTAL, M44TOTAL, M33TOTAL, M98TOTAL, M99TOTAL
            DO WHILE .NOT. EOF() .AND. COM_TYPE = 'S' .AND. COM_CODE = MSALE_CODE ;
               .AND. TRAN_DATE <= MEND_DATE           
               IF CK_NBR = SPACE(6) .OR. TRAN_DATE < MBEG_DATE
                  SKIP
                  LOOP
               ENDIF
               MCK_NBR = CK_NBR
               IF ADV_REP <> ' '
                  SKIP
                  LOOP
               ENDIF
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,30 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  @ 3,06 say mpage_no picture '99'
                  @ 3,15 SAY 'COMMISSION DISBURSEMENT REPORT FOR ' + M1_DATE + ' THRU ' + M2_DATE
                  @ 3,85 SAY DTOC(DATE())
                  @ 4,30 SAY 'ACCOUNT: ' + MNAME
                  @ 5,30 SAY 'ADDRESS: ' + MSTREET
                  @ 6,39 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
                  @ 7,28 SAY 'SOC SEC #: ' 
                  @ 7,39 SAY MCOM_SSN PICTURE '@R ###-##-####'
                  @ 9,5 SAY 'CK NUMBER     CK DATE         AMOUNT      PAYEE NAME'
                  MLINE = 11
               ENDIF
               @ MLINE,7 SAY STR(VAL(CK_NBR),6)
               @ MLINE,19 SAY DTOC(TRAN_DATE)
               @ MLINE,31 SAY -1 * AMOUNT PICTURE '999,999.99'
               SELECT D
               SEEK A->CK_NBR
               STORE PAY_NAME TO MPAY_NAME
               @ MLINE,47 SAY MPAY_NAME
               SELECT A
               MLINE = MLINE + 1
               IF MSALE_CODE = '44'
                  M44TOTAL = M44TOTAL + AMOUNT
               ELSE
                  IF MSALE_CODE = '99'
                     IF MPAY_NAME = 'WAYNE'
                        M98TOTAL = M98TOTAL + AMOUNT
                     ELSE
                        M99TOTAL = M99TOTAL + AMOUNT
                     ENDIF
                  ELSE
                     MTOTAL = MTOTAL + AMOUNT
                  ENDIF
               ENDIF
               SKIP
            ENDDO
            IF M33TOTAL <> 0 .OR. M44TOTAL <> 0 .OR. MTOTAL <> 0 .OR. M98TOTAL <> 0 .OR. M99TOTAL <> 0
               SELECT F
               APPEND BLANK
               REPLACE  NAME WITH MNAME
               REPLACE ADDR1 WITH MSTREET
               REPLACE ADDR2 WITH TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
               DO CASE
               CASE MFED_TAXID <> SPACE(9)
                  REPLACE RECPID WITH TRANSFORM(MFED_TAXID, '@R ##-#######')
               OTHERWISE
                  REPLACE RECPID WITH TRANSFORM(MCOM_SSN, '@R ###-##-####')
               ENDCASE           
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,30 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  @ 3,06 say mpage_no picture '99'
                  @ 3,15 SAY 'COMMISSION DISBURSEMENT REPORT FOR ' + M1_DATE + ' THRU ' + M2_DATE
                  @ 3,85 SAY DTOC(DATE())
                  @ 4,30 SAY 'ACCOUNT: ' + MNAME
                  @ 5,30 SAY 'ADDRESS: ' + MSTREET
                  @ 6,39 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
                  @ 7,28 SAY 'SOC SEC #: ' 
                  @ 7,39 SAY MCOM_SSN PICTURE '@R ###-##-####'
                  @ 9,5 SAY 'CK NUMBER     CK DATE         AMOUNT      PAYEE NAME'
                  MLINE = 11
               ENDIF
               
               MLINE = MLINE + 2
               IF M33TOTAL <> 0 .OR. M44TOTAL <> 0
                  @ MLINE,5 SAY 'TOTAL AMOUNT PAID: '    
                  @ MLINE,29 SAY M44TOTAL * -1 PICTURE '9,999,999.99'
                  REPLACE AMOUNT WITH M44TOTAL * -1
               ELSE
                  IF M98TOTAL <> 0 .OR. M99TOTAL <> 0
                     @ MLINE,5 SAY " TOTAL PAID TO WAYNE WESTON:   "
                     @ MLINE,42 SAY M98TOTAL * -1 PICTURE '9,999,999.99'
                     REPLACE AMOUNT WITH (M98TOTAL+M99TOTAL) * -1
                     MLINE = MLINE + 2
                     @ MLINE,5 SAY 'TOTAL PAID TO CHARLES YOUNG:'
                     @ MLINE,42 SAY M99TOTAL * -1 PICTURE '9,999,999.99'
                  ELSE
                     @ MLINE,5 SAY 'TOTAL AMOUNT PAID: '    
                     @ MLINE,29 SAY MTOTAL * -1 PICTURE '9,999,999.99'
                     REPLACE AMOUNT WITH MTOTAL * -1
                  ENDIF
               ENDIF
            ENDIF
            SELECT B
            SKIP
         ENDDO
      ENDIF
      
      STORE SPACE(28) TO MGEM_STRT
      STORE SPACE(20) TO MGEM_CITY
      STORE SPACE(2) TO  MGEM_ST
      STORE SPACE(5) TO  MGEM_ZIP
      STORE SPACE(9) TO  MGEM_SSN, MGEM_TAXID
      
      ***** NOW PRINT FOR THIRD PARTY PAYEES
      SELECT C
      IF MSAL_TYPE = ' '
         DO WHILE .NOT. EOF()
            IF MTHD_TYPE = 'X'
               IF MOPT_CODE <> '  '
                  IF COM_CODE <> MOPT_CODE
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
            ENDIF
            
            *** DONT PRINT a 1099 FOR BILL BACK COMMISSION PEOPLE
            IF BILL_BACK = 'Y'
               MBILL_BACK = .T.
               **SKIP
               **LOOP
            ELSE
               MBILL_BACK = .F.
            ENDIF
            
            
            IF NAME = 'GEM'
               STORE STREET TO MGEM_STRT
               STORE CITY TO MGEM_CITY
               STORE STATE TO MGEM_ST
               STORE ZIP TO MGEM_ZIP
               STORE COM_SSN TO MGEM_SSN
               STORE FED_TAXID TO MGEM_TAXID
               SKIP
               LOOP
            ENDIF
            STORE COM_CODE TO MCOM_CODE 
            STORE NAME TO MNAME
            STORE STREET TO MSTREET  
            STORE CITY TO MCITY    
            STORE STATE TO MSTATE 
            STORE ZIP TO MZIP
            STORE COM_SSN TO MCOM_SSN
            STORE FED_TAXID TO MFED_TAXID
            MLINE = 99
            SELECT A
            SEEK 'T' + MCOM_CODE 
            IF EOF()
               SELECT C
               SKIP
               LOOP
            ENDIF
            
            MTOTAL = 0
            
            DO WHILE .NOT. EOF() .AND. COM_TYPE = 'T' .AND. COM_CODE = MCOM_CODE ;
               .AND. TRAN_DATE <= MEND_DATE           
               
               IF CK_NBR = SPACE(6) .OR. TRAN_DATE < MBEG_DATE
                  SKIP
                  LOOP
               ENDIF
               IF COR_FLG = 'I' .OR. COR_FLG = 'C' .OR. COR_FLG = ' '
                  SKIP
                  LOOP
               ENDIF
               
               *** CHECK THIS OUT FOR BILLBACKS
               IF MBILL_BACK
                  MBB_TOT = MBB_TOT + AMOUNT
                  SKIP
                  LOOP
               ENDIF
               
               *** TAKE THIS OUT WHEN DONE FOR 2008
               *IF COM_CODE = '93' .OR. COM_CODE = ' 4'
               *ELSE
               *   IF PO_SUFFIX = 'R'
               *      SKIP
               *      LOOP
               *   ENDIF
               *ENDIF
               
               *IF PO_SUFFIX = 'R'
               *   SKIP
               *   LOOP
               *ENDIF
               
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,30 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  @ 3,06 say mpage_no picture '99'
                  @ 3,15 SAY 'COMMISSION DISBURSEMENT REPORT FOR ' + M1_DATE + ' THRU ' + M2_DATE
                  @ 3,85 SAY DTOC(DATE())
                  @ 4,30 SAY 'ACCOUNT: ' + MNAME
                  @ 5,30 SAY 'ADDRESS: ' + MSTREET
                  @ 6,39 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
                  @ 7,28 SAY 'SOC SEC #: ' 
                  @ 7,39 SAY MCOM_SSN PICTURE '@R ###-##-####'
                  @ 8,27 SAY 'FED TAX ID: '   
                  @ 8,39 SAY MFED_TAXID PICTURE '@R ##-#######'
                  @ 10,5 SAY 'CK NUMBER     CK DATE         AMOUNT      PAYEE NAME'
                  MLINE = 12
               ENDIF
               @ MLINE,7 SAY STR(VAL(CK_NBR),6)
               @ MLINE,19 SAY DTOC(TRAN_DATE)
               @ MLINE,31 SAY -1 * AMOUNT PICTURE '999,999.99'
               SELECT D
               SEEK A->CK_NBR
               IF .NOT. EOF()
                  @ MLINE,47 SAY PAY_NAME
               ENDIF
               SELECT A
               MLINE = MLINE + 1
               MTOTAL = MTOTAL + AMOUNT
               SKIP
            ENDDO
            
            IF MTOTAL <> 0
               SELECT F
               APPEND BLANK
               REPLACE  NAME WITH MNAME
               REPLACE ADDR1 WITH MSTREET
               REPLACE ADDR2 WITH TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
               DO CASE
               CASE MFED_TAXID <> SPACE(9)
                  REPLACE RECPID WITH TRANSFORM(MFED_TAXID, '@R ##-#######')
               OTHERWISE
                  REPLACE RECPID WITH TRANSFORM(MCOM_SSN, '@R ###-##-####')
               ENDCASE           
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,30 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  @ 3,06 say mpage_no picture '99'
                  @ 3,15 SAY 'COMMISSION DISBURSEMENT REPORT FOR ' + M1_DATE + ' THRU ' + M2_DATE
                  @ 3,85 SAY DTOC(DATE())
                  @ 4,30 SAY 'ACCOUNT: ' + MNAME
                  @ 5,30 SAY 'ADDRESS: ' + MSTREET
                  @ 6,39 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
                  @ 7,28 SAY 'SOC SEC #: ' 
                  @ 7,39 SAY MCOM_SSN PICTURE '@R ###-##-####'
                  @ 8,27 SAY 'FED TAX ID: '   
                  @ 8,39 SAY MFED_TAXID PICTURE '@R ##-#######'
                  @ 10,5 SAY 'CK NUMBER     CK DATE         AMOUNT      PAYEE NAME'
                  MLINE = 12
               ENDIF
               
               MLINE = MLINE + 2
               @ MLINE,5 SAY 'TOTAL AMOUNT PAID: '    
               @ MLINE,29 SAY MTOTAL * -1 PICTURE '9,999,999.99'
               REPLACE AMOUNT WITH MTOTAL * -1
            ENDIF
            SELECT C
            SKIP
         ENDDO
      ENDIF
      
      MLINE = 89
      MTOTAL = 0
      
      SELECT E
      DO FOX_USE WITH "DISBJRN INDEX DISBINV", .F.
      SEEK 'O'     
      DO WHILE .NOT. EOF() .AND. ACCT_TYPE = 'O'
         IF CATEGORY1 <> '7151' .OR. VOID_MAN = 'V'
            SKIP
            LOOP
         ENDIF
         STORE JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR TO MDATE
         STORE CTOD(MDATE) TO MDATE
         IF MDATE < MBEG_DATE .OR. MDATE > MEND_DATE
            SKIP
            LOOP
         ENDIF 
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,15 SAY 'COMMISSION DISBURSEMENT REPORT FOR ' + M1_DATE + ' THRU ' + M2_DATE
            @ 3,85 SAY DTOC(DATE())
            @ 4,30 SAY 'ACCOUNT: ' + 'GEM ENTERPRISES'
            @ 5,30 SAY 'ADDRESS: ' + MGEM_STRT
            @ 6,39 SAY TRIM(MGEM_CITY) + ', ' + MGEM_ST + '  ' + MZIP
            @ 7,28 SAY 'SOC SEC #: ' 
            @ 7,39 SAY MGEM_SSN PICTURE '@R ###-##-####'
            @ 8,27 SAY 'FED TAX ID: '   
            @ 8,39 SAY MGEM_TAXID PICTURE '@R ##-#######'
            @ 10,5 SAY 'CK NUMBER     CK DATE         AMOUNT      PAYEE NAME'
            MLINE = 12
         ENDIF
         @ MLINE,7 SAY STR(VAL(CK_NBR),6)
         @ MLINE,19 SAY DTOC(MDATE)
         @ MLINE,31 SAY AMOUNT1 PICTURE '999,999.99'
         @ MLINE,47 SAY ACCT_NAME
         MLINE = MLINE + 1
         MTOTAL = MTOTAL + AMOUNT1
         SKIP
      ENDDO
      IF MTOTAL <> 0
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,15 SAY 'COMMISSION DISBURSEMENT REPORT FOR ' + M1_DATE + ' THRU ' + M2_DATE
            @ 3,85 SAY DTOC(DATE())
            @ 4,30 SAY 'ACCOUNT: ' + 'GEM ENTERPRISES'
            @ 5,30 SAY 'ADDRESS: ' + MSTREET
            @ 6,39 SAY TRIM(MGEM_CITY) + ', ' + MGEM_ST + '  ' + MGEM_ZIP
            @ 7,28 SAY 'SOC SEC #: ' 
            @ 7,39 SAY MGEM_SSN PICTURE '@R ###-##-####'
            @ 8,27 SAY 'FED TAX ID: '   
            @ 8,39 SAY MGEM_TAXID PICTURE '@R ##-#######'
            @ 10,5 SAY 'CK NUMBER     CK DATE         AMOUNT      PAYEE NAME'
            MLINE = 12
         ENDIF
         
         MLINE = MLINE + 2
         @ MLINE,5 SAY 'TOTAL AMOUNT PAID: '    
         @ MLINE,29 SAY MTOTAL PICTURE '9,999,999.99'
         @ MLINE+1,1 SAY ' '
      ENDIF
      
      IF MBB_TOT <> 0
         EJECT
         MPAGE_NO = MPAGE_NO + 1
         @ 2,30 SAY MCOMPANY
         @ 3,1 SAY 'Page'
         @ 3,06 say mpage_no picture '99'
         @ 3,15 SAY 'BILLBACK DISBURSEMENT REPORT FOR  ' + M1_DATE + ' THRU ' + M2_DATE
         @ 3,85 SAY DTOC(DATE())
         @ 10,30 SAY 'TOTAL BILLBACK DISBUREMENTS: ' + TRANSFORM(MBB_TOT, '9,999,999.99')
         @ 11,1 SAY ' '
         MLINE = 12
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
      
      RUN DEL TMPIDX.IDX
      CLOSE DATA
      
   CASE VAL(MSEL) = 12
      **** NEED TO FIX IF PRINTING ON LASER FORMS
      
      M1099COMP = 'AMERICHICKEN, INC'
      M1099ADDR1 = '1330 COPPER DRIVE'
      M1099ADDR2 = 'CAPE GIRARDEAU, MO  63701-1730'
      M1099PHONE = '573-651-6485'
      M1099FEDID = '20-2483413'
      MTITLE = ' - PRINT 1099-MISC FORMS'
      
      
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      STORE SPACE(32) TO MOPT_NAME
      STORE SPACE(1) TO MSAL_TYPE, MTHD_TYPE
      STORE CTOD(' ') TO MBEG_DATE, MEND_DATE
      ** HERE
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 13,5 SAY 'Note:  If optional name is left blank -'
         @ 14,5 SAY "       ALL 1099'S will be printed."
         @ 16,5 SAY 'Optional Payee Name:' GET MOPT_NAME PICTURE '@!'
         @ 17,5 SAY "If Payee Name entered - Select Payee Type with an 'X'"
         @ 18,5 SAY 'Company Salesperson:     or    Third Party:'
         @ 18,26 GET MSAL_TYPE PICTURE '@!'
         @ 18,49 GET MTHD_TYPE PICTURE '@!'
         
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2. Edit    3. Cancel'    
         READ   
         @ 24,9 GET MACTION PICTURE '9' RANGE 1,3
         READ
      ENDDO
      IF MACTION = 3
         LOOP  
      ENDIF
      MACTION = ' '
      DO PRT_SET
      
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
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
      MLINE = 99
      MPAGE_NO= 0
      MBB_TOT = 0
      MMARGIN = SPACE(4)
      SELECT F
      DO FOX_USE WITH "1099INFO", .F.
      I = 0
      DO WHILE .NOT. EOF()
         I = I + 1
         ?
         ? MMARGIN + M1099COMP
         ?
         ? MMARGIN + M1099ADDR1
         ? MMARGIN + M1099ADDR2
         ? MMARGIN + M1099PHONE
         ?
         ?
         ?
         ?
         
         ? MMARGIN + M1099FEDID + SPACE(08) + RECPID
         ?
         ? MMARGIN  
         ? MMARGIN + NAME
         ? MMARGIN + SPACE(35) + TRANSFORM(AMOUNT, '999,999.99')
         ?
         ?
         ? MMARGIN + ADDR1
         ?
         ? MMARGIN + ADDR2
         ?
         IF I = 2
            EJECT
            I = 0
         ELSE
            MI = 1
            DO WHILE MI<= 12
               ?
               MI = MI + 1
            ENDDO
         ENDIF
         SKIP
      ENDDO
      
      IF I <> 0      
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      
   ENDCASE
   
   CLOSE DATA
   IF MSEL <> '99'
      MSEL = '  '
   ENDIF
ENDDO
CLOSE DATA
RETURN

* EOF: COM_MENU.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/8/15 at 1:37 PM.
