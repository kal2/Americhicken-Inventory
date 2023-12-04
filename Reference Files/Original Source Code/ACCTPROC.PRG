****************
* Program.: ACCTPROC.PRG
* Author..: GRACE KELLER
* Date....: 02/10/88
* Notice..: Copyright (C) 1987, Solid Software, Inc., All Rights Reserved
* Notes...: JOURNAL/LEDGER ACTIVITY PROCEDURE FILE
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
*
PROCEDURE POSTSPRD
* Notes...: POST SPREADSHEET INFORMATION TO JOURNALS
*
MTITLE = ' - POST SPREADSHEET INFORMATION'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
STORE DATE() TO MPOST_DATE
DIMENSION MUPDRCD(15)  
DIMENSION MCK(15)
DIMENSION MCK_LINE(15)

MNEXT_ENT = .T.

SELECT E
DO FOX_USE WITH "SS INDEX SS_YRMO", .F.

SELECT C
DO FOX_USE WITH "PURCHJRN INDEX PURCHJRN", .F.

SELECT D
DO FOX_USE WITH "SALESJRN INDEX SALESJRN", .F.

SELECT A
DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
STORE TRAN_MO TO MTRAN_MO
STORE TRAN_YR TO MTRAN_YR
MCHOICE = SPACE(3)

IF MPROG_CODE = 2 
   @ 10,5 say 'The posting month/year is: ' + mtran_mo + '/'+ mtran_yr
   @ 12,5 say 'Do you want to post all entries for the above period (YES/NO)? ' get mchoice picture '@!' VALID(MCHOICE = 'YES' .OR. MCHOICE = 'NO ')
   READ 
   IF MCHOICE = 'YES'
      MENTRY = 'B'
      DO POSTALL
      CLOSE DATA
      RETURN
   ENDIF
ENDIF

STORE ' ' TO MENTRY
DO WHILE MENTRY <> 'I' .AND. MENTRY <> 'C'
   STORE 'I' TO MENTRY 
   @ 10,5 say 'Do You Want to Post Invoices (I) or Corrections (C) ? ' GET MENTRY PICTURE '@!'
   READ
ENDDO
IF MENTRY <> 'I'
   STORE 'C' TO MENTRY
ENDIF
MCHOICE = SPACE(3)
IF MPROG_CODE = 1                            
   @ 12,5 say 'The posting month/year is: ' + mtran_mo + '/'+ mtran_yr
   @ 14,5 say 'Do you want to post all invoices for the above period (YES/NO)? ' get mchoice picture '@!' VALID(MCHOICE = 'YES' .OR. MCHOICE = 'NO ')
   READ 
ENDIF
IF MCHOICE = 'YES'
   DO POSTALL
   CLOSE DATA
   RETURN
ENDIF

DO FOX_USE WITH "DAILYJRN INDEX POSTED, JRN_PO, JRN_MO", .F.
IF MENTRY = 'I'
   SEEK ' I'
ELSE
   SEEK ' C'
ENDIF
IF EOF()
   @ 4,1 CLEAR TO 21,78
   @ 10,5 SAY 'THERE ARE NO ENTRIES TO BE POSTED'
   STORE ' ' TO MWAIT
   @ 12,5 SAY 'PRESS ENTER TO CONTINUE ' GET MWAIT
   READ
   RETURN
ENDIF
@ 3,0 to 25,79
@ 3,0 CLEAR
@ 3,0 TO 5,79
@ 04,1  SAY '  Sal Inv  PO'
@ 4,18 say 'Cust'
@ 4,27 say 'Selling'
@ 4,36 say 'Supplr'
@ 4,44 say 'Purchase'
@ 4,54 say 'Freight'
@ 04,63 say '  Comm'
@ 04,72 say '    Net'
@ 23,0 to 25,79
MMORE = .T.
STORE RECNO() TO MRECNO
DO WHILE MMORE
   GOTO MRECNO
   MLINE = 7
   I = 1
   
   STORE 0 TO MCK_LINE, MUPDRCD   
   STORE SPACE(1) TO MCK
   
   DO WHILE .NOT. EOF() .AND. POST_FLG = ' ' .AND. MENTRY = INV_COR .AND. MMORE .AND. MLINE <= 22
      M = 1
      IF SAL_CODE2 <> '  '
         M = M + 1
      ENDIF
      IF SAL_CODE3 <> '  '
         M = M + 1
      ENDIF
      IF COM_CODE <> '  '
         M = M + 1
      ENDIF
      IF COM_CODE2 <> '  '
         M = M + 1
      ENDIF
      IF COM_CODE3 <> '  '
         M = M + 1
      ENDIF
      IF CUS_PALL <> 0 .OR. SUP_PALL <> 0 .OR. FRT_PALL <> 0
         M = M + 1
      ENDIF
      IF MLINE + M >= 22
         MLINE = 23
         LOOP
      ENDIF
      
      STORE RSUPCODE TO MRSUPCODE
      STORE BBUYCODE TO MBBUYCODE
      SELECT B
      IF MRSUPCODE <> 'NONE'
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
         SEEK MRSUPCODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,6) TO MRSUPNAME
         ELSE 
            STORE 'NOT FD' TO MRSUPNAME
         ENDIF
      ELSE
         STORE 'NONE' TO MRSUPNAME
      ENDIF
      IF MBBUYCODE <> 'NONE'
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         SEEK MBBUYCODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,6) TO MBBUYNAME
         ELSE 
            STORE 'NOT FD' TO MBBUYNAME
         ENDIF
      ELSE
         STORE 'NONE' TO MBBUYNAME 
      ENDIF
      
      SELECT A   
      @ MLINE,2 SAY SALESMAN
      @ MLINE,5 SAY INV_NBR   
      @ MLINE,12 SAY PO_NBR
      IF PO_SUFFIX <> ' '
         @ MLINE,16 SAY PO_SUFFIX
      ENDIF
      @ MLINE,18 SAY MBBUYNAME
      @ MLINE,25 SAY TOT_SELL PICTURE '999999.99'
      @ MLINE,36 SAY MRSUPNAME
      @ MLINE,43 SAY TOT_PURCH PICTURE '999999.99'
      *** IF MFI, SHOW BOTH FREIGHT AMOUNTS TOGETHER
      *IF MPROG_CODE = 2
      @ MLINE,53 SAY FRT_AMT1 + FRT_AMT2 + FRT_AMT3 PICTURE '99999.99'
      *ELSE
      *   @ MLINE,53 SAY FRT_AMT1 PICTURE '99999.99'
      *ENDIF
      @ MLINE,62 SAY SALE_COMM PICTURE '99999.99'
      @ MLINE,71 SAY TOT_NET PICTURE '999999.99'
      
      STORE MLINE TO MCK_LINE(I)
      STORE RECNO() TO MUPDRCD(I)
      
      I = I + 1
      MLINE = MLINE + 1
      IF CUS_PALL <> 0 .OR. SUP_PALL <> 0 .OR. FRT_PALL <> 0
         @ MLINE,18 SAY 'PALLETS'
         @ MLINE,25 SAY CUS_PALL PICTURE '@Z 999999.99'
         @ MLINE,43 SAY SUP_PALL PICTURE '@Z 999999.99'
         @ MLINE,53 SAY FRT_PALL PICTURE '@Z 99999.99'
         MLINE = MLINE + 1
      ENDIF
      
      **RON MONTGOMERY CHANGES
      IF SAL_CODE2 <> '  '
         **@ MLINE,2 SAY SAL_CODE2
         STORE SAL_CODE2 TO MCOM_CODE
         SELECT B
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         SEEK MCOM_CODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,6) TO MCOM_NAME
         ELSE  
            STORE SPACE(6) TO MCOM_NAME
         ENDIF
         
         @ MLINE,18 SAY MCOM_NAME
         SELECT A
         @ MLINE,62 SAY SALE2_AMT PICTURE '99999.99'
         **@ MLINE,71 SAY SALE2_NET PICTURE '999999.99'
         MLINE = MLINE + 1
      ENDIF
      
      IF SAL_CODE3 <> '  '
         @ MLINE,2 SAY SAL_CODE3
         @ MLINE,62 SAY SALE3_AMT PICTURE '99999.99'
         @ MLINE,71 SAY SALE3_NET PICTURE '999999.99'
         MLINE = MLINE + 1
      ENDIF
      IF COM_CODE <> '  '
         STORE COM_CODE TO MCOM_CODE
         SELECT B
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         SEEK MCOM_CODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,6) TO MCOM_NAME
         ELSE  
            STORE SPACE(6) TO MCOM_NAME
         ENDIF
         
         @ MLINE,18 SAY MCOM_NAME
         SELECT A
         @ MLINE,62 SAY COMM_AMT PICTURE '99999.99'
         MLINE = MLINE + 1
      ENDIF
      
      IF COM_CODE2 <> '  '
         STORE COM_CODE2 TO MCOM_CODE
         SELECT B
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         SEEK MCOM_CODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,6) TO MCOM_NAME
         ELSE  
            STORE SPACE(6) TO MCOM_NAME
         ENDIF
         
         @ MLINE,18 SAY MCOM_NAME
         SELECT A
         @ MLINE,62 SAY COMM_AMT2 PICTURE '99999.99'
         MLINE = MLINE + 1
      ENDIF
      
      IF COM_CODE3 <> '  '
         STORE COM_CODE3 TO MCOM_CODE
         SELECT B
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         SEEK MCOM_CODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,6) TO MCOM_NAME
         ELSE  
            STORE SPACE(6) TO MCOM_NAME
         ENDIF
         
         @ MLINE,18 SAY MCOM_NAME
         SELECT A
         @ MLINE,62 SAY COMM_AMT3 PICTURE '99999.99'
         MLINE = MLINE + 1
      ENDIF
      
      SELECT A
      SKIP
      STORE RECNO() TO MRECNO
   ENDDO
   STORE I-1 TO MMAX_I
   
   STORE 2 TO MACTION
   DO WHILE MACTION = 2
      I = 1
      DO WHILE I<= MMAX_I
         @ MCK_LINE(I),0 GET MCK(I) PICTURE '@!'
         I = I + 1
      ENDDO
      
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Save/Next Page     2. Edit      3. Save/Finished'
      READ
      @ 24,9 GET MACTION PICTURE '9' range 1,3
      READ
   ENDDO
   
   SELECT A
   DO FILELOCK
   I = 1
   DO WHILE I <= MMAX_I
      IF MCK(I) = 'X' .OR. MCK(I) = 'P' 
         GOTO MUPDRCD(I)
         
         ***** DO POSTING HERE
         ***** SUPPLIER JOURNAL
         IF A->RSUPCODE = 'INVN'
            IF MPROG_CODE = 2
               *** PUT THIS INTO THE INVENTORY ACCOUNT
               SELECT E
               DO FOX_USE WITH "INVLED INDEX INVLED", .F.
               DO FILELOCK
               APPEND BLANK
               REPLACE RSUPCODE WITH A->RSUPCODE
               REPLACE BBUYCODE WITH A->BBUYCODE
               REPLACE SALESMAN WITH A->SALESMAN
               REPLACE INV_NBR WITH A->INV_NBR
               REPLACE PO_NBR WITH A->PO_NBR
               REPLACE PO_SUFFIX WITH A->PO_SUFFIX
               REPLACE AMOUNT WITH -1 * (A->TOT_PURCH + A->SUP_PALL)
               REPLACE TRAN_DATE WITH A->JRNL_DATE
               REPLACE POST_DATE WITH DATE()
               REPLACE TRAN_MO WITH A->TRAN_MO
               REPLACE TRAN_YR WITH A->TRAN_YR
               IF MENTRY <> 'I'  
                  REPLACE COR_FLG WITH 'C'
               ELSE
                  REPLACE COR_FLG WITH 'I'
               ENDIF
               REPLACE SEQ WITH A->SEQ
               UNLOCK
               USE
            ENDIF
         ELSE
            IF A->RSUPCODE <> 'ID'
               IF A->RSUPCODE <> 'NONE' .AND. A->TOT_PURCH <> 0
                  SELECT C
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE RSUPCODE WITH A->RSUPCODE
                  REPLACE SALESMAN WITH A->SALESMAN
                  REPLACE INV_NBR WITH A->INV_NBR
                  REPLACE PO_NBR WITH A->PO_NBR
                  REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                  REPLACE AMOUNT WITH A->TOT_PURCH
                  REPLACE TRAN_DATE WITH A->JRNL_DATE
                  REPLACE POST_DATE WITH DATE()
                  REPLACE TRAN_MO WITH A->TRAN_MO
                  REPLACE TRAN_YR WITH A->TRAN_YR
                  IF MENTRY <> 'I'  
                     REPLACE COR_FLG WITH 'C'
                  ELSE
                     REPLACE COR_FLG WITH 'I'
                  ENDIF
                  REPLACE SEQ WITH A->SEQ
                  UNLOCK
               ENDIF
               
               IF A->RSUPCODE <> 'NONE' .AND. A->SUP_PALL <> 0
                  SELECT C
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE RSUPCODE WITH A->RSUPCODE
                  REPLACE SALESMAN WITH A->SALESMAN
                  REPLACE INV_NBR WITH A->INV_NBR
                  REPLACE PO_NBR WITH A->PO_NBR
                  REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                  REPLACE AMOUNT WITH A->SUP_PALL  
                  REPLACE TRAN_DATE WITH A->JRNL_DATE
                  REPLACE POST_DATE WITH DATE()
                  REPLACE TRAN_MO WITH A->TRAN_MO
                  REPLACE TRAN_YR WITH A->TRAN_YR
                  REPLACE PALL_FLG WITH 'Y'
                  IF MENTRY  <> 'I'  
                     REPLACE COR_FLG WITH 'C'
                  ELSE
                     REPLACE COR_FLG WITH 'I'
                  ENDIF
                  REPLACE SEQ WITH A->SEQ
                  UNLOCK
               ENDIF
            ENDIF
         ENDIF
         ***** SALES JOURNAL
         IF A->BBUYCODE = 'INVN'
            IF MPROG_CODE = 2
               *** PUT THIS INTO THE INVENTORY ACCOUNT
               SELECT E
               DO FOX_USE WITH "INVLED INDEX INVLED", .F.
               DO FILELOCK
               APPEND BLANK
               REPLACE BBUYCODE WITH A->BBUYCODE
               REPLACE RSUPCODE WITH A->RSUPCODE
               REPLACE SALESMAN WITH A->SALESMAN
               REPLACE INV_NBR WITH A->INV_NBR
               REPLACE PO_NBR WITH A->PO_NBR
               REPLACE PO_SUFFIX WITH A->PO_SUFFIX
               REPLACE AMOUNT WITH A->TOT_SELL + A->CUS_PALL
               REPLACE TRAN_DATE WITH A->JRNL_DATE
               REPLACE POST_DATE WITH DATE()
               REPLACE TRAN_MO WITH A->TRAN_MO
               REPLACE TRAN_YR WITH A->TRAN_YR
               IF MENTRY  <> 'I'  
                  REPLACE COR_FLG WITH 'C'
               ELSE
                  REPLACE COR_FLG WITH 'I'
               ENDIF
               REPLACE SEQ WITH A->SEQ
               UNLOCK
               USE
            ENDIF
         ELSE
            IF A->BBUYCODE <> 'ID'
               IF A->BBUYCODE <> 'NONE' .AND. A->TOT_SELL <> 0
                  SELECT D
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE BBUYCODE WITH A->BBUYCODE
                  REPLACE SALESMAN WITH A->SALESMAN
                  REPLACE INV_NBR WITH A->INV_NBR
                  REPLACE PO_NBR WITH A->PO_NBR
                  REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                  REPLACE AMOUNT WITH A->TOT_SELL                 
                  REPLACE TRAN_DATE WITH A->JRNL_DATE
                  REPLACE POST_DATE WITH DATE()
                  REPLACE TRAN_MO WITH A->TRAN_MO
                  REPLACE TRAN_YR WITH A->TRAN_YR
                  IF MENTRY  <> 'I'  
                     REPLACE COR_FLG WITH 'C'
                  ELSE
                     REPLACE COR_FLG WITH 'I'
                  ENDIF
                  REPLACE SEQ WITH A->SEQ
                  UNLOCK
               ENDIF
               
               IF A->BBUYCODE <> 'NONE' .AND. A->CUS_PALL <> 0
                  SELECT D
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE BBUYCODE WITH A->BBUYCODE
                  REPLACE SALESMAN WITH A->SALESMAN
                  REPLACE INV_NBR WITH A->INV_NBR
                  REPLACE PO_NBR WITH A->PO_NBR
                  REPLACE PO_SUFFIX WITH A->PO_SUFFIX
                  REPLACE AMOUNT WITH A->CUS_PALL
                  REPLACE TRAN_DATE WITH A->JRNL_DATE
                  REPLACE POST_DATE WITH DATE()
                  REPLACE TRAN_MO WITH A->TRAN_MO
                  REPLACE TRAN_YR WITH A->TRAN_YR
                  IF MENTRY  <> 'I'  
                     REPLACE COR_FLG WITH 'C'
                  ELSE
                     REPLACE COR_FLG WITH 'I'
                  ENDIF
                  REPLACE PALL_FLG WITH 'Y'
                  REPLACE SEQ WITH A->SEQ
                  UNLOCK
               ENDIF
            ENDIF
         ENDIF
         
         ***** FREIGHT JOURNAL
         SELECT E
         DO FOX_USE WITH "FRTJRN INDEX FRTJRN", .F.
         IF A->FRT_CODE1 <> 'NONE' .AND. A->FRT_AMT1 <> 0
            DO FILELOCK
            APPEND BLANK
            REPLACE FRT_CODE WITH A->FRT_CODE1
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->FRT_AMT1
            REPLACE TRAN_DATE WITH A->JRNL_DATE
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->TRAN_MO
            REPLACE TRAN_YR WITH A->TRAN_YR
            IF MENTRY  <> 'I'  
               REPLACE COR_FLG WITH 'C'
            ELSE
               REPLACE COR_FLG WITH 'I'
            ENDIF
            REPLACE SEQ WITH A->SEQ
            UNLOCK
         ENDIF
         
         IF A->FRT_CODE1 <> 'NONE' .AND. A->FRT_PALL <> 0
            DO FILELOCK
            APPEND BLANK
            REPLACE FRT_CODE WITH A->FRT_CODE1
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->FRT_PALL
            REPLACE TRAN_DATE WITH A->JRNL_DATE
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->TRAN_MO
            REPLACE TRAN_YR WITH A->TRAN_YR
            REPLACE PALL_FLG WITH 'Y'
            IF MENTRY  <> 'I'  
               REPLACE COR_FLG WITH 'C'
            ELSE
               REPLACE COR_FLG WITH 'I'
            ENDIF
            REPLACE SEQ WITH A->SEQ
            UNLOCK
         ENDIF
         
         *** ADDED 11/2003 2ND FREIGHT CARRIER FOR EVERYONE
         ***IF MPROG_CODE = 2
         *** CHECK FOR 2ND FREIGHT CARRIER ON MFI
         IF A->FRT_CODE2 <> 'NONE' .AND. A->FRT_CODE2 <> SPACE(4) .AND. A->FRT_AMT2 <> 0
            DO FILELOCK
            APPEND BLANK
            REPLACE FRT_CODE WITH A->FRT_CODE2
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->FRT_AMT2
            REPLACE TRAN_DATE WITH A->JRNL_DATE
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->TRAN_MO
            REPLACE TRAN_YR WITH A->TRAN_YR
            IF MENTRY  <> 'I'  
               REPLACE COR_FLG WITH 'C'
            ELSE
               REPLACE COR_FLG WITH 'I'
            ENDIF
            REPLACE SEQ WITH A->SEQ
            UNLOCK
         ENDIF
         
         IF A->FRT_CODE3 <> 'NONE' .AND. A->FRT_CODE3 <> SPACE(4) .AND. A->FRT_AMT3 <> 0
            DO FILELOCK
            APPEND BLANK
            REPLACE FRT_CODE WITH A->FRT_CODE3
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->FRT_AMT3
            REPLACE TRAN_DATE WITH A->JRNL_DATE
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->TRAN_MO
            REPLACE TRAN_YR WITH A->TRAN_YR
            IF MENTRY  <> 'I'  
               REPLACE COR_FLG WITH 'C'
            ELSE
               REPLACE COR_FLG WITH 'I'
            ENDIF
            REPLACE SEQ WITH A->SEQ
            UNLOCK
         ENDIF
         
         IF A->SALESMAN = '25'
            SELECT E
            DO FOX_USE WITH "ERNLED INDEX ERNLED, ERNPD", .F.
            DO FILELOCK
            APPEND BLANK
            REPLACE COM_CODE WITH A->SALESMAN
            REPLACE COM_TYPE WITH 'S'
            REPLACE SALESMAN WITH A->SALESMAN 
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE RSUPCODE WITH A->RSUPCODE
            REPLACE BBUYCODE WITH A->BBUYCODE
            REPLACE AMOUNT WITH A->TOT_NET
            REPLACE TRAN_DATE WITH A->JRNL_DATE
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->TRAN_MO
            REPLACE TRAN_YR WITH A->TRAN_YR
            REPLACE COR_FLG WITH A->INV_COR
            REPLACE TOT_LBS WITH A->TOT_LBS
            UNLOCK
         ENDIF
         ***ENDIF
         
         ***** UPDATE COMMISSIONS/THIRD PARTY COMMISSIONS JOURNAL
         SELECT E
         DO FOX_USE WITH "COMJRN INDEX COMJRN", .F.
         IF A->SALESMAN <> '  ' .AND. A->SALE_COMM <> 0
            DO FILELOCK
            APPEND BLANK
            REPLACE COM_CODE WITH A->SALESMAN
            REPLACE COM_TYPE WITH 'S'
            REPLACE SALESMAN WITH A->SALESMAN 
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->SALE_COMM
            REPLACE TRAN_DATE WITH A->JRNL_DATE
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->TRAN_MO
            REPLACE TRAN_YR WITH A->TRAN_YR
            IF MENTRY  <> 'I'  
               REPLACE COR_FLG WITH 'C'
            ELSE
               REPLACE COR_FLG WITH 'I'
            ENDIF
            REPLACE SEQ WITH A->SEQ
            IF MCOMPANY = 'DIVISION 15'
               REPLACE TOT_LBS WITH A->TOT_LBS
            ENDIF
            UNLOCK
         ENDIF
         
         **RON MONTGOMERY CHANGES
         IF A->SAL_CODE2 <> '  ' .AND. A->SALE2_AMT <> 0
            DO FILELOCK
            APPEND BLANK
            REPLACE COM_CODE WITH A->SAL_CODE2
            REPLACE COM_TYPE WITH 'T'
            REPLACE SALESMAN WITH A->SALESMAN 
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->SALE2_AMT
            REPLACE TRAN_DATE WITH A->JRNL_DATE
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->TRAN_MO
            REPLACE TRAN_YR WITH A->TRAN_YR
            IF MENTRY  <> 'I'  
               REPLACE COR_FLG WITH 'C'
            ELSE
               REPLACE COR_FLG WITH 'I'
            ENDIF
            REPLACE SEQ WITH A->SEQ
            IF MCOMPANY = 'DIVISION 15'
               REPLACE TOT_LBS WITH A->TOT_LBS
            ENDIF
            UNLOCK
         ENDIF
         
         IF A->SAL_CODE3 <> '  ' .AND. A->SALE3_AMT <> 0
            DO FILELOCK
            APPEND BLANK
            REPLACE COM_CODE WITH A->SAL_CODE3
            REPLACE COM_TYPE WITH 'S'
            REPLACE SALESMAN WITH A->SALESMAN 
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->SALE3_AMT
            REPLACE TRAN_DATE WITH A->JRNL_DATE
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->TRAN_MO
            REPLACE TRAN_YR WITH A->TRAN_YR
            IF MENTRY  <> 'I'  
               REPLACE COR_FLG WITH 'C'
            ELSE
               REPLACE COR_FLG WITH 'I'
            ENDIF
            REPLACE SEQ WITH A->SEQ
            IF MCOMPANY = 'DIVISION 15' 
               REPLACE TOT_LBS WITH A->TOT_LBS
            ENDIF
            UNLOCK
         ENDIF
         
         IF A->COM_CODE <> '  ' .AND. A->COMM_AMT <> 0
            SELECT F
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
            SEEK A->COM_CODE
            IF BILL_BACK = 'Y'
               SELECT E
               DO FOX_USE WITH "BBKJRN INDEX BBKJRN", .F.
            ELSE
               SELECT E
               DO FOX_USE WITH "COMJRN INDEX COMJRN", .F.
            ENDIF
            SELECT F
            USE
            SELECT E
            DO FILELOCK
            APPEND BLANK
            REPLACE COM_CODE WITH A->COM_CODE 
            REPLACE COM_TYPE WITH 'T'
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->COMM_AMT 
            REPLACE TRAN_DATE WITH A->JRNL_DATE
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->TRAN_MO
            REPLACE TRAN_YR WITH A->TRAN_YR
            IF MENTRY  <> 'I'  
               REPLACE COR_FLG WITH 'C'
            ELSE
               REPLACE COR_FLG WITH 'I'
            ENDIF
            REPLACE SEQ WITH A->SEQ
            IF MCOMPANY = 'DIVISION 15'
               REPLACE TOT_LBS WITH A->TOT_LBS
            ENDIF
            UNLOCK
         ENDIF
         IF A->COM_CODE2 <> '  ' .AND. A->COMM_AMT2 <> 0
            SELECT F
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
            SEEK A->COM_CODE2
            IF BILL_BACK = 'Y'
               SELECT E
               DO FOX_USE WITH "BBKJRN INDEX BBKJRN", .F.
            ELSE
               SELECT E
               DO FOX_USE WITH "COMJRN INDEX COMJRN", .F.
            ENDIF
            SELECT F
            USE
            SELECT E
            DO FILELOCK
            APPEND BLANK
            REPLACE COM_CODE WITH A->COM_CODE2 
            REPLACE COM_TYPE WITH 'T'
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->COMM_AMT2 
            REPLACE TRAN_DATE WITH A->JRNL_DATE
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->TRAN_MO
            REPLACE TRAN_YR WITH A->TRAN_YR
            IF MENTRY  <> 'I'  
               REPLACE COR_FLG WITH 'C'
            ELSE
               REPLACE COR_FLG WITH 'I'
            ENDIF
            REPLACE SEQ WITH A->SEQ
            IF MCOMPANY = 'DIVISION 15'
               REPLACE TOT_LBS WITH A->TOT_LBS
            ENDIF
            UNLOCK
         ENDIF
         
         IF A->COM_CODE3 <> '  ' .AND. A->COMM_AMT3 <> 0
            SELECT F
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
            SEEK A->COM_CODE3
            IF BILL_BACK = 'Y'
               SELECT E
               DO FOX_USE WITH "BBKJRN INDEX BBKJRN", .F.
            ELSE
               SELECT E
               DO FOX_USE WITH "COMJRN INDEX COMJRN", .F.
            ENDIF
            SELECT F
            USE
            SELECT E
            DO FILELOCK
            APPEND BLANK
            REPLACE COM_CODE WITH A->COM_CODE3 
            REPLACE COM_TYPE WITH 'T'
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->COMM_AMT3 
            REPLACE TRAN_DATE WITH A->JRNL_DATE
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->TRAN_MO
            REPLACE TRAN_YR WITH A->TRAN_YR
            IF MENTRY  <> 'I'  
               REPLACE COR_FLG WITH 'C'
            ELSE
               REPLACE COR_FLG WITH 'I'
            ENDIF
            REPLACE SEQ WITH A->SEQ
            IF MCOMPANY = 'DIVISION 15'
               REPLACE TOT_LBS WITH A->TOT_LBS
            ENDIF
            UNLOCK
         ENDIF
         
         IF MENTRY = 'I'
            SELECT E
            DO FOX_USE WITH "SS INDEX SS_YRMO", .F.
            SEEK A->TRAN_YR + A->TRAN_MO + A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
            IF .NOT. EOF()
               DO RECLOCK
               REPLACE POST_FLG WITH 'P'
               UNLOCK
            ENDIF
         ENDIF
         
         ***** CREDIT JOURNAL FOR MFI/DAYLEE
         *** A->RSUPCODE = 'ID72' - IT MEANS IT IS FINISHED PRODUCT
         *** A->BBUYCODE <> ' 123' - IT MEANS IT WAS SOLD TO A CUSTOMER - NOT
         ***                         SOLD TO MFI
         IF A->SALESMAN = '72' .AND. A->RSUPCODE = 'ID72' .AND. A->BBUYCODE <> ' 123'
            SELECT F
            DO FOX_USE WITH "NETJRN INDEX NETJRN", .F.
            DO FILELOCK
            APPEND BLANK
            REPLACE BBUYCODE WITH A->BBUYCODE 
            REPLACE BUY_CODE WITH A->BUY_CODE
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->TOT_NET 
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->TRAN_MO
            REPLACE TRAN_YR WITH A->TRAN_YR
            REPLACE SHIP_DATE WITH A->SHIP_DATE
            IF MENTRY  <> 'I'  
               REPLACE COR_FLG WITH 'C'
            ELSE
               REPLACE COR_FLG WITH 'I'
            ENDIF
            REPLACE SEQ WITH A->SEQ
            REPLACE TOT_LBS WITH A->TOT_LBS
            UNLOCK
         ENDIF
         SELECT A
         REPLACE POST_FLG WITH 'P'
         IF A->SALESMAN = '72'
            REPLACE POST_DATE WITH DATE()
         ENDIF
      ENDIF
      I = I + 1
   ENDDO
   FLUSH
   UNLOCK
   IF MACTION = 3
      MMORE = .F.  
      LOOP
   ELSE
      IF EOF()
         MMORE = .F.
      ELSE
         @ 6,0 CLEAR TO 22,79
      ENDIF
   ENDIF
