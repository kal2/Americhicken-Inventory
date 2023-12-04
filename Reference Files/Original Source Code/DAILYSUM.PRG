************
* Program.: DAILYSUM.PRG
* Author..: GRACE KELLER
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: DAILY SALES SUMMARY
*
* ---SET environment.
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

MTITLE = ' - DAILY SALES DETAIL SUMMARY'
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
**** GET DATE FOR THIS REPORT
STORE DATE() TO MDATE
STORE 0 TO MTRAN_YR, MTRAN_MO
STORE 'P' TO MDISP_PRT
MOPTION = 'REGULAR'
MI_OPT = 'ALL  '         
STORE '**' TO MOPT_SALES
STORE 2 TO MACTION
STORE 'Y' TO MINC_BOX
DO WHILE MACTION = 2
   @ 06,5 SAY '            ENTER REPORT DATE: '
   @ 06,37 GET MDATE
   @ 08,2 SAY 'REPORT FORMAT (REGULAR OR PLANT):'      
   @ 08,37 GET MOPTION PICTURE '@!' VALID(MOPTION = 'REGULAR' .OR. MOPTION = 'PLANT' .OR. MOPTION = ' ')  
   @ 10,5 SAY 'DISPLAY OR PRINT REPORT (D/P):'
   @ 10,37 GET MDISP_PRT PICTURE '@!'
   @ 12,5 say '         Optional Salesperson:'
   @ 12,37 GET MOPT_SALES PICTURE '##'
   
   DO CASE
   CASE  MCOMPANY = 'DIVISION 15'
      *MI_OPT = 'SALES'
      @ 12,5 SAY '      SELECT CUSTOMER SALES (SALES) OR'
      @ 13,5 SAY 'ORDERS GOING INTO INVENTORY (INVEN) OR'
      @ 14,5 say '                   ALL ORDERS (ALL) ' GET MI_OPT PICTURE '@!'
   CASE MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
      @ 14,5 say '    Include Western Box (Y/N):'
      @ 14,37 GET MINC_BOX PICTURE '@!' VALID(MINC_BOX = 'Y' .OR. MINC_BOX = 'N')
   ENDCASE
   @ 16,5 say '(OPTIONAL: ENTER FOLLOWING FIELDS FOR MONTHLY SPREADSHEET TOTALS)'
   @ 17,5 SAY '           MONTH AND YEAR:    /   '
   @ 17,32 GET MTRAN_MO PICTURE '##'
   @ 17,37 GET MTRAN_YR PICTURE '####'
   STORE 1 TO MACTION
   @ 23,00 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   IF MACTION = 1
      IF DTOC(MDATE) = '  /  /  '
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
   MPAGE_LEN = 58
ELSE
   MPAGE_LEN = 22
ENDIF

STORE MONTH(MDATE) TO MMONTH
MMONTH = MMONTH + 100
STORE SUBSTR(STR(MMONTH,3),2) TO MMONTH

STORE YEAR(MDATE) TO MYEAR
STORE STR(MYEAR,4) TO MYEAR

STORE DAY(MDATE) TO MDAY
MDAY = MDAY + 100
STORE SUBSTR(STR(MDAY,3),2) TO MDAY

SELECT A
DO FOX_USE WITH "INV_HEAD INDEX INV_DATE", .F.
SEEK MYEAR + MMONTH + MDAY
IF EOF()
   @ 4,1 CLEAR TO 21,78 
   @ 10,5 SAY 'THERE IS NO SALES INVOICING DATA ON FILE FOR THIS DATE'
   STORE ' ' TO MWAIT
   @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
   READ
   RETURN
ENDIF

SELECT C
DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
SELECT D
DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.

SELECT A
IF MOPT_SALES <> '**'
   SET FILTER TO SALESMAN = MOPT_SALES
   GOTO TOP
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
   
   *** PRINT IN 12 CPI
   ?? chr(27) + '&k4S'
   
   *** LETTER GOTHIC AND BOLDED PRINT
   ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
   
   *** LETTER SIZE PAPER
   ?? CHR(27) + '&l2A'
   
   *** PORTRAIT MODE
   ?? CHR(27) + '&l0O'
   
ENDIF

MCORR = 0
MPURCH = 0
MSELL = 0
MTOTAL = 0
MCOMM = 0
SEEK MYEAR + MMONTH + MDAY

