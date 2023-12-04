******************
* Program.: COM_SEL2.PRG
* Author..: Grace Keller
* Date....: 10/11/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: FREIGHT CARRIER SELECT 
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MCOM_FD = .F.
***STORE TRIM(MCOM_NAME) TO SRCH_ARG
SEEK SRCH_ARG
IF EOF() .OR. DELETED()
   @ 23,0 CLEAR
   STORE ' ' TO MSPACE 
   @ 24,10 SAY '3RD PARTY COMMISSION NAME NOT FOUND - PRESS RETURN TO REENTER'
   @ 24,51 GET MSPACE
   READ
   @ 24,1 CLEAR
ELSE               
   STORE RECNO() TO MFST_REC
   SKIP
   IF NAME = SRCH_ARG
      MADD = .F.
      SAVE SCREEN TO MCOM_SCRN
      DO MULTCOM
      RESTORE SCREEN FROM MCOM_SCRN
      IF MACTION <> 5
         MCOM_FD = .T.
      ENDIF
   ELSE
      GOTO MFST_REC
      MCOM_FD = .T.
   ENDIF
ENDIF

RETURN
* EOF: COM_SEL2.PRG


*Formatted by: dANALYST Ver. 7.3a on December 3, 1987 at 6:01 PM.
