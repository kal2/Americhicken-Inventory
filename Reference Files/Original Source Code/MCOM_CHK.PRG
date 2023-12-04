**********
* Program.: MCOM_CHK.PRG
* Author..: Grace Keller
* Date....: 01/25/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINT AMERICHICKEN COMMISSION CHECKS
*
IF MMASTDBF = '\AMERICO\'
   TEMPMAST = '\AMERICO\'
   MTITLE = ' - PRINT AMERICHICKEN COMMISSION CHECKS / PROCESS WIRES'
ELSE
   TEMPMAST = '\BROKER\'
   MTITLE = ' - PRINT MIDWEST COMMISSION CHECKS / PROCESS WIRES'
ENDIF
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
STORE DATE() TO MCK_DATE
SET PROC TO MISC_CHK
MTOTAL = 0
STORE 2 TO MACTION
STORE 'L' TO MCHOICE
DO WHILE MACTION = 2 
   @ 8,5 SAY 'SELECT ONE OF THE FOLLOWING PAYMENT TYPES: ' get mchoice picture '@!'
   **@ 10,5 SAY '  1. Checks (C) - Old Format    Laser Checks (L) - New Format'
   @ 10,5 SAY '  1. Laser Checks (L)'
   @ 11,5 say '  2. Wires        (W)'
   @ 14,5 SAY 'Note: If any of the salespersons have total deductions that equal'
   @ 15,5 say '      the amount approved to pay, no check will print, but all of'
   @ 16,5 say '      the appropriate file processing will occur.'
   MACTION = 1
   @ 24,1 say 'Action: ' + str(maction,1)
   @ 24,13 say '1. Continue      2. Edit      3. Cancel'
   READ
   @ 24,9 get maction PICTURE '9' range 1,3
   READ
   IF MACTION = 1
      *IF MCHOICE <> 'C' .AND. MCHOICE <> 'W' .AND. MCHOICE <> 'L'                    
      IF MCHOICE <> 'W' .AND. MCHOICE <> 'L'                    
         @ 24,0 CLEAR
         *STORE 'ABOVE CHOICE MUST BE A "C" OR "W" OR "L" - PRESS RETURN TO REENTER' TO MMSG
         STORE 'ABOVE CHOICE MUST BE A "W" OR "L" - PRESS RETURN TO REENTER' TO MMSG
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
OTHERWISE
   MCK_NBR = WIRE_NBR
ENDCASE
@ 4,1 CLEAR TO 20,78
STORE 2 TO MACTION
DO WHILE MACTION = 2
   DO CASE
   CASE MCHOICE = 'C' .OR. MCHOICE = 'L'
      @ 8,5 SAY '      Starting Check Number: '
      @ 8,35 GET MCK_NBR PICTURE '######'  
      @ 11,5 SAY '     Enter Date For Checks:' GET mCK_date
   OTHERWISE
      @ 8,5 SAY '       Starting Wire Number: '
      @ 8,35 SAY MCK_NBR PICTURE '######'  
      @ 11,5 SAY '      Enter Date For Wires:' GET mCK_date
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
   DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
   DO FILELOCK
   REPLACE CK_PRINT WITH 'N'
   UNLOCK
   USE
   RETURN
ENDIF
@ 4,1 CLEAR TO 22,78
@ 4,5 SAY 'The following salespersons have orders approved for payment:'
mline = 6
MNEGATIVE = .F.
SELECT E
DO FOX_USE WITH "COM_ADJ INDEX COM_ADJ", .F.
SELECT A
DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMPD", .F.
SEEK ' S'

DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. COM_TYPE = 'S'
   STORE COM_CODE TO MCOM_CODE
   MTOT = 0
   DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. COM_TYPE = 'S' .AND. COM_CODE = MCOM_CODE
      IF APRVD_FLG <> 'Y'
         SKIP
         LOOP
      ENDIF
      MTOT = MTOT + AMOUNT 
      SKIP
   ENDDO
   IF MTOT <> 0
      SELECT F
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      SEEK MCOM_CODE
      MNAME = SUBSTR(NAME,1,12)
      USE
      SELECT E
      SEEK 'S' + MCOM_CODE
      MADJ = AMOUNT1 + AMOUNT2 + AMOUNT3 + AMOUNT4 + AMOUNT5
      SELECT A
      @ MLINE,5 SAY mcom_code + ' - '+ MNAME + SPACE(5) + TRANSFORM(MTOT, '9,999,999.99') + SPACE(5) + TRANSFORM(MADJ, '9,999,999.99') + SPACE(5) + TRANSFORM(MTOT+MADJ, '9,999,999.99')
      MLINE = MLINE + 1
      IF MTOT + MADJ < 0
         MNEGATIVE = .T.
      ENDIF
   ENDIF
   
ENDDO
SELECT E
USE

IF MLINE = 6   
   STORE ' ' TO MWAIT
   @ MLINE,1 SAY 'There are NO orders approved for payment - press return to continue ' get mwait
   READ
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
ELSE  
   MLINE = MLINE + 1
   IF MNEGATIVE
      STORE ' ' TO MWAIT
      @ MLINE,5 SAY 'Check print cannot continue.  At least one person has a negative amount' 
      @ mline+1,5 say 'approved.  Unapprove until they have zero or positive amount to pay. ' GET MWAIT
      READ
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
   ELSE
      STORE '   ' TO MYES_NO
      DO WHILE MYES_NO <> 'YES' .AND. MYES_NO <> 'NO'
         @ MLINE,5 SAY 'Do you want to continue with check print (YES/NO)? ' get myes_no picture '@!'
         READ
      ENDDO
      IF MYES_NO <> 'YES'
         CLOSE DATA
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
         DO FILELOCK
         REPLACE CK_PRINT WITH 'N'
         UNLOCK
         USE
         RETURN
      ENDIF
   ENDIF
ENDIF

IF MCHOICE = 'C'
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
ENDIF
MPRT_ONE = .F.
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
ENDIF
MPRT_ONE = .F.

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

SELECT B
USE COMS EXCLUSIVE
DELETE ALL
PACK
INDEX ON COM_TYPE + COM_CODE TO COMS
UNLOCK
DO FOX_USE WITH "COMS INDEX COMS", .F.

SELECT A
DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMPD", .F.

SEEK ' S'
DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. COM_TYPE = 'S'
   STORE COM_CODE TO MCOM_CODE
   MTOT = 0
   MTOT_72 = 0
   MAMT98  = 0
   MAMT99  = 0
   DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. COM_TYPE = 'S' .AND. COM_CODE = MCOM_CODE
      IF APRVD_FLG <> 'Y'
         SKIP
         LOOP
      ENDIF
      IF COM_CODE = '99'      
         SELECT C
         DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
         SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
         IF EOF()
            MAMT99 = MAMT99 + A->AMOUNT
         ELSE
            DO CASE
            CASE SHIP_DATE >= CTOD('12/04/94')
               MAMT99 = MAMT99 + A->AMOUNT
            OTHERWISE
               MX = ROUND(A->AMOUNT/2,2)
               MAMT99 = MAMT99 + MX
               MAMT98 = MAMT98 + (A->AMOUNT - MX)
            ENDCASE
         ENDIF
         SELECT A
      ELSE
         MTOT = MTOT + AMOUNT 
         IF SALESMAN = '72'
            MTOT_72 = MTOT_72 + AMOUNT
         ENDIF
      ENDIF
      SKIP
   ENDDO
   SELECT B     
   DO FILELOCK
   APPEND BLANK
   REPLACE COM_TYPE WITH 'S'
   
   DO CASE
   CASE MCOM_CODE = '99'
      MAMT72_1 = ROUND((MTOT_72 / 2),2)
      MAMT72_2 = MTOT_72 - MAMT72_1
      REPLACE COM_CODE WITH '99'
      REPLACE AMOUNT WITH MAMT99  
      REPLACE AMOUNT72 WITH MAMT72_1
      IF MAMT98 <> 0
         APPEND BLANK
         REPLACE COM_CODE WITH '98'
         REPLACE COM_TYPE WITH 'S'
         REPLACE AMOUNT WITH MAMT98   
         REPLACE AMOUNT72 WITH MAMT72_2
      ENDIF
   OTHERWISE
      REPLACE COM_CODE WITH MCOM_CODE
      REPLACE AMOUNT WITH MTOT
      REPLACE AMOUNT72 WITH MTOT_72
   ENDCASE  
   UNLOCK
   SELECT A
