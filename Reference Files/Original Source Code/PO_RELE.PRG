*************
* Program.: PO_RELE.PRG
* Author..: Grace Keller
* Date....: 02/13/95
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: RELEASE ORDER FROM HOLD STATUS TO SHIPPED STATUS
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

MMORE = .T.
DO WHILE MMORE
   
   MTITLE = ' - RELEASE ORDER(S) FROM HOLD TO SHIPPED STATUS'
   MACTION = 2
   MTOT_FRT = 0
   MFRT_NAME = SPACE(32)
   STORE SPACE(4) TO MFRT_CODE
   STORE SPACE(28) TO MSTREET
   STORE SPACE(20) TO MCITY
   STORE SPACE(2) TO MSTATE
   STORE SPACE(5) TO MZIP
   STORE SPACE(4) TO MZIP4
   
   I = 1
   DO WHILE I<= 10
      MI = SUBST(STR(I+100,3),2)
      MSALES&MI = SPACE(2)
      MPO&MI = SPACE(4)
      MSUFF&MI = SPACE(1)
      MLBS&MI  = 0
      MPRO_FRT&MI = 0
      MINVN&MI = ' '
      I = I + 1
   ENDDO
   
   DO WHILE MACTION = 2
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - SELECT ORDER(S) TO RELEASE'    
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      @ 5,5 SAY 'Total Freight        Freight Carrier'
      @ 10,8 SAY 'Order(s)'
      @ 10,22 SAY 'Ship Lbs'
      @ 10,36 SAY 'Pro Frt'
      @ 10,45 SAY 'INVN'
      @ 11,6  SAY '1.   -    -'
      @ 12,6  SAY '2.   -    -'
      @ 13,6  SAY '3.   -    -'
      @ 14,6  SAY '4.   -    -'
      @ 15,6  SAY '5.   -    -'
      @ 16,6  SAY '6.   -    -'
      @ 17,6  SAY '7.   -    -'
      @ 18,6  SAY '8.   -    -'
      @ 19,6  SAY '9.   -    -'
      @ 20,5  SAY'10.   -    -'
      @ 6,7   GET MTOT_FRT PICTURE '99,999.99'
      @ 6,26  GET MFRT_NAME PICTURE '@!'
      
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue Release    2. Edit    3. Cancel'
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      
      IF MACTION = 2
         LOOP
      ENDIF
      
      IF MACTION = 3
         MMORE = .F.
         LOOP
      ENDIF
      
      IF MFRT_NAME = 'NONE' .OR. MFRT_NAME = SPACE(32)
         IF MTOT_FRT <> 0
            @ 24,0 CLEAR
            STORE ' ' TO MERROR
            @ 24,0 SAY 'ERROR: NO FRT CARRIER ENTERED BUT FRT AMOUNT NOT EQUAL ZERO ' GET MERROR
            READ
            MACTION = 2
            @ 24,0 CLEAR
            LOOP
         ENDIF
      ENDIF
      
      *IF MTOT_FRT = 0
      *   IF MFRT_NAME <> 'NONE' .AND. MFRT_NAME <> SPACE(32)
      *      @ 24,0 CLEAR
      *      STORE ' ' TO MERROR
      *      @ 24,0 SAY 'ERROR: FRT AMOUNT EQUAL ZERO - FRT CARRIER ENTERED ' GET MERROR
      *      READ
      *      MACTION = 2
      *      LOOP
      *   ENDIF
      *ENDIF
      IF MTOT_FRT > 6500
         @ 24,0 CLEAR
         STORE '  ' TO MERROR
         @ 24,0 SAY "FREIGHT AMOUNT ENTERED GREATER THAN $6500 - ENTER 'OK' TO VERIFY" GET MERROR PICTURE '@!' VALID(MERROR = 'OK')
         READ
         @ 24,0 CLEAR
      ENDIF
      
      STORE MFRT_NAME TO MNAME
      
      IF MNAME <> 'NONE' .AND. MNAME <> SPACE(32)
         MNAME_FD = .F.
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
         DO FRT_SEL4
         IF .NOT. MNAME_FD .OR. MACTION = 3
            MACTION = 2
            LOOP
         ENDIF
         STORE NAME TO MFRT_NAME
         STORE FRT_CODE TO MFRT_CODE
         STORE STREET TO MSTREET
         STORE CITY   TO MCITY
         STORE STATE TO MSTATE
         STORE ZIP TO MZIP
         STORE ZIP4 TO MZIP4
      ENDIF
      
   ENDDO
   IF MACTION = 3
      MMORE = .F.
      LOOP
   ENDIF
   
   @ 6,26 SAY MFRT_NAME
   @ 7,26 SAY MSTREET
   IF MCITY <> SPACE(20)
      @ 8,26 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP + '-' + MZIP4
   ENDIF
   
   
   MACTION = 2
   DO WHILE MACTION = 2
      MLINE = 11
      I = 1
      DO WHILE I<= 10
         MI = SUBSTR(STR(I+100,3),2)
         @ MLINE,9  GET MSALES&MI 
         @ MLINE,12 GET MPO&MI PICTURE '####'
         @ MLINE,17 GET MSUFF&MI PICTURE '@!'
         MLINE = MLINE + 1
         I = I + 1
      ENDDO
      
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue Release    2. Edit    3. Cancel'
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      
      IF MACTION = 2
         LOOP
      ENDIF
      
      IF MACTION = 3
         MMORE = .F.
         LOOP
      ENDIF
      
      ****** CHECK ALL ORDER FOR SHIPMENT STATUS
      MERROR = .F.
      I = 1
      DO WHILE I<= 10 .AND. .NOT. MERROR
         MI = SUBSTR(STR(I+100,3),2)
         STORE MSALES&MI TO MSALESMAN
         STORE MPO&MI TO MPO_NBR
         STORE MSUFF&MI TO MPO_SUFFIX
         IF MPO_NBR = SPACE(4)
            I = 11
            LOOP
         ENDIF
         
         SELECT B
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF EOF() .OR. DELETED()
            @ 24,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'ORDER ' + MPO_NBR + '-' + MPO_SUFFIX + ' NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
            READ
            MERROR = .T.
            @ 24,0 CLEAR
            LOOP
         ENDIF
         
         IF BROKERAGE <> 'H'
            @ 24,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'ORDER ' + MPO_NBR + '-' + MPO_SUFFIX + ' ALREADY RELEASED - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
            READ
            MERROR = .T.
            @ 24,0 CLEAR
            LOOP
         ENDIF
         
         STORE MONTH(SHIP_DATE) TO MSHIP_MO
         MSHIP_MO = SUBSTR(STR(MSHIP_MO+100,3),2) 
         STORE STR(YEAR(SHIP_DATE),4)  TO MSHIP_YR
         SELECT F
         DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
         STORE TRAN_MO TO MTRAN_MO
         STORE TRAN_YR TO MTRAN_YR
         
         USE
         
         SELECT B
         IF SHIP_DATE > DATE()
            @ 24,0 CLEAR
            MWAIT = ' '
            @ 24,1 SAY 'CANNOT RELEASE- ORDER ' + MPO_NBR + '-' + MPO_SUFFIX + ' SHIP DATE IN FUTURE - PRESS RETURN SELECT AGAIN ' GET MWAIT
            READ
            MERROR = .T.
            @ 24,0 CLEAR
            LOOP
         ENDIF
         
         IF BBUYCODE = 'INVN' .OR. RSUPCODE = 'INVN'
            IF VAL(MSHIP_YR+MSHIP_MO) < VAL(MTRAN_YR+MTRAN_MO)
               @ 24,0 CLEAR
               MWAIT = ' '
               @ 24,1 SAY 'CANNOT RELEASE- ORDER ' + MPO_NBR + '-' + MPO_SUFFIX + ' FROM PREVIOUS SHIP MONTH- PRESS RETURN SELECT AGAIN ' GET MWAIT
               READ
               MERROR = .T.
               @ 24,0 CLEAR
               LOOP
            ENDIF
         ENDIF
         
         IF B->BBUYCODE = 'INVN'
            IF MONTH(B->SHIP_DATE) <> MONTH(B->DEL_REQD)
               @ 24,0 CLEAR
               MWAIT = ' '
               @ 24,1 SAY MPO_NBR + '-' + MPO_SUFFIX + ' SHIP/DEL MONTH MUST BE SAME FOR INVN- PRESS RETURN SELECT AGAIN ' GET MWAIT
               READ
               MERROR = .T.
               @ 24,0 CLEAR
               LOOP
            ENDIF
            IF YEAR(B->SHIP_DATE) <> YEAR(B->DEL_REQD)
               @ 24,0 CLEAR
               MWAIT = ' '
               @ 24,1 SAY MPO_NBR + '-' + MPO_SUFFIX + ' SHIP/DEL YEAR MUST BE SAME FOR INVN- PRESS RETURN SELECT AGAIN ' GET MWAIT
               READ
               MERROR = .T.
               @ 24,0 CLEAR
               LOOP
            ENDIF
         ENDIF
         
         SELECT C
         IF B->BBUYCODE = 'INVN' .OR.  B->RSUPCODE = 'INVN'
            IF MSALESMAN <> SPACE(2) .OR. MPO_NBR <> SPACE(4)
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
                  IF QTY = 0
                     SKIP
                     LOOP
                  ENDIF
                  IF IN_LOT = 'P' .OR. OUT_LOT = 'P' .OR. IN_LOT = 'U' .OR. OUT_LOT = 'U'
                     @ 24,0 CLEAR
                     MWAIT = ' '
                     @ 24,01 SAY MPO_NBR + '-' + MPO_SUFFIX + ' PEND/UNDET LOT # ON ITEM(S) - CANNOT RELEASE-PRESS RETURN ' GET MWAIT
                     READ
                     GOTO BOTTOM
                     MACTION = 2
                     MERROR = .T.
                     @ 24,0 CLEAR
                     LOOP
                  ENDIF
                  **** CHECK FOR PACK DATES ON ORDERS GOING INTO/OUT OF INVENTORY
                  IF B->BBUYCODE = 'INVN' .AND. (IN_LOT <> 'P' .AND. IN_LOT <> 'U')
                     IF PAK_YR = 0 .OR. PAK_DAY = 0
                        @ 24,0 CLEAR
                        MWAIT = ' '
                        @ 24,01 SAY MPO_NBR + '-' + MPO_SUFFIX + ' PAK DATE NOT ENTERED ON ALL ITEMS- CANNOT RELEASE-PRESS RETURN ' GET MWAIT
                        READ
                        GOTO BOTTOM
                        MACTION = 2
                        MERROR = .T.
                        @ 24,0 CLEAR
                        LOOP
                     ENDIF
                  ENDIF
                  SKIP
               ENDDO
            ENDIF
         ENDIF
         
         IF .NOT. MERROR
            IF B->RSUPCODE = 'INVN'
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
                  IF C->QTY = 0
                     SKIP
                     LOOP
                  ENDIF
                  **** MAKE SURE LOT NUMBER ON FILE AND AT LEAST THAT MAY CASES LEFT
                  SELECT E
                  DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
                  SEEK B->SUP_CODE
                  IF .NOT. EOF()
                     MFREEZ_LOC = NAME
                  ELSE
                     MFREEZ_LOC = 'UNKNOWN' + SPACE(25)
                  ENDIF
                  USE
                  
                  SELECT F
                  DO FOX_USE WITH "INVEN INDEX INVNLOC, INVNSOLD, INVNINBR, INVNLOT, INVNPO, INVNANIV, INVNCAT", .F.
                  SEEK MFREEZ_LOC + C->OUT_LOT
                  IF EOF()            
                     SELECT C
                     @ 24,0 CLEAR
                     STORE MPO_NBR + '-' + MPO_SUFFIX +' OUT OF INVN-LOT ' + c->out_lot  + ' NOT ON FILE -CANNOT RELEASE-PRESS RETURN ' TO MWAIT
                     @ 24,01 GET MWAIT
                     READ
                     GOTO BOTTOM
                     MERROR = .T.
                     MACTION = 2
                     @ 24,0 CLEAR
                     LOOP
                  ELSE
                     IF C->QTY > CASE_LEFT
                        SELECT C
                        @ 24,0 CLEAR
                        MWAIT = ' '
                        @ 24,01 SAY MPO_NBR + '-' + MPO_SUFFIX + ' NOT ENUF CASES LEFT IN LOT: ' + C->OUT_LOT + ' -CANNOT RELEASE-PRESS RETURN ' GET MWAIT
                        READ
                        GOTO BOTTOM
                        MERROR = .T.
                        MACTION = 2
                        @ 24,0 CLEAR
                        LOOP
                     ENDIF
                  ENDIF
                  SELECT F
                  USE
                  SELECT C
                  SKIP
               ENDDO
               IF MERROR
                  LOOP
               ENDIF
            ELSE
               IF B->BBUYCODE = 'INVN'
                  SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
                  DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
                     IF C->QTY = 0
                        SKIP
                        LOOP
                     ENDIF
                     **** MAKE SURE LOT NUMBER NOT ON FILE
                     SELECT E
                     DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
                     SEEK B->SUP_CODE
                     IF .NOT. EOF()
                        MFREEZ_LOC = NAME
                     ELSE
                        MFREEZ_LOC = 'UNKNOWN' + SPACE(25)
                     ENDIF
                     USE
                     
                     SELECT F
                     DO FOX_USE WITH "INVEN INDEX INVNLOC, INVNSOLD, INVNINBR, INVNLOT, INVNPO, INVNANIV, INVNCAT", .F.
                     SEEK MFREEZ_LOC + C->IN_LOT
                     IF .NOT. EOF()            
                        SELECT C
                        @ 24,0 CLEAR
                        STORE MPO_NBR + '-' + MPO_SUFFIX + ' INTO INVN-LOT ' + c->IN_lot  + ' ALREADY ON FILE-CANNOT RELEASE-PRESS RETURN ' TO MWAIT
                        @ 24,01 GET MWAIT
                        READ
                        GOTO BOTTOM
                        MERROR = .T.
                        MACTION = 2
                        @ 24,0 CLEAR
                        LOOP
                     ENDIF
                     SELECT F
                     USE
                     SELECT C
                     SKIP
                  ENDDO
                  
                  IF MERROR
                     LOOP
                  ENDIF
                  
               ENDIF
            ENDIF
         ENDIF
         
         I = I + 1
      ENDDO
      
      IF MERROR
         MACTION = 2
      ENDIF
      
      
   ENDDO

   IF .NOT. mmore
      loop
   endif

   MINVN= .T.
   I = 1
   MTOT_LBS = 0
   MINVN_LBS = 0
   DO WHILE I<= 10
      MI = SUBSTR(STR(I+100,3),2)
      STORE MSALES&MI TO MSALESMAN
      STORE MPO&MI TO MPO_NBR
      STORE MSUFF&MI TO MPO_SUFFIX
      IF MPO&MI <> SPACE(4)
         SELECT B
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF BBUYCODE = 'INVN'
            *** TOOK OUT NOT PRORATING FREIGHT ON INVENTORY SHIPPED WITH
            *** REGULAR CUSTOMER PO'S -  07/14/2011
            ***MINVN&MI = 'Y'
            MINVN= .F.
         ELSE
            MINVN= .F.
         ENDIF
         
         SELECT C
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
            IF QTY <> 0
               IF SUBSTR(PACKED,1,1) = 'B'
                  MLBS&MI = MLBS&MI + (QTY * VAL(SUBSTR(PACKED,2)))
               ELSE
                  MLBS&MI = MLBS&MI + LBS
               ENDIF
            ENDIF
            SKIP
         ENDDO
         
         IF MINVN&MI = 'Y'
            MINVN_LBS = MINVN_LBS + MLBS&MI
         ELSE
            MTOT_LBS = MTOT_LBS + MLBS&MI
         ENDIF
      ENDIF
      
      I = I + 1
   ENDDO
   
   *** IF ALL INVENTORY - THEN ALL LBS ARE PRORATED
   IF MINVN
      MTOT_LBS = MINVN_LBS
   ENDIF
   
   IF MINVN01 = 'Y' .AND. MPO02 = SPACE(4)
      MPRO_FRT01 = MTOT_FRT
   ELSE
      
      IF MTOT_LBS <> 0
         I = 1
         MTOT_PRO = 0
         MLAST_PO = '01'
         
         DO WHILE I<= 10
            MI = SUBSTR(STR(I+100,3),2)
            IF MLBS&MI <> 0
               IF MINVN&MI <> 'Y' .OR. MINVN
                  MLAST_PO = MI
                  MPRO_FRT&MI = ROUND(MLBS&MI/MTOT_LBS * MTOT_FRT,2)
                  MTOT_PRO = MTOT_PRO + MPRO_FRT&MI
               ENDIF
            ENDIF
            I = I + 1
         ENDDO
         MPRO_FRT&MLAST_PO = MPRO_FRT&MLAST_PO + (MTOT_FRT - MTOT_PRO)
         
      ENDIF
   ENDIF
   I = 1
   MLINE = 11
   DO WHILE I<= 10
      MI = SUBSTR(STR(I+100,3),2)
      @ MLINE,21 SAY MLBS&MI PICTURE '99,999.99'
      @ MLINE,34 SAY MPRO_FRT&MI PICTURE '99,999.99'
      @ MLINE,47 SAY MINVN&MI
      I = I + 1
      MLINE = MLINE + 1
   ENDDO
   
   MCONT = ' '
   @ 22,4 SAY 'Continue with release(s) (Y/N): ' GET MCONT PICTURE '@!' VALID(MCONT= 'Y' .OR. MCONT = 'N')
   READ
   IF MCONT = 'Y'
      MDOIT = .T.
      IF MDOIT
         I = 1
         DO WHILE I<= 10
            
            MI = SUBSTR(STR(I+100,3),2)
            
            IF MPO&MI = SPACE(4)
               I = 11
               LOOP
            ENDIF
            
            STORE MSALES&MI TO MSALESMAN
            STORE MPO&MI    TO MPO_NBR
            STORE MSUFF&MI  TO MPO_SUFFIX
            SELECT B
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            
            **** NOW UPDATE INVENTORY FILES IF NEEDED
            IF RSUPCODE = 'INVN' .OR. BBUYCODE = 'INVN'
               ** UPDATE INVENTORY DETAIL ACTIVITY CODE
               SELECT C
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               
               DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
                  IF QTY = 0
                     SKIP
                     LOOP
                  ENDIF
                  IF B->BBUYCODE = 'INVN'
                     **** GOING INTO INVENTORY
                     STORE C->IN_LOT TO MIN_LOT
                     
                     SELECT E
                     DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
                     SEEK B->BUY_CODE
                     IF .NOT. EOF()
                        MFREEZ_LOC = NAME
                     ELSE
                        MFREEZ_LOC = 'UNKNOWN' + SPACE(25)
                     ENDIF
                     USE
                     *******************************
                     ****** HEADER RECORD PROCESSING
                     *******************************
                     
                     *** GET THE HOLD RECORD FROM THE HOLDING INVENTORY FILE
                     DO FOX_USE WITH "HINVEN INDEX HINVNLOC, HINVSOLD", .F.
                     SEEK MFREEZ_LOC + MIN_LOT
                     
                     IF C->QTY <> 0
                        IF I_NBR = 0
                           *** GENERATE I NBR FOR THE OLD SYSTEM
                           SELECT F
                           DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
                           MI_NBR = LAST_INBR
                           MI_NBR = MI_NBR + 1
                           DO RECLOCK
                           REPLACE LAST_INBR WITH MI_NBR
                           UNLOCK 
                           USE
                           SELECT E
                           DO RECLOCK
                           REPLACE I_NBR WITH MI_NBR
                           UNLOCK
                        ENDIF
                        *** GET THE CURRENT FILE
                        SELECT F
                        DO FOX_USE WITH "INVEN INDEX INVNLOC, INVNSOLD, INVNINBR, INVNLOT, INVNPO, INVNANIV, INVNCAT", .F.
                        SEEK MFREEZ_LOC + MIN_LOT
                        
                        DO FILELOCK
                        IF EOF()
                           APPEND BLANK
                           REPLACE SALESMAN    WITH MSALESMAN
                           REPLACE PO_NBR      WITH MPO_NBR
                           REPLACE PO_SUFFIX   WITH MPO_SUFFIX
                           REPLACE FREEZ_LOC   WITH MFREEZ_LOC
                           REPLACE LOT_NBR     WITH MIN_LOT
                           REPLACE I_NBR       WITH E->I_NBR
                        ENDIF
                        REPLACE SHIP_DATE   WITH E->SHIP_DATE
                        REPLACE ANIV_DATE   WITH E->ANIV_DATE
                        REPLACE RSUPCODE    WITH E->RSUPCODE
                        REPLACE LBS         WITH E->LBS
                        REPLACE CASE_CNT    WITH E->CASE_CNT
                        REPLACE FRH_FRZ     WITH E->FRH_FRZ
                        REPLACE PROD_DESC   WITH E->PROD_DESC
                        REPLACE PACKED      WITH E->PACKED
                        REPLACE PACKAGED    WITH E->PACKAGED
                        REPLACE BOX_SZ      WITH E->BOX_SZ
                        REPLACE BOX_SIZE    WITH E->BOX_SIZE
                        REPLACE PRI_LB      WITH E->PRI_LB
                        REPLACE STOR_LB     WITH E->STOR_LB
                        REPLACE SIZE        WITH E->SIZE
                        REPLACE GRADE       WITH E->GRADE
                        REPLACE PAK_YR      WITH E->PAK_YR
                        REPLACE PAK_DAY     WITH E->PAK_DAY
                        REPLACE NOTE        WITH E->NOTE
                        MCAT = '  '
                        *** REPLACE FIELDS FOR THE OLD INVENTORY SYSTEM
                        REPLACE DIV_CODE    WITH '11'
                        REPLACE BROK_NAME   WITH B->BROK_NAME
                        REPLACE VALUE       WITH E->VALUE
                        REPLACE PRO_PRI     WITH E->PRO_PRI
                        REPLACE BOX_SIZE    WITH E->BOX_SIZE
                        REPLACE PROD_SIZE   WITH E->PROD_SIZE
                        
                        UNLOCK
                        
                        *** END OF INVENTORY FIELDS UPDATE
                     ENDIF
                     
                     SELECT E
                     *** DELETE THE HOLD RECORD
                     DO RECLOCK
                     DELETE
                     UNLOCK
                     
                     ************************************************
                     *** DETAIL RECORD PROCESSING
                     ************************************************
                     DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT", .F.
                     *** FIND THE RECORD PUTTING INTO INVENTORY
                     SEEK MFREEZ_LOC + MIN_LOT + 'I'
                     
                     IF C->QTY <> 0
                        **** GET THE CURRENT RECORD HERE
                        SELECT F
                        DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT, INVN_DTL, DTL_DATE, IDTL_DTL, INVN_PO, INVNDISP", .F.
                        SEEK MFREEZ_LOC + MIN_LOT + 'I'
                        DO FILELOCK
                        IF EOF()
                           APPEND BLANK
                           REPLACE SALESMAN WITH MSALESMAN
                           REPLACE PO_NBR WITH MPO_NBR
                           REPLACE PO_SUFFIX WITH MPO_SUFFIX
                           REPLACE ITEM_NBR WITH C->ITEM_NBR
                           REPLACE ACT_CODE WITH 'I'
                        ENDIF
                        
                        REPLACE LOT_NBR WITH MIN_LOT
                        REPLACE FREEZ_LOC WITH MFREEZ_LOC
                        REPLACE QTY WITH E->QTY
                        REPLACE LBS WITH E->LBS
                        REPLACE ACTIVITY WITH 'IN '
                        REPLACE ACT_DATE WITH E->ACT_DATE
                        *** REPLACE FOR OLD INVENTORY FIELDS
                        REPLACE I_NBR WITH E->I_NBR
                        REPLACE SYS_DATE WITH DATE()
                        *** END OF OLD FIELDS
                        UNLOCK
                     ENDIF
                     
                     *** DELETE THE HOLD RECORD
                     SELECT E
                     IF .NOT. EOF()
                        DO RECLOCK
                        DELETE
                        UNLOCK
                     ENDIF
                     *** CALCULATE WHAT'S LEFT (GOING IN)
                     MX = 0
                     MY = 0
                     MLBS_COM = 0
                     MCASE_COM = 0
                     MLBS_SOLD = 0
                     MCASE_SOLD = 0
                     
                     SELECT F
                     DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT, INVN_DTL, DTL_DATE, IDTL_DTL, INVN_PO, INVNDISP", .F.
                     SEEK MFREEZ_LOC + MIN_LOT
                     DO WHILE .NOT. EOF() .AND. LOT_NBR = MIN_LOT .AND. FREEZ_LOC = MFREEZ_LOC
                        IF ACTIVITY = 'COM'
                           MLBS_COM = MLBS_COM + (LBS * -1)
                           MCASE_COM = MCASE_COM + (QTY * -1)
                           SKIP
                           LOOP
                        ENDIF
                        MX = MX + QTY
                        MY = MY + LBS
                        IF ACTIVITY = 'OUT'
                           MLBS_SOLD = MLBS_SOLD + (LBS * -1)
                           MCASE_SOLD= MCASE_SOLD + (QTY * -1)
                        ENDIF
                        SKIP
                     ENDDO
                     
                     SELECT F
                     DO FOX_USE WITH "INVEN INDEX INVNLOC, INVNSOLD, INVNINBR, INVNLOT, INVNPO, INVNANIV, INVNCAT", .F.
                     SEEK MFREEZ_LOC + MIN_LOT
                     IF .NOT. EOF()
                        DO FILELOCK
                        REPLACE LBS_SOLD    WITH MLBS_SOLD
                        REPLACE CASE_SOLD   WITH MCASE_SOLD
                        REPLACE LBS_LEFT    WITH LBS - LBS_SOLD
                        REPLACE CASE_LEFT   WITH CASE_CNT - CASE_SOLD
                        REPLACE LBS_COM     WITH MLBS_COM
                        REPLACE CASE_COM    WITH MCASE_COM
                        
                        MVAL1 = LBS_LEFT * PRI_LB
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
                        
                        MVAL_LEFT = MVAL1          
                        REPLACE VAL_LEFT WITH MVAL_LEFT
                        
                        IF CASE_LEFT <= 0
                           REPLACE SOLD_FLG WITH 'Y'
                           REPLACE VAL_LEFT WITH 0
                        ELSE
                           REPLACE SOLD_FLG WITH ' '
                        ENDIF
                        UNLOCK
                     ENDIF
                  ENDIF
                  
                  ********************************************
                  **** END OF PROCESSING GOING INTO INVENTORY
                  ********************************************
                  ***here                  
                  *******************************************
                  *** SELLING OUT OF INVENTORY
                  IF B->RSUPCODE = 'INVN'
                     STORE C->OUT_LOT TO MOUT_LOT
                     SELECT E
                     DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
                     SEEK B->SUP_CODE
                     IF EOF()
                        MFREEZ_LOC = 'UNKNOWN' + SPACE(25)
                     ELSE
                        MFREEZ_LOC = NAME
                     ENDIF
                     
                     *******************************
                     **** GET THE HOLD DETAIL RECORD
                     *******************************
                     
                     DO FOX_USE WITH "HINV_DTL INDEX HINV_DTL", .F.
                     SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + C->ITEM_NBR + 'S'
                     ** IF QTY = 0, FORGET THE WHOLE THING
                     
                     IF C->QTY = 0
                        IF .NOT. EOF()
                           DO RECLOCK
                           DELETE
                           UNLOCK
                        ENDIF
                        USE
                        
                        SELECT C
                        SKIP
                        LOOP
                     ENDIF
                     *** GET THE I NBR TAKING OUT OF INVEN
                     SELECT F
                     DO FOX_USE WITH "INVEN INDEX INVNLOC, INVNSOLD, INVNINBR, INVNLOT, INVNPO, INVNANIV, INVNCAT", .F.
                     SEEK MFREEZ_LOC + MOUT_LOT
                     MI_NBR = I_NBR
                     USE
                     **********************************
                     **** GET THE CURRENT DETAIL RECORD
                     **********************************
                     SELECT F
                     DO FOX_USE WITH "INVN_DTL INDEX INVN_DTL, DTL_LOT, DTL_DATE, IDTL_DTL, INVN_PO, INVNDISP", .F.
                     DO FILELOCK
                     SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX + C->ITEM_NBR + 'S'
                     IF EOF()
                        APPEND BLANK
                        REPLACE SALESMAN WITH MSALESMAN
                        REPLACE PO_NBR WITH MPO_NBR
                        REPLACE PO_SUFFIX WITH MPO_SUFFIX
                        REPLACE ITEM_NBR WITH C->ITEM_NBR
                        REPLACE ACT_CODE WITH 'S'
                     ENDIF
                     
                     REPLACE LOT_NBR WITH MOUT_LOT
                     REPLACE I_NBR WITH MI_NBR
                     REPLACE FREEZ_LOC WITH MFREEZ_LOC
                     REPLACE QTY WITH E->QTY
                     REPLACE LBS WITH E->LBS 
                     REPLACE ACTIVITY WITH 'OUT'
                     REPLACE ACT_DATE WITH B->SHIP_DATE
                     **********************************************
                     REPLACE SYS_DATE WITH DATE()
                     REPLACE SHIP_LBS  WITH E->SHIP_LBS
                     REPLACE SHIP_CASE WITH E->SHIP_CASE
                     REPLACE SHIP_VAL  WITH E->SHIP_VAL
                     REPLACE SHIP_PRI  WITH E->SHIP_PRI
                     REPLACE BBUYCODE  WITH B->BBUYCODE
                     
                     SELECT A
                     DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
                     SEEK B->BUY_CODE
                     MNAME = NAME   
                     USE
                     SELECT F
                     REPLACE SHIP_NAME WITH MNAME
                     UNLOCK
                     
                     *** NOW DELETE THE RECORD FROM HOLD INVENTORY
                     SELECT E
                     DO RECLOCK
                     DELETE
                     UNLOCK
                     
                     **** END OF REGULAR  UPDATES
                     **********************************************
                     
                     *** CALCULATE WHAT'S LEFT USING LOT_NBR (OUT)
                     MX = 0
                     MY = 0
                     MLBS_SOLD = 0
                     MCASE_SOLD = 0
                     MLBS_COM   = 0
                     MCASE_COM  = 0
                     SELECT F
                     DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT, INVN_DTL, DTL_DATE, IDTL_DTL, INVN_PO, INVNDISP", .F.
                     SEEK MFREEZ_LOC + MOUT_LOT
                     DO WHILE .NOT. EOF() .AND. LOT_NBR = MOUT_LOT .AND. FREEZ_LOC = MFREEZ_LOC
                        IF ACTIVITY = 'COM'
                           MLBS_COM = MLBS_COM + (LBS * -1)
                           MCASE_COM = MCASE_COM + (QTY * -1)
                           SKIP
                           LOOP
                        ENDIF
                        MX = MX + QTY
                        MY = MY + LBS
                        IF ACTIVITY = 'OUT'
                           MLBS_SOLD = MLBS_SOLD + (LBS * -1)
                           MCASE_SOLD= MCASE_SOLD + (QTY * -1)
                        ENDIF
                        SKIP
                     ENDDO
                     USE
                     
                     SELECT F
                     DO FOX_USE WITH "INVEN INDEX INVNLOC, INVNSOLD, INVNINBR, INVNLOT, INVNPO, INVNANIV, INVNCAT", .F.
                     SEEK MFREEZ_LOC + MOUT_LOT
                     IF .NOT. EOF()
                        DO FILELOCK
                        REPLACE LBS_SOLD    WITH MLBS_SOLD
                        REPLACE CASE_SOLD   WITH MCASE_SOLD
                        REPLACE LBS_LEFT    WITH LBS - LBS_SOLD
                        REPLACE CASE_LEFT   WITH CASE_CNT - CASE_SOLD
                        REPLACE LBS_COM     WITH MLBS_COM
                        REPLACE CASE_COM    WITH MCASE_COM
                        
                        MVAL1 = LBS_LEFT * PRI_LB
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
                        
                        MVAL_LEFT = MVAL1          
                        REPLACE VAL_LEFT WITH MVAL_LEFT
                        
                        IF CASE_LEFT <= 0
                           REPLACE SOLD_FLG WITH 'Y'
                           REPLACE VAL_LEFT WITH 0
                           IF CASE_LEFT < 0
                              @ 24,0 CLEAR
                              MOK = SPACE(2)
                              @ 24,1 SAY 'OVERSOLD QTY ON LOT #: ' + MOUT_LOT + ' - TYPE "OK" TO CONTINUE ' GET MOK PICTURE '@!' VALID MOK = 'OK'
                              READ
                           ENDIF
                        ELSE
                           REPLACE SOLD_FLG WITH ' '
                        ENDIF
                        UNLOCK
                     ENDIF
                  ENDIF   
                  
                  
                  SELECT C
                  SKIP
               ENDDO
               
            ENDIF
            
            **IF MPRO_FRT&MI <> 0         
            SELECT B
            DO RECLOCK
            IF MFRT_CODE = SPACE(4)
               REPLACE FRT_CODE1 WITH 'NONE'
               REPLACE FRT_AMT1 WITH 0
            ELSE
               REPLACE FRT_CODE1 WITH MFRT_CODE
               REPLACE FRT_AMT1  WITH MPRO_FRT&MI
            ENDIF
            
            *** CHECK FOR SPLIT SHIP ORDERS
            X = 1
            R = 1
            DO WHILE X <= 10 .AND. R<= 6
               MX = SUBSTR(STR(X+100,3),2)
               IF I = X
                  X = X + 1
                  LOOP
               ENDIF
               IF MPO&MX <> SPACE(4)
                  IF MSALES&MX <> SPACE(2)
                     MPO = MSALES&MX + '-' + MPO&MX
                  ELSE
                     MPO = MPO&MX
                  ENDIF
                  IF MSUFF&MX <> ' '
                     MPO = MPO + '-' + MSUFF&MX
                  ENDIF
                  MR = STR(R,1)
                  REPLACE REF_PO&MR WITH MPO
                  R = R + 1
               ENDIF
               X = X + 1
            ENDDO
            
            UNLOCK
            
            MGROSS = B->GROSS
            
            MNET = MGROSS - (FRT_AMT1+ FRT1_ADJ1+ FRT1_ADJ2+ FRT_PALL)
            
            IF COMM_ENT <> 0
               MCOMM_AMT = COMM_ENT
            ELSE
               MCOMM_AMT = COMM_AMT
            ENDIF
            
            IF COMM_ENT2 <> 0
               MCOMM_AMT2= COMM_ENT2
            ELSE
               MCOMM_AMT2 = COMM_AMT2
            ENDIF
            
            IF COMM_ENT3 <> 0
               MCOMM_AMT3 = COMM_ENT3
            ELSE                     
               MCOMM_AMT3 = COMM_AMT3
            ENDIF
            
            IF SALE_ENT <> 0
               MSALE_COMM = SALE_ENT
            ELSE
               MSALE_COMM = SALE_COMM
            ENDIF
            
            IF SALE2_ENT <> 0
               MSALE2_COM = SALE2_ENT
            ELSE
               MSALE2_COM = SALE2_AMT
            ENDIF
            
            IF SALE3_ENT <> 0
               MSALE3_COM = SALE3_ENT
            ELSE
               MSALE3_COM = SALE3_AMT
            ENDIF
            
            
            MNET = MNET - MCOMM_AMT - MCOMM_AMT2 - MCOMM_AMT3 
            MNET = MNET - MSALE_COMM - MSALE2_COM - MSALE3_COM
            
            IF MISC_FLG <> ' '
               SELECT E
               DO FOX_USE WITH "MISC_CHG INDEX MISC_CHG", .F.
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               IF .NOT. EOF()
                  STORE MISCAMT1 TO MMISCAMT1
                  STORE MISCAMT2 TO MMISCAMT2
                  STORE MISCAMT3 TO MMISCAMT3
               ELSE
                  STORE 0 TO MMISCAMT1, MMISCAMT2, MMISCAMT3
               ENDIF
               USE
            ELSE
               STORE 0 TO MMISCAMT1, MMISCAMT2, MMISCAMT3
            ENDIF
            
            MNET = MNET - MMISCAMT1 - MMISCAMT2 - MMISCAMT3
            SELECT B
            DO RECLOCK
            REPLACE TOT_NET WITH MNET
            UNLOCK
            **ENDIF
            
            SELECT B
            DO RECLOCK
            REPLACE BROKERAGE WITH ' '
            UNLOCK
            
            I = I + 1
         ENDDO
         
         **RELEASE MCOMM_AMT, MCOMM_AMT2, MCOMM_AMT3, MSALE_COMM
         **RELEASE MMISCAMT1, MMISCAMT2, MMISCAMT3, MFRT_CODE
         I = 1
         DO WHILE I <= 10
            MI = SUBSTR(STR(I+100,3),2)
            RELEASE MLBS&MI, MPRO_FRT&MI, MINVN&MI
            I = I + 1
         ENDDO
         
         **** NOW PRINT THESE ORDER(S) AGAIN BECAUSE IT CHANGED STATUS
         I = 1
         DO WHILE I <= 10
            MI = SUBSTR(STR(I+100,3),2)
            IF MPO&MI = SPACE(4)
               I = 11
               LOOP
            ENDIF
            STORE MSALES&MI TO MSALESMAN
            STORE MPO&MI TO MPO_NBR
            STORE MSUFF&MI TO MPO_SUFF
            SELECT B
            SEEK MSALESMAN+MPO_NBR+MPO_SUFF
            DO PRT_ONE
            I = I + 1
         ENDDO
         *** GET RID OF ALL USED FILES EXCEPT FOR B->PO_HEAD, C->PO_DTL
         SELECT A
         USE
         SELECT D
         USE
         SELECT E
         USE
         SELECT F
         USE
         SELECT B
         
         SET PROC TO
      ENDIF
      
      @ 22,1 SAY SPACE(78)
      @ 23,1 SAY SPACE(78)
      @ 3,0 to 24,79
      STORE 'ORDER(S) RELEASED - PRESS RETURN TO CONTINUE ' TO MWAIT
      @ 22,1 GET MWAIT
      CLEAR GETS
      MWAIT = ' '
      @ 22,47 GET MWAIT 
      READ
      @ 22,1 SAY SPACE(78)
   ENDIF
   MMORE = .F.
   
ENDDO

CLOSE DATA

RETURN
* EOF: PO_RELE.PRG
*Formatted by: ToolBox Ver. 1.2  on 9/9/14 at 12:57 PM.
