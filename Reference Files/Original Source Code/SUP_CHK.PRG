**************
* Program.: SUP_CHK.PRG
* Author..: Grace Keller
* Date....: 01/25/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINT SUPPLIER CHECKS
*
IF MMASTDBF = '\AMERICO\'
   TEMPMAST = '\AMERICO\'
ELSE
   TEMPMAST = '\BROKER\'
ENDIF
MTITLE = ' - SUPPLIER CHECK PRINT / WIRE PAYMENTS / DEBIT & CREDIT CLEAR'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@  3,0 TO 22,79
IF MPROG_CODE = 1
   SELECT A
   DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.
ELSE
   SELECT A
   DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
ENDIF
IF CK_PRINT = 'Y'
   STORE 'Someone else is printing checks at this time.' TO MMSG1
   STORE 'Please wait until they have completed to print your checks !' TO MMSG2
   STORE "Press 'Enter' to return to menu." TO MMSG3
   @ 10,5 GET MMSG1
   @ 12,5 GET MMSG2
   CLEAR GETS
   @ 14,5 GET MMSG3
   READ  
   CLOSE DATA
   RETURN
ELSE
   DO FILELOCK
   REPLACE CK_PRINT WITH 'Y'
   UNLOCK
ENDIF

STORE DATE() TO MCK_DATE
SET PROC TO REC_PROC
MTOTAL = 0
MSW_DIFF = 0
STORE 2 TO MACTION
STORE 'L' TO MCHOICE
DO WHILE MACTION = 2 
   @ 8,5 SAY 'SELECT ONE OF THE FOLLOWING PAYMENT TYPES: ' get mchoice picture '@!'
   **@ 10,5 SAY '  1. Checks (C) - Old Format      Laser Checks (L) - New Format'
   @ 10,5 SAY '  1. Laser Checks (L) '
   @ 11,5 say '  2. Wires  (W)'
   @ 12,5 say '  3. No Payment - Process Debits/Credits (N) '
   @ 13,5 say '     (Note: Total of Debits/Credits to each Supplier must be ZERO!)'
   MACTION = 1
   @ 24,1 say 'Action: ' + str(maction,1)
   @ 24,13 say '1. Continue      2. Edit      3. Cancel'
   READ
   @ 24,9 get maction PICTURE '9' range 1,3
   READ
   IF MACTION = 1
      IF MCHOICE <> 'W' .AND. MCHOICE <> 'N' .AND. MCHOICE <> 'L'
         @ 24,0 CLEAR
         STORE 'ABOVE CHOICE MUST BE A "C" OR "W" OR "N" OR "L" - PRESS RETURN TO REENTER' TO MMSG
         STORE 'ABOVE CHOICE MUST BE A "W" OR "N" OR "L" - PRESS RETURN TO REENTER' TO MMSG
         @ 24,1 GET MMSG
         READ
         MACTION = 2
      ENDIF
   ENDIF
ENDDO
IF MACTION = 3
   CLOSE DATA
   IF MPROG_CODE = 1
      SELECT A
      DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.
   ELSE
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
   ENDIF
   DO FILELOCK
   REPLACE CK_PRINT WITH 'N'
   UNLOCK
   USE
   RETURN
ENDIF
IF MPROG_CODE = 1
   SELECT A
   DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.
ELSE
   SELECT A
   DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
ENDIF
DO CASE
CASE MCHOICE = 'C'
   MCK_NBR = CK_NBR         
CASE MCHOICE = 'L'
   MCK_NBR = LCK_NBR         
CASE MCHOICE = 'W'
   MCK_NBR = WIRE_NBR
OTHERWISE
   MCK_NBR = DC_NBR 
ENDCASE
@ 4,1 CLEAR TO 20,78
STORE 2 TO MACTION
DO WHILE MACTION = 2
   DO CASE
   CASE MCHOICE = 'C' .OR. MCHOICE = 'L'
      @ 8,5 SAY '      Starting Check Number: '
      @ 8,35 GET MCK_NBR PICTURE '######'  
      @ 11,5 SAY '     Enter Date For Checks:' GET mCK_date
   CASE MCHOICE = 'W'
      @ 8,5 SAY '       Starting Wire Number: '
      @ 8,35 SAY MCK_NBR PICTURE '######'  
      @ 11,5 SAY '      Enter Date For Wires:' GET mCK_date
   OTHERWISE
      @ 11,5 SAY 'Enter Debit/Credit Processing Date:' GET MCK_DATE
   ENDCASE
   MACTION = 1
   
   @ 24,1 say 'Action: ' + str(maction,1)
   @ 24,13 say '1. Continue      2. Edit      3. Cancel'
   READ
   @ 24,9 get maction PICTURE '9' range 1,3
   READ
ENDDO

IF MACTION = 3
   CLOSE DATA
   IF MPROG_CODE = 1
      SELECT A
      DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.
   ELSE
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
   ENDIF
   DO FILELOCK
   REPLACE CK_PRINT WITH 'N'
   UNLOCK
   USE
   RETURN
ENDIF

STORE DTOC(MCK_DATE) TO MDATE
STORE SUBSTR(MDATE,1,2) TO MMONTH
STORE SUBSTR(MDATE,4,2) TO MDAY
STORE SUBSTR(MDATE,7) TO MYEAR
IF MCHOICE = 'C' .OR. MCHOICE = 'L'
   STORE ' ' TO MPRT_ACT
   DO PRT_SET 
   IF MPRT_ACT <> 'C'
      CLOSE DATA
      SELECT A
      DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
      DO FILELOCK
      REPLACE CK_PRINT WITH 'N'
      UNLOCK
      USE
      RETURN
   ENDIF 
   SET CONSOLE OFF
   IF FILE("C:\COMPINFO\PRINTERS.DBF")
      SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
   ELSE
      SET PRINT TO LPT1
   ENDIF
   SET DEVICE TO PRINT
   SET PRINT ON
   IF MCHOICE = 'L'
      *** SELECT TRAY 2
      ?? CHR(27) + '&l1H'
   ENDIF
ENDIF

