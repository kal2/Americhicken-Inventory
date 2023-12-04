************************
* Program.: MARG_RPT.PRG
* Author..: GRACE KELLER
* Date....: 10/01/97
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXBASE  
* Notes...: MARGIN REPORT FOR DATABASE 15           
*
CLEAR
@ 00,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@ 01,00 SAY MPROGRAM + ' - PRINT MARGIN REPORT'                 
@ 2,0 to 24,79
SET PROC TO MARG_RPT

MSEL_PREFX = '  '
MSEL_PCODE = SPACE(10)
MSEL_SUP = ' '
STORE '  ' TO MSEL_MO
STORE SPACE(4) TO MSEL_YR
MACTION = 2
DO WHILE MACTION = 2
   @ 10,3 SAY 'Enter Ending Month/Year:   /  '         
   @ 10,28 get MSEL_MO PICTURE '##'
   @ 10,31 GET MSEL_YR PICTURE '####'
   @ 13,3 SAY 'Select Specific Vendor   (Y/N): ' get msel_sup picture '@!' valid(MSEL_SUP = 'Y' .OR. MSEL_SUP = 'N' .OR. MSEL_SUP = ' ')
   
   STORE 1 TO MACTION
   @ 24,0 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Continue    2. Edit    3. Cancel Report'          
   READ
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
   READ
ENDDO

IF MACTION = 3                         
   RETURN
ENDIF

IF MSEL_SUP = 'Y'
   SAVE SCREEN TO MGRACE
   MNAME_FD = .F.
   DO RSUPSEL1
   RESTORE SCREEN FROM MGRACE
   IF .NOT. MNAME_FD
      @ 24,0 CLEAR
      MWAIT = ' '
      @ 24,1 SAY 'NO SPECIFIC VENDOR SELECTED - PRESS ENTER TO RETURN TO MENU ' GET MWAIT
      @ 24,0 CLEAR
      RETURN
   ELSE
      SELECT A
      MOPT_SUP  = RSUPCODE
      USE   
   ENDIF
ELSE
   MOPT_SUP  = SPACE(4)
ENDIF

MPRT_ACT = 'C'
DO PRT_SET
IF MPRT_ACT <> 'C'
   RETURN
ENDIF
MMO = VAL(MSEL_MO)
MMO = MMO - 2
DO CASE
CASE MMO = -1
   MSTART_MO = '11'
   MSTART_YR = VAL(MSEL_YR) -1 
   MSTART_YR = STR(MSTART_YR,4)
   M1_MO = '11'
   M2_MO = '12'
   M3_MO = '01'
CASE MMO = 0
   MSTART_MO = '12'
   MSTART_YR = VAL(MSEL_YR) - 1
   MSTART_YR = STR(MSTART_YR,4)
   M1_MO = '12'
   M2_MO = '01'
   M3_MO = '02'
   
OTHERWISE
   MSTART_MO = SUBSTR(STR(MMO+100,3),2)
   MSTART_YR = MSEL_YR
   M1_MO = MSTART_MO
   M2_MO = VAL(MSTART_MO) + 1
   M2_MO = SUBSTR(STR(M2_MO+100,3),2)
   M3_MO = VAL(MSTART_MO) + 2
   M3_MO = SUBSTR(STR(M3_MO+100,3),2)
ENDCASE

MPAGE_LEN = 56
MPAGE_NO = 0
MLINE = 99
@ 21,16 SAY 'PROCESSING/PRINTING......'

SELECT B
MFILE = 'INVNTMP'
*** INVNTMP6
MFILENM = MFILE + '6'
USE &MFILENM EXCLUSIVE               
DELETE ALL
PACK
INDEX ON NAME + CITY + SUP_PREFX + SUP_PCODE TO &MFILENM
DO FOX_USE WITH "&MFILENM INDEX &MFILENM", .F.
DO FILELOCK

SELECT D
DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP, PO_SUP ", .F.

SELECT E
DO FOX_USE WITH "PO_DTL INDEX PO_DTL ", .F.

