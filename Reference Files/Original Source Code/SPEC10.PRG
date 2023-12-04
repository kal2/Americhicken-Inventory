************
* Program.: SPEC10.PRG
* Author..: GRACE KELLER
* Date....: 
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MAIN PROGRAM - SPEC10
*
* ---SET environment.
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

SET CENTURY ON
SET DELETED ON
SET TALK OFF
SET ECHO OFF
SET BELL OFF
SET MENU OFF
SET SAFETY OFF
SET ESCAPE ON
SET SCOREBOARD ON
SET STATUS OFF
SET EXCLUSIVE OFF
SET PATH TO \AMERIFOX   
SET DECIMALS TO 5
SET DEVICE TO SCREEN

CLIPPER = .F.
FOXBASE = .T.
MMONO   = .F.

* ---SET COLOR TO values.   (If changed, change other one farther down too)
IF .NOT. MMONO .AND. ISCOLOR()
   SET COLOR TO W+/B,W+/R
ELSE
   SET COLOR TO W/N,N/W
ENDIF

CLOSE ALL
SET DEVICE TO SCREEN

**** FINISHES THE READ WHEN DOING A PAGE DOWN

SELECT A
DO FOX_USE WITH "C:\COMPINFO\SCREEN", .F.
MSCRNSIZE = SCRNSIZE
USE

DO CASE
*** TEST
CASE MSCRNSIZE = 'T'
   DEFINE WINDOW MWINDOW ;
     FROM 2,24 TO 40,252 ;
     FONT "LUCIDA CONSOLE", 18 ;
     COLOR W+/B, W+/R ;
     NONE
*** Jeni
CASE MSCRNSIZE = 'J'
   **GOOD - FROM 2,10 TO 35,200  
   **BETTER-  FROM 2,5 TO 35,210
   DEFINE WINDOW MWINDOW ;
     FROM 2,5 TO 40,210 ;
     FONT "LUCIDA CONSOLE", 16 ;
     COLOR W+/B, W+/R ;
     NONE
*** WIDESCREEN
CASE MSCRNSIZE = 'W'
   DEFINE WINDOW MWINDOW ;
     FROM 5,30 TO 57,272 ;
     FONT "LUCIDA CONSOLE", 20 ;
     COLOR W+/B, W+/R ;
     NONE
*** LAPTOP
CASE MSCRNSIZE = 'L'
   DEFINE WINDOW MWINDOW ;
     FROM 2,23 TO 54,265 ;
     FONT "LUCIDA CONSOLE", 20 ;
     COLOR W+/B, W+/R ;
     NONE
*** OTHER - SQUARE 
OTHERWISE
   DEFINE WINDOW MWINDOW ;
     FROM 5,4 TO 57,200 ;
     FONT "LUCIDA CONSOLE", 19 ;
     COLOR W+/B, W+/R ;
     NONE
ENDCASE

ACTIVATE WINDOW "MWINDOW"

* ---MAIN PROCESSING LOOP
CLEAR
SET COLOR TO W/W,W/W
SET COLOR TO W+/B+,W+/R+
CLEAR


**********************************************************************
**** THIS WORKS - BUT GIVES AN EXTRA EJECT AT THE END OF JOB**********
**** ORIGINALLY HAD THIS WAY FOR STODDARD COUNTY
**MPRINTIT = "PRINT.EXE /D:" + MPRINTER + " C:\COMPINFO\PRT_FILE.TXT"
**********************************************************************

****TESTING************
****MPRINTIT = "PRINT.EXE /D:\\GRACE64-HP\HP4250 \COMPINFO\PRTFILE.TXT"
****MPRINTIT = "PRINT.EXE /D:\\GINGER-PC\HP940C \REPORTS\PRTFILE.TXT"
*** END OF TESTING*****
************************************************************************

* ---Initialize global variables.
SELECT A
DO FOX_USE WITH "COMPANY", .F.
MCOMPANY = TRIM(COMPANY)
MMASTDBF = TRIM(MASTDBF)
MDBFLOC = TRIM(DBFLOC)
USE

SELECT A
DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
MPROGRAM = TRIM(PROGRAM)
MPROG_CODE = PROG_CODE
USE

