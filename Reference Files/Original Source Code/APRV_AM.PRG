**********
* Program.: APRV_AM.PRG
* Author..: Grace Keller
* Date....: 05/17/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: APPROVE AMERICHICKEN THIRD PARTY COMMISSIONS FOR PAYMENT 
*
MTITLE = ' - APPROVE THIRD PARTY AMERICHICKEN COMM FOR PAYMENT'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 24,79
SELECT A
DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.

SELECT C
DO FOX_USE WITH "COMTHD INDEX COMTHD", .T.
SET FILTER TO COM_PD = ' '
GOTO TOP

DO WHILE .NOT. EOF()
   SELECT A
   SEEK C->COM_CODE
   *********SEEK A->COM_CODE
   IF EOF()
      STORE SPACE(2) TO MLED_CODE 
   ELSE
      STORE LED_CODE TO MLED_CODE
   ENDIF
   
   SELECT C
   IF MLED_CODE = SPACE(2)
      REPLACE LED_CODE WITH COM_CODE
   ELSE
      REPLACE LED_CODE WITH MLED_CODE
   ENDIF
   SKIP
ENDDO
SELECT A
USE
SELECT C
USE

SELECT C
DO FOX_USE WITH "COMTHD", .T.
INDEX ON COM_PD + LED_CODE TO COMTPD
USE

MNEXT_COM = .T.
DIMENSION MUPDRCD(15)  
DIMENSION MSELECT(15)
DIMENSION MAMOUNT(15)

