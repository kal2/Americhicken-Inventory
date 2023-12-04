*************
* Program.: RSUP_ADD.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SUPPLIER ADD
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_RSUP = .T.  
STORE SPACE(4) TO MZIP4
MTITLE = ' - ADD REMIT TO SUPPLIER INFORMATION' 
**** PUT UP THE SCREEN
DO TEXTRSUP
DO WHILE MMORE_RSUP
   DO INITRSUP
   MNOT_DONE = .T.
   DO WHILE MNOT_DONE
      DO GETRSUP
      STORE 1 TO MACTION
      @ 24,0 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Save      2. Edit      3. Cancel'
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      DO CASE
      CASE MACTION = 3
         MNOT_DONE = .F.
         MMORE_RSUP = .F.
         LOOP
         
      CASE MACTION = 2
         LOOP
         
      CASE MACTION = 1
         IF MNAME = SPACE(32)    
            MNOT_DONE = .F.
            MMORE_RSUP = .F.
            LOOP
         ENDIF
         SEEK MNAME
         IF .NOT. EOF()
            @ 24,0 CLEAR
            STORE 'N' TO MYES_NO 
            @ 24,1 SAY 'REMIT TO NAME ALREADY ON FILE -DO YOU WANT TO CONTINUE WITH ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'Y'
               MINIT_NM = .T.
               DO INITRSUP
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
         STORE STR(RSUPCODE+1,4) TO MRSUPCODE
         DO RECLOCK
         REPLACE RSUPCODE WITH RSUPCODE + 1
         UNLOCK
         USE
         SELECT A
         DO FILELOCK
         APPEND BLANK
         UNLOCK
         DO REPLRSUP
         MINIT_NM = .T.
         MADD = .T.
            MMORE_RSUP = .F.
         MNOT_DONE = .F.
      ENDCASE
   ENDDO
ENDDO
RETURN
* EOF: SUP_ADD.PRG
*Formatted by: FoxToolBox Ver. 0.8c on October 29, 1987 at 12:56 PM.
