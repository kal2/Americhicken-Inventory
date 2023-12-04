***************
* Program.: MAINT3.PRG
* Author..: GRACE KELLER
* Date....: 06/07/88
* Notice..: Copyright (C) 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: File Maintenance Program MENU III
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

STORE ' ' TO MSELECT3
STORE ' ' TO MACTION

DO WHILE MSELECT3 <> '9'
   CLOSE DATA
   CLEAR
   @ 01,00 SAY MCOMPANY
   @ 02,00 SAY MPROGRAM + ' - FILE MAINTENANCE MENU III'
   @ 02,70 SAY DATE()
   @ 3,0 to 25,79
   
   @ 04,10 SAY "1 - DELETE ENTRIES ON SUPPLIER/FREIGHT APPROVAL SCREEN"
   @ 06,10 SAY '2 - ADD ENTRIES ON SUPPLIER/FREIGHT APPROVAL SCREEN'  
   @ 08,10 SAY '3 - MARK PAID OR DELETE ENTRIES ON CUSTOMER RECEIPT SCREEN'
   @ 10,10 SAY '4 - ADD ENTRIES ON CUSTOMER RECEIPT SCREEN'
   @ 12,10 say '5 - UPDATE COMMISSION PAID ENTRIES TO BE UNPAID ENTRIES'
   @ 13,10 SAY '    (Note: Above used when com. check written, then voided)'
   @ 15,10 SAY '6 - DISPLAY STATUS OF LEDGER CLOSINGS'
   @ 17,10 say '7 - MANUALLY ADD FRT/SALES/PURCHASE/COMMISSION LEDGER ENTRIES'
   @ 19,10 SAY '8 - CHANGE CHECK NBR/DATE/ACCT CODES/AMOUNTS ON ISSUED CHECKS'
   @ 21,10 SAY '9 - RETURN TO MAIN MENU'
   
   STORE '1' TO MSELECT3
   @ 23,02 SAY 'CHOICE: '
   @ 23,10 GET MSELECT3 PICTURE '@!'
   READ
   
   DO CASE
   CASE MSELECT3 = '1'   
      @ 4,1 CLEAR TO 23,78
      STORE ' ' TO MPICK
      @ 10,10 SAY 'DO YOU WANT TO SELECT SUPPLIERS OR FREIGHT (S/F)? ' GET MPICK PICTURE '@!'
      READ
      DO CASE
      CASE MPICK = 'S'
         STORE 0 TO MSW_DIFF
         MNEXT_CUST = .T.
         
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
            MTITLE = ' - DELETE ENTRIES ON THE SUPPLIER APPROVAL SCREEN'
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 to 25,79
            DO APRV_SF
            @ 5,40 SAY SPACE(20)
            SELECT D
            DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
            SELECT B
            DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
            
            SELECT C
            DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
            SEEK MRSUPCODE
            IF EOF()
               @ 10,5 SAY 'THERE ARE NO APPROVAL ENTRIES ON FILE FOR THIS SUPPLIER.'
               STORE ' ' TO MWAIT
               @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
               READ
               CLOSE DATA
               LOOP  
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
               @ 08,1 CLEAR TO 23,78
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
                  DO APRV_SR
                  SKIP
                  MLINE = MLINE + 1
               ENDDO
               MMAX_LINE = MLINE - 1
               STORE RECNO() TO MRECNO
               IF .NOT. EOF() .AND. RSUPCODE = MRSUPCODE 
                  @ 24,69 SAY "More PO's"
                  MBLURP = .T.
               ELSE
                  @ 24,69 SAY SPACE(9)
                  MBLURP = .F.
               ENDIF
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
                  IF MBLURP
                     @24,09 GET MACTION PICTURE '9' RANGE 1,4
                  ELSE
                     @24,09 GET MACTION PICTURE '9' RANGE 1,3
                  ENDIF
                  READ               
               ENDDO          
               IF .NOT. MBLURP  .AND. MACTION = 3
                  MACTION = 4
               ENDIF
               IF MACTION = 4
                  MMORE = .F.
                  @ 04,1 CLEAR TO 23,78
                  @ 24,0 CLEAR
                  STORE ' ' TO MYES_NO
                  @ 10,5 SAY 'DO YOU WANT TO DELETE ENTRIES FOR ANOTHER SUPPLIER (Y/N)? ' GET MYES_NO PICTURE '@!'
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
                  IF MUPDRCD(I) = 0 .OR. (MSELECT(I) <> 'X' .AND. MSELECT(I) <> 'D')
                     I = I + 1
                     LOOP
                  ENDIF
                  SELECT C
                  GOTO MUPDRCD(I)
                  DO RECLOCK
                  DELETE   
                  UNLOCK
                  I = I + 1
               ENDDO
               
               IF MACTION <> 3
                  MMORE = .F.
                  @ 04,1 CLEAR TO 23,78
                  @ 24,0 CLEAR
                  STORE ' ' TO MYES_NO
                  @ 10,5 SAY 'DO YOU WANT TO UPDATE FOR ANOTHER SUPPLIER (Y/N)? ' GET MYES_NO PICTURE '@!'
                  READ
                  IF MYES_NO <> 'Y'
                     MNEXT_CUST = .F.
                  ENDIF
               ENDIF
            ENDDO
         ENDDO
         
         SELECT C
         UNLOCK
         CLOSE DATA
      CASE MPICK = 'F'
         STORE 0 TO MSW_DIFF
         MNEXT_FRT = .T.
         
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
            MTITLE = ' - DELETE ENTRIES ON THE FREIGHT APPROVAL SCREEN'
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 to 25,79
            DO APRVFSF
            @ 5,40 SAY SPACE(20)
            SELECT D
            DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
            SELECT B
            DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
            
            SELECT C
            DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
            SEEK MFRT_CODE
            IF EOF()
               @ 10,5 SAY 'THERE ARE NO ENTRIES ON THE APPROVAL SCREEN FOR THIS FREIGHT CARRIER.'
               STORE ' ' TO MWAIT
               @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
               READ
               LOOP  
            ENDIF
            
            STORE RECNO() TO MRECNO, MFST_REC
            MPAGE_TOT = 0   
            MMORE = .T.
            DO WHILE MMORE
               STORE ' ' TO MSELECT
               STORE 0 TO MUPDRCD, MADJUST
               GOTO MRECNO
               MLINE = 08
               @ 08,1 CLEAR TO 23,78
               @ 24,0 CLEAR
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
                  DO APRVFSR
                  SKIP
                  MLINE = MLINE + 1
               ENDDO
               MMAX_LINE = MLINE - 1
               STORE RECNO() TO MRECNO
               IF .NOT. EOF() .AND. FRT_CODE = MFRT_CODE 
                  @ 24,69 SAY "More PO's"
                  MBLURP = .T.
               ELSE
                  @ 24,69 SAY SPACE(9)
                  MBLURP = .F.
               ENDIF
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
                  IF MBLURP
                     @24,09 GET MACTION PICTURE '9' RANGE 1,4
                  ELSE
                     @24,09 GET MACTION PICTURE '9' RANGE 1,3
                  ENDIF
                  READ               
               ENDDO          
               
               IF .NOT. MBLURP
                  IF MACTION = 3
                     MACTION = 4
                  ENDIF
               ENDIF
               IF MACTION = 4
                  MMORE = .F.
                  @ 04,1 CLEAR TO 23,78
                  @ 24,0 CLEAR
                  STORE ' ' TO MYES_NO
                  @ 10,5 SAY 'DO YOU WANT TO DELETE FOR ANOTHER FREIGHT CARRIER (Y/N)? ' GET MYES_NO PICTURE '@!'
                  READ
                  IF MYES_NO <> 'Y'
                     MNEXT_FRT = .F.
                  ENDIF
                  LOOP
               ENDIF
               
               I = 1 
               DO WHILE I <= 15
                  IF (MUPDRCD(I) = 0) .OR. (MSELECT(I) <> 'X' .AND. MSELECT(I) <> 'D')
                     I = I + 1
                     LOOP
                  ENDIF
                  GOTO MUPDRCD(I)
                  DO RECLOCK
                  DELETE
                  UNLOCK
                  I = I + 1
               ENDDO
               IF MACTION <> 3
                  MMORE = .F.
                  @ 04,1 CLEAR TO 23,78
                  @ 24,0 CLEAR
                  STORE ' ' TO MYES_NO
                  @ 10,5 SAY 'DO YOU WANT TO UPDATE FOR ANOTHER FREIGHT (Y/N)? ' GET MYES_NO PICTURE '@!'
                  READ
                  IF MYES_NO <> 'Y'
                     MNEXT_FRT  = .F.
                  ENDIF
               ENDIF
            ENDDO
         ENDDO
      ENDCASE
   CASE MSELECT3 = '2'   
      @ 4,1 CLEAR TO 23,78
      STORE ' ' TO MPICK
      @ 10,10 SAY 'DO YOU WANT TO SELECT SUPPLIERS OR FREIGHT (S/F)? ' GET MPICK PICTURE '@!'
      READ
      DO CASE
      CASE MPICK = 'S'
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
         SELECT A
         DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
         MTITLE = ' - ADD ENTRIES ON THE SUPPLIER APPROVAL SCREEN'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 25,79
         STORE SPACE(2) TO MSALESMAN
         STORE SPACE(4) TO MPO_NBR
         STORE ' ' TO MPO_SUFFIX
         STORE 0 TO MINV_NBR, MAMT_DUE
         STORE SPACE(12) TO MSUP_INV
         STORE CTOD(' ') TO MDUE_DATE
         @ 4,5 SAY MNAME
         @ 5,5 SAY TRIM(MCITY) + ', ' + MSTATE           
         
         @ 7,1 SAY '         PO NUMBER: '
         @ 7,23 SAY '-    -'
         @ 9,1 SAY '         INVOICE #:'
         @ 11,1 SAY 'SUPPLIER INVOICE #:'
         @ 13,1 SAY '          DATE DUE:'
         @ 15,1 SAY '        AMOUNT DUE: '
         @ 24,1 SAY 'Action:      1. Continue       2. Edit      3. Cancel'
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 7,21 GET MSALESMAN PICTURE '##'
            @ 7,24 GET MPO_NBR PICTURE '####'
            @ 7,29 GET MPO_SUFFIX PICTURE '@!'
            @ 9,21 GET MINV_NBR PICTURE '#####'
            @ 11,21 GET MSUP_INV PICTURE '@!'
            @ 13,21 GET MDUE_DATE
            @ 15,21 GET MAMT_DUE PICTURE '######.##'
            READ
            STORE 1 TO MACTION
            @ 24,9 GET MACTION PICTURE '#' RANGE 1,3 
            READ
         ENDDO
         IF MACTION = 1 .AND. MPO_NBR <> SPACE(4) 
            DO FILELOCK
            APPEND BLANK
            REPLACE salesman   WITH Msalesman  
            REPLACE po_nbr     WITH Mpo_nbr    
            REPLACE po_suffix  WITH Mpo_suffix 
            REPLACE RSUPCODE   WITH MRSUPCODE    
            REPLACE AMT_DUE   WITH MAMT_DUE               
            REPLACE INV_nbr    WITH STR(MINV_NBR,5) 
            REPLACE DUE_DATE WITH MDUE_DATE
            REPLACE SUP_INV WITH MSUP_INV
            REPLACE DEB_CRD WITH 'Y'
            REPLACE SEQ WITH '1'
            UNLOCK
         ENDIF
         
      CASE MPICK = 'F'
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
         SELECT A
         DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
         MTITLE = ' - ADD ENTRIES ON THE FREIGHT APPROVAL SCREEN'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 25,79
         
         STORE SPACE(2) TO MSALESMAN
         STORE SPACE(4) TO MPO_NBR
         STORE ' ' TO MPO_SUFFIX
         STORE 0 TO MINV_NBR, MAMT_DUE
         STORE SPACE(12) TO MFRT_INV
         STORE CTOD(' ') TO MDUE_DATE
         @ 4,5 SAY MNAME
         @ 5,5 SAY TRIM(MCITY) + ', ' + MSTATE           
         
         @ 7,1 SAY '         PO NUMBER: '
         @ 7,23 SAY '-    -'
         @ 9,1 SAY '         INVOICE #:'
         @ 11,1 SAY ' FREIGHT INVOICE #:'
         @ 13,1 SAY '          DATE DUE:'
         @ 15,1 SAY '        AMOUNT DUE: '
         @ 24,1 SAY 'Action:      1. Continue       2. Edit      3. Cancel'
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 7,21 GET MSALESMAN PICTURE '##'
            @ 7,24 GET MPO_NBR PICTURE '####'
            @ 7,29 GET MPO_SUFFIX PICTURE '@!'
            @ 9,21 GET MINV_NBR PICTURE '#####'
            @ 11,21 GET MFRT_INV PICTURE '@!'
            @ 13,21 GET MDUE_DATE
            @ 15,21 GET MAMT_DUE PICTURE '######.##'
            READ
            STORE 1 TO MACTION
            @ 24,9 GET MACTION PICTURE '#' RANGE 1,3
            READ
         ENDDO
         IF MACTION = 1 .AND. MPO_NBR <> SPACE(4) 
            DO FILELOCK
            APPEND BLANK
            REPLACE salesman   WITH Msalesman  
            REPLACE po_nbr     WITH Mpo_nbr    
            REPLACE po_suffix  WITH Mpo_suffix 
            REPLACE FRT_CODE   WITH MFRT_CODE    
            REPLACE AMT_DUE   WITH MAMT_DUE               
            REPLACE INV_NBR    WITH STR(MINV_NBR,5) 
            REPLACE DUE_DATE WITH MDUE_DATE
            REPLACE FRT_INV WITH MFRT_INV
            REPLACE DEB_CRD WITH 'Y'
            UNLOCK
         ENDIF
         
      ENDCASE
   CASE MSELECT3 = '3'   
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
            RELEASE MCK, MREC, MAMT
            LOOP
         ENDIF
         STORE NAME TO MNAME
         STORE BBUYCODE TO MBBUYCODE
         STORE STREET TO MSTREET
         STORE CITY TO MCITY
         STORE STATE TO MSTATE
         STORE ZIP TO MZIP
         SET PROC TO PAY_PROC
         MTITLE = ' - MARK PAID OR DELETE ENTRIES ON THE CUSTOMER RECEIPT SCREEN'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 25,79
         DO PAYCRDSF
         @ 4,52 SAY "('P' to Mark Entries Paid)"
         @ 5,52 say "('D' to Delete Entries)"
         SELECT E 
         DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PRINT, PO_SUP, PO_SHIP, PO_FRT", .F.
         SELECT D
         DO FOX_USE WITH "INV_ADJ INDEX INV_ADJ", .F.
         SELECT B
         DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
         SEEK MBBUYCODE + ' '
         IF EOF()
            @ 14,1 SAY 'THERE ARE NO OUTSTANDING INVOICES FOR THIS CUSTOMER '
            @ 16,1 SAY 'PLEASE REENTER THE CUSTOMER SELECTED'
            @ 17,1 SAY ' '
            WAIT 'PRESS RETURN TO CONTINUE'
            RELEASE MCK, MREC, MAMT
            LOOP
         ENDIF
         STORE RECNO() TO MRECNO, MFST_REC
         MNOT_DONE = .T.
         DO WHILE MNOT_DONE
            STORE SPACE(1) TO MCK
            STORE 0 TO MCK_AMT, MTOT_PAID
            GOTO MRECNO
            MLINE = 09
            @ 09,1 CLEAR TO 22,78
            @ 24,0 CLEAR
            DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. MBBUYCODE = BBUYCODE .AND. PAID_FLG = ' '
               MI = MLINE - 8    
               STORE INV_NBR TO MINV_NBR
               STORE DEB_CRD TO MDEB_CRD
               STORE SALESMAN TO MSALESMAN
               STORE PO_NBR TO MPO_NBR
               STORE PO_SUFFIX TO MPO_SUFFIX
               IF DTOC(SHIP_DATE) <> '  /  /  '
                  STORE SHIP_DATE TO MINV_DATE
               ELSE
                  STORE INV_DATE TO MINV_DATE
               ENDIF
               MAMT(MI) = TOT_SELL + CUS_PALL
               IF SUBSTR(MINV_NBR,1,1) <> 'A' .AND. MDEB_CRD = ' '
                  SELECT D
                  SEEK MINV_NBR
                  DO WHILE .NOT. EOF() .AND. INV_NBR = MINV_NBR
                     MAMT(MI) = MAMT(MI) + ADJ_AMT
                     SKIP
                  ENDDO
                  SELECT B
               ENDIF
               MAMT(MI) = MAMT(MI) - AMT_PAID
               STORE RECNO() TO MREC(MI)
               DO PAYCRDSR
               SKIP
               MLINE = MLINE + 1
            ENDDO
            MMAX_LINE = MLINE - 1
            IF .NOT. EOF() .AND. BBUYCODE = MBBUYCODE .AND. PAID_FLG = ' '
               @ 24,70 SAY 'More ....'
               MBLURP = .T.
               STORE MRECNO TO MFST_REC
               STORE RECNO() TO MRECNO     
            ELSE
               @ 24,70 say space(9)   
               MBLURP = .F.
               STORE MRECNO TO MFST_REC
               STORE 0 TO MRECNO
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
                  IF MCK(MI) <> ' ' .AND. MCK(MI) <> 'P' .AND. MCK(MI) <> 'D'
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
            IF .NOT. MBLURP .AND. MACTION = 3
               MACTION = 4   
            ENDIF     
            IF MACTION = 4
               MNOT_DONE = .F.
               MEDIT = .F.
               RELEASE MCK, MREC, MAMT
               LOOP
            ENDIF
            
            I = 1 
            DO WHILE I <= 14
               IF MCK(I) = ' '
                  I = I + 1
                  LOOP
               ENDIF
               SELECT B
               GOTO MREC(I)
               DO FILELOCK
               IF MCK(I) = 'P'
                  REPLACE PAID_FLG WITH 'Y'
               ENDIF
               IF MCK(I) = 'D'
                  DELETE
               ENDIF
               UNLOCK
               *** ALSO MARK PO PAID IN FULL
               IF MCK(I) = 'P'
                  SELECT E
                  SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
                  IF .NOT. EOF()
                     DO FILELOCK
                     REPLACE PAID_FLG WITH 'Y'
                     UNLOCK
                  ENDIF
                  SELECT B
               ENDIF
               I = I + 1
            ENDDO
            MEDIT = .F.
            IF MACTION <> 3
               MNOT_DONE = .F.
            ENDIF
         ENDDO
      ENDDO
      RELEASE MCK, MREC, MAMT
      CLOSE DATA
      
      
   CASE MSELECT3 = '4'
      STORE DATE() TO MDATE     
      SELECT B
      DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
      MMORE = .T.
      DO WHILE  MMORE
         MNAME_FD = .F.
         DO BBUYSEL3
         IF .NOT. MNAME_FD
            MMORE = .F.
            LOOP
         ENDIF
         STORE NAME TO MNAME
         STORE BBUYCODE TO MBBUYCODE
         STORE STREET TO MSTREET
         STORE CITY TO MCITY
         STORE STATE TO MSTATE
         STORE ZIP TO MZIP
         
         STORE 2 TO MACTION
         STORE SPACE(2) TO MSALESMAN
         STORE SPACE(4) TO MPO_NBR
         STORE SPACE(1) TO MPO_SUFFIX
         STORE 0 TO MINV_NBR, MAMOUNT  
         MTITLE = ' - ADD ENTRIES ON THE CUSTOMER RECEIPTS SCREEN'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 25,79
         DO WHILE MACTION = 2
            @ 4,5 SAY MNAME
            @ 5,5 SAY MSTREET
            @ 6,5 SAY TRIM(MCITY) + ', ' + MSTATE
            
            @ 09,5 SAY '      AMOUNT: '
            @ 10,5 SAY '(Note: Above amount can be negative!)'
            @ 12,5 SAY 'MIDWEST PO #: '
            @ 12,21 SAY '-'
            @ 12,26 SAY '-'
            @ 14,4 SAY 'MIDWEST INV #:'
            
            @ 09,19 GET MAMOUNT PICTURE '99999.99'
            @ 12,19 get MSALESMAN PICTURE '##'
            @ 12,22 GET MPO_NBR PICTURE '####'
            @ 12,27 GET MPO_SUFFIX PICTURE '@!'
            @ 14,19 GET MINV_NBR PICTURE '#####'
            STORE 1 TO MACTION
            @ 24,0 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,12 SAY '1.Save/Return    2. Edit   3. Save/Add Another    4. Cancel'
            READ
            @24,09 GET MACTION PICTURE '9' RANGE 1,4
            READ
         ENDDO
         
         IF MACTION = 4
            MMORE = .F.
            LOOP
         ENDIF
         IF MACTION = 1 .OR. MACTION = 3
            STORE STR(MINV_NBR,5) TO MINV_NBR
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE salesman   WITH Msalesman  
            REPLACE po_nbr     WITH Mpo_nbr    
            REPLACE po_suffix  WITH Mpo_suffix 
            REPLACE bbuycode   WITH Mbbuycode  
            REPLACE ship_date  WITH MDATE   
            REPLACE tot_sell   WITH MAMOUNT
            IF VAL(MINV_NBR) < 10000
               REPLACE INV_NBR WITH 'A' + SUBSTR(MINV_NBR,2)           
            ELSE
               REPLACE INV_NBR WITH MINV_NBR
            ENDIF
            REPLACE DEB_CRD WITH 'Y'
            REPLACE INV_DATE   WITH MDATE
            UNLOCK
            
         ELSE
            MMORE = .F.
            LOOP
         ENDIF
         IF MACTION = 1
            MMORE = .F.
         ENDIF
      ENDDO
      CLOSE DATA
      
   CASE MSELECT3 = '5'   
      STORE ' ' TO MSEL_TYPE
      STORE SPACE(2) TO MSEL_CODE
      @ 4,1 CLEAR TO 22,78
      STORE SPACE(32) TO MNAME
      STORE SPACE(1) TO MSALE_SEL, MTHIRD_SEL, MSEL_TYPE
      STORE CTOD(' ') TO MPAID_DATE
      STORE 2 TO MACTION      
      DO WHILE MACTION = 2      
         @ 8,2 SAY  'DATE OF COMMISSION CHECK:'
         @ 8,29 GET MPAID_DATE
         @ 10,5 SAY 'COMMISSIONS PAYEE NAME: '
         @ 10,29 GET MNAME PICTURE '@!'
         @ 13,5 SAY "'X' THE APPROPRIATE COMMISSIONS CATEGORY"
         @ 14,5 SAY 'MIDWEST SALESPERSON:             THIRD PARTY COMMISSION:'
         @ 14,26 GET MSALE_SEL PICTURE '@!'
         @ 14,62 GET MTHIRD_SEL PICTURE '@!'
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue      2.  Edit      3. Cancel Report'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         
         IF MACTION = 1
            IF MSALE_SEL = 'X'
               STORE 'S' TO MCOM_TYPE
            ELSE
               IF MTHIRD_SEL = 'X'
                  STORE 'T' TO MCOM_TYPE
               ELSE
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  @ 24,0 SAY 'NO COMMISSIONS CATEGORY IS SELECTED - PRESS RETURN TO REENTER ' GET MWAIT
                  READ
                  MACTION = '2'
                  @ 24,0 CLEAR
                  LOOP
               ENDIF
            ENDIF
            IF DTOC(MPAID_DATE) = '  /  /  '  
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT
               @ 24,0 SAY 'NO DATE IS ENTERED - PRESS RETURN TO REENTER ' GET MWAIT
               READ
               MACTION = '2'
               @ 24,0 CLEAR
               LOOP
            ENDIF
            IF MNAME =  SPACE(32)
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT
               @ 24,0 SAY 'NO NAME IS ENTERED - PRESS RETURN TO REENTER ' GET MWAIT
               READ
               MACTION = '2'
               @ 24,0 CLEAR
               LOOP
            ELSE
               IF MSALE_SEL = 'X'
                  SELECT A
                  DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
                  SEEK TRIM(MNAME)
                  IF .NOT. EOF()
                     STORE SALE_CODE TO MCOM_CODE
                     STORE 'S' TO MCOM_TYPE
                  ELSE
                     @ 24,0 CLEAR
                     mwait = ' '
                     @ 24,1 SAY 'SALESPERSON NAME NOT ON FILE - PRESS ANY KEY TO REENTER' GET MWAIT
                     READ
                     MACTION = 2
                     @ 24,0 CLEAR
                     LOOP 
                  ENDIF
               ELSE
                  SELECT A
                  DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
                  SEEK TRIM(MNAME)
                  IF .NOT. EOF()
                     STORE COM_CODE TO MCOM_CODE
                     STORE 'T' TO MCOM_TYPE
                  ELSE
                     @ 24,0 CLEAR
                     mwait = ' '
                     @ 24,1 SAY 'THIRD PARTY NAME NOT ON FILE - PRESS ANY KEY TO REENTER' GET MWAIT
                     READ
                     MACTION = 2
                     @ 24,0 CLEAR
                     LOOP 
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
      ENDDO
      IF MACTION = 3
         CLOSE DATA
         LOOP   
      ENDIF  
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
      DO FILELOCK
      DO WHILE .NOT. EOF()
         IF PAID_DATE <> MPAID_DATE
            SKIP
            LOOP
         ENDIF
         IF COM_TYPE = MCOM_TYPE .AND. COM_CODE = MCOM_CODE
            REPLACE COM_PD WITH ' '
            REPLACE PAID_DATE WITH CTOD(' ')
         ENDIF
         SKIP
      ENDDO
      CLOSE DATA
   CASE MSELECT3 = '6'   
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 02,00 SAY MPROGRAM + ' - DISPLAY LEDGER CLOSING STATUS'
      @ 02,70 SAY DATE()
      @ 3,0 to 25,79
      STORE 0 TO MTRAN_MO, MTRAN_YR
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 06,5 SAY 'CLOSING MONTH: ' GET MTRAN_MO PICTURE '##' RANGE 1,12
         @ 08,5 SAY ' CLOSING YEAR: ' GET MTRAN_YR PICTURE '####' RANGE 1988,2099
         STORE 1 TO MACTION
         @ 24,0 SAY 'Action: ' + STR(MACTION,1)
         @ 24,12 SAY '1. Continue      2. Edit     3. Cancel'
         READ
         @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
         READ
      ENDDO
      IF MACTION = 1
         MTRAN_MO = MTRAN_MO + 1
         IF MTRAN_MO = 13
            MTRAN_MO = 1
         ENDIF
         STORE SUBSTR(STR(MTRAN_MO + 100,3),2) TO MTRAN_MO
         STORE STR(MTRAN_YR,4) TO MTRAN_YR   
         IF MTRAN_MO = '01'
            MTRAN_YR = STR(VAL(MTRAN_YR) +1,4)
         ENDIF
         STORE 'N' TO MFRT_X, MSUP_X, MCUS_X, MCOM_X
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED", .F.
         SEEK MTRAN_YR + MTRAN_MO
         IF .NOT. EOF() .AND. DTOC(TRAN_DATE) = '  /  /  ' .AND. DTOC(POST_DATE) = '  /  /  '
            STORE 'Y' TO MCOM_X
         ENDIF
         DO FOX_USE WITH "SUPLED INDEX SUPLED", .F.
         SEEK MTRAN_YR + MTRAN_MO
         IF .NOT. EOF() .AND. DTOC(TRAN_DATE) = '  /  /  ' .AND. DTOC(POST_DATE) = '  /  /  '
            STORE 'Y' TO MSUP_X
         ENDIF
         DO FOX_USE WITH "CUSLED INDEX CUSLED", .F.
         SEEK MTRAN_YR + MTRAN_MO
         IF .NOT. EOF() .AND. DTOC(TRAN_DATE) = '  /  /  ' .AND. DTOC(POST_DATE) = '  /  /  '
            STORE 'Y' TO MCUS_X
         ENDIF
         DO FOX_USE WITH "FRTLED INDEX FRTLED", .F.
         SEEK MTRAN_YR + MTRAN_MO
         IF .NOT. EOF() .AND. DTOC(TRAN_DATE) = '  /  /  ' .AND. DTOC(POST_DATE) = '  /  /  '
            STORE 'Y' TO MFRT_X
         ENDIF
         
         @ 11,5 SAY '    FREIGHT LEDGER: ' + MFRT_X 
         @ 13,5 SAY '   PURCHASE LEDGER: ' + MSUP_X 
         @ 15,5 SAY '      SALES LEDGER: ' + MCUS_X 
         @ 17,5 SAY 'COMMISSIONS LEDGER: ' + MCOM_X 
         @ 24,0 CLEAR
         STORE ' ' TO MWAIT
         @ 24,1 SAY 'PRESS RETURN TO CONTINUE.... ' GET MWAIT
         READ
      ENDIF
      CLOSE DATA
   CASE MSELECT3 = '7'   
      MTITLE = ' - ADD MANUAL LEDGER ENTRIES'
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @  2,0 SAY MPROGRAM + MTITLE
      @ 3,0 to 25,79
      STORE 0 TO MTRAN_MO, MTRAN_YR
      STORE 2 TO MACTION
      STORE ' ' TO MFRT_X, MSUP_X, MCUS_X, MCOM_X
      DO WHILE MACTION = 2
         @ 05,5 SAY "SELECT WITH AN 'X' THE LEDGER TO UPDATE (ONLY SELECT ONE AT A TIME)"
         @ 08,5 SAY '    FREIGHT LEDGER: ' GET MFRT_X PICTURE '@!'
         @ 10,5 SAY '   PURCHASE LEDGER: ' GET MSUP_X PICTURE '@!'
         @ 12,5 SAY '      SALES LEDGER: ' GET MCUS_X PICTURE '@!'
         @ 14,5 SAY 'COMMISSIONS LEDGER: ' GET MCOM_X PICTURE '@!'
         @ 16,5 SAY '      POSTING MONTH: ' GET MTRAN_MO PICTURE '##' RANGE 1,12
         @ 18,5 SAY '       POSTING YEAR: ' GET MTRAN_YR PICTURE '####' RANGE 1988,2099
         @ 20,5 SAY '(Note: These entries do not show up on the spreadsheet!)'
         @ 21,5 say '(They only update the ledgers)'     
         STORE 1 TO MACTION
         @ 24,0 SAY 'Action: ' + STR(MACTION,1)
         @ 24,12 SAY '1. Continue      2. Edit     3. Cancel'
         @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
         
         READ
         DO CASE
         CASE MFRT_X <> ' ' .AND. MFRT_X <> 'X'
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY "FREIGHT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
            
         CASE MSUP_X <> ' ' .AND. MSUP_X <> 'X'
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY "PURCHASE SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
            
         CASE MCUS_X <> ' ' .AND. MCUS_X <> 'X'
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY "SALES SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
            READ
            
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
            
         CASE MCOM_X <> ' ' .AND. MCOM_X <> 'X'
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY "COMMISSION SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDCASE
      ENDDO
      IF MACTION = 3
         RETURN
      ENDIF
      
      STORE SUBSTR(STR(MTRAN_MO+100,3),2) TO MTRAN_MO
      STORE STR(MTRAN_YR,4) TO MTRAN_YR
      @ 4,1 CLEAR TO 22,78
      DO CASE
      CASE MFRT_X = 'X'
         SELECT B
         DO FOX_USE WITH "FRTLED INDEX FRTLED, FRTMATCH, FRTNOMAT", .F.
         MMORE_ENT = .T.
         DO WHILE MMORE_ENT
            STORE SPACE(4) TO MPO_NBR
            STORE SPACE(5) TO MINV_NBR
            STORE SPACE(1) TO MPO_SUFFIX
            STORE SPACE(2) TO MSALESMAN
            STORE CTOD(' ') TO MSHIP_DATE
            STORE 0 TO MAMOUNT, MINV_NBR
            MCK_NBR = 0
            MCK_DATE = CTOD(' ')
            STORE SPACE(32) TO MNAME
            STORE 2 TO MACTION   
            DO WHILE MACTION = 2
               @ 6,1  SAY '   FREIGHT NAME: '
               @ 8,1  SAY '      PO NUMBER: ' 
               @ 8,20 SAY '-'                
               @ 8,25 SAY '-'              
               @ 10,1 SAY  '   INVOICE NBR: '    
               @ 12,1 SAY '      SHIP DATE: '
               @ 14,1 SAY '  LEDGER AMOUNT: '
               @ 16,1 SAY '(Note: The above amount can be a negative number.)'
               @ 18,1 SAY '(OPT) CHECK NBR:'   
               @ 20,1 SAY '(OPT) CHECK DATE:'
               @ 6,18 GET MNAME
               @ 8,18 GET MSALESMAN        
               @ 8,21 GET MPO_NBR PICTURE '####'
               @ 8,26 GET MPO_SUFFIX PICTURE '@!'
               @ 10,18 GET MINV_NBR PICTURE '#####'
               @ 12,18 GET MSHIP_DATE
               @ 14,18 GET MAMOUNT PICTURE '#,###,###.##'
               @ 18,18 GET MCK_NBR PICTURE '######'
               @ 20,19 GET MCK_DATE
               READ
               STORE 1 TO MACTION
               @ 24,0 CLEAR
               @ 24,01 SAY 'Action: ' + STR(MACTION,1)
               @ 24,13 SAY '1. Continue     2. Edit      3. Cancel Entry'
               @ 24,9 GET MACTION PICTURE '9' range 1,3
               READ
               IF MACTION = 1
                  IF MINV_NBR = 0 .AND. MSALESMAN = SPACE(2) .AND. MPO_NBR = SPACE(4)
                     MACTION = 3
                     LOOP
                  ENDIF
                  IF MPO_NBR = SPACE(4)
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,1 SAY 'PURCHASE ORDER NUMBER MUST BE ENTERED - PRESS RETURN TO REENTER ' GET MWAIT
                     READ
                     @ 24,0 CLEAR
                     MACTION = 2
                     LOOP
                  ENDIF
                  IF MSALESMAN <> SPACE(2)
                     SELECT A
                     DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
                     SEEK MSALESMAN
                     IF  EOF()
                        @ 24,0 CLEAR
                        STORE ' ' TO MWAIT
                        @ 24,0 SAY 'INVALID SALESPERSON CODE - PRESS RETURN TO REENTER ' GET MWAIT
                        READ
                        @ 24,0 CLEAR
                        MACTION = 2
                        LOOP
                     ENDIF
                  ENDIF
                  MNAME_FD = .F.
                  SELECT A
                  DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
                  DO FRT_SEL3
                  IF .NOT. MNAME_FD .OR. MACTION = 3
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'VALID FREIGHT CARRIER MUST BE SELECTED - PRESS RETURN TO REENTER ' GET MWAIT
                     READ
                     @ 24,0 CLEAR
                     MACTION = 2
                     LOOP
                  ENDIF
                  STORE NAME TO MNAME      
                  STORE FRT_CODE TO MFRT_CODE 
               ENDIF
            ENDDO
            IF MACTION = 3
               MMORE_ENT = .F.
               LOOP
            ENDIF
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE salesman   WITH MSALESMAN  
            REPLACE po_nbr     WITH MPO_NBR    
            REPLACE po_suffix  WITH MPO_SUFFIX 
            REPLACE INV_NBR    WITH STR(MINV_NBR,5)   
            REPLACE FRT_CODE WITH MFRT_CODE
            REPLACE POST_DATE  WITH DATE()
            REPLACE TRAN_MO     WITH MTRAN_MO
            REPLACE TRAN_YR     WITH MTRAN_YR
            REPLACE AMOUNT WITH MAMOUNT
            IF MCK_NBR = 0
               REPLACE TRAN_DATE WITH MSHIP_DATE
               REPLACE COR_FLG WITH 'Y'
            ELSE
               REPLACE CK_NBR WITH STR(MCK_NBR,6)
               REPLACE TRAN_DATE WITH MCK_DATE
               REPLACE COR_FLG WITH 'D'
            ENDIF
            UNLOCK
         ENDDO
         
      CASE MSUP_X = 'X'
         SELECT B
         DO FOX_USE WITH "SUPLED INDEX SUPLED, SUPMATCH, SUPNOMAT", .F.
         MMORE_ENT = .T.
         DO WHILE MMORE_ENT
            STORE SPACE(4) TO MPO_NBR
            STORE SPACE(5) TO MINV_NBR
            STORE SPACE(1) TO MPO_SUFFIX
            STORE SPACE(2) TO MSALESMAN
            STORE CTOD(' ') TO MSHIP_DATE
            STORE 0 TO MAMOUNT, MINV_NBR
            STORE SPACE(32) TO MNAME
            MCK_NBR = 0
            MCK_DATE = CTOD(' ')
            STORE 2 TO MACTION   
            DO WHILE MACTION = 2
               @ 6,1 SAY '  SUPPLIER NAME: '
               @ 8,1 SAY '      PO NUMBER: ' 
               @ 8,20 SAY '-'                
               @ 8,25 SAY '-'              
               @ 10,1 SAY  '   INVOICE NBR: '    
               @ 12,1 SAY '     SHIP DATE: '
               @ 14,1 SAY ' LEDGER AMOUNT: '
               @ 16,1 SAY '(Note: The above amount can be a negative number.)'
               @ 18,1 SAY '(OPT) CHECK NBR:'   
               @ 20,1 SAY '(OPT) CHECK DATE:'
               @ 6,18 GET MNAME
               @ 8,18 GET MSALESMAN        
               @ 8,21 GET MPO_NBR PICTURE '####'
               @ 8,26 GET MPO_SUFFIX PICTURE '@!'
               @ 10,18 GET MINV_NBR PICTURE '#####'
               @ 12,18 GET MSHIP_DATE
               @ 14,18 GET MAMOUNT PICTURE '#,###,###.##'
               @ 18,18 GET MCK_NBR PICTURE '######'
               @ 20,19 GET MCK_DATE
               READ
               STORE 1 TO MACTION
               @ 24,0 CLEAR
               @ 24,01 SAY 'Action: ' + STR(MACTION,1)
               @ 24,13 SAY '1. Continue     2. Edit      3. Cancel Entry'
               @ 24,9 GET MACTION PICTURE '9' range 1,3
               READ
               IF MACTION = 1
                  IF MINV_NBR = 0 .AND. MSALESMAN = SPACE(2) .AND. MPO_NBR = SPACE(4)
                     MACTION = 3
                     LOOP
                  ENDIF
                  IF MPO_NBR = SPACE(4)
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,1 SAY 'PURCHASE ORDER NUMBER MUST BE ENTERED - PRESS RETURN TO REENTER ' GET MWAIT
                     READ
                     @ 24,0 CLEAR
                     MACTION = 2
                     LOOP
                  ENDIF
                  IF MSALESMAN <> SPACE(2)
                     SELECT A
                     DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
                     SEEK MSALESMAN
                     IF  EOF()
                        @ 24,0 CLEAR
                        STORE ' ' TO MWAIT
                        @ 24,0 SAY 'INVALID SALESPERSON CODE - PRESS RETURN TO REENTER ' GET MWAIT
                        READ
                        @ 24,0 CLEAR
                        MACTION = 2
                        LOOP
                     ENDIF
                  ENDIF
                  MNAME_FD = .F.
                  SELECT A
                  DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
                  DO RSUPSEL2
                  IF .NOT. MNAME_FD .OR. MACTION = 3
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'VALID SUPPLIER MUST BE SELECTED - PRESS RETURN TO REENTER ' GET MWAIT
                     READ
                     @ 24,0 CLEAR
                     MACTION = 2
                     LOOP
                  ENDIF
                  STORE NAME TO MRSUPNAME
                  STORE RSUPCODE TO MRSUPCODE
               ENDIF
            ENDDO
            IF MACTION = 3
               MMORE_ENT = .F.
               LOOP
            ENDIF
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE salesman   WITH MSALESMAN  
            REPLACE po_nbr     WITH MPO_NBR    
            REPLACE po_suffix  WITH MPO_SUFFIX 
            REPLACE INV_NBR    WITH STR(MINV_NBR,5)   
            REPLACE RSUPCODE WITH MRSUPCODE
            REPLACE POST_DATE  WITH DATE()
            REPLACE TRAN_MO     WITH MTRAN_MO
            REPLACE TRAN_YR     WITH MTRAN_YR
            REPLACE AMOUNT WITH MAMOUNT
            IF MCK_NBR = 0
               REPLACE TRAN_DATE WITH MSHIP_DATE
               REPLACE COR_FLG WITH 'Y'
            ELSE
               REPLACE CK_NBR WITH STR(MCK_NBR,6)
               REPLACE TRAN_DATE WITH MCK_DATE
               REPLACE COR_FLG WITH 'D'
            ENDIF
            UNLOCK
         ENDDO
         
      CASE MCUS_X = 'X'
         SELECT B
         DO FOX_USE WITH "CUSLED INDEX CUSLED, CUSMATCH, CUSNOMAT", .F.
         MMORE_ENT = .T.
         DO WHILE MMORE_ENT
            STORE SPACE(4) TO MPO_NBR
            STORE SPACE(5) TO MINV_NBR
            STORE SPACE(1) TO MPO_SUFFIX
            STORE SPACE(2) TO MSALESMAN
            STORE CTOD(' ') TO MSHIP_DATE
            STORE 0 TO MAMOUNT, MINV_NBR
            STORE SPACE(32) TO MNAME
            MCK_NBR = 0
            MCK_DATE = CTOD(' ')
            STORE 2 TO MACTION   
            DO WHILE MACTION = 2
               @ 6,1 SAY '  CUSTOMER NAME: '
               @ 8,1 SAY '      PO NUMBER: ' 
               @ 8,20 SAY '-'                
               @ 8,25 SAY '-'              
               @ 10,1 SAY  '   INVOICE NBR: '    
               @ 12,1 SAY '     SHIP DATE: '
               @ 14,1 SAY ' LEDGER AMOUNT: '
               @ 16,1 SAY '(Note: The above amount can be a negative number.)'
               @ 18,1 SAY '(OPT) CHECK NBR:'   
               @ 20,1 SAY '(OPT) CHECK DATE:'
               @ 6,18 GET MNAME
               @ 8,18 GET MSALESMAN        
               @ 8,21 GET MPO_NBR PICTURE '####'
               @ 8,26 GET MPO_SUFFIX PICTURE '@!'
               @ 10,18 GET MINV_NBR PICTURE '#####'
               @ 12,18 GET MSHIP_DATE
               @ 14,18 GET MAMOUNT PICTURE '#,###,###.##'
               @ 18,18 GET MCK_NBR PICTURE '######'
               @ 20,19 GET MCK_DATE
               READ
               STORE 1 TO MACTION
               @ 24,0 CLEAR
               @ 24,01 SAY 'Action: ' + STR(MACTION,1)
               @ 24,13 SAY '1. Continue     2. Edit      3. Cancel Entry'
               @ 24,9 GET MACTION PICTURE '9' range 1,3
               READ
               IF MACTION = 1
                  IF MINV_NBR = 0 .AND. MSALESMAN = SPACE(2) .AND. MPO_NBR = SPACE(4)
                     MACTION = 3
                     LOOP
                  ENDIF
                  IF MPO_NBR = SPACE(4)
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,1 SAY 'PURCHASE ORDER NUMBER MUST BE ENTERED - PRESS RETURN TO REENTER ' GET MWAIT
                     READ
                     @ 24,0 CLEAR
                     MACTION = 2
                     LOOP
                  ENDIF
                  IF MSALESMAN <> SPACE(2)
                     SELECT A
                     DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
                     SEEK MSALESMAN
                     IF  EOF()
                        @ 24,0 CLEAR
                        STORE ' ' TO MWAIT
                        @ 24,0 SAY 'INVALID SALESPERSON CODE - PRESS RETURN TO REENTER ' GET MWAIT
                        READ
                        @ 24,0 CLEAR
                        MACTION = 2
                        LOOP
                     ENDIF
                  ENDIF
                  MNAME_FD = .F.
                  SELECT A
                  DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
                  DO BBUYSEL2
                  IF .NOT. MNAME_FD .OR. MACTION = 3
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'VALID CUSTOMER MUST BE SELECTED - PRESS RETURN TO REENTER ' GET MWAIT
                     READ
                     @ 24,0 CLEAR
                     MACTION = 2
                     LOOP
                  ENDIF
                  STORE NAME TO MBBUYNAME
                  STORE BBUYCODE TO MBBUYCODE
               ENDIF
            ENDDO
            IF MACTION = 3
               MMORE_ENT = .F.
               LOOP
            ENDIF
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE salesman   WITH MSALESMAN  
            REPLACE po_nbr     WITH MPO_NBR    
            REPLACE po_suffix  WITH MPO_SUFFIX 
            REPLACE INV_NBR    WITH STR(MINV_NBR,5)   
            REPLACE BBUYCODE WITH MBBUYCODE
            REPLACE POST_DATE  WITH DATE()
            REPLACE TRAN_MO     WITH MTRAN_MO
            REPLACE TRAN_YR     WITH MTRAN_YR
            REPLACE AMOUNT WITH MAMOUNT
            IF MCK_NBR = 0
               REPLACE TRAN_DATE WITH MSHIP_DATE
               REPLACE COR_FLG WITH 'Y'
            ELSE
               REPLACE CK_NBR WITH STR(MCK_NBR,6)
               REPLACE TRAN_DATE WITH MCK_DATE
               REPLACE COR_FLG WITH 'R'
            ENDIF
            UNLOCK
         ENDDO
         
         
      CASE MCOM_X = 'X'
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            STORE ' ' TO MCHOICE
            @ 10,10 SAY 'Is this Entry for Midwest Salespersons (M) '
            @ 12,10 say '       or for Third Party Salespersons (T)? ' get mchoice picture '@!'
            READ
            STORE 1 TO MACTION
            @ 24,0 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue     2. Edit      3. Cancel Entry'
            @ 24,9 GET MACTION PICTURE '9' range 1,3
            READ
            IF MACTION = 1
               IF MCHOICE <> 'M' .AND. MCHOICE <> 'T'
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  @ 24,1 SAY 'PLEASE ENTER "M" OR "T" - PRESS RETURN TO REENTER ' GET MWAIT
                  READ
                  @ 24,0 CLEAR
                  MACTION = 2
                  LOOP
               ENDIF
            ENDIF
         ENDDO
         IF MACTION <> 3
            SELECT B
            DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
            MMORE_ENT = .T.
            DO WHILE MMORE_ENT
               STORE SPACE(4) TO MPO_NBR
               STORE SPACE(5) TO MINV_NBR
               STORE SPACE(1) TO MPO_SUFFIX
               STORE SPACE(2) TO MSALESMAN
               STORE CTOD(' ') TO MSHIP_DATE
               STORE 0 TO MAMOUNT, MINV_NBR
               STORE 'N' TO MYES_NO
               STORE SPACE(32) TO MNAME
               MCK_NBR = 0
               MCK_DATE = CTOD(' ')
               STORE 2 TO MACTION   
               DO WHILE MACTION = 2
                  @ 6,1 SAY 'COMMISSION NAME: '
                  @ 8,1 SAY '      PO NUMBER: ' 
                  @ 8,20 SAY '-'                
                  @ 8,25 SAY '-'              
                  @ 10,1 SAY  '   INVOICE NBR: '    
                  @ 12,1 SAY '     SHIP DATE: '
                  @ 14,1 SAY ' LEDGER AMOUNT: '
                  @ 16,1 SAY '(Note: The above amount can be a negative number.)'
                  @ 18,1 SAY '(OPT) CHECK NBR:'   
                  @ 20,1 SAY '(OPT) CHECK DATE:'
                  @ 6,18 GET MNAME
                  @ 8,18 GET MSALESMAN        
                  @ 8,21 GET MPO_NBR PICTURE '####'
                  @ 8,26 GET MPO_SUFFIX PICTURE '@!'
                  @ 10,18 GET MINV_NBR PICTURE '#####'
                  @ 12,18 GET MSHIP_DATE
                  @ 14,18 GET MAMOUNT PICTURE '#,###,###.##'
                  @ 18,18 GET MCK_NBR PICTURE '######'
                  @ 20,19 GET MCK_DATE
                  READ
                  STORE 1 TO MACTION
                  @ 24,0 CLEAR
                  @ 24,01 SAY 'Action: ' + STR(MACTION,1)
                  @ 24,13 SAY '1. Continue     2. Edit      3. Cancel Entry'
                  @ 24,9 GET MACTION PICTURE '9' range 1,3
                  READ
                  IF MACTION = 1
                     IF MINV_NBR = 0 .AND. MSALESMAN = SPACE(2) .AND. MPO_NBR = SPACE(4)
                        MACTION = 3
                        LOOP
                     ENDIF
                     IF MPO_NBR = SPACE(4)
                        @ 24,0 CLEAR
                        STORE ' ' TO MWAIT
                        @ 24,1 SAY 'PURCHASE ORDER NUMBER MUST BE ENTERED - PRESS RETURN TO REENTER ' GET MWAIT
                        READ
                        @ 24,0 CLEAR
                        MACTION = 2
                        LOOP
                     ENDIF
                     IF MSALESMAN <> SPACE(2)
                        SELECT A
                        DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
                        SEEK MSALESMAN
                        IF  EOF()
                           @ 24,0 CLEAR
                           STORE ' ' TO MWAIT
                           @ 24,0 SAY 'INVALID SALESPERSON CODE - PRESS RETURN TO REENTER ' GET MWAIT
                           READ
                           @ 24,0 CLEAR
                           MACTION = 2
                           LOOP
                        ENDIF
                     ENDIF
                     SELECT A
                     IF MCHOICE = 'M'
                        SELECT A
                        DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
                        SEEK TRIM(MNAME)
                        IF EOF()
                           @ 24,0 CLEAR
                           STORE ' ' TO MWAIT
                           @ 24,1 SAY 'VALID SALESPERSON NAME MUST BE ENTERED - PRESS RETURN TO REENTER ' GET MWAIT
                           READ
                           @ 24,0 CLEAR
                           MACTION = 2
                           LOOP
                        ELSE
                           STORE NAME TO MNAME
                           STORE SALE_CODE TO MCOM_CODE 
                        ENDIF
                     ELSE
                        SELECT A
                        DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
                        SEEK TRIM(MNAME)
                        IF EOF()
                           @ 24,0 CLEAR
                           STORE ' ' TO MWAIT
                           @ 24,1 SAY 'THIRD PARTY PAYEE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
                           READ
                           @ 24,0 CLEAR
                           MACTION = 2
                           LOOP
                        ELSE
                           STORE NAME TO MNAME
                           STORE COM_CODE TO MCOM_CODE
                        ENDIF
                     ENDIF
                  ENDIF
               ENDDO
               IF MACTION = 3
                  MMORE_ENT = .F.
                  LOOP
               ENDIF
               SELECT B
               DO FILELOCK
               APPEND BLANK
               REPLACE salesman   WITH MSALESMAN  
               REPLACE po_nbr     WITH MPO_NBR    
               REPLACE po_suffix  WITH MPO_SUFFIX 
               REPLACE INV_NBR    WITH STR(MINV_NBR,5)   
               REPLACE COM_CODE WITH MCOM_CODE
               IF MCHOICE = 'M'
                  REPLACE COM_TYPE WITH 'S'
               ELSE
                  REPLACE COM_TYPE WITH 'T'
               ENDIF
               REPLACE POST_DATE  WITH DATE()
               REPLACE TRAN_MO     WITH MTRAN_MO
               REPLACE TRAN_YR     WITH MTRAN_YR
               REPLACE AMOUNT WITH MAMOUNT
               IF MCK_NBR = 0
                  REPLACE TRAN_DATE WITH MSHIP_DATE
                  REPLACE COR_FLG WITH 'Y'
               ELSE
                  REPLACE CK_NBR WITH STR(MCK_NBR,6)
                  REPLACE TRAN_DATE WITH MCK_DATE
                  REPLACE COR_FLG WITH 'D'
               ENDIF
               *REPLACE SEQ WITH '1'
               UNLOCK
            ENDDO
         ENDIF
      ENDCASE
   CASE MSELECT3 = '8'
      STORE 0 TO MCK_NBR, MNEW_CKNBR
      STORE CTOD(' ') TO MCK_DATE, MNEW_CKDT
      
      STORE SPACE(4) TO MACCOUNT01, MACCOUNT02, MACCOUNT03, MACCOUNT04, MACCOUNT05, MACCOUNT06
      STORE 0 TO MREC01, MREC02, MREC03, MREC04, MREC05, MREC06
      STORE 0 TO MAMT01, MAMT02, MAMT03, MAMT04, MAMT05, MAMT06
      
      STORE SPACE(4) TO MACCOUNT07, MACCOUNT08, MACCOUNT09, MACCOUNT10, MACCOUNT11, MACCOUNT12
      STORE 0 TO MREC07, MREC08, MREC09, MREC10, MREC11, MREC12
      STORE 0 TO MAMT07, MAMT08, MAMT09, MAMT10, MAMT11, MAMT12
      
      SELECT B
      DO FOX_USE WITH "DISBJRN INDEX DISBJRN, DISB_PO, DISBINV, DISBSTR, DISBINQ", .F.
      MPO_FD = .F.
      STORE 1 TO MACTION
      MPO_SEL = .T.
      
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - CHANGE ISSUED CHECK INFO'          
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      STORE ' ' TO MCHOICE1, MCHOICE2
      @ 5,1 SAY "Select with an 'X' which information to change"
      @ 8,1 say  'Check Number/Date: ' get mchoice1 picture '@!' VALID(MCHOICE1 = 'X' .OR. MCHOICE1 = ' ')
      @ 10,1 say 'Account Codes/Amounts (Misc Check ONLY): ' get mchoice2 picture '@!' VALID(MCHOICE2 = 'X' .OR. MCHOICE2 = ' ')
      READ
      @ 5,01 CLEAR TO 21,78
      DO CASE
      CASE MCHOICE1 = 'X'
         DO WHILE MPO_SEL
            @  5, 5 SAY 'Enter Old Check Number: ' GET MCK_NBR PICTURE '######'         
            @  6, 5 SAY '  Enter Old Check Date: ' GET MCK_DATE
            @  9, 5 SAY 'Enter New Check Number: ' GET MNEW_CKNBR PICTURE '######'         
            @ 10, 5 SAY '  Enter New Check Date: ' GET MNEW_CKDT
            
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
            @ 24,13 SAY '1. Continue    2. Edit     3. Cancel'                                     
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
            
            DO CASE
            CASE MACTION = 3
               MPO_SEL = .F.
               LOOP
               
            CASE MACTION = 1
               IF MCK_NBR = 0
                  MPO_SEL = .F.
                  LOOP
               ENDIF
               STORE DTOC(MCK_DATE) TO MDATE
               STORE SUBSTR(MDATE,1,2) TO MJRNL_MO
               STORE SUBSTR(MDATE,4,2) TO MJRNL_DAY
               STORE SUBSTR(MDATE,7) TO MJRNL_YR
               STORE STR(MCK_NBR,6) TO MNBR
               STORE DTOC(MNEW_CKDT) TO MNEW_DATE
               STORE SUBSTR(MNEW_DATE,1,2) TO MNEW_MO
               STORE SUBSTR(MNEW_DATE,4,2) TO MNEW_DAY
               STORE SUBSTR(MNEW_DATE,7) TO MNEW_YR
               
               SELECT B
               SEEK MJRNL_YR + MJRNL_MO + MJRNL_DAY + MNBR   
               IF EOF()
                  STORE 'CHECK NUMBER NOT FOUND ON FILE WITH THIS DATE - PRESS RETURN TO REENTER ' TO MMSG
                  @ 16,1 SAY SPACE(78)
                  @ 16,1 GET MMSG
                  READ  
                  @ 16,1 SAY SPACE(78)
                  LOOP
               ENDIF
               DO WHILE .NOT. EOF()
                  DO FILELOCK
                  REPLACE CK_NBR WITH STR(MNEW_CKNBR,6)
                  REPLACE JRNL_MO  WITH MNEW_MO
                  REPLACE JRNL_YR  WITH MNEW_YR
                  REPLACE JRNL_DAY WITH MNEW_DAY
                  UNLOCK
                  SEEK MJRNL_YR + MJRNL_MO + MJRNL_DAY + MNBR
               ENDDO
               SELECT B
               DO FOX_USE WITH "CK_REG INDEX CK_REG", .F.
               SEEK MNBR
               DO WHILE .NOT. EOF()
                  DO FILELOCK
                  REPLACE CK_NBR WITH STR(MNEW_CKNBR,6)
                  REPLACE CK_DATE WITH MNEW_CKDT
                  UNLOCK
                  SEEK MNBR
               ENDDO
               MPO_SEL = .F.
               MWAIT = ' '
               @ 24,1 SAY 'CHECK NUMBER AND/OR DATE CHANGED - PRESS ENTER ' GET MWAIT
               READ
               
            CASE MACTION = 2
               LOOP
               
            ENDCASE
            
         ENDDO
         CLOSE DATA
         
      CASE MCHOICE2 = 'X'
         DO WHILE MPO_SEL
            STORE SPACE(6) TO MCK_NBR
            @  5, 5 SAY 'Enter Check Number'
            @  7,10 get mck_nbr PICTURE '@!'                     
            @ 10,5 SAY ' Enter Check Date  '
            @ 12,10 get MCK_DATE
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
            @ 24,13 SAY '1. Continue    2. Edit     3. Cancel'                                     
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
            
            DO CASE
            CASE MACTION = 3
               MPO_SEL = .F.
               LOOP
               
            CASE MACTION = 1
               IF MCK_NBR = SPACE(6)
                  MPO_SEL = .F.
                  LOOP
               ENDIF
               I = 1
               DO WHILE I <=12
                  STORE SUBSTR(STR(I+100,3),2) TO MI
                  STORE 0 TO MREC&MI, MAMT&MI
                  STORE SPACE(4) TO MACCOUNT&MI
                  I = I + 1
               ENDDO
               STORE DTOC(MCK_DATE) TO MDATE
               STORE SUBSTR(MDATE,1,2) TO MJRNL_MO
               STORE SUBSTR(MDATE,4,2) TO MJRNL_DAY
               STORE SUBSTR(MDATE,7) TO MJRNL_YR
               IF SUBSTR(MCK_NBR,1,1) <> '1'.AND. SUBSTR(MCK_NBR,1,1) <> '2' .AND. SUBSTR(MCK_NBR,1,1) <> '3' ;
                  .AND. SUBSTR(MCK_NBR,1,1) <> '4' .AND. SUBSTR(MCK_NBR,1,1) <> '5' .AND. SUBSTR(MCK_NBR,1,1) <> '6' ;
                  .AND. SUBSTR(MCK_NBR,1,1) <> '7' .AND. SUBSTR(MCK_NBR,1,1) <> '8' .AND. SUBSTR(MCK_NBR,1,1) <> '9'
                  STORE MCK_NBR  TO MNBR
               ELSE
                  STORE VAL(MCK_NBR) TO MCK_NBR
                  STORE STR(MCK_NBR,6) TO MNBR
               ENDIF
               SELECT B
               SEEK MJRNL_YR + MJRNL_MO + MJRNL_DAY + MNBR   
               IF EOF()
                  STORE 'CHECK NUMBER NOT FOUND ON FILE WITH THIS DATE - PRESS RETURN TO REENTER ' TO MMSG
                  @ 16,1 SAY SPACE(78)
                  @ 16,1 GET MMSG
                  READ  
                  @ 16,1 SAY SPACE(78)
                  LOOP
               ENDIF

               STORE ACCT_TYPE TO MACCT_TYPE
               STORE ACCT_NAME TO MACCT_NAME
               STORE SYS_DATE  TO MSYS_DATE

               STORE 1 TO I
               DO WHILE .NOT. EOF() .AND. CK_NBR = MNBR .AND. JRNL_YR = MJRNL_YR .AND. JRNL_DAY = MJRNL_DAY .AND. JRNL_MO = MJRNL_MO .AND. I <=12
                  STORE SUBSTR(STR(I+100,3),2) TO MI
                  STORE RECNO() TO MREC&MI
                  STORE CATEGORY1 TO MACCOUNT&MI
                  STORE AMOUNT1 TO MAMT&MI
                  SKIP
                  I = I + 1
               ENDDO
               @ 15,1 SAY '1.  ACCOUNT: '
               @ 15,14 GET MACCOUNT01 PICTURE '####'
               @ 15,24 GET MAMT01 PICTURE '9,999,999.99'
               *IF MACCOUNT02 <> SPACE(4)
                  @ 16,1 SAY '2.  ACCOUNT: '
                  @ 16,14 GET MACCOUNT02 PICTURE '####'
                  @ 16,24 GET MAMT02 PICTURE '9,999,999.99'
               *ENDIF
               *IF MACCOUNT03 <> SPACE(4)
                  @ 17,1 SAY '3.  ACCOUNT: '
                  @ 17,14 GET MACCOUNT03 PICTURE '####'
                  @ 17,24 GET MAMT03 PICTURE '9,999,999.99'
               *ENDIF
               *IF MACCOUNT04 <> SPACE(4)
                  @ 18,1 SAY '4.  ACCOUNT: '
                  @ 18,14 GET MACCOUNT04 PICTURE '####'
                  @ 18,24 GET MAMT04 PICTURE '9,999,999.99'
               *ENDIF
               *IF MACCOUNT05 <> SPACE(4)
                  @ 19,1 SAY '5.  ACCOUNT: '
                  @ 19,14 GET MACCOUNT05 PICTURE '####'
                  @ 19,24 GET MAMT05 PICTURE '9,999,999.99'
               *ENDIF
               *IF MACCOUNT06 <> SPACE(4)
                  @ 20,1    SAY '6.  ACCOUNT: '
                  @ 20,14   GET MACCOUNT06 PICTURE '####'
                  @ 20,24   GET MAMT06 PICTURE '9,999,999.99'
               *ENDIF
               *IF MACCOUNT07 <> SPACE(4)
                  @ 15,40   SAY ' 7. ACCOUNT: '
                  @ 15,54   GET MACCOUNT07 PICTURE '####'
                  @ 15,63   GET MAMT07 PICTURE '9,999,999.99'
               *ENDIF
               *IF MACCOUNT08 <> SPACE(4)
                  @ 16,40 SAY ' 8. ACCOUNT: '
                  @ 16,54 GET MACCOUNT08 PICTURE '####'
                  @ 16,63 GET MAMT08 PICTURE '9,999,999.99'
               *ENDIF
               *IF MACCOUNT09 <> SPACE(4)
                  @ 17,40 SAY ' 9. ACCOUNT: '
                  @ 17,54 GET MACCOUNT09 PICTURE '####'
                  @ 17,63 GET MAMT09 PICTURE '9,999,999.99'
               *ENDIF
               *IF MACCOUNT10 <> SPACE(4)
                  @ 18,40 SAY '10. ACCOUNT: '
                  @ 18,54 GET MACCOUNT10 PICTURE '####'
                  @ 18,63 GET MAMT10 PICTURE '9,999,999.99'
               *ENDIF
               *IF MACCOUNT11 <> SPACE(4)
                  @ 19,40 SAY '11. ACCOUNT: '
                  @ 19,54 GET MACCOUNT11 PICTURE '####'
                  @ 19,63 GET MAMT11 PICTURE '9,999,999.99'
               *ENDIF
               *IF MACCOUNT12 <> SPACE(4)
                  @ 20,40 SAY '12  ACCOUNT: '
                  @ 20,54 GET MACCOUNT12 PICTURE '####'
                  @ 20,63 GET MAMT12 PICTURE '9,999,999.99'
               *ENDIF
               
               STORE 1 TO MACTION
               @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
               @ 24,13 SAY '1. Continue    2. Edit     3. Cancel'
               
               READ
               
               @24,09 GET MACTION PICTURE '9' RANGE 1,3
               READ               
               IF MACTION = 3
                  MPO_SEL = .F.
               ENDIF
               IF MACTION = 1
                  MTOT_AMT = 0
                  
                  IF MREC01 <> 0
                     GOTO MREC01
                     DO FILELOCK
                     REPLACE CATEGORY1 WITH MACCOUNT01
                     REPLACE AMOUNT1   WITH MAMT01
                     UNLOCK
                     MTOT_AMT = MTOT_AMT + MAMT01
                  ELSE
                     IF MAMT01 <> 0 .OR. MACCOUNT01 <> SPACE(4)
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE JRNL_MO  WITH MJRNL_MO
                        REPLACE JRNL_DAY WITH MJRNL_DAY
                        REPLACE JRNL_YR  WITH MJRNL_YR
                        REPLACE CK_NBR   WITH MNBR
                        REPLACE CATEGORY1 WITH MACCOUNT01
                        REPLACE AMOUNT1   WITH MAMT01
                        REPLACE ACCT_TYPE WITH MACCT_TYPE
                        REPLACE ACCT_NAME WITH MACCT_NAME
                        REPLACE SYS_DATE  WITH MSYS_DATE
                        UNLOCK
                        MTOT_AMT = MTOT_AMT + MAMT01
                     ENDIF
                  ENDIF
                  
                  IF MREC02 <> 0
                     GOTO MREC02
                     DO FILELOCK
                     REPLACE CATEGORY1 WITH MACCOUNT02
                     REPLACE AMOUNT1   WITH MAMT02
                     MTOT_AMT = MTOT_AMT + MAMT02
                     UNLOCK
                  ELSE
                     IF MAMT02 <> 0 .OR. MACCOUNT02 <> SPACE(4)
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE JRNL_MO  WITH MJRNL_MO
                        REPLACE JRNL_DAY WITH MJRNL_DAY
                        REPLACE JRNL_YR  WITH MJRNL_YR
                        REPLACE CK_NBR   WITH MNBR
                        REPLACE CATEGORY1 WITH MACCOUNT02
                        REPLACE AMOUNT1   WITH MAMT02
                        REPLACE ACCT_TYPE WITH MACCT_TYPE
                        REPLACE ACCT_NAME WITH MACCT_NAME
                        REPLACE SYS_DATE  WITH MSYS_DATE
                        UNLOCK
                        MTOT_AMT = MTOT_AMT + MAMT02
                     ENDIF
                  ENDIF
                  IF MREC03 <> 0
                     GOTO MREC03
                     DO FILELOCK
                     REPLACE CATEGORY1 WITH MACCOUNT03
                     REPLACE AMOUNT1   WITH MAMT03 
                     MTOT_AMT = MTOT_AMT + MAMT03
                     UNLOCK
                  ELSE
                     IF MAMT03 <> 0 .OR. MACCOUNT03 <> SPACE(4)
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE JRNL_MO  WITH MJRNL_MO
                        REPLACE JRNL_DAY WITH MJRNL_DAY
                        REPLACE JRNL_YR  WITH MJRNL_YR
                        REPLACE CK_NBR   WITH MNBR
                        REPLACE CATEGORY1 WITH MACCOUNT03
                        REPLACE AMOUNT1   WITH MAMT03
                        REPLACE ACCT_TYPE WITH MACCT_TYPE
                        REPLACE ACCT_NAME WITH MACCT_NAME
                        REPLACE SYS_DATE  WITH MSYS_DATE
                        UNLOCK
                        MTOT_AMT = MTOT_AMT + MAMT03
                     ENDIF
                  ENDIF
                  IF MREC04 <> 0
                     GOTO MREC04
                     DO FILELOCK
                     REPLACE CATEGORY1 WITH MACCOUNT04
                     REPLACE AMOUNT1   WITH MAMT04
                     MTOT_AMT = MTOT_AMT + MAMT04
                     UNLOCK
                  ELSE
                     IF MAMT04 <> 0 .OR. MACCOUNT04 <> SPACE(4)
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE JRNL_MO  WITH MJRNL_MO
                        REPLACE JRNL_DAY WITH MJRNL_DAY
                        REPLACE JRNL_YR  WITH MJRNL_YR
                        REPLACE CK_NBR   WITH MNBR
                        REPLACE CATEGORY1 WITH MACCOUNT04
                        REPLACE AMOUNT1   WITH MAMT04
                        REPLACE ACCT_TYPE WITH MACCT_TYPE
                        REPLACE ACCT_NAME WITH MACCT_NAME
                        REPLACE SYS_DATE  WITH MSYS_DATE
                        UNLOCK
                        MTOT_AMT = MTOT_AMT + MAMT04
                     ENDIF
                  ENDIF
                  IF MREC05 <> 0
                     GOTO MREC05
                     DO FILELOCK
                     REPLACE CATEGORY1 WITH MACCOUNT05
                     REPLACE AMOUNT1   WITH MAMT05
                     MTOT_AMT = MTOT_AMT + MAMT05
                     UNLOCK
                  ELSE
                     IF MAMT05 <> 0 .OR. MACCOUNT05 <> SPACE(4)
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE JRNL_MO  WITH MJRNL_MO
                        REPLACE JRNL_DAY WITH MJRNL_DAY
                        REPLACE JRNL_YR  WITH MJRNL_YR
                        REPLACE CK_NBR   WITH MNBR
                        REPLACE CATEGORY1 WITH MACCOUNT05
                        REPLACE AMOUNT1   WITH MAMT05
                        REPLACE ACCT_TYPE WITH MACCT_TYPE
                        REPLACE ACCT_NAME WITH MACCT_NAME
                        REPLACE SYS_DATE  WITH MSYS_DATE
                        UNLOCK
                        MTOT_AMT = MTOT_AMT + MAMT05
                     ENDIF
                  ENDIF
                  IF MREC06 <> 0
                     GOTO MREC06
                     DO FILELOCK
                     REPLACE CATEGORY1 WITH MACCOUNT06
                     REPLACE AMOUNT1   WITH MAMT06
                     MTOT_AMT = MTOT_AMT + MAMT06
                     UNLOCK
                  ELSE
                     IF MAMT06 <> 0 .OR. MACCOUNT06 <> SPACE(4)
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE JRNL_MO  WITH MJRNL_MO
                        REPLACE JRNL_DAY WITH MJRNL_DAY
                        REPLACE JRNL_YR  WITH MJRNL_YR
                        REPLACE CK_NBR   WITH MNBR
                        REPLACE CATEGORY1 WITH MACCOUNT06
                        REPLACE AMOUNT1   WITH MAMT06
                        REPLACE ACCT_TYPE WITH MACCT_TYPE
                        REPLACE ACCT_NAME WITH MACCT_NAME
                        REPLACE SYS_DATE  WITH MSYS_DATE
                        UNLOCK
                        MTOT_AMT = MTOT_AMT + MAMT06
                     ENDIF
                  ENDIF
                  IF MREC07 <> 0
                     GOTO MREC07
                     DO FILELOCK
                     REPLACE CATEGORY1 WITH MACCOUNT07
                     REPLACE AMOUNT1   WITH MAMT07
                     MTOT_AMT = MTOT_AMT + MAMT07
                     UNLOCK
                  ELSE
                     IF MAMT07 <> 0 .OR. MACCOUNT07 <> SPACE(4)
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE JRNL_MO  WITH MJRNL_MO
                        REPLACE JRNL_DAY WITH MJRNL_DAY
                        REPLACE JRNL_YR  WITH MJRNL_YR
                        REPLACE CK_NBR   WITH MNBR
                        REPLACE CATEGORY1 WITH MACCOUNT07
                        REPLACE AMOUNT1   WITH MAMT07
                        REPLACE ACCT_TYPE WITH MACCT_TYPE
                        REPLACE ACCT_NAME WITH MACCT_NAME
                        REPLACE SYS_DATE  WITH MSYS_DATE
                        UNLOCK
                        MTOT_AMT = MTOT_AMT + MAMT07
                     ENDIF
                  ENDIF
                  IF MREC08 <> 0
                     GOTO MREC08
                     DO FILELOCK
                     REPLACE CATEGORY1 WITH MACCOUNT08
                     REPLACE AMOUNT1   WITH MAMT08
                     MTOT_AMT = MTOT_AMT + MAMT08
                     UNLOCK
                  ELSE
                     IF MAMT08 <> 0 .OR. MACCOUNT08 <> SPACE(4)
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE JRNL_MO  WITH MJRNL_MO
                        REPLACE JRNL_DAY WITH MJRNL_DAY
                        REPLACE JRNL_YR  WITH MJRNL_YR
                        REPLACE CK_NBR   WITH MNBR
                        REPLACE CATEGORY1 WITH MACCOUNT08
                        REPLACE AMOUNT1   WITH MAMT08
                        REPLACE ACCT_TYPE WITH MACCT_TYPE
                        REPLACE ACCT_NAME WITH MACCT_NAME
                        REPLACE SYS_DATE  WITH MSYS_DATE
                        UNLOCK
                        MTOT_AMT = MTOT_AMT + MAMT08
                     ENDIF
                  ENDIF
                  IF MREC09 <> 0
                     GOTO MREC09
                     DO FILELOCK
                     REPLACE CATEGORY1 WITH MACCOUNT09
                     REPLACE AMOUNT1   WITH MAMT09
                     MTOT_AMT = MTOT_AMT + MAMT09
                     UNLOCK
                  ELSE
                     IF MAMT09 <> 0 .OR. MACCOUNT09 <> SPACE(4)
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE JRNL_MO  WITH MJRNL_MO
                        REPLACE JRNL_DAY WITH MJRNL_DAY
                        REPLACE JRNL_YR  WITH MJRNL_YR
                        REPLACE CK_NBR   WITH MNBR
                        REPLACE CATEGORY1 WITH MACCOUNT09
                        REPLACE AMOUNT1   WITH MAMT09
                        REPLACE ACCT_TYPE WITH MACCT_TYPE
                        REPLACE ACCT_NAME WITH MACCT_NAME
                        REPLACE SYS_DATE  WITH MSYS_DATE
                        UNLOCK
                        MTOT_AMT = MTOT_AMT + MAMT09
                     ENDIF
                  ENDIF
                  IF MREC10 <> 0
                     GOTO MREC10
                     DO FILELOCK
                     REPLACE CATEGORY1 WITH MACCOUNT10
                     REPLACE AMOUNT1   WITH MAMT10
                     MTOT_AMT = MTOT_AMT + MAMT10
                     UNLOCK
                  ELSE
                     IF MAMT10 <> 0 .OR. MACCOUNT10 <> SPACE(4)
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE JRNL_MO  WITH MJRNL_MO
                        REPLACE JRNL_DAY WITH MJRNL_DAY
                        REPLACE JRNL_YR  WITH MJRNL_YR
                        REPLACE CK_NBR   WITH MNBR
                        REPLACE CATEGORY1 WITH MACCOUNT10
                        REPLACE AMOUNT1   WITH MAMT10
                        REPLACE ACCT_TYPE WITH MACCT_TYPE
                        REPLACE ACCT_NAME WITH MACCT_NAME
                        REPLACE SYS_DATE  WITH MSYS_DATE
                        UNLOCK
                        MTOT_AMT = MTOT_AMT + MAMT10
                     ENDIF
                  ENDIF
                  IF MREC11 <> 0
                     GOTO MREC11
                     DO FILELOCK
                     REPLACE CATEGORY1 WITH MACCOUNT11
                     REPLACE AMOUNT1   WITH MAMT11
                     MTOT_AMT = MTOT_AMT + MAMT11
                     UNLOCK
                  ELSE
                     IF MAMT11 <> 0 .OR. MACCOUNT11 <> SPACE(4)
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE JRNL_MO  WITH MJRNL_MO
                        REPLACE JRNL_DAY WITH MJRNL_DAY
                        REPLACE JRNL_YR  WITH MJRNL_YR
                        REPLACE CK_NBR   WITH MNBR
                        REPLACE CATEGORY1 WITH MACCOUNT11
                        REPLACE AMOUNT1   WITH MAMT11
                        REPLACE ACCT_TYPE WITH MACCT_TYPE
                        REPLACE ACCT_NAME WITH MACCT_NAME
                        REPLACE SYS_DATE  WITH MSYS_DATE
                        UNLOCK
                        MTOT_AMT = MTOT_AMT + MAMT11
                     ENDIF
                  ENDIF
                  IF MREC12 <> 0
                     GOTO MREC12
                     DO FILELOCK
                     REPLACE CATEGORY1 WITH MACCOUNT12
                     REPLACE AMOUNT1   WITH MAMT12
                     MTOT_AMT = MTOT_AMT + MAMT12
                     UNLOCK
                  ELSE
                     IF MAMT12 <> 0 .OR. MACCOUNT12 <> SPACE(4)
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE JRNL_MO  WITH MJRNL_MO
                        REPLACE JRNL_DAY WITH MJRNL_DAY
                        REPLACE JRNL_YR  WITH MJRNL_YR
                        REPLACE CK_NBR   WITH MNBR
                        REPLACE CATEGORY1 WITH MACCOUNT12
                        REPLACE AMOUNT1   WITH MAMT12
                        REPLACE ACCT_TYPE WITH MACCT_TYPE
                        REPLACE ACCT_NAME WITH MACCT_NAME
                        REPLACE SYS_DATE  WITH MSYS_DATE
                        UNLOCK
                        MTOT_AMT = MTOT_AMT + MAMT12
                     ENDIF
                  ENDIF
                  MPO_SEL = .F.
                  
                  SELECT C
                  DO FOX_USE WITH "CK_REG INDEX CK_REG", .F.
                  SEEK MNBR
                  IF .NOT. EOF()
                     DO FILELOCK
                     REPLACE AMOUNT WITH MTOT_AMT
                     UNLOCK
                  ENDIF
                  USE
               ENDIF
            CASE MACTION = 2
               LOOP
               
            ENDCASE
            
         ENDDO
         CLOSE DATA
      ENDCASE
   ENDCASE
ENDDO
RETURN
*Formatted by: ToolBox Ver. 1.2  on 2/4/19 at 1:43 PM.
