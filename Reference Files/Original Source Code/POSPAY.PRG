*************************
* Program.: POSPAY.PRG
* Author..: GRACE KELLER
* Date....: 04/05/17
* Notice..: Copyright 1987,1988 Solid Software, Inc., All Rights Reserved
* Notes...: CREATE POSITVIE PAY FILE FOR COMMERCE BANK
*

CLEAR
@ 00,01 SAY MCOMPANY
@ 01,01 SAY MPROGRAM + ' - CREATE COMMERCE BANK POSITIVE PAY FILE'
@ 01,69 SAY DATE()
@ 02,00 TO 22,79
MS_DATE = DATE()
ME_DATE = DATE()
MLIST_DET = 'N'
STORE 0 TO MBEG_NBR, MEND_NBR
store 'SOUTHERN' TO MBANK

MACTION = 2
DO WHILE MACTION = 2
   @ 08,10 SAY 'CHECK STARTING DATE: ' GET MS_DATE
   @ 10,10 SAY 'CHECK   ENDING DATE: ' GET ME_DATE
   @ 14,06 SAY 'OPTIONAL BEGIN CHECK NBR:          ENDING CHECK NBR:      '
   @ 14,33 GET MBEG_NBR PICTURE '#####'
   @ 14,60 GET MEND_NBR PICTURE '#####'
   @ 16,09 SAY 'Checks for SOUTHERN OR COMMERCE: ' GET MBANK picture '@!'
   READ
   
   IF ME_DATE < MS_DATE
      @ 23,00 CLEAR
      MJUNK = 'ENDING DATE MUST NOT BE BEFORE STARTING DATE - PRESS RETURN TO CONTINUE'
      @ 23,02 GET MJUNK
      READ
      @ 23,00 CLEAR
      LOOP
   ENDIF
   
   MACTION = 1
ENDDO

MACTION = 'C'
@ 20,05 SAY "READY PRINTER - PRESS 'C' TO CONTINUE, 'A' TO ABORT";
   GET MACTION PICTURE '@!'
READ

IF MACTION = 'A'
   RETURN
ENDIF

IF MBEG_NBR <> 0
   IF MEND_NBR = 0 .OR. MEND_NBR < MBEG_NBR
      STORE MBEG_NBR TO MEND_NBR
   ENDIF
ENDIF

SELECT C
DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE" ,.F.

SELECT D
DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.

SELECT A
DO FOX_USE WITH "CK_REG INDEX CK_DATE", .F.
STORE STR(YEAR(MS_DATE),4) TO MS_YR
STORE SUBSTR(DTOC(MS_DATE),1,2) TO MS_MO
STORE SUBSTR(DTOC(MS_DATE),4,2) TO MS_DY

SEEK MS_YR + MS_MO + MS_DY
IF EOF()
   @ 23,00 CLEAR
   MJUNK = 'NO CHECKS ON FILE FOR STARTING DAY - PRESS RETURN TO CONTINUE'
   @ 23,02 GET MJUNK
   READ
   @ 23,00 CLEAR
   RETURN
ENDIF

