************
* Program.: SPECIAL8.PRG
* Author..: GRACE KELLER
* Date....: 
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: REPORT SPECIAL8
*
* ---SET environment.
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     


CLEAR
@ 01,00 SAY MCOMPANY
@ 02,00 SAY MPROGRAM + ' - REPORT SPECIAL8 PROD DTLS/TOTS'
@ 02,70 SAY DATE()
@ 3,0 to 24,79

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
      MPAGE_LEN = 54
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
   SELECT F
   DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
   SELECT E
   DO FOX_USE WITH "MISC_CHG INDEX MISC_CHG", .F.
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
   MGRND_LBS = 0

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
      
      MCUST_LBS = 0
      
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
               @ 1,25 SAY MCOMPANY + ' - Report: Spec8'
               @ 2,1 SAY 'Page'
               @ 2,06 say MPAGE_NO picture '99'
               @ 2,25 SAY 'PRODUCTS TOTAL FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
               @ 2,80 SAY DTOC(DATE())
               @ 3,80 SAY TIME()
               
               MPRT_NAME = .T.
               MPRT_PO   = .T.
               @ 5,1 SAY 'PO NUMBER SHIP DATE   PROD    QTY PURCHASE   FREIGHT    COMM      BB  ITM CST  SELLING  ITM NET'
               *          XX-XXXX-X XX/XX/XXXX  XXXX  99999  XX.XXXX  XXX.XXXX XX.XXXX XX.XXXX  XX.XXXX  XX.XXXX  XX.XXXX
               *          12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
               *                   10        20        30        40        50        60        70        80        90        100       110
               
               @ 5,01 SAY REPLICATE('_',95)
               MLINE = 7
            ENDIF

            IF A->FRT_AMT1 = 0
               MITM_FRT = 0
               MFRT_LB = 0
            ELSE
               MFRT_LB = (A->FRT_AMT1+A->FRT1_ADJ1+A->FRT1_ADJ2+A->FRT_PALL) / A->TOT_LBS
               **MITM_FRT = MFRT_LB * LBS
               MITM_FRT = MFRT_LB * QTY
               IF PACKED <> 'B'
                  MFRT_LB = ROUND(MITM_FRT / LBS,4)
               ENDIF
            ENDIF
            
            IF COM1_CENT <> 0 .OR. COM2_CENT <>0 .OR. COM3_CENT <> 0
               MCOMM_LB = COM1_CENT + COM2_CENT + COM3_CENT
               MITM_COMM = MCOMM_LB * LBS
            ELSE
               MCOMM_LB  = 0
               MITM_COMM = 0
            ENDIF
            
            MBB_LB = 0
            
            IF MPRT_NAME
               IF MLINE <> 7
                  MLINE = MLINE + 2
               ENDIF
               @ MLINE,1 SAY MCUST_NAME
               MPRT_NAME = .F.
               MLINE = MLINE + 1
            ENDIF
            
            IF MPRT_PO
               IF SALESMAN <> SPACE(2)
                  @ MLINE,1 SAY SALESMAN + '-'
               ENDIF
               @ MLINE,4 SAY PO_NBR
               IF PO_SUFFIX <> ' '
                  @ MLINE,8 SAY '-' + PO_SUFFIX
               ENDIF
               
               @ MLINE,11 SAY A->SHIP_DATE                     
               MPRT_PO = .F.
            ENDIF
            @ MLINE,23 SAY PROD_DESC
            @ MLINE,29 SAY LBS PICTURE '99999'
            MCUST_LBS = MCUST_LBS + LBS
            MGRND_LBS = MGRND_LBS + LBS
            @ MLINE,36 SAY PUR_PRICE PICTURE '99.9999'
            @ MLINE,45 SAY MFRT_LB PICTURE '999.9999'
            @ MLINE,54 SAY MCOMM_LB PICTURE '99.9999'
            @ MLINE,62 SAY MBB_LB PICTURE '99.9999'
            MPRO_PRI = PUR_PRICE + MFRT_LB + MCOMM_LB + MBB_LB 
            @ MLINE,71 SAY MPRO_PRI PICTURE '99.9999'
            @ MLINE,80 SAY SEL_PRICE PICTURE '99.9999'
            @ MLINE,88 SAY SEL_PRICE - MPRO_PRI PICTURE '999.9999'
            MLINE = MLINE + 1
            SKIP
         ENDDO
         
         SELECT A
         SKIP
      ENDDO
      
      IF MCUST_LBS <> 0 .AND. MSEL_PROD <> SPACE(4)
         @ MLINE,1 SAY 'TOTAL:'
         @ MLINE,29 SAY MCUST_LBS PICTURE '99999'
         **MGRND_LBS = MGRND_LBS + MCUST_LBS
         MLINE = MLINE + 1
      ENDIF

   ENDDO
   
   IF MLINE <> 99
      IF MDISP_PRT = 'P'
         MLINE = MLINE + 2
         @ MLINE,1 SAY 'GRAND TOTAL:'
         @ MLINE,29 SAY MGRND_LBS PICTURE '99999'
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
   ELSE
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
   ENDIF
   CLOSE DATA
   MNOT_DONE = .F.
ENDDO
RETURN

*Formatted by: ToolBox Ver. 1.2  on 3/11/16 at 10:31 AM.
