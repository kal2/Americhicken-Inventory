******************
* Program.: RSUP_SEL.PRG
* Author..: Grace Keller
* Date....: 10/12/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SUPPLIER SELECT
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
PROCEDURE RSUP_SEL 
SELECT A
DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME, &MDBFLOC.RSUPCODE", .F.
STORE SPACE(32) TO MINS_CO1, MINS_CO2, MINS_CO3, MINS_CO4, MINS_CO5
STORE SPACE(1) TO MINDEM_FLG
STORE CTOD('') TO MINDEM_DT
STORE SPACE(32)    TO MNAME
MNAME_FD = .F.
STORE 1 TO MACTION
MSUP_SEL = .T.
DO WHILE MSUP_SEL
   
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - SELECT REMIT TO SUPPLIER'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   @  5, 5 SAY 'Enter Search Field:'
   @  8, 5 SAY 'Name'
   @ 10, 5 GET Mname PICTURE '@!'
   
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      
      IF MNAME <> SPACE(32)
         STORE TRIM(MNAME) TO SRCH_ARG
         SEEK SRCH_ARG
         IF EOF() .OR. DELETED()
            @ 23,0 CLEAR
            STORE 'Y' TO MYES_NO
            @ 24,05 SAY 'NAME NOT FOUND - DO YOU WANT TO ADD (Y/N)? ' get MYES_NO PICTURE '@!'
            READ
            IF MYES_NO = 'Y'
               MINIT_NM = .F.
               DO RSUP_ADD
               STORE SPACE(32) TO MNAME
            ELSE 
               STORE SPACE(32) TO MNAME
            ENDIF
            LOOP
         ELSE               
            STORE RECNO() TO MFST_REC
            MADD = .F.
            DO MUL1RSUP 
            IF MACTION = 5
               LOOP
            ENDIF
            IF MADD
               MNAME = SPACE(32)
               LOOP
            ENDIF
            DO RSUPEDIT
            MNAME = SPACE(32)
            LOOP
         ENDIF
      ENDIF     
      
      MSUP_SEL = .F.
      LOOP
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 3
      MSUP_SEL = .F.
      
   ENDCASE
ENDDO
RETURN

PROCEDURE TEXTSUPP
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 24,79
@ 5,11  SAY 'SUPPLIER NAME:'
@ 7,12 SAY 'PHONE NUMBER:'
@ 7,45 SAY 'FAX NUMBER:'
@ 9,10 SAY '  CONTACT NAME:'
@ 10,10 SAY ' CONTACT PHONE:' 
@ 10,44 SAY 'CONTACT FAX:'
@ 12,10 SAY 'FRT CONT PHONE:'
@ 13,10 SAY 'FRT CONT EMAIL:'

@ 15,02 SAY '   SHIP FROM-->'
@ 16,02 SAY '     ADDRESS-->'
@ 15,18 SAY 'STREET:'
@ 16,20 SAY 'CITY:'
@ 16,50 SAY 'STATE:'
@ 16,62 SAY 'ZIP:'
@ 16,72 SAY '-'
@ 18,3 SAY '   NOTE:'

@ 19,1 say '   PRINCIPAL REMIT TO NAME             OPTIONAL-FRT CONFIRMATION PU NAME'
RETURN


PROCEDURE INITSUPP
IF MINIT_NM
   mname       = SPACE(32)
ENDIF
mstreet     = SPACE(28)
mcity       = SPACE(20)
mstate      = SPACE(2)
mzip        = SPACE(5)
mzip4       = SPACE(4)
mnote       = SPACE(60)
MSUP_CODE   = SPACE(4)
MAREA_CODE   = SPACE(3)
MPHONE       = SPACE(7)
MFAX         = SPACE(10)
MCONT_FAX    = SPACE(10)
MCONT_NAME   = SPACE(32)
MCONT_PH     = SPACE(10)
MREM_NAME    = SPACE(32)
MCONF_NAME   = SPACE(32)
MRSUPCODE    = SPACE(4)
MFRT_PH      = SPACE(10)
MFRT_EMAIL   = SPACE(50)
MPU_CODE   = SPACE(4)
RETURN


PROCEDURE GETSUPP
@ 05,26 GET mname PICTURE '@!'
@ 07,26 GET MAREA_CODE PICTURE '###'
@ 07,29 GET MPHONE PICTURE '@R -###-####'
@ 07,57 GET MFAX PICTURE '@R ###-###-####'
@ 09,26 GET MCONT_NAME PICTURE '@!'
@ 10,26 GET MCONT_PH PICTURE '@R ###-###-####'
@ 10,57 GET MCONT_FAX PICTURE '@R ###-###-####'
@ 12,26 GET MFRT_PH PICTURE '@R ###-###-####'
@ 13,26 GET MFRT_EMAIL

@ 15,26 GET mstreet PICTURE '@!'
@ 16,26 GET mcity PICTURE '@!'
@ 16,57 GET mstate PICTURE '@!'
@ 16,67 GET mzip PICTURE '#####'
@ 16,73 GET mzip4 PICTURE '####'
@ 18,12 GET mnote PICTURE '@!'
@ 20,4  GET MREM_NAME PICTURE '@!'
@ 20,40 GET MCONF_NAME PICTURE '@!'
RETURN

PROCEDURE STORSUPP
STORE name       TO mname      
STORE street     TO mstreet    
STORE city       TO mcity      
STORE state      TO mstate     
STORE zip        TO mzip       
STORE zip4       TO mzip4      
STORE note       TO mnote      
STORE SUP_CODE   TO MSUP_CODE
STORE AREA_CODE  TO MAREA_CODE
STORE PHONE      TO MPHONE
STORE FAX        TO MFAX
STORE CONT_FAX   TO MCONT_FAX
STORE CONT_NAME  TO MCONT_NAME
STORE CONT_PH    TO MCONT_PH
STORE RSUPCODE   TO MRSUPCODE
STORE PU_CODE    TO MPU_CODE
STORE FRT_PH     TO MFRT_PH
STORE FRT_EMAIL  TO MFRT_EMAIL
RETURN

