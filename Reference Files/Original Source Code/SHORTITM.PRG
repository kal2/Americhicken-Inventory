**********
* Program.: SHORTITM.PRG
* Author..: Grace Keller
* Date....: 10/30/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: ENTER ITEM SHORT WEIGHT
*
SET DECIMALS TO 5
@ 8,0 CLEAR TO 22,79
@ 24,0 CLEAR
STORE 'SHORTWT   ' TO MREAS_CODE
STORE SPACE(25) TO MREAS_DESC
STORE 1 TO MACTION
@ 24,0 SAY 'Action: ' + STR(MACTION,1)
@ 24,12 SAY '1. Finished with Item Edit      2. Edit Screen'

MACTION = 2
DO WHILE MACTION = 2   
   DO GETSHORT
   STORE 1 TO MACTION
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,2
   READ
ENDDO
MLBS(MNBR_ITM) = MLBS_X

MVAL1 = (MLBS_X + MSW_LBS) * MPURC_PRI(MNBR_ITM) 
MVAL2 = MSW_LBS * MPURC_PRI(MNBR_ITM)

IF MVAL1 <> 0
   MVAL = INT(MVAL1*100)
   IF (ABS(MVAL1) * 100) - ABS(MVAL) > .49
      IF MVAL1 >= 0
         MVAL1 = (MVAL + 1) / 100
      ELSE
         MVAL1 = (MVAL - 1) / 100
      ENDIF
   ELSE
      MVAL1 = MVAL / 100
   ENDIF
ENDIF

IF MVAL2 <> 0
   MVAL = INT(MVAL2*100)
   IF (ABS(MVAL2) * 100) - ABS(MVAL) > .49
      IF MVAL2 >= 0
         MVAL2 = (MVAL + 1) / 100
      ELSE
         MVAL2 = (MVAL - 1) / 100
      ENDIF
   ELSE
      MVAL2 = MVAL / 100
   ENDIF
ENDIF

MPURC_TOT(MNBR_ITM) = MVAL1 - MVAL2

******************************************************************************
******************************************************************************

MVAL1 = (MLBS_X + MSW_LBS) * MSELL_PRI(MNBR_ITM) 
MVAL2 = MSW_LBS * MSELL_PRI(MNBR_ITM)

IF MVAL1 <> 0
   MVAL = INT(MVAL1*100)
   IF (ABS(MVAL1) * 100) - ABS(MVAL) > .49
      IF MVAL1 >= 0
         MVAL1 = (MVAL + 1) / 100
      ELSE
         MVAL1 = (MVAL - 1) / 100
      ENDIF
   ELSE
      MVAL1 = MVAL / 100
   ENDIF
ENDIF

IF MVAL2 <> 0
   MVAL = INT(MVAL2*100)
   IF (ABS(MVAL2) * 100) - ABS(MVAL) > .49
      IF MVAL2 >= 0
         MVAL2 = (MVAL + 1) / 100
      ELSE
         MVAL2 = (MVAL - 1) / 100
      ENDIF
   ELSE
      MVAL2 = MVAL / 100
   ENDIF
ENDIF

MSELL_TOT(MNBR_ITM) = MVAL1 - MVAL2


MSHRT_BOX(MNBR_ITM) = MLBS_BOX
MSHRT_LBS(MNBR_ITM) = MSW_LBS
RETURN

* EOF: SHORTITM.PRG


*Formatted by: ToolBox Ver. 1.2  on 12/12/94 at 3:52 PM.
