************
* Program.: AMERISUM.PRG
* Author..: GRACE KELLER
* Date....: 10/25/2010
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: POUNDS BY PRODUCT SUMMARY            
*
MTITLE = ' - PRODUCT SUMMARY'              
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 23,79
STORE SPACE(4) TO MYEAR
STORE 0 TO MCOUNT
STORE 'D' TO MSUM_ONLY
STORE 'P' TO MPRT_TYPE
STORE 'A' TO MGRP_OPT
store 'N' to myes_no
STORE 'E' TO MALL_PRODS
STORE 'P' TO MSEL_TYPE

store space(4) to mopt_buyer
store 'N'  TO MYES_BROKR
STORE '  ' TO MOPT_BROKR
store space(10) to mopt_prod
STORE 2 TO MACTION
DO WHILE MACTION = 2      
   @ 05,2 say '        Select Report Year: ' GET MYEAR PICTURE '####'
   @ 07,2 say 'Select Cutoff/Closed Month: ' GET MCOUNT PICTURE '##'
   @ 09,2 SAY 'Include ALL (A) Products -or- EXCLUDE Marked Products (E):' GET MALL_PRODS PICTURE '@!' VALID(MALL_PRODS = 'A' .OR. MALL_PRODS = 'E')
   @ 11,2 SAY 'Summary Only (S) -or- Detail Report (D) too: ' GET MSUM_ONLY PICTURE '@!' VALID(MSUM_ONLY = 'S' .OR. MSUM_ONLY = 'D')
   ***@ 13,2 SAY 'Print Report (P) -or- Create Print File (F): ' GET MPRT_TYPE PICTURE '@!' VALID(MPRT_TYPE = 'P' .OR. MPRT_TYPE = 'F') 
   @ 13,2 SAY 'On Summary - Print All Products (A) - or - Product Groups (G): ' GET MGRP_OPT PICTURE '@!' VALID(MGRP_OPT = 'A' .OR. MGRP_OPT = 'G') 
   @ 15,2 SAY 'Select (P)ounds, (S)ales$ -or- (N)et$ : ' GET MSEL_TYPE PICTURE '@!' VALID(MSEL_TYPE = 'P' .OR. MSEL_TYPE = 'S' .OR. MSEL_TYPE = 'N')
   @ 17,2 say 'Select Optional Ship To Customer (Y/N): ' GET MYES_NO PICTURE "@!" valid(myes_no = 'Y' .or. myes_no = 'N')
   @ 19,2 say '          Select Optional Broker (Y/N): ' GET MYES_BROKR PICTURE "@!" valid(myes_BROKR = 'Y' .or. myes_BROKR = 'N')
   @ 21,2 say '               Select Optional Product: ' get mopt_prod picture '@!'
   STORE 1 TO MACTION
   @ 24,00 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'                     
   READ
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ
   IF MACTION = 1
      IF VAL(MYEAR) > YEAR(DATE())
         @ 24,0 CLEAR
         STORE 'INVALID YEAR SELECTED - PRESS RETURN TO REENTER' TO MWAIT
         @ 24,1 GET MWAIT
         READ
         @ 24,0 CLEAR
         MACTION = 2
         LOOP
      ENDIF
   ENDIF
ENDDO
IF MACTION = 3
   RETURN 
ENDIF  
IF MCOUNT <= 0
   MCOUNT = 1
ENDIF
If myes_no = 'Y'
   SAVE SCREEN TO MGRACE
   CLEAR
   MWAIT = ' '
   @ 5,1 SAY 'PRESS ENTER TO SELECT SHIP TO CUSTOMER' GET MWAIT
   READ
   MNAME_FD = .F.
   SET PROC TO BUY_PROC
   DO BUY_SEL1
   SET PROC TO 
   RESTORE SCREEN FROM MGRACE
   IF MNAME_FD
      STORE BUY_CODE TO MOPT_BUYER
      USE
   ELSE
      USE
      @ 24,0 clear
      mwait = ' '
      @ 24,1 say 'No Ship To Customer Selected - Press Return to Exit' get Mwait
      read
      RETURN
   ENDIF
ENDIF

