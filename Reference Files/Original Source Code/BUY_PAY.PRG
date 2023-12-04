**********
* Program.: BUY_PAY.PRG
* Author..: GRACE KELLER
* Date....: 01/05/88
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: CUSTOMER PAYMENT MENU   
*
* ---PROCESSING LOOP
STORE 0 TO MACTION
STORE ' ' TO MSELECTION
DIMENSION MUPDRCD(60)  
DIMENSION MPAYIND(60)
DIMENSION MPAYAMT(60)
DIMENSION MPAY_DUE(60)
DIMENSION MREASON(60)
DIMENSION MCK(16)
DIMENSION MREC(16)
DIMENSION MPD_AMT(16)
DIMENSION MAMT(16)
DIMENSION MSHRT(16)
DIMENSION MDUE(16)
DIMENSION MSW(16) 
DIMENSION MSELECT(25)
DIMENSION MCRED_REAS(16)
DO WHILE MSELECTION <> '9'
   SET PROC TO PO_PROC
   CLOSE DATA
   CLEAR
   @ 1,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 02,00 SAY MPROGRAM + ' - RECEIPTS MENU'
   @ 03,00 TO 24,79 
   
   @ 04,09 SAY '1 - ENTER RECEIPTS FROM CUSTOMERS'
   @ 06,09 SAY '2 - ENTER MISCELLANEOUS RECEIPTS'
   @ 08,09 SAY '3 - ENTER DUPLICATE CUSTOMER RECEIPTS (TWO PAYMENTS ON ONE INVOICE)'
   @ 10,09 SAY '4 - DELETE/VOID CUSTOMER RECEIPTS'
   @ 12,09 say '5 - ENTER CROSSOVER A/P RECEIPT FROM SUPPLIER/FREIGHT'   
   @ 14,09 say '6 - MOVE CUSTOMER RECEIPTS FROM RECV/MISC/CREDIT AND VICE VERSA'
   @ 16,09 SAY '7 - MOVE CREDITS FROM CREDIT BALANCE ACCOUNT TO CUSTOMER ACCOUNTS'
   @ 18,09 SAY '8 - MOVE CREDITS FROM ONE CUSTOMER ACCOUNT TO ANOTHER CUSTOMER'
   @ 20,09 SAY '9 - EXIT TO MAIN MENU'
   
   STORE '1' TO MSELECTION
   @ 22,01 SAY 'CHOICE: '
   @ 22,09 get mselection picture '9'
   READ
   
   DO CASE
      
   CASE MSELECTION = '1'
      STORE DATE() TO MPAID_DATE
      ***STORE CTOD('') TO MPAID_DATE
      ***STORE SPACE(7) TO MLOCATION
      STORE 'LOCAL  ' TO MLOCATION
      STORE ' ' TO MLOC_CODE
      MNEXT_CUST = .T.
      SET PROC TO PAY_PROC
      SELECT D
      DO FOX_USE WITH "INV_ADJ INDEX INV_ADJ", .F.
      SELECT E
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      SELECT F
      DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE, PAY_CUST, PAY_PO, PAY_SYS", .F.
      
      DO WHILE MNEXT_CUST
         SELECT B
         DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
         **DO FILELOCK
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
         STORE CRED_BAL TO MCRED_BAL
         USE
         SET PROC TO PAY_PROC
         MTITLE = ' - INVOICE PAYMENT INFORMATION'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 25,79
         DO PAY_SF
         SELECT B
         SEEK MBBUYCODE + ' '
         IF EOF()
            @ 14,1 SAY 'THERE ARE NO OUTSTANDING INVOICES FOR THIS CUSTOMER '
            @ 16,1 SAY 'PLEASE REENTER THE CUSTOMER SELECTED'
            MWAIT = ' '
            @ 18,1 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT
            READ
            LOOP
         ENDIF
         
         STORE RECNO() TO MRECNO, MFST_REC
         STORE SPACE(7) TO MCK_NBR
         STORE 0 TO MUPDRCD, MPAYIND, MPAYAMT
         STORE SPACE(1) TO MREASON             
         MSUB = 0
         STORE 0.00 TO MCK_AMT, MTOT_PAID
         MBALANCE = 0
         
         
         MEDIT = .T.
         DO WHILE MEDIT
            GOTO MFST_REC
            STORE 2 TO MACTION
            DO WHILE MACTION = 2
               DO PAY_GF1
               STORE 1 TO MACTION
               @ 25,0 CLEAR
               @ 25,01 SAY 'Action: ' + STR(MACTION,1)
               @ 25,13 SAY '1. Continue    2. Edit    3. Cancel'
               
               READ
               
               @25,09 GET MACTION PICTURE '9' RANGE 1,3
               READ               
               IF MACTION = 1
                  *** CHECK ON THE PAID DATE FOR REASONABILITY
                  IF DATE() - MPAID_DATE > 4 .OR. DATE() - MPAID_DATE < 0                                  
                     @ 25,0 CLEAR
                     mcont = ' '
                     @ 25,0 SAY 'WARNING:CHECK PAID DATE!! More than 4 Days old or in future!!-Press return ' get mcont
                     READ
                     @ 25,0 CLEAR
                  ENDIF
                  IF  MPAID_DATE = CTOD('')
                     @ 25,0 CLEAR
                     mcont = ' '
                     @ 25,0 SAY 'ERROR: NO PAID DATE ENTERED - Press return to enter one ' get mcont
                     READ
                     @ 25,0 CLEAR
                     MACTION = 2
                     LOOP
                  ENDIF
                  *IF MLOC_CODE <> 'Y' .AND. MLOC_CODE <> 'L'  .AND. MLOC_CODE <> 'B' .AND. MLOC_CODE <> 'G' .AND. MPROG_CODE = 1
                  IF MLOCATION <> 'YUMA' .AND. MLOCATION <> 'LOCKBOX'  .AND. MLOCATION <> 'LOCAL' .AND. MPROG_CODE = 1
                     @ 25,0 CLEAR
                     MCONT = ' '
                     @ 25,0 SAY 'WARNING: DEPOSIT LOCATION INVALID - Press return ' get mcont
                     READ
                     @ 25,0 CLEAR
                     MACTION = 2
                  ELSE
                     DO CASE
                     CASE MLOCATION = 'LOCKBOX'
                        MLOC_CODE = 'L'
                     CASE MLOCATION = 'LOCAL'
                        MLOC_CODE = 'B'
                     CASE MLOCATION = 'YUMA'
                        MLOC_CODE = 'Y'
                     OTHERWISE 
                        MLOC_CODE = ' '
                     ENDCASE
                  ENDIF
               ENDIF
            ENDDO    
            IF MACTION = 3
               MEDIT = .F.
               LOOP
            ENDIF
            
            MNOT_DONE = .T.
            DO WHILE MNOT_DONE
               STORE 0 TO MREC, MPD_AMT, MAMT, MSHRT, MDUE
               STORE SPACE(1) TO MCRED_REAS
               STORE ' ' TO MCK, MSW
               GOTO MRECNO
               MLINE = 12
               @ 12,1 CLEAR TO 24,78
               @ 25,0 CLEAR
               DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. MBBUYCODE = BBUYCODE .AND. PAID_FLG = ' '
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
                  I = MLINE - 11
                  STORE I TO MI
                  STORE RECNO() TO MREC(MI)
                  STORE AMT_PAID TO MAMT_PAID
                  MAMT(MI) = TOT_SELL + CUS_PALL                        
                  IF SUBSTR(MINV_NBR,1,1) <> 'A' .AND. MDEB_CRD = ' '
                     SELECT D
                     SEEK MINV_NBR
                     DO WHILE .NOT. EOF() .AND. INV_NBR = MINV_NBR
                        IF SHRT_LBS <> 0   
                           MSHRT(MI) = MSHRT(MI) + ADJ_AMT 
                        ELSE
                           MAMT(MI) = MAMT(MI) + ADJ_AMT 
                        ENDIF
                        SKIP
                     ENDDO
                     **** SET UP THE S/W FLAG HERE - BECAUSE CANNOT ENTER
                     **** PAYMENTS UNLES S/W ENTERED
                     SELECT E
                     SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
                     IF .NOT. EOF()
                        IF SHORT_FLG <> ' '
                           MSW(MI) = 'Y'
                        ENDIF
                     ENDIF
                     SELECT B 
                  ELSE
                     MSW(MI) = 'Y'
                  ENDIF
                  DO PAY_SR
                  SKIP
                  MLINE = MLINE + 1
               ENDDO
               MMAX_LINE = MLINE - 1
               STORE RECNO() TO MRECNO
               IF .NOT. EOF() .AND. BBUYCODE = MBBUYCODE .AND. PAID_FLG = ' '
                  @ 23,69 SAY 'More Inv.'
                  MBLURP = .T.
               ELSE
                  @ 23,69 SAY SPACE(9)
                  MBLURP = .F.
               ENDIF
               MLINE = 12
               I = 1
               DO WHILE MLINE <= MMAX_LINE
                  STORE I TO MI
                  DO PAY_GF2          
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
               DO WHILE I <= 16
                  STORE I TO MI
                  MPD_AMT(MI) = ROUND(MPD_AMT(MI),2)
                  MDUE(MI) = ROUND(MDUE(MI),2)
                  
                  IF MCK(MI) <> ' ' .AND. MCK(MI) <> 'P' .AND. MCK(MI) <> 'X' .AND. MCK(MI) <> 'F'
                     @ 25,0 CLEAR
                     STORE ' ' TO MWAIT
                     MERR_LINE = I       
                     MERR_LINE = STR(MERR_LINE,2)
                     @ 25,0 SAY 'PAYMENT INDICATOR ON LINE ' + MERR_LINE + ' INVALID - PRESS RETURN TO REENTER ' GET MWAIT
                     READ
                     I = 99
                     LOOP
                  ENDIF
                  IF MCK(MI) = 'P' .AND. MPD_AMT(MI) = 0
                     @ 25,0 CLEAR
                     STORE ' ' TO MWAIT
                     MERR_LINE = I      
                     MERR_LINE = STR(MERR_LINE,2)
                     @ 25,0 SAY 'PARTIAL PAYMENT ON LINE ' + MERR_LINE + ' BUT NO AMOUNT ENTERED - PRESS RETURN TO REENTER' GET MWAIT
                     READ
                     I = 99
                     LOOP
                  ENDIF
                  IF (MCK(MI) <> 'F' .AND. MCK(MI) <> 'X'.AND. MCK(MI) <> ' ') .AND. MDUE(MI) > 0 .AND. MPD_AMT(MI) > MDUE(MI)
                     @ 25,0 CLEAR
                     STORE ' ' TO MWAIT
                     MERR_LINE = I      
                     MERR_LINE = STR(MERR_LINE,2)
                     @ 25,0 SAY 'AMOUNT PAID MORE THAN AMOUT DUE - MUST PAY IN FULL ON LINE '+ MERR_LINE + ' ' GET MWAIT 
                     READ
                     I = 99
                     LOOP
                  ENDIF
                  
                  IF MCK(MI) <> ' '
                     IF MSW(MI) <> 'Y'
                        @ 25,0 CLEAR
                        STORE ' ' TO MWAIT
                        MERR_LINE = I      
                        MERR_LINE = STR(MERR_LINE,2)
                        @ 25,0 SAY 'CANNOT PAY INVOICE ON LINE ' + MERR_LINE + " - NO S/W'S ENTERED - PRESS RETURN TO REENTER" GET MWAIT
                        READ
                        I = 99
                        LOOP
                     ENDIF
                  ENDIF
                  *** MPROG_CODE = 1 FOR MIDWEST FOODS  
                  IF MPROG_CODE = 1
                     IF (MCK(MI) = 'F'.OR. MCK(MI) = 'X') .AND. MPD_AMT(MI) <> 0
                        IF MDUE(MI) > 0
                           IF MDUE(MI) - MPD_AMT(MI) > 10
                              @ 25,0 CLEAR
                              STORE ' ' TO MWAIT
                              MERR_LINE = I      
                              MERR_LINE = STR(MERR_LINE,2)
                              @ 25,0 SAY 'LINE ' + MERR_LINE + " - CANNOT UNDERPAY BY MORE THAN $ 10.00 " GET MWAIT
                              READ
                              I = 99
                              LOOP
                           ENDIF
                        ELSE
                           IF MDUE(MI) - MPD_AMT(MI) < -10
                              @ 25,0 CLEAR
                              STORE ' ' TO MWAIT
                              MERR_LINE = I      
                              MERR_LINE = STR(MERR_LINE,2)
                              @ 25,0 SAY 'LINE ' + MERR_LINE + " - MUST USE CREDIT WITHIN $ -10.00 " GET MWAIT
                              READ
                              I = 99
                              LOOP
                           ENDIF
                        ENDIF
                     ENDIF
                  ELSE
                     *** FOR MPROG_CODE = 2 - MFI - MUST ENTER A REASON CODE FOR UNDER/OVER PAY
                     IF (MCK(MI) = 'F'.OR. MCK(MI) = 'X') .AND. MPD_AMT(MI) <> 0
                        IF MDUE(MI) > 0
                           IF MDUE(MI) - MPD_AMT(MI) > 1000
                              @ 25,0 CLEAR
                              STORE ' ' TO MWAIT
                              MERR_LINE = I      
                              MERR_LINE = STR(MERR_LINE,2)
                              @ 25,0 SAY 'LINE ' + MERR_LINE + " - CANNOT UNDERPAY BY MORE THAN $ 1000 " GET MWAIT
                              READ
                              I = 99
                              LOOP
                           ENDIF
                           IF MCRED_REAS(MI) = ' '         
                              @ 25,0 CLEAR
                              STORE ' ' TO MWAIT
                              MERR_LINE = I      
                              MERR_LINE = STR(MERR_LINE,2)
                              @ 25,0 SAY 'LINE ' + MERR_LINE + " - NO REASON CODE ENTERED " GET MWAIT
                              READ
                              I = 99
                              LOOP
                           ENDIF
                        ENDIF
                     ENDIF
                  ENDIF
                  I = I + 1
               ENDDO
               IF I = 99
                  STORE MFST_REC TO MRECNO
                  LOOP
               ENDIF
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
                     @ MLINE,67 GET  MDUE(I) PICTURE '999,999.99'
                     CLEAR GETS
                     MPG_PAID = MPG_PAID + MDUE(I)
                  ELSE
                     MPG_PAID = MPG_PAID + MPD_AMT(I)
                  ENDIF
                  I = I + 1
                  MLINE = MLINE + 1
               ENDDO
               @ 6,62 SAY 'Tot Amt Selected'
               @ 7,67 SAY MPG_PAID + MTOT_PAID PICTURE '999,999.99'
               
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
                  STORE MCRED_REAS(MI) TO MREASON(MSUB)
                  I = I + 1
               ENDDO
               MTOT_PAID = MTOT_PAID + MPG_PAID
               
               IF MACTION = 3
                  LOOP
               ENDIF
               IF ROUND(MTOT_PAID,2) <> ROUND(MCK_AMT,2)
                  @ 25,0 CLEAR
                  MWAIT = ' '
                  @ 25,0 SAY 'TOTAL AMT MARKED PAID DOES NOT EQUAL CHECK AMT - PRESS RETURN TO START AGAIN ' GET MWAIT
                  READ
                  MTOT_PAID = MTOT_PAID - MPG_PAID
                  STORE MFST_REC TO MRECNO
                  MNOT_DONE = .F.
                  MEDIT = .F.
                  LOOP
               ENDIF  
               *** UPDATE CUSTOMER BALANCE TO REFLECT PAID AMOUNT    
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
               SEEK MBBUYCODE
               DO RECLOCK
               REPLACE CUS_BAL WITH CUS_BAL - ROUND(MTOT_PAID,2)
               UNLOCK
               USE
               *** NOW UPDATE RECORDS PAID
               I = 1
               DO WHILE I <= MSUB
                  SELECT B
                  GOTO MUPDRCD(I)
                  DO RECLOCK
                  REPLACE AMT_PAID WITH AMT_PAID + MPAYAMT(I)
                  UNLOCK
                  STORE SALESMAN TO MSALESMAN
                  STORE PO_NBR TO MPO_NBR
                  STORE PO_SUFFIX TO MPO_SUFFIX
                  STORE BUY_CODE TO MBUY_CODE
                  STORE BBUYCODE TO MBBUYCODE
                  STORE SHIP_DATE TO MSHIP_DATE
                  STORE INV_NBR TO MINV_NBR
                  STORE DEB_CRD TO MDEB_CRD
                  IF SUBSTR(MINV_NBR,1,1) = 'A'
                     MDEB_CRD = 'Y'
                  ENDIF
                  IF MPAYIND(I) <> ' '
                     SELECT F
                     DO FILELOCK
                     APPEND BLANK
                     REPLACE SALESMAN WITH MSALESMAN
                     REPLACE PO_NBR WITH MPO_NBR
                     REPLACE PO_SUFFIX WITH MPO_SUFFIX
                     REPLACE BBUYCODE WITH MBBUYCODE
                     IF DTOC(MPAID_DATE) = '  /  /  '
                        REPLACE PAID_DATE WITH DATE()
                     ELSE
                        REPLACE PAID_DATE WITH MPAID_DATE
                     ENDIF
                     REPLACE SYS_DATE WITH DATE()
                     REPLACE INV_NBR WITH MINV_NBR
                     REPLACE DEB_CRD WITH MDEB_CRD
                     REPLACE INV_DATE WITH MSHIP_DATE
                     REPLACE CK_NBR WITH MCK_NBR
                     IF MPROG_CODE = 2
                        REPLACE REASON WITH MREASON(I)
                     ELSE
                        REPLACE LOC_CODE WITH MLOC_CODE
                     ENDIF
                     *** PROCESSING A CREDIT IF PAYMENT AMOUNT LESS THAN ZERO
                     IF MPAYAMT(I) < 0
                        *** IF B->TOT_SELL + B->CUS_PALL < -1000
                        REPLACE AMT_PAID WITH MPAYAMT(I)
                        ***ELSE
                        ***REPLACE AMT_OVER WITH MPAYAMT(I)
                        ***ENDIF  
                     ELSE
                        IF MPAYIND(I) = 'P'
                           REPLACE  AMT_PAID WITH MPAYAMT(I)
                        ELSE
                           MOVER = MPAYAMT(I) - MPAY_DUE(I)
                           ******HERE- OR PUT CREDITS ON CUSTOMER ACCOUNT
                           IF MOVER >= 1000 .OR. MCRED_BAL = 'N' 
                              REPLACE AMT_PAID WITH MPAYAMT(I)
                           ELSE
                              REPLACE AMT_PAID WITH MPAYAMT(I) - MOVER      
                              *** NOTE: 16299 STARTS 01/01/90 INVOICES
                              ***IF VAL(MINV_NBR) < 16299 .AND. MPROG_CODE = 1
                              IF MPROG_CODE = 1
                                 REPLACE AMT_OVER WITH MOVER 
                              ELSE
                                 IF MOVER > 10
                                    REPLACE CRED_AMT WITH MOVER
                                 ELSE
                                    REPLACE AMT_OVER WITH MOVER
                                 ENDIF
                              ENDIF
                           ENDIF
                        ENDIF
                     ENDIF
                     UNLOCK
                  ENDIF
                  SELECT B
                  GOTO MUPDRCD(I)
                  IF MPAYIND(I) = 'F' .OR. MPAYIND(I) = 'X'
                     DO FILELOCK
                     REPLACE PAID_FLG WITH 'Y'       
                     UNLOCK
                     IF MDEB_CRD = ' '
                        SELECT E
                        SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
                        IF .NOT. EOF() .AND. INV_NBR = MINV_NBR
                           DO RECLOCK 
                           REPLACE PAID_FLG WITH 'Y'
                           UNLOCK
                        ENDIF
                     ENDIF
                     ** ONLY PUT OUT CREDITS FOR AMOUNTS > 10.00   (12/29/89)
                     IF MPAYAMT(I) > MPAY_DUE(I) + 10
                        SELECT B
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE SALESMAN   WITH MSALESMAN  
                        REPLACE PO_NBR     WITH MPO_NBR    
                        REPLACE PO_SUFFIX  WITH MPO_SUFFIX 
                        REPLACE BUY_CODE   WITH MBUY_CODE  
                        *** IF CUSTOMER RCD HAS FLAG SET THAT DOES NOT
                        *** WANT CREDITS IN THE CREDIT BALANCE ACCOUNT
                        *** (MCRED_BAL = 'N')
                        *** NOTE: 16299 STARTS 01/01/90 INVOICES
                        MCRED_SELL = MPAY_DUE(I) - MPAYAMT(I)   
                        **IF VAL(MINV_NBR) < 16299 .OR. MCRED_BAL = 'N' .OR. MCRED_SELL <= -1000
                        IF MCRED_BAL = 'N' .OR. MCRED_SELL <= -1000
                           REPLACE BBUYCODE   WITH MBBUYCODE  
                        ELSE
                           REPLACE ORIG_BBUY WITH MBBUYCODE
                           REPLACE BBUYCODE WITH 'CRED'
                        ENDIF
                        REPLACE SHIP_DATE  WITH MPAID_DATE   
                        REPLACE TOT_SELL   WITH MCRED_SELL                 
                        IF VAL(MINV_NBR) < 10000
                           REPLACE INV_NBR    WITH 'A' + SUBSTR(MINV_NBR,2)
                        ELSE
                           REPLACE INV_NBR WITH MINV_NBR
                        ENDIF
                        REPLACE DEB_CRD WITH 'Y'
                        REPLACE INV_DATE   WITH MPAID_DATE
                        REPLACE CRED_PAY WITH 'Y'
                        UNLOCK
                     ENDIF
                  ENDIF
                  
                  I = I + 1
               ENDDO
               FLUSH
               MNOT_DONE = .F.
               MEDIT = .F.
            ENDDO
         ENDDO
      ENDDO
      *SELECT B
      *UNLOCK
      CLOSE DATA
      
   CASE MSELECTION = '2'
      STORE DATE() TO MDATE     
      SELECT B
      DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
      SELECT A
      DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE, PAY_CUST, PAY_PO, PAY_SYS", .F.
      MTITLE = ' - ENTER MISCELLANEOUS PAYMENTS'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      MMORE = .T.
      DO WHILE  MMORE
         STORE 2 TO MACTION
         STORE SPACE(4) TO MACCOUNT 
         STORE 0 TO MAMOUNT
         STORE SPACE(2) TO MCOM_CODE
         STORE ' ' TO MLOC_CODE
         STORE SPACE(7) TO MLOCATION
         DO WHILE MACTION = 2
            
            IF MPROG_CODE = 1
               @ 6,4 SAY 'DEP. LOCATION: '
            ENDIF
            
            @ 8,5 SAY 'PAYMENT DATE: '
            @ 10,5 SAY '      AMOUNT: '
            @ 13,5 SAY ' ACCOUNT NBR: '
            
            IF MPROG_CODE = 1
               @ 6,19 GET MLOCATION PICTURE '@!'
            ENDIF
            
            @ 8,19 GET MDATE
            @ 10,19 GET MAMOUNT PICTURE '9999999.99'
            @ 11,5 SAY '(Note: Above amount can be negative.)'        
            @ 13,19 get MACCOUNT PICTURE '####'
            
            STORE 1 TO MACTION
            @ 24,0 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,12 SAY '1.Save/Return    2. Edit   3. Save/Add Another    4. Cancel'
            READ
            IF MACCOUNT = '7149' .OR. MACCOUNT = '7350'
               @ 15,5 SAY 'ENTER SALESPERSON CODE: ' GET MCOM_CODE PICTURE '##'
            ENDIF
            @ 24,09 GET MACTION PICTURE '9' RANGE 1,4
            READ
            IF MACTION = 1
               *IF MLOC_CODE <> 'Y' .AND. MLOC_CODE <> 'L'  .AND. MLOC_CODE <> 'B' .AND. MLOC_CODE <> 'G' .AND. MPROG_CODE = 1
               IF MLOCATION <> 'YUMA' .AND. MLOCATION <> 'LOCKBOX'  .AND. MLOCATION <> 'LOCAL' .AND. MPROG_CODE = 1
                  @ 24,0 CLEAR
                  MCONT = ' '
                  @ 24,0 SAY 'WARNING: DEPOSIT LOCATION INVALID - Press return ' get mcont
                  READ
                  @ 24,0 CLEAR
                  MACTION = 2
               ELSE
                  DO CASE
                  CASE MLOCATION = 'LOCKBOX'
                     MLOC_CODE = 'L'
                  CASE MLOCATION = 'LOCAL'
                     MLOC_CODE = 'B'
                  CASE MLOCATION = 'YUMA'
                     MLOC_CODE = 'Y'
                  OTHERWISE 
                     MLOC_CODE = ' '
                  ENDCASE
               ENDIF
            ENDIF
         ENDDO
         
         IF MACTION = 4
            MMORE = .F.
            LOOP
         ENDIF
         
         IF MAMOUNT <> 0
            SELECT B
            SEEK MACCOUNT
            IF EOF()
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT
               @ 24,1 SAY 'ACCOUNT NUMBER NOT ON FILE - PLEASE CHECK AND REENTER ' GET MWAIT
               READ
               LOOP
            ENDIF
            SELECT A
            DO FILELOCK
            APPEND BLANK
            REPLACE PAID_DATE WITH MDATE
            REPLACE SYS_DATE WITH MDATE
            **** REKO OR MFI ADVANCE REPAYMENTS
            IF MACCOUNT = '171' .OR. MACCOUNT = '161'
               REPLACE AMT_PAID WITH MAMOUNT
            ELSE
               REPLACE AMT_OVER WITH MAMOUNT
            ENDIF
            REPLACE ACCOUNT WITH MACCOUNT
            IF MACCOUNT = '7149' .OR. MACCOUNT = '7350'
               REPLACE SALESMAN WITH MCOM_CODE
            ENDIF
            IF MPROG_CODE = 1
               REPLACE LOC_CODE WITH MLOC_CODE
            ENDIF
            UNLOCK
         ELSE
            MMORE = .F.
         ENDIF
         IF MACTION = 1
            MMORE = .F.
         ENDIF
         
      ENDDO
      
   CASE MSELECTION = '3'
      STORE DATE() TO MDATE     
      SELECT C
      DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
      SELECT B
      DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE, PAY_CUST, PAY_PO, PAY_SYS", .F.
      MTITLE = ' - ENTER DUPLICATE CUSTOMER RECEIPTS'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      MMORE = .T.
      DO WHILE  MMORE
         MNAME_FD = .F.
         SAVE SCREEN TO MGRACE
         DO BBUYSEL3
         IF .NOT. MNAME_FD
            MMORE = .F.
            LOOP
         ENDIF
         RESTORE SCREEN FROM MGRACE
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
         STORE SPACE(7) TO MCK_NBR
         STORE 0 TO MINV_NBR
         STORE 0 TO MAMOUNT
         STORE ' ' TO MLOC_CODE
         STORE SPACE(7) TO MLOCATION
         DO WHILE MACTION = 2
            @ 4,5 SAY MNAME
            @ 5,5 SAY MSTREET
            @ 6,5 SAY TRIM(MCITY) + ', ' + MSTATE
            
            @ 8,5  SAY 'PAYMENT DATE: '
            @ 10,5 SAY 'CHECK NUMBER:'
            @ 12,5 SAY '      AMOUNT: '
            @ 14,5 SAY 'MIDWEST PO #: '
            @ 14,21 SAY '-'
            @ 14,26 SAY '-'
            @ 16,4 SAY 'MIDWEST INV #:'
            IF MPROG_CODE = 1
               @ 18,4 SAY 'DEP. LOCATION:'
            ENDIF
            
            @ 8,19 GET MDATE
            @ 10,19 GET MCK_NBR PICTURE '@!'
            @ 12,19 GET MAMOUNT PICTURE '99999.99'
            @ 14,19 get MSALESMAN PICTURE '##'
            @ 14,22 GET MPO_NBR PICTURE '####'
            @ 14,27 GET MPO_SUFFIX PICTURE '@!'
            @ 16,19 GET MINV_NBR PICTURE '#####'
            IF MPROG_CODE = 1
               @ 18,19 GET MLOCATION PICTURE '@!'
            ENDIF
            STORE 1 TO MACTION
            @ 24,0 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,12 SAY '1.Save/Return    2. Edit   3. Save/Add Another    4. Cancel'
            READ
            @24,09 GET MACTION PICTURE '9' RANGE 1,4
            READ
            IF MACTION = 1 .OR. MACTION = 3
               *IF MLOC_CODE <> 'Y' .AND. MLOC_CODE <> 'L'  .AND. MLOC_CODE <> 'B' .AND. MLOC_CODE <> 'G' .AND. MPROG_CODE = 1
               IF MLOCATION <> 'YUMA' .AND. MLOCATION <> 'LOCKBOX'  .AND. MLOCATION <> 'LOCAL' .AND. MPROG_CODE = 1
                  @ 24,0 CLEAR
                  MCONT = ' '
                  @ 24,0 SAY 'WARNING: DEPOSIT LOCATION INVALID - Press return ' get mcont
                  READ
                  @ 24,0 CLEAR
                  MACTION = 2
               ELSE
                  DO CASE
                  CASE MLOCATION = 'LOCKBOX'
                     MLOC_CODE = 'L'
                  CASE MLOCATION = 'LOCAL'
                     MLOC_CODE = 'B'
                  CASE MLOCATION = 'YUMA'
                     MLOC_CODE = 'Y'
                  OTHERWISE 
                     MLOC_CODE = ' '
                  ENDCASE
               ENDIF
               
            ENDIF
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
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE BBUYCODE WITH MBBUYCODE
            REPLACE PAID_DATE WITH MDATE
            REPLACE SYS_DATE WITH MDATE
            IF MPROG_CODE = 1
               REPLACE LOC_CODE WITH MLOC_CODE
            ENDIF
            ** CHG 4/16/92    
            *IF MAMOUNT > 1000
            REPLACE AMT_PAID WITH MAMOUNT    
            *ELSE
            *   REPLACE AMT_OVER WITH MAMOUNT
            *ENDIF
            REPLACE INV_NBR WITH MINV_NBR
            REPLACE INV_DATE WITH MDATE
            REPLACE CK_NBR WITH MCK_NBR
            UNLOCK
            SELECT C
            DO FILELOCK
            APPEND BLANK
            REPLACE salesman   WITH Msalesman  
            REPLACE po_nbr     WITH Mpo_nbr    
            REPLACE po_suffix  WITH Mpo_suffix 
            REPLACE bbuycode   WITH Mbbuycode  
            REPLACE ship_date  WITH MDATE   
            REPLACE tot_sell   WITH -1 * MAMOUNT
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
   CASE MSELECTION = '4'
      STORE 'B' TO MLOC_CODE
      STORE SPACE(7) TO MLOCATION
      MNAME_FD = .F.
      DO BBUYSEL3
      IF .NOT. MNAME_FD
         LOOP
      ENDIF
      STORE BBUYCODE TO MSVCODE  
      MTITLE = ' - VOID/DELETE CUSTOMER PAYMENTS'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      @ 04,1 SAY MNAME
      @ 5,1 SAY TRIM(STREET) + ',  ' + TRIM(CITY) + ',  ' + STATE
      @ 06,1 TO 06,78
      IF MPROG_CODE = 1
         MACTION = 2
         DO WHILE MACTION = 2
            *@ 7,1 SAY 'LOCATION CODE: '
            *@ 7,16 GET MLOCATION PICTURE '@!'
            STORE 1 TO MACTION
            @ 24,0 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,12 SAY '1. Continue   2. Edit   3. Cancel'
            READ
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ
            IF MACTION = 1
               **IF MLOC_CODE <> 'Y' .AND. MLOC_CODE <> 'L'  .AND. MLOC_CODE <> 'B' .AND. MLOC_CODE <> 'G'
               *IF MLOCATION <> 'YUMA' .AND. MLOCATION <> 'LOCKBOX'  .AND. MLOCATION <> 'LOCAL' .AND. MPROG_CODE = 1
               *   @ 24,0 CLEAR
               *   MCONT = ' '
               *   @ 24,0 SAY 'WARNING: DEPOSIT LOCATION INVALID - Press return ' get mcont
               *   READ
               *   @ 24,0 CLEAR
               *   MACTION = 2
               *ELSE
               *   DO CASE
               *   CASE MLOCATION = 'LOCKBOX'
               *      MLOC_CODE = 'L'
               *   CASE MLOCATION = 'LOCAL'
               *      MLOC_CODE = 'B'
               *   CASE MLOCATION = 'YUMA'
               *      MLOC_CODE = 'Y'
               *   OTHERWISE 
               *      MLOC_CODE = ' '
               *   ENDCASE
               *ENDIF
            ENDIF
         ENDDO
         IF MACTION = 3
            LOOP
         ENDIF
      ENDIF
      
      @ 07,1  SAY '   Sel    PO #    Inv.  Ship Dt   Cust PO Nbr    Amt Recvd  Paid Dt   Ck Nbr'
      SELECT C
      DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PO_SUP", .F.
      SELECT G
      DO FOX_USE WITH "PAYMENTS INDEX PAY_SYS, PAY_DATE, PAY_CUST, PAY_PO", .F.
      
      SEEK MSVCODE
      IF EOF()
         @ 4,1  CLEAR TO 21,78
         @ 10,5 SAY 'NO PAYMENTS ON FILE FROM THIS CUSTOMER'
         STORE ' ' TO MWAIT
         @ 12,5 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT 
         READ
         LOOP
      ENDIF
      STORE RECNO() TO MVWRECNO
      DO WHILE .NOT. EOF() .AND. BBUYCODE = MSVCODE
         STORE ' ' TO MSELECT, MUPDRCD
         SELECT G
         GOTO MVWRECNO
         MLINE = 08
         @ 08,1 CLEAR TO 22,78
         @ 24,0 CLEAR
         DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. BBUYCODE = MSVCODE
            I = MLINE - 7
            @ MLINE,1 SAY STR(I,2) + '.'
            IF SALESMAN <> SPACE(2)
               @ MLINE,8 SAY SALESMAN + '-'
            ENDIF
            @ MLINE,11 SAY PO_NBR
            IF PO_SUFFIX <> SPACE(1)
               @ MLINE,15 SAY '-' + PO_SUFFIX
            ENDIF
            @ MLINE,19 SAY INV_NBR
            SELECT B
            SEEK G->SALESMAN + G->PO_NBR + G->PO_SUFFIX
            IF .NOT. EOF()
               @ MLINE,25 SAY SHIP_DATE
               IF SUBSTR(BUYER_PO,13,1) = ' '
                  @ MLINE,35 SAY BUYER_PO
               else
                  @ MLINE,35 SAY substr(BUYER_PO,4,12)
               ENDIF
            ENDIF
            SELECT G
            STORE RECNO() TO MUPDRCD(I)
            @ MLINE,49 SAY  AMT_PAID + AMT_OVER + CRED_AMT PICTURE '999,999.99'
            @ MLINE,61 SAY PAID_DATE
            @ MLINE,71 SAY CK_NBR
            SKIP
            MLINE = MLINE + 1
         ENDDO
         MVW_MAX = MLINE - 1
         STORE RECNO() TO MVWRECNO
         IF .NOT. EOF() .AND. BBUYCODE = MSVCODE
            @ 23,70 SAY "More ...."
            MVWBLURP = .T.
         ELSE
            @ 24,70 TO 24,79
            MVWBLURP = .F.
         ENDIF
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         IF MVWBLURP
            @ 24,13 SAY '1. Continue/Next Page     2. Edit    3. Finished'    
         ELSE
            @ 24,13 SAY '1. Continue/Return     2. Edit     3. Finished'    
         ENDIF
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            MVWLINE = 8
            MVWI = 1
            SELECT B
            DO WHILE MVWLINE <= MVW_MAX
               @ MVWLINE,5 GET MSELECT(MVWI) PICTURE '@!'
               MVWLINE = MVWLINE + 1
               MVWI = MVWI + 1
            ENDDO
            READ
            STORE 1 TO MACTION
            @ 24,9 GET MACTION PICTURE '#' RANGE 1,3
            READ
         ENDDO
         
         MVWI = 1
         DO WHILE MVWI <= MVW_MAX
            IF MSELECT(MVWI) = 'X'
               ****** SET THIS PAYMENT BACK UP TO BE PAID AGAIN
               SELECT G
               GOTO MUPDRCD(MVWI)
               STORE INV_NBR TO MINV_NBR
               STORE SALESMAN TO MSALESMAN
               STORE PO_NBR TO MPO_NBR
               STORE PO_SUFFIX TO MPO_SUFFIX
               STORE BBUYCODE TO MBBUYCODE
               @ 4,50 SAY 'PO NUMBER: ' 
               IF MSALESMAN <>  '  '
                  @ 4,61 SAY MSALESMAN + '-'
               ENDIF
               @ 4,64 SAY MPO_NBR
               IF MPO_SUFFIX <> ' '
                  @ 4,68 SAY '-' + MPO_SUFFIX 
               ENDIF
               **STORE PAID_DATE TO MDATE
               STORE DATE() TO MDATE
               @ 5,50 SAY 'ENTER VOID DATE: ' 
               @ 5,67 GET MDATE
               READ
               @ 4,50 SAY SPACE(27)
               @ 5,50 SAY SPACE(27)
               SELECT B
               SEEK G->SALESMAN + G->PO_NBR + G->PO_SUFFIX
               STORE SHIP_DATE TO MSHIP_DATE
               STORE BUYER_PO TO MBUYER_PO
               STORE BUY_CODE TO MBUY_CODE
               
               SELECT A
               DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
               SEEK MBBUYCODE
               DO RECLOCK 
               REPLACE CUS_BAL WITH CUS_BAL + G->AMT_PAID+G->CRED_AMT+G->AMT_OVER
               UNLOCK
               USE
               
               ***** 07/23/93 SET UP TO BE PROCESSED NEW WAY
               ***** THIS IS THE NEW PROCESSING  *****
               SELECT C
               DO FILELOCK
               APPEND BLANK
               REPLACE SALESMAN   WITH MSALESMAN  
               REPLACE PO_NBR     WITH MPO_NBR    
               REPLACE PO_SUFFIX  WITH MPO_SUFFIX 
               REPLACE BBUYCODE   WITH MBBUYCODE  
               REPLACE BUY_CODE   WITH MBUY_CODE
               REPLACE BUYER_PO   WITH MBUYER_PO  
               REPLACE SHIP_DATE  WITH MSHIP_DATE 
               REPLACE INV_NBR    WITH MINV_NBR
               REPLACE DEB_CRD    WITH 'Y'
               REPLACE INV_DATE   WITH DATE()       
               REPLACE TOT_SELL   WITH G->AMT_PAID
               UNLOCK
               
               IF G->CRED_AMT <> 0
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE SALESMAN   WITH MSALESMAN  
                  REPLACE PO_NBR     WITH MPO_NBR    
                  REPLACE PO_SUFFIX  WITH MPO_SUFFIX 
                  REPLACE BBUYCODE   WITH 'CRED'     
                  REPLACE ORIG_BBUY  WITH MBBUYCODE  
                  REPLACE BUY_CODE   WITH MBUY_CODE
                  REPLACE BUYER_PO   WITH MBUYER_PO  
                  REPLACE SHIP_DATE  WITH MSHIP_DATE 
                  REPLACE INV_NBR    WITH MINV_NBR
                  REPLACE DEB_CRD    WITH 'Y'
                  REPLACE INV_DATE   WITH DATE()       
                  REPLACE TOT_SELL   WITH G->CRED_AMT      
                  UNLOCK
               ENDIF
               
               SELECT G
               IF MDATE <> PAID_DATE .OR. POST_FLG <> ' '
                  STORE INV_NBR TO MINV_NBR
                  STORE INV_DATE TO MINV_DATE
                  STORE SALESMAN TO MSALESMAN
                  STORE PO_NBR TO MPO_NBR
                  STORE PO_SUFFIX TO MPO_SUFFIX
                  STORE AMT_PAID TO MAMT_PAID
                  STORE AMT_OVER TO MAMT_OVER
                  STORE CRED_AMT TO MCRED_AMT
                  STORE BBUYCODE TO MBBUYCODE
                  STORE CK_NBR TO MCK_NBR
                  STORE ACCOUNT TO MACCOUNT
                  STORE DEB_CRD TO MDEB_CRD
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE INV_NBR WITH MINV_NBR
                  REPLACE INV_DATE WITH MINV_DATE
                  REPLACE SALESMAN WITH MSALESMAN
                  REPLACE PO_NBR WITH MPO_NBR
                  REPLACE PO_SUFFIX WITH MPO_SUFFIX
                  REPLACE AMT_PAID WITH -1 * MAMT_PAID
                  REPLACE AMT_OVER WITH -1 * MAMT_OVER
                  REPLACE CRED_AMT WITH -1 * MCRED_AMT
                  REPLACE BBUYCODE WITH MBBUYCODE
                  REPLACE CK_NBR WITH MCK_NBR
                  REPLACE ACCOUNT WITH MACCOUNT
                  REPLACE DEB_CRD WITH MDEB_CRD
                  REPLACE PAID_DATE WITH MDATE
                  REPLACE SYS_DATE WITH DATE()
                  IF MPROG_CODE = 1
                     REPLACE LOC_CODE WITH MLOC_CODE
                  ENDIF
                  UNLOCK
               ELSE
                  DO FILELOCK
                  DELETE
                  UNLOCK
               ENDIF
            ENDIF
            MVWI = MVWI + 1
         ENDDO
         
         IF MACTION = 3 
            SELECT G
            GOTO BOTTOM
            SKIP
            LOOP
         ENDIF
         
         IF .NOT. MVWBLURP .AND. MACTION = 1
            SELECT G
            GOTO BOTTOM
            SKIP
            LOOP
         ENDIF
         SELECT G
         GOTO MVWRECNO
      ENDDO
      ***RELEASE MUPDRCD, MSELECT
   CASE MSELECTION = '5'
      STORE DATE() TO MDATE     
      SELECT B
      DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE, PAY_CUST, PAY_PO, PAY_SYS", .F.
      MTITLE = ' - ENTER A/P CROSSOVER RECEIPTS FROM SUPPLIER/FREIGHT'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      STORE ' ' TO MCHOICE
      DO WHILE MCHOICE <> 'S' .AND. MCHOICE <> 'F' .AND. MCHOICE <> 'Q'
         @ 10,5 SAY 'IS RECIEPT FROM SUPPLIER OR FREIGHT (S/F)? ' GET MCHOICE PICTURE '@!'
         @ 12,5 SAY '(Enter an "Q" if you wish to quit and return to menu)'
         READ
         IF MCHOICE <> 'S' .AND. MCHOICE <> 'F' .AND. MCHOICE <> 'Q'
            @ 25,0 CLEAR
            STORE ' ' TO MWAIT
            @ 25,1 SAY 'YOU MUST ENTER A "S" OR "F" OR "Q" - PRESS RETURN TO REENTER ' GET MWAIT
            READ
            @ 25,0 CLEAR
         ENDIF
      ENDDO
      IF MCHOICE = 'Q'
         CLOSE DATA
         LOOP
      ENDIF
      MMORE = .T.
      MLOC_CODE = ' '
      MLOCATION = SPACE(7)
      DO WHILE  MMORE
         STORE SPACE(4) TO MCODE
         DO CASE   
         CASE MCHOICE = 'S'
            MNAME_FD = .F.
            DO RSUPSEL3
            IF .NOT. MNAME_FD
               MMORE = .F.
               LOOP
            ENDIF
            STORE NAME TO MNAME
            STORE RSUPCODE TO MCODE
            STORE STREET TO MSTREET
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            STORE ZIP TO MZIP
         CASE MCHOICE = 'F'
            MNAME_FD = .F.
            DO FRT_SEL1 
            IF .NOT. MNAME_FD
               MMORE = .F.
               LOOP
            ENDIF
            STORE NAME TO MNAME
            STORE FRT_CODE TO MCODE    
            STORE STREET TO MSTREET
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            STORE ZIP TO MZIP
         ENDCASE
         STORE 2 TO MACTION
         STORE SPACE(2) TO MSALESMAN
         STORE SPACE(4) TO MPO_NBR
         STORE SPACE(1) TO MPO_SUFFIX
         STORE SPACE(7) TO MCK_NBR
         STORE 0 TO MINV_NBR
         STORE 0 TO MAMOUNT
         @ 4,1 CLEAR TO 23,78
         DO WHILE MACTION = 2
            @ 4,5 SAY MNAME
            @ 5,5 SAY MSTREET
            @ 6,5 SAY TRIM(MCITY) + ', ' + MSTATE
            @ 8,5  SAY 'PAYMENT DATE: '
            @ 10,5 SAY 'CHECK NUMBER:'
            @ 12,5 SAY '      AMOUNT: '
            @ 14,5 SAY 'MIDWEST PO #: '
            @ 14,21 SAY '-'
            @ 14,26 SAY '-'
            @ 16,4 SAY 'MIDWEST INV #:'
            IF MPROG_CODE = 1
               @ 18,4 SAY 'DEP. LOCATION:'
            ENDIF
            @ 8,19 GET MDATE
            @ 10,10 GET MCK_NBR PICTURE '@!'
            @ 12,19 GET MAMOUNT PICTURE '99999.99'
            @ 14,19 get MSALESMAN PICTURE '##'
            @ 14,22 GET MPO_NBR PICTURE '####'
            @ 14,27 GET MPO_SUFFIX PICTURE '@!'
            @ 16,19 GET MINV_NBR PICTURE '#####'
            IF MPROG_CODE = 1
               @ 18,19 GET MLOCATION PICTURE '@!'
            ENDIF
            STORE 1 TO MACTION
            @ 25,0 CLEAR
            @ 25,01 SAY 'Action: ' + STR(MACTION,1)
            @ 25,12 SAY '1.Save/Return    2. Edit   3. Save/Add Another    4. Cancel'
            READ
            @25,09 GET MACTION PICTURE '9' RANGE 1,4
            READ
            IF MACTION = 1 .OR. MACTION = 3
               *IF MLOC_CODE <> 'Y' .AND. MLOC_CODE <> 'L'  .AND. MLOC_CODE <> 'B' .AND. MLOC_CODE <> 'G' .AND. MPROG_CODE = 1
               IF MLOCATION <> 'YUMA' .AND. MLOCATION <> 'LOCKBOX'  .AND. MLOCATION <> 'LOCAL' .AND. MPROG_CODE = 1
                  @ 25,0 CLEAR
                  MCONT = ' '
                  @ 25,0 SAY 'WARNING: DEPOSIT LOCATION INVALID - Press return ' get mcont
                  READ
                  @ 25,0 CLEAR
                  MACTION = 2
               ELSE
                  DO CASE
                  CASE MLOCATION = 'LOCKBOX'
                     MLOC_CODE = 'L'
                  CASE MLOCATION = 'LOCAL'
                     MLOC_CODE = 'B'
                  CASE MLOCATION = 'YUMA'
                     MLOC_CODE = 'Y'
                  OTHERWISE 
                     MLOC_CODE = ' '
                  ENDCASE
               ENDIF
            ENDIF
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
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE BBUYCODE WITH MCODE    
            REPLACE PAID_DATE WITH MDATE
            REPLACE SYS_DATE WITH MDATE
            IF MPROG_CODE = 1
               REPLACE LOC_CODE WITH MLOC_CODE
            ENDIF
            REPLACE INV_DATE WITH MDATE
            REPLACE INV_NBR WITH MINV_NBR
            REPLACE CK_NBR WITH MCK_NBR
            **** AMOUNT PAID GOES INTO THE MISCELLANEOUS INCOME COLUMN
            **** THIS WILL BE POSTED TO THE SUPPLIER OR FREIGHT LEDGER
            REPLACE AMT_OVER WITH MAMOUNT
            IF MCHOICE = 'S'
               REPLACE ACCOUNT WITH '151 '
            ELSE
               REPLACE ACCOUNT WITH '152 '
            ENDIF
            UNLOCK
            ***** PUT THIS A/P CROSSOVER RECEIPT ON THE 
            ***** SUPPLIER APPROVAL SCREEN OR THE FREIGHT APPROVAL SCREEN
            
            IF MCHOICE = 'S'
               SELECT C
               DO FOX_USE WITH "DISBJRN INDEX DISB_PO", .F.
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + 'S'
               IF .NOT. EOF()
                  STORE BILL_INV TO MSUP_INV
               ELSE
                  STORE SPACE(12) TO MSUP_INV
               ENDIF
               DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
               DO FILELOCK
               APPEND BLANK
               REPLACE RSUPCODE WITH MCODE    
               REPLACE DUE_DATE WITH DATE()
               UNLOCK
               DO RECLOCK
               REPLACE SALESMAN WITH MSALESMAN
               REPLACE PO_NBR WITH MPO_NBR
               REPLACE PO_SUFFIX WITH MPO_SUFFIX
               REPLACE INV_NBR WITH MINV_NBR
               REPLACE AMT_DUE WITH MAMOUNT
               REPLACE REASON WITH 'A/P RECEIPT'
               REPLACE SUP_INV WITH MSUP_INV
               REPLACE DEB_CRD WITH 'Y'
               UNLOCK
            ELSE
               SELECT C
               DO FOX_USE WITH "DISBJRN INDEX DISB_PO", .F.
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + 'F'
               IF .NOT. EOF()
                  STORE BILL_INV TO MFRT_INV
               ELSE
                  STORE SPACE(12) TO MFRT_INV
               ENDIF
               DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
               DO FILELOCK
               APPEND BLANK
               REPLACE FRT_CODE WITH MCODE    
               REPLACE DUE_DATE WITH DATE()
               UNLOCK
               DO RECLOCK
               REPLACE SALESMAN WITH MSALESMAN
               REPLACE PO_NBR WITH MPO_NBR
               REPLACE PO_SUFFIX WITH MPO_SUFFIX
               REPLACE INV_NBR WITH MINV_NBR
               REPLACE AMT_DUE WITH MAMOUNT
               REPLACE REASON WITH 'A/P RECEIPT'
               REPLACE FRT_INV WITH MFRT_INV
               REPLACE DEB_CRD WITH 'Y'
               UNLOCK
            ENDIF
         ELSE
            MMORE = .F.
            LOOP
         ENDIF
         IF MACTION = 1
            MMORE = .F.
         ENDIF
      ENDDO
   CASE MSELECTION = '6'
      STORE DATE() TO MDATE     
      MTITLE = ' - MOVE MISCELLANEOUS RECIEPT TO RECEIVABLES'
      MMORE = .T.
      STORE DATE() TO MDATE      
      STORE 'N' TO MYES_NO
      MLOC_CODE = ' '
      MLOCATION = SPACE(7)
      DO WHILE  MMORE
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         STORE SPACE(4) TO MPO_NBR
         STORE SPACE(2) TO MSALESMAN
         STORE ' ' TO MPO_SUFFIX
         STORE 0 TO MINV_NBR
         IF MYES_NO = 'N'
            @ 10,5 SAY 'Is Purchase Order on File (Y/N)? ' get myes_no picture '@!'
            READ
            @ 10,1 SAY SPACE(78)
         ENDIF
         IF MYES_NO = 'Y'
            SELECT D
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
            SELECT C
            DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
            SELECT B
            DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE, PAY_CUST, PAY_PO, PAY_SYS", .F.
            @ 12,5 SAY '           PO NUMBER: '
            @ 12,29 SAY '-'
            @ 12,34 SAY '-'
            @ 12,27 GET MSALESMAN PICTURE '##'
            @ 12,30 GET MPO_NBR PICTURE '####'
            @ 12,35 GET MPO_SUFFIX PICTURE '@!'           
            @ 14,5 SAY '      INVOICE NUMBER: '
            @ 14,27 GET MINV_NBR PICTURE '#####'
            READ
            IF MSALESMAN = SPACE(2) .AND. MPO_NBR = SPACE(4) .AND. MPO_SUFFIX = SPACE(1)
               MMORE = .F.
               LOOP
            ENDIF
            SELECT C
            SEEK MSALESMAN+MPO_NBR+MPO_SUFFIX
            IF EOF()
               @ 25,0 CLEAR
               STORE ' ' TO MWAIT
               @ 25,0 SAY 'PURCHASE ORDER NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
               LOOP
            ELSE
               SELECT D
               SEEK C->BBUYCODE
               IF EOF()
                  STORE 'CUST. NOT ON FILE' TO MNAME
                  STORE SPACE(20) TO MSTREET, MCITY
                  STORE SPACE(2) TO MSTATE, MZIP
                  STORE A->BBUYCODE TO MBBUYCODE
               ELSE
                  STORE NAME TO MNAME
                  STORE BBUYCODE TO MBBUYCODE
                  STORE STREET TO MSTREET
                  STORE CITY TO MCITY
                  STORE STATE TO MSTATE
                  STORE ZIP TO MZIP
               ENDIF
            ENDIF
         ELSE
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
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 to 24,79
            USE
            SELECT D
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
            SELECT C
            DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
            SELECT B
            DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE, PAY_CUST, PAY_PO, PAY_SYS", .F.
         ENDIF
         @ 4,5 SAY MNAME
         @ 5,5 SAY MSTREET
         @ 6,5 SAY TRIM(MCITY) + ', ' + MSTATE
         STORE 2 TO MACTION
         STORE 0 TO MRECV_AMT, MMISC_AMT, MCRED_AMT 
         DO WHILE MACTION = 2
            
            @ 8,5  SAY '    TRANSACTION DATE: '
            IF MPROG_CODE = 1
               @ 9,5 SAY '        DEP. LOCATION: '
            ENDIF
            @ 10,5 SAY '   RECEIVABLE AMOUNT: '
            @ 11,5 SAY 'MISCELLANEOUS AMOUNT: '
            @ 12,4 say 'CREDIT BALANCE AMOUNT: '
            @ 8,27 GET MDATE
            IF MPROG_CODE = 1
               @ 9,27 GET MLOCATION PICTURE '@!'
            ENDIF
            @ 10,27 GET MRECV_AMT PICTURE '######.##'
            @ 11,27 GET MMISC_AMT PICTURE '######.##'
            @ 12,27 GET MCRED_AMT PICTURE '######.##'
            IF MYES_NO <> 'Y'
               @ 13,5 SAY '           PO NUMBER: '
               @ 13,29 SAY '-'
               @ 13,34 SAY '-'
               @ 13,27 GET MSALESMAN PICTURE '##'
               @ 13,30 GET MPO_NBR PICTURE '####'
               @ 13,35 GET MPO_SUFFIX PICTURE '@!'
               @ 15,5 SAY '      INVOICE NUMBER: '
               @ 15,27 GET MINV_NBR PICTURE '#####'
            ENDIF
            @ 18,3 SAY 'IMPORTANT: PLEASE VERIFY INFORMATION ENTERED VERY CAREFULLY BEFORE SAVING !'
            @ 20,5 SAY 'Enter Negative Amount in Appropriate Column.'
            STORE 1 TO MACTION
            @ 25,0 CLEAR
            @ 25,01 SAY 'Action: ' + STR(MACTION,1)
            @ 25,12 SAY '1.Save/Add Another    2. Edit   3. Save/Return    4. Cancel'
            READ
            @25,09 GET MACTION PICTURE '9' RANGE 1,4
            READ
            IF MACTION = 1 .OR. MACTION = 3
               *IF MRECV_AMT + MMISC_AMT + MCRED_AMT <> 0
               *   @ 24,0 CLEAR
               *   STORE 'ERROR IN ENTRY - AMOUNTS MUST TOTAL ZERO - PRESS RETURN TO REENTER'  TO MERROR
               *   @ 24,1 GET MERROR
               *   READ
               *   MACTION = 2
               *ENDIF
               *IF MLOC_CODE <> 'Y' .AND. MLOC_CODE <> 'L'  .AND. MLOC_CODE <> 'B' .AND. MLOC_CODE <> 'G' .AND. MPROG_CODE = 1
               IF MLOCATION <> 'YUMA' .AND. MLOCATION <> 'LOCKBOX'  .AND. MLOCATION <> 'LOCAL' .AND. MPROG_CODE = 1
                  @ 25,0 CLEAR
                  MCONT = ' '
                  @ 25,0 SAY 'WARNING: DEPOSIT LOCATION INVALID - Press return ' get mcont
                  READ
                  @ 25,0 CLEAR
                  MACTION = 2
               ELSE
                  DO CASE
                  CASE MLOCATION = 'LOCKBOX'
                     MLOC_CODE = 'L'
                  CASE MLOCATION = 'LOCAL'
                     MLOC_CODE = 'B'
                  CASE MLOCATION = 'YUMA'
                     MLOC_CODE = 'Y'
                  OTHERWISE 
                     MLOC_CODE = ' '
                  ENDCASE
               ENDIF
            ENDIF
         ENDDO
         
         IF MACTION = 4
            MMORE = .F.
            LOOP
         ENDIF
         IF MACTION = 1 .OR. MACTION = 3
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE BBUYCODE WITH MBBUYCODE
            REPLACE PAID_DATE WITH MDATE
            REPLACE SYS_DATE WITH MDATE
            REPLACE AMT_PAID WITH MRECV_AMT
            REPLACE AMT_OVER WITH MMISC_AMT    
            REPLACE CRED_AMT WITH MCRED_AMT
            REPLACE INV_DATE WITH MDATE
            REPLACE INV_NBR WITH STR(MINV_NBR,5)
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            IF MPROG_CODE = 1
               REPLACE LOC_CODE WITH MLOC_CODE
            ENDIF
            UNLOCK
         ELSE
            MMORE = .F.
            LOOP
         ENDIF
         IF MACTION = 3
            MMORE = .F.
         ENDIF
         
      ENDDO
   CASE MSELECTION = '7'
      
      STORE DATE() TO MPAID_DATE
      MNEXT_CUST = .T.
      SELECT D
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      
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
         STORE 'YES' TO MYES_NO
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 10,5 SAY 'Do you want to select a specific customer (YES/NO)? ' get myes_no picture '@!' 
            STORE 1 TO MACTION
            @ 25,01 SAY 'Action: ' + STR(MACTION,1)
            @ 25,13 SAY '1. Continue      2. Edit      3. Cancel'    
            READ
            @ 25,09 GET MACTION PICTURE '#' RANGE 1,3
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
         @ 3,0 to 25,79
         IF MOPT_BBUY <> SPACE(4)
            @ 04,1  SAY 'Customer:'
            @ 04,11 say mname
            @ 05,11 SAY TRIM(MCITY) + ', ' + MSTATE
         ELSE
            @ 4,1 SAY 'No Customer Selected'
         ENDIF
         @ 06,1 to 06,78 
         @ 06,1 say 'OUTSTANDING CREDITS'
         *** ' ' = UNPAID
         *** 'CRED' CREDIT BALANCE ACCOUNT CODE
         SELECT C
         SEEK 'CRED ' 
         IF EOF()
            @ 14,1 SAY 'THERE ARE NO OUTSTANDING CREDITS ON FILE  '
            @ 16,1 SAY 'PLEASE SELECT AGAIN'       
            @ 17,1 SAY ' '
            WAIT 'PRESS RETURN TO CONTINUE'
            LOOP
         ELSE
            IF MOPT_BBUY <> SPACE(4)
               MNOT_FOUND = .T.
               DO WHILE .NOT. EOF() .AND. PAID_FLG = ' ' .AND. BBUYCODE = 'CRED' .AND. MNOT_FOUND
                  IF ORIG_BBUY = MOPT_BBUY
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
         ENDIF
         STORE RECNO() TO MRECNO, MFST_REC   
         STORE 0 TO MUPDRCD, MPAYIND, MPAYAMT
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         
         MSUB = 0
         MTOT_PAID = 0
         SELECT C
         
         MNOT_DONE = .T.
         DO WHILE MNOT_DONE
            STORE 0 TO MREC, MPD_AMT, MAMT, MSHRT, MDUE
            STORE ' ' TO MCK, MSW
            GOTO MRECNO
            MFST_REC = MRECNO
            MLINE = 7
            @ 07,1 CLEAR TO 22,78
            @ 24,0 CLEAR
            DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. BBUYCODE = 'CRED' .AND. PAID_FLG = ' '
               IF MOPT_BBUY <> SPACE(4)
                  IF MOPT_BBUY <> ORIG_BBUY
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               SELECT A
               SEEK C->ORIG_BBUY
               IF EOF()
                  STORE 'CUSTOMER NOT ON FILE' TO MNAME
               ELSE
                  STORE NAME TO MNAME
               ENDIF
               SELECT C
               STORE INV_NBR TO MINV_NBR
               STORE SALESMAN TO MSALESMAN
               STORE PO_NBR TO MPO_NBR
               STORE PO_SUFFIX TO MPO_SUFFIX
               I = MLINE - 6 
               STORE I TO MI
               STORE RECNO() TO MREC(MI)
               MAMT(MI) = TOT_SELL                                   
               MDUE(MI) = TOT_SELL - AMT_PAID
               @ MLINE,1 SAY STR(MI,2) + '.'
               @ MLINE,5 SAY SUBSTR(MNAME,1,14)
               *@ mline,22  say INV_NBR 
               @ MLINE,21 SAY MSALESMAN
               IF MSALESMAN <> '  '
                  @ MLINE,23 SAY  '-'
               ENDIF
               @ MLINE,24 SAY MPO_NBR
               IF MPO_SUFFIX <> ' '
                  @ MLINE,28 SAY '-'
                  @ MLINE,29 SAY MPO_SUFFIX
               ENDIF
               @ MLINE,31 SAY SUBSTR(DTOC(INV_DATE),1,6)
               @ mline,37 say substr(dtoc(inv_date),9)
               **@ mline,29 say INV_DATE
               @ mline,39 SAY MDUE(MI) picture '999,999.99'
               IF CRED_REAS <> ' '      
                  SELECT D
                  SEEK 'M' + C->CRED_REAS
                  MCRED_REAS(MI) = SUBSTR(DESC,1,13)
                  @ MLINE,66 SAY MCRED_REAS(MI)
                  SELECT C
               ELSE
                  MCRED_REAS(MI) = SPACE(13)
               ENDIF
               SKIP
               MLINE = MLINE + 1
            ENDDO
            MMAX_LINE = MLINE - 1
            STORE RECNO() TO MRECNO      
            IF .NOT. EOF() .AND. BBUYCODE = 'CRED' .AND. PAID_FLG = ' '
               IF MOPT_BBUY <> SPACE(4)
                  DO WHILE .NOT. EOF() .AND. BBUYCODE = 'CRED' .AND. PAID_FLG = ' ' .AND. MOPT_BBUY <> ORIG_BBUY
                     SKIP
                  ENDDO
                  IF MOPT_BBUY = ORIG_BBUY
                     @ 23,70 SAY 'More Inv.'
                     STORE RECNO() TO MRECNO      
                     MBLURP = .T.
                  ELSE
                     @ 24,70 TO 24,79
                     MBLURP = .F.
                  ENDIF
               ELSE
                  @ 23,70 SAY 'More Inv.'
                  STORE RECNO() TO MRECNO      
                  MBLURP = .T.
               ENDIF
            ELSE
               @ 24,70 TO 24,79
               MBLURP = .F.
            ENDIF
            
            MLINE = 7 
            I = 1
            DO WHILE MLINE <= MMAX_LINE
               STORE I TO MI
               @ MLINE,51 GET MCK(MI) PICTURE '@!'
               @ MLINE,54 GET MPD_AMT(MI) PICTURE '999,999.99'
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
            MERR = .F.
            DO WHILE I <= 16
               STORE I TO MI
               IF MCK(MI) <> ' ' .AND. MCK(MI) <> 'P' .AND. MCK(MI) <> 'X' .AND. MCK(MI) <> 'F'  .AND. MCK(MI) <> 'R'
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  MERR = .T.
                  MRECNO = MFST_REC
                  MERR_LINE = I       
                  MERR_LINE = STR(MERR_LINE,2)
                  @ 24,0 SAY 'CREDIT INDICATOR ON LINE ' + MERR_LINE + ' INVALID - PRESS RETURN TO REENTER ' GET MWAIT
                  READ
                  MCK(MI) = ' '
                  I = I + 1
                  LOOP
               ENDIF
               IF MCK(MI) = 'P' .AND. MPD_AMT(MI) = 0
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  MERR = .T.
                  MRECNO = MFST_REC
                  MERR_LINE = I      
                  MERR_LINE = STR(MERR_LINE,2)
                  @ 24,0 SAY 'PARTIAL CREDIT ON LINE ' + MERR_LINE + ' BUT NO AMOUNT ENTERED - PRESS RETURN TO REENTER' GET MWAIT
                  READ
                  MCK(MI) = ' '
                  I = I + 1
                  LOOP
               ENDIF
               
               IF MCK(MI) = 'P' .AND. MPD_AMT(MI) > 0
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  MERR = .T.
                  MRECNO = MFST_REC
                  MERR_LINE = I      
                  MERR_LINE = STR(MERR_LINE,2)
                  @ 24,0 SAY 'MUST ENTER A NEGATIVE NUMBER FOR PARTIAL ON LINE ' + MERR_LINE + ' - PRESS RETURN TO REENTER' GET MWAIT
                  READ
                  MCK(MI) = ' '
                  I = I + 1
                  LOOP
               ENDIF
               
               IF MCK(MI) = 'P' .AND. MDUE(MI) > 0 .AND. MPD_AMT(MI) < MDUE(MI)
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  MERR = .T.
                  MRECNO = MFST_REC
                  MERR_LINE = I      
                  MERR_LINE = STR(MERR_LINE,2)
                  @ 24,0 SAY 'CREDIT AMT ENTERED MORE THAN CREDIT AMOUNT LEFT ON LINE '+ MERR_LINE + ' ' GET MWAIT 
                  READ
                  MCK(MI) = ' '
                  I = I + 1
                  LOOP
               ENDIF
               
               IF MCK(MI) = 'R'
                  MTHIS_LINE = .T.
                  DO WHILE MTHIS_LINE
                     @ I+6,66 GET MCRED_REAS(MI) PICTURE '@!'
                     READ 
                     IF SUBSTR(MCRED_REAS(MI),1,1) = ' '
                        MCRED_REAS(MI) = SPACE(13)                    
                        @ I+6,66 SAY MCRED_REAS(MI) PICTURE '@!'
                        MTHIS_LINE = .F.
                        SELECT C
                        GOTO MREC(MI)
                        DO RECLOCK
                        REPLACE CRED_REAS WITH SUBSTR(MCRED_REAS(MI),1,1)
                        UNLOCK
                     ELSE
                        SELECT D
                        SEEK 'M' + SUBSTR(MCRED_REAS(MI),1,1)
                        IF EOF()
                           MWAIT = ' '    
                           @ 24,0 SAY 'INVALID CREDIT REASON CODE ENTERED ' GET MWAIT 
                           READ
                           SELECT C
                           LOOP
                        ELSE
                           STORE SUBSTR(DESC,1,13) TO MCRED_REAS(MI)
                           @ I+6,66 SAY MCRED_REAS(MI) PICTURE '@!'
                           MTHIS_LINE = .F.
                           SELECT C
                           GOTO MREC(MI)
                           DO RECLOCK
                           REPLACE CRED_REAS WITH SUBSTR(MCRED_REAS(MI),1,1)
                           UNLOCK
                        ENDIF
                     ENDIF
                  ENDDO
                  MCK(MI) = ' '
               ENDIF
               
               I = I + 1
            ENDDO
            IF MERR
               LOOP
            ENDIF
            MLINE = 7 
            I = 1
            MPG_PAID = 0
            DO WHILE I <= 11
               IF MCK(I) = ' '
                  I = I + 1
                  MLINE = MLINE + 1
                  LOOP
               ENDIF
               IF (MCK(I) = 'X' .OR. MCK(I) = 'F') .AND. MPD_AMT(I) = 0
                  @ I+6,66 GET  MDUE(I) PICTURE '999,999.99'
                  CLEAR GETS
                  MPG_PAID = MPG_PAID + MDUE(I)
               ELSE
                  MPG_PAID = MPG_PAID + MPD_AMT(I)
               ENDIF
               I = I + 1
            ENDDO
            @ 4,50 SAY 'Total Credits Selected'
            @ 5,57 SAY MPG_PAID + MTOT_PAID PICTURE '999,999.99'
            
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
                  LOOP
               ENDIF
            ELSE
               IF MACTION = 3
                  MNOT_DONE = .F.
                  LOOP
               ENDIF
            ENDIF
            
            I = 1 
            DO WHILE I <= 16
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
               SELECT C
               GOTO MUPDRCD(I)
               DO RECLOCK
               REPLACE AMT_PAID WITH AMT_PAID + MPAYAMT(I)
               UNLOCK
               IF TOT_SELL = AMT_PAID
                  DO FILELOCK
                  REPLACE PAID_FLG WITH 'Y'
                  UNLOCK
               ENDIF
               STORE SALESMAN TO MSALESMAN
               STORE PO_NBR TO MPO_NBR
               STORE PO_SUFFIX TO MPO_SUFFIX
               STORE BBUYCODE TO MBBUYCODE
               STORE ORIG_BBUY TO MORIG_BBUY
               STORE SHIP_DATE TO MTRAN_DATE
               STORE BBUYCODE TO MBBUYCODE
               STORE ORIG_BBUY TO MORIG_BBUY
               STORE SHIP_DATE TO MTRAN_DATE
               STORE INV_NBR TO MINV_NBR
               MDEB_CRD = 'Y'
               *************************************
               ** RECEIPTS FILE  (PAYMENTS FILE)  ** 
               *************************************
               SELECT B
               DO FILELOCK
               ****** THIS IS FOR CREDIT BALANCE ACCOUNT
               APPEND BLANK
               REPLACE SALESMAN WITH MSALESMAN
               REPLACE PO_NBR WITH MPO_NBR
               REPLACE PO_SUFFIX WITH MPO_SUFFIX
               REPLACE INV_NBR WITH MINV_NBR
               REPLACE BBUYCODE WITH C->ORIG_BBUY
               REPLACE PAID_DATE WITH MPAID_DATE
               REPLACE SYS_DATE WITH DATE()
               REPLACE DEB_CRD WITH MDEB_CRD
               REPLACE INV_DATE WITH MTRAN_DATE
               REPLACE CRED_AMT WITH MPAYAMT(I)
               
               ***** THIS IS FOR CUSTOMER ACCOUNT      
               APPEND BLANK
               REPLACE SALESMAN WITH MSALESMAN
               REPLACE PO_NBR WITH MPO_NBR
               REPLACE PO_SUFFIX WITH MPO_SUFFIX
               REPLACE INV_NBR WITH MINV_NBR
               REPLACE BBUYCODE WITH C->ORIG_BBUY
               REPLACE PAID_DATE WITH MPAID_DATE
               REPLACE SYS_DATE WITH DATE()
               REPLACE DEB_CRD WITH MDEB_CRD
               REPLACE INV_DATE WITH MTRAN_DATE
               *** CHANGED 01/02/91
               *** REPLACE AMT_OVER WITH (-1) * MPAYAMT(I)
               REPLACE AMT_PAID WITH (-1) * MPAYAMT(I)
               UNLOCK
               
               ***** MAKE AN ENTRY ON CUSTOMER PAYMENT FILE ****
               ***** CUS_INV FILE FOR THE NEW CREDIT AMOUNT
               
               SELECT C
               DO FILELOCK 
               APPEND BLANK
               REPLACE SALESMAN   WITH MSALESMAN  
               REPLACE PO_NBR     WITH MPO_NBR    
               REPLACE PO_SUFFIX  WITH MPO_SUFFIX 
               REPLACE INV_NBR    WITH MINV_NBR
               REPLACE BBUYCODE   WITH MORIG_BBUY
               REPLACE TOT_SELL   WITH MPAYAMT(I)                  
               REPLACE DEB_CRD    WITH 'Y'
               REPLACE SHIP_DATE  WITH MTRAN_DATE   
               REPLACE INV_DATE   WITH MTRAN_DATE
               REPLACE CRED_PAY   WITH 'Y'
               UNLOCK
               
               SELECT B
               I = I + 1
            ENDDO
            FLUSH
            MNOT_DONE = .F.
         ENDDO
      ENDDO
      CLOSE DATA
      
   CASE MSELECTION = '8'
      
      STORE DATE() TO MPAID_DATE
      MNEXT_CUST = .T.
      
      SELECT B
      DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE, PAY_CUST, PAY_PO, PAY_SYS", .F.
      
      SELECT C
      DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
      
      DO WHILE MNEXT_CUST
         MTITLE = ' - MOVE MISC. CREDITS TO A DIFFERENT CUSTOMER'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         @ 7,5 SAY 'The next screen will prompt you for a customer name.'
         @ 8,5 say 'Please select the customer account you want to move credits FROM.'
         STORE 'C' TO MCONT
         @ 10,5 say 'Enter a "C" to continue or "Q" to quit selection. ' get mcont picture '@!'
         READ
         IF MCONT <> 'C'
            MNEXT_CUST = .F.
            LOOP
         ENDIF
         MNAME_FD = .F.
         DO BBUYSEL3
         IF .NOT. MNAME_FD      
            MNEXT_CUST = .F.
            LOOP
         ENDIF
         STORE BBUYCODE TO MFROM_CODE
         STORE NAME TO MFROM_NAME
         STORE CITY TO MFROM_CITY
         STORE STATE TO MFROM_ST
         
         MTITLE = ' - MOVE MISC. CREDITS TO A DIFFERENT CUSTOMER'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         @ 7,5 SAY 'The next screen will ALSO prompt you for a customer name.'
         @ 8,5 say 'Please select the customer account you want to move credits TO.'
         STORE 'C' TO MCONT
         @ 10,5 say 'Enter a "C" to continue or "Q" to quit selection. ' get mcont picture '@!'
         READ
         IF MCONT <> 'C'
            MNEXT_CUST = .F.
            LOOP
         ENDIF
         MNAME_FD = .F.
         DO BBUYSEL3
         IF .NOT. MNAME_FD      
            MNEXT_CUST = .F.
            LOOP
         ENDIF
         STORE BBUYCODE TO MTO_CODE
         STORE NAME TO MTO_NAME
         STORE CITY TO MTO_CITY
         STORE STATE TO MTO_ST
         
         MTITLE = ' - MOVE MISC. CREDITS TO A DIFFERENT CUSTOMER'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         
         @ 7,5 SAY 'FROM Credits Customer:'        
         @ 9,10 SAY MFROM_NAME
         @ 10,10 SAY TRIM(MFROM_CITY) + ', ' + MFROM_ST  
         @ 12,5 SAY 'TO Credits Customer:'
         @ 14,10 SAY MTO_NAME
         @ 15,10 SAY TRIM(MTO_CITY) + ', ' + MTO_ST  
         
         STORE 'C' TO MCONT
         @ 18,5 say 'Enter a "C" to continue or "Q" to quit selection. ' get mcont picture '@!'
         READ
         IF MCONT <> 'C'
            MNEXT_CUST = .F.
            LOOP
         ENDIF
         
         SET PROC TO PAY_PROC
         MTITLE = ' - MOVE MISC. CREDITS TO A DIFFERENT CUSTOMER'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         IF MFROM_CODE <> SPACE(4)
            @ 04,1  SAY 'Customer:'
            @ 04,11 say MFROM_NAME
            @ 05,11 SAY TRIM(MFROM_CITY) + ', ' + MFROM_ST    
         ELSE
            @ 4,1 SAY 'No Customer Selected'
         ENDIF
         @ 06,1 to 06,78 
         @ 06,1 say 'OUTSTANDING CREDITS'
         *** ' ' = UNPAID
         SELECT C
         SEEK MFROM_CODE + ' '
         IF EOF()
            @ 14,1 SAY 'THERE ARE NO OUTSTANDING CREDITS ON FILE FOR THIS CUSTOMER.'
            @ 16,1 SAY 'PLEASE SELECT AGAIN'       
            @ 17,1 SAY ' '
            WAIT 'PRESS RETURN TO CONTINUE'
            LOOP
         ENDIF
         STORE RECNO() TO MRECNO             
         STORE 0 TO MUPDRCD, MPAYIND, MPAYAMT
         
         MSUB = 0
         MTOT_PAID = 0
         SELECT C
         
         MNOT_DONE = .T.
         DO WHILE MNOT_DONE
            STORE 0 TO MREC, MPD_AMT, MAMT, MSHRT, MDUE
            STORE ' ' TO MCK, MSW
            GOTO MRECNO
            MLINE = 7
            @ 07,1 CLEAR TO 22,78
            @ 24,0 CLEAR
            DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. BBUYCODE = MFROM_CODE .AND. PAID_FLG = ' '
               IF TOT_SELL - AMT_PAID >= 0
                  SKIP
                  LOOP
               ENDIF
               STORE INV_NBR TO MINV_NBR
               STORE SALESMAN TO MSALESMAN
               STORE PO_NBR TO MPO_NBR
               STORE PO_SUFFIX TO MPO_SUFFIX
               I = MLINE - 6 
               STORE I TO MI
               STORE RECNO() TO MREC(MI)
               MAMT(MI) = TOT_SELL                                   
               MDUE(MI) = TOT_SELL - AMT_PAID
               @ MLINE,1 SAY STR(MI,2) + '.'
               IF SALESMAN <> SPACE(2)
                  @ MLINE,6 SAY SALESMAN + '-'      
               ENDIF
               @ MLINE,9 SAY PO_NBR
               IF PO_SUFFIX <> ' '
                  @ MLINE,13 SAY '-' + PO_SUFFIX
               ENDIF
               @ mline,20  say INV_NBR 
               @ mline,30 say INV_DATE      
               @ mline,45 SAY MDUE(MI) picture '999,999.99'
               SKIP
               MLINE = MLINE + 1
            ENDDO
            MMAX_LINE = MLINE - 1
            STORE RECNO() TO MRECNO
            IF .NOT. EOF() .AND. BBUYCODE = MFROM_CODE .AND. PAID_FLG = ' '
               @ 23,70 SAY 'More Inv.'
               MBLURP = .T.
            ELSE
               @ 24,70 TO 24,79
               MBLURP = .F.
            ENDIF
            
            MLINE = 7 
            I = 1
            DO WHILE MLINE <= MMAX_LINE
               STORE I TO MI
               @ MLINE,60 GET MCK(MI) PICTURE '@!'
               @ MLINE,66 GET MPD_AMT(MI) PICTURE '999,999.99'
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
            DO WHILE I <= 16
               STORE I TO MI
               IF MCK(MI) <> ' ' .AND. MCK(MI) <> 'P' .AND. MCK(MI) <> 'X' .AND. MCK(MI) <> 'F' 
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  MERR_LINE = I       
                  MERR_LINE = STR(MERR_LINE,2)
                  @ 24,0 SAY 'CREDIT INDICATOR ON LINE ' + MERR_LINE + ' INVALID - PRESS RETURN TO REENTER ' GET MWAIT
                  READ
                  LOOP
               ENDIF
               IF MCK(MI) = 'P' .AND. MPD_AMT(MI) = 0
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  MERR_LINE = I      
                  MERR_LINE = STR(MERR_LINE,2)
                  @ 24,0 SAY 'PARTIAL CREDIT ON LINE ' + MERR_LINE + ' BUT NO AMOUNT ENTERED - PRESS RETURN TO REENTER' GET MWAIT
                  READ
                  LOOP
               ENDIF
               IF (MCK(MI) <> 'F' .AND. MCK(MI) <> 'X'.AND. MCK(MI) <> ' ') .AND. MDUE(MI) > 0 .AND. MPD_AMT(MI) < MDUE(MI)
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  MERR_LINE = I      
                  MERR_LINE = STR(MERR_LINE,2)
                  @ 24,0 SAY 'CREDIT AMT ENTERED MORE THAN CREDIT AMOUNT LEFT ON LINE '+ MERR_LINE + ' ' GET MWAIT 
                  READ
                  LOOP
               ENDIF
               
               I = I + 1
            ENDDO
            MLINE = 7 
            I = 1
            MPG_PAID = 0
            DO WHILE I <= 11
               IF MCK(I) = ' '
                  I = I + 1
                  MLINE = MLINE + 1
                  LOOP
               ENDIF
               IF (MCK(I) = 'X' .OR. MCK(I) = 'F') .AND. MPD_AMT(I) = 0
                  @ I+6,66 GET  MDUE(I) PICTURE '999,999.99'
                  CLEAR GETS
                  MPG_PAID = MPG_PAID + MDUE(I)
               ELSE
                  MPG_PAID = MPG_PAID + MPD_AMT(I)
               ENDIF
               I = I + 1
            ENDDO
            @ 4,50 SAY 'Total Credits Selected'
            @ 5,57 SAY MPG_PAID + MTOT_PAID PICTURE '999,999.99'
            
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
                  LOOP
               ENDIF
            ELSE
               IF MACTION = 3
                  MNOT_DONE = .F.
                  LOOP
               ENDIF
            ENDIF
            
            I = 1 
            DO WHILE I <= 16
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
               SELECT C
               GOTO MUPDRCD(I)
               DO RECLOCK
               REPLACE AMT_PAID WITH AMT_PAID + MPAYAMT(I)
               UNLOCK
               IF TOT_SELL = AMT_PAID
                  DO FILELOCK
                  REPLACE PAID_FLG WITH 'Y'
                  UNLOCK
               ENDIF
               STORE SALESMAN TO MSALESMAN
               STORE PO_NBR TO MPO_NBR
               STORE PO_SUFFIX TO MPO_SUFFIX
               STORE BBUYCODE TO MBBUYCODE
               STORE ORIG_BBUY TO MORIG_BBUY
               STORE SHIP_DATE TO MTRAN_DATE
               STORE INV_NBR TO MINV_NBR
               
               ***** MAKE AN ENTRY ON CUSTOMER PAYMENT FILE  ****
               ***** CUS_INV FILE FOR THE NEW CUSTOMER AMOUNT ***
               
               SELECT C
               DO FILELOCK 
               APPEND BLANK
               REPLACE SALESMAN   WITH MSALESMAN  
               REPLACE PO_NBR     WITH MPO_NBR    
               REPLACE PO_SUFFIX  WITH MPO_SUFFIX 
               REPLACE INV_NBR    WITH MINV_NBR
               REPLACE BBUYCODE   WITH MTO_CODE   
               REPLACE TOT_SELL   WITH MPAYAMT(I)                  
               REPLACE DEB_CRD    WITH 'Y'
               REPLACE SHIP_DATE  WITH MTRAN_DATE   
               REPLACE INV_DATE   WITH MTRAN_DATE
               REPLACE CRED_PAY   WITH 'Y'
               UNLOCK
               
               **********************************************************
               ** MAKE UPDATING ENTRIES ON RECEIPTS FILE TO CLEAR LEDGERS
               **********************************************************
               ** RECEIPTS FILE  (PAYMENTS FILE)  ** 
               **********************************************************
               SELECT B
               DO FILELOCK
               ****** THIS IS FOR THE FROM CUSTOMER ACCOUNT       
               APPEND BLANK
               REPLACE SALESMAN WITH MSALESMAN
               REPLACE PO_NBR WITH MPO_NBR
               REPLACE PO_SUFFIX WITH MPO_SUFFIX
               REPLACE INV_NBR WITH MINV_NBR
               REPLACE BBUYCODE WITH MFROM_CODE  
               REPLACE PAID_DATE WITH DATE()    
               REPLACE SYS_DATE WITH DATE()
               REPLACE DEB_CRD WITH 'Y'        
               REPLACE INV_DATE WITH MTRAN_DATE
               REPLACE AMT_PAID WITH MPAYAMT(I)
               
               ***** THIS IS FOR THE TO CUSTOMER ACCOUNT      
               APPEND BLANK
               REPLACE SALESMAN WITH MSALESMAN
               REPLACE PO_NBR WITH MPO_NBR
               REPLACE PO_SUFFIX WITH MPO_SUFFIX
               REPLACE INV_NBR WITH MINV_NBR
               REPLACE BBUYCODE WITH MTO_CODE    
               REPLACE PAID_DATE WITH DATE()    
               REPLACE SYS_DATE WITH DATE()
               REPLACE DEB_CRD WITH 'Y'     
               REPLACE INV_DATE WITH MTRAN_DATE
               REPLACE AMT_PAID WITH (-1) * MPAYAMT(I)
               UNLOCK
               
               I = I + 1
            ENDDO
            FLUSH
            MNOT_DONE = .F.
         ENDDO
         MNEXT_CUST = .F.
      ENDDO
      CLOSE DATA
   ENDCASE
   CLOSE DATA
   
ENDDO
CLOSE DATA
RETURN

* EOF: BUY_PAY.PRG

*Formatted by: ToolBox Ver. 1.2  on 8/14/14 at 2:31 PM.