DO CASE
CASE MOPTION = 'REGULAR'
   DO WHILE .NOT. EOF() .AND. MYEAR = SUBSTR(DTOC(INV_DATE),7) .AND. VAL(MMONTH) = VAL(SUBSTR(DTOC(INV_DATE),1,2)) .and. val(MDAY) = VAL(SUBSTR(DTOC(INV_DATE),4,2))
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
         DO CASE
         CASE MI_OPT = 'INVEN'
            @ 2,22 SAY 'DAILY INVENTORY SUMMARY FOR ' + DTOC(MDATE)
         CASE MI_OPT = 'SALES'
            @ 2,22 SAY 'DAILY SALES DETAIL SUMMARY FOR ' + DTOC(MDATE)
         OTHERWISE
            @ 2,22 SAY 'DAILY ORDER DETAIL SUMMARY FOR ' + DTOC(MDATE)
         ENDCASE
         @ 2,70 SAY DTOC(DATE())
         @ 4,0 SAY 'INV NBR'
         @ 4,10 SAY 'SUPPLIER'
         @ 4,22 SAY 'TOT PURCH'
         @ 4,33 SAY 'CUSTOMER'
         @ 4,46 SAY 'TOT SELL'
         IF MCOMPANY = 'DIVISION 15'
            @ 4,56 SAY '   PROFIT %'
         ELSE
            @ 4,56 SAY 'BROKR'
            @ 4,65 SAY 'COMM'
         ENDIF
         @ 4,73 SAY 'TOT NET'
         
         IF MDISP_PRT = 'P'
            @ 4,83 SAY 'AVG LB'
            @ 4,0 SAY REPLICATE ('_',89)
         ELSE
            @ 5,0 SAY REPLICATE ('-',79)
         ENDIF
         MLINE = 6
      ENDIF
      
      STORE SALESMAN TO MSALESMAN
      STORE PO_NBR TO MPO_NBR
      STORE PO_SUFFIX TO MPO_SUFFIX
      
      SELECT C
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      IF EOF()
         STORE 'NONE' TO MRSUPCODE, MBBUYCODE
      ELSE
         STORE RSUPCODE TO MRSUPCODE
         STORE BBUYCODE TO MBBUYCODE
      ENDIF
      DO CASE
      CASE MI_OPT = 'SALES'
         IF BBUYCODE = 'INVN'
            SELECT A
            SKIP
            LOOP
         ENDIF
      CASE MI_OPT = 'INVEN'
         IF BBUYCODE <> 'INVN' 
            SELECT A
            SKIP
            LOOP
         ENDIF
      ENDCASE
      SELECT D
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      IF .NOT. EOF()
         STORE SUBSTR(PROD_DESC,1,5) TO MPROD
      ELSE
         STORE SPACE(5) TO MPROD
      ENDIF
      
      SELECT B
      IF MRSUPCODE = 'NONE'
         STORE 'NONE' + SPACE(6) TO MRSUPNAME
      ELSE
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
         SEEK MRSUPCODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,10) TO MRSUPNAME
         ELSE 
            STORE 'NOTONFILE ' TO MRSUPNAME
         ENDIF
      ENDIF
      
      IF MBBUYCODE = 'NONE'
         STORE 'NONE' + SPACE(56) TO MBBUYNAME
      ELSE  
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         SEEK MBBUYCODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,10) TO MBBUYNAME
         ELSE 
            STORE 'NOTONFILE ' TO MBBUYNAME
         ENDIF
      ENDIF
      
      IF MSALESMAN <> SPACE(2)
         DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
         SEEK MSALESMAN
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,5) TO MSAL_NAME
         ELSE
            STORE SPACE(05) TO MSAL_NAME
         ENDIF
      ELSE
         SELECT C
         STORE SUBSTR(BROK_NAME,1,05) TO MSAL_NAME
      ENDIF
      
      SELECT C
      IF SALESMAN <> SPACE(2)
         STORE SALESMAN + '-' + INV_NBR TO MINV_NBR
      ELSE
         STORE INV_NBR TO MINV_NBR
      ENDIF
      
      @ MLINE,0  SAY MINV_NBR
      @ MLINE,10 SAY MRSUPNAME
      @ MLINE,21 SAY TOT_PURCH PICTURE '999,999.99'
      MPURCH = MPURCH + TOT_PURCH
      @ MLINE,33 SAY MBBUYNAME
      @ MLINE,44 SAY TOT_SELL PICTURE '999,999.99'
      MSELL = MSELL + TOT_SELL
      MSTORAGE = 0
      MTOT_NET = TOT_NET
      IF MCOMPANY = 'DIVISION 15'
         SELECT C
         MTOT_NET = TOT_NET - MSTORAGE
         IF TOT_PURCH <> 0       
            MPERCENT = ROUND((MTOT_NET/TOT_PURCH) * 100,1)
         ELSE
            MPERCENT = 0
         ENDIF
         @ MLINE,60 SAY MPERCENT PICTURE '999.9'       
         @ MLINE,66 SAY '%'
      ELSE
         @ MLINE,56 SAY MSAL_NAME
         @ MLINE,61 SAY SALE_COMM PICTURE '99999.99'
      ENDIF
      MCOMM = MCOMM + SALE_COMM
      
      @ MLINE,70 SAY MTOT_NET PICTURE '999,999.99'
      
      MTOTAL = MTOTAL + MTOT_NET
      
      IF COM_CODE <> SPACE(2) .AND. COMM_AMT <> 0
         STORE COM_CODE TO MCOM_CODE
         SELECT B
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         SEEK MCOM_CODE
         IF .NOT. EOF()
            STORE NAME TO MCOM_NAME
         ELSE  
            STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME
         ENDIF
         SELECT C
         MLINE = MLINE + 2
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
            DO CASE
            CASE MI_OPT = 'INVEN'
               @ 2,22 SAY 'DAILY INVENTORY SUMMARY FOR ' + DTOC(MDATE)
            CASE MI_OPT = 'SALES'
               @ 2,22 SAY 'DAILY SALES DETAIL SUMMARY FOR ' + DTOC(MDATE)
            OTHERWISE
               @ 2,22 SAY 'DAILY ORDER DETAIL SUMMARY FOR ' + DTOC(MDATE)
            ENDCASE
            @ 2,70 SAY DTOC(DATE())
            @ 4,0 SAY 'INV NBR'
            @ 4,10 SAY 'SUPPLIER'
            @ 4,22 SAY 'TOT PURCH'
            @ 4,33 SAY 'CUSTOMER'
            @ 4,46 SAY 'TOT SELL'
            IF MCOMPANY = 'DIVISION 15'
               @ 4,56 SAY '   PROFIT %'
            ELSE
               @ 4,56 SAY 'BROKR'
               @ 4,65 SAY 'COMM'
            ENDIF
            @ 4,73 SAY 'TOT NET'
            IF MDISP_PRT = 'P'
               @ 4,0 SAY REPLICATE ('_',80)
            ELSE
               @ 5,0 SAY REPLICATE ('-',79)
            ENDIF
            MLINE = 6
         ENDIF
         @ MLINE,0 SAY MINV_NBR
         @ MLINE,56 SAY SUBSTR(MCOM_NAME,1,5)
         @ MLINE,61 SAY COMM_AMT PICTURE '99999.99'
         MCOMM = MCOMM + COMM_AMT
      ENDIF
      
      IF COM_CODE2 <> SPACE(2) .AND. COMM_AMT2 <> 0
         STORE COM_CODE2 TO MCOM_CODE2
         SELECT B
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         SEEK MCOM_CODE2
         IF .NOT. EOF()
            STORE NAME TO MCOM_NAME2
         ELSE  
            STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME2
         ENDIF
         SELECT C
         MLINE = MLINE + 2
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
            DO CASE
            CASE MI_OPT = 'INVEN'
               @ 2,22 SAY 'DAILY INVENTORY SUMMARY FOR ' + DTOC(MDATE)
            CASE MI_OPT = 'SALES'
               @ 2,22 SAY 'DAILY SALES DETAIL SUMMARY FOR ' + DTOC(MDATE)
            OTHERWISE
               @ 2,22 SAY 'DAILY ORDER DETAIL SUMMARY FOR ' + DTOC(MDATE)
            ENDCASE
            @ 2,70 SAY DTOC(DATE())
            @ 4,0 SAY 'INV NBR'
            @ 4,10 SAY 'SUPPLIER'
            @ 4,22 SAY 'TOT PURCH'
            @ 4,33 SAY 'CUSTOMER'
            @ 4,46 SAY 'TOT SELL'
            IF MCOMPANY = 'DIVISION 15'
               @ 4,56 SAY '   PROFIT %'
            ELSE
               @ 4,56 SAY 'BROKR'
               @ 4,65 SAY 'COMM'
            ENDIF
            @ 4,73 SAY 'TOT NET'
            IF MDISP_PRT = 'P'
               @ 4,0 SAY REPLICATE ('_',80)
            ELSE
               @ 5,0 SAY REPLICATE ('-',79)
            ENDIF
            MLINE = 6
         ENDIF
         @ MLINE,0 SAY MINV_NBR
         @ MLINE,56 SAY SUBSTR(MCOM_NAME2,1,5)
         @ MLINE,61 SAY COMM_AMT2 PICTURE '99999.99'
         MCOMM = MCOMM + COMM_AMT2
      ENDIF
      
      IF COM_CODE3 <> SPACE(2) .AND. COMM_AMT3 <> 0
         STORE COM_CODE3 TO MCOM_CODE3
         SELECT B
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         SEEK MCOM_CODE3
         IF .NOT. EOF()
            STORE NAME TO MCOM_NAME3
         ELSE  
            STORE '3RD PARTY COMM PAYEE NOT ON FILE' TO MCOM_NAME3
         ENDIF
         SELECT C
         MLINE = MLINE + 2
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
            DO CASE
            CASE MI_OPT = 'INVEN'
               @ 2,22 SAY 'DAILY INVENTORY SUMMARY FOR ' + DTOC(MDATE)
            CASE MI_OPT = 'SALES'
               @ 2,22 SAY 'DAILY SALES DETAIL SUMMARY FOR ' + DTOC(MDATE)
            OTHERWISE
               @ 2,22 SAY 'DAILY ORDER DETAIL SUMMARY FOR ' + DTOC(MDATE)
            ENDCASE
            @ 2,70 SAY DTOC(DATE())
            @ 4,0 SAY 'INV NBR'
            @ 4,10 SAY 'SUPPLIER'
            @ 4,22 SAY 'TOT PURCH'
            @ 4,33 SAY 'CUSTOMER'
            @ 4,46 SAY 'TOT SELL'
            IF MCOMPANY = 'DIVISION 15'
               @ 4,56 SAY '   PROFIT %'
            ELSE
               @ 4,56 SAY 'BROKR'
               @ 4,65 SAY 'COMM'
            ENDIF
            @ 4,73 SAY 'TOT NET'
            IF MDISP_PRT = 'P'
               @ 4,0 SAY REPLICATE ('_',80)
            ELSE
               @ 5,0 SAY REPLICATE ('-',80)
            ENDIF
            MLINE = 6
         ENDIF
         @ MLINE,0 SAY MINV_NBR
         @ MLINE,56 SAY SUBSTR(MCOM_NAME3,1,5)
         @ MLINE,61 SAY COMM_AMT3 PICTURE '99999.99'
         MCOMM = MCOMM + COMM_AMT3
      ENDIF
      
      IF SAL_CODE2 <> SPACE(2) .AND. (SALE2_AMT <> 0 .OR. SALE2_NET <> 0)
         STORE SAL_CODE2 TO MSAL_CODE2
         SELECT B
         **RON MONTGOMERY CHANGES
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         **DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
         SEEK MSAL_CODE2
         IF .NOT. EOF()
            STORE NAME TO MSAL_NAME2
         ELSE
            STORE '3RD PARTY CONTRACTOR NOT ON FILE' TO MSAL_NAME2
         ENDIF
         SELECT C
         MLINE = MLINE + 2
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
            DO CASE
            CASE MI_OPT = 'INVEN'
               @ 2,22 SAY 'DAILY INVENTORY SUMMARY FOR ' + DTOC(MDATE)
            CASE MI_OPT = 'SALES'
               @ 2,22 SAY 'DAILY SALES DETAIL SUMMARY FOR ' + DTOC(MDATE)
            OTHERWISE
               @ 2,22 SAY 'DAILY ORDER DETAIL SUMMARY FOR ' + DTOC(MDATE)
            ENDCASE
            @ 2,70 SAY DTOC(DATE())
            @ 4,0 SAY 'INV NBR'
            @ 4,10 SAY 'SUPPLIER'
            @ 4,22 SAY 'TOT PURCH'
            @ 4,33 SAY 'CUSTOMER'
            @ 4,46 SAY 'TOT SELL'
            IF MCOMPANY = 'DIVISION 15'
               @ 4,56 SAY '   PROFIT %'
            ELSE
               @ 4,56 SAY 'BROKR'
               @ 4,65 SAY 'COMM'
            ENDIF
            @ 4,73 SAY 'TOT NET'
            IF MDISP_PRT = 'P'
               @ 4,0 SAY REPLICATE ('_',80)
            ELSE
               @ 5,0 SAY REPLICATE ('-',79)
            ENDIF
            MLINE = 6
         ENDIF
         @ MLINE,0 SAY MINV_NBR
         @ MLINE,56 SAY SUBSTR(MSAL_NAME2,1,5)
         @ MLINE,62 SAY SALE2_AMT PICTURE '9999.99'
         @ MLINE,71 SAY SALE2_NET PICTURE '99,999.99'
         MCOMM = MCOMM + SALE2_AMT 
         
         MTOTAL = MTOTAL + SALE2_NET
      ENDIF
      IF SAL_CODE3 <> SPACE(2) .AND. (SALE3_AMT <> 0 .OR. SALE3_NET <> 0)
         STORE SAL_CODE3 TO MSAL_CODE3
         SELECT B
         DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
         SEEK MSAL_CODE3
         IF .NOT. EOF()
            STORE NAME TO MSAL_NAME3
         ELSE
            STORE 'SALESPERSON NOT ON FILE         ' TO MSAL_NAME3
         ENDIF
         SELECT C
         MLINE = MLINE + 2
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
            DO CASE
            CASE MI_OPT = 'INVEN'
               @ 2,22 SAY 'DAILY INVENTORY SUMMARY FOR ' + DTOC(MDATE)
            CASE MI_OPT = 'SALES'
               @ 2,22 SAY 'DAILY SALES DETAIL SUMMARY FOR ' + DTOC(MDATE)
            OTHERWISE
               @ 2,22 SAY 'DAILY ORDER DETAIL SUMMARY FOR ' + DTOC(MDATE)
            ENDCASE
            @ 2,70 SAY DTOC(DATE())
            @ 4,0 SAY 'INV NBR'
            @ 4,10 SAY 'SUPPLIER'
            @ 4,22 SAY 'TOT PURCH'
            @ 4,33 SAY 'CUSTOMER'
            @ 4,46 SAY 'TOT SELL'
            IF MCOMPANY = 'DIVISION 15'
               @ 4,56 SAY '   PROFIT %'
            ELSE
               @ 4,56 SAY 'BROKR'
               @ 4,65 SAY 'COMM'
            ENDIF
            @ 4,73 SAY 'TOT NET'
            IF MDISP_PRT = 'P'
               @ 4,0 SAY REPLICATE ('_',80)
            ELSE
               @ 5,0 SAY REPLICATE ('-',79)
            ENDIF
            MLINE = 6
         ENDIF
         @ MLINE,0 SAY MINV_NBR
         @ MLINE,56 SAY SUBSTR(MSAL_NAME3,1,5)
         @ MLINE,62 SAY SALE3_AMT PICTURE '9999.99'
         @ MLINE,71 SAY SALE3_NET PICTURE '99,999.99'
         MCOMM = MCOMM + SALE3_AMT 
         
         MTOTAL = MTOTAL + SALE3_NET
      ENDIF
      IF MDISP_PRT = 'P'
         @ MLINE,82 SAY ROUND((TOT_NET+SALE2_NET+SALE_COMM+COMM_AMT+COMM_AMT2+COMM_AMT3+SALE2_AMT+SALE3_NET+SALE3_AMT) / TOT_LBS,4) PICTURE '99.9999'
         @ MLINE+1,1 SAY ' '
      ENDIF
      MLINE = MLINE + 2
      SELECT A
      SKIP
   ENDDO
   
