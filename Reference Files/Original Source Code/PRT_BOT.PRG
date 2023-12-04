*********************
* Program.: PRT_BOT.PRG
* Author..: Grace Keller
* Date....: 11/15/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINTER SET UP

MSETUP = .T.
@ 23,0 CLEAR
DO WHILE MSETUP
   
   STORE 'C' TO MACTION
   @ 23,01 SAY 'LOAD PAPER AND READY THE PRINTER'
   @ 24,01 SAY "TYPE 'C' TO CONTINUE OR 'A' TO ABORT: "     ;
      GET MACTION PICTURE '@! A'
   
   READ
   
   DO CASE
      
   CASE MACTION = 'C'
      MSETUP = .F.
      LOOP                
   CASE MACTION = 'A'
      MSETUP = .F.
      LOOP         
   ENDCASE
ENDDO
@ 23,0 CLEAR
STORE MACTION TO MPRT_ACT
RETURN
* EOF: PRT_BOT.PRG
*Formatted by: ToolBox Ver. 1.2  on 2/11/96 at 4:04 PM.
