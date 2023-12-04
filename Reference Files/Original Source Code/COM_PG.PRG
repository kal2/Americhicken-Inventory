**********
* Program.: COM_PG.PRG
* Author..: Grace Keller
* Date....: 10/19/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: COMMISSION PO DETAIL AMOUNTS - PRIMARY/SECONDAY
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
IF EOF()
   RETURN
ENDIF
RELEASE MFAX, MNOTE, MCRED_LIM
RELEASE MFAX, MNET_DAYS, MLET_CRD, MGUARAN, MACTIVE, MBEG_DATE, MEND_DATE
RELEASE MPAY_NAME, MPAY_STRT, MPAY_CITY, MPAY_STATE, MPAY_ZIP, MPAY_ZIP4, MPAY_AREA, MPAY_PHONE
RELEASE MNAME, MSTREET, MCITY, MSTATE, MZIP, MZIP4, MAREA_CODE, PHONE
RELEASE MREM_NAME, MBIL_NAME, MFRT_CODE, MBUYER_PD, MINV_COMMT

SELECT A
DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
SEEK B->BBUYCODE
STORE FED_CUST TO MFED_CUST
USE
IF MPO_ADD
   STORE SPACE(2) TO MCOM1, MCOM2, MCOM3
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.CUSTCOMM INDEX &MDBFLOC.CUSTCOMM", .F.
   SEEK B->BBUYCODE
   IF .NOT. EOF()
      I = 1
      IF CUSTCOMM1 <> SPACE(2)
         MI = STR(I,1)
         MCOM&MI = CUSTCOMM1
         I = I + 1
      ENDIF
      IF CUSTCOMM2 <> SPACE(2)
         MI = STR(I,1)
         MCOM&MI = CUSTCOMM2
         I = I + 1
      ENDIF
      IF CUSTCOMM3 <> SPACE(2)
         MI = STR(I,1)
         MCOM&MI = CUSTCOMM3
         I = I + 1
      ENDIF
      IF CUSTBILL1 <> SPACE(2)
         *** FEDERATED = 30
         IF CUSTBILL1 = '30'
            MCOM3 = CUSTBILL1
         ELSE
            MI = STR(I,1)
            MCOM&MI = CUSTBILL1
            I = I + 1
         ENDIF
      ENDIF
      IF CUSTBILL2 <> SPACE(2)
         *** FEDERATED = 30
         IF CUSTBILL1 = '30'
            MCOM3 = CUSTBILL1
         ELSE
            MI = STR(I,1)
            MCOM&MI = CUSTBILL2
            I = I + 1
         ENDIF
      ENDIF
      IF CUSTBILL3 <> SPACE(2)
         *** FEDERATED = 30
         IF CUSTBILL1 = '30'
            MCOM3 = CUSTBILL1
         ELSE
            MI = STR(I,1)
            MCOM&MI = CUSTBILL3
            I = I + 1
         ENDIF
      ENDIF
   ENDIF
   USE
   SELECT B
   DO RECLOCK
   REPLACE COM_CODE WITH MCOM1
   REPLACE COM_CODE2 WITH MCOM2
   REPLACE COM_CODE3 WITH MCOM3
   UNLOCK
ENDIF

SELECT C
MPAGE = 1
@ 2,40 SAY SPACE(39)
@ 3,0 CLEAR
@ 3,1 SAY 'PAGE:'
@ 2,34 SAY '1. 3RD COM:'
@ 3,34 SAY '2. 3RD COM:'
@ 4,34 SAY '3. 3RD COM:'
@ 4,1 SAY 'PO #: '
@ 4,7 SAY MSALESMAN + '-' + MPO_NBR
IF MPO_SUFFIX <> ' '
   @ 4,14 SAY '-' + MPO_SUFFIX
ENDIF
***@ 6,0 TO 6,79
*@ 6,1 SAY 'ITM   PRODUCT  1ST /QTY  2ND /QTY  3RD /QTY      1ST AMT    2ND AMT    3RD AMT'
*           12345678901234567890123456789012345678901234567890123456789012345678901234567890
*                    10        20        30        40        50        60        70           
@ 6,0 SAY '-ITM-'
@ 6,6 SAY '-PRODUCT-'
@ 6,16 SAY '-1ST/QTY-'
@ 6,26 SAY '-2ND/QTY-'
@ 6,36 SAY '-3RD/QTY-'
@ 6,49 SAY '-1ST AMT-'
@ 6,60 SAY '-2ND AMT-'
@ 6,71 SAY '-3RD AMT-'
@ 24,0 to 24,79

STORE B->COM_CODE  TO MCOM_CODE
STORE B->COM_CODE2 TO MCOM_CODE2
STORE B->COM_CODE3 TO MCOM_CODE3

SELECT A
DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
IF MCOM_CODE <> SPACE(2)
   SEEK MCOM_CODE
   IF .NOT. EOF()
      STORE SUBSTR(NAME,1,25) TO MCOM_NAME
   ELSE  
      STORE '3RD PARTY COMM NOT ON FILE' TO MCOM_NAME
   ENDIF
ELSE
   STORE SPACE(25) TO MCOM_NAME
ENDIF

IF MCOM_CODE2 <> SPACE(2)
   SEEK MCOM_CODE2
   IF .NOT. EOF()
      STORE SUBSTR(NAME,1,25) TO MCOM_NAME2
   ELSE  
      STORE '3RD PARTY COMM NOT ON FILE' TO MCOM_NAME2
   ENDIF
ELSE
   STORE SPACE(25) TO MCOM_NAME2
ENDIF

IF MCOM_CODE3 <> SPACE(2)
   SEEK MCOM_CODE3
   IF .NOT. EOF()
      STORE SUBSTR(NAME,1,25) TO MCOM_NAME3
   ELSE  
      STORE '3RD PARTY COMM NOT ON FILE' TO MCOM_NAME3
   ENDIF
