****************
* Program.: MASTER.PRG
* Author..: GRACE KELLER
* Mods by.: 
* Date....: 10/12/87
* Notice..: Copyright (C) 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: File Maintenance Program
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
CLOSE DATA

STORE ' ' TO MSELECTION
STORE ' ' TO MACTION

DO WHILE VAL(MSELECTION) <> 99 
   
   CLEAR
   @ 01,00 SAY MCOMPANY
   @ 02,00 SAY MPROGRAM + ' - MASTER FILE UPDATE MENU'
   @ 02,70 SAY DATE()
   @ 3,0 to 25,79
   
   @ 04,10 SAY ' 1 - REMIT TO     SUPPLIERS         3. BILL TO CUSTOMERS'
   @ 05,10 SAY ' 2 - SHIPPED FROM SUPPLIERS         4. SHIP TO CUSTOMERS'
   @ 06,10 SAY ' 5 - FREIGHT CARRIERS'
   @ 07,10 SAY ' 6 - SALESPERSONS'
   @ 08,10 SAY ' 7 - THIRD PARTY COMMISSION PAYEES'
   @ 09,10 SAY ' 8 - PRODUCT NATURE'
   @ 10,10 SAY ' 9 - PRODUCT GRADES'      
   @ 11,10 SAY '10 - REFRIGERATION/STORAGE AND PACKAGING DESCRIPTIONS'
   @ 12,10 SAY '11 - PRODUCT SIZE'
   @ 13,10 SAY '12 - UNIT PACK (BOX SIZES)'
   @ 14,10 SAY '13 - PRODUCT DESCRIPTIONS'
   @ 15,10 SAY '14 - Q HOLD MASTER - INVENTORY PULL RULES'
   @ 16,10 SAY '15 - CHART OF ACCOUNTS'
   @ 17,10 SAY '16 - ADD/UPDATE BROKER/BILLBACKS BY CUSTOMER'
   @ 18,10 SAY '17 - BROKERAGE FEES FOR 3RD PARTY COMM/PROGRAM BILLBACKS'
   @ 19,10 SAY '18 - NATIONAL PRICING MASTER'
   @ 20,10 SAY '19 - SUPPLIER\CUSTOMER PRICING MASTER'
   @ 21,10 SAY '99 - RETURN TO MAINTENANCE MENU'
   
   STORE '  ' TO MSELECTION
   @ 23,02 SAY 'CHOICE: '
   @ 23,10 GET MSELECTION picture '##'
   READ
   
   DO CASE
      
   CASE VAL(MSELECTION) = 1     
      SET PROC TO SUP_PROC
      DO RSUP_SEL
   CASE VAL(MSELECTION) = 2     
      SET PROC TO SUP_PROC
      DO SUP_SEL
   CASE VAL(MSELECTION) =  3    
      SET PROC TO BUY_PROC
      DO BBUY_SEL
   CASE VAL(MSELECTION) =  4    
      SET PROC TO BUY_PROC
      DO BUY_SEL
   CASE VAL(MSELECTION) =  5    
      DO FRT_SEL
   CASE VAL(MSELECTION) =  6    
      SET PROC TO SAL_PROC
      DO PUBLSAL
      DO SAL_SEL 
      DO RELESAL
   CASE VAL(MSELECTION) =  7    
      SET PROC TO COM_PROC
      DO PUBLCOM
      DO COM_SEL  
      DO RELECOM
   CASE VAL(MSELECTION) =  8    
      *     DO FR_FZ    
      * Notes...: FRESH/FROZEN DESCRIPTION UPDATE  
      *
      * ---OPEN FILES
      *  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
      SELECT D
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      MTITLE = ' - UPDATE/DELETE FRESH/FROZEN CATEGORY'
      STORE SPACE(2) TO MCODE     
      MNOT_FIN = .T.
      DO WHILE MNOT_FIN
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            @ 7,2 SAY 'FRESH/FROZEN CODE'      
            @ 9,08 GET MCODE PICTURE '@!'
            STORE 1 TO MSEL   
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,3
            READ               
         ENDDO
         IF MSEL = 3 .OR. MCODE = SPACE(2)
            MNOT_FIN = .F.
            LOOP
         ENDIF
         SEEK 'F' + MCODE      
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,6) TO MDESC
         ELSE
            STORE SPACE(6) TO MDESC
         ENDIF
         @ 7,27 SAY 'DESCRIPTION TO BE PRINTED'
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            @ 9,35 GET MDESC PICTURE '@!'
            STORE 1 TO MSEL
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1. Save Update    2. Edit    3. Delete Code & Desc    4. Cancel'
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,4
            READ               
         ENDDO
         
         DO CASE
            
         CASE MSEL=1
            IF MCODE <> SPACE(2)
               SEEK 'F' + MCODE      
               IF EOF()
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE TYPE WITH 'F'
                  REPLACE CODE WITH MCODE
                  UNLOCK
               ENDIF
               DO RECLOCK
               REPLACE DESC WITH MDESC
               UNLOCK
               MCODE = SPACE(2)
            ELSE
               MNOT_FIN = .F.
            ENDIF
         CASE MSEL = 3 
            SEEK 'F' + MCODE     
            IF .NOT. EOF()
               DO RECLOCK
               DELETE
               UNLOCK
               @ 23,0 CLEAR
               STORE 'CODE & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
               @ 24,5 GET MWAIT
               READ        
            ENDIF
            MNOT_FIN = .F.
         CASE MSEL = 4
            MNOT_FIN = .F.
            
         ENDCASE
         
      ENDDO
      
      CLOSE DATA 
      
   CASE VAL(MSELECTION) =  9    
      DO CASE
      CASE MCOMPANY <> 'DIVISION 15'
         *     DO GRADE     
         * ---OPEN FILES
         *  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
         SELECT D
         DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
         
         MTITLE = ' - UPDATE/DELETE GRADE CATEGORY'
         STORE SPACE(1) TO MCODE     
         MNOT_FIN = .T.
         DO WHILE MNOT_FIN
            STORE 2 TO MSEL
            DO WHILE MSEL = 2
               CLEAR
               @  1, 0 SAY MCOMPANY
               @  1,68 SAY DATE()
               @  2, 0 SAY MPROGRAM + MTITLE
               @ 3,0 TO 22,79
               @ 7,5 SAY 'GRADE CODE'      
               @ 9,09 GET MCODE PICTURE '@!'
               STORE 1 TO MSEL   
               @ 24,01 SAY 'Action: ' + STR(MSEL,1)
               @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
               READ
               @24,09 GET MSEL PICTURE '9' RANGE 1,3
               READ               
            ENDDO
            IF MSEL = 3 .OR. MCODE = SPACE(1)
               MNOT_FIN = .F.
               LOOP
            ENDIF
            SEEK 'G' + MCODE      
            IF .NOT. EOF()
               STORE SUBSTR(DESC,1,8) TO MDESC
            ELSE
               STORE SPACE(8) TO MDESC
            ENDIF
            @ 7,27 SAY 'DESCRIPTION TO BE PRINTED'
            STORE 2 TO MSEL
            DO WHILE MSEL = 2
               @ 9,35 GET MDESC PICTURE '@!'
               STORE 1 TO MSEL
               @ 24,01 SAY 'Action: ' + STR(MSEL,1)
               @ 24,13 SAY '1. Save Update    2. Edit    3. Delete Code & Desc    4. Cancel'
               READ
               @24,09 GET MSEL PICTURE '9' RANGE 1,4
               READ               
            ENDDO
            
            DO CASE
               
            CASE MSEL=1
               IF MCODE <> SPACE(1)
                  SEEK 'G' + MCODE      
                  IF EOF()
                     DO FILELOCK
                     APPEND BLANK
                     UNLOCK
                     DO RECLOCK
                     REPLACE TYPE WITH 'G'
                     REPLACE CODE WITH MCODE
                     UNLOCK
                  ENDIF
                  DO RECLOCK
                  REPLACE DESC WITH MDESC
                  UNLOCK
                  MCODE = SPACE(1)
               ELSE
                  MNOT_FIN = .F.
               ENDIF
            CASE MSEL = 3 
               SEEK 'G' + MCODE     
               IF .NOT. EOF()
                  DO RECLOCK
                  DELETE
                  UNLOCK
                  @ 23,0 CLEAR
                  STORE 'CODE & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
                  @ 24,5 GET MWAIT
                  READ        
               ENDIF
               MNOT_FIN = .F.
            CASE MSEL = 4
               MNOT_FIN = .F.
               
            ENDCASE
            
         ENDDO
         
         CLOSE DATA 
         
      OTHERWISE
         
         SELECT D
         DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
         
         MTITLE = ' - UPDATE/DELETE PROCESS TYPE CATEGORY'
         STORE SPACE(1) TO MCODE     
         MNOT_FIN = .T.
         DO WHILE MNOT_FIN
            STORE 2 TO MSEL
            DO WHILE MSEL = 2
               CLEAR
               @  1, 0 SAY MCOMPANY
               @  1,68 SAY DATE()
               @  2, 0 SAY MPROGRAM + MTITLE
               @ 3,0 TO 22,79
               @ 7,5 SAY 'PROCESS CODE'      
               @ 9,09 GET MCODE PICTURE '@!'
               STORE 1 TO MSEL   
               @ 24,01 SAY 'Action: ' + STR(MSEL,1)
               @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
               READ
               @24,09 GET MSEL PICTURE '9' RANGE 1,3
               READ               
            ENDDO
            IF MSEL = 3 .OR. MCODE = SPACE(1)
               MNOT_FIN = .F.
               LOOP
            ENDIF
            SEEK 'G' + MCODE      
            IF .NOT. EOF()
               STORE SUBSTR(DESC,1,8) TO MDESC
            ELSE
               STORE SPACE(8) TO MDESC
            ENDIF
            @ 7,27 SAY 'DESCRIPTION TO BE PRINTED'
            STORE 2 TO MSEL
            DO WHILE MSEL = 2
               @ 9,35 GET MDESC PICTURE '@!'
               STORE 1 TO MSEL
               @ 24,01 SAY 'Action: ' + STR(MSEL,1)
               @ 24,13 SAY '1. Save Update    2. Edit    3. Delete Code & Desc    4. Cancel'
               READ
               @24,09 GET MSEL PICTURE '9' RANGE 1,4
               READ               
            ENDDO
            
            DO CASE
               
            CASE MSEL=1
               IF MCODE <> SPACE(1)
                  SEEK 'G' + MCODE      
                  IF EOF()
                     DO FILELOCK
                     APPEND BLANK
                     UNLOCK
                     DO RECLOCK
                     REPLACE TYPE WITH 'G'
                     REPLACE CODE WITH MCODE
                     UNLOCK
                  ENDIF
                  DO RECLOCK
                  REPLACE DESC WITH MDESC
                  UNLOCK
                  MCODE = SPACE(1)
               ELSE
                  MNOT_FIN = .F.
               ENDIF
            CASE MSEL = 3 
               SEEK 'G' + MCODE     
               IF .NOT. EOF()
                  DO RECLOCK
                  DELETE
                  UNLOCK
                  @ 23,0 CLEAR
                  STORE 'CODE & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
                  @ 24,5 GET MWAIT
                  READ        
               ENDIF
               MNOT_FIN = .F.
            CASE MSEL = 4
               MNOT_FIN = .F.
               
            ENDCASE
            
         ENDDO
         
         CLOSE DATA 
      ENDCASE
      
      
   CASE VAL(MSELECTION) = 10    
      *     DO PACKAGE  
      * Notes...: PACKAGE DESCRIPTION UPDATE  
      *
      * ---OPEN FILES
      *  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
      SELECT D
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - UPDATE/DELETE REFRIGERATION/PAKAGINGING CATEGORIES'
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      @ 10,5 SAY 'Do you want to update Refrigeration/Storage Categories'
      @ 11,5 SAY 'Eg. "ICED, CHILLED, C.O.2, IQF" '
      @ 13,5 SAY 'OR do you want to update Packaging Descriptions'
      @ 14,5 SAY 'Eg. "BULK, CARTON, LAYER PACK, POLY BAG" ?'
      @ 17,5 SAY 'Enter "STORAGE" OR "PACKAGE" for the appropriate choice.'
      MCHOICE = SPACE(7)
      @ 18,5 GET MCHOICE PICTURE '@!'
      READ
      IF MCHOICE <> 'STORAGE' .AND. MCHOICE <> 'PACKAGE'
         LOOP
      ENDIF
      DO CASE
      CASE MCHOICE = 'STORAGE'
         MTITLE = ' - UPDATE/DELETE REFRIGERATION/STORAGE CATEGORY'
         STORE SPACE(1) TO MCODE     
         MNOT_FIN = .T.
         DO WHILE MNOT_FIN
            STORE 2 TO MSEL
            DO WHILE MSEL = 2
               CLEAR
               @  1, 0 SAY MCOMPANY
               @  1,68 SAY DATE()
               @  2, 0 SAY MPROGRAM + MTITLE
               @ 3,0 TO 22,79
               @ 7,2 SAY 'REFRIGERATION/STORAGE CODE'      
               @ 9,12 GET MCODE PICTURE '@!'
               STORE 1 TO MSEL   
               @ 24,01 SAY 'Action: ' + STR(MSEL,1)
               @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
               READ
               @24,09 GET MSEL PICTURE '9' RANGE 1,3
               READ               
            ENDDO
            IF MSEL = 3 .OR. MCODE = SPACE(1)
               MNOT_FIN = .F.
               LOOP
            ENDIF
            SEEK 'D' + MCODE      
            IF .NOT. EOF()
               STORE SUBSTR(DESC,1,8) TO MDESC
            ELSE
               STORE SPACE(8) TO MDESC
            ENDIF
            @ 7,39 SAY 'DESCRIPTION TO BE PRINTED'
            STORE 2 TO MSEL
            DO WHILE MSEL = 2
               @ 9,44 GET MDESC PICTURE '@!'
               STORE 1 TO MSEL
               @ 24,01 SAY 'Action: ' + STR(MSEL,1)
               @ 24,13 SAY '1. Save Update    2. Edit    3. Delete Code & Desc    4. Cancel'
               READ
               @24,09 GET MSEL PICTURE '9' RANGE 1,4
               READ               
            ENDDO
            
            DO CASE
               
            CASE MSEL=1
               IF MCODE <> SPACE(1)
                  SEEK 'D' + MCODE      
                  IF EOF()
                     DO FILELOCK
                     APPEND BLANK
                     REPLACE TYPE WITH 'D'
                     REPLACE CODE WITH MCODE
                     UNLOCK
                  ENDIF
                  DO RECLOCK
                  REPLACE DESC WITH MDESC
                  UNLOCK
                  MCODE = SPACE(1)
               ELSE
                  MNOT_FIN = .F.
               ENDIF
            CASE MSEL = 3 
               SEEK 'D' + MCODE     
               IF .NOT. EOF()
                  DO RECLOCK
                  DELETE
                  UNLOCK
                  @ 23,0 CLEAR
                  STORE 'CODE & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
                  @ 24,5 GET MWAIT
                  READ        
               ENDIF
               MNOT_FIN = .F.
            CASE MSEL = 4
               MNOT_FIN = .F.
               
            ENDCASE
            
         ENDDO
      OTHERWISE
         MTITLE = ' - UPDATE/DELETE PACKAGING DESCRIPTION CATEGORY'
         STORE SPACE(1) TO MCODE     
         MNOT_FIN = .T.
         DO WHILE MNOT_FIN
            STORE 2 TO MSEL
            DO WHILE MSEL = 2
               CLEAR
               @  1, 0 SAY MCOMPANY
               @  1,68 SAY DATE()
               @  2, 0 SAY MPROGRAM + MTITLE
               @ 3,0 TO 22,79
               @ 7,2 SAY 'PACKAGING CODE'      
               @ 9,12 GET MCODE PICTURE '@!'
               STORE 1 TO MSEL   
               @ 24,01 SAY 'Action: ' + STR(MSEL,1)
               @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
               READ
               @24,09 GET MSEL PICTURE '9' RANGE 1,3
               READ               
            ENDDO
            IF MSEL = 3 .OR. MCODE = SPACE(1)
               MNOT_FIN = .F.
               LOOP
            ENDIF
            SEEK 'K' + MCODE      
            IF .NOT. EOF()
               STORE SUBSTR(DESC,1,9) TO MDESC
            ELSE
               STORE SPACE(9) TO MDESC
            ENDIF
            @ 7,39 SAY 'DESCRIPTION TO BE PRINTED'
            STORE 2 TO MSEL
            DO WHILE MSEL = 2
               @ 9,44 GET MDESC PICTURE '@!'
               STORE 1 TO MSEL
               @ 24,01 SAY 'Action: ' + STR(MSEL,1)
               @ 24,13 SAY '1. Save Update    2. Edit    3. Delete Code & Desc    4. Cancel'
               READ
               @24,09 GET MSEL PICTURE '9' RANGE 1,4
               READ               
            ENDDO
            
            DO CASE
               
            CASE MSEL=1
               IF MCODE <> SPACE(1)
                  SEEK 'K' + MCODE      
                  IF EOF()
                     DO FILELOCK
                     APPEND BLANK
                     REPLACE TYPE WITH 'K'
                     REPLACE CODE WITH MCODE
                     UNLOCK
                  ENDIF
                  DO RECLOCK
                  REPLACE DESC WITH MDESC
                  UNLOCK
                  MCODE = SPACE(1)
               ELSE
                  MNOT_FIN = .F.
               ENDIF
            CASE MSEL = 3 
               SEEK 'K' + MCODE     
               IF .NOT. EOF()
                  DO RECLOCK
                  DELETE
                  UNLOCK
                  @ 23,0 CLEAR
                  STORE 'CODE & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
                  @ 24,5 GET MWAIT
                  READ        
               ENDIF
               MNOT_FIN = .F.
            CASE MSEL = 4
               MNOT_FIN = .F.
               
            ENDCASE
            
         ENDDO
      ENDCASE
      CLOSE DATA 
      
   CASE VAL(MSELECTION) = 11    
      *     DO SIZE     
      * Notes...: SIZE DESCRIPTION UPDATE  
      *
      * ---OPEN FILES
      *  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
      SELECT D
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      MTITLE = ' - UPDATE/DELETE SIZE CATEGORY'
      STORE SPACE(5) TO MCODE     
      MNOT_FIN = .T.
      DO WHILE MNOT_FIN
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            @ 7,5 SAY ' SIZE CODE'      
            @ 9,07 GET MCODE PICTURE '@!'
            STORE 1 TO MSEL   
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,3
            READ               
         ENDDO
         IF MSEL = 3 .OR. MCODE = SPACE(5)
            MNOT_FIN = .F.
            LOOP
         ENDIF
         SEEK 'Z' + MCODE      
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,13) TO MDESC
         ELSE
            STORE SPACE(13) TO MDESC
         ENDIF
         @ 7,27 SAY 'DESCRIPTION TO BE PRINTED'
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            @ 9,32 GET MDESC PICTURE '@!'
            STORE 1 TO MSEL
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1. Save Update    2. Edit    3. Delete Code & Desc    4. Cancel'
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,4
            READ               
         ENDDO
         
         DO CASE
            
         CASE MSEL=1
            IF MCODE <> SPACE(5)
               SEEK 'Z' + MCODE      
               IF EOF()
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE TYPE WITH 'Z'
                  REPLACE CODE WITH MCODE
                  UNLOCK
               ENDIF
               DO RECLOCK
               REPLACE DESC WITH MDESC
               UNLOCK
               MCODE = SPACE(5)
            ELSE
               MNOT_FIN = .F.
            ENDIF
         CASE MSEL = 3 
            SEEK 'Z' + MCODE     
            IF .NOT. EOF()
               DO RECLOCK
               DELETE
               UNLOCK
               @ 23,0 CLEAR
               STORE 'CODE & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
               @ 24,5 GET MWAIT
               READ        
            ENDIF
            MNOT_FIN = .F.
         CASE MSEL = 4
            MNOT_FIN = .F.
            
         ENDCASE
         
      ENDDO
      
      CLOSE DATA 
      
   CASE VAL(MSELECTION) =  12    
      *     DO PACK     
      * Notes...: UNIT PACK (BOX SIZES)          
      *
      * ---OPEN FILES
      *  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
      SELECT D
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      MTITLE = ' - UPDATE/DELETE UNIT PACK (BOX SIZE) CATEGORY'
      STORE SPACE(8) TO MCODE     
      MNOT_FIN = .T.
      DO WHILE MNOT_FIN
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            @ 7,2 SAY '     UNIT PACK CODE  '           
            @ 9,09 GET MCODE PICTURE '@!'
            STORE 1 TO MSEL   
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,3
            READ               
         ENDDO
         IF MSEL = 3 .OR. MCODE = SPACE(8)
            MNOT_FIN = .F.
            LOOP
         ENDIF
         SEEK 'S' + MCODE      
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,11) TO MDESC
            STORE BOX_SZ TO MBOX_SZ
         ELSE
            STORE SPACE(11) TO MDESC
            STORE 0 TO MBOX_SZ
         ENDIF
         
         @ 7,34 SAY 'DESCRIPTION TO BE PRINTED'
         @ 7,66 SAY 'BOX WEIGHT'
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            @ 9,42 GET MDESC PICTURE '@!'
            @ 9,70 GET MBOX_SZ PICTURE '###.##' 
            
            STORE 1 TO MSEL
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1. Save Update    2. Edit    3. Delete Code & Desc    4. Cancel'
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,4
            READ               
         ENDDO
         
         DO CASE
            
         CASE MSEL=1
            IF MCODE <> SPACE(2)
               SEEK 'S' + MCODE      
               IF EOF()
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE TYPE WITH 'S'
                  REPLACE CODE WITH MCODE
                  UNLOCK
               ENDIF
               DO RECLOCK
               REPLACE DESC WITH MDESC
               REPLACE BOX_SZ WITH MBOX_SZ
               UNLOCK
               MCODE = SPACE(8)
            ELSE
               MNOT_FIN = .F.
            ENDIF
         CASE MSEL = 3 
            SEEK 'S' + MCODE     
            IF .NOT. EOF()
               DO RECLOCK
               DELETE
               UNLOCK
               @ 23,0 CLEAR
               STORE 'CODE & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
               @ 24,5 GET MWAIT
               READ        
            ENDIF
            MNOT_FIN = .F.
         CASE MSEL = 4
            MNOT_FIN = .F.
            
         ENDCASE
         
      ENDDO
      
      CLOSE DATA 
      
   CASE VAL(MSELECTION) =  13    
      *     DO PRODUCT  
      * Notes...: PRODUCT DESCRIPTION UPDATE  
      *
      * ---OPEN FILES
      *  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
      SELECT D
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      MTITLE = ' - UPDATE/DELETE PRODUCT DESCRIPTION CATEGORY'
      STORE SPACE(6) TO MCODE     
      STORE SPACE(6) TO MBOX_CODE      
      STORE 0 TO MAVG_PURCH
      STORE 0 TO MCASE_PALL
      STORE 'Y' TO MINCLUDE
      MNOT_FIN = .T.
      DO WHILE MNOT_FIN
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            @ 7,2 SAY 'PRODUCT CODE'      
            @ 9,3  GET MCODE PICTURE '@!'
            STORE 1 TO MSEL   
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,3
            READ               
         ENDDO
         IF MSEL = 3 .OR. MCODE = SPACE(6)
            MNOT_FIN = .F.
            LOOP
         ENDIF
         SEEK 'R' + MCODE      
         IF .NOT. EOF()
            STORE DESC TO MDESC
            STORE PROD_CAT TO MPROD_CAT
            STORE BOX_CODE TO MBOX_CODE
            STORE INC_MOSUM TO MINCLUDE
            STORE PROD_RPT  TO MPROD_RPT
            STORE PROD_GRP  TO MPROD_GRP
            STORE AVG_PURCH TO MAVG_PURCH
            STORE CASE_PALL TO MCASE_PALL
         ELSE
            STORE SPACE(25) TO MDESC
            STORE SPACE(1) TO MPROD_CAT
            STORE SPACE(6) TO MBOX_CODE
            STORE 'Y' TO MINCLUDE
            STORE SPACE(10) TO MPROD_RPT, MPROD_GRP
            STORE 0 TO MAVG_PURCH, MCASE_PALL
         ENDIF
         @ 7,20 SAY 'DESCRIPTION TO BE PRINTED    # CASES PER PALLET'

         @ 12,2 SAY '          PRODUCT BOX SIZE/WEIGHT: '
         @ 13,2 SAY '           AVERAGE PURCHASE PRICE: '
         @ 15,2 SAY '  INCLUDE ON MONTHLY REPORT (Y/N): '
         @ 17,2 SAY 'Only Enter the Following if Different from the Acutal Product Code'
         @ 18,2 SAY '      Monthly Report Product Code: '
         @ 19,2 SAY '     Monthly Report Grouping Code: '
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            @ 9,20 GET MDESC PICTURE '@!'
            @ 9,57 GET MCASE_PALL PICTURE '999'
            @ 12,37 GET MBOX_CODE PICTURE '@!'
            @ 13,37 GET MAVG_PURCH PICTURE '##.####'
            @ 15,37 GET MINCLUDE PICTURE '@!' VALID(MINCLUDE = 'Y' .OR. MINCLUDE = 'N')
            @ 18,37 GET MPROD_RPT PICTURE '@!'
            @ 19,37 GET MPROD_GRP PICTURE '@!'

            STORE 1 TO MSEL
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1.Save Update    2.Edit    3.Cancel/Exit    4.Delete Code/Desc'
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,4
            READ               
         ENDDO
         
         DO CASE
            
         CASE MSEL=1
            IF MCODE <> SPACE(10)
               SEEK 'R' + MCODE      
               IF EOF()
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE TYPE WITH 'R'
                  REPLACE CODE WITH MCODE
                  UNLOCK
               ENDIF
               DO RECLOCK
               REPLACE DESC WITH MDESC
               REPLACE PROD_CAT WITH MPROD_CAT
               REPLACE BOX_CODE WITH MBOX_CODE
               REPLACE INC_MOSUM WITH MINCLUDE
               REPLACE PROD_RPT  WITH MPROD_RPT
               REPLACE PROD_GRP  WITH MPROD_GRP
               REPLACE AVG_PURCH WITH MAVG_PURCH
               REPLACE CASE_PALL WITH MCASE_PALL
               UNLOCK
               MCODE = SPACE(10)
            ELSE
               MNOT_FIN = .F.
            ENDIF
         CASE MSEL = 4 
            SEEK 'R' + MCODE     
            IF .NOT. EOF()
               DO RECLOCK
               DELETE
               UNLOCK
               @ 23,0 CLEAR
               STORE 'CODE & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
               @ 24,5 GET MWAIT
               READ        
            ENDIF
            MNOT_FIN = .F.
         CASE MSEL = 3
            MNOT_FIN = .F.
            
         ENDCASE
         
      ENDDO
      
      CLOSE DATA 
      
   CASE VAL(MSELECTION) =  14
      * Notes...: QMASTER INVENTORY PULL RULES

      SELECT D
      DO FOX_USE WITH "&MDBFLOC.QMASTER INDEX &MDBFLOC.QMASTER", .F.
      
      MTITLE = ' - UPDATE/DELETE Q-HOLD MASTER - INVN PULL RULES'
      MCODE = ' '                 
      MNOT_FIN = .T.
      DO WHILE MNOT_FIN
         STORE 2 TO MSEL
         STORE SPACE(32) TO MFREEZ_LOC, MBUY_NAME
         STORE SPACE(10) TO MPROD_DESC
         STORE 0 TO MBEG_JULYR, MBEG_JULDY, MEND_JULYR, MEND_JULDY

         DO WHILE MSEL = 2
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            @ 6,2 SAY  '     Freezer Location: '
            @ 8,2 say  '         Product Code: '
            @ 10,2 say 'Ship To Customer Name: '
            @ 12,2 say 'Begin  Production Julian Date:    /'
            @ 14,2 say 'Ending Production Julian DAte:    /'
            @ 6,25 GET MFREEZ_LOC PICTURE '@!'
            @ 8,25 GET MPROD_DESC PICTURE '@!'
            @ 10,25 GET MBUY_NAME PICTURE '@!'
            @ 12,33 GET MBEG_JULYR PICTURE '999'
            @ 12,37 GET MBEG_JULDY PICTURE '99'
            @ 14,33 GET MEND_JULYR PICTURE '999'
            @ 14,37 GET MEND_JULDY PICTURE '99'
            STORE 1 TO MSEL   
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,3
            READ               
         ENDDO
         IF MSEL = 3 .OR. MCODE = ' '       
            MNOT_FIN = .F.
            LOOP
         ENDIF
         SEEK 'M' + MCODE      
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,20) TO MDESC
         ELSE
            STORE SPACE(20) TO MDESC
         ENDIF
         @ 7,39 SAY 'DESCRIPTION'
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            @ 9,39 GET MDESC PICTURE '@!'
            STORE 1 TO MSEL
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1. Save Update    2. Edit    3. Delete Code & Desc    4. Cancel'
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,4
            READ               
         ENDDO
         
         DO CASE
            
         CASE MSEL=1
            IF MCODE <> ' '     
               SEEK 'M' + MCODE      
               IF EOF()
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE TYPE WITH 'M'
                  REPLACE CODE WITH MCODE
                  UNLOCK
               ENDIF
               DO RECLOCK
               REPLACE DESC WITH MDESC
               UNLOCK
               MCODE = ' '      
            ELSE
               MNOT_FIN = .F.
            ENDIF
         CASE MSEL = 3 
            SEEK 'M' + MCODE     
            IF .NOT. EOF()
               DO RECLOCK
               DELETE
               UNLOCK
               @ 23,0 CLEAR
               STORE 'CODE & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
               @ 24,5 GET MWAIT
               READ        
            ENDIF
            MNOT_FIN = .F.
         CASE MSEL = 4
            MNOT_FIN = .F.
            
         ENDCASE
         
      ENDDO
      
      CLOSE DATA 
      
   CASE VAL(MSELECTION) =  15
      * Notes...: ADD/UPDATE CHART OF ACCOUNTS     
      *
      * ---OPEN FILES
      *  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
      SELECT D
      DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
      MTITLE = ' - ADD/UPDATE/DELETE CHART OF ACCOUNTS'
      MNOT_FIN = .T.
      DO WHILE MNOT_FIN
         STORE SPACE(4) TO MACCOUNT 
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            @ 7,2 SAY '    ACCOUNT NUMBER:'      
            @ 7,22 GET MACCOUNT PICTURE '####'
            STORE 1 TO MSEL   
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,3
            READ               
         ENDDO
         IF MSEL = 3 .OR. MACCOUNT = SPACE(4)
            MNOT_FIN = .F.
            LOOP
         ENDIF
         SEEK MACCOUNT
         IF .NOT. EOF()
            STORE DESCRIP TO MDESCRIP
            STORE CK_DESC TO MCK_DESC
         ELSE
            STORE SPACE(25) TO MDESCRIP, MCK_DESC
         ENDIF
         @ 9,2 SAY 'OFFICE DESCRIPTION:'
         @ 11,2 SAY ' CHECK DESCRIPTION:'
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            @ 9,22 GET MDESCRIP PICTURE '@!'
            @ 11,22 GET MCK_DESC PICTURE '@!'
            STORE 1 TO MSEL
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1. Save Update    2. Edit    3. Delete Account Desc    4. Cancel'
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,4
            READ               
         ENDDO
         
         DO CASE
            
         CASE MSEL=1
            IF MACCOUNT <> SPACE(4)
               SEEK MACCOUNT
               IF EOF()
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE ACCOUNT WITH MACCOUNT
                  UNLOCK
               ENDIF
               DO RECLOCK
               REPLACE DESCRIP WITH MDESCRIP
               REPLACE CK_DESC WITH MCK_DESC
               UNLOCK
            ELSE
               MNOT_FIN = .F.
            ENDIF
         CASE MSEL = 3 
            SEEK MACCOUNT  
            IF .NOT. EOF()
               DO RECLOCK
               DELETE
               UNLOCK
               @ 23,0 CLEAR
               STORE 'ACCOUNT & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
               @ 24,5 GET MWAIT
               READ        
            ENDIF
            MNOT_FIN = .F.
         CASE MSEL = 4
            MNOT_FIN = .F.
            
         ENDCASE
         
      ENDDO
      
      * EOF: ACCOUNTS.PRG
      
   CASE VAL(MSELECTION) =  16
      *** DON'T DO VENDOR CODES ANYMORE- DO BROKERS/BILLBACKS BY CUST
      MVENDOR = .F.
      IF MVENDOR
         *** VENDOR PRODUCT CODES
         SELECT D
         DO FOX_USE WITH "&MDBFLOC.SUP_PROD INDEX &MDBFLOC.SUP_PROD", .F.
         
         MTITLE = ' - UPDATE/DELETE VENDOR PRODUCT CODES/DESCRIPTION'  
         STORE SPACE(2) TO MSUP_PREFX
         STORE SPACE(10) TO MSUP_PCODE     
         MNOT_FIN = .T.
         DO WHILE MNOT_FIN
            STORE 2 TO MSEL
            DO WHILE MSEL = 2
               CLEAR
               @  1, 0 SAY MCOMPANY
               @  1,68 SAY DATE()
               @  2, 0 SAY MPROGRAM + MTITLE
               @ 3,0 TO 22,79
               @ 6,2 SAY ' VENDOR        VENDOR'
               @ 7,2 SAY ' PREFIX     PRODUCT CODE  '
               @ 8,5 GET MSUP_PREFX PICTURE '@!'
               @ 8,15 GET MSUP_PCODE PICTURE '@!'
               STORE 1 TO MSEL   
               @ 24,01 SAY 'Action: ' + STR(MSEL,1)
               @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
               READ
               @24,09 GET MSEL PICTURE '9' RANGE 1,3
               READ               
            ENDDO
            IF MSEL = 3 .OR. MSUP_PCODE = SPACE(10)
               MNOT_FIN = .F.
               LOOP
            ENDIF
            SEEK MSUP_PREFX + MSUP_PCODE
            IF .NOT. EOF()
               STORE DESCRIP TO MDESCRIP
               STORE FRH_FRZ TO MFRH_FRZ 
               STORE GRADE   TO MGRADE
               STORE SUBSTR(PACKAGED,1,1) TO MPAK1     
               STORE SUBSTR(PACKAGED,2) TO MPAK2     
               STORE PROD_DESC TO MPROD_DESC
               STORE SIZE     TO MSIZE
               STORE PACKED   TO MPACKED
               STORE BOX_SZ   TO MBOX_SZ
            ELSE
               STORE SPACE(45) TO MDESCRIP
               STORE SPACE(2) TO MFRH_FRZ 
               STORE SPACE(1) TO MGRADE
               STORE SPACE(1) TO MPAK1 
               STORE SPACE(1) TO MPAK2 
               STORE SPACE(4) TO MPROD_DESC
               STORE SPACE(5) TO MSIZE
               STORE SPACE(8) TO MPACKED
               STORE 0        TO MBOX_SZ
            ENDIF
            @ 6,30 SAY '           VENDOR'
            @ 7,30 SAY 'PRODUCT DESCRIPTION:'   
            @ 8,30 GET MDESCRIP PICTURE '@!'
            @ 10,1 TO 10,78
            @ 11,3 SAY 'MIDWEST CORRESPONDING PRODUCT INFORMATION'
            @ 13,3 SAY '      PRODUCT NATURE (FRESH/FROZEN):'
            @ 14,3 SAY 'PROCESS TYPE (SMOKED,MARINATED,ETC):'
            @ 15,3 SAY '              REFRIGERATION/STORAGE: '   
            @ 16,3 SAY '              PACKAGING DESCRIPTION:'
            @ 17,3 SAY '                       PRODUCT SIZE: '
            @ 18,3 SAY '                          UNIT PACK:'                    
            @ 19,3 SAY '                         BOX WEIGHT: '
            @ 20,3 SAY '               MIDWEST PRODUCT CODE: '
            STORE 2 TO MSEL
            DO WHILE MSEL = 2
               @ 8,30 GET MDESCRIP PICTURE '@!'
               @ 13,42 GET MFRH_FRZ PICTURE '@!'
               @ 14,42 GET MGRADE PICTURE '@!'
               @ 15,42 GET MPAK1 PICTURE '@!'
               @ 16,42 GET MPAK2 PICTURE '@!'
               @ 17,42 GET MSIZE PICTURE '@!'
               @ 18,42 GET MPACKED PICTURE '@!'
               @ 19,42 GET MBOX_SZ PICTURE '99999'
               @ 20,42 GET MPROD_DESC PICTURE '@!'
               STORE 1 TO MSEL
               @ 24,01 SAY 'Action: ' + STR(MSEL,1)
               @ 24,13 SAY '1. Save Update    2. Edit    3. Delete Code & Desc    4. Cancel'
               READ
               @24,09 GET MSEL PICTURE '9' RANGE 1,4
               READ               
            ENDDO
            
            DO CASE
               
            CASE MSEL=1
               IF MSUP_PCODE <> SPACE(10)
                  SEEK MSUP_PREFX + MSUP_PCODE
                  IF EOF()
                     DO FILELOCK
                     APPEND BLANK
                     REPLACE SUP_PREFX WITH MSUP_PREFX
                     REPLACE SUP_PCODE WITH MSUP_PCODE
                     UNLOCK
                  ENDIF
                  DO RECLOCK
                  REPLACE DESCRIP WITH MDESCRIP
                  REPLACE FRH_FRZ WITH MFRH_FRZ 
                  REPLACE GRADE   WITH MGRADE
                  REPLACE PACKAGED WITH  MPAK1 + MPAK2
                  REPLACE PROD_DESC WITH MPROD_DESC
                  REPLACE SIZE     WITH MSIZE
                  REPLACE PACKED   WITH MPACKED
                  REPLACE BOX_SZ   WITH MBOX_SZ
                  UNLOCK
                  MSUP_PCODE = SPACE(10)
                  MSUP_PREFX = SPACE(2)
               ELSE
                  MNOT_FIN = .F.
               ENDIF
            CASE MSEL = 3 
               SEEK MSUP_PREFX + MSUP_PCODE
               IF .NOT. EOF()
                  DO RECLOCK
                  DELETE
                  UNLOCK
                  @ 23,0 CLEAR
                  STORE 'CODE & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
                  @ 24,5 GET MWAIT
                  READ        
               ENDIF
               MNOT_FIN = .F.
            CASE MSEL = 4
               MNOT_FIN = .F.
               
            ENDCASE
         ENDDO
      ELSE
         *** NOW DO BROKERS/BILLBACKS         
         SELECT D
         DO FOX_USE WITH "&MDBFLOC.CUSTCOMM INDEX &MDBFLOC.CUSTCOMM", .F.
         
         MTITLE = ' - UPDATE/DELETE CUSTOMER BROKERS/BILLBACKS'
         
         MNOT_FIN = .T.

         DO WHILE MNOT_FIN
            STORE SPACE(32) TO MCOMM_NM1, MCOMM_NM2, MCOMM_NM3
            STORE SPACE(32) TO MBILL_NM1, MBILL_NM2, MBILL_NM3
            STORE SPACE(32) TO MBBUYNAME
            STORE 2 TO MSEL
            DO WHILE MSEL = 2
               CLEAR
               @  1, 0 SAY MCOMPANY
               @  1,68 SAY DATE()
               @  2, 0 SAY MPROGRAM + MTITLE
               @ 3,0 TO 22,79
               @ 5,2 SAY 'SELECT BILL TO CUSTOMER:'
               @ 7,2 GET MBBUYNAME PICTURE '@!'
               STORE 1 TO MSEL
               @ 24,01 SAY 'Action: ' + STR(MSEL,1)
               @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
               READ
               @24,09 GET MSEL PICTURE '9' RANGE 1,3
               READ               
            ENDDO
            IF MSEL = 3 .OR. MBBUYNAME = SPACE(32)
               MNOT_FIN = .F.
               LOOP
            ENDIF
            
            STORE MBBUYNAME TO MNAME
            MNAME_FD = .F.
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
            DO BBUYSEL2
            IF .NOT. MNAME_FD .OR. MACTION = 3
               LOOP
            ENDIF
            STORE BBUYCODE TO MBBUYCODE
            @ 7,2 SAY NAME
            @ 8,2 SAY STREET
            @ 9,2 SAY TRIM(CITY) + ', ' + STATE + '  ' + ZIP
            
            @ 13,2 SAY '   BROKERS                              PROGRAMS/BILLBACKS'
            @ 15,2 SAY '1.                                   1.'
            @ 16,2 SAY '2.                                   2.'
            @ 17,2 SAY '3.                                   3.'
            *** SEE WHO IS ON FILE ALREADY            
            SELECT D
            SEEK MBBUYCODE
            IF EOF()
               STORE SPACE(2) TO MCOMM_CD1, MCOMM_CD2, MCOMM_CD3
               STORE SPACE(2) TO MBILL_CD1, MBILL_CD2, MBILL_CD3
            ELSE
               STORE CUSTCOMM1 TO MCOMM_CD1
               STORE CUSTCOMM2 TO MCOMM_CD2
               STORE CUSTCOMM3 TO MCOMM_CD3
               STORE CUSTBILL1 TO MBILL_CD1
               STORE CUSTBILL2 TO MBILL_CD2
               STORE CUSTBILL3 TO MBILL_CD3
            ENDIF

            SELECT E
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
            IF MCOMM_CD1 <> SPACE(2)
               SEEK MCOMM_CD1
               IF .NOT. EOF()
                  STORE NAME TO MCOMM_NM1
               ENDIF
            ENDIF
            IF MCOMM_CD2 <> SPACE(2)
               SEEK MCOMM_CD2
               IF .NOT. EOF()
                  STORE NAME TO MCOMM_NM2
               ENDIF
            ENDIF
            IF MCOMM_CD3 <> SPACE(2)
               SEEK MCOMM_CD3
               IF .NOT. EOF()
                  STORE NAME TO MCOMM_NM3
               ENDIF
            ENDIF

            IF MBILL_CD1 <> SPACE(2)
               SEEK MBILL_CD1
               IF .NOT. EOF()
                  STORE NAME TO MBILL_NM1
               ENDIF
            ENDIF
            IF MBILL_CD2 <> SPACE(2)
               SEEK MBILL_CD2
               IF .NOT. EOF()
                  STORE NAME TO MBILL_NM2
               ENDIF
            ENDIF
            IF MBILL_CD3 <> SPACE(2)
               SEEK MBILL_CD3
               IF .NOT. EOF()
                  STORE NAME TO MBILL_NM3
               ENDIF
            ENDIF
            USE

            STORE 2 TO MSEL
            DO WHILE MSEL = 2
               
               @ 15,5 GET MCOMM_NM1 PICTURE '@!'
               @ 16,5 GET MCOMM_NM2 PICTURE '@!'
               @ 17,5 GET MCOMM_NM3 PICTURE '@!'
               @ 15,42 GET MBILL_NM1 PICTURE '@!'
               @ 16,42 GET MBILL_NM2 PICTURE '@!'
               @ 17,42 GET MBILL_NM3 PICTURE '@!'
               
               STORE 1 TO MSEL
               @ 24,01 SAY 'Action: ' + STR(MSEL,1)
               @ 24,13 SAY '1. Save/Update    2. Edit    3. Cancel'
               READ

               SELECT E
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
               
               IF MCOMM_NM1 <> SPACE(32)
                  STORE TRIM(MCOMM_NM1) TO SRCH_ARG
                  MBB_FD = .F.
                  DO BB_SEL2
                  IF MBB_FD
                     STORE NAME TO MCOMM_NM1
                     STORE COM_CODE TO MCOMM_CD1
                  ELSE
                     STORE SPACE(32) TO MCOMM_NM1
                     STORE SPACE(2)  TO MCOMM_CD1
                  ENDIF
               ELSE
                  STORE SPACE(32) TO MCOMM_NM1
                  STORE SPACE(2)  TO MCOMM_CD1
               ENDIF
               
               IF MCOMM_NM2 <> SPACE(32)
                  STORE TRIM(MCOMM_NM2) TO SRCH_ARG
                  MBB_FD = .F.
                  DO BB_SEL2
                  IF MBB_FD
                     STORE NAME TO MCOMM_NM2
                     STORE COM_CODE TO MCOMM_CD2
                  ELSE
                     STORE SPACE(32) TO MCOMM_NM2 
                     STORE SPACE(2)  TO MCOMM_CD2
                  ENDIF
               ELSE
                  STORE SPACE(32) TO MCOMM_NM2 
                  STORE SPACE(2)  TO MCOMM_CD2
               ENDIF
               
               IF MCOMM_NM3 <> SPACE(32)
                  STORE TRIM(MCOMM_NM3) TO SRCH_ARG
                  MBB_FD = .F.
                  DO BB_SEL2
                  IF MBB_FD
                     STORE NAME TO MCOMM_NM3
                     STORE COM_CODE TO MCOMM_CD3
                  ELSE
                     STORE SPACE(32) TO MCOMM_NM3 
                     STORE SPACE(2)  TO MCOMM_CD3
                  ENDIF
               ELSE
                  STORE SPACE(32) TO MCOMM_NM3 
                  STORE SPACE(2)  TO MCOMM_CD3
               ENDIF
               
               IF MBILL_NM1 <> SPACE(32)
                  STORE TRIM(MBILL_NM1) TO SRCH_ARG
                  MBB_FD = .F.
                  DO BB_SEL2
                  IF MBB_FD
                     STORE NAME TO MBILL_NM1
                     STORE COM_CODE TO MBILL_CD1
                  ELSE
                     STORE SPACE(32) TO MBILL_NM1
                     STORE SPACE(2)  TO MBILL_CD1
                  ENDIF
               ELSE
                  STORE SPACE(32) TO MBILL_NM1
                  STORE SPACE(2)  TO MBILL_CD1
               ENDIF
               
               IF MBILL_NM2 <> SPACE(32)
                  STORE TRIM(MBILL_NM2) TO SRCH_ARG
                  MBB_FD = .F.
                  DO BB_SEL2
                  IF MBB_FD
                     STORE NAME TO MBILL_NM2
                     STORE COM_CODE TO MBILL_CD2
                  ELSE
                     STORE SPACE(32) TO MBILL_NM2 
                     STORE SPACE(2)  TO MBILL_CD2
                  ENDIF
               ELSE
                  STORE SPACE(32) TO MBILL_NM2 
                  STORE SPACE(2)  TO MBILL_CD2
               ENDIF
               
               IF MBILL_NM3 <> SPACE(32)
                  STORE TRIM(MBILL_NM3) TO SRCH_ARG
                  MBB_FD = .F.
                  DO BB_SEL2
                  IF MBB_FD
                     STORE NAME TO MBILL_NM3
                     STORE COM_CODE TO MBILL_CD3
                  ELSE
                     STORE SPACE(32) TO MBILL_NM3 
                     STORE SPACE(2)  TO MBILL_CD3
                  ENDIF
               ELSE
                  STORE SPACE(32) TO MBILL_NM3 
                  STORE SPACE(2)  TO MBILL_CD3
               ENDIF

               @ 15,5 SAY MCOMM_NM1 PICTURE '@!'
               @ 16,5 SAY MCOMM_NM2 PICTURE '@!'
               @ 17,5 SAY MCOMM_NM3 PICTURE '@!'
               @ 15,42 SAY MBILL_NM1 PICTURE '@!'
               @ 16,42 SAY MBILL_NM2 PICTURE '@!'
               @ 17,42 SAY MBILL_NM3 PICTURE '@!'

               @24,09 GET MSEL PICTURE '9' RANGE 1,3
               READ               
            ENDDO
            
            DO CASE
               
            CASE MSEL=1
               
               SELECT D
               SEEK MBBUYCODE
               IF EOF()
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE BBUYCODE WITH MBBUYCODE
                  UNLOCK
               ENDIF
               DO RECLOCK
               REPLACE CUSTCOMM1 WITH MCOMM_CD1
               REPLACE CUSTCOMM2 WITH MCOMM_CD2
               REPLACE CUSTCOMM3 WITH MCOMM_CD3
               REPLACE CUSTBILL1 WITH MBILL_CD1
               REPLACE CUSTBILL2 WITH MBILL_CD2
               REPLACE CUSTBILL3 WITH MBILL_CD3
               UNLOCK
               
            CASE MSEL = 3
               MNOT_FIN = .F.
               
            ENDCASE
         ENDDO
      ENDIF
      
      
      CLOSE DATA
      
   CASE VAL(MSELECTION) =  17
      *** BROKERAGE FEES FOR 3RD PARTY COMM
      SELECT D
      DO FOX_USE WITH "&MMASTDBF.BROK_FEE INDEX &MMASTDBF.BROK_FEE", .F.
      
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
      
      MTITLE = ' - UPDATE/DELETE BROKERAGE FEES FOR 3RD PARTY COMM'  
      STORE SPACE(32) TO MCOM_NAME
      STORE SPACE(6) TO MPROD_CODE  
      MNOT_FIN = .T.
      
      DO WHILE MNOT_FIN
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            CLEAR
            @  1, 0 SAY MCOMPANY
            @  1,68 SAY DATE()
            @  2, 0 SAY MPROGRAM + MTITLE
            @ 3,0 TO 22,79
            @ 6,2 SAY '3RD PARTY NAME                       PRODUCT    BROK FEE'
            @ 8,2  GET MCOM_NAME PICTURE '@!'
            @ 8,39 GET MPROD_CODE  PICTURE '@!'
            STORE 1 TO MSEL
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'
            READ
            @24,09 GET MSEL PICTURE '9' RANGE 1,3
            READ               
         ENDDO
         IF MSEL = 3 .OR. MCOM_NAME = SPACE(32) .OR. MPROD_CODE = SPACE(6)
            MNOT_FIN = .F.
            LOOP
         ENDIF
         
         *** GET THE RIGHT COMMISSION PAYEE
         SELECT E
         MCOM_FD = .F.
         STORE TRIM(MCOM_NAME) TO SRCH_ARG
         DO COM_SEL2

         IF .NOT. MCOM_FD
            LOOP
         ELSE
            STORE NAME TO MCOM_NAME
            STORE COM_CODE TO MCOM_CODE
         ENDIF
         
         @  8,2 SAY MCOM_NAME
         
         SELECT D
         SEEK MCOM_CODE + MPROD_CODE
         IF .NOT. EOF()
            STORE BROK_FEE TO MBROK_FEE
            MONFILE = .T.
         ELSE
            STORE 0 TO MBROK_FEE
            MONFILE = .F.
         ENDIF
         
         STORE 2 TO MSEL
         DO WHILE MSEL = 2
            @ 8,52 GET MBROK_FEE PICTURE '99.9999'
            
            STORE 1 TO MSEL
            @ 24,01 SAY 'Action: ' + STR(MSEL,1)
            IF MONFILE
               @ 24,13 SAY '1. Save Update    2. Edit    3. Cancel    4. Delete Code & Desc'
            ELSE
               @ 24,13 SAY '1. Add Rcd/Save   2. Edit    3. Cancel'
            ENDIF
            READ
            IF MONFILE
               @24,09 GET MSEL PICTURE '9' RANGE 1,4
            ELSE
               @ 24,09 GET MSEL PICTURE '9' RANGE 1,3
            ENDIF
            READ
         ENDDO
         
         DO CASE
            
         CASE MSEL = 3
            LOOP
            
         CASE MSEL=1
            IF .NOT. MONFILE
               DO FILELOCK
               APPEND BLANK
               REPLACE COM_CODE WITH MCOM_CODE
               REPLACE PROD_CODE WITH MPROD_CODE
               UNLOCK
            ENDIF
            DO RECLOCK
            REPLACE BROK_FEE WITH MBROK_FEE
            UNLOCK
            MPROD_CODE = SPACE(6)
            
         CASE MSEL = 4
            DO RECLOCK
            DELETE
            UNLOCK
            @ 24,0 CLEAR
            STORE 'CODE & DESCRIPTION DELETED - PRESS RETURN TO CONTINUE' TO MWAIT
            @ 24,5 GET MWAIT
            READ        
            MPROD_CODE = SPACE(6)
            
         ENDCASE
      ENDDO
      CLOSE DATA 
   CASE VAL(MSELECTION) =  18
      DO NATLMAST
      CLOSE DATA
   CASE VAL(MSELECTION) =  19
      DO CUSTMAST
      CLOSE DATA
   
   ENDCASE
   CLOSE DATA
   
ENDDO

RETURN

* EOF: MAINT.PRG
*Formatted by: ToolBox Ver. 1.2  on 2/21/6 at 10:12 AM.
