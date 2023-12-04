**********
* Program.: NEW_DISB.PRG
* Author..: GRACE KELLER
* Date....: 12/28/95
* Notice..: Copyright 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MISCELLANEOUS DISBURSEMENTS ACROSS DATABASES
*


* ---PROCESSING LOOP
SET PROCEDURE TO NEW_DISB
SELECT C
DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
SELECT B
DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
SELECT A
DO FOX_USE WITH "MAN_CK INDEX MAN_CK", .F.

MMORE = .T.
DO WHILE MMORE
   CLEAR
   @ 1,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 02,00 SAY MPROGRAM + ' - MISC. MANUAL DISBURSEMENTS ACROSS DATABASES'
   @ 03,00 TO 24,79 
   
   @ 4,6 SAY ' PAYEE: ' 
   @ 5,6 SAY 'STREET:'                          
   @ 6,6 SAY '  CITY: ' 
   @ 6,45 SAY 'STATE: ' 
   @ 6,58 SAY 'ZIP: '
   IF MPROG_CODE = 2
      @ 07,1 SAY 'SALESPERSON:'
   ENDIF
   @ 8,1 SAY ' CHECK DATE:              INVOICE NBR:'  
   @ 9,1 SAY 'DESCRIPTION: '

   @ 10,1 SAY '1. ACCT: XXXX   2. ACCT: XXXX   3. ACCT: XXXX   4. ACCT: XXXX   5. ACCT: XXXX'

   @ 12,1 SAY 'DB CODE: XX     DB CODE:        DB CODE:        DB CODE:        DB CODE:'
   @ 13,1 SAY 'AMT:            AMT:            AMT:            AMT:            AMT:          '
   @ 14,1 SAY 'SALE CODE: XX   SALE CODE: XX   SALE CODE:  XX  SALE CODE: XX   SALE CODE: XX'

   @ 16,1 SAY 'DB CODE: XX     DB CODE:        DB CODE:        DB CODE:        DB CODE:'
   @ 17,1 SAY 'AMT:            AMT:            AMT:            AMT:            AMT:         '
   @ 18,1 SAY 'SALE CODE: XX   SALE CODE: XX   SALE CODE:  XX  SALE CODE: XX   SALE CODE: XX'

   @ 20,1 SAY 'DB CODE:        DB CODE:        DB CODE:        DB CODE:        DB CODE:'
   @ 21,1 SAY 'AMT:            AMT:            AMT:            AMT:            AMT:         '
   @ 22,1 SAY 'SALE CODE: XX   SALE CODE: XX   SALE CODE:  XX  SALE CODE: XX   SALE CODE: XX'
