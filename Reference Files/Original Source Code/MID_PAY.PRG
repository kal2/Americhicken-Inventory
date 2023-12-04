**********
* Program.: MID_PAY.PRG
* Author..: GRACE KELLER
* Date....: 01/22/88
* Notice..: Copyright 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MIDWEST PAYMENT MENU   
*
* ---PROCESSING LOOP
STORE 0 TO MACTION
STORE '  ' TO MSELECTION

DO WHILE MSELECTION <> '99'
   SET PROC TO PO_PROC
   CLOSE DATA
   CLEAR
   @ 00,00 SAY MCOMPANY
   @ 01,00 SAY MPROGRAM + ' - MIDWEST PAYMENT MENU'
   @ 02,00 TO 24,79 
   
   @ 03,09 SAY " 1 - MATCH SUPPLIER INVOICES RECEIVED WITH PO'S"
   @ 04,09 SAY ' 2 - APPROVE SUPPLIER INVOICES FOR PAYMENT'          
   @ 05,09 SAY ' 3 - PRINT SUPPLIER ADJUSTMENT ADVISEMENTS'
   @ 06,09 SAY ' 4 - SUPPLIER CHECK PRINT / WIRE PAYMENTS / DEBIT & CREDIT PROCESS'
   @ 07,09 SAY ' 5 - ENTER SUPPLIER BILLING PRICE ADJUSTMENTS'
   @ 08,09 SAY ' 6 - UNMATCH/RELEASE HOLD SUPPLIER INVOICES'
   
   @ 10,09 SAY " 7 - MATCH FREIGHT INVOICES RECEIVED WITH PO'S"
   @ 11,09 SAY ' 8 - APPROVE FREIGHT INVOICES FOR PAYMENT'
   @ 12,09 SAY ' 9 - PRINT FREIGHT CHECKS'
   @ 13,09 SAY '10 - UNMATCH FREIGHT INVOICES'
   @ 15,09 say '11 - MANUAL DISBURSEMENTS (PAYROLL & MISCELLANEOUS)'
   @ 17,09 SAY '12 - COMMISSIONS'
   @ 19,09 SAY '13 - VOID CHECK'             
   @ 20,09 SAY '14 - CLEAR CHECKS / BALANCE BANK STATEMENT'
   @ 21,09 SAY '15 - CREATE COMMERCE POSTIVE PAY FILE'
   @ 22,09 SAY '99 - EXIT TO MAIN MENU'
   
   @ 24,01 SAY 'CHOICE: '
   @ 24,09 get mselection picture '##'
   READ
   
   DO CASE
      
   CASE VAL(MSELECTION) = 1
      DO SUP_REC
   CASE VAL(MSELECTION) = 2
      DO APRV_SUP
   CASE VAL(MSELECTION) = 3
      DO PRT_ADV
   CASE VAL(MSELECTION) = 4
      DO SUP_CHK
   CASE VAL(MSELECTION) = 5
      MDOSHORT = .F.
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PO_SUP, PO_SHIP, PO_FRT", .F.
      SELECT C
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      SET PROC TO PO_PROC
      DO PO_SEL2
      CLOSE DATA
      
   CASE VAL(MSELECTION) = 6
      DO UNMATCH 
      
   CASE VAL(MSELECTION) = 7
      DO FRT_REC1
   CASE VAL(MSELECTION) = 8
      DO APRV_FRT
   CASE VAL(MSELECTION) = 9
      DO FRT_CHK1
   CASE VAL(MSELECTION) = 10
      DO UNFRT   
      
   CASE VAL(MSELECTION) = 11
      DO MAN_DISB
   CASE VAL(MSELECTION) = 12
      DO COM_MENU
   CASE VAL(MSELECTION) = 13
      DO VOID_CK 
   CASE VAL(MSELECTION) = 14
      MTITLE = ' - CLEAR CHECKS/BALANCE BANK STATEMENT'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      STORE ' ' TO MFUNC1, MFUNC2
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 06,5 SAY 'Please select desired function:' 
         @ 9,5 say  '1. Clear/Unclear Checks: ' GET MFUNC1 PICTURE '@!'
         @ 11,5 say '2.     Balance Statment: ' GET MFUNC2 PICTURE '@!'
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
         @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
         READ
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
      ENDDO
      IF MACTION = 3
         LOOP   
      ENDIF
      DO CASE
      CASE MFUNC1 = 'X'
         MTITLE = ' - CLEAR CHECKS' 
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         *SELECT A
         *DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
         *MUNCLRDNBR = UNCLRDNBR
         SELECT C
         DO FOX_USE WITH "\AMERICO\CK_REG", .F.
         @ 10,1 SAY SPACE(78)
         MCHOICE = ' '
         MNBR = 0
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            CLEAR 
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            MTITLE = ' - CLEAR/UNCLEAR CHECKS'
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 to 24,79
            @ 06,5 SAY 'Do you want to CLEAR (C) or UNCLEAR (U)? ' GET MCHOICE PICTURE '@!'
            @ 09,5 SAY 'Starting Check Number: ' get mnbr picture '######'
            
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
            @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
            IF  MACTION = 2 .OR. MACTION = 3 
               LOOP
            ENDIF
            
         ENDDO
         
         IF MACTION = 3 .OR. (MCHOICE <> 'C' .AND. MCHOICE <> 'U')
            RELEASE MUPDRCD, MSELECT
            CLOSE DATA
            LOOP
         ENDIF
         
         @ 13,3 SAY 'PLEASE WAIT,,, SORTING CHECKS TOGETHER...'
         SET FILTER TO VAL(CK_NBR) >= MNBR
         GOTO TOP
         DO CASE
         CASE MCHOICE = 'U'
            COPY TO TMPSORT FOR VOID_MAN <> 'V' .AND. CLEAR_FLG <> ' '
         OTHERWISE
            COPY TO TMPSORT FOR VOID_MAN <> 'V' .AND. CLEAR_FLG = ' ' 
         ENDCASE
         USE TMPSORT EXCLUSIVE
         REPLACE ALL DESCRIP WITH 'AMERICO'
         
         
         MDOIT = .F.
         IF MDOIT
            DO FOX_USE WITH "\AMERICO\CK_REG", .F.
            SET FILTER TO VAL(CK_NBR) >= MNBR
            GOTO TOP
            DO CASE
            CASE MCHOICE = 'U'
               COPY TO TMPSORT1 FOR VOID_MAN <> 'V' .AND. CLEAR_FLG <> ' '
            OTHERWISE
               COPY TO TMPSORT1 FOR VOID_MAN <> 'V' .AND. CLEAR_FLG = ' '
            ENDCASE
            USE TMPSORT1 EXCLUSIVE
            REPLACE ALL DESCRIP WITH 'AMERICO'
            
            **DO FOX_USE WITH "\PLANT71\CK_REG", .F.
            **SET FILTER TO VAL(CK_NBR) >= MNBR
            **GOTO TOP
            **DO CASE
            **CASE MCHOICE = 'U'
            **   COPY TO TMPSORT2 FOR VOID_MAN <> 'V' .AND. CLEAR_FLG <> ' '
            **OTHERWISE
            **   COPY TO TMPSORT2 FOR VOID_MAN <> 'V' .AND. CLEAR_FLG = ' '
            **ENDCASE
            **USE TMPSORT2 EXCLUSIVE
            **REPLACE ALL DESCRIP WITH 'PLANT71'
            
            USE TMPSORT EXCLUSIVE
            APPEND FROM TMPSORT1
            **APPEND FROM TMPSORT2
            INDEX ON CK_NBR TO TMPSORT
         ENDIF
         
         USE TMPSORT EXCLUSIVE
         INDEX ON CK_NBR TO TMPSORT
         DO FOX_USE WITH "TMPSORT INDEX TMPSORT", .F.
         
         STORE RECNO() TO MVWRECNO
         DIMENSION MSELECT(18), MUPDRCD(18)
         
         CLEAR 
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         MTITLE = ' - CLEAR/UNCLEAR CHECKS'
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         MPICK = SPACE(8)
         SET CONFIRM ON
         @ 10,1 SAY 'Do You Want to Print a REPORT  (REPORT)'       
         @ 11,1 SAY 'OR CONTINUE With Clear/Unclear (CONTINUE): ' GET MPICK PICTURE '@!'
         READ
         SET CONFIRM OFF
         MPICK = UPPER(MPICK)
         DO CASE
         CASE MPICK = 'REPORT'   
            
            SET CONSOLE OFF
            IF FILE("C:\COMPINFO\PRINTERS.DBF")
               SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
            ELSE
               SET PRINT TO LPT3
            ENDIF
            SET DEVICE TO PRINT
            SET PRINT ON
            
            *** PRINT IN 10 CPI
            ?? chr(27) + '&k0S'
            
            *** LETTER GOTHIC AND BOLDED PRINT
            ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
            
            *** LETTER SIZE PAPER
            ?? CHR(27) + '&l2A'
            
            *** PORTRAIT MODE
            ?? CHR(27) + '&l0O'
            
            MPAGE = 0
            MLINE = 99
            DO WHILE .NOT. EOF()
               IF MLINE > 56
                  IF MLINE <> 99
                     @ MLINE+1,1 SAY ' '
                     EJECT
                  ENDIF
                  MLINE = 2
                  @ MLINE,2 SAY DATE()
                  @ MLINE,23 SAY 'OUTSTANDING CHECKS'
                  @ MLINE,70 SAY TIME()
                  MLINE = MLINE + 2
                  @ MLINE,2 SAY 'CHK NBR     CK DATE        AMOUNT      DATABASE'
                  MLINE = MLINE + 2
               ENDIF
               @ MLINE,2 SAY CK_NBR
               @ MLINE,14 SAY CK_DATE
               @ MLINE,24 SAY AMOUNT PICTURE '9,999,999.99'
               @ MLINE,42 SAY SUBSTR(DESCRIP,1,7)
               MLINE = MLINE + 1
               SKIP
            ENDDO
            IF MLINE <> 99
               @ MLINE+1,1 SAY ' '
               EJECT
            ENDIF
            SET DEVICE TO SCREEN
            SET PRINT OFF
            SET PRINT TO
            SET CONSOLE ON
            IF MPRINTER3 <> 'DONOTPRINT'
               RUN &MPRINTIT3
            ENDIF
            LOOP
         OTHERWISE
            IF MPICK <> 'CONTINUE'
               LOOP
            ENDIF
         ENDCASE
         CLEAR 
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         MTITLE = ' - CLEAR/UNCLEAR CHECKS'
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         IF MCHOICE = 'U'
            @ 04,1  SAY '   Unclear  Check Number   Check Amount   Check Date       (CLEARED CHECKS)'
         ELSE
            @ 04,1  SAY '    Clear   Check Number   Check Amount   Check Date       (UNCLEARED CHECKS)'
         ENDIF
         @ 05,1 TO 05,78
         
         DO WHILE .NOT. EOF() 
            STORE ' ' TO MSELECT, MUPDRCD
            SELECT C
            GOTO MVWRECNO
            MLINE = 06
            @ 06,1 CLEAR TO 23,78
            @ 24,0 CLEAR
            DO WHILE .NOT. EOF() .AND. MLINE < 23 
               *IF VOID_MAN = 'V'
               *   SKIP
               *   LOOP
               *ENDIF
               *IF MCHOICE = 'U'
               *   IF CLEAR_FLG <> ' '
               *      SKIP
               *      LOOP
               *   ENDIF
               *ELSE
               *   IF CLEAR_FLG <> 'N'
               *      SKIP
               *     LOOP
               *   ENDIF
               *ENDIF
               I = MLINE - 5
               @ MLINE,1 SAY STR(I,2) + '.'
               MUPDRCD(I) = RECNO()
               @ MLINE,15 SAY CK_NBR
               @ MLINE,29 SAY AMOUNT PICTURE '999,999.99'
               @ MLINE,44 SAY CK_DATE
               SKIP
               MLINE = MLINE + 1
            ENDDO
            MVW_MAX = MLINE - 1 
            MSUB_MAX = I
            IF .NOT. EOF() 
               @ 22,69 SAY "More ...."
               MVWBLURP = .T.
            ELSE
               @ 22,69 SAY SPACE(9)
               MVWBLURP = .F.
            ENDIF
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            IF MVWBLURP
               @ 24,13 SAY '1. Continue/Next Page    2. Edit    3. Finished'    
            ELSE
               @ 24,13 SAY '1. Continue/Return    2. Edit    3. Finished'    
            ENDIF
            STORE 2 TO MACTION
            DO WHILE MACTION = 2 
               MVWLINE = 6
               MVWI = 1
               DO WHILE MVWLINE <= MVW_MAX
                  IF MSELECT(MVWI) = ' '                   
                     @ MVWLINE,7 GET MSELECT(MVWI) PICTURE '@!'
                  ELSE 
                     @ MVWLINE,7 SAY MSELECT(MVWI)           
                  ENDIF
                  MVWLINE = MVWLINE + 1
                  MVWI = MVWI + 1
               ENDDO
               READ
               STORE 1 TO MACTION
               @ 24,9 GET MACTION PICTURE '#' RANGE 1,3
               READ
            ENDDO
            
            MVWI = 1
            DO WHILE MVWI <= MSUB_MAX
               IF MSELECT(MVWI) = 'X'          
                  GOTO MUPDRCD(MVWI)
                  **** OLD WAY
                  *DO RECLOCK
                  *IF MCHOICE = 'U'
                  *   REPLACE CLEAR_FLG WITH 'N'
                  *   IF VAL(CK_NBR) < VAL(MUNCLRDNBR) .AND. VAL(CK_NBR) > 700
                  *      SELECT A
                  *      DO RECLOCK  
                  *      REPLACE UNCLRDNBR WITH C->CK_NBR
                  *      UNLOCK
                  *      SELECT C
                  *   ENDIF
                  *ELSE
                  *   REPLACE CLEAR_FLG WITH ' '
                  *ENDIF                                 
                  *UNLOCK
                  MUPDATED = .F.
                  DO CASE
                  CASE DESCRIP = 'AMERICO'
                     SELECT A
                     DO FOX_USE WITH "\AMERICO\CK_REG INDEX \AMERICO\CK_REG", .F.
                     SEEK C->CK_NBR
                     IF .NOT. EOF()
                        DO WHILE .NOT. EOF() .AND. CK_NBR = C->CK_NBR .AND. VOID_MAN = 'V'
                           SKIP
                        ENDDO
                        IF CK_NBR = C->CK_NBR
                           DO RECLOCK
                           IF MCHOICE = 'U'
                              REPLACE CLEAR_FLG WITH ' '
                           ELSE
                              REPLACE CLEAR_FLG WITH 'Y'
                           ENDIF                                 
                           UNLOCK
                           MUPDATED = .T.
                        ENDIF
                     ENDIF
                     
                  CASE DESCRIP = 'AMERICO'
                     SELECT A
                     DO FOX_USE WITH "\AMERICO\CK_REG INDEX \AMERICO\CK_REG", .F.
                     SEEK C->CK_NBR
                     IF .NOT. EOF()
                        DO WHILE .NOT. EOF() .AND. CK_NBR = C->CK_NBR .AND. VOID_MAN = 'V'
                           SKIP
                        ENDDO
                        IF CK_NBR = C->CK_NBR
                           DO RECLOCK
                           IF MCHOICE = 'U'
                              REPLACE CLEAR_FLG WITH ' '
                           ELSE
                              REPLACE CLEAR_FLG WITH 'Y'
                           ENDIF                                 
                           UNLOCK
                           MUPDATED = .T.
                        ENDIF
                     ENDIF
                     
                     
                  CASE DESCRIP = 'PLANT71'
                     SELECT A
                     DO FOX_USE WITH "\PLANT71\CK_REG INDEX \PLANT71\CK_REG", .F.
                     SEEK C->CK_NBR
                     IF .NOT. EOF()
                        DO WHILE .NOT. EOF() .AND. CK_NBR = C->CK_NBR .AND. VOID_MAN = 'V'
                           SKIP
                        ENDDO
                        IF CK_NBR = C->CK_NBR
                           DO RECLOCK
                           IF MCHOICE = 'U'
                              REPLACE CLEAR_FLG WITH ' '
                           ELSE
                              REPLACE CLEAR_FLG WITH 'Y'
                           ENDIF                                 
                           UNLOCK
                           MUPDATED = .T.
                        ENDIF
                     ENDIF
                  ENDCASE
                  SELECT C
                  IF .NOT. MUPDATED   
                     @ 24,0 CLEAR
                     MCONT = ' '
                     DO WHILE MCONT <> 'C'
                        @ 24,1 SAY 'CK #: ' + CK_NBR + ' NOT UPDATED - NOT FOUND ON D/B- ENTER "C" TO CONTINUE ' GET MCONT PICTURE '@!'
                        READ
                     ENDDO
                     @ 24,0 CLEAR
                  ENDIF
                  
                  
               ENDIF
               MVWI = MVWI + 1
            ENDDO
            
            IF MACTION = 3 
               GOTO BOTTOM
               SKIP
               LOOP
            ENDIF
            
            IF MVWBLURP .AND. MACTION = 1
               GOTO MUPDRCD(MSUB_MAX)
               SKIP     
               IF .NOT. EOF()
                  STORE RECNO() TO MVWRECNO
               ENDIF
            ELSE
               GOTO BOTTOM
               SKIP
               LOOP
            ENDIF
         ENDDO
         RELEASE MUPDRCD, MSELECT
      CASE MFUNC2 = 'X'
         MTITLE = ' - BALANCE BANK STATEMENT' 
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
         MBANK_BAL = BANK_BAL
         MOUT_DEP  = 0
         MSTMT_DATE = CTOD('')
         @ 08,5 SAY ' Statement Cutoff Date: '
         @ 10,5 SAY 'Bank Statement Balance: '
         @ 12,5 say '  Outstanding Deposits: '
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 08,31 GET MSTMT_DATE  
            @ 10,31 GET MBANK_BAL PICTURE '###,###,###.##'
            @ 12,31 GET MOUT_DEP  PICTURE '###,###,###.##'
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
            @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
            READ
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
         ENDDO
         IF MACTION = 3
            CLOSE DATA
            LOOP   
         ENDIF
         DO RECLOCK 
         REPLACE BANK_BAL WITH MBANK_BAL
         UNLOCK
         MUNCLRDNBR = UNCLRDNBR
         USE
         
         @ 4,1 CLEAR TO 22,78
         MPRT_ACT = 'C'
         DO PRT_SET
         IF MPRT_ACT <> 'C'
            LOOP  
         ENDIF
         
         SET CONSOLE OFF
         IF FILE("C:\COMPINFO\PRINTERS.DBF")
            SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
         ELSE
            SET PRINT TO LPT3
         ENDIF
         SET DEVICE TO PRINT
         SET PRINT ON
         
         *** PRINT IN 12 CPI
         ?? chr(27) + '&k4S'
         
         *** LETTER GOTHIC AND BOLDED PRINT
         ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
         
         *** LETTER SIZE PAPER
         ?? CHR(27) + '&l2A'
         
         *** PORTRAIT MODE
         ?? CHR(27) + '&l0O'
         
         SELECT B
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
         SELECT C
         DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
         SELECT A
         DO FOX_USE WITH "CK_REG INDEX CK_REG", .F.
         MLINE = 99
         MPAGE_NO = 0
         MTOT = 0
         SEEK MUNCLRDNBR  
         IF EOF()
            GOTO TOP
            DO WHILE .NOT. EOF() .AND. CLEAR_FLG <> ' '
               SKIP
            ENDDO
         ENDIF
         IF CLEAR_FLG <> ' '
            SKIP
            MCONT = .T.
            DO WHILE .NOT. EOF() .AND. MCONT
               IF CLEAR_FLG = ' '
                  SELECT D
                  DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
                  DO RECLOCK
                  REPLACE UNCLRDNBR WITH A->CK_NBR
                  UNLOCK
                  USE
                  SELECT A
                  MCONT = .F.
                  LOOP
               ENDIF
               SKIP
            ENDDO
         ENDIF
         DO WHILE .NOT. EOF()
            IF VOID_MAN = 'V'
               SKIP
               LOOP
            ENDIF
            IF CLEAR_FLG <> ' '
               SKIP
               LOOP
            ENDIF
            IF CK_DATE > MSTMT_DATE
               SKIP
               LOOP
            ENDIF
            IF MLINE > 58
               IF MLINE <> 99
                  EJECT
               ENDIF
               MLINE = 2
               MPAGE_NO = MPAGE_NO + 1
               @ MLINE,2 SAY 'PAGE  ' + STR(MPAGE_NO,3)
               @ MLINE,27 SAY 'BANK STATEMENT BALANCING'     
               @ MLINE,65 SAY DTOC(DATE())
               MLINE = MLINE + 2
               @ 4,2 SAY 'CHECK NBR      CHK DATE   PAYEE                                          AMOUNT'
               @ 5,0 SAY REPLICATE ('_',81)
               MLINE = 7
            ENDIF
            @ MLINE,3 SAY CK_NBR
            @ MLINE,17 SAY CK_DATE
            
            DO CASE
            CASE PAY_TYPE = 'S'
               SELECT B
               SEEK A->PAY_CODE
               IF EOF()
                  STORE 'PAYEE NOT ON FILE' TO MNAME
               ELSE
                  STORE NAME TO MNAME
               ENDIF
               @ MLINE,28 SAY MNAME
               SELECT A
            CASE PAY_TYPE = 'F'
               SELECT C 
               SEEK A->PAY_CODE
               IF EOF()
                  STORE 'PAYEE NOT ON FILE' TO MNAME
               ELSE
                  STORE NAME TO MNAME
               ENDIF
               @ MLINE,28 SAY MNAME
               SELECT A
            CASE PAY_TYPE = 'O' .OR. PAY_TYPE = 'P' 
               @ MLINE,28 SAY PAY_NAME
            ENDCASE
            @ MLINE,71 SAY AMOUNT PICTURE '999,999.99'
            MTOT = MTOT + AMOUNT
            MLINE = MLINE + 1
            SKIP
         ENDDO
         *** THIS IS FOR THE 11 DATABASE - AMERICHICKEN
         MDO_THIS = .F.
         IF MDO_THIS
            SELECT B
            DO FOX_USE WITH "\AMERICO\REM_SUP INDEX \AMERICO\RSUPCODE", .F.
            SELECT C
            DO FOX_USE WITH "\AMERICO\FREIGHT INDEX \AMERICO\FRT_CODE", .F.
            SELECT A
            DO FOX_USE WITH "\AMERICO\CK_REG INDEX \AMERICO\CK_REG", .F.
            DO WHILE .NOT. EOF()
               IF VOID_MAN = 'V'
                  SKIP
                  LOOP
               ENDIF
               IF CLEAR_FLG <> ' '
                  SKIP
                  LOOP
               ENDIF
               IF CK_DATE > MSTMT_DATE
                  SKIP
                  LOOP
               ENDIF
               IF MLINE > 58
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MLINE = 2
                  MPAGE_NO = MPAGE_NO + 1
                  @ MLINE,2 SAY 'PAGE  ' + STR(MPAGE_NO,3)
                  @ MLINE,27 SAY 'BANK STATEMENT BALANCING'     
                  @ MLINE,65 SAY DTOC(DATE())
                  MLINE = MLINE + 2
                  @ 4,2 SAY 'CHECK NBR      CHK DATE   PAYEE                                          AMOUNT'
                  @ 5,0 SAY REPLICATE ('_',81)
                  MLINE = 7
               ENDIF
               @ MLINE,0 SAY '11-'
               @ MLINE,3 SAY CK_NBR
               @ MLINE,17 SAY CK_DATE
               
               DO CASE
               CASE PAY_TYPE = 'S'
                  SELECT B
                  SEEK A->PAY_CODE
                  IF EOF()
                     STORE 'PAYEE NOT ON FILE' TO MNAME
                  ELSE
                     STORE NAME TO MNAME
                  ENDIF
                  @ MLINE,28 SAY MNAME
                  SELECT A
               CASE PAY_TYPE = 'F'
                  SELECT C 
                  SEEK A->PAY_CODE
                  IF EOF()
                     STORE 'PAYEE NOT ON FILE' TO MNAME
                  ELSE
                     STORE NAME TO MNAME
                  ENDIF
                  @ MLINE,28 SAY MNAME
                  SELECT A
               CASE PAY_TYPE = 'O'
                  @ MLINE,28 SAY PAY_NAME
               ENDCASE
               @ MLINE,71 SAY AMOUNT PICTURE '999,999.99'
               MTOT = MTOT + AMOUNT
               MLINE = MLINE + 1
               SKIP
            ENDDO
         ENDIF
         
         MDO_THIS = .F.
         IF MDO_THIS
            *** THIS IS FOR THE 10 DATABASE - YUMA, AZ    
            SELECT A
            DO FOX_USE WITH "I:CK_REG INDEX I:CK_REG", .F.
            DO WHILE .NOT. EOF()
               IF VOID_MAN = 'V'
                  SKIP
                  LOOP
               ENDIF
               IF CLEAR_FLG <> ' '
                  SKIP
                  LOOP
               ENDIF
               IF CK_DATE > MSTMT_DATE
                  SKIP
                  LOOP
               ENDIF
               IF MLINE > 58
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MLINE = 2
                  MPAGE_NO = MPAGE_NO + 1
                  @ MLINE,2 SAY 'PAGE  ' + STR(MPAGE_NO,3)
                  @ MLINE,27 SAY 'BANK STATEMENT BALANCING'     
                  @ MLINE,65 SAY DTOC(DATE())
                  MLINE = MLINE + 2
                  @ 4,2 SAY 'CHECK NBR      CHK DATE   PAYEE                                          AMOUNT'
                  @ 5,0 SAY REPLICATE ('_',81)
                  MLINE = 7
               ENDIF
               @ MLINE,0 SAY '10-'
               @ MLINE,3 SAY CK_NBR
               @ MLINE,17 SAY CK_DATE
               
               DO CASE
               CASE PAY_TYPE = 'S'
                  SELECT B
                  SEEK A->PAY_CODE
                  IF EOF()
                     STORE 'PAYEE NOT ON FILE' TO MNAME
                  ELSE
                     STORE NAME TO MNAME
                  ENDIF
                  @ MLINE,28 SAY MNAME
                  SELECT A
               CASE PAY_TYPE = 'F'
                  SELECT C 
                  SEEK A->PAY_CODE
                  IF EOF()
                     STORE 'PAYEE NOT ON FILE' TO MNAME
                  ELSE
                     STORE NAME TO MNAME
                  ENDIF
                  @ MLINE,28 SAY MNAME
                  SELECT A
               CASE PAY_TYPE = 'O'
                  @ MLINE,28 SAY PAY_NAME
               ENDCASE
               @ MLINE,71 SAY AMOUNT PICTURE '999,999.99'
               MTOT = MTOT + AMOUNT
               MLINE = MLINE + 1
               SKIP
            ENDDO
            
            
            *** THIS IS FOR THE 20 DATABASE - PRODUCE     
            SELECT A
            DO FOX_USE WITH "J:CK_REG INDEX J:CK_REG", .F.
            DO WHILE .NOT. EOF()
               IF VOID_MAN = 'V'
                  SKIP
                  LOOP
               ENDIF
               IF CLEAR_FLG <> ' '
                  SKIP
                  LOOP
               ENDIF
               IF CK_DATE > MSTMT_DATE
                  SKIP
                  LOOP
               ENDIF
               IF MLINE > 58
                  IF MLINE <> 99
                     EJECT
                  ENDIF
                  MLINE = 2
                  MPAGE_NO = MPAGE_NO + 1
                  @ MLINE,2 SAY 'PAGE  ' + STR(MPAGE_NO,3)
                  @ MLINE,27 SAY 'BANK STATEMENT BALANCING'     
                  @ MLINE,65 SAY DTOC(DATE())
                  MLINE = MLINE + 2
                  @ 4,2 SAY 'CHECK NBR      CHK DATE   PAYEE                                          AMOUNT'
                  @ 5,0 SAY REPLICATE ('_',81)
                  MLINE = 7
               ENDIF
               @ MLINE,0 SAY '20-'
               @ MLINE,3 SAY CK_NBR
               @ MLINE,17 SAY CK_DATE
               
               DO CASE
               CASE PAY_TYPE = 'S'
                  SELECT B
                  SEEK A->PAY_CODE
                  IF EOF()
                     STORE 'PAYEE NOT ON FILE' TO MNAME
                  ELSE
                     STORE NAME TO MNAME
                  ENDIF
                  @ MLINE,28 SAY MNAME
                  SELECT A
               CASE PAY_TYPE = 'F'
                  SELECT C 
                  SEEK A->PAY_CODE
                  IF EOF()
                     STORE 'PAYEE NOT ON FILE' TO MNAME
                  ELSE
                     STORE NAME TO MNAME
                  ENDIF
                  @ MLINE,28 SAY MNAME
                  SELECT A
               CASE PAY_TYPE = 'O'
                  @ MLINE,28 SAY PAY_NAME
               ENDCASE
               @ MLINE,71 SAY AMOUNT PICTURE '999,999.99'
               MTOT = MTOT + AMOUNT
               MLINE = MLINE + 1
               SKIP
            ENDDO
         ENDIF
         
         
         
         IF MTOT <> 0              
            MLINE = MLINE + 1
            @ MLINE,41 SAY 'TOTAL UNCLEARED CHECKS: '
            @ MLINE,67 SAY MTOT PICTURE '999,999,999.99'
         ENDIF
         MLINE = MLINE + 2
         IF MLINE+11 > 58
            IF MLINE <> 99
               @ MLINE+1,1 SAY ' '
               EJECT
            ENDIF
            MLINE = 2
            MPAGE_NO = MPAGE_NO + 1
            @ MLINE,2 SAY 'PAGE  ' + STR(MPAGE_NO,3)
            @ MLINE,27 SAY 'BANK STATEMENT BALANCING'     
            @ MLINE,65 SAY DTOC(DATE())
            MLINE = MLINE + 2
            @ 4,2 SAY 'CHECK NBR      CHK DATE   PAYEE                                          AMOUNT'
            @ 5,0 SAY REPLICATE ('_',81)
            MLINE = 7
         ENDIF
         @ MLINE,3 SAY '   STATEMENT BALANCE: '
         @ MLINE,30 SAY MBANK_BAL PICTURE '999,999,999.99'
         MLINE = MLINE + 2 
         @ MLINE,3 SAY 'OUTSTANDING DEPOSITS: '
         @ MLINE,30 SAY MOUT_DEP PICTURE '999,999,999.99'
         MLINE = MLINE + 2 
         @ MLINE,5 SAY '      Subtotal . .:'
         @ MLINE,30 SAY MBANK_BAL + MOUT_DEP PICTURE '999,999,999.99'
         MLINE = MLINE + 2     
         @ MLINE,3 SAY '  OUTSTANDING CHECKS: '
         @ MLINE,30 SAY MTOT PICTURE '999,999,999.99'
         MLINE = MLINE + 2
         @ MLINE,30 SAY '=============='
         MLINE = MLINE + 2
         @ MLINE,3 SAY '             BALANCE: '
         @ MLINE,30 SAY MBANK_BAL + MOUT_DEP - MTOT PICTURE '999,999,999.99'
         MLINE = MLINE + 1
         @ MLINE,1 SAY ' '
         EJECT
         
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
      ENDCASE
      MSELECTION = '  '
   CASE VAL(MSELECTION) = 15
      DO POSPAY
      MSELECTION = '  '
   ENDCASE
   
   IF MSELECTION <> '99'
      MSELECTION = '  '
   ENDIF
ENDDO
CLOSE DATA
RETURN

* EOF: MID_PAY.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 11:30 AM.
