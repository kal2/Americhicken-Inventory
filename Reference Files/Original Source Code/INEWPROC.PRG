*********************** 
***FILE NAME: INEWPROC.PRG
*  BY: 
*  DATE: July 10,1991      
*  DESC:
*  CALLED BY:
*  DATA FILES:
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

* ---MAIN PROCESSING LOOP

SET PROCEDURE TO INEWPROC

STORE ' ' TO MSELECTION
DO WHILE MSELECTION <> '9'
   CLOSE DATA
   CLEAR
   @ 00,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 01,00 SAY MPROGRAM + ' - MAIN MENU'
   @ 2,0 to 25,79
   
   @ 04,10 SAY '1 - VIEW/CHANGE LOT/COST/SHIPMENT INFORMATION'
   @ 06,10 SAY '2 - REPORTS'
   @ 08,10 SAY '3 - FILE MAINTENANCE'
   @ 10,10 SAY '4 - PRINT LOT ACTIVITY/HISTORY'
   @ 22,10 SAY '9 - EXIT'
   
   STORE '1' TO MSELECTION
   @ 24,02 SAY 'CHOICE: '
   @ 24,10 GET MSELECTION PICTURE '9'
   READ
   **CLEAR GETS
   **@ 24,09 SAY ' '
   **MSELECTION = INKEY(60)
   **IF MSELECTION = 0
   **   SET COLOR TO W/N
   **   CLEAR
   **   IF  MSTATION = '1' .OR. MKEN_COLOR = 'Y'
   **      SET COLOR TO W+/B+,W+/R+
   **   ELSE
   **      SET COLOR TO W/N,N/W
   **   ENDIF
   **   
   **   MSELECTION = INKEY(0)
   **   MSELECTION = '0'
   **ELSE
   **   MSELECTION = CHR(MSELECTION)
   **ENDIF
   
   DO CASE
   CASE MSELECTION = '1'
      DO IVIEWCHG 
      MSELECTION = ' '
   CASE MSELECTION = '2'
      DO IRPTS 
      MSELECTION = ' '
   CASE MSELECTION = '3'
      DO IMAINT   
      MSELECTION = ' '
   CASE MSELECTION = '4'
      DO PRINTLOT 
      MSELECTION = ' '
   ENDCASE
ENDDO
CLOSE DATA
CLEAR
RETURN



PROCEDURE TEXTLOT 
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 25,79
@ 04,01 SAY '      LOT #:' 
@ 04,25 SAY 'FREEZER:'

@ 06,03 SAY 'PO #:'  
@ 06,11 SAY '-'
@ 06,16 SAY '-'

@ 06,24 SAY 'DIVISION CODE: '
@ 06,47 SAY 'I #:'
@ 06,61 SAY 'DATE IN:'

@ 08,01 SAY '   SUPPLIER:'
@ 08,55 SAY 'DATE PAID:'

@ 10,01 SAY '    PRODUCT:'
@ 11,01 SAY '  PROD SIZE:'
@ 11,35 SAY ' BOX SIZE:'

@ 13,01 SAY 'NOTE:'

@ 15,01 SAY '   UNITS IN:'
@ 15,34 SAY 'UNITS LEFT:'

@ 17,01 SAY '   CASES IN:'
@ 17,34 SAY 'CASES LEFT:'

@ 19,01 SAY 'PRI/UNIT IN:'
@ 19,33 SAY 'CUR COST/UN:'

@ 21,01 SAY '   $ AMT IN:'
@ 21,34 SAY 'CUR COST $:'

RETURN


PROCEDURE GETLOT 
@ 04,14 GET MLOT_NBR   PICTURE '@!'
@ 04,34 GET MFREEZ_LOC PICTURE '@!'

@ 06,09 GET MSALESMAN  PICTURE '##'
@ 06,12 GET MPO_NBR    PICTURE '####'
@ 06,17 GET MPO_SUFFIX PICTURE '@!'
@ 06,39 GET MDIV_CODE  PICTURE '##'
@ 06,52 SAY MI_NBR     PICTURE '#####'
@ 06,70 GET MANIV_DATE           

@ 08,14 GET MSUPPLIER  PICTURE '@!'

@ 08,66 GET MPAID_DATE 

@ 10,14 GET MPROD_DESC PICTURE '@!'
IF MPROD_DESC <> SPACE(4)
   @ 10,21 SAY 'DESC: ' + MPROD_DISP
ENDIF

@ 11,14 GET MPROD_SIZE PICTURE '@!'
@ 11,46 GET MBOX_SIZE  PICTURE '@!'

@ 13,07 GET MNOTE      PICTURE '@!'

@ 15,14 GET MLBS       PICTURE '###,###,###.##'
@ 17,14 GET MCASE_CNT  PICTURE '####'
@ 19,14 GET MPRI_LB    PICTURE '##.####'
READ
IF MPROD_DESC <> SPACE(4)
   SELECT C
   SEEK 'R' + MPROD_DESC
   MPROD_DISP = DESC
   SELECT A
   @ 10,21 SAY 'DESC: '
   @ 10,27 GET MPROD_DISP
ENDIF

MVAL1  = MLBS * MPRI_LB    
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
MVALUE = MVAL1 

@ 21,14 GET MVALUE     PICTURE '###,###.##'
DO CALCCUR2
@ 15,46 GET MLBS_LEFT  PICTURE '###,###,###.##'
@ 17,46 GET MCASE_LEFT PICTURE '####'
IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
   MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
ELSE
   MPRO_PRI = 0
   MVAL_LEFT = 0
ENDIF
@ 19,46 GET MPRO_PRI   PICTURE '##.####'
@ 21,46 GET MVAL_LEFT  PICTURE '###,###.##'
CLEAR GETS
RETURN

PROCEDURE STORLOT 
MLOT_NBR    = LOT_NBR      
MSALESMAN   = SALESMAN
MPO_NBR     = PO_NBR  
MPO_SUFFIX  = PO_SUFFIX
MANIV_DATE  = ANIV_DATE
MFREEZ_LOC  = FREEZ_LOC
MPROD_DESC  = PROD_DESC
MDIV_CODE   = DIV_CODE
MPROD_SIZE  = PROD_SIZE
MBOX_SIZE   = BOX_SIZE
MLBS        = LBS      
MCASE_CNT   = CASE_CNT 
MPRI_LB     = PRI_LB
MVALUE      = VALUE
MSUPPLIER   = SUPPLIER
MPAID_DATE  = PAID_DATE
MNOTE       = NOTE
MI_NBR      = I_NBR
MVAL_LEFT   = VAL_LEFT
MLBS_LEFT   = LBS_LEFT
DO CALC_CUR

IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
   MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
ELSE
   MPRO_PRI = 0
   MVAL_LEFT = 0
ENDIF

RETURN

PROCEDURE REPLLOT 
DO FILELOCK
REPLACE LOT_NBR   WITH MLOT_NBR
REPLACE SALESMAN  WITH MSALESMAN
REPLACE PO_NBR    WITH MPO_NBR
REPLACE PO_SUFFIX WITH MPO_SUFFIX
REPLACE FREEZ_LOC WITH MFREEZ_LOC
REPLACE ANIV_DATE WITH MANIV_DATE
REPLACE PROD_DESC WITH MPROD_DESC
REPLACE DIV_CODE  WITH MDIV_CODE
REPLACE PROD_SIZE WITH MPROD_SIZE
REPLACE BOX_SIZE  WITH MBOX_SIZE
REPLACE LBS       WITH MLBS      
REPLACE CASE_CNT  WITH MCASE_CNT 
REPLACE PRI_LB    WITH MPRI_LB
REPLACE VALUE     WITH MVALUE
REPLACE SUPPLIER  WITH MSUPPLIER
REPLACE PAID_DATE WITH MPAID_DATE
REPLACE NOTE      WITH MNOTE
REPLACE I_NBR     WITH MI_NBR

DO CALC_CUR

IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
   MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
ELSE
   MPRO_PRI = 0
   MVAL_LEFT = 0
ENDIF

REPLACE VAL_LEFT  WITH MVAL_LEFT
REPLACE CASE_LEFT WITH MCASE_LEFT
REPLACE PRO_PRI   WITH MPRO_PRI
REPLACE LBS_LEFT  WITH MLBS_LEFT 
IF LBS_LEFT = 0 .OR. CASE_LEFT = 0
   REPLACE SOLD_FLG WITH 'Y'
ELSE
   REPLACE SOLD_FLG WITH ' '
ENDIF
UNLOCK
RETURN

PROCEDURE MULTIPO 
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MATCH SELECT'
@ 3,0 TO 21,79
@  5, 2 SAY "PO'S MATCHING YOUR INPUT.  PLEASE SELECT ACTION."
@ 6,5 say 'PO NBR     LOT NBR  I NBR   FREEZER               PRODUCT       BOX SZ'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC

MMULT = .T.
DO WHILE MMULT
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. SALESMAN+PO_NBR+PO_SUFFIX = SRCH_ARG .AND. MLINE < 20
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      IF SALESMAN <> '  '
         @ MLINE, 5 SAY SALESMAN + '-'
      ENDIF  
      @ MLINE,8 SAY PO_NBR
      IF PO_SUFFIX <> ' '
         @ MLINE,12 SAY '-' + PO_SUFFIX
      ENDIF
      @ MLINE,16 SAY LOT_NBR
      **@ MLINE,25 SAY I_NBR PICTURE '#####'
      @ MLINE,33 SAY SUBSTR(FREEZ_LOC,1,20)
      SELECT C
      SEEK 'R'+A->PROD_DESC
      @ MLINE,55 SAY SUBSTR(DESC,1,12)
      SELECT A
      @ MLINE,69 SAY BOX_SIZE
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. SALESMAN+PO_NBR+PO_SUFFIX = SRCH_ARG 
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Selection Number: '
   @ 22,19 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add PO/Lot   5.Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MFOUND = .T.
      MMULT = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add PO/Lot   5.Cancel'
   @ 24,09 GET MACTION PICTURE '9' RANGE 1,5
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      @ 07,01 CLEAR TO 20,78
      IF .NOT. MORE_FLG
         GOTO MTOP_REC
         STORE MTOP_SEQ - 1 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 2
      @ 07,01 CLEAR TO 20,78
      GOTO MTOP_REC
      STORE MTOP_SEQ - 1 TO MSEQ_NUM
      IF MSEQ_NUM <> 0
         SKIP -13
         STORE MSEQ_NUM - 13 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 3
      @ 07,01 CLEAR TO 20,78
      STORE 0 TO MSEQ_NUM
      GOTO MFST_REC
      LOOP
      
   CASE MACTION = 4
      MINIT_NM = .F.
      MADD = .T. 
      MMULT = .F.
      
   CASE MACTION = 5
      MMULT = .F.
      
   ENDCASE
   
ENDDO
RETURN


PROCEDURE MULTIFRZ
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MATCH SELECT'
@ 3,0 TO 21,79
@  5, 2 SAY "PO'S MATCHING YOUR INPUT.  PLEASE SELECT ACTION."
@ 6,5 say 'PO NBR     LOT NBR  I NBR   FREEZER               PRODUCT       BOX SZ'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC

MMULT = .T.
DO WHILE MMULT
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. FREEZ_LOC = SRCH_ARG .AND. MLINE < 20
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      IF SALESMAN <> '  '
         @ MLINE, 5 SAY SALESMAN + '-'
      ENDIF  
      @ MLINE,8 SAY PO_NBR
      IF PO_SUFFIX <> ' '
         @ MLINE,12 SAY '-' + PO_SUFFIX
      ENDIF
      @ MLINE,16 SAY LOT_NBR
      **@ MLINE,25 SAY I_NBR PICTURE '#####'
      @ MLINE,33 SAY SUBSTR(FREEZ_LOC,1,20)
      SELECT C
      SEEK 'R'+A->PROD_DESC
      @ MLINE,55 SAY SUBSTR(DESC,1,12)
      SELECT A
      @ MLINE,69 SAY BOX_SIZE
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. FREEZ_LOC = SRCH_ARG                   
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Selection Number: '
   @ 22,19 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add PO/Lot   5.Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MFOUND = .T.
      MMULT = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add PO/Lot   5.Cancel'
   @ 24,09 GET MACTION PICTURE '9' RANGE 1,5
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      @ 07,01 CLEAR TO 20,78
      IF .NOT. MORE_FLG
         GOTO MTOP_REC
         STORE MTOP_SEQ - 1 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 2
      @ 07,01 CLEAR TO 20,78
      GOTO MTOP_REC
      STORE MTOP_SEQ - 1 TO MSEQ_NUM
      IF MSEQ_NUM <> 0
         SKIP -13
         STORE MSEQ_NUM - 13 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 3
      @ 07,01 CLEAR TO 20,78
      STORE 0 TO MSEQ_NUM
      GOTO MFST_REC
      LOOP
      
   CASE MACTION = 4
      MINIT_NM = .F.
      MADD = .T. 
      MMULT = .F.
      
   CASE MACTION = 5
      MMULT = .F.
      
   ENDCASE
   
ENDDO
RETURN

PROCEDURE MULTILOT
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MATCH SELECT'
@ 3,0 TO 21,79
@  5, 2 SAY "PO'S MATCHING YOUR INPUT.  PLEASE SELECT ACTION."
@ 6,5 say 'LOT NBR  I NBR   PO NBR     FREEZER               PRODUCT       BOX SZ'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC

MMULT = .T.
DO WHILE MMULT
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. LOT_NBR = SRCH_ARG .AND. MLINE < 20
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      @ MLINE,5  SAY LOT_NBR
      **@ MLINE,14 SAY I_NBR PICTURE '#####'
      IF SALESMAN <> '  '
         @ MLINE,22 SAY SALESMAN + '-'
      ENDIF  
      @ MLINE,25 SAY PO_NBR
      IF PO_SUFFIX <> ' '
         @ MLINE,29 SAY '-' + PO_SUFFIX
      ENDIF
      @ MLINE,33 SAY SUBSTR(FREEZ_LOC,1,20)
      SELECT C
      SEEK 'R'+A->PROD_DESC
      @ MLINE,55 SAY SUBSTR(DESC,1,12)
      SELECT A
      @ MLINE,69 SAY BOX_SIZE
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. LOT_NBR = SRCH_ARG                   
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Selection Number: '
   @ 22,19 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add PO/Lot   5.Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MFOUND = .T.
      MMULT = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add PO/Lot   5.Cancel'
   @ 24,09 GET MACTION PICTURE '9' RANGE 1,5
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      @ 07,01 CLEAR TO 20,78
      IF .NOT. MORE_FLG
         GOTO MTOP_REC
         STORE MTOP_SEQ - 1 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 2
      @ 07,01 CLEAR TO 20,78
      GOTO MTOP_REC
      STORE MTOP_SEQ - 1 TO MSEQ_NUM
      IF MSEQ_NUM <> 0
         SKIP -13
         STORE MSEQ_NUM - 13 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 3
      @ 07,01 CLEAR TO 20,78
      STORE 0 TO MSEQ_NUM
      GOTO MFST_REC
      LOOP
      
   CASE MACTION = 4
      MINIT_NM = .F.
      MADD = .T. 
      MMULT = .F.
      
   CASE MACTION = 5
      MMULT = .F.
      
   ENDCASE
   
ENDDO
RETURN

