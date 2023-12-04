*************
* Program.: CONFIRM1.PRG
* Author..: Grace Keller
* Date....: 10/26/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINT ORDER CONFIRMATION
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
RELEASE MNET_DAYS, MLET_CRD, MGUARAN, MACTIVE, MBEG_DATE, MEND_DATE
RELEASE MPAY_NAME, MPAY_STRT, MPAY_CITY, MPAY_STATE, MPAY_ZIP, MPAY_ZIP4, MPAY_AREA, MPAY_PHONE

MDEL_FILE = "DEL C:\COMPINFO\C*.TXT"
RUN &MDEL_FILE

MTITLE = ' - PRINT ORDER CONFIRMATIONS/MARGIN SUMMARY'
STORE 2 TO MACTION

DO WHILE MACTION = 2
   STORE ' ' TO MTYPE1, MTYPE2, MTYPE3
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - ORDER CONFIRMATIONS'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 to 24,79
   
   @ 4,1 SAY "SELECT WITH AN 'X' TYPE OF CONFIRMATION TO PRINT"
   @ 6,1 SAY ' Supplier Confirmation:' GET MTYPE1 PICTURE '@!' VALID(MTYPE1 = 'X' .OR. MTYPE1 = ' ')
   @ 7,1 SAY ' Customer Confirmation:' GET MTYPE2 PICTURE '@!' VALID(MTYPE2 = 'X' .OR. MTYPE2 = ' ')
   @ 7,30 say '( and - Inbound Freezer - Non Transfer)'
   @ 8,1 SAY '  Freezer Confirmation:' GET MTYPE3 PICTURE '@!' VALID(MTYPE3 = 'X' .OR. MTYPE3 = ' ')
   @ 8,30 say '( Inbound Freezer Transfer / Outbound Release)'
   
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue    2. Edit    3. Cancel'
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   
   IF MACTION = 2
      LOOP
   ENDIF
   IF MTYPE1 = ' ' .AND. MTYPE2 = ' ' .AND. MTYPE3 = ' '
      MACTION = 3
      LOOP
   ENDIF
   
   SELECT B
   DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
   STORE SPACE(4) TO MPROD
   
   DO CASE
      *** SUPPLIER
   CASE MTYPE1 = 'X'
      SELECT A
      STORE SUP_CODE TO MSUP_CODE
      STORE RSUPCODE TO MRSUPCODE
      
      ***************************
      ** GET SUPPLIER INFORMATION
      ***************************
      STORE SPACE(30) TO MSUP_NAME, XSUP_NAME
      STORE SPACE(30) TO MSUP_STRT
      STORE SPACE(30) TO MSUP_CITYST
      STORE SPACE(13) TO MSUP_FAX, MSUP_PHONE
      STORE SPACE(30) TO MCONTACT
      STORE SPACE(30) TO MTO
      IF A->PU_LOC = 'TRANSFER'
         STORE A->BUY_CODE TO MBUY_CODE
         SELECT E
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         SEEK MBUY_CODE
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,30) TO MBUY_NAME
            STORE STREET + SPACE(2) TO MBUY_STRT
            IF ZIP4 = SPACE(4)
               STORE ZIP + SPACE(5) TO MBUY_ZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MBUY_ZIP 
            ENDIF
            STORE TRIM(CITY) + ', ' + STATE  + '  ' + MBUY_ZIP TO MBUY_CITYST
            STORE LEN(MSUP_CITYST) TO MLEN
            IF MLEN < 30
               STORE MSUP_CITYST + SPACE(30-MLEN) TO MBUY_CITYST
            ELSE
               IF MLEN > 30
                  STORE SUBSTR(MSUP_CITYST,1,30) TO MBUY_CITYST
               ENDIF
            ENDIF
         ELSE
            STORE SPACE(30) TO MBUY_NAME
            STORE SPACE(30) TO MBUY_STRT
            STORE SPACE(30) TO MBUY_CITYST
         ENDIF
      ELSE
      ENDIF
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
      SEEK MSUP_CODE
      IF .NOT. EOF()
         STORE CONT_FAX TO MFAX
         STORE SUBSTR(CONT_NAME,1,30) TO MTO
         STORE SUBSTR(NAME,1,30) TO XSUP_NAME, MSUP_NAME
         STORE FAX TO MSUP_FAX
         STORE AREA_CODE + PHONE TO MSUP_PHONE
         STORE STREET + SPACE(2) TO MSUP_STRT
         IF ZIP4 = SPACE(4)
            STORE ZIP + SPACE(5) TO MSUP_ZIP
         ELSE
            STORE ZIP + '-' + ZIP4 TO MSUP_ZIP 
         ENDIF
         STORE TRIM(CITY) + ', ' + STATE  + '  ' + MSUP_ZIP TO MSUP_CITYST
         STORE LEN(MSUP_CITYST) TO MLEN
         IF MLEN < 30
            STORE MSUP_CITYST + SPACE(30-MLEN) TO MSUP_CITYST
         ELSE
            IF MLEN > 30
               STORE SUBSTR(MSUP_CITYST,1,30) TO MSUP_CITYST
            ENDIF
         ENDIF
      ELSE
         STORE SPACE(30) TO MSUP_NAME, XSUP_NAME
         STORE SPACE(30) TO MSUP_STRT
         STORE SPACE(30) TO MSUP_CITYST
         STORE SPACE(13) TO MSUP_FAX, MSUP_PHONE
         STORE SPACE(30) TO MCONTACT
      ENDIF
      STORE SPACE(13) TO MPHONE
      DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
      SEEK MRSUPCODE
      IF .NOT. EOF()
         STORE SUBSTR(NAME,1,30) TO MREM_NAME       
         STORE STREET +SPACE(2) TO MREM_STRT  
         **STORE SUBSTR(NOTE,1,30) TO MTO
         IF ZIP4 = SPACE(4)
            STORE ZIP + SPACE(5) TO MREM_ZIP
         ELSE
            STORE ZIP + '-' + ZIP4 TO MREM_ZIP 
         ENDIF
         STORE TRIM(CITY) + ', ' + STATE  + '  ' + MREM_ZIP TO MREM_CITYST
         STORE LEN(MREM_CITYST) TO MLEN
         IF MLEN < 30
            STORE MREM_CITYST + SPACE(30-MLEN) TO MREM_CITYST
         ELSE
            IF MLEN > 30
               STORE SUBSTR(MREM_CITYST,1,30) TO MREM_CITYST
            ENDIF
         ENDIF
         STORE AREA_CODE + PHONE TO MPHONE
         ***STORE FAX  TO MFAX
      ELSE
         STORE SPACE(30) TO MREM_NAME
         STORE SPACE(30) TO MREM_STRT
         STORE SPACE(30) TO MREM_CITYST
      ENDIF
      
      STORE 'CUSTOMER SERVICE' + SPACE(14) TO MFROM
      ***STORE SPACE(30) TO MTO, MCONTACT
      STORE SPACE(10) TO MFOB, MPREPAID
      STORE A->SHIP_DATE TO MSHIP_DATE
      STORE A->ORD_DATE TO MORD_DATE
      IF MRSUPCODE = 'INVN'
         STORE 'N' TO MSAMP_RQST
      ELSE
         STORE 'N' TO MSAMP_RQST
      ENDIF
      IF A->PU_LOC = 'TRANSFER'
         STORE SPACE(30) TO MNOTE, MNOTE2, MNOTE3
      ELSE
         STORE 'CUST PO#: ' + A->BUYER_PO + SPACE(5) TO MNOTE
         STORE 'DRIVER KNOWS DESTINATION' + SPACE(6) TO MNOTE3
         SELECT E
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         SEEK A->BUY_CODE
         STORE ZIP TO MBUY_ZIP
         STORE TRIM(CITY) + ', ' + STATE  + '  ' + MBUY_ZIP TO MBUY_CITYST
         IF LEN(MBUY_CITYST) < 30
            MDIFF = 30 - LEN(MBUY_CITYST) 
            MNOTE2 = MBUY_CITYST + SPACE(MDIFF)
         ELSE
            STORE SUBSTR(MBUY_CITYST,1,30) TO MNOTE2
         ENDIF
      ENDIF      
      **STORE SPACE(15) TO MSUP_PHONE
      IF A->PU_LOC = 'TRANSFER'
         @ 10,1 say '   FROM:                                TRNSFER'
         @ 11,1 SAY '     TO:                                    LOC'
         @ 12,1 SAY '   WITH:'
         @ 13,1 SAY '  PHONE:'                                        
         @ 14,1 SAY '    FAX:'                                         
         
         @ 16,1 SAY '   PO #:   -    -'
         @ 17,1 SAY ' ORD DT:'
         @ 18,1 SAY 'TRAN DT:'
         @ 20,1 SAY '  NOTES:'
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 10,10 GET MFROM PICTURE '@!'
            @ 11,10 GET MTO   PICTURE '@!'
            @ 12,10 GET MREM_NAME PICTURE '@!'
            @ 13,10 GET MPHONE PICTURE '@R ###-###-####'
            @ 14,10 GET MFAX   PICTURE '@R ###-###-####'
            @ 16,10 GET MSALESMAN
            @ 16,13 GET MPO_NBR
            @ 16,18 GET MPO_SUFFIX PICTURE '@!'
            @ 17,10 GET MORD_DATE
            @ 18,10 GET MSHIP_DATE
            @ 20,10 GET MNOTE PICTURE '@!'
            @ 21,10 GET MNOTE2 PICTURE '@!'
            @ 22,10 GET MNOTE3 PICTURE '@!'
            @ 10,49 GET MBUY_NAME PICTURE '@!'
            @ 11,49 GET MBUY_STRT PICTURE '@!'
            @ 12,49 GET MBUY_CITYST PICTURE '@!'
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
            @ 24,13 SAY '1. Continue    2. Edit    3. Cancel/Exit'
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
            
         ENDDO      
      ELSE
         @ 10,1 say '   FROM:                               SHIPPED'
         @ 11,1 SAY '     TO:                                  FROM:'
         @ 12,1 SAY '   WITH:'
         @ 13,1 SAY '  PHONE:                                 PHONE:'
         @ 14,1 SAY '    FAX:                               CONTACT:'
         
         @ 16,1 SAY '   PO #:   -    -'
         @ 17,1 SAY ' ORD DT:'
         @ 18,1 SAY 'LOAD DT:                  PRINT SAMPLE REQUEST:'
         @ 20,1 SAY '  NOTES:'
         
         *** CHANGES TO MAKE REMIT TO LOOK LIKE SHIPPED FROM
         STORE XSUP_NAME  TO MREM_NAME
         STORE MSUP_PHONE TO MPHONE
         ****STORE MSUP_FAX   TO MFAX
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 10,10 GET MFROM PICTURE '@!'
            @ 11,10 GET MTO   PICTURE '@!'
            @ 12,10 GET MREM_NAME PICTURE '@!'
            @ 13,10 GET MPHONE PICTURE '@R ###-###-####'
            @ 14,10 GET MFAX   PICTURE '@R ###-###-####'
            @ 16,10 GET MSALESMAN
            @ 16,13 GET MPO_NBR
            @ 16,18 GET MPO_SUFFIX PICTURE '@!'
            @ 17,10 GET MORD_DATE
            @ 18,10 GET MSHIP_DATE
            @ 20,10 GET MNOTE PICTURE '@!'
            @ 21,10 GET MNOTE2 PICTURE '@!'
            @ 22,10 GET MNOTE3 PICTURE '@!'
            @ 10,49 GET MSUP_NAME PICTURE '@!'
            @ 11,49 GET MSUP_STRT PICTURE '@!'
            @ 12,49 GET MSUP_CITYST PICTURE '@!'
            @ 13,49 GET MSUP_PHONE   PICTURE '@R ###-###-####'
            @ 14,49 GET MCONTACT
            IF MRSUPCODE <> 'INVN'
               @ 18,49 GET MSAMP_RQST PICTURE '@!' VALID(MSAMP_RQST = 'Y' .OR. MSAMP_RQST = 'N')
            ENDIF
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
            @ 24,13 SAY '1. Continue    2. Edit    3. Cancel/Exit'
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
            READ               
            
         ENDDO      
      ENDIF
      IF MACTION = 3
         LOOP
      ENDIF
      
      
   CASE MTYPE2 = 'X'
      *** CUSTOMER CONFIRMATION -OR- FREEZER INBOUND CONFIRMATION
      DO CASE
      CASE A->BBUYCODE = 'INVN'
         *** INBOUND FREEZER CONFIRMATION
         SELECT A
         STORE BUY_CODE TO MBUY_CODE
         STORE BBUYCODE TO MBBUYCODE
         STORE SPACE(42) TO MATTN, MATTN2
         STORE SPACE(30) TO MNOTE, MNOTE2
         STORE SPACE(13) TO MFAX
         STORE SPACE(13) TO MPHONE
         STORE 0 TO MALL_AMT
         IF CUS_REAS1 = 'PICKUP ALL'
            STORE CUS_AMT1  * -1 TO MALL_AMT
         ENDIF
         
         ***************************
         ** GET CUSTOMER INFORMATION
         ***************************
         SELECT E
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         SEEK MBUY_CODE
         IF .NOT. EOF()
            STORE NAME TO MCUS_NAME       
            STORE STREET + SPACE(2) + SPACE(2) TO MCUS_STRT  
            IF ZIP4 = SPACE(4)
               STORE ZIP + SPACE(5) TO MCUS_ZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MCUS_ZIP 
            ENDIF
            STORE TRIM(CITY) + ', ' + STATE  + '  ' + MCUS_ZIP TO MCUS_CITYST
            STORE LEN(MCUS_CITYST) TO MLEN
            IF MLEN < 32
               STORE MCUS_CITYST + SPACE(32-MLEN) TO MCUS_CITYST
            ELSE
               IF MLEN > 32
                  STORE SUBSTR(MCUS_CITYST,1,32) TO MCUS_CITYST
               ENDIF
            ENDIF
            STORE CONT_FAX TO MFAX
            STORE CONT_PH  TO MPHONE
            STORE CONT_NAME TO MATTN
            STORE CONT_NAM2 TO MATTN2
         ELSE
            STORE SPACE(32) TO MCUS_NAME
            STORE SPACE(32) TO MCUS_STRT
            STORE SPACE(32) TO MCUS_CITYST
         ENDIF
         
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         SEEK MBBUYCODE                
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,30) TO MBIL_NAME       
            **STORE SUBSTR(NOTE,1,32) TO MATTN
            STORE STREET +SPACE(2) TO MBIL_STRT
            IF ZIP4 = SPACE(4)
               STORE ZIP + SPACE(5) TO MBIL_ZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MBIL_ZIP 
            ENDIF
            STORE TRIM(CITY) + ', ' + STATE  + '  ' + MBIL_ZIP TO MBIL_CITYST
            STORE LEN(MBIL_CITYST) TO MLEN
            IF MLEN < 30
               STORE MBIL_CITYST + SPACE(30-MLEN) TO MBIL_CITYST
            ELSE
               IF MLEN > 30
                  STORE SUBSTR(MBIL_CITYST,1,30) TO MBIL_CITYST
               ENDIF
            ENDIF
            *** STORE AREA_CODE + PHONE TO MPHONE
            *** STORE FAX  TO MFAX
         ELSE
            STORE SPACE(30) TO MBIL_NAME
            STORE SPACE(30) TO MBIL_STRT
            STORE SPACE(30) TO MBIL_CITYST
         ENDIF
         
         STORE SPACE(30) TO MSUP_NAME
         STORE SPACE(30) TO MSUP_CITYST
         STORE SPACE(10) TO MSUP_PHN
         **IF A->FRT_CODE1 = 'NONE'
         DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
         SEEK A->SUP_CODE
         IF .NOT. EOF()
            IF NAME = 'RANDALL COLD STORAGE'
               STORE SUBSTR(STREET,1,30) TO MSUP_NAME
            ELSE
               STORE SUBSTR(NAME,1,30) TO MSUP_NAME
            ENDIF
            STORE AREA_CODE + PHONE TO MSUP_PHN
            IF ZIP4 = SPACE(4)
               STORE ZIP + SPACE(5) TO MSUP_ZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MSUP_ZIP 
            ENDIF
            STORE TRIM(CITY) + ', ' + STATE  + '  ' + MSUP_ZIP TO MSUP_CITYST
            STORE LEN(MSUP_CITYST) TO MLEN
            IF MLEN < 30
               STORE MSUP_CITYST + SPACE(30-MLEN) TO MSUP_CITYST
            ELSE
               IF MLEN > 30
                  STORE SUBSTR(MSUP_CITYST,1,30) TO MSUP_CITYST
               ENDIF
            ENDIF
         ENDIF
         **ENDIF         
         
         STORE SPACE(30) TO MCOM_NAME
         STORE SPACE(32) TO MCC_NAME
         DO FOX_USE WITH "&mdbfloc.compayee INDEX &mdbfloc.com_code", .F.
         IF A->COM_CODE <> SPACE(2)
            SEEK A->COM_CODE
            IF .NOT. EOF() .AND. PRT_CONF <> 'N'
               STORE SUBSTR(NAME,1,25) TO MCOM_NAME
               STORE CC_NAME           TO MCC_NAME
            ENDIF
         ENDIF
         
         STORE MCUS_NAME TO MTO
         STORE 'CUSTOMER SERVICE' + SPACE(14) TO MFROM
         STORE A->SHIP_DATE TO MSHIP_DATE
         STORE A->ORD_DATE TO MORD_DATE
         IF A->PU_LOC = 'CPU'
            STORE A->SHIP_DATE TO MDEL_REQD
         ELSE
            IF A->FRT_CODE1 <> 'NONE'
               STORE A->DEL_REQD TO MDEL_REQD
            ELSE
               STORE CTOD('') TO MDEL_REQD
            ENDIF
         ENDIF
         STORE A->BUYER_PO TO MBUYER_PO
         STORE MSALESMAN TO RSALESMAN
         STORE MPO_NBR   TO RPO_NBR
         STORE MPO_SUFFIX TO RPO_SUFFIX
         
         @ 10,1 say 'ATTN/TO:                                  SHP'

         @ 11,1 SAY '                                          ADR '

         @ 12,1 SAY '        '

         @ 13,1 SAY '  PHONE:                                       '

         @ 14,1 SAY '    FAX:                                 PROD'

         @ 15,1 SAY '   FROM:                                 ORIG'

         @ 16,1 SAY 'CUST PO:'
         @ 17,1 SAY 'AMERI #:   -    -'
         @ 18,1 SAY 'RELEASE:   -    -'
         @ 19,1 SAY ' ORD DT:'
         IF A->PU_LOC = 'CPU'
            @ 20,1 SAY 'PKUP DT:'
         ELSE
            @ 20,1 SAY 'DELV DT:'
         ENDIF
         @ 21,1 SAY '  NOTES:'
         
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 10,10 GET MTO PICTURE '@!'
            @ 11,1  GET MATTN   PICTURE '@!'
            @ 12,1  GET MATTN2  PICTURE '@!'
            @ 13,10 GET MPHONE PICTURE '@R ###-###-####'
            @ 14,10 GET MFAX   PICTURE '@R ###-###-####'
            @ 15,10 GET MFROM  PICTURE '@!'

            @ 16,10 GET MBUYER_PO PICTURE '@!'
            @ 17,10 GET MSALESMAN
            @ 17,13 GET MPO_NBR
            @ 17,18 GET MPO_SUFFIX PICTURE '@!'
            @ 18,10 GET RSALESMAN
            @ 18,13 GET RPO_NBR
            @ 18,18 GET RPO_SUFFIX
            @ 19,10 GET MORD_DATE
            @ 20,10 GET MDEL_REQD
            @ 21,10 GET MNOTE PICTURE '@!'
            @ 22,10 GET MNOTE2 PICTURE '@!'
            @ 10,47 GET MCUS_STRT PICTURE '@!'
            @ 11,47 GET MCUS_CITYST PICTURE '@!'
            
            @ 14,47 GET MSUP_NAME PICTURE '@!'
            @ 15,47 GET MSUP_CITYST PICTURE '@!'
            
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
         
      OTHERWISE
         SELECT A
         STORE BUY_CODE TO MBUY_CODE
         STORE BBUYCODE TO MBBUYCODE
         STORE SPACE(42) TO MATTN, MATTN2
         STORE SPACE(30) TO MNOTE, MNOTE2
         STORE SPACE(13) TO MFAX
         STORE SPACE(13) TO MPHONE
         STORE 0 TO MALL_AMT
         IF CUS_REAS1 = 'PICKUP ALL'
            STORE CUS_AMT1  * -1 TO MALL_AMT
         ENDIF
         
         ***************************
         ** GET CUSTOMER INFORMATION
         ***************************
         SELECT E
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         SEEK MBUY_CODE
         IF .NOT. EOF()
            STORE NAME  TO MCUS_NAME       
            STORE STREET + SPACE(2) + SPACE(2) TO MCUS_STRT  
            IF ZIP4 = SPACE(4)
               STORE ZIP + SPACE(5) TO MCUS_ZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MCUS_ZIP 
            ENDIF
            STORE TRIM(CITY) + ', ' + STATE  + '  ' + MCUS_ZIP TO MCUS_CITYST
            STORE LEN(MCUS_CITYST) TO MLEN
            IF MLEN < 32
               STORE MCUS_CITYST + SPACE(32-MLEN) TO MCUS_CITYST
            ELSE
               IF MLEN > 32
                  STORE SUBSTR(MCUS_CITYST,1,32) TO MCUS_CITYST
               ENDIF
            ENDIF
            STORE CONT_FAX TO MFAX
            STORE CONT_PH  TO MPHONE
            STORE CONT_NAME TO MATTN
            STORE CONT_NAM2 TO MATTN2
         ELSE
            STORE SPACE(32) TO MCUS_NAME
            STORE SPACE(32) TO MCUS_STRT
            STORE SPACE(32) TO MCUS_CITYST
         ENDIF
         
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         SEEK MBBUYCODE                
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,30) TO MBIL_NAME       
            STORE NAME TO MTO
            **STORE SUBSTR(NOTE,1,32) TO MATTN
            STORE STREET +SPACE(2) TO MBIL_STRT
            IF ZIP4 = SPACE(4)
               STORE ZIP + SPACE(5) TO MBIL_ZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MBIL_ZIP 
            ENDIF
            STORE TRIM(CITY) + ', ' + STATE  + '  ' + MBIL_ZIP TO MBIL_CITYST
            STORE LEN(MBIL_CITYST) TO MLEN
            IF MLEN < 30
               STORE MBIL_CITYST + SPACE(30-MLEN) TO MBIL_CITYST
            ELSE
               IF MLEN > 30
                  STORE SUBSTR(MBIL_CITYST,1,30) TO MBIL_CITYST
               ENDIF
            ENDIF
            *** STORE AREA_CODE + PHONE TO MPHONE
            *** STORE FAX  TO MFAX
         ELSE
            STORE SPACE(30) TO MBIL_NAME
            STORE SPACE(30) TO MBIL_STRT
            STORE SPACE(30) TO MBIL_CITYST
            STORE SPACE(32) TO MTO
         ENDIF
         
         STORE SPACE(30) TO MSUP_NAME
         STORE SPACE(30) TO MSUP_CITYST
         STORE SPACE(10) TO MSUP_PHN
         **IF A->FRT_CODE1 = 'NONE'
         DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
         SEEK A->SUP_CODE
         IF .NOT. EOF()
            IF NAME = 'RANDALL COLD STORAGE'
               STORE SUBSTR(STREET,1,30) TO MSUP_NAME
            ELSE
               STORE SUBSTR(NAME,1,30) TO MSUP_NAME
            ENDIF
            STORE AREA_CODE + PHONE TO MSUP_PHN
            IF ZIP4 = SPACE(4)
               STORE ZIP + SPACE(5) TO MSUP_ZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MSUP_ZIP 
            ENDIF
            STORE TRIM(CITY) + ', ' + STATE  + '  ' + MSUP_ZIP TO MSUP_CITYST
            STORE LEN(MSUP_CITYST) TO MLEN
            IF MLEN < 30
               STORE MSUP_CITYST + SPACE(30-MLEN) TO MSUP_CITYST
            ELSE
               IF MLEN > 30
                  STORE SUBSTR(MSUP_CITYST,1,30) TO MSUP_CITYST
               ENDIF
            ENDIF
         ENDIF
         **ENDIF         
         
         STORE SPACE(30) TO MCOM_NAME
         STORE SPACE(32) TO MCC_NAME
         DO FOX_USE WITH "&mdbfloc.compayee INDEX &mdbfloc.com_code", .F.
         IF A->COM_CODE <> SPACE(2)
            SEEK A->COM_CODE
            IF .NOT. EOF() .AND. PRT_CONF <> 'N'
               STORE SUBSTR(NAME,1,25) TO MCOM_NAME
               STORE CC_NAME           TO MCC_NAME
            ENDIF
         ENDIF
         ***STORE MBIL_NAME TO MTO
         STORE 'CUSTOMER SERVICE' + SPACE(14) TO MFROM
         STORE A->SHIP_DATE TO MSHIP_DATE
         STORE A->ORD_DATE TO MORD_DATE
         IF A->PU_LOC = 'CPU'
            STORE A->SHIP_DATE TO MDEL_REQD
         ELSE
            IF A->FRT_CODE1 <> 'NONE'
               STORE A->DEL_REQD TO MDEL_REQD
            ELSE
               STORE CTOD('') TO MDEL_REQD
            ENDIF
         ENDIF
         STORE A->BUYER_PO TO MBUYER_PO
         STORE MSALESMAN TO RSALESMAN
         STORE MPO_NBR   TO RPO_NBR
         STORE MPO_SUFFIX TO RPO_SUFFIX
         
         @ 10,1 say 'ATTN/TO:                                  BROK'
         @ 11,1 SAY '                                          CUST'
         @ 13,1 SAY '  PHONE:                               BILL TO'
         @ 14,1 SAY '    FAX:                                       '
         @ 15,1 SAY '   FROM:                                       '
         IF A->PU_LOC = 'CPU'
            @ 16,1 SAY 'CUST PO:'
         ELSE
            @ 15,44 SAY 'CUST '
            @ 16,1 SAY 'CUST PO:                               SHIP TO'
         ENDIF
         @ 17,1 SAY 'AMERI #:   -    -'
         @ 18,1 SAY 'RELEASE:   -    -'
         @ 19,1 SAY ' ORD DT:                               PRODUCT'
         IF A->PU_LOC = 'CPU'
            @ 20,1 SAY 'PKUP DT:                                ORIGIN'
         ELSE
            @ 20,1 SAY 'DELV DT:                                ORIGIN'
         ENDIF
         @ 21,1 SAY '   NOTE:'
         
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 10,10 GET MTO PICTURE '@!'
            @ 11,1 GET MATTN   PICTURE '@!'
            @ 12,1 GET MATTN2  PICTURE '@!'

            @ 13,10 GET MPHONE PICTURE '@R ###-###-####'
            @ 14,10 GET MFAX   PICTURE '@R ###-###-####'
            @ 15,10 GET MFROM  PICTURE '@!'
            @ 16,10 GET MBUYER_PO PICTURE '@!'
            @ 17,10 GET MSALESMAN
            @ 17,13 GET MPO_NBR
            @ 17,18 GET MPO_SUFFIX PICTURE '@!'
            @ 18,10 GET RSALESMAN
            @ 18,13 GET RPO_NBR
            @ 18,18 GET RPO_SUFFIX
            @ 19,10 GET MORD_DATE
            @ 20,10 GET MDEL_REQD
            @ 21,10 GET MNOTE PICTURE '@!'
            @ 22,10 GET MNOTE2 PICTURE '@!'
            @ 10,48 GET MCOM_NAME PICTURE '@!'
            @ 11,48 GET MBIL_NAME PICTURE '@!'
            @ 12,48 GET MBIL_STRT PICTURE '@!'
            @ 13,48 GET MBIL_CITYST PICTURE '@!'
            IF A->FRT_CODE1 <> 'NONE'
               @ 15,48 GET MCUS_NAME PICTURE '@!'
               @ 16,48 GET MCUS_STRT PICTURE '@!'
               @ 17,48 GET MCUS_CITYST PICTURE '@!'
            ENDIF
            @ 19,48 GET MSUP_NAME PICTURE '@!'
            @ 20,48 GET MSUP_CITYST PICTURE '@!'
            ***@ 21,49 GET MSUP_PHN PICTURE '@R ###-###-####'
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
      ENDCASE
      
   CASE MTYPE3 = 'X'
      
      *** FREEZER RELEASE
      SELECT A
      
      STORE SPACE(55) TO MREMARKS
      STORE SPACE(30) TO MATTN
      
      **** COMING OUT OF INVENTORY
      DO CASE
      CASE RSUPCODE = 'INVN'
         
         STORE BUY_CODE TO MBUY_CODE
         STORE BBUYCODE TO MBBUYCODE
         STORE SPACE(13) TO MFAX, MCONT_FAX
         STORE 'CUSTOMER SERVICE' + SPACE(14) TO MFROM
         STORE SPACE(30) TO MCONTACT1, MCONTACT2
         STORE SPACE(13) TO MPHONE, MPHONE1,MPHONE2
         ***************************
         ** GET CUSTOMER INFORMATION
         ***************************
         STORE SPACE(30) TO MCUS_NAME, MCUS_STRT, MCUS_CITYST, MCONTACT2
         STORE SPACE(10) TO MPHONE2, MCUS_ZIP
         SELECT E
         **IF A->FRT_CODE1 = 'NONE'
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         SEEK MBUY_CODE
         **GOTO BOTTOM
         **SKIP
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,30) TO MCUS_NAME       
            STORE STREET + SPACE(2) TO MCUS_STRT  
            STORE AREA_CODE + PHONE TO MPHONE2
            STORE SUBSTR(NOTE,1,30) TO MCONTACT2
            IF ZIP4 = SPACE(4)
               STORE ZIP + SPACE(5) TO MCUS_ZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MCUS_ZIP 
            ENDIF
            STORE TRIM(CITY) + ', ' + STATE  + '  ' + MCUS_ZIP TO MCUS_CITYST
            STORE LEN(MCUS_CITYST) TO MLEN
            IF MLEN < 30
               STORE MCUS_CITYST + SPACE(30-MLEN) TO MCUS_CITYST
            ELSE
               IF MLEN > 30
                  STORE SUBSTR(MCUS_CITYST,1,30) TO MCUS_CITYST
               ENDIF
            ENDIF
         ENDIF
         **ENDIF      
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         **SEEK MBBUYCODE
         GOTO BOTTOM
         SKIP
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,30) TO MBIL_NAME       
            STORE STREET +SPACE(2) TO MBIL_STRT  
            IF ZIP4 = SPACE(4)
               STORE ZIP + SPACE(5) TO MBIL_ZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MBIL_ZIP 
            ENDIF
            STORE TRIM(CITY) + ', ' + STATE  + '  ' + MBIL_ZIP TO MBIL_CITYST
            STORE LEN(MBIL_CITYST) TO MLEN
            IF MLEN < 30
               STORE MBIL_CITYST + SPACE(30-MLEN) TO MBIL_CITYST
            ELSE
               IF MLEN > 30
                  STORE SUBSTR(MBIL_CITYST,1,30) TO MBIL_CITYST
               ENDIF
            ENDIF
            STORE AREA_CODE + PHONE TO MPHONE1
            STORE SUBSTR(NOTE,1,30) TO MCONTACT1
         ELSE
            IF A->SUP_CODE = ' 104'
               STORE 'AMERICHICKEN-PLEASE ID PALLETS' TO MBIL_NAME
            ELSE
               STORE 'AMERICHICKEN' + SPACE(18) TO MBIL_NAME
            ENDIF
            **STORE SPACE(30) TO MBIL_NAME
            STORE SPACE(30) TO MBIL_STRT
            STORE SPACE(30) TO MBIL_CITYST
         ENDIF
         
         STORE SPACE(30) TO MSUP_NAME
         DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
         SEEK A->SUP_CODE
         
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,30) TO MSUP_NAME       
            STORE AREA_CODE + PHONE TO MPHONE
            **STORE SUBSTR(NOTE,1,30) TO MATTN
            STORE SUBSTR(CONT_NAME,1,30) TO MATTN
            STORE FAX TO MFAX
            STORE CONT_FAX TO MCONT_FAX
            STORE CONT_PH  TO MPHONE
         ENDIF
         
         STORE MSUP_NAME TO MTO
         STORE A->SHIP_DATE TO MSHIP_DATE
         STORE A->ORD_DATE TO MORD_DATE
         STORE A->BUYER_PO TO MBUYER_PO
         STORE MSALESMAN TO RSALESMAN
         STORE MPO_NBR   TO RPO_NBR
         STORE MPO_SUFFIX TO RPO_SUFFIX
         
      OTHERWISE
         
         STORE BUY_CODE TO MBUY_CODE
         STORE BBUYCODE TO MBBUYCODE
         
         STORE SPACE(13) TO MFAX, MCONT_FAX
         STORE 'CUSTOMER SERVICE' + SPACE(14) TO MFROM
         STORE SPACE(30) TO MATTN, MCONTACT1, MCONTACT2
         STORE SPACE(13) TO MPHONE, MPHONE1,MPHONE2
         
         ***************************
         ** GET CUSTOMER INFORMATION
         ***************************
         STORE SPACE(30) TO MCUS_NAME, MCUS_STRT, MCUS_CITYST, MCONTACT2
         STORE SPACE(10) TO MPHONE2, MCUS_ZIP
         
         SELECT E
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         SEEK MBUY_CODE
         IF .NOT. EOF()
            STORE NAME TO MTO       
            *STORE AREA_CODE + PHONE TO MPHONE
            *STORE FAX TO MFAX
            STORE CONT_PH TO MPHONE
            STORE CONT_FAX TO MCONT_FAX
            STORE SUBSTR(CONT_NAME,1,30) TO MATTN
         ENDIF
         IF A->PU_LOC = 'TRANSFER'
            MBIL_STRT = 'PLEASE ACCEPT FROM:'
            SELECT E
            DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
            SEEK A->SUP_CODE
            IF .NOT. EOF()
               STORE SUBSTR(NAME,1,30) TO MBIL_CITYST      
            ENDIF
         ENDIF
         
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         **SEEK MBBUYCODE
         GOTO BOTTOM
         SKIP
         IF .NOT. EOF()
            STORE SUBSTR(NAME,1,30) TO MBIL_NAME       
            STORE STREET +SPACE(2) TO MBIL_STRT  
            IF ZIP4 = SPACE(4)
               STORE ZIP + SPACE(5) TO MBIL_ZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MBIL_ZIP 
            ENDIF
            STORE TRIM(CITY) + ', ' + STATE  + '  ' + MBIL_ZIP TO MBIL_CITYST
            STORE LEN(MBIL_CITYST) TO MLEN
            IF MLEN < 30
               STORE MBIL_CITYST + SPACE(30-MLEN) TO MBIL_CITYST
            ELSE
               IF MLEN > 30
                  STORE SUBSTR(MBIL_CITYST,1,30) TO MBIL_CITYST
               ENDIF
            ENDIF
            STORE AREA_CODE + PHONE TO MPHONE1
            STORE SUBSTR(NOTE,1,30) TO MCONTACT1
         ELSE
            STORE 'AMERICHICKEN' + SPACE(18) TO MBIL_NAME
            **STORE SPACE(30) TO MBIL_NAME
            IF A->PU_LOC = 'TRANSFER'
               MBIL_STRT = 'PLEASE ACCEPT FROM:'
               SELECT E
               DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
               SEEK A->SUP_CODE
               IF .NOT. EOF()
                  STORE SUBSTR(NAME,1,30) TO MBIL_CITYST      
               ENDIF
            ELSE
               STORE SPACE(30) TO MBIL_STRT
               STORE SPACE(30) TO MBIL_CITYST
            ENDIF
         ENDIF
         
         STORE SPACE(30) TO MSUP_NAME
         STORE A->DEL_REQD TO MSHIP_DATE
         STORE A->ORD_DATE TO MORD_DATE
         STORE SPACE(15) TO MBUYER_PO
         
         STORE MSALESMAN TO RSALESMAN
         STORE MPO_NBR   TO RPO_NBR
         STORE MPO_SUFFIX TO RPO_SUFFIX
         
      ENDCASE
      @ 10,1 say '     TO:'                                      
      @ 11,1 SAY '   ATTN:                                  CUST:'
      @ 12,1 SAY '  PHONE:                                       '
      @ 13,1 SAY '    FAX:                                       '
      @ 15,1 SAY '   FROM:'
      @ 16,1 SAY '                                   DELIVERY PO:'
      @ 17,1 SAY 'AMERI #:   -    -                           TO:'
      @ 18,1 SAY 'RELEASE:   -    -                              '
      @ 19,1 SAY ' ORD DT:                                      '
      IF A->RSUPCODE = 'INVN'
         @ 20,1 SAY 'LOAD DT:                                 PHONE:'
      ELSE
         IF A->PU_LOC = 'TRANSFER'
            @ 20,1 SAY 'TRAN DT:                                 PHONE:'
            STORE A->DEL_REQD TO MSHIP_DATE
         ELSE
            @ 20,1 SAY 'DELV DT:                                 PHONE:'
            STORE A->DEL_REQD TO MSHIP_DATE
         ENDIF
      ENDIF
      @ 21,1 SAY '                                       CONTACT:'
      @ 22,1 SAY '   NOTE:'
      
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 10,10 GET MTO PICTURE '@!'
         @ 11,10 GET MATTN   PICTURE '@!'
         @ 12,10 GET MPHONE PICTURE '@R ###-###-####'
         @ 13,10 GET MCONT_FAX PICTURE '@R ###-###-####'
         @ 15,10 GET MFROM  PICTURE '@!'
         @ 17,10 GET MSALESMAN
         @ 17,13 GET MPO_NBR
         @ 17,18 GET MPO_SUFFIX PICTURE '@!'
         @ 18,10 GET RSALESMAN
         @ 18,13 GET RPO_NBR
         @ 18,18 GET RPO_SUFFIX
         @ 19,10 GET MORD_DATE
         @ 20,10 GET MSHIP_DATE
         @ 11,49 GET MBIL_NAME PICTURE '@!'
         @ 12,49 GET MBIL_STRT PICTURE '@!'
         @ 13,49 GET MBIL_CITYST PICTURE '@!'
         
         @ 16,49 GET MBUYER_PO PICTURE '@!'
         @ 17,49 GET MCUS_NAME PICTURE '@!'
         @ 18,49 GET MCUS_STRT PICTURE '@!'
         @ 19,49 GET MCUS_CITYST PICTURE '@!'
         @ 20,49 GET MPHONE2 PICTURE '@R ###-###-####'
         @ 21,49 GET MCONTACT2 PICTURE '@!'
         @ 22,10 GET MREMARKS PICTURE '@!'
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
      
   ENDCASE
   
   IF MCOMPANY = 'MIDWEST FOOD -DIV 11 INVENTORY'
      STORE '   ' TO PSALESMAN
   ELSE
      STORE MSALESMAN + '-' TO PSALESMAN
   ENDIF
   IF PSALESMAN = '  -'
      STORE SPACE(3) TO PSALESMAN
   ENDIF
   
   STORE ' ' TO MACTION
   DO PRT_BOT
   IF MACTION <> 'C'
      MACTION = 1
      LOOP
   ENDIF 
   MACTION = 2
   
   STORE TIME() TO MTIME
   MPRT_FILE = 'C' + SUBSTR(MTIME,1,2) + SUBSTR(MTIME,4,2) + SUBSTR(MTIME,7,2) + '.TXT'
   
   SET CONSOLE OFF
   SET PRINT TO C:\COMPINFO\&MPRT_FILE
   
   
   SET CONSOLE OFF
   IF FILE("C:\COMPINFO\PRINTERS.DBF")
      ***SET PRINT TO C:\COMPINFO\&MPRT_FILE.TXT
      SET PRINT TO C:\COMPINFO\&MPRT_FILE
   ELSE
      SET PRINT TO LPT3
   ENDIF
   SET DEVICE TO PRINT
   SET PRINT ON
   
   *** LETTER SIZE PAPER
   ?? CHR(27) + '&l2A'
   *** PORTRAIT MODE
   ?? CHR(27) + '&l0O'
   
   **** OLD WAY OF PRINTING THE HEADER
   **** ? space(29)
   ****?? REPLICATE('ß',36)
   ****?
   ****? SPACE(29)        
   *** SET DOUBLE WIDE
   ****?? CHR(27) + 'W1' 
   *** SET DOUBLE HIGH             
   ****?? CHR(27) + 'w1' 
   *** TURN ON EMPHASIZED
   ****?? CHR(27) + 'G'        
   ****?? chr(27) + 'R' + CHR(2) + '@'
   ****?? ' AmeriChicken, Inc'
   ****?? chr(27) + 'R' + CHR(2) + '@'
   *** TURN OFF DOUBLE WIDE
   ****?? CHR(27) + 'W0'
   *** TURN QFF DOUBLE HEIGHT       
   ****?? CHR(27) + 'w0' 
   *** TURN OFF EMPHASIZED
   ****?? CHR(27) + 'H'
   ****? space(29)
   ****?? REPLICATE('ß',36)
   DO AMER_BOX
   
   ? SPACE(5) + 'Phone: ' + '573-651-6485' + SPACE(37) + '1330 Copper Dr.'
   ? SPACE(5) + 'Fax:   ' + '573-651-4669' + SPACE(37) + 'Cape Girardeau, MO  63701'
   ? SPACE(5) + 'Email: customerservice@americhicken.com'
   ?
   ? SPACE(5) + REPLICATE('=',88)
   IF MTYPE3 = 'X'
   ELSE
      ?  SPACE(5) + SPACE(25) +  SPACE(27) + SPACE(21) + 'DATE'
   ENDIF
   
   
   ***HERE PRINT
   
   DO CASE
   CASE MTYPE1 = 'X'
      ?  SPACE(4) + SPACE(26) + 'PURCHASE ORDER CONFIRMATION' + SPACE(18) + DTOC(DATE())
      ?
      ?
      ?  SPACE(4) + 'FROM:        ' + MFROM
      IF A->PU_LOC = 'TRANSFER'
         ?? SPACE(5) + '      TRANSFER: ' + MBUY_NAME
      ELSE
         ?? SPACE(5) + '  SHIPPED FROM: ' + MSUP_NAME
      ENDIF
      
      ?
      IF A->PU_LOC = 'TRANSFER'
         ?? SPACE(49) + SPACE(5) + '    LOCATION  '
      ELSE
         ?? SPACE(68)
      ENDIF
      IF A->PU_LOC = 'TRANSFER'
         ?? MBUY_STRT
      ELSE
         ?? MSUP_STRT
      ENDIF
      ?  SPACE(4) + 'TO:          ' + MTO
      ?? SPACE(21)
      IF A->PU_LOC = 'TRANSFER'
         ?? MBUY_CITYST
      ELSE
         ?? MSUP_CITYST
      ENDIF
      ?
      ?  SPACE(4) + 'WITH:        ' + MREM_NAME
      ?
      ?  SPACE(4) + 'PHONE:       ' + SUBSTR(MPHONE,1,3) + '-' + SUBSTR(MPHONE,4,3) + '-' + SUBSTR(MPHONE,7) + SPACE(15)
      IF A->PU_LOC <> 'TRANSFER'
         ?? SPACE(5) + '     PICKUP PHONE: ' + SUBSTR(MSUP_PHONE,1,3) + '-' + SUBSTR(MSUP_PHONE,4,3) + '-' + SUBSTR(MSUP_PHONE,7)
      ENDIF
      ?
      ?  SPACE(4) + 'FAX:         ' + SUBSTR(MFAX,1,3) + '-' + SUBSTR(MFAX,4,3) + '-' + SUBSTR(MFAX,7) + SPACE(15)
      
      IF A->PU_LOC <> 'TRANSFER'
         ?? SPACE(5) + '     CONTACT: ' + MCONTACT
      ENDIF
      
      ?
      IF MNOTE <> SPACE(30) .OR. MNOTE2 <> SPACE(30) .OR. MNOTE3 <> SPACE(30)
         ?  SPACE(4) + SPACE(50) + 'NOTES: ' + MNOTE
      ELSE
         ?
      ENDIF
      ?  SPACE(4) + 'PO #:        '
      
      IF PSALESMAN <> '  '
         ?? PSALESMAN 
         ?? MPO_NBR
         IF MPO_SUFFIX = ' '
            ?? SPACE(2)
         ELSE
            ?? '-' + MPO_SUFFIX
         ENDIF
         ?? ' '
      ELSE
         ?? MPO_NBR
         IF MPO_SUFFIX = ' '
            ?? SPACE(2)
         ELSE
            ?? '-' + MPO_SUFFIX
         ENDIF
         ?? SPACE(3)
      ENDIF
      
      ?? SPACE(35) + MNOTE2
      ?  SPACE(4)  + SPACE(50) + SPACE(7) + MNOTE3
      ?  SPACE(4) + 'ORDER DATE:  ' + DTOC(MORD_DATE)
      ?
      IF A->PU_LOC = 'TRANSFER'
         ?  SPACE(4) + 'TRANSFER DT: ' + DTOC(MSHIP_DATE)
      ELSE
         ?  SPACE(4) + 'LOAD DATE:   ' + DTOC(MSHIP_DATE)
      ENDIF
      ?
      ?
      
      
   CASE MTYPE2 = 'X'
      DO CASE
      CASE MBIL_NAME = 'INVENTORY'
         ?  SPACE(5) + SPACE(24) + 'FREEZER INBOUND CONFIRMATION' + SPACE(18) + DTOC(DATE())
         ?
         ?  SPACE(5) + 'TO:   ' + MTO  + SPACE(4)
         ?? SPACE(6) + 'ADDR: '  + MCUS_STRT
         
         ?  SPACE(5) + SPACE(42)
         ?? SPACE(3) + '         ' + MCUS_CITYST          
         
         
         ?  SPACE(5) + 'ATTN: ' + MATTN
         
         ?  SPACE(5) + '      ' + MATTN2
         
         ?  SPACE(5)
         
         
         ?  SPACE(5)
         ?? 'PH #: ' + SUBSTR(MPHONE,1,3) + '-' + SUBSTR(MPHONE,4,3) + '-' + SUBSTR(MPHONE,7) + SPACE(18) + SPACE(6)
         ?? SPACE(3) + 'PRODUCT  ' + MSUP_NAME          
         
         ?  SPACE(5) + 'FAX:  ' + SUBSTR(MFAX,1,3) + '-' + SUBSTR(MFAX,4,3) + '-' + SUBSTR(MFAX,7) + SPACE(18) + SPACE(6)
         ?? SPACE(3) + ' ORIGIN: ' + MSUP_CITYST        
         
         ? SPACE(5) + SPACE(44)
         
         ?  SPACE(5) + 'FROM: ' + MFROM
         
         ?  SPACE(5) + SPACE(44)
         IF MNOTE <> SPACE(30) .OR. MNOTE2 <> SPACE(30)
            ?? SPACE(3) + 'NOTES: ' + MNOTE
         ENDIF
         
         ?  SPACE(5) + 'CUST PO #:  ' + MBUYER_PO + SPACE(17)
         ?? SPACE(3) + '       ' + MNOTE2
         
         ?  SPACE(5) + 'AMERI PO #: '
         
         IF PSALESMAN <> '  '
            ?? PSALESMAN 
            ?? MPO_NBR
            IF MPO_SUFFIX = ' '
               ?? SPACE(2)
            ELSE
               ?? '-' + MPO_SUFFIX
            ENDIF
            ?? ' '
         ELSE
            ?? MPO_NBR
            IF MPO_SUFFIX = ' '
               ?? SPACE(2)
            ELSE
               ?? '-' + MPO_SUFFIX
            ENDIF
            ?? SPACE(3)
         ENDIF
         
         ?  SPACE(5) + 'RELEASE #:  '
         IF PSALESMAN <> '  '
            ?? PSALESMAN 
            ?? MPO_NBR
            IF MPO_SUFFIX = ' '
               ?? SPACE(2)
            ELSE
               ?? '-' + MPO_SUFFIX
            ENDIF
            ?? ' '
         ELSE
            ?? MPO_NBR
            IF MPO_SUFFIX = ' '
               ?? SPACE(2)
            ELSE
               ?? '-' + MPO_SUFFIX
            ENDIF
            ?? SPACE(3)
         ENDIF
         
         ?
         
         ?  SPACE(5) + 'ORDER DATE: ' + DTOC(MORD_DATE) + SPACE(17)
         
         IF A->PU_LOC = 'CPU'
            ?  SPACE(5) + 'PKUP DATE:  ' + DTOC(MDEL_REQD) + SPACE(17)
         ELSE
            ?  SPACE(5) + 'DELV DATE:  ' + DTOC(MDEL_REQD) + SPACE(17)
         ENDIF
         ?
         IF MALL_AMT <> 0
            ?  SPACE(5) + 'PKUP ALLOW: ' + LTRIM(TRANSFORM(MALL_AMT, '$$,$$$.$$')) + SPACE(2) + '*********'
         ENDIF
         ?
         
      OTHERWISE
         *** CUSTOMER CONFIRMATIONS
         ?  SPACE(5) + SPACE(25) + 'CUSTOMER SALES CONFIRMATION' + SPACE(18) + DTOC(DATE())
         ?

         ?  SPACE(5) + 'TO:   ' + MTO  + SPACE(4)
         ?? SPACE(5) + '    BROKER:   ' + MCOM_NAME

         ?  SPACE(5) + SPACE(47) + '    CC:       ' + MCC_NAME

         ?  SPACE(5) + 'ATTN: ' + MATTN

         ?  SPACE(5) + '      ' + MATTN2
         ?? '   BILL TO   ' + MBIL_NAME

         ?  SPACE(5) + SPACE(42)
         ?? SPACE(5) + '    CUSTOMER: ' + MBIL_STRT

         ?  SPACE(5)
         ?? 'PH #: ' + SUBSTR(MPHONE,1,3) + '-' + SUBSTR(MPHONE,4,3) + '-' + SUBSTR(MPHONE,7) + SPACE(18) + SPACE(6)
         ?? SPACE(5) + SPACE(14) + MBIL_CITYST
         
         ?  SPACE(5) + 'FAX:  ' + SUBSTR(MFAX,1,3) + '-' + SUBSTR(MFAX,4,3) + '-' + SUBSTR(MFAX,7) + SPACE(18) + SPACE(6)
         ?? SPACE(5) + SPACE(14) 
         
         ?  SPACE(5) + SPACE(47)
         
         
         IF A->PU_LOC <>'CPU'
            ?? SPACE(3) + ' SHIP TO   ' + MCUS_NAME
         ELSE
            ?? SPACE(3) + ' SHIP TO   ' + 'CUSTOMER PICKUP'
         ENDIF
         
         ?  SPACE(5) + 'FROM: ' + MFROM + SPACE(4)
         IF A->PU_LOC <>'CPU'
            ?? SPACE(11) + 'CUSTOMER: ' + MCUS_STRT
         ENDIF
         
         ?   SPACE(5) + SPACE(47)
         IF A->PU_LOC <>'CPU'
            ??  SPACE(3) + SPACE(11) + MCUS_CITYST
         ENDIF
         
         ?  SPACE(5) + 'CUST PO #:  ' + MBUYER_PO + SPACE(15)
         
         ?  SPACE(5) + 'AMERI PO #: '
         
         IF PSALESMAN <> '  '
            ?? PSALESMAN 
            ?? MPO_NBR
            IF MPO_SUFFIX = ' '
               ?? SPACE(2)
            ELSE
               ?? '-' + MPO_SUFFIX
            ENDIF
            ?? ' '
         ELSE
            ?? MPO_NBR
            IF MPO_SUFFIX = ' '
               ?? SPACE(2)
            ELSE
               ?? '-' + MPO_SUFFIX
            ENDIF
            ?? SPACE(3)
         ENDIF
         
         ?? SPACE(21)
         
         IF MNOTE <> SPACE(30) .OR. MNOTE2 <> SPACE(30)
            ?? SPACE(5) + '    NOTES:    ' + MNOTE     
         ENDIF
         ?  SPACE(5) + 'RELEASE #:  '
         IF PSALESMAN <> '  '
            ?? PSALESMAN 
            ?? MPO_NBR
            IF MPO_SUFFIX = ' '
               ?? SPACE(2)
            ELSE
               ?? '-' + MPO_SUFFIX
            ENDIF
            ?? ' '
         ELSE
            ?? MPO_NBR
            IF MPO_SUFFIX = ' '
               ?? SPACE(2)
            ELSE
               ?? '-' + MPO_SUFFIX
            ENDIF
            ?? SPACE(3)
         ENDIF
         ?? SPACE(40) +  MNOTE2
         ?
         ?  SPACE(5) + 'ORDER DATE: ' + DTOC(MORD_DATE) + SPACE(17)
         IF A->PU_LOC ='CPU'
            ?? SPACE(5) + '       PICKUP    ' + MSUP_NAME
         ELSE
            ?? SPACE(5) + '       PRODUCT   ' + MSUP_NAME
         ENDIF
         IF A->PU_LOC = 'CPU'
            ?  SPACE(5) + 'PKUP DATE:  ' + DTOC(MDEL_REQD) + SPACE(17)
         ELSE
            ?  SPACE(5) + 'DELV DATE:  ' + DTOC(MDEL_REQD) + SPACE(17)
         ENDIF
         
         IF A->PU_LOC ='CPU'
            ?? SPACE(5) + SPACE(7) + 'LOCATION: ' + MSUP_CITYST
         ELSE
            ?? SPACE(5) + SPACE(7) + 'ORIGIN:   ' + MSUP_CITYST
         ENDIF
         ?
         IF MALL_AMT <> 0
            ?  SPACE(5) + 'PKUP ALLOW: ' + LTRIM(TRANSFORM(MALL_AMT, '$$,$$$.$$')) + SPACE(2) + '*********'
         ENDIF
         ?
         
      ENDCASE
      
      *** SET UP FOR ITEMS PRINT
      SELECT A
      IF SHIP_NBR <> SPACE(4)
         *** THIS IS A SHIPPED WITH PO *** DONT DO ITEMS
         SELECT B
         DO FOX_USE WITH "C:\COMPWORK\DTL_TEMP", .T.
         DELETE ALL
         PACK
      ELSE
         IF A->MAIN_SHIP = 'Y'
            SELECT E
            DO FOX_USE WITH "SHIPWITH INDEX SHIPWITH", .F.
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF .NOT. EOF()         
               STORE PO_SHIP1 TO MPO_SHIP1
               STORE PO_SHIP2 TO MPO_SHIP2
               STORE PO_SHIP3 TO MPO_SHIP3
               STORE PO_SHIP4 TO MPO_SHIP4
               STORE PO_SHIP5 TO MPO_SHIP5
               STORE PO_SHIP6 TO MPO_SHIP6
               STORE PO_SUFF1 TO MPO_SUFF1
               STORE PO_SUFF2 TO MPO_SUFF2
               STORE PO_SUFF3 TO MPO_SUFF3
               STORE PO_SUFF4 TO MPO_SUFF4
               STORE PO_SUFF5 TO MPO_SUFF5
               STORE PO_SUFF6 TO MPO_SUFF6
            ELSE
               STORE SPACE(4) TO MPO_SHIP1, MPO_SHIP2, MPO_SHIP3, MPO_SHIP3, MPO_SHIP4, MPO_SHIP5, MPO_SHIP6
               STORE SPACE(1) TO MPO_SUFF1, MPO_SUFF2, MPO_SUFF3, MPO_SUFF3, MPO_SUFF4, MPO_SUFF5, MPO_SUFF6
            ENDIF
         ENDIF  
         SELECT E
         USE C:\COMPWORK\DTL_TEMP EXCLUSIVE
         DELETE ALL
         PACK
         INDEX ON PROD_DESC + STR_PRI TO C:\COMPWORK\DTL_TEMP            
         USE C:\COMPWORK\DTL_TEMP INDEX C:\COMPWORK\DTL_TEMP EXCLUSIVE
         
         SELECT B
         DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         *** GET THE MAIN PO ITEMS         
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
            IF QTY = 0
               SKIP
               LOOP
            ENDIF
            STORE STR(SEL_PRICE,7,4) TO MSTR_PRI
            SELECT E
            SEEK B->PROD_DESC + MSTR_PRI
            IF EOF()
               APPEND BLANK
               REPLACE SALESMAN WITH MSALESMAN
               REPLACE PO_NBR   WITH MPO_NBR
               REPLACE PO_SUFFIX WITH MPO_SUFFIX
               REPLACE PROD_DESC WITH B->PROD_DESC
               REPLACE SEL_PRICE WITH B->SEL_PRICE
               REPLACE STR_PRI   WITH MSTR_PRI
            ENDIF
            REPLACE QTY      WITH QTY + B->QTY
            REPLACE FRH_FRZ  WITH B->FRH_FRZ
            REPLACE GRADE    WITH B->GRADE
            REPLACE PACKAGED WITH B->PACKAGED
            REPLACE PRODUCT  WITH B->PRODUCT
            REPLACE SIZE     WITH B->SIZE
            REPLACE PACKED   WITH B->PACKED
            REPLACE LBS      WITH LBS + B->LBS
            REPLACE PUR_PRICE WITH B->PUR_PRICE
            REPLACE TOT_SELL WITH TOT_SELL + B->TOT_SELL
            REPLACE TOT_PURCH WITH TOT_PURCH + B->TOT_PURCH
            REPLACE BILL_PRI  WITH B->BILL_PRI
            REPLACE SHORT_FLG WITH B->SHORT_FLG
            REPLACE SHRT_BOX  WITH B->SHRT_BOX
            REPLACE SHRT_LBS  WITH B->SHRT_LBS
            SELECT B
            SKIP
         ENDDO
         IF A->MAIN_SHIP = 'Y'
            ******
            *** NOW GET ALL THE SHIPPED WITH ITEMS
            I = 1
            DO WHILE I<= 6
               STORE STR(I,1) TO MI
               IF MPO_SHIP&MI = SPACE(4)
                  I = I + 1
                  LOOP
               ENDIF
               SELECT B
               SEEK MSALESMAN + MPO_SHIP&MI + MPO_SUFF&MI
               DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_SHIP&MI .AND. PO_SUFFIX = MPO_SUFF&MI
                  IF QTY = 0
                     SKIP
                     LOOP
                  ENDIF
                  STORE STR(SEL_PRICE,7,4) TO MSTR_PRI
                  SELECT E
                  SEEK B->PROD_DESC + MSTR_PRI
                  IF EOF()
                     APPEND BLANK
                     REPLACE SALESMAN WITH MSALESMAN
                     REPLACE PO_NBR   WITH MPO_NBR
                     REPLACE PO_SUFFIX WITH MPO_SUFFIX
                     REPLACE PROD_DESC WITH B->PROD_DESC
                     REPLACE SEL_PRICE WITH B->SEL_PRICE
                     REPLACE STR_PRI   WITH MSTR_PRI
                  ENDIF
                  REPLACE QTY      WITH QTY + B->QTY
                  REPLACE FRH_FRZ  WITH B->FRH_FRZ
                  REPLACE GRADE    WITH B->GRADE
                  REPLACE PACKAGED WITH B->PACKAGED
                  REPLACE PRODUCT  WITH B->PRODUCT
                  REPLACE SIZE     WITH B->SIZE
                  REPLACE PACKED   WITH B->PACKED
                  REPLACE LBS      WITH LBS + B->LBS
                  REPLACE PUR_PRICE WITH B->PUR_PRICE
                  REPLACE TOT_SELL WITH TOT_SELL + B->TOT_SELL
                  REPLACE TOT_PURCH WITH TOT_PURCH + B->TOT_PURCH
                  REPLACE BILL_PRI  WITH B->BILL_PRI
                  REPLACE SHORT_FLG WITH B->SHORT_FLG
                  REPLACE SHRT_BOX  WITH B->SHRT_BOX
                  REPLACE SHRT_LBS  WITH B->SHRT_LBS
                  SELECT B
                  SKIP
               ENDDO
               I = I + 1
            ENDDO
         ENDIF
         SELECT E
         USE
         **** NOW SWITCH OVER TO THE TEMP FILE
         SELECT B
         DO FOX_USE WITH "C:\COMPWORK\DTL_TEMP", .F.
      ENDIF
      
      SELECT B
      
      
   CASE MTYPE3 = 'X'
      IF A->BBUYCODE = 'INVN' .AND. A->PU_LOC = 'TRANSFER'
         ?  SPACE(5) + SPACE(21) + 'FREEZER TRANSFER IN STORAGE NOTIFICATION' + SPACE(10) + 'DATE: ' + DTOC(DATE())
      ELSE
         ?  SPACE(5) + SPACE(25) + '       FREEZER NOTIFICATION' + SPACE(12) + 'DATE: ' + DTOC(DATE())
      ENDIF
      
      ?
      ?  SPACE(5) + 'TO:         ' + MTO  
      ?      
      ?  SPACE(5) + 'ATTN:       ' + MATTN
      ?? SPACE(5) + '      CUSTOMER: ' + MBIL_NAME
      ?
      ?  SPACE(5) + 'PHONE:      ' + SUBSTR(MPHONE,1,3) + '-' + SUBSTR(MPHONE,4,3) + '-' + SUBSTR(MPHONE,7) + SPACE(18)
      ?? SPACE(5) + SPACE(16) + MBIL_STRT
      ?  SPACE(5) + 'FAX:        '
      
      IF MCONT_FAX <> SPACE(10)     
         ?? SUBSTR(MCONT_FAX,1,3) + '-' + SUBSTR(MCONT_FAX,4,3) + '-' + SUBSTR(MCONT_FAX,7)
      ELSE
         ?? SUBSTR(MFAX,1,3) + '-' + SUBSTR(MFAX,4,3) + '-' + SUBSTR(MFAX,7)
      ENDIF
      
      ?? SPACE(15)
      ?? SPACE(5) + SPACE(19) + MBIL_CITYST
      ?
      ?  SPACE(5) + 'FROM:       ' + MFROM
      ?  SPACE(5) + SPACE(42)
      ?
      ?  SPACE(5) + 'AMERI PO #: '
      IF PSALESMAN <> '  '
         ?? PSALESMAN 
         ?? MPO_NBR
         IF MPO_SUFFIX = ' '
            ?? SPACE(2)
         ELSE
            ?? '-' + MPO_SUFFIX
         ENDIF
         ?? ' '
      ELSE
         ?? MPO_NBR
         IF MPO_SUFFIX = ' '
            ?? SPACE(2)
         ELSE
            ?? '-' + MPO_SUFFIX
         ENDIF
         ?? SPACE(3)
      ENDIF
      
      ?? SPACE(21)
      IF A->PU_LOC <> 'TRANSFER'
         IF A->PU_LOC = 'CPU'
            ?? SPACE(5) + '      CUSTOMER  ' + MCUS_NAME
         ELSE
            ?? SPACE(5) + '      SHIPPING  ' + MCUS_NAME
         ENDIF
      ENDIF
      ?  SPACE(5) + 'RELEASE #:  '
      IF PSALESMAN <> '  '
         ?? PSALESMAN 
         ?? MPO_NBR
         IF MPO_SUFFIX = ' '
            ?? SPACE(2)
         ELSE
            ?? '-' + MPO_SUFFIX
         ENDIF
         ?? ' '
      ELSE
         ?? MPO_NBR
         IF MPO_SUFFIX = ' '
            ?? SPACE(2)
         ELSE
            ?? '-' + MPO_SUFFIX
         ENDIF
         ?? SPACE(3)
      ENDIF
      
      
      ?? SPACE(21)
      IF A->PU_LOC <> 'TRANSFER'
         IF A->PU_LOC = 'CPU'
            ?? SPACE(5) + '      PICK UP:  ' + MCUS_STRT
         ELSE
            ?? SPACE(5) + '            TO: ' + MCUS_STRT
         ENDIF
      ENDIF
      
      ?  SPACE(5) + 'ORDER DATE: ' + DTOC(MORD_DATE) + SPACE(21)
      IF A->PU_LOC <> 'TRANSFER'
         ?? SPACE(5) + SPACE(16) + MCUS_CITYST
      ENDIF
      ?
      IF A->RSUPCODE = 'INVN'
         ?  SPACE(47) + SPACE(5) + '      CUST PO#: ' + MBUYER_PO
         ?  SPACE(5) + 'LOAD DATE:  ' + DTOC(MSHIP_DATE) + SPACE(17)
         ?? SPACE(5) + '         PHONE:    ' + SUBSTR(MPHONE2,1,3) + '-' + SUBSTR(MPHONE2,4,3) + '-' + SUBSTR(MPHONE2,7)
      ELSE
         IF A->PU_LOC <> 'TRANSFER'
            ?  SPACE(47) + SPACE(5) + ' DELIVERY PO #: ' + MBUYER_PO
            ?  SPACE(5) + 'DELIV DATE: ' + DTOC(MSHIP_DATE) + SPACE(17)
            ?? SPACE(5) + '   DELIVERY PHONE: ' + SUBSTR(MPHONE2,1,3) + '-' + SUBSTR(MPHONE2,4,3) + '-' + SUBSTR(MPHONE2,7)
         ELSE
            ?
            ?  SPACE(4) + 'TRANSFER DT: ' + DTOC(MSHIP_DATE) + SPACE(17)
         ENDIF
      ENDIF
      ?  SPACE(5) + SPACE(39)
      IF A->PU_LOC <> 'TRANSFER'
         ?? SPACE(5) + '         CONTACT:  ' + MCONTACT2
      ENDIF
      IF MREMARKS <> SPACE(30)
         ?  SPACE(5) + 'NOTES:  ' + MREMARKS
      ENDIF
      ?
   ENDCASE
   *******************************************************************
   
   ?  SPACE(5) + 'CODE' + SPACE(2) + '  QTY' + SPACE(2) + 'DESCRIPTION' + SPACE(34) + 'CASE WT     TOTAL WT  '
   IF MTYPE3 <> 'X'
      IF MTYPE2 = 'X' .AND. MBIL_NAME = 'INVENTORY'
         *** LEAVE THIS BLANK
      ELSE
         ?? ' PRICE/CS'
      ENDIF
   ELSE
      ?? ' LOT NBR'
   ENDIF
   ?  SPACE(5) + '======' + SPACE(1) + '====' + SPACE(2) + '===================================' + SPACE(10) + '=======   ==========  '
   IF MTYPE2 = 'X' .AND. MBIL_NAME = 'INVENTORY'
      *** LEAVE THIS BLANK
   ELSE
      ?? ' ========'
   ENDIF
   ?
   SELECT B
   IF MTYPE2 <> 'X'
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
   ENDIF
   
   MPAGE_NBR = 1
   MCOUNT = 0
   
   DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
      IF PROD_DESC = SPACE(4) .OR. QTY = 0 
         SKIP
         LOOP
      ENDIF

      MCOUNT = MCOUNT + 1
      IF MCOUNT > 12
         DO CONF_HD
         MCOUNT = 1
      ENDIF
      STORE SPACE(4) TO MPART0
      STORE SPACE(6) TO MPART1
      STORE SPACE(8) TO MPART2, MPART3, MPART6
      STORE SPACE(9) TO MPART3_X
      STORE SPACE(20) TO MPART4
      STORE SPACE(13) TO MPART5
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      IF B->FRH_FRZ <> SPACE(2)
         SEEK 'F' + B->FRH_FRZ
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,6) TO MPART1
         ENDIF
      ENDIF
      IF B->GRADE <> SPACE(1)
         SEEK 'G' + B->GRADE
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,8) TO MPART2
         ENDIF
      ENDIF
      
      IF SUBSTR(B->PACKAGED,1,1) <> SPACE(1)
         SEEK 'D' + SUBSTR(B->PACKAGED,1,1)
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,8) TO MPART3
         ENDIF
      ENDIF
      IF SUBSTR(B->PACKAGED,2) <> SPACE(1)
         SEEK 'K' + SUBSTR(B->PACKAGED,2)
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,9) TO MPART3_X
         ENDIF
      ELSE
         DO CASE
         CASE SUBSTR(B->PACKAGED,1,1) = 'I'
            STORE 'ICE PACK' TO MPART3
         CASE SUBSTR(B->PACKAGED,1,1) = 'L'
            STORE 'CHILL PK' TO MPART3
         ENDCASE
      ENDIF
      
      IF MPART3 = SPACE(8)
         MPART3 = MPART3_X             
      ELSE
         MPART3 = TRIM(MPART3) + ' ' + MPART3_X  
      ENDIF
      
      IF B->PROD_DESC <> 'BROKERAGE'
         SEEK 'R' + B->PROD_DESC
         IF .NOT. EOF()
            STORE DESC TO MPART4 
         ENDIF
      ENDIF
      
      IF B->SIZE <> SPACE(5)
         SEEK 'Z' + B->SIZE
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,13) TO MPART5
         ENDIF
      ENDIF
      *IF B->PACKED <> SPACE(4)
      *   SEEK 'S' + B->PACKED
      *   IF .NOT. EOF()
      *      STORE SUBSTR(DESC,1,8) TO MPART6
      *   ENDIF
      *ENDIF
      SELECT B
      ? SPACE(5) + SUBSTR(PROD_DESC,1,6) + SPACE(1)
      ?? TRANSFORM(QTY, '@Z 9999') + SPACE(2)
      MPRT_LINE = ' '
      MPART1 = TRIM(MPART1)
      MPART2 = TRIM(MPART2)
      MPART3 = TRIM(MPART3)
      MPART4 = TRIM(MPART4)
      MPART5 = TRIM(MPART5)
      MPART6 = TRIM(MPART6)
      
      MLEN1 = LEN(MPART1)
      MLEN2 = LEN(MPART2)
      MLEN3 = LEN(MPART3)
      MLEN4 = LEN(MPART4)
      MLEN5 = LEN(MPART5)
      MLEN6 = LEN(MPART6)
      
      IF MLEN1 <> 0
         MPRT_LINE = MPRT_LINE + MPART1 + ' '
      ENDIF
      IF MLEN2 <> 0
         MPRT_LINE = MPRT_LINE + MPART2 + ' '
      ENDIF
      IF MLEN4 <> 0
         MPRT_LINE = MPRT_LINE + MPART4 + ' '
      ENDIF
      IF MLEN5 <> 0
         MPRT_LINE = MPRT_LINE + MPART5 + ' '
      ENDIF
      IF MLEN6 <> 0
         MPRT_LINE = MPRT_LINE + MPART6 + ' '
      ENDIF
      IF MLEN3 <> 0
         MPRT_LINE = MPRT_LINE + MPART3 + ' '
      ENDIF
      MPRT_LINE = TRIM(SUBSTR(MPRT_LINE,2))
      MTOT_LEN = LEN(MPRT_LINE)
      IF MTOT_LEN > 49
         ?? SUBSTR(MPRT_LINE,1,49)
         MTOT_LEN = 49
      ELSE
         ?? MPRT_LINE
      ENDIF
      MDIFF = 50 - MTOT_LEN
      ?? SPACE(MDIFF)             
      IF SUBSTR(B->PACKED,1,1) = 'B'
         ?? SUBSTR(B->PACKED,2) + ' '
      ELSE
         DO CASE
         CASE MTYPE2 = 'X' .AND. B->PROD_DESC = '47184' .AND. A->BBUYCODE = ' 189'
            ?? '37  '
         CASE MTYPE2 = 'X' .AND. B->PROD_DESC = '36429' .AND. A->BBUYCODE = ' 226'
            ?? '30  '
         CASE MTYPE2 = 'X' .AND. B->PROD_DESC = '36089' .AND. (A->BBUYCODE = ' 263' .OR. A->BBUYCODE = ' 268' .OR. A->BBUYCODE = ' 225' .OR. A->BBUYCODE = ' 233')
            ?? '39  '
         CASE MTYPE2 = 'X' .AND. (B->PROD_DESC = '65521' .OR. B->PROD_DESC = '65543') .AND. A->BBUYCODE = '  96'
            ?? '32.5'
         CASE MTYPE2 = 'X' .AND. (B->PROD_DESC = '51160' .OR. B->PROD_DESC = '51221') .AND. (A->BBUYCODE = ' 244' .OR. A->BBUYCODE = ' 231' .OR. A->BBUYCODE = '  84' .OR. A->BBUYCODE = ' 189' .OR. A->BBUYCODE = ' 256')
            ?? 'AVWT'
         OTHERWISE
            ?? B->PACKED
         ENDCASE
      ENDIF
      ?? SPACE(1)
      IF SUBSTR(B->PACKED,1,1) = 'B'
         STORE VAL(SUBSTR(B->PACKED,2)) TO MCS_WT
      ELSE
         STORE VAL(PACKED) TO MCS_WT
      ENDIF
      MLBS = ROUND((MCS_WT * B->QTY),2)
      IF MLBS = 0
         DO CASE
         CASE MTYPE2 = 'X' .AND. B->PROD_DESC = '47184' .AND. A->BBUYCODE = ' 189'
            ?? TRANSFORM(37 * B->QTY, '999,999.99') + SPACE(3)
         CASE MTYPE2 = 'X' .AND. B->PROD_DESC = '36429' .AND. A->BBUYCODE = ' 226'
            ?? TRANSFORM(30 * B->QTY, '999,999.99') + SPACE(3)
         CASE MTYPE2 = 'X' .AND. B->PROD_DESC = '36089' .AND. (A->BBUYCODE = ' 263' .OR. A->BBUYCODE = ' 268' .OR. A->BBUYCODE = ' 225' .OR. A->BBUYCODE = ' 233')
            ?? TRANSFORM(39 * B->QTY, '999,999.99') + SPACE(3)
         CASE MTYPE2 = 'X' .AND. (B->PROD_DESC = '65521' .OR. B->PROD_DESC = '65543') .AND. A->BBUYCODE = '  96'
            ?? TRANSFORM(32.5 * B->QTY, '999,999.99') + SPACE(3)
         CASE MTYPE2 = 'X' .AND. B->PROD_DESC = '51221' .AND. A->BBUYCODE = ' 256'
            ?? TRANSFORM(32 * B->QTY, '999,999.99') + SPACE(3)
         CASE MTYPE2 = 'X' .AND. (B->PROD_DESC = '51160' .OR. B->PROD_DESC = '51221') .AND. (A->BBUYCODE = ' 244' .OR. A->BBUYCODE = ' 231' .OR. A->BBUYCODE = '  84' .OR. A->BBUYCODE = ' 189')
            **?? TRANSFORM(32 * B->QTY, '999,999.99') + SPACE(3)
            ?? TRANSFORM(B->QTY, '999,999.99') + SPACE(3)
         OTHERWISE
            ** ONLY PRINT CWT LBS ON SUPPLIER NOTIFICATIONS
            IF MTYPE2 = 'X' .OR. MTYPE3 = 'X' 
               ?? SPACE(12)
            ELSE
               ?? TRANSFORM(B->LBS, '999,999.99') + SPACE(3)
            ENDIF
         ENDCASE
      ELSE
         ?? TRANSFORM(MLBS, '999,999.99') + SPACE(3)
      ENDIF
      
      DO CASE
      CASE MTYPE1 = 'X'
         ** IF SHIPPED FROM ALBERTVILLE, PUT A TBD, EMMAUS OR CUSTOM CUT
         IF A->PU_LOC <> 'TRANSFER' .AND. (MSUP_NAME = 'ALBERTVILLE QUALITY' .OR. MSUP_NAME = 'EMMAUS FOODS' .OR. MSUP_NAME = 'AMERICOLD/ALBERTVILLE CUSTOM')
            ?? '  TBD'
         ELSE
            ?? TRANSFORM(PUR_PRICE, '@Z 99.9999')
         ENDIF
      CASE MTYPE2 = 'X'
         IF MBIL_NAME <> 'INVENTORY'
            IF MBIL_NAME = 'RACETRAC PETROLEUM'
               ?? '  TBD'
            ELSE
               ?? TRANSFORM(SEL_PRICE, '@Z 99.9999')
            ENDIF
         ENDIF
      OTHERWISE
         IF OUT_LOT = 'P'  .OR. (OUT_LOT = 'U' .AND. A->SUP_CODE = ' 207')
            ?? 'TBD'
         ELSE
            ?? OUT_LOT
         ENDIF
      ENDCASE
      
      ?
      SKIP
   ENDDO
   IF MTYPE1 = 'X'
      IF MSAMP_RQST = 'Y'
         ?
         ?
         ?
         ?
         ? SPACE(5)
         DO SAMP_BOX
         
         ****OLD WAY HERE
         ******* SET DOUBLE WIDE
         ****?? CHR(27) + 'W1' 
         *** SET DOUBLE HIGH             
         ****?? CHR(27) + 'w1' 
         *** TURN ON EMPHASIZED
         ****?? CHR(27) + 'G'        
         ****?? 'SAMPLE REQUEST'
         *** TURN OFF DOUBLE WIDE
         ****?? CHR(27) + 'W0'
         *** TURN QFF DOUBLE HEIGHT       
         ****?? CHR(27) + 'w0' 
         *** TURN OFF EMPHASIZED
         ****?? CHR(27) + 'H'
         
         ?
         ? SPACE(5) + 'Ship One Case Each of the                   Notify Customer Service at AmeriChicken Inc'
         ? SPACE(5) + 'Above Product(s) to:                        When Product has Shipped with Tracking Info'
         ? SPACE(5) + '--------------------------------            ------------------------------------------'
         ? SPACE(5) + 'Customer Service                            Phone:  573-651-6485'
         ? SPACE(5) + '1330 Copper Drive                           Fax:    573-651-4669'                      
         ? SPACE(5) + 'Cape Girardeau, MO  63701                   Email:  customerservice@americhicken.com'
         ? SPACE(5) + 'Phone: 573-651-3940'
         ?       
      ENDIF
   ENDIF
   IF MTYPE3 = 'X'
      ? SPACE(5) + REPLICATE('=',91)
   ENDIF
   ?
   
   EJECT
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   
   MPRINTITC = 'COPY C:\COMPINFO\' + MPRT_FILE + ' ' + MPRINTER3
   
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTITC
   ENDIF
ENDDO

PUBLIC MNET_DAYS, MLET_CRD, MGUARAN, MACTIVE, MBEG_DATE, MEND_DATE
PUBLIC MPAY_NAME, MPAY_STRT, MPAY_CITY, MPAY_STATE, MPAY_ZIP, MPAY_ZIP4, MPAY_AREA, MPAY_PHONE
RETURN
* EOF: CONFIRM1.PRG


*Formatted by: ToolBox Ver. 1.2  on 10/5/16 at 4:55 PM.
