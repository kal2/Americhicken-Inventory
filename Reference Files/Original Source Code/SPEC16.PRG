************
* Program.: SPEC16.PRG
* Author..: GRACE KELLER
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SPECIAL16 - BILLBACK ACCRUALS/PAYMENTS
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
@ 02,00 SAY MPROGRAM + ' - REPORT SPEC16 - BILLBACK ACCRUALS/PAYMENTS'
@ 02,70 SAY DATE()
@ 3,0 to 24,79

STORE SPACE(2) TO MOPT_CODE
MPAPER = SPACE(6)
@ 06,05 say "Please  This report will only pick up PO's that have"
@ 07,05 say 'Note:   been posted to the ledgers - ie, after monthly closing.'
@ 08,05 say '        The report then looks at the PO Ship date for date '
@ 09,05 say '        range check - BUT - the invoice must first have been '
@ 10,05 say '        posted to the bill back ledger !'
MCHOICE = ' '
MYES_NO = SPACE(3)  
@ 13,5 SAY 'Do you want to select a specific Billback (YES/NO)? ' get MYES_NO picture '@!'
READ
IF MYES_NO <> 'YES' .AND. MYES_NO <> 'NO '
   QUIT   
ENDIF
@ 4,1 clear to 22,78
IF MYES_NO = 'YES'
   
   *** GET THE RIGHT COMMISSION PAYEE
   MNAME_FD = .F.
   DO COM_SEL1
   IF .NOT. MNAME_FD
      QUIT
   ELSE
      STORE NAME TO MCOM_NAME
      STORE COM_CODE TO MOPT_CODE
      STORE NAME TO MNAME
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
   ENDIF
ELSE
   MNAME = 'NO BILLBACK SELECTED' + SPACE(12)
   MCITY = SPACE(20)
   MSTATE = SPACE(2)
ENDIF

