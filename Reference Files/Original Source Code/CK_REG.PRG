**********
* Program.: CK_REG.PRG
* Author..: GRACE KELLER
* Date....: 03/21/88
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: CHECK REGISTER REPORT     
*

MTITLE = ' - DAILY CHECK REGISTER'

CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
**** GET DATE FOR THIS REPORT
STORE DATE() TO MCK_DATE
STORE 'D' TO MDISP_PRT
STORE 2 TO MACTION      
DO WHILE MACTION = 2      
   @ 08,5 SAY '            ENTER REPORT DATE: '
   @ 08,37 GET MCK_DATE
   @ 10,5 SAY 'DISPLAY OR PRINT REPORT (D/P):'
   @ 10,37 GET MDISP_PRT PICTURE '@!'
   
   STORE 1 TO MACTION
   @ 23,00 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   IF MACTION = 1
      IF DTOC(MCK_DATE) = '  /  /  '
         @ 24,0 CLEAR
         mwait = ' '
         @ 24,1 SAY 'NO DATE ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
         READ
         MACTION = 2
         @ 24,0 CLEAR
         LOOP 
      ENDIF
   ENDIF
ENDDO

IF MACTION = 3
   RETURN
ENDIF  
MPRT_ACT = 'C'

IF MDISP_PRT = 'P'
   DO PRT_SET
   
   IF MPRT_ACT <> 'C'
      RETURN
   ENDIF
   MPAGE_LEN = 56
ELSE
   MPAGE_LEN = 20
ENDIF

SELECT B
DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
SELECT C
DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.

SELECT A
DO FOX_USE WITH "CK_REG INDEX CK_DATE", .F.
STORE DTOC(MCK_DATE) TO MDATE
STORE SUBSTR(MDATE,1,2) TO MMONTH
STORE SUBSTR(MDATE,4,2) TO MDAY
STORE STR(YEAR(MDATE),4) TO MYEAR

SEEK MYEAR + MMONTH + MDAY
IF EOF()
   @ 4,1 CLEAR TO 21,78 
   @ 10,5 SAY 'THERE IS NO CHECK DATA ON FILE FOR THIS DATE'
   STORE ' ' TO MWAIT
   @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
   READ
   RETURN
ENDIF

MPAGE_NO = 0
MLINE = 99 
IF MDISP_PRT = 'P'
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
   
ENDIF

MDAILY_TOT = 0
DO WHILE .NOT. EOF() .AND. SYS_DATE = MCK_DATE
   IF MLINE > MPAGE_LEN
      IF MLINE <> 99
         IF MDISP_PRT = 'P'
            EJECT
         ELSE
            STORE 'C' TO MPRT_SEL
            @ 24,0 SAY "PRESS 'C' TO CONTINUE OR 'S' TO STOP REPORT DISPLAY: "     ;
               GET MPRT_SEL PICTURE '@! A'
            READ
            IF MPRT_SEL = 'S'
               SELECT A
               GOTO BOTTOM
               SKIP
               LOOP
            ENDIF
            CLEAR
         ENDIF
      ENDIF
      IF MLINE = 99 .AND. MDISP_PRT <> 'P'
         CLEAR
      ENDIF
      MPAGE_NO = MPAGE_NO + 1
      
      @ 1,34 SAY MCOMPANY
      @ 2,0 SAY 'PAGE'
      @ 2,05 say mpage_no picture '99'
      @ 2,22 SAY 'DAILY CHECK REGISTER FOR ' + DTOC(MCK_DATE)
      @ 2,70 SAY DTOC(DATE())
      @ 4,2 SAY 'CHECK NBR      PAYEE                                          AMOUNT'
      IF MDISP_PRT = 'P'
         @ 5,0 SAY REPLICATE ('_',80)
      ELSE
         @ 6,0 SAY REPLICATE ('-',80)
      ENDIF
      MLINE = 7
   ENDIF
   @ MLINE,3 SAY CK_NBR
   DO CASE
   CASE PAY_TYPE = 'S'
      SELECT B
      SEEK A->PAY_CODE
      IF EOF()
         STORE 'PAYEE NOT ON FILE' TO MNAME
      ELSE
         STORE NAME TO MNAME
      ENDIF
      @ MLINE,17 SAY MNAME
      SELECT A
   CASE PAY_TYPE = 'F'
      SELECT C 
      SEEK A->PAY_CODE
      IF EOF()
         STORE 'PAYEE NOT ON FILE' TO MNAME
      ELSE
         STORE NAME TO MNAME
      ENDIF
      @ MLINE,17 SAY MNAME
      SELECT A
   CASE PAY_TYPE = 'O'
      @ MLINE,17 SAY PAY_NAME
   ENDCASE
   @ MLINE,60 SAY AMOUNT PICTURE '999,999.99'
   IF VOID_MAN = 'M'
      @ MLINE,73 SAY 'MANUAL'
   ENDIF
   IF VOID_MAN = 'V'
      @ MLINE,73 SAY 'VOID'
   ENDIF
   IF VOID_MAN <> 'V'
      MDAILY_TOT = MDAILY_TOT + AMOUNT
   ENDIF
   MLINE = MLINE + 2
   SKIP
ENDDO   

MLINE = MLINE + 1
IF MLINE > MPAGE_LEN
   IF MLINE <> 99
      IF MDISP_PRT = 'P'
         EJECT
      ELSE
         STORE 'C' TO MPRT_SEL
         @ 24,0 SAY "PRESS 'C' TO CONTINUE OR 'S' TO STOP REPORT DISPLAY: "     ;
            GET MPRT_SEL PICTURE '@! A'
         READ
         IF MPRT_SEL = 'S'
            RETURN   
         ENDIF
         CLEAR
      ENDIF
   ENDIF
   IF MLINE = 99 .AND. MDISP_PRT <> 'P'
      CLEAR
   ENDIF
   MPAGE_NO = MPAGE_NO + 1
   
   
   @ 1,34 SAY MCOMPANY
   @ 2,0 SAY 'PAGE'
   @ 2,05 say mpage_no picture '99'
   @ 2,22 SAY 'DAILY CHECK REGISTER FOR ' + DTOC(MCK_DATE)
   @ 2,70 SAY DTOC(DATE())
   @ 4,2 SAY 'CHECK NBR      PAYEE                                          AMOUNT'
   IF MDISP_PRT = 'P'
      @ 5,0 SAY REPLICATE ('_',80)
   ELSE
      @ 6,0 SAY REPLICATE ('-',80)
   ENDIF
   MLINE = 7
ENDIF

@ MLINE,17 SAY 'TOTAL CHECKS:'
@ MLINE,60 SAY MDAILY_TOT PICTURE '999,999.99'
IF MDISP_PRT = 'P'
   MLINE = MLINE + 1
   @ mline+1,1 say ' '
   eject
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
   
ELSE
   MPRT_SEL = ' '
   @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
   READ
ENDIF
CLOSE DATA

RETURN

* EOF: CK_REG.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/8/15 at 1:23 PM.
