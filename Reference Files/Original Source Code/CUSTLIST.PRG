****************
* Program.: CUSTLIST.PRG
* Author..: GRACE KELLER
* Date....: 10/26/87
* Notice..: Copyright (C) 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRICING MASTER LISTING
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MTITLE = ' - PRICING MASTER LISTING'
CLEAR
@ 01,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@  2,0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
MCUTOFF = CTOD('')
MCHOICE = ' '
MFILE_PRT = ' '
mopt_prod = space(10)
@ 05,5 SAY 'Only Select those with Order Activity on/after this Date: ' GET MCUTOFF 
@ 08,5 SAY 'Supplier or Customer Pricing Master (S/C): ' GET MCHOICE PICTURE '@!' VALID(MCHOICE = ' ' .OR. MCHOICE = 'S' .OR. MCHOICE = 'C')
READ
IF MCHOICE = ' '
   RETURN
ENDIF
MORDER = ' '
IF MCHOICE = 'C'
   MSEL_BBUY = SPACE(4)
   MYES_NO = '   '
   MACTION = 2
   DO WHILE MACTION = 2
      @ 10,5 say 'Optional Product: ' get mopt_proD picture '@!'
      @ 12,5 SAY 'Do you want to select a specific customer (YES/NO) ' GET MYES_NO PICTURE '@!'
      @ 14,5 SAY 'Print in Name Order (N) -or- Product Order (P) ' get MORDER PICTURE '@!' VALID(MORDER = 'N' .OR. MORDER = 'P')
      @ 16,5 say '  Create Excel File (F) -or- Print Report  (P) ' get MFILE_PRT PICTURE '@!'
      STORE 1 TO MACTION
      @ 23,00 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MACTION = 3     
      MDO_AGAIN = .F.
      RETURN   
   ENDIF  
   IF MYES_NO = 'YES'
      **** SELECT A CUSTOMER HERE 
      SAVE SCREEN TO MGRACE
      MNAME_FD = .F.
      DO BBUYSEL3
      IF .NOT. MNAME_FD
         CLOSE DATA
         RESTORE SCREEN FROM MGRACE
         MWAIT = ' '
         @ 14,5 SAY 'CUSTOMER NOT FOUND - PRESS RETURN TO CONTINUE' GET MWAIT
         READ
         RETURN
      ENDIF
      MSEL_BBUY = BBUYCODE
      CLOSE DATA
      RESTORE SCREEN FROM MGRACE
   ENDIF
ELSE
   MSEL_RSUP = SPACE(4)
   MYES_NO = '   '
   MACTION = 2
   DO WHILE MACTION = 2
      @ 10,5 say 'Optional Product: ' get mopt_proD picture '@!'
      @ 12,5 SAY 'Do you want to select a specific supplier (YES/NO) ' GET MYES_NO PICTURE '@!'
      @ 14,5 SAY 'Print in Name Order (N) -or- Product Order (P) ' get MORDER PICTURE '@!' VALID(MORDER = 'N' .OR. MORDER = 'P')
      @ 16,5 say '  Create Excel File (F) -or- Print Report  (P) ' get MFILE_PRT PICTURE '@!'
      STORE 1 TO MACTION
      @ 23,00 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MACTION = 3     
      MDO_AGAIN = .F.
      RETURN   
   ENDIF  
   IF MYES_NO = 'YES'
      **** SELECT A SUPPLIER HERE 
      SAVE SCREEN TO MGRACE
      MNAME_FD = .F.
      DO RSUPSEL3
      IF .NOT. MNAME_FD
         CLOSE DATA
         RESTORE SCREEN FROM MGRACE
         MWAIT = ' '
         @ 14,5 SAY 'SUPPLIER NOT FOUND - PRESS RETURN TO CONTINUE' GET MWAIT
         READ
         RETURN
      ENDIF
      MSEL_RSUP = RSUPCODE
      CLOSE DATA
      RESTORE SCREEN FROM MGRACE
   ENDIF
ENDIF
IF MFILE_PRT <> 'F' .AND. MFILE_PRT <> 'P'
   MFILE_PRT = 'P'
ENDIF
*** INITIALIZE FILES
SELECT A
DO FOX_USE WITH "&MDBFLOC.PRI_MAST", .T.
REPLACE ALL LAST_SHIP WITH CTOD('')
REPLACE ALL LBS_SHIP  WITH 0

