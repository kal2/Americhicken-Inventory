**********
* Program.: MISC_CHG.PRG
* Author..: Grace Keller
* Date....: 10/14/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MISCELLANEOUS ADJUSTMENTS              
*
* ---OPEN FILES
SELECT D
USE
SELECT E
USE
SELECT F
USE
SELECT B
IF RSUPCODE = 'NONE' .AND. BBUYCODE = 'NONE' 
   MGOTO_PG = 4
   RETURN
ENDIF
MCALC_SELL = 0
SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
   MCALC_SELL  = MCALC_SELL + TOT_SELL
   SKIP
ENDDO
SELECT B
SET PROC TO PO_PROC
MTITLE =  ' - EDIT MISCELLANEOUS ADJUSTMENTS'
MMORE_MISC = .T.     
STORE SUP_REAS1 TO MSUP_REAS1, OSUP_REAS1
STORE SUP_REAS2 TO MSUP_REAS2, OSUP_REAS2
STORE CUS_REAS1 TO MCUS_REAS1, OCUS_REAS1
STORE CUS_REAS2 TO MCUS_REAS2, OCUS_REAS2
STORE SUP_AMT1 TO MSUP_AMT1, OSUP_AMT1
STORE SUP_AMT2 TO MSUP_AMT2, OSUP_AMT2
STORE CUS_AMT1 TO MCUS_AMT1, MORIG_AMT1
STORE CUS_AMT2 TO MCUS_AMT2, MORIG_AMT2
STORE WRITEOFF TO MWRITEOFF, MORIG_WRIT
STORE CUS_PALL TO MCUS_PALL, MORIGCPALL
STORE SUP_PALL TO MSUP_PALL, OSUP_PALL

*** IF SHIP TO CUSTOMER = 'PICKED UP'
**IF SUBSTR(B->BUY_CODE,1,1) = 'P' .OR. B->PU_LOC = 'CPU'

** BREADING
** REBATE
** SAMPLE
** DAMAGED

