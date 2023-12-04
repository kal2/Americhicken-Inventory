*  FILE NAME: SAL_PROC.PRG
*  BY: 
*  DATE: October 12, 1987
*  DESC:
*  CALLED BY:
*  DATA FILES:

*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
PROCEDURE TEXTSAL 
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 23,79
@ 5,3   SAY ' SALESPERSON NAME:'
@ 07,3  SAY '          ADDRESS:'  
@ 08,3  SAY '             CITY:'
@ 08,47 SAY 'STATE:'
@ 08,59 SAY 'ZIP:'
@ 08,69 SAY '-'
@ 10,3  SAY ' SALESPERSON CODE:'

@ 12,2  say 'COMMISSION PERCENT:            EFFECTIVE DATE:'
@ 13,2  SAY 'COMMISSION PERCENT:            EFFECTIVE DATE:'
@ 14,2  SAY 'COMMISSION PERCENT:            EFFECTIVE DATE:'  

@ 16,3  SAY '   SOCIAL SEC NBR:'
@ 17,3  SAY '   FEDERAL TAX ID:'
@ 18,3 SAY  'RESERVE DEDUCTION ACCOUNT CODE: '
@ 19,3 SAY  '     RESERVE ACCOUNT PAID CODE: '
@ 21,3 SAY  '      INCLUDE ON REPORTS (Y/N): '
RETURN


PROCEDURE INITSAL 
IF MINIT_NM
   MNAME       = SPACE(32)
ENDIF
MSTREET     = SPACE(28)
MCITY       = SPACE(20)
MSTATE      = SPACE(2)
MZIP        = SPACE(5)
MZIP4       = SPACE(4)
MSALE_CODE  = SPACE(2)
MSALE_PERC  = 0
MSALE_PER2  = 0
MSALE_PER3  = 0 
MEFF_DT1    = CTOD(' ')
MEFF_DT2    = CTOD(' ')
MEFF_DT3    = CTOD(' ')
MSALE_SSN   = SPACE(9)
MFED_TAXID  = SPACE(9)
STORE SPACE(4) TO MRES_DED, MRES_PAID
STORE 'Y' TO MRPT_PRT
RETURN

PROCEDURE SAYSAL
@ 05,22 SAY mname      
@ 07,22 SAY mstreet    
@ 08,22 SAY mcity      
@ 08,54 SAY MSTATE
@ 08,64 SAY mzip       
@ 08,70 SAY mzip4      
@ 10,22 SAY MSALE_CODE PICTURE '##'

@ 12,22 SAY MSALE_PERC PICTURE '###' 
@ 12,49 SAY MEFF_DT1
@ 13,22 SAY MSALE_PER2 PICTURE '###'
@ 13,49 SAY MEFF_DT2
@ 14,22 SAY MSALE_PER3 PICTURE '###'
@ 14,49 SAY MEFF_DT3
 
@ 16,22 SAY MSALE_SSN PICTURE '@R ###-##-####'
@ 17,22 SAY MFED_TAXID PICTURE '@R ##-#######'
@ 18,36 SAY MRES_DED
@ 19,36 SAY MRES_PAID
@ 21,36 SAY MRPT_PRT     
RETURN

PROCEDURE GETSAL
@ 05,22 GET mname PICTURE '@!'
@ 07,22 GET mstreet PICTURE '@!'
@ 08,22 GET mcity  PICTURE '@!'
@ 08,54 GET MSTATE PICTURE '@!'
@ 08,64 GET MZIP PICTURE '#####'
@ 08,70 GET mzip4 PICTURE '####'
@ 10,22 GET MSALE_CODE PICTURE '##'

@ 12,22 GET MSALE_PERC PICTURE '###' RANGE 0,100
@ 12,49 GET MEFF_DT1
@ 13,22 GET MSALE_PER2 PICTURE '###' RANGE 0,100
@ 13,49 GET MEFF_DT2
@ 14,22 GET MSALE_PER3 PICTURE '###' RANGE 0,100
@ 14,49 GET MEFF_DT3
 
@ 16,22 GET MSALE_SSN PICTURE '@R ###-##-####'
@ 17,22 GET MFED_TAXID PICTURE '@R ##-#######'
@ 18,36 GET MRES_DED PICTURE '####'
@ 19,36 GET MRES_PAID PICTURE '####'
@ 21,36 GET MRPT_PRT PICTURE '@!'
RETURN

PROCEDURE STORSAL
STORE name       TO mname      
STORE street     TO mstreet    
STORE city       TO mcity      
STORE STATE      TO MSTATE
STORE ZIP        TO MZIP
STORE zip4       TO mzip4      
STORE SALE_CODE  TO MSALE_CODE
STORE SALE_PERC  TO MSALE_PERC
MSALE_PER2 = SALE_PER2
MSALE_PER3 = SALE_PER3
MEFF_DT1   = EFF_DT1
MEFF_DT2   = EFF_DT2
MEFF_DT3   = EFF_DT3
STORE SALE_SSN   TO MSALE_SSN
STORE FED_TAXID  TO MFED_TAXID
STORE RES_DED    TO MRES_DED
STORE RES_PAID   TO MRES_PAID
STORE RPT_PRT    TO MRPT_PRT
IF MRPT_PRT <> 'Y'
   STORE 'N' TO MRPT_PRT 
ENDIF
RETURN

PROCEDURE REPLSAL
IF NAME <> MNAME .OR. SALE_CODE <> MSALE_CODE
   DO FILELOCK
   REPLACE name       WITH mname      
   REPLACE SALE_CODE  WITH MSALE_CODE