OTHERWISE
   
   DO WHILE .NOT. EOF() .AND. MYEAR = SUBSTR(DTOC(INV_DATE),7) .AND. VAL(MMONTH) = VAL(SUBSTR(DTOC(INV_DATE),1,2)) .and. val(MDAY) = VAL(SUBSTR(DTOC(INV_DATE),4,2))
      
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
         @ 2,22 SAY 'DAILY SALES DETAIL SUMMARY FOR ' + DTOC(MDATE)
         @ 2,70 SAY DTOC(DATE())
         
         @ 4,1 SAY 'INV NBR    PRODUCT      TOT PURCH   CUSTOMER     PRI/LB    TOT SELL    FREIGHT      TOT NET'
         IF MDISP_PRT = 'P'
            @ 4,0 SAY REPLICATE ('_',92)
         ELSE
            @ 5,0 SAY REPLICATE ('-',79)
         ENDIF
         MLINE = 6
      ENDIF
      
      STORE SALESMAN TO MSALESMAN
      STORE PO_NBR TO MPO_NBR
      STORE PO_SUFFIX TO MPO_SUFFIX
      MFREIGHT = FRT1_AMT  
      SELECT C
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      IF EOF()
         STORE 'NONE' TO MRSUPCODE, MBBUYCODE
      ELSE
         STORE RSUPCODE TO MRSUPCODE
         STORE BBUYCODE TO MBBUYCODE
      ENDIF
      
      SELECT B
      IF MRSUPCODE = 'NONE'
         STORE 'NONE' + SPACE(6) TO MRSUPNAME
      ELSE
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
         SEEK MRSUPCODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,10) TO MRSUPNAME
         ELSE 
            STORE 'NOTONFILE ' TO MRSUPNAME
         ENDIF
      ENDIF
      
      IF MBBUYCODE = 'NONE'
         STORE 'NONE' + SPACE(56) TO MBBUYNAME
      ELSE  
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         SEEK MBBUYCODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,10) TO MBBUYNAME
         ELSE 
            STORE 'NOTONFILE ' TO MBBUYNAME
         ENDIF
      ENDIF
      
      SELECT C
      IF SALESMAN <> SPACE(2)
         STORE SALESMAN + '-' + INV_NBR TO MINV_NBR
      ELSE
         STORE INV_NBR TO MINV_NBR
      ENDIF
      
      SELECT D
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      IF .NOT. EOF()
         STORE SUBSTR(PROD_DESC,1,5) TO MPROD
      ELSE
         STORE SPACE(5) TO MPROD
      ENDIF
      DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
         @ MLINE,1  SAY MINV_NBR
         SELECT E
         DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
         SEEK 'R' + SUBSTR(D->PROD_DESC,1,4)
         MPROD_DESC = DESC
         SELECT D
         **** THERE
         @ MLINE,10 SAY MRSUPNAME
         @ MLINE,21 SAY TOT_PURCH PICTURE '999,999.99'
         MPURCH = MPURCH + TOT_PURCH
         @ MLINE,33 SAY MBBUYNAME
         @ MLINE,44 SAY TOT_SELL PICTURE '999,999.99'
         MSELL = MSELL + TOT_SELL
         @ MLINE,56 SAY MSAL_NAME
         
         @ MLINE,61 SAY SALE_COMM PICTURE '99999.99'
         MCOMM = MCOMM + SALE_COMM
         @ MLINE,71 SAY TOT_NET PICTURE '99,999.99'
         @ MLINE+1,1 SAY ' '
         MTOTAL = MTOTAL + TOT_NET
         MLINE = MLINE + 2
         SKIP
      ENDDO
      
      MLINE = MLINE + 2
      SELECT A
      SKIP
   ENDDO
