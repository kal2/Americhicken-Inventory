***************
* Program.: SALE_AGE.PRG
* Author..: GRACE KELLER
* Date....: 03/21/91
* Notice..: Copyright (C) 1991, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SALESPERSON AGING COMPARISON REPORT
*
CLEAR
@ 01,00 SAY MCOMPANY
@ 02,00 SAY MPROGRAM + ' - SALESPERSON AGING COMPARISON'
@ 02,70 SAY DATE()
@ 3,0 TO 22,79
STORE 2 TO MACTION      
STORE 'P' TO MDISP_PRT
DO WHILE MACTION = 2      
   @ 10,5 SAY 'Calculate (C) or Print (P) Report? ' GET MDISP_PRT PICTURE '@!'
   STORE 1 TO MACTION
   @ 24,00 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report/Finished'             
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
ENDDO
IF MACTION = 3
   MNOT_DONE = .F.
   RETURN
ENDIF  
@ 10,1 SAY SPACE(77)

DO CASE
CASE MDISP_PRT <> 'P'
   **** GET FIRST AND LAST DATES FOR THIS REPORT
   STORE CTOD(' ') TO MBEG_DATE, MEND_DATE
   @ 7,2 say  '  Starting Aging Date:'
   @ 9,2 SAY  '    Ending Aging Date: ' 
   STORE 'PLEASE SELECT REPORT OPTIONS....' TO MGET
   @ 20,16 GET MGET
   CLEAR GETS
   STORE 2 TO MACTION      
   DO WHILE MACTION = 2      
      @ 07,25 GET MBEG_DATE PICTURE '##'
      @ 09,25 GET MEND_DATE PICTURE '##'
      STORE 1 TO MACTION
      @ 24,00 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report/Finished'             
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      
      IF MACTION = 1
         IF DTOC(MBEG_DATE) = '  /  /  ' .OR. DTOC(MEND_DATE) = '  /  /  '
            @ 23,0 CLEAR
            mwait = ' '
            @ 23,1 SAY 'Only One Date Entered - Both Begin and End Dates Must be Entered'
            @ 24,1 say 'Press Any Key to Reenter ' get mwait
            READ
            MACTION = 2
            @ 23,0 clear
            RETURN
         ENDIF
      ENDIF
   ENDDO
   IF MACTION = 3
      MNOT_DONE = .F.
      RETURN
   ENDIF  
   @ 20,1 SAY SPACE(77)
   @ 20,16 SAY 'PROCESSING........'
   
   SELECT A 
   DO FOX_USE WITH "TOTALS", .F.
   DO FILELOCK
   USE TOTALS EXCLUSIVE
   DELETE ALL
   PACK
   INDEX ON SALESMAN TO TMP_TOT
   DO FOX_USE WITH "TOTALS INDEX TMP_TOT", .F.
   DO FILELOCK
   
   STORE MONTH(MBEG_DATE) TO MMONTH
   MMONTH = MMONTH + 100
   STORE SUBSTR(STR(MMONTH,3),2) TO MMONTH
   
   STORE YEAR(MBEG_DATE) TO MYEAR
   STORE STR(MYEAR,4) TO MYEAR
   
   SELECT C
   DO FOX_USE WITH "PAYMENTS INDEX PAY_PO", .F.
   SELECT D
   DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP", .F.
   
   @ 4,1 CLEAR TO 20,78
   @ 17,15 SAY 'CALCULATING CUSTOMER AGING DAYS - PLEASE WAIT...'
   
   SELECT D
   SEEK MYEAR + MMONTH
   DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MEND_DATE
      IF SHIP_DATE < MBEG_DATE
         SKIP
         LOOP
      ENDIF
      
      IF BBUYCODE = 'NONE' .OR. BBUYCODE = 'INVN' .OR. (TOT_SELL+CUS_PALL) = 0 .OR. TOT_LBS = 0
         SKIP
         LOOP
      ENDIF
      
      IF SALESMAN = '  '
         DO CASE
         CASE BROK_NAME = 'KEN' .OR. BROK_NAME = ' KEN'
            MSALESMAN = '02'
         CASE BROK_NAME = 'BOB' .OR. BROK_NAME = ' BOB'
            MSALESMAN = '01'
         OTHERWISE
            MSALESMAN = '  '
         ENDCASE
      ELSE
         MSALESMAN = SALESMAN
      ENDIF
      
      SELECT C
      SEEK D->SALESMAN + D->PO_NBR + D->PO_SUFFIX
      IF .NOT. EOF()
         MDAYS = (PAID_DATE - D->SHIP_DATE)
         SELECT A
         SEEK MSALESMAN
         IF EOF()
            APPEND BLANK
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE END_DATE WITH MEND_DATE
            REPLACE BEG_DATE WITH MBEG_DATE
         ENDIF     
         REPLACE NBR_SHIPS WITH NBR_SHIPS + 1
         REPLACE NBR_DAYS WITH NBR_DAYS + MDAYS
      ENDIF
      SELECT D
      SKIP
   ENDDO
   
