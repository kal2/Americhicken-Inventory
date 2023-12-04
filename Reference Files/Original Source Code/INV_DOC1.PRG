************
* Program.: INV_DOC.PRG
* Author..: Grace Keller
* Date....: 10/26/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: INVOICE DOCUMENT PRINT
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

*** IF SHIPPED WITH - PRETEND LIKE THERE ARE NO ITEMS OR ADJUSTMENTS
SET PROCEDURE TO INV_DOC1
STORE SPACE(4) TO MPO_SHIP1, MPO_SHIP2, MPO_SHIP3, MPO_SHIP3, MPO_SHIP4, MPO_SHIP5, MPO_SHIP6
STORE SPACE(1) TO MPO_SUFF1, MPO_SUFF2, MPO_SUFF3, MPO_SUFF3, MPO_SUFF4, MPO_SUFF5, MPO_SUFF6
SELECT A
IF SHIP_NBR <> SPACE(4)
   *** THIS IS A SHIPPED WITH PO *** DONT DO ITEMS
   SELECT B
   DO FOX_USE WITH "C:\COMPWORK\DTL_TEMP", .T.
   DELETE ALL
   PACK
ELSE
   IF MAIN_SHIP = 'Y' .OR. MCOMPANY = 'AMERICHICKEN, INC'
      SELECT E
      DO FOX_USE WITH "SHIPWITH INDEX SHIPWITH", .F.
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      IF .NOT. EOF()         
         STORE PO_SHIP1 TO MPO_SHIP1
         STORE PO_SHIP2 TO MPO_SHIP2
         STORE PO_SHIP3 TO MPO_SHIP3
         STORE PO_SHIP4 TO MPO_SHIP4
         STORE PO_SHIP5 TO MPO_SHIP5
         STORE PO_SHIP6 TO MPO_SHIP6
         STORE PO_SUFF1 TO MPO_SUFF1
         STORE PO_SUFF2 TO MPO_SUFF2
         STORE PO_SUFF3 TO MPO_SUFF3
         STORE PO_SUFF4 TO MPO_SUFF4
         STORE PO_SUFF5 TO MPO_SUFF5
         STORE PO_SUFF6 TO MPO_SUFF6
      ENDIF
      
      SELECT E
      DO FOX_USE WITH "C:\COMPWORK\DTL_TEMP", .T.
      DELETE ALL
      PACK
      INDEX ON PROD_DESC + STR_PRI TO C:\COMPWORK\DTL_TEMP            
      DO FOX_USE WITH "C:\COMPWORK\DTL_TEMP INDEX C:\COMPWORK\DTL_TEMP", .T.
      
      SELECT B
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      *** GET THE MAIN PO ITEMS         
      DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
         STORE STR(SEL_PRICE,7,4) TO MSTR_PRI
         SELECT E
         SEEK B->PROD_DESC + MSTR_PRI
         IF EOF()
            APPEND BLANK
            REPLACE SALESMAN WITH MSALESMAN
            REPLACE PO_NBR   WITH MPO_NBR
            REPLACE PO_SUFFIX WITH MPO_SUFFIX
            REPLACE PROD_DESC WITH B->PROD_DESC
            REPLACE SEL_PRICE WITH B->SEL_PRICE
            REPLACE STR_PRI   WITH MSTR_PRI
         ENDIF
         REPLACE QTY      WITH QTY + B->QTY
         REPLACE FRH_FRZ  WITH B->FRH_FRZ
         REPLACE GRADE    WITH B->GRADE
         REPLACE PACKAGED WITH B->PACKAGED
         REPLACE PRODUCT  WITH B->PRODUCT
         REPLACE SIZE     WITH B->SIZE
         REPLACE PACKED   WITH B->PACKED
         REPLACE LBS      WITH LBS + B->LBS
         REPLACE PUR_PRICE WITH B->PUR_PRICE
         REPLACE TOT_SELL WITH TOT_SELL + B->TOT_SELL
         REPLACE TOT_PURCH WITH TOT_PURCH + B->TOT_PURCH
         REPLACE BILL_PRI  WITH B->BILL_PRI
         REPLACE SHORT_FLG WITH B->SHORT_FLG
         REPLACE SHRT_BOX  WITH B->SHRT_BOX
         REPLACE SHRT_LBS  WITH B->SHRT_LBS
         
         SELECT B
         SKIP
      ENDDO
      ******
      *** NOW GET ALL THE SHIPPED WITH ITEMS
      I = 1
      DO WHILE I<= 6
         STORE STR(I,1) TO MI
         IF MPO_SHIP&MI = SPACE(4)
            I = I + 1
            LOOP
         ENDIF
         SELECT B
         SEEK MSALESMAN + MPO_SHIP&MI + MPO_SUFF&MI
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_SHIP&MI .AND. PO_SUFFIX = MPO_SUFF&MI
            STORE STR(SEL_PRICE,7,4) TO MSTR_PRI
            SELECT E
            SEEK B->PROD_DESC + MSTR_PRI
            IF EOF()
               APPEND BLANK
               REPLACE SALESMAN WITH MSALESMAN
               REPLACE PO_NBR   WITH MPO_NBR
               REPLACE PO_SUFFIX WITH MPO_SUFFIX
               REPLACE PROD_DESC WITH B->PROD_DESC
               REPLACE SEL_PRICE WITH B->SEL_PRICE
               REPLACE STR_PRI   WITH MSTR_PRI
            ENDIF
            REPLACE QTY      WITH QTY + B->QTY
            REPLACE FRH_FRZ  WITH B->FRH_FRZ
            REPLACE GRADE    WITH B->GRADE
            REPLACE PACKAGED WITH B->PACKAGED
            REPLACE PRODUCT  WITH B->PRODUCT
            REPLACE SIZE     WITH B->SIZE
            REPLACE PACKED   WITH B->PACKED
            REPLACE LBS      WITH LBS + B->LBS
            REPLACE PUR_PRICE WITH B->PUR_PRICE
            REPLACE TOT_SELL WITH TOT_SELL + B->TOT_SELL
            REPLACE TOT_PURCH WITH TOT_PURCH + B->TOT_PURCH
            REPLACE BILL_PRI  WITH B->BILL_PRI
            REPLACE SHORT_FLG WITH B->SHORT_FLG
            REPLACE SHRT_BOX  WITH B->SHRT_BOX
            REPLACE SHRT_LBS  WITH B->SHRT_LBS
            SELECT B
            SKIP
         ENDDO
         I = I + 1
      ENDDO
      SELECT E
      USE
      **** NOW SWITCH OVER TO THE TEMP FILE
      SELECT B
      DO FOX_USE WITH "C:\COMPWORK\DTL_TEMP INDEX C:\COMPWORK\DTL_TEMP", .F.
      
   ELSE
      SELECT B
      DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
   ENDIF