PROCEDURE REPLSUPP
IF NAME <> MNAME .OR. SUP_CODE <> MSUP_CODE
   DO FILELOCK
   REPLACE name       WITH mname      
   REPLACE sup_CODE   WITH Msup_CODE
ELSE
   DO RECLOCK
ENDIF
REPLACE street     WITH mstreet    
REPLACE city       WITH mcity      
REPLACE state      WITH mstate     
REPLACE zip        WITH mzip       
REPLACE zip4       WITH mzip4      
REPLACE note       WITH mnote      
REPLACE AREA_CODE  WITH MAREA_CODE
REPLACE PHONE      WITH MPHONE
REPLACE FAX        WITH MFAX
REPLACE CONT_FAX   WITH MCONT_FAX
REPLACE CONT_NAME  WITH MCONT_NAME
REPLACE CONT_PH    WITH MCONT_PH
REPLACE RSUPCODE   WITH MRSUPCODE
REPLACE PU_CODE  WITH MPU_CODE
REPLACE FRT_PH     WITH MFRT_PH
REPLACE FRT_EMAIL  WITH MFRT_EMAIL
UNLOCK
RETURN

PROCEDURE PUBLSUPP
PUBLIC mname, mstreet, mcity, mstate, mzip
PUBLIC MZIP4, MSUP_CODE, MREM_NAME
PUBLIC MPHONE, MAREA_CODE, MRSUPCODE
PUBLIC MFAX, MNOTE
RETURN


***** REMIT TO SUPPLIER INFO

PROCEDURE TEXTRSUP
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 24,79
@ 4,07  SAY 'SUPPLIER REMIT TO:'
@ 6,12 SAY 'PHONE NUMBER:                   FAX NUMBER:'
@ 8,1 SAY '   REMIT         STREET:'
@ 9,1 SAY '  ADDRESS          CITY:                        STATE:      ZIP:      -'
@ 11,2 SAY '      PAYMENT NET DAYS:           INDEMNITY CONTRACT (Y/N):'
@ 12,2 SAY ' ACTIVE/INACTIVE (A/I):                      CONTRACT DATE:'
@ 13,2 SAY "MIDWEST'S CREDIT LIMIT:"
@ 14,2 SAY '  LETTER OF CREDIT AMT:           DATE BEGIN:              EXPIRE:'
@ 15,2 SAY '             GUARANTOR:'
@ 16,3 SAY '   NOTE:'
@ 17,1 TO 17,7
@ 17,71 TO 17,78
@ 17,08 SAY " I N S U R A N C E   C O V E R A G E   I N F O R M A T I O N"
@ 18,1 SAY ' A. Insurance Co:'
@ 19,1 SAY ' B. Insurance Co:'
@ 20,1 SAY ' C. Insurance Co:'
@ 21,1 SAY ' C. Insurance Co:'
@ 22,1 SAY ' C. Insurance Co:'
RETURN

PROCEDURE GETRSUP
@ 04,26 GET mname PICTURE '@!'
@ 06,26 GET MAREA_CODE PICTURE '###'
@ 06,29 GET MPHONE PICTURE '@R -###-####'
@ 06,56 GET MFAX PICTURE '@R ###-###-####'
@ 08,26 GET mstreet PICTURE '@!'
@ 09,26 GET mcity PICTURE '@!'
@ 09,56 GET mstate PICTURE '@!'
@ 09,66 GET mzip PICTURE '#####'
@ 09,72 GET mzip4 PICTURE '####'
@ 11,26 GET MNET_DAYS  PICTURE '###'
@ 12,26 GET MACTIVE PICTURE '@!'
@ 11,63 GET MINDEM_FLG PICTURE '@!'
@ 12,63 GET MINDEM_DT
@ 13,26 GET mcred_lim   PICTURE '#######'
@ 14,26 GET MLET_CRD PICTURE '#######'
@ 14,48 GET MBEG_DATE
@ 14,69 GET MEND_DATE
@ 15,26 GET MGUARAN PICTURE '@!'
@ 16,12 GET mnote PICTURE '@!'
@ 18,19 GET MINS_CO1 PICTURE '@!'
@ 19,19 GET MINS_CO2 PICTURE '@!'
@ 20,19 GET MINS_CO3 PICTURE '@!'
@ 21,19 GET MINS_CO4 PICTURE '@!'
@ 22,19 GET MINS_CO5 PICTURE '@!'
RETURN

PROCEDURE INITRSUP
IF MINIT_NM
   mname       = SPACE(32)
ENDIF
mstreet     = SPACE(28)
mcity       = SPACE(20)
mstate      = SPACE(2)
mzip        = SPACE(5)
mzip4       = SPACE(4)
mcred_lim   = 0
mnote       = SPACE(60)
MRSUPCODE   = SPACE(4)
MAREA_CODE   = SPACE(3)
MPHONE       = SPACE(7)
MFAX         = SPACE(10)
MNET_DAYS    = 14
MBEG_DATE    = CTOD(' ')
MEND_DATE    = CTOD(' ')
MLET_CRD     = 0
MGUARAN      = SPACE(20)
MACTIVE      = 'A'
MINDEM_FLG   = ' '
MINDEM_DT    = CTOD('')
RETURN




PROCEDURE STORRSUP 
STORE name       TO mname      
STORE street     TO mstreet    
STORE city       TO mcity      
STORE state      TO mstate     
STORE zip        TO mzip       
STORE zip4       TO mzip4      
STORE cred_lim   TO mcred_lim  
STORE note       TO mnote      
STORE RSUPCODE   TO MRSUPCODE
STORE AREA_CODE  TO MAREA_CODE
STORE PHONE      TO MPHONE
STORE FAX        TO MFAX
STORE NET_DAYS   TO MNET_DAYS
IF MNET_DAYS = 0
   STORE 14 TO MNET_DAYS
ENDIF
STORE BEG_DATE   TO MBEG_DATE
STORE END_DATE   TO MEND_DATE
STORE LET_CRD    TO MLET_CRD
STORE GUARAN     TO MGUARAN
STORE ACTIVE     TO MACTIVE
IF MACTIVE <> 'I'
   STORE 'A' TO MACTIVE