ELSE
   STORE SPACE(25) TO MCOM_NAME3
ENDIF


IF MVIEW
   @ 2,46 SAY MCOM_NAME
   @ 3,46 SAY MCOM_NAME2
   @ 4,46 SAY MCOM_NAME3
ELSE
   MACTION = 2
   DO WHILE MACTION = 2
      @ 2,46 GET MCOM_NAME PICTURE '@!'
      READ
      IF MCOM_NAME <> SPACE(25)
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
         MCOM_FD = .F.
         STORE TRIM(MCOM_NAME) TO SRCH_ARG
         DO COM_SEL2
         IF .NOT. MCOM_FD
            MCOM_NAME = SPACE(25)
            MCOM_CODE = SPACE(2)
         ELSE
            STORE SUBSTR(NAME,1,25) TO MCOM_NAME
            STORE COM_CODE TO MCOM_CODE
         ENDIF
         @  2,46 SAY MCOM_NAME
      ELSE
         STORE '  ' TO MCOM_CODE
      ENDIF
      
      @ 3,46 GET MCOM_NAME2 PICTURE '@!'
      READ
      IF MCOM_NAME2 <> SPACE(25)
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
         MCOM_FD = .F.
         STORE TRIM(MCOM_NAME2) TO SRCH_ARG
         DO COM_SEL2
         IF .NOT. MCOM_FD
            MCOM_NAME2 = SPACE(25)
            MCOM_CODE2 = SPACE(2)
         ELSE
            STORE SUBSTR(NAME,1,25) TO MCOM_NAME2
            STORE COM_CODE TO MCOM_CODE2
         ENDIF
         @  3,46 SAY MCOM_NAME2
      ELSE
         STORE '  ' TO MCOM_CODE2
      ENDIF
      
      @ 4,46 GET MCOM_NAME3 PICTURE '@!'
      READ
      IF MCOM_NAME3 <> SPACE(25)
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
         MCOM_FD = .F.
         STORE TRIM(MCOM_NAME3) TO SRCH_ARG
         DO COM_SEL2
         IF .NOT. MCOM_FD
            STORE SPACE(25) TO MCOM_NAME3
            STORE SPACE(2) TO MCOM_CODE3
         ELSE
            STORE SUBSTR(NAME,1,25) TO MCOM_NAME3
            STORE COM_CODE TO MCOM_CODE3
         ENDIF
         @  4,46 SAY MCOM_NAME3
      ELSE
         STORE '  ' TO MCOM_CODE3
      ENDIF
      MACTION = 1
      @ 25,0 SAY 'Action: ' + STR(MACTION,1)
      @ 25,13 SAY '1. Continue    2. Edit'
      @ 25,8 GET MACTION PICTURE '#' RANGE 1,2
      READ
   ENDDO
ENDIF

SELECT A
USE



SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX

MMAX_ITM = 0
MNBR_ITM = 1

DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
   MI = SUBSTR(STR(MNBR_ITM+100,3),2)
   IF MCOM_CODE <>SPACE(2)
      STORE COM1_CENT TO MCOM1_C&MI
   ENDIF
   IF MCOM_CODE2 <> SPACE(2)
      STORE COM2_CENT TO MCOM2_C&MI
   ENDIF
   IF MCOM_CODE3 <> SPACE(3)
      STORE COM3_CENT TO MCOM3_C&MI
   ENDIF
   STORE RECNO()   TO MREC&MI
   STORE PROD_DESC TO MPROD&MI
   
   IF .NOT. MVIEW
      *** ONLY PICK UP ON PO ADD OR ON PO'S SHIPPED AFTER 07/15/2003
      IF MPO_SUFFIX <> 'R'
         MCUTOFF = CTOD('07/15/2003')
         IF MPO_ADD .OR. B->SHIP_DATE >= MCUTOFF
            *** ONLY PICK UP ON PO'S HAVING SELLING PRICE -IF ZERO -IT A SAMPLE
            IF SEL_PRICE = 0
               IF MCOM_CODE <>SPACE(2)
                  STORE 0 TO MCOM1_C&MI
               ENDIF
               IF MCOM_CODE2 <> SPACE(2)
                  STORE 0 TO MCOM2_C&MI
               ENDIF
               IF MCOM_CODE3 <> SPACE(3)
                  STORE 0 TO MCOM3_C&MI
               ENDIF
            ELSE
               SELECT A
               DO FOX_USE WITH "&MMASTDBF.BROK_FEE INDEX &MMASTDBF.BROK_FEE", .F.
               
               IF MCOM_CODE <> SPACE(2)
                  IF MCOM1_C&MI >= 0
                     SEEK MCOM_CODE + SUBSTR(MPROD&MI,1,6)
                     IF .NOT. EOF()
                        STORE BROK_FEE TO MCOM1_C&MI
                     ELSE
                        STORE 0 TO MCOM1_C&MI
                     ENDIF
                  ENDIF
                  MDO_025 = .F.
                  IF MDO_025
                     IF B->SHIP_DATE >= CTOD('07/01/2016') .AND. (MCOM_CODE = '82' .or. MCOM_CODE = '1J' .or. MCOM_CODE = '1K' .or. MCOM_CODE = '2L' .or.MCOM_CODE = '2M') .AND. C->QTY > 0 .AND. C->PROD_DESC <> '1100'
                        *** UWG-unified western grocers-gets addl 2.5% ACCRUED
                        ** added 05/03/2017
                        **225 = unified western grocers-oregon
                        **82  = unified western grocers
                        **1J  = uwg-or
                        **22012 - product
                        *** the above combo does not get the extra calculated
                        IF B->BBUYCODE = ' 225' .AND. (mcom_code = '82' .or. mcom_code = '1J') .and. c->prod_desc = '22012'
                        else
                           IF (C->PROD_DESC = '47184' .OR. C->PROD_DESC = '51221' .OR. C->PROD_DESC = '51160') .AND. B->BBUYCODE = ' 189'
                              MEXTRA = ROUND(((C->TOT_SELL*.025)/C->QTY),4)
                           ELSE
                              MEXTRA = ROUND(((C->TOT_SELL*.025)/C->LBS),4)
                           ENDIF
                           MCOM1_C&MI = MCOM1_C&MI + MEXTRA
                        endif
                     ENDIF
                  ENDIF
                  
                  IF MCOM_CODE = '21' .AND. B->SHIP_DATE >= CTOD('01/01/2020')
                     ** NO ADDL 2% FOR AWG - ASSOCIATED WHOLESALE GROCERS
                     ** AFTER 01/01/2020
                  ELSE
                     IF B->SHIP_DATE >= CTOD('10/01/2008') .AND. MCOM_CODE = '21' .AND. C->QTY > 0 .AND. C->PROD_DESC <> '1100'
                        *** AWG GETS ANOTHER 2% ACCRUED = AWG COM_CODE = 21
                        IF (C->PROD_DESC = '47184' .OR. C->PROD_DESC = '51221' .OR. C->PROD_DESC = '51160') .AND. B->BBUYCODE = ' 189'
                           MEXTRA = ROUND(((C->TOT_SELL*.02)/C->QTY),4)
                        ELSE
                           MEXTRA = ROUND(((C->TOT_SELL*.02)/C->LBS),4)
                        ENDIF
                        
                        MCOM1_C&MI = MCOM1_C&MI + MEXTRA
                     ENDIF
                  ENDIF
                  IF B->SHIP_DATE >= CTOD('03/01/2011') .and. b->ship_date < ctod('01/01/2020') .AND. MCOM_CODE = '2C' .AND. C->QTY > 0 .AND. (C->PROD_DESC = '8901' .OR. C->PROD_DESC = '24561' .OR. C->PROD_DESC = '24160')
                     *** CENTER OF THE PLATE GETS ANOTHER 1% ACCRUED = CENTER OF THE PLATE COM_CODE = 2C
                     MEXTRA = ROUND(((C->TOT_SELL*.01)/C->QTY),4)
                     MCOM1_C&MI = MCOM1_C&MI + MEXTRA
                  ENDIF
               ENDIF
               
               IF MCOM_CODE2 <> SPACE(2)
                  IF MCOM2_C&MI >= 0
                     SEEK MCOM_CODE2 + SUBSTR(MPROD&MI,1,6)
                     IF .NOT. EOF()
                        STORE BROK_FEE TO MCOM2_C&MI
                     ELSE
                        STORE 0 TO MCOM2_C&MI
                     ENDIF
                  ENDIF
                  MDO_025 = .F.
                  IF MDO_025
                     IF B->SHIP_DATE >= CTOD('07/01/2016') .AND. (MCOM_CODE2 = '82' .or. MCOM_CODE2 = '1J' .or. MCOM_CODE2 = '1K' .or. MCOM_CODE2 = '2L' .or.MCOM_CODE2 = '2M') .AND. C->QTY > 0 .AND. C->PROD_DESC <> '1100'
                        *** UWG-unified western grocers-gets addl 2.5% ACCRUED
                        ** added 05/03/2017
                        **225 = unified western grocers-oregon
                        **82  = unified western grocers
                        **1J  = uwg-or
                        **22012 - product
                        *** the above combo does not get the extra calculated
                        IF B->BBUYCODE = ' 225' .AND. (mcom_code2 = '82' .or. mcom_code2 = '1J') .and. c->prod_desc = '22012'
                        else
                           IF (C->PROD_DESC = '47184' .OR. C->PROD_DESC = '51221' .OR. C->PROD_DESC = '51160') .AND. B->BBUYCODE = ' 189'
                              MEXTRA = ROUND(((C->TOT_SELL*.025)/C->QTY),4)
                           ELSE
                              MEXTRA = ROUND(((C->TOT_SELL*.025)/C->LBS),4)
                           ENDIF
                           MCOM2_C&MI = MCOM2_C&MI + MEXTRA
                        endif
                     ENDIF
                  ENDIF
                  IF MCOM_CODE = '21' .AND. B->SHIP_DATE >= CTOD('01/01/2020')
                     ** NO ADDL 2% FOR AWG - ASSOCIATED WHOLESALE GROCERS
                     ** AFTER 01/01/2020
                  ELSE
                     IF B->SHIP_DATE >= CTOD('10/01/2008') .AND. MCOM_CODE2 = '21' .AND. C->QTY > 0  .AND. C->PROD_DESC <> '1100'
                        *** AWG GETS ANOTHER 2% ACCRUED = AWG COM_CODE= 21
                        IF (C->PROD_DESC = '47184' .OR. C->PROD_DESC = '51221' .OR. C->PROD_DESC = '51160') .AND. B->BBUYCODE = ' 189'
                           MEXTRA = ROUND(((C->TOT_SELL*.02)/C->QTY),4)
                        ELSE
                           MEXTRA = ROUND(((C->TOT_SELL*.02)/C->LBS),4)
                        ENDIF
                        MCOM2_C&MI = MCOM2_C&MI + MEXTRA
                     ENDIF
                  ENDIF
                  IF B->SHIP_DATE >= CTOD('03/01/2011') .and. b->ship_date < ctod('01/01/2020') .AND. MCOM_CODE2 = '2C' .AND. C->QTY > 0 .AND. (C->PROD_DESC = '8901' .OR. C->PROD_DESC = '24561' .OR. C->PROD_DESC = '24160')
                     *** CENTER OF THE PLATE GETS ANOTHER 1% ACCRUED = CENTER OF THE PLATE COM_CODE = 2C
                     MEXTRA = ROUND(((C->TOT_SELL*.01)/C->QTY),4)
                     MCOM2_C&MI = MCOM2_C&MI + MEXTRA
                  ENDIF
               ENDIF
               IF MCOM_CODE3 <> SPACE(2)
                  IF MCOM3_C&MI >= 0
                     SEEK MCOM_CODE3 + SUBSTR(MPROD&MI,1,6)
                     IF .NOT. EOF()
                        STORE BROK_FEE TO MCOM3_C&MI
                     ELSE
                        STORE 0 TO MCOM3_C&MI
                     ENDIF
                  ENDIF
                  MDO_025 = .F.
                  IF MDO_025
                     IF B->SHIP_DATE >= CTOD('07/01/2016') .AND. (MCOM_CODE3 = '82' .or. MCOM_CODE3 = '1J' .or. MCOM_CODE3 = '1K' .or. MCOM_CODE3 = '2L' .or.MCOM_CODE3 = '2M') .AND. C->QTY > 0 .AND. C->PROD_DESC <> '1100'
                        *** UWG-unified western grocers-gets addl 2.5% ACCRUED
                        ** added 05/03/2017
                        **225 = unified western grocers-oregon
                        **82  = unified western grocers
                        **1J  = uwg-or
                        **22012 - product
                        *** the above combo does not get the extra calculated
                        IF B->BBUYCODE = ' 225' .AND. (mcom_code3 = '82' .or. mcom_code3 = '1J') .and. c->prod_desc = '22012'
                        else
                           IF (C->PROD_DESC = '47184' .OR. C->PROD_DESC = '51221' .OR. C->PROD_DESC = '51160') .AND. B->BBUYCODE = ' 189'
                              MEXTRA = ROUND(((C->TOT_SELL*.025)/C->QTY),4)
                           ELSE
                              MEXTRA = ROUND(((C->TOT_SELL*.025)/C->LBS),4)
                           ENDIF
                           MCOM3_C&MI = MCOM3_C&MI + MEXTRA
                        endif
                     ENDIF
                  ENDIF
                  
                  IF MCOM_CODE = '21' .AND. B->SHIP_DATE >= CTOD('01/01/2020')
                     ** NO ADDL 2% FOR AWG - ASSOCIATED WHOLESALE GROCERS
                     ** AFTER 01/01/2020
                  ELSE
                     IF B->SHIP_DATE >= CTOD('10/01/2008') .AND. MCOM_CODE3 = '21' .AND. C->QTY > 0 .AND. C->PROD_DESC <> '1100'
                        *** AWG GETS ANOTHER 2% ACCRUED = AWG COM_CODE = 21
                        IF (C->PROD_DESC = '47184' .OR. C->PROD_DESC = '51221' .OR. C->PROD_DESC = '51160') .AND. B->BBUYCODE = ' 189'
                           MEXTRA = ROUND(((C->TOT_SELL*.02)/C->QTY),4)
                        ELSE
                           MEXTRA = ROUND(((C->TOT_SELL*.02)/C->LBS),4)
                        ENDIF
                        MCOM3_C&MI = MCOM3_C&MI + MEXTRA
                     ENDIF
                  ENDIF
                  IF B->SHIP_DATE >= CTOD('03/01/2011') .and. b->ship_date < ctod('01/01/2020') .AND. MCOM_CODE3 = '2C' .AND. C->QTY > 0 .AND. (C->PROD_DESC = '8901' .OR. C->PROD_DESC = '24561' .OR. C->PROD_DESC = '24160')
                     *** CENTER OF THE PLATE GETS ANOTHER 1% ACCRUED = CENTER OF THE PLATE COM_CODE = 2C
                     MEXTRA = ROUND(((C->TOT_SELL*.01)/C->QTY),4)
                     MCOM3_C&MI = MCOM3_C&MI + MEXTRA
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   SELECT C
   MMAX_ITM = MMAX_ITM + 1
   MNBR_ITM = MNBR_ITM + 1
   SKIP