ENDIF

SELECT B

IF .NOT. EOF()
   MNO_ITM = .F.
   MHEAD_PRT = .T.
ENDIF
DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
   IF PROD_DESC = SPACE(5) .OR. TOT_SELL = 0
      SKIP
      LOOP
   ENDIF
   IF MHEAD_PRT
      STORE SUBSTR(PROD_DESC,1,6) TO MPROD
   ENDIF
   IF MHEAD_PRT
      DO IHD_PRT
   ENDIF
   SELECT A
   IF MCK_BROK
      MCK_BROK = .F.
      IF BROKERAGE = 'X'
         ? SPACE(15) + 'BROKERAGE FEE'
         ?
         MLINE = MLINE + 2
      ENDIF
   ENDIF
   
   SELECT B
   STORE SPACE(4) TO MPART0
   STORE SPACE(6) TO MPART1
   STORE SPACE(8) TO MPART2, MPART3, MPART6
   STORE SPACE(9) TO MPART3_X
   STORE SPACE(20) TO MPART4
   STORE SPACE(13) TO MPART5
   SELECT C
   DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
   IF MCOMPANY = 'AMERICHICKEN, INC'
      MPART0 = SUBSTR(B->PROD_DESC,1,6) 
   ENDIF
   IF B->FRH_FRZ <> SPACE(2)
      SEEK 'F' + B->FRH_FRZ
      IF .NOT. EOF()
         STORE SUBSTR(DESC,1,6) TO MPART1
      ENDIF
   ENDIF
   IF B->GRADE <> SPACE(1)
      SEEK 'G' + B->GRADE
      IF .NOT. EOF()
         STORE SUBSTR(DESC,1,8) TO MPART2
      ENDIF
   ENDIF
   
   IF SUBSTR(B->PACKAGED,1,1) <> SPACE(1)
      SEEK 'D' + SUBSTR(B->PACKAGED,1,1)
      IF .NOT. EOF()
         STORE SUBSTR(DESC,1,8) TO MPART3
      ENDIF
   ENDIF
   
   IF SUBSTR(B->PACKAGED,2) <> SPACE(1)
      SEEK 'K' + SUBSTR(B->PACKAGED,2)
      IF .NOT. EOF()
         STORE SUBSTR(DESC,1,9) TO MPART3_X
      ENDIF
   ELSE
      DO CASE
      CASE SUBSTR(B->PACKAGED,1,1) = 'I'
         STORE 'ICE PACK' TO MPART3
      CASE SUBSTR(B->PACKAGED,1,1) = 'L'
         STORE 'CHILL PK' TO MPART3
      ENDCASE
   ENDIF
   
   IF MPART3 = SPACE(8)
      MPART3 = MPART3_X             
   ELSE
      MPART3 = TRIM(MPART3) + ' ' + MPART3_X  
   ENDIF
   
   IF B->PROD_DESC <> 'BROKERAGE'
      SEEK 'R' + B->PROD_DESC
      IF .NOT. EOF()
         STORE DESC TO MPART4 
      ENDIF
   ENDIF
   
   IF B->SIZE <> SPACE(5)
      SEEK 'Z' + B->SIZE
      IF .NOT. EOF()
         STORE SUBSTR(DESC,1,13) TO MPART5
      ENDIF
   ENDIF
   IF B->PACKED <> SPACE(4)
      SEEK 'S' + B->PACKED
      IF .NOT. EOF()
         STORE SUBSTR(DESC,1,8) TO MPART6
         ** BOUGHT BY THE POUND AND SOLD BY THE CASE
         ** MEIJER BOT BY LB, SOLD BY LB- ASSUME 32# CASE WT ALWAYS
         *** CUSTOMER = 'ASSOCIATED GROCERS' AND PRODUCT = 47184
         DO CASE
         CASE A->BBUYCODE = ' 189' .AND. B->PROD_DESC = '47184'
            MPART6 = '37-41#'
         CASE A->BBUYCODE = ' 226' .AND. B->PROD_DESC = '47184'
            MPART6 = '37-41#'
         CASE A->BBUYCODE = ' 226' .AND. B->PROD_DESC = '36089'
            MPART6 = '37-41#'
         CASE A->BBUYCODE = ' 226' .AND. B->PROD_DESC = '36429'
            MPART6 = '38.5#/AVG'
         CASE A->BBUYCODE = ' 227' .AND. B->PROD_DESC = '36679'
            MPART6 = '39#'
         CASE A->BBUYCODE = ' 227' .AND. B->PROD_DESC = '36089'
            MPART6 = '39#'
         CASE A->BBUYCODE = '  96' .AND. (B->PROD_DESC = '65521' .OR. B->PROD_DESC = '65543')
            MPART6 = '32.5#'
         CASE (A->BBUYCODE = ' 231' .OR. A->BBUYCODE = '  84' .OR. A->BBUYCODE = ' 189') .AND. (B->PROD_DESC = '51160' .OR. B->PROD_DESC = '51221')
            **MPART6 = '32#/AVG'
            MPART6 = 'AVG WT'
         ENDCASE
      ENDIF
   ENDIF
   
   SELECT B
   
   ? SPACE(5) + TRANSFORM(QTY, '@Z 9999') + SPACE(7)
   
   MPRT_LINE = ' '
   MPART0 = TRIM(MPART0)
   MPART1 = TRIM(MPART1)
   MPART2 = TRIM(MPART2)
   MPART3 = TRIM(MPART3)
   MPART4 = TRIM(MPART4)
   MPART5 = TRIM(MPART5)
   MPART6 = TRIM(MPART6)
   
   MLEN0 = LEN(MPART0)
   MLEN1 = LEN(MPART1)
   MLEN2 = LEN(MPART2)
   MLEN3 = LEN(MPART3)
   MLEN4 = LEN(MPART4)
   MLEN5 = LEN(MPART5)
   MLEN6 = LEN(MPART6)
   IF MLEN0 <> 0
      MPRT_LINE = MPRT_LINE + MPART0 + ' '
   ENDIF
   IF MLEN1 <> 0
      MPRT_LINE = MPRT_LINE + MPART1 + ' '
   ENDIF
   IF MLEN2 <> 0
      MPRT_LINE = MPRT_LINE + MPART2 + ' '
   ENDIF
   IF MLEN4 <> 0
      MPRT_LINE = MPRT_LINE + MPART4 + ' '
   ENDIF
   IF MLEN5 <> 0
      MPRT_LINE = MPRT_LINE + MPART5 + ' '
   ENDIF
   IF MLEN6 <> 0
      MPRT_LINE = MPRT_LINE + MPART6 + ' '
   ENDIF
   IF MLEN3 <> 0
      MPRT_LINE = MPRT_LINE + MPART3 + ' '
   ENDIF
   MPRT_LINE = TRIM(SUBSTR(MPRT_LINE,2))
   MTOT_LEN = LEN(MPRT_LINE)
   IF MTOT_LEN > 49
      ?? SUBSTR(MPRT_LINE,1,49)
      MTOT_LEN = 49
   ELSE
      ?? MPRT_LINE
   ENDIF
   MDIFF = 50 - MTOT_LEN
   ?? SPACE(MDIFF)             
   IF MCOPY_ONLY
      DO CASE
         
      CASE PROD_DESC = '47184' .AND. A->BBUYCODE = ' 189'
         ?? TRANSFORM(QTY, '@Z 999,999.99')
      CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '47184'
         ?? TRANSFORM(QTY, '@Z 999,999.99')
      CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '36089'
         ?? TRANSFORM(QTY, '@Z 999,999.99')
      CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '36429'
         ?? TRANSFORM(QTY, '@Z 999,999.99')
      CASE A->BBUYCODE = ' 227'.AND. PROD_DESC = '36679'
         ?? TRANSFORM(QTY, '@Z 999,999.99')
      CASE A->BBUYCODE = ' 227'.AND. PROD_DESC = '36089'
         ?? TRANSFORM(QTY, '@Z 999,999.99')
      CASE A->BBUYCODE = '  96' .AND. (PROD_DESC = '65521' .OR. PROD_DESC = '65543')
         ?? TRANSFORM(QTY, '@Z 999,999.99')
      CASE (A->BBUYCODE = ' 231' .OR. A->BBUYCODE = '  84' .OR. A->BBUYCODE = ' 189') .AND. (PROD_DESC = '51160' .OR. PROD_DESC = '51221')
         **?? TRANSFORM(QTY*32, '@Z 999,999.99')
         ?? TRANSFORM(QTY, '@Z 999,999.99')
      OTHERWISE
         ?? TRANSFORM(LBS+SHRT_LBS, '@Z 999,999.99')
      ENDCASE
      
      ?? SPACE(2) + TRANSFORM(SEL_PRICE, '@Z 99.9999')
      
      DO CASE
      CASE PROD_DESC = '47184' .AND. A->BBUYCODE = ' 189'
         MVAL1 = QTY * SEL_PRICE
         MVAL2 = SHRT_LBS * SEL_PRICE
      CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '47184'
         MVAL1 = QTY * SEL_PRICE
         MVAL2 = SHRT_LBS * SEL_PRICE
      CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '36089'
         MVAL1 = QTY * SEL_PRICE
         MVAL2 = SHRT_LBS * SEL_PRICE
      CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '36429'
         MVAL1 = QTY * SEL_PRICE
         MVAL2 = SHRT_LBS * SEL_PRICE
      CASE A->BBUYCODE = ' 227'.AND. PROD_DESC = '36679'
         MVAL1 = QTY * SEL_PRICE
         MVAL2 = SHRT_LBS * SEL_PRICE
      CASE A->BBUYCODE = ' 227'.AND. PROD_DESC = '36089'
         MVAL1 = QTY * SEL_PRICE
         MVAL2 = SHRT_LBS * SEL_PRICE
      CASE A->BBUYCODE = '  96' .AND. (PROD_DESC = '65521' .OR. PROD_DESC = '65543')
         MVAL1 = QTY * SEL_PRICE
         MVAL2 = SHRT_LBS * SEL_PRICE
      CASE (A->BBUYCODE = ' 231' .OR. A->BBUYCODE = '  84' .OR. A->BBUYCODE = ' 189') .AND. (PROD_DESC = '51160' .OR. PROD_DESC = '51221')
         **MVAL1 = (QTY * 32) * SEL_PRICE
         MVAL1 = QTY * SEL_PRICE
         MVAL2 = SHRT_LBS * SEL_PRICE
      OTHERWISE
         MVAL1 = (LBS+SHRT_LBS) * SEL_PRICE
         MVAL2 = SHRT_LBS * SEL_PRICE
      ENDCASE
      
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
      
      MSELL = MVAL1           
      
      ?? SPACE(3) + TRANSFORM(MSELL, '@Z 999999.99')
      ?
      MTOTAL = MTOTAL + MSELL
   ELSE
      IF SHORT_FLG <> ' ' .AND. MCUST_SW
         DO CASE
            
         CASE PROD_DESC = '47184' .AND. A->BBUYCODE = ' 189'
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '47184'
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '36429'
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '36089'
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE A->BBUYCODE = ' 227'.AND. PROD_DESC = '36679'
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE A->BBUYCODE = ' 227'.AND. PROD_DESC = '36089'
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE A->BBUYCODE = '  96' .AND. (PROD_DESC = '65521' .OR. PROD_DESC = '65543')
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE (A->BBUYCODE = ' 231' .OR. A->BBUYCODE = '  84' .OR. A->BBUYCODE = ' 189') .AND. (PROD_DESC = '51160' .OR. PROD_DESC = '51221')
            **?? TRANSFORM((QTY*32), '@Z 999,999.99')
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         OTHERWISE
            ?? TRANSFORM(LBS+ SHRT_LBS, '@Z 999,999.99')
         ENDCASE
      ELSE
         DO CASE
         CASE PROD_DESC = '47184' .AND. A->BBUYCODE = ' 189'
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '47184'
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '36089'
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '36429'
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE A->BBUYCODE = ' 227'.AND. PROD_DESC = '36779'
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE A->BBUYCODE = ' 227'.AND. PROD_DESC = '36089'
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE A->BBUYCODE = '  96' .AND. (PROD_DESC = '65521' .OR. PROD_DESC = '65543')
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         CASE (A->BBUYCODE = ' 231' .OR. A->BBUYCODE = '  84' .OR. A->BBUYCODE = ' 189') .AND. (PROD_DESC = '51160' .OR. PROD_DESC = '51221')
            **?? TRANSFORM((QTY*32), '@Z 999,999.99')
            ?? TRANSFORM(QTY, '@Z 999,999.99')
         OTHERWISE
            ?? TRANSFORM(LBS, '@Z 999,999.99')
         ENDCASE
      ENDIF
      ?? SPACE(2) + TRANSFORM(SEL_PRICE, '@Z 99.9999')
      IF SHORT_FLG <> ' ' .AND. MCUST_SW 
         DO CASE
         CASE A->BBUYCODE = ' 189'.AND. PROD_DESC = '47184'
            MVAL1 = QTY * SEL_PRICE
            MVAL2 = SHRT_LBS * SEL_PRICE
            **226 = NASH FINCH CUSTOMER
            **AS OF 08/14/2007
         CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '47184'
            MVAL1 = QTY * SEL_PRICE
            MVAL2 = SHRT_LBS * SEL_PRICE
            **AS OF 08/22/2007
         CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '36089'
            MVAL1 = QTY * SEL_PRICE
            MVAL2 = SHRT_LBS * SEL_PRICE
         CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '36429'
            MVAL1 = QTY * SEL_PRICE
            MVAL2 = SHRT_LBS * SEL_PRICE
         CASE A->BBUYCODE = ' 227'.AND. PROD_DESC = '36679'
            MVAL1 = QTY * SEL_PRICE
            MVAL2 = SHRT_LBS * SEL_PRICE
         CASE A->BBUYCODE = ' 227'.AND. PROD_DESC = '36089'
            MVAL1 = QTY * SEL_PRICE
            MVAL2 = SHRT_LBS * SEL_PRICE
         CASE A->BBUYCODE = '  96' .AND. (PROD_DESC = '65521' .OR. PROD_DESC = '65543')
            MVAL1 = QTY * SEL_PRICE
            MVAL2 = SHRT_LBS * SEL_PRICE
         CASE (A->BBUYCODE = ' 231' .OR. A->BBUYCODE = '  84' .OR. A->BBUYCODE = ' 189') .AND. (PROD_DESC = '51160' .OR. PROD_DESC = '51221')
            **MVAL1 = (QTY*32) * SEL_PRICE
            MVAL1 = QTY * SEL_PRICE
            MVAL2 = SHRT_LBS * SEL_PRICE

         OTHERWISE
            MVAL1 = (LBS + SHRT_LBS) * SEL_PRICE
            MVAL2 = SHRT_LBS * SEL_PRICE
         ENDCASE
         
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
         
         MSELL = MVAL1 - MVAL2
      ELSE
         ** MSELL = ROUND(LBS * SEL_PRICE,2)
         
         DO CASE
         CASE PROD_DESC = '47184' .AND. A->BBUYCODE = ' 189'
            MVAL1 = QTY * SEL_PRICE
         CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '47184'
            MVAL1 = QTY * SEL_PRICE
         CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '36089'
            MVAL1 = QTY * SEL_PRICE
         CASE A->BBUYCODE = ' 226'.AND. PROD_DESC = '36429'
            MVAL1 = QTY * SEL_PRICE
         CASE A->BBUYCODE = ' 227'.AND. PROD_DESC = '36679'
            MVAL1 = QTY * SEL_PRICE
         CASE A->BBUYCODE = ' 227'.AND. PROD_DESC = '36089'
            MVAL1 = QTY * SEL_PRICE
         CASE A->BBUYCODE = '  96' .AND. (PROD_DESC = '65521' .OR. PROD_DESC = '65543')
            MVAL1 = QTY * SEL_PRICE
         CASE (A->BBUYCODE = ' 231' .OR. A->BBUYCODE = '  84' .OR. A->BBUYCODE = ' 189') .AND. (PROD_DESC = '51160' .OR. PROD_DESC = '51221')
            **MVAL1 = (QTY*32) * SEL_PRICE
            MVAL1 = QTY * SEL_PRICE
         OTHERWISE
            MVAL1 = LBS * SEL_PRICE
         ENDCASE
         
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
         MSELL = MVAL1
      ENDIF
      ?? SPACE(2) + TRANSFORM(MSELL, '@Z 9999999.99')
      
      ?
      MTOTAL = MTOTAL + MSELL
   ENDIF
   MLINE = MLINE + 2
   IF MLINE > 50
      MHEAD_PRT = .T.
   ENDIF
   IF SHORT_FLG <> ' ' .AND. MCUST_SW .AND. .NOT. MCOPY_ONLY
      ? SPACE(16) + 'SHORT WEIGHT' + SPACE(38) + TRANSFORM(-1 * SHRT_LBS, '999,999.99')
      ?? SPACE(2) + TRANSFORM(SEL_PRICE, '99.9999')
      ** MSELL = ROUND((SHRT_LBS * -1) * SEL_PRICE,2)
      MVAL1 = (SHRT_LBS * -1) * SEL_PRICE
      
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
      
      MSELL = MVAL1      
      
      ?? SPACE(2) + TRANSFORM(MSELL, '9999999.99')
      ?
      MTOTAL = MTOTAL + MSELL
      MLINE = MLINE + 2
      IF MLINE > 50
         MHEAD_PRT = .T.
      ENDIF
   ENDIF
   SKIP