ENDDO
RETURN
* EOF: POSTSPRD.PRG

**************************************
PROCEDURE JRNL_PRT 
MTITLE = ' - JOURNAL LISTINGS'
CLEAR
@ 01,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@  2,0 SAY MPROGRAM + MTITLE
@ 3,0 TO 24,79
STORE ' ' TO MFRT_SEL, MSUP_SEL, MCUS_SEL, MCOM_SEL, MDIS_SEL, MREC_SEL, MBBK_SEL
STORE 0 TO MTRAN_MO, MTRAN_YR, MBUS_MO, MBUS_YR
STORE CTOD(' ') TO MPOSTED
MYES_NO = 'N'
STORE 2 TO MACTION
DO WHILE MACTION = 2
   @ 04,5 SAY "Select with an 'X' desired report(s)"
   @ 06,5 SAY '      FREIGHT JOURNAL: ' GET MFRT_SEL PICTURE '@!' VALID(MFRT_SEL = ' ' .OR. MFRT_SEL = 'X')
   @ 08,5 SAY '     PURCHASE JOURNAL: ' GET MSUP_SEL PICTURE '@!' VALID(MSUP_SEL = ' ' .OR. MSUP_SEL = 'X')
   @ 10,5 SAY '        SALES JOURNAL: ' GET MCUS_SEL PICTURE '@!' VALID(MCUS_SEL = ' ' .OR. MCUS_SEL = 'X')
   @ 12,5 SAY '  COMMISSIONS JOURNAL: ' GET MCOM_SEL PICTURE '@!' VALID(MCOM_SEL = ' ' .OR. MCOM_SEL = 'X')
   @ 14,5 SAY '     BILLBACK JOURNAL: ' GET MBBK_SEL PICTURE '@!' VALID(MBBK_SEL = ' ' .OR. MBBK_SEL = 'X')
   @ 16,5 SAY '       BUSINESS MONTH: ' GET MBUS_MO PICTURE '##' RANGE 1,12
   @ 17,5 SAY '        BUSINESS YEAR: ' GET MBUS_YR PICTURE '####' RANGE 1988,2099
   @ 18,5 SAY '(OPTIONAL)  POST DATE: ' GET MPOSTED
   @ 20,3 SAY 'PRINT TOTALS ONLY (Y/N): ' GET MYES_NO PICTURE '@!' VALID(MYES_NO = 'Y' .OR. MYES_NO = 'N')
   
   STORE 1 TO MACTION
   @ 24,0 SAY 'Action: ' + STR(MACTION,1)
   @ 24,12 SAY '1. Continue      2. Edit     3. Cancel'
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
   
   READ
ENDDO

STORE SUBSTR(STR(MBUS_MO + 100,3),2) TO MBUS_MO  
STORE STR(MBUS_YR,4) TO MBUS_YR
DO CASE
CASE MBUS_MO = '01'
   STORE 'JANUARY' TO MMONTH
CASE MBUS_MO = '02'
   STORE 'FEBRUARY' TO MMONTH
CASE MBUS_MO = '03'
   STORE 'MARCH' TO MMONTH
CASE MBUS_MO = '04'
   STORE 'APRIL' TO MMONTH
CASE MBUS_MO = '05'
   STORE 'MAY' TO MMONTH
CASE MBUS_MO = '06'
   STORE 'JUNE' TO MMONTH
CASE MBUS_MO = '07'
   STORE 'JULY' TO MMONTH
CASE MBUS_MO = '08'
   STORE 'AUGUST' TO MMONTH
CASE MBUS_MO = '09'
   STORE 'SEPTEMBER' TO MMONTH
CASE MBUS_MO = '10'
   STORE 'OCTOBER' TO MMONTH
CASE MBUS_MO = '11'
   STORE 'NOVEMBER' TO MMONTH
CASE MBUS_MO = '12'
   STORE 'DECEMBER' TO MMONTH
OTHERWISE
   STORE ' ' TO MMONTH
ENDCASE
IF DTOC(MPOSTED) <> '  /  /  '
   STORE SUBSTR(DTOC(MPOSTED),7) + SUBSTR(DTOC(MPOSTED),1,2) + SUBSTR(DTOC(MPOSTED),4,2) TO MOPT_DATE
ELSE
   STORE SPACE(8) TO MOPT_DATE
ENDIF
STORE ' ' TO MACTION
DO PRT_SET
IF MACTION <> 'C'
   RETURN
ENDIF 
MTRAN_MO = MBUS_MO
MTRAN_YR = MBUS_YR

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

*** LETTER SIZE PAPER
?? CHR(27) + '&l2A'

*** PORTRAIT MODE
?? CHR(27) + '&l0O'

