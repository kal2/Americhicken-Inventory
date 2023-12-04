**********
* Program.: CUST_SEL.PRG
* Author..: GRACE KELLER
* Date....: 10/12/87 
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MULTIPLE - CUSTOMER SELECT
*

*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MULTIPLE MATCHES SELECT'
@ 3,0 TO 21,79
@  5, 2 SAY 'MORE THAN ONE CUSTOMER MATCHES YOUR INPUT.  PLEASE SELECT ONE.'
@ 6,1 SAY 'SEL'
@ 6,5 say 'NAME'
@ 6,45 SAY 'CITY'   
@ 6,71 SAY 'STATE'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC
I = 1

MMULT_BUY = .T.
DO WHILE MMULT_BUY

   X = 1
   DO WHILE X <= 13
      MX = SUBSTR(STR(X+100,3),2)
      STORE SPACE(1) TO MSEL&MX
      STORE 0        TO MREC&MX
      X = X + 1
   ENDDO

   MLINE = 7
   X = 1
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. NAME = SRCH_ARG .AND. MLINE < 20
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF

      MX = SUBSTR(STR(X+100,3),2)
      STORE RECNO() TO MREC&MX

      @ MLINE, 2   GET MSEL&MX PICTURE '@!'
      @ MLINE, 1+3 SAY STR(MSEQ_NUM,2) + '.'
      @ MLINE, 5+3 SAY NAME
      @ MLINE,42+3 SAY CITY    
      @ MLINE,71+3 SAY STATE

      X = X + 1
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. NAME = SRCH_ARG
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Next Pg.   2. Finished'
   
   READ
   
   @ 24,09 GET MACTION PICTURE '9' RANGE 1,2
   READ               

   X = 1
   DO WHILE X <= 13
      MX = SUBSTR(STR(X+100,3),2)
      IF MREC&MX <> 0
         GOTO MREC&MX
      ENDIF
      IF MSEL&MX = 'X'
         MI = SUBSTR(STR(I+100,3),2)
         STORE BBUYCODE TO MCUST&MI
         I = I + 1
      ENDIF
      X = X + 1
   ENDDO

   IF MACTION = 1
      @ 07,01 CLEAR TO 20,78
      IF .NOT. MORE_FLG
         MMULT_BUY = .F.
      ELSE
         SKIP
      ENDIF
   ELSE
      MMULT_BUY = .F.
   ENDIF
   
ENDDO

RETURN
* EOF: CUST_SEL.PRG
*Formatted by: FoxToolBox Ver. 0.8c on October 28, 1987 at 2:05 PM.