ENDDO


MNBR_ITM = 1
DO WHILE MNBR_ITM <= MMAX_ITM
   MACTION = 2
   DO WHILE MACTION = 2
      MLINE = 7
      @ MLINE,0 CLEAR TO 22,79
      @ 3,7 SAY STR(MPAGE,2)
      DO WHILE MLINE <= 22 .AND. MNBR_ITM <= MMAX_ITM
         MI = SUBSTR(STR(MNBR_ITM+100,3),2)
         @ MLINE,0 SAY STR(MNBR_ITM,2) + '.'
         @ MLINE,7 SAY MPROD&MI
         IF MVIEW
            IF MCOM_CODE <> SPACE(2)
               @ MLINE,17 SAY MCOM1_C&MI PICTURE '##.####'
            ENDIF
            IF MCOM_CODE2 <> SPACE(2)
               @ MLINE,27 SAY MCOM2_C&MI PICTURE '##.####'
            ENDIF
            IF MCOM_CODE3 <> SPACE(2)
               @ MLINE,37 SAY MCOM3_C&MI PICTURE '##.####'
            ENDIF
         ELSE
            IF MCOM_CODE <> SPACE(2)
               @ MLINE,17 GET MCOM1_C&MI PICTURE '##.####'
            ENDIF
            IF MCOM_CODE2 <> SPACE(2)
               @ MLINE,27 GET MCOM2_C&MI PICTURE '##.####'
            ENDIF
            IF MCOM_CODE3 <> SPACE(2)
               @ MLINE,37 GET MCOM3_C&MI PICTURE '##.####'
            ENDIF
         ENDIF
         MLINE = MLINE + 1
         MNBR_ITM = MNBR_ITM + 1
      ENDDO
      IF MNBR_ITM <= MMAX_ITM
         @ 24,67 SAY 'More Items...'
      ELSE
         @ 24,67 TO 24,79
      ENDIF
      STORE 1 TO MACTION
      @ 25,0 SAY 'Action: ' + STR(MACTION,1)
      IF MVIEW
         @ 25,13 SAY '1. Continue    2. Edit     3. Cancel Comm View'
      ELSE
         @ 25,13 SAY '1. Continue    2. Edit     3. Cancel All Comm Updates'
         *@ 25,8 GET MACTION PICTURE '#' RANGE 1,3
         *READ
      ENDIF
      
      MLINE = 7
      I = (MPAGE * 17) - 16
      DO WHILE MLINE <= 22 .AND. I <= MMAX_ITM
         *** SHOW ALL THIS INFO BACK
         MI = SUBSTR(STR(I+100,3),2)
         IF MREC&MI <> 0
            GOTO MREC&MI
            
            IF MCOM_CODE <> SPACE(2)
               DO CASE
               CASE (PROD_DESC = '47184' .OR. PROD_DESC = '51221' .OR. PROD_DESC = '51160') .AND. B->BBUYCODE = ' 189'
                  @ MLINE,48 SAY ROUND(MCOM1_C&MI * QTY,2) PICTURE '99,999.99'
               CASE (PROD_DESC = '65521' .OR. PROD_DESC = '65543') .AND. MCOM_CODE = '32'
                  @ MLINE,48 SAY ROUND(MCOM1_C&MI * QTY,2) PICTURE '99,999.99'
               OTHERWISE
                  @ MLINE,48 SAY ROUND(MCOM1_C&MI * LBS,2) PICTURE '99,999.99'
               ENDCASE
            ENDIF
            IF MCOM_CODE2 <> SPACE(2)
               DO CASE
               CASE (PROD_DESC = '47184' .OR. PROD_DESC = '51221' .OR. PROD_DESC = '51160') .AND. B->BBUYCODE = ' 189'
                  @ MLINE,59 SAY ROUND(MCOM2_C&MI * QTY,2) PICTURE '99,999.99'
               CASE (PROD_DESC = '65521' .OR. PROD_DESC = '65543') .AND. MCOM_CODE2 = '32'
                  @ MLINE,48 SAY ROUND(MCOM1_C&MI * QTY,2) PICTURE '99,999.99'
               OTHERWISE
                  @ MLINE,59 SAY ROUND(MCOM2_C&MI * LBS,2) PICTURE '99,999.99'
               ENDCASE
            ENDIF
            IF MCOM_CODE3 <> SPACE(2)
               DO CASE
               CASE (PROD_DESC = '47184' .OR. PROD_DESC = '51221' .OR. PROD_DESC = '51160') .AND. B->BBUYCODE = ' 189'
                  @ MLINE,70 SAY ROUND(MCOM3_C&MI * QTY,2) PICTURE '99,999.99'
               CASE (PROD_DESC = '65521' .OR. PROD_DESC = '65543') .AND. MCOM_CODE3 = '32'
                  @ MLINE,48 SAY ROUND(MCOM1_C&MI * QTY,2) PICTURE '99,999.99'
               OTHERWISE
                  @ MLINE,70 SAY ROUND(MCOM3_C&MI * LBS,2) PICTURE '99,999.99'
               ENDCASE
            ENDIF
         ENDIF
         I = I + 1
         MLINE = MLINE + 1
      ENDDO
      @ 25,8 GET MACTION PICTURE '#' RANGE 1,3
      READ
   ENDDO
   IF MACTION = 3
      MNBR_ITM = MMAX_ITM + 10
      LOOP
   ENDIF
   MPAGE = MPAGE + 1