IF MFRT_SEL = 'X'
   IF MYES_NO <> 'Y' 
      SELECT A 
      DO FOX_USE WITH "FRTJRN", .F.
      INDEX ON POST_FLG + TRAN_YR + TRAN_MO + INV_NBR + COR_FLG + PALL_FLG TO FRTDUP
      DO FOX_USE WITH "FRTJRN INDEX FRTDUP", .F.
      SEEK ' '
      DO WHILE .NOT. EOF() .AND. POST_FLG = ' '
         IF COR_FLG = ' '
            SKIP
            LOOP
         ENDIF
         STORE INV_NBR TO MINV_NBR
         STORE AMOUNT TO MAMOUNT
         STORE FRT_CODE TO MFRT_CODE
         STORE SEQ TO MSEQ1
         STORE POST_DATE TO MPOST_DATE
         STORE TRAN_YR TO MTRAN_YR
         STORE TRAN_MO TO MTRAN_MO
         SKIP
         STORE SEQ TO MSEQ2
         IF .NOT. EOF() .AND. POST_FLG = ' ' .AND. TRAN_YR = MTRAN_YR .AND. ;
            TRAN_MO = MTRAN_MO .AND. INV_NBR = MINV_NBR .AND. (AMOUNT = -1 * MAMOUNT) ;
            .AND. FRT_CODE = MFRT_CODE .AND. MSEQ1 = '1' .AND. MSEQ2 = '2' ;
            .AND. POST_DATE = MPOST_DATE
            SKIP -1
            DELETE
            SKIP
            DELETE
            SKIP
         ENDIF
      ENDDO
      USE
      * END OF DELETING DUPLICATE ENTRIES (BACK OFF, PUT BACK ON SAME AMOUNT)
   ENDIF
   MTRAN_MO = MBUS_MO
   MTRAN_YR = MBUS_YR
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
   SELECT A
   DO FOX_USE WITH "FRTJRN INDEX FRTJRN", .F.
   MACTIVITY = 0  
   IF MOPT_DATE = SPACE(8)
      SEEK MTRAN_YR + MTRAN_MO
   ELSE
      SEEK MTRAN_YR + MTRAN_MO + MOPT_DATE
   ENDIF
   MPRINTED = .F.
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      IF DTOC(MPOSTED) <> '  /  /  '
         IF MPOSTED <> POST_DATE
            SKIP
            LOOP
         ENDIF
      ENDIF
      MPRINTED = .T.
      IF MYES_NO <> 'Y'
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            IF DTOC(MPOSTED) <> '  /  /  '
               STORE MMONTH + ' - ' + DTOC(MPOSTED) TO MPRINT
            ELSE
               STORE MMONTH TO MPRINT
            ENDIF
            @ 3,25 SAY 'FREIGHT JOURNAL LISTING FOR ' + MPRINT 
            @ 3,79  SAY DTOC(DATE())
            @ 5,1 SAY '  DATE  '
            @ 5,12 SAY 'ACCOUNT'
            @ 5,52 SAY 'INVOICE NBR'
            @ 5,67 SAY 'PO NUMBER'
            @ 5,82 SAY '   AMOUNT' 
            @ 5,01 SAY REPLICATE('_',90)
            MLINE = 7
            MDO_NM = .T.
         ENDIF
         STORE FRT_CODE TO MFRT_CODE
         SELECT B
         SEEK MFRT_CODE
         IF EOF()
            STORE 'FRT NOT ON FILE' TO MNAME
         ELSE
            STORE NAME TO MNAME
         ENDIF
         SELECT A
         @ MLINE,1 SAY TRAN_DATE
         @ MLINE,12 SAY MNAME
         IF INV_NBR <> SPACE(5) 
            @ MLINE,55 SAY INV_NBR
         ENDIF
         IF SALESMAN <> '  '
            IF PO_SUFFIX <> ' '
               @ MLINE,67 SAY SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
            ELSE
               @ MLINE,67 SAY SALESMAN + '-' + PO_NBR 
            ENDIF
         ELSE
            IF PO_SUFFIX <> ' '
               @ MLINE,67 SAY PO_NBR + '-' + PO_SUFFIX
            ELSE
               @ MLINE,67 SAY PO_NBR 
            ENDIF
         ENDIF
         @ MLINE,81 SAY AMOUNT PICTURE '999,999.99'
         MLINE = MLINE + 1
      ENDIF
      MACTIVITY = MACTIVITY + AMOUNT
      SKIP
   ENDDO
   IF MACTIVITY <> 0 .OR. MPRINTED
      IF MYES_NO = 'Y'
         *** TOTALS ONLY - NEED TO FORMAT HEADERS HERE
         IF MLINE <> 99
            EJECT         
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 2,30 SAY MCOMPANY
         @ 3,1 SAY 'Page'
         @ 3,06 say mpage_no picture '99'
         IF DTOC(MPOSTED) <> '  /  /  '
            STORE MMONTH + ' - ' + DTOC(MPOSTED) TO MPRINT
         ELSE
            STORE MMONTH TO MPRINT
         ENDIF
         @ 3,25 SAY 'FREIGHT JOURNAL TOTALS FOR ' + MPRINT 
         @ 3,79  SAY DTOC(DATE())
         *** @ 3,01 SAY REPLICATE('_',90)
         MLINE = 5
      ENDIF
      MLINE = MLINE + 1
      @ MLINE,5 SAY 'TOTAL ALL ACTIVITY: ' 
      @ MLINE,78 SAY MACTIVITY PICTURE '99,999,999.99'
      @ MLINE+1,1 SAY ' ' 
      EJECT
   ENDIF
ENDIF

MTRAN_MO = MBUS_MO
MTRAN_YR = MBUS_YR
IF MSUP_SEL = 'X'
   IF MYES_NO <> 'Y'
      *** DO SUP_DUP (USED TO BE)
      SELECT A 
      DO FOX_USE WITH "PURCHJRN", .F.
      INDEX ON POST_FLG + TRAN_YR + TRAN_MO + INV_NBR + COR_FLG + PALL_FLG TO PURCHDUP
      DO FOX_USE WITH "PURCHJRN INDEX PURCHDUP", .F.
      SEEK ' '
      DO WHILE .NOT. EOF() .AND. POST_FLG = ' '
         IF COR_FLG = ' '
            SKIP
            LOOP
         ENDIF
         STORE INV_NBR TO MINV_NBR
         STORE AMOUNT TO MAMOUNT
         STORE RSUPCODE TO MRSUPCODE
         STORE SEQ TO MSEQ1
         STORE POST_DATE TO MPOST_DATE
         STORE TRAN_YR TO MTRAN_YR
         STORE TRAN_MO TO MTRAN_MO
         SKIP
         STORE SEQ TO MSEQ2
         IF .NOT. EOF() .AND. POST_FLG = ' ' .AND. TRAN_YR = MTRAN_YR .AND. ;
            TRAN_MO = MTRAN_MO .AND. INV_NBR = MINV_NBR .AND. ;
            (AMOUNT = -1 * MAMOUNT) .AND. RSUPCODE = MRSUPCODE .AND. ;
            MSEQ1 = '1' .AND. MSEQ2 = '2'  .AND. POST_DATE = MPOST_DATE
            SKIP -1
            DELETE
            SKIP
            DELETE
            SKIP
         ENDIF
      ENDDO
      USE
      ***** END OF DELETING DUPLICATE ENTRIES
   ENDIF
   MTRAN_MO = MBUS_MO
   MTRAN_YR = MBUS_YR
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
   SELECT A
   DO FOX_USE WITH "PURCHJRN INDEX PURCHJRN", .F.
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   IF MOPT_DATE = SPACE(8)
      SEEK MTRAN_YR + MTRAN_MO
   ELSE
      SEEK MTRAN_YR + MTRAN_MO + MOPT_DATE
   ENDIF
   MACTIVITY = 0  
   MDIV_ACT  = 0
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      IF MPOSTED <> CTOD('')
         IF MPOSTED <> POST_DATE
            SKIP
            LOOP
         ENDIF
      ENDIF
      IF RSUPCODE = 'I'
         IF RSUPCODE = 'ID'
            MDIV_ACT = MDIV_ACT + AMOUNT
         ENDIF
         SKIP
         LOOP
      ENDIF
      IF MYES_NO <> 'Y'
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            IF DTOC(MPOSTED) <> '  /  /  '
               STORE MMONTH + ' - ' + DTOC(MPOSTED) TO MPRINT
            ELSE
               STORE MMONTH TO MPRINT
            ENDIF
            @ 3,20 SAY 'PURCHASE JOURNAL LISTING FOR ' + MPRINT 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY '  DATE'
            @ 5,12 SAY 'ACCOUNT'
            @ 5,52 SAY 'INVOICE NBR'
            @ 5,67 SAY 'PO NUMBER'
            @ 5,82 SAY '   AMOUNT' 
            @ 5,1  SAY REPLICATE('_',90)
            MLINE = 7
            MDO_NM = .T.
         ENDIF
         STORE RSUPCODE TO MRSUPCODE
         SELECT B
         SEEK MRSUPCODE
         IF EOF()
            STORE 'SUP NOT ON FILE' TO MNAME
         ELSE
            STORE NAME TO MNAME
         ENDIF
         SELECT A
         @ MLINE,1 SAY TRAN_DATE
         @ MLINE,12 SAY MNAME
         IF INV_NBR <> SPACE(5) 
            @ MLINE,55 SAY INV_NBR
         ENDIF
         IF SALESMAN <> '  '
            IF PO_SUFFIX <> ' '
               @ MLINE,67 SAY SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
            ELSE
               @ MLINE,67 SAY SALESMAN + '-' + PO_NBR 
            ENDIF
         ELSE
            IF PO_SUFFIX <> ' '
               @ MLINE,67 SAY PO_NBR + '-' + PO_SUFFIX
            ELSE
               @ MLINE,67 SAY PO_NBR 
            ENDIF
         ENDIF
         @ MLINE,79 SAY AMOUNT PICTURE '9,999,999.99'
         MLINE = MLINE + 1
      ENDIF
      MACTIVITY = MACTIVITY + AMOUNT
      SKIP
   ENDDO
   IF MACTIVITY <> 0 .OR. MDIV_ACT <> 0
      IF MYES_NO = 'Y'
         *** TOTALS ONLY - NEED TO FORMAT HEADERS HERE
         IF MLINE <> 99
            EJECT         
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 2,30 SAY MCOMPANY
         @ 3,1 SAY 'Page'
         @ 3,06 say mpage_no picture '99'
         IF DTOC(MPOSTED) <> '  /  /  '
            STORE MMONTH + ' - ' + DTOC(MPOSTED) TO MPRINT
         ELSE
            STORE MMONTH TO MPRINT
         ENDIF
         @ 3,25 SAY 'PURCHASE JOURNAL TOTALS FOR ' + MPRINT 
         @ 3,79  SAY DTOC(DATE())
         *** @ 3,01 SAY REPLICATE('_',90)
         MLINE = 5
      ENDIF
      MLINE = MLINE + 1
      @ MLINE,5 SAY 'TOTAL PURCHASE JOURNAL ACTIVITY: ' 
      @ MLINE,78 SAY MACTIVITY PICTURE '99,999,999.99'
      IF MDIV_ACT <> 0
         MLINE = MLINE + 2
         @ MLINE,5 SAY 'TOTAL DIVISION PURCHASES: ' 
         @ MLINE,78 SAY MDIV_ACT PICTURE '99,999,999.99'
      ENDIF
      @ MLINE+1,1 SAY ' '
      EJECT
   ENDIF
ENDIF

MTRAN_MO = MBUS_MO
MTRAN_YR = MBUS_YR
IF MCUS_SEL = 'X'
   IF MYES_NO <> 'Y'
      *** DO CUS_DUP (USED TO BE)
      SELECT A 
      DO FOX_USE WITH "SALESJRN", .F.
      INDEX ON POST_FLG + TRAN_YR + TRAN_MO + INV_NBR + COR_FLG + PALL_FLG TO SALESDUP
      DO FOX_USE WITH "SALESJRN INDEX SALESDUP", .F.
      SEEK ' '
      DO WHILE .NOT. EOF() .AND. POST_FLG = ' '
         IF COR_FLG = ' '
            SKIP
            LOOP
         ENDIF
         STORE INV_NBR TO MINV_NBR
         STORE AMOUNT TO MAMOUNT
         STORE BBUYCODE TO MBBUYCODE
         STORE SEQ TO MSEQ1
         STORE POST_DATE TO MPOST_DATE
         STORE TRAN_MO TO MTRAN_MO
         STORE TRAN_YR TO MTRAN_YR
         SKIP
         STORE SEQ TO MSEQ2
         IF .NOT. EOF() .AND. POST_FLG = ' ' .AND. TRAN_YR = MTRAN_YR .AND. ;
            TRAN_MO = MTRAN_MO .AND. INV_NBR = MINV_NBR .AND. (AMOUNT = -1 * MAMOUNT) ;
            .AND. BBUYCODE = MBBUYCODE .AND. MSEQ1 = '1' .AND. MSEQ2 = '2' .AND. ;
            POST_DATE = MPOST_DATE
            SKIP -1
            DELETE
            SKIP
            DELETE
            SKIP
         ENDIF
      ENDDO
      USE
      ****** END OF DELETING DUPLICATE ENTRIES
   ENDIF
   MTRAN_MO = MBUS_MO
   MTRAN_YR = MBUS_YR
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
   SELECT A
   DO FOX_USE WITH "SALESJRN INDEX SALESJRN", .F.
   
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   IF MOPT_DATE = SPACE(8)
      SEEK MTRAN_YR + MTRAN_MO
   ELSE
      SEEK MTRAN_YR + MTRAN_MO + MOPT_DATE
   ENDIF
   MACTIVITY = 0  
   MDIV_ACT  = 0
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      IF DTOC(MPOSTED) <> '  /  /  '
         IF MPOSTED <> POST_DATE
            SKIP
            LOOP
         ENDIF
      ENDIF
      IF BBUYCODE = 'I'
         IF BBUYCODE = 'ID'
            MDIV_ACT = MDIV_ACT + AMOUNT
         ENDIF
         SKIP
         LOOP
      ENDIF
      IF MYES_NO <> 'Y'
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            IF DTOC(MPOSTED) <> '  /  /  '
               STORE MMONTH + ' - ' + DTOC(MPOSTED) TO MPRINT
            ELSE
               STORE MMONTH TO MPRINT
            ENDIF
            @ 3,20 SAY 'SALES JOURNAL LISTING FOR ' + MPRINT 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY '  DATE  '
            @ 5,12 SAY 'ACCOUNT'
            @ 5,52 SAY 'INVOICE NBR'
            @ 5,67 SAY 'PO NUMBER'
            @ 5,82 SAY '   AMOUNT' 
            @ 5,01 SAY REPLICATE('_',90)
            MLINE = 7
            MDO_NM = .T.
         ENDIF
         STORE BBUYCODE TO MBBUYCODE
         SELECT B
         SEEK MBBUYCODE
         IF EOF()
            STORE 'CUS NOT ON FILE' TO MNAME
         ELSE
            STORE NAME TO MNAME
         ENDIF
         SELECT A
         @ MLINE,1 SAY TRAN_DATE
         @ MLINE,12 SAY MNAME
         IF INV_NBR <> SPACE(5) 
            @ MLINE,55 SAY INV_NBR
         ENDIF
         IF SALESMAN <> '  '
            IF PO_SUFFIX <> ' '
               @ MLINE,67 SAY SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
            ELSE
               @ MLINE,67 SAY SALESMAN + '-' + PO_NBR 
            ENDIF
         ELSE
            IF PO_SUFFIX <> ' '
               @ MLINE,67 SAY PO_NBR + '-' + PO_SUFFIX
            ELSE
               @ MLINE,67 SAY PO_NBR 
            ENDIF
         ENDIF
         @ MLINE,79 SAY AMOUNT PICTURE '9,999,999.99'
         MLINE = MLINE + 1
      ENDIF
      MACTIVITY = MACTIVITY + AMOUNT
      SKIP
   ENDDO
   IF MACTIVITY <> 0 .OR. MDIV_ACT <> 0
      IF MYES_NO = 'Y'
         *** TOTALS ONLY - NEED TO FORMAT HEADERS HERE
         IF MLINE <> 99
            EJECT         
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 2,30 SAY MCOMPANY
         @ 3,1 SAY 'Page'
         @ 3,06 say mpage_no picture '99'
         IF DTOC(MPOSTED) <> '  /  /  '
            STORE MMONTH + ' - ' + DTOC(MPOSTED) TO MPRINT
         ELSE
            STORE MMONTH TO MPRINT
         ENDIF
         @ 3,25 SAY 'SALES JOURNAL TOTALS FOR ' + MPRINT 
         @ 3,79  SAY DTOC(DATE())
         ** @ 3,01 SAY REPLICATE('_',90)
         MLINE = 5
      ENDIF
      
      MLINE = MLINE + 1
      @ MLINE,5 SAY 'TOTAL SALES JOURNAL ACTIVITY: ' 
      @ MLINE,78 SAY MACTIVITY PICTURE '99,999,999.99'
      IF MDIV_ACT <> 0
         MLINE = MLINE + 2
         @ MLINE,5 SAY 'TOTAL DIVISION SALES: ' 
         @ MLINE,78 SAY MDIV_ACT PICTURE '99,999,999.99'
      ENDIF
      @ MLINE+1,1 SAY ' '
      EJECT
   ENDIF