IF FILE("C:\COMPINFO\PRINTERS.DBF")
   SELECT A
   DO FOX_USE WITH "C:\COMPINFO\PRINTERS", .F.
   MPRINTER  = TRIM(PRINTER1)
   MPRINTER2 = TRIM(PRINTER2)
   MPRINTER3 = TRIM(PRINTER3)
   USE
ELSE
   MPRINTER  = 'DONOTPRINT'
   MPRINTER2 = 'DONOTPRINT'
   MPRINTER3 = 'DONOTPRINT'
ENDIF  

MPRINTIT  = 'COPY C:\COMPINFO\PRT_FILE.TXT ' + MPRINTER
MPRINTIT2 = 'COPY C:\COMPINFO\PRT_FILE.TXT ' + MPRINTER2
MPRINTIT3 = 'COPY C:\COMPINFO\PRT_FILE.TXT ' + MPRINTER3


**********************************************************************
**** THIS WORKS - BUT GIVES AN EXTRA EJECT AT THE END OF JOB**********
**** ORIGINALLY HAD THIS WAY FOR STODDARD COUNTY
**MPRINTIT = "PRINT.EXE /D:" + MPRINTER + " C:\COMPINFO\PRT_FILE.TXT"
**********************************************************************

****TESTING************
****MPRINTIT = "PRINT.EXE /D:\\GRACE64-HP\HP4250 \COMPINFO\PRTFILE.TXT"
****MPRINTIT = "PRINT.EXE /D:\\GINGER-PC\HP940C \REPORTS\PRTFILE.TXT"
*** END OF TESTING*****
************************************************************************

STORE 'BROKER SYSTEM' TO MPROGRAM

STORE .T. TO MONO

MPASSWORD = 'ADM99'
MUSER = 'SUPERVISOR'
MSECURITY = .T.

ON KEY LABEL PGUP CLEAR READ
ON KEY LABEL PGDN CLEAR READ


CLEAR
@ 01,00 SAY MCOMPANY
@ 02,00 SAY MPROGRAM + ' - REPORT SPEC10 -FREIGHT'
@ 02,70 SAY DATE()
@ 3,0 to 24,79

STORE SPACE(4) TO MBBUYCODE, MRSUPCODE, MBUY_CODE, MSUP_CODE
MPAPER = SPACE(6)

MCHOICE = ' '
MYES_NO = SPACE(3)  
@ 10,5 SAY 'Do you want to select a specific Customer (YES/NO)? ' get MYES_NO picture '@!'
READ
IF MYES_NO <> 'YES' .AND. MYES_NO <> 'NO '
   QUIT   
ENDIF
@ 10,1 SAY SPACE(78)
IF MYES_NO = 'YES'
   MNAME_FD = .F.
   DO BBUYSEL3
   IF .NOT. MNAME_FD
      QUIT  
   ENDIF
   STORE BBUYCODE TO MBBUYCODE
   STORE NAME TO MNAME
   STORE CITY TO MCITY
   STORE STATE TO MSTATE
   CLEAR
   @ 01,00 SAY MCOMPANY
   @ 02,00 SAY MPROGRAM + ' - PRODUCT DETAILS/TOTALS'
   @ 02,70 SAY DATE()
   @ 3,0 to 25,79
   MYES_NO = '   '
   @ 12,5 SAY 'Do you want to select a specific Ship To Customer (YES/NO)? ' get MYES_NO picture '@!'
   READ
   IF MYES_NO = 'YES'
      MNAME_FD = .F.
      SET PROC TO BUY_PROC
      DO BUY_SEL1
      IF MNAME_FD
         STORE BUY_CODE TO MBUY_CODE
      ENDIF
      SET PROC TO PO_PROC
   ENDIF
   USE
ELSE
   MNAME = 'NO SUPPLIER/CUSTOMER SELECTED'
   MCITY = SPACE(20)
   MSTATE = SPACE(2)
ENDIF

