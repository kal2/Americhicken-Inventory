************
* Program.: SPEC14A.PRG
* Author..: GRACE KELLER
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: REPORT SPEC14A
*
* ---SET environment.
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

*** GET THE RIGHT COMMISSION PAYEE
MNAME_FD = .F.
DO COM_SEL1
IF .NOT. MNAME_FD
   RETURN
ELSE
   STORE NAME TO MCOM_NAME
   STORE COM_CODE TO MOPT_CODE
   STORE NAME TO MNAME
   STORE CITY TO MCITY
   STORE STATE TO MSTATE
ENDIF

CLEAR
@ 01,00 SAY MCOMPANY
@ 02,00 SAY MPROGRAM + ' -REPORT SPEC14A -PRODUCT DTLS/TOT FOR BROKER'
@ 02,70 SAY DATE()
@ 3,0 to 24,79

STORE SPACE(4) TO MBBUYCODE, MRSUPCODE, MBUY_CODE, MSUP_CODE
MPAPER = SPACE(6)

MCHOICE = ' '
MYES_NO = SPACE(3)  
@ 10,5 SAY 'Do you want to select a specific Customer (YES/NO)? ' get MYES_NO picture '@!'
READ

IF MYES_NO = SPACE(3)
   MYES_NO = 'NO '
ENDIF

IF MYES_NO <> 'YES' .AND. MYES_NO <> 'NO '
   RETURN   
ENDIF

@ 10,1 SAY SPACE(78)
IF MYES_NO = 'YES'
   MNAME_FD = .F.
   DO BBUYSEL3
   IF .NOT. MNAME_FD
      RETURN  
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
STORE 'S' TO MCUST_PICK
@ 5,2 SAY  'Report Begin Date: '                   
@ 7,2 SAY  '         End Date: '
@ 10,1 SAY 'Optional  Product: '
@ 13,1 SAY 'Print Report by Ship To Customers (S) -or- Bill To Customers (B) '

STORE 2 TO MACTION
DO WHILE MACTION = 2      
   @ 05,21 GET MSTART
   @ 07,21 GET MLAST
   @ 10,21 GET MSEL_PROD PICTURE '@!'
   @ 13,67 get mcust_pick picture '@!' valid(mcust_pick = 'B' .OR. MCUST_PICK = 'S')
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
   RETURN
ENDIF  

MPRT_ACT = 'C'

@ 20,01 CLEAR TO 20,78 
IF MDISP_PRT = 'P'
   DO PRT_SET
   IF MPRT_ACT <> 'C'
      RETURN  
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
   
   *** PRINT IN 12 CPI
   ?? chr(27) + '&k4S'
   
   *** LETTER GOTHIC AND BOLDED PRINT
   ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
   
   *** LETTER SIZE PAPER
   ?? CHR(27) + '&l2A'
   
   *** PORTRAIT MODE
   ?? CHR(27) + '&l0O'
   
ENDIF

SELECT E
DO FOX_USE WITH "TEMPPROD", .T.
DELETE ALL
PACK
INDEX ON PROD_DESC + STR(CTOD('12/31/2099') - SHIP_DATE,10) TO TEMPPROD
DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .T.


SELECT B
DO FOX_USE WITH "PO_DTL INDEX  PO_DTL", .F.

IF MSEL_PROD <> SPACE(4)            
   ***MSEL_PROD = MSEL_PROD + SPACE(6)
   ***SET FILTER TO PROD_DESC = MSEL_PROD
   GOTO TOP
ENDIF

SELECT C 
DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.

SELECT D
DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.

SELECT F
DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.

SELECT A
DO FOX_USE WITH "PO_HEAD INDEX TMP_BUY", .F.

