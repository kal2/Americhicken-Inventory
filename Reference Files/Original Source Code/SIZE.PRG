**********
* Program.: SIZE.PRG
* Author..: Grace Keller
* Date....: 10/13/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SIZE DESCRIPTION UPDATE  
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT D
DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.

MTITLE = ' - UPDATE/DELETE SIZE CATEGORY'
STORE SPACE(5) TO MCODE     
MNOT_FIN = .T.
DO WHILE MNOT_FIN
   STORE 2 TO MSEL
   DO WHILE MSEL = 2
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      @ 7,5 SAY ' SIZE CODE'      
      @ 9,07 GET MCODE PICTURE '@!'
      STORE 1 TO MSEL   
      @ 24,01 SAY 'Action: ' + STR(MSEL,1)
      @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
      READ
      @24,09 GET MSEL PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MSEL = 3 .OR. MCODE = SPACE(5)
      MNOT_FIN = .F.
      LOOP
   ENDIF
   SEEK 'Z' + MCODE      
   IF .NOT. EOF()
      STORE SUBSTR(DESC,1,13) TO MDESC
   ELSE
      STORE SPACE(13) TO MDESC
   ENDIF
   @ 7,27 SAY 'DESCRIPTION TO BE PRINTED'
   STORE 2 TO MSEL
   DO WHILE MSEL = 2
      @ 9,32 GET MDESC PICTURE '@!'
      STORE 1 TO MSEL
      @ 24,01 SAY 'Action: ' + STR(MSEL,1)
      @ 24,13 SAY '1. Save Update    2. Edit    3. Delete Code & Desc    4. Cancel'
      READ
      @24,09 GET MSEL PICTURE '9' RANGE 1,4
      READ               
   ENDDO
   
   DO CASE
      
   CASE MSEL=1
      IF MCODE <> SPACE(5)
         SEEK 'Z' + MCODE      
         IF EOF()
            DO FILELOCK
            APPEND BLANK
            REPLACE TYPE WITH 'Z'
            REPLACE CODE WITH MCODE
            UNLOCK
         ENDIF
         DO RECLOCK
         REPLACE DESC WITH MDESC
         UNLOCK
         MCODE = SPACE(5)
      ELSE
         MNOT_FIN = .F.
      ENDIF
   CASE MSEL = 3 
      SEEK 'Z' + MCODE     
      IF .NOT. EOF()
         DO RECLOCK
         DELETE
         UNLOCK
         @ 23,0 CLEAR
         STORE 'CODE & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
         @ 24,5 GET MWAIT
         READ        
      ENDIF
      MNOT_FIN = .F.
   CASE MSEL = 4
      MNOT_FIN = .F.
      
   ENDCASE
   
ENDDO

CLOSE DATA 

RETURN
* EOF: SIZE.PRG
*Formatted by: FoxToolBox Ver. 0.8c on October 28, 1987 at 3:10 PM.
