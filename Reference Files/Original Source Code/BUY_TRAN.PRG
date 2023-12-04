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
      *** SEE IF I GET A HIT ON THE CITY/STATE 
      MGO_ON = .T.
      *DO WHILE .NOT. EOF() .AND. NAME = SRCH_ARG .AND. MGO_ON
      *   IF CITY = TRIM(MBBUYCITY) .AND. STATE = MBBUYST
      *      MGO_ON = .F.
      *      LOOP
      *   ENDIF
      *   SKIP
      *ENDDO
      
      IF MGO_ON
         GOTO MFST_REC 
         SAVE SCREEN TO MPO_GRACE
         DO MUL1BUY
         IF MACTION <> 5
            MNAME_FD = .T.
         ENDIF
         RESTORE SCREEN FROM MPO_GRACE
      ELSE
         MNAME_FD = .T.
      ENDIF
      RETURN
   ELSE
      GOTO MFST_REC
      MNAME_FD = .T.
      RETURN
   ENDIF
ENDIF
RETURN
* EOF: BUY_SEL2.PRG
*Formatted by: ToolBox Ver. 1.2  on 6/27/97 at 8:05 AM.
