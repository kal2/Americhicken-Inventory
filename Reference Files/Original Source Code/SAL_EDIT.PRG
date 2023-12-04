*************
* Program.: SAL_EDIT.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SALESPERSON EDIT/DELETE
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_PP = .T.  
MTITLE = ' - VIEW/CHANGE/DELETE SALESPERSON INFORMATION' 
**** PUT UP THE SCREEN
DO TEXTSAL
DO STORSAL
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   DO GETSAL
   STORE 1 TO MACTION
   @ 23,0 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Save Updates   2.Edit Screen   3.Delete Salesperson   4.Cancel'
   READ
   @24,09 GET MACTION PICTURE '9' RANGE 1,4
   READ               
   DO CASE
   CASE MACTION = 4
      MNOT_DONE = .F.
      LOOP
      
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 1
      DO REPLSAL
      MNOT_DONE = .F.
      
   CASE MACTION = 3
      @ 23,0 CLEAR
      STORE 'N' TO MYES_NO
      STORE 'Are You Sure You Want to DELETE this Salesperson (Y/N)? ' TO MWAIT
      @ 24,10 SAY MWAIT
      CLEAR GETS    
      @ 24,64 GET MYES_NO PICTURE '@!'
      READ
      IF MYES_NO = 'Y'
         DO RECLOCK
         DELETE
      UNLOCK
   ENDIF 
   MNOT_DONE = .F.
ENDCASE

ENDDO
RETURN
* EOF: SAL_EDIT.PRG
*Formatted by: FoxToolBox Ver. 0.8c on October 28, 1987 at 2:08 PM.
