******************
* Program.: PO_SEL2.PRG
* Author..: Grace Keller
* Date....: 10/19/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PURCHASE ORDER SELECT
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SET PROC TO PO_PROC
STORE SPACE(2)    TO MSALESMAN
STORE SPACE(4)    TO MPO_NBR
STORE SPACE(1)    TO MPO_SUFFIX
   SELECT B
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
MPO_FD = .F.
STORE 1 TO MACTION
MPO_SEL = .T.
DO WHILE MPO_SEL
   
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - SELECT PURCHASE ORDER'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   @  5, 5 SAY 'Enter Search Field:'
   @  8, 5 SAY 'Purchase Order Number'
   @ 10, 5 GET Msalesman PICTURE '##'
   @ 10,7 say '-'
   @ 10,8 get mpo_nbr picture '####'
   @ 10,12 say '-'
   @ 10,13 get mpo_suffix picture '@!'
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      IF MPO_NBR <> SPACE(4)
         SELECT B
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF EOF() .OR. DELETED()
            @ 23,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'PURCHASE ORDER NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
            READ
            LOOP
         ELSE
           DO RECLOCK  
           REPLACE COM_PD WITH ' '
           UNLOCK
            **** IF FINISHED HERE, GET OUT
            STORE SPACE(2)    TO MSALESMAN
            STORE SPACE(4)    TO MPO_NBR
            STORE SPACE(1)    TO MPO_SUFFIX
            LOOP
         ENDIF
      ENDIF     
      
      MPO_SEL = .F.
      LOOP
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 3
      MPO_SEL = .F.
      
   ENDCASE
   
ENDDO
CLOSE DATA
RETURN
* EOF: PO_SEL2.PRG


*Formatted by: FoxToolBox Ver. 0.8c on October 28, 1987 at 2:01 PM.
