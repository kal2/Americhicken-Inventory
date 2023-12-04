*********************
* Program.: PRT_10.PRG
* Author..: Grace Keller
* Date....: 11/15/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINTER SET UP

MSETUP = .T.

DO WHILE MSETUP
   
   STORE 'C' TO MPRT_ACT
   
   @ 19,01 SAY 'LOAD WHITE PAPER AND READY THE PRINTER'
   @ 20,01 SAY "TYPE 'C' TO CONTINUE OR 'A' TO ABORT: "     ;
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
@ 19,1 SAY SPACE(78)
@ 20,1 SAY SPACE(78)
RETURN
* EOF: PRT_10.PRG