OTHERWISE
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
   
   SELECT A
   DO FOX_USE WITH "TOTALS INDEX TMP_TOT", .F.
   SUM NBR_SHIPS TO TNBR_SHIPS
   SUM NBR_DAYS  TO TNBR_DAYS
   
   @ 2,78 SAY DTOC(DATE())
   @ 2,32 SAY 'MIDWEST FOOD AND POULTRY'
   
   GOTO TOP
   @ 3,30 SAY 'AGING PERCENTAGE COMPARISONS'
   @ 4,33 SAY  DTOC(BEG_DATE) + ' THRU ' + DTOC(END_DATE)
   @ 9,1 SAY 'SALESPERSON            NBR SHIPMENTS     NBR COLLECTION DAYS     AVG NBR COLLECTION DAYS'
   
   **1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234556789012345678901234567890
   **10        20        30        40        50        60        70        80        90
   **12345678901234567890       99,999              99,999,999                  XXX.XX                       
   
   @ 9,01 SAY REPLICATE('_',88)
   MLINE = 11
   
   SELECT B 
   DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
   
   DO WHILE .NOT. EOF()
      STORE NAME TO MNAME
      SELECT A
      SEEK B->SALE_CODE 
      IF EOF()
         SELECT B
         SKIP
         LOOP
      ENDIF
      @ MLINE,1 SAY SUBSTR(MNAME,1,20)        
      SELECT A
      IF NBR_SHIPS <> 0 .AND. NBR_DAYS <> 0
         MAGING = NBR_DAYS/NBR_SHIPS
      ELSE
         MAGING = 0
      ENDIF
      
      @ MLINE,28 SAY NBR_SHIPS PICTURE '99,999'
      @ MLINE,48 SAY NBR_DAYS PICTURE '99,999,999'
      @ MLINE,76 SAY MAGING PICTURE '999.99'
      
      MLINE = MLINE + 3
      
      SELECT B
      SKIP
   ENDDO
   
   MLINE = MLINE + 4
   
   @ MLINE,1 SAY 'ALL OFFICES'
   @ MLINE,1 SAY REPLICATE('_',11)
   IF TNBR_SHIPS <> 0 .AND. TNBR_DAYS <> 0
      MAGING = TNBR_DAYS/TNBR_SHIPS
   ELSE
      MAGING = 0
   ENDIF
   
   
   @ MLINE,28 SAY TNBR_SHIPS PICTURE '99,999'
   @ MLINE,48 SAY TNBR_DAYS PICTURE '99,999,999'
   @ MLINE,76 SAY MAGING PICTURE '999.99'
   
   @ MLINE+1,0 SAY ' '
   EJECT
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
ENDCASE
CLOSE DATA
RETURN
*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 4:49 PM.
