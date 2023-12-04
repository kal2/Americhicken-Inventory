*************
* Program.: BUY_ADD.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: CUSTOMER ADD
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_BUY = .T.  
STORE SPACE(10) TO MCONT_FAX
MTITLE = ' - ADD SHIP TO CUSTOMER INFORMATION'
**** PUT UP THE SCREEN
DO TEXTBUY 
DO WHILE MMORE_BUY
   DO INITBUY  
   MNOT_DONE = .T.
   DO WHILE MNOT_DONE
      DO GETBUY 
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
         MMORE_BUY = .F.
         LOOP
         
      CASE MACTION = 2
         LOOP
         
      CASE MACTION = 1
         IF MNAME = SPACE(32)    
            MNOT_DONE = .F.
            MMORE_BUY = .F.
            LOOP
         ENDIF
         IF MBIL_NAME = SPACE(32)
            @ 24,0 CLEAR
            STORE 'PRINCIPAL BILL TO NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MWAIT
            @ 24,5 GET MWAIT
            READ
            LOOP
         ENDIF

         SEEK MNAME
         IF .NOT. EOF()
            @ 24,0 CLEAR
            STORE 'N' TO MYES_NO 
            @ 24,1 SAY 'SHIP TO NAME ALREADY ON FILE - DO YOU WANT TO CONTINUE WITH ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'Y'
               MINIT_NM = .T.
               DO INITBUY 
               LOOP
            ENDIF
         ENDIF
         STORE MNAME TO MBUY_NAME
         STORE MSTREET TO MBUY_STRT
         STORE MCITY TO MBUY_CITY
         STORE MSTATE TO MBUY_STATE
         STORE MZIP TO MBUY_ZIP
         STORE MZIP4 TO MBUY_ZIP4
         STORE MNOTE TO MBUY_NOTE
         STORE MAREA_CODE TO MBUY_AREA
         STORE MPHONE TO MBUY_PHONE

         IF MBIL_NAME <> 'SAME'
            STORE MBIL_NAME TO MNAME
         ENDIF
         
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME, &MDBFLOC.BBUYCODE" ,.F.
         MNAME_FD = .F.
         
         DO BBUYSEL2
         
         **STORE MBUY_NAME TO MNAME
         **STORE MBUY_STRT TO MSTREET
         **STORE MBUY_CITY TO MCITY
         **STORE MBUY_STATE TO MSTATE
         **STORE MBUY_ZIP TO MZIP
         **STORE MBUY_ZIP4 TO MZIP4
         **STORE MBUY_NOTE TO MNOTE
         **STORE MBUY_AREA TO MAREA_CODE
         **STORE MBUY_PHONE TO MPHONE 
         
         IF .NOT. MNAME_FD
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY 'BILL TO MUST BE ON FILE - PLEASE HIT ANY KEY TO REENTER'
            @ 24,78  GET MWAIT
            READ
            @ 24,0 CLEAR
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_NAME, &MDBFLOC.BUY_CODE", .F.
            LOOP
         ENDIF
         STORE BBUYCODE TO MBBUYCODE
         @ 19,26 SAY A->NAME
         @ 20,26 SAY A->STREET
         IF A->ZIP4 = SPACE(4)
            STORE A->ZIP TO MZIPB
         ELSE
            STORE A->ZIP + '-' + A->ZIP4 TO MZIPB
         ENDIF
         @ 21,26 SAY TRIM(A->CITY) + ', ' + A->STATE + '  ' + MZIPB
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_NAME, &MDBFLOC.BUY_CODE", .F.
         
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
            MMORE_BUY = .F.
            LOOP
            
         CASE MACTION = 1
            IF MMASTDBF <> MDBFLOC
               SELECT C
               DO FOX_USE WITH "&MDBFLOC.CONTROL", .F.
            ELSE
               SELECT C
               DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
            ENDIF
            DO RECLOCK
            STORE STR(BUY_CODE+1,4) TO MBUY_CODE
            REPLACE BUY_CODE WITH BUY_CODE + 1
            UNLOCK
            USE
            SELECT A
            DO FILELOCK
            APPEND BLANK
            UNLOCK
            DO REPLBUY 
            MINIT_NM = .T.
            MADD = .T.
            MMORE_BUY = .F.
            MNOT_DONE = .F.
         ENDCASE
      ENDCASE
   ENDDO
ENDDO
RETURN
* EOF: BUY_ADD.PRG
*Formatted by: dANALYST Ver. 7.3a on November 24, 1987 at 3:03 PM.
