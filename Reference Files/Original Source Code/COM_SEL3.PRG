******************
* Program.: COM_SEL3.PRG
* Author..: Grace Keller
* Date....: 10/11/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: FREIGHT CARRIER SELECT 
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MNAME_FD = .F.
IF MNAME = SPACE(32)
   MNAME_FD = .T.
   RETURN
ENDIF
STORE TRIM(MNAME) TO SRCH_ARG
SEEK SRCH_ARG
IF EOF() .OR. DELETED()
   @ 23,0 CLEAR
   STORE ' ' TO MSPACE 
   @ 24,10 SAY 'PAYEE NAME NOT FOUND - PRESS RETURN TO REENTER'
   @ 24,70 GET MSPACE
   READ
@ 24,0 CLEAR
   RETURN
ELSE               
   STORE RECNO() TO MFST_REC
   SKIP
   IF NAME = SRCH_ARG
      MADD = .F.
      SAVE SCREEN TO MGRACE
      DO MULTCOM
      RESTORE SCREEN FROM MGRACE
      IF MACTION <> 5
         MNAME_FD = .T.
      ENDIF
   ELSE
      GOTO MFST_REC
      MNAME_FD = .T.
   ENDIF
ENDIF
   
   RETURN
   * EOF: COM_SEL3.PRG
   
   
*Formatted by: dANALYST Ver. 7.3a on November 18, 1987 at 2:05 PM.
