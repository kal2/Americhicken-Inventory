***********
* Program.: PRODDTLS.PRG
* Author..: GRACE KELLER
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MAIN PROGRAM FOR AMERICO BROKER SYSTEM SYSTEM
*
* ---SET environment.
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
CLEAR
@ 01,00 SAY MCOMPANY
@ 02,00 SAY MPROGRAM + ' - PRODUCT DETAILS/TOTALS'
@ 02,70 SAY DATE()
@ 3,0 to 23,79

STORE SPACE(4) TO MBBUYCODE, MRSUPCODE, MBUY_CODE, MSUP_CODE
MPAPER = SPACE(6)
@ 10,5 SAY 'Do you want the wide paper report with purchase/selling dollars'
@ 12,5 say 'printed or the narrow paper report with no dollar activity printed?'
@ 15,5 say 'SELECT REPORT TYPE: (WIDE/NARROW)? ' GET MPAPER PICTURE '@!'
READ
IF MPAPER <> 'WIDE  ' .AND. MPAPER <> 'NARROW'
   RETURN
ENDIF
@ 4,1 CLEAR TO 22,78
STORE ' ' TO MCHOICE1, MCHOICE2, MC1, MC2, MC3, MC4, MC5, MC6
IF MPAPER = 'WIDE'
   @ 5,5 SAY "Select with an 'X' one of the following two formats"
   @ 8,5 SAY 'Format 1:  Print ALL      detail line fields: ' GET MCHOICE1 PICTURE '@!'
   @ 9,5 SAY 'Format 2:  Print SPECIFIC Detail line fields: ' GET MCHOICE2 PICTURE '@!'
   READ
   IF MCHOICE1 = ' ' .AND. MCHOICE2 = ' '
      MCHOICE1 = 'X'
   ENDIF
   IF MCHOICE2 = 'X'
      @ 11,5 SAY "Select with an 'X' of the following which detail items to print" 
      @ 12,5 say '(Can select more than one)'
      @ 14,8 say 'Pounds'
      @ 15,8 say 'Supplier Info (Name,price,total dollars)'
      @ 16,8 say 'Customer Info (Name,price,total dollars)'
      @ 17,8 say 'Freight dollars'
      @ 18,8 say 'Net dollars'
      @ 19,8 say 'Adjustment dollars'
      
      @ 14,5 get MC1 PICTURE '@!' VALID(MC1 = ' ' .OR. MC1 = 'X')
      @ 15,5 get MC2 PICTURE '@!' VALID(MC2 = ' ' .OR. MC2 = 'X')
      @ 16,5 get MC3 PICTURE '@!' VALID(MC3 = ' ' .OR. MC3 = 'X')
      @ 17,5 get MC4 PICTURE '@!' VALID(MC4 = ' ' .OR. MC4 = 'X')
      @ 18,5 get MC5 PICTURE '@!' VALID(MC5 = ' ' .OR. MC5 = 'X')
      @ 19,5 get MC6 PICTURE '@!' VALID(MC6 = ' ' .OR. MC6 = 'X')
      READ
   ENDIF
ENDIF
@ 4,1 CLEAR TO 22,78

MCHOICE = ' '
MYES_NO = SPACE(3)  
@ 10,5 SAY 'Do you want to select a specific Supplier or Customer (YES/NO)? ' get MYES_NO picture '@!'
READ
IF MYES_NO <> 'YES' .AND. MYES_NO <> 'NO '
   RETURN   
