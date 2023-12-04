**********
* Program.: REPORTS.PRG
* Author..: GRACE KELLER
* Date....: 10/04/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: POULTRY REPORTS MENU
*

*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
STORE 0 TO MACTION
STORE ' ' TO MRPT_SEL
DO WHILE MRPT_SEL <> '9'
   CLOSE DATA
   CLEAR
   @ 1,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 02,00 SAY MPROGRAM + ' - REPORTS MENU I'
   @ 03,00 TO 25,79 
   
   @ 04,09 SAY '1 - MASTER FILE LISTINGS                  S - SPECIAL REPORTS' 
   @ 06,09 SAY '2 - SALES REPORTS'
   @ 08,09 SAY '3 - CUSTOMER / RECEIPTS / CREDIT CHECK REPORTS'
   @ 10,09 SAY '4 - PRODUCT/PURCHASE/SELLING TOTAL REPORTS (SUPPLIER/CUSTOMER)'
   @ 12,09 SAY '5 - ORDERS NEEDING SHORTWEIGHTS (BY SALESPERSON)'
   @ 14,09 SAY '6 - MIDWEST DISBURSEMENT REPORTS'
   @ 16,09 SAY '7 - SUPPLIER / FREIGHT / CUSTOMER OUTSTANDING BALANCES'
   @ 18,09 SAY '8 - CUSTOMER / SUPPLIER / FREIGHT PAYMENT INFO'
   @ 21,09 SAY '9 - EXIT TO MAIN MENU'
   
   STORE '1' TO MRPT_SEL
   @ 23,01 SAY 'CHOICE: '
   @ 23,24 say "('X' TO PAGE TO REPORTS MENU II)"
   @ 23,09 GET MRPT_SEL PICTURE '@!'
   READ
   
   DO CASE
   CASE MRPT_SEL = 'X'
      DO REPORTS2
      
   CASE MRPT_SEL = 'S'
      DO SPECRPTS
      
   CASE MRPT_SEL = '1'
      DO MASTLIST   
   CASE MRPT_SEL = '2'
      DO SALESRPT
   CASE MRPT_SEL = '3'
      DO PAYRPTS
   CASE MRPT_SEL = '4'
      DO PRODRPTS
   CASE MRPT_SEL = '5'
      * Notes...: DAILY SHORT WEIGHTS NEEDED REPORT FOR SALESPERSONS
      *
      
      MTITLE = ' - OUTSTANDING SHORTWEIGHTS REPORT (BY SALESPERSON)'      
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      **** GET DATE FOR THIS REPORT
      STORE DATE() TO MDATE
      STORE 'P' TO MDISP_PRT
      STORE 'N' TO MYES_NO     
      MOPT_SALES = '**'
      MINDEX = 'N'
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         **@ 10,6 SAY 'DISPLAY OR PRINT REPORT (D/P):'
         **@ 10,38 GET MDISP_PRT PICTURE '@!'
         @ 08,6 SAY 'Have you entered any shortweights since last daily backup (Y/N)? ' get mindex picture '@!'
         @ 10,6 SAY "(Note: If 'Y' is answered above, the file will be reindexed)."
         
         @ 13, 6 SAY '(Optional) Salesperson Code: ' GET MOPT_SALES PICTURE '@!'
         @ 14, 6 SAY "('**' for all salespersons)"
         **@ 12,1 SAY 'DO YOU ALSO WANT THE ORDERS INCLUDED FOR'
         **@ 13,1 SAY "WHICH THE CENTRAL OFFICE CALLS FOR S/W'S (Y/N)? " GET MYES_NO PICTURE '@!'
         
         
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
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
      SELECT C
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      
      SELECT B
      IF MINDEX = 'Y'
         DO FOX_USE WITH "PO_HEAD", .F.
         INDEX ON SHORT_FLG + SALESMAN + STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2) TO PO_TEMP
         USE
      ENDIF
      DO FOX_USE WITH "PO_HEAD INDEX PO_TEMP", .F.
      @ 19,16 SAY 'PROCESSING........'
      SEEK ' '
      IF EOF()
         @ 05,01 CLEAR TO 22,78
         STORE ' ' TO MWAIT
         @ 10,05 SAY 'THERE ARE NO PURCHASE ORDERS NEEDING SHORTWEIGHTS'
         @ 12,05 SAY 'PRESS ENTER KEY TO CONTINUE ' GET MWAIT
         READ
         RETURN
      ENDIF
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
      
      DO WHILE .NOT. EOF() .AND. SHORT_FLG = ' '
         IF DEL_REQD > DATE() 
            SKIP
            LOOP
         ENDIF
         IF MOPT_SALES <> '**'
            IF SALESMAN <> MOPT_SALES
               SKIP
               LOOP
            ENDIF
         ENDIF
         STORE SALESMAN TO MSALESMAN
         IF MSALESMAN <> SPACE(2)
            SELECT C
            
            SEEK MSALESMAN   
            IF .NOT. EOF()
               STORE SUBSTR(NAME,1,20) TO MNAME
            ELSE
               STORE 'NOT ON FILE        ' TO MNAME
            ENDIF
         ELSE
            STORE BROK_NAME + SPACE(13) TO MNAME
         ENDIF
         SELECT B
         DO WHILE .NOT. EOF() .AND. SHORT_FLG = ' ' .AND. SALESMAN = MSALESMAN
            IF DEL_REQD > DATE() 
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
               @ 1,34 SAY MCOMPANY
               @ 2,0 SAY 'PAGE'
               @ 2,05 say mpage_no picture '99'
               @ 2,22 SAY 'PURCHASE ORDERS NEEDING SHORTWEIGHTS'
               @ 2,70 SAY DTOC(DATE())
               @ 3,34 SAY MNAME
               @ 5,2 SAY 'SHIP DATE'   
               @ 5,13 SAY 'PO NUMBER'       
               @ 5,25 SAY 'INV NBR'
               @ 5,35 SAY 'CUSTOMER'    
               @ 5,60 SAY 'DELIV DATE'
               IF MDISP_PRT = 'P'
                  @ 5,75 SAY 'S/W CUST'
                  @ 5,86 SAY 'S/W SUPPLIER'
                  @ 5,0 SAY REPLICATE ('_',98)
               ELSE
                  @ 6,0 SAY REPLICATE ('-',80)
               ENDIF
               MLINE = 7
            ENDIF
            SELECT A
            SEEK B->BBUYCODE
            IF .NOT. EOF()
               IF MSALESMAN <> '  '
                  IF MYES_NO = 'N' .AND. NO_SHRTRPT = 'Y'
                     SELECT B
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               STORE NAME TO MBBUYNAME
            ELSE 
               STORE 'BILL TO NOT ON FILE' TO MBBUYNAME
            ENDIF
            
            SELECT B
            @ MLINE,2 SAY SHIP_DATE
            @ MLINE,13 SAY SALESMAN  
            IF SALESMAN <> '  '
               @ MLINE,15 SAY '-'
            ENDIF
            @ MLINE,16 SAY PO_NBR
            IF PO_SUFFIX <> ' '
               @ MLINE,20 SAY '-' + PO_SUFFIX
            ENDIF
            @ MLINE,25 SAY SALESMAN
            IF SALESMAN <> SPACE(2)
               @ MLINE,27 SAY '-'
            ENDIF
            @ MLINE,28 SAY INV_NBR    
            @ MLINE,35 SAY SUBSTR(MBBUYNAME,1,20)
            @ MLINE,61 SAY DEL_REQD
            IF MDISP_PRT = 'P'
               @ MLINE,84 SAY '|'
               MLINE = MLINE + 1
               @ MLINE,84 SAY '|'
               MLINE = MLINE + 1
            ELSE
               MLINE = MLINE + 2 
            ENDIF
            
            SKIP
         ENDDO
         IF MDISP_PRT = 'P'
            MLINE = MLINE + 2
            @ MLINE,2 SAY 'SHORT WEIGHT MUST BE SAME ON BOTH CUSTOMER & SUPPLIER.  IF NOT, YOU MUST NOTE'
            @ MLINE+1,2 SAY 'WHY THE DIFFERENCE AND THE PLANT & SALESPERSON WHO APPROVED THE SHORT WEIGHT.'
         ENDIF
         MLINE = 80
         MPAGE_NO = 0
      ENDDO
      IF MDISP_PRT = 'P'
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
      
      CLOSE DATA
   CASE MRPT_SEL = '6'
      DO DISBRPT
   CASE MRPT_SEL = '7'
      STORE ' ' TO MFRT_SEL, MSUP_SEL, MCUS_SEL
      MTITLE = ' - SUPPLIER / FREIGHT / CUSTOMER OUTSTANDING BALANCES'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 22,79
      @ 7,5 SAY "SELECT WITH AN 'X' OF THE FOLLOWING CATEGORIES:"
      @ 10,5 SAY '       SUPPLIER: '
      @ 12,5 SAY 'FREIGHT CARRIER: '
      @ 14,5 SAY '       CUSTOMER: '
      STORE 2 TO MACTION 
      DO WHILE MACTION = 2
         @ 10,22 GET MSUP_SEL PICTURE '@!'
         @ 12,22 GET MFRT_SEL PICTURE '@!'
         @ 14,22 GET MCUS_SEL PICTURE '@!'
         STORE 1 TO MACTION
         @ 24,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         
      ENDDO
      IF MACTION = 3
         RETURN
      ENDIF
      
      DO CASE
      CASE MSUP_SEL = 'X'
         STORE 'N' TO MYES_NO
         @ 17,5 SAY 'PRINT LIST OF ORDERS (Y/N)? ' GET MYES_NO PICTURE '@!'
         READ
         
         * Notes...: DISPLAY TOTAL AMOUNT OWED TO SUPPLIERS
         
         MNEXT_CUST = .T.
         DO WHILE MNEXT_CUST
            MNAME_FD = .F.
            STORE SPACE(32) TO MNAME
            DO RSUPSEL3
            IF .NOT. MNAME_FD 
               MNEXT_CUST = .F.
               LOOP
            ENDIF
            STORE RSUPCODE TO MRSUPCODE
            STORE NAME TO MNAME
            STORE STREET TO MSTREET
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            SET PROC TO REC_PROC
            STORE 0 TO MTOTAL, MUNDER, MSTOP
            MTITLE = ' - DISPLAY SUPPLIER BALANCE'
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            SELECT C
            USE TEMPAGE2 EXCLUSIVE
            DELETE ALL
            PACK
            INDEX ON STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,5) TO TEMPAGE2
            USE
            DO FOX_USE WITH "TEMPAGE2 INDEX TEMPAGE2", .F.
            
            SELECT A
            DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
            SELECT B
            DO FOX_USE WITH "PO_HEAD INDEX PO_SUP, PO_HEAD", .F.
            SEEK MRSUPCODE
            IF EOF()
               @ 10,5 SAY 'THERE ARE NO PURCHASE ORDERS ON FILE FOR THIS SUPPLIER.'
               STORE ' ' TO MWAIT
               @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
               READ
               RETURN
            ENDIF
            *** MATCHED BUT NOT PAID
            *** GET THESE OFF THE SUPPLIER INVOICE FILE
            @ 10,10 SAY 'CALCULATING.......'
            IF MYES_NO = 'Y'
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
            *** UNMATCHED AND UNPAID
            SET ORDER TO 1
            SEEK MRSUPCODE + '  ' 
            MLINE = 99
            DO WHILE .NOT. EOF() .AND. RSUPCODE = MRSUPCODE .AND. SUP_REC = ' ' .AND. SUP_PD = ' '
               STORE TOT_PURCH + SUP_PALL + BILL_ADJ TO MX
               MTOTAL = MTOTAL + MX
               IF MYES_NO = 'Y'
                  SELECT C
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE NAME WITH MNAME
                  REPLACE STREET WITH MSTREET
                  REPLACE CITY WITH MCITY
                  REPLACE STATE WITH MSTATE
                  REPLACE RSUPCODE WITH MRSUPCODE
                  REPLACE SALESMAN WITH B->SALESMAN
                  REPLACE PO_NBR WITH B->PO_NBR
                  REPLACE PO_SUFFIX WITH B->PO_SUFFIX
                  REPLACE SHIP_DATE WITH B->SHIP_DATE
                  REPLACE INV_NBR WITH B->INV_NBR
                  REPLACE TOT_DUE WITH MX
                  UNLOCK
                  SELECT B
                  ** IF MLINE > 56 
                  **    IF MLINE <> 99
                  **       EJECT
                  **    ENDIF
                  **    MLINE = 0
                  ** ENDIF
                  ** MLINE = MLINE + 1
                  ** ? SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX + SPACE(7) + INV_NBR + SPACE(7) + TRANSFORM(MX, '999,999.99') + space(5) + dtoc(ship_date) 
               ENDIF
               SKIP
            ENDDO
            SELECT B
            SET ORDER TO 2
            SELECT A
            GOTO TOP
            DO WHILE .NOT. EOF()
               IF RSUPCODE = MRSUPCODE
                  STORE HOLD_FLG TO MHOLD_FLG
                  STORE ADDL_DUE TO MADDL_DUE
                  STORE AMT_DUE TO MAMT_DUE
                  MSHIP_DATE = DUE_DATE
                  IF DEB_CRD <> 'Y'
                     SELECT B
                     SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
                     IF .NOT. EOF()
                        STORE TOT_PURCH + SUP_PALL + BILL_ADJ TO MAMT_DUE
                        MSHIP_DATE = SHIP_DATE
                     ENDIF
                     SELECT A
                  ENDIF
                  DO CASE
                  CASE MHOLD_FLG = 'S'
                     MSTOP = MSTOP + MAMT_DUE
                  CASE MADDL_DUE = 'Y'       
                     MUNDER = MUNDER + MAMT_DUE
                  OTHERWISE
                     MTOTAL = MTOTAL + MAMT_DUE
                  ENDCASE
                  IF MYES_NO = 'Y'
                     SELECT C
                     DO FILELOCK
                     APPEND BLANK
                     REPLACE NAME WITH MNAME
                     REPLACE STREET WITH MSTREET
                     REPLACE CITY WITH MCITY
                     REPLACE STATE WITH MSTATE
                     REPLACE RSUPCODE WITH MRSUPCODE
                     REPLACE SALESMAN WITH A->SALESMAN
                     REPLACE PO_NBR WITH A->PO_NBR
                     REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                     REPLACE INV_NBR WITH A->INV_NBR
                     REPLACE SHIP_DATE WITH MSHIP_DATE
                     REPLACE TOT_DUE WITH MAMT_DUE
                     UNLOCK
                     SELECT A
                  ENDIF
               ENDIF
               SKIP
            ENDDO
            IF MYES_NO = 'Y'
               SELECT C
               GOTO TOP
               ? MNAME
               ? MSTREET
               ? TRIM(MCITY) + ', ' + MSTATE
               DO WHILE .NOT. EOF()
                  IF MLINE > 56 
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                     MLINE = 0
                  ENDIF
                  MLINE = MLINE + 1
                  ? SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX + SPACE(7) + INV_NBR + SPACE(7) + TRANSFORM(TOT_DUE, '999,999.99') + space(5) + dtoc(ship_date) 
                  SKIP
               ENDDO
               
               MTOT = MTOTAL + MUNDER + MSTOP
               IF MTOT <> 0
                  ?
                  ? SPACE(03) + '   AMOUNT OWED        UNDERBILL AMT     STOP PAYMENT    TOTAL AMOUNT OWED'
                  ? SPACE(03) + TRANSFORM(MTOTAL, '9,999,999.99') + SPACE(6) + TRANSFORM(MUNDER, '9,999,999.99') + SPACE(9) + TRANSFORM(MSTOP, '9,999,999.99') + SPACE(5) + TRANSFORM(MTOT, '9,999,999.99')
                  ?
                  EJECT
               ENDIF
               SET DEVICE TO SCREEN
               SET PRINT OFF
               SET PRINT TO
               SET CONSOLE ON
               IF MPRINTER3 <> 'DONOTPRINT'
                  RUN &MPRINTIT3
               ENDIF
               
            ENDIF
            
            @ 10,10 SAY SPACE(40)
            @ 06,10 SAY MNAME
            @ 07,10 SAY MSTREET
            @ 08,10 SAY TRIM(MCITY) + ', ' + MSTATE
            MTOT = MTOTAL + MUNDER
            @ 12,04 SAY  '   AMOUNT OWED     UNDERBILL AMT     STOP PAYMENT    TOTAL AMOUNT OWED'
            @ 13,06 SAY MTOTAL PICTURE '9,999,999.99'
            @ 13,21 SAY MUNDER PICTURE '9,999,999.99'
            @ 13,41 SAY MSTOP PICTURE '9,999,999.99'
            @ 13,61 SAY MTOTAL + MUNDER + MSTOP PICTURE '9,999,999.99'
            @ 23,1 SAY 'Press any key when ready to continue...'
            wait ' '
            @ 06,1 CLEAR TO 21,78
            @ 23,0
            STORE 'N' TO MAGAIN 
            @ 10,05 SAY 'Do You Want to Select Another Supplier (Y/N)? ' get mAGAIN  picture '@!'
            READ
            IF MAGAIN <> 'Y'
               MNEXT_CUST = .F.
            ENDIF
         ENDDO
         CLOSE DATA
      CASE MFRT_SEL = 'X'
         STORE 'N' TO MYES_NO
         @ 17,5 SAY 'PRINT LIST OF ORDERS (Y/N)? ' GET MYES_NO PICTURE '@!'
         READ
         * Notes...: DISPLAY TOTAL AMOUNT OWED TO FREIGHT CARRIERS
         MNEXT_FRT = .T.
         DO WHILE MNEXT_FRT
            MNAME_FD = .F.
            STORE SPACE(32) TO MNAME
            DO FRT_SEL1
            IF .NOT. MNAME_FD 
               MNEXT_FRT = .F.
               LOOP
            ENDIF
            STORE FRT_CODE TO MFRT_CODE
            STORE NAME TO MNAME
            STORE STREET TO MSTREET
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            MTOTAL = 0
            MTITLE = ' - DISPLAY FREIGHT CARRIER BALANCE'
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            SELECT B
            DO FOX_USE WITH "PO_HEAD INDEX PO_FRT", .F.
            SEEK MFRT_CODE
            IF EOF()
               @ 10,5 SAY 'THERE ARE NO PURCHASE ORDERS ON FILE FOR THIS FREIGHT CARRIER.'
               STORE ' ' TO MWAIT
               @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
               READ
               RETURN
            ENDIF
            
            *** MATCHED BUT NOT PAID
            SEEK MFRT_CODE + 'Y ' 
            MTOTAL = 0
            @ 10,10 SAY 'CALCULATING.......'
            IF MYES_NO = 'Y'
               
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
               
               ? MNAME
               ? MSTREET
               ? TRIM(MCITY) + ', ' + MSTATE
            ENDIF
            MLINE = 99
            DO WHILE .NOT. EOF() .AND. FRT_CODE1 = MFRT_CODE .AND. FRT_REC = 'Y' .AND. FRT_PD = ' '
               MX = FRT_AMT1 + FRT_PALL + FRT1_ADJ1 + FRT1_ADJ2
               MTOTAL = MTOTAL + MX
               IF MYES_NO = 'Y'
                  IF MLINE > 56 
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                     MLINE = 0
                  ENDIF
                  MLINE = MLINE + 1
                  ? SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX + SPACE(7) + INV_NBR + SPACE(7) + TRANSFORM(MX, '999,999.99') + space(5) + dtoc(ship_date) 
               ENDIF
               SKIP
            ENDDO
            *** UNMATCHED AND UNPAID
            SEEK MFRT_CODE + '  ' 
            DO WHILE .NOT. EOF() .AND. FRT_CODE1 = MFRT_CODE .AND. FRT_REC = ' ' .AND. FRT_PD = ' '
               MX = FRT_AMT1 + FRT_PALL + FRT1_ADJ1 + FRT1_ADJ2
               MTOTAL = MTOTAL + MX
               IF MYES_NO = 'Y'
                  IF MLINE > 56 
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                     MLINE = 0
                  ENDIF
                  MLINE = MLINE + 1
                  ? SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX + SPACE(7) + INV_NBR + SPACE(7) + TRANSFORM(MX, '999,999.99') + space(5) + dtoc(ship_date) 
               ENDIF
               SKIP
            ENDDO
            
            SELECT A
            DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
            DO WHILE .NOT. EOF()
               IF DEB_CRD = 'Y'
                  IF FRT_CODE = MFRT_CODE
                     MTOTAL = MTOTAL + AMT_DUE
                     IF MYES_NO = 'Y'
                        IF MLINE > 56 
                           IF MLINE <> 99
                              EJECT
                           ENDIF
                           MLINE = 0
                        ENDIF
                        MLINE = MLINE + 1
                        ? SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX + SPACE(7) + INV_NBR + SPACE(7) + TRANSFORM(AMT_DUE, '999,999.99') + SPACE(5) + dtoc(DUE_DATE) 
                     ENDIF
                  ENDIF
               ENDIF
               SKIP
            ENDDO
            IF MYES_NO = 'Y'
               IF MTOTAL <> 0
                  ?
                  ? SPACE(03) + 'TOTAL AMOUNT OWED'
                  ? SPACE(03) + TRANSFORM(MTOTAL, '9,999,999.99')
                  ?
                  EJECT
               ENDIF
               SET DEVICE TO SCREEN
               SET PRINT OFF
               SET PRINT TO
               SET CONSOLE ON
               IF MPRINTER3 <> 'DONOTPRINT'
                  RUN &MPRINTIT3
               ENDIF
               
            ENDIF
            @ 10,10 SAY SPACE(40)
            @ 06,10 SAY MNAME
            @ 07,10 SAY MSTREET
            @ 08,10 SAY TRIM(MCITY) + ', ' + MSTATE
            @ 11,10 SAY 'TOTAL AMOUNT OWED'
            @ 12,12 SAY MTOTAL PICTURE '9,999,999.99'
            @ 23,1 SAY 'Press any key when ready to continue...'
            wait ' '
            @ 06,1 CLEAR TO 21,78
            @ 23,0
            STORE 'N' TO MAGAIN 
            @ 10,05 SAY 'Do You Want to Select Another Freight Carrier (Y/N)? ' get mAGAIN picture '@!'
            READ
            IF MAGAIN <> 'Y'
               MNEXT_FRT = .F.
            ENDIF
         ENDDO
         CLOSE DATA
      CASE MCUS_SEL = 'X'
         STORE 'N' TO MYES_NO
         @ 17,5 SAY 'PRINT LIST OF ORDERS (Y/N)? ' GET MYES_NO PICTURE '@!'
         READ
         MNEXT_CUST = .T.
         DO WHILE MNEXT_CUST
            MNAME_FD = .F.
            DO BBUYSEL3
            IF .NOT. MNAME_FD
               MNEXT_CUST = .F.
               LOOP
            ENDIF
            STORE NAME TO MNAME
            STORE BBUYCODE TO MBBUYCODE
            STORE STREET TO MSTREET
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            STORE ZIP TO MZIP
            SET PROC TO PAY_PROC
            MTITLE = ' - DISPLAY CUSTOMER BALANCE'
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            SELECT B
            DO FOX_USE WITH "INV_ADJ INDEX INV_ADJ", .F.
            SELECT A
            DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR", .F.
            SEEK MBBUYCODE + ' '
            IF EOF()
               @ 14,1 SAY 'NO OUTSTANDING DEBITS OR CREDITS ON FILE FOR THIS CUSTOMER '
               @ 16,1 SAY 'PLEASE REENTER THE CUSTOMER SELECTED'
               @ 17,1 SAY ' '
               WAIT 'PRESS RETURN TO CONTINUE'
               LOOP
            ENDIF
            @ 10,10 SAY 'CALCULATING.......'
            IF MYES_NO = 'Y'
               
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
               
               ? MNAME
               ? MSTREET
               ? TRIM(MCITY) + ', ' + MSTATE
            ENDIF
            MLINE = 99
            STORE 0 TO MBALANCE, MMISC_TOT, MREC_CRD
            DO WHILE .NOT. EOF() .AND. BBUYCODE = MBBUYCODE .AND. PAID_FLG = ' '
               ***** DO I COUNT THOSE CREDITS IN THE MISCELLANEOUS COLUMN
               IF SUBSTR(INV_NBR,1,1) = 'A' .OR. DEB_CRD <> ' '
                  DO CASE
                  CASE TOT_SELL- AMT_PAID < 0 .AND. TOT_SELL-AMT_PAID >= -1000
                     MMISC_TOT = MMISC_TOT + (TOT_SELL - AMT_PAID)
                     IF MYES_NO = 'Y'
                        IF MLINE > 56 
                           IF MLINE <> 99
                              EJECT
                           ENDIF
                           MLINE = 0
                        ENDIF
                        MLINE = MLINE + 1
                        ? SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX + SPACE(7) + INV_NBR + SPACE(7) + TRANSFORM(TOT_SELL-AMT_PAID, '999,999.99') + SPACE(5) + DTOC(SHIP_DATE)
                     ENDIF
                     SKIP
                     LOOP
                  CASE TOT_SELL-AMT_PAID < -1000
                     MREC_CRD = MREC_CRD + (TOT_SELL-AMT_PAID)
                     IF MYES_NO = 'Y'
                        IF MLINE > 56 
                           IF MLINE <> 99
                              EJECT
                           ENDIF
                           MLINE = 0
                        ENDIF
                        MLINE = MLINE + 1
                        ? SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX + SPACE(7) + INV_NBR + SPACE(7) + TRANSFORM(TOT_SELL-AMT_PAID, '999,999.99') + SPACE(5) + DTOC(SHIP_DATE)
                     ENDIF
                     SKIP
                     LOOP
                  ENDCASE
               ENDIF
               STORE INV_NBR TO MINV_NBR
               STORE SALESMAN TO MSALESMAN
               STORE PO_NBR TO MPO_NBR
               STORE PO_SUFFIX TO MPO_SUFFIX
               MAMT = TOT_SELL + CUS_PALL - AMT_PAID
               IF SUBSTR(MINV_NBR,1,1) <> 'A' .AND. DEB_CRD = ' '
                  SELECT B
                  SEEK MINV_NBR
                  DO WHILE .NOT. EOF() .AND. INV_NBR = MINV_NBR
                     MAMT = MAMT + ADJ_AMT
                     SKIP
                  ENDDO
                  SELECT A
               ENDIF
               IF MYES_NO = 'Y'
                  IF MLINE > 56 
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                     MLINE = 0
                  ENDIF
                  MLINE = MLINE + 1
                  ? SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX + SPACE(7) + INV_NBR + SPACE(7) + TRANSFORM(MAMT, '999,999.99') + SPACE(5) + DTOC(SHIP_DATE)
               ENDIF
               MBALANCE = MBALANCE + MAMT
               SKIP
            ENDDO
            IF MYES_NO = 'Y'
               IF MBALANCE <> 0
                  ?
                  ? SPACE(5) + 'RECEIVABLE    RECEIVABLE CREDIT   MISC CREDIT    TOTAL RECEIVABLE'
                  MTOT = MBALANCE + MREC_CRD + MMISC_TOT
                  ? SPACE(3) + TRANSFORM(MBALANCE, '9,999,999.99')
                  ?? SPACE(05) + TRANSFORM(MREC_CRD, '9,999,999.99')
                  ?? SPACE(05) + TRANSFORM(MMISC_TOT, '9,999,999.99')
                  ?? SPACE(05) + TRANSFORM(MTOT, '9,999,999.99')
                  ?
                  EJECT
               ENDIF
               
               SET DEVICE TO SCREEN
               SET PRINT OFF
               SET PRINT TO
               SET CONSOLE ON
               IF MPRINTER3 <> 'DONOTPRINT'
                  RUN &MPRINTIT3
               ENDIF
            ENDIF
            
            @ 10,05 SAY SPACE(40)
            @ 06,05 SAY MNAME
            @ 07,05 SAY MSTREET
            @ 08,05 SAY TRIM(MCITY) + ', ' + MSTATE
            @ 11,05 SAY 'RECEIVABLE    RECEIVABLE CREDIT   MISC CREDIT    TOTAL RECEIVABLE'
            @ 12,03 SAY MBALANCE PICTURE '9,999,999.99'
            @ 12,22 SAY MREC_CRD PICTURE '9,999,999.99'
            @ 12,38 SAY MMISC_TOT PICTURE '9,999,999.99'
            @ 12,56 SAY MBALANCE + MREC_CRD + MMISC_TOT PICTURE '9,999,999.99'
            @ 23,1 SAY 'Press any key when ready to continue...'
            wait ' '
            @ 06,1 CLEAR TO 21,78
            @ 23,0
            STORE 'N' TO MAGAIN 
            @ 10,05 SAY 'Do You Want to Select Another Customer (Y/N)? ' get MAGAIN  picture '@!'
            READ
            IF MAGAIN <> 'Y'
               MNEXT_CUST = .F.
            ENDIF
         ENDDO
         
      ENDCASE
      
   CASE MRPT_SEL = '8'
      
      STORE SPACE(32) TO MRSUPNAME, MBBUYNAME, MFRT_NAME
      DIMENSION MUPDRCD(15)  
      DIMENSION MSELECT(15)
      MVIEW = .T.
      
      MPO_FD = .F.
      STORE 1 TO MACTION
      MPO_SEL = .T.
      DO WHILE MPO_SEL
         
         CLEAR 
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         MTITLE = ' - PAYMENT SELECTION MENU'
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         @  4, 5 SAY 'Enter One of the Following Search Fields:'
         @ 08,3 say  'Customer Name:'
         @ 12,3 say  'Supplier Name:'
         @ 16,3 say  ' Freight Name:'
         
         @ 08,18 GET MBBUYNAME PICTURE '@!'
         @ 12,18 GET MRSUPNAME PICTURE '@!'
         @ 16,18 GET MFRT_NAME PICTURE '@!'
         
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
         @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 3
            MPO_SEL = .F.
            LOOP
         ENDIF
         IF MACTION = 1
            store 'N' to mtot_only
            @ 19,3 SAY 'Display Totals Only (Y/N)? ' get mtot_only picture '@!'
            READ
            
            IF MTOT_ONLY = 'Y'
               STORE CTOD(' ') TO MBEGIN, MEND
               DO WHILE MBEGIN = CTOD('') .AND. MEND = CTOD('')
                  @ 21,3 SAY 'Begin Date: '
                  @ 21,15 GET MBEGIN 
                  @ 21,30 say 'End Date: ' 
                  @ 21,40 GET MEND
                  READ
               ENDDO
            ENDIF
            
            
            DO CASE
            CASE MBBUYNAME <> SPACE(32)
               STORE MBBUYNAME TO MNAME
               MNAME_FD = .F.
               STORE TRIM(MNAME) TO SRCH_ARG
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
               SEEK SRCH_ARG
               IF EOF()
                  @ 24,0 CLEAR
                  STORE ' ' TO MSPACE 
                  @ 24,10 SAY 'BILL TO NAME NOT FOUND ON FILE - PLEASE RETURN TO REENTER ' GET MSPACE PICTURE '@!'
                  READ
                  LOOP
               ELSE 
                  STORE RECNO() TO MFST_REC
                  SKIP
                  IF NAME = SRCH_ARG
                     MADD = .F.
                     DO MUL1BBUY
                     IF MACTION <> 5
                        MNAME_FD = .T.
                     ENDIF
                  ELSE
                     GOTO MFST_REC
                     MNAME_FD = .T.
                  ENDIF
               ENDIF
               IF .NOT. MNAME_FD
                  LOOP              
               ENDIF
               STORE BBUYCODE TO MSVCODE
               STORE NAME TO MNAME
               STORE STREET TO MSTREET
               STORE CITY TO MCITY
               STORE STATE TO MSTATE
               
            CASE MRSUPNAME <> SPACE(32)
               STORE MRSUPNAME TO MNAME
               MNAME_FD = .F.
               STORE TRIM(MNAME) TO SRCH_ARG
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
               SEEK SRCH_ARG
               IF EOF() .OR. DELETED()
                  @ 24,0 CLEAR
                  STORE ' ' TO MSPACE 
                  @ 24,10 SAY 'REMIT TO NAME NOT FOUND ON FILE - PRESS RETURN TO REENTER ' GET MSPACE PICTURE '@!'
                  READ
                  LOOP
               ELSE               
                  STORE RECNO() TO MFST_REC
                  SKIP
                  IF NAME = SRCH_ARG
                     MADD = .F.
                     DO MUL1RSUP
                     IF MACTION <> 5
                        MNAME_FD = .T.
                     ENDIF
                  ELSE
                     GOTO MFST_REC
                     MNAME_FD = .T.
                  ENDIF
               ENDIF
               IF .NOT. MNAME_FD
                  LOOP
               ENDIF
               STORE RSUPCODE TO MSVCODE   
               STORE NAME TO MNAME
               STORE STREET TO MSTREET
               STORE CITY TO MCITY
               STORE STATE TO MSTATE
               
            CASE MFRT_NAME <> SPACE(32)
               STORE MFRT_NAME TO MNAME
               MNAME_FD = .F.
               STORE TRIM(MNAME) TO SRCH_ARG
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
               SEEK SRCH_ARG
               IF EOF()
                  @ 24,0 CLEAR
                  STORE ' ' TO MSPACE 
                  @ 24,10 SAY 'FREIGHT CARRIER NOT FOUND ON FILE - PRESS RETURN TO REENTER ' GET MSPACE PICTURE '@!'
                  READ
               ELSE               
                  STORE RECNO() TO MFST_REC
                  SKIP
                  IF NAME = SRCH_ARG
                     MADD = .F.
                     DO MUL1FRT 
                     IF MACTION <> 5
                        MNAME_FD = .T.
                     ENDIF
                  ELSE
                     GOTO MFST_REC
                     MNAME_FD = .T.
                  ENDIF
               ENDIF
               IF .NOT. MNAME_FD
                  LOOP
               ENDIF
               STORE FRT_CODE TO MSVCODE    
               STORE NAME TO MNAME
               STORE STREET TO MSTREET
               STORE CITY TO MCITY
               STORE STATE TO MSTATE
            OTHERWISE
               MPO_SEL = .F.
               LOOP
            ENDCASE
            
            DO CASE
            CASE MTOT_ONLY = 'N'
               DO CASE  
               CASE MBBUYNAME <> SPACE(32)
                  SELECT B
                  DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
                  SELECT C
                  DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
                  SELECT G
                  DO FOX_USE WITH "PAYMENTS INDEX PAY_SYS", .F.
                  SEEK MSVCODE
                  IF EOF()
                     @ 4,1  CLEAR TO 21,78
                     @ 10,5 SAY 'NO PAYMENTS ON FILE FROM THIS CUSTOMER'
                     STORE ' ' TO MWAIT
                     @ 12,5 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT 
                     READ
                     LOOP
                  ENDIF
                  MTITLE = ' - DISPLAY PAYMENTS RECEIVED FROM CUSTOMERS'
                  CLEAR
                  @  1, 0 SAY MCOMPANY
                  @  1,68 SAY DATE()
                  @  2, 0 SAY MPROGRAM + MTITLE
                  @ 3,0 to 24,79
                  @ 04,1 SAY MNAME
                  @ 5,1 SAY TRIM(MSTREET) + ',  ' + TRIM(MCITY) + ',  ' + MSTATE
                  @ 06,1 TO 06,78
                  @ 07,1  SAY '   Sel    PO #    Inv.  Ship Dt   Cust PO Nbr    Amt Recvd  Paid Dt   Ck Nbr'
                  *            123456789012345678901234567890123456789012345678901234567890123456789012345678   
                  *                     10        20        30        40        50        60        70
                  *                x  xx-xxxx-x  xxxx  xx/xx/xx  xxxxxxxxxxxx  999,999.99  XX/XX/XX  xxxxxxx
                  STORE RECNO() TO MVWRECNO
                  DO WHILE .NOT. EOF() .AND. BBUYCODE = MSVCODE
                     STORE ' ' TO MSELECT, MUPDRCD
                     SELECT G
                     DO FOX_USE WITH "PAYMENTS INDEX PAY_SYS", .F.
                     GOTO MVWRECNO
                     MLINE = 08
                     @ 08,1 CLEAR TO 22,78
                     @ 24,0 CLEAR
                     DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. BBUYCODE = MSVCODE
                        I = MLINE - 7
                        @ MLINE,1 SAY STR(I,2) + '.'
                        IF SALESMAN <> SPACE(2)
                           @ MLINE,8 SAY SALESMAN + '-'
                        ENDIF
                        @ MLINE,11 SAY PO_NBR
                        IF PO_SUFFIX <> SPACE(1)
                           @ MLINE,15 SAY '-' + PO_SUFFIX
                        ENDIF
                        @ MLINE,18 SAY INV_NBR    
                        SELECT B
                        SEEK G->SALESMAN + G->PO_NBR + G->PO_SUFFIX
                        IF .NOT. EOF()
                           @ MLINE,24 SAY SHIP_DATE
                           IF SUBSTR(BUYER_PO,13,1) = ' '
                              @ MLINE,35 SAY BUYER_PO
                           ELSE
                              @ MLINE,35 SAY SUBSTR(BUYER_PO,4)
                           ENDIF
                           STORE RECNO() TO MUPDRCD(I)
                        ELSE
                           STORE 0 TO MUPDRCD(I)
                        ENDIF
                        SELECT G
                        @ MLINE,49 SAY  AMT_PAID PICTURE '999,999.99'
                        @ MLINE,61 SAY PAID_DATE
                        @ MLINE,71 SAY CK_NBR
                        SKIP
                        MLINE = MLINE + 1
                     ENDDO
                     MVW_MAX = MLINE - 1
                     STORE RECNO() TO MVWRECNO
                     IF .NOT. EOF() .AND. BBUYCODE = MSVCODE
                        @ 23,70 SAY "More ...."
                        MVWBLURP = .T.
                     ELSE
                        @ 23,70 to 23,78
                        MVWBLURP = .F.
                     ENDIF
                     @ 24,01 SAY 'Action: ' + STR(MACTION,1)
                     IF MVWBLURP
                        @ 24,13 SAY '1. Continue/Next Page     2. Edit    3. Finished'    
                     ELSE
                        @ 24,13 SAY '1. Continue/Return     2. Edit     3. Finished'    
                     ENDIF
                     STORE 2 TO MACTION
                     DO WHILE MACTION = 2
                        MVWLINE = 8
                        MVWI = 1
                        SELECT B
                        DO WHILE MVWLINE <= MVW_MAX
                           @ MVWLINE,5 GET MSELECT(MVWI) PICTURE '@!'
                           READ
                           IF MSELECT(MVWI) = 'X'
                              SELECT B
                              IF MUPDRCD(MVWI) <> 0
                                 GOTO MUPDRCD(MVWI)
                                 SAVE SCREEN TO MVW_SCREEN
                                 DO POVWMAIN
                                 RESTORE SCREEN FROM MVW_SCREEN
                              ENDIF
                           ENDIF
                           @ MVWLINE,5 SAY ' '
                           MVWLINE = MVWLINE + 1
                           MVWI = MVWI + 1
                        ENDDO
                        STORE 1 TO MACTION
                        @ 24,9 GET MACTION PICTURE '9' RANGE 1,3
                        READ
                     ENDDO
                     
                     IF MACTION = 3 
                        SELECT G
                        DO FOX_USE WITH "PAYMENTS INDEX PAY_SYS", .F.
                        GOTO BOTTOM
                        SKIP
                        LOOP
                     ENDIF
                     IF .NOT. MVWBLURP .AND. MACTION = 1
                        SELECT G
                        DO FOX_USE WITH "PAYMENTS INDEX PAY_SYS", .F.
                        GOTO BOTTOM
                        SKIP
                        LOOP
                     ENDIF
                     SELECT G
                     DO FOX_USE WITH "PAYMENTS INDEX PAY_SYS", .F.
                     GOTO MVWRECNO
                  ENDDO
                  
               CASE MRSUPNAME <> SPACE(32)
                  SELECT C
                  DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
                  SELECT B
                  DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
                  SELECT G
                  DO FOX_USE WITH "DISBJRN INDEX DISBINQ", .F.
                  SEEK 'S' + MSVCODE
                  IF EOF()
                     @ 3,0 CLEAR
                     @ 3,0 TO 22,79
                     @ 10,5 SAY 'NO PAYMENTS ON FILE TO THIS SUPPLIER'
                     STORE ' ' TO MWAIT
                     @ 12,5 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT 
                     READ
                     LOOP
                  ENDIF
                  MTITLE = ' - DISPLAY PAYMENTS ON FILE TO SUPPLIER'
                  CLEAR
                  @  1, 0 SAY MCOMPANY
                  @  1,68 SAY DATE()
                  @  2, 0 SAY MPROGRAM + MTITLE
                  @ 3,0 to 24,79
                  @ 04,1 SAY MNAME
                  @ 5,1 SAY TRIM(MSTREET) + ',  ' + TRIM(MCITY) + ',  ' + MSTATE
                  @ 06,1 TO 06,78
                  @ 07,1  SAY '   Sel    PO #    Inv.  Ship Dt   Sup Inv Nbr     Amt Paid  Paid Dt   Ck Nbr'
                  *            123456789012345678901234567890123456789012345678901234567890123456789012345678   
                  *                     10        20        30        40        50        60        70
                  *                x  xx-xxxx-x  xxxx  xx/xx/xx  xxxxxxxxxxxx  999,999.99  XX/XX/XX  xxxxxxx
                  STORE RECNO() TO MVWRECNO
                  DO WHILE .NOT. EOF() .AND. ACCT_NBR = MSVCODE .AND. ACCT_TYPE = 'S'
                     STORE ' ' TO MSELECT, MUPDRCD
                     SELECT G
                     DO FOX_USE WITH "DISBJRN INDEX DISBINQ", .F.
                     GOTO MVWRECNO
                     MLINE = 08
                     @ 08,1 CLEAR TO 22,78
                     @ 24,0 CLEAR
                     DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. ACCT_NBR = MSVCODE .AND. ACCT_TYPE = 'S'
                        I = MLINE - 7
                        @ MLINE,1 SAY STR(I,2) + '.'
                        STORE RECNO() TO MUPDRCD(I)
                        
                        IF SALESMAN <> SPACE(2)
                           @ MLINE,8 SAY SALESMAN + '-'
                        ENDIF
                        @ MLINE,11 SAY PO_NBR
                        IF PO_SUFFIX <> SPACE(1)
                           @ MLINE,15 SAY '-' + PO_SUFFIX
                        ENDIF
                        @ MLINE,18 SAY INV_NBR    
                        SELECT B
                        SEEK G->SALESMAN + G->PO_NBR + G->PO_SUFFIX
                        IF .NOT. EOF()
                           @ MLINE,24 SAY SHIP_DATE
                           STORE RECNO() TO MUPDRCD(I)
                        ELSE
                           STORE 0 TO MUPDRCD(I)
                        ENDIF
                        SELECT G
                        @ MLINE,35 SAY BILL_INV
                        @ MLINE,49 SAY  AMOUNT1 PICTURE '999,999.99'
                        @ MLINE,61 SAY JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR 
                        @ MLINE,71 SAY CK_NBR
                        SKIP
                        MLINE = MLINE + 1
                     ENDDO
                     MVW_MAX = MLINE - 1
                     STORE RECNO() TO MVWRECNO
                     IF .NOT. EOF() .AND. ACCT_NBR = MSVCODE .AND. ACCT_TYPE = 'S'
                        @ 23,70 SAY "More PO's"
                        MVWBLURP = .T.
                     ELSE
                        @ 23,70 to 23,78
                        MVWBLURP = .F.
                     ENDIF
                     @ 24,01 SAY 'Action: ' + STR(MACTION,1)
                     IF MVWBLURP
                        @ 24,13 SAY '1. Continue/Next Page     2. Edit    3. Finished'    
                     ELSE
                        @ 24,13 SAY '1. Continue/Return     2. Edit     3. Finished'    
                     ENDIF
                     STORE 2 TO MACTION
                     DO WHILE MACTION = 2
                        MVWLINE = 8
                        MVWI = 1
                        DO WHILE MVWLINE <= MVW_MAX
                           @ MVWLINE,5 GET MSELECT(MVWI) PICTURE '@!'
                           READ
                           IF MSELECT(MVWI) = 'X'
                              SELECT B
                              GOTO MUPDRCD(MVWI)
                              SAVE SCREEN TO MVW_SCREEN
                              DO POVWMAIN
                              RESTORE SCREEN FROM MVW_SCREEN
                           ENDIF
                           @ MVWLINE,5 SAY ' '
                           MVWLINE = MVWLINE + 1
                           MVWI = MVWI + 1
                        ENDDO
                        STORE 1 TO MACTION
                        
                        @ 24,9 GET MACTION PICTURE '9' RANGE 1,3
                        READ
                     ENDDO
                     
                     IF MACTION = 3 
                        SELECT G
                        DO FOX_USE WITH "DISBJRN INDEX DISBINQ", .F.
                        GOTO BOTTOM
                        SKIP
                        LOOP
                     ENDIF
                     IF .NOT. MVWBLURP .AND. MACTION = 1
                        SELECT G
                        DO FOX_USE WITH "DISBJRN INDEX DISBINQ", .F.
                        GOTO BOTTOM
                        SKIP
                        LOOP
                     ENDIF
                     SELECT G
                     DO FOX_USE WITH "DISBJRN INDEX DISBINQ", .F.
                     GOTO MVWRECNO
                  ENDDO
                  
               CASE MFRT_NAME <> SPACE(32)
                  SELECT C
                  DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
                  SELECT B
                  DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
                  SELECT G
                  DO FOX_USE WITH "DISBJRN INDEX DISBINQ", .F.
                  SEEK 'F' + MSVCODE
                  IF EOF()
                     @ 3,0 CLEAR
                     @ 3,0 TO 22,79
                     STORE ' ' TO MWAIT
                     @ 12,5 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT 
                     READ
                     LOOP
                  ENDIF
                  MTITLE = ' - DISPLAY PAYMENTS ON FILE TO FREIGHT CARRIER'
                  CLEAR
                  @  1, 0 SAY MCOMPANY
                  @  1,68 SAY DATE()
                  @  2, 0 SAY MPROGRAM + MTITLE
                  @ 3,0 to 24,79
                  @ 04,1 SAY MNAME
                  @ 5,1 SAY TRIM(MSTREET) + ',  ' + TRIM(MCITY) + ',  ' + MSTATE
                  @ 06,1 TO 06,78
                  @ 07,1  SAY '   Sel    PO #    Inv.  Ship Dt   Sup Inv Nbr     Amt Paid  Paid Dt   Ck Nbr'
                  *            123456789012345678901234567890123456789012345678901234567890123456789012345678   
                  *                     10        20        30        40        50        60        70
                  *                x  xx-xxxx-x  xxxx  xx/xx/xx  xxxxxxxxxxxx  999,999.99  XX/XX/XX  xxxxxxx
                  STORE RECNO() TO MVWRECNO
                  DO WHILE .NOT. EOF() .AND. ACCT_NBR = MSVCODE .AND. ACCT_TYPE = 'F'
                     STORE ' ' TO MSELECT, MUPDRCD
                     SELECT G
                     DO FOX_USE WITH "DISBJRN INDEX DISBINQ", .F.
                     GOTO MVWRECNO
                     MLINE = 08
                     @ 08,1 CLEAR TO 22,78
                     @ 24,0 CLEAR
                     DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. ACCT_NBR = MSVCODE .AND. ACCT_TYPE = 'F'
                        I = MLINE - 7
                        @ MLINE,1 SAY STR(I,2) + '.'
                        STORE RECNO() TO MUPDRCD(I)
                        
                        IF SALESMAN <> SPACE(2)
                           @ MLINE,8 SAY SALESMAN + '-'
                        ENDIF
                        @ MLINE,11 SAY PO_NBR
                        IF PO_SUFFIX <> SPACE(1)
                           @ MLINE,15 SAY '-' + PO_SUFFIX
                        ENDIF
                        @ MLINE,18 SAY INV_NBR    
                        SELECT B
                        SEEK G->SALESMAN + G->PO_NBR + G->PO_SUFFIX
                        IF .NOT. EOF()
                           @ MLINE,24 SAY SHIP_DATE
                           STORE RECNO() TO MUPDRCD(I)
                        ELSE
                           STORE 0 TO MUPDRCD(I)
                        ENDIF
                        SELECT G
                        @ MLINE,35 SAY BILL_INV
                        @ MLINE,49 SAY  AMOUNT1 PICTURE '999,999.99'
                        @ MLINE,61 SAY JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR 
                        @ MLINE,71 SAY CK_NBR
                        SKIP
                        MLINE = MLINE + 1
                     ENDDO
                     MVW_MAX = MLINE - 1
                     STORE RECNO() TO MVWRECNO
                     IF .NOT. EOF() .AND. ACCT_NBR = MSVCODE .AND. ACCT_TYPE = 'F'
                        @ 23,70 SAY "More PO's"
                        MVWBLURP = .T.
                     ELSE
                        @ 23,70 to 23,78
                        MVWBLURP = .F.
                     ENDIF
                     @ 24,01 SAY 'Action: ' + STR(MACTION,1)
                     IF MVWBLURP
                        @ 24,13 SAY '1. Continue/Next Page     2. Edit    3. Finished'    
                     ELSE
                        @ 24,13 SAY '1. Continue/Return     2. Edit     3. Finished'    
                     ENDIF
                     STORE 2 TO MACTION
                     DO WHILE MACTION = 2
                        MVWLINE = 8
                        MVWI = 1
                        DO WHILE MVWLINE <= MVW_MAX
                           @ MVWLINE,5 GET MSELECT(MVWI) PICTURE '@!'
                           READ
                           IF MSELECT(MVWI) = 'X'
                              SELECT B
                              GOTO MUPDRCD(MVWI)
                              SAVE SCREEN TO MVW_SCREEN
                              DO POVWMAIN
                              RESTORE SCREEN FROM MVW_SCREEN
                           ENDIF
                           @ MVWLINE,5 SAY ' '
                           MVWLINE = MVWLINE + 1
                           MVWI = MVWI + 1
                        ENDDO
                        STORE 1 TO MACTION
                        
                        @ 24,9 GET MACTION PICTURE '9' RANGE 1,3
                        READ
                     ENDDO
                     
                     IF MACTION = 3 
                        SELECT G
                        DO FOX_USE WITH "DISBJRN INDEX DISBINQ", .F.
                        GOTO BOTTOM
                        SKIP
                        LOOP
                     ENDIF
                     IF .NOT. MVWBLURP .AND. MACTION = 1
                        SELECT G
                        DO FOX_USE WITH "DISBJRN INDEX DISBINQ", .F.
                        GOTO BOTTOM
                        SKIP
                        LOOP
                     ENDIF
                     SELECT G
                     DO FOX_USE WITH "DISBJRN INDEX DISBINQ", .F.
                     GOTO MVWRECNO
                  ENDDO
                  
               OTHERWISE
                  MPO_SEL = .F.
                  LOOP
               ENDCASE
               ****
               **** DISPLAY TOTALS ONLY FROM HERE ON DOWN
            CASE MTOT_ONLY = 'Y'
               DO CASE  
               CASE MBBUYNAME <> SPACE(32)
                  SELECT G
                  DO FOX_USE WITH "PAYMENTS INDEX PAY_SYS", .F.
                  SEEK MSVCODE
                  IF EOF()
                     @ 3,0 CLEAR
                     @ 3,0 TO 22,79
                     @ 10,5 SAY 'NO PAYMENTS ON FILE FROM THIS CUSTOMER'
                     STORE ' ' TO MWAIT
                     @ 12,5 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT 
                     READ
                     LOOP
                  ENDIF
                  MTITLE = ' - DISPLAY PAYMENT TOTAL RECEIVED FROM CUSTOMER'
                  CLEAR
                  @  1, 0 SAY MCOMPANY
                  @  1,68 SAY DATE()
                  @  2, 0 SAY MPROGRAM + MTITLE
                  @ 3,0 to 24,79
                  @ 04,1 SAY MNAME
                  @ 5,1 SAY TRIM(MSTREET) + ',  ' + TRIM(MCITY) + ',  ' + MSTATE
                  @ 06,1 TO 06,78
                  MTOTAL = 0
                  MNOT_DONE = .T.
                  DO WHILE .NOT. EOF() .AND. BBUYCODE = MSVCODE .AND. MNOT_DONE
                     IF PAID_DATE < MBEGIN
                        MNOT_DONE = .F.
                        LOOP
                     ENDIF
                     IF PAID_DATE >= MBEGIN .AND. PAID_DATE <= MEND
                        MTOTAL = MTOTAL + AMT_PAID + AMT_OVER
                     ENDIF
                     SKIP
                  ENDDO
                  @ 10,1 SAY 'TOTAL RECEIPTS FROM ' + DTOC(MBEGIN) + ' - ' + DTOC(MEND)
                  @ 12,17 SAY MTOTAL PICTURE '99,999,999.99'
                  STORE ' ' TO MWAIT
                  @ 24,0 SAY 'PRESS RETURN TO CONTINUE... ' GET MWAIT
                  READ
                  
                  
               CASE MRSUPNAME <> SPACE(32)
                  SELECT G
                  DO FOX_USE WITH "DISBJRN INDEX DISBINQ", .F.
                  SEEK 'S' + MSVCODE
                  IF EOF()
                     @ 3,0 CLEAR
                     @ 3,0 TO 22,79
                     @ 10,5 SAY 'NO PAYMENTS ON FILE TO THIS SUPPLIER'
                     STORE ' ' TO MWAIT
                     @ 12,5 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT 
                     READ
                     LOOP
                  ENDIF
                  MTITLE = ' - DISPLAY PAYMENT TOTAL REMITTED TO SUPPLIER'
                  CLEAR
                  @  1, 0 SAY MCOMPANY
                  @  1,68 SAY DATE()
                  @  2, 0 SAY MPROGRAM + MTITLE
                  @ 3,0 to 24,79
                  @ 04,1 SAY MNAME
                  @ 5,1 SAY TRIM(MSTREET) + ',  ' + TRIM(MCITY) + ',  ' + MSTATE
                  @ 06,1 TO 06,78
                  MTOTAL = 0
                  MNOT_DONE = .T.
                  DO WHILE .NOT. EOF() .AND. ACCT_NBR = MSVCODE .AND. ACCT_TYPE = 'S' .AND. MNOT_DONE
                     STORE JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR TO MDATE
                     STORE CTOD(MDATE) TO MDATE
                     IF MDATE < MBEGIN
                        MNOT_DONE = .F.
                        LOOP
                     ENDIF
                     IF MDATE >= MBEGIN .AND. MDATE <= MEND
                        MTOTAL = MTOTAL + AMOUNT1
                     ENDIF
                     SKIP
                  ENDDO
                  @ 10,1 SAY 'TOTAL REMITTED FROM ' + DTOC(MBEGIN) + ' - ' + DTOC(MEND)
                  @ 12,17 SAY MTOTAL PICTURE '99,999,999.99'
                  STORE ' ' TO MWAIT
                  @ 24,0 SAY 'PRESS RETURN TO CONTINUE... ' GET MWAIT
                  READ
                  
                  
               CASE MFRT_NAME <> SPACE(32)
                  SELECT G
                  DO FOX_USE WITH "DISBJRN INDEX DISBINQ", .F.
                  SEEK 'F' + MSVCODE
                  IF EOF()
                     @ 3,0 CLEAR
                     @ 3,0 TO 22,79
                     @ 10,5 SAY 'NO PAYMENTS ON FILE TO THIS SUPPLIER'
                     STORE ' ' TO MWAIT
                     @ 12,5 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT 
                     READ
                     LOOP
                  ENDIF
                  MTITLE = ' - DISPLAY PAYMENT TOTAL REMITTED TO FREIGHT'
                  CLEAR
                  @  1, 0 SAY MCOMPANY
                  @  1,68 SAY DATE()
                  @  2, 0 SAY MPROGRAM + MTITLE
                  @ 3,0 to 24,79
                  @ 04,1 SAY MNAME
                  @ 5,1 SAY TRIM(MSTREET) + ',  ' + TRIM(MCITY) + ',  ' + MSTATE
                  @ 06,1 TO 06,78
                  MTOTAL = 0
                  MNOT_DONE = .T.
                  DO WHILE .NOT. EOF() .AND. ACCT_NBR = MSVCODE .AND. ACCT_TYPE = 'F' .AND. MNOT_DONE
                     STORE JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR TO MDATE
                     STORE CTOD(MDATE) TO MDATE
                     IF MDATE < MBEGIN
                        MNOT_DONE = .F.
                        LOOP
                     ENDIF
                     IF MDATE >= MBEGIN .AND. MDATE <= MEND
                        MTOTAL = MTOTAL + AMOUNT1
                     ENDIF
                     SKIP
                  ENDDO
                  @ 10,1 SAY 'TOTAL REMITTED FROM ' + DTOC(MBEGIN) + ' - ' + DTOC(MEND)
                  @ 12,17 SAY MTOTAL PICTURE '99,999,999.99'
                  STORE ' ' TO MWAIT
                  @ 24,0 SAY 'PRESS RETURN TO CONTINUE... ' GET MWAIT
                  READ
               OTHERWISE 
                  MPO_SEL = .F.
                  LOOP
               ENDCASE
            OTHERWISE
               MPO_SEL = .F.
               LOOP
            ENDCASE
            
         ENDIF
         STORE SPACE(32)   TO MRSUPNAME, MBBUYNAME, MFRT_NAME
      ENDDO
      
      RELEASE MUPDRCD, MSELECT
      
   ENDCASE
   
ENDDO
CLOSE DATA

RETURN

* EOF: REPORTS.PRG


*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 2:36 PM.
