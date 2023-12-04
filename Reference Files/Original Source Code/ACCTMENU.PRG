****************
* Program.: ACCTMENU.PRG
* Author..: GRACE KELLER
* Date....: 02/10/88
* Notice..: Copyright (C) 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: JOURNAL/LEDGER ACTIVITY
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
STORE ' ' TO MSELECTION
STORE ' ' TO MACTION
SET PROC TO ACCTPROC
DO WHILE VAL(MSELECTION) <> 9  
   CLOSE DATA
   CLEAR
   @ 01,00 SAY MCOMPANY
   @ 02,00 SAY MPROGRAM + ' - JOURNALS / LEDGERS / POSTING MENU'
   @ 02,68 SAY DATE()
   @ 3,0 to 25,79
   
   @ 04,9 SAY ' 1 - MONTHLY SPREADSHEET OR INVENTORY SUMMARY (TOTALS OR DETAILS)'
   @ 05,9 SAY '     (NOTE: ABOVE REPORT MUST PRINT ON WIDE PAPER)'
   @ 07,9 SAY ' 2 - POST SPREADSHEET ENTRIES TO JOURNALS (PURCHASE,SALES,FRT,COMM)'
   @ 09,9 SAY ' 3 - PRINT JOURNAL ACTIVITY REGISTERS / TOTALS'
   @ 11,9 SAY ' 4 - POST JOURNAL ENTRIES TO LEDGERS'
   @ 13,9 SAY ' 5 - CONSOLIDATE LEDGER ACCOUNTS (Do before printing ending balances)'
   @ 15,9 SAY ' 6 - LEDGER ACTIVITY REGISTERS / ENDING BALANCES / BOATMENS REPORT'   
   @ 17,9 SAY ' 7 - ADD/UPDATE MANUAL SPREADSHEET ENTRIES'
   @ 19,9 SAY ' 8 - MONTHLY CLOSING / POST ENDING BALANCES'
   @ 21,9 SAY ' 9 - RETURN TO MENU'
   
   STORE ' ' TO MSELECTION
   @ 23,01 SAY 'CHOICE: '
   @ 23,10 GET MSELECTION picture '#'
   READ
   
   DO CASE
      
   CASE VAL(MSELECTION) = 1     
      SET PROC TO ACCTMENU
      MDISP_PRT = 'P'
      @ 4,1 CLEAR TO 24,78
      STORE 'S' TO MINVEN 
      @ 10,5 SAY 'DO YOU WANT A SPREADSHEET (S) OR INVENTORY (I) REPORT? ' GET MINVEN PICTURE '@!'
      READ
      
      DO CASE
      CASE MINVEN = 'S'
         MINVEN = ' SPREADSHEET '
         @ 4,1 CLEAR TO 24,78
         STORE 'Y' TO MTOT_ONLY
         @ 10,5 SAY 'DO YOU ONLY WANT TO PRINT TOTALS (Y/N)? ' GET MTOT_ONLY PICTURE '@!'
         READ
         MCHOICE = ' '
         MINOUT = 'ALL'
         IF MTOT_ONLY ='Y'
            @ 10,5 SAY 'DO YOU WANT TOTALS FOR INVOICES (I), CORRECTIONS (C), OR BOTH (B) ? ' GET MCHOICE PICTURE '@!'
         ELSE
            @ 10,5 SAY 'DO YOU WANT THE SPREADSHEET FOR INVOICES (I)  OR CORRECTIONS (C) ? ' GET MCHOICE PICTURE '@!'
         ENDIF
         @ 12,5 say 'REGULAR PURCHASE/SALES ORDERS  (REG)'
         @ 13,5 SAY 'ORDERS GOING INTO INVENTORY    (IN )'
         @ 14,5 SAY 'ORDERS COMING OUT OF INVENTORY (OUT)'
         @ 15,5 SAY 'ALL ORDERS                     (ALL)'
         @ 16,5 SAY 'SAMPLES                        (SAM): ' GET MINOUT PICTURE '@!'
         READ
         @ 10,5 SAY SPACE(70)
         @ 12,5 SAY SPACE(70)
         @ 13,5 SAY SPACE(70)
         @ 14,5 SAY SPACE(70)
         @ 15,5 SAY SPACE(70)
         @ 16,5 SAY SPACE(70)
         MWORD = ' '
         IF MCHOICE = 'I'
            MINVOICE = .T.
            MWORD = 'INVOICE'
         ENDIF
         IF MCHOICE = 'C'
            MINVOICE = .F.
            MWORD = 'CORRECTION'
         ENDIF
         IF MCHOICE = 'B'
            MINVOICE = .T.
            MWORD = 'INVOICE/CORRECTION'
         ENDIF
         
         DO CASE
         CASE MCHOICE = 'I'
            DO CASE
            CASE MINOUT = 'ALL'
               MWORD = 'ALL INVOICES'
            CASE MINOUT = 'REG'
               MWORD = 'REGULAR INVOICE'
            CASE MINOUT = 'IN'
               MWORD = 'INVOICE INTO INVN'
            CASE MINOUT = 'OUT'
               MWORD = 'INVOICE OUT OF INVN'
            OTHERWISE
               MWORD = 'INVOICE SAMPLES'
            ENDCASE
            
         CASE MCHOICE = 'C'
            DO CASE
            CASE MINOUT = 'ALL'
               MWORD = 'ALL CORRECTIONS'
            CASE MINOUT = 'REG'
               MWORD = 'REGULAR CORRECTION'
            CASE MINOUT = 'IN'
               MWORD = 'CORRECTION INTO INVN'
            CASE MINOUT = 'OUT'
               MWORD = 'CORRECTION OUT OF INVN'
            OTHERWISE
               MWORD = 'CORRECTION SAMPLES'
            ENDCASE
            
         OTHERWISE
            DO CASE
            CASE MINOUT = 'ALL'
               MWORD = 'ALL INVOICES/CORRECTIONS'
            CASE MINOUT = 'REG'
               MWORD = 'REGULAR INVOICE/CORRECTION'
            CASE MINOUT = 'IN'
               MWORD = 'INVOICE/CORRECTION INTO INVN'
            CASE MINOUT = 'OUT'
               MWORD = 'INVOICE/CORRECTION OUT OF INVN'
            OTHERWISE
               MWORD = 'INVOICE/CORRECTION SAMPLES'
            ENDCASE
         ENDCASE
         
         MSTRT_INV = SPACE(5)
         MPAGE_NO = 0
         
         MTITLE = ' - MONTHLY SPREADSHEET REGISTER'
         CLEAR
         @  1, 1  SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         **** GET DATE FOR THIS REPORT
         STORE DATE() TO MDATE
         STORE 'P' TO MDISP_PRT
         STORE '  ' TO MTRAN_MO
         STORE SPACE(4) TO MTRAN_YR
         STORE 2 TO MACTION      
         DO WHILE MACTION = 2      
            @ 08,5 SAY '         ENTER BUSINESS MONTH: '
            @ 08,37 GET MTRAN_MO PICTURE '##'
            @ 10,5 SAY '          ENTER BUSINESS YEAR: '
            @ 10,37 GET MTRAN_YR PICTURE '####'
            
            STORE 1 TO MACTION
            @ 23,00 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
            IF MACTION = 1
               IF MTRAN_MO = '  ' .OR. MTRAN_YR = SPACE(4)
                  @ 24,0 CLEAR
                  mwait = ' '
                  @ 24,1 SAY 'NO MONTH/YEAR ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
                  READ
                  MACTION = 2
                  @ 24,0 CLEAR
                  LOOP 
               ENDIF
            ENDIF
         ENDDO
         
         IF MACTION = 3
            SET PROC TO PO_PROC
            RETURN
         ENDIF  
         MPRT_ACT = 'C'
         
         IF MPRT_ACT <> 'C'
            RETURN
         ENDIF
         MPAGE_LEN = 44
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
         
         SELECT A
         DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
         SEEK MTRAN_YR + MTRAN_MO       
         
         IF EOF()
            @ 4,1 CLEAR TO 21,78 
            @ 10,5 SAY 'THERE IS NO SPREADSHEE DATA ON FILE FOR THIS MONTH'
            STORE ' ' TO MWAIT
            @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
            READ
            SET PROC TO PO_PROC
            RETURN
         ENDIF
         
         SELECT C
         DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
         SELECT D
         DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
         SELECT A
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
            ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
            
            *** LANDSCAPE MODE
            ?? CHR(27) + '&l1O'
            
            *** LEGAL SIZE PAPER
            ?? CHR(27) + '&l3A'
            
         ENDIF
         STORE 0 TO MTOT_PURCH, MTOT_SELL, MPURCH_FRT, MCUS_FRT, MTOT_FRT, MFRT_FRT
         STORE 0 TO MMISC, MTOT_COMM, MTOT_NET, MPURCH_INV, MSELL_INV
         STORE 0 TO MPFRT_INV, MSFRT_INV, MPURCH_TR, MSELL_TR 
         STORE 0 TO MPFRT_TR, MSFRT_TR                        
         STORE 0 TO MSAMPLES, MARTIC, MWESTERN, MHARVEST, MOTHSAMP, MBILL_BACK
         STORE 0 TO MLBS_INV, MLBS_COR       
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO                       
            
            IF MCHOICE <> 'B'
               IF MINVOICE .AND. INV_COR = 'C'
                  SKIP
                  LOOP
               ENDIF
               
               IF .NOT. MINVOICE .AND. INV_COR = 'I'
                  SKIP
                  LOOP
               ENDIF
            ENDIF            
            
            DO CASE
            CASE MINOUT = 'REG'
               IF RSUPCODE = 'IN' .OR. BBUYCODE = 'IN'
                  SKIP
                  LOOP
               ENDIF
            CASE MINOUT = 'IN'
               IF BBUYCODE <> 'IN'
                  SKIP
                  LOOP
               ENDIF
            CASE MINOUT = 'OUT'
               IF RSUPCODE <> 'IN'
                  SKIP
                  LOOP
               ENDIF
            ENDCASE
            
            IF MINOUT = 'SAM'
               MSELECT = .F.
               IF BBUYCODE = 'SAMP'
                  MSAMPLES = MSAMPLES + TOT_PURCH+SUP_PALL
                  MSELECT = .T.
               ENDIF
               IF CUS_PALL <> 0
                  IF MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
                     MSELECT = .T.
                     *** ARTIC CASCADE SAMPLE
                     DO CASE
                        *** ARTIC CASCADE SAMPLE
                     CASE BBUYCODE = '  45'
                        MARTIC = MARTIC - CUS_PALL
                        *** WESTERN BOX SAMPLE
                     CASE BBUYCODE = '  12'
                        MWESTERN = MWESTERN - CUS_PALL
                        *** HARVEST MEATS SAN DIEGO
                     CASE BBUYCODE = '  14'
                        MHARVEST = MHARVEST - CUS_PALL
                     OTHERWISE
                        *** OTHER SAMPLES

                        MOTHSAMP = MOTHSAMP - CUS_PALL
                     ENDCASE
                  ENDIF
               ENDIF
               
               IF .NOT. MSELECT
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            
            IF MLINE > MPAGE_LEN
               DO SPRDHD
            ENDIF
            STORE SALESMAN TO MSALESMAN
            STORE PO_NBR TO MPO_NBR
            STORE PO_SUFFIX TO MPO_SUFFIX
            STORE BBUYCODE TO MBBUYCODE
            
            SELECT C
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF EOF()
               STORE 'NONE' TO MRSUPCODE
            ELSE
               STORE RSUPCODE TO MRSUPCODE
            ENDIF
            
            SELECT D
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF .NOT. EOF()
               STORE SUBSTR(PROD_DESC,1,6) TO MPROD
            ELSE
               STORE SPACE(6) TO MPROD
            ENDIF
            
            SELECT B
            IF MRSUPCODE = 'NONE' .OR. MRSUPCODE = SPACE(4)
               STORE 'NONE' + SPACE(4) TO MRSUPNAME
            ELSE
               DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
               SEEK MRSUPCODE
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,8) TO MRSUPNAME
               ELSE 
                  STORE 'NOTONFIL' TO MRSUPNAME
               ENDIF
            ENDIF
            
            IF MBBUYCODE = 'NONE' .OR. MBBUYCODE = SPACE(4)
               STORE 'NONE' + SPACE(3) TO MBBUYNAME
            ELSE  
               DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
               SEEK MBBUYCODE
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,7) TO MBBUYNAME
               ELSE 
                  STORE 'NOTONFL' TO MBBUYNAME
               ENDIF
            ENDIF
            
            IF MSALESMAN <> SPACE(2)
               DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               SEEK MSALESMAN
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,7) TO MSAL_NAME
               ELSE
                  STORE SPACE(7) TO MSAL_NAME
               ENDIF
            ELSE
               SELECT A
               STORE BROK_NAME TO MSAL_NAME
            ENDIF
            
            SELECT A
            IF SALESMAN <> SPACE(2)
               STORE SALESMAN + '-' + INV_NBR TO MINV_NBR
            ELSE
               STORE INV_NBR TO MINV_NBR
            ENDIF
            
            MFRT_AMT = FRT_AMT1 + FRT_AMT2 + FRT_AMT3
            
            IF MTOT_ONLY <> 'Y'
               DO SPRDSAY
            ENDIF            
            
            IF RSUPCODE <> 'I'
               MTOT_PURCH = MTOT_PURCH + TOT_PURCH
               MPURCH_FRT = MPURCH_FRT + SUP_PALL
            ELSE
               IF RSUPCODE = 'ID'
                  MPURCH_TR = MPURCH_TR + TOT_PURCH
                  MPFRT_TR  = MPFRT_TR + SUP_PALL
               ELSE
                  MPURCH_INV = MPURCH_INV + TOT_PURCH
                  MPFRT_INV  = MPFRT_INV + SUP_PALL
               ENDIF
            ENDIF
            IF BBUYCODE <> 'I'
               MTOT_SELL = MTOT_SELL + TOT_SELL
               MCUS_FRT = MCUS_FRT + CUS_PALL
               DO CASE
               CASE INV_COR = 'I'
                  IF PO_SUFFIX = 'R' .OR. PO_SUFFIX = 'B' .OR. PO_SUFFIX = 'W' .OR. REBATE <> ' ' .OR. BREADING <> ' '
                  ELSE
                     MLBS_INV = MLBS_INV + TOT_LBS
                  ENDIF
               OTHERWISE
                  IF PO_SUFFIX = 'R' .OR. PO_SUFFIX = 'B' .OR. PO_SUFFIX = 'W' .OR. REBATE <> ' ' .OR. BREADING <> ' '
                  ELSE
                     MLBS_COR = MLBS_COR + TOT_LBS
                  ENDIF
               ENDCASE
            ELSE
               IF BBUYCODE = 'ID'
                  MSELL_TR = MSELL_TR + TOT_SELL
                  MSFRT_TR = MSFRT_TR + CUS_PALL
               ELSE
                  MSELL_INV = MSELL_INV + TOT_SELL
                  MSFRT_INV = MSFRT_INV + CUS_PALL
               ENDIF
            ENDIF
            MTOT_FRT = MTOT_FRT + MFRT_AMT
            MFRT_FRT = MFRT_FRT + FRT_PALL
            MMISC = MMISC + MISC_AMT
            MTOT_COMM = MTOT_COMM + SALE_COMM
            MTOT_NET = MTOT_NET + TOT_NET
            
            IF COM_CODE <> SPACE(2) .AND. COMM_AMT <> 0
               STORE COM_CODE TO MCOM_CODE
               SELECT B
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               
               SEEK MCOM_CODE
               IF .NOT. EOF()
                  STORE NAME TO MCOM_NAME
               ELSE  
                  STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME
               ENDIF
               
               IF VAL(A->PO_NBR) >= 1 .AND. VAL(A->PO_NBR) <= 12
                  MTOT_COMM = MTOT_COMM + A->COMM_AMT
                  MBB = .F.
               ELSE
                  IF BILL_BACK = 'Y'
                     MBILL_BACK = MBILL_BACK + A->COMM_AMT
                     MBB = .T.
                  ELSE
                     MTOT_COMM = MTOT_COMM + A->COMM_AMT
                     MBB = .F.
                  ENDIF
               ENDIF
               
               SELECT A
               IF MTOT_ONLY <> 'Y'
                  MLINE = MLINE + 2
                  IF MLINE > MPAGE_LEN
                     DO SPRDHD
                  ENDIF
                  @ MLINE,1 SAY MINV_NBR
                  IF MBB
                     @ MLINE,118 SAY COMM_AMT PICTURE '9999999.99'
                  ELSE
                     @ MLINE,130 SAY COMM_AMT PICTURE '999999.99'
                  ENDIF
                  @ MLINE,141 SAY SUBSTR(MCOM_NAME,1,7)
               ENDIF
            ENDIF
            
            IF COM_CODE2 <> SPACE(2) .AND. COMM_AMT2 <> 0
               STORE COM_CODE2 TO MCOM_CODE
               SELECT B
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               
               SEEK MCOM_CODE
               IF .NOT. EOF()
                  STORE NAME TO MCOM_NAME
               ELSE  
                  STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME
               ENDIF
               IF BILL_BACK = 'Y'
                  MBILL_BACK = MBILL_BACK + A->COMM_AMT2
                  MBB = .T.
               ELSE
                  MTOT_COMM = MTOT_COMM + A->COMM_AMT2
                  MBB = .F.
               ENDIF
               
               SELECT A
               IF MTOT_ONLY <> 'Y'
                  MLINE = MLINE + 2
                  IF MLINE > MPAGE_LEN
                     DO SPRDHD
                  ENDIF
                  @ MLINE,1 SAY MINV_NBR
                  IF MBB
                     @ MLINE,118 SAY COMM_AMT2 PICTURE '9999999.99'
                  ELSE
                     @ MLINE,130 SAY COMM_AMT2 PICTURE '999999.99'
                  ENDIF
                  @ MLINE,141 SAY SUBSTR(MCOM_NAME,1,7)
               ENDIF
            ENDIF
            
            IF COM_CODE3 <> SPACE(2) .AND. COMM_AMT3 <> 0
               STORE COM_CODE3 TO MCOM_CODE
               SELECT B
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               
               SEEK MCOM_CODE
               IF .NOT. EOF()
                  STORE NAME TO MCOM_NAME
               ELSE  
                  STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME
               ENDIF
               IF BILL_BACK = 'Y'
                  MBILL_BACK = MBILL_BACK + A->COMM_AMT3
                  MBB = .T.
               ELSE
                  MTOT_COMM = MTOT_COMM + A->COMM_AMT3
                  MBB = .F.
               ENDIF
               SELECT A
               IF MTOT_ONLY <> 'Y'
                  MLINE = MLINE + 2
                  IF MLINE > MPAGE_LEN
                     DO SPRDHD
                  ENDIF
                  @ MLINE,1 SAY MINV_NBR
                  IF MBB
                     @ MLINE,118 SAY COMM_AMT3 PICTURE '9999999.99'
                  ELSE
                     @ MLINE,130 SAY COMM_AMT3 PICTURE '999999.99'
                  ENDIF
                  @ MLINE,141 SAY SUBSTR(MCOM_NAME,1,7)
               ENDIF
            ENDIF
            
            **RON MONTGOMERY CHANGES
            IF SAL_CODE2 <> SPACE(2)
               STORE SAL_CODE2 TO MSAL_CODE2
               SELECT B
               **DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               SEEK MSAL_CODE2
               IF .NOT. EOF()
                  STORE NAME TO MSAL_NAME2
               ELSE
                  STORE '3RD PARTY CONTRACTOR NOT ON FILE' TO MSAL_NAME2
               ENDIF
               SELECT A
               IF MTOT_ONLY <> 'Y'
                  MLINE = MLINE + 2
                  IF MLINE > MPAGE_LEN
                     DO SPRDHD
                  ENDIF
                  @ MLINE,1 SAY MINV_NBR
                  @ MLINE,130 SAY SALE2_AMT PICTURE '999999.99'
                  @ MLINE,141 SAY SUBSTR(MSAL_NAME2,1,7)
                  **@ MLINE,150 SAY SALE2_NET PICTURE '99999999.99'
               ENDIF
               MTOT_COMM = MTOT_COMM + SALE2_AMT
               **MTOT_NET = MTOT_NET + SALE2_NET
            ENDIF
            
            IF SAL_CODE3 <> SPACE(2)                        
               STORE SAL_CODE3 TO MSAL_CODE3
               SELECT B
               DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               SEEK MSAL_CODE3
               IF .NOT. EOF()
                  STORE NAME TO MSAL_NAME3
               ELSE
                  STORE 'SALESPERSON NOT ON FILE         ' TO MSAL_NAME3
               ENDIF
               SELECT A
               IF MTOT_ONLY <> 'Y'
                  MLINE = MLINE + 2
                  IF MLINE > MPAGE_LEN
                     DO SPRDHD
                  ENDIF
                  @ MLINE,1 SAY MINV_NBR
                  @ MLINE,130 SAY SALE3_AMT PICTURE '999999.99'
                  @ MLINE,141 SAY SUBSTR(MSAL_NAME3,1,07)
                  @ MLINE,150 SAY SALE3_NET PICTURE '99999999.99'
               ENDIF
               MTOT_COMM = MTOT_COMM + SALE3_AMT
               MTOT_NET = MTOT_NET + SALE3_NET
            ENDIF
            
            IF MTOT_ONLY <> 'Y'
               MLINE = MLINE + 2
            ENDIF
            SKIP
         ENDDO
         
         @ MLINE,1 SAY 'TOTALS:'
         @ MLINE,35 SAY MTOT_SELL PICTURE '99999999.99'
         @ MLINE,46 SAY MCUS_FRT PICTURE '999999.99'
         @ MLINE,66 SAY MTOT_PURCH PICTURE '99999999.99'
         @ MLINE,77 SAY MPURCH_FRT PICTURE '999999.99'
         @ MLINE,87  SAY MTOT_FRT PICTURE '9999999.99'
         @ MLINE,99  SAY MFRT_FRT PICTURE '999999.99'
         @ MLINE,108 SAY MMISC PICTURE '999999.99'
         @ MLINE,118 SAY MBILL_BACK PICTURE '9999999.99'
         @ MLINE,130 SAY MTOT_COMM PICTURE '999999.99'
         @ MLINE,150 SAY MTOT_NET PICTURE '99999999.99'
         MLINE = MLINE + 2
         @ MLINE,1 SAY 'INVENTORY:'
         @ MLINE,35 SAY MSELL_INV PICTURE '99999999.99'
         @ MLINE,46 SAY MSFRT_INV PICTURE '999999.99'
         @ MLINE,66 SAY MPURCH_INV PICTURE '99999999.99'
         @ MLINE,77 SAY MPFRT_INV  PICTURE '999999.99'
         MLINE = MLINE + 2
         @ MLINE,1 SAY 'TRANSFER SALES:'
         @ MLINE,35 SAY MSELL_TR PICTURE '99999999.99'
         @ MLINE,46 SAY MSFRT_TR PICTURE '999999.99'
         MLINE = MLINE + 2
         @ MLINE,1 SAY 'TRANSFER PURCHASES:'
         @ MLINE,87 SAY MPURCH_TR PICTURE '99999999.99'
         @ MLINE,99 SAY MPFRT_TR  PICTURE '999999.99'
         MLINE = MLINE + 3
         IF MSAMPLES <> 0
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'NOTE: COST OF PRODUCT SAMPLES SHIPPED:' 
            @ MLINE,66 SAY MSAMPLES PICTURE '99999999.99'
         ENDIF
         IF MARTIC <> 0
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'NOTE: ARTIC CASCADE COST OF PRODUCT SAMPLES DEDUCTED:' 
            @ MLINE,66 SAY MARTIC PICTURE '99999999.99'
         ENDIF
         IF MWESTERN <> 0
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'NOTE: WESTERN BOX COST OF PRODUCT SAMPLES DEDUCTED:' 
            @ MLINE,66 SAY MWESTERN PICTURE '99999999.99'
         ENDIF
         IF MHARVEST <> 0
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'NOTE: HARVEST FOODS COST OF PRODUCT SAMPLES DEDUCTED:' 
            @ MLINE,66 SAY MHARVEST PICTURE '99999999.99'
         ENDIF
         IF MOTHSAMP <> 0
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'NOTE: OTHER COST OF PRODUCT SAMPLES DEDUCTED:' 
            @ MLINE,66 SAY MOTHSAMP PICTURE '99999999.99'
         ENDIF
         MTOT_SAMP = MSAMPLES+MARTIC+MWESTERN+MHARVEST+MOTHSAMP
         IF MTOT_SAMP <> 0
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'TOTAL COST OF PRODUCT SAMPLES:' 
            @ MLINE,66 SAY MTOT_SAMP PICTURE '99999999.99'
         ENDIF
         IF MLBS_INV <> 0
            MLINE = MLINE + 3
            @ MLINE,1 SAY 'SALES POUNDS - INVOICES:' 
            @ MLINE,66 SAY MLBS_INV PICTURE '99999999.99'
         ENDIF
         IF MLBS_COR <> 0
            MLINE = MLINE + 3
            @ MLINE,1 SAY 'SALES POUNDS - CORRECTIONS:' 
            @ MLINE,66 SAY MLBS_COR PICTURE '99999999.99'
         ENDIF
         @ MLINE+1,1 SAY ' '
         
         EJECT
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
         
      OTHERWISE
         
         MINVEN = ' INVENTORY '
         MTITLE = ' - MONTHLY INVENTORY SUMMARY'
         
         CLEAR
         @  1, 1  SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         **** GET DATE FOR THIS REPORT
         STORE DATE() TO MDATE
         STORE '  ' TO MTRAN_MO
         STORE SPACE(4) TO MTRAN_YR
         MTOT_DET = SPACE(7)
         STORE 2 TO MACTION      
         DO WHILE MACTION = 2      
            @ 08,5 SAY '         ENTER BUSINESS MONTH: '
            @ 08,37 GET MTRAN_MO PICTURE '##'
            @ 10,5 SAY '          ENTER BUSINESS YEAR: '  
            @ 10,37 GET MTRAN_YR PICTURE '####'
            @ 12,5 SAY 'PRINT TOTALS OR DETAILS (TOTALS/DETAILS)? ' GET MTOT_DET PICTURE '@!'
            
            STORE 1 TO MACTION
            @ 23,00 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
            IF MACTION = 1
               IF MTRAN_MO = '  ' .OR. MTRAN_YR = SPACE(4)
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
         MPRT_ACT = 'C'
         
         DO PRT_SET
         IF MPRT_ACT <> 'C'
            SET PROC TO PO_PROC
            RETURN
         ENDIF
         MPAGE_LEN = 44
         
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
         
         SELECT A
         DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
         SEEK MTRAN_YR + MTRAN_MO        
         IF EOF()
            @ 4,1 CLEAR TO 21,78 
            @ 10,5 SAY 'THERE IS NO SPREADSHEET DATA ON FILE FOR THIS MONTH'
            STORE ' ' TO MWAIT
            @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
            READ
            SET PROC TO PO_PROC
            RETURN
         ENDIF
         
         SELECT C
         DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
         SELECT D
         DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
         SELECT A
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
            ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
            
            *** LANDSCAPE MODE
            ?? CHR(27) + '&l1O'
            
            *** LEGAL SIZE PAPER
            ?? CHR(27) + '&l3A'
            
         ENDIF
         STORE 0 TO MTOT_PURCH, MTOT_SELL, MPURCH_FRT, MCUS_FRT, MTOT_FRT, MFRT_FRT
         STORE 0 TO MMISC, MTOT_COMM, MTOT_NET
         
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO                       
            
            IF RSUPCODE <> 'INVN' .AND. BBUYCODE <> 'INVN'
               SKIP
               LOOP
            ENDIF
            
            IF RSUPCODE = 'INVN'
               MTOT_PURCH = MTOT_PURCH + TOT_PURCH
               MPURCH_FRT = MPURCH_FRT + SUP_PALL
            ENDIF
            IF BBUYCODE = 'INVN'
               MTOT_SELL = MTOT_SELL + TOT_SELL
               MCUS_FRT = MCUS_FRT + CUS_PALL
            ENDIF
            
            IF MTOT_DET = 'DETAILS'
               STORE SALESMAN TO MSALESMAN
               STORE PO_NBR TO MPO_NBR
               STORE PO_SUFFIX TO MPO_SUFFIX
               STORE BBUYCODE TO MBBUYCODE
               
               SELECT C
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               IF EOF()
                  STORE 'NONE' TO MRSUPCODE
               ELSE
                  STORE RSUPCODE TO MRSUPCODE
               ENDIF
               
               SELECT D
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               IF .NOT. EOF()
                  STORE SUBSTR(PROD_DESC,1,6) TO MPROD
               ELSE
                  STORE SPACE(6) TO MPROD
               ENDIF
               
               SELECT B
               IF MRSUPCODE = 'NONE' .OR. MRSUPCODE = SPACE(4)
                  STORE 'NONE' + SPACE(4) TO MRSUPNAME
               ELSE
                  DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
                  SEEK MRSUPCODE
                  IF .NOT. EOF()
                     STORE SUBSTR(NAME,1,8) TO MRSUPNAME
                  ELSE 
                     STORE 'NOTONFIL' TO MRSUPNAME
                  ENDIF
               ENDIF
               
               IF MBBUYCODE = 'NONE' .OR. MBBUYCODE = SPACE(4)
                  STORE 'NONE' + SPACE(3) TO MBBUYNAME
               ELSE  
                  DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
                  SEEK MBBUYCODE
                  IF .NOT. EOF()
                     STORE SUBSTR(NAME,1,7) TO MBBUYNAME
                  ELSE 
                     STORE 'NOTONFL' TO MBBUYNAME
                  ENDIF
               ENDIF
               
               IF MSALESMAN <> SPACE(2)
                  DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
                  SEEK MSALESMAN
                  IF .NOT. EOF()
                     STORE SUBSTR(NAME,1,7) TO MSAL_NAME
                  ELSE
                     STORE SPACE(7) TO MSAL_NAME
                  ENDIF
               ELSE
                  SELECT A
                  STORE BROK_NAME TO MSAL_NAME
               ENDIF
               
               SELECT A
               IF SALESMAN <> SPACE(2)
                  STORE SALESMAN + '-' + INV_NBR TO MINV_NBR
               ELSE
                  STORE INV_NBR TO MINV_NBR
               ENDIF
               IF MLINE > MPAGE_LEN
                  DO SPRDHD
               ENDIF
               
               MFRT_AMT = FRT_AMT1 + FRT_AMT2 + FRT_AMT3  
               
               DO SPRDSAY
               
               MTOT_FRT = MTOT_FRT + MFRT_AMT
               MFRT_FRT = MFRT_FRT + FRT_PALL
               MMISC = MMISC + MISC_AMT
               MTOT_COMM = MTOT_COMM + SALE_COMM
               MTOT_NET = MTOT_NET + TOT_NET
               
               IF COM_CODE <> SPACE(2) .AND. COMM_AMT <> 0
                  STORE COM_CODE TO MCOM_CODE
                  SELECT B
                  DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
                  
                  SEEK MCOM_CODE
                  IF .NOT. EOF()
                     STORE NAME TO MCOM_NAME
                  ELSE  
                     STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME
                  ENDIF
                  IF BILL_BACK = 'Y'
                     MBILL_BACK = MBILL_BACK + A->COMM_AMT
                     MBB = .T.
                  ELSE
                     MTOT_COMM = MTOT_COMM + A->COMM_AMT
                     MBB = .F.
                  ENDIF
                  
                  SELECT A
                  IF MYES_NO <> 'Y'
                     MLINE = MLINE + 2
                     IF MLINE > MPAGE_LEN
                        DO SPRDHD
                     ENDIF
                     @ MLINE,1 SAY MINV_NBR
                     IF MBB
                        @ MLINE,118 SAY COMM_AMT PICTURE '999999.99'
                     ELSE
                        @ MLINE,130 SAY COMM_AMT PICTURE '9999999.99'
                     ENDIF
                     @ MLINE,141 SAY SUBSTR(MCOM_NAME,1,7)
                  ENDIF
               ENDIF
               
               IF COM_CODE2 <> SPACE(2) .AND. COMM_AMT2 <> 0
                  STORE COM_CODE2 TO MCOM_CODE
                  SELECT B
                  DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
                  
                  SEEK MCOM_CODE
                  IF .NOT. EOF()
                     STORE NAME TO MCOM_NAME
                  ELSE  
                     STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME
                  ENDIF
                  IF MCOMPANY = 'AMERICHICKEN, INC' .OR. A->SALESMAN = '11'
                     IF BILL_BACK = 'Y'
                        MBILL_BACK = MBILL_BACK + A->COMM_AMT2
                        MBB = .T.
                     ELSE
                        MTOT_COMM = MTOT_COMM + A->COMM_AMT2
                        MBB = .F.
                     ENDIF
                  ENDIF
                  SELECT A
                  IF MYES_NO <> 'Y'
                     MLINE = MLINE + 2
                     IF MLINE > MPAGE_LEN
                        DO SPRDHD
                     ENDIF
                     @ MLINE,1 SAY MINV_NBR
                     IF MBB
                        @ MLINE,118 SAY COMM_AMT2 PICTURE '999999.99'
                     ELSE
                        @ MLINE,130 SAY COMM_AMT2 PICTURE '9999999.99'
                     ENDIF
                     @ MLINE,141 SAY SUBSTR(MCOM_NAME,1,7)
                  ENDIF
               ENDIF
               
               IF COM_CODE3 <> SPACE(2) .AND. COMM_AMT3 <> 0
                  STORE COM_CODE3 TO MCOM_CODE
                  SELECT B
                  DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
                  
                  SEEK MCOM_CODE
                  IF .NOT. EOF()
                     STORE NAME TO MCOM_NAME
                  ELSE  
                     STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME
                  ENDIF
                  IF BILL_BACK = 'Y'
                     MBILL_BACK = MBILL_BACK + A->COMM_AMT3
                     MBB = .T.
                  ELSE
                     MTOT_COMM = MTOT_COMM + A->COMM_AMT3
                     MBB = .F.
                  ENDIF
                  SELECT A
                  MLINE = MLINE + 2
                  IF MLINE > MPAGE_LEN
                     DO SPRDHD
                  ENDIF
                  IF MYES_NO <> 'Y'
                     @ MLINE,1 SAY MINV_NBR
                     IF MBB
                        @ MLINE,118 SAY COMM_AMT3 PICTURE '999999.99'
                     ELSE
                        @ MLINE,130 SAY COMM_AMT3 PICTURE '9999999.99'
                     ENDIF
                     @ MLINE,141 SAY SUBSTR(MCOM_NAME,1,7)
                  ENDIF
               ENDIF
               
               **RON MONTGOMERY CHANGES
               IF SAL_CODE2 <> SPACE(2)
                  STORE SAL_CODE2 TO MSAL_CODE2
                  SELECT B
                  **DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
                  DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
                  SEEK MSAL_CODE2
                  IF .NOT. EOF()
                     STORE NAME TO MSAL_NAME2
                  ELSE
                     STORE '3RD PARTY CONTRACTOR NOT ON FILE' TO MSAL_NAME2
                  ENDIF
                  SELECT A
                  MLINE = MLINE + 2
                  IF MLINE > MPAGE_LEN
                     DO SPRDHD
                  ENDIF
                  IF MYES_NO <> 'Y'
                     @ MLINE,1 SAY MINV_NBR
                     @ MLINE,130 SAY SALE2_AMT PICTURE '999999.99'
                     @ MLINE,141 SAY SUBSTR(MSAL_NAME2,1,7)
                     **@ MLINE,150 SAY SALE2_NET PICTURE '99999999.99'
                  ENDIF
                  MTOT_COMM = MTOT_COMM + SALE2_AMT
                  **MTOT_NET = MTOT_NET + SALE2_NET
               ENDIF
               
               IF SAL_CODE3 <> SPACE(2)                        
                  STORE SAL_CODE3 TO MSAL_CODE3
                  SELECT B
                  DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
                  SEEK MSAL_CODE3
                  IF .NOT. EOF()
                     STORE NAME TO MSAL_NAME3
                  ELSE
                     STORE 'SALESPERSON NOT ON FILE         ' TO MSAL_NAME3
                  ENDIF
                  SELECT A
                  MLINE = MLINE + 2
                  IF MLINE > MPAGE_LEN
                     DO SPRDHD
                  ENDIF
                  IF MYES_NO <> 'Y'
                     @ MLINE,1 SAY MINV_NBR
                     @ MLINE,130 SAY SALE3_AMT PICTURE '999999.99'
                     @ MLINE,141 SAY SUBSTR(MSAL_NAME3,1,7)
                     @ MLINE,150 SAY SALE3_NET PICTURE '99999999.99'
                  ENDIF
                  MTOT_COMM = MTOT_COMM + SALE3_AMT
                  MTOT_NET = MTOT_NET + SALE3_NET
               ENDIF
               
               MLINE = MLINE + 2
               
            ENDIF
            
            SELECT A
            SKIP
         ENDDO
         IF MLINE > MPAGE_LEN
            DO SPRDHD
         ENDIF
         @ MLINE,1 SAY 'TOTALS:'
         @ MLINE,35 SAY MTOT_SELL PICTURE '99999999.99'
         @ MLINE,46 SAY MCUS_FRT PICTURE '999999.99'
         @ MLINE,66 SAY MTOT_PURCH PICTURE '99999999.99'
         @ MLINE,77 SAY MPURCH_FRT PICTURE '999999.99'
         EJECT
         @ MLINE+1,1 SAY ' '
         
         **** RESET PRINT BACK TO THE WAY IT NORMALLY SHOULD BE SET
         **** EPSON -ELITE, AND LETTER QUALITY MODE, SANS SERIF
         *?? CHR(18)
         *?? CHR(27) + 'M'
         *?? CHR(27) + 'x' + CHR(1)
         *?? CHR(27) + 'k' + CHR(2)
         
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
         
      ENDCASE
      CLOSE DATA
      MSELECTION = ' '
   CASE VAL(MSELECTION) = 2    
      SET PROC TO ACCTPROC
      DO POSTSPRD 
      MSELECTION = ' '
   CASE VAL(MSELECTION) = 3     
      SET PROC TO ACCTPROC
      DO JRNL_PRT
      MSELECTION = ' '
   CASE VAL(MSELECTION) = 4    
      DO POSTJRN
      MSELECTION = ' '
   CASE VAL(MSELECTION) = 5    
      DO CONVLED
      MSELECTION = ' '
   CASE VAL(MSELECTION) =  6    
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 02,00 SAY MPROGRAM + ' - LEDGER REPORTS / BOATMENS STATEMENT'
      @ 02,70 SAY DATE()
      @ 3,0 to 25,79
      MCHOICE = ' '
      @ 10,5 SAY 'Make your report selection: ' get mchoice picture '@!'
      @ 12,5 SAY "'L' - Ledger Activity / Balance Reports "     
      ***@ 14,5 SAY "'B' - Bank Statement - Old"      
      READ 
      DO CASE
      CASE MCHOICE = 'L'
         DO LED_PRT 
      CASE MCHOICE = 'B'
      ENDCASE
      MSELECTION = ' '
   CASE VAL(MSELECTION) =  7    
      *** DO MANUAL
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      SELECT C
      DO FOX_USE WITH "INV_HEAD INDEX INV_HEAD", .F.
      
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 02,00 SAY MPROGRAM + ' - ADD / UPDATE MANUAL SPREADSHEET ENTRIES'
      @ 02,70 SAY DATE()
      @ 3,0 to 24,79
      STORE ' ' TO MCHOICE
      @ 10,5 SAY 'Do You Want to Add Entries (A) or Update Entries (U) ? ' GET MCHOICE PICTURE '@!'
      READ
      IF MCHOICE = 'U'
         DO UPDSPRD
         MSELECTION = ' '
         LOOP
      ELSE
         IF MCHOICE <> 'A'
            MSELECTION = ' '
            LOOP   
         ENDIF
      ENDIF
      STORE 0 TO MMONTH, MTRAN_YR
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 14,5 SAY 'Enter Posting Month: ' get mmonth picture '##' range 1,12
         @ 16,5 SAY '       Posting Year: ' get mtran_yr picture '####' range 1988,2099
         STORE 1 TO MACTION
         @ 24,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
      ENDDO
      IF MACTION = 3
         MSELECTION = ' '
         LOOP
      ENDIF
      STORE SUBSTR(STR(MMONTH+100,3),2) TO MTRAN_MO
      STORE STR(MTRAN_YR,4) TO MTRAN_YR
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 02,00 SAY MPROGRAM + ' - ADD MANUAL SPREADSHEET ENTRY'
      @ 02,70 SAY DATE()
      @ 3,0 to 24,79
      STORE DATE() TO MPOST_DATE
      MMORE_ENT = .T.
      DO WHILE MMORE_ENT
         CLEAR
         @ 01,00 SAY MCOMPANY
         @ 02,00 SAY MPROGRAM + ' - ADD MANUAL SPREADSHEET ENTRY'
         @ 02,70 SAY DATE()
         @ 3,0 to 24,79
         STORE SPACE(5) TO MINV_NBR
         STORE SPACE(4) TO MPO_NBR
         STORE SPACE(1) TO MPO_SUFFIX
         STORE SPACE(2) TO MSALESMAN
         STORE SPACE(32) TO MRSUPNAME, MBBUYNAME, MFRT_NAME1, MFRT_NAME2, MSAL2_NAME, MCOM_NAME, MCOM_NAME2
         STORE 0 TO MTOT_PUR1, MTOT_PUR2, MTOT_SEL1, MTOT_SEL2, M1ST_FRT1, M1ST_FRT2
         STORE 0 TO M2ND_FRT1, M2ND_FRT2, MSALE_COM1, MSALE_COM2, MSAL2_COM1, MSAL2_COM2, MSAL3_COM1, MSAL3_COM2
         STORE 0 TO MCOM_COM1, MCOM_COM2, MMISC_AMT1, MMISC_AMT2
         STORE 0 TO MCOM2_COM1, MCOM2_COM2
         STORE 0 TO MFRT_PAL1, MFRT_PAL2, MCUS_PAL1, MCUS_PAL2, MSUP_PAL1, MSUP_PAL2
         STORE SPACE(2) TO MCOM_CODE, MCOM_CODE2, MSAL_CODE2, MSAL_CODE3             
         STORE SPACE(4) TO MFRT_CODE1             
         MEDIT_ENT = .T.    
         DO WHILE MEDIT_ENT   
            MEDIT = .T.
            DO WHILE MEDIT
               MACTION = 1
               @ 4,1 SAY 'INVOICE NBR: '    
               @ 4,16 GET MINV_NBR PICTURE '#####'
               
               @ 4,25 SAY 'PO NUMBER: ' 
               @ 4,38 GET MSALESMAN
               @ 4,40 SAY '-'
               @ 4,41 GET MPO_NBR PICTURE '####'
               @ 4,45 SAY '-'
               @ 4,46 GET MPO_SUFFIX PICTURE '@!'
               @ 4,53 SAY 'POSTING DATE: '
               @ 4,67 GET MPOST_DATE
               READ
               IF MINV_NBR = SPACE(5) .AND. MSALESMAN = SPACE(2) .AND. MPO_NBR = SPACE(4)
                  MMORE_ENT = .F.
                  MEDIT = .F.
                  MEDIT_ENT = .F.
                  LOOP
               ENDIF
               IF MPO_NBR <> SPACE(4)
                  SELECT B
                  SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
                  IF .NOT. EOF()
                     @ 24,0 CLEAR
                     STORE 'N' TO MYES_NO
                     @ 24,0 SAY 'PO ON FILE - DO YOU WANT TO CONTINUE WITH THIS ENTRY (Y/N)? ' GET MYES_NO PICTURE '@!'
                     READ
                     @ 24,0 CLEAR
                     IF MYES_NO <> 'Y'
                        MEDIT_ENT = .F.
                        MEDIT = .F.
                        MACTION = 3
                        LOOP
                     ELSE
                        STORE INV_NBR TO MINV_NBR
                     ENDIF
                  ENDIF
               ELSE
                  IF MINV_NBR <> SPACE(5)
                     MINV_NBR = STR(VAL(MINV_NBR),5)    
                     SELECT C
                     SEEK MINV_NBR
                     IF .NOT. EOF()
                        @ 24,0 CLEAR
                        STORE 'N' TO MYES_NO
                        @ 24,0 SAY 'INVOICE ON FILE - DO YOU WANT TO CONTINUE WITH THIS ENTRY (Y/N)? ' GET MYES_NO PICTURE '@!'
                        READ
                        @ 24,0 CLEAR
                        IF MYES_NO <> 'Y'
                           MEDIT_ENT = .F.
                           MEDIT = .F.
                           MACTION = 3
                           LOOP
                        ELSE
                           STORE SALESMAN TO MSALESMAN
                           STORE PO_NBR TO MPO_NBR
                           STORE PO_SUFFIX TO MPO_SUFFIX
                        ENDIF
                     ENDIF
                  ENDIF
               ENDIF
               IF MSALESMAN <> SPACE(2)
                  SELECT A
                  DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
                  SEEK MSALESMAN
                  IF .NOT. EOF()
                     STORE NAME TO MSAL_NAME
                     MEDIT = .F.
                  ELSE
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'INVALID SALESPERSON CODE - PRESS RETURN TO REENTER ' GET MWAIT
                     READ
                     @ 24,0 CLEAR
                     LOOP
                  ENDIF
               ELSE
                  MEDIT = .F.
               ENDIF
            ENDDO
            IF .NOT. MMORE_ENT .OR. MACTION = 3
               LOOP
            ENDIF
            
            @ 4,16 SAY MINV_NBR
            @ 4,38 SAY MSALESMAN
            @ 4,41 SAY MPO_NBR
            @ 4,46 SAY MPO_SUFFIX
            @ 4,67 SAY MPOST_DATE
            @ 6,51 SAY '1ST ENTRY AMT'
            @ 6,66 SAY '2ND ENTRY AMT'
            
            MDO_THIS = .T.
            DO WHILE MDO_THIS
               ***** CUSTOMER INFORMATION
               @ 8,1 SAY '       CUSTOMER:'
               @ 8,18 GET MBBUYNAME PICTURE '@!'
               READ
               STORE MBBUYNAME TO MNAME
               IF MNAME <> 'NONE'
                  MNAME_FD = .F.
                  SELECT A
                  DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
                  DO BBUYSEL2
                  IF .NOT. MNAME_FD .OR. MACTION = 3
                     LOOP
                  ENDIF
                  STORE NAME TO MBBUYNAME
                  STORE BBUYCODE TO MBBUYCODE
                  @ 8,18 SAY MBBUYNAME
                  @ 9,1 SAY '  CUST. PALLETS:'
                  
                  @ 8,52 GET MTOT_SEL1 PICTURE '###,###.##'
                  @ 8,67 GET MTOT_SEL2 PICTURE '###,###.##'
                  @ 9,52 GET MCUS_PAL1 PICTURE '###,###.##'
                  @ 9,67 GET MCUS_PAL2 PICTURE '###,###.##'
                  READ
                  MDO_THIS = .F.
               ELSE
                  STORE MNAME TO MBBUYNAME
                  STORE 'NONE' TO MBBUYCODE
                  @ 8,18 SAY MBBUYNAME
                  MDO_THIS = .F.
               ENDIF
            ENDDO
            
            MDO_THIS = .T.
            DO WHILE MDO_THIS
               *** SUPPLIER INFORMATION
               @ 10,1 SAY '       SUPPLIER:'
               @ 10,18 GET MRSUPNAME PICTURE '@!'
               READ
               STORE MRSUPNAME TO MNAME
               IF MNAME <> 'NONE'
                  MNAME_FD = .F.
                  SELECT A
                  DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
                  DO RSUPSEL2
                  IF .NOT. MNAME_FD .OR. MACTION = 3
                     LOOP
                  ENDIF
                  STORE NAME TO MRSUPNAME
                  STORE RSUPCODE TO MRSUPCODE
                  @ 10,18 SAY MRSUPNAME
                  @ 11,1 SAY '   SUP. PALLETS:'
                  @ 10,52 GET MTOT_PUR1 PICTURE '###,###.##'
                  @ 10,67 GET MTOT_PUR2 PICTURE '###,###.##'
                  @ 11,52 GET MSUP_PAL1 PICTURE '###,###.##'
                  @ 11,67 GET MSUP_PAL2 PICTURE '###,###.##'
                  MDO_THIS = .F.
                  READ
               ELSE
                  STORE MNAME TO MRSUPNAME
                  STORE 'NONE' TO MRSUPCODE
                  @ 10,18 SAY MRSUPNAME
                  MDO_THIS = .F.
               ENDIF
            ENDDO
            
            MDO_THIS = .T.
            DO WHILE MDO_THIS
               ***** FIRST FREIGHT CARRIER
               @ 12,1 SAY '   FREIGHT COMP:'
               @ 12,18 GET MFRT_NAME1 PICTURE '@!'
               READ
               STORE MFRT_NAME1 TO MNAME
               IF MNAME <> 'NONE'
                  MNAME_FD = .F.
                  SELECT A
                  DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
                  DO FRT_SEL3
                  IF .NOT. MNAME_FD .OR. MACTION = 3
                     LOOP
                  ENDIF
                  STORE NAME TO MFRT_NAME1
                  STORE FRT_CODE TO MFRT_CODE1
                  @ 12,18 SAY MFRT_NAME1
                  @ 12,1 SAY '   FRT. PALLETS:'
                  @ 12,52 GET M1ST_FRT1 PICTURE '###,###.##'
                  @ 12,67 GET M1ST_FRT2 PICTURE '###,###.##'
                  @ 13,52 GET MFRT_PAL1 PICTURE '###,###.##'
                  @ 13,67 GET MFRT_PAL2 PICTURE '###,###.##'
                  READ
                  MDO_THIS = .F.
               ELSE
                  STORE MNAME TO MFRT_NAME1
                  STORE 'NONE' TO MFRT_CODE1
                  @ 12,18 SAY MFRT_NAME1
                  MDO_THIS = .F.
               ENDIF
            ENDDO 
            
            IF MSALESMAN <> SPACE(2)
               @ 14,1 SAY '    SALESPERSON: '
               @ 14,18 SAY MSAL_NAME
               @ 14,52 GET MSALE_COM1 PICTURE '###,###.##'
               @ 14,67 GET MSALE_COM2 PICTURE '###,###.##'
               READ
            ENDIF
            
            **RON MONTGOMERY CHANGES
            **@ 15,1 SAY 'INTERCOMP SALMN:'
            @ 15,1 SAY '3RD PRTY CNTRCT:'
            MEDIT = .T.
            DO WHILE MEDIT
               @ 15,18 GET MSAL2_NAME PICTURE '@!'
               READ
               IF MSAL2_NAME = SPACE(32)
                  @ 15,18 SAY MSAL2_NAME
                  MEDIT = .F.
                  LOOP
               ENDIF
               STORE MSAL2_NAME TO MNAME
               MNAME_FD = .F.
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
               **DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
               SEEK TRIM(MNAME)
               IF EOF()
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  **@ 24,1 SAY 'INTERCOMPANY SALESPERSON NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
                  @ 24,1 SAY 'THIRD PARTY CONTRACTOR   NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
                  READ
                  @ 24,0 CLEAR
               ELSE
                  STORE NAME TO MSAL2_NAME
                  STORE SALE_CODE TO MSAL_CODE2
                  @ 15,18 SAY MSAL2_NAME
                  MEDIT = .F.
               ENDIF
               
            ENDDO
            
            IF MSAL2_NAME <> SPACE(32)
               @ 15,52 GET MSAL2_COM1 PICTURE '###,###.##'
               @ 15,67 GET MSAL2_COM2 PICTURE '###,###.##'
               READ
            ENDIF
            
            ***** THIRD PARTY COMMISSIONS
            
            @ 16,1 SAY 'THIRD PARTY COM:'
            MEDIT = .T.
            DO WHILE MEDIT
               @ 16,18 GET MCOM_NAME PICTURE '@!'
               READ
               IF MCOM_NAME = SPACE(32)
                  @ 16,18 SAY MCOM_NAME
                  MEDIT = .F.
                  LOOP
               ENDIF
               STORE MCOM_NAME TO MNAME
               MNAME_FD = .F.
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
               SEEK TRIM(MCOM_NAME)
               IF EOF()
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  @ 24,1 SAY 'THIRD PARTY PAYEE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
                  READ
                  @ 24,0 CLEAR
               ELSE
                  STORE NAME TO MCOM_NAME
                  STORE COM_CODE TO MCOM_CODE
                  @ 16,18 SAY MCOM_NAME
                  MEDIT = .F.
               ENDIF
            ENDDO
            IF MCOM_NAME <> SPACE(32)
               @ 16,52 GET MCOM_COM1 PICTURE '###,###.##'
               @ 16,67 GET MCOM_COM2 PICTURE '###,###.##'
               READ
            ENDIF
            
            @ 17,1 SAY 'THIRD PARTY COM:'
            MEDIT = .T.
            DO WHILE MEDIT
               @ 17,18 GET MCOM_NAME2 PICTURE '@!'
               READ
               IF MCOM_NAME2 = SPACE(32)
                  @ 17,18 SAY MCOM_NAME2
                  MEDIT = .F.
                  LOOP
               ENDIF
               STORE MCOM_NAME2 TO MNAME
               MNAME_FD = .F.
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
               SEEK TRIM(MCOM_NAME2)
               IF EOF()
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  @ 24,1 SAY 'THIRD PARTY PAYEE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
                  READ
                  @ 24,0 CLEAR
               ELSE
                  STORE NAME TO MCOM_NAME2
                  STORE COM_CODE TO MCOM_CODE2
                  @ 17,18 SAY MCOM_NAME2
                  MEDIT = .F.
               ENDIF
            ENDDO
            IF MCOM_NAME2 <> SPACE(32)
               @ 17,52 GET MCOM2_COM1 PICTURE '###,###.##'
               @ 17,67 GET MCOM2_COM2 PICTURE '###,###.##'
               READ
            ENDIF
            @ 18,1 SAY '  MISCELLANEOUS:'
            @ 18,52 GET MMISC_AMT1 PICTURE '###,###.##'
            @ 18,67 GET MMISC_AMT2 PICTURE '###,###.##'
            READ
            MGROSS1 = (MTOT_SEL1 + MCUS_PAL1) - (MTOT_PUR1 + MSUP_PAL1)
            MTOT_NET1 = MGROSS1 - M1ST_FRT1 - MFRT_PAL1 - M2ND_FRT1 - MSALE_COM1 - MSAL2_COM1 - MCOM_COM1 - MCOM2_COM1 - MMISC_AMT1
            MGROSS2 = (MTOT_SEL2 + MCUS_PAL2) - (MTOT_PUR2 + MSUP_PAL2)
            MTOT_NET2 = MGROSS2 - M1ST_FRT2 - MFRT_PAL2 - M2ND_FRT2 - MSALE_COM2 - MSAL2_COM2 - MCOM_COM2 - MCOM2_COM2 - MMISC_AMT2
            @ 19,52 TO 19,61
            @ 19,67 TO 19,76
            @ 20,1 SAY '            NET:'
            @ 20,52 GET MTOT_NET1 PICTURE '###,###.##'
            @ 20,67 GET MTOT_NET2 PICTURE '###,###.##'
            STORE 1 TO MACTION
            @ 24,0 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue     2. Edit      3. Cancel Entry'
            @ 24,9 GET MACTION PICTURE '9' range 1,3
            READ
            IF MACTION <> 2
               MEDIT_ENT = .F.
            ENDIF
         ENDDO
         
         IF MMORE_ENT 
            IF MACTION <> 3
               
               SELECT E
               DO FOX_USE WITH "DAILYJRN INDEX JRN_MO, JRN_PO, JRN_TRAN, POSTED", .F.
               DO FILELOCK
               
               *** PUT IN FIRST ENTRY
               APPEND BLANK
               REPLACE salesman   WITH MSALESMAN  
               REPLACE po_nbr     WITH MPO_NBR    
               REPLACE po_suffix  WITH MPO_SUFFIX 
               REPLACE RSUPCODE   WITH MRSUPCODE
               REPLACE bbuycode   WITH MBBUYCODE  
               REPLACE tot_sell   WITH MTOT_SEL1  
               REPLACE CUS_PALL   WITH MCUS_PAL1
               REPLACE TOT_PURCH  WITH MTOT_PUR1 
               REPLACE SUP_PALL   WITH MSUP_PAL1
               REPLACE TOT_NET    WITH MTOT_NET1
               REPLACE GROSS      WITH MGROSS1
               REPLACE FRT_CODE1  WITH MFRT_CODE1
               REPLACE FRT_AMT1   WITH M1ST_FRT1 
               REPLACE FRT_PALL   WITH MFRT_PAL1
               REPLACE COM_CODE   WITH MCOM_CODE
               REPLACE COMM_AMT   WITH MCOM_COM1 
               REPLACE COMM_AMT2  WITH MCOM2_COM1
               REPLACE SALE_COMM  WITH MSALE_COM1
               REPLACE SAL_CODE2  WITH MSAL_CODE2 
               REPLACE SALE2_AMT  WITH MSAL2_COM1
               
               REPLACE SAL_CODE3  WITH MSAL_CODE3
               REPLACE SALE3_AMT  WITH MSAL3_COM1
               REPLACE MISC_AMT   WITH MMISC_AMT1
               IF VAL(MINV_NBR) < 10000
                  MINV_NBR = STR(VAL(MINV_NBR),5)    
               ENDIF
               REPLACE INV_NBR    WITH MINV_NBR   
               REPLACE TRAN_DATE  WITH MPOST_DATE   
               REPLACE SHORT_FLG   WITH 'Y'
               REPLACE JRNL_DATE   WITH MPOST_DATE
               REPLACE TRAN_MO     WITH MTRAN_MO
               REPLACE TRAN_YR     WITH MTRAN_YR
               REPLACE INV_COR     WITH 'C'
               REPLACE SEQ         WITH '1'
               **** PUT IN THE NEW ENTRY IF THERE NEEDS TO BE 
               IF MTOT_PUR2 <> 0 .OR. MTOT_SEL2 <> 0 .OR. M1ST_FRT2 <> 0 .OR. M2ND_FRT2 <> 0 ;
                  .OR. MSALE_COM2 <> 0 .OR. MSAL2_COM2 <> 0 .OR. MCOM_COM2 <> 0 .OR. MCOM2_COM2 <> 0 .OR. MMISC_AMT2 <> 0 ;
                  .OR. MCUS_PAL2 <> 0 .OR. MSUP_PAL2 <> 0 .OR. MFRT_PAL2 <> 0
                  APPEND BLANK
                  REPLACE salesman   WITH MSALESMAN  
                  REPLACE po_nbr     WITH MPO_NBR    
                  REPLACE po_suffix  WITH MPO_SUFFIX 
                  REPLACE RSUPCODE   WITH MRSUPCODE
                  REPLACE bbuycode   WITH MBBUYCODE  
                  REPLACE tot_sell   WITH MTOT_SEL2  
                  REPLACE CUS_PALL   WITH MCUS_PAL2
                  REPLACE TOT_PURCH  WITH MTOT_PUR2 
                  REPLACE SUP_PALL   WITH MSUP_PAL2
                  REPLACE TOT_NET    WITH MTOT_NET2
                  REPLACE GROSS      WITH MGROSS2
                  REPLACE FRT_CODE1  WITH MFRT_CODE1
                  REPLACE FRT_AMT1   WITH M1ST_FRT2 
                  REPLACE FRT_PALL   WITH MFRT_PAL2
                  REPLACE COM_CODE   WITH MCOM_CODE
                  REPLACE COMM_AMT   WITH MCOM_COM2 
                  REPLACE COMM_AMT2  WITH MCOM2_COM2
                  REPLACE SALE_COMM  WITH MSALE_COM2
                  REPLACE SAL_CODE2  WITH MSAL_CODE2 
                  REPLACE SALE2_AMT  WITH MSAL2_COM2
                  REPLACE SAL_CODE3  WITH MSAL_CODE3 
                  REPLACE SALE3_AMT  WITH MSAL3_COM2
                  REPLACE MISC_AMT   WITH MMISC_AMT2
                  REPLACE INV_NBR    WITH MINV_NBR   
                  REPLACE TRAN_DATE  WITH MPOST_DATE   
                  REPLACE SHORT_FLG   WITH 'Y'
                  REPLACE JRNL_DATE   WITH DATE()
                  REPLACE TRAN_MO     WITH MTRAN_MO   
                  REPLACE TRAN_YR     WITH MTRAN_YR
                  REPLACE INV_COR     WITH 'C'
                  REPLACE SEQ WITH '2'
               ENDIF
               UNLOCK
            ENDIF
         ENDIF
      ENDDO
      * EOF: MANUAL.PRG
      MSELECTION = ' '
   CASE VAL(MSELECTION) =  8    
      * DO POST_BAL (USED TO BE)
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 02,00 SAY MPROGRAM + ' - POST MONTH ENDING BALANCES'
      @ 02,70 SAY DATE()
      @ 3,0 to 24,79
      STORE ' ' TO MFRT_X, MSUP_X, MCUS_X, MCOM_X, MBBK_X
      STORE 0 TO MTRAN_MO
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 05,5 SAY "SELECT WITH AN 'X' THE BALANCES TO POST (CAN SELECT MORE THAN ONE)"
         @ 08,5 SAY '    FREIGHT LEDGER: ' GET MFRT_X PICTURE '@!'
         @ 10,5 SAY '   PURCHASE LEDGER: ' GET MSUP_X PICTURE '@!'
         @ 12,5 SAY '      SALES LEDGER: ' GET MCUS_X PICTURE '@!'
         IF MCOMPANY <> 'DIVISION'
            @ 14,5 SAY 'COMMISSIONS LEDGER: ' GET MCOM_X PICTURE '@!'
         ENDIF
         @ 16,5 SAY '   BILLBACK LEDGER: ' GET MBBK_X PICTURE '@!'
         @ 18,5 SAY '    MONTH TO CLOSE: ' GET MTRAN_MO PICTURE '##' RANGE 1,12
         
         STORE 1 TO MACTION
         @ 24,0 SAY 'Action: ' + STR(MACTION,1)
         @ 24,12 SAY '1. Continue      2. Edit     3. Cancel'
         @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
         
         READ
         IF MFRT_X <> ' ' .AND. MFRT_X <> 'X'
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY "FREIGHT LEDGER SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF MSUP_X <> ' ' .AND. MSUP_X <> 'X'
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY "PURCHASE LEDGER  SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF MCUS_X <> ' ' .AND. MCUS_X <> 'X'
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY "SALES LEDGER  SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF MCOM_X <> ' ' .AND. MCOM_X <> 'X'
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY "COMMISSION LEDGER  SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF   
         IF MBBK_X <> ' ' .AND. MBBK_X <> 'X'
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY "BILLBACK  LEDGER  SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF   
      ENDDO
      IF MACTION = 3
         LOOP  
      ENDIF
      MNEXT_MO = MTRAN_MO + 1
      IF MNEXT_MO = 13
         MNEXT_MO = 1
      ENDIF
      STORE SUBSTR(STR(MTRAN_MO + 100,3),2) TO MTRAN_MO
      STORE SUBSTR(STR(MNEXT_MO + 100,3),2) TO MNEXT_MO
      STORE STR(YEAR(DATE()),4) TO MNEXT_YR
      IF MTRAN_MO = '12'
         MTRAN_YR = STR(VAL(MNEXT_YR)-1,4)
      ELSE
         MTRAN_YR = MNEXT_YR
      ENDIF
      IF MSUP_X = 'X'
         SELECT A
         DO FOX_USE WITH "SUPLED INDEX SUPLED, SUPMATCH, SUPNOMAT", .F.
         DO FILELOCK
         MNOT_DONE = .T.
         SEEK MTRAN_YR + MTRAN_MO 
         
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. MNOT_DONE
            STORE LED_CODE TO MLED_CODE
            MBALANCE = 0
            DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. LED_CODE = MLED_CODE
               MBALANCE = MBALANCE + AMOUNT
               SKIP
               IF EOF()
                  STORE 0 TO MRECNO
               ELSE
                  STORE RECNO() TO MRECNO
               ENDIF
            ENDDO
            IF MBALANCE <> 0
               APPEND BLANK
               REPLACE RSUPCODE WITH MLED_CODE
               REPLACE LED_CODE WITH MLED_CODE
               REPLACE TRAN_MO WITH MNEXT_MO
               REPLACE TRAN_YR WITH MNEXT_YR
               REPLACE AMOUNT WITH MBALANCE
            ENDIF
            IF MRECNO = 0
               MNOT_DONE = .F.
            ELSE
               GOTO MRECNO
            ENDIF
         ENDDO
         
         DO FOX_USE WITH "SUPLED INDEX SUPMATCH, SUPNOMAT", .F.
         DO FILELOCK
         DO WHILE .NOT. EOF() 
            IF MATCH_FLG <> ' '
               SKIP
               LOOP
            ENDIF
            IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
               REPLACE MATCH_FLG WITH 'Y'
               SKIP
               LOOP
            ENDIF
            IF AMOUNT = 0
               REPLACE MATCH_FLG WITH 'Y'
               SKIP
               LOOP
            ENDIF
            
            STORE LED_CODE TO MLED_CODE
            MSALESMAN = SALESMAN 
            MPO_NBR = PO_NBR      
            MPO_SUFFIX = PO_SUFFIX
            MTOT = 0         
            MRECNO = RECNO()          
            MCONT = .T.
            MSTOP_REC = 0   
            DO WHILE .NOT. EOF() .AND. LED_CODE = MLED_CODE .AND. SALESMAN = MSALESMAN ;
               .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. MCONT
               IF MATCH_FLG <> ' '
                  SKIP
                  LOOP
               ENDIF
               MTOT = MTOT + AMOUNT
               IF MTOT = 0 .OR. (MTOT > -.001 .AND. MTOT < 0) .OR. (MTOT < .001 .AND. MTOT > 0)
                  MCONT = .F.
                  STORE RECNO() TO MSTOP_REC
                  LOOP
               ENDIF
               SKIP
            ENDDO
            IF MSTOP_REC <> 0
               GOTO MRECNO   
               MCONT = .T.
               DO WHILE .NOT. EOF() .AND. LED_CODE = MLED_CODE .AND. SALESMAN = MSALESMAN ;
                  .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. MCONT     
                  IF MATCH_FLG <> ' '
                     SKIP
                     LOOP
                  ENDIF
                  REPLACE MATCH_FLG WITH 'Y'
                  IF RECNO() = MSTOP_REC
                     MCONT = .F.
                  ENDIF
                  SKIP
               ENDDO
            ENDIF
         ENDDO
         UNLOCK
         
         IF MPROG_CODE = 2
            DO FOX_USE WITH "INVLED INDEX INVLED", .F.
            DO FILELOCK
            MNOT_DONE = .T.
            SEEK MTRAN_YR + MTRAN_MO 
            MBALANCE = 0
            
            DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. .NOT. EOF()
               MBALANCE = MBALANCE + AMOUNT
               SKIP
            ENDDO
            
            APPEND BLANK
            REPLACE TRAN_MO WITH MNEXT_MO
            REPLACE TRAN_YR WITH MNEXT_YR
            REPLACE AMOUNT WITH MBALANCE
            UNLOCK
         ENDIF
         
         USE
         
      ENDIF
      IF MCUS_X = 'X'   
         SELECT A 
         DO FOX_USE WITH "CUSLED INDEX CUSLED, CUSMATCH, CUSNOMAT", .F.
         DO FILELOCK
         MNOT_DONE = .T.
         SEEK MTRAN_YR + MTRAN_MO 
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. MNOT_DONE
            STORE LED_CODE TO MLED_CODE
            MBALANCE = 0
            DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. LED_CODE = MLED_CODE
               MBALANCE = MBALANCE + AMOUNT
               SKIP
               IF EOF()
                  STORE 0 TO MRECNO
               ELSE
                  STORE RECNO() TO MRECNO
               ENDIF
            ENDDO
            IF MBALANCE <> 0
               APPEND BLANK
               REPLACE BBUYCODE WITH MLED_CODE
               REPLACE LED_CODE WITH MLED_CODE
               REPLACE TRAN_MO WITH MNEXT_MO
               REPLACE TRAN_YR WITH MNEXT_YR
               REPLACE AMOUNT WITH MBALANCE
            ENDIF
            IF MRECNO = 0
               MNOT_DONE = .F.
            ELSE
               GOTO MRECNO
            ENDIF
         ENDDO
         
         DO FOX_USE WITH "CUSLED INDEX CUSMATCH, CUSNOMAT", .F.
         DO FILELOCK
         DO WHILE .NOT. EOF() 
            IF MATCH_FLG <> ' '
               SKIP
               LOOP
            ENDIF
            IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
               REPLACE MATCH_FLG WITH 'Y'
               SKIP
               LOOP
            ENDIF
            IF AMOUNT = 0
               REPLACE MATCH_FLG WITH 'Y'
               SKIP
               LOOP
            ENDIF
            
            STORE LED_CODE TO MLED_CODE
            MSALESMAN = SALESMAN 
            MPO_NBR = PO_NBR      
            MPO_SUFFIX = PO_SUFFIX
            STORE INV_NBR TO MINV_NBR
            STORE 0 TO MTOT
            STORE RECNO() TO MRECNO   
            MCONT = .T.
            MSTOP_REC = 0   
            DO WHILE .NOT. EOF() .AND. LED_CODE = MLED_CODE .AND. SALESMAN = MSALESMAN ;
               .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. MCONT
               IF MATCH_FLG <> ' '
                  SKIP
                  LOOP
               ENDIF
               MTOT = MTOT + AMOUNT
               IF MTOT = 0 .OR. (MTOT > -.001 .AND. MTOT < 0) .OR. (MTOT < .001 .AND. MTOT > 0)
                  MCONT = .F.
                  STORE RECNO() TO MSTOP_REC
                  LOOP
               ENDIF
               SKIP
            ENDDO
            IF MSTOP_REC <> 0
               GOTO MRECNO   
               MCONT = .T.
               DO WHILE .NOT. EOF() .AND. LED_CODE = MLED_CODE .AND. SALESMAN = MSALESMAN ;
                  .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. MCONT     
                  IF MATCH_FLG <> ' '
                     SKIP
                     LOOP
                  ENDIF
                  REPLACE MATCH_FLG WITH 'Y'
                  IF RECNO() = MSTOP_REC
                     MCONT = .F.
                  ENDIF
                  SKIP
               ENDDO
            ENDIF
         ENDDO
         UNLOCK
         USE
      ENDIF
      IF MFRT_X =  'X'  
         SELECT A
         DO FOX_USE WITH "FRTLED INDEX FRTLED, FRTMATCH, FRTNOMAT", .F.
         DO FILELOCK
         MNOT_DONE = .T.
         SEEK MTRAN_YR + MTRAN_MO 
         
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. MNOT_DONE
            STORE FRT_CODE TO MFRT_CODE
            MBALANCE = 0
            DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. FRT_CODE = MFRT_CODE
               MBALANCE = MBALANCE + AMOUNT
               SKIP
               IF EOF()
                  STORE 0 TO MRECNO
               ELSE
                  STORE RECNO() TO MRECNO
               ENDIF
            ENDDO
            IF MBALANCE <> 0
               APPEND BLANK
               REPLACE FRT_CODE WITH MFRT_CODE
               REPLACE TRAN_MO WITH MNEXT_MO
               REPLACE TRAN_YR WITH MNEXT_YR
               REPLACE AMOUNT WITH MBALANCE
            ENDIF
            IF MRECNO = 0
               MNOT_DONE = .F.
            ELSE
               GOTO MRECNO
            ENDIF
         ENDDO
         
         DO FOX_USE WITH "FRTLED INDEX FRTMATCH, FRTNOMAT", .F.
         DO FILELOCK
         
         DO WHILE .NOT. EOF() 
            IF MATCH_FLG <> ' '
               SKIP
               LOOP
            ENDIF
            IF DTOC(POST_DATE) = '  /  /  ' .AND. DTOC(TRAN_DATE) = '  /  /  '
               REPLACE MATCH_FLG WITH 'Y'
               SKIP
               LOOP
            ENDIF
            IF AMOUNT = 0
               REPLACE MATCH_FLG WITH 'Y'
               SKIP
               LOOP
            ENDIF
            
            STORE FRT_CODE TO MFRT_CODE
            MSALESMAN = SALESMAN 
            MPO_NBR = PO_NBR      
            MPO_SUFFIX = PO_SUFFIX
            MTOT = 0         
            MRECNO = RECNO()          
            MCONT = .T.
            MSTOP_REC = 0   
            DO WHILE .NOT. EOF() .AND. FRT_CODE = MFRT_CODE .AND. SALESMAN = MSALESMAN ;
               .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. MCONT
               IF MATCH_FLG <> ' '
                  SKIP
                  LOOP
               ENDIF
               MTOT = MTOT + AMOUNT
               IF MTOT = 0 .OR. (MTOT > -.001 .AND. MTOT < 0) .OR. (MTOT < .001 .AND. MTOT > 0)
                  MCONT = .F.
                  STORE RECNO() TO MSTOP_REC
                  LOOP
               ENDIF
               SKIP
            ENDDO
            IF MSTOP_REC <> 0
               GOTO MRECNO   
               MCONT = .T.
               DO WHILE .NOT. EOF() .AND. FRT_CODE = MFRT_CODE .AND. SALESMAN = MSALESMAN ;
                  .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. MCONT     
                  IF MATCH_FLG <> ' '
                     SKIP
                     LOOP
                  ENDIF
                  REPLACE MATCH_FLG WITH 'Y'
                  IF RECNO() = MSTOP_REC
                     MCONT = .F.
                  ENDIF
                  SKIP
               ENDDO
            ENDIF
         ENDDO
         UNLOCK
         USE
      ENDIF
      IF MCOM_X = 'X'   
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
         DO FILELOCK
         
         MNOT_DONE = .T.
         SEEK MTRAN_YR + MTRAN_MO 
         
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. MNOT_DONE
            STORE COM_CODE TO MCOM_CODE
            STORE COM_TYPE TO MCOM_TYPE
            MBALANCE = 0
            DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. MTRAN_MO = TRAN_MO .AND. COM_TYPE = MCOM_TYPE .AND. COM_CODE = MCOM_CODE
               MBALANCE = MBALANCE + AMOUNT
               SKIP
               IF EOF()
                  STORE 0 TO MRECNO
               ELSE
                  STORE RECNO() TO MRECNO
               ENDIF
            ENDDO
            IF MBALANCE <> 0
               APPEND BLANK
               REPLACE COM_CODE WITH MCOM_CODE 
               REPLACE COM_TYPE WITH MCOM_TYPE
               REPLACE AMOUNT WITH MBALANCE
               REPLACE TRAN_MO WITH MNEXT_MO
               REPLACE TRAN_YR WITH MNEXT_YR
               REPLACE APRVD_FLG WITH 'Y'
               REPLACE COM_PD WITH 'Y'
            ENDIF
            IF MRECNO = 0
               MNOT_DONE = .F.
            ELSE
               GOTO MRECNO
            ENDIF
         ENDDO
         UNLOCK
         USE
      ENDIF   
      IF MBBK_X = 'X'   
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.BBKLED INDEX &MMASTDBF.BBKLED, &MMASTDBF.BBKPD", .F.
         DO FILELOCK
         
         MNOT_DONE = .T.
         SEEK MTRAN_YR + MTRAN_MO 
         
         DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. MNOT_DONE
            STORE LED_CODE TO MLED_CODE
            STORE COM_TYPE TO MCOM_TYPE
            MBALANCE = 0
            DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. MTRAN_MO = TRAN_MO .AND. COM_TYPE = MCOM_TYPE .AND. LED_CODE = MLED_CODE
               MBALANCE = MBALANCE + AMOUNT
               SKIP
               IF EOF()
                  STORE 0 TO MRECNO
               ELSE
                  STORE RECNO() TO MRECNO
               ENDIF
            ENDDO
            IF MBALANCE <> 0
               APPEND BLANK
               REPLACE COM_CODE WITH MLED_CODE
               REPLACE COM_TYPE WITH MCOM_TYPE
               REPLACE LED_CODE WITH MLED_CODE
               REPLACE AMOUNT WITH MBALANCE
               REPLACE TRAN_MO WITH MNEXT_MO
               REPLACE TRAN_YR WITH MNEXT_YR
               REPLACE APRVD_FLG WITH 'Y'
               REPLACE COM_PD WITH 'Y'
            ENDIF
            IF MRECNO = 0
               MNOT_DONE = .F.
            ELSE
               GOTO MRECNO
            ENDIF
         ENDDO
         UNLOCK
         USE
      ENDIF   
      **** END OF FILE FOR POST ENDING BALANCES
      MSELECTION = ' '
   ENDCASE
   CLOSE DATA
   
