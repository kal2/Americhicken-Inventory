*************
* Program.: FRT_UPD.PRG
* Author..: Grace Keller
* Date....: 10/28/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: FREIGHT CARRIER EDIT/DELETE
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_PP = .T.  
MTITLE = ' - VIEW/CHANGE FREIGHT INSURANCE INFORMATION' 
**** PUT UP THE SCREEN
DO SAYFRT2
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   DO GETFRT3
   STORE 1 TO MACTION
   @ 24,0 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Save/Return    2.Edit Screen    3.Print Ins. Letter   4.Cancel'
   READ
   @24,09 GET MACTION PICTURE '9' RANGE 1,4
   READ               
   DO CASE
   CASE MACTION = 4
      MNOT_DONE = .F.
      LOOP
      
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 1 .OR. MACTION = 3
      DO REPLFRT
      IF MACTION = 3
         DO FRT_LET
      ENDIF
      MNOT_DONE = .F.
   ENDCASE
   
ENDDO
RETURN
* EOF: FRT_UPD2.PRG
*Formatted by: ToolBox Ver. 1.2  on 5/29/90 at 8:52 AM.
