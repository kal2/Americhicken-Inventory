************
* Program.: SPEC17.PRG
* Author..: GRACE KELLER
* Date....: 
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SPEC17 - BILLBACK LISTINGS
*
* ---SET environment.
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

CLEAR
@ 01,00 SAY MCOMPANY
@ 02,00 SAY MPROGRAM + ' - REPORT SPEC17 - BILLBACK LISTINGS'
@ 02,70 SAY DATE()
@ 3,0 to 24,79
STORE 'S' TO Mrpt_opt
SET CONFIRM ON
@ 10,1 say 'Print Detail (D) -or- Yearly Summary (S)  Report: ' get Mrpt_opt PICTURE '@!' VALID(Mrpt_opt = 'D' .OR. Mrpt_opt = 'S')
READ
SET CONFIRM OFF
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   CLEAR
   @ 01,00 SAY MCOMPANY
   @ 02,00 SAY MPROGRAM + ' - BILLBACK LISTINGS'
   @ 02,70 SAY DATE()
   @ 3,0 to 25,79
   STORE SPACE(2) TO MOPT_CODE
   MPAPER = SPACE(6)
   
   MCHOICE = ' '
   MYES_NO = 'YES'     
   *** GET THE RIGHT COMMISSION PAYEE
   MNAME_FD = .F.
   DO COM_SEL1
   IF .NOT. MNAME_FD
      MNOT_DONE = .F.
      LOOP
   ELSE
      STORE NAME TO MCOM_NAME
      STORE COM_CODE TO MOPT_CODE
      STORE NAME TO MNAME
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
   ENDIF
   
   MTITLE = ' - BILLBACK  ACTIVITY REPORT'  
   CLEAR
   @  1, 1  SAY MCOMPANY
   @  1,68 SAY DATE()
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   **** GET FIRST AND LAST DATES FOR THIS REPORT
   
   STORE 'P' TO MDISP_PRT
   STORE SPACE(2) TO MSTRT_MO, MLAST_MO
   STORE SPACE(4) TO MSTRT_YR, MLAST_YR
   @ 5,2 SAY  'Report Begin MM/YYYY:   /'                   
   @ 7,2 SAY  '         End MM/YYYY:   /'
   STORE 2 TO MACTION      
   DO WHILE MACTION = 2      
      @ 05,24 GET MSTRT_MO
      @ 05,27 GET MSTRT_YR
      @ 07,24 GET MLAST_MO
      @ 07,27 GET MLAST_YR
      
      STORE 1 TO MACTION
      @ 24,00 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report/Finished'             
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 1
         IF MSTRT_MO = SPACE(2) .OR. MLAST_MO = SPACE(2) .OR. MSTRT_YR = SPACE(4) .OR. MLAST_YR = SPACE(4)
            MACTION = 3
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
   
   SELECT A
   DO FOX_USE WITH "&MMASTDBF.BBKLED INDEX &MMASTDBF.BBKLED", .F.
   
   DO CASE
   CASE Mrpt_opt = 'D'
      SEEK MSTRT_YR + MSTRT_MO + 'T' + MOPT_CODE
      IF EOF()
         MBEG_BAL = 0
      ELSE
         IF COR_FLG = ' '
            MBEG_BAL = AMOUNT
         ELSE
            MBEG_BAL = 0
         ENDIF
      ENDIF
      MEND_BAL = MBEG_BAL
      MPRT_BAL = .T.
      
      SET FILTER TO COR_FLG <> ' '  .AND. LED_CODE = MOPT_CODE
      GOTO TOP
      
      MPAGE_NO = 0
      STORE 0 TO MCHECKS, MINVOICES, MEND_BAL
      
      DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR+TRAN_MO) <= VAL(MLAST_YR+MLAST_MO)
         IF VAL(TRAN_YR+TRAN_MO) < VAL(MSTRT_YR+MSTRT_MO)
            SKIP
            LOOP
         ENDIF
         *IF LED_CODE <> MOPT_CODE
         *   SKIP
         *   LOOP
         *ENDIF
         
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,40 SAY MCOMPANY + ' - Report: Spec17'
            @ 3,1 SAY 'Page'
            @ 3,6 SAY STR(MPAGE_NO,2)
            @ 3,28 SAY ' BILLBACK LEDGER LISTING FOR ' + MSTRT_MO + '/' + MSTRT_YR + ' THRU ' + MLAST_MO + '/' + MLAST_YR 
            @ 3,84  SAY DTOC(DATE())
            @ 5,1 SAY 'ACCOUNT/DATE/ITEM'
            @ 5,31 SAY 'INVOICE '
            @ 5,42 SAY 'P.O. NBR'
            @ 5,57 SAY '  DEBITS'  
            @ 5,70 SAY '  CREDITS'
            @ 5,84 SAY '   BALANCE'
            @ 5,01 SAY REPLICATE('_',93)
            @ 7,1 SAY MNAME
            MLINE = 8
            MDO_NM = .F.
         ENDIF
         IF MPRT_BAL
            @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
            @ MLINE,81 SAY MBEG_BAL PICTURE '99,999,999.99'
            MLINE = MLINE + 1
            MPRT_BAL = .F.
         ENDIF
         
         @ MLINE,5 SAY TRAN_DATE
         IF CK_NBR = SPACE(6)
            DO CASE
            CASE COR_FLG = 'I' .OR. COR_FLG = ' '
               @ MLINE,16 SAY 'INVOICE'
            CASE COR_FLG = 'R'
               @ MLINE,16 SAY 'RECEIPT'
            CASE COR_FLG = 'D'
               @ MLINE,16 SAY 'A/R REIMBURSE'
            OTHERWISE
               @ MLINE,16 SAY 'CORRECTION'
            ENDCASE
         ELSE
            @ MLINE,16 SAY 'CK #: ' + CK_NBR
         ENDIF
         IF INV_NBR <> SPACE(5) 
            @ MLINE,32 SAY INV_NBR
         ENDIF
         IF SALESMAN <> '  '
            IF PO_SUFFIX <> ' '
               @ MLINE,42 SAY  SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
            ELSE
               @ MLINE,42 SAY SALESMAN + '-' + PO_NBR 
            ENDIF
         ELSE
            IF PO_SUFFIX <> ' '
               @ MLINE,42 SAY PO_NBR + '-' + PO_SUFFIX
            ELSE
               @ MLINE,42 SAY PO_NBR 
            ENDIF
         ENDIF
         IF AMOUNT > 0
            @ MLINE,69 SAY AMOUNT PICTURE '999,999.99'
         ELSE
            @ MLINE,55 SAY AMOUNT PICTURE '999,999.99'
         ENDIF
         
         MEND_BAL = MEND_BAL + AMOUNT
         MLINE = MLINE + 1
         SKIP
      ENDDO
      
      @ MLINE,5 SAY 'ENDING ACCOUNT BALANCE'
      @ MLINE,81 SAY MEND_BAL PICTURE '99,999,999.99'
      MLINE = MLINE + 1
      @ MLINE,1 SAY ' '        
      
   OTHERWISE
      
      I = 1
      DO WHILE I <= 12
         MI = SUBSTR(STR(I+100,3),2)
         STORE 0 TO MACT&MI
         I = I + 1
      ENDDO
      STORE 0 TO MEND_BAL
      STORE 0 TO MPAY1, MPAY2, MPAY3, MPAY4
      
      SEEK MSTRT_YR + MSTRT_MO + 'T' + MOPT_CODE
      IF EOF()
         MBEG_BAL = 0
      ELSE
         IF COR_FLG = ' '
            MBEG_BAL = AMOUNT
         ELSE
            MBEG_BAL = 0
         ENDIF
      ENDIF
      MEND_BAL = MBEG_BAL
      MPRT_BAL = .T.
      
      SET FILTER TO COR_FLG <> ' '  .AND. LED_CODE = MOPT_CODE
      GOTO TOP
      
      MPAGE_NO = 0
      
      DO WHILE .NOT. EOF() .AND. VAL(TRAN_YR+TRAN_MO) <= VAL(MLAST_YR+MLAST_MO)
         IF VAL(TRAN_YR+TRAN_MO) < VAL(MSTRT_YR+MSTRT_MO)
            SKIP
            LOOP
         ENDIF
         MI = TRAN_MO
         IF CK_NBR = SPACE(6) .AND. PO_SUFFIX <> 'R'
            MACT&MI = MACT&MI + AMOUNT
         ELSE
            DO CASE
            CASE TRAN_MO = '01' .OR. TRAN_MO = '02' .OR. TRAN_MO = '03'
               MPAY1 = MPAY1 + AMOUNT
            CASE TRAN_MO = '04' .OR. TRAN_MO = '05' .OR. TRAN_MO = '06'
               MPAY2 = MPAY2 + AMOUNT
            CASE TRAN_MO = '07' .OR. TRAN_MO = '08' .OR. TRAN_MO = '09'
               MPAY3 = MPAY3 + AMOUNT
            OTHERWISE
               MPAY4 = MPAY4 + AMOUNT
            ENDCASE
         ENDIF
         MEND_BAL = MEND_BAL + AMOUNT
         SKIP
      ENDDO
      
      IF MLINE > MPAGE_LEN
         IF MLINE <> 99
            EJECT         
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 2,40 SAY MCOMPANY + ' - Report: Spec17'
         @ 3,1 SAY 'Page'
         @ 3,6 SAY STR(MPAGE_NO,2)
         @ 3,28 SAY ' BILLBACK LEDGER LISTING FOR ' + MSTRT_MO + '/' + MSTRT_YR + ' THRU ' + MLAST_MO + '/' + MLAST_YR 
         @ 3,84  SAY DTOC(DATE())
         @ 5,1 SAY 'ACCOUNT/DATE/ITEM'
         @ 5,31 SAY 'INVOICE '
         @ 5,42 SAY 'P.O. NBR'
         @ 5,57 SAY '  DEBITS'  
         @ 5,70 SAY '  CREDITS'
         @ 5,84 SAY '   BALANCE'
         @ 5,01 SAY REPLICATE('_',93)
         @ 7,1 SAY MNAME
         MLINE = 8
         MDO_NM = .F.
      ENDIF
      IF MPRT_BAL
         MLINE = MLINE + 1
         @ MLINE,5 SAY 'BEGINNING ACCOUNT BALANCE'
         @ MLINE,81 SAY MBEG_BAL PICTURE '99,999,999.99'
         MLINE = MLINE + 2
         MPRT_BAL = .F.
      ENDIF
      
      @ MLINE,5 SAY 'JANUARY ACCRUAL'
      @ MLINE,69 SAY MACT01 PICTURE '999,999.99'
      MLINE = MLINE + 1
      
      @ MLINE,5 SAY 'FEBRUARY ACCRUAL'
      @ MLINE,69 SAY MACT02 PICTURE '999,999.99'
      MLINE = MLINE + 1
      
      @ MLINE,5 SAY 'MARCH ACCRUAL'
      @ MLINE,69 SAY MACT03 PICTURE '999,999.99'
      MLINE = MLINE + 2
      
      @ MLINE,5 SAY '1ST QTR TOTAL ACCRUAL'
      @ MLINE,69 SAY MACT01 + MACT02 + MACT03 PICTURE '999,999.99'
      MLINE = MLINE +  1
      @ MLINE,5 SAY '1ST QTR PAYMENTS'
      @ MLINE,55 SAY MPAY1 PICTURE '999,999.99'
      MLINE = MLINE + 3
      
      @ MLINE,5 SAY 'APRIL ACCRUAL'
      @ MLINE,69 SAY MACT04 PICTURE '999,999.99'
      MLINE = MLINE + 1
      
      @ MLINE,5 SAY 'MAY ACCRUAL'
      @ MLINE,69 SAY MACT05 PICTURE '999,999.99'
      MLINE = MLINE + 1
      
      @ MLINE,5 SAY 'JUNE ACCRUAL'
      @ MLINE,69 SAY MACT06 PICTURE '999,999.99'
      MLINE = MLINE + 2
      
      @ MLINE,5 SAY '2ND QTR TOTAL ACCRUAL'
      @ MLINE,69 SAY MACT04 + MACT05 + MACT06 PICTURE '999,999.99'
      MLINE = MLINE + 1
      @ MLINE,5 SAY '2ND QTR PAYMENTS'
      @ MLINE,55 SAY MPAY2 PICTURE '999,999.99'
      MLINE = MLINE + 3 
      
      @ MLINE,5 SAY 'JULY ACCRUAL'
      @ MLINE,69 SAY MACT07 PICTURE '999,999.99'
      MLINE = MLINE + 1
      
      @ MLINE,5 SAY 'AUGUST ACCRUAL'
      @ MLINE,69 SAY MACT08 PICTURE '999,999.99'
      MLINE = MLINE + 1
      
      @ MLINE,5 SAY 'SEPTEMBER ACCRUAL'
      @ MLINE,69 SAY MACT09 PICTURE '999,999.99'
      MLINE = MLINE + 2
      
      @ MLINE,5 SAY '3RD QTR TOTAL ACCRUAL'
      @ MLINE,69 SAY MACT07 + MACT08 + MACT09 PICTURE '999,999.99'
      MLINE = MLINE + 1
      @ MLINE,5 SAY '3RD QTR PAYMENTS'
      @ MLINE,55 SAY MPAY3 PICTURE '999,999.99'
      MLINE = MLINE + 3
      
      @ MLINE,5 SAY 'OCTOBER ACCRUAL'
      @ MLINE,69 SAY MACT10 PICTURE '999,999.99'
      MLINE = MLINE + 1
      
      @ MLINE,5 SAY 'NOVEMBER ACCRUAL'
      @ MLINE,69 SAY MACT11 PICTURE '999,999.99'
      MLINE = MLINE + 1
      
      @ MLINE,5 SAY 'DECEMBER ACCRUAL'
      @ MLINE,69 SAY MACT12 PICTURE '999,999.99'
      MLINE = MLINE + 2
      
      @ MLINE,5 SAY '4TH QTR TOTAL ACCRUAL'
      @ MLINE,69 SAY MACT10 + MACT11 + MACT12 PICTURE '999,999.99'
      MLINE = MLINE + 1
      @ MLINE,5 SAY '4TH QTR PAYMENTS'
      @ MLINE,55 SAY MPAY4 PICTURE '999,999.99'
      MLINE = MLINE + 3
      
      MLINE = MLINE + 2
      @ MLINE,5 SAY 'TOTALS'
      @ MLINE,55 SAY MPAY1 + MPAY2 + MPAY3 + MPAY4 PICTURE '999,999.99'
      MTOTAL = MACT01+MACT02+MACT03+MACT04+MACT05+MACT06
      MTOTAL = MTOTAL + MACT07+MACT08+MACT09+MACT10+MACT11+MACT12
      @ MLINE,69 SAY MTOTAL PICTURE '999,999.99'
      @ MLINE,81 SAY MEND_BAL PICTURE '999,999.99'
      MLINE = MLINE + 1
      @ MLINE,1 SAY ' '
   ENDCASE
   EJECT
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
   CLOSE DATA
ENDDO
RETURN

*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 11:37 AM.