MPRT_ONE = .F.
SELECT F
DO FOX_USE WITH "CK_REG INDEX CK_REG, CK_DATE", .F.
SELECT E
DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
SELECT C
DO FOX_USE WITH "DISBJRN INDEX DISBJRN, DISB_PO, DISBINV, DISBSTR, DISBINQ", .F.
SELECT D
DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.

SELECT B
DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PO_SUP", .F.

SELECT A
DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
DO FILELOCK
MFIRST_TM = .T.

DO CASE
CASE MCHOICE = 'L'
   *** NEW LASER PRINT FORMAT OPTION
   DO WHILE .NOT. EOF()
      IF APRVDFLG <> 'Y'
         SKIP
         LOOP
      ENDIF
      STORE RSUPCODE TO MRSUPCODE
      SELECT E
      SEEK MRSUPCODE
      IF EOF()
         STORE 'SUPPLIER NOT ON FILE' TO MRSUPNAME
         STORE SPACE(1) TO MCITY, MSTATE, MZIP, MSTREET 
      ELSE
         STORE NAME TO MRSUPNAME
         STORE STREET TO MSTREET
         STORE CITY TO MCITY
         STORE STATE TO MSTATE
         STORE ZIP TO MZIP
      ENDIF
      
      MTOT = 0
      MCHK_AMT = 0
      
      I = 1
      DO WHILE I<=13
         MI = SUBSTR(STR(I+100,3),2)
         STORE SPACE(12) TO MSUPINV&MI
         STORE SPACE(2) TO MSALES&MI
         STORE SPACE(5) TO MINV&MI
         STORE CTOD('')   TO MSHIPDT&MI
         STORE 0        TO MDUE&MI, MADJ&MI, MPAID&MI
         I = I + 1
      ENDDO
      
      SELECT A
      I = 1
      DO WHILE .NOT. EOF() .AND. RSUPCODE = MRSUPCODE .AND. I<= 13
         IF APRVDFLG <> 'Y'
            SKIP
            LOOP
         ENDIF
         MI = SUBSTR(STR(I+100,3),2)
         SELECT A
         STORE AMT_DUE TO MAMT_DUE
         IF MAMT_DUE = 0
            MADJ_TOT = 0
            MPALLETS = 0
            IF DEB_CRD =  ' '
               SELECT B
               SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
               IF .NOT. EOF()
                  MADJ_TOT = SUP_AMT1 + SUP_AMT2  - SW_PURCH
                  DO TOTDIFF
                  MADJ_TOT = MADJ_TOT - MSW_DIFF
                  SELECT B
                  IF SUP_PALL < 0
                     MPAID = MAMT_DUE + MADJ_TOT + SUP_PALL
                     STORE SUP_PALL TO MPALLETS
                  ELSE
                     MPAID = MAMT_DUE + MADJ_TOT 
                     STORE SUP_PALL TO MPALLETS
                  ENDIF
               ELSE
                  STORE MAMT_DUE TO MPAID
               ENDIF
            ELSE
               STORE MAMT_DUE TO MPAID
            ENDIF
            
            SELECT A
            IF MPAID = 0
               SELECT A
               DELETE
               SELECT B
               SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
               IF .NOT. EOF()
                  DO RECLOCK
                  REPLACE SUP_PD WITH 'Y'
                  FLUSH
                  UNLOCK
               ENDIF
               IF A->SUP_INV <> SPACE(12)
                  **** ALSO WRITE A RECORD OUT TO CASH DISBURSEMENTS JOURNAL
                  **** TO KEEP TRACK OF SUPPLIER INVOICE NUMBER IF ONE ENTERED
                  SELECT C
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE JRNL_MO WITH MMONTH
                  REPLACE JRNL_YR WITH MYEAR
                  REPLACE JRNL_DAY WITH MDAY
                  REPLACE SALESMAN WITH A->SALESMAN
                  REPLACE INV_NBR WITH A->INV_NBR
                  REPLACE PO_NBR WITH A->PO_NBR
                  REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                  **** FOR PRODUCT INVOICE
                  REPLACE CATEGORY1 WITH 'P'
                  REPLACE ACCT_NBR WITH MRSUPCODE
                  **** FOR THE SUPPLIER
                  REPLACE ACCT_TYPE WITH 'S'
                  REPLACE BILL_INV WITH A->SUP_INV
                  REPLACE SYS_DATE WITH DATE()
                  FLUSH
                  UNLOCK
               ENDIF
               SELECT A
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         SELECT A
         STORE AMT_DUE TO MAMT_DUE
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         STORE SUP_INV TO MSUP_INV
         STORE DEB_CRD TO MDEB_CRD
         
         MSHIPDT&MI = MSHIP_DATE
         MSUPINV&MI = MSUP_INV
         MSALES&MI  = MSALESMAN
         MINV&MI    = INV_NBR
         MDUE&MI    = MAMT_DUE
         
         MADJ_TOT = 0
         MPALLETS = 0
         STORE MAMT_DUE TO MPAID
         SELECT B
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF .NOT. EOF()       
            IF MDEB_CRD = ' '
               MADJ_TOT = SUP_AMT1 + SUP_AMT2  - SW_PURCH
               DO TOTDIFF
               MADJ_TOT = MADJ_TOT - MSW_DIFF
               SELECT B
               IF SUP_PALL < 0
                  MPAID = MAMT_DUE + MADJ_TOT + SUP_PALL
                  STORE SUP_PALL TO MPALLETS
               ELSE
                  MPAID = MAMT_DUE + MADJ_TOT 
                  STORE SUP_PALL TO MPALLETS
               ENDIF
               DO RECLOCK
               REPLACE SUP_PD WITH 'Y'
               FLUSH
               UNLOCK
               STORE (TOT_PURCH + SUP_PALL + BILL_ADJ) - MPAID TO MDIFF
               IF MDIFF < -1000 .OR. MDIFF > 1000
                  SELECT A
                  STORE RECNO() TO MRECNO
                  APPEND BLANK
                  REPLACE RSUPCODE WITH B->RSUPCODE
                  REPLACE SALESMAN WITH B->SALESMAN
                  REPLACE PO_NBR WITH B->PO_NBR
                  REPLACE PO_SUFFIX WITH B->PO_SUFFIX
                  REPLACE INV_NBR WITH B->INV_NBR
                  REPLACE AMT_DUE WITH MDIFF
                  REPLACE DUE_DATE WITH DATE()
                  REPLACE SUP_INV WITH MSUP_INV
                  REPLACE DEB_CRD WITH 'Y'
                  REPLACE ADDL_DUE WITH 'Y'
                  GOTO MRECNO
               ENDIF
            ENDIF
         ENDIF   
         IF B->SUP_PALL < 0
            MADJ&MI = MADJ_TOT + B->SUP_PALL
         ELSE
            MADJ&MI = MADJ_TOT
         ENDIF
         
         MTOT = MTOT + MPAID
         MPAID&MI = MPAID
         
         **** WRITE THIS RECORD OUT TO THE CASH DISBURSEMENTS JOURNAL
         SELECT C
         IF MAMT_DUE + MADJ_TOT <> 0
            DO FILELOCK
            APPEND BLANK
            REPLACE JRNL_MO WITH MMONTH
            REPLACE JRNL_YR WITH MYEAR
            REPLACE JRNL_DAY WITH MDAY
            DO CASE
            CASE MCHOICE = 'C' .OR. MCHOICE = 'L'
               REPLACE CK_NBR WITH STR(MCK_NBR,6)
            CASE MCHOICE = 'W'
               STORE SUBSTR(STR(MCK_NBR + 100000,6),2) TO MWIRE_NBR
               REPLACE CK_NBR WITH 'W' + MWIRE_NBR       
            OTHERWISE
               STORE SUBSTR(STR(MCK_NBR + 10000,5),2) TO MDC_NBR
               REPLACE CK_NBR WITH 'DC' + MDC_NBR         
            ENDCASE
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            IF MPALLETS < 0
               REPLACE AMOUNT1 WITH MAMT_DUE + MADJ_TOT
            ELSE
               REPLACE AMOUNT1 WITH MAMT_DUE + MADJ_TOT - MPALLETS
            ENDIF
            REPLACE ADJUST WITH MADJ_TOT
            
            **** FOR PRODUCT INVOICE
            REPLACE CATEGORY1 WITH 'P'
            REPLACE ACCT_NBR WITH MRSUPCODE
            
            **** FOR THE SUPPLIER
            REPLACE ACCT_TYPE WITH 'S'
            REPLACE BILL_INV WITH MSUP_INV
            REPLACE SYS_DATE WITH DATE()
            FLUSH
            UNLOCK
         ENDIF
         IF MPALLETS <> 0
            DO FILELOCK
            APPEND BLANK
            REPLACE JRNL_MO WITH MMONTH
            REPLACE JRNL_YR WITH MYEAR
            REPLACE JRNL_DAY WITH MDAY
            DO CASE
            CASE MCHOICE = 'C' .OR. MCHOICE = 'L'
               REPLACE CK_NBR WITH STR(MCK_NBR,6)
            CASE MCHOICE = 'W'
               STORE SUBSTR(STR(MCK_NBR + 100000,6),2) TO MWIRE_NBR
               REPLACE CK_NBR WITH 'W' + MWIRE_NBR       
            OTHERWISE
               STORE SUBSTR(STR(MCK_NBR + 10000,5),2) TO MDC_NBR
               REPLACE CK_NBR WITH 'DC' + MDC_NBR         
            ENDCASE
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE AMOUNT1 WITH MPALLETS    
            
            **** FOR FREIGHT    
            REPLACE CATEGORY1 WITH 'F'
            REPLACE ACCT_NBR WITH MRSUPCODE
            
            **** FOR THE SUPPLIER
            REPLACE ACCT_TYPE WITH 'S'
            REPLACE BILL_INV WITH MSUP_INV
            REPLACE SYS_DATE WITH DATE()
            FLUSH
            UNLOCK
         ENDIF
         SELECT A
         DELETE
         I = I + 1
         SKIP
      ENDDO
      
      **** DO THE CHECK REGISTER HERE
      SELECT F
      DO FILELOCK
      APPEND BLANK
      REPLACE PAY_CODE WITH MRSUPCODE
      DO CASE
      CASE MCHOICE = 'C' .OR. MCHOICE = 'L'
         REPLACE CK_NBR WITH STR(MCK_NBR,6)
      CASE MCHOICE = 'W'
         STORE SUBSTR(STR(MCK_NBR + 100000,6),2) TO MWIRE_NBR
         REPLACE CK_NBR WITH 'W' + MWIRE_NBR       
         REPLACE CLEAR_FLG WITH 'Y'
      OTHERWISE
         STORE SUBSTR(STR(MCK_NBR + 10000,5),2) TO MDC_NBR
         REPLACE CK_NBR WITH 'DC' + MDC_NBR         
         REPLACE CLEAR_FLG WITH 'Y'
      ENDCASE
      
      REPLACE CK_DATE WITH MCK_DATE
      REPLACE AMOUNT WITH MTOT
      REPLACE PAY_TYPE WITH 'S' 
      REPLACE SYS_DATE WITH DATE()
      FLUSH
      UNLOCK
      
      SELECT A
      
      MCHK_AMT = MTOT
      
      **** PRINT THE CHECK
      
      *** FONT COURIER
      ?? CHR(27) + '(s4099T'
      
      *** PRINT IN 8 LINES PER IN/VERTICAL
      ?? chr(27) + '&l8D'
      
      *** PRINT IN 10 CPI
      ?? chr(27) + '&k0S'
      
      *** BOLDED PRINT
      ?? CHR(27) + '(s4B'
      
      ? SPACE(63) + 'Check No: ' + STR(MCK_NBR,6)
      ?
      ?
      ?
      
      ?  SPACE(43) + 'Check Date' + space(15) + 'Amount'
      ?  SPACE(43) + MDATE     
      MAMOUNT = '$' + LTRIM(TRANSFORM(MCHK_AMT, "999,999.99"))
      
      ?? SPACE(9)
      ?? SPACE(2+10-LEN(MAMOUNT)) + MAMOUNT
      
      ?
      STORE STR(MCHK_AMT,9,2) TO MTOTC
      
      IF MTOT < 1.00
         IF MTOT > 0.00
            STORE SUBSTR(MTOTC,8,2)+ '/100 Dollars' TO mMTOTstr
         ELSE
            STORE ' Error -- Negative Amount of '+MTOTC TO mMTOTstr
         ENDIF
      ELSE
         STORE '& ' +SUBSTR(MTOTC,8,2)+ '/100 Dollars' TO mMTOTstr
         STORE VAL(SUBSTR(MTOTC,5,2)) TO p
         IF p < 20 .AND. p > 9
            STORE VAL(SUBSTR(MTOTC,6,1)) TO p
            STORE TRIM(SUBSTR('Ten       Eleven    Twelve    Thirteen  Fourteen  ' + ;
               'Fifteen   Sixteen   Seventeen Eighteen  Nineteen    ',p*10+1,10))+' '+ ;
               mMTOTstr TO mMTOTstr
         ELSE
            STORE VAL(SUBSTR(MTOTC,6,1)) TO p
            IF p > 0
               STORE TRIM(SUBSTR('     One  Two  ThreeFour Five Six  '+;
                  'SevenEightNine   ',p*5+1,5))+ ' ' +mMTOTstr TO mMTOTstr
            ENDIF
            STORE VAL(SUBSTR(MTOTC,5,1)) TO p
            IF p > 1
               IF VAL(SUBSTR(MTOTC,6,1)) > 0
                  STORE TRIM(SUBSTR('       Ten    Twenty Thirty Forty  '+;
                     'Fifty  Sixty  SeventyEighty Ninety   ',p*7+1,7))+ '-' +mMTOTstr TO mMTOTstr
               ELSE
                  STORE TRIM(SUBSTR('       Ten    Twenty Thirty Forty  '+;
                     'Fifty  Sixty  SeventyEighty Ninety   ',p*7+1,7))+ ' ' +mMTOTstr TO mMTOTstr
               ENDIF
            ENDIF
         ENDIF
         STORE VAL(SUBSTR(MTOTC,4,1)) TO p
         IF p > 0
            STORE TRIM(SUBSTR('     One  Two  ThreeFour Five Six  Seven'+;
               'EightNine   ',p*5+1,5))+ ' Hundred ' +mMTOTstr TO mMTOTstr
         ENDIF
      ENDIF
      IF MTOT > 999.99
         STORE ' Thousand ' +mMTOTstr TO mMTOTstr
         STORE VAL(SUBSTR(MTOTC,2,2)) TO p
         IF p < 20 .AND. p > 9
            STORE VAL(SUBSTR(MTOTC,3,1)) TO p
            STORE TRIM(SUBSTR('Ten       Eleven    Twelve    Thirteen  Fourteen  '+ ;
               'Fifteen   Sixteen   Seventeen Eighteen  Nineteen    ',p*10+1,10))+ ;
               mMTOTstr TO mMTOTstr
         ELSE
            STORE VAL(SUBSTR(MTOTC,3,1)) TO p
            IF p > 0
               STORE TRIM(SUBSTR('     One  Two  ThreeFour Five Six  Seven'+;
                  'EightNine   ',p*5+1,5))+mMTOTstr TO mMTOTstr
            ENDIF
            STORE VAL(SUBSTR(MTOTC,2,1)) TO p
            IF p > 1
               IF VAL(SUBSTR(MTOTC,3,1)) > 0
                  STORE TRIM(SUBSTR('       Ten    Twenty Thirty Forty  '+;
                     'Fifty  Sixty  SeventyEighty Ninety   ',p*7+1,7))+ '-' +mMTOTstr TO mMTOTstr
               ELSE
                  STORE TRIM(SUBSTR('       Ten    Twenty Thirty Forty  '+;
                     'Fifty  Sixty  SeventyEighty Ninety   ',p*7+1,7))+ ' ' +mMTOTstr TO mMTOTstr
               ENDIF VAL(SUBSTR(MTOTC,3,1)) > 0
            ENDIF
         ENDIF
      ENDIF
      IF MTOT > 99999.99
         STORE VAL(SUBSTR(MTOTC,1,1)) TO p
         STORE TRIM(SUBSTR('     One  Two  ThreeFour Five Six  Seven'+;
            'EightNine   ',p*5+1,5))+ ' Hundred ' +mMTOTstr TO mMTOTstr
      ENDIF
      IF MTOT > 999999.99
         STORE '*************************************** Dollars' ;
            TO mMTOTstr
      ENDIF
      STORE '***'+mMTOTstr TO mMTOTstr
      DO CASE
      CASE MTOT <= 9.99
         STORE '******' + STR(MTOT,4,2) TO mamount
      CASE MTOT <= 99.99
         STORE '*****' + STR(MTOT,5,2) TO mamount
      CASE MTOT <= 999.99
         STORE '****' + STR(MTOT,6,2) TO mamount
      CASE MTOT <= 9999.99
         STORE '***' + SUBSTR(STR(MTOT,7,2),1,1) + ;
            ',' + SUBSTR(STR(MTOT,7,2),2,6) TO mamount
      CASE MTOT <= 99999.99
         STORE '**' + SUBSTR(STR(MTOT,8,2),1,2) + ;
            ',' + SUBSTR(STR(MTOT,8,2),3,6) TO mamount
      CASE MTOT <= 999999.99
         STORE '*' + SUBSTR(STR(MTOT,9,2),1,3) + ;
            ',' + SUBSTR(STR(MTOT,9,2),4,6) TO mamount
      CASE MTOT <= 9999999.99
         STORE SUBSTR(STR(MTOT,10,2),1,4) + ;
            ',' + SUBSTR(STR(MTOT,10,2),5,6) TO mamount
      ENDCASE
      IF MTOT < 0.00
         STORE  '****,***.**' TO mamount
      ENDIF
      IF LEN(TRIM(mMTOTstr)) > 75
         IF LEN(TRIM(MMTOTSTR)) > 90
            *** PRINT IN 16.5 CPI
            ?? chr(27) + '&k2S'
         ELSE
            *** PRINT IN 12 CPI
            ?? chr(27) + '&k4S'
         ENDIF
      ELSE
         *** PRINT IN 10 CPI
         ?? chr(27) + '&k0S'
      ENDIF
      ?
      ? SPACE(5) + mMTOTstr
      
      *** PRINT IN 10 CPI
      ?? chr(27) + '&k0S'
      ? 
      ? 
      ?
      ?
      ? 'Pay' + space(4) + MRSUPNAME
      ? ' To' + SPACE(4) + MSTREET
      ? SPACE(7) + TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
      ?
      
      ?
      ?
      
      *************************
      **** PRINT THE FIRST STUB
      *************************
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      
      *** BACK TO MEDIUM STROKE PRINT
      ?? CHR(27) + '(s0B'
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      ? '       INVOICE NO.  AMERICHICKEN NO.      AMT INVOICED       ADJUSTMENTS      REMITTANCE'
      ?
      I = 1
      MNDX = 1
      
      DO WHILE I<= 13
         MI = SUBSTR(STR(I+100,3),2)
         IF MSUPINV&MI <> SPACE(12) .OR. MDUE&MI <> 0 .OR. MPAID&MI <> 0
            ? SPACE(7) + MSUPINV&MI + SPACE(5)
            IF MSALES&MI <> SPACE(2)
               ?? MSALES&MI + '-'
            ELSE
               ?? SPACE(3)
            ENDIF
            ?? MINV&MI + SPACE(10)
            ?? TRANSFORM(MDUE&MI,  '9,999,999.99') + SPACE(6) 
            ?? TRANSFORM(MADJ&MI, '@Z 9,999,999.99') + SPACE(4)
            ?? TRANSFORM(MPAID&MI, '9,999,999.99')
            MNDX = MNDX + 1
         ENDIF
         I = I + 1
      ENDDO
      ?
      ? SPACE(7) + 'Total Remittance: ' + SPACE(53)
      ?? TRANSFORM(MCHK_AMT,"999,999.99")
      DO WHILE MNDX < 13
         ?
         MNDX = MNDX + 1
      ENDDO
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      **** PRINT THE SECOND STUB
      
      *** PRINT IN 10 CPI
      ?? chr(27) + '&k0S'
      
      ? SPACE(6) + MRSUPNAME       + SPACE(06) + ' Check No:   ' + LTRIM(STR(MCK_NBR,6))
      
      ? SPACE(6) + MSTREET        + SPACE(11)
      
      ?? '    Date:   ' + MDATE
      ? SPACE(6) + TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
      ***? 
      ? space(47) + 'Amount:   '
      MAMOUNT = '$' + LTRIM(TRANSFORM(MCHK_AMT, "999,999.99"))
      ?? MAMOUNT
      ?
      ?
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      ? '       INVOICE NO.  AMERICHICKEN NO.      AMT INVOICED       ADJUSTMENTS      REMITTANCE'
      ?
      I = 1
      MNDX = 1
      
      DO WHILE I<= 13
         MI = SUBSTR(STR(I+100,3),2)
         IF MSUPINV&MI <> SPACE(12) .OR. MDUE&MI <> 0 .OR. MPAID&MI <> 0
            ? SPACE(7) + MSUPINV&MI + SPACE(5)
            IF MSALES&MI <> SPACE(2)
               ?? MSALES&MI + '-'
            ELSE
               ?? SPACE(3)
            ENDIF
            ?? MINV&MI + SPACE(10)
            ?? TRANSFORM(MDUE&MI,  '9,999,999.99') + SPACE(6) 
            ?? TRANSFORM(MADJ&MI, '@Z 9,999,999.99') + SPACE(4)
            ?? TRANSFORM(MPAID&MI, '9,999,999.99')
            MNDX = MNDX + 1
         ENDIF
         I = I + 1
      ENDDO
      ?
      ? SPACE(7) + 'Total Remittance: ' + SPACE(53)
      ?? TRANSFORM(MCHK_AMT,"999,999.99")
      DO WHILE MNDX < 13
         ?
         MNDX = MNDX + 1
      ENDDO
      
      IF LEN(TRIM(mMTOTstr)) > 75
         IF LEN(TRIM(MMTOTSTR)) > 90
            *** PRINT IN 16.5 CPI
            ?? chr(27) + '&k2S'
         ELSE
            *** PRINT IN 12 CPI
            ?? chr(27) + '&k4S'
         ENDIF
      ELSE
         *** PRINT IN 10 CPI
         ?? chr(27) + '&k0S'
      ENDIF
      
      ? SPACE(5) + mMTOTstr
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      IF I < 13
         ?
      ENDIF

      EJECT
      
      MCK_NBR = MCK_NBR + 1
      
   ENDDO
   