MTITLE = ' - PRODUCT DETAILS/TOTALS'
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
**** GET FIRST AND LAST DATES FOR THIS REPORT
STORE CTOD(' ') TO MSTART, MLAST
STORE 'P' TO MDISP_PRT
STORE SPACE(10) TO MSEL_PROD
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   @ 5,2 SAY  'Report Begin Date: '                   
   @ 7,2 SAY  '         End Date: '
   @ 10,1 SAY 'Optional  Product: '
   STORE 2 TO MACTION      
   DO WHILE MACTION = 2      
      @ 05,21 GET MSTART
      @ 07,21 GET MLAST
      @ 10,21 GET MSEL_PROD PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,00 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report/Finished'             
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 1
         IF DTOC(MSTART) = '  /  /  ' .AND. DTOC(MLAST) = '  /  /  '
            MACTION = 3
            LOOP
         ENDIF
         
         IF (DTOC(MSTART) <> '  /  /  ' .AND. DTOC(MLAST) = '  /  /  ') .OR. (DTOC(MSTART) = '  /  /  ' .AND. DTOC(MLAST) <> '  /  /  ')
            @ 23,0 CLEAR
            mwait = ' '
            @ 23,1 SAY 'Only One Date Entered - Both Begin and End Dates Must be Entered'
            @ 24,1 say 'Press Any Key to Reenter ' get mwait
            READ
            MACTION = 2
            @ 23,0 clear
            LOOP 
         ENDIF
      ENDIF
   ENDDO
   
   IF MACTION = 3
      MNOT_DONE = .F.
      LOOP
   ENDIF  
   
   MPRT_ACT = 'C'
   
   @ 20,01 CLEAR TO 20,78 
   IF MDISP_PRT = 'P'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      MPAGE_LEN = 56
   ELSE
      MPAGE_LEN = 20
   ENDIF
   STORE MONTH(MSTART) TO MSTRT_MO   
   MSTRT_MO = MSTRT_MO + 100
   STORE SUBSTR(STR(MSTRT_MO,3),2) TO MSTRT_MO
   
   STORE MONTH(MLAST) TO MLAST_MO   
   MLAST_MO = MLAST_MO + 100
   STORE SUBSTR(STR(MLAST_MO,3),2) TO MLAST_MO
   
   STORE YEAR(MSTART) TO MSTRT_YR
   STORE STR(MSTRT_YR,4) TO MSTRT_YR
   
   STORE YEAR(MLAST) TO MLAST_YR
   STORE STR(MLAST_YR,4) TO MLAST_YR
   
   STORE DAY(MSTART) TO MSTRT_DAY
   MSTRT_DAY = MSTRT_DAY + 100
   STORE SUBSTR(STR(MSTRT_DAY,3),2) TO MSTRT_DAY
   
   STORE DAY(MLAST) TO MLAST_DAY
   MLAST_DAY = MLAST_DAY + 100
   STORE SUBSTR(STR(MLAST_DAY,3),2) TO MLAST_DAY
   MPAGE_NO = 0
   MLINE = 99
   
   @ 21,16 SAY SPACE(34)
   @ 21,16 SAY 'PROCESSING............'
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

*** BOLDED PRINT
?? CHR(27) + '(s4B'

*** LETTER SIZE PAPER
?? CHR(27) + '&l2A'

