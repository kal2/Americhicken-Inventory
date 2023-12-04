********************
* Program.: PAYRPTS.PRG
* Author..: GRACE KELLER
* Date....: 01/08/88
* Notice..: Copyright (C) 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PAYMENT REPORT MENU    
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
STORE ' ' TO MSELECTION
STORE ' ' TO MACTION
SET PROCEDURE TO PAYRPTS
DO WHILE VAL(MSELECTION) <> 9  
   CLOSE DATA
   CLEAR
   @ 01,00 SAY MCOMPANY
   @ 02,00 SAY MPROGRAM + ' - PAYMENT REPORTS MENU'
   @ 02,70 SAY DATE()
   @ 3,0 to 25,79
   
   @ 04,10 SAY '1 - RECEIPTS REGISTER/TOTALS'
   @ 06,10 say '2 - DATE-TO-DATE RECEIPT TOTALS BY ACCOUNT'
   @ 08,10 SAY '3 - DATE-TO-DATE RECEIPT TOTALS BY ACCOUNT/SALESPERSON'
   @ 10,10 SAY '4 - AGED ACCOUNTS RECEIVABLE REPORT'            
   @ 12,10 say '5 - DATE-TO-DATE RECEIPT TOTALS FOR SELECTED MISC. ACCOUNT'
   @ 14,10 SAY '6 - PRINT ACTIVE CUSTOMER CREDIT LIMIT REPORT (OPTIONAL SALESPERSON)'
   @ 16,10 SAY '7 - CREDIT CHECK - PRINT ALL CUSTOMERS'
   @ 18,10 SAY '8 - CUSTOMER RECEIVABLE CREDIT REPORT' 
   @ 20,10 SAY 'C - SALESPERSON CUSTOMER CREDIT ADVISEMENT WARNING REPORT'
   @ 22,10 SAY 'S - CUSTOMER STATEMENT'
   @ 23,10 SAY '                               9 - RETURN TO REPORTS MENU'
   
   STORE ' ' TO MSELECTION
   @ 23,02 SAY 'CHOICE: '
   @ 23,10 GET MSELECTION picture '@!'
   READ
   
   DO CASE
      
      
   CASE VAL(MSELECTION) = 1     
      DO REC_REG
      
   CASE VAL(MSELECTION) =  2    
      
      MTITLE = ' - DATE-TO-DATE RECEIPTS TOTALS BY ACCOUNT'
      
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE CTOD(' ') TO MDATE, MEND_DATE
      STORE 'P' TO MDISP_PRT
      MRECALC = 'Y'
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 08,5 SAY 'BEGIN REPORT DATE: '
         @ 08,24 GET MDATE
         @ 10,5 SAY '  END REPORT DATE: ' 
         @ 10,24 GET MEND_DATE
         @ 12,3 SAY 'DISPLAY/PRINT (D/P): '
         @ 12,24 GET MDISP_PRT PICTURE '@!'
         @ 14,5 SAY 'RE-CALCULATE TOTALS (Y/N): '
         @ 14,32 GET MRECALC PICTURE '@!'
         
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF DTOC(MDATE) = '  /  /  '
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'NO DATE ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
               READ
               MACTION = 2
               @ 24,0 CLEAR
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
         MPAGE_LEN = 22
      ENDIF
      
      STORE MONTH(MDATE) TO MMONTH
      MMONTH = MMONTH + 100
      STORE SUBSTR(STR(MMONTH,3),2) TO MMONTH
      
      STORE YEAR(MDATE) TO MYEAR
      STORE STR(MYEAR,4) TO MYEAR
      
      STORE DAY(MDATE) TO MDAY
      MDAY = MDAY + 100
      STORE SUBSTR(STR(MDAY,3),2) TO MDAY
      SELECT E
      DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
      
      SELECT A
      DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE", .F.
      SEEK MYEAR + MMONTH + MDAY  
      IF EOF()
         SEEK MYEAR+MMONTH
         IF EOF()
            @ 4,1 CLEAR TO 21,78 
            @ 10,5 SAY 'THERE IS NO PAYMENT DATA ON FILE FOR THIS MONTH/YEAR'
            STORE ' ' TO MWAIT
            @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
            READ
            LOOP  
         ELSE 
            DO WHILE .NOT. EOF() .AND. PAID_DATE < MDATE
               SKIP
            ENDDO
         ENDIF
      ENDIF
      IF MRECALC = 'Y'
         SELECT B
         USE TMP_ACCT EXCLUSIVE
         DELETE ALL
         PACK
         INDEX ON CATEGORY TO TMP_ACCT
         USE
         DO FOX_USE WITH "TMP_ACCT INDEX TMP_ACCT", .F.
         DO FILELOCK
         SELECT A
         
         DO WHILE .NOT. EOF() .AND. PAID_DATE <= MEND_DATE
            IF ACCOUNT = SPACE(4)
               STORE '6100' TO MCATEGORY
            ELSE
               STORE ACCOUNT TO MCATEGORY
            ENDIF
            
            SELECT B
            SEEK MCATEGORY
            IF EOF()
               APPEND BLANK
               REPLACE CATEGORY WITH MCATEGORY
            ENDIF
            IF MCATEGORY = '6100' .OR. MCATEGORY = '171' .OR. MCATEGORY = '161'
               ** SPLIT OUT THE CREDIT BALANCE INTO A DIFFERENT CATEGORY
               **REPLACE AMOUNT WITH AMOUNT + A->AMT_PAID + A->CRED_AMT   
               REPLACE AMOUNT WITH AMOUNT + A->AMT_PAID                 
            ELSE
               REPLACE AMOUNT WITH AMOUNT + A->AMT_OVER
            ENDIF
            IF MCATEGORY = '6100'
               IF A->AMT_OVER <> 0
                  STORE '6102' TO MCATEGORY
                  SEEK MCATEGORY
                  IF EOF()
                     APPEND BLANK
                     REPLACE CATEGORY WITH MCATEGORY
                  ENDIF
                  REPLACE AMOUNT WITH AMOUNT + A->AMT_OVER
               ENDIF
               IF A->CRED_AMT <> 0
                  STORE '6101' TO MCATEGORY
                  SEEK MCATEGORY
                  IF EOF()
                     APPEND BLANK
                     REPLACE CATEGORY WITH MCATEGORY
                  ENDIF
                  REPLACE AMOUNT WITH AMOUNT + A->CRED_AMT
               ENDIF
            ENDIF
            SELECT A
            SKIP
         ENDDO
         
         SELECT B
         FLUSH
         UNLOCK
      ENDIF
      MGRAND_TOT = 0
      SELECT B
      DO FOX_USE WITH "TMP_ACCT INDEX TMP_ACCT", .F.
      MPAGE_NO = 0
      MLINE = 99 
      
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
      GOTO TOP
      DO WHILE .NOT. EOF() 
         STORE CATEGORY TO MCATEGORY 
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               IF MDISP_PRT = 'P'
                  EJECT
               ENDIF
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,19 SAY MCOMPANY
            @ 2,1 SAY 'PAGE'
            @ 2,06 say mpage_no picture '99'
            @ 2,15 SAY '   RECEIPT TOTALS BY ACCOUNT'
            @ 2,51  SAY DTOC(DATE())
            @ 3,19 SAY DTOC(MDATE) + ' THRU ' + DTOC(MEND_DATE)
            @ 5,1 SAY 'ACCOUNT                                        TOTAL'
            @ 5,0 SAY REPLICATE ('_',60)
            MLINE = 7
         ENDIF
         IF AMOUNT <> 0
            SELECT E
            SEEK MCATEGORY
            IF .NOT. EOF()
               @ MLINE,1 SAY DESCRIP 
            ELSE
               @ MLINE,1 SAY MCATEGORY + ' - NOT ON FILE'
            ENDIF
            SELECT B
            @ MLINE,40 SAY AMOUNT PICTURE '99,999,999.99'
            MGRAND_TOT = MGRAND_TOT + AMOUNT
         
            MLINE = MLINE + 2
         ENDIF

         SKIP
      ENDDO
      
      @ MLINE,1 SAY 'TOTAL RECEIPTS:'
      @ MLINE,40 SAY MGRAND_TOT PICTURE '99,999,999.99'
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
      CLOSE DATA
      
   CASE VAL(MSELECTION) =  3    
      MTITLE = ' - RECEIPTS TOTALS BY SALESPERSON/ACCOUNT'
      
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE CTOD(' ') TO MDATE, MEND_DATE
      STORE 'P' TO MDISP_PRT
      MOPT_SALES = '**'
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 08,5 SAY 'BEGIN REPORT DATE: '
         @ 08,24 GET MDATE
         @ 10,5 SAY '  END REPORT DATE: ' 
         @ 10,24 GET MEND_DATE
         @ 12,3 SAY 'DISPLAY/PRINT (D/P): '
         @ 12,24 GET MDISP_PRT PICTURE '@!'
         
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF DTOC(MDATE) = '  /  /  '
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'NO DATE ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
               READ
               MACTION = 2
               @ 24,0 CLEAR
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
         MPAGE_LEN = 22
      ENDIF
      
      STORE MONTH(MDATE) TO MMONTH
      MMONTH = MMONTH + 100
      STORE SUBSTR(STR(MMONTH,3),2) TO MMONTH
      
      STORE YEAR(MDATE) TO MYEAR
      STORE STR(MYEAR,4) TO MYEAR
      
      STORE DAY(MDATE) TO MDAY
      MDAY = MDAY + 100
      STORE SUBSTR(STR(MDAY,3),2) TO MDAY
      SELECT E
      DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
      SELECT C
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT A
      DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE", .F.
      SEEK MYEAR + MMONTH + MDAY  
      IF EOF()
         SEEK MYEAR+MMONTH
         IF EOF()
            @ 4,1 CLEAR TO 21,78 
            @ 10,5 SAY 'THERE IS NO PAYMENT DATA ON FILE FOR THIS MONTH/YEAR'
            STORE ' ' TO MWAIT
            @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
            READ
            LOOP  
         ELSE 
            DO WHILE .NOT. EOF() .AND. PAID_DATE < MDATE
               SKIP
            ENDDO
         ENDIF
      ENDIF
      SELECT B
      USE TMP_ACCT EXCLUSIVE
      DELETE ALL
      PACK
      INDEX ON SALESMAN + CATEGORY TO TMP_ACCT
      USE
      *DO FOX_USE WITH "TMP_ACCT INDEX TMP_ACCT", .F.
      USE TMP_ACCT INDEX TMP_ACCT EXCLUSIVE
      MDOMESTIC = 0
      
      SELECT A
      
      DO WHILE .NOT. EOF() .AND. PAID_DATE <= MEND_DATE
         IF ACCOUNT = SPACE(4)
            STORE '6100' TO MCATEGORY
         ELSE
            STORE ACCOUNT TO MCATEGORY
         ENDIF
         IF MPROG_CODE = 1  
            MSALESMAN = A->SALESMAN
         ELSE
            SELECT C
            SEEK A->SALESMAN
            IF EOF() .OR. OFFICE_CD = '  '
               MSALESMAN = '01'
            ELSE
               MSALESMAN = OFFICE_CD
            ENDIF
         ENDIF
         
         SELECT B
         SEEK MSALESMAN + MCATEGORY
         IF EOF()
            APPEND BLANK
            REPLACE CATEGORY WITH MCATEGORY
            REPLACE SALESMAN WITH MSALESMAN
         ENDIF
         IF MCATEGORY = '6100' .OR. MCATEGORY = '171' .OR. MCATEGORY = '161'
            REPLACE AMOUNT WITH AMOUNT + A->AMT_PAID + A->CRED_AMT   
         ELSE
            REPLACE AMOUNT WITH AMOUNT + A->AMT_OVER
         ENDIF
         IF MCATEGORY = '6100'
            IF A->AMT_OVER <> 0
               STORE '6102' TO MCATEGORY
               SEEK MSALESMAN + MCATEGORY
               IF EOF()
                  APPEND BLANK
                  REPLACE CATEGORY WITH MCATEGORY
                  REPLACE SALESMAN WITH MSALESMAN
               ENDIF
               REPLACE AMOUNT WITH AMOUNT + A->AMT_OVER
            ENDIF
         ENDIF
         
         IF MPROG_CODE = 2
            **** IF DOMESTIC LOAD, MIDWEST IS PAYING SALES COMMISSION
            IF A->BBUYCODE = '   9'
               MDOMESTIC = MDOMESTIC + A->AMT_PAID + A->CRED_AMT + A->AMT_OVER
            ENDIF
         ENDIF
         SELECT A
         SKIP
      ENDDO
      
      SELECT B
      FLUSH
      UNLOCK
      SELECT C
      USE
      MGRAND_TOT = 0
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      SELECT B
      DO FOX_USE WITH "TMP_ACCT INDEX TMP_ACCT", .F.
      MPAGE_NO = 0
      MLINE = 99 
      
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
      GOTO TOP
      DO WHILE .NOT. EOF() 
         STORE SALESMAN TO MSALESMAN
         IF MPROG_CODE = 1
            SELECT A
            SEEK MSALESMAN
            IF EOF() .OR. MSALESMAN = SPACE(2)
               MSALE_NAME = 'SALESPERSON NOT IDENTIFIED ' + MSALESMAN
            ELSE
               MSALE_NAME = NAME
            ENDIF
            SELECT B
         ELSE
            DO CASE
            CASE MSALESMAN = '01'
               MSALE_NAME = 'CAPE GIRARDEAU OFFICE'
            CASE MSALESMAN = '02'
               MSALE_NAME = 'SOUTH CAROLINA OFFICE'
            OTHERWISE 
               MSALE_NAME = 'OFFICE UNKNOWN'
            ENDCASE
         ENDIF
         MSALE_TOT = 0
         MPRT_NAME = .T.
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
            IF AMOUNT = 0
               SKIP
               LOOP
            ENDIF
            STORE CATEGORY TO MCATEGORY 
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  IF MDISP_PRT = 'P'
                     EJECT
                  ENDIF
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 1,19 SAY MCOMPANY
               @ 1,1 SAY 'PAGE'
               @ 1,06 say mpage_no picture '99'
               @ 1,55  SAY DTOC(DATE())
               IF MPROG_CODE = 1
                  @ 2,13 SAY 'RECEIPT TOTALS BY SALESPERSON/ACCOUNT'
               ELSE
                  @ 2,13 SAY 'RECEIPT TOTALS BY OFFICE/ACCOUNT'    
               ENDIF
               @ 3,19 SAY DTOC(MDATE) + ' THRU ' + DTOC(MEND_DATE)
               IF MPROG_CODE = 1
                  @ 5,1 SAY 'SALESPERSON/ACCOUNT                            TOTAL'
               ELSE
                  @ 5,1 SAY 'OFFICE/ACCOUNT                                 TOTAL'
               ENDIF
               @ 5,0 SAY REPLICATE ('_',60)
               MLINE = 7
               MPRT_NAME = .T.
            ENDIF
            IF MPRT_NAME
               @ MLINE,1 SAY MSALE_NAME
               MLINE = MLINE + 1
               MPRT_NAME = .F.
            ENDIF
            
            SELECT E
            SEEK MCATEGORY
            IF .NOT. EOF()
               @ MLINE,3 SAY DESCRIP 
            ELSE
               @ MLINE,3 SAY MCATEGORY + ' - NOT ON FILE'
            ENDIF
            SELECT B
            @ MLINE,40 SAY AMOUNT PICTURE '99,999,999.99'
            MLINE = MLINE + 1
            MSALE_TOT = MSALE_TOT + AMOUNT
            SKIP
         ENDDO
         @ MLINE-1,1 SAY REPLICATE('_',32)
         @ MLINE-1,40 SAY REPLICATE('_',13)
         @ MLINE,1 SAY MSALESMAN + ' TOTALS:'
         @ MLINE,40 SAY MSALE_TOT PICTURE '99,999,999.99'
         MLINE = MLINE + 3
         MGRAND_TOT = MGRAND_TOT + MSALE_TOT
      ENDDO
      @ MLINE,1 SAY 'TOTAL RECEIPTS:'
      @ MLINE,40 SAY MGRAND_TOT PICTURE '99,999,999.99'
      IF MDOMESTIC <> 0
         MLINE = MLINE + 5
         @ MLINE,1 SAY 'RECEIPTS FROM MIDWEST FOOD & POULTRY: ' 
         @ MLINE,40 SAY MDOMESTIC PICTURE '99,999,999.99'
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
      CLOSE DATA
      
      
   CASE VAL(MSELECTION) =  4    
      * Notes...: INVOICE PAYMENT INFORMATION
      **** DO ALL THE PRINT ROUTINE STUFF
      MTITLE = ' - AGING REPORT'                    
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      MDO_AGAIN = .T.
      DO WHILE MDO_AGAIN
         CLOSE DATA
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         CLEAR
         @  1, 1  SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         MRPT_TYPE = '       '
         STORE 2 TO MACTION      
         DO WHILE MACTION = 2      
            @ 10,5 SAY 'Do you want the Regular Aging Report (REGULAR)'
            @ 12,5 SAY 'or the Summary Reports (SUMMARY) ' 
            @ 14,5 SAY 'or the Short Regular Aging Report (SHORT): 'GET MRPT_TYPE PICTURE '@!'
            STORE 1 TO MACTION
            @ 23,00 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
         ENDDO
         IF MACTION = 3 .OR. (MRPT_TYPE <> 'REGULAR' .AND. MRPT_TYPE <> 'SUMMARY' .AND. MRPT_TYPE <> 'SHORT')
            MDO_AGAIN = .F.
            LOOP   
         ENDIF  
         @ 4,1 CLEAR TO 21,78
         IF MRPT_TYPE = 'SHORT'
            MDO_AGAIN = .F. 
            DO SHRT_AGE
            LOOP
         ENDIF
         MSEL_BBUY = SPACE(4)
         MYES_NO = '   '
         MACTION = 2
         DO WHILE MACTION = 2
            @ 10,5 SAY 'Do you want to select a specific customer (YES/NO) ' GET MYES_NO PICTURE '@!'
            STORE 1 TO MACTION
            @ 23,00 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
            READ
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
         ENDDO
         IF MACTION = 3     
            MDO_AGAIN = .F.
            LOOP   
         ENDIF  
         @ 10,1 SAY SPACE(77)
         IF MYES_NO = 'YES'
            **** SELECT A CUSTOMER HERE 
            SAVE SCREEN TO MGRACE
            MNAME_FD = .F.
            DO BBUYSEL3
            IF .NOT. MNAME_FD 
               MDO_AGAIN = .F.
               LOOP
            ENDIF
            MSEL_BBUY = BBUYCODE
            CLOSE DATA
            RESTORE SCREEN FROM MGRACE
            @ 10,1 SAY SPACE(78)
            SET PROC TO PAYRPTS 
         ENDIF
         IF MPROG_CODE = 1
            STORE '     ' TO MAGE_PICK
         ELSE
            STORE 'ALL  ' TO MAGE_PICK
         ENDIF
         IF MRPT_TYPE = 'SUMMARY'
            MSEL_DAYS = 20
         ELSE
            IF MPROG_CODE = 1
               MSEL_DAYS = 7   
            ELSE
               MSEL_DAYS = 35  
            ENDIF
         ENDIF
         STORE 2 TO MACTION      
         DO WHILE MACTION = 2      
            @ 10,5 SAY 'Do you want report(s) for ALL accounts (ALL)'
            @ 12,5 SAY 'or by salesperson (SALES)? ' get mage_pick picture '@!'
            *IF MRPT_TYPE = 'SUMMARY'
            @ 15,5 SAY "Select PO's      days and older"
            @ 15,18 GET MSEL_DAYS PICTURE '##'       
            *ENDIF
            STORE 1 TO MACTION
            @ 23,00 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
            IF MACTION = 1
               IF MAGE_PICK <> 'ALL  ' .AND. MAGE_PICK <> 'SALES' .AND. MAGE_PICK <> '     '
                  @ 24,0 CLEAR
                  mwait = ' '
                  @ 24,1 SAY 'INVALID CHOICE - PRESS ANY KEY TO REENTER' GET MWAIT
                  READ
                  MACTION = 2
                  @ 24,0 CLEAR
                  LOOP 
               ENDIF
               
               IF MSEL_DAYS <= 7 .AND. MRPT_TYPE = 'SUMMARY'
                  @ 24,0 CLEAR
                  mwait = ' '
                  @ 24,1 SAY 'DAYS OLD SELECTION MUST BE GREATER THAN 7- PRESS ANY KEY TO REENTER' GET MWAIT
                  READ
                  MACTION = 2
                  @ 24,0 CLEAR
                  LOOP 
               ENDIF
            ENDIF
         ENDDO
         
         IF MACTION = 3 .OR. MAGE_PICK = '     '
            LOOP   
         ENDIF  
         IF MAGE_PICK = 'ALL'
            MCODE = '**'
         ENDIF
         IF MCOMPANY = 'DIVISION 15'
            @ 17,5 SAY 'CALCULATING DIV. 15 CUSTOMER BALANCES.... PLEASE WAIT...'
            SELECT C
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
            DO WHILE .NOT. EOF()
               DO RECLOCK
               REPLACE CUS_BAL15 WITH 0
               UNLOCK
               SKIP
            ENDDO
            
            SELECT A
            DO FOX_USE WITH "CUS_INV INDEX CUS_DATE", .F.
            SEEK ' '
            DO WHILE .NOT. EOF() .AND. PAID_FLG = ' '
               STORE BBUYCODE TO MBBUYCODE
               MBALANCE = 0
               DO WHILE .NOT. EOF() .AND. PAID_FLG = ' ' .AND. BBUYCODE = MBBUYCODE
                  MSTILL_DUE = TOT_SELL + CUS_PALL - AMT_PAID
                  IF MSTILL_DUE > 0 
                     MBALANCE = MBALANCE + MSTILL_DUE
                  ENDIF
                  SKIP
               ENDDO
               
               SELECT C
               SEEK MBBUYCODE
               IF .NOT. EOF()
                  DO RECLOCK
                  REPLACE CUS_BAL15 WITH MBALANCE 
                  UNLOCK
               ENDIF
               SELECT A
            ENDDO
            
            CLOSE DATA
            @ 17,1 SAY space(77)
         ENDIF
         
         DO CASE  
         CASE MRPT_TYPE = 'REGULAR'
            **** GET DATE FOR THIS REPORT
            STORE DATE() TO MRPT_DATE
            STORE '**' TO MCODE
            STORE 1  TO MTIMES
            STORE 'D' TO MDISP_PRT
            STORE 'NO ' TO MOLD_PICK
            @ 4,1 CLEAR TO 21,78
            STORE 2 TO MACTION      
            DO WHILE MACTION = 2      
               @ 08,5 SAY 'PRINT OLD/INACTIVE CUSTOMERS (YES/NO) ? ' GET MOLD_PICK PICTURE '@!'
               @ 10,5 SAY 'ENTER REPORT DATE: '
               @ 10,24 GET MRPT_DATE
               IF MAGE_PICK <> 'ALL  '
                  @ 13,5 SAY ' SALESPERSON CODE: '
                  @ 13,24 GET MCODE               
                  @ 14,5 SAY " (ENTER '**' IF REPORT DESIRED FOR ALL SALESPERSONS)"
                  @ 16,5 SAY 'NUMBER OF REPORTS: '
                  @ 16,24 GET MTIMES PICTURE '#' RANGE 0,3
               ENDIF
               STORE 1 TO MACTION
               @ 23,00 CLEAR
               @ 24,01 SAY 'Action: ' + STR(MACTION,1)
               @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
               
               READ
               
               @24,09 GET MACTION PICTURE '9' RANGE 1,3
               READ               
               IF MACTION = 1
                  IF DTOC(MRPT_DATE) = '  /  /  '
                     @ 24,0 CLEAR
                     mwait = ' '
                     @ 24,1 SAY 'NO DATE ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
                     READ
                     MACTION = 2
                     @ 24,0 CLEAR
                     LOOP 
                  ENDIF
               ENDIF
            ENDDO
            
            IF MACTION = 3
               LOOP  
            ENDIF  
            
            MPRT_ACT = 'C'
            
            DO PRT_SET
            
            IF MPRT_ACT <> 'C'
               LOOP  
            ENDIF
            SELECT E
            DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, TMP_BUY", .F.
            SELECT F
            DO FOX_USE WITH "INV_HEAD INDEX INV_HEAD", .F.
            
            SELECT C
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
            SELECT B
            DO FOX_USE WITH "INV_ADJ INDEX INV_ADJ", .F.
            
            SELECT D
            USE TEMP_AGE EXCLUSIVE         
            DELETE ALL
            PACK
            USE
            
            SELECT D
            DO FOX_USE WITH "TEMP_AGE", .F.
            IF MAGE_PICK = 'ALL  '
               INDEX ON NAME + RSUPCODE TO TEMP_AGE
               DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE", .F.
            ELSE
               INDEX ON SALESMAN + NAME  + RSUPCODE TO TEMP_AGE
               INDEX ON SALESMAN + REGION + RSUPCODE TO TEMPAGE2
               INDEX ON REGION + RSUPCODE TO TEMPAGE3
               DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE, TEMPAGE2, TEMPAGE3", .F.
            ENDIF
            
            SELECT A
            DO FOX_USE WITH "CUS_INV INDEX CUS_DATE", .F.
            
            SEEK ' '            
            IF EOF()
               @ 14,1 SAY 'THERE ARE NO OUTSTANDING INVOICES TO BE AGED'         
               @ 16,1 SAY ' '
               WAIT 'PRESS RETURN TO CONTINUE'
               LOOP  
            ENDIF
            
            MDATE = MRPT_DATE - MSEL_DAYS
            DO WHILE .NOT. EOF() .AND. PAID_FLG = ' '
               IF MSEL_BBUY <> SPACE(4)
                  IF MSEL_BBUY <> BBUYCODE
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               IF BBUYCODE = 'CRED'
                  SKIP
                  LOOP
               ENDIF
               IF SALESMAN = '06' .AND. PO_NBR = '0830' .AND. PO_SUFFIX <> ' '
                  SKIP
                  LOOP
               ENDIF
               STORE BBUYCODE TO MBBUYCODE
               SELECT C
               SEEK MBBUYCODE
               
               IF .NOT. EOF()
                  STORE NAME TO MNAME
               ELSE 
                  STORE 'CUSTOMER NOT ON FILE' TO MNAME
               ENDIF
               
               IF MOLD_PICK = 'NO'
                  SELECT E
                  MPRT_CUST = .T.
                  SET ORDER TO 2
                  SEEK MBBUYCODE
                  IF DATE() - SHIP_DATE > 180
                     MPRT_CUST = .F.
                  ENDIF
                  SET ORDER TO 1
                  IF .NOT. MPRT_CUST
                     SELECT A
                     DO WHILE .NOT. EOF() .AND. PAID_FLG = ' ' .AND. BBUYCODE = MBBUYCODE
                        SKIP
                     ENDDO
                     LOOP
                  ENDIF
               ENDIF
               
               SELECT A
               MOVERDUE = 0             
               MBALANCE = 0
               DO WHILE .NOT. EOF() .AND. PAID_FLG = ' ' .AND. BBUYCODE = MBBUYCODE
                  IF MCODE <> '**'
                     IF SALESMAN <> MCODE
                        SKIP
                        LOOP
                     ENDIF
                  ENDIF
                  IF SALESMAN = '06' .AND. PO_NBR = '0830' .AND. PO_SUFFIX <> ' '
                     SKIP
                     LOOP
                  ENDIF
                  STORE INV_NBR TO MINV_NBR
                  STORE SALESMAN TO MSALESMAN
                  STORE PO_NBR TO MPO_NBR
                  STORE PO_SUFFIX TO MPO_SUFFIX
                  STORE TOT_SELL + CUS_PALL TO MAMT
                  SELECT F
                  SEEK A->INV_NBR
                  IF EOF()
                     STORE 0 TO MTOT_SELL       
                  ELSE
                     STORE TOT_SELL TO MTOT_SELL        
                  ENDIF
                  
                  SELECT E
                  SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
                  IF EOF()
                     STORE SPACE(15) TO MBUYER_PO
                     STORE SHIP_DATE TO MTRAN_DATE
                  ELSE
                     STORE BUYER_PO TO MBUYER_PO
                     IF MCOMPANY = 'AMERICHICKEN, INC'
                        IF DEL_REQD <> CTOD('')
                           STORE DEL_REQD TO MTRAN_DATE
                        ELSE
                           STORE SHIP_DATE TO MTRAN_DATE
                        ENDIF
                     ELSE
                        STORE SHIP_DATE TO MTRAN_DATE
                     ENDIF
                  ENDIF
                  IF A->DEB_CRD = ' '
                     SELECT B
                     SEEK MINV_NBR
                     DO WHILE .NOT. EOF() .AND. INV_NBR = MINV_NBR
                        MAMT = MAMT + ADJ_AMT
                        SKIP
                     ENDDO
                  ENDIF
                  SELECT A
                  MSTILL_DUE = MAMT - AMT_PAID
                  
                  **
                  IF MSTILL_DUE > 0 .OR. (MPROG_CODE = 2 .AND. BBUYCODE = ' 199')
                     MBALANCE = MBALANCE + MSTILL_DUE
                     ***IF DTOC(SHIP_DATE) <> '  /  /  '
                     ***   STORE SHIP_DATE TO MTRAN_DATE    
                     ***ELSE
                     ***   STORE INV_DATE TO MTRAN_DATE   
                     ***ENDIF
                     SELECT D
                     DO FILELOCK
                     APPEND BLANK
                     REPLACE NAME WITH MNAME
                     REPLACE RSUPCODE WITH MBBUYCODE
                     REPLACE SALESMAN WITH MSALESMAN
                     REPLACE TOT_SELL WITH MTOT_SELL
                     REPLACE STILL_DUE WITH MSTILL_DUE            
                     REPLACE TRAN_DATE WITH MTRAN_DATE
                     REPLACE REGION WITH C->REGION
                     
                     IF MTRAN_DATE <= MDATE
                        REPLACE INV_NBR WITH MINV_NBR
                        REPLACE PO_NBR WITH MPO_NBR
                        REPLACE PO_SUFFIX WITH MPO_SUFFIX
                        REPLACE BUYER_PO WITH MBUYER_PO
                        MOVERDUE = MOVERDUE + MSTILL_DUE       
                     ENDIF
                     UNLOCK
                  ENDIF
                  SELECT A
                  SKIP
               ENDDO
               
               SELECT A
            ENDDO
            
            CLOSE DATA
            
            MPAGE_NO = 0
            MLINE = 99 
            MPAGE_LEN = 58
            
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
            ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
            
            *** LETTER SIZE PAPER
            ?? CHR(27) + '&l2A'
            
            *** PORTRAIT MODE
            ?? CHR(27) + '&l0O'
            
            DO CASE
            CASE MAGE_PICK = 'ALL  '
               
               SELECT C
               DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
               
               SELECT D
               DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE", .F.
               STORE 0 TO M0_6DAYS, M7_14DAYS, M15_21DAYS, M22_30DAYS, MOVER_30
               
               DO WHILE .NOT. EOF()
                  
                  IF PO_NBR = SPACE(4)
                     STORE MRPT_DATE - TRAN_DATE TO MDAYS
                     DO CASE
                     CASE MDAYS <= 6
                        M0_6DAYS = M0_6DAYS + STILL_DUE
                     CASE MDAYS > 6 .AND. MDAYS < 15
                        M7_14DAYS = M7_14DAYS + STILL_DUE
                     CASE MDAYS > 14 .AND. MDAYS < 22
                        M15_21DAYS = M15_21DAYS + STILL_DUE
                     CASE MDAYS > 21 .AND. MDAYS < 31
                        M22_30DAYS = M22_30DAYS + STILL_DUE
                     OTHERWISE 
                        MOVER_30 = MOVER_30 + STILL_DUE
                     ENDCASE
                     SKIP
                     LOOP
                  ENDIF
                  
                  STORE RSUPCODE TO MBBUYCODE
                  STORE NAME TO MNAME      
                  SELECT C
                  SEEK MBBUYCODE
                  IF .NOT. EOF()
                     IF MCOMPANY = 'DIVISION 15'
                        STORE CUS_BAL15 TO MBALANCE
                     ELSE
                        STORE CUS_BAL TO MBALANCE
                     ENDIF
                     STORE CRED_LIM TO MCRED_LIM
                     MCRED_LIM1 = SPACE(10)       
                     IF MCRED_LIM = 0
                        DO CASE
                        CASE SUBSTR(NOTE,1,3) = 'L/C' .OR. SUBSTR(NOTE,1,3) = 'CAD' .OR. SUBSTR(NOTE,1,3) = 'COD'
                           STORE SUBSTR(NOTE,1,3) TO MCRED_LIM1
                        CASE SUBSTR(NOTE,1,6) = 'C.O.D.'
                           STORE SUBSTR(NOTE,1,6) TO MCRED_LIM1
                        CASE SUBSTR(NOTE,1,9) = 'NO CREDIT'
                           STORE SUBSTR(NOTE,1,9) TO MCRED_LIM1
                        CASE SUBSTR(NOTE,1,10) = 'LOAD BASIS' .OR. SUBSTR(NOTE,1,10) = 'LOAD-BASIS'
                           STORE SUBSTR(NOTE,1,10) TO MCRED_LIM1
                        CASE SUBSTR(NOTE,1,10) = 'INV TO INV' .OR. SUBSTR(NOTE,1,10) = 'INV-TO-INV'
                           STORE SUBSTR(NOTE,1,10) TO MCRED_LIM1
                        ENDCASE
                     ENDIF
                     STORE '(' + AREA_CODE + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4) TO MPHONE
                     STORE TRIM(CITY) + ', ' + STATE TO MADDR
                     IF SHIPS_25 <> 0 .AND. DAYS_25 <> 0
                        MAVG_25 = DAYS_25/SHIPS_25
                     ELSE
                        MAVG_25 = 0
                     ENDIF
                     
                     IF SHIPS_180 <> 0 .AND. DAYS_180 <> 0
                        MAVG_180 = DAYS_180/SHIPS_180
                     ELSE
                        MAVG_180 = 0
                     ENDIF
                  ELSE
                     STORE 0 TO MBALANCE, MCRED_LIM, MAVG_25, MAVG_180              
                     STORE SPACE(13) TO MPHONE, MADDR
                     STORE SPACE(10) TO MCRED_LIM1
                  ENDIF
                  
                  MOVERDUE = 0
                  MPRT_CUST = .T.
                  SELECT D
                  DO WHILE .NOT. EOF() .AND. RSUPCODE = MBBUYCODE .AND. NAME = MNAME
                     IF PO_NBR = SPACE(4)
                        STORE MRPT_DATE - TRAN_DATE TO MDAYS
                        DO CASE
                        CASE MDAYS <= 6
                           M0_6DAYS = M0_6DAYS + STILL_DUE
                        CASE MDAYS > 6 .AND. MDAYS < 15
                           M7_14DAYS = M7_14DAYS + STILL_DUE
                        CASE MDAYS > 14 .AND. MDAYS < 22
                           M15_21DAYS = M15_21DAYS + STILL_DUE
                        CASE MDAYS > 21 .AND. MDAYS < 31
                           M22_30DAYS = M22_30DAYS + STILL_DUE
                        OTHERWISE 
                           MOVER_30 = MOVER_30 + STILL_DUE
                        ENDCASE
                        SKIP
                        LOOP
                     ENDIF
                     IF MLINE > MPAGE_LEN
                        MPRT_CUST = .T.
                        DO AGE_HEAD
                     ELSE 
                        IF MPRT_CUST
                           @ MLINE,1 SAY MNAME
                           @ MLINE,45 SAY MPHONE
                           MLINE = MLINE + 1
                           @ MLINE,1 SAY MADDR
                           MPRT_CUST = .F.
                           MLINE = MLINE + 2
                           IF MLINE > MPAGE_LEN
                              MPRT_CUST = .T.
                              DO AGE_HEAD
                           ENDIF
                        ENDIF
                     ENDIF
                     IF SALESMAN <> '  '
                        @ MLINE,1 SAY SALESMAN + '-'
                     ENDIF
                     @ MLINE,4 SAY INV_NBR 
                     @ MLINE,10 SAY TOT_SELL PICTURE '9,999,999.99'
                     @ MLINE,23 SAY STILL_DUE PICTURE '9,999,999.99'
                     @ MLINE,40 SAY BUYER_PO
                     IF SALESMAN <> '  '
                        @ MLINE,56 SAY SALESMAN + '-'
                     ENDIF
                     @ MLINE,59 SAY PO_NBR
                     IF PO_SUFFIX <> SPACE(1)
                        @ MLINE,63 SAY '-' + PO_SUFFIX
                     ENDIF
                     @ MLINE,70 SAY TRAN_DATE
                     STORE MRPT_DATE - TRAN_DATE TO MDAYS
                     @ MLINE,82 SAY MDAYS PICTURE '999'
                     STORE MDATE - TRAN_DATE TO MLATE_DAYS
                     @ MLINE,92 SAY MLATE_DAYS PICTURE '999'
                     MOVERDUE = MOVERDUE + STILL_DUE       
                     DO CASE
                     CASE MDAYS <= 6
                        M0_6DAYS = M0_6DAYS + STILL_DUE
                     CASE MDAYS > 6 .AND. MDAYS < 15
                        M7_14DAYS = M7_14DAYS + STILL_DUE
                     CASE MDAYS > 14 .AND. MDAYS < 22
                        M15_21DAYS = M15_21DAYS + STILL_DUE
                     CASE MDAYS > 21 .AND. MDAYS < 31
                        M22_30DAYS = M22_30DAYS + STILL_DUE
                     OTHERWISE 
                        MOVER_30 = MOVER_30 + STILL_DUE
                     ENDCASE
                     MLINE = MLINE + 2
                     SKIP
                  ENDDO
                  IF MOVERDUE > 0
                     **** DO CUSTOMER OVERDUE BALANCE HERE
                     IF MLINE > MPAGE_LEN
                        MPRT_CUST = .T.
                        DO AGE_HEAD
                     ENDIF
                     @ MLINE,5 SAY 'OVERDUE TOTAL: '
                     @ MLINE,22 SAY MOVERDUE PICTURE '9,999,999.99'
                     MLINE = MLINE + 2
                     IF MLINE > MPAGE_LEN
                        MPRT_CUST = .T.
                        DO AGE_HEAD
                     ENDIF
                     @ MLINE,5 SAY '    TOTAL DUE:'      
                     @ MLINE,24 SAY MBALANCE PICTURE '999,999.99'
                     MLINE = MLINE + 2
                     IF MLINE > MPAGE_LEN
                        MPRT_CUST = .T.
                        DO AGE_HEAD
                     ENDIF
                     
                     @ MLINE,5 SAY ' CREDIT LIMIT:'      
                     DO CASE
                     CASE MCRED_LIM <> 0
                        @ MLINE,24 SAY MCRED_LIM PICTURE '999,999.99'
                     CASE MCRED_LIM1 <> SPACE(10)
                        @ MLINE,24 SAY MCRED_LIM1                     
                     OTHERWISE
                        @ MLINE,24 SAY MCRED_LIM PICTURE '999,999.99'
                     ENDCASE
                     
                     MLINE = MLINE + 2
                     IF MAVG_25 <> 0 .OR. MAVG_180 <> 0
                        IF MLINE > MPAGE_LEN
                           MPRT_CUST = .T.
                           DO AGE_HEAD
                        ENDIF
                        IF MPROG_CODE = 1
                           @ MLINE,1 SAY 'PAST 6 MONTHS AVG. PAY:'      
                        ELSE
                           @ MLINE,1 SAY 'PAST 2 YEARS AVG. PAY:'      
                        ENDIF
                        @ MLINE,24 SAY MAVG_180 PICTURE '999,999.99'
                        MLINE = MLINE + 2
                        IF MPROG_CODE = 1
                           @ MLINE,1 SAY ' PAST 25 DAYS AVG. PAY:'      
                        ELSE
                           @ MLINE,1 SAY '  PAST 1 YEAR AVG. PAY:'      
                        ENDIF
                        @ MLINE,24 SAY MAVG_25  PICTURE '999,999.99'
                        MLINE = MLINE + 2
                     ENDIF
                     MLINE = MLINE + 1
                  ENDIF
               ENDDO
               
               MLINE = 88
               MPRT_CUST = .F.
               DO AGE_HEAD
               MLINE = MLINE + 6
               @ MLINE,1 SAY '                    T O T A L   A G E D   A C C O U N T S   R E C E I V A B L E'
               MLINE = MLINE + 2
               @ MLINE,1 SAY '---------------------------------------------------------------------------------------------- '
               @ MLINE+1,1 SAY '[   UNDER 7 DAYS   |   7 - 14 DAYS   |  15 - 21 DAYS   |  22 - 30 DAYS   |    OVER 30 DAYS   ]'
               @ MLINE+2,1 SAY '[                  |                 |                 |                 |                   ]'
               MLINE = MLINE + 3
               @ MLINE,1 SAY '[                  |                 |                 |                 |                   ]'
               @ MLINE,5 SAY M0_6DAYS  PICTURE '9,999,999.99'
               @ MLINE,23 SAY M7_14DAYS PICTURE '9,999,999.99'
               @ MLINE,41 SAY M15_21DAYS PICTURE '9,999,999.99'
               @ MLINE,59 SAY M22_30DAYS PICTURE '9,999,999.99'
               @ MLINE,79 SAY MOVER_30 PICTURE '9,999,999.99'
               @ MLINE+1,1 SAY '[                  |                 |                 |                 |                   ]'
               @ MLINE+2,1 SAY '----------------------------------------------------------------------------------------------'
               @ MLINE+3,1 SAY ' '
               EJECT
               
               
            OTHERWISE                    
               I = 1
               DO WHILE I <= MTIMES
                  STORE 0 TO M0_6TOT, M7_14TOT, M15_21TOT, M22_30TOT, MOV_30TOT
                  MPAGE_NO = 0
                  MLINE = 99 
                  MPAGE_LEN = 58
                  
                  SELECT C
                  DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
                  
                  SELECT D
                  DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE, TEMPAGE2, TEMPAGE3", .F.
                  DO WHILE .NOT. EOF()
                     
                     STORE SALESMAN TO MSALESMAN
                     IF MSALESMAN <> SPACE(2)
                        SELECT A
                        DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
                        SEEK MSALESMAN
                        IF .NOT. EOF()
                           STORE NAME TO MSAL_NAME
                        ELSE
                           STORE SPACE(32) TO MSAL_NAME
                        ENDIF
                        SELECT D
                     ELSE
                        STORE SPACE(32) TO MSAL_NAME
                     ENDIF
                     STORE 0 TO M0_6DAYS, M7_14DAYS, M15_21DAYS, M22_30DAYS, MOVER_30
                     DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
                        STORE NAME TO MNAME
                        STORE RSUPCODE TO MBBUYCODE
                        SELECT C
                        SEEK MBBUYCODE
                        IF .NOT. EOF()
                           ** STORE CUS_BAL TO MBALANCE
                           STORE CRED_LIM TO MCRED_LIM
                           MCRED_LIM1 = SPACE(10)       
                           IF MCRED_LIM = 0
                              DO CASE
                              CASE SUBSTR(NOTE,1,3) = 'L/C' .OR. SUBSTR(NOTE,1,3) = 'CAD' .OR. SUBSTR(NOTE,1,3) = 'COD'
                                 STORE SUBSTR(NOTE,1,3) TO MCRED_LIM1
                              CASE SUBSTR(NOTE,1,6) = 'C.O.D.'
                                 STORE SUBSTR(NOTE,1,6) TO MCRED_LIM1
                              CASE SUBSTR(NOTE,1,9) = 'NO CREDIT'
                                 STORE SUBSTR(NOTE,1,9) TO MCRED_LIM1
                              CASE SUBSTR(NOTE,1,10) = 'LOAD BASIS' .OR. SUBSTR(NOTE,1,10) = 'LOAD-BASIS'
                                 STORE SUBSTR(NOTE,1,10) TO MCRED_LIM1
                              CASE SUBSTR(NOTE,1,10) = 'INV TO INV' .OR. SUBSTR(NOTE,1,10) = 'INV-TO-INV'
                                 STORE SUBSTR(NOTE,1,10) TO MCRED_LIM1
                              ENDCASE
                           ENDIF
                           
                           STORE '(' + AREA_CODE + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4) TO MPHONE
                           STORE TRIM(CITY) + ', ' + STATE TO MADDR
                           IF SHIPS_25 <> 0 .AND. DAYS_25 <> 0
                              MAVG_25 = DAYS_25/SHIPS_25
                           ELSE
                              MAVG_25 = 0
                           ENDIF
                           
                           IF SHIPS_180 <> 0 .AND. DAYS_180 <> 0
                              MAVG_180 = DAYS_180/SHIPS_180
                           ELSE
                              MAVG_180 = 0
                           ENDIF
                        ELSE
                           STORE 0 TO MCRED_LIM, MAVG_25, MAVG_180
                           STORE SPACE(13) TO MPHONE, MADDR
                           MCRED_LIM1 = SPACE(10)
                        ENDIF
                        STORE 0 TO MOVERDUE, MBALANCE
                        MPRT_CUST = .T.
                        SELECT D
                        DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. NAME = MNAME .AND. RSUPCODE = MBBUYCODE
                           
                           MBALANCE = MBALANCE + STILL_DUE
                           IF PO_NBR = SPACE(4)
                              STORE MRPT_DATE - TRAN_DATE TO MDAYS
                              DO CASE
                              CASE MDAYS <= 6
                                 M0_6DAYS = M0_6DAYS + STILL_DUE
                              CASE MDAYS > 6 .AND. MDAYS < 15
                                 M7_14DAYS = M7_14DAYS + STILL_DUE
                              CASE MDAYS > 14 .AND. MDAYS < 22
                                 M15_21DAYS = M15_21DAYS + STILL_DUE
                              CASE MDAYS > 21 .AND. MDAYS < 31
                                 M22_30DAYS = M22_30DAYS + STILL_DUE
                              OTHERWISE 
                                 MOVER_30 = MOVER_30 + STILL_DUE
                              ENDCASE
                              SKIP
                              LOOP
                           ENDIF
                           
                           IF MLINE > MPAGE_LEN
                              MPRT_CUST = .T.
                              DO AGE_HEAD
                           ELSE 
                              IF MPRT_CUST
                                 @ MLINE,1 SAY MNAME
                                 @ MLINE,45 SAY MPHONE
                                 MLINE = MLINE + 1
                                 @ MLINE,1 SAY MADDR
                                 MPRT_CUST = .F.
                                 MLINE = MLINE + 2
                                 IF MLINE > MPAGE_LEN
                                    MPRT_CUST = .T.
                                    DO AGE_HEAD
                                 ENDIF
                              ENDIF
                           ENDIF
                           
                           IF SALESMAN <> '  '
                              @ MLINE,1 SAY SALESMAN + '-'
                           ENDIF
                           @ MLINE,4 SAY INV_NBR
                           @ MLINE,10 SAY TOT_SELL PICTURE '9,99,999.99'
                           @ MLINE,23 SAY STILL_DUE PICTURE '9,999,999.99'
                           @ MLINE,40 SAY BUYER_PO
                           IF SALESMAN <> '  '
                              @ MLINE,56 SAY SALESMAN + '-'
                           ENDIF
                           @ MLINE,59 SAY PO_NBR
                           IF PO_SUFFIX <> SPACE(1)
                              @ MLINE,63 SAY '-' + PO_SUFFIX
                           ENDIF
                           @ MLINE,70 SAY TRAN_DATE
                           STORE MRPT_DATE - TRAN_DATE TO MDAYS_OLD
                           @ MLINE,82 SAY MDAYS_OLD PICTURE '999'
                           STORE MDATE - TRAN_DATE TO MDAYS
                           @ MLINE,92 SAY MDAYS PICTURE '999'
                           MOVERDUE = MOVERDUE + STILL_DUE       
                           
                           DO CASE
                           CASE MDAYS_OLD <= 6
                              M0_6DAYS = M0_6DAYS + STILL_DUE
                           CASE MDAYS_OLD > 6 .AND. MDAYS_OLD < 15
                              M7_14DAYS = M7_14DAYS + STILL_DUE
                           CASE MDAYS_OLD > 14 .AND. MDAYS_OLD < 22
                              M15_21DAYS = M15_21DAYS + STILL_DUE
                           CASE MDAYS_OLD > 21 .AND. MDAYS_OLD < 31
                              M22_30DAYS = M22_30DAYS + STILL_DUE
                           OTHERWISE 
                              MOVER_30 = MOVER_30 + STILL_DUE
                           ENDCASE
                           MLINE = MLINE + 2
                           SKIP
                        ENDDO
                        **** DO CUSTOMER OVERDUE BALANCE HERE
                        IF MOVERDUE > 0
                           IF MLINE > MPAGE_LEN
                              MPRT_CUST = .T.
                              DO AGE_HEAD
                           ENDIF
                           @ MLINE,5 SAY 'OVERDUE TOTAL: '
                           @ MLINE,22 SAY MOVERDUE PICTURE '9,999,999.99'
                           MLINE = MLINE + 2
                           IF MLINE > MPAGE_LEN
                              MPRT_CUST = .T.
                              DO AGE_HEAD
                           ENDIF
                           @ MLINE,5 SAY '    TOTAL DUE:'      
                           @ MLINE,24 SAY MBALANCE PICTURE '999,999.99'
                           MLINE = MLINE + 2
                           IF MLINE > MPAGE_LEN
                              MPRT_CUST = .T.
                              DO AGE_HEAD
                           ENDIF
                           @ MLINE,5 SAY ' CREDIT LIMIT:'      
                           DO CASE
                           CASE MCRED_LIM <> 0
                              @ MLINE,24 SAY MCRED_LIM PICTURE '999,999.99'
                           CASE MCRED_LIM1 <> SPACE(10)
                              @ MLINE,24 SAY MCRED_LIM1                     
                           OTHERWISE
                              @ MLINE,24 SAY MCRED_LIM PICTURE '999,999.99'
                           ENDCASE
                           
                           MLINE = MLINE + 2
                           IF MAVG_25 <> 0 .OR. MAVG_180 <> 0
                              IF MLINE > MPAGE_LEN
                                 MPRT_CUST = .T.
                                 DO AGE_HEAD
                              ENDIF
                              IF MPROG_CODE = 1
                                 @ MLINE,1 SAY 'PAST 6 MONTHS AVG. PAY:'      
                              ELSE
                                 @ MLINE,1 SAY 'PAST 2 YEARS AVG. PAY:'      
                              ENDIF
                              
                              @ MLINE,24 SAY MAVG_180 PICTURE '999,999.99'
                              MLINE = MLINE + 2
                              IF MPROG_CODE = 1
                                 @ MLINE,1 SAY ' PAST 25 DAYS AVG. PAY:'      
                              ELSE
                                 @ MLINE,1 SAY '  PAST 1 YEAR AVG. PAY:'      
                              ENDIF
                              
                              @ MLINE,24 SAY MAVG_25  PICTURE '999,999.99'
                              MLINE = MLINE + 2
                           ENDIF
                           MLINE = MLINE + 1
                        ENDIF
                     ENDDO
                     
                     MLINE = 88
                     MPRT_CUST = .F.
                     DO AGE_HEAD
                     MLINE = MLINE + 2
                     IF MSAL_NAME = SPACE(3)
                        STORE 'KEN' TO MSAL_NAME
                     ENDIF
                     @ MLINE,34 SAY 'SALESPERSON: ' + MSAL_NAME
                     MLINE = MLINE + 4
                     @ MLINE,1 SAY '                    T O T A L   A G E D   A C C O U N T S   R E C E I V A B L E'
                     MLINE = MLINE + 2
                     @ MLINE,1 SAY '---------------------------------------------------------------------------------------------- '
                     @ MLINE+1,1 SAY '[   UNDER 7 DAYS   |   7 - 14 DAYS   |  15 - 21 DAYS   |  22 - 30 DAYS   |    OVER 30 DAYS   ]'
                     @ MLINE+2,1 SAY '[                  |                 |                 |                 |                   ]'
                     MLINE = MLINE + 3
                     @ MLINE,1 SAY '[                  |                 |                 |                 |                   ]'
                     @ MLINE,5 SAY M0_6DAYS PICTURE '9,999,999.99'
                     @ MLINE,23 SAY M7_14DAYS PICTURE '9,999,999.99'
                     @ MLINE,41 SAY M15_21DAYS PICTURE '9,999,999.99'
                     @ MLINE,59 SAY M22_30DAYS PICTURE '9,999,999.99'
                     @ MLINE,79 SAY MOVER_30 PICTURE '9,999,999.99'
                     @ MLINE+1,1 SAY '[                  |                 |                 |                 |                   ]'
                     @ MLINE+2,1 SAY '----------------------------------------------------------------------------------------------'
                     
                     MLINE = MLINE + 4
                     @ MLINE,1 SAY 'TOTAL RECEIVABLES: ' 
                     @ MLINE,20 SAY M0_6DAYS+M7_14DAYS+M15_21DAYS+M22_30DAYS+MOVER_30 PICTURE '999,999,999.99'
                     MLINE = MLINE + 4
                     M0_6TOT = M0_6TOT + M0_6DAYS
                     M7_14TOT = M7_14TOT + M7_14DAYS
                     M15_21TOT = M15_21TOT + M15_21DAYS
                     M22_30TOT = M22_30TOT + M22_30DAYS
                     MOV_30TOT = MOV_30TOT + MOVER_30
                     IF MPROG_CODE = 2
                        @ MLINE,1 SAY 'COUNTRY/REGION             AVG. PAST 1 YR      AVG. PAST 2 YR      TOTAL RECEIVABLE'
                        @ MLINE,1 SAY REPLICATE('_',83)
                        MLINE = MLINE + 2
                        IF EOF()
                           MRECNO = 0
                        ELSE
                           MRECNO = RECNO()
                        ENDIF
                        SET ORDER TO 2
                        SEEK MSALESMAN
                        DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
                           MSHIPS_25 = 0
                           MDAYS_25  = 0
                           MSHIPS_180 = 0
                           MDAYS_180  = 0
                           MREGION = REGION 
                           MDUE = 0
                           DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. REGION = MREGION
                              MBBUYCODE = RSUPCODE
                              SELECT C
                              SEEK MBBUYCODE
                              MSHIPS_25  = MSHIPS_25  + SHIPS_25
                              MDAYS_25   = MDAYS_25   + DAYS_25
                              MSHIPS_180 = MSHIPS_180 + SHIPS_180
                              MDAYS_180  = MDAYS_180  + DAYS_180
                              SELECT D
                              DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. REGION = MREGION .AND. MBBUYCODE = RSUPCODE
                                 MDUE = MDUE + STILL_DUE
                                 SKIP
                              ENDDO
                           ENDDO
                           @ MLINE,1 SAY MREGION
                           IF MSHIPS_25 <> 0 .AND. MDAYS_25 <> 0
                              MAVG_25 = MDAYS_25/MSHIPS_25
                           ELSE
                              MAVG_25 = 0
                           ENDIF
                           
                           IF MSHIPS_180 <> 0 .AND. MDAYS_180 <> 0
                              MAVG_180 = MDAYS_180/MSHIPS_180
                           ELSE
                              MAVG_180 = 0
                           ENDIF
                           @ MLINE,32 SAY MAVG_180 PICTURE '999,999.99'
                           @ MLINE,52 SAY MAVG_25  PICTURE '999,999.99'
                           @ MLINE,70 SAY MDUE PICTURE '999,999,999.99'
                           MLINE = MLINE + 2
                        ENDDO
                        SET ORDER TO 1
                        IF MRECNO <> 0
                           GOTO MRECNO     
                        ENDIF
                     ENDIF
                     MLINE = 80
                     MPAGE_NO = 0
                  ENDDO
                  
                  IF MCODE = '**'
                     EJECT
                     MLINE = 99
                     MPRT_CUST = .F.
                     DO AGE_HEAD
                     MLINE = MLINE + 2
                     @ MLINE,36 SAY MCOMPANY                     
                     MLINE = MLINE + 4
                     @ MLINE,1 SAY '                    T O T A L   A G E D   A C C O U N T S   R E C E I V A B L E'
                     MLINE = MLINE + 2
                     @ MLINE,1 SAY '---------------------------------------------------------------------------------------------- '
                     @ MLINE+1,1 SAY '[   UNDER 7 DAYS   |   7 - 14 DAYS   |  15 - 21 DAYS   |  22 - 30 DAYS   |    OVER 30 DAYS   ]'
                     @ MLINE+2,1 SAY '[                  |                 |                 |                 |                   ]'
                     MLINE = MLINE + 3
                     @ MLINE,1 SAY '[                  |                 |                 |                 |                   ]'
                     @ MLINE,5 SAY M0_6TOT PICTURE '9,999,999.99'
                     @ MLINE,23 SAY M7_14TOT PICTURE '9,999,999.99'
                     @ MLINE,41 SAY M15_21TOT PICTURE '9,999,999.99'
                     @ MLINE,59 SAY M22_30TOT PICTURE '9,999,999.99'
                     @ MLINE,79 SAY MOV_30TOT PICTURE '9,999,999.99'
                     @ MLINE+1,1 SAY '[                  |                 |                 |                 |                   ]'
                     @ MLINE+2,1 SAY '----------------------------------------------------------------------------------------------'
                     
                     MLINE = MLINE + 4
                     @ MLINE,1 SAY 'GRAND TOTAL RECEIVABLES: ' 
                     @ MLINE,28 SAY M0_6TOT+M7_14TOT+M15_21TOT+M22_30TOT+MOV_30TOT PICTURE '999,999,999,999.99'
                     MLINE = MLINE + 4
                  ENDIF
                  IF MPROG_CODE = 2
                     @ MLINE,1 SAY 'COUNTRY/REGION             AVG. PAST 1 YR      AVG. PAST 2 YR      TOTAL RECEIVABLE'
                     @ MLINE,1 SAY REPLICATE('_',83)
                     MLINE = MLINE + 2
                     SET ORDER TO 3
                     GOTO TOP
                     DO WHILE .NOT. EOF()
                        MSHIPS_25 = 0
                        MDAYS_25  = 0
                        MSHIPS_180 = 0
                        MDAYS_180  = 0
                        MREGION = REGION 
                        MDUE = 0
                        DO WHILE .NOT. EOF() .AND. REGION = MREGION
                           SELECT C
                           SEEK D->RSUPCODE
                           MSHIPS_25  = MSHIPS_25  + SHIPS_25
                           MDAYS_25   = MDAYS_25   + DAYS_25
                           MSHIPS_180 = MSHIPS_180 + SHIPS_180
                           MDAYS_180  = MDAYS_180  + DAYS_180
                           SELECT D
                           MBBUYCODE = RSUPCODE
                           DO WHILE .NOT. EOF() .AND. REGION = MREGION .AND. MBBUYCODE = RSUPCODE
                              MDUE = MDUE + STILL_DUE
                              SKIP
                           ENDDO
                        ENDDO
                        @ MLINE,1 SAY MREGION
                        IF MSHIPS_25 <> 0 .AND. MDAYS_25 <> 0
                           MAVG_25 = MDAYS_25/MSHIPS_25
                        ELSE
                           MAVG_25 = 0
                        ENDIF
                        
                        IF MSHIPS_180 <> 0 .AND. MDAYS_180 <> 0
                           MAVG_180 = MDAYS_180/MSHIPS_180
                        ELSE
                           MAVG_180 = 0
                        ENDIF
                        @ MLINE,32 SAY MAVG_180 PICTURE '999,999.99'
                        @ MLINE,52 SAY MAVG_25  PICTURE '999,999.99'
                        @ MLINE,70 SAY MDUE PICTURE '999,999,999.99'
                        MLINE = MLINE + 2
                     ENDDO
                     SET ORDER TO 1
                     GOTO TOP
                  ENDIF
                  @ MLINE+1,1 SAY ' '

                  MLINE = 80
                  MPAGE_NO = 0
                  EJECT
                  I = I + 1
               ENDDO
            ENDCASE
            
            SET DEVICE TO SCREEN
            SET PRINT OFF
            SET PRINT TO
            SET CONSOLE ON
            IF MPRINTER3 <> 'DONOTPRINT'
               RUN &MPRINTIT3
            ENDIF
            
         OTHERWISE
            @ 4,1 CLEAR TO 21,78
            IF MAGE_PICK <> 'ALL  '
               STORE '**' TO MCODE
               STORE 2 TO MACTION      
               DO WHILE MACTION = 2      
                  @ 10,5 SAY ' SALESPERSON CODE: '
                  @ 10,24 GET MCODE               
                  @ 12,5 SAY " (ENTER '**' IF REPORT DESIRED FOR ALL SALESPERSONS)"
                  STORE 1 TO MACTION
                  @ 23,00 CLEAR
                  @ 24,01 SAY 'Action: ' + STR(MACTION,1)
                  @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
                  
                  READ
                  
                  @24,09 GET MACTION PICTURE '9' RANGE 1,3
                  READ               
               ENDDO
               
               IF MACTION = 3
                  LOOP  
               ENDIF  
            ENDIF
            MPRT_ACT = 'C'
            DO PRT_SET
            IF MPRT_ACT <> 'C'
               LOOP  
            ENDIF
            
            *** THESE ARE THE SUMMARY REPORTS ****
            MPAGE_NO = 0
            MLINE = 99 
            MPAGE_LEN = 58
            SELECT B
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
            
            SELECT C
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
            
            SELECT D
            USE TEMP_AGE EXCLUSIVE
            
            INDEX ON SALESMAN + NAME  + RSUPCODE TO TEMP_AGE
            USE      
            DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE", .F.
            
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
            ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
            
            *** LETTER SIZE PAPER
            ?? CHR(27) + '&l2A'
            
            *** PORTRAIT MODE
            ?? CHR(27) + '&l0O'
            
            *** THIS IS THE FIRST OF TWO TYPES OF SUMMARY REPORTS
            *** THIS REPORT IS ACCOUNTS OVER THEIR CREDIT LIMITS
            DO WHILE .NOT. EOF()
               IF MCODE <> '**'
                  IF MCODE <> SALESMAN
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               
               MSALESMAN = SALESMAN
               SELECT B
               SEEK MSALESMAN 
               IF .NOT. EOF()
                  MSAL_NAME = NAME
               ELSE
                  IF MSALESMAN = '  '
                     MSAL_NAME = 'KEN    '
                  ELSE 
                     MSAL_NAME = 'UNKNOWN'
                  ENDIF
               ENDIF
               SELECT D
               DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
                  MNAME = NAME
                  MBBUYCODE = RSUPCODE    
                  DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. NAME = MNAME .AND. RSUPCODE = MBBUYCODE
                     SKIP
                  ENDDO
                  SELECT C
                  SEEK MBBUYCODE
                  IF .NOT. EOF()
                     IF CUS_BAL < CRED_LIM
                        SELECT D
                        LOOP
                     ENDIF
                  ELSE
                     SELECT D
                     LOOP
                  ENDIF
                  SELECT D
                  IF MLINE > MPAGE_LEN
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                     MPAGE_NO = MPAGE_NO + 1
                     @ 1,25 SAY MCOMPANY
                     @ 1,1 SAY 'PAGE'
                     @ 1,06 say mpage_no picture '99'
                     @ 1,61  SAY DTOC(DATE())
                     @ 2,19 SAY 'CUSTOMER ACCOUNTS OVER CREDIT LIMIT'
                     IF MAGE_PICK <> 'ALL'
                        @ 3,19 SAY 'SALESPERSON: ' + MSAL_NAME
                     ENDIF
                     @ 5,1 SAY 'SALES   ACCOUNT                                 LIMIT        BALANCE'
                     @ 5,0 SAY REPLICATE ('_',70)
                     MLINE = 7
                  ENDIF
                  @ MLINE,2 SAY MSALESMAN
                  @ MLINE,9 SAY MNAME
                  
                  IF C->CRED_LIM <> 0
                     @ MLINE,45 SAY C->CRED_LIM PICTURE '9,999,999'
                  ELSE
                     MCRED_LIM1 = SPACE(10)
                     DO CASE
                     CASE SUBSTR(C->NOTE,1,3) = 'L/C' .OR. SUBSTR(C->NOTE,1,3) = 'CAD' .OR. SUBSTR(C->NOTE,1,3) = 'COD'
                        STORE SUBSTR(C->NOTE,1,3) TO MCRED_LIM1
                     CASE SUBSTR(C->NOTE,1,6) = 'C.O.D' 
                        STORE SUBSTR(C->NOTE,1,6) TO MCRED_LIM1
                     CASE SUBSTR(C->NOTE,1,9) = 'NO CREDIT'
                        STORE SUBSTR(C->NOTE,1,9) TO MCRED_LIM1
                     CASE SUBSTR(C->NOTE,1,10) = 'LOAD BASIS' .OR. SUBSTR(C->NOTE,1,10) = 'LOAD-BASIS'
                        STORE SUBSTR(C->NOTE,1,10) TO MCRED_LIM1
                     CASE SUBSTR(C->NOTE,1,10) = 'INV TO INV' .OR. SUBSTR(C->NOTE,1,10) = 'INV-TO-INV'
                        STORE SUBSTR(C->NOTE,1,10) TO MCRED_LIM1
                     ENDCASE
                     
                     IF MCRED_LIM1 <> SPACE(10)
                        @ MLINE,45 SAY MCRED_LIM1                         
                     ELSE
                        @ MLINE,45 SAY C->CRED_LIM PICTURE '9,999,999'
                     ENDIF
                  ENDIF
                  @ MLINE,57 SAY C->CUS_BAL  PICTURE '9,999,999.99'
                  MLINE = MLINE + 1
               ENDDO
               MLINE = MLINE + 1
               IF MAGE_PICK <> 'ALL' .AND. MLINE <> 99
                  MLINE = 88
               ENDIF
            ENDDO
            
            EJECT
            
            ***** SECOND SUMMARY REPORT
            ***** PO'S OVER SELECTED DAYS OLD
            MPAGE_NO = 0
            MLINE = 99 
            MPAGE_LEN = 58
            MGRAND_TOT = 0
            SELECT D
            GOTO TOP
            
            DO WHILE .NOT. EOF()
               IF MCODE <> '**'
                  IF MCODE <> SALESMAN
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               
               MSALESMAN = SALESMAN
               SELECT B
               SEEK MSALESMAN 
               IF .NOT. EOF()
                  MSAL_NAME = NAME
               ELSE
                  IF MSALESMAN = '  '
                     MSAL_NAME = 'KEN    '
                  ELSE 
                     MSAL_NAME = 'UNKNOWN'
                  ENDIF
               ENDIF
               MSAL_TOT = 0
               SELECT D
               DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
                  MNAME = NAME
                  MBBUYCODE = RSUPCODE    
                  MBALANCE = 0
                  DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. NAME = MNAME .AND. RSUPCODE = MBBUYCODE
                     IF DATE() - TRAN_DATE < MSEL_DAYS
                        SKIP
                        LOOP
                     ENDIF
                     IF MLINE > MPAGE_LEN
                        IF MLINE <> 99
                           EJECT
                        ENDIF
                        MPAGE_NO = MPAGE_NO + 1
                        @ 1,25 SAY MCOMPANY
                        @ 1,1 SAY 'PAGE'
                        @ 1,06 say mpage_no picture '99'
                        @ 1,61  SAY DTOC(DATE())
                        @ 2,19 SAY 'PURCHASE ORDERS ' + TRANSFORM(MSEL_DAYS, '99') + ' DAYS AND OLDER'
                        IF MAGE_PICK <> 'ALL'
                           @ 3,19 SAY 'SALESPERSON: ' + MSAL_NAME
                        ENDIF
                        @ 5,1 SAY 'PO NBR       ACCOUNT                             AMOUNT DUE      DAYS OLD'
                        @ 5,0 SAY REPLICATE ('_',74)
                        MLINE = 7
                     ENDIF
                     IF SALESMAN <> '  '
                        @ MLINE,1 SAY SALESMAN + '-'
                     ENDIF
                     @ MLINE,4 SAY PO_NBR
                     IF PO_SUFFIX <> ' '
                        @ MLINE,8 SAY '-' + PO_SUFFIX
                     ENDIF
                     @ MLINE,14 SAY NAME 
                     @ MLINE,48 SAY STILL_DUE PICTURE '9,999,999.99'
                     @ MLINE,68 SAY DATE() - TRAN_DATE PICTURE '9999'
                     MBALANCE = MBALANCE + STILL_DUE
                     MLINE = MLINE + 1
                     SKIP
                  ENDDO
                  IF MBALANCE <> 0
                     SELECT C
                     SEEK MBBUYCODE
                     SELECT D
                     @ MLINE,16 SAY 'Customer Total:'
                     @ MLINE,48 SAY MBALANCE PICTURE '9,999,999.99'
                     @ MLINE,63 SAY 'Bal:'
                     IF MCOMPANY = 'DIVISION 15'
                        @ MLINE,67 SAY C->CUS_BAL15 PICTURE '9,999,999.99'
                     ELSE
                        @ MLINE,67 SAY C->CUS_BAL PICTURE '9,999,999.99'
                     ENDIF
                     @ MLINE,82 SAY 'Lim:'
                     IF C->CRED_LIM <> 0
                        @ MLINE,86 SAY C->CRED_LIM PICTURE '9,999,999'
                     ELSE
                        MCRED_LIM1 = SPACE(10)
                        DO CASE
                        CASE SUBSTR(C->NOTE,1,3) = 'L/C' .OR. SUBSTR(C->NOTE,1,3) = 'CAD' .OR. SUBSTR(C->NOTE,1,3) = 'COD'
                           STORE SUBSTR(C->NOTE,1,3) TO MCRED_LIM1
                        CASE SUBSTR(C->NOTE,1,6) = 'C.O.D'
                           STORE SUBSTR(C->NOTE,1,6) TO MCRED_LIM1
                        CASE SUBSTR(C->NOTE,1,9) = 'NO CREDIT'
                           STORE SUBSTR(C->NOTE,1,9) TO MCRED_LIM1
                        CASE SUBSTR(C->NOTE,1,10) = 'LOAD BASIS' .OR. SUBSTR(C->NOTE,1,10) = 'LOAD-BASIS'
                           STORE SUBSTR(C->NOTE,1,10) TO MCRED_LIM1
                        CASE SUBSTR(C->NOTE,1,10) = 'INV TO INV' .OR. SUBSTR(C->NOTE,1,10) = 'INV-TO-INV'
                           STORE SUBSTR(C->NOTE,1,10) TO MCRED_LIM1
                        ENDCASE
                        
                        IF MCRED_LIM1 <> SPACE(10)
                           @ MLINE,86 SAY MCRED_LIM1                         
                        ELSE
                           @ MLINE,86 SAY C->CRED_LIM PICTURE '9,999,999'
                        ENDIF
                     ENDIF
                     
                     @ MLINE,16 SAY REPLICATE('_',15)
                     @ MLINE,48 SAY REPLICATE('_',12)
                     @ MLINE,67 SAY REPLICATE('_',12)
                     @ MLINE,86 SAY REPLICATE('_',12)
                     MLINE = MLINE + 2
                     MSAL_TOT = MSAL_TOT + MBALANCE
                  ENDIF
               ENDDO
               
               IF MSAL_TOT <> 0
                  @ MLINE,1 SAY MSALESMAN + ' SALESPERSON TOTAL:'
                  @ MLINE,48 SAY MSAL_TOT PICTURE '9,999,999.99'
                  @ MLINE,1  SAY REPLICATE('_',21)
                  @ MLINE,48 SAY REPLICATE('_',12)
                  MLINE = MLINE + 2
                  MGRAND_TOT = MGRAND_TOT + MSAL_TOT
               ENDIF
               IF MAGE_PICK <> 'ALL' .AND. MLINE <> 99
                  MLINE = 88
               ELSE
                  MLINE = MLINE + 2
               ENDIF
            ENDDO
            IF MAGE_PICK = 'ALL' .AND. MGRAND_TOT <> 0
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 1,25 SAY MCOMPANY
                  @ 1,1 SAY 'PAGE'
                  @ 1,06 say mpage_no picture '99'
                  @ 1,61  SAY DTOC(DATE())
                  @ 2,19 SAY 'PURCHASE ORDERS ' + TRANSFORM(MSEL_DAYS, '99') + ' DAYS AND OLDER'
                  IF MAGE_PICK <> 'ALL'
                     @ 3,19 SAY 'SALESPERSON: ' + MSAL_NAME
                  ENDIF
                  @ 5,1 SAY 'PO NBR       ACCOUNT                             AMOUNT DUE      DAYS OLD'
                  @ 5,0 SAY REPLICATE ('_',74)
                  MLINE = 7
               ENDIF
               @ MLINE,1 SAY 'GRAND TOTAL:'
               @ MLINE,48 SAY MGRAND_TOT PICTURE '9,999,999.99'
               @ MLINE,1  SAY REPLICATE('_',12)
               @ MLINE,48 SAY REPLICATE('_',12)
               MLINE = MLINE + 2
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
            SET CONSOLE ON
         ENDCASE
         
      ENDDO
      
      CLOSE DATA
      
      
   CASE VAL(MSELECTION) =  5
      
      MTITLE = ' - PRINT DATE-TO-DATE RECEIPTS ACTIVITY BY ACCOUNT'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      STORE CTOD(' ') TO MBEG_DATE, MEND_DATE
      STORE SPACE(4) TO MACCOUNT
      MOPT_SALES = '**'
      MCHOICE = 'D'
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 08,5 SAY 'REPORT BEGINNING DATE: ' GET MBEG_DATE        
         @ 10,5 SAY '   REPORT ENDING DATE: ' GET MEND_DATE
         @ 12,5 SAY '         ACCOUNT CODE: ' GET MACCOUNT PICTURE '####'
         IF MPROG_CODE = 2
            @ 16,4 SAY '(OPTIONAL) SALESPERSON: ' GET MOPT_SALES               
         ENDIF
         
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
      SELECT D
      DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
      SEEK MACCOUNT
      IF EOF()
         STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP
      ELSE
         STORE DESCRIP TO MDESCRIP 
      ENDIF
      MTOTAL = 0
      SELECT B
      DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE", .F.
      SEEK MBEG_YEAR + MBEG_MO   
      DO WHILE .NOT. EOF() .AND. PAID_DATE < MBEG_DATE
         SKIP
      ENDDO 
      DO WHILE .NOT. EOF() .AND. PAID_DATE <= MEND_DATE
         IF MACCOUNT <> ACCOUNT  
            SKIP
            LOOP
         ENDIF
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,35 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,20 SAY '  RECEIPTS REPORT FOR ' + M1_DATE + ' THRU ' + M2_DATE
            @ 3,85 SAY DTOC(DATE())
            @ 5,26 SAY 'ACCOUNT: '+ MACCOUNT+' (' + TRIM(MDESCRIP)+')'
            @ 7,5 SAY '         RECEIPT DATE         AMOUNT'
            MLINE = 9 
         ENDIF
         @ MLINE,18 SAY PAID_DATE   
         @ MLINE,28 SAY AMT_OVER PICTURE '99,999,999.99'
         MLINE = MLINE + 1
         MTOTAL = MTOTAL + AMT_OVER
         SKIP
      ENDDO
      IF MTOTAL <> 0
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,35 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,20 SAY '  RECEIPTS REPORT FOR ' + M1_DATE + ' THRU ' + M2_DATE
            @ 3,85 SAY DTOC(DATE())
            @ 5,26 SAY 'ACCOUNT: '+ MACCOUNT+' (' + TRIM(MDESCRIP)+')'
            @ 7,5 SAY '         RECEIPT DATE         AMOUNT'
            MLINE = 9 
         ENDIF
         
         MLINE = MLINE + 2
         @ MLINE,5 SAY 'TOTAL AMOUNT RCVD: '    
         @ MLINE,28 SAY MTOTAL PICTURE '99,999,999.99'
      ENDIF
      
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
      LOOP
      
      ******* OLD STUFF STARTS MFI AGING *******
      **** DO ALL THE PRINT ROUTINE STUFF
      MTITLE = ' - AGING REPORT FOR MFI'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE DATE() TO MRPT_DATE
      STORE 'D' TO MDISP_PRT
      STORE 'N' TO MYES_NO
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 10,5 SAY 'ENTER REPORT DATE: '
         @ 10,24 GET MRPT_DATE
         @ 13,5 SAY 'SELECT SPECIFIC SHIP TO CUSTOMER (Y/N)? ' GET MYES_NO PICTURE '@!'
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF DTOC(MRPT_DATE) = '  /  /  '
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'NO DATE ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
               READ
               MACTION = 2
               @ 24,0 CLEAR
               LOOP 
            ENDIF
         ENDIF
      ENDDO
      
      IF MACTION = 3
         RETURN
      ENDIF  
      
      IF MYES_NO = 'Y'
         ***** SELECT A SPECFIC SHIP TO CUSTOMER
         
         SAVE SCREEN TO MGRACE
         SELECT C
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_NAME", .F.
         STORE SPACE(32)    TO MNAME 
         MNAME_FD = .F.
         STORE 1 TO MACTION
         MBUY_SEL = .T.
         DO WHILE MBUY_SEL
            CLEAR 
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            MTITLE = ' - SELECT SHIP TO CUSTOMER'
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            @  5, 5 SAY 'Enter Customer Search Field:'
            @  8, 5 SAY 'Name'
            @ 10, 5 GET Mname PICTURE '@!'
            
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
            @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
            
            DO CASE
               
            CASE MACTION = 1
               IF MNAME <> SPACE(32)
                  STORE TRIM(MNAME) TO SRCH_ARG
                  SEEK SRCH_ARG
                  IF EOF() .OR. DELETED()
                     @ 24,0 CLEAR
                     STORE ' ' TO MYES_NO
                     @ 24,05 SAY 'NAME NOT FOUND - PRESS RETURN TO REENTER ' get MYES_NO PICTURE '@!'
                     READ
                     @ 24,0 CLEAR     
                     LOOP
                  ELSE               
                     STORE RECNO() TO MFST_REC
                     SKIP
                     IF NAME = SRCH_ARG
                        MADD = .F.
                        DO MUL1BUY
                        IF MACTION <> 5
                           MNAME_FD = .T.
                        ENDIF
                     ELSE
                        GOTO MFST_REC
                        MNAME_FD = .T.
                     ENDIF
                  ENDIF
               ENDIF
               
               MBUY_SEL = .F.
               
            CASE MACTION = 3
               MBUY_SEL = .F.
               
            ENDCASE
            
         ENDDO
         RESTORE SCREEN FROM MGRACE
         IF .NOT. MNAME_FD 
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY 'SHIP TO CUSTOMER NOT SELECTED - PRESS RETURN TO CONTINUE ' GET MWAIT
            @ 24,0 CLEAR
            LOOP
         ELSE
            STORE BUY_CODE TO MPICK_CODE
         ENDIF
      ELSE
         STORE SPACE(4) TO MPICK_CODE
      ENDIF
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         RETURN
      ENDIF
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
      
      DO WHILE .NOT. EOF()
         DO RECLOCK
         REPLACE CUS_BAL WITH 0
         UNLOCK
         SKIP
      ENDDO
      
      SELECT B
      DO FOX_USE WITH "INV_ADJ INDEX INV_ADJ", .F.
      SELECT F
      DO FOX_USE WITH "INV_HEAD INDEX INV_HEAD", .F.
      
      SELECT D
      USE TEMP_AGE INDEX TEMP_AGE EXCLUSIVE         
      DELETE ALL
      PACK
      USE
      SELECT D
      DO FOX_USE WITH "TEMP_AGE", .F.
      INDEX ON NAME + RSUPCODE TO TEMP_AGE
      DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE", .F.
      
      SELECT E
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      
      SELECT A
      DO FOX_USE WITH "CUS_INV INDEX CUS_DATE", .F.
      
      SEEK ' '            
      IF EOF()
         @ 14,1 SAY 'THERE ARE NO OUTSTANDING INVOICES TO BE AGED'         
         @ 16,1 SAY ' '
         WAIT 'PRESS RETURN TO CONTINUE'
         RETURN
      ENDIF
      MPAGE_NO = 0
      MLINE = 99 
      MPAGE_LEN = 58
      
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
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
      MDATE = MRPT_DATE - 7 
      DO WHILE .NOT. EOF() .AND. PAID_FLG = ' '
         **** MIDWEST FOODS INTL. BUYER CODE
         IF BBUYCODE <> ' 123'
            SKIP
            LOOP
         ENDIF
         DO WHILE .NOT. EOF() .AND. PAID_FLG = ' ' .AND. BBUYCODE = ' 123'
            IF MPICK_CODE <> SPACE(4)
               IF BUY_CODE <> MPICK_CODE
                  SKIP
                  LOOP
               ELSE
                  STORE MPICK_CODE TO MBUY_CODE
               ENDIF
            ELSE
               STORE BUY_CODE TO MBUY_CODE
            ENDIF
            SELECT C
            SEEK MBUY_CODE
            
            IF .NOT. EOF()
               STORE NAME TO MNAME
            ELSE 
               STORE 'SHIP TO  NOT ON FILE' TO MNAME
            ENDIF
            SELECT A
            
            STORE INV_NBR TO MINV_NBR
            STORE SALESMAN TO MSALESMAN
            STORE PO_NBR TO MPO_NBR
            STORE PO_SUFFIX TO MPO_SUFFIX
            SELECT F
            SEEK A->INV_NBR
            IF EOF()
               STORE 0 TO MTOT_SELL, MAMT
            ELSE
               STORE TOT_SELL TO MTOT_SELL, MAMT
            ENDIF
            SELECT E
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF .NOT. EOF()
               STORE BUYER_PO TO MBUYER_PO
            ELSE
               STORE SPACE(15) TO MBUYER_PO
            ENDIF
            SELECT B
            SEEK MINV_NBR
            DO WHILE .NOT. EOF() .AND. INV_NBR = MINV_NBR
               MAMT = MAMT + ADJ_AMT
               SKIP
            ENDDO
            SELECT A
            MSTILL_DUE = MAMT - AMT_PAID
            
            IF MSTILL_DUE > 0 
               IF DTOC(SHIP_DATE) <> '  /  /  '
                  STORE SHIP_DATE TO MTRAN_DATE    
               ELSE
                  STORE INV_DATE TO MTRAN_DATE   
               ENDIF
               
               SELECT D
               DO FILELOCK
               APPEND BLANK
               REPLACE NAME WITH MNAME
               REPLACE RSUPCODE WITH MBUY_CODE
               REPLACE SALESMAN WITH A->SALESMAN
               REPLACE INV_NBR WITH MINV_NBR
               REPLACE TOT_SELL WITH MTOT_SELL
               REPLACE STILL_DUE WITH MSTILL_DUE            
               REPLACE TRAN_DATE WITH MTRAN_DATE
               REPLACE PO_NBR WITH MPO_NBR
               REPLACE PO_SUFFIX WITH MPO_SUFFIX
               REPLACE BUYER_PO WITH MBUYER_PO
               UNLOCK
               
               SELECT C
               SEEK MBUY_CODE
               IF .NOT. EOF()
                  DO RECLOCK
                  REPLACE CUS_BAL WITH CUS_BAL + MSTILL_DUE
                  UNLOCK
               ENDIF
            ENDIF
            SELECT A
            SKIP
         ENDDO
         
         SELECT A
      ENDDO
      CLOSE DATA
      
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
      
      SELECT D
      DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE", .F.
      DO WHILE .NOT. EOF()
         STORE RSUPCODE TO MBUY_CODE
         STORE NAME TO MNAME      
         SELECT C
         SEEK MBUY_CODE
         IF .NOT. EOF()
            IF MCOMPANY = 'DIVISION 15'
               STORE CUS_BAL15 TO MBALANCE
            ELSE
               STORE CUS_BAL TO MBALANCE
            ENDIF
            STORE 0 TO MCRED_LIM
            STORE '(' + AREA_CODE + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4) TO MPHONE
            STORE TRIM(CITY) + ', ' + STATE TO MADDR
         ELSE
            STORE 0 TO MBALANCE, MCRED_LIM
            STORE SPACE(13) TO MPHONE, MADDR
         ENDIF
         
         MOVERDUE = 0
         MPRT_CUST = .T.
         SELECT D
         DO WHILE .NOT. EOF() .AND. RSUPCODE = MBUY_CODE .AND. NAME = MNAME
            IF MLINE > MPAGE_LEN
               DO MFI_HEAD
            ELSE 
               IF MPRT_CUST
                  @ MLINE,1 SAY MNAME
                  @ MLINE,45 SAY MPHONE
                  MLINE = MLINE + 1
                  @ MLINE,1 SAY MADDR
                  MPRT_CUST = .F.
                  MLINE = MLINE + 2
                  IF MLINE > MPAGE_LEN
                     DO MFI_HEAD
                  ENDIF
               ENDIF
            ENDIF
            IF SALESMAN <> '  '
               @ MLINE,1 SAY SALESMAN + '-'
            ENDIF
            @ MLINE,4 SAY INV_NBR
            @ MLINE,12 SAY TOT_SELL PICTURE '999,999.99'
            @ MLINE,25 SAY STILL_DUE PICTURE '999,999.99'
            @ MLINE,40 SAY BUYER_PO
            IF MSALESMAN <> '  '
               @ MLINE,56 SAY SALESMAN + '-'
            ENDIF
            @ MLINE,59 SAY PO_NBR
            IF MPO_SUFFIX <> SPACE(1)
               @ MLINE,63 SAY '-' + PO_SUFFIX
            ENDIF
            @ MLINE,70 SAY TRAN_DATE
            STORE MRPT_DATE - TRAN_DATE TO MDAYS
            @ MLINE,82 SAY MDAYS PICTURE '999'
            STORE MDATE - TRAN_DATE TO MDAYS
            IF MDAYS > 0
               @ MLINE,92 SAY MDAYS PICTURE '999'
            ENDIF 
            IF MDAYS > 0
               MOVERDUE = MOVERDUE + STILL_DUE       
            ENDIF
            MLINE = MLINE + 2
            SKIP
         ENDDO
         **** DO CUSTOMER OVERDUE BALANCE HERE
         IF MLINE > MPAGE_LEN
            DO MFI_HEAD
         ENDIF
         @ MLINE,5 SAY 'OVERDUE TOTAL: '
         @ MLINE,22 SAY MOVERDUE PICTURE '9,999,999.99'
         MLINE = MLINE + 2
         IF MLINE > MPAGE_LEN
            DO MFI_HEAD
         ENDIF
         @ MLINE,5 SAY '    TOTAL DUE:'      
         @ MLINE,24 SAY MBALANCE PICTURE '999,999.99'
         MLINE = MLINE + 2
         IF MLINE > MPAGE_LEN
            DO MFI_HEAD
         ENDIF
         @ MLINE,5 SAY ' CREDIT LIMIT:'      
         @ MLINE,24 SAY MCRED_LIM PICTURE '999,999.99'
         MLINE = MLINE + 3
      ENDDO
      
      @ MLINE + 1,1 SAY ' '
      EJECT
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      
   CASE VAL(MSELECTION) = 6    
      MTITLE = ' - ACTIVE CUSTOMER CREDIT LIMIT REPORT BY SALESPERSON'    
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE CTOD(' ') TO MDATE, MBEGIN
      STORE '**' TO MOPT_SALES
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 06,5 SAY '  ENTER BEGINNING REPORT DATE: '
         @ 06,37 GET MBEGIN
         @ 08,5 SAY '     ENTER ENDING REPORT DATE: '
         @ 08,37 GET MDATE
         @ 12,4 SAY '     OPTIONAL SALESPERSON CODE:'       
         @ 12,37 GET MOPT_SALES PICTURE '##'
         @ 13,2 SAY "(ENTER '**' FOR ALL SALESPERSONS)"
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF DTOC(MDATE) = '  /  /  ' .OR. DTOC(MBEGIN) = '  /  /  '
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'NO DATE ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
               READ
               MACTION = 2
               @ 24,0 CLEAR
               LOOP 
            ELSE
               IF MDATE < MBEGIN
                  @ 24,0 CLEAR
                  mwait = ' '
                  @ 24,1 SAY 'ENDING DATE BEFORE BEGINNING - PRESS ANY KEY TO REENTER' GET MWAIT
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
      
      MPRT_ACT = 'C'
      
      DO PRT_SET
      
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      MPAGE_LEN = 56
      
      MPAGE_NO = 0
      MLINE = 99 
      @ 19,16 SAY 'PROCESSING & PRINTING.....PLEASE WAIT...'
      SELECT D
      DO FOX_USE WITH "CUS_TMP INDEX CUS_TMP", .F.
      DO FILELOCK
      USE CUS_TMP EXCLUSIVE
      DELETE ALL
      PACK
      INDEX ON SALESMAN + BBUYNAME TO CUS_TMP
      USE CUS_TMP INDEX CUS_TMP EXCLUSIVE
      
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
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      SELECT A
      DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP", .F.
      MSHIP_DATE = SUBSTR(DTOC(MBEGIN),7) + SUBSTR(DTOC(MBEGIN),1,2) 
      SEEK MSHIP_DATE
      DO WHILE .NOT. EOF() .AND. SHIP_DATE < MBEGIN
         SKIP
      ENDDO
      
      DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MDATE
         
         IF BBUYCODE = 'NONE' .OR. BBUYCODE = 'INVN'
            SKIP
            LOOP
         ENDIF
         
         IF MOPT_SALES <> '**'  
            IF SALESMAN <> MOPT_SALES
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         MSALESMAN = SALESMAN
         MBBUYCODE = BBUYCODE
         SELECT C
         SEEK MBBUYCODE
         IF EOF()
            STORE 'CUSTOMER NOT ON FILE' TO MBBUYNAME
         ELSE
            STORE NAME TO MBBUYNAME
         ENDIF
         
         SELECT D
         SEEK MSALESMAN + MBBUYNAME
         IF .NOT. EOF()
            REPLACE PAY_POST WITH PAY_POST + A->TOT_SELL + A->CUS_AMT1 + A->CUS_AMT2 + A->CUS_PALL
            REPLACE CRED_BAL WITH CRED_BAL + A->TOT_LBS
            SELECT A
            SKIP
            LOOP
         ENDIF
         SELECT D
         APPEND BLANK
         REPLACE SALESMAN WITH MSALESMAN
         REPLACE BBUYNAME WITH MBBUYNAME
         REPLACE ADDRESS  WITH C->STREET
         REPLACE CITY     WITH C->CITY
         REPLACE STATE    WITH C->STATE
         REPLACE ZIP      WITH C->ZIP
         REPLACE PHONE    WITH C->AREA_CODE + C->PHONE
         IF C->SHIPS_25 <> 0 .OR. C->DAYS_25 <> 0
            REPLACE AVG_25 WITH ROUND(C->DAYS_25/C->SHIPS_25,2)
         ENDIF
         IF C->SHIPS_180 <> 0 .OR. C->DAYS_180 <> 0
            REPLACE AVG_180 WITH ROUND(C->DAYS_180/C->SHIPS_180,2)
         ENDIF
         REPLACE PAY_AMT WITH C->CRED_LIM
         REPLACE PAY_POST WITH PAY_POST + A->TOT_SELL + A->CUS_AMT1 + A->CUS_AMT2 + A->CUS_PALL
         REPLACE CRED_BAL WITH CRED_BAL + A->TOT_LBS
         SELECT A
         SKIP
      ENDDO
      
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      SELECT D
      GOTO TOP
      
      DO WHILE .NOT. EOF() 
         STORE SALESMAN TO MSALESMAN
         SELECT A
         SEEK MSALESMAN
         MNAME = NAME     
         SELECT D
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  EJECT
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 1,38 SAY MCOMPANY
               @ 2,0 SAY 'PAGE'
               @ 2,05 say mpage_no picture '99'
               @ 2,21 SAY 'SALESPERSON CUSTOMER REPORT ' + DTOC(MBEGIN) + ' THRU ' + DTOC(MDATE)
               @ 2,79 SAY DTOC(DATE())
               @ 3,38 SAY 'SALESPERSON: ' + MNAME
               @ 5,1 SAY 'CUSTOMER'
               @ 5,42 SAY 'CREDIT'
               @ 5,53 SAY 'AVG PAY'
               @ 5,63 SAY 'AVG PAY'
               @ 5,78 SAY 'TOTAL'
               @ 5,92 SAY 'TOTAL'
               
               @ 6,43 SAY 'LIMIT'
               @ 6,53 SAY '25 DAYS'
               @ 6,62 SAY '180 DAYS'
               @ 6,74 SAY 'SELLING $'
               @ 6,91 SAY 'POUNDS'
               MLINE = 8
            ENDIF
            @ MLINE,1 SAY BBUYNAME 
            @ MLINE,37 SAY PAY_AMT PICTURE '999,999,999'
            @ MLINE,53 SAY AVG_25 PICTURE '999.99'
            @ MLINE,63 SAY AVG_180 PICTURE '999.99'
            @ MLINE,72 SAY PAY_POST PICTURE '999,999,999'   
            @ MLINE,86 SAY CRED_BAL PICTURE '999,999,999'
            MLINE = MLINE + 1
            @ MLINE,4 SAY ADDRESS
            MLINE = MLINE + 1
            @ MLINE,4 SAY TRIM(CITY) + ', ' + STATE + '  ' + ZIP
            MLINE = MLINE + 1
            @ MLINE,4 SAY PHONE PICTURE '@R 999-999-9999'
            MLINE = MLINE + 2
            SKIP
         ENDDO
         IF MLINE <> 99
            @ MLINE+1,1 SAY ' '
         ENDIF
         MLINE = 88
      ENDDO
      EJECT
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      
   CASE VAL(MSELECTION) = 7    
      MTITLE = ' - CUSTOMER CREDIT CHECK REPORT'
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @  2,0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      MDATE = DATE() - 356 
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 10,5 SAY 'CREDIT CUTOFF DATE: ' 
         @ 10,26 GET MDATE
         @ 13,5 SAY '(Note: Any customer whose last sales activity was prior )'
         @ 14,5 SAY '(      to this date will not be included.)'
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
      ENDDO
      
      IF MACTION = 3                            
         LOOP   
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
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX TMP_BUY", .F.
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
      MLINE = 99
      MPAGE_NO = 0
      MFIRST_TM = .T.
      DO WHILE .NOT. EOF()
         IF BBUYCODE = 'NONE' .OR. BBUYCODE = 'INVN' .OR. BBUYCODE = 'REJE'
            SKIP
            LOOP
         ENDIF
         SELECT B
         SEEK A->BBUYCODE
         IF EOF()
            SELECT A
            SKIP
            LOOP
         ENDIF
         DO WHILE SHIP_DATE = CTOD('')  
            SKIP
         ENDDO
         
         IF SHIP_DATE < MDATE
            SELECT A
            SKIP
            LOOP
         ELSE
            MSHIP_DATE = SHIP_DATE
         ENDIF
         
         SELECT A
         IF MLINE+6 > 60
            IF MFIRST_TM
               MFIRST_TM = .F.
            ELSE
               EJECT
            ENDIF
            MLINE = 2
            MPAGE_NO = MPAGE_NO + 1
            @ MLINE,1 SAY 'PAGE  ' + str(mpage_no,3)
            @ mline,36 say 'CUSTOMER CREDIT CHECK LISTING'
            @ MLINE,85 SAY DTOC(DATE())
            MLINE = MLINE + 2
            @ MLINE,1 SAY '                                 CREDIT  LETTER   BEGIN      END       LAST    FIN STMT   REVIEW'
            MLINE = MLINE + 1
            @ MLINE,1 SAY 'NAME / ADDRESS                    LIMIT  CREDIT    DATE      DATE      SALE      DATE      DATE'
            MLINE = MLINE + 2
         ENDIF
         @ MLINE,1 SAY NAME
         @ MLINE,33 SAY CRED_LIM PICTURE '9999999'
         IF LET_CRD <> 0
            @ MLINE,41 SAY LET_CRD PICTURE '9999999'
            SET CENTURY OFF
            @ MLINE,50 SAY BEG_DATE
            @ MLINE,60 SAY END_DATE
            SET CENTURY ON
         ENDIF
         SET CENTURY OFF
         @ MLINE,70 SAY MSHIP_DATE 
         @ MLINE,80 SAY DATE_FIN
         @ MLINE,90 SAY DATE_RVWD          
         SET CENTURY ON
         MLINE = MLINE + 1
         IF STREET <> SPACE(28)
            @ MLINE,1 SAY STREET
            MLINE = MLINE + 1
         ENDIF
         IF ZIP4 = SPACE(4)
            STORE ZIP TO MZIP
         ELSE
            STORE ZIP + '-' + ZIP4 TO MZIP
         ENDIF
         IF CITY <> '   ' .AND. STATE <> '  '
            @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE + '  ' + MZIP
         ENDIF
         MLINE = MLINE + 1
         IF AREA_CODE <> SPACE(3) .AND. PHONE <> SPACE(7)
            @ MLINE,1 SAY '(' + AREA_CODE + ')' + TRANSFORM(PHONE, '@R 999-9999')
            MLINE = MLINE + 1
         ENDIF
         IF SHIPS_180 <> 0 .AND. DAYS_180 <> 0
            MAVG_180 = DAYS_180/SHIPS_180
         ELSE
            MAVG_180 = 0
         ENDIF
         @ MLINE,1 SAY 'LAST 6 MO. AVG PAY DAYS: '
         @ MLINE,26 SAY MAVG_180 PICTURE '999.99'
         MLINE = MLINE + 1
         IF ACTIVE <> ' '
            @ MLINE,01 SAY '* INACTIVE CUSTOMER *'
            MLINE = MLINE + 1
         ENDIF
         IF NOTE <> SPACE(60)
            @ MLINE,1 SAY '* NOTE: *'
            @ MLINE,11 SAY NOTE
            MLINE = MLINE + 1
         ENDIF
         IF NOTE2 <> SPACE(60)
            @ MLINE,1 SAY '* NOTE: *'
            @ MLINE,11 SAY NOTE2
            MLINE = MLINE + 1
         ENDIF
         
         MLINE = MLINE + 2
         SKIP
      ENDDO
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
      
      
   CASE VAL(MSELECTION) =  8    
      MTITLE = ' - OUTSTANDING CUSTOMER CREDITS REPORT'    
      
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE CTOD(' ') TO MDATE, MBEGIN
      STORE 'N' TO MYES_NO             
      STORE '**' TO MOPT_SALES
      STORE SPACE(4) TO MOPT_CUST
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 06,5 SAY '  ENTER BEGINNING REPORT DATE: '
         @ 06,37 GET MBEGIN
         @ 08,5 SAY '     ENTER ENDING REPORT DATE: '
         @ 08,37 GET MDATE
         @ 10,4 SAY 'SELECT SPECIFIC CUSTOMER (Y/N):'
         @ 10,37 GET MYES_NO PICTURE '@!'
         @ 12,4 SAY '     OPTIONAL SALESPERSON CODE:'       
         @ 12,37 GET MOPT_SALES PICTURE '##'
         @ 13,2 SAY "(ENTER '**' FOR ALL SALESPERSONS)"
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF DTOC(MDATE) = '  /  /  ' .OR. DTOC(MBEGIN) = '  /  /  '
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'NO DATE ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
               READ
               MACTION = 2
               @ 24,0 CLEAR
               LOOP 
            ELSE
               IF MDATE < MBEGIN
                  @ 24,0 CLEAR
                  mwait = ' '
                  @ 24,1 SAY 'ENDING DATE BEFORE BEGINNING - PRESS ANY KEY TO REENTER' GET MWAIT
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
      IF MYES_NO = 'Y'
         SAVE SCREEN TO MSCREEN
         MNAME_FD = .F.
         DO BBUYSEL3
         IF MNAME_FD
            STORE BBUYCODE TO MOPT_CUST
         ENDIF
         use
         RESTORE SCREEN FROM MSCREEN
      ENDIF
      MPRT_ACT = 'C'
      
      DO PRT_SET
      
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      MPAGE_LEN = 56
      
      MPAGE_NO = 0
      MLINE = 99 
      @ 19,16 SAY 'CALCULATING & PRINTING.....PLEASE WAIT...'
      SELECT D
      DO FOX_USE WITH "CUS_TMP INDEX CUS_TMP", .F.
      DO FILELOCK
      USE CUS_TMP EXCLUSIVE
      DELETE ALL
      PACK
      INDEX ON SALESMAN + BBUYNAME + INV_NBR TO CUS_TMP
      USE CUS_TMP INDEX CUS_TMP EXCLUSIVE
      
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
      
      SELECT F
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      SELECT E
      DO FOX_USE WITH "INV_ADJ INDEX INV_ADJ", .F.
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      SELECT B
      DO FOX_USE WITH "PAYMENTS INDEX PAY_PO", .F.
      SELECT A
      DO FOX_USE WITH "CUS_INV INDEX CUS_DATE", .F.
      SEEK ' '
      
      DO WHILE .NOT. EOF() .AND. PAID_FLG = ' '
         IF MOPT_CUST <> SPACE(4)
            IF BBUYCODE = 'CRED'
               IF ORIG_BBUY <> MOPT_CUST
                  SKIP
                  LOOP
               ENDIF
            ELSE
               IF BBUYCODE <> MOPT_CUST
                  SKIP
                  LOOP
               ENDIF
            ENDIF
         ENDIF
         
         IF MOPT_SALES <> '**'  
            IF SALESMAN <> MOPT_SALES
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         IF INV_DATE < MBEGIN .OR. INV_DATE > MDATE 
            SKIP
            LOOP
         ENDIF
         
         *** IF SUBSTR(INV_NBR,1,1) = 'A' .OR. DEB_CRD <> ' ' .OR. CRED_PAY <> ' '
         MAMT = (TOT_SELL + CUS_PALL) - AMT_PAID
         MAMT_PAID = AMT_PAID
         MTOT_SELL = TOT_SELL + CUS_PALL
         **********************************************
         **** DONT COUNT THOSE CREDITS LESS THAN $ 1.00
         **********************************************
         IF MAMT < -1
            *** WRITE RECORD OUT TO TEMPORARY FILE
            SELECT C
            IF A->BBUYCODE = 'CRED'
               SEEK A->ORIG_BBUY
            ELSE
               SEEK A->BBUYCODE
            ENDIF
            IF EOF()
               STORE 'CUSTOMER NOT ON FILE' TO MBBUYNAME
            ELSE
               STORE NAME TO MBBUYNAME
            ENDIF
            SELECT D
            APPEND BLANK
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE BBUYNAME WITH MBBUYNAME
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE TOT_SELL WITH MTOT_SELL
            REPLACE AMT_PAID WITH MAMT_PAID
            REPLACE INV_DATE WITH A->INV_DATE
            IF A->BBUYCODE = 'CRED'
               REPLACE CRED_BAL WITH MAMT
            ELSE
               IF MTOT_SELL >= -1000 
                  REPLACE MISC_CRD WITH MAMT
               ELSE
                  REPLACE RECV_CRD WITH MAMT
               ENDIF
            ENDIF
            IF A->CRED_REAS <> ' '
               SELECT F
               SEEK 'M' + A->CRED_REAS
               SELECT D
               REPLACE CRED_DESC WITH F->DESC
            ENDIF
         ENDIF
         SELECT A
         SKIP
      ENDDO
      
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      SELECT D
      GOTO TOP
      STORE 0 TO MGRND_MISC, MGRND_RECV, MGRND_BAL, MGRND_MIS1
      DO WHILE .NOT. EOF() 
         STORE SALESMAN TO MSALESMAN
         STORE 0 TO MSAL_MISC, MSAL_RECV, MSAL_BAL, MSAL_MISC1
         
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
            STORE BBUYNAME TO MNAME     
            MPRT_NAME = .T.
            STORE 0 TO MMISC_TOT, MREC_CRD, MCRED_BAL, MMISC_TOT1
            DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. BBUYNAME = MNAME     
               IF SALESMAN = '66'
                  MTOP_LIM = -1000
               ELSE
                  MTOP_LIM = -1000
               ENDIF
               
               IF MISC_CRD >= MTOP_LIM
                  MMISC_TOT = MMISC_TOT + MISC_CRD
               ELSE
                  MMISC_TOT1 = MMISC_TOT1 + MISC_CRD
               ENDIF
               
               MREC_CRD  = MREC_CRD  + RECV_CRD
               IF CRED_BAL >= MTOP_LIM
                  MMISC_TOT = MMISC_TOT + CRED_BAL
               ELSE
                  MMISC_TOT1 = MMISC_TOT1 + CRED_BAL
               ENDIF
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 1,34 SAY MCOMPANY
                  @ 2,0 SAY 'PAGE'
                  @ 2,05 say mpage_no picture '99'
                  @ 2,17 SAY 'CUSTOMER CREDIT REPORT ' + DTOC(MBEGIN) + ' THRU ' + DTOC(MDATE)
                  @ 2,70 SAY DTOC(DATE())
                  @ 4,30 SAY '     REMAINING'
                  @ 4,48 SAY '  ORIGINAL'     
                  @ 4,63 SAY '      CREDIT AMT'
                  @ 5,1 SAY 'PO NUMBER' 
                  @ 5,12 SAY 'INV NBR'  
                  @ 5,23 SAY 'DATE'
                  @ 5,30 SAY '    CREDIT AMT'
                  @ 5,48 SAY ' CREDIT AMT'
                  @ 5,63 SAY '         APPLIED'
                  @ 5,0 SAY REPLICATE ('_',80)
                  MLINE = 7
                  MPRT_NAME = .T.
               ENDIF
               IF MPRT_NAME
                  @ MLINE,1 SAY MNAME
                  MLEN = LEN(TRIM(MNAME))
                  @ MLINE,1 SAY REPLICATE('_',MLEN)
                  MPRT_NAME = .F.
                  MLINE = MLINE + 1
               ENDIF
               IF SALESMAN <> SPACE(2)
                  @ MLINE,1 SAY SALESMAN
                  @ MLINE,3 SAY '-'
               ENDIF
               @ MLINE,4 SAY PO_NBR
               IF PO_SUFFIX <> ' '
                  @ MLINE,8 SAY '-'
                  @ MLINE,9 SAY PO_SUFFIX
               ENDIF
               @ MLINE,13 SAY INV_NBR   
               
               @ MLINE,21 SAY INV_DATE
               DO CASE
               CASE MISC_CRD <> 0     
                  @ MLINE,32 SAY TRANSFORM(MISC_CRD, '9,999,999.99')
               CASE RECV_CRD <> 0
                  @ MLINE,32 SAY TRANSFORM(RECV_CRD, '9,999,999.99')
               OTHERWISE
                  @ MLINE,32 SAY TRANSFORM(CRED_BAL, '9,999,999.99')
               ENDCASE
               @ MLINE,47 SAY TRANSFORM(TOT_SELL, '9,999,999.99')
               @ MLINE,66 SAY TRANSFORM(AMT_PAID, '9,999,999.99')
               @ MLINE,80 SAY TRIM(CRED_DESC)
               MLINE = MLINE + 1
               SKIP
            ENDDO
            MLINE = MLINE + 1
            IF MREC_CRD <> 0
               @ MLINE,5 SAY 'Credits Over $1000:'
               @ mline,32 SAY TRANSFORM(MREC_CRD, '9,999,999.99')
               MLINE = MLINE + 1
            ENDIF
            
            MTOP_LIM = STR(MTOP_LIM* -1,3)
            
            IF MMISC_TOT1 <> 0
               @ MLINE,5 SAY 'Credits GT $ ' + MTOP_LIM + ' and LT $ 1000'
               @ mline,32 SAY TRANSFORM(MMISC_TOT1, '9,999,999.99')
               MLINE = MLINE + 1
            ENDIF
            IF MMISC_TOT <> 0
               @ MLINE,5 SAY 'Credits GT $ 5 and LT $ ' + MTOP_LIM
               @ mline,32 SAY TRANSFORM(MMISC_TOT, '9,999,999.99')
               MLINE = MLINE + 1
            ENDIF
            
            IF MREC_CRD <> 0 .OR. MMISC_TOT <> 0 .OR. MMISC_TOT1 <> 0
               MLINE = MLINE + 1 
               @ MLINE,5 SAY 'Total Credits:'
               @ mline,32 say TRANSFORM(MREC_CRD+MMISC_TOT+MMISC_TOT1, '9,999,999.99')
               MLINE = MLINE + 2
            ELSE
               MLINE = MLINE + 1
            ENDIF
            MSAL_MISC = MSAL_MISC + MMISC_TOT
            MSAL_RECV = MSAL_RECV + MREC_CRD
            MSAL_MISC1 = MSAL_MISC1  + MMISC_TOT1
         ENDDO
         
         IF MSAL_MISC <> 0 .OR. MSAL_RECV <> 0 .OR. MSAL_MISC1 <> 0
            EJECT
            MPAGE_NO = MPAGE_NO + 1
            @ 1,34 SAY MCOMPANY
            @ 2,0 SAY 'PAGE'
            @ 2,05 say mpage_no picture '99'
            @ 2,17 SAY 'CUSTOMER CREDIT REPORT ' + DTOC(MBEGIN) + ' THRU ' + DTOC(MDATE)
            @ 2,70 SAY DTOC(DATE())
            @ 4,30 SAY '     REMAINING'
            @ 4,48 SAY '  ORIGINAL'     
            @ 4,63 SAY '      CREDIT AMT'
            @ 5,1 SAY 'PO NUMBER' 
            @ 5,12 SAY 'INV NBR'  
            @ 5,23 SAY 'DATE'
            @ 5,30 SAY '    CREDIT AMT'
            @ 5,48 SAY ' CREDIT AMT'
            @ 5,63 SAY '         APPLIED'
            @ 5,0 SAY REPLICATE ('_',80)
            MLINE = 8
            @ MLINE,1 SAY 'Total Credits for Salesperson: ' + msalesman
            mline = mline + 2
            IF MSAL_RECV <> 0
               @ MLINE,5 SAY 'Credits Over $1000:'
               @ mline,32 SAY TRANSFORM(MSAL_RECV, '9,999,999.99')
               MLINE = MLINE + 2
            ENDIF
            
            IF MSAL_MISC1 <> 0
               @ MLINE,5 SAY 'Credits GT $ ' + MTOP_LIM + ' and LT $ 1000'
               @ mline,32 SAY TRANSFORM(MSAL_MISC1, '9,999,999.99')
               MLINE = MLINE + 1
            ENDIF
            IF MSAL_MISC <> 0
               @ MLINE,5 SAY 'Credits GT $ 5 and LT $ ' + MTOP_LIM
               @ mline,32 SAY TRANSFORM(MSAL_MISC, '9,999,999.99')
               MLINE = MLINE + 1
            ENDIF
            
            IF MSAL_RECV <> 0 .OR. MSAL_MISC <> 0 .OR. MSAL_MISC1 <> 0
               @ MLINE,5 SAY 'Total Credits:'
               @ mline,32 say transform(MSAL_RECV+MSAL_MISC+MSAL_MISC1, '9,999,999.99')
               MLINE = MLINE + 2
            ENDIF
            
         ENDIF
         
         MLINE = 88      
         MGRND_MISC = MGRND_MISC + MSAL_MISC
         MGRND_RECV = MGRND_RECV + MSAL_RECV
         MGRND_MIS1  = MGRND_MIS1  + MSAL_MISC1
      ENDDO
      IF MOPT_SALES = '**'  
         IF MGRND_MISC <> 0 .OR. MGRND_RECV <> 0 .OR. MGRND_MIS1 <> 0
            EJECT
            MPAGE_NO = MPAGE_NO + 1
            @ 1,34 SAY MCOMPANY
            @ 2,0 SAY 'PAGE'
            @ 2,05 say mpage_no picture '99'
            @ 2,17 SAY 'CUSTOMER CREDIT REPORT ' + DTOC(MBEGIN) + ' THRU ' + DTOC(MDATE)
            @ 2,70 SAY DTOC(DATE())
            @ 4,30 SAY '     REMAINING'
            @ 4,48 SAY '  ORIGINAL'     
            @ 4,63 SAY '      CREDIT AMT'
            @ 5,1 SAY 'PO NUMBER' 
            @ 5,12 SAY 'INV NBR'  
            @ 5,23 SAY 'DATE'
            @ 5,30 SAY '    CREDIT AMT'
            @ 5,48 SAY ' CREDIT AMT'
            @ 5,63 SAY '         APPLIED'
            @ 5,0 SAY REPLICATE ('_',80)
            MLINE = 8
            @ MLINE,5 SAY 'GRAND TOTAL ALL CREDITS'
            mline = mline + 2
            IF MGRND_RECV <> 0 .OR. MGRND_MISC <> 0 .OR. MGRND_MIS1 <> 0
               @ MLINE,5 SAY 'Total Credits:'
               @ mline,32 say transform(MGRND_RECV+MGRND_MISC+MGRND_MIS1, '9,999,999.99')
               MLINE = MLINE + 2
            ENDIF
         ENDIF
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
      
   CASE MSELECTION =  'C'    
      DO CUSTWARN
      
   CASE MSELECTION =  'S'    
      DO STMT
   ENDCASE
   
