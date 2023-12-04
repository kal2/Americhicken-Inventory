**********
* Program.: TAKE_CRD.PRG
* Author..: Grace Keller
* Date....: 01/04/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: CLEAR OUTSTANDING CREDITS  
*
DIMENSION MCK(14)
DIMENSION MREC(14)
DIMENSION MAMT(14)
MNEXT_CUST = .T.
SET PROC TO PAY_PROC
DO WHILE MNEXT_CUST
   MNAME_FD = .F.
   DO BBUYSEL3
   IF .NOT. MNAME_FD
      MNEXT_CUST = .F.
      LOOP
   ENDIF
   STORE NAME TO MNAME
   STORE BBUYCODE TO MBBUYCODE
   STORE STREET TO MSTREET
   STORE CITY TO MCITY
   STORE STATE TO MSTATE
   STORE ZIP TO MZIP
   SET PROC TO PAY_PROC
   MTITLE = ' - CLEAR OUTSTANDING CREDITS'
   CLEAR
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 to 24,79
   DO PAYCRDSF
   SELECT E
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
   
   SELECT B
   DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
   SEEK MBBUYCODE + ' '
   MNO_CRD = .T.
   DO WHILE .NOT. EOF() .AND. BBUYCODE = MBBUYCODE .AND. PAID_FLG = ' ' .AND. MNO_CRD
      IF SUBSTR(INV_NBR,1,1) = 'A' .OR. DEB_CRD = 'Y'
         IF TOT_SELL < 0
            MNO_CRD = .F.
            STORE RECNO() TO MRECNO
         ENDIF
      ENDIF
      SKIP
   ENDDO
   IF MNO_CRD
      @ 14,1 SAY 'THERE ARE NO OUTSTANDING CREDITS FOR THIS CUSTOMER '
      @ 16,1 SAY 'PLEASE REENTER THE CUSTOMER SELECTED'
      @ 17,1 SAY ' '
      WAIT 'PRESS RETURN TO CONTINUE'
      LOOP
   ENDIF
   
   MNOT_DONE = .T.
   DO WHILE MNOT_DONE
      STORE SPACE(1) TO MCK
      STORE 0 TO MCK_AMT, MTOT_PAID
      GOTO MRECNO
      MLINE = 09
      @ 09,1 CLEAR TO 22,78
      @ 24,0 CLEAR
      DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. MBBUYCODE = BBUYCODE .AND. PAID_FLG = ' '
         STORE INV_NBR TO MINV_NBR
         IF SUBSTR(MINV_NBR,1,1) <> 'A' .AND. DEB_CRD = ' '
            SKIP
            LOOP
         ENDIF
         IF TOT_SELL >=0
            SKIP
            LOOP
         ENDIF
         
         IF DTOC(SHIP_DATE) <> '  /  /  '
            STORE SHIP_DATE TO MINV_DATE
         ELSE
            STORE INV_DATE TO MINV_DATE
         ENDIF
         STORE DEB_CRD TO MDEB_CRD
         I = MLINE - 8 
         
         STORE I TO MI
         STORE RECNO() TO MREC(MI)
         MAMT(MI) = TOT_SELL - AMT_PAID
         
         DO PAYCRDSR
         SKIP
         MLINE = MLINE + 1
      ENDDO
      MMAX_LINE = MLINE - 1
      DO WHILE .NOT. EOF() .AND. DEB_CRD = ' ' .AND. BBUYCODE = MBBUYCODE .AND. PAID_FLG = ' '
         SKIP
      ENDDO
      STORE RECNO() TO MRECNO
      IF .NOT. EOF() .AND. BBUYCODE = MBBUYCODE .AND. PAID_FLG = ' '
         @ 23,70 SAY 'More ....'
         MBLURP = .T.
      ELSE
         @ 23,70 to 23,78
         MBLURP = .F.
      ENDIF
      
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         MLINE = 09
         I = 1
         DO WHILE MLINE <= MMAX_LINE
            STORE I TO MI
            DO PAYCRDGF         
            MLINE = MLINE + 1
            I = I + 1
         ENDDO
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         IF MBLURP
            @ 24,13 SAY '1. Save & Return    2. Edit    3. Next Page    4. Cancel'    
         ELSE
            @ 24,13 SAY '1. Save & Return    2. Edit    3. Cancel'    
         ENDIF
         READ
         I = 1 
         DO WHILE I <= 14 
            STORE I TO MI
            IF MCK(MI) <> ' ' .AND. MCK(MI) <> 'X' 
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT
               MERR_LINE = I + 11
               MERR_LINE = STR(MERR_LINE,2)
               @ 24,0 SAY 'SELECTION INDICATOR ON LINE ' + MERR_LINE + ' INVALID - PRESS RETURN TO REENTER ' GET MWAIT
               READ
               @ 24,0 CLEAR
               MACTION = 2
               I = 99
               LOOP
            ENDIF
            I = I + 1
         ENDDO
      ENDDO
      MLINE = 9 
      
      IF MBLURP
         @24,09 GET MACTION PICTURE '9' RANGE 1,4
      ELSE
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
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
            MEDIT = .F.
            LOOP
         ENDIF
      ELSE
         IF MACTION = 3
            MNOT_DONE = .F.
            MEDIT = .F.
            LOOP
         ENDIF
      ENDIF
      
      I = 1 
      DO WHILE I <= 14
         IF MCK(I) = ' '
            I = I + 1
            LOOP
         ENDIF
         STORE I TO MI
         SELECT B
         GOTO MREC(MI)
         ****** IF MORE THAN 300 DOLLARS HERE - MUST UPDATE BALANCE ON
         ****** BOOKS SO THAT THE PAID AMOUNT = INVOICE AMOUNT
         
         DO FILELOCK
         REPLACE PAID_FLG WITH 'Y'       
         UNLOCK
         ********** UPDATE COMMISSION FLAG TO BE PAID ON THE PO HEADER RCD 
         SELECT E
         SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
         IF .NOT. EOF()
            DO RECLOCK 
            REPLACE OVER_PD WITH OVER_PD + MAMT(MI)
            UNLOCK
            **** WRITE THE COMMISSION RECORD TO BE PAID IF NEEDED
         ENDIF
         I = I + 1
      ENDDO
      MNOT_DONE = .F.
      MEDIT = .F.
   ENDDO
ENDDO
CLOSE DATA

RETURN
* EOF: TAKE_CRD.PRG
*Formatted by: dANALYST Ver. 7.3a on August 25, 1988 at 2:15 PM.
