**********
* Program.: CUS_INV.PRG
* Author..: GRACE KELLER
* Date....: 11/04/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: CUSTOMER INVOICE MENU   
*
* ---PROCESSING LOOP
STORE 0 TO MACTION
STORE ' ' TO MSELECTION

DO WHILE MSELECTION <> '9'
   SET PROC TO PO_PROC
   CLOSE DATA
   CLEAR
   @ 1,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 02,00 SAY MPROGRAM + ' - CUSTOMER INVOICE MENU'
   @ 03,00 TO 24,79 
   
   @ 05,09 SAY '1 - PRINT ALL INVOICES SCHEDULED FOR PRINT'
   @ 07,09 SAY '2 - REPRINT INVOICE (Use this option if you have made corrections)'
   @ 08,09 SAY '       since the last time an invoice was printed)'
   @ 10,09 SAY '3 - PRINT COPY OF ORIGINAL INVOICE (Only use if NO CHANGES made)' 
   @ 11,09 say '       since the last time an invoice was printed)'
   @ 13,09 SAY '4 - DAILY SALESPERSON/CUSTOMER CREDIT REPORT'
   IF MCOMPANY = 'DIVISION 15'
      @ 15,09 say '5 - CREATE REPRINT INVOICE COPY FOR TRANSMISSION TO LA OFFICE'
   ENDIF
   *  @ 17,09 SAY '5 - ENTER MANUAL INVOICE (DEBIT OR CREDIT)'
   @ 20,09 SAY '9 - EXIT TO MAIN MENU'
   
   STORE '1' TO MSELECTION
   @ 22,01 SAY 'CHOICE: '
   @ 22,09 get mselection picture '9'
   READ
   **CLEAR GETS
   **@ 22,08 SAY ' '
   **MSELECTION = INKEY(60)
   **IF MSELECTION = 0
   **   SET COLOR TO W/N
   **   CLEAR
   **   SET COLOR TO W+/B+,W+/R+
   **   MSELECTION = INKEY(0)
   **   MSELECTION = '0'
   **ELSE
   **   DO CASE
   **   CASE MSELECTION < 0
   **      IF MSELECTION = -4
   **         SET PROC TO BUY_PROC
   **         DO CUSTINQ      
   **         SET PROC TO PO_PROC     
   **      ELSE              
   **      ENDIF
   **      MSELECTION = '0'
   **   OTHERWISE
   **      IF MSELECTION = 13
   **         MSELECTION = '1'
   **      ELSE
   **         MSELECTION = CHR(MSELECTION)
   **      ENDIF
   **   ENDCASE
   **ENDIF
   
   
   DO CASE
      
   CASE MSELECTION = '1'
      DO INV_PRT
      
   CASE MSELECTION = '2'
      MPRT_COPY = .T.
      DO REPRINT
   CASE MSELECTION = '3'
      DO COPY_PRT
   CASE MSELECTION = '4'
      CLEAR
      @ 1,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 02,00 SAY MPROGRAM + ' - DAILY SALESPERSON CUSTOMER CREDIT REPORT'
      @ 03,00 TO 22,79 
      STORE '**' TO MCODE
      STORE 1 TO MTIMES
      STORE 'N' TO MYES_NO  
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 06,5 SAY ' SALESPERSON CODE: '
         @ 06,24 GET MCODE               
         @ 07,5 SAY " (ENTER '**' IF REPORT DESIRED FOR ALL SALESPERSONS)"
         **@ 09,5 SAY 'NUMBER OF REPORTS: '
         **@ 9,24 GET MTIMES PICTURE '#'
         **@ 11,5 SAY 'PRINT ALL ORDERS (Y/N)? '
         **@ 11,28 GET MYES_NO PICTURE '@!'
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
      *** HERE, I HAVE TO CALCULATE CURRENT BALANCES FOR THOSE 
      *** CUSTOMERS WITH MORE THAN ONE SALESPERSON
      SELECT A
      DO FOX_USE WITH "CUS_INV INDEX CUS_DATE", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      DO WHILE .NOT. EOF()
         IF S1_CODE = '  '
            SKIP
            LOOP
         ENDIF
         MS1_CODE = S1_CODE
         MS2_CODE = S2_CODE
         MS3_CODE = S3_CODE
         STORE 0 TO MS1_BAL, MS2_BAL, MS3_BAL
         MBBUYCODE = BBUYCODE
         SELECT A
         SEEK ' ' + MBBUYCODE
         MOVERDUE = 0             
         MBALANCE = 0
         
         DO WHILE .NOT. EOF() .AND. PAID_FLG = ' ' .AND. BBUYCODE = MBBUYCODE
            STORE TOT_SELL + CUS_PALL TO MAMT
            MSTILL_DUE = MAMT - AMT_PAID
            
            IF MSTILL_DUE > 0 
               IF SALESMAN = '  '
                  MSALESMAN = '02'
               ELSE
                  MSALESMAN = SALESMAN
               ENDIF
               
               DO CASE
               CASE MSALESMAN = MS1_CODE
                  MS1_BAL = MS1_BAL + MSTILL_DUE
               CASE MSALESMAN = MS2_CODE
                  MS2_BAL = MS2_BAL + MSTILL_DUE
               CASE MSALESMAN = MS3_CODE
                  MS3_BAL = MS3_BAL + MSTILL_DUE
               ENDCASE
            ENDIF
            SKIP
         ENDDO
         
         SELECT C 
         IF .NOT. EOF()
            DO RECLOCK
            REPLACE S1_BAL  WITH MS1_BAL  
            REPLACE S2_BAL  WITH MS2_BAL
            REPLACE S3_BAL  WITH MS3_BAL
            UNLOCK
         ENDIF
         SKIP
         
      ENDDO
      
      CLOSE DATA
      
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      
      MPAGE_NO = 0
      MLINE = 99 
      MPAGE_LEN = 58
      SELECT A
      DO FOX_USE WITH "CUS_INV INDEX CUS_INV", .F.
      
      SELECT D
      USE TEMPAGE1 EXCLUSIVE
      DELETE ALL
      PACK
      INDEX ON SALESMAN + NAME  + BBUYCODE + SUBSTR(DTOC(SHIP_DATE),7) + SUBSTR(DTOC(SHIP_DATE),1,5) TO TEMPAGE1
      INDEX ON BBUYCODE + SALESMAN TO TEMPAGE2
      USE      
      DO FOX_USE WITH "TEMPAGE1 INDEX TEMPAGE2, TEMPAGE1", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      
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
      
      *** THIS REPORT IS A DAILY REPORT OF CUSTOMERS OVER THE
      *** CREDIT LIMIT
      
      DO WHILE .NOT. EOF()
         IF CUS_BAL = 0
            SKIP
            LOOP
         ENDIF
         IF ACTIVE = 'I'
            SKIP
            LOOP
         ENDIF
         MBBUYCODE = BBUYCODE
         MNAME     = NAME
         MCUS_BAL = CUS_BAL 
         MS1_LIM = S1_LIM
         MS1_CODE = S1_CODE
         MS1_BAL  = S1_BAL
         MS2_LIM  = S2_LIM
         MS2_CODE = S2_CODE
         MS2_BAL  = S2_BAL
         MS3_LIM  = S3_LIM
         MS3_CODE = S3_CODE
         MS3_BAL  = S3_BAL
         
         SELECT A
         SEEK MBBUYCODE + ' '
         
         DO WHILE .NOT. EOF() .AND. MBBUYCODE = BBUYCODE .AND. PAID_FLG = ' '
            IF DEB_CRD <> ' ' .OR. CRED_PAY <> ' ' .OR. AMT_PAID <> 0
               SKIP 
               LOOP
            ENDIF
            IF SALESMAN = '  '
               MSALESMAN = '02'
            ELSE
               MSALESMAN = SALESMAN
            ENDIF
            
            SELECT D
            SEEK MBBUYCODE + A->SALESMAN
            DO CASE
            CASE (C->S1_BAL <> 0 .OR. C->S2_BAL <> 0 .OR. C->S3_BAL <> 0) .AND. (MSALESMAN = MS1_CODE .OR. MSALESMAN = MS2_CODE .OR. MSALESMAN = MS3_CODE)
               **** DO THIS FROM A SALESMAN POINT OF VIEW
               DO CASE
                  ****   CHECK FOR MATCH ON SALESPERSON 1
               CASE MSALESMAN = MS1_CODE
                  IF C->S1_BAL < C->S1_LIM  
                     IF EOF()
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE BBUYCODE WITH MBBUYCODE
                        REPLACE SALESMAN WITH A->SALESMAN
                        REPLACE NAME WITH MNAME   
                        UNLOCK
                     ENDIF
                  ELSE
                     IF EOF()
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE BBUYCODE WITH MBBUYCODE
                        REPLACE SALESMAN WITH A->SALESMAN
                        REPLACE NAME WITH MNAME
                        UNLOCK
                        IF MS1_BAL > C->S1_LIM   
                           DO RECLOCK
                           REPLACE PO_NBR   WITH A->PO_NBR
                           REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                           REPLACE SHIP_DATE WITH A->SHIP_DATE
                           REPLACE TOT_SELL  WITH A->TOT_SELL+A->CUS_PALL
                           UNLOCK
                           MS1_BAL = MS1_BAL - TOT_SELL  
                        ENDIF
                     ELSE
                        IF MS1_BAL > C->S1_LIM  
                           DO FILELOCK
                           APPEND BLANK
                           REPLACE BBUYCODE WITH MBBUYCODE
                           REPLACE NAME     WITH MNAME
                           REPLACE SALESMAN WITH A->SALESMAN
                           REPLACE PO_NBR   WITH A->PO_NBR
                           REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                           REPLACE SHIP_DATE WITH A->SHIP_DATE
                           REPLACE TOT_SELL  WITH A->TOT_SELL+A->CUS_PALL
                           UNLOCK
                           MS1_BAL = MS1_BAL - TOT_SELL  
                        ENDIF
                     ENDIF
                  ENDIF
                  
                  **** CHECK FOR MATCH ON SALESPERSON 2      
               CASE MSALESMAN = MS2_CODE
                  IF C->S2_BAL < C->S2_LIM
                     IF EOF()
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE BBUYCODE WITH MBBUYCODE
                        REPLACE SALESMAN WITH A->SALESMAN
                        REPLACE NAME WITH MNAME   
                        UNLOCK
                     ENDIF
                  ELSE
                     IF EOF()
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE BBUYCODE WITH MBBUYCODE
                        REPLACE SALESMAN WITH A->SALESMAN
                        REPLACE NAME WITH MNAME
                        UNLOCK
                        IF MS2_BAL > C->S2_LIM  
                           DO RECLOCK
                           REPLACE PO_NBR   WITH A->PO_NBR
                           REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                           REPLACE SHIP_DATE WITH A->SHIP_DATE
                           REPLACE TOT_SELL  WITH A->TOT_SELL+A->CUS_PALL
                           UNLOCK
                           MS2_BAL = MS2_BAL - TOT_SELL  
                        ENDIF
                     ELSE
                        IF MS2_BAL > C->S2_LIM   
                           DO FILELOCK
                           APPEND BLANK
                           REPLACE BBUYCODE WITH MBBUYCODE
                           REPLACE NAME     WITH MNAME
                           REPLACE SALESMAN WITH A->SALESMAN
                           REPLACE PO_NBR   WITH A->PO_NBR
                           REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                           REPLACE SHIP_DATE WITH A->SHIP_DATE
                           REPLACE TOT_SELL  WITH A->TOT_SELL+A->CUS_PALL
                           UNLOCK
                           MS2_BAL = MS2_BAL - TOT_SELL  
                        ENDIF
                     ENDIF
                  ENDIF
                  
               OTHERWISE
                  
                  **** CHECK FOR MATCH ON SALESPERSON 3      
               CASE MSALESMAN = MS3_CODE
                  IF C->S3_BAL < C->S3_BAL  
                     IF EOF()
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE BBUYCODE WITH MBBUYCODE
                        REPLACE SALESMAN WITH A->SALESMAN
                        REPLACE NAME WITH MNAME   
                        UNLOCK
                     ENDIF
                  ELSE
                     IF EOF()
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE BBUYCODE WITH MBBUYCODE
                        REPLACE SALESMAN WITH A->SALESMAN
                        REPLACE NAME WITH MNAME
                        UNLOCK
                        IF MS3_BAL > C->S3_LIM
                           DO RECLOCK
                           REPLACE PO_NBR   WITH A->PO_NBR
                           REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                           REPLACE SHIP_DATE WITH A->SHIP_DATE
                           REPLACE TOT_SELL  WITH A->TOT_SELL+A->CUS_PALL
                           UNLOCK
                           MS3_BAL = MS3_BAL - TOT_SELL  
                        ENDIF
                     ELSE
                        IF MS3_BAL > C->S3_LIM  
                           DO FILELOCK
                           APPEND BLANK
                           REPLACE BBUYCODE WITH MBBUYCODE
                           REPLACE NAME     WITH MNAME
                           REPLACE SALESMAN WITH A->SALESMAN
                           REPLACE PO_NBR   WITH A->PO_NBR
                           REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                           REPLACE SHIP_DATE WITH A->SHIP_DATE
                           REPLACE TOT_SELL  WITH A->TOT_SELL+A->CUS_PALL
                           UNLOCK
                           MS3_BAL = MS3_BAL - TOT_SELL  
                        ENDIF
                     ENDIF
                  ENDIF
               ENDCASE
               
            OTHERWISE
               *** DO THIS FROM A TOTAL COMPANY POINT OF VIEW
               IF C->CUS_BAL < C->CRED_LIM
                  IF EOF()
                     DO FILELOCK
                     APPEND BLANK
                     REPLACE BBUYCODE WITH MBBUYCODE
                     REPLACE SALESMAN WITH A->SALESMAN
                     REPLACE NAME WITH MNAME   
                     UNLOCK
                  ENDIF
               ELSE
                  IF EOF()
                     DO FILELOCK
                     APPEND BLANK
                     REPLACE BBUYCODE WITH MBBUYCODE
                     REPLACE SALESMAN WITH A->SALESMAN
                     REPLACE NAME WITH MNAME
                     UNLOCK
                     IF MCUS_BAL > C->CRED_LIM
                        DO RECLOCK
                        REPLACE PO_NBR   WITH A->PO_NBR
                        REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                        REPLACE SHIP_DATE WITH A->SHIP_DATE
                        REPLACE TOT_SELL  WITH A->TOT_SELL+A->CUS_PALL
                        UNLOCK
                        MCUS_BAL = MCUS_BAL - TOT_SELL  
                     ENDIF
                  ELSE
                     IF MCUS_BAL > C->CRED_LIM
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE BBUYCODE WITH MBBUYCODE
                        REPLACE NAME     WITH MNAME
                        REPLACE SALESMAN WITH A->SALESMAN
                        REPLACE PO_NBR   WITH A->PO_NBR
                        REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                        REPLACE SHIP_DATE WITH A->SHIP_DATE
                        REPLACE TOT_SELL  WITH A->TOT_SELL+A->CUS_PALL
                        UNLOCK
                        MCUS_BAL = MCUS_BAL - TOT_SELL  
                     ENDIF
                  ENDIF
               ENDIF
            ENDCASE
            SELECT A
            SKIP
         ENDDO
         SELECT C
         SKIP
      ENDDO
      
      ** ALL THRU THE SELECTION PROCESS
      SELECT B
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT D
      DO FOX_USE WITH "TEMPAGE1 INDEX TEMPAGE1", .F.
      
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
         MSAL_NAME = NAME
         SELECT D
         IF MSALESMAN = '  '
            MSAL_NAME = 'KEN OCHS'
         ENDIF
         MPAGE_NO = 0
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  EJECT
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 1,25 SAY MCOMPANY
               @ 1,1 SAY 'PAGE'
               @ 1,06 say mpage_no picture '99'
               @ 1,61  SAY DTOC(DATE())
               @ 2,19 SAY 'CUSTOMER ACCOUNTS / CREDIT LIMITS'
               @ 3,19 SAY 'SALESPERSON: ' + MSAL_NAME
               @ 5,1 SAY '                                                                AVG PAYMENT DAYS'
               @ 6,1 SAY 'ACCOUNT                                 LIMIT        BALANCE     25 DAYS   6 MO.'
               @ 6,0 SAY REPLICATE ('_',96)
               MLINE = 8
            ENDIF
            MNAME = NAME + BBUYCODE
            @ MLINE,1 SAY NAME 
            SELECT C
            SEEK D->BBUYCODE
            IF .NOT. EOF()       
               IF MSALESMAN = '  '
                  MSALEP = '02'
               ELSE
                  MSALEP = MSALESMAN
               ENDIF
               IF (C->S1_BAL <> 0 .OR. C->S2_BAL <> 0 .OR. C->S3_BAL <> 0) .AND. (MSALEP = S1_CODE .OR. MSALEP = S2_CODE .OR. MSALEP = S3_CODE)
                  DO CASE
                  CASE MSALEP = S1_CODE
                     @ MLINE,37 SAY S1_LIM PICTURE '9,999,999'
                     @ MLINE,52 SAY ROUND(S1_BAL,0)  PICTURE '9,999,999'
                  CASE MSALEP = S2_CODE
                     @ MLINE,37 SAY S2_LIM PICTURE '9,999,999'
                     @ MLINE,52 SAY ROUND(S2_BAL,0)  PICTURE '9,999,999'
                  CASE MSALEP = S3_CODE
                     @ MLINE,37 SAY S3_LIM PICTURE '9,999,999'
                     @ MLINE,52 SAY ROUND(S3_BAL,0)  PICTURE '9,999,999'
                  ENDCASE
               ELSE
                  @ MLINE,37 SAY CRED_LIM PICTURE '9,999,999'
                  @ MLINE,52 SAY ROUND(CUS_BAL,0)  PICTURE '9,999,999'
               ENDIF
               IF SHIPS_25 <> 0 .AND. DAYS_25 <> 0
                  MAVG_25 = ROUND(DAYS_25/SHIPS_25,1)
               ELSE
                  MAVG_25 = 0
               ENDIF
               
               IF SHIPS_180 <> 0 .AND. DAYS_180 <> 0
                  MAVG_180 = ROUND(DAYS_180/SHIPS_180,1)
               ELSE
                  MAVG_180 = 0
               ENDIF
               @ MLINE,67 SAY MAVG_25 PICTURE '999.9' 
               @ MLINE,75 SAY MAVG_180 PICTURE '999.9'
            ENDIF
            MFIRST_TM = .T.
            SELECT D
            DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. NAME+BBUYCODE = MNAME
               IF PO_NBR <> SPACE(4)
                  IF MFIRST_TM
                     MLEN = LEN(TRIM(D->NAME))
                     @ MLINE,1 SAY REPLICATE('_',MLEN)
                     @ MLINE,37 SAY REPLICATE('_',9)
                     @ MLINE,52 SAY REPLICATE('_',9)
                     MFIRST_TM = .F.
                  ENDIF
                  MLINE = MLINE + 1
                  @ MLINE,10 SAY 'PO #: '   
                  IF SALESMAN <> '  '
                     @ MLINE,16 SAY SALESMAN + '-' + PO_NBR
                     IF PO_SUFFIX <> ' '
                        @ MLINE,23 SAY '-' + PO_SUFFIX
                     ENDIF
                  ELSE
                     @ MLINE,16 SAY PO_NBR
                     IF PO_SUFFIX <> ' '
                        @ MLINE,20 SAY '-' + PO_SUFFIX
                     ENDIF
                  ENDIF
                  @ MLINE,29 SAY 'SHIPPED: ' + DTOC(SHIP_DATE)
                  @ MLINE,58 SAY '    DAYS: '   
                  @ MLINE,68 SAY DATE()-SHIP_DATE PICTURE '9999'
                  @ MLINE,77 SAY '    DUE: ' + TRANSFORM(TOT_SELL, '999,999.99')
               ENDIF
               SKIP
            ENDDO
            MLINE = MLINE + 2
         ENDDO
         IF MLINE <> 99
            MLINE = 88
         ENDIF
      ENDDO    
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
      
   CASE MSELECTION = '5'
      MPRT_COPY = .F.
      DO REPRINT 
      
   ENDCASE
   
ENDDO
CLOSE DATA
MSELECTION = ' '
RETURN

* EOF: CUS_INV.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/8/15 at 1:58 PM.
