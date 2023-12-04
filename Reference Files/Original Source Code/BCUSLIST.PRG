*************
* Program.: BCUSLIST.PRG
* Author..: Grace Keller
* Date....: 10/26/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: CUSTOMER LISTING 
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MTITLE = ' - BILL TO CUSTOMER LISTING'

CLEAR
@ 01,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@  2,0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
STORE 'NO ' TO MYES_NO
STORE CTOD('') TO MACT_DATE
@ 10,10 SAY 'Do you want Credit Information Printed (YES/NO)? ' get myes_no picture '@!'
@ 12,10 say 'Only Select Customers with Activity After than this Date: ' GET MACT_DATE
@ 13,10 SAY '   Note: Leave Date Blank if Selecting ALL Customers'
READ
@ 10,01 CLEAR TO 13,78
STORE ' ' TO MACTION
DO PRT_SET
IF MACTION <> 'C'
   RETURN
ENDIF 

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
?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'

*** LETTER SIZE PAPER
?? CHR(27) + '&l2A'

*** PORTRAIT MODE
?? CHR(27) + '&l0O'

SELECT A
DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
SELECT B
DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
MLINE = 99
MPAGE_NO = 0
MFIRST_TM = .T.
DO WHILE .NOT. EOF()
   
   IF MACT_DATE <> CTOD('')
      SELECT B
      SEEK A->BBUYCODE
      IF SHIP_DATE < MACT_DATE
         SELECT A
         SKIP
         LOOP
      ENDIF
      SELECT A
   ENDIF
   IF MLINE > 58
      IF MFIRST_TM
         MFIRST_TM = .F.
      ELSE
         EJECT
      ENDIF
      MLINE = 2
      MPAGE_NO = MPAGE_NO + 1
      @ MLINE,5 SAY 'PAGE  ' + str(mpage_no,3)
      @ mline,27 say 'BILL TO CUSTOMER LISTING' 
      @ MLINE,65 SAY DTOC(DATE())
      MLINE = MLINE + 2
      @ MLINE,5 SAY 'NAME/ADDRESS'
      @ MLINE,45 SAY 'PHONE'
      MLINE = MLINE + 2
   ENDIF
   @ MLINE,5 SAY NAME       
   @ MLINE,45 SAY '(' + AREA_CODE + ')' + TRANSFORM(PHONE, '@R 999-9999')
   MLINE = MLINE + 1
   @ MLINE,5 SAY STREET
   IF ZIP4 = SPACE(4)
      STORE ZIP TO MZIP
   ELSE
      STORE ZIP + '-' + ZIP4 TO MZIP
   ENDIF
   MLINE = MLINE + 1
   @ MLINE,5 SAY TRIM(CITY) + ', ' + STATE + '  ' + MZIP
   IF MYES_NO = 'YES'
      MLINE = MLINE + 1
      @ MLINE,5 SAY '    Credit Limit: '             
      @ MLINE,25 SAY CRED_LIM PICTURE '9999999.99'
      IF LET_CRD <> 0
         MLINE = MLINE + 1
         @ MLINE,5 SAY 'Letter of Credit: $ '
         @ MLINE,25 SAY LET_CRD PICTURE '9999999.99'
         @ MLINE,38 SAY 'Begin: ' + dtoc(beg_date) + space(5) + 'End: ' + dtoc(end_date)
      ENDIF
   ENDIF
   MLINE = MLINE + 2
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
RETURN
* EOF: BCUSLIST.PRG
*Formatted by: ToolBox Ver. 1.2  on 7/22/14 at 2:30 PM.