SUSPEND

   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Save/Add Another    2. Edit   3. Save/Finished    4. Cancel'
   STORE SPACE(32) TO MNAME
   STORE CTOD(' ') TO MCK_DATE
   STORE SPACE(25) TO MSTREET 
   STORE SPACE(20) TO MCITY
   STORE SPACE(2) TO MSTATE, MSALESMAN
   STORE SPACE(2) TO MSALES1, MSALES2, MSALES3, MSALES4, MSALES5
   STORE SPACE(2) TO MSALES1A, MSALES2A, MSALES3A, MSALES4A, MSALES5A
   STORE SPACE(2) TO MSALES1B, MSALES2B, MSALES3B, MSALES4B, MSALES5B
   STORE SPACE(5) TO MZIP
   STORE 0 TO MAMOUNT1, MAMOUNT2, MAMOUNT3, MAMOUNT4, MAMOUNT5
   STORE 0 TO MAMOUNT1A, MAMOUNT2A, MAMOUNT3A, MAMOUNT4A, MAMOUNT5A
   STORE 0 TO MAMOUNT1B, MAMOUNT2B, MAMOUNT3B, MAMOUNT4B, MAMOUNT5B
   STORE SPACE(4) TO MACCOUNT1, MACCOUNT2, MACCOUNT3, MACCOUNT4, MACCOUNT5
   STORE SPACE(20) TO MDESCRIP1, MDESCRIP2, MDESCRIP3, MDESCRIP4, MDESCRIP5
   STORE SPACE(25) TO MDESCRIP
   STORE SPACE(12) TO MSUP_INV
   STORE 2 TO MACTION
   DO WHILE MACTION = 2
      @ 22,1 CLEAR TO 22,78
      @ 4,14 GET MNAME PICTURE '@!'
      @ 5,14 GET MSTREET PICTURE '@!'
      @ 6,14 GET MCITY PICTURE '@!'
      @ 6,52 GET MSTATE PICTURE '@!'
      @ 6,63 GET MZIP PICTURE '#####'
      IF MPROG_CODE = 2
         @ 07,14 GET MSALESMAN PICTURE '##'
      ENDIF
      @ 8,14 GET MCK_DATE
      @ 9,14 GET MSUP_INV PICTURE '@!'
      @ 10,14 GET MDESCRIP PICTURE '@!'
      **** START ALL NEW STUFF HERE


      @ 12,12 GET MAMOUNT1 PICTURE '###,###.##'
      @ 12,35 GET MACCOUNT1 PICTURE '#####'
      IF MPROG_CODE = 1
         @ 12,52 GET MSALES1 PICTURE '##'
      ENDIF
      
      @ 14,12 GET MAMOUNT2 PICTURE '###,###.##'
      @ 14,35 GET MACCOUNT2 PICTURE '#####'
      IF MPROG_CODE = 1
         @ 14,52 GET MSALES2 PICTURE '##'
      ENDIF
      
      @ 16,12 GET MAMOUNT3 PICTURE '###,###.##'
      @ 16,35 GET MACCOUNT3 PICTURE '#####'
      IF MPROG_CODE = 1
         @ 16,52 GET MSALES3 PICTURE '##'
      ENDIF
      
      @ 18,12 GET MAMOUNT4 PICTURE '###,###.##'
      @ 18,35 GET MACCOUNT4 PICTURE '#####'
      IF MPROG_CODE = 1
         @ 18,52 GET MSALES4 PICTURE '##'
      ENDIF
      
      @ 20,12 GET MAMOUNT5 PICTURE '###,###.##'
      @ 20,35 GET MACCOUNT5 PICTURE '#####'
      IF MPROG_CODE = 1
         @ 20,52 GET MSALES5 PICTURE '##'
      ENDIF
      CLEAR GETS
      @ 4,14 GET MNAME PICTURE '@!'
      READ
      DO CASE
      CASE MNAME = SPACE(32)
         MACTION = 4
         LOOP
      CASE MNAME = '*'
         SELECT A
         GOTO TOP
         IF EOF()
            STORE 0 TO MFST_REC
         ELSE
            STORE RECNO() TO MFST_REC
         ENDIF
         SAVE SCREEN TO MSCREEN
         DO MULTCHK
         IF MACTION = 4
            LOOP
         ENDIF
         RESTORE SCREEN FROM MSCREEN
         STORE NAME TO MNAME
         STORE STREET TO MSTREET
         STORE CITY TO MCITY
         STORE STATE TO MSTATE
         STORE ZIP TO MZIP
         STORE DESCRIP TO MDESCRIP
         STORE SUP_INV TO MSUP_INV
         STORE CK_DATE TO MCK_DATE
         STORE AMOUNT1 TO MAMOUNT1
         STORE AMOUNT2 TO MAMOUNT2
         STORE AMOUNT3 TO MAMOUNT3
         STORE AMOUNT4 TO MAMOUNT4
         STORE AMOUNT5 TO MAMOUNT5
         STORE ACCOUNT1 TO MACCOUNT1
         STORE ACCOUNT2 TO MACCOUNT2
         STORE ACCOUNT3 TO MACCOUNT3
         STORE ACCOUNT4 TO MACCOUNT4
         STORE ACCOUNT5 TO MACCOUNT5
         STORE SALESMAN TO MSALESMAN
         IF MPROG_CODE = 1
            STORE SALES1   TO MSALES1
            STORE SALES2   TO MSALES2
            STORE SALES3   TO MSALES3
            STORE SALES4   TO MSALES4
            STORE SALES5   TO MSALES5
         ENDIF
         @ 4,14 SAY MNAME PICTURE '@!'
         MNEW_RCD = .F.
         SELECT B
         IF MACCOUNT1 <> SPACE(4)
            SEEK MACCOUNT1
            IF .NOT. EOF()
               STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP1
            ELSE
               STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP1
            ENDIF
         ENDIF
         IF MACCOUNT2 <> SPACE(4)
            SEEK MACCOUNT2
            IF .NOT. EOF()
               STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP2
            ELSE
               STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP2
            ENDIF
         ENDIF
         IF MACCOUNT3 <> SPACE(4)
            SEEK MACCOUNT3
            IF .NOT. EOF()
               STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP3
            ELSE
               STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP3
            ENDIF
         ENDIF
         IF MACCOUNT4 <> SPACE(4)
            SEEK MACCOUNT4
            IF .NOT. EOF()
               STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP4
            ELSE 
               STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP4
            ENDIF
         ENDIF
         IF MACCOUNT5 <> SPACE(4)
            SEEK MACCOUNT5
            IF .NOT. EOF()
               STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP5
            ELSE 
               STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP5
            ENDIF
         ENDIF
         SELECT A
      OTHERWISE
         STORE TRIM(MNAME) TO SRCH_ARG
         SEEK SRCH_ARG   
         *     IF .NOT. EOF() .AND. ACCOUNT1 <> '8020'
         IF .NOT. EOF()
            STORE RECNO() TO MFST_REC
            SKIP
            IF NAME = SRCH_ARG
               SAVE SCREEN TO MSCREEN
               DO MULTPAY
               IF MACTION = 4  
                  LOOP
               ENDIF
               RESTORE SCREEN FROM MSCREEN
            ELSE
               GOTO MFST_REC
            ENDIF
            STORE NAME TO MNAME
            STORE STREET TO MSTREET
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            STORE ZIP TO MZIP
            STORE DESCRIP TO MDESCRIP
            STORE SUP_INV TO MSUP_INV
            STORE CK_DATE TO MCK_DATE
            STORE AMOUNT1 TO MAMOUNT1
            STORE AMOUNT2 TO MAMOUNT2
            STORE AMOUNT3 TO MAMOUNT3
            STORE AMOUNT4 TO MAMOUNT4
            STORE AMOUNT5 TO MAMOUNT5
            STORE ACCOUNT1 TO MACCOUNT1
            STORE ACCOUNT2 TO MACCOUNT2
            STORE ACCOUNT3 TO MACCOUNT3
            STORE ACCOUNT4 TO MACCOUNT4
            STORE ACCOUNT5 TO MACCOUNT5
            STORE SALESMAN TO MSALESMAN
            IF MPROG_CODE = 1
               STORE SALES1   TO MSALES1
               STORE SALES2   TO MSALES2
               STORE SALES3   TO MSALES3
               STORE SALES4   TO MSALES4
               STORE SALES5   TO MSALES5
            ENDIF
            SELECT B
            IF MACCOUNT1 <> SPACE(4)
               SEEK MACCOUNT1
               IF .NOT. EOF()
                  STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP1
               ELSE
                  STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP1
               ENDIF
            ENDIF
            IF MACCOUNT2 <> SPACE(4)
               SEEK MACCOUNT2
               IF .NOT. EOF()
                  STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP2
               ELSE
                  STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP2
               ENDIF
            ENDIF
            IF MACCOUNT3 <> SPACE(4)
               SEEK MACCOUNT3
               IF .NOT. EOF()
                  STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP3
               ELSE
                  STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP3
               ENDIF
            ENDIF
            IF MACCOUNT4 <> SPACE(4)
               SEEK MACCOUNT4
               IF .NOT. EOF()
                  STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP4
               ELSE 
                  STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP4
               ENDIF
            ENDIF
            IF MACCOUNT5 <> SPACE(4)
               SEEK MACCOUNT5
               IF .NOT. EOF()
                  STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP5
               ELSE 
                  STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP5
               ENDIF
            ENDIF
            SELECT A
            @ 4,14 SAY MNAME PICTURE '@!'
            MNEW_RCD = .F.
         ELSE
            MNEW_RCD = .T.
         ENDIF
      ENDCASE
      @ 5,14 GET MSTREET PICTURE '@!'
      @ 6,14 GET MCITY PICTURE '@!'
      @ 6,52 GET MSTATE PICTURE '@!'
      @ 6,63 GET MZIP PICTURE '#####'
      @ 8,14 GET MCK_DATE
      @ 9,14 GET MSUP_INV PICTURE '@!'
      @ 10,14 GET MDESCRIP PICTURE '@!'
      IF MPROG_CODE = 2
         @ 11,14 GET MSALESMAN PICTURE '##'
      ENDIF
      @ 12,12 GET MAMOUNT1 PICTURE '###,###.##'
      @ 12,35 GET MACCOUNT1 PICTURE '#####'
      @ 12,57 SAY MDESCRIP1
      IF MPROG_CODE = 1
         @ 12,52 GET MSALES1 PICTURE '##'
      ENDIF
      
      @ 14,12 GET MAMOUNT2 PICTURE '###,###.##'
      @ 14,35 GET MACCOUNT2 PICTURE '#####'
      @ 14,57 SAY MDESCRIP2
      IF MPROG_CODE = 1
         @ 14,52 GET MSALES2 PICTURE '##'
      ENDIF
      
      @ 16,12 GET MAMOUNT3 PICTURE '###,###.##'
      @ 16,35 GET MACCOUNT3 PICTURE '#####'
      @ 16,57 SAY MDESCRIP3 
      IF MPROG_CODE = 1
         @ 16,52 GET MSALES3 PICTURE '##'
      ENDIF
      
      @ 18,12 GET MAMOUNT4 PICTURE '###,###.##'
      @ 18,35 GET MACCOUNT4 PICTURE '#####'
      @ 18,57 SAY MDESCRIP4 
      IF MPROG_CODE = 1
         @ 18,52 GET MSALES4 PICTURE '##'
      ENDIF
      
      @ 20,12 GET MAMOUNT5 PICTURE '###,###.##'
      @ 20,35 GET MACCOUNT5 PICTURE '#####'
      @ 20,57 SAY MDESCRIP5 
      IF MPROG_CODE = 1
         @ 20,52 GET MSALES5 PICTURE '##'
      ENDIF
      
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Save/Add Another    2. Edit   3. Save/Finished    4. Cancel'
      READ
      MTOT = MAMOUNT1 + MAMOUNT2 + MAMOUNT3 + MAMOUNT4 + MAMOUNT5
      @ 22,1 SAY 'CHECK TOT:'
      @ 22,12 SAY MTOT PICTURE '###,###.##'
      SELECT B
      IF MACCOUNT1 <> SPACE(4)
         SEEK MACCOUNT1
         IF .NOT. EOF()
            STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP1
         ELSE
            STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP1
         ENDIF
      ENDIF
      IF MACCOUNT2 <> SPACE(4)
         SEEK MACCOUNT2
         IF .NOT. EOF()
            STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP2
         ELSE
            STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP2
         ENDIF
      ENDIF
      IF MACCOUNT3 <> SPACE(4)
         SEEK MACCOUNT3
         IF .NOT. EOF()
            STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP3
         ELSE
            STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP3
         ENDIF
      ENDIF
      IF MACCOUNT4 <> SPACE(4)
         SEEK MACCOUNT4
         IF .NOT. EOF()
            STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP4
         ELSE 
            STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP4
         ENDIF
      ENDIF
      IF MACCOUNT5 <> SPACE(4)
         SEEK MACCOUNT5
         IF .NOT. EOF()
            STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP5
         ELSE 
            STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP5
         ENDIF
      ENDIF
      SELECT A
      @ 12,57 SAY MDESCRIP1
      @ 14,57 SAY MDESCRIP2
      @ 16,57 SAY MDESCRIP3 
      @ 18,57 SAY MDESCRIP4 
      @ 20,57 SAY MDESCRIP5 
      @ 24,9 GET MACTION PICTURE '#' RANGE 1,4
      READ
      IF MACTION = 1 .OR. MACTION = 3
         MMSG = 'ACCOUNT NOT ON FILE'         
         IF MDESCRIP1 = MMSG .OR. MDESCRIP2 = MMSG .OR. MDESCRIP3 = MMSG .OR. MDESCRIP4 = MMSG .OR. MDESCRIP5 = MMSG
            DO CASE
            CASE MDESCRIP1 = MMSG
               STORE 'FIRST ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            CASE MDESCRIP2 = MMSG
               STORE 'SECOND ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            CASE MDESCRIP3 = MMSG
               STORE 'THIRD ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            CASE MDESCRIP4 = MMSG
               STORE 'FOURTH ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            OTHERWISE
               STORE 'FIFTH ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            ENDCASE
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         
         *** MAKE SURE ON MISCELLANEOUS CHECKS, RESERVE DEDUCTIONS CANNOT
         *** BE ENTERED, THOSE ARE ENTERED ON COMMISSION CHECKS ONLY (COM_MENU)
         IF VAL(MACCOUNT1) >= 8401 .AND. VAL(MACCOUNT1) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 1 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT2) >= 8401 .AND. VAL(MACCOUNT2) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 2 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT3) >= 8401 .AND. VAL(MACCOUNT3) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 3 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT4) >= 8401 .AND. VAL(MACCOUNT4) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 4 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         
         IF VAL(MACCOUNT1) >= 8425 .AND. VAL(MACCOUNT1) <= 8450
            IF MSALES1 = SPACE(2) .AND. MPROG_CODE = 1
               @ 24,0 CLEAR
               STORE 'ERROR !!!  NO SALESPERSON CODE ENTERED - PRESS RETURN TO EDIT' TO MJUNK
               @ 24,1 GET MJUNK
               READ
               @ 24,0 CLEAR
               MACTION = 2
               LOOP
            ENDIF
         ENDIF 
         
         IF MACCOUNT1 = '8397' .OR. MACCOUNT1 = '8398' .OR. MACCOUNT1 = '8399' .OR. MACCOUNT1 = '8600' .OR. MACCOUNT1 = '8500'
            IF MSALES1 <> SPACE(2) .AND. MPROG_CODE = 1
               @ 24,0 CLEAR
               STORE 'DO NOT ENTER SALESPERSON ON THESE ACCOUNTS - PRESS RETURN TO EDIT' TO MJUNK
               @ 24,1 GET MJUNK
               READ
               @ 24,0 CLEAR
               MACTION = 2
               LOOP
            ENDIF
         ELSE
            IF MSALES1   = SPACE(2) .AND. MPROG_CODE = 1
               @ 24,0 CLEAR
               STORE '  ' TO MOK
               @ 24,0 SAY 'WARNING !!!  NO SALESPERSON CODE ENTERED - ENTER "OK" IF THAT IS CORRECT ' GET MOK PICTURE '@!'
               READ
               @ 24,0 CLEAR
               IF MOK <> 'OK'
                  MACTION = 2
                  LOOP
               ENDIF
            ENDIF
         ENDIF
         ***** COMMISSION ADVANCES, COMMISSION RESERVE PAYMENTS, ETC.
         *DO CASE
         *CASE MACCOUNT1 = '7301' .OR. MACCOUNT2 = '7301' .OR. MACCOUNT3 = '7301' .OR. MACCOUNT4 = '7301' .OR. MACCOUNT5 = '7301'
         *   @ 22,40 SAY 'ENTER SALESPERSON CODE: ' 
         *   STORE '  ' TO MSALESMAN    
         *   @ 22,64 GET MSALESMAN PICTURE '##'
         *   READ
         *CASE (VAL(MACCOUNT1) >= 8401 .AND. VAL(MACCOUNT1) <= 8450) .OR. ;
         *   (VAL(MACCOUNT2) >= 8401 .AND. VAL(MACCOUNT2) <= 8450) .OR. ;     
         *   (VAL(MACCOUNT3) >= 8401 .AND. VAL(MACCOUNT3) <= 8450)       
         *   @ 22,40 SAY 'ENTER SALESPERSON CODE: ' 
         *   STORE '  ' TO MSALESMAN    
         *   DO WHILE MSALESMAN = '  '
         *      @ 22,64 GET MSALESMAN PICTURE '##'
         *      READ
         *      IF MSALESMAN = '  ' 
         *         MWAIT = ' '
         *         @ 24,1 SAY 'MUST ENTER A SALESPERSON CODE - PRESS RETURN TO REENTER ' GET MWAIT
         *         READ
         *         @ 24,0 CLEAR
         *      ENDIF
         *   ENDDO
         *CASE (VAL(MACCOUNT4) >= 8401 .AND. VAL(MACCOUNT4) <= 8450) .OR. ;
         *   (VAL(MACCOUNT5) >= 8401 .AND. VAL(MACCOUNT5) <= 8450)   
         *   @ 22,40 SAY 'ENTER SALESPERSON CODE: ' 
         *   STORE '  ' TO MSALESMAN    
         *   DO WHILE MSALESMAN = '  '
         *      @ 22,64 GET MSALESMAN PICTURE '##'
         *      READ
         *      IF MSALESMAN = '  ' 
         *         MWAIT = ' '
         *         @ 24,1 SAY 'MUST ENTER A SALESPERSON CODE - PRESS RETURN TO REENTER ' GET MWAIT
         *         READ
         *         @ 24,0 CLEAR
         *      ENDIF
         *   ENDDO
         *   READ
         *CASE MACCOUNT1 = '7150' .OR. MACCOUNT2 = '7150' .OR. MACCOUNT3 = '7150' .OR. MACCOUNT4 = '7150' .OR. MACCOUNT5 = '7150'
         *   @ 22,40 SAY 'ENTER SALESPERSON CODE: ' 
         *   STORE '  ' TO MSALESMAN    
         *   DO WHILE MSALESMAN = '  '
         *      @ 22,64 GET MSALESMAN PICTURE '##'
         *      READ
         *      IF MSALESMAN = '  ' 
         *         MWAIT = ' '
         *         @ 24,1 SAY 'MUST ENTER A SALESPERSON CODE - PRESS RETURN TO REENTER ' GET MWAIT
         *         READ
         *         @ 24,0 CLEAR
         *      ENDIF
         *   ENDDO
         *   READ
         *CASE MACCOUNT1 = '7350' .OR. MACCOUNT2 = '7350' .OR. MACCOUNT3 = '7350' .OR. MACCOUNT4 = '7350' .OR. MACCOUNT5 = '7350'
         *   @ 22,40 SAY 'ENTER SALESPERSON CODE: ' 
         *   STORE '  ' TO MSALESMAN    
         *   DO WHILE MSALESMAN = '  '
         *      @ 22,64 GET MSALESMAN PICTURE '##'
         *      READ
         *      IF MSALESMAN = '  ' 
         *         MWAIT = ' '
         *         @ 24,1 SAY 'MUST ENTER A SALESPERSON CODE - PRESS RETURN TO REENTER ' GET MWAIT
         *         READ
         *         @ 24,0 CLEAR
         *      ENDIF
         *   ENDDO
         *   READ
         *ENDCASE
      ENDIF
   ENDDO
   
   IF MACTION = 4 
      IF MNAME <> '**'
         MMORE = .F.
      ENDIF
      LOOP
   ENDIF
   
   IF MNAME = SPACE(32)
      MMORE = .F.
      LOOP
   ENDIF
   
   IF MNEW_RCD       
      IF MTOT = 0
         LOOP
      ENDIF
      DO FILELOCK
      APPEND BLANK
      REPLACE NAME WITH MNAME
      UNLOCK
   ELSE
      IF MTOT = 0
         DELETE
         LOOP
      ENDIF
   ENDIF
   DO RECLOCK
   REPLACE STREET WITH MSTREET
   REPLACE CITY WITH MCITY
   REPLACE STATE WITH MSTATE
   REPLACE ZIP WITH MZIP
   REPLACE DESCRIP WITH MDESCRIP
   REPLACE SUP_INV WITH MSUP_INV
   REPLACE AMOUNT1 WITH MAMOUNT1
   REPLACE AMOUNT2 WITH MAMOUNT2
   REPLACE AMOUNT3 WITH MAMOUNT3
   REPLACE AMOUNT4 WITH MAMOUNT4
   REPLACE AMOUNT5 WITH MAMOUNT5
   REPLACE ACCOUNT1 WITH MACCOUNT1
   REPLACE ACCOUNT2 WITH MACCOUNT2
   REPLACE ACCOUNT3 WITH MACCOUNT3
   REPLACE ACCOUNT4 WITH MACCOUNT4
   REPLACE ACCOUNT5 WITH MACCOUNT5
   REPLACE CK_DATE WITH MCK_DATE
   REPLACE SALESMAN WITH MSALESMAN
   IF MPROG_CODE = 1
      REPLACE SALES1  WITH MSALES1
      REPLACE SALES2  WITH MSALES2
      REPLACE SALES3  WITH MSALES3
      REPLACE SALES4  WITH MSALES4
      REPLACE SALES5  WITH MSALES5
   ENDIF
   UNLOCK
   