ENDDO
CLOSE DATA
SELECT B
DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
SELECT F
DO FOX_USE WITH "CK_REG INDEX CK_REG, CK_DATE", .F.
SELECT D
DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
SELECT E
DO FOX_USE WITH "COM_ADJ INDEX COM_ADJ", .F.

MPAY_AMT = 0

SELECT A
DO FOX_USE WITH "COMS INDEX COMS", .F.

MFIRST_TM = .T.
SEEK 'S'
DO WHILE .NOT. EOF() .AND. COM_TYPE = 'S'
   STORE COM_CODE TO MCOM_CODE
   MTOTAL = 0        
   MAMOUNT72 = 0
   DO WHILE .NOT. EOF() .AND. COM_TYPE = 'S' .AND. COM_CODE = MCOM_CODE
      MTOTAL = MTOTAL + AMOUNT
      MAMOUNT72 = AMOUNT72
      SKIP
   ENDDO
   
   IF MTOTAL <= 0
      LOOP
   ENDIF
   
   SELECT B
   SEEK MCOM_CODE
   IF .NOT. EOF()
      STORE NAME TO MNAME
      STORE STREET TO MSTREET
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
      STORE ZIP TO MZIP
   ELSE
      STORE SPACE(32) TO MNAME
      STORE SPACE(20) TO MSTREET, MCITY
      STORE SPACE(2) TO MSTATE, MZIP
   ENDIF
   
   MTOT = 0    
   STORE DTOC(MCK_DATE) TO MDATE
   STORE SUBSTR(MDATE,1,2) TO MMONTH
   STORE SUBSTR(MDATE,4,2) TO MDAY
   STORE SUBSTR(MDATE,7) TO MYEAR
   
   STORE SPACE(4) TO MCATEGORY1, MCATEGORY2, MCATEGORY3, MCATEGORY4, MCATEGORY5
   STORE 0 TO MAMOUNT1, MAMOUNT2, MAMOUNT3, MAMOUNT4, MAMOUNT5
   STORE MTOTAL TO MAMOUNT1
   STORE '7150' TO MCATEGORY1
   
   SELECT E
   SEEK 'S' + MCOM_CODE
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
   MAMT_DUE = MAMOUNT1 + MAMOUNT2 + MAMOUNT3 + MAMOUNT4 + MAMOUNT5
   ***
   IF MAMT_DUE > 0
      I = 1
      DO WHILE I <= 5
         STORE STR(I,1) TO MI
         IF MAMOUNT&MI <> 0
            SELECT D
            SEEK MCATEGORY&MI
            IF .NOT. EOF()
               IF CK_DESC = SPACE(10)
                  STORE 'MISCELLANEOUS       ' TO MCK_DESC
               ELSE
                  STORE CK_DESC TO MCK_DESC
               ENDIF
            ELSE
               STORE 'MISCELLANEOUS            ' TO MCK_DESC
            ENDIF
            DO CASE
            CASE I = 1
               IF MAMOUNT1 - MAMOUNT72 <> 0
                  SELECT C
                  DO FOX_USE WITH "&MMASTDBF.DISBJRN INDEX &MMASTDBF.DISBJRN, &MMASTDBF.DISB_PO, &MMASTDBF.DISBINV, &MMASTDBF.DISBSTR, &MMASTDBF.DISBINQ", .F.
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE JRNL_MO WITH MMONTH
                  REPLACE JRNL_YR WITH MYEAR
                  REPLACE JRNL_DAY WITH MDAY
                  IF MCHOICE = 'C'
                     REPLACE CK_NBR WITH STR(MCK_NBR,6)
                  ELSE
                     STORE SUBSTR(STR(MCK_NBR + 100000,6),2) TO MWIRE_NBR
                     REPLACE CK_NBR WITH 'W' + MWIRE_NBR       
                  ENDIF
                  REPLACE AMOUNT1 WITH MAMOUNT1 - MAMOUNT72  
                  REPLACE CATEGORY1 WITH MCATEGORY&MI
                  REPLACE ACCT_NBR WITH 'S '+ MCOM_CODE
                  REPLACE ACCT_TYPE WITH 'O'
                  REPLACE SYS_DATE WITH DATE()
                  **REPLACE ACCT_NAME WITH MNAME
                  REPLACE ACCT_NAME WITH MNAME
                  UNLOCK
               ENDIF
               IF MAMOUNT72 <> 0
                  SELECT C
                  DO FOX_USE WITH "L:DISBJRN INDEX L:DISBJRN, L:DISB_PO, L:DISBINV, L:DISBSTR, L:DISBINQ", .F.
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE JRNL_MO WITH MMONTH
                  REPLACE JRNL_YR WITH MYEAR
                  REPLACE JRNL_DAY WITH MDAY
                  IF MCHOICE = 'C'
                     REPLACE CK_NBR WITH STR(MCK_NBR,6)
                  ELSE
                     STORE SUBSTR(STR(MCK_NBR + 100000,6),2) TO MWIRE_NBR
                     REPLACE CK_NBR WITH 'W' + MWIRE_NBR       
                  ENDIF
                  REPLACE AMOUNT1 WITH MAMOUNT72  
                  REPLACE CATEGORY1 WITH MCATEGORY&MI
                  REPLACE ACCT_NBR WITH 'S '+ MCOM_CODE
                  REPLACE ACCT_TYPE WITH 'O'
                  REPLACE SYS_DATE WITH DATE()
                  *REPLACE ACCT_NAME WITH MNAME
                  REPLACE ACCT_NAME WITH MNAME
                  UNLOCK
               ENDIF
            OTHERWISE
               SELECT C
               DO FOX_USE WITH "&MMASTDBF.DISBJRN INDEX &MMASTDBF.DISBJRN, &MMASTDBF.DISB_PO, &MMASTDBF.DISBINV, &MMASTDBF.DISBSTR, &MMASTDBF.DISBINQ", .F.
               DO FILELOCK
               APPEND BLANK
               REPLACE JRNL_MO WITH MMONTH
               REPLACE JRNL_YR WITH MYEAR
               REPLACE JRNL_DAY WITH MDAY
               IF MCHOICE = 'C'
                  REPLACE CK_NBR WITH STR(MCK_NBR,6)
               ELSE
                  STORE SUBSTR(STR(MCK_NBR + 100000,6),2) TO MWIRE_NBR
                  REPLACE CK_NBR WITH 'W' + MWIRE_NBR       
               ENDIF
               REPLACE AMOUNT1 WITH MAMOUNT&MI 
               REPLACE CATEGORY1 WITH MCATEGORY&MI
               REPLACE ACCT_NBR WITH 'S '+ MCOM_CODE
               REPLACE ACCT_TYPE WITH 'O'
               REPLACE SYS_DATE WITH DATE()
               *REPLACE ACCT_NAME WITH MNAME
               REPLACE ACCT_NAME WITH MNAME
               UNLOCK
            ENDCASE
            MLINE = MLINE + 1
         ENDIF
         I = I + 1
      ENDDO
   ELSE
      IF MAMT_DUE = 0
         I = 1
         DO WHILE I <= 5
            STORE STR(I,1) TO MI
            IF MAMOUNT&MI <> 0
               DO CASE
               CASE I = 1
                  IF MAMOUNT1 - MAMOUNT72 <> 0
                     SELECT C
                     DO FOX_USE WITH "&MMASTDBF.DISBJRN INDEX &MMASTDBF.DISBJRN, &MMASTDBF.DISB_PO, &MMASTDBF.DISBINV, &MMASTDBF.DISBSTR, &MMASTDBF.DISBINQ", .F.
                     DO FILELOCK
                     APPEND BLANK
                     REPLACE JRNL_MO WITH MMONTH
                     REPLACE JRNL_YR WITH MYEAR
                     REPLACE JRNL_DAY WITH MDAY
                     REPLACE AMOUNT1 WITH MAMOUNT1 - MAMOUNT72
                     REPLACE CATEGORY1 WITH MCATEGORY&MI
                     REPLACE ACCT_NBR WITH 'S '+ MCOM_CODE
                     REPLACE ACCT_TYPE WITH 'O'
                     REPLACE SYS_DATE WITH DATE()
                     REPLACE ACCT_NAME WITH MNAME
                     REPLACE CK_NBR WITH '     0'
                     UNLOCK
                  ENDIF
                  IF MAMOUNT72 <> 0
                     SELECT C
                     DO FOX_USE WITH "L:DISBJRN INDEX L:DISBJRN, L:DISB_PO, L:DISBINV, L:DISBSTR, L:DISBINQ", .F.
                     DO FILELOCK
                     APPEND BLANK
                     REPLACE JRNL_MO WITH MMONTH
                     REPLACE JRNL_YR WITH MYEAR
                     REPLACE JRNL_DAY WITH MDAY
                     REPLACE AMOUNT1 WITH MAMOUNT72
                     REPLACE CATEGORY1 WITH MCATEGORY&MI
                     REPLACE ACCT_NBR WITH 'S '+ MCOM_CODE
                     REPLACE ACCT_TYPE WITH 'O'
                     REPLACE SYS_DATE WITH DATE()
                     REPLACE ACCT_NAME WITH MNAME
                     REPLACE CK_NBR WITH '     0'
                     UNLOCK
                  ENDIF
               OTHERWISE
                  SELECT C
                  DO FOX_USE WITH "&MMASTDBF.DISBJRN INDEX &MMASTDBF.DISBJRN, &MMASTDBF.DISB_PO, &MMASTDBF.DISBINV, &MMASTDBF.DISBSTR, &MMASTDBF.DISBINQ", .F.
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE JRNL_MO WITH MMONTH
                  REPLACE JRNL_YR WITH MYEAR
                  REPLACE JRNL_DAY WITH MDAY
                  REPLACE AMOUNT1 WITH MAMOUNT&MI 
                  REPLACE CATEGORY1 WITH MCATEGORY&MI
                  REPLACE ACCT_NBR WITH 'S '+ MCOM_CODE
                  REPLACE ACCT_TYPE WITH 'O'
                  REPLACE SYS_DATE WITH DATE()
                  REPLACE ACCT_NAME WITH MNAME
                  REPLACE CK_NBR WITH '     0'
                  UNLOCK
               ENDCASE
               MLINE = MLINE + 1
            ENDIF
            I = I + 1
         ENDDO
      ENDIF
   ENDIF
   
   MTOT = MTOT + MAMT_DUE
   
   IF MTOT > 0
      SELECT A
      MPAY_AMT = MPAY_AMT + MTOT
      SELECT A
   ELSE
      *** FOR CHECK AMOUNTS OF ZERO - WHERE RESERVE WITHHELD EQUAL AMOUNT PAID
      IF MTOT = 0
         SELECT F
         DO FILELOCK
         APPEND BLANK
         REPLACE PAY_CODE WITH 'S ' + MCOM_CODE
         REPLACE PAY_NAME WITH MNAME        
         REPLACE CK_DATE WITH MCK_DATE
         REPLACE CK_NBR WITH '     0'
         REPLACE AMOUNT WITH MTOT
         REPLACE PAY_TYPE WITH 'O' 
         REPLACE DESCRIP WITH 'COMMISSIONS'
         REPLACE SYS_DATE WITH DATE()
         UNLOCK
         SELECT A
      ENDIF
   ENDIF
