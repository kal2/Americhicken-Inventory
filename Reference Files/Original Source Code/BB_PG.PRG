**********
* Program.: BB_PG.PRG
* Author..: Grace Keller
* Date....: 10/19/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: BILLBACK PO DETAIL AMOUNTS - PRIMARY/SECONDAY
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
IF EOF()
   RETURN
ENDIF
SELECT A
DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
SEEK B->BBUYCODE
STORE FED_CUST TO MFED_CUST
USE
SELECT C
MPAGE = 1
@ 2,40 SAY SPACE(39)
@ 3,0 CLEAR
@ 3,1 SAY 'PAGE:'
@ 2,34 SAY '1. 3RD BB:'
@ 3,34 SAY '2. 3RD BB:'
@ 4,34 SAY '3. 3RD BB:'
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
@ 23,0 to 25,79

STORE B->BB_CODE  TO MBB_CODE
STORE B->BB_CODE2 TO MBB_CODE2
STORE B->BB_CODE3 TO MBB_CODE3

SELECT A
DO FOX_USE WITH "&MMASTDBF.BILLBACK INDEX &MMASTDBF.BB_CODE", .F.
IF MBB_CODE <> SPACE(2)
   SEEK MBB_CODE
   IF .NOT. EOF()
      STORE SUBSTR(NAME,1,25) TO MBB_NAME
   ELSE  
      STORE '3RD PARTY BB NOT ON FILE ' TO MBB_NAME
   ENDIF
ELSE
   STORE SPACE(25) TO MBB_NAME
ENDIF

IF MBB_CODE2 <> SPACE(2)
   SEEK MBB_CODE2
   IF .NOT. EOF()
      STORE SUBSTR(NAME,1,25) TO MBB_NAME2
   ELSE  
      STORE '3RD PARTY BB NOT ON FILE ' TO MBB_NAME2
   ENDIF
ELSE
   STORE SPACE(25) TO MBB_NAME2
ENDIF

IF MBB_CODE3 <> SPACE(2)
   SEEK MBB_CODE3
   IF .NOT. EOF()
      STORE SUBSTR(NAME,1,25) TO MBB_NAME3
   ELSE  
      STORE '3RD PARTY BB NOT ON FILE' TO MBB_NAME3
   ENDIF
ELSE
   STORE SPACE(25) TO MBB_NAME3
ENDIF


IF MVIEW
   @ 2,46 SAY MBB_NAME
   @ 3,46 SAY MBB_NAME2
   @ 4,46 SAY MBB_NAME3
