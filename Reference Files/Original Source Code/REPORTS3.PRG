**********
* Program.: REPORTS3.PRG
* Author..: GRACE KELLER
* Date....: 10/04/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: POULTRY REPORTS MENU III
* 
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

CLOSE DATA

STORE 0 TO MACTION
STORE '  ' TO MSEL_RPT3
DO WHILE MSEL_RPT3 <> '99'
   STORE '  ' TO MSEL_RPT3
   CLOSE DATA
   CLEAR
   @ 1,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 02,00 SAY MPROGRAM + ' - REPORTS MENU III'
   @ 03,00 TO 25,79 
   
   @ 04,09 SAY ' 1 - PRINT SALESPERSON ORDER ACTIVITY'          
   @ 06,09 SAY ' 2 - PRINT CUSTOMER CONTACT REPORT - OVERDUE INVOICES'
   @ 08,09 say ' 3 - PRINT THIRD PARTY LIST OF OUTSTANDING ORDERS/CREDIT LIMITS'
   @ 10,09 SAY ' 4 - PRINT AVERAGE AGING DAYS FOR ALL CUSTOMERS BETWEEN TWO SHIP DATES'
   @ 12,09 SAY ' 5 - SALESPERSON PAYMENT WORKSHEET'
   @ 14,09 SAY ' 6 - PRINT CASH FLOW REPORT (CHECKS/RECEIPTS/RECV/INVEN)'
   @ 16,09 SAY ' 7 - PRINT FREIGHT CARRIER ORIGINATION REPORT'
   @ 18,09 say ' 8 - PRINT A/P, A/R, INV REPORT (CASH ANALYSIS)'
   @ 20,09 SAY ' 9 - PRINT REPORT OF FREIGHT ADJUSTMENTS/DEDUCTS'
   @ 22,09 SAY '99 - EXIT TO MAIN MENU'
   
   STORE '1 ' TO MSEL_RPT3
   @ 23,01 SAY 'CHOICE: '
   @ 23,09 GET MSEL_RPT3 PICTURE '@!'
   READ
   
   DO CASE
   CASE VAL(MSEL_RPT3) = 9
      DO FRT_RPT
      CLOSE DATA

   CASE VAL(MSEL_RPT3) = 1
      MTITLE = " - SALESPERSON DETAIL/SUMMARY OF ORDER ACTIVITY"            
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE SPACE(2) TO MBEG_MO, MEND_MO
      STORE SPACE(4) TO MBEG_YR, MEND_YR
      STORE 'P' TO MDISP_PRT
      STORE '**' to msel_sales
      STORE CTOD('') TO MSEL_SHIP
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 08,4 SAY 'ENTER MONTH/YEAR BEGINNING REPORT DATE: '
         @ 08,47 SAY '/'
         @ 10,4 SAY '   ENTER MONTH/YEAR ENDING REPORT DATE: '
         @ 10,47 SAY '/'
         @ 12,4 SAY '          ENTER/SELECT ONE SALESPERSON: '
         *@ 14,2 SAY 'SELECT ORDERS SHIPPED ON/AFTER THIS DATE: '
         @ 08,45 GET MBEG_MO
         @ 08,48 GET MBEG_YR
         @ 10,45 GET MEND_MO
         @ 10,48 GET MEND_YR
         @ 12,45 GET MSEL_SALES               
         *@ 14,45 GET MSEL_SHIP
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF VAL(MEND_YR+MEND_MO) < VAL(MBEG_YR+MBEG_MO)
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'ENDING DATE BEFORE BEGIN DATE - PRESS ANY KEY TO REENTER' GET MWAIT
               READ
               MACTION = 2
               @ 24,0 CLEAR
               LOOP 
            ENDIF
            IF MSEL_SALES = '**' 
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'MUST SELECT SALESPERSON - PRESS ANY KEY TO REENTER' GET MWAIT
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
      *** IF ANY ARE SPACES, GET OUT OF THIS REPORT 
      IF MBEG_MO = SPACE(2) .OR. MBEG_YR = SPACE(4) .OR. MEND_MO = SPACE(2) .OR. MEND_YR = SPACE(4)
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
      
      MLINE = 99
      MPAGE_NO = 0
      SELECT C
      DO FOX_USE WITH "NOTES INDEX NOTES", .F.
      
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      
      SELECT A
      DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
      SEEK MBEG_YR + MBEG_MO
      IF EOF()
         @ 4,1 CLEAR TO 21,78 
         @ 10,5 SAY 'THERE IS NO SALES DATA ON FILE FOR BEGINNING MONTH'
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
      IF MPROG_CODE = 2
         DO CASE
         CASE MSEL_SALES = '25'
            MBROK_NAME = 'KEITH'
         CASE MSEL_SALES = '26'
            MBROK_NAME = 'MATT '
         CASE MSEL_SALES = '27'    
            MBROK_NAME = 'KEN  '
         CASE MSEL_SALES = '29' 
            MBROK_NAME = 'KATHY'
         OTHERWISE
            MBROK_NAME = SPACE(5)
         ENDCASE
      ENDIF
      
      MTOT_NET = 0
      MTOT_COMM = 0
      DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR+TRAN_MO) <= VAL(MEND_YR+MEND_MO)                           
         IF SALESMAN = '  ' .AND. PO_NBR = '4487'
            SKIP
            LOOP
         ENDIF
         DO CASE
         CASE MPROG_CODE = 2
            IF SALESMAN = '25' .AND. PO_NBR = '2978' .AND. PO_SUFFIX = '2'
               SKIP
               LOOP
            ENDIF
            SELECT B
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
            SELECT A
            IF SALESMAN <> MSEL_SALES .AND. SAL_CODE2 <> MSEL_SALES .AND. SAL_CODE3 <> MSEL_SALES
               SKIP
               LOOP
            ENDIF
         OTHERWISE
            IF SALESMAN <> MSEL_SALES .AND. SAL_CODE2 <> MSEL_SALES .AND. SAL_CODE3 <> MSEL_SALES
               SKIP
               LOOP
            ENDIF
         ENDCASE
         SELECT A
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,30 SAY MCOMPANY
            @ 2,0 SAY 'PAGE'
            @ 2,05 say mpage_no picture '99'
            @ 2,14 SAY 'SALESPERSON DETAIL/SUMMARY OF ORDER ACTIVITY FOR: ' + MSEL_SALES 
            @ 2,70 SAY DTOC(DATE())
            @ 3,14 SAY '   ACTIVITY PERIOD: ' + MBEG_MO + '/' + MBEG_YR + ' THRU ' + MEND_MO + '/' + MEND_YR
            
            @ 5,2 SAY 'PO NBR'
            @ 5,15 SAY 'SHIP DATE'
            IF MPROG_CODE = 2
               @ 5,27 SAY 'INV/COR/MO'
            ELSE
               @ 5,28 SAY 'INV/COR'
            ENDIF
            @ 5,38 SAY 'SALES COMMISSN'   
            @ 5,58 SAY 'MW NET AMT'
            @ 5,0 SAY REPLICATE ('_',68)
            MLINE = 6
         ENDIF
         
         DO CASE
         CASE MPROG_CODE = 2
            IF SALESMAN <> SPACE(2)
               @ MLINE,0 SAY SALESMAN + '-'
            ENDIF
            
            @ MLINE,3 SAY PO_NBR
            IF PO_SUFFIX <> ' '
               @ MLINE,7 SAY '-' + PO_SUFFIX
            ENDIF
            
            @ MLINE,16 SAY SHIP_DATE
            @ MLINE,31 SAY INV_COR
            @ MLINE,33 SAY '- ' + TRAN_MO
            @ MLINE,38 SAY SALE_COMM PICTURE '999,999.99'
            @ MLINE,58 SAY TOT_NET PICTURE '999,999.99'
            MTOT_NET = MTOT_NET + TOT_NET
            MTOT_COMM = MTOT_COMM + SALE_COMM
            MLINE = MLINE + 1
         OTHERWISE
            IF SALESMAN = MSEL_SALES
               IF SALESMAN <> SPACE(2)
                  @ MLINE,0 SAY SALESMAN + '-'
               ENDIF
               
               @ MLINE,3 SAY PO_NBR
               IF PO_SUFFIX <> ' '
                  @ MLINE,7 SAY '-' + PO_SUFFIX
               ENDIF
               
               @ MLINE,16 SAY SHIP_DATE
               @ MLINE,31 SAY INV_COR
               @ MLINE,38 SAY SALE_COMM PICTURE '999,999.99'
               @ MLINE,58 SAY TOT_NET PICTURE '999,999.99'
               MTOT_NET = MTOT_NET + TOT_NET
               MTOT_COMM = MTOT_COMM + SALE_COMM
               MLINE = MLINE + 1
            ENDIF
            
            IF SAL_CODE2 = MSEL_SALES
               IF SALESMAN <> SPACE(2)
                  @ MLINE,0 SAY SALESMAN + '-'
               ENDIF
               
               @ MLINE,3 SAY PO_NBR
               IF PO_SUFFIX <> ' '
                  @ MLINE,7 SAY '-' + PO_SUFFIX
               ENDIF
               
               @ MLINE,16 SAY SHIP_DATE
               @ MLINE,31 SAY INV_COR
               @ MLINE,38 SAY SALE2_AMT PICTURE '999,999.99'
               @ MLINE,58 SAY SALE2_NET PICTURE '999,999.99'
               MTOT_NET = MTOT_NET + SALE2_NET
               MTOT_COMM = MTOT_COMM + SALE2_AMT
               MLINE = MLINE + 1
            ENDIF
            
            IF SAL_CODE3 = MSEL_SALES
               IF SALESMAN <> SPACE(2)
                  @ MLINE,0 SAY SALESMAN + '-'
               ENDIF
               
               @ MLINE,3 SAY PO_NBR
               IF PO_SUFFIX <> ' '
                  @ MLINE,7 SAY '-' + PO_SUFFIX
               ENDIF
               
               @ MLINE,16 SAY SHIP_DATE
               @ MLINE,31 SAY INV_COR
               @ MLINE,38 SAY SALE3_AMT PICTURE '999,999.99'
               @ MLINE,58 SAY SALE3_NET PICTURE '999,999.99'
               MTOT_NET = MTOT_NET + SALE3_NET
               MTOT_COMM = MTOT_COMM + SALE3_AMT
               MLINE = MLINE + 1
            ENDIF
            
            *** TRACK LAST LINE OF NOTES FOR RICHARD
            IF MSEL_SALES = '66'
               SELECT C
               SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX + '6'
               IF .NOT. EOF()
                  @ MLINE,5 SAY NOTE 
                  MLINE = MLINE + 1
               ENDIF    
               SELECT A
            ENDIF
         ENDCASE
         SKIP
      ENDDO
      MLINE = MLINE + 2
      
      @ MLINE,0 SAY 'TOTALS FOR PERIOD:'
      
      @ MLINE,38 SAY MTOT_COMM PICTURE '999,999.99'
      @ MLINE,58 SAY MTOT_NET PICTURE '999,999.99'
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
      
   CASE VAL(MSEL_RPT3) = 2
      
      MTITLE = ' - CONTACT CUSTOMER REPORT - OVERDUE ORDERS'                    
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      SET PROC TO PAYRPTS 
      
      @ 4,1 CLEAR TO 21,78
      MSEL_BBUY = SPACE(4)
      MYES_NO = '   '
      MACTION = 2
      MORD_PICK = 'D'
      MCOL_PICK = 'B'
      DO WHILE MACTION = 2
         @ 10,5 SAY 'Do you want to select a specific customer (YES/NO) ' GET MYES_NO PICTURE '@!'
         @ 12,5 SAY 'Include ALL (A) orders or just DUE (D) orders: ' GET MORD_PICK picture '@!'
         @ 14,5 SAY 'Print BOTH Invoice Amount and Due Amount (B) Columns '   
         @ 15,5 say '         OR    only print Invoice Amount (I) Columns: ' GET MCOL_PICK PICTURE '@!'
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
         @ 13,5 SAY ' SALESPERSON CODE: '
         @ 13,24 GET MCODE               
         @ 14,5 SAY " (ENTER '**' IF REPORT DESIRED FOR ALL SALESPERSONS)"
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
      INDEX ON NAME  + RSUPCODE TO TEMP_AGE
      INDEX ON SALESMAN + REGION + RSUPCODE TO TEMPAGE2
      INDEX ON REGION + RSUPCODE TO TEMPAGE3
      DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE, TEMPAGE2, TEMPAGE3", .F.
      
      SELECT A
      DO FOX_USE WITH "CUS_INV INDEX CUS_DATE", .F.
      
      SEEK ' '            
      IF EOF()
         @ 14,1 SAY 'THERE ARE NO OUTSTANDING INVOICES TO BE AGED'         
         @ 16,1 SAY ' '
         WAIT 'PRESS RETURN TO CONTINUE'
         LOOP  
      ENDIF
      
      MDATE = MRPT_DATE - 7 
      DO WHILE .NOT. EOF() .AND. PAID_FLG = ' '
         IF MSEL_BBUY <> SPACE(4)
            IF MSEL_BBUY <> BBUYCODE
               SKIP
               LOOP
            ENDIF
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
            ELSE
               STORE BUYER_PO TO MBUYER_PO
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
            
            IF MSTILL_DUE > 0 
               MBALANCE = MBALANCE + MSTILL_DUE
               IF DTOC(SHIP_DATE) <> '  /  /  '
                  STORE SHIP_DATE TO MTRAN_DATE    
               ELSE
                  STORE INV_DATE TO MTRAN_DATE   
               ENDIF
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
               
               IF MTRAN_DATE <= MDATE .OR. MORD_PICK = 'A'
                  REPLACE INV_NBR WITH MINV_NBR
                  REPLACE PO_NBR WITH MPO_NBR
                  REPLACE PO_SUFFIX WITH MPO_SUFFIX
                  REPLACE BUYER_PO WITH MBUYER_PO
                  IF MORD_PICK = 'A'
                     IF MTRAN_DATE <= MDATE 
                        MOVERDUE = MOVERDUE + MSTILL_DUE       
                     ENDIF
                  ELSE
                     MOVERDUE = MOVERDUE + MSTILL_DUE       
                  ENDIF
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
      
      MPAGE_NO = 0
      MLINE = 99 
      MPAGE_LEN = 58
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      
      SELECT D
      DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE, TEMPAGE2, TEMPAGE3", .F.
      DO WHILE .NOT. EOF()
         STORE SALESMAN TO MSALESMAN
         STORE NAME TO MNAME
         STORE RSUPCODE TO MBBUYCODE
         SELECT C
         SEEK MBBUYCODE
         IF .NOT. EOF()
            ** STORE CUS_BAL TO MBALANCE
            STORE CRED_LIM TO MCRED_LIM
            MCRED_LIM1 = SPACE(3)
            IF MCRED_LIM = 0
               IF MPROG_CODE = 2
                  IF SUBSTR(NOTE,1,3) = 'L/C' .OR. SUBSTR(NOTE,1,3) = 'CAD'
                     MCRED_LIM1 = SUBSTR(NOTE,1,3)
                  ENDIF
               ENDIF
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
            MCRED_LIM1 = SPACE(3)
         ENDIF
         STORE 0 TO MOVERDUE, MBALANCE
         MPRT_CUST = .T.
         SELECT D
         DO WHILE .NOT. EOF() .AND. NAME = MNAME .AND. RSUPCODE = MBBUYCODE
            
            MBALANCE = MBALANCE + STILL_DUE
            IF PO_NBR = SPACE(4)
               SKIP
               LOOP
            ENDIF
            
            IF MLINE > MPAGE_LEN
               MPRT_CUST = .T.
               DO AGEHEAD1
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
                     DO AGEHEAD1
                  ENDIF
               ENDIF
            ENDIF
            
            IF SALESMAN <> '  '
               @ MLINE,1 SAY SALESMAN + '-'
            ENDIF
            @ MLINE,4 SAY INV_NBR
            @ MLINE,12 SAY TOT_SELL PICTURE '999,999.99'
            IF MCOL_PICK = 'B'
               @ MLINE,25 SAY STILL_DUE PICTURE '999,999.99'
            ENDIF
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
            IF MDAYS > 0
               @ MLINE,92 SAY MDAYS PICTURE '999'
            ENDIF
            
            IF MORD_PICK = 'A'
               IF MDAYS > 0             
                  IF MCOL_PICK = 'B'
                     MOVERDUE = MOVERDUE + STILL_DUE       
                  ELSE
                     MOVERDUE = MOVERDUE + TOT_SELL
                  ENDIF
               ENDIF
            ELSE
               IF MCOL_PICK = 'B'
                  MOVERDUE = MOVERDUE + STILL_DUE       
               ELSE
                  MOVERDUE = MOVERDUE + TOT_SELL
               ENDIF
            ENDIF
            
            *** MOVERDUE = MOVERDUE + STILL_DUE       
            
            MLINE = MLINE + 2
            SKIP
         ENDDO
         **** DO CUSTOMER OVERDUE BALANCE HERE
         IF MOVERDUE > 0
            IF MLINE > MPAGE_LEN
               MPRT_CUST = .T.
               DO AGEHEAD1
            ENDIF
            @ MLINE,5 SAY 'OVERDUE TOTAL: '
            @ MLINE,24 SAY MOVERDUE PICTURE '999,999.99'
            MLINE = MLINE + 2
            IF MLINE > MPAGE_LEN
               MPRT_CUST = .T.
               DO AGEHEAD1
            ENDIF
            @ MLINE,5 SAY '    TOTAL DUE:'      
            @ MLINE,24 SAY MBALANCE PICTURE '999,999.99'
            MLINE = MLINE + 2
            IF MLINE > MPAGE_LEN
               MPRT_CUST = .T.
               DO AGEHEAD1
            ENDIF
            @ MLINE,5 SAY ' CREDIT LIMIT:'      
            IF MPROG_CODE = 1
               @ MLINE,24 SAY MCRED_LIM PICTURE '999,999.99'
            ELSE
               IF MCRED_LIM <> 0 
                  @ MLINE,24 SAY MCRED_LIM PICTURE '999,999.99'
               ELSE
                  @ MLINE,25 SAY MCRED_LIM1                      
               ENDIF
            ENDIF
            MLINE = MLINE + 2
            IF MAVG_25 <> 0 .OR. MAVG_180 <> 0
               IF MLINE > MPAGE_LEN
                  MPRT_CUST = .T.
                  DO AGEHEAD1
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
               EJECT            
               MLINE = 88
            ENDIF
         ENDIF
      ENDDO
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      CLOSE DATA
      
   CASE VAL(MSEL_RPT3) = 3
      MTITLE = ' - CONTACT CUSTOMER REPORT - OVERDUE ORDERS'                    
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      STORE SPACE(32) TO MNAME
      STORE 2 TO MACTION
      MCODE = '**'
      DO WHILE MACTION = 2
         @ 10,5 SAY 'THIRD PARTY COMMISSION PAYEE'
         @ 12,5 GET MNAME PICTURE '@!'
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2. Edit    3. Cancel'    
         READ
         @ 24,9 GET MACTION PICTURE '9' RANGE 1,3
         READ
         IF MACTION = 1
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
            SEEK TRIM(MNAME)
            IF EOF()
               @ 24,0 CLEAR 
               STORE ' ' TO MWAIT
               @ 24,1 SAY 'THIRD PARTY COMMISSION PAYEE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
               READ
               @ 24,0 CLEAR
               MACTION = 2
            ELSE
               STORE RECNO() TO MFST_REC
               SKIP
               STORE TRIM(MNAME) TO SRCH_ARG
               IF NAME = SRCH_ARG    
                  MNAME_FD = .F.
                  DO MULTCOM
                  IF MNAME_FD
                     STORE NAME TO MNAME
                     STORE COM_CODE TO MCODE
                     MACTION = 1
                  ELSE
                     MACTION = 3
                     LOOP
                  ENDIF
               ELSE
                  GOTO MFST_REC
                  STORE NAME TO MNAME
                  STORE COM_CODE TO MCODE
               ENDIF
            ENDIF
         ENDIF
      ENDDO
      IF MACTION = 3
         LOOP
      ENDIF
      
      SET PROC TO PAYRPTS 
      
      @ 4,1 CLEAR TO 21,78
      MSEL_BBUY = SPACE(4)
      MYES_NO = 'NO '
      MACTION = 2
      MORD_PICK = 'A'
      MCOL_PICK = 'B'
      DO WHILE MACTION = 2
         @ 10,5 SAY 'Do you want to select a specific customer (YES/NO) ' GET MYES_NO PICTURE '@!'
         @ 12,5 SAY 'Include ALL (A) orders or just DUE (D) orders: ' GET MORD_PICK picture '@!'
         @ 14,5 SAY 'Print BOTH Invoice Amount and Due Amount (B) Columns '   
         @ 15,5 say '         OR    only print Invoice Amount (I) Columns: ' GET MCOL_PICK PICTURE '@!'
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
      **** GET DATE FOR THIS REPORT
      STORE DATE() TO MRPT_DATE
      STORE 1  TO MTIMES
      STORE 'D' TO MDISP_PRT
      STORE 'NO ' TO MOLD_PICK
      @ 4,1 CLEAR TO 21,78
      
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
      DO FOX_USE WITH "NOTES INDEX NOTES", .F.
      
      SELECT D
      USE TEMP_AGE EXCLUSIVE         
      DELETE ALL
      PACK
      USE
      
      SELECT D
      DO FOX_USE WITH "TEMP_AGE", .F.
      INDEX ON NAME  + RSUPCODE TO TEMP_AGE
      INDEX ON SALESMAN + REGION + RSUPCODE TO TEMPAGE2
      INDEX ON REGION + RSUPCODE TO TEMPAGE3
      DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE, TEMPAGE2, TEMPAGE3", .F.
      
      SELECT A
      DO FOX_USE WITH "CUS_INV INDEX CUS_DATE", .F.
      
      SEEK ' '            
      IF EOF()
         @ 14,1 SAY 'THERE ARE NO OUTSTANDING INVOICES TO BE AGED'         
         @ 16,1 SAY ' '
         WAIT 'PRESS RETURN TO CONTINUE'
         LOOP  
      ENDIF
      MDATE = MRPT_DATE - 7 
      DO WHILE .NOT. EOF() .AND. PAID_FLG = ' '
         IF MSEL_BBUY <> SPACE(4)
            IF MSEL_BBUY <> BBUYCODE
               SKIP
               LOOP
            ENDIF
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
            STORE INV_NBR TO MINV_NBR
            STORE SALESMAN  TO MSALESMAN
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
            MBUYER_PO = SPACE(15)
            SELECT E
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF EOF()
               SELECT A
               SKIP
               LOOP
            ENDIF
            
            IF MCODE <> '**'
               IF COM_CODE <> MCODE .AND. COM_CODE2 <> MCODE
                  SELECT A
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            SELECT B
            SEEK MSALESMAN+MPO_NBR+MPO_SUFFIX
            IF .NOT. EOF() 
               MBUYER_PO = SUBSTR(NOTE,1,4) + SPACE(8)
            ENDIF
            
            SELECT A
            MSTILL_DUE = MAMT - AMT_PAID
            
            IF MSTILL_DUE > 0 
               MBALANCE = MBALANCE + MSTILL_DUE
               IF DTOC(SHIP_DATE) <> '  /  /  '
                  STORE SHIP_DATE TO MTRAN_DATE    
               ELSE
                  STORE INV_DATE TO MTRAN_DATE   
               ENDIF
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
               
               IF MTRAN_DATE <= MDATE .OR. MORD_PICK = 'A'
                  REPLACE INV_NBR WITH MINV_NBR
                  REPLACE PO_NBR WITH MPO_NBR
                  REPLACE PO_SUFFIX WITH MPO_SUFFIX
                  REPLACE BUYER_PO WITH MBUYER_PO
                  IF MORD_PICK = 'A'
                     IF MTRAN_DATE <= MDATE 
                        MOVERDUE = MOVERDUE + MSTILL_DUE       
                     ENDIF
                  ELSE
                     MOVERDUE = MOVERDUE + MSTILL_DUE       
                  ENDIF
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
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      
      SELECT D
      DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE, TEMPAGE2, TEMPAGE3", .F.
      DO WHILE .NOT. EOF()
         STORE SALESMAN TO MSALESMAN
         STORE NAME TO MNAME
         STORE RSUPCODE TO MBBUYCODE
         SELECT C
         SEEK MBBUYCODE
         IF .NOT. EOF()
            ** STORE CUS_BAL TO MBALANCE
            STORE CRED_LIM TO MCRED_LIM
            MCRED_LIM1 = SPACE(3)
            IF MCRED_LIM = 0
               IF MPROG_CODE = 2
                  IF SUBSTR(NOTE,1,3) = 'L/C' .OR. SUBSTR(NOTE,1,3) = 'CAD'
                     MCRED_LIM1 = SUBSTR(NOTE,1,3)
                  ENDIF
               ENDIF
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
            MCRED_LIM1 = SPACE(3)
         ENDIF
         STORE 0 TO MOVERDUE, MBALANCE
         MPRT_CUST = .T.
         SELECT D
         DO WHILE .NOT. EOF() .AND. NAME = MNAME .AND. RSUPCODE = MBBUYCODE
            
            MBALANCE = MBALANCE + STILL_DUE
            IF PO_NBR = SPACE(4)
               SKIP
               LOOP
            ENDIF
            
            IF MLINE > MPAGE_LEN
               MPRT_CUST = .T.
               DO AGEHEAD2
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
                     DO AGEHEAD2
                  ENDIF
               ENDIF
            ENDIF
            
            IF SALESMAN <> '  '
               @ MLINE,1 SAY SALESMAN + '-'
            ENDIF
            @ MLINE,4 SAY INV_NBR
            @ MLINE,12 SAY TOT_SELL PICTURE '999,999.99'
            IF MCOL_PICK = 'B'
               @ MLINE,25 SAY STILL_DUE PICTURE '999,999.99'
            ENDIF
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
            IF MDAYS > 0
               @ MLINE,92 SAY MDAYS PICTURE '999'
            ENDIF
            
            IF MORD_PICK = 'A'
               IF MDAYS > 0             
                  IF MCOL_PICK = 'B'
                     MOVERDUE = MOVERDUE + STILL_DUE       
                  ELSE
                     MOVERDUE = MOVERDUE + TOT_SELL
                  ENDIF
               ENDIF
            ELSE
               IF MCOL_PICK = 'B'
                  MOVERDUE = MOVERDUE + STILL_DUE       
               ELSE
                  MOVERDUE = MOVERDUE + TOT_SELL
               ENDIF
            ENDIF
            
            *** MOVERDUE = MOVERDUE + STILL_DUE       
            
            MLINE = MLINE + 2
            SKIP
         ENDDO
         **** DO CUSTOMER OVERDUE BALANCE HERE
         **IF MOVERDUE > 0
         IF MLINE > MPAGE_LEN
            MPRT_CUST = .T.
            DO AGEHEAD2
         ENDIF
         @ MLINE,5 SAY 'OVERDUE TOTAL: '
         @ MLINE,24 SAY MOVERDUE PICTURE '999,999.99'
         MLINE = MLINE + 2
         IF MLINE > MPAGE_LEN
            MPRT_CUST = .T.
            DO AGEHEAD2
         ENDIF
         @ MLINE,5 SAY '    TOTAL DUE:'      
         @ MLINE,24 SAY MBALANCE PICTURE '999,999.99'
         MLINE = MLINE + 2
         IF MLINE > MPAGE_LEN
            MPRT_CUST = .T.
            DO AGEHEAD2
         ENDIF
         @ MLINE,5 SAY ' CREDIT LIMIT:'      
         IF MPROG_CODE = 1
            @ MLINE,24 SAY MCRED_LIM PICTURE '999,999.99'
         ELSE
            IF MCRED_LIM <> 0 
               @ MLINE,24 SAY MCRED_LIM PICTURE '999,999.99'
            ELSE
               @ MLINE,25 SAY MCRED_LIM1                      
            ENDIF
         ENDIF
         MLINE = MLINE + 2
         IF MAVG_25 <> 0 .OR. MAVG_180 <> 0
            IF MLINE > MPAGE_LEN
               MPRT_CUST = .T.
               DO AGEHEAD2
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
            EJECT            
            MLINE = 88
            ***ENDIF
         ENDIF
      ENDDO
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      CLOSE DATA
      
   CASE VAL(MSEL_RPT3) = 4
      DO ALLAGE
      
   CASE VAL(MSEL_RPT3) = 5 
      MTITLE = " - SALESPERSON PAYMENT WORKSHEET"                           
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE SPACE(2) TO MBEG_MO,  MEND_MO
      STORE SPACE(4) TO MBEG_YR, MEND_YR
      STORE 0 TO MPERCENT
      STORE 'P' TO MDISP_PRT
      STORE '**' to msel_sales
      STORE CTOD('') TO MSEL_SHIP
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 08,4 SAY 'ENTER MONTH/YEAR REPORT DATE: '
         @ 08,37 SAY '/'
         @ 10,4 SAY 'ENTER/SELECT ONE SALESPERSON: '
         @ 12,4 SAY ' PERCENT OF GROSS FOR SALARY: '
         @ 08,35 GET MBEG_MO
         @ 08,38 GET MBEG_YR
         @ 10,35 GET MSEL_SALES               
         @ 12,35 GET MPERCENT PICTURE '###'    
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF MSEL_SALES = '**' 
               @ 24,0 CLEAR
               mwait = ' '
               @ 24,1 SAY 'MUST SELECT SALESPERSON - PRESS ANY KEY TO REENTER' GET MWAIT
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
      *** IF ANY ARE SPACES, GET OUT OF THIS REPORT 
      IF MBEG_MO = SPACE(2) .OR. MBEG_YR = SPACE(4)       
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
      
      MLINE = 99
      MPAGE_NO = 0
      
      SELECT A
      DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
      SEEK MBEG_YR + MBEG_MO
      IF EOF()
         @ 4,1 CLEAR TO 21,78 
         @ 10,5 SAY 'THERE IS NO SALES DATA ON FILE FOR BEGINNING MONTH'
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
      
      MTOT_SELL = 0
      MTOT_PURCH = 0
      MTOT_FRT   = 0
      MTOT_COMM  = 0
      DO WHILE .NOT. EOF() .AND. TRAN_YR= MBEG_YR .AND. TRAN_MO = MBEG_MO                           
         DO CASE
         CASE MSEL_SALES = '10'
            MTOT_SELL  = MTOT_SELL + TOT_SELL + CUS_PALL
            MTOT_PURCH = MTOT_PURCH + TOT_PURCH + SUP_PALL
            MTOT_FRT   = MTOT_FRT + FRT_AMT1 + FRT_PALL
            MTOT_COMM  = MTOT_COMM + COMM_AMT + COMM_AMT2 + COMM_AMT3 + SALE2_AMT + SALE2_NET + SALE3_AMT + SALE3_NET
            IF SALESMAN <> '10'
               *** GET THE SALESMAN'S PERCENT
               SELECT B
               DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
               SEEK A->SALESMAN
               IF .NOT. EOF()
                  STORE SALE_PERC TO MSALE_PERC
                  IF SALE_PER2 <> 0
                     STORE SALE_PER2 TO MSALE_PERC
                  ENDIF
                  IF SALE_PER3 <> 0
                     STORE SALE_PER3 TO MSALE_PERC
                  ENDIF
               ELSE
                  STORE 0 TO MSALE_PERC
               ENDIF
               USE
               SELECT A
               IF MSALE_PERC <> 0
                  MSALE_PERC = MSALE_PERC/100
               ENDIF
               MTOT_COMM = MTOT_COMM + ROUND(SALE_COMM/MSALE_PERC,2) 
            ENDIF
            
         OTHERWISE
            IF SALESMAN <> MSEL_SALES                                 
               SKIP
               LOOP
            ENDIF
            MTOT_SELL  = MTOT_SELL + TOT_SELL + CUS_PALL
            MTOT_PURCH = MTOT_PURCH + TOT_PURCH + SUP_PALL
            MTOT_FRT   = MTOT_FRT + FRT_AMT1 + FRT_PALL
            MTOT_COMM  = MTOT_COMM + COMM_AMT + COMM_AMT2 + COMM_AMT3 + SALE2_AMT + SALE3_AMT              
         ENDCASE
         SKIP
      ENDDO
      MPAGE_NO = MPAGE_NO + 1
      @ 1,30 SAY MCOMPANY
      @ 2,25 SAY 'SALESPERSON PAYMENT WORKSHEET: ' + MSEL_SALES 
      
      MLINE = 4
      @ MLINE,5 SAY "TODAY'S DATE: "
      @ MLINE,19 SAY DATE()
      MLINE = MLINE + 2
      @ MLINE,5 SAY 'MONTHLY PERIOD: ' + MBEG_MO + '/' + MBEG_YR
      MLINE = MLINE + 3
      
      @ MLINE,5 SAY 'PRODUCT SALES:'     
      @ MLINE,45 SAY MTOT_SELL PICTURE '9,999,999.99'
      
      MLINE = MLINE + 2
      @ MLINE,5 SAY 'PRODUCT PURCHASES:'
      @ MLINE,45 SAY MTOT_PURCH PICTURE '9,999,999.99'
      
      MLINE = MLINE + 2
      @ MLINE,5 SAY 'FREIGHT CHARGES:'
      @ MLINE,45 SAY MTOT_FRT PICTURE '9,999,999.99'
      
      MLINE = MLINE + 2
      @ MLINE,5 SAY 'THIRD PARTY/INTRACOMP COMM & NET:'
      @ MLINE,45 SAY MTOT_COMM PICTURE '9,999,999.99'
      
      MLINE = MLINE + 2
      @ MLINE,5 SAY 'GROSS PROFIT:'
      MGROSS = MTOT_SELL - MTOT_PURCH - MTOT_FRT - MTOT_COMM 
      @ MLINE,45 SAY MGROSS PICTURE '9,999,999.99'
      MLINE = MLINE + 3
      
      SELECT A
      DO FOX_USE WITH "DISBJRN INDEX DISBJRN", .F.
      SEEK MBEG_YR+ MBEG_MO            
      
      SELECT B
      USE TMP_ACCT EXCLUSIVE
      DELETE ALL
      PACK
      INDEX ON CATEGORY + SALESMAN TO TMP_ACCT
      USE
      DO FOX_USE WITH "TMP_ACCT INDEX TMP_ACCT", .F.
      SELECT A
      DO WHILE .NOT. EOF() .AND. JRNL_MO = MBEG_MO .AND. JRNL_YR = MBEG_YR
         IF VOID_MAN = 'V'
            SKIP
            LOOP
         ENDIF
         MTYPE = SUBSTR(ACCT_TYPE,1,1)
         IF MTYPE = 'S' .OR. MTYPE = 'F' 
            SKIP
            LOOP
         ENDIF
         IF CATEGORY1 = '8598' .OR. CATEGORY1 = '8599' .OR. CATEGORY1 = '8001' .OR. CATEGORY1 = '8002' .OR. CATEGORY1 = '3220'
            SKIP
            LOOP
         ENDIF
         
         IF CATEGORY1 = '3301' .OR. CATEGORY1 = '3302' .OR. CATEGORY1 = '3310'
            SKIP
            LOOP
         ENDIF
         IF CATEGORY1 = '3312' .OR. CATEGORY1 = '3314' .OR. CATEGORY1 = '3316'
            SKIP
            LOOP
         ENDIF
         IF CATEGORY1 = '8240' .OR. CATEGORY1 = '8020' .OR. CATEGORY1 = '3306'
            SKIP
            LOOP
         ENDIF
         IF CATEGORY1 = '3321' .OR. CATEGORY1 = '3307' .OR. CATEGORY1 = '3308'
            SKIP
            LOOP
         ENDIF
         IF CATEGORY1 = '3318' .OR. CATEGORY1 = '8068'
            SKIP
            LOOP
         ENDIF
         
         
         SELECT B
         SEEK A->CATEGORY1
         IF EOF()
            DO FILELOCK
            APPEND BLANK
            REPLACE CATEGORY WITH A->CATEGORY1
            UNLOCK
         ENDIF
         DO RECLOCK
         IF CATEGORY = '3305'
            *** ONLY COUNT HALF OF FICA
            REPLACE AMOUNT WITH AMOUNT + A->AMOUNT1 * .5
         ELSE
            REPLACE AMOUNT WITH AMOUNT + A->AMOUNT1      
         ENDIF
         UNLOCK
         SELECT A
         SKIP
      ENDDO
      
      SELECT A
      USE
      @ MLINE,5 SAY 'OPERATING EXPENSES'
      MLINE = MLINE + 2
      
      SELECT D
      DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
      SELECT B
      GOTO TOP
      MTOT_EXP = 0
      MDRAW = 0
      DO WHILE .NOT. EOF()
         IF CATEGORY = '8000'
            MDRAW = AMOUNT
            SKIP
            LOOP
         ENDIF
         
         SELECT D
         SEEK B->CATEGORY 
         @ MLINE,5 SAY DESCRIP
         SELECT B
         @ MLINE,45 SAY AMOUNT PICTURE '9,999,999.99'
         MLINE = MLINE + 2
         MTOT_EXP = MTOT_EXP + AMOUNT
         SKIP
      ENDDO
      @ MLINE,5 SAY 'TOTAL EXPENSE: '
      @ MLINE,45 SAY MTOT_EXP PICTURE '9,999,999.99'
      MLINE = MLINE + 3
      @ MLINE,5 SAY 'NET INCOME FOR THE PERIOD: '
      
      MNET = MGROSS - MTOT_EXP 
      @ MLINE,45 SAY MNET PICTURE '9,999,999.99'
      MLINE = MLINE + 3
      MSALARY = ROUND((MPERCENT/100) * MNET,2)
      @ MLINE,5 SAY 'SALARY TO BE PAID:' 
      @ MLINE,45 SAY MSALARY PICTURE '9,999,999.99'
      MLINE = MLINE + 2
      @ MLINE,5 SAY 'MINUS SALARY PAID IN MONTH:'
      @ MLINE,45 SAY MDRAW PICTURE '9,999,999.99'
      MLINE = MLINE + 3
      @ MLINE,5 SAY 'AMOUNT OF PAYMENT/CHECK:'
      @ MLINE,45 SAY MSALARY - MDRAW PICTURE '9,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,1 SAY ' '
      EJECT
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      
   CASE VAL(MSEL_RPT3) = 6  
      *** CASH FLOW REPORT FOR ALL DATABASES
      ** 1 = &MMASTDBF. - DIVISION 01 - MIDWEST FOOD & POULTRY
      ** 2 = K: - DIVISION 15 - FOOD SERVICE
      ** 3 = I: - DIVISION 10 - YUMA, AZ
      ** 4 = P: - DIVISION MF - MFI
      MTIMES = 1
      DO WHILE MTIMES <= 4
         MI = STR(MTIMES,1)
         STORE 0 TO MTOT_REC&MI, MTOT_PAY&MI, MTOT_RECV&MI, MTOT_INV&MI
         MTIMES = MTIMES + 1
      ENDDO
      
      MTITLE = ' - RECEIPTS/PAYMENTS/RECV/INVEN'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE DATE() TO MDATE              
      DO WHILE MACTION = 2      
         @ 08,5 SAY 'REPORT DATE: '
         @ 08,24 GET MDATE
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
               @ 24,1 SAY 'BOTH DATES NOT ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
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
      MPAGE_LEN = 56
      
      MPAGE_NO = 0
      MLINE = 1  
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
      
      STORE MONTH(MDATE) TO MMONTH
      MMONTH = MMONTH + 100
      STORE SUBSTR(STR(MMONTH,3),2) TO MMONTH
      
      STORE YEAR(MDATE) TO MYEAR
      STORE STR(MYEAR,4) TO MYEAR
      
      STORE DAY(MDATE) TO MDAY
      MDAY = MDAY + 100
      STORE SUBSTR(STR(MDAY,3),2) TO MDAY
      
      MTIMES = 1
      DO WHILE MTIMES <= 4
         DO CASE
         CASE MTIMES = 1
            MFILE = '&MMASTDBF.'
         CASE MTIMES = 2
            MFILE = 'K:'
         CASE MTIMES = 3 
            MFILE = 'I:'
         CASE MTIMES = 4 
            MFILE = 'P:'
         ENDCASE
         MI = STR(MTIMES,1)
         
         **** CALCULATE THE RECEIPTS
         SELECT A
         DO FOX_USE WITH "&MFILE.PAYMENTS INDEX &MFILE.PAY_DATE, &MFILE.PAY_PO", .F.
         SEEK MYEAR + MMONTH + MDAY  
         
         DO WHILE .NOT. EOF() .AND. PAID_DATE <= MDATE
            MTOT_REC&MI = MTOT_REC&MI + AMT_PAID + CRED_AMT + AMT_OVER
            SKIP  
         ENDDO    
         CLOSE DATA
         
         **** CALCULATE THE PAYMENTS
         SELECT A
         DO FOX_USE WITH "&MFILE.CK_REG INDEX &MFILE.CK_DATE", .F.
         
         SEEK MYEAR + MMONTH + MDAY
         DO WHILE .NOT. EOF() .AND. CK_DATE <= MDATE
            IF VOID_MAN = 'V'
               SKIP
               LOOP
            ENDIF
            MTOT_PAY&MI = MTOT_PAY&MI + AMOUNT
            SKIP
         ENDDO
         CLOSE DATA
         
         **** CALCULATE THE RECEIVABLES
         SELECT A
         DO FOX_USE WITH "&MFILE.CUS_INV", .F.
         SET FILTER TO PAID_FLG = ' '
         GOTO TOP
         SUM TOT_SELL+CUS_PALL-AMT_PAID TO MTOT_RECV&MI
         CLOSE DATA
         
         
         **** CALCULATE THE INVENTORY
         DO CASE
            ** DIVISION 15
         CASE MTIMES = 2                   
            
            SELECT A
            DO FOX_USE WITH "K:INVEN", .F.
            
            SET FILTER TO SOLD_FLG = ' '
            GOTO TOP
            DO WHILE .NOT. EOF()
               
               MCASE_LEFT = 0
               MVAL_LEFT = 0
               MLBS_LEFT = 0
               ***CALCULATE CURRENT VALUE
               
               SELECT A
               MVAL_LEFT  = VALUE
               MLBS_LEFT  = LBS
               MCASE_LEFT = CASE_CNT
               MTOT_COST = 0    
               MTOT_PRO  = 0
               MWORK_COST = 0
               SELECT B
               DO FOX_USE WITH "K:INVN_DTL INDEX K:DTL_LOT, K:IDTL_DTL, K:INVN_PO, K:INVNDISP, K:DTL_DATE, K:INVN_DTL", .F.
               
               **SEEK STR(A->I_NBR,5)
               ***HERE
               SEEK A->FREEZ_LOC + A->LOT_NBR
               *DO WHILE .NOT. EOF() .AND. A->I_NBR = I_NBR
               DO WHILE .NOT. EOF() .AND. A->FREEZ_LOC = FREEZ_LOC .AND. A->LOT_NBR = LOT_NBR
                  DO CASE    
                  CASE ACT_CODE = 'C'
                     MTOT_COST = MTOT_COST + COST_AMT
                     MWORK_COST = MWORK_COST + COST_AMT
                  CASE ACT_CODE = 'S'
                     MTHIS_COST =  ROUND(MWORK_COST/MLBS_LEFT,4) * SHIP_LBS
                     MLBS_LEFT  = MLBS_LEFT  - SHIP_LBS
                     MVAL_LEFT  = MVAL_LEFT  - SHIP_VAL               
                     MCASE_LEFT = MCASE_LEFT - SHIP_CASE
                     MTOT_PRO  = MTOT_PRO + MTHIS_COST
                     MWORK_COST = MWORK_COST - MTHIS_COST
                  ENDCASE
                  SKIP
               ENDDO
               MVAL_LEFT = MVAL_LEFT + ( MTOT_COST - MTOT_PRO)
               SELECT B
               USE
               SELECT A
               
               IF MLBS_LEFT <> 0
                  MSTOR_UNIT = 0
                  MPRO_PRI = PRI_LB + MSTOR_UNIT                  
                  MVAL_LEFT = ROUND(MPRO_PRI * MLBS_LEFT,2)
               ELSE
                  MPRO_PRI = 0
                  MVAL_LEFT = 0
               ENDIF
               MTOT_INV&MI = MTOT_INV&MI + MVAL_LEFT
               SKIP
            ENDDO
            
         OTHERWISE
            DO CASE
            CASE MTIMES = 1           
               MDIV = '01'
            CASE MTIMES = 3                      
               MDIV = '10'
            CASE MTIMES = 4                      
               MDIV = 'MF'
            OTHERWISE
               MDIV = '??'
            ENDCASE
            
            SELECT A
            DO FOX_USE WITH "S:INVEN", .F.
            
            SET FILTER TO SOLD_FLG = ' '
            GOTO TOP
            DO WHILE .NOT. EOF()
               IF MDIV <> DIV_CODE
                  SKIP
                  LOOP
               ENDIF
               
               SELECT A
               IF CASE_LEFT > 0
                  MVAL_LEFT = ROUND(LBS_LEFT * PRI_LB,2)
               ENDIF
               MTOT_INV&MI = MTOT_INV&MI + MVAL_LEFT
               SKIP
            ENDDO
            
         ENDCASE
         CLOSE DATA
         
         MTIMES = MTIMES + 1
      ENDDO
      
      MT_REC = 0
      MT_PAY = 0
      MT_RECV = 0
      MT_INV  = 0
      MPAGE_NO = MPAGE_NO + 1
      @ 1,30 SAY MCOMPANY
      @ 2,0 SAY 'PAGE'
      @ 2,05 say mpage_no picture '99'
      @ 2,27 SAY 'CASH FLOW REPORT FOR: ' + DTOC(MDATE)
      @ 2,70 SAY DTOC(DATE())
      @ 5,1 SAY 'DIVISION'
      @ 5,1+15 SAY '      RECEIPTS'
      @ 5,20+15 SAY '        CHECKS'
      @ 5,40+15 SAY '   RECEIVABLES'
      @ 5,60+15 SAY '     INVENTORY'   
      @ 6,1 SAY REPLICATE ('_',89)
      MLINE = 8
      
      MTIMES = 1
      DO WHILE MTIMES <= 4
         DO CASE
         CASE MTIMES = 1  
            @ MLINE,1 SAY 'DIVISION 01'
         CASE MTIMES = 2  
            @ MLINE,1 SAY 'DIVISION 15'
         CASE MTIMES = 3  
            @ MLINE,1 SAY 'DIVISION 10'
         OTHERWISE       
            @ MLINE,1 SAY 'MFI        '
         ENDCASE
         MI = STR(MTIMES,1)
         @ MLINE,1+15 SAY MTOT_REC&MI PICTURE '999,999,999.99'
         @ MLINE,20+15 SAY MTOT_PAY&MI PICTURE '999,999,999.99'
         @ MLINE,40+15 SAY MTOT_RECV&MI PICTURE '999,999,999.99'
         @ MLINE,60+15 SAY MTOT_INV&MI PICTURE '999,999,999.99'
         MT_REC = MT_REC + MTOT_REC&MI
         MT_PAY = MT_PAY + MTOT_PAY&MI
         MT_RECV = MT_RECV + MTOT_RECV&MI
         MT_INV  = MT_INV  + MTOT_INV&MI
         
         MLINE = MLINE + 2
         MTIMES = MTIMES + 1
      ENDDO
      MLINE = MLINE + 2
      @ MLINE,1 SAY 'TOTAL ALL DIV:'
      @ MLINE,1+15 SAY MT_REC PICTURE '999,999,999.99'
      @ MLINE,20+15 SAY MT_PAY PICTURE '999,999,999.99'
      @ MLINE,40+15 SAY MT_RECV PICTURE '999,999,999.99'
      @ MLINE,60+15 SAY MT_INV PICTURE '999,999,999.99'
      
      @ MLINE+1,1 SAY ' '
      EJECT
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
   CASE VAL(MSEL_RPT3) = 7
      **** NOTE: THIS HAS NOT BEEN CHANGED TO REFERENCE THE FRT_2ND FILE
      **** THAT FILE IS USE BY MFI CURRENTLY
      MTITLE = ' - LIST FREIGHT ACTIVITY BY OPTIONAL SALESPERSON'
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET FIRST AND LAST DATES FOR THIS REPORT
      STORE CTOD(' ') TO MSTART, MLAST
      STORE 'P' TO MDISP_PRT
      STORE '**' TO MOPT_SALES
      MFRT_SEL = '1'
      @ 09,2 say '        BEGINNING DATE: '
      @ 11,2 SAY '           ENDING DATE: '
      @ 14,2 SAY '(OPTIONAL) SALESPERSON: '
      @ 16,2 SAY 'SELECT FREIGHT CARRIER (1)'               
      @ 17,2 SAY '   OR  FREIGHT CARRIER (2): '                
      @ 18,2 SAY '   OR  FREIGHT CARREIR (3):'
      
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 09,27 GET MSTART
         @ 11,27 GET MLAST
         @ 14,27 GET MOPT_SALES PICTURE '@!'
         @ 17,31 GET MFRT_SEL PICTURE '#'
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
      INDEX ON TRAN_DATE TO TEMP_AGE
      CLOSE DATA
      SELECT A 
      DO FOX_USE WITH "PO_HEAD INDEX  PO_SHIP", .F.
      SELECT C 
      DO FOX_USE WITH "TEMP_AGE INDEX  TEMP_AGE", .F.
      SELECT D
      DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
      SELECT F
      DO FOX_USE WITH "FRT_2ND INDEX FRT2_PO", .F.
      
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
      IF MFRT_SEL <> '1' .AND. MFRT_SEL <> '2' .AND. MFRT_SEL <> '3'
         MFRT_SEL = '1'
      ENDIF
      DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MLAST
         IF MOPT_SALES <> '**'
            IF SALESMAN <> MOPT_SALES
               SKIP
               LOOP
            ENDIF
         ENDIF
         MTOT_FRT = 0
         DO CASE
         CASE MFRT_SEL = '1'
            IF FRT_CODE1 = 'NONE' .OR. FRT_CODE1 = 'DELV' .OR. FRT_CODE1 = SPACE(4)
               SKIP 
               LOOP
            ENDIF
            SELECT D
            SEEK A->FRT_CODE1
            IF .NOT. EOF()
               STORE NAME TO MNAME
               STORE CITY TO MCITY
               STORE STATE TO MSTATE
               STORE '(' + AREA_CODE+ + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4) TO MPHONE
            ELSE
               STORE 'NOT ON FILE' TO MNAME
               STORE SPACE(2) TO MCITY, MSTATE, MADDR, MZIP, MPHONE
            ENDIF
            MTOT_FRT = (A->FRT_AMT1 + A->FRT1_ADJ1 + A->FRT1_ADJ2)
            
         CASE MFRT_SEL = '2'
            IF A->FRT2_FLG = ' ' .OR. A->FRT2_FLG = 'N'
               SKIP
               LOOP
            ENDIF
            SELECT F
            DO FOX_USE WITH "FRT_2ND INDEX FRT2_PO", .F.
            SEEK A->SALESMAN + A->PO_NBR+A->PO_SUFFIX
            MTOT_FRT = FRT_AMT2
            SELECT D
            SEEK F->FRT_CODE2
            IF .NOT. EOF()
               STORE NAME TO MNAME
               STORE CITY TO MCITY
               STORE STATE TO MSTATE
               STORE '(' + AREA_CODE+ + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4) TO MPHONE
            ELSE
               STORE 'NOT ON FILE' TO MNAME
               STORE SPACE(2) TO MCITY, MSTATE, MADDR, MZIP, MPHONE
            ENDIF
         OTHERWISE
            IF A->FRT3_FLG = ' ' .OR. A->FRT3_FLG = 'N'
               SKIP
               LOOP
            ENDIF
            SELECT F
            DO FOX_USE WITH "FRT_3RD INDEX FRT3_PO", .F.
            SEEK A->SALESMAN + A->PO_NBR+A->PO_SUFFIX
            MTOT_FRT = FRT_AMT3
            SELECT D
            SEEK F->FRT_CODE3
            IF .NOT. EOF()
               STORE NAME TO MNAME
               STORE CITY TO MCITY
               STORE STATE TO MSTATE
               STORE '(' + AREA_CODE+ + ')' + SUBSTR(PHONE,1,3) + '-' + SUBSTR(PHONE,4) TO MPHONE
            ELSE
               STORE 'NOT ON FILE' TO MNAME
               STORE SPACE(2) TO MCITY, MSTATE, MADDR, MZIP, MPHONE
            ENDIF
         ENDCASE
         
         SELECT E
         SEEK A->SUP_CODE
         IF .NOT. EOF()
            STORE CITY TO MREGION
            STORE STATE TO MREG_STATE
         ELSE
            STORE 'UNKNOWN ORIGIN' TO MREGION
            STORE SPACE(2) TO MREG_STATE
         ENDIF
         
         SELECT C 
         DO FILELOCK
         APPEND BLANK
         REPLACE NAME WITH MNAME
         REPLACE CITY WITH MCITY
         REPLACE STATE WITH MSTATE
         REPLACE PHONE WITH MPHONE
         REPLACE TOT_SW WITH MTOT_FRT 
         REPLACE TRAN_DATE WITH A->SHIP_DATE
         REPLACE REGION WITH MREGION
         REPLACE REG_STATE WITH MREG_STATE
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
            @ MLINE,11 SAY 'FREIGHT CARRIER ACTIVITY BETWEEN ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
            IF MDISP_PRT = 'P'
               @ MLINE,01 SAY REPLICATE('_',77)
            ENDIF
            MLINE = MLINE + 2
            @ MLINE,01 SAY 'FREIGHT CARRIER' 
            @ mline,40 say 'FREIGHT AMT   ORIGINATION'        
            
            MLINE = MLINE + 2
         ENDIF
         @ MLINE,01 SAY NAME    
         @ MLINE,44 SAY TOT_SW PICTURE '999,999'
         @ MLINE,54 SAY TRIM(REGION) + ', ' + REG_STATE
         @ MLINE,85 SAY TRAN_DATE
         MLINE = MLINE + 1
         @ MLINE,5 SAY TRIM(CITY) + ', ' + STATE + '  ' + PHONE
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
      
   CASE VAL(MSEL_RPT3) = 8
      DO CASHFLOW                      
      CLOSE DATA
      
   *CASE VAL(MSEL_RPT3) = 9
   *   DO MARG_RPT                      
   *   CLOSE DATA
      
   ENDCASE
   
ENDDO
CLOSE DATA
SET PROC TO
RETURN


* EOF: REPORTS3.PRG



*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 3:49 PM.