ENDDO

DO CASE
CASE MCHOICE = 'C'
   *************************************************
   **** PRINT THE CHECK TO THE PAYROLL ACCOUNT *****
   **** OLD MFP WAY OF DOING THINGS            *****
   *************************************************
   
   MLINE = 1
   ? SPACE(6) + TRIM(MNAME)
   ? SPACE(80) + 'CHECK NO. ' + STR(MCK_NBR,6)
   ? '      INVOICE NO.        DESCRIPTION                       REMITTANCE'
   ?
   MLINE = MLINE + 4
   MTOT = MPAY_AMT
   SELECT A
   
   
   STORE 'COMMISSIONS' + SPACE(9) TO MDESCRIP
   STORE SPACE(12)  TO MSUP_INV
   ? SPACE(6) + MSUP_INV + SPACE(7)
   ?? MCK_DESC
   ?? SPACE(09)
   ?? TRANSFORM(MPAY_AMT, '999,999.99')
   ?
   ?
   ?
   ?
   
   MLINE = MLINE + 5
   ***** NOW SKIP DOWN SO MANY LINES TO GET TO THE BOTTOM OF THE STUB AND READY TO PRINT
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
   **? SPACE(8) + 'MIDWEST FOOD & POULTRY PAYROLL'
   ? SPACE(8) + MNAME
   ? SPACE(8) + MSTREET
   ? SPACE(8) + TRIM(MCITY) + ', ' + MSTATE + SPACE(2) + MZIP
   MLINE = MLINE + 5
   X = 1
   DO WHILE X <= 8
      ?
      X = X + 1
   ENDDO