ENDDO
*** NOW CHECK ALSO FOR THE ADJUSTMENTS
SELECT A
STORE CUS_AMT1  TO MCUS_AMT1
STORE CUS_REAS1 TO MCUS_REAS1
STORE CUS_AMT2  TO MCUS_AMT2
STORE CUS_REAS2 TO MCUS_REAS2
STORE CUS_PALL  TO MCUS_PALL
IF MCUS_REAS1 = SPACE(15)
   MCUS_REAS1 = "ADDN'L CHARGE"
ENDIF
IF MCUS_REAS2 = SPACE(15)
   MCUS_REAS2 = "ADDN'L CHARGE"
ENDIF
STORE RECNO() TO MRECNO

I = 1
DO WHILE I<= 6
   STORE STR(I,1) TO MI
   IF MPO_SHIP&MI = SPACE(4)
      I = I + 1
      LOOP
   ENDIF
   SEEK MSALESMAN + MPO_SHIP&MI + MPO_SUFF&MI
   MCUS_AMT1 = MCUS_AMT1 + CUS_AMT1
   MCUS_AMT2 = MCUS_AMT2 + CUS_AMT2
   MCUS_PALL = MCUS_PALL + CUS_PALL
   I = I + 1
ENDDO

GOTO MRECNO
IF MCUS_AMT1 <> 0
   IF MCUS_REAS1 <> '2% NET 10' .AND. MCUS_REAS1 <> 'PROGRAM-'
      IF MHEAD_PRT
         DO IHD_PRT
      ENDIF
      SELECT A
      IF MCK_BROK
         MCK_BROK = .F.
         IF BROKERAGE = 'X'
            ? SPACE(15) + 'BROKERAGE FEE'
            ?
            MLINE = MLINE + 2
         ENDIF
      ENDIF
      
      ? SPACE(16) + MCUS_REAS1 + SPACE(56) + TRANSFORM(MCUS_AMT1, '@Z 9999999.99')
      ?
      MTOTAL = MTOTAL + MCUS_AMT1
      MLINE = MLINE + 2
   ENDIF