ENDDO
SET PROC TO PO_PROC
RETURN

PROCEDURE SPRDHD

IF MLINE <> 99
   EJECT
ENDIF

MPAGE_NO = MPAGE_NO + 1
@ 2,60 SAY MCOMPANY
@ 3,1 SAY 'Page'
@ 3,06 say mpage_no picture '99'
@ 3,40 SAY 'MONTHLY ' + MINVEN + MWORD + ' SUMMARY FOR ' + MMONTH
@ 3,126 SAY DTOC(DATE())
@ 5,1 SAY 'INV #'
@ 5,9 SAY 'PO NBR'
@ 5,19 SAY 'PROD'
@ 5,27 SAY 'CUSTOMR'
@ 5,38 SAY 'TOT SELL'
@ 5,48 SAY 'CUS FRT'
@ 5,57 SAY 'SUPPLIER'
@ 5,68 SAY 'TOT PURCH'
@ 5,79 SAY 'SUP FRT'
@ 5,90 SAY 'FREIGHT'
@ 5,100 SAY 'FRT PALL'    
@ 5,113 SAY 'MISC' 
@ 5,121 SAY 'BILL BK'
@ 5,135 SAY 'COMM'
@ 5,141 SAY 'BROKER'
@ 5,154 SAY 'TOT NET'
@ 5,01 SAY REPLICATE('_',160)
MLINE = 7
RETURN

