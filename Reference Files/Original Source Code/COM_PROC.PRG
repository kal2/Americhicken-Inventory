**************************
*  FILE NAME: COM_PROC.PRG
*  BY: 
*  DATE: October 12, 1987
*  DESC:
*  CALLED BY:
*  DATA FILES:

*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
PROCEDURE TEXTCOM 
CLEAR 
@ 1,0 SAY MCOMPANY
@ 1,68 SAY DATE()
@ 2,0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
@ 5,3   SAY '       Payee Name:'
@ 5,3  SAY '          Address:'  
@ 8,3  SAY '             City:'
@ 8,47 SAY 'State:'
@ 8,59 SAY 'Zip:'
@ 8,69 SAY '-'
@ 10,3  SAY '   Social Sec Nbr:'
@ 12,1  SAY '(OR) Federal Tax ID:'
@ 14,1 say 'Bill Back Third Party (Y/N): '
@ 16,1 say 'Sales Confirmation CC:'
@ 18,1 say 'Print on Customer Confirmation (Y/N): '
@ 20,1 SAY 'Print Brokerage Invoices (Y/N): '
RETURN

PROCEDURE INITCOM 
IF MINIT_NM
   mname       = SPACE(32)
ENDIF
mstreet     = SPACE(28)
mcity       = SPACE(20)
MSTATE      = SPACE(2)
mzip        = SPACE(5)
mzip4       = SPACE(4)
MCOM_CODE   = SPACE(2)
MCOM_SSN    = SPACE(9)
MFED_TAXID  = SPACE(9)
MCOM_CODE   = SPACE(2)
MCC_NAME    = SPACE(32)
MBILL_BACK  = 'N'
MPRT_CONF   = 'Y'
MINV_SEL    = 'Y'
RETURN

PROCEDURE SAYCOM
@ 5,22 SAY mname      
@ 7,22 SAY mstreet    
@ 8,22 SAY mcity      
@ 8,54 SAY MSTATE
@ 8,64 SAY mzip       
@ 8,70 SAY mzip4      
@ 10,22 SAY MCOM_SSN PICTURE '@R ###-##-####'
@ 12,22 SAY MFED_TAXID PICTURE '@R ##-#######'
@ 14,30 SAY MBILL_BACK 
@ 16,24 SAY MCC_NAME
@ 18,39 SAY MPRT_CONF
@ 20,33 SAY MINV_SEL
RETURN

PROCEDURE GETCOM
@ 5,22 GET mname PICTURE '@!'
@ 7,22 GET mstreet PICTURE '@!'
@ 8,22 GET mcity  PICTURE '@!'
@ 8,54 GET MSTATE PICTURE '@!'
@ 8,64 GET MZIP PICTURE '#####'
@ 8,70 GET mzip4 PICTURE '####'
@ 10,22 GET MCOM_SSN PICTURE '@R ###-##-####'
@ 12,22 GET MFED_TAXID PICTURE '@R ##-#######'
@ 14,30 GET MBILL_BACK PICTURE '@!' VALID(MBILL_BACK = 'N' .OR. MBILL_BACK = 'Y')
@ 16,24 GET MCC_NAME PICTURE '@!'
@ 18,39 GET MPRT_CONF PICTURE '@!' VALID(MPRT_CONF = 'Y' .OR. MPRT_CONF = 'N')
@ 20,33 GET MINV_SEL PICTURE '@!' VALID(MINV_SEL = 'Y' .OR. MINV_SEL = 'N')
RETURN

PROCEDURE STORCOM
STORE name       TO mname      
STORE street     TO mstreet    
STORE city       TO mcity      
STORE STATE      TO MSTATE
STORE ZIP        TO MZIP
STORE zip4       TO mzip4      
STORE COM_CODE   TO MCOM_CODE
STORE COM_SSN    TO MCOM_SSN
STORE FED_TAXID  TO MFED_TAXID
STORE BILL_BACK  TO MBILL_BACK
STORE CC_NAME    TO MCC_NAME
STORE PRT_CONF   TO MPRT_CONF
STORE INV_SEL    TO MINV_SEL
RETURN

PROCEDURE REPLCOM
IF NAME <> MNAME .OR. COM_CODE <> MCOM_CODE
   DO FILELOCK
   REPLACE name       WITH mname      
   REPLACE COM_CODE   WITH MCOM_CODE
ELSE
   DO RECLOCK
ENDIF
REPLACE street     WITH mstreet    
REPLACE city       WITH mcity      
REPLACE STATE      WITH MSTATE
REPLACE zip        WITH mzip       
REPLACE zip4       WITH mzip4      
REPLACE COM_SSN    WITH MCOM_SSN
REPLACE FED_TAXID  WITH MFED_TAXID
REPLACE BILL_BACK  WITH MBILL_BACK
REPLACE CC_NAME    WITH MCC_NAME
REPLACE PRT_CONF   WITH MPRT_CONF
REPLACE INV_SEL    WITH MINV_SEL
UNLOCK
RETURN

PROCEDURE PUBLCOM
PUBLIC mname, mstreet, mcity, MSTATE, mzip, mzip4, MCOM_CODE, MFED_TAXID, MCOM_SSN             
PUBLIC MBILL_BACK, MINV_SEL
RETURN

PROCEDURE RELECOM
*RELEASE mname, mstreet, mcity, mzip, mzip4
*RELEASE MCOM_CODE, MFED_TAXID, MCOM_SSN
RELEASE MFED_TAXID, MCOM_SSN, MBILL_BACK, MINV_SEL
RETURN

