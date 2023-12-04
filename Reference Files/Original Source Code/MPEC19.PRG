****************
* Program.: STATLIST.PRG
* Author..: GRACE KELLER
* Date....: 10/26/87
* Notice..: Copyright (C) 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: STATE SHIPPING MASTER LISTING
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MTITLE = ' - STATE SHIPPED TO MASTER LISTING'
CLEAR
@ 01,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@  2,0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
MCUTOFF = CTOD('')
mchoice = 'C'
mopt_prod = space(10)
@ 05,5 SAY 'Only Select those with Order Activity on/after this Date: ' GET MCUTOFF 
READ
IF MCHOICE = ' '
   RETURN
ENDIF
MORDER = 'S'
MSEL_BUY = SPACE(4)
MYES_NO = '   '
MACTION = 2
DO WHILE MACTION = 2
   @ 10,5 say 'Optional Product: ' get mopt_proD picture '@!'
   @ 12,5 SAY 'Do you want to select a specific customer (YES/NO) ' GET MYES_NO PICTURE '@!'
   **@ 14,5 SAY 'Print in State Order (S) -or- Product Order (P) ' get MORDER PICTURE '@!' VALID(MORDER = 'S' .OR. MORDER = 'P')
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
   DO BUY_SEL1
   IF .NOT. MNAME_FD
      CLOSE DATA
      RESTORE SCREEN FROM MGRACE
      MWAIT = ' '
      @ 14,5 SAY 'CUSTOMER NOT FOUND - PRESS RETURN TO CONTINUE' GET MWAIT
      READ
      RETURN
   ENDIF
   MSEL_BUY = BUY_CODE
   CLOSE DATA
   RESTORE SCREEN FROM MGRACE
ENDIF

*** INITIALIZE FILES
SELECT A
DO FOX_USE WITH "&MDBFLOC.ST_MAST", .T.
DELETE ALL
PACK
USE

STORE ' ' TO MPRT_ACT
DO PRT_SET
IF MPRT_ACT <> 'C'
   RETURN
ENDIF 

SELECT D
DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.

SELECT B
DO FOX_USE WITH "PO_HEAD", .F.
SET FILTER TO SHIP_DATE >= MCUTOFF
GOTO TOP

SELECT C
DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.

SELECT A
DO FOX_USE WITH "&MDBFLOC.ST_MAST", .T.
INDEX ON STATE + BUY_CODE + PROD_DESC TO  &MDBFLOC.TMP_PRI
DO FOX_USE WITH "&MDBFLOC.ST_MAST INDEX &MDBFLOC.TMP_PRI", .T.

SELECT A
INDEX ON BUY_CODE + PROD_DESC TO  &MDBFLOC.TMP_PRI
DO FOX_USE WITH "&MDBFLOC.ST_MAST INDEX &MDBFLOC.TMP_PRI", .T.

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
      SEEK B->BUY_CODE + D->PROD_DESC
      IF EOF()
         APPEND BLANK
         REPLACE BUY_CODE WITH B->BUY_CODE
         REPLACE PROD_DESC WITH D->PROD_DESC
      ENDIF
      IF LAST_SHIP = CTOD('')
         REPLACE LAST_SHIP WITH B->SHIP_DATE
      ELSE
         IF B->SHIP_DATE > LAST_SHIP
            REPLACE LAST_SHIP WITH B->SHIP_DATE
         ENDIF
      ENDIF
      
      IF PRICE1 = 0
         REPLACE PRICE1 WITH D->SEL_PRICE
      ELSE
         IF D->SEL_PRICE <> PRICE1
            REPLACE PRICE2 WITH D->SEL_PRICE
         ENDIF
      ENDIF
      
      REPLACE LBS_SHIP WITH D->LBS
      
      SELECT D
      SKIP
   ENDDO
   SELECT B
   SKIP
ENDDO

SELECT A
GOTO TOP

*** GET THE CUSTOMER NAMES & STATES SET UP
DO WHILE .NOT. EOF()
   SELECT C
   SEEK A->BUY_CODE
   SELECT A
   IF C->BBUYCODE = 'INVN'
      DELETE
   ELSE
      REPLACE NAME  WITH C->NAME
      REPLACE STATE WITH C->STATE
   ENDIF
   SKIP
ENDDO


SELECT A
DELETE FOR NAME = 'NONE' .OR. NAME = 'DONATION' .OR. NAME = 'SAMPLE'
DELETE FOR PRICE1 <= 0 .AND. PRICE2 <= 0
PACK
CLOSE DATA

SELECT A
DO FOX_USE WITH "&MDBFLOC.ST_MAST", .T.
IF MORDER = 'S'
   INDEX ON STATE + NAME + PROD_DESC TO  &MDBFLOC.PRI_TEMP
ELSE
   INDEX ON PROD_DESC + STATE + NAME TO &MDBFLOC.PRI_TEMP
ENDIF
DO FOX_USE WITH "&MDBFLOC.ST_MAST INDEX &MDBFLOC.PRI_TEMP", .F.

