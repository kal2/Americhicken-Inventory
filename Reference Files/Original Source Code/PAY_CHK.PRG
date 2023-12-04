**************
* Program.: PAY_CHK.PRG
* Author..: Grace Keller
* Date....: 01/25/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINT PAYROLL CHECKS 
*
IF MMASTDBF = '\AMERICO\'
   TEMPMAST = '\AMERICO\'
ELSE
   TEMPMAST = '\BROKER\'
ENDIF

MTITLE = ' - PRINT PAYROLL CHECKS/ADVISEMENTS'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()                               
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 22,79
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

STORE CK_NBR  TO MCK_NBR
STORE ACH_NBR TO MACH_NBR

STORE DATE() TO MCK_DATE
SET PROC TO MISC_CHK
MTOTAL = 0
MCHOICE = 'ACH'
STORE 2 TO MACTION
DO WHILE MACTION = 2
   
   @ 8,5 SAY 'Print Check (CHK) -or- ACH Advisement (ACH): '
   @ 8,50 GET MCHOICE PICTURE '@!' VALID(MCHOICE = 'CHK' .OR. MCHOICE = 'ACH')
   MACTION = 1
   @ 24,1 say 'Action: ' + str(maction,1)
   @ 24,13 say '1. Continue      2. Edit      3. Cancel'
   READ
   @ 24,9 get maction PICTURE '9' range 1,3
   READ
ENDDO
IF MACTION = 3
   CLOSE DATA
   RETURN
ENDIF
@ 08,5 say space(70)

STORE 2 TO MACTION
DO WHILE MACTION = 2
   @ 9,5 SAY '      (or 0 to Cancel)'
   IF MCHOICE = 'CHK'
      @ 8,5 SAY '      Starting Check Number: '
      @ 8,35 GET MCK_NBR PICTURE '######'  
   ELSE
      @ 8,5 SAY '      Starting ACH   Number: '
      @ 8,35 GET MACH_NBR PICTURE '######'  
   ENDIF
   *  @ 11,5 SAY '     Enter Date For Checks:' GET mCK_date
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

STORE ' ' TO MPRT_ACT
DO PAY_SET


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
MPRT_ONE = .F.

SET CONSOLE OFF
IF FILE("C:\COMPINFO\PRINTERS.DBF")
   SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
ELSE
   SET PRINT TO LPT3
ENDIF
SET DEVICE TO PRINT
SET PRINT ON

***SELECT TRAY 2
?? CHR(27) + '&l1H'
SELECT F
DO FOX_USE WITH "CK_REG INDEX CK_REG, CK_DATE", .F.
SELECT C
DO FOX_USE WITH "DISBJRN INDEX DISBJRN, DISB_PO, DISBINV, DISBSTR, DISBINQ", .F.
SELECT D
DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.

SELECT A
DO FOX_USE WITH "MAN_CK", .F.