ENDIF
IF MCUS_AMT2 <> 0
   IF MCUS_REAS2 <> '2% NET 10' .AND. MCUS_REAS2 <> 'PROGRAM-'
      IF MHEAD_PRT
         DO IHD_PRT
      ENDIF
      MPRT_ONE = .T.
      SELECT A
      IF MCK_BROK
         MCK_BROK = .F.
         IF BROKERAGE = 'X'
            ? SPACE(15) + 'BROKERAGE FEE'
            ?
            MLINE = MLINE + 2
         ENDIF
      ENDIF
      
      ? SPACE(16) + MCUS_REAS2 + SPACE(56) + TRANSFORM(MCUS_AMT2, '@Z 9999999.99')
      ?                                                 
      MLINE = MLINE + 2
      MTOTAL = MTOTAL + MCUS_AMT2
   ENDIF
ENDIF

IF MCUS_PALL <> 0
   IF MHEAD_PRT
      DO IHD_PRT
   ENDIF
   MPRT_ONE = .T.
   SELECT A
   IF MCK_BROK
      MCK_BROK = .F.
      IF BROKERAGE = 'X'
         ? SPACE(15) + 'BROKERAGE FEE'
         ?
         MLINE = MLINE + 2
      ENDIF
   ENDIF
   
   ? SPACE(16) + 'PALLETS/FREIGHT' + SPACE(57) + TRANSFORM(MCUS_PALL, '@Z 999999.99')
   ?
   MLINE = MLINE + 2
   MTOTAL = MTOTAL + MCUS_PALL
