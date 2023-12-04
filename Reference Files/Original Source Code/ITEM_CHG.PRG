****************
* Program.: ITEM_CHG.PRG
* Author..: Grace Keller
* Date....: 10/19/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: ITEM PAGE EDIT - MULTIPLE PAGES
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
RELEASE MQTY
RELEASE MFR_FZ
RELEASE MGRADE
RELEASE MPAK  
RELEASE MCLASS
RELEASE MPROD
RELEASE MSIZE
RELEASE MPACKSPEC
RELEASE MLBS
RELEASE MPURC_PRI
RELEASE MSELL_PRI
RELEASE MPURC_TOT
RELEASE MSELL_TOT
RELEASE MSHRT_BOX
RELEASE MSHRT_LBS
RELEASE MBILL_PRI
RELEASE MPAK1  
RELEASE MPAK2  
RELEASE MBOX_SZ
RELEASE MOLD_LOT
RELEASE MOLD_LBS
RELEASE MOLD_QTY
RELEASE MOLD_PROD
RELEASE MIN_LOT
RELEASE MOUT_LOT
RELEASE MOLD_IN
RELEASE MOLD_OUT
RELEASE MSTOR_ITEM
RELEASE MPAK_YR
RELEASE MPAK_DAY
RELEASE Mout_YR
RELEASE Mout_DAY

DIMENSION MQTY(7)
DIMENSION MFR_FZ(7)
DIMENSION MGRADE(7)
DIMENSION MPAK(7)  
DIMENSION MCLASS(7)
DIMENSION MPROD(7)
DIMENSION MSIZE(7)
DIMENSION MPACKSPEC(7)
DIMENSION MLBS(7)
DIMENSION MPURC_PRI(7)
DIMENSION MSELL_PRI(7)
DIMENSION MPURC_TOT(7)
DIMENSION MSELL_TOT(7)
DIMENSION MSHRT_BOX(7)
DIMENSION MSHRT_LBS(7)
DIMENSION MBILL_PRI(7)
DIMENSION MPAK1(7)  
DIMENSION MPAK2(7)  
DIMENSION MBOX_SZ(7)
DIMENSION MOLD_LOT(7)
DIMENSION MOLD_LBS(7)
DIMENSION MOLD_QTY(7)
DIMENSION MOLD_PROD(7)
DIMENSION MIN_LOT(7)
DIMENSION MOUT_LOT(7)
DIMENSION MOLD_IN(7)
DIMENSION MOLD_OUT(7)
DIMENSION MSTOR_ITEM(7)
DIMENSION MPAK_YR(7)
DIMENSION MPAK_DAY(7)
DIMENSION Mout_YR(7)
DIMENSION Mout_DAY(7)

SELECT A
USE
DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
STORE TRAN_MO TO MTRAN_MO
STORE TRAN_YR TO MTRAN_YR
USE

IF B->BROKERAGE = 'H'
   SET PROC TO H_PROC
ELSE
   SET PROC TO I_PROC
ENDIF

MMORE_ITM = .T.
MPAGE = 1
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
MTITLE = ' - EDIT ITEMS'
@  2, 0 SAY MPROGRAM + MTITLE
@  2,45 SAY 'ORDER #:'
@ 2,55 SAY MSALESMAN
@ 2,57 SAY '-'
@ 2,58 SAY MPO_NBR
IF MPO_SUFFIX <> ' '
   @ 2,62 SAY '-'
   @ 2,63 SAY MPO_SUFFIX
ENDIF
DO TEXT2ND
DO TEXT3RD
@ 3,65 SAY 'ITEMS: PAGE'
SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
IF EOF()
   STORE 0 TO MITM_REC, MFST_REC
ELSE
   STORE RECNO() TO MITM_REC, MFST_REC
ENDIF

STORE 0 TO DTOT_SELL, DTOT_PURCH
DO WHILE MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX 
   DTOT_SELL = DTOT_SELL + TOT_SELL
   IF TOT_BILL <> 0
      DTOT_PURCH = DTOT_PURCH + TOT_BILL
   ELSE
      DTOT_PURCH = DTOT_PURCH + TOT_PURCH
   ENDIF
   SKIP
ENDDO

