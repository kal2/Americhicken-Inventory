*************
* Program.: SUP_ADD.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SUPPLIER ADD
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_SUP = .T.  
MTITLE = ' - ADD SUPPLIER INFORMATION' 
**** PUT UP THE SCREEN
DO TEXTSUPP
DO WHILE MMORE_SUP
   DO INITSUPP
   MNOT_DONE = .T.
   DO WHILE MNOT_DONE
      DO GETSUPP
      STORE 1 TO MACTION
      @ 24,0 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Save      2. Edit       3. Cancel'
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      DO CASE
      CASE MACTION = 3
         MNOT_DONE = .F.
         MMORE_SUP = .F.
         LOOP
         
      CASE MACTION = 2
         LOOP
         
      CASE MACTION = 1
         IF MNAME = SPACE(32)    
            MNOT_DONE = .F.
            MMORE_SUP = .F.
            LOOP
         ENDIF
         IF MREM_NAME = SPACE(32)
            @ 24,0 CLEAR
            STORE 'REMIT TO NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MWAIT
            @ 24,5 GET MWAIT
            READ
            LOOP
         ENDIF
         SEEK MNAME
         IF .NOT. EOF()
            @ 24,0 CLEAR
            STORE 'N' TO MYES_NO 
            @ 24,1 SAY 'SHIPPED FROM NAME ALREADY ON FILE- DO YOU WANT TO CONTINUE WITH ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'Y'
               MINIT_NM = .T.
               DO INITSUPP
               LOOP
            ENDIF
         ENDIF
         
         STORE MNAME TO MSUP_NAME
         STORE MSTREET TO MSUP_STRT
         STORE MCITY TO MSUP_CITY
         STORE MSTATE TO MSUP_STATE
         STORE MZIP TO MSUP_ZIP
         STORE MZIP4 TO MSUP_ZIP4
         STORE MNOTE TO MSUP_NOTE
         STORE MAREA_CODE TO MSUP_AREA
         STORE MPHONE TO MSUP_PHONE

         IF MREM_NAME <> 'SAME'
            STORE MREM_NAME TO MNAME
         ENDIF
         
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME, &MDBFLOC.RSUPCODE" ,.F.
         MNAME_FD = .F.
         
         DO RSUPSEL2
         
         STORE MSUP_NAME TO MNAME
         STORE MSUP_STRT TO MSTREET
         STORE MSUP_CITY TO MCITY
         STORE MSUP_STATE TO MSTATE
         STORE MSUP_ZIP TO MZIP
         STORE MSUP_ZIP4 TO MZIP4
         STORE MSUP_NOTE TO MNOTE
         STORE MSUP_AREA TO MAREA_CODE
         STORE MSUP_PHONE TO MPHONE 
         
         IF .NOT. MNAME_FD
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY 'REMIT TO MUST BE ON FILE - PLEASE HIT ANY KEY TO REENTER'
            @ 24,78  GET MWAIT
            READ
            @ 24,0 CLEAR
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_NAME, &MDBFLOC.SUP_CODE", .F.
            LOOP
         ENDIF
         STORE RSUPCODE TO MRSUPCODE
         @ 19,26 SAY NAME
         @ 20,26 SAY STREET
         IF ZIP4 = SPACE(4)
            STORE ZIP TO MZIP
         ELSE
            STORE ZIP + '-' + ZIP4 TO MZIP
         ENDIF
         @ 21,26 SAY TRIM(CITY) + ', ' + STATE + '  ' + MZIP

         SELECT A
         DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_NAME, &MDBFLOC.SUP_CODE", .F.
         
         STORE 1 TO MACTION
         @ 24,0 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Save      2. Edit       3. Cancel'
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         
         DO CASE
         CASE MACTION = 2
            LOOP
         CASE MACTION = 3
            MNOT_DONE = .F.
            MMORE_SUP = .F.
            LOOP
            
         CASE MACTION = 1
            IF MMASTDBF <> MDBFLOC
               SELECT C
               DO FOX_USE WITH "&MDBFLOC.CONTROL", .F.
            ELSE
               SELECT C
               DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
            ENDIF
            STORE STR(SUP_CODE+1,4) TO MSUP_CODE
            DO RECLOCK
            REPLACE SUP_CODE WITH SUP_CODE + 1
            UNLOCK
            USE
            SELECT A
            DO FILELOCK
            APPEND BLANK
            UNLOCK
            DO REPLSUPP
            MINIT_NM = .T.
            MADD = .T.
            MMORE_SUP = .F.
            MNOT_DONE = .F.
         ENDCASE
      ENDCASE
   ENDDO
ENDDO
RETURN
* EOF: SUP_ADD.PRG
*Formatted by: dANALYST Ver. 7.3a on November 24, 1987 at 3:03 PM.
