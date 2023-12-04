**********
* Program.: PO_SHORT.PRG
* Author..: Grace Keller
* Date....: 11/03/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PURCHASE ORDER SHORTWEIGHTS
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
DIMENSION MQTY(25)
DIMENSION MFR_FZ(15)
DIMENSION MGRADE(15)
DIMENSION MPAK(15)  
DIMENSION MCLASS(15)
DIMENSION MPROD(15)
DIMENSION MSIZE(15)
DIMENSION MPACKSPEC(15)
DIMENSION MLBS(15)
DIMENSION MPURC_PRI(15)
DIMENSION MSELL_PRI(15)
DIMENSION MPURC_TOT(15)
DIMENSION MSELL_TOT(15)
DIMENSION MSHRT_BOX(15)
DIMENSION MSHRT_LBS(15)
DIMENSION MBILL_PRI(15)
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
STORE DATE() TO MDATE
STORE TIME() TO MTIME
SELECT B
IF (RSUPCODE <> 'NONE' .AND. RSUPCODE <> 'INVN' .AND. SUP_PD <> ' ') .OR. (BBUYCODE <> 'NONE' .AND. BBUYCODE <> 'INVN' .AND. PAID_FLG <> ' ')
   @ 3,0 CLEAR
   IF MSALESMAN <> '  '
      MSAY_PO = MSALESMAN + '-' + MPO_NBR
   ELSE
      MSAY_PO = MPO_NBR
   ENDIF
   IF MPO_SUFFIX <> ' '
      MSAY_PO = MSAY_PO + '-' + MPO_SUFFIX
   ENDIF
   MTITLE = ' - ENTER SHORTWEIGHTS FOR PO NBR ' + MSAY_PO
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,78
   @ 10,05 SAY 'Payment has already been made to the supplier or the customer'
   @ 12,05 SAY 'has already paid Midwest.  Appropriate adjustment entries will be made'
   @ 14,05 say '(Customer - on Receipt Screen  /or/  Supplier - on Approval Screen).'
   STORE 'N' TO MYES_NO
   @ 17,05 SAY 'ARE YOU SURE YOU WANT TO CONTINUE (Y/N)? ' GET MYES_NO PICTURE '@!'
   READ
   IF MYES_NO <> 'Y'
      RETURN
   ENDIF
ENDIF

SET PROC TO PO_PROC
DO STORHEAD
STORE SUP_CODE TO MSUP_CODE
STORE BUY_CODE TO MBUY_CODE
STORE SALESMAN TO MSALESMAN
STORE RSUPCODE TO SRSUPCODE
STORE BBUYCODE TO SBBUYCODE
STORE SALESMAN TO SSALESMAN
STORE FRT_CODE1 TO SFRT_CODE1
STORE COM_CODE TO SCOM_CODE
STORE COM_CODE2 TO SCOM_CODE2
STORE COM_CODE3 TO SCOM_CODE3
STORE SAL_CODE2 TO SSAL_CODE2
STORE SAL_CODE3 TO SSAL_CODE3
IF FRT2_FLG <> ' '
   SELECT A
   DO FOX_USE WITH "FRT_2ND INDEX FRT2_PO, FRT2_FRT", .F.
   SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX       
   SFRT_CODE2 = FRT_CODE2
   SFRT_AMT2  = FRT_AMT2
   MFRT_AMT2  = FRT_AMT2
   MFRT_CODE2 = FRT_CODE2
   USE
   SELECT B
ELSE
   SFRT_AMT2 = 0
   SFRT_CODE2 = SPACE(4)
   MFRT_AMT2  = 0
   FRT_CODE2  = SPACE(4)
ENDIF
IF FRT3_FLG <> ' '
   SELECT A
   DO FOX_USE WITH "FRT_3RD INDEX FRT3_PO, FRT3_FRT", .F.
   SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX       
   SFRT_CODE3 = FRT_CODE3
   SFRT_AMT3  = FRT_AMT3
   MFRT_AMT3  = FRT_AMT3
   MFRT_CODE3 = FRT_CODE3
   USE
   SELECT B