IF MFST_REC = 0
   GOTO BOTTOM
   SKIP
ELSE
   GOTO MFST_REC
ENDIF

MPAGE = 1

DO WHILE MMORE_ITM
   @ 08,00 CLEAR TO 22,80
   *** ZERO OUT THE STUFF
   MNBR_ITM = 1
   DO WHILE MNBR_ITM <= 7
      SELECT B
      STORE 0 TO MQTY(MNBR_ITM), MLBS(MNBR_ITM), MBOX_SZ(MNBR_ITM), MOLD_QTY(MNBR_ITM)
      STORE 0 TO MPURC_PRI(MNBR_ITM), MSELL_PRI(MNBR_ITM), MSTOR_ITEM(MNBR_ITM)
      STORE SPACE(2) TO MFR_FZ(MNBR_ITM)
      STORE SPACE(1) TO MPAK1(MNBR_ITM), MPAK2(MNBR_ITM), MGRADE(MNBR_ITM)
      IF MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
         STORE SPACE(6) TO MPROD(MNBR_ITM), MOLD_PROD(MNBR_ITM)
         STORE SPACE(6) TO MPACKSPEC(MNBR_ITM)
      ELSE
         STORE SPACE(6) TO MPROD(MNBR_ITM), MOLD_PROD(MNBR_ITM)
         STORE SPACE(6) TO MPACKSPEC(MNBR_ITM)
      ENDIF
      STORE SPACE(5) TO MSIZE(MNBR_ITM)
      STORE SPACE(10) TO MOUT_LOT(MNBR_ITM), MOLD_OUT(MNBR_ITM)
      STORE SPACE(10) TO MIN_LOT(MNBR_ITM), MOLD_IN(MNBR_ITM)
      STORE 0 TO MPAK_YR(MNBR_ITM), MPAK_DAY(MNBR_ITM)
      STORE 0 TO Mout_YR(MNBR_ITM), Mout_DAY(MNBR_ITM)
      MNBR_ITM = MNBR_ITM + 1
   ENDDO
   
   MNBR_ITM = 1
   
   SELECT C
   
   IF MITM_REC <> 0
      GOTO MITM_REC
   ELSE
      GOTO BOTTOM
      SKIP
   ENDIF
   
   DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. VAL(ITEM_NBR) <= (MPAGE * 7)
      DO STORITM
      MNBR_ITM = MNBR_ITM + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
      MBLURP = .T.
      STORE RECNO() TO MITM_REC
   ELSE
      MBLURP = .F.
      STORE 0 TO MITM_REC   
   ENDIF
   
   MLINE = 08 
   @ 8,0 CLEAR TO 22,80
   MNBR_ITM = 1
   DO WHILE MNBR_ITM <= 7           
      IF MPROD(MNBR_ITM) <> SPACE(6)
         DO SAYITM 
      ENDIF
      MLINE = MLINE + 2
      MNBR_ITM = MNBR_ITM + 1
   ENDDO
   
   IF MBLURP
      @ 23,67 SAY 'More Items..'
   ELSE
      @ 23,67 SAY SPACE(12)
   ENDIF
   @ 3,77 SAY STR(MPAGE,2)
   
   STORE 2 TO MACTION
   DO WHILE MACTION = 2
      MLINE = 08 
      MNBR_ITM = 1
      
      MNEXT_ITM = .T.
      DO WHILE MLINE <= 20 .AND. MNEXT_ITM
         IF MPROD(MNBR_ITM) = SPACE(6)
            DO GETITM

         IF MPROD(MNBR_ITM) <> SPACE(6) .AND. MSELL_PRI(MNBR_ITM) = 0

            @ 24,0 CLEAR
            MOK = SPACE(4)

            DO WHILE MOK <> 'OK  ' .AND. MOK <> 'EDIT'
               @ 24,1 SAY "SELL PRICE IS ZERO-ENTER 'OK' TO CONT- OR 'EDIT' TO CHANGE" GET MOK PICTURE '@!'
               READ
               IF MOK <> 'OK' .AND. MOK <> 'EDIT'
                  STORE 'Invalid Input' to minv_err
                  @ 24,66 GET MINV_ERR
                  READ
               ENDIF
            ENDDO
            IF MOK = 'EDIT'
               @ 24,1 SAY SPACE(78)
               LOOP
            ENDIF
            @ 24,1 SAY SPACE(78)
         ENDIF


            IF .NOT. MNEXT_ITM
               LOOP
            ENDIF
            *** TENDERS PROCESSING
            *** cant write this back if div 11, coming out of inventory, and
            *** is not current processing month
            IF B->BROKERAGE <> 'H' .AND. B->RSUPCODE = 'INVN' 
               *** IF TENDERS - PRODUCT 8901, 8910, 8989, 8999
               IF SUBSTR(MPROD(MNBR_ITM),1,4) = '8901' .OR. SUBSTR(MPROD(MNBR_ITM),1,4) = '8910' .OR. SUBSTR(MPROD(MNBR_ITM),1,4) = '8989' .OR. SUBSTR(MPROD(MNBR_ITM),1,4) = '8999'
                  STORE MONTH(B->SHIP_DATE) TO MSHIP_MO
                  MSHIP_MO = SUBSTR(STR(MSHIP_MO+100,3),2) 
                  STORE STR(YEAR(B->SHIP_DATE),4)  TO MSHIP_YR
                  *IF VAL(MSHIP_YR+MSHIP_MO) < VAL(MTRAN_YR+MTRAN_MO)
                  *   *** this is an error
                  *   @ 24,4 CLEAR
                  *   STORE ' ' TO MWAIT               
                  *   @ 24,1 SAY 'CANNOT ADD ITEM - TENDERS OUT OF INVN -CHECK WITH ACCTG ' GET MWAIT
                  *   READ
                  *   @ 24,0 CLEAR
                  *   LOOP
                  *ENDIF
               ENDIF
            ENDIF
            
            *** WRITE THIS RECORD BACK NOW
            X = (MLINE/2) -3
            I = ((MPAGE-1)*7) + X
            *** I IS THE ITEM NUMBER
            *** X IS THE ARRAY NUMBER
            *** SAVE ALL INFO BACK TO ITEM RECORD
            MAPPEND = .F.
            MPRICE_CHG = .F.
            DO REPLITM
            
            SELECT C
            IF B->BBUYCODE = 'INVN' .AND. MPRICE_CHG
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT               
               @ 24,1 SAY 'PRICE CHANGE GOING INTO INVEN - MUST CHECK ORDERS SHIPPED OUT ' GET MWAIT
               READ
               @ 24,0 CLEAR
            ENDIF
         ELSE
            DO HIGHITM
            *** TENDERS PROCESSING
            *** NEW STUFF HERE AS OF 09/01/04 - CANNOT CORRECT OUT OF INVN
            *** ITEM IF NOT CURRENT PROCESSING MONTH
            IF B->BROKERAGE <> 'H' .AND. B->RSUPCODE = 'INVN' 
               *** IF TENDERS - PRODUCT 8901, 8910, 8989, 8999
               IF SUBSTR(MPROD(MNBR_ITM),1,4) = '8901' .OR. SUBSTR(MPROD(MNBR_ITM),1,4) = '8910' .OR. SUBSTR(MPROD(MNBR_ITM),1,4) = '8989' .OR. SUBSTR(MPROD(MNBR_ITM),1,4) = '8999'
                  STORE MONTH(B->SHIP_DATE) TO MSHIP_MO
                  MSHIP_MO = SUBSTR(STR(MSHIP_MO+100,3),2) 
                  STORE STR(YEAR(B->SHIP_DATE),4)  TO MSHIP_YR
                  IF VAL(MSHIP_YR+MSHIP_MO) <> VAL(MTRAN_YR+MTRAN_MO)
                     **STORE 'N' TO MPICK
                     STORE ' ' TO MPICK
                  ELSE
                     STORE ' ' TO MPICK
                  ENDIF
                  RELEASE MSHIP_MO, MSHIP_YR
               ELSE
                  STORE ' ' TO MPICK
               ENDIF
            ELSE
               STORE ' ' TO MPICK
            ENDIF
            
            IF MPICK = 'N'
               @ MLINE,0 GET MPICK PICTURE '@!' VALID(MPICK = 'N')
            ELSE
               @ MLINE,0 GET MPICK PICTURE '@!'
            ENDIF
            READ
            DO CLEAROUT
            DO SAYITM
            
            DO CASE
            CASE MPICK = 'C' .OR. MPICK = 'X'
               STORE MLINE TO MSAVE_LINE
               STORE MNBR_ITM TO MSAVE_ITM
               X = (MLINE/2) -3
               I = ((MPAGE-1)*7) + X
               SAVE SCREEN TO MEDIT_SCR
               MAPPEND = .F.
               DO NCOR_ITM
               RESTORE SCREEN FROM MEDIT_SCR
               STORE MSAVE_LINE TO MLINE
               STORE MSAVE_ITM TO MNBR_ITM
               DO SAYITM
               @ MLINE,0 SAY ' '
            CASE MPICK = 'D'
               IF MQTY(MNBR_ITM) = 0
                  SELECT C
                  I = ((MPAGE - 1) * 7) + MNBR_ITM
                  SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + STR(I,2)
                  IF .NOT. EOF()
                     IF QTY = 0
                        DO RECLOCK
                        DELETE
                        UNLOCK
                        IF B->RSUPCODE = 'INVN' .OR. B->BBUYCODE = 'INVN'
                           SELECT E
                           ************************************************
                           *** DETAIL HOLD INVN RECORD PROCESSING
                           ************************************************
                           DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT", .F.
                           DO WHILE .NOT. EOF()
                              IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. ITEM_NBR = STR(I,2) .AND. QTY = 0
                                 DO RECLOCK
                                 DELETE
                                 UNLOCK
                                 GOTO BOTTOM
                              ENDIF
                              SKIP
                           ENDDO
                           *** IF GOING INTO INVENTORY - DELETE OUT OF HEADER
                           IF B->BBUYCODE = 'INVN'
                              DO FOX_USE WITH "HINVEN INDEX HINVNLOC, HINVSOLD", .F.
                              DO WHILE .NOT. EOF()
                                 IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. LOT_NBR = IN_LOT(MNBR_ITM) .AND. CASE_CNT = 0
                                    DO RECLOCK
                                    DELETE
                                    UNLOCK
                                    GOTO BOTTOM
                                 ENDIF
                                 SKIP
                              ENDDO
                           ENDIF
                           USE
                        ENDIF
                     ELSE
                        @ 25,0 CLEAR
                        STORE 'CANNOT DELETED - ITEM RCD QTY NOT ZERO - PRESS RETURN TO CONT' TO MWAIT
                        @ 25,1 GET MWAIT
                        READ
                        @ 25,0 CLEAR
                     ENDIF
                  ENDIF
               ELSE
                  @ 25,0 CLEAR
                  STORE 'CANNOT DELETED - QTY NOT ZERO - PRESS RETURN TO CONT' TO MWAIT
                  @ 25,1 GET MWAIT
                  READ
                  @ 25,0 CLEAR
               ENDIF
               @ MLINE,0 SAY ' '
            OTHERWISE
               @ MLINE,0 SAY ' '
            ENDCASE
         ENDIF
         
         MLINE = MLINE + 2
         IF MLINE <= 20
            MNBR_ITM = MNBR_ITM + 1
         ELSE
            MNEXT_ITM = .F.
         ENDIF
         
      ENDDO
      
      IF MBLURP
         STORE 4 TO MACTION
      ELSE
         STORE 1 TO MACTION
      ENDIF
      @ 25,0 SAY 'Action: ' + STR(MACTION,1)
      @ 25,13 SAY '1. Continue    2. Edit    3. Previous Pg.   4. Next Itm Pg.' 
      @ 25,8 GET MACTION PICTURE '#' RANGE 1,4
      READ      
      IF MACTION <> 2 .AND. MACTION <> 4
         *** IF NOT ON HOLD - DO NOT LET OFF THIS PAGE IF NO LOT INFO ENTERED
         IF MBBUYCODE = 'INVN' .OR. MRSUPCODE = 'INVN'
            *** ONLY CHECK THOSE SHIPPED AFTER 3/31/02
            IF B->SHIP_DATE > CTOD('03/31/2002')
               *** DO NOT LET OFF THIS ITEM PAGE IF LOT INFORMATION NOT ENTERED
               *** CHECK FOR ALL THE LOT INFO NEEDED
               SELECT C
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               MERROR = .F.
               DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
                  IF QTY <> 0  .AND. B->BROKERAGE <> 'H'
                     IF MBBUYCODE = 'INVN'
                        IF IN_LOT = SPACE(10)
                           @ 25,0 CLEAR
                           MWAIT = ' '
                           @ 25,0 SAY 'ORDER NOT ON HOLD - LOT INFO MUST BE ENTERED ' GET MWAIT
                           READ
                           @ 25,0 CLEAR
                           GOTO BOTTOM
                           MERROR = .T.
                        ENDIF
                     ELSE
                        IF OUT_LOT = SPACE(10)
                           @ 25,0 CLEAR
                           MWAIT = ' '
                           @ 25,0 SAY 'ORDER NOT ON HOLD - LOT INFO MUST BE ENTERED ' GET MWAIT
                           READ
                           @ 25,0 CLEAR
                           GOTO BOTTOM
                           MERROR = .T.
                        ENDIF
                     ENDIF
                  ENDIF
                  SKIP
               ENDDO
               IF MERROR
                  MACTION = 2
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDDO
   DO CASE      
   CASE MACTION = 1 .OR. MACTION = 3 .OR. MACTION = 4
      IF MACTION <> 4
         MMORE_ITM = .F.
      ELSE
         MPAGE = MPAGE + 1
      ENDIF
      
   CASE MACTION = 2
      STORE MFST_REC TO MITM_REC
      LOOP        
      
   ENDCASE 