IF B->PO_SUFFIX <> 'B' .AND. B->PO_SUFFIX <> 'R' .AND. B->PO_SUFFIX <> 'S' .AND. B->PO_SUFFIX <> 'D'
   MAMT = 0
   MDESC = SPACE(15)
   MLB_AMT = 0
   SELECT F
   DO FOX_USE WITH "&MDBFLOC.PICKUP INDEX &MDBFLOC.PICKUP", .F.
   SEEK B->BUY_CODE
   IF .NOT. EOF()
      DO CASE
      CASE BEG_DT3 <> CTOD('') .AND. B->SHIP_DATE >= BEG_DT3
         MLB_AMT = ALLOW3
         MAMT    = AMT3
         MDESC =  DESC3
      CASE BEG_DT2 <> CTOD('') .AND. B->SHIP_DATE >= BEG_DT2
         MLB_AMT = ALLOW2
         MDESC  = DESC2
         MAMT    = AMT2
      CASE BEG_DT1 <> CTOD('') .AND. B->SHIP_DATE >= BEG_DT1
         MLB_AMT = ALLOW1
         MDESC  = DESC1
         MAMT    = AMT1
      ENDCASE
   ENDIF
   USE
   
   DO CASE
   CASE MAMT <> 0 .OR. MLB_AMT <> 0
      IF (MCUS_REAS1 = 'NO-' .AND. MDESC = SUBSTR(MCUS_REAS1,4)) .OR. (MCUS_REAS2 = 'NO-' .AND. MDESC = SUBSTR(MCUS_REAS2,4))
         **** NO DEDUCTION GIVEN - DESCRIPTION CHANGED TO THIS
      ELSE
         DO CASE
         CASE MCUS_REAS1 = MDESC .OR. MCUS_AMT1 = 0
            IF MLB_AMT <> 0
               MCUS_AMT1 = ROUND(MLB_AMT * B->TOT_LBS,2) * -1
               MCUS_REAS1 = MDESC
            ELSE
               IF MAMT <> 0
                  MCUS_AMT1 = MAMT * -1
                  MCUS_REAS1 = MDESC
               ENDIF
            ENDIF
         CASE MCUS_REAS2 = MDESC .OR. MCUS_AMT2 = 0
            IF MLB_AMT <> 0
               MCUS_AMT2 = ROUND(MLB_AMT * B->TOT_LBS,2) * -1
               MCUS_REAS2 = MDESC
            ELSE
               IF MAMT <> 0
                  MCUS_AMT2 = MAMT * -1
                  MCUS_REAS2 = MDESC
               ENDIF
            ENDIF
         ENDCASE
      ENDIF
   OTHERWISE
      ** WHEN ABOVE IS ZERO THERE IS NO OVERALL ORDER PICKUP ALLOWANCE
      ** SO, CHECK FOR ONE BY ITEM
      MITMPK_TOT = 0
      MDESC = SPACE(15)
      
      SELECT F
      DO FOX_USE WITH "&MDBFLOC.PKUPITEM INDEX &MDBFLOC.PKUPITEM", .F.
      
      SELECT C
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      
      DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
         SELECT F
         SEEK B->BUY_CODE + C->PROD_DESC
         IF .NOT. EOF() .AND. B->SHIP_DATE >= BEG_DT .AND. B->SHIP_DATE <= END_DT
            MLB_AMT = ROUND(ITM_PKUP * C->LBS,2)
            MITMPK_TOT = MITMPK_TOT + MLB_AMT
            IF MDESC =  SPACE(15)
               MDESC = PBUYTYPE
            ENDIF
         ENDIF
         SELECT C
         SKIP
      ENDDO
      IF MDESC <> SPACE(15) .AND. MITMPK_TOT <> 0
         
         IF (MCUS_REAS1 = 'NO-' .AND. MDESC = SUBSTR(MCUS_REAS1,4)) .OR. (MCUS_REAS2 = 'NO-' .AND. MDESC = SUBSTR(MCUS_REAS2,4))
            **** NO DEDUCTION GIVEN - DESCRIPTION CHANGED TO THIS
         ELSE
            DO CASE
            CASE MCUS_REAS1 = MDESC .OR. MCUS_REAS1 = SPACE(15)
               MCUS_AMT1 = MITMPK_TOT
               MCUS_REAS1 = MDESC
            CASE MCUS_REAS2 = MDESC .OR. MCUS_REAS2 = SPACE(15)
               MCUS_AMT2 = MITMPK_TOT
               MCUS_REAS2 = MDESC
            ENDCASE
         ENDIF
      ENDIF
      SELECT F
      USE
   ENDCASE
ENDIF

*** CHECK FOR ANY CUSTOMER DEDUCTIONS/PROGRAMS/PROMOTIONS
SELECT F
DO FOX_USE WITH "&MDBFLOC.CUST_DED INDEX &MDBFLOC.CUST_DED", .F.
SEEK B->BBUYCODE