ENDIF


MTRAN_MO = MBUS_MO
MTRAN_YR = MBUS_YR
IF MCOM_SEL = 'X'
   IF MYES_NO <> 'Y'
      ** DO COM_DUP (USED TO BE)   
      SELECT A 
      DO FOX_USE WITH "COMJRN", .F.
      INDEX ON POST_FLG + TRAN_YR + TRAN_MO + INV_NBR + COM_TYPE + COM_CODE TO COMDUP
      DO FOX_USE WITH "COMJRN INDEX COMDUP", .F.
      SEEK ' '
      
      DO WHILE .NOT. EOF() .AND. POST_FLG = ' '
         IF COR_FLG = ' '
            SKIP
            LOOP
         ENDIF
         STORE INV_NBR TO MINV_NBR
         STORE AMOUNT TO MAMOUNT
         STORE COM_TYPE TO MCOM_TYPE 
         STORE COM_CODE TO MCOM_CODE
         STORE SEQ TO MSEQ1
         STORE TRAN_MO TO MTRAN_MO
         STORE TRAN_YR TO MTRAN_YR
         STORE POST_DATE TO MPOST_DATE
         SKIP
         STORE SEQ TO MSEQ2
         IF .NOT. EOF() .AND. POST_FLG = ' ' .AND. TRAN_YR = MTRAN_YR .AND. ;
            TRAN_MO = MTRAN_MO .AND. INV_NBR = MINV_NBR .AND. (AMOUNT = -1 * MAMOUNT) ;
            .AND. COM_CODE = MCOM_CODE .AND. COM_TYPE = MCOM_TYPE .AND. MSEQ1 = '1' ;
            .AND. MSEQ2 = '2' .AND. POST_DATE = MPOST_DATE
            SKIP -1
            DELETE
            SKIP
            DELETE
            SKIP
         ENDIF
      ENDDO
      USE
      ***** END OF DELETING DUPLICATE ENTRIES
   ENDIF
   MTRAN_MO = MBUS_MO
   MTRAN_YR = MBUS_YR
   
   SELECT A
   DO FOX_USE WITH "COMJRN INDEX COMJRN", .F.
   
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   
   IF MOPT_DATE = SPACE(8)
      SEEK MTRAN_YR + MTRAN_MO
   ELSE
      SEEK MTRAN_YR + MTRAN_MO + MOPT_DATE
   ENDIF
   MACTIVITY = 0  
   
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      IF DTOC(MPOSTED) <> '  /  /  '
         IF MPOSTED <> POST_DATE
            SKIP
            LOOP
         ENDIF
      ENDIF
      IF MYES_NO <> 'Y'
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            IF DTOC(MPOSTED) <> '  /  /  '
               STORE MMONTH + ' - ' + DTOC(MPOSTED) TO MPRINT
            ELSE
               STORE MMONTH TO MPRINT
            ENDIF
            @ 3,20 SAY 'COMMISSIONS JOURNAL LISTING FOR ' + MPRINT 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY '  DATE  '
            @ 5,12 SAY 'ACCOUNT'
            @ 5,52 SAY 'INVOICE NBR'
            @ 5,67 SAY 'PO NUMBER'
            @ 5,82 SAY '   AMOUNT' 
            @ 5,01 SAY REPLICATE('_',90)
            MLINE = 7
            MDO_NM = .T.
         ENDIF
         STORE COM_CODE TO MCOM_CODE
         IF COM_TYPE = 'S'
            SELECT B
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
         ELSE
            SELECT B
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         ENDIF
         SEEK MCOM_CODE
         IF EOF()
            STORE 'COMMISSION PAYEE NOT ON FILE' TO MNAME
         ELSE
            STORE NAME TO MNAME
         ENDIF
         SELECT A
         @ MLINE,1 SAY TRAN_DATE
         @ MLINE,12 SAY MNAME
         IF INV_NBR <> SPACE(5) 
            @ MLINE,55 SAY INV_NBR
         ENDIF
         IF SALESMAN <> '  '
            IF PO_SUFFIX <> ' '
               @ MLINE,67 SAY SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
            ELSE
               @ MLINE,67 SAY SALESMAN + '-' + PO_NBR 
            ENDIF
         ELSE
            IF PO_SUFFIX <> ' '
               @ MLINE,67 SAY PO_NBR + '-' + PO_SUFFIX
            ELSE
               @ MLINE,67 SAY PO_NBR 
            ENDIF
         ENDIF
         @ MLINE,79 SAY AMOUNT PICTURE '9,999,999.99'
         MLINE = MLINE + 1
      ENDIF
      MACTIVITY = MACTIVITY + AMOUNT
      SKIP
   ENDDO
   IF MACTIVITY <> 0
      IF MYES_NO = 'Y'
         *** TOTALS ONLY - NEED TO FORMAT HEADERS HERE
         IF MLINE <> 99
            EJECT         
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 2,30 SAY MCOMPANY
         @ 3,1 SAY 'Page'
         @ 3,06 say mpage_no picture '99'
         IF DTOC(MPOSTED) <> '  /  /  '
            STORE MMONTH + ' - ' + DTOC(MPOSTED) TO MPRINT
         ELSE
            STORE MMONTH TO MPRINT
         ENDIF
         @ 3,25 SAY 'COMMMISSION JOURNAL TOTALS FOR ' + MPRINT 
         @ 3,79  SAY DTOC(DATE())
         ** @ 3,01 SAY REPLICATE('_',90)
         MLINE = 5
      ENDIF
      MLINE = MLINE + 1
      @ MLINE,5 SAY 'TOTAL ALL ACTIVITY: ' 
      @ MLINE,78 SAY MACTIVITY PICTURE '99,999,999.99'
      @ MLINE+1,1 SAY ' '
      EJECT
   ENDIF
ENDIF   

MTRAN_MO = MBUS_MO
MTRAN_YR = MBUS_YR
IF MBBK_SEL = 'X'
   IF MYES_NO <> 'Y'
      ** DO COM_DUP (USED TO BE)   
      SELECT A 
      DO FOX_USE WITH "BBKJRN", .F.
      INDEX ON POST_FLG + TRAN_YR + TRAN_MO + INV_NBR + COM_TYPE + COM_CODE TO BBKDUP
      DO FOX_USE WITH "BBKJRN INDEX BBKDUP", .F.
      SEEK ' '
      
      DO WHILE .NOT. EOF() .AND. POST_FLG = ' '
         IF COR_FLG = ' '
            SKIP
            LOOP
         ENDIF
         STORE INV_NBR TO MINV_NBR
         STORE AMOUNT TO MAMOUNT
         STORE COM_TYPE TO MCOM_TYPE 
         STORE COM_CODE TO MCOM_CODE
         STORE SEQ TO MSEQ1
         STORE TRAN_MO TO MTRAN_MO
         STORE TRAN_YR TO MTRAN_YR
         STORE POST_DATE TO MPOST_DATE
         SKIP
         STORE SEQ TO MSEQ2
         IF .NOT. EOF() .AND. POST_FLG = ' ' .AND. TRAN_YR = MTRAN_YR .AND. ;
            TRAN_MO = MTRAN_MO .AND. INV_NBR = MINV_NBR .AND. (AMOUNT = -1 * MAMOUNT) ;
            .AND. COM_CODE = MCOM_CODE .AND. COM_TYPE = MCOM_TYPE .AND. MSEQ1 = '1' ;
            .AND. MSEQ2 = '2' .AND. POST_DATE = MPOST_DATE
            SKIP -1
            DELETE
            SKIP
            DELETE
            SKIP
         ENDIF
      ENDDO
      USE
      ***** END OF DELETING DUPLICATE ENTRIES
   ENDIF
   MTRAN_MO = MBUS_MO
   MTRAN_YR = MBUS_YR
   
   SELECT A
   DO FOX_USE WITH "BBKJRN INDEX BBKJRN", .F.
   
   MFIRST_TM = .T.
   MLINE = 99
   MPAGE_NO = 0
   MPAGE_LEN = 56
   
   IF MOPT_DATE = SPACE(8)
      SEEK MTRAN_YR + MTRAN_MO
   ELSE
      SEEK MTRAN_YR + MTRAN_MO + MOPT_DATE
   ENDIF
   MACTIVITY = 0  
   
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      IF DTOC(MPOSTED) <> '  /  /  '
         IF MPOSTED <> POST_DATE
            SKIP
            LOOP
         ENDIF
      ENDIF
      IF MYES_NO <> 'Y'
         IF MLINE > MPAGE_LEN 
            IF MLINE <> 99
               EJECT         
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 2,30 SAY MCOMPANY
            @ 3,1 SAY 'Page'
            @ 3,06 say mpage_no picture '99'
            IF DTOC(MPOSTED) <> '  /  /  '
               STORE MMONTH + ' - ' + DTOC(MPOSTED) TO MPRINT
            ELSE
               STORE MMONTH TO MPRINT
            ENDIF
            @ 3,20 SAY ' BILLBACK   JOURNAL LISTING FOR ' + MPRINT 
            @ 3,72  SAY DTOC(DATE())
            @ 5,1 SAY '  DATE  '
            @ 5,12 SAY 'ACCOUNT'
            @ 5,52 SAY 'INVOICE NBR'
            @ 5,67 SAY 'PO NUMBER'
            @ 5,82 SAY '   AMOUNT' 
            @ 5,01 SAY REPLICATE('_',90)
            MLINE = 7
            MDO_NM = .T.
         ENDIF
         STORE COM_CODE TO MCOM_CODE
         IF COM_TYPE = 'S'
            SELECT B
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
         ELSE
            SELECT B
            DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         ENDIF
         SEEK MCOM_CODE
         IF EOF()
            STORE '  BILLBACK PAYEE NOT ON FILE' TO MNAME
         ELSE
            STORE NAME TO MNAME
         ENDIF
         SELECT A
         @ MLINE,1 SAY TRAN_DATE
         @ MLINE,12 SAY MNAME
         IF INV_NBR <> SPACE(5) 
            @ MLINE,55 SAY INV_NBR
         ENDIF
         IF SALESMAN <> '  '
            IF PO_SUFFIX <> ' '
               @ MLINE,67 SAY SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX
            ELSE
               @ MLINE,67 SAY SALESMAN + '-' + PO_NBR 
            ENDIF
         ELSE
            IF PO_SUFFIX <> ' '
               @ MLINE,67 SAY PO_NBR + '-' + PO_SUFFIX
            ELSE
               @ MLINE,67 SAY PO_NBR 
            ENDIF
         ENDIF
         @ MLINE,79 SAY AMOUNT PICTURE '9,999,999.99'
         MLINE = MLINE + 1
      ENDIF
      MACTIVITY = MACTIVITY + AMOUNT
      SKIP
   ENDDO
   IF MACTIVITY <> 0
      IF MYES_NO = 'Y'
         *** TOTALS ONLY - NEED TO FORMAT HEADERS HERE
         IF MLINE <> 99
            EJECT         
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 2,30 SAY MCOMPANY
         @ 3,1 SAY 'Page'
         @ 3,06 say mpage_no picture '99'
         IF DTOC(MPOSTED) <> '  /  /  '
            STORE MMONTH + ' - ' + DTOC(MPOSTED) TO MPRINT
         ELSE
            STORE MMONTH TO MPRINT
         ENDIF
         @ 3,25 SAY '  BILLBACK  JOURNAL TOTALS FOR ' + MPRINT 
         @ 3,79  SAY DTOC(DATE())
         *** @ 3,01 SAY REPLICATE('_',90)
         MLINE = 5
      ENDIF
      MLINE = MLINE + 1
      @ MLINE,5 SAY 'TOTAL ALL ACTIVITY: ' 
      @ MLINE,78 SAY MACTIVITY PICTURE '99,999,999.99'
      @ MLINE+1,1 SAY ' '
      EJECT
   ENDIF
ENDIF   

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON
IF MPRINTER3 <> 'DONOTPRINT'
   RUN &MPRINTIT3
ENDIF
RETURN


PROCEDURE POSTJRN 
MTITLE = ' - POST JOURNAL ENTRIES TO LEDGER'

CLEAR
@ 01,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@  2,0 SAY MPROGRAM + MTITLE
@ 3,0 TO 24,79
STORE ' ' TO MFRT_SEL, MSUP_SEL, MCUS_SEL, MCOM_SEL, MDIS_SEL, MREC_SEL, MBBK_SEL
STORE 0 TO MTRAN_MO, MTRAN_YR
STORE 2 TO MACTION
DO WHILE MACTION = 2
   @ 04,5 SAY "SELECT WITH AN 'X' THE JOURNAL ENTRIES TO POST"
   @ 05,5 SAY '      FREIGHT JOURNAL: ' GET MFRT_SEL PICTURE '@!'
   @ 07,5 SAY '     PURCHASE JOURNAL: ' GET MSUP_SEL PICTURE '@!'
   @ 09,5 SAY '        SALES JOURNAL: ' GET MCUS_SEL PICTURE '@!'
   @ 11,5 SAY '  COMMISSIONS JOURNAL: ' GET MCOM_SEL PICTURE '@!'
   @ 13,5 SAY '     BILLBACK JOURNAL: ' GET MBBK_SEL PICTURE '@!'
   @ 15,5 SAY 'DISBURSEMENTS JOURNAL: ' GET MDIS_SEL PICTURE '@!'
   @ 17,5 SAY '  RECEIVABLES JOURNAL: ' GET MREC_SEL PICTURE '@!'
   @ 19,5 SAY '        POSTING MONTH: ' GET MTRAN_MO PICTURE '99' RANGE 1,12
   @ 21,5 SAY '         POSTING YEAR: ' GET MTRAN_YR PICTURE '####' RANGE 1988,2099
   STORE 1 TO MACTION
   @ 24,0 SAY 'Action: ' + STR(MACTION,1)
   @ 24,12 SAY '1. Continue      2. Edit     3. Cancel'
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
   
   READ
   DO CASE
   CASE MFRT_SEL <> ' ' .AND. MFRT_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "FREIGHT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MSUP_SEL <> ' ' .AND. MSUP_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "PURCHASE SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MCUS_SEL <> ' ' .AND. MCUS_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "SALES SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MCOM_SEL <> ' ' .AND. MCOM_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "COMMISSION SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MBBK_SEL <> ' ' .AND. MBBK_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "BILLBACK SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MDIS_SEL <> ' ' .AND. MDIS_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "DISBURSEMENT SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MREC_SEL <> ' ' .AND. MREC_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "RECEIVABLES SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   ENDCASE
ENDDO
STORE SUBSTR(STR(MTRAN_MO + 100,3),2) TO MTRAN_MO
STORE STR(MTRAN_YR,4) TO MTRAN_YR

IF MFRT_SEL = 'X'
   *** DO FRT_DUP     *USED TO BE DONE HERE AS WELL AS IN JOURNAL PRINT 
   *** ELIMINATED THIS STEP 1/18/90 BECAUSE JOURNALS ARE ALWAYS PRINTED 
   *** SO NO NEED TO DO IT TWICE.)
   
   SELECT B
   DO FOX_USE WITH "FRTLED INDEX FRTLED, FRTMATCH, FRTNOMAT", .F.
   SELECT A
   DO FOX_USE WITH "FRTJRN INDEX FRTJRN", .F.
   
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO FREIGHT JOURNAL ACTIVITY TO POST FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
   ENDIF
   @ 19,1 CLEAR TO 21,78
   @ 19,5 SAY 'POSTING.........PLEASE WAIT'
   SELECT A
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      IF POST_FLG <> ' '
         SKIP
         LOOP                                                                 
      ENDIF
      SELECT B
      DO FILELOCK
      APPEND BLANK
      REPLACE FRT_CODE WITH A->FRT_CODE
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->AMOUNT    
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH MTRAN_MO
      REPLACE TRAN_YR WITH MTRAN_YR
      REPLACE TRAN_DATE WITH A->TRAN_DATE
      REPLACE COR_FLG WITH A->COR_FLG
      UNLOCK
      SELECT A
      DO RECLOCK
      REPLACE POST_FLG WITH 'P'
      UNLOCK
      SKIP
   ENDDO
ENDIF
CLOSE DATA
IF MSUP_SEL = 'X'
   *** DO SUP_DUP      *USED TO BE DON HERE AS WELL AS IN JOURNAL PRINT
   *** ELIMINATED THIS STEP 1/18/90 BECAUSE JOURNALS ARE ALWAYS PRINTED 
   *** SO NO NEED TO DO IT TWICE.)
   
   SELECT B
   DO FOX_USE WITH "SUPLED INDEX SUPLED, SUPMATCH, SUPNOMAT", .F.
   SELECT A
   DO FOX_USE WITH "PURCHJRN INDEX PURCHJRN", .F.
   
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO PURCHASE JOURNAL ACTIVITY TO POST FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
   ENDIF
   @ 19,1 CLEAR TO 21,78
   @ 19,5 SAY 'POSTING.........PLEASE WAIT'
   SELECT A
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      IF POST_FLG <> ' '
         SKIP
         LOOP                                                                 
      ENDIF
      SELECT B
      DO FILELOCK
      APPEND BLANK
      REPLACE RSUPCODE WITH A->RSUPCODE
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->AMOUNT    
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH MTRAN_MO
      REPLACE TRAN_YR WITH MTRAN_YR
      REPLACE TRAN_DATE WITH A->TRAN_DATE
      REPLACE COR_FLG WITH A->COR_FLG
      REPLACE PALL_FLG WITH A->PALL_FLG
      UNLOCK
      SELECT A
      DO RECLOCK
      REPLACE POST_FLG WITH 'P'
      UNLOCK
      SKIP
   ENDDO
