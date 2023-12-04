**********
* Program.: MULTSUP.PRG
* Author..: GRACE KELLER
* Date....: 10/12/87 
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MULTIPLE SUPPLIER
*

*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MULTIPLE MATCHES SELECT'
@ 3,0 TO 21,79
@  4, 2 SAY 'MORE THAN ONE PUCHASE ORDER MATCHES YOUR INPUT.  PLEASE SELECT ONE.'
@ 6,1 say '    PO NUMBER  INV NBR  SHIP DATE  TOTAL LBS   TOT PURCH   TOT SELL      NET'

MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC

MMULT_PO = .T.
DO WHILE MMULT_PO
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. BUYER_PO = SRCH_ARG .AND. MLINE < 20
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      IF SALESMAN <> SPACE(2)
         @ MLINE,5 SAY SALESMAN + '-'
      ENDIF
      
      @ MLINE,8 SAY PO_NBR
      IF PO_SUFFIX <> ' '
         @ MLINE,12 SAY '-'
         @ MLINE,13 SAY PO_SUFFIX
      ENDIF
      SELECT B
      SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
      IF .NOT. EOF()
         @ MLINE,25 SAY SHIP_DATE
         IF INV_NBR <> SPACE(5)
            IF SALESMAN <> SPACE(2)
               @ MLINE,16 SAY SALESMAN + '-'
            ENDIF
            @ MLINE,19 SAY INV_NBR   
         ENDIF
         @ MLINE,35 SAY TOT_LBS PICTURE '9999999.99'
         @ MLINE,48 SAY TOT_PURCH + BILL_ADJ PICTURE '999999.99'
         @ MLINE,59 SAY TOT_SELL PICTURE '999999.99'
         @ MLINE,70 SAY TOT_NET - BILL_ADJ PICTURE '999999.99'
      ENDIF
      MLINE = MLINE + 1
      SELECT A
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. BUYER_PO = SRCH_ARG
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Select PO Number: '
   @ 22,19 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Next Pg.    2. Previous Pg.    3. First Pg.    4. Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MMULT_PO = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1. Next Pg.    2. Previous Pg.    3. First Pg.    4. Cancel'
   @ 24,09 GET MACTION PICTURE '9' RANGE 1,4
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
      MMULT_PO = .F.
      
   ENDCASE
   
ENDDO

RETURN
* EOF: MULTPO.PRG
*Formatted by: dANALYST Ver. 7.3a on May 5, 1988 at 1:25 PM.
