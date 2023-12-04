*****************
* Program.: APRV_FRT.PRG
* Author..: Grace Keller
* Date....: 03/13/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: APPROVE FREIGHT INVOICES FOR PAYMENTS
*
STORE 0 TO MSW_DIFF
MTITLE = ' - APPROVE FREIGHT INVOICES FOR PAYMENT'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 24,79
STORE 'Y' TO MYES_NO
* @ 10,4 SAY 'DO YOU WANT TO SELECT A SPECIFIC FREIGHT CARRIER (Y/N) ? ' GET MYES_NO PICTURE '@!'
* READ
* @ 10,4 CLEAR TO 10,78
DO CASE
CASE MYES_NO = 'Y'
   MNEXT_FRT = .T.
   DIMENSION MUPDRCD(15)  
   DIMENSION MSELECT(15)
   DIMENSION MDUE(15)
   
   DO WHILE MNEXT_FRT
      MNAME_FD = .F.
      STORE SPACE(32) TO MNAME
      DO FRT_SEL1
      IF .NOT. MNAME_FD 
         MNEXT_FRT = .F.
         LOOP
      ENDIF
      STORE FRT_CODE TO MFRT_CODE
      STORE NAME TO MNAME
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
      SET PROC TO REC_PROC
      MTOTAL = 0
      MTITLE = ' - APPROVE FREIGHT INVOICES FOR PAYMENT'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      DO APRVFSF
      SELECT D
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      
      SELECT C
      DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
      SEEK MFRT_CODE
      IF EOF()
         @ 10,5 SAY 'THERE ARE NO MATCHED INVOICES ON FILE FOR THIS FREIGHT CARRIER.'
         STORE ' ' TO MWAIT
         @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
         READ
         RETURN
      ENDIF
      
      STORE RECNO() TO MRECNO, MFST_REC
      MPAGE_TOT = 0   
      MMORE = .T.
      DO WHILE MMORE
         STORE ' ' TO MSELECT
         STORE 0 TO MUPDRCD, MADJUST
         GOTO MRECNO
         MLINE = 08
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         DO APRVFSF

         DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. MFRT_CODE = FRT_CODE
            I = MLINE - 7 
            STORE RECNO() TO MUPDRCD(I)
            STORE DUE_DATE TO MDUE_DATE    
            IF FRT_INV = SPACE(12)
               STORE SUBSTR(REASON,1,12) TO MINV_NBR
            ELSE
               STORE FRT_INV TO MINV_NBR
            ENDIF
            MADJ = 0     
            IF DEB_CRD = ' '                         
               IF FRT_SEQ <> '2'
                  SELECT B
                  SEEK C->SALESMAN + C->PO_NBR + C->PO_SUFFIX
                  IF .NOT. EOF()
                     IF FRT_PALL < 0
                        STORE FRT1_ADJ1 + FRT1_ADJ2 + FRT_PALL TO MADJ 
                     ELSE
                        STORE FRT1_ADJ1 + FRT1_ADJ2 TO MADJ 
                     ENDIF
                  ENDIF
               ENDIF
            ENDIF
            SELECT C
            MDUE(I) = AMT_DUE + MADJ
            
            IF APRVDFLG = 'Y'
               STORE 'X' TO MSELECT(I)
               MTOTAL = MTOTAL + MDUE(I)  
            ELSE
               IF APRVDFLG = 'H'
                  STORE 'H' TO MSELECT(I)
               ENDIF
            ENDIF
            DO APRVFSR
            SKIP
            MLINE = MLINE + 1
         ENDDO
         MMAX_LINE = MLINE - 1
         STORE RECNO() TO MRECNO
         IF .NOT. EOF() .AND. FRT_CODE = MFRT_CODE 
            @ 23,70 SAY "More PO's"
            MBLURP = .T.
         ELSE
            @ 23,70 CLEAR TO 23,79
            MBLURP = .F.
         ENDIF
         @ 5,57 SAY MTOTAL PICTURE '999,999.99'
         STORE MTOTAL TO MPAGE_TOT
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            MLINE = 8
            I = 1
            DO WHILE MLINE <= MMAX_LINE
               @ MLINE,7 GET MSELECT(I) PICTURE '@!'
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
            DO WHILE I <= 15
               IF MUPDRCD(I) = 0
                  I = I + 1
                  LOOP
               ENDIF
               GOTO MUPDRCD(I)
               STORE FRT_INV TO MFRT_INV
               IF MSELECT(I) = 'O'
                  **** THIS MEANS I HAVE TO OVERRIDE THE FREIGHT INVOICE NUMBER
                  MLINE = I + 7
                  @ MLINE,39 GET MFRT_INV 
                  READ
                  DO RECLOCK
                  REPLACE FRT_INV WITH MFRT_INV
                  UNLOCK
                  STORE ' ' TO MSELECT(I)
                  @ MLINE,7 GET MSELECT(I)
                  @ MLINE,39 SAY MFRT_INV
                  CLEAR GETS
               ENDIF
               I = I + 1
            ENDDO
            
            I = 1 
            DO WHILE I <= 15
               IF MUPDRCD(I) = 0
                  I = I + 1
                  LOOP
               ENDIF
               GOTO MUPDRCD(I)
               IF MSELECT(I) <> 'X' .AND. MSELECT(I) <> 'H'
                  IF APRVDFLG = 'Y'
                     MPAGE_TOT = MPAGE_TOT - MDUE(I)
                  ENDIF
               ELSE
                  IF MSELECT(I) = 'X'  
                     IF APRVDFLG = ' '
                        MPAGE_TOT = MPAGE_TOT + MDUE(I)
                     ENDIF
                  ENDIF
               ENDIF
               I = I + 1
            ENDDO
            @ 5,57 SAY MPAGE_TOT PICTURE '999,999.99'
            
            IF MBLURP
               @24,09 GET MACTION PICTURE '9' RANGE 1,4
            ELSE
               @24,09 GET MACTION PICTURE '9' RANGE 1,3
            ENDIF
            READ               
            IF MACTION = 2
               STORE MTOTAL TO MPAGE_TOT
               @ 5,57 SAY MPAGE_TOT PICTURE '999,999.99'
            ENDIF
         ENDDO          
         
         IF .NOT. MBLURP  .AND. MACTION = 3
            MACTION = 4
         ENDIF
         IF MACTION = 4
            MMORE = .F.
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 to 24,79
            STORE 'N' TO MYES_NO
            @ 10,5 SAY 'DO YOU WANT TO APPROVE FOR ANOTHER FREIGHT CARRIER (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'Y'
               MNEXT_FRT = .F.
            ELSE
               MPAGE_TOT = 0
            ENDIF
            LOOP
         ENDIF
         
         I = 1 
         DO WHILE I <= 15
            IF MUPDRCD(I) = 0
               I = I + 1
               LOOP
            ENDIF
            GOTO MUPDRCD(I)
            DO RECLOCK
            IF MSELECT(I) = ' '
               IF APRVDFLG = 'Y'  
                  MTOTAL = MTOTAL - MDUE(I) 
                  REPLACE APRVDFLG WITH ' '
               ENDIF
            ELSE
               IF MSELECT(I) = 'H'
                  IF APRVDFLG = 'Y'
                     MTOTAL = MTOTAL - MDUE(I)
                  ENDIF
                  REPLACE APRVDFLG WITH 'H'
               ELSE
                  IF MSELECT(I) = 'X'
                     IF APRVDFLG = ' '
                        MTOTAL = MTOTAL + MDUE(I)
                     ENDIF
                     REPLACE APRVDFLG WITH 'Y'       
                  ENDIF
               ENDIF
            ENDIF
            UNLOCK 
            I = I + 1
         ENDDO
         @ 5,57 SAY MTOTAL PICTURE '999,999.99'
         
         IF MACTION <> 3
            MMORE = .F.
         ENDIF
         
      ENDDO
   ENDDO
   
