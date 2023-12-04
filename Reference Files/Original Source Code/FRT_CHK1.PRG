**********
* Program.: FRT_CHK1.PRG
* Author..: Grace Keller
* Date....: 05/01978
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Notes...: PRINT FREIGHT CHECKS - AUTO APPROVE
*
IF MMASTDBF = '\AMERICO\'
   TEMPMAST = '\AMERICO\'
ELSE
   TEMPMAST = '\BROKER\'
ENDIF
MTITLE = ' - PRINT FREIGHT CARRIER CHECKS'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 23,79
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
   @ 12,5 get MMSG2
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

********************
**** NEW - 05/01/97
********************
STORE 2 TO MACTION
STORE ' ' TO MSEL1, MSEL2
STORE DATE() TO MFRT_DATE
MCHOICE = 'L'
DO WHILE MACTION = 2
   @ 05,5 SAY 'Select with an "X" ONLY ONE of the following print options'
   @ 08,2 SAY '1.      Automatically approve/print checks that are due by ' 
   @ 11,2 SAY '2.      Print checks for freight bills manually approved'
   @ 8,5 GET MSEL1 PICTURE '@!'
   @ 8,62 GET MFRT_DATE
   @ 11,5 GET MSEL2
   
   **@ 14,5 SAY 'Select Check Type: ' get mchoice picture '@!'
   **@ 15,5 SAY 'Checks (C) - Old Format   -OR-   Laser Checks (L) - New Format'
   
   MACTION = 1
   @ 24,1 say 'Action: ' + str(maction,1)
   @ 24,13 say '1. Continue      2. Edit      3. Cancel'
   READ
   @ 24,9 get maction PICTURE '9' range 1,3
   READ
   
   IF MACTION = 1
      **IF MCHOICE <> 'L' .AND. MCHOICE <> 'C'
      **   @ 24,0 CLEAR
      **   STORE 'CHECK CHOICE MUST BE A "C" OR "L" - PRESS RETURN TO REENTER' TO MMSG
      **   @ 24,1 GET MMSG
      **   READ
      **   MACTION = 2
      **   @ 24,0 CLEAR
      **   LOOP
      **ENDIF
      
      IF MSEL1 = 'X'
         IF MFRT_DATE = CTOD('')
            @ 24,0 CLEAR
            MWAIT = ' '
            @ 24,1 SAY 'AUTO APPROVE SELECTED- BUT NO DATE ENTERED - PRESS RETURN ' GET MWAIT
            READ
            MACTION = 2 
            @ 24,0 CLEAR
            LOOP
         ENDIF
         IF MFRT_DATE < DATE() - 7 .OR. MFRT_DATE > DATE() + 7
            @ 24,0 CLEAR
            MWAIT = ' '
            @ 24,1 SAY 'AUTO APPROVE SELECTED- BUT INVALID DATE ENTERED - PRESS RETURN ' GET MWAIT
            READ
            MACTION = 2 
            @ 24,0 CLEAR
            LOOP
         ENDIF
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
@ 4,1 CLEAR TO 22,78
IF MCHOICE = 'C'
   STORE CK_NBR TO MCK_NBR
ELSE
   STORE LCK_NBR TO MCK_NBR
ENDIF
MTOTAL = 0
STORE DATE() TO MCK_DATE
SET PROC TO REC_PROC
STORE 2 to maction
DO WHILE MACTION = 2
   @ 8,5 SAY '      Starting Check Number: '
   @ 9,5 SAY '      (or 0 to Cancel)'  
   @ 8,35 GET MCK_NBR PICTURE '######'  
   @ 11,5 SAY '     Enter Date For Checks:' GET mCK_date
   MACTION = 1
   @ 24,1 say 'Action: ' + str(maction,1)
   @ 24,13 say '1. Continue      2. Edit      3. Cancel'
   READ
   @ 24,9 get maction PICTURE '9' range 1,3
   READ
ENDDO

