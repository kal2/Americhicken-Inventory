************
* Program.: SPEC18.PRG
* Author..: GRACE KELLER
* Date....: 
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: REPORT SPECIAL 18
*
* ---SET environment.
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

CLEAR
@ 01,01 SAY MCOMPANY
@ 02,01 SAY MPROGRAM + ' - PO ACTIVITY FOR SUP/CUS/PRODUCT'
@ 02,70 SAY DATE()
@ 3,0 TO 23,79

STORE SPACE(4) TO MBBUYCODE, MRSUPCODE, MBUY_CODE, MSUP_CODE
MPAPER = SPACE(6)

MCHOICE = ' '
MYES_NO = SPACE(3)  
@ 10,5 SAY 'Do you want to select a specific Customer (YES/NO)? ' get MYES_NO picture '@!'
READ
IF MYES_NO <> 'YES' .AND. MYES_NO <> 'NO '
   REPLACE   
ENDIF
@ 10,1 SAY SPACE(78)
IF MYES_NO = 'YES'
   MNAME_FD = .F.
   DO BBUYSEL3
   IF .NOT. MNAME_FD
      REPLACE  
   ENDIF
   STORE BBUYCODE TO MBBUYCODE
   STORE NAME TO MNAME
   STORE CITY TO MCITY
   STORE STATE TO MSTATE
   CLEAR
   @ 01,01 SAY MCOMPANY
   @ 02,01 SAY MPROGRAM + ' - PRODUCT DETAILS/TOTALS'
   @ 02,70 SAY DATE()
   @ 3,0 TO 23,79
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
@  1,70 SAY DATE()
@  2, 1 SAY MPROGRAM + MTITLE
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
   
   SELECT E
   DO FOX_USE WITH "TEMPPROD", .T.
   DELETE ALL
   PACK
   INDEX ON NAME + BBUYCODE + DTOC(SHIP_DATE) TO TEMPPROD
   DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .T.
   
   SELECT B
   DO FOX_USE WITH "PO_DTL INDEX  PO_DTL", .F.
   
   IF MSEL_PROD <> SPACE(10)            
      SET FILTER TO PROD_DESC = MSEL_PROD
      GOTO TOP
   ENDIF
   
   SELECT C 
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
   SELECT D
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
   
   SELECT A 
   DO FOX_USE WITH "PO_HEAD INDEX TMP_BUY", .F.
   
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
      
      IF BBUYCODE = 'NONE'
         SKIP
         LOOP
      ENDIF
      
      MPRT_NAME = .T.
      STORE BBUYCODE TO MSAVE_CODE
      
      IF A->BBUYCODE = 'INVN'
         SELECT F 
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         SEEK A->BUY_CODE
         IF .NOT. EOF()
            STORE NAME TO MCUST_NAME 
         ELSE
            STORE 'CUST NOT ON FILE' TO MCUST_NAME
         ENDIF    
      ELSE
         SELECT D
         SEEK A->BBUYCODE
         IF .NOT. EOF()
            STORE NAME TO MCUST_NAME 
         ELSE
            STORE 'CUST NOT ON FILE' TO MCUST_NAME
         ENDIF
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
         STORE 0 TO MTOT_LBS         
         
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
               
               MLBS = MLBS + LBS
               
               SKIP
            ENDDO
            
            IF MLBS = 0
               SELECT A
               SKIP
               LOOP
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
            
            IF A->BBUYCODE = 'INVN'
               SELECT F 
               DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
               SEEK A->BUY_CODE
               IF .NOT. EOF()
                  STORE NAME TO MCUST_NAME 
               ELSE
                  STORE 'CUST NOT ON FILE' TO MCUST_NAME
               ENDIF    
            ELSE
               SELECT D
               SEEK A->BBUYCODE
               IF .NOT. EOF()
                  STORE NAME TO MCUST_NAME 
               ELSE
                  STORE 'CUST NOT ON FILE' TO MCUST_NAME
               ENDIF
            ENDIF
            SELECT E
            REPLACE NAME WITH MCUST_NAME
            REPLACE TOT_LBS WITH MLBS
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
      
      MPRT_NAME = .T.
      STORE NAME+BBUYCODE TO MSAVE_CODE
      
      MCUST_NAME = NAME
      
      SELECT A
      
      STORE 0 TO MTOT_FRT, MTOT_LBS
      
      DO WHILE .NOT. EOF() .AND. NAME+BBUYCODE = MSAVE_CODE
         
         IF A->RSUPCODE = 'INVN'
            SELECT F 
            DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
            SEEK A->SUP_CODE
            IF .NOT. EOF()
               MSUP_NAME = NAME
            ELSE
               MSUP_NAME = 'SUP NOT ON FILE'
            ENDIF
         ELSE
            SELECT C
            SEEK A->RSUPCODE
            IF .NOT. EOF()
               MSUP_NAME= NAME
            ELSE
               MSUP_NAME = 'SUP NOT ON FILE'
            ENDIF
         ENDIF
         
         SELECT A
         
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
            @ 1,25 SAY MCOMPANY + ' - Report: Spec18'
            @ 2,1 SAY 'Page'
            @ 2,06 say MPAGE_NO picture '99'
            @ 2,25 SAY DTOC(MSTART) + ' - ' + DTOC(MLAST)
            @ 2,80 SAY DTOC(DATE())
            IF MSEL_PROD <> SPACE(10)
               @ 3,25 SAY 'OPTIONAL PRODUCT: ' + MSEL_PROD
            ENDIF
            @ 3,80 SAY TIME()
            MPRT_NAME = .T.
            MPRT_PO   = .T.
            @ 5,1 SAY 'PO NUMBER SHIP DATE   SUPPLIER                                     QTY'
            MLINE = 6
         ENDIF
         
         SELECT A
         MLBS = TOT_LBS
         MFRT_LB = FRT_LB
         IF MPRT_NAME
            MLINE = MLINE + 1
            @ MLINE,1 SAY MCUST_NAME
            MPRT_NAME = .F.
            MLINE = MLINE + 1
         ENDIF
         
         MTOT_LBS = MTOT_LBS + MLBS
         
         IF SALESMAN <> SPACE(2)
            @ MLINE,1 SAY SALESMAN + '-'
         ENDIF
         @ MLINE,4 SAY PO_NBR
         IF PO_SUFFIX <> ' '
            @ MLINE,8 SAY '-' + PO_SUFFIX
         ENDIF
         
         @ MLINE,11 SAY A->SHIP_DATE                     
         
         @ MLINE,23 SAY MSUP_NAME
         
         @ MLINE,62 SAY MLBS PICTURE '9,999,999'
         MLINE = MLINE + 1
         SKIP
      ENDDO
      IF MTOT_LBS <> 0
         @ MLINE,1  SAY 'SUBTOTAL:'
         @ MLINE,62 SAY MTOT_LBS PICTURE '9,999,999'
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

*Formatted by: ToolBox Ver. 1.2  on 12/9/16 at 1:45 PM.