DO WHILE .NOT. EOF()
   IF SHIP_DATE < MSTART .OR. SHIP_DATE > MLAST                          
      SKIP
      LOOP
   ENDIF
   
   IF MOPT_CODE <> COM_CODE .AND. MOPT_CODE <> COM_CODE2 .AND. MOPT_CODE <> COM_CODE3
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
      
      STORE SALESMAN TO MSALESMAN
      STORE PO_NBR TO MPO_NBR
      STORE PO_SUFFIX TO MPO_SUFFIX
      
      IF MCUST_PICK = 'S'
         SELECT F
         SEEK A->BUY_CODE
         
         IF .NOT. EOF()
            MCUST_NAME = NAME
            MCUST_CITY = SUBSTR(CITY,1,12)
            MCUST_ST = STATE
         ELSE
            STORE 'CUST NOT ON FILE' TO MCUST_NAME
            MCUST_CITY = SPACE(12)
            MCUST_ST = '  ' 
         ENDIF
      ENDIF
      
      MPRT_PO = .T.
      
      SELECT B
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      
      DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
         IF LBS <= 0
            SKIP
            LOOP
         ENDIF
         IF SEL_PRICE <= 0
            SKIP
            LOOP
         ENDIF
         
         IF COM1_CENT = 0 .AND. COM2_CENT = 0 .AND. COM3_CENT = 0
            SKIP
            LOOP
         ELSE
            DO CASE
            CASE MOPT_CODE = a->COM_CODE
               MCOMM_LB = COM1_CENT
            CASE MOPT_CODE = a->COM_CODE2
               MCOMM_LB = COM2_CENT 
            CASE MOPT_CODE = a->COM_CODE3
               MCOMM_LB = COM3_CENT
            OTHERWISE
               MCOMM_LB = 0
            ENDCASE
            IF MCOMM_LB = 0
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         SELECT E
         APPEND BLANK
         REPLACE SALESMAN  WITH MSALESMAN
         REPLACE PO_NBR    WITH MPO_NBR
         REPLACE PO_SUFFIX WITH MPO_SUFFIX
         REPLACE BBUYCODE  WITH MSAVE_CODE
         REPLACE NAME WITH MCUST_NAME
         REPLACE SHIP_DATE WITH A->del_reqd
         REPLACE PROD_DESC WITH B->PROD_DESC
         REPLACE LBS       WITH B->LBS
         REPLACE COMM_LB   WITH MCOMM_LB
         REPLACE PACKED    WITH B->PACKED            
         SELECT B
         SKIP
      ENDDO
      SELECT A
      SKIP
   ENDDO
   
ENDDO

SELECT E
USE

DO FOX_USE WITH "TEMPPROD", .T.
INDEX ON NAME + PROD_DESC + STR(CTOD('12/31/2099') - SHIP_DATE,10) TO TEMPPROD
DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .T.

