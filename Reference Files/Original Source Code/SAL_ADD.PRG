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
*Formatted by: FoxToolBox Ver. 0.8c on October 28, 1987 at 2:08 PM.