ELSE
   MACTION = 2
   DO WHILE MACTION = 2
      @ 2,46 GET MBB_NAME PICTURE '@!'
      READ
      IF MBB_NAME <> SPACE(25)
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.BILLBACK INDEX &MMASTDBF.BB_NAME", .F.
         MBB_FD = .F.
         STORE TRIM(MBB_NAME) TO SRCH_ARG
         DO BB_SEL2
         IF .NOT. MBB_FD
            MBB_NAME = SPACE(25)
            MBB_CODE = SPACE(2)
         ELSE
            STORE SUBSTR(NAME,1,25) TO MBB_NAME
            STORE BB_CODE TO MBB_CODE
         ENDIF
         @  2,46 SAY MBB_NAME
      ELSE
         STORE '  ' TO MBB_CODE
      ENDIF
      
      @ 3,46 GET MBB_NAME2 PICTURE '@!'
      READ
      IF MBB_NAME2 <> SPACE(25)
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.BILLBACK INDEX &MMASTDBF.BB_NAME", .F.
         MBB_FD = .F.
         STORE TRIM(MBB_NAME2) TO SRCH_ARG
         DO BB_SEL2
         IF .NOT. MBB_FD
            MBB_NAME2 = SPACE(25)
            MBB_CODE2 = SPACE(2)
         ELSE
            STORE SUBSTR(NAME,1,25) TO MBB_NAME2
            STORE BB_CODE TO MBB_CODE2
         ENDIF
         @  3,46 SAY MBB_NAME2
      ELSE
         STORE '  ' TO MBB_CODE2
      ENDIF
      
      @ 4,46 GET MBB_NAME3 PICTURE '@!'
      READ
      IF MBB_NAME3 <> SPACE(25)
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.BILLBACK INDEX &MMASTDBF.BB_NAME", .F.
         MBB_FD = .F.
         STORE TRIM(MBB_NAME3) TO SRCH_ARG
         DO BB_SEL2
         IF .NOT. MBB_FD
            STORE SPACE(25) TO MBB_NAME3
            STORE SPACE(2) TO MBB_CODE3
         ELSE
            STORE SUBSTR(NAME,1,25) TO MBB_NAME3
            STORE BB_CODE TO MBB_CODE3
         ENDIF
         @  4,46 SAY MBB_NAME3
      ELSE
         STORE '  ' TO MBB_CODE3
      ENDIF
      MACTION = 1
      @ 24,0 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2. Edit'
      @ 24,8 GET MACTION PICTURE '#' RANGE 1,2
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
   STORE BB1_CENT TO MBB1_C&MI
   STORE BB2_CENT TO MBB2_C&MI
   STORE BB3_CENT TO MBB3_C&MI
   STORE RECNO()   TO MREC&MI
   STORE PROD_DESC TO MPROD&MI
   IF .NOT. MVIEW
      *** ONLY PICK UP ON PO ADD OR ON PO'S SHIPPED AFTER 07/15/2003
      MCUTOFF = CTOD('07/15/2003')
      IF MPO_ADD .OR. B->SHIP_DATE >= MCUTOFF
         
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.BROK_FEE INDEX &MMASTDBF.BROK_FEE", .F.
         
         IF MBB1_C&MI >= 0
            IF MBB_CODE <> SPACE(2)
               SEEK MBB_CODE + SUBSTR(MPROD&MI,1,4)
               IF .NOT. EOF()
                  STORE BROK_FEE TO MBB1_C&MI
               ENDIF
            ENDIF
         ENDIF
         
         IF MBB2_C&MI >= 0
            IF MBB_CODE2 <> SPACE(2)
               SEEK MBB_CODE2 + SUBSTR(MPROD&MI,1,4)
               IF .NOT. EOF()
                  STORE BROK_FEE TO MBB2_C&MI
               ENDIF
            ENDIF
         ENDIF
         
         IF MBB3_C&MI >= 0
            IF MBB_CODE3 <> SPACE(2)
               SEEK MBB_CODE3 + SUBSTR(MPROD&MI,1,4)
               IF .NOT. EOF()
                  STORE BROK_FEE TO MBB3_C&MI
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
            @ MLINE,17 SAY MBB1_C&MI PICTURE '##.####'
            @ MLINE,27 SAY MBB2_C&MI PICTURE '##.####'
            @ MLINE,37 SAY MBB3_C&MI PICTURE '##.####'
         ELSE
            @ MLINE,17 GET MBB1_C&MI PICTURE '##.####'
            @ MLINE,27 GET MBB2_C&MI PICTURE '##.####'
            @ MLINE,37 GET MBB3_C&MI PICTURE '##.####'
         ENDIF
         MLINE = MLINE + 1
         MNBR_ITM = MNBR_ITM + 1
      ENDDO
      IF MNBR_ITM <= MMAX_ITM
         @ 23,67 SAY 'More Items...'
      ELSE
         @ 23,67 TO 24,79
      ENDIF
      STORE 1 TO MACTION
      @ 24,0 SAY 'Action: ' + STR(MACTION,1)
      IF MVIEW
         @ 24,13 SAY '1. Continue    2. Edit     3. Cancel BBm View'
      ELSE
         @ 24,13 SAY '1. Continue    2. Edit     3. Cancel All BBm Updates'
         READ
      ENDIF
      
      MLINE = 7
      I = 1
      DO WHILE MLINE <= 22 .AND. I <= MMAX_ITM
         *** SHOW ALL THIS INFO BACK
         MI = SUBSTR(STR(I+100,3),2)
         IF MREC&MI <> 0
            GOTO MREC&MI
            @ MLINE,48 SAY ROUND(MBB1_C&MI * LBS,2) PICTURE '99,999.99'
            @ MLINE,59 SAY ROUND(MBB2_C&MI * LBS,2) PICTURE '99,999.99'
            @ MLINE,70 SAY ROUND(MBB3_C&MI * LBS,2) PICTURE '99,999.99'
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
   REPLACE BB1_CENT WITH MBB1_C&MI
   REPLACE BB2_CENT WITH MBB2_C&MI
   REPLACE BB3_CENT WITH MBB3_C&MI
   UNLOCK
   MNBR_ITM = MNBR_ITM + 1
ENDDO

MNBR_ITM = 1
DO WHILE MNBR_ITM <= MMAX_ITM
   MI = SUBSTR(STR(MNBR_ITM+100,3),2)
   RELEASE MREC&MI, MBB1_C&MI, MBB2_C&MI, MPROD&MI, MBB3_C&MI
   MNBR_ITM = MNBR_ITM + 1
ENDDO

*** FINISH UP - CALCULATE TOTALS FOR COMMISSION PEOPLES
STORE 0 TO MTOT_BB1, MTOT_BB2, MTOT_BB3
SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX  
   MTOT_BB1 = MTOT_BB1 + ROUND(BB1_CENT * LBS,2)
   MTOT_BB2 = MTOT_BB2 + ROUND(BB2_CENT * LBS,2)
   MTOT_BB3 = MTOT_BB3 + ROUND(BB3_CENT * LBS,2)
   SKIP
