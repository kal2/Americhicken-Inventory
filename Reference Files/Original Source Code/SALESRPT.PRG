***************
* Program.: SALESRPT.PRG
* Author..: GRACE KELLER
* Date....: 12/09/87
* Notice..: Copyright (C) 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SALES REPORT MENU    
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
STORE ' ' TO MSELECTION
STORE ' ' TO MACTION

DO WHILE VAL(MSELECTION) <> 9  
   
   CLEAR
   @ 01,00 SAY MCOMPANY
   @ 02,00 SAY MPROGRAM + ' - SALES REPORTS MENU'
   @ 02,70 SAY DATE()
   @ 3,0 to 25,79
   
   @ 04,09 SAY ' 1 - MONTHLY SPREADSHEET TOTALS (INVOICES & CORRECTIONS)'                                 
   @ 06,09 SAY ' 2 - DAILY SALES DETAIL SUMMARY (INVOICES ONLY)'
   @ 08,09 SAY ' 3 - DAILY SPREADSHEET INVOICE REGISTER -(PRINTED LEDGER TYPE REPORT)'
   @ 09,09 SAY '     (NOTE: ABOVE REPORT MUST PRINT ON WIDE PAPER)'
   @ 11,09 SAY ' 4 - DATE-TO-DATE SPREADSHEET TOTALS (INVOICES & CORRECTIONS)'
   @ 13,09 SAY ' 5 - DATE-TO-DATE SALESPERSON SUMMARY'                     
   @ 15,09 say " 6 - SALESPERSON DETAIL REPORT (LISTS PO'S - BY MONTH)"
   @ 17,09 SAY ' 7 - CUSTOMER SALES DOLLARS - OPTIONAL CUSTOMER STATE'
   ****@ 17,10 SAY ' 7 - SALESPERSON COMPARISON REPORTS (PERCENTAGE/AGING/INTEREST)'
   @ 19,09 SAY ' 8 - PRINT DETAIL SHIPMENT INFORMATION'  
   @ 21,09 SAY ' 9 - RETURN TO REPORTS MENU'
   
   STORE ' ' TO MSELECTION
   @ 23,01 SAY 'CHOICE: '
   @ 23,10 GET MSELECTION picture '#'
   READ
   
   DO CASE
      
   CASE VAL(MSELECTION) = 1     
      * Notes...: DAILY SALES REPORT         
      MTITLE = ' - MONTHLY SPREADSHEET TOTALS (INVOICES & CORRECTIONS)'    
      
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE DATE() TO MDATE
      STORE 'D' TO MDISP_PRT
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 08,5 SAY '     ENTER ENDING REPORT DATE: '
         @ 08,37 GET MDATE
         @ 10,5 SAY 'DISPLAY OR PRINT REPORT (D/P):'
         @ 10,37 GET MDISP_PRT PICTURE '@!'
         
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
         MPAGE_LEN = 20
      ENDIF
      
      STORE MONTH(MDATE) TO MMONTH
      MMONTH = MMONTH + 100
      STORE SUBSTR(STR(MMONTH,3),2) TO MMONTH
      
      STORE YEAR(MDATE) TO MYEAR
      STORE STR(MYEAR,4) TO MYEAR
      
      STORE DAY(MDATE) TO MDAY
      MDAY = MDAY + 100
      STORE SUBSTR(STR(MDAY,3),2) TO MDAY
      
      SELECT A
      DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
      
      SEEK MYEAR + MMONTH
      IF EOF()
         @ 4,1 CLEAR TO 21,78 
         @ 10,5 SAY 'THERE IS NO ACTIVITY DATA ON FILE FOR THIS MONTH'
         STORE ' ' TO MWAIT
         @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
         READ
         RETURN
      ENDIF
      
      MPAGE_NO = 0
      MLINE = 99 
      @ 19,16 SAY 'CALULATING........'
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
      
      MMTD_TOT = 0 
      MDAILY_TOT = 0
      DO WHILE .NOT. EOF() .AND. TRAN_MO = MMONTH .AND. TRAN_YR = MYEAR
         IF SHIP_DATE > MDATE
            SKIP
            LOOP
         ENDIF
         MMTD_TOT = MMTD_TOT + TOT_NET + SALE2_NET + SALE3_NET
         SKIP
      ENDDO
      IF MLINE > MPAGE_LEN
         IF MLINE = 99 .AND. MDISP_PRT <> 'P'
            CLEAR
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 2,27 SAY MCOMPANY
         @ 3,1 SAY 'Page'
         @ 3,06 say mpage_no picture '99'
         @ 3,20 SAY 'MONTHLY SPREADSHEET TOTALS'
         @ 3,70 SAY DTOC(DATE())
         IF MDISP_PRT = 'P'
            @ 3,01 SAY REPLICATE('_',77)
         ENDIF
         MLINE = 7
      ENDIF
      @ MLINE,10 SAY 'ENDING SALES DATE         M-T-D NET SALES'
      MLINE = MLINE + 2
      @ MLINE,14 SAY MDATE
      *@ MLINE,31 SAY MDAILY_TOT PICTURE '9,999,999.99' 
      @ MLINE,38 SAY MMTD_TOT PICTURE '99,999,999.99'
      IF MDISP_PRT = 'P'
         MLINE = MLINE + 1
         @ mline+1,1 say ' '
         eject
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
      
   CASE VAL(MSELECTION) = 2     
      DO DAILYSUM
      
   CASE VAL(MSELECTION) =  3    
      * Notes...: DAILY detaIl SALES REPORT         
      MTITLE = ' - DAILY SPREADSHEET INVOICE REGISTER'
      
      CLEAR
      @  1, 1  SAY MCOMPANY      
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE DATE() TO MDATE
      STORE 'P' TO MDISP_PRT
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 08,5 SAY '          ENTER BUSINESS DATE: '
         @ 08,37 GET MDATE
         *  @ 10,5 SAY 'DISPLAY OR PRINT REPORT (D/P):'
         *  @ 10,37 GET MDISP_PRT PICTURE '@!'
         
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
      
      *DO PRT_132
      *DO PRT_SET
      IF MPRT_ACT <> 'C'
         RETURN
      ENDIF
      MPAGE_LEN = 44
      
      STORE MONTH(MDATE) TO MMONTH
      MMONTH = MMONTH + 100
      STORE SUBSTR(STR(MMONTH,3),2) TO MMONTH
      
      STORE YEAR(MDATE) TO MYEAR
      STORE STR(MYEAR,4) TO MYEAR
      
      STORE DAY(MDATE) TO MDAY
      MDAY = MDAY + 100
      STORE SUBSTR(STR(MDAY,3),2) TO MDAY
      
      SELECT A
      DO FOX_USE WITH "INV_HEAD INDEX INV_DATE", .F.
      SEEK MYEAR + MMONTH + MDAY
      IF EOF()
         @ 4,1 CLEAR TO 21,78 
         @ 10,5 SAY 'THERE IS NO SALES INVOICING DATA ON FILE FOR THIS DATE'
         STORE ' ' TO MWAIT
         @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
         READ
         RETURN
      ELSE  
         STORE RECNO() TO MSTRT_REC
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
         ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
         
         *** LANDSCAPE MODE
         ?? CHR(27) + '&l1O'
         
         *** LEGAL SIZE PAPER
         ?? CHR(27) + '&l3A'
         
      ENDIF
      MINVN = .F.
      MPURCH = 0 
      MSELL = 0
      MTOTAL = 0
      MCOMM = 0
      SEEK MYEAR + MMONTH + MDAY
      
      DO WHILE .NOT. EOF() .AND. MYEAR = SUBSTR(DTOC(INV_DATE),7) .AND. VAL(MMONTH) = VAL(SUBSTR(DTOC(INV_DATE),1,2)) .and. val(MDAY) = VAL(SUBSTR(DTOC(INV_DATE),4,2))
         STORE MONTH(SHIP_DATE) TO MMO   
         DO WHILE .NOT. EOF() .AND. MYEAR = SUBSTR(DTOC(INV_DATE),7) .AND. VAL(MMONTH) = VAL(SUBSTR(DTOC(INV_DATE),1,2)) .and. val(MDAY) = VAL(SUBSTR(DTOC(INV_DATE),4,2)) .AND. MONTH(SHIP_DATE) = MMO
            
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  EJECT
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 2,60 SAY MCOMPANY
               @ 3,1 SAY 'Page'
               *              @ 3,06 say mpage_no picture '99'
               @ 3,46 SAY 'DAILY SPREADSHEET DETAIL REPORT FOR ' + DTOC(MDATE)
               @ 3,128 SAY DTOC(DATE())
               @ 5,1 SAY 'INV NBR'
               @ 5,12 SAY 'P.O. NBR'
               @ 5,23 SAY 'DESCR'
               @ 5,31 SAY 'CUSTOMER'
               @ 5,44 SAY '  TOT SELL'
               @ 5,56 SAY 'CUST FRT'
               @ 5,66 SAY 'SUPPLIER'
               @ 5,80 SAY ' TOT PURCH'
               @ 5,92 SAY ' SUP FRT'
               @ 5,102 SAY '  FREIGHT'
               @ 5,113 SAY 'PALLETS'    
               @ 5,122 SAY '   MISC' 
               @ 5,132 SAY '     COMM'
               @ 5,144 SAY 'BROKR'
               @ 5,151 SAY 'TOT NET'
               @ 5,01 SAY REPLICATE('_',159)
               MLINE = 7
            ENDIF
            
            STORE SALESMAN TO MSALESMAN
            STORE PO_NBR TO MPO_NBR
            STORE PO_SUFFIX TO MPO_SUFFIX
            
            SELECT C
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF EOF()
               STORE 'NONE' TO MRSUPCODE, MBBUYCODE
            ELSE
               STORE RSUPCODE TO MRSUPCODE
               STORE BBUYCODE TO MBBUYCODE
               IF RSUPCODE = 'INVN' .OR. BBUYCODE = 'INVN'
                  MINVN = .T.
               ENDIF
            ENDIF
            
            SELECT D
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF .NOT. EOF()
               STORE SUBSTR(PROD_DESC,1,5) TO MPROD
            ELSE
               STORE SPACE(5) TO MPROD
            ENDIF
            
            SELECT B
            IF MRSUPCODE = 'NONE'
               STORE 'NONE' + SPACE(6) TO MRSUPNAME
            ELSE
               DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
               SEEK MRSUPCODE
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,10) TO MRSUPNAME
               ELSE 
                  STORE 'NOTONFILE ' TO MRSUPNAME
               ENDIF
            ENDIF
            
            IF MBBUYCODE = 'NONE'
               STORE 'NONE' + SPACE(56) TO MBBUYNAME
            ELSE  
               DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
               SEEK MBBUYCODE
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,10) TO MBBUYNAME
               ELSE 
                  STORE 'NOTONFILE ' TO MBBUYNAME
               ENDIF
            ENDIF
            
            IF MSALESMAN <> SPACE(2)
               DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               SEEK MSALESMAN
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,8) TO MSAL_NAME
               ELSE
                  STORE SPACE(08) TO MSAL_NAME
               ENDIF
            ELSE
               SELECT C
               STORE BROK_NAME TO MSAL_NAME
            ENDIF
            
            SELECT C
            IF SALESMAN <> SPACE(2)
               STORE SALESMAN + '-' + INV_NBR TO MINV_NBR
            ELSE
               STORE INV_NBR TO MINV_NBR
            ENDIF
            
            @ MLINE,1 SAY MINV_NBR
            IF MSALESMAN <> SPACE(2) 
               @ MLINE,12 SAY MSALESMAN + '-'
            ENDIF
            @ MLINE,15 SAY MPO_NBR
            IF MPO_SUFFIX <> ' '
               @ MLINE,19 SAY '-' + MPO_SUFFIX
            ENDIF
            IF BROKERAGE = 'X'
               @  MLINE,23 SAY 'BROKE'
            ELSE
               @ MLINE,23 SAY MPROD
            ENDIF
            @ MLINE,31 SAY MBBUYNAME
            @ MLINE,66 SAY MRSUPNAME
            IF MPROG_CODE = 2
               MFRT_AMT = FRT_AMT1 + FRT_AMT2 + FRT_AMT3 
            ELSE
               MFRT_AMT = FRT_AMT1            
            ENDIF
            @ MLINE,101 SAY MFRT_AMT PICTURE '999,999.99'
            @ MLINE,114 SAY FRT_PALL PICTURE '@Z 9999.99'
            @ MLINE,144 SAY MSAL_NAME
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
               MLINE = MLINE + 2
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,60 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  *                 @ 3,06 say mpage_no picture '99'
                  @ 3,46 SAY 'DAILY SPREADSHEET DETAIL REPORT FOR ' + DTOC(MDATE)
                  @ 3,128 SAY DTOC(DATE())
                  @ 5,1 SAY 'INV NBR'
                  @ 5,12 SAY 'P.O. NBR'
                  @ 5,23 SAY 'DESCR'
                  @ 5,31 SAY 'CUSTOMER'
                  @ 5,44 SAY '  TOT SELL'
                  @ 5,56 SAY 'CUST FRT'
                  @ 5,66 SAY 'SUPPLIER'
                  @ 5,80 SAY ' TOT PURCH'
                  @ 5,92 SAY ' SUP FRT'
                  @ 5,102 SAY '  FREIGHT'
                  @ 5,113 SAY 'PALLETS'    
                  @ 5,122 SAY '   MISC' 
                  @ 5,132 SAY '     COMM'
                  @ 5,144 SAY 'BROKR'
                  @ 5,151 SAY 'TOT NET'
                  @ 5,01 SAY REPLICATE('_',157)
                  MLINE = 7
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,144 SAY SUBSTR(MCOM_NAME,1,08)
            ENDIF
            
            IF COM_CODE2 <> SPACE(2) .AND. COMM_AMT2 <> 0
               STORE COM_CODE2 TO MCOM_CODE2
               SELECT B
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               
               SEEK MCOM_CODE2
               IF .NOT. EOF()
                  STORE NAME TO MCOM_NAME2
               ELSE  
                  STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME2
               ENDIF
               MLINE = MLINE + 2
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,60 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  *                 @ 3,06 say mpage_no picture '99'
                  @ 3,46 SAY 'DAILY SPREADSHEET DETAIL REPORT FOR ' + DTOC(MDATE)
                  @ 3,128 SAY DTOC(DATE())
                  @ 5,1 SAY 'INV NBR'
                  @ 5,12 SAY 'P.O. NBR'
                  @ 5,23 SAY 'DESCR'
                  @ 5,31 SAY 'CUSTOMER'
                  @ 5,44 SAY '  TOT SELL'
                  @ 5,56 SAY 'CUST FRT'
                  @ 5,66 SAY 'SUPPLIER'
                  @ 5,80 SAY ' TOT PURCH'
                  @ 5,92 SAY ' SUP FRT'
                  @ 5,102 SAY '  FREIGHT'
                  @ 5,113 SAY 'PALLETS'    
                  @ 5,122 SAY '   MISC' 
                  @ 5,132 SAY '     COMM'
                  @ 5,144 SAY 'BROKR'
                  @ 5,151 SAY 'TOT NET'
                  @ 5,01 SAY REPLICATE('_',157)
                  MLINE = 7
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,144 SAY SUBSTR(MCOM_NAME2,1,08)
            ENDIF
            
            IF COM_CODE3 <> SPACE(2) .AND. COMM_AMT3 <> 0
               STORE COM_CODE3 TO MCOM_CODE3
               SELECT B
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               
               SEEK MCOM_CODE3
               IF .NOT. EOF()
                  STORE NAME TO MCOM_NAME3
               ELSE  
                  STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME3
               ENDIF
               MLINE = MLINE + 2
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,60 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  *                 @ 3,06 say mpage_no picture '99'
                  @ 3,46 SAY 'DAILY SPREADSHEET DETAIL REPORT FOR ' + DTOC(MDATE)
                  @ 3,128 SAY DTOC(DATE())
                  @ 5,1 SAY 'INV NBR'
                  @ 5,12 SAY 'P.O. NBR'
                  @ 5,23 SAY 'DESCR'
                  @ 5,31 SAY 'CUSTOMER'
                  @ 5,44 SAY '  TOT SELL'
                  @ 5,56 SAY 'CUST FRT'
                  @ 5,66 SAY 'SUPPLIER'
                  @ 5,80 SAY ' TOT PURCH'
                  @ 5,92 SAY ' SUP FRT'
                  @ 5,102 SAY '  FREIGHT'
                  @ 5,113 SAY 'PALLETS'    
                  @ 5,122 SAY '   MISC' 
                  @ 5,132 SAY '     COMM'
                  @ 5,144 SAY 'BROKR'
                  @ 5,151 SAY 'TOT NET'
                  @ 5,01 SAY REPLICATE('_',157)
                  MLINE = 7
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,144 SAY SUBSTR(MCOM_NAME3,1,08)
            ENDIF
            
            SELECT C
            IF SAL_CODE2 <> SPACE(2) .AND. SALE2_AMT <> 0
               STORE SAL_CODE2 TO MSAL_CODE2
               **RON MONTGOMERY CHANGES
               SELECT B
               **DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               SEEK MSAL_CODE2
               IF .NOT. EOF()
                  STORE NAME TO MSAL_NAME2
               ELSE
                  STORE '3RD PARTY CONTRACTOR NOT ON FILE' TO MSAL_NAME2
               ENDIF
               MLINE = MLINE + 2
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,60 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  *                 @ 3,06 say mpage_no picture '99'
                  @ 3,46 SAY 'DAILY SPREADSHEET DETAIL REPORT FOR ' + DTOC(MDATE)
                  @ 3,128 SAY DTOC(DATE())
                  @ 5,1 SAY 'INV NBR'
                  @ 5,12 SAY 'P.O. NBR'
                  @ 5,23 SAY 'DESCR'
                  @ 5,31 SAY 'CUSTOMER'
                  @ 5,44 SAY '  TOT SELL'
                  @ 5,56 SAY 'CUST FRT'
                  @ 5,66 SAY 'SUPPLIER'
                  @ 5,80 SAY ' TOT PURCH'
                  @ 5,92 SAY ' SUP FRT'
                  @ 5,102 SAY '  FREIGHT'
                  @ 5,113 SAY 'PALLETS'    
                  @ 5,122 SAY '   MISC' 
                  @ 5,132 SAY '     COMM'
                  @ 5,144 SAY 'BROKR'
                  @ 5,151 SAY 'TOT NET'
                  @ 5,01 SAY REPLICATE('_',157)
                  MLINE = 7
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,144 SAY SUBSTR(MSAL_NAME2,1,08)
            ENDIF
            
            IF SAL_CODE3 <> SPACE(2) .AND. SALE3_AMT <> 0
               STORE SAL_CODE3 TO MSAL_CODE3
               SELECT B
               DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               SEEK MSAL_CODE3
               IF .NOT. EOF()
                  STORE NAME TO MSAL_NAME3
               ELSE
                  STORE 'SALESPERSON NOT ON FILE         ' TO MSAL_NAME3
               ENDIF
               MLINE = MLINE + 2
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,60 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  *                 @ 3,06 say mpage_no picture '99'
                  @ 3,46 SAY 'DAILY SPREADSHEET DETAIL REPORT FOR ' + DTOC(MDATE)
                  @ 3,128 SAY DTOC(DATE())
                  @ 5,1 SAY 'INV NBR'
                  @ 5,12 SAY 'P.O. NBR'
                  @ 5,23 SAY 'DESCR'
                  @ 5,31 SAY 'CUSTOMER'
                  @ 5,44 SAY '  TOT SELL'
                  @ 5,56 SAY 'CUST FRT'
                  @ 5,66 SAY 'SUPPLIER'
                  @ 5,80 SAY ' TOT PURCH'
                  @ 5,92 SAY ' SUP FRT'
                  @ 5,102 SAY '  FREIGHT'
                  @ 5,113 SAY 'PALLETS'    
                  @ 5,122 SAY '   MISC' 
                  @ 5,132 SAY '     COMM'
                  @ 5,144 SAY 'BROKR'
                  @ 5,151 SAY 'TOT NET'
                  @ 5,01 SAY REPLICATE('_',157)
                  MLINE = 7
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,144 SAY SUBSTR(MSAL_NAME3,1,08)
            ENDIF
            
            MLINE = MLINE + 2
            SELECT A
            SKIP
         ENDDO
         MLINE = 76
         
      ENDDO   
      EJECT
      
      MLINE = 99
      IF MINVN
         *************
         GOTO MSTRT_REC
         DO WHILE .NOT. EOF() .AND. MYEAR = SUBSTR(DTOC(INV_DATE),7) .AND. VAL(MMONTH) = VAL(SUBSTR(DTOC(INV_DATE),1,2)) .and. val(MDAY) = VAL(SUBSTR(DTOC(INV_DATE),4,2))
            
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  EJECT
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 2,60 SAY MCOMPANY
               @ 3,1 SAY 'Page'
               @ 3,46 SAY 'DAILY SPREADSHEET INVENTORY REPORT FOR ' + DTOC(MDATE)
               @ 3,128 SAY DTOC(DATE())
               @ 5,1 SAY 'INV NBR'
               @ 5,12 SAY 'P.O. NBR'
               @ 5,23 SAY 'DESCR'
               @ 5,31 SAY 'CUSTOMER'
               @ 5,44 SAY '  TOT SELL'
               @ 5,56 SAY 'CUST FRT'
               @ 5,66 SAY 'SUPPLIER'
               @ 5,80 SAY ' TOT PURCH'
               @ 5,92 SAY ' SUP FRT'
               @ 5,102 SAY '  FREIGHT'
               @ 5,113 SAY 'PALLETS'    
               @ 5,122 SAY '   MISC' 
               @ 5,132 SAY '     COMM'
               @ 5,144 SAY 'BROKR'
               @ 5,151 SAY 'TOT NET'
               @ 6,01 SAY REPLICATE('*',159)
               MLINE = 8
            ENDIF
            
            STORE SALESMAN TO MSALESMAN
            STORE PO_NBR TO MPO_NBR
            STORE PO_SUFFIX TO MPO_SUFFIX
            
            SELECT C
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            
            IF RSUPCODE <> 'INVN' .AND. BBUYCODE <> 'INVN'
               SELECT A
               SKIP
               LOOP
            ENDIF
            
            IF EOF()
               STORE 'NONE' TO MRSUPCODE, MBBUYCODE
            ELSE
               STORE RSUPCODE TO MRSUPCODE
               STORE BBUYCODE TO MBBUYCODE
            ENDIF
            
            SELECT D
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF .NOT. EOF()
               STORE SUBSTR(PROD_DESC,1,5) TO MPROD
            ELSE
               STORE SPACE(5) TO MPROD
            ENDIF
            
            SELECT B
            IF MRSUPCODE = 'NONE'
               STORE 'NONE' + SPACE(6) TO MRSUPNAME
            ELSE
               DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
               SEEK MRSUPCODE
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,10) TO MRSUPNAME
               ELSE 
                  STORE 'NOTONFILE ' TO MRSUPNAME
               ENDIF
            ENDIF
            
            IF MBBUYCODE = 'NONE'
               STORE 'NONE' + SPACE(56) TO MBBUYNAME
            ELSE  
               DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
               SEEK MBBUYCODE
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,10) TO MBBUYNAME
               ELSE 
                  STORE 'NOTONFILE ' TO MBBUYNAME
               ENDIF
            ENDIF
            
            IF MSALESMAN <> SPACE(2)
               DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               SEEK MSALESMAN
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,8) TO MSAL_NAME
               ELSE
                  STORE SPACE(08) TO MSAL_NAME
               ENDIF
            ELSE
               SELECT C
               STORE BROK_NAME TO MSAL_NAME
            ENDIF
            
            SELECT C
            IF SALESMAN <> SPACE(2)
               STORE SALESMAN + '-' + INV_NBR TO MINV_NBR
            ELSE
               STORE INV_NBR TO MINV_NBR
            ENDIF
            
            @ MLINE,1 SAY MINV_NBR
            IF MSALESMAN <> SPACE(2) 
               @ MLINE,12 SAY MSALESMAN + '-'
            ENDIF
            @ MLINE,15 SAY MPO_NBR
            IF MPO_SUFFIX <> ' '
               @ MLINE,19 SAY '-' + MPO_SUFFIX
            ENDIF
            IF BROKERAGE = 'X'
               @  MLINE,23 SAY 'BROKE'
            ELSE
               @ MLINE,23 SAY MPROD
            ENDIF
            @ MLINE,31 SAY MBBUYNAME
            @ MLINE,66 SAY MRSUPNAME
            IF MPROG_CODE = 2
               MFRT_AMT = FRT_AMT1 + FRT_AMT2 + FRT_AMT3 
            ELSE
               MFRT_AMT = FRT_AMT1            
            ENDIF
            @ MLINE,101 SAY MFRT_AMT PICTURE '999,999.99'
            @ MLINE,114 SAY FRT_PALL PICTURE '@Z 9999.99'
            @ MLINE,144 SAY MSAL_NAME
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
               MLINE = MLINE + 2
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,60 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  @ 3,46 SAY 'DAILY SPREADSHEET INVENTORY REPORT FOR ' + DTOC(MDATE)
                  @ 3,128 SAY DTOC(DATE())
                  @ 5,1 SAY 'INV NBR'
                  @ 5,12 SAY 'P.O. NBR'
                  @ 5,23 SAY 'DESCR'
                  @ 5,31 SAY 'CUSTOMER'
                  @ 5,44 SAY '  TOT SELL'
                  @ 5,56 SAY 'CUST FRT'
                  @ 5,66 SAY 'SUPPLIER'
                  @ 5,80 SAY ' TOT PURCH'
                  @ 5,92 SAY ' SUP FRT'
                  @ 5,102 SAY '  FREIGHT'
                  @ 5,113 SAY 'PALLETS'    
                  @ 5,122 SAY '   MISC' 
                  @ 5,132 SAY '     COMM'
                  @ 5,144 SAY 'BROKR'
                  @ 5,151 SAY 'TOT NET'
                  @ 6,01 SAY REPLICATE('_',157)
                  MLINE = 8
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,144 SAY SUBSTR(MCOM_NAME,1,08)
            ENDIF
            
            IF COM_CODE2 <> SPACE(2) .AND. COMM_AMT2 <> 0
               STORE COM_CODE2 TO MCOM_CODE2
               SELECT B
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               
               SEEK MCOM_CODE2
               IF .NOT. EOF()
                  STORE NAME TO MCOM_NAME2
               ELSE  
                  STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME2
               ENDIF
               MLINE = MLINE + 2
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,60 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  @ 3,46 SAY 'DAILY SPREADSHEET INVENTORY REPORT FOR ' + DTOC(MDATE)
                  @ 3,128 SAY DTOC(DATE())
                  @ 5,1 SAY 'INV NBR'
                  @ 5,12 SAY 'P.O. NBR'
                  @ 5,23 SAY 'DESCR'
                  @ 5,31 SAY 'CUSTOMER'
                  @ 5,44 SAY '  TOT SELL'
                  @ 5,56 SAY 'CUST FRT'
                  @ 5,66 SAY 'SUPPLIER'
                  @ 5,80 SAY ' TOT PURCH'
                  @ 5,92 SAY ' SUP FRT'
                  @ 5,102 SAY '  FREIGHT'
                  @ 5,113 SAY 'PALLETS'    
                  @ 5,122 SAY '   MISC' 
                  @ 5,132 SAY '     COMM'
                  @ 5,144 SAY 'BROKR'
                  @ 5,151 SAY 'TOT NET'
                  @ 6,01 SAY REPLICATE('_',157)
                  MLINE = 8
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,144 SAY SUBSTR(MCOM_NAME2,1,08)
            ENDIF
            IF COM_CODE3 <> SPACE(2) .AND. COMM_AMT3 <> 0
               STORE COM_CODE3 TO MCOM_CODE3
               SELECT B
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               
               SEEK MCOM_CODE3
               IF .NOT. EOF()
                  STORE NAME TO MCOM_NAME3
               ELSE  
                  STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME3
               ENDIF
               MLINE = MLINE + 2
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,60 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  @ 3,46 SAY 'DAILY SPREADSHEET INVENTORY REPORT FOR ' + DTOC(MDATE)
                  @ 3,128 SAY DTOC(DATE())
                  @ 5,1 SAY 'INV NBR'
                  @ 5,12 SAY 'P.O. NBR'
                  @ 5,23 SAY 'DESCR'
                  @ 5,31 SAY 'CUSTOMER'
                  @ 5,44 SAY '  TOT SELL'
                  @ 5,56 SAY 'CUST FRT'
                  @ 5,66 SAY 'SUPPLIER'
                  @ 5,80 SAY ' TOT PURCH'
                  @ 5,92 SAY ' SUP FRT'
                  @ 5,102 SAY '  FREIGHT'
                  @ 5,113 SAY 'PALLETS'    
                  @ 5,122 SAY '   MISC' 
                  @ 5,132 SAY '     COMM'
                  @ 5,144 SAY 'BROKR'
                  @ 5,151 SAY 'TOT NET'
                  @ 6,01 SAY REPLICATE('_',157)
                  MLINE = 8
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,144 SAY SUBSTR(MCOM_NAME3,1,08)
            ENDIF
            
            SELECT C
            IF SAL_CODE2 <> SPACE(2) .AND. SALE2_AMT <> 0
               **RON MONTGOMERY CHANGES
               STORE SAL_CODE2 TO MSAL_CODE2
               SELECT B
               **DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               SEEK MSAL_CODE2
               IF .NOT. EOF()
                  STORE NAME TO MSAL_NAME2
               ELSE
                  STORE 'SALESPERSON NOT ON FILE         ' TO MSAL_NAME2
               ENDIF
               MLINE = MLINE + 2
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,60 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  @ 3,46 SAY 'DAILY SPREADSHEET INVENTORY REPORT FOR ' + DTOC(MDATE)
                  @ 3,128 SAY DTOC(DATE())
                  @ 5,1 SAY 'INV NBR'
                  @ 5,12 SAY 'P.O. NBR'
                  @ 5,23 SAY 'DESCR'
                  @ 5,31 SAY 'CUSTOMER'
                  @ 5,44 SAY '  TOT SELL'
                  @ 5,56 SAY 'CUST FRT'
                  @ 5,66 SAY 'SUPPLIER'
                  @ 5,80 SAY ' TOT PURCH'
                  @ 5,92 SAY ' SUP FRT'
                  @ 5,102 SAY '  FREIGHT'
                  @ 5,113 SAY 'PALLETS'    
                  @ 5,122 SAY '   MISC' 
                  @ 5,132 SAY '     COMM'
                  @ 5,144 SAY 'BROKR'
                  @ 5,151 SAY 'TOT NET'
                  @ 6,01 SAY REPLICATE('_',157)
                  MLINE = 8
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,144 SAY SUBSTR(MSAL_NAME2,1,08)
            ENDIF
            
            IF SAL_CODE3 <> SPACE(2) .AND. SALE3_AMT <> 0
               STORE SAL_CODE3 TO MSAL_CODE3
               SELECT B
               DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               SEEK MSAL_CODE3
               IF .NOT. EOF()
                  STORE NAME TO MSAL_NAME3
               ELSE
                  STORE 'SALESPERSON NOT ON FILE         ' TO MSAL_NAME3
               ENDIF
               MLINE = MLINE + 2
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 2,60 SAY MCOMPANY
                  @ 3,1 SAY 'Page'
                  @ 3,46 SAY 'DAILY SPREADSHEET INVENTORY REPORT FOR ' + DTOC(MDATE)
                  @ 3,128 SAY DTOC(DATE())
                  @ 5,1 SAY 'INV NBR'
                  @ 5,12 SAY 'P.O. NBR'
                  @ 5,23 SAY 'DESCR'
                  @ 5,31 SAY 'CUSTOMER'
                  @ 5,44 SAY '  TOT SELL'
                  @ 5,56 SAY 'CUST FRT'
                  @ 5,66 SAY 'SUPPLIER'
                  @ 5,80 SAY ' TOT PURCH'
                  @ 5,92 SAY ' SUP FRT'
                  @ 5,102 SAY '  FREIGHT'
                  @ 5,113 SAY 'PALLETS'    
                  @ 5,122 SAY '   MISC' 
                  @ 5,132 SAY '     COMM'
                  @ 5,144 SAY 'BROKR'
                  @ 5,151 SAY 'TOT NET'
                  @ 6,01 SAY REPLICATE('_',157)
                  MLINE = 8
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,144 SAY SUBSTR(MSAL_NAME3,1,08)
            ENDIF
            
            MLINE = MLINE + 2
            SELECT A
            SKIP
         ENDDO   
         EJECT
      ENDIF
      **** EPSON -ELITE, AND LETTER QUALITY MODE, SANS SERIF
      ?? CHR(18)
      ?? CHR(27) + 'M'
      ?? CHR(27) + 'x' + CHR(1)
      ?? CHR(27) + 'k' + CHR(2)
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      CLOSE DATA
      * EOF: NEWRPT.PRG
   CASE VAL(MSELECTION) = 4     
      * Notes...: DAILY SALES REPORT         
      MTITLE = ' - MONTH-TO-MONTH SPREADSHEET SUMMARY REPORT'
      
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET FIRST AND LAST DATES FOR THIS REPORT
      STORE 0 TO MSTART_MO, MSTART_YR, MLAST_MO, MLAST_YR
      STORE 'D' TO MDISP_PRT
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 09,2 say '  BEGININNING MONTH AND YEAR:'      
         @ 09,36 SAY '/'
         @ 09,33 GET MSTART_MO PICTURE '##' RANGE 1,12
         @ 09,38 GET MSTART_YR PICTURE '####' RANGE 1987,2099
         @ 11,2 SAY '       ENDING MONTH AND YEAR:'
         @ 11,36 SAY '/'
         @ 11,33 GET MLAST_MO PICTURE '##' RANGE 1,12
         @ 11,38 GET MLAST_YR PICTURE '####' RANGE 1987,2099
         @ 13,2 SAY 'DISPLAY OR PRINT (D/P): '
         @ 13,27 GET MDISP_PRT PICTURE '@!'
         STORE 1 TO MACTION
         @ 24,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'                     
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF MSTART_MO = 0 .AND. MSTART_YR = 0 .AND. MLAST_MO = 0 .AND. MLAST_YR = 0                                                        
               MACTION = 3
            ENDIF
         ENDIF
         
         IF MACTION = 1
            IF MSTART_MO = 0 .OR. MSTART_YR = 0 .OR. MLAST_MO = 0 .OR. MLAST_YR = 0                                                        
               @ 23,0 CLEAR
               mwait = ' '
               @ 23,1 SAY 'Incomplete Dates Entered - Both Begin and End Dates Must be Entered'
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
      SELECT A 
      *DO FOX_USE WITH "DAILYJRN INDEX JRN_DATE", .F.
      DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
      
      MSTART_MO = MSTART_MO + 100
      STORE SUBSTR(STR(MSTART_MO,3),2) TO MSTART_MO
      
      MLAST_MO = MLAST_MO + 100
      STORE SUBSTR(STR(MLAST_MO,3),2) TO MLAST_MO
      
      *MSTART_YR = MSTART_YR + 100
      STORE STR(MSTART_YR,4) TO MSTART_YR
      
      *MLAST_YR = MLAST_YR + 100
      STORE STR(MLAST_YR,4) TO MLAST_YR
      
      STORE MSTART_MO TO MTRAN_MO
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
      
      STORE MMONTH TO MBNAME
      
      STORE MLAST_MO TO MTRAN_MO
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
      
      STORE MMONTH TO MENAME
      
      SEEK MSTART_YR + MSTART_MO
      
      MPAGE_NO = 0
      MLINE = 99 
      @ 16,16 SAY 'CALULATING........'
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
      
      MNET_TOT = 0 
      MGROSS_TOT = 0
      MEND =  VAL(MLAST_YR + MLAST_MO)        
      DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR + TRAN_MO) <= MEND                    
         MNET_TOT = MNET_TOT + TOT_NET + SALE2_NET + SALE3_NET
         MGROSS_TOT = MGROSS_TOT + TOT_SELL
         SKIP
      ENDDO
      IF MLINE = 99 .AND. MDISP_PRT <> 'P'
         CLEAR
      ENDIF
      MPAGE_NO = MPAGE_NO + 1
      @ 2,27 SAY MCOMPANY
      @ 3,1 SAY 'Page'
      @ 3,06 say mpage_no picture '99'
      @ 3,20 SAY '  SPREADSHEET TOTALS FOR '
      @ 3,70 SAY DTOC(DATE())
      IF MBNAME = MENAME
         @ 4,27 SAY MBNAME
      ELSE
         @ 4,27 SAY MBNAME + ' - ' + MENAME
      ENDIF
      IF MDISP_PRT = 'P'
         @ 4,01 SAY REPLICATE('_',77)
      ENDIF
      MLINE = 7
      @ MLINE,10 SAY 'TOTAL GROSS SALES           TOTAL NET SALES'
      MLINE = MLINE + 2
      @ MLINE,12 SAY MGROSS_TOT PICTURE '999,999,999.99' 
      @ MLINE,39 SAY MNET_TOT PICTURE '999,999,999.99'
      IF MDISP_PRT = 'P'
         MLINE = MLINE + 1
         @ mline+1,1 say ' '
         eject
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
      * EOF: DATESLS.PRG
      
   CASE VAL(MSELECTION) =  5 
      STORE 'T' TO MRPT_CHOICE 
      * Notes...: DAILY SALES REPORT FOR SALESMAN 
      MTITLE = ' - SALESPERSON SALES SUMMARY'
      
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE DATE() TO MDATE
      STORE 0 TO MSTART_MO, MSTART_YR, MLAST_MO, MLAST_YR
      store space(2) to msel_sales
      STORE 'D' TO MDISP_PRT
      store 'NO ' TO MYES_NO
      STORE 'B' TO MINV_COR
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 06,2 say '    Beginning Month and Year:'      
         @ 06,36 SAY '/'
         @ 06,33 GET MSTART_MO PICTURE '##' RANGE 1,12
         @ 06,38 GET MSTART_YR PICTURE '####' RANGE 1987,2099
         @ 07,2 SAY '       Ending Month and Year:'
         @ 07,36 SAY '/'
         @ 07,33 GET MLAST_MO PICTURE '##' RANGE 1,12
         @ 07,38 GET MLAST_YR PICTURE '####' RANGE 1987,2099
         @ 08,1 SAY 'Select Activity: Invoices (I),' 
         @ 09,1 say '  Corrections (C) or Both (B):'
         @ 09,33 get minv_cor picture '@!'
         @ 10,5 SAY 'Display or Print Report (D/P):'
         @ 10,37 GET MDISP_PRT PICTURE '@!'
         @ 13,4 SAY '(Optional)   SALESPERSON CODE: ' 
         @ 13,37 get msel_sales picture '##'
         @ 14,4 SAY '(Note: If salesperson code left blank, all salespersons)'
         @ 15,4 say '(      will be printed on the report)'
         @ 17,1 SAY 'Include Third Party Salespersons:'      
         @ 17,37 get myes_no picture '@!'
         @ 18,1 say '              (Enter YES or NO)'
         
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF MSTART_MO = 0 .AND. MSTART_YR = 0 .AND. MLAST_MO = 0 .AND. MLAST_YR = 0                                                        
               MACTION = 3
            ENDIF
         ENDIF
         IF MACTION = 1
            IF MSTART_MO = 0 .OR. MSTART_YR = 0 .OR. MLAST_MO = 0 .OR. MLAST_YR = 0                                                        
               @ 23,0 CLEAR
               mwait = ' '
               @ 23,1 SAY 'Incomplete Dates Entered - Both Begin and End Dates Must be Entered'
               @ 24,1 say 'Press Any Key to Reenter ' get mwait
               READ
               MACTION = 2
               @ 23,0 clear
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
            RETURN
         ENDIF
         MPAGE_LEN = 56
      ELSE
         MPAGE_LEN = 22
      ENDIF
      
      MSTART_MO = MSTART_MO + 100
      STORE SUBSTR(STR(MSTART_MO,3),2) TO MSTART_MO
      
      MLAST_MO = MLAST_MO + 100
      STORE SUBSTR(STR(MLAST_MO,3),2) TO MLAST_MO
      
      *MSTART_YR = MSTART_YR + 100
      STORE STR(MSTART_YR,4) TO MSTART_YR
      
      *MLAST_YR = MLAST_YR + 100
      STORE STR(MLAST_YR,4) TO MLAST_YR
      
      STORE MSTART_MO TO MTRAN_MO
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
      
      STORE MMONTH TO MBNAME
      
      STORE MLAST_MO TO MTRAN_MO
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
      
      STORE MMONTH TO MENAME
      
      SELECT D
      DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      
      SELECT A
      DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
      DO CASE
      CASE MINV_COR = 'I'
         SET FILTER TO INV_COR = 'I'
         MWORD = 'INVOICES'
      CASE MINV_COR = 'C'
         SET FILTER TO INV_COR = 'C'
         MWORD = 'CORRECTIONS'
      OTHERWISE
         MWORD = 'INVOICES & CORRECTIONS'
      ENDCASE
      GOTO TOP
      
      SEEK MSTART_YR + MSTART_MO 
      IF EOF()
         @ 4,1 CLEAR TO 21,78 
         @ 10,5 SAY 'THERE IS NO SALES DATA ON FILE FOR THIS MONTH'
         STORE ' ' TO MWAIT
         @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
         READ
         RETURN
      ENDIF
      
      @ 20,16 SAY 'CALCULATING........'
      
      STORE 0 TO MMTD_COMM, MDAILY_COM, MMTD_NET, MDAILY_NET
      STORE 0 TO MTOT_PURCH, MTOT_SELL, MCOMM, MNET
      
      SELECT B
      USE SALESUM EXCLUSIVE
      DELETE ALL
      PACK
      INDEX ON NAME TO SALESUM
      UNLOCK
      
      DO FOX_USE WITH "SALESUM INDEX SALESUM", .F.
      
      SELECT A
      DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR+TRAN_MO) <= VAL(MLAST_YR+MLAST_MO)
         MTOT_SELL = MTOT_SELL + TOT_SELL + CUS_PALL
         MTOT_PURCH = MTOT_PURCH + TOT_PURCH + SUP_PALL
         MNET = MNET + TOT_NET + SALE2_NET + SALE3_NET
         MCOMM = MCOMM + SALE_COMM + SALE2_AMT + SALE3_AMT
         IF MYES_NO = 'YES'
            MCOMM = MCOMM + COMM_AMT + COMM_AMT2 + COMM_AMT3
         ENDIF
         IF MSEL_SALES <> SPACE(2)       
            IF SALESMAN <> MSEL_SALES .AND. SAL_CODE2 <> MSEL_SALES .AND. SAL_CODE3 <> MSEL_SALES
               IF (MSEL_SALES = '01' .AND. (BROK_NAME = 'BOB' .OR. BROK_NAME = ' BOB')) ; 
                  .OR. (MSEL_SALES = '02' .AND. (BROK_NAME = 'KEN' .OR. BROK_NAME = ' KEN'))
               ELSE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
         ENDIF
         DO CASE
         CASE MSEL_SALES = SPACE(2)
            IF SALESMAN <> SPACE(2)
               SELECT C
               DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               
               SEEK A->SALESMAN
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,20) TO MNAME
               ELSE
                  STORE 'NOT ON FILE        ' TO MNAME
               ENDIF
            ELSE
               DO CASE
               CASE BROK_NAME = SPACE(5)
                  STORE 'NO SALESPERSON' TO MNAME
               CASE BROK_NAME = ' KEN'
                  STORE 'KEN' + SPACE(13) TO MNAME
               CASE BROK_NAME = ' BOB'
                  STORE 'BOB' + SPACE(13) TO MNAME
               OTHERWISE 
                  STORE BROK_NAME + SPACE(13) TO MNAME
               ENDCASE
            ENDIF
            SELECT B
            SEEK TRIM(MNAME)
            IF EOF()
               DO FILELOCK
               APPEND BLANK
               REPLACE NAME WITH MNAME
            ELSE
               DO FILELOCK
            ENDIF
            REPLACE COMM_AMT WITH COMM_AMT + A->SALE_COMM
            
            REPLACE TOT_NET WITH TOT_NET + A->TOT_NET
            REPLACE SALES WITH SALES + A->TOT_SELL + A->CUS_PALL
            REPLACE PURCHASES WITH PURCHASES + A->TOT_PURCH + A->SUP_PALL
            UNLOCK
            
            SELECT A
            MMTD_COMM = MMTD_COMM + SALE_COMM
            MMTD_NET = MMTD_NET + TOT_NET
         OTHERWISE
            IF SALESMAN = MSEL_SALES     
               SELECT C
               DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               
               SEEK A->SALESMAN
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,20) TO MNAME
               ELSE
                  STORE 'NOT ON FILE        ' TO MNAME
               ENDIF
               SELECT B
               SEEK TRIM(MNAME)
               IF EOF()
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE NAME WITH MNAME
               ELSE
                  DO FILELOCK
               ENDIF
               REPLACE COMM_AMT WITH COMM_AMT + A->SALE_COMM
               REPLACE TOT_NET WITH TOT_NET + A->TOT_NET
               REPLACE SALES WITH SALES + A->TOT_SELL + A->CUS_PALL
               REPLACE PURCHASES WITH PURCHASES + A->TOT_PURCH + A->SUP_PALL
               UNLOCK
               
               SELECT A
            ELSE
               IF (MSEL_SALES = '01' .AND. BROK_NAME = 'BOB') .OR. ;
                  (MSEL_SALES = '02' .AND. BROK_NAME = 'KEN')
                  STORE BROK_NAME TO MNAME
                  SELECT B
                  SEEK TRIM(MNAME)
                  IF EOF()
                     DO FILELOCK
                     APPEND BLANK
                     REPLACE NAME WITH MNAME
                  ELSE
                     DO FILELOCK
                  ENDIF
                  REPLACE COMM_AMT WITH COMM_AMT + A->SALE_COMM
                  REPLACE TOT_NET WITH TOT_NET + A->TOT_NET
                  REPLACE SALES WITH SALES + A->TOT_SELL + A->CUS_PALL
                  REPLACE PURCHASES WITH PURCHASES + A->TOT_PURCH + A->SUP_PALL
                  UNLOCK
                  
                  SELECT A
               ENDIF
            ENDIF
         ENDCASE
         
         IF SAL_CODE2 <> SPACE(2)
            IF MSEL_SALES <> SPACE(2)
               IF MSEL_SALES <> SAL_CODE2
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            SELECT C
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
            
            SEEK A->SAL_CODE2
            IF .NOT. EOF()
               IF NAME = 'BOB' .OR. NAME = 'KEN'
                  STORE SUBSTR(NAME,1,3) + SPACE(17) TO MNAME
               ELSE
                  STORE SUBSTR(NAME,1,20) TO MNAME
               ENDIF
            ELSE
               STORE 'NOT ON FILE        ' TO MNAME
            ENDIF
            SELECT B
            SEEK TRIM(MNAME)
            IF EOF()
               DO FILELOCK
               APPEND BLANK
               REPLACE NAME WITH MNAME
            ELSE
               DO FILELOCK
            ENDIF
            
            REPLACE COMM_AMT WITH COMM_AMT + A->SALE2_AMT
            REPLACE TOT_NET WITH TOT_NET + A->SALE2_NET
            
            UNLOCK
            SELECT A
            
         ENDIF
         
         IF SAL_CODE3 <> SPACE(2)
            IF MSEL_SALES <> SPACE(2)
               IF MSEL_SALES <> SAL_CODE3
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            SELECT C
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
            
            SEEK A->SAL_CODE3
            IF .NOT. EOF()
               IF NAME = 'BOB' .OR. NAME = 'KEN'
                  STORE SUBSTR(NAME,1,3) + SPACE(17) TO MNAME
               ELSE
                  STORE SUBSTR(NAME,1,20) TO MNAME
               ENDIF
            ELSE
               STORE 'NOT ON FILE        ' TO MNAME
            ENDIF
            SELECT B
            SEEK TRIM(MNAME)
            IF EOF()
               DO FILELOCK
               APPEND BLANK
               REPLACE NAME WITH MNAME
            ELSE
               DO FILELOCK
            ENDIF
            
            REPLACE COMM_AMT WITH COMM_AMT + A->SALE3_AMT
            REPLACE TOT_NET WITH TOT_NET + A->SALE3_NET
            
            UNLOCK
            SELECT A
            
         ENDIF
         
         IF MYES_NO = 'YES'
            IF COM_CODE <> SPACE(2)
               SELECT C
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               SEEK A->COM_CODE
               IF .NOT. EOF()                      
                  STORE SUBSTR(NAME,1,20) TO MNAME
               ELSE  
                  STORE 'NOT ON FILE        ' TO MNAME
               ENDIF
               SELECT B
               SEEK TRIM(MNAME)
               IF EOF()
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE NAME WITH MNAME
               ELSE
                  DO FILELOCK
               ENDIF
               
               REPLACE COMM_AMT WITH COMM_AMT + A->COMM_AMT 
               UNLOCK
               SELECT A
            ENDIF
            IF COM_CODE2 <> SPACE(2)
               SELECT C
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               SEEK A->COM_CODE2
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,20) TO MNAME
               ELSE  
                  STORE 'NOT ON FILE        ' TO MNAME
               ENDIF
               SELECT B
               SEEK TRIM(MNAME)
               IF EOF()
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE NAME WITH MNAME
               ELSE
                  DO FILELOCK
               ENDIF
               
               REPLACE COMM_AMT WITH COMM_AMT + A->COMM_AMT2 
               UNLOCK
               SELECT A
            ENDIF
            IF COM_CODE3 <> SPACE(2)
               SELECT C
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               SEEK A->COM_CODE3
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,20) TO MNAME
               ELSE  
                  STORE 'NOT ON FILE        ' TO MNAME
               ENDIF
               SELECT B
               SEEK TRIM(MNAME)
               IF EOF()
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE NAME WITH MNAME
               ELSE
                  DO FILELOCK
               ENDIF
               
               REPLACE COMM_AMT WITH COMM_AMT + A->COMM_AMT3 
               UNLOCK
               SELECT A
            ENDIF
         ENDIF
         SKIP
      ENDDO
      SELECT B
      GOTO TOP
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
      
      DO WHILE .NOT. EOF()
         
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
            
            @ 1,33 SAY MCOMPANY
            @ 2,0 SAY 'PAGE'
            @ 2,05 say mpage_no picture '99'
            @ 2,25 SAY 'SALESPERSON ' + MWORD + ' SUMMARY FOR'
            @ 2,70 SAY DTOC(DATE())
            STORE LEN(MBNAME + ' ' + MSTART_YR + ' THRU ' + MENAME + ' ' + MLAST_YR) TO MLEN
            MCOL = (80-MLEN) / 2
            @ 3,MCOL SAY MBNAME + ' ' + MSTART_YR + ' THRU ' + MENAME + ' ' + MLAST_YR
            @ 5,1 SAY 'SALESPERSON'     
            @ 5,28 SAY 'PURCHASES' 
            @ 5,48 SAY 'SALES'
            @ 5,57 SAY 'COMMISSION'
            IF MDISP_PRT = 'P'
               @ 5,81 SAY 'MW NET'
            ELSE
               @ 5,74 SAY 'MW NET'
            ENDIF
            
            IF MDISP_PRT = 'P'
               @ 5,0 SAY REPLICATE ('_',92)
            ELSE
               @ 6,0 SAY REPLICATE ('-',80)
            ENDIF
            MLINE = 7
         ENDIF
         
         @ MLINE,1 SAY SUBSTR(NAME,1,18)  
         @ MLINE,21 SAY PURCHASES PICTURE '9,999,999,999.99'
         @ MLINE,37 SAY SALES     PICTURE '9,999,999,999.99'
         @ MLINE,53 SAY COMM_AMT PICTURE '999,999,999.99'
         IF MDISP_PRT = 'P'
            MPERCENT = ROUND((COMM_AMT/MCOMM) * 100,0)
            @ MLINE,68 SAY MPERCENT PICTURE '999'
            @ MLINE,71 SAY '%'
            @ MLINE,74 SAY TOT_NET  PICTURE '99,999,999.99'
            MPERCENT = ROUND((TOT_NET/MNET) * 100,0)
            @ MLINE,88 SAY MPERCENT PICTURE '999'
            @ MLINE,91 SAY '%'
         ELSE
            @ MLINE,67 SAY TOT_NET  PICTURE '99,999,999.99'
         ENDIF
         MLINE = MLINE + 2
         SKIP
      ENDDO
      
      IF MDISP_PRT = 'P'
         IF MSEL_SALES = SPACE(2)
            MLINE = MLINE + 1
            @ MLINE,2 SAY 'TOTALS:'
            @ MLINE,21 SAY MTOT_PURCH PICTURE '9,999,999,999.99'
            @ MLINE,37 SAY MTOT_SELL PICTURE '9,999,999,999.99'
            @ MLINE,53 SAY MCOMM PICTURE '999,999,999.99'
            @ MLINE,71 SAY MNET  PICTURE '9,999,999,999.99'
         ENDIF
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
         IF MLINE > MPAGE_LEN
            STORE 'C' TO MPRT_SEL
            @ 24,0 SAY "PRESS 'C' TO CONTINUE OR 'S' TO STOP REPORT DISPLAY: "     ;
               GET MPRT_SEL PICTURE '@! A'
            READ
            IF MPRT_SEL = 'S'
               CLOSE DATA
               RETURN
            ENDIF
            @ 6,0 CLEAR
            MLINE = 6
         ENDIF
         MLINE = MLINE + 1
         IF MSEL_SALES = SPACE(2)
            @ MLINE,2 SAY 'TOTALS:'
            @ MLINE,21 SAY MTOT_PURCH PICTURE '9,999,999,999.99'
            @ MLINE,37 SAY MTOT_SELL PICTURE '9,999,999,999.99'
            @ MLINE,53 SAY MCOMM PICTURE '999,999,999.99'
            @ MLINE,67 SAY MNET  PICTURE '99,999,999.99'
         ENDIF
         MPRT_SEL = ' '
         @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
         READ
      ENDIF
      CLOSE DATA
      * EOF: SALESUM.PRG
      
   CASE VAL(MSELECTION) =  6    
      MTITLE = ' - MONTHLY SALESPERSON SALES DETAIL REPORT'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      store '  ' to mbeg_mo, mend_mo 
      store SPACE(4) TO mbeg_yr, mend_yr 
      
      STORE 'D' TO MDISP_PRT
      STORE '**' to msel_sales
      STORE 'B' TO MINV_COR
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 06,1 say 'ENTER BEGINNING MO/YR REPORT DATE:   /'
         @ 08,4 SAY    'ENTER ENDING MO/YR REPORT DATE:   /'
         @ 06,37 GET MBEG_MO PICTURE '##'
         @ 06,40 GET MBEG_YR PICTURE '####'
         @ 08,37 GET MEND_MO PICTURE '##'
         @ 08,40 GET MEND_YR PICTURE '####'
         @ 10,5 SAY 'DISPLAY OR PRINT REPORT (D/P):'
         @ 10,37 GET MDISP_PRT PICTURE '@!'
         @ 12,5 SAY 'Select Activity: Invoices (I),' 
         @ 13,5 say '  Corrections (C) or Both (B):'
         @ 13,37 get minv_cor picture '@!'
         @ 15,4 SAY '(Optional)   SALESPERSON CODE: ' 
         @ 15,37 get msel_sales picture '##'
         @ 16,4 SAY '(Note: If salesperson not selected, all salespersons)'
         @ 17,4 say '(      will be printed on the report)'
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF MBEG_YR+MBEG_MO = '      ' .OR. MEND_YR+MEND_MO = '      '
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'NO DATE(S) ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
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
      MLINE = 99
      MPAGE_NO = 0
      
      SELECT C
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      SELECT D
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      SELECT A
      DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
      DO CASE
      CASE MINV_COR = 'I'
         SET FILTER TO INV_COR = 'I'
         MWORD = 'INVOICES'
      CASE MINV_COR = 'C'
         SET FILTER TO INV_COR = 'C'
         MWORD = 'CORRECTIONS'
      OTHERWISE
         MWORD = 'INVOICES & CORRECTIONS'
      ENDCASE
      GOTO TOP
      SEEK MBEG_YR+ MBEG_MO 
      IF EOF()
         @ 4,1 CLEAR TO 21,78 
         @ 10,5 SAY 'THERE IS NO SALES DATA ON FILE FOR SELECTED BEGIN MONTH'
         STORE ' ' TO MWAIT
         @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
         READ
         RETURN
      ENDIF
      
      @ 19,16 SAY 'PROCESSING.........'
      SELECT A
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
      
      MPURCH = 0 
      MSELL = 0
      MTOTAL = 0
      MCOMM = 0
      DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR+TRAN_MO) <= VAL(MEND_YR+MEND_MO)    
         IF MSEL_SALES <> '**'    
            IF SALESMAN <> MSEL_SALES .AND. SAL_CODE2 <> MSEL_SALES
               SKIP
               LOOP
            ENDIF
         ENDIF
         IF SALESMAN = '  ' .AND. PO_NBR = '4487'
            SKIP
            LOOP
         ENDIF
         MSALESMAN = SALESMAN
         MPO_NBR   = PO_NBR
         MPO_SUFFIX = PO_SUFFIX
         MSAL_CODE2 = SAL_CODE2
         MINV_NBR   = INV_NBR
         MTOT_PURCH = TOT_PURCH
         MTOT_SELL  = TOT_SELL
         MSALE_COMM = SALE_COMM
         MTOT_NET   = TOT_NET
         MSALE2_AMT = SALE2_AMT
         MSALE2_NET = SALE2_NET
         MSALE3_AMT = SALE3_AMT
         MSALE3_NET = SALE3_NET
         SKIP
         
         DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR+TRAN_MO) <= VAL(MEND_YR+MEND_MO) .AND. INV_NBR = MINV_NBR 
            IF SALESMAN = '  ' .AND. PO_NBR = '4487'
               SKIP
               LOOP
            ENDIF
            MTOT_PURCH = MTOT_PURCH + TOT_PURCH
            MTOT_SELL  = MTOT_SELL  + TOT_SELL
            MSALE_COMM = MSALE_COMM + SALE_COMM
            MTOT_NET   = MTOT_NET   + TOT_NET
            MSALE2_AMT = MSALE2_AMT + SALE2_AMT
            MSALE2_NET = MSALE2_NET + SALE2_NET
            MSALE3_AMT = MSALE3_AMT + SALE3_AMT
            MSALE3_NET = MSALE3_NET + SALE3_NET
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
            @ 2,19 SAY 'SALESPERSON ' + MWORD + ' REPORT FOR '  
            @ 2,70 SAY DTOC(DATE())
            @ 03,34 SAY   MBEG_MO+'/'+MBEG_YR + ' THRU ' +MEND_MO+'/'+MEND_YR
            @ 5,0 SAY 'PO NBR'
            @ 5,10 SAY 'SUPPLIER'
            @ 5,22 SAY 'TOT PURCH'
            @ 5,33 SAY 'CUSTOMER'
            @ 5,46 SAY 'TOT SELL'
            @ 5,56 SAY 'BROKR'
            @ 5,65 SAY 'COMM'
            @ 5,73 SAY 'TOT NET'
            IF MDISP_PRT = 'P'
               @ 5,0 SAY REPLICATE ('_',80)
            ELSE
               @ 6,0 SAY REPLICATE ('-',80)
            ENDIF
            MLINE = 7
         ENDIF
         
         SELECT C
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF EOF()
            STORE 'NONE' TO MRSUPCODE, MBBUYCODE
         ELSE
            STORE RSUPCODE TO MRSUPCODE
            STORE BBUYCODE TO MBBUYCODE
         ENDIF
         
         SELECT D
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF .NOT. EOF()
            STORE SUBSTR(PROD_DESC,1,5) TO MPROD
         ELSE
            STORE SPACE(5) TO MPROD
         ENDIF
         
         SELECT B
         IF MRSUPCODE = 'NONE'
            STORE 'NONE' + SPACE(6) TO MRSUPNAME
         ELSE
            DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
            SEEK MRSUPCODE
            IF .NOT. EOF()
               STORE SUBSTR(NAME,1,10) TO MRSUPNAME
            ELSE 
               STORE 'NOTONFILE ' TO MRSUPNAME
            ENDIF
         ENDIF
         
         IF MBBUYCODE = 'NONE'
            STORE 'NONE' + SPACE(56) TO MBBUYNAME
         ELSE  
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
            SEEK MBBUYCODE
            IF .NOT. EOF()
               STORE SUBSTR(NAME,1,10) TO MBBUYNAME
            ELSE 
               STORE 'NOTONFILE ' TO MBBUYNAME
            ENDIF
         ENDIF
         
         IF MSALESMAN <> SPACE(2)
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
            SEEK MSALESMAN
            IF .NOT. EOF()
               STORE SUBSTR(NAME,1,5) TO MSAL_NAME
            ELSE
               STORE SPACE(05) TO MSAL_NAME
            ENDIF
         ELSE
            SELECT C
            STORE SUBSTR(BROK_NAME,1,05) TO MSAL_NAME
         ENDIF
         
         SELECT C
         SELECT A
         IF MSALESMAN <> SPACE(2)
            @ MLINE,0 SAY MSALESMAN + '-'
         ENDIF
         @ MLINE,3 SAY MPO_NBR
         IF MPO_SUFFIX <> ' '
            @ MLINE,7 SAY '-' + MPO_SUFFIX
         ENDIF
         IF MSAL_CODE2 <> '  ' .AND. MSEL_SALES <> '**'
            *** IF A SPECIFIC SALESPERSON SELECTED - MASK THE INTRACOMP PART
            IF MSEL_SALES = MSAL_CODE2
               @ MLINE,10 SAY MRSUPNAME
               @ MLINE,21 SAY MTOT_PURCH PICTURE '999,999.99'
               MPURCH = MPURCH + MTOT_PURCH
               @ MLINE,33 SAY 'INTRACOMPANY SALE'       
            ELSE
               @ MLINE,10 SAY 'INTRACOMPANY PURCHASE'
               @ MLINE,33 SAY MBBUYNAME
               @ MLINE,44 SAY MTOT_SELL PICTURE '999,999.99'
               MSELL = MSELL + MTOT_SELL
            ENDIF
         ELSE
            @ MLINE,10 SAY MRSUPNAME
            @ MLINE,21 SAY MTOT_PURCH PICTURE '999,999.99'
            MPURCH = MPURCH + MTOT_PURCH
            @ MLINE,33 SAY MBBUYNAME
            @ MLINE,44 SAY MTOT_SELL PICTURE '999,999.99'
            MSELL = MSELL + MTOT_SELL
         ENDIF
         
         DO CASE
         CASE MSEL_SALES = '**'         
            @ MLINE,56 SAY MSAL_NAME
            @ MLINE,61 SAY MSALE_COMM PICTURE '99999.99'
            MCOMM = MCOMM + MSALE_COMM
            @ MLINE,71 SAY MTOT_NET PICTURE '99,999.99'
            MTOTAL = MTOTAL + MTOT_NET
            MLINE = MLINE + 2
         CASE MSALESMAN = MSEL_SALES
            @ MLINE,56 SAY MSAL_NAME
            @ MLINE,61 SAY MSALE_COMM PICTURE '99999.99'
            MCOMM = MCOMM + MSALE_COMM
            @ MLINE,71 SAY MTOT_NET PICTURE '99,999.99'
            MTOTAL = MTOTAL + MTOT_NET
            MLINE = MLINE + 2
         CASE MSEL_SALES = MSAL_CODE2
            SELECT B
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
            SEEK MSAL_CODE2
            IF .NOT. EOF()
               STORE NAME TO MSAL_NAME2
            ELSE
               STORE 'SALESPERSON NOT ON FILE         ' TO MSAL_NAME2
            ENDIF
            SELECT A
            @ MLINE,56 SAY SUBSTR(MSAL_NAME2,1,5)
            @ MLINE,62 SAY MSALE2_AMT PICTURE '9999.99'
            @ MLINE,71 SAY MSALE2_NET PICTURE '99,999.99'
            MTOTAL = MTOTAL + MSALE2_NET
            MCOMM = MCOMM + MSALE2_AMT
            MLINE = MLINE + 2
         CASE MSEL_SALES = MSAL_CODE3
            SELECT B
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
            SEEK MSAL_CODE3
            IF .NOT. EOF()
               STORE NAME TO MSAL_NAME3
            ELSE
               STORE 'SALESPERSON NOT ON FILE         ' TO MSAL_NAME3
            ENDIF
            SELECT A
            @ MLINE,56 SAY SUBSTR(MSAL_NAME3,1,5)
            @ MLINE,62 SAY MSALE3_AMT PICTURE '9999.99'
            @ MLINE,71 SAY MSALE3_NET PICTURE '99,999.99'
            MTOTAL = MTOTAL + MSALE3_NET
            MCOMM = MCOMM + MSALE3_AMT
            MLINE = MLINE + 2
         ENDCASE
      ENDDO
      IF MDISP_PRT = 'P'
         @ MLINE,0 SAY 'TOTALS:'
         @ MLINE,19 SAY MPURCH PICTURE '9,999,999.99'
         @ MLINE,42 SAY MSELL PICTURE '9,999,999.99'
         @ MLINE,60 SAY MCOMM PICTURE '99,999.99'
         @ MLINE,70 SAY MTOTAL PICTURE '999,999.99'
         
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
         IF MLINE > MPAGE_LEN
            @ 6,0 CLEAR
            MLINE = 6
         ENDIF
         @ MLINE,0 SAY 'TOTALS:'
         @ MLINE,19 SAY MPURCH PICTURE '9,999,999.99'
         @ MLINE,42 SAY MSELL PICTURE '9,999,999.99'
         @ MLINE,60 SAY MCOMM PICTURE '99,999.99'
         @ MLINE,70 SAY MTOTAL PICTURE '999,999.99'
         MPRT_SEL = ' '
         @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
         READ
      ENDIF
      
      CLOSE DATA
      
   CASE VAL(MSELECTION) =  7    
      MDOTHIS = .F.
      IF MDOTHIS 
         MCALLING = 'SALECOMP'
         MSECURITY = .F.
         DO SECURITY
         IF .NOT. MSECURITY
            LOOP  
         ENDIF
         
         MTITLE = ' - SALESPERSON COMPARISON REPORTS'
         
         CLEAR
         @  1, 1  SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         
         MRPT_TYPE = ' '          
         MACTION = 2
         
         DO WHILE MACTION = 2      
            @ 10,5 SAY 'Process Percentage (P) or Aging (A) Comparison: '                              
            @ 11,5 SAY '        or Interest (I)'
            @ 10,52 GET MRPT_TYPE PICTURE '@!'
            STORE 1 TO MACTION
            @ 23,00 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel'
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
         ENDDO
         
         IF MACTION = 3 .OR. MRPT_TYPE = ' '
            LOOP  
         ENDIF  
         DO CASE
         CASE MRPT_TYPE = 'P'
            DO SALECOMP
         CASE MRPT_TYPE = 'A'
            DO SALE_AGE
         CASE MRPT_TYPE = 'I'
            DO SALEINT
         ENDCASE
      ENDIF
      
      DO SALESACT
      
      
   CASE VAL(MSELECTION) =  8
      *** DO MFI_COM
      
      MTITLE = ' - MONTHLY SALESPERSON SALES DETAIL REPORT'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      store '  ' to mbeg_mo, mend_mo 
      store SPACE(4) TO mbeg_yr, mend_yr 
      STORE CTOD('') TO MBEG_DATE, MEND_DATE
      STORE 'D' TO MDISP_PRT
      STORE '**' to msel_sales
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 06,1 say 'ENTER BEGINNING REPORT DATE:'
         @ 08,4 SAY    'ENTER ENDING REPORT DATE:'
         @ 06,33 GET MBEG_DATE 
         @ 08,33 GET MEND_DATE 
         @ 10,5 SAY 'DISPLAY OR PRINT REPORT (D/P):'
         @ 10,37 GET MDISP_PRT PICTURE '@!'
         @ 15,4 SAY '(Optional)   SALESPERSON CODE: ' 
         @ 15,37 get msel_sales picture '##'
         @ 16,4 SAY '(Note: If salesperson not selected, all salespersons)'
         @ 17,4 say '(      will be printed on the report)'
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF DTOC(MBEG_DATE) = '  /  /  ' .OR. DTOC(MEND_DATE) = '  /  /  '
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'NO DATE(S) ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
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
      MLINE = 99
      MPAGE_NO = 0
      
      SELECT D
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      SELECT A
      DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP", .F.
      
      MWORD = 'SHIPMENTS'
      STORE SUBSTR(DTOC(MBEG_DATE),7) TO MBEG_YR
      STORE SUBSTR(DTOC(MBEG_DATE),1,2) TO MBEG_MO
      SEEK MBEG_YR+ MBEG_MO 
      IF EOF()
         @ 4,1 CLEAR TO 21,78 
         @ 10,5 SAY 'THERE IS NO SALES DATA ON FILE FOR SELECTED BEGIN MONTH'
         STORE ' ' TO MWAIT
         @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
         READ
         RETURN
      ENDIF
      DO WHILE .NOT. EOF() .AND. SHIP_DATE < MBEG_DATE
         SKIP
      ENDDO
      
      
      @ 19,16 SAY 'PROCESSING.........'
      SELECT A
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
      
      MPURCH = 0 
      MSELL = 0
      MTOTAL = 0
      
      MCOMM = 0
      DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MEND_DATE
         IF MSEL_SALES <> '**'    
            IF SALESMAN <> MSEL_SALES .AND. SAL_CODE2 <> MSEL_SALES
               SKIP
               LOOP
            ENDIF
         ENDIF
         MSALESMAN = SALESMAN 
         MPO_NBR   = PO_NBR
         MPO_SUFFIX = PO_SUFFIX
         MSAL_CODE2 = SAL_CODE2
         MINV_NBR   = INV_NBR
         MTOT_PURCH = TOT_PURCH
         MTOT_SELL  = TOT_SELL
         MSALE_COMM = SALE_COMM
         MTOT_NET   = TOT_NET
         MSALE2_AMT = SALE2_AMT
         MSALE2_NET = SALE2_NET
         MSALE3_AMT = SALE3_AMT
         MSALE3_NET = SALE3_NET
         
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
            @ 2,19 SAY 'SALESPERSON ' + MWORD + ' REPORT FOR '  
            @ 2,70 SAY DTOC(DATE())
            @ 03,34 SAY DTOC(MBEG_DATE)+ ' THRU '  +DTOC(MEND_DATE)      
            @ 5,0 SAY 'PO NBR'
            @ 5,10 SAY 'SUPPLIER'
            @ 5,22 SAY 'TOT PURCH'
            @ 5,33 SAY 'CUSTOMER'
            @ 5,46 SAY 'TOT SELL'
            @ 5,56 SAY 'BROKR'
            @ 5,65 SAY 'COMM'
            @ 5,73 SAY 'TOT NET'
            IF MDISP_PRT = 'P'
               @ 5,0 SAY REPLICATE ('_',80)
            ELSE
               @ 6,0 SAY REPLICATE ('-',80)
            ENDIF
            MLINE = 7
         ENDIF
         
         STORE RSUPCODE TO MRSUPCODE
         STORE BBUYCODE TO MBBUYCODE
         
         SELECT D
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF .NOT. EOF()
            STORE SUBSTR(PROD_DESC,1,5) TO MPROD
         ELSE
            STORE SPACE(5) TO MPROD
         ENDIF
         
         SELECT E
         IF MRSUPCODE = 'NONE'
            STORE 'NONE' + SPACE(6) TO MRSUPNAME
         ELSE
            DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
            SEEK MRSUPCODE
            IF .NOT. EOF()
               STORE SUBSTR(NAME,1,10) TO MRSUPNAME
            ELSE 
               STORE 'NOTONFILE ' TO MRSUPNAME
            ENDIF
         ENDIF
         
         IF MBBUYCODE = 'NONE'
            STORE 'NONE' + SPACE(56) TO MBBUYNAME
         ELSE  
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
            SEEK MBBUYCODE
            IF .NOT. EOF()
               STORE SUBSTR(NAME,1,10) TO MBBUYNAME
            ELSE 
               STORE 'NOTONFILE ' TO MBBUYNAME
            ENDIF
         ENDIF
         
         IF MSALESMAN <> SPACE(2)
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
            SEEK MSALESMAN
            IF .NOT. EOF()
               STORE SUBSTR(NAME,1,5) TO MSAL_NAME
            ELSE
               STORE SPACE(05) TO MSAL_NAME
            ENDIF
         ELSE
            SELECT A
            STORE SUBSTR(BROK_NAME,1,05) TO MSAL_NAME
         ENDIF
         
         SELECT A
         IF MSALESMAN <> SPACE(2)
            @ MLINE,0 SAY MSALESMAN + '-'
         ENDIF
         @ MLINE,3 SAY MPO_NBR
         IF MPO_SUFFIX <> ' '
            @ MLINE,7 SAY '-' + MPO_SUFFIX
         ENDIF
         IF MSAL_CODE2 <> '  ' .AND. MSEL_SALES <> '**'
            *** IF A SPECIFIC SALESPERSON SELECTED - MASK THE INTRACOMP PART
            IF MSEL_SALES = MSAL_CODE2
               @ MLINE,10 SAY MRSUPNAME
               @ MLINE,21 SAY MTOT_PURCH PICTURE '999,999.99'
               MPURCH = MPURCH + MTOT_PURCH
               @ MLINE,33 SAY 'INTRACOMPANY SALE'       
            ELSE
               @ MLINE,10 SAY 'INTRACOMPANY PURCHASE'
               @ MLINE,33 SAY MBBUYNAME
               @ MLINE,44 SAY MTOT_SELL PICTURE '999,999.99'
               MSELL = MSELL + MTOT_SELL
            ENDIF
         ELSE
            @ MLINE,10 SAY MRSUPNAME
            @ MLINE,21 SAY MTOT_PURCH PICTURE '999,999.99'
            MPURCH = MPURCH + MTOT_PURCH
            @ MLINE,33 SAY MBBUYNAME
            @ MLINE,44 SAY MTOT_SELL PICTURE '999,999.99'
            MSELL = MSELL + MTOT_SELL
         ENDIF
         
         DO CASE
         CASE MSEL_SALES = '**'         
            @ MLINE,56 SAY MSAL_NAME
            @ MLINE,61 SAY MSALE_COMM PICTURE '99999.99'
            MCOMM = MCOMM + MSALE_COMM
            @ MLINE,71 SAY MTOT_NET PICTURE '99,999.99'
            
            IF MDISP_PRT = 'P'
               @ MLINE,81 SAY MPROD
               @ MLINE,87 SAY SHIP_DATE
            ENDIF
            MTOTAL = MTOTAL + MTOT_NET
            MLINE = MLINE + 2
         CASE MSALESMAN = MSEL_SALES
            @ MLINE,56 SAY MSAL_NAME
            @ MLINE,61 SAY MSALE_COMM PICTURE '99999.99'
            MCOMM = MCOMM + MSALE_COMM
            @ MLINE,71 SAY MTOT_NET PICTURE '99,999.99'
            IF MDISP_PRT = 'P'
               @ MLINE,81 SAY MPROD
               @ MLINE,87 SAY SHIP_DATE
            ENDIF
            MTOTAL = MTOTAL + MTOT_NET
            MLINE = MLINE + 2
         CASE MSEL_SALES = MSAL_CODE2
            SELECT E
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
            SEEK MSAL_CODE2
            IF .NOT. EOF()
               STORE NAME TO MSAL_NAME2
            ELSE
               STORE 'SALESPERSON NOT ON FILE         ' TO MSAL_NAME2
            ENDIF
            SELECT A
            @ MLINE,56 SAY SUBSTR(MSAL_NAME2,1,5)
            @ MLINE,62 SAY MSALE2_AMT PICTURE '9999.99'
            @ MLINE,71 SAY MSALE2_NET PICTURE '99,999.99'
            MTOTAL = MTOTAL + MSALE2_NET
            MCOMM = MCOMM + MSALE2_AMT
            MLINE = MLINE + 2
         CASE MSEL_SALES = MSAL_CODE3
            SELECT E
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
            SEEK MSAL_CODE3
            IF .NOT. EOF()
               STORE NAME TO MSAL_NAME3
            ELSE
               STORE 'SALESPERSON NOT ON FILE         ' TO MSAL_NAME3
            ENDIF
            SELECT A
            @ MLINE,56 SAY SUBSTR(MSAL_NAME3,1,5)
            @ MLINE,62 SAY MSALE3_AMT PICTURE '9999.99'
            @ MLINE,71 SAY MSALE3_NET PICTURE '99,999.99'
            MTOTAL = MTOTAL + MSALE3_NET
            MCOMM = MCOMM + MSALE3_AMT
            MLINE = MLINE + 2
         ENDCASE
         SELECT A
         SKIP
      ENDDO
      IF MDISP_PRT = 'P'
         @ MLINE,0 SAY 'TOTALS:'
         @ MLINE,19 SAY MPURCH PICTURE '9,999,999.99'
         @ MLINE,42 SAY MSELL PICTURE '9,999,999.99'
         @ MLINE,60 SAY MCOMM PICTURE '99,999.99'
         @ MLINE,70 SAY MTOTAL PICTURE '999,999.99'
         
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
         IF MLINE > MPAGE_LEN
            @ 6,0 CLEAR
            MLINE = 6
         ENDIF
         @ MLINE,0 SAY 'TOTALS:'
         @ MLINE,19 SAY MPURCH PICTURE '9,999,999.99'
         @ MLINE,42 SAY MSELL PICTURE '9,999,999.99'
         @ MLINE,60 SAY MCOMM PICTURE '99,999.99'
         @ MLINE,70 SAY MTOTAL PICTURE '999,999.99'
         MPRT_SEL = ' '
         @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
         READ
      ENDIF
      
      CLOSE DATA
      
      
      
   ENDCASE
   CLOSE DATA
   
ENDDO

RETURN

* EOF: SALESRPT.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 4:47 PM.
