******************
* Program.: PO.PRG
* Author..: GRACE KELLER
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PURCHASE ORDER MENU     
*
* ---PROCESSING LOOP
*  MULTI-USER RECORD/FILE LOCKING  +(M4)  CLIPPER                             

STORE 0 TO MACTION
STORE ' ' TO MSELECTION

DO WHILE MSELECTION <> '9'
   MDOSHORT = .F.
   SET PROC TO PO_PROC
   CLOSE DATA
   CLEAR
   @ 1,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 02,00 SAY MPROGRAM + ' - PURCHASE ORDER MENU'
   @ 03,00 , 24,79 BOX
   
   @ 04,09 SAY ' 1 - ADD    PURCHASE ORDER(S)'
   @ 05,09 SAY ' 2 - CHANGE PURCHASE ORDER(S)'
   @ 06,09 SAY ' 3 - VIEW   PURCHASE ORDER(S)'
   @ 07,09 SAY ' 4 - DELETE/VOID PURCHASE ORDER'
   @ 09,09 say ' 5 - ENTER PURCHASE ORDER SHORTWEIGHTS'
   @ 11,09 SAY " 6 - VIEW ALL PO'S FOR CUSTOMER/SUPPLIER/FREIGHT"
   @ 12,09 say ' 7 - VIEW PO LEDGER HISTORY'
   **@ 14,09 SAY ' 8 - PRINT LOG & ORDERS / ADD TRANSMITTED ORDERS TO BROKER D/B'     
   @ 14,09 SAY ' P - PRINT COPY OF ORDER'
   @ 17,09 SAY ' A - PRINT ORDER CONFIRMATIONS        F - VIEW ALL FRT FOR SHIPMNT'
   @ 18,09 SAY ' B - PRINT ORDER MARGIN SUMMARY       R - RELEASE ORDERS FROM HOLD'
   @ 19,09 SAY ' D - PRINT DAILY ORDERS ENTERED       S - DAILY SAMPLE REQUEST RPT'
   @ 20,09 SAY ' H - DISPLAY/PRINT ORDERS ON HOLD     T - LIST PO PRI CHGS-FOR LOT'
   @ 21,09 SAY '                                      W - WHITE BOARD REPORT'
   @ 22,09 SAY ' 9 - EXIT TO MAIN MENU'
   
   STORE ' ' TO MSELECTION
   @ 25,02 SAY 'CHOICE: '
   @ 25,10 get mselection picture '@!'
   READ
   
   DO CASE
      
   CASE VAL(MSELECTION) = 1
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PRINT, PO_SUP, PO_SHIP, PO_FRT", .F.
      SELECT C
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      DO PO_ADD     
   CASE VAL(MSELECTION) = 2
      MVIEW = .F.
      * DO PO_SEL 
      DO PO_PICK
   CASE VAL(MSELECTION) = 3
      MVIEW = .T. 
      MLAST_PG = .F.
      *     DO PO_SEL 
      DO PO_PICK
      
   CASE VAL(MSELECTION) = 4
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PRINT, PO_SUP, PO_SHIP, PO_FRT", .F.
      SELECT C
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      DO VOIDPO

   CASE VAL(MSELECTION) = 5
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PO_SUP", .F.
      SELECT C
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      MDOSHORT = .T.
      DO PO_SEL2
      
   CASE VAL(MSELECTION) = 6
      *     DO CUSTPOVW
      MPICK = .T.
      DO SEL_VW 
   CASE VAL(MSELECTION) = 7
      
      MTITLE = ' - ORDER LEDGER INQUIRY'    
      
      MMORE = .T.
      STORE SPACE(2) TO MSALESMAN
      STORE SPACE(4) TO MPO_NBR
      STORE ' ' TO MPO_SUFFIX, MTYPE
      STORE 'D' TO MDISP_PRT
      DO WHILE MMORE
         CLEAR
         @  1, 1  SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            SET DEVICE TO SCREEN
            SET PRINT OFF
            SET PRINT TO
            SET CONSOLE ON
            @ 08,5 SAY 'PO NUMBER: '
            @ 08,18 SAY '-'
            @ 08,23 SAY '-'
            @ 08,16 GET MSALESMAN PICTURE '##'
            @ 08,19 GET MPO_NBR PICTURE '####'
            @ 08,24 GET MPO_SUFFIX PICTURE '@!'
            @ 11,5 SAY 'SUPPLIER (S), CUSTOMER (C) '
            @ 12,5 SAY '            OR FREIGHT (F)? ' GET MTYPE PICTURE '@!'
            @ 14,5 SAY '    DISPLAY OR PRINT (D/P)? ' GET MDISP_PRT PICTURE '@!'
            STORE 1 TO MACTION
            @ 23,00 CLEAR
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2.  Edit    3. Finished'     
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
            IF MACTION = 1 .AND. (MSALESMAN <> '  ' .OR. MPO_NBR <> '  ')
               IF MTYPE <> 'C' .AND. MTYPE <> 'S' .AND. MTYPE <> 'F'
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  @ 24,1 SAY 'SUPPLIER, CUSTOMER, FREIGHT SELECTION INVALID - PRESS RETURN TO CONTINUE ' GET MWAIT  
                  READ
                  MACTION = 2
                  LOOP
               ENDIF
               IF MDISP_PRT <> 'D' .AND. MDISP_PRT <> 'P'
                  @ 24,0 CLEAR
                  STORE ' ' TO MWAIT
                  @ 24,1 SAY 'DISPLAY/PRINT SELECTION INVALID - PRESS RETURN TO CONTINUE ' GET MWAIT  
                  READ
                  MACTION = 2
                  LOOP
               ENDIF
            ENDIF
            
         ENDDO
         IF MACTION = 3 .OR. (MSALESMAN = '  ' .AND. MPO_NBR = SPACE(4))
            MMORE = .F.
            LOOP
         ENDIF
         IF MDISP_PRT = 'P'
            MPRT_ACT = 'C'
            
            DO PRT_SET
            
            IF MPRT_ACT <> 'C'
               RETURN
            ENDIF
            
            MPAGE_LEN = 56
         ELSE
            MPAGE_LEN = 22
         ENDIF
         MPAGE_NO = 0
         MLINE = 99 
         IF MDISP_PRT = 'P'
            @ 19,16 SAY 'PROCESSING.......PLEASE WAIT...'
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
         DO CASE
         CASE MTYPE = 'C'
            SELECT C
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         CASE MTYPE = 'S'
            SELECT C
            DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
         OTHERWISE
            SELECT C
            DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
         ENDCASE
         *IF MTYPE = 'C'
         SELECT B
         DO FOX_USE WITH "PAYMENTS INDEX PAY_PO", .F.
         *ELSE
         SELECT E
         DO FOX_USE WITH "DISBJRN INDEX DISB_PO", .F.
         *ENDIF
         SELECT D
         DO FOX_USE WITH "DAILYJRN INDEX JRN_PO", .F.
         SELECT A
         DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
         
         SEEK MSALESMAN+MPO_NBR+MPO_SUFFIX
         IF EOF()
            @ 20,1 SAY 'NO HISTORY ON FILE FOR: ' + SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
            LOOP
         ENDIF
         TTOT_PURCH = 0
         TTOT_FRT = 0
         TTOT_SELL = 0
         TTOT_RECV = 0
         TTOT_MISC = 0
         TTOT_CRED = 0
         SELECT D
         SEEK MSALESMAN+MPO_NBR+MPO_SUFFIX
         
         STORE SPACE(4) TO MCODE
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
            MPRT_NAME = .F.
            DO CASE
            CASE MTYPE = 'C'
               IF BBUYCODE <> MCODE
                  SELECT C
                  SEEK D->BBUYCODE
                  IF EOF()
                     STORE 'CUSTOMER NOT ON FILE' TO MNAME     
                  ELSE
                     STORE NAME TO MNAME    
                  ENDIF
                  SELECT D
                  STORE BBUYCODE TO MCODE
                  MPRT_NAME = .T.
               ENDIF
            CASE MTYPE = 'S'
               IF RSUPCODE <> MCODE
                  SELECT C
                  SEEK D->RSUPCODE
                  IF EOF()
                     STORE 'SUPPLIER NOT ON FILE' TO MNAME     
                  ELSE
                     STORE NAME TO MNAME    
                  ENDIF
                  SELECT D
                  STORE RSUPCODE TO MCODE
                  MPRT_NAME = .T.
               ENDIF
            OTHERWISE
               IF FRT_CODE1 <> MCODE
                  SELECT C
                  SEEK D->FRT_CODE1
                  IF EOF()
                     STORE 'FREIGHT NOT ON FILE' TO MNAME     
                  ELSE
                     STORE NAME TO MNAME    
                  ENDIF
                  SELECT D
                  STORE FRT_CODE1 TO MCODE
                  MPRT_NAME = .T.
               ENDIF
            ENDCASE
            
            MWORK_LINE = MLINE
            IF MPRT_NAME
               IF MWORK_LINE <> 99
                  MWORK_LINE = MWORK_LINE + 1
               ENDIF
            ENDIF
            
            IF MWORK_LINE > MPAGE_LEN
               IF MDISP_PRT = 'P'
                  IF MLINE <> 99
                     EJECT
                  ENDIF
               ELSE
                  CLEAR
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               @ 1,34 SAY MCOMPANY
               @ 2,0 SAY 'PAGE'
               @ 2,05 say mpage_no picture '99'
               @ 2,30 SAY 'PURCHASE ORDER INQUIRY '
               @ 2,70 SAY DTOC(DATE())
               @ 4,1 SAY 'PO NUMBER' 
               @ 4,12 SAY 'INV NBR'  
               @ 4,23 SAY 'DATE'
               @ 4,30 SAY '        AMOUNT'
               @ 4,48 SAY 'DESCRIPTION'
               IF MDISP_PRT = 'P'
                  @ 4,0 SAY REPLICATE ('_',80)
               ENDIF
               MLINE = 6
               @ MLINE,1 SAY MNAME
               IF MDISP_PRT = 'P'
                  MLEN = LEN(TRIM(MNAME))
                  @ MLINE,1 SAY REPLICATE('_',MLEN)
               ENDIF
               MPRT_NAME = .F.
               MLINE = MLINE + 1
            ENDIF
            IF MPRT_NAME
               @ MLINE,1 SAY MNAME
               MLINE = MLINE + 1
               MPRT_NAME = .F.
            ENDIF
            
            IF SALESMAN <> SPACE(2)
               @ MLINE,1 SAY SALESMAN
               @ MLINE,3 SAY '-'
            ENDIF
            @ MLINE,4 SAY PO_NBR
            IF PO_SUFFIX <> ' '
               @ MLINE,8 SAY '-'
               @ MLINE,9 SAY PO_SUFFIX
            ENDIF
            @ MLINE,13 SAY INV_NBR   
            
            @ MLINE,21 SAY TRAN_DATE
            DO CASE
            CASE MTYPE = 'C'
               @ MLINE,32 SAY TRANSFORM(TOT_SELL+CUS_PALL, '9,999,999.99')
               TTOT_SELL = TTOT_SELL + TOT_SELL + CUS_PALL
            CASE MTYPE = 'S'
               @ MLINE,32 SAY TRANSFORM(TOT_PURCH+SUP_PALL, '9,999,999.99')
               TTOT_PURCH = TTOT_PURCH + TOT_PURCH + SUP_PALL
            OTHERWISE           
               @ MLINE,32 SAY TRANSFORM(FRT_AMT1+FRT_PALL, '9,999,999.99')
               TTOT_FRT = TTOT_FRT + FRT_AMT1 + FRT_PALL
            ENDCASE
            IF INV_COR = 'I'
               @ MLINE,48 SAY 'INVOICE'
            ELSE
               @ MLINE,48 SAY 'CORRECTION'
            ENDIF
            MLINE = MLINE + 1
            SKIP
         ENDDO
         DO CASE
         CASE MTYPE = 'C'
            ***********************************           
            **** GET THE PAYMENTS RECEIVED ****
            ***********************************          
            SELECT B
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
            DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR  .AND. PO_SUFFIX = A->PO_SUFFIX
               IF ACCOUNT = '151 ' .OR. ACCOUNT = '152 '
                  SKIP
                  LOOP
               ENDIF
               IF AMT_PAID <> 0 .OR. AMT_OVER <> 0 .OR. CRED_AMT <> 0
                  IF MLINE > MPAGE_LEN
                     IF MDISP_PRT = 'P'
                        IF MLINE <> 99
                           EJECT
                        ENDIF
                     ELSE
                        CLEAR
                     ENDIF
                     MPAGE_NO = MPAGE_NO + 1
                     @ 1,34 SAY MCOMPANY
                     @ 2,0 SAY 'PAGE'
                     @ 2,05 say mpage_no picture '99'
                     @ 2,30 SAY 'PURCHASE ORDER INQUIRY '
                     @ 2,70 SAY DTOC(DATE())
                     @ 4,1 SAY 'PO NUMBER' 
                     @ 4,12 SAY 'INV NBR'  
                     @ 4,23 SAY 'DATE'
                     @ 4,30 SAY '        AMOUNT'
                     @ 4,48 SAY 'DESCRIPTION'
                     IF MDISP_PRT = 'P'
                        @ 4,0 SAY REPLICATE ('_',80)
                     ENDIF
                     MLINE = 6
                     @ MLINE,1 SAY MNAME
                     IF MDISP_PRT = 'P'
                        MLEN = LEN(TRIM(MNAME))
                        @ MLINE,1 SAY REPLICATE('_',MLEN)
                     ENDIF
                     MPRT_NAME = .F.
                     MLINE = MLINE + 1
                  ENDIF
                  
                  IF SALESMAN <> SPACE(2)
                     @ MLINE,1 SAY SALESMAN
                     @ MLINE,3 SAY '-'
                  ENDIF
                  @ MLINE,4 SAY PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,8 SAY '-'
                     @ MLINE,9 SAY PO_SUFFIX
                  ENDIF
                  @ MLINE,13 SAY INV_NBR   
                  
                  @ MLINE,21 SAY PAID_DATE
                  IF AMT_PAID <> 0 
                     @ MLINE,32 SAY TRANSFORM(AMT_PAID * -1, '9,999,999.99')
                     @ MLINE,48 SAY 'RECV. PAYMENT - CK # ' + CK_NBR
                     TTOT_RECV = TTOT_RECV + (AMT_PAID * -1)
                     MLINE = MLINE + 1
                  ENDIF
                  IF AMT_OVER <> 0
                     IF MLINE > MPAGE_LEN
                        IF MDISP_PRT = 'P'
                           IF MLINE <> 99
                              EJECT
                           ENDIF
                        ELSE
                           CLEAR
                        ENDIF
                        MPAGE_NO = MPAGE_NO + 1
                        @ 1,34 SAY MCOMPANY
                        @ 2,0 SAY 'PAGE'
                        @ 2,05 say mpage_no picture '99'
                        @ 2,30 SAY 'PURCHASE ORDER INQUIRY '
                        @ 2,70 SAY DTOC(DATE())
                        @ 4,1 SAY 'PO NUMBER' 
                        @ 4,12 SAY 'INV NBR'  
                        @ 4,23 SAY 'DATE'
                        @ 4,30 SAY '        AMOUNT'
                        @ 4,48 SAY 'DESCRIPTION'
                        IF MDISP_PRT = 'P'
                           @ 4,0 SAY REPLICATE ('_',80)
                        ENDIF
                        MLINE = 6
                        @ MLINE,1 SAY MNAME
                        IF MDISP_PRT = 'P'
                           MLEN = LEN(TRIM(MNAME))
                           @ MLINE,1 SAY REPLICATE('_',MLEN)
                        ENDIF
                        MPRT_NAME = .F.
                        MLINE = MLINE + 1
                     ENDIF
                     
                     IF SALESMAN <> SPACE(2)
                        @ MLINE,1 SAY SALESMAN
                        @ MLINE,3 SAY '-'
                     ENDIF
                     @ MLINE,4 SAY PO_NBR
                     IF PO_SUFFIX <> ' '
                        @ MLINE,8 SAY '-'
                        @ MLINE,9 SAY PO_SUFFIX
                     ENDIF
                     @ MLINE,13 SAY INV_NBR   
                     
                     @ MLINE,21 SAY PAID_DATE
                     @ MLINE,32 SAY TRANSFORM(AMT_OVER * -1 , '9,999,999.99')
                     @ MLINE,48 SAY 'MISC. PAYMENT - CK # ' + CK_NBR
                     TTOT_MISC = TTOT_MISC + (AMT_OVER * -1)
                     MLINE = MLINE + 1
                  ENDIF
                  
                  IF CRED_AMT <> 0
                     IF MLINE > MPAGE_LEN
                        IF MDISP_PRT = 'P'
                           IF MLINE <> 99
                              EJECT
                           ENDIF
                        ELSE
                           CLEAR
                        ENDIF
                        MPAGE_NO = MPAGE_NO + 1
                        @ 1,34 SAY MCOMPANY
                        @ 2,0 SAY 'PAGE'
                        @ 2,05 say mpage_no picture '99'
                        @ 2,30 SAY 'PURCHASE ORDER INQUIRY '
                        @ 2,70 SAY DTOC(DATE())
                        @ 4,1 SAY 'PO NUMBER' 
                        @ 4,12 SAY 'INV NBR'  
                        @ 4,23 SAY 'DATE'
                        @ 4,30 SAY '        AMOUNT'
                        @ 4,48 SAY 'DESCRIPTION'
                        IF MDISP_PRT = 'P'
                           @ 4,0 SAY REPLICATE ('_',80)
                        ENDIF
                        MLINE = 6
                        @ MLINE,1 SAY MNAME
                        IF MDISP_PRT = 'P'
                           MLEN = LEN(TRIM(MNAME))
                           @ MLINE,1 SAY REPLICATE('_',MLEN)
                        ENDIF
                        MPRT_NAME = .F.
                        MLINE = MLINE + 1
                     ENDIF
                     
                     IF SALESMAN <> SPACE(2)
                        @ MLINE,1 SAY SALESMAN
                        @ MLINE,3 SAY '-'
                     ENDIF
                     @ MLINE,4 SAY PO_NBR
                     IF PO_SUFFIX <> ' '
                        @ MLINE,8 SAY '-'
                        @ MLINE,9 SAY PO_SUFFIX
                     ENDIF
                     @ MLINE,13 SAY INV_NBR   
                     
                     @ MLINE,21 SAY PAID_DATE
                     @ MLINE,32 SAY TRANSFORM(CRED_AMT * -1 , '9,999,999.99')
                     @ MLINE,48 SAY 'CRED. PAYMENT - CK # ' + CK_NBR
                     TTOT_CRED = TTOT_CRED + (CRED_AMT * -1)
                     MLINE = MLINE + 1
                  ENDIF
               ENDIF
               SKIP
            ENDDO
            
            SELECT E
            DO FOX_USE WITH "DISBJRN INDEX DISB_PO", .F.
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
            DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR  .AND. PO_SUFFIX = A->PO_SUFFIX
               IF CATEGORY1 = '150' .AND. AMOUNT1 <> 0
                  IF MLINE > MPAGE_LEN
                     IF MDISP_PRT = 'P'
                        IF MLINE <> 99
                           EJECT
                        ENDIF
                     ELSE
                        CLEAR
                     ENDIF
                     MPAGE_NO = MPAGE_NO + 1
                     @ 1,34 SAY MCOMPANY
                     @ 2,0 SAY 'PAGE'
                     @ 2,05 say mpage_no picture '99'
                     @ 2,30 SAY 'PURCHASE ORDER INQUIRY '
                     @ 2,70 SAY DTOC(DATE())
                     @ 4,1 SAY 'PO NUMBER' 
                     @ 4,12 SAY 'INV NBR'  
                     @ 4,23 SAY 'DATE'
                     @ 4,30 SAY '        AMOUNT'
                     @ 4,48 SAY 'DESCRIPTION'
                     IF MDISP_PRT = 'P'
                        @ 4,0 SAY REPLICATE ('_',80)
                     ENDIF
                     MLINE = 6
                     @ MLINE,1 SAY MNAME
                     IF MDISP_PRT = 'P'
                        MLEN = LEN(TRIM(MNAME))
                        @ MLINE,1 SAY REPLICATE('_',MLEN)
                     ENDIF
                     MPRT_NAME = .F.
                     MLINE = MLINE + 1
                  ENDIF
                  
                  IF SALESMAN <> SPACE(2)
                     @ MLINE,1 SAY SALESMAN
                     @ MLINE,3 SAY '-'
                  ENDIF
                  @ MLINE,4 SAY PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,8 SAY '-'
                     @ MLINE,9 SAY PO_SUFFIX
                  ENDIF
                  @ MLINE,13 SAY INV_NBR   
                  
                  @ MLINE,21 SAY CTOD(JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR)
                  
                  @ MLINE,32 SAY TRANSFORM(AMOUNT1, '9,999,999.99')
                  @ MLINE,48 SAY 'A/R REIMURSE - CK # ' + CK_NBR
                  TTOT_RECV = TTOT_RECV + AMOUNT1
               ENDIF
               SKIP
            ENDDO
            
            
         CASE MTYPE = 'S'
            ***********************************           
            **** GET THE SUPPLIER PAYMENTS ****
            ***********************************          
            SELECT E
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX + 'S'
            DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR  .AND. PO_SUFFIX = A->PO_SUFFIX .AND. ACCT_TYPE = 'S'
               IF VOID_MAN <> 'V'
                  IF MLINE > MPAGE_LEN
                     IF MDISP_PRT = 'P'
                        IF MLINE <> 99
                           EJECT
                        ENDIF
                     ELSE
                        CLEAR
                     ENDIF
                     MPAGE_NO = MPAGE_NO + 1
                     @ 1,34 SAY MCOMPANY
                     @ 2,0 SAY 'PAGE'
                     @ 2,05 say mpage_no picture '99'
                     @ 2,30 SAY 'PURCHASE ORDER INQUIRY '
                     @ 2,70 SAY DTOC(DATE())
                     @ 4,1 SAY 'PO NUMBER' 
                     @ 4,12 SAY 'INV NBR'  
                     @ 4,23 SAY 'DATE'
                     @ 4,30 SAY '        AMOUNT'
                     @ 4,48 SAY 'DESCRIPTION'
                     IF MDISP_PRT = 'P'
                        @ 4,0 SAY REPLICATE ('_',80)
                     ENDIF
                     MLINE = 6
                     @ MLINE,1 SAY MNAME
                     IF MDISP_PRT = 'P'
                        MLEN = LEN(TRIM(MNAME))
                        @ MLINE,1 SAY REPLICATE('_',MLEN)
                     ENDIF
                     MPRT_NAME = .F.
                     MLINE = MLINE + 1
                  ENDIF
                  
                  IF SALESMAN <> SPACE(2)
                     @ MLINE,1 SAY SALESMAN
                     @ MLINE,3 SAY '-'
                  ENDIF
                  @ MLINE,4 SAY PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,8 SAY '-'
                     @ MLINE,9 SAY PO_SUFFIX
                  ENDIF
                  @ MLINE,13 SAY INV_NBR   
                  @ MLINE,21 SAY JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR
                  @ MLINE,32 SAY TRANSFORM(AMOUNT1 * -1, '9,999,999.99')
                  @ MLINE,48 SAY 'PAYMENT - CK # ' + CK_NBR
                  TTOT_RECV = TTOT_RECV + (AMOUNT1 * -1)
                  MLINE = MLINE + 1
               ENDIF
               SKIP
            ENDDO
            
            ***********************************          
            SELECT B
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
            DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR  .AND. PO_SUFFIX = A->PO_SUFFIX
               
               IF ACCOUNT <> '151 '
                  SKIP
                  LOOP
               ENDIF
               IF MLINE > MPAGE_LEN
                  IF MDISP_PRT = 'P'
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                  ELSE
                     CLEAR
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 1,34 SAY MCOMPANY
                  @ 2,0 SAY 'PAGE'
                  @ 2,05 say mpage_no picture '99'
                  @ 2,30 SAY 'PURCHASE ORDER INQUIRY '
                  @ 2,70 SAY DTOC(DATE())
                  @ 4,1 SAY 'PO NUMBER' 
                  @ 4,12 SAY 'INV NBR'  
                  @ 4,23 SAY 'DATE'
                  @ 4,30 SAY '        AMOUNT'
                  @ 4,48 SAY 'DESCRIPTION'
                  IF MDISP_PRT = 'P'
                     @ 4,0 SAY REPLICATE ('_',80)
                  ENDIF
                  MLINE = 6
                  @ MLINE,1 SAY MNAME
                  IF MDISP_PRT = 'P'
                     MLEN = LEN(TRIM(MNAME))
                     @ MLINE,1 SAY REPLICATE('_',MLEN)
                  ENDIF
                  MPRT_NAME = .F.
                  MLINE = MLINE + 1
               ENDIF
               
               IF SALESMAN <> SPACE(2)
                  @ MLINE,1 SAY SALESMAN
                  @ MLINE,3 SAY '-'
               ENDIF
               @ MLINE,4 SAY PO_NBR
               IF PO_SUFFIX <> ' '
                  @ MLINE,8 SAY '-'
                  @ MLINE,9 SAY PO_SUFFIX
               ENDIF
               @ MLINE,13 SAY INV_NBR   
               @ MLINE,21 SAY PAID_DATE
               @ MLINE,32 SAY TRANSFORM((AMT_PAID+AMT_OVER+CRED_AMT), '9,999,999.99')
               @ MLINE,48 SAY 'RECEIPT - CK # ' + CK_NBR
               TTOT_RECV = TTOT_RECV + ((AMT_PAID+AMT_OVER+CRED_AMT))
               MLINE = MLINE + 1
               SKIP
            ENDDO
         OTHERWISE
            
            ***********************************           
            **** GET THE FREIGHT PAYMENTS ****
            ***********************************          
            SELECT E
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX + 'F'
            DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR  .AND. PO_SUFFIX = A->PO_SUFFIX .AND. ACCT_TYPE = 'F'
               IF VOID_MAN <> 'V' .AND. ACCT_NBR = A->FRT_CODE1
                  IF MLINE > MPAGE_LEN
                     IF MDISP_PRT = 'P'
                        IF MLINE <> 99
                           EJECT
                        ENDIF
                     ELSE
                        CLEAR
                     ENDIF
                     MPAGE_NO = MPAGE_NO + 1
                     @ 1,34 SAY MCOMPANY
                     @ 2,0 SAY 'PAGE'
                     @ 2,05 say mpage_no picture '99'
                     @ 2,30 SAY 'PURCHASE ORDER INQUIRY '
                     @ 2,70 SAY DTOC(DATE())
                     @ 4,1 SAY 'PO NUMBER' 
                     @ 4,12 SAY 'INV NBR'  
                     @ 4,23 SAY 'DATE'
                     @ 4,30 SAY '        AMOUNT'
                     @ 4,48 SAY 'DESCRIPTION'
                     IF MDISP_PRT = 'P'
                        @ 4,0 SAY REPLICATE ('_',80)
                     ENDIF
                     MLINE = 6
                     @ MLINE,1 SAY MNAME
                     IF MDISP_PRT = 'P'
                        MLEN = LEN(TRIM(MNAME))
                        @ MLINE,1 SAY REPLICATE('_',MLEN)
                     ENDIF
                     MPRT_NAME = .F.
                     MLINE = MLINE + 1
                  ENDIF
                  
                  IF SALESMAN <> SPACE(2)
                     @ MLINE,1 SAY SALESMAN
                     @ MLINE,3 SAY '-'
                  ENDIF
                  @ MLINE,4 SAY PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,8 SAY '-'
                     @ MLINE,9 SAY PO_SUFFIX
                  ENDIF
                  @ MLINE,13 SAY INV_NBR   
                  @ MLINE,21 SAY JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR
                  @ MLINE,32 SAY TRANSFORM(AMOUNT1 * -1, '9,999,999.99')
                  @ MLINE,48 SAY 'PAYMENT - CK # ' + CK_NBR
                  TTOT_RECV = TTOT_RECV + (AMOUNT1 * -1)
                  MLINE = MLINE + 1
               ENDIF
               SKIP
            ENDDO
            ***********************************
            SELECT B
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
            DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR  .AND. PO_SUFFIX = A->PO_SUFFIX
               
               IF ACCOUNT <> '152 '
                  SKIP
                  LOOP
               ENDIF
               IF MLINE > MPAGE_LEN
                  IF MDISP_PRT = 'P'
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                  ELSE
                     CLEAR
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 1,34 SAY MCOMPANY
                  @ 2,0 SAY 'PAGE'
                  @ 2,05 say mpage_no picture '99'
                  @ 2,30 SAY 'PURCHASE ORDER INQUIRY '
                  @ 2,70 SAY DTOC(DATE())
                  @ 4,1 SAY 'PO NUMBER' 
                  @ 4,12 SAY 'INV NBR'  
                  @ 4,23 SAY 'DATE'
                  @ 4,30 SAY '        AMOUNT'
                  @ 4,48 SAY 'DESCRIPTION'
                  IF MDISP_PRT = 'P'
                     @ 4,0 SAY REPLICATE ('_',80)
                  ENDIF
                  MLINE = 6
                  @ MLINE,1 SAY MNAME
                  IF MDISP_PRT = 'P'
                     MLEN = LEN(TRIM(MNAME))
                     @ MLINE,1 SAY REPLICATE('_',MLEN)
                  ENDIF
                  MPRT_NAME = .F.
                  MLINE = MLINE + 1
               ENDIF
               
               IF SALESMAN <> SPACE(2)
                  @ MLINE,1 SAY SALESMAN
                  @ MLINE,3 SAY '-'
               ENDIF
               @ MLINE,4 SAY PO_NBR
               IF PO_SUFFIX <> ' '
                  @ MLINE,8 SAY '-'
                  @ MLINE,9 SAY PO_SUFFIX
               ENDIF
               @ MLINE,13 SAY INV_NBR   
               @ MLINE,21 SAY PAID_DATE
               @ MLINE,32 SAY TRANSFORM((AMT_PAID+AMT_OVER+CRED_AMT), '9,999,999.99')
               @ MLINE,48 SAY 'RECEIPT - CK # ' + CK_NBR
               TTOT_RECV = TTOT_RECV + ((AMT_PAID+AMT_OVER+CRED_AMT))
               MLINE = MLINE + 1
               SKIP
            ENDDO
            
         ENDCASE
         
         IF MDISP_PRT = 'P'
            EJECT
            SET DEVICE TO SCREEN
            SET PRINT OFF
            SET PRINT TO
            SET CONSOLE ON
            IF MPRINTER3 <> 'DONOTPRINT'
               RUN &MPRINTIT3
            ENDIF
         ELSE
            DO CASE
            CASE MTYPE = 'C'
               @ 23,1 SAY '  SPREADSHEET      RECV TOTAL      MISC TOTAL     CRED TOTAL'
               @ 24,1 SAY TTOT_SELL PICTURE '@Z 99,999,999.99'
               @ 24,33 SAY TTOT_MISC PICTURE '@Z 99,999,999.99'
               @ 24,48 SAY TTOT_CRED PICTURE '@Z 99,999,999.99'
            CASE MTYPE = 'S'
               @ 23,1 SAY '  SPREADSHEET      PAYMENT TOTAL'
               @ 24,1 SAY TTOT_PURCH PICTURE '@Z 99,999,999.99'
            OTHERWISE
               @ 23,1 SAY '  SPREADSHEET      PAYMENT TOTAL'
               @ 24,1 SAY TTOT_FRT PICTURE '@Z 99,999,999.99'
            ENDCASE
            @ 24,17 SAY TTOT_RECV PICTURE '@Z 99,999,999.99'
            STORE 'PRESS RETURN' TO MWAIT
            @ 24,67 GET MWAIT
            READ
         ENDIF
         STORE SPACE(2) TO MSALESMAN
         STORE SPACE(4) TO MPO_NBR
         STORE SPACE(1) TO MPO_SUFFIX
      ENDDO
      CLOSE DATA
      
   CASE VAL(MSELECTION) = 8
      **** RECORDING INTRACOMP S/W'S NEVER COMPLETED
      **SELECT B
      **DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PO_SUP", .F.
      **SELECT C
      **DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      **MDOSHORT = .T.
      **DO PO_SEL2
      ************************************************
      **** DO TRANSMITTED ORDERS PROCESSING  *********
      ************************************************
      
      MTITLE = ' - LOG & PRINT / ADD TRANSMITTED ORDERS'
      
      STORE SPACE(1) TO MCHOICE1, MCHOICE2, MCHOICE3
      STORE SPACE(2) TO MTRAN_SALE
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 05,5 SAY "SELECT ONE OF THE FOLLOWING OPTIONS WITH AN 'X'"
         @ 07,5 SAY 'Note: Must print log report/orders before'
         @ 08,5 say '      to BROKER database as transmission file'
         @ 09,5 say '      will be deleted upon completion of adds.'
         
         IF MCOMPANY <> 'DIVISION' .AND. MPROG_CODE = 1   
            @ 12,5 SAY 'Enter Salesperson Code: ' GET MTRAN_SALE PICTURE '@!'   
         ENDIF
         
         @ 14,5 say '1.  Print Log Report & Copies of Orders:  ' get mchoice1 picture '@!'
         @ 16,5 SAY '2.  Add Transmitted Orders to BROKER D/B: ' get mchoice2 picture '@!'
         IF MCOMPANY = 'DIVISION 15'
            @ 18,5 SAY '3.  Print LA Office Daily Aging:          ' GET MCHOICE3 PICTURE '@!'
         ENDIF
         STORE 1 TO MACTION
         @ 23,00 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel'     
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MCOMPANY <> 'DIVISION' .AND. MPROG_CODE = 1
            IF MACTION = 1
               IF MTRAN_SALE = '  '    
                  @ 24,0 CLEAR
                  MWAIT = ' '
                  @ 24,1 SAY 'NO SALESPERSON CODE ENTERED - PRESS RETURN TO REENTER ' GET MWAIT
                  READ
                  @ 24,0 CLEAR
                  MACTION = 2
               ENDIF
               
               IF MTRAN_SALE = '44' .OR. MTRAN_SALE = '65' .OR. MTRAN_SALE = 'MF' .OR. MTRAN_SALE = '39' .or. mtran_sale = '88' .or. mtran_sale = '50'
                  *** THESE SALESPERSONS ARE ONLINE AND OK
               ELSE
                  @ 24,0 CLEAR
                  MWAIT = ' '
                  @ 24,1 SAY 'SALESPERSON NOT ONLINE - PRESS RETURN TO REENTER ' GET MWAIT
                  READ
                  @ 24,0 CLEAR
                  MACTION = 2
               ENDIF
            ENDIF
         ENDIF
      ENDDO
      IF MACTION = 3                                                    
         LOOP
      ENDIF
      
      DO CASE
      CASE MPROG_CODE = 1 .AND. MTRAN_SALE = 'MF'   
         MTRAN_SALE = 'M1'
         RUN COPY \MFI\TRAN_DM1.DBF TRAN_DM1.DBF
         RUN COPY \MFI\TRAN_PM1.DBF TRAN_PM1.DBF
         
      CASE MPROG_CODE = 2
         MTRAN_SALE = 'MF'
      ENDCASE
      
      SELECT A
      IF MTRAN_SALE = '  '
         DO FOX_USE WITH "TRAN_PO", .T.
      ELSE
         MFILE = 'TRAN_P' + MTRAN_SALE
         DO FOX_USE WITH "&MFILE", .T.
      ENDIF
      DO FILELOCK
      GOTO TOP
      DO WHILE .NOT. EOF()
         
         STORE YEAR(SHIP_DATE) TO MYEAR
         MYEAR = STR(MYEAR,4)
         MYEAR = '20' + SUBSTR(MYEAR,3)
         MDATE = SUBSTR(DTOC(SHIP_DATE),1,6) + MYEAR
         MDATE = CTOD(MDATE)
         REPLACE SHIP_DATE WITH MDATE
         
         STORE YEAR(ORD_DATE) TO MYEAR
         MYEAR = STR(MYEAR,4)
         MYEAR = '20' + SUBSTR(MYEAR,3)
         MDATE = SUBSTR(DTOC(ORD_DATE),1,6) + MYEAR
         MDATE = CTOD(MDATE)
         REPLACE ORD_DATE WITH MDATE
         
         STORE YEAR(DEL_REQD) TO MYEAR
         MYEAR = STR(MYEAR,4)
         MYEAR = '20' + SUBSTR(MYEAR,3)
         MDATE = SUBSTR(DTOC(DEL_REQD),1,6) + MYEAR
         MDATE = CTOD(MDATE)
         REPLACE DEL_REQD WITH MDATE
         
         STORE YEAR(TRAN_DATE) TO MYEAR
         MYEAR = STR(MYEAR,4)
         MYEAR = '20' + SUBSTR(MYEAR,3)
         MDATE = SUBSTR(DTOC(TRAN_DATE),1,6) + MYEAR
         MDATE = CTOD(MDATE)
         REPLACE TRAN_DATE WITH MDATE
         
         SKIP
      ENDDO
      
      USE
      
      DO CASE 
      CASE MCHOICE1 = 'X'
         MPRT_ACT = 'C'
         DO PRT_SET
         IF MPRT_ACT <> 'C'
            LOOP   
         ENDIF
         @ 18,1 SAY 'PRINTING LOG.... PLEASE WAIT.'
         MPRT_LOG = .T.
         IF MPRT_LOG
            
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
            
            SELECT A
            
            IF MTRAN_SALE = '  '
               DO FOX_USE WITH "TRAN_PO", .F.
            ELSE
               MFILE = 'TRAN_P' + MTRAN_SALE
               DO FOX_USE WITH "&MFILE", .F.
            ENDIF
            
            MLINE = 99
            MPAGE_NO = 0
            
            DO CASE
            CASE MTRAN_SALE = '44' .OR. MTRAN_SALE = '39' .OR. MTRAN_SALE = '50'
               DO WHILE .NOT. EOF()
                  IF MLINE > 56
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                     MLINE = 2
                     MPAGE_NO = MPAGE_NO + 1
                     @ MLINE,1 SAY 'PAGE  ' + str(mpage_no,3)
                     @ MLINE,25 SAY 'ORDER TRANSMISSION LOG FOR '
                     @ MLINE,54 SAY DATE()
                     @ MLINE,65 SAY TIME()
                     MLINE = MLINE + 2
                     @ MLINE,1 SAY 'ORDER NBR     SHIP DATE'
                     MLINE = MLINE + 2
                  ENDIF
                  @ MLINE,1 SAY SALESMAN+ '-' + PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,8 SAY '-' + PO_SUFFIX
                  ENDIF
                  @ MLINE,15 SAY SHIP_DATE
                  @ MLINE,1 SAY REPLICATE('_',9)
                  
                  IF COR_FLG = 'Y' 
                     @ MLINE,25 SAY '****CORRECTION****'
                  ENDIF
                  
                  MLINE = MLINE + 1
                  @ MLINE,1 SAY 'SELLING: '
                  @ MLINE,12 SAY TOT_SELL+CUS_PALL PICTURE '999,999.99'
                  @ MLINE,25 SAY BBUYNAME
                  @ MLINE,59 SAY BBUYSTRT
                  MLINE = MLINE + 1
                  @ MLINE,59 SAY TRIM(BBUYCITY) + ', ' + BBUYST + ' ' + BBUYZIP
                  @ MLINE,59 SAY REPLICATE('_',33)
                  MLINE = MLINE + 1
                  @ MLINE,1 SAY 'PURCHASE: '
                  @ MLINE,12 SAY TOT_PURCH+SUP_PALL PICTURE '999,999.99'
                  IF MPROG_CODE = 2
                     @ MLINE,25 SAY SUPNAME 
                     @ MLINE,59 SAY SUPSTRT
                     MLINE = MLINE + 1
                     @ MLINE,59 SAY TRIM(SUPCITY) + ', ' + SUPST + ' ' + SUPZIP
                  ELSE
                     @ MLINE,25 SAY RSUPNAME
                     @ MLINE,59 SAY RSUPSTRT
                     MLINE = MLINE + 1
                     @ MLINE,59 SAY TRIM(RSUPCITY) + ', ' + RSUPST + ' ' + RSUPZIP
                  ENDIF
                  
                  IF FRT_NAME <> SPACE(32)
                     MLINE = MLINE + 1
                     @ MLINE,1 SAY 'FREIGHT: '
                     @ MLINE,12 SAY FRT_AMT1 PICTURE '999,999.99'
                     @ MLINE,25 SAY FRT_NAME
                  ENDIF
                  **IF SALESMAN = '44'
                  IF FRT_NAME2 <> SPACE(32)
                     MLINE = MLINE + 1
                     @ MLINE,1 SAY 'FREIGHT: '
                     @ MLINE,12 SAY FRT_AMT2 PICTURE '999,999.99'
                     @ MLINE,25 SAY FRT_NAME2
                  ENDIF
                  **ENDIF
                  MLINE = MLINE + 2
                  SKIP
               ENDDO
               IF MLINE =99
                  MLINE = 2
                  MPAGE_NO = MPAGE_NO + 1
                  @ MLINE,1 SAY 'PAGE  ' + str(mpage_no,3)
                  @ MLINE,25 SAY 'ORDER TRANSMISSION LOG FOR '
                  @ MLINE,54 SAY DATE()
                  @ MLINE,65 SAY TIME()
                  MLINE = MLINE + 2
                  @ MLINE,1 SAY 'ORDERS'                   
                  MLINE = MLINE + 2
                  @ MLINE,1 SAY 'NO TRANSMITTED ORDERS ON FILE FOR LOG PRINT'
               ENDIF
               
            OTHERWISE
               DO WHILE .NOT. EOF()
                  IF MLINE > 56
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                     MLINE = 2
                     MPAGE_NO = MPAGE_NO + 1
                     @ MLINE,1 SAY 'PAGE  ' + str(mpage_no,3)
                     @ MLINE,25 SAY 'ORDER TRANSMISSION LOG FOR '
                     @ MLINE,54 SAY DATE()
                     @ MLINE,65 SAY TIME()
                     MLINE = MLINE + 2
                     @ MLINE,1 SAY 'ORDER NBR     SHIP DATE'
                     **@ MLINE,1 SAY 'ORDERS'                   
                     MLINE = MLINE + 2
                  ENDIF
                  @ MLINE,1 SAY SALESMAN+ '-' + PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,8 SAY '-' + PO_SUFFIX
                  ENDIF
                  @ MLINE,15 SAY SHIP_DATE
                  @ MLINE,1 SAY REPLICATE('_',9)
                  
                  *** FOR DIVISION 15 - I AM CAPTURING CORRECTIONS
                  IF MCOMPANY = 'DIVISION 15' .OR. MPROG_CODE = 2
                     IF COR_FLG = 'Y' 
                        @ MLINE,25 SAY '****CORRECTION****'
                     ENDIF
                  ENDIF
                  
                  MLINE = MLINE + 1
                  @ MLINE,1 SAY 'SELLING: '
                  @ MLINE,12 SAY TOT_SELL+CUS_PALL PICTURE '999,999.99'
                  @ MLINE,25 SAY BBUYNAME
                  @ MLINE,59 SAY BBUYSTRT
                  MLINE = MLINE + 1
                  @ MLINE,59 SAY TRIM(BBUYCITY) + ', ' + BBUYST + ' ' + BBUYZIP
                  @ MLINE,59 SAY REPLICATE('_',33)
                  MLINE = MLINE + 1
                  @ MLINE,1 SAY 'PURCHASE: '
                  @ MLINE,12 SAY TOT_PURCH+SUP_PALL PICTURE '999,999.99'
                  IF MPROG_CODE = 2
                     @ MLINE,25 SAY SUPNAME 
                     @ MLINE,59 SAY SUPSTRT
                     MLINE = MLINE + 1
                     @ MLINE,59 SAY TRIM(SUPCITY) + ', ' + SUPST + ' ' + SUPZIP
                  ELSE
                     @ MLINE,25 SAY RSUPNAME
                     @ MLINE,59 SAY RSUPSTRT
                     MLINE = MLINE + 1
                     @ MLINE,59 SAY TRIM(RSUPCITY) + ', ' + RSUPST + ' ' + RSUPZIP
                  ENDIF
                  
                  IF FRT_NAME <> SPACE(32)
                     MLINE = MLINE + 1
                     @ MLINE,1 SAY 'FREIGHT: '
                     @ MLINE,12 SAY FRT_AMT1 PICTURE '999,999.99'
                     @ MLINE,25 SAY FRT_NAME
                  ENDIF
                  **IF SALESMAN = '44'
                  IF FRT_NAME2 <> SPACE(32)
                     MLINE = MLINE + 1
                     @ MLINE,1 SAY 'FREIGHT2: '
                     @ MLINE,12 SAY FRT_AMT2 PICTURE '999,999.99'
                     @ MLINE,25 SAY FRT_NAME2
                  ENDIF
                  ***ENDIF
                  IF MPROG_CODE = 2
                     IF FRT_NAME2 <> SPACE(32)
                        MLINE = MLINE + 1
                        @ MLINE,1 SAY 'FREIGHT2: '
                        @ MLINE,12 SAY FRT_AMT2 PICTURE '999,999.99'
                        @ MLINE,25 SAY FRT_NAME2
                     ENDIF
                     IF FRT_NAME3 <> SPACE(32)
                        MLINE = MLINE + 1
                        @ MLINE,1 SAY 'FREIGHT3: '
                        @ MLINE,12 SAY FRT_AMT3 PICTURE '999,999.99'
                        @ MLINE,25 SAY FRT_NAME3
                     ENDIF
                     
                  ENDIF
                  MLINE = MLINE + 2
                  SKIP
               ENDDO
               IF MLINE =99
                  MLINE = 2
                  MPAGE_NO = MPAGE_NO + 1
                  @ MLINE,1 SAY 'PAGE  ' + str(mpage_no,3)
                  @ MLINE,25 SAY 'ORDER TRANSMISSION LOG FOR '
                  @ MLINE,54 SAY DATE()
                  @ MLINE,65 SAY TIME()
                  MLINE = MLINE + 2
                  @ MLINE,1 SAY 'ORDERS'                   
                  MLINE = MLINE + 2
                  @ MLINE,1 SAY 'NO TRANSMITTED ORDERS ON FILE FOR LOG PRINT'
                  @ MLINE+1,1 SAY ' '
               ENDIF
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
         ENDIF
         
         SET CONFIRM ON
         MCONT = SPACE(8)
         DO WHILE MCONT <> 'CONTINUE' .AND. MCONT <> 'EXIT    '
            @ 18,1 SAY 'WAITING ON YOU !!!  Please select DRAFT MODE and'
            @ 19,1 SAY 'key in "CONTINUE" when ready to print orders: ' get mcont picture '@!'       
            @ 21,1 SAY '(or "EXIT" if you got here by mistake!!!)'
            READ
         ENDDO
         SET CONFIRM OFF
         @ 18,1 SAY SPACE(70)
         @ 19,1 SAY SPACE(70)
         @ 21,1 SAY SPACE(70)
         IF MCONT <> 'EXIT    '
            @ 18,1 SAY 'PRINTING ORDERS.... PLEASE WAIT...'              
            **** NOW PRINT OUT THE ORDERS
            SELECT C
            IF MTRAN_SALE = '  '
               USE TRAN_DTL EXCLUSIVE
               INDEX ON SALESMAN + PO_NBR+ PO_SUFFIX TO TRAN_DTL
               USE
               DO FOX_USE WITH "TRAN_DTL INDEX TRAN_DTL", .F.
            ELSE
               MFILE = 'TRAN_D' + MTRAN_SALE
               USE &MFILE EXCLUSIVE
               INDEX ON SALESMAN + PO_NBR+ PO_SUFFIX TO &MFILE   
               USE
               DO FOX_USE WITH "&MFILE INDEX &MFILE", .F.
            ENDIF
            
            SELECT B
            IF MTRAN_SALE = '  '
               DO FOX_USE WITH "TRAN_PO", .F.
            ELSE
               MFILE = 'TRAN_P' + MTRAN_SALE
               DO FOX_USE WITH "&MFILE", .F.
            ENDIF
            
            DO WHILE .NOT. EOF()
               MFRT_COPY = .F.
               DO PO_PRT
               SELECT B   
               
               DO CASE
               CASE MCOMPANY = 'DIVISION 15'
                  IF COR_FLG <> 'Y' .AND. BBUYNAME <> 'SALESPERSON'
                     IF FRT_NAME <> SPACE(32)
                        MFRT_COPY = .T.
                        SELECT B
                        MSUP_NAME = RSUPNAME
                        MSUP_STRT  = RSUPSTRT           
                        MSUP_CITYST = TRIM(RSUPCITY) + ', ' + RSUPST + '  ' + RSUPZIP 
                        MCUS_NAME = BBUYNAME
                        MCUS_STRT  = BBUYSTRT          
                        MCUS_CITYST = TRIM(BBUYCITY) + ', ' + BBUYST + '  ' + BBUYZIP
                        MFRT_NAME1 = FRT_NAME            
                        SELECT F
                        DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
                        SEEK MSALESMAN
                        IF .NOT. EOF()
                           MSAL_NAME = NAME
                        ELSE
                           MSAL_NAME = 'SALESPERSON NAME NOT ON FILE' + SPACE(4)
                        ENDIF
                        DO PRT_1FRT
                     ENDIF
                  ENDIF
               OTHERWISE
                  IF COR_FLG <> 'Y' .AND. BBUYNAME <> 'SALESPERSON'
                     ***IF BBUYNAME <> 'SALESPERSON'
                     IF FRT_NAME <> SPACE(32)
                        MFRT_COPY = .T.
                        SELECT B
                        MSUP_NAME = RSUPNAME
                        MSUP_STRT  = RSUPSTRT           
                        MSUP_CITYST = TRIM(RSUPCITY) + ', ' + RSUPST + '  ' + RSUPZIP 
                        MCUS_NAME = BBUYNAME
                        MCUS_STRT  = BBUYSTRT          
                        MCUS_CITYST = TRIM(BBUYCITY) + ', ' + BBUYST + '  ' + BBUYZIP
                        MFRT_NAME1 = FRT_NAME            
                        SELECT F
                        DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
                        SEEK MSALESMAN
                        IF .NOT. EOF()
                           MSAL_NAME = NAME
                        ELSE
                           MSAL_NAME = 'SALESPERSON NAME NOT ON FILE' + SPACE(4)
                        ENDIF
                        DO PRT_1FRT
                     ENDIF
                     **IF MSALESMAN = '44'
                     IF B->FRT_NAME2 <> SPACE(32)
                        MFRT_COPY = .T.
                        SELECT B
                        MSUP_NAME = RSUPNAME
                        MSUP_STRT  = RSUPSTRT           
                        MSUP_CITYST = TRIM(RSUPCITY) + ', ' + RSUPST + '  ' + RSUPZIP 
                        MCUS_NAME = BBUYNAME
                        MCUS_STRT  = BBUYSTRT          
                        MCUS_CITYST = TRIM(BBUYCITY) + ', ' + BBUYST + '  ' + BBUYZIP
                        MFRT_NAME = FRT_NAME2            
                        MFRT_AMT  = FRT_AMT2
                        SELECT F
                        DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
                        SEEK MSALESMAN
                        IF .NOT. EOF()
                           MSAL_NAME = NAME
                        ELSE
                           MSAL_NAME = 'SALESPERSON NAME NOT ON FILE' + SPACE(4)
                        ENDIF
                        DO PRT_2FRT
                     ENDIF
                     **ENDIF
                  ENDIF
               ENDCASE 
               SELECT B
               SKIP
            ENDDO 
         ENDIF
         
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         
         **************************************************************
         *** THIS NEEDS TO STAY ON EPSON PRINTER UNTIL ORDERS MOVED ***
         **************************************************************
         
         IF MPRINTER <> 'DONOTPRINT'
            RUN &MPRINTIT
         ENDIF
         
         **************************************************************
         *** THIS NEEDS TO STAY ON EPSON PRINTER UNTIL ORDERS MOVED ***
         **************************************************************
         
      CASE MCHOICE2 = 'X'
         DO TRAN_ADD
         
      CASE MCHOICE3 = 'X'
         DO SHRT_AGE
         
      ENDCASE
      
      CLOSE DATA
      
   CASE MSELECTION = 'P'
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PRINT, PO_SUP, PO_SHIP, PO_FRT", .F.
      SELECT C
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      DO PO_PRT1

      
   CASE MSELECTION = 'A'
      DO CONFIRM
      
   CASE MSELECTION = 'B'
      DO ORD_MARG
      
   CASE MSELECTION = 'D'
      DO ENT_ORDS
      
   CASE MSELECTION = 'H'
      DO HOLDRPT
      
   CASE MSELECTION = 'W'
      DO WHITEBRD
      
   CASE MSELECTION = 'F'
      DO FRT_SHIP
      
   CASE MSELECTION = 'R'
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PRINT, PO_SUP, PO_SHIP, PO_FRT", .F.
      SELECT C
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      DO PO_RELE
      CLOSE DATA
   CASE MSELECTION = 'S'
      DO SAMPRQST
   CASE MSELECTION = 'T'
      SET PROC TO PO
      DO CINV_PRI
      SET PROC TO PO_PROC
   ENDCASE
   
