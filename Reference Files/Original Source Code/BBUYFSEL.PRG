******************
* Program.: BBUY_SEL.PRG
* Author..: Grace Keller
* Date....: 10/12/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: BUYER SELECT
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
CLEAR GETS
CLEAR READ
CLEAR
SELECT A
DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME, &MDBFLOC.BBUYCODE", .F.
SET PROC TO BUY_PROC
STORE SPACE(32)    TO MNAME 
MNAME_FD = .F.
STORE 1 TO MACTION
MBUY_SEL = .T.
DO WHILE MBUY_SEL
   
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - SELECT BILL TO CUSTOMER'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   @  5, 5 SAY 'Enter Search Field:'
   @  8, 5 SAY 'Name'
   @ 10, 5 GET Mname PICTURE '@!'
   
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: '
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
            STORE ' ' TO MYES_NO
            @ 24,05 SAY 'NAME NOT FOUND - PRESS RETURN ' get MYES_NO
            READ
            STORE SPACE(32) TO MNAME
            LOOP
         ELSE               
            STORE RECNO() TO MFST_REC
            STORE TRIM(MNAME) TO SRCH_ARG
            SKIP
            IF NAME = SRCH_ARG
               MADD = .F.
               DO MUL1BBUY 
               IF MACTION = 5
                  LOOP
               ENDIF
               IF MADD
                  MNAME = SPACE(32)
                  LOOP
               ENDIF
               **DO BBUYEDIT
               DO BBUYVIEW
               MNAME = SPACE(32)
               LOOP
            ELSE
               GOTO MFST_REC
               DO BBUYVIEW
               MNAME = SPACE(32)
               LOOP
            ENDIF
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
* EOF: BBUY_SEL.PRG

*Formatted by: ToolBox Ver. 1.2  on 10/18/18 at 11:26 AM.