CASE MCHOICE = 'L'   
   MTOT = MPAY_AMT
   MCHK_AMT = MTOT
   
   
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
   
   
   STORE 'COMMISSION/CONSULTING FEE' + SPACE(9) TO MDESCRIP
   
   *** BACK TO MEDIUM STROKE PRINT
   ?? CHR(27) + '(s0B'
   
   ? SPACE(6) + MDESCRIP + SPACE(23) + TRANSFORM(MPAY_AMT, '999,999.99')
   ?
   ?
   ?
   ?
   
   ?
   ?
   
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
   
   ? SPACE(6) + MDESCRIP + SPACE(23) + TRANSFORM(MPAY_AMT, '999,999.99')
   ?
   ?
   ?
   ?
   
   ?
   ?
   
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
ENDCASE

**** DO THE CHECK REGISTER HERE
SELECT F
DO FILELOCK
APPEND BLANK
REPLACE PAY_NAME WITH MNAME
IF MCHOICE = 'C' .OR. MCHOICE = 'L'
   REPLACE CK_NBR WITH STR(MCK_NBR,6)
ELSE
   STORE SUBSTR(STR(MCK_NBR + 100000,6),2) TO MWIRE_NBR
   REPLACE CK_NBR WITH 'W' + MWIRE_NBR       