ENDDO
SET PROCEDURE TO PO_PROC
CLOSE DATA
RETURN

PROCEDURE MULTPAY
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MULTIPLE MATCHES SELECT'
@ 3,0 TO 21,79
@  5, 2 SAY 'PAYEES MATCHING YOUR INPUT.  PLEASE SELECT ONE.'
@ 6,5 say 'NAME'
@ 6,42 SAY 'CITY'   
@ 6,70 SAY 'STATE'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC

MMULT_PAY = .T.
DO WHILE MMULT_PAY
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. NAME = SRCH_ARG .AND. MLINE < 20
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      @ MLINE, 5 SAY NAME
      @ MLINE,42 SAY CITY    
      @ MLINE,71 SAY STATE
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. NAME = SRCH_ARG
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Select PAYEE Number: '
   @ 22,25 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Next Pg.  2. Previous Pg.  3. First Pg.  4. Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MMULT_PAY = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1. Next Pg.  2. Previous Pg.  3. First Pg.  4. Cancel'
   @ 24,09 GET MACTION PICTURE '9' RANGE 1,5
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      @ 07,01 CLEAR TO 20,78
      IF .NOT. MORE_FLG
         GOTO MTOP_REC
         STORE MTOP_SEQ - 1 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 2
      @ 07,01 CLEAR TO 20,78
      GOTO MTOP_REC
      STORE MTOP_SEQ - 1 TO MSEQ_NUM
      IF MSEQ_NUM <> 0
         SKIP -13
         STORE MSEQ_NUM - 13 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 3
      @ 07,01 CLEAR TO 20,78
      STORE 0 TO MSEQ_NUM
      GOTO MFST_REC
      LOOP
   CASE MACTION = 4
      MMULT_PAY = .F.
      
   ENDCASE
   
