**********
* Program.: REPORTS2.PRG
* Author..: GRACE KELLER
* Date....: 10/04/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: POULTRY REPORTS MENU II
* 

*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
CLOSE DATA

STORE 0 TO MACTION
STORE ' ' TO MSEL_RPT2
DO WHILE MSEL_RPT2 <> '9'
   CLOSE DATA
   CLEAR
   @ 1,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 02,00 SAY MPROGRAM + ' - REPORTS MENU II'
   @ 03,00 TO 25,79 
   
   @ 04,09 SAY '1 - REPORT OF ORDERS ON SUPPLIER PAYMENT HOLD'
   @ 06,09 SAY '2 - CALCULATE/PRINT AVERAGE PAYMENT DAYS FOR CUSTOMERS'
   @ 08,09 SAY '3 - AVERAGE NUMBER OF PAYMENT DAYS FOR MFI SHIP TO CUSTOMERS'
   @ 10,09 SAY '4 - PRINT FREIGHT/SUPPLIERS WITH EXPIRING INSURANCE COVERAGES'
   @ 12,09 SAY '5 - SALESPERSON REPORT OF CUSTOMERS OVER CREDIT LIMIT'
   @ 14,09 SAY '6 - PRINT SPREADSHEET REGISTER (Note: WIDE Paper Required)'
   @ 16,09 SAY '7 - PRINT ACTIVE FREIGHT CARRIER LIST (OPTIONAL SALESPERSON)'
   @ 18,09 SAY '8 - PRINT SPREADSHEET TOTALS BY OFFICE/SALESPERSON'                
   
   @ 21,09 SAY '9 - EXIT TO MAIN MENU'
   
   STORE '1' TO MSEL_RPT2
   @ 23,01 SAY 'CHOICE: '
   @ 23,25 say "('X' TO PAGE TO REPORTS MENU III)"
   @ 23,09 GET MSEL_RPT2 PICTURE '@!'
   READ
   
   DO CASE
   CASE MSEL_RPT2 = 'X'
      DO REPORTS3
      
   CASE MSEL_RPT2 = '1'
      MTITLE = ' - PURCHASE ORDERS ON PAYMENT HOLD'
      
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
         @ 10,5 SAY 'DISPLAY OR PRINT REPORT (D/P):'
         @ 10,37 GET MDISP_PRT PICTURE '@!'
         
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
      MPRT_ACT = 'C'
      
      IF MDISP_PRT = 'P'
         DO PRT_SET
         
         IF MPRT_ACT <> 'C'
            LOOP  
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
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      SELECT D
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
      SELECT A
      DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
      MINV = .F. 
      
      MPAGE_NO = 0
      MLINE = 99 
      IF MDISP_PRT = 'P'
         SET CONSOLE OFF
         IF FILE("C:\COMPINFO\PRINTERS.DBF")
            SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
         ELSE
            SET PRINT TO lpt3
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
            @ 1,32 SAY MCOMPANY
            @ 2,0 SAY 'PAGE'
            @ 2,05 say mpage_no picture '99'
            @ 2,24 SAY 'PURCHASE ORDERS ON PAYMENT HOLD'
            @ 2,70 SAY DTOC(DATE())
            @ 4,0 SAY 'SUPPLIER'
            @ 4,22 SAY 'INV NBR'
            @ 4,32 SAY 'PO NUMBER'
            @ 4,44 SAY 'SUP INV NBR'
            @ 4,58 SAY 'DUE DATE'
            @ 4,68 SAY 'AMOUNT DUE'
            IF MDISP_PRT = 'P'
               @ 4,0 SAY REPLICATE ('_',80)
            ELSE
               @ 5,0 SAY REPLICATE ('-',80)
            ENDIF
            MLINE = 6
         ENDIF
         IF HOLD_FLG = ' '
            SKIP
            LOOP
         ENDIF
         MINV = .T.
         
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         STORE RSUPCODE TO MRSUPCODE
         MADJ = 0
         MSW_DIFF = 0
         IF DEB_CRD = ' '
            SELECT B
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF .NOT. EOF()
               IF SUP_PALL < 0
                  STORE (-1 * SW_PURCH) + SUP_AMT1 + SUP_AMT2  + SUP_PALL TO MADJ 
               ELSE
                  STORE (-1 * SW_PURCH) + SUP_AMT1 + SUP_AMT2 TO MADJ 
               ENDIF
               DO TOTDIFF 
               MADJ = MADJ - MSW_DIFF
            ENDIF
         ENDIF
         SELECT C
         SEEK MRSUPCODE
         IF .NOT. EOF()
            STORE NAME TO MNAME
         ELSE
            STORE 'SUPPLIER NAME NOT ON FILE' TO MNAME
         ENDIF
         SELECT A
         @ MLINE,0  SAY SUBSTR(MNAME,1,20)
         IF MSALESMAN <> SPACE(2)
            @ MLINE,22 SAY MSALESMAN + '-'
         ENDIF
         IF SUBSTR(INV_NBR,1,1) = ' ' 
            @ MLINE,25 SAY SUBSTR(INV_NBR,2)
         ELSE
            @ MLINE,25 SAY INV_NBR
         ENDIF
         IF MSALESMAN <> SPACE(2)
            @ MLINE,32 SAY MSALESMAN + '-'
         ENDIF
         @ MLINE,35 SAY MPO_NBR
         IF MPO_SUFFIX <> SPACE(1)
            @ MLINE,39 SAY '-' + MPO_SUFFIX
         ENDIF
         @ MLINE,43 SAY SUP_INV
         @ MLINE,57 SAY DUE_DATE
         @ MLINE,68 SAY AMT_DUE + MADJ PICTURE '999,999.99'
         MLINE = MLINE + 2
         SKIP
      ENDDO
      IF MDISP_PRT = 'P'
         IF .NOT. MINV
            @ MLINE, 3 SAY 'THERE ARE NO INVOICES ON PAYMENT HOLD'
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
         IF .NOT. MINV
            @ MLINE, 3 SAY 'THERE ARE NO INVOICES ON PAYMENT HOLD'
         ENDIF
         MPRT_SEL = ' '
         @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
         READ
      ENDIF
      
   CASE MSEL_RPT2 = '2'
      
      MTITLE = ' - AVERAGE NUMBER OF AGING DAYS FOR REMIT FROM CUSTOMERS'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 25,79
      STORE 'ALL     ' TO MCHOICE
      @ 10,5 SAY 'Do you want all customers (ALL) OR specific customers (SPECIFIC)? ' GET MCHOICE PICTURE '@!' VALID(MCHOICE = 'SPECIFIC' .OR. MCHOICE = 'ALL')
      READ
      @ 10,1 SAY SPACE(78)
      DO CASE
      CASE MCHOICE = 'SPECIFIC'
         STORE DATE() TO MB_DATE, ME_DATE
         STORE 'D' TO MDISP_PRT
         STORE 2 TO MACTION      
         DO WHILE MACTION = 2      
            @ 10,5 SAY '        STARTING SHIPPED DATE: '          
            @ 10,37 GET MB_DATE
            @ 12,5 SAY '          ENDING SHIPPED DATE: '
            @ 12,37 GET ME_DATE
            @ 14,5 SAY 'DISPLAY OR PRINT REPORT (D/P):'
            @ 14,37 GET MDISP_PRT PICTURE '@!'
            
            STORE 1 TO MACTION
            @ 24,00 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
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
            MPAGE_LEN = 22
         ENDIF
         
         STORE MONTH(MB_DATE) TO MMONTH
         MMONTH = MMONTH + 100
         STORE SUBSTR(STR(MMONTH,3),2) TO MMONTH
         
         STORE YEAR(MB_DATE) TO MYEAR
         STORE STR(MYEAR,4) TO MYEAR
         
         SELECT B
         DO FOX_USE WITH "CUS_INV INDEX CUS_SHIP", .F.
         
         SELECT C
         DO FOX_USE WITH "PAYMENTS INDEX PAY_PO", .F.
         MMORE_CUST = .T.
         DO WHILE MMORE_CUST
            MNAME_FD = .F.
            DO BBUYSEL3
            IF .NOT. MNAME_FD
               MMORE_CUST = .F.
               LOOP
            ENDIF
            STORE BBUYCODE TO MSVCODE  
            STORE NAME TO MNAME
            STORE STREET TO MSTREET
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            CLEAR
            MTITLE = ' - AVERAGE NUMBER OF PAYMENT DAYS FOR REMIT TO CUSTOMERS'
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 to 25,79
            @ 10,1 SAY 'CALCULATING.....'
            MPAGE_NO = 0 
            @ 04,1 SAY MNAME
            @ 5,1 SAY TRIM(MSTREET) + ',  ' + TRIM(MCITY) + ',  ' + MSTATE
            @ 6,1 TO 6,78
            STORE 0 TO MNBR_DAYS, MSHIPS
            SELECT B
            SEEK MYEAR + MMONTH
            DO WHILE .NOT. EOF() .AND. SHIP_DATE <= ME_DATE
               IF SHIP_DATE < MB_DATE
                  SKIP
                  LOOP
               ENDIF
               IF BBUYCODE <> MSVCODE
                  SKIP
                  LOOP
               ENDIF
               IF PAID_FLG = ' ' .OR. SUBSTR(INV_NBR,1,1) = 'A' .OR. DEB_CRD = 'Y' .OR. AMT_PAID =  0
                  SKIP
                  LOOP
               ENDIF
               SELECT C
               SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
               
               IF .NOT. EOF()
                  MSHIPS = MSHIPS + 1
                  MNBR_DAYS = MNBR_DAYS + (PAID_DATE - B->SHIP_DATE)
               ENDIF
               SELECT B
               SKIP
            ENDDO
            @ 10,1 SAY SPACE(77)
            @ 9,5  SAY 'TIME PERIOD: ' + DTOC(MB_DATE) + ' - ' + DTOC(ME_DATE)
            @ 12,5 SAY 'AVERAGE NUMBER OF PAYMENT DAYS'
            IF MNBR_DAYS = 0 .OR. MSHIPS = 0
               @ 13,21 SAY '     0.00'
            ELSE 
               @ 13,21 SAY MNBR_DAYS/MSHIPS PICTURE '999999.99'
            ENDIF
            STORE 'PRESS RETURN TO CONTINUE...' TO MWAIT
            @ 24,0 GET MWAIT
            READ
            IF MDISP_PRT = 'P'
               SET CONSOLE OFF
               IF FILE("C:\COMPINFO\PRINTERS.DBF")
                  SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
               ELSE
                  SET PRINT TO lpt3
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
               
               MPAGE_NO = MPAGE_NO + 1
               @ 1,32 SAY MCOMPANY
               @ 2,0 SAY 'PAGE'
               @ 2,05 say mpage_no picture '99'
               @ 2,14 SAY 'AVERAGE NUMBER OF PAYMENT DAYS FOR REMIT TO CUSTOMERS'
               @ 2,70 SAY DTOC(DATE())
               @ 04,24 SAY MNAME
               @ 5,24 SAY TRIM(MSTREET) + ',  ' + TRIM(MCITY) + ',  ' + MSTATE
               @ 7,24 SAY 'TIME PERIOD: ' + DTOC(MB_DATE) + ' - ' + DTOC(ME_DATE)
               @ 8,0 SAY REPLICATE('-',80)
               @ 11,24 SAY 'AVERAGE NUMBER OF PAYMENT DAYS'
               IF MNBR_DAYS = 0 .OR. MSHIPS = 0
                  @ 12,32 SAY '     0.00'
               ELSE
                  @ 12,32 SAY MNBR_DAYS/MSHIPS PICTURE '99999.99'
               ENDIF
               EJECT
               SET DEVICE TO SCREEN
               SET PRINT OFF
               SET PRINT TO
               SET CONSOLE ON
               IF MPRINTER3 <> 'DONOTPRINT'
                  RUN &MPRINTIT3
               ENDIF
            ENDIF
         ENDDO
         
      OTHERWISE         
         STORE DATE() TO MB_DATE, ME_DATE
         STORE 'P' TO MDISP_PRT
         STORE 2 TO MACTION      
         DO WHILE MACTION = 2      
            @ 10,5 SAY '        STARTING SHIPPED DATE: '          
            @ 10,37 GET MB_DATE
            @ 12,5 SAY '          ENDING SHIPPED DATE: '
            @ 12,37 GET ME_DATE
            *        @ 14,5 SAY 'DISPLAY OR PRINT REPORT (D/P):'
            *        @ 14,37 GET MDISP_PRT PICTURE '@!'
            
            STORE 1 TO MACTION
            @ 24,00 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
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
            MPAGE_LEN = 22
         ENDIF
         @ 15,5 SAY 'CALCULATING AND PRINTING......'
         
         STORE MONTH(MB_DATE) TO MMONTH
         MMONTH = MMONTH + 100
         STORE SUBSTR(STR(MMONTH,3),2) TO MMONTH
         
         STORE YEAR(MB_DATE) TO MYEAR
         STORE STR(MYEAR,4) TO MYEAR
         
         SELECT B
         DO FOX_USE WITH "CUS_INV INDEX CUS_SHIP", .F.
         
         SELECT C
         DO FOX_USE WITH "PAYMENTS INDEX PAY_PO", .F.
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         DO WHILE .NOT. EOF()
            DO RECLOCK
            REPLACE NBR_DAYS WITH 0
            REPLACE SHIPS WITH 0
            UNLOCK
            SKIP
         ENDDO
         
         SELECT B
         SEEK MYEAR + MMONTH
         DO WHILE .NOT. EOF() .AND. SHIP_DATE <= ME_DATE
            STORE BBUYCODE TO MBBUYCODE
            IF SHIP_DATE < MB_DATE
               SKIP
               LOOP
            ENDIF
            IF PAID_FLG = ' ' .OR. SUBSTR(INV_NBR,1,1) = 'A' .OR. DEB_CRD = 'Y' .OR. AMT_PAID <> 0
               SKIP
               LOOP
            ENDIF
            SELECT C
            SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
            IF .NOT. EOF()
               MDAYS = (PAID_DATE - B->SHIP_DATE)
               SELECT A
               SEEK MBBUYCODE
               IF .NOT. EOF()
                  DO RECLOCK
                  REPLACE SHIPS WITH SHIPS + 1
                  REPLACE NBR_DAYS WITH NBR_DAYS + MDAYS
                  UNLOCK
               ENDIF
            ENDIF
            SELECT B
            SKIP
         ENDDO
         MPAGE_NO = 0 
         MLINE = 99
         SET CONSOLE OFF
         IF FILE("C:\COMPINFO\PRINTERS.DBF")
            SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
         ELSE
            SET PRINT TO lpt3
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
         
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
         DO WHILE .NOT. EOF()
            IF SHIPS = 0 .OR. NBR_DAYS = 0
               SKIP
               LOOP
            ENDIF
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
               @ 1,32 SAY MCOMPANY
               @ 2,0 SAY 'PAGE'
               @ 2,05 say mpage_no picture '99'
               @ 2,14 SAY 'AVERAGE NUMBER OF PAYMENT DAYS FOR REMIT TO CUSTOMERS'
               @ 2,70 SAY DTOC(DATE())
               @ 4,24 SAY 'TIME PERIOD: ' + DTOC(MB_DATE) + ' - ' + DTOC(ME_DATE)
               @ 5,0 SAY REPLICATE('-',80)
               @ 6,1 SAY 'CUSTOMER'
               @ 6,50 SAY 'AVERAGE NUMBER PAYMENT DAYS'
               IF MDISP_PRT = 'P'
                  @ 6,0 SAY REPLICATE ('_',80)
               ELSE
                  @ 7,0 SAY REPLICATE ('-',80)
               ENDIF
               MLINE = 8
            ENDIF
            @ MLINE,1 SAY NAME
            @ MLINE,58 SAY NBR_DAYS/SHIPS PICTURE '99999.99'
            MLINE = MLINE + 1
            @ MLINE,1 SAY TRIM(STREET) + ', ' + TRIM(CITY) + ', ,' + STATE
            MLINE = MLINE + 2
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
      ENDCASE
      
   CASE MSEL_RPT2 = '3'
      MTITLE = ' - AVERAGE NUMBER OF AGING DAYS FOR MFI SHIP TO CUSTOMERS'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 25,79
      STORE DATE() TO MB_DATE, ME_DATE
      STORE 'P' TO MDISP_PRT
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 10,5 SAY '        STARTING SHIPPED DATE: '          
         @ 10,37 GET MB_DATE
         @ 12,5 SAY '          ENDING SHIPPED DATE: '
         @ 12,37 GET ME_DATE
         *        @ 14,5 SAY 'DISPLAY OR PRINT REPORT (D/P):'
         *        @ 14,37 GET MDISP_PRT PICTURE '@!'
         
         STORE 1 TO MACTION
         @ 24,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
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
         MPAGE_LEN = 22
      ENDIF
      
      STORE MONTH(MB_DATE) TO MMONTH
      MMONTH = MMONTH + 100
      STORE SUBSTR(STR(MMONTH,3),2) TO MMONTH
      
      STORE YEAR(MB_DATE) TO MYEAR
      STORE STR(MYEAR,4) TO MYEAR
      
      SELECT D
      USE TEMP_AGE INDEX TEMP_AGE EXCLUSIVE         
      DELETE ALL
      PACK
      USE
      SELECT D
      DO FOX_USE WITH "TEMP_AGE", .F.
      INDEX ON NAME + RSUPCODE TO TEMP_AGE
      DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE", .F.
      DO FILELOCK
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
      
      SELECT B
      DO FOX_USE WITH "CUS_INV INDEX CUS_SHIP", .F.
      
      SELECT C
      DO FOX_USE WITH "PAYMENTS INDEX PAY_PO", .F.
      CLEAR
      MTITLE = ' - AVERAGE NUMBER OF PAYMENT DAYS FOR MFI SHIP TO CUSTOMERS'
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 25,79
      @ 10,1 SAY 'CALCULATING.....'
      MPAGE_NO = 0 
      STORE 0 TO MNBR_DAYS, MSHIPS
      SELECT B
      SEEK MYEAR + MMONTH
      DO WHILE .NOT. EOF() .AND. SHIP_DATE <= ME_DATE
         IF SHIP_DATE < MB_DATE
            SKIP
            LOOP
         ENDIF
         ** THIS IS THE CODE FOR MFI
         IF BBUYCODE <> ' 123' 
            SKIP
            LOOP
         ENDIF
         IF PAID_FLG = ' ' .OR. SUBSTR(INV_NBR,1,1) = 'A' .OR. DEB_CRD = 'Y' .OR. AMT_PAID <> 0
            SKIP
            LOOP
         ENDIF
         STORE BUY_CODE TO MBUY_CODE
         SELECT C
         SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
         
         IF .NOT. EOF()
            SELECT E
            SEEK MBUY_CODE
            STORE NAME TO MNAME
            
            SELECT D
            SEEK MNAME + MBUY_CODE
            IF EOF()
               APPEND BLANK
               REPLACE NAME WITH MNAME
               REPLACE RSUPCODE WITH MBUY_CODE
            ENDIF
            REPLACE TOT_LBS WITH TOT_LBS + 1
            REPLACE TOT_SW WITH TOT_SW + (C->PAID_DATE - B->SHIP_DATE)
            *              ? DTOC(PAID_DATE) + '   ' + DTOC(B->SHIP_DATE)
         ENDIF
         SELECT B
         SKIP
      ENDDO
      CLOSE DATA
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO lpt3
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
      SELECT A
      DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE", .F.
      DO WHILE .NOT. EOF()
         IF TOT_LBS = 0 .OR. TOT_SW = 0
            SKIP
            LOOP
         ENDIF
         IF MLINE > 58
            IF MLINE <> 99
               EJECT
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,32 SAY MCOMPANY
            @ 2,0 SAY 'PAGE'
            @ 2,05 say mpage_no picture '99'
            @ 2,14 SAY 'AVERAGE NUMBER OF PAYMENT DAYS FOR MFI SHIP TO CUSTOMERS'
            @ 2,70 SAY DTOC(DATE())
            @ 4,24 SAY 'TIME PERIOD: ' + DTOC(MB_DATE) + ' - ' + DTOC(ME_DATE)
            @ 6,1 SAY 'CUSTOMER'
            @ 6,40 SAY 'AVERAGE NUMBER OF PAYMENT DAYS'
            @ 6,0 SAY REPLICATE('_',80)
            MLINE = 8
         ENDIF
         @ MLINE,1 SAY NAME
         @ MLINE,49 SAY TOT_sw/TOT_lbs PICTURE '99999.99'
         MLINE = MLINE + 2
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
      
   CASE MSEL_RPT2 = '4'
      MTITLE = ' - FRT/SUP WITH NONE/EXPIRING INSURANCE COVERAGE'        
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      STORE DATE() TO MDATE
      MCUTOFF = DATE() - 180
      STORE 2 TO MACTION      
      STORE SPACE(8) TO MCHOICE
      DO WHILE MACTION = 2
         
         @ 08,5 SAY '        Activity Cutoff Date:'
         @ 08,35 GET MCUTOFF
         @ 10,5 SAY '(Note: Will not be included if last    )'
         @ 11,5 SAY '(      activity was prior to this date.)'
         @ 14,5 SAY 'Report Date when Coverages will Expire:'          
         @ 14,46 GET MDATE
         @ 17,5 SAY 'Select Freight  (FREIGHT)  OR'
         @ 18,5 say '       Supplier (SUPPLIER) Report:'
         @ 18,41 GET MCHOICE PICTURE '@!' VALID(MCHOICE = 'SUPPLIER' .OR. MCHOICE = 'FREIGHT')
         STORE 1 TO MACTION
         @ 24,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF DTOC(MCUTOFF) = '  /  /  '      
               @ 24,0 CLEAR
               MERROR = 'CUTOFF DATE NOT ENTERED - PRESS RETURN TO REENTER'
               @ 24,3 GET MERROR
               CLEAR GETS
               MWAIT = ' '
               @ 24,1 GET MWAIT
               READ
               @ 24,0 CLEAR
               MACTION = 2
               LOOP
            ENDIF
            IF DTOC(MDATE) = '  /  /  '      
               @ 24,0 CLEAR
               MERROR = 'EXPIRATION DATE NOT ENTERED - PRESS RETURN TO REENTER'
               @ 24,3 GET MERROR
               CLEAR GETS
               MWAIT = ' '
               @ 24,1 GET MWAIT
               READ
               @ 24,0 CLEAR
               MACTION = 2
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
      MPAGE_LEN = 56
      
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
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
      MLINE = 99
      MPAGE_NO = 0
      DO CASE
      CASE MCHOICE = 'FREIGHT'
         SELECT B
         DO FOX_USE WITH "PO_HEAD INDEX TMP_FRT", .F.
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
         DO WHILE .NOT. EOF()
            IF NAME = 'X' .OR. NAME = 'NONE' .OR. NAME = 'TBA'
               SKIP
               LOOP
            ENDIF
            SELECT B
            SEEK A->FRT_CODE 
            IF EOF()
               SELECT A
               SKIP
               LOOP
            ENDIF
            
            IF SHIP_DATE < MCUTOFF
               SELECT A
               SKIP
               LOOP
            ENDIF
            
            SELECT A
            STORE .F. TO MAUTO_EXP, MCARGO_EXP, MGEN_EXP, MWORK_EXP
            IF POLICY2 = SPACE(20)
               MAUTO_EXP = .T.
            ELSE
               IF DTOC(AUTO_END) = '  /  /  ' 
                  IF DTOC(AUTO_BEG) = '  /  /  '
                     MAUTO_EXP = .T.
                  ELSE
                     IF AUTO_BEG+365 <= MDATE
                        MAUTO_EXP = .T.
                     ENDIF
                  ENDIF
               ELSE
                  IF AUTO_END <= MDATE
                     MAUTO_EXP = .T.
                  ENDIF
               ENDIF
            ENDIF
            IF POLICY4 = SPACE(20)
               MCARGO_EXP = .T.
            ELSE
               IF DTOC(CARGO_END) = '  /  /  ' 
                  IF DTOC(CARGO_BEG) = '  /  /  '
                     MCARGO_EXP = .T.
                  ELSE
                     IF CARGO_BEG+365 <= MDATE
                        MCARGO_EXP = .T.
                     ENDIF
                  ENDIF
               ELSE
                  IF CARGO_END <= MDATE
                     MCARGO_EXP = .T.
                  ENDIF
               ENDIF
            ENDIF
            
            
            IF POLICY1 = SPACE(20)
               MGEN_EXP = .T.
            ELSE
               IF DTOC(GEN_END) = '  /  /  ' 
                  IF DTOC(GEN_BEG) = '  /  /  '
                     MGEN_EXP = .T.
                  ELSE
                     IF GEN_BEG+365 <= MDATE
                        MGEN_EXP = .T.
                     ENDIF
                  ENDIF
               ELSE
                  IF GEN_END <= MDATE
                     MGEN_EXP = .T.
                  ENDIF
               ENDIF
            ENDIF
            
            IF POLICY3 = SPACE(20)
               MWORK_EXP = .T.
            ELSE
               IF DTOC(WORK_END) = '  /  /  ' 
                  IF DTOC(WORK_BEG) = '  /  /  '
                     MWORK_EXP = .T.
                  ELSE
                     IF WORK_BEG+365 <= MDATE
                        MWORK_EXP = .T.
                     ENDIF
                  ENDIF
               ELSE
                  IF WORK_END <= MDATE
                     MWORK_EXP = .T.
                  ENDIF
               ENDIF
            ENDIF

            ** AS OF DEC 2019 - DONT CHECK FOR WORKERS COMP
            MWORK_EXP = .F.

            IF  MAUTO_EXP .OR. MCARGO_EXP .OR. MGEN_EXP .OR. MWORK_EXP
            ELSE
               SKIP
               LOOP
            ENDIF  

            IF MLINE > 56
               IF MLINE <> 99
                  EJECT
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 1,32 SAY MCOMPANY
               @ 2,0 SAY 'PAGE'
               @ 2,05 say mpage_no picture '99'
               @ 2,14 SAY 'FREIGHT CARRIERS WITH INSURANCE COVERAGE(S) EXPIRING BY ' + DTOC(MDATE)
               @ 2,85 SAY DTOC(DATE())
               @ 3,19 SAY 'AND FREIGHT CARRIERS WITH NO INSURANCE COVERAGE'
               @ 5,1 SAY 'FREIGHT CARRIER                      EXPIRATION DATE    TYPE            POLICY #'
               @ 5,0 SAY REPLICATE('_',85)
               MLINE = 7
            ENDIF
            
            MFRT_LINE = 0
            
            IF MGEN_EXP
               MFRT_LINE = MFRT_LINE + 1
               IF MFRT_LINE = 1
                  @ MLINE,1 SAY NAME
               ENDIF
               DO CASE
               CASE POLICY1 = SPACE(20)
                  @ MLINE,38 SAY '* NO COVERAGE *'
               CASE DTOC(GEN_BEG) = '  /  /  ' .AND. DTOC(GEN_END) = '  /  /  '
                  @ MLINE,38 SAY '* NO COVERAGE *'
               OTHERWISE
                  IF DTOC(GEN_END) <> '  /  /  '
                     @ MLINE,41 SAY GEN_END
                  ELSE
                     @ MLINE,41 SAY GEN_BEG + 365
                  ENDIF
                  @ MLINE,73 SAY POLICY1
               ENDCASE
               @ MLINE,57 SAY 'GENERAL'
               MLINE = MLINE + 1
            ENDIF
            
            
            IF MAUTO_EXP
               MFRT_LINE = MFRT_LINE + 1
               DO CASE
               CASE MFRT_LINE = 1
                  @ MLINE,1 SAY NAME
               CASE MFRT_LINE = 2
                  @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE
               ENDCASE
               DO CASE
               CASE POLICY2 = SPACE(20)
                  @ MLINE,38 SAY '* NO COVERAGE *'
               CASE DTOC(AUTO_BEG) = '  /  /  ' .AND. DTOC(AUTO_END) = '  /  /  '
                  @ MLINE,38 SAY '* NO COVERAGE *'
               OTHERWISE
                  IF DTOC(AUTO_END) <> '  /  /  '
                     @ MLINE,41 SAY AUTO_END
                  ELSE
                     @ MLINE,41 SAY AUTO_BEG + 365
                  ENDIF
                  @ MLINE,73 SAY POLICY2
               ENDCASE
               @ MLINE,57 SAY 'AUTO'
               MLINE = MLINE + 1
            ENDIF
            
            
            IF MWORK_EXP
               MFRT_LINE = MFRT_LINE + 1
               DO CASE
               CASE MFRT_LINE = 1
                  @ MLINE,1 SAY NAME
               CASE MFRT_LINE = 2
                  @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE
               CASE MFRT_LINE = 3
                  @ MLINE,1 SAY '(' + AREA_CODE + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4)
               ENDCASE
               DO CASE
               CASE POLICY3 = SPACE(20)
                  @ MLINE,38 SAY '* NO COVERAGE *'
               CASE DTOC(WORK_BEG) = '  /  /  ' .AND. DTOC(WORK_END) = '  /  /  '
                  @ MLINE,38 SAY '* NO COVERAGE *'
               OTHERWISE
                  IF DTOC(WORK_END) <> '  /  /  '
                     @ MLINE,41 SAY WORK_END
                  ELSE
                     @ MLINE,41 SAY WORK_BEG + 365
                  ENDIF
                  @ MLINE,73 SAY POLICY3
               ENDCASE
               @ MLINE,57 SAY 'WORKERS COMP'
               MLINE = MLINE + 1
            ENDIF
            
            IF MCARGO_EXP
               MFRT_LINE = MFRT_LINE + 1
               DO CASE
               CASE MFRT_LINE = 1
                  @ MLINE,1 SAY NAME
               CASE MFRT_LINE = 2
                  @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE
               CASE MFRT_LINE = 3
                  @ MLINE,1 SAY '(' + AREA_CODE + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4)
               ENDCASE
               DO CASE
               CASE POLICY4 = SPACE(20)
                  @ MLINE,38 SAY '* NO COVERAGE *'
               CASE DTOC(CARGO_BEG) = '  /  /  ' .AND. DTOC(CARGO_END) = '  /  /  '
                  @ MLINE,38 SAY '* NO COVERAGE *'
               OTHERWISE
                  IF DTOC(CARGO_END) <> '  /  /  '
                     @ MLINE,41 SAY CARGO_END
                  ELSE
                     @ MLINE,41 SAY CARGO_BEG + 365
                  ENDIF
                  @ MLINE,73 SAY POLICY4
               ENDCASE
               @ MLINE,57 SAY 'CARGO'      
               MLINE = MLINE + 1
            ENDIF
            
            DO WHILE MFRT_LINE < 3
               MFRT_LINE = MFRT_LINE + 1
               DO CASE
               CASE MFRT_LINE = 2
                  @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE
                  MLINE = MLINE + 1
               CASE MFRT_LINE = 3
                  @ MLINE,1 SAY '(' + AREA_CODE + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4)
                  MLINE = MLINE + 1
               ENDCASE
            ENDDO
            MLINE = MLINE + 1
            SKIP
         ENDDO

      OTHERWISE
         *** NOW DO SUPPLIER
         SELECT B
         DO FOX_USE WITH "PO_HEAD INDEX TMP_SUP", .F.
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
         DO WHILE .NOT. EOF()
            IF NAME = 'INVENTORY' .OR. NAME = 'AMERICHICKEN' .OR. NAME = 'NONE'
               SKIP
               LOOP
            ENDIF
            IF NAME <> 'XINSURANCE'
               SELECT B
               SEEK A->RSUPCODE 
               IF EOF()
                  SELECT A
                  SKIP
                  LOOP
               ENDIF
               
               IF SHIP_DATE < MCUTOFF
                  SELECT A
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT A
            
            IF NAME = 'XINVENTORY UNITED'
               SUSPEND
            ENDIF
            
            STORE .F. TO MAUTO_EXP, MEXCES_EXP, MGEN_EXP, MWORK_EXP, MRECAL_EXP
            
            IF POLICY1 = SPACE(20)
               MGEN_EXP = .T.
            ELSE
               IF DTOC(GEN_END) = '  /  /  ' 
                  IF DTOC(GEN_BEG) = '  /  /  '
                     MGEN_EXP = .T.
                  ELSE
                     IF GEN_BEG+365 <= MDATE
                        MGEN_EXP = .T.
                     ENDIF
                  ENDIF
               ELSE
                  IF GEN_END <= MDATE
                     MGEN_EXP = .T.
                  ENDIF
               ENDIF
            ENDIF
            
            IF POLICY2 = SPACE(20)
               MAUTO_EXP = .T.
            ELSE
               IF DTOC(AUTO_END) = '  /  /  ' 
                  IF DTOC(AUTO_BEG) = '  /  /  '
                     MAUTO_EXP = .T.
                  ELSE
                     IF AUTO_BEG+365 <= MDATE
                        MAUTO_EXP = .T.
                     ENDIF
                  ENDIF
               ELSE
                  IF AUTO_END <= MDATE
                     MAUTO_EXP = .T.
                  ENDIF
               ENDIF
            ENDIF
            
            IF POLICY3 = SPACE(20)
               MWORK_EXP = .T.
            ELSE
               IF DTOC(WORK_END) = '  /  /  ' 
                  IF DTOC(WORK_BEG) = '  /  /  '
                     MWORK_EXP = .T.
                  ELSE
                     IF WORK_BEG+365 <= MDATE
                        MWORK_EXP = .T.
                     ENDIF
                  ENDIF
               ELSE
                  IF WORK_END <= MDATE
                     MWORK_EXP = .T.
                  ENDIF
               ENDIF
            ENDIF
            
            IF POLICY4 = SPACE(20)
               MEXCES_EXP = .T.
            ELSE
               IF DTOC(EXCES_END) = '  /  /  ' 
                  IF DTOC(EXCES_BEG) = '  /  /  '
                     MEXCES_EXP = .T.
                  ELSE
                     IF EXCES_BEG+365 <= MDATE
                        MEXCES_EXP = .T.
                     ENDIF
                  ENDIF
               ELSE
                  IF EXCES_END <= MDATE
                     MEXCES_EXP = .T.
                  ENDIF
               ENDIF
            ENDIF
            
            IF POLICY5 = SPACE(20)
               MRECAL_EXP = .T.
            ELSE
               IF DTOC(RECAL_END) = '  /  /  ' 
                  IF DTOC(RECAL_BEG) = '  /  /  '
                     MRECAL_EXP = .T.
                  ELSE
                     IF RECAL_BEG+365 <= MDATE
                        MRECAL_EXP = .T.
                     ENDIF
                  ENDIF
               ELSE
                  IF RECAL_END <= MDATE
                     MRECAL_EXP = .T.
                  ENDIF
               ENDIF
            ENDIF
            
            IF  MAUTO_EXP .OR. MEXCES_EXP .OR. MGEN_EXP .OR. MWORK_EXP .OR. MRECAL_EXP
            ELSE
               SKIP
               LOOP
            ENDIF  
            IF MLINE > 58
               IF MLINE <> 99
                  EJECT
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 1,32 SAY MCOMPANY
               @ 2,0 SAY 'PAGE'
               @ 2,05 say mpage_no picture '99'
               @ 2,12 SAY 'REMIT TO SUPPLIERS WITH INSURANCE COVERAGE(S) EXPIRING BY ' + DTOC(MDATE)
               @ 2,85 SAY DTOC(DATE())
               @ 3,22 SAY 'AND SUPPLIERS WITH NO INSURANCE COVERAGE'
               @ 5,1 SAY 'SUPPLIER                             EXPIRATION DATE    TYPE            POLICY #'
               @ 5,0 SAY REPLICATE('_',85)
               MLINE = 7
            ENDIF
            
            MFRT_LINE = 0
            
            IF MGEN_EXP
               MFRT_LINE = MFRT_LINE + 1
               DO CASE
               CASE POLICY1 = SPACE(20)
                  @ MLINE,38 SAY '* NO COVERAGE *'
               CASE DTOC(GEN_BEG) = '  /  /  ' .AND. DTOC(GEN_END) = '  /  /  '
                  @ MLINE,38 SAY '* NO COVERAGE *'
               OTHERWISE
                  IF DTOC(GEN_END) <> '  /  /  '
                     @ MLINE,41 SAY GEN_END
                  ELSE
                     @ MLINE,41 SAY GEN_BEG + 365
                  ENDIF
                  @ MLINE,73 SAY POLICY1
               ENDCASE
               @ MLINE,57 SAY 'GENERAL'
               DO CASE
               CASE MFRT_LINE = 1
                  @ MLINE,1 SAY NAME
                  MLINE = MLINE + 1
               ENDCASE
            ENDIF
            
            IF MAUTO_EXP
               MFRT_LINE = MFRT_LINE + 1
               DO CASE
               CASE POLICY2 = SPACE(20)
                  @ MLINE,38 SAY '* NO COVERAGE *'
               CASE DTOC(AUTO_BEG) = '  /  /  ' .AND. DTOC(AUTO_END) = '  /  /  '
                  @ MLINE,38 SAY '* NO COVERAGE *'
               OTHERWISE
                  IF DTOC(AUTO_END) <> '  /  /  '
                     @ MLINE,41 SAY AUTO_END
                  ELSE
                     @ MLINE,41 SAY AUTO_BEG + 365
                  ENDIF
                  @ MLINE,73 SAY POLICY2
               ENDCASE
               @ MLINE,57 SAY 'AUTO'
               DO CASE
               CASE MFRT_LINE = 1
                  @ MLINE,1 SAY NAME
                  MLINE = MLINE + 1
               CASE MFRT_LINE = 2
                  @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE
                  MLINE = MLINE + 1
               ENDCASE
            ENDIF
            
            IF MWORK_EXP
               MFRT_LINE = MFRT_LINE + 1
               DO CASE
               CASE POLICY3 = SPACE(20)
                  @ MLINE,38 SAY '* NO COVERAGE *'
               CASE DTOC(WORK_BEG) = '  /  /  ' .AND. DTOC(WORK_END) = '  /  /  '
                  @ MLINE,38 SAY '* NO COVERAGE *'
               OTHERWISE
                  IF DTOC(WORK_END) <> '  /  /  '
                     @ MLINE,41 SAY WORK_END
                  ELSE
                     @ MLINE,41 SAY WORK_BEG + 365
                  ENDIF
                  @ MLINE,73 SAY POLICY3
               ENDCASE
               @ MLINE,57 SAY 'WORKERS COMP'
               DO CASE
               CASE MFRT_LINE = 1
                  @ MLINE,1 SAY NAME
                  MLINE = MLINE + 1
               CASE MFRT_LINE = 2
                  @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE
                  MLINE = MLINE + 1
               CASE MFRT_LINE = 3
                  @ MLINE,1 SAY '(' + AREA_CODE + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4)
                  MLINE = MLINE + 1
               ENDCASE
            ENDIF
            
            IF MEXCES_EXP
               MFRT_LINE = MFRT_LINE + 1
               DO CASE
               CASE POLICY4 = SPACE(20)
                  @ MLINE,38 SAY '* NO COVERAGE *'
               CASE DTOC(EXCES_BEG) = '  /  /  ' .AND. DTOC(EXCES_END) = '  /  /  '
                  @ MLINE,38 SAY '* NO COVERAGE *'
               OTHERWISE
                  IF DTOC(EXCES_END) <> '  /  /  '
                     @ MLINE,41 SAY EXCES_END
                  ELSE
                     @ MLINE,41 SAY EXCES_BEG + 365
                  ENDIF
                  @ MLINE,73 SAY POLICY4
               ENDCASE
               @ MLINE,57 SAY 'EXCESS LIAB'
               DO CASE
               CASE MFRT_LINE = 1
                  @ MLINE,1 SAY NAME
                  MLINE = MLINE + 1
               CASE MFRT_LINE = 2
                  @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE
                  MLINE = MLINE + 1
               CASE MFRT_LINE = 3
                  @ MLINE,1 SAY '(' + AREA_CODE + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4)
                  MLINE = MLINE + 1
               OTHERWISE 
                  MLINE = MLINE + 1
               ENDCASE
            ENDIF
            
            IF MRECAL_EXP
               MFRT_LINE = MFRT_LINE + 1
               DO CASE
               CASE POLICY5 = SPACE(20)
                  @ MLINE,38 SAY '* NO COVERAGE *'
               CASE DTOC(RECAL_BEG) = '  /  /  ' .AND. DTOC(RECAL_END) = '  /  /  '
                  @ MLINE,38 SAY '* NO COVERAGE *'
               OTHERWISE
                  IF DTOC(RECAL_END) <> '  /  /  '
                     @ MLINE,41 SAY RECAL_END
                  ELSE
                     @ MLINE,41 SAY RECAL_BEG + 365
                  ENDIF
                  @ MLINE,73 SAY POLICY5
               ENDCASE
               @ MLINE,57 SAY 'PROD RECALL'
               DO CASE
               CASE MFRT_LINE = 1
                  @ MLINE,1 SAY NAME
                  MLINE = MLINE + 1
               CASE MFRT_LINE = 2
                  @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE
                  MLINE = MLINE + 1
               CASE MFRT_LINE = 3
                  @ MLINE,1 SAY '(' + AREA_CODE + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4)
                  MLINE = MLINE + 1
               OTHERWISE 
                  MLINE = MLINE + 1
               ENDCASE
            ENDIF
            
            DO WHILE MFRT_LINE < 3
               MFRT_LINE = MFRT_LINE + 1
               DO CASE
               CASE MFRT_LINE = 2
                  @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE
                  MLINE = MLINE + 1
               CASE MFRT_LINE = 3
                  @ MLINE,1 SAY '(' + AREA_CODE + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4)
                  MLINE = MLINE + 1
               ENDCASE
            ENDDO
            MLINE = MLINE + 1
            SKIP
         ENDDO
      ENDCASE
      
      IF MLINE <> 99
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
      
   CASE MSEL_RPT2 = '5'
      MTITLE = ' - SALESPERSON CUSTOMER CREDIT REPORT'                    
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      @ 17,15 SAY 'CALCULATING CURRENT CUSTOMER BALANCES.... PLEASE WAIT...'
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      DO WHILE .NOT. EOF()
         DO RECLOCK
         REPLACE BAL_CALC WITH 0
         UNLOCK
         SKIP
      ENDDO
      
      SELECT F
      DO FOX_USE WITH "INV_HEAD INDEX INV_HEAD", .F.
      
      SELECT B
      DO FOX_USE WITH "INV_ADJ INDEX INV_ADJ", .F.
      
      SELECT A
      DO FOX_USE WITH "CUS_INV INDEX CUS_DATE", .F.
      SEEK ' '
      
      DO WHILE .NOT. EOF() .AND. PAID_FLG = ' '
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
         SELECT A
         MOVERDUE = 0             
         MBALANCE = 0
         DO WHILE .NOT. EOF() .AND. PAID_FLG = ' ' .AND. BBUYCODE = MBBUYCODE
            MSTILL_DUE = (TOT_SELL + CUS_PALL) - AMT_PAID
            IF MSTILL_DUE > 0 
               MBALANCE = MBALANCE + MSTILL_DUE
            ENDIF
            SKIP
         ENDDO
         
         SELECT C 
         *** SEEK MBBUYCODE
         IF .NOT. EOF()
            DO RECLOCK
            REPLACE BAL_CALC WITH MBALANCE 
            UNLOCK
         ENDIF
         SELECT A
      ENDDO
      CLOSE DATA
      
      ***** NOW START THE EXTRACTION PROCESS FOR THOSE CUSTOMERS THAT
      ***** HAVE OUTSTANDING RECEIVABLES THAT ARE MORE THAN THEIR LIMIT
      
      CLOSE DATA
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      
      STORE '**' TO MCODE
      STORE 1  TO MTIMES
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 13,5 SAY ' SALESPERSON CODE: '
         @ 13,24 GET MCODE               
         @ 14,5 SAY " (ENTER '**' IF REPORT DESIRED FOR ALL SALESPERSONS)"
         @ 16,5 SAY 'NUMBER OF REPORTS: '
         @ 16,24 GET MTIMES PICTURE '#' RANGE 1,3
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
      
      MPRT_ACT = 'C'
      
      DO PRT_SET
      
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      
      SELECT E
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      SELECT F
      DO FOX_USE WITH "INV_HEAD INDEX INV_HEAD", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      
      SELECT D
      USE CRED_AGE EXCLUSIVE         
      DELETE ALL
      PACK
      USE
      
      SELECT D
      DO FOX_USE WITH "CRED_AGE", .F.
      INDEX ON SALESMAN + NAME  + BBUYCODE TO CRED_AGE
      DO FOX_USE WITH "CRED_AGE INDEX CRED_AGE", .F.
      
      SELECT A
      DO FOX_USE WITH "CUS_INV INDEX CUS_DATE", .F.
      
      SELECT C
      
      DO WHILE .NOT. EOF()
         IF BAL_CALC <= CRED_LIM
            SKIP
            LOOP
         ENDIF
         
         SELECT A
         
         SEEK ' ' + C->BBUYCODE
         
         DO WHILE .NOT. EOF() .AND. PAID_FLG = ' ' .AND. BBUYCODE = C->BBUYCODE
            
            MBALANCE = 0
            
            IF MCODE <> '**'
               IF SALESMAN <> MCODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            MSTILL_DUE = (TOT_SELL+CUS_PALL) - AMT_PAID
            IF MSTILL_DUE <= 0
               SKIP
               LOOP
            ENDIF
            
            SELECT F
            SEEK A->INV_NBR
            IF EOF()
               STORE 0 TO MTOT_SELL       
            ELSE
               STORE TOT_SELL TO MTOT_SELL        
            ENDIF
            
            SELECT E
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
            IF EOF()
               STORE SPACE(15) TO MBUYER_PO
            ELSE
               STORE BUYER_PO TO MBUYER_PO
            ENDIF
            
            IF DTOC(SHIP_DATE) <> '  /  /  '
               STORE SHIP_DATE TO MTRAN_DATE    
            ELSE
               STORE INV_DATE TO MTRAN_DATE   
            ENDIF
            
            SELECT D
            DO FILELOCK
            APPEND BLANK
            REPLACE NAME WITH C->NAME
            REPLACE BBUYCODE WITH C->BBUYCODE
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE TOT_SELL WITH MTOT_SELL
            REPLACE STILL_DUE WITH MSTILL_DUE            
            REPLACE TRAN_DATE WITH MTRAN_DATE
            REPLACE BUYER_PO WITH MBUYER_PO
            UNLOCK
            
            SELECT A
            SKIP
         ENDDO
         
         SELECT C
         SKIP
      ENDDO
      
      CLOSE DATA
      
      SET PROCEDURE TO REPORTS2
      ************************************ 
      **** NOW DO THE PRINT PART HERE ****
      ************************************ 
      I = 1
      DO WHILE I <= MTIMES
         MPAGE_NO = 0
         MLINE = 99 
         MPAGE_LEN = 58
         
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
         ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
         
         *** LETTER SIZE PAPER
         ?? CHR(27) + '&l2A'
         
         *** PORTRAIT MODE
         ?? CHR(27) + '&l0O'
         
         MDATE = DATE()
         SELECT C
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         SELECT D
         DO FOX_USE WITH "CRED_AGE INDEX CRED_AGE", .F.
         
         DO WHILE .NOT. EOF()
            MSALESMAN = SALESMAN
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
            ELSE
               STORE SPACE(32) TO MSAL_NAME
            ENDIF
            MPAGE_NO = 0
            **** FORCE A PAGE BREAK BETWEEN SALESPERSONS
            IF MLINE <> 99
               MLINE = 88
            ENDIF
            
            SELECT D
            DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
               STORE BBUYCODE TO MBBUYCODE
               STORE NAME TO MNAME      
               SELECT C
               SEEK MBBUYCODE
               STORE BAL_CALC TO MBALANCE
               STORE CRED_LIM TO MCRED_LIM
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
               
               MBALANCE = 0
               MPRT_CUST = .T.
               
               SELECT D
               DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. BBUYCODE = MBBUYCODE .AND. NAME = MNAME
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
                  @ MLINE,12 SAY TOT_SELL PICTURE '999,999.99'
                  @ MLINE,25 SAY STILL_DUE PICTURE '999,999.99'
                  @ MLINE,40 SAY BUYER_PO
                  IF SALESMAN <> '  '
                     @ MLINE,56 SAY SALESMAN + '-'
                  ENDIF
                  @ MLINE,59 SAY PO_NBR
                  IF PO_SUFFIX <> SPACE(1)
                     @ MLINE,63 SAY '-' + PO_SUFFIX
                  ENDIF
                  @ MLINE,70 SAY TRAN_DATE
                  STORE MDATE - TRAN_DATE TO MDAYS
                  @ MLINE,82 SAY MDAYS PICTURE '999'
                  MBALANCE = MBALANCE + STILL_DUE       
                  MLINE = MLINE + 1
                  SKIP
               ENDDO
               
               **** DO CUSTOMER BALANCE INFORMATION HERE
               IF MLINE +6 > MPAGE_LEN
                  MPRT_CUST = .T.
                  DO AGE_HEAD
               ENDIF
               MLINE = MLINE + 1
               @ MLINE,5 SAY '    TOTAL DUE:'      
               @ MLINE,25 SAY MBALANCE PICTURE '999,999.99'
               IF MAVG_180 <> 0                        
                  @ MLINE,40 SAY 'PAST 6 MONTHS AVG. PAY:'      
                  @ MLINE,64 SAY MAVG_180 PICTURE '999,999.99'
               ENDIF
               MLINE = MLINE + 1
               @ MLINE,5 SAY ' CREDIT LIMIT:'      
               @ MLINE,25 SAY MCRED_LIM PICTURE '999,999.99'
               IF MAVG_25 <> 0 
                  @ MLINE,40 SAY ' PAST 25 DAYS AVG. PAY:'      
                  @ MLINE,64 SAY MAVG_25  PICTURE '999,999.99'
               ENDIF
               MLINE = MLINE + 1
               @ MLINE,1 SAY 'AMOUNT OVER LIMIT:'      
               @ MLINE,25 SAY MBALANCE - MCRED_LIM PICTURE '999,999.99'
               MLINE = MLINE + 3
            ENDDO
         ENDDO
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
         CLOSE DATA
         I = I + 1
      ENDDO
      SET PROCEDURE TO PO_PROC
      
      LOOP
      
      
   CASE MSEL_RPT2 = '6'
      SET PROCEDURE TO REPORTS2
      
      MTITLE = ' - SPREADSHEET REGISTER'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE DATE() TO MDATE
      STORE CTOD(' ') TO MSTART, MLAST
      STORE 'P' TO MDISP_PRT
      STORE '  ' TO MTRAN_MO
      STORE SPACE(4) TO MTRAN_YR
      STORE 'DETAILS' TO MCHOICE
      MINV_COR = 'C'
      STORE 'Y' TO MYES_NO
      STORE 2 TO MACTION      
      MPOSTIT = 'U'
      DO WHILE MACTION = 2      
         @ 08,5 SAY '           ENTER BEGINNING REPORT DATE: ' GET MSTART
         @ 10,5 SAY '              ENTER ENDING REPORT DATE: ' GET MLAST
         @ 12,5 SAY 'SELECT INVOICES (I) OR CORRECTIONS (C): ' GET MINV_COR PICTURE '@!' VALID(MINV_COR = 'C' .OR. MINV_COR = 'I')
         @ 14,2 say 'SELECT POSTED (P) OR UNPOSTED (U) ENTRIES: ' GET MPOSTIT PICTURE '@!' VALID(MPOSTIT = 'P' .OR. MPOSTIT = 'U')
         STORE 1 TO MACTION
         @ 23,00 CLEAR
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
      MTOT_RPT = 'N'
      IF MPOSTIT = 'P'
         MQUESTION = '   PRINT ONLY TOTALS BY DAY REPORT (Y/N)?: ' 
         @ 16,2 GET MQUESTION
         CLEAR GETS
         @ 16,46 GET MTOT_RPT PICTURE '@!'
         READ
      ENDIF
      MPRT_ACT = 'C'
      
      *DO PRT_132
      *DO PRT_SET
      IF MPRT_ACT <> 'C'
         RETURN
      ENDIF
      MPAGE_LEN = 44
      MPAGE_NO = 0
      @ 19,16 SAY 'PROCESSING........'
      IF MDISP_PRT = 'P'
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
         ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
         
         *** LANDSCAPE MODE
         ?? CHR(27) + '&l1O'
         
         *** LEGAL SIZE PAPER
         ?? CHR(27) + '&l3A'
         
      ENDIF
      MLINE = 99
      
      STORE MONTH(MSTART) TO MSTRT_MO   
      MSTRT_MO = MSTRT_MO + 100
      STORE SUBSTR(STR(MSTRT_MO,3),2) TO MSTRT_MO
      
      STORE MONTH(MLAST) TO MLAST_MO   
      MLAST_MO = MLAST_MO + 100
      STORE SUBSTR(STR(MLAST_MO,3),2) TO MLAST_MO
      
      STORE YEAR(MSTART) TO MSTRT_YR
      STORE STR(MSTRT_YR,4) TO MSTRT_YR
      
      STORE YEAR(MLAST) TO MLAST_YR
      STORE STR(MLAST_YR,4) TO MLAST_YR
      
      STORE DAY(MSTART) TO MSTRT_DAY
      MSTRT_DAY = MSTRT_DAY + 100
      STORE SUBSTR(STR(MSTRT_DAY,3),2) TO MSTRT_DAY
      
      STORE DAY(MLAST) TO MLAST_DAY
      MLAST_DAY = MLAST_DAY + 100
      STORE SUBSTR(STR(MLAST_DAY,3),2) TO MLAST_DAY
      SELECT A
      DO FOX_USE WITH "DAILYJRN INDEX POSTED", .F.
      SELECT C
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      SELECT D
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      SELECT A
      DO CASE 
      CASE MINV_COR = 'C'
         IF MPOSTIT = 'U'
            MPOSTIT = ' '
            SEEK ' C' + MSTRT_YR+MSTRT_MO+MSTRT_DAY
            IF EOF()
               SEEK ' C' + MSTRT_YR+MSTRT_MO            
               DO WHILE .NOT. EOF() .AND. POST_FLG = MPOSTIT .AND. INV_COR = MINV_COR .AND. TRAN_DATE <= MSTART
                  SKIP
               ENDDO
            ENDIF
         ELSE
            SEEK 'PC' + MSTRT_YR+MSTRT_MO+MSTRT_DAY
            MPOSTIT = 'P'
            IF EOF()
               SEEK 'PC' + MSTRT_YR+MSTRT_MO            
               DO WHILE .NOT. EOF() .AND. POST_FLG = MPOSTIT .AND. INV_COR = MINV_COR .AND. TRAN_DATE <= MSTART
                  SKIP
               ENDDO
            ENDIF
         ENDIF
      OTHERWISE
         IF MPOSTIT = 'U'
            SEEK ' I' + MSTRT_YR+MSTRT_MO+MSTRT_DAY
            MPOSTIT = ' '
            IF EOF()
               SEEK ' I' + MSTRT_YR+MSTRT_MO            
               DO WHILE .NOT. EOF() .AND. POST_FLG = MPOSTIT .AND. INV_COR = MINV_COR .AND. TRAN_DATE <= MSTART
                  SKIP
               ENDDO
            ENDIF
         ELSE
            SEEK 'PI' + MSTRT_YR+MSTRT_MO+MSTRT_DAY
            MPOSTIT = 'P'
            IF EOF()
               SEEK 'PI' + MSTRT_YR+MSTRT_MO            
               DO WHILE .NOT. EOF() .AND. POST_FLG = MPOSTIT .AND. INV_COR = MINV_COR .AND. TRAN_DATE <= MSTART
                  SKIP
               ENDDO
            ENDIF
         ENDIF
      ENDCASE
      MPAGE_NO = 0
      MLINE = 99 
      IF MDISP_PRT = 'P'
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
         ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
         
         *** LANDSCAPE MODE
         ?? CHR(27) + '&l1O'
         
         *** LEGAL SIZE PAPER
         ?? CHR(27) + '&l3A'
         
      ENDIF
      SET PROCEDURE TO REPORTS2
      STORE 0 TO MTOT_PURCH, MTOT_SELL, MPURCH_FRT, MCUS_FRT, MTOT_FRT, MFRT_FRT
      STORE 0 TO MMISC, MTOT_COMM, MTOT_NET, MPINV, MPFRT_INV, MCINV, MCFRT_INV
      STORE 0 TO MPTR, MPFRT_TR, MCTR, MCFRT_TR
      STORE 99999 TO MINV_NBR 
      
      DO CASE
      CASE MTOT_RPT = 'N'
         DO WHILE .NOT. EOF() .AND. POST_FLG = MPOSTIT .AND. INV_COR = MINV_COR .AND. TRAN_DATE <= MLAST
            IF RSUPCODE <> 'I' 
               MTOT_PURCH = MTOT_PURCH + TOT_PURCH
               MPURCH_FRT = MPURCH_FRT + SUP_PALL
            ELSE
               IF RSUPCODE = 'ID'
                  MPTR      = MPTR + TOT_PURCH
                  MPFRT_TR  = MPFRT_TR + SUP_PALL
               ELSE
                  MPINV     = MPINV + TOT_PURCH
                  MPFRT_INV = MPFRT_INV + SUP_PALL
               ENDIF
            ENDIF
            IF BBUYCODE <> 'I'  
               MTOT_SELL = MTOT_SELL + TOT_SELL
               MCUS_FRT = MCUS_FRT + CUS_PALL
            ELSE
               IF BBUYCODE = 'ID'
                  MCTR      = MCTR     + TOT_SELL
                  MCFRT_TR  = MCFRT_TR + CUS_PALL
               ELSE
                  MCINV     = MCINV     + TOT_SELL
                  MCFRT_INV = MCFRT_INV + CUS_PALL
               ENDIF
            ENDIF
            IF MPROG_CODE = 2
               MTOT_FRT = MTOT_FRT + FRT_AMT1 + FRT_AMT2 + FRT_AMT3
            ELSE
               MTOT_FRT = MTOT_FRT + FRT_AMT1
            ENDIF
            MFRT_FRT = MFRT_FRT + FRT_PALL
            MMISC = MMISC + MISC_AMT
            MTOT_COMM = MTOT_COMM + SALE_COMM
            MTOT_NET = MTOT_NET + TOT_NET
            IF COM_CODE <> SPACE(2) .AND. COMM_AMT <> 0
               MTOT_COMM = MTOT_COMM + COMM_AMT
            ENDIF
            IF COM_CODE2 <> SPACE(2) .AND. COMM_AMT2 <> 0
               MTOT_COMM = MTOT_COMM + COMM_AMT2
            ENDIF
            IF SAL_CODE2 <> SPACE(2)                      
               MTOT_COMM = MTOT_COMM + SALE2_AMT
               MTOT_NET = MTOT_NET + SALE2_NET
            ENDIF
            IF SAL_CODE3 <> SPACE(2)                      
               MTOT_COMM = MTOT_COMM + SALE3_AMT
               MTOT_NET = MTOT_NET + SALE3_NET
            ENDIF
            IF MLINE > MPAGE_LEN
               DO SPREADHD
            ENDIF
            STORE SPACE(8) TO MRSUPNAME, MBBUYNAME, MSAL_NAME, MCOM_NAME, MSAL_NAME2, MSAL_NAME3
            
            STORE SALESMAN TO MSALESMAN
            STORE PO_NBR TO MPO_NBR
            STORE PO_SUFFIX TO MPO_SUFFIX
            
            SELECT C
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF EOF()         
               STORE SPACE(4) TO MRSUPCODE, MBBUYCODE
               STORE SPACE(2) TO MSALESMAN, MCOM_CODE, MSAL_CODE2, MCOM_CODE2, MSAL_CODE3
            ELSE
               STORE RSUPCODE TO MRSUPCODE
               STORE BBUYCODE TO MBBUYCODE
               STORE SALESMAN TO MSALESMAN
               STORE COM_CODE TO MCOM_CODE
               STORE COM_CODE2 TO MCOM_CODE2
               STORE SAL_CODE2 TO MSAL_CODE2
               STORE SAL_CODE3 TO MSAL_CODE3
            ENDIF
            
            SELECT D
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF .NOT. EOF()
               STORE SUBSTR(PROD_DESC,1,5) TO MPROD
            ELSE
               STORE SPACE(5) TO MPROD
            ENDIF
            
            SELECT B
            IF MRSUPCODE = 'NONE' .OR. MRSUPCODE = SPACE(4)
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
            
            IF MBBUYCODE = 'NONE' .OR. MBBUYCODE = SPACE(4)
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
               SELECT A
               STORE BROK_NAME TO MSAL_NAME
            ENDIF
            
            SELECT A
            IF MSALESMAN <> SPACE(2)
               STORE MSALESMAN + '-' + INV_NBR TO MINV_NBR
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
            @ MLINE,23 SAY MPROD
            @ MLINE,31 SAY MBBUYNAME
            @ MLINE,44 SAY TOT_SELL PICTURE '9999999.99'
            @ MLINE,55 SAY CUS_PALL PICTURE '@Z 999999.99'
            @ MLINE,66 SAY MRSUPNAME
            @ MLINE,80 SAY TOT_PURCH PICTURE '9999999.99'
            @ MLINE,91 SAY SUP_PALL PICTURE '@Z 999999.99'
            IF MPROG_CODE = 2
               @ MLINE,101 SAY FRT_AMT1 + FRT_AMT2 + FRT_AMT3 PICTURE '9999999.99'
            ELSE
               @ MLINE,101 SAY FRT_AMT1 PICTURE '9999999.99'
            ENDIF
            
            @ MLINE,114 SAY FRT_PALL PICTURE '@Z 9999.99'
            @ MLINE,122 SAY MISC_AMT PICTURE '@Z 999999.99'
            @ MLINE,131 SAY SALE_COMM PICTURE '9999999.99'
            @ MLINE,143 SAY MSAL_NAME
            @ MLINE,152 SAY TOT_NET PICTURE '999,999.99'
            IF COMM_AMT <> 0
               SELECT B
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               
               SEEK MCOM_CODE
               IF .NOT. EOF()
                  STORE NAME TO MCOM_NAME
               ELSE  
                  STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME
               ENDIF
               SELECT A
               MLINE = MLINE + 2
               
               IF MLINE > MPAGE_LEN
                  DO SPREADHD
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,131 SAY COMM_AMT PICTURE '999,999.99'
               @ MLINE,143 SAY SUBSTR(MCOM_NAME,1,08)
            ENDIF
            IF COMM_AMT2 <> 0
               SELECT B
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               
               SEEK MCOM_CODE2
               IF .NOT. EOF()
                  STORE NAME TO MCOM_NAME2
               ELSE  
                  STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME2
               ENDIF
               SELECT A
               MLINE = MLINE + 2
               
               IF MLINE > MPAGE_LEN
                  DO SPREADHD
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,131 SAY COMM_AMT2 PICTURE '999,999.99'
               @ MLINE,143 SAY SUBSTR(MCOM_NAME2,1,08)
            ENDIF
            **RON MONTGOMERY CHANGES
            IF SALE2_AMT <> 0 .OR. SALE2_NET <> 0
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
                  DO SPREADHD
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,131 SAY SALE2_AMT PICTURE '99,999.99'
               @ MLINE,143 SAY SUBSTR(MSAL_NAME2,1,08)
               @ MLINE,153 SAY SALE2_NET PICTURE '99,999.99'
            ENDIF
            IF SALE3_AMT <> 0 .OR. SALE3_NET <> 0           
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
                  DO SPREADHD
               ENDIF
               @ MLINE,1 SAY MINV_NBR
               @ MLINE,131 SAY SALE3_AMT PICTURE '99,999.99'
               @ MLINE,143 SAY SUBSTR(MSAL_NAME3,1,08)
               @ MLINE,153 SAY SALE3_NET PICTURE '99,999.99'
            ENDIF
            MLINE = MLINE + 2
            SKIP
         ENDDO
         
      OTHERWISE
         STORE 0 TO DTOT_PURCH, DTOT_SELL, DPURCH_FRT, DCUS_FRT, DTOT_FRT, DFRT_FRT
         STORE 0 TO DMISC, DTOT_COMM, DTOT_NET  
         STORE 0 TO MPUR_INV, MCUS_INV, DPUR_INV, DCUS_INV 
         STORE 0 TO MPUR_FINV, MCUS_FINV, DPUR_FINV, DCUS_FINV
         STORE 0 TO MPUR_TR, MCUS_TR, DPUR_TR, DCUS_TR 
         STORE 0 TO MPUR_FTR, MCUS_FTR, DPUR_FTR, DCUS_FTR
         DO WHILE .NOT. EOF() .AND. POST_FLG = MPOSTIT .AND. INV_COR = MINV_COR .AND. TRAN_DATE <= MLAST
            MDATE = TRAN_DATE
            DO WHILE .NOT. EOF() .AND. POST_FLG = MPOSTIT .AND. INV_COR = MINV_COR .AND. TRAN_DATE <= MLAST .AND. TRAN_DATE = MDATE
               **IF RSUPCODE <> 'INVN' 
               IF RSUPCODE <> 'I' 
                  DTOT_PURCH = DTOT_PURCH + TOT_PURCH
                  DPURCH_FRT = DPURCH_FRT + SUP_PALL
               ELSE
                  IF RSUPCODE = 'ID'
                     DPUR_TR   = DPUR_TR + TOT_PURCH
                     DPUR_FTR  = DPUR_FTR + SUP_PALL
                  ELSE
                     DPUR_INV   = DPUR_INV + TOT_PURCH
                     DPUR_FINV  = DPUR_FINV + SUP_PALL
                  ENDIF
               ENDIF
               **IF BBUYCODE <> 'INVN'  
               IF BBUYCODE <> 'I'  
                  DTOT_SELL = DTOT_SELL + TOT_SELL
                  DCUS_FRT = DCUS_FRT + CUS_PALL
               ELSE
                  IF BBUYCODE = 'ID'
                     DCUS_TR  = DCUS_TR + TOT_SELL
                     DCUS_FTR = DCUS_FTR + CUS_PALL
                  ELSE
                     DCUS_INV  = DCUS_INV + TOT_SELL
                     DCUS_FINV = DCUS_FINV + CUS_PALL
                  ENDIF
               ENDIF
               IF MPROG_CODE = 2
                  DTOT_FRT = DTOT_FRT + FRT_AMT1 + FRT_AMT2 + FRT_AMT3
               ELSE
                  DTOT_FRT = DTOT_FRT + FRT_AMT1
               ENDIF
               DFRT_FRT = DFRT_FRT + FRT_PALL
               DMISC = DMISC + MISC_AMT
               DTOT_COMM = DTOT_COMM + SALE_COMM
               DTOT_NET = DTOT_NET + TOT_NET
               IF COM_CODE <> SPACE(2) .AND. COMM_AMT <> 0
                  DTOT_COMM = DTOT_COMM + COMM_AMT
               ENDIF
               IF COM_CODE2 <> SPACE(2) .AND. COMM_AMT2 <> 0
                  DTOT_COMM = DTOT_COMM + COMM_AMT2
               ENDIF
               IF SAL_CODE2 <> SPACE(2)                      
                  DTOT_COMM = DTOT_COMM + SALE2_AMT
                  DTOT_NET = DTOT_NET + SALE2_NET
               ENDIF
               IF SAL_CODE3 <> SPACE(2)                      
                  DTOT_COMM = DTOT_COMM + SALE3_AMT
                  DTOT_NET = DTOT_NET + SALE3_NET
               ENDIF
               SKIP
            ENDDO
            
            
            IF MLINE > MPAGE_LEN
               DO SPREADHD
            ENDIF
            
            @ MLINE,1 SAY DTOC(MDATE) + ' DAILY TOTALS:'
            @ MLINE,44 SAY DTOT_SELL PICTURE '9999999.99'
            @ MLINE,55 SAY DCUS_FRT PICTURE '@Z 999999.99'
            @ MLINE,80 SAY DTOT_PURCH PICTURE '9999999.99'
            @ MLINE,91 SAY DPURCH_FRT PICTURE '@Z 999999.99'
            @ MLINE,101 SAY DTOT_FRT  PICTURE '9999999.99'
            @ MLINE,114 SAY DFRT_FRT  PICTURE '@Z 9999.99'
            @ MLINE,122 SAY DMISC PICTURE '@Z 999999.99'
            @ MLINE,131 SAY DTOT_COMM PICTURE '9999999.99'
            MLINE = MLINE + 2
            IF DPUR_INV <> 0 .OR. DPUR_FINV <> 0 .OR. DCUS_INV <> 0 .OR. DCUS_FINV <> 0
               @ MLINE,1 SAY DTOC(MDATE) + ' DAILY INVENTORY TOTALS:'
               @ MLINE,44 SAY DCUS_INV PICTURE '9999999.99'
               @ MLINE,55 SAY DCUS_FINV PICTURE '@Z 999999.99'
               @ MLINE,80 SAY DPUR_INV PICTURE '9999999.99'
               @ MLINE,91 SAY DPUR_FINV PICTURE '@Z 999999.99'
               MLINE = MLINE + 2
            ENDIF
            IF DPUR_TR <> 0 .OR. DPUR_FTR <> 0 .OR. DCUS_TR <> 0 .OR. DCUS_FTR <> 0
               @ MLINE,1 SAY DTOC(MDATE) + ' DAILY TRANSFER TOTALS:'
               @ MLINE,44 SAY DCUS_TR PICTURE '9999999.99'
               @ MLINE,55 SAY DCUS_FTR PICTURE '@Z 999999.99'
               @ MLINE,80 SAY DPUR_TR PICTURE '9999999.99'
               @ MLINE,91 SAY DPUR_FTR PICTURE '@Z 999999.99'
               MLINE = MLINE + 2
            ENDIF
            
            MTOT_PURCH = DTOT_PURCH + MTOT_PURCH
            MPURCH_FRT = DPURCH_FRT + MPURCH_FRT
            MPUR_INV   = DPUR_INV + MPUR_INV 
            MPUR_FINV  = DPUR_FINV + MPUR_FINV
            MPUR_TR    = DPUR_TR  + MPUR_TR  
            MPUR_FTR   = DPUR_FTR  + MPUR_FTR 
            MTOT_SELL  = DTOT_SELL + MTOT_SELL
            MCUS_FRT   = DCUS_FRT + MCUS_FRT
            MCUS_INV   = DCUS_INV + MCUS_INV
            MCUS_FINV  = DCUS_FINV + MCUS_FINV
            MCUS_TR    = DCUS_TR  + MCUS_TR 
            MCUS_FTR   = DCUS_FTR  + MCUS_FTR 
            MTOT_FRT   = DTOT_FRT + MTOT_FRT
            MFRT_FRT   = DFRT_FRT + MFRT_FRT
            MMISC      = DMISC + MMISC
            MTOT_COMM  = DTOT_COMM + MTOT_COMM
            MTOT_NET   = DTOT_NET + MTOT_NET
            
            IF MLINE > MPAGE_LEN
               DO SPREADHD
            ENDIF
            @ MLINE,1 SAY DTOC(MDATE) + ' TOTALS FORWARD:'
            @ MLINE,43 SAY MTOT_SELL PICTURE '99999999.99'
            @ MLINE,55 SAY MCUS_FRT PICTURE '999999.99'
            @ MLINE,79 SAY MTOT_PURCH PICTURE '99999999.99'
            @ MLINE,91 SAY MPURCH_FRT PICTURE '999999.99'
            @ MLINE,101 SAY MTOT_FRT PICTURE '9999999.99'
            @ MLINE,113 SAY MFRT_FRT PICTURE '99999.99'
            @ MLINE,122 SAY MMISC PICTURE '999999.99'
            @ MLINE,131 SAY MTOT_COMM PICTURE '9999999.99'
            @ MLINE,152 SAY MTOT_NET PICTURE '9999999.99'
            
            MLINE = MLINE + 2
            IF MPUR_INV <> 0 .OR. MPUR_FINV <> 0 .OR. MCUS_INV <> 0 .OR. MCUS_FINV <> 0
               @ MLINE,1 SAY DTOC(MDATE) + ' INVENTORY TOTALS FORWARD:'
               @ MLINE,44 SAY MCUS_INV PICTURE '9999999.99'
               @ MLINE,55 SAY MCUS_FINV PICTURE '@Z 999999.99'
               @ MLINE,80 SAY MPUR_INV PICTURE '9999999.99'
               @ MLINE,91 SAY MPUR_FINV PICTURE '@Z 999999.99'
               MLINE = MLINE + 2
            ENDIF
            IF MPUR_TR  <> 0 .OR. MPUR_FTR  <> 0 .OR. MCUS_TR  <> 0 .OR. MCUS_FTR  <> 0
               @ MLINE,1 SAY DTOC(MDATE) + '  TRANSFER TOTALS FORWARD:'
               @ MLINE,44 SAY MCUS_TR  PICTURE '9999999.99'
               @ MLINE,55 SAY MCUS_FTR  PICTURE '@Z 999999.99'
               @ MLINE,80 SAY MPUR_TR  PICTURE '9999999.99'
               @ MLINE,91 SAY MPUR_FTR  PICTURE '@Z 999999.99'
               MLINE = MLINE + 2
            ENDIF
            @ MLINE,01 SAY REPLICATE('_',161)
            MLINE = MLINE + 2
            STORE 0 TO DTOT_PURCH, DTOT_SELL, DPURCH_FRT, DCUS_FRT, DTOT_FRT, DFRT_FRT
            STORE 0 TO DMISC, DTOT_COMM, DTOT_NET  
            STORE 0 TO DPUR_INV, DCUS_INV, DPUR_FINV, DCUS_FINV
            STORE 0 TO DPUR_TR, DCUS_TR, DPUR_FTR, DCUS_FTR
         ENDDO
      ENDCASE
      IF MPOSTIT = ' '
         IF MLINE +2 > MPAGE_LEN
            DO SPREADHD
         ENDIF
         @ MLINE,1 SAY 'SPREADSHEET TOTALS: '
         @ MLINE,43 SAY MTOT_SELL PICTURE '99999999.99'
         @ MLINE,55 SAY MCUS_FRT PICTURE '999999.99'
         @ MLINE,79 SAY MTOT_PURCH PICTURE '99999999.99'
         @ MLINE,91 SAY MPURCH_FRT PICTURE '999999.99'
         @ MLINE,101 SAY MTOT_FRT PICTURE '9999999.99'
         @ MLINE,113 SAY MFRT_FRT PICTURE '99999.99'
         @ MLINE,122 SAY MMISC PICTURE '999999.99'
         @ MLINE,131 SAY MTOT_COMM PICTURE '9999999.99'
         @ MLINE,152 SAY MTOT_NET PICTURE '9999999.99'
         IF MPINV <> 0 .OR. MPFRT_INV <> 0 .OR. MCINV <> 0 .OR. MCFRT_INV <> 0
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'INVENTORY TOTALS: '
            @ MLINE,43 SAY MCINV PICTURE '99999999.99'
            @ MLINE,55 SAY MCFRT_INV PICTURE '999999.99'
            @ MLINE,79 SAY MPINV PICTURE '99999999.99'
            @ MLINE,91 SAY MPFRT_INV PICTURE '999999.99'
         ENDIF
         IF MPTR <> 0 .OR. MPFRT_TR <> 0 .OR. MCTR <> 0 .OR. MCFRT_TR <> 0
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'TRANSFER TOTALS: '
            @ MLINE,43 SAY MCTR PICTURE '99999999.99'
            @ MLINE,55 SAY MCFRT_TR PICTURE '999999.99'
            @ MLINE,79 SAY MPTR PICTURE '99999999.99'
            @ MLINE,91 SAY MPFRT_TR PICTURE '999999.99'
         ENDIF
      ENDIF
      EJECT
      **** EPSON -ELITE, AND LETTER QUALITY MODE, SANS SERIF
      ****?? CHR(18)
      ****?? CHR(27) + 'M'
      ****?? CHR(27) + 'x' + CHR(1)
      ****?? CHR(27) + 'k' + CHR(2)
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      CLOSE DATA
      
      
   CASE MSEL_RPT2 = '7'
      **** NOTE: THIS HAS NOT BEEN CHANGED TO REFERENCE THE FRT_2ND FILE
      **** THAT FILE IS USE BY MFI CURRENTLY
      MTITLE = ' - LIST FREIGHT CARRIER BY SALESPERSON'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET FIRST AND LAST DATES FOR THIS REPORT
      STORE CTOD(' ') TO MSTART, MLAST
      STORE 'P' TO MDISP_PRT
      STORE '**' TO MOPT_SALES
      @ 09,2 say '        BEGINNING DATE: '
      @ 11,2 SAY '           ENDING DATE: '
      @ 14,2 SAY '(OPTIONAL) SALESPERSON: '
      
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 09,27 GET MSTART
         @ 11,27 GET MLAST
         @ 14,27 GET MOPT_SALES PICTURE '@!'
         STORE 1 TO MACTION
         @ 24,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report/Finished'                     
         
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
         MPAGE_LEN = 22
      ENDIF
      SELECT C
      USE TEMP_AGE EXCLUSIVE
      DELETE ALL
      PACK
      INDEX ON NAME + CITY TO TEMP_AGE
      CLOSE DATA
      SELECT A 
      DO FOX_USE WITH "PO_HEAD INDEX  PO_SHIP", .F.
      SELECT C 
      DO FOX_USE WITH "TEMP_AGE INDEX  TEMP_AGE", .F.
      SELECT D
      DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
      
      STORE MONTH(MSTART) TO MSTRT_MO   
      MSTRT_MO = MSTRT_MO + 100
      STORE SUBSTR(STR(MSTRT_MO,3),2) TO MSTRT_MO
      
      STORE MONTH(MLAST) TO MLAST_MO   
      MLAST_MO = MLAST_MO + 100
      STORE SUBSTR(STR(MLAST_MO,3),2) TO MLAST_MO
      
      STORE YEAR(MSTART) TO MSTRT_YR
      STORE STR(MSTRT_YR,4) TO MSTRT_YR
      
      STORE YEAR(MLAST) TO MLAST_YR
      STORE STR(MLAST_YR,4) TO MLAST_YR
      
      STORE DAY(MSTART) TO MSTRT_DAY
      MSTRT_DAY = MSTRT_DAY + 100
      STORE SUBSTR(STR(MSTRT_DAY,3),2) TO MSTRT_DAY
      
      STORE DAY(MLAST) TO MLAST_DAY
      MLAST_DAY = MLAST_DAY + 100
      STORE SUBSTR(STR(MLAST_DAY,3),2) TO MLAST_DAY
      SELECT A
      SEEK MSTRT_YR + MSTRT_MO + MSTRT_DAY
      IF EOF()
         SEEK MSTRT_YR + MSTRT_MO 
         IF EOF()
            SEEK MSTRT_YR
            IF EOF()
               GOTO TOP
            ENDIF
         ENDIF
      ENDIF
      DO WHILE .NOT. EOF() .AND. SHIP_DATE < MSTART
         SKIP
      ENDDO
      MPAGE_NO = 0
      MLINE = 99 
      @ 20,16 SAY 'PROCESSING........'
      IF MDISP_PRT = 'P'
         SET CONSOLE OFF
         IF FILE("C:\COMPINFO\PRINTERS.DBF")
            SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
         ELSE
            SET PRINT TO lpt3
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
      DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MLAST
         IF MOPT_SALES <> '**'
            IF SALESMAN <> MOPT_SALES
               SKIP
               LOOP
            ENDIF
         ENDIF
         IF FRT_CODE1 = 'NONE' .OR. FRT_CODE1 = 'DELV' .OR. FRT_CODE1 = SPACE(4)
            SKIP 
            LOOP
         ENDIF
         SELECT D
         DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
         SEEK A->FRT_CODE1
         IF .NOT. EOF()
            STORE NAME TO MNAME
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            STORE STREET TO MADDR
            STORE ZIP    TO MZIP
         ELSE
            STORE 'NOT ON FILE' TO MNAME
            STORE SPACE(2) TO MCITY, MSTATE, MADDR, MZIP
         ENDIF
         SELECT C 
         SEEK MNAME 
         IF EOF()
            DO FILELOCK
            APPEND BLANK
            REPLACE NAME WITH MNAME
            REPLACE ADDR WITH MADDR
            REPLACE CITY WITH MCITY
            REPLACE STATE WITH MSTATE
            REPLACE ZIP   WITH MZIP
         ENDIF
         DO RECLOCK
         REPLACE TOT_LBS WITH TOT_LBS + 1  
         REPLACE TOT_SW WITH TOT_SW + (A->FRT_AMT1 + A->FRT1_ADJ1 + A->FRT1_ADJ2)
         UNLOCK
         SELECT A
         SKIP
      ENDDO
      CLOSE DATA
      SELECT C 
      DO FOX_USE WITH "TEMP_AGE INDEX  TEMP_AGE", .F.
      DO WHILE .NOT. EOF()
         
         IF MLINE > MPAGE_LEN
            IF MDISP_PRT <> 'P'
               IF MLINE = 99 
                  CLEAR
               ELSE
                  STORE ' ' TO MWAIT
                  @ 24,0 SAY 'Press Return to Continue Report ' GET MWAIT
                  READ
                  CLEAR    
               ENDIF
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,27 SAY MCOMPANY
            @ 1,70 SAY DTOC(DATE())
            IF MOPT_SALES <> '**'
               @ 2,27 SAY 'OPTIONAL SALESPERSON: ' + MOPT_SALES
               MLINE = 3
            ELSE
               MLINE = 2
            ENDIF
            @ MLINE,1 SAY 'Page'
            @ MLINE,06 say mpage_no picture '99'
            @ MLINE,11 SAY 'ACTIVE FREIGHT CARRIERS BETWEEN ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
            IF MDISP_PRT = 'P'
               @ MLINE,01 SAY REPLICATE('_',77)
            ENDIF
            MLINE = MLINE + 2
            @ MLINE,01 SAY 'FREIGHT CARRIER' 
            @ mline,40 say 'NBR OF SHIPS      TOTAL FREIGHT AMT'
            
            MLINE = MLINE + 2
         ENDIF
         @ MLINE,01 SAY NAME    
         @ MLINE,44 SAY TOT_LBS PICTURE '99,999'
         @ MLINE,63 SAY TOT_SW PICTURE '99,999,999'
         MLINE = MLINE + 1
         @ MLINE,5 SAY ADDR
         MLINE = MLINE + 1
         @ MLINE,5 SAY TRIM(CITY) + ', ' + STATE + '  ' + ZIP
         MLINE = MLINE + 2
         SKIP
      ENDDO
      
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
      
   CASE MSEL_RPT2 = '8'
      MTITLE = ' - SPREADSHEET TOTALS BY OFFICE/SALESPERSON'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      
      **** GET DATE FOR THIS REPORT
      STORE SPACE(2) TO MBEG_MO, MEND_MO
      STORE SPACE(4) TO MBEG_YR, MEND_YR
      STORE 'P' TO MDISP_PRT
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 08,5 SAY 'BEGIN REPORT MONTH/YEAR:'
         @ 08,33 SAY '/'
         @ 08,30 GET MBEG_MO PICTURE '##'
         @ 08,35 GET MBEG_YR PICTURE '####'
         
         @ 10,5 SAY '  END REPORT MONTH/YEAR: ' 
         @ 10,33 SAY '/'  
         @ 10,30 GET MEND_MO PICTURE '##'
         @ 10,35 GET MEND_YR PICTURE '####'
         
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF MBEG_MO = '  ' .OR. MBEG_YR = '  ' .OR. MEND_MO = '  ' .OR. MEND_YR = '  '
               @ 24,0 CLEAR
               MWAIT = ' '
               @ 24,1 SAY 'BEGIN OR END DATE NOT FULLY ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
               READ
               MACTION = 2
               @ 24,0 CLEAR
               LOOP 
            ENDIF
         ENDIF
      ENDDO
      ********************      
      IF MACTION = 3
         RETURN
      ENDIF  
      MBEG_DT = CTOD(MBEG_MO+'/01/'+MBEG_YR)
      MEND_DT = CTOD(MEND_MO+'/01/'+MEND_YR)
      
      MBEG_CMO = CMONTH(MBEG_DT)
      MEND_CMO = CMONTH(MEND_DT)
      
      MEND = VAL(MEND_YR + MEND_MO)
      
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
      
      MPAGE_LEN = 56
      
      SELECT C
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT B
      USE TMP_ACCT EXCLUSIVE
      DELETE ALL
      PACK
      INDEX ON OFFICE_CD + TYPE  + CATEGORY TO TMP_ACCT
      USE
      USE TMP_ACCT INDEX TMP_ACCT EXCLUSIVE
      *DO FOX_USE WITH "TMP_ACCT INDEX TMP_ACCT", .F.
      SELECT A
      DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
      STORE 0 TO MTOT_PURCH, MTOT_SELL, MTOT_FRT, MTOT_COMM, MTOT_MISC
      SEEK MBEG_YR + MBEG_MO        
      
      DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR+TRAN_MO) <= MEND
         *** WARNING !!!
         *** IF MFI EVER STARTS TO HAVE THEIR SALESPEOPLE MAKE MONEY, FIGURE
         *** OUT WHAT TO DO HERE !!!
         
         MINVEN = 0
         IF RSUPCODE = 'INVN'
            MINVEN = MINVEN + (TOT_PURCH + SUP_PALL)
            MTOT_PURCH = 0
         ELSE
            MTOT_PURCH = TOT_PURCH + SUP_PALL
         ENDIF
         
         IF BBUYCODE = 'INVN'
            MINVEN = MINVEN - (TOT_SELL + CUS_PALL)         
            MTOT_SELL = 0
         ELSE
            MTOT_SELL = TOT_SELL + CUS_PALL
         ENDIF
         
         IF MPROG_CODE = 2
            MTOT_FRT =  FRT_AMT1 + FRT_PALL + FRT_AMT2 + FRT_AMT3
         ELSE
            MTOT_FRT =  FRT_AMT1 + FRT_PALL
         ENDIF
         MTOT_COMM = SALE_COMM + COMM_AMT + COMM_AMT2 + SALE2_AMT + SALE3_AMT
         MTOT_MISC = MISC_AMT
         SELECT C
         SEEK A->SALESMAN
         IF EOF()
            MOFFICE_CD = '  '
         ELSE
            MOFFICE_CD = OFFICE_CD
         ENDIF
         **RON MONTGOMERY CHANGES
         MDOIT = .F.
         IF A->SAL_CODE2 <> '  ' .OR. MDOIT
            SEEK A->SAL_CODE2
            IF EOF()
               MINTRA_OFF = '  '
            ELSE
               MINTRA_OFF = OFFICE_CD
            ENDIF
         ELSE
            MINTRA_OFF = '  '
         ENDIF
         SELECT B
         IF MTOT_SELL <> 0
            ** C= SALES, C= SPREADSHEET CUSTOMER SALES
            SEEK MOFFICE_CD + 'C' + 'C'
            IF EOF()
               APPEND BLANK
               REPLACE OFFICE_CD WITH MOFFICE_CD
               REPLACE TYPE WITH 'C'
               REPLACE CATEGORY WITH 'C'
            ENDIF
            REPLACE AMOUNT WITH AMOUNT + MTOT_SELL
         ENDIF
         
         IF MTOT_PURCH <> 0
            ** D= PRODUCT COST, A= PAYABLES-SUPPLIER
            SEEK MOFFICE_CD + 'D' + 'A'
            IF EOF()
               APPEND BLANK
               REPLACE OFFICE_CD WITH MOFFICE_CD
               REPLACE TYPE WITH 'D'
               REPLACE CATEGORY WITH 'A'
            ENDIF
            REPLACE AMOUNT WITH AMOUNT + MTOT_PURCH
         ENDIF
         
         ** D= DISBURSEMENTS, B= ACCRUED FREIGHT
         SEEK MOFFICE_CD + 'D' + 'B'
         IF EOF()
            APPEND BLANK
            REPLACE OFFICE_CD WITH MOFFICE_CD
            REPLACE TYPE WITH 'D'
            REPLACE CATEGORY WITH 'B'
         ENDIF
         REPLACE AMOUNT WITH AMOUNT + MTOT_FRT  
         
         ** D= DISBURSEMENTS, D= ACCRUED COMMISSIONS
         SEEK MOFFICE_CD + 'D' + 'D'
         IF EOF()
            APPEND BLANK
            REPLACE OFFICE_CD WITH MOFFICE_CD
            REPLACE TYPE WITH 'D'
            REPLACE CATEGORY WITH 'D'
         ENDIF
         REPLACE AMOUNT WITH AMOUNT + MTOT_COMM 
         
         ** D= DISBURSEMENTS, E= MISCELLANEOUS EXPENSES
         SEEK MOFFICE_CD + 'D' + 'E'
         IF EOF()
            APPEND BLANK
            REPLACE OFFICE_CD WITH MOFFICE_CD
            REPLACE TYPE WITH 'D'
            REPLACE CATEGORY WITH 'E'
         ENDIF
         REPLACE AMOUNT WITH AMOUNT + MTOT_MISC 
         
         *** NOTE: 
         *** IF CUSTOMER = INVENTORY -TREAT NORMALLY
         *** IF SUPPLIER = INVENTORY AND NO INTRA COMP SALE - TREAT NORMALLY
         *** IF SUPPLIER = INVENTORY .AND. INTRACOMPANY SALESPERSON <> '  '
         ***  **FOR THE ORIGINAL BUYING OFFICE *** INTRA OFFICE *** 
         ***    REDUCE INVEN,  DECREASE PAYABLE    
         ***  **FOR THE SELLING OFFICE 
         ***    INCREASE PAYABLE, INCREASE RECEIVABLE
         *** ENDIF
         
         IF MINVEN <> 0
            DO CASE
               **** MINVEN < 0 MEANS BBUYCODE = INVN - PUT INTO INVENTORY
            CASE MINVEN < 0  
               SEEK MOFFICE_CD + 'D' + 'I'
               IF EOF()
                  APPEND BLANK
                  REPLACE OFFICE_CD WITH MOFFICE_CD 
                  REPLACE TYPE WITH 'D'
                  REPLACE CATEGORY WITH 'I'
               ENDIF
               REPLACE AMOUNT WITH AMOUNT + MINVEN    
            OTHERWISE
               **RON MONTGOMERY CHANGES
               MDOIT = .F.
               IF A->SAL_CODE2 <> '  ' .OR. MDOIT
                  *** REDUCE INVENTORY BECAUSE SELLING OUT
                  SEEK MINTRA_OFF + 'D' + 'I'
                  IF EOF()
                     APPEND BLANK
                     REPLACE OFFICE_CD WITH MINTRA_OFF 
                     REPLACE TYPE WITH 'D'
                     REPLACE CATEGORY WITH 'I'
                  ENDIF
                  REPLACE AMOUNT WITH AMOUNT + MINVEN    
                  *** INTRACOMPANY SALE (DECREASE PRODUCT COST)    
                  ** D= PRODUCT COST, F= INTRACOMPANY SALE
                  SEEK MINTRA_OFF + 'D' + 'F'
                  IF EOF()
                     APPEND BLANK
                     REPLACE OFFICE_CD WITH MINTRA_OFF
                     REPLACE TYPE WITH 'D'
                     REPLACE CATEGORY WITH 'F'
                  ENDIF
                  REPLACE AMOUNT WITH AMOUNT - MINVEN     
                  *** INTRACOMPANY PURCHASE - (INCREASE PRODUCT COST)       
                  ** D= PRODUCT COST, G= INTRACOMPANY PURCHASE
                  SEEK MOFFICE_CD + 'D' + 'G'
                  IF EOF()
                     APPEND BLANK
                     REPLACE OFFICE_CD WITH MOFFICE_CD 
                     REPLACE TYPE WITH 'D'
                     REPLACE CATEGORY WITH 'G'
                  ENDIF
                  REPLACE AMOUNT WITH AMOUNT + MINVEN    
               ELSE
                  *** REDUCE INVENTORY FOR MAIN OFFICE (BUYING AND SELLING)
                  SEEK MOFFICE_CD + 'D' + 'I'
                  IF EOF()
                     APPEND BLANK
                     REPLACE OFFICE_CD WITH MOFFICE_CD 
                     REPLACE TYPE WITH 'D'
                     REPLACE CATEGORY WITH 'I'
                  ENDIF
                  REPLACE AMOUNT WITH AMOUNT + MINVEN    
               ENDIF
            ENDCASE
         ENDIF
         SELECT A
         SKIP
      ENDDO
      CLOSE DATA
      MGRAND_DIS = 0
      MGRAND_REC = 0
      MGRAND_INV = 0
      SELECT A
      DO FOX_USE WITH "TMP_ACCT INDEX TMP_ACCT", .F.
      MPAGE_NO = 0
      MLINE = 99 
      
      IF MDISP_PRT = 'P'
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
         ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
         
         *** LETTER SIZE PAPER
         ?? CHR(27) + '&l2A'
         
         *** PORTRAIT MODE
         ?? CHR(27) + '&l0O'
         
      ENDIF
      GOTO TOP
      DO WHILE .NOT. EOF() 
         STORE OFFICE_CD TO MOFFICE_CD
         DO CASE
         CASE MOFFICE_CD = '01'
            MOFFICE_DS = 'MISSOURI OFFICE'
         CASE MOFFICE_CD = '02'
            MOFFICE_DS = 'SOUTH CAROLINA OFFICE'
         OTHERWISE
            MOFFICE_DS = 'UNKNOWN OFFICE'
         ENDCASE
         MSAL_DIS = 0
         MSAL_REC = 0
         MSAL_INV = 0
         MPRT_NAME = .T.
         DO WHILE .NOT. EOF() .AND. OFFICE_CD = MOFFICE_CD
            STORE TYPE TO MTYPE
            MPRT_TYPE = .T.
            DO WHILE .NOT. EOF() .AND. OFFICE_CD = MOFFICE_CD .AND. TYPE = MTYPE
               IF AMOUNT = 0
                  SKIP
                  LOOP
               ENDIF
               DO CASE
               CASE CATEGORY = 'C'
                  MCAT_DESC = 'RECEIVABLES'
               CASE CATEGORY = 'I'
                  IF AMOUNT < 0
                     MCAT_DESC = 'INVENTORY INCREASE'
                  ELSE
                     MCAT_DESC = 'INVENTORY DECREASE'
                  ENDIF
               CASE CATEGORY = 'A'
                  MCAT_DESC = 'PAYABLES - SUPPLIER'
               CASE CATEGORY = 'B'
                  MCAT_DESC = 'PAYABLES - FREIGHT'
               CASE CATEGORY = 'D'
                  MCAT_DESC = 'PAYABLES - COMMISSIONS'
               CASE CATEGORY = 'E'
                  MCAT_DESC = 'MISCELLANEOUS'
               CASE CATEGORY = 'F'
                  MCAT_DESC = 'INTRACOMPANY TRANSFER (SALE)'
               CASE CATEGORY = 'G'
                  MCAT_DESC = 'INTRACOMPANY TRANSFER (PURCHASE)'
               OTHERWISE
                  MCAT_DESC = 'UNKNOWN CATEGORY-' + CATEGORY
               ENDCASE
               
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
                  @ 2,9 SAY '     SPREADSHEET TOTALS BY OFFICE/CATEGORY'
                  IF MBEG_MO+MBEG_YR <> MEND_MO+MEND_YR
                     @ 3,19 SAY TRIM(MBEG_CMO) + "'" + MBEG_YR + ' THRU ' + TRIM(MEND_CMO) + "'" + MEND_YR
                  ELSE
                     @ 3,27 SAY TRIM(MBEG_CMO) + "'" + MBEG_YR
                  ENDIF
                  @ 5,1 SAY 'OFFICE / DESCRIPTION                          TOTALS'
                  @ 5,79 SAY ' GRAND TOTALS'     
                  @ 5,0 SAY REPLICATE ('_',92)
                  MLINE = 7
                  MPRT_NAME = .T.
                  MPRT_TYPE = .T.
               ENDIF
               IF MPRT_NAME
                  @ MLINE,1 SAY MOFFICE_DS
                  MLEN= LEN(TRIM(MOFFICE_DS))
                  @ MLINE,1 SAY REPLICATE('_',MLEN)
                  MLINE = MLINE + 1
                  MPRT_NAME = .F.
               ENDIF
               IF MPRT_TYPE 
                  IF MTYPE = 'D'
                     @ MLINE,3 SAY 'PRODUCT COST'
                  ELSE
                     @ MLINE,3 SAY 'PRODUCT SALES'
                  ENDIF
                  MLINE = MLINE + 1
                  MPRT_TYPE = .F.
               ENDIF
               
               @ MLINE,6 SAY MCAT_DESC
               @ MLINE,40 SAY AMOUNT PICTURE '99,999,999.99'
               MLINE = MLINE + 1
               IF MTYPE = 'D'
                  IF CATEGORY = 'I'
                     MSAL_INV = MSAL_INV + AMOUNT
                  ELSE
                     MSAL_DIS = MSAL_DIS + AMOUNT
                  ENDIF
               ELSE
                  MSAL_REC = MSAL_REC + AMOUNT
               ENDIF
               SKIP
            ENDDO
         ENDDO
         @ MLINE,60 SAY 'PRODUCT SALES'
         @ MLINE,79 SAY MSAL_REC PICTURE '99,999,999.99'
         MGRAND_REC = MGRAND_REC + MSAL_REC
         MLINE = MLINE + 1
         @ MLINE,60 SAY 'PRODUCT COST'
         @ MLINE,79 SAY MSAL_DIS + MSAL_INV PICTURE '99,999,999.99'
         MGRAND_DIS = MGRAND_DIS + MSAL_DIS              
         MGRAND_INV = MGRAND_INV + MSAL_INV
         MLINE = MLINE + 1
         @ MLINE,60 SAY REPLICATE('=',17)
         @ MLINE,79 SAY REPLICATE('=',13)
         MLINE = MLINE + 1
         @ MLINE,60 SAY 'DIFFERENCE '
         @ MLINE,79 SAY MSAL_REC - MSAL_INV - MSAL_DIS PICTURE '99,999,999.99'
         MLINE = MLINE + 3
      ENDDO
      IF MLINE +8 > MPAGE_LEN
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
         @ 2,9 SAY '     SPREADSHEET TOTALS BY OFFICE/CATEGORY'
         IF MBEG_MO+MBEG_YR <> MEND_MO+MEND_YR
            @ 3,19 SAY TRIM(MBEG_CMO) + "'" + MBEG_YR + ' THRU ' + TRIM(MEND_CMO) + "'" + MEND_YR
         ELSE
            @ 3,27 SAY TRIM(MBEG_CMO) + "'" + MBEG_YR
         ENDIF
         @ 5,1 SAY 'OFFICE / DESCRIPTION                          TOTALS'
         @ 5,79 SAY ' GRAND TOTALS'
         @ 5,0 SAY REPLICATE ('_',92)
         MLINE = 7
      ENDIF
      MLINE = MLINE + 2
      @ MLINE,60 SAY REPLICATE('=',32)
      MLINE = MLINE + 1
      @ MLINE,66 SAY 'COMPANY GRAND TOTALS '
      MLINE = MLINE + 1
      @ MLINE,60 SAY 'PRODUCT SALES'
      @ MLINE,79 SAY MGRAND_REC PICTURE'99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,60 SAY 'PRODUCT COST'
      @ MLINE,79 SAY MGRAND_DIS + MGRAND_INV PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,60 SAY REPLICATE('=',32)
      MLINE = MLINE + 1
      @ MLINE,60 SAY 'DIFFERENCE'
      @ MLINE,79 SAY MGRAND_REC - MGRAND_INV - MGRAND_DIS PICTURE '99,999,999.99'
      @ MLINE+1,1 SAY ' '
      
      *** NOW SHOW LEDGER BALANCES
      CLOSE DATA
      SELECT A
      DO FOX_USE WITH "CUSLED INDEX CUSLED", .F.
      SEEK MEND_YR + MEND_MO
      DO CASE
      CASE .NOT. EOF()
         MLED_RECV = 0
         MLED_PAY  = 0
         MLED_INV  = 0
         DO WHILE TRAN_YR = MEND_YR .AND. TRAN_MO = MEND_MO .AND. .NOT. EOF()
            MLED_RECV = MLED_RECV + AMOUNT
            SKIP
         ENDDO
         DO FOX_USE WITH "SUPLED INDEX SUPLED", .F.
         SEEK MEND_YR+MEND_MO
         DO WHILE TRAN_YR = MEND_YR .AND. TRAN_MO = MEND_MO .AND. .NOT. EOF()
            MLED_PAY = MLED_PAY + AMOUNT
            SKIP
         ENDDO
         DO FOX_USE WITH "FRTLED INDEX FRTLED", .F.
         SEEK MEND_YR+MEND_MO
         DO WHILE TRAN_YR = MEND_YR .AND. TRAN_MO = MEND_MO .AND. .NOT. EOF()
            MLED_PAY = MLED_PAY + AMOUNT
            SKIP
         ENDDO
         DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED", .F.
         SEEK MEND_YR+MEND_MO
         DO WHILE TRAN_YR = MEND_YR .AND. TRAN_MO = MEND_MO .AND. .NOT. EOF()
            MLED_PAY = MLED_PAY + AMOUNT
            SKIP
         ENDDO
         *** FIND INVENTORY BALANCE
         DO FOX_USE WITH "INVLED INDEX INVLED", .F.
         SEEK MEND_YR+MEND_MO
         DO WHILE TRAN_YR = MEND_YR .AND. TRAN_MO = MEND_MO .AND. .NOT. EOF()
            MLED_INV = MLED_INV + AMOUNT
            SKIP
         ENDDO
         
         IF MLINE +8 > MPAGE_LEN
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
            @ 2,9 SAY '     SPREADSHEET TOTALS BY OFFICE/CATEGORY'
            IF MBEG_MO+MBEG_YR <> MEND_MO+MEND_YR
               @ 3,19 SAY TRIM(MBEG_CMO) + "'" + MBEG_YR + ' THRU ' + TRIM(MEND_CMO) + "'" + MEND_YR
            ELSE
               @ 3,27 SAY TRIM(MBEG_CMO) + "'" + MBEG_YR
            ENDIF
            @ 5,1 SAY 'OFFICE / DESCRIPTION                          TOTALS'
            @ 5,79 SAY ' GRAND TOTALS'
            @ 5,0 SAY REPLICATE ('_',92)
            MLINE = 7
         ENDIF
         MLINE = MLINE + 4
         STORE LEN('Ledger Balances as of Month Ending ' + TRIM(MEND_CMO) + "'" + MEND_YR) TO MLEN
         @ MLINE,1 SAY 'Ledger Balances as of Month Ending ' + TRIM(MEND_CMO) + "'" + MEND_YR
         @ MLINE,1 SAY REPLICATE('_',MLEN)
         MLINE = MLINE + 2
         @ MLINE,1 SAY  'RECEIVABLES'
         @ MLINE,20 SAY MLED_RECV PICTURE '99,999,999.99'
         MLINE = MLINE + 2
         @ MLINE,1 SAY  'PAYABLES'
         @ MLINE,20 SAY MLED_PAY  PICTURE '99,999,999.99'
         MLINE = MLINE + 2
         @ MLINE,1 SAY  'INVENTORY'
         @ MLINE,20 SAY MLED_INV  PICTURE '99,999,999.99'
      ENDCASE
      EJECT
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      CLOSE DATA
   ENDCASE
   