IF MOPT_PROD <> SPACE(10)
   IF MSEL_BUY = SPACE(4)
      SET FILTER TO PROD_DESC = MOPT_PROD .AND. LAST_SHIP >= MCUTOFF
   ELSE
      SET FILTER TO MSEL_BUY = BUY_CODE .AND. PROD_DESC = MOPT_PROD .AND. LAST_SHIP >= MCUTOFF
   ENDIF
ELSE
   IF MSEL_BUY = SPACE(4)
      SET FILTER TO LAST_SHIP >= MCUTOFF
   ELSE
      SET FILTER TO MSEL_BUY = BUY_CODE .AND. LAST_SHIP >= MCUTOFF
   ENDIF
ENDIF
GOTO TOP

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
      IF MSEL_BUY <> SPACE(4)
         IF MSEL_BUY <> BBUYCODE
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
         @ MLINE,30 say 'AMERICHICKEN CUSTOMER PRICING MASTER - Spec19'
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
         
         IF MLINE > 56
            IF MFIRST_TM
               MFIRST_TM = .F.
            ELSE
               EJECT
            ENDIF
            MLINE = 2
            MPAGE_NO = MPAGE_NO + 1
            @ MLINE,11 SAY 'PAGE  ' + str(mpage_no,3)
            @ MLINE,30 say 'AMERICHICKEN CUSTOMER PRICING MASTER - Spec19'
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
   
   DO WHILE .NOT. EOF()
      STORE STATE TO MSTATE
      IF MLINE > 56
         IF MFIRST_TM
            MFIRST_TM = .F.
         ELSE
            EJECT
         ENDIF
         MLINE = 2
         MPAGE_NO = MPAGE_NO + 1
         @ MLINE,5 SAY 'PAGE  ' + str(mpage_no,3)
         @ MLINE,30 say 'AMERICHICKEN STATE SHIP TO MASTER - Spec19'
         @ MLINE,82 SAY DTOC(DATE())
         MLINE = MLINE + 1
         @ MLINE,30 SAY 'Products Shipped on/after ' + DTOC(MCUTOFF)
         MLINE = MLINE + 2
         @ MLINE,5 SAY 'State/Ship To/Prod                     Price1      Price2             Lbs/Cases'
         MLINE = MLINE + 2
         @ MLINE,5 SAY '**' + MSTATE
         MLINE = MLINE + 1
      ELSE
         MLINE = MLINE + 2
         @ MLINE,5 SAY '**' + MSTATE
         MLINE = MLINE + 1
      ENDIF
      
      
      DO WHILE .NOT. EOF() .AND. STATE = MSTATE
         
         STORE NAME TO MNAME
         
         IF MLINE > 55
            IF MFIRST_TM
               MFIRST_TM = .F.
            ELSE
               EJECT
            ENDIF
            MLINE = 2
            MPAGE_NO = MPAGE_NO + 1
            @ MLINE,5 SAY 'PAGE  ' + str(mpage_no,3)
            @ MLINE,30 say 'AMERICHICKEN STATE SHIP TO MASTER - Spec19'
            @ MLINE,82 SAY DTOC(DATE())
            MLINE = MLINE + 1
            @ MLINE,30 SAY 'Products Shipped on/after ' + DTOC(MCUTOFF)
            MLINE = MLINE + 2
            @ MLINE,5 SAY 'State/Ship To/Prod                     Price1      Price2             Lbs/Cases'
            MLINE = MLINE + 2
            @ MLINE,5 SAY '**' + MSTATE
            MLINE = MLINE + 1
         ELSE
            MLINE = MLINE + 1
         ENDIF
         @ MLINE,7 SAY MNAME
         MLINE = MLINE + 1
         
         DO WHILE .NOT. EOF() .AND. STATE = MSTATE .AND. NAME = MNAME
            
            IF MLINE > 56
               IF MFIRST_TM
                  MFIRST_TM = .F.
               ELSE
                  EJECT
               ENDIF
               MLINE = 2
               MPAGE_NO = MPAGE_NO + 1
               @ MLINE,5 SAY 'PAGE  ' + str(mpage_no,3)
               @ MLINE,30 say 'AMERICHICKEN STATE SHIP TO MASTER - Spec19'
               @ MLINE,82 SAY DTOC(DATE())
               MLINE = MLINE + 1
               @ MLINE,30 SAY 'Products Shipped on/after ' + DTOC(MCUTOFF)
               MLINE = MLINE + 2
               @ MLINE,5 SAY 'State/Ship To/Prod                     Price1      Price2             Lbs/Cases'
               MLINE = MLINE + 2
               @ MLINE,5 SAY '**' + MSTATE
               MLINE = MLINE + 1
               @ MLINE,7 SAY MNAME
               MLINE = MLINE + 1
            ENDIF
            @ MLINE,7  SAY PROD_DESC
            @ MLINE,43 SAY PRICE1 PICTURE '99.9999'
            IF  PRICE2 <> 0
               @ MLINE,55 SAY PRICE2 PICTURE '99.9999'
            ENDIF
            @ MLINE,73 SAY LBS_SHIP PICTURE '999,999,999'
            
            MLINE = MLINE + 1
            SKIP
         ENDDO
      ENDDO
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

CLOSE DATA
RETURN
*Formatted by: ToolBox Ver. 1.2  on 7/11/17 at 11:09 AM.
