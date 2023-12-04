***************
* Program.: DISBRPT.PRG
* Author..: GRACE KELLER
* Date....: 12/09/87
* Notice..: Copyright (C) 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: DISBURSEMENT REPORT MENU    
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
STORE ' ' TO MSELECTION
STORE ' ' TO MACTION

DO WHILE VAL(MSELECTION) <> 9  
   
   CLEAR
   @ 01,00 SAY MCOMPANY
   @ 02,00 SAY MPROGRAM + ' - DISBURSEMENT REPORTS MENU'
   @ 02,70 SAY DATE()
   @ 3,0 to 24,79
   
   @ 05,05 SAY ' 1 - CHECK REGISTER'
   @ 07,05 SAY ' 2 - DISBURSEMENT REGISTER'
   @ 09,05 say ' 3 - DATE-TO-DATE DISBURSEMENT TOTALS FOR ALL ACCOUNTS'
   @ 11,05 SAY ' 4 - DATE-TO-DATE DISBURSEMENTS/RESERVE ACTIVITY FOR ONE SELECTED ACCOUNT'
   @ 13,05 say ' 5 - DATE-TO-DATE DISBURSEMENT TOTALS FOR ACCOUNTS (BY SALESPERSON)'
   @ 15,05 SAY ' 6 - PRINT LIST OF OLD SUPPLIER INVOICES NOT MATCHED/PAID'
   @ 17,05 SAY ' 7 - PRINT MONTHLY NET SUMMARY FOR CUSTOMER/COMMISSION DISBURSE'
   @ 19,05 SAY ' 9 - RETURN TO REPORTS MENU'
   
   STORE ' ' TO MSELECTION
   @ 21,02 SAY 'CHOICE: '
   @ 21,10 GET MSELECTION picture '#'
   READ
   
   DO CASE
      
   CASE VAL(MSELECTION) = 1     
      MTITLE = ' - CHECK REGISTER'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE DATE() TO MCK_DATE, MEND_DATE
      STORE 'P' TO MDISP_PRT
      STORE 1 TO MNBR_RPTS
      STORE 'REGULAR' TO MFORMAT
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 05,5 SAY '        Beginning Report Date: '
         @ 05,37 GET MCK_DATE 
         @ 07,5 SAY '           Ending Report Date: '
         @ 07,37 GET MEND_DATE
         @ 09,5 SAY '       Selected Report Format: '
         @ 09,37 GET MFORMAT PICTURE '@!'
         @ 10,5 SAY "(Format Options: 'REGULAR' or 'TOTALS' by day)"
         @ 12,5 SAY 'Display or Print Report (D/P):'
         @ 12,37 GET MDISP_PRT PICTURE '@!'
         @ 14,5 SAY '   Number of Reports to Print:'
         @ 14,37 GET MNBR_RPTS PICTURE '#'
         
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF DTOC(MCK_DATE) = '  /  /  ' .OR. DTOC(MEND_DATE) = '  /  /  '
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'DATES ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
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
      
      IF MDISP_PRT = 'P'
         DO PRT_SET
         
         IF MPRT_ACT <> 'C'
            LOOP  
         ENDIF
         MPAGE_LEN = 56
      ELSE
         MNBR_RPTS = 1
         MPAGE_LEN = 20
      ENDIF
      
      SELECT B
      DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
      
      SELECT A
      DO FOX_USE WITH "CK_REG INDEX CK_DATE", .F.
      STORE DTOC(MCK_DATE) TO MDATE
      STORE SUBSTR(MDATE,1,2) TO MMONTH
      STORE SUBSTR(MDATE,4,2) TO MDAY
      STORE SUBSTR(MDATE,7) TO MYEAR
      MNO_DATE = .F.
      SEEK MYEAR + MMONTH + MDAY
      IF EOF()
         IF MCK_DATE = MEND_DATE
            MNO_DATE = .T.
         ELSE
            SEEK MYEAR + MMONTH
            IF EOF()
               MNO_DATE = .T.
            ELSE 
               DO WHILE .NOT. EOF() .AND. CK_DATE < MCK_DATE
                  SKIP
               ENDDO
               IF EOF()
                  MNO_DATE = .T.
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      
      IF MNO_DATE
         @ 4,1 CLEAR TO 21,78
         @ 10,5 SAY 'THERE IS NO CHECK DATA ON FILE FOR THIS DATE'
         STORE ' ' TO MWAIT
         @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
         READ
         LOOP  
      ENDIF
      
      STORE RECNO() TO MSTART_REC
      MNBR_TIMES = 1
      DO WHILE MNBR_TIMES <= MNBR_RPTS
         SELECT A
         GOTO MSTART_REC
         MNBR_TIMES = MNBR_TIMES + 1
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
            
            *** PRINT IN 12 CPI
            ?? chr(27) + '&k4S'
            
            *** LETTER GOTHIC AND BOLDED PRINT
            ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
            
            *** LETTER SIZE PAPER
            ?? CHR(27) + '&l2A'
            
            *** PORTRAIT MODE
            ?? CHR(27) + '&l0O'
            
         ENDIF
         
         MDAILY_TOT = 0
         DO CASE
         CASE MFORMAT = 'REGULAR'
            DO WHILE .NOT. EOF() .AND. CK_DATE <= MEND_DATE
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     IF MDISP_PRT = 'P'
                        EJECT
                     ELSE
                        STORE 'C' TO MPRT_SEL
                        @ 24,0 SAY "PRESS 'C' TO CONTINUE OR 'S' TO STOP REPORT DISPLAY: "     ;
                           GET MPRT_SEL PICTURE '@! A'
                        READ
                        IF MPRT_SEL = 'S'
                           SELECT A
                           GOTO BOTTOM
                           SKIP
                           LOOP
                        ENDIF
                        CLEAR
                     ENDIF
                  ENDIF
                  IF MLINE = 99 .AND. MDISP_PRT <> 'P'
                     CLEAR
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  
                  @ 1,34 SAY MCOMPANY
                  @ 2,0 SAY 'PAGE'
                  @ 2,05 say mpage_no picture '99'
                  IF MCK_DATE = MEND_DATE
                     @ 2,22 SAY 'DAILY CHECK REGISTER FOR ' + DTOC(MCK_DATE)
                  ELSE
                     @ 2,20 SAY 'CHECK REGISTER FOR ' + DTOC(MCK_DATE) + ' THRU ' + DTOC(MEND_DATE)
                  ENDIF
                  @ 2,70 SAY DTOC(DATE())
                  @ 4,2 SAY 'CHECK NBR         REMIT TO                                       AMOUNT'
                  IF MDISP_PRT = 'P'
                     @ 5,0 SAY REPLICATE ('_',80)
                  ELSE
                     @ 6,0 SAY REPLICATE ('-',80)
                  ENDIF
                  MLINE = 7
               ENDIF
               @ MLINE,3 SAY CK_NBR
               IF VOID_MAN = 'M'
                  @ MLINE,11 SAY '*MANUAL*'
               ENDIF
               IF VOID_MAN = 'V'
                  @ MLINE,11 SAY '*VOID*'
               ENDIF
               DO CASE
               CASE PAY_TYPE = 'S'
                  SELECT B
                  SEEK A->PAY_CODE
                  IF EOF()
                     STORE 'REMIT TO NOT ON FILE' TO MNAME
                  ELSE
                     STORE NAME TO MNAME
                  ENDIF
                  @ MLINE,20 SAY MNAME
                  SELECT A
               CASE PAY_TYPE = 'F'
                  SELECT C 
                  SEEK A->PAY_CODE
                  IF EOF()
                     STORE 'REMIT TO NOT ON FILE' TO MNAME
                  ELSE
                     STORE NAME TO MNAME
                  ENDIF
                  @ MLINE,20 SAY MNAME
                  SELECT A
               CASE PAY_TYPE = 'O' .OR. PAY_TYPE = 'P'
                  @ MLINE,20 SAY PAY_NAME
               ENDCASE
               @ MLINE,61 SAY AMOUNT PICTURE '9,999,999.99'
               IF VOID_MAN <> 'V'
                  MDAILY_TOT = MDAILY_TOT + AMOUNT
               ENDIF
               MLINE = MLINE + 2
               SKIP
            ENDDO   
            
            MLINE = MLINE + 1
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  IF MDISP_PRT = 'P'
                     EJECT
                  ELSE
                     STORE 'C' TO MPRT_SEL
                     @ 24,0 SAY "PRESS 'C' TO CONTINUE OR 'S' TO STOP REPORT DISPLAY: "     ;
                        GET MPRT_SEL PICTURE '@! A'
                     READ
                     IF MPRT_SEL = 'S'
                        RETURN   
                     ENDIF
                     CLEAR
                  ENDIF
               ENDIF
               IF MLINE = 99 .AND. MDISP_PRT <> 'P'
                  CLEAR
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               
               @ 1,34 SAY MCOMPANY
               @ 2,0 SAY 'PAGE'
               @ 2,05 say mpage_no picture '99'
               IF MCK_DATE = MEND_DATE
                  @ 2,22 SAY 'DAILY CHECK REGISTER FOR ' + DTOC(MCK_DATE)
               ELSE
                  @ 2,20 SAY 'CHECK REGISTER FOR ' + DTOC(MCK_DATE) + ' THRU ' + DTOC(MEND_DATE)
               ENDIF
               @ 2,70 SAY DTOC(DATE())
               @ 4,2 SAY 'CHECK NBR         REMIT TO                                       AMOUNT'
               IF MDISP_PRT = 'P'
                  @ 5,0 SAY REPLICATE ('_',80)
               ELSE
                  @ 6,0 SAY REPLICATE ('-',80)
               ENDIF
               MLINE = 7
            ENDIF
            
            @ MLINE,17 SAY 'TOTAL CHECKS:'
            @ MLINE,60 SAY MDAILY_TOT PICTURE '99,999,999.99'
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
            
         OTHERWISE
            MTOTAL = 0
            DO WHILE .NOT. EOF() .AND. CK_DATE <= MEND_DATE
               MCK_DATE = CK_DATE
               MDAILY_TOT = 0
               DO WHILE .NOT. EOF() .AND. CK_DATE <= MEND_DATE .AND. MCK_DATE = CK_DATE 
                  IF VOID_MAN = 'V'
                     SKIP
                     LOOP
                  ENDIF
                  MDAILY_TOT = MDAILY_TOT + AMOUNT
                  SKIP
               ENDDO
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     IF MDISP_PRT = 'P'
                        EJECT
                     ELSE
                        STORE 'C' TO MPRT_SEL
                        @ 24,0 SAY "PRESS 'C' TO CONTINUE OR 'S' TO STOP REPORT DISPLAY: "     ;
                           GET MPRT_SEL PICTURE '@! A'
                        READ
                        IF MPRT_SEL = 'S'
                           SELECT A
                           GOTO BOTTOM
                           SKIP
                           LOOP
                        ENDIF
                        CLEAR
                     ENDIF
                  ENDIF
                  IF MLINE = 99 .AND. MDISP_PRT <> 'P'
                     CLEAR
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  
                  @ 1,34 SAY MCOMPANY
                  @ 2,0 SAY 'PAGE'
                  @ 2,05 say mpage_no picture '99'
                  IF MCK_DATE = MEND_DATE
                     @ 2,22 SAY 'DAILY CHECK REGISTER FOR ' + DTOC(MCK_DATE)
                  ELSE
                     @ 2,20 SAY 'CHECK REGISTER FOR ' + DTOC(MCK_DATE) + ' THRU ' + DTOC(MEND_DATE)
                  ENDIF
                  @ 2,70 SAY DTOC(DATE())
                  @ 4,2 SAY 'CHECK DATE             DAILY TOTAL'
                  IF MDISP_PRT = 'P'
                     @ 5,0 SAY REPLICATE ('_',40)
                  ELSE
                     @ 6,0 SAY REPLICATE ('-',80)
                  ENDIF
                  MLINE = 7
               ENDIF
               @ MLINE,4 SAY MCK_DATE
               @ MLINE,22 SAY MDAILY_TOT PICTURE '999,999,999.99'
               MLINE = MLINE + 2
               MTOTAL = MTOTAL + MDAILY_TOT
            ENDDO
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  IF MDISP_PRT = 'P'
                     EJECT
                  ELSE
                     STORE 'C' TO MPRT_SEL
                     @ 24,0 SAY "PRESS 'C' TO CONTINUE OR 'S' TO STOP REPORT DISPLAY: "     ;
                        GET MPRT_SEL PICTURE '@! A'
                     READ
                     IF MPRT_SEL = 'S'
                        SELECT A
                        GOTO BOTTOM
                        SKIP
                        LOOP
                     ENDIF
                     CLEAR
                  ENDIF
               ENDIF
               IF MLINE = 99 .AND. MDISP_PRT <> 'P'
                  CLEAR
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               
               @ 1,34 SAY MCOMPANY
               @ 2,0 SAY 'PAGE'
               @ 2,05 say mpage_no picture '99'
               IF MCK_DATE = MEND_DATE
                  @ 2,22 SAY 'DAILY CHECK REGISTER FOR ' + DTOC(MCK_DATE)
               ELSE
                  @ 2,20 SAY 'CHECK REGISTER FOR ' + DTOC(MCK_DATE) + ' THRU ' + DTOC(MEND_DATE)
               ENDIF
               @ 2,70 SAY DTOC(DATE())
               @ 4,2 SAY 'CHECK DATE             DAILY TOTAL'
               IF MDISP_PRT = 'P'
                  @ 5,0 SAY REPLICATE ('_',40)
               ELSE
                  @ 6,0 SAY REPLICATE ('-',80)
               ENDIF
               MLINE = 7
            ENDIF
            @ MLINE,2 SAY 'TOTAL CHECKS:'
            @ MLINE,22 SAY MTOTAL PICTURE '999,999,999.99'
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
         ENDCASE
      ENDDO
      CLOSE DATA
      * EOF: CK_REG.PRG
      
   CASE VAL(MSELECTION) = 2     
      * Notes...: DATE-TO-DATE DISBURSEMENT REGISTER     
      *
      MTITLE = ' - DISBURSEMENT REGISTER'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      
      **** GET DATE FOR THIS REPORT
      STORE CTOD(' ') TO MDATE, MEND_DATE
      STORE 'P' TO MDISP_PRT
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 08,5 SAY 'BEGIN REPORT DATE: '
         @ 08,32 GET MDATE
         @ 10,5 SAY '  END REPORT DATE: ' 
         @ 10,32 GET MEND_DATE
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF DTOC(MDATE) = '  /  /  ' .OR. DTOC(MEND_DATE) = '  /  /  '
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'BEGIN OR END DATE NOT ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
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
         MPAGE_LEN = 42
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
      
      STORE MONTH(MEND_DATE) TO MEMONTH
      MEMONTH = MEMONTH + 100
      STORE SUBSTR(STR(MEMONTH,3),2) TO MEMONTH
      
      STORE YEAR(MEND_DATE) TO MEYEAR
      STORE STR(MEYEAR,4) TO MEYEAR
      
      STORE DAY(MEND_DATE) TO MEDAY
      MEDAY = MEDAY + 100
      STORE SUBSTR(STR(MEDAY,3),2) TO MEDAY
      
      SELECT B
      DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
      SELECT D
      DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
      
      SELECT A
      DO FOX_USE WITH "DISBJRN INDEX DISBJRN", .F.
      SEEK MYEAR + MMONTH + MDAY  
      IF EOF()
         SEEK MYEAR+MMONTH
         IF EOF()
            @ 4,1 CLEAR TO 21,78 
            @ 10,5 SAY 'THERE IS NO DISBURSEMENT DATA ON FILE FOR THIS MONTH/YEAR'
            STORE ' ' TO MWAIT
            @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
            READ
            LOOP  
         ELSE         
            DO WHILE .NOT. EOF() .AND. CTOD(JRNL_MO+'/'+JRNL_DAY+'/'+JRNL_YR) < MDATE
               SKIP
            ENDDO
         ENDIF
      ENDIF
      MPAGE_NO = 0
      MLINE = 99 
      
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
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      MDAILY_TOT = 0
      DO WHILE .NOT. EOF() .AND. CTOD(JRNL_MO+'/'+JRNL_DAY+'/'+JRNL_YR) <= MEND_DATE
         
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               IF MDISP_PRT = 'P'
                  EJECT
               ENDIF
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,49 SAY MCOMPANY
            @ 2,1 SAY 'PAGE'
            @ 2,06 say mpage_no picture '99'
            @ 2,35 SAY 'DISBURSEMENT REGISTER FOR ' + DTOC(MDATE) + ' THRU ' + DTOC(MEND_DATE)
            @ 2,100 SAY DTOC(DATE())
            @ 4,1 SAY '    CHK DATE   CHK NBR    INV NBR      PO NBR     REMIT TO                              INVOICE NBR         AMOUNT    ACCOUNT'
            @ 4,0 SAY REPLICATE ('_',135)
            MLINE = 7
         ENDIF
         IF VOID_MAN <> ' '
            @ MLINE,0 SAY 'VOID'      
         ENDIF
         @ MLINE,5 SAY JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR  
         @ MLINE,16 SAY CK_NBR
         IF SALESMAN <> SPACE(2)
            @ MLINE,28 SAY SALESMAN + '-'
         ENDIF
         @ MLINE,31 SAY INV_NBR
         IF SALESMAN <> SPACE(2)
            @ MLINE,40 SAY SALESMAN + '-'
         ENDIF
         @ MLINE,43 SAY PO_NBR
         IF PO_SUFFIX <> ' '
            @ MLINE,47 SAY '-' + PO_SUFFIX
         ENDIF
         
         DO CASE
         CASE ACCT_TYPE = 'S'
            SELECT B
            SEEK A->ACCT_NBR
            IF EOF()
               STORE 'REMIT TO NOT ON FILE' TO MNAME
            ELSE
               STORE NAME TO MNAME
            ENDIF
            @ MLINE,51 SAY SUBSTR(MNAME,1,30)
            SELECT A
         CASE ACCT_TYPE = 'F'
            SELECT C 
            SEEK A->ACCT_NBR
            IF EOF()
               STORE 'REMIT TO NOT ON FILE' TO MNAME
            ELSE
               STORE NAME TO MNAME
            ENDIF
            @ MLINE,51 SAY SUBSTR(MNAME,1,30)
            SELECT A
         CASE ACCT_TYPE = 'O' .OR. ACCT_TYPE = 'P'
            IF ACCT_NAME = SPACE(25)
               @ MLINE,51 SAY 'NONE'
            ELSE
               @ MLINE,51 SAY SUBSTR(ACCT_NAME,1,30)
            ENDIF
         ENDCASE
         @ MLINE,89 SAY BILL_INV
         @ MLINE,103  SAY AMOUNT1 PICTURE '9,999,999.99'
         IF VOID_MAN <> 'V'
            MDAILY_TOT = MDAILY_TOT + AMOUNT1
         ENDIF
         SELECT D
         SEEK A->CATEGORY1
         IF .NOT. EOF()
            @ MLINE,119 SAY SUBSTR(CK_DESC,1,15)
         ELSE
            IF A->CATEGORY1 <> SPACE(4)
               @ MLINE,119 SAY 'MISCELLANEOUS'     
            ENDIF
         ENDIF
         SELECT A
         MLINE = MLINE + 2
         SKIP
      ENDDO   
      
      MLINE = MLINE + 1
      IF MLINE > MPAGE_LEN
         IF MLINE <> 99
            IF MDISP_PRT = 'P'
               EJECT
            ENDIF
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 1,49 SAY MCOMPANY
         @ 2,1 SAY 'PAGE'
         @ 2,06 say mpage_no picture '99'
         @ 2,35 SAY 'DISBURSEMENT REGISTER FOR ' + DTOC(MDATE) + ' THRU ' + DTOC(MEND_DATE)
         @ 2,100 SAY DTOC(DATE())
         @ 4,1 SAY '    CHK DATE   CHK NBR    INV NBR      PO NBR     REMIT TO                              INVOICE NBR         AMOUNT    ACCOUNT'
         @ 5,0 SAY REPLICATE ('_',135)
         MLINE = 7
      ENDIF
      
      @ MLINE,50 SAY 'TOTAL CHECKS:'
      @ MLINE,102 SAY MDAILY_TOT PICTURE '99,999,999.99'
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
   CASE VAL(MSELECTION) = 3     
      * Notes...: DATE-TO-DATE DISBURSEMENT TOTALS BY ACCOUNT
      *
      MTITLE = ' - DATE-TO-DATE DISBURSEMENT TOTALS FOR ALL ACCOUNTS'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      
      **** GET DATE FOR THIS REPORT
      STORE CTOD(' ') TO MDATE, MEND_DATE
      STORE 'P' TO MDISP_PRT
      STORE 'Y' TO MRECALC
      STORE 2 TO MACTION      
      STORE 'REG ' TO MCHOICE
      
      DO WHILE MACTION = 2
         @ 08,5 SAY 'BEGIN REPORT DATE: '
         @ 08,24 GET MDATE
         @ 10,5 SAY '  END REPORT DATE: ' 
         @ 10,24 GET MEND_DATE
         @ 12,5 SAY 'RE-CALCULATE TOTALS (Y/N): '
         @ 12,32 GET MRECALC PICTURE '@!'
         @ 14,1 SAY 'REGULAR OR ACCOUNTING (REG/ACCT): ' GET MCHOICE PICTURE '@!' VALID(MCHOICE = 'REG' .OR. MCHOICE = 'ACCT' .OR. MCHOICE = '    ')
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF DTOC(MDATE) = '  /  /  ' .OR. DTOC(MEND_DATE) = '  /  /  '
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'BEGIN OR END DATE NOT ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
               READ
               MACTION = 2
               @ 24,0 CLEAR
               LOOP 
            ENDIF
         ENDIF
      ENDDO
      
      IF MACTION = 3 .OR. MCHOICE = '    '
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
      
      STORE MONTH(MEND_DATE) TO MEMONTH
      MEMONTH = MEMONTH + 100
      STORE SUBSTR(STR(MEMONTH,3),2) TO MEMONTH
      
      STORE YEAR(MEND_DATE) TO MEYEAR
      STORE STR(MEYEAR,4) TO MEYEAR
      
      STORE DAY(MEND_DATE) TO MEDAY
      MEDAY = MEDAY + 100
      STORE SUBSTR(STR(MEDAY,3),2) TO MEDAY
      MPAGE_LEN = 56
      
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
      SELECT D
      DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
      
      SELECT A
      DO FOX_USE WITH "DISBJRN INDEX DISBJRN", .F.
      SEEK MYEAR + MMONTH + MDAY  
      IF EOF()
         SEEK MYEAR+MMONTH
         IF EOF()
            @ 4,1 CLEAR TO 21,78 
            @ 10,5 SAY 'THERE IS NO DISBURSEMENT DATA ON FILE FOR THIS MONTH/YEAR'
            STORE ' ' TO MWAIT
            @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
            READ
            LOOP  
         ELSE         
            DO WHILE .NOT. EOF() .AND. CTOD(JRNL_MO+'/'+JRNL_DAY+'/'+JRNL_YR) < MDATE
               SKIP
            ENDDO
         ENDIF
      ENDIF
      IF MRECALC = 'Y'
         SELECT B
         USE TMPACCT1 EXCLUSIVE
         DELETE ALL
         PACK
         INDEX ON CATEGORY + SALESMAN TO TMPACCT1
         USE
         DO FOX_USE WITH "TMPACCT1 INDEX TMPACCT1", .F.
      ELSE
         SELECT B
         DO FOX_USE WITH "TMPACCT1 INDEX TMPACCT1", .F.
      ENDIF
      IF MRECALC = 'Y'
         SELECT A
         DO WHILE .NOT. EOF() .AND. CTOD(JRNL_MO+'/'+JRNL_DAY+'/'+JRNL_YR) <= MEND_DATE
            IF VOID_MAN = 'V'
               SKIP
               LOOP
            ENDIF
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE AMOUNT WITH A->AMOUNT1
            IF MCHOICE = 'REG'
               IF A->CATEGORY1 = '7150' .AND. A->ACCT_NBR = 'T'
                  *** CHECK TO SEE IF COMMISSION IS A BILLBACK THIRD PARTY
                  STORE SUBSTR(A->ACCT_NBR,3) TO MACCT_NBR
                  SELECT E
                  SEEK MACCT_NBR
                  IF BILL_BACK = 'Y'
                     SELECT B
                     REPLACE CATEGORY WITH 'BB'
                  ENDIF
               ENDIF
               
               
               SELECT B
               DO CASE
               CASE A->ACCT_TYPE = 'S'
                  REPLACE CATEGORY WITH 'P'
               CASE A->ACCT_TYPE = 'F'
                  REPLACE CATEGORY WITH 'F'
               OTHERWISE
                  IF CATEGORY <> 'BB'
                     REPLACE CATEGORY WITH A->CATEGORY1
                  ENDIF
                  DO CASE
                     *** ON FURNITURE AND FIXTURES ACCOUNT AND FOOD SHOW EQUIP, I NEED MORE INFO SAVED
                  CASE CATEGORY = '1220' .OR. CATEGORY = '8222' .OR. CATEGORY = '7603'
                     REPLACE ACCT_NAME WITH A->ACCT_NAME
                     REPLACE CK_NBR WITH A->CK_NBR
                     REPLACE CK_DATE WITH CTOD(A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR)
                     *** ON PAYROLL FOR SALESPEOPLE-SPLIT OUT
                  CASE CATEGORY = '8020'
                     IF A->SALESMAN <> '  '
                        REPLACE SALESMAN WITH '**'
                     ENDIF
                  ENDCASE
               ENDCASE
            ELSE
               SELECT D
               SEEK A->CATEGORY1
               SELECT B
               REPLACE CATEGORY WITH D->ACCT_DESC
            ENDIF
            UNLOCK
            SELECT A
            SKIP
         ENDDO
      ENDIF
      MPAGE_NO = 0
      MLINE = 99 
      
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
      
      MGRAND_TOT = 0
      SELECT B
      GOTO TOP
      DO WHILE .NOT. EOF() 
         STORE CATEGORY TO MCATEGORY 
         STORE SALESMAN TO MSALESMAN
         MTOTAL = 0
         DO WHILE .NOT. EOF() .AND. CATEGORY = MCATEGORY .AND. SALESMAN = MSALESMAN
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  IF MDISP_PRT = 'P'
                     EJECT
                  ENDIF
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 1,20 SAY MCOMPANY
               @ 2,1 SAY 'PAGE'
               @ 2,06 say mpage_no picture '99'
               @ 2,15 SAY 'DISBURSEMENT TOTALS BY ACCOUNT'
               @ 2,54  SAY DTOC(DATE())
               @ 3,19 SAY DTOC(MDATE) + ' THRU ' + DTOC(MEND_DATE)
               @ 5,1 SAY 'ACCOUNT                                        TOTAL'
               *          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567891123456789012345678
               *                   10        20        30        40        50        60        70        80        90        100       110
               @ 5,0 SAY REPLICATE ('_',60)
               MLINE = 7
            ENDIF
            MTOTAL = MTOTAL + AMOUNT     
            SKIP
         ENDDO
         IF MTOTAL = 0
            LOOP
         ENDIF
         DO CASE
         CASE MCATEGORY = 'BB'
            @ MLINE,1 SAY 'COMMISSION/CONSULTING - BILL BACKS'
         CASE MCATEGORY = '8020'
            IF MSALESMAN = '  '
               @ MLINE,1 SAY 'PAYROLL - EMPLOYEES'         
            ELSE
               @ MLINE,1 SAY 'PAYROLL - SALESPERSONS'
            ENDIF
         OTHERWISE
            IF MCHOICE = 'REG'
               SELECT D
               SEEK SUBSTR(MCATEGORY,1,4)
               IF .NOT. EOF()
                  @ MLINE,1 SAY DESCRIP 
               ELSE
                  @ MLINE,1 SAY MCATEGORY + ' - NOT ON FILE'
               ENDIF
            ELSE
               @ MLINE,1 SAY MCATEGORY
            ENDIF
         ENDCASE
         
         @ MLINE,40 SAY MTOTAL PICTURE '99,999,999.99'
         MGRAND_TOT = MGRAND_TOT + MTOTAL
         MLINE = MLINE + 2
         SELECT B
      ENDDO
      
      @ MLINE,1 SAY 'TOTAL CHECKS:'
      @ MLINE,40 SAY MGRAND_TOT PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ mline+1,1 say ' '
      eject
      MPAGE_NO = 0
      MLINE = 99 
      **SEEK '1220'
      
      GOTO TOP
      MFURN = .F.
      DO WHILE .NOT. EOF() 
         IF CATEGORY <> '1220' .AND. CATEGORY <> '8222'
            SKIP
            LOOP
         ENDIF
         MFURN = .T.
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               IF MDISP_PRT = 'P'
                  EJECT
               ENDIF
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,24 SAY MCOMPANY
            @ 2,1 SAY 'PAGE'
            @ 2,06 say mpage_no picture '99'
            @ 2,10 SAY 'FURNITURE & FIXTURES/OFFICE EQUIPMENT PURCHASE REPORT'
            @ 2,70  SAY DTOC(DATE())
            @ 3,20 SAY DTOC(MDATE) + ' THRU ' + DTOC(MEND_DATE)
            @ 5,1 SAY 'PURCHASED FROM                     DATE      AMOUNT   CK NBR   DESCRIPTION'
            *          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567891123456789012345678
            *                   10        20        30        40        50        60        70        80        90        100       110
            @ 5,0 SAY REPLICATE ('_',75)
            MLINE = 7
         ENDIF
         @ MLINE,1 SAY ACCT_NAME      
         @ MLINE,34 SAY CK_DATE
         @ MLINE,43 SAY AMOUNT PICTURE '999999.99'
         @ MLINE,55 SAY CK_NBR
         MLINE = MLINE + 2
         SKIP
      ENDDO
      IF MFURN
         @ MLINE +1,1 SAY ' '
         EJECT
      ENDIF
      
      
      MPAGE_NO = 0
      MLINE = 99 
      GOTO TOP
      MFURN = .F.
      
      DO WHILE .NOT. EOF()
         IF CATEGORY <> '7603'
            SKIP
            LOOP
         ENDIF
         MFURN = .T.
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               IF MDISP_PRT = 'P'
                  EJECT
               ENDIF
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,24 SAY MCOMPANY
            @ 2,1 SAY 'PAGE'
            @ 2,06 say mpage_no picture '99'
            @ 2,15 SAY 'FOOD SHOW EQUIPMENT PURCHASE REPORT'
            @ 2,70  SAY DTOC(DATE())
            @ 3,20 SAY DTOC(MDATE) + ' THRU ' + DTOC(MEND_DATE)
            @ 5,1 SAY 'PURCHASED FROM                     DATE      AMOUNT   CK NBR   DESCRIPTION'
            *          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567891123456789012345678
            *                   10        20        30        40        50        60        70        80        90        100       110
            @ 5,0 SAY REPLICATE ('_',75)
            MLINE = 7
         ENDIF
         @ MLINE,1 SAY ACCT_NAME      
         @ MLINE,34 SAY CK_DATE
         @ MLINE,43 SAY AMOUNT PICTURE '999999.99'
         @ MLINE,55 SAY CK_NBR
         MLINE = MLINE + 2
         SKIP
      ENDDO
      
      IF MFURN
         @ MLINE,1 SAY ' '
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
      
   CASE VAL(MSELECTION) =  4    
      MTITLE = ' - PRINT DATE-TO-DATE DISBURSEMENTS/RESERVE ACTIVITY BY ACCOUNT'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      STORE CTOD(' ') TO MBEG_DATE, MEND_DATE
      STORE SPACE(4) TO MACCOUNT
      STORE SPACE(32) TO MPAYEE
      MTOTAL = 0
      MOPT_SALES = '**'
      MCHOICE = 'D'
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 08,5 SAY 'REPORT BEGINNING DATE: ' GET MBEG_DATE        
         @ 10,5 SAY '   REPORT ENDING DATE: ' GET MEND_DATE
         @ 12,3 SAY '(OPTIONAL) ACCOUNT CODE: ' GET MACCOUNT PICTURE '####'
         @ 14,5 SAY '(OPTIONAL) PAYEE NAME: ' GET MPAYEE PICTURE '@!'
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
      IF VAL(MACCOUNT) >= 8401 .AND. VAL(MACCOUNT) <= 8450
         MMORE = .T.
         DO WHILE MMORE
            STORE 'A' TO MCHOICE
            STORE '  ' TO MSALE_CODE
            @ 17,5 SAY 'Print ALL Reserve Activity (A) or just Midwest Disbursements (D)? ' GET MCHOICE PICTURE '@!'
            @ 18,5 say 'Enter Salesperson Code: ' get msale_code picture '##'              
            READ
            IF MCHOICE <> 'A' .AND. MCHOICE <> 'D'
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT
               @ 24,1 SAY "PRINT SELECTION MUST BE AN 'A' OR A 'D' - PRESS RETURN TO REENTER " GET MWAIT
               READ
               @ 24,0 CLEAR
               LOOP
            ENDIF
            IF MSALE_CODE = SPACE(2)
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT
               @ 24,1 SAY "MUST ENTER A SALESPERSON CODE - PRESS RETURN TO REENTER " GET MWAIT
               READ
               @ 24,0 CLEAR
               LOOP
            ENDIF
            MMORE = .F.
         ENDDO
      ENDIF
      MACTION = ' '
      DO PRT_SET
      STORE DTOC(MBEG_DATE) TO M1_DATE
      STORE DTOC(MEND_DATE) TO M2_DATE
      STORE SUBSTR(M1_DATE,1,2) TO MBEG_MO   
      STORE SUBSTR(M1_DATE,7) TO MBEG_YEAR
      STORE SUBSTR(M2_DATE,1,2) TO MEND_MO   
      STORE SUBSTR(M2_DATE,7) TO MEND_YEAR         
      STORE TRIM(MPAYEE) TO MPAYEE
      MPAGE_LEN = 56
      
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
      
      MLINE = 99
      MPAGE_NO= 0
      IF MACCOUNT =  SPACE(4)
         STORE 'NO ACCOUNT SELECTED' TO MDESCRIP
      ELSE
         SELECT D
         DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
         SEEK MACCOUNT
         IF EOF()
            STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP
         ELSE
            STORE DESCRIP TO MDESCRIP 
         ENDIF
      ENDIF
      MTOTAL = 0
      DO CASE
      CASE MCHOICE <> 'A'
         SELECT B
         DO FOX_USE WITH "DISBJRN INDEX DISBJRN", .F.
         SEEK MBEG_YEAR + MBEG_MO   
         DO WHILE .NOT. EOF()
            STORE JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR TO MDATE
            STORE CTOD(MDATE) TO MDATE
            IF MDATE < MBEG_DATE
               SKIP
               LOOP
            ENDIF 
            IF MDATE > MEND_DATE
               GOTO BOTTOM
               SKIP
               LOOP
            ENDIF
            IF VOID_MAN = 'V'
               SKIP
               LOOP
            ENDIF
            IF MACCOUNT <> SPACE(4)
               IF MACCOUNT <> CATEGORY1
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            IF MPAYEE <> SPACE(10)
               IF ACCT_NAME <> TRIM(MPAYEE)
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            IF MOPT_SALES <> '**'
               IF SALESMAN <> MOPT_SALES
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  EJECT
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 2,35 SAY MCOMPANY
               @ 3,1 SAY 'Page'
               @ 3,06 say mpage_no picture '99'
               @ 3,20 SAY 'DISBURSEMENT REPORT FOR ' + M1_DATE + ' THRU ' + M2_DATE
               @ 3,85 SAY DTOC(DATE())
               @ 5,26 SAY 'ACCOUNT: '+ MACCOUNT+' (' + TRIM(MDESCRIP) + ')'
               @ 7,5 SAY 'CK NUMBER     CK DATE         AMOUNT      PAYEE NAME                           INVOICE #'
               MLINE = 9 
            ENDIF
            @ MLINE,7 SAY CK_NBR
            @ MLINE,19 SAY DTOC(MDATE)
            @ MLINE,31 SAY AMOUNT1 PICTURE '999,999.99'
            @ MLINE,47 SAY ACCT_NAME
            @ MLINE,84 SAY BILL_INV
            MLINE = MLINE + 1
            MTOTAL = MTOTAL + AMOUNT1
            SKIP
         ENDDO
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,35 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,20 SAY 'DISBURSEMENT REPORT FOR ' + M1_DATE + ' THRU ' + M2_DATE
            @ 3,85 SAY DTOC(DATE())
            @ 5,26 SAY 'ACCOUNT: '+ MACCOUNT+' (' + TRIM(MDESCRIP)+')'
            @ 7,5 SAY 'CK NUMBER     CK DATE         AMOUNT      PAYEE NAME                           INVOICE #'
            MLINE = 9 
         ENDIF
         
         MLINE = MLINE + 2
         @ MLINE,5 SAY 'TOTAL AMOUNT PAID: '    
         @ MLINE,29 SAY MTOTAL PICTURE '9,999,999.99'
         @ mline +1, 1 say ' '
      OTHERWISE
         SELECT B
         DO FOX_USE WITH "&MDBFLOC.RESERVE INDEX &MDBFLOC.RESERVE", .F.
         SEEK MSALE_CODE 
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALE_CODE
            IF TRAN_DATE < MBEG_DATE .OR. TRAN_DATE > MEND_DATE
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
               @ 3,24 SAY '  ACTIVITY REPORT FOR ' + M1_DATE + ' THRU ' + M2_DATE
               @ 3,85 SAY DTOC(DATE())
               @ 5,26 SAY 'ACCOUNT: '+ MACCOUNT+' (' + TRIM(MDESCRIP)+')'
               @ 7,5 SAY '        ACTIVITY DATE         AMOUNT      DESCRIPTION'
               MLINE = 9 
            ENDIF
            @ MLINE,16 SAY TRAN_DATE  
            @ MLINE,31 SAY AMOUNT PICTURE '999,999.99'
            DO CASE
            CASE ACT_CODE = 'D'
               @ MLINE,47 SAY 'DEPOSIT'
               MTOTAL = MTOTAL + AMOUNT
            CASE ACT_CODE = 'I'
               @ MLINE,47 SAY 'INTEREST'
               MTOTAL = MTOTAL + AMOUNT
            CASE ACT_CODE = 'W'
               @ MLINE,47 SAY 'WITHDRAWAL'
               MTOTAL = MTOTAL - AMOUNT
            CASE ACT_CODE = 'R'
               @ MLINE,47 SAY 'REDEPOSIT'
               MTOTAL = MTOTAL + AMOUNT
            ENDCASE
            
            MLINE = MLINE + 1
            SKIP
         ENDDO
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,35 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            @ 3,24 SAY '  ACTIVITY REPORT FOR ' + M1_DATE + ' THRU ' + M2_DATE
            @ 3,85 SAY DTOC(DATE())
            @ 5,26 SAY 'ACCOUNT: '+ MACCOUNT+' (' + TRIM(MDESCRIP)+')'
            @ 7,5 SAY '        ACTIVITY DATE         AMOUNT      DESCRIPTION'
            MLINE = 9 
         ENDIF
         
         MLINE = MLINE + 2
         @ MLINE,5 SAY 'TOTAL ACTIVITY: '    
         @ MLINE,29 SAY MTOTAL PICTURE '9,999,999.99'
         @ mline+1,1 say ' '
      ENDCASE
      
      IF MLINE <> 99
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      
   CASE VAL(MSELECTION) =  5    
      * Notes...: DATE-TO-DATE DISBURSEMENT TOTALS BY ACCOUNT BY SALESPERSON
      *
      MTITLE = ' - DISBURSEMENTS FOR ALL ACCOUNTS (BY SALESPERSON)'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      
      **** GET DATE FOR THIS REPORT
      STORE CTOD(' ') TO MDATE, MEND_DATE
      STORE 'P' TO MDISP_PRT
      STORE '**' TO MOPT_SALES
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 08,5 SAY 'BEGIN REPORT DATE: '
         @ 08,24 GET MDATE
         @ 10,5 SAY '  END REPORT DATE: ' 
         @ 10,24 GET MEND_DATE
         @ 12,5 SAY 'OPTIONAL SALESPERSON CODE: '    
         @ 12,32 GET MOPT_SALES PICTURE '@!'
         
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF DTOC(MDATE) = '  /  /  ' .OR. DTOC(MEND_DATE) = '  /  /  '
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'BEGIN OR END DATE NOT ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
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
      
      STORE MONTH(MEND_DATE) TO MEMONTH
      MEMONTH = MEMONTH + 100
      STORE SUBSTR(STR(MEMONTH,3),2) TO MEMONTH
      
      STORE YEAR(MEND_DATE) TO MEYEAR
      STORE STR(MEYEAR,4) TO MEYEAR
      
      STORE DAY(MEND_DATE) TO MEDAY
      MEDAY = MEDAY + 100
      STORE SUBSTR(STR(MEDAY,3),2) TO MEDAY
      MPAGE_LEN = 56
      
      SELECT D
      DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
      
      SELECT C
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT A
      DO FOX_USE WITH "DISBJRN INDEX DISBJRN", .F.
      
      SEEK MYEAR + MMONTH + MDAY  
      IF EOF()
         SEEK MYEAR+MMONTH
         IF EOF()
            @ 4,1 CLEAR TO 21,78 
            @ 10,5 SAY 'THERE IS NO DISBURSEMENT DATA ON FILE FOR THIS MONTH/YEAR'
            STORE ' ' TO MWAIT
            @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
            READ
            LOOP  
         ELSE         
            DO WHILE .NOT. EOF() .AND. CTOD(JRNL_MO+'/'+JRNL_DAY+'/'+JRNL_YR) < MDATE
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
      USE TMP_ACCT INDEX TMP_ACCT EXCLUSIVE
      *DO FOX_USE WITH "TMP_ACCT INDEX TMP_ACCT", .F.
      SELECT A
      DO WHILE .NOT. EOF() .AND. CTOD(JRNL_MO+'/'+JRNL_DAY+'/'+JRNL_YR) <= MEND_DATE
         IF VOID_MAN = 'V'
            SKIP
            LOOP
         ENDIF
         IF MOPT_SALES <> '**'
            IF SALESMAN <> SPACE(2)
               IF MOPT_SALES <> SALESMAN 
                  SKIP
                  LOOP
               ENDIF
            ELSE
               IF SUBSTR(ACCT_NBR,1,1) = 'S'
                  IF MOPT_SALES <> SUBSTR(ACCT_NBR,3)
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
         SELECT B
         APPEND BLANK
         REPLACE AMOUNT WITH A->AMOUNT1
         DO CASE
            *** SUPPLIERS
         CASE A->ACCT_TYPE = 'S'
            REPLACE CATEGORY WITH 'P'
            *** FREIGHT
         CASE A->ACCT_TYPE = 'F'
            REPLACE CATEGORY WITH 'F'
         OTHERWISE
            REPLACE CATEGORY WITH A->CATEGORY1
         ENDCASE
         *REPLACE ACCT_NAME WITH A->ACCT_NAME
         *REPLACE CK_NBR WITH A->CK_NBR
         *REPLACE CK_DATE WITH CTOD(A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR)
         MSALESMAN = A->SALESMAN
         IF MSALESMAN = SPACE(2) .AND. SUBSTR(A->ACCT_NBR,1,1) = 'S'
            MSALESMAN = SUBSTR(A->ACCT_NBR,3)
         ENDIF
         IF MPROG_CODE = 2
            SELECT C
            SEEK MSALESMAN
            IF EOF() .OR. OFFICE_CD = '  '
               MSALESMAN = '01'
            ELSE
               MSALESMAN = OFFICE_CD
            ENDIF
            SELECT B  
         ENDIF
         REPLACE SALESMAN WITH MSALESMAN
         SELECT A
         SKIP
      ENDDO
      SELECT C
      USE
      MPAGE_NO = 0
      MLINE = 99 
      
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
      
      
      MGRAND_TOT = 0
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      SELECT B
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
         ELSE
            DO CASE
            CASE MSALESMAN = '01'
               MSALE_NAME = 'CAPE GIRARDEAU OFFICE'
            CASE MSALESMAN = '02'
               MSALE_NAME = 'SOUTH CAROLINA OFFICE'
            OTHERWISE
               MSALE_NAME = 'UNKNOWN OFFICE'
            ENDCASE
         ENDIF
         SELECT B
         MSALE_TOT = 0
         MPRT_NAME = .T.
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
            STORE CATEGORY TO MCATEGORY 
            MTOTAL = 0
            DO WHILE .NOT. EOF() .AND. CATEGORY = MCATEGORY
               MTOTAL = MTOTAL + AMOUNT     
               SKIP
            ENDDO
            IF MTOTAL = 0
               LOOP
            ENDIF
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  IF MDISP_PRT = 'P'
                     EJECT
                  ENDIF
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 1,25 SAY MCOMPANY
               @ 1,1 SAY 'PAGE'
               @ 1,06 say mpage_no picture '99'
               @ 1,55  SAY DTOC(DATE())
               IF MPROG_CODE = 1
                  @ 2,15 SAY 'DISBURSEMENT TOTALS BY SALESPERSON/ACCOUNT'
               ELSE
                  @ 2,15 SAY 'DISBURSEMENT TOTALS BY OFFICE/ACCOUNT'     
               ENDIF
               @ 3,25 SAY DTOC(MDATE) + ' THRU ' + DTOC(MEND_DATE)
               IF MPROG_CODE = 1
                  @ 5,1 SAY 'SALESPERSON/ACCOUNT                            TOTAL'
               ELSE
                  @ 5,1 SAY 'OFFICE/ACCOUNT                                 TOTAL'
               ENDIF
               @ 5,0 SAY REPLICATE ('_',55)
               MLINE = 7
               MPRT_NAME = .T.
            ENDIF
            IF MPRT_NAME 
               @ MLINE,1 SAY MSALE_NAME
               MLINE =MLINE + 1
               MPRT_NAME = .F.
            ENDIF
            SELECT D
            SEEK MCATEGORY
            IF .NOT. EOF()
               @ MLINE,3 SAY DESCRIP 
            ELSE
               @ MLINE,3 SAY MCATEGORY + ' - NOT ON FILE'
            ENDIF
            @ MLINE,40 SAY MTOTAL PICTURE '99,999,999.99'
            MLINE = MLINE + 1
            MSALE_TOT = MSALE_TOT + MTOTAL
            SELECT B
         ENDDO
         @ MLINE-1,1 SAY REPLICATE('_',32)
         @ MLINE-1,40 SAY REPLICATE('_',13)
         @ MLINE,1 SAY MSALESMAN + ' TOTALS:'
         @ MLINE,40 SAY MSALE_TOT PICTURE '99,999,999.99'
         MGRAND_TOT = MGRAND_TOT + MSALE_TOT
         MLINE = MLINE + 3
         SELECT B
      ENDDO
      
      @ MLINE,1 SAY 'TOTAL CHECKS:'
      @ MLINE,40 SAY MGRAND_TOT PICTURE '99,999,999.99'
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
      
   CASE VAL(MSELECTION) =  6    
      @ 04,1 CLEAR TO 22,78
      
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      @ 15,5 SAY 'PRINTING... PLEASE WAIT...'
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
      
      
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_SUP", .F.
      MLINE = 99
      MPAGE_NO = 0
      
      SELECT A
      DO WHILE .NOT. EOF()
         SELECT B
         SEEK A->RSUPCODE + ' '
         DO WHILE .NOT. EOF() .AND. RSUPCODE = A->RSUPCODE .AND. SUP_REC = ' '       
            IF RSUPCODE = 'I'
               SKIP
               LOOP
            ENDIF
            IF RSUPCODE = 'NONE'
               SKIP
               LOOP
            ENDIF
            IF DATE() - SHIP_DATE <= 45
               SKIP
               LOOP
            ENDIF
            IF MLINE > 58
               IF MLINE <> 99
                  EJECT
               ENDIF
               @ 2,27 SAY MCOMPANY
               MPAGE_NO = MPAGE_NO + 1
               @ 3,2 SAY 'PAGE ' + STR(MPAGE_NO,2)
               @ 3,18 SAY 'ORDERS NOT MATCHED/PAID OLDER THAN 45 DAYS'
               @ 3,70 SAY DTOC(DATE())
               @ 5,1 SAY 'PO NUMBER     INVOICE NBR    SHIP DATE    SUPPLIER'
               MLINE = 7
            ENDIF
            IF SALESMAN <> '  '
               @ MLINE,1 SAY SALESMAN + '-'
            ENDIF
            @ MLINE,4 SAY PO_NBR   
            IF PO_SUFFIX <> ' '
               @ MLINE,08 SAY '-' + PO_SUFFIX
            ENDIF
            @ MLINE,17 SAY INV_NBR
            @ MLINE,30 SAY SHIP_DATE
            @ MLINE,43 SAY A->NAME
            MLINE = MLINE + 1
            SKIP
         ENDDO
         SELECT A
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
      
      CLOSE DATA
   CASE VAL(MSELECTION) =  7    
      MTITLE = 'MONTHLY NET SUMMARY FOR SPECIFIC CUSTOMER'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      STORE SPACE(2) TO MTRAN_MO           
      STORE SPACE(4) TO MTRAN_YR
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 08,5 SAY 'REPORT MONTH AND YEAR:    /   '
         @ 08,28 GET MTRAN_MO PICTURE '##'
         @ 08,33 GET MTRAN_YR PICTURE '####'
         @ 11,5 SAY 'Note:  The next screen will prompt you for a specific customer.'
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
      @ 4,1 CLEAR TO 21,78
      MSEL_BBUY = SPACE(4)
      **** SELECT A CUSTOMER HERE 
      SAVE SCREEN TO MGRACE
      MNAME_FD = .F.
      DO BBUYSEL3
      IF .NOT. MNAME_FD 
         CLOSE DATA  
         LOOP
      ENDIF
      MSEL_BBUY = BBUYCODE
      STORE NAME TO MNAME
      CLOSE DATA
      RESTORE SCREEN FROM MGRACE
      SELECT A
      DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
      SEEK MTRAN_YR + MTRAN_MO 
      IF EOF()
         @ 4,1 CLEAR TO 21,78 
         @ 10,5 SAY 'THERE IS NO ACTIVITY DATA ON FILE FOR THIS MONTH'
         STORE ' ' TO MWAIT
         @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
         READ
         CLOSE DATA
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
      ?? chr(27) + '&k0S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
      @ 3,5 SAY DATE()
      @ 3,20 SAY 'MIDWEST FOOD & POULTRY, INC.'
      @ 5,20 SAY 'MONTLY NET SUMMARY FOR: ' + MTRAN_MO + '/' + MTRAN_YR
      @ 6,20 SAY 'FOR: ' + MNAME
      MLINE = 8
      MTOT = 0
      DO WHILE .NOT. EOF() .AND. TRAN_MO = MTRAN_MO .AND. TRAN_YR = MTRAN_YR       
         IF BBUYCODE <> MSEL_BBUY
            SKIP
            LOOP
         ENDIF
         @ MLINE,5 SAY SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
         @ MLINE,15 SAY SHIP_DATE 
         @ MLINE,25 SAY TOT_NET PICTURE '999,999.99'
         @ MLINE,40 SAY INV_COR
         MLINE = MLINE + 1
         MTOT = MTOT + TOT_NET
         SKIP
      ENDDO
      MLINE = MLINE + 3
      @ MLINE,5 SAY 'TOTAL: '
      @ MLINE,25 SAY MTOT PICTURE '999,999.99'
      EJECT
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
   CASE VAL(MSELECTION) =  8    
      
   ENDCASE
   CLOSE DATA
   
ENDDO

RETURN

* EOF: DISBRPT.PRG

*Formatted by: ToolBox Ver. 1.2  on 12/9/15 at 10:00 AM.
