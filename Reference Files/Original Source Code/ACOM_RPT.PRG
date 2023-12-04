*  FILE NAME: ACOM_RPT.PRG
**** DO ALL THE PRINT ROUTINE STUFF

MTITLE = ' - PRINT REPORT OF COMMISSIONS TO BE OR ALREADY PAID'
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
STORE '30' TO MFED_CODE
STORE SPACE(32) TO MNAME
STORE SPACE(1) TO MSALE_SEL, MTHIRD_SEL, MSEL_TYPE
STORE SPACE(2) TO MSEL_CODE
STORE 'N' TO MYES_NO
STORE 2 TO MACTION      
DO WHILE MACTION = 2      
   @ 10,5 SAY 'THIRD PARTY COMMISSIONS PAYEE NAME: '
   @ 10,29 GET MNAME PICTURE '@!'
   @ 11,5 SAY " (LEAVE BLANK IF REPORT DESIRED FOR ALL COMMISSIONS)"
   @ 16,5 SAY 'Is This Report Before Check Print (Y/N)? ' GET MYES_NO PICTURE '@!'
   STORE 1 TO MACTION
   @ 23,00 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Continue      2.  Edit      3. Cancel Report'
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   IF MACTION = 1 .AND. MNAME <> SPACE(32)
      STORE 'T' TO MSEL_TYPE
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
      SEEK TRIM(MNAME)
      IF .NOT. EOF()
         STORE RECNO() TO MFST_REC
         SKIP
         STORE TRIM(MNAME) TO SRCH_ARG
         IF NAME = SRCH_ARG    
            MNAME_FD = .F.
            DO MULTCOM
            IF MNAME_FD
               STORE NAME TO MNAME
               STORE COM_CODE TO MSEL_CODE
               MACTION = 1
            ELSE
               MACTION = 3
               LOOP
            ENDIF
         ELSE
            GOTO MFST_REC
            STORE NAME TO MNAME
            STORE COM_CODE TO MSEL_CODE
         ENDIF
      ELSE
         @ 24,0 CLEAR
         mwait = ' '
         @ 24,1 SAY 'THIRD PARTY NAME NOT ON FILE - PRESS ANY KEY TO REENTER' GET MWAIT
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

STORE CTOD(' ') TO MDATE
IF MYES_NO = 'N'
   @ 18,23 SAY 'Enter Check Paid Date: '                         
   @ 18,46 GET MDATE
   READ
   STORE .F. TO MBEFORE
ELSE
   STORE .T. TO MBEFORE
ENDIF

MPRT_ACT = 'C'
DO PRT_SET
IF MPRT_ACT <> 'C'
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

*** PRINT IN 12 CPI
?? chr(27) + '&k4S'

*** LETTER GOTHIC AND BOLDED PRINT
?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'

*** LETTER SIZE PAPER
?? CHR(27) + '&l2A'

*** PORTRAIT MODE
?? CHR(27) + '&l0O'

MPAGE_LEN = 54
MLINE = 99
MPAGE_NO = 0


SELECT A
DO FOX_USE WITH "TEMPINV", .T.
DELETE ALL
PACK

SELECT C
DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
SELECT D 
DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
SELECT E
DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
SELECT B 
DO FOX_USE WITH "&MMASTDBF.COMTHD INDEX &MMASTDBF.COMTPD", .F.
IF MBEFORE
   MPAID = ' '
ELSE
   MPAID = 'Y'
ENDIF