If MYES_BROKR = 'Y'
   SAVE SCREEN TO MGRACE
   CLEAR
   MWAIT = ' '
   @ 5,1 SAY 'PRESS ENTER TO SELECT OPTIONAL THIRD PARTY BROKER/BILLBACK' GET MWAIT
   READ
   *** GET THE RIGHT COMMISSION PAYEE
   MNAME_FD = .F.
   DO COM_SEL1
   RESTORE SCREEN FROM MGRACE
   IF MNAME_FD
      STORE COM_CODE TO MOPT_BROKR
      USE
   ELSE
      USE
      @ 24,0 clear
      mwait = ' '
      @ 24,1 say 'No broker/billback Selected - Press Return to Exit' get Mwait
      read
      RETURN
   ENDIF
ENDIF

SELECT F
DO FOX_USE WITH "PRT_NOTE INDEX PRT_NOTE", .F.

SELECT E
DO FOX_USE WITH "&MDBFLOC.BUYER INDEX  &MDBFLOC.BUY_CODE", .F.

SELECT D
DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX  &MDBFLOC.PRODUCTS", .F.

SELECT C
USE AMERISUM EXCLUSIVE         
DELETE ALL
PACK
INDEX ON PROD_DESC + BUY_CODE TO AMERISUM
INDEX ON PROD_GRP  TO AMERISM2

USE
USE AMERISUM INDEX AMERISUM, AMERISM2 EXCLUSIVE

SELECT B 
DO FOX_USE WITH "PO_DTL INDEX  PO_DTL", .F.
** PER CELINDA/MATT - 3/30/17 - SKIP IF NEGATIVE QTY - RETURNED PRODUCT
if mopt_prod <> space(10)
   SET FILTER TO QTY > 0 .AND. PROD_DESC = mopt_prod
else
   SET FILTER TO QTY > 0
endif
GOTO TOP

SELECT A 
DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP", .F.

IF MOPT_BUYER <> SPACE(4)
   SET FILTER TO BUY_CODE = MOPT_BUYER
   GOTO TOP
ENDIF

SEEK MYEAR
MPRT_ACT = 'C'

IF MPRT_TYPE = 'P'
   DO PRT_SET
   IF MPRT_ACT <> 'C'
      CLOSE DATA
      RETURN
   ENDIF
ENDIF

MPAGE_LEN = 60

@ 19,16 SAY 'CALCULATING .... PLEASE WAIT..'