ENDDO


IF MACTION = 3 .OR. MVIEW
   MNBR_ITM = 1
   DO WHILE MNBR_ITM <= MMAX_ITM
      MI = SUBSTR(STR(MNBR_ITM+100,3),2)
      RELEASE MCOM1_C&MI, MCOM2_C&MI, MCOM3_C&MI
      MNBR_ITM = MNBR_ITM + 1
   ENDDO
   PUBLIC MFAX, MNOTE, MCRED_LIM
   PUBLIC MFAX, MNET_DAYS, MLET_CRD, MGUARAN, MACTIVE, MBEG_DATE, MEND_DATE
   PUBLIC MPAY_NAME, MPAY_STRT, MPAY_CITY, MPAY_STATE, MPAY_ZIP, MPAY_ZIP4, MPAY_AREA, MPAY_PHONE
   PUBLIC MNAME, MSTREET, MCITY, MSTATE, MZIP, MZIP4, MAREA_CODE, PHONE
   PUBLIC MREM_NAME, MBIL_NAME, MFRT_CODE, MBUYER_PD, MINV_COMMT
   RETURN
ENDIF

***************************************
*** WRITE THIS INFO BACK NOW
***************************************
MNBR_ITM = 1
DO WHILE MNBR_ITM <= MMAX_ITM
   MI = SUBSTR(STR(MNBR_ITM+100,3),2)
   GOTO MREC&MI
   DO RECLOCK
   IF MCOM_CODE <> SPACE(2)
      REPLACE COM1_CENT WITH MCOM1_C&MI
   ENDIF
   IF MCOM_CODE2 <> SPACE(2)
      REPLACE COM2_CENT WITH MCOM2_C&MI
   ENDIF
   IF MCOM_CODE3 <> SPACE(2)
      REPLACE COM3_CENT WITH MCOM3_C&MI
   ENDIF
   UNLOCK
   MNBR_ITM = MNBR_ITM + 1
ENDDO

MNBR_ITM = 1
DO WHILE MNBR_ITM <= MMAX_ITM
   MI = SUBSTR(STR(MNBR_ITM+100,3),2)
   RELEASE MREC&MI, MCOM1_C&MI, MCOM2_C&MI, MPROD&MI, MCOM3_C&MI
   MNBR_ITM = MNBR_ITM + 1
ENDDO

*** FINISH UP - CALCULATE TOTALS FOR COMMISSION PEOPLES
*** AND SEE IF ANY OFF INVOICE CUSTOMER PROMOTIONS

