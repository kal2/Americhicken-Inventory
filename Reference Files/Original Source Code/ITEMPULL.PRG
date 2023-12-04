***********************
* Program.: ITEM_ADD.PRG
* Author..: Grace Keller
* Date....: 04/10/94
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: ORDER ITEM ADD - MULTIPLE PAGES
*         :                  NEW FOR AUTOMATIC INVENTORY UPDATING
*
* ---OPEN FILES
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
RELEASE MOUT_YR
RELEASE MOUT_DAY


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
DIMENSION MPAK_YR(7)
DIMENSION MPAK_DAY(7)
DIMENSION MOUT_YR(7)
DIMENSION MOUT_DAY(7)

I = 1
DO WHILE I<=13
   MI = SUBSTR(STR(I+100,3),2)
   MPPROD&MI = SPACE(6)
   MPCASES&MI= 0
   I = I + 1
ENDDO

MERROR = .F.
MCONT = .T.
DO WHILE MCONT
   CLEAR
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - ADD FROM OLDEST'
   @  2, 0 SAY MPROGRAM + MTITLE
   @  2,45 SAY 'ORDER #:'
   @ 2,55 SAY MSALESMAN
   @ 2,57 SAY '-'
   @ 2,58 SAY MPO_NBR
   IF MPO_SUFFIX <> ' '
      @ 2,62 SAY '-'
      @ 2,63 SAY MPO_SUFFIX
   ENDIF
   @ 3,0 to 24,79
   @ 4,6  SAY 'PRODUCT'
   @ 4,16 SAY 'CASES'
   **@ 4,26 SAY 'LBS(if CWT)'
   MLINE = 7
   DO WHILE MLINE <= 18
      @ MLINE,1 SAY STR(MLINE-6,2)
      MLINE = MLINE + 1
   ENDDO
   
   MACTION = 2
   DO WHILE MACTION = 2
      MLINE = 7
      DO WHILE MLINE<= 18
         MI = SUBSTR(STR((MLINE-6)+100,3),2)
         @ MLINE,7  GET MPPROD&MI PICTURE '@!'
         @ MLINE,16 GET MPCASES&MI PICTURE '####'
         MLINE = MLINE + 1
      ENDDO
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 1
         *** CHECK TO MAKE SURE PRODUCT CODES ARE VALID
         SELECT E
         DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
         I = 1
         DO WHILE I<=13
            MI = SUBSTR(STR(I+100,3),2)
            IF MPPROD&MI <> SPACE(6)
               SEEK 'R' +  MPPROD&MI
               IF EOF()
                  @ 24,0 CLEAR
                  STORE 'PRODUCT ON LINE ' + MI + ' - IS INVALID - PRESS RETURN TO REENTER' TO MWAIT
                  @ 24,1 GET MWAIT
                  READ
                  MACTION = 2
                  @ 24,0 CLEAR
                  I = 14
                  USE
                  LOOP
               ENDIF
            ENDIF
            I = I + 1
         ENDDO
         USE
      ENDIF
   ENDDO
   
   IF MACTION = 3 .OR. MPPROD01 = SPACE(6)
      MCONT = .F.
      MERROR = .T.
      LOOP
   ENDIF
   
   I = 1
   DO WHILE I<=13
      MI = SUBSTR(STR(I+100,3),2)
      MPLEFT&MI = MPCASES&MI
      I = I + 1
   ENDDO
   MCONT = .F.
ENDDO

IF MERROR
   I = 1
   DO WHILE I<=13
      MI = SUBSTR(STR(I+100,3),2)
      RELEASE MPLEFT&MI
      RELEASE MPCASES&MI
      RELEASE MPPROD&MI
      I = I + 1
   ENDDO
   RETURN
ELSE
   RELEASE MERROR
ENDIF


SELECT E
DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
SEEK B->SUP_CODE
IF EOF()
   MFREEZ_LOC = 'UNKNOWN' + SPACE(25)
ELSE
   MFREEZ_LOC = NAME
ENDIF
USE

IF B->BROKERAGE = 'H'
   SET PROC TO H_PROC
ELSE
   SET PROC TO I_PROC
ENDIF

CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
MTITLE = ' - ADD ORDER ITEMS'
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
@ 3,65 SAY 'ITEMS: PAGE '

MPULL = 1
MMORE_ITM = .T.  
MPAGE = 0