ENDIF
**** IF NOT PRINTINT ONE - JUST RETURN
IF .NOT. MPRT_ONE
   SET PROC TO
   RETURN
ENDIF

DO WHILE MLINE <=45
   ?
   MLINE = MLINE + 1
ENDDO
?
?
?
SELECT A
IF MTERM_DAYS = 0
   MDATE = DEL_REQD + 15
ELSE
   MDATE = DEL_REQD + MTERM_DAYS
ENDIF

*** TURN ON DOUBLE WIDE, DOUBLE HIGH
?? CHR(27) + 'w' + '1'
?? CHR(14)        

? SPACE(67) + 'DATE DUE: ' + DTOC(MDATE)
?
?
IF MCOMPANY = 'AMERICHICKEN, INC'
   ? SPACE(16)
   *** NOW GET ALL THE SHIPPED WITH POS
   MSPACE = 0
   I = 1
   DO WHILE I<= 6
      STORE STR(I,1) TO MI
      IF MPO_SHIP&MI = SPACE(4)
         I = I + 1
         LOOP
      ELSE
         ?? MPO_SHIP&MI
         IF MPO_SUFF&MI <> ' '
            ?? '-' + MPO_SUFF&MI
            MSPACE = MSPACE + 2
         ENDIF
         ?? ', '
         MSPACE = MSPACE + 6
      ENDIF
      I = I + 1
   ENDDO
   MSPACE = 68-15-MSPACE
   ?? SPACE(MSPACE)