PROCEDURE SPRDSAY
@ MLINE,1 SAY MINV_NBR
IF MSALESMAN <> SPACE(2) 
   @ MLINE,8 SAY MSALESMAN + '-'
ENDIF
@ MLINE,11 SAY MPO_NBR
IF MPO_SUFFIX <> ' '
   @ MLINE,15 SAY '-' + MPO_SUFFIX
ENDIF
IF BROKERAGE = 'X'
   @  MLINE,19 SAY 'BROKER'
ELSE
   @ MLINE,19 SAY MPROD
ENDIF
@ MLINE,27 SAY MBBUYNAME
@ MLINE,35 SAY TOT_SELL PICTURE '9999999.99'
@ MLINE,46 SAY CUS_PALL PICTURE '@Z 999999.99'
@ MLINE,57 SAY MRSUPNAME
@ MLINE,66 SAY TOT_PURCH PICTURE '9999999.99'
@ MLINE,77 SAY SUP_PALL PICTURE '@Z 999999.99'
@ MLINE,87  SAY MFRT_AMT PICTURE '9999999.99'
@ MLINE,99  SAY FRT_PALL PICTURE '@Z 99999.99'
@ MLINE,108 SAY MISC_AMT PICTURE '@Z 999999.99'
@ MLINE,130 SAY SALE_COMM PICTURE '999999.99'
@ MLINE,141 SAY MSAL_NAME
@ MLINE,150 SAY TOT_NET PICTURE '99999999.99'
RETURN


* EOF: ACCTMENU.PRG

*Formatted by: ToolBox Ver. 1.2  on 12/8/15 at 11:13 AM.