ENDDO 

*** FINISH UP - CALCULATE TOTALS FOR ITEMS
STORE 0 TO MTOT_SELL, MTOT_PURCH, MTOT_LBS, MTLBS_CALC, MTOT_STOR
SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
DO WHILE MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX  .AND. .NOT. EOF()
   MTOT_SELL = MTOT_SELL + TOT_SELL
   IF TOT_BILL <> 0
      MTOT_PURCH = MTOT_PURCH + TOT_BILL
   ELSE
      MTOT_PURCH = MTOT_PURCH + TOT_PURCH
   ENDIF
   
   IF SUBSTR(PACKED,1,1) = 'B'
      MCALC_LBS = VAL(SUBSTR(PACKED,2)) * LBS
   ELSE
      MCALC_LBS = LBS
   ENDIF
   
   DO RECLOCK
   REPLACE CALC_LBS WITH MCALC_LBS
   UNLOCK
   
   IF MCOMPANY = 'DIVISON 15' .OR. MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
      MTLBS_CALC = MTLBS_CALC + MCALC_LBS
      MTOT_LBS = MTOT_LBS + MCALC_LBS
   ELSE
      MTOT_LBS = MTOT_LBS + MCALC_LBS
   ENDIF
   SKIP
ENDDO

SELECT B 
DO RECLOCK
*** FOR AMERICHICKEN, ITS THE QTY SHIPPED - NOT LBS
IF MCOMPANY = 'MIDWEST FOOD -DIV 11' .OR. MCOMPANY = 'AMERICHICKEN, INC'
   REPLACE TOT_LBS WITH MTLBS_CALC