ELSE
   ? SPACE(84-15)
ENDIF
?? 'AMOUNT DUE:     '
?? TRANSFORM(MTOTAL, '@Z 9,999,999.99')
**** TURN OFF DOUBLE HIGH
?? CHR(27) + 'w' + '0'
?
IF MCOMPANY = 'AMERICHICKEN, INC'
   MPRT_NBR = STR(MINV_NBR,5)    
   ?
   ?
   ?
   ?? space(7)
   *** TURN ON DOUBLE WIDE, DOUBLE HIGH
   ?? CHR(27) + 'w' + '1'
   ?? CHR(14)        
   ?? 'INVOICE NBR: ' + LTRIM(MPRT_NBR)
   
   **** TURN OFF DOUBLE HIGH
   ?? CHR(27) + 'w' + '0'
ELSE
   ?
   ?? CHR(27) + 'G'
   ?? SPACE(5) + REPLICATE('*',36)
   ?
   ?           
   *** TURN ON DOUBLE HIGH
   ?? CHR(27) + 'w' + '1'
   *** NOW DO THE PRINTING
   **?? SPACE(12) 
   ?? SPACE(5) 
   ?? CHR(27) + '-' + '1'
   ?? 'REMIT TO:'
   
   ?? CHR(27) + '-' + '0'
   
   DO CASE
   CASE MCOMPANY = 'DIVISION 15'
      ?? '  6820 WILSON AVE  2ND FLOOR'
   OTHERWISE
      ?? SPACE(4) + '1330 COPPER DRIVE'
   ENDCASE
   
   **** TURN OFF DOUBLE HIGH 
   ?? CHR(27) + 'w' + '0'
   ?
   *** TURN ON DOUBLE HIGH
   ?? CHR(27) + 'w' + '1'
   ?
   
   DO CASE
   CASE MCOMPANY = 'DIVISION 15'
      ?? SPACE(5) + '           LOS ANGELES, CA  90001   '
   OTHERWISE
      ?? SPACE(5) + '      CAPE GIRARDEAU,  MO 63701'
   ENDCASE
                                                         
   **** TURN OFF DOUBLE HIGH 
   ?? CHR(27) + 'w' + '0'
   ?           
   ?? SPACE(5) + REPLICATE('*',36)
   ?? CHR(27) + 'H'