MTITLE = ' - BILLBACK  ACCRUALS/PAYMENTS'
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
**** GET FIRST AND LAST DATES FOR THIS REPORT
STORE CTOD(' ') TO MSTART, MLAST
STORE 'P' TO MDISP_PRT
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   @ 5,2 SAY  'Report Begin Date: '                   
   @ 7,2 SAY  '         End Date: '
   STORE 2 TO MACTION      
   DO WHILE MACTION = 2      
      @ 05,21 GET MSTART
      @ 07,21 GET MLAST
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
   INDEX ON COM_CODE + BUY_CODE + PROD_DESC + DTOC(SHIP_DATE) TO TEMPPROD
   DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .T.
   
   SELECT A
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
   
   SELECT B
   DO FOX_USE WITH "PO_DTL INDEX  PO_DTL", .F.
   
   SELECT D
   DO FOX_USE WITH "&MMASTDBF.BBKLED INDEX &MMASTDBF.BBKLED", .F.
   SET FILTER TO COR_FLG = 'I'
   GOTO TOP
   
   SEEK MSTRT_YR + MSTRT_MO
   
   DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR+TRAN_MO) <= VAL(MLAST_YR+MLAST_MO)
      IF MOPT_CODE <> '  '
         IF COM_CODE <> MOPT_CODE
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      SELECT A
      SEEK D->SALESMAN + D->PO_NBR + D->PO_SUFFIX
      STORE SHIP_DATE TO MSHIP_DATE
      STORE BBUYCODE TO MBBUYCODE
      STORE BUY_CODE TO MBUY_CODE
      
      DO CASE
      CASE D->COM_CODE = COM_CODE
         MNBR = '1'
      CASE D->COM_CODE = COM_CODE2
         MNBR = '2'
      CASE D->COM_CODE = COM_CODE3
         MNBR = '3'
      OTHERWISE
         MNBR = '0'
      ENDCASE
      
      SELECT B
      SEEK D->SALESMAN + D->PO_NBR + D->PO_SUFFIX
      
      DO WHILE .NOT. EOF() .AND. SALESMAN = D->SALESMAN .AND. PO_NBR = D->PO_NBR .AND. PO_SUFFIX = D->PO_SUFFIX
         IF MNBR = '0'
            MAMT = 0
         ELSE
            MI = MNBR
            MCOMM_LB = COM&MI._CENT
            DO CASE
            CASE (PROD_DESC = '47184' .OR. PROD_DESC = '51221' .OR. PROD_DESC = '51160') .AND. A->BBUYCODE = ' 189'
               MAMT = = ROUND(COM&MI._CENT * QTY,2)
            CASE (PROD_DESC = '65521' .OR. PROD_DESC = '65543') .AND. D->COM_CODE = '32'
               MAMT = ROUND(COM&MI._CENT * QTY,2)
            OTHERWISE
               MAMT = ROUND(COM&MI._CENT * LBS,2)
            ENDCASE
         ENDIF
         IF MAMT = 0
            SKIP
            LOOP
         ENDIF
         SELECT E
         APPEND BLANK
         REPLACE COM_CODE  WITH D->COM_CODE
         REPLACE BUY_CODE  WITH MBUY_CODE
         REPLACE BBUYCODE  WITH MBBUYCODE
         REPLACE SHIP_DATE WITH MSHIP_DATE
         REPLACE SALESMAN  WITH D->SALESMAN
         REPLACE PO_NBR    WITH D->PO_NBR
         REPLACE PO_SUFFIX WITH D->PO_SUFFIX
         REPLACE PROD_DESC WITH B->PROD_DESC
         REPLACE TOT_LBS   WITH B->CALC_LBS
         REPLACE TOT_CASE  WITH B->QTY
         REPLACE TOT_COMM  WITH MAMT
         REPLACE COMM_LB   WITH MCOMM_LB
         SELECT B                  
         SKIP
      ENDDO
      SELECT D
      SKIP
   ENDDO
   
   SELECT B
   USE
   SELECT A
   USE
   SELECT D
   USE
   
   SELECT A 
   DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
   
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
   
   SELECT C
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
   
   SELECT E
   DO FOX_USE WITH "TEMPPROD", .T.
   
   GOTO TOP
   
   DO WHILE .NOT. EOF()
      SELECT A
      SEEK E->COM_CODE
      SELECT E
      REPLACE NAME WITH A->NAME
      
      SELECT B
      SEEK E->BUY_CODE
      SELECT E
      REPLACE CUST_NAME WITH B->NAME
      
      SELECT C
      SEEK E->BBUYCODE
      SELECT E
      REPLACE BBUYNAME WITH C->NAME
      SKIP
   ENDDO
   
   SELECT A
   USE
   SELECT B
   USE
   SELECT C
   USE
   
   SELECT A
   DO FOX_USE WITH "BBKLED INDEX BBKLED", .F.
   
   SELECT E
   ***SUSPEND
   
   DO FOX_USE WITH "TEMPPROD", .T.
   INDEX ON NAME +COM_CODE + CUST_NAME + BUY_CODE + PROD_DESC + DTOC(SHIP_DATE) TO TEMPPROD
   
   DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .T.
   
   GOTO TOP
   STORE 0 TO GTOT_LBS, GTOT_CASE, GTOT_COMM, GBAL
   STORE 0 TO GPD_LBS, GPD_CASE, GPD_COMM
   **SUSPEND
   
   DO WHILE .NOT. EOF()
      STORE NAME TO MNAME
      STORE COM_CODE TO MCOM_CODE
      STORE 0 TO TTOT_LBS, TTOT_CASE, TTOT_COMM, TBAL
      STORE 0 TO TPD_LBS, TPD_CASE, TPD_COMM
      MPRT_COM = .T.
      MPRT_BAL = .T.
      
      SELECT A
      SEEK MSTRT_YR+MSTRT_MO+'T' + MCOM_CODE
      IF .NOT. EOF() .AND. COR_FLG = ' '
         STORE AMOUNT TO MBEG_BAL
      ELSE
         STORE 0 TO MBEG_BAL
      ENDIF
      
      SELECT E
      DO WHILE .NOT. EOF() .AND. NAME+COM_CODE = MNAME+MCOM_CODE
         STORE CUST_NAME TO MCUST_NAME
         STORE BUY_CODE  TO MBUY_CODE
         STORE 0 TO CTOT_LBS, CTOT_CASE, CTOT_COMM, CBAL
         STORE 0 TO CPD_LBS, CPD_CASE, CPD_COMM
         MPRT_NAME = .T.
         
         DO WHILE .NOT. EOF() .AND. NAME+COM_CODE = MNAME+MCOM_CODE .AND. CUST_NAME+BUY_CODE = MCUST_NAME+MBUY_CODE
            STORE 0 TO PTOT_LBS, PTOT_CASE, PTOT_COMM, PBAL
            STORE 0 TO PPD_LBS, PPD_CASE, PPD_COMM
            STORE PROD_DESC TO MPROD_DESC
            MPRT_PROD = .T.
            
            DO WHILE .NOT. EOF() .AND. NAME+COM_CODE = MNAME+MCOM_CODE .AND. CUST_NAME+BUY_CODE = MCUST_NAME+MBUY_CODE .AND. PROD_DESC = MPROD_DESC
               
               IF MLINE > MPAGE_LEN .OR. MPRT_COM
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
                  @ 2,25 SAY 'BILLBACK ACTIVITY FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
                  @ 2,80 SAY DTOC(DATE())
                  @ 3,25 SAY 'BILLBACK: ' + MNAME
                  @ 3,80 SAY TIME()
                  
                  MPRT_PROD   = .T.
                  MPRT_NAME   = .T.
                  MPRT_COM    = .F.
                  @ 5,1 SAY '       PO NUMBER  SHIP DATE   BILL TO        QTY     POUNDS     BB/LB    AMOUNT'
                  *                 XX-XXXX-X  XX/XX/XXXX  XXXXXXXXXX  999999  XXXXXX.XX   XX.XXXX  XXXXX.XX
                  *          1234567890123456789012345678901234567890123456789012345678901234567890123456789012
                  *                   10        20        30        40        50        60        70        80
                  @ 5,01 SAY REPLICATE('_',79)
                  MLINE = 7
               ENDIF
               
               IF MPRT_BAL
                  @ MLINE,1 SAY 'BILLBACK BEGINNING BALANCE'
                  @ MLINE,72 SAY MBEG_BAL PICTURE '99999.99'
                  MPRT_BAL = .F.
                  MLINE = MLINE + 1
               ENDIF
               
               IF MPRT_NAME
                  @ MLINE,1 SAY MCUST_NAME
                  MPRT_NAME = .F.
                  MLINE = MLINE  + 1
               ENDIF
               
               IF MPRT_PROD
                  @ MLINE,5 SAY 'PRODUCT: ' + MPROD_DESC
                  MPRT_PROD = .F.
                  MLINE = MLINE + 1
               ENDIF
               
               IF SALESMAN <> SPACE(2)
                  @ MLINE,8 SAY SALESMAN + '-'
               ENDIF
               @ MLINE,11 SAY PO_NBR
               IF PO_SUFFIX <> ' '
                  @ MLINE,15 SAY '-' + PO_SUFFIX
               ENDIF
               @ MLINE,19 SAY SHIP_DATE                     
               @ MLINE,31 SAY SUBSTR(BBUYNAME,1,10)
               @ MLINE,43 SAY TOT_CASE PICTURE '999999'
               @ MLINE,51 SAY TOT_LBS PICTURE '999999.99'
               @ MLINE,63 SAY COMM_LB PICTURE '99.9999'
               @ MLINE,72 SAY TOT_COMM PICTURE '99999.99'
               MLINE = MLINE + 1
               
               *** ADD IN FOR PRODUCT TOTALS
               
               PTOT_LBS  = PTOT_LBS  + TOT_LBS
               PTOT_CASE = PTOT_CASE + TOT_CASE
               PTOT_COMM = PTOT_COMM + TOT_COMM
               
               SKIP
            ENDDO
            *** DO PRODUCT TOTALS
            @ MLINE,8  SAY 'PRODUCT SUBTOTAL:'
            @ MLINE,42 SAY PTOT_CASE PICTURE '9999999'
            @ MLINE,50 SAY PTOT_LBS PICTURE '9999999.99'
            @ MLINE,71 SAY PTOT_COMM PICTURE '999999.99'
            MLINE = MLINE + 2
            *** ADD IN FOR CUSTOMER TOTALS
            CPD_LBS   = CPD_LBS   + PTOT_LBS
            CPD_CASE  = CPD_CASE  + PTOT_CASE
            CPD_COMM  = CPD_COMM  + PTOT_COMM
            CTOT_LBS  = CTOT_LBS  + PTOT_LBS
            CTOT_CASE = CTOT_CASE + PTOT_CASE
            CTOT_COMM = CTOT_COMM + PTOT_COMM
         ENDDO
         *** DO CUSTOMER TOTALS
         @ MLINE,1  SAY '->SUB: ' + MCUST_NAME
         @ MLINE,42 SAY CTOT_CASE PICTURE '9999999'
         @ MLINE,50 SAY CTOT_LBS PICTURE '9999999.99'
         @ MLINE,71 SAY CTOT_COMM PICTURE '999999.99'
         MLINE = MLINE + 3
         *** ADD IN FOR THIRD PARTY TOTALS
         TPD_LBS   = TPD_LBS   + CTOT_LBS
         TPD_CASE  = TPD_CASE  + CTOT_CASE
         TPD_COMM  = TPD_COMM  + CTOT_COMM
         TTOT_LBS  = TTOT_LBS  + CTOT_LBS
         TTOT_CASE = TTOT_CASE + CTOT_CASE
         TTOT_COMM = TTOT_COMM + CTOT_COMM
      ENDDO
      *** DO THIRD PARTY TOTALS
      @ MLINE,1  SAY '->TOT: ' + MNAME
      @ MLINE,42 SAY TTOT_CASE PICTURE '9999999'
      @ MLINE,50 SAY TTOT_LBS PICTURE '9999999.99'
      @ MLINE,71 SAY TTOT_COMM PICTURE '999999.99'
      MLINE = MLINE + 2
      @ MLINE,1  SAY '->ENDING BALANCE: ' + MNAME
      @ MLINE,71 SAY TTOT_COMM + MBEG_BAL PICTURE '999999.99'
      
      MLINE = MLINE + 3
      *** ADD IN FOR GRAND TOTALS      
      GPD_LBS   = GPD_LBS   + TTOT_LBS
      GPD_CASE  = GPD_CASE  + TTOT_CASE
      GPD_COMM  = GPD_COMM  + TTOT_COMM
      GTOT_LBS  = GTOT_LBS  + TTOT_LBS
      GTOT_CASE = GTOT_CASE + TTOT_CASE
      GTOT_COMM = GTOT_COMM + TTOT_COMM
      GBAL      = GBAL      + MBEG_BAL
      MLINE = 88
   ENDDO
   **** NOW DO GRAND TOTALS
   
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
   @ 2,25 SAY 'BILLBACK ACTIVITY FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
   @ 2,80 SAY DTOC(DATE())
   @ 3,80 SAY TIME()
   MLINE = 6
   
   IF MDISP_PRT = 'P'
      @ MLINE,1 SAY 'GRAND TOTALS'
      @ MLINE,41 SAY GTOT_CASE PICTURE '99999999'
      @ MLINE,49 SAY GTOT_LBS PICTURE '99999999.99'
      @ MLINE,70 SAY GTOT_COMM PICTURE '9999999.99'
      MLINE = MLINE + 1
      @ MLINE,1 SAY 'TOTAL ENDING BALANCE'
      @ MLINE,70 SAY GBAL PICTURE '9999999.99'
      
      @ MLINE,1 SAY ' '
      EJECT
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
   ELSE
      @ MLINE,1 SAY 'GRAND TOTALS/AVGS'
      @ MLINE,41 SAY GTOT_CASE PICTURE '99999999'
      @ MLINE,49 SAY GTOT_LBS PICTURE '99999999.99'
      @ MLINE,70 SAY GTOT_COMM PICTURE '9999999.99'
      MPRT_SEL = ' '
      @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
      READ
   ENDIF
   CLOSE DATA
   MNOT_DONE = .F.
ENDDO
QUIT

*Formatted by: ToolBox Ver. 1.2  on 12/17/15 at 9:30 AM.