SELECT A
DO FOX_USE WITH "&MDBFLOC.CUSIPROM INDEX &MDBFLOC.CUSIPROM", .F.
STORE 0 TO MTOT_COM1, MTOT_COM2, MTOT_COM3
STORE 0 TO MBUYOFF

SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX  
   
   DO CASE
   CASE (PROD_DESC = '47184' .OR. PROD_DESC = '51221' .OR. PROD_DESC = '51160') .AND. B->BBUYCODE = ' 189'
      MTOT_COM1 = MTOT_COM1 + ROUND(COM1_CENT * QTY,2)
   CASE (PROD_DESC = '65521' .OR. PROD_DESC = '65543')  .AND. B->COM_CODE = '32'
      MTOT_COM1 = MTOT_COM1 + ROUND(COM1_CENT * QTY,2)
   OTHERWISE
      MTOT_COM1 = MTOT_COM1 + ROUND(COM1_CENT * LBS,2)
   ENDCASE
   
   DO CASE
   CASE (PROD_DESC = '47184' .OR. PROD_DESC = '51221' .OR. PROD_DESC = '51160') .AND. B->BBUYCODE = ' 189'
      MTOT_COM2 = MTOT_COM2 + ROUND(COM2_CENT * QTY,2)
   CASE (PROD_DESC = '65521' .OR. PROD_DESC = '65543')  .AND. B->COM_CODE2 = '32'
      MTOT_COM2 = MTOT_COM2 + ROUND(COM2_CENT * QTY,2)
   OTHERWISE
      MTOT_COM2 = MTOT_COM2 + ROUND(COM2_CENT * LBS,2)
   ENDCASE
   
   DO CASE
   CASE (PROD_DESC = '47184' .OR. PROD_DESC = '51221' .OR. PROD_DESC = '51160') .AND. B->BBUYCODE = ' 189'
      MTOT_COM3 = MTOT_COM3 + ROUND(COM3_CENT * QTY,2)
   CASE (PROD_DESC = '65521' .OR. PROD_DESC = '65543')  .AND. B->COM_CODE3 = '32'
      MTOT_COM3 = MTOT_COM3 + ROUND(COM3_CENT * QTY,2)
   OTHERWISE
      MTOT_COM3 = MTOT_COM3 + ROUND(COM3_CENT * LBS,2)
   ENDCASE
   
   
   IF C->SEL_PRICE > 0 .AND. C->LBS > 0
      *** NOW CHECK FOR CUSTOMER OFF INVOICE
      SELECT A
      SEEK B->BBUYCODE + C->PROD_DESC
      IF .NOT. EOF()
         IF B->SHIP_DATE >= BEG_DT .AND. B->SHIP_DATE <= END_DT
            MPROM = ROUND(ITM_PROM * C->LBS,2)
            SELECT C
            DO RECLOCK
            DO CASE
            CASE A->PBUYTYPE = 'P'
               REPLACE PBUYPAY WITH MPROM
            CASE A->PBUYTYPE = 'O'
               REPLACE PBUYOFF WITH MPROM
            ENDCASE
            UNLOCK
            
         ENDIF
      ENDIF
   ELSE
      SELECT C
      DO RECLOCK
      REPLACE PBUYPAY WITH 0
      REPLACE PBUYOFF WITH 0
      UNLOCK
   ENDIF
   SELECT C
   SKIP
ENDDO

***STORE B->COM_CODE  TO MCOM_CODE
***STORE B->COM_CODE2 TO MCOM_CODE2
***STORE B->COM_CODE3 TO MCOM_CODE3
IF MCOMPANY = 'AMERICHICKEN, INC' .OR. B->SALESMAN = '11'
   MAM_FLG = .T.
ELSE
   MAM_FLG = .F.