ELSE
   SFRT_AMT3 = 0
   SFRT_CODE3 = SPACE(4)
   MFRT_AMT3  = 0
   FRT_CODE3  = SPACE(4)
ENDIF

DO 8910_TOT
DO HEAD_TOT
DO SAVE_TOT
STORE MTOT_SELL TO MSAV_SELL
STORE MTOT_PURCH TO MSAV_PURCH
STORE MTOT_LBS TO MSAV_LBS
MCHG_ITM = .F.
MADD_ITM = .F.
SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
IF .NOT. EOF()
   STORE RECNO() TO MRECNO, MFST_REC
ELSE 
   STORE 0 TO MRECNO, MFST_REC
ENDIF

MMORE_ITM = .T.  
MPAGE = 1
@ 02,55 SAY 'INV NBR: ' + MINV_NBR
@ 3,0 CLEAR
IF MSALESMAN <> '  '
   MSAY_PO = MSALESMAN + '-' + MPO_NBR
ELSE
   MSAY_PO = MPO_NBR
ENDIF
IF MPO_SUFFIX <> ' '
   MSAY_PO = MSAY_PO + '-' + MPO_SUFFIX
ENDIF
MTITLE = ' - ENTER SHORTWEIGHTS FOR PO NBR ' + MSAY_PO
DO TEXT2ND