PROCEDURE IRPTS
MRPT_SEL = ' '
DO WHILE MRPT_SEL <> '9'
   CLOSE DATA
   CLEAR
   @ 00,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 01,00 SAY MPROGRAM + ' - REPORTS MENU'
   @ 2,0 to 25,79
   
   @ 03,10 SAY '1 - DISPLAY/PRINT REMAINING INVENTORY'                       
   @ 05,10 SAY '2 - PRINT INVENTORY IN LOT NBR/OR DATE ORDER BY PRODUCT CATEGORY'                       
   @ 07,10 SAY '3 - PRINT REPORT OF LOTS WITH APPROACHING ANNIVERSARY DATES'
   @ 09,10 SAY '4 - PRINT ACTIVITY REPORT FOR MONTHLY CLOSING'               
   @ 11,10 SAY '5 - PRINT DETAILS BY LOT NBR/TOTALS USING CUTOFF ACTIVITY DATE'
   @ 13,10 SAY '6 - PRINT ACTIVITY BY OPTIONAL SUPPLIER'
   @ 15,10 SAY '7 - CALCULATE/PRINT DATE-TO-DATE STORAGE COSTS'
   @ 17,10 say '8 - PRINT SPECIFIC LOT ACTIVITY/NET DOLLARS'
   @ 19,10 SAY '9 - EXIT'
   
   STORE ' ' TO MRPT_SEL   
   @ 22,02 SAY 'CHOICE: '
   @ 22,10 GET MRPT_SEL   PICTURE '9'
   READ
   
   DO CASE
   CASE MRPT_SEL = '1'
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNCAT", .F.
      SET FILTER TO SOLD_FLG = ' '
      
      SELECT F
      *** INVNTMP5
      MFILENM = 'INVNTMP' + '5'
      USE &MFILENM EXCLUSIVE
      DELETE ALL
      PACK
      INDEX ON RSUPCODE TO &MFILENM
      USE
      DO FOX_USE WITH "&MFILENM INDEX &MFILENM", .F.
      
      SELECT A
      MSAVE_LINE = 0
      MTOP_REC = 0
      MNBR_LINES = 0
      MPRT_OUT = .T.  
      MPAGE = 0
      MMORE = .T.
      DO WHILE MMORE
         MNEXT_PRFX = '  '
         MNEXT_CODE = SPACE(10)
         SELECT C
         DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
         CLEAR
         @ 00,00 SAY MCOMPANY
         @ 01,68 SAY DATE()
         @ 01,00 SAY MPROGRAM + ' - PRINT/DISPLAY INVENTORY PRODUCT SUMMARY'
         @ 2,0 to 25,79
         MSEL_PROD = SPACE(10)
         MSEL_PREFX = '  '
         MSEL_FRZR = SPACE(32)
         MRPT_PICK = 'D'
         MPRT_DISP = 'D'
         MPAPER = 'WIDE'
         MACTION = 2
         DO WHILE MACTION = 2
            @ 05,3 SAY '  Print (P) or Display (D) Report:' get MPRT_DISP PICTURE '@!'
            @ 09,3 SAY '      Enter Optional Product Code: '
            @ 09,38 GET MSEL_PREFX PICTURE '@!'
            @ 09,41 GET MSEL_PROD  PICTURE '@!'
            @ 21,5 SAY 'Note: If selecting report - WIDE paper required'
            STORE 1 TO MACTION
            @ 24,0 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2. Edit    3. Finished/Cancel'          
            READ
            @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
            READ
            IF MACTION = 1
               SELECT C
               MFRZR_CODE = SPACE(4)
            ENDIF
         ENDDO
         IF MACTION = 3
            MMORE = .F.
            LOOP
         ENDIF
         
         **** TEMPORARY
         IF MPRT_DISP <> 'D'
            **MPRT_DISP = 'D'
         ENDIF
         IF MPRT_DISP = 'P'
            MPRT_ACT = 'C'
            DO PRT_SET
            IF MPRT_ACT <> 'C'
               LOOP  
            ENDIF
            MPAGE_LEN = 56
         ELSE
            MPAGE_LEN = 22 
         ENDIF
         
         MPAGE_NO = 0
         MLINE = 99
         
         IF MPRT_DISP = 'P'
            @ 21,16 SAY SPACE(34)
            @ 21,16 SAY 'PROCESSING/PRINTING......'
            
            SET CONSOLE OFF
            IF FILE("C:\COMPINFO\PRINTERS.DBF")
               SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
            ELSE
               SET PRINT TO LPT3
            ENDIF
            SET DEVICE TO PRINT
            SET PRINT ON
            *** PRINT IN 12 CPI
            ?? chr(27) + '&k4S'
            
            *** LETTER GOTHIC AND BOLDED PRINT
            ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
            
            *** LANDSCAPE MODE
            ?? CHR(27) + '&l1O'
            
            *** LEGAL SIZE PAPER
            ?? CHR(27) + '&l3A'
            
            DO IRPT
            LOOP
         ELSE
            CLEAR
         ENDIF
         
         **** FORGING ON AHEAD - THIS IS FOR DISPLAY PURPOSES
         
         SELECT A
         GOTO TOP
         
         DO CASE
         CASE MSEL_PREFX+MSEL_PROD = SPACE(12)
         CASE MSEL_PREFX+MSEL_PROD = 'M    '
            LOOP
         CASE MSEL_PREFX+MSEL_PROD = 'B    '
            LOOP
         CASE MSEL_PROD <> SPACE(10)
            SEEK MSEL_PREFX+MSEL_PROD
            IF EOF()
               @ 23,0 CLEAR
               MWAIT = ' '
               @ 24,1 SAY 'NO INVENTORY FOR SELECTED VENDOR CODE - PRESS RETURN TO CONTINUE  ' GET MWAIT  
               READ
               @ 24,0 CLEAR
               SELECT A
               GOTO BOTTOM
               SKIP
               LOOP
            ENDIF
         CASE MSEL_PREFX <> '  '
            **** FIND NEXT STARTING PLACE HERE
            SEEK MSEL_PREFX
            IF EOF()
               @ 23,0 CLEAR
               MWAIT = ' '
               @ 24,1 SAY 'NO INVENTORY FOR SELECTED VENDOR PREFIX - PRESS RETURN TO CONTINUE  ' GET MWAIT  
               READ
               @ 24,0 CLEAR
               SELECT A
               GOTO BOTTOM
               SKIP
               LOOP
            ENDIF
         ENDCASE
         
         DO INV_DSP1
         
         
         MCANCEL = .F.
         DO WHILE .NOT. MCANCEL
            
            SELECT A
            
            DO WHILE .NOT. EOF()
               
               MPROD_DESC = IPRODDESC
               MPRT_OUT = .T.
               DO WHILE .NOT. EOF() .AND. IPRODDESC = MPROD_DESC .AND. .NOT. MCANCEL 
                  
                  DO CASE
                     
                  CASE MSEL_PREFX+MSEL_PROD = SPACE(12)
                     ** NO PRODUCT SELECTED - KEEP GOING TO ENDO OF FILE
                     
                  CASE MSEL_PREFX <> SPACE(2) .AND. MSEL_PROD = SPACE(10)
                     ** PREFIX SELECTED - CHECK ONLY THAT
                     IF MSEL_PREFX <> SUBSTR(IPRODDESC,1,2)
                        GOTO BOTTOM
                        SKIP
                        LOOP
                     ENDIF
                     
                  OTHERWISE
                     ** SOMETHING SELECTED  - CHECK BOTH PREFIX AND PRODUCT
                     IF MSEL_PREFX+MSEL_PROD <> IPRODDESC
                        GOTO BOTTOM
                        SKIP
                        LOOP
                     ENDIF
                  ENDCASE
                  
                  SELECT C
                  DO FOX_USE WITH "&MDBFLOC.SUP_PROD INDEX &MDBFLOC.SUP_PROD", .F.
                  SEEK A->IPRODDESC
                  IF EOF()
                     MPRT_PROD = 'CODE NOT ON FILE'
                  ELSE
                     MPRT_PROD = DESCRIP 
                  ENDIF
                  
                  SELECT A
                  
                  IF MPRT_OUT
                     MJUMP = 2
                  ELSE
                     MJUMP = 1
                  ENDIF
                  IF MLINE <> 5 .AND. MLINE + MJUMP > MPAGE_LEN
                     MNEXT_PRFX = '  '
                     MNEXT_CODE = SPACE(10)
                     @ 24,0 SAY "ENTER = NEXT PG   'B' = PG BACK   'M' = MENU    OR NEXT PRODUCT CD "                 
                     @ 24,67 GET MNEXT_PRFX PICTURE '@!'
                     @ 24,70 GET MNEXT_CODE PICTURE '@!'
                     READ
                     DO CASE
                     CASE MNEXT_PRFX+MNEXT_CODE = 'M    '
                        SELECT A
                        GOTO BOTTOM
                        SKIP
                        MCANCEL = .T.
                        LOOP
                     CASE MNEXT_PRFX+MNEXT_CODE = 'B    '
                        DO CASE
                        CASE MTOP_REC = 0 .OR. MLINE = 5
                           GOTO TOP
                        OTHERWISE 
                           MLINE = 6           
                           GOTO MTOP_REC
                           SKIP -1
                           MPROD = IPRODDESC
                           MLINE = MLINE + 1
                           MQUIT = .F.
                           DO WHILE .NOT. BOF() .AND. MLINE < MPAGE_LEN .AND. .NOT. MQUIT
                              SKIP -1
                              IF MPROD <> IPRODDESC
                                 IF MLINE+2 >= MPAGE_LEN
                                    SKIP    
                                    MQUIT = .T.
                                    LOOP
                                 ELSE
                                    MLINE = MLINE + 2
                                 ENDIF
                              ENDIF
                              MLINE = MLINE + 1
                              MPROD = IPRODDESC
                           ENDDO
                        ENDCASE
                        DO INV_DSP1
                        LOOP
                     CASE MNEXT_CODE <> SPACE(10)
                        MSEL_PREFX = MNEXT_PRFX 
                        MSEL_PROD = MNEXT_CODE
                        **** FIND NEXT STARTING PLACE HERE
                        SELECT A
                        SEEK MSEL_PREFX+MSEL_PROD
                        IF EOF()
                           @ 23,0 CLEAR
                           MWAIT = ' '
                           @ 24,1 SAY 'NO INVENTORY FOR SELECTED VENDOR CODE - PRESS RETURN TO CONTINUE  ' GET MWAIT  
                           READ
                           @ 24,0 CLEAR
                           SELECT A
                           GOTO BOTTOM
                           SKIP
                           MCANCEL = .T.
                           LOOP
                        ENDIF
                        STORE SPACE(2) TO MNEXT_PRFX
                        STORE SPACE(10) TO MNEXT_CODE
                        DO INV_DSP1
                        LOOP
                     CASE MNEXT_PRFX <> '  '
                        **** FIND NEXT STARTING PLACE HERE
                        MSEL_PREFX = MNEXT_PRFX
                        MSEL_PROD = MNEXT_CODE
                        SELECT A
                        SEEK MSEL_PREFX
                        IF EOF()        
                           @ 23,0 CLEAR
                           MWAIT = ' '
                           @ 24,1 SAY 'NO INVENTORY FOR SELECTED PREFIX CODE - PRESS RETURN TO CONTINUE  ' GET MWAIT  
                           READ
                           @ 24,0 CLEAR
                           SELECT A
                           GOTO BOTTOM
                           SKIP
                           MCANCEL = .T.
                           LOOP
                        ENDIF
                        MNEXT_PRFX = SPACE(2)   
                        MNEXT_CODE = SPACE(10)  
                        DO INV_DSP1
                        LOOP
                     OTHERWISE
                        MSEL_PREFX = SPACE(2)   
                        MSEL_PROD = SPACE(10)  
                        MNEXT_PRFX = SPACE(2)   
                        MNEXT_CODE = SPACE(10)  
                        DO INV_DSP1
                        LOOP
                     ENDCASE
                  ENDIF
                  
                  IF MPRT_OUT
                     *** PRINT OUT PRODUCT DESCRIPTION
                     MLINE = MLINE + 1
                     IF SUBSTR(PROD_DESC,1,2) = '  '
                        MX = SUBSTR(MPROD_DESC,3)
                        @ MLINE,0  GET MX                    
                     ELSE
                        @ MLINE,0  GET MPROD_DESC
                     ENDIF
                     MSPACE = 66 - LEN(MPRT_PROD)
                     @ MLINE,13 SAY MPRT_PROD                 
                     CLEAR GETS
                     MPRT_OUT = .F.
                     MLINE = MLINE + 1
                  ENDIF
                  
                  *** OK, NOW GET TO IT
                  SELECT F
                  DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
                  SEEK A->RSUPCODE
                  IF EOF()
                     MNAME = 'UNKN'
                  ELSE
                     MNAME = SUBSTR(NAME,1,4)
                  ENDIF
                  USE
                  SELECT A
                  IF FRH_FRZ = 'FH'
                     @ MLINE,1 SAY '*FRESH'
                  ENDIF
                  @ MLINE,8  SAY MNAME   
                  @ MLINE,13 SAY LOT_NBR
                  IF SUBSTR(LOT_NBR,1,1) = 'P' .OR. SUBSTR(LOT_NBR,1,1) = 'O'
                     @ MLINE,24 SAY '*'
                  ENDIF
                  @ MLINE,25 SAY DTOC(ANIV_DATE)
                  IF BOX_SZ = 0    
                     @ MLINE,34 SAY ' CWT'
                  ELSE
                     IF BOX_SZ - INT(BOX_SZ) <> 0
                        @ MLINE,34 SAY BOX_SZ PICTURE '99.9' 
                     ELSE
                        @ MLINE,34 SAY BOX_SZ PICTURE '9999'
                     ENDIF
                  ENDIF
                  *** NOW - FIGURE OUT WHAT IS LEFT
                  *** EVERYTHING WITH FIVE '*' IN FRONT IS THE LATEST
                  *****@ MLINE,27 SAY CASE_LEFT PICTURE '9999'
                  IF SUBSTR(PACKED,1,1) = 'B'
                     MLBS_LEFT = ROUND(CASE_LEFT * BOX_SZ,2)
                     MSTOR_UNIT = STOR_LB
                     @ MLINE,40 SAY CASE_COM PICTURE '@Z 9999'
                     @ MLINE,45 SAY ROUND(CASE_COM * BOX_SZ,2) PICTURE '@Z 999999.99'
                     *** THIS IS AVAILABLE
                     MAVAIL = CASE_LEFT - CASE_COM
                     @ MLINE,57 SAY MAVAIL PICTURE '9999'
                     @ MLINE,62 SAY ROUND(MAVAIL * BOX_SZ,2) PICTURE '999999.99'
                     *** 
                     @ MLINE,72 SAY PRI_LB + MSTOR_UNIT PICTURE '99.9999'
                     MPRI_LB = PRI_LB / BOX_SZ                     
                     MPRI_LB = ROUND(MPRI_LB,4)
                  ELSE
                     @ MLINE,40 SAY CASE_COM PICTURE '@Z 9999'
                     @ MLINE,45 SAY LBS_COM PICTURE '@Z 999999.99'
                     *** THIS IS AVAILABLE
                     @ MLINE,57 SAY CASE_LEFT - CASE_COM PICTURE '9999'
                     @ MLINE,62 SAY LBS_LEFT - LBS_COM PICTURE '999999.99'
                     *** 
                     @ MLINE,72 SAY PRI_LB + STOR_LB PICTURE '9.9999'
                  ENDIF
                  SELECT A
                  MLINE = MLINE + 1
                  SKIP
               ENDDO
            ENDDO
            IF MNEXT_PRFX = 'M'
               MCANCEL = .T.
               LOOP
            ENDIF
            
            MNEXT_PRFX = '  '
            MNEXT_CODE = SPACE(10)
            @ 24,0 SAY "ENTER = NEXT PG   'B' = PG BACK   'M' = MENU    OR NEXT PRODUCT CD "                 
            @ 24,67 GET MNEXT_PRFX PICTURE '@!'
            @ 24,70 GET MNEXT_CODE PICTURE '@!'
            READ
            DO CASE
            CASE MNEXT_PRFX+MNEXT_CODE = 'M    '
               SELECT A
               GOTO BOTTOM
               SKIP
               MCANCEL = .T.
               LOOP
            CASE MNEXT_PRFX+MNEXT_CODE = 'B    '
               DO CASE
               CASE MTOP_REC = 0 .OR. MLINE = 5
                  GOTO TOP
               OTHERWISE 
                  MLINE = 6           
                  GOTO MTOP_REC
                  SKIP -1
                  MPROD = IPRODDESC
                  MLINE = MLINE + 1
                  MQUIT = .F.
                  DO WHILE .NOT. BOF() .AND. MLINE < MPAGE_LEN .AND. .NOT. MQUIT
                     SKIP -1
                     IF MPROD <> IPRODDESC
                        IF MLINE+2 >= MPAGE_LEN
                           SKIP    
                           MQUIT = .T.
                           LOOP
                        ELSE
                           MLINE = MLINE + 2
                        ENDIF
                     ENDIF
                     MLINE = MLINE + 1
                     MPROD = IPRODDESC
                  ENDDO
               ENDCASE
               DO INV_DSP1
               LOOP
            CASE MNEXT_CODE <> SPACE(10)
               MSEL_PREFX = MNEXT_PRFX 
               MSEL_PROD = MNEXT_CODE
               **** FIND NEXT STARTING PLACE HERE
               SELECT A
               SEEK MSEL_PREFX+MSEL_PROD
               IF EOF()
                  @ 23,0 CLEAR
                  MWAIT = ' '
                  @ 24,1 SAY 'NO INVENTORY FOR SELECTED VENDOR CODE - PRESS RETURN TO CONTINUE  ' GET MWAIT  
                  READ
                  @ 24,0 CLEAR
                  SELECT A
                  GOTO BOTTOM
                  SKIP
                  MCANCEL = .T.
                  LOOP
               ENDIF
               STORE SPACE(2) TO MNEXT_PRFX
               STORE SPACE(10) TO MNEXT_CODE
               DO INV_DSP1
               LOOP
            CASE MNEXT_PRFX <> '  '
               **** FIND NEXT STARTING PLACE HERE
               MSEL_PREFX = MNEXT_PRFX
               MSEL_PROD = MNEXT_CODE
               SELECT A
               SEEK MSEL_PREFX
               IF EOF()        
                  @ 23,0 CLEAR
                  MWAIT = ' '
                  @ 24,1 SAY 'NO INVENTORY FOR SELECTED PREFIX CODE - PRESS RETURN TO CONTINUE  ' GET MWAIT  
                  READ
                  @ 24,0 CLEAR
                  SELECT A
                  GOTO BOTTOM
                  SKIP
                  MCANCEL = .T.
                  LOOP
               ENDIF
               MNEXT_PRFX = SPACE(2)   
               MNEXT_CODE = SPACE(10)  
               DO INV_DSP1
               LOOP
            OTHERWISE
               MSEL_PREFX = SPACE(2)   
               MSEL_PROD = SPACE(10)  
               MNEXT_PRFX = SPACE(2)   
               MNEXT_CODE = SPACE(10)  
               SELECT A
               GOTO TOP
               DO INV_DSP1
               LOOP
            ENDCASE
         ENDDO
      ENDDO
      CLOSE DATA
      MRPT_SEL   = ' '
      
      
   CASE MRPT_SEL = '2'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT INVENTORY REPORT BY LOT NUMBER/DATE'
      @ 2,0 to 25,79
      MDIV  = SPACE(2)
      MFREEZER = SPACE(40)
      MRPT_ORDER = '    '
      MTOT_ONLY = 'NO '
      @ 7,3 SAY '     Enter Optional Division Code: ' GET MDIV PICTURE '@!'
      @ 09,3 SAY '      Enter Optional Freezer Name: ' GET MFREEZER PICTURE '@!'
      @ 11,1 SAY 'Print in Lot (LOT) or Date (DATE) Order: ' GET MRPT_ORDER PICTURE '@!'
      @ 13,1 SAY '             Print totals only (YES/NO): ' GET MTOT_ONLY PICTURE '@!'
      READ
      @ 5,1 CLEAR TO 13,78
      
      MPRT_ACT = 'C'
      
      @ 20,01 CLEAR TO 20,78 
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      MPAGE_LEN = 44
      
      MPAGE_NO = 0
      MLINE = 99
      
      @ 21,16 SAY SPACE(34)
      @ 21,16 SAY 'PROCESSING............'
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      SELECT E
      DO FOX_USE WITH "&MMASTDBF.DIVISION", .F.
      
      SELECT D 
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      DO CASE
      CASE MRPT_ORDER = 'LOT'
         SELECT A
         DO FOX_USE WITH "INVEN INDEX INVNLOT", .F.
      OTHERWISE
         SELECT A
         *** DATE ORDER 
         DO FOX_USE WITH "INVEN INDEX INVNANIV", .F.
      ENDCASE
      MTOT_LBS = 0
      MTOT_VAL = 0
      MTOT_CASE = 0
      IF MFREEZER <> SPACE(40)
         MFREEZER = TRIM(MFREEZER)
      ENDIF
      
      I = 1
      DO WHILE I <= 24
         MI = SUBSTR(STR(I+100,3),2)
         STORE 0 TO MNBR&MI
         I = I + 1
      ENDDO
      
      DO WHILE .NOT. EOF()
         IF SOLD_FLG <> ' '
            SKIP
            LOOP
         ENDIF 
         IF MDIV <> SPACE(2)
            IF MDIV <> DIV_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
         IF MFREEZER <> SPACE(40)
            IF FREEZ_LOC <> MFREEZER
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT 
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,59 SAY MCOMPANY
            @ 2,1 SAY 'Page'
            @ 2,06 say mpage_no picture '99'
            @ 2,50 SAY '    INVENTORY REPORT  AS OF ' + DTOC(DATE())
            @ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
            @ 5,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK  CASES        UNITS  PUR PRI     POUNDS      TOTAL $'
            @ 5,01 SAY REPLICATE('_',160)
            MLINE = 7
         ENDIF
         IF MTOT_ONLY = 'NO '
            @ MLINE,1 SAY ANIV_DATE
            @ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
            @ MLINE,33 SAY LOT_NBR
            *@ MLINE,42 SAY STR(I_NBR,5)  
         ENDIF
         *** GO FIND THE SALESPERSON NAME
         IF SALESMAN <> '  '
            SELECT D
            SEEK A->SALESMAN
            IF .NOT. EOF()
               *@ MLINE,48 SAY SUBSTR(NAME,1,7)
            ELSE
               *@ MLINE,48 SAY A->SALESMAN
            ENDIF
            SELECT A
         ELSE
            *@ MLINE,48 SAY BROK_NAME
         ENDIF
         IF MTOT_ONLY = 'NO '
            @ MLINE,49 SAY SUBSTR(SUPPLIER,1,16)
            @ MLINE,69 SAY PROD_DESC
            @ MLINE,76 SAY PROD_SIZE
            
            SELECT C
            SEEK 'R' + A->PROD_DESC
            IF EOF()       
               MDESC = A->PROD_DESC
            ELSE
               MDESC = SUBSTR(DESC,1,15)
            ENDIF
            @ MLINE,86 SAY SUBSTR(MDESC,1,15)
         ENDIF
         
         SELECT A
         MCASE_LEFT = 0
         MVAL_LEFT = 0
         MLBS_LEFT = 0
         DO CALC_CUR
         IF MLBS_LEFT <> 0
            *IF SUBSTR(BOX_SIZE,1,1) = 'B' .OR. SUBSTR(BOX_SIZE,1,1) = 'H'  
            *   MSTOR_UNIT = ROUND(VAL(SUBSTR(BOX_SIZE,2))*.0125,4)
            *ELSE
            *   MSTOR_UNIT = .0125
            *ENDIF
            MSTOR_UNIT = 0
            MPRO_PRI = PRI_LB + MSTOR_UNIT                  
            MVAL_LEFT = ROUND(MPRO_PRI * MLBS_LEFT,2)
         ELSE
            MPRO_PRI = 0
            MVAL_LEFT = 0
         ENDIF
         
         IF MTOT_ONLY = 'NO '
            @ MLINE,104 SAY BOX_SIZE
            @ MLINE,111 SAY MCASE_LEFT PICTURE '9999'
         ENDIF
         
         MTOT_CASE = MTOT_CASE + MCASE_LEFT
         IF MTOT_ONLY = 'NO '
            @ MLINE,118 SAY MLBS_LEFT  PICTURE '999,999.99'
            @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
            *IF MRPT_ORDER = 'LOT'
            *   @ MLINE,140 SAY MPRO_PRI   PICTURE '99.9999'
            *ENDIF
         ENDIF
         
         IF SUBSTR(box_size,1,1) = 'B' .OR. SUBSTR(BOX_SIZE,1,1) = 'H'
            mbox_sz = val(substr(box_size,2))
            MLBS = ROUND(mcase_LEFT * mbOX_SZ,2)
         ELSE
            mlbs = mlbs_left                                          
         ENDIF
         IF MTOT_ONLY = 'NO '
            @ mline,138 say mlbs picture '999,999.99'
         ENDIF
         MTOT_LBS = MTOT_LBS + MLBS
         
         IF MLBS_LEFT <> 0
            IF MTOT_ONLY = 'NO '
               @ MLINE,149 SAY MVAL_LEFT  PICTURE '9,999,999.99'
            ENDIF
            MTOT_VAL = MTOT_VAL + MVAL_LEFT
            *** NOW ADD IN FOR ANIVERSARY DATE $
            MNO_DATE = CTOD('')
            MANIV_DATE = ANIV_DATE
            MMO = VAL(SUBSTR(DTOC(MANIV_DATE),1,2))
            MMO = MMO + 1
            MMO = SUBSTR(STR(MMO+100,3),2)
            IF MMO = '13'
               MMO = '01'
               MYR = VAL(SUBSTR(DTOC(MANIV_DATE),7))
               MYR = MYR + 1
               MYR = STR(MYR,4)
            ELSE
               MYR = SUBSTR(DTOC(MANIV_DATE),7)
            ENDIF
            MREST = SUBSTR(DTOC(MANIV_DATE),3,4)
            MDY = SUBSTR(DTOC(MANIV_DATE),4,2)
            MANIV_DATE = CTOD(MMO+MREST+MYR)
            ** CHECK FOR VALID DATE
            IF MANIV_DATE = MNO_DATE
               MDAYX = VAL(MDY)
               DO WHILE MANIV_DATE = MNO_DATE
                  MDAYX = MDAYX - 1
                  MX = SUBSTR(STR(MDAYX+100,3),2)
                  MANIV_DATE = CTOD(MMO+'/'+MX+'/'+MYR)
               ENDDO
            ENDIF
            ** END OF VALID DATE CHECK
            I = 0
            DO WHILE MANIV_DATE <= DATE()
               I = I + 1
               MMO = VAL(SUBSTR(DTOC(MANIV_DATE),1,2))
               MMO = MMO + 1
               MMO = SUBSTR(STR(MMO+100,3),2)
               IF MMO = '13'
                  MMO = '01'
                  MYR = VAL(SUBSTR(DTOC(MANIV_DATE),7))
                  MYR = MYR + 1
                  MYR = STR(MYR,4)
               ELSE
                  MYR = SUBSTR(DTOC(MANIV_DATE),7)
               ENDIF
               MREST = SUBSTR(DTOC(MANIV_DATE),3,4)
               MANIV_DATE = CTOD(MMO+MREST+MYR)
               ** CHECK FOR VALID DATE
               IF MANIV_DATE = MNO_DATE
                  MDAYX = VAL(MDY)
                  DO WHILE MANIV_DATE = MNO_DATE
                     MDAYX = MDAYX - 1
                     MX = SUBSTR(STR(MDAYX+100,3),2)
                     MANIV_DATE = CTOD(MMO+'/'+MX+'/'+MYR)
                  ENDDO
               ENDIF
               ** END OF VALID DATE CHECK
            ENDDO
            IF I <> 0
               MI = SUBSTR(STR(I+100,3),2)
               MNBR&MI = MNBR&MI + MVAL_LEFT
            ENDIF
         ENDIF
         IF MTOT_ONLY = 'NO '
            MLINE = MLINE + 2
         ENDIF
         SKIP
      ENDDO
      
      IF MLINE <> 99 .OR. MTOT_ONLY = 'YES'
         MLINE = MLINE + 1
         @ MLINE,1 SAY 'GRAND TOTALS:'
         *@ MLINE,109 SAY MTOT_CASE  PICTURE '999999'
         *@ MLINE,115 SAY MTOT_LBS PICTURE '99,999,999.99'
         @ mline,135 say mTOT_lbs picture '99,999,999.99'
         @ MLINE,148 SAY MTOT_VAL PICTURE '99,999,999.99'
         *@ MLINE+1,1 SAY ' '
         MLINE = MLINE + 3
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT 
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,59 SAY MCOMPANY
            @ 2,1 SAY 'Page'
            @ 2,06 say mpage_no picture '99'
            @ 2,50 SAY '    INVENTORY REPORT  AS OF ' + DTOC(DATE())
            @ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
            @ 5,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK  CASES        UNITS  PUR PRI                 TOTAL $'
            @ 5,01 SAY REPLICATE('_',160)
            MLINE = 7
         ENDIF
         @ MLINE,1 SAY 'NUMBER OF ANNIVERSARIES            TOTAL VALUE'
         MLINE = MLINE + 2
         MTOT = 0
         I = 1
         DO WHILE I<= 24
            MI = SUBSTR(STR(I+100,3),2)
            IF MNBR&MI <> 0
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT 
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 1,59 SAY MCOMPANY
                  @ 2,1 SAY 'Page'
                  @ 2,06 say mpage_no picture '99'
                  @ 2,50 SAY '    INVENTORY REPORT  AS OF ' + DTOC(DATE())
                  @ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
                  @ 5,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK  CASES        UNITS  PUR PRI                 TOTAL $'
                  @ 5,01 SAY REPLICATE('_',160)
                  MLINE = 7
               ENDIF
               @ MLINE,11 SAY STR(I,2)
               @ MLINE,33 SAY MNBR&MI PICTURE '999,999,999.99'
               MTOT = MTOT + MNBR&MI
               MLINE = MLINE + 2
            ENDIF
            I = I + 1
         ENDDO
         @ MLINE,1 SAY 'TOTAL REACHING ANNIVERSARY'
         @ MLINE,33 SAY MTOT PICTURE '999,999,999.99' 
         @ MLINE+1,1 SAY ' '
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      CLOSE DATA
      MRPT_SEL   = ' '
      
   CASE MRPT_SEL = '3'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT LOTS WITH APPROACHING ANNIV DATES'
      @ 2,0 to 25,79
      MPROD = SPACE(4)
      MDIV  = SPACE(2)
      MFREEZER = SPACE(40)
      MCUTOFF_DT = CTOD('')
      MRPT_PICK = 'D'
      @ 5,3 SAY '                Enter Report Date: ' GET MCUTOFF_DT
      @ 6,3 SAY '(Will print lots with anniversaries from above date forward 14 days)'
      @ 8,3 SAY '     Enter OPTIONAL Division Code: ' GET MDIV PICTURE '@!'
      @ 10,3 SAY '      Enter OPTIONAL Product Code: ' GET MPROD  PICTURE '@!'
      @ 12,3 SAY '      Enter OPTIONAL Freezer Name: ' GET MFREEZER PICTURE '@!'
      READ
      IF DTOC(MCUTOFF_DT) = '  /  /  '
         LOOP
      ENDIF
      
      @ 5,3 CLEAR TO 12,78
      
      MPRT_ACT = 'C'
      
      @ 20,01 CLEAR TO 20,78 
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      MPAGE_LEN = 44
      
      MPAGE_NO = 0
      MLINE = 99
      
      @ 21,16 SAY SPACE(34)
      @ 21,16 SAY 'PROCESSING............'
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      MDATE = MCUTOFF_DT
      I = 1
      DO WHILE I <= 14
         MI = SUBSTR(STR(I+100,3),2)
         MDAY&MI = SUBSTR(DTOC(MDATE),4,2)
         MDATE = MDATE + 1
         I = I + 1
      ENDDO
      
      SELECT E
      DO FOX_USE WITH "&MMASTDBF.DIVISION", .F.
      
      SELECT D 
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNSOLD", .F.
      SEEK ' '
      MTOT_LBS = 0
      MTOT_VAL = 0
      MTOT_CASE = 0
      IF MFREEZER <> SPACE(40)
         MFREEZER = TRIM(MFREEZER)
      ENDIF
      DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' '
         IF MDIV <> SPACE(2)
            IF MDIV <> DIV_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
         MMATCH = .F.
         I = 1
         DO WHILE I <= 14 .AND. .NOT. MMATCH
            MI = SUBSTR(STR(I+100,3),2)
            IF SUBSTR(DTOC(ANIV_DATE),4,2) = MDAY&MI
               MMATCH = .T.
            ENDIF
            I = I + 1
         ENDDO
         IF .NOT. MMATCH
            SKIP
            LOOP
         ENDIF
         
         MTOT_DLBS = 0
         MTOT_DVAL = 0
         MTOT_DCAS = 0
         MDIV_CODE = DIV_CODE
         MDIV_NAME = 'DIVISION CODE NOT ON FILE'
         SELECT E
         GOTO TOP
         DO WHILE .NOT. EOF()
            IF MDIV_CODE = DIV_CODE
               MDIV_NAME = DIV_NAME
               GOTO BOTTOM
            ENDIF
            SKIP
         ENDDO
         
         SELECT A
         IF MPROD <> SPACE(4)
            IF MPROD <> PROD_DESC
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         IF MFREEZER <> SPACE(40)
            IF FREEZ_LOC <> MFREEZER
               SKIP
               LOOP
            ENDIF
         ENDIF
         MMATCH = .F.
         I = 1
         DO WHILE I <= 14 .AND. .NOT. MMATCH
            MI = SUBSTR(STR(I+100,3),2)
            IF SUBSTR(DTOC(ANIV_DATE),4,2) = MDAY&MI
               MMATCH = .T.
            ENDIF
            I = I + 1
         ENDDO
         IF .NOT. MMATCH
            SKIP
            LOOP
         ENDIF
         
         MPRT_DIV = .T.
         SELECT A
         DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' ' .AND. DIV_CODE = MDIV_CODE
            MSV_PROD = PROD_DESC
            MPROD_LBS = 0
            MPROD_DLR = 0
            MPROD_CASE = 0
            DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' ' .AND. DIV_CODE = MDIV_CODE .AND. MSV_PROD = PROD_DESC
               IF MPROD <> SPACE(4)
                  IF MPROD <> PROD_DESC
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               
               IF MFREEZER <> SPACE(40)
                  IF FREEZ_LOC <> MFREEZER
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               
               MMATCH = .F.
               I = 1
               DO WHILE I <= 14 .AND. .NOT. MMATCH
                  MI = SUBSTR(STR(I+100,3),2)
                  IF SUBSTR(DTOC(ANIV_DATE),4,2) = MDAY&MI
                     MMATCH = .T.
                  ENDIF
                  I = I + 1
               ENDDO
               IF .NOT. MMATCH
                  SKIP
                  LOOP
               ENDIF
               
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT 
                  ENDIF
                  
                  MPAGE_NO = MPAGE_NO + 1
                  
                  @ 1,59 SAY MCOMPANY
                  @ 2,1 SAY 'Page'
                  @ 2,06 say mpage_no picture '99'
                  @ 2,50 SAY '  ANNIVERSARY SUMMARY AS OF ' + DTOC(MDATE)
                  @ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
                  @ 4,1 SAY '  DATE    LOCATION              LOT #    I #   SALES   SUPPLIER            PROD SIZE PRODUCT           PACK  CASES      POUNDS     PRICE   COST/LB    TOTAL COST'
                  @ 4,01 SAY REPLICATE('_',160)
                  MLINE = 6
               ENDIF
               IF MPRT_DIV
                  @ MLINE,1 SAY 'DIVISION: ' + MDIV_NAME
                  @ MLINE,1 SAY REPLICATE('_',42)
                  MPRT_DIV = .F.
                  MLINE = MLINE + 2
               ENDIF
               IF MRPT_PICK = 'D'
                  @ MLINE,1 SAY ANIV_DATE
                  @ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
                  @ MLINE,33 SAY LOT_NBR
                  **@ MLINE,42 SAY STR(I_NBR,5)  
                  *** GO FIND THE SALESPERSON NAME
                  IF SALESMAN <> '  '
                     SELECT D
                     SEEK A->SALESMAN
                     IF .NOT. EOF()
                        @ MLINE,48 SAY SUBSTR(NAME,1,7)
                     ELSE
                        @ MLINE,48 SAY A->SALESMAN
                     ENDIF
                     SELECT A
                  ELSE
                     @ MLINE,48 SAY BROK_NAME
                  ENDIF
                  @ MLINE,56 SAY SUPPLIER
                  @ MLINE,76 SAY PROD_SIZE
                  *IF DTOC(PAID_DATE) = '  /  /  '
                  *   @ MLINE,79 SAY 'NO'
                  *ELSE
                  *   @ MLINE,76 SAY PAID_DATE
                  *ENDIF
               ENDIF
               SELECT C
               SEEK 'R' + A->PROD_DESC
               IF EOF()       
                  MDESC = A->PROD_DESC
               ELSE
                  MDESC = SUBSTR(DESC,1,15)
               ENDIF
               IF MRPT_PICK = 'D'
                  @ MLINE,86 SAY SUBSTR(MDESC,1,15)
               ENDIF
               SELECT A
               MCASE_LEFT = 0
               MVAL_LEFT = 0
               MLBS_LEFT = 0
               DO CALC_CUR
               IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
                  MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
               ELSE
                  MPRO_PRI = 0
                  MVAL_LEFT = 0
               ENDIF
               IF MRPT_PICK = 'D'
                  @ MLINE,104 SAY BOX_SIZE
                  @ MLINE,111 SAY MCASE_LEFT PICTURE '9999'
                  @ MLINE,117 SAY MLBS_LEFT  PICTURE '999,999.99'
                  @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
                  @ MLINE,140 SAY MPRO_PRI   PICTURE '99.9999'
                  @ MLINE,149 SAY MVAL_LEFT  PICTURE '9,999,999.99'
               ENDIF
               MPROD_LBS = MPROD_LBS + LBS_LEFT
               MPROD_DLR = MPROD_DLR + MVAL_LEFT
               MPROD_CASE = MPROD_CASE + MCASE_LEFT
               IF MRPT_PICK = 'D'
                  MLINE = MLINE + 2
               ENDIF
               SKIP
            ENDDO
            *@ MLINE,5 SAY TRIM(MDESC) + ' TOTAL:' 
            *@ MLINE,5 SAY REPLICATE('_',22)
            *@ MLINE,109 SAY MPROD_CASE PICTURE '999999'
            *@ MLINE,116 SAY MPROD_LBS  PICTURE '9,999,999.9'
            *@ MLINE,149 SAY MPROD_DLR  PICTURE '9,999,999.99'
            *@ MLINE,109 SAY REPLICATE('_',52)
            *MLINE = MLINE + 3
            MTOT_DLBS = MTOT_DLBS + MPROD_LBS
            MTOT_DVAL = MTOT_DVAL + MPROD_DLR
            MTOT_DCAS = MTOT_DCAS + MPROD_CASE
         ENDDO
         
         MTOT_LBS = MTOT_LBS + MTOT_DLBS
         MTOT_VAL = MTOT_VAL + MTOT_DVAL
         MTOT_CASE = MTOT_CASE + MTOT_DCAS
         *@ MLINE,1 SAY 'DIVISION TOTALS:'
         *@ MLINE,109 SAY MTOT_DCAS PICTURE '999999'
         *@ MLINE,115 SAY MTOT_DLBS PICTURE '99,999,999.9'
         *@ MLINE,148 SAY MTOT_DVAL PICTURE '99,999,999.99'
         *MLINE = MLINE + 3
      ENDDO
      
      IF MLINE <> 99     
         *MLINE = MLINE + 1
         *@ MLINE,1 SAY 'GRAND TOTALS:'
         *@ MLINE,109 SAY MTOT_CASE  PICTURE '999999'
         *@ MLINE,115 SAY MTOT_LBS PICTURE '99,999,999.9'
         *@ MLINE,148 SAY MTOT_VAL PICTURE '99,999,999.99'
         
         @ MLINE+1,1 SAY ' '
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      MRPT_SEL   = ' '
      
   CASE MRPT_SEL = '4'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT INVENTORY ACTIVITY MONTHLY CLOSING REPORT'
      @ 2,0 to 25,79
      MPROD    = SPACE(4)
      MDIV     = SPACE(2)
      MFREEZER = SPACE(40)
      MI_NBR   = 0         
      MIN_OUT  = 'BOTH'
      MIN_TOT  = 0
      MOUT_TOT = 0
      STORE CTOD('') TO MBEG_DATE, MEND_DATE
      MRPT_PICK = '1'
      MTOT_ONLY = 'N'
      @ 8,3 SAY  'Beginning Activity Date: ' GET MBEG_DATE
      @ 10,3 SAY '   Ending Activity Date: ' GET MEND_DATE
      @ 12,3 SAY '  Optionl Division Code: ' GET MDIV PICTURE '@!'
      @ 14,3 SAY 'Print totals only (Y/N): ' get mtot_only picture '@!'
      READ
      IF MRPT_PICK = ' '
         LOOP
      ENDIF
      IF MTOT_ONLY <> 'N'
         MTOT_ONLY = 'Y'
      ENDIF
      
      @ 4,3 CLEAR TO 22,78
      
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      IF MIN_OUT = '    '
         MIN_OUT = 'BOTH'
      ENDIF
      ** IF DATES ARE LEFT BLANK, PICK UP ALL ACTIVITY
      ** BY FORMATTING WITH REAL OLD AND CURRENT BEGIN/END
      IF DTOC(MBEG_DATE) = '  /  /  '
         MBEG_DATE = CTOD('01/01/90')
      ENDIF
      IF DTOC(MEND_DATE) = '  /  /  '
         MEND_DATE = DATE()
      ENDIF
      MPAGE_LEN = 44
      MPAGE_NO = 0
      MLINE = 99
      
      @ 21,16 SAY SPACE(34)
      @ 21,16 SAY 'PROCESSING............'
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      SELECT E
      DO FOX_USE WITH "&MMASTDBF.DIVISION", .F.
      
      SELECT D 
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      SELECT B
      USE INVNTEMP EXCLUSIVE
      DELETE ALL
      PACK
      DO FOX_USE WITH "INVNTEMP", .F.
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNANIV", .F.
      
      IF MFREEZER <> SPACE(40)
         MFREEZER = TRIM(MFREEZER)
      ENDIF
      IF MIN_OUT = 'IN' .OR. MIN_OUT = 'BOTH'
         
         IF VAL(SUBSTR(DTOC(MBEG_DATE),7)) >= VAL(SUBSTR(DTOC(ANIV_DATE),7))
            SEEK SUBSTR(DTOC(MBEG_DATE),7)
         ENDIF
         
         ** FIRST GET ALL THE SHIPMENTS INTO INVENTORY THAT
         ** FALL INTO THIS DATE RANGE - THESE COME FROM THE "INVEN" FILE
         DO WHILE .NOT. EOF() .AND. ANIV_DATE < MBEG_DATE
            SKIP
         ENDDO
         DO WHILE .NOT. EOF() .AND. ANIV_DATE <= MEND_DATE
            
            IF LBS = 0 .OR. CASE_CNT = 0
               SKIP
               LOOP
            ENDIF
            
            ** CHECK DIVISION CODE MATCH
            IF MDIV <> SPACE(2)
               IF MDIV <> DIV_CODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            ** CHECK PRODUCT DESCRIPTION MATCH
            IF MPROD <> SPACE(4)
               IF MPROD <> PROD_DESC
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            ** CHECK FREEZER MATCH
            IF MFREEZER <> '  '
               IF TRIM(FREEZ_LOC) <> MFREEZER
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK I NBR MATCH
            IF MI_NBR <> 0
               IF MI_NBR <> I_NBR
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE SALESMAN    WITH A->SALESMAN
            REPLACE PO_NBR      WITH A->PO_NBR
            REPLACE PO_SUFFIX   WITH A->PO_SUFFIX
            REPLACE FREEZ_LOC   WITH A->FREEZ_LOC
            REPLACE I_NBR       WITH A->I_NBR
            REPLACE DIV_CODE    WITH A->DIV_CODE
            REPLACE PROD_DESC   WITH A->PROD_DESC
            REPLACE BOX_SIZE    WITH A->BOX_SIZE
            REPLACE LOT_NBR     WITH A->LOT_NBR
            REPLACE SUPPLIER    WITH A->SUPPLIER
            REPLACE LBS         WITH A->LBS
            REPLACE PRI_LB      WITH A->PRI_LB
            REPLACE CASE_CNT    WITH A->CASE_CNT
            REPLACE VALUE       WITH A->VALUE
            REPLACE ACT_DATE    WITH A->ANIV_DATE
            REPLACE PACKED      WITH A->PACKED
            REPLACE ACT_CODE    WITH 'I'
            
            UNLOCK
            SELECT A
            SKIP
         ENDDO
      ENDIF
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
      
      SELECT F
      DO FOX_USE WITH "INVN_DTL INDEX DTL_DATE", .F.
      
      *** GET ALL THE OUT ACTIVITY FROM THE DETAIL FILE
      *** FOR THE SPECIFIED TIME FRAME
      
      IF MIN_OUT = 'OUT' .OR. MIN_OUT = 'BOTH'
         IF VAL(SUBSTR(DTOC(MBEG_DATE),7)) >= VAL(SUBSTR(DTOC(ACT_DATE),7))
            SEEK SUBSTR(DTOC(MBEG_DATE),7)
         ENDIF
         ** FIRST GET ALL THE SHIPMENTS OUT OF INVENTORY THAT
         ** FALL INTO THIS DATE RANGE
         DO WHILE .NOT. EOF() .AND. ACT_DATE <  MBEG_DATE
            SKIP
         ENDDO
         DO WHILE .NOT. EOF() .AND. ACT_DATE <= MEND_DATE
            *** IF THIS IS NOT A SHIPMENT RECORD, SKIP IT
            IF ACT_CODE <> 'S'
               SKIP
               LOOP
            ENDIF
            
            IF SHIP_LBS = 0 .OR. SHIP_CASE = 0
               SKIP
               LOOP
            ENDIF
            ** CHECK I NBR MATCH
            IF MI_NBR <> 0
               IF MI_NBR <> I_NBR
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT A
            SEEK F->FREEZ_LOC + F->LOT_NBR
            ** CHECK PRODUCT DESCRIPTION MATCH
            IF MPROD <> SPACE(4)
               IF MPROD <> PROD_DESC
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK DIVISION CODE MATCH
            IF MDIV <> SPACE(2)
               IF MDIV <> DIV_CODE
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK FREEZER MATCH
            IF MFREEZER <> '  '
               IF TRIM(FREEZ_LOC) <> MFREEZER
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE FREEZ_LOC   WITH A->FREEZ_LOC
            REPLACE I_NBR       WITH A->I_NBR
            REPLACE DIV_CODE    WITH A->DIV_CODE
            REPLACE PROD_DESC   WITH A->PROD_DESC
            REPLACE BOX_SIZE    WITH A->BOX_SIZE
            REPLACE LOT_NBR     WITH A->LOT_NBR
            REPLACE SUPPLIER    WITH A->SUPPLIER
            REPLACE PACKED      WITH A->PACKED
            *** GET THIS INFO FROM DETAIL RECORD
            REPLACE SALESMAN    WITH F->SALESMAN
            REPLACE PO_NBR      WITH F->PO_NBR
            REPLACE PO_SUFFIX   WITH F->PO_SUFFIX
            REPLACE LBS         WITH (F->SHIP_LBS * -1)
            REPLACE PRI_LB      WITH F->SHIP_PRI
            REPLACE CASE_CNT    WITH (F->SHIP_CASE * -1)
            REPLACE VALUE       WITH (F->SHIP_VAL * -1)
            REPLACE ACT_DATE    WITH F->ACT_DATE
            REPLACE ACT_CODE    WITH 'S'
            UNLOCK
            SELECT F
            SKIP
         ENDDO
      ENDIF
      
      SELECT B
      USE INVNTEMP EXCLUSIVE
      INDEX ON DIV_CODE + SALESMAN + PO_NBR + PO_SUFFIX + SUBSTR(DTOC(ACT_DATE),7) + SUBSTR(DTOC(ACT_DATE),1,5) TO INVNTEMP
      **** TO HERE
      DO FOX_USE WITH "INVNTEMP INDEX INVNTEMP", .F.
      **** ZERO OUT GRAND TOTALS ***
      MTOT_LBS = 0
      MTOT_VAL = 0
      MTOT_CAS = 0
      ***********************************
      SELECT E
      GOTO TOP
      DO WHILE .NOT. EOF()
         MDIV_NAME = DIV_NAME
         MTOT_DLBS = 0
         MTOT_DVAL = 0
         MTOT_DCAS = 0
         SELECT B
         SEEK E->DIV_CODE
         IF EOF()
            SELECT E
            SKIP
            LOOP
         ENDIF
         IF MLINE <> 99
            MLINE = 89
         ENDIF
         
         DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE
            MTOT_ALBS = 0
            MTOT_AVAL = 0
            MTOT_ACAS = 0
            MSALESMAN = SALESMAN
            MPO_NBR   = PO_NBR
            MPO_SUFFIX = PO_SUFFIX
            
            DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX     
               
               *** PRINT THE DETAIL HERE
               IF MLINE > MPAGE_LEN
                  DO ACT_HEAD
               ENDIF
               
               IF MTOT_ONLY = 'N'
                  SELECT C
                  SEEK 'R' + B->PROD_DESC 
                  IF EOF()       
                     MDESC = 'CODE: ' + B->PROD_DESC
                  ELSE
                     MDESC = SUBSTR(DESC,1,15)
                  ENDIF
                  
                  SELECT B
                  @ MLINE,1 SAY ACT_DATE
                  **@ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
                  @ MLINE,33 SAY LOT_NBR
                  **@ MLINE,42 SAY STR(I_NBR,5)  
                  @ MLINE,52 SAY SALESMAN
                  IF SALESMAN <> '  '
                     @ MLINE,54 SAY '-'
                  ENDIF
                  @ MLINE,55 SAY PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,59 SAY '-' + PO_SUFFIX
                  ENDIF
                  *@ MLINE,62 SAY SUBSTR(SUPPLIER,1,15)
                  IF ACT_CODE = 'I'
                     @ MLINE,79 SAY 'IN'
                  ELSE
                     @ MLINE,79 SAY 'OUT'     
                  ENDIF
                  *@ MLINE,86 SAY SUBSTR(MDESC,1,15)
                  **@ MLINE,97 SAY PACKED     
                  @ MLINE,110 SAY CASE_CNT  PICTURE '99999'
                  @ MLINE,117 SAY LBS       PICTURE '999,999.99'
                  @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
                  @ MLINE,149 SAY VALUE     PICTURE '9,999,999.99'
                  MTOT_ALBS = MTOT_ALBS + LBS
                  MTOT_AVAL = MTOT_AVAL + VALUE
                  MTOT_ACAS = MTOT_ACAS + CASE_CNT
                  MLAST_VAL = VALUE
                  MLINE = MLINE + 1
               ENDIF
               IF ACT_CODE = 'I'
                  MIN_TOT = MIN_TOT + VALUE
               ELSE
                  MOUT_TOT = MOUT_TOT + VALUE
               ENDIF
               SKIP
            ENDDO
            
            IF MTOT_ONLY = 'N' 
               *** DO PO TOTALS
               IF MLAST_VAL = MTOT_AVAL
                  @ MLINE-1,149 SAY REPLICATE('_',12)
                  MLINE = MLINE + 1
               ELSE       
                  @ MLINE,5 SAY 'PO TOTAL:'            
                  @ MLINE,5 SAY REPLICATE('_',09)
                  @ MLINE,109 SAY MTOT_ACAS PICTURE '999999'
                  @ MLINE,115 SAY MTOT_ALBS  PICTURE '9,999,999.99'
                  @ MLINE,149 SAY MTOT_AVAL  PICTURE '9,999,999.99'
                  @ MLINE,149 SAY REPLICATE('_',12)
                  MLINE = MLINE + 2
               ENDIF
            ENDIF
            MTOT_DLBS = MTOT_DLBS + MTOT_ALBS
            MTOT_DVAL = MTOT_DVAL + MTOT_AVAL
            MTOT_DCAS = MTOT_DCAS + MTOT_ACAS 
            MTOT_ALBS = 0
            MTOT_AVAL = 0
            MTOT_ACAS = 0
         ENDDO
         IF MTOT_ONLY = 'N'
            *** DO DIVISION TOTALS
            IF MLINE > MPAGE_LEN
               DO ACT_HEAD
            ENDIF
            @ MLINE,5 SAY 'DIV.-' + TRIM(MDIV_NAME) + ' TOTALS: ' 
            @ MLINE,109 SAY MTOT_DCAS PICTURE '999999'
            @ MLINE,115 SAY MTOT_DLBS  PICTURE '9,999,999.99'
            @ MLINE,149 SAY MTOT_DVAL  PICTURE '9,999,999.99'
            MLINE = MLINE + 3
            @ MLINE,05 SAY REPLICATE('*',156)
            MTOT_LBS = MTOT_LBS + MTOT_DLBS
            MTOT_VAL = MTOT_VAL + MTOT_DVAL
            MTOT_CAS = MTOT_CAS + MTOT_DCAS 
            MLINE = MLINE + 3
            MTOT_DLBS = 0
            MTOT_DVAL = 0
            MTOT_DCAS = 0
         ENDIF
         SELECT E
         SKIP
      ENDDO
      IF MLINE <> 99     
         IF MLINE > MPAGE_LEN
            DO ACT_HEAD
         ENDIF
         MLINE = MLINE + 1
         @ MLINE,1 SAY 'GRAND TOTALS:'
         @ MLINE,109 SAY MTOT_CAS  PICTURE '999999'
         @ MLINE,114 SAY MTOT_LBS PICTURE '99,999,999.99'
         @ MLINE,148 SAY MTOT_VAL PICTURE '99,999,999.99'
         MLINE = MLINE + 3
         @ MLINE,1 SAY 'GRAND TOTALS $ IN: '  
         @ MLINE,22 SAY MIN_TOT PICTURE '99,999,999.99'
         MLINE = MLINE + 1
         @ MLINE,1 SAY 'GRAND TOTALS $ OUT: '  
         @ MLINE,22 SAY MOUT_TOT PICTURE '99,999,999.99'
         
         @ MLINE+1,1 SAY ' '
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      CLOSE DATA
      MRPT_SEL   = ' '
      
   CASE MRPT_SEL = '5' 
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT DETAILS/TOTAL LBS/DOLLARS USING CUTOFF DATE'
      @ 2,0 to 25,79
      MDIV  = SPACE(2)
      MFREEZER = SPACE(40)
      MCUTOFF = CTOD('')
      MTOT_DET = 'T'     
      @ 5,3 say '       Enter Activity Cutoff Date: ' GET MCUTOFF
      @ 7,3 SAY '     Enter Optional Division Code: ' GET MDIV PICTURE '@!'
      @ 09,3 SAY '      Enter Optional Freezer Name: ' GET MFREEZER PICTURE '@!'
      @ 11,3 SAY '  Print Totals (T) or Details (D): ' GET MTOT_DET PICTURE '@!'
      READ
      @ 5,3 CLEAR TO 11,78
      
      MPRT_ACT = 'C'
      
      @ 20,01 CLEAR TO 20,78 
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      MPAGE_LEN = 44
      
      MPAGE_NO = 0
      MLINE = 99
      
      @ 21,16 SAY SPACE(34)
      @ 21,16 SAY 'PROCESSING............'
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      SELECT C
      USE INVNTMP3 EXCLUSIVE               
      DELETE ALL
      PACK
      INDEX ON FREEZ_LOC + LOT_NBR TO INVNTMP3
      DO FOX_USE WITH "INVNTMP3 INDEX INVNTMP3", .F.
      DO FILELOCK
      
      SELECT B
      DO FOX_USE WITH "INVN_DTL INDEX DTL_DATE", .F.
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNSOLD", .F.
      SEEK ' '
      DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' '
         IF ANIV_DATE > MCUTOFF
            SKIP
            LOOP
         ENDIF
         SELECT C
         APPEND BLANK
         REPLACE LOT_NBR WITH A->LOT_NBR
         REPLACE DIV_CODE  WITH A->DIV_CODE
         REPLACE FREEZ_LOC WITH A->FREEZ_LOC
         REPLACE BROK_NAME WITH A->BROK_NAME
         REPLACE I_NBR     WITH A->I_NBR
         
         REPLACE RSUPCODE WITH A->RSUPCODE
         REPLACE SUPPLIER WITH A->SUPPLIER
         REPLACE ANIV_DATE WITH A->ANIV_DATE
         REPLACE SHIP_DATE WITH A->SHIP_DATE
         
         REPLACE PROD_SIZE WITH A->PROD_SIZE
         REPLACE PROD_DESC WITH A->PROD_DESC
         REPLACE BOX_SIZE    WITH A->BOX_SIZE
         REPLACE CASE_LEFT WITH A->CASE_LEFT
         REPLACE LBS_LEFT  WITH A->LBS_LEFT
         REPLACE PRI_LB    WITH A->PRI_LB
         REPLACE CASE_CNT  WITH A->CASE_CNT
         REPLACE PACKED    WITH A->PACKED
         SELECT A
         SKIP
      ENDDO
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
      
      MTRAN_YR = SUBSTR(DTOC(MCUTOFF),7)
      MTRAN_MO = SUBSTR(DTOC(MCUTOFF),1,2)
      SELECT B
      SEEK MTRAN_YR+MTRAN_MO
      IF EOF()
         SEEK MTRAN_YR
         IF EOF()
            GOTO TOP 
         ENDIF 
      ENDIF
      
      DO WHILE .NOT. EOF()
         IF ACT_DATE <= MCUTOFF
            SKIP
            LOOP
         ENDIF
         IF ACT_CODE <> 'S'
            SKIP
            LOOP
         ENDIF
         
         SELECT A
         SEEK B->FREEZ_LOC + B->LOT_NBR
         
         IF MDIV <> SPACE(2)
            IF DIV_CODE <> MDIV
               SELECT B
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         IF EOF() .OR. ANIV_DATE > MCUTOFF
            SELECT B
            SKIP
            LOOP
         ENDIF
         SELECT C
         SEEK B->FREEZ_LOC + B->LOT_NBR        
         DO CASE
         CASE EOF()     
            APPEND BLANK
            REPLACE LOT_NBR   WITH B->LOT_NBR
            REPLACE I_NBR     WITH B->I_NBR
            REPLACE CASE_LEFT WITH B->SHIP_CASE      
            REPLACE LBS_LEFT  WITH B->SHIP_LBS       
            REPLACE FREEZ_LOC WITH B->FREEZ_LOC
            SELECT A
            SEEK B->FREEZ_LOC + B->LOT_NBR        
            SELECT C
            REPLACE DIV_CODE  WITH A->DIV_CODE
            REPLACE BROK_NAME WITH A->BROK_NAME
            REPLACE RSUPCODE WITH A->RSUPCODE
            REPLACE SUPPLIER WITH A->SUPPLIER
            REPLACE ANIV_DATE WITH A->ANIV_DATE
            REPLACE SHIP_DATE WITH A->SHIP_DATE
            REPLACE PROD_SIZE WITH A->PROD_SIZE
            REPLACE PROD_DESC WITH A->PROD_DESC
            REPLACE BOX_SIZE    WITH A->BOX_SIZE
            REPLACE PRI_LB    WITH A->PRI_LB
            REPLACE CASE_CNT  WITH A->CASE_CNT
            REPLACE PACKED    WITH A->PACKED
         OTHERWISE
            REPLACE CASE_LEFT WITH CASE_LEFT +  B->SHIP_CASE 
            REPLACE LBS_LEFT  WITH LBS_LEFT +  B->SHIP_LBS 
         ENDCASE
         SELECT B
         SKIP
      ENDDO
      
      CLOSE DATA
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      SELECT A
      USE INVNTMP3 EXCLUSIVE
      INDEX ON FREEZ_LOC + LOT_NBR TO INVNTMP3
      USE
      
      DO FOX_USE WITH "INVNTMP3 INDEX INVNTMP3", .F.
      
      **** HERE
      MTOT_LBS = 0
      MTOT_VAL = 0
      MTOT_CASE = 0
      IF MFREEZER <> SPACE(40)
         MFREEZER = TRIM(MFREEZER)
      ENDIF
      DO WHILE .NOT. EOF()
         IF MDIV <> SPACE(2)
            IF MDIV <> DIV_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
         IF MFREEZER <> SPACE(40)
            IF FREEZ_LOC <> MFREEZER
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT 
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,59 SAY MCOMPANY
            @ 2,1 SAY 'Page'
            @ 2,06 say mpage_no picture '99'
            @ 2,50 SAY '    INVENTORY REPORT  AS OF ' + DTOC(MCUTOFF)
            @ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
            **@ 3,50 SAY '    ESTIMATED STORAGE @ .0125 / LB'
            **@ 5,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK  CASES        UNITS  PUR PRI  PUR+STOR   COST W/STOR'
            @ 5,1 SAY '                                                                                                             CASES        UNITS'
            @ 6,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK   LEFT         LEFT  PUR PRI           PURCHASE COST'
            @ 6,01 SAY REPLICATE('_',160)
            MLINE = 8
         ENDIF
         SELECT C
         SEEK 'R' + A->PROD_DESC
         IF EOF()       
            MDESC = A->PROD_DESC
         ELSE
            MDESC = SUBSTR(DESC,1,15)
         ENDIF
         
         SEEK 'S' + A->PACKED
         MBOX_SZ = BOX_SZ
         IF SUBSTR(A->PACKED,1,1) = 'B'
            MLBS_CALC = A->LBS_LEFT * MBOX_SZ
            MTOT_LBS = MTOT_LBS + MLBS_CALC
         ELSE
            MTOT_LBS = MTOT_LBS + A->LBS_LEFT
         ENDIF
         
         SELECT A
         IF MTOT_DET = 'D'
            @ MLINE,1 SAY ANIV_DATE
            @ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
            @ MLINE,33 SAY LOT_NBR
            **@ MLINE,42 SAY STR(I_NBR,5)  
            
            ***@ MLINE,49 SAY SUBSTR(SUPPLIER,1,16)
            IF SUBSTR(A->PACKED,1,1) = 'B' 
               @ MLINE,49 SAY MLBS_CALC PICTURE '9,999,999.99'
            ELSE
               @ MLINE,49 SAY LBS_LEFT  PICTURE '9,999,999.99'
            ENDIF
            @ MLINE,69 SAY PROD_DESC
            @ MLINE,76 SAY PROD_SIZE
         ENDIF
         
         IF MTOT_DET = 'D'
            @ MLINE,86 SAY SUBSTR(MDESC,1,15)
            @ MLINE,104 SAY MBOX_SZ PICTURE '99.9'
            @ MLINE,111 SAY CASE_LEFT PICTURE '9999'
            @ MLINE,118 SAY LBS_LEFT  PICTURE '999,999.99'
            @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
         ENDIF
         
         MTOT_CASE = MTOT_CASE + CASE_LEFT
         MVAL1  = PRI_LB * LBS_LEFT
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
         MTOT_VAL = MTOT_VAL + MVAL_LEFT
         
         IF MTOT_DET = 'D'
            @ MLINE,149 SAY MVAL_LEFT PICTURE '9,999,999.99'
            MLINE = MLINE + 2
         ENDIF
         SKIP
      ENDDO
      
      IF MLINE <> 99     
         MLINE = MLINE + 1
         @ MLINE,1 SAY 'GRAND TOTAL DOLLARS:'
         *@ MLINE,109 SAY MTOT_CASE  PICTURE '999999'
         *@ MLINE,115 SAY MTOT_LBS PICTURE '99,999,999.99'
         @ MLINE,148 SAY MTOT_VAL PICTURE '99,999,999.99'
         
         MLINE = MLINE + 3
         @ MLINE,1 SAY 'GRAND TOTAL POUNDS:'
         @ MLINE,115 SAY MTOT_LBS PICTURE '99,999,999.99'
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      MRPT_SEL   = ' '
      
   CASE MRPT_SEL = '6'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT ACTIVITY REPORT FOR OPTIONAL SUPPLIER'
      @ 2,0 to 25,79
      MPROD    = SPACE(4)
      MDIV     = SPACE(2)
      MFREEZER = SPACE(40)
      MI_NBR   = 0         
      MIN_OUT  = '    '
      MSUP_NAME = SPACE(40)
      STORE CTOD('') TO MBEG_DATE, MEND_DATE
      MRPT_PICK = '1'
      @ 8,3 SAY '         Beginning Activity Date: ' GET MBEG_DATE
      @ 10,3 SAY '            Ending Activity Date: ' GET MEND_DATE
      @ 12,3 SAY '      Select Shipments IN or OUT: ' GET MIN_OUT PICTURE '@!'
      @ 14,3 SAY '         Enter Optional I Number: ' GET MI_NBR PICTURE '#####'
      @ 16,3 SAY '    Enter Optional Division Code: ' GET MDIV PICTURE '@!'
      @ 18,3 SAY '     Enter Optional Product Code: ' GET MPROD  PICTURE '@!'
      @ 20,3 SAY '     Enter Optional Freezer Name: ' GET MFREEZER PICTURE '@!'
      @ 22,3 say '    Enter Optional Supplier Name: ' GET MSUP_NAME PICTURE '@!'
      READ
      IF MRPT_PICK = ' '
         LOOP
      ENDIF
      
      @ 4,3 CLEAR TO 22,78
      
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      IF MIN_OUT = '    '
         MIN_OUT = 'OUT '
      ENDIF
      ** IF DATES ARE LEFT BLANK, PICK UP ALL ACTIVITY
      ** BY FORMATTING WITH REAL OLD AND CURRENT BEGIN/END
      IF DTOC(MBEG_DATE) = '  /  /  '
         MBEG_DATE = CTOD('01/01/90')
      ENDIF
      IF DTOC(MEND_DATE) = '  /  /  '
         MEND_DATE = DATE()
      ENDIF
      MPAGE_LEN = 44
      MPAGE_NO = 0
      MLINE = 99
      
      @ 21,16 SAY SPACE(34)
      @ 21,16 SAY 'PROCESSING............'
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      SELECT E
      DO FOX_USE WITH "&MMASTDBF.DIVISION", .F.
      
      SELECT D 
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      SELECT B
      USE INVNTEMP EXCLUSIVE
      DELETE ALL
      PACK
      DO FOX_USE WITH "INVNTEMP", .F.
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNANIV", .F.
      
      IF MFREEZER <> SPACE(40)
         MFREEZER = TRIM(MFREEZER)
      ENDIF
      
      IF MSUP_NAME <> SPACE(40)
         MSUP_NAME = TRIM(MSUP_NAME)
      ENDIF
      
      IF MIN_OUT = 'IN' .OR. MIN_OUT = 'BOTH'
         
         IF VAL(SUBSTR(DTOC(MBEG_DATE),7)) >= VAL(SUBSTR(DTOC(ANIV_DATE),7))
            SEEK SUBSTR(DTOC(MBEG_DATE),7)
         ENDIF
         
         ** FIRST GET ALL THE SHIPMENTS INTO INVENTORY THAT
         ** FALL INTO THIS DATE RANGE - THESE COME FROM THE "INVEN" FILE
         DO WHILE .NOT. EOF() .AND. ANIV_DATE < MBEG_DATE
            SKIP
         ENDDO
         DO WHILE .NOT. EOF() .AND. ANIV_DATE <= MEND_DATE
            
            IF LBS = 0 .OR. CASE_CNT = 0
               SKIP
               LOOP
            ENDIF
            
            ** CHECK DIVISION CODE MATCH
            IF MDIV <> SPACE(2)
               IF MDIV <> DIV_CODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            IF MSUP_NAME <> SPACE(40)
               IF SUPPLIER <> MSUP_NAME
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK PRODUCT DESCRIPTION MATCH
            IF MPROD <> SPACE(4)
               IF MPROD <> PROD_DESC
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            ** CHECK FREEZER MATCH
            IF MFREEZER <> '  '
               IF TRIM(FREEZ_LOC) <> MFREEZER
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK I NBR MATCH
            IF MI_NBR <> 0
               IF MI_NBR <> I_NBR
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE SALESMAN    WITH A->SALESMAN
            REPLACE PO_NBR      WITH A->PO_NBR
            REPLACE PO_SUFFIX   WITH A->PO_SUFFIX
            REPLACE FREEZ_LOC   WITH A->FREEZ_LOC
            REPLACE I_NBR       WITH A->I_NBR
            REPLACE DIV_CODE    WITH A->DIV_CODE
            REPLACE PROD_DESC   WITH A->PROD_DESC
            REPLACE BOX_SIZE    WITH A->BOX_SIZE
            REPLACE LOT_NBR     WITH A->LOT_NBR
            REPLACE SUPPLIER    WITH A->SUPPLIER
            REPLACE LBS         WITH A->LBS
            REPLACE PRI_LB      WITH A->PRI_LB
            REPLACE CASE_CNT    WITH A->CASE_CNT
            REPLACE VALUE       WITH A->VALUE
            REPLACE ACT_DATE    WITH A->ANIV_DATE
            REPLACE ACT_CODE    WITH 'I'
            UNLOCK
            SELECT A
            SKIP
         ENDDO
      ENDIF
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
      
      SELECT F
      DO FOX_USE WITH "INVN_DTL INDEX DTL_DATE", .F.
      
      *** GET ALL THE OUT ACTIVITY FROM THE DETAIL FILE
      *** FOR THE SPECIFIED TIME FRAME
      
      IF MIN_OUT = 'OUT' .OR. MIN_OUT = 'BOTH'
         IF VAL(SUBSTR(DTOC(MBEG_DATE),7)) >= VAL(SUBSTR(DTOC(ACT_DATE),7))
            SEEK SUBSTR(DTOC(MBEG_DATE),7)
         ENDIF
         ** FIRST GET ALL THE SHIPMENTS OUT OF INVENTORY THAT
         ** FALL INTO THIS DATE RANGE
         DO WHILE .NOT. EOF() .AND. ACT_DATE <  MBEG_DATE
            SKIP
         ENDDO
         DO WHILE .NOT. EOF() .AND. ACT_DATE <= MEND_DATE
            *** IF THIS IS NOT A SHIPMENT RECORD, SKIP IT
            IF ACT_CODE <> 'S'
               SKIP
               LOOP
            ENDIF
            
            IF SHIP_LBS = 0 .OR. SHIP_CASE = 0
               SKIP
               LOOP
            ENDIF
            ** CHECK I NBR MATCH
            IF MI_NBR <> 0
               IF MI_NBR <> I_NBR
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT A
            SEEK F->FREEZ_LOC + F->LOT_NBR
            ** CHECK PRODUCT DESCRIPTION MATCH
            IF MPROD <> SPACE(4)
               IF MPROD <> PROD_DESC
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK DIVISION CODE MATCH
            IF MDIV <> SPACE(2)
               IF MDIV <> DIV_CODE
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            IF MSUP_NAME <> SPACE(40)
               IF SUPPLIER <> MSUP_NAME
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK FREEZER MATCH
            IF MFREEZER <> '  '
               IF TRIM(FREEZ_LOC) <> MFREEZER
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE FREEZ_LOC   WITH A->FREEZ_LOC
            REPLACE I_NBR       WITH A->I_NBR
            REPLACE DIV_CODE    WITH A->DIV_CODE
            REPLACE PROD_DESC   WITH A->PROD_DESC
            REPLACE BOX_SIZE    WITH A->BOX_SIZE
            REPLACE LOT_NBR     WITH A->LOT_NBR
            REPLACE SUPPLIER    WITH A->SUPPLIER
            REPLACE PRI_LB      WITH A->PRI_LB
            
            *** GET THIS INFO FROM DETAIL RECORD
            REPLACE SALESMAN    WITH F->SALESMAN
            REPLACE PO_NBR      WITH F->PO_NBR
            REPLACE PO_SUFFIX   WITH F->PO_SUFFIX
            REPLACE SHIP_LBS    WITH (F->SHIP_LBS)
            IF F->CUS_PRI <> 0
               REPLACE SHIP_PRI    WITH (F->CUS_PRI)       
            ELSE
               REPLACE SHIP_PRI    WITH A->PRI_LB
            ENDIF
            REPLACE CASE_CNT    WITH (F->SHIP_CASE)
            REPLACE VALUE       WITH (F->SHIP_VAL)
            REPLACE ACT_DATE    WITH F->ACT_DATE
            REPLACE ACT_CODE    WITH 'S'
            UNLOCK
            SELECT F
            SKIP
         ENDDO
      ENDIF
      
      SELECT B
      USE INVNTEMP EXCLUSIVE
      IF MRPT_PICK = '1'
         INDEX ON DIV_CODE + FREEZ_LOC + PROD_DESC + ACT_CODE + SUBSTR(DTOC(ACT_DATE),7) + SUBSTR(DTOC(ACT_DATE),1,5) TO INVNTEMP
      ELSE
         INDEX ON DIV_CODE + FREEZ_LOC + PROD_DESC + STR(I_NBR,5) TO INVNTEMP
      ENDIF
      
      DO FOX_USE WITH "INVNTEMP INDEX INVNTEMP", .F.
      DO CASE
      CASE MRPT_PICK = '1'
         **** ZERO OUT GRAND TOTALS ***
         MTOT_LBS = 0
         MTOT_VAL = 0
         MTOT_CAS = 0
         MTOT_NET = 0
         MTOT_SEL = 0
         MTOT_X   = 0
         ***********************************
         SELECT E
         GOTO TOP
         DO WHILE .NOT. EOF()
            MDIV_NAME = DIV_NAME
            MTOT_DLBS = 0
            MTOT_DVAL = 0
            MTOT_DCAS = 0
            MTOT_DNET = 0
            MTOT_DSEL = 0
            MTOT_DX   = 0
            SELECT B
            SEEK E->DIV_CODE
            IF EOF()
               SELECT E
               SKIP
               LOOP
            ENDIF
            IF MLINE <> 99
               MLINE = 89
            ENDIF
            
            DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE
               MSV_FREEZ = FREEZ_LOC
               MTOT_FLBS = 0
               MTOT_FVAL = 0
               MTOT_FCAS = 0
               MTOT_FNET = 0
               MTOT_FSEL = 0
               MTOT_FX   = 0
               DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ
                  MSV_PROD = PROD_DESC
                  MTOT_PLBS = 0
                  MTOT_PVAL = 0
                  MTOT_PCAS = 0
                  MTOT_PNET = 0
                  MTOT_PSEL = 0
                  MTOT_PX   = 0
                  SELECT C
                  SEEK 'R' + MSV_PROD     
                  IF EOF()       
                     MDESC = 'CODE: ' + MSV_PROD
                  ELSE
                     MDESC = SUBSTR(DESC,1,15)
                  ENDIF
                  SELECT B
                  DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ .AND. PROD_DESC = MSV_PROD
                     MSV_ACTCD = ACT_CODE
                     MTOT_ALBS = 0
                     MTOT_AVAL = 0
                     MTOT_ACAS = 0
                     MTOT_ANET = 0
                     MTOT_ASEL = 0
                     MTOT_AX   = 0
                     DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ .AND. PROD_DESC = MSV_PROD .AND. MSV_ACTCD = ACT_CODE
                        *** PRINT THE DETAIL HERE
                        IF MLINE > MPAGE_LEN
                           DO ACT_HED1
                        ENDIF
                        
                        @ MLINE,1 SAY ACT_DATE
                        *@ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
                        @ MLINE,33-22 SAY LOT_NBR
                        **@ MLINE,42-22 SAY STR(I_NBR,5)  
                        @ MLINE,52-22 SAY SALESMAN
                        IF SALESMAN <> '  '
                           @ MLINE,54-22 SAY '-'
                        ENDIF
                        @ MLINE,55-22 SAY PO_NBR
                        IF PO_SUFFIX <> ' '
                           @ MLINE,59-22 SAY '-' + PO_SUFFIX
                        ENDIF
                        @ MLINE,62-22 SAY SUBSTR(SUPPLIER,1,15)
                        IF ACT_CODE = 'I'
                           @ MLINE,79-22 SAY 'IN'
                        ELSE
                           @ MLINE,79-22 SAY 'OUT'     
                        ENDIF
                        @ MLINE,86-22 SAY SUBSTR(MDESC,1,15)
                        @ MLINE,104-22 SAY BOX_SIZE
                        @ MLINE,110-22 SAY CASE_CNT  PICTURE '99999'
                        IF ACT_CODE = 'I'
                           @ MLINE,117-22 SAY LBS       PICTURE '999,999.99'
                           @ MLINE,130-22 SAY PRI_LB    PICTURE '99.9999'
                        ELSE
                           @ MLINE,117-22 SAY SHIP_LBS  PICTURE '999,999.99'
                           @ MLINE,130-22 SAY SHIP_PRI  PICTURE '99.9999'
                        ENDIF
                        MSELL = 0
                        IF ACT_CODE = 'I'
                           @ MLINE,149-22 SAY VALUE     PICTURE '9,999,999.99'
                        ELSE
                           MSELL = ROUND(SHIP_LBS * SHIP_PRI,2)
                           @ MLINE,149-22 SAY MSELL     PICTURE '9,999,999.99'
                        ENDIF
                        IF ACT_CODE <> 'I'
                           MPRI = SHIP_PRI - PRI_LB
                           MNET = ROUND(MPRI * (SHIP_LBS),2)
                           @ MLINE,141 SAY MNET PICTURE '99,999.99'
                           MTOT_ANET = MTOT_ANET + MNET
                           MTOT_ALBS = MTOT_ALBS + SHIP_LBS
                           MTOT_ASEL = MTOT_ASEL + MSELL
                        ELSE
                           MTOT_ALBS = MTOT_ALBS + LBS
                        ENDIF
                        MTOT_AVAL = MTOT_AVAL + VALUE
                        MTOT_ACAS = MTOT_ACAS + CASE_CNT
                        IF SUBSTR(BOX_SIZE,1,1) = 'B' .OR. SUBSTR(BOX_SIZE,1,1) = 'H'
                           MTOT_AX = MTOT_AX + (VAL(SUBSTR(BOX_SIZE,2)) * CASE_CNT)
                        ELSE
                           IF ACT_CODE <> 'I'
                              MTOT_AX = MTOT_AX + SHIP_LBS
                           ELSE
                              MTOT_AX = MTOT_AX + LBS
                           ENDIF
                        ENDIF
                        MLINE = MLINE + 1
                        SKIP
                     ENDDO
                     
                     *** DO ACTIVITY (INS AND OUTS) TOTALS
                     *IF MSV_ACTCD = 'I'
                     *   MTOT_WORD = ' IN: ' 
                     *ELSE
                     *   MTOT_WORD = ' OUT: ' 
                     *ENDIF
                     *MLINE = MLINE + 1
                     *@ MLINE,5 SAY TRIM(MDESC) + MTOT_WORD 
                     *@ MLINE,5 SAY REPLICATE('_',24)
                     *@ MLINE,109-22 SAY MTOT_ACAS PICTURE '999999'
                     *@ MLINE,115-22 SAY MTOT_ALBS  PICTURE '9,999,999.99'
                     *@ MLINE,149-22 SAY MTOT_AVAL  PICTURE '9,999,999.99'
                     *@ MLINE,138 SAY MTOT_ANET PICTURE '9,999,999.99'
                     *@ MLINE,109-22 SAY REPLICATE('_',63)
                     
                     MTOT_PLBS = MTOT_PLBS + MTOT_ALBS
                     MTOT_PVAL = MTOT_PVAL + MTOT_AVAL
                     MTOT_PCAS = MTOT_PCAS + MTOT_ACAS 
                     MTOT_PNET = MTOT_PNET + MTOT_ANET
                     MTOT_PSEL = MTOT_PSEL + MTOT_ASEL
                     MTOT_PX   = MTOT_PX   + MTOT_AX
                     MLINE = MLINE + 2
                     MTOT_ALBS = 0
                     MTOT_AVAL = 0
                     MTOT_ACAS = 0
                     MTOT_ANET = 0
                     MTOT_ASEL = 0
                     MTOT_AX   = 0
                  ENDDO
                  *** DO PRODUCT TOTALS
                  *** FINISH UP
                  IF MLINE > MPAGE_LEN
                     DO ACT_HED1
                  ENDIF
                  @ MLINE,5 SAY TRIM(MDESC) + ' TOTALS: ' 
                  @ MLINE,5 SAY REPLICATE('_',22)
                  @ MLINE,40 SAY 'LBS= ' + TRANSFORM(MTOT_PX, '99,999,999.9')
                  @ MLINE,109-22 SAY MTOT_PCAS PICTURE '999999'
                  @ MLINE,115-22 SAY MTOT_PLBS  PICTURE '99,999,999.9'
                  
                  IF MIN_OUT = 'IN  '
                     @ MLINE,149-22 SAY MTOT_PVAL  PICTURE '9,999,999.99'
                  ELSE
                     @ MLINE,149-22 SAY MTOT_PSEL  PICTURE '9,999,999.99'
                  ENDIF
                  @ MLINE,138 SAY MTOT_PNET PICTURE '9,999,999.99'
                  @ MLINE,109-22 SAY REPLICATE('_',11)
                  MTOT_FLBS = MTOT_FLBS + MTOT_PLBS
                  MTOT_FVAL = MTOT_FVAL + MTOT_PVAL
                  MTOT_FCAS = MTOT_FCAS + MTOT_PCAS 
                  MTOT_FNET = MTOT_FNET + MTOT_PNET
                  MTOT_FSEL = MTOT_FSEL + MTOT_PSEL
                  MTOT_FX   = MTOT_FX   + MTOT_PX
                  MLINE = MLINE + 3
                  MTOT_PLBS = 0
                  MTOT_PVAL = 0
                  MTOT_PCAS = 0
                  MTOT_PNET = 0
                  MTOT_PSEL = 0
                  MTOT_PX   = 0
               ENDDO
               *** DO FREEZER TOTALS
               IF MLINE > MPAGE_LEN
                  DO ACT_HED1
               ENDIF
               @ MLINE,5 SAY TRIM(MSV_FREEZ) + ' TOTALS: ' 
               @ MLINE,40 SAY 'LBS= ' + TRANSFORM(MTOT_FX, '99,999,999.9')
               @ MLINE,109-22 SAY MTOT_FCAS PICTURE '999999'
               @ MLINE,115-22 SAY MTOT_FLBS  PICTURE '99,999,999.9'
               IF MIN_OUT = 'IN  '
                  @ MLINE,149-22 SAY MTOT_FVAL  PICTURE '9,999,999.99'
               ELSE
                  @ MLINE,149-22 SAY MTOT_FSEL  PICTURE '9,999,999.99'
               ENDIF
               @ MLINE,138 SAY MTOT_FNET PICTURE '9,999,999.99'
               @ MLINE,05 SAY REPLICATE('_',156)
               MTOT_DLBS = MTOT_DLBS + MTOT_FLBS
               MTOT_DVAL = MTOT_DVAL + MTOT_FVAL
               MTOT_DCAS = MTOT_DCAS + MTOT_FCAS 
               MTOT_DNET = MTOT_DNET + MTOT_FNET 
               MTOT_DSEL = MTOT_DSEL + MTOT_FSEL
               MTOT_DX   = MTOT_DX   + MTOT_FX 
               MLINE = MLINE + 3
               MTOT_FLBS = 0
               MTOT_FVAL = 0
               MTOT_FCAS = 0
               MTOT_FNET = 0
               MTOT_FSEL = 0
               MTOT_FX   = 0
            ENDDO
            *** DO DIVISION TOTALS
            IF MLINE > MPAGE_LEN
               DO ACT_HED1
            ENDIF
            
            @ MLINE,5 SAY 'DIV.-' + TRIM(SUBSTR(MDIV_NAME,1,20)) + ' TOTALS: ' 
            @ MLINE,40 SAY 'LBS= ' + TRANSFORM(MTOT_DX, '99,999,999.9')
            @ MLINE,109-22 SAY MTOT_DCAS PICTURE '999999'
            @ MLINE,115-22 SAY MTOT_DLBS  PICTURE '9,999,999.99'
            IF MIN_OUT = 'IN  '
               @ MLINE,149-22 SAY MTOT_DVAL  PICTURE '9,999,999.99'
            ELSE
               @ MLINE,149-22 SAY MTOT_DSEL  PICTURE '9,999,999.99'
            ENDIF
            @ MLINE,138 SAY MTOT_DNET PICTURE '9,999,999.99'
            MLINE = MLINE + 1
            @ MLINE,05 SAY REPLICATE('*',156)
            MTOT_LBS = MTOT_LBS + MTOT_DLBS
            MTOT_VAL = MTOT_VAL + MTOT_DVAL
            MTOT_CAS = MTOT_CAS + MTOT_DCAS 
            MTOT_NET = MTOT_NET + MTOT_DNET
            MTOT_SEL = MTOT_SEL + MTOT_DSEL
            MTOT_X   = MTOT_X   + MTOT_DX
            MLINE = MLINE + 3
            MTOT_DLBS = 0
            MTOT_DVAL = 0
            MTOT_DCAS = 0
            MTOT_DNET = 0
            MTOT_DSEL = 0
            MTOT_DX   = 0
            SELECT E
            SKIP
         ENDDO
      OTHERWISE
         ********************************************
         *** REPORT SELECTION # 2
         *** ALL ACTIVITY GROUPED TOGETHER BY I NBR
         ********************************************
         **** ZERO OUT GRAND TOTALS ***
         MTOT_LBS = 0
         MTOT_VAL = 0
         MTOT_CAS = 0
         MTOT_NET = 0
         ***********************************
         SELECT E
         GOTO TOP
         DO WHILE .NOT. EOF()
            MDIV_NAME = DIV_NAME
            MTOT_DLBS = 0
            MTOT_DVAL = 0
            MTOT_DCAS = 0
            SELECT B
            SEEK E->DIV_CODE
            IF EOF()
               SELECT E
               SKIP
               LOOP
            ENDIF
            IF MLINE <> 99
               MLINE = 89
            ENDIF
            
            DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE
               MSV_FREEZ = FREEZ_LOC
               MTOT_FLBS = 0
               MTOT_FVAL = 0
               MTOT_FCAS = 0
               DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ
                  MSV_PROD = PROD_DESC
                  MTOT_PLBS = 0
                  MTOT_PVAL = 0
                  MTOT_PCAS = 0
                  SELECT C
                  SEEK 'R' + MSV_PROD     
                  IF EOF()       
                     MDESC = 'CODE: ' + MSV_PROD
                  ELSE
                     MDESC = SUBSTR(DESC,1,15)
                  ENDIF
                  SELECT B
                  DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ .AND. PROD_DESC = MSV_PROD
                     MSV_I_NBR = I_NBR
                     MSV_FREEZ = FREEZ_LOC
                     MSV_LOT   = LOT_NBR
                     MTOT_ILBS = 0
                     MTOT_IVAL = 0
                     MTOT_ICAS = 0
                     DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ .AND. PROD_DESC = MSV_PROD .AND. MSV_FREEZ = FREEZ_LOC .AND. MSV_LOT = LOT_NBR
                        *** PRINT THE DETAIL HERE
                        IF MLINE > MPAGE_LEN
                           DO ACT_HEAD
                        ENDIF
                        
                        @ MLINE,1 SAY ACT_DATE
                        @ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
                        @ MLINE,33 SAY LOT_NBR
                        **@ MLINE,42 SAY STR(I_NBR,5)  
                        @ MLINE,52 SAY SALESMAN
                        IF SALESMAN <> '  '
                           @ MLINE,54 SAY '-'
                        ENDIF
                        @ MLINE,55 SAY PO_NBR
                        IF PO_SUFFIX <> ' '
                           @ MLINE,59 SAY '-' + PO_SUFFIX
                        ENDIF
                        @ MLINE,62 SAY SUBSTR(SUPPLIER,1,15)
                        IF ACT_CODE = 'I'
                           @ MLINE,79 SAY 'IN'
                        ELSE
                           @ MLINE,79 SAY 'OUT'     
                        ENDIF
                        @ MLINE,86 SAY SUBSTR(MDESC,1,15)
                        @ MLINE,104 SAY BOX_SIZE
                        @ MLINE,110 SAY CASE_CNT  PICTURE '99999'
                        @ MLINE,117 SAY LBS       PICTURE '999,999.99'
                        @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
                        @ MLINE,149 SAY VALUE     PICTURE '9,999,999.99'
                        MTOT_ILBS = MTOT_ILBS + LBS
                        MTOT_IVAL = MTOT_IVAL + VALUE
                        MTOT_ICAS = MTOT_ICAS + CASE_CNT
                        MLINE = MLINE + 1
                        SKIP
                     ENDDO
                     
                     *** DO I NUMBER TOTALS HERE
                     MLINE = MLINE + 1
                     @ MLINE,5 SAY 'I ' + STR(MSV_I_NBR,5) + ' TOTAL: '       
                     @ MLINE,5 SAY REPLICATE('_',24)
                     @ MLINE,109 SAY MTOT_ICAS PICTURE '999999'
                     @ MLINE,115 SAY MTOT_ILBS  PICTURE '9,999,999.99'
                     @ MLINE,149 SAY MTOT_IVAL  PICTURE '9,999,999.99'
                     @ MLINE,109 SAY REPLICATE('_',52)
                     MTOT_PLBS = MTOT_PLBS + MTOT_ILBS
                     MTOT_PVAL = MTOT_PVAL + MTOT_IVAL
                     MTOT_PCAS = MTOT_PCAS + MTOT_ICAS 
                     MLINE = MLINE + 2
                  ENDDO
                  *** DO PRODUCT TOTALS
                  *** FINISH UP
                  IF MLINE > MPAGE_LEN
                     DO ACT_HEAD
                  ENDIF
                  @ MLINE,5 SAY TRIM(MDESC) + ' TOTALS: ' 
                  @ MLINE,5 SAY REPLICATE('_',22)
                  @ MLINE,109 SAY MTOT_PCAS PICTURE '999999'
                  @ MLINE,115 SAY MTOT_PLBS  PICTURE '9,999,999.99'
                  @ MLINE,149 SAY MTOT_PVAL  PICTURE '9,999,999.99'
                  @ MLINE,109 SAY REPLICATE('_',52)
                  MTOT_FLBS = MTOT_FLBS + MTOT_PLBS
                  MTOT_FVAL = MTOT_FVAL + MTOT_PVAL
                  MTOT_FCAS = MTOT_FCAS + MTOT_PCAS 
                  MLINE = MLINE + 3
               ENDDO
               *** DO FREEZER TOTALS
               IF MLINE > MPAGE_LEN
                  DO ACT_HEAD
               ENDIF
               @ MLINE,5 SAY TRIM(MSV_FREEZ) + ' TOTALS: ' 
               @ MLINE,109 SAY MTOT_FCAS PICTURE '999999'
               @ MLINE,115 SAY MTOT_FLBS  PICTURE '9,999,999.99'
               @ MLINE,149 SAY MTOT_FVAL  PICTURE '9,999,999.99'
               @ MLINE,05 SAY REPLICATE('_',156)
               MTOT_DLBS = MTOT_DLBS + MTOT_FLBS
               MTOT_DVAL = MTOT_DVAL + MTOT_FVAL
               MTOT_DCAS = MTOT_DCAS + MTOT_FCAS 
               MLINE = MLINE + 3
            ENDDO
            *** DO DIVISION TOTALS
            IF MLINE > MPAGE_LEN
               DO ACT_HEAD
            ENDIF
            @ MLINE,5 SAY 'DIV.-' + TRIM(MDIV_NAME) + ' TOTALS: ' 
            @ MLINE,109 SAY MTOT_DCAS PICTURE '999999'
            @ MLINE,115 SAY MTOT_DLBS  PICTURE '9,999,999.99'
            @ MLINE,149 SAY MTOT_DVAL  PICTURE '9,999,999.99'
            MLINE = MLINE + 1
            @ MLINE,05 SAY REPLICATE('*',156)
            MTOT_LBS = MTOT_LBS + MTOT_DLBS
            MTOT_VAL = MTOT_VAL + MTOT_DVAL
            MTOT_CAS = MTOT_CAS + MTOT_DCAS 
            MLINE = MLINE + 3
            SELECT E
            SKIP
         ENDDO
      ENDCASE
      IF MLINE <> 99     
         IF MLINE > MPAGE_LEN
            DO ACT_HED1
         ENDIF
         MLINE = MLINE + 1
         @ MLINE,1 SAY 'GRAND TOTALS:'
         @ MLINE,40 SAY 'LBS= ' + TRANSFORM(MTOT_X, '99,999,999.9')
         @ MLINE,109-22 SAY MTOT_CAS  PICTURE '999999'
         @ MLINE,114-22 SAY MTOT_LBS PICTURE '99,999,999.99'
         IF MIN_OUT = 'IN  '
            @ MLINE,148-22 SAY MTOT_VAL  PICTURE '99,999,999.99'
         ELSE
            @ MLINE,148-22 SAY MTOT_SEL  PICTURE '99,999,999.99'
         ENDIF
         @ MLINE,138 SAY MTOT_NET PICTURE '9,999,999.99'
         @ MLINE+1,1 SAY ' '
         IF MIN_OUT = 'OUT'
            MLINE = MLINE + 3
            @ MLINE,1 SAY 'TOTAL PURCHASE $: ' + TRANSFORM(MTOT_VAL, '9,999,999.99')
            @ MLINE+1,1 SAY ' '
         ENDIF
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      MRPT_SEL   = ' '
      
   CASE MRPT_SEL = '7'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - CALCULATE/PRINT DATE TO DATE STORAGE COSTS'
      @ 2,0 to 25,79
      
      MBEGIN = CTOD('')  
      MEND   = CTOD('')  
      MPRT_DISP = 'D'
      MDETAILS = 'N'
      MACTION = 2
      DO WHILE MACTION = 2
         @ 07,3 SAY 'Enter Starting Date: ' GET MBEGIN 
         @ 09,3 SAY '  Enter Ending Date: ' GET MEND
         @ 11,3 SAY 'Display/Print (D/P)? ' GET MPRT_DISP PICTURE '@!'
         @ 13,3 SAY 'Print Details (Y/N)? ' GET MDETAILS PICTURE '@!'
         STORE 1 TO MACTION
         @ 24,0 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2. Edit    3. Cancel Report'          
         READ
         @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
         READ
         IF MACTION = 1 .AND. MPRT_DISP = 'P'
            @ 13,3 SAY 'Print Details (Y/N)? ' GET MDETAILS
            READ       
         ENDIF
      ENDDO
      IF MACTION = 3                         
         LOOP
      ENDIF
      @ 3,1 CLEAR TO 22,78
      IF MPRT_DISP = 'P'
         MPRT_ACT = 'C'
         DO PRT_SET
         IF MPRT_ACT <> 'C'
            LOOP  
         ENDIF
         @ 21,16 SAY SPACE(34)
         @ 21,16 SAY 'PROCESSING......'
         MPAGE_LEN = 56
         SET CONSOLE OFF
         IF FILE("C:\COMPINFO\PRINTERS.DBF")
            SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
         ELSE
            SET PRINT TO LPT3
         ENDIF
         SET DEVICE TO PRINT
         SET PRINT ON
         
         *** PRINT IN 12 CPI
         ?? chr(27) + '&k4S'
         
         *** LETTER GOTHIC AND BOLDED PRINT
         ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
         
         *** LETTER SIZE PAPER
         ?? CHR(27) + '&l2A'
         
         *** PORTRAIT MODE
         ?? CHR(27) + '&l0O'
         
      ELSE
         MPAGE_LEN = 23
         @ 21,16 SAY SPACE(34)
         @ 21,16 SAY 'PROCESSING......'
      ENDIF
      MPAGE_NO = 0
      MLINE = 99
      
      IF MDETAILS = 'Y'
         SET CONSOLE OFF
         IF FILE("C:\COMPINFO\PRINTERS.DBF")
            SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
         ELSE
            SET PRINT TO LPT3
         ENDIF
         SET DEVICE TO PRINT
         SET PRINT ON
         
         *** PRINT IN 12 CPI
         ?? chr(27) + '&k4S'
         
         *** LETTER GOTHIC AND BOLDED PRINT
         ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
         
         *** LETTER SIZE PAPER
         ?? CHR(27) + '&l2A'
         
         *** PORTRAIT MODE
         ?? CHR(27) + '&l0O'
         
      ENDIF
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
      
      SELECT B
      DO FOX_USE WITH "INVN_DTL INDEX DTL_DATE", .F.
      
      MYRX= SUBSTR(DTOC(MBEGIN),7)
      MMOX= SUBSTR(DTOC(MBEGIN),1,2)
      MDAYX= SUBSTR(DTOC(MBEGIN),4,2)
      
      SEEK MYRX+MMOX+MDAYX
      IF EOF()
         SEEK MYRX+MMOX
         IF EOF() 
            SEEK MYRX
            IF EOF()
               GOTO TOP
            ENDIF
         ENDIF
      ENDIF
      MTOT_M1 = 0
      MTOT_M2 = 0
      MTARE_IN = 0
      DO WHILE .NOT. EOF() .AND. ACT_DATE < MBEGIN
         SKIP
      ENDDO
      IF MDETAILS = 'Y'
         ? 'STUFF GOING IN'
      ENDIF
      MBOX_STOR = .027 
      MTOT_IN = 0
      MBOX_IN = 0
      DO WHILE .NOT. EOF() .AND. ACT_DATE <= MEND
         IF ACTIVITY <> 'IN'
            SKIP
            LOOP
         ENDIF
         MSTOR_LB = 0
         SELECT A
         SEEK B->FREEZ_LOC + B->LOT_NBR
         SELECT B
         *******************************
         IF SUBSTR(A->PACKED,1,1) = 'B' .OR. SUBSTR(A->PACKED,1,1) = 'H'
            MXLBS =  A->BOX_SZ * QTY
         ELSE
            MXLBS = LBS
         ENDIF
         M1 = .0270
         M2 = .0041
         MX1 = ROUND(MXLBS*M1,2) + ROUND((QTY*2)*M1,2)
         MX2 = ROUND(MXLBS*M2,2) + ROUND((QTY*2)*M2,2)
         MTOT_M1 = MTOT_M1 + MX1
         MTOT_M2 = MTOT_M2 + MX2
         **************************************
         MTOT_IN = MTOT_IN + ROUND(LBS * MSTOR_LB,2)
         **ESTIMATED TARE WT STORAGE
         MTARE_IN = MTARE_IN + ROUND((QTY * 2) * M1,2)
         
         MY = 0
         IF MDETAILS = 'Y'
            ? LOT_NBR + '  ' + DTOC(ACT_DATE) + '    EST LBS: ' +TRANSFORM(MXLBS+(QTY*2), '9999999') + SPACE(3) + TRANSFORM(MX1, '99999.99')  +SPACE(3) +TRANSFORM(MX2, '99999.99')
         ENDIF
         SKIP
      ENDDO
      IF MDETAILS = 'Y'
         ?
         ? 'TOT $ @ .027/LB: ' + TRANSFORM(MTOT_M1, '99999.99')  +'  TOT $ @ .0041 ACCESSORIAL: ' +TRANSFORM(MTOT_M2, '99999.99')
         EJECT
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
      ENDIF
      
      *** NOW START WITH RECURRING CHARGES
      ** PUT EVERYTHING BACK TO THE BEGINNING OF THIS TIME FRAME
      MCUTOFF = MBEGIN - 1
      
      SELECT C
      *** INVNTMP5
      MFILENM = 'INVNTMP' + '5'
      USE &MFILENM EXCLUSIVE               
      DELETE ALL
      PACK
      INDEX ON FREEZ_LOC + LOT_NBR TO &MFILENM
      DO FOX_USE WITH "&MFILENM INDEX &MFILENM", .F.
      DO FILELOCK
      SELECT B
      DO FOX_USE WITH "INVN_DTL INDEX DTL_DATE", .F.
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNSOLD", .F.
      SEEK ' '
      DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' '
         IF ANIV_DATE > MCUTOFF
            SKIP
            LOOP
         ENDIF
         SELECT C
         APPEND BLANK
         REPLACE LOT_NBR WITH A->LOT_NBR
         REPLACE FREEZ_LOC WITH A->FREEZ_LOC
         REPLACE RSUPCODE WITH A->RSUPCODE
         REPLACE ANIV_DATE WITH A->ANIV_DATE
         REPLACE SIZE    WITH A->SIZE
         REPLACE GRADE   WITH A->GRADE
         REPLACE PROD_DESC WITH A->PROD_DESC
         REPLACE SUP_PREFX WITH A->SUP_PREFX 
         REPLACE SUP_PCODE WITH A->SUP_PCODE
         REPLACE BOX_SZ    WITH A->BOX_SZ
         REPLACE CASE_LEFT WITH A->CASE_LEFT
         REPLACE LBS_LEFT  WITH A->LBS_LEFT
         REPLACE PRI_LB    WITH A->PRI_LB + A->STOR_LB
         REPLACE CASE_CNT  WITH A->CASE_CNT
         REPLACE STOR_LB   WITH A->STOR_LB
         REPLACE PACKED    WITH A->PACKED
         SELECT A
         SKIP
      ENDDO
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNLOT", .F.
      
      MTRAN_YR = SUBSTR(DTOC(MCUTOFF),7)
      MTRAN_MO = SUBSTR(DTOC(MCUTOFF),1,2)
      
      SELECT B
      SEEK MTRAN_YR+MTRAN_MO
      IF EOF()
         SEEK MTRAN_YR
         IF EOF()
            GOTO TOP 
         ENDIF 
      ENDIF
      
      DO WHILE .NOT. EOF()
         IF ACT_DATE <= MCUTOFF      
            SKIP
            LOOP
         ENDIF
         
         IF ACTIVITY = 'IN '
            SKIP
            LOOP
         ENDIF
         
         SELECT C
         SEEK B->FREEZ_LOC + B->LOT_NBR   
         DO CASE
         CASE EOF()     
            SELECT A
            SEEK B->FREEZ_LOC + B->LOT_NBR
            IF EOF() .OR. ANIV_DATE > MCUTOFF
               SELECT B
               SKIP
               LOOP
            ENDIF
            SELECT C
            *** GET ALL THE DETAIL STUFF
            APPEND BLANK
            REPLACE FREEZ_LOC WITH B->FREEZ_LOC
            REPLACE LOT_NBR WITH B->LOT_NBR
            REPLACE CASE_LEFT WITH B->QTY * -1
            REPLACE LBS_LEFT  WITH B->LBS * -1 
            **** GET ALL THE HEADER STUFF
            REPLACE SIZE    WITH A->SIZE
            REPLACE GRADE   WITH A->GRADE
            REPLACE PROD_DESC WITH A->PROD_DESC
            REPLACE RSUPCODE WITH A->RSUPCODE
            REPLACE ANIV_DATE WITH A->ANIV_DATE
            REPLACE SUP_PREFX WITH A->SUP_PREFX 
            REPLACE SUP_PCODE WITH A->SUP_PCODE
            REPLACE BOX_SZ    WITH A->BOX_SZ
            REPLACE PACKED    WITH A->PACKED
            REPLACE PRI_LB    WITH A->PRI_LB + A->STOR_LB
            REPLACE CASE_CNT  WITH A->CASE_CNT
            REPLACE STOR_LB   WITH A->STOR_LB
         OTHERWISE
            REPLACE CASE_LEFT WITH CASE_LEFT + B->QTY * -1
            REPLACE LBS_LEFT  WITH LBS_LEFT + B->LBS * -1 
         ENDCASE
         SELECT B
         SKIP
      ENDDO
      
      CLOSE DATA
      
      SELECT B
      DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT", .F.
      SELECT A
      *** INVNTMP5
      MFILENM = 'INVNTMP' + '5'
      DO FOX_USE WITH "&MFILENM INDEX &MFILENM", .F.
      
      **** NOW WALK THRU EVERY DAY OF THIS TIME PERIOD
      **** AND SEE WHAT HAD AN ANNIVERSARY DATE
      
      MTOT_ANIV = 0
      MTOT_ABOX = 0
      IF MDETAILS = 'Y'
         
         SET CONSOLE OFF
         IF FILE("C:\COMPINFO\PRINTERS.DBF")
            SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
         ELSE
            SET PRINT TO LPT3
         ENDIF
         SET DEVICE TO PRINT
         SET PRINT ON
         
         *** PRINT IN 12 CPI
         ?? chr(27) + '&k4S'
         
         *** LETTER GOTHIC AND BOLDED PRINT
         ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
         
         *** LETTER SIZE PAPER
         ?? CHR(27) + '&l2A'
         
         *** PORTRAIT MODE
         ?? CHR(27) + '&l0O'
         
         ? 'STUFF OUT'
      ENDIF
      DO WHILE .NOT. EOF()                                          
         IF CASE_LEFT  = 0    
            SKIP 
            LOOP
         ENDIF
         
         MDATE= ANIV_DATE
         DO CASE
         CASE MDATE <= CTOD('12/31/99')
            MANIV_STOR = .0120
         OTHERWISE
            MANIV_STOR = 0
         ENDCASE
         
         MMO = VAL(SUBSTR(DTOC(MDATE),1,2))
         MYR = VAL(SUBSTR(DTOC(MDATE),7)) 
         MDY = SUBSTR(DTOC(MDATE),4,2)
         MNEXT_MO =MMO + 1
         IF MNEXT_MO > 12
            MNEXT_MO = 01  
            MNEXT_YR = MYR + 1
         ELSE
            MNEXT_YR = MYR
         ENDIF
         MNEXT_MO = SUBSTR(STR(MNEXT_MO+100,3),2)
         MNEXT_YR = SUBSTR(STR(MNEXT_YR+100,3),2)
         MDY_X = '  '
         IF VAL(MDY) > 28
            DO CASE
            CASE VAL(MDY) = 29 .OR. VAL(MDY) = 30
               IF VAL(MNEXT_MO) = 02 
                  MDY_X = '28'
               ENDIF
            CASE VAL(MDY) = 31
               IF VAL(MNEXT_MO) = 02 
                  MDY_X = '28'
               ELSE
                  IF VAL(MNEXT_MO) = 04 .OR. VAL(MNEXT_MO) = 06 .OR. VAL(MNEXT_MO) = 09 .OR. VAL(MNEXT_MO) = 11
                     MDY_X = '30'
                  ENDIF
               ENDIF
            ENDCASE
         ENDIF
         IF MDY_X = '  '
            MDY_X = MDY
         ENDIF
         MNEXTMODT = CTOD(MNEXT_MO+'/'+MDY_X+'/'+MNEXT_YR)
         M1ST_DATE = MBEGIN     
         
         DO WHILE MNEXTMODT <= MEND                  
            
            ** THIS IS IN TIME FRAME
            IF MNEXTMODT >= MBEGIN
               
               **FIGURE OUT WHAT WAS LEFT ON MNEXTMODT
               SELECT B
               SEEK A->FREEZ_LOC+A->LOT_NBR
               DO WHILE .NOT. EOF() .AND. FREEZ_LOC = A->FREEZ_LOC .AND. LOT_NBR = A->LOT_NBR
                  IF ACT_DATE < MBEGIN
                     SKIP
                     LOOP
                  ENDIF
                  IF ACT_DATE <  M1ST_DATE .OR. ACT_DATE >= MNEXTMODT
                     SKIP
                     LOOP
                  ENDIF
                  IF ACTIVITY <> 'OUT'
                     SKIP
                     LOOP
                  ENDIF
                  SELECT A
                  DO RECLOCK 
                  REPLACE CASE_LEFT WITH CASE_LEFT + B->QTY       
                  REPLACE LBS_LEFT  WITH LBS_LEFT  + B->LBS      
                  UNLOCK
                  SELECT B
                  SKIP
               ENDDO 
               
               SELECT A
               IF SUBSTR(PACKED,1,1) = 'B' .OR. SUBSTR(PACKED,1,1) = 'H'
                  IF BOX_SZ = 0
                     MBOX_SZ = VAL(SUBSTR(PACKED,2))
                  ELSE
                     MBOX_SZ = BOX_SZ
                  ENDIF
                  MANIV = ROUND(MANIV_STOR * MBOX_SZ,4)          
               ELSE
                  MANIV = MANIV_STOR
               ENDIF
               
               MTOT_ANIV = MTOT_ANIV + ROUND(LBS_LEFT * MANIV,2)
               MTOT_ABOX = MTOT_ABOX + ROUND((CASE_LEFT*2.00) * MANIV_STOR,2)
               
               MX = ROUND(LBS_LEFT * MANIV,2)
               *         MY = ROUND((QTY * 2.00) * MBOX_STOR,2)
               MY = 0
               IF MDETAILS = 'Y'
                  ? LOT_NBR + '  ' + DTOC(MNEXTMODT) + '  ' + TRANSFORM(MX+MY, '99999.99')
                  
               ENDIF
            ENDIF
            
            MMO = VAL(SUBSTR(DTOC(MNEXTMODT),1,2))
            MYR = VAL(SUBSTR(DTOC(MNEXTMODT),7)) 
            MNEXT_MO =MMO + 1
            IF MNEXT_MO > 12
               MNEXT_MO = 01  
               MNEXT_YR = MYR + 1
            ELSE
               MNEXT_YR = MYR
            ENDIF
            MNEXT_MO = SUBSTR(STR(MNEXT_MO+100,3),2)
            MNEXT_YR = SUBSTR(STR(MNEXT_YR+100,3),2)
            MDY_X = '  '
            IF VAL(MDY) > 28
               DO CASE
               CASE VAL(MDY) = 29 .OR. VAL(MDY) = 30
                  IF VAL(MNEXT_MO) = 02 
                     MDY_X = '28'
                  ENDIF
               CASE VAL(MDY) = 31
                  IF VAL(MNEXT_MO) = 02 
                     MDY_X = '28'
                  ELSE
                     IF VAL(MNEXT_MO) = 04 .OR. VAL(MNEXT_MO) = 06 .OR. VAL(MNEXT_MO) = 09 .OR. VAL(MNEXT_MO) = 11
                        MDY_X = '30'
                     ENDIF
                  ENDIF
               ENDCASE
            ENDIF
            IF MDY_X = '  '
               MDY_X = MDY
            ENDIF
            M1ST_DATE = MNEXTMODT
            
            MNEXTMODT = CTOD(MNEXT_MO+'/'+MDY_X+'/'+MNEXT_YR)
            
         ENDDO
         
         SELECT A
         SKIP
      ENDDO
      IF MDETAILS = 'Y'
         EJECT
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
      ENDIF
      @ 04,10 SAY 'STORAGE CALCULATED FOR: ' + DTOC(MBEGIN) + ' THRU ' + DTOC(MEND)
      @ 06,10 SAY 'NET STORAGE GOING INTO INVENTORY: ' 
      @ 06,42 SAY MTOT_M1 - MTARE_IN PICTURE '9,999,999.99'
      
      @ 08,05 SAY 'EST. TARE STORAGE GOING INTO INVENTORY: ' 
      @ 08,42 SAY MTARE_IN   PICTURE '9,999,999.99'
      
      @ 10,10 SAY 'ACCESSORIAL STORAGE: '
      @ 10,42 SAY MTOT_M2 PICTURE '9,999,999.99'
      
      @ 12,10 SAY 'NET ANNIVERSARY STORAGE: '
      @ 12,42 SAY MTOT_ANIV PICTURE '9,999,999.99'
      
      @ 14,05 SAY 'EST. TARE ANNIVERSARY STORAGE: '
      @ 14,42 SAY MTOT_ABOX PICTURE '9,999,999.99'
      
      @ 21,1 CLEAR TO 21,78               
      MCONT = SPACE(8)
      DO WHILE MCONT <> 'CONTINUE'
         @ 18,1 SAY 'ENTER "CONTINUE" WHEN READY TO RETURN: ' GET MCONT PICTURE '@!'
         READ
      ENDDO
      
      *EJECT 
      *SET DEVICE TO SCREEN
      *SET CONSOLE ON  
      CLOSE DATA
      MSELECTION = ' '
      MRPT_SEL = ' '
      
   CASE MRPT_SEL = '8'
      MNEXT_LOT = .T.
      MFREEZ_LOC = 'INVENTORY' + SPACE(23)
      DO WHILE MNEXT_LOT
         *** SELECT LOT NUMBER HERE
         CLEAR
         @ 00,00 SAY MCOMPANY
         @ 01,68 SAY DATE()
         @ 01,00 SAY MPROGRAM + ' - PRINT LOT ACTIVITY/NET DOLLARS'         
         @ 2,0 to 25,79
         MLOT = SPACE(10)
         MPERCENT =0 
         MACTION = 2
         DO WHILE MACTION = 2
            @ 07,3 SAY 'Enter Freezer Name: ' GET MFREEZ_LOC PICTURE '@!'
            @ 09,3 SAY '  Enter Lot Number: ' GET MLOT PICTURE '@!'
            @ 11,3 SAY 'Optional: Bench Price Percentage: ' get mpercent picture '###.##'
            @ 21,16 SAY 'PLEASE ENTER SELECTIONS'
            STORE 1 TO MACTION
            @ 24,0 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2. Edit    3. Finished'               
            READ
            @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
            READ
         ENDDO
         IF MACTION = 3 .OR. MLOT = SPACE(10)
            MNEXT_LOT = .F.
            LOOP
         ENDIF
         *** DO HEADERS
         SELECT A
         DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
         SELECT E
         DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
         
         SELECT D
         DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
         
         SELECT F
         DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT", .F.
         
         SEEK TRIM(MFREEZ_LOC)
         IF .NOT. EOF()
            MFREEZ_LOC = FREEZ_LOC
         ENDIF
         SEEK MFREEZ_LOC + MLOT
         IF EOF()
            MWAIT = ' '
            @ 12,10 SAY 'NO DATA ON FILE FOR THIS LOT - PRESS RETURN ' GET MWAIT
            READ 
            LOOP
         ELSE
            MOUT = .F.
            DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT
               IF ACTIVITY <> 'OUT'
                  SKIP
                  LOOP
               ENDIF
               MOUT = .T.
               SKIP
            ENDDO
            IF .NOT. MOUT
               MWAIT = ' '
               @ 12,10 SAY 'NO SHIPMENTS ON FILE FOR THIS LOT - PRESS RETURN ' GET MWAIT
               READ 
               LOOP
            ENDIF
            
         ENDIF
         @ 21,16 SAY SPACE(50)
         MPRT_ACT = 'C'
         DO PRT_SET
         IF MPRT_ACT <> 'C'
            LOOP  
         ENDIF
         MPAGE_LEN = 56
         MPAGE_NO = 1
         STORE 0 TO MLBS_SOLD, MLBS_PUR, MPUR_PRICE, MBENCH_PRI, MTOT_SELL, MTOT_PURCH
         
         @ 21,16 SAY SPACE(34)
         @ 21,16 SAY 'PRINTING .........'
         
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
         
         @ 1,0 SAY 'PAGE: ' + STR(MPAGE_NO,2)
         @ 1,25 SAY MCOMPANY    
         @ 1,68 SAY DATE()
         @ 2,28 SAY 'LOT NUMBER: ' + MLOT
         
         @ 4,1 SAY 'PO NUMBER'
         @ 4,15 SAY 'ACTIVITY'
         @ 4,25 SAY 'ACT DATE'
         @ 4,42 SAY 'QUANTITY'
         @ 4,57 SAY 'PRICE'
         @ 4,75 SAY 'TOTAL'
         @ 4,1 SAY REPLICATE('_',79)
         MLINE = 6 
         
         SELECT E
         SEEK MFREEZ_LOC + MLOT    
         MTOT_QTY = LBS 
         MPRI_LB = PRI_LB
         MTOT_AMT = ROUND(LBS*PRI_LB,2)
         @ MLINE,1 SAY SALESMAN+'-' + PO_NBR
         IF PO_SUFFIX <> ' '
            @ MLINE,8 SAY '-' + PO_SUFFIX
         ENDIF
         @ MLINE,15 SAY 'PURCHASE'
         @ MLINE,25 SAY ANIV_DATE
         @ MLINE,40 SAY LBS PICTURE '999,999.99'
         @ MLINE,55 SAY PRI_LB PICTURE '99.9999'
         @ MLINE,70 SAY MTOT_AMT PICTURE '999,999.99'
         MLBS_PUR = LBS
         MTOT_PURCH = MTOT_AMT
         MPUR_PRICE = PRI_LB
         IF MPERCENT = 0
            MBENCH_PRI = MPUR_PRICE
         ELSE
            MBENCH_PRI = MPUR_PRICE + ROUND(MPUR_PRICE * MPERCENT/100,4)
         ENDIF
         MLINE = MLINE + 3
         
         MTOT_SELL = 0
         SELECT F
         SEEK MFREEZ_LOC + MLOT
         DO WHILE .NOT. EOF() .AND. MFREEZ_LOC = FREEZ_LOC .AND. LOT_NBR = MLOT
            IF ACTIVITY <> 'OUT'
               SKIP
               LOOP
            ENDIF
            IF MLINE > MPAGE_LEN
               EJECT
               MPAGE_NO = MPAGE_NO + 1
               @ 1,0 SAY 'PAGE: ' + STR(MPAGE_NO,2)
               @ 1,25 SAY MCOMPANY    
               @ 1,68 SAY DATE()
               @ 2,28 SAY 'LOT NUMBER: ' + MLOT
               
               @ 4,1 SAY 'PO NUMBER'
               @ 4,15 SAY 'ACTIVITY'
               @ 4,25 SAY 'ACT DATE'
               @ 4,42 SAY 'QUANTITY'
               @ 4,57 SAY 'PRICE'
               @ 4,75 SAY 'TOTAL'
               @ 4,1 SAY REPLICATE('_',79)
               MLINE = 6 
            ENDIF
            @ MLINE,1 SAY SALESMAN+ '-'+PO_NBR
            IF PO_SUFFIX <> ' '
               @ MLINE,8 SAY '-' + PO_SUFFIX
            ENDIF
            @ MLINE,15 SAY 'SALE'      
            SELECT A
            SEEK F->SALESMAN+F->PO_NBR+F->PO_SUFFIX               
            @ MLINE,25 SAY SHIP_DATE
            
            SELECT D               
            SEEK F->SALESMAN+F->PO_NBR+F->PO_SUFFIX+F->ITEM_NBR
            
            @ MLINE,40 SAY LBS PICTURE '999,999.99'
            @ MLINE,55 SAY SEL_PRICE PICTURE '99.9999'
            @ MLINE,70 SAY TOT_SELL PICTURE '999,999.99'
            MLBS_SOLD = MLBS_SOLD + LBS
            MTOT_SELL = MTOT_SELL + TOT_SELL
            MLINE = MLINE + 1
            SELECT F
            SKIP
         ENDDO
         MLINE = MLINE + 3
         IF MPERCENT <> 0
            @ MLINE,1 SAY 'BENCH PRICE (' + TRANSFORM(MPERCENT, '99.99') + '% OVER PURCHASE PRICE)'
            @ MLINE,74 SAY MBENCH_PRI PICTURE '999.9999'
            MLINE = MLINE + 2
         ENDIF
         @ MLINE,1 SAY 'TOTAL POUNDS SOLD TO DATE: '
         @ MLINE,70 SAY MLBS_SOLD PICTURE '999,999.99'
         MLINE = MLINE + 2
         @ MLINE,1 SAY 'AVERAGE PRICE/LB SOLD:'
         MAVG_PRI = ROUND(MTOT_SELL/MLBS_SOLD,4)
         @ MLINE,74 SAY MAVG_PRI PICTURE '999.9999' 
         MLINE = MLINE + 2
         @ MLINE,1 SAY 'TOTAL NET $ TO DATE: '          
         *MPRI = MAVG_PRI - MBENCH_PRI
         *MTOT_NET = ROUND(MPRI * MLBS_SOLD,2)
         SET DECIMALS TO 6
         MPERC = MPERCENT / 100
         MTOT_NET = (((MTOT_SELL/MLBS_SOLD) * (1 - MPERC)) - MPUR_PRICE) * MLBS_SOLD
         MTOT_NET = ROUND(MTOT_NET,2)
         @ MLINE,70 SAY MTOT_NET PICTURE '999,999.99'
         MLINE = MLINE + 2
         IF MPERCENT <> 0                     
            DO CASE
            CASE MTOT_NET > 0
               @ MLINE,1 SAY '50 % OF NET $ ='  
               M50_PER = ROUND(MTOT_NET/2,2)                       
               @ MLINE,70 SAY M50_PER PICTURE '999,999.99'
               MCNTS =  ROUND(M50_PER/MLBS_SOLD,3)
               @ MLINE,82 SAY '(' + TRANSFORM(MCNTS, '99.999') + ' CENT/#)'
            CASE MTOT_NET < 0
               M50_PER = ROUND(MTOT_NET/2,2)                       
               MCNTS =  ROUND(MTOT_NET/MLBS_SOLD,3)
               @ MLINE,75 SAY '(' + TRANSFORM(MCNTS, '99.999') + ' CENT/LB LOSS)'
            ENDCASE
         ENDIF
         EJECT
         
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
      ENDDO
      CLOSE DATA
      MRPT_SEL   = ' '
      
   ENDCASE
   
