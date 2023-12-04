**************************
*  FILE NAME: H_PROC.PRG
*  BY: GRACE KELLER
*  DATE: 4/10/95
*  CALLED BY:
*  DATA FILES:
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
*
PROCEDURE TEXT2ND 
@ 04,1 SAY '                P R P'
@ 05,1 SAY ' SHIP        FH T E A PROD   '   
@ 05,39 SAY 'UNITS/'
@ 05,48 SAY 'PURCH'
@ 05,56 SAY 'SELL'
@ 05,66 SAY 'TOTAL'
@ 05,75 SAY 'TOTAL'
@ 06,1 SAY '  QTY UNITPK FR Y F K CODE   SIZE'
@ 06,39 SAY 'POUNDS'
@ 06,48 SAY 'PRICE'
@ 06,56 SAY 'PRICE'
@ 06,66 SAY 'PURCH'
@ 06,76 SAY 'SELL'
@ 06,0 TO 06,80
@ 24,0 TO 24,80
RETURN

PROCEDURE TEXT3RD
@ 04,0 SAY 'S'
@ 05,0 SAY 'E'
@ 06,0 SAY 'L'
RETURN

PROCEDURE TEXT4TH 
@ 04,1 SAY '                P R P'
@ 05,1 SAY ' SHIP        FH T E A PROD   '   
@ 05,39 SAY 'UNITS/'
@ 05,48 SAY 'PURCH'
@ 05,56 SAY 'SELL'
@ 05,66 SAY 'TOTAL'
@ 05,75 SAY 'TOTAL'
@ 06,1 SAY '  QTY UNITPK FR Y F K CODE   SIZE'
@ 06,39 SAY 'POUNDS'
@ 06,48 SAY 'PRICE'
@ 06,56 SAY 'PRICE'
@ 06,66 SAY 'PURCH'
@ 06,76 SAY 'SELL'
@ 06,0 TO 06,80
@ 24,0 TO 24,80
RETURN


PROCEDURE SAYITM
**MSTOR_ITEM(MNBR_ITM) = 0            
@ MLINE,0 SAY SPACE(79)
@ MLINE+1,0 SAY SPACE(79)
@ MLINE,2 SAY MQTY(MNBR_ITM) PICTURE '####'
@ MLINE,7 SAY MPACKSPEC(MNBR_ITM) PICTURE '@!'
@ MLINE,14 SAY MFR_FZ(MNBR_ITM) PICTURE '@!'
@ MLINE,17 SAY MGRADE(MNBR_ITM) PICTURE '@!'
@ MLINE,19 SAY MPAK1(MNBR_ITM) PICTURE '@!'
@ MLINE,21 SAY MPAK2(MNBR_ITM) PICTURE '@!'
@ MLINE,23 SAY MPROD(MNBR_ITM) PICTURE '@!'
@ MLINE,30 SAY MSIZE(MNBR_ITM) PICTURE '@!'
MMMX = ((MPAGE-1)*7)+MNBR_ITM
IF MMMX <10
   @ MLINE+1,0 SAY STR(MMMX,1) + '.'
ELSE
   @ MLINE+1,0 SAY STR(MMMX,2) + '.'
ENDIF

IF MOUT_LOT(MNBR_ITM) <> SPACE(10)
   @ MLINE+1,3 SAY 'OUT LOT: '
   @ MLINE+1,12 SAY MOUT_LOT(MNBR_ITM) PICTURE '@!'
   @ MLINE+1,24 SAY "PAK:    /"
   @ MLINE+1,29 SAY MOUT_DAY(MNBR_ITM) PICTURE '999'
   @ MLINE+1,33 SAY MOUT_YR(MNBR_ITM) PICTURE '99'
ENDIF
IF MIN_LOT(MNBR_ITM) <> SPACE(10)
   @ MLINE+1,39 SAY 'TO LOT: '
   @ MLINE+1,47 SAY MIN_LOT(MNBR_ITM) PICTURE '@!'
   @ MLINE+1,59 SAY 'PAK:    /  '
   @ MLINE+1,64 SAY MPAK_DAY(MNBR_ITM) PICTURE '999'
   @ MLINE+1,68 SAY MPAK_YR(MNBR_ITM) PICTURE '99'
ENDIF


@ MLINE,36 SAY MLBS(MNBR_ITM) PICTURE '999999.99'

@ MLINE,46 SAY MPURC_PRI(MNBR_ITM) PICTURE '99.9999'
@ MLINE,55 SAY MSELL_PRI(MNBR_ITM) PICTURE '99.9999'


STORE 0 TO MDISP_PURC, MDISP_SELL
DO CALCDISP
@ MLINE,63 SAY MDISP_PURC PICTURE '99999.99'
@ MLINE,72 SAY MDISP_SELL PICTURE '99999.99'

SELECT C
RETURN

PROCEDURE HIGHITM 
MSAYLINE1 = STR(MQTY(MNBR_ITM),4) + ' ' + MPACKSPEC(MNBR_ITM)
MSAYLINE1 = MSAYLINE1 + SPACE(2)
MSAYLINE1 = MSAYLINE1 + ' ' + MFR_FZ(MNBR_ITM) + ' ' 
MSAYLINE1 = MSAYLINE1 + MGRADE(MNBR_ITM) + ' ' + MPAK1(MNBR_ITM) + ' ' + MPAK2(MNBR_ITM) + ' '
MSAYLINE1 = MSAYLINE1 + SUBSTR(MPROD(MNBR_ITM),1,6)
MSAYLINE1 = MSAYLINE1 + ' ' + MSIZE(MNBR_ITM) + ' '
MSAYLINE1 = MSAYLINE1 + TRANSFORM(MLBS(MNBR_ITM), '999999.99') + ' '

MPRI1 = MPURC_PRI(MNBR_ITM)
MPRI2 = MSELL_PRI(MNBR_ITM)

STORE 0 TO MDISP_PURC, MDISP_SELL
DO CALCDISP

MSAYLINE1 = MSAYLINE1 + TRANSFORM(MPRI1, '99.9999') + '  '
MSAYLINE1 = MSAYLINE1 + TRANSFORM(MPRI2, '99.9999') + ' '
MSAYLINE1 = MSAYLINE1 + TRANSFORM(MDISP_PURC, '99999.99') + ' '
MSAYLINE1 = MSAYLINE1 + TRANSFORM(MDISP_SELL, '99999.99') 


*** START LINE 2
MMMX = ((MPAGE-1)*7)+MNBR_ITM
IF MMMX <10
   MSAYLINE2 = STR(MMMX,1) + '.' + ' '
ELSE
   MSAYLINE2 = STR(MMMX,2) + '.' 
ENDIF
IF MOUT_LOT(MNBR_ITM) <> SPACE(10)
   MSAYLINE2 = MSAYLINE2 + 'OUT LOT: ' + MOUT_LOT(MNBR_ITM)
   msayline2 = msayline2 + space(2) + 'PAK: ' + STR(MOUT_DAY(MNBR_ITM),3) + '/' + STR(MOUT_YR(MNBR_ITM),2) + space(4)
ELSE
   MSAYLINE2 = MSAYLINE2 + SPACE(12) + SPACE(10) + SPACE(14)
ENDIF

IF MIN_LOT(MNBR_ITM) <> SPACE(10)
   MSAYLINE2 = MSAYLINE2 + 'IN LOT: ' + MIN_LOT(MNBR_ITM) 
   MSAYLINE2 = MSAYLINE2 + SPACE(2) + 'PAK: ' + STR(MPAK_DAY(MNBR_ITM),3) + '/' + STR(MPAK_YR(MNBR_ITM),2)
ELSE
   MSAYLINE2 = MSAYLINE2 + SPACE(8) + SPACE(10)
ENDIF

SELECT C
@ MLINE,2 GET MSAYLINE1
MSAYLINE2A = SUBSTR(MSAYLINE2,1,3)
MSAYLINE2B = SUBSTR(MSAYLINE2,4)
@ MLINE+1,0 SAY MSAYLINE2A
@ MLINE+1,3 GET MSAYLINE2B
CLEAR GETS

RETURN



PROCEDURE CLEAROUT
@ MLINE,6 SAY ' '
@ MLINE,13 SAY ' '
@ MLINE,16 SAY ' '
@ MLINE,18 SAY ' '
@ MLINE,20 SAY ' '
@ MLINE,22 SAY ' '
@ MLINE,29 SAY ' '
@ MLINE,35 SAY ' '
@ MLINE,45 SAY ' '
@ MLINE,53 SAY '  '
@ MLINE,62 SAY ' '
@ MLINE,71 SAY ' '
@ MLINE+1,2 SAY ' '
@ MLINE+1,13 SAY ' '
@ MLINE+1,24 SAY '   '
@ MLINE+1,42 SAY ' '
@ MLINE+1,53 SAY '  '
@ MLINE+1,79 SAY '  '
RETURN



PROCEDURE GETITM 
*** FIGURE OUT IF THIS ITEM IS BEING ADDED OR CORRECTED
SELECT C
DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
I = ((MPAGE - 1) * 7) + MNBR_ITM
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + STR(I,2)
IF EOF()
   *** ADDED
   MADD_EDIT = 'A'
ELSE
   *** EDITED
   MADD_EDIT = 'E'
ENDIF