DO WHILE MMORE_ITM
   MMAX_ITM = 0
   MNBR_ITM = 1
   SELECT C
   IF .NOT. EOF()
      GOTO MRECNO
   ENDIF
   DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. VAL(ITEM_NBR) <= (MPAGE * 15)    
      DO STORITM
      IF SHORT_FLG = 'Y'
         STORE 'S' TO MFLAG(MNBR_ITM)
      ELSE
         STORE ' ' TO MFLAG(MNBR_ITM)
      ENDIF
      MMAX_ITM = MMAX_ITM + 1
      MNBR_ITM = MNBR_ITM + 1
      SKIP
   ENDDO
   STORE RECNO() TO MRECNO
   IF .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
      MBLURP = .T.
   ELSE
      MBLURP = .F.
   ENDIF
   @ 3,77 SAY STR(MPAGE,2)
   MLINE = 08 
   MNBR_ITM = 1
   DO WHILE MNBR_ITM <= MMAX_ITM
      DO SAYITM 
      @ MLINE,0 SAY MFLAG(MNBR_ITM)
      MLINE = MLINE + 1
      MNBR_ITM = MNBR_ITM + 1
   ENDDO
   IF MBLURP
      @ 24,67 SAY 'More Items...'
   ELSE
      @ 24,67 TO 24,79
   ENDIF
   
   MLINE = 08 
   MNBR_ITM = 1
   
   MNEXT_ITM = .T.
   DO WHILE MLINE <= 22 .AND. MNBR_ITM <= MMAX_ITM
      *     STORE ' ' TO MPICK
      STORE MFLAG(MNBR_ITM) TO MSAVE_FLAG
      @ MLINE,0 GET MFLAG(MNBR_ITM) PICTURE '@!'
      READ
      IF MFLAG(MNBR_ITM) = 'N' .AND. MSAVE_FLAG = 'S'
         IF MSHRT_LBS(MNBR_ITM) <> 0
            @ 24,0 CLEAR
            STORE 'AFTER SW ENTERED, MUST ZERO OUT LBS TO ENTER NO SW - PRESS RETURN TO REENTER' TO MMSG
            @ 24,0 GET MMSG
            READ
            @ 24,0 CLEAR
            STORE MSAVE_FLAG TO MFLAG(MNBR_ITM)
            LOOP
         ENDIF
      ENDIF
      STORE MFLAG(MNBR_ITM) TO MPICK
      IF MPICK = 'X' .OR. MPICK = 'C'
         **** I IS THE ITEM NUMBER
         **** X IS THE SUBSCRIPT NUMBER
         I = ((MPAGE - 1) * 15) + (MLINE - 7)
         X = MLINE - 7
         SAVE SCREEN TO MSHRT_SCRN
         STORE 0 TO MSW_LBS, MLBS_X, MQTY_X, MLBS_BOX
         STORE MLBS(MNBR_ITM) TO MORIG_LBS
         STORE MPURC_TOT(MNBR_ITM) TO MORIG_PURC
         STORE MSELL_TOT(MNBR_ITM) TO MORIG_SELL
         DO SHORTITM
         RESTORE SCREEN FROM MSHRT_SCRN
         DO SAYITM
         IF MLBS(MNBR_ITM) <> MORIG_LBS
            MCHANGE = .T.
            **** LOCATE THE RIGHT RECORD AND WRITE BACK
            **** ALSO WRITE BACK HISTORY
            STORE 'SHORTWT   ' TO MREAS_CODE
            STORE SPACE(25) TO MREAS_DESC
            MAPPEND = .F.
            DO REPLONE
            SELECT C
            DO RECLOCK
            REPLACE SHORT_FLG WITH 'Y'
            FLUSH
            UNLOCK
            MLOSS_LBS = MLBS(MNBR_ITM) - MORIG_LBS
            SELECT B
            **IF  BBUYCODE <> 'NONE' .AND. BBUYCODE <> 'INVN'
            IF  BBUYCODE <> 'NONE' .AND. BBUYCODE <> 'I'
               IF MORIG_LBS <> MLBS(MNBR_ITM) .OR. MORIG_SELL <> MSELL_TOT(MNBR_ITM)
                  IF INV_NBR <> SPACE(5)
                     STORE INV_NBR TO MINV_NBR
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
                        IF B->PAID_FLG <> 'Y'
                           SELECT E
                           DO FOX_USE WITH "INV_ADJ INDEX INV_ADJ", .F.
                           DO FILELOCK
                           APPEND BLANK
                           REPLACE salesman   WITH B->salesman  
                           REPLACE po_nbr     WITH B->po_nbr    
                           REPLACE po_suffix  WITH B->po_suffix 
                           REPLACE bbuycode   WITH B->bbuycode  
                           REPLACE ADJ_DATE   WITH DATE()
                           REPLACE ADJ_AMT    WITH MSELL_TOT(MNBR_ITM) - MORIG_SELL
                           REPLACE inv_nbr    WITH B->inv_nbr      
                           REPLACE SHRT_LBS   WITH MLOSS_LBS
                           FLUSH
                           UNLOCK
                        ELSE
                           SELECT E
                           DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
                           DO FILELOCK
                           APPEND BLANK
                           REPLACE salesman   WITH B->salesman  
                           REPLACE po_nbr     WITH B->po_nbr    
                           REPLACE po_suffix  WITH B->po_suffix 
                           REPLACE buy_code   WITH B->buy_code  
                           REPLACE bbuycode   WITH B->bbuycode  
                           REPLACE buyer_po   WITH B->buyer_po  
                           REPLACE ship_date  WITH B->ship_date 
                           REPLACE tot_sell   WITH MSELL_TOT(MNBR_ITM) - MORIG_SELL
                           IF VAL(MINV_NBR) < 10000
                              REPLACE INV_NBR WITH 'A' + SUBSTR(MINV_NBR,2)
                           ELSE
                              REPLACE INV_NBR WITH MINV_NBR
                           ENDIF
                           REPLACE DEB_CRD WITH 'Y'    
                           REPLACE INV_DATE   WITH DATE()       
                           FLUSH
                           UNLOCK
                        ENDIF
                     OTHERWISE
                        DO RECLOCK 
                        REPLACE TOT_SELL   WITH TOT_SELL + (MSELL_TOT(MNBR_ITM) - MORIG_SELL)
                        UNLOCK
                     ENDCASE
                  ENDIF
               ENDIF 
            ENDIF 
            **** NOW CHECK ON THE SUPPLIER SIDE
            **IF  B->RSUPCODE <> 'NONE' .AND. B->RSUPCODE <> 'INVN' .AND. B->INV_FLG <> ' ' .AND. B->SHORT_FLG <> ' '
            IF  B->RSUPCODE <> 'NONE' .AND. B->RSUPCODE <> 'I' .AND. B->INV_FLG <> ' ' .AND. B->SHORT_FLG <> ' '
               
               DO CASE
                  
               CASE B->SUP_REC = ' '
                  
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
                     REPLACE AMT_DUE WITH AMT_DUE + (MPURC_TOT(MNBR_ITM) - MORIG_PURC)
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
                     REPLACE SALESMAN   WITH B->SALESMAN  
                     REPLACE PO_NBR     WITH B->PO_NBR    
                     REPLACE PO_SUFFIX  WITH B->PO_SUFFIX 
                     REPLACE RSUPCODE   WITH B->RSUPCODE    
                     REPLACE AMT_DUE WITH AMT_DUE + (MPURC_TOT(MNBR_ITM) - MORIG_PURC)
                     REPLACE INV_NBR    WITH B->INV_NBR      
                     REPLACE DUE_DATE WITH DATE()
                     REPLACE REASON WITH 'ITEM ADJ.' 
                     REPLACE SUP_INV WITH MSUP_INV
                     REPLACE DEB_CRD WITH 'Y'
                     REPLACE SEQ WITH '1'
                     UNLOCK
                  ENDIF
               ENDCASE
            ENDIF
            SELECT E
            USE
            SELECT D
            USE
            SELECT C
         ENDIF
      ELSE
         IF MPICK = 'N'
            STORE 0 TO MSW_LBS, MLBS_X, MQTY_X, MLBS_BOX
            STORE MLBS(MNBR_ITM) TO MORIG_LBS
            STORE MPURC_TOT(MNBR_ITM) TO MORIG_PURC
            STORE MSELL_TOT(MNBR_ITM) TO MORIG_SELL
            STORE 'NO SHORTWT' TO MREAS_CODE
            STORE SPACE(25) TO MREAS_DESC
            MAPPEND = .F.
            I = ((MPAGE - 1) * 15) + (MLINE - 7)
            X = MLINE - 7
            STORE 0 TO MSHRT_BOX(X), MSHRT_LBS(X)
            DO REPLONE
            DO RECLOCK
            SELECT C
            REPLACE SHORT_FLG WITH 'Y'
            FLUSH
            UNLOCK
         ENDIF
      ENDIF
      *     @ MLINE,0 SAY ' '
      MLINE = MLINE + 1
      MNBR_ITM = MNBR_ITM + 1
      
   ENDDO
   
   STORE 1 TO MACTION
   @ 24,0 SAY 'Action: ' + STR(MACTION,1)
   IF MBLURP
      @ 24,12 SAY '1. Next Itm Pg.     2. Edit     3. Finished'
   ELSE
      @ 24,12 SAY '1. Finished     2. Edit'
   ENDIF
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
   
   READ
   IF MBLURP
      DO CASE
      CASE MACTION = 1
         @ 8,0 CLEAR TO 22,79 
         MPAGE = MPAGE + 1
         LOOP      
      CASE MACTION = 2
         MNBR_ITM = 1
         STORE MFST_REC TO MRECNO
         LOOP
      CASE MACTION = 3
         SELECT C
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         MALL_DONE = .T.
         DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
            IF SHORT_FLG = ' '
               MALL_DONE = .F.
            ENDIF
            MSW_LBS = MSW_LBS + SHRT_LBS
            IF BILL_PRI = 0
               *** MSW_PURCH = MSW_PURCH + ROUND((BILL_PRI * SHRT_LBS),2)
               MVAL1 = SHRT_LBS * BILL_PRI
            ELSE
               *** MSW_PURCH = MSW_PURCH + ROUND((PUR_PRICE * SHRT_LBS),2)
               MVAL1 = SHRT_LBS * PUR_PRICE
            ENDIF
            
            IF MVAL1 <> 0
               MVAL = INT(MVAL1*100)
               IF (ABS(MVAL1) * 100) - ABS(MVAL) > .49
                  IF MVAL1 >= 0
                     MVAL1 = (MVAL + 1) / 100
                  ELSE
                     MVAL1 = (MVAL - 1) / 100
                  ENDIF
               ELSE
                  MVAL1 = MVAL / 100
               ENDIF
            ENDIF
            
            
            MSW_PURCH = MSW_PURCH + MVAL1
            
            *** MSW_SELL = MSW_SELL + ROUND((SEL_PRICE * SHRT_LBS),2)
            MVAL1 = SHRT_LBS * SEL_PRICE
            
            IF MVAL1 <> 0
               MVAL = INT(MVAL1*100)
               IF (ABS(MVAL1) * 100) - ABS(MVAL) > .49
                  IF MVAL1 >= 0
                     MVAL1 = (MVAL + 1) / 100
                  ELSE
                     MVAL1 = (MVAL - 1) / 100
                  ENDIF
               ELSE
                  MVAL1 = MVAL / 100
               ENDIF
            ENDIF
            
            MSW_SELL = MSW_SELL + MVAL1
            SKIP
         ENDDO
         DO HEAD_TOT
         IF MALL_DONE
            SELECT B
            IF SHORT_FLG = ' '
               DO RECLOCK
               REPLACE SHORT_FLG WITH 'Y'
               FLUSH
               UNLOCK
            ENDIF
            DO RECLOCK
            REPLACE SW_LBS WITH MSW_LBS
            REPLACE SW_PURCH WITH MSW_PURCH
            REPLACE SW_SELL WITH MSW_SELL
            FLUSH
            UNLOCK
         ENDIF
         MMORE_ITM = .F.
         DO FRT_SHRT
      ENDCASE
   ELSE
      DO CASE      
      CASE MACTION = 1
         SELECT C
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         MALL_DONE = .T.
         STORE 0 TO MSW_LBS, MSW_PURCH, MSW_SELL
         DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
            IF SHORT_FLG = ' '
               MALL_DONE = .F.
            ENDIF
            MSW_LBS = MSW_LBS + SHRT_LBS
            
            IF BILL_PRI = 0
               *** MSW_PURCH = MSW_PURCH + ROUND((BILL_PRI * SHRT_LBS),2)
               MVAL1 = SHRT_LBS * BILL_PRI
            ELSE
               *** MSW_PURCH = MSW_PURCH + ROUND((PUR_PRICE * SHRT_LBS),2)
               MVAL1 = SHRT_LBS * PUR_PRICE
            ENDIF
            
            IF MVAL1 <> 0
               MVAL = INT(MVAL1*100)
               IF (ABS(MVAL1) * 100) - ABS(MVAL) > .49
                  IF MVAL1 >= 0
                     MVAL1 = (MVAL + 1) / 100
                  ELSE
                     MVAL1 = (MVAL - 1) / 100
                  ENDIF
               ELSE
                  MVAL1 = MVAL / 100
               ENDIF
            ENDIF
            MSW_PURCH = MSW_PURCH + MVAL1
            
            
            MVAL1 = SHRT_LBS * SEL_PRICE
            IF MVAL1 <> 0
               MVAL = INT(MVAL1*100)
               IF (ABS(MVAL1) * 100) - ABS(MVAL) > .49
                  IF MVAL1 >= 0
                     MVAL1 = (MVAL + 1) / 100
                  ELSE
                     MVAL1 = (MVAL - 1) / 100
                  ENDIF
               ELSE
                  MVAL1 = MVAL / 100
               ENDIF
            ENDIF
            
            MSW_SELL = MSW_SELL + MVAL1
            SKIP
         ENDDO
         DO HEAD_TOT
         IF MALL_DONE
            SELECT B
            IF SHORT_FLG = ' '
               DO RECLOCK
               REPLACE SHORT_FLG WITH 'Y'
               FLUSH
               UNLOCK
            ENDIF
            DO RECLOCK
            REPLACE SW_LBS WITH MSW_LBS
            REPLACE SW_PURCH WITH MSW_PURCH
            REPLACE SW_SELL WITH MSW_SELL
            FLUSH
            UNLOCK
         ENDIF
         
         *** NEW AS OF 10/04/94
         DO MISC_CHG
         *** MAKE SURE THIS WORKS OK
         
         MLAST_PG = .T.
         DO FRT_SHRT
         MMORE_ITM = .F.
         
      CASE MACTION = 2
         STORE MFST_REC TO MRECNO
         MNBR_ITM = 1
         LOOP        
      ENDCASE 
   ENDIF
ENDDO 

RETURN
* EOF: PO_SHORT.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/12/94 at 3:58 PM.
