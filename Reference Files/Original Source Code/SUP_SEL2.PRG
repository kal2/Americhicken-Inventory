******************
* Program.: SUP_SEL2.PRG
* Author..: Grace Keller
* Date....: 10/11/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PO SUPPLIER SELECT 
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MNAME_FD = .F.
STORE 1 TO MACTION
STORE TRIM(MNAME) TO SRCH_ARG
SEEK SRCH_ARG
IF EOF() .OR. DELETED()
   @ 24,0 CLEAR
   STORE ' ' TO MSPACE 
   MYES_NO = 'N'
   @ 24,10 SAY 'NAME NOT FOUND ON FILE - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO picture '@!'
   READ
   IF MYES_NO = 'Y'
      MINIT_NM = .F.
      DO SUP_ADD
      IF MACTION <> 4
         MNAME_FD = .T.
      ENDIF
   ENDIF
ELSE               
   STORE RECNO() TO MFST_REC
   SKIP
   IF NAME = SRCH_ARG
      MADD = .F.
      DO MUL1SUP
      IF MACTION <> 5
         MNAME_FD = .T.
      ENDIF
   ELSE
      GOTO MFST_REC
      MNAME_FD = .T.
   ENDIF
ENDIF

RETURN
* EOF: SUP_SEL2.PRG


*Formatted by: dANALYST Ver. 7.3a on November 30, 1987 at 10:55 AM.
