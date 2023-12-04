**********
* Program.: PROMO_PG.PRG
* Author..: Grace Keller
* Date....: 10/19/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PROMOTION PAGE DETAIL AMOUNTS
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX

STORE SPACE(32) TO MPBUYNAME, MPUSRNAME, MPBRKNAME
STORE SPACE(4) TO MPUSRCODE
STORE SPACE(2) TO MPCOMCODE
STORE SPACE(1) TO MPBUYTYPE
STORE 0 TO MPBUY_AMT, MPCOM_AMT, MPUSR_AMT

IF MPO_ADD
   *** ON AN ADD - PICK UP JUST LUMP SUM AMOUNT PROMOTIONS
   SELECT A
   *** DO NOT PICK UP LUMP SUM AMOUNTS - ENTERED MANUALLY RIGHT NOW
   **DO FOX_USE WITH "&MDBFLOC.CUSTPROM INDEX &MDBFLOC.CUSTPROM", .F.
   **SEEK B->BBUYCODE
   **DO WHILE .NOT. EOF() .AND. BBUYCODE = B->BBUYCODE
   **   IF B->DEL_REQD >= BEG_DT .AND. B->DEL_REQD <= END_DT
   **      IF PROMAMT <> 0
   **         MPBUY_AMT = PROMAMT
   **         MPBUYTYPE = PROM_TYPE
   **         GOTO TO BOTTOM
   **      ENDIF
   **   ENDIF
   **   SKIP
   **ENDDO
   
   **DO FOX_USE WITH "&MDBFLOC.COMMPROM INDEX &MDBFLOC.COMMPROM", .F.
   **DO WHILE .NOT. EOF()
   **   IF B->DEL_REQD >= BEG_DT .AND. B->DEL_REQD <= END_DT
   **      IF PROMAMT <> 0
   **         MPCOM_AMT = PROMAMT
   **         MPCOM_CODE = COM_CODE
   **         GOTO TO BOTTOM
   **      ENDIF
   **   ENDIF
   **   SKIP
   **ENDDO
   
   **DO FOX_USE WITH "&MDBFLOC.USERPROM INDEX &MDBFLOC.USERPROM", .F.
   **DO WHILE .NOT. EOF()
   **   IF B->DEL_REQD >= BEG_DT .AND. B->DEL_REQD <= END_DT
   **      IF PROMAMT <> 0
   **         MPUSR_AMT = PROMAMT
   **         MPUSR_CODE = USER_CODE
   **         GOTO TO BOTTOM
   **      ENDIF
   **   ENDIF
   **   SKIP
   **ENDDO
ELSE
   *** THESE ARE ALL PROMOTIONS ENTERED ON HEADER RECORD

   IF B->PBUYCODE <> SPACE(4)
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      SEEK B->PBUYCODE
      IF .NOT. EOF()
         STORE SUBSTR(NAME,1,25) TO MPBUYNAME
      ELSE  
         STORE 'BILLTO CUSTOMR NOT ON FILE' TO MPBUYNAME
      ENDIF
      USE
      MPBUYTYPE  = B->PBUY_TYPE
      MPBUY_PROM = B->PBUY_PROM
   ENDIF
   
   IF B->PCOMCODE <> SPACE(2)
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
      SEEK B->PCOMCODE
      IF .NOT. EOF()
         STORE SUBSTR(NAME,1,25) TO MPCOMNAME
      ELSE  
         STORE '3RD PARTY COMM NOT ON FILE' TO MPCOMNAME
      ENDIF
      MPBRK_PROM = B->PBRK_PROM
      USE
   ENDIF
   
   *** DONT HAVE THE USERS ENTERED YET *** NO MASTER FILE SET UP
   IF B->PUSRCODE <> SPACE(4)
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.USERS INDEX &MDBFLOC.USR_CODE", .F.
      SEEK B->PUSRCODE
      IF .NOT. EOF()
         STORE SUBSTR(NAME,1,25) TO MPUSRNAME
      ELSE  
         STORE 'END USER CUST NOT ON FILE ' TO MPUSRNAME
      ENDIF
      MPUSR_PROM = B->PUSR_PROM
      USE
   ENDIF
