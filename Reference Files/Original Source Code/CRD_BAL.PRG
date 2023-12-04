**********
* Program.: CRD_BAL.PRG
* Author..: Grace Keller
* Date....: 12/22/89
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: CREATE ENTRIES TO MOVE CREDITS FROM CREDIT BALANCE ACCOUNT TO 
*         : TO CUSTOMER FILE 
*
STORE DATE() TO MPAID_DATE
DIMENSION MUPDRCD(30)  
DIMENSION MPAYIND(30)
DIMENSION MPAYAMT(30)
DIMENSION MPAY_DUE(30)
DIMENSION MCK(11)
DIMENSION MREC(11)
DIMENSION MPD_AMT(11)
DIMENSION MAMT(11)
DIMENSION MSHRT(11)
DIMENSION MDUE(11)
DIMENSION MSW(11)
MNEXT_CUST = .T.

SELECT B
DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE, PAY_CUST, PAY_PO, PAY_SYS", .F.

SELECT C
DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.

DO WHILE MNEXT_CUST
   MTITLE = ' - MOVE CREDITS TO CUSTOMER ACCOUNTS'
   CLEAR
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 to 24,79
   STORE 'NO ' TO MYES_NO
   STORE 2 TO MACTION
   DO WHILE MACTION = 2
      @ 10,5 SAY 'Do you want to select a specific customer (YES/NO)? ' get myes_no picture '@!' 
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue      2. Edit      3. Cancel'    
      READ
      @ 24,09 GET MACTION PICTURE '#' RANGE 1,3
      READ
   ENDDO
   IF MACTION = 3
      MNEXT_CUST = .F.
      LOOP
   ENDIF
   IF MYES_NO = 'YES'
      MNAME_FD = .F.
      DO BBUYSEL3
      IF .NOT. MNAME_FD
         MNEXT_CUST = .F.
         LOOP
      ENDIF
      STORE NAME TO MNAME
      STORE BBUYCODE TO MOPT_BBUY
      STORE STREET TO MSTREET
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
      STORE ZIP TO MZIP
   ELSE
      MNEXT_CUST = .F.
      STORE SPACE(4) TO MOPT_BBUY
   ENDIF
   SET PROC TO PAY_PROC
   MTITLE = ' - MOVE CREDITS TO CUSTOMER ACCOUNTS'
   CLEAR
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 to 24,79
   IF MOPT_CUST 
      @ 04,1  SAY 'Customer:'
      @ 04,11 say mname
      @ 05,11 SAY TRIM(MCITY) + ', ' + MSTATE
   ELSE
      @ 4,1 SAY 'No Customer Selected'
   ENDIF
   @ 06,1 to 06,78 
   @ 06,1 say 'OUTSTANDING CREDITS'
   SELECT B
   *** ' ' = UNPAID
   *** 'CRED' CREDIT BALANCE ACCOUNT CODE
   SEEK ' ' +  'CRED'
   IF MOPT_BBUY = SPACE(4)
      IF EOF()
         @ 14,1 SAY 'THERE ARE NO OUTSTANDING CREDITS FOR THIS CUSTOMER '
         @ 16,1 SAY 'PLEASE SELECT ANOTHER CUSTOMER'       
         @ 17,1 SAY ' '
         WAIT 'PRESS RETURN TO CONTINUE'
         LOOP
      ENDIF
   ELSE
      MNOT_FOUND = .T.
      DO WHILE .NOT. EOF() .AND. PAID_FLG = ' ' .AND. BBUYCODE = 'CRED' .AND. MNOT_FOUND
         IF ORIG_BUY = MOPT_BBUY
            MNOT_FOUND = .F.
            LOOP
         ENDIF 
         SKIP
      ENDDO
      IF MNOT_FOUND
         @ 14,1 SAY 'THERE ARE NO OUTSTANDING CREDITS FOR THIS CUSTOMER '
         @ 16,1 SAY 'PLEASE SELECT ANOTHER CUSTOMER'       
         @ 17,1 SAY ' '
         WAIT 'PRESS RETURN TO CONTINUE'
         LOOP
      ENDIF
      
   ENDIF
   STORE RECNO() TO MRECNO             
   STORE 0 TO MUPDRCD, MPAYIND, MPAYAMT
   MSUB = 0
   MTOT_PAID = 0
   
   MNOT_DONE = .T.
   DO WHILE MNOT_DONE
      STORE 0 TO MREC, MPD_AMT, MAMT, MSHRT, MDUE
      STORE ' ' TO MCK, MSW
      GOTO MRECNO
      MLINE = 12
      @ 12,1 CLEAR TO 22,78
      @ 24,0 CLEAR
      DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. BBUYCODE = 'CRED' 
         IF MOPT_BBUY <> SPACE(4)
            IF MOPT_BBUY <> ORIG_BUY
               SKIP
               LOOP
            ENDIF
         ENDIF
         STORE INV_NBR TO MINV_NBR
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         STORE TRAN_DATE TO MINV_DATE       
         I = MLINE - 11
         STORE I TO MI
         STORE RECNO() TO MREC(MI)
         MAMT(MI) = TOT_SELL                                   
         MDUE(MI) = TOT_SELL - AMT_PAID
         @ MLINE,1 SAY STR(MI,2) + '.'
         @ mline,6  say INV_NBR 
         @ mline,14 say TRAN_DATE     
         @ mline,24 SAY MAMT(MI) picture '999,999.99'
         @ mline,48 SAY MDUE(MI) picture '999,999.99'
         SKIP
         MLINE = MLINE + 1
      ENDDO
      MMAX_LINE = MLINE - 1
      STORE RECNO() TO MRECNO
      IF .NOT. EOF() .AND. LED_CODE = 'CRED' .AND. PAID_FLG = ' '
         IF MOPT_BBUY <> SPACE(4)
            IF MOPT_BBUY = ORIG_BUY
               @ 25,70 SAY 'More Inv.'
               MBLURP = .T.
            ELSE
               @ 25,70 24,78
               MBLURP = .F.
            ENDIF
         ELSE
            @ 25,70 SAY 'More Inv.'
            MBLURP = .T.
         ENDIF
      ELSE
         @ 25,70 to 24,78
         MBLURP = .F.
      ENDIF
      
      MLINE = 12
      I = 1
      DO WHILE MLINE <= MMAX_LINE
         STORE I TO MI
         
         *********************************
         DO PAY_GF2          
         *********************************
         MLINE = MLINE + 1
         I = I + 1
      ENDDO
      STORE 1 TO MACTION
      @ 25,01 SAY 'Action: ' + STR(MACTION,1)
      IF MBLURP
         @ 25,13 SAY '1. Save & Return    2. Edit    3. Next Page    4. Cancel'    
      ELSE
         @ 25,13 SAY '1. Save & Return    2. Edit    3. Cancel'    
      ENDIF
      READ
      I = 1 
      DO WHILE I <= 11
         STORE I TO MI
         IF MCK(MI) <> ' ' .AND. MCK(MI) <> 'P' .AND. MCK(MI) <> 'X' .AND. MCK(MI) <> 'F' 
            @ 25,0 CLEAR
            STORE ' ' TO MWAIT
            MERR_LINE = I       
            MERR_LINE = STR(MERR_LINE,2)
            @ 25,0 SAY 'CREDIT INDICATOR ON LINE ' + MERR_LINE + ' INVALID - PRESS RETURN TO REENTER ' GET MWAIT
            READ
            LOOP
         ENDIF
         IF MCK(MI) = 'P' .AND. MPD_AMT(MI) = 0
            @ 25,0 CLEAR
            STORE ' ' TO MWAIT
            MERR_LINE = I      
            MERR_LINE = STR(MERR_LINE,2)
            @ 25,0 SAY 'PARTIAL CREDIT ON LINE ' + MERR_LINE + ' BUT NO AMOUNT ENTERED - PRESS RETURN TO REENTER' GET MWAIT
            READ
            LOOP
         ENDIF
         IF (MCK(MI) <> 'F' .AND. MCK(MI) <> 'X'.AND. MCK(MI) <> ' ') .AND. MDUE(MI) > 0 .AND. MPD_AMT(MI) < MDUE(MI)
            @ 25,0 CLEAR
            STORE ' ' TO MWAIT
            MERR_LINE = I      
            MERR_LINE = STR(MERR_LINE,2)
            @ 25,0 SAY 'CREDIT AMT ENTERED MORE THAN CREDIT AMOUNT LEFT ON LINE '+ MERR_LINE + ' ' GET MWAIT 
            READ
            LOOP
         ENDIF
         
         I = I + 1
      ENDDO
      MLINE = 12
      I = 1
      MPG_PAID = 0
      DO WHILE I <= 11
         IF MCK(I) = ' '
            I = I + 1
            MLINE = MLINE + 1
            LOOP
         ENDIF
         IF (MCK(I) = 'X' .OR. MCK(I) = 'F') .AND. MPD_AMT(I) = 0
            @ MLINE,69 GET  MDUE(I) PICTURE '999,999.99'
            CLEAR GETS
            MPG_PAID = MPG_PAID + MDUE(I)
         ELSE
            MPG_PAID = MPG_PAID + MPD_AMT(I)
         ENDIF
         I = I + 1
         MLINE = MLINE + 1
      ENDDO
      @ 6,50 SAY 'Total Credits Selected '
      @ 7,57 SAY MPG_PAID + MTOT_PAID PICTURE '999,999.99'
      
      IF MBLURP
         @25,09 GET MACTION PICTURE '9' RANGE 1,4
      ELSE
         @25,09 GET MACTION PICTURE '9' RANGE 1,3
      ENDIF
      READ               
      IF MACTION = 2
         STORE MFST_REC TO MRECNO
         MNOT_DONE = .F.
         LOOP
      ENDIF
      
      IF MBLURP      
         IF MACTION = 4
            MNOT_DONE = .F.
            LOOP
         ENDIF
      ELSE
         IF MACTION = 3
            MNOT_DONE = .F.
            LOOP
         ENDIF
      ENDIF
      
      I = 1 
      DO WHILE I <= 11
         IF MCK(I) = ' '
            I = I + 1
            LOOP
         ENDIF
         STORE I TO MI
         MSUB = MSUB + 1
         
         STORE MCK(MI) TO MPAYIND(MSUB)
         IF MPD_AMT(MI) = 0
            STORE MDUE(MI) TO MPAYAMT(MSUB)
         ELSE
            STORE MPD_AMT(MI) TO MPAYAMT(MSUB)
         ENDIF
         STORE MDUE(MI) TO MPAY_DUE(MSUB)
         STORE MREC(MI) TO MUPDRCD(MSUB)
         I = I + 1
      ENDDO
      MTOT_PAID = MTOT_PAID + MPG_PAID
      
      IF MACTION = 3
         LOOP
      ENDIF
      I = 1
      DO WHILE I <= MSUB
         SELECT B
         GOTO MUPDRCD(I)
         DO RECLOCK
         REPLACE CRD_USED WITH CRD_USED + MPAYAMT(I)
         UNLOCK
         IF CRD_USED = AMOUNT
            DO FILELOCK
            REPLACE CRD_FLAG WITH 'Y'
            UNLOCK
         ENDIF
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         STORE BBUYCODE TO MBBUYCODE
         STORE TRAN_DATE TO MTRAN_DATE
         STORE INV_NBR TO MINV_NBR
         MDEB_CRD = 'Y'
         *******************  
         ** RECEIPTS FILE ** 
         *******************
         SELECT B
         DO FILELOCK
         ****** THIS IS FOR CREDIT BALANCE ACCOUNT
         APPEND BLANK
         REPLACE SALESMAN WITH MSALESMAN
         REPLACE PO_NBR WITH MPO_NBR
         REPLACE PO_SUFFIX WITH MPO_SUFFIX
         REPLACE BBUYCODE WITH MBBUYCODE
         REPLACE CRED_ACCT WITH 'Y'
         REPLACE PAID_DATE WITH MPAID_DATE
         REPLACE SYS_DATE WITH DATE()
         REPLACE INV_NBR WITH MINV_NBR
         REPLACE DEB_CRD WITH MDEB_CRD
         REPLACE INV_DATE WITH MTRAN_DATE
         REPLACE AMT_PAID WITH MPAYAMT(I)
         
         ***** THIS IS FOR CUSTOMER ACCOUNT      
         APPEND BLANK
         REPLACE SALESMAN WITH MSALESMAN
         REPLACE PO_NBR WITH MPO_NBR
         REPLACE PO_SUFFIX WITH MPO_SUFFIX
         REPLACE BBUYCODE WITH MBBUYCODE
         REPLACE PAID_DATE WITH MPAID_DATE
         REPLACE SYS_DATE WITH DATE()
         REPLACE INV_NBR WITH MINV_NBR
         REPLACE DEB_CRD WITH MDEB_CRD
         REPLACE INV_DATE WITH MTRAN_DATE
         REPLACE AMT_PAID WITH (-1) * MPAYAMT(I)
         UNLOCK
         ***** MAKE AN ENTRY ON CUSTOMER PAYMENT FILE ****
         ***** CUS_INV FILE
         
         SELECT C
         DO FILELOCK 
         APPEND BLANK
         REPLACE SALESMAN   WITH MSALESMAN  
         REPLACE PO_NBR     WITH MPO_NBR    
         REPLACE PO_SUFFIX  WITH MPO_SUFFIX 
         REPLACE BBUYCODE   WITH MBBUYCODE  
         REPLACE SHIP_DATE  WITH MTRAN_DATE   
         REPLACE TOT_SELL   WITH MPAYAMT(I)                  
         REPLACE INV_NBR    WITH MINV_NBR
         REPLACE DEB_CRD    WITH 'Y'
         REPLACE INV_DATE   WITH MTRAN_DATE
         UNLOCK
         
         SELECT B
         I = I + 1
      ENDDO
      FLUSH
      MNOT_DONE = .F.
   ENDDO
ENDDO
CLOSE DATA

RETURN
* EOF: CRD_BAL.PRG
*Formatted by: ToolBox Ver. 1.2  on 1/3/90 at 10:33 AM.
