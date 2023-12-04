******************
* Program.: PO_SEL2.PRG
* Author..: Grace Keller
* Date....: 10/19/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PURCHASE ORDER SELECT
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
STORE SPACE(2)    TO MSALESMAN
STORE SPACE(4)    TO MPO_NBR
STORE SPACE(1)    TO MPO_SUFFIX
STORE '1'         TO MFRT_SEQ
SELECT C
DO FOX_USE WITH "FRT_2ND INDEX FRT2_PO, FRT2_FRT", .F.
SELECT D
DO FOX_USE WITH "FRT_3RD INDEX FRT3_PO, FRT3_FRT", .F.
SELECT B
DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PO_FRT", .F.
SELECT A
DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
MPO_FD = .F.
STORE 1 TO MACTION
MPO_SEL = .T.
DO WHILE MPO_SEL
   
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - SELECT PURCHASE ORDER'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   @  5, 5 SAY 'Enter Search Field:'
   @  8, 5 SAY 'Purchase Order Number'
   @ 10,7 say '-'
   @ 10,12 say '-'
   IF MPROG_CODE = 2
      @ 12,5 SAY 'Freight Carrier Sequence (1 or 2 or 3): '
   ENDIF
   @ 10, 5 GET Msalesman PICTURE '##'
   @ 10,8 get mpo_nbr picture '####'
   @ 10,13 get mpo_suffix picture '@!'
   IF MPROG_CODE = 2
      @ 12,47 GET MFRT_SEQ VALID(MFRT_SEQ = ' ' .OR. MFRT_SEQ = '1' .OR. MFRT_SEQ = '2' .OR. MFRT_SEQ = '3')
   ENDIF
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      
      IF MPO_NBR = SPACE(4)
         MPO_SEL = .F.
         LOOP
      ENDIF
      
      SELECT B
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      
      IF EOF() .OR. DELETED()
         @ 23,0 CLEAR
         MWAIT = ' '
         @ 24,10 SAY 'PURCHASE ORDER NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
         READ
         LOOP
      ENDIF
      
      DO CASE
      CASE MFRT_SEQ = '2'
         SELECT C
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF FRT_PD2 <> ' '
            STORE '   ' TO MYES_NO
            @ 24,0 SAY 'FREIGHT HAS ALREADY BEEN PAID - DID YOU VOID THE CHECK (YES/NO) ? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'YES' 
               STORE ' ' TO MWAIT
               @ 24,0 SAY "DID NOT ENTER 'YES' - UNMATCH NOT PROCESSED - PRESS RETURN TO CONTINUE " GET MWAIT
               READ
               @ 24,0 CLEAR
               STORE SPACE(2)    TO MSALESMAN
               STORE SPACE(4)    TO MPO_NBR
               STORE SPACE(1)    TO MPO_SUFFIX
               STORE '1'         TO MFRT_SEQ
               LOOP
            ENDIF
         ENDIF
      CASE MFRT_SEQ = '3'
         SELECT D
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF FRT_PD3 <> ' '
            STORE '   ' TO MYES_NO
            @ 24,0 SAY 'FREIGHT HAS ALREADY BEEN PAID - DID YOU VOID THE CHECK (YES/NO) ? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'YES' 
               STORE ' ' TO MWAIT
               @ 24,0 SAY "DID NOT ENTER 'YES' - UNMATCH NOT PROCESSED - PRESS RETURN TO CONTINUE " GET MWAIT
               READ
               @ 24,0 CLEAR
               STORE SPACE(2)    TO MSALESMAN
               STORE SPACE(4)    TO MPO_NBR
               STORE SPACE(1)    TO MPO_SUFFIX
               STORE '1'         TO MFRT_SEQ
               LOOP
            ENDIF
         ENDIF
      OTHERWISE
         IF FRT_PD <> ' '
            STORE '   ' TO MYES_NO
            @ 24,0 SAY 'FREIGHT HAS ALREADY BEEN PAID - DID YOU VOID THE CHECK (YES/NO) ? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'YES' 
               STORE ' ' TO MWAIT
               @ 24,0 SAY "DID NOT ENTER 'YES' - UNMATCH NOT PROCESSED - PRESS RETURN TO CONTINUE " GET MWAIT
               READ
               @ 24,0 CLEAR
               STORE SPACE(2)    TO MSALESMAN
               STORE SPACE(4)    TO MPO_NBR
               STORE SPACE(1)    TO MPO_SUFFIX
               STORE '1'         TO MFRT_SEQ
               LOOP
            ENDIF
         ENDIF
      ENDCASE
      DO CASE
      CASE MFRT_SEQ = '2'
         DO RECLOCK
         REPLACE FRT_REC2 WITH  ' '
         REPLACE FRT_PD2 WITH ' '
         UNLOCK
         STORE FRT_CODE2 TO MFRT_CODE
      CASE MFRT_SEQ = '3'
         DO RECLOCK
         REPLACE FRT_REC3 WITH  ' '
         REPLACE FRT_PD3 WITH ' '
         UNLOCK
         STORE FRT_CODE3 TO MFRT_CODE
      OTHERWISE
         DO RECLOCK  
         REPLACE FRT_REC WITH  ' '
         REPLACE FRT_PD WITH ' '
         UNLOCK
         STORE FRT_CODE1 TO MFRT_CODE
      ENDCASE
      
      SELECT A
      SEEK MFRT_CODE
      DO WHILE .NOT. EOF() .AND. FRT_CODE = MFRT_CODE
         IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR  .AND. PO_SUFFIX = MPO_SUFFIX
            DELETE
            MFRT_CODE = '9999'
         ENDIF
         SKIP
      ENDDO
      **** IF FINISHED HERE, GET OUT
      STORE SPACE(2)    TO MSALESMAN
      STORE SPACE(4)    TO MPO_NBR
      STORE SPACE(1)    TO MPO_SUFFIX
      STORE '1'         TO MFRT_SEQ
      
   CASE MACTION = 3
      MPO_SEL = .F.
      
   ENDCASE
   
ENDDO
CLOSE DATA
RETURN
* EOF: UNFRT.PRG
*Formatted by: ToolBox Ver. 1.2  on 2/8/0 at 11:12 AM.
