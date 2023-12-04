************
* Program.: STMT.PRG
* Author..: GRACE KELLER
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: STATEMENT PRINT ROUTINE
*
* ---SET environment.
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     


MTITLE = ' - STATMENT PRINT'
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
MDO_AGAIN = .T.
DO WHILE MDO_AGAIN
   SAVE SCREEN TO MGRACE
   MNAME_FD = .F.
   DO BBUYSEL3
   IF .NOT. MNAME_FD 
      MDO_AGAIN = .F.
      LOOP
   ENDIF
   MSEL_BBUY = BBUYCODE
   CLOSE DATA
   RESTORE SCREEN FROM MGRACE
   @ 10,1 SAY SPACE(78)
   SET PROC TO PAYRPTS 
   
   
   MTERM_DAYS = 15
   STORE DATE() TO MRPT_DATE
   MPRT_ACT = 'C'
   
   DO PRT_SET
   
   IF MPRT_ACT <> 'C'
      LOOP  
   ENDIF
   SELECT E
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, TMP_BUY", .F.
   SELECT F
   DO FOX_USE WITH "INV_HEAD INDEX INV_HEAD", .F.
   
   SELECT C
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
   SELECT B
   DO FOX_USE WITH "INV_ADJ INDEX INV_ADJ", .F.
   
   SELECT D
   USE TEMP_AGE EXCLUSIVE         
   DELETE ALL
   PACK
   USE
   
   SELECT D
   DO FOX_USE WITH "TEMP_AGE", .F.
   INDEX ON NAME + RSUPCODE TO TEMP_AGE
   DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE", .F.
   
   SELECT A
   DO FOX_USE WITH "CUS_INV INDEX CUS_DATE", .F.
   
   SEEK ' '            
   IF EOF()
      @ 14,1 SAY 'THERE ARE NO OUTSTANDING INVOICES TO BE AGED'         
      @ 16,1 SAY ' '
      WAIT 'PRESS RETURN TO CONTINUE'
      LOOP  
   ENDIF
   
   DO WHILE .NOT. EOF() .AND. PAID_FLG = ' '
      IF MSEL_BBUY <> SPACE(4)
         IF MSEL_BBUY <> BBUYCODE
            SKIP
            LOOP
         ENDIF
      ENDIF
      IF BBUYCODE = 'CRED'
         SKIP
         LOOP
      ENDIF
      
      STORE BBUYCODE TO MBBUYCODE
      SELECT C
      SEEK MBBUYCODE
      
      IF .NOT. EOF()
         STORE NAME TO MNAME
      ELSE 
         STORE 'CUSTOMER NOT ON FILE' TO MNAME
      ENDIF
      
      SELECT A
      
      MOVERDUE = 0
      MBALANCE = 0
      
      DO WHILE .NOT. EOF() .AND. PAID_FLG = ' ' .AND. BBUYCODE = MBBUYCODE
         
         STORE INV_NBR TO MINV_NBR
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         STORE TOT_SELL + CUS_PALL TO MAMT

         SELECT F
         SEEK A->INV_NBR
         IF EOF()
            STORE 0 TO MTOT_SELL       
         ELSE
            STORE TOT_SELL TO MTOT_SELL        
         ENDIF
         
         SELECT E
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF EOF()
            STORE SPACE(15) TO MBUYER_PO
            STORE 0 TO MPO_AMT
         ELSE
            STORE BUYER_PO TO MBUYER_PO
            STORE TOT_SELL + CUS_PALL TO MPO_AMT
         ENDIF
         
         SELECT A

         ** IF CUS_INV FILE AMT <= 0 .AND. CURRENT PO AMT <= INVOICED AMOUNT
         ** CREDIT SITUATION - DON'T SHOW ON CUSTOMER REPORT

         IF MAMT <= 0 .AND. MPO_AMT <= MTOT_SELL
            SKIP
            LOOP
         ENDIF
         
         MSTILL_DUE = MTOT_SELL - AMT_PAID
         
         **
         
         IF MSTILL_DUE > 0
            
            MBALANCE = MBALANCE + MSTILL_DUE
            IF DTOC(SHIP_DATE) <> '  /  /  '
               STORE SHIP_DATE TO MTRAN_DATE    
            ELSE
               STORE INV_DATE TO MTRAN_DATE   
            ENDIF
            SELECT D
            DO FILELOCK
            APPEND BLANK
            REPLACE NAME WITH MNAME
            REPLACE RSUPCODE  WITH MBBUYCODE
            REPLACE SALESMAN  WITH MSALESMAN
            REPLACE TOT_SELL  WITH MTOT_SELL
            REPLACE STILL_DUE WITH MSTILL_DUE            
            REPLACE TRAN_DATE WITH MTRAN_DATE
            REPLACE REGION    WITH C->REGION
            REPLACE INV_NBR   WITH MINV_NBR
            REPLACE PO_NBR    WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE BUYER_PO  WITH MBUYER_PO
            UNLOCK
         ENDIF
         SELECT A
         SKIP
      ENDDO
      
   ENDDO
   
   
   CLOSE DATA
   
   MPAGE_NO = 0
   
   MLINE = 99
   MPAGE_LEN = 58
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
   
   SELECT C
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
   
   SELECT D
   DO FOX_USE WITH "TEMP_AGE INDEX TEMP_AGE", .F.
   
   IF .NOT. EOF()
      STORE RSUPCODE TO MBBUYCODE
      STORE NAME TO MNAME      
      SELECT C
      SEEK MBBUYCODE
      IF .NOT. EOF()
         STORE STREET TO MSTREET
         STORE TRIM(CITY) + ', ' + STATE + SPACE(2) + ZIP TO MADDR
      ELSE
         STORE SPACE(13) TO MPHONE, MADDR, MSTREET
      ENDIF
      
      SELECT D
      MLINE = 4
      @ MLINE,5 SAY 'AMERICHICKEN, INC.'
      MLINE = MLINE + 1
      @ MLINE,5 SAY '1330 COPPER DRIVE'
      MLINE = MLINE + 1
      @ MLINE,5 SAY 'CAPE GIRARDEAU, MO  63701'
      MLINE = MLINE + 1
      @ MLINE,5 SAY 'Phone: 573-651-3940'
      MLINE = MLINE + 1
      @ MLINE,5 SAY 'Corporate Contact: Celinda Tankersley'
      MLINE = MLINE + 3
      @ MLINE,34 SAY 'STATEMENT OF ACCOUNT'
      MLINE = MLINE + 1
      @ MLINE,34 SAY REPLICATE('-',20)
      MLINE = MLINE + 1
      @ MLINE,36 SAY 'DATE: ' + DTOC(MRPT_DATE)
      MLINE = MLINE + 2
      @ MLINE,5 SAY MNAME
      MLINE = MLINE + 1
      @ MLINE,5 SAY MSTREET
      MLINE = MLINE + 1
      @ MLINE,5 SAY MADDR
      MLINE = MLINE + 3
      
      @ MLINE,5 SAY ' INV DATE    INV NBR  PO NBR    CUSTOMER PO #     INV AMT   PAYMENTS  AMOUNT DUE'
      *              XX/XX/XXXX  99-XXXXX  XX-XXXX-X XXXXXXXXXXXXX  999,999.99 999,999.99  999,999.99
      *              5678901234567890123456789012345678901234567890123456789012345678901234567890123456789
      *                  10        20        30        40        50        60         70        80
      MLINE = MLINE + 1
      @ MLINE,5 SAY REPLICATE('=',80)
      MLINE = MLINE + 1
   ENDIF
   
   STORE 0 TO MCURRENT, MPAST_DUE
   
   DO WHILE .NOT. EOF()
      STORE MRPT_DATE - TRAN_DATE TO MDAYS
      DO CASE
      CASE MDAYS <= 15
         MCURRENT = MCURRENT + STILL_DUE
      OTHERWISE 
         MPAST_DUE = MPAST_DUE + STILL_DUE
      ENDCASE
      
      @ MLINE,5 SAY TRAN_DATE   
      IF SALESMAN <> '  '
         @ MLINE,17 SAY SALESMAN + '-'
      ENDIF
      @ MLINE,20 SAY INV_NBR 
      IF SALESMAN <> '  '
         @ MLINE,27 SAY SALESMAN + '-'
      ENDIF
      @ MLINE,30 SAY PO_NBR
      IF PO_SUFFIX <> SPACE(1)
         @ MLINE,34 SAY '-' + PO_SUFFIX
      ENDIF
      @ MLINE,37 SAY BUYER_PO
      
      @ MLINE,52 SAY TOT_SELL PICTURE '999,999.99'
      @ MLINE,63 SAY TOT_SELL-STILL_DUE PICTURE '999,999.99'
      @ MLINE,75 SAY STILL_DUE PICTURE '999,999.99'
      
      IF MDAYS > 14
         @ MLINE,86 SAY '=> PAST DUE'
      ENDIF
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF MLINE <> 99   
      MLINE = MLINE + 5
      @ MLINE,5 SAY 'Payment Terms Are NET 14 From Invoice Date'
      MLINE = MLINE + 2
      @ MLINE,5 SAY   '    A C C O U N T   S U M M A R Y'
      MLINE = MLINE + 1
      @ MLINE,5 SAY   '--------------------------------------------------------'
      @ MLINE+1,5 SAY '[     CURRENT      |     PAST DUE    |      TOTAL      ]'
      @ MLINE+2,5 SAY '[   1 - 15 DAYS    |   OVER 15 DAYS  |   AMOUNT DUE    ]'
      @ MLINE+3,5 SAY '[                  |                 |                 ]'
      @ MLINE+4,5 SAY '[                  |                 |                 ]'
      @ MLINE+4,7 SAY MCURRENT  PICTURE '9,999,999.99'
      @ MLINE+4,27 SAY MPAST_DUE PICTURE '9,999,999.99'
      @ MLINE+4,45 SAY MCURRENT + MPAST_DUE PICTURE '9,999,999.99'
      @ MLINE+5,5 SAY '--------------------------------------------------------'
      @ MLINE+6,1 SAY ' '
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
   
ENDDO
RETURN
*Formatted by: ToolBox Ver. 1.2  on 12/17/15 at 11:17 AM.