SEEK MPAID
DO WHILE .NOT. EOF() .AND. COM_PD = MPAID
   
   IF MBEFORE
      IF APRVD_FLG = ' '
         SKIP
         LOOP
      ENDIF
   ELSE
      IF MDATE <> PAID_DATE
         SKIP
         LOOP
      ENDIF
   ENDIF
   
   IF MSEL_CODE <> SPACE(2)
      IF MSEL_CODE <> LED_CODE 
         SKIP
         LOOP
      ENDIF
   ENDIF
   
   STORE LED_CODE TO MCOM_CODE
   MTOTAL = 0
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
   SEEK MCOM_CODE  
   IF .NOT. EOF()
      STORE NAME TO MNAME, MLED_NAME
      STORE INV_SEL TO MINV_SEL
   ELSE
      STORE 'THIRD PARTY NOT ON FILE' TO MNAME, MLED_NAME
      STORE 'N' TO MINV_SEL 
   ENDIF
   *** USE THIS FOR A REPORT FOR  ALL - NOT JUST FEDERATED
   
   SELECT F
   USE TEMPPROD EXCLUSIVE
   DELETE ALL
   PACK
   INDEX ON CUST_NAME + SALESMAN + PO_NBR + PO_SUFFIX TO TEMPPROD
   DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .F.
   DO FILELOCK
   
   MPAGE_NO = 0
   
   SELECT B
   DO WHILE .NOT. EOF() .AND. COM_PD = MPAID .AND. LED_CODE = MCOM_CODE
      
      IF MBEFORE
         IF APRVD_FLG = ' '
            SKIP
            LOOP
         ENDIF
      ELSE
         IF MDATE <> PAID_DATE
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      IF MSEL_CODE <> SPACE(2)
         IF MSEL_CODE <> LED_CODE 
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      IF MLINE > MPAGE_LEN
         IF MLINE <> 99
            EJECT
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 2,3 SAY 'PAGE ' + STR(MPAGE_NO,2) 
         @ 2,32 SAY MCOMPANY
         @ 2,74 SAY DATE()
         @ 3,32 SAY 'COMMISSIONS REPORT'
         @ 4,32 SAY MLED_NAME
         @ 6,14 SAY 'SHIP DATE'
         @ 6,27 SAY 'PO NUMBER'
         @ 6,39 SAY 'CUST PO NBR'
         @ 6,57 SAY 'INVOICE NBR'
         @ 6,76 SAY 'AMOUNT'
         @ 6,14 SAY REPLICATE('_',68)
         MLINE = 8
      ENDIF
      STORE SPACE(5) TO MBROK_NAME
      STORE CTOD(' ') TO MSHIP_DATE
      SELECT C
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      
      SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
      IF .NOT. EOF()
         STORE BBUYCODE TO MBBUYCODE
         STORE BUY_CODE TO MBUY_CODE
         STORE BROK_NAME TO MBROK_NAME
         STORE SHIP_DATE TO MSHIP_DATE
         STORE BUYER_PO TO MBUYER_PO
         IF MBBUYCODE = 'NONE'
            STORE 'NONE' TO MBBUYNAME
         ELSE
            SELECT D
            SEEK MBBUYCODE
            IF .NOT. EOF()
               STORE NAME TO MBBUYNAME
            ELSE
               STORE 'SOLD TO NOT ON FILE' TO MBBUYNAME
            ENDIF
         ENDIF
         
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         SEEK MBUY_CODE
         IF .NOT. EOF()
            STORE NAME TO MBUY_NAME
         ELSE
            STORE 'SHIP TO NOT ON FILE' TO MBUY_NAME
         ENDIF
         
         SELECT C
         **** FEDERATED FOODS -DO THIS SPECIAL PRODUCT FILE/REPORT -TEMPPROD
         **** ALSO, ONLY DO ON INVOICE
         IF B->COR_FLG = 'I'
            MSEQ = 0
            DO CASE
            CASE B->LED_CODE = C->COM_CODE
               MSEQ = 1
            CASE B->LED_CODE = C->COM_CODE2
               MSEQ = 2
            CASE B->LED_CODE = C->COM_CODE3
               MSEQ = 3
            ENDCASE
            
            SELECT E
            SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
            DO WHILE .NOT. EOF() .AND. B->SALESMAN = SALESMAN .AND. B->PO_NBR = PO_NBR .AND. B->PO_SUFFIX = PO_SUFFIX
               MCOM_CENT = 0
               DO CASE
               CASE MSEQ = 1
                  STORE COM1_CENT TO MCOM_CENT
               CASE MSEQ = 2
                  STORE COM2_CENT TO MCOM_CENT
               CASE MSEQ = 3
                  STORE COM3_CENT TO MCOM_CENT
               ENDCASE
               
               IF MCOM_CENT = 0
                  SKIP
                  LOOP
               ENDIF
               
               SELECT F
               APPEND BLANK
               REPLACE CUST_NAME WITH MBBUYNAME
               REPLACE REGION    WITH MBUY_NAME
               REPLACE BUYER_PO  WITH MBUYER_PO
               REPLACE SHIP_DATE WITH C->SHIP_DATE
               REPLACE BUYER_PO  WITH MBUYER_PO
               REPLACE INV_NBR   WITH C->INV_NBR
               REPLACE SALESMAN  WITH E->SALESMAN
               REPLACE PO_NBR    WITH E->PO_NBR
               REPLACE PO_SUFFIX WITH E->PO_SUFFIX
               REPLACE PROD_DESC WITH E->PROD_DESC
               REPLACE TOT_SELL  WITH E->TOT_SELL
               REPLACE LBS_SOLD  WITH E->LBS
               
               REPLACE INV_PRI WITH MCOM_CENT
               REPLACE TOT_COMM WITH ROUND(MCOM_CENT * E->LBS,2)
               SELECT E
               SKIP
            ENDDO
            
         ENDIF
      ELSE
         STORE SPACE(32) TO MBBUYNAME, MBUY_NAME
         MSHIP_DATE = CTOD('')
         STORE SPACE(15) TO MBUYER_PO
      ENDIF
      SELECT B
      @ MLINE,14 SAY MSHIP_DATE
      @ MLINE,27 SAY SALESMAN
      IF SALESMAN <> SPACE(2)
         @ MLINE,29 SAY '-'
      ENDIF
      
      @ MLINE,30 SAY PO_NBR
      IF PO_SUFFIX <> ' '
         @ MLINE,34 SAY '-'
         @ MLINE,35 SAY PO_SUFFIX
      ENDIF
      @ MLINE,39 SAY MBUYER_PO
      @ MLINE,60 SAY INV_NBR
      
      @ MLINE,72 SAY AMOUNT PICTURE '999,999.99'
      IF COR_FLG = 'I' 
         @ MLINE,86 SAY 'INVOICE'
      ELSE
         @ MLINE,86 SAY 'CORRECTION'
      ENDIF
      
      MTOTAL = MTOTAL + AMOUNT
      MLINE = MLINE + 1
      
      SELECT B
      SKIP
   ENDDO
   MLINE = MLINE + 1
   @ MLINE,3 SAY 'TOTAL: '
   @ MLINE,70 SAY MTOTAL PICTURE '9,999,999.99'
   @ MLINE+1,1 SAY ' '
   MLINE = 70
   MPAGE_NO = 0
   
   *** ONLY PRINT ORDER REPORT FOR ALL THIRD PARTY - NOT COPY OF ORDERS
   
   SELECT F
   GOTO TOP
   
   DO WHILE .NOT. EOF()
      
      STORE CUST_NAME TO MNAME
      MFIRST_CUS = .T.
      
      IF MLINE > MPAGE_LEN
         IF MLINE <> 99
            EJECT
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 1,25 SAY MCOMPANY
         @ 1,1 SAY 'Page'
         @ 1,06 say mpage_no picture '99'
         @ 1,68 SAY DTOC(DATE())
         @ 2,25 SAY 'COMMISSION PO SUMMARY FOR ' + MLED_NAME
         MLINE = 4
         MLINE = MLINE + 2
         @ MLINE,1 SAY 'PO NBR    INV NBR  SHIP DATE   CUST PO       PROD     QTY  PRI/QTY   COMM AMT   TOT SELL'
         **             XX-XXXX-X   XXXXX  XX/XX/XXXX  123456789012  XXXX  XXXXXX  XX.XXXX   XXXXX.XX   XXXXX.XX
         ***            123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         ***                    10        20        30        40        50        60        70        80         
         @ MLINE,01 SAY REPLICATE('_',88)
         MLINE = MLINE + 2
         MFIRST_PO = .T.
      ENDIF
      
      IF MFIRST_CUS
         @ MLINE,1 SAY CUST_NAME
         IF CUST_NAME = 'GROCERY SUPPLY'
            @ MLINE,46 SAY REGION
         ENDIF
         MLINE = MLINE + 1
         MFIRST_CUS = .F.
      ENDIF
      
      DO WHILE .NOT. EOF() .AND. CUST_NAME = MNAME
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         STORE 0 TO MTOT_COMM, MTOT_SELL, MTOT_QTY
         
         MFIRST_PO = .T.
         
         DO WHILE .NOT. EOF() .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
            
            IF TOT_COMM = 0
               SKIP
               LOOP
            ENDIF
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  EJECT
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 1,25 SAY MCOMPANY
               @ 1,1 SAY 'Page'
               @ 1,06 say mpage_no picture '99'
               @ 1,68 SAY DTOC(DATE())
               @ 2,25 SAY 'COMMISSION PO SUMMARY FOR ' + MLED_NAME
               MLINE = 3
               MLINE = MLINE + 2
               
               @ MLINE,1 SAY 'PO NBR    INV NBR  SHIP DATE   CUST PO     PROD       QTY  PRI/QTY   COMM AMT   TOT SELL'
               **             XX-XXXX-X   XXXXX  XX/XX/XXXX  123456789012  XXXX  XXXXXX  XX.XXXX   XXXXX.XX   XXXXX.XX
               ***            123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
               ***                    10        20        30        40        50        60        70        80         
               @ MLINE,01 SAY REPLICATE('_',88)
               MLINE = MLINE + 2
               @ MLINE,1 SAY TRIM(CUST_NAME)
               IF CUST_NAME = 'GROCERY SUPPLY'
                  @ MLINE,46 SAY REGION
               ENDIF
               MLINE = MLINE + 1
               MFIRST_PO = .T.
            ENDIF
            IF MFIRST_PO
               @ MLINE,1 SAY SALESMAN + '-'
               @ MLINE,4 SAY PO_NBR
               IF PO_SUFFIX <> ' '
                  @ MLINE,8 SAY '-' + PO_SUFFIX
               ENDIF
               @ MLINE,13 SAY INV_NBR
               @ MLINE,20 SAY SHIP_DATE
               @ MLINE,32 SAY BUYER_PO
               MFIRST_PO = .F.
            ENDIF
            @ MLINE,44 SAY SUBSTR(PROD_DESC,1,6)
            STORE INV_PRI TO MINV_PRI
            STORE PROD_DESC TO MPROD_DESC
            STORE 0 TO MPRD_COMM, MPRD_SELL, MPRD_QTY
            DO WHILE .NOT. EOF() .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. PROD_DESC = MPROD_DESC
               IF TOT_COMM = 0
                  SKIP
                  LOOP
               ENDIF
               MPRD_QTY  = MPRD_QTY + LBS_SOLD
               MPRD_COMM = MPRD_COMM + TOT_COMM
               MPRD_SELL = MPRD_SELL + TOT_SELL
               SKIP
            ENDDO
            @ MLINE,52 SAY MPRD_QTY PICTURE '999999'
            @ MLINE,60 SAY MINV_PRI  PICTURE '99.9999'
            @ MLINE,70 SAY MPRD_COMM PICTURE '99999.99'
            @ MLINE,81 SAY MPRD_SELL PICTURE '99999.99'
            MTOT_QTY  = MTOT_QTY + MPRD_QTY
            MTOT_COMM = MTOT_COMM + MPRD_COMM
            MTOT_SELL = MTOT_SELL + MPRD_SELL
            MLINE = MLINE + 1
         ENDDO
         
         MLINE = MLINE - 1
         @ MLINE,51 SAY REPLICATE('_',7)
         @ MLINE,70 SAY REPLICATE('_',8)
         @ MLINE,81 SAY REPLICATE('_',8)
         MLINE = MLINE + 1
         @ MLINE,52 SAY MTOT_QTY PICTURE '999999'
         @ MLINE,70 SAY MTOT_COMM PICTURE '99999.99'
         @ MLINE,81 SAY MTOT_SELL PICTURE '99999.99'
         @ MLINE+1,1 SAY ' '
         MLINE = MLINE + 2
      ENDDO
      
   ENDDO
   SELECT B
   MLINE = 70
   
ENDDO

IF MLINE <> 99
   @ MLINE+1,1 SAY ' '
   EJECT
ENDIF

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON
IF MPRINTER3 <> 'DONOTPRINT'
   RUN &MPRINTIT3
ENDIF
CLOSE DATA
RETURN

*Formatted by: ToolBox Ver. 1.2  on 1/11/16 at 4:53 PM.