DO WHILE .NOT. EOF() .AND. BBUYCODE = B->BBUYCODE
   MAMT = 0
   MDESC = SPACE(15)
   MPERCENT = 0
   
   DO CASE
   CASE BEG_DT3 <> CTOD('') .AND. B->ORD_DATE >= BEG_DT3
      MAMT = ALLOW3
      MPERCENT = PERCENT3
      MDESC =  DESC3
   CASE BEG_DT2 <> CTOD('') .AND. B->ORD_DATE >= BEG_DT2
      MAMT = ALLOW2
      MPERCENT = PERCENT2
      MDESC  = DESC2
   CASE BEG_DT1 <> CTOD('') .AND. B->ORD_DATE >= BEG_DT1
      MAMT = ALLOW1
      MPERCENT = PERCENT1
      MDESC  = DESC1
   ENDCASE
   
   *********************************************************************
   DO CASE
   CASE MAMT <> 0
      IF (MCUS_REAS1 = 'NO-' .AND. MDESC = SUBSTR(MCUS_REAS1,4)) .OR. (MCUS_REAS2 = 'NO-' .AND. MDESC = SUBSTR(MCUS_REAS2,4))
         **** NO DEDUCTION GIVEN - DESCRIPTION CHANGED TO THIS
      ELSE
         DO CASE
         CASE MCUS_REAS1 = MDESC .OR. MCUS_AMT1 = 0
            MCUS_AMT1 = ROUND(MAMT * B->TOT_LBS,2)
            MCUS_REAS1 = MDESC
            IF B->TOT_LBS < 0
               MCUS_AMT1 = 0
               MCUS_REAS1 = SPACE(15)
            ENDIF
         CASE MCUS_REAS2 = MDESC .OR. MCUS_AMT2 = 0
            MCUS_AMT2 = ROUND(MAMT * B->TOT_LBS,2)
            MCUS_REAS2 = MDESC
            IF B->TOT_LBS < 0
               MCUS_AMT2 = 0
               MCUS_REAS2 = SPACE(15)
            ENDIF
         ENDCASE
      ENDIF
   CASE MPERCENT <> 0
      IF (MCUS_REAS1 = 'NO-' .AND. MDESC = SUBSTR(MCUS_REAS1,4)) .OR. (MCUS_REAS2 = 'NO-' .AND. MDESC = SUBSTR(MCUS_REAS2,4))
         **** NO DEDUCTION GIVEN - DESCRIPTION CHANGED TO THIS
      ELSE
         
         DO CASE
         CASE MCUS_REAS1 = MDESC .OR. MCUS_AMT1 = 0
            MCUS_AMT1 = ROUND(MPERCENT * MCALC_SELL,2)
            MCUS_REAS1 = MDESC
            IF MCALC_SELL < 0
               MCUS_AMT1 = 0
               MCUS_REAS1 = SPACE(15)
            ENDIF
         CASE MCUS_REAS2 = MDESC .OR. MCUS_AMT2 = 0
            MCUS_AMT2 = ROUND(MPERCENT * MCALC_SELL,2)
            MCUS_REAS2 = MDESC
            IF MCALC_SELL < 0
               MCUS_AMT2 = 0
               MCUS_REAS2 = SPACE(15)
            ENDIF
         ENDCASE
      ENDIF
   ENDCASE
   SKIP
ENDDO
USE

*** ALSO CHECK FOR CUSTOMER OFF INVOICE PROMOTIONS
SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
MBUYOFF = 0
MBUYPAY = 0
DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
   MBUYOFF = MBUYOFF + PBUYOFF
   MBUYPAY = MBUYPAY + PBUYPAY
   SKIP
ENDDO
MDESC = 'PROGRAM/OFF INV'
IF MBUYOFF < 0
   IF (MCUS_REAS1 = 'NO-' .AND. MDESC = SUBSTR(MCUS_REAS1,4)) .OR. (MCUS_REAS2 = 'NO-' .AND. MDESC = SUBSTR(MCUS_REAS2,4))
      **** NO DEDUCTION GIVEN - DESCRIPTION CHANGED TO THIS
   ELSE
      IF (MCUS_REAS1 = 'OVR-' .AND. MDESC = SUBSTR(MCUS_REAS1,5)) .OR. (MCUS_REAS2 = 'OVR-' .AND. MDESC = SUBSTR(MCUS_REAS2,5))
         **** NO DEDUCTION GIVEN - DESCRIPTION CHANGED TO THIS
      ELSE
         DO CASE
         CASE MCUS_REAS1 = MDESC .OR. MCUS_AMT1 = 0
            MCUS_AMT1 = MBUYOFF
            MCUS_REAS1 = MDESC
         CASE MCUS_REAS2 = MDESC .OR. MCUS_AMT2 = 0
            MCUS_AMT2 = MBUYOFF
            MCUS_REAS2 = MDESC
         ENDCASE
      ENDIF
   ENDIF