ELSE
   REPLACE TOT_LBS WITH MTOT_LBS
ENDIF
UNLOCK

**** STARTING BROKER STUFF
IF DTOT_SELL <> MTOT_SELL
   IF  B->BBUYCODE <> 'NONE' .AND. B->BBUYCODE <> 'I' .AND. B->INV_NBR <> SPACE(5)
      STORE B->INV_NBR TO MINV_NBR
      MALL_PAID = .T.
      SELECT E
      DO FOX_USE WITH "CUS_INV INDEX CUSIVNBR, CUS_INV, CUS_DATE, CUS_SHIP", .F.
      SEEK MINV_NBR
      DO WHILE .NOT. EOF() .AND. INV_NBR = MINV_NBR .AND. MALL_PAID 
         IF PAID_FLG <> ' ' .OR. CRED_PAY <> ' '
            SKIP
            LOOP
         ENDIF
         MALL_PAID = .F.
      ENDDO
      DO CASE
      CASE MALL_PAID 
         SELECT E
         DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
         DO FILELOCK
         APPEND BLANK
         REPLACE salesman   WITH B->salesman  
         REPLACE po_nbr     WITH B->po_nbr    
         REPLACE po_suffix  WITH B->po_suffix 
         REPLACE buy_code   WITH B->buy_code  
         REPLACE bbuycode   WITH B->bbuycode  
         REPLACE ship_date  WITH B->ship_date 
         REPLACE tot_sell   WITH MTOT_SELL - DTOT_SELL      
         REPLACE INV_NBR WITH MINV_NBR
         REPLACE DEB_CRD WITH 'Y'    
         REPLACE INV_DATE   WITH DATE()       
         FLUSH
         UNLOCK
      OTHERWISE
         DO RECLOCK 
         REPLACE TOT_SELL   WITH TOT_SELL + (MTOT_SELL - DTOT_SELL)    
         UNLOCK
      ENDCASE
   ENDIF