ENDDO
RETURN


PROCEDURE ACT_HEAD
IF MLINE <> 99
   EJECT 
ENDIF
MPAGE_NO = MPAGE_NO + 1
@ 1,59 SAY MCOMPANY
@ 2,1 SAY 'Page'
@ 2,06 say mpage_no picture '99'
@ 2,50 SAY 'INVENTORY ACTIVITY BETWEEN ' + DTOC(MBEG_DATE) + ' - ' + DTOC(MEND_DATE)
@ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
@ 4,1 SAY '  DATE    LOCATION              LOT #      I #     PO NBR    SUPPLIER      ACTIVITY  PRODUCT           PACK  CASES      POUNDS     PRICE                $ AMOUNT'
@ 4,01 SAY REPLICATE('_',160)
MLINE = 6
@ MLINE,1 SAY 'DIVISION: ' + MDIV_NAME
@ MLINE,1 SAY REPLICATE('_',42)
MLINE = MLINE + 2
RETURN

PROCEDURE ACT_HED1
IF MLINE <> 99
   EJECT 
ENDIF
MPAGE_NO = MPAGE_NO + 1
@ 1,59 SAY MCOMPANY
@ 2,1 SAY 'Page'
@ 2,06 say mpage_no picture '99'
@ 2,50 SAY 'INVENTORY ACTIVITY BETWEEN ' + DTOC(MBEG_DATE) + ' - ' + DTOC(MEND_DATE)
@ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
@ 4,1 SAY '  DATE    LOT #      I #     PO NBR    SUPPLIER      ACTIVITY  PRODUCT           PACK  CASES       UNITS     PRICE                $ AMOUNT      NET $'
@ 4,01 SAY REPLICATE('_',160)
MLINE = 6
@ MLINE,1 SAY 'DIVISION: ' + MDIV_NAME
@ MLINE,1 SAY REPLICATE('_',42)
MLINE = MLINE + 2
RETURN