IF MBANK = 'SOUTHERN'

   SELECT B
   USE POSPAY EXCLUSIVE
   DELETE ALL
   PACK

   SELECT A
   
   DO WHILE .NOT. EOF() .AND. CK_DATE <= ME_DATE
      
      ** IF AMOUNT IS ZERO OR CLEARED - SKIP ON BY
      
      IF AMOUNT = 0 
         SKIP
         LOOP
      ENDIF
      
      IF CLEAR_FLG = 'Y'
         SKIP
         LOOP
      ENDIF
      
      *** SKIP CREDIT DEBIT MATCHES, ACH CHECKS AND MANUALLY ENTERED CHECKS
      
      STORE SUBSTR(CK_NBR,1,1) TO MCHKOUT
      IF MCHKOUT = ' ' .OR. MCHKOUT = '0' .OR. MCHKOUT = '1'
      ELSE
         IF MCHKOUT = '2' .OR. MCHKOUT = '3' .OR. MCHKOUT = '4'
         ELSE
            IF MCHKOUT = '5' .OR. MCHKOUT = '6' .OR. MCHKOUT = '7'
            ELSE
               IF MCHKOUT = '8' .OR. MCHKOUT = '9'
               ELSE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      
      IF MBEG_NBR <> 0
         IF VAL(CK_NBR) < MBEG_NBR .OR. VAL(CK_NBR) > MEND_NBR
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      SELECT B
      APPEND BLANK
      
      REPLACE PP_DATE WITH DTOC(A->CK_DATE)
      REPLACE PP_CKNBR WITH A->CK_NBR
      REPLACE PP_CKNBR WITH LTRIM(PP_CKNBR)
      IF A->PAY_NAME <> SPACE(32)
         REPLACE PP_NAME WITH A->PAY_NAME
      ELSE
         DO CASE
         CASE A->PAY_TYPE = 'S'
            SELECT C
            SEEK A->PAY_CODE
            SELECT B
            REPLACE PP_NAME WITH C->NAME
            
         CASE A->PAY_TYPE = 'F'
            SELECT D
            SEEK A->PAY_CODE
            SELECT B
            REPLACE PP_NAME WITH D->NAME
            
         ENDCASE
      ENDIF
      SELECT B
      REPLACE PP_AMT WITH TRANSFORM(A->AMOUNT, '999999999.99')
      REPLACE PP_AMT WITH LTRIM(PP_AMT)
      REPLACE PP_CODE WITH 'I'
      
      SELECT A
      SKIP
   ENDDO
   
   STORE DTOC(DATE()) TO MDATE
   STORE SUBSTR(MDATE,1,2) + SUBSTR(MDATE,4,2) + SUBSTR(MDATE,9,2) TO MDATE
   MFILE = 'PP' + MDATE + '.TXT' 
   
   IF FILE("S:\POSPAY\&MFILE")
      I = 1
      DO WHILE I <= 9
         IF I = 9
            MFILE = 'P9' + MDATE + '.TXT' 
            I = 10
         ELSE
            MFILE = 'P' + STR(I,1) + MDATE + '.TXT' 
            IF .NOT. FILE("S:\POSPAY\&MFILE")
               I = 10
            ELSE
               I = I + 1
            ENDIF
         ENDIF
      ENDDO
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
   
   *** LETTER SIZE PAPER
   ?? CHR(27) + '&l2A'
   
   *** PORTRAIT MODE
   ?? CHR(27) + '&l0O'
   
   MLINE = 99
   
   SELECT B
   GOTO TOP
   MTOT_CHK = 0
   
   DO WHILE .NOT. EOF()
      IF MLINE > 56
         IF MLINE <> 99  
            EJECT
         ENDIF
         MTITLE = 'SOUTHERN BANK POSITIVE PAY FILE'
         ?  DTOC(DATE()) + SPACE(10) + MTITLE
         ?  TIME() + SPACE(21) + 'FILE: ' + MFILE
         ?
         ? 'CHK NBR     CHK AMOUNT      DATE     ACT  PAYEE'
         MLINE = 4
      ENDIF
      
      ? SPACE(1)
      ?? PP_CKNBR + SPACE(2)
      ?? TRANSFORM(VAL(PP_AMT), '99,999,999.99')  + SPACE(3)
      MTOT_CHK = MTOT_CHK + VAL(PP_AMT)
      ?? PP_DATE + SPACE(3)
      ?? PP_CODE + SPACE(3)
      ?? PP_NAME
      MLINE = MLINE + 1
      SKIP
   ENDDO 
   ? SPACE(1)
   ?? 'TOTAL ' + SPACE(1)
   ?? TRANSFORM(MTOT_CHK, '999,999,999.99') 
   ?
   EJECT
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
   
   CLOSE DATA
   
   SELECT B
   USE POSPAY EXCLUSIVE
   COPY TO S:\POSPAY\&MFILE TYPE DELIMITED WITH "" WITH CHARACTER TAB
   CLOSE ALL
   