GOTO TOP
STORE 0 TO GQTY, GPURCHASE, GCOST, GSELLING, GNET, GFRT, GCOMM, GBB, GLBS
DO WHILE .NOT. EOF()
   STORE NAME TO MNAME
   MPRT_NAME = .T.
   STORE 0 TO CQTY, CPURCHASE, CCOST, CSELLING, CNET, CFRT, CCOMM, CBB, CLBS
   DO WHILE .NOT. EOF() .AND. NAME = MNAME
      STORE PROD_DESC TO MPROD_DESC
      STORE 0 TO MQTY, MPURCHASE, MCOST, MSELLING, MNET, MFRT, MCOMM, MBB, MLBS
      MPRT_PROD = .T.         
      
      DO WHILE .NOT. EOF() .AND. NAME = MNAME .AND. PROD_DESC = MPROD_DESC
         
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
            @ 1,25 SAY MCOMPANY + ' - Report: Spec14A'
            @ 2,11 SAY 'Page'
            @ 2,16 say MPAGE_NO picture '99'
            @ 2,25 SAY 'TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
            @ 2,75 SAY DTOC(DATE())
            @ 3,25 SAY 'COMMISSION PAYEE: ' + MCOM_NAME 
            @ 3,75 SAY TIME()
            
            IF MSEL_PROD <> SPACE(6)
               @ 4,25 SAY 'Optional Selected Product: ' + MSEL_PROD
               MPRT_Prod   = .F.
            ELSE
               MPRT_Prod   = .T.
            ENDIF
            
            MPRT_NAME   = .T.
            @ 5,10 SAY '       PO NUMBER DELV DATE    QTY         COMMISSION'
            *                 XX-XXXX-X XX/XX/XXXX 99999  XX.XXXX  XXX.XXXX XX.XXXX XX.XXXX  XX.XXXX  XX.XXXX  XX.XXXX
            *          12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
            *                   10        20        30        40        50        60        70        80        90        100       110
            
            @ 5,10 SAY REPLICATE('_',53)
            MLINE = 7
         ENDIF
         
         IF MPRT_NAME
            @ MLINE,11 SAY NAME
            MPRT_NAME = .F.
            MLINE = MLINE  + 1
         ENDIF
         
         IF MPRT_PROD .AND. MSEL_PROD = SPACE(6)
            @ MLINE,15 SAY 'PRODUCT: ' + PROD_DESC
            MPRT_PROD = .F.
            MLINE = MLINE + 1
         ENDIF
         
         STORE SHIP_DATE TO MSHIP_DATE
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         STORE COMM_LB TO MCOMM_LB
         
         MPO_LBS = 0
         DO WHILE .NOT. EOF() .AND. NAME = MNAME .AND. PROD_DESC = MPROD_DESC .AND. SALESMAN+PO_NBR+PO_SUFFIX = MSALESMAN+MPO_NBR+MPO_SUFFIX
            MPO_LBS = MPO_LBS + LBS
            SKIP
         ENDDO
         
         
         **@ MLINE,1  SAY SUBSTR(NAME,1,6)
         IF mSALESMAN <> SPACE(2)
            @ MLINE,18 SAY mSALESMAN + '-'
         ENDIF
         @ MLINE,21 SAY mPO_NBR
         IF mPO_SUFFIX <> ' '
            @ MLINE,25 SAY '-' + mPO_SUFFIX
         ENDIF
         @ MLINE,28 SAY mSHIP_DATE                     
         @ MLINE,39 SAY mpo_LBS PICTURE '99999'
         @ MLINE,56 SAY mCOMM_LB PICTURE '99.9999'
         
         *** ADD IN FOR PRODUCT TOTALS
         MQTY = MQTY + mpo_LBS
         
         *** ADD IN FOR CUSTOMER TOTALS
         CQTY     = CQTY + mpo_LBS
         
         *** ADD IN FOR GRAND TOTALS
         GQTY     = GQTY + mpo_LBS
         MLINE = MLINE + 1
      ENDDO
      @ MLINE,15 SAY 'PRODUCT TOTAL'
      @ MLINE,34 SAY MQTY PICTURE '99,999,999'
      MLINE = MLINE + 2
   ENDDO
   IF MSEL_PROD = SPACE(6)
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
         @ 1,25 SAY MCOMPANY + ' - Report: Spec14A'
         @ 2,11 SAY 'Page'
         @ 2,16 say MPAGE_NO picture '99'
         @ 2,25 SAY 'TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
         @ 2,75 SAY DTOC(DATE())
         @ 3,25 SAY 'COMMISSION PAYEE: ' + MCOM_NAME 
         @ 3,75 SAY TIME()
         
         IF MSEL_PROD <> SPACE(6)
            @ 4,25 SAY 'Optional Selected Product: ' + MSEL_PROD
            MPRT_Prod   = .F.
         ELSE
            MPRT_Prod   = .T.
         ENDIF
         
         MPRT_NAME   = .T.
         @ 5,10 SAY '       PO NUMBER DELV DATE    QTY         COMMISSION'
         *                 XX-XXXX-X XX/XX/XXXX 99999  XX.XXXX  XXX.XXXX XX.XXXX XX.XXXX  XX.XXXX  XX.XXXX  XX.XXXX
         *          12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         *                   10        20        30        40        50        60        70        80        90        100       110
         
         @ 5,10 SAY REPLICATE('_',53)
         MLINE = 7
      ENDIF
      @ MLINE,11 SAY 'CUSTOMER TOTAL'
      @ MLINE,34 SAY CQTY PICTURE '99,999,999'
      MLINE = MLINE + 4
   ENDIF
ENDDO

IF MLINE <> 99
   IF MDISP_PRT = 'P'
      IF MSEL_PROD = SPACE(10)
         MLINE = MLINE + 2
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
            @ 1,25 SAY MCOMPANY + ' - Report: Spec14A'
            @ 2,11 SAY 'Page'
            @ 2,16 say MPAGE_NO picture '99'
            @ 2,25 SAY 'TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
            @ 2,75 SAY DTOC(DATE())
            @ 3,25 SAY 'COMMISSION PAYEE: ' + MCOM_NAME 
            @ 3,75 SAY TIME()
            
            IF MSEL_PROD <> SPACE(6)
               @ 4,25 SAY 'Optional Selected Product: ' + MSEL_PROD
               MPRT_Prod   = .F.
            ELSE
               MPRT_Prod   = .T.
            ENDIF
            
            MPRT_NAME   = .T.
            @ 5,10 SAY '       PO NUMBER DELV DATE    QTY         COMMISSION'
            *                 XX-XXXX-X XX/XX/XXXX 99999  XX.XXXX  XXX.XXXX XX.XXXX XX.XXXX  XX.XXXX  XX.XXXX  XX.XXXX
            *          12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
            *                   10        20        30        40        50        60        70        80        90        100       110
            
            @ 5,10 SAY REPLICATE('_',53)
            MLINE = 7
         ENDIF
         @ MLINE,11 SAY 'GRAND TOTALS'
         @ MLINE,34 SAY GQTY PICTURE '99,999,999'
      ENDIF
      MLINE = MLINE + 1
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
      MPRT_SEL = ' '
      @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
      READ
   ENDIF
ELSE
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
ENDIF
CLOSE DATA
MNOT_DONE = .F.


RETURN


*Formatted by: ToolBox Ver. 1.2  on 3/6/20 at 11:10 AM.
