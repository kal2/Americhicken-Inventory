******************
* Program.: RSUPSEL2.PRG
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
   @ 24,10 SAY 'REMIT TO NAME NOT FOUND ON FILE - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
   READ
   IF MYES_NO = 'Y'
      SAVE SCREEN TO MPO_GRACE
      MINIT_NM = .F.
      DO RSUP_ADD
      RESTORE SCREEN FROM MPO_GRACE
      IF MACTION <> 4
         MNAME_FD = .T.
      ENDIF
      RETURN
   ENDIF
ELSE               
   STORE RECNO() TO MFST_REC
   SKIP
   IF NAME = SRCH_ARG
      MADD = .F.
      SAVE SCREEN TO MPO_GRACE
      DO MUL1RSUP
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
* EOF: RSUPSEL2.PRG