ENDCASE


*** BBUYCODE = '  16' = BRYAN FOODS - KEEP THEM SEPERATE
MBRYANNET = 0
*** SALESMAN OR SAL_CODE2 = '85' = SOUTHERN CALIFORNIA MEAT & PROVISIONS
***                                KEEP THEM SEPERATE TOO
MSOUTHCAL = 0
MTOT_SALES = 0
MTOT_NET = 0 

MCOR_SALES = 0
MCOR_NET   = 0

IF MTRAN_MO = 0 .AND. MTRAN_YR = 0
   MTRAN_MO = '  '
   MTRAN_YR = '  '
ELSE
   SELECT A
   DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
   IF MOPT_SALES <> '**'
      SET FILTER TO SALESMAN = MOPT_SALESS
      GOTO TOP
   ENDIF
   
   MTRAN_MO = MTRAN_MO + 100
   STORE SUBSTR(STR(MTRAN_MO,3),2) TO MTRAN_MO
   
   *MTRAN_YR = MTRAN_YR + 100
   STORE STR(MTRAN_YR,4) TO MTRAN_YR
   
   DO CASE
   CASE MTRAN_MO = '01'
      STORE 'JANUARY' TO MMONTH
   CASE MTRAN_MO = '02'
      STORE 'FEBRUARY' TO MMONTH
   CASE MTRAN_MO = '03'
      STORE 'MARCH' TO MMONTH
   CASE MTRAN_MO = '04'
      STORE 'APRIL' TO MMONTH
   CASE MTRAN_MO = '05'
      STORE 'MAY' TO MMONTH
   CASE MTRAN_MO = '06'
      STORE 'JUNE' TO MMONTH
   CASE MTRAN_MO = '07'
      STORE 'JULY' TO MMONTH
   CASE MTRAN_MO = '08'
      STORE 'AUGUST' TO MMONTH
   CASE MTRAN_MO = '09'
      STORE 'SEPTEMBER' TO MMONTH
   CASE MTRAN_MO = '10'
      STORE 'OCTOBER' TO MMONTH
   CASE MTRAN_MO = '11'
      STORE 'NOVEMBER' TO MMONTH
   CASE MTRAN_MO = '12'
      STORE 'DECEMBER' TO MMONTH
   OTHERWISE
      STORE ' ' TO MMONTH
   ENDCASE
   
   MSTORAGE = 0
   SEEK MTRAN_YR + MTRAN_MO
   DO WHILE .NOT. EOF() .AND. TRAN_MO = MTRAN_MO .AND. TRAN_YR = MTRAN_YR       
      
      IF MINC_BOX = 'N' .AND. BBUYCODE = '  12'
         SKIP
         LOOP
      ENDIF
      *** TEMP - SKIP AROUND ARTIC CASCADE/ BILL TO COREMARK
      **IF BUY_CODE = '  54'
      **   SKIP
      **   LOOP
      **ENDIF
      **** CALCULATE THE NET TOTALS HERE
      DO CASE
      CASE MCOMPANY = 'DIVISION 15'
         IF BBUYCODE <> 'INVN'
            IF PO_SUFFIX <> '8' .AND. PO_SUFFIX <> '9'
               IF INV_COR = 'I'
                  MTOT_SALES = MTOT_SALES + TOT_SELL+CUS_PALL
               ELSE
                  MCOR_SALES = MCOR_SALES + TOT_SELL+CUS_PALL
               ENDIF
            ENDIF
         ENDIF
      OTHERWISE
         ****
         IF BBUYCODE <> 'INVN'        
            MTOT_SALES = MTOT_SALES + TOT_SELL+CUS_PALL
         ENDIF
      ENDCASE
      
      
      IF MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
         MAM_FLG = .T.
      ELSE
         MAM_FLG = .F.
      ENDIF
      IF MAM_FLG .AND. INV_COR = 'C' .AND. TRAN_DATE = MDATE
         MCORR = MCORR + TOT_NET
      ENDIF
      *********
      IF MCOMPANY = 'DIVISION 15' .AND. INV_COR <> 'I'
         MCOR_NET = MCOR_NET + TOT_NET
      ELSE
         MTOT_NET = MTOT_NET + TOT_NET
      ENDIF
      *********
      IF MCOMPANY = 'DIVISION 15' .AND. INV_COR <> 'I'
         MCOR_NET = MCOR_NET + SALE2_NET + SALE3_NET
      ELSE
         MTOT_NET = MTOT_NET + SALE2_NET + SALE3_NET
      ENDIF
      *********
      ****MTOT_NET = MTOT_NET + TOT_NET + SALE2_NET + SALE3_NET
      SKIP
   ENDDO
