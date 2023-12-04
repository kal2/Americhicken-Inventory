****************
* Program.: PRODRPTS.PRG
* Author..: GRACE KELLER
* Date....: 01/08/88
* Notice..: Copyright (C) 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRODUCT REPORT MENU    
*
MSECURITY = .F.
MCALLING = 'SUP_PROD'
DO SECURITY
IF .NOT. MSECURITY
   RETURN
ENDIF

MTITLE = ' - PRODUCT AVERAGE PRICES'
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
MOPT_SEL = ' '
@ 10,5 say 'Do you want to select a specific supplier or customer (Y/N)? ' GET MOPT_SEL picture '@!'
READ
IF MOPT_SEL <> 'Y' .AND. MOPT_SEL <> 'N'
   RETURN
ENDIF
IF MOPT_SEL = 'Y'
   STORE ' ' TO MSUP_CUS
   @ 12,5 SAY 'Select Supplier (S) or Customer (C) ? ' get msup_cus picture '@!'
   READ
   IF MSUP_CUS <> 'S' .AND. MSUP_CUS <> 'C'
      RETURN
   ENDIF
   DO CASE
   CASE MSUP_CUS = 'S'
      MNAME_FD = .F.
      DO RSUPSEL3
      IF .NOT. MNAME_FD
         RETURN 
      ENDIF
      STORE RSUPCODE TO MRSUPCODE
      STORE NAME TO MNAME
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
   OTHERWISE
      MNAME_FD = .F.
      DO BBUYSEL3
      IF .NOT. MNAME_FD
         RETURN 
      ENDIF
      STORE BBUYCODE TO MBBUYCODE
      STORE NAME TO MNAME
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
   ENDCASE
ELSE
   STORE SPACE(4) TO MRSUPCODE, MBBUYCODE
   MNAME = 'NO CUSTOMER/SUPPLIER SELECTED'
   STORE SPACE(20) TO MCITY
   STORE SPACE(2) TO MSTATE
ENDIF
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
**** GET FIRST AND LAST DATES FOR THIS REPORT
STORE CTOD(' ') TO MSTART, MLAST
STORE 'P' TO MDISP_PRT
STORE SPACE(10) TO MPROD
STORE SPACE(2) TO MNATURE
@ 5,10 SAY MNAME
@ 6,10 SAY TRIM(MCITY) + ', ' + MSTATE
STORE 2 TO MACTION      
DO WHILE MACTION = 2      
   @ 08,2 say '        BEGINNING DATE: '
   @ 08,27 GET MSTART
   @ 10,2 SAY '           ENDING DATE: '
   @ 10,27 GET MLAST
   @ 12,2 SAY '          PRODUCT CODE: '
   @ 12,27 GET MPROD PICTURE '@!'
   @ 14,2 SAY '            (OPTIONAL)'
   @ 15,2 SAY '   PRODUCT NATURE CODE:'
   @ 15,27 GET MNATURE PICTURE '@!'
   @ 17,2 SAY 'DISPLAY OR PRINT (D/P): '
   @ 17,27 GET MDISP_PRT PICTURE '@!'
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
         LOOP
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
      
      IF MPROD <> SPACE(4)
         IF MPROD = 'TENDERS'
            STORE 'TENDERS' TO MDESCR
         ELSE
            
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
            SEEK 'R' + MPROD
            IF EOF()
               @ 24,0       
               @ 24,1 SAY 'ERROR: PRODUCT CODE INVALID - PRESS RETURN TO REENTER'
               MSPACE = ' '
               @ 24,78 GET MSPACE
               READ
               @ 24,0 
               MACTION = 2
               LOOP
            ELSE
               STORE DESC TO MDESCR
            ENDIF
         ENDIF
      ENDIF
      IF MNATURE <> SPACE(2)
         IF MNATURE <> 'FR' .AND. MNATURE <> 'FH' 
            @ 24,0       
            @ 24,1 SAY 'ERROR: PRODUCT NATURE CODE INVALID - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            MACTION = 2
            LOOP
         ENDIF  
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
SELECT C 
DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX  BBUYCODE", .F.
SELECT B 
DO FOX_USE WITH "PO_DTL INDEX  PO_DTL", .F.
SELECT A 
DO FOX_USE WITH "PO_HEAD INDEX  PO_SHIP", .F.