MDO_THIS = .T.
DO WHILE MDO_THIS 
   MMMX = ((MPAGE-1)*7)+MNBR_ITM
   DO CASE
      *** TAKING OUT OF INVENTORY
   CASE MRSUPCODE = 'INVN'
      *** TAKING OUT OF INVENTORY
      IF MMMX <10
         @ MLINE+1,0 SAY STR(MMMX,1) + '.'
      ELSE
         @ MLINE+1,0 SAY STR(MMMX,2) + '.'
      ENDIF
      @ MLINE+1,3 SAY 'OUT LOT:'
      @ MLINE+1,12 GET MOUT_LOT(MNBR_ITM) PICTURE '@!'
      READ
      IF MOUT_LOT(MNBR_ITM) = SPACE(10)
         DO CASE
         CASE MOLD_OUT(MNBR_ITM) = SPACE(10)
            IF MQTY(MNBR_ITM) <> 0
               @ 24,0       
               @ 24,1 SAY 'ERROR: NO LOT NUMBER ENTERED - MUST ENTER LOT -PRESS RETURN TO REENTER'
               MSPACE = ' '                            
               @ 24,78 GET MSPACE          
               READ
               @ 24,0 
               LOOP
            ELSE
               MDO_THIS = .F.
               *MMORE_ITM = .F.
               MNEXT_ITM = .F.
               LOOP
            ENDIF
            
         OTHERWISE
            @ 24,0       
            @ 24,1 SAY 'ERROR: PREV.LOT ENTERED-CANNOT DELETE LOT#-MUST ZERO OUT -PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            MOUT_LOT(MNBR_ITM) = MOLD_OUT(MNBR_ITM)
            LOOP
         ENDCASE
      ENDIF
      
      IF MOLD_OUT(MNBR_ITM) = 'P' .AND. MOUT_LOT(MNBR_ITM) = 'PENDING'
         @ 24,0       
         @ 24,1 SAY 'ERROR: PREVIOUS LOT PENDING - CANNOT REENTER PENDING -PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
      
      ** SUP_CODE = 158 IS MILLARD
      ** SUP_CODE =  85 IS AMERICOLD GADSDEN
      ** SUP_CODE =  86 IS AMERICOLD ALBERTVILLE
      ** SUP_CODE = 213 IS AMERICOLD BIRMINGHAM
      ** SUP_CODE = 243 is Lineage Attalla
      ** SUP_CODE = 207 IS Lineage Logistics (old Preferred)
      IF (MOUT_LOT(MNBR_ITM) = 'UN' .OR. MOUT_LOT(MNBR_ITM) = 'U ')
         IF B->SUP_CODE <> ' 207' .AND. B->SUP_CODE <> ' 243' .AND. B->SUP_CODE <> ' 158' .AND. B->SUP_CODE <> '  85' .AND. B->SUP_CODE <> '  86' .AND. B->SUP_CODE <> ' 213'
            @ 24,0       
            @ 24,1 SAY 'ERR: NOT CORRECT FREEZER - CANNOT DO UNDETERMINED - RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            LOOP
         ENDIF
      ENDIF
      
      *** PUT THIS ON HOLD FOR RIGHT NOW
      *** TAKING OUT OF INVENTORY , CANNOT BE PENDING
      *IF MOUT_LOT(MNBR_ITM) = 'P'
      *   @ 24,0       
      *   @ 24,1 SAY 'ERROR: TAKING OUT OF INVENTORY-LOT MUST NOT BE PENDING- PRESS RETURN TO REENTER'
      *   MSPACE = ' '
      *   @ 24,78 GET MSPACE
      *   READ
      *   @ 24,0 
      *   LOOP
      *ENDIF
      
      **IF MOUT_LOT(MNBR_ITM) = 'COMMIT'
      IF MOUT_LOT(MNBR_ITM) = 'UN' .OR. MOUT_LOT(MNBR_ITM) = 'U '
         *** GENERATE A LOT NUMBER HERE
         *** FORMULATE A LOT NUMBER HERE WITH PO NUMBER + ITEM
         MVAL_ORD = VAL(MPO_NBR)
         MVAL_SUFFIX = VAL(MPO_SUFFIX)
         *** SHIPPING OUT OF INVENTORY
         MOUT_LOT(MNBR_ITM) = 'U' + SUBSTR(STR(MVAL_ORD+10000,5),2) + ;
            SUBSTR(STR(MVAL_SUFFIX+10,2),2) + ;
            SUBSTR(STR(MMMX+100,3),2) + '  '
      ENDIF
      
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
      SEEK B->SUP_CODE
      IF EOF()
         MFREEZ_LOC = 'UNKNOWN' + SPACE(25)
      ELSE
         MFREEZ_LOC = NAME
      ENDIF
      
      **IF SUBSTR(MOUT_LOT(MNBR_ITM),1,1) <> 'C'
      IF SUBSTR(MOUT_LOT(MNBR_ITM),1,1) <> 'U'
         DO FOX_USE WITH "INVEN INDEX INVNLOC, INVNSOLD, INVNINBR, INVNLOT, INVNPO, INVNANIV, INVNCAT", .F.
         SEEK MFREEZ_LOC + MOUT_LOT(MNBR_ITM)
         IF EOF()
            DO FOX_USE WITH "HINVEN INDEX HINVNLOC, HINVSOLD", .F.
            SEEK MFREEZ_LOC + MOUT_LOT(MNBR_ITM)
            IF EOF()
               @ 24,0
               @ 24,1 SAY 'ERROR: TAKING OUT OF INVENTORY -ENTERED LOT NOT ON FILE - PRESS RETURN TO REENTER'
               MSPACE = ' '
               @ 24,78 GET MSPACE
               READ
               @ 24,0 
               LOOP
            ELSE
               MCASE_LEFT          = CASE_CNT
            ENDIF
         ELSE
            MCASE_LEFT          = CASE_LEFT
         ENDIF
         MCASE_COM           = CASE_COM
         MPURC_PRI(MNBR_ITM) = PRI_LB
         MBOX_SZ(MNBR_ITM)   = BOX_SZ
         MMULT               = BOX_SZ
         MFR_FZ(MNBR_ITM)    = FRH_FRZ
         MPAK1(MNBR_ITM)     = SUBSTR(PACKAGED,1,1)
         MPAK2(MNBR_ITM)     = SUBSTR(PACKAGED,2,1)
         MGRADE(MNBR_ITM)    = GRADE
         MPROD(MNBR_ITM)     = PROD_DESC
         MSIZE(MNBR_ITM)     = SIZE
         MPACKSPEC(MNBR_ITM) = SUBSTR(PACKED,1,4)
         *** NEW 12/13/2013
         IF B->BBUYCODE = 'INVN'
            MPAK_YR(MNBR_ITM)  = PAK_YR
            MPAK_DAY(MNBR_ITM) = PAK_DAY
         ENDIF
         MOUT_YR(MNBR_ITM) = PAK_YR
         MOUT_DAY(MNBR_ITM)= PAK_DAY
      ENDIF
      
      USE
      SELECT C
      @ MLINE+1,12 SAY MOUT_LOT(MNBR_ITM) PICTURE '@!'
      @ MLINE+1,24 SAY "PAK:    /"
      @ MLINE+1,29 SAY MOUT_DAY(MNBR_ITM) PICTURE '999'
      @ MLINE+1,33 SAY MOUT_YR(MNBR_ITM) PICTURE '99'
      @ MLINE,2 GET MQTY(MNBR_ITM) PICTURE '####'
      *** IF COMMITTED - NO PRODUCT THERE
      **IF MOUT_LOT(MNBR_ITM) = 'C'
      IF MOUT_LOT(MNBR_ITM) = 'U'
         **@ MLINE,7 GET MPACKSPEC(MNBR_ITM) PICTURE '@!'
         MFR_FZ(MNBR_ITM) = 'FR'
         @ MLINE,14 SAY MFR_FZ(MNBR_ITM) PICTURE '@!'
         @ MLINE,17 GET MGRADE(MNBR_ITM) PICTURE '@!'
         @ MLINE,19 GET MPAK1(MNBR_ITM) PICTURE '@!'
         @ MLINE,21 GET MPAK2(MNBR_ITM) PICTURE '@!'
         @ MLINE,23 GET MPROD(MNBR_ITM) PICTURE '@!'
         @ MLINE,30 GET MSIZE(MNBR_ITM) PICTURE '@!'
      ELSE
         @ MLINE,7 SAY MPACKSPEC(MNBR_ITM) PICTURE '@!'
         @ MLINE,14 SAY MFR_FZ(MNBR_ITM) PICTURE '@!'
         @ MLINE,17 SAY MGRADE(MNBR_ITM) PICTURE '@!'
         @ MLINE,19 SAY MPAK1(MNBR_ITM) PICTURE '@!'
         @ MLINE,21 SAY MPAK2(MNBR_ITM) PICTURE '@!'
         @ MLINE,23 SAY MPROD(MNBR_ITM) PICTURE '@!'
         @ MLINE,30 SAY MSIZE(MNBR_ITM) PICTURE '@!'
      ENDIF
      READ
      
      *** CHECK OUT THE PRODUCT CODE
      IF MOUT_LOT(MNBR_ITM) = 'U'
         SELECT E
         DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
         
         *** CHECK OUT THE PRODUCT CODE
         SEEK 'R' + MPROD(MNBR_ITM)  
         IF EOF()
            @ 24,0       
            @ 24,1 SAY 'ERROR: PRODUCT CODE INVALID - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            LOOP
         ELSE
            IF BOX_CODE = SPACE(6)
               IF MPACKSPEC(MNBR_ITM) = SPACE(4)
                  MPACKSPEC(MNBR_ITM) = '?   '
               ENDIF
               MMULT = 0
            ELSE
               ** HERE
               MPACKSPEC(MNBR_ITM) = BOX_CODE
               IF BOX_CODE = 'CWT'
                  MMULT = 0
               ELSE
                  IF SUBSTR(BOX_CODE,1,1) = 'B'
                     MMULT = VAL(SUBSTR(BOX_CODE,2))
                  ELSE
                     MMULT = VAL(BOX_CODE)
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
         @ MLINE,7 SAY MPACKSPEC(MNBR_ITM) PICTURE '@!'
      ENDIF
      
      *** CHECK THIS LATER
      **IF MQTY(MNBR_ITM) <> 0 .AND. MOUT_LOT(MNBR_ITM) <> 'C'
      IF MQTY(MNBR_ITM) <> 0 .AND. MOUT_LOT(MNBR_ITM) <> 'U'
         SELECT E
         DO FOX_USE WITH "HINV_DTL", .F.
         SUM QTY FOR LOT_NBR = MOUT_LOT(MNBR_ITM) .AND. ACT_CODE = 'S' TO MPEND_OUT
         USE
         MPEND_OUT = -1 * MPEND_OUT
         SELECT C
         **** FIGURE THIS OUT *** HOW TO ADD IN STUFF PENDING TO BE SHIPPED
         IF MOLD_QTY(MNBR_ITM) <> MQTY(MNBR_ITM)
            IF MOLD_QTY(MNBR_ITM) = 0
               MCALC_LEFT = MCASE_LEFT - MPEND_OUT
            ELSE
               MCALC_LEFT = MCASE_LEFT - MPEND_OUT - (MOLD_QTY(MNBR_ITM) - MQTY(MNBR_ITM))
            ENDIF
            
            IF MQTY(MNBR_ITM) > MCALC_LEFT
               @ 24,0
               @ 24,1 SAY 'ERROR: NOT THAT MANY CASES LEFT IN LOT  - PRESS RETURN TO REENTER'
               MSPACE = ' '
               @ 24,78 GET MSPACE
               READ
               @ 24,0 
               LOOP
            ENDIF
         ENDIF
      ENDIF
      @ MLINE,2 SAY MQTY(MNBR_ITM) PICTURE '####'
   OTHERWISE
      *** NOT OUT OF INVENTORY - SO MUST GET ALL THE ITEM STUFF
      MP_DESC = SPACE(24)
      SELECT C
      *** 
      @ MLINE,2 GET MQTY(MNBR_ITM) PICTURE '####'
      ** ON AN ADD-SKIP OVER THIS - PICK UP OUT OF PRODUCT FILE 
      IF MADD_EDIT = 'A'
         IF MPACKSPEC(MNBR_ITM) <> SPACE(6)
            @ MLINE,7 GET MPACKSPEC(MNBR_ITM) PICTURE '@!'
         ENDIF
      ELSE
         @ MLINE,7 GET MPACKSPEC(MNBR_ITM) PICTURE '@!'
      ENDIF
      MFR_FZ(MNBR_ITM) = 'FR'
      @ MLINE,14 SAY MFR_FZ(MNBR_ITM) PICTURE '@!'
      @ MLINE,17 GET MGRADE(MNBR_ITM) PICTURE '@!'
      @ MLINE,19 GET MPAK1(MNBR_ITM) PICTURE '@!'
      @ MLINE,21 GET MPAK2(MNBR_ITM) PICTURE '@!'
      @ MLINE,23 GET MPROD(MNBR_ITM) PICTURE '@!'
      @ MLINE,30 GET MSIZE(MNBR_ITM) PICTURE '@!'
      @ MLINE+1,55 SAY MP_DESC
      READ
      
      IF MPROD(MNBR_ITM) = '2929'
         MFR_FZ(MNBR_ITM) = 'FH'
         @ MLINE,14 SAY MFR_FZ(MNBR_ITM) PICTURE '@!'
      ENDIF
      
      IF MPROD(MNBR_ITM) = SPACE(6)
         IF MOLD_PROD(MNBR_ITM) <> SPACE(6)
            @ 24,0       
            @ 24,0 SAY 'ITM#: ' + STR(MMMX,2)+' -CANNOT BLANKOUT PROD CODE-MUST ZERO CASE/LBS-PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,79 GET MSPACE
            READ
            @ 24,0 
            MPROD(MNBR_ITM) = MOLD_PROD(MNBR_ITM)
            LOOP
         ELSE
            @ MLINE,0 SAY SPACE(70)
            @ MLINE+1,0 SAY SPACE(70)
            MNEXT_ITM = .F.
            MDO_THIS = .F.
            LOOP
         ENDIF
      ENDIF
      
      *** DO EDITS ON THIS INFORMATION
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      *** CHECK OUT THE PRODUCT CODE
      SEEK 'R' + MPROD(MNBR_ITM)  
      IF EOF()
         @ 24,0       
         @ 24,1 SAY 'ERROR: PRODUCT CODE INVALID - PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ELSE
         IF BOX_CODE = SPACE(6)
            IF MPACKSPEC(MNBR_ITM) = SPACE(6)
               MPACKSPEC(MNBR_ITM) = '?     '
            ENDIF
            MMULT = 0
         ELSE
            ** HERE
            MPACKSPEC(MNBR_ITM) = BOX_CODE
            IF BOX_CODE = 'CWT'
               MMULT = 0
            ELSE
               IF SUBSTR(BOX_CODE,1,1) = 'B'
                  MMULT = VAL(SUBSTR(BOX_CODE,2))
               ELSE
                  MMULT = VAL(BOX_CODE)
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      @ MLINE,7 SAY MPACKSPEC(MNBR_ITM) PICTURE '@!'
      
      ** CHECK OUT UNIT PACK CODE
      IF MPACKSPEC(MNBR_ITM) = '?'
         @ 24,0       
         @ 24,1 SAY 'ERROR: CANNOT DETERMINE UNIT PACK - PRESS RETURN TO ENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
      
      SEEK 'S' + MPACKSPEC(MNBR_ITM)
      IF EOF()
         @ 24,0       
         @ 24,1 SAY 'ERROR: UNIT PACK CODE INVALID - PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
         MMULT = VAL(MPACKSPEC(MNBR_ITM))
      ELSE
         MMULT = BOX_SZ   
      ENDIF
      
      IF MFR_FZ(MNBR_ITM) <> SPACE(2) 
         SEEK 'F' + MFR_FZ(MNBR_ITM)
         IF EOF()
            @ 24,0       
            @ 24,1 SAY 'ERROR: FRESH/FROZEN CODE INVALID - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            LOOP
         ENDIF
      ELSE
         @ 24,0       
         @ 24,1 SAY 'ERROR: FRESH/FROZEN CODE NOT ENTERED - PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
      
      IF MGRADE(MNBR_ITM) <> SPACE(1)
         SEEK 'G' + MGRADE(MNBR_ITM)
         IF  EOF()
            @ 24,0       
            @ 24,1 SAY 'ERROR: PROCESS TYPE CODE INVALID - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            LOOP
         ENDIF
      ENDIF
      
      IF MPAK1(MNBR_ITM) <> SPACE(1)
         SEEK 'D' + MPAK1(MNBR_ITM)           
         IF EOF()
            @ 24,0       
            @ 24,1 SAY 'ERROR: REFRIGERATION CODE INVALID - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            LOOP
         ENDIF
      ENDIF
      *****************
      IF MPAK2(MNBR_ITM)    <> SPACE(1)
         SEEK 'K' + MPAK2(MNBR_ITM)   
         IF EOF()
            @ 24,0       
            @ 24,1 SAY 'ERROR: PACKAGING CODE INVALID - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            LOOP
         ENDIF
      ENDIF
      
      IF MSIZE(MNBR_ITM) <> SPACE(5)
         SEEK 'Z' + MSIZE(MNBR_ITM) 
         IF EOF()
            @ 24,0       
            @ 24,1 SAY 'ERROR: SIZE CODE INVALID - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            LOOP
         ENDIF
      ENDIF
      
      @ MLINE,2 SAY MQTY(MNBR_ITM) PICTURE '####'
      @ MLINE,7 SAY MPACKSPEC(MNBR_ITM) PICTURE '@!'
      @ MLINE,14 SAY MFR_FZ(MNBR_ITM) PICTURE '@!'
      @ MLINE,17 SAY MGRADE(MNBR_ITM) PICTURE '@!'
      @ MLINE,19 SAY MPAK1(MNBR_ITM) PICTURE '@!'
      @ MLINE,21 SAY MPAK2(MNBR_ITM) PICTURE '@!'
      @ MLINE,23 SAY MPROD(MNBR_ITM) PICTURE '@!'
      @ MLINE,30 SAY MSIZE(MNBR_ITM) PICTURE '@!'
   ENDCASE
   
   **** IF GOING INTO INVENTORY - GET ADDITIONAL LOT #
   IF MBBUYCODE = 'INVN'
      MMMX = ((MPAGE-1)*7)+MNBR_ITM
      IF MMMX <10
         @ MLINE+1,0 SAY STR(MMMX,1) + '.'
      ELSE
         @ MLINE+1,0 SAY STR(MMMX,2) + '.'
      ENDIF
      @ MLINE+1,39 SAY 'IN LOT:'
      @ MLINE+1,47 GET MIN_LOT(MNBR_ITM) PICTURE '@!'
      @ MLINE+1,59 SAY 'PAK:    /  '
      @ MLINE+1,64 GET MPAK_DAY(MNBR_ITM) PICTURE '999'
      @ MLINE+1,68 GET MPAK_YR(MNBR_ITM) PICTURE '99'
      READ
      
      ** BUY_CODE = 447 IS MILLARD
      ** BUY_CODE = 156 IS AMERICOLD GADSDEN
      
      IF (MIN_LOT(MNBR_ITM) = 'UN' .OR. MIN_LOT(MNBR_ITM) = 'U ') .AND. B->BUY_CODE <> ' 447' .AND. B->BUY_CODE <> ' 156'
         @ 24,0       
         @ 24,1 SAY 'ERR: NOT MILLARD OR GADSDEN -CANNOT DO UNDETERMINED -PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
      
      IF MIN_LOT(MNBR_ITM) = 'PENDING' .OR. MIN_LOT(MNBR_ITM) = 'PE'
         *** FORMULATE AN I NUMBER HERE WITH PO NUMBER + ITEM
         MVAL_ORD = VAL(MPO_NBR)
         MVAL_SUFFIX = VAL(MPO_SUFFIX)
         *** SHIPPING INTO HOLDING INVENTORY - GENERATE AN "A" LOT NBR
         MIN_LOT(MNBR_ITM) = 'P' + SUBSTR(STR(MVAL_ORD+10000,5),2) + ;
            SUBSTR(STR(MVAL_SUFFIX+10,2),2) + ;
            SUBSTR(STR(MMMX+100,3),2) + '  '
      ENDIF      
      
      IF MIN_LOT(MNBR_ITM) = 'UNDET' .OR. MIN_LOT(MNBR_ITM) = 'UN' .OR. MIN_LOT(MNBR_ITM) = 'U '
         *** FORMULATE AN I NUMBER HERE WITH PO NUMBER + ITEM
         MVAL_ORD = VAL(MPO_NBR)
         MVAL_SUFFIX = VAL(MPO_SUFFIX)
         *** SHIPPING INTO HOLDING INVENTORY - GENERATE A LOT NBR
         MIN_LOT(MNBR_ITM) = 'U' + SUBSTR(STR(MVAL_ORD+10000,5),2) + ;
            SUBSTR(STR(MVAL_SUFFIX+10,2),2) + ;
            SUBSTR(STR(MMMX+100,3),2) + '  '
      ENDIF      
      @ MLINE+1,47 SAY MIN_LOT(MNBR_ITM) PICTURE '@!'
      @ MLINE+1,64 SAY MPAK_DAY(MNBR_ITM) PICTURE '999'
      @ MLINE+1,68 SAY MPAK_YR(MNBR_ITM) PICTURE '99'
      
      IF MIN_LOT(MNBR_ITM) = SPACE(10) 
         @ 24,0       
         @ 24,1 SAY 'ERROR: INVENTORY MUST HAVE LOT NUMBER --PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
      
      ***IF MADD_EDIT = 'A'
      *** IF ADDING A LOT NUMBER, - GOING INTO INVENTORY - 
      *** SEE IF ON LOT ALREAY ON FILE IN INVENTORY
      *** IF ITS ON FILE - MUST BE THE SAME PO, ITEM
      SELECT F
      DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
      SEEK B->BUY_CODE
      IF .NOT. EOF()
         MFREEZ_LOC = NAME
      ELSE
         MFREEZ_LOC = 'UNKNOWN' + SPACE(25)
      ENDIF
      USE
      
      SELECT E
      DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT", .F.
      *** FIND THE RECORD PUTTING INTO INVENTORY
      SEEK MFREEZ_LOC + MIN_LOT(MNBR_ITM) + 'I'
      
      IF .NOT. EOF()
         ** IF NOT THE SAME ITEM PUTTING INTO INVENTORY - ERROR HERE
         MXX = ((MPAGE - 1) * 7) + MNBR_ITM
         MXX = STR(MXX,2)
         IF MSALESMAN+MPO_NBR+MPO_SUFFIX+MXX <> SALESMAN+PO_NBR+PO_SUFFIX+ITEM_NBR
            @ 24,0
            @ 24,1 SAY 'ERROR: LOT NUMBER ALREADY USED - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            USE
            LOOP
         ENDIF
      ELSE
         DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT", .F.
         *** FIND THE RECORD PUTTING INTO INVENTORY
         SEEK MFREEZ_LOC + MIN_LOT(MNBR_ITM) + 'I'
         IF .NOT. EOF()
            ** IF NOT THE SAME ITEM PUTTING INTO INVENTORY - ERROR HERE
            MXX = ((MPAGE - 1) * 7) + MNBR_ITM
            MXX = STR(MXX,2)
            IF MSALESMAN+MPO_NBR+MPO_SUFFIX+MXX <> SALESMAN+PO_NBR+PO_SUFFIX+ITEM_NBR
               @ 24,0
               @ 24,1 SAY 'ERROR: LOT NUMBER ALREADY USED - PRESS RETURN TO REENTER'
               MSPACE = ' '
               @ 24,78 GET MSPACE
               READ
               @ 24,0 
               USE
               LOOP
            ENDIF
         ENDIF
      ENDIF
      USE
      ****ENDIF
      
      IF MOLD_IN(MNBR_ITM) = 'P' .AND. MIN_LOT(MNBR_ITM) = 'PENDING'
         @ 24,0       
         @ 24,1 SAY 'ERROR: PREVIOUS LOT PENDING - CANNOT REENTER PENDING -PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
      
      **IF MOLD_IN(MNBR_ITM) = 'C' .AND. MIN_LOT(MNBR_ITM) = 'COMMIT'
      IF MOLD_IN(MNBR_ITM) = 'U' .AND. (MIN_LOT(MNBR_ITM) = 'UN' .OR. MIN_LOT(MNBR_ITM) = 'U ')
         @ 24,0       
         @ 24,1 SAY 'ERROR: PREVIOUS LOT COMMIT - CANNOT REENTER COMMIT -PRESS RETURN TO REENTER'
         MSPACE = ' '                                            
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
   ENDIF
   
   IF MQTY(MNBR_ITM) = 0
      MLBS(MNBR_ITM) = 0
   ENDIF
   
   **** NOW GET QTY FOR EVERYONE
   DO CASE
   CASE MPACKSPEC(MNBR_ITM) = 'CWT' .OR. MPACKSPEC(MNBR_ITM) = 'CBO' .OR. MPACKSPEC(MNBR_ITM) = '   '
      @ MLINE,36 GET MLBS(MNBR_ITM) PICTURE '999999.99'
      MBOX_SZ(MNBR_ITM) = 0
   CASE SUBSTR(MPACKSPEC(MNBR_ITM),1,1) = 'B' .OR. SUBSTR(MPACKSPEC(MNBR_ITM),1,1) = 'H'
      *** PRICED PER BOX
      MLBS(MNBR_ITM) = MQTY(MNBR_ITM)
      IF SUBSTR(MPACKSPEC(MNBR_ITM),1,1) = 'H'
         MLBS(MNBR_ITM) = MLBS(MNBR_ITM) * 24
      ENDIF
      @ MLINE,36 SAY MLBS(MNBR_ITM) PICTURE '999999.99'
      MBOX_SZ(MNBR_ITM) = MMULT
   OTHERWISE
      MLBS(MNBR_ITM) = MMULT * MQTY(MNBR_ITM)
      MBOX_SZ(MNBR_ITM) = MMULT
      @ MLINE,36 GET MLBS(MNBR_ITM) PICTURE '999999.99'
      *CLEAR GETS
   ENDCASE
   
   IF MRSUPCODE = 'INVN' .AND. MOUT_LOT(MNBR_ITM) = 'U'
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      SEEK 'R' + MPROD(MNBR_ITM)  
      IF .NOT. EOF()
         MPURC_PRI(MNBR_ITM) = AVG_PURCH
      ENDIF
   ENDIF
   
   IF MBBUYCODE = 'INVN' .AND. MIN_LOT(MNBR_ITM) = 'U'
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      SEEK 'R' + MPROD(MNBR_ITM)  
      IF .NOT. EOF()
         MSELL_PRI(MNBR_ITM) = AVG_PURCH
      ENDIF
   ENDIF
   
   
   IF MADD_EDIT = 'A' .AND. MRSUPCODE <> 'INVN' .AND. MRSUPCODE <> 'NONE'
      **** ON AN ADD- GET THE PRICE OFF THE SUPPLIER PRICING MASTER 
      SELECT F
      DO FOX_USE WITH "&MDBFLOC.SUP_MAST INDEX &MDBFLOC.SUP_MAST", .F.
      SEEK MRSUPCODE + MPROD(MNBR_ITM)
      IF .NOT. EOF()
         DO CASE
         CASE BEG_DT5 <> CTOD('') .AND. B->DEL_REQD >= BEG_DT5
            MPURC_PRI(MNBR_ITM) = PRICE5
         CASE BEG_DT4 <> CTOD('') .AND. B->DEL_REQD >= BEG_DT4
            MPURC_PRI(MNBR_ITM) = PRICE4
         CASE BEG_DT3 <> CTOD('') .AND. B->DEL_REQD >= BEG_DT3
            MPURC_PRI(MNBR_ITM) = PRICE3
         CASE BEG_DT2 <> CTOD('') .AND. B->DEL_REQD >= BEG_DT2
            MPURC_PRI(MNBR_ITM) = PRICE2
         OTHERWISE
            MPURC_PRI(MNBR_ITM) = PRICE1
         ENDCASE
      ENDIF
      USE
      SELECT B
   ENDIF
   
   
   IF MADD_EDIT = 'A' .AND. MBBUYCODE <> 'INVN' .AND. MBBUYCODE <> 'NONE'
      **** ON AN ADD- GET THE PRICE OFF THE CUSTOMER PRICING MASTER 
      SELECT F
      DO FOX_USE WITH "&MDBFLOC.PRI_MAST INDEX &MDBFLOC.PRI_MAST", .F.
      SEEK MBBUYCODE + MPROD(MNBR_ITM)
      IF .NOT. EOF()
         DO CASE
         CASE BEG_DT5 <> CTOD('') .AND. B->DEL_REQD >= BEG_DT5
            MSELL_PRI(MNBR_ITM) = PRICE5
         CASE BEG_DT4 <> CTOD('') .AND. B->DEL_REQD >= BEG_DT4
            MSELL_PRI(MNBR_ITM) = PRICE4
         CASE BEG_DT3 <> CTOD('') .AND. B->DEL_REQD >= BEG_DT3
            MSELL_PRI(MNBR_ITM) = PRICE3
         CASE BEG_DT2 <> CTOD('') .AND. B->DEL_REQD >= BEG_DT2
            MSELL_PRI(MNBR_ITM) = PRICE2
         OTHERWISE
            MSELL_PRI(MNBR_ITM) = PRICE1
         ENDCASE
         
         IF LAST_CUST = CTOD('')
            @ 24,0 CLEAR
            STORE '  ' TO MOK
            @ 24,1 SAY 'Item ' + str(mnbr_itm,1) + ' - Product Not Shipped Within Last 6 Months - Check Price -key OK ' get mok picture '@!' valid(mok = 'OK')
            READ
            @ 24,0 CLEAR
         ENDIF
         
      ENDIF
      
      *** CHECK FOR OFF ITEM PROMOTIONS
      
      SELECT F
      DO FOX_USE WITH "&MDBFLOC.CUSIOFF INDEX &MDBFLOC.CUSIOFF", .F.
      SEEK MBBUYCODE + MPROD(MNBR_ITM)
      DO WHILE .NOT. EOF() .AND. BBUYCODE = MBBUYCODE .AND. PROD_DESC = MPROD(MNBR_ITM)
         IF B->ORD_DATE >= BEG_DT .AND. B->ORD_DATE <= END_DT
            MSELL_PRI(MNBR_ITM) = MSELL_PRI(MNBR_ITM) + ITM_PROM
            GOTO BOTTOM
         ENDIF
         SKIP
      ENDDO
      USE
      SELECT B
      
   ENDIF
   
   DO CASE
   CASE MRSUPCODE = 'INVN' .AND. MBBUYCODE = 'INVN'
      MSELL_PRI(MNBR_ITM) = MPURC_PRI(MNBR_ITM)
      @ MLINE,46 SAY MPURC_PRI(MNBR_ITM) PICTURE '99.9999'
      @ MLINE,55 SAY MSELL_PRI(MNBR_ITM) PICTURE '99.9999'
      
   CASE MRSUPCODE = 'INVN'
      MSTOR_LB = 0
      **MLOT_X = MLOT(MNBR_ITM)
      *DO CALC_OUT
      **MSTOR_ITEM(MNBR_ITM) = MSTOR_LB
      **@ MLINE,46 SAY MPURC_PRI(MNBR_ITM) + MSTOR_ITEM(MNBR_ITM) PICTURE '99.9999'
      @ MLINE,46 SAY MPURC_PRI(MNBR_ITM) PICTURE '99.9999'
      @ MLINE,55 GET MSELL_PRI(MNBR_ITM) PICTURE '99.9999'
      READ
      
   CASE MBBUYCODE = 'INVN'
      MSTOR_LB = 0
      MPACKIT = MPACKSPEC(MNBR_ITM)
      MBOXIT  = MBOX_SZ(MNBR_ITM)
      *DO CALC_IN
      **MSTOR_ITEM(MNBR_ITM) = MSTOR_LB
      @ MLINE,46 GET MPURC_PRI(MNBR_ITM) PICTURE '99.9999'
      READ
      *@ MLINE,55 SAY MPURC_PRI(MNBR_ITM) + MSTOR_ITEM(MNBR_ITM) PICTURE '99.9999'
      *MSELL_PRI(MNBR_ITM) = MPURC_PRI(MNBR_ITM)
      MSELL_PRI(MNBR_ITM) = MPURC_PRI(MNBR_ITM)
      @ MLINE,55 SAY MSELL_PRI(MNBR_ITM) PICTURE '99.9999'
      @ MLINE+1,59 SAY 'PAK:    /  '
      @ MLINE+1,64 SAY MPAK_DAY(MNBR_ITM) PICTURE '999'
      @ MLINE+1,68 SAY MPAK_YR(MNBR_ITM) PICTURE '99'
      **READ
      
   OTHERWISE
      **MSTOR_ITEM(MNBR_ITM) = 0
      @ MLINE,46 GET MPURC_PRI(MNBR_ITM) PICTURE '99.9999'
      @ MLINE,55 GET MSELL_PRI(MNBR_ITM) PICTURE '99.9999'
      READ
   ENDCASE
   
   IF MLBS(MNBR_ITM) = 0                   
      @ 24,0       
      @ 24,1 SAY 'WARNING !!   NO POUNDS ENTERED - USUSALLY INCORRECT- CHECK - PRESS RETURN ' 
      MSPACE = ' '
      @ 24,78 GET MSPACE
      READ
      @ 24,0 
   ENDIF
   
   STORE 0 TO MDISP_PURC, MDISP_SELL
   
   DO CALCDISP
   
   @ MLINE,36 SAY MLBS(MNBR_ITM) PICTURE '999999.99'
   
   @ MLINE,46 SAY MPURC_PRI(MNBR_ITM) PICTURE '99.9999'
   @ MLINE,55 SAY MSELL_PRI(MNBR_ITM) PICTURE '99.9999'
   
   @ MLINE,63 SAY MDISP_PURC PICTURE '99999.99'
   @ MLINE,72 SAY MDISP_SELL PICTURE '99999.99'
   
   MDO_THIS = .F.
