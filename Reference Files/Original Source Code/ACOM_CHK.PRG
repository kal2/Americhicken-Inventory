************
* Program.: ACOM_CHK.PRG
* Author..: Grace Keller
* Date....: 05/17/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINT THIRD PARTY COMMISSION CHECKS
*
IF MMASTDBF = '\AMERICO\'
   TEMPMAST = '\AMERICO\'
ELSE
   TEMPMAST = '\BROKER\'
ENDIF
MTITLE = ' - PRINT AMERICHICKEN THIRD PARTY CHECKS'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 22,79
SELECT A
DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.

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

STORE DATE() TO MCK_DATE
MTOTAL = 0
MSW_DIFF = 0
STORE 2 TO MACTION
STORE ' ' TO MCHOICE
DO WHILE MACTION = 2 
   @ 8,5 SAY 'SELECT ONE OF THE FOLLOWING PAYMENT TYPES: ' get mchoice picture '@!'
   **@ 10,5 SAY '  1. Checks (C) - Old Format    Laser Checks (L) - New Format'
   @ 10,5 SAY '  1. Laser Checks (L)'
   @ 11,5 say '  2. Wires        (W)'
   @ 12,5 say '  3. No Payment - Process Debits/Credits (N) '
   @ 13,5 say '     (Note: Total of Debits/Credits to each Third Party must be ZERO!)'
   MACTION = 1
   @ 24,1 say 'Action: ' + str(maction,1)
   @ 24,13 say '1. Continue      2. Edit      3. Cancel'
   READ
   @ 24,9 get maction PICTURE '9' range 1,3
   READ
   IF MACTION = 1
      **IF MCHOICE <> 'C' .AND. MCHOICE <> 'W' .AND. MCHOICE <> 'N' .AND. MCHOICE <> 'L'
      IF MCHOICE <> 'W' .AND. MCHOICE <> 'N' .AND. MCHOICE <> 'L'
         @ 24,0 CLEAR
         **STORE 'ABOVE CHOICE MUST BE A "C" OR "W" OR "N" OR "L" - PRESS RETURN TO REENTER' TO MMSG
         STORE 'ABOVE CHOICE MUST BE A "L" OR "W" OR "N" - PRESS RETURN TO REENTER' TO MMSG
         @ 24,1 GET MMSG
         READ
         MACTION = 2
      ENDIF
   ENDIF
ENDDO
IF MACTION = 3
   CLOSE DATA
   SELECT A
   DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.
   DO FILELOCK
   REPLACE CK_PRINT WITH 'N'
   UNLOCK
   USE
   RETURN
ENDIF
SELECT A
DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.
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
   SELECT A
   DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.
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
      DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.
      DO FILELOCK
      REPLACE CK_PRINT WITH 'N'
      UNLOCK
      USE
      RETURN
   ENDIF 
ENDIF

MPRT_ONE = .F.
SELECT E
DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.

SELECT B
DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.

SELECT A
DO FOX_USE WITH "COMTHD", .T.
INDEX ON COM_PD + LED_CODE TO COMTPD
DO FOX_USE WITH "&MMASTDBF.COMTHD INDEX &MMASTDBF.COMTPD", .F.

SELECT C
DO FOX_USE WITH "&MMASTDBF.DISBJRN INDEX &MMASTDBF.DISBINQ", .F.
SELECT F
DO FOX_USE WITH "&MMASTDBF.CK_REG INDEX &MMASTDBF.CK_REG", .F.

SELECT A