PROCEDURE COM_SEL
******************
* Program.: COM_SEL.PRG
* Author..: Grace Keller
* Date....: 10/12/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SALESPERSON SELECT
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT A
DO FOX_USE WITH "&mdbfloc.compayee INDEX &mdbfloc.com_name, &mdbfloc.com_code", .F.
STORE SPACE(32)    TO MNAME, MCC_NAME, MPRT_CONF
MNAME_FD = .F.
STORE 1 TO MACTION
MCOM_SEL = .T.
DO WHILE MCOM_SEL
   
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - SELECT 3RD PARTY PAYEE'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   @  5, 5 SAY 'Enter Search Field:'
   @  8, 5 SAY 'Name'
   @ 10, 5 GET Mname PICTURE '@!'
   
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      
      IF MNAME <> SPACE(32)
         STORE TRIM(MNAME) TO SRCH_ARG
         SEEK SRCH_ARG
         IF EOF() .OR. DELETED()
            @ 23,0 CLEAR
            STORE 'Y' TO MYES_NO
            @ 24,05 SAY 'NAME NOT FOUND - DO YOU WANT TO ADD (Y/N)? ' get MYES_NO PICTURE '@!'
            READ
            IF MYES_NO = 'Y'
               MINIT_NM = .F.
               DO COM_ADD
               STORE SPACE(32) TO MNAME
            ELSE 
               STORE SPACE(32) TO MNAME
            ENDIF
            LOOP
         ELSE               
            STORE RECNO() TO MFST_REC
            SKIP
            IF NAME = SRCH_ARG
               MADD = .F.
               DO MULTCOM
               IF MACTION = 5
                  LOOP
               ENDIF
               IF MADD
                  MNAME = SPACE(32)
                  LOOP
               ENDIF
               DO COM_EDIT
               MNAME = SPACE(32)
               LOOP
            ELSE
               GOTO MFST_REC
               DO COM_EDIT
               STORE SPACE(32) TO MNAME
            ENDIF
            LOOP
         ENDIF
      ENDIF     
      
      MCOM_SEL = .F.
      LOOP
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 3
      MCOM_SEL = .F.
      
   ENDCASE
   
ENDDO

RETURN
* EOF: COM_SEL.PRG

PROCEDURE COM_ADD
*************
* Program.: COM_ADD.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SALESPERSON ADD
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_COM = .T.  
MTITLE = ' - ADD 3RD PARTY COMMISSION PAYEE INFORMATION' 
**** PUT UP THE SCREEN
DO TEXTCOM
DO WHILE MMORE_COM
   DO INITCOM
   MNOT_DONE = .T.
   DO WHILE MNOT_DONE
      DO GETCOM
      STORE 1 TO MACTION
      @ 23,0 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Save & Add Another    2. Edit    3. Save & Return    4. Cancel'
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,4
      READ               
      DO CASE
      CASE MACTION = 4
         MNOT_DONE = .F.
         MMORE_COM = .F.
         LOOP
         
      CASE MACTION = 2
         LOOP
         
      CASE MACTION = 1 .OR. MACTION = 3
         IF MNAME = SPACE(32)    
            MNOT_DONE = .F.
            MMORE_COM = .F.
            LOOP
         ENDIF
         SEEK MNAME
         IF .NOT. EOF()
            @ 23,0 CLEAR
            STORE 'N' TO MYES_NO 
            @ 24,1 SAY 'NAME ALREADY ON FILE - DO YOU WANT TO CONTINUE WITH THIS ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'Y'
               MINIT_NM = .T.
               DO INITCOM
               LOOP
            ENDIF
         ENDIF
         IF MMASTDBF <> MDBFLOC
            SELECT C
            DO FOX_USE WITH "&MDBFLOC.CONTROL", .F.
         ELSE
            SELECT C
            DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
         ENDIF
         STORE STR(COM_CODE+1,2) TO MCOM_CODE
         DO RECLOCK
         REPLACE COM_CODE WITH COM_CODE + 1
         UNLOCK
         USE
         SELECT A
         DO FILELOCK
         APPEND BLANK
         UNLOCK
         DO REPLCOM
         MINIT_NM = .T.
         MADD = .T.
         IF MACTION = 3
            MMORE_COM = .F.
         ENDIF
         MNOT_DONE = .F.
      ENDCASE
   ENDDO
ENDDO
RETURN
* EOF: COM_ADD.PRG

PROCEDURE COM_EDIT.PRG
*************
* Program.: COM_EDIT.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: 3RD PARTY COMMISSION PAYEE EDIT/DELETE
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_PP = .T.  
MTITLE = ' - VIEW/CHANGE/DELETE 3RD PARTY PAYEE'
**** PUT UP THE SCREEN
DO TEXTCOM
DO STORCOM
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   DO GETCOM
   @ 7,70 SAY 'CODE: ' + A->COM_CODE
   STORE 1 TO MACTION
   @ 23,0 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Save Updates   2.Edit Screen   3.Delete Payee   4.Cancel'
   READ
   @24,09 GET MACTION PICTURE '9' RANGE 1,4
   READ               
   DO CASE
   CASE MACTION = 4
      MNOT_DONE = .F.
      LOOP
      
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 1
      DO REPLCOM
      MNOT_DONE = .F.
      
   CASE MACTION = 3
      @ 23,0 CLEAR
      STORE 'N' TO MYES_NO
      STORE 'Are You Sure You Want to DELETE this Payee (Y/N)? ' TO MWAIT
      @ 24,10 SAY MWAIT
      CLEAR GETS    
      @ 24,61 GET MYES_NO PICTURE '@!'
      READ
      IF MYES_NO = 'Y'
         DO RECLOCK
         DELETE
         UNLOCK
      ENDIF 
      MNOT_DONE = .F.
   ENDCASE
   
ENDDO
RETURN
* EOF: COM_EDIT.PRG
*Formatted by: dANALYST Ver. 7.3a on March 29, 1988 at 2:54 PM.