ENDDO

RETURN


PROCEDURE AGE_HEAD 
IF MLINE > MPAGE_LEN
   IF MLINE <> 99
      EJECT
   ENDIF
   MPAGE_NO = MPAGE_NO + 1
   @ 2,36 SAY MCOMPANY
   @ 3,1 SAY 'Page'
   @ 3,06 say mpage_no picture '99'
   @ 3,28 SAY 'OVERDUE ACCOUNTS REPORT AS OF ' + DTOC(MRPT_DATE)
   @ 3,88 SAY DTOC(DATE())
   IF MPRT_CUST
      @ 5,1 SAY 'CUSTOMER'
      @ 5,15 SAY 'INV AMT'
      @ 5,28 SAY 'AMT DUE'
      @ 5,40 SAY 'CUST PO #'
      @ 5,59 SAY 'PO #'
      @ 5,70 SAY 'INV DATE'
      @ 5,80 SAY 'DAYS OLD'
      *@ 5,89 SAY ' PAST 7'
      @ 5,89 SAY 'PAST '  + STR(MSEL_DAYS,2)
      @ 5,1 SAY REPLICATE('_',98)
      MLINE = 7
      @ MLINE,1 SAY MNAME
      @ MLINE,45 SAY MPHONE
      MLINE = MLINE + 1
      @ MLINE,1 SAY MADDR
      MLINE = MLINE + 2
      MPRT_CUST = .F.
   ELSE
      MLINE = 7
   ENDIF
