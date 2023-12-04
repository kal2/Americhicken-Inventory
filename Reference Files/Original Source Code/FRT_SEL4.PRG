******************
* Program.: FRT_SEL4.PRG
* Author..: Grace Keller
* Date....: 02/21/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: Freight SELECT  - NO OPTION TO ADD
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
   @ 24,10 SAY 'FREIGHT CARRIER NOT FOUND ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MYES_NO 
   READ
ELSE               
   STORE RECNO() TO MFST_REC
   SKIP
   IF NAME = SRCH_ARG
      MADD = .F.
      SAVE SCREEN TO MPO_GRACE
      DO MUL1FRT 
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
* EOF: FRT_SEL4.PRG


*Formatted by: dANALYST Ver. 7.3a on November 23, 1987 at 3:38 PM.
