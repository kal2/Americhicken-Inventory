****************
* Program.: PRODRPTS.PRG
* Author..: GRACE KELLER
* Date....: 01/08/88
* Notice..: Copyright (C) 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRODUCT REPORT MENU    
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion      
CLOSE DATA
STORE ' ' TO MSELECTION
STORE ' ' TO MACTION
DIMENSION MPUR(20)
DIMENSION MBOT(20)
DIMENSION MDLRS(20)
DIMENSION MPOUNDS(20)
DIMENSION MDESC(20)

DO WHILE VAL(MSELECTION) <> 9  
   CLOSE DATA
   CLEAR
   @ 01,00 SAY MCOMPANY
   @ 02,00 SAY MPROGRAM + ' - PRODUCT REPORTS MENU'
   @ 02,70 SAY DATE()
   @ 3,0 to 25,79
   
   @ 04,10 SAY ' 1 - SPECIAL REPORTS'
   @ 06,10 SAY ' 2 - PRINT MONTHLY SALES POUNDS/SALE$/NET$ - SUMMARY/BY CUSTOMER'
   @ 08,10 SAY ' 3 - LIST PRODUCT DETAILS FOR SUPPLIERS/CUSTOMERS'
   @ 10,10 SAY ' 4 - LIST ALL SUPPLIERS/CUSTOMERS SELLING/BUYING PRODUCTS'
   @ 12,10 SAY ' 5 - LIST PRODUCT AVERAGE PRICES '
   @ 14,10 say ' 6 - LIST DOLLAR/POUNDS ACTIVITY FOR FREIGHT CARRIERS'
   @ 16,10 SAY ' 7 - SALESPERSON SUPPLIER/CUSTOMER/PRODUCT TOTAL REPORTS'
   @ 18,10 say ' 8 - POUNDS BY PRODUCT SUMMARY'
   @ 20,10 SAY ' 9 - RETURN TO REPORTS MENU'
   
   STORE ' ' TO MSELECTION
   @ 23,02 SAY 'CHOICE: '
   @ 23,10 GET MSELECTION
   READ
   
   DO CASE
      
   CASE VAL(MSELECTION) = 1
      DO SPECRPTS
      
   CASE VAL(MSELECTION) = 2 
      DO AMERISUM
      
      
   CASE VAL(MSELECTION) = 3
      DO PRODDTLS
      
      
   CASE VAL(MSELECTION) =  4
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 02,00 SAY MPROGRAM + ' - PRODUCT REPORTS MENU'
      @ 02,70 SAY DATE()
      @ 3,0 to 22,79
      @ 10,5 SAY 'Do You Want Products for: ' 
      store ' ' to mchoice
      @ 12,5 say 'Remit to Suppliers (S) or Bill to Customers (C) ? ' get mchoice picture '@!'
      READ
      DO CASE
      CASE MCHOICE = 'S'
         MNOT_DONE = .T.
         DO WHILE MNOT_DONE
            MTITLE = ' - SUPPLIERS SELLING PRODUCT(S)'
            CLEAR
            @  1,0  SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2,0  SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            **** GET FIRST AND LAST DATES FOR THIS REPORT
            STORE CTOD(' ') TO MSTART, MLAST
            STORE 'D' TO MDISP_PRT
            MDLRS_LBS = 'Y'
            STORE SPACE(10) TO MPROD1, MPROD2
            STORE '**' TO MOPT_SALES
            @ 07,2 say '        BEGINNING DATE: '
            @ 09,2 SAY '           ENDING DATE: '
            @ 11,2 SAY '    PRODUCT CODE RANGE:          THRU'      
            @ 13,1 SAY '         PRINT DOLLARS: ' 
            @ 15,2 SAY 'DISPLAY OR PRINT (D/P): '
            @ 17,2 SAY '(OPTIONAL) SALESPERSON: '
            STORE 'PLEASE SELECT REPORT OPTIONS....' TO MGET
            @ 20,16 GET MGET
            CLEAR GETS
            
            STORE 2 TO MACTION      
            DO WHILE MACTION = 2      
               @ 07,27 GET MSTART
               @ 09,27 GET MLAST
               @ 11,27 GET MPROD1 PICTURE '@!'
               @ 11,41 GET MPROD2 PICTURE '@!'
               @ 13,27 GET MDLRS_LBS PICTURE '@!'
               @ 15,27 GET MDISP_PRT PICTURE '@!'
               @ 17,27 GET MOPT_SALES PICTURE '@!'
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
                  ENDIF
               ENDIF
               
               IF MACTION = 1
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
            
            IF MDISP_PRT = 'P'
               DO PRT_SET
               
               IF MPRT_ACT <> 'C'
                  LOOP   
               ENDIF
               MPAGE_LEN = 56
            ELSE
               MPAGE_LEN = 22
            ENDIF
            SELECT C
            USE TEMPPROD EXCLUSIVE
            DELETE ALL
            PACK
            INDEX ON RSUPCODE + PROD_DESC TO TEMPPROD
            CLOSE DATA
            SELECT B 
            DO FOX_USE WITH "PO_DTL INDEX  PO_DTL", .F.
            SELECT A 
            DO FOX_USE WITH "PO_HEAD INDEX  PO_SHIP", .F.
            SELECT C 
            DO FOX_USE WITH "TEMPPROD INDEX  TEMPPROD", .F.
            DO FILELOCK
            
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
            SELECT A
            SEEK MSTRT_YR + MSTRT_MO + MSTRT_DAY
            IF EOF()
               SEEK MSTRT_YR + MSTRT_MO 
               IF EOF()
                  SEEK MSTRT_YR
                  IF EOF()
                     GOTO TOP
                  ENDIF
               ENDIF
            ENDIF
            DO WHILE .NOT. EOF() .AND. SHIP_DATE < MSTART
               SKIP
            ENDDO
            MPAGE_NO = 0
            MLINE = 99 
            @ 20,16 SAY 'PROCESSING........'
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
            
            MPROD1 = VAL(MPROD1)
            IF MPROD2 = SPACE(10)
               MPROD2 = MPROD1
            ELSE
               MPROD2 = VAL(MPROD2)
            ENDIF
            DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MLAST
               IF RSUPCODE = 'NONE' .OR. RSUPCODE = 'INVN'
                  SKIP
                  LOOP
               ENDIF
               IF MOPT_SALES <> '**'
                  IF SALESMAN <> MOPT_SALES
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               STORE SALESMAN TO MSALESMAN
               STORE PO_NBR TO MPO_NBR
               STORE PO_SUFFIX TO MPO_SUFFIX
               STORE RSUPCODE TO MRSUPCODE
               STORE SHIP_DATE TO MSHIP_DATE
               SELECT B
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
                  IF PUR_PRICE = 0
                     SKIP
                     LOOP
                  ENDIF
                  I = 1
                  IF VAL(PROD_DESC) >= MPROD1 .AND. VAL(PROD_DESC) <= MPROD2
                     
                     SELECT C 
                     SEEK MRSUPCODE + B->PROD_DESC
                     IF EOF()
                        APPEND BLANK
                        REPLACE RSUPCODE WITH MRSUPCODE
                        REPLACE PROD_DESC WITH B->PROD_DESC
                     ENDIF
                     IF B->TOT_BILL = 0
                        REPLACE TOT_PURCH WITH  TOT_PURCH + B->TOT_PURCH
                     ELSE
                        REPLACE TOT_PURCH WITH  TOT_PURCH + B->TOT_BILL
                     ENDIF
                     REPLACE TOT_LBS WITH TOT_LBS + B->LBS
                     REPLACE SHIP_DATE WITH MSHIP_DATE
                     REPLACE NBR_SHIPS WITH NBR_SHIPS + 1
                     SELECT B
                  ENDIF
                  SKIP
               ENDDO
               SELECT A
               SKIP
            ENDDO
            CLOSE DATA
            
            *** FINISHED WITH EXTRACT - NOW START REPORT
            MLINE = 99
            MPAGE_NO = 0
            SELECT D 
            DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
            SELECT C 
            DO FOX_USE WITH "TEMPPROD INDEX  TEMPPROD", .F.
            SELECT B
            DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX  &MDBFLOC.RSUPNAME", .F.
            
            DO WHILE .NOT. EOF()
               SELECT C
               SEEK B->RSUPCODE
               IF EOF()
                  SELECT B
                  SKIP
                  LOOP
               ENDIF
               SELECT B
               STORE NAME      TO MNAME
               STORE STREET    TO MADDR
               STORE CITY      TO MCITY
               STORE STATE     TO MSTATE
               STORE ZIP       TO MZIP
               STORE PHONE     TO MPHONE
               STORE AREA_CODE TO MAREA_CODE
               
               STORE 0 TO MTOT_DLRS, MTOT_LBS
               MRSUPCODE = RSUPCODE
               IF MLINE > MPAGE_LEN
                  IF MDISP_PRT <> 'P'
                     IF MLINE = 99 
                        CLEAR
                     ELSE
                        STORE ' ' TO MWAIT
                        @ 24,0 SAY 'Press Return to Continue Report ' GET MWAIT
                        READ
                        CLEAR    
                     ENDIF
                  ELSE 
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                  ENDIF
                  MLINE = 1
                  MPAGE_NO = MPAGE_NO + 1
                  @ 1,27 SAY MCOMPANY
                  @ 1,60 SAY DTOC(DATE())
                  @ 1,70 SAY TIME()
                  IF MOPT_SALES <> '**'
                     @ 2,27 SAY 'OPTIONAL SALESPERSON: ' + MOPT_SALES
                     MLINE = 3
                  ELSE
                     MLINE = 2
                  ENDIF
                  @ MLINE,1 SAY 'Page'
                  @ MLINE,06 say mpage_no picture '99'
                  @ MLINE,15 SAY 'SUPPLIERS BUYING PRODUCTS BETWEEN ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
                  IF MDISP_PRT = 'P'
                     @ MLINE,01 SAY REPLICATE('_',94)
                  ENDIF
                  MLINE = MLINE + 2
                  IF MDLRS_LBS = 'Y'
                     @ MLINE,01 SAY 'LAST SHIP DT    NBR OF SHIPS      PRODUCT                        TOTAL DOLLARS'
                  ELSE
                     @ MLINE,01 SAY 'LAST SHIP DT    NBR OF SHIPS      PRODUCT'
                  ENDIF
                  IF MDISP_PRT = 'P'
                     @ MLINE,82 SAY 'TOTAL POUNDS'
                  ENDIF
                  MLINE = MLINE + 1
               ENDIF
               MLINE = MLINE + 1
               @ MLINE,01 SAY MNAME    
               @ MLINE,40 SAY TRIM(MADDR)
               MLINE = MLINE + 1
               @ MLINE,1 SAY '(' + MAREA_CODE + ')' + SUBSTR(MPHONE,1,3) + '-' + SUBSTR(MPHONE,4)
               @ MLINE,40 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP 
               MLINE = MLINE + 1
               SELECT C
               DO WHILE .NOT. EOF() .AND. RSUPCODE = MRSUPCODE
                  
                  IF MLINE > MPAGE_LEN
                     IF MDISP_PRT <> 'P'
                        IF MLINE = 99 
                           CLEAR
                        ELSE
                           STORE ' ' TO MWAIT
                           @ 24,0 SAY 'Press Return to Continue Report ' GET MWAIT
                           READ
                           CLEAR    
                        ENDIF
                     ELSE  
                        IF MLINE <> 99
                           EJECT
                        ENDIF
                     ENDIF
                     MLINE = 1
                     MPAGE_NO = MPAGE_NO + 1
                     @ 1,27 SAY MCOMPANY
                     @ 1,60 SAY DTOC(DATE())
                     @ 1,70 SAY TIME()
                     IF MOPT_SALES <> '**'
                        @ 2,27 SAY 'OPTIONAL SALESPERSON: ' + MOPT_SALES
                        MLINE = 3
                     ELSE
                        MLINE = 2
                     ENDIF
                     @ MLINE,1 SAY 'Page'
                     @ MLINE,06 say mpage_no picture '99'
                     @ MLINE,15 SAY 'SUPPLIERS BUYING PRODUCTS BETWEEN ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
                     IF MDISP_PRT = 'P'
                        @ MLINE,01 SAY REPLICATE('_',94)
                     ENDIF
                     MLINE = MLINE + 2
                     IF MDLRS_LBS = 'Y'
                        @ MLINE,01 SAY 'LAST SHIP DT    NBR OF SHIPS      PRODUCT                        TOTAL DOLLARS'
                     ELSE
                        @ MLINE,01 SAY 'LAST SHIP DT    NBR OF SHIPS      PRODUCT'
                     ENDIF
                     IF MDISP_PRT = 'P'
                        @ MLINE,82 SAY 'TOTAL POUNDS'
                     ENDIF
                     MLINE = MLINE + 2
                     @ MLINE,01 SAY MNAME    
                     @ MLINE,40 SAY TRIM(MADDR)
                     MLINE = MLINE + 1
                     @ MLINE,1 SAY '(' + MAREA_CODE + ')' + SUBSTR(MPHONE,1,3) + '-' + SUBSTR(MPHONE,4)
                     @ MLINE,40 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP 
                     MLINE = MLINE + 1
                  ENDIF
                  SELECT D
                  SEEK 'R' + C->PROD_DESC 
                  IF EOF()
                     MPRT_DESC = 'NOT ON FILE'
                  ELSE
                     MPRT_DESC = DESC
                  ENDIF
                  SELECT C
                  @ MLINE,03 SAY SHIP_DATE
                  @ MLINE,20 SAY NBR_SHIPS PICTURE '9999'
                  @ MLINE,35 SAY '(' + TRIM(C->PROD_DESC) + ') ' + MPRT_DESC
                  IF MDLRS_LBS = 'Y'
                     @ MLINE,65 SAY TOT_PURCH PICTURE '999,999,999.99' 
                  ENDIF
                  IF MDISP_PRT = 'P'
                     @ MLINE,80 SAY TOT_LBS PICTURE '999,999,999.99'
                  ENDIF
                  SKIP
                  MLINE = MLINE + 1
               ENDDO
               SELECT B
               SKIP
            ENDDO
            
            IF MDISP_PRT = 'P'
               MLINE = MLINE + 1
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
         ENDDO
         
      CASE MCHOICE = 'C'  
         MNOT_DONE = .T.
         DO WHILE MNOT_DONE
            MTITLE = ' - CUSTOMERS BUYING PRODUCT(S)'
            CLEAR
            @  1, 1  SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            **** GET FIRST AND LAST DATES FOR THIS REPORT
            STORE CTOD(' ') TO MSTART, MLAST
            STORE 'D' TO MDISP_PRT
            STORE SPACE(10) TO MPROD1, MPROD2
            MDLRS_LBS = 'Y'
            MOPT_SALES = '**'
            @ 07,2 say '        BEGINNING DATE: '
            @ 09,2 SAY '           ENDING DATE: '
            @ 13,2 SAY '         PRINT DOLLARS: '
            @ 11,2 SAY '    PRODUCT CODE RANGE:          THRU'      
            @ 15,2 SAY 'DISPLAY OR PRINT (D/P): '
            @ 17,2 SAY '(OPTIONAL) SALESPERSON: '
            STORE 'PLEASE SELECT REPORT OPTIONS....' TO MGET
            @ 20,16 GET MGET
            CLEAR GETS
            
            STORE 2 TO MACTION      
            DO WHILE MACTION = 2      
               @ 07,27 GET MSTART
               @ 09,27 GET MLAST
               @ 11,27 GET MPROD1 PICTURE '@!'
               @ 11,41 GET MPROD2 PICTURE '@!'
               @ 13,27 GET MDLRS_LBS PICTURE '@!'
               @ 15,27 GET MDISP_PRT PICTURE '@!'
               @ 17,27 GET MOPT_SALES PICTURE '@!'
               STORE 1 TO MACTION
               @ 24,00 CLEAR
               @ 24,01 SAY 'Action: ' + STR(MACTION,1)
               @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'                     
               
               READ
               
               @24,09 GET MACTION PICTURE '9' RANGE 1,3
               READ               
               IF MACTION = 1
                  IF DTOC(MSTART) = '  /  /  ' .AND. DTOC(MLAST) = '  /  /  '
                     MACTION = 3
                  ENDIF
               ENDIF
               
               IF MACTION = 1
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
            
            IF MDISP_PRT = 'P'
               DO PRT_SET
               
               IF MPRT_ACT <> 'C'
                  LOOP   
               ENDIF
               MPAGE_LEN = 56
            ELSE
               MPAGE_LEN = 22
            ENDIF
            SELECT C
            USE TEMPPROD EXCLUSIVE
            DELETE ALL
            PACK
            INDEX ON BBUYCODE + PROD_DESC TO TEMPPROD
            CLOSE DATA
            SELECT B 
            DO FOX_USE WITH "PO_DTL INDEX  PO_DTL", .F.
            SELECT A 
            DO FOX_USE WITH "PO_HEAD INDEX  PO_SHIP", .F.
            SELECT C 
            DO FOX_USE WITH "TEMPPROD INDEX  TEMPPROD", .F.
            DO FILELOCK
            
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
            SELECT A
            SEEK MSTRT_YR + MSTRT_MO + MSTRT_DAY
            IF EOF()
               SEEK MSTRT_YR + MSTRT_MO 
               IF EOF()
                  SEEK MSTRT_YR
                  IF EOF()
                     GOTO TOP
                  ENDIF
               ENDIF
            ENDIF
            DO WHILE .NOT. EOF() .AND. SHIP_DATE < MSTART
               SKIP
            ENDDO
            MPAGE_NO = 0
            MLINE = 99 
            @ 19,16 SAY 'PROCESSING........'
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
            
            STORE VAL(MPROD1) TO MPROD1
            IF MPROD2 = SPACE(10)
               STORE MPROD1 TO MPROD2
            ELSE
               STORE VAL(MPROD2) TO MPROD2
            ENDIF
            DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MLAST
               IF BBUYCODE = 'NONE' .OR. BBUYCODE = 'INVN'
                  SKIP
                  LOOP
               ENDIF
               IF MOPT_SALES <> '**'
                  IF SALESMAN <> MOPT_SALES
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               STORE SALESMAN TO MSALESMAN
               STORE PO_NBR TO MPO_NBR
               STORE PO_SUFFIX TO MPO_SUFFIX
               STORE BBUYCODE TO MBBUYCODE
               STORE SHIP_DATE TO MSHIP_DATE
               SELECT B
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
                  IF SEL_PRICE = 0
                     SKIP
                     LOOP
                  ENDIF
                  I = 1
                  IF VAL(PROD_DESC) >= MPROD1 .AND. VAL(PROD_DESC) <= MPROD2
                     SELECT C 
                     SEEK MBBUYCODE + B->PROD_DESC
                     IF EOF()
                        APPEND BLANK
                        REPLACE BBUYCODE WITH MBBUYCODE
                        REPLACE PROD_DESC WITH B->PROD_DESC
                     ENDIF
                     REPLACE TOT_SELL WITH  TOT_SELL + B->TOT_SELL   
                     REPLACE TOT_LBS WITH TOT_LBS   + B->LBS
                     REPLACE PROD_DESC WITH B->PROD_DESC
                     REPLACE SHIP_DATE WITH MSHIP_DATE
                     REPLACE NBR_SHIPS WITH NBR_SHIPS + 1
                     SELECT B
                  ENDIF
                  SKIP
               ENDDO
               SELECT A
               SKIP
            ENDDO
            CLOSE DATA
            SELECT D 
            DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX  &MDBFLOC.PRODUCTS", .F.
            SELECT C 
            DO FOX_USE WITH "TEMPPROD INDEX  TEMPPROD", .F.
            
            SELECT B
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
            MLINE = 99
            MPAGE_NO = 0
            DO WHILE .NOT. EOF()
               SELECT C
               SEEK B->BBUYCODE
               IF EOF()
                  SELECT B
                  SKIP
                  LOOP
               ENDIF
               MLINE = MLINE + 1
               SELECT B
               STORE NAME TO MNAME
               STORE CITY TO MCITY
               STORE STATE TO MSTATE
               STORE STREET TO MADDR
               STORE ZIP   TO MZIP
               STORE PHONE TO MPHONE
               STORE AREA_CODE TO MAREA_CODE
               STORE 0 TO MTOT_DLRS, MTOT_LBS
               MBBUYCODE = BBUYCODE
               STORE CRED_LIM TO MCRED_LIM
               MCRED_LIM1 = SPACE(10)       
               IF MCRED_LIM = 0
                  DO CASE
                  CASE SUBSTR(NOTE,1,3) = 'L/C' .OR. SUBSTR(NOTE,1,3) = 'CAD' .OR. SUBSTR(NOTE,1,3) = 'COD'
                     STORE SUBSTR(NOTE,1,3) TO MCRED_LIM1
                  CASE SUBSTR(NOTE,1,6) = 'C.O.D.'
                     STORE SUBSTR(NOTE,1,6) TO MCRED_LIM1
                  CASE SUBSTR(NOTE,1,9) = 'NO CREDIT'
                     STORE SUBSTR(NOTE,1,9) TO MCRED_LIM1
                  CASE SUBSTR(NOTE,1,10) = 'LOAD BASIS' .OR. SUBSTR(NOTE,1,10) = 'LOAD-BASIS'
                     STORE SUBSTR(NOTE,1,10) TO MCRED_LIM1
                  CASE SUBSTR(NOTE,1,10) = 'INV TO INV' .OR. SUBSTR(NOTE,1,10) = 'INV-TO-INV'
                     STORE SUBSTR(NOTE,1,10) TO MCRED_LIM1
                  OTHERWISE
                     STORE 'NO CREDIT ' TO MCRED_LIM1
                  ENDCASE
               ENDIF
               
               IF MLINE > MPAGE_LEN
                  IF MDISP_PRT <> 'P'
                     IF MLINE = 99 
                        CLEAR
                     ELSE
                        STORE ' ' TO MWAIT
                        @ 24,0 SAY 'Press Return to Continue Report ' GET MWAIT
                        READ
                        CLEAR    
                     ENDIF
                  ELSE 
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                  ENDIF
                  MLINE = 1
                  MPAGE_NO = MPAGE_NO + 1
                  @ 1,27 SAY MCOMPANY
                  @ 1,60 SAY DTOC(DATE())
                  @ 1,70 SAY TIME()
                  IF MOPT_SALES <> '**'
                     @ 2,27 SAY 'OPTIONAL SALESPERSON: ' + MOPT_SALES
                     MLINE = 3
                  ELSE
                     MLINE = 2
                  ENDIF
                  @ MLINE,1 SAY 'Page'
                  @ MLINE,06 say mpage_no picture '99'
                  @ MLINE,15 SAY 'CUSTOMERS BUYING PRODUCTS BETWEEN ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
                  IF MDISP_PRT = 'P'
                     @ MLINE,01 SAY REPLICATE('_',94)
                  ENDIF
                  MLINE = MLINE + 2
                  IF MDLRS_LBS = 'Y'
                     @ MLINE,01 SAY 'LAST SHIP DT    NBR OF SHIPS      PRODUCT                        TOTAL DOLLARS'
                  ELSE
                     @ MLINE,01 SAY 'LAST SHIP DT    NBR OF SHIPS      PRODUCT'
                  ENDIF
                  IF MDISP_PRT = 'P'
                     @ MLINE,82 SAY 'TOTAL POUNDS'
                  ENDIF
                  MLINE = MLINE + 2
               ENDIF
               @ MLINE,01 SAY MNAME    
               @ MLINE,40 SAY TRIM(MADDR)
               MLINE = MLINE + 1
               @ MLINE,1 SAY '(' + MAREA_CODE + ')' + SUBSTR(MPHONE,1,3) + '-' + SUBSTR(MPHONE,4)
               @ MLINE,40 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP 
               MLINE = MLINE + 1
               @ MLINE,1 SAY 'CREDIT LIMIT: '
               DO CASE
               CASE MCRED_LIM <> 0
                  @ MLINE,15 SAY MCRED_LIM PICTURE '9,999,999.99' 
               OTHERWISE
                  @ MLINE,15 SAY MCRED_LIM1
               ENDCASE
               MLINE = MLINE + 1
               SELECT C
               DO WHILE .NOT. EOF() .AND. BBUYCODE = MBBUYCODE
                  
                  IF MLINE > MPAGE_LEN
                     IF MDISP_PRT <> 'P'
                        IF MLINE = 99 
                           CLEAR
                        ELSE
                           STORE ' ' TO MWAIT
                           @ 24,0 SAY 'Press Return to Continue Report ' GET MWAIT
                           READ
                           CLEAR    
                        ENDIF
                     ELSE  
                        IF MLINE <> 99
                           EJECT
                        ENDIF
                     ENDIF
                     MLINE = 1
                     MPAGE_NO = MPAGE_NO + 1
                     @ 1,27 SAY MCOMPANY
                     @ 1,60 SAY DTOC(DATE())
                     @ 1,70 SAY TIME()
                     IF MOPT_SALES <> '**'
                        @ 2,27 SAY 'OPTIONAL SALESPERSON: ' + MOPT_SALES
                        MLINE = 3
                     ELSE
                        MLINE = 2
                     ENDIF
                     @ MLINE,1 SAY 'Page'
                     @ MLINE,06 say mpage_no picture '99'
                     @ MLINE,15 SAY 'CUSTOMERS BUYING PRODUCTS BETWEEN ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
                     IF MDISP_PRT = 'P'
                        @ MLINE,01 SAY REPLICATE('_',94)
                     ENDIF
                     MLINE = MLINE + 2
                     IF MDLRS_LBS = 'Y'
                        @ MLINE,01 SAY 'LAST SHIP DT    NBR OF SHIPS      PRODUCT                        TOTAL DOLLARS'
                     ELSE
                        @ MLINE,01 SAY 'LAST SHIP DT    NBR OF SHIPS      PRODUCT'
                     ENDIF
                     IF MDISP_PRT = 'P'
                        @ MLINE,82 SAY 'TOTAL POUNDS'
                     ENDIF
                     MLINE = MLINE + 2
                     @ MLINE,01 SAY MNAME    
                     @ MLINE,40 SAY TRIM(MADDR)
                     MLINE = MLINE + 1
                     @ MLINE,1 SAY '(' + MAREA_CODE + ')' + SUBSTR(MPHONE,1,3) + '-' + SUBSTR(MPHONE,4)
                     @ MLINE,40 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP 
                     MLINE = MLINE + 1
                  ENDIF
                  SELECT D
                  SEEK 'R' + C->PROD_DESC 
                  IF EOF()
                     MPRT_DESC = 'NOT ON FILE'
                  ELSE
                     MPRT_DESC = DESC
                  ENDIF
                  SELECT C
                  @ MLINE,03 SAY SHIP_DATE
                  @ MLINE,20 SAY NBR_SHIPS PICTURE '9999'
                  @ MLINE,35 SAY '(' + TRIM(C->PROD_DESC) + ') ' + MPRT_DESC
                  IF MDLRS_LBS = 'Y'
                     @ MLINE,65 SAY TOT_SELL PICTURE '999,999,999.99' 
                  ENDIF
                  IF MDISP_PRT = 'P'
                     @ MLINE,80 SAY TOT_LBS PICTURE '999,999,999.99'
                  ENDIF
                  SKIP
                  MLINE = MLINE + 1
               ENDDO
               SELECT B
               SKIP
            ENDDO
            
            IF MDISP_PRT = 'P'
               MLINE = MLINE + 1
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
         ENDDO
      ENDCASE            
      
   CASE VAL(MSELECTION) =  5    
      DO AVG_PRI
      
   CASE VAL(MSELECTION) = 6
      DO FRT_ACT
      
   CASE VAL(MSELECTION) = 7    
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 02,00 SAY MPROGRAM + ' - PRODUCT REPORTS MENU'
      @ 02,70 SAY DATE()
      @ 3,0 to 22,79
      SELECT C
      USE TEMPPROD EXCLUSIVE
      DELETE ALL
      PACK
      INDEX ON RSUPCODE +BBUYCODE+ PROD_DESC + SALESMAN TO TEMPPROD
      DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .F.
      DO FILELOCK
      STORE ' ' TO MCHOICE
      **** GET FIRST AND LAST DATES FOR THIS REPORT
      STORE CTOD(' ') TO MSTART, MLAST
      STORE 'D' TO MDISP_PRT
      STORE SPACE(10) TO MPROD
      STORE 2 TO MACTION
      DO WHILE MACTION = 2      
         @ 06,5 SAY 'Do You Want Totals for: ' 
         @ 08,5 say 'Remit to Suppliers (S) or Bill to Customers (C) ? '
         @ 09,5 SAY 'or by Product (P) ? ' get mchoice picture '@!'
         @ 12,2 say '        Beginning Date: '
         @ 12,27 GET MSTART
         @ 14,2 SAY '           Ending Date: '
         @ 14,27 GET MLAST
         @ 16,2 SAY 'Display or Print (D/P): '
         @ 16,27 GET MDISP_PRT PICTURE '@!'
         STORE 1 TO MACTION
         @ 24,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'                     
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 1
            IF DTOC(MSTART) = '  /  /  ' .AND. DTOC(MLAST) = '  /  /  '
               MACTION = 3
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
            IF MCHOICE <> 'C' .AND. MCHOICE <> 'S' .AND. MCHOICE <> 'P'
               @ 23,0 CLEAR
               mwait = ' '
               @ 23,1 SAY 'Supplier/Customer/Product Choice Invalid'
               @ 24,1 say 'Press Any Key to Reenter ' get mwait
               READ
               MACTION = 2
               @ 23,0 clear
               LOOP 
            ENDIF
         ENDIF 
      ENDDO
      IF MACTION = 3
         LOOP   
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
      
      @ 4,1 CLEAR TO 22,78
      @ 24,0 CLEAR
      
      STORE SPACE(32) TO MSAL_NAME
      STORE SPACE(10) TO MPROD
      MSELECT = .T.
      DO WHILE MSELECT
         @ 10,1 SAY '       SALESPERSON NAME:'
         @ 10,27 GET MSAL_NAME PICTURE '@!'
         IF MCHOICE = 'P'
            @ 11,1 SAY '(Optional - Leave name blank if report for all salespersons.)'
            @ 13,1 SAY '           PRODUCT CODE: ' get mprod picture '@!'
            @ 14,1 say '(Optional - Leave product blank if report for all products.)'
         ENDIF
         STORE 1 TO MACTION
         @ 24,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'                     
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 3 .OR. MSAL_NAME = SPACE(32)
            MSELECT = .F.
            STORE SPACE(2) TO MSALESMAN 
            LOOP
         ENDIF
         IF MACTION = 2
            LOOP
         ENDIF
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
         SEEK TRIM(MSAL_NAME)
         IF .NOT. EOF()
            STORE NAME TO MSAL_NAME
            STORE SALE_CODE TO MSALESMAN  
            MSELECT = .F.
         ELSE
            @ 22,0       
            mwait = ' '
            @ 22,1 SAY 'Invalid Salesperson Entered - Press Return to Reenter ' get mwait
            READ
            MACTION = 2
            @ 22,0
         ENDIF
      ENDDO
      IF MSALESMAN = SPACE(2) .AND. (MCHOICE = 'C' .OR. MCHOICE = 'S')
         LOOP
      ENDIF
      
      DO CASE
      CASE MCHOICE = 'S'
         store 'YES' to MYES_NO
         @ 15,5 SAY 'Do you want a Specific Supplier (YES/NO)? ' get MYES_NO picture '@!'
         READ
         IF MYES_NO <> 'NO '
            MTITLE = ' - SUPPLIER/SALESPERSON TOTAL LISTING'
            MNAME_FD = .F.
            DO RSUPSEL3
            IF .NOT. MNAME_FD
               LOOP  
            ENDIF
            STORE RSUPCODE TO MRSUPCODE
            CLEAR
            @  1, 1  SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
         ELSE
            @ 4,1 CLEAR TO 22,78
            @ 24,0 CLEAR
            STORE SPACE(4) TO MRSUPCODE
         ENDIF
         
         MPRT_ACT = 'C'
         
         IF MDISP_PRT = 'P'
            DO PRT_SET
            
            IF MPRT_ACT <> 'C'
               LOOP  
            ENDIF
            MPAGE_LEN = 56
         ELSE
            MPAGE_LEN = 20
         ENDIF
         SELECT A 
         DO FOX_USE WITH "PO_HEAD INDEX  PO_HEAD", .F.
         MSUB = 0
         STORE 0 TO MTOT_PURCH, MTOT_NET, MTOT_COMM  
         
         SELECT A
         SEEK MSALESMAN
         MPAGE_NO = 0
         MLINE = 99 
         @ 19,16 SAY 'PROCESSING........'
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
            
            *** LETTER GOTHIC AND BOLDED PRINT
            ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
            
            *** LETTER SIZE PAPER
            ?? CHR(27) + '&l2A'
            
            *** PORTRAIT MODE
            ?? CHR(27) + '&l0O'
            
         ENDIF
         
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
            IF MRSUPCODE <> SPACE(4)
               IF RSUPCODE <> MRSUPCODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            IF SHIP_DATE < MSTART .OR. SHIP_DATE > MLAST
               SKIP
               LOOP
            ENDIF
            SELECT C
            SEEK A->RSUPCODE
            IF EOF()
               APPEND BLANK
            ENDIF
            REPLACE RSUPCODE WITH A->RSUPCODE
            REPLACE TOT_NET WITH TOT_NET + A->TOT_NET
            REPLACE TOT_COMM WITH TOT_COMM + A->SALE_COMM
            REPLACE TOT_SELL WITH TOT_SELL + A->TOT_PURCH + A->SUP_PALL
            
            SELECT A
            SKIP
         ENDDO
         SELECT A
         SELECT A 
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
         
         SELECT C
         GOTO TOP
         MLINE = 99   
         DO WHILE .NOT. EOF()
            
            IF MLINE > MPAGE_LEN
               IF MLINE = 99 .AND. MDISP_PRT <> 'P'
                  CLEAR
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 1,40 SAY MCOMPANY
               @ 2,1 SAY 'Page'
               @ 2,06 say mpage_no picture '99'
               @ 2,25 SAY 'SUPPLIER/SALESMAN TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
               @ 2,70 SAY DTOC(DATE())
               @ 3,35 SAY MSAL_NAME
               @ 3,71 SAY TIME()
               IF MDISP_PRT = 'P'
                  @ 3,01 SAY REPLICATE('_',77)
               ENDIF
               @ 6,1 SAY 'SUPPLIER' 
               @ 6,33 SAY '   TOTAL PURCH'
               @ 6,51 SAY '   TOTAL NET'
               @ 6,63 SAY '   TOTAL COMM' 
               MLINE = 8
            ENDIF
            SELECT A
            SEEK C->RSUPCODE
            IF EOF()
               @ MLINE,1 SAY 'SUPPLIER NOT ON FILE:'+ C->RSUPCODE
            ELSE
               @ MLINE,1 SAY NAME
            ENDIF
            SELECT C
            @ MLINE,33 SAY TOT_SELL PICTURE '999,999,999.99' 
            @ MLINE,49 SAY TOT_NET  PICTURE '999,999,999.99'
            @ MLINE,62 SAY TOT_COMM PICTURE '999,999,999.99'
            MTOT_PURCH = MTOT_PURCH + TOT_SELL
            MTOT_NET = MTOT_NET + TOT_NET
            MTOT_COMM = MTOT_COMM + TOT_COMM
            MLINE = MLINE + 1
            SELECT A
            @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE
            SELECT C
            MLINE = MLINE + 2
            SKIP
         ENDDO
         
         IF MLINE > MPAGE_LEN
            IF MDISP_PRT <> 'P'
               IF MLINE = 99 
                  CLEAR
               ELSE
                  STORE ' ' TO MWAIT
                  @ 24,0 SAY 'Press Return to Continue to Next Page ' GET MWAIT
                  READ
                  CLEAR    
               ENDIF
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,27 SAY MCOMPANY
            @ 2,1 SAY 'Page'
            @ 2,06 say mpage_no picture '99'
            @ 2,25 SAY 'SUPPLIER/SALESMAN TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
            @ 2,70 SAY DTOC(DATE())
            @ 3,35 SAY MSAL_NAME
            @ 3,71 SAY TIME()
            IF MDISP_PRT = 'P'
               @ 3,01 SAY REPLICATE('_',77)
            ENDIF
            @ 6,1 SAY 'SUPPLIER' 
            @ 6,33 SAY '   TOTAL PURCH'
            @ 6,51 SAY '   TOTAL NET'
            @ 6,63 SAY '   TOTAL COMM' 
            MLINE = 7
         ENDIF
         @ MLINE,05 SAY 'TOTALS:'
         @ MLINE,33 SAY MTOT_PURCH PICTURE '999,999,999.99' 
         @ MLINE,49 SAY MTOT_NET  PICTURE '999,999,999.99'
         @ MLINE,62 SAY MTOT_COMM PICTURE '999,999,999.99'
         IF MDISP_PRT = 'P'
            MLINE = MLINE + 1
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
      CASE MCHOICE = 'C'  
         store 'YES' to MYES_NO
         @ 15,5 SAY 'Do you want a Specific Customer (YES/NO)? ' get MYES_NO picture '@!'
         READ
         IF MYES_NO <> 'NO '
            MTITLE = ' - CUSTOMER/SALESPERSON TOTAL LISTING'
            MNAME_FD = .F.
            DO BBUYSEL3
            IF .NOT. MNAME_FD
               LOOP  
            ENDIF
            STORE BBUYCODE TO MBBUYCODE
            CLEAR
            @  1, 1  SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
         ELSE
            @ 4,1 CLEAR TO 22,78
            @ 24,0 CLEAR
            STORE SPACE(4) TO MBBUYCODE
         ENDIF
         
         
         MPRT_ACT = 'C'
         
         IF MDISP_PRT = 'P'
            DO PRT_SET
            
            IF MPRT_ACT <> 'C'
               LOOP  
            ENDIF
            MPAGE_LEN = 56
         ELSE
            MPAGE_LEN = 20
         ENDIF
         SELECT A 
         DO FOX_USE WITH "PO_HEAD INDEX  PO_HEAD", .F.
         MSUB = 0
         STORE 0 TO MTOT_SELL, MTOT_NET, MTOT_COMM   
         STORE 0 TO MINV_SELL, MINV_NET, MINV_COMM
         
         SELECT A
         SEEK MSALESMAN
         MPAGE_NO = 0
         MLINE = 99 
         @ 19,16 SAY 'PROCESSING........'
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
            
            *** LETTER GOTHIC AND BOLDED PRINT
            ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
            
            *** LETTER SIZE PAPER
            ?? CHR(27) + '&l2A'
            
            *** PORTRAIT MODE
            ?? CHR(27) + '&l0O'
         ENDIF
         
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
            IF MBBUYCODE <> SPACE(4)
               IF BBUYCODE <> MBBUYCODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            IF SHIP_DATE < MSTART .OR. SHIP_DATE > MLAST
               SKIP
               LOOP
            ENDIF
            SELECT C
            SEEK A->BBUYCODE 
            IF EOF()
               APPEND BLANK
            ENDIF
            REPLACE RSUPCODE WITH A->BBUYCODE
            REPLACE TOT_NET WITH TOT_NET + A->TOT_NET
            REPLACE TOT_COMM WITH TOT_COMM + A->SALE_COMM
            REPLACE TOT_SELL WITH TOT_SELL + A->TOT_SELL + A->CUS_PALL
            IF A->RSUPCODE = 'INVN'
               REPLACE INV_NET WITH INV_NET + A->TOT_NET
               REPLACE INV_SELL WITH INV_SELL + A->TOT_SELL + A->CUS_PALL
               REPLACE INV_COMM WITH INV_COMM + A->SALE_COMM
            ENDIF
            SELECT A
            SKIP
         ENDDO
         SELECT A
         SELECT A 
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         
         SELECT C
         GOTO TOP
         MLINE = 99   
         DO WHILE .NOT. EOF()
            
            IF MLINE > MPAGE_LEN
               IF MLINE = 99 .AND. MDISP_PRT <> 'P'
                  CLEAR
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 1,40 SAY MCOMPANY
               @ 1,1 SAY 'Page'
               @ 1,06 say mpage_no picture '99'
               @ 1,70 SAY DTOC(DATE())
               @ 2,25 SAY 'CUSTOMER/SALESMAN TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
               @ 3,35 SAY MSAL_NAME
               @ 3,71 SAY TIME()
               IF MDISP_PRT = 'P'
                  @ 3,01 SAY REPLICATE('_',78)
               ENDIF
               @ 6,1 SAY 'CUSTOMER' 
               @ 6,33 SAY '   TOTAL SELLING'
               @ 6,51 SAY '   TOTAL NET'
               @ 6,66 SAY '   TOTAL COMM' 
               MLINE = 8
            ENDIF
            IF TOT_SELL = 0 .AND. TOT_NET = 0 .AND. TOT_COMM = 0
               SKIP
               LOOP
            ENDIF
            SELECT A
            SEEK C->RSUPCODE
            IF EOF()
               @ MLINE,1 SAY 'CUSTOMER NOT ON FILE:'+ C->RSUPCODE
            ELSE
               @ MLINE,1 SAY NAME
            ENDIF
            SELECT C
            @ MLINE,35 SAY TOT_SELL PICTURE '999,999,999.99' 
            @ MLINE,49 SAY TOT_NET  PICTURE '999,999,999.99'
            @ MLINE,65 SAY TOT_COMM PICTURE '999,999,999.99'
            
            MTOT_SELL = MTOT_SELL + TOT_SELL
            MTOT_NET = MTOT_NET + TOT_NET
            MTOT_COMM = MTOT_COMM + TOT_COMM
            MINV_SELL = MINV_SELL + INV_SELL
            MINV_NET  = MINV_NET + INV_NET
            MINV_COMM = MINV_COMM + INV_COMM
            
            MLINE = MLINE + 1
            SELECT A
            @ MLINE,1 SAY TRIM(CITY) + ', ' + STATE
            MLINE = MLINE + 2
            SELECT C
            SKIP
         ENDDO
         
         IF MLINE > MPAGE_LEN
            IF MDISP_PRT <> 'P'
               IF MLINE = 99 
                  CLEAR
               ELSE
                  STORE ' ' TO MWAIT
                  @ 24,0 SAY 'Press Return to Continue to Next Page ' GET MWAIT
                  READ
                  CLEAR    
               ENDIF
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,27 SAY MCOMPANY
            @ 1,1 SAY 'Page'
            @ 1,70 SAY DTOC(DATE())
            @ 1,06 say mpage_no picture '99'
            @ 2,25 SAY 'CUSTOMER/SALESMAN TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
            @ 3,35 SAY MSAL_NAME
            @ 3,71 SAY TIME()
            IF MDISP_PRT = 'P'
               @ 3,01 SAY REPLICATE('_',78)
            ENDIF
            @ 6,1 SAY 'CUSTOMER' 
            @ 6,33 SAY '   TOTAL SELLING'
            @ 6,51 SAY '   TOTAL NET'
            @ 6,66 SAY '   TOTAL COMM' 
            MLINE = 7
         ENDIF
         @ MLINE,05 SAY 'TOTALS:'
         @ MLINE,35 SAY MTOT_SELL PICTURE '999,999,999.99' 
         @ MLINE,49 SAY MTOT_NET  PICTURE '999,999,999.99'
         @ MLINE,65 SAY MTOT_COMM PICTURE '999,999,999.99'
         MLINE = MLINE + 2
         IF MINV_SELL <> 0 .OR. MINV_NET <> 0 .OR. MINV_COMM <> 0
            @ MLINE,05 SAY 'TOTALS FOR SALES FROM INVENTORY:'
            @ MLINE,35 SAY MINV_SELL PICTURE '999,999,999.99' 
            @ MLINE,49 SAY MINV_NET  PICTURE '999,999,999.99'
            @ MLINE,65 SAY MINV_COMM PICTURE '999,999,999.99'
            MLINE = MLINE + 1
            @ MLINE,05 SAY 'TOTALS FOR DIRECT SALES:'     
            @ MLINE,35 SAY MTOT_SELL - MINV_SELL PICTURE '999,999,999.99' 
            @ MLINE,49 SAY MTOT_NET - MINV_NET  PICTURE '999,999,999.99'
            @ MLINE,65 SAY MTOT_COMM - MINV_COMM PICTURE '999,999,999.99'
         ENDIF
         IF MDISP_PRT = 'P'
            MLINE = MLINE + 1
            @ MLINE+1,1 say ' '
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
      CASE MCHOICE = 'P'
         @ 4,1 CLEAR TO 21,78
         MYES_NO = 'NO '
         @ 10,5 SAY 'Do you want to select a specific Supplier/Customer (YES/NO)? ' get MYES_NO picture '@!'
         READ
         MRSUPCODE = SPACE(4)
         MBBUYCODE = SPACE(4)
         IF MYES_NO = 'YES'
            @ 10,1 SAY SPACE(78)
            MCHOICE = ' '
            @ 10,5 SAY 'Specific Supplier (S) or Customer (C) or Both(B)? ' get mchoice picture '@!' VALID (MCHOICE = 'S' .OR. MCHOICE = 'C' .OR. MCHOICE = 'B')
            READ
            @ 10,1 SAY SPACE(78)
            IF MCHOICE = 'S' .OR. MCHOICE = 'B'
               MNAME_FD = .F.
               DO RSUPSEL3
               IF  MNAME_FD
                  STORE RSUPCODE TO MRSUPCODE
                  STORE NAME TO MRSUPNAME
                  STORE CITY TO MRSUPCITY
                  STORE STATE TO MRSUPST   
               ENDIF
            ENDIF
            IF MCHOICE = 'C' .OR. MCHOICE = 'B'
               MNAME_FD = .F.
               DO BBUYSEL3
               IF  MNAME_FD
                  STORE BBUYCODE TO MBBUYCODE
                  STORE NAME TO MBBUYNAME
                  STORE CITY TO MBBUYCITY
                  STORE STATE TO MBBUYST   
               ENDIF
            ENDIF
            SELECT A
            USE
         ENDIF
         
         MTITLE = ' - SALESPERSON PRODUCT LISTING'
         CLEAR
         @  1, 1  SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         
         SELECT C
         INDEX ON SALESMAN + PROD_DESC + RSUPCODE + BBUYCODE  TO TEMPPROD
         DO FOX_USE WITH "TEMPPROD INDEX TEMPPROD", .F.
         DO FILELOCK
         
         *** REPORT IS TOTALED BY PRODUCT
         MPRT_ACT = 'C'
         
         IF MDISP_PRT = 'P'
            DO PRT_SET
            
            IF MPRT_ACT <> 'C'
               LOOP  
            ENDIF
            MPAGE_LEN = 56
         ELSE
            MPAGE_LEN = 20
         ENDIF
         STORE 0 TO MITM_SELL, MITM_NET, MITM_LBS
         
         SELECT A 
         DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP", .F.
         SELECT B
         DO FOX_USE WITH "PO_DTL INDEX  PO_DTL", .F.
         
         MSUB = 0
         STORE 0 TO MTOT_LBS, MTOT_SELL, MTOT_NET
         STORE 0 TO MINV_LBS, MINV_SELL, MINV_NET
         SELECT A
         SEEK MSTRT_YR + MSTRT_MO
         MPAGE_NO = 0
         MLINE = 99 
         @ 19,16 SAY 'PROCESSING........'
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
            
            *** LETTER GOTHIC AND BOLDED PRINT
            ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
            
            *** LETTER SIZE PAPER
            ?? CHR(27) + '&l2A'
            
            *** PORTRAIT MODE
            ?? CHR(27) + '&l0O'
            
         ENDIF
         
         DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MLAST  
            IF SHIP_DATE < MSTART
               SKIP 
               LOOP
            ENDIF
            IF MYES_NO = 'NO'
               IF BBUYCODE = 'INVN' .OR. BBUYCODE = 'REJE' 
                  SKIP
                  LOOP
               ENDIF
            ELSE  
               IF MBBUYCODE <> SPACE(4)
                  IF MBBUYCODE <> BBUYCODE
                     SKIP 
                     LOOP
                  ENDIF
               ENDIF
               IF MRSUPCODE <> SPACE(4)
                  IF MRSUPCODE <> RSUPCODE
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
            ENDIF
            
            IF TOT_SELL + CUS_PALL = 0
               SKIP
               LOOP
            ENDIF
            IF MSALESMAN <> '  '
               IF MSALESMAN <> SALESMAN
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT B
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
            DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR .AND. PO_SUFFIX = A->PO_SUFFIX
               IF MPROD <> SPACE(10)
                  IF MPROD <> PROD_DESC
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               IF A->SALESMAN = '  '
                  IF A->BROK_NAME = 'KEN' .OR. A->BROK_NAME = ' KEN'
                     MCODE = '02'
                  ELSE
                     IF A->BROK_NAME = 'BOB' .OR. A->BROK_NAME = ' BOB'
                        MCODE = '01'
                     ENDIF
                  ENDIF
               ELSE
                  MCODE = A->SALESMAN
               ENDIF
               
               SELECT C
               ***SEEK '    ' + B->PROD_DESC + MCODE
               SEEK MCODE + B->PROD_DESC + A->RSUPCODE+A->BBUYCODE
               IF EOF()
                  APPEND BLANK
                  REPLACE PROD_DESC WITH B->PROD_DESC
                  REPLACE SALESMAN WITH MCODE    
                  REPLACE BBUYCODE WITH A->BBUYCODE
                  REPLACE RSUPCODE WITH A->RSUPCODE
               ENDIF
               REPLACE TOT_LBS WITH TOT_LBS + B->LBS
               REPLACE TOT_SELL WITH TOT_SELL + B->TOT_SELL
               IF A->RSUPCODE = 'INVN'
                  REPLACE INV_LBS WITH INV_LBS + B->LBS
                  REPLACE INV_SELL WITH INV_SELL + B->TOT_SELL
               ENDIF
               IF A->TOT_LBS = 0
                  MFRT_LB = 0
               ELSE
                  MFRT_LB = (A->FRT_AMT1+A->FRT1_ADJ1+A->FRT1_ADJ2+A->FRT_PALL) / A->TOT_LBS
               ENDIF
               MITM_FRT = MFRT_LB * B->LBS
               IF B->BILL_PRI <> 0
                  REPLACE TOT_NET WITH TOT_NET + (B->TOT_SELL - B->TOT_BILL - MITM_FRT)
                  IF A->RSUPCODE = 'INVN'
                     REPLACE INV_NET WITH INV_NET + (B->TOT_SELL - B->TOT_BILL - MITM_FRT)
                  ENDIF
               ELSE
                  REPLACE TOT_NET WITH TOT_NET + (B->TOT_SELL - B->TOT_PURCH - MITM_FRT)
                  IF A->RSUPCODE = 'INVN'
                     REPLACE TOT_NET WITH TOT_NET + (B->TOT_SELL - B->TOT_PURCH - MITM_FRT)
                  ENDIF
               ENDIF
               SELECT B
               SKIP
            ENDDO
            SELECT A
            SKIP
         ENDDO
         
         
         SELECT F 
         DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
         SELECT D 
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
         
         SELECT E 
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         
         SELECT A 
         DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
         MHIGH_PROD = SPACE(10)
         MLOW_PROD = SPACE(10)
         MHIGH_NET = 0
         MLOW_NET = 0
         MITM_KB = 0
         MTOT_KB = 0
         MLINE = 99
         STORE 0 TO GTOT_LBS, GTOT_SELL, GTOT_NET
         STORE 0 TO GINV_LBS, GINV_SELL, GINV_NET
         
         DO WHILE .NOT. EOF()
            SELECT C
            SEEK A->SALE_CODE
            
            DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALE_CODE
               SELECT D
               SEEK C->RSUPCODE
               SELECT E
               SEEK C->BBUYCODE
               SELECT F
               SEEK 'R' + C->PROD_DESC
               SELECT C
               STORE PROD_DESC TO MPROD_DESC
               IF MLINE > MPAGE_LEN
                  IF MDISP_PRT = 'D'
                     IF MLINE = 99
                        CLEAR
                     ELSE
                        MCONT = 'C'
                        @ 24,1 SAY "PRESS 'ENTER' TO CONTINUE OR 'A' TO CANCEL REPORT " GET MCONT PICTURE '@!'
                        READ
                        IF MCONT = 'A'
                           SELECT C
                           GOTO BOTTOM
                           SKIP
                           LOOP
                        ELSE
                           CLEAR
                        ENDIF
                     ENDIF
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 1,25 SAY MCOMPANY
                  @ 1,1 SAY 'Page'
                  @ 1,06 say mpage_no picture '99'
                  @ 1,60 SAY DTOC(DATE())
                  @ 1,71 SAY TIME()
                  @ 2,16 SAY 'SALESMAN/PRODUCT TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
                  @ 3,25 SAY 'SALESMAN: ' + A->NAME
                  @ 4,08 SAY 'Note: Product Net = Selling - Purchase - Pro-rated Freight)'
                  @ 6,1 SAY 'PRODUCT/DESCRIPTION'     
                  @ 6,29 SAY '   TOTAL POUNDS' 
                  @ 6,47 SAY '  GROSS SALES $'
                  @ 6,65 SAY '    TOTAL NET $' 
                  IF MDISP_PRT = 'P'
                     @ 6,01 SAY REPLICATE('_',79)
                  ENDIF
                  MLINE = 8
               ENDIF
               @ MLINE,1 SAY 'SUPPLIER: '+ SUBSTR(D->NAME,1,20)
               IF MDISP_PRT <> 'D'
                  @ MLINE,1 SAY REPLICATE('_',8)
               ENDIF
               @ MLINE,41 SAY 'CUSTOMER: ' + SUBSTR(E->NAME,1,20)
               IF MDISP_PRT <> 'D'
                  @ MLINE,41 SAY REPLICATE('_',8)
               ENDIF
               MLINE = MLINE + 1
               @ MLINE,11  SAY TRIM(SUBSTR(D->CITY,1,16)) + ', ' + D->STATE
               @ MLINE,51 SAY TRIM(SUBSTR(E->CITY,1,16)) + ', ' + E->STATE
               MLINE = MLINE + 1
               @ MLINE,1 SAY PROD_DESC
               @ MLINE,7 SAY SUBSTR(F->DESC,1,20)
               
               SELECT C
               @ MLINE,29 SAY TOT_LBS   PICTURE '999,999,999,999' 
               @ MLINE,47 SAY TOT_SELL  PICTURE '999,999,999,999'
               @ MLINE,65 SAY TOT_NET   PICTURE '999,999,999,999'
               
               
               MTOT_SELL = MTOT_SELL + TOT_SELL 
               MTOT_NET  = MTOT_NET  + TOT_NET 
               MTOT_LBS  = MTOT_LBS  + TOT_LBS   
               GTOT_SELL = GTOT_SELL + TOT_SELL 
               GTOT_NET  = GTOT_NET  + TOT_NET 
               GTOT_LBS  = GTOT_LBS  + TOT_LBS   
               
               IF RSUPCODE = 'INVN'
                  MINV_SELL = MINV_SELL + TOT_SELL
                  MINV_NET  = MINV_NET  + TOT_NET
                  MINV_LBS  = MINV_LBS  + TOT_LBS
                  GINV_SELL = GINV_SELL + TOT_SELL
                  GINV_NET  = GINV_NET  + TOT_NET
                  GINV_LBS  = GINV_LBS  + TOT_LBS
               ENDIF
               
               MLINE = MLINE + 2
               SKIP
               
               *MX = (.4 * MITM_NET) + MITM_KB
               *IF MHIGH_NET = 0 .AND. MLOW_NET = 0
               *   STORE MX TO MHIGH_NET, MLOW_NET
               *   STORE MPROD_DESC TO MHIGH_PROD, MLOW_PROD
               *ENDIF
               *IF MX > MHIGH_NET
               *   STORE MX TO MHIGH_NET
               *   STORE MPROD_DESC TO MHIGH_PROD
               *ENDIF
               *IF MX < MLOW_NET
               *   STORE MX TO MLOW_NET
               *   STORE MPROD_DESC TO MLOW_PROD
               *ENDIF
               *STORE 0 TO MITM_SELL, MITM_NET, MITM_LBS, MITM_KB
               *MLINE = MLINE + 3
               *ENDIF
               
            ENDDO
            SELECT A
            SKIP
            IF .NOT. EOF()
               MLINE = 99
            ENDIF
         ENDDO
         
         IF MDISP_PRT = 'D'
            MCONT = 'C'
            @ 24,1 SAY "PRESS 'ENTER' TO CONTINUE OR 'A' TO CANCEL REPORT " GET MCONT PICTURE '@!'
            READ
            IF MCONT = 'A'
               SELECT C
               GOTO BOTTOM
               SKIP
               LOOP
            ELSE
               CLEAR
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,25 SAY MCOMPANY
            @ 1,1 SAY 'Page'
            @ 1,60 SAY DTOC(DATE())
            @ 1,71 SAY TIME()
            @ 1,06 say mpage_no picture '99'
            @ 2,16 SAY 'SALESMAN/PRODUCT TOTALS FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
            @ 3,25 SAY 'SALESMAN: ' + A->NAME
            @ 4,08 SAY 'Note: Product Net = Selling - Purchase - Pro-rated Freight)'
            @ 6,29 SAY '   TOTAL POUNDS' 
            @ 6,47 SAY '  GROSS SALES $'
            @ 6,65 SAY '    TOTAL NET $' 
            IF MDISP_PRT = 'P'
               @ 6,01 SAY REPLICATE('_',80)
            ENDIF
            MLINE = 8
         ELSE
            MLINE = MLINE + 2
         ENDIF
         @ MLINE,01 SAY 'GRAND TOTALS:'
         IF MDISP_PRT = 'P'
            @ MLINE,01 SAY REPLICATE('_',13)
         ENDIF
         GTOT_LBS = ROUND(GTOT_LBS,0)
         GTOT_SELL = ROUND(GTOT_SELL,0)
         GTOT_NET = ROUND(GTOT_NET,0)
         GINV_LBS = ROUND(GINV_LBS,0)
         GINV_SELL = ROUND(GINV_SELL,0)
         GINV_NET = ROUND(GINV_NET,0)
         @ MLINE,29 SAY GTOT_LBS   PICTURE '999,999,999,999'
         @ MLINE,47 SAY GTOT_SELL  PICTURE '999,999,999,999'
         *@ MLINE,65 SAY GTOT_NET + MTOT_KB   PICTURE '999,999,999,999'
         @ MLINE,65 SAY GTOT_NET   PICTURE '999,999,999,999'
         
         MLINE = MLINE + 2
         IF GINV_SELL <> 0 .OR. GINV_NET <> 0 .OR. GINV_LBS <> 0
            @ MLINE,02 SAY 'TOTALS FOR SALES FROM INVN:'
            @ MLINE,29 SAY GINV_LBS   PICTURE '999,999,999,999' 
            @ MLINE,47 SAY GINV_SELL  PICTURE '999,999,999,999'
            @ MLINE,65 SAY GINV_NET   PICTURE '999,999,999,999'
            MLINE = MLINE + 1
            @ MLINE,05 SAY 'TOTALS FOR DIRECT SALES:'     
            @ MLINE,29 SAY GTOT_LBS - GINV_LBS   PICTURE '999,999,999,999' 
            @ MLINE,47 SAY GTOT_SELL - GINV_SELL  PICTURE '999,999,999,999'
            @ MLINE,65 SAY GTOT_NET - GINV_NET   PICTURE '999,999,999,999'
            MLINE = MLINE + 1
         ENDIF
         
         *@ MLINE,1 SAY 'MIDWEST PROFIT:'
         *@ MLINE,65 SAY (.4 * MTOT_NET) + MTOT_KB PICTURE '999,999,999,999'
         *MLINE = MLINE + 2
         *@ MLINE,1 SAY 'MOST PROFITABLE: ' + MHIGH_PROD
         *@ MLINE,65 SAY MHIGH_NET  PICTURE '999,999,999,999'
         *MLINE = MLINE + 2
         *@ MLINE,1 SAY 'LEAST PROFITABLE: ' + MLOW_PROD
         *@ MLINE,65 SAY MLOW_NET   PICTURE '999,999,999,999'
         
         IF MDISP_PRT = 'P'
            MLINE = MLINE + 1
            @ MLINE+1,1 say ' '
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
      ENDCASE
      
      
   CASE VAL(MSELECTION) = 8 
      DO LBS_RPT
   ENDCASE
   