ENDIF
RETURN

PROCEDURE AGEHEAD1
IF MLINE > MPAGE_LEN
   IF MLINE <> 99
      EJECT
   ENDIF
   MPAGE_NO = MPAGE_NO + 1
   @ 2,36 SAY MCOMPANY
   @ 3,1 SAY 'Page'
   @ 3,06 say mpage_no picture '99'
   @ 3,29 SAY 'OVERDUE ORDERS REPORT AS OF ' + DTOC(MRPT_DATE)
   @ 3,88 SAY DTOC(DATE())
   IF MPRT_CUST
      @ 5,1 SAY 'CUSTOMER'
      @ 5,15 SAY 'INV AMT'
      IF MCOL_PICK = 'B'
         @ 5,28 SAY 'AMT DUE'
      ENDIF
      @ 5,40 SAY 'CUST PO #'
      @ 5,59 SAY 'PO #'
      @ 5,70 SAY 'INV DATE'
      @ 5,80 SAY 'DAYS OLD'
      @ 5,89 SAY ' PAST 7'
      @ 5,1 SAY REPLICATE('_',98)
      MLINE = 7
      @ MLINE,1 SAY MNAME
      @ MLINE,45 SAY MPHONE
      MLINE = MLINE + 1
      @ MLINE,1 SAY MADDR
      MLINE = MLINE + 2
      MPRT_CUST = .F.
   ELSE
      MLINE = 7
   ENDIF