DO WHILE .NOT. EOF() .AND. YEAR(SHIP_DATE) <= VAL(MYEAR)
   *** IF ONLY PUTTING INTO INVENTORY - SKIP - DONT COUNT AS SALE 
   IF BBUYCODE = 'INVN' .OR. BBUYCODE = 'NONE'
      SKIP
      LOOP
   ENDIF
   *** SKIP THESE
   *** BUYER = NONE OR BUY_CODE = 345 (LOCAL SALES) OR BUY_CODE = 49 (SAMPLE)
   *** BUYER = 460 (DONATION)
   IF BUY_CODE = 'NONE' .OR. BUY_CODE = ' 345' .OR. BUY_CODE = '  49' .OR. BUY_CODE = ' 460'
      SKIP
      LOOP
   ENDIF
   IF PO_SUFFIX = 'R'
      SKIP
      LOOP
   ENDIF
   IF BROKERAGE = 'H'
      SKIP
      LOOP
   ENDIF
   IF MONTH(SHIP_DATE) > MCOUNT
      SKIP
      LOOP
   ENDIF

   ** Check Optional Broker
   IF MOPT_BROKR <> '  '
      IF MOPT_BROKR = COM_CODE .OR. MOPT_BROKR = COM_CODE2 .OR. MOPT_BROKR = COM_CODE3
      ELSE
        SKIP
        LOOP
      ENDIF
   ENDIF
   *** 3/30/17-IF SUPPLIER IS INVENTORY-CUSTOMER IS EMMAUS (436)-BAD PRODUCT
   IF RSUPCODE = 'INVN' .AND. BBUYCODE = ' 436'
      SKIP
      LOOP
   ENDIF

   STORE SALESMAN TO MSALESMAN
   STORE PO_NBR TO MPO_NBR
   STORE PO_SUFFIX TO MPO_SUFFIX
   
   ** CHECK TO SEE IF SHOULD EXCLUDE FROM MONTHLY REPORT
   
   SELECT F
   SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
   IF .NOT. EOF()     
      IF SUP_COMMT = 'EXCLUDE'
         SELECT A
         SKIP
         LOOP
      ENDIF
   ENDIF
   
   *** CHECK PURCHASE ORDER DETAIL
   SELECT B           
   SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
   
   DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
      IF LBS = 0
         SKIP
         LOOP
      ENDIF
      
      SELECT D
      SEEK 'R' + B->PROD_DESC
      IF EOF()
         SELECT B
         SKIP
         LOOP
      ENDIF
      
      IF MALL_PRODS = 'A'
      ELSE
         IF INC_MOSUM <> 'Y'
            SELECT B
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      IF PROD_RPT = SPACE(10)
         STORE CODE TO MPROD_RPT
      ELSE
         STORE PROD_RPT TO MPROD_RPT
      ENDIF
      
      IF PROD_GRP = SPACE(10)
         STORE CODE TO MPROD_GRP
      ELSE
         STORE PROD_GRP TO MPROD_GRP
      ENDIF
      
      SELECT C
      **SEEK  B->PROD_DESC + A->BUY_CODE
      SEEK  MPROD_RPT + A->BUY_CODE
      IF EOF()
         APPEND BLANK
         REPLACE BUY_CODE WITH A->BUY_CODE
         **REPLACE PROD_DESC WITH B->PROD_DESC
         REPLACE PROD_DESC WITH MPROD_RPT
         REPLACE PROD_GRP  WITH MPROD_GRP
      ENDIF
      DO CASE
      CASE SUBSTR(B->PACKED,1,1) = 'B' .OR. SUBSTR(B->PACKED,1,1) = 'H'
         MLBS = (VAL(SUBSTR(B->PACKED,2))*B->QTY)
      OTHERWISE 
         MLBS = B->LBS         
      ENDCASE
      MI = MONTH(A->SHIP_DATE)
      MI = SUBSTR(STR(MI+100,3),2)
      
      DO CASE
      CASE MSEL_TYPE = 'P'
         ** REPORT SELECTION - POUNDS
         REPLACE LBS&MI WITH LBS&MI + MLBS
      CASE MSEL_TYPE = 'S'
         ** REPORT SELECTION - SALES DOLLARS
         REPLACE LBS&MI WITH LBS&MI + B->TOT_SELL
      OTHERWISE
         ** REPORT SELECTION - PRORATED NET DOLLARS
         IF A->TOT_LBS = 0
            MFRT_LB = 0
         ELSE
            MFRT_LB = (A->FRT_AMT1+A->FRT1_ADJ1+A->FRT1_ADJ2+A->FRT_PALL) / A->TOT_LBS
         ENDIF

         MITM_FRT = ROUND(B->CALC_LBS * MFRT_LB,2)
         MCOMM    = ROUND(B->QTY*(B->COM1_CENT+B->COM2_CENT+B->COM3_CENT),2)
         MPRO_COST = B->PUR_PRICE + MITM_FRT + MCOMM 
         MITM_NET = B->TOT_SELL - MPRO_COST
         REPLACE LBS&MI WITH LBS&MI + MITM_NET
      ENDCASE
      
      *** GET THE CUSTOMER NAME
      SELECT E
      SEEK  A->BUY_CODE
      IF EOF()
         SELECT C
         REPLACE BUY_NAME WITH 'CUSTOMER SHIP TO NOT ON FILE'
         STORE SPACE(4) TO MGRP_CODE
         REPLACE GRP_CODE WITH MGRP_CODE
      ELSE
         SELECT C
         REPLACE BUY_NAME WITH E->NAME
         STORE E->GRP_CODE TO MGRP_CODE
         STORE E->GRP_DESC TO MGRP_DESC
         REPLACE GRP_CODE WITH MGRP_CODE
      ENDIF
      
      *** NOW CHECK FOR GROUP CODES - GROUPING CUSTOMERS ON ONE REPORT
      IF MGRP_CODE <> SPACE(4)
         SELECT C
         **SEEK  B->PROD_DESC + MGRP_CODE
         SEEK  MPROD_RPT + MGRP_CODE
         IF EOF()
            APPEND BLANK
            REPLACE BUY_CODE WITH MGRP_CODE
            ***REPLACE PROD_DESC WITH B->PROD_DESC
            REPLACE PROD_DESC WITH MPROD_RPT
            REPLACE GRP_RCD WITH 'Y'
         ENDIF
         DO CASE
         CASE SUBSTR(B->PACKED,1,1) = 'B' .OR. SUBSTR(B->PACKED,1,1) = 'H'
            MLBS = (VAL(SUBSTR(B->PACKED,2))*B->QTY)
         OTHERWISE 
            MLBS = B->LBS         
         ENDCASE
         MI = MONTH(A->SHIP_DATE)
         MI = SUBSTR(STR(MI+100,3),2)
         DO CASE
         CASE MSEL_TYPE = 'P'
            ** REPORT SELECTION - POUNDS
            REPLACE LBS&MI WITH LBS&MI + MLBS
         CASE MSEL_TYPE = 'S'
            ** REPORT SELECTION - SALES DOLLARS
            REPLACE LBS&MI WITH LBS&MI + B->TOT_SELL
         OTHERWISE
            ** REPORT SELECTION - PRORATED NET DOLLARS
            IF A->TOT_LBS = 0
               MFRT_LB = 0
            ELSE
               MFRT_LB = (A->FRT_AMT1+A->FRT1_ADJ1+A->FRT1_ADJ2+A->FRT_PALL) / A->TOT_LBS
            ENDIF
            MITM_FRT = ROUND(B->CALC_LBS * MFRT_LB,2)
            MCOMM    = ROUND(B->QTY*(B->COM1_CENT+B->COM2_CENT+B->COM3_CENT),2)
            MPRO_COST = B->PUR_PRICE + MITM_FRT + MCOMM 
            MITM_NET = B->TOT_SELL - MPRO_COST
            REPLACE LBS&MI WITH LBS&MI + MITM_NET
         ENDCASE
         
         REPLACE BUY_NAME WITH TRIM(MGRP_DESC) +  ' CUST GROUP'
      ENDIF
      SELECT B
      SKIP
   ENDDO
   
   SELECT A
   SKIP
