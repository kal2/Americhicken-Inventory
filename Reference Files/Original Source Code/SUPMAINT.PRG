************
* Program.: SUPMAINT.PRG
* Author..: Grace Keller
* Date....: 01/25/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SUPPLIER MAINTENANCE SCREEN            
*
STORE 0 TO MSW_DIFF
MTITLE = ' - APPROVE SUPPLIER INVOICES FOR PAYMENT'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 24,79
STORE 'N' TO MYES_NO
@ 10,4 SAY 'DO YOU WANT TO SELECT A SPECIFIC SUPPLIER (Y/N) ? ' GET MYES_NO PICTURE '@!'
READ
@ 10,4 CLEAR TO 10,78
DO CASE
CASE MYES_NO = 'Y'
   MNEXT_CUST = .T.
   DIMENSION MUPDRCD(15)  
   DIMENSION MSELECT(15)
   DIMENSION MDUE(15)
   
   DO WHILE MNEXT_CUST
      MNAME_FD = .F.
      STORE SPACE(32) TO MNAME
      DO RSUPSEL3
      IF .NOT. MNAME_FD 
         MNEXT_CUST = .F.
         LOOP
      ENDIF
      STORE RSUPCODE TO MRSUPCODE
      STORE NAME TO MNAME
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
      SET PROC TO REC_PROC
      MTOTAL = 0
      MTITLE = ' - APPROVE SUPPLIER INVOICES FOR PAYMENT'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      DO APRV_SF
      SELECT D
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      
      SELECT C
      DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
      SEEK MRSUPCODE
      IF EOF()
         @ 10,5 SAY 'THERE ARE NO MATCHED INVOICES ON FILE FOR THIS SUPPLIER.'
         STORE ' ' TO MWAIT
         @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
         READ
         CLOSE DATA
         RETURN
      ENDIF
      DO FILELOCK
      STORE RECNO() TO MRECNO, MFST_REC
      MPAGE_TOT = 0   
      MMORE = .T.
      DO WHILE MMORE
         STORE ' ' TO MSELECT
         STORE 0 TO MUPDRCD, MADJUST
         GOTO MRECNO
         MLINE = 08
         @ 08,1 CLEAR TO 22,78
         @ 24,0 CLEAR
         DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. MRSUPCODE = RSUPCODE                     
            I = MLINE - 7 
            STORE RECNO() TO MUPDRCD(I)
            STORE DUE_DATE TO MDUE_DATE    
            IF SUP_INV = SPACE(12)
               STORE SUBSTR(REASON,1,12) TO MINV_NBR
            ELSE
               STORE SUP_INV TO MINV_NBR
            ENDIF
            IF DEB_CRD = ' '
               SELECT B
               SEEK C->SALESMAN + C->PO_NBR + C->PO_SUFFIX
               IF .NOT. EOF()
                  IF SUP_PALL < 0
                     STORE (-1 * SW_PURCH) + SUP_AMT1 + SUP_AMT2  + SUP_PALL TO MADJ 
                  ELSE
                     STORE (-1 * SW_PURCH) + SUP_AMT1 + SUP_AMT2 TO MADJ 
                  ENDIF
                  DO TOTDIFF 
                  MADJ = MADJ - MSW_DIFF
               ELSE      
                  STORE 0 TO MADJ
               ENDIF
            ELSE
               STORE 0 TO MADJ
            ENDIF
            SELECT C
            MDUE(I) = AMT_DUE + MADJ
            IF APRVDFLG <> ' '
               STORE 'X' TO MSELECT(I)
               MTOTAL = MTOTAL + MDUE(I)  
            ENDIF
            
            IF HOLD_FLG <> ' '
               IF HOLD_FLG = 'S'
                  STORE 'S' TO MSELECT(I)
               ELSE
                  STORE 'H' TO MSELECT(I)
               ENDIF
            ENDIF
            
            IF ADDL_DUE <> ' '
               STORE 'U' TO MSELECT(I)
            ENDIF
            
            DO APRV_SR
            SKIP
            MLINE = MLINE + 1
         ENDDO
         MMAX_LINE = MLINE - 1
         STORE RECNO() TO MRECNO
         IF .NOT. EOF() .AND. RSUPCODE = MRSUPCODE 
            @ 23,70 SAY "More PO's"
            MBLURP = .T.
         ELSE
            @ 23,70 to 23,78
            MBLURP = .F.
         ENDIF
         @ 5,57 SAY MTOTAL PICTURE '999,999.99'
         STORE MTOTAL TO MPAGE_TOT
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            MLINE = 8
            I = 1
            DO WHILE MLINE <= MMAX_LINE
               IF MSELECT(I) <> 'H' .AND. MSELECT(I) <> 'U' .AND. MSELECT(I) <> 'S'
                  @ MLINE,7 GET MSELECT(I) PICTURE '@!'
               ELSE 
                  @ MLINE,7 SAY MSELECT(I) PICTURE '@!'
               ENDIF
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
               IF MUPDRCD(I) = 0 .OR. MSELECT(I) = 'H' .OR. MSELECT(I) = 'U'
                  I = I + 1
                  LOOP
               ENDIF
               SELECT C
               GOTO MUPDRCD(I)
               STORE SUP_INV TO MSUP_INV 
               IF MSELECT(I) = 'O'
                  **** THIS MEANS I HAVE TO OVERRIDE THE SUPPLIER INVOICE NUMBER
                  MLINE = I + 7
                  @ MLINE,39 GET MSUP_INV 
                  READ
                  DO RECLOCK
                  REPLACE SUP_INV WITH MSUP_INV
                  UNLOCK
                  STORE ' ' TO MSELECT(I)
                  @ MLINE,7 GET MSELECT(I)
                  @ MLINE,39 SAY MSUP_INV
                  CLEAR GETS
               ENDIF
               IF MSELECT(I) = 'S' 
                  **** THIS MEANS I NEED TO PUT THIS RECORD ON STOP PAYMENT HOLD
                  MLINE = I + 7
                  DO RECLOCK
                  REPLACE HOLD_FLG WITH 'S'      
                  UNLOCK
                  @ MLINE,7 SAY MSELECT(I)
               ENDIF
               IF MSELECT(I) = 'X' .AND. MUPDRCD(I) <> 0      
                  SELECT B
                  SEEK C->SALESMAN + C->PO_NBR + C->PO_SUFFIX
                  IF .NOT. EOF()
                     STORE TOT_PURCH + BILL_ADJ + SUP_PALL TO MPURCH
                     IF MDUE(I) > MPURCH
                        @ 24,0 CLEAR
                        STORE ' ' TO MWAIT
                        @ 24,0 SAY 'PAY AMT ON INV # ' + MSUP_INV + ' MORE THAN PO AMT - ' + TRANSFORM(MPURCH, '999,999.99') + ' - PRESS RETURN ' GET MWAIT
                        READ
                        @ 24,0 CLEAR
                        @ 24,01 SAY 'Action: ' + STR(MACTION,1)
                        IF MBLURP
                           @ 24,13 SAY '1. Save & Return    2. Edit    3. Next Page    4. Cancel'    
                        ELSE
                           @ 24,13 SAY '1. Save & Return    2. Edit    3. Cancel'    
                        ENDIF
                        *                       I = 99
                        *                       SELECT C
                        *                       LOOP
                     ENDIF
                     IF SHORT_FLG = ' ' 
                        @ 24,0 CLEAR
                        STORE ' ' TO MWAIT
                        @ 24,0 SAY 'CANNOT PAY INV # ' + MSUP_INV + " - S/W'S NOT ENTERED ON PO- PRESS RETURN " GET MWAIT
                        READ
                        @ 24,0 CLEAR
                        @ 24,01 SAY 'Action: ' + STR(MACTION,1)
                        IF MBLURP
                           @ 24,13 SAY '1. Save & Return    2. Edit    3. Next Page    4. Cancel'    
                        ELSE
                           @ 24,13 SAY '1. Save & Return    2. Edit    3. Cancel'    
                        ENDIF
                        I = 99
                        SELECT C
                        LOOP
                     ENDIF
                  ENDIF
                  SELECT C
                  IF DATE() < DUE_DATE
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'WARNING: PAYING INV # ' + SUP_INV + ' BEFORE DUE DATE - PRESS RETURN TO CONTINUE ' GET MWAIT
                     READ
                     @ 24,0 CLEAR
                     @ 24,01 SAY 'Action: ' + STR(MACTION,1)
                     IF MBLURP
                        @ 24,13 SAY '1. Save & Return    2. Edit    3. Next Page    4. Cancel'    
                     ELSE
                        @ 24,13 SAY '1. Save & Return    2. Edit    3. Cancel'    
                     ENDIF
                  ENDIF
               ENDIF
               I = I + 1
            ENDDO
            IF I = 99
               MACTION = 2
               LOOP
            ENDIF
            I = 1 
            DO WHILE I <= 15
               IF MUPDRCD(I) = 0 .OR. MSELECT(I) = 'H' .OR. MSELECT(I) = 'U' .OR. MSELECT(I) = 'S'
                  I = I + 1
                  LOOP
               ENDIF
               GOTO MUPDRCD(I)
               IF MSELECT(I) <> 'X'
                  IF APRVDFLG <> ' '
                     MPAGE_TOT = MPAGE_TOT - MDUE(I)
                  ENDIF
               ELSE
                  IF APRVDFLG = ' '
                     MPAGE_TOT = MPAGE_TOT + MDUE(I)
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
            @ 04,1 CLEAR TO 22,78
            @ 24,0 CLEAR
            STORE ' ' TO MYES_NO
            @ 10,5 SAY 'DO YOU WANT TO APPROVE FOR ANOTHER SUPPLIER (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'Y'
               MNEXT_CUST = .F.
            ELSE
               MPAGE_TOT = 0
            ENDIF
            LOOP
         ENDIF
         
         I = 1 
         DO WHILE I <= 15
            IF MUPDRCD(I) = 0 .OR. MSELECT(I) = 'H' .OR. MSELECT(I) = 'U' .OR. MSELECT(I) = 'S'
               I = I + 1
               LOOP
            ENDIF
            GOTO MUPDRCD(I)
            DO RECLOCK
            IF MSELECT(I) <> 'X'
               IF APRVDFLG <> ' '
                  MTOTAL = MTOTAL - MDUE(I) 
                  REPLACE APRVDFLG WITH ' '
               ENDIF
            ELSE
               IF APRVDFLG = ' '
                  MTOTAL = MTOTAL + MDUE(I)
                  REPLACE APRVDFLG WITH 'Y'       
               ENDIF
            ENDIF
            UNLOCK 
            I = I + 1
         ENDDO
         @ 5,57 SAY MTOTAL PICTURE '999,999.99'
         
         IF MACTION <> 3
            MMORE = .F.
            @ 04,1 CLEAR TO 22,78
            @ 24,0 CLEAR
            STORE ' ' TO MYES_NO
            @ 10,5 SAY 'DO YOU WANT TO APPROVE FOR ANOTHER SUPPLIER (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'Y'
               MNEXT_CUST = .F.
            ENDIF
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
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
   SELECT C
   DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
   IF EOF()
      @ 10,5 SAY 'THERE ARE NO MATCHED INVOICES ON FILE FOR SUPPLIERS.'
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
      DO APRV_SF1
      MLINE = 06
      @ 06,1 CLEAR TO 22,78
      @ 24,0 CLEAR
      DO WHILE .NOT. EOF() .AND. MLINE < 23 
         I = MLINE - 5 
         STORE RSUPCODE TO MRSUPCODE
         SELECT A
         SEEK MRSUPCODE
         IF .NOT. EOF()
            STORE NAME TO MNAME
         ELSE
            STORE 'SUPPLIER NOT ON FILE' TO MNAME
         ENDIF
         SELECT C
         IF SUP_INV = SPACE(12)
            STORE SUBSTR(REASON,1,12) TO MINV_NBR
         ELSE
            STORE SUP_INV TO MINV_NBR
         ENDIF
         IF DEB_CRD = ' '
            SELECT B
            SEEK C->SALESMAN + C->PO_NBR + C->PO_SUFFIX
            IF .NOT. EOF()
               IF SUP_PALL < 0
                  STORE (-1 * SW_PURCH) + SUP_AMT1 + SUP_AMT2  + SUP_PALL TO MADJ 
               ELSE
                  STORE (-1 * SW_PURCH) + SUP_AMT1 + SUP_AMT2 TO MADJ 
               ENDIF
               DO TOTDIFF 
               MADJ = MADJ - MSW_DIFF
            ELSE      
               STORE 0 TO MADJ
            ENDIF
         ELSE
            STORE 0 TO MADJ
         ENDIF
         SELECT C
         MDUE(I) = AMT_DUE + MADJ
         
         STORE RECNO() TO MUPDRCD(I)
         IF APRVDFLG <> ' '
            STORE 'X' TO MSELECT(I)
            MTOTAL = MTOTAL + MDUE(I)
         ENDIF
         IF HOLD_FLG <> ' '
            IF HOLD_FLG = 'S'
               STORE 'S' TO MSELECT(I)
            ELSE
               STORE 'H' TO MSELECT(I)
            ENDIF
         ENDIF
         IF ADDL_DUE <> ' '
            STORE 'U' TO MSELECT(I)
         ENDIF
         STORE DUE_DATE TO MDUE_DATE    
         DO APRV_SR1
         SKIP
         MLINE = MLINE + 1
      ENDDO
      MMAX_LINE = MLINE - 1
      STORE RECNO() TO MRECNO
      IF .NOT. EOF()
         @ 23,70 SAY "More PO's"
         MBLURP = .T.
      ELSE
         @ 23,70 to 23,78
         MBLURP = .F.
      ENDIF
      @ 2,69 SAY MTOTAL PICTURE '999,999.99'
      STORE MTOTAL TO MPAGE_TOT
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         MLINE = 6
         I = 1
         DO WHILE MLINE <= MMAX_LINE
            IF MSELECT(I) = 'H' .OR. MSELECT(I) = 'U' .OR. MSELECT(I) = 'S'
               @ MLINE,5 SAY MSELECT(I)
            ELSE
               @ MLINE,5 GET MSELECT(I)
            ENDIF
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
            IF MUPDRCD(I) = 0 .OR. MSELECT(I) = 'H' .OR. MSELECT(I) = 'U'
               I = I + 1
               LOOP
            ENDIF
            GOTO MUPDRCD(I)
            STORE SUP_INV TO MSUP_INV
            IF MSELECT(I) = 'O'
               **** THIS MEANS I HAVE TO OVERRIDE THE SUPPLIER INVOICE NUMBER
               MLINE = I + 5
               @ MLINE,45 GET MSUP_INV 
               READ
               DO RECLOCK
               REPLACE SUP_INV WITH MSUP_INV
               UNLOCK
               STORE ' ' TO MSELECT(I)
               @ MLINE,5 GET MSELECT(I)
               @ MLINE,45 SAY MSUP_INV
               CLEAR GETS
            ENDIF
            IF MSELECT(I) = 'S'
               **** THIS MEANS I HAVE TO OVERRIDE THE SUPPLIER INVOICE NUMBER
               MLINE = I + 5
               DO RECLOCK
               REPLACE HOLD_FLG WITH 'S'     
               UNLOCK
               @ MLINE,5 SAY MSELECT(I)
            ENDIF
            IF MSELECT(I) = 'X'
               SELECT B
               SEEK C->SALESMAN + C->PO_NBR + C->PO_SUFFIX
               IF MDUE(I) > TOT_PURCH + BILL_ADJ + SUP_PALL
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  @ 24,0 SAY 'AMT TO PAY INV # ' + MSUP_INV + ' IS MORE THAN PO - PRESS RETURN TO CONTINUE' GET MWAIT
                  READ
                  @ 24,0 CLEAR
                  @ 24,01 SAY 'Action: ' + STR(MACTION,1)
                  IF MBLURP
                     @ 24,13 SAY '1. Save & Return    2. Edit    3. Next Page    4. Cancel'    
                  ELSE
                     @ 24,13 SAY '1. Save & Return    2. Edit    3. Cancel'    
                  ENDIF
                  I = 99
                  LOOP
               ENDIF
               SELECT C
               GOTO MUPDRCD(I)
               IF DATE() < DUE_DATE
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  @ 24,0 SAY 'WARNING: PAYING INV # ' + SUP_INV + ' BEFORE DUE DATE - PRESS RETURN TO CONTINUE ' GET MWAIT
                  READ
                  @ 24,0 CLEAR
                  @ 24,01 SAY 'Action: ' + STR(MACTION,1)
                  IF MBLURP
                     @ 24,13 SAY '1. Save & Return    2. Edit    3. Next Page    4. Cancel'    
                  ELSE
                     @ 24,13 SAY '1. Save & Return    2. Edit    3. Cancel'    
                  ENDIF
               ENDIF
            ENDIF
            I = I + 1
         ENDDO
         IF I = 99
            MACTION = 2
            LOOP
         ENDIF
         I = 1 
         DO WHILE I <= 17
            IF MUPDRCD(I) = 0 .OR. MSELECT(I) = 'H' .OR. MSELECT(I) = 'U' .OR. MSELECT(I) = 'S'
               I = I + 1
               LOOP
            ENDIF
            GOTO MUPDRCD(I)
            IF MSELECT(I) <> 'X'
               IF APRVDFLG <> ' '
                  MPAGE_TOT = MPAGE_TOT - MDUE(I)
               ENDIF
            ELSE
               IF APRVDFLG = ' '
                  MPAGE_TOT = MPAGE_TOT + MDUE(I)
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
         IF MUPDRCD(I) = 0 .OR. MSELECT(I) = 'H' .OR. MSELECT(I) = 'U' .OR. MSELECT(I) = 'S'
            I = I + 1
            LOOP
         ENDIF
         GOTO MUPDRCD(I)
         DO RECLOCK
         IF MSELECT(I) <> 'X'
            IF APRVDFLG <> ' '
               MTOTAL = MTOTAL - MDUE(I)
               REPLACE APRVDFLG WITH ' '
            ENDIF
         ELSE
            IF APRVDFLG = ' '
               MTOTAL = MTOTAL + MDUE(I)
               REPLACE APRVDFLG WITH 'Y'       
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
SELECT C
UNLOCK
CLOSE DATA

RETURN
* EOF: APRV_SUP.PRG


*Formatted by: dANALYST Ver. 7.3a on October 24, 1988 at 1:06 PM.