ENDDO

RETURN


PROCEDURE PROD_HD1
@ 1,20 SAY 'MIDWEST FOOD & POULTRY, INC. FOOD SERVICE' + SPACE(12) + DTOC(DATE())
MLINE = 2
@ MLINE,20 SAY 'PRODUCT SOLD BETWEEN ' + DTOC(MBEGIN) + ' - ' + DTOC(MEND)
MLINE = MLINE + 2
@ MLINE,0 SAY 'PRODUCT CODE  DESCRIPTION'
@ MLINE,60 SAY '  CASES'
@ MLINE,68 SAY '    POUNDS'
@ MLINE,79 SAY 'SELL $ %'
@ MLINE,79+9 SAY 'SELLING $'
@ MLINE,89+9 SAY '  NET $'
@ MLINE,0 SAY REPLICATE('_',105)  
MLINE = 6
RETURN

PROCEDURE PROD_HD2
@ 1,20 SAY 'MIDWEST FOOD & POULTRY, INC. FOOD SERVICE' + SPACE(12) + DTOC(DATE())
MLINE = 2
@ MLINE,20 SAY 'PRODUCT SOLD BETWEEN ' + DTOC(MBEGIN) + ' - ' + DTOC(MEND)
MLINE = MLINE + 2
@ MLINE,73 SAY 'SALE $'
@ MLINE,86 SAY 'NET $'
MLINE = MLINE + 1
@ MLINE,0 SAY 'PRODUCT CODE  DESCRIPTION'
@ MLINE,60 SAY '# CASES'
@ MLINE,72 SAY 'PERCENT'   
@ MLINE,84 SAY 'PERCENT'   
@ MLINE,0 SAY REPLICATE('_',90)  
MLINE = 7
RETURN

* EOF: PRODRPTS.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 2:18 PM.