ENDIF 
IF DTOT_PURCH <> MTOT_PURCH
   IF  B->RSUPCODE <> 'NONE' .AND. B->RSUPCODE <> 'I' .AND. B->INV_NBR <> SPACE(5)
      DO CASE
         *** NO SUPPLIER INVOICE RECEIVED
      CASE B->SUP_REC = ' '
         *** SUPPLIER INV RECEIVED, BUT NOT PAID
      CASE B->SUP_REC <> ' ' .AND. B->SUP_PD = ' '
         SELECT E
         DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
         SEEK B->RSUPCODE
         DO WHILE .NOT. EOF() .AND. RSUPCODE = B->RSUPCODE
            IF SALESMAN = B->SALESMAN .AND. PO_NBR = B->PO_NBR .AND. PO_SUFFIX = B->PO_SUFFIX
               DO RECLOCK
               DELETE
               UNLOCK
               GOTO BOTTOM
            ENDIF
            SKIP
         ENDDO
         SELECT B
         DO RECLOCK
         REPLACE SUP_REC WITH ' '
         UNLOCK
         *** SUPPLIER INVOICE RECEIVED AND PAID
      CASE B->SUP_REC <> ' ' .AND. B->SUP_PD <> ' '
         SELECT E
         DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
         SEEK B->RSUPCODE
         MFOUND = .F.
         DO WHILE .NOT. EOF() .AND. RSUPCODE = B->RSUPCODE .AND. .NOT. MFOUND
            IF SALESMAN = B->SALESMAN .AND. PO_NBR = B->PO_NBR .AND. PO_SUFFIX = B->PO_SUFFIX
               MFOUND = .T.
               LOOP
            ENDIF
            SKIP
         ENDDO
         IF MFOUND
            DO FILELOCK
            REPLACE AMT_DUE WITH AMT_DUE + (MTOT_PURCH - DTOT_PURCH)
            REPLACE PRT_ADV WITH ' '
            UNLOCK
         ELSE
            SELECT D
            DO FOX_USE WITH "DISBJRN INDEX DISB_PO", .F.
            SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX + 'S'
            IF .NOT. EOF()
               STORE BILL_INV TO MSUP_INV
            ELSE
               STORE SPACE(12) TO MSUP_INV
            ENDIF
            SELECT E
            DO FILELOCK
            APPEND BLANK
            REPLACE salesman   WITH B->salesman  
            REPLACE po_nbr     WITH B->po_nbr    
            REPLACE po_suffix  WITH B->po_suffix 
            REPLACE RSUPCODE   WITH B->RSUPCODE    
            REPLACE AMT_DUE WITH MTOT_PURCH - DTOT_PURCH
            REPLACE INV_NBR    WITH B->inv_nbr      
            REPLACE DUE_DATE WITH DATE()
            REPLACE REASON WITH 'ITEM ADJ.' 
            REPLACE SUP_INV WITH MSUP_INV
            REPLACE DEB_CRD WITH 'Y'
            REPLACE SEQ WITH '1'
            UNLOCK
         ENDIF
      ENDCASE
   ENDIF
ENDIF
SET PROCEDURE TO PO_PROC 
IF MACTION = 1
   MGOTO_PG = 3
ELSE
   MGOTO_PG = 1
ENDIF
RETURN
* EOF: ITEM_CHG.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/7/16 at 5:00 PM.