SELECT C
**DO FOX_USE WITH "REM_SUP INDEX RSUPCODE", .F.
DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.

SELECT A
DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT", .F.
*** HAL'S PLACE
**MFREEZ_LOC = 'GLACIER - INVENTORY' + SPACE(13)
*** MW
MFREEZ_LOC = 'INVENTORY' + SPACE(23)

SELECT D
SEEK MSTART_YR + MSTART_MO

MEND_DATE = CTOD(MSEL_MO + '/28/' + MSEL_YR)
DO WHILE SUBSTR(DTOC(MEND_DATE),1,2) = MSEL_MO
   MEND_DATE = MEND_DATE + 1
ENDDO
MEND_DATE = MEND_DATE - 1

*** PICK UP ALL THE ITEMS COMING FROM A SUPPLIER - EITHER GOING INTO
*** INVENTORY OR AS A DIRECT PURCHASE/SALE 
DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MEND_DATE
   IF PO_SUFFIX = '8' .OR. PO_SUFFIX = '9'
      SKIP
      LOOP
   ENDIF
   
   IF MOPT_SUP <> SPACE(4)
      IF RSUPCODE <> MOPT_SUP
         SKIP
         LOOP
      ENDIF
   ENDIF
   
   IF RSUPCODE = 'NONE' .OR. RSUPCODE = 'INVN'
      SKIP
      LOOP
   ENDIF
   
   MRSUPCODE = RSUPCODE
   *** SUPPLIER FILE
   SELECT C
   SEEK D->RSUPCODE
   IF EOF()
      MNAME = 'VENDOR NOT ON FILE'+SPACE(14)
      MCITY = SPACE(20)
      MSTATE = SPACE(2)
      MZIP = SPACE(5)
      MAREA_CODE = SPACE(3)
      MPHONE = SPACE(7)
      MNOTE = SPACE(60)
   ELSE
      MNAME = NAME
      MCITY = CITY
      MSTATE = STATE
      MZIP = ZIP
      MAREA_CODE = AREA_CODE
      MPHONE = PHONE    
      MNOTE = NOTE      
   ENDIF
   
   *** PO_DTL
   SELECT E
   SEEK D->SALESMAN + D->PO_NBR + D->PO_SUFFIX
   IF EOF()
      SELECT D
      SKIP
      LOOP
   ENDIF
   
   DO WHILE .NOT. EOF() .AND. SALESMAN = D->SALESMAN .AND. PO_NBR = D->PO_NBR .AND. PO_SUFFIX = D->PO_SUFFIX
      IF QTY = 0
         SKIP 
         LOOP
      ENDIF
      ** TEMP GATHERING FILE
      SELECT B
      SEEK MNAME + MCITY + E->SUP_PREFX + E->SUP_PCODE
      IF EOF()
         APPEND BLANK
         REPLACE NAME      WITH MNAME
         REPLACE CITY      WITH MCITY
         REPLACE STATE     WITH MSTATE
         REPLACE ZIP       WITH MZIP
         REPLACE AREA_CODE WITH MAREA_CODE
         REPLACE PHONE     WITH MPHONE
         REPLACE NOTE      WITH MNOTE
         REPLACE SUP_PREFX WITH E->SUP_PREFX
         REPLACE SUP_PCODE WITH E->SUP_PCODE
         REPLACE PACKED    WITH E->PACKED
      ENDIF
      
      SELECT E
      STORE RECNO() TO MRECNO
      
      *** NOW GET THE SALE PART  
      
      DO CASE
         *** DIRECT SALE 
      CASE E->LOT_NBR = SPACE(10)
         SELECT B
         *** THIS IS THE PURCHASE PART
         DO CASE     
         CASE SUBSTR(DTOC(D->SHIP_DATE),1,2) = M1_MO
            REPLACE P1_AMT WITH P1_AMT + E->TOT_PURCH
            REPLACE P1_CS  WITH P1_CS  + E->QTY
            IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
               REPLACE P1_LBS WITH P1_LBS + (E->BOX_SZ * E->LBS) 
            ELSE
               REPLACE P1_LBS WITH P1_LBS + E->LBS
            ENDIF
            
         CASE SUBSTR(DTOC(D->SHIP_DATE),1,2) = M2_MO
            REPLACE P2_AMT WITH P2_AMT + E->TOT_PURCH
            REPLACE P2_CS  WITH P2_CS  + E->QTY
            IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
               REPLACE P2_LBS WITH P2_LBS + (E->BOX_SZ * E->LBS) 
            ELSE
               REPLACE P2_LBS WITH P2_LBS + E->LBS
            ENDIF
            
         OTHERWISE
            REPLACE P3_AMT WITH P3_AMT + E->TOT_PURCH
            REPLACE P3_CS  WITH P3_CS  + E->QTY
            IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
               REPLACE P3_LBS WITH P3_LBS + (E->BOX_SZ * E->LBS) 
            ELSE
               REPLACE P3_LBS WITH P3_LBS + E->LBS
            ENDIF
         ENDCASE   
         
         *** THIS IS THE SALE PART
         DO CASE
         CASE SUBSTR(DTOC(D->SHIP_DATE),1,2) = M1_MO
            REPLACE S1_AMT WITH S1_AMT + E->TOT_SELL 
            REPLACE S1_CS  WITH S1_CS  + E->QTY
            IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
               REPLACE S1_LBS WITH S1_LBS + (E->BOX_SZ * E->LBS) 
            ELSE
               REPLACE S1_LBS WITH S1_LBS + E->LBS
            ENDIF
            
         CASE SUBSTR(DTOC(D->SHIP_DATE),1,2) = M2_MO
            REPLACE S2_AMT WITH S2_AMT + E->TOT_SELL 
            REPLACE S2_CS  WITH S2_CS  + E->QTY
            IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
               REPLACE S2_LBS WITH S2_LBS + (E->BOX_SZ * E->LBS) 
            ELSE
               REPLACE S2_LBS WITH S2_LBS + E->LBS
            ENDIF
            
         OTHERWISE
            REPLACE S3_AMT WITH S3_AMT + E->TOT_SELL  
            REPLACE S3_CS  WITH S3_CS  + E->QTY
            IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
               REPLACE S3_LBS WITH S3_LBS + (E->BOX_SZ * E->LBS) 
            ELSE
               REPLACE S3_LBS WITH S3_LBS + E->LBS
            ENDIF
         ENDCASE   
         
      OTHERWISE
         *** HALS OFFICE
         ***STORE LOT TO MLOT_NBR
         *** MW OFFICE
         
         STORE LOT_NBR TO MLOT_NBR
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR    TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         STORE ITEM_NBR   TO MITEM_NBR
         
         *** NOW FIND THE SALES FOR THIS LOT
         SELECT A
         SEEK MFREEZ_LOC + MLOT_NBR
         *** HALS OFFICE
         **DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT = MLOT_NBR
         *** MW OFFICE
         DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT_NBR
            *IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. ITEM_NBR = MITEM_NBR
            *   SKIP 
            *   LOOP
            *ENDIF
            IF ACTIVITY <> 'OUT'
               SKIP
               LOOP
            ENDIF
            IF PO_SUFFIX = '8' .OR. PO_SUFFIX = '9'
               SKIP
               LOOP
            ENDIF
            *** NOW THIS IS A SALE
            
            SELECT E
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX + A->ITEM_NBR
            IF .NOT. EOF()
               
               SELECT B
               *** THIS IS THE PURCHASE PART
               DO CASE     
               CASE SUBSTR(DTOC(D->SHIP_DATE),1,2) = M1_MO
                  REPLACE P1_AMT WITH P1_AMT + E->TOT_PURCH
                  REPLACE P1_CS  WITH P1_CS  + E->QTY
                  IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
                     REPLACE P1_LBS WITH P1_LBS + (E->BOX_SZ * E->LBS) 
                  ELSE
                     REPLACE P1_LBS WITH P1_LBS + E->LBS
                  ENDIF
                  
               CASE SUBSTR(DTOC(D->SHIP_DATE),1,2) = M2_MO
                  REPLACE P2_AMT WITH P2_AMT + E->TOT_PURCH
                  REPLACE P2_CS  WITH P2_CS  + E->QTY
                  IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
                     REPLACE P2_LBS WITH P2_LBS + (E->BOX_SZ * E->LBS) 
                  ELSE
                     REPLACE P2_LBS WITH P2_LBS + E->LBS
                  ENDIF
                  
               OTHERWISE
                  REPLACE P3_AMT WITH P3_AMT + E->TOT_PURCH
                  REPLACE P3_CS  WITH P3_CS  + E->QTY
                  IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
                     REPLACE P3_LBS WITH P3_LBS + (E->BOX_SZ * E->LBS) 
                  ELSE
                     REPLACE P3_LBS WITH P3_LBS + E->LBS
                  ENDIF
               ENDCASE   
               
               *** THIS IS THE SALE PART
               DO CASE     
               CASE SUBSTR(DTOC(A->ACT_DATE),1,2) = M1_MO
                  REPLACE S1_AMT WITH S1_AMT + E->TOT_SELL 
                  REPLACE S1_CS  WITH S1_CS  + E->QTY
                  IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
                     REPLACE S1_LBS WITH S1_LBS + (E->BOX_SZ * E->LBS) 
                     ** ESTIMATED INVENTORY COSTS
                     *** = .0085+ .0085 + .0085 + .0085 = .034 /LB
                     REPLACE S1_STOR WITH S1_STOR + ROUND(.034 * (E->BOX_SZ * E->LBS),2)
                  ELSE
                     REPLACE S1_LBS WITH S1_LBS + E->LBS
                     REPLACE S1_STOR WITH S1_STOR + ROUND(.034 * E->LBS,2)
                  ENDIF
                  
               CASE SUBSTR(DTOC(A->ACT_DATE),1,2) = M2_MO
                  REPLACE S2_AMT WITH S2_AMT + E->TOT_SELL 
                  REPLACE S2_CS  WITH S2_CS  + E->QTY
                  IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
                     REPLACE S2_LBS WITH S2_LBS + (E->BOX_SZ * E->LBS) 
                     ** ESTIMATED INVENTORY COSTS
                     *** = .0085+ .0085 + .0085 + .0085 = .034 /LB
                     REPLACE S2_STOR WITH S2_STOR + ROUND(.034 * (E->BOX_SZ * E->LBS),2)
                  ELSE
                     REPLACE S2_LBS WITH S2_LBS + E->LBS
                     REPLACE S2_STOR WITH S2_STOR + ROUND(.034 * E->LBS,2)
                  ENDIF
                  
               OTHERWISE
                  REPLACE S3_AMT WITH S3_AMT + E->TOT_SELL  
                  REPLACE S3_CS  WITH S3_CS  + E->QTY
                  IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
                     REPLACE S3_LBS WITH S3_LBS + (E->BOX_SZ * E->LBS) 
                     ** ESTIMATED INVENTORY COSTS
                     *** = .0085+ .0085 + .0085 + .0085 = .034 /LB
                     REPLACE S3_STOR WITH S3_STOR + ROUND(.034 * (E->BOX_SZ * E->LBS),2)
                  ELSE
                     REPLACE S3_LBS WITH S3_LBS + E->LBS
                     REPLACE S3_STOR WITH S3_STOR + ROUND(.034 * E->LBS,2)
                  ENDIF
               ENDCASE   
               
            ENDIF
            SELECT A
            SKIP
         ENDDO
      ENDCASE 
      
      SELECT E
      GOTO MRECNO
      SKIP
   ENDDO
   SELECT D 
   SKIP