ENDIF

SELECT C
MPAGE = 1
@ 2,40 SAY SPACE(39)
@ 3,0 CLEAR
@ 3,1 SAY 'PAGE:'
@ 2,25 SAY 'TYPE:'
@ 2,30 SAY 'CUST:'
@ 3,30 SAY 'BROK:'
@ 4,30 SAY 'USER:'
@ 4,1 SAY 'PO #: '
@ 4,7 SAY MSALESMAN + '-' + MPO_NBR
IF MPO_SUFFIX <> ' '
   @ 4,14 SAY '-' + MPO_SUFFIX
ENDIF
*          XX. XXXXXX XXXXX-P X.XXXX XXXXX.XX   XXXX X.XXXX XXXXX.XX   XXXX X.XXXX XXXXX.XX
@ 6,0 SAY 'ITM -PROD- CUSTOMR  $/QTY  CUS AMT   BROK  $/QTY BROK AMT   USER  $/QTY USER AMT'
*          012345678901234567890123456789012345678901234567890123456789012345678901234567890
*                    10        20        30        40        50        60        70           
@ 24,0 TO 24,79

IF MVIEW
   @ 2,30 SAY MPBUYTYPE
   @ 2,39 SAY MPBUYNAME
   @ 2,71 SAY MPBUY_PROM PICTURE '99999.99'
   @ 3,39 SAY MPCOMNAME
   @ 3,71 SAY MPBRK_PROM PICTURE '99999.99'
   @ 4,39 SAY MPUSRNAME 
   @ 4,71 SAY MPUSR_PROM PICTURE '99999.99'
ELSE
   MACTION = 2
   DO WHILE MACTION = 2
      @ 2,39 GET MPBUYNAME PICTURE '@!'
      READ
      IF MPBUYNAME <> SPACE(25)
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
         SET PROC TO BUY_PROC
         MNAME_FD = .F.
         SAVE SCREEN TO MADD_SCRN
         DO BBUYSEL2
         RESTORE SCREEN FROM MADD_SCRN
         @ 24,0 CLEAR
         IF (.NOT. MNAME_FD) .OR. (MNAME = SPACE(32))
            MPBUYNAME = SPACE(25)
            MPBUYCODE = SPACE(2)
            @  2,39 SAY MPBUYNAME
         ELSE
            STORE SUBSTR(NAME,1,25) TO MPBUYNAME
            STORE BBUYCODE TO MPBUYCODE
            @ 2,30 GET MPBUYTYPE PICTURE '@!' VALID(MPBUYTYPE = 'O' .OR. MPBUYTYPE = 'P' .OR. MPBUYTYPE = 'D')
            @ 2,39 SAY MPBUYNAME
            @ 2,71 GET MPBUY_PROM PICTURE '99999.99'
            READ
         ENDIF
      ELSE
         STORE SPACE(4) TO MPBUYCODE
      ENDIF
      
      *** NOW START ON THE BROKER/THIRD PARTY COMM PART OF THE SCREEN
      @ 3,39 GET MPCOMNAME PICTURE '@!'
      READ
      IF MPCOMNAME <> SPACE(25)
         MCOM_FD = .F.
         STORE TRIM(MPCOMNAME) TO SRCH_ARG
         DO COM_SEL2
         IF .NOT. MCOM_FD
            MPCOMNAME = SPACE(25)
            MPCOMCODE = SPACE(2)
            @ 3,35 SAY MPCOMNAME
         ELSE
            STORE SUBSTR(NAME,1,25) TO MPCOMNAME 
            STORE COM_CODE TO MPCOMCODE 
            @ 3,39 SAY MPCOMNAME
            @ 3,71 GET MPBRK_PROM PICTURE '99999.99'
         ENDIF
      ELSE
         STORE '  ' TO MPCOMCODE 
      ENDIF
      
      **** NOW CHECK FOR END USER
      *** NOW START ON THE END USER PART OF THE SCREEN
      @ 4,39 GET MPUSRNAME PICTURE '@!'
      READ
      IF MPUSRNAME <> SPACE(25)
         MCOM_FD = .F.
         STORE TRIM(MPUSRNAME) TO SRCH_ARG
         DO USR_SEL2
         IF .NOT. MCOM_FD
            MPUSRNAME = SPACE(25)
            MPUSRCODE = SPACE(2)
            @ 4,39 SAY MPUSRNAME
         ELSE
            STORE SUBSTR(NAME,1,25) TO MPUSRNAME 
            STORE USR_CODE TO MPUSRCODE 
            @ 4,39 SAY MUSRMNAME
            @ 4,71 GET MPUSR_PROM PICTURE '99999.99'
         ENDIF
      ELSE
         STORE SPACE(4) TO MPUSRCODE 
      ENDIF
      MACTION = 1
      @ 24,0 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2. Edit'
      @ 24,8 GET MACTION PICTURE '#' RANGE 1,2
      READ
   ENDDO
