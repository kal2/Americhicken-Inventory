*************
* Program.: SHRTSUM.PRG
* Author..: GRACE KELLER
* Date....: 01/29/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: DAILY SHORT WEIGHTS NEEDED REPORT FOR SALESPERSONS
*

MTITLE = ' - OUTSTANDING SHORTWEIGHTS REPORT (BY SALESPERSON)'      
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
**** GET DATE FOR THIS REPORT
STORE DATE() TO MDATE
STORE 'P' TO MDISP_PRT
STORE 'N' TO MYES_NO     
STORE 2 TO MACTION      
DO WHILE MACTION = 2      
   @ 10,6 SAY 'DISPLAY OR PRINT REPORT (D/P):'
   @ 10,38 GET MDISP_PRT PICTURE '@!'
   @ 12,1 SAY 'DO YOU ALSO WANT THE ORDERS INCLUDED FOR'
   @ 13,1 SAY "WHICH THE CENTRAL OFFICE CALLS FOR S/W'S (Y/N)? " GET MYES_NO PICTURE '@!'
   
   
   STORE 1 TO MACTION
   @ 23,00 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
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
   MPAGE_LEN = 22
ENDIF
SELECT C
DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.

SELECT A
DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.

SELECT B
DO FOX_USE WITH "PO_HEAD", .F.
INDEX ON SHORT_FLG + SALESMAN + STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2) TO PO_TEMP
DO FOX_USE WITH "PO_HEAD INDEX PO_TEMP", .F.
@ 19,16 SAY 'PROCESSING........'
SEEK ' '
IF EOF()
   @ 05,01 CLEAR TO 22,78
   STORE ' ' TO MWAIT
   @ 10,05 SAY 'THERE ARE NO PURCHASE ORDERS NEEDING SHORTWEIGHTS'
   @ 12,05 SAY 'PRESS ENTER KEY TO CONTINUE ' GET MWAIT
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
   ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
   
   *** LETTER SIZE PAPER
   ?? CHR(27) + '&l2A'
   
   *** PORTRAIT MODE
   ?? CHR(27) + '&l0O'
   
ENDIF

DO WHILE .NOT. EOF() .AND. SHORT_FLG = ' '
   IF DEL_REQD > DATE() 
      SKIP
      LOOP
   ENDIF
   
   STORE SALESMAN TO MSALESMAN
   IF MSALESMAN <> SPACE(2)
      SELECT C
      
      SEEK MSALESMAN   
      IF .NOT. EOF()
         STORE SUBSTR(NAME,1,20) TO MNAME
      ELSE
         STORE 'NOT ON FILE        ' TO MNAME
      ENDIF
   ELSE
      STORE BROK_NAME + SPACE(13) TO MNAME
   ENDIF
   SELECT B
   DO WHILE .NOT. EOF() .AND. SHORT_FLG = ' ' .AND. SALESMAN = MSALESMAN
      IF DEL_REQD > DATE() 
         SKIP
         LOOP
      ENDIF
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
         @ 2,22 SAY 'PURCHASE ORDERS NEEDING SHORTWEIGHTS'
         @ 2,70 SAY DTOC(DATE())
         @ 3,22 SAY MNAME
         @ 5,2 SAY 'SHIP DATE'   
         
         @ 5,15 SAY 'PO NUMBER'       
         @ 5,28 SAY 'CUSTOMER'    
         @ 5,63 SAY 'DELIVERY DATE'
         IF MDISP_PRT = 'P'
            @ 5,0 SAY REPLICATE ('_',80)
         ELSE
            @ 6,0 SAY REPLICATE ('-',80)
         ENDIF
         MLINE = 7
      ENDIF
      SELECT A
      SEEK B->BBUYCODE
      IF .NOT. EOF()
         IF MSALESMAN <> '  '
            IF MYES_NO = 'N' .AND. NO_SHRTRPT = 'Y'
               SELECT B
               SKIP
               LOOP
            ENDIF
         ENDIF
         STORE NAME TO MBBUYNAME
      ELSE 
         STORE 'BILL TO NOT ON FILE' TO MBBUYNAME
      ENDIF
      
      SELECT B
      @ MLINE,2 SAY SHIP_DATE
      @ MLINE,15 SAY SALESMAN  
      IF SALESMAN <> '  '
         @ MLINE,17 SAY '-'
      ENDIF
      @ MLINE,18 SAY PO_NBR
      IF PO_SUFFIX <> ' '
         @ MLINE,22 SAY '-' + PO_SUFFIX
      ENDIF
      @ MLINE,28 SAY MBBUYNAME
      @ MLINE,65 SAY DEL_REQD
      MLINE = MLINE + 2 
      SKIP
   ENDDO
   MLINE = 80
   MPAGE_NO = 0
ENDDO
IF MDISP_PRT = 'P'
   @ mline+1,1 say ' '
   EJECT
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

* EOF: SHRTSUM.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 4:56 PM.