ENDDO

*** CALCULATE THE PERIOD SALES        
MDO_THIS = .F.
IF MDO_THIS
   SELECT A
   DO FOX_USE WITH "INVEN INDEX INVNLOT", .F.
   MFREEZ_LOC = 'GLACIER - INVENTORY' + SPACE(13)
   
   SELECT D
   
   SEEK MSTART_YR + MSTART_MO
   DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MEND_DATE
      
      IF BBUYCODE = 'INVN' .OR. BBUYCODE = 'NONE'
         SKIP
         LOOP
      ENDIF
      
      *** DO NOT PICK UP RELOT ORDERS AS SALES
      IF PO_SUFFIX = '8' .OR. PO_SUFFIX = '9'
         SKIP
         LOOP
      ENDIF
      
      SELECT E
      SEEK D->SALESMAN + D->PO_NBR + D->PO_SUFFIX
      DO WHILE .NOT. EOF() .AND. SALESMAN = D->SALESMAN .AND. PO_NBR = D->PO_NBR .AND. PO_SUFFIX = D->PO_SUFFIX
         
         *** FORMAT THE SUPPLIER NAME,CITY,STATE,ZIP
         DO CASE
         CASE D->RSUPCODE = 'INVN'
            **** CAME OUT OF INVENTORY - GO FIND ORIGINAL SUPPLIER
            SELECT A
            SEEK MFREEZ_LOC + E->LOT     
            IF EOF()
               IF MOPT_SUP <> SPACE(4)
                  SELECT E
                  SKIP
                  LOOP
               ENDIF
               MNAME = 'VENDOR NOT ON FILE'+SPACE(14)
               MCITY = SPACE(20)
               MSTATE = SPACE(2)
               MZIP = SPACE(5)
               MRSUPCODE = SPACE(4)
               MAREA_CODE = SPACE(3)
               MPHONE = SPACE(7)
               MNOTE = SPACE(60)
            ELSE
               IF MOPT_SUP <> SPACE(4)
                  IF RSUPCODE <> MOPT_SUP
                     SELECT E
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               SELECT C
               SEEK A->RSUPCODE
               IF EOF()
                  MNAME = 'VENDOR NOT ON FILE'+SPACE(14)
                  MCITY = SPACE(20)
                  MSTATE = SPACE(2)
                  MZIP = SPACE(5)
                  MRSUPCODE = SPACE(4)
                  MAREA_CODE = SPACE(3)
                  MPHONE = SPACE(7)
                  MNOTE = SPACE(60)
               ELSE
                  MNAME = NAME
                  MCITY = CITY
                  MSTATE = STATE
                  MZIP = ZIP
                  MRSUPCODE = RSUPCODE
                  MAREA_CODE = AREA_CODE
                  MPHONE = PHONE    
                  MNOTE = NOTE       
               ENDIF
            ENDIF
            
         OTHERWISE
            *** DIRECT SALE       
            IF MOPT_SUP <> SPACE(4)
               IF D->RSUPCODE <> MOPT_SUP
                  SELECT E
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT C
            SEEK D->RSUPCODE
            IF EOF()
               MNAME = 'VENDOR NOT ON FILE'+SPACE(14)
               MCITY = SPACE(20)
               MSTATE = SPACE(2)
               MZIP = SPACE(5)
               MRSUPCODE = SPACE(4)
               MAREA_CODE = SPACE(3)
               MPHONE = SPACE(7)
               MNOTE = SPACE(60)
            ELSE
               MNAME = NAME
               MCITY = CITY
               MSTATE = STATE
               MZIP = ZIP
               MRSUPCODE = RSUPCODE
               MAREA_CODE = AREA_CODE 
               MPHONE = PHONE   
               MNOTE = NOTE      
            ENDIF
         ENDCASE
         
         SELECT B
         SEEK MNAME + MCITY + E->SUP_PREFX + E->SUP_PCODE
         IF EOF()
            APPEND BLANK
            REPLACE NAME      WITH MNAME
            REPLACE CITY      WITH MCITY
            REPLACE STATE     WITH MSTATE
            REPLACE ZIP       WITH MZIP
            REPLACE AREA_CODE WITH MAREA_CODE
            REPLACE PHONE     WITH MPHONE
            REPLACE NOTE      WITH MNOTE
            REPLACE SUP_PREFX WITH E->SUP_PREFX
            REPLACE SUP_PCODE WITH E->SUP_PCODE
            REPLACE PACKED    WITH E->PACKED
         ENDIF
         
         DO CASE     
         CASE SUBSTR(DTOC(D->SHIP_DATE),1,2) = M1_MO
            REPLACE S1_AMT WITH S1_AMT + E->TOT_SELL 
            REPLACE S1_CS  WITH S1_CS  + E->QTY
            IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
               REPLACE S1_LBS WITH S1_LBS + (E->BOX_SZ * E->LBS) 
            ELSE
               REPLACE S1_LBS WITH S1_LBS + E->LBS
            ENDIF
            
         CASE SUBSTR(DTOC(D->SHIP_DATE),1,2) = M2_MO
            REPLACE S2_AMT WITH S2_AMT + E->TOT_SELL 
            REPLACE S2_CS  WITH S2_CS  + E->QTY
            IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
               REPLACE S2_LBS WITH S2_LBS + (E->BOX_SZ * E->LBS) 
            ELSE
               REPLACE S2_LBS WITH S2_LBS + E->LBS
            ENDIF
            
         OTHERWISE
            REPLACE S3_AMT WITH S3_AMT + E->TOT_SELL  
            REPLACE S3_CS  WITH S3_CS  + E->QTY
            IF SUBSTR(E->PACKED,1,1) = 'B' .OR. SUBSTR(E->PACKED,1,1) = 'H'
               REPLACE S3_LBS WITH S3_LBS + (E->BOX_SZ * E->LBS) 
            ELSE
               REPLACE S3_LBS WITH S3_LBS + E->LBS
            ENDIF
         ENDCASE   
         SELECT E
         SKIP
      ENDDO
      SELECT D
      SKIP
   ENDDO
