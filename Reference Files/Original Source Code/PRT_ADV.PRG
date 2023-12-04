**********
* Program.: PRT_ADV.PRG
* Author..: Grace Keller
* Date....: 01/25/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: APPROVE SUPPLIER INVOICES FOR PAYMENTS
*
SET PROC TO REC_PROC
MTOTAL = 0
MTITLE = ' - PRINT DEDUCTION ADVISEMENTS'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 24,79
STORE 'N' TO MYES_NO
@ 10,5 SAY 'Is this a REPRINT of Deduction Advisements (Y/N) ? ' GET MYES_NO PICTURE '@!'
READ
IF MYES_NO = 'Y'
   DO REP_ADV
   RETURN
ENDIF
@ 10,1 CLEAR TO 10,78
STORE 'N' TO MYES_NO, MPURCH_SEL
@ 10,5 SAY 'PRINT ADVISEMENTS FOR A SPECIFIC SUPPLIER (Y/N)? ' GET MYES_NO PICTURE '@!'
@ 12,5 SAY '           SELECT SPECIFIC PURCHASE ORDER (Y/N)? ' GET MPURCH_SEL PICTURE '@!'

READ
IF MYES_NO = 'Y'
   MNAME_FD = .F.
   DO RSUPSEL3
   IF .NOT. MNAME_FD
      RETURN
   ENDIF
   STORE RSUPCODE TO MSAVECODE
   USE
ELSE
   STORE SPACE(4) TO MSAVECODE
ENDIF
STORE SPACE(2) TO SSALESMAN
STORE SPACE(4) TO SPO_NBR
STORE SPACE(1) TO SPO_SUFFIX
IF MPURCH_SEL = 'Y'
   @ 15,16 SAY 'ENTER PURCHASE ORDER NUMBER: ' 
   @ 15,46 GET SSALESMAN PICTURE '##'
   @ 15,48 SAY '-'
   @ 15,49 GET SPO_NBR PICTURE '####'
   @ 15,53 SAY '-'
   @ 15,54 GET SPO_SUFFIX PICTURE '#'
   READ
ENDIF


STORE ' ' TO MPRT_ACT
DO PRT_SET 
IF MPRT_ACT <> 'C'
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

?? chr(27) + 'C' + CHR(33)
SELECT F
DO FOX_USE WITH "PRT_NOTE INDEX PRT_NOTE", .F.

SELECT E
DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
SELECT D
DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.

SELECT C
DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.

SELECT B
DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.

SELECT A
DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
MFIRST_TM = .T.