ENDIF
@ 10,1 SAY SPACE(78)
IF MYES_NO = 'YES'
   @ 10,5 SAY 'Select Products for: ' 
   STORE ' ' TO MCHOICE
   SET CONFIRM ON
   @ 12,5 SAY 'Remit to Suppliers (S) or Bill to Customers (C) ? ' get mchoice picture '@!'
   READ
   SET CONFIRM OFF
   IF MCHOICE <> 'S' .AND. MCHOICE <> 'C'
      MSELECTION = ' '
      RETURN   
   ENDIF
   IF MCHOICE = 'C'
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
      MNAME_FD = .F.
      DO RSUPSEL3
      IF .NOT. MNAME_FD
         RETURN   
      ENDIF
      STORE RSUPCODE TO MRSUPCODE
      STORE NAME TO MNAME
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 02,00 SAY MPROGRAM + ' - PRODUCT DETAILS/TOTALS'
      @ 02,70 SAY DATE()
      @ 3,0 to 23,79
      MYES_NO = '   '
      @ 12,5 SAY 'Do you want to select a specific Shipped From Supplier (YES/NO)? ' get MYES_NO picture '@!'
      READ
      IF MYES_NO = 'YES'
         MNAME_FD = .F.
         SET PROC TO SUP_PROC
         DO SUP_SEL1
         IF MNAME_FD 
            STORE SUP_CODE TO MSUP_CODE
         ENDIF
         SET PROC TO PO_PROC
      ENDIF
      USE
   ENDIF
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
@ 3,0 TO 23,79
**** GET FIRST AND LAST DATES FOR THIS REPORT
STORE CTOD(' ') TO MSTART, MLAST
STORE '**' TO MOPT_SALES   
STORE 'P' TO MDISP_PRT

STORE space(10) TO MPROD1, MPROD2
STORE SPACE(2) TO MNATURE
MGRADE = ' ' 
MREFRIG = ' '
MPACKAGE = ' '
MSIZE = SPACE(5)
MPACKED = SPACE(4)