ENDIF
**** DONE WITH THE EXTRACT  - NOW FORMAT THE REPORT 

SET CONSOLE OFF
IF FILE("C:\COMPINFO\PRINTERS.DBF")
   SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
ELSE
   SET PRINT TO LPT3
ENDIF
SET DEVICE TO PRINT
SET PRINT ON

*** PRINT IN 12 CPI
?? chr(27) + '&k4S'

*** LETTER GOTHIC AND BOLDED PRINT
?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'

*** LANDSCAPE MODE
?? CHR(27) + '&l1O'

*** LEGAL SIZE PAPER
?? CHR(27) + '&l3A'

SELECT A
USE
SELECT D
USE
SELECT E
USE

MLINE = 99
MPAGE_LEN = 44
MPAGE_NO = 0

SELECT A
**DO FOX_USE WITH "SUP_PROD INDEX SUP_PROD", .F.
DO FOX_USE WITH "&MDBFLOC.SUP_PROD INDEX &MDBFLOC.SUP_PROD", .F.

SELECT B
GOTO TOP
STORE 0 TO GP1_AMT, GP2_AMT, GP3_AMT, GS1_AMT, GS2_AMT, GS3_AMT
STORE 0 TO GC1_AMT, GC2_AMT, GC3_AMT
DO WHILE .NOT. EOF()
   MNAME  = NAME
   MCITY  = CITY
   MSTATE = STATE
   MZIP   = ZIP
   MAREA_CODE = AREA_CODE
   MPHONE     = PHONE
   MNOTE      = NOTE
   MVEND_LEN = LEN(TRIM(MNAME)) + LEN(TRIM(MCITY)) + 16
   IF MLINE > MPAGE_LEN
      DO MARG_HD
   ELSE
      MLINE = MLINE + 1
      @ MLINE,1 SAY TRIM(MNAME) + SPACE(5) + TRIM(MCITY) + ', ' + MSTATE + SPACE(2) + MZIP
      @ MLINE,1 SAY REPLICATE('_',MVEND_LEN)
      MLINE = MLINE + 1
      @ MLINE,1 SAY MAREA_CODE + '-' + SUBSTR(MPHONE,1,3) + '-' + SUBSTR(MPHONE,4) + SPACE(5) + MNOTE
      MLINE = MLINE + 1
   ENDIF
   
   STORE 0 TO TP1_AMT, TP2_AMT, TP3_AMT, TS1_AMT, TS2_AMT, TS3_AMT
   STORE 0 TO TC1_AMT, TC2_AMT, TC3_AMT
   
   DO WHILE .NOT. EOF() .AND. NAME = MNAME .AND. CITY = MCITY
      IF MLINE > MPAGE_LEN
         DO MARG_HD 
      ENDIF
      @ MLINE,1 SAY SUP_PREFX
      @ MLINE,3 SAY SUP_PCODE
      *** FIND THE PRODUCT DESCRIPTION
      SELECT A
      SEEK B->SUP_PREFX+B->SUP_PCODE
      IF EOF()
         @ MLINE,14 SAY 'PRODUCT CODE NOT ON FILE'
      ELSE
         @ MLINE,14 SAY SUBSTR(DESCRIP,1,40)        
      ENDIF
      SELECT B
      @ MLINE,56 SAY P1_AMT PICTURE '9999999'
      @ MLINE,64 SAY S1_AMT PICTURE '9999999'
      @ MLINE,74 SAY P2_AMT PICTURE '9999999'
      @ MLINE,82 SAY S2_AMT PICTURE '9999999'
      @ MLINE,92 SAY P3_AMT PICTURE '9999999'
      @ MLINE,100 SAY S3_AMT PICTURE '9999999'
      @ MLINE,111 SAY P1_AMT + P2_AMT + P3_AMT PICTURE '9999999'
      @ MLINE,119 SAY S1_AMT + S2_AMT + S3_AMT PICTURE '9999999'
      @ MLINE,135 SAY S1_STOR + S2_STOR + S3_STOR PICTURE '999999'
      @ MLINE,148 SAY (S1_AMT + S2_AMT + S3_AMT) - (P1_AMT + P2_AMT + P3_AMT) - (S1_STOR + S2_STOR + S3_STOR) PICTURE '999999'
      TP1_AMT = TP1_AMT + P1_AMT
      TP2_AMT = TP2_AMT + P2_AMT
      TP3_AMT = TP3_AMT + P3_AMT
      TS1_AMT = TS1_AMT + S1_AMT
      TS2_AMT = TS2_AMT + S2_AMT
      TS3_AMT = TS3_AMT + S3_AMT
      TC1_AMT = TC1_AMT + S1_STOR
      TC2_AMT = TC2_AMT + S2_STOR
      TC3_AMT = TC3_AMT + S3_STOR
      MLINE = MLINE + 2
      SKIP
   ENDDO
   *** SHOW TOTALS FOR THIS SUPPLIER
   @ MLINE,1 SAY 'SUPPLIER TOTALS: ' 
   @ MLINE,56 SAY TP1_AMT PICTURE '9999999'
   @ MLINE,64 SAY TS1_AMT PICTURE '9999999'
   @ MLINE,74 SAY TP2_AMT PICTURE '9999999'
   @ MLINE,82 SAY TS2_AMT PICTURE '9999999'
   @ MLINE,92 SAY TP3_AMT PICTURE '9999999'
   @ MLINE,100 SAY TS3_AMT PICTURE '9999999'
   @ MLINE,111 SAY TP1_AMT + TP2_AMT + TP3_AMT PICTURE '9999999'
   @ MLINE,119 SAY TS1_AMT + TS2_AMT + TS3_AMT PICTURE '9999999'
   @ MLINE,135 SAY TC1_AMT + TC2_AMT + TC3_AMT PICTURE '999999'
   @ MLINE,148 SAY (TS1_AMT + TS2_AMT + TS3_AMT) - (TP1_AMT + TP2_AMT + TP3_AMT)  - (TC1_AMT + TC2_AMT + TC3_AMT) PICTURE '999999'
   MLINE = MLINE + 3
   GP1_AMT = GP1_AMT + TP1_AMT
   GP2_AMT = GP2_AMT + TP2_AMT
   GP3_AMT = GP3_AMT + TP3_AMT
   GS1_AMT = GS1_AMT + TS1_AMT
   GS2_AMT = GS2_AMT + TS2_AMT
   GS3_AMT = GS3_AMT + TS3_AMT
   GC1_AMT = GC1_AMT + TC1_AMT
   GC2_AMT = GC2_AMT + TC2_AMT
   GC3_AMT = GC3_AMT + TC3_AMT
