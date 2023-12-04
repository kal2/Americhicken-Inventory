**************
* Program.: MID_PAY.PRG
* Author..: GRACE KELLER
* Date....: 01/22/88
* Notice..: Copyright 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MIDWEST PAYMENT MENU   
*


* ---PROCESSING LOOP
STORE 0 TO MACTION
STORE 50 TO MSELECT

DO WHILE MSELECT <> 99
   
   CLEAR
   @ 1,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 02,00 SAY MPROGRAM + ' - MANUAL CASH DISBURSMENTS MENU'
   @ 03,00 TO 25,79 
   
   @ 04,09 SAY "1 - RECORD SUPPLIER MANUAL DISBURSEMENTS (WILL NOT PRINT CHECK)"
   @ 05,09 SAY '2 - RECORD FREIGHT MANUAL DISBURSEMENTS (WILL NOT PRINT CHECK)' 
   @ 06,09 SAY '3 - RECORD MISCELLANEOUS DISBURSEMENTS (WILL NOT PRINT CHECK)'
   
   @ 08,09 SAY '4 - ENTER MISCELLANEOUS DISBURSEMENTS'
   @ 09,09 SAY '5 - PRINT MISCELLANEOUS CHECKS'
   
   @ 11,09 SAY '6 - ENTER PAYROLL DISBURSEMENTS'
   @ 12,09 SAY '7 - PRINT PAYROLL CHECK'
   
   @ 14,09 say '8 - ENTER A/R REIMBURSEMENTS (Will Print Check with Misc. Checks)'
   @ 15,09 SAY '9 - RECORD A/R REIMB. WIRES TO CUSTOMERS (WILL NOT PRINT CHECK)'
   
   @ 21,09 SAY '99- EXIT TO MAIN MENU'
   
   STORE  1 TO MSELECT
   @ 23,01 SAY 'CHOICE: '
   @ 23,09 get MSELECT picture '##'
   READ
   
   DO CASE
      
   CASE MSELECT = 1
      DO SUP_DISB
   CASE MSELECT = 2
      DO FRT_DISB
   CASE MSELECT = 3
      DO MAN_OTH 
   CASE MSELECT = 4
      DO OTH_DISB
   CASE MSELECT = 5
      DO MISC_CHK
   CASE MSELECT = 6
      DO PAY_DISB
   CASE MSELECT = 7
      DO PAY_CHK
   CASE MSELECT = 8
      MMORE = .T.
      DO WHILE MMORE
         STORE SPACE(32) TO MNAME 
         MNAME_FD = .F.
         DO BBUYSEL3
         IF .NOT. MNAME_FD
            MMORE = .F.
            LOOP
         ENDIF
         
         STORE NAME TO MNAME
         STORE BBUYCODE TO MBBUYCODE
         STORE STREET TO MSTREET
         STORE CITY TO MCITY
         STORE STATE TO MSTATE
         STORE ZIP TO MZIP
         USE        
         
         CLEAR
         @ 1,00 SAY MCOMPANY
         @ 01,68 SAY DATE()
         @ 02,00 SAY MPROGRAM + ' - ENTER A/R REIMBURSEMENTS'
         @ 03,00 TO 24,79 
         
         @ 4,3 SAY ' SEND TO:'
         @ 5,5 SAY 'STREET: '
         @ 6,5 SAY '  CITY: ' 
         @ 6,45 SAY 'STATE: ' 
         @ 6,58 SAY 'ZIP: '
         @ 9,1 SAY '         INVOICE NBR: '
         @ 11,1 SAY '              PO NBR: '
         @ 11,26 SAY '-' 
         @ 11,31 SAY '-'
         
         @ 15,1 SAY ' AMOUNT TO REIMBURSE:' 
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Save/Add Another    2. Edit   3. Save/Finished    4. Cancel'
         
         STORE 0 TO MAMOUNT1
         STORE SPACE(2) TO MSALESMAN 
         STORE SPACE(6) TO MCK_NBR
         STORE SPACE(4) TO MPO_NBR
         STORE SPACE(1) TO MPO_SUFFIX
         STORE SPACE(5) TO MINV_NBR
         
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 21,1 CLEAR TO 21,78
            @ 4,13 SAY MNAME PICTURE '@!'
            @ 5,13 SAY MSTREET PICTURE '@!'
            @ 6,13 SAY MCITY PICTURE '@!'
            @ 6,52 SAY MSTATE PICTURE '@!'
            @ 6,63 SAY MZIP PICTURE '#####'
            @ 09,24 GET MINV_NBR PICTURE '#####'
            @ 11,24 GET MSALESMAN PICTURE '##'
            @ 11,27 GET MPO_NBR PICTURE '####'
            @ 11,32 GET MPO_SUFFIX PICTURE '@!'
            @ 15,24 GET MAMOUNT1 PICTURE '###,###.##'
            
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Save/Add Another    2. Edit   3. Save/Finished    4. Cancel'
            READ
            
            @ 24,9 GET MACTION PICTURE '#' RANGE 1,4
            READ
            IF MAMOUNT1 <> 0 .AND. MACTION = 1
               SELECT B
               DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               DO CASE
               CASE EOF()
                  @ 24,0 CLEAR      
                  STORE '  ' TO MOK
                  SET CONFIRM ON
                  @ 24,1 SAY "WARNING: PO NOT ON FILE - ENTER 'OK' TO CONTINUE " GET MOK PICTURE '@!'
                  READ
                  SET CONFIRM OFF
                  USE
                  @ 24,0 CLEAR
                  STORE 1 TO MACTION
                  @ 24,01 SAY 'Action: ' + STR(MACTION,1)
                  @ 24,13 SAY '1. Save/Add Another    2. Edit   3. Save/Finished    4. Cancel'
                  @ 24,9 GET MACTION PICTURE '#' RANGE 1,4
                  READ
               OTHERWISE
                  @ 24,0 CLEAR
                  STORE '  ' TO MOK
                  STORE BBUYCODE TO MBBUYCODE
                  USE
                  SELECT D
                  DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
                  SEEK MBBUYCODE
                  IF EOF()
                     @ 24,0 CLEAR      
                     STORE '  ' TO MOK
                     SET CONFIRM ON
                     @ 24,1 SAY "WARNING: CUST NAME DOES NOT MATCH PO- ENTER 'OK' TO CONTINUE " GET MOK PICTURE '@!'
                     READ
                     SET CONFIRM OFF
                     USE
                     @ 24,0 CLEAR
                     STORE 1 TO MACTION
                     @ 24,01 SAY 'Action: ' + STR(MACTION,1)
                     @ 24,13 SAY '1. Save/Add Another    2. Edit   3. Save/Finished    4. Cancel'
                     @ 24,9 GET MACTION PICTURE '#' RANGE 1,4
                     READ
                  ENDIF
                  USE
               ENDCASE
            ENDIF
         ENDDO
         
         IF MACTION = 4
            MMORE = .F.
            LOOP
         ENDIF
         
         IF MAMOUNT1 = 0
            LOOP
         ENDIF
         
         SELECT A
         DO FOX_USE WITH "MAN_CK INDEX MAN_CK", .F.
         STORE '150 ' TO MACCOUNT1
         DO FILELOCK
         APPEND BLANK
         REPLACE NAME WITH MNAME
         REPLACE STREET WITH MSTREET
         REPLACE CITY WITH MCITY
         REPLACE STATE WITH MSTATE
         REPLACE ZIP WITH MZIP
         REPLACE DESCRIP WITH 'REIMBURSEMENT'
         REPLACE AMOUNT01 WITH MAMOUNT1
         REPLACE ACCOUNT01 WITH MACCOUNT1
         REPLACE ACCT_NBR WITH MBBUYCODE
         REPLACE SALESMAN WITH MSALESMAN
         REPLACE PO_NBR WITH MPO_NBR
         REPLACE PO_SUFFIX WITH MPO_SUFFIX
         REPLACE USER WITH MUSER
         MINV_NBR = STR(VAL(MINV_NBR),5)    
         REPLACE INV01 WITH MINV_NBR
         UNLOCK
      ENDDO
      SET PROCEDURE TO PO_PROC
      CLOSE DATA
      RETURN
   CASE MSELECT = 9
      STORE CTOD(' ') TO MCK_DATE
      SELECT B
      DO FOX_USE WITH "DISBJRN INDEX DISBJRN, DISB_PO, DISBINV, DISBSTR, DISBINQ", .F.
      SELECT C
      DO FOX_USE WITH "CK_REG INDEX CK_REG, CK_DATE", .F.
      
      MMORE = .T.
      DO WHILE MMORE
         STORE SPACE(32) TO MNAME 
         MNAME_FD = .F.
         DO BBUYSEL3
         IF .NOT. MNAME_FD
            MMORE = .F.
            LOOP
         ENDIF
         
         STORE NAME TO MNAME
         STORE BBUYCODE TO MBBUYCODE
         STORE STREET TO MSTREET
         STORE CITY TO MCITY
         STORE STATE TO MSTATE
         STORE ZIP TO MZIP
         
         CLEAR
         @ 1,00 SAY MCOMPANY
         @ 01,68 SAY DATE()
         @ 02,00 SAY MPROGRAM + ' - RECORD WIRE A/R REIMBURSEMENTS TO CUSTOMERS'
         @ 03,00 TO 24,79 
         
         @ 4,3 SAY ' BILL TO:'
         @ 5,5 SAY 'STREET: '
         @ 6,5 SAY '  CITY: ' 
         @ 6,45 SAY 'STATE: ' 
         @ 6,58 SAY 'ZIP: '
         @ 8,1  SAY '           WIRE DATE: '
         @ 10,1 SAY '         WIRE AMOUNT:' 
         @ 12,1 SAY ' MIDWEST INVOICE NBR: '
         @ 14,1 SAY '      MIDWEST PO NBR: '
         @ 14,26 SAY '-'
         @ 14,31 SAY '-'
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Save/Add Another    2. Edit   3. Save/Finished    4. Cancel'
         
         STORE 0 TO MAMOUNT1, MAMOUNT2
         STORE SPACE(2) TO MSALESMAN 
         STORE SPACE(6) TO MCK_NBR
         STORE SPACE(4) TO MPO_NBR
         STORE SPACE(1) TO MPO_SUFFIX
         STORE SPACE(5) TO MINV_NBR
         
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 21,1 CLEAR TO 21,78
            @ 4,13 SAY MNAME PICTURE '@!'
            @ 5,13 SAY MSTREET PICTURE '@!'
            @ 6,13 SAY MCITY PICTURE '@!'
            @ 6,52 SAY MSTATE PICTURE '@!'
            @ 6,63 SAY MZIP PICTURE '#####'
            @ 8,24 GET MCK_DATE
            @ 10,24 GET MAMOUNT1 PICTURE '##,###.##'
            @ 12,24 GET MINV_NBR PICTURE '#####'
            @ 14,24 GET MSALESMAN PICTURE '##'
            @ 14,27 GET MPO_NBR PICTURE '####'
            @ 14,32 GET MPO_SUFFIX PICTURE '@!'
            
            
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Save/Add Another    2. Edit   3. Save/Finished    4. Cancel'
            READ
            
            @ 24,9 GET MACTION PICTURE '#' RANGE 1,4
            READ
         ENDDO
         IF MACTION = 4
            MMORE = .F.
         ENDIF
         
         IF MAMOUNT1 = 0
            LOOP
         ENDIF
         STORE DTOC(MCK_DATE) TO MDATE
         STORE SUBSTR(MDATE,1,2) TO MMONTH
         STORE SUBSTR(MDATE,4,2) TO MDAY
         STORE SUBSTR(MDATE,7) TO MYEAR
         *** GET THE NEXT WIRE NUMBER TO USE 
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
         DO RECLOCK
         MCK_NBR = WIRE_NBR
         REPLACE WIRE_NBR WITH WIRE_NBR + 1
         UNLOCK
         
         STORE SUBSTR(STR(MCK_NBR + 100000,6),2) TO MWIRE_NBR
         MCK_NBR = 'W' + MWIRE_NBR       
         
         SELECT B
         DO FILELOCK
         APPEND BLANK
         REPLACE JRNL_MO WITH MMONTH
         REPLACE JRNL_YR WITH MYEAR
         REPLACE JRNL_DAY WITH MDAY
         REPLACE CK_NBR WITH MCK_NBR
         REPLACE SALESMAN WITH MSALESMAN
         MINV_NBR = STR(VAL(MINV_NBR),5)
         REPLACE INV_NBR WITH MINV_NBR
         REPLACE PO_NBR WITH MPO_NBR
         REPLACE PO_SUFFIX WITH MPO_SUFFIX
         REPLACE AMOUNT1 WITH MAMOUNT1
         REPLACE SYS_DATE WITH MCK_DATE
         ** A/R REIM CATEGORY CODE
         REPLACE CATEGORY1 WITH '150 '
         REPLACE ACCT_NBR WITH MBBUYCODE
         REPLACE ACCT_TYPE WITH 'O'
         REPLACE ACCT_NAME WITH MNAME
         UNLOCK
         SELECT C
         DO FILELOCK
         APPEND BLANK
         REPLACE PAY_NAME WITH MNAME        
         REPLACE CK_NBR WITH MCK_NBR
         REPLACE CK_DATE WITH MCK_DATE
         REPLACE SYS_DATE WITH MCK_DATE
         REPLACE AMOUNT WITH MAMOUNT1
         REPLACE PAY_TYPE WITH 'O' 
         REPLACE DESCRIP WITH 'A/R REIMBURSEMENT'
         REPLACE CLEAR_FLG WITH 'Y'
         UNLOCK
         SELECT E
         DO FOX_USE WITH "CUS_INV INDEX CUS_INV, CUS_DATE, CUSIVNBR, CUS_SHIP", .F.
         DO FILELOCK
         APPEND BLANK
         REPLACE SALESMAN   WITH MSALESMAN  
         REPLACE PO_NBR     WITH MPO_NBR    
         REPLACE PO_SUFFIX  WITH MPO_SUFFIX 
         REPLACE BBUYCODE   WITH MBBUYCODE    
         REPLACE SHIP_DATE  WITH MCK_DATE 
         REPLACE TOT_SELL   WITH MAMOUNT1   
         REPLACE INV_NBR    WITH MINV_NBR      
         REPLACE INV_DATE   WITH MCK_DATE
         REPLACE DEB_CRD    WITH 'Y'
         REPLACE CRED_PAY   WITH 'Y'
         UNLOCK
         USE
      ENDDO
   CASE MSELECT = 10
      ***DO NEW_DISB
   CASE MSELECT = 11
      
   ENDCASE
   CLOSE DATA
   
ENDDO
RETURN

* EOF: MAN_DISB.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/17/98 at 6:01 AM.