ENDDO

***STORE B->BB_CODE  TO MBB_CODE
***STORE B->BB_CODE2 TO MBB_CODE2
***STORE B->BB_CODE3 TO MBB_CODE3
DO CASE
CASE MCOMPANY = 'AMERICHICKEN, INC' .AND. B->INV_FLG <> ' '
   ***** CHECK OUT FOR THE FIRST THIRD PARTY COMMISSION
   IF  B->BBM_AMT <> MTOT_BB1
      STORE B->BBM_AMT TO MOLD_AMT
      STORE B->BB_CODE TO MOLD_CODE
      SELECT D
      DO FOX_USE WITH "BBTHD INDEX BBTHD, BBTDT, BBTPD", .F.
      *** LOOK FOR A NOT PAID INVOICE ENTRY 
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '1' + ' I'
      IF .NOT. EOF()
         DO RECLOCK
         REPLACE BB_CODE WITH MBB_CODE
         REPLACE AMOUNT WITH MTOT_BB1
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
               STORE BB_CODE TO MOLD_CODE
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
            REPLACE BB_TYPE WITH 'T'
            REPLACE AMOUNT WITH (-1) * MOLD_AMT
            REPLACE BB_CODE WITH MOLD_CODE
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
            REPLACE BB_TYPE WITH 'T'
         ENDIF
         DO RECLOCK
         REPLACE BB_CODE WITH MBB_CODE
         REPLACE AMOUNT WITH MTOT_BB1
         UNLOCK
      ENDIF
   ENDIF   
   ***** CHECK OUT FOR THE SECOND THIRD PARTY COMMISSION
   IF B->BBM_AMT2 <> MTOT_BB2
      STORE B->BBM_AMT2 TO MOLD_AMT2
      STORE B->BB_CODE2 TO MOLD_CODE2
      SELECT D
      DO FOX_USE WITH "BBTHD INDEX BBTHD, BBTDT, BBTPD", .F.
      *** LOOK FOR A NOT PAID INVOICE ENTRY
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '2' + ' I'
      IF .NOT. EOF()
         DO RECLOCK
         REPLACE BB_CODE WITH MBB_CODE2
         REPLACE AMOUNT WITH MTOT_BB2
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
               STORE BB_CODE TO MOLD_CODE2
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
            REPLACE BB_TYPE WITH 'T'
            REPLACE AMOUNT WITH (-1) * MOLD_AMT2
            REPLACE BB_CODE WITH MOLD_CODE2
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
            REPLACE BB_TYPE WITH 'T'
         ENDIF
         DO RECLOCK
         REPLACE BB_CODE WITH MBB_CODE2
         REPLACE AMOUNT WITH MTOT_BB2
         UNLOCK
      ENDIF
   ENDIF   
   
   
   ***** CHECK OUT FOR THE 3RD THIRD PARTY COMMISSION
   IF B->BBM_AMT3 <> MTOT_BB3
      STORE B->BBM_AMT3 TO MOLD_AMT3
      STORE B->BB_CODE3 TO MOLD_CODE3
      SELECT D
      DO FOX_USE WITH "BBTHD INDEX BBTHD, BBTDT, BBTPD", .F.
      *** LOOK FOR A NOT PAID INVOICE ENTRY
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + '3' + ' I'
      IF .NOT. EOF()
         DO RECLOCK
         REPLACE BB_CODE WITH MBB_CODE3
         REPLACE AMOUNT WITH MTOT_BB3
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
               REPLACE CENT&MI WITH C->BB3_CENT
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
               STORE BB_CODE TO MOLD_CODE2
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
            REPLACE BB_TYPE WITH 'T'
            REPLACE AMOUNT WITH (-1) * MOLD_AMT3
            REPLACE BB_CODE WITH MOLD_CODE3
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
         DO FOX_USE WITH "BBTHD INDEX BBTHD, BBTDT, BBTPD", .F.
                           
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
            REPLACE BB_TYPE WITH 'T'
         ENDIF
         DO RECLOCK
         REPLACE BB_CODE WITH MBB_CODE3
         REPLACE AMOUNT WITH MTOT_BB3
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
               REPLACE CENT&MI WITH C->BB3_CENT
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
REPLACE BBM_AMT WITH MTOT_BB1
REPLACE BBM_AMT2 WITH MTOT_BB2
REPLACE BBM_AMT3 WITH MTOT_BB3
UNLOCK

RETURN
* EOF: BB_PG.PRG
*Formatted by: ToolBox Ver. 1.2  on 8/5/4 at 11:04 AM.