ENDIF

MDESC = 'PROGRAM/BILLBAK'
IF MBUYPAY < 0
   IF (MCUS_REAS1 = 'NO-' .AND. MDESC = SUBSTR(MCUS_REAS1,4)) .OR. (MCUS_REAS2 = 'NO-' .AND. MDESC = SUBSTR(MCUS_REAS2,4))
      **** NO DEDUCTION GIVEN - DESCRIPTION CHANGED TO THIS
   ELSE
      IF (MCUS_REAS1 = 'OVR-' .AND. MDESC = SUBSTR(MCUS_REAS1,5)) .OR. (MCUS_REAS2 = 'OVR-' .AND. MDESC = SUBSTR(MCUS_REAS2,5))
         **** NO DEDUCTION GIVEN - DESCRIPTION CHANGED TO THIS
      ELSE
         DO CASE
         CASE MCUS_REAS1 = MDESC .OR. MCUS_AMT1 = 0
            MCUS_AMT1 = MBUYPAY
            MCUS_REAS1 = MDESC
         CASE MCUS_REAS2 = MDESC .OR. MCUS_AMT2 = 0
            MCUS_AMT2 = MBUYPAY
            MCUS_REAS2 = MDESC
         ENDCASE
      ENDIF
   ENDIF
ENDIF

SELECT F
DO FOX_USE WITH "PRT_NOTE INDEX PRT_NOTE", .F.
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
IF .NOT. EOF()
   STORE INV_COMMT TO MINV_COMMT, OINV_COMMT
   STORE SUP_COMMT TO MSUP_COMMT, OSUP_COMMT
ELSE
   STORE SPACE(60) TO MINV_COMMT, MSUP_COMMT, OINV_COMMT, OSUP_COMMT