PROCEDURE ACT_HD10
IF MLINE <> 99
   EJECT 
ENDIF
MPAGE_NO = MPAGE_NO + 1
@ 1,23 SAY MCOMPANY
@ 2,1 SAY 'Page'
@ 2,06 say mpage_no picture '99'
@ 2,23 SAY 'DAILY ACTIVITY REPORT FOR: ' + DTOC(MDATE)
@ 2,60  SAY DTOC(DATE()) + '  ' + TIME()
MLINE = 4
@ MLINE,1 SAY 'LOT NBR'
@ MLINE,10 SAY 'ACT'
@ MLINE,15 SAY 'PO NBR'
@ MLINE,28 SAY 'QTY'
@ MLINE,37 SAY 'POUNDS'
@ MLINE,46 SAY ' PRI/LB'
@ MLINE,61 SAY 'VALUE'
MLINE = 6
RETURN



PROCEDURE ACT_HD1 
IF MLINE <> 99
   EJECT 
ENDIF
MPAGE_NO = MPAGE_NO + 1
@ 1,59 SAY MCOMPANY
@ 2,1 SAY 'Page'
@ 2,06 say mpage_no picture '99'
@ 2,50 SAY 'INVENTORY REPORT BY I NUMBER AS OF: ' + DTOC(MEND_DATE)
@ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
@ 4,1 SAY 'LOT DATE  LOCATION              LOT #      I #               SUPPLIER                PRODUCT           PACK  CASES      POUNDS     PRICE                        '
@ 4,01 SAY REPLICATE('_',145)
MLINE = 6
RETURN