DO FOX_USE WITH "&MDBFLOC.SUP_MAST", .T.
REPLACE ALL LAST_SHIP WITH CTOD('')
REPLACE ALL LBS_SHIP  WITH 0
USE

DO FOX_USE WITH "TMP_XCEL", .T.
DELETE ALL
PACK
USE

MPRT_ACT = 'C'

IF MFILE_PRT = 'P'
   STORE ' ' TO MPRT_ACT
   DO PRT_SET
   IF MPRT_ACT <> 'C'
      RETURN
   ENDIF 
ELSE 
   @ 18,5 SAY 'PROCESSING PLEASE WAIT....'
ENDIF


DO CASE
CASE MCHOICE = 'C'
   SELECT D
   DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
   
   SELECT B
   DO FOX_USE WITH "PO_HEAD", .F.
   SET FILTER TO SHIP_DATE >= MCUTOFF
   GOTO TOP
   
   SELECT C
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
   
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.PRI_MAST", .T.
   *** GET THE CUSTOMER NAMES SET UP
   DO WHILE .NOT. EOF()
      SELECT C
      SEEK A->BBUYCODE
      IF .NOT. EOF()
         SELECT A
         REPLACE NAME WITH C->NAME
      ENDIF
      SELECT A
      SKIP
   ENDDO
   
   SELECT A
   INDEX ON BBUYCODE + PROD_DESC TO  &MDBFLOC.TMP_PRI
   USE
   DO FOX_USE WITH "&MDBFLOC.PRI_MAST INDEX &MDBFLOC.TMP_PRI", .F.
   
   SELECT B
   
   DO WHILE .NOT. EOF()
      
      SELECT D
      SEEK B->SALESMAN+B->PO_NBR+B->PO_SUFFIX
      
      DO WHILE .NOT. EOF() .AND. SALESMAN+PO_NBR+PO_SUFFIX = B->SALESMAN+B->PO_NBR+B->PO_SUFFIX
         IF LBS <= 0
            SKIP
            LOOP
         ENDIF
         
         SELECT A
         SEEK B->BBUYCODE + D->PROD_DESC
         
         IF .NOT. EOF()
            IF LAST_SHIP = CTOD('')
               DO RECLOCK
               REPLACE LAST_SHIP WITH B->SHIP_DATE
               UNLOCK
            ELSE
               IF B->SHIP_DATE > LAST_SHIP
                  DO RECLOCK
                  REPLACE LAST_SHIP WITH B->SHIP_DATE
                  UNLOCK
               ENDIF
            ENDIF
            DO RECLOCK
            REPLACE LBS_SHIP WITH D->LBS
            UNLOCK
         ENDIF
         SELECT D
         SKIP
      ENDDO
      SELECT B
      SKIP
   ENDDO
   
   CLOSE DATA
   
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.PRI_MAST", .T.
   IF MORDER = 'N'
      INDEX ON NAME TO  &MDBFLOC.PRI_TEMP
   ELSE
      INDEX ON PROD_DESC + NAME TO &MDBFLOC.PRI_TEMP
   ENDIF
   DO FOX_USE WITH "&MDBFLOC.PRI_MAST INDEX &MDBFLOC.PRI_TEMP", .F.
   IF MOPT_PROD <> SPACE(10)
      SET FILTER TO PROD_DESC = MOPT_PROD .AND. LAST_SHIP >= MCUTOFF
   ELSE
      SET FILTER TO LAST_SHIP >= MCUTOFF
   ENDIF
   GOTO TOP
   