ENDDO
SELECT E
USE
SELECT B
RETURN



PROCEDURE GETITMP
*** FIGURE OUT IF THIS ITEM IS BEING ADDED OR CORRECTED
SELECT C
DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
I = ((MPAGE - 1) * 7) + MNBR_ITM
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + STR(I,2)
IF EOF()
   *** ADDED
   MADD_EDIT = 'A'
ELSE
   *** EDITED
   MADD_EDIT = 'E'
ENDIF

MDO_THIS = .T.
DO WHILE MDO_THIS 
   MMMX = ((MPAGE-1)*7)+MNBR_ITM
   DO CASE
      *** TAKING OUT OF INVENTORY
   CASE MRSUPCODE = 'INVN'
      *** TAKING OUT OF INVENTORY
      IF MMMX <10
         @ MLINE+1,0 SAY STR(MMMX,1) + '.'
      ELSE
         @ MLINE+1,0 SAY STR(MMMX,2) + '.'
      ENDIF
      @ MLINE+1,3 SAY 'OUT LOT:'
      @ MLINE+1,12 SAY MOUT_LOT(MNBR_ITM) PICTURE '@!'
      @ MLINE+1,24 SAY "PAK:    /"
      @ MLINE+1,29 SAY MOUT_DAY(MNBR_ITM) PICTURE '999'
      @ MLINE+1,33 SAY MOUT_YR(MNBR_ITM) PICTURE '99'
      
      **@ MLINE+1,14 GET MOUT_LOT(MNBR_ITM) PICTURE '@!'
      **READ
      IF MOUT_LOT(MNBR_ITM) = SPACE(10)
         DO CASE
         CASE MOLD_OUT(MNBR_ITM) = SPACE(10)
            IF MQTY(MNBR_ITM) <> 0
               @ 24,0       
               @ 24,1 SAY 'ERROR: NO LOT NUMBER ENTERED - MUST ENTER LOT -PRESS RETURN TO REENTER'
               MSPACE = ' '                            
               @ 24,78 GET MSPACE
               READ
               @ 24,0 
               LOOP
            ELSE
               MDO_THIS = .F.
               *MMORE_ITM = .F.
               MNEXT_ITM = .F.
               LOOP
            ENDIF
            
         OTHERWISE
            @ 24,0       
            @ 24,1 SAY 'ERROR: PREV.LOT ENTERED-CANNOT DELETE LOT#-MUST ZERO OUT -PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            MOUT_LOT(MNBR_ITM) = MOLD_OUT(MNBR_ITM)
            LOOP
         ENDCASE
      ENDIF
      
      IF MOLD_OUT(MNBR_ITM) = 'P' .AND. MOUT_LOT(MNBR_ITM) = 'PENDING'
         @ 24,0       
         @ 24,1 SAY 'ERROR: PREVIOUS LOT PENDING - CANNOT REENTER PENDING -PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
      
      *** PUT THIS ON HOLD FOR RIGHT NOW
      *** TAKING OUT OF INVENTORY , CANNOT BE PENDING
      *IF MOUT_LOT(MNBR_ITM) = 'P'
      *   @ 24,0       
      *   @ 24,1 SAY 'ERROR: TAKING OUT OF INVENTORY-LOT MUST NOT BE PENDING- PRESS RETURN TO REENTER'
      *   MSPACE = ' '
      *   @ 24,78 GET MSPACE
      *   READ
      *   @ 24,0 
      *   LOOP
      *ENDIF
      
      **IF MOUT_LOT(MNBR_ITM) = 'COMMIT'
      IF MOUT_LOT(MNBR_ITM) = 'UN' .OR. MOUT_LOT(MNBR_ITM) = 'U '
         *** GENERATE A LOT NUMBER HERE
         *** FORMULATE A LOT NUMBER HERE WITH PO NUMBER + ITEM
         MVAL_ORD = VAL(MPO_NBR)
         MVAL_SUFFIX = VAL(MPO_SUFFIX)
         *** SHIPPING OUT OF INVENTORY
         **MOUT_LOT(MNBR_ITM) = 'C' + SUBSTR(STR(MVAL_ORD+10000,5),2) + ;
         MOUT_LOT(MNBR_ITM) = 'U' + SUBSTR(STR(MVAL_ORD+10000,5),2) + ;
            SUBSTR(STR(MVAL_SUFFIX+10,2),2) + ;
            SUBSTR(STR(MMMX+100,3),2)  + '  '
      ENDIF
      
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
      SEEK B->SUP_CODE
      IF EOF()
         MFREEZ_LOC = 'UNKNOWN' + SPACE(25)
      ELSE
         MFREEZ_LOC = NAME
      ENDIF
      
      **IF SUBSTR(MOUT_LOT(MNBR_ITM),1,1) <> 'C'
      IF SUBSTR(MOUT_LOT(MNBR_ITM),1,1) <> 'U'
         DO FOX_USE WITH "INVEN INDEX INVNLOC, INVNSOLD, INVNINBR, INVNLOT, INVNPO, INVNANIV, INVNCAT", .F.
         SEEK MFREEZ_LOC + MOUT_LOT(MNBR_ITM)
         IF EOF()
            DO FOX_USE WITH "HINVEN INDEX HINVNLOC, HINVSOLD", .F.
            SEEK MFREEZ_LOC + MOUT_LOT(MNBR_ITM)
            IF EOF()
               @ 24,0
               @ 24,1 SAY 'ERROR: TAKING OUT OF INVENTORY -ENTERED LOT NOT ON FILE - PRESS RETURN TO REENTER'
               MSPACE = ' '
               @ 24,78 GET MSPACE
               READ
               @ 24,0 
               LOOP
            ELSE
               MCASE_LEFT          = CASE_CNT
            ENDIF
         ELSE
            MCASE_LEFT          = CASE_LEFT
         ENDIF
         MCASE_COM           = CASE_COM
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
         MOUT_DAY(MNBR_ITM)  = PAK_DAY
         MOUT_YR(MNBR_ITM)   = PAK_YR
      ENDIF
      
      USE
      SELECT C
      @ MLINE+1,12 SAY MOUT_LOT(MNBR_ITM) PICTURE '@!'
      @ MLINE+1,24 SAY "PAK:    /"
      @ MLINE+1,29 SAY MOUT_DAY(MNBR_ITM) PICTURE '999'
      @ MLINE+1,33 SAY MOUT_YR(MNBR_ITM) PICTURE '99'
      @ MLINE,2 GET MQTY(MNBR_ITM) PICTURE '####'
      *** IF COMMITTED - NO PRODUCT THERE
      **IF MOUT_LOT(MNBR_ITM) = 'C'
      IF MOUT_LOT(MNBR_ITM) = 'U'
         **@ MLINE,7 GET MPACKSPEC(MNBR_ITM) PICTURE '@!'
         MFR_FZ(MNBR_ITM) = 'FR'
         @ MLINE,14 SAY MFR_FZ(MNBR_ITM) PICTURE '@!'
         @ MLINE,17 GET MGRADE(MNBR_ITM) PICTURE '@!'
         @ MLINE,19 GET MPAK1(MNBR_ITM) PICTURE '@!'
         @ MLINE,21 GET MPAK2(MNBR_ITM) PICTURE '@!'
         @ MLINE,23 GET MPROD(MNBR_ITM) PICTURE '@!'
         @ MLINE,30 GET MSIZE(MNBR_ITM) PICTURE '@!'
      ELSE
         @ MLINE,7 SAY MPACKSPEC(MNBR_ITM) PICTURE '@!'
         @ MLINE,14 SAY MFR_FZ(MNBR_ITM) PICTURE '@!'
         @ MLINE,17 SAY MGRADE(MNBR_ITM) PICTURE '@!'
         @ MLINE,19 SAY MPAK1(MNBR_ITM) PICTURE '@!'
         @ MLINE,21 SAY MPAK2(MNBR_ITM) PICTURE '@!'
         @ MLINE,23 SAY MPROD(MNBR_ITM) PICTURE '@!'
         @ MLINE,30 SAY MSIZE(MNBR_ITM) PICTURE '@!'
      ENDIF
      READ
      
      IF MQTY(MNBR_ITM) <> 0
         SELECT E
         DO FOX_USE WITH "HINV_DTL", .F.
         SUM QTY FOR LOT_NBR = MOUT_LOT(MNBR_ITM) .AND. ACT_CODE = 'S' TO MPEND_OUT
         USE
         MPEND_OUT = -1 * MPEND_OUT
         SELECT C
         **** FIGURE THIS OUT *** HOW TO ADD IN STUFF PENDING TO BE SHIPPED
         IF MOLD_QTY(MNBR_ITM) <> MQTY(MNBR_ITM)
            IF MOLD_QTY(MNBR_ITM) = 0
               MCALC_LEFT = MCASE_LEFT - MPEND_OUT
            ELSE
               MCALC_LEFT = MCASE_LEFT - MPEND_OUT - (MOLD_QTY(MNBR_ITM) - MQTY(MNBR_ITM))
            ENDIF
            
            IF MQTY(MNBR_ITM) > MCALC_LEFT
               @ 24,0
               @ 24,1 SAY 'ERROR: NOT THAT MANY CASES LEFT IN LOT  - PRESS RETURN TO REENTER'
               MSPACE = ' '
               @ 24,78 GET MSPACE
               READ
               @ 24,0 
               LOOP
            ENDIF
         ENDIF
      ENDIF
      @ MLINE,2 SAY MQTY(MNBR_ITM) PICTURE '####'
   OTHERWISE
      *** NOT OUT OF INVENTORY - SO MUST GET ALL THE ITEM STUFF
      MP_DESC = SPACE(24)
      SELECT C
      *** 
      @ MLINE,2 GET MQTY(MNBR_ITM) PICTURE '####'
      **@ MLINE,7 GET MPACKSPEC(MNBR_ITM) PICTURE '@!'
      MFR_FZ(MNBR_ITM) = 'FR'
      @ MLINE,14 GET MFR_FZ(MNBR_ITM) PICTURE '@!'
      @ MLINE,17 GET MGRADE(MNBR_ITM) PICTURE '@!'
      @ MLINE,19 GET MPAK1(MNBR_ITM) PICTURE '@!'
      @ MLINE,21 GET MPAK2(MNBR_ITM) PICTURE '@!'
      @ MLINE,23 GET MPROD(MNBR_ITM) PICTURE '@!'
      @ MLINE,30 GET MSIZE(MNBR_ITM) PICTURE '@!'
      @ MLINE+1,55 SAY MP_DESC
      READ
      
      IF MPROD(MNBR_ITM) = SPACE(6)
         IF MOLD_PROD(MNBR_ITM) <> SPACE(6)
            @ 24,0       
            @ 24,0 SAY 'ITM#: ' + STR(MMMX,2)+' -CANNOT BLANKOUT PROD CODE-MUST ZERO CASE/LBS-PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,79 GET MSPACE
            READ
            @ 24,0 
            MPROD(MNBR_ITM) = MOLD_PROD(MNBR_ITM)
            LOOP
         ELSE
            @ MLINE,0 SAY SPACE(70)
            @ MLINE+1,0 SAY SPACE(70)
            MNEXT_ITM = .F.
            MDO_THIS = .F.
            LOOP
         ENDIF
      ENDIF
      *** DO EDITS ON THIS INFORMATION
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      *** CHECK OUT THE PRODUCT CODE
      SEEK 'R' + MPROD(MNBR_ITM)  
      IF EOF()
         @ 24,0       
         @ 24,1 SAY 'ERROR: PRODUCT CODE INVALID - PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ELSE
         IF BOX_CODE = SPACE(6)
            IF MPACKSPEC(MNBR_ITM) = SPACE(6)
               MPACKSPEC(MNBR_ITM) = '?     '
            ENDIF
            MMULT = 0
         ELSE
            ** HERE
            MPACKSPEC(MNBR_ITM) = BOX_CODE
            IF SUBSTR(BOX_CODE,1,1) = 'B'
               MMULT = VAL(SUBSTR(BOX_CODE,2))
            ELSE
               MMULT = VAL(BOX_CODE)
            ENDIF
         ENDIF
      ENDIF
      @ MLINE,7 SAY MPACKSPEC(MNBR_ITM) PICTURE '@!'
      
      ** CHECK OUT UNIT PACK CODE
      SEEK 'S' + MPACKSPEC(MNBR_ITM)
      IF EOF()
         @ 24,0       
         @ 24,1 SAY 'ERROR: UNIT PACK CODE INVALID - PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ELSE
         MMULT = BOX_SZ   
      ENDIF
      
      IF MFR_FZ(MNBR_ITM) <> SPACE(2) 
         SEEK 'F' + MFR_FZ(MNBR_ITM)
         IF EOF()
            @ 24,0       
            @ 24,1 SAY 'ERROR: FRESH/FROZEN CODE INVALID - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            LOOP
         ENDIF
      ELSE
         @ 24,0       
         @ 24,1 SAY 'ERROR: FRESH/FROZEN CODE NOT ENTERED - PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
      
      IF MGRADE(MNBR_ITM) <> SPACE(1)
         SEEK 'G' + MGRADE(MNBR_ITM)
         IF  EOF()
            @ 24,0       
            @ 24,1 SAY 'ERROR: PROCESS TYPE CODE INVALID - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            LOOP
         ENDIF
      ENDIF
      
      IF MPAK1(MNBR_ITM) <> SPACE(1)
         SEEK 'D' + MPAK1(MNBR_ITM)           
         IF EOF()
            @ 24,0       
            @ 24,1 SAY 'ERROR: REFRIGERATION CODE INVALID - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            LOOP
         ENDIF
      ENDIF
      *****************
      IF MPAK2(MNBR_ITM)    <> SPACE(1)
         SEEK 'K' + MPAK2(MNBR_ITM)   
         IF EOF()
            @ 24,0       
            @ 24,1 SAY 'ERROR: PACKAGING CODE INVALID - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            LOOP
         ENDIF
      ENDIF
      
      *** CHECK OUT THE PRODUCT CODE
      SEEK 'R' + MPROD(MNBR_ITM)  
      IF EOF()
         @ 24,0       
         @ 24,1 SAY 'ERROR: PRODUCT CODE INVALID - PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
      
      IF MSIZE(MNBR_ITM) <> SPACE(5)
         SEEK 'Z' + MSIZE(MNBR_ITM) 
         IF EOF()
            @ 24,0       
            @ 24,1 SAY 'ERROR: SIZE CODE INVALID - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            LOOP
         ENDIF
      ENDIF
      
      @ MLINE,2 SAY MQTY(MNBR_ITM) PICTURE '####'
      @ MLINE,7 SAY MPACKSPEC(MNBR_ITM) PICTURE '@!'
      @ MLINE,14 SAY MFR_FZ(MNBR_ITM) PICTURE '@!'
      @ MLINE,17 SAY MGRADE(MNBR_ITM) PICTURE '@!'
      @ MLINE,19 SAY MPAK1(MNBR_ITM) PICTURE '@!'
      @ MLINE,21 SAY MPAK2(MNBR_ITM) PICTURE '@!'
      @ MLINE,23 SAY MPROD(MNBR_ITM) PICTURE '@!'
      @ MLINE,30 SAY MSIZE(MNBR_ITM) PICTURE '@!'
   ENDCASE
   
   **** IF GOING INTO INVENTORY - GET ADDITIONAL LOT #
   IF MBBUYCODE = 'INVN'
      MMMX = ((MPAGE-1)*7)+MNBR_ITM
      IF MMMX <10
         @ MLINE+1,0 SAY STR(MMMX,1) + '.'
      ELSE
         @ MLINE+1,0 SAY STR(MMMX,2) + '.'
      ENDIF
      @ MLINE+1,39 SAY 'TO LOT:'
      @ MLINE+1,47 GET MIN_LOT(MNBR_ITM) PICTURE '@!'
      @ MLINE+1,59 SAY 'PAK:    /  '
      @ MLINE+1,64 GET MPAK_DAY(MNBR_ITM) PICTURE '999'
      @ MLINE+1,68 GET MPAK_YR(MNBR_ITM) PICTURE '99'
      
      READ
      IF MIN_LOT(MNBR_ITM) = 'PENDING' .OR. MIN_LOT(MNBR_ITM) = 'PE' 
         *** FORMULATE AN I NUMBER HERE WITH PO NUMBER + ITEM
         MVAL_ORD = VAL(MPO_NBR)
         MVAL_SUFFIX = VAL(MPO_SUFFIX)
         *** SHIPPING INTO HOLDING INVENTORY - GENERATE AN "A" LOT NBR
         MIN_LOT(MNBR_ITM) = 'P' + SUBSTR(STR(MVAL_ORD+10000,5),2) + ;
            SUBSTR(STR(MVAL_SUFFIX+10,2),2) + ;
            SUBSTR(STR(MMMX+100,3),2) + '  '
      ENDIF      
      IF MIN_LOT(MNBR_ITM) = 'UNDET' .OR. MIN_LOT(MNBR_ITM) = 'UN' .OR. MIN_LOT(MNBR_ITM) = 'U '
         *** FORMULATE AN I NUMBER HERE WITH PO NUMBER + ITEM
         MVAL_ORD = VAL(MPO_NBR)
         MVAL_SUFFIX = VAL(MPO_SUFFIX)
         *** SHIPPING INTO HOLDING INVENTORY - GENERATE A LOT NBR
         MIN_LOT(MNBR_ITM) = 'U' + SUBSTR(STR(MVAL_ORD+10000,5),2) + ;
            SUBSTR(STR(MVAL_SUFFIX+10,2),2) + ;
            SUBSTR(STR(MMMX+100,3),2) + '  '
      ENDIF      
      @ MLINE+1,47 SAY MIN_LOT(MNBR_ITM) PICTURE '@!'
      @ MLINE+1,64 SAY MPAK_DAY(MNBR_ITM) PICTURE '999'
      @ MLINE+1,68 SAY MPAK_YR(MNBR_ITM) PICTURE '99'
      
      IF MIN_LOT(MNBR_ITM) = SPACE(10) 
         @ 24,0       
         @ 24,1 SAY 'ERROR: INVENTORY MUST HAVE LOT NUMBER --PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
      
      ***IF MADD_EDIT = 'A'
      *** IF ADDING A LOT NUMBER, - GOING INTO INVENTORY - 
      *** SEE IF ON LOT ALREAY ON FILE IN INVENTORY
      *** IF ITS ON FILE - MUST BE THE SAME PO, ITEM
      SELECT F
      DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
      SEEK B->BUY_CODE
      IF .NOT. EOF()
         MFREEZ_LOC = NAME
      ELSE
         MFREEZ_LOC = 'UNKNOWN' + SPACE(25)
      ENDIF
      USE
      
      SELECT E
      DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT", .F.
      *** FIND THE RECORD PUTTING INTO INVENTORY
      SEEK MFREEZ_LOC + MIN_LOT(MNBR_ITM) + 'I'
      
      IF .NOT. EOF()
         ** IF NOT THE SAME ITEM PUTTING INTO INVENTORY - ERROR HERE
         MXX = ((MPAGE - 1) * 7) + MNBR_ITM
         MXX = STR(MXX,2)
         IF MSALESMAN+MPO_NBR+MPO_SUFFIX+MXX <> SALESMAN+PO_NBR+PO_SUFFIX+ITEM_NBR
            @ 24,0
            @ 24,1 SAY 'ERROR: LOT NUMBER ALREADY USED - PRESS RETURN TO REENTER'
            MSPACE = ' '
            @ 24,78 GET MSPACE
            READ
            @ 24,0 
            USE
            LOOP
         ENDIF
      ELSE
         DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT", .F.
         *** FIND THE RECORD PUTTING INTO INVENTORY
         SEEK MFREEZ_LOC + MIN_LOT(MNBR_ITM) + 'I'
         IF .NOT. EOF()
            ** IF NOT THE SAME ITEM PUTTING INTO INVENTORY - ERROR HERE
            MXX = ((MPAGE - 1) * 7) + MNBR_ITM
            MXX = STR(MXX,2)
            IF MSALESMAN+MPO_NBR+MPO_SUFFIX+MXX <> SALESMAN+PO_NBR+PO_SUFFIX+ITEM_NBR
               @ 24,0
               @ 24,1 SAY 'ERROR: LOT NUMBER ALREADY USED - PRESS RETURN TO REENTER'
               MSPACE = ' '
               @ 24,78 GET MSPACE
               READ
               @ 24,0 
               USE
               LOOP
            ENDIF
         ENDIF
      ENDIF
      USE
      ****ENDIF
      
      IF MOLD_IN(MNBR_ITM) = 'P' .AND. MIN_LOT(MNBR_ITM) = 'PENDING'
         @ 24,0       
         @ 24,1 SAY 'ERROR: PREVIOUS LOT PENDING - CANNOT REENTER PENDING -PRESS RETURN TO REENTER'
         MSPACE = ' '
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
      
      **IF MOLD_IN(MNBR_ITM) = 'C' .AND. MIN_LOT(MNBR_ITM) = 'COMMIT'
      IF MOLD_IN(MNBR_ITM) = 'U' .AND. (MIN_LOT(MNBR_ITM) = 'UN' .OR. MIN_LOT(MNBR_ITM) = 'U ')
         @ 24,0       
         @ 24,1 SAY 'ERROR: PREVIOUS LOT COMMIT - CANNOT REENTER COMMIT -PRESS RETURN TO REENTER'
         MSPACE = ' '                                            
         @ 24,78 GET MSPACE
         READ
         @ 24,0 
         LOOP
      ENDIF
   ENDIF
   
   IF MQTY(MNBR_ITM) = 0
      MLBS(MNBR_ITM) = 0
   ENDIF
   
   **** NOW GET QTY FOR EVERYONE
   DO CASE
   CASE MPACKSPEC(MNBR_ITM) = 'CWT' .OR. MPACKSPEC(MNBR_ITM) = 'CBO' .OR. MPACKSPEC(MNBR_ITM) = '   '
      @ MLINE,36 GET MLBS(MNBR_ITM) PICTURE '999999.99'
      MBOX_SZ(MNBR_ITM) = 0
   CASE SUBSTR(MPACKSPEC(MNBR_ITM),1,1) = 'B' .OR. SUBSTR(MPACKSPEC(MNBR_ITM),1,1) = 'H'
      *** PRICED PER BOX
      MLBS(MNBR_ITM) = MQTY(MNBR_ITM)
      IF SUBSTR(MPACKSPEC(MNBR_ITM),1,1) = 'H'
         MLBS(MNBR_ITM) = MLBS(MNBR_ITM) * 24
      ENDIF
      @ MLINE,36 SAY MLBS(MNBR_ITM) PICTURE '999999.99'
      MBOX_SZ(MNBR_ITM) = MMULT
   OTHERWISE
      MLBS(MNBR_ITM) = MMULT * MQTY(MNBR_ITM)
      MBOX_SZ(MNBR_ITM) = MMULT
      @ MLINE,36 GET MLBS(MNBR_ITM) PICTURE '999999.99'
      *CLEAR GETS
   ENDCASE
   
   
   IF MADD_EDIT = 'A' .AND. MBBUYCODE <> 'INVN' .AND. MBBUYCODE <> 'NONE'
      **** ON AN ADD- GET THE PRICE OFF THE PRICING MASTER 
      SELECT F
      DO FOX_USE WITH "&MDBFLOC.PRI_MAST INDEX &MDBFLOC.PRI_MAST", .F.
      SEEK MBBUYCODE + MPROD(MNBR_ITM)
      IF .NOT. EOF()
         DO CASE
         CASE BEG_DT5 <> CTOD('') .AND. B->DEL_REQD >= BEG_DT5
            MSELL_PRI(MNBR_ITM) = PRICE5
         CASE BEG_DT4 <> CTOD('') .AND. B->DEL_REQD >= BEG_DT4
            MSELL_PRI(MNBR_ITM) = PRICE4
         CASE BEG_DT3 <> CTOD('') .AND. B->DEL_REQD >= BEG_DT3
            MSELL_PRI(MNBR_ITM) = PRICE3
         CASE BEG_DT2 <> CTOD('') .AND. B->DEL_REQD >= BEG_DT2
            MSELL_PRI(MNBR_ITM) = PRICE2
         OTHERWISE
            MSELL_PRI(MNBR_ITM) = PRICE1
         ENDCASE
         IF LAST_CUST = CTOD('')
            @ 24,0 CLEAR
            STORE '  ' TO MOK
            @ 24,1 SAY 'Item ' + str(mnbr_itm,1) + ' - Product Not Shipped Within Last 6 Months - Check Price -key OK ' get mok picture '@!' valid(mok = 'OK')
            READ
            @ 24,0 CLEAR
         ENDIF
      ENDIF
      
      *** CHECK FOR OFF ITEM PROMOTIONS
      SELECT F
      DO FOX_USE WITH "&MDBFLOC.CUSIOFF INDEX &MDBFLOC.CUSIOFF", .F.
      SEEK MBBUYCODE + MPROD(MNBR_ITM)
      DO WHILE .NOT. EOF() .AND. BBUYCODE = MBBUYCODE .AND. PROD_DESC = MPROD(MNBR_ITM)
         IF B->ORD_DATE >= BEG_DT .AND. B->ORD_DATE <= END_DT
            MSELL_PRI(MNBR_ITM) = MSELL_PRI(MNBR_ITM) + ITM_PROM
            GOTO BOTTOM
         ENDIF
         SKIP
      ENDDO
      
      USE
      SELECT B
   ENDIF
   
   IF MRSUPCODE = 'INVN' .AND. MOUT_LOT(MNBR_ITM) = 'U'
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      SEEK 'R' + MPROD(MNBR_ITM)  
      IF .NOT. EOF()
         MPURC_PRI(MNBR_ITM) = AVG_PURCH
      ENDIF
   ENDIF
   
   IF MBBUYCODE = 'INVN' .AND. MIN_LOT(MNBR_ITM) = 'U'
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      SEEK 'R' + MPROD(MNBR_ITM)  
      IF .NOT. EOF()
         MSELL_PRI(MNBR_ITM) = AVG_PURCH
      ENDIF
   ENDIF
   
   DO CASE
   CASE MRSUPCODE = 'INVN' .AND. MBBUYCODE = 'INVN'
      MSELL_PRI(MNBR_ITM) = MPURC_PRI(MNBR_ITM)
      @ MLINE,46 SAY MPURC_PRI(MNBR_ITM) PICTURE '99.9999'
      @ MLINE,55 SAY MSELL_PRI(MNBR_ITM) PICTURE '99.9999'
      
   CASE MRSUPCODE = 'INVN'
      MSTOR_LB = 0
      **MLOT_X = MLOT(MNBR_ITM)
      *DO CALC_OUT
      **MSTOR_ITEM(MNBR_ITM) = MSTOR_LB
      **@ MLINE,46 SAY MPURC_PRI(MNBR_ITM) + MSTOR_ITEM(MNBR_ITM) PICTURE '99.9999'
      @ MLINE,46 SAY MPURC_PRI(MNBR_ITM) PICTURE '99.9999'
      @ MLINE,55 GET MSELL_PRI(MNBR_ITM) PICTURE '99.9999'
      READ
      
   CASE MBBUYCODE = 'INVN'
      MSTOR_LB = 0
      MPACKIT = MPACKSPEC(MNBR_ITM)
      MBOXIT  = MBOX_SZ(MNBR_ITM)
      *DO CALC_IN
      **MSTOR_ITEM(MNBR_ITM) = MSTOR_LB
      @ MLINE,46 GET MPURC_PRI(MNBR_ITM) PICTURE '99.9999'
      READ
      *@ MLINE,55 SAY MPURC_PRI(MNBR_ITM) + MSTOR_ITEM(MNBR_ITM) PICTURE '99.9999'
      *MSELL_PRI(MNBR_ITM) = MPURC_PRI(MNBR_ITM)
      MSELL_PRI(MNBR_ITM) = MPURC_PRI(MNBR_ITM)
      @ MLINE,55 SAY MSELL_PRI(MNBR_ITM) PICTURE '99.9999'
      **READ
      
   OTHERWISE
      **MSTOR_ITEM(MNBR_ITM) = 0
      @ MLINE,46 GET MPURC_PRI(MNBR_ITM) PICTURE '99.9999'
      @ MLINE,55 GET MSELL_PRI(MNBR_ITM) PICTURE '99.9999'
      READ
   ENDCASE
   
   IF MLBS(MNBR_ITM) = 0                   
      @ 24,0       
      @ 24,1 SAY 'WARNING !!   NO POUNDS ENTERED - USUSALLY INCORRECT- CHECK - PRESS RETURN ' 
      MSPACE = ' '
      @ 24,78 GET MSPACE
      READ
      @ 24,0 
   ENDIF
   
   STORE 0 TO MDISP_PURC, MDISP_SELL
   
   DO CALCDISP
   
   @ MLINE,36 SAY MLBS(MNBR_ITM) PICTURE '999999.99'
   
   @ MLINE,46 SAY MPURC_PRI(MNBR_ITM) PICTURE '99.9999'
   @ MLINE,55 SAY MSELL_PRI(MNBR_ITM) PICTURE '99.9999'
   
   @ MLINE,63 SAY MDISP_PURC PICTURE '99999.99'
   @ MLINE,72 SAY MDISP_SELL PICTURE '99999.99'
   
   MDO_THIS = .F.