ENDIF
STORE INS_CO1    TO MINS_CO1
STORE INS_CO2    TO MINS_CO2
STORE INS_CO3    TO MINS_CO3
STORE INS_CO4    TO MINS_CO4
STORE INS_CO5    TO MINS_CO5
STORE INDEM_FLG TO MINDEM_FLG
STORE INDEM_DT  TO MINDEM_DT
RETURN

PROCEDURE REPLRSUP
IF NAME <> MNAME .OR. RSUPCODE <> MRSUPCODE
   DO FILELOCK
   REPLACE name       WITH mname      
   REPLACE RSUPCODE   WITH MRSUPCODE
ELSE
   DO RECLOCK
ENDIF
REPLACE street     WITH mstreet    
REPLACE city       WITH mcity      
REPLACE state      WITH mstate     
REPLACE zip        WITH mzip       
REPLACE zip4       WITH mzip4      
REPLACE cred_lim   WITH mcred_lim  
REPLACE note       WITH mnote      
REPLACE AREA_CODE  WITH MAREA_CODE
REPLACE PHONE      WITH MPHONE
REPLACE FAX        WITH MFAX
**IF MNET_DAYS <> 14
   REPLACE NET_DAYS   WITH MNET_DAYS
**ENDIF
REPLACE BEG_DATE   WITH MBEG_DATE
REPLACE END_DATE   WITH MEND_DATE
REPLACE LET_CRD    WITH MLET_CRD
REPLACE GUARAN     WITH MGUARAN
IF MACTIVE <> 'I'
   STORE ' ' TO MACTIVE
ENDIF
REPLACE ACTIVE     WITH MACTIVE
REPLACE INS_CO1    WITH MINS_CO1
REPLACE INS_CO2    WITH MINS_CO2
REPLACE INS_CO3    WITH MINS_CO3
REPLACE INS_CO4    WITH MINS_CO4
REPLACE INS_CO5    WITH MINS_CO5
REPLACE INDEM_FLG  WITH MINDEM_FLG
REPLACE INDEM_DT   WITH MINDEM_DT
UNLOCK
RETURN

PROCEDURE PUBLRSUP
PUBLIC mname, mstreet, mcity, mstate, mzip
PUBLIC MZIP4, MRSUPCODE
PUBLIC MAREA_CODE, MPHONE
PUBLIC MCRED_LIM, MNOTE
PUBLIC MFAX, MNET_DAYS, MLET_CRD, MGUARAN, MACTIVE, MBEG_DATE, MEND_DATE
RETURN


PROCEDURE RSUP_ADD
*************
* Program.: RSUP_ADD.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SUPPLIER ADD
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_RSUP = .T.  
STORE SPACE(4) TO MZIP4
MTITLE = ' - ADD REMIT TO SUPPLIER INFORMATION' 
**** PUT UP THE SCREEN
DO TEXTRSUP
DO WHILE MMORE_RSUP
   DO INITRSUP
   MNOT_DONE = .T.
   DO WHILE MNOT_DONE
      DO GETRSUP
      STORE 1 TO MACTION
      @ 24,0 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1.Save     2.Edit     3.Cancel    4.Save/Update Insurance'
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,4
      READ               
      DO CASE
      CASE MACTION = 3
         MNOT_DONE = .F.
         MMORE_RSUP = .F.
         LOOP
         
      CASE MACTION = 2
         LOOP
         
      CASE MACTION = 1 .OR. MACTION = 4
         IF MNAME = SPACE(32)    
            MNOT_DONE = .F.
            MMORE_RSUP = .F.
            LOOP
         ENDIF
         SEEK MNAME
         IF .NOT. EOF()
            @ 24,0 CLEAR
            STORE 'N' TO MYES_NO 
            @ 24,1 SAY 'REMIT TO NAME ALREADY ON FILE -DO YOU WANT TO CONTINUE WITH ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'Y'
               MINIT_NM = .T.
               DO INITRSUP
               LOOP
            ENDIF
         ENDIF
         IF MMASTDBF <> MDBFLOC
            SELECT E
            DO FOX_USE WITH "&MDBFLOC.CONTROL", .F.
         ELSE
            SELECT E
            DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
         ENDIF
         STORE STR(RSUPCODE+1,4) TO MRSUPCODE
         DO RECLOCK
         REPLACE RSUPCODE WITH RSUPCODE + 1
         UNLOCK
         USE
         SELECT A
         DO FILELOCK
         APPEND BLANK
         UNLOCK
         DO REPLRSUP
         IF MACTION = 4
            DO SUP_INS
         ENDIF
         MINIT_NM = .T.
         MADD = .T.
         MMORE_RSUP = .F.
         MNOT_DONE = .F.
      ENDCASE
   ENDDO
ENDDO
RETURN

PROCEDURE RSUPEDIT 
*************
* Program.: RSUPEDIT.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SUPPLIER EDIT/DELETE
*
* ---OPEN FILES
MMORE_PP = .T.  
MTITLE = ' - VIEW/CHANGE/DELETE REMIT TO SUPPLIER INFORMATION' 
**** PUT UP THE SCREEN
DO TEXTRSUP
DO STORRSUP
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   DO GETRSUP
   STORE 1 TO MACTION
   @ 24,0 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Save   2.Edit   3.Delete   4.Cancel   5.Save/Update Insurance'
   READ
   @24,09 GET MACTION PICTURE '9' RANGE 1,5
   READ               
   DO CASE
   CASE MACTION = 4
      MNOT_DONE = .F.
      LOOP
      
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 1 .OR. MACTION = 5
      DO REPLRSUP
      IF MACTION = 5
         DO SUP_INS
      ENDIF
      MNOT_DONE = .F.
      
   CASE MACTION = 3
      SELECT E
      DO FOX_USE WITH "PO_HEAD INDEX TMP_SUP", .F.
      SEEK A->RSUPCODE
      IF .NOT. EOF()
         @ 24,0 CLEAR
         STORE ' ' TO MYES_NO
         STORE 'CANNOT DELETE THIS SUPPLIER - PO(s) ON FILE ! ' TO MWAIT
         @ 24,1 SAY MWAIT
         CLEAR GETS    
         @ 24,51 GET MYES_NO PICTURE '@!'
         READ
         @ 24,0 CLEAR
         USE
         SELECT A
      ELSE
         USE
         SELECT A
         @ 24,0 CLEAR
         STORE 'N' TO MYES_NO
         STORE 'Are You Sure You Want to DELETE this Supplier (Y/N)? ' TO MWAIT
         @ 24,10 SAY MWAIT
         CLEAR GETS    
         @ 24,65 GET MYES_NO PICTURE '@!'
         READ
         IF MYES_NO = 'Y'
            DELETE
         ENDIF 
      ENDIF
      MNOT_DONE = .F.
   ENDCASE
   