*** PORTRAIT MODE
?? CHR(27) + '&l0O'

   ENDIF
   
   SELECT E
   DO FOX_USE WITH "TEMPPROD", .T.
   DELETE ALL
   PACK
   INDEX ON NAME + BBUYCODE + DTOC(SHIP_DATE) TO TEMPPROD
   DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .T.
   
   SELECT B
   DO FOX_USE WITH "PO_DTL INDEX  PO_DTL", .F.
   
   IF MSEL_PROD <> SPACE(4)            
      SET FILTER TO PROD_DESC = MSEL_PROD
      GOTO TOP
   ENDIF
   
   SELECT C 
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
   SELECT D
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
   
   SELECT A 
   DO FOX_USE WITH "PO_HEAD INDEX TMP_BUY", .F.
   set filter to po_suffix <> 'R'
   goto top

   DO WHILE .NOT. EOF()
      IF SHIP_DATE < MSTART .OR. SHIP_DATE > MLAST                          
         SKIP
         LOOP
      ENDIF
      
      IF MBBUYCODE <> SPACE(4)
         IF MBBUYCODE <> BBUYCODE
            SKIP
            LOOP
         ENDIF
         IF MBUY_CODE <> SPACE(4)
            IF MBUY_CODE <> BUY_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
      ENDIF
      
      IF MCOMPANY = 'AMERICHICKEN, INC'
         IF BBUYCODE = 'NONE' .OR. BBUYCODE = 'INVN'
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      MPRT_NAME = .T.
      STORE BBUYCODE TO MSAVE_CODE
      SELECT C
      SEEK A->RSUPCODE
      IF .NOT. EOF()
         MSUP_NAME= NAME
         MSUP_CITY = SUBSTR(CITY,1,12)
         MSUP_ST = STATE
      ELSE
         MSUP_NAME = 'SUP NOT ON FILE'
         MSUP_CITY = SPACE(12)
         MSUP_ST = '  '
      ENDIF
      SELECT D
      SEEK A->BBUYCODE
      IF .NOT. EOF()
         MCUST_NAME = NAME
         MCUST_CITY = SUBSTR(CITY,1,12)
         MCUST_ST = STATE
      ELSE
         STORE 'CUST NOT ON FILE' TO MCUST_NAME
         MCUST_CITY = SPACE(12)
         MCUST_ST = '  ' 
      ENDIF
      
      SELECT A
      
      IF MCUST_NAME = 'SAMPLE'
         SKIP
         LOOP
      ENDIF
      
      DO WHILE .NOT. EOF() .AND. BBUYCODE = MSAVE_CODE
         
         IF SHIP_DATE < MSTART .OR. SHIP_DATE > MLAST
            SKIP
            LOOP
         ENDIF
         
         IF MBUY_CODE <> SPACE(4)
            IF MBUY_CODE <> BUY_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         STORE SHIP_DATE TO MSHIP_DATE
         STORE 0 TO MTOT_FRT, MTOT_LBS         
         
         DO WHILE .NOT. EOF() .AND. BBUYCODE = MSAVE_CODE .AND. SHIP_DATE = MSHIP_DATE
            
            IF MBUY_CODE <> SPACE(4)
               IF MBUY_CODE <> BUY_CODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            STORE SALESMAN TO MSALESMAN
            STORE PO_NBR TO MPO_NBR
            STORE PO_SUFFIX TO MPO_SUFFIX
            
            SELECT B
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            MLBS = 0
            
            DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
               
               IF LBS <= 0
                  SKIP
                  LOOP
               ENDIF
               
               IF PACKED = 'B'
                  MLBS = MLBS + (VAL(SUBSTR(PACKED,2)) * LBS)
               ELSE
                  MLBS = MLBS + LBS
               ENDIF
               
               SKIP
            ENDDO
            
            SELECT A
            IF FRT_AMT1 = 0 .OR. MLBS = 0
               MFRT_LB = 0
               MFRT = 0
            ELSE
               MFRT = FRT_AMT1+FRT1_ADJ1+FRT1_ADJ2+FRT_PALL
               MFRT_LB = ROUND(MFRT / MLBS,4)
            ENDIF
            
            SELECT E
            APPEND BLANK
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE PO_NBR   WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE BBUYCODE WITH A->BBUYCODE
            REPLACE RSUPCODE WITH A->RSUPCODE
            REPLACE BUY_CODE WITH A->BUY_CODE
            REPLACE SUP_CODE WITH A->SUP_CODE
            REPLACE SHIP_DATE WITH A->SHIP_DATE
            REPLACE NAME WITH MCUST_NAME
            REPLACE FREIGHT WITH MFRT
            REPLACE TOT_LBS WITH MLBS
            REPLACE FRT_LB  WITH MFRT_LB
            SELECT A
            SKIP
         ENDDO
         
      ENDDO
      
   ENDDO
   *** END OF EXTRACT
   
   
   SELECT E
   USE
   SELECT A
   DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .T.
   
   DO WHILE .NOT. EOF()
      
      IF SHIP_DATE < MSTART .OR. SHIP_DATE > MLAST
         SKIP
         LOOP
      ENDIF
      
      IF MBBUYCODE <> SPACE(4)
         IF MBBUYCODE <> BBUYCODE
            SKIP
            LOOP
         ENDIF
         IF MBUY_CODE <> SPACE(4)
            IF MBUY_CODE <> BUY_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
      ENDIF
      
      IF MCOMPANY = 'AMERICHICKEN, INC'
         IF BBUYCODE = 'NONE' .OR. BBUYCODE = 'INVN'
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      MPRT_NAME = .T.
      STORE NAME+BBUYCODE TO MSAVE_CODE
      
      SELECT C
      SEEK A->RSUPCODE
      IF .NOT. EOF()
         MSUP_NAME= NAME
         MSUP_CITY = SUBSTR(CITY,1,12)
         MSUP_ST = STATE
      ELSE
         MSUP_NAME = 'SUP NOT ON FILE'
         MSUP_CITY = SPACE(12)
         MSUP_ST = '  '
      ENDIF
      
      SELECT D
      SEEK A->BBUYCODE
      IF .NOT. EOF()
         MCUST_NAME = NAME
         MCUST_CITY = SUBSTR(CITY,1,12)
         MCUST_ST = STATE
      ELSE
         STORE 'CUST NOT ON FILE' TO MCUST_NAME
         MCUST_CITY = SPACE(12)
         MCUST_ST = '  ' 
      ENDIF
      SELECT A
      IF MCUST_NAME = 'SAMPLE'
         SKIP
         LOOP
      ENDIF
      
      STORE 0 TO MTOT_FRT, MTOT_LBS
      
      DO WHILE .NOT. EOF() .AND. NAME+BBUYCODE = MSAVE_CODE
         IF SHIP_DATE < MSTART .OR. SHIP_DATE > MLAST
            SKIP
            LOOP
         ENDIF
         
         IF MBUY_CODE <> SPACE(4)
            IF MBUY_CODE <> BUY_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         
         IF MLINE > MPAGE_LEN
            IF MLINE = 99
               IF MDISP_PRT <> 'P'
                  CLEAR
               ENDIF
            ELSE
               IF MDISP_PRT <> 'P'
                  CLEAR
               ELSE
                  EJECT
               ENDIF
            ENDIF
            
            MPAGE_NO = MPAGE_NO + 1
            @ 1,25 SAY MCOMPANY
            @ 2,1 SAY 'Page'
            @ 2,06 say MPAGE_NO picture '99'
            @ 2,25 SAY 'TOTAL FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
            @ 2,80 SAY DTOC(DATE())
            @ 3,80 SAY TIME()
            
            MPRT_NAME = .T.
            MPRT_PO   = .T.
            @ 5,1 SAY 'PO NUMBER SHIP DATE       FREIGHT       LBS     FRT/LB'
            @ 5,01 SAY REPLICATE('_',54)
            MLINE = 6
         ENDIF
         
         SELECT A
         MFRT = FREIGHT
         MLBS = TOT_LBS
         MFRT_LB = FRT_LB
         
         IF MPRT_NAME
            MLINE = MLINE + 1
            @ MLINE,1 SAY MCUST_NAME
            MPRT_NAME = .F.
            MLINE = MLINE + 1
         ENDIF
         
         MTOT_FRT = MTOT_FRT + MFRT
         MTOT_LBS = MTOT_LBS + MLBS
         
         IF SALESMAN <> SPACE(2)
            @ MLINE,1 SAY SALESMAN + '-'
         ENDIF
         @ MLINE,4 SAY PO_NBR
         IF PO_SUFFIX <> ' '
            @ MLINE,8 SAY '-' + PO_SUFFIX
         ENDIF
         
         @ MLINE,11 SAY A->SHIP_DATE                     
         
         @ MLINE,23 SAY MFRT PICTURE '999,999.99'
         @ MLINE,37 SAY MLBS PICTURE '999,999'
         @ MLINE,48 SAY MFRT_LB PICTURE '99.9999'
         MLINE = MLINE + 1
         SKIP
      ENDDO
      IF MTOT_LBS <> 0 .AND. MTOT_FRT <> 0
         @ MLINE,1  SAY 'SUBTOTAL:'
         @ MLINE,23 SAY MTOT_FRT PICTURE '999,999.99'
         @ MLINE,37 SAY MTOT_LBS PICTURE '999,999'
         MFRT_LB = ROUND(MTOT_FRT / MTOT_LBS,4)
         @ MLINE,48 SAY MFRT_LB PICTURE '99.9999'
         MLINE = MLINE + 1
      ELSE
         *MLINE = MLINE + 1
      ENDIF
   ENDDO
   IF MLINE <> 99
      IF MDISP_PRT = 'P'
         MLINE = MLINE + 1
         @ MLINE+1,1 SAY ' '
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
   ENDIF
   CLOSE DATA
   MNOT_DONE = .F.
ENDDO
QUIT       

*Formatted by: ToolBox Ver. 1.2  on 7/23/14 at 1:58 PM.