PROCEDURE CALC_CUR

SELECT A
MVAL_LEFT  = VALUE
MLBS_LEFT  = LBS
MCASE_LEFT = CASE_CNT
MTOT_COST = 0    
MTOT_PRO  = 0
MWORK_COST = 0
SELECT B
DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT, IDTL_DTL, INVN_PO, INVNDISP, DTL_DATE, INVN_DTL", .F.

**SEEK STR(A->I_NBR,5)
***HERE
SEEK A->FREEZ_LOC + A->LOT_NBR
*DO WHILE .NOT. EOF() .AND. A->I_NBR = I_NBR
DO WHILE .NOT. EOF() .AND. A->FREEZ_LOC = FREEZ_LOC .AND. A->LOT_NBR = LOT_NBR
   DO CASE    
   CASE ACT_CODE = 'C'
      MTOT_COST = MTOT_COST + COST_AMT
      MWORK_COST = MWORK_COST + COST_AMT
   CASE ACT_CODE = 'S'
      MTHIS_COST =  ROUND(MWORK_COST/MLBS_LEFT,4) * SHIP_LBS
      MLBS_LEFT  = MLBS_LEFT  - SHIP_LBS
      MVAL_LEFT  = MVAL_LEFT  - SHIP_VAL               
      MCASE_LEFT = MCASE_LEFT - SHIP_CASE
      MTOT_PRO  = MTOT_PRO + MTHIS_COST
      MWORK_COST = MWORK_COST - MTHIS_COST
   ENDCASE
   SKIP