ENDDO
RETURN

PROCEDURE SUP_SEL
******************
* Program.: SUP_SEL.PRG
* Author..: Grace Keller
* Date....: 10/12/86
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SUPPLIER SELECT
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT A
DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_NAME, &MDBFLOC.SUP_CODE", .F.
STORE SPACE(32)    TO MNAME 
MNAME_FD = .F.
STORE 1 TO MACTION
MSUP_SEL = .T.
DO WHILE MSUP_SEL
   
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - SELECT SHIPPED FROM SUPPLIER'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   @  5, 5 SAY 'Enter Search Field:'
   @  8, 5 SAY 'Name'
   @ 10, 5 GET Mname PICTURE '@!'
   
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      
      IF MNAME <> SPACE(32)
         STORE TRIM(MNAME) TO SRCH_ARG
         SEEK SRCH_ARG
         IF EOF() .OR. DELETED()
            @ 24,0 CLEAR
            STORE 'Y' TO MYES_NO
            @ 24,05 SAY 'NAME NOT FOUND - DO YOU WANT TO ADD (Y/N)? ' get MYES_NO PICTURE '@!'
            READ
            IF MYES_NO = 'Y'
               MINIT_NM = .F.
               DO SUP_ADD
               STORE SPACE(32) TO MNAME
            ELSE 
               STORE SPACE(32) TO MNAME
            ENDIF
            LOOP
         ELSE               
            STORE RECNO() TO MFST_REC
            MADD = .F.
            DO MUL1SUP 
            IF MACTION = 5
               LOOP
            ENDIF
            IF MADD
               MNAME = SPACE(32)
               LOOP
            ENDIF
            DO SUP_EDIT
            MNAME = SPACE(32)
            LOOP
         ENDIF
      ENDIF     
      
      MSUP_SEL = .F.
      LOOP
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 3
      MSUP_SEL = .F.
      
   ENDCASE
   
ENDDO
RETURN

PROCEDURE SUP_ADD
*************
* Program.: SUP_ADD.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SUPPLIER ADD
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE_SUP = .T.  
MTITLE = ' - ADD SUPPLIER INFORMATION' 
**** PUT UP THE SCREEN
STORE SPACE(10) TO MCONT_FAX
STORE SPACE(10) TO MCONT_PH, MFRT_PH
STORE SPACE(50) TO MFRT_EMAIL
STORE SPACE(32) TO MCONT_NAME
STORE SPACE(4)  TO MPU_CODE
STORE SPACE(32) TO MCONF_NAME
DO TEXTSUPP
DO WHILE MMORE_SUP
   DO INITSUPP
   MNOT_DONE = .T.
   DO WHILE MNOT_DONE
      DO GETSUPP
      STORE 1 TO MACTION
      @ 24,0 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Save      2. Edit       3. Cancel'
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      DO CASE
      CASE MACTION = 3
         MNOT_DONE = .F.
         MMORE_SUP = .F.
         LOOP
         
      CASE MACTION = 2
         LOOP
         
      CASE MACTION = 1
         IF MNAME = SPACE(32)    
            MNOT_DONE = .F.
            MMORE_SUP = .F.
            LOOP
         ENDIF
         IF MREM_NAME = SPACE(32)
            @ 24,0 CLEAR
            STORE 'REMIT TO NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MWAIT
            @ 24,5 GET MWAIT
            READ
            LOOP
         ENDIF
         SEEK MNAME
         IF .NOT. EOF()
            @ 24,0 CLEAR
            STORE 'N' TO MYES_NO 
            @ 24,1 SAY 'SHIPPED FROM NAME ALREADY ON FILE- DO YOU WANT TO CONTINUE WITH ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
            READ
            IF MYES_NO <> 'Y'
               MINIT_NM = .T.
               DO INITSUPP
               LOOP
            ENDIF
         ENDIF
         
         STORE MNAME TO MSUP_NAME
         STORE MSTREET TO MSUP_STRT
         STORE MCITY TO MSUP_CITY
         STORE MSTATE TO MSUP_STATE
         STORE MZIP TO MSUP_ZIP
         STORE MZIP4 TO MSUP_ZIP4
         STORE MNOTE TO MSUP_NOTE
         STORE MAREA_CODE TO MSUP_AREA
         STORE MFAX TO MSUP_FAX
         STORE MPHONE TO MSUP_PHONE
         IF MREM_NAME <> 'SAME'
            STORE MREM_NAME TO MNAME
         ENDIF
         
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME, &MDBFLOC.RSUPCODE" ,.F.
         MNAME_FD = .F.
         
         DO RSUPSEL2
         
         STORE MSUP_NAME TO MNAME    
         STORE MSUP_STRT TO MSTREET
         STORE MSUP_CITY TO MCITY
         STORE MSUP_STATE TO MSTATE
         STORE MSUP_ZIP TO MZIP
         STORE MSUP_ZIP4 TO MZIP4
         STORE MSUP_NOTE TO MNOTE
         STORE MSUP_AREA TO MAREA_CODE
         STORE MSUP_PHONE TO MPHONE
         STORE MSUP_FAX  TO MFAX
         IF .NOT. MNAME_FD
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY 'REMIT TO MUST BE ON FILE - PLEASE HIT ANY KEY TO REENTER'
            @ 24,78  GET MWAIT
            READ
            @ 24,0 CLEAR
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_NAME, &MDBFLOC.SUP_CODE", .F.
            LOOP
         ENDIF
         STORE RSUPCODE TO MRSUPCODE
         @ 20,4 SAY NAME
         @ 21,4 SAY STREET
         IF ZIP4 = SPACE(4)
            STORE ZIP TO MRZIP
         ELSE
            STORE ZIP + '-' + ZIP4 TO MRZIP
         ENDIF
         @ 22,4 SAY TRIM(CITY) + ', ' + STATE + '  ' + MRZIP
         
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_NAME, &MDBFLOC.SUP_CODE", .F.
         IF MCONF_NAME <> SPACE(32)
            ***HERE GET THE FRT CONFIRMATION PU SUPPLIER
            MNAME_FD = .F.
            STORE MNAME TO MSAVE_NAME
            STORE MCONF_NAME TO MNAME
            @ 24,0 CLEAR
            SAVE SCREEN TO MADD_SCRN
            DO SUP_SEL2
            RESTORE SCREEN FROM MADD_SCRN
            STOrE MSAVE_NAME TO MNAME
            IF MNAME_FD
               STORE SUP_CODE TO MPU_CODE
               @ 20,40 SAY NAME
               @ 21,40 SAY STREET
               IF ZIP4 = SPACE(4)
                  STORE ZIP TO MZIP
               ELSE
                  STORE ZIP + '-' + ZIP4 TO MZIP
               ENDIF
               @ 22,40 SAY TRIM(CITY) + ', ' + STATE + '  ' + MZIP
            ELSE
               STORE SPACE(4) TO MPU_CODE
            ENDIF
         ELSE
            STORE SPACE(4) TO MPU_CODE
            @ 20,40 SAY SPACE(32)
            @ 21,40 SAY SPACE(32)
            @ 22,40 SAY SPACE(32)
         ENDIF
         
         STORE 1 TO MACTION
         @ 24,0 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Save      2. Edit       3. Cancel'
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         
         DO CASE
         CASE MACTION = 2
            LOOP
         CASE MACTION = 3
            MNOT_DONE = .F.
            MMORE_SUP = .F.
            LOOP
            
         CASE MACTION = 1
            IF MMASTDBF <> MDBFLOC
               SELECT E
               DO FOX_USE WITH "&MDBFLOC.CONTROL", .F.
            ELSE
               SELECT E
               DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
            ENDIF
            STORE STR(SUP_CODE+1,4) TO MSUP_CODE
            DO RECLOCK
            REPLACE SUP_CODE WITH SUP_CODE + 1
            UNLOCK
            USE
            SELECT A
            DO FILELOCK
            APPEND BLANK
            UNLOCK
            DO REPLSUPP
            MINIT_NM = .T.
            MADD = .T.
            MMORE_SUP = .F.
            MNOT_DONE = .F.
         ENDCASE
      ENDCASE
   ENDDO
