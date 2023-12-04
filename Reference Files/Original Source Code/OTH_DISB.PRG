**********
* Program.: OTH_DISB.PRG
* Author..: GRACE KELLER
* Date....: 03/11/88
* Notice..: Copyright 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MISCELLANEOUS DISBURSEMENTS
*
* ---PROCESSING LOOP
SET PROCEDURE TO OTH_DISB

SELECT F
DO FOX_USE WITH "PAYEES INDEX PAYEES", .F.

SELECT C
DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
SELECT B
DO FOX_USE WITH "&MMASTDBF.ACCOUNTS INDEX &MMASTDBF.ACCOUNTS", .F.
SELECT A
DO FOX_USE WITH "MAN_CK INDEX MAN_CK", .F.

IF MUSER <> 'SUPERVISOR'
   SET FILTER TO USER = MUSER
   GOTO TOP
ENDIF

MMORE = .T.
DO WHILE MMORE
   CLEAR
   @ 1,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 02,00 SAY MPROGRAM + ' - MISCELLANEOUS MANUAL DISBURSEMENTS'
   @ 03,00 TO 24,79 
   
   @ 4,6 SAY ' PAYEE: ' 
   @ 5,6 SAY 'STREET: '
   @ 6,6 SAY '  CITY: ' 
   @ 6,45 SAY 'STATE: ' 
   @ 6,58 SAY 'ZIP:      -'
   @ 7,1 SAY ' CHECK DATE: '
   @ 7,35 SAY 'DESCRIPTION: '
   @ 09,1 SAY '         AMOUNT   ACCT  SALESMAN  INV NBR'         
   @ 10,1 SAY ' 1.'                
   @ 11,1 SAY ' 2.'
   @ 12,1 SAY ' 3.'
   @ 13,1 SAY ' 4.'
   @ 14,1 SAY ' 5.'
   @ 15,1 SAY ' 6.'
   @ 16,1 SAY ' 7.'
   @ 17,1 SAY ' 8.'
   @ 18,1 SAY ' 9.'
   @ 19,1 SAY '10.'
   @ 20,1 SAY '11.'
   @ 21,1 SAY '12.'
   
   
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Save/Add Another    2. Edit   3. Save/Finished    4. Cancel'
   STORE SPACE(32) TO MNAME
   STORE CTOD(' ') TO MCK_DATE
   STORE SPACE(25) TO MSTREET 
   STORE SPACE(20) TO MCITY
   STORE SPACE(2) TO MSTATE, MSALESMAN
   STORE SPACE(2) TO MSALES01, MSALES02, MSALES03, MSALES04, MSALES05, MSALES06
   STORE SPACE(2) TO MSALES07, MSALES08, MSALES09, MSALES10, MSALES11, MSALES12
   STORE SPACE(15) TO MINV01, MINV02, MINV03, MINV04, MINV05, MINV06
   STORE SPACE(15) TO MINV07, MINV08, MINV09, MINV10, MINV11, MINV12
   STORE SPACE(5) TO MZIP
   STORE SPACE(4) TO MZIP4
   STORE 0 TO MAMOUNT01, MAMOUNT02, MAMOUNT03, MAMOUNT04, MAMOUNT05, MAMOUNT06
   STORE 0 TO MAMOUNT07, MAMOUNT08, MAMOUNT09, MAMOUNT10, MAMOUNT11, MAMOUNT12
   STORE SPACE(4) TO MACCOUNT01, MACCOUNT02, MACCOUNT03, MACCOUNT04, MACCOUNT05, MACCOUNT06
   STORE SPACE(4) TO MACCOUNT07, MACCOUNT08, MACCOUNT09, MACCOUNT10, MACCOUNT11, MACCOUNT12
   STORE SPACE(20) TO MDESCRIP01, MDESCRIP02, MDESCRIP03, MDESCRIP04, MDESCRIP05, MDESCRIP06
   STORE SPACE(20) TO MDESCRIP07, MDESCRIP08, MDESCRIP09, MDESCRIP10, MDESCRIP11, MDESCRIP12
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
      @ 6,69 GET MZIP4 PICTURE '####'
      @ 7,14 GET MCK_DATE
      @ 7,48 GET MDESCRIP PICTURE '@!'
      
      MLINE = 10
      I = 1
      DO WHILE I<=12
         MI = SUBSTR(STR(I+100,3),2)
         @ MLINE,06 GET MAMOUNT&MI PICTURE '###,###.##'
         @ MLINE,19 GET MACCOUNT&MI PICTURE '####'
         @ MLINE,29 GET MSALES&MI PICTURE '@!'
         @ MLINE,35 GET MINV&MI
         I = I + 1
         MLINE = MLINE + 1
      ENDDO
      
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
         STORE ZIP4 TO MZIP4
         STORE DESCRIP TO MDESCRIP
         STORE SUP_INV TO MSUP_INV
         STORE CK_DATE TO MCK_DATE
         STORE SALESMAN TO MSALESMAN
         
         I = 1
         DO WHILE I<=12
            MI = SUBSTR(STR(I+100,3),2)
            STORE AMOUNT&MI  TO MAMOUNT&MI
            STORE ACCOUNT&MI TO MACCOUNT&MI
            STORE INV&MI     TO MINV&MI
            STORE SALES&MI   TO MSALES&MI
            I = I + 1
         ENDDO
         
         @ 4,14 SAY MNAME PICTURE '@!'
         MNEW_RCD = .F.
         SELECT B
         I = 1
         DO WHILE I<=12
            MI = SUBSTR(STR(I+100,3),2)
            IF MACCOUNT&MI <> SPACE(4) .OR. MAMOUNT&MI <> 0
               SEEK MACCOUNT&MI
               IF .NOT. EOF()
                  STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP&MI
               ELSE
                  STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP&MI
               ENDIF
            ENDIF
            I = I + 1
         ENDDO
         SELECT A
         
      OTHERWISE
         STORE TRIM(MNAME) TO SRCH_ARG
         SEEK SRCH_ARG   
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
            STORE ZIP4 TO MZIP4
            STORE DESCRIP TO MDESCRIP
            STORE SUP_INV TO MSUP_INV
            STORE CK_DATE TO MCK_DATE
            STORE SALESMAN TO MSALESMAN
            I = 1
            DO WHILE I<=12
               MI = SUBSTR(STR(I+100,3),2)
               STORE AMOUNT&MI  TO MAMOUNT&MI
               STORE ACCOUNT&MI TO MACCOUNT&MI
               STORE INV&MI     TO MINV&MI
               STORE SALES&MI   TO MSALES&MI
               I = I + 1
            ENDDO
            SELECT B
            I = 1
            DO WHILE I<=12
               MI = SUBSTR(STR(I+100,3),2)
               IF MACCOUNT&MI <> SPACE(4)
                  SEEK MACCOUNT&MI
                  IF .NOT. EOF()
                     STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP&MI
                  ELSE
                     STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP&MI
                  ENDIF
               ENDIF
               I = I + 1
            ENDDO
            
            SELECT A
            @ 4,14 SAY MNAME PICTURE '@!'
            MNEW_RCD = .F.
            MPAY_ADD = .F.
         ELSE
            MNEW_RCD = .T.
            MPAY_ADD = .F.
            MNAME_FD = .F.
            SELECT F
            STORE TRIM(MNAME) TO SRCH_ARG
            SEEK SRCH_ARG
            IF EOF()
               MPAY_ADD = .T.
            ELSE
               STORE RECNO() TO MFST_REC
               SKIP
               IF NAME = SRCH_ARG    
                  SAVE SCREEN TO MSCREEN
                  DO MULTPAYS
                  RESTORE SCREEN FROM MSCREEN
                  IF MNAME_FD .AND. .NOT. MPAY_ADD
                     STORE NAME TO MNAME
                     STORE STREET TO MSTREET  
                     STORE CITY   TO MCITY
                     STORE STATE  TO MSTATE
                     STORE ZIP    TO MZIP
                     STORE ZIP4   TO MZIP4
                  ENDIF
                  
               ELSE
                  GOTO MFST_REC
                  STORE NAME TO MNAME
                  STORE STREET TO MSTREET  
                  STORE CITY   TO MCITY
                  STORE STATE  TO MSTATE
                  STORE ZIP    TO MZIP
                  STORE ZIP4   TO MZIP4
               ENDIF
            ENDIF
            SELECT A
         ENDIF
      ENDCASE
      @ 5,14 GET MSTREET PICTURE '@!'
      @ 6,14 GET MCITY PICTURE '@!'
      @ 6,52 GET MSTATE PICTURE '@!'
      @ 6,63 GET MZIP PICTURE '#####'
      @ 6,69 GET MZIP4 PICTURE '####'
      @ 7,14 GET MCK_DATE
      @ 7,48 GET MDESCRIP PICTURE '@!'
      
      
      MLINE = 10
      I = 1
      DO WHILE I<=12
         MI = SUBSTR(STR(I+100,3),2)
         @ MLINE,06 GET MAMOUNT&MI PICTURE '###,###.##'
         @ MLINE,19 GET MACCOUNT&MI PICTURE '####'
         @ MLINE,29 GET MSALES&MI PICTURE '@!'
         @ MLINE,35 GET MINV&MI
         @ MLINE,55 SAY MDESCRIP&MI
         I = I + 1
         MLINE = MLINE + 1
      ENDDO
      
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Save/Add Another    2. Edit   3. Save/Finished    4. Cancel'
      READ
      MTOT = MAMOUNT01 + MAMOUNT02 + MAMOUNT03 + MAMOUNT04 + MAMOUNT05 + MAMOUNT06
      MTOT = MTOT + MAMOUNT07 + MAMOUNT08 + MAMOUNT09 + MAMOUNT10 + MAMOUNT11 + MAMOUNT12
      @ 22,1 SAY 'TOT:'
      @ 22,06 SAY MTOT PICTURE '###,###.##'
      SELECT B
      
      
      
      SELECT B
      I = 1
      DO WHILE I<=12
         MI = SUBSTR(STR(I+100,3),2)
         IF MACCOUNT&MI <> SPACE(4)
            SEEK MACCOUNT&MI
            IF .NOT. EOF()
               STORE SUBSTR(CK_DESC,1,22) TO MDESCRIP&MI
            ELSE
               STORE 'ACCOUNT NOT ON FILE' TO MDESCRIP&MI
            ENDIF
         ENDIF
         I = I + 1
      ENDDO
      SELECT A
      MLINE = 10
      I = 1
      DO WHILE I<=12
         MI = SUBSTR(STR(I+100,3),2)
         @ MLINE,55 SAY MDESCRIP&MI
         I = I + 1
         MLINE = MLINE + 1
      ENDDO
      
      @ 24,9 GET MACTION PICTURE '#' RANGE 1,4
      READ
      IF MACTION = 1 .OR. MACTION = 3
         
         MMSG = 'ACCOUNT NOT ON FILE'
         DO CASE
         CASE MDESCRIP01 = MMSG
            STORE 'NBR 1 ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         CASE MDESCRIP02 = MMSG
            STORE 'NBR 2 ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         CASE MDESCRIP03 = MMSG
            STORE 'NBR 3 ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         CASE MDESCRIP04 = MMSG
            STORE 'NBR 4 ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         CASE MDESCRIP05 = MMSG
            STORE 'NBR 5 ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         CASE MDESCRIP06 = MMSG
            STORE 'NBR 6 ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         CASE MDESCRIP07 = MMSG
            STORE 'NBR 7 ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         CASE MDESCRIP08 = MMSG
            STORE 'NBR 8 ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         CASE MDESCRIP09 = MMSG
            STORE 'NBR 9 ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         CASE MDESCRIP10 = MMSG
            STORE 'NBR 10 ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         CASE MDESCRIP11 = MMSG
            STORE 'NBR 11 ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         CASE MDESCRIP12 = MMSG
            STORE 'NBR 12 ACCOUNT CODE INVALID - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,0 CLEAR
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         OTHERWISE
         ENDCASE
         
         SELECT E
         DO FOX_USE WITH "DISBJRN INDEX DISBJRN", .F.
         
         SET FILTER TO ACCT_TYPE = 'O' .AND. ACCT_NAME = MNAME .AND. bill_inv <> space(12) .AND. VOID_MAN <> 'V'
         GOTO TOP
         
         MDATE_CHK = DATE() - 60
         
         MMATCH = .F.
         
         STORE DTOC(MDATE_CHK) TO MXX
         SEEK SUBSTR(MXX,7,4) + SUBSTR(MXX,1,2)
         IF EOF()
            SEEK SUBSTR(MXX,7,4)
         ENDIF
         DO WHILE .NOT. EOF() .AND. CTOD(JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR) < MDATE_CHK
            SKIP
         ENDDO
         IF .NOT. EOF()
            STORE RECNO() TO MSTRT_REC
            
            I = 1
            DO WHILE I<=12
               MI = SUBSTR(STR(I+100,3),2)
               IF MACCOUNT&MI = SPACE(4) .or. MINV&MI = SPACE(12)
                  I = I + 1
                  LOOP
               ENDIF
               
               GOTO MSTRT_REC
               MMATCH = .F.
               
               DO WHILE .NOT. EOF()
                  IF CATEGORY1 = MACCOUNT&MI .AND. UPPER(MINV&MI) = UPPER(BILL_INV) 
                     MMATCH = .T.
                     STORE CTOD(JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR) TO MERR_DATE
                     STORE CK_NBR TO MERR_CHK
                     GOTO BOTTOM
                  ENDIF
                  SKIP
               ENDDO
               
               IF MMATCH
                  @ 24,0 CLEAR
                  STORE 'PAID ' + TRIM(MINV&MI) + ' ON ' + dtoc(MERR_DATE) + ' WITH CHK# ' + LTRIM(MERR_CHK) + ' - Press Return to Reenter'  TO MMSG
                  @ 24,1 GET MMSG
                  READ
                  @ 24,0 CLEAR
                  I = 15
                  LOOP
               ENDIF
               I = I + 1
            ENDDO
            
            IF MMATCH
               MACTION = 2
               SELECT E
               USE
               SELECT A
               LOOP
            ENDIF
         ENDIF   
         SELECT E
         USE
               
         SELECT A
         
         ** MAKE SURE IF ENTERED AS THIRD PARTY SALES1 = 'TP'
         ** THAT THE THIRD PARTY NAME IS ON FILE
         IF MSALES01 = 'TP' .OR. MSALES02 = 'TP' .OR. MSALES03 = 'TP' .OR. MSALES04 = 'TP' .OR. MSALES05 = 'TP' .OR. MSALES06 = 'TP'
            SELECT E
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
            SEEK MNAME
            IF EOF()
               @ 24,0 CLEAR
               STORE 'SALESMAN=TP, BUT NAME NOT ON FILE AS THIRD PARTY - PRESS RETURN TO EDIT' TO MJUNK
               @ 24,1 GET MJUNK
               READ
               @ 24,0 CLEAR
               MACTION = 2
               SELECT A
               LOOP
            ELSE
               *** MAKE SURE THE COM CODE IS STORED FOR CHECK PRINT
               STORE COM_CODE TO MSALESMAN
            ENDIF
         ENDIF
         IF MSALES07 = 'TP' .OR. MSALES08 = 'TP' .OR. MSALES09 = 'TP' .OR. MSALES10 = 'TP' .OR. MSALES11 = 'TP' .OR. MSALES12 = 'TP'
            SELECT E
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
            SEEK MNAME
            IF EOF()
               @ 24,0 CLEAR
               STORE 'SALESMAN=TP, BUT NAME NOT ON FILE AS THIRD PARTY - PRESS RETURN TO EDIT' TO MJUNK
               @ 24,1 GET MJUNK
               READ
               @ 24,0 CLEAR
               MACTION = 2
               SELECT A
               LOOP
            ELSE
               *** MAKE SURE THE COM CODE IS STORED FOR CHECK PRINT
               STORE COM_CODE TO MSALESMAN
            ENDIF
         ENDIF
         SELECT A
         
         *** MAKE SURE ON MISCELLANEOUS CHECKS, RESERVE DEDUCTIONS CANNOT
         *** BE ENTERED, THOSE ARE ENTERED ON COMMISSION CHECKS ONLY (COM_MENU)
         
         IF VAL(MACCOUNT01) >= 8401 .AND. VAL(MACCOUNT01) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 1 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT02) >= 8401 .AND. VAL(MACCOUNT02) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 2 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT03) >= 8401 .AND. VAL(MACCOUNT03) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 3 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT04) >= 8401 .AND. VAL(MACCOUNT04) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 4 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT05) >= 8401 .AND. VAL(MACCOUNT05) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 5 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT06) >= 8401 .AND. VAL(MACCOUNT06) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 6 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT07) >= 8401 .AND. VAL(MACCOUNT07) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 7 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT08) >= 8401 .AND. VAL(MACCOUNT08) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 8 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT09) >= 8401 .AND. VAL(MACCOUNT09) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 9 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT10) >= 8401 .AND. VAL(MACCOUNT10) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 10 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT11) >= 8401 .AND. VAL(MACCOUNT11) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 11 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         IF VAL(MACCOUNT12) >= 8401 .AND. VAL(MACCOUNT12) <= 8424
            @ 24,0 CLEAR
            STORE 'ACCOUNT 12 CANNOT BE ENTERED AS RESERVE DEDUCT - PRESS RETURN TO EDIT' TO MJUNK
            @ 24,1 GET MJUNK
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
         
         IF VAL(MACCOUNT01) >= 8425 .AND. VAL(MACCOUNT01) <= 8450
            IF MSALES01 = SPACE(2) .AND. MPROG_CODE = 1
               @ 24,0 CLEAR
               STORE 'ERROR !!!  NO SALESPERSON CODE ENTERED - PRESS RETURN TO EDIT' TO MJUNK
               @ 24,1 GET MJUNK
               READ
               @ 24,0 CLEAR
               MACTION = 2
               LOOP
            ENDIF
         ENDIF 
         
         IF MACCOUNT01 = '8397' .OR. MACCOUNT01 = '8398' .OR. MACCOUNT01 = '8399' .OR. MACCOUNT01 = '8600' .OR. MACCOUNT01 = '8500'
            IF MSALES01 <> SPACE(2) .AND. MPROG_CODE = 1
               @ 24,0 CLEAR
               STORE 'DO NOT ENTER SALESPERSON ON THESE ACCOUNTS - PRESS RETURN TO EDIT' TO MJUNK
               @ 24,1 GET MJUNK
               READ
               @ 24,0 CLEAR
               MACTION = 2
               LOOP
            ENDIF
         ELSE
            IF MSALES01   = SPACE(2) .AND. MPROG_CODE = 1
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
   
   SELECT F
   IF MPAY_ADD
      DO FILELOCK
      APPEND BLANK
      REPLACE NAME   WITH MNAME
      REPLACE STREET WITH MSTREET
      REPLACE CITY   WITH MCITY
      REPLACE STATE  WITH MSTATE
      REPLACE ZIP    WITH MZIP
      REPLACE ZIP4   WITH MZIP4
      UNLOCK
   ELSE
      SEEK MNAME + MSTREET
      IF EOF()
         DO FILELOCK
         APPEND BLANK
         REPLACE NAME   WITH MNAME
         REPLACE STREET WITH MSTREET
         REPLACE CITY   WITH MCITY
         REPLACE STATE  WITH MSTATE
         REPLACE ZIP    WITH MZIP
         REPLACE ZIP4   WITH MZIP4
         UNLOCK
      ENDIF
   ENDIF
   
   SELECT A
   IF MNEW_RCD       
      IF MTOT = 0
         LOOP
      ENDIF
      DO FILELOCK
      APPEND BLANK
      REPLACE NAME WITH MNAME
      REPLACE USER WITH MUSER
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
   REPLACE ZIP4 WITH MZIP4
   REPLACE DESCRIP WITH MDESCRIP
   REPLACE SUP_INV WITH MSUP_INV
   REPLACE CK_DATE WITH MCK_DATE
   REPLACE SALESMAN WITH MSALESMAN
   I = 1
   DO WHILE I<= 12
      MI = SUBSTR(STR(I+100,3),2)
      REPLACE AMOUNT&MI WITH MAMOUNT&MI
      REPLACE ACCOUNT&MI WITH MACCOUNT&MI
      REPLACE SALES&MI  WITH MSALES&MI
      REPLACE INV&MI WITH MINV&MI
      I = I + 1
   ENDDO
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
*Formatted by: ToolBox Ver. 1.2  on 8/27/20 at 8:56 AM.