ENDIF

SET PROC TO
RETURN

PROCEDURE IHD_PRT
MHEAD_PRT = .F.
IF MFIRST_TM 
   MFIRST_TM = .F.
ELSE
   EJECT
ENDIF
SELECT A
MPRT_NBR = STR(MINV_NBR,5)    
IF SUBSTR(MPRT_NBR,1,1) = ' '
   MPRT_NBR = SUBSTR(MPRT_NBR,2)
ENDIF
IF MCOMPANY = 'AMERICHICKEN, INC'
   ?
   ?
   ?
   ?
   ? SPACE(41) + 'INVOICE NBR: ' + LTRIM(MPRT_NBR)
   ?
   IF MPRT_MSG = 'YES'
      ?  space(41) + ' COPY OF INVOICE '
   ELSE
      ?
   ENDIF
   ?
   ? SPACE(10) + 'SOLD TO: ' + SPACE(23) + SPACE(22) + 'SHIP TO:'
ELSE
   ?
   ?? space(77) + ' INVOICE NUMBER'
   ?
   ? SPACE(15) 
   ?? SPACE(61)
   
   **** SET DOUBLE HIGH, DOUBLE WIDE
   ?? CHR(14)        
   ?? CHR(27) + 'w' + '1'
   IF SALESMAN = SPACE(2)
      ?? SPACE(3) + MPRT_NBR
   ELSE
      IF VAL(SALESMAN) >= 25 .AND. VAL(SALESMAN) <= 29
         ?? SPACE(3) 
      ELSE
         ?? SALESMAN + '-' 
      ENDIF
      ?? MPRT_NBR    
   ENDIF
   **** TURN OFF DOUBLE HIGH 
   ?? CHR(27) + 'w' + '0'
   IF MPRT_MSG = 'YES'
      ?  space(75) + ' COPY OF INVOICE '
   ELSE
      ?
   ENDIF
   ?
   ?
   ?
   ?
   ? SPACE(10) + 'SOLD TO: ' + SPACE(23) + SPACE(22) + 'SHIP TO:'
