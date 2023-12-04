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
*Formatted by: FoxToolBox Ver. 0.8c on October 28, 1987 at 2:08 PM.