DO WHILE MMORE_ITM
   MPAGE = MPAGE + 1
   @ 3,77 SAY STR(MPAGE,2)
   MNBR_ITM = 1
   
   DO WHILE MNBR_ITM <= 7
      STORE 0 TO MQTY(MNBR_ITM), MLBS(MNBR_ITM), MBOX_SZ(MNBR_ITM)
      STORE 0 TO MOLD_QTY(MNBR_ITM), MOLD_LBS(MNBR_ITM)
      STORE 0 TO MPURC_PRI(MNBR_ITM), MSELL_PRI(MNBR_ITM)
      IF B->RSUPCODE = 'INVN'
         STORE 'FR' TO MFR_FZ(MNBR_ITM)
      ELSE
         STORE SPACE(2) TO MFR_FZ(MNBR_ITM)
      ENDIF
      STORE SPACE(1) TO MPAK1(MNBR_ITM), MPAK2(MNBR_ITM), MGRADE(MNBR_ITM)
      IF MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
         STORE SPACE(6) TO MPROD(MNBR_ITM), MOLD_PROD(MNBR_ITM)
         STORE SPACE(6) TO MPACKSPEC(MNBR_ITM)
      ELSE
         STORE SPACE(6) TO MPROD(MNBR_ITM), MOLD_PROD(MNBR_ITM)
         STORE SPACE(6) TO MPACKSPEC(MNBR_ITM)
      ENDIF
      STORE SPACE(10) TO MIN_LOT(MNBR_ITM), MOLD_IN(MNBR_ITM)
      STORE SPACE(10) TO MOUT_LOT(MNBR_ITM), MOLD_OUT(MNBR_ITM)
      STORE SPACE(5) TO MSIZE(MNBR_ITM)
      STORE 0 TO MPAK_YR(MNBR_ITM), MPAK_DAY(MNBR_ITM)
      STORE 0 TO MOUT_YR(MNBR_ITM), MOUT_DAY(MNBR_ITM)
      MNBR_ITM = MNBR_ITM + 1
   ENDDO
   
   @ 8,0 CLEAR TO 22,80
   MLINE = 8  
   MNEXT_ITM = .T.
   MNBR_ITM = 1
   
   **** DO ONE PAGE AT A TIME
   DO WHILE MNBR_ITM <= 7 .AND. MNEXT_ITM
      
      *** FORMAT THE OUT LOT & QTY FOR THOSE ITEMS BEING PULLED
      MPULLIT = .T.
      DO WHILE MPULL <= 13 .AND. MPULLIT
         MPULLI = SUBSTR(STR(MPULL+100,3),2)
         IF MPLEFT&MPULLI <= 0
            MPULL = MPULL + 1
         ELSE
            MPULLIT = .F.
         ENDIF
      ENDDO
      
      IF MPULL > 13
         MPULLIT = .F.
      ELSE
         MPULLIT = .T.
      ENDIF
      
      
      *** SET IT UP TO PULL OUT OF INVENTORY
      SELECT F
      DO FOX_USE WITH "HINV_DTL", .F.
      
      SELECT E
      DO FOX_USE WITH "INVEN INDEX INVNSOLD", .F.
      SET FILTER TO UPPER(NOTE) <> 'HOLD Q'
      GOTO TOP
      
      MQTY(MNBR_ITM) = 0
      MFILE_NBR = 1
      
      
      DO WHILE MPULLIT
         
         MPULLI = SUBSTR(STR(MPULL+100,3),2)
         
         SELECT E
         
         DO CASE
         CASE MFILE_NBR = 1
            
            MFILE_NBR = 2
            SEEK ' 11' + MFREEZ_LOC + MPPROD&MPULLI
            IF EOF()
               MFILE_NBR = 3
               LOOP
            ENDIF
            
            IF NOTE = 'HOLD' .OR. CASE_LEFT <= 0
               LOOP
            ENDIF
            
            MCASE_LEFT = CASE_LEFT
            
            SELECT F
            SUM QTY FOR LOT_NBR = E->LOT_NBR .AND. ACT_CODE = 'S' TO MPEND_OUT
            MPEND_OUT = -1 * MPEND_OUT
            MCALC_LEFT = MCASE_LEFT - MPEND_OUT
            
            IF MCALC_LEFT <= 0
               LOOP
            ENDIF
            
            IF MPLEFT&MPULLI > MCALC_LEFT
               MPLEFT&MPULLI = MPLEFT&MPULLI - MCALC_LEFT
               MQTY(MNBR_ITM) = MCALC_LEFT
            ELSE
               MQTY(MNBR_ITM) = MPLEFT&MPULLI
               MPLEFT&MPULLI = 0
            ENDIF
            
            MPULLIT = .F.
            LOOP
            
            
         CASE MFILE_NBR = 2
            
            SKIP
            
            IF EOF() .OR. SOLD_FLG <> ' ' .OR. DIV_CODE <> '11' .OR. FREEZ_LOC <> MFREEZ_LOC .OR. PROD_DESC <> MPPROD&MPULLI
               MFILE_NBR = 3
               LOOP
            ENDIF
            
            IF NOTE = 'HOLD' .OR. CASE_LEFT = 0
               LOOP
            ENDIF
            
            MCASE_LEFT = CASE_LEFT
            SELECT F
            SUM QTY FOR LOT_NBR = E->LOT_NBR .AND. ACT_CODE = 'S' TO MPEND_OUT
            MPEND_OUT = -1 * MPEND_OUT
            MCALC_LEFT = MCASE_LEFT - MPEND_OUT
            IF MCALC_LEFT <= 0
               LOOP
            ENDIF
            
            IF MPLEFT&MPULLI > MCALC_LEFT
               MPLEFT&MPULLI = MPLEFT&MPULLI - MCALC_LEFT
               MQTY(MNBR_ITM) = MCALC_LEFT
            ELSE
               MQTY(MNBR_ITM) = MPLEFT&MPULLI
               MPLEFT&MPULLI = 0
            ENDIF
            
            MPULLIT = .F.
            LOOP
            
            
         CASE MFILE_NBR = 3
            
            MFILE_NBR = 4
            SELECT E
            DO FOX_USE WITH "HINVEN INDEX HINVSOLD", .F.
            
            SEEK ' 11' + MFREEZ_LOC + MPPROD&MPULLI
            IF EOF()
               MCASE_LEFT = 0
               MFILE_NBR = 5
               IF MPULL<= 13
                  MPLEFT&MPULLI = 0
               ENDIF
               MQTY(MNBR_ITM) = 0
               MPULLIT = .F.
               LOOP
            ENDIF
            
            IF NOTE = 'HOLD' .OR. CASE_CNT <= 0
               LOOP
            ENDIF
            
            MCASE_LEFT = CASE_CNT
            
            SELECT F
            SUM QTY FOR LOT_NBR = E->LOT_NBR .AND. ACT_CODE = 'S' TO MPEND_OUT
            MPEND_OUT = -1 * MPEND_OUT
            MCALC_LEFT = MCASE_LEFT - MPEND_OUT
            
            IF MCALC_LEFT <= 0
               LOOP
            ENDIF
            
            IF MPLEFT&MPULLI > MCALC_LEFT
               MPLEFT&MPULLI = MPLEFT&MPULLI - MCALC_LEFT
               MQTY(MNBR_ITM) = MCALC_LEFT
            ELSE
               MQTY(MNBR_ITM) = MPLEFT&MPULLI
               MPLEFT&MPULLI = 0
            ENDIF
            
            MPULLIT = .F.
            LOOP
            
         CASE MFILE_NBR = 4
            
            SKIP
            
            IF EOF() .OR. SOLD_FLG <> ' ' .OR. DIV_CODE <> '11' .OR. FREEZ_LOC <> MFREEZ_LOC .OR. PROD_DESC <> MPPROD&MPULLI
               MCASE_LEFT = 0
               MFILE_NBR = 5
               IF MPULL<= 13
                  MPLEFT&MPULLI = 0
               ENDIF
               MQTY(MNBR_ITM) = 0
               MPULLIT = .F.
               LOOP
            ENDIF
            
            IF NOTE = 'HOLD' .OR. CASE_CNT = 0
               LOOP
            ENDIF
            
            MCASE_LEFT = CASE_CNT
            
            SELECT F
            SUM QTY FOR LOT_NBR = E->LOT_NBR .AND. ACT_CODE = 'S' TO MPEND_OUT
            MPEND_OUT = -1 * MPEND_OUT
            MCALC_LEFT = MCASE_LEFT - MPEND_OUT
            IF MCALC_LEFT <= 0
               LOOP
            ENDIF
            
            IF MPLEFT&MPULLI > MCALC_LEFT
               MPLEFT&MPULLI = MPLEFT&MPULLI - MCALC_LEFT
               MQTY(MNBR_ITM) = MCALC_LEFT
            ELSE
               MQTY(MNBR_ITM) = MPLEFT&MPULLI
               MPLEFT&MPULLI = 0
            ENDIF
            
            MPULLIT = .F.
            LOOP
            
         OTHERWISE
            
            MPULLIT = .F.
            MQTY(MNBR_ITM) = 0
            IF MPULL <= 13
               MPLEFT&MPULLI = 0
            ENDIF
         ENDCASE
         
      ENDDO
      
      SELECT E
      
      IF MQTY(MNBR_ITM) <= 0
         IF MPULL <= 13
            @ 24,0 CLEAR
            @ 24,5 SAY 'NO INVENTORY LEFT FOR PRODUCT ' + MPPROD&MPULLI + " ENTER 'C' TO CONTINUE"
            MCONT = ' '
            @ 24,1 GET MCONT PICTURE '@!' VALID(MCONT = 'C')
            READ
            MPLEFT&MPULLI = 0
            @ 24,0 CLEAR
            LOOP
         ENDIF
         MOUT_LOT(MNBR_ITM) = SPACE(10)
      ELSE
         MPURC_PRI(MNBR_ITM) = PRI_LB
         MBOX_SZ(MNBR_ITM)   = BOX_SZ
         MMULT               = BOX_SZ
         MFR_FZ(MNBR_ITM)    = FRH_FRZ
         MPAK1(MNBR_ITM)     = SUBSTR(PACKAGED,1,1)
         MPAK2(MNBR_ITM)     = SUBSTR(PACKAGED,2,1)
         MGRADE(MNBR_ITM)    = GRADE
         MPROD(MNBR_ITM)     = PROD_DESC
         MSIZE(MNBR_ITM)     = SIZE
         MPACKSPEC(MNBR_ITM) = PACKED
         MOUT_LOT(MNBR_ITM)  = LOT_NBR
      ENDIF
      
      SELECT E
      USE
      SELECT F
      USE
      
      MACTION = 2
      DO WHILE MACTION = 2
         SELECT C
         *** GET ITEM INFO -BUT NOT THE OUT OF INVN LOT NUMBER
         IF MOUT_LOT(MNBR_ITM) = SPACE(10)
            DO GETITM
         ELSE
            DO GETITMP
         ENDIF      
         STORE 1 TO MACTION
         @ 24,0 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2. Edit  '
         @ 24,8 GET MACTION PICTURE '#' RANGE 1,2
         READ
         
         IF MACTION = 1 .AND. MNEXT_ITM
            ***I = ((MPAGE - 1) * 7) + 1
            I = ((MPAGE - 1) * 7) + MNBR_ITM
            X = MNBR_ITM
            MAPPEND = .T.
            SELECT C
            DO FILELOCK
            
            DO REPLITM
            SELECT C
            UNLOCK
            
            MLINE = MLINE + 2
            MNBR_ITM = MNBR_ITM + 1
            
         ELSE
            IF MACTION = 1
               IF MPROD(MNBR_ITM) = SPACE(6)
                  MMORE_ITM = .F.
                  MNEXT_ITM = .F.
                  LOOP
               ENDIF
            ENDIF
         ENDIF
         
      ENDDO
   ENDDO
   **** FINISH UP
   ****MMORE_ITM = .F.
