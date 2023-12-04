**********
* Program.: MISC_CHK.PRG
* Author..: Grace Keller
* Date....: 01/25/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINT MISCELLANEOUS CHECKS
*
IF MMASTDBF = '\AMERICO\'
   TEMPMAST = '\AMERICO\'
ELSE
   TEMPMAST = '\BROKER\'
ENDIF

MTITLE = ' - PRINT MISCELLANEOUS CHECKS'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 22,79

MCHOICE = ' '
STORE 2 TO MACTION
DO WHILE MACTION = 2
   @ 6,5  say 'Print Selection: '
   @ 6,22 GET MCHOICE PICTURE '@!' VALID(MCHOICE = 'A' .or. MCHOICE = 'L')
   **@ 9,5  SAY 'Check       (Old Format)  (C) '
   @ 09,5 SAY 'Laser Check      (L) '
   @ 11,5 SAY 'ACH Advisement   (A) '
   
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
@ 06,4 CLEAR TO 14,70

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


IF MCHOICE = 'L'
   STORE LCK_NBR TO MCK_NBR
ELSE
   STORE CK_NBR TO MCK_NBR
ENDIF

STORE ACH_NBR TO MACH_NBR

STORE DATE() TO MCK_DATE
SET PROC TO MISC_CHK
MTOTAL = 0
MPAYROLL = 'N'
store 2 to maction
DO WHILE MACTION = 2
   
   IF MCHOICE = 'C' .OR. MCHOICE = 'L'
      @ 8,5 SAY '      Starting Check Number: '
      @ 8,35 GET MCK_NBR PICTURE '######'  
      @ 11,5 SAY '  Print Payroll Tax Checks: ' GET MPAYROLL PICTURE '@!' VALID(MPAYROLL = 'N' .OR. MPAYROLL = 'Y')
   ELSE
      @ 8,5 SAY '      Starting ACH   Number: '
      @ 8,35 GET MACH_NBR PICTURE '######'  
   ENDIF
   @ 9,5 SAY '      (or 0 to Cancel)'
   *  @ 11,5 SAY '     Enter Date For Checks:' GET mCK_date
   MACTION = 1
   
   @ 24,1 say 'Action: ' + str(maction,1)
   @ 24,13 say '1. Continue      2. Edit      3. Cancel'
   READ
   @ 24,9 get maction PICTURE '9' range 1,3
   READ
ENDDO

**IF MACTION = 3 .OR. MCK_NBR = 0
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

SELECT F
DO FOX_USE WITH "CK_REG INDEX CK_REG, CK_DATE", .F.
SELECT C
DO FOX_USE WITH "DISBJRN INDEX DISBJRN, DISB_PO, DISBINV, DISBSTR, DISBINQ", .F.
SELECT D
DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.

SELECT A
DO FOX_USE WITH "MAN_CK", .F.

IF MUSER <> 'SUPERVISOR'
   SET FILTER TO USER = MUSER
   GOTO TOP
ENDIF

MFIRST_TM = .T.