ENDIF
CLOSE DATA
IF MCUS_SEL = 'X'
   *** DO CUS_DUP       (USED TO BE DONE HERE AS WELL AS IN JOURNAL PRINT.
   *** ELIMINATED THIS STEP 1/18/90 BECAUSE JOURNALS ARE ALWAYS PRINTED 
   *** SO NO NEED TO DO IT TWICE.)
   
   SELECT B
   DO FOX_USE WITH "CUSLED INDEX CUSLED, CUSMATCH, CUSNOMAT", .F.
   SELECT A
   DO FOX_USE WITH "SALESJRN INDEX SALESJRN", .F.
   
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO SALES JOURNAL ACTIVITY TO POST FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
   ENDIF
   @ 19,1 CLEAR TO 21,78
   @ 19,5 SAY 'POSTING.........PLEASE WAIT'
   SELECT A
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      IF POST_FLG <> ' '
         SKIP
         LOOP                                                                 
      ENDIF
      SELECT B
      DO FILELOCK
      APPEND BLANK
      REPLACE BBUYCODE WITH A->BBUYCODE
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->AMOUNT    
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH MTRAN_MO
      REPLACE TRAN_YR WITH MTRAN_YR
      REPLACE TRAN_DATE WITH A->TRAN_DATE
      REPLACE COR_FLG WITH A->COR_FLG
      REPLACE PALL_FLG WITH A->PALL_FLG
      UNLOCK
      SELECT A
      DO RECLOCK
      REPLACE POST_FLG WITH 'P'
      UNLOCK
      SKIP
   ENDDO
ENDIF    
CLOSE DATA
IF MCOM_SEL = 'X'
   *** DO COM_DUP   (USED TO BE DONE HERE AS WELL AS IN JOURNAL PRINT.
   *** ELIMINATED THIS STEP 1/18/90 BECAUSE JOURNALS ARE ALWAYS PRINTED 
   *** SO NO NEED TO DO IT TWICE.)
   
   SELECT B
   DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
   SELECT A
   DO FOX_USE WITH "COMJRN INDEX COMJRN", .F.
   
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO COMMISSIONS JOURNAL ACTIVITY TO POST FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
   ENDIF
   @ 19,1 CLEAR TO 21,78
   @ 19,5 SAY 'POSTING.........PLEASE WAIT'
   SELECT A
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      IF POST_FLG <> ' '
         SKIP
         LOOP                                                                 
      ENDIF
      SELECT B
      DO FILELOCK
      APPEND BLANK
      REPLACE COM_CODE WITH A->COM_CODE
      REPLACE COM_TYPE WITH A->COM_TYPE
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->AMOUNT    
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH MTRAN_MO
      REPLACE TRAN_YR WITH MTRAN_YR
      REPLACE TRAN_DATE WITH A->TRAN_DATE
      REPLACE COR_FLG WITH A->COR_FLG
      IF MCOMPANY = 'DIVISION 15'
         REPLACE TOT_LBS WITH A->TOT_LBS
      ENDIF
      UNLOCK
      SELECT A
      DO RECLOCK
      REPLACE POST_FLG WITH 'P'
      UNLOCK
      SKIP
   ENDDO
ENDIF
CLOSE DATA
IF MBBK_SEL = 'X'
   SELECT B
   DO FOX_USE WITH "&MMASTDBF.BBKLED INDEX &MMASTDBF.BBKLED, &MMASTDBF.BBKPD", .F.
   SELECT A
   DO FOX_USE WITH "BBKJRN INDEX BBKJRN", .F.
   
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO BILLBACK JOURNAL ACTIVITY TO POST FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
   ENDIF
   @ 19,1 CLEAR TO 21,78
   @ 19,5 SAY 'POSTING.........PLEASE WAIT'
   SELECT A
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      IF POST_FLG <> ' '
         SKIP
         LOOP                                                                 
      ENDIF
      SELECT B
      DO FILELOCK
      APPEND BLANK
      REPLACE COM_CODE WITH A->COM_CODE
      REPLACE COM_TYPE WITH A->COM_TYPE
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->AMOUNT    
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH MTRAN_MO
      REPLACE TRAN_YR WITH MTRAN_YR
      REPLACE TRAN_DATE WITH A->TRAN_DATE
      REPLACE COR_FLG WITH A->COR_FLG
      IF MCOMPANY = 'DIVISION 15'
         REPLACE TOT_LBS WITH A->TOT_LBS
      ENDIF
      UNLOCK
      SELECT A
      DO RECLOCK
      REPLACE POST_FLG WITH 'P'
      UNLOCK
      SKIP
   ENDDO
ENDIF
CLOSE DATA
IF MDIS_SEL = 'X'
   
   @ 19,01 CLEAR TO 21,78
   STORE ' ' TO MCHOICE
   DO WHILE MCHOICE <> 'A' .AND. MCHOICE <> 'C' .AND. MCHOICE <> 'Q'
      @ 19,5 SAY 'Post  ALL  Monthly Disbursement Activity (A) or '
      @ 20,5 say 'ONLY Monthly Disbursement Commission Activity (C): ' get mchoice picture '@!'
      @ 21,5 say '(or (Q) to quit and return to menu)'
      READ
   ENDDO
   IF MCHOICE = 'Q'
      RETURN
   ENDIF
   
   SELECT E
   DO FOX_USE WITH "CUSLED INDEX CUSLED, CUSMATCH, CUSNOMAT", .F.
   SELECT D
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
   SELECT C
   DO FOX_USE WITH "FRTLED INDEX FRTLED, FRTMATCH, FRTNOMAT", .F.
   SELECT B
   DO FOX_USE WITH "SUPLED INDEX SUPLED, SUPMATCH, SUPNOMAT", .F.
   SELECT A
   DO FOX_USE WITH "DISBJRN INDEX DISBJRN", .F.
   
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO DISBURSEMENT JOURNAL ACTIVITY TO POST FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
   ENDIF
   @ 19,1 CLEAR TO 21,78
   @ 19,5 SAY 'POSTING.........PLEASE WAIT'
   SELECT A
   DO WHILE .NOT. EOF() .AND. JRNL_MO = MTRAN_MO .AND. JRNL_YR = MTRAN_YR
      
      IF POST_FLG <> ' '
         SKIP
         LOOP                                                                 
      ENDIF
      IF VOID_MAN = 'V' 
         SKIP
         LOOP
      ENDIF
      IF MCHOICE = 'C'  
         DO CASE
         CASE CATEGORY1 = '7150' .OR. CATEGORY1 = '7301' .OR. CATEGORY1 = '7350'  
            ** THIS IS OK FOR COMMISSIONS ONLY 
         CASE VAL(CATEGORY1) >= 8401 .AND. VAL(CATEGORY1) < 8450 
            ** THIS IS OK FOR COMMISSIONS ONLY
         CASE CATEGORY1 = '8020' .AND. SALESMAN <> '  '
            ** THIS IS PAYROLL FOR SALESPERSONS
         CASE CATEGORY1 = '8021' .AND. SALESMAN <> '  '
            ** THIS IS COMMISSION PAID  FOR EXPENSES REIM TO MIDWEST
         CASE VAL(CATEGORY1) >= 7000 .AND. VAL(CATEGORY1) <= 7010
            ** THIS IS FOR EXPENSES RECOVERED ON OUR SALESPERSONS
         OTHERWISE
            SKIP
            LOOP
         ENDCASE
      ENDIF
      IF ACCT_TYPE = 'O'
         DO CASE
            **** ACCOUNTS RECEIVABLE REIMBURSEMENT
         CASE CATEGORY1 = '150'
            SELECT E
            DO FILELOCK
            APPEND BLANK
            REPLACE BBUYCODE WITH A->ACCT_NBR      
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->AMOUNT1       
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->JRNL_MO
            REPLACE TRAN_YR WITH MTRAN_YR
            STORE A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR TO MX
            REPLACE TRAN_DATE WITH CTOD(MX)
            REPLACE CK_NBR WITH A->CK_NBR
            *** THIS IS A DISBURSEMENT
            REPLACE COR_FLG WITH 'D'
            UNLOCK
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
            ** MIDWEST FOODS INTL ADVANCE MUST BE CROSSED OVER TO ACCOUNTS REC 
         CASE CATEGORY1 = '160'
            SELECT E
            DO FILELOCK
            APPEND BLANK
            *** MIDWEST FOODS INTL CODE IS 123
            REPLACE BBUYCODE WITH ' 123'      
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->AMOUNT1       
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->JRNL_MO
            REPLACE TRAN_YR WITH MTRAN_YR
            STORE A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR TO MX
            REPLACE TRAN_DATE WITH CTOD(MX)
            REPLACE CK_NBR WITH A->CK_NBR
            *** THIS IS A DISBURSEMENT
            REPLACE COR_FLG WITH 'D'
            UNLOCK
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
            
            ** REKO FOODS ADVANCE MUST BE CROSSED OVER TO ACCOUNTS REC 
         CASE CATEGORY1 = '170'
            SELECT E
            DO FILELOCK
            APPEND BLANK
            *** REKO FOODS CODE IS 207
            REPLACE BBUYCODE WITH ' 207'      
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->AMOUNT1       
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->JRNL_MO
            REPLACE TRAN_YR WITH MTRAN_YR
            STORE A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR TO MX
            REPLACE TRAN_DATE WITH CTOD(MX)
            REPLACE CK_NBR WITH A->CK_NBR
            *** THIS IS A DISBURSEMENT
            REPLACE COR_FLG WITH 'D'
            UNLOCK
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
            
         CASE CATEGORY1 = '7150' .OR. CATEGORY1 = '7301' .OR. CATEGORY1 = '7350'
            IF SUBSTR(A->ACCT_NBR,1,1) = 'T'
               SELECT F
               DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
               SEEK SUBSTR(A->ACCT_NBR,3)
               IF BILL_BACK = 'Y'
                  DO FOX_USE WITH "&MMASTDBF.BBKLED INDEX &MMASTDBF.BBKLED, &MMASTDBF.BBKPD", .F.
               ELSE
                  DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
               ENDIF
            ELSE
               SELECT F
               DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
            ENDIF
            DO FILELOCK
            APPEND BLANK
            *** THIS IS A COMMISSION CHECK
            REPLACE COM_TYPE WITH SUBSTR(A->ACCT_NBR,1,1)
            REPLACE COM_CODE WITH SUBSTR(A->ACCT_NBR,3)
            REPLACE COM_PD WITH 'Y'
            REPLACE APRVD_FLG WITH 'Y'
            REPLACE AMOUNT WITH A->AMOUNT1 * -1  
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->JRNL_MO
            REPLACE TRAN_YR WITH MTRAN_YR
            STORE A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR TO MX
            REPLACE TRAN_DATE WITH CTOD(MX)
            REPLACE CK_NBR WITH A->CK_NBR
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE INV_NBR WITH A->INV_NBR
            *** THIS IS A DISBURSEMENT
            REPLACE COR_FLG WITH 'D'
            IF A->CATEGORY1 = '7301'
               REPLACE ADV_REP WITH 'A'
            ENDIF
            IF A->CATEGORY1 = '7350'
               REPLACE ADV_REP WITH 'R'
            ENDIF
            UNLOCK
            IF A->CATEGORY1 = '7301' .OR. A->CATEGORY1 = '7350'
               IF SUBSTR(A->ACCT_NBR,1,1) <> 'T'
                  STORE SUBSTR(A->ACCT_NBR,3) TO MCOM_CODE
                  SELECT F
                  DO FOX_USE WITH "&MDBFLOC.RESERVE INDEX &MDBFLOC.RESERVE", .F.
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE TRAN_MO WITH A->JRNL_MO
                  REPLACE TRAN_YR WITH MTRAN_YR
                  STORE A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR TO MX
                  REPLACE TRAN_DATE WITH CTOD(MX)
                  REPLACE CATEGORY WITH A->CATEGORY1
                  REPLACE AMOUNT WITH A->AMOUNT1       
                  REPLACE SALESMAN WITH MCOM_CODE
                  UNLOCK
               ENDIF
            ENDIF
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
         CASE CATEGORY1 = '7148' .OR. (VAL(CATEGORY1) >= 7000 .AND. VAL(CATEGORY1) <= 7010)
            *** CATEGORY1 = '7148'
            *** THIS IS A COMMISSIONS PAID FOR EXPENSES REIMBURSED TO MIDWEST
            *** CATEGORY1 >= 7000 .AND. CATEGORY1 < 7010
            *** THIS IS FOR EXPENSES RECOVERED ON OUR SALESPERSONS COMMISSIONS PAID
            SELECT F
            DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
            DO FILELOCK
            APPEND BLANK
            REPLACE COM_TYPE WITH 'S'                      
            IF A->CATEGORY1 = '7148'
               REPLACE COM_CODE WITH A->SALESMAN    
            ELSE
               REPLACE COM_CODE WITH SUBSTR(A->ACCT_NBR,3)
            ENDIF
            REPLACE COM_PD WITH 'Y'
            REPLACE APRVD_FLG WITH 'Y'
            REPLACE AMOUNT WITH A->AMOUNT1 * -1  
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->JRNL_MO
            REPLACE TRAN_YR WITH MTRAN_YR
            STORE A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR TO MX
            REPLACE TRAN_DATE WITH CTOD(MX)
            REPLACE CK_NBR WITH A->CK_NBR
            *** SAVE THE CATEGORY BACK INTO THE RECORD SO CAN PRINT OUT ON LEDGER
            REPLACE INV_NBR WITH A->CATEGORY1
            *** THIS IS A DISBURSEMENT
            REPLACE COR_FLG WITH 'D'
            UNLOCK
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
            
         CASE VAL(CATEGORY1) >= 8425 .AND. VAL(CATEGORY1) < 8450
            IF SUBSTR(A->ACCT_NBR,1,1) <> 'T'
               STORE SUBSTR(A->ACCT_NBR,3) TO MCOM_CODE
               SELECT F
               DO FOX_USE WITH "&MDBFLOC.RESERVE INDEX &MDBFLOC.RESERVE", .F.
               DO FILELOCK
               APPEND BLANK
               REPLACE TRAN_MO WITH A->JRNL_MO
               REPLACE TRAN_YR WITH MTRAN_YR
               REPLACE TRAN_DATE WITH CTOD(MX)
               REPLACE CATEGORY WITH A->CATEGORY1
               REPLACE AMOUNT WITH A->AMOUNT1       
               REPLACE ACT_CODE WITH 'D'       
               REPLACE SALESMAN WITH MCOM_CODE
               UNLOCK
            ENDIF
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
         CASE CATEGORY1 = '7404' .AND. MPROG_CODE = 1
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE RSUPCODE WITH ' 285'       
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->AMOUNT1 * -1
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->JRNL_MO
            REPLACE TRAN_YR WITH MTRAN_YR
            STORE A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR TO MX
            REPLACE TRAN_DATE WITH CTOD(MX)
            REPLACE CK_NBR WITH A->CK_NBR
            
            *** THIS IS A DISBURSEMENT
            REPLACE COR_FLG WITH 'D'
            UNLOCK
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
            
         CASE CATEGORY1 = '8020' .AND. SALESMAN <> '  '                          
            SELECT F
            DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
            DO FILELOCK
            APPEND BLANK
            *** THIS IS A PAYROLL CHECK FOR SALESPEOPLE
            REPLACE COM_TYPE WITH 'S' 
            REPLACE COM_CODE WITH A->SALESMAN
            REPLACE COM_PD WITH 'Y'
            REPLACE APRVD_FLG WITH 'Y'
            REPLACE AMOUNT WITH A->AMOUNT1 * -1  
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH A->JRNL_MO
            REPLACE TRAN_YR WITH MTRAN_YR
            STORE A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR TO MX
            REPLACE TRAN_DATE WITH CTOD(MX)
            REPLACE CK_NBR WITH A->CK_NBR
            *** THIS IS A DISBURSEMENT
            REPLACE COR_FLG WITH 'D'
            UNLOCK
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
            
         OTHERWISE
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            SKIP
            LOOP
         ENDCASE
      ENDIF 
      
      IF ACCT_TYPE = 'S' 
         SELECT B
         DO FILELOCK
         APPEND BLANK
         REPLACE RSUPCODE WITH A->ACCT_NBR
         REPLACE SALESMAN WITH A->SALESMAN
         REPLACE INV_NBR WITH A->INV_NBR
         REPLACE PO_NBR WITH A->PO_NBR
         REPLACE PO_SUFFIX WITH A->PO_SUFFIX
         REPLACE AMOUNT WITH A->AMOUNT1 * -1
         REPLACE POST_DATE WITH DATE()
         REPLACE TRAN_MO WITH A->JRNL_MO
         REPLACE TRAN_YR WITH MTRAN_YR
         STORE A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR TO MX
         REPLACE TRAN_DATE WITH CTOD(MX)
         REPLACE CK_NBR WITH A->CK_NBR
         
         *** THIS IS A DISBURSEMENT
         REPLACE COR_FLG WITH 'D'
         IF A->CATEGORY1 = 'F' .OR. A->CATEGORY1 = 'L'
            REPLACE PALL_FLG WITH 'Y'
         ENDIF
         UNLOCK
         SELECT A
         DO RECLOCK
         REPLACE POST_FLG WITH 'P'
         UNLOCK
         SKIP
         LOOP
      ENDIF
      IF ACCT_TYPE = 'F'
         SELECT C
         DO FILELOCK
         APPEND BLANK
         REPLACE FRT_CODE WITH A->ACCT_NBR
         REPLACE SALESMAN WITH A->SALESMAN
         REPLACE INV_NBR WITH A->INV_NBR
         REPLACE PO_NBR WITH A->PO_NBR
         REPLACE PO_SUFFIX WITH A->PO_SUFFIX
         REPLACE AMOUNT WITH A->AMOUNT1 * -1
         REPLACE POST_DATE WITH DATE()
         REPLACE TRAN_MO WITH A->JRNL_MO
         REPLACE TRAN_YR WITH MTRAN_YR
         STORE A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR TO MX
         REPLACE TRAN_DATE WITH CTOD(MX)
         REPLACE CK_NBR WITH A->CK_NBR
         *** THIS IS A DISBURSEMENT
         REPLACE COR_FLG WITH 'D'
         UNLOCK
         SELECT A
         DO RECLOCK
         REPLACE POST_FLG WITH 'P'
         UNLOCK
         SKIP
         LOOP
      ENDIF
      
      *** PAYROLL FOR SALESPEOPLE - ACCT_TYPE = 'P' - SALESPERSON CODE <> '  '
      IF ACCT_TYPE = 'P' .AND. SALESMAN <> '  ' .AND. CATEGORY1 = '8020'
         SELECT F
         DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
         DO FILELOCK
         APPEND BLANK
         *** THIS IS A PAYROLL CHECK FOR SALESPEOPLE
         REPLACE COM_TYPE WITH 'S' 
         REPLACE COM_CODE WITH A->SALESMAN
         REPLACE COM_PD WITH 'Y'
         REPLACE APRVD_FLG WITH 'Y'
         REPLACE AMOUNT WITH A->AMOUNT1 * -1  
         REPLACE POST_DATE WITH DATE()
         REPLACE TRAN_MO WITH A->JRNL_MO
         REPLACE TRAN_YR WITH MTRAN_YR
         STORE A->JRNL_MO + '/' + A->JRNL_DAY + '/' + A->JRNL_YR TO MX
         REPLACE TRAN_DATE WITH CTOD(MX)
         REPLACE CK_NBR WITH A->CK_NBR
         *** THIS IS A DISBURSEMENT
         REPLACE COR_FLG WITH 'D'
         UNLOCK
      ENDIF 
      SELECT A
      DO RECLOCK
      REPLACE POST_FLG WITH 'P'
      UNLOCK
      SKIP
      
   ENDDO