ENDDO
SELECT E
USE
SELECT B
RETURN


PROCEDURE REPLITM
****I = ((MPAGE - 1) * 7) + MNBR_ITM
DO CASE
   *** CASE NO PRODUCT LINE HERE
CASE MPROD(X) = SPACE(6)
   RETURN
OTHERWISE
   *** NEED TO WRITE BACK ALL THIS INFO
   SELECT C
   DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
   DO FILELOCK
   IF MAPPEND
      APPEND BLANK
      REPLACE salesman   WITH MSALESMAN
      REPLACE po_nbr     WITH MPO_NBR
      REPLACE po_suffix  WITH MPO_SUFFIX
      REPLACE item_nbr   WITH STR(I,2)  
      MADDED = .T.
   ELSE
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + STR(I,2)
      IF EOF()
         APPEND BLANK
         REPLACE salesman   WITH MSALESMAN
         REPLACE po_nbr     WITH MPO_NBR
         REPLACE po_suffix  WITH MPO_SUFFIX
         REPLACE item_nbr   WITH STR(I,2)  
         MADDED = .T.
      ELSE
         MADDED = .F.
      ENDIF
   ENDIF
   REPLACE QTY         WITH MQTY(X)
   REPLACE FRH_FRZ     WITH MFR_FZ(X)    
   REPLACE PACKAGED    WITH MPAK1(X)+MPAK2(X)
   REPLACE PROD_DESC   WITH MPROD(X)     
   REPLACE PACKED      WITH MPACKSPEC(X) 
   REPLACE LBS         WITH MLBS(X)
   REPLACE GRADE       WITH MGRADE(X)
   REPLACE SIZE        WITH MSIZE(X)
   REPLACE PUR_PRICE   WITH MPURC_PRI(X) 
   REPLACE SEL_PRICE   WITH MSELL_PRI(X)
   REPLACE TOT_PURCH   WITH MPURC_TOT(X)
   REPLACE TOT_SELL    WITH MSELL_TOT(X)
   UNLOCK
   
   IF MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
      
      DO RECLOCK
      *** SAVE THIS LOT BACK TO PO_DTL RECORD
      REPLACE IN_LOT     WITH MIN_LOT(X)
      REPLACE OUT_LOT    WITH MOUT_LOT(X)
      REPLACE PAK_YR     WITH MPAK_YR(X)
      REPLACE PAK_DAY    WITH MPAK_DAY(X)
      UNLOCK
      
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      SEEK 'S' + MPACKSPEC(X)
      STORE BOX_SZ TO MMULT, MBOX_SZ(X)
      SEEK 'R' + MPROD(X)
      MPROD_CAT = PROD_CAT
      USE 
      SELECT C 
      *REPLACE BOX_SZ      WITH MBOX_SZ(X)
      *REPLACE PROD_CAT    WITH MPROD_CAT
      
      IF B->BBUYCODE = 'INVN'
         *** GOING INTO INVENTORY
         IF MIN_LOT(X) = 'PENDING' .OR. MIN_LOT(X) = 'PE' 
            *** FORMULATE AN I NUMBER HERE WITH PO NUMBER + ITEM
            MVAL_ORD = VAL(MPO_NBR)
            MVAL_SUFFIX = VAL(MPO_SUFFIX)
            *** SHIPPING INTO HOLDING INVENTORY - GENERATE AN "A" LOT NBR
            MIN_LOT(X) = 'P' + SUBSTR(STR(MVAL_ORD+10000,5),2) + ;
               SUBSTR(STR(MVAL_SUFFIX+10,2),2) + ;
               SUBSTR(STR(X+100,3),2) + '  '
            SELECT C
            DO RECLOCK
            *** SAVE THIS LOT BACK TO PO_DTL RECORD
            REPLACE IN_LOT     WITH MIN_LOT(X)
            REPLACE PAK_YR     WITH MPAK_YR(X)
            REPLACE PAK_DAY    WITH MPAK_DAY(X)
            UNLOCK
         ENDIF
         
         IF MIN_LOT(X) = 'UNDET' .OR. MIN_LOT(X) = 'UN' .OR. MIN_LOT(X) = 'U '
            *** FORMULATE AN I NUMBER HERE WITH PO NUMBER + ITEM
            MVAL_ORD = VAL(MPO_NBR)
            MVAL_SUFFIX = VAL(MPO_SUFFIX)
            *** SHIPPING INTO HOLDING INVENTORY - GENERATE AN "A" LOT NBR
            MIN_LOT(X) = 'U' + SUBSTR(STR(MVAL_ORD+10000,5),2) + ;
               SUBSTR(STR(MVAL_SUFFIX+10,2),2) + ;
               SUBSTR(STR(X+100,3),2) + '  '
            SELECT C
            DO RECLOCK
            *** SAVE THIS LOT BACK TO PO_DTL RECORD
            REPLACE IN_LOT     WITH MIN_LOT(X)
            REPLACE PAK_YR     WITH MPAK_YR(X)
            REPLACE PAK_DAY    WITH MPAK_DAY(X)
            UNLOCK
         ENDIF
         
         SELECT F
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         SEEK B->BUY_CODE
         IF .NOT. EOF()
            MFREEZ_LOC = NAME
         ELSE
            MFREEZ_LOC = 'UNKNOWN' + SPACE(25)
         ENDIF
         USE
         
         MLBS_CALC = MLBS(X)
         
         *** GOING INTO INVENTORY
         SELECT F
         DO FOX_USE WITH "HINVEN INDEX HINVNLOC, HINVSOLD", .F.
         
         DO FILELOCK
         IF MOLD_IN(X) <> SPACE(10) .AND. MOLD_IN(X) <> MIN_LOT(X)
            SEEK MFREEZ_LOC + MOLD_IN(X)
            IF .NOT. EOF()
               REPLACE LOT_NBR WITH MIN_LOT(X)
               REPLACE PAK_YR  WITH MPAK_YR(X)
               REPLACE PAK_DAY WITH MPAK_DAY(X)
            ENDIF
         ENDIF
         SEEK MFREEZ_LOC + MIN_LOT(X)
         IF EOF()
            APPEND BLANK
            REPLACE SALESMAN    WITH MSALESMAN
            REPLACE PO_NBR      WITH MPO_NBR
            REPLACE PO_SUFFIX   WITH MPO_SUFFIX
            REPLACE FREEZ_LOC   WITH MFREEZ_LOC
            REPLACE LOT_NBR     WITH MIN_LOT(X)
            MI_NBR = 0
         ELSE
            MI_NBR = I_NBR
         ENDIF
         SELECT F
         REPLACE SHIP_DATE   WITH MSHIP_DATE
         REPLACE ANIV_DATE   WITH MDEL_REQD
         REPLACE RSUPCODE    WITH MRSUPCODE
         REPLACE LBS         WITH MLBS(X)
         REPLACE CASE_CNT    WITH MQTY(X)
         REPLACE FRH_FRZ     WITH MFR_FZ(X)
         REPLACE PROD_DESC   WITH MPROD(X)     
         *REPLACE PROD_CAT    WITH MPROD_CAT
         REPLACE PACKED      WITH MPACKSPEC(X) 
         REPLACE PACKAGED    WITH MPAK1(X) + MPAK2(X)
         REPLACE BOX_SZ      WITH MBOX_SZ(X)
         REPLACE PRI_LB      WITH MSELL_PRI(X)
         **REPLACE STOR_LB     WITH MSTOR_ITEM(X)
         REPLACE SIZE        WITH MSIZE(X)
         REPLACE GRADE       WITH MGRADE(X)
         REPLACE PAK_YR      WITH MPAK_YR(X)
         REPLACE PAK_DAY     WITH MPAK_DAY(X)
         IF B->BUYER_PO = 'HOLD Q'
            REPLACE NOTE WITH SUBSTR(B->BUYER_PO,1,7)
         ENDIF
         
         MCAT = '  '
         
         *** REPLACE FIELDS FOR THE OLD INVENTORY SYSTEM
         REPLACE DIV_CODE    WITH '11'
         REPLACE BROK_NAME   WITH B->BROK_NAME
         REPLACE VALUE       WITH MSELL_TOT(X)
         REPLACE PRO_PRI     WITH MSELL_PRI(X)
         REPLACE BOX_SIZE    WITH STR(MBOX_SZ(X),5,1)
         REPLACE PROD_SIZE   WITH MSIZE(X)
         *** END OF OLD INVENTORY FIELDS
         
         *** SEE IF THERE IS A DETAIL RECORD ON FILE
         SELECT E
         DO FOX_USE WITH "HINV_DTL INDEX HINV_DTL, HDTL_LOT", .F.
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + STR(I,2) + 'I'
         DO FILELOCK
         IF EOF()
            APPEND BLANK
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE ITEM_NBR WITH STR(I,2)
            REPLACE ACT_CODE WITH 'I'
         ENDIF
         REPLACE LOT_NBR WITH MIN_LOT(X)
         REPLACE FREEZ_LOC WITH MFREEZ_LOC
         REPLACE QTY WITH MQTY(X)
         REPLACE LBS WITH MLBS(X)
         REPLACE ACTIVITY WITH 'IN '
         REPLACE ACT_DATE WITH B->DEL_REQD 
         *** REPLACE FOR OLD INVENTORY FIELDS
         REPLACE I_NBR WITH MI_NBR
         REPLACE SYS_DATE WITH DATE()
         *** END OF OLD FIELDS
         UNLOCK
         *** NEW STUFF HERE 8/9/2002
         **** NOW SEE IF OLD LOT IN <> NEW LOT IN
         *** THEN UPDATE ORDERS COMING OUT OF INVENTORY
         IF MOLD_IN(X) <> SPACE(10) .AND. MOLD_IN(X) <> MIN_LOT(X)
            SELECT E
            DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT, HINV_DTL", .F.
            SEEK MFREEZ_LOC + MOLD_IN(X) + 'S'
            
            DO WHILE .NOT. EOF()
               IF .NOT. EOF()
                  DO RECLOCK
                  REPLACE LOT_NBR WITH MIN_LOT(X)
                  UNLOCK
                  
                  SELECT C
                  STORE RECNO() TO MRECNO
                  SEEK E->SALESMAN + E->PO_NBR + E->PO_SUFFIX + E->ITEM_NBR
                  IF .NOT. EOF()
                     DO RECLOCK
                     REPLACE OUT_LOT WITH MIN_LOT(X)
                     UNLOCK
                  ENDIF
                  GOTO MRECNO               
               ENDIF
               SELECT E
               SEEK MFREEZ_LOC + MOLD_IN(X) + 'S'
            ENDDO
         ENDIF
         
         *****************
         **** FIX THIS UP
         *****************
         MDO = .F.
         IF MDO
            *** CALCULATE WHAT'S LEFT USING CURRENT LOT_NBR
            MX = 0
            MY = 0
            MLBS_COM = 0
            MCASE_COM = 0
            MLBS_SOLD = 0
            MCASE_SOLD = 0
            SELECT E
            DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT, INVN_DTL, DTL_DATE, IDTL_DTL, INVN_PO, INVNDISP", .F.
            SEEK MFREEZ_LOC + MIN_LOT(X)
            DO WHILE .NOT. EOF() .AND. LOT_NBR = MIN_LOT(X) .AND. FREEZ_LOC = MFREEZ_LOC
               IF ACTIVITY = 'COM'
                  MLBS_COM = MLBS_COM + (LBS * -1)
                  MCASE_COM = MCASE_COM + (QTY * -1)
                  SKIP
                  LOOP
               ENDIF
               MX = MX + QTY
               MY = MY + LBS
               IF ACTIVITY = 'OUT'
                  MLBS_SOLD = MLBS_SOLD + (LBS * -1)
                  MCASE_SOLD= MCASE_SOLD + (QTY * -1)
               ENDIF
               SKIP
            ENDDO
            
            SELECT F
            REPLACE LBS_SOLD    WITH MLBS_SOLD
            REPLACE CASE_SOLD   WITH MCASE_SOLD
            **REPLACE LBS_LEFT    WITH MY              
            **REPLACE CASE_LEFT   WITH MX                     
            REPLACE LBS_LEFT    WITH LBS - LBS_SOLD
            REPLACE CASE_LEFT   WITH CASE_CNT - CASE_SOLD
            REPLACE LBS_COM     WITH MLBS_COM
            REPLACE CASE_COM    WITH MCASE_COM
            
            MVAL1 = LBS_LEFT * PRI_LB
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
            
            MVAL_LEFT = MVAL1          
            REPLACE VAL_LEFT WITH MVAL_LEFT
            
            IF CASE_LEFT <= 0
               REPLACE SOLD_FLG WITH 'Y'
               REPLACE VAL_LEFT WITH 0
               DELETE
            ELSE
               REPLACE SOLD_FLG WITH ' '
            ENDIF
            
            
            *****************
            **** FIX THIS UP
            *****************
            *** CALCULATE WHAT'S LEFT USING OLD IN LOT NBR
            MX = 0
            MY = 0
            MLBS_COM = 0
            MCASE_COM = 0
            MLBS_SOLD = 0
            MCASE_SOLD = 0
            SELECT E
            SEEK MFREEZ_LOC + MOLD_IN(X)
            DO WHILE .NOT. EOF() .AND. LOT_NBR = MOLD_IN(X) .AND. FREEZ_LOC = MFREEZ_LOC
               IF ACTIVITY = 'COM'
                  MLBS_COM = MLBS_COM + (LBS * -1)
                  MCASE_COM = MCASE_COM + (QTY * -1)
                  SKIP
                  LOOP
               ENDIF
               MX = MX + QTY
               MY = MY + LBS
               IF ACTIVITY = 'OUT'
                  MLBS_SOLD = MLBS_SOLD + (LBS * -1)
                  MCASE_SOLD= MCASE_SOLD + (QTY * -1)
               ENDIF
               SKIP
            ENDDO
            
            USE
            SELECT F
            REPLACE LBS_SOLD    WITH MLBS_SOLD
            REPLACE CASE_SOLD   WITH MCASE_SOLD
            *REPLACE LBS_LEFT    WITH MY              
            *REPLACE CASE_LEFT   WITH MX                     
            REPLACE LBS_LEFT    WITH LBS - LBS_SOLD
            REPLACE CASE_LEFT   WITH CASE_CNT - CASE_SOLD
            REPLACE LBS_COM     WITH MLBS_COM
            REPLACE CASE_COM    WITH MCASE_COM
            
            MVAL1 = LBS_LEFT * PRI_LB
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
            
            MVAL_LEFT = MVAL1          
            REPLACE VAL_LEFT WITH MVAL_LEFT
            
            IF CASE_LEFT <= 0
               REPLACE SOLD_FLG WITH 'Y'
               REPLACE VAL_LEFT WITH 0
               DELETE
            ELSE
               REPLACE SOLD_FLG WITH ' '
            ENDIF
            UNLOCK
         ENDIF
      ENDIF
      
      
      **** END OF PROCESSING GOING INTO INVENTORY
      
      *******************************************
      *** SELLING OUT OF INVENTORY
      *******************************************
      IF B->RSUPCODE = 'INVN'
         SELECT F
         DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
         SEEK B->SUP_CODE
         IF .NOT. EOF()
            MFREEZ_LOC = NAME
         ELSE
            MFREEZ_LOC = 'UNKNOWN' + SPACE(25)
         ENDIF
         USE
         
         *** FOR THE OLD SYSTEM ***
         MI_NBR = 0
         *** END OF OLD SYSTEM NEEDS
         
         *** NEW HERE MAY 2014
         SELECT F
         DO FOX_USE WITH "HINVEN INDEX HINVNLOC, HINVSOLD", .F.
         
         IF MOUT_LOT(X) = 'U'
            SEEK MFREEZ_LOC + MOUT_LOT(X)
            IF .NOT. EOF()
               DO RECLOCK
               REPLACE PAK_YR  WITH MPAK_YR(X)
               REPLACE PAK_DAY WITH MPAK_DAY(X)
               MI_NBR = I_NBR
               UNLOCK
            ELSE
               DO FILELOCK
               APPEND BLANK
               REPLACE SALESMAN    WITH MSALESMAN
               REPLACE PO_NBR      WITH MPO_NBR
               REPLACE PO_SUFFIX   WITH MPO_SUFFIX
               REPLACE FREEZ_LOC   WITH MFREEZ_LOC
               REPLACE LOT_NBR     WITH MOUT_LOT(X)
               MI_NBR = 0
               UNLOCK
            ENDIF
            DO RECLOCK
            REPLACE SHIP_DATE   WITH MSHIP_DATE
            REPLACE ANIV_DATE   WITH MDEL_REQD
            REPLACE RSUPCODE    WITH MRSUPCODE
            
            **NOTHING GOING IN - FOR UNDETERMINED
            *REPLACE LBS         WITH MLBS(X)
            *REPLACE CASE_CNT    WITH MQTY(X)
            
            REPLACE FRH_FRZ     WITH MFR_FZ(X)
            REPLACE PROD_DESC   WITH MPROD(X)     
            *REPLACE PROD_CAT    WITH MPROD_CAT
            REPLACE PACKED      WITH MPACKSPEC(X) 
            REPLACE PACKAGED    WITH MPAK1(X) + MPAK2(X)
            REPLACE BOX_SZ      WITH MBOX_SZ(X)
            REPLACE PRI_LB      WITH MSELL_PRI(X)
            REPLACE SIZE        WITH MSIZE(X)
            REPLACE GRADE       WITH MGRADE(X)
            REPLACE PAK_YR      WITH MPAK_YR(X)
            REPLACE PAK_DAY     WITH MPAK_DAY(X)
            IF B->BUYER_PO = 'HOLD Q'
               REPLACE NOTE WITH SUBSTR(B->BUYER_PO,1,7)
            ENDIF
            MCAT = '  '
            
            *** REPLACE FIELDS FOR THE OLD INVENTORY SYSTEM
            REPLACE DIV_CODE    WITH '11'
            REPLACE BROK_NAME   WITH B->BROK_NAME
            REPLACE VALUE       WITH MSELL_TOT(X)
            REPLACE PRO_PRI     WITH MSELL_PRI(X)
            REPLACE BOX_SIZE    WITH STR(MBOX_SZ(X),5,1)
            REPLACE PROD_SIZE   WITH MSIZE(X)
            *** END OF OLD INVENTORY FIELDS
            UNLOCK
         ENDIF
         **** END OF NEW HERE
         
         
         
         SELECT E
         DO FOX_USE WITH "HINV_DTL INDEX HINV_DTL, HDTL_LOT", .F.
         DO FILELOCK
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + STR(I,2) + 'S'
         IF EOF()
            APPEND BLANK
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE ITEM_NBR WITH STR(I,2)
            REPLACE I_NBR WITH MI_NBR
            REPLACE ACT_CODE WITH 'S'
         ENDIF
         
         REPLACE LOT_NBR WITH MOUT_LOT(X)
         REPLACE FREEZ_LOC WITH MFREEZ_LOC
         REPLACE QTY WITH MQTY(X) * -1
         REPLACE LBS WITH MLBS(X) * -1
         REPLACE ACTIVITY WITH 'OUT'
         REPLACE ACT_DATE WITH B->SHIP_DATE
         **********************************************
         *** NOW UPDATE FIELDS FOR OLD INVENTORY SYSTEM
         REPLACE SYS_DATE WITH DATE()
         REPLACE SHIP_LBS  WITH MLBS(X)
         REPLACE SHIP_CASE WITH MQTY(X)
         REPLACE SHIP_VAL  WITH MPURC_TOT(X)
         REPLACE SHIP_PRI  WITH MPURC_PRI(X)
         REPLACE BBUYCODE  WITH B->BBUYCODE
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         SEEK B->BUY_CODE
         MNAME = NAME   
         USE
         SELECT E
         REPLACE SHIP_NAME WITH MNAME
         **** END OF UPDATES FOR OLD SYSTEM
         **********************************************
         
         UNLOCK
         MDO = .F.
         IF MDO
            ****************
            **** FIX THIS UP
            ****************
            *** CALCULATE WHAT'S LEFT USING LOT_NBR FOR CURRENT LOT
            MX = 0
            MY = 0
            MLBS_SOLD = 0
            MCASE_SOLD = 0
            MLBS_COM   = 0
            MCASE_COM  = 0
            DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT, INVN_DTL, DTL_DATE, IDTL_DTL, INVN_PO, INVNDISP", .F.
            SEEK MFREEZ_LOC + MOUT_LOT(X)
            DO WHILE .NOT. EOF() .AND. LOT_NBR = MOUT_LOT(X) .AND. FREEZ_LOC = MFREEZ_LOC
               IF ACTIVITY = 'COM'
                  MLBS_COM = MLBS_COM + (LBS * -1)
                  MCASE_COM = MCASE_COM + (QTY * -1)
                  SKIP
                  LOOP
               ENDIF
               MX = MX + QTY
               MY = MY + LBS
               IF ACTIVITY = 'OUT'
                  MLBS_SOLD = MLBS_SOLD + (LBS * -1)
                  MCASE_SOLD= MCASE_SOLD + (QTY * -1)
               ENDIF
               SKIP
            ENDDO
            USE
            SELECT F
            DO FOX_USE WITH "INVEN INDEX INVNLOC, INVNSOLD, INVNINBR, INVNLOT, INVNPO, INVNANIV, INVNCAT", .F.
            DO FILELOCK
            SEEK MFREEZ_LOC + MOUT_LOT(X)
            IF .NOT. EOF()
               REPLACE LBS_SOLD    WITH MLBS_SOLD
               REPLACE CASE_SOLD   WITH MCASE_SOLD
               *REPLACE LBS_LEFT    WITH MY              
               *REPLACE CASE_LEFT   WITH MX                     
               REPLACE LBS_LEFT    WITH LBS - LBS_SOLD
               REPLACE CASE_LEFT   WITH CASE_CNT - CASE_SOLD
               REPLACE LBS_COM     WITH MLBS_COM
               REPLACE CASE_COM    WITH MCASE_COM
               
               MVAL1 = LBS_LEFT * PRI_LB
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
               
               MVAL_LEFT = MVAL1          
               REPLACE VAL_LEFT WITH MVAL_LEFT
               
               IF CASE_LEFT <= 0
                  REPLACE SOLD_FLG WITH 'Y'
                  REPLACE VAL_LEFT WITH 0
                  DELETE
               ELSE
                  REPLACE SOLD_FLG WITH ' '
               ENDIF
            ENDIF
            UNLOCK
            
            ****************
            **** FIX THIS UP
            ****************
            
            *** CALCULATE WHAT'S LEFT USING LOT_NBR FOR OLD LOT
            MX = 0
            MY = 0
            MLBS_SOLD = 0
            MCASE_SOLD = 0
            MLBS_COM   = 0
            MCASE_COM  = 0
            SELECT E
            DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT, INVN_DTL, DTL_DATE, IDTL_DTL, INVN_PO, INVNDISP", .F.
            SEEK MFREEZ_LOC + MOLD_OUT(X)
            DO WHILE .NOT. EOF() .AND. LOT_NBR = MOLD_OUT(X) .AND. FREEZ_LOC = MFREEZ_LOC
               IF ACTIVITY = 'COM'
                  MLBS_COM = MLBS_COM + (LBS * -1)
                  MCASE_COM = MCASE_COM + (QTY * -1)
                  SKIP
                  LOOP
               ENDIF
               MX = MX + QTY
               MY = MY + LBS
               IF ACTIVITY = 'OUT'
                  MLBS_SOLD = MLBS_SOLD + (LBS * -1)
                  MCASE_SOLD= MCASE_SOLD + (QTY * -1)
               ENDIF
               SKIP
            ENDDO
            USE
            
            SELECT F
            DO FOX_USE WITH "INVEN INDEX INVNLOC, INVNSOLD, INVNINBR, INVNLOT, INVNPO, INVNANIV, INVNCAT", .F.
            DO FILELOCK
            SEEK MFREEZ_LOC + MOLD_OUT(X)
            IF .NOT. EOF()
               REPLACE LBS_SOLD    WITH MLBS_SOLD
               REPLACE CASE_SOLD   WITH MCASE_SOLD
               **REPLACE LBS_LEFT    WITH MY              
               **REPLACE CASE_LEFT   WITH MX                     
               REPLACE LBS_LEFT    WITH LBS - LBS_SOLD
               REPLACE CASE_LEFT   WITH CASE_CNT - CASE_SOLD
               REPLACE LBS_COM     WITH MLBS_COM
               REPLACE CASE_COM    WITH MCASE_COM
               
               MVAL1 = LBS_LEFT * PRI_LB
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
               
               MVAL_LEFT = MVAL1          
               REPLACE VAL_LEFT WITH MVAL_LEFT
               
               IF CASE_LEFT <= 0
                  REPLACE SOLD_FLG WITH 'Y'
                  REPLACE VAL_LEFT WITH 0
                  DELETE
               ELSE
                  REPLACE SOLD_FLG WITH ' '
               ENDIF
            ENDIF
            UNLOCK
            *** END OF PROCESSING COMING OUT OF INVENTORY
         ENDIF
      ENDIF
   ENDIF
