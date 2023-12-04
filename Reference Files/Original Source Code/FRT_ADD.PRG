*************
* Program.: FRT_ADD.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: FREIGHT CARRIER ADD
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_FRT = .T.  
MTITLE = ' - ADD FREIGHT CARRIER INFORMATION' 
MFAX_AREA   = SPACE(3)
MFAX_PHONE  = SPACE(7)
MPAY_FAREA   = SPACE(3)
MPAY_FPHON  = SPACE(7)
MACTIVE     = SPACE(1)
MNOTE       = SPACE(65)
MCANCEL     = 0        
MFRT_CONT   = SPACE(32)
MINS_CO1    = SPACE(32)
MINS_CO2    = SPACE(32)
MINS_CO3    = SPACE(32)
MINS_CO4    = SPACE(32)
MINS_CO5    = SPACE(32)

MINS_TP1    = SPACE(1)
MINS_TP2    = SPACE(1)
MINS_TP3    = SPACE(1)
MINS_TP4    = SPACE(1)
MINS_TP5    = SPACE(1)

MPOLICY1    = SPACE(20)
MPOLICY2    = SPACE(20)
MPOLICY3    = SPACE(20)
MPOLICY4    = SPACE(20)
MPOLICY5    = SPACE(20)

MAUTO_COV1  = 0 
MAUTO_COV2  = 0 
MAUTO_COV3  = 0 
MAUTO_COV4  = 0 

MCARG_COV1  = 0
MCARG_COV2  = 0
MCARG_COV3  = 0
MCARG_COV4  = 0

MWORK_COV1  = 0
MWORK_COV2  = 0
MWORK_COV3  = 0

MGEN_COV1   = 0
MGEN_COV2   = 0
MGEN_COV3   = 0
MGEN_COV4   = 0
MGEN_COV5   = 0
MGEN_COV6   = 0

MAUTO_BEG   = CTOD(' ')
MCARGO_BEG  = CTOD(' ')
MGEN_BEG    = CTOD(' ')
MWORK_BEG   = CTOD(' ')

MAUTO_END   = CTOD(' ')
MCARGO_END  = CTOD(' ')
MGEN_END    = CTOD(' ')
MWORK_END   = CTOD(' ')

MAUTO_LET   = CTOD(' ')
MCARGO_LET  = CTOD(' ')
MGEN_LET    = CTOD(' ')
MWORK_LET   = CTOD(' ')
MPHY_BEG    = CTOD(' ')
MPHY_END    = CTOD(' ')
MPHY_COV1   = 0
MPHY_COV2   = 0


**** PUT UP THE SCREEN
DO TEXTFRT
DO WHILE MMORE_FRT
   IF MINIT_NM
      MNAME       = SPACE(32)
   ENDIF
   MSTREET     = SPACE(28)
   MCITY       = SPACE(20)
   MSTATE      = SPACE(2)
   MZIP        = SPACE(5)
   MZIP4       = SPACE(4)
   MFRT_CODE   = SPACE(4)
   MAREA_CODE  = SPACE(3)
   MPHONE      = SPACE(7)
   MPAY_NAME   = SPACE(32)
   MPAY_STRT   = SPACE(28)
   MPAY_CITY   = SPACE(20)
   MPAY_STATE  = SPACE(2)
   MPAY_ZIP    = SPACE(5)
   MPAY_ZIP4   = SPACE(4)
   MPAY_AREA   = SPACE(3)
   MPAY_PHONE  = SPACE(7)
   MFRT_CONT   = SPACE(32)
   MNOT_DONE = .T.
   DO WHILE MNOT_DONE
      DO GETFRT1
      STORE 1 TO MACTION
      @ 23,0 CLEAR
      @ 23,01 SAY 'Action: ' + STR(MACTION,1)
      @ 23,13 SAY '1. Save/Return    2. Edit Screen         3.Cancel'
      @ 24,13 say '5. Insurance Pg   6. Print Ins. Letter'
      READ
      IF MPAY_NAME = 'SAME'
         STORE MNAME TO MPAY_NAME
         STORE MSTREET TO MPAY_STRT 
         STORE MCITY   TO MPAY_CITY
         STORE MSTATE  TO MPAY_STATE
         STORE MZIP    TO MPAY_ZIP
         STORE MZIP4   TO MPAY_ZIP4
         STORE MAREA_CODE TO MPAY_AREA
         STORE MPHONE     TO MPAY_PHONE
         STORE MFAX_AREA  TO MPAY_FAREA
         STORE MFAX_PHONE TO MPAY_FPHON
         DO SAYPAY 
      ENDIF
      DO GETFRT2
      READ
      IF MINS_CO1 <> ' ' .OR. MINS_CO2 <> ' ' .OR. MINS_CO3 <> ' ' .OR. MINS_CO4 <> ' '
         MACTION = 5
      ENDIF
      @23,09 GET MACTION PICTURE '9' RANGE 1,6
      READ               
      DO CASE
      CASE MACTION = 3
         MNOT_DONE = .F.
         MMORE_FRT = .F.
         LOOP
         
      CASE MACTION = 2
         LOOP
         
      CASE MACTION = 1 .OR. MACTION = 5 .OR. MACTION = 6
         IF MNAME = SPACE(32)    
            MNOT_DONE = .F.
            MMORE_FRT = .F.
            LOOP
         ENDIF
         SEEK MNAME
         IF .NOT. EOF()
            @ 23,0 CLEAR
            STORE 'N' TO MYES_NO 
            @ 24,1 SAY 'NAME ALREADY ON FILE - DO YOU WANT TO CONTINUE WITH THIS ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'Y'
               MINIT_NM = .T.
               DO INITFRT
               LOOP
            ENDIF
         ENDIF
         IF MMASTDBF <> MDBFLOC
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.CONTROL", .F.
         ELSE
            SELECT A
            DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
         ENDIF
         STORE STR(FRT_CODE+1,4) TO MFRT_CODE
         DO RECLOCK
         REPLACE FRT_CODE WITH FRT_CODE + 1
         UNLOCK
         USE
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME, &MDBFLOC.FRT_CODE", .F.
         DO FILELOCK
         APPEND BLANK
         UNLOCK
         DO REPLFRT1
         DO CASE
         CASE MACTION = 5
            DO FRT_UPD2
         CASE MACTION = 6
            DO FRT_LET
         ENDCASE
         MINIT_NM = .T.
         MADD = .T.
         MMORE_FRT = .F.
         MNOT_DONE = .F.
      ENDCASE
   ENDDO
ENDDO
RETURN
* EOF: FRT_ADD.PRG


*Formatted by: ToolBox Ver. 1.2  on 6/4/90 at 10:05 AM.