IF MCHOICE <> 'L'
   DO WHILE .NOT. EOF()
      *** NEVER PRINT CHECKS FOR THESE ANYMORE - ONLY ACH ADVISEMENTS
      IF MCHOICE = 'C'
         IF ACCOUNT01 = '8020'
            SKIP
            LOOP
         ENDIF
         IF MPAYROLL = 'N'
            IF ACCOUNT01 = '3305' .OR. ACCOUNT01 = '3306'
               SKIP
               LOOP
            ENDIF
         ENDIF
      ENDIF
      STORE NAME TO MNAME
      STORE STREET TO MSTREET
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
      STORE ZIP TO MZIP
      STORE ZIP4 TO MZIP4
      MLINE = 1
      ? SPACE(6) + TRIM(MNAME)
      IF LEN(TRIM(MCITY)) <> 0
         ?? ', ' + TRIM(MCITY) + ', ' + MSTATE + SPACE(2) + MZIP   
         IF MZIP4 <> SPACE(4)
            ?? '-' + MZIP4
         ENDIF
      ENDIF
      IF MCHOICE = 'C'
         ? SPACE(80) + 'CHECK NO. ' + STR(MCK_NBR,6)
      ELSE
         ? SPACE(80) + 'ACH NO.   A' + LTRIM(STR(MACH_NBR,5))
      ENDIF
      ? '      INVOICE NO.        DESCRIPTION                       REMITTANCE'
      ?
      MLINE = MLINE + 4
      
      
      MTOT = 0
      
      SELECT A
      DO WHILE .NOT. EOF() .AND. NAME = MNAME .AND. MLINE + 4 <= 17
         IF ACCOUNT01 = '8020'
            SKIP
            LOOP
         ENDIF
         STORE DESCRIP TO MDESCRIP
         IF DTOC(CK_DATE) = '  /  /  '
            STORE DATE() TO MCK_DATE
         ELSE
            STORE CK_DATE TO MCK_DATE
         ENDIF
         STORE DTOC(MCK_DATE) TO MDATE
         STORE SUBSTR(MDATE,1,2) TO MMONTH
         STORE SUBSTR(MDATE,4,2) TO MDAY
         STORE SUBSTR(MDATE,7) TO MYEAR
         I = 1
         DO WHILE I<=12
            MI = SUBSTR(STR(I+100,3),2)
            STORE SPACE(4) TO MCATEGORY&MI
            STORE 0 TO MAMOUNT&MI
            STORE SPACE(2) TO MSALES&MI
            STORE SPACE(15) TO MINV&MI
            I = I + 1
         ENDDO
         
         MAMT_DUE = 0
         I = 1
         DO WHILE I<=12
            MI = SUBSTR(STR(I+100,3),2)
            IF AMOUNT&MI <> 0
               STORE AMOUNT&MI  TO MAMOUNT&MI
               STORE ACCOUNT&MI TO MCATEGORY&MI
               STORE SALES&MI   TO MSALES&MI
               STORE INV&MI     TO MINV&MI
               MAMT_DUE = MAMT_DUE + MAMOUNT&MI
            ENDIF
            I = I + 1
         ENDDO
         
         STORE SUP_INV TO MSUP_INV
         I = 1
         DO WHILE I <= 12
            MI = SUBSTR(STR(I+100,3),2)
            IF MAMOUNT&MI <> 0
               ? SPACE(6) + MINV&MI + SPACE(4)
               SELECT D
               SEEK MCATEGORY&MI
               IF .NOT. EOF()
                  IF CK_DESC = SPACE(10)
                     STORE 'MISCELLANEOUS       ' TO MCK_DESC
                  ELSE
                     STORE CK_DESC TO MCK_DESC
                  ENDIF
               ELSE
                  STORE 'MISCELLANEOUS       ' TO MCK_DESC
               ENDIF
               ?? MCK_DESC
               IF MPROG_CODE = 1 .AND. MSALES&MI <> SPACE(2)
                  ?? SPACE(2) + 'S-' + MSALES&MI + SPACE(1)
               ELSE
                  ?? SPACE(07)
               ENDIF
               ?? TRANSFORM(MAMOUNT&MI, '9,999,999.99')
               
               SELECT C
               
               DO FILELOCK
               APPEND BLANK
               REPLACE JRNL_MO WITH MMONTH
               REPLACE JRNL_YR WITH MYEAR
               REPLACE JRNL_DAY WITH MDAY
               IF MCHOICE = 'C'
                  REPLACE CK_NBR WITH STR(MCK_NBR,6)
               ELSE
                  REPLACE CK_NBR WITH 'A' + LTRIM(STR(MACH_NBR,5))
               ENDIF
               REPLACE AMOUNT1 WITH MAMOUNT&MI
               REPLACE CATEGORY1 WITH MCATEGORY&MI
               REPLACE ACCT_NAME WITH MNAME
               REPLACE BILL_INV WITH MINV&MI
               REPLACE ACCT_TYPE WITH 'O'
               REPLACE SYS_DATE WITH DATE()
               IF MPROG_CODE = 1
                  IF A->SALES&MI <> 'TP'
                     REPLACE SALESMAN WITH A->SALES&MI
                  ENDIF
               ELSE
                  REPLACE SALESMAN WITH A->SALESMAN
               ENDIF
               IF CATEGORY1 = '150 ' 
                  REPLACE SALESMAN WITH A->SALESMAN
                  REPLACE PO_NBR WITH A->PO_NBR
                  REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                  REPLACE ACCT_NBR WITH A->ACCT_NBR 
                  REPLACE INV_NBR WITH A->INV_NBR
               ENDIF
               *** COMMISSIONS ADVANCED - NEEDS THE SALESPERSON NUMBER IN THE FILE
               IF CATEGORY1 = '7301'
                  IF MPROG_CODE = 1
                     *** FOR THIRD PARTY COMM ADVANCES - SALESMAN = COM_CODE
                     IF A->SALES&MI = 'TP'
                        REPLACE ACCT_NBR WITH 'T ' + A->SALESMAN
                     ELSE                    
                        REPLACE ACCT_NBR WITH 'S ' + A->SALES&MI
                     ENDIF
                  ELSE
                     REPLACE ACCT_NBR WITH 'S ' + A->SALESMAN
                  ENDIF
               ENDIF
               IF VAL(CATEGORY1) >= 8401 .AND. VAL(CATEGORY1) <= 8450
                  IF MPROG_CODE = 1
                     REPLACE ACCT_NBR WITH 'S ' + A->SALES&MI   
                  ELSE
                     REPLACE ACCT_NBR WITH 'S ' + A->SALESMAN
                  ENDIF
               ENDIF
               IF CATEGORY1 = '7150'
                  IF MPROG_CODE = 1
                     REPLACE ACCT_NBR WITH 'S ' + A->SALES&MI
                  ELSE
                     REPLACE ACCT_NBR WITH 'S ' + A->SALESMAN
                  ENDIF
               ENDIF
               IF CATEGORY1 = '7350'
                  IF MPROG_CODE = 1
                     REPLACE ACCT_NBR WITH 'S ' + A->SALES&MI   
                  ELSE
                     REPLACE ACCT_NBR WITH 'S ' + A->SALESMAN
                  ENDIF
               ENDIF
               MLINE = MLINE + 1
            ENDIF
            I = I + 1
         ENDDO
         
         MTOT = MTOT + MAMT_DUE
         
         IF A->ACCOUNT01 = '150 '
            SELECT E
            DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
            DO FILELOCK
            APPEND BLANK
            REPLACE SALESMAN   WITH A->SALESMAN  
            REPLACE PO_NBR     WITH A->PO_NBR    
            REPLACE PO_SUFFIX  WITH A->PO_SUFFIX 
            REPLACE BBUYCODE   WITH A->ACCT_NBR  
            REPLACE SHIP_DATE  WITH MCK_DATE 
            REPLACE TOT_SELL   WITH A->AMOUNT01 
            REPLACE INV_NBR    WITH A->INV_NBR      
            REPLACE INV_DATE   WITH MCK_DATE
            REPLACE DEB_CRD    WITH 'Y'
            UNLOCK
            USE
         ENDIF
         SELECT A
         DELETE
         SKIP
      ENDDO
      ***** NOW SKIP DOWN SO MANY LINES TO GET TO THE BOTTOM OF THE STUB AND READY TO PRINT
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
      IF MCHOICE = 'C'
         ?
         ?
         ? SPACE(8) + TRIM(MNAME)
         IF LEN(TRIM(MSTREET)) = 0
            ?
         ELSE
            ? SPACE(8) + TRIM(MSTREET)
         ENDIF
         IF LEN(TRIM(MCITY)) = 0 .AND. LEN(TRIM(MSTATE)) = 0
            ?
         ELSE
            ? SPACE(8) + TRIM(MCITY) + ', ' + MSTATE + SPACE(2) + MZIP   
            IF MZIP4 <> SPACE(4)
               ?? '-' + MZIP4
            ENDIF
         ENDIF
         MLINE = MLINE + 5
      ENDIF
      
      X = 1
      DO WHILE X <= 8
         ?
         X = X + 1
      ENDDO
      **** DO THE CHECK REGISTER HERE
      SELECT F
      DO FILELOCK
      APPEND BLANK
      REPLACE PAY_NAME WITH MNAME        
      IF MCHOICE = 'C'
         REPLACE CK_NBR WITH STR(MCK_NBR,6)
      ELSE
         REPLACE CK_NBR WITH 'A' + LTRIM(STR(MACH_NBR,5))
      ENDIF
      REPLACE CK_DATE WITH MCK_DATE
      REPLACE AMOUNT WITH MTOT
      REPLACE PAY_TYPE WITH 'O' 
      REPLACE DESCRIP WITH MDESCRIP
      REPLACE SYS_DATE WITH DATE()
      IF MCHOICE = 'A'
         REPLACE CLEAR_FLG WITH 'Y'
      ENDIF
      UNLOCK
      SELECT A
      IF MCHOICE = 'C'
         MCK_NBR = MCK_NBR + 1
      ELSE
         MACH_NBR = MACH_NBR + 1
      ENDIF
   ENDDO
   
