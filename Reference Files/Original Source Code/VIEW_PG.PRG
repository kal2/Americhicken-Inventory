**********
* Program.: VIEW_PG.PRG
* Author..: Grace Keller
* Date....: 10/26/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PURCHASE ORDER VIEW - MULTIPLE PAGES
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_ITM = .T.  
MPAGE = 2
@ 3,0 CLEAR
DO TEXT2ND
@ 3,65 SAY 'ITEMS: PAGE '

DO WHILE MMORE_ITM
   @ 3,77 SAY STR(MPAGE,2)
   MMAX_ITM = 0
   MNBR_ITM = 1
   MLINE = 08 
   SELECT C
   IF .NOT. EOF()
      GOTO MRECNO
   ENDIF
   DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. VAL(ITEM_NBR) <= 9 + ((MPAGE-1) * 15)     
      DO STORITM
      DO SAYITM
      MLINE = MLINE + 1
      MMAX_ITM = MMAX_ITM + 1
      MNBR_ITM = MNBR_ITM + 1
      SKIP
   ENDDO
   STORE RECNO() TO MRECNO
   IF .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
      @ 23,67 SAY 'More Items...'
   ELSE
      @ 23,67 TO 23,79
   ENDIF
   STORE 1 TO MACTION
   @ 24,0 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Totals/Frt/Comm    2. Next Item Pg.   3. Finish View'
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
   
   READ
   
   DO CASE      
   CASE MACTION = 1
      DO FRT_VIEW
      MMORE_ITM = .F.
   CASE MACTION = 2
      @ 8,0 CLEAR TO 22,79 
      MPAGE = MPAGE + 1
      LOOP      
   CASE MACTION = 3
      MMORE_ITM = .F.
   ENDCASE 
ENDDO 

RETURN
* EOF: VIEW_PG.PRG
*Formatted by: FoxToolBox Ver. 0.8c on October 28, 1987 at 2:06 PM.