ENDDO
RETURN


PROCEDURE MULTCHK
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MISCELLANEOUS CHECK DISPLAY'
@ 3,0 TO 21,79
@  5, 2 SAY 'PLEASE SELECT ONE.'
@ 6,5 say 'NAME'
@ 6,30 SAY 'CITY'   
@ 6,50 SAY 'STATE'
@ 6,61 SAY 'AMOUNT'
@ 6,70 SAY 'ACCOUNT'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
IF MFST_REC = 0
   @ 12,2 SAY 'NO MISCELLANEOUS CHECKS ON FILE TO BE PRINTED'
   STORE ' ' TO MWAIT
   @ 14,2 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT
   READ
   RETURN
ENDIF
GOTO MFST_REC

MMULT_PAY = .T.
DO WHILE MMULT_PAY
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. MLINE < 20
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      @ MLINE, 5 SAY SUBSTR(NAME,1,20)
      @ MLINE,30 SAY SUBSTR(CITY,1,20)
      @ MLINE,51 SAY STATE
      @ MLINE,57 SAY (AMOUNT1 + AMOUNT2 + AMOUNT3 + AMOUNT4) PICTURE '999,999.99'
      @ MLINE,72 SAY ACCOUNT1
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF()
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Select PAYEE Number: '
   @ 22,25 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Next Pg.  2. Previous Pg.  3. First Pg.  4. Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MMULT_PAY = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1. Next Pg.  2. Previous Pg.  3. First Pg.  4. Cancel'
   @ 24,09 GET MACTION PICTURE '9' RANGE 1,4
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      @ 07,01 CLEAR TO 20,78
      IF .NOT. MORE_FLG
         GOTO MTOP_REC
         STORE MTOP_SEQ - 1 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 2
      @ 07,01 CLEAR TO 20,78
      GOTO MTOP_REC
      STORE MTOP_SEQ - 1 TO MSEQ_NUM
      IF MSEQ_NUM <> 0
         SKIP -13
         STORE MSEQ_NUM - 13 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 3
      @ 07,01 CLEAR TO 20,78
      STORE 0 TO MSEQ_NUM
      GOTO MFST_REC
      LOOP
   CASE MACTION = 4
      MMULT_PAY = .F.
      
   ENDCASE
   
ENDDO
RETURN

* EOF: OTH_DISB.PRG
*Formatted by: ToolBox Ver. 1.2  on 5/2/95 at 8:19 AM.