ELSE
   
   SELECT B
   USE POSPAYC EXCLUSIVE
   DELETE ALL
   PACK

   SELECT A
   
   DO WHILE .NOT. EOF() .AND. CK_DATE <= ME_DATE
      
      ** IF AMOUNT IS ZERO OR CLEARED - SKIP ON BY
      
      IF AMOUNT = 0 
         SKIP
         LOOP
      ENDIF
      
      IF CLEAR_FLG = 'Y'
         ** IF CLEARED - BUT VOIDED - NEED TO SEND THE VOID
         IF VOID_MAN <> 'V'
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      *** SKIP CREDIT DEBIT MATCHES, ACH CHECKS AND MANUALLY ENTERED CHECKS
      
      STORE SUBSTR(CK_NBR,1,1) TO MCHKOUT
      IF MCHKOUT = ' ' .OR. MCHKOUT = '0' .OR. MCHKOUT = '1'
      ELSE
         IF MCHKOUT = '2' .OR. MCHKOUT = '3' .OR. MCHKOUT = '4'
         ELSE
            IF MCHKOUT = '5' .OR. MCHKOUT = '6' .OR. MCHKOUT = '7'
            ELSE
               IF MCHKOUT = '8' .OR. MCHKOUT = '9'
               ELSE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      
      IF MBEG_NBR <> 0
         IF VAL(CK_NBR) < MBEG_NBR .OR. VAL(CK_NBR) > MEND_NBR
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      SELECT B
      APPEND BLANK
      ** AMERI ACCT NBR
      REPLACE ACCT_NBR WITH '000271530805-1   '
      ** RT NBR
      REPLACE ROUTE_NBR WITH '101000019      '
      REPLACE CHK_NBR WITH LTRIM(A->CK_NBR)
      
      REPLACE CHK_AMT WITH   A->AMOUNT
      REPLACE CHK_DATE WITH  A->CK_DATE
      
      IF A->PAY_NAME = SPACE(32)
         IF A->PAY_TYPE = 'S'
            SELECT C
            SEEK A->PAY_CODE
            SELECT B
            REPLACE VEND_NAME WITH C->NAME
         ELSE
            IF A->PAY_TYPE = 'F'
               SELECT D
               SEEK A->PAY_CODE
               SELECT B
               REPLACE VEND_NAME WITH D->NAME
            ENDIF
         ENDIF
      ELSE
         REPLACE VEND_NAME WITH A->PAY_NAME
      ENDIF
      
      
      IF A->VOID_MAN = 'V'
         REPLACE BANK_ACTN WITH 'V'
      ELSE
         REPLACE BANK_ACTN WITH ' '
      ENDIF
      SELECT A
      SKIP
   ENDDO
   
   STORE DTOC(DATE()) TO MDATE
   STORE SUBSTR(MDATE,1,2) + SUBSTR(MDATE,4,2) + SUBSTR(MDATE,9,2) TO MDATE
   MFILE = 'PP' + MDATE + '.TXT' 
   
   IF FILE("S:\POSPAY\&MFILE")
      I = 1
      DO WHILE I <= 9
         IF I = 9
            MFILE = 'P9' + MDATE + '.TXT' 
            I = 10
         ELSE
            MFILE = 'P' + STR(I,1) + MDATE + '.TXT' 
            IF .NOT. FILE("S:\POSPAY\&MFILE")
               I = 10
            ELSE
               I = I + 1
            ENDIF
         ENDIF
      ENDDO
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
   
   *** LETTER SIZE PAPER
   ?? CHR(27) + '&l2A'
   
   *** PORTRAIT MODE
   ?? CHR(27) + '&l0O'
   
   MLINE = 99
   
   SELECT B
   GOTO TOP
   
   DO WHILE .NOT. EOF()
      IF MLINE > 56
         IF MLINE <> 99  
            EJECT
         ENDIF
         MTITLE = 'COMMERCE BANK POSITIVE PAY FILE'
         ?  DTOC(DATE()) + SPACE(10) + MTITLE
         ?  TIME() + SPACE(21) + 'FILE: ' + MFILE
         ?
         ? 'CHK NBR     CHK AMOUNT      DATE     ACT  PAYEE'
         MLINE = 4
      ENDIF
      
      ? SPACE(1)
      ?? SUBSTR(CHK_NBR,1,6) + SPACE(3)
      ?? TRANSFORM(CHK_AMT, '9,999,999.99') + SPACE(3)
      IF CHK_DATE < DATE()
         ?? DTOC(DATE()) + SPACE(4)
      ELSE
         ?? DTOC(CHK_DATE) + SPACE(4)
      ENDIF
      ?? BANK_ACTN + SPACE(2)
      ?? VEND_NAME
      MLINE = MLINE + 1
      SKIP
   ENDDO 
   EJECT
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
   
   
   SET CONSOLE OFF
   SET PRINT TO "S:\POSPAY\&MFILE"
   SET DEVICE TO PRINT
   SET PRINT ON
   
   SELECT B
   GOTO TOP
   
   MFIRST = .T.
   
   DO WHILE .NOT. EOF()
      IF MFIRST
         ?? ACCT_NBR
         MFIRST = .F.
      ELSE
         ? ACCT_NBR
      ENDIF
      
      ?? ROUTE_NBR
      ?? VEND_NAME
      ?? CHK_NBR
      
      IF CHK_DATE < DATE()
         STORE DTOC(DATE()) TO MCHK_DATE
      ELSE
         STORE DTOC(CHK_DATE) TO MCHK_DATE
      ENDIF
      
      STORE SUBSTR(MCHK_DATE,1,2) + SUBSTR(MCHK_DATE,4,2) + SUBSTR(MCHK_DATE,7,4) TO MCHK_DATE
      ?? MCHK_DATE  
      
      MCHK_AMT = CHK_AMT+100000000000
      STORE TRANSFORM(MCHK_AMT, '999999999999.99') TO  MCHK_AMT
      STORE SUBSTR(MCHK_AMT,2,11) + SUBSTR(MCHK_AMT,14,2) TO MCHK_AMT
      ?? MCHK_AMT
      
      ?? BANK_ACTN
      ?? SPACE(32)
      SKIP
   ENDDO
   
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   
   CLOSE DATA
ENDIF

RETURN

* EOF: POSPAY.PRG
*Formatted by: ToolBox Ver. 1.2  on 9/13/22 at 10:02 AM.