ENDDO
SET PROC TO PO_PROC
RETURN

PROCEDURE CINV_PRI 
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - PRINT ORDERS NEEDING PRICE CHGS'
@ 3,0 TO 22,79
MMORE = .T.
DO WHILE MMORE
   MLOT_NBR = SPACE(10)
   MFREEZ_LOC = SPACE(32)
   @  8, 5 SAY 'Lot Nbr:'
   @ 10,5 SAY  'Freezer:'
   MACTION = 2
   DO WHILE MACTION = 2
      @ 24,0 CLEAR
      @  8,14 GET MLOT_NBR PICTURE '@!'
      @ 10,14 GET MFREEZ_LOC PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   
   IF MACTION = 3 .OR. MLOT_NBR = SPACE(10)
      MMORE = .F.
      LOOP
   ENDIF 
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
   
   @ 3,4 SAY DATE()
   @ 3,20 SAY 'ORDERS NEEDING CORRECTIONS FOR INVENTORY PRICE CHANGE'
   @ 4,20 SAY 'LOT NUMBER: ' + MLOT_NBR
   MLINE = 6
   
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_NAME, &MDBFLOC.SUP_CODE", .F.
   SEEK TRIM(MFREEZ_LOC)
   STORE NAME TO MFREEZ_LOC
   
   DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT, HINV_DTL", .F.
   SEEK MFREEZ_LOC + MLOT_NBR
   
   DO WHILE .NOT. EOF() .AND. FREEZ_LOC = TRIM(MFREEZ_LOC) .AND. LOT_NBR = MLOT_NBR
      IF ACTIVITY = 'IN'
         SKIP
         LOOP
      ENDIF
      @ MLINE,4 SAY SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
      @ MLINE,17 SAY 'ON HOLD'
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT", .F.
   SEEK MFREEZ_LOC + MLOT_NBR
   DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT_NBR
      IF ACTIVITY = 'IN'
         SKIP
         LOOP
      ENDIF
      @ MLINE,4 SAY SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
      @ MLINE,17 SAY 'RELEASED'
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF MLINE = 6
      @ 10,4 SAY 'No Shipments Out of Selected Lot Found'
      @ 11,1 SAY ' '
   ELSE
      @ MLINE+1,1 SAY ' '
   ENDIF
   
   EJECT
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
   
