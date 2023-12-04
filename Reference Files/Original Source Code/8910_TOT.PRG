**********
* Program.: 8910_TOT.PRG
* Author..: Grace Keller
* Date....: 10/21/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: CALCULATE 8910 TOTALS
*
* ---OPEN FILES
STORE 0 TO MTOT_LBS
** RON MONTGOMERY CHANGES
SELECT C
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
DO WHILE MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX  .AND. .NOT. EOF()
   ** ADDED THE 00318 AND 11655 PRODUCTS ON 01/06/2017
   ** ADDED 2265 ON 11/28/2018
   IF (PROD_DESC = '8910' .OR. PROD_DESC = '00318' .OR. PROD_DESC = '11655' .OR. PROD_DESC = '2265') .AND. B->BBUYCODE <> 'INVN'
      MTOT_LBS = MTOT_LBS + QTY
   ENDIF
   SKIP
ENDDO

IF MTOT_LBS <> 0 .OR. B->CASE_8910 <> 0
   IF B->SHIP_DATE < CTOD('10/01/2022')
      SELECT B
      DO RECLOCK
      REPLACE CASE_8910 WITH MTOT_LBS
      UNLOCK
      MTOT_LBS = 0
   ELSE
      *** as of 10/01/2022  RON does not get this commission
      *** so zero out the case_8910 field  and amount if formatted
      SELECT B
      DO RECLOCK
      REPLACE CASE_8910 WITH 0
      REPLACE SALE2_CEN WITH 0
      IF B->BROKERAGE = 'H'
         REPLACE SAL_CODE2 with space(2)
         REPLACE SALE2_AMT  with 0
      ENDIF
      UNLOCK
      MTOT_LBS = 0
   ENDIF
ENDIF

RETURN

* EOF: 8910_TOT.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/12/96 at 7:34 PM.
