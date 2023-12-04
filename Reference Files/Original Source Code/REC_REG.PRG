********************
* Program.: REC_REG.PRG
* Author..: GRACE KELLER
* Date....: 01/08/88
* Notice..: Copyright (C) 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: RECEIPTS REGISTER FILE 
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
STORE ' ' TO MSELECTION
STORE ' ' TO MACTION
STORE SPACE(4) TO MBBUYCODE
MOPT_CUST = ' '
MTITLE = ' - RECEIPTS REGISTER/TOTALS'
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
STORE 'REGULAR    ' TO MREGISTER
@ 08,05 SAY 'Select one of the following receipt register print options:'    
@ 10,05 say 'REGULAR format'       
@ 11,05 say 'SALESPERSON format'
@ 12,05 say 'TOTALS by day format'
@ 13,05 SAY 'DATABASES together format'
@ 16,06 say 'Enter print format: ' get mregister picture '@!'

READ
@ 08,1 clear to 17,78

DO CASE
CASE  MREGISTER = 'DATABASES'
   DO REC_REG2
CASE  MREGISTER = 'REGULAR' .OR. MREGISTER = 'TOTALS'
   **** GET DATE FOR THIS REPORT
   STORE DATE() TO MDATE, MEND_DATE
   STORE 'P' TO MDISP_PRT
   STORE 'NO ' TO MOPT_CUST, MLONG_SHRT
   STORE 2 TO MACTION      
   STORE '**' TO MCODE
   STORE ' ' TO MLOC_CODE       
   DO WHILE MACTION = 2      
      @ 08,5 SAY 'BEGIN REPORT DATE: '
      @ 08,24 GET MDATE
      @ 10,5 SAY '  END REPORT DATE: ' 
      @ 10,24 GET MEND_DATE
      IF MREGISTER = 'REGULAR'
         @ 12,5 SAY 'SALESPERSON CODE: '
         @ 12,24 GET MCODE 
         @ 13,5 SAY " (ENTER '**' IF REPORT DESIRED FOR ALL SALESPERSONS)"
         @ 15,5 SAY 'SELECT SPECIFIC CUSTOMER (YES/NO)? ' GET MOPT_CUST PICTURE '@!'
         @ 17,5 SAY 'SELECT ONLY THOSE PAYMENTS THAT ARE SHORT/LONG (YES/NO)? ' GET MLONG_SHRT PICTURE '@!'
         IF MPROG_CODE = 1
            @ 19,5 SAY 'OPTIONAL LOCATION CODE:'
            @ 19,29 GET MLOC_CODE PICTURE '@!'
         ENDIF
      ELSE
         @ 15,5 SAY 'SELECT SPECIFIC CUSTOMER (YES/NO)? ' GET MOPT_CUST PICTURE '@!'
      ENDIF
      STORE 1 TO MACTION
      @ 23,00 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 1
         IF DTOC(MDATE) = '  /  /  ' .OR. DTOC(MEND_DATE) = '  /  /  '
            @ 24,0 CLEAR
            mwait = ' '
            @ 24,1 SAY 'BOTH DATES NOT ENTERED - PRESS ANY KEY TO REENTER' GET MWAIT
            READ
            MACTION = 2
            @ 24,0 CLEAR
            RETURN
         ENDIF
      ENDIF
   ENDDO
   
   IF MACTION = 3
      RETURN
   ENDIF  
   IF MOPT_CUST = 'YES'
      MNAME_FD = .F.
      DO BBUYSEL3
      IF .NOT. MNAME_FD
         RETURN
      ENDIF
      STORE BBUYCODE TO MBBUYCODE
   ENDIF
   
   MPRT_ACT = 'C'
   
   IF MDISP_PRT = 'P'
      DO PRT_SET
      
      IF MPRT_ACT <> 'C'
         RETURN 
      ENDIF
      MPAGE_LEN = 56
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
   
   SELECT E
   DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
   
   SELECT C
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
   
   SELECT A
   DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE, PAY_PO", .F.
   SEEK MYEAR + MMONTH + MDAY  
   IF EOF()
      SEEK MYEAR+MMONTH
      IF EOF()
         @ 4,1 CLEAR TO 21,78 
         @ 10,5 SAY 'THERE IS NO PAYMENT DATA ON FILE FOR THIS MONTH/YEAR'
         STORE ' ' TO MWAIT
         @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
         READ
         RETURN
      ELSE 
         DO WHILE .NOT. EOF() .AND. PAID_DATE < MDATE
            SKIP
         ENDDO
      ENDIF
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
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
   ENDIF
   
   MTOTAL = 0
   MTOT_CRED = 0
   MTOT_MISC = 0
   ** LOC_CODE = 'L' - LOCKBOX
   ** LOC_CODE = 'B' - LOCAL BANK      
   ** LOC_CODE = 'G' - GREAT WESTERN - FOOD SERVICE - CA
   ** LOC_CODE = 'Y' - YUMA, AZ - BANK 1
   MTLOCKBOX = 0
   MTLOCBANK = 0
   MTGRTWEST = 0
   MTYUMA    = 0
   MTOTHER   = 0
   DO CASE
   CASE MREGISTER = 'REGULAR'
      DO WHILE .NOT. EOF() .AND. PAID_DATE <= MEND_DATE
         IF MCODE <> '**'     
            IF SALESMAN <> MCODE
               SKIP
               LOOP
            ENDIF
         ENDIF
         IF MOPT_CUST = 'YES'
            IF MBBUYCODE <> BBUYCODE
               SKIP 
               LOOP
            ENDIF
         ENDIF
         IF MLONG_SHRT = 'YES'
            IF AMT_OVER = 0 .AND. CRED_AMT = 0
               SKIP
               LOOP
            ENDIF
         ENDIF
         STORE 0 TO MCUS_RECV, MCUS_CRED, MCUS_MISC
         MLASTSALES = SALESMAN 
         MLASTBBUY  = BBUYCODE
         DO WHILE .NOT. EOF() .AND. SALESMAN = MLASTSALES .AND. BBUYCODE = MLASTBBUY .AND. PAID_DATE <= MEND_DATE
            IF MLOC_CODE <> ' '
               IF MLOC_CODE <> LOC_CODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
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
               IF MDATE = MEND_DATE
                  @ 2,30 SAY 'RECEIPTS REGISTER FOR ' + DTOC(MDATE)
               ELSE 
                  @ 2,22 SAY 'RECEIPTS REGISTER FOR ' + DTOC(MDATE) + ' THRU ' + DTOC(MEND_DATE)
               ENDIF
               @ 2,80 SAY DTOC(DATE())
               IF MDATE = MEND_DATE
                  @ 4,0 SAY 'INV #  PO NBR     REMITTER                   CHECK#  RECEIVABLE  CREDIT AMT      MISC.   BALANCE'
               ELSE
                  @ 4,0 SAY 'INV #  PO NBR     REMITTER                   CHECK#  RECEIVABLE  CREDIT AMT      MISC.  DEP DATE'
               ENDIF
               IF MDISP_PRT = 'P'
                  @ 4,0 SAY REPLICATE ('_',96)
               ELSE
                  @ 5,0 SAY REPLICATE ('-',80)
               ENDIF
               MLINE = 6
            ENDIF
            
            STORE SALESMAN TO MSALESMAN
            STORE PO_NBR TO MPO_NBR
            STORE PO_SUFFIX TO MPO_SUFFIX
            STORE BBUYCODE TO MBBUYCODE
            STORE SPACE(7) TO MCK_NBR
            STORE INV_NBR TO MINV_NBR
            
            IF MBBUYCODE = SPACE(4) 
               SELECT E
               SEEK A->ACCOUNT
               IF .NOT. EOF()
                  STORE DESCRIP TO MBBUYNAME
               ELSE
                  STORE 'ACCOUNT NOT ON FILE' TO MBBUYNAME
               ENDIF
               SELECT A
               STORE 'MISC' TO MCK_NBR
            ELSE
               IF MBBUYCODE = 'NONE'
                  STORE 'NONE' TO MBBUYNAME
               ELSE  
                  IF A->ACCOUNT <> '151 ' .AND. A->ACCOUNT <> '152 '
                     SELECT B
                     DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
                     SEEK MBBUYCODE
                     IF .NOT. EOF()
                        STORE NAME TO MBBUYNAME
                     ELSE 
                        STORE 'NOT ON FILE' TO MBBUYNAME
                     ENDIF
                  ELSE
                     IF A->ACCOUNT = '151 '
                        SELECT B
                        DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
                        SEEK MBBUYCODE
                        IF .NOT. EOF()
                           STORE NAME TO MBBUYNAME
                        ELSE 
                           STORE 'NOT ON FILE' TO MBBUYNAME
                        ENDIF
                     ELSE
                        SELECT B
                        DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
                        SEEK MBBUYCODE
                        IF .NOT. EOF()
                           STORE NAME TO MBBUYNAME
                        ELSE 
                           STORE 'NOT ON FILE' TO MBBUYNAME
                        ENDIF
                     ENDIF
                  ENDIF
               ENDIF
               
               SELECT A
            ENDIF
            
            @ MLINE,0  SAY MINV_NBR
            IF MSALESMAN <> SPACE(2)
               @ MLINE,07 SAY MSALESMAN + '-' + MPO_NBR
            ELSE
               @ MLINE,10 SAY MPO_NBR
            ENDIF
            IF MPO_SUFFIX <> ' '
               @ MLINE,14 SAY '-' + PO_SUFFIX
            ENDIF
            @ MLINE,18 SAY SUBSTR(MBBUYNAME,1,25)
            @ MLINE,45 SAY CK_NBR
            @ MLINE,53 SAY AMT_PAID PICTURE '9999999.99'
            @ MLINE,65 SAY CRED_AMT PICTURE '@Z 9999999.99'
            @ MLINE,76 SAY AMT_OVER PICTURE '@Z 9999999.99'
            
            MCUS_RECV = MCUS_RECV + AMT_PAID
            MCUS_CRED = MCUS_CRED + CRED_AMT
            MCUS_MISC = MCUS_MISC + AMT_OVER
            DO CASE
            CASE LOC_CODE = 'L'
               MTLOCKBOX = MTLOCKBOX + AMT_PAID + CRED_AMT + AMT_OVER
            CASE LOC_CODE = 'B'
               MTLOCBANK = MTLOCBANK + AMT_PAID + CRED_AMT + AMT_OVER
            CASE LOC_CODE = 'G'
               MTGRTWEST = MTGRTWEST + AMT_PAID + CRED_AMT + AMT_OVER
            CASE LOC_CODE = 'Y'
               MTYUMA    = MTYUMA    + AMT_PAID + CRED_AMT + AMT_OVER
            OTHERWISE
               MTOTHER   = MTOTHER   + AMT_PAID + CRED_AMT + AMT_OVER
            ENDCASE
            IF MDATE = MEND_DATE
               IF ACCOUNT = SPACE(4)
                  SELECT C
                  SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
                  MTOT_SELL = TOT_SELL + CUS_PALL
                  SELECT A
                  STORE RECNO() TO MRECNO
                  MPO_PAID = 0
                  SET ORDER TO 2
                  SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
                  DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
                     MPO_PAID = MPO_PAID + AMT_PAID + AMT_OVER + CRED_AMT
                     SKIP
                  ENDDO
                  
                  MBALANCE = MTOT_SELL - MPO_PAID
                  SET ORDER TO 1
                  GOTO MRECNO
                  IF MBALANCE >= .01  .OR. MBALANCE <= .01
                     ** ADDED 11/06/90 ADDED CHECK TO PRINT CR
                     IF MBALANCE < 0
                        @ MLINE,87 SAY -1 * MBALANCE PICTURE '@Z 999999.99'
                        @ MLINE,97 SAY 'Cr'
                     ELSE
                        @ MLINE,87 SAY MBALANCE PICTURE '@Z 999999.99'
                     ENDIF
                     *** @ MLINE,87 SAY -1 * MBALANCE PICTURE '@Z 999999.99'
                  ENDIF
               ENDIF
            ELSE
               @ MLINE,88 SAY SUBSTR(DTOC(PAID_DATE),1,6) + SUBSTR(DTOC(PAID_DATE),9,2)
            ENDIF
            MLINE = MLINE + 2
            SELECT A
            SKIP
         ENDDO
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
            IF MDATE = MEND_DATE
               @ 2,30 SAY 'RECEIPTS REGISTER FOR ' + DTOC(MDATE)
            ELSE 
               @ 2,22 SAY 'RECEIPTS REGISTER FOR ' + DTOC(MDATE) + ' THRU ' + DTOC(MEND_DATE)
            ENDIF
            @ 2,70 SAY DTOC(DATE())
            IF MDATE = MEND_DATE
               @ 4,0 SAY 'INV #  PO NBR     REMITTER                   CHECK#  RECEIVABLE  CREDIT AMT      MISC.   BALANCE'
            ELSE
               @ 4,0 SAY 'INV #  PO NBR     REMITTER                   CHECK#  RECEIVABLE  CREDIT AMT      MISC.  DEP DATE'
            ENDIF
            IF MDISP_PRT = 'P'
               @ 4,0 SAY REPLICATE ('_',96)
            ELSE
               @ 5,0 SAY REPLICATE ('-',80)
            ENDIF
            MLINE = 6
         ENDIF
         IF MDATE = MEND_DATE
            @ MLINE,18 SAY '** SUBTOTAL **'
            @ MLINE,52 SAY MCUS_RECV PICTURE '99999999.99'
            @ MLINE,64 SAY MCUS_CRED PICTURE '@Z 99999999.99'
            @ MLINE,75 SAY MCUS_MISC PICTURE '@Z 99999999.99'
            @ MLINE,52 SAY REPLICATE('_',34)
            MLINE = MLINE + 3 
         ENDIF
         MTOTAL = MTOTAL + MCUS_RECV
         MTOT_CRED = MTOT_CRED + MCUS_CRED
         MTOT_MISC = MTOT_MISC + MCUS_MISC
      ENDDO
      IF MDISP_PRT = 'P'
         @ MLINE,0 SAY 'TOTAL RECEIPTS:'
         @ MLINE,52 SAY MTOTAL PICTURE '99999999.99'
         @ MLINE,64 SAY MTOT_CRED PICTURE '@Z 99999999.99'
         @ MLINE,75 SAY MTOT_MISC PICTURE '@Z 99999999.99'
         MLINE = MLINE + 2
         IF MTLOCKBOX <> 0 .OR. MLOC_CODE = ' '
            @ MLINE,0 SAY 'LOCKBOX: '
            @ MLINE,52 SAY MTLOCKBOX PICTURE '99999999.99'
            MLINE = MLINE + 1
         ENDIF
         IF MTLOCBANK <> 0 .OR. MLOC_CODE = ' '
            @ MLINE,0 SAY 'LOCAL BANK: '
            @ MLINE,52 SAY MTLOCBANK PICTURE '99999999.99'
            MLINE = MLINE + 1
         ENDIF
         *IF MTGRTWEST <> 0 .OR. MLOC_CODE = ' '
         *   @ MLINE,1 SAY 'GREAT WESTERN BANK- CA: '
         *   @ MLINE,53 SAY MTGRTWEST PICTURE '99999999.99'
         *   MLINE = MLINE + 1
         *ENDIF
         *IF MTYUMA    <> 0 .OR. MLOC_CODE = ' '
         *   @ MLINE,1 SAY 'YUMA, AZ - BANK 1: '
         *   @ MLINE,53 SAY MTYUMA  PICTURE '99999999.99'
         *   MLINE = MLINE + 1
         *ENDIF
         IF MTOTHER <> 0
            @ MLINE,0 SAY 'UNKNOWN RECEIPT LOCATION: '
            @ MLINE,52 SAY MTOTHER PICTURE '99999999.99'
            MLINE = MLINE + 1
         ENDIF
         
         IF MLOC_CODE = ' '
            @ MLINE,0 SAY 'GRAND TOTAL ALL LOCATIONS:'
            @ MLINE,52 SAY MTOTAL + MTOT_CRED + MTOT_MISC PICTURE '99999999.99'
            MLINE = MLINE + 1
         ENDIF
         @ MLINE,1 say ' '
         EJECT
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
      ELSE
         IF MLINE > MPAGE_LEN
            @ 6,0 CLEAR
            MLINE = 6
         ENDIF
         @ MLINE,0 SAY '    TOTAL RECEIPTS:'
         @ MLINE,65 SAY MTOTAL PICTURE '9,999,999.99'
         MPRT_SEL = ' '
         @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
         READ
      ENDIF
      CLOSE DATA
   OTHERWISE
      TLOCKBOX  = 0
      TLOCBANK  = 0
      TGRTWEST  = 0
      TYUMA     = 0 
      TOTHER    = 0
      DO WHILE .NOT. EOF() .AND. PAID_DATE <= MEND_DATE
         STORE PAID_DATE TO MDATE
         MLOCKBOX  = 0
         MLOCBANK  = 0
         MGRTWEST  = 0
         MYUMA     = 0
         MOTHER    = 0
         DO WHILE .NOT. EOF() .AND. PAID_DATE <= MEND_DATE .AND. PAID_DATE = MDATE
            IF MBBUYCODE <> SPACE(4)
               IF BBUYCODE  <> MBBUYCODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            DO CASE
            CASE ACCOUNT = '8397' .OR. ACCOUNT = '8599'
               MOTHER   = MOTHER   + AMT_PAID + CRED_AMT + AMT_OVER
            CASE LOC_CODE = 'L'
               MLOCKBOX = MLOCKBOX + AMT_PAID + CRED_AMT + AMT_OVER
            CASE LOC_CODE = 'B'
               MLOCBANK = MLOCBANK + AMT_PAID + CRED_AMT + AMT_OVER
            CASE LOC_CODE = 'G'
               MGRTWEST = MGRTWEST + AMT_PAID + CRED_AMT + AMT_OVER
            CASE LOC_CODE = 'Y'
               MYUMA    = MYUMA    + AMT_PAID + CRED_AMT + AMT_OVER
            OTHERWISE
               MOTHER   = MOTHER   + AMT_PAID + CRED_AMT + AMT_OVER
            ENDCASE
            SKIP
         ENDDO
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
            @ 2,05 SAY MPAGE_NO PICTURE '99'
            IF MDATE = MEND_DATE
               @ 2,30 SAY 'RECEIPTS REGISTER FOR ' + DTOC(MDATE)
            ELSE 
               @ 2,22 SAY 'RECEIPTS REGISTER FOR ' + DTOC(MDATE) + ' THRU ' + DTOC(MEND_DATE)
            ENDIF
            @ 2,70 SAY DTOC(DATE())
            **@ 4,1 SAY 'DEPOSIT DATE          LOCK BOX      LOCAL BANK      GREAT WEST         YUMA      LOAN/TR'
            @ 4,1 SAY 'DEPOSIT DATE          LOCK BOX      LOCAL BANK                                   LOAN/TR'
            IF MDISP_PRT = 'P'
               @ 4,0 SAY REPLICATE ('_',47)
               @ 4,80 SAY REPLICATE('_',10)
            ELSE
               @ 5,0 SAY REPLICATE ('-',47)
            ENDIF
            MLINE = 6
         ENDIF
         @ MLINE,3 SAY MDATE     
         @ MLINE,19 SAY MLOCKBOX  PICTURE '9,999,999.99'
         @ MLINE,35 SAY MLOCBANK  PICTURE '9,999,999.99'
         **@ MLINE,51 SAY MGRTWEST  PICTURE '9,999,999.99'
         **@ MLINE,65 SAY MYUMA     PICTURE '9,999,999.99'
         @ MLINE,77 SAY MOTHER    PICTURE '9,999,999.99'
         
         MLINE = MLINE + 2
         TLOCKBOX = TLOCKBOX + MLOCKBOX
         TLOCBANK = TLOCBANK + MLOCBANK
         TGRTWEST = TGRTWEST + MGRTWEST
         TYUMA    = TYUMA    + MYUMA
         TOTHER   = TOTHER   + MOTHER
      ENDDO
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
                  RETURN
               ENDIF
               CLEAR
            ENDIF
         ENDIF
         IF MLINE = 99 .AND. MDISP_PRT <> 'P'
            CLEAR
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
      ENDIF
      
      IF MDISP_PRT = 'P'
         @ MLINE,1 SAY 'TOTALS:'          
         @ MLINE,19 SAY TLOCKBOX  PICTURE '9,999,999.99'
         @ MLINE,35 SAY TLOCBANK  PICTURE '9,999,999.99'
         *@ MLINE,51 SAY TGRTWEST  PICTURE '9,999,999.99'
         *@ MLINE,65 SAY TYUMA     PICTURE '9,999,999.99'
         @ MLINE,77 SAY TOTHER    PICTURE '9,999,999.99'
         MLINE = MLINE + 2
         @ MLINE,1 SAY 'GRAND TOTALS:'
         @ MLINE,17 SAY TLOCKBOX+TLOCBANK+TGRTWEST+TOTHER+TYUMA PICTURE '999,999,999.99'             
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
         IF MLINE > MPAGE_LEN
            @ 6,0 CLEAR
            MLINE = 6
         ENDIF
         @ MLINE,1 SAY 'TOTAL RECEIPTS:'
         @ MLINE,17 SAY TCUS_RECV PICTURE '@Z 9,999,999.99'
         @ MLINE,36 SAY TCUS_CRED PICTURE '@Z 9,999,999.99'
         @ MLINE,49 SAY TCUS_MISC PICTURE '@Z 9,999,999.99'
         MPRT_SEL = ' '
         @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
         READ
      ENDIF
      CLOSE DATA
   ENDCASE
   