OTHERWISE
   SELECT C
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
   
   SELECT D
   DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
   
   SELECT B
   DO FOX_USE WITH "PO_HEAD", .F.
   SET FILTER TO SHIP_DATE >= MCUTOFF
   GOTO TOP
   
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.SUP_MAST", .T.
   *** GET THE SUPPLIER NAMES SET UP
   
   DO WHILE .NOT. EOF()
      SELECT C
      SEEK A->RSUPCODE
      IF .NOT. EOF()
         SELECT A
         REPLACE NAME WITH C->NAME
      ENDIF
      SELECT A
      SKIP
   ENDDO
   
   SELECT A
   INDEX ON RSUPCODE + PROD_DESC TO  &MDBFLOC.TMP_PRI
   USE
   DO FOX_USE WITH "&MDBFLOC.SUP_MAST INDEX &MDBFLOC.TMP_PRI", .F.
   
   SELECT B
   
   DO WHILE .NOT. EOF()
      
      SELECT D
      SEEK B->SALESMAN+B->PO_NBR+B->PO_SUFFIX
      
      DO WHILE .NOT. EOF() .AND. SALESMAN+PO_NBR+PO_SUFFIX = B->SALESMAN+B->PO_NBR+B->PO_SUFFIX
         IF LBS <= 0
            SKIP
            LOOP
         ENDIF
         
         SELECT A
         SEEK B->RSUPCODE + D->PROD_DESC
         
         IF .NOT. EOF()
            IF LAST_SHIP = CTOD('')
               DO RECLOCK
               REPLACE LAST_SHIP WITH B->SHIP_DATE
               UNLOCK
            ELSE
               IF B->SHIP_DATE > LAST_SHIP
                  DO RECLOCK
                  REPLACE LAST_SHIP WITH B->SHIP_DATE
                  UNLOCK
               ENDIF
            ENDIF
            DO RECLOCK
            REPLACE LBS_SHIP WITH D->LBS
            UNLOCK
         ENDIF
         SELECT D
         SKIP
      ENDDO
      SELECT B
      SKIP
   ENDDO
   
   
   CLOSE DATA
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.SUP_MAST", .T.
   INDEX ON NAME TO  &MDBFLOC.SUP_TEMP
   DO FOX_USE WITH "&MDBFLOC.SUP_MAST INDEX &MDBFLOC.SUP_TEMP", .F.
   IF MOPT_PROD <> SPACE(10)
      SET FILTER TO PROD_DESC = MOPT_PROD .AND. LAST_SHIP >= MCUTOFF
   ELSE
      SET FILTER TO LAST_SHIP >= MCUTOFF
   ENDIF
   GOTO TOP
   
ENDCASE