ENDDO
RETURN
* EOF: SUP_ADD.PRG

PROCEDURE SUP_EDIT
*************
* Program.: SUP_EDIT.PRG
* Author..: Grace Keller
* Date....: 10/12/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: SUPPLIER EDIT/DELETE
*
* ---OPEN FILES
MMORE_PP = .T.  
MTITLE = ' - VIEW/CHANGE/DELETE SHIPPED FROM SUPPLIER INFORMATION' 
**** PUT UP THE SCREEN
STORE SPACE(10) TO MCONT_FAX
STORE SPACE(10) TO MCONT_PH, MFRT_PH
STORE SPACE(50) TO MFRT_EMAIL
STORE SPACE(32) TO MCONT_NAME, MCONF_NAME
STORE SPACE(4)  TO MPU_CODE
DO TEXTSUPP
DO STORSUPP
STORE RECNO() TO MRECNO
DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE, &MDBFLOC.RSUPNAME", .F.
SEEK MRSUPCODE
IF .NOT. EOF()
   STORE NAME TO MREM_NAME
   STORE NAME TO MSV_NAME
   STORE STREET TO MREM_STRT
   STORE CITY TO MREM_CITY
   STORE STATE TO MREM_STATE
   IF ZIP4 = SPACE(4)
      STORE ZIP  TO MREM_ZIP
   ELSE
      STORE ZIP + '-' + ZIP4 TO MREM_ZIP
   ENDIF
ELSE
   STORE SPACE(32) TO MREM_NAME
   STORE MREM_NAME TO MSV_NAME
   STORE SPACE(28) TO MREM_STRT
   STORE SPACE(20) TO MREM_CITY
   STORE SPACE(2) TO MREM_STATE
   STORE SPACE(5) TO MREM_ZIP
ENDIF

DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE, &MDBFLOC.SUP_NAME", .F.
IF MPU_CODE <> SPACE(4)
   SEEK MPU_CODE
   IF EOF()
      STORE SPACE(32) TO MCONF_NAME, MSV_CONF
      STORE SPACE(28) TO MCONF_STRT
      STORE SPACE(20) TO MCONF_CITY
      STORE SPACE(2)  TO MCONF_ST
      STORE SPACE(5)  TO MCONF_ZIP
   ELSE
      STORE NAME TO MCONF_NAME, MSV_CONF
      STORE STREET TO MCONF_STRT
      STORE CITY   TO MCONF_CITY
      STORE STATE  TO MCONF_ST
      STORE ZIP    TO MCONF_ZIP
   ENDIF
ELSE
   STORE SPACE(32) TO MCONF_NAME, MSV_CONF
   STORE SPACE(28) TO MCONF_STRT
   STORE SPACE(20) TO MCONF_CITY
   STORE SPACE(2)  TO MCONF_ST
   STORE SPACE(5)  TO MCONF_ZIP
ENDIF

DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_NAME, &MDBFLOC.SUP_CODE", .F.
GOTO MRECNO
MNOT_DONE = .T.
DO WHILE MNOT_DONE
   DO GETSUPP
   @ 21,4 SAY MREM_STRT
   @ 22,4 SAY TRIM(MREM_CITY) + ', ' + MREM_STATE + '  ' + MREM_ZIP
   @ 21,40 SAY MCONF_STRT
   @ 22,40 SAY TRIM(MCONF_CITY) + ', ' + MCONF_ST + '  ' + MCONF_ZIP
   
   STORE 1 TO MACTION
   @ 24,0 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Save Updates    2.Edit Screen    3.Delete Supplier   4.Cancel'
   READ
   @24,09 GET MACTION PICTURE '9' RANGE 1,4
   READ               
   DO CASE
   CASE MACTION = 4
      MNOT_DONE = .F.
      LOOP
      
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 1
      
      STORE MNAME TO MSUP_NAME
      STORE MSTREET TO MSUP_STRT
      STORE MCITY TO MSUP_CITY
      STORE MSTATE TO MSUP_STATE
      STORE MZIP TO MSUP_ZIP
      STORE MZIP4 TO MSUP_ZIP4
      STORE MNOTE TO MSUP_NOTE
      STORE MAREA_CODE TO MSUP_AREA
      STORE MPHONE TO MSUP_PHONE
      STORE MFAX   TO MSUP_FAX
      IF MREM_NAME <> MSV_NAME .OR. MSV_CONF <> MCONF_NAME
         IF MREM_NAME <> MSV_NAME
            IF MREM_NAME <> 'SAME'
               STORE MREM_NAME TO MNAME
            ENDIF
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME, &MDBFLOC.RSUPCODE" ,.F.
            MNAME_FD = .F.
            
            DO RSUPSEL2
            
            STORE MSUP_NAME TO MNAME
            STORE MSUP_STRT TO MSTREET
            STORE MSUP_CITY TO MCITY
            STORE MSUP_STATE TO MSTATE
            STORE MSUP_ZIP TO MZIP
            STORE MSUP_ZIP4 TO MZIP4
            STORE MSUP_NOTE TO MNOTE
            STORE MSUP_AREA TO MAREA_CODE
            STORE MSUP_PHONE TO MPHONE 
            STORE MSUP_FAX  TO MFAX
            
            IF .NOT. MNAME_FD
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT
               @ 24,1 SAY 'REMIT TO MUST BE ON FILE - PLEASE HIT ANY KEY TO REENTER'
               @ 24,78  GET MWAIT
               READ
               @ 24,0 CLEAR
               DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_NAME, &MDBFLOC.SUP_CODE" ,.F.
               GOTO MRECNO
               LOOP
            ENDIF
            
            STORE RSUPCODE TO MRSUPCODE
            @ 20,4 SAY NAME
            @ 21,4 SAY STREET
            IF ZIP4 = SPACE(4)
               STORE ZIP + SPACE(5) TO MZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MZIP
            ENDIF
            @ 22,4 SAY TRIM(CITY) + ', ' + STATE + '  ' + MZIP
         ENDIF
         
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_NAME, &MDBFLOC.SUP_CODE", .F.
         
         IF MCONF_NAME <> SPACE(32) .AND. MSV_CONF <> MCONF_NAME
            ***HERE GET THE FRT CONFIRMATION PU SUPPLIER
            MNAME_FD = .F.
            STORE MNAME TO MSAVE_NAME
            STORE MCONF_NAME TO MNAME
            @ 24,0 CLEAR
            SAVE SCREEN TO MADD_SCRN
            DO SUP_SEL2
            RESTORE SCREEN FROM MADD_SCRN
            STORE MSAVE_NAME TO MNAME
            IF MNAME_FD
               STORE SUP_CODE TO MPU_CODE
               @ 20,40 SAY NAME
               @ 21,40 SAY STREET
               IF ZIP4 = SPACE(4)
                  STORE ZIP TO MZIP
               ELSE
                  STORE ZIP + '-' + ZIP4 TO MZIP
               ENDIF
               @ 22,40 SAY TRIM(CITY) + ', ' + STATE + '  ' + MZIP
            ELSE
               STORE SPACE(4) TO MPU_CODE
            ENDIF
         ELSE
            STORE SPACE(4) TO MPU_CODE
            @ 20,40 SAY SPACE(32)
            @ 21,40 SAY SPACE(32)
            @ 22,40 SAY SPACE(32)
         ENDIF
         
         SELECT A
         GOTO MRECNO
         
         STORE 1 TO MACTION
         
         @ 24,0 CLEAR
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Save      2. Edit       3. Cancel'
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         IF MACTION = 2
            LOOP
         ENDIF
         
         IF MACTION = 3
            MNOT_DONE = .F.
            LOOP
         ENDIF
      ENDIF
      
      DO REPLSUPP
      
      MNOT_DONE = .F.
      
   CASE MACTION = 3
      @ 24,0 CLEAR
      STORE 'N' TO MYES_NO
      STORE 'Are You Sure You Want to DELETE this Supplier (Y/N)? ' TO MWAIT
      @ 24,10 SAY MWAIT
      CLEAR GETS    
      @ 24,65 GET MYES_NO PICTURE '@!'
      READ
      IF MYES_NO = 'Y'
         DELETE
      ENDIF 
      MNOT_DONE = .F.
   ENDCASE
   
ENDDO
RETURN

PROCEDURE MUL5RSUP
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MATCH SELECT'
@ 3,0 TO 21,79
@  5, 2 SAY 'SUPPLIERS MATCHING YOUR INPUT.  PLEASE SELECT ACTION.'
@ 6,5 say 'NAME'
@ 6,42 SAY 'CITY'   
@ 6,70 SAY 'STATE'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC

MMULT_SUP = .T.
DO WHILE MMULT_SUP
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. NAME = SRCH_ARG .AND. ACTIVE = ' ' .AND. MLINE < 20
      
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      @ MLINE, 5 SAY NAME
      @ MLINE,42 SAY CITY    
      @ MLINE,71 SAY STATE
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. NAME = SRCH_ARG .AND. ACTIVE = ' '
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Select Supplier Number: '
   @ 22,25 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add Supplier  5.Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MMULT_SUP = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add Supplier  5.Cancel'
   @ 24,09 GET MACTION PICTURE '9' RANGE 1,5
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      @ 07,01 CLEAR TO 20,78
      IF .NOT. MORE_FLG
         GOTO MTOP_REC
         STORE MTOP_SEQ - 1 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 2
      @ 07,01 CLEAR TO 20,78
      GOTO MTOP_REC
      STORE MTOP_SEQ - 1 TO MSEQ_NUM
      IF MSEQ_NUM <> 0
         SKIP -13
         STORE MSEQ_NUM - 13 TO MSEQ_NUM
      ENDIF
      LOOP
      
   CASE MACTION = 3
      @ 07,01 CLEAR TO 20,78
      STORE 0 TO MSEQ_NUM
      GOTO MFST_REC
      LOOP
   CASE MACTION = 4
      MINIT_NM = .F.
      DO RSUP_ADD
      MMULT_SUP = .F.
      
   CASE MACTION = 5
      MMULT_SUP = .F.
      
   ENDCASE
   
ENDDO

RETURN


PROCEDURE SUP_SEL1
SELECT A
DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_NAME, &MDBFLOC.SUP_CODE", .F.
STORE SPACE(32)    TO MNAME 
MNAME_FD = .F.
STORE 1 TO MACTION
MSUP_SEL = .T.
DO WHILE MSUP_SEL
   
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - SELECT SHIP FROM SUPPLIER'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   @  5, 5 SAY 'Enter Search Field:'
   @  8, 5 SAY 'Name'
   @ 10, 5 GET Mname PICTURE '@!'
   
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   
   DO CASE
      
   CASE MACTION = 1
      IF MNAME <> SPACE(32)
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
      ENDIF
      MSUP_SEL = .F.
      LOOP
   CASE MACTION = 2
      LOOP
      
   CASE MACTION = 3
      MSUP_SEL = .F.
      
   ENDCASE
   
ENDDO
RETURN


PROCEDURE SUP_INS

STORE INS_CO1    TO MINS_CO1
STORE INS_CO2    TO MINS_CO2
STORE INS_CO3    TO MINS_CO3
STORE INS_CO4    TO MINS_CO4

STORE POLICY1    TO MPOLICY1
STORE POLICY2    TO MPOLICY2
STORE POLICY3    TO MPOLICY3
STORE POLICY4    TO MPOLICY4
STORE POLICY5    TO MPOLICY5

STORE INS_TP1    TO MINS_TP1
STORE INS_TP2    TO MINS_TP2
STORE INS_TP3    TO MINS_TP3
STORE INS_TP4    TO MINS_TP4
STORE INS_TP5    TO MINS_TP5

STORE AUTO_COV1  TO MAUTO_COV1
STORE AUTO_COV2  TO MAUTO_COV2
STORE AUTO_COV3  TO MAUTO_COV3
STORE AUTO_COV4  TO MAUTO_COV4

STORE EXCE_COV1 TO MEXCE_COV1
STORE EXCE_COV2 TO MEXCE_COV2

STORE RECA_COV1 TO MRECA_COV1

STORE GEN_COV1   TO MGEN_COV1 
STORE GEN_COV2   TO MGEN_COV2 
STORE GEN_COV3   TO MGEN_COV3 
STORE GEN_COV4   TO MGEN_COV4 
STORE GEN_COV5   TO MGEN_COV5 
STORE GEN_COV6   TO MGEN_COV6 

STORE WORK_COV1   TO MWORK_COV1
STORE WORK_COV2   TO MWORK_COV2
STORE WORK_COV3   TO MWORK_COV3

STORE AUTO_BEG   TO MAUTO_BEG
STORE EXCES_BEG  TO MEXCES_BEG
STORE RECAL_BEG  TO MRECAL_BEG
STORE GEN_BEG    TO MGEN_BEG  
STORE WORK_BEG   TO MWORK_BEG 
STORE AUTO_END   TO MAUTO_END
STORE EXCES_END  TO MEXCES_END
STORE RECAL_END  TO MRECAL_END
STORE GEN_END    TO MGEN_END  
STORE WORK_END   TO MWORK_END 
STORE AUTO_LET   TO MAUTO_LET
STORE EXCES_LET  TO MEXCES_LET
STORE RECAL_LET  TO MRECAL_LET
STORE GEN_LET    TO MGEN_LET  
STORE WORK_LET   TO MWORK_LET 
STORE CANCEL     TO MCANCEL

CLEAR
@ 0, 0 SAY MCOMPANY
@ 1, 0 SAY MPROGRAM + MTITLE
@ 1,68 SAY DATE()
@ 2,0 to 24,79
@ 03,01 SAY "INS CO. TYPE/COVERAGE  POLICY NUMBER         BEGIN DT    END DT    LETTER SENT"
@ 04,09 SAY "GENERAL"
@ 05,01 SAY "              Each Occurrence:"
@ 05,52 SAY "Pers/Adv Injury:"
@ 06,01 SAY "                  Fire Damage:"
@ 06,52 SAY "  GEN Aggregate:"
@ 07,01 SAY "              Medical Expense:"
@ 07,52 SAY "  OPS Aggregate:"
@ 08,01 TO 08,78
@ 09,09 SAY "AUTO LIABILITY"
@ 10,01 SAY "        Combined Single Limit:"
@ 10,46 SAY "Injury (Per Accident):"
@ 11,01 SAY "          Injury (Per Person):"
@ 11,52 SAY "Property Damage:"
@ 12,01 TO 12,78

@ 13,09 SAY "EXCESS LIAB"
@ 14,01 SAY "              Each Occurrence:"
@ 14,48 SAY "         Aggregate:"
@ 15,01 TO 15,78

