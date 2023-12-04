******************
* Program.: FRT_SHIP.PRG
* Author..: Grace Keller
* Date....: 05/15/06
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXBASE
* Notes...: View all Freight Per Shipment - all PO's
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

SELECT C
DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.

SELECT B
DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.

MPO_FD = .F.
STORE 1 TO MACTION
MPO_SEL = .T.
DO WHILE MPO_SEL
   STORE SPACE(2) TO MSALESMAN
   STORE SPACE(4) TO MPO_NBR
   STORE SPACE(1) TO MPO_SUFFIX
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - View Freight/Shipments'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 to 24,79
   @  4,1 SAY 'Select PO to view all Freight:   -    -'
   @ 4,32 GET MSALESMAN PICTURE '##'
   @ 4,35 GET MPO_NBR PICTURE '####'
   @ 4,40 GET MPO_SUFFIX PICTURE '@!'
   
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
   READ
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   
   IF MACTION = 3 .OR. MPO_NBR = SPACE(4)
      MPO_SEL = .F.
      LOOP
   ENDIF
   
   IF MACTION = 2
      LOOP
   ENDIF
   @ 24,0 CLEAR

   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue'

   SELECT B
   SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
   IF EOF()
      @ 24,0 CLEAR
      MWAIT = ' '
      @ 24,1 SAY 'Selected PO Not on File - Please Return to Reenter ' get mwait
      READ
      MACTION = 2
      @ 24,1 CLEAR
      LOOP
   ENDIF
   STORE FRT_CODE1 TO MFRT_CODE
   STORE TOT_LBS  TO MTOT_LBS
   STORE FRT_AMT1+FRT1_ADJ1+FRT1_ADJ2+FRT_PALL TO MTOT_FRT
   
   STORE REF_PO1  TO MREF_PO2
   STORE REF_PO2  TO MREF_PO3
   STORE REF_PO3  TO MREF_PO4
   STORE REF_PO4  TO MREF_PO5
   STORE REF_PO5  TO MREF_PO6
   STORE REF_PO6  TO MREF_PO7
   
   STORE MSALESMAN TO MSALES1
   STORE MPO_NBR   TO MPO1
   STORE MPO_SUFFIX TO MSUFF1
   SELECT E
   DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
   
   SELECT D
   DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
   
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
   
   SEEK MFRT_CODE
   IF EOF()
      STORE 'FREIGHT NOT ON FILE' TO MFRT_NAME
      STORE SPACE(20) TO MCITY
      STORE SPACE(2)  TO MSTATE
      STORE SPACE(5)  TO MZIP
   ELSE
      STORE NAME TO MFRT_NAME
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
      STORE ZIP   TO MZIP
   ENDIF
   
   SELECT B
   I = 2
   DO WHILE I<= 7
      MI = STR(I,1)
      IF MREF_PO&MI = SPACE(9)
         MSALES&MI = SPACE(2)
         MPO&MI    = SPACE(4)
         MSUFF&MI  = SPACE(1)
      ELSE
         IF SUBSTR(MREF_PO&MI,3) = '-'
            MSALES&MI = SUBSTR(MREF_PO&MI,1,2)
            MPO&MI    = SUBSTR(MREF_PO&MI,4,4)
            MSUFF&MI  = SUBSTR(MREF_PO&MI,9,1)
         ELSE
            MSALES&MI = SPACE(2)
            MPO&MI    = SUBSTR(MREF_PO&MI,1,4)
            MSUFF&MI  = SUBSTR(MREF_PO&MI,6,1)
         ENDIF
         SEEK MSALES&MI + MPO&MI + MSUFF&MI
         IF .NOT. EOF()
            MTOT_LBS = MTOT_LBS + TOT_LBS
            MTOT_FRT = MTOT_FRT + FRT_AMT1+FRT1_ADJ1+FRT1_ADJ2+FRT_PALL 
         ENDIF
      ENDIF
      I = I + 1
   ENDDO
   
   @ 6,1  SAY 'Freight Carrier:'
   @ 7,1  SAY '        Tot Amt:'
   @ 8,1  SAY '        Tot Lbs:'
   @ 6,18 SAY  MFRT_NAME
   @ 6,52 SAY  TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
   @ 7,18 SAY  MTOT_FRT PICTURE '999,999.99'
   @ 8,18 SAY  MTOT_LBS PICTURE '999,999.99'

   @ 9,1  say 'Sel'
   @ 10,1 say 'Vw   Orders    Ship Lbs    Freight  Shipped From'
   @ 10,59 say 'Shipped To:'
   @ 24,13 SAY '1. Continue'
   
   MLINE = 12
   I = 1
   DO WHILE I<= 7
      MI = STR(I,1)
      IF MPO&MI = SPACE(4)
         I = I + 1
         LOOP
      ENDIF
      @ MLINE,4 SAY MSALES&MI
      IF MSALES&MI <> SPACE(2)
         @ MLINE,6 SAY '-'
      ENDIF
      @ MLINE,7 SAY MPO&MI
      IF MSUFF&MI <> ' '
         @ MLINE,11 SAY '-' + MSUFF&MI
      ENDIF
      SELECT B
      SEEK MSALES&MI + MPO&MI + MSUFF&MI
      IF .NOT. EOF()
         @ MLINE,14 SAY TOT_LBS PICTURE '999,999.99'
         @ MLINE,26 SAY FRT_AMT1+FRT1_ADJ1+FRT1_ADJ2+FRT_PALL PICTURE '99,999.99'
         SELECT D
         SEEK B->SUP_CODE
         IF EOF()
            @ MLINE,37 SAY 'UNKNOWN SHIP FROM'
         ELSE
            STORE SUBSTR(CITY,1,16) TO MCITY
            @ MLINE,37 SAY TRIM(MCITY) + ',' + STATE
         ENDIF
         SELECT E         
         SEEK B->BUY_CODE
         IF EOF()
            @ MLINE,59 SAY 'UNKNOWN SHIP TO'
         ELSE
            STORE SUBSTR(CITY,1,16) TO MCITY
            @ MLINE,59 SAY TRIM(MCITY) + ',' + STATE
         ENDIF
         SELECT B
      ENDIF
      MLINE = MLINE + 1
      I = I + 1
   ENDDO
   SELECT A
   USE 
   SELECT D
   USE
   SELECT E
   USE
   
   MVWLINE = 12
   MVWI = 1
   DO WHILE MVWI <= 7
      MI = STR(MVWI,1)
      IF MPO&MI <> SPACE(4)
         MSELECT = ' '
         @ MVWLINE,2 GET MSELECT PICTURE '@!'
         READ
         IF MSELECT = 'X'
            
            SELECT B
            SEEK MSALES&MI + MPO&MI + MSUFF&MI
            
            SAVE SCREEN TO MVW_SCREEN
            MVIEW = .T.
            DO POVWMAIN
            RESTORE SCREEN FROM MVW_SCREEN
         ENDIF
         @ MVWLINE,2 SAY ' '
      ENDIF
      MVWLINE = MVWLINE + 1
      MVWI = MVWI + 1
   ENDDO
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue'
   @ 24,9 GET MACTION PICTURE '9' RANGE 1,1
   READ
ENDDO

CLOSE DATA

RETURN
* EOF: FRT_SHIP.PRG


*Formatted by: ToolBox Ver. 1.2  on 5/15/6 at 9:52 AM.
