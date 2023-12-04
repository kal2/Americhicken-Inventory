************
* Program.: SPECIAL9.PRG
* Author..: GRACE KELLER
* Date....: 
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: REPORT SPECIAL9
*
* ---SET environment.
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

CLEAR
@ 01,00 SAY MCOMPANY
@ 02,00 SAY MPROGRAM + ' - PRODUCT DETAILS/TOTALS'
@ 02,70 SAY DATE()
@ 3,0 to 24,79
MSELECT = SPACE(4)
@ 06,5 SAY 'Do you want to print Customers (CUST)'
@ 07,5 SAY '        -or- Commission Payees (COMM): ' GET MSELECT PICTURE '@!'
READ
IF MSELECT <> 'CUST' .AND. MSELECT <> 'COMM'
   RETURN
ENDIF

DO CASE
CASE MSELECT = 'CUST'
   
   STORE SPACE(4) TO MBBUYCODE, MRSUPCODE, MBUY_CODE, MSUP_CODE
   MPAPER = SPACE(6)
   
   MCHOICE = ' '
   MYES_NO = SPACE(3)  
   @ 10,5 SAY 'Do you want to select a specific Customer (YES/NO)? ' get MYES_NO picture '@!'
   READ
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
   MNOT_DONE = .T.
   STORE 0 TO MMIN_PRICE
   DO WHILE MNOT_DONE
      @ 5,2 SAY  'Report Begin Date: '                   
      @ 7,2 SAY  '         End Date: '
      @ 10,1 SAY 'Optional  Product: '
      @ 12,1 SAY 'Optional  Minimum Purchase Price: '
      STORE 2 TO MACTION
      DO WHILE MACTION = 2      
         @ 05,21 GET MSTART
         @ 07,21 GET MLAST
         @ 10,21 GET MSEL_PROD PICTURE '@!'
         
         @ 12,35 GET MMIN_PRICE PICTURE '##.####'
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
      
      SELECT A 
      DO FOX_USE WITH "PO_HEAD INDEX TMP_BUY", .F.
      
      IF MBBUYCODE = space(4) .and. MBUY_CODE = SPACE(4)
      ELSE
         IF MBUY_CODE <> SPACE(4)
            SET FILTER TO BBUYCODE = MBBUYCODE .AND. BUY_CODE = MBUY_CODE
            GOTO TOP
         ELSE
            SET FILTER TO BBUYCODE = MBBUYCODE
            GOTO TOP
         ENDIF
      ENDIF
      
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
            IF MBBUYCODE = SPACE(4)
               IF BBUYCODE = 'NONE' .OR. BBUYCODE = 'INVN'
                  SKIP
                  LOOP
               ENDIF
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
            
            MPRT_PO = .T.
            SELECT B
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            
            DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
               
               IF LBS <= 0
                  SKIP
                  LOOP
               ENDIF
               IF SEL_PRICE = 0
                  SKIP
                  LOOP
               ENDIF
               IF MMIN_PRICE <> 0
                  IF PUR_PRICE < MMIN_PRICE
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               if prod_desc = '1111' .or. prod_desc = '1112' .or. prod_desc = '1113'
                  skip
                  loop
               endif
               if prod_desc = '0300' .or. prod_desc = '1100' .or. prod_desc = '12  '
                  skip
                  loop
               endif
               if prod_desc = '1114' .or. prod_desc = '1115' .or. prod_desc = '1116'
                  skip
                  loop
               endif
               if prod_desc = '1117' .or. prod_desc = '1118' .or. prod_desc = '1119'
                  skip
                  loop
               endif
               if prod_desc = '1120' .or. prod_desc = '1121'
                  skip
                  loop
               endif
               if prod_desc = '8733' .or. prod_desc = '8801'
                  skip
                  loop
               endif
               if date() = ctod('05/23/2005')
                  if prod_desc = '8910' .or. prod_desc = '8730'
                     skip
                     loop
                  endif
               endif
               IF MSEL_PROD <> SPACE(10)
                  IF MSEL_PROD = 'TENDERS'
                     IF PROD_DESC = '8901' .OR. PROD_DESC = '8910' .OR. PROD_DESC = '8989' .OR. PROD_DESC = '8999'
                     ELSE
                        SKIP
                        LOOP
                     ENDIF
                  ELSE
                     IF MSEL_PROD <> PROD_DESC
                        SKIP
                        LOOP
                     ENDIF
                  ENDIF
               ENDIF   
               
               IF A->FRT_AMT1 = 0 .or. a->tot_lbs = 0
                  MITM_FRT = 0
                  MFRT_LB = 0
               ELSE
                  MFRT_LB = (A->FRT_AMT1+A->FRT1_ADJ1+A->FRT1_ADJ2+A->FRT_PALL) / A->TOT_LBS
                  IF SUBSTR(PACKED,1,1) = 'B'
                     MPACKED = VAL(SUBSTR(PACKED,2))
                  ELSE
                     MPACKED = 1
                  ENDIF
                  if lbs= 0
                     mitm_frt = 0
                     mfrt_lb = 0
                  else
                     MITM_FRT = MFRT_LB * (LBS * MPACKED)
                  endif
               ENDIF
               
               IF COM1_CENT <> 0 .OR. COM2_CENT <>0 .OR. COM3_CENT <> 0
                  MCOMM_LB = COM1_CENT + COM2_CENT + COM3_CENT
                  MITM_COMM = MCOMM_LB * LBS
               ELSE
                  MCOMM_LB  = 0
                  MITM_COMM = 0
               ENDIF
               
               MBB_LB = 0
               
               
               SELECT E
               APPEND BLANK
               REPLACE SALESMAN WITH MSALESMAN
               REPLACE PO_NBR   WITH MPO_NBR
               REPLACE PO_SUFFIX WITH MPO_SUFFIX
               REPLACE BBUYCODE WITH MSAVE_CODE
               REPLACE NAME WITH MCUST_NAME
               REPLACE SHIP_DATE WITH A->SHIP_DATE
               IF MSEL_PROD = 'TENDERS'
                  REPLACE PROD_DESC WITH 'TENDERS'
               ELSE
                  REPLACE PROD_DESC WITH B->PROD_DESC
               ENDIF
               REPLACE LBS       WITH B->LBS
               REPLACE PUR_PRICE WITH B->PUR_PRICE
               REPLACE SEL_PRICE WITH B->SEL_PRICE
               REPLACE FRT_LB    WITH MFRT_LB
               REPLACE COMM_LB   WITH MCOMM_LB
               REPLACE BB_LB     WITH MBB_LB
               REPLACE PACKED    WITH B->PACKED            
               SELECT B
               SKIP
            ENDDO
            SELECT A
            SKIP
         ENDDO
      ENDDO      
      
      SELECT E
      GOTO TOP
      STORE 0 TO GQTY, GPURCHASE, GCOST, GSELLING, GNET, GFRT, GCOMM, GBB, GLBS
      DO WHILE .NOT. EOF()
         
         STORE PROD_DESC TO MPROD_DESC
         STORE 0 TO MQTY, MPURCHASE, MCOST, MSELLING, MNET, MFRT, MCOMM, MBB, MLBS
         MPRT_PROD = .T.         
         DO WHILE .NOT. EOF() .AND. PROD_DESC = MPROD_DESC
            
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
               @ 1,25 SAY MCOMPANY + ' - Report: Spec9'
               @ 2,1 SAY 'Page'
               @ 2,06 say MPAGE_NO picture '99'
               @ 2,25 SAY 'PRODUCTS TOTAL FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
               @ 2,80 SAY DTOC(DATE())
               @ 3,80 SAY TIME()
               
               MPRT_Prod   = .T.
               @ 4,1 SAY '                                            PRORATED'
               @ 5,1 SAY 'CUST   PO NUMBER SHIP DATE    QTY PURCHASE    FRT/LB    COMM      BB  ITM CST  SELLING  ITM NET'
               *          XXXXXX XX-XXXX-X XX/XX/XXXX 99999  XX.XXXX  XXX.XXXX XX.XXXX XX.XXXX  XX.XXXX  XX.XXXX  XX.XXXX
               *          12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
               *                   10        20        30        40        50        60        70        80        90        100       110
               
               @ 5,01 SAY REPLICATE('_',95)
               MLINE = 7
            ENDIF
            
            IF MPRT_PROD
               @ MLINE,1 SAY 'PRODUCT: ' + PROD_DESC
               MPRT_PROD = .F.
               MLINE = MLINE + 1
            ENDIF
            
            @ MLINE,1  SAY SUBSTR(NAME,1,6)
            IF SALESMAN <> SPACE(2)
               @ MLINE,8 SAY SALESMAN + '-'
            ENDIF
            @ MLINE,11 SAY PO_NBR
            IF PO_SUFFIX <> ' '
               @ MLINE,15 SAY '-' + PO_SUFFIX
            ENDIF
            @ MLINE,18 SAY SHIP_DATE                     
            @ MLINE,29 SAY LBS PICTURE '99999'
            @ MLINE,36 SAY PUR_PRICE PICTURE '99.9999'
            @ MLINE,45 SAY FRT_LB PICTURE '999.9999'
            @ MLINE,54 SAY COMM_LB PICTURE '99.9999'
            @ MLINE,62 SAY BB_LB PICTURE '99.9999'
            IF SUBSTR(PACKED,1,1) = 'B'
               MFRT_QTY = ROUND(VAL(SUBSTR(PACKED,2)) * FRT_LB,4)
               MCALC_LBS = ROUND(VAL(SUBSTR(PACKED,2)) * LBS,4)
            ELSE
               MFRT_QTY = FRT_LB
               MCALC_LBS = LBS
            ENDIF
            
            MPRO_PRI = PUR_PRICE + MFRT_QTY + COMM_LB + BB_LB
            @ MLINE,71 SAY MPRO_PRI PICTURE '99.9999'
            @ MLINE,80 SAY SEL_PRICE PICTURE '99.9999'
            @ MLINE,89 SAY SEL_PRICE - MPRO_PRI PICTURE '99.9999'
            
            *** ADD IN FOR PRODUCT TOTALS
            MQTY = MQTY + LBS
            MLBS     = MLBS  + MCALC_LBS
            MPURCHASE = MPURCHASE + ROUND(LBS*PUR_PRICE,2)
            MCOST = MCOST + ROUND(LBS*MPRO_PRI,2)
            MSELLING = MSELLING + ROUND(LBS*SEL_PRICE,2)
            MNET     = MNET  + ROUND(LBS*(SEL_PRICE-MPRO_PRI),2)
            MFRT     = MFRT  + ROUND(LBS*MFRT_QTY,2)
            MCOMM    = MCOMM + ROUND(LBS*COMM_LB,2)
            MBB      = MBB   + ROUND(LBS*BB_LB,2)
            
            *** ADD IN FOR GRAND TOTALS
            GQTY     = GQTY + LBS
            GLBS     = GLBS + MCALC_LBS
            
            GPURCHASE = GPURCHASE + ROUND(LBS*PUR_PRICE,2)
            GCOST    = GCOST + ROUND(LBS*MPRO_PRI,2)
            GSELLING = GSELLING + ROUND(LBS*SEL_PRICE,2)
            GNET     = GNET  + ROUND(LBS*(SEL_PRICE-MPRO_PRI),2)
            GFRT     = GFRT  + ROUND(LBS*MFRT_QTY,2)
            GCOMM    = GCOMM + ROUND(LBS*COMM_LB,2)
            GBB      = GBB   + ROUND(LBS*BB_LB,2)
            MLINE = MLINE + 1
            SKIP
         ENDDO
         @ MLINE,1 SAY 'TOTAL/AVG'
         @ MLINE,26 SAY MQTY PICTURE '99999999'
         @ MLINE,36 SAY ROUND(MPURCHASE/MQTY,4) PICTURE '99.9999'
         @ MLINE,45 SAY ROUND(MFRT/MLBS,4) PICTURE '999.9999'
         @ MLINE,54 SAY ROUND(MCOMM/MQTY,4) PICTURE '99.9999'
         @ MLINE,62 SAY ROUND(MBB/MQTY,4) PICTURE '99.9999'
         @ MLINE,71 SAY ROUND(MCOST/MQTY,4)     PICTURE '99.9999'
         @ MLINE,80 SAY ROUND(MSELLING/MQTY,4)  PICTURE '99.9999'
         @ MLINE,89 SAY ROUND(MNET/MQTY,4)      PICTURE '99.9999'
         MLINE = MLINE + 2
      ENDDO
      
      IF MLINE <> 99
         IF MDISP_PRT = 'P'
            IF MSEL_PROD = SPACE(10)
               MLINE = MLINE + 2
               @ MLINE,1 SAY 'GRAND TOTAL/AVG'
               @ MLINE,26 SAY GQTY PICTURE '99999999'
               @ MLINE,36 SAY ROUND(GPURCHASE/GQTY,4) PICTURE '99.9999'
               @ MLINE,45 SAY ROUND(GFRT/GLBS,4) PICTURE '999.9999'
               @ MLINE,54 SAY ROUND(GCOMM/GQTY,4) PICTURE '99.9999'
               @ MLINE,62 SAY ROUND(GBB/GQTY,4) PICTURE '99.9999'
               @ MLINE,71 SAY ROUND(GCOST/GQTY,4)     PICTURE '99.9999'
               @ MLINE,80 SAY ROUND(GSELLING/GQTY,4)  PICTURE '99.9999'
               @ MLINE,89 SAY ROUND(GNET/GQTY,4)      PICTURE '99.9999'
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
      ENDIF
      CLOSE DATA
      MNOT_DONE = .F.
   ENDDO
   