ENDDO
MVAL_LEFT = MVAL_LEFT + ( MTOT_COST - MTOT_PRO)
SELECT A
RETURN

PROCEDURE CALCCUR2
MVAL_LEFT  = MVALUE
MLBS_LEFT  = MLBS
MCASE_LEFT = MCASE_CNT
MTOT_COST = 0    
MTOT_PRO  = 0
MWORK_COST = 0
SELECT B
DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT, INVN_DTL INDEX IDTL_DTL, INVN_PO, INVNDISP, DTL_DATE, INVN_DTL", .F.

*SEEK STR(A->I_NBR,5)
SEEK A->FREEZ_LOC + A->LOT_NBR
*DO WHILE .NOT. EOF() .AND. A->I_NBR = I_NBR
DO WHILE .NOT. EOF() .AND. A->FREEZ_LOC = FREEZ_LOC .AND. A->LOT_NBR = LOT_NBR
   DO CASE    
   CASE ACT_CODE = 'C'
      MTOT_COST = MTOT_COST + COST_AMT
      MWORK_COST = MWORK_COST + COST_AMT
   CASE ACT_CODE = 'S'
      MTHIS_COST =  ROUND(MWORK_COST/MLBS_LEFT,4) * SHIP_LBS
      MLBS_LEFT  = MLBS_LEFT  - SHIP_LBS
      MVAL_LEFT  = MVAL_LEFT  - SHIP_VAL               
      MCASE_LEFT = MCASE_LEFT - SHIP_CASE
      MTOT_PRO  = MTOT_PRO + MTHIS_COST
      MWORK_COST = MWORK_COST - MTHIS_COST
   ENDCASE
   SKIP
ENDDO
MVAL_LEFT = MVAL_LEFT + ( MTOT_COST - MTOT_PRO)
SELECT A
RETURN


********************************************
**   LOT COSTS                            **
********************************************

PROCEDURE LOT_COST
SELECT C
DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.

SELECT B
DO FOX_USE WITH "INVN_DTL INDEX IDTL_DTL, INVN_PO, INVNDISP, DTL_DATE, INVN_DTL, DTL_LOT", .F.
SELECT A
DO FOX_USE WITH "INVEN INDEX INVNLOT, INVNPO, INVNLOC, INVNSOLD, INVNINBR, INVNANIV", .F.

MMORE = .T.
MINIT_NM = .T.
DO WHILE MMORE
   
   MLOT_NBR    = SPACE(7)
   MI_NBR      = 0          
   MFREEZ_LOC  = SPACE(40)
   MACT_DATE   = CTOD(' ')
   MACT_CODE   = 'C'
   MCOST_AMT   = 0
   MCOST_CODE  = ' ' 
   MPAYEE      = SPACE(32)
   MACTION = 2    
   DO WHILE MACTION = 2
      
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - SELECT LOT'     
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      @  5, 5 SAY 'Enter the following fields:'
      @  8, 5 SAY '     Lot Nbr:'
      @  8,19 GET MLOT_NBR PICTURE '@!'
      @ 10,5  SAY '(OR)   I Nbr: '
      @ 10,19 GET MI_NBR   PICTURE '#####'
      @ 13,5  SAY '   Cost Date:'
      @ 13,19 GET MACT_DATE 
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
      
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      
      
      IF VAL(MLOT_NBR) <> 0 .AND. MI_NBR <> 0   
         IF DTOC(MACT_DATE) = '  /  /  '
            @ 23,0 CLEAR
            STORE ' ' TO MWAIT   
            @ 24,01 SAY 'INVOICE DATE NOT ENTERED - PRESS RETURN TO REENTER  ' GET MWAIT 
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
      ENDIF
      READ               
   ENDDO
   IF MACTION = 3                          
      MMORE = .F.
      LOOP
   ENDIF 
   SELECT A
   DO CASE
   CASE MLOT_NBR <> SPACE(7)
      SET ORDER TO 1
      SEEK MLOT_NBR
      STORE MLOT_NBR TO SRCH_ARG
      IF EOF()                
         @ 23,0 CLEAR
         STORE 'Y' TO MYES_NO
         @ 24,05 SAY 'LOT NBR NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' get MYES_NO PICTURE '@!'
         READ
         LOOP              
      ELSE               
         STORE RECNO() TO MFST_REC
         IF LOT_NBR = SRCH_ARG
            MADD = .F.
            MFOUND = .F.
            DO MULTILOT 
            DO CASE 
            CASE MFOUND
               DO STORLOT
            OTHERWISE 
               LOOP 
            ENDCASE
         ELSE
            GOTO MFST_REC
            DO STORLOT
         ENDIF
      ENDIF
   CASE MI_NBR <> 0
      SET ORDER TO 5
      SEEK STR(MI_NBR,5)
      IF EOF() 
         @ 23,0 CLEAR
         STORE 'Y' TO MYES_NO
         @ 24,05 SAY 'I NBR NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' get MYES_NO PICTURE '@!'
         READ
         LOOP              
      ELSE               
         DO STORLOT
      ENDIF
   ENDCASE
   SELECT B
   SEEK STR(MI_NBR,5)
   IF EOF()
      @ 23,0 CLEAR
      STORE ' ' TO MYES_NO
      @ 24,05 SAY 'COST NOT ON FILE - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
      READ
      IF MYES_NO = 'Y'
         DO FILELOCK
         APPEND BLANK
         REPLACE LOT_NBR  WITH MLOT_NBR
         REPLACE I_NBR    WITH MI_NBR
         REPLACE ACT_DATE WITH MACT_DATE
         REPLACE ACT_CODE WITH MACT_CODE
         UNLOCK
      ELSE
         LOOP              
      ENDIF
   ELSE 
      STORE RECNO() TO MFST_REC
      MADD = .F.
      MFOUND = .F.
      DO MULTICST 
      DO CASE 
      CASE MADD
         DO FILELOCK
         APPEND BLANK
         REPLACE LOT_NBR  WITH MLOT_NBR
         REPLACE I_NBR    WITH MI_NBR
         REPLACE ACT_DATE WITH MACT_DATE
         REPLACE ACT_CODE WITH MACT_CODE
         UNLOCK
      CASE MFOUND
         DO STORCOST
      OTHERWISE 
         LOOP 
      ENDCASE
   ENDIF
   
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - VIEW/UPDATE COST INFORMATION'
   DO TEXTCOST
   MACTION = 2
   DO WHILE MACTION = 2
      DO GETCOST
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Cancel'                                     
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MACTION = 3
      LOOP
   ENDIF
   
   DO REPLCOST
ENDDO
RETURN

PROCEDURE STORCOST
MCOST_AMT   = COST_AMT
MCOST_CODE  = COST_CODE
MPAYEE      = PAYEE    
MACT_DATE   = ACT_DATE
RETURN

PROCEDURE REPLCOST
DO RECLOCK
REPLACE COST_AMT   WITH MCOST_AMT
REPLACE COST_CODE  WITH MCOST_CODE
REPLACE PAYEE      WITH MPAYEE    
UNLOCK
SELECT A
MVAL_LEFT  = VALUE
MLBS_LEFT  = LBS
MCASE_LEFT = CASE_CNT
MTOT_COST = 0    
MTOT_PRO  = 0
MWORK_COST = 0

DO CALC_CUR

IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
   MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
ELSE
   MPRO_PRI = 0
   MVAL_LEFT = 0
ENDIF
DO RECLOCK
REPLACE VAL_LEFT  WITH MVAL_LEFT
REPLACE CASE_LEFT WITH MCASE_LEFT
REPLACE PRO_PRI   WITH MPRO_PRI
REPLACE LBS_LEFT  WITH MLBS_LEFT 
IF LBS_LEFT = 0 .OR. CASE_LEFT = 0
   REPLACE SOLD_FLG WITH 'Y'
ELSE
   REPLACE SOLD_FLG WITH ' '
ENDIF
UNLOCK
SELECT B
RETURN

PROCEDURE TEXTCOST
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 25,79
@ 05,01 SAY '       LOT #:' 
@ 05,25 SAY 'FREEZER:'
@ 06,01 SAY '         I #:'  
@ 08,01 SAY 'INVOICE DATE:'
@ 10,01 SAY '       PAYEE:'
@ 12,01 SAY '    $ AMOUNT:'
@ 14,01 SAY '   COST CODE:'

RETURN


PROCEDURE GETCOST
@ 05,15 GET MLOT_NBR   PICTURE '@!'
@ 05,34 GET MFREEZ_LOC PICTURE '@!'
@ 06,15 SAY MI_NBR     PICTURE '#####'
@ 08,15 GET MACT_DATE 
CLEAR GETS
@ 10,15 GET MPAYEE     PICTURE '@!'
@ 12,15 GET MCOST_AMT  PICTURE '999,999.99'
@ 14,15 GET MCOST_CODE PICTURE '@!'

RETURN

PROCEDURE MULTICST
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MATCH SELECT'
@ 3,0 TO 21,79
@  5, 2 SAY "COSTS ON FILE FOR THIS LOT.  PLEASE SELECT ACTION."
@ 6,5 say 'COST DATE   CODE    PAYEE'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC

MMULT = .T.
DO WHILE MMULT
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. I_NBR = MI_NBR .AND. ACT_CODE = 'C'
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      @ MLINE,5  SAY ACT_DATE
      @ MLINE,19 SAY COST_CODE
      @ MLINE,25 SAY PAYEE
      @ MLINE,62 SAY COST_AMT PICTURE '999,999.99'
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. I_NBR = MI_NBR .AND. ACT_CODE = 'C'  
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Selection Number: '
   @ 22,19 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add Cost   5.Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MFOUND = .T.
      MMULT = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add Cost   5.Cancel'
   @ 24,09 GET MACTION PICTURE '9' RANGE 1,5
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      @ 07,01 CLEAR TO 20,78
      IF .NOT. MORE_FLG
         GOTO MTOP_REC
         STORE MTOP_SEQ - 1 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 2
      @ 07,01 CLEAR TO 20,78
      GOTO MTOP_REC
      STORE MTOP_SEQ - 1 TO MSEQ_NUM
      IF MSEQ_NUM <> 0
         SKIP -13
         STORE MSEQ_NUM - 13 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 3
      @ 07,01 CLEAR TO 20,78
      STORE 0 TO MSEQ_NUM
      GOTO MFST_REC
      LOOP
      
   CASE MACTION = 4
      MINIT_NM = .F.
      MADD = .T. 
      MMULT = .F.
      
   CASE MACTION = 5
      MMULT = .F.
      
   ENDCASE
   
ENDDO
RETURN

********************************************
**   LOT SHIPMENTS                        **
********************************************

PROCEDURE LOT_SHIP
SELECT C
DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.