ENDDO

**** CALCULATE TOTALS FOR ITEMS      
STORE 0 TO MTOT_SELL, MTOT_PURCH, MTOT_LBS, MTLBS_CALC, MTOT_STOR
SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
DO WHILE MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX  .AND. .NOT. EOF()
   MTOT_SELL = MTOT_SELL + TOT_SELL
   MTOT_PURCH = MTOT_PURCH + TOT_PURCH
   
   IF SUBSTR(PACKED,1,1) = 'B'
      MCALC_LBS = VAL(SUBSTR(PACKED,2)) * LBS
   ELSE
      MCALC_LBS = LBS
   ENDIF
   
   DO RECLOCK
   REPLACE CALC_LBS WITH MCALC_LBS
   UNLOCK
   
   MTOT_LBS = MTOT_LBS + MCALC_LBS
   MTLBS_CALC = MTLBS_CALC + MCALC_LBS
   SKIP
ENDDO

SELECT B 
DO RECLOCK
*REPLACE TOT_LBS WITH MTOT_LBS
*** FOR AMERICHICKEN, ITS CASES SHIPPED (QTY), NOT LBS
IF MCOMPANY = 'MIDWEST FOOD -DIV 11' .OR. MCOMPANY = 'AMERICHICKEN, INC'
   REPLACE TOT_LBS WITH MTLBS_CALC