MFIRST_TM = .T.
MNOT_PRINT = .T.
DO WHILE .NOT. EOF()
   IF ACCOUNT01 <> '8020'
      SKIP
      LOOP
   ENDIF
   STORE NAME TO MNAME
   STORE TRIM(STREET) TO MSTREET
   STORE TRIM(CITY)   TO MCITY  
   STORE STATE        TO MSTATE
   STORE ZIP          TO MZIP
   
   SELECT A
   IF DTOC(CK_DATE) = '  /  /  '
      STORE DATE() TO MCK_DATE
   ELSE
      STORE CK_DATE TO MCK_DATE
   ENDIF
   STORE DTOC(MCK_DATE) TO MDATE
   STORE SUBSTR(MDATE,1,2) TO MMONTH
   STORE SUBSTR(MDATE,4,2) TO MDAY
   STORE SUBSTR(MDATE,7) TO MYEAR
   MSALESMAN = SALESMAN
   STORE SPACE(4) TO MCATEGORY1, MCATEGORY2, MCATEGORY3, MCATEGORY4, MCATEGORY5, MCATEGORY6, MCATEGORY07
   STORE 0 TO MAMOUNT1, MAMOUNT2, MAMOUNT3, MAMOUNT4, MAMOUNT5, MAMOUNT6, MAMOUNT7
   I = 1   
   STORE AMOUNT01 TO MAMOUNT1
   STORE ACCOUNT01 TO MCATEGORY1   
   STORE 'GROSS PAYROLL' + SPACE(5) TO MDESCRIP1
   STORE AMOUNT02 TO MAMOUNT2
   STORE ACCOUNT02 TO MCATEGORY2   
   IF MAMOUNT2 = 0
      MDESCRIP2 = SPACE(18)
   ELSE
      STORE 'FICA         ' + SPACE(5) TO MDESCRIP2
   ENDIF
   STORE AMOUNT03 TO MAMOUNT3
   STORE ACCOUNT03 TO MCATEGORY3   
   IF MAMOUNT3 = 0 
      MDESCRIP3 = SPACE(18)
   ELSE
      STORE 'FEDERAL TAX  ' + SPACE(5) TO MDESCRIP3
   ENDIF
   STORE AMOUNT04 TO MAMOUNT4
   STORE ACCOUNT04 TO MCATEGORY4   
   IF MAMOUNT4 = 0
      MDESCRIP4 = SPACE(18)
   ELSE
      STORE 'MISSOURI TAX ' + SPACE(5) TO MDESCRIP4
   ENDIF
   
   *** THESE ARE ENTERED OUT OF ORDER
   
   STORE AMOUNT07 TO MAMOUNT5
   STORE ACCOUNT07 TO MCATEGORY5
   
   IF MAMOUNT5 = 0
      MDESCRIP5 = SPACE(18)
   ELSE
      STORE 'OREGON TAX   ' + SPACE(5) TO MDESCRIP5
   ENDIF
   
   STORE AMOUNT05 TO MAMOUNT6
   STORE ACCOUNT05 TO MCATEGORY6
   STORE AMOUNT06 TO MAMOUNT7
   STORE ACCOUNT06 TO MCATEGORY7
   
   IF MAMOUNT6 = 0
      MDESCRIP6 = SPACE(18)
   ELSE
      SELECT D
      SEEK MCATEGORY6
      MDESCRIP6 = SUBSTR(CK_DESC,1,18)
   ENDIF
   
   IF MAMOUNT7 = 0
      MDESCRIP7 = SPACE(18)
   ELSE
      SELECT D
      SEEK MCATEGORY7
      MDESCRIP7 = SUBSTR(CK_DESC,1,18)
   ENDIF
   MTOT = MAMOUNT1 + MAMOUNT2 + MAMOUNT3 + MAMOUNT4 + MAMOUNT5 + MAMOUNT6 + MAMOUNT7
   
   MCHK_AMT = MTOT
   SELECT A
   IF MCHOICE = 'CHK'
      *** DO THE NEW LASER PRINT CHECK FORMAT
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
      
      *** PRINT IN 6 LINES PER IN/VERTICAL
      ?? chr(27) + '&l8D'
      ?
      ?
      
      *************************
      **** PRINT THE FIRST STUB
      *************************
      
      MX = 1
      DO WHILE MX <= 8
         ?
         MX = MX + 1
      ENDDO
      ?
      ?
      I = 1
      MNDX = 1
      
      DO WHILE I <= 7
         MI = STR(I,1)
         IF MAMOUNT&MI <> 0
            ? SPACE(7) + MDESCRIP&MI + SPACE(20)
            ?? TRANSFORM(MAMOUNT&MI, '999,999.99')
            ?
            MNDX = MNDX + 1
         ENDIF
         I = I + 1
      ENDDO
      
      ?
      ? SPACE(7) + 'Total Remittance: ' + SPACE(20)
      ?? TRANSFORM(MCHK_AMT,"999,999.99")
      
      DO WHILE MNDX < 8
         ?
         ?
         MNDX = MNDX + 1
      ENDDO
      
      I = 1
      DO WHILE I<= 9 
         ?
         I = I + 1
      ENDDO
      
      **** PRINT THE SECOND STUB
      
      *** PRINT IN 10 CPI
      ?? chr(27) + '&k0S'
      
      ? SPACE(6) + MNAME       + SPACE(06) + ' Check No:   ' + LTRIM(STR(MCK_NBR,6))
      
      ? SPACE(6) + MSTREET        + SPACE(29)
      
      ?? 'Date:   ' + MDATE
      ? SPACE(6) + TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
      ? 
      
      ? space(47) + 'Amount:   '
      MAMOUNT = '$' + LTRIM(TRANSFORM(MCHK_AMT, "999,999.99"))
      ?? MAMOUNT
      ?
      ?
      I = 1
      MNDX = 1
      I = 1
      DO WHILE I <= 7
         MI = STR(I,1)
         IF MAMOUNT&MI <> 0
            ? SPACE(7) + MDESCRIP&MI + SPACE(20)
            ?? TRANSFORM(MAMOUNT&MI, '999,999.99')
            ?
            MNDX = MNDX + 1
         ENDIF
         I = I + 1
      ENDDO
      ?
      ? SPACE(7) + 'Total Remittance: ' + SPACE(20)
      ?? TRANSFORM(MCHK_AMT,"999,999.99")
      DO WHILE MNDX <= 7
         ?
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
      ?
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      EJECT
      
   ELSE
      *** DO THE NEW LASER ADVISEMENT CHECK FORMAT
      MTIMES = 1
      DO WHILE MTIMES <= 2
         
         *** FONT COURIER
         ?? CHR(27) + '(s4099T'
         
         *** PRINT IN 8 LINES PER IN/VERTICAL
         ?? chr(27) + '&l8D'
         
         *** PRINT IN 10 CPI
         ?? chr(27) + '&k0S'
         
         *** BOLDED PRINT
         ?? CHR(27) + '(s4B'
         
         ? SPACE(62) + 'ACH NO.   A' + LTRIM(STR(MACH_NBR,5))
         ?
         ?
         
         ?  SPACE(43) + ' ACH Date ' + space(15) + 'Amount'
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
         ? 'Pay' + space(4) + MNAME
         ? ' To' + SPACE(4) + MSTREET
         ? SPACE(7) + TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
         ?
         
         *** PRINT IN 6 LINES PER IN/VERTICAL
         ?? chr(27) + '&l8D'
         ?
         ?
         I = 1
         MNDX = 0
         DO WHILE I <= 7
            MI = STR(I,1)
            IF MAMOUNT&MI <> 0
               ? SPACE(7) + MDESCRIP&MI + SPACE(20)
               ?? TRANSFORM(MAMOUNT&MI, '999,999.99')
               ?
               MNDX = MNDX + 1
            ENDIF
            I = I + 1
         ENDDO
         ? SPACE(7) + 'Total Remittance: ' + SPACE(20)
         ?? TRANSFORM(MCHK_AMT,"999,999.99")
         ?
         
         DO WHILE MNDX <= 7
            ?
            ?
            MNDX = MNDX + 1
         ENDDO
         
         IF MTIMES = 1
            I = 1
            DO WHILE I < 10
               ?
               I = I + 1
            ENDDO
         ELSE
            EJECT
         ENDIF
         
         *** PRINT IN 12 CPI
         ?? chr(27) + '&k4S'
         MTIMES = MTIMES + 1
      ENDDO
   ENDIF
   
   ** DO THE DISBURSEMENT JOURNAL HERE
   SELECT C
   DO FILELOCK
   APPEND BLANK
   REPLACE JRNL_MO WITH MMONTH
   REPLACE JRNL_YR WITH MYEAR
   REPLACE JRNL_DAY WITH MDAY
   IF MCHOICE = 'CHK'
      REPLACE CK_NBR WITH STR(MCK_NBR,6)
   ELSE
      REPLACE CK_NBR WITH 'A' + LTRIM(STR(MACH_NBR,5))
   ENDIF
   REPLACE SALESMAN WITH MSALESMAN
   REPLACE AMOUNT1 WITH MAMOUNT1
   REPLACE CATEGORY1 WITH MCATEGORY1   
   REPLACE ACCT_NAME WITH MNAME
   REPLACE ACCT_TYPE WITH 'P'
   REPLACE SYS_DATE WITH DATE()
   UNLOCK
   IF MAMOUNT2 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE JRNL_MO WITH MMONTH
      REPLACE JRNL_YR WITH MYEAR
      REPLACE JRNL_DAY WITH MDAY
      IF MCHOICE = 'CHK'
         REPLACE CK_NBR WITH STR(MCK_NBR,6)
      ELSE
         REPLACE CK_NBR WITH 'A' + LTRIM(STR(MACH_NBR,5))
      ENDIF
      REPLACE SALESMAN WITH MSALESMAN
      REPLACE AMOUNT1 WITH MAMOUNT2
      REPLACE CATEGORY1 WITH MCATEGORY2   
      REPLACE ACCT_NAME WITH MNAME
      REPLACE ACCT_TYPE WITH 'P'
      REPLACE SYS_DATE WITH DATE()
      UNLOCK
   ENDIF
   
   IF MAMOUNT3 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE JRNL_MO WITH MMONTH
      REPLACE JRNL_YR WITH MYEAR
      REPLACE JRNL_DAY WITH MDAY
      IF MCHOICE = 'CHK'
         REPLACE CK_NBR WITH STR(MCK_NBR,6)
      ELSE
         REPLACE CK_NBR WITH 'A' + LTRIM(STR(MACH_NBR,5))
      ENDIF
      REPLACE SALESMAN WITH MSALESMAN
      REPLACE AMOUNT1 WITH MAMOUNT3
      REPLACE CATEGORY1 WITH MCATEGORY3   
      REPLACE ACCT_NAME WITH MNAME
      REPLACE ACCT_TYPE WITH 'P'
      REPLACE SYS_DATE WITH DATE()
      UNLOCK
   ENDIF
   
   IF MAMOUNT4 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE JRNL_MO WITH MMONTH
      REPLACE JRNL_YR WITH MYEAR
      REPLACE JRNL_DAY WITH MDAY
      IF MCHOICE = 'CHK'
         REPLACE CK_NBR WITH STR(MCK_NBR,6)
      ELSE
         REPLACE CK_NBR WITH 'A' + LTRIM(STR(MACH_NBR,5))
      ENDIF
      REPLACE SALESMAN WITH MSALESMAN
      REPLACE AMOUNT1 WITH MAMOUNT4
      REPLACE CATEGORY1 WITH MCATEGORY4   
      REPLACE ACCT_NAME WITH MNAME
      REPLACE ACCT_TYPE WITH 'P'
      REPLACE SYS_DATE WITH DATE()
      UNLOCK
   ENDIF
   
   IF MAMOUNT7 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE JRNL_MO WITH MMONTH
      REPLACE JRNL_YR WITH MYEAR
      REPLACE JRNL_DAY WITH MDAY
      IF MCHOICE = 'CHK'
         REPLACE CK_NBR WITH STR(MCK_NBR,6)
      ELSE
         REPLACE CK_NBR WITH 'A' + LTRIM(STR(MACH_NBR,5))
      ENDIF
      REPLACE SALESMAN WITH MSALESMAN
      REPLACE AMOUNT1 WITH MAMOUNT7
      REPLACE CATEGORY1 WITH MCATEGORY7   
      REPLACE ACCT_NAME WITH MNAME
      REPLACE ACCT_TYPE WITH 'P'
      REPLACE SYS_DATE WITH DATE()
      UNLOCK
   ENDIF
   
   IF MAMOUNT5 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE JRNL_MO WITH MMONTH
      REPLACE JRNL_YR WITH MYEAR
      REPLACE JRNL_DAY WITH MDAY
      IF MCHOICE = 'CHK'
         REPLACE CK_NBR WITH STR(MCK_NBR,6)
      ELSE
         REPLACE CK_NBR WITH 'A' + LTRIM(STR(MACH_NBR,5))
      ENDIF
      REPLACE SALESMAN WITH MSALESMAN
      REPLACE AMOUNT1 WITH MAMOUNT5
      REPLACE CATEGORY1 WITH MCATEGORY5   
      REPLACE ACCT_NAME WITH MNAME
      REPLACE ACCT_TYPE WITH 'O'
      REPLACE SYS_DATE WITH DATE()
      UNLOCK
   ENDIF
   
   IF MAMOUNT6 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE JRNL_MO WITH MMONTH
      REPLACE JRNL_YR WITH MYEAR
      REPLACE JRNL_DAY WITH MDAY
      IF MCHOICE = 'CHK'
         REPLACE CK_NBR WITH STR(MCK_NBR,6)
      ELSE
         REPLACE CK_NBR WITH 'A' + LTRIM(STR(MACH_NBR,5))
      ENDIF
      REPLACE SALESMAN WITH MSALESMAN
      REPLACE AMOUNT1 WITH MAMOUNT6
      REPLACE CATEGORY1 WITH MCATEGORY6   
      REPLACE ACCT_NAME WITH MNAME
      REPLACE ACCT_TYPE WITH 'O'
      REPLACE SYS_DATE WITH DATE()
      UNLOCK
   ENDIF
   
   SELECT A
   DELETE
   **** DO THE CHECK REGISTER HERE
   SELECT F
   DO FILELOCK
   APPEND BLANK
   REPLACE PAY_NAME WITH MNAME        
   IF MCHOICE = 'CHK'
      REPLACE CK_NBR WITH STR(MCK_NBR,6)
   ELSE
      REPLACE CK_NBR WITH 'A' + LTRIM(STR(MACH_NBR,5))
      REPLACE CLEAR_FLG WITH 'Y'
   ENDIF
   REPLACE CK_DATE WITH MCK_DATE
   REPLACE AMOUNT WITH MTOT
   REPLACE PAY_TYPE WITH 'P' 
   REPLACE SYS_DATE WITH DATE()
   
   UNLOCK
   SELECT A
   SKIP
   IF MCHOICE = 'CHK'
      MCK_NBR = MCK_NBR + 1
   ELSE
      MACH_NBR = MACH_NBR + 1
   ENDIF
ENDDO

SELECT A
DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
DO FILELOCK
IF MCHOICE = 'CHK'
   REPLACE CK_NBR WITH MCK_NBR
ELSE
   REPLACE ACH_NBR WITH MACH_NBR
ENDIF
REPLACE CK_PRINT WITH 'N'
UNLOCK

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON
IF MPRINTER3 <> 'DONOTPRINT'
   RUN &MPRINTIT3
ENDIF

CLOSE DATA

RETURN
* EOF: PAY_CHK.PRG

*Formatted by: ToolBox Ver. 1.2  on 2/23/16 at 1:35 PM.