ENDIF
CLOSE DATA
IF MREC_SEL = 'X'
   SELECT B
   DO FOX_USE WITH "CUSLED INDEX CUSLED, CUSMATCH, CUSNOMAT", .F.
   
   SELECT A
   DO FOX_USE WITH "PAYMENTS INDEX PAY_DATE", .F.
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'THERE IS NO RECEIVABLE ACTIVITY TO POST FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
   ENDIF
   @ 19,1 CLEAR TO 21,78
   @ 19,5 SAY 'POSTING.........PLEASE WAIT'
   SELECT A
   DO WHILE .NOT. EOF() .AND. SUBSTR(DTOC(PAID_DATE),7) = MTRAN_YR .AND. SUBSTR(DTOC(PAID_DATE),1,2) = MTRAN_MO
      IF POST_FLG <> ' '
         SKIP
         LOOP                                                                 
      ENDIF
      DO CASE
      CASE ACCOUNT <> SPACE(4)
         ** MIDWEST FOODS INTL ADVANCE REPAYMENT MUST BE PUT IN ACCOUNTS REC 
         IF A->ACCOUNT = '161'
            SELECT B
            DO FILELOCK
            APPEND BLANK
            *** MIDWEST FOODS INTL CODE IS 123
            REPLACE BBUYCODE WITH ' 123'      
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH (A->AMT_PAID * -1)
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH MTRAN_MO
            REPLACE TRAN_YR WITH MTRAN_YR
            REPLACE CK_NBR WITH A->CK_NBR
            REPLACE TRAN_DATE WITH A->PAID_DATE
            *** THIS IS A RECEIPT     
            REPLACE COR_FLG WITH 'R'
            UNLOCK
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
         ENDIF
         ** REKO FOODS ADVANCE MUST BE PUT IN ACCOUNTS REC 
         IF A->ACCOUNT = '171'
            SELECT B
            DO FILELOCK
            APPEND BLANK
            *** REKO FOODS CODE IS 207
            REPLACE BBUYCODE WITH ' 207'      
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH (A->AMT_PAID * -1)
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH MTRAN_MO
            REPLACE TRAN_YR WITH MTRAN_YR
            REPLACE CK_NBR WITH A->CK_NBR
            REPLACE TRAN_DATE WITH A->PAID_DATE
            *** THIS IS A RECEIPT     
            REPLACE COR_FLG WITH 'R'
            UNLOCK
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
         ENDIF
         *** ACCOUNT 151 IS AN ACCOUNTS PAYABLE  SUPPLIER CROSSOVER
         IF A->ACCOUNT = '151'
            SELECT C
            DO FOX_USE WITH "SUPLED INDEX SUPLED, SUPMATCH, SUPNOMAT", .F.
            DO FILELOCK
            APPEND BLANK
            REPLACE RSUPCODE WITH A->BBUYCODE 
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->AMT_OVER        
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH MTRAN_MO
            REPLACE TRAN_YR WITH MTRAN_YR
            REPLACE CK_NBR WITH A->CK_NBR
            REPLACE TRAN_DATE WITH A->PAID_DATE
            *** THIS IS A RECEIPT     
            REPLACE COR_FLG WITH 'R'
            UNLOCK
            USE
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
         ENDIF
         *** ACCOUNT 152 IS AN ACCOUNTS PAYABLE  FREIGHT CROSSOVER
         IF A->ACCOUNT = '152'
            SELECT C
            DO FOX_USE WITH "FRTLED INDEX FRTLED, FRTMATCH, FRTNOMAT", .F.
            DO FILELOCK
            APPEND BLANK
            REPLACE FRT_CODE WITH A->BBUYCODE 
            REPLACE SALESMAN WITH A->SALESMAN
            REPLACE INV_NBR WITH A->INV_NBR
            REPLACE PO_NBR WITH A->PO_NBR
            REPLACE PO_SUFFIX WITH A->PO_SUFFIX
            REPLACE AMOUNT WITH A->AMT_OVER        
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH MTRAN_MO
            REPLACE TRAN_YR WITH MTRAN_YR
            REPLACE CK_NBR WITH A->CK_NBR
            REPLACE TRAN_DATE WITH A->PAID_DATE
            *** THIS IS A RECEIPT     
            REPLACE COR_FLG WITH 'R'
            UNLOCK
            USE
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
         ENDIF
         IF A->ACCOUNT = '7149' .OR. A->ACCOUNT = '7350' .OR. A->ACCOUNT = '7150'
            SELECT C
            DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
            DO FILELOCK
            APPEND BLANK
            *** THIS IS A COMMISSIONS PAID/COMMISSIONS ADVANCE REPAID
            *** ASSUME IT IS MW SALES FOR NOW
            REPLACE COM_TYPE WITH 'S'                     
            REPLACE COM_CODE WITH A->SALESMAN           
            REPLACE COM_PD WITH 'Y'
            REPLACE APRVD_FLG WITH 'Y'
            REPLACE AMOUNT WITH A->AMT_OVER      
            REPLACE POST_DATE WITH DATE()
            REPLACE TRAN_MO WITH MTRAN_MO   
            REPLACE TRAN_YR WITH MTRAN_YR
            REPLACE TRAN_DATE WITH A->PAID_DATE
            REPLACE CK_NBR WITH A->CK_NBR
            IF A->ACCOUNT = '7350'
               REPLACE ADV_REP WITH 'R'
            ENDIF
            *** THIS IS A RECEIPT     
            REPLACE COR_FLG WITH 'R'
            UNLOCK
            IF A->ACCOUNT = '7530'
               STORE A->SALESMAN TO MCOM_CODE
               SELECT C
               DO FOX_USE WITH "&MDBFLOC.RESERVE INDEX &MDBFLOC.RESERVE", .F.
               DO FILELOCK
               APPEND BLANK
               REPLACE TRAN_MO WITH MTRAN_MO  
               REPLACE TRAN_YR WITH MTRAN_YR
               REPLACE TRAN_DATE WITH A->PAID_DATE
               REPLACE CATEGORY WITH A->ACCOUNT   
               REPLACE AMOUNT WITH (A->AMT_OVER * -1) 
               REPLACE SALESMAN WITH MCOM_CODE
               UNLOCK
            ENDIF
            SELECT A
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
         ENDIF
      OTHERWISE
         IF BBUYCODE <> SPACE(4) .AND. BBUYCODE <> 'NONE'
            IF AMT_PAID <> 0
               SELECT B
               DO FILELOCK
               APPEND BLANK
               REPLACE BBUYCODE WITH A->BBUYCODE
               REPLACE SALESMAN WITH A->SALESMAN
               REPLACE INV_NBR WITH A->INV_NBR
               REPLACE PO_NBR WITH A->PO_NBR
               REPLACE PO_SUFFIX WITH A->PO_SUFFIX
               REPLACE AMOUNT WITH (A->AMT_PAID * -1)
               REPLACE POST_DATE WITH DATE()
               REPLACE TRAN_MO WITH MTRAN_MO
               REPLACE TRAN_YR WITH MTRAN_YR
               REPLACE CK_NBR WITH A->CK_NBR
               REPLACE TRAN_DATE WITH A->PAID_DATE
               *** THIS IS A RECEIPT     
               REPLACE COR_FLG WITH 'R'
               UNLOCK
               SELECT A
            ENDIF
            IF CRED_AMT <> 0
               SELECT C
               DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
               SEEK A->BBUYCODE
               SELECT B
               DO FILELOCK
               APPEND BLANK
               REPLACE BBUYCODE WITH A->BBUYCODE
               REPLACE SALESMAN WITH A->SALESMAN
               REPLACE INV_NBR WITH A->INV_NBR
               REPLACE PO_NBR WITH A->PO_NBR
               REPLACE PO_SUFFIX WITH A->PO_SUFFIX
               REPLACE AMOUNT WITH (A->CRED_AMT * -1)
               REPLACE POST_DATE WITH DATE()
               REPLACE TRAN_MO WITH MTRAN_MO
               REPLACE TRAN_YR WITH MTRAN_YR
               REPLACE CK_NBR WITH A->CK_NBR
               REPLACE TRAN_DATE WITH A->PAID_DATE
               *** THIS IS A RECEIPT     
               REPLACE COR_FLG WITH 'R'
               IF C->CRED_BAL <> 'N'
                  REPLACE LED_CODE WITH 'CRED'
               ENDIF
               UNLOCK
               SELECT A
            ENDIF
            DO RECLOCK
            REPLACE POST_FLG WITH 'P'
            UNLOCK
         ENDIF
      ENDCASE
      SKIP
   ENDDO
ENDIF  

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON

CLOSE DATA
RETURN
* EOF: POSTJRN.PRG
******************************



PROCEDURE CONVLED
MTITLE = ' - CONSOLIDATE LEDGER ACCOUNTS'
CLEAR
@ 01,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@  2,0 SAY MPROGRAM + MTITLE
@ 3,0 TO 24,79
STORE ' ' TO MSUP_SEL, MCUS_SEL, MBBK_SEL
STORE 0 TO MTRAN_MO, MTRAN_YR
STORE 2 TO MACTION
DO WHILE MACTION = 2
   @ 05,5 SAY "SELECT WITH AN 'X' THE LEDGER ENTRIES TO CONSOLIDATE"
   @ 06,5 SAY '(Note: Only consolidate one ledger at a time !)'
   @ 09,5 SAY '     PURCHASE LEDGER: ' GET MSUP_SEL PICTURE '@!'
   @ 11,5 SAY '        SALES LEDGER: ' GET MCUS_SEL PICTURE '@!'
   @ 13,5 SAY '     BILLBACK LEDGER: ' GET MBBK_SEL PICTURE '@!'
   @ 17,5 SAY '       ACTIVITY MONTH: ' GET MTRAN_MO PICTURE '99' RANGE 1,12
   @ 19,5 SAY '        ACTIVITY YEAR: ' GET MTRAN_YR PICTURE '####' RANGE 1988,2099
   STORE 1 TO MACTION
   @ 24,0 SAY 'Action: ' + STR(MACTION,1)
   @ 24,12 SAY '1. Continue      2. Edit     3. Cancel'
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
   
   READ
   DO CASE
      
   CASE MSUP_SEL <> ' ' .AND. MSUP_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "PURCHASE SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MCUS_SEL <> ' ' .AND. MCUS_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "SALES SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
   CASE MBBK_SEL <> ' ' .AND. MBBK_SEL <> 'X'
      @ 24,0 CLEAR
      STORE ' ' TO MWAIT
      @ 24,1 SAY "BILLBACK SELECTION MUST BE A BLANK OR 'X' - PLEASE REENTER " GET MWAIT
      READ
      @ 24,0 CLEAR
      MACTION = 2
      LOOP
      
      
   ENDCASE
ENDDO
STORE SUBSTR(STR(MTRAN_MO + 100,3),2) TO MTRAN_MO
STORE STR(MTRAN_YR,4) TO MTRAN_YR

DO CASE 
   
CASE MSUP_SEL = 'X'
   SELECT A
   DO FOX_USE WITH "SUPLED", .F.
   INDEX ON TRAN_YR + TRAN_MO + RSUPCODE TO TMP_IDX
   USE       
   DO FOX_USE WITH "SUPLED INDEX TMP_IDX, SUPLED, SUPMATCH, SUPNOMAT", .F.
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
   SELECT A
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'NO LEDGER ACTIVITY TO CONSOLIDATE FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
      RETURN
   ENDIF
   @ 19,5 SAY 'CONSOLIDATING......PLEASE WAIT'
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      
      STORE RSUPCODE TO MRSUPCODE
      SELECT B
      SEEK MRSUPCODE
      IF EOF()
         STORE SPACE(4) TO MLED_CODE 
      ELSE
         STORE LED_CODE TO MLED_CODE
      ENDIF
      SELECT A
      DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. RSUPCODE = MRSUPCODE
         DO FILELOCK
         IF MLED_CODE = SPACE(4)
            REPLACE LED_CODE WITH RSUPCODE
         ELSE
            REPLACE LED_CODE WITH MLED_CODE
         ENDIF
         UNLOCK
         SKIP
      ENDDO
   ENDDO
   
CASE MCUS_SEL = 'X'
   SELECT A
   DO FOX_USE WITH "CUSLED", .F.
   INDEX ON TRAN_YR + TRAN_MO + BBUYCODE TO  TMP_IDX
   USE
   DO FOX_USE WITH "CUSLED INDEX TMP_IDX, CUSLED, CUSMATCH, CUSNOMAT", .F.
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
   
   SELECT A
   SEEK MTRAN_YR + MTRAN_MO
   
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'NO LEDGER ACTIVITY TO CONSOLIDATE FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
      RETURN
   ENDIF
   @ 19,5 SAY 'CONSOLIDATING......PLEASE WAIT'
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      *** NO NEED TO CONSOLIDATE THE A/R CREDIT BALANCE ACCOUNT 
      IF LED_CODE = 'CRED'
         SKIP
         LOOP
      ENDIF
      STORE BBUYCODE TO MBBUYCODE
      SELECT B
      SEEK MBBUYCODE
      IF EOF()
         STORE SPACE(4) TO MLED_CODE 
      ELSE
         STORE LED_CODE TO MLED_CODE
      ENDIF
      SELECT A
      DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. BBUYCODE = MBBUYCODE
         IF LED_CODE = 'CRED'
            SKIP
            LOOP
         ENDIF
         DO FILELOCK
         IF MLED_CODE = SPACE(4)
            REPLACE LED_CODE WITH BBUYCODE
         ELSE
            REPLACE LED_CODE WITH MLED_CODE
         ENDIF
         UNLOCK
         SKIP
      ENDDO
   ENDDO
CASE MBBK_SEL = 'X'
   SELECT A
   DO FOX_USE WITH "BBKLED", .F.
   INDEX ON TRAN_YR + TRAN_MO + COM_CODE TO TMP_IDX
   USE       
   
   DO FOX_USE WITH "BBKLED INDEX TMP_IDX, BBKLED, BBKPD", .F.
   SELECT B
   DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
   
   SELECT A
   SEEK MTRAN_YR + MTRAN_MO
   IF EOF()
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      @ 4,1 CLEAR TO 20,78
      STORE ' ' TO MWAIT
      @ 10,1 SAY 'NO LEDGER ACTIVITY TO CONSOLIDATE FOR THIS MONTH - PRESS RETURN ' GET MWAIT
      READ
      RETURN
   ENDIF
   @ 19,5 SAY 'CONSOLIDATING......PLEASE WAIT'
   DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO
      
      STORE COM_CODE TO MCOM_CODE
      SELECT B
      SEEK MCOM_CODE
      IF EOF()
         STORE SPACE(2) TO MLED_CODE 
      ELSE
         STORE LED_CODE TO MLED_CODE
      ENDIF
      
      SELECT A
      DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. COM_CODE = MCOM_CODE
         DO FILELOCK
         IF MLED_CODE = SPACE(2)
            REPLACE LED_CODE WITH COM_CODE
         ELSE
            REPLACE LED_CODE WITH MLED_CODE
         ENDIF
         UNLOCK
         SKIP
      ENDDO
   ENDDO