ENDIF
DO CASE
CASE MAM_FLG .AND. B->INV_FLG <> ' '
   ***** CHECK OUT FOR THE FIRST THIRD PARTY COMMISSION
   IF  B->COMM_AMT <> MTOT_COM1
      STORE B->COMM_AMT TO MOLD_AMT
      STORE B->COM_CODE TO MOLD_CODE
      SELECT D
      DO FOX_USE WITH "COMTHD INDEX COMTHD, COMTDT, COMTPD", .F.
      *** LOOK FOR A NOT PAID INVOICE ENTRY 
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '1' + ' I'
      IF .NOT. EOF()
         DO RECLOCK
         REPLACE COM_CODE WITH MCOM_CODE
         REPLACE AMOUNT WITH MTOT_COM1
         UNLOCK
      ELSE
         *** LOOK FOR A NOT PAID CORRECTION ENTRY - first 3rd party
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '1' + ' C1'
         IF EOF()
            *** FIND THE LAST POSTED RECORD  TO MAKE A BACKOUT ENTRY
            SET ORDER TO 2
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '1'
            DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. THD_SEQ = '1'
               STORE AMOUNT TO MOLD_AMT
               STORE COM_CODE TO MOLD_CODE
               SKIP
            ENDDO
            SET ORDER TO 1
            DO FILELOCK
            APPEND BLANK
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR   WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE THD_SEQ   WITH '1'
            REPLACE INV_NBR WITH B->INV_NBR
            REPLACE TRAN_DATE WITH DATE()
            REPLACE COR_FLG WITH 'C'
            REPLACE SEQ WITH '1'
            REPLACE COM_TYPE WITH 'T'
            REPLACE AMOUNT WITH (-1) * MOLD_AMT
            REPLACE COM_CODE WITH MOLD_CODE
         ENDIF
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '1' + ' C2'
         IF EOF()
            DO FILELOCK
            APPEND BLANK
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR   WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE THD_SEQ   WITH '1'
            REPLACE INV_NBR WITH B->INV_NBR
            REPLACE TRAN_DATE WITH DATE()
            REPLACE COR_FLG WITH 'C'
            REPLACE SEQ WITH '2'
            REPLACE COM_TYPE WITH 'T'
         ENDIF
         DO RECLOCK
         REPLACE COM_CODE WITH MCOM_CODE
         REPLACE AMOUNT WITH MTOT_COM1
         UNLOCK
      ENDIF
   ENDIF   
   ***** CHECK OUT FOR THE SECOND THIRD PARTY COMMISSION
   IF B->COMM_AMT2 <> MTOT_COM2
      STORE B->COMM_AMT2 TO MOLD_AMT2
      STORE B->COM_CODE2 TO MOLD_CODE2
      SELECT D
      DO FOX_USE WITH "COMTHD INDEX COMTHD, COMTDT, COMTPD", .F.
      *** LOOK FOR A NOT PAID INVOICE ENTRY
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '2' + ' I'
      IF .NOT. EOF()
         DO RECLOCK
         REPLACE COM_CODE WITH MCOM_CODE2
         REPLACE AMOUNT WITH MTOT_COM2
         UNLOCK
      ELSE
         *** LOOK FOR A NOT PAID CORRECTION ENTRY
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '2' + ' C1'
         IF EOF()
            *** FIND THE LAST POSTED RECORD  TO MAKE A BACKOUT ENTRY
            SET ORDER TO 2
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '2'
            DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. THD_SEQ = '2'
               STORE AMOUNT TO MOLD_AMT2
               STORE COM_CODE TO MOLD_CODE2
               SKIP
            ENDDO
            SET ORDER TO 1
            DO FILELOCK
            APPEND BLANK
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR   WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE THD_SEQ   WITH '2'
            REPLACE INV_NBR WITH B->INV_NBR
            REPLACE TRAN_DATE WITH DATE()
            REPLACE COR_FLG WITH 'C'
            REPLACE SEQ WITH '1'
            REPLACE COM_TYPE WITH 'T'
            REPLACE AMOUNT WITH (-1) * MOLD_AMT2
            REPLACE COM_CODE WITH MOLD_CODE2
         ENDIF
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '2' + ' C2'
         IF EOF()
            DO FILELOCK
            APPEND BLANK
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR   WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE INV_NBR WITH B->INV_NBR
            REPLACE THD_SEQ WITH '2'
            REPLACE TRAN_DATE WITH DATE()
            REPLACE COR_FLG WITH 'C'
            REPLACE SEQ WITH '2'
            REPLACE COM_TYPE WITH 'T'
         ENDIF
         DO RECLOCK
         REPLACE COM_CODE WITH MCOM_CODE2
         REPLACE AMOUNT WITH MTOT_COM2
         UNLOCK
      ENDIF
   ENDIF   
   
   
   ***** CHECK OUT FOR THE 3RD THIRD PARTY COMMISSION
   IF B->COMM_AMT3 <> MTOT_COM3
      STORE B->COMM_AMT3 TO MOLD_AMT3
      STORE B->COM_CODE3 TO MOLD_CODE3
      SELECT D
      DO FOX_USE WITH "COMTHD INDEX COMTHD, COMTDT, COMTPD", .F.
      *** LOOK FOR A NOT PAID INVOICE ENTRY
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '3' + ' I'
      IF .NOT. EOF()
         DO RECLOCK
         REPLACE COM_CODE WITH MCOM_CODE3
         REPLACE AMOUNT WITH MTOT_COM3
         UNLOCK
         
         IF MFED_CUST = 'Y'
            STORE D->FED_KEY TO MFED_KEY
            SELECT A
            DO FOX_USE WITH "FEDTHD INDEX FEDTHD", .F.
            SEEK STR(MFED_KEY,5)
            IF EOF()
               SELECT E
               DO FOX_USE WITH "CONTROL", .F.
               DO RECLOCK
               STORE FED_KEY TO MFED_KEY
               REPLACE FED_KEY WITH FED_KEY + 1
               UNLOCK
               USE
               SELECT D
               DO RECLOCK
               REPLACE FED_KEY WITH MFED_KEY
               UNLOCK
               USE
               SELECT A
               DO FILELOCK
               APPEND BLANK
               REPLACE FED_KEY WITH MFED_KEY
               REPLACE SALESMAN WITH B->SALESMAN
               REPLACE PO_NBR WITH B->PO_NBR
               REPLACE PO_SUFFIX WITH B->PO_SUFFIX
               UNLOCK
            ENDIF
            DO RECLOCK
            SELECT C
            SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX       
            I = 1
            DO WHILE .NOT. EOF() .AND. I <= 20 .AND. SALESMAN = B->SALESMAN .AND. PO_NBR = B->PO_NBR .AND. PO_SUFFIX = B->PO_SUFFIX
               MI = SUBSTR(STR(I+100,3),2)
               SELECT A
               REPLACE PROD&MI WITH C->PROD_DESC
               REPLACE LBS&MI  WITH C->LBS
               REPLACE CENT&MI WITH C->COM3_CENT
               I = I + 1
               SELECT C
               SKIP
            ENDDO
            SELECT A
            USE
         ENDIF
         
      ELSE
         *** LOOK FOR A NOT PAID CORRECTION ENTRY
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '3' + ' C1'
         IF EOF()
            *** FIND THE LAST POSTED RECORD  TO MAKE A BACKOUT ENTRY
            SET ORDER TO 2
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '3'
            DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. THD_SEQ = '3'
               STORE AMOUNT TO MOLD_AMT2
               STORE COM_CODE TO MOLD_CODE2
               SKIP
            ENDDO
            SET ORDER TO 1
            DO FILELOCK
            APPEND BLANK
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR   WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE THD_SEQ   WITH '3'
            REPLACE INV_NBR WITH B->INV_NBR
            REPLACE TRAN_DATE WITH DATE()
            REPLACE COR_FLG WITH 'C'
            REPLACE SEQ WITH '1'
            REPLACE COM_TYPE WITH 'T'
            REPLACE AMOUNT WITH (-1) * MOLD_AMT3
            REPLACE COM_CODE WITH MOLD_CODE3
            UNLOCK
            IF MFED_CUST = 'Y'
               ** ADD THE BACK OUT ENTRY ON FEDERATED FOODS FILE FROM TEMPFED
               SELECT E
               DO FOX_USE WITH "CONTROL", .F.
               DO RECLOCK
               STORE FED_KEY TO MFED_KEY
               REPLACE FED_KEY WITH FED_KEY + 1
               UNLOCK
               USE
               SELECT D
               DO RECLOCK
               REPLACE FED_KEY WITH MFED_KEY
               UNLOCK
               USE
               SELECT A
               DO FOX_USE WITH "FEDTHD INDEX FEDTHD", .F.
               DO FILELOCK
               APPEND BLANK
               REPLACE FED_KEY WITH MFED_KEY
               REPLACE SALESMAN WITH B->SALESMAN
               REPLACE PO_NBR WITH B->PO_NBR
               REPLACE PO_SUFFIX WITH B->PO_SUFFIX
               UNLOCK
               
               DO RECLOCK
               SELECT E
               DO FOX_USE WITH "TEMPFED INDEX TEMPFED", .F.
               SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX       
               I = 1
               DO WHILE .NOT. EOF() .AND. I <= 20 .AND. SALESMAN = B->SALESMAN .AND. PO_NBR = B->PO_NBR .AND. PO_SUFFIX = B->PO_SUFFIX
                  MI = SUBSTR(STR(I+100,3),2)
                  SELECT A
                  REPLACE PROD&MI WITH E->PROD&MI  
                  REPLACE LBS&MI  WITH E->LBS&MI
                  REPLACE CENT&MI WITH E->CENT&MI  
                  I = I + 1
                  SELECT E
                  SKIP
               ENDDO
               SELECT A
               USE
               SELECT E
               USE
            ENDIF
         ENDIF
         
         SELECT D
         DO FOX_USE WITH "COMTHD INDEX COMTHD, COMTDT, COMTPD", .F.
         
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '3' + ' C2'
         IF EOF()
            DO FILELOCK
            APPEND BLANK
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR   WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE INV_NBR WITH B->INV_NBR
            REPLACE THD_SEQ WITH '3'
            REPLACE TRAN_DATE WITH DATE()
            REPLACE COR_FLG WITH 'C'
            REPLACE SEQ WITH '2'
            REPLACE COM_TYPE WITH 'T'
         ENDIF
         DO RECLOCK
         REPLACE COM_CODE WITH MCOM_CODE3
         REPLACE AMOUNT WITH MTOT_COM3
         UNLOCK
         IF MFED_CUST = 'Y'
            STORE D->FED_KEY TO MFED_KEY
            SELECT A
            DO FOX_USE WITH "FEDTHD INDEX FEDTHD", .F.
            SEEK STR(MFED_KEY,5)
            IF EOF()
               SELECT E
               DO FOX_USE WITH "CONTROL", .F.
               DO RECLOCK
               STORE FED_KEY TO MFED_KEY
               REPLACE FED_KEY WITH FED_KEY + 1
               UNLOCK
               USE
               SELECT D
               DO RECLOCK
               REPLACE FED_KEY WITH MFED_KEY
               UNLOCK
               USE
               SELECT A
               DO FILELOCK
               APPEND BLANK
               REPLACE FED_KEY WITH MFED_KEY
               REPLACE SALESMAN WITH B->SALESMAN
               REPLACE PO_NBR WITH B->PO_NBR
               REPLACE PO_SUFFIX WITH B->PO_SUFFIX
               UNLOCK
            ENDIF
            DO RECLOCK
            SELECT C
            SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX       
            I = 1
            DO WHILE .NOT. EOF() .AND. I <= 20 .AND. SALESMAN = B->SALESMAN .AND. PO_NBR = B->PO_NBR .AND. PO_SUFFIX = B->PO_SUFFIX
               MI = SUBSTR(STR(I+100,3),2)
               SELECT A
               REPLACE PROD&MI WITH C->PROD_DESC
               REPLACE LBS&MI  WITH C->LBS
               REPLACE CENT&MI WITH C->COM3_CENT
               I = I + 1
               SELECT C
               SKIP
            ENDDO
            SELECT A
            USE
         ENDIF
      ENDIF
   ENDIF
   
   SELECT D
   USE
   
