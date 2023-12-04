*********************
* Program.: PRT_12A.PRG
* Author..: Grace Keller
* Date....: 11/15/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINTER SET UP

MSETUP = .T.
DO WHILE MSETUP
   STORE 'C' TO MPRT_ACT
   @ 22,02 SAY "LOAD PAPER/READY PRINTER - TYPE 'C' TO CONTINUE OR 'A' TO ABORT: "     ;
      GET MPRT_ACT PICTURE '@! A'
   READ
   DO CASE
   CASE MPRT_ACT = 'C'
      MSETUP = .F.
      LOOP                
   CASE MPRT_ACT = 'A'
      MSETUP = .F.
      LOOP         
   ENDCASE
ENDDO
@ 22,02 CLEAR TO 22,77     
RETURN
* EOF: PRT_12A.PRG
*Formatted by: ToolBox Ver. 1.2  on 1/31/97 at 2:16 AM.