DO CASE
CASE MFILE_PRT = 'F'
   SELECT E
   DO FOX_USE WITH "TMP_XCEL", .T.
   
   DO CASE
   CASE MORDER = 'P'
      
      STORE SPACE(32) TO MNAME
      STORE SPACE(10) TO MPROD_DESC
      SELECT E
      APPEND BLANK
      REPLACE PRODUCT WITH DTOC(DATE())
      REPLACE NAME WITH 'AMERICHICKEN PRICING MASTER'
      APPEND BLANK
      REPLACE NAME WITH 'Products Shipped on/after ' + DTOC(MCUTOFF)
      APPEND BLANK
      APPEND BLANK
      IF MCHOICE = 'C'
         REPLACE NAME WITH 'CUSTOMER'
      ELSE
         REPLACE NAME WITH 'SUPPLIER'
      ENDIF
      REPLACE PRODUCT WITH 'PRODUCT'
      APPEND BLANK
      
      SELECT A
      DO WHILE .NOT. EOF()
         DO CASE
         CASE MCHOICE = 'C'
            IF MSEL_BBUY <> SPACE(4)
               IF MSEL_BBUY <> BBUYCODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
         OTHERWISE
            IF MSEL_RSUP <> SPACE(4)
               IF MSEL_RSUP <> RSUPCODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
         ENDCASE
         
         STORE PROD_DESC TO MPROD_DESC
         
         SELECT E
         
         APPEND BLANK
         REPLACE PRODUCT WITH MPROD_DESC
         MAPPEND = .F.
         SELECT A
         DO WHILE .NOT. EOF() .AND. PROD_DESC = MPROD_DESC
            DO CASE
            CASE MCHOICE = 'C'
               IF MSEL_BBUY <> SPACE(4)
                  IF MSEL_BBUY <> BBUYCODE
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
            OTHERWISE
               IF MSEL_RSUP <> SPACE(4)
                  IF MSEL_RSUP <> RSUPCODE
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
            ENDCASE
            
            SELECT E
            IF MAPPEND
               APPEND BLANK
            ELSE
               MAPPEND = .T.
            ENDIF
            
            REPLACE NAME WITH A->NAME
            
            DO CASE
            CASE A->PRICE3 <> 0
               REPLACE CUR_PRICE WITH A->PRICE3
            CASE A->PRICE2 <> 0
               REPLACE CUR_PRICE WITH A->PRICE2
            OTHERWISE
               REPLACE CUR_PRICE WITH A->PRICE1 
            ENDCASE
            
            REPLACE LBS_CASES WITH A->LBS_SHIP
            SELECT A
            SKIP
         ENDDO
         SELECT E
         APPEND BLANK
         SELECT A
      ENDDO
   OTHERWISE
      SELECT E
      APPEND BLANK
      REPLACE PRODUCT WITH DTOC(DATE())
      IF MCHOICE = 'C'
         REPLACE NAME WITH 'AMERICHICKEN CUSTOMER PRICING MASTER'
      ELSE
         REPLACE NAME WITH 'AMERICHICKEN SUPPLIER PRICING MASTER'
      ENDIF
      APPEND BLANK
      REPLACE NAME WITH 'Products Shipped on/after ' + DTOC(MCUTOFF)
      APPEND BLANK
      APPEND BLANK
      IF MCHOICE = 'C'
         REPLACE NAME WITH 'CUSTOMER'
      ELSE
         REPLACE NAME WITH 'SUPPLIER'
      ENDIF
      REPLACE PRODUCT WITH 'PRODUCT'
      APPEND BLANK
      STORE SPACE(32) TO MNAME
      
      SELECT A
      DO WHILE .NOT. EOF()
         DO CASE
         CASE MCHOICE = 'C'
            IF MSEL_BBUY <> SPACE(4)
               IF MSEL_BBUY <> BBUYCODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
         OTHERWISE
            IF MSEL_RSUP <> SPACE(4)
               IF MSEL_RSUP <> RSUPCODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
         ENDCASE
         
         SELECT E
         IF A->NAME <> MNAME
            APPEND BLANK
            APPEND BLANK
            REPLACE NAME WITH A->NAME
            MNAME = A->NAME
            REPLACE PRODUCT WITH A-> PROD_DESC
         ELSE
            APPEND BLANK
            REPLACE PRODUCT WITH A-> PROD_DESC
         ENDIF

         REPLACE PRODUCT WITH A-> PROD_DESC
         
         DO CASE
         CASE A->PRICE3 <> 0
            REPLACE CUR_PRICE WITH A->PRICE3
         CASE A->PRICE2 <> 0
            REPLACE CUR_PRICE WITH A->PRICE2
         OTHERWISE
            REPLACE CUR_PRICE WITH A->PRICE1
         ENDCASE
         REPLACE LBS_CASES WITH A->LBS_SHIP
         SELECT A
         SKIP
      ENDDO
   ENDCASE
   
   SELECT E
   APPEND BLANK
   
   **** back to regular
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
   ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
   
   *** LETTER SIZE PAPER
   ?? CHR(27) + '&l2A'
   
   *** PORTRAIT MODE
   ?? CHR(27) + '&l0O'
   
   DO CASE
      
   CASE MCHOICE = 'C' .AND. MORDER = 'P'
      MLINE = 99
      MPAGE_NO = 0
      MFIRST_TM = .T.
      STORE SPACE(32) TO MNAME
      STORE SPACE(10) TO MPROD_DESC
      
      DO WHILE .NOT. EOF()
         IF MSEL_BBUY <> SPACE(4)
            IF MSEL_BBUY <> BBUYCODE
               SKIP
               LOOP
            ENDIF
         ENDIF
         STORE PROD_DESC TO MPROD_DESC
         IF MLINE > 56
            IF MFIRST_TM
               MFIRST_TM = .F.
            ELSE
               EJECT
            ENDIF
            MLINE = 2
            MPAGE_NO = MPAGE_NO + 1
            @ MLINE,11 SAY 'PAGE  ' + str(mpage_no,3)
            @ MLINE,30 say 'AMERICHICKEN CUSTOMER PRICING MASTER'
            @ MLINE,82 SAY DTOC(DATE())
            MLINE = MLINE + 1
            @ MLINE,30 SAY 'Products Shipped on/after ' + DTOC(MCUTOFF)
            MLINE = MLINE + 2
            @ MLINE,11 SAY 'Customer                           Cur Price          Lbs/Cases'
            MLINE = MLINE + 2
            @ MLINE,11 SAY MPROD_DESC
            MLINE = MLINE + 1
         ELSE
            MLINE = MLINE + 1
            @ MLINE,11 SAY MPROD_DESC
            MLINE = MLINE + 1
         ENDIF
         
         
         DO WHILE .NOT. EOF() .AND. PROD_DESC = MPROD_DESC
            IF MSEL_BBUY <> SPACE(4)
               IF MSEL_BBUY <> BBUYCODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            IF MLINE > 56
               IF MFIRST_TM
                  MFIRST_TM = .F.
               ELSE
                  EJECT
               ENDIF
               MLINE = 2
               MPAGE_NO = MPAGE_NO + 1
               @ MLINE,11 SAY 'PAGE  ' + str(mpage_no,3)
               @ MLINE,30 say 'AMERICHICKEN CUSTOMER PRICING MASTER'
               @ MLINE,82 SAY DTOC(DATE())
               MLINE = MLINE + 1
               @ MLINE,30 SAY 'Products Shipped on/after ' + DTOC(MCUTOFF)
               MLINE = MLINE + 2
               @ MLINE,11 SAY 'Customer                           Cur Price          Lbs/Cases'
               MLINE = MLINE + 2
               @ MLINE,11 SAY MPROD_DESC
               MLINE = MLINE + 1
            ENDIF
            
            @ MLINE,11 SAY NAME
            DO CASE
            CASE PRICE3 <> 0
               @ MLINE,48 SAY PRICE3 PICTURE '99.9999'
            CASE PRICE2 <> 0
               @ MLINE,48 SAY PRICE2 PICTURE '99.9999'
            OTHERWISE
               @ MLINE,48 SAY PRICE1 PICTURE '99.9999'
            ENDCASE
            @ MLINE,64 SAY LBS_SHIP PICTURE '999,999,999'
            MLINE = MLINE + 1
            SKIP
         ENDDO
      ENDDO
   OTHERWISE
      
      MLINE = 99
      MPAGE_NO = 0
      MFIRST_TM = .T.
      STORE SPACE(32) TO MNAME
      
      DO WHILE .NOT. EOF()
         DO CASE
         CASE MCHOICE = 'C'
            IF MSEL_BBUY <> SPACE(4)
               IF MSEL_BBUY <> BBUYCODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
         OTHERWISE
            IF MSEL_RSUP <> SPACE(4)
               IF MSEL_RSUP <> RSUPCODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
         ENDCASE
         
         IF MLINE > 56
            IF MFIRST_TM
               MFIRST_TM = .F.
            ELSE
               EJECT
            ENDIF
            MLINE = 2
            MPAGE_NO = MPAGE_NO + 1
            @ MLINE,11 SAY 'PAGE  ' + str(mpage_no,3)
            IF MCHOICE = 'C'
               @ MLINE,30 say 'AMERICHICKEN CUSTOMER PRICING MASTER'
            ELSE
               @ MLINE,30 say 'AMERICHICKEN SUPPLIER PRICING MASTER'
            ENDIF
            @ MLINE,82 SAY DTOC(DATE())
            MLINE = MLINE + 1
            @ MLINE,30 SAY 'Products Shipped on/after ' + DTOC(MCUTOFF)
            MLINE = MLINE + 2
            @ MLINE,11 SAY 'Product               Cur Price          Lbs/Cases'
            MLINE = MLINE + 2
            @ MLINE,11 SAY NAME
            MNAME = NAME
            MLINE = MLINE + 1
         ENDIF
         
         IF NAME <> MNAME
            MLINE = MLINE + 1
            @ MLINE,11 SAY NAME
            MNAME = NAME
            MLINE = MLINE + 1
         ENDIF
         
         @ MLINE,11 SAY PROD_DESC
         *IF MCHOICE = 'C'
         DO CASE
         CASE PRICE3 <> 0
            @ MLINE,35 SAY PRICE3 PICTURE '99.9999'
         CASE PRICE2 <> 0
            @ MLINE,35 SAY PRICE2 PICTURE '99.9999'
         OTHERWISE
            @ MLINE,35 SAY PRICE1 PICTURE '99.9999'
         ENDCASE
         *ELSE
         *   @ MLINE,35 SAY PRICE1 PICTURE '99.9999'
         *ENDIF
         @ MLINE,50 SAY LBS_SHIP PICTURE '999,999,999'
         
         MLINE = MLINE + 1
         SKIP
      ENDDO
   ENDCASE
   @ MLINE,1 SAY ' '
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
*Formatted by: ToolBox Ver. 1.2  on 4/12/21 at 11:38 AM.