ENDIF
RETURN

PROCEDURE AGEHEAD2
IF MLINE > MPAGE_LEN
   IF MLINE <> 99
      EJECT
   ENDIF
   MPAGE_NO = MPAGE_NO + 1
   @ 2,36 SAY MCOMPANY
   @ 3,1 SAY 'Page'
   @ 3,06 say mpage_no picture '99'
   @ 3,27 SAY 'OUTSTANDING ORDERS REPORT AS OF ' + DTOC(MRPT_DATE)
   @ 3,88 SAY DTOC(DATE())
   IF MPRT_CUST
      @ 5,1 SAY 'CUSTOMER'
      @ 5,15 SAY 'INV AMT'
      IF MCOL_PICK = 'B'
         @ 5,28 SAY 'AMT DUE'
      ENDIF
      @ 5,40 SAY 'CONFIRM #'
      @ 5,59 SAY 'PO #'
      @ 5,70 SAY 'INV DATE'
      @ 5,80 SAY 'DAYS OLD'
      @ 5,89 SAY ' PAST 7'
      @ 5,1 SAY REPLICATE('_',98)
      MLINE = 7
      @ MLINE,1 SAY MNAME
      @ MLINE,45 SAY MPHONE
      MLINE = MLINE + 1
      @ MLINE,1 SAY MADDR
      MLINE = MLINE + 2
      MPRT_CUST = .F.
   ELSE
      MLINE = 7
   ENDIF
