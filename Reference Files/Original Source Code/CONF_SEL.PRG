**********
* Program.: CONF_SEL.PRG
* Author..: GRACE KELLER
* Date....: 12/17/2007 
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SELECT FREIGHT CONFIRMATIONS TO UPDATE/DELETE
*

*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - FREIGHT CONFIRMATION SELECT'
@ 3,0 TO 21,79
@ 4,5 SAY 'SELECT CONFIRMATION FOR: ' + MNAME 

@ 6,5 say 'CONF DATE    PO NUMBERS'

MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
MPAGE = 1
MMULT_SUP = .T.
DO WHILE MMULT_SUP
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   I = 1
   DO WHILE I <= 13
      MI = SUBSTR(STR(I+100,3),2)
      STORE 0 TO MREC&MI
      I = I + 1
   ENDDO

   DO WHILE .NOT. EOF() .AND. FRT_CODE = SRCH_ARG .AND. MLINE < 20
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      MI = SUBSTR(STR((MLINE-6)+100,3),2)
      STORE RECNO() TO MREC&MI
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      @ MLINE, 5 SAY CONF_DATE
      I = 1
      MCOL = 18
      DO WHILE I<= 8
         MI = STR(I,1)
         IF PO&MI = SPACE(4)
            I = I + 1
            LOOP
         ENDIF
         @ MLINE,MCOL SAY PO&MI
         IF SUFF&MI <> ' '
            @ MLINE,MCOL+4 SAY '-' + SUFF&MI
         ENDIF
         MCOL = MCOL + 8
         I = I + 1
      ENDDO
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. FRT_CODE = SRCH_ARG
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Select Supplier Number: '
   @ 22,25 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Next Pg.   2. Previous Pg.   3. First Pg.   4. Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MX = MSEL_NUM - ((MPAGE-1)*13)
      MX = SUBSTR(STR(MX+100,3),2)
      GOTO MREC&MX
      MMULT_SUP = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1. Next Pg.   2. Previous Pg.   3. First Pg.   4. Cancel'
   @ 24,09 GET MACTION PICTURE '9' RANGE 1,4
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      MPAGE = MPAGE + 1
      @ 07,01 CLEAR TO 20,78
      IF .NOT. MORE_FLG
         GOTO MTOP_REC
         STORE MTOP_SEQ - 1 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 2
      MPAGE = MPAGE -1
      IF MPAGE <= 0
         MPAGE = 1
      ENDIF
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
      MPAGE = 1
      LOOP

   CASE MACTION = 4
      MMULT_SUP = .F.
      
   ENDCASE
   
ENDDO

RETURN
* EOF: CONF_SEL.PRG
*Formatted by: FoxToolBox Ver. 0.8c on October 28, 1987 at 2:05 PM.
