**********
* Program.: MULTCOM.PRG
* Author..: GRACE KELLER
* Date....: 10/12/87 
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MULTIPLE 3RD PARTY COMMISSION PAYEES
*

*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MULTIPLE MATCHES SELECT'
@ 3,0 TO 21,79
@  5, 2 SAY 'MORE THAN ONE PAYEE MATCHES YOUR INPUT.  PLEASE SELECT ONE.'
@ 6,5 say 'NAME'
@ 6,42 SAY 'CITY'   
@ 6,70 SAY 'STATE'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC
MNAME_FD = .F.
MMULT_COM = .T.
DO WHILE MMULT_COM
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. NAME = SRCH_ARG .AND. MLINE < 20
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      @ MLINE, 5 SAY NAME
      @ MLINE,42 SAY CITY    
      @ MLINE,71 SAY STATE
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. NAME = SRCH_ARG
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Select Payee Number: '
   @ 22,23 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add Payee  5.Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MNAME_FD = .T.
      MMULT_COM = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add Payee  5.Cancel'
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
      DO COM_ADD
      MMULT_COM = .F.
      MNAME_FD = .T.
   CASE MACTION = 5
      MMULT_COM = .F.
      
   ENDCASE
   
ENDDO

RETURN
* EOF: MULTCOM.PRG
*Formatted by: FoxToolBox Ver. 0.8c on October 28, 1987 at 2:09 PM.
