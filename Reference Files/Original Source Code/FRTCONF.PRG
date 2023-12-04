**********
* Program.: FRTCONF.PRG
* Author..: Grace Keller
* Date....: 12/06/2007
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: dBASE III
* Notes...: PRINT FREIGHT ORDER CONFIRMATION
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxBASE+   Multi-User Code Insertion     

SET CENTURY ON
SET DELETED ON
SET TALK OFF
SET ECHO OFF
SET BELL OFF
SET MENU OFF
SET SAFETY OFF
SET ESCAPE ON
SET SCOREBOARD ON
SET STATUS OFF
SET EXCLUSIVE OFF
SET PATH TO \AMERIFOX   
SET DECIMALS TO 5
SET DEVICE TO SCREEN

CLIPPER = .F.
FOXBASE = .T.
MMONO   = .F.

* ---SET COLOR TO values.   (If changed, change other one farther down too)
IF .NOT. MMONO .AND. ISCOLOR()
   SET COLOR TO W+/B,W+/R
ELSE
   SET COLOR TO W/N,N/W
ENDIF

CLOSE ALL
SET DEVICE TO SCREEN
INSMODE(.F.)

**** FINISHES THE READ WHEN DOING A PAGE DOWN

SELECT A
DO FOX_USE WITH "C:\COMPINFO\SCREEN", .F.
MSCRNSIZE = SCRNSIZE
USE

DO CASE
   *** TEST
CASE MSCRNSIZE = 'T'
   DEFINE WINDOW MWINDOW ;
      FROM 2,24 TO 40,252 ;
      FONT "LUCIDA CONSOLE", 18 ;
      COLOR W+/B, W+/R ;
      NONE
   *** Jeni
CASE MSCRNSIZE = 'J'
   **GOOD - FROM 2,10 TO 35,200  
   **BETTER-  FROM 2,5 TO 35,210
   DEFINE WINDOW MWINDOW ;
      FROM 2,5 TO 40,210 ;
      FONT "LUCIDA CONSOLE", 16 ;
      COLOR W+/B, W+/R ;
      NONE
   *** WIDESCREEN
CASE MSCRNSIZE = 'W'
   DEFINE WINDOW MWINDOW ;
      FROM 5,30 TO 57,272 ;
      FONT "LUCIDA CONSOLE", 20 ;
      COLOR W+/B, W+/R ;
      NONE
*** viewsonic-CAROLYN HIGH RES 
CASE MSCRNSIZE = 'V'
   DEFINE WINDOW MWINDOW ;
     FROM 7,40 TO 60,280 ;
     FONT "LUCIDA CONSOLE", 28 ;
     COLOR W+/B, W+/R ;
     NONE
   *** LAPTOP
CASE MSCRNSIZE = 'L'
   DEFINE WINDOW MWINDOW ;
      FROM 2,23 TO 54,265 ;
      FONT "LUCIDA CONSOLE", 20 ;
      COLOR W+/B, W+/R ;
      NONE
   *** OTHER - SQUARE 
OTHERWISE
   DEFINE WINDOW MWINDOW ;
      FROM 5,4 TO 57,200 ;
      FONT "LUCIDA CONSOLE", 19 ;
      COLOR W+/B, W+/R ;
      NONE
ENDCASE

ACTIVATE WINDOW "MWINDOW"

* ---MAIN PROCESSING LOOP
CLEAR
SET COLOR TO W/W,W/W
SET COLOR TO W+/B+,W+/R+
CLEAR


**********************************************************************
**** THIS WORKS - BUT GIVES AN EXTRA EJECT AT THE END OF JOB**********
**** ORIGINALLY HAD THIS WAY FOR STODDARD COUNTY
**MPRINTIT = "PRINT.EXE /D:" + MPRINTER + " C:\COMPINFO\PRT_FILE.TXT"
**********************************************************************

****TESTING************
****MPRINTIT = "PRINT.EXE /D:\\GRACE64-HP\HP4250 \COMPINFO\PRTFILE.TXT"
****MPRINTIT = "PRINT.EXE /D:\\GINGER-PC\HP940C \REPORTS\PRTFILE.TXT"
*** END OF TESTING*****
************************************************************************

* ---Initialize global variables.
SELECT A
DO FOX_USE WITH "COMPANY", .F.
MCOMPANY = TRIM(COMPANY)
MMASTDBF = TRIM(MASTDBF)
MDBFLOC = TRIM(DBFLOC)
USE

SELECT A
DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
MPROGRAM = TRIM(PROGRAM)
MPROG_CODE = PROG_CODE
USE

IF FILE("C:\COMPINFO\PRINTERS.DBF")
   SELECT A
   DO FOX_USE WITH "C:\COMPINFO\PRINTERS", .F.
   MPRINTER  = TRIM(PRINTER1)
   MPRINTER1 = TRIM(PRINTER1)
   MPRINTER2 = TRIM(PRINTER2)
   MPRINTER3 = TRIM(PRINTER3)
   USE
ELSE
   MPRINTER  = 'DONOTPRINT'
   MPRINTER1 = 'DONOTPRINT'
   MPRINTER2 = 'DONOTPRINT'
   MPRINTER3 = 'DONOTPRINT'
ENDIF  

MPRINTIT  = 'COPY C:\COMPINFO\PRT_FILE.TXT ' + MPRINTER
MPRINTIT1 = 'COPY C:\COMPINFO\PRT_FILE.TXT ' + MPRINTER1
MPRINTIT2 = 'COPY C:\COMPINFO\PRT_FILE.TXT ' + MPRINTER2
MPRINTIT3 = 'COPY C:\COMPINFO\PRT_FILE.TXT ' + MPRINTER3


**********************************************************************
**** THIS WORKS - BUT GIVES AN EXTRA EJECT AT THE END OF JOB**********
**** ORIGINALLY HAD THIS WAY FOR STODDARD COUNTY
**MPRINTIT = "PRINT.EXE /D:" + MPRINTER + " C:\COMPINFO\PRT_FILE.TXT"
**********************************************************************

****TESTING************
****MPRINTIT = "PRINT.EXE /D:\\GRACE64-HP\HP4250 \COMPINFO\PRTFILE.TXT"
****MPRINTIT = "PRINT.EXE /D:\\GINGER-PC\HP940C \REPORTS\PRTFILE.TXT"
*** END OF TESTING*****
************************************************************************

STORE 'BROKER SYSTEM' TO MPROGRAM

STORE .T. TO MONO

MPASSWORD = 'ADM99'
MUSER = 'SUPERVISOR'
MSECURITY = .T.

ON KEY LABEL PGUP CLEAR READ
ON KEY LABEL PGDN CLEAR READ

STORE ' ' TO MSELECTION