**** PRELIMINARY TO MAKE SURE NO DUPLICATE CHECKS WRITTEN FOR SAME AMOUNTS
SEEK ' '
DO WHILE .NOT. EOF() .AND. COM_PD = ' '
   IF APRVD_FLG <> 'Y' .OR. AMOUNT = 0
      SKIP
      LOOP
   ENDIF
   STORE LED_CODE TO MCOM_CODE
   MTOT = 0    
   DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. LED_CODE = MCOM_CODE 
      IF APRVD_FLG <> 'Y' .OR. AMOUNT = 0
         SKIP
         LOOP
      ENDIF
      MTOT = MTOT + AMOUNT
      SKIP
   ENDDO
   
   SELECT C
   SEEK 'OT '+MCOM_CODE
   IF .NOT. EOF()
      STORE CK_NBR TO MCHK_NBR
      SELECT F
      SEEK MCHK_NBR
      IF .NOT. EOF()
         IF MTOT = AMOUNT
            @ 23,0 CLEAR
            MWAIT = ' '
            @ 23,1 SAY 'Chk To: ' + PAY_NAME + ' For Amt: ' + TRANSFORM(MTOT, '99,999.99') + ' -Same As Last Check'
            @ 24,1 SAY 'Enter "C" to Continue - or "A" to Abort Check Print: ' GET MWAIT PICTURE '@!' VALID(MWAIT = 'A' .OR. MWAIT = 'C')
            READ
            IF MWAIT = 'A'
               CLOSE DATA
               SELECT A
               DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.
               DO FILELOCK
               REPLACE CK_PRINT WITH 'N'
               UNLOCK
               USE
               CLOSE DATA
               RETURN
            ELSE
               @ 23,0 CLEAR
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   SELECT A
ENDDO
SELECT C
USE
SELECT F
USE

IF MCHOICE = 'C' .OR. MCHOICE = 'L'
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
SELECT A

