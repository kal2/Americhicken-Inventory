******************
* Program.: PO_SEL.PRG
* Author..: Grace Keller
* Date....: 10/19/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PURCHASE ORDER SELECT
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
STORE SPACE(2)    TO MSALESMAN
STORE SPACE(4)    TO MPO_NBR
STORE SPACE(1)    TO MPO_SUFFIX
STORE SPACE(2)    TO MINV_SLMN
STORE SPACE(5)    TO MINV_NBR
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
   @ 13,5 SAY 'Invoice Number'
   @ 15,7 say '-'
   @ 15,5 get minv_slmn picture '##'
   @ 15,8 get minv_nbr picture '#####'
   
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      DO CASE
      CASE MPO_NBR = SPACE(4) .AND. MINV_NBR = SPACE(5)
         MPO_SEL = .F.
         LOOP
      CASE MSALESMAN <> SPACE(2) .OR. MPO_NBR <> SPACE(4)
         SELECT B
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF EOF() .OR. DELETED()
            @ 23,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'PURCHASE ORDER NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
            READ
            LOOP
         ENDIF
      CASE MINV_NBR <> SPACE(5)
         STORE STR(VAL(MINV_NBR),5) TO MINV_NBR
         SELECT A
         DO FOX_USE WITH "INV_HEAD INDEX INV_HEAD", .F.
         
         SEEK MINV_NBR
         IF EOF() 
            @ 23,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'INVOICE NUMBER NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
            READ
            @ 24,0 CLEAR
            LOOP
         ENDIF
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         SELECT B
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF EOF()
            @ 23,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'CANNOT FIND MATCHING PURCHASE ORDER ON FILE - SELECT AGAIN ' GET MWAIT
            READ
            @ 24,0 CLEAR
            LOOP
         ENDIF
      ENDCASE
      
      
      IF .NOT. MVIEW
         DO PO_EDIT  
      ELSE
         IF MLAST_PG
            DO TOT_VIEW
         ELSE
            DO POVWMAIN
         ENDIF
      ENDIF
      *** IF FINISHED HERE GET OUT
      STORE SPACE(2)    TO MSALESMAN
      STORE SPACE(4)    TO MPO_NBR
      STORE SPACE(1)    TO MPO_SUFFIX
      STORE SPACE(2)    TO MINV_SLMN
      STORE SPACE(5)    TO MINV_NBR
      
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 3
      MPO_SEL = .F.
      
   ENDCASE
   
ENDDO

RETURN
* EOF: PO_SEL.PRG


*Formatted by: dANALYST Ver. 7.3a on July 1, 1988 at 3:40 PM.