ENDDO

SET CONSOLE OFF
IF FILE("C:\COMPINFO\PRINTERS.DBF")
   SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
ELSE
   SET PRINT TO LPT3
ENDIF
SET DEVICE TO PRINT
SET PRINT ON

IF MPRT_TYPE = 'P'
   *** LEGAL SIZE PAPER
   ?? CHR(27) + '&l3A'
   
   *** LANDSCAPE MODE
   ?? CHR(27) + '&l1O'
   
   *** FONT ARIAL BOLD
   ?? CHR(27) + '(s1p10v0s3b16602T'
   
   *** POINT HEIGHT 16 - DEFAULT IS 12
   ?? CHR(27) + '(s13V'
ENDIF


IF MPRT_TYPE = 'P'
   *** FONT COURIER BOLD
   ?? CHR(27) + '(s0ph0s3b4099T'
   
   *** PRINT IN 12 CPI
   ?? chr(27) + '&k4S'
   
   *** PRINT IN 6 LINES/INCH VERTICAL
   *?? chr(27) + '&l6D'
   
   *** PRINT IN 8 LINES PER IN/VERTICAL
   ?? chr(27) + '&l8D'
ENDIF
SELECT C
GOTO TOP

IF MOPT_BUYER = SPACE(4)
   DO CASE
   CASE MSEL_TYPE = 'P'
      ?? '   AmeriChicken Sales Report       Total Pounds     Year: ' + MYEAR
   CASE MSEL_TYPE = 'S'
      ?? '   AmeriChicken Report             Total Sales $    Year: ' + MYEAR
   OTHERWISE
      ?? '   AmeriChicken Report             Total Net $      Year: ' + MYEAR
   ENDCASE
   *?
   ? '  PRODUCT       JANUARY  FEBRUARY     MARCH     APRIL       MAY      JUNE      JULY    AUGUST'
   ?? ' SEPTEMBER   OCTOBER  NOVEMBER  DECEMBER       TOTAL   AVERAGE'
   **?
   I = 1
   DO WHILE I <= 12             
      MI = SUBSTR(STR(I+100,3),2)
      MTOT_LBS&MI = 0
      I = I + 1
   ENDDO
   
   *** select RBG simple color palette
   ?? CHR(27) + '*r3U'
   
   MBLACK = .T.
   DO CASE
   CASE MGRP_OPT = 'A'
      GOTO TOP
      DO WHILE .NOT. EOF()
         STORE PROD_DESC TO MPROD_DESC
         I = 1
         DO WHILE I <= 12             
            MI = SUBSTR(STR(I+100,3),2)
            MLBS&MI = 0
            I = I + 1
         ENDDO
         
         DO WHILE .NOT. EOF() .AND. PROD_DESC = MPROD_DESC
            I = 1
            DO WHILE I <= 12
               MI = SUBSTR(STR(I+100,3),2)
               IF GRP_RCD <> 'Y'
                  MLBS&MI = MLBS&MI + LBS&MI
                  MTOT_LBS&MI = MTOT_LBS&MI + LBS&MI
               ENDIF
               I = I + 1
            ENDDO
            SKIP
         ENDDO
         
         *** UNDERLINE OFF
         ?? CHR(27) + '&d@'
         ? SPACE(2)
         *** UNDERLINE ON
         ?? CHR(27) + '&d0D'
         
         IF MBLACK
            *** FONT COURIER BOLD
            ?? CHR(27) + '(s0ph0s3b4099T'
            
            *** PRINT IN 12 CPI
            ?? chr(27) + '&k4S'
            
            *** PRINT IN 8 LINES PER IN/VERTICAL
            ?? chr(27) + '&l8D'
            MBLACK = .F.
         ELSE
            *** FONT COURIER
            ?? CHR(27) + '(s0p10h0s0b4099T'
            *** PRINT IN 12 CPI
            ?? chr(27) + '&k4S'
            
            *** PRINT IN 8 LINES PER IN/VERTICAL
            ?? chr(27) + '&l8D'
            MBLACK = .T.
         ENDIF
         
         *IF MBLACK
         *   *** PRINT IN black
         *   ?? chr(27) + '*v0S'
         *   MBLACK = .F.
         *ELSE
         *   *** PRINT IN red
         *   **?? CHR(27) + '*v1S'
         *   
         *   *** PRINT IN blue
         *   **?? CHR(27) + '*v4S'
         *   
         *   *** PRINT IN magenta
         *   **?? CHR(27) + '*v5S'
         *   
         *   *** PRINT IN cyan
         *   ?? CHR(27) + '*v6S'
         *   
         *   MBLACK = .T.
         *ENDIF
         
         ?? MPROD_DESC + SPACE(2)
         MTOTAL = 0
         I = 1
         DO WHILE I<= 12
            MI = SUBSTR(STR(I+100,3),2)
            ??  TRANSFORM(MLBS&MI, '9,999,999') + SPACE(1)
            MTOTAL = MTOTAL + MLBS&MI
            I = I + 1
         ENDDO
         ?? SPACE(1)
         ?? TRANSFORM(MTOTAL, '99,999,999') + SPACE(2)
         MAVG = ROUND(MTOTAL/MCOUNT,0)
         ?? TRANSFORM(MAVG, '9,999,999')
      ENDDO
      
   OTHERWISE
      SET ORDER TO 2
      GOTO TOP
      DO WHILE .NOT. EOF()
         STORE PROD_GRP TO MPROD_DESC
         I = 1
         DO WHILE I <= 12             
            MI = SUBSTR(STR(I+100,3),2)
            MLBS&MI = 0
            I = I + 1
         ENDDO
         
         DO WHILE .NOT. EOF() .AND. PROD_GRP = MPROD_DESC
            I = 1
            DO WHILE I <= 12
               MI = SUBSTR(STR(I+100,3),2)
               IF GRP_RCD <> 'Y'
                  MLBS&MI = MLBS&MI + LBS&MI
                  MTOT_LBS&MI = MTOT_LBS&MI + LBS&MI
               ENDIF
               I = I + 1
            ENDDO
            SKIP
         ENDDO
         
         *** UNDERLINE OFF
         ?? CHR(27) + '&d@'
         ? SPACE(2)
         *** UNDERLINE ON
         ?? CHR(27) + '&d0D'
         
         IF MBLACK
            *** FONT COURIER BOLD
            ?? CHR(27) + '(s0ph0s3b4099T'
            
            *** PRINT IN 12 CPI
            ?? chr(27) + '&k4S'
            
            *** PRINT IN 8 LINES PER IN/VERTICAL
            ?? chr(27) + '&l8D'
            MBLACK = .F.
         ELSE
            *** FONT COURIER
            ?? CHR(27) + '(s0p10h0s0b4099T'
            *** PRINT IN 12 CPI
            ?? chr(27) + '&k4S'
            
            *** PRINT IN 8 LINES PER IN/VERTICAL
            ?? chr(27) + '&l8D'
            MBLACK = .T.
         ENDIF
         
         *IF MBLACK
         *   *** PRINT IN black
         *   ?? chr(27) + '*v0S'
         *   MBLACK = .F.
         *ELSE
         *   *** PRINT IN red
         *   **?? CHR(27) + '*v1S'
         *   
         *   *** PRINT IN blue
         *   **?? CHR(27) + '*v4S'
         *   
         *   *** PRINT IN magenta
         *   **?? CHR(27) + '*v5S'
         *   
         *   *** PRINT IN cyan
         *   ?? CHR(27) + '*v6S'
         *   
         *   MBLACK = .T.
         *ENDIF
         
         ?? MPROD_DESC + SPACE(2)
         MTOTAL = 0
         I = 1
         DO WHILE I<= 12
            MI = SUBSTR(STR(I+100,3),2)
            ??  TRANSFORM(MLBS&MI, '9,999,999') + SPACE(1)
            MTOTAL = MTOTAL + MLBS&MI
            I = I + 1
         ENDDO
         ?? SPACE(1)
         ?? TRANSFORM(MTOTAL, '99,999,999') + SPACE(1)
         MAVG = ROUND(MTOTAL/MCOUNT,0)
         ?? TRANSFORM(MAVG, '9,999,999')
      ENDDO
      
   ENDCASE
   
   ****** COLOR
   *** PRINT IN black
   *** ?? chr(27) + '*v0S'
   
   *** DO SUMMARY TOTALS HERE
   ?
   *** UNDERLINE OFF
   ?? CHR(27) + '&d@'
   ? SPACE(2)
   *** UNDERLINE ON
   ?? CHR(27) + '&d0D'
   
   ?? 'TOTALS    ' + SPACE(2)
   MTOTAL = 0
   I = 1
   DO WHILE I<= 12
      MI = SUBSTR(STR(I+100,3),2)
      ??  TRANSFORM(MTOT_LBS&MI, '9,999,999') + SPACE(1)
      MTOTAL = MTOTAL + MTOT_LBS&MI
      I = I + 1
   ENDDO
   ?? SPACE(1)
   ?? TRANSFORM(MTOTAL, '99,999,999') + SPACE(1)
   MAVG = ROUND(MTOTAL/MCOUNT,0)
   ?? TRANSFORM(MAVG, '9,999,999')
   EJECT
   