ENDCASE
RETURN
* EOF: CONVLED.PRG


*****************************
PROCEDURE UPDSPRD
MTITLE = ' - UPDATE SPREADSHEET INFORMATION'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
STORE DATE() TO MPOST_DATE
DIMENSION MUPDRCD(15)  
DIMENSION MCK(15)
DIMENSION MCK_LINE(15)
STORE 0 TO MZERO

MNEXT_ENT = .T.
SELECT B
DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
SELECT C
DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.

SELECT D
DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.

@ 3,0 to 25,79
STORE ' ' TO MENTRY
DO WHILE MENTRY <> 'I' .AND. MENTRY <> 'C'
   STORE 'I' TO MENTRY 
   @ 10,5 say 'Do You Want to Update Invoices (I) or Corrections (C) ? ' GET MENTRY PICTURE '@!'
   READ
ENDDO
IF MENTRY <> 'I'
   STORE 'C' TO MENTRY
ENDIF
SELECT A
DO FOX_USE WITH "DAILYJRN INDEX POSTED", .F.
IF MENTRY = 'I'
   SEEK ' I'
ELSE
   SEEK ' C'
ENDIF
IF EOF()
   @ 4,1 CLEAR TO 22,78
   @ 10,5 SAY 'THERE ARE NO UNPOSTED ENTRIES '
   STORE ' ' TO MWAIT
   @ 12,5 SAY 'PRESS ENTER TO CONTINUE ' GET MWAIT
   READ
   RETURN
ENDIF
@ 3,0 CLEAR
@ 3,0 TO 5,79
@ 04,1  SAY '  Sal Inv  PO'
@ 4,18 say 'Cust'
@ 4,27 say 'Selling'
@ 4,36 say 'Supplr'
@ 4,44 say 'Purchase'
@ 4,54 say 'Freight'
@ 04,63 say '  Comm'
@ 04,72 say '    Net'
@ 23,0 to 25,79
MMORE = .T.
STORE RECNO() TO MRECNO
DO WHILE MMORE
   GOTO MRECNO
   MLINE = 7
   I = 1
   
   STORE 0 TO MCK_LINE, MUPDRCD   
   STORE SPACE(1) TO MCK
   
   DO WHILE .NOT. EOF() .AND. POST_FLG = ' ' .AND. MENTRY = INV_COR .AND. MMORE .AND. MLINE <= 22
      M = 1
      IF SAL_CODE2 <> '  '
         M = M + 1
      ENDIF
      IF SAL_CODE3 <> '  '
         M = M + 1
      ENDIF
      IF COM_CODE <> '  '
         M = M + 1
      ENDIF
      IF COM_CODE2 <> '  '
         M = M + 1
      ENDIF
      IF COM_CODE3 <> '  '
         M = M + 1
      ENDIF
      IF CUS_PALL <> 0 .OR. SUP_PALL <> 0 .OR. FRT_PALL <> 0
         M = M + 1
      ENDIF
      IF MLINE + M >= 22
         MLINE = 23
         LOOP
      ENDIF
      
      STORE RSUPCODE TO MRSUPCODE
      STORE BBUYCODE TO MBBUYCODE
      
      IF MRSUPCODE <> 'NONE'
         SELECT B
         SEEK MRSUPCODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,6) TO MRSUPNAME
         ELSE 
            STORE 'NOT FD' TO MRSUPNAME
         ENDIF
      ELSE
         STORE 'NONE  ' TO MRSUPNAME
      ENDIF
      
      IF MBBUYCODE <> 'NONE'
         SELECT C
         SEEK MBBUYCODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,6) TO MBBUYNAME
         ELSE 
            STORE 'NOT FD' TO MBBUYNAME
         ENDIF
      ELSE
         STORE 'NONE' TO MBBUYNAME
      ENDIF
      
      SELECT A   
      @ MLINE,2 SAY SALESMAN
      @ MLINE,5 SAY INV_NBR    
      @ MLINE,12 SAY PO_NBR
      IF PO_SUFFIX <> ' '
         @ MLINE,16 SAY PO_SUFFIX
      ENDIF
      @ MLINE,18 SAY MBBUYNAME
      @ MLINE,25 SAY TOT_SELL PICTURE '999999.99'
      @ MLINE,36 SAY MRSUPNAME
      @ MLINE,43 SAY TOT_PURCH PICTURE '999999.99'
      @ MLINE,53 SAY FRT_AMT1 PICTURE '99999.99'
      @ MLINE,62 SAY SALE_COMM PICTURE '99999.99'
      @ MLINE,71 SAY TOT_NET PICTURE '999999.99'
      
      STORE MLINE TO MCK_LINE(I)
      STORE RECNO() TO MUPDRCD(I)
      
      I = I + 1
      MLINE = MLINE + 1
      IF CUS_PALL <> 0 .OR. SUP_PALL <> 0 .OR. FRT_PALL <> 0
         @ MLINE,18 SAY 'PALLETS'
         @ MLINE,25 SAY CUS_PALL PICTURE '@Z 999999.99'
         @ MLINE,43 SAY SUP_PALL PICTURE '@Z 999999.99'
         @ MLINE,53 SAY FRT_PALL PICTURE '@Z 99999.99'
         MLINE = MLINE + 1
      ENDIF
      
      **RON MONTGOMERY CHANGES
      IF SAL_CODE2 <> '  '
         **@ MLINE,3 SAY SAL_CODE2
         STORE SAL_CODE2 TO MCOM_CODE
         SELECT D
         SEEK MCOM_CODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,6) TO MCOM_NAME
         ELSE  
            STORE SPACE(6) TO MCOM_NAME
         ENDIF
         
         @ MLINE,18 SAY MCOM_NAME
         SELECT A
         @ MLINE,62 SAY SALE2_AMT PICTURE '99999.99'
         MLINE = MLINE + 1
      ENDIF
      
      IF SAL_CODE3 <> '  '
         @ MLINE,3 SAY SAL_CODE3
         @ MLINE,62 SAY SALE3_AMT PICTURE '99999.99'
         MLINE = MLINE + 1
      ENDIF
      
      IF COM_CODE <> '  '
         STORE COM_CODE TO MCOM_CODE
         SELECT D
         SEEK MCOM_CODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,6) TO MCOM_NAME
         ELSE  
            STORE SPACE(6) TO MCOM_NAME
         ENDIF
         
         @ MLINE,18 SAY MCOM_NAME
         SELECT A
         @ MLINE,62 SAY COMM_AMT PICTURE '99999.99'
         MLINE = MLINE + 1
      ENDIF
      IF COM_CODE2 <> '  '
         STORE COM_CODE2 TO MCOM_CODE
         SELECT D
         SEEK MCOM_CODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,6) TO MCOM_NAME
         ELSE  
            STORE SPACE(6) TO MCOM_NAME
         ENDIF
         
         @ MLINE,18 SAY MCOM_NAME
         SELECT A
         @ MLINE,62 SAY COMM_AMT2 PICTURE '99999.99'
         MLINE = MLINE + 1
      ENDIF
      
      IF COM_CODE3 <> '  '
         STORE COM_CODE3 TO MCOM_CODE
         SELECT D
         SEEK MCOM_CODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,6) TO MCOM_NAME
         ELSE  
            STORE SPACE(6) TO MCOM_NAME
         ENDIF
         
         @ MLINE,18 SAY MCOM_NAME
         SELECT A
         @ MLINE,62 SAY COMM_AMT3 PICTURE '99999.99'
         MLINE = MLINE + 1
      ENDIF
      
      SELECT A
      SKIP
      STORE RECNO() TO MRECNO
   ENDDO
   
   STORE I-1 TO MMAX_I
   
   STORE 2 TO MACTION
   
   DO WHILE MACTION = 2
      STORE SPACE(1) TO MCK(I)
      I = 1
      DO WHILE I<= MMAX_I
         @ MCK_LINE(I),0 GET MCK(I) PICTURE '@!'
         READ
         IF MCK(I) = 'D'
            GOTO MUPDRCD(I)
            DO RECLOCK
            DELETE
            UNLOCK
            STORE MCK_LINE(I) TO MLINE
            @ MLINE,26 SAY MZERO PICTURE '99999.99'
            @ MLINE,44 SAY MZERO PICTURE '99999.99'
            @ MLINE,54 SAY MZERO PICTURE '9999.99'
            @ MLINE,63 SAY MZERO PICTURE '9999.99'
            @ MLINE,72 SAY MZERO PICTURE '99999.99'
            MLINE = MLINE + 1
            IF CUS_PALL <> 0 .OR. SUP_PALL <> 0 .OR. FRT_PALL <> 0
               @ MLINE,25 SAY MZERO    PICTURE '@Z 999999.99'
               @ MLINE,43 SAY MZERO    PICTURE '@Z 999999.99'
               @ MLINE,53 SAY MZERO    PICTURE '@Z 99999.99'
               MLINE = MLINE + 1
            ENDIF
            IF SAL_CODE2 <> '  ' 
               @ MLINE,62 SAY MZERO     PICTURE '99999.99'
               MLINE = MLINE + 1
            ENDIF
            IF SAL_CODE3 <> '  ' 
               @ MLINE,62 SAY MZERO     PICTURE '99999.99'
               MLINE = MLINE + 1
            ENDIF
            IF COM_CODE <> '  '
               @ MLINE,62 SAY MZERO    PICTURE '99999.99'
               MLINE = MLINE + 1
            ENDIF
            IF COM_CODE2 <> '  '
               @ MLINE,62 SAY MZERO    PICTURE '99999.99'
               MLINE = MLINE + 1
            ENDIF
         ELSE 
            IF MCK(I) = 'X' .OR. MCK(I) = 'C'
               GOTO MUPDRCD(I)
               STORE TOT_SELL TO MTOT_SELL
               STORE TOT_PURCH TO MTOT_PURCH
               STORE FRT_AMT1 TO MFRT
               STORE SALE_COMM TO MSALE_COMM
               STORE TOT_NET TO MTOT_NET
               STORE SALE2_AMT TO MSALE2_AMT
               STORE SALE3_AMT TO MSALE3_AMT
               STORE COMM_AMT TO MCOMM_AMT
               STORE COMM_AMT2 TO MCOMM_AMT2
               STORE COMM_AMT3 TO MCOMM_AMT3
               STORE CUS_PALL TO MCUS_PALL
               STORE SUP_PALL TO MSUP_PALL
               STORE FRT_PALL TO MFRT_PALL
               STORE MCK_LINE(I) TO MLINE
               
               @ MLINE,25 GET MTOT_SELL PICTURE '999999.99'
               @ MLINE,43 GET MTOT_PURCH PICTURE '999999.99'
               @ MLINE,53 GET MFRT PICTURE '99999.99'
               @ MLINE,62 GET MSALE_COMM PICTURE '99999.99'
               
               MLINE = MLINE + 1
               IF CUS_PALL <> 0 .OR. SUP_PALL <> 0 .OR. FRT_PALL <> 0
                  @ MLINE,25 GET MCUS_PALL PICTURE '999999.99'
                  @ MLINE,43 GET MSUP_PALL PICTURE '999999.99'
                  @ MLINE,53 GET MFRT_PALL PICTURE '99999.99'
                  MLINE = MLINE + 1
               ENDIF
               
               IF SAL_CODE2 <> '  ' 
                  @ MLINE,62 GET MSALE2_AMT PICTURE '99999.99'
                  MLINE = MLINE + 1
               ENDIF
               IF SAL_CODE3 <> '  ' 
                  @ MLINE,62 GET MSALE3_AMT PICTURE '99999.99'
                  MLINE = MLINE + 1
               ENDIF
               IF COM_CODE <> '  '
                  @ MLINE,62 GET MCOMM_AMT PICTURE '99999.99'
                  MLINE = MLINE + 1
               ENDIF
               IF COM_CODE2 <> '  '
                  @ MLINE,62 GET MCOMM_AMT2 PICTURE '99999.99'
               ENDIF
               IF COM_CODE3 <> '  '
                  @ MLINE,62 GET MCOMM_AMT3 PICTURE '99999.99'
               ENDIF
               READ
               MTOT_NET = (MTOT_SELL + MCUS_PALL) - (MTOT_PURCH + MSUP_PALL) - MFRT - MSALE_COMM - MSALE2_AMT - MSALE3_AMT - MCOMM_AMT - MCOMM_AMT2 - MCOMM_AMT3 - MISC_AMT
               @ MCK_LINE(I),71 SAY MTOT_NET PICTURE '999999.99'
               
               STORE MCK_LINE(I) TO MLINE
               @ MLINE,25 SAY MTOT_SELL PICTURE '999999.99'
               @ MLINE,43 SAY MTOT_PURCH PICTURE '999999.99'
               @ MLINE,53 SAY MFRT PICTURE '99999.99'
               @ MLINE,62 SAY MSALE_COMM PICTURE '99999.99'
               
               MLINE = MLINE + 1
               IF CUS_PALL <> 0 .OR. SUP_PALL <> 0 .OR. FRT_PALL <> 0
                  @ MLINE,25 SAY MCUS_PALL PICTURE '@Z 999999.99'
                  @ MLINE,43 SAY MSUP_PALL PICTURE '@Z 999999.99'
                  @ MLINE,53 SAY MFRT_PALL PICTURE '@Z 99999.99'
                  MLINE = MLINE + 1
               ENDIF
               IF SAL_CODE2 <> '  ' 
                  @ MLINE,62 SAY MSALE2_AMT PICTURE '99999.99'
                  MLINE = MLINE + 1
               ENDIF
               IF SAL_CODE3 <> '  ' 
                  @ MLINE,62 SAY MSALE3_AMT PICTURE '99999.99'
                  MLINE = MLINE + 1
               ENDIF
               IF COM_CODE <> '  '
                  @ MLINE,62 SAY MCOMM_AMT PICTURE '99999.99'
                  MLINE = MLINE + 1
               ENDIF
               IF COM_CODE2 <> '  '
                  @ MLINE,62 SAY MCOMM_AMT2 PICTURE '99999.99'
                  MLINE = MLINE + 1
               ENDIF
               IF COM_CODE3 <> '  '
                  @ MLINE,62 SAY MCOMM_AMT3 PICTURE '99999.99'
                  MLINE = MLINE + 1
               ENDIF
               
               DO RECLOCK
               REPLACE TOT_SELL WITH MTOT_SELL
               REPLACE TOT_PURCH WITH MTOT_PURCH
               REPLACE FRT_AMT1 WITH FRT_AMT1 + (MFRT - (FRT_AMT1))
               REPLACE SALE_COMM WITH MSALE_COMM
               REPLACE TOT_NET WITH MTOT_NET
               REPLACE SALE2_AMT WITH MSALE2_AMT
               REPLACE SALE3_AMT WITH MSALE3_AMT
               REPLACE COMM_AMT WITH MCOMM_AMT
               REPLACE COMM_AMT2 WITH MCOMM_AMT2
               REPLACE COMM_AMT3 WITH MCOMM_AMT3
               REPLACE TOT_NET WITH MTOT_NET
               REPLACE CUS_PALL WITH MCUS_PALL
               REPLACE SUP_PALL WITH MSUP_PALL
               REPLACE FRT_PALL WITH MFRT_PALL
               UNLOCK
               
            ENDIF
         ENDIF
         @ MCK_LINE(I),0 SAY MCK(I)
         I = I + 1
      ENDDO
      
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue/Next Page     2. Edit      3. Finished'
      @ 24,9 GET MACTION PICTURE '9' range 1,3
      READ
   ENDDO
   IF MACTION = 3
      MMORE = .F.  
      LOOP
   ELSE
      IF EOF()
         MMORE = .F.
      ELSE
         @ 6,0 CLEAR TO 22,79
      ENDIF
   ENDIF
ENDDO
CLOSE DATA
RETURN
* EOF: UPDSPRD.PRG

** PROCEDURE POST ALL THE ENTRIES FOR A MONTH/YEAR -ESPECIALLY FOR MFI
PROCEDURE POSTALL
SELECT A
DO FOX_USE WITH "DAILYJRN INDEX JRN_MO, POSTED, JRN_PO", .F.
SEEK MTRAN_YR + MTRAN_MO + ' '
IF EOF()
   @ 4,1 CLEAR TO 21,78
   @ 10,5 SAY 'THERE ARE NO ENTRIES TO BE POSTED FOR THIS MONTH/YEAR'
   STORE ' ' TO MWAIT
   @ 12,5 SAY 'PRESS ENTER TO CONTINUE ' GET MWAIT
   READ
   RETURN
ENDIF