ENDCASE

SELECT F
UNLOCK
USE
SELECT E
UNLOCK
USE
SELECT C
UNLOCK
FLUSH
SELECT B 
RETURN






PROCEDURE REPLHIST     
SELECT D
USE HIST_DTL INDEX HIST_DTL
MADDED = .F.
SELECT C
IF .NOT. MAPPEND
   SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + STR(I,2)
   IF .NOT. EOF()
      SELECT D
      DO FILELOCK
      APPEND BLANK
      REPLACE salesman   WITH MSALESMAN
      REPLACE po_nbr     WITH MPO_NBR
      REPLACE po_suffix  WITH MPO_SUFFIX
      REPLACE item_nbr   WITH STR(I,2)  
      REPLACE qty         WITH C->QTY  
      REPLACE frh_frz     WITH C->FRH_FRZ       
      REPLACE grade       WITH C->GRADE       
      REPLACE packaged    WITH C->PACKAGED 
      REPLACE product     WITH C->PRODUCT  
      REPLACE prod_desc   WITH C->PROD_DESC  
      REPLACE size        WITH C->SIZE       
      REPLACE packed      WITH C->PACKED   
      REPLACE lbs         WITH C->LBS   
      REPLACE pur_price   WITH C->PUR_PRICE  
      REPLACE sel_price   WITH C->SEL_PRICE 
      REPLACE tot_purch   WITH C->TOT_PURCH
      REPLACE tot_sell    WITH C->TOT_SELL    
      REPLACE REAS_CODE   WITH MREAS_CODE
      REPLACE REAS_DESC   WITH MREAS_DESC
      REPLACE HIST_DATE   WITH DATE()
      REPLACE HIST_TIME   WITH TIME()
      REPLACE INV_FLG     WITH C->INV_FLG
      REPLACE INV_NBR     WITH C->INV_NBR
      REPLACE SHTSUPAMT   WITH MPURC_TOT(X) - MORIG_PURC
      REPLACE SHTCUSAMT   WITH MSELL_TOT(X) - MORIG_SELL
      REPLACE SHORT_LBS   WITH MLBS(X) - MORIG_LBS
      *** REPLACE USERID  WITH MUSERID
      FLUSH
      UNLOCK
   ENDIF