ENDIF

IF MLINE +6 > MPAGE_LEN
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
   
   DO CASE
   CASE MI_OPT = 'INVEN'
      @ 2,22 SAY 'DAILY INVENTORY SUMMARY FOR ' + DTOC(MDATE)
   CASE MI_OPT = 'SALES'
      @ 2,22 SAY 'DAILY SALES DETAIL SUMMARY FOR ' + DTOC(MDATE)
   OTHERWISE
      @ 2,22 SAY 'DAILY ORDER DETAIL SUMMARY FOR ' + DTOC(MDATE)
   ENDCASE
   @ 2,70 SAY DTOC(DATE())
   @ 4,0 SAY 'INV NBR'
   @ 4,10 SAY 'SUPPLIER'
   @ 4,22 SAY 'TOT PURCH'
   @ 4,33 SAY 'CUSTOMER'
   @ 4,46 SAY 'TOT SELL'
   @ 4,56 SAY 'BROKR'
   @ 4,65 SAY 'COMM'
   @ 4,73 SAY 'TOT NET'
   IF MDISP_PRT = 'P'
      @ 4,0 SAY REPLICATE ('_',80)
   ELSE
      @ 5,0 SAY REPLICATE ('-',79)
   ENDIF
   MLINE = 6
ENDIF

