**********
* Program.: ACCOUNTS.PRG
* Author..: Grace Keller
* Date....: 04/04/88
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: ADD/UPDATE CHART OF ACCOUNTS     
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT D
DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
MTITLE = ' - ADD/UPDATE/DELETE CHART OF ACCOUNTS'
MNOT_FIN = .T.
DO WHILE MNOT_FIN
   STORE 0 TO MACCOUNT 
   STORE 2 TO MSEL
   DO WHILE MSEL = 2
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      @ 7,2 SAY '    ACCOUNT NUMBER:'      
      @ 9,2 SAY 'OFFICE DESCRIPTION:'
      @ 11,2 SAY ' CHECK DESCRIPTION:'
      @ 7,22 GET MACCOUNT PICTURE '@!'
      STORE 1 TO MSEL   
      @ 24,01 SAY 'Action: ' + STR(MSEL,1)
      @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
      READ
      @24,09 GET MSEL PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MSEL = 3 .OR. MACCOUNT = 0
      MNOT_FIN = .F.
      LOOP
   ENDIF
   SEEK STR(MACCOUNT,4) 
   IF .NOT. EOF()
      STORE DESCRIP TO MDESCRIP
      STORE CK_DESC TO MCK_DESC
   ELSE
      STORE SPACE(25) TO MDESCRIP
      STORE SPACE(20) TO MCK_DESC
   ENDIF
   @ 9,2 SAY 'OFFICE DESCRIPTION:'
   @ 11,2 SAY ' CHECK DESCRIPTION:'
   STORE 2 TO MSEL
   DO WHILE MSEL = 2
      @ 9,22 GET MDESCRIP PICTURE '@!'
      @ 11,22 GET MCK_DESC PICTURE '@!'
      STORE 1 TO MSEL
      @ 24,01 SAY 'Action: ' + STR(MSEL,1)
      @ 24,13 SAY '1. Save Update    2. Edit    3. Delete Account Desc    4. Cancel'
      READ
      @24,09 GET MSEL PICTURE '9' RANGE 1,4
      READ               
   ENDDO
   
   DO CASE
      
   CASE MSEL=1
      IF MACCOUNT <> 0
         SEEK STR(MACCOUNT,4)  
         IF EOF()
            DO FILELOCK
            APPEND BLANK
            REPLACE ACCOUNT WITH STR(MACCOUNT,4)
            UNLOCK
         ENDIF
         DO RECLOCK
         REPLACE DESCRIP WITH MDESCRIP
         REPLACE CK_DESC WITH MCK_DESC
         UNLOCK
      ELSE
         MNOT_FIN = .F.
      ENDIF
   CASE MSEL = 3 
      SEEK STR(MACCOUNT,4)  
      IF .NOT. EOF()
         DO RECLOCK
         DELETE
         UNLOCK
         @ 23,0 CLEAR
         STORE 'ACCOUNT & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
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
* EOF: ACCOUNTS.PRG
*Formatted by: dANALYST Ver. 7.3a on April 4, 1988 at 8:28 AM.