DO WHILE MNEXT_COM
   STORE SPACE(32) TO MNAME
   STORE 'NO ' TO MYES_NO
   STORE 2 TO MACTION
   DO WHILE MACTION = 2
      @ 10,5 SAY 'THIRD PARTY COMMISSION PAYEE'
      @ 12,5 GET MNAME PICTURE '@!'
      @ 15,5 SAY 'Override Payment Status (YES/NO):' GET MYES_NO PICTURE '@!' VALID(MYES_NO = 'YES' .OR. MYES_NO = 'NO')
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2. Edit    3. Cancel'    
      READ
      @ 24,9 GET MACTION PICTURE '9' RANGE 1,3
      READ
      IF MACTION = 1
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
         SEEK TRIM(MNAME)
         IF EOF()
            @ 24,0 SAY SPACE(79)
            STORE ' ' TO MWAIT
            @ 24,1 SAY 'THIRD PARTY COMMISSION PAYEE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
            READ
            @ 24,0 SAY SPACE(79)
            MACTION = 2
         ELSE
            STORE RECNO() TO MFST_REC
            SKIP
            STORE TRIM(MNAME) TO SRCH_ARG
            IF NAME = SRCH_ARG    
               MNAME_FD = .F.
               DO MULTCOM
               IF MNAME_FD
                  STORE NAME TO MNAME
                  STORE COM_CODE TO MCOM_CODE
                  MACTION = 1
               ELSE
                  MACTION = 3
                  LOOP
               ENDIF
            ELSE
               GOTO MFST_REC
               STORE NAME TO MNAME
               STORE COM_CODE TO MCOM_CODE
            ENDIF
         ENDIF
      ENDIF
   ENDDO
   IF MACTION = 3
      MNEXT_COM = .F.
      LOOP
   ENDIF
   
   SELECT B
   DO FOX_USE WITH "&MMASTDBF.PO_HEAD INDEX &MMASTDBF.PO_HEAD", .F.
   SELECT E
   DO FOX_USE WITH "&MMASTDBF.CUS_INV INDEX &MMASTDBF.CUSIVNBR", .F.
   
   SELECT C
   DO FOX_USE WITH "&MMASTDBF.COMTHD INDEX &MMASTDBF.COMTPD, COMTDT, COMTHD", .F.
   
   MTOTAL = 0
   MTITLE = ' - APPROVE THIRD PARTY AMERICHICKEN COMM FOR PAYMENT'
   CLEAR
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 to 24,79
   @ 04,1 SAY MNAME
   @ 4,40 SAY 'AMT APPROVED'
   @ 06,1 TO 06,78
   
   @ 07,1  SAY '     Sel      Amt Due     P.O. Nbr.     Inv. Nbr    Inv/Cor       Ship Dt'
   *            123456789012345678901234567890123456789012345678901234567890123456789012345678   
   *                     10        20        30        40        50        60        70
   SEEK ' ' + MCOM_CODE
   IF EOF()
      @ 10,5 SAY 'THERE ARE NO COMMISSIONS TO PAY FOR THIS THIRD PARTY'
      STORE ' ' TO MWAIT
      @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
      READ
      RETURN
   ENDIF
   
   STORE RECNO() TO MRECNO, MFST_REC
   MTOTAL = 0   
   MMORE = .T.
   DO WHILE MMORE
      STORE ' ' TO MSELECT
      STORE 0 TO MUPDRCD, MADJUST
      GOTO MRECNO
      MLINE = 08
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      @ 04,1 SAY MNAME
      @ 4,40 SAY 'AMT APPROVED'
      @ 06,1 TO 06,78
      @ 07,1  SAY '     Sel      Amt Due     P.O. Nbr.     Inv. Nbr    Inv/Cor       Ship Dt'
      
      MPAGE_TOT = 0
      DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. COM_PD = ' ' .AND. COM_TYPE = 'T' .AND. LED_CODE = MCOM_CODE .AND. MMORE
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         SELECT B
         DO FOX_USE WITH "&MMASTDBF.PO_HEAD INDEX &MMASTDBF.PO_HEAD", .F.
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         STORE INV_NBR TO MINV_NBR
         STORE SHIP_DATE TO MSHIP_DATE
         MPAID = .T.
         IF MYES_NO = 'NO'
            SELECT E
            DO FOX_USE WITH "&MMASTDBF.CUS_INV INDEX &MMASTDBF.CUSIVNBR", .F.
            SEEK MINV_NBR
            IF .NOT. EOF()
               IF PAID_FLG = ' '
                  MPAID = .F.
               ENDIF
            ENDIF
         ENDIF
         SELECT C
         I = MLINE - 7 
         STORE RECNO() TO MUPDRCD(I)
         STORE AMOUNT TO MAMOUNT(I)
         IF APRVD_FLG <> ' '
            STORE 'X' TO MSELECT(I)
            MPAGE_TOT = MPAGE_TOT + MAMOUNT(I)  
         ELSE 
            IF MPAID
               STORE ' ' TO MSELECT(I)
            ELSE
               STORE 'N' TO MSELECT(I)
            ENDIF
         ENDIF
         @ MLINE,1 SAY STR(I,2) + '.'
         
         @ MLINE,12 SAY AMOUNT PICTURE '999,999.99'
         IF SALESMAN <> SPACE(2)
            @ MLINE,27 SAY SALESMAN + '-'
         ENDIF
         @ MLINE,30 SAY PO_NBR
         IF PO_SUFFIX <> ' '
            @ MLINE,34 SAY '-' + PO_SUFFIX
         ENDIF
         IF SALESMAN <> SPACE(2)
            @ MLINE,41 SAY SALESMAN + '-'
         ENDIF
         @ MLINE,44 SAY MINV_NBR
         IF COR_FLG = 'I' .OR. COR_FLG = ' '
            @ MLINE,53 SAY 'INVOICE'     
         ELSE
            @ MLINE,53 SAY 'CORRECTION'
         ENDIF
         @ MLINE,67 SAY MSHIP_DATE
         SKIP
         MLINE = MLINE + 1
      ENDDO
      MMAX_LINE = MLINE - 1
      STORE RECNO() TO MRECNO
      IF .NOT. EOF() .AND. COM_PD = ' ' .AND. LED_CODE = MCOM_CODE
         @ 23,70 SAY "More PO's"
         MBLURP = .T.
      ELSE
         @ 23,70 CLEAR TO 23,79
         MBLURP = .F.
      ENDIF
      @ 5,41 SAY MTOTAL + MPAGE_TOT PICTURE '999,999.99'
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         MLINE = 8
         I = 1
         DO WHILE MLINE <= MMAX_LINE
            IF MSELECT(I) = 'N'
               @ MLINE,7 SAY MSELECT(I)
            ELSE
               @ MLINE,7 GET MSELECT(I) PICTURE '@!'
            ENDIF
            MLINE = MLINE + 1
            I = I + 1
         ENDDO
         IF MBLURP
            STORE 3 TO MACTION
         ELSE
            STORE 1 TO MACTION
         ENDIF
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         IF MBLURP
            @ 24,13 SAY '1. Save & Return    2. Edit    3. Next Page    4. Cancel'    
         ELSE
            @ 24,13 SAY '1. Save & Return    2. Edit    3. Cancel'    
         ENDIF
         
         READ
         MPAGE_TOT = 0
         I = 1
         DO WHILE I <= 15
            IF MUPDRCD(I) = 0
               I = I + 1
               LOOP
            ENDIF
            IF MSELECT(I) <> 'N' .AND. MSELECT(I) <> ' ' .AND. MSELECT(I) <> 'X' .AND. MSELECT(I) <> 'S'
               @ 24,0 SAY SPACE(79)
               MWAIT = ' '
               @ 24,0 SAY "SELECT OPTION MUST BE ' ' OR 'X' OR 'S' - PRESS RETURN TO REENTER " GET MWAIT
               READ
               @ 24,0 SAY SPACE(79)
               I = 99
               MACTION = 2
               LOOP
            ENDIF
            IF MSELECT(I) = 'N'
               I = I + 1
               LOOP
            ENDIF
            IF MSELECT(I) = 'S'
               *** DO THE SPLIT THING HERE
               @ 24,0 SAY SPACE(79)
               SELECT C
               GOTO MUPDRCD(I)
               STORE AMOUNT TO MAMOUNT
               @ 24,1 SAY 'Amt to Split: ' 
               @ 24,15 SAY TRANSFORM(MAMOUNT, '999,999.99')
               @ 24,30 SAY 'Entry Amt 1: '
               @ 24,55 SAY 'Entry Amt 2: '
               STORE 0 TO MAMOUNT1, MAMOUNT2
               @ 24,43 GET MAMOUNT1 PICTURE '999,999.99'
               @ 24,68 GET MAMOUNT2 PICTURE '999,999.99'
               READ
               IF MAMOUNT1+MAMOUNT2 <> MAMOUNT
                  @ 24,0 SAY SPACE(79)
                  STORE ' ' TO MWAIT
                  @ 24,0 say 'Two Split Amounts Entered Do Not Add to Original Amount ' get mwait
                  READ
                  I = 16
                  MACTION = 4
                  LOOP
               ENDIF
               
               STORE COM_CODE TO SCOM_CODE
               STORE COM_TYPE TO SCOM_TYPE
               STORE LED_CODE TO SLED_CODE
               STORE SALESMAN TO SSALESMAN
               STORE THD_SEQ  TO STHD_SEQ
               STORE INV_NBR  TO SINV_NBR
               STORE PO_NBR   TO SPO_NBR
               STORE PO_SUFFIX TO SPO_SUFFIX
               STORE AMOUNT    TO SAMOUNT
               STORE TRAN_DATE TO STRAN_DATE
               STORE POST_DATE TO SPOST_DATE
               STORE TRAN_YR   TO STRAN_YR
               STORE TRAN_MO   TO STRAN_MO
               STORE COR_FLG   TO SCOR_FLG
               STORE APRVD_FLG TO SAPRVD_FLG
               STORE COM_PD    TO SCOM_PD
               STORE PAID_DATE TO SPAID_DATE
               STORE CK_NBR    TO SCK_NBR
               STORE ADV_REP   TO SADV_REP
               STORE TOT_LBS   TO STOT_LBS
               STORE SEQ       TO SSEQ
               STORE FED_KEY   TO SFED_KEY
               DO FILELOCK
               APPEND BLANK
               REPLACE COM_CODE WITH SCOM_CODE
               REPLACE COM_TYPE WITH SCOM_TYPE
               REPLACE LED_CODE WITH SLED_CODE
               REPLACE SALESMAN WITH SSALESMAN
               REPLACE THD_SEQ  WITH STHD_SEQ
               REPLACE INV_NBR WITH MINV_NBR
               REPLACE PO_NBR  WITH SPO_NBR
               REPLACE PO_SUFFIX WITH SPO_SUFFIX
               REPLACE AMOUNT    WITH MAMOUNT1
               REPLACE TRAN_DATE WITH STRAN_DATE
               REPLACE POST_DATE WITH SPOST_DATE
               REPLACE TRAN_YR   WITH STRAN_YR
               REPLACE TRAN_MO   WITH STRAN_MO
               REPLACE COR_FLG   WITH SCOR_FLG
               REPLACE APRVD_FLG WITH SAPRVD_FLG
               REPLACE COM_PD    WITH SCOM_PD
               REPLACE PAID_DATE WITH SPAID_DATE
               REPLACE CK_NBR    WITH SCK_NBR
               REPLACE ADV_REP   WITH SADV_REP
               REPLACE TOT_LBS   WITH STOT_LBS
               REPLACE SEQ       WITH SSEQ
               REPLACE FED_KEY   WITH SFED_KEY
               APPEND BLANK
               REPLACE COM_CODE WITH SCOM_CODE
               REPLACE COM_TYPE WITH SCOM_TYPE
               REPLACE LED_CODE WITH SLED_CODE
               REPLACE SALESMAN WITH SSALESMAN
               REPLACE THD_SEQ  WITH STHD_SEQ
               REPLACE INV_NBR WITH MINV_NBR
               REPLACE PO_NBR  WITH SPO_NBR
               REPLACE PO_SUFFIX WITH SPO_SUFFIX
               REPLACE AMOUNT    WITH MAMOUNT2
               REPLACE TRAN_DATE WITH STRAN_DATE
               REPLACE POST_DATE WITH SPOST_DATE
               REPLACE TRAN_YR   WITH STRAN_YR
               REPLACE TRAN_MO   WITH STRAN_MO
               REPLACE COR_FLG   WITH SCOR_FLG
               REPLACE APRVD_FLG WITH SAPRVD_FLG
               REPLACE COM_PD    WITH SCOM_PD
               REPLACE PAID_DATE WITH SPAID_DATE
               REPLACE CK_NBR    WITH SCK_NBR
               REPLACE ADV_REP   WITH SADV_REP
               REPLACE TOT_LBS   WITH STOT_LBS
               REPLACE SEQ       WITH SSEQ
               REPLACE FED_KEY   WITH SFED_KEY
               GOTO MUPDRCD(I)
               DELETE
               UNLOCK
               I = 16
               MACTION = 4
               LOOP
            ENDIF
            IF MSELECT(I) = 'X'
               MPAGE_TOT = MPAGE_TOT + MAMOUNT(I)
            ENDIF
            I = I + 1
         ENDDO
         **** THIS IS AN ERROR
         IF MLINE = 99 .OR. MACTION = 4
            LOOP
         ENDIF
         @ 5,41 SAY MTOTAL + MPAGE_TOT PICTURE '999,999.99'
         
         IF MBLURP
            @24,09 GET MACTION PICTURE '9' RANGE 1,4
         ELSE
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
         ENDIF
         READ               
      ENDDO          
      
      IF .NOT. MBLURP
         IF MACTION = 3
            MACTION = 4
         ENDIF
      ENDIF
      IF MACTION = 4
         MMORE = .F.
         
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         STORE ' ' TO MYES_NO
         @ 10,5 SAY 'DO YOU WANT TO SELECT/APPROVE MORE COMMISSIONS (Y/N)? ' GET MYES_NO PICTURE '@!'
         READ
         IF MYES_NO <> 'Y'
            MNEXT_COM = .F.
         ENDIF
         @ 10,5 SAY SPACE(60)
         LOOP
      ENDIF
      
      I = 1 
      DO WHILE I <= 15
         IF MUPDRCD(I) = 0
            I = I + 1
            LOOP
         ENDIF
         IF MSELECT(I) = 'N'
            I = I + 1
            LOOP
         ENDIF
         GOTO MUPDRCD(I)
         DO RECLOCK
         IF MSELECT(I) = ' '
            IF APRVD_FLG <> ' '
               REPLACE APRVD_FLG WITH ' '
            ENDIF
         ELSE
            IF APRVD_FLG = ' '
               REPLACE APRVD_FLG WITH 'Y'       
            ENDIF
         ENDIF
         UNLOCK 
         I = I + 1
      ENDDO
      MTOTAL = MTOTAL + MPAGE_TOT
      @ 5,41 SAY MTOTAL PICTURE '999,999.99'
      
      IF MACTION <> 3
         MMORE = .F.
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         STORE ' ' TO MYES_NO
         @ 10,5 SAY 'DO YOU WANT TO APPROVE MORE COMMISSIONS (Y/N)? ' GET MYES_NO PICTURE '@!'
         READ
         IF MYES_NO <> 'Y'
            MNEXT_COM = .F.
         ENDIF
         @ 10,5 SAY SPACE(60)
      ENDIF
   ENDDO
ENDDO

CLOSE DATA

RETURN
* EOF: APRV_AM.PRG
*Formatted by: ToolBox Ver. 1.2  on 7/25/14 at 2:36 PM.