ENDIF
RETURN

PROCEDURE STORITM
**MNBR_ITM = VAL(ITEM_NBR) - ((MPAGE-1) * 7)
STORE QTY         TO MQTY(MNBR_ITM), MOLD_QTY(MNBR_ITM)
STORE FRH_FRZ     TO MFR_FZ(MNBR_ITM)    
STORE GRADE       TO MGRADE(MNBR_ITM)    
STORE SUBSTR(PACKAGED,1,1) TO MPAK1(MNBR_ITM)      
STORE SUBSTR(PACKAGED,2,1) TO MPAK2(MNBR_ITM)
STORE SUBSTR(PROD_DESC,1,6)   TO MPROD(MNBR_ITM), MOLD_PROD(MNBR_ITM)
STORE SIZE        TO MSIZE(MNBR_ITM)      
STORE PACKED      TO MPACKSPEC(MNBR_ITM) 
STORE LBS         TO MLBS(MNBR_ITM), MOLD_LBS(MNBR_ITM)
STORE PUR_PRICE   TO MPURC_PRI(MNBR_ITM) 
STORE SEL_PRICE   TO MSELL_PRI(MNBR_ITM)
STORE TOT_PURCH   TO MPURC_TOT(MNBR_ITM)
STORE TOT_SELL    TO MSELL_TOT(MNBR_ITM)
STORE PAK_YR      TO MPAK_YR(MNBR_ITM), MOUT_YR(MNBR_ITM)
STORE PAK_DAY     TO MPAK_DAY(MNBR_ITM), MOUT_DAY(MNBR_ITM)
*STORE STOR_LB     TO MSTOR_ITEM(MNBR_ITM)
STORE OUT_LOT     TO MOUT_LOT(MNBR_ITM), MOLD_OUT(MNBR_ITM)
STORE IN_LOT      TO MIN_LOT(MNBR_ITM), MOLD_IN(MNBR_ITM)