ENDCASE
SELECT B
DO RECLOCK
REPLACE COMM_AMT WITH MTOT_COM1
REPLACE COMM_AMT2 WITH MTOT_COM2
REPLACE COMM_AMT3 WITH MTOT_COM3
UNLOCK

MNBR_ITM = 1
DO WHILE MNBR_ITM <= MMAX_ITM
   MI = SUBSTR(STR(MNBR_ITM+100,3),2)
   RELEASE MCOM1_C&MI, MCOM2_C&MI, MCOM3_C&MI
   MNBR_ITM = MNBR_ITM + 1
ENDDO

PUBLIC MFAX, MNOTE, MCRED_LIM
PUBLIC MFAX, MNET_DAYS, MLET_CRD, MGUARAN, MACTIVE, MBEG_DATE, MEND_DATE
PUBLIC MPAY_NAME, MPAY_STRT, MPAY_CITY, MPAY_STATE, MPAY_ZIP, MPAY_ZIP4, MPAY_AREA, MPAY_PHONE
PUBLIC MNAME, MSTREET, MCITY, MSTATE, MZIP, MZIP4, MAREA_CODE, PHONE
PUBLIC MREM_NAME, MBIL_NAME, MFRT_CODE, MBUYER_PD, MINV_COMMT

RETURN
* EOF: COM_PG.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/27/19 at 9:20 AM.