ENDDO
CLOSE DATA
RETURN


PROCEDURE AGE_HEAD
IF MLINE > MPAGE_LEN
   IF MLINE <> 99
      EJECT
   ENDIF
   MPAGE_NO = MPAGE_NO + 1
   @ 2,36 SAY MCOMPANY
   @ 3,1 SAY 'Page'
   @ 3,06 say mpage_no picture '99'
   @ 3,28 SAY 'OVERDUE ACCOUNTS REPORT AS OF ' + DTOC(MRPT_DATE)
   @ 3,88 SAY DTOC(DATE())
   IF MPRT_CUST
      @ 5,1 SAY 'CUSTOMER'
      IF MPROG_CODE <> 2
         @ 5,15 SAY 'INV AMT'
      ENDIF
      @ 5,28 SAY 'AMT DUE'
      @ 5,40 SAY 'CUST PO #'
      @ 5,59 SAY 'PO #'
      IF MCOMPANY = 'AMERICHICKEN, INC'
         @ 5,70 SAY 'DELV DT '
      ENDIF
      @ 5,80 SAY 'DAYS OLD'
      @ 5,89 SAY ' PAST ' + STR(MSEL_DAYS,2)
      @ 5,1 SAY REPLICATE('_',98)
      MLINE = 7
      @ MLINE,1 SAY MNAME
      @ MLINE,45 SAY MPHONE
      MLINE = MLINE + 1
      MPRT_CUST = .F.
   ELSE
      MLINE = 7
   ENDIF
