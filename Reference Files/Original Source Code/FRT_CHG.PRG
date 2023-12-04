**************
* Program.: FRT_CHG.PRG
* Author..: Grace Keller
* Date....: 10/20/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: FREIGHT EDIT
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT B
STORE FRT_CODE1 TO SFRT_CODE1
SET PROC TO FRT_PROC

STORE FRT_CODE1 TO MFRT_CODE1
STORE FRT_AMT1 TO MFRT_AMT1, OFRT_AMT1
STORE FRT1_ADJ1 TO MFRT1_ADJ1, OFRT1_ADJ1
STORE FRT1_ADJ2 TO MFRT1_ADJ2, OFRT1_ADJ2
STORE FRT1_RS1 TO MFRT1_RS1
STORE FRT1_RS2 TO MFRT1_RS2
STORE FRT_PALL TO MFRT_PALL, SFRT_PALL
STORE REF_PO3  TO MREF_PO3
STORE REF_PO4  TO MREF_PO4
STORE REF_PO5  TO MREF_PO5
STORE REF_PO6  TO MREF_PO6
SELECT A
DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE, &MDBFLOC.FRT_NAME", .F.
DO CASE
CASE MFRT_CODE1 = 'NONE'
   STORE 'NONE' + SPACE(28) TO MFRT_NAME1, MFSV1_NAME
CASE MFRT_CODE1 = 'CUST'
   STORE 'CUSTOMER PICK UP' + SPACE(16) TO MFRT_NAME1, MFSV1_NAME
CASE MFRT_CODE1 = SPACE(4)
   STORE SPACE(32) TO mFRT_NAME1, MFSV1_NAME
OTHERWISE     
   SEEK MFRT_CODE1
   IF .NOT. EOF()
      STORE NAME TO MFRT_NAME1, MFSV1_NAME
      STORE STREET TO MFRT_STRT1
      STORE CITY TO MFRT_CITY1
      STORE STATE TO MFRT_ST1   
      STORE ZIP TO MZIP1
      STORE ZIP4 TO MZIP4_1
   ELSE
      STORE 'FREIGHT CARRIER NOT ON FILE     ' TO MFRT_NAME1, MFSV1_NAME
   ENDIF
ENDCASE
IF MFRT_CODE1 <> 'NONE' .AND. MFRT_CODE1 <> SPACE(4) .AND. MFRT_CODE1 <> 'CUST' .AND. MFRT_NAME1 <> 'FREIGHT CARRIER NOT ON FILE'
   *  @ 6,5 SAY MFRT_STRT1
   IF MZIP4_1 = SPACE(4)
      STORE MZIP1 TO MZIP
   ELSE
      STORE MZIP1 + '-' + MZIP4_1 TO MZIP
   ENDIF
   @ 06,5 SAY TRIM(MFRT_CITY1) + ', ' + MFRT_ST1 + '  ' + MZIP
ENDIF