@ 16,09 SAY "WORKER'S COMP"
@ 17,01 SAY "                Each Accident:"
@ 17,49 SAY "Disease (Employee):"
@ 18,01 SAY "              Disease (Limit):"
@ 19,01 TO 19,78
@ 20,09 SAY "PRODUCT RECALL"
@ 21,01 SAY "              Each Occurrence:"
@ 22,1 TO 22,4
@ 22,06 SAY "CANCELLATION DAYS NOTICE:"
@ 22,35 TO 22,78
STORE 2 TO MACTION
DO WHILE MACTION = 2
   
   @ 04,04 GET MINS_TP1 PICTURE '@!'
   @ 04,24 GET MPOLICY1 PICTURE '@!'
   @ 04,46 GET MGEN_BEG   
   @ 04,57 GET MGEN_END   
   @ 04,69 GET MGEN_LET   
   @ 05,32 GET MGEN_COV4  PICTURE '##,###,###'
   @ 06,32 GET MGEN_COV5  PICTURE '##,###,###'
   @ 07,32 GET MGEN_COV6  PICTURE '##,###,###'
   @ 05,69 GET MGEN_COV3  PICTURE '##,###,###'
   @ 06,69 GET MGEN_COV1  PICTURE '##,###,###'
   @ 07,69 GET MGEN_COV2  PICTURE '##,###,###'
   
   @ 09,04 GET MINS_TP2 PICTURE '@!'
   @ 09,24 GET MPOLICY2 PICTURE '@!'
   @ 09,46 GET MAUTO_BEG  
   @ 09,57 GET MAUTO_END  
   @ 09,69 GET MAUTO_LET  
   @ 10,32 GET MAUTO_COV1  PICTURE '##,###,###'
   @ 11,32 GET MAUTO_COV2  PICTURE '##,###,###'
   @ 10,69 GET MAUTO_COV3  PICTURE '##,###,###'
   @ 11,69 GET MAUTO_COV4  PICTURE '##,###,###'
   
   @ 13,04 GET MINS_TP4   PICTURE '@!'
   @ 13,24 GET MPOLICY4   PICTURE '@!'
   @ 13,46 GET MEXCES_BEG 
   @ 13,57 GET MEXCES_END 
   @ 13,69 GET MEXCES_LET 
   @ 14,32 GET MEXCE_COV1 PICTURE '##,###,###'
   @ 14,69 GET MEXCE_COV2 PICTURE '##,###,###'
   
   @ 16,04 GET MINS_TP3  PICTURE '@!'
   @ 16,24 GET MPOLICY3  PICTURE '@!'
   @ 16,46 GET MWORK_BEG   
   @ 16,57 GET MWORK_END  
   @ 16,69 GET MWORK_LET  
   @ 17,32 GET MAUTO_COV1 PICTURE '##,###,###'
   @ 18,32 GET MAUTO_COV2 PICTURE '##,###,###'
   @ 17,69 GET MAUTO_COV3 PICTURE '##,###,###'
   
   @ 20,04 GET MINS_TP5   PICTURE '@!'
   @ 20,24 GET MPOLICY5   PICTURE '@!'
   @ 20,46 GET MRECAL_BEG 
   @ 20,57 GET MRECAL_END 
   @ 20,69 GET MRECAL_LET 
   @ 21,32 GET MRECA_COV1 PICTURE '##,###,###'
   
   @ 22,32 GET MCANCEL    PICTURE '##'
   
   
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Save    2. Edit     3. Cancel'                                     
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   
   IF MACTION = 1
      DO RECLOCK
      REPLACE INS_TP1    WITH MINS_TP1
      REPLACE INS_TP2    WITH MINS_TP2
      REPLACE INS_TP3    WITH MINS_TP3
      REPLACE INS_TP4    WITH MINS_TP4
      REPLACE INS_TP5    WITH MINS_TP5
      
      REPLACE POLICY1    WITH MPOLICY1
      REPLACE POLICY2    WITH MPOLICY2
      REPLACE POLICY3    WITH MPOLICY3
      REPLACE POLICY4    WITH MPOLICY4
      REPLACE POLICY5    WITH MPOLICY5
      
      REPLACE AUTO_COV1  WITH MAUTO_COV1
      REPLACE AUTO_COV2  WITH MAUTO_COV2
      REPLACE AUTO_COV3  WITH MAUTO_COV3
      REPLACE AUTO_COV4  WITH MAUTO_COV4
      
      REPLACE EXCE_COV1 WITH MEXCE_COV1
      REPLACE EXCE_COV2 WITH MEXCE_COV2
      
      REPLACE RECA_COV1 WITH MRECA_COV1
      
      REPLACE GEN_COV1   WITH MGEN_COV1 
      REPLACE GEN_COV2   WITH MGEN_COV2 
      REPLACE GEN_COV3   WITH MGEN_COV3 
      REPLACE GEN_COV4   WITH MGEN_COV4 
      REPLACE GEN_COV5   WITH MGEN_COV5 
      REPLACE GEN_COV6   WITH MGEN_COV6 
      
      REPLACE WORK_COV1  WITH MWORK_COV1
      REPLACE WORK_COV2  WITH MWORK_COV2
      REPLACE WORK_COV3  WITH MWORK_COV3
      
      REPLACE AUTO_BEG   WITH MAUTO_BEG
      REPLACE EXCES_BEG  WITH MEXCES_BEG
      REPLACE RECAL_BEG  WITH MRECAL_BEG
      REPLACE GEN_BEG    WITH MGEN_BEG  
      REPLACE WORK_BEG   WITH MWORK_BEG 
      REPLACE AUTO_END   WITH MAUTO_END
      REPLACE EXCES_END  WITH MEXCES_END
      REPLACE RECAL_END  WITH MRECAL_END
      REPLACE GEN_END    WITH MGEN_END  
      REPLACE WORK_END   WITH MWORK_END 
      REPLACE AUTO_LET   WITH MAUTO_LET
      REPLACE EXCES_LET  WITH MEXCES_LET
      REPLACE RECAL_LET  WITH MRECAL_LET
      REPLACE GEN_LET    WITH MGEN_LET  
      REPLACE WORK_LET   WITH MWORK_LET 
      REPLACE CANCEL     WITH MCANCEL
      UNLOCK
   ENDIF
ENDDO
RETURN

* EOF: SUP_PROC.PRG

*Formatted by: ToolBox Ver. 1.2  on 2/12/14 at 1:04 PM.