OTHERWISE
   DIMENSION MUPDRCD(17)  
   DIMENSION MSELECT(17)
   DIMENSION MDUE(17)
   MTOTAL = 0
   SELECT D
   DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
   SELECT B
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
   SELECT C
   DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
   IF EOF()
      @ 10,5 SAY 'THERE ARE NO MATCHED INVOICES ON FILE FOR FREIGHT CARRIERS.'
      STORE ' ' TO MWAIT
      @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
      READ
      RETURN
   ENDIF
   STORE RECNO() TO MRECNO, MFST_REC
   MPAGE_TOT = 0   
   MMORE = .T.
   SET PROC TO REC_PROC
   DO WHILE MMORE
      STORE ' ' TO MSELECT
      STORE 0 TO MUPDRCD           
      GOTO MRECNO
      DO APRVFSF1
      MLINE = 06
      @ 06,1 CLEAR TO 23,78
      @ 24,0 SAY SPACE(79)

      DO WHILE .NOT. EOF() .AND. MLINE < 23
         I = MLINE - 5 
         STORE FRT_CODE TO MFRT_CODE
         SELECT A
         SEEK MFRT_CODE
         IF .NOT. EOF()
            STORE NAME TO MNAME
         ELSE
            STORE 'FREIGHT CARRIER NOT ON FILE' TO MNAME
         ENDIF
         
         MADJ = 0     
         IF C->DEB_CRD = ' '
            SELECT B
            SEEK C->SALESMAN + C->PO_NBR + C->PO_SUFFIX
            IF .NOT. EOF()
               IF FRT_PALL < 0
                  STORE FRT1_ADJ1 + FRT1_ADJ2 + FRT_PALL TO MADJ 
               ELSE
                  STORE FRT1_ADJ1 + FRT1_ADJ2 TO MADJ 
               ENDIF
            ENDIF
         ENDIF
         SELECT C
         MDUE(I) = AMT_DUE + MADJ
         
         STORE RECNO() TO MUPDRCD(I)
         IF APRVDFLG = 'Y' 
            STORE 'X' TO MSELECT(I)
            MTOTAL = MTOTAL + MDUE(I)
         ELSE
            IF APRVDFLG = 'H'
               STORE 'H' TO MSELECT(I)
            ENDIF
         ENDIF
         STORE DUE_DATE TO MDUE_DATE    
         IF FRT_INV = SPACE(12)
            STORE SUBSTR(REASON,1,12) TO MINV_NBR
         ELSE
            STORE FRT_INV TO MINV_NBR
         ENDIF
         DO APRVFSR1
         SKIP
         MLINE = MLINE + 1
      ENDDO
      MMAX_LINE = MLINE - 1
      STORE RECNO() TO MRECNO
      IF .NOT. EOF()
         @ 23,70 SAY "More PO's"
         MBLURP = .T.
      ELSE
         @ 23,70 CLEAR TO 23,79
         MBLURP = .F.
      ENDIF
      @ 2,69 SAY MTOTAL PICTURE '999,999.99'
      STORE MTOTAL TO MPAGE_TOT
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         MLINE = 6
         I = 1
         DO WHILE MLINE <= MMAX_LINE
            @ MLINE,5 GET MSELECT(I) picture '@!'
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
         DO WHILE I <= 17
            IF MUPDRCD(I) = 0
               I = I + 1
               LOOP
            ENDIF
            GOTO MUPDRCD(I)
            STORE FRT_INV TO MFRT_INV
            IF MSELECT(I) = 'O'
               **** THIS MEANS I HAVE TO OVERRIDE THE FREIGHT INVOICE NUMBER
               MLINE = I + 7
               @ MLINE,39 GET MFRT_INV 
               READ
               DO RECLOCK
               REPLACE FRT_INV WITH MFRT_INV
               UNLOCK
               STORE ' ' TO MSELECT(I)
               @ MLINE,7 GET MSELECT(I)
               @ MLINE,45 SAY MFRT_INV
               CLEAR GETS
            ENDIF
            I = I + 1
         ENDDO
         
         I = 1 
         DO WHILE I <= 17
            IF MUPDRCD(I) = 0
               I = I + 1
               LOOP
            ENDIF
            GOTO MUPDRCD(I)
            IF MSELECT(I) <> 'X' .AND. MSELECT(I) <> 'H'
               IF APRVDFLG = 'Y'
                  MPAGE_TOT = MPAGE_TOT - MDUE(I)
               ENDIF
            ELSE
               IF MSELECT(I) = 'X'  
                  IF APRVDFLG = ' '
                     MPAGE_TOT = MPAGE_TOT + MDUE(I)
                  ENDIF
               ENDIF
            ENDIF
            
            I = I + 1
         ENDDO
         @ 2,69 SAY MPAGE_TOT PICTURE '999,999.99'
         
         IF MBLURP
            @24,09 GET MACTION PICTURE '9' RANGE 1,4
         ELSE
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
         ENDIF
         READ               
         IF MACTION = 2
            STORE MTOTAL TO MPAGE_TOT
            @ 2,69 SAY MPAGE_TOT PICTURE '999,999.99'
         ENDIF
      ENDDO          
      
      IF (.NOT. MBLURP .AND. MACTION = 3) .OR. MACTION = 4
         RETURN
      ENDIF
      I = 1 
      DO WHILE I <= 17
         IF MUPDRCD(I) = 0
            I = I + 1
            LOOP
         ENDIF
         GOTO MUPDRCD(I)
         DO RECLOCK
         IF MSELECT(I) = ' '
            IF APRVDFLG = 'Y'  
               MTOTAL = MTOTAL - MDUE(I) 
               REPLACE APRVDFLG WITH ' '
            ENDIF
         ELSE
            IF MSELECT(I) = 'H'
               IF APRVDFLG = 'Y'
                  MTOTAL = MTOTAL - MDUE(I)
               ENDIF
               REPLACE APRVDFLG WITH 'H'
            ELSE
               IF MSELECT(I) = 'X'
                  IF APRVDFLG = ' '
                     MTOTAL = MTOTAL + MDUE(I)
                  ENDIF
                  REPLACE APRVDFLG WITH 'Y'       
               ENDIF
            ENDIF
         ENDIF
         UNLOCK 
         I = I + 1
      ENDDO
      IF MACTION = 1
         MMORE = .F.
         LOOP
      ENDIF
      @ 2,69 SAY MTOTAL PICTURE '999,999.99'
      
   ENDDO
ENDCASE
CLOSE DATA

RETURN
* EOF: APRV_FRT.PRG
*Formatted by: ToolBox Ver. 1.2  on 5/1/97 at 12:58 PM.