OTHERWISE
   
   STORE SPACE(4) TO MBBUYCODE, MRSUPCODE, MBUY_CODE, MSUP_CODE
   MOPT_CODE = SPACE(2)
   MPAPER = SPACE(6)
   
   
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
   MOPT_CUST = 'N'
   MNOT_DONE = .T.
   DO WHILE MNOT_DONE
      @ 5,2 SAY  'Report Begin Date: '                   
      @ 7,2 SAY  '         End Date: '
      @ 10,1 SAY 'Optional  Product: '
      @ 13,1 SAY 'Select Optional Customer(s) - Y/N: ' 
      
      STORE 2 TO MACTION
      DO WHILE MACTION = 2      
         @ 05,21 GET MSTART
         @ 07,21 GET MLAST
         @ 10,21 GET MSEL_PROD PICTURE '@!'
         @ 13,37 GET MOPT_CUST PICTURE '@!'
         
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
      
      I = 1
      DO WHILE  I <= 99
         MI = SUBSTR(STR(I+100,3),2)
         STORE SPACE(4) TO MCUST&MI
         I = I + 1
      ENDDO
      
      IF MOPT_CUST = 'Y'
         
         **TEMPORARY
         *SELECT D
         *DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         *
         *I = 1
         *DO WHILE .NOT. EOF()
         *   IF NAME <> 'SYSCO FOOD'
         *      SKIP
         *      LOOP
         *   ENDIF
         *   MI = SUBSTR(STR(I+100,3),2)
         *   STORE BBUYCODE TO MCUST&MI
         *   I = I + 1
         *   SKIP
         *ENDDO
         *USE
         
         SAVE SCREEN TO MGRACE
         DO CUST_SEL
         RESTORE SCREEN FROM MGRACE
         
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
      
      SELECT A 
      DO FOX_USE WITH "PO_HEAD", .F.
      
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
         
         IF MOPT_CUST = 'Y'
            MMATCH = .F.
            I= 1
            DO WHILE I <=99 .AND. .NOT. MMATCH
               MI = SUBSTR(STR(I+100,3),2)
               IF BBUYCODE = MCUST&MI
                  MMATCH = .T.
                  LOOP
               ENDIF
               I = I + 1
            ENDDO
            IF .NOT. MMATCH
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
         
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         
         MPRT_PO = .T.
         SELECT B
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         
         DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
            
            IF LBS <= 0
               SKIP
               LOOP
            ENDIF
            IF SEL_PRICE = 0
               SKIP
               LOOP
            ENDIF
            if prod_desc = '1111' .or. prod_desc = '1112' .or. prod_desc = '1113'
               skip
               loop
            endif
            if prod_desc = '0300' .or. prod_desc = '1100' .or. prod_desc = '12  '
               skip
               loop
            endif
            if prod_desc = '1114' .or. prod_desc = '1115' .or. prod_desc = '1116'
               skip
               loop
            endif
            if prod_desc = '1117' .or. prod_desc = '1118' .or. prod_desc = '1119'
               skip
               loop
            endif
            if prod_desc = '1120' .or. prod_desc = '1121'
               skip
               loop
            endif
            if prod_desc = '8733' .or. prod_desc = '8801'
               skip
               loop
            endif
            if date() = ctod('05/23/2005')
               if prod_desc = '8910' .or. prod_desc = '8730'
                  skip
                  loop
               endif
            endif
            IF MSEL_PROD <> SPACE(10)
               IF MSEL_PROD = 'TENDERS'
                  IF PROD_DESC = '8901' .OR. PROD_DESC = '8910' .OR. PROD_DESC = '8989' .OR. PROD_DESC = '8999'
                  ELSE
                     SKIP
                     LOOP
                  ENDIF
               ELSE
                  IF MSEL_PROD <> PROD_DESC
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
            ENDIF   
            
            IF A->FRT_AMT1 = 0 .or. a->tot_lbs = 0
               MITM_FRT = 0
               MFRT_LB = 0
            ELSE
               MFRT_LB = (A->FRT_AMT1+A->FRT1_ADJ1+A->FRT1_ADJ2+A->FRT_PALL) / A->TOT_LBS
               IF SUBSTR(PACKED,1,1) = 'B'
                  MPACKED = VAL(SUBSTR(PACKED,2))
               ELSE
                  MPACKED = 1
               ENDIF
               if lbs= 0
                  mitm_frt = 0
                  mfrt_lb = 0
               else
                  MITM_FRT = MFRT_LB * (LBS * MPACKED)
               endif
            ENDIF
            
            IF COM1_CENT <> 0 .OR. COM2_CENT <>0 .OR. COM3_CENT <> 0
               MCOMM_LB = COM1_CENT + COM2_CENT + COM3_CENT
               MITM_COMM = MCOMM_LB * LBS
            ELSE
               MCOMM_LB  = 0
               MITM_COMM = 0
            ENDIF
            
            MBB_LB = 0
            
            
            SELECT E
            APPEND BLANK
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR   WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE BBUYCODE WITH MSAVE_CODE
            REPLACE NAME WITH MCUST_NAME
            REPLACE SHIP_DATE WITH A->SHIP_DATE
            IF MSEL_PROD = 'TENDERS'
               REPLACE PROD_DESC WITH 'TENDERS'
            ELSE
               REPLACE PROD_DESC WITH B->PROD_DESC
            ENDIF
            REPLACE LBS       WITH B->LBS
            REPLACE PUR_PRICE WITH B->PUR_PRICE
            REPLACE SEL_PRICE WITH B->SEL_PRICE
            REPLACE FRT_LB    WITH MFRT_LB
            REPLACE COMM_LB   WITH MCOMM_LB
            REPLACE BB_LB     WITH MBB_LB
            REPLACE PACKED    WITH B->PACKED            
            SELECT B
            SKIP
         ENDDO
         SELECT A
         SKIP
      ENDDO      
      
      SELECT E
      GOTO TOP
      
      ** IF DETAILS TO PRINT - AND MORE THAN ONE CUSTOMER
      IF .NOT. EOF() .AND. MCUST01 <> SPACE(4) .AND. MCUST02 <> SPACE(4)
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
            @ 1,25 SAY MCOMPANY + ' - Report: Spec9'
            @ 2,1 SAY 'Page'
            @ 2,06 say MPAGE_NO picture '99'
            @ 2,25 SAY 'PRODUCTS TOTAL FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
            @ 2,80 SAY DTOC(DATE())
            @ 3,25 SAY 'COMMISSION PAYEE: ' + MCOM_NAME 
            @ 3,80 SAY TIME()
            
            MPRT_Prod   = .T.
            @ 5,01 SAY REPLICATE('_',95)
            MLINE = 7
            I = 1
            SELECT D
            DO WHILE I<= 99
               MI = SUBSTR(STR(I+100,3),2)
               IF MCUST&MI <> SPACE(4)
                  SEEK MCUST&MI
                  @ MLINE,1 SAY NAME
                  @ MLINE,40 SAY TRIM(CITY) + ', ' + STATE
                  MLINE = MLINE + 1
               ENDIF
               I = I + 1
            ENDDO
            MLINE = 88
         ENDIF
      ENDIF
      
      SELECT E
      STORE 0 TO GQTY, GPURCHASE, GCOST, GSELLING, GNET, GFRT, GCOMM, GBB, GLBS
      DO WHILE .NOT. EOF()
         STORE PROD_DESC TO MPROD_DESC
         STORE 0 TO MQTY, MPURCHASE, MCOST, MSELLING, MNET, MFRT, MCOMM, MBB, MLBS
         MPRT_PROD = .T.         
         DO WHILE .NOT. EOF() .AND. PROD_DESC = MPROD_DESC
            
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
               @ 1,25 SAY MCOMPANY + ' - Report: Spec9'
               @ 2,1 SAY 'Page'
               @ 2,06 say MPAGE_NO picture '99'
               @ 2,25 SAY 'PRODUCTS TOTAL FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
               @ 2,80 SAY DTOC(DATE())
               @ 3,25 SAY 'COMMISSION PAYEE: ' + MCOM_NAME 
               @ 3,80 SAY TIME()
               
               MPRT_Prod   = .T.
               @ 4,1 SAY '                                            PRORATED'
               @ 5,1 SAY 'CUST   PO NUMBER SHIP DATE    QTY PURCHASE    FRT/LB    COMM      BB  ITM CST  SELLING  ITM NET'
               *          XXXXXX XX-XXXX-X XX/XX/XXXX 99999  XX.XXXX  XXX.XXXX XX.XXXX XX.XXXX  XX.XXXX  XX.XXXX  XX.XXXX
               *          12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
               *                   10        20        30        40        50        60        70        80        90        100       110
               
               @ 5,01 SAY REPLICATE('_',95)
               MLINE = 7
            ENDIF
            
            IF MPRT_PROD
               @ MLINE,1 SAY 'PRODUCT: ' + PROD_DESC
               MPRT_PROD = .F.
               MLINE = MLINE + 1
            ENDIF
            
            @ MLINE,1  SAY SUBSTR(NAME,1,6)
            IF SALESMAN <> SPACE(2)
               @ MLINE,8 SAY SALESMAN + '-'
            ENDIF
            @ MLINE,11 SAY PO_NBR
            IF PO_SUFFIX <> ' '
               @ MLINE,15 SAY '-' + PO_SUFFIX
            ENDIF
            @ MLINE,18 SAY SHIP_DATE                     
            @ MLINE,29 SAY LBS PICTURE '99999'
            @ MLINE,36 SAY PUR_PRICE PICTURE '99.9999'
            @ MLINE,45 SAY FRT_LB PICTURE '999.9999'
            @ MLINE,54 SAY COMM_LB PICTURE '99.9999'
            @ MLINE,62 SAY BB_LB PICTURE '99.9999'
            IF SUBSTR(PACKED,1,1) = 'B'
               MFRT_QTY = ROUND(VAL(SUBSTR(PACKED,2)) * FRT_LB,4)
               MCALC_LBS = ROUND(VAL(SUBSTR(PACKED,2)) * LBS,4)
            ELSE
               MFRT_QTY = FRT_LB
               MCALC_LBS = LBS
            ENDIF
            
            MPRO_PRI = PUR_PRICE + MFRT_QTY + COMM_LB + BB_LB
            @ MLINE,71 SAY MPRO_PRI PICTURE '99.9999'
            @ MLINE,80 SAY SEL_PRICE PICTURE '99.9999'
            @ MLINE,89 SAY SEL_PRICE - MPRO_PRI PICTURE '99.9999'
            
            *** ADD IN FOR PRODUCT TOTALS
            MQTY = MQTY + LBS
            MLBS     = MLBS  + MCALC_LBS
            MPURCHASE = MPURCHASE + ROUND(LBS*PUR_PRICE,2)
            MCOST = MCOST + ROUND(LBS*MPRO_PRI,2)
            MSELLING = MSELLING + ROUND(LBS*SEL_PRICE,2)
            MNET     = MNET  + ROUND(LBS*(SEL_PRICE-MPRO_PRI),2)
            MFRT     = MFRT  + ROUND(LBS*MFRT_QTY,2)
            MCOMM    = MCOMM + ROUND(LBS*COMM_LB,2)
            MBB      = MBB   + ROUND(LBS*BB_LB,2)
            
            *** ADD IN FOR GRAND TOTALS
            GQTY     = GQTY + LBS
            GLBS     = GLBS + MCALC_LBS
            
            GPURCHASE = GPURCHASE + ROUND(LBS*PUR_PRICE,2)
            GCOST    = GCOST + ROUND(LBS*MPRO_PRI,2)
            GSELLING = GSELLING + ROUND(LBS*SEL_PRICE,2)
            GNET     = GNET  + ROUND(LBS*(SEL_PRICE-MPRO_PRI),2)
            GFRT     = GFRT  + ROUND(LBS*MFRT_QTY,2)
            GCOMM    = GCOMM + ROUND(LBS*COMM_LB,2)
            GBB      = GBB   + ROUND(LBS*BB_LB,2)
            MLINE = MLINE + 1
            SKIP
         ENDDO
         @ MLINE,1 SAY 'TOTAL/AVG'
         @ MLINE,26 SAY MQTY PICTURE '99999999'
         @ MLINE,36 SAY ROUND(MPURCHASE/MQTY,4) PICTURE '99.9999'
         @ MLINE,45 SAY ROUND(MFRT/MLBS,4) PICTURE '999.9999'
         @ MLINE,54 SAY ROUND(MCOMM/MQTY,4) PICTURE '99.9999'
         @ MLINE,62 SAY ROUND(MBB/MQTY,4) PICTURE '99.9999'
         @ MLINE,71 SAY ROUND(MCOST/MQTY,4)     PICTURE '99.9999'
         @ MLINE,80 SAY ROUND(MSELLING/MQTY,4)  PICTURE '99.9999'
         @ MLINE,89 SAY ROUND(MNET/MQTY,4)      PICTURE '99.9999'
         MLINE = MLINE + 2
      ENDDO
      
      IF MLINE <> 99
         IF MDISP_PRT = 'P'
            IF MSEL_PROD = SPACE(10)
               MLINE = MLINE + 2
               @ MLINE,1 SAY 'GRAND TOTAL/AVG'
               @ MLINE,26 SAY GQTY PICTURE '99999999'
               @ MLINE,36 SAY ROUND(GPURCHASE/GQTY,4) PICTURE '99.9999'
               @ MLINE,45 SAY ROUND(GFRT/GLBS,4) PICTURE '999.9999'
               @ MLINE,54 SAY ROUND(GCOMM/GQTY,4) PICTURE '99.9999'
               @ MLINE,62 SAY ROUND(GBB/GQTY,4) PICTURE '99.9999'
               @ MLINE,71 SAY ROUND(GCOST/GQTY,4)     PICTURE '99.9999'
               @ MLINE,80 SAY ROUND(GSELLING/GQTY,4)  PICTURE '99.9999'
               @ MLINE,89 SAY ROUND(GNET/GQTY,4)      PICTURE '99.9999'
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
   ENDDO
   
ENDCASE

RETURN

*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 1:20 PM.