ENDIF
USE
DO TEXTMISC
DO WHILE MMORE_MISC
   DO GETMISC
   STORE 1 TO MACTION
   @ 24,0 SAY 'Action: ' + STR(MACTION,1)
   
   @ 24,13 SAY '1. Continue       2. Edit       3. Previous Pg. '
   READ
   IF MCOMPANY = 'DIVISION 70'
      IF MSUP_AMT1 < 0 .AND. MSUP_REAS1 <> 'LBS='
         @ 24,0 CLEAR 
         MCHOICE = ' '
         @ 24,1 SAY "WARNING: SUP CREDIT ENTERED & REASON NOT 'LBS=' FORMAT -CONT(C) OR EDIT(E)? " GET MCHOICE PICTURE '@!' VALID(MCHOICE = 'C' .OR. MCHOICE = 'E')
         READ
         @ 24,0 CLEAR
         IF MCHOICE = 'E'
            MACTION = 2
            LOOP
         ENDIF
      ENDIF
      
      IF MSUP_AMT2 < 0 .AND. MSUP_REAS2 <> 'LBS='
         @ 24,0 CLEAR 
         MCHOICE = ' '
         @ 24,1 SAY "WARNING: SUP CREDIT ENTERED & REASON NOT 'LBS=' FORMAT -CONT(C) OR EDIT(E)? " GET MCHOICE PICTURE '@!' VALID(MCHOICE = 'C' .OR. MCHOICE = 'E')
         READ
         @ 24,0 CLEAR
         IF MCHOICE = 'E'
            MACTION = 2
            LOOP
         ENDIF
      ENDIF
   ENDIF
   
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
   READ
   
   IF MACTION = 2
      LOOP 
   ENDIF
   SELECT B
   DO RECLOCK
   REPLACE SUP_REAS1 WITH MSUP_REAS1
   REPLACE SUP_REAS2 WITH MSUP_REAS2
   REPLACE SUP_AMT1 WITH MSUP_AMT1
   REPLACE SUP_AMT2 WITH MSUP_AMT2
   REPLACE CUS_REAS1 WITH MCUS_REAS1
   REPLACE CUS_REAS2 WITH MCUS_REAS2
   REPLACE CUS_AMT1 WITH MCUS_AMT1
   REPLACE CUS_AMT2 WITH MCUS_AMT2
   REPLACE WRITEOFF WITH MWRITEOFF
   REPLACE SUP_PALL WITH MSUP_PALL
   REPLACE CUS_PALL WITH MCUS_PALL
   UNLOCK
   SELECT F
   DO FOX_USE WITH "PRT_NOTE INDEX PRT_NOTE", .F.
   SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
   IF MINV_COMMT = SPACE(60) .AND. MSUP_COMMT = SPACE(60)
      IF .NOT. EOF()
         DO FILELOCK
         DELETE
         UNLOCK
      ENDIF
   ELSE
      IF EOF() 
         DO FILELOCK
         APPEND BLANK
         REPLACE SALESMAN WITH MSALESMAN
         REPLACE PO_NBR WITH MPO_NBR
         REPLACE PO_SUFFIX WITH MPO_SUFFIX
         UNLOCK
      ENDIF
      DO RECLOCK
      REPLACE INV_COMMT WITH MINV_COMMT
      REPLACE SUP_COMMT WITH MSUP_COMMT
      UNLOCK
   ENDIF
   USE
   
   MWRIT_HIST = .F.
   IF MSUP_REAS1 <> OSUP_REAS1 .OR. MSUP_REAS2 <> OSUP_REAS2 .OR. MCUS_REAS1 <> OCUS_REAS1 .OR. MCUS_REAS2 <> OCUS_REAS2
      MWRIT_HIST = .T.
   ENDIF
   IF MSUP_AMT1 <> OSUP_AMT1 .OR. MSUP_AMT2 <> OSUP_AMT2 .OR. MCUS_AMT1 <> MORIG_AMT1 .OR. MCUS_AMT2 <> MORIG_AMT2
      MWRIT_HIST = .T.
   ENDIF
   IF MWRITEOFF <> MORIG_WRIT .OR. MCUS_PALL <> MORIGCPALL .OR. MSUP_PALL <> OSUP_PALL
      MWRIT_HIST = .T.
   ENDIF
   IF MINV_COMMT <> OINV_COMMT .OR. MSUP_COMMT <> OSUP_COMMT
      MWRIT_HIST = .T.
   ENDIF
   USE
   
   IF MWRIT_HIST 
      SELECT F
      DO FOX_USE WITH "HIST_PG INDEX HIST_PG", .F.
      DO FILELOCK
      APPEND BLANK
      REPLACE SALESMAN WITH MSALESMAN
      REPLACE PO_NBR WITH MPO_NBR
      REPLACE PO_SUFFIX WITH MPO_SUFFIX
      UNLOCK
      DO RECLOCK
      REPLACE USERID WITH MUSER
      REPLACE HIST_DATE WITH DATE()
      REPLACE HIST_TIME WITH TIME()
      REPLACE SUP_REAS1 WITH OSUP_REAS1
      REPLACE SUP_REAS2 WITH OSUP_REAS2
      REPLACE CUS_REAS1 WITH OCUS_REAS1
      REPLACE CUS_REAS2 WITH OCUS_REAS2
      REPLACE SUP_AMT1  WITH OSUP_AMT1
      REPLACE SUP_AMT2  WITH OSUP_AMT2
      REPLACE CUS_AMT1  WITH MORIG_AMT1
      REPLACE CUS_AMT2  WITH MORIG_AMT2
      REPLACE WRITEOFF  WITH MORIG_WRIT
      REPLACE CUS_PALL  WITH MORIGCPALL
      REPLACE SUP_PALL  WITH OSUP_PALL
      REPLACE INV_COMMT WITH MINV_COMMT
      REPLACE SUP_COMMT WITH MSUP_COMMT
      UNLOCK
      USE
   ENDIF
   
   SELECT B
   
   **IF INV_FLG <> ' ' .AND. BBUYCODE <> 'INVN' .AND. BBUYCODE <> 'NONE'
   IF INV_FLG <> ' ' .AND. BBUYCODE <> 'I' .AND. BBUYCODE <> 'NONE'
      IF MCUS_AMT1 <> MORIG_AMT1 .OR. MCUS_AMT2 <> MORIG_AMT2 .OR. MWRITEOFF <> MORIG_WRIT .OR. MCUS_PALL <> MORIGCPALL
         MALL_PAID= .T.
         STORE INV_NBR TO MINV_NBR
         SELECT E
         DO FOX_USE WITH "CUS_INV INDEX CUSIVNBR, CUS_INV, CUS_DATE, CUS_SHIP", .F.
         SEEK MINV_NBR
         DO WHILE .NOT. EOF() .AND. INV_NBR = MINV_NBR .AND. MALL_PAID 
            IF PAID_FLG <> ' '
               SKIP
               LOOP
            ENDIF
            **** THOSE CREDITS ON FILE THAT WERE CREATED WHEN A RECEIPT WAS
            **** ENTERED, WHEN A CUSTOMER ADJUSTMENT IS MADE. - SO SKIP THOSE
            **** DO NOT UPDATE THOSE
            IF CRED_PAY <> ' '
               SKIP
               LOOP
            ENDIF
            MALL_PAID = .F.
         ENDDO
         
         IF MALL_PAID .AND. B->PAID_FLG <> ' '
            MWARNING = .F.
            IF MCUS_AMT1 <> MORIG_AMT1 .AND. MCUS_AMT1 < MORIG_AMT1
               MWARNING = .T.
            ENDIF
            IF MCUS_AMT2 <> MORIG_AMT2 .AND. MCUS_AMT2 < MORIG_AMT2
               MWARNING = .T.
            ENDIF
            IF MWRITEOFF <> MORIG_WRIT .AND. MWRITEOFF < MORIG_WRIT
               MWARNING = .T.
            ENDIF
            IF MCUS_PALL <> MORIGCPALL .AND. MCUS_PALL < MORIGCPALL
               MWARNING = .T.
            ENDIF
            IF MWARNING
               @ 24,0 CLEAR
               MYES_NO = '   '
               @ 24,0 SAY 'WARNING: CUSTOMER PAID IN FULL, DEDUCTION GIVES CREDIT !   EDIT (YES/NO)? ' GET MYES_NO PICTURE '@!' VALID(MYES_NO = 'YES' .OR. MYES_NO = 'NO ')
               READ
               @ 24,0 CLEAR
               IF MYES_NO = 'YES'
                  LOOP
               ENDIF
            ENDIF
         ENDIF
         DO CASE
         CASE MALL_PAID
            *** IF EVERYTHING IS ALL PAID - NEED TO MAKE A NEW ENTRY
            SELECT E
            DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
            **** WRITEOFF
            IF MCUS_AMT1 <> MORIG_AMT1
               DO FILELOCK
               APPEND BLANK
               REPLACE salesman   WITH B->salesman  
               REPLACE po_nbr     WITH B->po_nbr    
               REPLACE po_suffix  WITH B->po_suffix 
               REPLACE buy_code   WITH B->buy_code  
               REPLACE bbuycode   WITH B->bbuycode  
               REPLACE ship_date  WITH B->ship_date 
               REPLACE TOT_SELL  WITH MCUS_AMT1 - MORIG_AMT1
               IF VAL(MINV_NBR) < 10000
                  STORE 'A' + SUBSTR(MINV_NBR,2) TO MNBR
                  REPLACE inv_nbr    WITH MNBR
               ELSE
                  REPLACE INV_NBR WITH MINV_NBR
               ENDIF
               REPLACE DEB_CRD WITH 'Y'
               REPLACE INV_DATE   WITH DATE()       
               UNLOCK
            ENDIF
            *** WRITEOFF
            IF MCUS_AMT2 <> MORIG_AMT2
               DO FILELOCK
               APPEND BLANK
               REPLACE salesman   WITH B->salesman  
               REPLACE po_nbr     WITH B->po_nbr    
               REPLACE po_suffix  WITH B->po_suffix 
               REPLACE buy_code   WITH B->buy_code  
               REPLACE bbuycode   WITH B->bbuycode  
               REPLACE ship_date  WITH B->ship_date 
               REPLACE TOT_SELL  WITH MCUS_AMT2 - MORIG_AMT2
               IF VAL(MINV_NBR) < 10000
                  STORE 'A' + SUBSTR(MINV_NBR,2) TO MNBR
                  REPLACE inv_nbr    WITH MNBR
               ELSE
                  REPLACE INV_NBR WITH MINV_NBR
               ENDIF
               REPLACE DEB_CRD WITH 'Y'
               REPLACE inv_date   WITH DATE()       
               UNLOCK
            ENDIF
            IF MWRITEOFF <> MORIG_WRIT
               DO FILELOCK
               APPEND BLANK
               REPLACE salesman   WITH B->salesman  
               REPLACE po_nbr     WITH B->po_nbr    
               REPLACE po_suffix  WITH B->po_suffix 
               REPLACE buy_code   WITH B->buy_code  
               REPLACE bbuycode   WITH B->bbuycode  
               REPLACE ship_date  WITH B->ship_date 
               REPLACE TOT_SELL  WITH MWRITEOFF - MORIG_WRIT
               IF VAL(MINV_NBR) < 10000
                  STORE 'A' + SUBSTR(MINV_NBR,2) TO MNBR
                  REPLACE inv_nbr    WITH MNBR
               ELSE
                  REPLACE INV_NBR WITH MINV_NBR
               ENDIF
               REPLACE DEB_CRD WITH 'Y'
               REPLACE inv_date   WITH DATE()       
               UNLOCK
            ENDIF
            IF MCUS_PALL <> MORIGCPALL
               DO FILELOCK
               APPEND BLANK
               REPLACE salesman   WITH B->salesman  
               REPLACE po_nbr     WITH B->po_nbr    
               REPLACE po_suffix  WITH B->po_suffix 
               REPLACE buy_code   WITH B->buy_code  
               REPLACE bbuycode   WITH B->bbuycode  
               REPLACE ship_date  WITH B->ship_date 
               REPLACE TOT_SELL  WITH MCUS_PALL - MORIGCPALL
               IF VAL(MINV_NBR) < 10000
                  STORE 'A' + SUBSTR(MINV_NBR,2) TO MNBR
                  REPLACE inv_nbr    WITH MNBR
               ELSE
                  REPLACE INV_NBR WITH MINV_NBR
               ENDIF
               REPLACE DEB_CRD WITH 'Y'
               REPLACE inv_date   WITH DATE()       
               UNLOCK
            ENDIF
         OTHERWISE
            IF MCUS_AMT1 <> MORIG_AMT1
               DO RECLOCK 
               REPLACE TOT_SELL WITH TOT_SELL + (MCUS_AMT1- MORIG_AMT1)
               UNLOCK
            ENDIF
            IF MCUS_AMT2 <> MORIG_AMT2
               DO RECLOCK
               REPLACE TOT_SELL  WITH TOT_SELL + (MCUS_AMT2 - MORIG_AMT2)
               UNLOCK
            ENDIF
            IF MWRITEOFF <> MORIG_WRIT
               DO RECLOCK 
               REPLACE TOT_SELL  WITH TOT_SELL + (MWRITEOFF - MORIG_WRIT)
               UNLOCK
            ENDIF
            IF MCUS_PALL <> MORIGCPALL
               DO RECLOCK 
               REPLACE CUS_PALL  WITH CUS_PALL + (MCUS_PALL - MORIGCPALL)
               UNLOCK
            ENDIF
         ENDCASE 
      ENDIF
   ENDIF
   *** IF SUPPLIER BILL IS PAID - PUT OUT ADJUSTMENTS 
   **IF B->SUP_PD <> ' ' .AND. B->RSUPCODE <> 'NONE' .AND. B->RSUPCODE <> 'INVN'
   IF B->SUP_PD <> ' ' .AND. B->RSUPCODE <> 'NONE' .AND. B->RSUPCODE <> 'I'
      IF MSUP_AMT1 <> OSUP_AMT1 .OR. MSUP_AMT2 <> OSUP_AMT2 .OR. MSUP_PALL <> OSUP_PALL
         SELECT A
         DO FOX_USE WITH "DISBJRN INDEX DISB_PO", .F.
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + 'S'
         IF .NOT. EOF()
            STORE BILL_INV TO MSUP_INV
         ELSE
            STORE SPACE(12) TO MSUP_INV
         ENDIF
         
         SELECT A
         DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
         ***** POSSIBLY DO SOMETHING HERE WHERE IF THEY CHANGE THE AMOUNT
         ***** OTHER THAN ADJUSTMENTS - MAKE AN ADJUSTING ENTRY
         IF MSUP_AMT1 <> OSUP_AMT1
            DO FILELOCK
            APPEND BLANK
            REPLACE salesman   WITH Msalesman  
            REPLACE po_nbr     WITH Mpo_nbr    
            REPLACE po_suffix  WITH Mpo_suffix 
            REPLACE RSUPCODE   WITH MRSUPCODE    
            REPLACE AMT_DUE   WITH MSUP_AMT1 - OSUP_AMT1  
            REPLACE inv_nbr    WITH B->inv_nbr      
            REPLACE DUE_DATE WITH DATE()
            REPLACE REASON WITH MSUP_REAS1  
            REPLACE SUP_INV WITH MSUP_INV
            REPLACE DEB_CRD WITH 'Y'
            REPLACE SEQ WITH '1'
            UNLOCK
         ENDIF
         IF MSUP_AMT2 <> OSUP_AMT2
            DO FILELOCK
            APPEND BLANK
            REPLACE salesman   WITH Msalesman  
            REPLACE po_nbr     WITH Mpo_nbr    
            REPLACE po_suffix  WITH Mpo_suffix 
            REPLACE RSUPCODE   WITH MRSUPCODE    
            REPLACE AMT_DUE   WITH MSUP_AMT2 - OSUP_AMT2   
            REPLACE inv_nbr    WITH B->inv_nbr      
            REPLACE DUE_DATE WITH DATE()
            REPLACE REASON WITH MSUP_REAS2
            REPLACE SUP_INV WITH MSUP_INV
            REPLACE DEB_CRD WITH 'Y'
            REPLACE SEQ WITH '2'
            UNLOCK
         ENDIF
         
         IF MSUP_PALL <> OSUP_PALL  
            DO FILELOCK
            APPEND BLANK
            REPLACE salesman   WITH Msalesman  
            REPLACE po_nbr     WITH Mpo_nbr    
            REPLACE po_suffix  WITH Mpo_suffix 
            REPLACE RSUPCODE   WITH MRSUPCODE    
            REPLACE AMT_DUE   WITH MSUP_PALL - OSUP_PALL    
            REPLACE inv_nbr    WITH B->inv_nbr      
            REPLACE DUE_DATE WITH DATE()
            REPLACE REASON WITH 'PALLETS'
            REPLACE DEB_CRD WITH 'Y'
            REPLACE SUP_INV WITH MSUP_INV
            REPLACE SEQ WITH '3'
            UNLOCK
         ENDIF        
         USE
         SELECT B
      ENDIF
   ENDIF
   IF MACTION = 1
      MGOTO_PG = 4
   ELSE
      MGOTO_PG = 2
   ENDIF
   MMORE_MISC = .F.
ENDDO
SELECT E
USE
SELECT F
USE
FLUSH
RETURN
* EOF: MISC_CHG.PRG

*Formatted by: ToolBox Ver. 1.2  on 12/20/17 at 10:25 AM.