STORE 'N' TO MSUM_ONLY
STORE 'Y' TO MSEL_DLLR
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   @ 4,2 say  '           Report Begin Date: '                   
   @ 4,47 SAY  'End Date: '
   @ 6,2 SAY  ' (Optional) Salesperson Code: '
   @ 6,40 SAY " ('**' for all salespersons)"
   @ 8,1 SAY 'The following product fields are optional. Only enter if specifics desired.'
   
   @ 10,1 SAY '         Product Code Range:       thru' 
   @ 11,1 SAY '        Product Nature Code: '
   @ 12,1 SAY '         Product Grade Code: '
   @ 13,1 SAY ' Refrigeration/Storage Code: '
   @ 14,1 SAY ' Packaging Description Code: '
   @ 15,1 SAY '          Product Size Code: '
   @ 16,1 SAY '             Unit Pack Code: '
   @ 18,1 SAY '    Print Totals Only (Y/N): '
   *@ 17,2 SAY '  PRINT DOLLAR AMOUNTS (Y/N):'
   STORE 'PLEASE SELECT REPORT OPTIONS....' TO MGET
   @ 21,16 GET MGET
   CLEAR GETS
   STORE 2 TO MACTION      
   DO WHILE MACTION = 2      
      @ 04,32 GET MSTART
      @ 04,57 GET MLAST
      @ 06,32 GET MOPT_SALES 
      
      @ 10,30 GET MPROD1 PICTURE '@!'
      @ 10,42 GET MPROD2 PICTURE '@!'
      @ 11,30 GET MNATURE PICTURE '@!'
      @ 12,30 GET MGRADE PICTURE '@!'
      
      @ 13,30 GET MREFRIG PICTURE '@!'
      @ 14,30 GET MPACKAGE PICTURE '@!'
      @ 15,30 GET MSIZE PICTURE '@!'
      @ 16,30 GET MPACKED PICTURE '@!'
      
      @ 18,30 GET MSUM_ONLY PICTURE '@!'
      *@ 17,32 GET MSEL_DLLR PICTURE '@!'
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
         
         IF VAL(MPROD1) <> 0          
            IF VAL(MPROD2) = 0        
               MPROD2 = MPROD1            
            ELSE
               IF VAL(MPROD2) < VAL(MPROD1) 
                  @ 23,0 CLEAR
                  mwait = ' '
                  @ 23,1 SAY 'Ending product code is less than beginning product code'
                  @ 24,1 say 'Press Any Key to Reenter ' get mwait
                  READ
                  MACTION = 2
                  @ 23,0 clear
                  LOOP 
               ENDIF
            ENDIF
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
      MPAGE_LEN = 44
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
   
   MTOT_UNDER = 0
   MTOT_DLRS  = 0
   MTOT_LBS   = 0
   MTOT_SELL  = 0
   MFRT       = 0
   MMISC_AMT  = 0
   TSUP_ADJ   = 0
   TCUS_ADJ   = 0
   MTOT_CASE  = 0
   MCOMM      = 0
   MLBS_BOT   = 0
   MLBS_SOLD  = 0
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
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
   ENDIF
   SELECT F
   DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
   SELECT E
   DO FOX_USE WITH "MISC_CHG INDEX MISC_CHG", .F.
   SELECT B 
   DO FOX_USE WITH "PO_DTL INDEX  PO_DTL", .F.
   
   IF VAL(MPROD1) = 0            
      IF MNATURE <> SPACE(2)
         SET FILTER TO FRH_FRZ = MNATURE
         GOTO TOP
      ENDIF
   ELSE
      IF MNATURE = SPACE(2)
         SET FILTER TO VAL(PROD_DESC) >= VAL(MPROD1) .AND. VAL(PROD_DESC) <= VAL(MPROD2)
         GOTO TOP
      ELSE
         SET FILTER TO (VAL(PROD_DESC) >= VAL(MPROD1) .AND. VAL(PROD_DESC) <= VAL(MPROD2)) .AND. FRH_FRZ = MNATURE
         GOTO TOP
      ENDIF
   ENDIF
   
   SELECT C 
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
   SELECT D
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
   
   SELECT A 
   DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP", .F.
   
   SEEK MSTRT_YR + MSTRT_MO
   DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MLAST
      IF SHIP_DATE < MSTART                           
         SKIP
         LOOP
      ENDIF
      IF MOPT_SALES <> '**'     
         IF MOPT_SALES <> SALESMAN
            SKIP
            LOOP
         ENDIF
      ENDIF
      IF MRSUPCODE <> SPACE(4)
         IF MRSUPCODE <> RSUPCODE
            SKIP
            LOOP
         ENDIF
         IF MSUP_CODE <> SPACE(4)
            IF MSUP_CODE <> SUP_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
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
      
      IF MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
         IF BBUYCODE = 'NONE' .OR. BBUYCODE = 'INVN'
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      STORE SALESMAN TO MSALESMAN
      STORE PO_NBR TO MPO_NBR
      STORE PO_SUFFIX TO MPO_SUFFIX
      SELECT C
      SEEK A->RSUPCODE
      IF .NOT. EOF()
         MSUP_NAME= SUBSTR(NAME,1,12)
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
         MCUST_NAME = SUBSTR(NAME,1,12)
         MCUST_CITY = SUBSTR(CITY,1,12)
         MCUST_ST = STATE
      ELSE
         STORE 'CUST NOT ON FILE' TO MCUST_NAME
         MCUST_CITY = SPACE(12)
         MCUST_ST = '  ' 
      ENDIF
      
      MPO_DTL = .F.
      SELECT B
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      
      DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
         IF LBS = 0 
            SKIP
            LOOP
         ENDIF
         IF MCHOICE = 'S' .AND. PUR_PRICE = 0
            SKIP
            LOOP
         ENDIF
         IF MCHOICE = 'C' .AND. SEL_PRICE = 0
            SKIP
            LOOP
         ENDIF
         IF MGRADE <> ' '
            IF MGRADE <> GRADE
               SKIP
               LOOP
            ENDIF
         ENDIF
         IF MREFRIG <> ' '
            IF MREFRIG <> SUBSTR(PACKAGED,1,1)
               SKIP
               LOOP
            ENDIF
         ENDIF
         IF MPACKAGE <> ' '
            IF MPACKAGE <> SUBSTR(PACKAGED,2)
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         IF MSIZE <> SPACE(5)
            IF MSIZE <> SIZE
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         IF MPACKED <> SPACE(4)
            IF MPACKED <> PACKED
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         MPO_DTL = .T.
         IF MLINE > MPAGE_LEN
            IF MLINE = 99 .AND. MDISP_PRT <> 'P'
               CLEAR
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            IF MPAPER = 'WIDE'
               @ 1,59 SAY MCOMPANY
               @ 2,1 SAY 'Page'
               @ 2,06 say mpage_no picture '99'
               @ 2,53 SAY '    PRODUCTS TOTAL FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
               @ 2,130 SAY DTOC(DATE())
               @ 3,130 SAY TIME()
               @ 4,1 SAY 'PO NUMBER'
               IF MCHOICE1 = 'X' .OR. (MCHOICE2 = 'X' .AND. MC1 = 'X')
                  @ 4,12 SAY 'TOTAL LBS'
               ENDIF
               IF MCHOICE1 = 'X' .OR. (MCHOICE2 = 'X' .AND. MC2 = 'X')
                  @ 4,23 SAY 'SUPPLIER'
                  @ 4,33 SAY '    UNDER'
                  @ 4,44 SAY 'TOT UNDER'
                  @ 4,55 SAY 'PURCHASE' 
                  @ 4,66 SAY 'TOT PURCH'    
               ENDIF
               IF MCHOICE1 = 'X' .OR. (MCHOICE2 = 'X' .AND. MC3 = 'X')
                  @ 4,77 SAY 'CUSTOMER'
                  @ 4,88 SAY 'SELLING'
                  @ 4,99 SAY 'TOT SELL'
               ENDIF
               @ 4,109 SAY 'SHIP DT'
               IF MCHOICE1 = 'X' .OR. (MCHOICE2 = 'X' .AND. MC4 = 'X')
                  @ 4,121 SAY 'FREIGHT'   
               ENDIF
               IF MCHOICE1 = 'X' .OR. (MCHOICE2 = 'X' .AND. MC5 = 'X')
                  @ 4,131 SAY 'ITEM NET'
               ENDIF
               @ 4,142 SAY 'PRODUCT'
               @ 4,153 SAY 'NA'   
               IF MCHOICE1 = 'X' .OR. (MCHOICE2 = 'X' .AND. MC6 = 'X')
                  @ 4,156 SAY 'ADJUST'
               ENDIF
               IF MDISP_PRT = 'P'
                  @ 4,01 SAY REPLICATE('_',162)
               ENDIF
            ELSE
               @ 1,35 SAY MCOMPANY
               @ 2,1 SAY 'Page'
               @ 2,06 say mpage_no picture '99'
               @ 2,30 SAY 'PRODUCTS TOTAL FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
               @ 2,80 SAY DTOC(DATE())
               @ 3,80 SAY TIME()
               @ 4,1 SAY 'PO NUMBER  SHIP DT   TOTAL LBS  SUPPLIER          CUSTOMER        FREIGHT  PRODUCT            NA'
               IF MDISP_PRT = 'P'
                  @ 4,01 SAY REPLICATE('_',96)
               ENDIF
            ENDIF
            MLINE = 6
         ENDIF
         IF A->FRT_AMT1 = 0
            MITM_FRT = 0
         ELSE
            MFRT_LB = (A->FRT_AMT1+A->FRT1_ADJ1+A->FRT1_ADJ2+A->FRT_PALL) / A->TOT_LBS
            MITM_FRT = MFRT_LB * LBS
            MFRT = MFRT + MITM_FRT
         ENDIF
         IF A->COMM_AMT <> 0 .OR. A->SALE_COMM  <> 0 .OR. A->SALE2_AMT <> 0 .OR. A->COMM_AMT2 <> 0 .OR. A->COMM_AMT3 <> 0 .OR. A->SALE3_AMT <> 0
            MCOMM_LB = (A->COMM_AMT+A->COMM_AMT2+A->COMM_AMT3+A->SALE_COMM+A->SALE2_AMT+A->SALE3_AMT) / A->TOT_LBS
            MITM_COMM = MCOMM_LB * LBS
            MCOMM = MCOMM + MITM_COMM
         ENDIF
         
         MTOT_LBS = MTOT_LBS + LBS
         **IF A->BBUYCODE <> 'INVN'
         MLBS_SOLD = MLBS_SOLD + LBS
         MTOT_SELL = MTOT_SELL + TOT_SELL
         **ENDIF
         **IF A->RSUPCODE <> 'INVN'
         MLBS_BOT = MLBS_BOT + LBS
         MTOT_DLRS = MTOT_DLRS + TOT_PURCH
         IF TOT_BILL <> 0
            MTOT_UNDER = MTOT_UNDER + TOT_BILL
         ELSE
            MTOT_UNDER = MTOT_UNDER + TOT_PURCH
         ENDIF
         **ENDIF
         
         MTOT_CASE = MTOT_CASE + QTY
         IF MSUM_ONLY = 'N'
            IF MPAPER = 'WIDE'
               IF SALESMAN <> SPACE(2)
                  @ MLINE,1 SAY SALESMAN + '-'
               ENDIF
               @ MLINE,4 SAY PO_NBR
               IF PO_SUFFIX <> SPACE(1)
                  @ MLINE,8 SAY '-' + PO_SUFFIX
               ENDIF
               IF MCHOICE1 = 'X' .OR. (MCHOICE2 = 'X' .AND. MC1 = 'X')
                  @ MLINE,12 SAY LBS PICTURE '999999.99'
               ENDIF
               IF MCHOICE1 = 'X' .OR. (MCHOICE2 = 'X' .AND. MC2 = 'X')
                  @ MLINE,23 SAY SUBSTR(MSUP_NAME,1,10)
                  IF BILL_PRI <> 0
                     @ MLINE,34 SAY BILL_PRI PICTURE '99.9999'
                     @ MLINE,43 SAY TOT_BILL PICTURE '9999999.99'
                  ENDIF
                  @ MLINE,55 SAY PUR_PRICE PICTURE '99.9999'
                  @ MLINE,65 SAY TOT_PURCH PICTURE '9999999.99'
               ENDIF
               
               IF MCHOICE1 = 'X' .OR. (MCHOICE2 = 'X' .AND. MC3 = 'X')
                  @ MLINE,77 SAY SUBSTR(MCUST_NAME,1,10) 
                  @ MLINE,88 SAY SEL_PRICE PICTURE '99.9999'
                  @ MLINE,97 SAY TOT_SELL PICTURE '9999999.99'
               ENDIF
               @ MLINE,108 SAY A->SHIP_DATE
               
               IF MCHOICE1 = 'X' .OR. (MCHOICE2 = 'X' .AND. MC4 = 'X')
                  @ MLINE,119 SAY MITM_FRT PICTURE '999999.99'  
               ENDIF
               
               
               IF MCHOICE1 = 'X' .OR. (MCHOICE2 = 'X' .AND. MC5 = 'X')
                  @ MLINE,130 SAY TOT_SELL - TOT_PURCH - MITM_FRT PICTURE '999999.99'
               ENDIF
               SELECT F
               SEEK 'R' + B->PROD_DESC
               IF EOF()       
                  @ MLINE,141 SAY B->PROD_DESC
               ELSE
                  @ MLINE,141 SAY SUBSTR(DESC,1,10)
               ENDIF
               SELECT B
               @ MLINE,153 SAY FRH_FRZ
               MLINE = MLINE + 1
            ELSE
               IF SALESMAN <> SPACE(2)
                  @ MLINE,1 SAY SALESMAN + '-'
               ENDIF
               @ MLINE,4 SAY PO_NBR
               IF PO_SUFFIX <> SPACE(1)
                  @ MLINE,8 SAY '-' + PO_SUFFIX
               ENDIF
               @ MLINE,12 SAY A->SHIP_DATE
               @ MLINE,22 SAY LBS PICTURE '999999.99'
               @ MLINE,33 SAY MSUP_NAME
               @ MLINE,51 SAY SUBSTR(MCUST_NAME,1,12)
               @ MLINE,65 SAY MITM_FRT PICTURE '999999.99'  
               SELECT F
               SEEK 'R' + B->PROD_DESC
               IF EOF()
                  @ MLINE,81 SAY B->PROD_DESC
               ELSE
                  @ MLINE,76 SAY SUBSTR(DESC,1,17)
               ENDIF
               SELECT B
               @ MLINE,95 SAY FRH_FRZ
               MLINE = MLINE + 1
               @ MLINE,33 SAY TRIM(MSUP_CITY) + ', ' + MSUP_ST
               IF MCUST_CITY <> ' '
                  @ MLINE,51 SAY TRIM(MCUST_CITY) + ', ' + MCUST_ST    
               ENDIF
               MLINE = MLINE + 1
            ENDIF
         ENDIF
         SKIP
      ENDDO
      SELECT A
      IF MPO_DTL .AND. MPAPER = 'WIDE'
         MCUS_ADJ = CUS_AMT1 + CUS_AMT2 + CUS_PALL + WRITEOFF
         MSUP_ADJ = SUP_AMT1 + SUP_AMT2 + SUP_PALL
         TCUS_ADJ = TCUS_ADJ + MCUS_ADJ
         TSUP_ADJ = TSUP_ADJ + MSUP_ADJ
         IF MSUM_ONLY = 'N'
            IF MCUS_ADJ <> 0 .OR. MSUP_ADJ <> 0 
               IF MCHOICE1 = 'X' .OR. (MCHOICE2 = 'X' .AND. MC6 = 'X')
                  @ MLINE-1,155 SAY MCUS_ADJ - MSUP_ADJ PICTURE '@Z 99999.99'
               ENDIF
            ENDIF
         ENDIF
         IF MISC_FLG <> ' '
            SELECT E
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
            IF .NOT. EOF()
               MMISC_AMT = MMISC_AMT + MISCAMT1 +MISCAMT2 + MISCAMT3
            ENDIF
            SELECT A 
         ENDIF
      ENDIF
      SKIP
   ENDDO
   
   IF MLINE = 99 .AND. MDISP_PRT <> 'P'
      CLEAR
   ENDIF
   MPAGE_NO = MPAGE_NO + 1
   IF MPAPER = 'WIDE'
      @ 1,59 SAY MCOMPANY
      @ 2,1 SAY 'Page'
      @ 2,06 say mpage_no picture '99'
      @ 2,53 SAY '    PRODUCTS TOTAL FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
      @ 2,130 SAY DTOC(DATE())
      @ 3,130 SAY TIME()
      MLINE = 6
      
      @ MLINE,1 SAY ' TOTAL LBS   TOT CASES   TOT UNDERBILL $   TOT PURCHASE $   BILL DIFF $      TOT SELL $      FREIGHT $   COMMISSIONS    MISC COST  ADJUSTMENTS       TOTAL NET'
      IF MDISP_PRT = 'P'
         @ MLINE,00 SAY REPLICATE('_',160)
      ENDIF
      MLINE = MLINE + 2
      IF MLBS_BOT = MLBS_SOLD
         @ MLINE,00 SAY MLBS_BOT PICTURE '999,999,999'
      ELSE
         @ MLINE,00 SAY MLBS_BOT PICTURE '999,999,999'
         @ MLINE,15 SAY 'POUNDS BOUGHT'
         MLINE = MLINE + 1
         @ MLINE,00 SAY MLBS_SOLD PICTURE '999,999,999'
         @ MLINE,15 SAY 'POUNDS SOLD'  
         MLINE = MLINE + 2
      ENDIF 
      @ MLINE,12 SAY MTOT_CASE PICTURE '999,999,999'
      @ MLINE,27 SAY MTOT_UNDER PICTURE '999,999,999.99'
      @ MLINE,44 SAY MTOT_DLRS PICTURE '999,999,999.99' 
      @ MLINE,60 SAY MTOT_DLRS - MTOT_UNDER PICTURE '9,999,999.99'
      @ MLINE,74 SAY MTOT_SELL PICTURE '999,999,999.99'
      @ MLINE,90 SAY MFRT * -1 PICTURE '99,999,999.99'
      @ MLINE,104 SAY MCOMM * -1 PICTURE '@Z 99,999,999.99'
      @ MLINE,118 SAY MMISC_AMT * -1 PICTURE '@Z 9,999,999.99'
      MADJ = TCUS_ADJ - TSUP_ADJ
      @ MLINE,131 SAY MADJ PICTURE '@Z 9,999,999.99' 
      @ MLINE,146 SAY MTOT_SELL - MTOT_DLRS  - MFRT - MCOMM - MMISC_AMT + MADJ PICTURE '99,999,999.99'
   ELSE
      MLINE = MLINE + 1
      @ MLINE,03 SAY 'TOTAL POUNDS:'
      @ MLINE,17 SAY MTOT_LBS PICTURE '999,999,999.99'
   ENDIF
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
   CLOSE DATA
ENDDO
RETURN
*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 1:59 PM.