IF MDISP_PRT = 'P'

   @ MLINE,0 SAY 'DAILY TOTALS:'
   @ MLINE,19 SAY MPURCH PICTURE '9,999,999.99'
   @ MLINE,42 SAY MSELL PICTURE '9,999,999.99'
   @ MLINE,60 SAY MCOMM PICTURE '99,999.99'
   @ MLINE,70 SAY MTOTAL PICTURE '999,999.99'
   IF MCORR <> 0
      MLINE = MLINE + 2
      @ MLINE,0 SAY 'DAILY CORRECTIONS'
      @ MLINE,70 SAY MCORR PICTURE '999,999.99'
   ENDIF
   
   MLINE = MLINE + 3
   @ MLINE,1 SAY 'MONTHLY NET TOTALS FOR ' + MMONTH
   MLINE = MLINE + 1
   IF MCOMPANY = 'DIVISION 01'
      @ MLINE,1 SAY 'NET - ' + TRIM(MCOMPANY) + '(does not include BRYAN FOODS)'
   ELSE
      **   @ MLINE,1 SAY 'NET - MIDWEST FOOD & POULTRY (net has substracted out est. storage)'
      @ MLINE,1 SAY 'NET - ' + TRIM(MCOMPANY)
   ENDIF
   **@ MLINE,70 SAY MTOT_NET + MSOUTHCAL - MSTORAGE PICTURE '999,999.99'
   @ MLINE,70 SAY MTOT_NET + MSOUTHCAL  PICTURE '999,999.99'
   IF MSTORAGE <> 0
      MLINE = MLINE + 1
      @ MLINE,1 SAY '(Ken-info only: Estimated going in storage @ .0311 is [no anniversary included]: ' + transform(mstorage, '999999.99') + ' )'
   ENDIF
   MLINE = MLINE + 1
   
   IF MBRYANNET <> 0
      @ MLINE,1 SAY 'NET - BRYAN FOODS'                           
      @ MLINE,70 SAY MBRYANNET PICTURE '999,999.99'
      MLINE = MLINE + 1
   ENDIF
   @ MLINE,1 SAY 'TOTAL SALES DOLLARS: '
   @ MLINE,66 SAY MTOT_SALES PICTURE '999,999,999.99'
   IF MTOT_SALES <> 0
      MLINE = MLINE + 1
      @ MLINE,1 SAY '% NET DOLLARS TO TOTAL SALE DOLLARS: ' 
      MX = ROUND((MTOT_NET/MTOT_SALES) * 100,1)
      @ MLINE,74 SAY MX PICTURE '999.9'
      IF MDISP_PRT = 'P'
         @ MLINE,80 SAY '%'
         IF MSTORAGE <> 0
            MX = ROUND(((MTOT_NET-MSTORAGE)/MTOT_SALES) * 100,1)
            @ MLINE,85 SAY MX PICTURE '999.9'
            @ MLINE,91 SAY '%'
         ENDIF
      ENDIF
   ENDIF