ENDDO
MLINE = MLINE + 4
*** SHOW GRAND TOTALS             
@ MLINE,1 SAY 'GRAND TOTALS: ' 
@ MLINE,56 SAY GP1_AMT PICTURE '9999999'
@ MLINE,64 SAY GS1_AMT PICTURE '9999999'
@ MLINE,74 SAY GP2_AMT PICTURE '9999999'
@ MLINE,82 SAY GS2_AMT PICTURE '9999999'
@ MLINE,92 SAY GP3_AMT PICTURE '9999999'
@ MLINE,100 SAY GS3_AMT PICTURE '9999999'
@ MLINE,111 SAY GP1_AMT + GP2_AMT + GP3_AMT PICTURE '9999999'
@ MLINE,119 SAY GS1_AMT + GS2_AMT + GS3_AMT PICTURE '9999999'
@ MLINE,135 SAY GC1_AMT + GC2_AMT + GC3_AMT PICTURE '999999'
@ MLINE,148 SAY (GS1_AMT + GS2_AMT + GS3_AMT) - (GP1_AMT + GP2_AMT + GP3_AMT)  - (GC1_AMT + GC2_AMT + GC3_AMT) PICTURE '999999'

IF MLINE = 99          
   @ 4,1 SAY 'NO DATA SELECTED FOR REPORT'                            
