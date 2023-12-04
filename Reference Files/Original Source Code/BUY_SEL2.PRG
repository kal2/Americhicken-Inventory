******************
* Program.: BUY_SEL2.PRG
* Author..: Grace Keller
* Date....: 10/11/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PO SHIP TO BUYER  SELECT 
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
      DO BUY_ADD
      IF MACTION <> 4
         MNAME_FD = .T.
      ENDIF
   ENDIF
   RETURN
ELSE               
   STORE RECNO() TO MFST_REC
   SKIP
   IF NAME = SRCH_ARG
      MADD = .F.
      SAVE SCREEN TO MPO_GRACE
      DO MUL1BUY
      IF MACTION <> 5
         MNAME_FD = .T.
      ENDIF
      RESTORE SCREEN FROM MPO_GRACE
      RETURN
   ELSE
      GOTO MFST_REC
      MNAME_FD = .T.
      RETURN
   ENDIF
ENDIF


RETURN
* EOF: BUY_SEL2.PRG


*Formatted by: dANALYST Ver. 7.3a on November 23, 1987 at 4:15 PM.