IF MOUT_LOT(MNBR_ITM) <> SPACE(10)
   IF SUBSTR(MOUT_LOT(MNBR_ITM),1,1) <> 'U'
      ** GET THE OUT LOT JUL PAK DATE TO DISPLAY
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
      SEEK B->SUP_CODE
      IF EOF()
         MFREEZ_LOC = 'UNKNOWN' + SPACE(25)
      ELSE
         MFREEZ_LOC = NAME
      ENDIF
      DO FOX_USE WITH "INVEN INDEX INVNLOC, INVNSOLD, INVNINBR, INVNLOT, INVNPO, INVNANIV, INVNCAT", .F.
      SEEK MFREEZ_LOC + MOUT_LOT(MNBR_ITM)
      IF EOF()
         DO FOX_USE WITH "HINVEN INDEX HINVNLOC, HINVSOLD", .F.
         SEEK MFREEZ_LOC + MOUT_LOT(MNBR_ITM)
         IF .NOT. EOF()
            MOUT_DAY(MNBR_ITM) = PAK_DAY
            MOUT_YR(MNBR_ITM)  = PAK_YR
         ENDIF
      ELSE
         MOUT_DAY(MNBR_ITM) = PAK_DAY
         MOUT_YR(MNBR_ITM)  = PAK_YR
      ENDIF
      SELECT E
      USE
   ENDIF