MFIRST_TM = .T.
SEEK ' '
DO WHILE .NOT. EOF() .AND. COM_PD = ' '
   IF APRVD_FLG <> 'Y' .OR. AMOUNT = 0
      SKIP
      LOOP
   ENDIF
   STORE LED_CODE TO MCOM_CODE
   SELECT E
   SEEK MCOM_CODE
   IF EOF()
      STORE 'NAME NOT ON FILE' TO MNAME
      STORE SPACE(1) TO MSTREET, MCITY, MSTATE, MZIP, MBILL_BACK
   ELSE
      STORE NAME TO MNAME
      STORE STREET TO MSTREET
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
      STORE ZIP TO MZIP
      STORE BILL_BACK TO MBILL_BACK
   ENDIF
   SELECT A
   MTOT_OTHER = 0
   MTOT = 0    
   
   DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. LED_CODE = MCOM_CODE
      IF APRVD_FLG <> 'Y' .OR. AMOUNT = 0
         SKIP
         LOOP
      ENDIF
      
      STORE AMOUNT TO MAMOUNT
      MTOT = MTOT + MAMOUNT
      MTOT_OTHER = MTOT_OTHER + MAMOUNT
      DO RECLOCK
      **REPLACE CK_NBR WITH STR(MCK_NBR,6)
      
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
      
      UNLOCK
      
      SELECT C
      DO FOX_USE WITH "&MMASTDBF.DISBJRN INDEX &MMASTDBF.DISBJRN, &MMASTDBF.DISB_PO, &MMASTDBF.DISBINV, &MMASTDBF.DISBSTR, &MMASTDBF.DISBINQ", .F.
      DO FILELOCK
      APPEND BLANK
      REPLACE JRNL_MO WITH MMONTH
      REPLACE JRNL_YR WITH MYEAR
      REPLACE JRNL_DAY WITH MDAY
      ***REPLACE CK_NBR WITH STR(MCK_NBR,6)
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
      REPLACE AMOUNT1 WITH A->AMOUNT
      REPLACE CATEGORY1 WITH '7150'      
      REPLACE ACCT_NBR WITH 'T '+ A->COM_CODE
      REPLACE ACCT_TYPE WITH 'O'
      REPLACE SYS_DATE WITH DATE()
      REPLACE ACCT_NAME WITH MNAME
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE PO_NBR   WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE INV_NBR   WITH A->INV_NBR
      UNLOCK
      
      SELECT A
      SKIP
   ENDDO
   
   *** NOW LOOK FOR ANY MISC ADJUSTMENTS/DEDUCTIONS
   STORE SPACE(4) TO MCATEGORY2, MCATEGORY3, MCATEGORY4, MCATEGORY5
   STORE 0 TO MAMOUNT2, MAMOUNT3, MAMOUNT4, MAMOUNT5
   STORE SPACE(25) TO MDESC2, MDESC3, MDESC4, MDESC5
   STORE MTOT TO MAMOUNT1
   STORE '7150' TO MCATEGORY1
   STORE 'CONSULTING FEE ' + SPACE(10) TO MDESC1
   
   SELECT D
   DO FOX_USE WITH "THD_ADJ INDEX THD_ADJ", .F.
   SEEK 'T' + MCOM_CODE
   IF .NOT. EOF()
      I = 1   
      IF AMOUNT1 <> 0
         I = I + 1
         MI = STR(I,1)
         STORE AMOUNT1 TO MAMOUNT&MI
         STORE ACCOUNT1 TO MCATEGORY&MI
      ENDIF
      
      IF AMOUNT2 <> 0
         I = I + 1
         MI = STR(I,1)
         STORE AMOUNT2 TO MAMOUNT&MI
         STORE ACCOUNT2 TO MCATEGORY&MI
      ENDIF
      
      IF AMOUNT3 <> 0
         I = I + 1
         MI = STR(I,1)
         STORE AMOUNT3 TO MAMOUNT&MI
         STORE ACCOUNT3 TO MCATEGORY&MI
      ENDIF
      
      IF AMOUNT4 <> 0
         I = I + 1
         MI = STR(I,1)
         STORE AMOUNT4 TO MAMOUNT&MI
         STORE ACCOUNT4 TO MCATEGORY&MI
      ENDIF
      DO FILELOCK 
      DELETE 
   ENDIF
   MTOT = MAMOUNT1 + MAMOUNT2 + MAMOUNT3 + MAMOUNT4 + MAMOUNT5
   
   DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
   I = 2
   DO WHILE I<5
      I = I + 1
      MI = STR(I,1)
      IF MCATEGORY&MI <> SPACE(4)
         SEEK MCATEGORY&MI
         IF .NOT. EOF()
            STORE CK_DESC TO MDESC&MI
         ENDIF
      ENDIF
      I = I + 1
   ENDDO
   
   
   MCHK_AMT = MTOT
   *** HERE- CREATE A DIFFERENT PROCEDURE FOR LASER PRINTS
   *** OLD FORMAT EPSON PRINTER
   
   IF MCHOICE = 'C'
      MLINE = 1
      ? SPACE(6) + TRIM(MNAME)
      IF VAL(TRIM(MCITY)) <> 0 .OR. VAL(TRIM(MSTATE)) <> 0
         ?? ', ' + TRIM(MCITY) + ', ' + MSTATE + SPACE(2) + MZIP   
      ENDIF
      ? SPACE(80) + 'CHECK NO. ' + STR(MCK_NBR,6)
      ? SPACE(6) + MDESC1 + SPACE(5) + TRANSFORM(MAMOUNT1, '999,999.99')
      IF MCATEGORY2 <> SPACE(4)
         ? SPACE(6) + MDESC2 + SPACE(5) + TRANSFORM(MAMOUNT2, '999,999.99')
         MLINE = MLINE + 1
      ENDIF
      IF MCATEGORY3 <> SPACE(4)
         ? SPACE(6) + MDESC3 + SPACE(5) + TRANSFORM(MAMOUNT3, '999,999.99')
         MLINE = MLINE + 1
      ENDIF
      IF MCATEGORY4 <> SPACE(4)
         ? SPACE(6) + MDESC4 + SPACE(5) + TRANSFORM(MAMOUNT4, '999,999.99')
         MLINE = MLINE + 1
      ENDIF
      IF MCATEGORY5 <> SPACE(4)
         ? SPACE(6) + MDESC5 + SPACE(5) + TRANSFORM(MAMOUNT5, '999,999.99')
         MLINE = MLINE + 1
      ENDIF
      ?
      MLINE = MLINE + 4
      
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
      MLINE = MLINE + 5
      X = 1
      DO WHILE X <= 8
         ?
         X = X + 1
      ENDDO
   ELSE
      
      *** DO THE NEW LASER PRINT CHECK FORMAT
      
      IF MCHOICE = 'L'
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
         
         ?
         ?
         
         *** BACK TO MEDIUM STROKE PRINT
         ?? CHR(27) + '(s0B'
         
         ? SPACE(6) + MDESC1 + SPACE(23) + TRANSFORM(MAMOUNT1, '999,999.99')
         IF MCATEGORY2 <> SPACE(4)
            ? SPACE(6) + MDESC2 + SPACE(23) + TRANSFORM(MAMOUNT2, '999,999.99')
         ELSE
            ?
         ENDIF
         IF MCATEGORY3 <> SPACE(4)
            ? SPACE(6) + MDESC3 + SPACE(23) + TRANSFORM(MAMOUNT3, '999,999.99')
         ELSE
            ?
         ENDIF
         IF MCATEGORY4 <> SPACE(4)
            ? SPACE(6) + MDESC4 + SPACE(23) + TRANSFORM(MAMOUNT4, '999,999.99')
         ELSE
            ?
         ENDIF
         IF MCATEGORY5 <> SPACE(4)
            ? SPACE(6) + MDESC5 + SPACE(23) + TRANSFORM(MAMOUNT5, '999,999.99')
         ELSE
            ?
         ENDIF
         
         ?
         IF MCHK_AMT = MAMOUNT1
            ?
         ELSE
            ? SPACE(6) + 'Total Remittance: ' + SPACE(32)
            ?? TRANSFORM(MCHK_AMT,"999,999.99")
         ENDIF
         
         MNDX = 1
         DO WHILE MNDX < 8
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
         ?
         
         ?
         ?
         
         ? SPACE(6) + MDESC1 + SPACE(23) + TRANSFORM(MAMOUNT1, '999,999.99')
         IF MCATEGORY2 <> SPACE(4)
            ? SPACE(6) + MDESC2 + SPACE(23) + TRANSFORM(MAMOUNT2, '999,999.99')
         ELSE
            ?
         ENDIF
         IF MCATEGORY3 <> SPACE(4)
            ? SPACE(6) + MDESC3 + SPACE(23) + TRANSFORM(MAMOUNT3, '999,999.99')
         ELSE
            ?
         ENDIF
         IF MCATEGORY4 <> SPACE(4)
            ? SPACE(6) + MDESC4 + SPACE(23) + TRANSFORM(MAMOUNT4, '999,999.99')
         ELSE
            ?
         ENDIF
         IF MCATEGORY5 <> SPACE(4)
            ? SPACE(6) + MDESC5 + SPACE(23) + TRANSFORM(MAMOUNT5, '999,999.99')
         ELSE
            ?
         ENDIF
         
         ?
         IF MCHK_AMT = MAMOUNT1
            ?
         ELSE
            ? SPACE(6) + 'Total Remittance: ' + SPACE(32)
            ?? TRANSFORM(MCHK_AMT,"999,999.99")
         ENDIF
         
         MNDX = 1
         DO WHILE MNDX < 8
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
      ENDIF
      
   ENDIF
   
   
   **** DO THE CHECK REGISTER HERE
   SELECT F
   DO FOX_USE WITH "&MMASTDBF.CK_REG INDEX &MMASTDBF.CK_REG, &MMASTDBF.CK_DATE", .F.
   DO FILELOCK
   APPEND BLANK
   REPLACE PAY_CODE WITH 'T ' + MCOM_CODE
   REPLACE PAY_NAME WITH MNAME        
   **REPLACE CK_NBR WITH STR(MCK_NBR,6)
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
   REPLACE PAY_TYPE WITH 'O' 
   REPLACE DESCRIP WITH 'COMMISSIONS'
   REPLACE SYS_DATE WITH DATE()
   UNLOCK
   **** DONE WITH CHECK REGISTER
   **** FINISH UP DISBURSEMENT REGISTER
   SELECT C
   IF MAMOUNT2 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE JRNL_MO WITH MMONTH
      REPLACE JRNL_YR WITH MYEAR
      REPLACE JRNL_DAY WITH MDAY
      **REPLACE CK_NBR WITH STR(MCK_NBR,6)
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
      REPLACE AMOUNT1 WITH MAMOUNT2
      REPLACE CATEGORY1 WITH MCATEGORY2 
      REPLACE ACCT_NBR WITH 'T '+ A->COM_CODE
      REPLACE ACCT_TYPE WITH 'O'
      REPLACE SYS_DATE WITH DATE()
      REPLACE ACCT_NAME WITH MNAME
      UNLOCK
   ENDIF
   IF MAMOUNT3 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE JRNL_MO WITH MMONTH
      REPLACE JRNL_YR WITH MYEAR
      REPLACE JRNL_DAY WITH MDAY
      **REPLACE CK_NBR WITH STR(MCK_NBR,6)
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
      REPLACE AMOUNT1 WITH MAMOUNT3
      REPLACE CATEGORY1 WITH MCATEGORY3 
      REPLACE ACCT_NBR WITH 'T '+ A->COM_CODE
      REPLACE ACCT_TYPE WITH 'O'
      REPLACE SYS_DATE WITH DATE()
      REPLACE ACCT_NAME WITH MNAME
      UNLOCK
   ENDIF
   IF MAMOUNT4 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE JRNL_MO WITH MMONTH
      REPLACE JRNL_YR WITH MYEAR
      REPLACE JRNL_DAY WITH MDAY
      **REPLACE CK_NBR WITH STR(MCK_NBR,6)
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
      REPLACE AMOUNT1 WITH MAMOUNT4
      REPLACE CATEGORY1 WITH MCATEGORY4 
      REPLACE ACCT_NBR WITH 'T '+ A->COM_CODE
      REPLACE ACCT_TYPE WITH 'O'
      REPLACE SYS_DATE WITH DATE()
      REPLACE ACCT_NAME WITH MNAME
      UNLOCK
   ENDIF
   IF MAMOUNT5 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE JRNL_MO WITH MMONTH
      REPLACE JRNL_YR WITH MYEAR
      REPLACE JRNL_DAY WITH MDAY
      **REPLACE CK_NBR WITH STR(MCK_NBR,6)
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
      REPLACE AMOUNT1 WITH MAMOUNT5
      REPLACE CATEGORY1 WITH MCATEGORY5 
      REPLACE ACCT_NBR WITH 'T '+ A->COM_CODE
      REPLACE ACCT_TYPE WITH 'O'
      REPLACE SYS_DATE WITH DATE()
      REPLACE ACCT_NAME WITH MNAME
      UNLOCK
   ENDIF
   
   SELECT A
   MCK_NBR = MCK_NBR + 1
ENDDO
IF MCHOICE = 'C' .OR. MCHOICE = 'L'
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
ENDIF
SELECT A
DO FOX_USE WITH "&TEMPMAST.CONTROL", .F.
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


SELECT A

DO FOX_USE WITH "COMTHD", .T.
DO WHILE .NOT. EOF()
   IF COM_PD = 'Y' 
      SKIP
      LOOP
   ENDIF
   IF APRVD_FLG = 'Y'
      *DO FILELOCK 
      REPLACE COM_PD WITH 'Y'
      REPLACE PAID_DATE WITH DATE()
      *UNLOCK
   ENDIF
   SKIP
ENDDO
INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + THD_SEQ + COM_PD + COR_FLG + SEQ TO COMTHD
INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + THD_SEQ + COM_PD+ STR(YEAR(TRAN_DATE),4) + SUBSTR(DTOC(TRAN_DATE),1,2) + SUBSTR(DTOC(TRAN_DATE),4,2) TO COMTDT
INDEX ON COM_PD + LED_CODE TO COMTPD

CLOSE DATA

RETURN
* EOF: ACOM_CHK.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/15/16 at 2:19 PM.