ENDIF
RETURN

PROCEDURE AGE_WARN 
IF MLINE > MPAGE_LEN
   IF MLINE <> 99
      EJECT
   ENDIF
   MPAGE_NO = MPAGE_NO + 1
   @ 2,36 SAY MCOMPANY
   @ 3,1 SAY 'Page'
   @ 3,06 say mpage_no picture '99'
   @ 3,28 SAY 'CUSTOMER CREDIT ADVISEMENT AS OF ' + DTOC(MRPT_DATE)
   @ 3,88 SAY DTOC(DATE())
   IF MPRT_CUST
      @ 5,1 SAY 'CUSTOMER'
      IF MPROG_CODE <> 2
         @ 5,15 SAY 'INV AMT'
      ENDIF
      @ 5,28 SAY 'AMT DUE'
      @ 5,40 SAY 'CUST PO #'
      @ 5,59 SAY 'PO #'
      @ 5,70 SAY 'SHIP DT '
      @ 5,80 SAY 'DAYS OLD'
      @ 5,89 SAY ' PAST ' + STR(MSEL_DAYS,2)
      @ 5,1 SAY REPLICATE('_',98)
      MLINE = 7
      @ MLINE,1 SAY MNAME
      @ MLINE,45 SAY MPHONE
      MLINE = MLINE + 1
      MPRT_CUST = .F.
   ELSE
      MLINE = 7
   ENDIF
ENDIF
RETURN

* EOF: PO.PRG
*Formatted by: ToolBox Ver. 1.2  on 1/7/16 at 11:43 AM.
