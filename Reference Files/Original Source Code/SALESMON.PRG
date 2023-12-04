************
* Program.: PROGRAM.PRG
* Author..: GRACE KELLER
* Date....: 08/04/04
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MAIN PROGRAM FOR MONTHLY SALESPERSON SUMMARY
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
@ 02,00 SAY MPROGRAM + ' - PRODUCT DETAILS/TOTALS'
@ 02,70 SAY DATE()
@ 3,0 to 24,79

STORE SPACE(6) TO MPASSWORD
@ 10,08 say 'Enter Password: '
SET COLOR TO W/W,W/W
SET CONFIRM ON
@ 10,24 GET MPASSWORD PICTURE '@!'
READ
SET COLOR TO W+/B+,W+/R+
SET CONFIRM OFF
IF MPASSWORD <> 'EUGENE'
   MWAIT = ' '
   @ 15,10 SAY 'SECURITY VIOLATION !!!!   INVALID PASSWORD'
   @ 17,10 SAY 'RETURNING TO DESKTOP MENU - PRESS ENTER/RETURN KEY' GET MWAIT
   READ
   CLOSE DATA
   QUIT
ENDIF
@ 10,1 SAY SPACE(70)

STORE SPACE(4) TO MBBUYCODE, MRSUPCODE, MBUY_CODE, MSUP_CODE
MPAPER = SPACE(6)

MCHOICE = ' '
MYES_NO = SPACE(3)  
STORE SPACE(32) TO MINCEN_NM
@ 10,5 SAY 'Optional: Enter Salesperson Name: ' get MINCEN_NM picture '@!'
READ
IF MINCEN_NM <> SPACE(32)
   SELECT D
   DO FOX_USE WITH "SALESMAN INDEX SAL_NAME", .F.
   SEEK TRIM(MINCEN_NM)
   STORE SALE_CODE TO MOPT_CD 
   USE
ELSE
   STORE SPACE(2) TO MOPT_CD
ENDIF

STORE 'NO ' TO MYES_NO
@ 10,5 SAY SPACE(70)
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
   @ 3,0 to 24,79
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