OTHERWISE    
   
   MTITLE = ' - RECEIPTS REGISTER/TOTALS - BY SALESPERSON'
   CLEAR
   @  1, 1  SAY MCOMPANY
   @  1,68 SAY DATE()
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   **** GET DATE FOR THIS REPORT
   STORE DATE() TO MBEGIN, MEND
   STORE 'D' TO MDISP_PRT
   STORE SPACE(2) TO MCODE
   STORE 'NO ' TO MOPT_CUST, MOPT_CRED
   STORE 1  TO MTIMES
   STORE 2 TO MACTION      
   DO WHILE MACTION = 2      
      @ 08,5 SAY 'BEGIN REPORT DATE: '
      @ 08,24 GET MBEGIN    
      @ 10,5 SAY ' END REPORT DATE: '
      @ 10,24 GET MEND
      @ 12,5 SAY 'SALESPERSON CODE: '
      @ 12,24 GET MCODE               
      @ 13,5 SAY " (ENTER '**' IF REPORT DESIRED FOR ALL SALESPERSONS)"
      STORE 1 TO MACTION
      @ 23,00 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 1
         IF DTOC(MBEGIN) = '  /  /  ' .OR. DTOC(MEND) = '  /  /  '
            @ 24,0 CLEAR
            mwait = ' '
            @ 24,1 SAY 'BOTH DATES NOT ENTERED -  PRESS ANY KEY TO REENTER' GET MWAIT
            READ
            MACTION = 2
            @ 24,0 CLEAR
            RETURN
         ENDIF
      ENDIF
   ENDDO
   
   IF MACTION = 3
      RETURN
   ENDIF  
   
   MPRT_ACT = 'C'
   
   DO PRT_SET
   
   IF MPRT_ACT <> 'C'
      RETURN
   ENDIF
   MPAGE_LEN = 44
   
   STORE MONTH(MBEGIN) TO MMONTH
   MMONTH = MMONTH + 100
   STORE SUBSTR(STR(MMONTH,3),2) TO MMONTH
   
   STORE YEAR(MBEGIN) TO MYEAR
   STORE STR(MYEAR,4) TO MYEAR
   
   STORE DAY(MBEGIN) TO MDAY
   MDAY = MDAY + 100
   STORE SUBSTR(STR(MDAY,3),2) TO MDAY
   SELECT C
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
   SELECT E
   DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
   
   SELECT A
   DO FOX_USE WITH "PAYMENTS INDEX PAY_CUST, PAY_PO", .F.
   SEEK MYEAR + MMONTH + MDAY  
   IF EOF()
      SEEK MYEAR+MMONTH
      IF EOF()
         @ 4,1 CLEAR TO 21,78 
         @ 10,5 SAY 'THERE IS NO PAYMENT DATA ON FILE FOR THIS MONTH/YEAR'
         STORE ' ' TO MWAIT
         @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
         READ
         RETURN
      ELSE 
         DO WHILE .NOT. EOF() .AND. SYS_DATE < MBEGIN 
            SKIP
         ENDDO
      ENDIF
   ENDIF
   MPAGE_NO = 0
   MLINE = 99 
   MDISP_PRT = 'P'
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
   
   MTOTAL = 0
   MMISC = 0
   MTOT_DIFF = 0
   DO WHILE .NOT. EOF() .AND. SYS_DATE <= MEND      
      IF MCODE <> '**'
         IF SALESMAN <> MCODE
            SKIP
            LOOP
         ENDIF
      ENDIF
      IF DEB_CRD <> ' '
         SKIP
         LOOP
      ENDIF
      STORE SALESMAN TO MSALESMAN
      SELECT B
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      SEEK MSALESMAN
      IF EOF()
         STORE 'SALES CODE NOT ON FILE' TO MSAL_NAME
      ELSE
         STORE NAME   TO MSAL_NAME
      ENDIF
      STORE 0 TO MINV_TOT, MPAID_TOT, MTOT_DUE, MTOT_DIFF
      SELECT A
      DO WHILE .NOT. EOF() .AND. SYS_DATE <= MEND .AND. SALESMAN = MSALESMAN
         
         IF DEB_CRD <> ' '
            SKIP
            LOOP
         ENDIF
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
            @ 2,22 SAY 'RECEIPTS REGISTER FOR ' + DTOC(MBEGIN) + ' THRU ' + DTOC(MEND)
            @ 2,85 SAY DTOC(DATE())
            @ 3,34 SAY 'SALESPERSON: ' + MSAL_NAME
            @ 5,0 SAY 'INV NBR'
            @ 5,10 SAY 'PO NUMBER'
            @ 5,21 SAY 'REMITTER' 
            @ 5,40 SAY 'CHK NBR'
            @ 5,49 SAY 'INVOICE AMT'
            @ 5,66 SAY 'AMT DUE'
            @ 5,78 SAY 'PAID AMT'
            @ 5,92 SAY 'BALANCE'
            IF MDISP_PRT = 'P'
               @ 5,0 SAY REPLICATE ('_',99)
            ELSE
               @ 6,0 SAY REPLICATE ('-',80)
            ENDIF
            MLINE = 7
         ENDIF
         
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         STORE BBUYCODE TO MBBUYCODE
         STORE SPACE(7) TO MCK_NBR
         *** ACCOUNTS 151 AND 152 ARE A/P CROSSOVER RECEIPTS
         *** DO NOT NEED TO CHECK FOR ALL THE RECEIPTS
         IF A->ACCOUNT <> '151 ' .AND. A->ACCOUNT <> '152 '
            SELECT C
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF EOF()
               STORE 0 TO MTOT_SELL
            ELSE
               MTOT_SELL = TOT_SELL + CUS_PALL
            ENDIF
            STORE 0 TO MTOTAL
            SELECT A
            STORE RECNO() TO MRECNO
            SET ORDER TO 2
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR  .AND. PO_SUFFIX = MPO_SUFFIX 
               IF SYS_DATE <= MEND 
                  MTOTAL = MTOTAL + AMT_PAID + AMT_OVER + CRED_AMT
               ENDIF
               SKIP
            ENDDO   
            SET ORDER TO 1 
            GOTO MRECNO
            MPREV_TOT = MTOTAL - (AMT_PAID + AMT_OVER + CRED_AMT)
            MAMT_DUE = MTOT_SELL - MPREV_TOT
            *** IF TOTAL DUE PRIOR TO THIS PAYMENT < 0
            *** IGNORE, SKIP AROUND
            IF MAMT_DUE <= 0              
               SKIP
               LOOP
            ENDIF
         ELSE
            STORE 0 TO MTOT_SELL
         ENDIF
         IF MBBUYCODE = SPACE(4)
            SELECT E
            SEEK A->ACCOUNT
            IF .NOT. EOF()
               STORE DESCRIP TO MBBUYNAME
            ELSE
               STORE 'ACCOUNT NOT ON FILE' TO MBBUYNAME
            ENDIF
            SELECT A
            STORE 'MISC' TO MCK_NBR
         ELSE
            IF MBBUYCODE = 'NONE'
               STORE 'NONE' TO MBBUYNAME
            ELSE  
               IF A->ACCOUNT <> '151 ' .AND. A->ACCOUNT <> '152 '
                  SELECT B
                  DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
                  SEEK MBBUYCODE
                  IF .NOT. EOF()
                     STORE NAME TO MBBUYNAME
                  ELSE 
                     STORE 'NOT ON FILE' TO MBBUYNAME
                  ENDIF
               ELSE
                  IF A->ACCOUNT = '151 '
                     SELECT B
                     DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
                     SEEK MBBUYCODE
                     IF .NOT. EOF()
                        STORE NAME TO MBBUYNAME
                     ELSE 
                        STORE 'NOT ON FILE' TO MBBUYNAME
                     ENDIF
                  ELSE
                     SELECT B
                     DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
                     SEEK MBBUYCODE
                     IF .NOT. EOF()
                        STORE NAME TO MBBUYNAME
                     ELSE 
                        STORE 'NOT ON FILE' TO MBBUYNAME
                     ENDIF
                  ENDIF
               ENDIF
            ENDIF
            SELECT A
         ENDIF
         
         IF SALESMAN <> SPACE(2)
            STORE SALESMAN + '-' + INV_NBR TO MINV_NBR
         ELSE
            STORE INV_NBR TO MINV_NBR
         ENDIF
         @ MLINE,0  SAY MINV_NBR
         IF MSALESMAN <> SPACE(2)
            @ MLINE,10 SAY MSALESMAN + '-' + MPO_NBR
         ELSE
            @ MLINE,13 SAY MPO_NBR
         ENDIF
         IF MPO_SUFFIX <> ' '
            @ MLINE,17 SAY '-' + PO_SUFFIX
         ENDIF
         @ MLINE,21 SAY SUBSTR(MBBUYNAME,1,17)
         IF CK_NBR <> SPACE(7)
            STORE CK_NBR TO MCK_NBR
         ENDIF
         @ MLINE,40 SAY MCK_NBR
         @ MLINE,50 SAY MTOT_SELL PICTURE '@Z 999,999.99'
         IF ACCOUNT <> '151 ' .AND. ACCOUNT <> '152 '
            @ MLINE,63 SAY MAMT_DUE PICTURE '@Z 999,999.99'
            MTOT_DUE = MTOT_DUE + MAMT_DUE
            *** 10/23/90 - CHANGED, SO THAT OVERPAYMENTS SHOW CORRECTLY
            *IF AMT_PAID + AMT_OVER + CRED_AMT >= MAMT_DUE
            *   @ MLINE,76 SAY MAMT_DUE PICTURE '999,999.99'
            *   MPAID_TOT = MPAID_TOT + MAMT_DUE 
            *ELSE
            MPAID_X = AMT_PAID + AMT_OVER + CRED_AMT
            *** UP TO 06/06/97 - LIMIT WAS 1000
            *** ON 06/06/97    - LIMIT WAS CHANGED TO 500
            IF MSALESMAN = '66'
               MLIM = 500 
            ELSE
               MLIM = 500  
            ENDIF
            IF MPAID_X - MAMT_DUE >= MLIM
               @ MLINE,76 SAY MAMT_DUE PICTURE '999,999.99'
               MPAID_TOT = MPAID_TOT + MAMT_DUE
            ELSE
               @ MLINE,76 SAY MPAID_X PICTURE '999,999.99'
               MPAID_TOT = MPAID_TOT + MPAID_X
            ENDIF
            MDIFF = MTOT_SELL - MTOTAL
            ** ADDED 10/23/90 ADDED CHECK TO PRINT CR
            *** CHGD 4/1/91 TO NOT PRINT 5.00 OVER OR UNDER IN BAL COL
            IF MDIFF < 0
               IF MDIFF < -5 .AND. MDIFF > (-1 * MLIM)
                  @ MLINE,87 SAY (MDIFF * -1) PICTURE '@Z 999,999.99'
                  @ MLINE,98 SAY 'Cr'
                  MTOT_DIFF = MTOT_DIFF + MDIFF
               ENDIF
            ELSE
               IF MDIFF > 5
                  @ MLINE,87 SAY MDIFF PICTURE '@Z 999,999.99'
                  MTOT_DIFF = MTOT_DIFF + MDIFF
               ENDIF
            ENDIF
            *ENDIF
         ELSE
            @ MLINE,76 SAY AMT_OVER PICTURE '999,999.99'
            MPAID_TOT = MPAID_TOT + AMT_OVER
         ENDIF
         MINV_TOT = MINV_TOT + MTOT_SELL
         MLINE = MLINE + 2
         SKIP
      ENDDO
      IF MLINE <> 99
         IF MDISP_PRT = 'P'
            @ MLINE,0 SAY 'TOTALS:'
            @ MLINE,61 SAY MTOT_DUE PICTURE '@Z 9,999,999.99'
            @ MLINE,74 SAY MPAID_TOT PICTURE '9,999,999.99'
            *** 10/23/90 CHANGED SO THAT OVERPAYMENTS SHOW CORRECTLY
            *** IF MTOT_DUE - MPAID_TOT > 0
            IF MTOT_DIFF < 0
               @ MLINE,85 SAY (MTOT_DIFF * -1) PICTURE '@Z 9,999,999.99'
               @ MLINE,98 SAY 'Cr'
            ELSE
               @ MLINE,85 SAY MTOT_DIFF PICTURE '@Z 9,999,999.99'
            ENDIF
            *** ENDIF
            @ MLINE+1,1 SAY ' '
            EJECT
            MLINE = 99
         ENDIF
      ENDIF
   ENDDO
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
   
   CLOSE DATA
ENDCASE
RETURN
*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 2:30 PM.