DO FILELOCK
MNEXT_REC = 99999
DO WHILE MTRAN_YR = TRAN_YR .AND. MTRAN_MO = MTRAN_MO .AND. POST_FLG = ' ' .AND. MNEXT_REC <> 0 .AND. .NOT. EOF()
   DO CASE
   CASE MENTRY = 'I'
      IF INV_COR <> 'I'
         SKIP
         LOOP
      ENDIF
   CASE MENTRY = 'C'
      IF INV_COR <> 'C'
         SKIP
         LOOP
      ENDIF
   ENDCASE
   STORE RECNO() TO MRECNO  
   SKIP         
   IF EOF()
      MNEXT_REC = 0
   ELSE
      STORE RECNO() TO MNEXT_REC
   ENDIF
   GOTO MRECNO
   ***** SUPPLIER JOURNAL
   IF A->RSUPCODE = 'INVN'
      IF MPROG_CODE = 2
         *** PUT THIS INTO THE INVENTORY ACCOUNT
         SELECT E
         DO FOX_USE WITH "INVLED INDEX INVLED", .F.
         DO FILELOCK
         APPEND BLANK
         REPLACE RSUPCODE WITH A->RSUPCODE
         REPLACE BBUYCODE WITH A->BBUYCODE
         REPLACE SALESMAN WITH A->SALESMAN
         REPLACE INV_NBR WITH A->INV_NBR
         REPLACE PO_NBR WITH A->PO_NBR
         REPLACE PO_SUFFIX WITH A->PO_SUFFIX
         REPLACE AMOUNT WITH A->TOT_PURCH + A->SUP_PALL
         REPLACE TRAN_DATE WITH A->JRNL_DATE
         REPLACE POST_DATE WITH DATE()
         REPLACE TRAN_MO WITH A->TRAN_MO
         REPLACE TRAN_YR WITH A->TRAN_YR
         REPLACE COR_FLG WITH A->INV_COR
         UNLOCK
         USE
      ENDIF
   ELSE
      IF A->RSUPCODE <> 'NONE' .AND. A->TOT_PURCH <> 0
         SELECT C
         DO FILELOCK
         APPEND BLANK
         REPLACE RSUPCODE WITH A->RSUPCODE
         REPLACE SALESMAN WITH A->SALESMAN
         REPLACE INV_NBR WITH A->INV_NBR
         REPLACE PO_NBR WITH A->PO_NBR
         REPLACE PO_SUFFIX WITH A->PO_SUFFIX
         REPLACE AMOUNT WITH A->TOT_PURCH
         REPLACE TRAN_DATE WITH A->JRNL_DATE
         REPLACE POST_DATE WITH DATE()
         REPLACE TRAN_MO WITH A->TRAN_MO
         REPLACE TRAN_YR WITH A->TRAN_YR
         REPLACE COR_FLG WITH A->INV_COR
         REPLACE SEQ WITH A->SEQ
         UNLOCK
      ENDIF
      
      IF A->RSUPCODE <> 'NONE' .AND. A->SUP_PALL <> 0
         SELECT C
         DO FILELOCK
         APPEND BLANK
         REPLACE RSUPCODE WITH A->RSUPCODE
         REPLACE SALESMAN WITH A->SALESMAN
         REPLACE INV_NBR WITH A->INV_NBR
         REPLACE PO_NBR WITH A->PO_NBR
         REPLACE PO_SUFFIX WITH A->PO_SUFFIX
         REPLACE AMOUNT WITH A->SUP_PALL  
         REPLACE TRAN_DATE WITH A->JRNL_DATE
         REPLACE POST_DATE WITH DATE()
         REPLACE TRAN_MO WITH A->TRAN_MO
         REPLACE TRAN_YR WITH A->TRAN_YR
         REPLACE PALL_FLG WITH 'Y'
         REPLACE COR_FLG WITH A->INV_COR
         REPLACE SEQ WITH A->SEQ
         UNLOCK
      ENDIF
   ENDIF
   ***** SALES JOURNAL
   IF A->BBUYCODE = 'INVN'
      IF MPROG_CODE = 2
         *** PUT THIS INTO THE INVENTORY ACCOUNT
         SELECT E
         DO FOX_USE WITH "INVLED INDEX INVLED", .F.
         DO FILELOCK
         APPEND BLANK
         REPLACE BBUYCODE WITH A->BBUYCODE
         REPLACE RSUPCODE WITH A->RSUPCODE
         REPLACE SALESMAN WITH A->SALESMAN
         REPLACE INV_NBR WITH A->INV_NBR
         REPLACE PO_NBR WITH A->PO_NBR
         REPLACE PO_SUFFIX WITH A->PO_SUFFIX
         REPLACE AMOUNT WITH A->TOT_SELL + A->CUS_PALL
         REPLACE TRAN_DATE WITH A->JRNL_DATE
         REPLACE POST_DATE WITH DATE()
         REPLACE TRAN_MO WITH A->TRAN_MO
         REPLACE TRAN_YR WITH A->TRAN_YR
         REPLACE COR_FLG WITH A->INV_COR
         UNLOCK
         USE
      ENDIF
   ELSE
      IF A->BBUYCODE <> 'NONE' .AND. A->TOT_SELL <> 0
         SELECT D
         DO FILELOCK
         APPEND BLANK
         REPLACE BBUYCODE WITH A->BBUYCODE
         REPLACE SALESMAN WITH A->SALESMAN
         REPLACE INV_NBR WITH A->INV_NBR
         REPLACE PO_NBR WITH A->PO_NBR
         REPLACE PO_SUFFIX WITH A->PO_SUFFIX
         REPLACE AMOUNT WITH A->TOT_SELL                  
         REPLACE TRAN_DATE WITH A->JRNL_DATE
         REPLACE POST_DATE WITH DATE()
         REPLACE TRAN_MO WITH A->TRAN_MO
         REPLACE TRAN_YR WITH A->TRAN_YR
         REPLACE COR_FLG WITH A->INV_COR
         REPLACE SEQ WITH A->SEQ
         UNLOCK
      ENDIF
      
      IF A->BBUYCODE <> 'NONE' .AND. A->CUS_PALL <> 0
         SELECT D
         DO FILELOCK
         APPEND BLANK
         REPLACE BBUYCODE WITH A->BBUYCODE
         REPLACE SALESMAN WITH A->SALESMAN
         REPLACE INV_NBR WITH A->INV_NBR
         REPLACE PO_NBR WITH A->PO_NBR
         REPLACE PO_SUFFIX WITH A->PO_SUFFIX
         REPLACE AMOUNT WITH A->CUS_PALL
         REPLACE TRAN_DATE WITH A->JRNL_DATE
         REPLACE POST_DATE WITH DATE()
         REPLACE TRAN_MO WITH A->TRAN_MO
         REPLACE TRAN_YR WITH A->TRAN_YR
         REPLACE COR_FLG WITH A->INV_COR
         REPLACE PALL_FLG WITH 'Y'
         REPLACE SEQ WITH A->SEQ
         UNLOCK
      ENDIF
   ENDIF
   
   *** EARNINGS LEDGER FOR MFI
   IF MPROG_CODE = 2
      IF A->SALESMAN = '25'
         SELECT E
         DO FOX_USE WITH "ERNLED INDEX ERNLED, ERNPD", .F.
         DO FILELOCK
         APPEND BLANK
         REPLACE COM_CODE WITH A->SALESMAN
         REPLACE COM_TYPE WITH 'S'
         REPLACE SALESMAN WITH A->SALESMAN 
         REPLACE INV_NBR WITH A->INV_NBR
         REPLACE PO_NBR WITH A->PO_NBR
         REPLACE PO_SUFFIX WITH A->PO_SUFFIX
         REPLACE RSUPCODE WITH A->RSUPCODE
         REPLACE BBUYCODE WITH A->BBUYCODE
         REPLACE AMOUNT WITH A->TOT_NET
         REPLACE TRAN_DATE WITH A->JRNL_DATE
         REPLACE POST_DATE WITH DATE()
         REPLACE TRAN_MO WITH A->TRAN_MO
         REPLACE TRAN_YR WITH A->TRAN_YR
         REPLACE COR_FLG WITH A->INV_COR
         REPLACE TOT_LBS WITH A->TOT_LBS
         UNLOCK
      ENDIF
   ENDIF
   
   ***** FREIGHT JOURNAL
   SELECT E
   DO FOX_USE WITH "FRTJRN INDEX FRTJRN", .F.
   IF A->FRT_CODE1 <> 'NONE' .AND. A->FRT_AMT1 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE FRT_CODE WITH A->FRT_CODE1
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->FRT_AMT1
      REPLACE TRAN_DATE WITH A->JRNL_DATE
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH A->TRAN_MO
      REPLACE TRAN_YR WITH A->TRAN_YR
      REPLACE COR_FLG WITH A->INV_COR
      REPLACE SEQ WITH A->SEQ
      UNLOCK
   ENDIF
   IF A->FRT_CODE1 <> 'NONE' .AND. A->FRT_PALL <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE FRT_CODE WITH A->FRT_CODE1
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->FRT_PALL
      REPLACE TRAN_DATE WITH A->JRNL_DATE
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH A->TRAN_MO
      REPLACE TRAN_YR WITH A->TRAN_YR
      REPLACE PALL_FLG WITH 'Y'
      REPLACE COR_FLG WITH A->INV_COR
      REPLACE SEQ WITH A->SEQ
      UNLOCK
   ENDIF
   *** ADDED 11/2003
   ***IF MPROG_CODE = 2
   IF A->FRT_CODE2 <> 'NONE' .AND. A->FRT_CODE2 <> SPACE(4) .AND. A->FRT_AMT2 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE FRT_CODE WITH A->FRT_CODE2
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->FRT_AMT2
      REPLACE TRAN_DATE WITH A->JRNL_DATE
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH A->TRAN_MO
      REPLACE TRAN_YR WITH A->TRAN_YR
      REPLACE COR_FLG WITH A->INV_COR
      REPLACE SEQ WITH A->SEQ
      UNLOCK
   ENDIF
   IF A->FRT_CODE3 <> 'NONE' .AND. A->FRT_CODE3 <> SPACE(4) .AND. A->FRT_AMT3 <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE FRT_CODE WITH A->FRT_CODE3
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->FRT_AMT3
      REPLACE TRAN_DATE WITH A->JRNL_DATE
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH A->TRAN_MO
      REPLACE TRAN_YR WITH A->TRAN_YR
      REPLACE COR_FLG WITH A->INV_COR
      REPLACE SEQ WITH A->SEQ
      UNLOCK
   ENDIF
   ***ENDIF
   
   ***** UPDATE COMMISSIONS/THIRD PARTY COMMISSIONS JOURNAL
   SELECT E
   DO FOX_USE WITH "COMJRN INDEX COMJRN", .F.
   IF A->SALESMAN <> '  ' .AND. A->SALE_COMM <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE COM_CODE WITH A->SALESMAN
      REPLACE COM_TYPE WITH 'S'
      REPLACE SALESMAN WITH A->SALESMAN 
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->SALE_COMM
      REPLACE TRAN_DATE WITH A->JRNL_DATE
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH A->TRAN_MO
      REPLACE TRAN_YR WITH A->TRAN_YR
      REPLACE COR_FLG WITH A->INV_COR
      REPLACE SEQ WITH A->SEQ
      IF MCOMPANY = 'DIVISION 15'
         REPLACE TOT_LBS WITH A->TOT_LBS
      ENDIF
      UNLOCK
   ENDIF
   
   IF A->SAL_CODE2 <> '  ' .AND. A->SALE2_AMT <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE COM_CODE WITH A->SAL_CODE2
      **RON MONTGOMERY CHANGES
      REPLACE COM_TYPE WITH 'T'
      REPLACE SALESMAN WITH A->SALESMAN 
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->SALE2_AMT
      REPLACE TRAN_DATE WITH A->JRNL_DATE
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH A->TRAN_MO
      REPLACE TRAN_YR WITH A->TRAN_YR
      REPLACE COR_FLG WITH A->INV_COR
      REPLACE SEQ WITH A->SEQ
      IF MCOMPANY = 'DIVISION 15'
         REPLACE TOT_LBS WITH A->TOT_LBS
      ENDIF
      UNLOCK
   ENDIF
   
   IF A->SAL_CODE3 <> '  ' .AND. A->SALE3_AMT <> 0
      DO FILELOCK
      APPEND BLANK
      REPLACE COM_CODE WITH A->SAL_CODE3
      REPLACE COM_TYPE WITH 'S'
      REPLACE SALESMAN WITH A->SALESMAN 
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->SALE3_AMT
      REPLACE TRAN_DATE WITH A->JRNL_DATE
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH A->TRAN_MO
      REPLACE TRAN_YR WITH A->TRAN_YR
      REPLACE COR_FLG WITH A->INV_COR
      REPLACE SEQ WITH A->SEQ
      IF MCOMPANY = 'DIVISION 15'
         REPLACE TOT_LBS WITH A->TOT_LBS
      ENDIF
      UNLOCK
   ENDIF
   
   **HERE
   IF A->COM_CODE <> '  ' .AND. A->COMM_AMT <> 0
      IF DTOC(A->TRAN_DATE) = '01/01/2007'
         SELECT E
         DO FOX_USE WITH "COMJRN INDEX COMJRN", .F.
      ELSE
         SELECT F
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         SEEK A->COM_CODE
         IF BILL_BACK = 'Y'
            SELECT E
            DO FOX_USE WITH "BBKJRN INDEX BBKJRN", .F.
         ELSE
            SELECT E
            DO FOX_USE WITH "COMJRN INDEX COMJRN", .F.
         ENDIF
         SELECT F
         USE
      ENDIF
      SELECT E
      
      DO FILELOCK
      APPEND BLANK
      REPLACE COM_CODE WITH A->COM_CODE 
      REPLACE COM_TYPE WITH 'T'
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->COMM_AMT 
      REPLACE TRAN_DATE WITH A->JRNL_DATE
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH A->TRAN_MO
      REPLACE TRAN_YR WITH A->TRAN_YR
      REPLACE COR_FLG WITH A->INV_COR
      REPLACE SEQ WITH A->SEQ
      IF MCOMPANY = 'DIVISION 15'
         REPLACE TOT_LBS WITH A->TOT_LBS
      ENDIF
      UNLOCK
   ENDIF
   
   IF A->COM_CODE2 <> '  ' .AND. A->COMM_AMT2 <> 0
      IF DTOC(A->TRAN_DATE) = '01/01/2007'
         SELECT E
         DO FOX_USE WITH "BBKJRN INDEX BBKJRN", .F.
      ELSE
         SELECT F
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         SEEK A->COM_CODE2
         IF BILL_BACK = 'Y'
            SELECT E
            DO FOX_USE WITH "BBKJRN INDEX BBKJRN", .F.
         ELSE
            SELECT E
            DO FOX_USE WITH "COMJRN INDEX COMJRN", .F.
         ENDIF
         SELECT F
         USE
      ENDIF
      SELECT E
      DO FILELOCK
      APPEND BLANK
      REPLACE COM_CODE WITH A->COM_CODE2 
      REPLACE COM_TYPE WITH 'T'
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->COMM_AMT2 
      REPLACE TRAN_DATE WITH A->JRNL_DATE
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH A->TRAN_MO
      REPLACE TRAN_YR WITH A->TRAN_YR
      REPLACE COR_FLG WITH A->INV_COR
      REPLACE SEQ WITH A->SEQ
      IF MCOMPANY = 'DIVISION 15'
         REPLACE TOT_LBS WITH A->TOT_LBS
      ENDIF
      UNLOCK
   ENDIF
   
   IF A->COM_CODE3 <> '  ' .AND. A->COMM_AMT3 <> 0
      SELECT F
      DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
      SEEK A->COM_CODE3
      IF BILL_BACK = 'Y'
         SELECT E
         DO FOX_USE WITH "BBKJRN INDEX BBKJRN", .F.
      ELSE
         SELECT E
         DO FOX_USE WITH "COMJRN INDEX COMJRN", .F.
      ENDIF
      SELECT F
      USE
      SELECT E
      DO FILELOCK
      APPEND BLANK
      REPLACE COM_CODE WITH A->COM_CODE3 
      REPLACE COM_TYPE WITH 'T'
      REPLACE SALESMAN WITH A->SALESMAN
      REPLACE INV_NBR WITH A->INV_NBR
      REPLACE PO_NBR WITH A->PO_NBR
      REPLACE PO_SUFFIX WITH A->PO_SUFFIX
      REPLACE AMOUNT WITH A->COMM_AMT3 
      REPLACE TRAN_DATE WITH A->JRNL_DATE
      REPLACE POST_DATE WITH DATE()
      REPLACE TRAN_MO WITH A->TRAN_MO
      REPLACE TRAN_YR WITH A->TRAN_YR
      REPLACE COR_FLG WITH A->INV_COR
      REPLACE SEQ WITH A->SEQ
      IF MCOMPANY = 'DIVISION 15'
         REPLACE TOT_LBS WITH A->TOT_LBS
      ENDIF
      UNLOCK
   ENDIF
   
   IF A->INV_COR = 'I'
      SELECT E
      DO FOX_USE WITH "SS INDEX SS_YRMO", .F.
      SEEK A->TRAN_YR + A->TRAN_MO + A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
      IF .NOT. EOF()
         DO RECLOCK
         REPLACE POST_FLG WITH 'P'
         UNLOCK
      ENDIF
   ENDIF
   
   SELECT A
   REPLACE POST_FLG WITH 'P'
   IF MNEXT_REC <> 0
      GOTO MNEXT_REC
   ENDIF
ENDDO

FLUSH
UNLOCK
RETURN
* EOF: POSTALL.PRG
*** EOF:  ACCTPROC
*Formatted by: ToolBox Ver. 1.2  on 11/30/15 at 11:42 AM.
