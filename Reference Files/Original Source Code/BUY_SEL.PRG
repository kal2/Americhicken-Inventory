******************
* Program.: BUY_SEL.PRG
* Author..: Grace Keller
* Date....: 10/12/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: BUYER SELECT
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT A
DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_NAME, &MDBFLOC.BUY_CODE", .F.
SET PROC TO BUY_PROC
STORE SPACE(32)    TO MNAME 
MNAME_FD = .F.
STORE 1 TO MACTION
MBUY_SEL = .T.
DO WHILE MBUY_SEL
   
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - SELECT CUSTOMER'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   @  5, 5 SAY 'Enter Customer Search Field:'
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
            @ 24,0 CLEAR
            STORE 'Y' TO MYES_NO
            @ 24,05 SAY 'NAME NOT FOUND - DO YOU WANT TO ADD (Y/N)? ' get MYES_NO PICTURE '@!'
            READ
            IF MYES_NO = 'Y'
               MINIT_NM = .F.
               DO BUY_ADD
               STORE SPACE(32) TO MNAME
            ELSE 
               STORE SPACE(32) TO MNAME
            ENDIF
            LOOP
         ELSE               
            STORE RECNO() TO MFST_REC
            *            SKIP
            *            IF NAME = SRCH_ARG
            MADD = .F.
            DO MUL1BUY
            IF MACTION = 5
               LOOP
            ENDIF
            IF MADD
               MNAME = SPACE(32)
               LOOP
            ENDIF
            DO BUY_EDIT
            MNAME = SPACE(32)
            LOOP
            *           ELSE
            *              GOTO MFST_REC
            *              DO BUY_EDIT
            *              STORE SPACE(32) TO MNAME
            *           ENDIF
            *           LOOP
         ENDIF
      ENDIF     
      
      MBUY_SEL = .F.
      LOOP
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 3
      MBUY_SEL = .F.
      
   ENDCASE
   
ENDDO

RETURN
* EOF: BUY_SEL.PRG

*Formatted by: FoxToolBox Ver. 0.8c on October 28, 1987 at 2:03 PM.