MTOT_DLRS = 0
MTOT_LBS = 0
MTOT_SELL = 0
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
   
   *** PRINT IN 10 CPI
   ?? chr(27) + '&k0S'
   
   *** LETTER GOTHIC AND BOLDED PRINT
   ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
   
   *** LETTER SIZE PAPER
   ?? CHR(27) + '&l2A'
   
   *** PORTRAIT MODE
   ?? CHR(27) + '&l0O'
   
ENDIF

DO CASE
CASE MPROD <> SPACE(4)
   
   MLINE = 99
   MTOT_PURCH = 0
   MTOT_LBS = 0
   MTOT_SELL = 0
   MHIGH_BOT = 0
   MHBOT_DT = CTOD(' ')
   MLOW_BOT = 99999 
   MLBOT_DT = CTOD(' ')
   
   MHIGH_SOLD = 0
   MHSOLD_DT = CTOD(' ')
   MHIGH_CUST = SPACE(32)
   MLOW_SOLD = 99999
   MLSOLD_DT = CTOD(' ')
   MLOW_CUST = SPACE(32)
   DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MLAST
      IF BBUYCODE = 'NONE' .OR. BBUYCODE = 'INVN'
         SKIP
         LOOP
      ENDIF
      IF MOPT_SEL = 'Y'
         DO CASE
         CASE MSUP_CUS = 'S'
            IF RSUPCODE <> MRSUPCODE
               SKIP
               LOOP
            ENDIF
         OTHERWISE
            IF BBUYCODE <> MBBUYCODE
               SKIP
               LOOP
            ENDIF
         ENDCASE
      ENDIF
      STORE SALESMAN TO MSALESMAN
      STORE PO_NBR TO MPO_NBR
      STORE PO_SUFFIX TO MPO_SUFFIX
      
      SELECT B
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
         IF MPROD = 'TENDERS'
            IF PROD_DESC = '8901' .OR. PROD_DESC = '8910' .OR. PROD_DESC = '8989' .OR. PROD_DESC = '8999'
            ELSE
               SKIP
               LOOP
            ENDIF
         ELSE
            IF PROD_DESC <> MPROD
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         IF MNATURE <> SPACE(2)
            IF FRH_FRZ <> MNATURE 
               SKIP
               LOOP
            ENDIF
         ENDIF
         IF PUR_PRICE = 0 .OR. SEL_PRICE = 0 
            SKIP
            LOOP
         ENDIF
         MLINE = MLINE + 1
         IF BILL_PRI = 0
            STORE PUR_PRICE TO MPRICE
         ELSE
            STORE BILL_PRI TO MPRICE
         ENDIF
         IF TOT_BILL = 0
            STORE TOT_PURCH TO MPURCH
         ELSE
            STORE TOT_BILL TO MPURCH
         ENDIF
         MTOT_PURCH = MTOT_PURCH + MPURCH   
         MTOT_SELL = MTOT_SELL + TOT_SELL
         MTOT_LBS = MTOT_LBS + LBS
         IF MPRICE > 0 .AND. QTY > 0 
            IF MPRICE < MLOW_BOT
               STORE MPRICE TO MLOW_BOT
               STORE A->SHIP_DATE TO MLBOT_DT   
            ENDIF
            IF MPRICE > MHIGH_BOT
               STORE MPRICE TO MHIGH_BOT
               STORE A->SHIP_DATE TO MHBOT_DT  
            ENDIF 
         ENDIF
         IF SEL_PRICE > 0 .AND. QTY > 0  
            IF SEL_PRICE < MLOW_SOLD
               STORE SEL_PRICE TO MLOW_SOLD
               STORE A->SHIP_DATE TO MLSOLD_DT   
               SELECT C
               SEEK A->BBUYCODE
               IF .NOT. EOF()
                  STORE NAME TO MCUST_NAME
               ELSE
                  STORE 'CUST NOT ON FILE' TO MCUST_NAME
               ENDIF
               STORE MCUST_NAME TO MLOW_CUST
            ENDIF
            IF B->SEL_PRICE > MHIGH_SOLD
               STORE B->SEL_PRICE TO MHIGH_SOLD
               STORE A->SHIP_DATE TO MHSOLD_DT   
               SELECT C
               SEEK A->BBUYCODE
               IF .NOT. EOF()
                  STORE NAME TO MCUST_NAME
               ELSE
                  STORE 'CUST NOT ON FILE' TO MCUST_NAME
               ENDIF
               STORE MCUST_NAME TO MHIGH_CUST
            ENDIF 
         ENDIF
         SELECT B
         SKIP
      ENDDO
      SELECT A
      SKIP
   ENDDO
   
   MLINE = 70 
   DO CASE
   CASE MNATURE = 'FR'
      STORE 'FROZEN' TO MNATURE
   CASE MNATURE = 'FH'
      STORE 'FRESH' TO MNATURE
   CASE MNATURE = '  '
      STORE 'FRESH AND FROZEN' TO MNATURE
   ENDCASE
   IF MLINE > MPAGE_LEN
      IF MDISP_PRT <> 'P'
         CLEAR
      ENDIF
      MPAGE_NO = MPAGE_NO + 1
      @ 1,27 SAY MCOMPANY
      @ 2,1 SAY 'Page'
      @ 2,06 say mpage_no picture '99'
      @ 2,13 SAY '         PRODUCTS AVERAGE FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
      @ 2,70 SAY DTOC(DATE())
      @ 3,13 SAY '         PRODUCT: ' + MDESCR
      @ 3,70 SAY TIME()
      @ 4,13 SAY '         PRODUCT NATURE: ' + MNATURE
      @ 5,22 SAY MNAME
      @ 6,22 SAY TRIM(MCITY) + ', ' + MSTATE
      IF MDISP_PRT = 'P'
         @ 6,01 SAY REPLICATE('_',77)
      ENDIF
      MLINE = 8
   ENDIF
   @ MLINE,10 SAY 'TOTAL POUNDS     TOTAL PURCHASE $    TOTAL SELLING $      ITEMS NET'
   MLINE = MLINE + 2
   @ MLINE,09 SAY MTOT_LBS PICTURE '999,999,999.99'
   @ MLINE,27 SAY MTOT_PURCH PICTURE '999,999,999.99' 
   @ MLINE,47 SAY MTOT_SELL PICTURE '999,999,999.99'
   @ MLINE,65 SAY MTOT_SELL - MTOT_PURCH PICTURE '9,999,999.99'
   MLINE = MLINE + 3
   @ MLINE,1 SAY 'HIGHEST PRICE BOUGHT   DATE      LOWEST PRICE BOUGHT    DATE         AVG PURCH'
   MLINE = MLINE + 1
   IF DTOC(MHBOT_DT) = '  /  /  '
      @ MLINE,7 SAY '00.0000'
   ELSE
      @ MLINE,7 SAY MHIGH_BOT PICTURE '99.9999'
   ENDIF
   @ MLINE,22 SAY MHBOT_DT
   IF DTOC(MLBOT_DT) = '  /  /  '
      @ MLINE,41 SAY '00.0000'
   ELSE
      @ MLINE,41 SAY MLOW_BOT PICTURE '99.9999'
   ENDIF
   @ MLINE,55 SAY MLBOT_DT
   IF MTOT_LBS = 0 .OR. MTOT_PURCH = 0
      @ MLINE,70 SAY '00.0000'
   ELSE
      MAVG = MTOT_PURCH / MTOT_LBS
      MAVG = ROUND(MAVG,4)
      @ MLINE,70 SAY MAVG PICTURE '99.9999'
   ENDIF
   MLINE = MLINE + 3
   
   @ MLINE,1 SAY 'HIGHEST PRICE SOLD     DATE      LOWEST PRICE SOLD      DATE        AVG SELLING'
   MLINE = MLINE + 1
   IF DTOC(MHSOLD_DT) = '  /  /  '
      @ MLINE,7 SAY '00.0000'
   ELSE
      @ MLINE,7 SAY MHIGH_SOLD PICTURE '99.9999'
   ENDIF
   @ MLINE,22 SAY MHSOLD_DT
   IF DTOC(MLSOLD_DT) = '  /  /  '
      @ MLINE,41 SAY '00.0000'
   ELSE
      @ MLINE,41 SAY MLOW_SOLD PICTURE '99.9999'
   ENDIF
   @ MLINE,55 SAY MLSOLD_DT
   IF MTOT_SELL = 0 .OR. MTOT_LBS = 0
      @ MLINE,70 SAY '00.0000'
   ELSE
      MAVG = MTOT_SELL / MTOT_LBS
      MAVG = ROUND(MAVG,4)
      @ MLINE,70 SAY MAVG PICTURE '99.9999'
   ENDIF
   MLINE = MLINE + 1
   @ MLINE,1 SAY MHIGH_CUST
   @ MLINE,34 SAY MLOW_CUST
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
   
ENDCASE
CLOSE DATA
RETURN
** EOF: AVG_PRI.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/8/15 at 1:02 PM.