ELSE
   REPLACE TOT_LBS WITH MTOT_LBS
ENDIF
*REPLACE TOT_STOR WITH MTOT_STOR
UNLOCK
MPO_ADD = .T.

SET PROC TO PO_PROC 
**** FINISH UP
IF MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
   MVIEW = .F.
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
   RELEASE MPAK_YR
   RELEASE MPAK_DAY
   RELEASE MOUT_YR
   RELEASE MOUT_DAY
   I = 1
   DO WHILE I<=13
      MI = SUBSTR(STR(I+100,3),2)
      RELEASE MPLEFT&MI
      RELEASE MPCASES&MI
      RELEASE MPPROD&MI
      I = I + 1
   ENDDO
   STORE SPACE(25) TO MCOM_NAME, MCOM_NAME2, MCOM_NAME3    
   STORE SPACE(2)  TO  MCOM_CODE, MCOM_CODE2, MCOM_CODE3
   IF B->BBUYCODE <> 'INVN' .AND. B->BBUYCODE <> 'SAMP'
      DO COM_PG
   ENDIF
ENDIF
DO MISC_ADD
DO NEW_FRT    

RETURN
* EOF: ITEMPULL.PRG

*Formatted by: ToolBox Ver. 1.2  on 11/4/19 at 2:58 PM.