ENDIF
** PO DTL FILE
SELECT C
RETURN


PROCEDURE TRANPO   
MSALESMAN   = SALESMAN 
MPO_NBR     = PO_NBR  
MPO_SUFFIX  = PO_SUFFIX
MDEL_REQD   = DEL_REQD         
MORD_DATE   = ORD_DATE         
MBUYER_PO   = BUYER_PO   
MSHIP_DATE  = SHIP_DATE        
MTOT_LBS    = 0
MTOT_PURCH  = 0
MTOT_SELL   = 0
MFRT_CODE1  = SPACE(4)
MFRT_CODE2  = SPACE(4)
MFRT_CODE3  = SPACE(4)
MFRT_AMT1   = FRT_AMT1
MCOM_CODE   = SPACE(2)
MCOMM_CENT  = 0
MCOMM_AMT   = 0
MCOM_CODE2  = SPACE(2)
MCOM_CODE3  = SPACE(2)
MCOMM_CEN2  = 0
MCOMM_CEN3  = 0
MCOMM_AMT2  = 0
MCOMM_AMT3  = 0
MSALE_COMM  = 0
MZERO_COMM  = SPACE(1)
MSALE_CENT  = 0
MINV_FLG    = SPACE(1)
MINV_NBR    = SPACE(5)
MINV_DATE   = CTOD('  /  /  ')
STORE 0 TO MCOMM_ADJ
STORE SPACE(5) TO MBROK_NAME
STORE SPACE(2) TO MSAL_CODE2, MSAL_CODE3
STORE SPACE(25) TO MPU_LOC
STORE 0 TO MCOMM_ENT, MSALE2_AMT, MSALE2_ENT, MSALE2_CEN, MSALE_ENT
STORE 0 TO MSALE3_AMT, MSALE3_ENT, MSALE3_CEN
MFRT1_ADJ1 = FRT1_ADJ1
MFRT1_ADJ2 = FRT1_ADJ2
STORE 0 TO MTOT_NET, MSALE2_NET
MFRT1_RS1 = FRT1_RS1
MFRT1_RS2 = FRT1_RS2
IF MCOMPANY = 'DIVISION 15'
   MBROKERAGE = HOLD_STOR        
ELSE
   STORE SPACE(1) TO MBROKERAGE
ENDIF
STORE SPACE(1) TO MFRT2_FLG  
MFRT_CODE2 = SPACE(4)
MFRT_AMT2  = 0
STORE SPACE(1) TO MFRT3_FLG  
MFRT_CODE3 = SPACE(4)
MFRT_AMT3  = 0
RETURN



PROCEDURE CALCDISP
**** CALCULATE TOTAL PURCHASE

MVAL1 = MLBS(MNBR_ITM) * MPURC_PRI(MNBR_ITM) 

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

MPURC_TOT(MNBR_ITM) = MVAL1          

IF MRSUPCODE = 'INVN'
   MVAL1 = 0
   **MVAL1 = MLBS(MNBR_ITM) *  MSTOR_ITEM(MNBR_ITM)
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
   MDISP_PURC = MPURC_TOT(MNBR_ITM) + MVAL1
ELSE
   MDISP_PURC = MPURC_TOT(MNBR_ITM)
ENDIF

******************************************************************************
*** BOUGHT BY THE POUND, SOLD BY THE CASE
*** IF CUSTOMER = 'ASSOCIATED WHOLESALE GROCERS, INC'
*** AND PRODUCT = '47184' = BAKED MRB 8 PIECE - 96 COUNT
*** NEW AS OF 05/16/2006  - BOUGHT BY LB BUT SOLD BY QTY(CASE)
*** 8/22/2007 - 36089 8 pc fried
*** MEIJER BOT BY LB, SOLD BY LB - BUT ALWAYS ASSUME A 32 LB CASE WT ON
*** MEIJER PRODUCTS 51160 AND. 51221
*** EK BEVERAGE COMPANY - ALSO BUY 51160 AND 51221 AS OF 02/17/2008

DO CASE
CASE B->BBUYCODE = ' 189'.AND. MPROD(MNBR_ITM) = '47184'
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
   **226 = NASH FINCH CUSTOMER
   **AS OF 08/14/2007 36429 = 11/15/2007
CASE B->BBUYCODE = ' 226'.AND. MPROD(MNBR_ITM) = '47184' 
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
   
   *** AS OF 12/12/2008  - IDEAL FOOD PRODUCTS
CASE B->BBUYCODE = ' 256'.AND. MPROD(MNBR_ITM) = '51221'
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
   
   *** AS OF 11/1/2008  - FORTH'S FOODS, INC
CASE B->BBUYCODE = ' 263'.AND. MPROD(MNBR_ITM) = '36089'
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
CASE B->BBUYCODE = ' 263'.AND. MPROD(MNBR_ITM) = '36429'
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
CASE B->BBUYCODE = ' 263'.AND. MPROD(MNBR_ITM) = '36679'
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
   
   *** AS OF 11/1/2009  - UNIFIED WESTERN GROCERS-STOCKTON  = (268)
   *** AS OF 12/15/2009  - UNIFIED WESTERN GROCERS-OREGON (225) AND WA (233)
CASE (B->BBUYCODE = ' 268' .OR. B->BBUYCODE = ' 225' .OR. B->BBUYCODE = ' 233') .AND. MPROD(MNBR_ITM) = '36089'
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
   
   **AS OF 08/22/2007
CASE B->BBUYCODE = ' 226'.AND. MPROD(MNBR_ITM) = '36089'
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
CASE B->BBUYCODE = ' 226'.AND. MPROD(MNBR_ITM) = '36429'
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
   
CASE B->BBUYCODE = ' 227'.AND. MPROD(MNBR_ITM) = '36679'
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
CASE B->BBUYCODE = ' 227'.AND. MPROD(MNBR_ITM) = '36089'
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
CASE B->BBUYCODE = '  96'.AND. (MPROD(MNBR_ITM) = '65521' .OR. MPROD(MNBR_ITM) = '65543')
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
   
   ** MEIJER BOT BY CWT LB, SOLD BY LB - BUT AN EVEN 32 LB CASE
   ** MEIJER CHANGED - BUY BY THE CASE - NOT EVEN WT BOX
CASE (B->BBUYCODE = ' 244' .OR. B->BBUYCODE = ' 231'.OR. B->BBUYCODE = '  84' .OR. B->BBUYCODE = ' 189') .AND. (MPROD(MNBR_ITM) = '51160' .OR. MPROD(MNBR_ITM) = '51221')
   MVAL1 = MQTY(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
   **MVAL1 = (MQTY(MNBR_ITM) * 32) * MSELL_PRI(MNBR_ITM)
OTHERWISE
   MVAL1 = MLBS(MNBR_ITM) * MSELL_PRI(MNBR_ITM)
ENDCASE

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

MSELL_TOT(MNBR_ITM) = MVAL1            

*******************************************************
IF MBBUYCODE = 'INVN'
   MVAL1 = 0
   **MVAL1 = MLBS(MNBR_ITM) * MSTOR_ITEM(MNBR_ITM)
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
   MDISP_SELL = MSELL_TOT(MNBR_ITM) + MVAL1
ELSE
   MDISP_SELL = MSELL_TOT(MNBR_ITM)
ENDIF

RETURN


*Formatted by: ToolBox Ver. 1.2  on 2/25/19 at 8:31 AM.