ENDIF
EJECT 
SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON
IF MPRINTER3 <> 'DONOTPRINT'
   RUN &MPRINTIT3
ENDIF
CLOSE DATA
MRPT_SEL   = '  '
RETURN

PROCEDURE MARG_HD
IF MLINE <> 99
   EJECT
ENDIF
MPAGE_NO = MPAGE_NO + 1
@ 1,1 SAY 'PAGE: ' + STR(MPAGE_NO,3)
@ 1,50 SAY '      AMERICHICKEN, INC         ' + SPACE(32) + DTOC(DATE())
MLINE = 2
@ MLINE,50 SAY '  MARGIN REPORT FOR ' + M1_MO + '/' + MSTART_YR + ' THRU ' + M3_MO + '/' + MSEL_YR   
MLINE = MLINE + 1
@ MLINE,58 SAY ' MONTH ' + M1_MO               
@ MLINE,76 SAY ' MONTH ' + M2_MO
@ MLINE,94 SAY ' MONTH ' + M3_MO
@ MLINE,112 SAY 'GRAND TOTALS'
@ MLINE,132 SAY 'ESTIMATED'
MLINE = MLINE + 1
@ MLINE,56 SAY 'PURCH $  SALE $'
@ MLINE,74 SAY 'PURCH $  SALE $'
@ MLINE,92 SAY 'PURCH $  SALE $'
@ MLINE,111 SAY 'PURCH $  SALE $'
@ MLINE,134 SAY 'STORAGE'
@ MLINE,149 SAY 'NET $'

MLINE = MLINE + 1
@ MLINE,1 SAY TRIM(MNAME) + SPACE(5) + TRIM(MCITY) + ', ' + MSTATE + SPACE(2) + MZIP
@ MLINE,1 SAY REPLICATE('_',MVEND_LEN)
MLINE = MLINE + 1
@ MLINE,1 SAY MAREA_CODE + '-' + SUBSTR(MPHONE,1,3) + '-' + SUBSTR(MPHONE,4) + SPACE(5) + MNOTE
MLINE = MLINE + 2
RETURN
*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 11:20 AM.