ENDIF

**** NEED TO FIX THIS HERE - NEED TO CHECK ABOUT UPDATING LIKE COMTHD
**** NEW FILE CALLED PAY_PROM (PAY PROMOTIONS)
**** ALSO NEED TO UPDATE THE DAILYJRN - SPREADSHEET IF NEEDED
SELECT B
DO RECLOCK
REPLACE PBUYCODE WITH MPBUYCODE
REPLACE PBUY_PROM WITH MPBUY_PROM
REPLACE PBUY_TYPE WITH MPBUY_TYPE
REPLACE PCOM_CODE WITH MPCOM_CODE
REPLACE PBRK_PROM WITH MPBRK_PROM
REPLACE PUSR_CODE WITH MPUSR_CODE
REPLACE PUSR_PROM WITH MPUSR_PROM

***** FINISH UPDATING ALL OTHER FILES
SELECT A
USE


*** START ON THE ITEM INFORMATION
IF MVIEW
   SELECT D
   DO FOX_USE WITH "PO_PROM INDEX PO_PROM", .F.
   SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
ELSE
   SELECT C
   SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
ENDIF

MMAX_ITM = 0
MNBR_ITM = 1

*** DISPLAY BACK THE INFORMATION
DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
   MI = SUBSTR(STR(MNBR_ITM+100,3),2)
   STORE RECNO()   TO MREC&MI
   STORE PROD_DESC TO MPROD&MI
   *** IF NOT VIEWING - GO OUT TO GET CURRENT INFORMATION
   IF .NOT. MVIEW
      IF SEL_PRICE <> 0
         
         STORE 0 TO MBUY_C&MI
         *** CHECK FOR CUSTOMER PROMOTIONS
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.CUSTIPRO INDEX &MDBFLOC.CUSTIPRO", .F.
         SEEK B->BBUYCODE + SUBSTR(MPROD&MI,1,6)
         DO WHILE .NOT. EOF()
            IF B->DEL_REQD >= BEG_DT .AND. B->DEL_REQD <= END_DT
               STORE ITEM_PROM TO MBUY_C&MI
               STORE CUST_TYPE TO MBUY_T&MI
               GOTO BOTTOM
            ENDIF
            SKIP
         ENDDO
         
         *** CHECK FOR BROKER PROMOTIONS - MAXIMUM OF TWO ON EACH ITEM
         STORE 0 TO MBRK1_C&MI, MBRK2_C&MI
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.CUSTPITM INDEX &MDBFLOC.CUSTPITM", .F.
         SEEK SUBSTR(MPROD&MI,1,6)
         DO WHILE .NOT. EOF() .AND. SUBSTR(MPROD&MI,1,6) = PROD_DESC
            IF B->DEL_REQD >= BEG_DT .AND. B->DEL_REQD <= END_DT
               IF MBRK1_C&MI = 0
                  STORE ITEM_PROM TO MBRK1_C&MI
                  STORE COM_CODE  TO MBRK1_D&MI
               ELSE
                  IF MBRK2_C&MI = 0
                     STORE ITEM_PROM TO MBRK2_C&MI
                     STORE COM_CODE  TO MBRK2_D&MI
                  ELSE
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,1 SAY 'WARNING-MORE THAN TWO BROKERS ON THIS PRODUCT ' GET MWAIT
                     READ
                     GOTO BOTTOM
                  ENDIF
               ENDIF
            ENDIF
            SKIP
         ENDDO
         
         STORE 0 TO MUSR1_C&MI, MUSR2_C&MI, MUSR3_C&MI, MUSR4_C&MI
         *** CHECK FOR END USER PROMOTIONS - MAXIMUM OF FOUR ON EACH ITEM
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.COMMPROM INDEX &MDBFLOC.COMMPROM", .F.
         SEEK SUBSTR(MPROD&MI,1,6)
         DO WHILE .NOT. EOF() .AND. SUBSTR(MPROD&MI,1,6) = PROD_DESC
            IF B->DEL_REQD >= BEG_DT .AND. B->DEL_REQD <= END_DT
               DO CASE
               CASE MUSR1_C&MI = 0
                  STORE ITEM_PROM TO MUSR1_C&MI
                  STORE USERCODE  TO MUSR1_D&MI
               CASE MUSR2_C&MI = 0
                  STORE ITEM_PROM TO MUSR2_C&MI
                  STORE USERCODE  TO MUSR2_D&MI
               CASE MUSR3_C&MI = 0
                  STORE ITEM_PROM TO MUSR3_C&MI
                  STORE USERCODE  TO MUSR3_D&MI
               CASE MUSR4_C&MI = 0
                  STORE ITEM_PROM TO MUSR4_C&MI
                  STORE USERCODE  TO MUSR4_D&MI
               OTHERWISE
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  @ 24,1 SAY 'WARNING-MORE THAN FOUR USERS ON THIS PRODUCT ' GET MWAIT
                  READ
                  GOTO BOTTOM
               ENDCASE
            ENDIF
            SKIP
         ENDDO
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
         @ MLINE,4 SAY MPROD&MI
         
         IF MVIEW
            IF MCUS_C&MI <> 0
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
               SEEK B->BBUYCODE
               @ MLINE,11 SAY SUBSTR(NAME,1,5) + '-'
               @ MLINE,17 SAY MBUY_T&MI
               @ MLINE,19 SAY MBUY_C&MI PICTURE '#.####'
            ENDIF
            IF MBRK1_C&MI <> 0
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               SEEK MBRK1_D&MI
               @ MLINE,37 SAY SUBSTR(NAME,1,4)
               @ MLINE,42 SAY MBRK1_C&MI PICTURE '#.####'
            ENDIF
            IF MUSR1_C&MI <> 0
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.USER INDEX &MDBFLOC.USR_CODE", .F.
               SEEK MUSR1_D&MI
               @ MLINE,60 SAY SUBSTR(NAME,1,4)
               @ MLINE,65 SAY MUSR1_C&MI PICTURE '##.####'
            ENDIF
            
         ELSE
            
            IF MCUS_C&MI <> 0
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
               SEEK B->BBUYCODE
               @ MLINE,11 SAY SUBSTR(NAME,1,5) + '-'
               @ MLINE,17 SAY MCUS_T&MI
               @ MLINE,19 GET MCUS_C&MI PICTURE '#.####'
            ENDIF
            IF MBRK1_C&MI <> 0
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               SEEK MBRK1_D&MI
               @ MLINE,37 SAY SUBSTR(NAME,1,4)
               @ MLINE,42 GET MBRK1_C&MI PICTURE '#.####'
               
            ENDIF
            IF MUSR1_C&MI <> 0
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.USER INDEX &MDBFLOC.USR_CODE", .F.
               SEEK MUSR1_D&MI
               @ MLINE,60 SAY SUBSTR(NAME,1,4)
               @ MLINE,65 GET MUSR1_C&MI PICTURE '##.####'
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
      @ 24,0 SAY 'Action: ' + STR(MACTION,1)
      IF MVIEW
         @ 24,13 SAY '1. Continue    2. Edit     3. Cancel Prom View'
      ELSE
         @ 24,13 SAY '1. Continue    2. Edit     3. Cancel All Prom Updates'
         READ
      ENDIF
      
      MLINE = 7
      I = (MPAGE * 17) - 16
      DO WHILE MLINE <= 22 .AND. I <= MMAX_ITM
         *** SHOW ALL THIS INFO BACK
         MI = SUBSTR(STR(I+100,3),2)
         IF MREC&MI <> 0
            GOTO MREC&MI
            
            IF MCUS_C&MI <> 0
               @ MLINE,26 SAY ROUND(MBUY1_C&MI * LBS,2) PICTURE '99999.99'
            ENDIF
            
            IF MBRK1_C&MI <> 0
               @ MLINE,49 SAY ROUND(MBRK1_C&MI * LBS,2) PICTURE '99999.99'
            ENDIF
            
            IF MUSR1_C&MI <> 0
               @ MLINE,72 SAY ROUND(MUSR1_C&MI * LBS,2) PICTURE '99999.99'
            ENDIF
         ENDIF
         I = I + 1
         MLINE = MLINE + 1
      ENDDO
      @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
      READ
   ENDDO
   IF MACTION = 3
      MNBR_ITM = MMAX_ITM + 10
      LOOP
   ENDIF
   MPAGE = MPAGE + 1
