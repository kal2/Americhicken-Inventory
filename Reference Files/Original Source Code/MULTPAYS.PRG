**********
* Program.: MULTPAYS.PRG
* Author..: GRACE KELLER
* Date....: 10/12/87 
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MULTIPLE MISCELLANEOUS PAYEES
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
MPAY_ADD = .F.
MMULT_PAY = .T.
DO WHILE MMULT_PAY
   
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
   @ 24,13 SAY '1.Next Pg  2.Prev  3.First  4.Add Payee  5.Cancel  6.Delete Payee'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MNAME_FD = .T.
      MMULT_PAY = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1.Next Pg  2.Prev  3.First  4.Add Payee  5.Cancel  6.Delete Payee'
   @ 24,09 GET MACTION PICTURE '9' RANGE 1,6
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
      MPAY_ADD = .T.
      MMULT_PAY = .F.
      MNAME_FD = .T.
   CASE MACTION = 5
      MMULT_PAY = .F.

   CASE MACTION = 6
      @ 22,23 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
      READ
   
      IF MSEL_NUM <> 0
         STORE 1 TO MSEQ_NUM
         GOTO MFST_REC
         DO WHILE MSEQ_NUM <> MSEL_NUM
            SKIP
            STORE MSEQ_NUM + 1 TO MSEQ_NUM
         ENDDO     
         @ 5,1 CLEAR TO 5,78
         @ 7,1 CLEAR TO 20,78
         @ 08, 5 SAY NAME
         @ 08,42 SAY CITY    
         @ 08,71 SAY STATE
         STORE ' ' TO MYES_NO
         @ 10,5 SAY 'Delete this Payee (Y/N)? ' GET MYES_NO PICTURE '@!' VALID(MYES_NO = 'N' .OR. MYES_NO = 'Y')
         READ
         IF MYES_NO = 'Y'
            DO RECLOCK
            DELETE
            UNLOCK
         ENDIF
         MMULT_PAY = .F.
      ELSE
         MMULT_PAY = .F.
      ENDIF
   ENDCASE
   
ENDDO

RETURN
* EOF: MULTPAYS.PRG
*Formatted by: FoxToolBox Ver. 0.8c on October 28, 1987 at 2:09 PM.
