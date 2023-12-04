*************
* Program.: RSUPEDIT.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SUPPLIER EDIT/DELETE
*
* ---OPEN FILES
MMORE_PP = .T.  
MTITLE = ' - VIEW/CHANGE/DELETE REMIT TO SUPPLIER INFORMATION' 
**** PUT UP THE SCREEN
DO TEXTRSUP
DO STORRSUP
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   DO GETRSUP
   STORE 1 TO MACTION
   @ 24,0 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Save Updates    2.Edit Screen    3.Delete Supplier   4.Cancel'
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
      DO REPLRSUP
      MNOT_DONE = .F.
      
   CASE MACTION = 3
      @ 24,0 CLEAR
      STORE 'N' TO MYES_NO
      STORE 'Are You Sure You Want to DELETE this Supplier (Y/N)? ' TO MWAIT
      @ 24,10 SAY MWAIT
      CLEAR GETS    
      @ 24,65 GET MYES_NO PICTURE '@!'
      READ
      IF MYES_NO = 'Y'
         DELETE
      ENDIF 
      MNOT_DONE = .F.
   ENDCASE
   
ENDDO
RETURN
* EOF: RSUPEDIT.PRG
*Formatted by: dANALYST Ver. 7.2b on October 4, 1987 at 09:49 PM.