MMORE = .T.
MINIT_NM = .T.
DO WHILE MMORE
   SELECT B
   DO FOX_USE WITH "INVN_DTL INDEX INVN_PO, IDTL_DTL, INVNDISP, DTL_DATE, INVN_DTL, DTL_LOT", .F.
   SELECT A
   DO FOX_USE WITH "INVEN INDEX INVNLOT, INVNPO, INVNLOC, INVNSOLD, INVNINBR, INVNANIV", .F.
   
   
   MLOT_NBR    = SPACE(7)
   MI_NBR      = 0         
   MSALESMAN   = SPACE(2)
   MPO_NBR     = SPACE(4)
   MPO_SUFFIX  = ' '
   MFREEZ_LOC  = SPACE(40)
   MACT_DATE   = CTOD(' ')
   MACT_CODE   = 'S'
   MSHIP_NAME  = SPACE(32)
   MSHIP_LOC   = SPACE(32)
   MSHIP_LBS   = 0
   MSHIP_CASE  = 0   
   MSHIP_PRI   = 0        
   MSHIP_VAL   = 0
   MCUS_PRI    = 0
   
   MACTION = 2    
   DO WHILE MACTION = 2
      
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - SELECT LOT'     
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      @  5, 5 SAY 'Enter the following fields:'
      @  8, 5 SAY '     Lot Nbr:'
      @  8,19 GET MLOT_NBR PICTURE '@!'
      @  10,5 SAY '(OR)   I Nbr:'
      @ 10,19 GET MI_NBR PICTURE '#####'
      @ 13,2  SAY 'Shipment PO Nbr:   -    - '
      @ 13,19 GET MSALESMAN PICTURE '##'
      @ 13,22 GET MPO_NBR PICTURE '####'
      @ 13,27 GET MPO_SUFFIX PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
      
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      IF (MLOT_NBR <> SPACE(7) .OR. MI_NBR <> 0) .AND. MPO_NBR = SPACE(4)
         @ 23,0 CLEAR
         STORE ' ' TO MWAIT   
         @ 24,01 SAY 'PO NUMBER NOT ENTERED - PRESS RETURN TO REENTER  ' GET MWAIT 
         READ
         @ 24,0 CLEAR
         MACTION = 2
         LOOP
      ENDIF
      READ               
   ENDDO
   IF MACTION = 3 .OR. (MLOT_NBR = SPACE(7) .AND. MI_NBR = 0)
      MMORE = .F.
      LOOP
   ENDIF 
   DO CASE
   CASE MLOT_NBR <> SPACE(7)
      SELECT A
      SET ORDER TO 1
      STORE MLOT_NBR TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF()                 
         @ 23,0 CLEAR
         STORE 'Y' TO MYES_NO
         @ 24,05 SAY 'LOT NBR NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' get MYES_NO PICTURE '@!'
         READ
         LOOP              
      ELSE               
         STORE RECNO() TO MFST_REC
         SKIP
         IF LOT_NBR = SRCH_ARG
            MADD = .F.
            MFOUND = .F.
            DO MULTILOT 
            DO CASE 
            CASE MFOUND
               **DO STORLOT 
               MLOT_NBR    = LOT_NBR       
               MI_NBR      = I_NBR
               MFREEZ_LOC  = FREEZ_LOC
            OTHERWISE 
               LOOP 
            ENDCASE
         ELSE
            GOTO MFST_REC
            MADD = .F.
            MFOUND = .T.
            MLOT_NBR    = LOT_NBR       
            MI_NBR      = I_NBR
            MFREEZ_LOC  = FREEZ_LOC
         ENDIF
      ENDIF
   OTHERWISE        
      SELECT A
      SET ORDER TO 5
      SEEK STR(MI_NBR,5)
      IF EOF()                 
         @ 23,0 CLEAR
         STORE 'Y' TO MYES_NO
         @ 24,05 SAY 'I NBR NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' get MYES_NO PICTURE '@!'
         READ
         LOOP              
      ELSE               
         MADD = .F.
         MFOUND = .T.
         MLOT_NBR    = LOT_NBR       
         MI_NBR      = I_NBR
         MFREEZ_LOC  = FREEZ_LOC
      ENDIF
      
   ENDCASE
   SELECT B
   
   SEEK STR(MI_NBR,5) + MSALESMAN + MPO_NBR + MPO_SUFFIX
   IF .NOT. EOF()
      DO STORSHIP
   ELSE
      @ 23,0 CLEAR
      STORE ' ' TO MYES_NO
      @ 24,05 SAY 'SHIPMENT NOT ON FILE - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!' VALID (MYES_NO = 'Y' .OR. MYES_NO = 'N')
      READ
      IF MYES_NO = 'Y'
         DO FILELOCK
         APPEND BLANK
         REPLACE LOT_NBR  WITH MLOT_NBR
         REPLACE I_NBR    WITH MI_NBR
         REPLACE SALESMAN WITH MSALESMAN
         REPLACE PO_NBR   WITH MPO_NBR  
         REPLACE PO_SUFFIX WITH MPO_SUFFIX
         UNLOCK
      ELSE
         LOOP              
      ENDIF
   ENDIF
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - VIEW/UPDATE SHIPMENT INFORMATION'
   DO TEXTSHIP
   MACTION = 2
   DO WHILE MACTION = 2
      DO GETSHIP
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Cancel'                                     
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MACTION = 3
      LOOP
   ENDIF
   
   DO REPLSHIP
ENDDO
RETURN

PROCEDURE STORSHIP
MSHIP_NAME = SHIP_NAME
MACT_DATE  = ACT_DATE
MSHIP_LOC  = SHIP_LOC
MSHIP_LBS  = SHIP_LBS
MSHIP_CASE = SHIP_CASE
MSHIP_PRI  = SHIP_PRI
MSHIP_VAL  = SHIP_VAL
MCUS_PRI   = CUS_PRI
RETURN

PROCEDURE REPLSHIP
DO RECLOCK
REPLACE SHIP_NAME WITH MSHIP_NAME
REPLACE SHIP_LOC  WITH MSHIP_LOC
REPLACE SHIP_LBS  WITH MSHIP_LBS
REPLACE SHIP_CASE WITH MSHIP_CASE
REPLACE SHIP_PRI  WITH MSHIP_PRI
REPLACE SHIP_VAL  WITH MSHIP_VAL
REPLACE ACT_CODE  WITH MACT_CODE
REPLACE ACT_DATE  WITH MACT_DATE
REPLACE CUS_PRI   WITH MCUS_PRI
UNLOCK
SELECT A
MVAL_LEFT  = VALUE
MLBS_LEFT  = LBS
MCASE_LEFT = CASE_CNT
MTOT_COST = 0    
MTOT_PRO  = 0
MWORK_COST = 0
MPRO_PRI   = 0
DO CALC_CUR

IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
   MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
ELSE
   MPRO_PRI = 0
   MVAL_LEFT = 0
ENDIF
DO RECLOCK
REPLACE VAL_LEFT  WITH MVAL_LEFT
REPLACE CASE_LEFT WITH MCASE_LEFT
REPLACE PRO_PRI   WITH MPRO_PRI
REPLACE LBS_LEFT  WITH MLBS_LEFT 
IF LBS_LEFT = 0 .OR. CASE_LEFT = 0
   REPLACE SOLD_FLG WITH 'Y'
ELSE
   REPLACE SOLD_FLG WITH ' '
ENDIF
UNLOCK
SELECT B
RETURN

PROCEDURE TEXTSHIP
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 25,79
@ 05,01 SAY '       LOT #:' 
@ 05,25 SAY 'FREEZER:'
@ 06,01 SAY '         I #:'  
@ 08,01 SAY '        PO #:   -    -'
@ 10,01 SAY '   SHIP DATE:'
@ 12,01 SAY '  SHIPPED TO:'
@ 13,01 SAY ' TO LOCATION:'

@ 15,01 SAY '    SHIP CASES:'
@ 16,01 SAY '    SHIP UNITS:'
@ 17,01 SAY ' SHIP PRI/UNIT:'
@ 18,01 SAY '  TOTAL $ SHIP:'    
@ 20,01 SAY 'CUSTOMER PRICE:'  
RETURN


PROCEDURE GETSHIP 
@ 05,15 GET MLOT_NBR   PICTURE '@!'
@ 05,34 GET MFREEZ_LOC PICTURE '@!'
@ 06,15 SAY MI_NBR     PICTURE '#####'
@ 08,15 GET MSALESMAN 
@ 08,18 GET MPO_NBR
@ 08,23 GET MPO_SUFFIX PICTURE '@!'
CLEAR GETS
@ 10,15 GET MACT_DATE
@ 12,15 GET MSHIP_NAME PICTURE '@!'
@ 13,15 GET MSHIP_LOC  PICTURE '@!'
@ 15,17 GET MSHIP_CASE PICTURE '####'
@ 16,17 GET MSHIP_LBS  PICTURE '###,###.##'
@ 17,17 GET MSHIP_PRI  PICTURE '##.####'
@ 18,17 GET MSHIP_VAL  PICTURE '###,###.##'
@ 20,17 GET MCUS_PRI   PICTURE '##.####'
RETURN

PROCEDURE IVIEWCHG
****************************
**** SELECT ONE TO VIEW ****
****************************
SELECT C
DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
SELECT A
DO FOX_USE WITH "INVEN INDEX INVNLOT, INVNPO, INVNLOC, INVNSOLD, INVNINBR, INVNANIV", .F.
MMORE = .T.
MINIT_NM = .T.
DO WHILE MMORE
   
   IF MINIT_NM
      MLOT_NBR    = SPACE(7)
      MFREEZ_LOC  = SPACE(40)
      MSALESMAN   = SPACE(2)
      MPO_NBR     = SPACE(4)
      MPO_SUFFIX  = SPACE(1)
      MI_NBR      = 0        
   ENDIF
   
   MANIV_DATE  = CTOD(' ')
   MSUPPLIER   = SPACE(40)
   MPAID_DATE  = CTOD(' ')
   MPROD_DESC  = SPACE(4)
   MPROD_SIZE  = SPACE(10)
   MBOX_SIZE   = SPACE(4)
   MLBS        = 0        
   MCASE_CNT   = 0        
   MPRI_LB     = 0
   MPRO_PRI    = 0
   MVALUE      = 0
   MLBS_LEFT   = 0        
   MCASE_LEFT  = 0
   MVAL_LEFT   = 0
   
   MNOTE       = SPACE(72)
   MLOT_FD = .F.
   MPROD_DISP  = SPACE(25)
   MACTION = 2    
   DO WHILE MACTION = 2
      SELECT A
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - SELECT LOT'
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      @  5, 5 SAY 'Enter one of the following search fields:'
      @  8, 5 SAY 'Lot Nbr:'
      @ 11, 5 SAY '  I Nbr:'
      @ 14, 5 say 'Freezer:'
      @ 17, 5 say ' PO Nbr:   -    -' 
      @  8,14 GET MLOT_NBR PICTURE '@!'
      @ 11,14 GET MI_NBR   PICTURE '#####'
      @ 14,14 GET MFREEZ_LOC PICTURE '@!'
      @ 17,14 GET MSALESMAN PICTURE '@!'
      @ 17,17 GET MPO_NBR PICTURE '####'
      @ 17,22 GET MPO_SUFFIX PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MACTION = 3 .OR. (MLOT_NBR = SPACE(7) .AND. MFREEZ_LOC = SPACE(4) .AND. MPO_NBR = SPACE(4) .AND. MI_NBR = 0)
      MMORE = .F.
      LOOP
   ENDIF 
   
   DO CASE
   CASE MLOT_NBR <> SPACE(7)
      SET ORDER TO 1
      SEEK MLOT_NBR
      STORE TRIM(MLOT_NBR) TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF()                     
         @ 23,0 CLEAR
         STORE ' ' TO MWAIT   
         @ 24,05 SAY 'LOT NBR NOT ON FILE - PRESS RETURN TO REENTER '  GET MWAIT              
         READ
         MINIT_NM = .F.              
         LOOP
      ELSE               
         STORE RECNO() TO MFST_REC
         MADD = .F.
         MFOUND = .F.
         DO MULTILOT 
         DO CASE 
         CASE MADD
            @ 23,0 CLEAR
            STORE ' ' TO MWAIT   
            @ 24,05 SAY 'CANNOT ADD LOT - PRESS RETURN TO REENTER '  GET MWAIT              
            READ
            MINIT_NM = .F.              
            LOOP
         CASE MFOUND
            DO STORLOT
            SELECT C
            SEEK 'R' + MPROD_DESC
            MPROD_DISP = DESC
            SELECT A
         OTHERWISE 
            MINIT_NM = .T.
            LOOP 
         ENDCASE
      ENDIF
      
   CASE MFREEZ_LOC <> SPACE(40)
      SET ORDER TO 3
      STORE TRIM(MFREEZ_LOC) TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF() .OR. DELETED()
         @ 23,0 CLEAR
         STORE ' ' TO MWAIT  
         @ 24,05 SAY 'NO LOTS ON FILE FOR THIS FREEZER - PRESS RETURN TO REENTER  ' GET MWAIT PICTURE '@!'
         READ
         MINIT_NM = .F.              
         LOOP
      ELSE               
         STORE RECNO() TO MFST_REC
         SKIP
         IF FREEZ_LOC = SRCH_ARG
            GOTO MFST_REC
            MADD = .F.
            MFOUND = .F.
            DO MULTIFRZ  
            DO CASE 
            CASE MADD
               @ 23,0 CLEAR
               STORE ' ' TO MWAIT   
               @ 24,05 SAY 'CANNOT ADD LOT - PRESS RETURN TO REENTER '  GET MWAIT              
               READ
               MINIT_NM = .F.              
               LOOP
            CASE MFOUND
               DO STORLOT
               SELECT C
               SEEK 'R' + MPROD_DESC
               MPROD_DISP = DESC
               SELECT A
            OTHERWISE 
               MINIT_NM = .T.
               LOOP 
            ENDCASE
         ELSE
            GOTO MFST_REC
            DO STORLOT
            SELECT C
            SEEK 'R' + MPROD_DESC
            MPROD_DISP = DESC
            SELECT A
         ENDIF
      ENDIF
      
   CASE MPO_NBR <> SPACE(4)
      SET ORDER TO 2
      STORE MSALESMAN+MPO_NBR+MPO_SUFFIX TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF() .OR. DELETED()
         @ 23,0 CLEAR
         STORE ' ' TO MYES_NO
         @ 24,05 SAY 'PO NBR NOT ON FILE - PRESS RETURN TO REENTER  ' GET MWAIT  PICTURE '@!'
         READ
         MINIT_NM = .F.              
         LOOP
      ELSE               
         STORE RECNO() TO MFST_REC
         MADD = .F.
         MFOUND = .F.
         DO MULTIPO  
         DO CASE 
         CASE MADD
            @ 23,0 CLEAR
            STORE ' ' TO MWAIT  
            @ 24,05 SAY 'CANNOT ADD LOT FROM THIS FUNCTION - PRESS RETURN TO REENTER  ' GET MWAIT  PICTURE '@!'
            READ
            MINIT_NM = .F.              
            LOOP
         CASE MFOUND
            DO STORLOT
            SELECT C
            SEEK 'R' + MPROD_DESC
            MPROD_DISP = DESC
            SELECT A
         OTHERWISE 
            MINIT_NM = .T.
            LOOP 
         ENDCASE
      ENDIF
      
   CASE MI_NBR <> 0       
      SET ORDER TO 5
      STORE STR(MI_NBR,5) TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF()                 
         @ 23,0 CLEAR
         MWAIT = ' '
         @ 24,05 SAY 'I NBR NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT 
         READ
         MINIT_NM = .F.              
         LOOP
      ELSE               
         DO STORLOT
         SELECT C
         SEEK 'R' + MPROD_DESC
         MPROD_DISP = DESC
         SELECT A
      ENDIF
      
   ENDCASE
   
   CLEAR
   @ 0,0 SAY MCOMPANY + ' INVENTORY'
   @ 7,0 TO 7,79
   @ 9,0 TO 9,79
   @ 15,0 TO 15,79
   @ 21,0 TO 21,79
   @ 1,0 TO 24,79
   @ 2,1 SAY '   Lot Nbr:               |    Freezer:'
   @ 3,1 SAY '    PO Nbr:               |   Supplier:'
   @ 4,1 SAY '     I Nbr:               |  Prod Code:         Desc:'
   @ 5,1 SAY '   Date In:               |   Box Size:         Product Size:'
   @ 6,1 SAY 'Note:'
   @ 8,1 SAY 'In:      Units             Cases         Pr/Un           Value'
   @ 10,1 SAY 'COST:Date    Cases     Pounds  Reason      Payee           Pr/Un  Total Cost'
   @ 11,1 SAY '1.'
   @ 12,1 SAY '2.'
   @ 13,1 SAY '3.'
   @ 14,1 SAY '4.'
   @ 15,60 SAY 'More Costs'
   @ 16,1 SAY 'Sales Po #   Ship Dt  Case  Units Customer  Pri/Un     Value Pro/Cst Tot Cost'  
   @ 17,1 SAY '1.'
   @ 18,1 SAY '2.'
   @ 19,1 SAY '3.'
   @ 20,1 SAY '4.'
   @ 21,60 SAY 'More Ships'
   
   @ 22,1 SAY 'Remain:Units            Cases        Prorated Pr/Un          Value'            
   
   @ 24,1 SAY 'Action: 1   1. Continue   2. Update Lot Info   3. Add/Chg Cost  4. Add/Chg Ships'
   @ 2,13 SAY MLOT_NBR                
   @ 2,41 SAY SUBSTR(MFREEZ_LOC,1,20)
   IF MSALESMAN <> SPACE(2)
      @ 3,13 SAY MSALESMAN + '-'
   ENDIF
   @ 3,16 SAY MPO_NBR
   IF MPO_SUFFIX <> ' '
      @ 3,20 SAY '-' + MPO_SUFFIX
   ENDIF
   @ 3,41 SAY SUBSTR(MSUPPLIER,1,20)
   @ 4,13 SAY MI_NBR PICTURE '99999'
   @ 4,41 SAY MPROD_DESC
   SELECT C
   SEEK 'R' + MPROD_DESC
   MPROD_DISP = DESC
   @ 4,55 SAY SUBSTR(MPROD_DISP,1,22)
   @ 5,13 SAY MANIV_DATE
   @ 5,41 SAY MBOX_SIZE
   @ 5,63 SAY MPROD_SIZE
   @ 6,7  SAY MNOTE
   @ 8,16 SAY MLBS      PICTURE '999,999.99'
   @ 8,34 SAY MCASE_CNT PICTURE '9999'
   @ 8,49 SAY MPRI_LB   PICTURE '99.9999'
   @ 8,65 SAY MVALUE    PICTURE '99,999,999.99'
   SELECT B
   SET ORDER TO 1
   MMORE_SHIP = ' '
   
   MCOST_LINE = 11
   MSHIP_LINE = 17
   SELECT A
   MVAL_LEFT  = VALUE
   MLBS_LEFT  = LBS
   MCASE_LEFT = CASE_CNT
   MTOT_COST = 0    
   MTOT_PRO  = 0
   MWORK_COST = 0
   MLAST_COST = 0
   SELECT B
   *DO FOX_USE WITH "INVN_DTL INDEX IDTL_DTL, INVN_PO, INVNDISP, DTL_DATE, INVN_DTL, DTL_LOT", .F.
   DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT, IDTL_DTL, INVN_PO, INVNDISP, DTL_DATE, INVN_DTL", .F.
   
   SEEK A->FREEZ_LOC + A->LOT_NBR
   DO WHILE .NOT. EOF() .AND. A->FREEZ_LOC = FREEZ_LOC .AND. A->LOT_NBR = LOT_NBR
      DO CASE    
      CASE ACT_CODE = 'C'
         IF COST_AMT = 0
            SKIP
            LOOP
         ENDIF
         MTOT_COST = MTOT_COST + COST_AMT
         MWORK_COST = MWORK_COST + COST_AMT
         *** DISPLAY COST INFO       
         IF MCOST_LINE <= 14
            @ MCOST_LINE,4 SAY ACT_DATE
            @ MCOST_LINE,32 SAY COST_CODE
            @ MCOST_LINE,44 SAY SUBSTR(PAYEE,1,13)
            @ MCOST_LINE,67 SAY COST_AMT PICTURE '999,999.99'
            MCOST_LINE = MCOST_LINE + 1
         ELSE
            MMORE_COST = 'Y'
         ENDIF
      CASE ACT_CODE = 'S'
         IF SHIP_LBS = 0
            SKIP
            LOOP
         ENDIF
         MTHIS_COST =  ROUND(ROUND(MWORK_COST/MLBS_LEFT,4) * SHIP_LBS,2)
         *** DISPLAY SHIPMENT INFO       
         IF MSHIP_LINE <= 20
            IF SALESMAN <> SPACE(2)
               @ MSHIP_LINE,4 SAY SALESMAN + '-'
            ENDIF
            @ MSHIP_LINE,7 SAY PO_NBR
            IF PO_SUFFIX <> ' '
               @ MSHIP_LINE,11 SAY '-' + PO_SUFFIX
            ENDIF
            @ MSHIP_LINE,14 SAY ACT_DATE
            @ MSHIP_LINE,23 SAY SHIP_CASE  PICTURE '####'
            @ MSHIP_LINE,28 SAY SHIP_LBS   PICTURE '999999'
            @ MSHIP_LINE,35 SAY SUBSTR(SHIP_NAME,1,9)
            @ MSHIP_LINE,44 SAY SHIP_PRI PICTURE '99.9999'
            @ MSHIP_LINE,52 SAY SHIP_VAL PICTURE '999999.99' 
            @ MSHIP_LINE,62 SAY ROUND(MWORK_COST/MLBS_LEFT,4) PICTURE '99.9999'
            @ MSHIP_LINE,70 SAY ROUND(MTHIS_COST,2) PICTURE '99999.99'
            MLAST_COST = MTHIS_COST
            MSHIP_LINE = MSHIP_LINE + 1
         ELSE
            MMORE_SHIP = 'Y'
         ENDIF
         MLBS_LEFT  = MLBS_LEFT  - SHIP_LBS
         MVAL_LEFT  = MVAL_LEFT  - SHIP_VAL               
         MCASE_LEFT = MCASE_LEFT - SHIP_CASE
         MTOT_PRO  = MTOT_PRO + MTHIS_COST
         MWORK_COST = MWORK_COST - MTHIS_COST
      ENDCASE
      SKIP
   ENDDO
   SELECT A
   MCASE_LEFT = 0
   MVAL_LEFT = 0
   MLBS_LEFT = 0
   DO CALC_CUR
   IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
      MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
   ELSE
      MPRO_PRI = 0
      IF MVAL_LEFT <> 0
         IF MMORE_SHIP <> 'Y'
            MLAST_COST = MLAST_COST + MVAL_LEFT
            @ MSHIP_LINE-1,70 SAY ROUND(MLAST_COST,2) PICTURE '99999.99'
         ENDIF
      ENDIF
      MVAL_LEFT = 0
   ENDIF
   
   @ 22,13 GET MLBS_LEFT  PICTURE '999,999.99'
   @ 22,31 GET MCASE_LEFT PICTURE '9999'
   @ 22,53 GET MPRO_PRI   PICTURE '99.9999'
   @ 22,69 GET MVAL_LEFT  PICTURE '999,999.99'
   CLEAR GETS
   IF MMORE_COST = 'Y' 
      @ 15,72 GET MMORE_COST PICTURE '@!'
   ENDIF
   IF MMORE_SHIP = 'Y'
      @ 21,72 GET MMORE_SHIP PICTURE '@!'
   ENDIF
   IF MMORE_COST = 'Y' .OR. MMORE_SHIP = 'Y'
      READ
      DO CASE
      CASE MMORE_COST = 'X'
         MDO_COST = .T.
         MDO_SHIP = .F.
         SAVE SCREEN TO MGRACE
         DO SHIPCOST
         RESTORE SCREEN FROM MGRACE
         
      CASE MMORE_SHIP = 'X'
         MDO_SHIP = .T.
         MDO_COST = .F.
         SAVE SCREEN TO MGRACE
         DO SHIPCOST
         RESTORE SCREEN FROM MGRACE
      ENDCASE
   ENDIF
   
   MACTION = 1
   @ 24,9 GET MACTION PICTURE '#' RANGE 1,4
   READ
   
   DO CASE
   CASE MACTION = 1
   CASE MACTION = 2 
   CASE MACTION = 3
   CASE MACTION = 4
   OTHERWISE
      MINIT_NM = .T.
   ENDCASE 
ENDDO 
RETURN

PROCEDURE SHIPCOST
CLEAR
IF MDO_COST        
   @ 1,0 SAY MCOMPANY + ' INVENTORY - DISPLAY COSTS'
   @ 03,1 SAY 'COST:Date    Cases     Pounds  Reason      Payee           Pr/Lb  Total Cost'
ELSE
   @ 1,0 SAY MCOMPANY + ' INVENTORY - DISPLAY SHIPMENTS'
   **@ 03,1 SAY 'SALES Po Nbr    Date   Cases   Pounds  Sold To               Pr/Lb  Total Sale'
   @ 03,1 SAY 'Sales Po #   Ship Dt  Case Pounds Customer  Pri/Lb     Value Pro/Cst Tot Cost'  
ENDIF
@ 2,0 to 25,79
@ 04,1 SAY '1.'
@ 05,1 SAY '2.'
@ 06,1 SAY '3.'
@ 07,1 SAY '4.'
@ 08,1 SAY '5.'
@ 09,1 SAY '6.'
@ 10,1 SAY '7.'
@ 11,1 SAY '8.'
@ 12,1 SAY '9.'
@ 13,1 SAY '10.'
@ 14,1 SAY '11.'
@ 15,1 SAY '12.'
@ 16,1 SAY '13.'
@ 17,1 SAY '14.'
@ 18,1 SAY '15.'
@ 19,1 SAY '16.'
@ 20,1 SAY '17.'
@ 21,1 SAY '18.'
@ 22,1 SAY '19.'
@ 24,1 SAY 'Action: 1   1. Return'