IF MACTION = 3 .OR. MCK_NBR = 0
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
STORE ' ' TO MPRT_ACT
DO PRT_SET 
IF MPRT_ACT <> 'C'
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
*** IF ALL THE WAY DOWN TO HERE - DO AUTO APPROVE
IF MSEL1 = 'X'
   DO AUTO_FRT
ENDIF
MPRT_ONE = .F.

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

SELECT D
DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
SELECT B
DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PO_FRT", .F.
SELECT A
DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
MFIRST_TM = .T.

IF MCHOICE = 'C'
   
   DO WHILE .NOT. EOF()
      IF APRVDFLG <> 'Y'
         SKIP
         LOOP
      ENDIF
      STORE FRT_CODE TO MFRT_CODE
      STORE AMT_DUE TO MAMT_DUE
      SELECT D
      SEEK MFRT_CODE
      
      IF EOF()
         STORE 'FREIGHT NOT ON FILE' TO MNAME
         STORE SPACE(1) TO MCITY, MSTATE, MZIP, MSTREET, MZIP4
      ELSE
         IF PAY_NAME <> SPACE(20)
            STORE PAY_NAME TO MNAME     
            STORE PAY_STRT TO MSTREET
            STORE PAY_CITY TO MCITY
            STORE PAY_STATE TO MSTATE
            STORE PAY_ZIP TO MZIP
            STORE PAY_ZIP4 TO MZIP4
         ELSE
            STORE NAME TO MNAME
            STORE STREET TO MSTREET
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            STORE ZIP TO MZIP
            STORE ZIP4 TO MZIP4
         ENDIF
      ENDIF
      
      MLINE = 1
      ? SPACE(6) + TRIM(MNAME) + ', ' + TRIM(MCITY) + ', ' + MSTATE + SPACE(2) + MZIP   
      IF MZIP4 <> ' '
         ?? '-' + MZIP4
      ENDIF
      ? SPACE(80) + 'CHECK NO. ' + STR(MCK_NBR,6)
      
      ? '      INVOICE NO.  AMERICHICKEN NO.      AMT INVOICED       ADJUSTMENTS      REMITTANCE'
      ?
      MLINE = MLINE + 4
      
      MTOT = 0
      SELECT A
      DO WHILE .NOT. EOF() .AND. FRT_CODE = MFRT_CODE .AND. MLINE <= 17
         IF APRVDFLG <> 'Y'
            SKIP
            LOOP
         ENDIF
         STORE AMT_DUE TO MAMT_DUE
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         STORE FRT_INV TO MFRT_INV
         STORE DEB_CRD TO MDEB_CRD
         ? SPACE(7) + MFRT_INV + SPACE(5)
         
         
         ? SPACE(7) + MFRT_INV + SPACE(5)
         IF MSALESMAN <> SPACE(2)
            ?? MSALESMAN + '-'
         ELSE
            ?? SPACE(3)
         ENDIF
         ?? INV_NBR + SPACE(10)
         
         ?? TRANSFORM(MAMT_DUE, '999,999.99') + SPACE(7)
         MADJ_TOT = 0
         IF MDEB_CRD <>  ' '
            STORE MAMT_DUE TO MPAID
         ELSE
            DO CASE
            CASE FRT_SEQ = '2'
               SELECT E
               DO FOX_USE WITH "FRT_2ND INDEX FRT2_PO, FRT2_FRT", .F.
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               IF .NOT. EOF()
                  DO RECLOCK
                  REPLACE FRT_PD2 WITH 'Y'
                  UNLOCK
               ENDIF
            CASE FRT_SEQ = '3'
               SELECT E
               DO FOX_USE WITH "FRT_3RD INDEX FRT3_PO, FRT3_FRT", .F.
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               IF .NOT. EOF()
                  DO RECLOCK
                  REPLACE FRT_PD3 WITH 'Y'
                  UNLOCK
               ENDIF
            OTHERWISE
               SELECT B
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               IF .NOT. EOF()
                  MADJ_TOT = FRT1_ADJ1 + FRT1_ADJ2
                  IF FRT_PALL < 0
                     MADJ_TOT = MADJ_TOT + FRT_PALL
                  ENDIF
                  DO RECLOCK
                  REPLACE FRT_PD WITH 'Y'
                  UNLOCK
               ENDIF
            ENDCASE
            MPAID = MAMT_DUE + MADJ_TOT 
         ENDIF
         
         ?? TRANSFORM(MADJ_TOT, '@Z 99,999.99') + SPACE(9)
         MTOT = MTOT + MPAID
         ?? TRANSFORM(MPAID, '999,999.99')
         
         **** WRITE THIS RECORD OUT TO THE CASH DISBURSEMENTS JOURNAL
         IF MAMT_DUE + MADJ_TOT <> 0
            SELECT C
            DO FOX_USE WITH "DISBJRN INDEX DISBJRN, DISB_PO, DISBINV, DISBSTR, DISBINQ", .F.
            
            DO FILELOCK
            APPEND BLANK
            REPLACE JRNL_MO WITH MMONTH
            REPLACE JRNL_YR WITH MYEAR
            REPLACE JRNL_DAY WITH MDAY
            REPLACE CK_NBR WITH STR(MCK_NBR,6)
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE AMOUNT1 WITH MAMT_DUE + MADJ_TOT
            REPLACE ADJUST WITH MADJ_TOT
            
            **** FOR FREIGHT    
            REPLACE CATEGORY1 WITH 'F'
            REPLACE ACCT_NBR WITH MFRT_CODE
            
            **** FOR THE FREIGHT JOURNAL
            REPLACE ACCT_TYPE WITH 'F'
            REPLACE BILL_INV WITH MFRT_INV
            REPLACE SYS_DATE WITH DATE()
            USE   
         ENDIF
         SELECT A
         DELETE
         MLINE = MLINE + 1
         SKIP
      ENDDO
      
      ***** NOW SKIP DOWN SO MANY LINES TO GET TO THE BOTTOM OF THE STUB AND READY TO PRINT
      DO WHILE MLINE <= 25
         ?
         MLINE = MLINE + 1
      ENDDO
      
      STORE STR(MTOT,9,2) TO MTOTC
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
      ? SPACE(8) + TRIM(MNAME)
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
      **** DO THE CHECK REGISTER HERE
      SELECT F
      DO FOX_USE WITH "CK_REG INDEX CK_REG, CK_DATE", .F.
      DO FILELOCK
      APPEND BLANK
      REPLACE PAY_CODE WITH MFRT_CODE   
      REPLACE CK_NBR WITH STR(MCK_NBR,6)
      REPLACE CK_DATE WITH MCK_DATE
      REPLACE AMOUNT WITH MTOT
      REPLACE PAY_TYPE WITH 'F' 
      REPLACE SYS_DATE WITH DATE()
      USE   
      SELECT A
      MCK_NBR = MCK_NBR + 1
   ENDDO
   