MFRT_DONE = .T.
DO WHILE MFRT_DONE
   STORE 1 TO MACTION
   mfrt_sel1 = .T.
   DO WHILE mfrt_sel1
      
      @ 2,0 CLEAR
      MTITLE = ' - PURCHASE ORDER FREIGHT CARRIER'
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      @  4, 5 SAY 'FREIGHT CARRIER:'     
      @  5, 5 GET Mfrt_name1 PICTURE '@!'
      @ 13,1 TO 13,78
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue     2. Edit      3. Previous Pg.'
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      DO CASE
      CASE MACTION = 1 .OR. MACTION = 3
         DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
         IF MFRT_NAME1= 'NONE' .OR. MFRT_NAME1 = 'CUST'
            STORE MFRT_NAME1 TO MFRT_CODE1
            STORE 0 TO MFRT_AMT1, MFRT1_ADJ1, MFRT1_ADJ2, MFRT_PALL
            MFRT_SEL1 = .F.
            LOOP
         ENDIF
         IF MFRT_NAME1 =  SPACE(32)
            @ 24,0 CLEAR
            STORE 'NO FREIGHT CARRIER NAME ENTERED - PRESS RETURN TO REENTER' TO MWAIT
            @ 24,5  GET MWAIT 
            READ
            @ 24,0 CLEAR
            LOOP
         ENDIF     
         
         IF MFRT_NAME1 <> MFSV1_NAME
            STORE TRIM(MFRT_NAME1) TO SRCH_ARG
            SEEK SRCH_ARG
            IF EOF() .OR. DELETED()
               @ 23,0 CLEAR
               STORE ' ' TO MSPACE 
               STORE 'N' TO MYES_NO
               *@ 24,10 SAY 'FREIGHT CARRIER NOT NOT FOUND - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
               *READ
               IF MYES_NO = 'Y'
                  @ 24,0 clear
                  SAVE SCREEN TO MFRT_SAVE
                  MINIT_NM = .F.
                  DO FRT_ADD
                  RESTORE SCREEN FROM MFRT_SAVE
                  IF MACTION = 3  
                     LOOP
                  ENDIF
                  STORE NAME TO MFRT_NAME1
                  STORE STREET TO MFRT_STRT1
                  STORE CITY TO MFRT_CITY1
                  STORE STATE TO MFRT_ST1   
                  STORE ZIP TO MZIP1
                  STORE ZIP4 TO MZIP4_1
                  STORE FRT_CODE TO MFRT_CODE1
               ELSE
                  @ 24,0 CLEAR
                  STORE 'FREIGHT CARRIER MUST BE ON FILE - PRESS RETURN TO REENTER' TO MWAIT
                  @ 24,5 GET MWAIT
                  READ
                  @ 24,0 CLEAR
                  LOOP
               ENDIF
            ELSE               
               STORE RECNO() TO MFST_REC
               SKIP
               IF NAME = SRCH_ARG
                  MADD = .F.
                  SAVE SCREEN TO MFRT_SAVE
                  DO MULTFRT
                  RESTORE SCREEN FROM MFRT_SAVE
                  IF MACTION = 5
                     @ 24,0 CLEAR
                     STORE 'FREIGHT CARRIER MUST BE ON FILE - PRESS RETURN TO REENTER' TO MWAIT
                     @ 24,5 GET MWAIT
                     READ
                     @ 24,0 CLEAR
                     LOOP
                  ENDIF
                  STORE NAME TO MFRT_NAME1
                  STORE STREET TO MFRT_STRT1
                  STORE CITY TO MFRT_CITY1
                  STORE STATE TO MFRT_ST1   
                  STORE ZIP TO MZIP1
                  STORE ZIP4 TO MZIP4_1
                  STORE FRT_CODE TO MFRT_CODE1
                  MFRT_SEL1 = .F.
                  MNAME_FD = .T.
                  LOOP
               ELSE
                  GOTO MFST_REC
                  
                  STORE NAME TO MFRT_NAME1
                  STORE STREET TO MFRT_STRT1
                  STORE CITY TO MFRT_CITY1
                  STORE STATE TO MFRT_ST1   
                  STORE ZIP TO MZIP1
                  STORE ZIP4 TO MZIP4_1
                  STORE FRT_CODE TO MFRT_CODE1
                  MFRT_SEL1 = .F.
                  MNAME_FD = .T.
                  LOOP
               ENDIF
            ENDIF
         ENDIF
         
         MFRT_SEL1 = .F.
         LOOP
      CASE MACTION = 2
         LOOP
         
      ENDCASE
      
   ENDDO
   
   IF MFRT_NAME1 = 'NONE' .OR. MFRT_NAME1 = 'CUST'
      IF MACTION = 3
         MGOTO_PG = 3
      ELSE
         MGOTO_PG = 5
      ENDIF
      MFRT_DONE = .F.
      LOOP
   ENDIF
   
   @ 5,5 SAY MFRT_NAME1
   *  @ 6,5 SAY MFRT_STRT1
   IF MZIP4_1 = SPACE(4)
      STORE MZIP1 TO MZIP
   ELSE
      STORE MZIP1 + '-' + MZIP4_1 TO MZIP
   ENDIF
   @ 06,5 SAY TRIM(MFRT_CITY1) + ', ' + MFRT_ST1 + '  ' + MZIP
   
   MEDIT = .T.
   DO WHILE MEDIT
      
      @ 7 ,40 SAY 'SPLIT FRT PO NBRS:'  
      @ 08,5 SAY 'FREIGHT AMOUNT:'
      @ 10,2 SAY '1. ADJUSTMENT AMT:'
      @ 10,40 SAY 'REASON:'
      @ 11,2 SAY '2. ADJUSTMENT AMT:'
      @ 11,40 SAY 'REASON:'
      @ 12,2 SAY 'PALLET ADJUSTMENT:'
      @ 08,21 GET MFRT_AMT1 PICTURE '999999.99'

      @ 6,59 GET MREF_PO1 PICTURE '@!'
      @ 6,70 GET MREF_PO2 PICTURE '@!'
      @ 7,59 GET MREF_PO3 PICTURE '@!'
      @ 7,70 GET MREF_PO4 PICTURE '@!'
      @ 8,59 GET MREF_PO5 PICTURE '@!'
      @ 8,70 GET MREF_PO6 PICTURE '@!'

      @ 10,21 GET MFRT1_ADJ1 PICTURE '99999.99'
      @ 10,48 GET MFRT1_RS1 PICTURE '@!'
      @ 11,21 GET MFRT1_ADJ2 PICTURE '99999.99'
      @ 11,48 GET MFRT1_RS2 PICTURE '@!'
      @ 12,21 GET MFRT_PALL PICTURE '99999.99'
      STORE 1 TO MACTION
      @ 24,0 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Previous Pg.'
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 2
         LOOP
      ENDIF
      IF MFRT_PALL > 0
         @ 24,0 CLEAR
         mwait = ' '
         @ 24,1 say 'Pallets should be deducted - Enter "E" TO Edit or "C" to Continue: ' get mwait picture '@!' valid(mwait = 'C' .or. mwait = 'E')
         read
         @ 24,0 clear
         if mwait = 'E'
            loop
         endif
      endif

      MEDIT = .F.
   ENDDO
   *** IF CHANGING FROM 'NONE' TO SOMETHING - MARK UNPAID
   IF SFRT_CODE1 = 'NONE' .AND. MFRT_CODE1 <> 'NONE'
      IF B->FRT_PD <> ' '
         SELECT B
         DO FILELOCK
         REPLACE FRT_PD WITH ' '
         UNLOCK
      ENDIF
   ENDIF
   
   *** IF FREIGHT BILL IS PAID - PUT OUT ADJUSTMENTS 
   IF B->FRT_PD <> ' '
      
      IF MFRT_AMT1 <> OFRT_AMT1 .OR. MFRT1_ADJ1 <> OFRT1_ADJ1 .OR. MFRT1_ADJ2 <> OFRT1_ADJ2 .OR. MFRT_PALL <> SFRT_PALL
         STORE SPACE(12) TO MFRT_INV
         SELECT A
         DO FOX_USE WITH "DISBJRN INDEX DISB_PO", .F.
         SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX + 'F'
         DO WHILE .NOT. EOF() .AND. SALESMAN = B->SALESMAN .AND. PO_NBR = B->PO_NBR .AND. PO_SUFFIX = B->PO_SUFFIX .AND. ACCT_TYPE = 'F'
            IF B->FRT_CODE1 = ACCT_NBR
               STORE BILL_INV TO MFRT_INV
            ENDIF
            SKIP
         ENDDO
      ENDIF
      
      SELECT A
      DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
      IF MFRT_AMT1 <> OFRT_AMT1
         DO FILELOCK
         APPEND BLANK
         REPLACE salesman   WITH Msalesman  
         REPLACE po_nbr     WITH Mpo_nbr    
         REPLACE po_suffix  WITH Mpo_suffix 
         REPLACE FRT_CODE   WITH B->FRT_CODE1 
         REPLACE AMT_DUE   WITH MFRT_AMT1 - OFRT_AMT1  
         REPLACE inv_nbr    WITH B->inv_nbr      
         REPLACE DUE_DATE WITH DATE()
         REPLACE REASON WITH 'FRT ADJUSTMENT'
         REPLACE DEB_CRD WITH 'Y'
         REPLACE FRT_INV WITH MFRT_INV
         UNLOCK
      ENDIF
      IF MFRT1_ADJ1 <> OFRT1_ADJ1 .AND. MFRT1_RS1 <> 'WRITEOFF'
         DO FILELOCK
         APPEND BLANK
         REPLACE salesman   WITH Msalesman  
         REPLACE po_nbr     WITH Mpo_nbr    
         REPLACE po_suffix  WITH Mpo_suffix 
         REPLACE FRT_CODE   WITH B->FRT_CODE1 
         REPLACE AMT_DUE   WITH MFRT1_ADJ1 - OFRT1_ADJ1  
         REPLACE inv_nbr    WITH B->inv_nbr      
         REPLACE DUE_DATE WITH DATE()
         REPLACE REASON WITH MFRT1_RS1
         REPLACE DEB_CRD WITH 'Y'
         REPLACE FRT_INV WITH MFRT_INV
         UNLOCK
      ENDIF
      IF MFRT1_ADJ2 <> OFRT1_ADJ2 .AND. MFRT1_RS2 <> 'WRITEOFF'
         DO FILELOCK
         APPEND BLANK
         REPLACE salesman   WITH Msalesman  
         REPLACE po_nbr     WITH Mpo_nbr    
         REPLACE po_suffix  WITH Mpo_suffix 
         REPLACE FRT_CODE   WITH B->FRT_CODE1 
         REPLACE AMT_DUE   WITH MFRT1_ADJ2 - OFRT1_ADJ2  
         REPLACE inv_nbr    WITH B->inv_nbr      
         REPLACE DUE_DATE WITH DATE()
         REPLACE REASON WITH MFRT1_RS2
         REPLACE DEB_CRD WITH 'Y'
         REPLACE FRT_INV WITH MFRT_INV
         UNLOCK
      ENDIF        
      IF MFRT_PALL <> SFRT_PALL  
         DO FILELOCK
         APPEND BLANK
         REPLACE salesman   WITH Msalesman  
         REPLACE po_nbr     WITH Mpo_nbr    
         REPLACE po_suffix  WITH Mpo_suffix 
         REPLACE FRT_CODE   WITH B->FRT_CODE1 
         REPLACE AMT_DUE   WITH MFRT_PALL - SFRT_PALL    
         REPLACE inv_nbr    WITH B->inv_nbr      
         REPLACE DUE_DATE WITH DATE()
         REPLACE REASON WITH 'PALLETS'
         REPLACE DEB_CRD WITH 'Y'
         REPLACE FRT_INV WITH MFRT_INV
         UNLOCK
      ENDIF        
      SELECT A
      USE
      SELECT B
   ENDIF
   IF MACTION = 1
      MGOTO_PG = 5
   ELSE
      MGOTO_PG = 3
   ENDIF
   
   MFRT_CODE2 = SPACE(4)
   MFRT_AMT2 = 0
   SFRT_AMT2 = 0
   SFRT_CODE2 = SPACE(4)
   MFRT_PD2   = ' '
   
   MFRT_CODE3 = SPACE(4)
   MFRT_AMT3 = 0
   SFRT_AMT3 = 0
   SFRT_CODE3 = SPACE(4)
   MFRT_PD3   = ' '
   
   **************************************************
   **** SKIP BY THE SECOND FREIGHT CARRIER IF NOT MFI
   **************************************************
   **** AS OF 11/10/03 - DONT SKIP BY ANYONE
   ****
   ****IF MPROG_CODE <> 2
   ****   MFRT_DONE = .F.
   ****   LOOP
   ****ENDIF
   
   IF B->FRT2_FLG <> ' '
      SELECT A
      DO FOX_USE WITH "FRT_2ND INDEX FRT2_PO, FRT2_FRT", .F.
      SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX       
      MFRT_CODE2 = FRT_CODE2
      MFRT_AMT2 =  FRT_AMT2
      SFRT_CODE2 = FRT_CODE2
      SFRT_AMT2 = FRT_AMT2
      MFRT_PD2  = FRT_PD2
   ENDIF
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE, &MDBFLOC.FRT_NAME", .F.
   DO CASE
   CASE MFRT_CODE2 = 'NONE'
      STORE 'NONE' + SPACE(28) TO MFRT_NAME2, MFSV2_NAME
   CASE MFRT_CODE2 = 'CUST'
      STORE 'CUSTOMER PICK UP' + SPACE(16) TO MFRT_NAME2, MFSV2_NAME
   CASE MFRT_CODE2 = SPACE(4)
      STORE SPACE(32) TO MFRT_NAME2, MFSV2_NAME
   OTHERWISE     
      SEEK MFRT_CODE2
      IF .NOT. EOF()
         STORE NAME TO MFRT_NAME2, MFSV2_NAME
         STORE CITY TO MFRT_CITY2
         STORE STATE TO MFRT_ST2   
         STORE ZIP TO MZIP2
         STORE ZIP4 TO MZIP4_2
      ELSE
         STORE 'FREIGHT CARRIER NOT ON FILE     ' TO MFRT_NAME2, MFSV2_NAME
      ENDIF
   ENDCASE
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME, &MDBFLOC.FRT_CODE", .F.
   
   @ 15,5 SAY 'FREIGHT CARRIER 2:'     
   @ 16,5 SAY MFRT_NAME2
   IF MFRT_CODE2 <> SPACE(4) .AND. MFRT_CODE2 <> 'NONE' .AND. MFRT_NAME2 <> 'FREIGHT CARRIER NOT ON FILE'
      IF MZIP4_2 = SPACE(4)
         STORE MZIP2 TO MZIP
      ELSE
         STORE MZIP2 + '-' + MZIP4_2 TO MZIP
      ENDIF
      @ 17,5 SAY TRIM(MFRT_CITY2) + ', ' + MFRT_ST2 + '  ' + MZIP
   ENDIF
   
   
   STORE 1 TO MACTION
   MFRT_SEL2 = .T.
   DO WHILE MFRT_SEL2
      
      @ 16,5 GET MFRT_NAME2 PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Previous Pg.'
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      
      DO CASE
         
      CASE MACTION = 3
         MFRT_SEL2 = .F.
         IF MACTION = 1
            MGOTO_PG = 5
         ELSE
            MGOTO_PG = 3
         ENDIF
         
      CASE MACTION = 1
         IF MFRT_NAME2= 'NONE' .OR. MFRT_NAME2 = SPACE(32)                         
            MFRT2_FLG = ' '
            SELECT A
            DO FOX_USE WITH "FRT_2ND INDEX FRT2_PO, FRT2_FRT", .F.
            SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
            IF .NOT. EOF()
               DO RECLOCK  
               DELETE
               UNLOCK
            ENDIF
            SELECT B
            DO RECLOCK
            REPLACE FRT2_FLG WITH MFRT2_FLG
            UNLOCK
            MFRT_SEL2 = .F.
            LOOP
         ENDIF
         STORE TRIM(MFRT_NAME2) TO SRCH_ARG
         SEEK SRCH_ARG
         IF EOF() .OR. DELETED()
            @ 23,0 CLEAR
            STORE ' ' TO MSPACE 
            STORE 'N' TO MYES_NO
            @ 24,10 SAY 'FREIGHT CARRIER NOT NOT FOUND - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO = 'Y'
               @ 24,0 clear
               SAVE SCREEN TO MFRT_SAVE
               DO FRT_ADD
               RESTORE SCREEN FROM MFRT_SAVE
               IF MACTION = 3  
                  LOOP
               ENDIF
               STORE NAME TO MFRT_NAME2
               STORE STREET TO MFRT_STRT2
               STORE CITY TO MFRT_CITY2
               STORE STATE TO MFRT_ST2   
               STORE ZIP TO MZIP2
               STORE ZIP4 TO MZIP4_2
               STORE FRT_CODE TO MFRT_CODE2
            ELSE
               @ 24,0 CLEAR
               STORE 'FREIGHT NAME ENTERED MUST BE ON FILE - PRESS RETURN TO REENTER' TO MWAIT
               @ 24,5 GET MWAIT
               READ
               @ 24,0 CLEAR
               LOOP
            ENDIF
         ELSE               
            STORE RECNO() TO MFST_REC
            SKIP
            IF NAME = SRCH_ARG
               MADD = .F.
               SAVE SCREEN TO MFRT_SAVE
               DO MULTFRT
               RESTORE SCREEN FROM MFRT_SAVE
               IF MACTION = 5
                  @ 24,0 CLEAR
                  
                  STORE 'FREIGHT CARRIER MUST BE ON FILE - PRESS RETURN TO REENTER' TO MWAIT
                  @ 24,5 GET MWAIT
                  READ
                  @ 24,0 CLEAR
                  LOOP
               ENDIF
               STORE NAME TO MFRT_NAME2
               STORE STREET TO MFRT_STRT2
               STORE CITY TO MFRT_CITY2
               STORE STATE TO MFRT_ST2   
               STORE ZIP TO MZIP2
               STORE ZIP4 TO MZIP4_2
               STORE FRT_CODE TO MFRT_CODE2
               mfrt_sel2 = .F.
               MNAME_FD = .T.
               LOOP
            ELSE
               GOTO MFST_REC
               STORE NAME TO MFRT_NAME2
               STORE STREET TO MFRT_STRT2
               STORE CITY TO MFRT_CITY2
               STORE STATE TO MFRT_ST2   
               STORE ZIP TO MZIP2
               STORE ZIP4 TO MZIP4_2
               STORE FRT_CODE TO MFRT_CODE2
               IF MFRT_PD2 <> ' ' .AND. MFRT_CODE2 <> SFRT_CODE2
                  @ 24,0 CLEAR
                  MWAIT = ' '
                  @ 24,1 SAY 'WARNING! WARNING! FREIGHT IS PAID - SHOULD NOT CHANGE CARRIERS -PRESS RETURN ' GET MWAIT
                  READ 
                  @ 24,0 CLEAR
               ENDIF
               mfrt_sel2 = .F.
               MNAME_FD = .T.
               LOOP
            ENDIF
         ENDIF
         MFRT_SEL2 = .F.
         LOOP
      CASE MACTION = 2
         MFRT_SEL2 = .F.
         LOOP
         
      ENDCASE
      
   ENDDO
   IF MACTION = 2
      LOOP
   ENDIF

   IF MACTION = 3
      MFRT_DONE = .F.
      LOOP
   ENDIF

   IF MFRT_NAME2 = 'NONE' .OR. MFRT_NAME2 = SPACE(32)
      MFRT_DONE = .F.
      LOOP
   ENDIF
   
   @ 16,5 SAY MFRT_NAME2
   IF MZIP4_2 = SPACE(4)
      STORE MZIP2 TO MZIP
   ELSE
      STORE MZIP2 + '-' + MZIP4_2 TO MZIP
   ENDIF
   @ 17,5 SAY TRIM(MFRT_CITY2) + ', ' + MFRT_ST2 + '  ' + MZIP
   
   
   MEDIT = .T.
   DO WHILE MEDIT
      @ 19,5 SAY 'FREIGHT AMOUNT:'
      @ 19,21 GET MFRT_AMT2 PICTURE '99999.99'
      
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Previous Pg.'
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 2
         LOOP
      ENDIF
      MEDIT = .F.
      IF MACTION = 1
         MGOTO_PG = 5
      ELSE
         MGOTO_PG = 3
      ENDIF
      
      MFRT2_FLG = 'Y'
      SELECT A
      DO FOX_USE WITH "FRT_2ND INDEX FRT2_PO, FRT2_FRT", .F.
      SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
      IF EOF()
         DO FILELOCK
         APPEND BLANK
         REPLACE SALESMAN  WITH MSALESMAN
         REPLACE PO_NBR    WITH MPO_NBR
         REPLACE PO_SUFFIX WITH MPO_SUFFIX
         UNLOCK
      ENDIF
      DO RECLOCK
      REPLACE FRT_CODE2 WITH MFRT_CODE2
      REPLACE FRT_AMT2 WITH MFRT_AMT2
      UNLOCK
      SELECT B
      DO RECLOCK
      REPLACE FRT2_FLG WITH MFRT2_FLG
      UNLOCK
   ENDDO
   *** IF 2ND FREIGHT BILL IS PAID - AND AMOUNT CHANGED PUT OUT ADJUSTMENTS 
   IF MFRT_PD2 <> ' ' .AND. MFRT_AMT2 <> SFRT_AMT2
      SELECT A
      DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
      DO FILELOCK
      APPEND BLANK
      REPLACE SALESMAN   WITH MSALESMAN  
      REPLACE PO_NBR     WITH MPO_NBR    
      REPLACE PO_SUFFIX  WITH MPO_SUFFIX 
      REPLACE FRT_CODE   WITH SFRT_CODE2 
      REPLACE AMT_DUE    WITH MFRT_AMT2 - SFRT_AMT2
      REPLACE INV_NBR    WITH B->INV_NBR      
      REPLACE DUE_DATE WITH DATE()
      REPLACE REASON WITH 'FRT ADJUSTMENT'
      REPLACE DEB_CRD WITH 'Y'
      UNLOCK
   ENDIF
   
   *** START ON FREIGHT CARRIER 3
   
   IF B->FRT3_FLG <> ' '
      SELECT A
      DO FOX_USE WITH "FRT_3RD INDEX FRT3_PO, FRT3_FRT", .F.
      SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX       
      MFRT_CODE3 = FRT_CODE3
      MFRT_AMT3 =  FRT_AMT3
      SFRT_CODE3 = FRT_CODE3
      SFRT_AMT3 = FRT_AMT3
      MFRT_PD3  = FRT_PD3
   ENDIF
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE, &MDBFLOC.FRT_NAME", .F.
   DO CASE
   CASE MFRT_CODE3 = 'NONE'
      STORE 'NONE' + SPACE(28) TO MFRT_NAME3, MFSV3_NAME
   CASE MFRT_CODE3 = 'CUST'
      STORE 'CUSTOMER PICK UP' + SPACE(16) TO MFRT_NAME3, MFSV3_NAME
   CASE MFRT_CODE3 = SPACE(4)
      STORE SPACE(32) TO MFRT_NAME3, MFSV3_NAME
   OTHERWISE     
      SEEK MFRT_CODE3
      IF .NOT. EOF()
         STORE NAME TO MFRT_NAME3, MFSV3_NAME
         STORE CITY TO MFRT_CITY3
         STORE STATE TO MFRT_ST3   
         STORE ZIP TO MZIP3
         STORE ZIP4 TO MZIP4_3
      ELSE
         STORE 'FREIGHT CARRIER NOT ON FILE     ' TO MFRT_NAME3, MFSV3_NAME
      ENDIF
   ENDCASE
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME, &MDBFLOC.FRT_CODE", .F.
   
   @ 15,45 SAY 'FREIGHT CARRIER 3:'     
   @ 16,45 SAY MFRT_NAME3 
   IF MFRT_CODE3 <> SPACE(4) .AND. MFRT_CODE3 <> 'NONE' .AND. MFRT_NAME3 <> 'FREIGHT CARRIER NOT ON FILE'
      IF MZIP4_3 = SPACE(4)
         STORE MZIP3 TO MZIP
      ELSE
         STORE MZIP3 + '-' + MZIP4_3 TO MZIP
      ENDIF
      @ 17,45 SAY TRIM(MFRT_CITY3) + ', ' + MFRT_ST3 + '  ' + MZIP
   ENDIF
   STORE 1 TO MACTION
   MFRT_SEL3 = .T.
   DO WHILE MFRT_SEL3
      
      @ 16,45 GET MFRT_NAME3 PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Previous Pg.'
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      
      DO CASE
         
      CASE MACTION = 3
         MFRT_SEL3 = .F.
         IF MACTION = 1
            MGOTO_PG = 5
         ELSE
            MGOTO_PG = 3
         ENDIF
         
      CASE MACTION = 1
         IF MFRT_NAME3= 'NONE' .OR. MFRT_NAME3 = SPACE(32)                         
            MFRT3_FLG = ' '
            SELECT A
            DO FOX_USE WITH "FRT_3RD INDEX FRT3_PO, FRT3_FRT", .F.
            SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
            IF .NOT. EOF()
               DO RECLOCK  
               DELETE
               UNLOCK
            ENDIF
            SELECT B
            DO RECLOCK
            REPLACE FRT3_FLG WITH MFRT3_FLG
            UNLOCK
            MFRT_SEL3 = .F.
            LOOP
         ENDIF
         STORE TRIM(MFRT_NAME3) TO SRCH_ARG
         SEEK SRCH_ARG
         IF EOF() .OR. DELETED()
            @ 23,0 CLEAR
            STORE ' ' TO MSPACE 
            STORE 'N' TO MYES_NO
            @ 24,10 SAY 'FREIGHT CARRIER NOT NOT FOUND - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO = 'Y'
               @ 24,0 clear
               SAVE SCREEN TO MFRT_SAVE
               DO FRT_ADD
               RESTORE SCREEN FROM MFRT_SAVE
               IF MACTION = 3  
                  LOOP
               ENDIF
               STORE NAME TO MFRT_NAME3
               STORE STREET TO MFRT_STRT3
               STORE CITY TO MFRT_CITY3
               STORE STATE TO MFRT_ST3   
               STORE ZIP TO MZIP3
               STORE ZIP4 TO MZIP4_3
               STORE FRT_CODE TO MFRT_CODE3
            ELSE
               @ 24,0 CLEAR
               STORE 'FREIGHT NAME ENTERED MUST BE ON FILE - PRESS RETURN TO REENTER' TO MWAIT
               @ 24,5 GET MWAIT
               READ
               @ 24,0 CLEAR
               LOOP
            ENDIF
         ELSE               
            STORE RECNO() TO MFST_REC
            SKIP
            IF NAME = SRCH_ARG
               MADD = .F.
               SAVE SCREEN TO MFRT_SAVE
               DO MULTFRT
               RESTORE SCREEN FROM MFRT_SAVE
               IF MACTION = 5
                  @ 24,0 CLEAR
                  
                  STORE 'FREIGHT CARRIER MUST BE ON FILE - PRESS RETURN TO REENTER' TO MWAIT
                  @ 24,5 GET MWAIT
                  READ
                  @ 24,0 CLEAR
                  LOOP
               ENDIF
               STORE NAME TO MFRT_NAME3
               STORE STREET TO MFRT_STRT3
               STORE CITY TO MFRT_CITY3
               STORE STATE TO MFRT_ST3   
               STORE ZIP TO MZIP3
               STORE ZIP4 TO MZIP4_3
               STORE FRT_CODE TO MFRT_CODE3
               mfrt_sel3 = .F.
               MNAME_FD = .T.
               LOOP
            ELSE
               GOTO MFST_REC
               STORE NAME TO MFRT_NAME3
               STORE STREET TO MFRT_STRT3
               STORE CITY TO MFRT_CITY3
               STORE STATE TO MFRT_ST3   
               STORE ZIP TO MZIP3
               STORE ZIP4 TO MZIP4_3
               STORE FRT_CODE TO MFRT_CODE3
               IF MFRT_PD3 <> ' ' .AND. MFRT_CODE3 <> SFRT_CODE3
                  @ 24,0 CLEAR
                  MWAIT = ' '
                  @ 24,1 SAY 'WARNING! WARNING! FREIGHT IS PAID - SHOULD NOT CHANGE CARRIERS -PRESS RETURN ' GET MWAIT
                  READ 
                  @ 24,0 CLEAR
               ENDIF
               mfrt_sel3 = .F.
               MNAME_FD = .T.
               LOOP
            ENDIF
         ENDIF
         MFRT_SEL3 = .F.
         LOOP
      CASE MACTION = 2
         LOOP
         
      ENDCASE
      
   ENDDO
   
   IF MACTION = 3
      MFRT_DONE = .F.
      LOOP
   ENDIF
   IF MFRT_NAME3 = 'NONE' .OR. MFRT_NAME3 = SPACE(32)
      MFRT_DONE = .F.
      LOOP
   ENDIF
   @ 16,45 SAY MFRT_NAME3
   IF MZIP4_3 = SPACE(4)
      STORE MZIP3 TO MZIP
   ELSE
      STORE MZIP3 + '-' + MZIP4_3 TO MZIP
   ENDIF
   @ 17,45 SAY TRIM(MFRT_CITY3) + ', ' + MFRT_ST3 + '  ' + MZIP
   
   
   MEDIT = .T.
   DO WHILE MEDIT
      
      @ 19,45 SAY 'FREIGHT AMOUNT:'
      @ 19,61 GET MFRT_AMT3 PICTURE '99999.99'
      
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Previous Pg.'
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 2
         LOOP
      ENDIF
      MEDIT = .F.
      IF MACTION = 1
         MGOTO_PG = 5
      ELSE
         MGOTO_PG = 3
      ENDIF
      
      MFRT3_FLG = 'Y'
      SELECT A
      DO FOX_USE WITH "FRT_3RD INDEX FRT3_PO, FRT3_FRT", .F.
      SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
      IF EOF()
         DO FILELOCK
         APPEND BLANK
         REPLACE SALESMAN  WITH MSALESMAN
         REPLACE PO_NBR    WITH MPO_NBR
         REPLACE PO_SUFFIX WITH MPO_SUFFIX
         UNLOCK
      ENDIF
      DO RECLOCK
      REPLACE FRT_CODE3 WITH MFRT_CODE3
      REPLACE FRT_AMT3 WITH MFRT_AMT3
      UNLOCK
      SELECT B
      DO RECLOCK
      REPLACE FRT3_FLG WITH MFRT3_FLG
      UNLOCK                     
   ENDDO
   *** IF 3RD FREIGHT BILL IS PAID - AND AMOUNT CHANGED PUT OUT ADJUSTMENTS 
   IF MFRT_PD3 <> ' ' .AND. MFRT_AMT3 <> SFRT_AMT3
      SELECT A
      DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
      DO FILELOCK
      APPEND BLANK
      REPLACE SALESMAN   WITH MSALESMAN  
      REPLACE PO_NBR     WITH MPO_NBR    
      REPLACE PO_SUFFIX  WITH MPO_SUFFIX 
      REPLACE FRT_CODE   WITH SFRT_CODE3 
      REPLACE AMT_DUE    WITH MFRT_AMT3 - SFRT_AMT3
      REPLACE INV_NBR    WITH B->INV_NBR      
      REPLACE DUE_DATE WITH DATE()
      REPLACE REASON WITH 'FRT ADJUSTMENT'
      REPLACE DEB_CRD WITH 'Y'
      UNLOCK
   ENDIF
   
   MFRT_DONE = .F.
ENDDO

RETURN
* EOF: FRT_CHG.PRG
*Formatted by: ToolBox Ver. 1.2  on 11/17/3 at 8:23 AM.