ENDIF
IF MREG_NAME <> SPACE(32)
   ? SPACE(10) + MREG_NAME + SPACE(22) + SUBSTR(MSHP_NAME,1,31)
   ? SPACE(10) +'DBA: ' + MBIL_NAME + SPACE(17) + MSHP_STRT
   ? SPACE(10) + MBIL_ADR1 + SPACE(17) + TRIM(MSHP_CITY) + ', ' + MSHP_STATE + '  ' + MSHP_ZIP 
   ? SPACE(10) + MBIL_ADR2 + space(17)
   ? SPACE(10) + MBIL_ADR3
   ?
ELSE
   ? SPACE(10) + MBIL_NAME + SPACE(22) + SUBSTR(MSHP_NAME,1,31) 
   ? SPACE(10) + MBIL_ADR1 + SPACE(17) + MSHP_STRT
   ? SPACE(10) + MBIL_ADR2 + space(17) + TRIM(MSHP_CITY) + ', ' + MSHP_STATE + '  ' + MSHP_ZIP
   ? SPACE(10) + MBIL_ADR3
   ?
   ?
ENDIF
IF MSAL_CODE2 <> '  '
   **?? 'IntrCo ' + MSAL_CODE2
ENDIF
? SPACE(3) + 'SHIP DATE' + SPACE(1) + SPACE(4) + 'BUYERS PO' + SPACE(6)
?? 'AMERI PO' + SPACE(4) + 'BROKER' + SPACE(19) + SPACE(3) + 'HOW SHIPPED'
? space(3) + DTOC(SHIP_DATE) + space(3) + BUYER_PO + space(1) 

IF SALESMAN = SPACE(2)
   ?? SPACE(3) + PO_NBR
ELSE
   IF VAL(SALESMAN) >= 25 .AND. VAL(SALESMAN) <= 29
      ?? SPACE(3) 
   ELSE
      ?? SALESMAN + '-' 
   ENDIF
   ?? PO_NBR      
ENDIF

IF PO_SUFFIX <> ' '
   ?? '-' + PO_SUFFIX
ELSE
   ?? '  '
ENDIF
?? SPACE(3)
?? SUBSTR(D->COM_NAME,1,25)
?? SPACE(3) + SUBSTR(MFRT_NAME,1,22)
?
?
?
MLINE = 18
MPRT_ONE = .T.
RETURN
*Formatted by: ToolBox Ver. 1.2  on 8/24/7 at 2:39 PM.