MCONTINUE = .T.
DO WHILE MCONTINUE
   CLEAR
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - FREIGHT CONFIRMATION'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,80
   MCHOICE = ' '
   @ 10,5 SAY 'Add    Confirmation (A)'
   @ 11,5 SAY 'Change Confirmation (C)'
   @ 12,5 say 'Delete Confirmation (D)'
   @ 14,5 SAY '             Choice: '
   @ 14,26 GET MCHOICE PICTURE '@!' VALID(MCHOICE = 'A' .OR. MCHOICE = 'C' .OR. MCHOICE = 'D' .OR. MCHOICE = ' ')
   READ
   IF MCHOICE = ' '
      MCONTINUE = .F.
      LOOP
   ENDIF
   
   MNAME_FD = .F.
   DO FRT_SEL1 
   IF .NOT. MNAME_FD
      MCONTINUE = .F.
      LOOP
   ENDIF
   
   STORE NAME TO MNAME
   STORE FRT_CODE TO MFRT_CODE
   STORE FRT_CONT TO MFRT_CONT
   STORE AREA_CODE TO MAREA1
   STORE PHONE TO MPHONE1
   STORE FAX_AREA TO MAREA2
   STORE FAX_PHONE TO MPHONE2
   
   SELECT F
   DO FOX_USE WITH "FRTCONF INDEX FRTCONF", .F.
   IF MCHOICE = 'C' .OR. MCHOICE = 'D'
      MNEW = .F.
      MACTION = 1
      SEEK MFRT_CODE
      IF .NOT. EOF()
         STORE RECNO() TO MFST_REC
         STORE FRT_CODE TO SRCH_ARG
        SKIP
         IF FRT_CODE = SRCH_ARG
            GOTO MFST_REC
            DO CONF_SEL
            IF MACTION = 4
               @ 24,0 CLEAR
               MWAIT = ' '
               @ 24,1 SAY 'No Confirmation Selected - Press Enter to Continue ' GET MWAIT
               READ
               CLOSE DATA
               LOOP
            ENDIF
         ELSE
            GOTO MFST_REC
         ENDIF
      ELSE
         @ 24,0 CLEAR
         MWAIT = ' '
         @ 24,1 SAY 'No Confirmation on File for Carrier - Press Enter to Continue ' GET MWAIT
         READ
         CLOSE DATA
         LOOP
      ENDIF
      DO CASE
      CASE MCHOICE = 'C'
         STORE RATE    TO MRATE
         STORE PALLETS TO MPALLETS
         STORE SALES1  TO MSALES1
         STORE SALES2  TO MSALES2
         STORE SALES3  TO MSALES3
         STORE SALES4  TO MSALES4
         STORE SALES5  TO MSALES5
         STORE SALES6  TO MSALES6
         STORE SALES7  TO MSALES7
         STORE SALES8  TO MSALES8
         STORE PO1     TO MPO1
         STORE PO2     TO MPO2
         STORE PO3     TO MPO3
         STORE PO4     TO MPO4
         STORE PO5     TO MPO5
         STORE PO6     TO MPO6
         STORE PO7     TO MPO7
         STORE PO8     TO MPO8
         STORE SUFF1   TO MSUFF1
         STORE SUFF2   TO MSUFF2
         STORE SUFF3   TO MSUFF3
         STORE SUFF4   TO MSUFF4
         STORE SUFF5   TO MSUFF5
         STORE SUFF6   TO MSUFF6
         STORE SUFF7   TO MSUFF7
         STORE SUFF8   TO MSUFF8
         STORE NOTE1   TO MNOTE1
         STORE NOTE2   TO MNOTE2
      OTHERWISE
         DO RECLOCK
         DELETE
         UNLOCK
         MWAIT = ' '
         @ 24,0 CLEAR
         @ 24,1 SAY 'Confirmation Deleted - Press Enter to Continue ' GET MWAIT
         READ
         CLOSE DATA
         LOOP
      ENDCASE
   ELSE
      MNEW = .T.
   ENDIF
   RELEASE MFST_REC, SRCH_ARG, MWAIT
   RELEASE MNAME_FD, MCHOICE
   IF MNEW
      STORE 0 TO MRATE
      STORE 0 TO MPALLETS
      STORE SPACE(2) TO MSALES1, MSALES2, MSALES3, MSALES4, MSALES5, MSALES6, MSALES7, MSALES8
      STORE SPACE(4) TO MPO1, MPO2, MPO3, MPO4, MPO5, MPO6, MPO7, MPO8
      STORE ' ' TO MSUFF1, MSUFF2, MSUFF3, MSUFF4, MSUFF5, MSUFF6, MSUFF7, MSUFF8
      STORE SPACE(35) TO MNOTE1, MNOTE2
   ENDIF
   STORE 'Rose Hartman  ' TO MLOCAL
   **STORE 'Kathy Steffens' TO MLOCAL
   CLEAR
   @ 00,00 SAY 'FREIGHT CONFIRMATION'
   @ 00,70 SAY DATE()
   @ 1,00 SAY 'Frt Comp: '
   @ 1,11 say MNAME
   @ 1,47 SAY 'RATE:'
   @ 1,53 GET MRATE PICTURE '9999.99'
   @ 1,65 SAY 'PALLETS:'
   @ 1,74 GET MPALLETS PICTURE '99'
   *012345678901234567890123456789012345678901234567890123456789012345678901234567890
   *XX-XXXX-X XX-XXXX-X XX-XXXX-X XX-XXXX-X XX-XXXX-X XX-XXXX-X XX-XXXX-X XX-XXXX-X 
   *               10        20        30        40        50       60        70
   @ 2,0 SAY '  -    -    -    -    -    -    -    -    -    -    -    -    -    -    -    -' 
   @ 3,0 to 24,80
   STORE 2 TO MACTION
   DO WHILE MACTION = 2
      @ 2,0  GET MSALES1 PICTURE '##'
      @ 2,3  GET MPO1 PICTURE '9999'
      @ 2,8  GET MSUFF1 PICTURE '@!'
      @ 2,9  SAY '/'
      
      @ 2,10 GET MSALES2 PICTURE '##'
      @ 2,13 GET MPO2 PICTURE '9999'
      @ 2,18 GET MSUFF2 PICTURE '9'
      @ 2,19  SAY '/'
      
      @ 2,20 GET MSALES3 PICTURE '##'
      @ 2,23 GET MPO3 PICTURE '9999'
      @ 2,28 GET MSUFF3 PICTURE '@!'
      @ 2,29  SAY '/'
      
      @ 2,30 GET MSALES4 PICTURE '##'
      @ 2,33 GET MPO4 PICTURE '9999'
      @ 2,38 GET MSUFF4 PICTURE '@!'
      @ 2,39  SAY '/'
      
      @ 2,40 GET MSALES5 PICTURE '##'
      @ 2,43 GET MPO5 PICTURE '9999'
      @ 2,48 GET MSUFF5 PICTURE '@!'
      @ 2,49  SAY '/'
      
      @ 2,50 GET MSALES6 PICTURE '##'
      @ 2,53 GET MPO6 PICTURE '9999'
      @ 2,58 GET MSUFF6 PICTURE '@!'
      @ 2,59  SAY '/'
      
      @ 2,60 GET MSALES7 PICTURE '##'
      @ 2,63 GET MPO7 PICTURE '9999'
      @ 2,68 GET MSUFF7 PICTURE '@!'
      @ 2,69  SAY '/'
      
      @ 2,70 GET MSALES8 PICTURE '##'
      @ 2,73 GET MPO8 PICTURE '9999'
      @ 2,78 GET MSUFF8 PICTURE '@!'
      
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit    3. Cancel/Exit'
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MACTION = 3
      CLOSE DATA
      LOOP
   ENDIF
   STORE SPACE(4) TO MSUP1, MSUP2, MSUP3, MSUP4
   STORE SPACE(4) TO MCUS1, MCUS2, MCUS3, MCUS4, MCUS5, MCUS6, MCUS7, MCUS8
   SELECT D
   DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
   SELECT C
   DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
   SELECT B
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
   I = 1
   X = 1
   DO WHILE I<=8
      MI = STR(I,1)
      IF MPO&MI <> SPACE(4)
         SEEK MSALES&MI + MPO&MI+MSUFF&MI
         IF .NOT. EOF()
            IF X<=4
               ** CHECK FOR SUPPLIER - AND - POSSIBLY SUPPLIER LOCATIONS TO
               ** COMBINE INTO ONE PU LOCATION
               
               SELECT D
               SEEK B->SUP_CODE
               IF .NOT. EOF() .AND. PU_CODE <> SPACE(4)
                  STORE PU_CODE TO MPU_SUP
               ELSE
                  STORE B->SUP_CODE TO MPU_SUP
               ENDIF
               
               SELECT B
               IF MPU_SUP = MSUP1 .OR. MPU_SUP = MSUP2 .OR. MPU_SUP = MSUP3 .OR. MPU_SUP = MSUP4
               ELSE
                  DO CASE
                  CASE MSUP1 = SPACE(4)
                     STORE MPU_SUP TO MSUP1
                     X = X + 1
                  CASE MSUP2 = SPACE(4)
                     STORE MPU_SUP TO MSUP2
                     X = X + 1
                  CASE MSUP3 = SPACE(4)
                     STORE MPU_SUP TO MSUP3
                     X = X + 1
                  CASE MSUP4 = SPACE(4)
                     STORE MPU_SUP TO MSUP4
                     X = X + 1
                  ENDCASE
                  
               ENDIF
            ENDIF
            ** CHECK FOR CUSTOMER
            IF BUY_CODE = MCUS1 .OR. BUY_CODE = MCUS2 .OR. BUY_CODE = MCUS3 .OR. BUY_CODE = MCUS4 .OR. BUY_CODE = MCUS5 .OR. BUY_CODE = MCUS6 .OR. BUY_CODE = MCUS7 .OR. BUY_CODE = MCUS8
            ELSE
               DO CASE
               CASE MCUS1 = SPACE(4)
                  STORE BUY_CODE TO MCUS1
               CASE MCUS2 = SPACE(4)
                  STORE BUY_CODE TO MCUS2
               CASE MCUS3 = SPACE(4)
                  STORE BUY_CODE TO MCUS3
               CASE MCUS4 = SPACE(4)
                  STORE BUY_CODE TO MCUS4
               CASE MCUS5 = SPACE(4)
                  STORE BUY_CODE TO MCUS5
               CASE MCUS6 = SPACE(4)
                  STORE BUY_CODE TO MCUS6
               CASE MCUS7 = SPACE(4)
                  STORE BUY_CODE TO MCUS7
               CASE MCUS8 = SPACE(4)
                  STORE BUY_CODE TO MCUS8
               ENDCASE
            ENDIF
         ENDIF
      ENDIF
      I = I + 1
   ENDDO
   
   I = 1
   DO WHILE I<= 8
      MI = STR(I,1)
      IF I<=4
         STORE SPACE(20) TO MPU&MI, MDEL&MI
         STORE SPACE(7) TO MPUADDR&MI, MDELADDR&MI
         STORE ' ' TO MPU_SEQ&MI, MDEL_SEQ&MI
      ELSE
         STORE SPACE(20) TO MDEL&MI
         STORE SPACE(7) TO MDELADDR&MI
         STORE ' ' TO MDEL_SEQ&MI
      ENDIF
      I = I + 1
   ENDDO
   
   IF .NOT. MNEW
      ** CHECK TO SEE IF I CAN PUT IN SEQUENCE
      SELECT F
      I = 1
      DO WHILE I<= 8
         MI = STR(I,1)
         
         DO CASE
         CASE MCUS&MI = CUS1
            STORE '1' TO MDEL_SEQ&MI
         CASE MCUS&MI = CUS2
            STORE '2' TO MDEL_SEQ&MI
         CASE MCUS&MI = CUS3
            STORE '3' TO MDEL_SEQ&MI
         CASE MCUS&MI = CUS4
            STORE '4' TO MDEL_SEQ&MI
         CASE MCUS&MI = CUS5
            STORE '5' TO MDEL_SEQ&MI
         CASE MCUS&MI = CUS6
            STORE '6' TO MDEL_SEQ&MI
         CASE MCUS&MI = CUS7
            STORE '7' TO MDEL_SEQ&MI
         CASE MCUS&MI = CUS8
            STORE '8' TO MDEL_SEQ&MI
         ENDCASE
         IF I<=4
            DO CASE
            CASE MSUP&MI = SUP1
               STORE '1' TO MPU_SEQ&MI
            CASE MSUP&MI = SUP2
               STORE '2' TO MPU_SEQ&MI
            CASE MSUP&MI = SUP3
               STORE '3' TO MPU_SEQ&MI
            CASE MSUP&MI = SUP4
               STORE '4' TO MPU_SEQ&MI
            ENDCASE
         ENDIF
         I = I + 1
      ENDDO
      
   ENDIF
   
   SELECT D
   DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
   SELECT E
   DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
   
   I = 1
   DO WHILE I<=8
      MI = STR(I,1)
      IF I<=4
         IF MSUP&MI <> SPACE(4)
            SELECT D
            SEEK MSUP&MI
            IF EOF()
               STORE 'SUP ' + MSUP&MI + ' NOT ON FILE' TO MPU&MI
            ELSE
               STORE SUBSTR(NAME,1,20) TO MPU&MI
               STORE TRIM(SUBSTR(CITY,1,4)) + ',' + STATE TO MPUADDR&MI
            ENDIF
         ENDIF
      ENDIF
      IF MCUS&MI <> SPACE(4)
         SELECT E
         SEEK MCUS&MI
         IF EOF()
            STORE 'CUS ' + MCUS&MI + ' NOTFL' TO MDEL&MI
         ELSE
            **STORE SUBSTR(NAME,1,20) TO MDEL&MI
            STORE SUBSTR(NAME,1,10) TO MDEL&MI
            STORE TRIM(SUBSTR(CITY,1,4)) + ',' + STATE TO MDELADDR&MI
         ENDIF
      ENDIF
      I = I + 1
   ENDDO
   
   @ 4,1 SAY 'PU   Locations             PU Date      Deliv Locations            Del Date'
   @ 5,1 SAY 'Seq                           Time      Seq                            Time'
   *          10        20        30        40        50        60        70        80
   *-12345678901234567890123456789012345678901234567890123456789012345678901234567890----------------------------------------------------------------------------
   *6 x  Atlas                  xx/xx/xxxx     x  Sysco Foods            xx/xx/xxxx
   *7    XXXX XX  #:123456789012   XX:XX A        XXXX XX  #:123456789012   XX:XX A
   
   *** GET EVERYTHING IN THE RIGHT ORDER
   MCONT = .T.
   MYES_NO = ' '
   
   DO WHILE MCONT
      MLINE = 6
      I = 1
      DO WHILE I<=8
         MI = STR(I,1)
         IF I<=4
            IF MSUP&MI <> SPACE(4)
               @ MLINE,5 SAY MPU&MI
               @ MLINE+1,5 SAY MPUADDR&MI
            ENDIF
         ENDIF
         
         IF MCUS&MI <> SPACE(4)
            @ MLINE,46 SAY MDEL&MI
            @ MLINE+1,46 SAY MDELADDR&MI
         ENDIF
         MLINE = MLINE + 2
         I = I + 1
      ENDDO
      
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         I = 1
         MLINE = 6
         DO WHILE I<= 4
            MI = STR(I,1)
            IF MSUP&MI <> SPACE(4)
               @ MLINE,2 GET MPU_SEQ&MI
            ENDIF
            I = I + 1
            MLINE = MLINE + 2
         ENDDO
         
         I = 1
         MLINE = 6
         DO WHILE I<= 8
            MI = STR(I,1)
            IF MCUS&MI <> SPACE(4)
               @ MLINE,43 GET MDEL_SEQ&MI
            ENDIF
            I = I + 1
            MLINE = MLINE + 2
         ENDDO
         STORE 1 TO MACTION
         
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue    2. Edit    3. Cancel/Exit'
         READ
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
      ENDDO      
      IF MACTION = 3
         MYES_NO = 'X'
         MCONT = .F.
         LOOP
      ENDIF
      
      *** CLEAR OUT THE SCREEN
      ***
      I = 1
      MLINE = 6
      DO WHILE I<= 4
         MI = STR(I,1)
         IF MSUP&MI <> SPACE(4)
            @ MLINE,2 SAY MPU_SEQ&MI
         ENDIF
         I = I + 1
         MLINE = MLINE + 2
      ENDDO
      
      I = 1
      MLINE = 6
      DO WHILE I<= 8
         MI = STR(I,1)
         IF MCUS&MI <> SPACE(4)
            @ MLINE,43 SAY MDEL_SEQ&MI
         ENDIF
         I = I + 1
         MLINE = MLINE + 2
      ENDDO
      
      ***************************************
      *** SORT ALL OF THIS IN THE RIGHT ORDER
      *** SORTED WORK FIELDS START WITH 'S'
      ***************************************
      I = 1
      DO WHILE I<= 8
         MI = STR(I,1)
         IF I<=4
            STORE SPACE(4)  TO SSUP&MI, SCUS&MI
            STORE SPACE(20) TO SPU&MI
            STORE SPACE(7)  TO SUADDR&MI
            STORE SPACE(20) TO SDEL&MI
            STORE SPACE(7)  TO SDELADDR&MI
            STORE ' ' TO SPU_SEQ&MI, SDEL_SEQ&MI
         ELSE
            STORE SPACE(4)  TO SCUS&MI
            STORE SPACE(20) TO SDEL&MI
            STORE SPACE(7)  TO SDELADDR&MI
            STORE ' ' TO SDEL_SEQ&MI
         ENDIF
         I = I + 1
      ENDDO
      
      I = 1
      DO WHILE I<=8
         MI = STR(I,1)
         IF I<=4
            IF MSUP&MI <> SPACE(4)
               SI = MPU_SEQ&MI
               STORE MSUP&MI TO SSUP&SI
               STORE MPU&MI TO SPU&SI
               STORE MPUADDR&MI TO SPUADDR&SI
               STORE SI TO SPU_SEQ&SI
            ENDIF
         ENDIF
         IF MCUS&MI <> SPACE(4)
            SI = MDEL_SEQ&MI
            STORE MCUS&MI TO SCUS&SI
            STORE MDEL&MI TO SDEL&SI
            STORE MDELADDR&MI TO SDELADDR&SI
            STORE SI TO SDEL_SEQ&SI
         ENDIF
         I = I + 1
      ENDDO
      
      MLINE = 6
      I = 1
      DO WHILE I<=8
         @ MLINE,2 SAY ' '
         @ MLINE,43 SAY ' '
         @ MLINE,5 SAY SPACE(20)
         @ MLINE,46 SAY SPACE(20)
         @ MLINE+1,5 SAY SPACE(7) 
         @ MLINE+1,46 SAY SPACE(7)
         
         MI = STR(I,1)
         IF I<=4
            IF SSUP&MI <> SPACE(4)
               @ MLINE,2 SAY SPU_SEQ&MI
               @ MLINE,3 SAY '->'
               @ MLINE,5 SAY SPU&MI
               @ MLINE+1,5 SAY SPUADDR&MI
            ENDIF
         ENDIF
         
         IF SCUS&MI <> SPACE(4)
            @ MLINE,43 SAY SDEL_SEQ&MI
            @ MLINE,44 SAY '->'
            @ MLINE,46 SAY SDEL&MI
            @ MLINE+1,46 SAY SDELADDR&MI
         ENDIF
         MLINE = MLINE + 2
         I = I + 1
      ENDDO
      @ 25,0 CLEAR
      
      @ 25,1 SAY 'Are the Pickup and Deliveries in the Correct Order (Y/N or X to Exit): ' GET MYES_NO PICTURE '@!' VALID(MYES_NO = 'Y' .OR. MYES_NO = 'N' .OR. MYES_NO = 'X')
      READ                                                                    
      IF MYES_NO = 'Y' .OR. MYES_NO = 'X'
         MCONT = .F.
      ENDIF
      @ 25,0 CLEAR
   ENDDO
   
   IF MYES_NO = 'X'
      LOOP
   ENDIF
   
   *** RELEASE SOME ITEMS
   
   I = 1
   DO WHILE I<= 8
      MI = STR(I,1)
      IF I<=4
         RELEASE MPU&MI, PUADDR&MI
         RELEASE MDEL&MI, MDELADDR&MI
         RELEASE MPU_SEQ&MI, MDEL_SEQ&MI
      ELSE
         RELEASE MDEL&MI, MDELADDR&MI
         RELEASE MDEL_SEQ&MI
      ENDIF
      I = I + 1
   ENDDO
   
   I = 1
   DO WHILE I<= 8
      MI = STR(I,1)
      IF I<=4
         STORE CTOD('') TO SPU_DATE&MI, SDEL_DATE&MI
         STORE SPACE(5) TO SPU_TIME&MI, SDEL_TIME&MI
         STORE ' ' TO SPU_AMPM&MI, SDEL_AMPM&MI
         STORE SPACE(12) TO SPU_NBR&MI, SDEL_NBR&MI
         STORE 0 TO SDEL_WT&MI
      ELSE
         STORE CTOD('') TO SDEL_DATE&MI
         STORE SPACE(5) TO SDEL_TIME&MI
         STORE ' ' TO SDEL_AMPM&MI
         STORE SPACE(12) TO SDEL_NBR&MI
         STORE 0 TO SDEL_WT&MI
      ENDIF
      I = I + 1
   ENDDO
   IF .NOT. MNEW
      ** CHECK TO SEE IF I CAN PUT IN SOME DELIVERY DATES AND TIMES
      SELECT F
      I = 1
      DO WHILE I<= 8
         MI = STR(I,1)
         IF SCUS&MI = CUS&MI
            STORE DEL_DATE&MI TO SDEL_DATE&MI
            STORE DEL_TIME&MI TO SDEL_TIME&MI
            STORE DEL_AMPM&MI TO SDEL_AMPM&MI
            STORE DEL_NBR&MI  TO SDEL_NBR&MI
            STORE DEL_WT&MI   TO SDEL_WT&MI
         ENDIF
         IF I<=4
            IF SSUP&MI = SUP&MI
               STORE PU_DATE&MI TO SPU_DATE&MI
               STORE PU_TIME&MI TO SPU_TIME&MI
               STORE PU_AMPM&MI TO SPU_AMPM&MI
               STORE PU_NBR&MI  TO SPU_NBR&MI
            ENDIF
         ENDIF
         I = I + 1
      ENDDO
   ENDIF
   
   STORE 2 TO MACTION
   DO WHILE MACTION = 2
      MLINE = 6
      I = 1
      DO WHILE I<=4
         MI = STR(I,1)
         IF SSUP&MI <> SPACE(4)
            @ MLINE,28 GET SPU_DATE&MI
            @ MLINE+1,14 SAY '#:'
            @ MLINE+1,16 GET SPU_NBR&MI PICTURE '@!'
            @ MLINE+1,31 GET SPU_TIME&MI PICTURE '@R 99:99'
            @ MLINE+1,37 GET SPU_AMPM&MI PICTURE '@!'
         ENDIF
         MLINE = MLINE + 2
         I = I + 1
      ENDDO
      MLINE = 6
      I = 1
      DO WHILE I<=8
         MI = STR(I,1)
         IF SCUS&MI <> SPACE(4)
            @ MLINE,57 SAY 'GRS#:'
            @ MLINE,62 GET SDEL_WT&MI PICTURE '999999'
            @ MLINE,69 GET SDEL_DATE&MI
            @ MLINE+1,55 SAY '#:'
            @ MLINE+1,57 GET SDEL_NBR&MI PICTURE '@!'
            @ MLINE+1,72 GET SDEL_TIME&MI PICTURE '@R 99:99'
            @ MLINE+1,78 GET SDEL_AMPM&MI PICTURE '@!'
         ENDIF
         MLINE = MLINE + 2
         I = I + 1
      ENDDO
      
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit    3. Cancel/Exit'
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO      
   
   IF MACTION = 3
      LOOP
   ENDIF
   
   SELECT F
   IF MNEW
      DO FILELOCK
      APPEND BLANK
      REPLACE FRT_CODE WITH MFRT_CODE
      UNLOCK
   ENDIF
   
   DO RECLOCK
   REPLACE RATE     WITH MRATE
   REPLACE PALLETS  WITH MPALLETS
   REPLACE CONF_DATE WITH DATE()
   REPLACE SALES1   WITH MSALES1
   REPLACE SALES2   WITH MSALES2
   REPLACE SALES3   WITH MSALES3
   REPLACE SALES4   WITH MSALES4
   REPLACE SALES5   WITH MSALES5
   REPLACE SALES6   WITH MSALES6
   REPLACE SALES7   WITH MSALES7
   REPLACE SALES8   WITH MSALES8
   
   REPLACE PO1      WITH MPO1
   REPLACE PO2      WITH MPO2
   REPLACE PO3      WITH MPO3
   REPLACE PO4      WITH MPO4
   REPLACE PO5      WITH MPO5
   REPLACE PO6      WITH MPO6
   REPLACE PO7      WITH MPO7
   REPLACE PO8      WITH MPO8
   
   REPLACE SUFF1    WITH MSUFF1
   REPLACE SUFF2    WITH MSUFF2
   REPLACE SUFF3    WITH MSUFF3
   REPLACE SUFF4    WITH MSUFF4
   REPLACE SUFF5    WITH MSUFF5
   REPLACE SUFF6    WITH MSUFF6
   REPLACE SUFF7    WITH MSUFF7
   REPLACE SUFF8    WITH MSUFF8
   
   REPLACE SUP1     WITH SSUP1
   REPLACE SUP2     WITH SSUP2
   REPLACE SUP3     WITH SSUP3
   REPLACE SUP4     WITH SSUP4
   
   REPLACE CUS1     WITH SCUS1
   REPLACE CUS2     WITH SCUS2
   REPLACE CUS3     WITH SCUS3
   REPLACE CUS4     WITH SCUS4
   REPLACE CUS5     WITH SCUS5
   REPLACE CUS6     WITH SCUS6
   REPLACE CUS7     WITH SCUS7
   REPLACE CUS8     WITH SCUS8
   
   REPLACE PU_DATE1   WITH SPU_DATE1
   REPLACE PU_DATE2   WITH SPU_DATE2
   REPLACE PU_DATE3   WITH SPU_DATE3
   REPLACE PU_DATE4   WITH SPU_DATE4
   
   REPLACE PU_TIME1   WITH SPU_TIME1
   REPLACE PU_TIME2   WITH SPU_TIME2
   REPLACE PU_TIME3   WITH SPU_TIME3
   REPLACE PU_TIME4   WITH SPU_TIME4
   
   REPLACE PU_AMPM1   WITH SPU_AMPM1
   REPLACE PU_AMPM2   WITH SPU_AMPM2
   REPLACE PU_AMPM3   WITH SPU_AMPM3
   REPLACE PU_AMPM4   WITH SPU_AMPM4
   
   REPLACE PU_NBR1    WITH SPU_NBR1 
   REPLACE PU_NBR2    WITH SPU_NBR2 
   REPLACE PU_NBR3    WITH SPU_NBR3 
   REPLACE PU_NBR4    WITH SPU_NBR4 
   
   REPLACE DEL_DATE1  WITH SDEL_DATE1
   REPLACE DEL_DATE2  WITH SDEL_DATE2
   REPLACE DEL_DATE3  WITH SDEL_DATE3
   REPLACE DEL_DATE4  WITH SDEL_DATE4
   REPLACE DEL_DATE5  WITH SDEL_DATE5
   REPLACE DEL_DATE6  WITH SDEL_DATE6
   REPLACE DEL_DATE7  WITH SDEL_DATE7
   REPLACE DEL_DATE8  WITH SDEL_DATE8
   
   REPLACE DEL_TIME1  WITH SDEL_TIME1
   REPLACE DEL_TIME2  WITH SDEL_TIME2
   REPLACE DEL_TIME3  WITH SDEL_TIME3
   REPLACE DEL_TIME4  WITH SDEL_TIME4
   REPLACE DEL_TIME5  WITH SDEL_TIME5
   REPLACE DEL_TIME6  WITH SDEL_TIME6
   REPLACE DEL_TIME7  WITH SDEL_TIME7
   REPLACE DEL_TIME8  WITH SDEL_TIME8

   REPLACE DEL_WT1    WITH SDEL_WT1  
   REPLACE DEL_WT2    WITH SDEL_WT2  
   REPLACE DEL_WT3    WITH SDEL_WT3  
   REPLACE DEL_WT4    WITH SDEL_WT4  
   REPLACE DEL_WT5    WITH SDEL_WT5  
   REPLACE DEL_WT6    WITH SDEL_WT6  
   REPLACE DEL_WT7    WITH SDEL_WT7  
   REPLACE DEL_WT8    WITH SDEL_WT8  

   REPLACE DEL_AMPM1  WITH SDEL_AMPM1
   REPLACE DEL_AMPM2  WITH SDEL_AMPM2
   REPLACE DEL_AMPM3  WITH SDEL_AMPM3
   REPLACE DEL_AMPM4  WITH SDEL_AMPM4
   REPLACE DEL_AMPM5  WITH SDEL_AMPM5
   REPLACE DEL_AMPM6  WITH SDEL_AMPM6
   REPLACE DEL_AMPM7  WITH SDEL_AMPM7
   REPLACE DEL_AMPM8  WITH SDEL_AMPM8
   
   REPLACE DEL_NBR1   WITH SDEL_NBR1
   REPLACE DEL_NBR2   WITH SDEL_NBR2
   REPLACE DEL_NBR3   WITH SDEL_NBR3
   REPLACE DEL_NBR4   WITH SDEL_NBR4
   REPLACE DEL_NBR5   WITH SDEL_NBR5
   REPLACE DEL_NBR6   WITH SDEL_NBR6
   REPLACE DEL_NBR7   WITH SDEL_NBR7
   REPLACE DEL_NBR8   WITH SDEL_NBR8
   UNLOCK
   @ 24,0 clear
   @ 25,0 say 'Notes'
   @ 25,7  get mnote1
   @ 25,43 get mnote2
   READ
   DO RECLOCK
   REPLACE NOTE1 WITH MNOTE1
   REPLACE NOTE2 WITH MNOTE2
   UNLOCK
   @ 24,0 clear
   
   
   ** CALCULATE THE NUMBER OF PAGES
   MCOUNT = 0
   I = 1
   DO WHILE I<= 4
      MI = STR(I,1)
      IF SUP&MI <> SPACE(4)
         MCOUNT = MCOUNT + 1
      ENDIF
      I = I + 1
   ENDDO
   
   I = 1
   DO WHILE I<= 8
      MI = STR(I,1)
      IF CUS&MI <> SPACE(4)
         MCOUNT = MCOUNT + 1
      ENDIF
      I = I + 1
   ENDDO
   
   MTOT_PAGE = 0
   DO CASE
   CASE MCOUNT <=3
      MTOT_PAGE = 1
      IF MCOUNT = 3 .AND. (MNOTE1 <> SPACE(35) .OR. MNOTE2 <> SPACE(35))
         MTOT_PAGE = MTOT_PAGE + 1
      ENDIF
   CASE MCOUNT <=6
      MTOT_PAGE = 2
      IF MCOUNT = 6 .AND. (MNOTE1 <> SPACE(35) .OR. MNOTE2 <> SPACE(35))
         MTOT_PAGE = MTOT_PAGE + 1
      ENDIF
   CASE MCOUNT <=9
      MTOT_PAGE = 3
      IF MCOUNT = 9 .AND. (MNOTE1 <> SPACE(35) .OR. MNOTE2 <> SPACE(35))
         MTOT_PAGE = MTOT_PAGE + 1
      ENDIF
   OTHERWISE
      MTOT_PAGE = 4
      IF MCOUNT = 12 .AND. (MNOTE1 <> SPACE(35) .OR. MNOTE2 <> SPACE(35))
         MTOT_PAGE = MTOT_PAGE + 1
      ENDIF
   ENDCASE
   
   SET CONSOLE OFF
   IF FILE("C:\COMPINFO\PRINTERS.DBF")
      SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
   ELSE
      SET PRINT TO LPT3
   ENDIF
   SET DEVICE TO PRINT
   SET PRINT ON
   
   *** SELECT TRAY 2
   ?? CHR(27) + '&l1H'
   
   *** BOLDED PRINT
   ?? CHR(27) + '(s4B'
   
   MMARGIN = SPACE(08)
   MMARGIN1 = SPACE(05)
   
   MPAGE = 1
   ***SET PROC TO FRTCONF1
   SET CENTURY OFF
   
   MMAX_COUNT = MCOUNT
   MCOUNT = 1
   I = 1
   
   DO WHILE I<= 4
      MI = STR(I,1)
      IF F->SUP&MI = SPACE(4)
         I = I + 1
         LOOP
      ENDIF
      IF MCOUNT = 1 .OR. MCOUNT = 4 .OR. MCOUNT = 7 .OR. MCOUNT = 10
         DO CONFHEAD
      ENDIF
      SELECT D
      *** PRINT OUT SUPPLIER INFO
      SEEK F->SUP&MI
      ? MMARGIN + 'Pickup Location: ' + SPACE(15)
      ?? SPACE(3) + 'Load Dt: '
      STORE DOW(F->PU_DATE&MI) TO MDOW
      DO CASE
      CASE MDOW = 1
         ?? 'SUN'
      CASE MDOW = 2
         ?? 'MON'
      CASE MDOW = 3
         ?? 'TUE'
      CASE MDOW = 4
         ?? 'WED'
      CASE MDOW = 5
         ?? 'THU'
      CASE MDOW = 6
         ?? 'FRI'
      OTHERWISE
         ?? 'SAT'
      ENDCASE
      ??  SPACE(1)
      ?? DTOC(F->PU_DATE&MI) + SPACE(1)
      ?? TRANSFORM(F->PU_TIME&MI, '@R 99:99') + ' ' + F->PU_AMPM&MI + 'M'
      ? MMARGIN + NAME
      IF F->PU_NBR&MI <> SPACE(10)
         ?? SPACE(3) + 'Confirmation #: ' + F->PU_NBR&MI
      ENDIF
      ? MMARGIN + STREET
      STORE TRIM(CITY) + ', ' + STATE + SPACE(2) + ZIP TO MX
      ? MMARGIN + MX
      ?? SPACE(35 - LEN(MX))
      ?? 'Pickup '
      STORE FRT_PH    TO MFRT_PH
      STORE FRT_EMAIL TO MFRT_EMAIL

      *** GET THE PICKUP PO NUMBERS HERE
      STORE SPACE(9) TO MPRT_PO1, MPRT_PO2, MPRT_PO3, MPRT_PO4, MPRT_PO5, MPRT_PO6, MPRT_PO7, MPRT_PO8
      
      STORE 0 TO MLBS, MCASES
      MPO_PRT = 1
      MSEARCH = 1
      DO WHILE MSEARCH <= 8
         MSI = STR(MSEARCH,1)
         MXI = STR(MPO_PRT,1)
         
         SELECT B
         SEEK F->SALES&MSI + F->PO&MSI + F->SUFF&MSI
         IF .NOT. EOF()
            SELECT D
            SEEK B->SUP_CODE
            IF .NOT. EOF() .AND. PU_CODE <> SPACE(4)
               STORE PU_CODE TO MPU_SUP
            ELSE
               STORE B->SUP_CODE TO MPU_SUP
            ENDIF
         ELSE
            STORE SPACE(4) TO MPU_SUP
         ENDIF
         
         SELECT B
         IF .NOT. EOF() .AND. MPU_SUP = F->SUP&MI
            IF SALESMAN = '  '
               IF PO_SUFFIX <> ' '
                  STORE PO_NBR+'-'+PO_SUFFIX TO MPRT_PO&MXI
               ELSE
                  STORE PO_NBR TO MPRT_PO&MXI
               ENDIF
            ELSE
               MPRT_PO&MXI = SALESMAN + '-'
               IF PO_SUFFIX <> ' '
                  MPRT_PO&MXI =  MPRT_PO&MXI + PO_NBR + '-' + PO_SUFFIX
               ELSE
                  MPRT_PO&MXI =  MPRT_PO&MXI + PO_NBR
               ENDIF
            ENDIF
            MPO_PRT = MPO_PRT + 1
            SELECT C
            SEEK F->SALES&MSI + F->PO&MSI + F->SUFF&MSI
            DO WHILE .NOT. EOF() .AND. SALESMAN = F->SALES&MSI .AND. PO_NBR = F->PO&MSI .AND. PO_SUFFIX = F->SUFF&MSI
               MCASES = MCASES + QTY
               IF SUBSTR(PACKED,1,1) = 'B'
                  MLBS = MLBS + (VAL(SUBSTR(PACKED,2)) * LBS)
               ELSE
                  MLBS = MLBS + LBS
               ENDIF
               SKIP
            ENDDO
            SELECT B
         ENDIF
         MSEARCH = MSEARCH + 1
      ENDDO
      
      IF MPO_PRT <= 4
         IF MPRT_PO1 <> SPACE(9)
            ?? TRIM(MPRT_PO1)
         ENDIF
         IF MPRT_PO2 <> SPACE(9)
            ?? ', ' + TRIM(MPRT_PO2)
         ENDIF
         IF MPRT_PO3 <> SPACE(9)
            ?? ', ' + TRIM(MPRT_PO3)
         ENDIF
         IF MPRT_PO4 <> SPACE(9)
            ?? ', ' + TRIM(MPRT_PO4)
         ENDIF
         ?
      ELSE
         ?? TRIM(MPRT_PO1)
         ?? ', ' + TRIM(MPRT_PO2)
         ?? ', ' + TRIM(MPRT_PO3)
         ?? ', ' + TRIM(MPRT_PO4)
         ? MMARGIN + SPACE(35) + "PO#(s) "  
         IF MPRT_PO5 <> SPACE(9)
            ?? TRIM(MPRT_PO5)
         ENDIF
         IF MPRT_PO6 <> SPACE(9)
            ?? ', ' + TRIM(MPRT_PO6)
         ENDIF
         IF MPRT_PO7 <> SPACE(9)
            ?? ', ' + TRIM(MPRT_PO7)
         ENDIF
         IF MPRT_PO8 <> SPACE(9)
            ?? ', ' + TRIM(MPRT_PO8)
         ENDIF
      ENDIF
      SELECT D
      *** CALCULATE THE LBS TOO
      ?
      ? MMARGIN + '    Contact Ph#: ' + TRANSFORM(MFRT_PH, '@R 999-999-9999')
      ? MMARGIN + SPACE(35) + 'Net Lbs ' + TRANSFORM(MLBS, '99,999')
      ?? SPACE(3)
      ?? 'Cases: ' + TRANSFORM(MCASES, '9999')
      ? MMARGIN
      *** BOLDED PRINT
      ?? CHR(27) + '(s9B'
      ?? 'Cont Appt Email: ' + MFRT_EMAIL
      *** regular BOLDED PRINT
      ?? CHR(27) + '(s4B'
      ?
      ?
      I = I + 1
      MCOUNT = MCOUNT + 1
   ENDDO
   
   I = 1
   DO WHILE I<= 8
      MI = STR(I,1)
      IF F->CUS&MI = SPACE(4)
         I = I + 1
         LOOP
      ENDIF
      
      IF MCOUNT = 1 .OR. MCOUNT = 4 .OR. MCOUNT = 7 .OR. MCOUNT = 10
         DO CONFHEAD
      ENDIF
      
      SELECT E
      *** PRINT OUT CUSTOMER INFO
      SEEK F->CUS&MI
      ? MMARGIN + 'Delivery Location:' + SPACE(14)
      ?? SPACE(3) + 'Del Dt: '
      STORE DOW(F->DEL_DATE&MI) TO MDOW
      DO CASE
      CASE MDOW = 1
         ?? 'SUN'
      CASE MDOW = 2
         ?? 'MON'
      CASE MDOW = 3
         ?? 'TUE'
      CASE MDOW = 4
         ?? 'WED'
      CASE MDOW = 5
         ?? 'THU'
      CASE MDOW = 6
         ?? 'FRI'
      OTHERWISE  
         ?? 'SAT'
      ENDCASE
      
      ?? SPACE(1)
      ?? DTOC(F->DEL_DATE&MI) + SPACE(1)
      ?? TRANSFORM(F->DEL_TIME&MI, '@R 99:99') + ' ' + F->DEL_AMPM&MI + 'M'
      
      ? MMARGIN + NAME
      IF F->DEL_NBR&MI <> SPACE(10)
         ?? SPACE(3) + 'Confirmation #: ' + F->DEL_NBR&MI
      ENDIF
      
      *** GET THE DELIVERY AMERI/CUSTOMER PO NUMBERS HERE
      STORE SPACE(9) TO MPRT_PO1, MPRT_PO2, MPRT_PO3, MPRT_PO4, MPRT_PO5, MPRT_PO6
      STORE SPACE(15) TO MCUST_PO1, MCUST_PO2, MCUST_PO3, MCUST_PO4, MCUST_PO5, MCUST_PO6
      STORE 0 TO MLBS, MCASES
      MPO_PRT = 1
      MSEARCH = 1
      DO WHILE MSEARCH <= 6
         MSI = STR(MSEARCH,1)
         MXI = STR(MPO_PRT,1)
         SELECT B
         SEEK F->SALES&MSI + F->PO&MSI + F->SUFF&MSI
         IF .NOT. EOF() .AND. BUY_CODE = SCUS&MI
            IF SALESMAN = '  '
               IF PO_SUFFIX <> ' '
                  STORE PO_NBR+'-'+PO_SUFFIX TO MPRT_PO&MXI
               ELSE
                  STORE PO_NBR TO MPRT_PO&MXI
               ENDIF
            ELSE
               MPRT_PO&MXI = SALESMAN + '-'
               IF PO_SUFFIX <> ' '
                  MPRT_PO&MXI =  MPRT_PO&MXI + PO_NBR + '-' + PO_SUFFIX
               ELSE
                  MPRT_PO&MXI =  MPRT_PO&MXI + PO_NBR
               ENDIF
            ENDIF
            STORE BUYER_PO TO MCUST_PO&MXI
            
            MPO_PRT = MPO_PRT + 1
            SELECT C
            SEEK F->SALES&MSI + F->PO&MSI + F->SUFF&MSI
            DO WHILE .NOT. EOF() .AND. SALESMAN = F->SALES&MSI .AND. PO_NBR = F->PO&MSI .AND. PO_SUFFIX = F->SUFF&MSI
               MCASES = MCASES + QTY
               IF SUBSTR(PACKED,1,1) = 'B'
                  MLBS = MLBS + (VAL(SUBSTR(PACKED,2)) * LBS)
               ELSE
                  MLBS = MLBS + LBS
               ENDIF
               SKIP
            ENDDO
            SELECT B
         ENDIF
         MSEARCH = MSEARCH + 1
      ENDDO
      SELECT E 
      ? MMARGIN + STREET
      ?? SPACE(7) + 'Deliv  '
      
      ?? TRIM(MPRT_PO1)
      IF MCUST_PO1 <> SPACE(15)
         ?? ' / ' +  TRIM(MCUST_PO1)
      ENDIF
      STORE TRIM(CITY) + ', ' + STATE + '  ' + ZIP TO MX
      ? MMARGIN + MX
      ?? SPACE(35 - LEN(MX))
      ?? 'PO#(s) '
      IF MPRT_PO2 <> SPACE(9) .OR. MCUST_PO2 <> SPACE(15)
         ?? TRIM(MPRT_PO2)
         IF MCUST_PO2 <> SPACE(15)
            ?? ' / ' +  TRIM(MCUST_PO2)
         ENDIF
      ENDIF
      ? MMARGIN + SPACE(35)
      IF MPRT_PO3 <> SPACE(9) .OR. MCUST_PO3 <> SPACE(15)
         ?? '       '
         ?? TRIM(MPRT_PO3)
         IF MCUST_PO3 <> SPACE(15)
            ?? ' / ' +  TRIM(MCUST_PO3)
         ENDIF
      ENDIF
      SELECT E
      ? MMARGIN + 'Contact Ph#:   ' + TRANSFORM(FRT_PH, '@R 999-999-9999') + SPACE(8) 
      
      IF MPRT_PO4 <> SPACE(9) .OR. MCUST_PO4 <> SPACE(15)
         ?? '       '
         ?? TRIM(MPRT_PO4)
         IF MCUST_PO4 <> SPACE(15)
            ?? ' / ' +  TRIM(MCUST_PO4)
         ENDIF
      ENDIF
      IF DEL_PH = SPACE(10)
         ?
      ELSE
         ? MMARGIN + 'Delv/Appt Ph#: ' + TRANSFORM(DEL_PH, '@R 999-999-9999') + SPACE(8)
      ENDIF
      
      IF MPRT_PO5 <> SPACE(9) .OR. MCUST_PO5 <> SPACE(15)
         ?? '       '
         ?? TRIM(MPRT_PO5)
         IF MCUST_PO5 <> SPACE(15)
            ?? ' / ' +  TRIM(MCUST_PO5)
         ENDIF
      ENDIF
      
      IF DEL_MAIL = SPACE(28)
         ? MMARGIN + SPACE(35)
      ELSE
         ? MMARGIN + 'Email: ' + DEL_MAIL
      ENDIF
      
      IF MPRT_PO6 = SPACE(9) .AND. MCUST_PO6 = SPACE(15)
         IF F->DEL_WT&MI <> 0
            ??  'Gross Lbs' + TRANSFORM(F->DEL_WT&MI, '999,999') + space(2)
         ELSE
            ??  'Net Lbs ' + TRANSFORM(MLBS, '99,999') + space(4)
         ENDIF
         ?? 'Cases: ' + TRANSFORM(MCASES, '9999')
         IF DEL_TIME = SPACE(12)
            ?
         ELSE
            ? MMARGIN + 'Receiving Hours: ' + DEL_TIME
         ENDIF
      ELSE
         ?? TRIM(MPRT_PO6)
         IF MCUST_PO6 <> SPACE(15)
            ?? ' / ' +  TRIM(MCUST_PO6)
         ENDIF
         IF DEL_TIME = SPACE(12)
            ? MMARGIN + SPACE(35)
         ELSE
            ? MMARGIN + 'Receiving Hours: ' + DEL_TIME + SPACE(8)
         ENDIF
         IF F->DEL_WT&MI <> 0
            ??  'Gross Lbs' + TRANSFORM(F->DEL_WT&MI, '999,999') + space(2)
         ELSE
            ??  'Net Lbs ' + TRANSFORM(MLBS, '99,999') + space(4)
         ENDIF
         ?? 'Cases: ' + TRANSFORM(MCASES, '9999')
      ENDIF
      ?
      ?
      I = I + 1
      MCOUNT = MCOUNT + 1
   ENDDO
   IF MNOTE1 <> SPACE(35) .or. MNOTE2 <> SPACE(35)

      IF MCOUNT = 4 .OR. MCOUNT = 7 .OR. MCOUNT = 10
         DO CONFHEAD
      ENDIF
      ?
      ?

      IF MNOTE1 <> SPACE(35)

         *** FONT ARIAL BOLD
         ?? CHR(27) + '(s1p10v0s3b16602T'
         
         *** POINT HEIGHT 16 - DEFAULT IS 12
         ?? CHR(27) + '(s16V'

         ? SPACE(22) + MNOTE1
         ?
      ENDIF
      
      IF MNOTE2 <> SPACE(35)

         *** FONT ARIAL BOLD
         ?? CHR(27) + '(s1p10v0s3b16602T'
         
         *** POINT HEIGHT 16 - DEFAULT IS 12
         ?? CHR(27) + '(s16V'

         ? SPACE(22) + MNOTE2

      ENDIF

   ENDIF
   
   SET CENTURY ON
   EJECT
   *** AUTO SELECT THE TRAY  
   ?? CHR(27) + '&l7H'

   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER2 <> 'DONOTPRINT'
      RUN &MPRINTIT2
   ENDIF
   