ELSE
   @ MLINE,0 SAY 'DAILY TOTALS:'
   @ MLINE,19 SAY MPURCH PICTURE '9,999,999.99'
   @ MLINE,42 SAY MSELL PICTURE '9,999,999.99'
   @ MLINE,60 SAY MCOMM PICTURE '99,999.99'
   @ MLINE,70 SAY MTOTAL PICTURE '999,999.99'
   MLINE = MLINE + 3
   @ MLINE,0 SAY 'MONTHLY NET TOTALS FOR ' + MMONTH
   MLINE = MLINE + 1
   @ MLINE,1 SAY 'NET - '+ TRIM(MCOMPANY)
   @ MLINE,70 SAY MTOT_NET + MSOUTHCAL PICTURE '999,999.99'
   IF MBRYANNET <> 0
      @ MLINE,1 SAY 'NET - BRYAN FOODS'
      @ MLINE,70 SAY MBRYANNET PICTURE '999,999.99'
   ENDIF
ENDIF

IF VAL(MTRAN_MO) <> 0 .AND. VAL(MTRAN_YR) <> 0
   ********************************************************
   ***** NOW CALCULATE PREVIOUS MONTH'S TOTALS TO PRINT OUT
   ***** 07/26/94
   ********************************************************
   *** BBUYCODE = '  16' = BRYAN FOODS - KEEP THEM SEPERATE
   MBRYANNET = 0
   *** SALESMAN OR SAL_CODE2 = '85' = SOUTHERN CALIFORNIA MEAT & PROVISIONS
   ***                                KEEP THEM SEPERATE TOO
   MSOUTHCAL = 0
   MTOT_SALES = 0
   MTOT_NET = 0 
   MCOR_NET = 0
   MCOR_SALES = 0
   MSTORAGE = 0
   MPREV_MO = VAL(MTRAN_MO) - 1
   IF MPREV_MO < 1
      MPREV_MO = 12
      MPREV_YR = VAL(MTRAN_YR) -1
   ELSE 
      MPREV_YR = VAL(MTRAN_YR)
   ENDIF
   
   MTRAN_MO = MPREV_MO
   MTRAN_YR = MPREV_YR
   
   IF MTRAN_MO <> 0 .AND. MTRAN_YR <> 0
      SELECT A
      DO FOX_USE WITH "DAILYJRN INDEX JRN_MO", .F.
      
      MTRAN_MO = MTRAN_MO + 100
      STORE SUBSTR(STR(MTRAN_MO,3),2) TO MTRAN_MO
      
      *MTRAN_YR = MTRAN_YR + 100
      STORE STR(MTRAN_YR,4) TO MTRAN_YR
      
      DO CASE
      CASE MTRAN_MO = '01'
         STORE 'JANUARY' TO MMONTH
      CASE MTRAN_MO = '02'
         STORE 'FEBRUARY' TO MMONTH
      CASE MTRAN_MO = '03'
         STORE 'MARCH' TO MMONTH
      CASE MTRAN_MO = '04'
         STORE 'APRIL' TO MMONTH
      CASE MTRAN_MO = '05'
         STORE 'MAY' TO MMONTH
      CASE MTRAN_MO = '06'
         STORE 'JUNE' TO MMONTH
      CASE MTRAN_MO = '07'
         STORE 'JULY' TO MMONTH
      CASE MTRAN_MO = '08'
         STORE 'AUGUST' TO MMONTH
      CASE MTRAN_MO = '09'
         STORE 'SEPTEMBER' TO MMONTH
      CASE MTRAN_MO = '10'
         STORE 'OCTOBER' TO MMONTH
      CASE MTRAN_MO = '11'
         STORE 'NOVEMBER' TO MMONTH
      CASE MTRAN_MO = '12'
         STORE 'DECEMBER' TO MMONTH
      OTHERWISE
         STORE ' ' TO MMONTH
      ENDCASE
      
      SEEK MTRAN_YR + MTRAN_MO
      
      DO WHILE .NOT. EOF() .AND. TRAN_MO = MTRAN_MO .AND. TRAN_YR = MTRAN_YR       
         IF TRAN_DATE > MDATE -30
            SKIP
            LOOP
         ENDIF
         IF MINC_BOX = 'N' .AND. BBUYCODE = '  12'
            SKIP
            LOOP
         ENDIF
         *** TEMP - SKIP AROUND ARTIC CASCADE / BILL TO COREMARK
         *IF BUY_CODE = '  54'
         *   SKIP
         *   LOOP
         *ENDIF
         
         **** CALCULATE THE NET TOTALS HERE
         DO CASE
         CASE MCOMPANY = 'DIVISION 15'
            IF BBUYCODE <> 'INVN'
               IF PO_SUFFIX <> '8' .AND. PO_SUFFIX <> '9'
                  IF INV_COR = 'I'
                     MTOT_SALES = MTOT_SALES + TOT_SELL+CUS_PALL
                  ELSE
                     MCOR_SALES = MCOR_SALES + TOT_SELL+CUS_PALL
                  ENDIF
               ENDIF
            ENDIF
            
         OTHERWISE
            ****
            IF BBUYCODE <> 'INVN'
               MTOT_SALES = MTOT_SALES + TOT_SELL+CUS_PALL
            ENDIF
         ENDCASE
         *********
         IF MCOMPANY = 'DIVISION 15' .AND. INV_COR <> 'I'
            MCOR_NET = MCOR_NET + TOT_NET
         ELSE
            MTOT_NET = MTOT_NET + TOT_NET
         ENDIF
         *********
         IF MCOMPANY = 'DIVISION 15' .AND. INV_COR <> 'I'
            MCOR_NET = MCOR_NET + SALE2_NET + SALE3_NET
         ELSE
            MTOT_NET = MTOT_NET + SALE2_NET + SALE3_NET
         ENDIF
         *********
         ****MTOT_NET = MTOT_NET + TOT_NET + SALE2_NET + SALE3_NET
         SKIP
      ENDDO
   ENDIF
   IF MLINE +6 > MPAGE_LEN
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
      DO CASE
      CASE MI_OPT = 'INVEN'
         @ 2,22 SAY 'DAILY INVENTORY SUMMARY FOR ' + DTOC(MDATE)
      CASE MI_OPT = 'SALES'
         @ 2,22 SAY 'DAILY SALES DETAIL SUMMARY FOR ' + DTOC(MDATE)
      OTHERWISE
         @ 2,22 SAY 'DAILY ORDER DETAIL SUMMARY FOR ' + DTOC(MDATE)
      ENDCASE
      @ 2,70 SAY DTOC(DATE())
      @ 4,0 SAY 'INV NBR'
      @ 4,10 SAY 'SUPPLIER'
      @ 4,22 SAY 'TOT PURCH'
      @ 4,33 SAY 'CUSTOMER'
      @ 4,46 SAY 'TOT SELL'
      @ 4,56 SAY 'BROKR'
      @ 4,65 SAY 'COMM'
      @ 4,73 SAY 'TOT NET'
      IF MDISP_PRT = 'P'
         @ 4,0 SAY REPLICATE ('_',80)
      ELSE
         @ 5,0 SAY REPLICATE ('-',79)
      ENDIF
      MLINE = 6
   ENDIF
   
   IF MDISP_PRT = 'P'
      MLINE = MLINE + 3
      @ MLINE,1 SAY 'MONTHLY NET TOTALS FOR ' + MMONTH + ' UP TO/INCLUDING ' + DTOC(MDATE-30)
      MLINE = MLINE + 1
      
      IF MCOMPANY = 'DIVISION 01'
         @ MLINE,1 SAY 'NET - ' + TRIM(MCOMPANY) + ' (does not include BRYAN FOODS)'
      ELSE
         **@ MLINE,1 SAY 'NET - MIDWEST FOOD & POULTRY (net has substracted out est. storage)'
         @ MLINE,1 SAY 'NET - ' + TRIM(MCOMPANY)
      ENDIF
      @ MLINE,70 SAY MTOT_NET + MSOUTHCAL - MSTORAGE PICTURE '999,999.99'
      IF MSTORAGE <> 0
         MLINE = MLINE + 1
         @ MLINE,1 SAY '(Ken-info only: Estimated going in storage @ .0311 is [no anniversary included]: ' + transform(mstorage, '999999.99') + ' )'
      ENDIF
      MLINE = MLINE + 1
      @ MLINE,1 SAY 'TOTAL SALES DOLLARS: '
      @ MLINE,66 SAY MTOT_SALES PICTURE '999,999,999.99'
      IF MTOT_SALES <> 0
         MLINE = MLINE + 1
         @ MLINE,1 SAY '% NET DOLLARS TO TOTAL SALE DOLLARS: ' 
         MX = ROUND((MTOT_NET/MTOT_SALES) * 100,1)
         @ MLINE,74 SAY MX PICTURE '999.9'
         IF MDISP_PRT = 'P'
            @ MLINE,80 SAY '%'
            IF MSTORAGE <> 0
               MX = ROUND(((MTOT_NET-MSTORAGE)/MTOT_SALES) * 100,1)
               @ MLINE,85 SAY MX PICTURE '999.9'
               @ MLINE,91 SAY '%'
            ENDIF
         ENDIF
      ENDIF
   ENDIF
