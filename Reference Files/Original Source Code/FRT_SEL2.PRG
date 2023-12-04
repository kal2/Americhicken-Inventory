******************
* Program.: FRT_SEL2.PRG
* Author..: Grace Keller
* Date....: 10/11/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: FREIGHT CARRIER SELECT 
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MFRT_DONE = .T.
DO WHILE MFRT_DONE
   STORE 1 TO MACTION
   MFRT_SEL1 = .T.
   DO WHILE MFRT_SEL1 
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - PURCHASE ORDER FREIGHT CARRIER SELECT'
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      @  4, 5 SAY 'FREIGHT CARRIER:'     
      @  5, 5 GET Mfrt_name1 PICTURE '@!'
      @ 13,1 TO 13,78
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit'
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,2
      READ               
      
      DO CASE
         
      CASE MACTION = 1
         IF MFRT_NAME1= 'NONE' .OR. MFRT_NAME1 = 'CUST'
            STORE MFRT_NAME1 TO MFRT_CODE1
            MFRT_SEL1 = .F.
            LOOP
         ENDIF
         IF MFRT_NAME1 <> SPACE(32)
            STORE TRIM(MFRT_NAME1) TO SRCH_ARG
            SEEK SRCH_ARG
            IF EOF() .OR. DELETED()
               @ 24,0 CLEAR
               STORE ' ' TO MSPACE 
               STORE 'N' TO MYES_NO
               *@ 24,10 SAY 'FREIGHT CARRIER NOT NOT FOUND - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
               *
               *READ
               IF MYES_NO = 'Y'
                  @ 24,0 clear
                  SAVE SCREEN TO MFRT_SAVE
                  MINIT_NM = .F.
                  STORE MFRT_NAME1 TO MNAME
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
         ELSE
            @ 24,0 CLEAR
            STORE 'NO FREIGHT CARRIER NAME ENTERED - PRESS RETURN TO REENTER' TO MWAIT
            @ 24,5  GET MWAIT 
            READ
            @ 24,0 CLEAR
            LOOP
         ENDIF     
         
         MFRT_SEL1 = .F.
         LOOP
      CASE MACTION = 2
         LOOP
         
      ENDCASE
      
   ENDDO
   
   IF MFRT_NAME1 = 'NONE' .OR. MFRT_NAME1 = 'CUST'
      MFRT_DONE = .F.
      LOOP
   ENDIF
   
   @ 5,5 SAY MFRT_NAME1
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
      @ 08,21 GET MFRT_AMT1 PICTURE '######.##'

      @ 6,59 GET MREF_PO1 PICTURE '@!'
      @ 6,70 GET MREF_PO2 PICTURE '@!'
      @ 7,59 GET MREF_PO3 PICTURE '@!'
      @ 7,70 GET MREF_PO4 PICTURE '@!'
      @ 8,59 GET MREF_PO5 PICTURE '@!'
      @ 8,70 GET MREF_PO6 PICTURE '@!'

      @ 10,21 GET MFRT1_ADJ1 PICTURE '#####.##'
      @ 10,48 GET MFRT1_RS1 PICTURE '@!'
      @ 11,21 GET MFRT1_ADJ2 PICTURE '#####.##'
      @ 11,48 GET MFRT1_RS2 PICTURE '@!'
      @ 12,21 GET MFRT_PALL PICTURE '#####.##'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit'
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,2
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
   MFRT_DONE = .F.
   
   *** IF THIS IS NOT MFI - SKIP AROUND 2ND FREIGHT CARRIER
   *** PUT IN 11/2003
   *IF MPROG_CODE <> 2
   *   LOOP
   *ENDIF
   
   
   **** START ON THE SECOND CARRIER HERE
   @ 24,0 CLEAR
   MFRT_SEL1 = .T.
   @ 14, 5 SAY 'FREIGHT CARRIER 2'     
   DO WHILE MFRT_SEL1
      @ 15, 5 GET MFRT_NAME2 PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit'
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,2
      READ               
      
      DO CASE
      CASE MACTION = 2
         MFRT_SEL1 = .F.
         LOOP
      CASE MACTION = 1
         IF MFRT_NAME2= '    ' .OR. MFRT_NAME2 = 'NONE' .OR. MFRT_NAME2 = 'CUST'
            STORE SUBSTR(MFRT_NAME2,1,4) TO MFRT_CODE2
            MFRT_SEL1 = .F.
            LOOP
         ENDIF
         
         STORE TRIM(MFRT_NAME2) TO SRCH_ARG
         SEEK SRCH_ARG
         IF EOF() .OR. DELETED()
            @ 24,0 CLEAR
            STORE ' ' TO MSPACE 
            STORE 'N' TO MYES_NO
            @ 24,10 SAY 'FREIGHT CARRIER NOT NOT FOUND - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO = 'Y'
               @ 24,0 CLEAR
               SAVE SCREEN TO MFRT_SAVE
               MINIT_NM = .F.
               STORE MFRT_NAME2 TO MNAME
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
               STORE NAME TO MFRT_NAME2
               STORE CITY TO MFRT_CITY2
               STORE STATE TO MFRT_ST2   
               STORE ZIP TO MZIP2
               STORE ZIP4 TO MZIP4_2
               STORE FRT_CODE TO MFRT_CODE2
            ELSE
               GOTO MFST_REC
               STORE NAME TO MFRT_NAME2
               STORE CITY TO MFRT_CITY2
               STORE STATE TO MFRT_ST2   
               STORE ZIP TO MZIP2
               STORE ZIP4 TO MZIP4_2
               STORE FRT_CODE TO MFRT_CODE2
            ENDIF
         ENDIF
         STORE NAME TO MFRT_NAME2
         STORE CITY TO MFRT_CITY2
         STORE STATE TO MFRT_ST2   
         STORE ZIP TO MZIP2
         STORE ZIP4 TO MZIP4_2
         STORE FRT_CODE TO MFRT_CODE2
         MFRT_SEL1 = .F.
      ENDCASE
   ENDDO
   IF MACTION = 2
      LOOP
   ENDIF

   IF MFRT_NAME2= '    ' .OR. MFRT_NAME2 = 'NONE' .OR. MFRT_NAME2 = 'CUST'
      STORE SUBSTR(MFRT_NAME2,1,4) TO MFRT_CODE2
      MFRT_DONE = .F.
      LOOP
   ENDIF
   
   @ 15,5 SAY MFRT_NAME2
   IF MZIP4_2 = SPACE(4)
      STORE MZIP2 TO MZIP
   ELSE
      STORE MZIP2 + '-' + MZIP4_2 TO MZIP
   ENDIF
   @ 16,5 SAY TRIM(MFRT_CITY2) + ', ' + MFRT_ST2 + '  ' + MZIP
   MEDIT = .T.
   DO WHILE MEDIT
      
      @ 18,5 SAY 'FREIGHT AMOUNT:'
      @ 18,21 GET MFRT_AMT2 PICTURE '#####.##'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit'
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,2
      READ               
      IF MACTION = 2
         LOOP
      ENDIF
      MEDIT = .F.
   ENDDO
   
   
   **** START ON THE THIRD CARRIER HERE
   @ 24,0 CLEAR
   MFRT_SEL1 = .T.
   @ 14,45 SAY 'FREIGHT CARRIER 3'     
   DO WHILE MFRT_SEL1
      @ 15,45 GET MFRT_NAME3 PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit'
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,2
      READ               
      
      DO CASE
         
      CASE MACTION = 1
         IF MFRT_NAME3= '    ' .OR. MFRT_NAME3 = 'NONE' .OR. MFRT_NAME3 = 'CUST'
            STORE SUBSTR(MFRT_NAME3,1,4) TO MFRT_CODE3
            MFRT_SEL1 = .F.
            LOOP
         ENDIF
         
         STORE TRIM(MFRT_NAME3) TO SRCH_ARG
         SEEK SRCH_ARG
         IF EOF() .OR. DELETED()
            @ 24,0 CLEAR
            STORE ' ' TO MSPACE 
            STORE 'N' TO MYES_NO
            @ 24,10 SAY 'FREIGHT CARRIER NOT NOT FOUND - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO = 'Y'
               @ 24,0 CLEAR
               SAVE SCREEN TO MFRT_SAVE
               MINIT_NM = .F.
               STORE MFRT_NAME3 TO MNAME
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
               STORE NAME TO MFRT_NAME3
               STORE CITY TO MFRT_CITY3
               STORE STATE TO MFRT_ST3   
               STORE ZIP TO MZIP3
               STORE ZIP4 TO MZIP4_3
               STORE FRT_CODE TO MFRT_CODE3
            ELSE
               GOTO MFST_REC
               STORE NAME TO MFRT_NAME3
               STORE CITY TO MFRT_CITY3
               STORE STATE TO MFRT_ST3   
               STORE ZIP TO MZIP3
               STORE ZIP4 TO MZIP4_3
               STORE FRT_CODE TO MFRT_CODE3
            ENDIF
         ENDIF
         STORE NAME TO MFRT_NAME3
         STORE CITY TO MFRT_CITY3
         STORE STATE TO MFRT_ST3   
         STORE ZIP TO MZIP3
         STORE ZIP4 TO MZIP4_3
         STORE FRT_CODE TO MFRT_CODE3
         MFRT_SEL1 = .F.
      ENDCASE
   ENDDO
   
   IF MFRT_NAME3= '    ' .OR. MFRT_NAME3 = 'NONE' .OR. MFRT_NAME3 = 'CUST'
      STORE SUBSTR(MFRT_NAME3,1,4) TO MFRT_CODE3
      MFRT_DONE = .F.
      LOOP
   ENDIF
   
   @ 15,45 SAY MFRT_NAME3
   IF MZIP4_3 = SPACE(4)
      STORE MZIP3 TO MZIP
   ELSE
      STORE MZIP3 + '-' + MZIP4_3 TO MZIP
   ENDIF
   @ 16,45 SAY TRIM(MFRT_CITY3) + ', ' + MFRT_ST3 + '  ' + MZIP
   MEDIT = .T.
   DO WHILE MEDIT
      
      @ 18,45 SAY 'FREIGHT AMOUNT:'
      @ 18,61 GET MFRT_AMT3 PICTURE '#####.##'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit'
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,2
      READ               
      IF MACTION = 2
         LOOP
      ENDIF
      MEDIT = .F.
   ENDDO
   
   MFRT_DONE = .F.
ENDDO

RETURN
* EOF: FRT_SEL2.PRG
*Formatted by: ToolBox Ver. 1.2  on 11/17/3 at 8:25 AM.