ENDDO
CLOSE DATA

QUIT

PROCEDURE CONFHEAD
IF MPAGE <> 1
   EJECT
ENDIF
**? MMARGIN1 + SPACE(54) + '**********************'
?
? 
?
? MMARGIN1 + SPACE(50) + 'roseh@americhicken.com'
*?
*?
? 

? MMARGIN1 + 'Date: ' + DTOC(DATE())
MPRT = MAREA1+MPHONE1
?? SPACE(35) + 'Ph:  ' + TRANSFORM(MPRT, '@R 999-999-9999')
? MMARGIN1 + 'Page ' + STR(MPAGE,1) + ' of ' + STR(MTOT_PAGE,1)
MPRT = MAREA2+MPHONE2
?? SPACE(38) +  'Fax: ' + + TRANSFORM(MPRT, '@R 999-999-9999')
?

? MMARGIN + 'To:   ' +  MNAME
?? SPACE(1) + 'Freight Amt: ' + TRANSFORM(MRATE, '9999.99')

? MMARGIN + 'Attn: ' +  MFRT_CONT
? MMARGIN + SPACE(39)
?? 'Pallet Exchange: ' + 'Yes '
IF MPALLETS = 0
   ?? SPACE(2)
ELSE
   ?? STR(MPALLETS,2)
ENDIF
?? '  No '
? MMARGIN1 + 'From: ' + MLOCAL + SPACE(19)

?
?
?
?
?
?
*?
MPAGE = MPAGE + 1
RETURN
*Formatted by: ToolBox Ver. 1.2  on 3/2/17 at 1:25 PM.