ELSE
   *** NEW LASER PRINT CHECK FORMAT
   
   DO WHILE .NOT. EOF()
      IF APRVDFLG <> 'Y'
         SKIP
         LOOP
      ENDIF
      STORE FRT_CODE TO MFRT_CODE
      STORE AMT_DUE TO MAMT_DUE
      SELECT D
      SEEK MFRT_CODE
      
      IF EOF()
         STORE 'FREIGHT NOT ON FILE' TO MNAME
         STORE SPACE(1) TO MCITY, MSTATE, MZIP, MSTREET, MZIP4
      ELSE
         IF PAY_NAME <> SPACE(20)
            STORE PAY_NAME TO MNAME     
            STORE PAY_STRT TO MSTREET
            STORE PAY_CITY TO MCITY
            STORE PAY_STATE TO MSTATE
            STORE PAY_ZIP TO MZIP
            STORE PAY_ZIP4 TO MZIP4
         ELSE
            STORE NAME TO MNAME
            STORE STREET TO MSTREET
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            STORE ZIP TO MZIP
            STORE ZIP4 TO MZIP4
         ENDIF
      ENDIF
      
      MTOT = 0
      MCHK_AMT = 0
      
      
      I = 1
      DO WHILE I<=13
         MI = SUBSTR(STR(I+100,3),2)
         STORE SPACE(12) TO MFRTINV&MI
         STORE SPACE(2) TO MSALES&MI
         STORE SPACE(5) TO MINV&MI
         STORE CTOD('')   TO MSHIPDT&MI
         STORE 0        TO MDUE&MI, MADJ&MI, MPAID&MI
         I = I + 1
      ENDDO
      
      I = 1
      SELECT A
      DO WHILE .NOT. EOF() .AND. FRT_CODE = MFRT_CODE .AND. I <= 13
         IF APRVDFLG <> 'Y'
            SKIP
            LOOP
         ENDIF
         
         MI = SUBSTR(STR(I+100,3),2)
         
         STORE AMT_DUE TO MAMT_DUE, MDUE&MI
         STORE SALESMAN TO MSALESMAN, MSALES&MI
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         STORE INV_NBR   TO MINV&MI
         STORE FRT_INV TO MFRT_INV, MFRTINV&MI
         STORE DEB_CRD TO MDEB_CRD
         MADJ_TOT = 0
         
         IF MDEB_CRD <>  ' '
            STORE MAMT_DUE TO MPAID
         ELSE
            DO CASE
            CASE FRT_SEQ = '2'
               SELECT E
               DO FOX_USE WITH "FRT_2ND INDEX FRT2_PO, FRT2_FRT", .F.
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               IF .NOT. EOF()
                  DO RECLOCK
                  REPLACE FRT_PD2 WITH 'Y'
                  UNLOCK
               ENDIF
            CASE FRT_SEQ = '3'
               SELECT E
               DO FOX_USE WITH "FRT_3RD INDEX FRT3_PO, FRT3_FRT", .F.
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               IF .NOT. EOF()
                  DO RECLOCK
                  REPLACE FRT_PD3 WITH 'Y'
                  UNLOCK
               ENDIF
            OTHERWISE
               SELECT B
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               IF .NOT. EOF()
                  MADJ_TOT = FRT1_ADJ1 + FRT1_ADJ2
                  IF FRT_PALL < 0
                     MADJ_TOT = MADJ_TOT + FRT_PALL
                  ENDIF
                  DO RECLOCK
                  REPLACE FRT_PD WITH 'Y'
                  UNLOCK
               ENDIF
            ENDCASE
            MPAID = MAMT_DUE + MADJ_TOT 
         ENDIF
         
         MADJ&MI = MADJ_TOT
         MPAID&MI = MPAID
         
         MTOT = MTOT + MPAID
         
         **** WRITE THIS RECORD OUT TO THE CASH DISBURSEMENTS JOURNAL
         IF MAMT_DUE + MADJ_TOT <> 0
            SELECT C
            DO FOX_USE WITH "DISBJRN INDEX DISBJRN, DISB_PO, DISBINV, DISBSTR, DISBINQ", .F.
            
            DO FILELOCK
            APPEND BLANK
            REPLACE JRNL_MO WITH MMONTH
            REPLACE JRNL_YR WITH MYEAR
            REPLACE JRNL_DAY WITH MDAY
            REPLACE CK_NBR WITH STR(MCK_NBR,6)
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE AMOUNT1 WITH MAMT_DUE + MADJ_TOT
            REPLACE ADJUST WITH MADJ_TOT
            
            **** FOR FREIGHT    
            REPLACE CATEGORY1 WITH 'F'
            REPLACE ACCT_NBR WITH MFRT_CODE
            
            **** FOR THE FREIGHT JOURNAL
            REPLACE ACCT_TYPE WITH 'F'
            REPLACE BILL_INV WITH MFRT_INV
            REPLACE SYS_DATE WITH DATE()
            USE   
         ENDIF
         SELECT A
         DELETE
         I = I + 1
         SKIP
      ENDDO
      
      **** DO THE CHECK REGISTER HERE
      SELECT F
      DO FOX_USE WITH "CK_REG INDEX CK_REG, CK_DATE", .F.
      DO FILELOCK
      APPEND BLANK
      REPLACE PAY_CODE WITH MFRT_CODE   
      REPLACE CK_NBR WITH STR(MCK_NBR,6)
      REPLACE CK_DATE WITH MCK_DATE
      REPLACE AMOUNT WITH MTOT
      REPLACE PAY_TYPE WITH 'F' 
      REPLACE SYS_DATE WITH DATE()
      USE   
      
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
      ? 'Pay' + space(4) + MNAME
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
      ? '      INVOICE NO.   AMERICHICKEN NO.     AMT INVOICED       ADJUSTMENTS      REMITTANCE'
      ?
      I = 1
      MNDX = 1
      DO WHILE I<= 13
         MI = SUBSTR(STR(I+100,3),2)
         IF MFRTINV&MI <> SPACE(12) .OR. MDUE&MI <> 0 .OR. MPAID&MI <> 0
            ? SPACE(6) + MFRTINV&MI + SPACE(9)
            IF MSALES&MI <> SPACE(2)
               ?? MSALES&MI + '-'
            ELSE
               ?? SPACE(3)
            ENDIF
            ?? MINV&MI + SPACE(8)
            ?? TRANSFORM(MDUE&MI, '999,999.99') + SPACE(6)
            ?? TRANSFORM(MADJ&MI, '@Z 99,999.99') + SPACE(9)
            ?? TRANSFORM(MPAID&MI, '999,999.99')
            MNDX = MNDX + 1
         ENDIF
         I = I + 1
      ENDDO
      
      ?
      ? SPACE(6) + 'Total Remittance: ' + SPACE(53)
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
      ? SPACE(6) + MNAME       + SPACE(06) + ' Check No:   ' + LTRIM(STR(MCK_NBR,6))
      
      ? SPACE(6) + MSTREET        + SPACE(11)
      
      ?? '    Date:   ' + MDATE
      ? SPACE(6) + TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
      ? 
      ? space(47) + 'Amount:   '
      MAMOUNT = '$' + LTRIM(TRANSFORM(MCHK_AMT, "999,999.99"))
      ?? MAMOUNT
      ?
      **?
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      ? '      INVOICE NO.   AMERICHICKEN NO.     AMT INVOICED       ADJUSTMENTS      REMITTANCE'
      ?
      
      I = 1
      MNDX = 1
      DO WHILE I<= 13
         MI = SUBSTR(STR(I+100,3),2)
         IF MFRTINV&MI <> SPACE(12) .OR. MDUE&MI <> 0 .OR. MPAID&MI <> 0
            ? SPACE(6) + MFRTINV&MI + SPACE(9)
            IF MSALES&MI <> SPACE(2)
               ?? MSALES&MI + '-'
            ELSE
               ?? SPACE(3)
            ENDIF
            ?? MINV&MI + SPACE(8)
            ?? TRANSFORM(MDUE&MI, '999,999.99') + SPACE(6)
            ?? TRANSFORM(MADJ&MI, '@Z 99,999.99') + SPACE(9)
            ?? TRANSFORM(MPAID&MI, '999,999.99')
            MNDX = MNDX + 1
         ENDIF
         I = I + 1
      ENDDO
      
      IF MNDX < 13
         ?
      ENDIF
      ? SPACE(6) + 'Total Remittance: ' + SPACE(53)
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
      
      ?
      
      EJECT
      
      MCK_NBR = MCK_NBR + 1
   ENDDO   
   
ENDIF

IF MPROG_CODE = 1
   SELECT A
   DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.
ELSE
   SELECT A
   DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
ENDIF
DO FILELOCK
IF MCHOICE = 'C'
   REPLACE CK_NBR WITH MCK_NBR
ELSE
   REPLACE LCK_NBR WITH MCK_NBR
ENDIF
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
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
ENDIF
CLOSE DATA

RETURN
* EOF: FRT_CHK1.PRG
*Formatted by: ToolBox Ver. 1.2  on 1/5/16 at 10:21 AM.