ENDIF
REPLACE CK_DATE WITH MCK_DATE
REPLACE AMOUNT WITH MTOT
REPLACE PAY_TYPE WITH 'O' 
REPLACE DESCRIP WITH 'COMMISSIONS'
REPLACE SYS_DATE WITH DATE()
UNLOCK

MCK_NBR = MCK_NBR + 1
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
SELECT A
DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
DO FILELOCK

DO CASE
CASE MCHOICE = 'C'
   REPLACE CK_NBR WITH MCK_NBR
CASE MCHOICE = 'L'
   REPLACE LCK_NBR WITH MCK_NBR
OTHERWISE
   REPLACE WIRE_NBR WITH MCK_NBR
ENDCASE

REPLACE CK_PRINT WITH 'N'
UNLOCK

CLOSE DATA

SELECT A
DO FOX_USE WITH "COMLED INDEX COMLED, COMPD", .F.
DO WHILE .NOT. EOF()
   IF COM_PD <> ' ' .OR. COM_TYPE <> 'S'
      SKIP
      LOOP
   ENDIF
   IF APRVD_FLG = 'Y'
      DO FILELOCK 
      REPLACE COM_PD WITH 'Y'
      REPLACE PAID_DATE WITH DATE()
      UNLOCK
   ENDIF
   SKIP
ENDDO
CLOSE DATA
RETURN
* EOF: MCOM_CHK.PRG
*Formatted by: ToolBox Ver. 1.2  on 1/5/16 at 10:21 AM.