OTHERWISE
   **** NOT LASER CHECK PRINT PROCESSING
   DO WHILE .NOT. EOF()
      IF APRVDFLG <> 'Y'
         SKIP
         LOOP
      ENDIF
      STORE RSUPCODE TO MRSUPCODE
      SELECT E
      SEEK MRSUPCODE
      IF EOF()
         STORE 'SUPPLIER NOT ON FILE' TO MRSUPNAME
         STORE SPACE(1) TO MCITY, MSTATE, MZIP, MSTREET, MZIP4
      ELSE
         STORE NAME TO MRSUPNAME
         STORE STREET TO MSTREET
         STORE CITY TO MCITY
         STORE STATE TO MSTATE
         STORE ZIP TO MZIP
         STORE ZIP4 TO MZIP4
      ENDIF
      MLINE = 1
      
      IF MCHOICE = 'C'
         ? SPACE(6) + TRIM(MRSUPNAME) + ', ' + TRIM(MCITY) + ', ' + MSTATE + SPACE(2) + MZIP   
         IF MZIP4 <> ' '
            ?? '-' + MZIP4
         ENDIF
         ? SPACE(80) + 'CHECK NO. ' + STR(MCK_NBR,6)
         ? '      INVOICE NO.  AMERICHICKEN NO.      AMT INVOICED       ADJUSTMENTS      REMITTANCE'
         ?
         MLINE = MLINE + 4
      ENDIF
      MTOT = 0    
      SELECT A
      DO WHILE .NOT. EOF() .AND. RSUPCODE = MRSUPCODE .AND. MLINE <= 17
         IF APRVDFLG <> 'Y'
            SKIP
            LOOP
         ENDIF
         STORE AMT_DUE TO MAMT_DUE
         IF MAMT_DUE = 0
            MADJ_TOT = 0
            MPALLETS = 0
            IF DEB_CRD =  ' '
               SELECT B
               SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
               IF .NOT. EOF()
                  MADJ_TOT = SUP_AMT1 + SUP_AMT2  - SW_PURCH
                  DO TOTDIFF
                  MADJ_TOT = MADJ_TOT - MSW_DIFF
                  SELECT B
                  IF SUP_PALL < 0
                     MPAID = MAMT_DUE + MADJ_TOT + SUP_PALL
                     STORE SUP_PALL TO MPALLETS
                  ELSE
                     MPAID = MAMT_DUE + MADJ_TOT 
                     STORE SUP_PALL TO MPALLETS
                  ENDIF
               ELSE
                  STORE MAMT_DUE TO MPAID
               ENDIF
            ELSE
               STORE MAMT_DUE TO MPAID
            ENDIF
            IF MPAID = 0
               SELECT A
               DELETE
               SELECT B
               SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
               IF .NOT. EOF()
                  DO RECLOCK
                  REPLACE SUP_PD WITH 'Y'
                  FLUSH
                  UNLOCK
               ENDIF
               IF A->SUP_INV <> SPACE(12)
                  **** ALSO WRITE A RECORD OUT TO CASH DISBURSEMENTS JOURNAL
                  **** TO KEEP TRACK OF SUPPLIER INVOICE NUMBER IF ONE ENTERED
                  SELECT C
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE JRNL_MO WITH MMONTH
                  REPLACE JRNL_YR WITH MYEAR
                  REPLACE JRNL_DAY WITH MDAY
                  REPLACE SALESMAN WITH A->SALESMAN
                  REPLACE INV_NBR WITH A->INV_NBR
                  REPLACE PO_NBR WITH A->PO_NBR
                  REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                  **** FOR PRODUCT INVOICE
                  REPLACE CATEGORY1 WITH 'P'
                  REPLACE ACCT_NBR WITH MRSUPCODE
                  **** FOR THE SUPPLIER
                  REPLACE ACCT_TYPE WITH 'S'
                  REPLACE BILL_INV WITH A->SUP_INV
                  REPLACE SYS_DATE WITH DATE()
                  FLUSH
                  UNLOCK
               ENDIF
               SELECT A
               SKIP
               LOOP
            ENDIF
         ENDIF
         SELECT A
         STORE AMT_DUE TO MAMT_DUE
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         STORE SUP_INV TO MSUP_INV
         STORE DEB_CRD TO MDEB_CRD
         IF MCHOICE = 'C'
            ? SPACE(7) + MSUP_INV + SPACE(5)
            IF MSALESMAN <> SPACE(2)
               ?? MSALESMAN + '-'
            ELSE
               ?? SPACE(3)
            ENDIF
            ?? INV_NBR + SPACE(10)
            
            ?? TRANSFORM(MAMT_DUE, '999,999.99') + SPACE(6)
         ENDIF
         MADJ_TOT = 0
         MPALLETS = 0
         STORE MAMT_DUE TO MPAID
         SELECT B
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF .NOT. EOF()       
            IF MDEB_CRD = ' '
               MADJ_TOT = SUP_AMT1 + SUP_AMT2  - SW_PURCH
               DO TOTDIFF
               MADJ_TOT = MADJ_TOT - MSW_DIFF
               SELECT B
               IF SUP_PALL < 0
                  MPAID = MAMT_DUE + MADJ_TOT + SUP_PALL
                  STORE SUP_PALL TO MPALLETS
               ELSE
                  MPAID = MAMT_DUE + MADJ_TOT 
                  STORE SUP_PALL TO MPALLETS
               ENDIF
               DO RECLOCK
               REPLACE SUP_PD WITH 'Y'
               FLUSH
               UNLOCK
               STORE (TOT_PURCH + SUP_PALL + BILL_ADJ) - MPAID TO MDIFF
               IF MDIFF < -5 .OR. MDIFF > 5
                  SELECT A
                  STORE RECNO() TO MRECNO
                  APPEND BLANK
                  REPLACE RSUPCODE WITH B->RSUPCODE
                  REPLACE SALESMAN WITH B->SALESMAN
                  REPLACE PO_NBR WITH B->PO_NBR
                  REPLACE PO_SUFFIX WITH B->PO_SUFFIX
                  REPLACE INV_NBR WITH B->INV_NBR
                  REPLACE AMT_DUE WITH MDIFF
                  REPLACE DUE_DATE WITH DATE()
                  REPLACE SUP_INV WITH MSUP_INV
                  REPLACE DEB_CRD WITH 'Y'
                  REPLACE ADDL_DUE WITH 'Y'
                  GOTO MRECNO
               ENDIF
            ENDIF
         ENDIF   
         IF MCHOICE = 'C'
            IF B->SUP_PALL < 0
               ?? TRANSFORM((MADJ_TOT+B->SUP_PALL), '@Z 999,999.99') + SPACE(9)
            ELSE
               ?? TRANSFORM(MADJ_TOT, '@Z 999,999.99') + SPACE(9)
            ENDIF
         ENDIF
         MTOT = MTOT + MPAID
         IF MCHOICE = 'C'
            ?? TRANSFORM(MPAID, '999,999.99')
         ENDIF
         **** WRITE THIS RECORD OUT TO THE CASH DISBURSEMENTS JOURNAL
         SELECT C
         IF MAMT_DUE + MADJ_TOT <> 0
            DO FILELOCK
            APPEND BLANK
            REPLACE JRNL_MO WITH MMONTH
            REPLACE JRNL_YR WITH MYEAR
            REPLACE JRNL_DAY WITH MDAY
            DO CASE
            CASE MCHOICE = 'C'
               REPLACE CK_NBR WITH STR(MCK_NBR,6)
            CASE MCHOICE = 'W'
               STORE SUBSTR(STR(MCK_NBR + 100000,6),2) TO MWIRE_NBR
               REPLACE CK_NBR WITH 'W' + MWIRE_NBR       
            OTHERWISE
               STORE SUBSTR(STR(MCK_NBR + 10000,5),2) TO MDC_NBR
               REPLACE CK_NBR WITH 'DC' + MDC_NBR         
            ENDCASE
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            IF MPALLETS < 0
               REPLACE AMOUNT1 WITH MAMT_DUE + MADJ_TOT
            ELSE
               REPLACE AMOUNT1 WITH MAMT_DUE + MADJ_TOT - MPALLETS
            ENDIF
            REPLACE ADJUST WITH MADJ_TOT
            
            **** FOR PRODUCT INVOICE
            REPLACE CATEGORY1 WITH 'P'
            REPLACE ACCT_NBR WITH MRSUPCODE
            
            **** FOR THE SUPPLIER
            REPLACE ACCT_TYPE WITH 'S'
            REPLACE BILL_INV WITH MSUP_INV
            REPLACE SYS_DATE WITH DATE()
            FLUSH
            UNLOCK
         ENDIF
         IF MPALLETS <> 0
            DO FILELOCK
            APPEND BLANK
            REPLACE JRNL_MO WITH MMONTH
            REPLACE JRNL_YR WITH MYEAR
            REPLACE JRNL_DAY WITH MDAY
            DO CASE
            CASE MCHOICE = 'C'
               REPLACE CK_NBR WITH STR(MCK_NBR,6)
            CASE MCHOICE = 'W'
               STORE SUBSTR(STR(MCK_NBR + 100000,6),2) TO MWIRE_NBR
               REPLACE CK_NBR WITH 'W' + MWIRE_NBR       
            OTHERWISE
               STORE SUBSTR(STR(MCK_NBR + 10000,5),2) TO MDC_NBR
               REPLACE CK_NBR WITH 'DC' + MDC_NBR         
            ENDCASE
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE AMOUNT1 WITH MPALLETS    
            
            **** FOR FREIGHT    
            REPLACE CATEGORY1 WITH 'F'
            REPLACE ACCT_NBR WITH MRSUPCODE
            
            **** FOR THE SUPPLIER
            REPLACE ACCT_TYPE WITH 'S'
            REPLACE BILL_INV WITH MSUP_INV
            REPLACE SYS_DATE WITH DATE()
            FLUSH
            UNLOCK
         ENDIF
         SELECT A
         DELETE
         MLINE = MLINE + 1
         SKIP
      ENDDO
      ***** NOW SKIP DOWN SO MANY LINES TO GET TO THE BOTTOM OF THE STUB AND READY TO PRINT
      STORE STR(MTOT,9,2) TO MTOTC
      IF MCHOICE = 'C'
         IF MPROG_CODE = 1
            DO WHILE MLINE <= 21
               ?
               MLINE = MLINE + 1
            ENDDO
            DO CASE
            CASE MCOMPANY = 'DIV'
               ? SPACE(36) + 'DIV: ' + SUBSTR(MCOMPANY,10,2)
            CASE MCOMPANY = 'MIDWEST FOOD -DIV 11'
               ? SPACE(36) + 'DIV: 11'
            CASE MCOMPANY = 'AMERICHICKEN, INC'
               **? SPACE(36) + 'DIV: AM'
               ?
            OTHERWISE
               ? SPACE(36) + 'DIV: 01'
            ENDCASE
            ?
            ?
            ?
         ELSE
            DO WHILE MLINE <= 25
               ?
               MLINE = MLINE + 1
            ENDDO
         ENDIF
         IF MTOT < 1.00
            IF MTOT > 0.00
               STORE SUBSTR(MTOTC,8,2)+ '/100 Dollars' TO mMTOTstr
            ELSE
               STORE ' Error -- Negative Amount of '+MTOTC TO mMTOTstr
            ENDIF
         ELSE
            STORE '& ' +SUBSTR(MTOTC,8,2)+ '/100 Dollars' TO mMTOTstr
            STORE VAL(SUBSTR(MTOTC,5,2)) TO p
            IF p < 20 .AND. p > 9
               STORE VAL(SUBSTR(MTOTC,6,1)) TO p
               STORE TRIM(SUBSTR('Ten       Eleven    Twelve    Thirteen  Fourteen  ' + ;
                  'Fifteen   Sixteen   Seventeen Eighteen  Nineteen    ',p*10+1,10))+' '+ ;
                  mMTOTstr TO mMTOTstr
            ELSE
               STORE VAL(SUBSTR(MTOTC,6,1)) TO p
               IF p > 0
                  STORE TRIM(SUBSTR('     One  Two  ThreeFour Five Six  '+;
                     'SevenEightNine   ',p*5+1,5))+ ' ' +mMTOTstr TO mMTOTstr
               ENDIF
               STORE VAL(SUBSTR(MTOTC,5,1)) TO p
               IF p > 1
                  IF VAL(SUBSTR(MTOTC,6,1)) > 0
                     STORE TRIM(SUBSTR('       Ten    Twenty Thirty Forty  '+;
                        'Fifty  Sixty  SeventyEighty Ninety   ',p*7+1,7))+ '-' +mMTOTstr TO mMTOTstr
                  ELSE
                     STORE TRIM(SUBSTR('       Ten    Twenty Thirty Forty  '+;
                        'Fifty  Sixty  SeventyEighty Ninety   ',p*7+1,7))+ ' ' +mMTOTstr TO mMTOTstr
                  ENDIF
               ENDIF
            ENDIF
            STORE VAL(SUBSTR(MTOTC,4,1)) TO p
            IF p > 0
               STORE TRIM(SUBSTR('     One  Two  ThreeFour Five Six  Seven'+;
                  'EightNine   ',p*5+1,5))+ ' Hundred ' +mMTOTstr TO mMTOTstr
            ENDIF
         ENDIF
         IF MTOT > 999.99
            STORE ' Thousand ' +mMTOTstr TO mMTOTstr
            STORE VAL(SUBSTR(MTOTC,2,2)) TO p
            IF p < 20 .AND. p > 9
               STORE VAL(SUBSTR(MTOTC,3,1)) TO p
               STORE TRIM(SUBSTR('Ten       Eleven    Twelve    Thirteen  Fourteen  '+ ;
                  'Fifteen   Sixteen   Seventeen Eighteen  Nineteen    ',p*10+1,10))+ ;
                  mMTOTstr TO mMTOTstr
            ELSE
               STORE VAL(SUBSTR(MTOTC,3,1)) TO p
               IF p > 0
                  STORE TRIM(SUBSTR('     One  Two  ThreeFour Five Six  Seven'+;
                     'EightNine   ',p*5+1,5))+mMTOTstr TO mMTOTstr
               ENDIF
               STORE VAL(SUBSTR(MTOTC,2,1)) TO p
               IF p > 1
                  IF VAL(SUBSTR(MTOTC,3,1)) > 0
                     STORE TRIM(SUBSTR('       Ten    Twenty Thirty Forty  '+;
                        'Fifty  Sixty  SeventyEighty Ninety   ',p*7+1,7))+ '-' +mMTOTstr TO mMTOTstr
                  ELSE
                     STORE TRIM(SUBSTR('       Ten    Twenty Thirty Forty  '+;
                        'Fifty  Sixty  SeventyEighty Ninety   ',p*7+1,7))+ ' ' +mMTOTstr TO mMTOTstr
                  ENDIF VAL(SUBSTR(MTOTC,3,1)) > 0
               ENDIF
            ENDIF
         ENDIF
         IF MTOT > 99999.99
            STORE VAL(SUBSTR(MTOTC,1,1)) TO p
            STORE TRIM(SUBSTR('     One  Two  ThreeFour Five Six  Seven'+;
               'EightNine   ',p*5+1,5))+ ' Hundred ' +mMTOTstr TO mMTOTstr
         ENDIF
         IF MTOT > 999999.99
            STORE '*************************************** Dollars' ;
               TO mMTOTstr
         ENDIF
         STORE '***'+mMTOTstr TO mMTOTstr
         DO CASE
         CASE MTOT <= 9.99
            STORE '******' + STR(MTOT,4,2) TO mamount
         CASE MTOT <= 99.99
            STORE '*****' + STR(MTOT,5,2) TO mamount
         CASE MTOT <= 999.99
            STORE '****' + STR(MTOT,6,2) TO mamount
         CASE MTOT <= 9999.99
            STORE '***' + SUBSTR(STR(MTOT,7,2),1,1) + ;
               ',' + SUBSTR(STR(MTOT,7,2),2,6) TO mamount
         CASE MTOT <= 99999.99
            STORE '**' + SUBSTR(STR(MTOT,8,2),1,2) + ;
               ',' + SUBSTR(STR(MTOT,8,2),3,6) TO mamount
         CASE MTOT <= 999999.99
            STORE '*' + SUBSTR(STR(MTOT,9,2),1,3) + ;
               ',' + SUBSTR(STR(MTOT,9,2),4,6) TO mamount
         CASE MTOT <= 9999999.99
            STORE SUBSTR(STR(MTOT,10,2),1,4) + ;
               ',' + SUBSTR(STR(MTOT,10,2),5,6) TO mamount
         ENDCASE
         IF MTOT < 0.00
            STORE  '****,***.**' TO mamount
         ENDIF
         ? SPACE(8) + mMTOTstr
         MLINE = MLINE + 1
         ?
         ?
         Mline = MLine + 2
         ? SPACE(62) + mdate + SPACE(11) + mamount
         Mline = Mline + 1
         ?
         ?
         ? SPACE(8) + TRIM(MRSUPNAME)
         ? SPACE(8) + TRIM(MSTREET)
         ? SPACE(8) + TRIM(MCITY) + ', ' + MSTATE + SPACE(2) + MZIP   
         IF MZIP4 <> ' '
            ?? '-' + MZIP4
         ENDIF
         MLINE = MLINE + 5
         X = 1
         DO WHILE X <= 8
            ?
            X = X + 1
         ENDDO
      ENDIF
      **** DO THE CHECK REGISTER HERE
      SELECT F
      DO FILELOCK
      APPEND BLANK
      REPLACE PAY_CODE WITH MRSUPCODE
      DO CASE
      CASE MCHOICE = 'C'
         REPLACE CK_NBR WITH STR(MCK_NBR,6)
      CASE MCHOICE = 'W'
         STORE SUBSTR(STR(MCK_NBR + 100000,6),2) TO MWIRE_NBR
         REPLACE CK_NBR WITH 'W' + MWIRE_NBR       
         REPLACE CLEAR_FLG WITH 'Y'
      OTHERWISE
         STORE SUBSTR(STR(MCK_NBR + 10000,5),2) TO MDC_NBR
         REPLACE CK_NBR WITH 'DC' + MDC_NBR         
         REPLACE CLEAR_FLG WITH 'Y'
      ENDCASE
      
      REPLACE CK_DATE WITH MCK_DATE
      REPLACE AMOUNT WITH MTOT
      REPLACE PAY_TYPE WITH 'S' 
      REPLACE SYS_DATE WITH DATE()
      FLUSH
      UNLOCK
      SELECT A
      MCK_NBR = MCK_NBR + 1
   ENDDO
   
ENDCASE

CLOSE DATA
IF MPROG_CODE = 1
   SELECT A
   DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.
ELSE
   SELECT A
   DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
ENDIF

DO FILELOCK
DO CASE
CASE MCHOICE = 'C'
   REPLACE CK_NBR WITH MCK_NBR
CASE MCHOICE = 'L'
   REPLACE LCK_NBR WITH MCK_NBR
CASE MCHOICE = 'W'
   REPLACE WIRE_NBR WITH MCK_NBR
OTHERWISE          
   REPLACE DC_NBR WITH MCK_NBR
ENDCASE
REPLACE CK_PRINT WITH 'N'
UNLOCK

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON

IF MCHOICE = 'C'
   IF MPRINTER <> 'DONOTPRINT'
      RUN &MPRINTIT
   ENDIF
ELSE
   IF MCHOICE = 'L'
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
   ENDIF
ENDIF

CLOSE DATA
RETURN
* EOF: SUP_CHK.PRG

*Formatted by: ToolBox Ver. 1.2  on 1/5/16 at 10:21 AM.
