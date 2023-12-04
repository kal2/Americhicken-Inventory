*************
* Program.: CONFIRM.PRG
* Author..: Grace Keller
* Date....: 12/05/94
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINT ONE ORDER  
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT A
DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PRINT, PO_SUP, PO_SHIP, PO_FRT", .F.
MTITLE = ' - PRINT ORDER CONFIRMATIONS'
STORE SPACE(2)    TO MSALESMAN
STORE SPACE(4)    TO MPO_NBR
STORE SPACE(1)    TO MPO_SUFFIX
STORE 1 TO MACTION
MPO_SEL = .T.
DO WHILE MPO_SEL
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - SELECT ORDER'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   
   @  5, 5 SAY 'Enter Search Field:'
   @  8, 5 SAY 'Order Number'
   @ 10, 5 GET Msalesman PICTURE '##'
   @ 10,7 say '-'
   @ 10,8 get mpo_nbr picture '####'
   @ 10,12 say '-'
   @ 10,13 get mpo_suffix picture '@!'
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Print    2. Edit    3. Finished'
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   
   IF MACTION = 2
      LOOP
   ENDIF
   
   IF MACTION = 3 .OR. MPO_NBR = SPACE(4)
      MSALESMAN = SPACE(2)
      MPO_NBR = SPACE(4)
      MPO_SUFFIX = ' '
      MPO_SEL = .F.
      LOOP
   ENDIF
   
   SELECT A
   SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
   IF EOF() .OR. DELETED()
      @ 23,0 CLEAR
      MWAIT = ' '
      @ 24,10 SAY 'ORDER NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
      READ
      LOOP
   ENDIF
   DO CONFIRM1
   MSALESMAN = SPACE(2)
   MPO_NBR = SPACE(4)
   MPO_SUFFIX = ' '
ENDDO

CLOSE DATA

RETURN
* EOF: CONFIRM.PRG
*Formatted by: ToolBox Ver. 1.2  on 10/9/2 at 3:25 PM.