ELSE
   DO RECLOCK
ENDIF
REPLACE street     WITH mstreet    
REPLACE city       WITH mcity      
REPLACE STATE      WITH MSTATE
REPLACE zip        WITH mzip       
REPLACE zip4       WITH mzip4      
REPLACE SALE_PERC  WITH MSALE_PERC
REPLACE SALE_PER2  WITH MSALE_PER2
REPLACE SALE_PER3  WITH MSALE_PER3

REPLACE EFF_DT1    WITH MEFF_DT1
REPLACE EFF_DT2    WITH MEFF_DT2
REPLACE EFF_DT3    WITH MEFF_DT3

REPLACE SALE_SSN   WITH MSALE_SSN
REPLACE FED_TAXID  WITH MFED_TAXID
REPLACE RES_DED    WITH MRES_DED
REPLACE RES_PAID   WITH MRES_PAID
IF MRPT_PRT = 'Y'
   REPLACE RPT_PRT WITH MRPT_PRT
ELSE
   REPLACE RPT_PRT WITH ' '
ENDIF
UNLOCK
RETURN

PROCEDURE PUBLSAL
PUBLIC mname, mstreet, mcity, MSTATE, mzip, mzip4, MSALE_CODE, MSALE_PERC
PUBLIC MSALE_SSN, MRES_PAID, MRES_DED, MRPT_PRT, MSALE_PER2, MSALE_PER3
PUBLIC MEFF_DT1, MEFF_DT2, MEFF_DT3, MFED_TAXID
RETURN

PROCEDURE RELESAL
*RELEASE mname, mstreet, mcity, mzip, mzip4
*RELEASE MSALE_CODE, MSALE_PERC, MSALE_SSN
RELEASE MSALE_SSN, MRES_DED, MRES_PAID, MRPT_PRT
RELEASE MSALE_PER2, MSALE_PER3, MEFF_DT1, MEFF_DT2, MEFF_DT3, MFED_TAXID
RETURN

PROCEDURE SAL_SEL
******************
* Program.: SAL_SEL.PRG
* Author..: Grace Keller
* Date....: 10/12/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SALESPERSON SELECT
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT A
DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME, &MMASTDBF.SAL_CODE", .F.
STORE SPACE(32)    TO MNAME 
MNAME_FD = .F.
STORE 1 TO MACTION
MSAL_SEL = .T.
DO WHILE MSAL_SEL
   
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - SELECT SALESPERSON'
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
               DO SAL_ADD
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
               DO MULTSAL
               IF MACTION = 5
                  LOOP
               ENDIF
               IF MADD
                  MNAME = SPACE(32)
                  LOOP
               ENDIF
               DO SAL_EDIT
               MNAME = SPACE(32)
               LOOP
            ELSE
               GOTO MFST_REC
               DO SAL_EDIT
               STORE SPACE(32) TO MNAME
            ENDIF
            LOOP
         ENDIF
      ENDIF     
      
      MSAL_SEL = .F.
      LOOP
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 3
      MSAL_SEL = .F.
      
   ENDCASE
   
ENDDO

RETURN
* EOF: SAL_SEL.PRG

PROCEDURE SAL_ADD
*************
* Program.: SAL_ADD.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SALESPERSON ADD
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_SAL = .T.  
MTITLE = ' - ADD SALESPERSON INFORMATION' 
**** PUT UP THE SCREEN
DO TEXTSAL
DO WHILE MMORE_SAL
   DO INITSAL
   MNOT_DONE = .T.
   DO WHILE MNOT_DONE
      DO GETSAL
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
         MMORE_SAL = .F.
         LOOP
         
      CASE MACTION = 2
         LOOP
         
      CASE MACTION = 1 .OR. MACTION = 3
         IF MNAME = SPACE(32)    
            MNOT_DONE = .F.
            MMORE_SAL = .F.
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
               DO INITSAL
               LOOP
            ENDIF
         ENDIF
         DO FILELOCK
         APPEND BLANK
         UNLOCK
         DO REPLSAL
         MINIT_NM = .T.
         MADD = .T.
         IF MACTION = 3
            MMORE_SAL = .F.
         ENDIF
         MNOT_DONE = .F.
      ENDCASE
   ENDDO
ENDDO
RETURN
* EOF: SAL_ADD.PRG

PROCEDURE SAL_EDIT
*************
* Program.: SAL_EDIT.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SALESPERSON EDIT/DELETE
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_PP = .T.  
MTITLE = ' - VIEW/CHANGE/DELETE SALESPERSON INFORMATION' 
**** PUT UP THE SCREEN
DO TEXTSAL
DO STORSAL
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   DO GETSAL
   STORE 1 TO MACTION
   @ 23,0 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Save Updates   2.Edit Screen   3.Delete Salesperson   4.Cancel'
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
      DO REPLSAL
      MNOT_DONE = .F.
      
   CASE MACTION = 3
      @ 23,0 CLEAR
      STORE 'N' TO MYES_NO
      STORE 'Are You Sure You Want to DELETE this Salesperson (Y/N)? ' TO MWAIT
      @ 24,10 SAY MWAIT
      CLEAR GETS    
      @ 24,64 GET MYES_NO PICTURE '@!'
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
* EOF: SAL_EDIT.PRG
*Formatted by: dANALYST Ver. 7.3a on March 29, 1988 at 2:55 PM.