DO WHILE .NOT. EOF()
   IF PRT_ADV <> ' '
      SKIP
      LOOP
   ENDIF
   IF HOLD_FLG <> ' ' .OR. ADDL_DUE <> ' '
      SKIP
      LOOP
   ENDIF
   IF MSAVECODE <> SPACE(4)
      IF RSUPCODE <> MSAVECODE
         SKIP
         LOOP
      ENDIF
   ENDIF
   IF SSALESMAN <> SPACE(2) .OR. SPO_NBR <> SPACE(4)
      IF SALESMAN <> SSALESMAN .OR. PO_NBR <> SPO_NBR .OR. PO_SUFFIX <> SPO_SUFFIX
         SKIP
         LOOP
      ENDIF
   ENDIF
   STORE RSUPCODE TO MRSUPCODE
   SELECT D
   SEEK MRSUPCODE
   IF EOF()
      STORE 'SUPPLIER NOT ON FILE' TO MRSUPNAME
      STORE SPACE(1) TO MCITY, MSTATE, MZIP
   ELSE
      STORE NAME TO MRSUPNAME
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
      STORE ZIP TO MZIP
   ENDIF
   SELECT A
   DO WHILE .NOT. EOF() .AND. RSUPCODE = MRSUPCODE
      IF PRT_ADV <> ' '
         SKIP
         LOOP
      ENDIF
      IF SSALESMAN <> SPACE(2) .OR. SPO_NBR <> SPACE(4)
         IF SALESMAN <> SSALESMAN .OR. PO_NBR <> SPO_NBR .OR. PO_SUFFIX <> SPO_SUFFIX
            SKIP
            LOOP
         ENDIF
      ENDIF
      STORE SALESMAN TO MSALESMAN
      STORE PO_NBR TO MPO_NBR
      STORE PO_SUFFIX TO MPO_SUFFIX
      STORE SUP_INV TO MSUP_INV
      
      IF DEB_CRD = ' '
         SELECT B
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF .NOT. EOF()
            IF SHORT_FLG = ' '
               SELECT A
               SKIP
               LOOP
            ENDIF
         ENDIF
         SELECT A
      ENDIF
      
      MTIMES = 1
      DO WHILE MTIMES <= 1
         MLINE = 1
         ? SPACE(5) + MRSUPNAME
         ? SPACE(5) + TRIM(MCITY) + ', ' + MSTATE + SPACE(2) + MZIP   
         ?
         ? SPACE(5) + 'INVOICE NUMBER: ' + MSUP_INV
         ?? SPACE(11) + 'MIDWEST PO #: '
         IF MSALESMAN <> SPACE(2)
            ?? MSALESMAN + '-'
         ELSE
            ?? SPACE(3)
         ENDIF
         ?? MPO_NBR
         IF MPO_SUFFIX <> ' '
            ?? '-' + MPO_SUFFIX
         ENDIF
         ?
         ? 'ITEM CASES DESCRIPTION                                   S/W CASE   TOTAL S/W    PRICE     AMOUNT'
         ?
         IF DEB_CRD = ' '
            SELECT C
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            MTOTAL = 0
            DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
               ? SPACE(1) + ITEM_NBR + '.' + SPACE(1) + TRANSFORM(QTY, '@Z 9999')
               ?? SPACE(1)
               STORE SPACE(6) TO MPART1
               STORE SPACE(8) TO MPART2, MPART3, MPART6
               STORE SPACE(20) TO MPART4
               STORE SPACE(13) TO MPART5
               SELECT E
               IF C->FRH_FRZ <> SPACE(2)
                  SEEK 'F' + C->FRH_FRZ
                  IF .NOT. EOF()
                     STORE SUBSTR(DESC,1,6) TO MPART1
                  ENDIF
               ENDIF
               IF C->GRADE <> SPACE(1)
                  SEEK 'G' + C->GRADE
                  IF .NOT. EOF()
                     STORE SUBSTR(DESC,1,8) TO MPART3
                  ENDIF
               ENDIF
               IF C->PACKAGED <> SPACE(1)
                  SEEK 'D' + C->PACKAGED
                  IF .NOT. EOF()
                     STORE SUBSTR(DESC,1,8) TO MPART3
                  ENDIF
               ENDIF
               
               IF C->PROD_DESC <> 'BROKERAGE'
                  SEEK 'R' + C->PROD_DESC
                  IF .NOT. EOF()
                     STORE DESC TO MPART4 
                  ENDIF
               ENDIF
               
               IF C->SIZE <> SPACE(5)
                  SEEK 'Z' + C->SIZE
                  IF .NOT. EOF()
                     STORE SUBSTR(DESC,1,13) TO MPART5
                  ENDIF
               ENDIF
               IF C->PACKED <> SPACE(4)
                  SEEK 'S' + C->PACKED
                  IF .NOT. EOF()
                     STORE SUBSTR(DESC,1,8) TO MPART6
                  ENDIF
               ENDIF
               STORE LEN(TRIM(MPART1)) TO MLEN1
               STORE LEN(TRIM(MPART2)) TO MLEN2
               STORE LEN(TRIM(MPART3)) TO MLEN3
               STORE LEN(TRIM(MPART4)) TO MLEN4
               STORE LEN(TRIM(MPART5)) TO MLEN5
               STORE LEN(TRIM(MPART6)) TO MLEN6
               MDESC = SPACE(1)
               
               IF MLEN1 <> 0
                  STORE MDESC + TRIM(MPART1) + ' ' TO MDESC
               ENDIF
               IF MLEN2 <> 0
                  STORE MDESC + TRIM(MPART2) + ' ' TO MDESC
               ENDIF
               IF MLEN3 <> 0
                  STORE MDESC + TRIM(MPART3) + ' ' TO MDESC
               ENDIF
               IF MLEN4 <> 0
                  STORE MDESC + TRIM(MPART4) + ' ' TO MDESC
               ENDIF
               IF MLEN5 <> 0
                  STORE MDESC + TRIM(MPART5) + ' ' TO MDESC
               ENDIF
               STORE MDESC + TRIM(MPART6) TO MDESC
               
               
               IF LEN(MDESC) < 44
                  ?? MDESC
                  STORE LEN(MDESC) TO MTOT_LEN
               ELSE
                  ?? SUBSTR(MDESC,1,44)
                  STORE 44 TO MTOT_LEN
               ENDIF
               
               MDIFF = 45 - MTOT_LEN
               ?? SPACE(MDIFF) + SPACE(1)  
               
               SELECT C
               IF SHRT_LBS = 0
                  ?? SPACE(11) + '  NO S/W' + SPACE(18) + '0.00'
               ELSE
                  ?? SPACE(1) + TRANSFORM(SHRT_BOX, '@Z 999.99') + SPACE(2)
                  IF BILL_PRI <> 0
                     STORE BILL_PRI TO MPRICE
                  ELSE
                     STORE PUR_PRICE TO MPRICE
                  ENDIF
                  ***STORE ROUND((SHRT_LBS * MPRICE),2) TO MSW_AMT
                  MVAL1   = SHRT_LBS * MPRICE
                  IF MVAL1 <> 0
                     MVAL = INT(MVAL1*100)
                     IF (ABS(MVAL1) * 100) - ABS(MVAL) > .49
                        IF MVAL1 >= 0
                           MVAL1 = (MVAL + 1) / 100
                        ELSE
                           MVAL1 = (MVAL - 1) / 100
                        ENDIF
                     ELSE
                        MVAL1 = MVAL / 100
                     ENDIF
                  ENDIF
                  
                  *IF MVAL1 >= 0
                  *   MVAL1 = INT((MVAL1+.005) * 100) / 100
                  *ELSE
                  *   MVAL1 = INT((MVAL1-.005) * 100) / 100
                  *ENDIF
                  
                  MSW_AMT = MVAL1 
                  ?? SPACE(1) + TRANSFORM(SHRT_LBS, '@Z 999999.99') + SPACE(4)+ TRANSFORM(MPRICE, '99.9999')  + SPACE(1) + TRANSFORM(-1 * MSW_AMT, '@Z 999,999.99')
                  MTOTAL = MTOTAL + (-1 * MSW_AMT)
               ENDIF
               SKIP
            ENDDO
            SELECT B
            ***** NOW CHECK FOR SUPPLIER ADJUSTMENTS
            *           SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF .NOT. EOF()
               IF SUP_AMT1 <> 0 .OR. SUP_REAS1 <> SPACE(15)
                  ?
                  ? SPACE(5) + SUP_REAS1 + SPACE(67) +  TRANSFORM(SUP_AMT1, '@Z 999,999.99')
                  MTOTAL = MTOTAL + SUP_AMT1
               ENDIF
               IF SUP_AMT2 <> 0 .OR. SUP_REAS2 <> SPACE(15)
                  ?
                  ? SPACE(5) + SUP_REAS2 + SPACE(67) +  TRANSFORM(SUP_AMT2, '@Z 999,999.99')
                  MTOTAL = MTOTAL + SUP_AMT2
               ENDIF
               IF SUP_PALL <> 0 
                  ?
                  ? SPACE(11) + 'PALLETS  ' + SPACE(67) +  TRANSFORM(SUP_PALL, '@Z 999,999.99')
                  MTOTAL = MTOTAL + SUP_PALL
               ENDIF
               SELECT F
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               IF .NOT. EOF()     
                  IF SUP_COMMT <> SPACE(60)
                     ?
                     ? SPACE(5) + SUP_COMMT
                  ENDIF
               ENDIF
            ENDIF
            ?
            ? SPACE(5) + 'TOTAL ADJUSTMENTS: ' + SPACE(63) + TRANSFORM(MTOTAL, '999,999.99')
         ELSE
            ? SPACE(5) + REASON + SPACE(67) + TRANSFORM(AMT_DUE, '@Z 999,999.99')
            SELECT F
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF .NOT. EOF()     
               IF SUP_COMMT <> SPACE(60)
                  ?
                  ? SPACE(5) + SUP_COMMT
               ENDIF
            ENDIF
            ?
            ? SPACE(5) + 'TOTAL ADJUSTMENT: ' + SPACE(64) + TRANSFORM(A->AMT_DUE, '999,999.99')
         ENDIF
         
         EJECT
         MTIMES = MTIMES + 1
         SELECT A
      ENDDO
      
      SELECT A
      DO RECLOCK
      REPLACE PRT_ADV WITH 'P'
      UNLOCK
      SKIP
   ENDDO
ENDDO
?? chr(27) + 'C' + CHR(66)

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON
IF MPRINTER <> 'DONOTPRINT'
   RUN &MPRINTIT
ENDIF
CLOSE DATA

RETURN
* EOF: PRT_ADV.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/12/94 at 3:45 PM.