MLINE = 4 
SELECT B
**SET ORDER TO 3

DO CASE
CASE MDO_COST
   *** SEEK THOSE COSTS
   SEEK A->FREEZ_LOC + A->LOT_NBR
   DO WHILE .NOT. EOF() .AND. A->FREEZ_LOC = FREEZ_LOC .AND. A->LOT_NBR = LOT_NBR .AND. MLINE <= 22
      IF ACT_CODE <> 'C'
         SKIP
         LOOP
      ENDIF
      @ MLINE,4 SAY ACT_DATE
      @ MLINE,32 SAY COST_CODE
      @ MLINE,44 SAY SUBSTR(PAYEE,1,13)
      @ MLINE,67 SAY COST_AMT PICTURE '999,999.99'
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
CASE MDO_SHIP       
   
   SELECT A
   MLBS_LEFT  = LBS
   
   MTOT_COST = 0    
   MTOT_PRO  = 0
   MWORK_COST = 0
   MLAST_COST = 0
   SELECT B
   DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT, IDTL_DTL, INVN_PO, INVNDISP, DTL_DATE, INVN_DTL", .F.
   
   SEEK A->FREEZ_LOC + A->LOT_NBR
   
   DO WHILE .NOT. EOF() .AND. A->FREEZ_LOC = FREEZ_LOC .AND. A->LOT_NBR = LOT_NBR
      IF MLINE > 22
         @ 24,1 SAY 'Action: 1   1. Next Page'
         MACTION = 1
         @ 24,9 GET MACTION PICTURE '#' RANGE 1,1
         READ
         MLINE = 4 
         @ 4,4 CLEAR TO 22,78
         @ 24,0 clear
      ENDIF
      
      DO CASE    
      CASE ACT_CODE = 'C'
         IF COST_AMT = 0
            SKIP
            LOOP
         ENDIF
         MTOT_COST = MTOT_COST + COST_AMT
         MWORK_COST = MWORK_COST + COST_AMT
      CASE ACT_CODE = 'S'
         IF SHIP_LBS = 0
            SKIP
            LOOP
         ENDIF
         MTHIS_COST =  ROUND(ROUND(MWORK_COST/MLBS_LEFT,4) * SHIP_LBS,2)
         *** DISPLAY SHIPMENT INFO       
         IF SALESMAN <> SPACE(2)
            @ MLINE,4 SAY SALESMAN + '-'
         ENDIF
         @ MLINE,7 SAY PO_NBR
         IF PO_SUFFIX <> ' '
            @ MLINE,11 SAY '-' + PO_SUFFIX
         ENDIF
         @ MLINE,14 SAY ACT_DATE
         @ MLINE,23 SAY SHIP_CASE  PICTURE '####'
         @ MLINE,28 SAY SHIP_LBS   PICTURE '999999'
         @ MLINE,35 SAY SUBSTR(SHIP_NAME,1,9)
         @ MLINE,44 SAY SHIP_PRI PICTURE '99.9999'
         @ MLINE,52 SAY SHIP_VAL PICTURE '999999.99' 
         @ MLINE,62 SAY ROUND(MWORK_COST/MLBS_LEFT,4) PICTURE '99.9999'
         @ MLINE,70 SAY ROUND(MTHIS_COST,2) PICTURE '99999.99'
         MLAST_COST = MTHIS_COST
         MLINE = MLINE + 1
         MTOT_PRO  = MTOT_PRO + MTHIS_COST
         MWORK_COST = MWORK_COST - MTHIS_COST
         MLBS_LEFT  = MLBS_LEFT  - SHIP_LBS
      ENDCASE
      SKIP
   ENDDO
   
ENDCASE
@ 24,1 SAY 'Action: 1   1. Return'
MACTION = 1
@ 24,9 GET MACTION PICTURE '#' RANGE 1,1
READ




RETURN

PROCEDURE IACT_RPT
********



RETURN

PROCEDURE IMAINT
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
MTITLE = ' - REINDEX FILES'
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 25,79

@ 07,10 SAY 'This will reindex the data files.  It will take a few minutes.'
STORE 'NO ' TO MTEMP
SET CONFIRM ON
@ 11,20 SAY 'ARE YOU READY ?!?!?! (YES/NO) ' GET MTEMP PICTURE '@!'

READ
SET CONFIRM OFF
IF MTEMP = 'YES'
   @ 4,1 CLEAR TO 22,78
   
   @ 17,20 SAY 'MAIN INVENTORY FILE......'
   USE INVEN EXCLUSIVE
   SET TALK ON
   SET ECHO ON
   SET STATUS ON
   
   PACK
   INDEX ON LOT_NBR TO INVNLOT
   INDEX ON SALESMAN+PO_NBR+PO_SUFFIX TO INVNPO
   INDEX ON FREEZ_LOC + LOT_NBR TO INVNLOC
   INDEX ON SOLD_FLG+DIV_CODE+PROD_DESC+DTOC(ANIV_DATE,7)+DTOC(ANIV_DATE,1,2)+DTOC(ANIV_DATE,4,2) + LOT_NBR TO INVNSOLD
   INDEX ON STR(I_NBR,5) TO INVNINBR
   INDEX ON SUBSTR(DTOC(ANIV_DATE),7)+SUBSTR(DTOC(ANIV_DATE),1,5) TO INVNANIV
   **INDEX ON CATEGORY + ISIZE + IPRODDESC TO INVNCAT 
   INDEX ON IPRODDESC TO INVNCAT 
   UNLOCK
   SET TALK OFF
   SET ECHO OFF
   SET STATUS OFF
   
   @ 17,01 SAY SPACE(78)  
   @ 17,20 SAY 'INVENTORY ACTIVITY DETAIL FILE....'
   USE INVN_DTL EXCLUSIVE
   SET TALK ON
   SET ECHO ON
   SET STATUS ON
   
   PACK
   INDEX ON STR(I_NBR,5)+SUBSTR(DTOC(ACT_DATE),7)+SUBSTR(DTOC(ACT_DATE),1,2)+SUBSTR(DTOC(ACT_DATE),4,2) TO IDTL_DTL
   INDEX ON STR(I_NBR,5) + SALESMAN + PO_NBR+PO_SUFFIX TO INVN_PO
   INDEX ON STR(I_NBR,5) + ACT_CODE + STR(CTOD('12/31/2099')-ACT_DATE,10) + ACT_CODE TO INVNDISP
   INDEX ON SUBSTR(DTOC(ACT_DATE),7)+SUBSTR(DTOC(ACT_DATE),1,5) TO DTL_DATE
   INDEX ON SALESMAN+PO_NBR+PO_SUFFIX+ITEM_NBR+ACT_CODE TO INVN_DTL
   INDEX ON FREEZ_LOC + LOT_NBR TO DTL_LOT
   UNLOCK
   
   SET TALK OFF
   SET ECHO OFF
   SET STATUS OFF
   
   @ 17,01 SAY SPACE(78)  
ENDIF
RETURN


PROCEDURE IRPT
*** THIS IS CHOICE NUMBER 1 REPORT 

MPAGE_LEN = 44
SELECT A
GOTO TOP
MTOT_LBS = 0
MTOT_CASE = 0
MTOT_AVLBS = 0
MTOT_AVCS = 0
MTOT_VALUE = 0
MTVAL_30 = 0
MTVAL_M30 = 0
MTLBS_30 = 0
MTLBS_M30 = 0

MCANCEL = .F.
DO WHILE .NOT. EOF()                     
   MPROD_DESC = IPRODDESC
   MSIZE = ISIZE
   MPROD_LBS = 0
   MPROD_CASE = 0
   MAV_LBS = 0
   MAV_CASE = 0
   MPRT_OUT = .T.
   IF MLINE <> 99 .AND. MLINE <> 6
      MLINE = MLINE + 1
   ENDIF
   DO WHILE .NOT. EOF() .AND. IPRODDESC = MPROD_DESC                      
      
      
      IF MSEL_PREFX+MSEL_PROD <> SPACE(12)
         IF MSEL_PREFX+MSEL_PROD <> IPRODDESC
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.SUP_PROD INDEX &MDBFLOC.SUP_PROD", .F.
      SEEK A->IPRODDESC
      IF EOF()
         ****MPRT_PROD = 'CODE NOT ON FILE'
         SELECT C
         DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
         
         MPRT_IT = TRIM(A->ISIZE)
         
         IF A->GRADE <> ' '
            DO CASE
            CASE A->GRADE = 'M'
               MGRADE = 'MAR'               
            CASE A->GRADE = 'S'
               MGRADE = 'SMK'              
            CASE A->GRADE = 'O'
               MGRADE = 'OVR'               
            OTHERWISE
               MGRADE = '   '
            ENDCASE
         ELSE
            MGRADE = '   '
         ENDIF
         
         MGRADE = TRIM(MGRADE)
         IF LEN(MPRT_IT) > 1
            IF LEN(MGRADE) > 1
               MPRT_IT = MPRT_IT + ' ' + MGRADE
            ENDIF     
         ELSE
            MPRT_IT = MGRADE
         ENDIF
         
         MPRT_IT = TRIM(MPRT_IT)
         IF LEN(MPRT_IT) > 1
            MPRT_IT = MPRT_IT + ' '
         ENDIF
         MLEN = LEN(MPRT_IT)
         MLEN = 40 - MLEN
         
         SEEK 'R' + SUBSTR(A->IPRODDESC,3,4)     
         IF EOF()       
            MPRT_PROD = MPRT_IT   
         ELSE
            MPRT_PROD = MPRT_IT + SUBSTR(DESC,1,MLEN)
         ENDIF
      ELSE
         MPRT_PROD = DESCRIP 
      ENDIF
      
      
      ** FREEZER NAME NOT USED NOW - MAYBE LATER
      SELECT B
      DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
      SEEK A->FRZR_CODE           
      IF .NOT. EOF()
         IF NAME = 'PREFERRED'
            MPRT_FRZR = 'PR' + SUBSTR(NAME,11,2)
         ELSE
            MPRT_FRZR = SUBSTR(NAME,1,6)
         ENDIF
      ELSE
         MPRT_FRZR = 'UNKNOW'
      ENDIF
      ** FREEZER NAME NOT USED NOW - MAYBE LATER
      
      DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
      SEEK A->RSUPCODE
      IF EOF()
         MPRT_SUP = SPACE(5)
      ELSE
         MPRT_SUP = SUBSTR(NAME,1,5)
      ENDIF
      SELECT A
      *** DO WIDE REPORT HERE - ELITE HAS 156 CHARS      
      IF MLINE > MPAGE_LEN
         IF MLINE <> 99
            EJECT        
         ENDIF
         DO INV_WHD1
         MPRT_OUT = .T.
      ENDIF
      
      @ MLINE,1 SAY LOT_NBR
      @ MLINE,10 SAY DTOC(ANIV_DATE)      
      IF SUBSTR(LOT_NBR,1,1) = 'P' .OR. SUBSTR(LOT_NBR,1,1) = 'O'
         @ MLINE,18 SAY '-NA'
      ENDIF
      @ MLINE,22 SAY MPRT_SUP
      IF SUBSTR(IPRODDESC,1,2) = '  '
         @ MLINE,29  SAY SUBSTR(MPROD_DESC,3)
      ELSE
         @ MLINE,29  SAY MPROD_DESC
      ENDIF
      @ MLINE,42 SAY MPRT_PROD                 
      IF BOX_SZ = 0    
         @ MLINE,85 SAY ' CWT'
      ELSE
         IF BOX_SZ - INT(BOX_SZ) <> 0
            @ MLINE,85 SAY BOX_SZ PICTURE '99.9' 
         ELSE
            @ MLINE,85 SAY BOX_SZ PICTURE '9999'
         ENDIF
      ENDIF
      
      *** NOW - FIGURE OUT WHAT IS LEFT
      IF SUBSTR(PACKED,1,1) = 'B' .OR. SUBSTR(PACKED,1,1) = 'H'
         *** WHAT WENT IN
         @ MLINE,90 SAY ROUND(CASE_CNT * BOX_SZ,2) PICTURE '999999'
         @ MLINE,97 SAY CASE_CNT PICTURE '9999'
         *** WHAT IS SOLD AND COMMITTED
         @ MLINE,103 SAY ROUND((CASE_SOLD+CASE_COM) * BOX_SZ,2) PICTURE '999999'
         @ MLINE,111 SAY CASE_SOLD+CASE_COM PICTURE '9999'
         
         MLBS_LEFT = ROUND(LBS_LEFT * BOX_SZ,2)
         MSTOR_UNIT = (STOR_LB * MLBS_LEFT) / LBS_LEFT
         MSTOR_UNIT = ROUND(MSTOR_UNIT,4)
         
         *** THIS IS AVAILABLE
         @ MLINE,118 SAY MLBS_LEFT - LBS_COM PICTURE '999999.99'
         @ MLINE,129 SAY CASE_LEFT - CASE_COM PICTURE '9999'
         
         *** PRICE/BOX AND PRICE/LB
         @ MLINE,135 SAY PRI_LB  PICTURE '99.9999'
         MPRI_LB = PRI_LB / BOX_SZ                     
         MPRI_LB = ROUND(MPRI_LB,4)
         @ MLINE,144 SAY MPRI_LB  PICTURE '99.9999'
         
         MDAYS = DATE() - A->ANIV_DATE
         IF MDAYS > 0
            @ MLINE,154 SAY MDAYS PICTURE '999'
         ENDIF
         
         MPROD_LBS = MPROD_LBS + MLBS_LEFT
         MPROD_CASE = MPROD_CASE + CASE_LEFT
         MAV_CASE = MAV_CASE + (CASE_LEFT - CASE_COM)
         MAV_LBS  = MAV_LBS + (MLBS_LEFT - LBS_COM)
         MVALUE = ROUND(CASE_LEFT*PRI_LB,2)
         MTOT_VALUE = MTOT_VALUE + MVALUE                       
         IF MDAYS <= 30                 
            MTLBS_30 = MTLBS_30 + MLBS_LEFT
            MTVAL_30 = MTVAL_30 + MVALUE
         ELSE
            MTLBS_M30 = MTLBS_M30 + MLBS_LEFT
            MTVAL_M30 = MTVAL_M30 + MVALUE     
            SELECT F
            SEEK A->RSUPCODE
            IF EOF()
               DO FILELOCK()
               APPEND BLANK
               REPLACE RSUPCODE WITH A->RSUPCODE
               UNLOCK
            ENDIF
            DO RECLOCK
            REPLACE OV30_LBS WITH OV30_LBS + MLBS_LEFT
            REPLACE OV30_VAL WITH OV30_VAL + MVALUE
            UNLOCK
            SELECT A
         ENDIF
      ELSE
         
         *** WHAT WENT IN
         @ MLINE,90 SAY LBS PICTURE '999999'
         @ MLINE,97 SAY CASE_CNT PICTURE '9999'
         *** WHAT IS SOLD AND COMMITTED
         @ MLINE,103 SAY LBS_SOLD+LBS_COM PICTURE '999999'
         @ MLINE,111 SAY CASE_SOLD+CASE_COM PICTURE '9999'
         
         *** THIS IS AVAILABLE
         @ MLINE,118 SAY LBS_LEFT - LBS_COM PICTURE '999999.99'
         @ MLINE,129 SAY CASE_LEFT - CASE_COM PICTURE '9999'
         
         *** SHOW PRICES
         @ MLINE,135 SAY PRI_LB  PICTURE '99.9999'
         @ MLINE,144 SAY PRI_LB  PICTURE '99.9999'
         
         MDAYS = DATE() - A->ANIV_DATE
         IF MDAYS > 0
            @ MLINE,154 SAY MDAYS PICTURE '999'
         ENDIF
         
         MPROD_LBS = MPROD_LBS + LBS_LEFT
         MPROD_CASE = MPROD_CASE + CASE_LEFT
         MAV_CASE = MAV_CASE + (CASE_LEFT - CASE_COM)
         MAV_LBS  = MAV_LBS + (LBS_LEFT - LBS_COM)
         MVALUE = ROUND(LBS_LEFT*PRI_LB,2)
         MTOT_VALUE = MTOT_VALUE + MVALUE                       
         IF MDAYS <= 30
            MTLBS_30 = MTLBS_30 + LBS_LEFT
            MTVAL_30 = MTVAL_30 + MVALUE
         ELSE
            MTLBS_M30 = MTLBS_M30 + LBS_LEFT
            MTVAL_M30 = MTVAL_M30 + MVALUE     
            SELECT F
            SEEK A->RSUPCODE
            IF EOF()
               DO FILELOCK()
               APPEND BLANK
               REPLACE RSUPCODE WITH A->RSUPCODE
               UNLOCK
            ENDIF
            DO RECLOCK
            REPLACE OV30_LBS WITH OV30_LBS + A->LBS_LEFT
            REPLACE OV30_VAL WITH OV30_VAL + MVALUE
            UNLOCK
            SELECT A
         ENDIF
      ENDIF
      MLINE = MLINE + 1
      SKIP
   ENDDO
ENDDO
*** DO GRAND TOTALS HERE
IF MLINE =  99     
   @ 6,1 SAY 'NO INVENTORY DATA SELECTED FOR REPORT'                            
ELSE
   MLINE = MLINE + 2
   IF MLINE+8 > MPAGE_LEN
      IF MLINE <> 99
         EJECT      
      ENDIF
      DO INV_HD1
      MLINE = MLINE + 2
   ENDIF
   
   MLINE = MLINE + 1
   @ MLINE,1 SAY 'TOTAL LBS   IN INVENTORY:           ' + TRANSFORM(MTLBS_30+MTLBS_M30, '9,999,999.99')
   MLINE = MLINE + 1
   @ MLINE,1 SAY 'TOTAL VALUE OF INVENTORY:           ' + TRANSFORM(MTOT_VALUE, '9,999,999.99')
   MLINE = MLINE + 2
   @ MLINE,1 SAY 'TOTAL LBS LESS/EQUAL   30 DAYS OLD: ' + TRANSFORM(MTLBS_30, '9,999,999.99')
   MLINE = MLINE + 1
   @ MLINE,1 SAY 'TOTAL VALUE LESS/EQUAL 30 DAYS OLD: ' + TRANSFORM(MTVAL_30, '9,999,999.99')
   MLINE = MLINE + 2
   @ MLINE,1 SAY 'TOTAL LBS MORE THAN   30 DAYS OLD:  ' + TRANSFORM(MTLBS_M30, '9,999,999.99')
   MLINE = MLINE + 1
   @ MLINE,1 SAY 'TOTAL VALUE MORE THAN 30 DAYS OLD:  ' + TRANSFORM(MTVAL_M30, '9,999,999.99')
   MLINE = MLINE + 2
   @ MLINE,1 SAY ' '
   SELECT B
   USE
   SELECT C
   USE
   SELECT D
   USE
   
   SELECT C
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
   
   DO WHILE .NOT. EOF()
      SELECT F
      SEEK C->RSUPCODE
      IF .NOT. EOF()
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT      
            ENDIF
            **DO INV_HD1
            MLINE = 3
            MLINE = MLINE + 2
         ENDIF
         @ MLINE,1 SAY C->NAME     
         @ MLINE,40 SAY 'OVER 30: LBS=' + TRANSFORM(OV30_LBS, '99,999,999.99')
         @ MLINE,72 SAY 'VALUE='+TRANSFORM(OV30_VAL, '99,999,999.99')
         MLINE = MLINE + 2
      ENDIF
      SELECT C
      SKIP
   ENDDO
   @ MLINE+1,1 SAY ' '
ENDIF
EJECT 

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON
IF MPRINTER3 <> 'DONOTPRINT'
   RUN &MPRINTIT3
ENDIF

MNEXT_SCRN = .F.
MMORE = .F.

SET DEVICE TO SCREEN
SET CONSOLE ON 

RETURN

PROCEDURE INV_HD1
CLEAR
MLINE = 1
@ MLINE,20 SAY '     MIDWEST INVENTORY - FOOD SERVICE ' + SPACE(14) + DTOC(DATE())        

IF MPRT_DISP = 'P'
   MPAGE = MPAGE + 1
   @ MLINE,86 SAY 'PAGE: ' + STR(MPAGE,3)
ENDIF
IF MPRT_DISP = 'D'
   MLINE = MLINE + 1
ELSE
   MLINE = MLINE + 2
ENDIF

@ MLINE,0 SAY 'VENDOR #     PRODUCT   BOX CASE    POUNDS CASE    POUNDS CASE    POUNDS    UNIT '
IF MPRT_DISP <> 'D'
   @ MLINE,81 SAY '  PRI/  CS DYS'
ENDIF
MLINE = MLINE + 1
@ MLINE,0 SAY '   LOT NBR   ANIV DT  SIZE LEFT      LEFT COMM      COMM AVAI     AVAIL   PRICE '
IF MPRT_DISP <> 'D'
   @ MLINE,81 SAY ' POUND SLD OLD'
ENDIF
IF MPRT_DISP = 'D'
   @ 4,0 TO 4,79
   @ 2,12 TO 22,12
   @ 2,21 TO 22,21
   @ 2,26 TO 22,26
   @ 2,31 to 22,31
   @ 2,41 TO 22,41
   @ 2,46 to 22,46
   @ 2,56 to 22,56
   @ 2,61 to 22,61
   @ 2,71 to 22,71
   @ 4,0 TO 4,79
ELSE
   @ MLINE,0 SAY REPLICATE('_',95)
ENDIF
IF MPRT_DISP = 'D'
   MLINE = 5
ELSE
   MLINE = 6
ENDIF
RETURN

PROCEDURE INV_DSP1
STORE MLINE TO MSAVE_LINE
CLEAR
MLINE = 1
@ MLINE,20 SAY '     MIDWEST INVENTORY - FOOD SERVICE ' + SPACE(14) + DTOC(DATE())        

MLINE = MLINE + 1

@ MLINE,0 SAY 'VENDOR #     PRODUCT             BOX    CASE    POUNDS   CASE    POUNDS    UNIT '

MLINE = MLINE + 1
@ MLINE,0 SAY '             LOT NBR   ANIV DT  SIZE    COMM      COMM  AVAIL     AVAIL   PRICE '
@ 4,0 TO 4,79
MLINE = 5
MNBR_LINES = 0
MPRT_OUT = .T.
STORE RECNO() TO MTOP_REC
RETURN

PROCEDURE INV_WHD1
MPAGE_NO = MPAGE_NO + 1
@ 1,1 SAY 'PAGE NBR: ' + STR(MPAGE_NO,2)
@ 1,35 SAY 'MIDWEST FOOD & POULTRY - FOOD SERVICE INVENTORY DETAIL' + SPACE(14) + DTOC(DATE())

MLINE = 3
@ MLINE,29 SAY 'PRODUCT'        
@ MLINE,85 SAY ' BOX'
@ MLINE,90 SAY '   LBS'
@ MLINE,97 SAY 'CASE'   
@ MLINE,103 SAY '   LBS'
@ MLINE,111 SAY 'CASE'    
@ MLINE,121 SAY '   LBS'      
@ MLINE,129 SAY 'CASE'   
@ MLINE,137 SAY ' UNIT'
@ MLINE,146 SAY 'PRICE'
@ MLINE,153 SAY 'DAYS'
MLINE = MLINE + 1
@ MLINE,1  SAY 'LOT NBR'
@ MLINE,11 SAY 'DATE IN'
@ MLINE,22 SAY 'SUP'     
@ MLINE,29 SAY 'CODE'
@ MLINE,42 SAY 'PRODUCT DESCRIPTION'
@ MLINE,85 SAY 'SIZE'
@ MLINE,90 SAY '    IN'
@ MLINE,97 SAY '  IN'   
@ MLINE,103 SAY ' SL/CM'
@ MLINE,110 SAY 'SL/CM'   
@ MLINE,121 SAY ' AVAIL'      
@ MLINE,128 SAY 'AVAIL'  
@ MLINE,137 SAY 'PRICE'
@ MLINE,146 SAY '  /LB'
@ MLINE,153 SAY ' OLD'
@ MLINE,1 SAY REPLICATE('_',156)
MLINE = MLINE + 2
RETURN

PROCEDURE INV_HD2
@ 1,20 SAY '     MIDWEST FOOD SERVICE INVENTORY' + SPACE(14) + DTOC(DATE())
MLINE = 2
IF MCUTOFF <> CTOD('')
   @ MLINE,25 SAY 'CUTOFF DATE AS OF: ' + DTOC(MCUTOFF)
   MLINE = MLINE + 1
ENDIF
MLINE = MLINE + 1
@ MLINE,47 SAY 'BOX CASE'
@ MLINE,59 SAY 'POUNDS'
@ MLINE,69 SAY 'UNIT'
@ MLINE,76 SAY 'COST'
@ MLINE,81 SAY 'CASE' 
MLINE = MLINE + 1
@ MLINE,0 SAY 'LOT NBR'
@ MLINE,09 SAY 'SUPLR' 
@ MLINE,15 SAY 'DATE IN'
@ MLINE,24 SAY 'PRODUCT DESC'
@ MLINE,48 SAY 'SZ LEFT'
@ MLINE,61 SAY 'LEFT'
@ MLINE,69 SAY 'COST' 
@ MLINE,78 SAY 'LB'
@ MLINE,81 SAY 'SOLD'
@ MLINE,0 SAY REPLICATE('_',86)
MLINE = MLINE + 2
RETURN

* EOF: INEWPROC.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/9/15 at 11:33 AM.