ELSE
   *** NEW LASER CHECK FORMAT
   
   DO WHILE .NOT. EOF()
      
      *** NEVER PRINT CHECKS FOR THESE ANYMORE - ONLY ACH ADVISEMENTS
      
      IF MCHOICE = 'C' .OR. MCHOICE = 'L'
         IF ACCOUNT01 = '8020'
            SKIP
            LOOP
         ENDIF
         IF MPAYROLL = 'N'
            IF ACCOUNT01 = '3305' .OR. ACCOUNT01 = '3306'
               SKIP
               LOOP
            ENDIF
         ENDIF
      ENDIF
      STORE NAME TO MNAME
      STORE STREET TO MSTREET
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
      STORE ZIP TO MZIP
      STORE ZIP4 TO MZIP4
      MTOT = 0
      
      SELECT A
      
      STORE DESCRIP TO MDESCRIP
      IF DTOC(CK_DATE) = '  /  /  '
         STORE DATE() TO MCK_DATE
      ELSE
         STORE CK_DATE TO MCK_DATE
      ENDIF
      STORE DTOC(MCK_DATE) TO MDATE
      STORE SUBSTR(MDATE,1,2) TO MMONTH
      STORE SUBSTR(MDATE,4,2) TO MDAY
      STORE SUBSTR(MDATE,7) TO MYEAR
      I = 1
      DO WHILE I<=12
         MI = SUBSTR(STR(I+100,3),2)
         STORE SPACE(4) TO MCATEGORY&MI
         STORE 0 TO MAMOUNT&MI
         STORE SPACE(2) TO MSALES&MI
         STORE SPACE(15) TO MINV&MI
         I = I + 1
      ENDDO
      
      MAMT_DUE = 0
      I = 1
      DO WHILE I<=12
         MI = SUBSTR(STR(I+100,3),2)
         IF AMOUNT&MI <> 0
            STORE AMOUNT&MI  TO MAMOUNT&MI
            STORE ACCOUNT&MI TO MCATEGORY&MI
            STORE SALES&MI   TO MSALES&MI
            STORE INV&MI     TO MINV&MI
            MAMT_DUE = MAMT_DUE + MAMOUNT&MI
         ENDIF
         I = I + 1
      ENDDO
      
      I = 1
      DO WHILE I<=12
         MI = SUBSTR(STR(I+100,3),2)
         IF MAMOUNT&MI <> 0
            SELECT C
            DO FILELOCK
            APPEND BLANK
            REPLACE JRNL_MO WITH MMONTH
            REPLACE JRNL_YR WITH MYEAR
            REPLACE JRNL_DAY WITH MDAY
            IF MCHOICE = 'C' .OR. MCHOICE = 'L'
               REPLACE CK_NBR WITH STR(MCK_NBR,6)
            ELSE
               REPLACE CK_NBR WITH 'A' + LTRIM(STR(MACH_NBR,5))
            ENDIF
            REPLACE AMOUNT1 WITH MAMOUNT&MI
            REPLACE CATEGORY1 WITH MCATEGORY&MI
            REPLACE ACCT_NAME WITH MNAME
            REPLACE BILL_INV WITH MINV&MI
            REPLACE ACCT_TYPE WITH 'O'
            REPLACE SYS_DATE WITH DATE()
            IF MPROG_CODE = 1
               IF A->SALES&MI <> 'TP'
                  REPLACE SALESMAN WITH A->SALES&MI
               ENDIF
            ELSE
               REPLACE SALESMAN WITH A->SALESMAN
            ENDIF
            IF CATEGORY1 = '150 ' 
               REPLACE SALESMAN WITH A->SALESMAN
               REPLACE PO_NBR WITH A->PO_NBR
               REPLACE PO_SUFFIX WITH A->PO_SUFFIX
               REPLACE ACCT_NBR WITH A->ACCT_NBR 
               REPLACE INV_NBR WITH A->INV_NBR
            ENDIF
            *** COMMISSIONS ADVANCED - NEEDS THE SALESPERSON NUMBER IN THE FILE
            IF CATEGORY1 = '7301'
               IF MPROG_CODE = 1
                  *** FOR THIRD PARTY COMM ADVANCES - SALESMAN = COM_CODE
                  IF A->SALES&MI = 'TP'
                     REPLACE ACCT_NBR WITH 'T ' + A->SALESMAN
                  ELSE                    
                     REPLACE ACCT_NBR WITH 'S ' + A->SALES&MI
                  ENDIF
               ELSE
                  REPLACE ACCT_NBR WITH 'S ' + A->SALESMAN
               ENDIF
            ENDIF
            IF VAL(CATEGORY1) >= 8401 .AND. VAL(CATEGORY1) <= 8450
               IF MPROG_CODE = 1
                  REPLACE ACCT_NBR WITH 'S ' + A->SALES&MI   
               ELSE
                  REPLACE ACCT_NBR WITH 'S ' + A->SALESMAN
               ENDIF
            ENDIF
            IF CATEGORY1 = '7150'
               IF MPROG_CODE = 1
                  REPLACE ACCT_NBR WITH 'S ' + A->SALES&MI
               ELSE
                  REPLACE ACCT_NBR WITH 'S ' + A->SALESMAN
               ENDIF
            ENDIF
            IF CATEGORY1 = '7350'
               IF MPROG_CODE = 1
                  REPLACE ACCT_NBR WITH 'S ' + A->SALES&MI   
               ELSE
                  REPLACE ACCT_NBR WITH 'S ' + A->SALESMAN
               ENDIF
            ENDIF
         ENDIF
         
         I = I + 1
      ENDDO
      
      MTOT = MAMT_DUE
      
      IF A->ACCOUNT01 = '150 '
         SELECT E
         DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
         DO FILELOCK
         APPEND BLANK
         REPLACE SALESMAN   WITH A->SALESMAN  
         REPLACE PO_NBR     WITH A->PO_NBR    
         REPLACE PO_SUFFIX  WITH A->PO_SUFFIX 
         REPLACE BBUYCODE   WITH A->ACCT_NBR  
         REPLACE SHIP_DATE  WITH MCK_DATE 
         REPLACE TOT_SELL   WITH A->AMOUNT01 
         REPLACE INV_NBR    WITH A->INV_NBR      
         REPLACE INV_DATE   WITH MCK_DATE
         REPLACE DEB_CRD    WITH 'Y'
         UNLOCK
         USE
      ENDIF
      
      **** DO THE CHECK REGISTER HERE
      SELECT F
      DO FILELOCK
      APPEND BLANK
      REPLACE PAY_NAME WITH MNAME        
      IF MCHOICE = 'C' .OR. MCHOICE = 'L'
         REPLACE CK_NBR WITH STR(MCK_NBR,6)
      ELSE
         REPLACE CK_NBR WITH 'A' + LTRIM(STR(MACH_NBR,5))
      ENDIF
      REPLACE CK_DATE WITH MCK_DATE
      REPLACE AMOUNT WITH MTOT
      REPLACE PAY_TYPE WITH 'O' 
      REPLACE DESCRIP WITH MDESCRIP
      REPLACE SYS_DATE WITH DATE()
      IF MCHOICE = 'A'
         REPLACE CLEAR_FLG WITH 'Y'
      ENDIF
      UNLOCK
      
      *** DO THE NEW LASER PRINT CHECK FORMAT
      
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
      MAMOUNT = '$' + LTRIM(TRANSFORM(MCHK_AMT, "9,999,999.99"))
      
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
      
      
      ? '       INVOICE NO.        DESCRIPTION                       REMITTANCE'
      ?
      I = 1
      MNDX = 1
      
      I = 1
      DO WHILE I <= 12
         MI = SUBSTR(STR(I+100,3),2)
         IF MAMOUNT&MI <> 0
            ? SPACE(7) + MINV&MI + SPACE(4)
            SELECT D
            SEEK MCATEGORY&MI
            IF .NOT. EOF()
               IF CK_DESC = SPACE(10)
                  STORE 'MISCELLANEOUS       ' TO MCK_DESC
               ELSE
                  STORE CK_DESC TO MCK_DESC
               ENDIF
            ELSE
               STORE 'MISCELLANEOUS       ' TO MCK_DESC
            ENDIF
            ?? MCK_DESC
            IF MPROG_CODE = 1 .AND. MSALES&MI <> SPACE(2)
               ?? SPACE(2) + 'S-' + MSALES&MI + SPACE(3)
            ELSE
               ?? SPACE(09)
            ENDIF
            ?? TRANSFORM(MAMOUNT&MI, '999,999.99')
            MNDX = MNDX + 1
         ENDIF
         I = I + 1
      ENDDO
      
      ?
      ? SPACE(7) + 'Total Remittance: ' + SPACE(33)
      ?? TRANSFORM(MCHK_AMT,"9,999,999.99")
      
      DO WHILE MNDX < 15
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
      
      **** PRINT THE SECOND STUB
      
      *** PRINT IN 10 CPI
      ?? chr(27) + '&k0S'
      
      ? SPACE(6) + MNAME       + SPACE(06) + ' Check No:   ' + LTRIM(STR(MCK_NBR,6))
      
      ? SPACE(6) + MSTREET        + SPACE(18)
      
      ?? 'Date:   ' + MDATE
      ? SPACE(6) + TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
      ? 
      
      ? space(47) + 'Amount:   '
      MAMOUNT = '$' + LTRIM(TRANSFORM(MCHK_AMT, "9,999,999.99"))
      ?? MAMOUNT
      ?
      ?
      
      ? '       INVOICE NO.        DESCRIPTION                       REMITTANCE'
      ?
      I = 1
      MNDX = 1
      
      I = 1
      DO WHILE I <= 12
         MI = SUBSTR(STR(I+100,3),2)
         IF MAMOUNT&MI <> 0
            ? SPACE(7) + MINV&MI + SPACE(4)
            SELECT D
            SEEK MCATEGORY&MI
            IF .NOT. EOF()
               IF CK_DESC = SPACE(10)
                  STORE 'MISCELLANEOUS       ' TO MCK_DESC
               ELSE
                  STORE CK_DESC TO MCK_DESC
               ENDIF
            ELSE
               STORE 'MISCELLANEOUS       ' TO MCK_DESC
            ENDIF
            ?? MCK_DESC
            IF MPROG_CODE = 1 .AND. MSALES&MI <> SPACE(2)
               ?? SPACE(2) + 'S-' + MSALES&MI + SPACE(1)
            ELSE
               ?? SPACE(07)
            ENDIF
            ?? TRANSFORM(MAMOUNT&MI, '9,999,999.99')
            MNDX = MNDX + 1
         ENDIF
         I = I + 1
      ENDDO
      
      ?
      ? SPACE(7) + 'Total Remittance: ' + SPACE(33)
      ?? TRANSFORM(MCHK_AMT,"9,999,999.99")
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
      
      IF MCHOICE = 'C' .OR. MCHOICE = 'L'
         MCK_NBR = MCK_NBR + 1
      ELSE
         MACH_NBR = MACH_NBR + 1
      ENDIF
      
      SELECT A
      DELETE
      SKIP
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

DO CASE
CASE MCHOICE = 'C'
   REPLACE CK_NBR WITH MCK_NBR
CASE MCHOICE = 'L'
   REPLACE LCK_NBR WITH MCK_NBR
OTHERWISE
   REPLACE ACH_NBR WITH MACH_NBR
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
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
ENDIF
CLOSE DATA

RETURN
* EOF: MISC_CHK.PRG
*Formatted by: ToolBox Ver. 1.2  on 1/5/16 at 10:21 AM.