MTITLE = ' - SALESPERSON MONTHLY PRODUCT DETAILS/TOTALS'
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 23,79
**** GET FIRST AND LAST DATES FOR THIS REPORT
STORE SPACE(2) TO MTRAN_MO
STORE SPACE(4) TO MTRAN_YR
STORE 'P' TO MDISP_PRT
STORE SPACE(10) TO MSEL_PROD
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   @  5,1 SAY ' Enter Report Mo/Yr:   /'                
   @ 10,1 SAY '  Optional  Product: '
   STORE 2 TO MACTION      
   DO WHILE MACTION = 2      
      @ 05,22 GET MTRAN_MO PICTURE '##' 
      @ 05,25 GET MTRAN_YR PICTURE '####'
      @ 10,22 GET MSEL_PROD PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,00 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report/Finished'             
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 1
         IF VAL(MTRAN_MO) < 1 .OR. VAL(MTRAN_MO) > 12
            @ 23,0 CLEAR
            mwait = ' '
            @ 23,1 SAY 'Invalid Transaction Month'
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
   
   @ 20,01 SAY SPACE(77)
   @ 21,01 SAY SPACE(77)
   IF MDISP_PRT = 'P'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      MPAGE_LEN = 56
   ELSE
      MPAGE_LEN = 20
   ENDIF
   
   MPAGE_NO = 0
   MLINE = 99
   @ 19,16 SAY 'PROCESSING............'
   
   IF MDISP_PRT = 'P'
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
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
   ENDIF
   
   SELECT F
   **DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
   DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
   
   SELECT E
   DO FOX_USE WITH "SALESMON", .T.
   DELETE ALL
   PACK
   
   SELECT B
   DO FOX_USE WITH "PO_DTL INDEX  PO_DTL", .F.
   
   SELECT C 
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
   SELECT D
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
   
   SELECT A 
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
   
   SELECT F
   ***SET FILTER TO PO_NBR = '2192'
   GOTO TOP
   
   SEEK MTRAN_YR+MTRAN_MO
   
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      
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
      MFREIGHT = FRT_AMT1+FRT_AMT2+FRT_AMT3+FRT_PALL
      
      MMISC = MISC_AMT
      ** GET SPECIFIC FIELDS FROM SELECT A->PO_HEAD
      
      SELECT A
      SEEK F->SALESMAN+F->PO_NBR+F->PO_SUFFIX
      STORE SHIP_DATE TO MSHIP_DATE
      STORE TOT_LBS TO MTOT_LBS
      MSUP_ADJ = SUP_AMT1 + SUP_AMT2 + SUP_PALL
      MCUS_ADJ = CUS_AMT1 + CUS_AMT2 + CUS_PALL + WRITEOFF
      
      IF MTOT_LBS <> 0 .AND. MSUP_ADJ <> 0
         MSUP_LB = ROUND(MSUP_ADJ / MTOT_LBS,6)
      ELSE
         MSUP_LB  = 0
      ENDIF
      
      IF MTOT_LBS <> 0 .AND. MCUS_ADJ <> 0
         MCUS_LB = ROUND(MCUS_ADJ / MTOT_LBS,6)
      ELSE
         MCUS_LB  = 0
      ENDIF
      
      IF MTOT_LBS <> 0 .AND. MFREIGHT <> 0
         MFRT_LB = ROUND(MFREIGHT / MTOT_LBS,6)
      ELSE
         MFRT_LB = 0
      ENDIF
      
      IF MTOT_LBS <> 0 .AND. MMISC <> 0
         MMISC_LB = ROUND(MMISC / MTOT_LBS,6)
      ELSE    
         MMISC_LB = 0
      ENDIF
      
      IF F->INV_COR = 'I'
         SELECT B
         SEEK F->SALESMAN+F->PO_NBR+F->PO_SUFFIX
         *** IF NO PO ITEMS - CREATE AND ENTRY FOR THE ORDER
         IF EOF()
            SELECT E
            APPEND BLANK
            REPLACE BBUYCODE WITH F->BBUYCODE
            REPLACE BUY_CODE WITH F->BUY_CODE
            REPLACE PO_NBR WITH F->PO_NBR
            REPLACE PO_SUFFIX WITH F->PO_SUFFIX
            REPLACE TOT_LBS WITH MTOT_LBS
            REPLACE SHIP_DATE WITH MSHIP_DATE
            REPLACE TOT_NET WITH F->TOT_NET
            REPLACE ITM_NET WITH F->TOT_NET
            REPLACE INV_COR WITH 'I'
         ELSE
            DO WHILE .NOT. EOF() .AND. SALESMAN = F->SALESMAN .AND. PO_NBR = F->PO_NBR .AND. PO_SUFFIX = F->PO_SUFFIX
               IF MSEL_PROD <> SPACE(10)
                  IF MSEL_PROD <> PROD_DESC
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               IF SUBSTR(B->PACKED,1,1) = 'B'
                  STORE VAL(SUBSTR(B->PACKED,2)) TO MCS_WT
                  MLBS = ROUND((MCS_WT * B->QTY),2)
               ELSE
                  MLBS = B->LBS
               ENDIF
               MITM_FRT  = ROUND(MFRT_LB * MLBS,2)
               MITM_MISC = ROUND(MMISC_LB * MLBS,2)
               MITM_SUP  = ROUND(MSUP_LB * MLBS,2)
               MITM_CUS  = ROUND(MCUS_LB * MLBS,2)
               IF COM1_CENT <> 0 .OR. COM2_CENT <>0 .OR. COM3_CENT <> 0
                  MCOMM_LB = COM1_CENT + COM2_CENT + COM3_CENT
                  MITM_COMM = ROUND(MCOMM_LB * B->LBS,2)
               ELSE
                  MITM_COMM = 0
               ENDIF
               MTOT_PURCH = TOT_PURCH + MITM_SUP
               MTOT_SELL  = TOT_SELL  + MITM_CUS
               MITM_NET = MTOT_SELL -MTOT_PURCH -MITM_FRT -MITM_MISC -MITM_COMM
               
               SELECT E
               APPEND BLANK
               REPLACE BBUYCODE WITH F->BBUYCODE
               REPLACE BUY_CODE WITH F->BUY_CODE
               REPLACE PO_NBR WITH F->PO_NBR
               REPLACE PO_SUFFIX WITH F->PO_SUFFIX
               REPLACE PROD_DESC WITH B->PROD_DESC
               REPLACE TOT_LBS WITH MLBS
               REPLACE SHIP_DATE WITH MSHIP_DATE
               REPLACE SEL_PRICE WITH B->SEL_PRICE
               REPLACE ITM_NET WITH MITM_NET
               REPLACE ITEM_NBR WITH B->ITEM_NBR
               REPLACE INV_COR WITH 'I'
               SELECT B
               SKIP
            ENDDO
            SELECT E
            REPLACE TOT_NET WITH F->TOT_NET
         ENDIF
      ELSE
         SELECT E
         APPEND BLANK
         REPLACE BBUYCODE WITH F->BBUYCODE
         REPLACE BUY_CODE WITH F->BUY_CODE
         REPLACE PO_NBR WITH F->PO_NBR
         REPLACE PO_SUFFIX WITH F->PO_SUFFIX
         REPLACE TOT_LBS WITH MTOT_LBS
         REPLACE SHIP_DATE WITH MSHIP_DATE
         REPLACE TOT_NET WITH F->TOT_NET
         REPLACE ITM_NET WITH F->TOT_NET
         REPLACE INV_COR WITH 'X'
         REPLACE SEQ WITH F->SEQ
      ENDIF
      SELECT F
      SKIP
   ENDDO
   
   SELECT E
   GOTO TOP
   DO WHILE .NOT. EOF()
      
      IF BBUYCODE = 'INVN'
         SELECT D
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         SEEK E->BUY_CODE
         IF .NOT. EOF()
            MCUST_NAME = NAME
            MCUST_CITY = SUBSTR(CITY,1,12)
            MCUST_ST = STATE
            MINCEN_CD = '11'
         ELSE
            STORE 'CUST NOT ON FILE' TO MCUST_NAME
            MCUST_CITY = SPACE(12)
            MCUST_ST = '  ' 
            MINCEN_CD = '11'
         ENDIF
         
      ELSE
         
         SELECT D
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         SEEK E->BBUYCODE
         IF .NOT. EOF()
            MCUST_NAME = NAME
            MCUST_CITY = SUBSTR(CITY,1,12)
            MCUST_ST = STATE
            MINCEN_CD = INCEN_CD
         ELSE
            STORE 'CUST NOT ON FILE' TO MCUST_NAME
            MCUST_CITY = SPACE(12)
            MCUST_ST = '  ' 
            MINCEN_CD = SPACE(2)
         ENDIF
      ENDIF
      SELECT E
      REPLACE NAME WITH MCUST_NAME
      REPLACE CITY WITH MCUST_CITY
      REPLACE STATE WITH MCUST_ST
      REPLACE INCEN_CD WITH MINCEN_CD
      SKIP
   ENDDO
   
   **** COMMENT THIS OUT WHEN LANCE (12) MEETS HIS SALES QUOTA
   SELECT E
   ***REPLACE INCEN_CD WITH '12' FOR INCEN_CD = '14'
   *** CROWN FOODS = '  79'
   REPLACE INCEN_CD WITH '11' FOR BBUYCODE = '  79'
   *** US FOODSERVICE - TRADE PAYABLES = ' 172'
   REPLACE INCEN_CD WITH '11' FOR BBUYCODE = ' 172'
   ************************************************************
   
   SELECT E
   INDEX ON INCEN_CD+NAME+CITY+PO_NBR+PO_SUFFIX+ITEM_NBR TO SALESMON
   DO FOX_USE WITH "SALESMON INDEX SALESMON", .T.
   
   MTIMES = 1
   DO WHILE MTIMES <= 3
      DO CASE
      CASE MTIMES = 1
         MOPT_CD = '12'
         MOPT_NAME = 'JASON MINK'
      CASE MTIMES = 2
         
         *** COMMENT THIS OUT FOR LANCE
         ***MTIMES = MTIMES + 1
         ***LOOP
         
         *** UNCOMMENT THIS FOR LANCE
         MOPT_CD = '15'
         **MOPT_NAME = 'TAYLOR BASS'
         MOPT_NAME = 'EASTERN STATES'
         
      OTHERWISE
         MOPT_CD = '11'
         MOPT_NAME = 'AMERICHICKEN/MATT'
      ENDCASE
      
      MTIMES = MTIMES + 1
      
      IF MOPT_CD <> SPACE(2)
         SET FILTER TO INCEN_CD = MOPT_CD
         GOTO TOP
      ENDIF
      
      MLINE = 99
      MPAGE_NO = 0
      DO WHILE .NOT. EOF()
         MGRAND_TOT = 0
         STORE INCEN_CD TO MINCEN_CD
         
         DO WHILE .NOT. EOF() .AND. INCEN_CD = MINCEN_CD
            
            STORE NAME+CITY TO MNAME_CITY
            MPRT_NAME = .T.
            MCUST_TOT = 0   
            DO WHILE .NOT. EOF() .AND. INCEN_CD = MINCEN_CD .AND. NAME+CITY = MNAME_CITY
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
                  @ 2,25 SAY 'MONTHLY TOTAL SUMMARY FOR ' + MTRAN_MO + '/' + MTRAN_YR
                  
                  @ 2,80 SAY DTOC(DATE())
                  @ 3,25 SAY 'SALESPERSON: ' + MOPT_NAME
                  @ 3,80 SAY TIME()
                  
                  MPRT_NAME = .T.
                  MPRT_PO   = .T.
                  @ 4,1 SAY 'CUSTOMER/'                                          
                  @ 5,1 SAY '   PO NBR  SHIP DATE   I/C  PRODUCT    QTY  SELL PR    ITEM NET   ORDER NET    CUST TOT NET'
                  *          XX-XXXX-X  XX/XX/XXXX   X   XXXXXX   99999  XX.XXXX  XXX,XXX.XX  XXX,XXX.99
                  *          12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                  *                   10        20        30        40        50        60        70        80        90        100       110
                  
                  **@ 5,01 SAY REPLICATE('_',71)
                  MLINE = 7
               ENDIF
               
               IF MPRT_NAME
                  @ MLINE,1 SAY NAME
                  MLEN = LEN(TRIM(NAME))
                  @ MLINE,1 SAY REPLICATE('_', MLEN)
                  MPRT_NAME = .F.
                  MLINE = MLINE + 1
               ENDIF
               STORE PO_NBR+PO_SUFFIX TO MPO_NBR
               MPRT_PO = .T.
               DO WHILE .NOT. EOF() .AND. INCEN_CD = MINCEN_CD .AND. NAME+CITY = MNAME_CITY .AND. PO_NBR+PO_SUFFIX = MPO_NBR
                  IF MPRT_PO
                     
                     *IF SALESMAN <> SPACE(2)
                     *   @ MLINE,1 SAY SALESMAN + '-'
                     *ENDIF
                     @ MLINE,4 SAY PO_NBR
                     IF PO_SUFFIX <> ' '
                        @ MLINE,8 SAY '-' + PO_SUFFIX
                     ENDIF
                     
                     @ MLINE,12 SAY SHIP_DATE
                     IF INV_COR = 'I'
                        @ MLINE,25 SAY INV_COR
                     ELSE
                        @ MLINE,25 SAY 'C'
                     ENDIF
                     MPRT_PO = .F.
                  ENDIF
                  IF INV_COR = 'I'
                     @ MLINE,29 SAY PROD_DESC
                  ELSE
                     @ MLINE,29 SAY 'CCCC'
                  ENDIF
                  @ MLINE,38 SAY TRANSFORM(TOT_LBS, '99999')
                  @ MLINE,45 SAY TRANSFORM(SEL_PRICE, '99.9999')
                  @ MLINE,54 SAY TRANSFORM(ITM_NET, '999,999.99')
                  @ MLINE,66 SAY TRANSFORM(TOT_NET, '@Z 999,999.99')
                  MCUST_TOT = MCUST_TOT + TOT_NET
                  MLINE = MLINE + 1
                  SKIP
               ENDDO
               MLINE = MLINE + 1
            ENDDO
            @ MLINE-2,81 SAY TRANSFORM(MCUST_TOT, '999,999.99')
            MGRAND_TOT = MGRAND_TOT + MCUST_TOT
         ENDDO
         MLINE = MLINE + 2
         @ MLINE,1 SAY 'GRAND TOTAL: '
         @ MLINE,79 SAY TRANSFORM(MGRAND_TOT, '9,999,999.99')
      ENDDO   
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

*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 4:05 PM.
