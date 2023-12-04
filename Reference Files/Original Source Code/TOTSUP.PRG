**********
* Program.: TOTSUP.PRG
* Author..: Grace Keller
* Date....: 03/09/88
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: CALCUALTE SUPPLIER INVOICE BILLING
*
* ---OPEN FILES
MTOT = 0
MTOT_BILL = 0
MSW_DIFF = 0
SELECT B
STORE SALESMAN TO MSALESMAN
STORE PO_NBR TO MPO_NBR
STORE PO_SUFFIX TO MPO_SUFFIX
SELECT D
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
DO WHILE MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX  .AND. .NOT. EOF()
   
   IF BILL_PRI = 0
      MVAL1 = (LBS+SHRT_LBS) * PUR_PRICE 
      MVAL2 = SHRT_LBS * PUR_PRICE
      
      IF MVAL1 >= 0
         MVAL1 = INT((MVAL1+.005) * 100) / 100
      ELSE
         MVAL1 = INT((MVAL1-.005) * 100) / 100
      ENDIF
      
      IF MVAL2 >= 0
         MVAL2 = INT((MVAL2+.005) * 100) / 100
      ELSE
         MVAL2 = INT((MVAL2-.005) * 100) / 100
      ENDIF  
      
      
      *********************
      *     IF MVAL1 <> 0
      *        MVAL = INT(MVAL1*100)
      *        IF (ABS(MVAL1) * 100) - ABS(MVAL) > .49
      *           IF MVAL1 >= 0
      *              MVAL1 = (MVAL + 1) / 100
      *           ELSE
      *              MVAL1 = (MVAL - 1) / 100
      *           ENDIF
      *        ELSE
      *           MVAL1 = MVAL / 100
      *        ENDIF
      *     ENDIF
      *     IF MVAL2 <> 0
      *        MVAL = INT(MVAL2*100)
      *        IF (ABS(MVAL2) * 100) - ABS(MVAL) > .49
      *           IF MVAL2 >= 0
      *              MVAL2 = (MVAL + 1) / 100
      *           ELSE
      *              MVAL2 = (MVAL - 1) / 100
      *           ENDIF
      *        ELSE
      *           MVAL2 = MVAL / 100
      *        ENDIF
      *     ENDIF
      
      *MTOT = MTOT + (MVAL1 - MVAL2)
      MTOT = MTOT + MVAL1
   ELSE
      
      MVAL1 = (LBS+SHRT_LBS) * BILL_PRI  
      MVAL2 = SHRT_LBS * BILL_PRI
      
      IF MVAL1 >= 0
         MVAL1 = INT((MVAL1+.005) * 100) / 100
      ELSE
         MVAL1 = INT((MVAL1-.005) * 100) / 100
      ENDIF
      
      IF MVAL2 >= 0
         MVAL2 = INT((MVAL2+.005) * 100) / 100
      ELSE
         MVAL2 = INT((MVAL2-.005) * 100) / 100
      ENDIF  
      
      *************
      *     IF MVAL1 <> 0
      *        MVAL = INT(MVAL1*100)
      *        IF (ABS(MVAL1) * 100) - ABS(MVAL) > .49
      *           IF MVAL1 >= 0
      *              MVAL1 = (MVAL + 1) / 100
      *           ELSE
      *              MVAL1 = (MVAL - 1) / 100
      *           ENDIF
      *        ELSE
      *           MVAL1 = MVAL / 100
      *        ENDIF
      *     ENDIF
      *     IF MVAL2 <> 0
      *        MVAL = INT(MVAL2*100)
      *        IF (ABS(MVAL2) * 100) - ABS(MVAL) > .49
      *           IF MVAL2 >= 0
      *              MVAL2 = (MVAL + 1) / 100
      *           ELSE
      *              MVAL2 = (MVAL - 1) / 100
      *           ENDIF
      *        ELSE
      *           MVAL2 = MVAL / 100
      *        ENDIF
      *     ENDIF
      *     
      MTOT = MTOT + MVAL1
      
      ***MTOT = MTOT + (MVAL1 - MVAL2)
   ENDIF
   
   SKIP
ENDDO
RETURN
* EOF: TOTSUP.PRG


*Formatted by: ToolBox Ver. 1.2  on 5/23/97 at 12:53 PM.
