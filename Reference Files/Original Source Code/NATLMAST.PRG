****************
* Program.: NATLMAST.PRG
* Author..: GRACE KELLER
* Date....: 02/22/06
* Notice..: Copyright (C) 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: NATIONAL PRICING MASTER UPDATE
*

MTITLE = ' - VIEW/ADD/UPDATE NATIONAL PRICING MASTER'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
STORE DATE() TO MPOST_DATE
DIMENSION MUPDRCD(16)  
DIMENSION MCK(16)
DIMENSION MCK_LINE(16)
STORE 0 TO MZERO

MNEXT_ENT = .T.
SELECT A
DO FOX_USE WITH "&MDBFLOC.NATLMAST INDEX &MDBFLOC.NATLMAST", .F.
SELECT B
DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
@ 3,0 to 24,79
STORE ' ' TO MENTRY
@ 10,5 say '   Select One of the Following Options:'
@ 12,5 SAY '   (V) - View Master'
@ 13,5 say '   (A) - Add Items to Master'
@ 14,5 say '   (U) - Update Master'
@ 16,1 SAY 'Select:'
@ 16,9 GET MENTRY PICTURE '@!'
READ
IF MENTRY <> 'V' .AND. MENTRY <> 'A' .AND. MENTRY <> 'U'
   CLOSE DATA
   RETURN
ENDIF

SELECT A
DO CASE
CASE MENTRY  = 'A'
   @ 3,0 CLEAR
   @ 3,0 TO 5,79
   @ 04,1  SAY '     Prod Code     Description                 Natl Price'
   @ 24,0 TO 24,79
   MMORE = .T.
   MLINE = 7
   MPROD_DESC = SPACE(10)   
   MPRICE = 0

   DO WHILE MMORE .AND. MLINE <= 22
      @ MLINE,6 GET MPROD_DESC PICTURE '@!'
      READ
      IF MPROD_DESC = SPACE(10)
         MMORE = .F.
         LOOP
      ENDIF
      SELECT B
      SEEK 'R' + MPROD_DESC
      IF .NOT. EOF()
         @ MLINE,20 SAY DESC
      ENDIF
      @ MLINE,50 GET MPRICE PICTURE '99.9999'
      READ
      SELECT A
      SEEK MPROD_DESC
      IF EOF()
         DO FILELOCK
         APPEND BLANK
         REPLACE PROD_DESC WITH MPROD_DESC
         UNLOCK
      ENDIF
      DO RECLOCK
      REPLACE PRICE WITH MPRICE
      UNLOCK
      MLINE = MLINE + 1
      MPROD_DESC = SPACE(10)
      MPRICE = 0
   ENDDO

OTHERWISE

   @ 3,0 CLEAR
   @ 3,0 TO 5,79
   @ 04,1  SAY 'Sel  Prod Code     Description                 Natl Price'
   @ 24,0 TO 24,79
   MMORE = .T.
   STORE RECNO() TO MRECNO
   DO WHILE MMORE
      
      GOTO MRECNO
      MLINE = 7
      I = 1
      
      STORE 0 TO MCK_LINE, MUPDRCD   
      STORE SPACE(1) TO MCK
      
      DO WHILE .NOT. EOF() .AND. MMORE .AND. MLINE <= 22
         
         @ MLINE,6 SAY PROD_DESC             
         SELECT B
         SEEK 'R' + A->PROD_DESC
         IF .NOT. EOF()
            @ MLINE,20 SAY DESC
         ENDIF
         
         SELECT A
         @ MLINE,50 SAY PRICE PICTURE '99.9999'
         STORE MLINE TO MCK_LINE(I)
         STORE RECNO() TO MUPDRCD(I)

         MLINE = MLINE + 1
         I = I + 1
         SKIP
         STORE RECNO() TO MRECNO
      ENDDO
      
      STORE I-1 TO MMAX_I
      

      IF MENTRY = 'U'
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            I = 1
            STORE SPACE(1) TO MCK(I)
            DO WHILE I<= MMAX_I
               @ MCK_LINE(I),2 GET MCK(I) PICTURE '@!'
               READ
               IF MCK(I) = 'D'
                  GOTO MUPDRCD(I)
                  DO RECLOCK
                  DELETE
                  UNLOCK
                  STORE MCK_LINE(I) TO MLINE
                  @ MLINE,6  SAY SPACE(10)
                  @ MLINE,20 SAY SPACE(25)
                  @ MLINE,50 SAY MZERO PICTURE '99.9999'
               ELSE 
                  IF MCK(I) = 'X' .OR. MCK(I) = 'C'
                     GOTO MUPDRCD(I)
                     STORE PRICE TO MPRICE
                     @ MCK_LINE(I),50 GET MPRICE PICTURE '99.9999'
                     READ
                     DO RECLOCK
                     REPLACE PRICE WITH MPRICE
                     UNLOCK
                  ENDIF
               ENDIF
               @ MCK_LINE(I),2 SAY MCK(I)
               I = I + 1
            ENDDO
            
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue/Next Page     2. Edit      3. Finished'
            @ 24,9 GET MACTION PICTURE '9' range 1,3
            READ
         ENDDO
         IF MACTION = 3
            MMORE = .F.  
            LOOP
         ELSE
            IF EOF()
               MMORE = .F.
            ELSE
               @ 6,0 CLEAR TO 22,79
            ENDIF
         ENDIF
      ELSE
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue/Next Page     2. Finished'
         @ 24,9 GET MACTION PICTURE '9' range 1,2
         READ
         IF MACTION = 2
            MMORE = .F.  
            LOOP
         ELSE
            IF EOF()
               MMORE = .F.
            ELSE
               @ 6,0 CLEAR TO 22,79
            ENDIF
         ENDIF
      ENDIF
      
   ENDDO
ENDCASE
CLOSE DATA
RETURN
* EOF: NATLMAST.PRG
*Formatted by: ToolBox Ver. 1.2  on 2/22/6 at 2:35 PM.