ENDDO
CLOSE DATA

RETURN

PROCEDURE SSERR_HD
IF MLINE > MPAGE_LEN
   IF MLINE <> 99
      EJECT
   ENDIF
   MPAGE_NO = MPAGE_NO + 1
   @ 1,24 SAY MCOMPANY
   @ 2,0 SAY 'PAGE'
   @ 2,05 say mpage_no picture '99'
   @ 2,20 SAY 'SS/BROKER SPREADSHEET COMPARISONS'     
   @ 2,68 SAY DTOC(DATE())
   @ 4,1 SAY 'INV NBR     PO NBR         MESSAGE/CATEGORY'
   @ 4,1 SAY REPLICATE ('_',75)
   MLINE = 6
ENDIF
RETURN

PROCEDURE SPREADHD
IF MLINE > MPAGE_LEN
   IF MLINE <> 99
      EJECT
   ENDIF
   MPAGE_NO = MPAGE_NO + 1
   @ 2,60 SAY MCOMPANY
   @ 3,1 SAY 'Page'
   @ 3,06 say mpage_no picture '99'
   IF MINV_COR = 'C'
      @ 3,46 SAY 'CORRECTION SPREADSHEET SUMMARY FOR ' + DTOC(MSTART) + ' THRU ' + DTOC(MLAST)
   ELSE
      @ 3,46 SAY '  INVOICE  SPREADSHEET SUMMARY FOR ' + DTOC(MSTART) + ' THRU ' + DTOC(MLAST)
   ENDIF
   
   @ 3,128 SAY DTOC(DATE())
   IF MPOSTIT = ' '
      @ 4,61 SAY '(UNPOSTED ENTRIES)'
   ELSE
      @ 4,61 SAY '(POSTED  ENTRIES)'
   ENDIF
   IF MTOT_RPT = 'Y' 
      @ 5,1 SAY 'POST DATE'
      @ 5,44 SAY '  TOT SELL'
      @ 5,56 SAY 'CUST FRT'
   ELSE
      @ 5,1 SAY 'INV NBR'
      @ 5,12 SAY 'P.O. NBR'
      @ 5,23 SAY 'DESCR'
      @ 5,31 SAY 'CUSTOMER'
      @ 5,44 SAY '  TOT SELL'
      @ 5,56 SAY 'CUST FRT'
      @ 5,66 SAY 'SUPPLIER'
   ENDIF
   @ 5,80 SAY ' TOT PURCH'
   @ 5,92 SAY ' SUP FRT'
   @ 5,102 SAY '  FREIGHT'
   @ 5,113 SAY 'FRT PALL'    
   @ 5,123 SAY '   MISC' 
   @ 5,133 SAY '    COMM'
   @ 5,143 SAY 'BROKR'
   @ 5,155 SAY 'TOT NET'
   @ 5,01 SAY REPLICATE('_',161)
   MLINE = 7
ENDIF
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
   @ 3,26 SAY 'ACCOUNTS OVER CREDIT LIMIT AS OF ' + DTOC(MDATE)
   @ 3,88 SAY DTOC(DATE())
   @ 4,26 SAY 'SALESPERSON: ' + MSAL_NAME
   IF MPRT_CUST
      @ 6,1 SAY 'CUSTOMER'
      @ 6,15 SAY 'INV AMT'
      @ 6,28 SAY 'AMT DUE'
      @ 6,40 SAY 'CUST PO #'
      @ 6,59 SAY 'PO #'
      @ 6,70 SAY 'INV DATE'
      @ 6,80 SAY 'DAYS OLD'
      @ 6,1 SAY REPLICATE('_',90)
      MLINE = 8
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

* EOF: REPORTS2.PRG


*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 3:42 PM.