ENDIF
RETURN

PROCEDURE MFI_HEAD 
IF MLINE > MPAGE_LEN
   IF MLINE <> 99
      EJECT
   ENDIF
   MPAGE_NO = MPAGE_NO + 1
   @ 2,34 SAY MCOMPANY
   @ 3,1 SAY 'Page'
   @ 3,06 say mpage_no picture '99'
   @ 3,28 SAY 'OVERDUE ACCOUNTS REPORT AS OF ' + DTOC(MRPT_DATE)
   @ 3,88 SAY DTOC(DATE())
   @ 5,1 SAY 'CUSTOMER'
   @ 5,15 SAY 'INV AMT'
   @ 5,28 SAY 'AMT DUE'
   @ 5,40 SAY 'CUST PO #'
   @ 5,59 SAY 'PO #'
   @ 5,70 SAY 'INV DATE'
   @ 5,80 SAY 'DAYS OLD'
   @ 5,89 SAY ' PAST 7'
   @ 5,1 SAY REPLICATE('_',98)
   MLINE = 7
   @ MLINE,1 SAY MNAME
   @ MLINE,45 SAY MPHONE
   MLINE = MLINE + 1
   @ MLINE,1 SAY MADDR
   MLINE = MLINE + 2
   MPRT_CUST = .F.
ENDIF
RETURN


* EOF: PAYRPTS.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 1:33 PM.
