******************
* Program.: FRT_SEL.PRG
* Author..: Grace Keller
* Date....: 10/12/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: FREIGHT CARRIER SELECT
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT A
DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME, &MDBFLOC.FRT_CODE", .F.
SET PROC TO FRT_PROC
STORE SPACE(32)    TO MNAME 
MNAME_FD = .F.
STORE 1 TO MACTION
MFRT_SEL = .T.
DO WHILE MFRT_SEL
   
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - SELECT FREIGHT CARRIER'
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
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,05 SAY 'FREIGHT CARRIER NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
            READ
            @ 24,0 CLEAR
            LOOP
         ELSE               
            STORE RECNO() TO MFST_REC
            SKIP
            IF NAME = SRCH_ARG
               MADD = .F.
               DO MUL1FRT
               IF MACTION = 5
                  LOOP
               ENDIF
            ELSE
               GOTO MFST_REC
            ENDIF
            MNAME_FD = .T.
         ENDIF
      ENDIF
      MFRT_SEL = .F.
      
   CASE MACTION = 3
      MFRT_SEL = .F.
      
   ENDCASE
   
ENDDO

RETURN
* EOF: FRT_SEL.PRG

*Formatted by: dANALYST Ver. 7.3a on February 12, 1988 at 2:11 PM.
