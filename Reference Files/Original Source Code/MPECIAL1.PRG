************
* Program.: SPECIAL1.PRG
* Author..: GRACE KELLER
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SPECIAL1
*
* ---SET environment.
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

CLEAR
@ 00,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@ 01,00 SAY MPROGRAM + ' - REPORT SPECIAL1'
@ 2,0 to 22,79

**** GET FIRST AND LAST DATES FOR THIS REPORT
STORE CTOD(' ') TO MSTART, MLAST
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   STORE ' ' TO MCHOICE
   STORE 'P' TO MDISP_PRT
   STORE SPACE(10) TO MPROD
   STORE ' ' TO MCHOICE1, MCHOICE2, MCHOICE3, MCHOICE4
   STORE 'Y' TO MSUM_ONLY
   STORE 2 TO MACTION
   DO WHILE MACTION = 2      
      @ 06,5 SAY 'Totals by Product for: ' 
      @ 8,2 say '        Beginning Date: '
      @ 8,27 GET MSTART
      @ 9,2 SAY '           Ending Date: '
      @ 9,27 GET MLAST
      @ 11,1 SAY '    Summary Report Only: ' GET MSUM_ONLY PICTURE '@!' VALID(MSUM_ONLY = 'Y' .OR. MSUM_ONLY = 'N')
      @ 13,1 SAY '           PRODUCT CODE: ' get mprod picture '@!'
      @ 14,1 say '(Optional - Leave product blank if report for all products.)'
      @ 17,1 SAY 'Optionally select specific Customers/Suppliers - select with an "X"'
      @ 18,3 SAY 'Remit to     Supplier            Bill to Customer:'
      @ 19,3 SAY 'Shipped from Supplier            Ship to Customer:'
      @ 18,25 GET MCHOICE1 PICTURE '@!'
      @ 19,25 GET MCHOICE2 PICTURE '@!'
      @ 18,54 GET MCHOICE3 PICTURE '@!'
      @ 19,54 GET MCHOICE4 PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,00 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'                     
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 1
         IF DTOC(MSTART) = '  /  /  ' .AND. DTOC(MLAST) = '  /  /  '
            MACTION = 3
         ENDIF
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
      MNOT_DONE = .F.
      LOOP
   ENDIF  
   
   SELECT C
   USE TEMPPROD EXCLUSIVE
   DELETE ALL
   PACK
   IF MSUM_ONLY = 'Y'
      INDEX ON PROD_DESC TO TEMPPROD
   ELSE
      INDEX ON BUY_CODE + PROD_DESC TO TEMPPROD
   ENDIF
   DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .F.
   DO FILELOCK
   
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
   
   
   STORE SPACE(4) TO MBBUYCODE, MRSUPCODE, MBUY_CODE, MSUP_CODE
   
   IF MCHOICE1 = 'X'
      CLEAR
      MWAIT = ' '
      @ 5,1 SAY 'PRESS ENTER TO SELECT REMIT TO SUPPLIER' GET MWAIT
      READ
      MNAME_FD = .F.
      DO RSUPSEL3
      IF .NOT. MNAME_FD
         MCHOICE1 = ' '
      ELSE
         STORE RSUPCODE TO MRSUPCODE
         STORE NAME TO MREM_NAME
         STORE CITY TO MREM_CITY
         STORE STATE TO MREM_STATE
      ENDIF
   ENDIF
   
   IF MCHOICE2 = 'X'
      CLEAR
      MWAIT = ' '
      @ 5,1 SAY 'PRESS ENTER TO SELECT SHIPPED FROM SUPPLIER' GET MWAIT
      READ
      MNAME_FD = .F.
      SET PROC TO SUP_PROC
      DO SUP_SEL1
      IF MNAME_FD 
         STORE SUP_CODE TO MSUP_CODE
         STORE NAME TO MSUP_NAME
         STORE CITY TO MSUP_CITY
         STORE STATE TO MSUP_STATE
      ELSE
         STORE ' ' TO MCHOICE2
      ENDIF
      SET PROC TO
      USE
   ENDIF
   
   IF MCHOICE3 = 'X'
      CLEAR
      MWAIT = ' '
      @ 5,1 SAY 'PRESS ENTER TO SELECT BILL TO CUSTOMER' GET MWAIT
      READ
      MNAME_FD = .F.
      DO BBUYSEL3
      IF .NOT. MNAME_FD
         MCHOICE3 = ' '
      ELSE
         STORE BBUYCODE TO MBBUYCODE
         STORE NAME TO MBIL_NAME
         STORE CITY TO MBIL_CITY
         STORE STATE TO MBIL_STATE
      ENDIF
      USE
   ENDIF
   IF MCHOICE4 = 'X'
      CLEAR
      MWAIT = ' '
      @ 5,1 SAY 'PRESS ENTER TO SELECT SHIP TO CUSTOMER' GET MWAIT
      READ
      MNAME_FD = .F.
      SET PROC TO BUY_PROC
      DO BUY_SEL1
      IF MNAME_FD
         STORE BUY_CODE TO MBUY_CODE
         STORE NAME TO MBUY_NAME
         STORE CITY TO MBUY_CITY
         STORE STATE TO MBUY_STATE
      ELSE
         MCHOICE4 = ' '
      ENDIF
      SET PROC TO 
      USE
   ENDIF
   
   IF MRSUPCODE = SPACE(4) .AND. MSUP_CODE = SPACE(4) .AND. MBBUYCODE = SPACE(4) .AND. MBUY_CODE = SPACE(4)
      MNAME = 'NO SUPPLIER/CUSTOMER SELECTED'
      MCITY = SPACE(20)
      MSTATE = SPACE(2)
   ENDIF
   
   MTITLE = ' - PRODUCT LISTING'
   CLEAR
   @  1, 1  SAY MCOMPANY
   @  1,68 SAY DATE()
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 to 22,79
   
   SELECT C
   DO FILELOCK
   
   *** REPORT IS TOTALED BY SHIP TO CUSTOMER/PRODUCT
   MPRT_ACT = 'C'
   
   IF MDISP_PRT = 'P'
      DO PRT_SET
      
      IF MPRT_ACT <> 'C'
         MNOT_DONE = .F.
         LOOP
      ENDIF
      MPAGE_LEN = 56
   ELSE
      MPAGE_LEN = 20
   ENDIF
   STORE 0 TO MITM_SELL, MITM_NET, MITM_LBS
   
   SELECT A 
   DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP", .F.
   SELECT B
   DO FOX_USE WITH "PO_DTL INDEX  PO_DTL", .F.
   
   MSUB = 0
   STORE 0 TO MP_LBS, MS_LBS, MP_QTY, MS_QTY
   STORE 0 TO MTOT_PURCH, MTOT_SOLD, MQTY_PURCH, MQTY_SOLD
   SELECT A
   SEEK MSTRT_YR + MSTRT_MO
   MLINE = 99 
   @ 19,16 SAY 'PROCESSING........'
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
   
   DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MLAST  
      IF SHIP_DATE < MSTART
         SKIP 
         LOOP
      ENDIF
      IF MRSUPCODE <> SPACE(4)
         IF RSUPCODE <> MRSUPCODE
            SKIP
            LOOP
         ENDIF
      ENDIF
      IF MSUP_CODE <> SPACE(4)
         IF SUP_CODE <> MSUP_CODE
            SKIP
            LOOP
         ENDIF
      ENDIF
      IF MBBUYCODE <> SPACE(4)
         IF BBUYCODE <> MBBUYCODE
            SKIP
            LOOP
         ENDIF
      ENDIF
      IF MBUY_CODE <> SPACE(4)
         IF BUY_CODE <> MBUY_CODE
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      IF RSUPCODE = 'INVN' .AND. BBUYCODE = 'INVN'
         SKIP
         LOOP
      ENDIF
      IF TOT_SELL = 0 .AND. TOT_PURCH = 0
         SKIP
         LOOP
      ENDIF
      
      *** IF THIS IS NOT AN ACTUAL SALE GOING TO A CUSTOMER - SKIP AROUND
      *** (GOING INTO INVENTORY - SKIP)
      *IF BBUYCODE = 'INVN'
      *SKIP
      *LOOP
      *ENDIF
      
      
      SELECT B
      SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
      DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR .AND. PO_SUFFIX = A->PO_SUFFIX
         IF PROD_DESC = SPACE(4) .OR. PROD_DESC = '1100'
            SKIP
            LOOP
         ENDIF
         IF MPROD <> SPACE(10)
            IF MPROD <> PROD_DESC
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         SELECT C
         IF MSUM_ONLY = 'Y'
            SEEK B->PROD_DESC
         ELSE
            SEEK A->BUY_CODE + B->PROD_DESC
         ENDIF
         
         IF EOF()
            APPEND BLANK
            REPLACE PROD_DESC WITH B->PROD_DESC
            REPLACE BUY_CODE  WITH A->BUY_CODE
         ENDIF
         
         IF SUBSTR(B->PACKED,1,1) = 'B'
            STORE VAL(SUBSTR(B->PACKED,2)) TO MCS_WT
         ELSE
            STORE VAL(B->PACKED) TO MCS_WT
         ENDIF
         MLBS = ROUND((MCS_WT * B->QTY),2)
         
         IF MLBS = 0
            MLBS = B->LBS
         ENDIF
         IF A->RSUPCODE <> 'INVN' .AND. B->TOT_PURCH <> 0
            REPLACE TOT_LBS WITH TOT_LBS + B->QTY
            REPLACE LBS_BOT WITH LBS_BOT + MLBS
         ENDIF
         IF A->BBUYCODE <> 'INVN' .AND. B->TOT_SELL <> 0
            REPLACE TOT_SW WITH TOT_SW  + B->QTY
            REPLACE LBS_SOLD WITH LBS_SOLD + MLBS
         ENDIF
         SELECT B
         SKIP
      ENDDO
      SELECT A
      SKIP
   ENDDO
   
   
   MFIRST = .T.
   SELECT E
   DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
   SELECT C
   GOTO TOP
   DO WHILE .NOT. EOF()
      SELECT E
      SEEK C->BUY_CODE
      SELECT C
      REPLACE NAME WITH E->NAME
      SKIP
   ENDDO
   
   SELECT C
   USE TEMPPROD EXCLUSIVE
   IF MSUM_ONLY = 'Y'
      INDEX ON PROD_DESC TO TEMPPROD
   ELSE
      INDEX ON NAME + PROD_DESC TO TEMPPROD
   ENDIF
   
   DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .F.
   DO FILELOCK
   GOTO TOP
   *** DO THE REPORT HERE   
   MPAGE_NO = 0
   MLINE = 99
   STORE 0 TO MTOT_PURCH, MTOT_SOLD, MQTY_PURCH, MQTY_SOLD
   
   IF MSUM_ONLY = 'Y'
      DO WHILE .NOT. EOF()
         IF MLINE > MPAGE_LEN
            IF MDISP_PRT = 'D'
               IF MLINE = 99
                  CLEAR
               ELSE
                  MCONT = 'C'
                  @ 24,1 SAY "PRESS 'ENTER' TO CONTINUE OR 'A' TO CANCEL REPORT " GET MCONT PICTURE '@!'
                  READ
                  IF MCONT = 'A'
                     SELECT C
                     GOTO BOTTOM
                     SKIP
                     LOOP
                  ELSE
                     CLEAR
                  ENDIF
               ENDIF
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,25 SAY MCOMPANY + ' - Report: Spec1'
            @ 1,1 SAY 'Page'
            @ 1,06 say mpage_no picture '99'
            @ 1,60 SAY DTOC(DATE())
            @ 1,72 SAY TIME()
            @ 2,16 SAY '         PRODUCT TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
            MLINE = 3
            IF MRSUPCODE <> SPACE(4)
               @ MLINE,16 SAY '  REMIT TO   SUPPLIER: ' + MREM_NAME
               MLINE = MLINE + 1
               @ MLINE,16 SAY '                       ' + TRIM(MREM_CITY) + ', ' + MREM_STATE
               MLINE = MLINE + 1
            ENDIF
            IF MSUP_CODE <> SPACE(4)
               @ MLINE,16 SAY 'SHIPPED FROM SUPPLIER: ' + MSUP_NAME
               MLINE = MLINE + 1
               @ MLINE,16 SAY '                       ' + TRIM(MSUP_CITY) + ', ' + MSUP_STATE
               MLINE = MLINE + 1
            ENDIF
            IF MBBUYCODE <> SPACE(4)
               @ MLINE,16 SAY '   BILL TO   CUSTOMER: ' + MBIL_NAME
               MLINE = MLINE + 1
               @ MLINE,16 SAY '                       ' + TRIM(MBIL_CITY) + ', ' + MBIL_STATE
               MLINE = MLINE + 1
            ENDIF
            IF MBUY_CODE <> SPACE(4)
               @ MLINE,16 SAY '   SHIP TO   CUSTOMER: ' + MBUY_NAME
               MLINE = MLINE + 1
               @ MLINE,16 SAY '                       ' + TRIM(MBUY_CITY) + ', ' + MBUY_STATE
               MLINE = MLINE + 1
            ENDIF
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'PRODUCT'
            @ MLINE,16 SAY 'PURCHASED QTY   PURCHASED LBS       SOLD QTY       SOLD LBS'
            *              XX,XXX,XXX      XX,XXX,XXX     XX,XXX,XXX     XX,XXX,XXX
            *           56790123456789012345678901234567890123456789012345678901234567890
            *               20        30        40        50        60        70        
            IF MDISP_PRT = 'P'
               @ MLINE,01 SAY REPLICATE('_',80)
            ENDIF
            MLINE = MLINE + 2
         ENDIF
         IF TOT_LBS + LBS_BOT + TOT_SW + LBS_SOLD <> 0 
            @ MLINE,1 SAY PROD_DESC
            @ MLINE,19 SAY TOT_LBS PICTURE '99,999,999'
            @ MLINE,35 SAY LBS_BOT PICTURE '99,999,999'
            @ MLINE,50 SAY TOT_SW PICTURE '99,999,999'
            @ MLINE,65 SAY LBS_SOLD PICTURE '99,999,999'
            MTOT_PURCH = MTOT_PURCH + LBS_BOT
            MTOT_SOLD  = MTOT_SOLD + LBS_SOLD
            MQTY_PURCH = MQTY_PURCH + TOT_LBS
            MQTY_SOLD  = MQTY_SOLD + TOT_SW
            MLINE = MLINE + 2
         ENDIF
         SKIP
      ENDDO
      
      IF MLINE = 99
         IF MDISP_PRT = 'P'
            MPAGE_NO = MPAGE_NO + 1
            @ 1,25 SAY MCOMPANY + ' - Report: Spec1'
            @ 1,1 SAY 'Page'
            @ 1,06 say mpage_no picture '99'
            @ 1,60 SAY DTOC(DATE())
            @ 1,72 SAY TIME()
            @ 2,16 SAY '         PRODUCT TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
            MLINE = 3
            IF MRSUPCODE <> SPACE(4)
               @ MLINE,16 SAY '  REMIT TO   SUPPLIER: ' + MREM_NAME
               MLINE = MLINE + 1
            ENDIF
            IF MSUP_CODE <> SPACE(4)
               @ MLINE,16 SAY 'SHIPPED FROM SUPPLIER: ' + MSUP_NAME
               MLINE = MLINE + 1
            ENDIF
            IF MBBUYCODE <> SPACE(4)
               @ MLINE,16 SAY '   BILL TO   CUSTOMER: ' + MBIL_NAME
               MLINE = MLINE + 1
            ENDIF
            IF MBUY_CODE <> SPACE(4)
               @ MLINE,16 SAY '   SHIP TO   CUSTOMER: ' + MBUY_NAME
               MLINE = MLINE + 1
            ENDIF
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'PRODUCT'
            @ MLINE,16 SAY 'PURCHASED QTY   PURCHASED LBS       SOLD QTY       SOLD LBS'
            IF MDISP_PRT = 'P'
               @ MLINE,01 SAY REPLICATE('_',80)
            ENDIF
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'NO ACTIVITY SELECTED'
            EJECT
         ENDIF
      ELSE
         MLINE = MLINE + 2
         
         IF MDISP_PRT = 'P'
            MLINE = MLINE + 1
            @ MLINE,1 SAY 'GRAND TOTALS:'
            @ MLINE,19 SAY MQTY_PURCH PICTURE '99,999,999'
            @ MLINE,35 SAY MTOT_PURCH PICTURE '99,999,999'
            @ MLINE,50 SAY MQTY_SOLD  PICTURE '99,999,999'
            @ MLINE,65 SAY MTOT_SOLD PICTURE '99,999,999'
            @ mline+1,1 say ' '
            EJECT
         ELSE
            MPRT_SEL = ' '
            @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
            READ
         ENDIF
      ENDIF
      
   ELSE
      
      DO WHILE .NOT. EOF()
         STORE NAME TO MNAME
         STORE BUY_CODE TO MBUY_CODE
         STORE 0 TO MTOT_PURCH, MTOT_SOLD, MQTY_PURCH, MQTY_SOLD
         MPAGE_NO = 0
         MLINE = 99
         SELECT E
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         SEEK MBUY_CODE
         IF NAME = 'NONE' .OR. NAME = 'SAMPLE'
            SELECT C
            SKIP
            LOOP
         ENDIF
         STORE NAME TO MBUY_NAME
         STORE CITY TO MBUY_CITY
         STORE STATE TO MBUY_STATE
         SELECT C
         
         DO WHILE .NOT. EOF() .AND. NAME = MNAME
            
            IF MLINE > MPAGE_LEN
               IF MDISP_PRT = 'D'
                  IF MLINE = 99
                     CLEAR
                  ELSE
                     MCONT = 'C'
                     @ 24,1 SAY "PRESS 'ENTER' TO CONTINUE OR 'A' TO CANCEL REPORT " GET MCONT PICTURE '@!'
                     READ
                     IF MCONT = 'A'
                        SELECT C
                        GOTO BOTTOM
                        SKIP
                        LOOP
                     ELSE
                        CLEAR
                     ENDIF
                  ENDIF
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 1,25 SAY MCOMPANY + ' - Report: Spec1'
               @ 1,1 SAY 'Page'
               @ 1,06 say mpage_no picture '99'
               @ 1,60 SAY DTOC(DATE())
               @ 1,72 SAY TIME()
               @ 2,16 SAY '         PRODUCT TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
               MLINE = 3
               IF MRSUPCODE <> SPACE(4)
                  @ MLINE,16 SAY '  REMIT TO   SUPPLIER: ' + MREM_NAME
                  MLINE = MLINE + 1
                  @ MLINE,16 SAY '                       ' + TRIM(MREM_CITY) + ', ' + MREM_STATE
                  MLINE = MLINE + 1
               ENDIF
               IF MSUP_CODE <> SPACE(4)
                  @ MLINE,16 SAY 'SHIPPED FROM SUPPLIER: ' + MSUP_NAME
                  MLINE = MLINE + 1
                  @ MLINE,16 SAY '                       ' + TRIM(MSUP_CITY) + ', ' + MSUP_STATE
                  MLINE = MLINE + 1
               ENDIF
               IF MBBUYCODE <> SPACE(4)
                  @ MLINE,16 SAY '   BILL TO   CUSTOMER: ' + MBIL_NAME
                  MLINE = MLINE + 1
                  @ MLINE,16 SAY '                       ' + TRIM(MBIL_CITY) + ', ' + MBIL_STATE
                  MLINE = MLINE + 1
               ENDIF
               IF MBUY_CODE <> SPACE(4)
                  @ MLINE,16 SAY '   SHIP TO   CUSTOMER: ' + MBUY_NAME
                  MLINE = MLINE + 1
                  @ MLINE,16 SAY '                       ' + TRIM(MBUY_CITY) + ', ' + MBUY_STATE
                  MLINE = MLINE + 1
               ENDIF
               MLINE = MLINE + 2
               @ MLINE,1 SAY 'PRODUCT'
               @ MLINE,16 SAY 'PURCHASED QTY   PURCHASED LBS       SOLD QTY       SOLD LBS'
               *              XX,XXX,XXX      XX,XXX,XXX     XX,XXX,XXX     XX,XXX,XXX
               *           56790123456789012345678901234567890123456789012345678901234567890
               *               20        30        40        50        60        70        
               IF MDISP_PRT = 'P'
                  @ MLINE,01 SAY REPLICATE('_',80)
               ENDIF
               MLINE = MLINE + 2
            ENDIF
            IF TOT_LBS + LBS_BOT + TOT_SW + LBS_SOLD <> 0 
               @ MLINE,1 SAY PROD_DESC
               @ MLINE,19 SAY TOT_LBS PICTURE '99,999,999'
               @ MLINE,35 SAY LBS_BOT PICTURE '99,999,999'
               @ MLINE,50 SAY TOT_SW PICTURE '99,999,999'
               @ MLINE,65 SAY LBS_SOLD PICTURE '99,999,999'
               MTOT_PURCH = MTOT_PURCH + LBS_BOT
               MTOT_SOLD  = MTOT_SOLD + LBS_SOLD
               MQTY_PURCH = MQTY_PURCH + TOT_LBS
               MQTY_SOLD  = MQTY_SOLD + TOT_SW
               MLINE = MLINE + 2
            ENDIF
            SKIP
         ENDDO
         
         IF MLINE = 99
            IF MDISP_PRT = 'P'
               MPAGE_NO = MPAGE_NO + 1
               @ 1,25 SAY MCOMPANY + ' - Report: Spec1'
               @ 1,1 SAY 'Page'
               @ 1,06 say mpage_no picture '99'
               @ 1,60 SAY DTOC(DATE())
               @ 1,72 SAY TIME()
               @ 2,16 SAY '         PRODUCT TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
               MLINE = 3
               IF MRSUPCODE <> SPACE(4)
                  @ MLINE,16 SAY '  REMIT TO   SUPPLIER: ' + MREM_NAME
                  MLINE = MLINE + 1
               ENDIF
               IF MSUP_CODE <> SPACE(4)
                  @ MLINE,16 SAY 'SHIPPED FROM SUPPLIER: ' + MSUP_NAME
                  MLINE = MLINE + 1
               ENDIF
               IF MBBUYCODE <> SPACE(4)
                  @ MLINE,16 SAY '   BILL TO   CUSTOMER: ' + MBIL_NAME
                  MLINE = MLINE + 1
               ENDIF
               IF MBUY_CODE <> SPACE(4)
                  @ MLINE,16 SAY '   SHIP TO   CUSTOMER: ' + MBUY_NAME
                  MLINE = MLINE + 1
               ENDIF
               MLINE = MLINE + 2
               @ MLINE,1 SAY 'PRODUCT'
               @ MLINE,16 SAY 'PURCHASED QTY   PURCHASED LBS       SOLD QTY       SOLD LBS'
               IF MDISP_PRT = 'P'
                  @ MLINE,01 SAY REPLICATE('_',80)
               ENDIF
               MLINE = MLINE + 2
               @ MLINE,1 SAY 'NO ACTIVITY SELECTED'
               EJECT
            ENDIF
         ELSE
            MLINE = MLINE + 2
            
            IF MDISP_PRT = 'P'
               MLINE = MLINE + 1
               @ MLINE,1 SAY 'GRAND TOTALS:'
               @ MLINE,19 SAY MQTY_PURCH PICTURE '99,999,999'
               @ MLINE,35 SAY MTOT_PURCH PICTURE '99,999,999'
               @ MLINE,50 SAY MQTY_SOLD  PICTURE '99,999,999'
               @ MLINE,65 SAY MTOT_SOLD PICTURE '99,999,999'
               @ mline+1,1 say ' '
               EJECT
            ELSE
               MPRT_SEL = ' '
               @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
               READ
            ENDIF
         ENDIF
      ENDDO
   ENDIF
   
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
   SELECT E
   USE
   
   IF MCHOICE1 = ' ' .AND. MCHOICE2 = ' ' .AND. MCHOICE3 = ' ' .AND. MCHOICE4 = ' '
      MNOT_DONE = .F.
   ENDIF
ENDDO

CLOSE DATA
RETURN  

*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 11:39 AM.