ENDIF

*** UNDERLINE OFF
?? CHR(27) + '&d@'

*** RESET TO FACTORY SETTINGS
*** COLOR ?? CHR(27) + 'E'

*** LEGAL SIZE PAPER
?? CHR(27) + '&l3A'

*** LANDSCAPE MODE
?? CHR(27) + '&l1O'

*** PRINT IN 8 LINES PER IN/VERTICAL
?? chr(27) + '&l8D'




*** NOW CHECK TO SEE IF DETAIL REPORTS NEEDED
IF MSUM_ONLY <> 'S'
   
   SELECT C
   USE AMERISUM EXCLUSIVE
   INDEX ON BUY_NAME + BUY_CODE + PROD_DESC TO AMERISM1
   USE AMERISUM INDEX AMERISM1 EXCLUSIVE
   
   MLINE = 99
   
   DO WHILE .NOT. EOF()
      STORE BUY_NAME TO MBUY_NAME
      STORE BUY_CODE TO MBUY_CODE
      STORE GRP_CODE TO MGRP_CODE
      I = 1
      DO WHILE I <= 12             
         MI = SUBSTR(STR(I+100,3),2)
         MTOT_LBS&MI = 0
         I = I + 1
      ENDDO
      
      STORE RECNO() TO MRECNO
      COUNT FOR BUY_NAME+BUY_CODE = MBUY_NAME+MBUY_CODE TO MLN_COUNT
      GOTO MRECNO
      IF MLINE <> 99
         IF (MLN_COUNT*2) + 14 > 56 - MLINE
            EJECT
            MLINE = 0
         ENDIF
      ELSE
         MLINE = 0
      ENDIF
      
      *** DO THE HEADING
      IF MPRT_TYPE = 'P'
         *** UNDERLINE OFF
         ?? CHR(27) + '&d@'
         
         *** FONT ARIAL BOLD
         ?? CHR(27) + '(s1p10v0s3b16602T'
         
         *** POINT HEIGHT 16 - DEFAULT IS 12
         ?? CHR(27) + '(s16V'
      ENDIF
      DO CASE
      CASE MSEL_TYPE = 'P'
         ? '   ' + MYEAR + ' AmeriChicken Sales Pounds for: ' + MBUY_NAME
      CASE MSEL_TYPE = 'S'
         ? '   ' + MYEAR + ' AmeriChicken Sales Dollars for: ' + MBUY_NAME
      OTHERWISE
         ? '   ' + MYEAR + ' AmeriChicken Net Dollars for: ' + MBUY_NAME
      ENDCASE
      IF MPRT_TYPE = 'P'
         *** FONT COURIER BOLD
         ?? CHR(27) + '(s0ph0s3b4099T'
         
         *** PRINT IN 12 CPI
         ?? chr(27) + '&k4S'
         
         *** PRINT IN 6 LINES/INCH VERTICAL
         **?? chr(27) + '&l6D'
         
         *** PRINT IN 8 LINES PER IN/VERTICAL
         ?? chr(27) + '&l8D'
         
      ENDIF
      
      IF MGRP_CODE <> SPACE(4)
         ?? SPACE(15) + 'CUST GROUP: ' + MGRP_CODE
      ENDIF
      ?
      *** UNDERLINE OFF
      ?? CHR(27) + '&d@'
      ? '  '
      *** UNDERLINE ON
      ?? CHR(27) + '&d0D'
      ?? 'PRODUCT       JANUARY  FEBRUARY     MARCH     APRIL       MAY      JUNE      JULY    AUGUST'
      ?? ' SEPTEMBER   OCTOBER  NOVEMBER  DECEMBER       TOTAL   AVERAGE'
      
      ?
      MLINE = MLINE + 1
      DO WHILE .NOT. EOF() .AND. MBUY_NAME+MBUY_CODE = BUY_NAME+BUY_CODE
         *** UNDERLINE OFF
         ?? CHR(27) + '&d@'
         ? SPACE(2)
         *** UNDERLINE ON
         ?? CHR(27) + '&d0D'
         
         ?? PROD_DESC + SPACE(2)
         MTOTAL = 0
         I = 1
         DO WHILE I<= 12
            MI = SUBSTR(STR(I+100,3),2)
            ??  TRANSFORM(LBS&MI, '9,999,999') + SPACE(1)
            MTOT_LBS&MI = MTOT_LBS&MI + LBS&MI
            MTOTAL = MTOTAL + LBS&MI
            I = I + 1
         ENDDO
         ?? SPACE(1)
         ?? TRANSFORM(MTOTAL, '99,999,999') + SPACE(1)
         MAVG = ROUND(MTOTAL/MCOUNT,0)
         ?? TRANSFORM(MAVG, '9,999,999')
         ?
         MLINE = MLINE + 2
         SKIP
      ENDDO
      
      *** DO CUSTOMER TOTALS HERE
      ?
      *** UNDERLINE OFF
      ?? CHR(27) + '&d@'
      ? SPACE(2)
      *** UNDERLINE ON
      ?? CHR(27) + '&d0D'
      ?? 'TOTALS    ' + SPACE(2)
      MTOTAL = 0
      I = 1
      DO WHILE I<= 12
         MI = SUBSTR(STR(I+100,3),2)
         ??  TRANSFORM(MTOT_LBS&MI, '9,999,999') + SPACE(1)
         MTOTAL = MTOTAL + MTOT_LBS&MI
         I = I + 1
      ENDDO
      ?? SPACE(1)
      ?? TRANSFORM(MTOTAL, '99,999,999') + SPACE(1)
      MAVG = ROUND(MTOTAL/MCOUNT,0)
      ?? TRANSFORM(MAVG, '9,999,999')
      ?
      ?
      ?
      ?
      MLINE = MLINE + 6
      **EJECT
   ENDDO
ENDIF

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON
IF MPRINTER3 <> 'DONOTPRINT'
   RUN &MPRINTIT3
ENDIF

CLOSE DATA
RETURN
*Formatted by: ToolBox Ver. 1.2  on 8/26/16 at 2:49 PM.
