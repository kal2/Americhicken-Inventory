*************
* Program.: FRT_UPD.PRG
* Author..: Grace Keller
* Date....: 10/28/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: FREIGHT CARRIER EDIT/DELETE
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_PP = .T.  
MTITLE = ' - VIEW/CHANGE/DELETE FREIGHT CARRIER INFORMATION' 
**** PUT UP THE SCREEN
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


DO TEXTFRT
DO STORFRT
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   DO GETFRT1
   STORE 1 TO MACTION
   @ 23,0 CLEAR
   @ 23,01 SAY 'Action: ' + STR(MACTION,1)
   @ 23,13 SAY '1.Save/Return    2.Edit Screen    3.Delete Carrier   4.Cancel'
   @ 24,13 say '5.Insurance Pg   6.Print Ins. Letter'
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
   CASE MACTION = 4
      MNOT_DONE = .F.
      LOOP
      
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 1 .OR. MACTION = 5 .OR. MACTION = 6
      DO REPLFRT1
      IF MACTION = 5
         DO FRT_UPD2
      ENDIF
      IF MACTION = 6
         DO FRT_LET
      ENDIF
      MNOT_DONE = .F.
      
   CASE MACTION = 3
      SELECT E
      DO FOX_USE WITH "PO_HEAD INDEX TMP_FRT", .F.
      SEEK A->FRT_CODE
      IF .NOT. EOF()
         @ 23,0 CLEAR
         STORE ' ' TO MYES_NO
         STORE 'CANNOT DELETE THIS FREIGHT CARRIER - PO(s) ON FILE ! ' TO MWAIT
         @ 23,1 SAY MWAIT
         CLEAR GETS    
         @ 23,59 GET MYES_NO PICTURE '@!'
         READ
         @ 23,0 CLEAR
         USE
         SELECT A
      ELSE
         USE
         SELECT A
         @ 23,0 CLEAR
         STORE 'N' TO MYES_NO
         STORE 'Are You Sure You Want to DELETE this Carrier (Y/N)? ' TO MWAIT
         @ 24,10 SAY MWAIT
         CLEAR GETS    
         @ 24,65 GET MYES_NO PICTURE '@!'
         READ
         IF MYES_NO = 'Y'
            DO RECLOCK
            DELETE
            UNLOCK
         ENDIF 
      ENDIF
      MNOT_DONE = .F.
   ENDCASE
   
ENDDO
RETURN
* EOF: FRT_UPD.PRG
*Formatted by: ToolBox Ver. 1.2  on 7/7/93 at 2:33 PM.