ENDDO
IF MACTION = 3 .OR. MVIEW
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
   IF MBUY1_C&MI <> 0
      REPLACE PBUYCENT WITH MBUY1_C&MI
      REPLACE PBUYTYPE WITH MBUY1_T&MI
      REPLACE PBUYCALC WITH ROUND(MBUY1_C&MI * LBS,2)
   ENDIF
   IF MCOM1_C&MI <> 0        
      REPLACE PCOMCODE1 WITH MCOM1_D&MI 
      REPLACE PCOMCENT1 WITH MCOM1_C&MI
      REPLACE PCOMCALC1 WITH ROUND(MCOM1_C&MI * LBS,2)
   ENDIF
   IF MUSR1_C&MI <> 0
      REPLACE PUSRCODE1 WITH MUSR1_D&MI 
      REPLACE PUSRCENT1 WITH MUSR1_C&MI
      REPLACE PUSRCALC1 WITH ROUND(MUSR1_C&MI * LBS,2)
   ENDIF
   UNLOCK
   MNBR_ITM = MNBR_ITM + 1
ENDDO

MNBR_ITM = 1
DO WHILE MNBR_ITM <= MMAX_ITM
   MI = SUBSTR(STR(MNBR_ITM+100,3),2)
   RELEASE MPROD&MI, MREC&MI
   RELEASE MBUY_C&MI, MBUY_T&MI, MCOM1_C&MI, MCOM2_C&MI
   RELEASE MUSR1_C&MI, MUSR2_C&MI, MUSR3_C&MI, MUSR4_C&MI
   RELEASE MCOM1_D&MI, MCOM2_D&MI
   RELEASE MUSR1_D&MI, MUSR2_D&MI, MUSR3_D&MI, MUSR4_D&MI
   MNBR_ITM = MNBR_ITM + 1
ENDDO

*** FINISH UP - CALCULATE TOTALS FOR COMMISSION PEOPLES
MDOTHIS = .F.
IF MDOTHIS
   STORE 0 TO MTOT_COM1, MTOT_COM2, MTOT_COM3
   SELECT C
   SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
   DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX  
      MTOT_COM1 = MTOT_COM1 + ROUND(COM1_CENT * LBS,2)
      MTOT_COM2 = MTOT_COM2 + ROUND(COM2_CENT * LBS,2)
      MTOT_COM3 = MTOT_COM3 + ROUND(COM3_CENT * LBS,2)
      SKIP
   ENDDO
   
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
ENDIF

RETURN
* EOF: PROMO_PG.PRG
*Formatted by: ToolBox Ver. 1.2  on 4/6/6 at 3:27 AM.