ENDIF

IF MCOMPANY = 'MIDWEST FOOD -DIV 11' .OR. MCOMPANY = 'AMERICHICKEN, INC'
   
   SELECT A
   DO FOX_USE WITH "INVEN", .F.
   SET FILTER TO SOLD_FLG = ' '
   GOTO TOP
   COPY TO INVNTMP5
   
   SELECT B
   DO FOX_USE WITH "INVNTMP5", .T.
   INDEX ON FREEZ_LOC+PROD_DESC +SUP_PREFX TO INVNTMP5
   
   DO FOX_USE WITH "INVNTMP5 INDEX INVNTMP5", .F.
   
   STORE 0 TO MGRAND_TOT
   
   GOTO TOP
   DO WHILE .NOT. EOF()
      
      IF SUBSTR(PACKED,1,1) = 'B'
         MLBS_LEFT = ROUND(CASE_LEFT * BOX_SZ,2)
         IF SUBSTR(PACKED,1,1) = 'B' .OR. PRI_LB >= 10 .OR. LOT_NBR = 'H0 '
            MVAL_LEFT = ROUND(CASE_LEFT * PRI_LB,2)
         ELSE
            MLBS_LEFT = ROUND(CASE_LEFT * BOX_SZ,2)
            MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
         ENDIF
         
      ELSE
         IF SUBSTR(PACKED,1,1) = 'B' .OR. PRI_LB >= 10 .OR. LOT_NBR = 'H0 '
            MVAL_LEFT = ROUND(CASE_LEFT * PRI_LB,2)
         ELSE
            IF PACKED = 'CWT'
               MLBS_LEFT = LBS_LEFT
               MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
            ELSE
               MLBS_LEFT = ROUND(CASE_LEFT * BOX_SZ,2)
               MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
            ENDIF
         ENDIF
      ENDIF
      
      MGRAND_TOT = MGRAND_TOT + MVAL_LEFT
      SKIP
   ENDDO
   
   MLINE = MLINE + 2
   @ MLINE,1 SAY 'CURRENT INVENTORY VALUE:'
   @ MLINE,66 SAY MGRAND_TOT PICTURE '999,999,999.99'
   SELECT A
   USE
   SELECT B
   USE
   
ENDIF


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
* EOF: DAILYSUM.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/8/15 at 2:02 PM.
