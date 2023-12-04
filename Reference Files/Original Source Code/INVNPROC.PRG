************************ 
*  FILE NAME: INVNPROC.PRG
*  BY: 
*  DATE: July 10,1991      
*  DESC:
*  CALLED BY:
*  DATA FILES:
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

SET PROCEDURE TO INVNPROC

STORE ' ' TO MSELECTION
DO WHILE MSELECTION <> '9'
   CLOSE DATA
   CLEAR
   @ 00,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 01,00 SAY MPROGRAM + ' - MAIN MENU'
   @ 2,0 to 25,79
   
   @ 03,10 SAY '1 - View Lot Info'    
   @ 05,10 SAY '2 - Add/Change Lot Information'
   @ 07,10 SAY '3 - Add/Change Shipment Information'   
   @ 09,10 SAY '4 - Display/Print Current Inventory'
   @ 11,10 SAY '5 - Reports'
   @ 13,10 SAY '6 - Display/Print Activity for Freezer/Product/Time'
   @ 15,10 SAY '7 - Print Inventory Summary (Optional Cutoff Date)'
   @ 17,10 SAY '8 - File Maintenance'
   @ 19,10 say 'D - Delete Old Pending Entries'
   @ 21,10 SAY '9 - Exit'
   
   STORE '1' TO MSELECTION
   @ 22,02 SAY 'CHOICE: '
   @ 22,10 GET MSELECTION PICTURE '@!'
   READ
   
   *CLEAR GETS
   *@ 22,09 SAY ' '
   *MSELECTION = INKEY(60)
   *IF MSELECTION = 0
   *   SET COLOR TO W/N
   *   CLEAR
   *   SET COLOR TO W+/B+,W+/R+
   *   MSELECTION = INKEY(0)
   *   MSELECTION = '0'
   *ELSE
   *   MSELECTION = CHR(MSELECTION)
   *ENDIF
   
   DO CASE
   CASE MSELECTION = 'D'
      DO IPENDUPD
      MSELECTION = ' '
   CASE MSELECTION = '1'
      DO IVIEWCHG
      MSELECTION = ' '
   CASE MSELECTION = '2'
      DO LOT_INFO
      *DO LOT_COST
      MSELECTION = ' '
   CASE MSELECTION = '3'
      DO LOT_SHIP
      MSELECTION = ' '
   CASE MSELECTION = '4'
      MPAGE = 0
      MMORE = .T.
      MPAGE_LEN = 23
      MSEL_FREEZ = SPACE(32)
      MSEL_PROD = SPACE(6)
      DO WHILE MMORE
         
         CLEAR
         @ 00,00 SAY MCOMPANY
         @ 01,68 SAY DATE()
         @ 01,00 SAY MPROGRAM + ' - DISPLAY/PRINT INVENTORY SUMMARY'
         @ 2,0 to 22,79
         MPRT_DISP = 'D'
         MSEL_PROD = SPACE(6)
         MOPT_HOLD = 'Y'
         *IF MPASSWORD = 'ADM'
         *   MYES_NO = 'Y'
         *ELSE
         MYES_NO = 'N'
         *ENDIF
         MACTION = 2
         MHP_OPT = 'N'
         MQA_OPT = 'B '
         DO WHILE MACTION = 2
            @ 05,3 SAY '  Print (P) or Display (D) Report:' get MPRT_DISP PICTURE '@!'
            @ 07,3 SAY '      Enter Optional Product Code: '
            @ 09,3 SAY '  Enter Optional Freezer Location: '
            @ 07,38 GET MSEL_PROD PICTURE '@!'
            @ 09,38 GET MSEL_FREEZ PICTURE '@!'
            @ 11,3 SAY 'Include PENDING Activity (Y/N):' GET MOPT_HOLD PICTURE '@!' VALID(MOPT_HOLD = 'Y' .OR. MOPT_HOLD = 'N')
            IF MPASSWORD = 'ADM'
               @ 13,3 SAY 'For Print: Include Remaining Dollar Amount (Y/N): ' GET MYES_NO PICTURE '@!' VALID(MYES_NO = 'Y' .OR. MYES_NO = 'N')
            ENDIF
            @ 15,3 SAY 'Select Regular (Non-QA Hold) Product (R) -or- Q Hold Product  (Q*):' 
            @ 16,3 SAY '                                         -or- BOTH (Reg & QA) (B ):' GET MQA_OPT PICTURE '@!' VALID(MQA_OPT = 'R' .OR. MQA_OPT = 'Q' .OR. MQA_OPT = 'B')

            @ 18,3 SAY 'Select Not-Holiday (Not-50)  Product (N) -or- Holiday Product (H): '
            @ 19,3 SAY '                                         -or- BOTH (Reg & 50) (B): ' GET MHP_OPT PICTURE '@!' VALID(MHP_OPT = 'N' .OR. MHP_OPT = 'H' .OR. MHP_OPT = 'B')
            
            STORE 1 TO MACTION
            @ 24,0 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue    2. Edit    3. Finished/Cancel'          
            READ
            @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
            READ
         ENDDO
         IF MACTION = 3
            MMORE = .F.
            LOOP
         ENDIF
         SELECT B
         USE
         
         *** DO SOME CLEANUP HERE
         SELECT B
         DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT", .F.
         
         SELECT A
         DO FOX_USE WITH "HINVEN", .F.
         SET FILTER TO LOT_NBR <> 'U'
         GOTO TOP
         
         DO WHILE .NOT. EOF()
            IF LBS = 0 .AND. CALC_LBS = 0 .AND. CASE_CNT = 0 .AND. CASE_LEFT = 0
               *** NEED TO DELETE THESE RECORDS - LEFTOVER NO ACTIVITY
               SELECT B
               SEEK A->FREEZ_LOC + A->LOT_NBR
               DO WHILE .NOT. EOF() .AND. FREEZ_LOC = A->FREEZ_LOC .AND. LOT_NBR = A->LOT_NBR
                  DO RECLOCK
                  DELETE
                  UNLOCK
                  SKIP
               ENDDO
               SELECT A
               
               DO RECLOCK
               DELETE
               UNLOCK
            ENDIF
            SKIP
         ENDDO
         *** DO MORE CLEANUP ON LEFTOVER UNDETERMINED LOTS
         SELECT A
         **DO FOX_USE WITH "HINVEN", .F.
         SET FILTER TO LOT_NBR = 'U'
         GOTO TOP
         DO WHILE .NOT. EOF()
            
            IF LBS = 0 .AND. CALC_LBS = 0 .AND. CASE_CNT = 0 .AND. CASE_LEFT = 0
               *** NEED TO DELETE THESE RECORDS - LEFTOVER NO ACTIVITY
               SELECT B
               SEEK A->FREEZ_LOC + A->LOT_NBR
               IF EOF()
                  SELECT A
                  DO RECLOCK
                  DELETE
                  UNLOCK
               ELSE
                  IF QTY = 0 .AND. LBS = 0
                     DO RECLOCK
                     DELETE
                     UNLOCK
                     SELECT A
                     DO RECLOCK
                     DELETE
                     UNLOCK
                  ENDIF
               ENDIF
               
            ENDIF
            
            SELECT A
            SKIP
         ENDDO
         
         
         SELECT A
         USE
         SELECT B
         USE
         
         SELECT A
         DO FOX_USE WITH "INVEN", .F.
         
         IF MQA_OPT = 'R'
            SET FILTER TO SOLD_FLG = ' ' .AND. UPPER(NOTE) <> 'HOLD QA'
         ELSE
            IF MQA_OPT = 'Q'
               **SET FILTER TO SOLD_FLG = ' ' .AND. UPPER(NOTE) = 'HOLD QA'
               SET FILTER TO SOLD_FLG = ' ' .AND. UPPER(NOTE) = 'HOLD ' + MQA_OPT
            ELSE
               SET FILTER TO SOLD_FLG = ' '
            ENDIF
         ENDIF
         
         DO CASE
         CASE MSEL_FREEZ <> SPACE(32) .AND. MSEL_PROD <> SPACE(6)
            COPY TO C:\COMPWORK\INVNTMP FOR  FREEZ_LOC = TRIM(MSEL_FREEZ) .AND. PROD_DESC = MSEL_PROD
         CASE MSEL_FREEZ <> SPACE(32)
            COPY TO C:\COMPWORK\INVNTMP FOR FREEZ_LOC = TRIM(MSEL_FREEZ)
         CASE MSEL_PROD <> SPACE(6)
            COPY TO C:\COMPWORK\INVNTMP FOR PROD_DESC = MSEL_PROD
         OTHERWISE
            COPY TO C:\COMPWORK\INVNTMP
         ENDCASE
         
         SELECT B
         USE C:\COMPWORK\INVNTMP5 EXCLUSIVE
         DELETE ALL
         PACK
         APPEND FROM C:\COMPWORK\INVNTMP
         USE
         
         SELECT B
         DO FOX_USE WITH "C:\COMPWORK\INVNTMP5", .T.
         GOTO TOP
         
         IF MOPT_HOLD = 'Y' 
            **** GET ALL THE PENDING LOTS
            SELECT A
            DO FOX_USE WITH "HINVEN", .F.
            IF MQA_OPT = 'R'
               SET FILTER TO SOLD_FLG = ' ' .AND. UPPER(NOTE) <> 'HOLD QA'
            ELSE
               IF MQA_OPT = 'Q'
                  **SET FILTER TO SOLD_FLG = ' ' .AND. UPPER(NOTE) = 'HOLD QA'
                  SET FILTER TO SOLD_FLG = ' ' .AND. UPPER(NOTE) = 'HOLD ' + MQA_OPT
               ELSE
                  SET FILTER TO SOLD_FLG = ' '
               ENDIF
            ENDIF
            DO CASE
            CASE MSEL_FREEZ <> SPACE(32) .AND. MSEL_PROD <> SPACE(6)
               COPY TO C:\COMPWORK\PENDTMP FOR  FREEZ_LOC = TRIM(MSEL_FREEZ) .AND. PROD_DESC = MSEL_PROD
            CASE MSEL_FREEZ <> SPACE(32)
               COPY TO C:\COMPWORK\PENDTMP FOR FREEZ_LOC = TRIM(MSEL_FREEZ)
            CASE MSEL_PROD <> SPACE(6)
               COPY TO C:\COMPWORK\PENDTMP FOR PROD_DESC = MSEL_PROD
               
            OTHERWISE
               COPY TO C:\COMPWORK\PENDTMP
            ENDCASE
            
            SELECT A
            USE C:\COMPWORK\PENDING EXCLUSIVE
            DELETE ALL
            PACK
            
            APPEND FROM C:\COMPWORK\PENDTMP
            
            REPLACE NOTE WITH 'HOLD' FOR NOTE <> 'HOLD QA'
            
            REPLACE ALL CASE_LEFT WITH CASE_CNT
            REPLACE ALL LBS_LEFT WITH  LBS
            USE
            
            SELECT B
            APPEND FROM C:\COMPWORK\PENDING
            
            INDEX ON FREEZ_LOC+LOT_NBR TO C:\COMPWORK\INVNTMP5
            
            DO FOX_USE WITH "C:\COMPWORK\INVNTMP5 INDEX C:\COMPWORK\INVNTMP5", .T.
            
            SELECT A
            DO FOX_USE WITH "HINV_DTL", .F.
            DO WHILE .NOT. EOF()
               IF ACTIVITY = 'IN'
                  SKIP
                  LOOP
               ENDIF
               SELECT B
               SEEK A->FREEZ_LOC + A->LOT_NBR
               REPLACE CASE_COM WITH CASE_COM + (-1 * A->QTY)
               REPLACE LBS_COM  WITH LBS_COM  + (-1 * A->LBS)
               SELECT A
               SKIP
            ENDDO
         ENDIF
         
         SELECT D
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
         
         SELECT C
         DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
         
         SELECT A
         DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
         
         SELECT B
         DO FOX_USE WITH "C:\COMPWORK\INVNTMP5", .T.
         REPLACE ALL SUPPLIER WITH SPACE(40)
         GOTO TOP
         
         DO WHILE .NOT. EOF()
            SELECT A
            SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
            STORE SUP_CODE TO MSUP_CODE
            STORE RSUPCODE TO MRSUPCODE
            STORE BBUYCODE TO MBBUYCODE
            
            SELECT B
            REPLACE FRZR_CODE WITH MBBUYCODE
            
            DO CASE
            CASE RSUPCODE = 'INVN'
               SELECT C
               SEEK MSUP_CODE
               SELECT B
               REPLACE SUPPLIER WITH SUBSTR(C->NAME,1,5)
            OTHERWISE
               SELECT D
               SEEK MRSUPCODE
               SELECT B
               REPLACE SUPPLIER WITH SUBSTR(D->NAME,1,5)
            ENDCASE
            
            SKIP
         ENDDO
         
         SELECT A
         USE
         SELECT C
         USE
         SELECT D
         USE
         
         SELECT B
         DO FOX_USE WITH "C:\COMPWORK\INVNTMP5", .T.
         DO CASE
         CASE MHP_OPT = 'N'
            DELETE FOR SALESMAN = '50'
            PACK
         CASE MHP_OPT = 'H'
            DELETE FOR SALESMAN <> '50'
            PACK
         ENDCASE
         GOTO TOP

         IF MPRT_DISP = 'P'
            **** TOOK OUT ON 10/21/2014
            ***REPLACE SUP_PREFX WITH 'P' FOR NOTE = 'HOLD' .AND. SUBSTR(LOT_NBR,1,1) <> 'U'
            ***REPLACE SUP_PREFX WITH 'U' FOR NOTE = 'HOLD' .AND. SUBSTR(LOT_NBR,1,1)  = 'U'
         ENDIF
         
         **INDEX ON FREEZ_LOC+PROD_DESC +SUP_PREFX TO C:\COMPWORK\INVNTMP5
         INDEX ON FREEZ_LOC+PROD_DESC +substr(dtoc(aniv_date),7) + substr(dtoc(aniv_date),1,2) + substr(dtoc(aniv_date),4,2) TO C:\COMPWORK\INVNTMP5
         DO FOX_USE WITH "C:\COMPWORK\INVNTMP5 INDEX C:\COMPWORK\INVNTMP5", .F.
         **** PRINT THIS OUT
         DO CASE
         CASE MPRT_DISP = 'P'
            MPRT_ACT = 'C'
            DO PRT_SET
            IF MPRT_ACT <> 'C'
               CLOSE DATA
               MMORE = .F.
               LOOP
            ENDIF
            MPAGE_LEN = 56
            
            MPAGE_NO = 0
            MLINE = 99
            
            @ 21,16 SAY SPACE(34)
            @ 21,16 SAY 'PROCESSING/PRINTING......'
            SET CONSOLE OFF
            IF FILE("C:\COMPINFO\PRINTERS.DBF")
               SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
            ELSE
               SET PRINT TO LPT3
            ENDIF
            SET DEVICE TO PRINT
            SET PRINT ON
            
            *** PRINT IN 12 CPI
            ?? chr(27) + '&k4S'
            
            *** LETTER GOTHIC AND BOLDED PRINT
            ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
            
            *** LETTER SIZE PAPER
            ?? CHR(27) + '&l2A'
            
            *** PORTRAIT MODE
            ?? CHR(27) + '&l0O'
            
            MTOT_LBS = 0
            MTOT_CASE = 0
            MTOT_VAL = 0
            STORE 0 TO MGRAND_CUR, MGRAND_COM, MGRAND_AV, MGRAND_TOT
            MCANCEL = .F.
            STORE 0 TO MTEND_QTY, MTEND_VAL, MTEND_COM, MTEND_HOLD, MTEND_HVAL
            DO WHILE .NOT. EOF()
               STORE FREEZ_LOC TO MFREEZ_LOC
               MPRT_FREEZ = .T.
               STORE 0 TO MFREEZ_CUR, MFREEZ_COM, MFREEZ_AV, MFREEZ_TOT
               
               DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC
                  **STORE PROD_DESC + SUP_PREFX TO MPROD_DESC
                  STORE PROD_DESC TO MPROD_DESC
                  STORE 0 TO MPROD_TOT, MPROD_VAL, MPROD_COM
                  STORE NOTE TO MNOTE                  
                  DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. PROD_DESC = MPROD_DESC
                     
                     IF MLINE > MPAGE_LEN
                        IF MLINE <> 99
                           EJECT        
                        ENDIF
                        MPAGE_NO = MPAGE_NO + 1
                        @ 1,0 SAY 'PAGE: ' + STR(MPAGE_NO,2)
                        IF MQA_OPT = 'Q'
                           **@ 1,20 SAY TRIM(MCOMPANY) + ' QA HOLD INVENTORY' + SPACE(13) + DTOC(DATE())
                           @ 1,20 SAY TRIM(MCOMPANY) + ' ' + MQA_OPT + ' HOLD INVENTORY' + SPACE(13) + DTOC(DATE())
                        ELSE
                           IF MQA_OPT = 'R'
                              @ 1,20 SAY TRIM(MCOMPANY) + ' CURRENT INVENTORY' + SPACE(13) + DTOC(DATE())
                           ELSE
                              @ 1,20 SAY TRIM(MCOMPANY) + ' QA & CURRENT INVENTORY' + SPACE(13) + DTOC(DATE())
                           ENDIF
                        ENDIF
                        MLINE = 2
                        IF MYES_NO = 'Y'
                           @ MLINE,0 SAY '                                           BOX     CASE   CASE    CASE          UNIT  REMAINING'
                        ELSE
                           @ MLINE,0 SAY '                                           BOX     CASE   CASE    CASE          '
                        ENDIF
                        MLINE = MLINE + 1
                        IF MYES_NO = 'Y'
                           @ MLINE,0 SAY 'LOT NBR     SUPLR  DATE IN  JUL PK  PROD    SZ     CURR   COMM   AVAIL  ***    PRICE   CURR VAL'
                        ELSE                        
                           @ MLINE,0 SAY 'LOT NBR     SUPLR  DATE IN  JUL PK  PROD    SZ     CURR   COMM   AVAIL  ***    '
                        ENDIF
                        @ MLINE,0 SAY REPLICATE('_',95)
                        MLINE = MLINE + 2
                        MPRT_FREEZ = .T.      
                     ENDIF
                     
                     IF MPRT_FREEZ
                        MLINE = MLINE + 1
                        @ MLINE,0 SAY MFREEZ_LOC
                        STORE LEN(TRIM(MFREEZ_LOC)) TO MLEN
                        @ MLINE,0 SAY REPLICATE('_',MLEN)
                        MPRT_FREEZ = .F.
                        MLINE = MLINE + 2
                     ENDIF
                     IF RSUPCODE = 'INVN'
                        MPRT_SUP = 'F-' + SUBSTR(SUPPLIER,1,3)
                     ELSE
                        MPRT_SUP = SUBSTR(SUPPLIER,1,5)
                     ENDIF
                     
                     @ MLINE,0 SAY LOT_NBR
                     @ MLINE,12 SAY MPRT_SUP
                     @ MLINE,19 SAY SUBSTR(DTOC(ANIV_DATE),1,6) + SUBSTR(DTOC(ANIV_DATE),9)
                     IF SUBSTR(LOT_NBR,1,1) <> 'P' .AND. SUBSTR(LOT_NBR,1,1) <> 'U'
                        @ MLINE,28 SAY STR(PAK_DAY,3) + '/' + STR(PAK_YR,2)
                     ENDIF
                     
                     @ MLINE,28+8 SAY SUBSTR(PROD_DESC,1,6)
                     
                     IF BOX_SZ = 0
                        @ MLINE,34+8 SAY ' CWT'
                     ELSE
                        IF BOX_SZ - INT(BOX_SZ) <> 0
                           @ MLINE,34+8 SAY BOX_SZ PICTURE '99.9' 
                        ELSE
                           @ MLINE,34+8 SAY BOX_SZ PICTURE '9999'
                        ENDIF
                     ENDIF
                     *** NOW - FIGURE OUT WHAT IS LEFT
                     *** EVERYTHING WITH FIVE '*' IN FRONT IS THE LATEST
                     *****@ MLINE,27+8 SAY CASE_LEFT PICTURE '9999'
                     
                     IF SUBSTR(PACKED,1,1) = 'B'
                        MLBS_LEFT = ROUND(CASE_LEFT * BOX_SZ,2)
                        MSTOR_UNIT = STOR_LB
                        @ MLINE,43+8 SAY CASE_LEFT PICTURE '@Z 9999'
                        @ MLINE,50+8 SAY CASE_COM PICTURE '@Z 9999'
                        *** THIS IS LBS
                        **@ MLINE,45 SAY ROUND(CASE_COM * BOX_SZ,2) PICTURE '@Z 999999.99'
                        *** THIS IS AVAILABLE
                        MAVAIL = CASE_LEFT - CASE_COM
                        @ MLINE,58+7 SAY MAVAIL PICTURE '99999'
                        IF SUBSTR(LOT_NBR,1,1) = 'P' .OR. NOTE = 'HOLD Q'
                           **IF NOTE = 'HOLD QA' .AND. MQA_OPT = 'Q'
                           IF NOTE = 'HOLD Q' .AND. MQA_OPT = 'Q'
                              MPROD_TOT = MPROD_TOT + MAVAIL
                           ELSE
                              IF NOTE = 'HOLD QM'
                                 MPROD_TOT = MPROD_TOT + MAVAIL
                              ENDIF
                           ENDIF
                        ELSE
                           MPROD_TOT = MPROD_TOT + MAVAIL
                        ENDIF
                        
                        IF NOTE = 'HOLD'
                           IF NOTE = 'HOLD Q'
                              IF SUBSTR(LOT_NBR,1,1) = 'P'
                                 IF RSUPCODE = 'INVN'
                                    @ MLINE,71 SAY 'IFRZ' + SUBSTR(NOTE,6,2)
                                 ELSE
                                    @ MLINE,71 SAY 'ISUP' + SUBSTR(NOTE,6,2)
                                 ENDIF
                              ELSE
                                 IF SUBSTR(LOT_NBR,1,1) = 'U'
                                    IF FRZR_CODE = 'INVN'
                                       @ MLINE,71 SAY 'OFRZ' + SUBSTR(NOTE,6,2)
                                    ELSE
                                       @ MLINE,71 SAY 'OCUS' + SUBSTR(NOTE,6,2)
                                    ENDIF
                                 ELSE
                                    *@ MLINE,71 SAY '*Q?*'
                                    @ MLINE,71 SAY '*' + SUBSTR(NOTE,6,2) + '*'
                                 ENDIF
                              ENDIF
                              **ENDIF
                           ELSE
                              IF FREEZ_LOC = 'MILLARD' .OR. FREEZ_LOC = 'AMERICOLD GADSDEN'
                                 IF SUBSTR(LOT_NBR,1,1) = 'P'
                                    IF RSUPCODE = 'INVN'
                                       @ MLINE,71 SAY 'IFRZ'
                                    ELSE
                                       @ MLINE,71 SAY 'ISUP'
                                    ENDIF
                                 ELSE
                                    IF SUBSTR(LOT_NBR,1,1) = 'U'
                                       IF FRZR_CODE = 'INVN'
                                          @ MLINE,71 SAY 'OFRZ'
                                       ELSE
                                          @ MLINE,71 SAY 'OCUS'
                                       ENDIF
                                    ENDIF
                                 ENDIF
                              ELSE
                                 IF RSUPCODE = 'INVN'
                                    @ MLINE,71 SAY 'IFRZ'
                                 ELSE
                                    @ MLINE,71 SAY 'ISUP'
                                 ENDIF
                              ENDIF
                           ENDIF
                        ENDIF
                        
                        
                        IF MYES_NO = 'Y'
                           @ MLINE,72+5 SAY PRI_LB PICTURE '99.9999'
                        ENDIF
                        
                        IF SUBSTR(PACKED,1,1) = 'B' .OR. PRI_LB >= 10 .OR. LOT_NBR = 'H0 '
                           MVAL_LEFT = ROUND(CASE_LEFT * PRI_LB,2)
                        ELSE
                           MLBS_LEFT = ROUND(CASE_LEFT * BOX_SZ,2)
                           MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
                        ENDIF
                        
                        IF NOTE <> 'HOLD'
                           IF MYES_NO = 'Y' 
                              @ MLINE,80+5 SAY MVAL_LEFT PICTURE '999,999.99'
                              MPROD_VAL = MPROD_VAL + MVAL_LEFT
                              IF ORIG_PRI <> 0
                                 ****@ MLINE,93 SAY ORIG_PRI PICTURE '99.9999'
                              ENDIF
                           ENDIF
                        ELSE
                        ENDIF
                        *****************************************************                        
                     ELSE
                        @ MLINE,43+8 SAY CASE_LEFT PICTURE '@Z 9999'
                        @ MLINE,50+8 SAY CASE_COM PICTURE '@Z 9999'
                        MAVAIL = CASE_LEFT - CASE_COM
                        @ MLINE,58+7 SAY MAVAIL PICTURE '99999'
                        IF SUBSTR(LOT_NBR,1,1) = 'P' .OR. NOTE = 'HOLD Q'
                           **IF NOTE = 'HOLD QA' .AND. MQA_OPT = 'Q'
                           IF NOTE = 'HOLD Q' .AND. MQA_OPT = 'Q'
                              MPROD_TOT = MPROD_TOT + MAVAIL
                           ELSE
                              IF NOTE = 'HOLD QM'
                                 MPROD_TOT = MPROD_TOT + MAVAIL
                              ENDIF
                           ENDIF
                        ELSE
                           MPROD_TOT = MPROD_TOT + MAVAIL
                        ENDIF
                        
                        IF NOTE = 'HOLD'
                           IF NOTE = 'HOLD Q'
                              IF SUBSTR(LOT_NBR,1,1) = 'P'
                                 IF RSUPCODE = 'INVN'
                                    @ MLINE,71 SAY 'IFRZ' + SUBSTR(NOTE,6,2)
                                 ELSE
                                    @ MLINE,71 SAY 'ISUP' + SUBSTR(NOTE,6,2)
                                 ENDIF
                              ELSE
                                 IF SUBSTR(LOT_NBR,1,1) = 'U'
                                    IF FRZR_CODE = 'INVN'
                                       @ MLINE,71 SAY 'OFRZ' + SUBSTR(NOTE,6,2)
                                    ELSE
                                       @ MLINE,71 SAY 'OCUS' + SUBSTR(NOTE,6,2)
                                    ENDIF
                                 ELSE
                                    *@ MLINE,71 SAY '*Q?*'
                                    @ MLINE,71 SAY '*' + SUBSTR(NOTE,6,2) + '*'
                                 ENDIF
                              ENDIF
                              **ENDIF
                           ELSE
                              IF FREEZ_LOC = 'MILLARD' .OR. FREEZ_LOC = 'AMERICOLD GADSDEN'
                                 IF SUBSTR(LOT_NBR,1,1) = 'P'
                                    IF RSUPCODE = 'INVN'
                                       @ MLINE,71 SAY 'IFRZ'
                                    ELSE
                                       @ MLINE,71 SAY 'ISUP'
                                    ENDIF
                                 ELSE
                                    IF SUBSTR(LOT_NBR,1,1) = 'U'
                                       IF FRZR_CODE = 'INVN'
                                          @ MLINE,71 SAY 'OFRZ'
                                       ELSE
                                          @ MLINE,71 SAY 'OCUS'
                                       ENDIF
                                    ENDIF
                                 ENDIF
                              ELSE
                                 IF RSUPCODE = 'INVN'
                                    @ MLINE,71 SAY 'IFRZ'
                                 ELSE
                                    @ MLINE,71 SAY 'ISUP'
                                 ENDIF
                              ENDIF
                           ENDIF
                        ENDIF
                        
                        *** 
                        IF MYES_NO = 'Y'
                           @ MLINE,72+5 SAY PRI_LB  PICTURE '99.9999'
                        ENDIF
                        IF SUBSTR(PACKED,1,1) = 'B' .OR. PRI_LB >= 10 .OR. LOT_NBR = 'H0 '
                           MVAL_LEFT = ROUND(CASE_LEFT * PRI_LB,2)
                        ELSE
                           IF PACKED = 'CWT'
                              MLBS_LEFT = LBS_LEFT
                              MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
                           ELSE
                              MLBS_LEFT = ROUND(CASE_LEFT * BOX_SZ,2)
                              MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
                           ENDIF
                        ENDIF
                        
                        IF NOTE <> 'HOLD'
                           IF MYES_NO = 'Y'
                              @ MLINE,80+5 SAY MVAL_LEFT PICTURE '999,999.99'
                              MPROD_VAL = MPROD_VAL + MVAL_LEFT
                              IF ORIG_PRI <> 0
                                 **@ MLINE,93 SAY ORIG_PRI PICTURE '99.9999'
                              ENDIF
                           ENDIF
                        ELSE
                        ENDIF
                     ENDIF
                     
                     MPROD_COM  = MPROD_COM + CASE_COM
                     
                     IF SUBSTR(LOT_NBR,1,1) = 'P' .OR. NOTE = 'HOLD QA'
                     ELSE
                        MFREEZ_CUR = MFREEZ_CUR + CASE_LEFT
                     ENDIF
                     
                     MFREEZ_COM = MFREEZ_COM + CASE_COM
                     IF SUBSTR(LOT_NBR,1,1) = 'P' .OR. NOTE = 'HOLD Q'
                        **IF NOTE = 'HOLD QA' .AND. MQA_OPT = 'Q'
                        IF NOTE = 'HOLD Q' .AND. MQA_OPT = 'Q'
                           MFREEZ_AV = MFREEZ_AV + MAVAIL
                        ELSE
                           IF NOTE = 'HOLD QM'
                              MFREEZ_AV = MFREEZ_AV + MAVAIL
                           ENDIF
                        ENDIF
                     ELSE
                        MFREEZ_AV  = MFREEZ_AV  + MAVAIL
                     ENDIF
                     
                     IF NOTE <> 'HOLD QA' .AND. NOTE <> 'HOLD QP'
                        MFREEZ_TOT = MFREEZ_TOT + MVAL_LEFT
                     ENDIF
                     
                     MLINE = MLINE + 1
                     SKIP
                  ENDDO
                  IF SUBSTR(MPROD_DESC,5,1) <> 'P'
                     @ MLINE,28+8 SAY REPLICATE('=',35)
                     IF MYES_NO = 'Y'
                        @ MLINE,72+5 SAY REPLICATE('=',18)
                     ENDIF
                     MLINE = MLINE + 1
                     @ MLINE,28+8 SAY SUBSTR(MPROD_DESC,1,6)
                     @ MLINE,35+8 SAY 'TOTAL:'
                     
                     @ MLINE,57+8 SAY MPROD_TOT PICTURE '99999'
                     IF MYES_NO = 'Y' 
                        MXTOT = MPROD_COM + MPROD_TOT
                        IF MXTOT <> 0
                           MXPRI = ROUND(MPROD_VAL/MXTOT,4)
                           @ MLINE,72+5 SAY MXPRI  PICTURE '99.9999'
                        ENDIF
                        IF MPROD_VAL <> 0
                           @ MLINE,80+5 SAY MPROD_VAL PICTURE '999,999.99'
                        ENDIF
                     ENDIF
                     
                     IF SUBSTR(MPROD_DESC,1,6) <> PROD_DESC
                        MLINE = MLINE + 3
                     ELSE
                        MLINE = MLINE + 2
                     ENDIF
                  ELSE
                     MLINE = MLINE + 2
                  ENDIF
                  
               ENDDO
               @ MLINE,1 SAY 'FREEZER TOTAL:'
               @ MLINE,42+8 SAY MFREEZ_CUR PICTURE '99999'
               @ MLINE,49+8 SAY MFREEZ_COM PICTURE '99999'
               @ MLINE,57+8 SAY MFREEZ_AV PICTURE '99999'
               IF MYES_NO = 'Y'
                  @ MLINE,78+5 SAY MFREEZ_TOT PICTURE '9,999,999.99'
               ENDIF
               MGRAND_CUR = MGRAND_CUR + MFREEZ_CUR
               MGRAND_COM = MGRAND_COM + MFREEZ_COM
               MGRAND_AV  = MGRAND_AV  + MFREEZ_AV
               MGRAND_TOT = MGRAND_TOT + MFREEZ_TOT
               MLINE = MLINE + 2
            ENDDO
            IF MLINE =  99
               @ 4,1 SAY 'NO INVENTORY DATA SELECTED FOR REPORT'                            
            ELSE
               MLINE = MLINE + 1
               @ MLINE,1 SAY 'GRAND TOTALS:'
               @ MLINE,41+8 SAY MGRAND_CUR PICTURE '999999'
               @ MLINE,48+8 SAY MGRAND_COM PICTURE '999999'
               @ MLINE,56+8 SAY MGRAND_AV  PICTURE '999999'
               IF MYES_NO = 'Y'
                  @ MLINE,78+5 SAY MGRAND_TOT PICTURE '9,999,999.99'
               ENDIF
               @ MLINE+1,1 SAY ' '
               
               MDO_TENDER = .F.
               IF MDO_TENDER
                  MLINE = MLINE + 3
                  IF MLINE+2 > MPAGE_LEN
                     IF MLINE <> 99
                        EJECT        
                     ENDIF
                     MPAGE_NO = MPAGE_NO + 1
                     @ 1,0 SAY 'PAGE: ' + STR(MPAGE_NO,2)
                     IF MQA_OPT = 'Q'
                        **@ 1,20 SAY TRIM(MCOMPANY) + ' QA HOLD INVENTORY' + SPACE(13) + DTOC(DATE())
                        @ 1,20 SAY TRIM(MCOMPANY) + ' ' + MQA_OPT + ' HOLD INVENTORY' + SPACE(13) + DTOC(DATE())
                     ELSE
                        @ 1,20 SAY TRIM(MCOMPANY) + ' CURRENT INVENTORY' + SPACE(13) + DTOC(DATE())
                     ENDIF
                     MLINE = 2
                     IF MYES_NO = 'Y'
                        @ MLINE,0 SAY '                                   BOX     CASE   CASE    CASE             UNIT  REMAINING'
                     ELSE
                        @ MLINE,0 SAY '                                   BOX     CASE   CASE    CASE             '
                     ENDIF
                     MLINE = MLINE + 1
                     IF MYES_NO = 'Y'
                        @ MLINE,0 SAY 'LOT NBR     SUPLR  DATE IN  PROD    SZ     CURR   COMM   AVAIL *HOLD*    PRICE   CURR VAL'
                     ELSE
                        @ MLINE,0 SAY 'LOT NBR     SUPLR  DATE IN  PROD    SZ     CURR   COMM   AVAIL *HOLD*    '
                     ENDIF
                     @ MLINE,0 SAY REPLICATE('_',92)
                     MLINE = MLINE + 2
                     MPRT_FREEZ = .T.      
                  ENDIF
                  @ MLINE,1 SAY 'NOTE: TENDER TOTALS/BLENDED AVG:'
                  @ MLINE,49+8 SAY MTEND_COM PICTURE '99999'
                  @ MLINE,57+8 SAY MTEND_QTY PICTURE '99999'
                  IF MYES_NO = 'Y' 
                     MXTOT = MTEND_COM + MTEND_QTY
                     IF MXTOT <> 0
                        MXPRI = ROUND(MTEND_VAL/MXTOT,4)
                        @ MLINE,72+5 SAY MXPRI  PICTURE '99.9999'
                     ENDIF
                     IF MTEND_VAL <> 0
                        @ MLINE,80+5 SAY MTEND_VAL PICTURE '999,999.99'
                     ENDIF
                     MLINE = MLINE + 2
                     @ MLINE,1 SAY 'NOTE: TENDER HOLD/BLENDED TOTALS:'
                     @ MLINE,42+8 SAY MTEND_HOLD PICTURE '99999'
                     MXTOT = MTEND_COM + MTEND_QTY + MTEND_HOLD
                     MXVAL = MTEND_VAL + MTEND_HVAL
                     IF MXTOT <> 0
                        MXPRI = ROUND(MXVAL/MXTOT,4)
                     ELSE
                        MXPRI = 0
                     ENDIF
                     @ MLINE,72+5 SAY MXPRI  PICTURE '99.9999'
                     @ MLINE,80+5 SAY MTEND_HVAL PICTURE '999,999.99'
                  ENDIF
               ENDIF
            ENDIF
            EJECT 
            SET DEVICE TO SCREEN
            SET PRINT OFF
            SET PRINT TO
            SET CONSOLE ON
            IF MPRINTER3 <> 'DONOTPRINT'
               RUN &MPRINTIT3
            ENDIF
            CLOSE DATA
            MMORE = .F.
         OTHERWISE
            
            SELECT B
            CLEAR
            MLINE = 1
            IF MCOMPANY = 'AMERICHICKEN, INC'
               @ MLINE,20 SAY '          AMERICHICKEN, INC.      ' + SPACE(5) + DTOC(DATE())
            ELSE
               @ MLINE,20 SAY '             MIDWEST FOODS        ' + SPACE(5) + DTOC(DATE())
            ENDIF
            MLINE = MLINE + 1
            **IF MYES_NO = 'Y'
            **   @ MLINE,0 SAY '                                 BOX       CASE   CASE   CASE              UNIT '
            **   MLINE = MLINE + 1
            **   @ MLINE,0 SAY ' PROD  FRZR LOT NBR    DATE IN  SIZE       CURR   COMM  AVAIL   *HOLD*    PRICE '
            **ELSE
            @ MLINE,0 SAY '                                         BOX       CASE   CASE   CASE               '
            MLINE = MLINE + 1
            @ MLINE,0 SAY 'PROD   FRZR LOT NBR    JUL PK  DATE IN  SIZE       CURR   COMM  AVAIL  *HOLD*      '
            **ENDIF                                      
            *               123456789012345678901234567890123456789CURR4567890123456789012345678901234567890
            *                        10        20        30        40        50        60        70        80
            @ 4,0 TO 4,79
            MLINE = 5
            STORE 0 TO MTOP_REC
            MCANCEL = .F.
            MGRND_CASE = 0
            MGRND_COMM = 0
            MGRND_AVL  = 0
            DO WHILE .NOT. MCANCEL
               DO WHILE .NOT. EOF() .AND. .NOT. MCANCEL
                  IF MLINE = 5
                     STORE RECNO() TO MTOP_REC
                  ENDIF
                  @ MLINE,0 SAY SUBSTR(PROD_DESC,1,6)
                  IF FREEZ_LOC = 'PREFERRED'
                     @ MLINE,3+4  SAY 'PR' + SUBSTR(FREEZ_LOC,11,2)
                  ELSE
                     @ MLINE,3+4  SAY SUBSTR(FREEZ_LOC,1,4)
                  ENDIF
                  @ MLINE,12 SAY LOT_NBR
                  IF SUBSTR(LOT_NBR,1,1) <> 'P' .AND. SUBSTR(LOT_NBR,1,1) <> 'U'
                     @ MLINE,23 SAY STR(PAK_DAY,3) + '/' + STR(PAK_YR,2)
                  ENDIF
                  @ MLINE,23+8 SAY SUBSTR(DTOC(ANIV_DATE),1,6) + SUBSTR(DTOC(ANIV_DATE),9)
                  
                  IF BOX_SZ = 0
                     @ MLINE,32+8 SAY ' CWT'
                  ELSE
                     IF BOX_SZ - INT(BOX_SZ) <> 0
                        @ MLINE,32+8 SAY BOX_SZ PICTURE '99.9' 
                     ELSE
                        @ MLINE,32+8 SAY BOX_SZ PICTURE '9999'
                     ENDIF
                  ENDIF
                  *** NOW - FIGURE OUT WHAT IS LEFT
                  *** EVERYTHING WITH FIVE '*' IN FRONT IS THE LATEST
                  *****@ MLINE,27 SAY CASE_LEFT PICTURE '9999'
                  IF SUBSTR(PACKED,1,1) = 'B'
                     MLBS_LEFT = ROUND(CASE_LEFT * BOX_SZ,2)
                     MSTOR_UNIT = STOR_LB
                     @ MLINE,43+8 SAY CASE_LEFT PICTURE '@Z 9999'
                     @ MLINE,50+8 SAY CASE_COM PICTURE '@Z 9999'
                     MGRND_COMM = MGRND_COMM + CASE_COM
                     *** THIS IS LBS
                     **@ MLINE,45+8 SAY ROUND(CASE_COM * BOX_SZ,2) PICTURE '@Z 999999.99'
                     *** THIS IS AVAILABLE
                     MAVAIL = CASE_LEFT - CASE_COM
                     @ MLINE,56+8 SAY MAVAIL PICTURE '99999'
                     IF SUBSTR(LOT_NBR,1,1) = 'P' .OR. NOTE = 'HOLD Q'
                        **IF NOTE = 'HOLD QA' .AND. MQA_OPT = 'Q'
                        IF NOTE = 'HOLD Q' .AND. MQA_OPT = 'Q'
                           MGRND_AVL = MGRND_AVL + MAVAIL
                        ELSE
                           IF NOTE = 'HOLD QM'
                              MGRND_AVL = MGRND_AVL + MAVAIL
                           ENDIF
                        ENDIF
                     ELSE
                        MGRND_AVL = MGRND_AVL + MAVAIL
                     ENDIF
                     ***@ MLINE,62 SAY ROUND(MAVAIL * BOX_SZ,2) PICTURE '999999.99'
                     *** 
                     
                     IF NOTE = 'HOLD'
                        IF NOTE = 'HOLD Q'
                           ***IF FREEZ_LOC = 'MILLARD' .OR. FREEZ_LOC = 'AMERICOLD GADSDEN'
                           IF SUBSTR(LOT_NBR,1,1) = 'P'
                              IF RSUPCODE = 'INVN'
                                 @ MLINE,71 SAY 'IFRZ' + SUBSTR(NOTE,6,2)
                              ELSE
                                 @ MLINE,71 SAY 'ISUP' + SUBSTR(NOTE,6,2)
                              ENDIF
                           ELSE
                              IF SUBSTR(LOT_NBR,1,1) = 'U'
                                 IF FRZR_CODE = 'INVN'
                                    @ MLINE,71 SAY 'OFRZ' + SUBSTR(NOTE,6,2)
                                 ELSE
                                    @ MLINE,71 SAY 'OCUS' + SUBSTR(NOTE,6,2)
                                 ENDIF
                              ELSE
                                 *@ MLINE,71 SAY '*Q?*'
                                 @ MLINE,71 SAY '*' + SUBSTR(NOTE,6,2) + '*'
                              ENDIF
                           ENDIF
                           ***ENDIF
                        ELSE
                           IF FREEZ_LOC = 'MILLARD' .OR. FREEZ_LOC = 'AMERICOLD GADSDEN'
                              IF SUBSTR(LOT_NBR,1,1) = 'P'
                                 IF RSUPCODE = 'INVN'
                                    @ MLINE,71 SAY 'IFRZ'
                                 ELSE
                                    @ MLINE,71 SAY 'ISUP'
                                 ENDIF
                              ELSE
                                 IF SUBSTR(LOT_NBR,1,1) = 'U'
                                    IF FRZR_CODE = 'INVN'
                                       @ MLINE,71 SAY 'OFRZ'
                                    ELSE
                                       @ MLINE,71 SAY 'OCUS'
                                    ENDIF
                                 ENDIF
                              ENDIF
                           ELSE
                              IF RSUPCODE = 'INVN'
                                 @ MLINE,71 SAY 'IFRZ'
                              ELSE
                                 @ MLINE,71 SAY 'ISUP'
                              ENDIF
                           ENDIF
                        ENDIF
                     ELSE
                        MGRND_CASE = MGRND_CASE + MAVAIL
                     ENDIF
                     
                     IF SALESMAN = '50'
                       @ MLINE,76 SAY '*50*'
                     ENDIF
                     **IF MYES_NO = 'Y'
                     **   @ MLINE,72 SAY PRI_LB + MSTOR_UNIT PICTURE '99.9999'
                     **ENDIF
                     MPRI_LB = PRI_LB / BOX_SZ
                     MPRI_LB = ROUND(MPRI_LB,4)
                     
                  ELSE
                     @ MLINE,43+8 SAY CASE_LEFT PICTURE '@Z 9999'
                     @ MLINE,50+8 SAY CASE_COM PICTURE '@Z 9999'
                     MGRND_COMM = MGRND_COMM + CASE_COM
                     **@ MLINE,45+8 SAY LBS_COM PICTURE '@Z 999999.99'
                     *** THIS IS AVAILABLE
                     
                     MAVAIL = CASE_LEFT - CASE_COM
                     @ MLINE,56+8 SAY MAVAIL PICTURE '99999'
                     IF SUBSTR(LOT_NBR,1,1) = 'P' .OR. NOTE = 'HOLD Q'
                        **IF NOTE = 'HOLD QA' .AND. MQA_OPT = 'Q'
                        IF NOTE = 'HOLD Q' .AND. MQA_OPT = 'Q'
                           MGRND_AVL = MGRND_AVL + MAVAIL
                        ELSE
                           IF NOTE = 'HOLD QM'
                              MGRND_AVL = MGRND_AVL + MAVAIL
                           ENDIF
                        ENDIF
                     ELSE
                        MGRND_AVL = MGRND_AVL + MAVAIL
                     ENDIF
                     
                     **@ MLINE,62+8 SAY LBS_LEFT - LBS_COM PICTURE '999999.99'
                     IF NOTE = 'HOLD'
                        IF NOTE = 'HOLD Q'
                           **@ MLINE,65+8 SAY '*QA*'
                           @ MLINE,65+8 SAY '*' + SUBSTR(NOTE,6,2) + '*'
                        ELSE
                           IF FREEZ_LOC = 'MILLARD' .OR. FREEZ_LOC = 'AMERICOLD GADSDEN'
                              IF SUBSTR(LOT_NBR,1,1) = 'P'
                                 IF RSUPCODE = 'INVN'
                                    @ MLINE,65+8 SAY 'IFRZ'
                                 ELSE
                                    @ MLINE,65+8 SAY 'ISUP'
                                 ENDIF
                              ELSE
                                 MGRND_CASE = MGRND_CASE + CASE_LEFT - CASE_COM
                                 IF SUBSTR(LOT_NBR,1,1) = 'U'
                                    IF FRZR_CODE = 'INVN'
                                       @ MLINE,65+8 SAY 'OFRZ'
                                    ELSE
                                       @ MLINE,65+8 SAY 'OCUS'
                                    ENDIF
                                 ENDIF
                              ENDIF
                           ELSE
                              IF RSUPCODE = 'INVN'
                                 @ MLINE,65+8 SAY 'IFRZ'
                              ELSE
                                 @ MLINE,65+8 SAY 'ISUP'
                              ENDIF
                           ENDIF
                        ENDIF
                     ELSE
                        MGRND_CASE = MGRND_CASE + CASE_LEFT - CASE_COM
                     ENDIF
                     
                     IF SALESMAN = '50'
                       @ MLINE,76 SAY '*50*'
                     ENDIF
                     *** 
                     ***IF MYES_NO = 'Y'
                     ***   @ MLINE,72 SAY PRI_LB + STOR_LB PICTURE '99.9999'
                     ***ENDIF
                  ENDIF
                  SELECT B
                  MLINE = MLINE + 2
                  SKIP
                  
                  IF MLINE > MPAGE_LEN .OR. EOF()
                     IF EOF()
                        @ 24,44+8 SAY 'TOT AVAIL:'
                        ***@ 24,55+8 SAY MGRND_CASE - MGRND_COMM PICTURE '999999'
                        **@ 24,55+8 SAY MGRND_CASE PICTURE '999999'
                        @ 24,55+8 SAY MGRND_AVL PICTURE '999999'
                     ENDIF
                     MCHOICE = ' '
                     @ 24,0 SAY "ENTER=NEXT PG   P=PREV PG   M=MENU  " GET MCHOICE PICTURE '@!'
                     READ
                     DO CASE
                     CASE MCHOICE = 'M'
                        SELECT B
                        GOTO BOTTOM
                        SKIP
                        MCANCEL = .T.
                        LOOP
                     CASE MCHOICE = 'P'
                        IF MLINE = 5
                           GOTO TOP
                        ELSE
                           MLINE = 5           
                           @ 5,0 CLEAR
                           GOTO MTOP_REC
                           SKIP -10
                        ENDIF
                     OTHERWISE
                        @ 5,0 CLEAR
                        MLINE = 5
                     ENDCASE
                  ENDIF            
                  
               ENDDO
               IF EOF()
                  
                  MCANCEL = .T.
               ENDIF
            ENDDO
         ENDCASE   
      ENDDO
      
      CLOSE DATA
      MSELECTION = ' '
   CASE MSELECTION = '5'
      DO IRPTS
      MSELECTION = ' '
   CASE MSELECTION = '6'
      DO FREEZINQ
      MSELECTION = ' '
      
      ***** OLD COSTING STUFF
      MDO_COST = .F.
      IF MDO_COST
         MMORE = .T.
         DO WHILE MMORE
            MPAGE = 0
            MPAGE_LEN = 23
            MSEL_FREEZ = SPACE(32)
            MSEL_PROD = SPACE(6)
            CLEAR
            @ 00,00 SAY MCOMPANY
            @ 01,68 SAY DATE()
            @ 01,00 SAY MPROGRAM + ' - DISPLAY INVENTORY COSTING'
            @ 2,0 to 22,79
            MPRT_DISP = 'D'
            MSEL_PROD = SPACE(10)
            MOPT_HOLD = 'N'
            MYES_NO = 'Y'
            MACTION = 2
            DO WHILE MACTION = 2
               **@ 05,3 SAY '  Print (P) or Display (D) Report:' get MPRT_DISP PICTURE '@!'
               @ 07,3 SAY '               Enter Product Code: '
               @ 09,3 SAY '  Enter Optional Freezer Location: '
               @ 07,38 GET MSEL_PROD PICTURE '@!'
               @ 09,38 GET MSEL_FREEZ PICTURE '@!'
               *@ 11,3 SAY 'Include HOLD Activity (Y/N):' GET MOPT_HOLD PICTURE '@!' VALID(MOPT_HOLD = 'Y' .OR. MOPT_HOLD = 'N')
               STORE 1 TO MACTION
               @ 24,0 SAY 'Action: ' + STR(MACTION,1)
               @ 24,13 SAY '1. Continue    2. Edit    3. Finished/Cancel'          
               READ
               @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
               READ
               IF MSEL_PROD = SPACE(10)
                  MACTION = 3
               ENDIF
               
            ENDDO
            IF MACTION = 3
               MMORE = .F.
               LOOP
            ENDIF
            SELECT B
            USE
            
            SELECT A
            DO FOX_USE WITH "INVEN", .F.
            SET FILTER TO SOLD_FLG = ' '
            GOTO TOP
            DO CASE
            CASE MSEL_FREEZ <> SPACE(32)
               COPY TO INVNCOST FOR FREEZ_LOC = TRIM(MSEL_FREEZ)
               
               SELECT B
               DO FOX_USE WITH "INVNCOST", .T.
               
               IF MSEL_PROD <> SPACE(10)
                  IF MSEL_PROD = 'TENDERS'
                     DELETE FOR PROD_DESC <> '8901' .AND. PROD_DESC <> '8910' .AND. PROD_DESC <> '8989' .AND. PROD_DESC <> '8999'
                  ELSE
                     DELETE FOR PROD_DESC <> TRIM(MSEL_PROD)
                  ENDIF
               ENDIF
               USE
               
            CASE MSEL_PROD <> SPACE(10)
               IF MSEL_PROD = 'TENDERS'
                  COPY TO INVNCOST FOR  PROD_DESC = '8901' .OR. PROD_DESC = '8910' .OR. PROD_DESC = '8989' .OR. PROD_DESC = '8999'
               ELSE
                  COPY TO INVNCOST FOR  PROD_DESC = TRIM(MSEL_PROD)
               ENDIF
            OTHERWISE
               COPY TO INVNCOST
            ENDCASE
            
            SELECT B
            DO FOX_USE WITH "INVNCOST", .T.
            
            MDO = .F.
            IF MDO
               IF MOPT_HOLD = 'Y'
                  **** GET ALL THE PENDING LOTS
                  SELECT A
                  DO FOX_USE WITH "HINVEN", .F.
                  DO CASE
                  CASE MSEL_FREEZ <> SPACE(32)
                     COPY TO PENDING FOR FREEZ_LOC = TRIM(MSEL_FREEZ)
                     IF MSEL_PROD <> SPACE(10)
                        *IF MSEL_PROD = 'TENDERS'
                        *DELETE FOR PROD_DESC <> '8901' .AND. PROD_DESC <> '8910' .AND. PROD_DESC <> '8989' .AND. PROD_DESC <> '8999'
                        *ELSE
                        *DELETE FOR PROD_DESC <> MSEL_PROD
                        *ENDIF
                     ENDIF
                  CASE MSEL_PROD <> SPACE(4)
                     IF MSEL_PROD = 'TENDERS'
                        COPY TO PENDING FOR  PROD_DESC = '8901' .OR. PROD_DESC = '8910' .OR. PROD_DESC = '8989' .OR. PROD_DESC = '8999'
                     ELSE
                        COPY TO PENDING FOR  PROD_DESC = TRIM(MSEL_PROD)
                     ENDIF
                  OTHERWISE
                     COPY TO PENDING
                  ENDCASE
                  DO FOX_USE WITH "PENDING", .F.
                  REPLACE NOTE WITH 'HOLD' FOR NOTE <> 'HOLD Q'
                  REPLACE ALL CASE_LEFT WITH CASE_CNT
                  REPLACE ALL LBS_LEFT WITH  LBS
                  USE
                  
                  SELECT B
                  APPEND FROM PENDING
                  
                  INDEX ON FREEZ_LOC+LOT_NBR TO INVNCOST
                  DO FOX_USE WITH "INVNCOST INDEX INVNCOST", .F.
                  
                  SELECT A
                  DO FOX_USE WITH "HINV_DTL", .F.
                  DO WHILE .NOT. EOF()
                     IF ACTIVITY = 'IN'
                        SKIP
                        LOOP
                     ENDIF
                     SELECT B
                     SEEK A->FREEZ_LOC + A->LOT_NBR
                     DO RECLOCK
                     REPLACE CASE_COM WITH CASE_COM + (-1 * A->QTY)
                     REPLACE LBS_COM  WITH LBS_COM  + (-1 * A->LBS)
                     UNLOCK
                     SELECT A
                     SKIP
                  ENDDO
               ENDIF
            ENDIF
            
            SELECT B
            DO FOX_USE WITH "INVNCOST", .T.
            *** TOOK OUT ON 10/21/2014
            ***REPLACE SUP_PREFX WITH 'P' FOR NOTE = 'HOLD'
            ***INDEX ON FREEZ_LOC+PROD_DESC +SUP_PREFX TO INVNCOST
            INDEX ON FREEZ_LOC+PROD_DESC TO INVNCOST
            
            DO FOX_USE WITH "INVNCOST INDEX INVNCOST", .F.
            
            IF MSEL_PROD = 'TENDERS'
               STORE 'TENDERS' TO MPROD_DESC
            ELSE
               STORE PROD_DESC TO MPROD_DESC
            ENDIF
            STORE 0 TO MPROD_TOT, MPROD_VAL, MPROD_COM
            
            DO WHILE .NOT. EOF()
               IF SUBSTR(PACKED,1,1) = 'B'
                  MLBS_LEFT = ROUND(CASE_LEFT * BOX_SZ,2)
                  MSTOR_UNIT = STOR_LB
                  MAVAIL = CASE_LEFT - CASE_COM
                  MPROD_TOT = MPROD_TOT + MAVAIL
                  IF SUBSTR(PACKED,1,1) = 'B' .OR. PRI_LB >= 10 .OR. LOT_NBR = 'H0 '
                     MVAL_LEFT = ROUND(MAVAIL * PRI_LB,2)
                  ELSE
                     MLBS_LEFT = ROUND(MAVAIL * BOX_SZ,2)
                     MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
                  ENDIF
                  
                  IF NOTE <> 'HOLD'
                     MPROD_VAL = MPROD_VAL + MVAL_LEFT
                  ENDIF
               ELSE
                  MAVAIL = CASE_LEFT - CASE_COM
                  MPROD_TOT = MPROD_TOT + MAVAIL
                  IF SUBSTR(PACKED,1,1) = 'B' .OR. PRI_LB >= 10 .OR. LOT_NBR = 'H0 '
                     MVAL_LEFT = ROUND(MAVAIL * PRI_LB,2)
                  ELSE
                     IF PACKED = 'CWT'
                        MLBS_LEFT = LBS_LEFT
                        MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
                     ELSE
                        MLBS_LEFT = ROUND(MAVAIL * BOX_SZ,2)
                        MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
                     ENDIF
                  ENDIF
                  
                  IF NOTE <> 'HOLD'
                     MPROD_VAL = MPROD_VAL + MVAL_LEFT
                  ENDIF
               ENDIF
               MPROD_COM  = MPROD_COM + CASE_COM
               SKIP
            ENDDO
            
            CLEAR
            @ 1,13 SAY TRIM(MCOMPANY) + ' CURRENT INVENTORY COSTING'
            
            MLINE = 2
            
            @ MLINE,0 SAY REPLICATE('-',79)
            
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'PRODUCT: ' + MPROD_DESC
            MLINE = MLINE + 2
            @ MLINE,1 SAY 'INVEN QTY   INVEN VALUE    AVG PRI'
            *              12345678901234567890123456789012345678901
            *                       10        20        30   
            *                99,999     999,999.99    99.9999'
            MLINE = MLINE + 1
            
            IF MPROD_TOT <> 0
               MXPRI = ROUND(MPROD_VAL/MPROD_TOT,4)
            ELSE
               MXPRI = 0
            ENDIF
            @ MLINE,3  SAY MPROD_TOT PICTURE '99,999'
            @ MLINE,14 SAY MPROD_VAL PICTURE '999,999.99'
            @ MLINE,28 SAY MXPRI PICTURE '99.9999'
            MLINE = MLINE + 3
            
            
            
            MDO_AGAIN = .T.
            DO WHILE MDO_AGAIN
               MLINE = 10
               STORE 0 TO MPUR_QTY, MPUR_PRI
               STORE 0 TO MAVG_PRI, MOTH_QTY, MOTH_QTY1
               @ MLINE,1 SAY 'CALCULATION CASE 1----------------------'
               MLINE = MLINE + 1
               
               @ MLINE,1 SAY 'PURCHASE QTY  PURCHASE PRI  CALC AVG PRI'
               @ MLINE+1,4 GET MPUR_QTY PICTURE '99999'
               @ MLINE+1,18 GET MPUR_PRI PICTURE '99.9999'
               
               STORE MLINE+1 TO MSAVE1
               MLINE = MLINE + 4
               @ MLINE,1 SAY 'CALCULATION CASE 2----------------------'
               MLINE = MLINE + 1
               @ MLINE,1 SAY 'TARGET PRICE     PURCH QTY     PURCH PRI'
               MLINE = MLINE + 1
               @ MLINE,1 SAY '                       500'
               @ MLINE,4 GET MAVG_PRI PICTURE '99.9999'
               STORE MLINE TO MSAVE2
               MLINE = MLINE + 1
               @ MLINE,1 SAY '                      1000'
               MLINE = MLINE + 1
               @ MLINE,1 SAY '                      1500'
               MLINE = MLINE + 1
               @ MLINE,1 SAY '                      2000'
               MLINE = MLINE + 1
               @ MLINE,1 SAY '              OTHER:      '
               @ MLINE,22 GET MOTH_QTY PICTURE '99999'
               MLINE = MLINE + 1
               @ MLINE,1 SAY '              OTHER:      '
               @ MLINE,22 GET MOTH_QTY1 PICTURE '99999'
               MLINE = MLINE + 1
               READ
               IF MPUR_QTY = 0 .AND. MPUR_PRI = 0 .AND. MAVG_PRI = 0
                  MDO_AGAIN = .F.
                  LOOP
               ENDIF
               IF MPUR_QTY <> 0 .OR. MPUR_PRI <> 0
                  MCALC1 = ROUND(MPUR_QTY * MPUR_PRI,2)
                  IF MCALC1+MPROD_TOT <> 0
                     MCALC2 = ROUND((MPROD_VAL+MCALC1)/(MPROD_TOT+MPUR_QTY),4)
                  ELSE
                     MCALC2 = 0
                  ENDIF
                  @ MSAVE1,33 SAY MCALC2 PICTURE '99.9999'
               ENDIF
               
               
               IF MAVG_PRI <> 0
                  M500 = ROUND(((MAVG_PRI * (MPROD_TOT+500)) - MPROD_VAL) / 500,4)
                  @ MSAVE2,33 SAY M500 PICTURE '99.9999'
                  
                  M1000 = ROUND(((MAVG_PRI * (MPROD_TOT+1000)) - MPROD_VAL) / 1000,4)
                  @ MSAVE2+1,33 SAY M1000 PICTURE '99.9999'
                  
                  M1500 = ROUND(((MAVG_PRI * (MPROD_TOT+1500)) - MPROD_VAL) / 1500,4)
                  @ MSAVE2+2,33 SAY M1500 PICTURE '99.9999'
                  
                  M2000 = ROUND(((MAVG_PRI * (MPROD_TOT+2000)) - MPROD_VAL) / 2000,4)
                  @ MSAVE2+3,33 SAY M2000 PICTURE '99.9999'
                  
                  MOTH  = ROUND(((MAVG_PRI * (MPROD_TOT+MOTH_QTY)) - MPROD_VAL) / MOTH_QTY,4)
                  @ MSAVE2+4,33 SAY MOTH PICTURE '99.9999'
                  
                  MOTH1  = ROUND(((MAVG_PRI * (MPROD_TOT+MOTH_QTY1)) - MPROD_VAL) / MOTH_QTY1,4)
                  @ MSAVE2+5,33 SAY MOTH1 PICTURE '99.9999'
                  
                  
               ENDIF
               
               STORE 'PRESS RETURN TO CONTINUE' TO MWAIT
               @ MLINE+1,1 GET MWAIT
               READ
            ENDDO
            
            CLOSE DATA
         ENDDO
      ENDIF
      
      MSELECTION = ' '
      
   CASE MSELECTION = '7'
      **** CHANGE THIS REPORT HERE FOR HOLD STUFF
      DO BROKRPT
      MSELECTION = ' '
   CASE MSELECTION = '6'
      
      
      MSELECTION = ' '
   CASE MSELECTION = '8'
      DO IMAINT   
      MSELECTION = ' '
   ENDCASE
ENDDO
CLOSE DATA
CLEAR
RETURN   


PROCEDURE LOT_INFO
SELECT C
DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
SELECT A
DO FOX_USE WITH "INVEN INDEX INVNLOT, INVNPO, INVNLOC, INVNSOLD, INVNINBR, INVNANIV", .F.
MMORE = .T.
MINIT_NM = .T.
DO WHILE MMORE
   
   IF MINIT_NM
      MLOT_NBR    = SPACE(10)
      MFREEZ_LOC  = SPACE(32)
      MSALESMAN   = SPACE(2)
      MPO_NBR     = SPACE(4)
      MPO_SUFFIX  = SPACE(1)
      MI_NBR      = 0        
   ENDIF
   
   MANIV_DATE  = CTOD(' ')
   MSUPPLIER   = SPACE(40)
   MPAID_DATE  = CTOD(' ')
   MPROD_DESC  = SPACE(6)
   MDIV_CODE   = '  '
   MPROD_SIZE  = SPACE(10)
   MBOX_SIZE   = SPACE(5)
   MLBS        = 0        
   MCASE_CNT   = 0        
   MPRI_LB     = 0
   MPRO_PRI    = 0
   MVALUE      = 0
   MLBS_LEFT   = 0        
   MCASE_LEFT  = 0
   MVAL_LEFT   = 0
   
   MNOTE       = SPACE(72)
   MLOT_FD = .F.
   MPROD_DISP  = SPACE(25)
   MPAK_YR   = 0
   MPAK_DAY  = 0
   
   MACTION = 2
   DO WHILE MACTION = 2
      
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - SELECT LOT'
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      @  5, 5 SAY 'Enter one of the following search fields:'
      @  8, 5 SAY 'Lot Nbr:'
      @ 11, 5 SAY '  I Nbr:'
      @ 14, 5 say 'Freezer:'
      @ 17, 5 say ' PO Nbr:   -    -' 
      @  8,14 GET MLOT_NBR PICTURE '@!'
      @ 11,14 GET MI_NBR   PICTURE '#####'
      @ 14,14 GET MFREEZ_LOC PICTURE '@!'
      @ 17,14 GET MSALESMAN PICTURE '@!'
      @ 17,17 GET MPO_NBR PICTURE '####'
      @ 17,22 GET MPO_SUFFIX PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MACTION = 3 .OR. (MLOT_NBR = SPACE(10) .AND. MFREEZ_LOC = SPACE(4) .AND. MPO_NBR = SPACE(4) .AND. MI_NBR = 0)
      MMORE = .F.
      LOOP
   ENDIF 
   DO CASE
   CASE MLOT_NBR <> SPACE(10)
      SET ORDER TO 1
      STORE MLOT_NBR TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF() .OR. DELETED()
         @ 23,0 CLEAR
         STORE 'Y' TO MYES_NO
         @ 24,05 SAY 'LOT NBR NOT ON FILE - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
         READ
         IF MYES_NO = 'Y'
            DO FILELOCK   
            APPEND BLANK 
            UNLOCK
            SELECT F
            DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
            MI_NBR = LAST_INBR
            MI_NBR = MI_NBR + 1
            DO RECLOCK
            REPLACE LAST_INBR WITH MI_NBR
            UNLOCK 
            SELECT A
            DO RECLOCK
            REPLACE I_NBR WITH MI_NBR
            UNLOCK
         ELSE 
            MINIT_NM = .F.              
            LOOP
         ENDIF
      ELSE               
         STORE RECNO() TO MFST_REC
         SKIP
         IF LOT_NBR = SRCH_ARG
            MADD = .F.
            MFOUND = .F.
            DO MULTILOT 
            DO CASE 
            CASE MADD
               DO FILELOCK        
               APPEND BLANK
               UNLOCK
               SELECT F
               DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
               MI_NBR = LAST_INBR
               MI_NBR = MI_NBR + 1
               DO RECLOCK
               REPLACE LAST_INBR WITH MI_NBR
               UNLOCK 
               SELECT A
               DO RECLOCK
               REPLACE I_NBR WITH MI_NBR
               UNLOCK
            CASE MFOUND
               DO STORLOT
               SELECT C
               SEEK 'R' + MPROD_DESC
               MPROD_DISP = DESC
               SELECT A
            OTHERWISE 
               MINIT_NM = .T.
               LOOP 
            ENDCASE
         ELSE
            GOTO MFST_REC
            MADD = .F.
            MFOUND = .T.
            DO STORLOT
            SELECT C
            SEEK 'R' + MPROD_DESC
            MPROD_DISP = DESC
            SELECT A
         ENDIF
      ENDIF
      
   CASE MFREEZ_LOC <> SPACE(32)
      SET ORDER TO 3
      STORE TRIM(MFREEZ_LOC) TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF() .OR. DELETED()
         @ 23,0 CLEAR
         STORE 'Y' TO MYES_NO
         @ 24,05 SAY 'NO LOTS ON FILE FOR THIS FREEZER - DO YOU WANT TO ADD (Y/N)? ' get MYES_NO PICTURE '@!'
         READ
         IF MYES_NO = 'Y'
            DO FILELOCK   
            APPEND BLANK 
            UNLOCK
            SELECT F
            DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
            MI_NBR = LAST_INBR
            MI_NBR = MI_NBR + 1
            DO RECLOCK
            REPLACE LAST_INBR WITH MI_NBR
            UNLOCK 
            SELECT A
            DO RECLOCK
            REPLACE I_NBR WITH MI_NBR
            UNLOCK
         ELSE 
            MINIT_NM = .F.              
            LOOP
         ENDIF
      ELSE               
         STORE RECNO() TO MFST_REC
         SKIP
         IF FREEZ_LOC = SRCH_ARG
            GOTO MFST_REC
            MADD = .F.
            MFOUND = .F.
            DO MULTIFRZ  
            DO CASE 
            CASE MADD
               DO FILELOCK        
               APPEND BLANK
               UNLOCK
               SELECT F
               DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
               MI_NBR = LAST_INBR
               MI_NBR = MI_NBR + 1
               DO RECLOCK
               REPLACE LAST_INBR WITH MI_NBR
               UNLOCK 
               SELECT A
               DO RECLOCK
               REPLACE I_NBR WITH MI_NBR
               UNLOCK
            CASE MFOUND
               DO STORLOT
               SELECT C
               SEEK 'R' + MPROD_DESC
               MPROD_DISP = DESC
               SELECT A
            OTHERWISE 
               MINIT_NM = .T.
               LOOP 
            ENDCASE
         ELSE
            GOTO MFST_REC
            DO STORLOT
            SELECT C
            SEEK 'R' + MPROD_DESC
            MPROD_DISP = DESC
            SELECT A
         ENDIF
      ENDIF
      
   CASE MPO_NBR <> SPACE(4)
      SET ORDER TO 2
      STORE MSALESMAN+MPO_NBR+MPO_SUFFIX TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF() .OR. DELETED()
         @ 23,0 CLEAR
         STORE 'Y' TO MYES_NO
         @ 24,05 SAY 'PO NBR NOT ON FILE - DO YOU WANT TO ADD (Y/N)? ' get MYES_NO PICTURE '@!'
         READ
         IF MYES_NO = 'Y'
            DO FILELOCK   
            APPEND BLANK 
            UNLOCK 
            SELECT F
            DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
            MI_NBR = LAST_INBR
            MI_NBR = MI_NBR + 1
            DO RECLOCK
            REPLACE LAST_INBR WITH MI_NBR
            UNLOCK 
            SELECT A
            DO RECLOCK
            REPLACE I_NBR WITH MI_NBR
            UNLOCK
         ELSE 
            MINIT_NM = .F.              
            LOOP
         ENDIF
      ELSE               
         STORE RECNO() TO MFST_REC
         MADD = .F.
         MFOUND = .F.
         DO MULTIPO  
         DO CASE 
         CASE MADD
            DO FILELOCK        
            APPEND BLANK
            UNLOCK
            SELECT F
            DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
            MI_NBR = LAST_INBR
            MI_NBR = MI_NBR + 1
            DO RECLOCK
            REPLACE LAST_INBR WITH MI_NBR
            UNLOCK 
            SELECT A
            DO RECLOCK
            REPLACE I_NBR WITH MI_NBR
            UNLOCK
         CASE MFOUND
            DO STORLOT
            SELECT C
            SEEK 'R' + MPROD_DESC
            MPROD_DISP = DESC
            SELECT A
         OTHERWISE 
            MINIT_NM = .T.
            LOOP 
         ENDCASE
      ENDIF
      
   CASE MI_NBR <> 0       
      SET ORDER TO 5
      STORE STR(MI_NBR,5) TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF()                 
         @ 23,0 CLEAR
         MWAIT = ' '
         @ 24,05 SAY 'I NBR NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT 
         READ
         MINIT_NM = .F.              
         LOOP
      ELSE               
         DO STORLOT
         SELECT C
         SEEK 'R' + MPROD_DESC
         MPROD_DISP = DESC
         SELECT A
      ENDIF
      
   ENDCASE
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - VIEW/UPDATE LOT INFORMATION'
   DO TEXTLOT
   MACTION = 2
   DO WHILE MACTION = 2
      DO GETLOT
      STORE 1 TO MACTION
      @ 25,01 SAY 'Action: ' + STR(MACTION,1)  
      IF MCASE_CNT = 0 .AND. MCASE_LEFT = 0
         @ 25,13 SAY '1. Continue    2. Edit     3. Cancel     4. Delete Lot'
         @ 25,09 GET MACTION PICTURE '9' RANGE 1,4
      ELSE
         @ 25,13 SAY '1. Continue    2. Edit     3. Cancel'
         @ 25,09 GET MACTION PICTURE '9' RANGE 1,3
      ENDIF
      @25,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MACTION = 3 
      MINIT_NM = .T.
      LOOP
   ENDIF
   IF MACTION = 4
      STORE LOT_NBR   TO MLOT_NBR
      STORE FREEZ_LOC TO MFREEZ_LOC
      DO RECLOCK
      DELETE
      UNLOCK
      
      SELECT B
      ***DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT", .F.
      SEEK MFREEZ_LOC + MLOT_NBR
      DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT_NBR
         DO RECLOCK
         DELETE
         UNLOCK
         SKIP
      ENDDO
      SELECT A
      STORE 'Lot Deleted - Press Return to Continue' TO MWAIT
      @ 25,0 CLEAR
      @ 25,1 GET MWAIT
      READ
   ELSE
      DO REPLLOT
   ENDIF
   MINIT_NM = .T.
ENDDO
RETURN


PROCEDURE TEXTLOT 
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 23,79
@ 04,01 SAY '      LOT #:' 
@ 04,25 SAY 'FREEZER:'

@ 06,03 SAY 'PO #:'  
@ 06,11 SAY '-'
@ 06,16 SAY '-'

@ 06,24 SAY 'DIVISION CODE: '
@ 06,46 SAY 'I #:'
@ 06,59 SAY 'DATE IN:'

@ 08,01 SAY '   SUPPLIER:'
@ 08,55 SAY 'DATE PAID:'

@ 10,01 SAY '    PRODUCT:'
@ 11,01 SAY '  PROD SIZE:'
@ 11,35 SAY ' BOX SIZE:'
@ 11,58 SAY 'PAK DT:    /'


@ 13,01 SAY 'NOTE'

@ 15,01 SAY '   UNITS IN:'
@ 15,34 SAY 'UNITS LEFT:'

@ 17,01 SAY '   CASES IN:'
@ 17,34 SAY 'CASES LEFT:'

@ 19,01 SAY 'PRI/UNIT IN:'
@ 19,33 SAY 'CUR COST/UN:'

@ 21,01 SAY '   $ AMT IN:'
@ 21,34 SAY 'CUR COST $:'

RETURN


PROCEDURE GETLOT 
@ 04,14 GET MLOT_NBR   PICTURE '@!'
@ 04,34 GET MFREEZ_LOC PICTURE '@!'

@ 06,09 GET MSALESMAN  PICTURE '##'
@ 06,12 GET MPO_NBR    PICTURE '####'
@ 06,17 GET MPO_SUFFIX PICTURE '@!'
@ 06,39 GET MDIV_CODE  PICTURE '##'
@ 06,51 SAY MI_NBR     PICTURE '#####'
@ 06,68 GET MANIV_DATE           

@ 08,14 GET MSUPPLIER  PICTURE '@!'

@ 08,66 GET MPAID_DATE 

@ 10,14 GET MPROD_DESC PICTURE '@!'
IF MPROD_DESC <> SPACE(6)
   @ 10,21 SAY 'DESC: ' + MPROD_DISP
ENDIF

@ 11,14 GET MPROD_SIZE PICTURE '@!'
@ 11,46 GET MBOX_SIZE  PICTURE '@!'
@ 11,66 GET MPAK_DAY   PICTURE '999'
@ 11,70 GET MPAK_YR    PICTURE '99'

@ 13,06 GET MNOTE      PICTURE '@!'

@ 15,14 GET MLBS       PICTURE '###,###,###.##'
@ 17,14 GET MCASE_CNT  PICTURE '####'
@ 19,14 GET MPRI_LB    PICTURE '##.####'
READ
IF MPROD_DESC <> SPACE(6)
   SELECT C
   SEEK 'R' + MPROD_DESC
   MPROD_DISP = DESC
   SELECT A
   @ 10,21 SAY 'DESC: '
   @ 10,27 GET MPROD_DISP
ENDIF

MVAL1  = MLBS * MPRI_LB    
IF MVAL1 <> 0
   MVAL = INT(MVAL1*100)
   IF (ABS(MVAL1) * 100) - ABS(MVAL) > .49
      IF MVAL1 >= 0
         MVAL1 = (MVAL + 1) / 100
      ELSE
         MVAL1 = (MVAL - 1) / 100
      ENDIF
   ELSE
      MVAL1 = MVAL / 100
   ENDIF
ENDIF
MVALUE = MVAL1 

@ 21,14 GET MVALUE     PICTURE '###,###.##'
DO CALCCUR2
@ 15,46 GET MLBS_LEFT  PICTURE '###,###,###.##'
@ 17,46 GET MCASE_LEFT PICTURE '####'
IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
   MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
ELSE
   MPRO_PRI = 0
   MVAL_LEFT = 0
ENDIF
@ 19,46 GET MPRO_PRI   PICTURE '##.####'
@ 21,46 GET MVAL_LEFT  PICTURE '###,###.##'
CLEAR GETS
RETURN

PROCEDURE STORLOT 
MLOT_NBR    = LOT_NBR      
MSALESMAN   = SALESMAN
MPO_NBR     = PO_NBR  
MPO_SUFFIX  = PO_SUFFIX
MANIV_DATE  = ANIV_DATE
MFREEZ_LOC  = FREEZ_LOC
MPROD_DESC  = PROD_DESC
MDIV_CODE   = DIV_CODE
MPROD_SIZE  = PROD_SIZE
MBOX_SIZE   = BOX_SIZE
MLBS        = LBS      
MCASE_CNT   = CASE_CNT 
MPRI_LB     = PRI_LB
MVALUE      = VALUE
MRSUPCODE   = RSUPCODE
MSUPPLIER   = SUPPLIER
MPAID_DATE  = PAID_DATE
MNOTE       = NOTE
MI_NBR      = I_NBR
MVAL_LEFT   = VAL_LEFT
MLBS_LEFT   = LBS_LEFT
MPAK_YR     = PAK_YR
MPAK_DAY    = PAK_DAY

DO CALC_CUR

IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
   MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
ELSE
   MPRO_PRI = 0
   MVAL_LEFT = 0
ENDIF
SELECT F
DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
SEEK A->RSUPCODE
IF .NOT. EOF()
   STORE NAME TO MSUPPLIER
ENDIF
USE
SELECT A
RETURN

PROCEDURE REPLLOT 
DO FILELOCK
REPLACE LOT_NBR   WITH MLOT_NBR
REPLACE SALESMAN  WITH MSALESMAN
REPLACE PO_NBR    WITH MPO_NBR
REPLACE PO_SUFFIX WITH MPO_SUFFIX
REPLACE FREEZ_LOC WITH MFREEZ_LOC
REPLACE ANIV_DATE WITH MANIV_DATE
REPLACE PROD_DESC WITH MPROD_DESC
REPLACE DIV_CODE  WITH MDIV_CODE
REPLACE PROD_SIZE WITH MPROD_SIZE
REPLACE BOX_SIZE  WITH MBOX_SIZE
REPLACE LBS       WITH MLBS      
REPLACE CASE_CNT  WITH MCASE_CNT 
REPLACE PRI_LB    WITH MPRI_LB
REPLACE VALUE     WITH MVALUE
REPLACE SUPPLIER  WITH MSUPPLIER
REPLACE PAID_DATE WITH MPAID_DATE
REPLACE NOTE      WITH MNOTE
REPLACE I_NBR     WITH MI_NBR
REPLACE PAK_YR    WITH MPAK_YR
REPLACE PAK_DAY   WITH MPAK_DAY
DO CALC_CUR

IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
   MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
ELSE
   MPRO_PRI = 0
   MVAL_LEFT = 0
ENDIF

REPLACE VAL_LEFT  WITH MVAL_LEFT
REPLACE CASE_LEFT WITH MCASE_LEFT
REPLACE PRO_PRI   WITH MPRO_PRI
REPLACE LBS_LEFT  WITH MLBS_LEFT 
IF LBS_LEFT = 0 .OR. CASE_LEFT = 0
   REPLACE SOLD_FLG WITH 'Y'
ELSE
   REPLACE SOLD_FLG WITH ' '
ENDIF
UNLOCK
RETURN

PROCEDURE MULTIPO 
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MATCH SELECT'
@ 3,0 TO 21,79
@  5, 2 SAY "PO'S MATCHING YOUR INPUT.  PLEASE SELECT ACTION."
@ 6,5 say 'PO NBR     LOT NBR  I NBR   FREEZER               PRODUCT       BOX SZ'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC

MMULT = .T.
DO WHILE MMULT
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. SALESMAN+PO_NBR+PO_SUFFIX = SRCH_ARG .AND. MLINE < 20
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      IF SALESMAN <> '  '
         @ MLINE, 5 SAY SALESMAN + '-'
      ENDIF  
      @ MLINE,8 SAY PO_NBR
      IF PO_SUFFIX <> ' '
         @ MLINE,12 SAY '-' + PO_SUFFIX
      ENDIF
      @ MLINE,16 SAY LOT_NBR
      @ MLINE,25 SAY I_NBR PICTURE '#####'
      @ MLINE,33 SAY SUBSTR(FREEZ_LOC,1,20)
      SELECT C
      SEEK 'R'+A->PROD_DESC
      @ MLINE,55 SAY SUBSTR(DESC,1,12)
      SELECT A
      @ MLINE,69 SAY BOX_SIZE
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. SALESMAN+PO_NBR+PO_SUFFIX = SRCH_ARG 
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Selection Number: '
   @ 22,19 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add PO/Lot   5.Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MFOUND = .T.
      MMULT = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add PO/Lot   5.Cancel'
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
      MADD = .T. 
      MMULT = .F.
      
   CASE MACTION = 5
      MMULT = .F.
      
   ENDCASE
   
ENDDO
RETURN


PROCEDURE MULTIFRZ
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MATCH SELECT'
@ 3,0 TO 21,79
@  5, 2 SAY "PO'S MATCHING YOUR INPUT.  PLEASE SELECT ACTION."
@ 6,5 say 'PO NBR     LOT NBR  I NBR   FREEZER               PRODUCT       BOX SZ'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC

MMULT = .T.
DO WHILE MMULT
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. FREEZ_LOC = SRCH_ARG .AND. MLINE < 20
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      IF SALESMAN <> '  '
         @ MLINE, 5 SAY SALESMAN + '-'
      ENDIF  
      @ MLINE,8 SAY PO_NBR
      IF PO_SUFFIX <> ' '
         @ MLINE,12 SAY '-' + PO_SUFFIX
      ENDIF
      @ MLINE,16 SAY LOT_NBR
      @ MLINE,25 SAY I_NBR PICTURE '#####'
      @ MLINE,33 SAY SUBSTR(FREEZ_LOC,1,20)
      SELECT C
      SEEK 'R'+A->PROD_DESC
      @ MLINE,55 SAY SUBSTR(DESC,1,12)
      SELECT A
      @ MLINE,69 SAY BOX_SIZE
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. FREEZ_LOC = SRCH_ARG                   
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Selection Number: '
   @ 22,19 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add PO/Lot   5.Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MFOUND = .T.
      MMULT = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add PO/Lot   5.Cancel'
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
      MADD = .T. 
      MMULT = .F.
      
   CASE MACTION = 5
      MMULT = .F.
      
   ENDCASE
   
ENDDO
RETURN

PROCEDURE MULTILOT
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MATCH SELECT'
@ 3,0 TO 21,79
@  5, 2 SAY "PO'S MATCHING YOUR INPUT.  PLEASE SELECT ACTION."
@ 6,5 say 'LOT NBR  I NBR   PO NBR     FREEZER               PRODUCT       BOX SZ'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC

MMULT = .T.
DO WHILE MMULT
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. LOT_NBR = SRCH_ARG .AND. MLINE < 20
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      @ MLINE,5  SAY LOT_NBR
      **@ MLINE,14 SAY I_NBR PICTURE '#####'
      IF SALESMAN <> '  '
         @ MLINE,22 SAY SALESMAN + '-'
      ENDIF  
      @ MLINE,25 SAY PO_NBR
      IF PO_SUFFIX <> ' '
         @ MLINE,29 SAY '-' + PO_SUFFIX
      ENDIF
      @ MLINE,33 SAY SUBSTR(FREEZ_LOC,1,20)
      SELECT C
      SEEK 'R'+A->PROD_DESC
      @ MLINE,55 SAY SUBSTR(DESC,1,12)
      SELECT A
      @ MLINE,69 SAY BOX_SIZE
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. LOT_NBR = SRCH_ARG                   
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Selection Number: '
   @ 22,19 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add PO/Lot   5.Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MFOUND = .T.
      MMULT = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add PO/Lot   5.Cancel'
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
      MADD = .T. 
      MMULT = .F.
      
   CASE MACTION = 5
      MMULT = .F.
      
   ENDCASE
   
ENDDO
RETURN

PROCEDURE IRPTS
STORE ' ' TO MRPT_SEL   
DO WHILE MRPT_SEL <> '9'
   CLOSE DATA
   CLEAR
   @ 00,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 01,00 SAY MPROGRAM + ' - REPORTS MENU'
   @ 2,0 to 25,79
   
   @ 03,10 SAY '1 - Print Activity Report (In/Out/Both)'
   @ 05,10 SAY '2 - Print Report of Lots With Approaching Anniversary Dates'
   @ 07,10 SAY '3 - Print Activity Report (In/Out/Both) by PO Nbr'
   @ 09,10 SAY '4 - Print Problem List - Orders Coming out Diff Price Than In'
   @ 11,10 say '5 - Print Daily Activity Report'
   @ 13,10 SAY '6 - Print Activity for Selected Lot'
   @ 15,10 SAY '7 - Display/Print PAK Date - Product Activity by Freezer/Cust/Date'
   
   *@ 10,10 SAY '4 - Print Inventory Product Summary'
   *@ 12,10 SAY '5 - PRINT REMAINING PRODUCT REPORT BY I NUMBER'
   *@ 14,10 SAY '6 - PRINT REPORT BY LOT NBR/OR DATE ORDER'     
   *@ 16,10 SAY '7 - PRINT BY LOT NUMBER USING CUTOFF ACTIVITY DATE'
   *@ 18,10 SAY '8 - PRINT ACTIVITY BY OPTIONAL SUPPLIER'
   @ 19,10 SAY '9 - Exit'
   
   STORE ' ' TO MRPT_SEL
   @ 21,02 SAY 'CHOICE: '
   @ 21,10 GET MRPT_SEL   PICTURE '9'
   *CLEAR GETS
   *@ 21,09 SAY ' '
   READ
   
   **MRPT_SEL   = INKEY(60)
   **IF MRPT_SEL   = 0
   **   SET COLOR TO W/N
   **   CLEAR
   **   DO CASE
   **   CASE MUSER = 'KEN'
   **      SET COLOR TO W+/B+,W+/R+
   **   CASE MUSER = 'BOB'
   **      *SET COLOR TO GR+/B+,GR+/GR    
   **      SET COLOR TO W+/B+,W+/R+
   **   OTHERWISE
   **      SET COLOR TO W/N,N/W
   **   ENDCASE
   
   **   MRPT_SEL = INKEY(0)
   **   MRPT_SEL = '0'
   **ELSE
   **   MRPT_SEL = CHR(MRPT_SEL)
   **ENDIF
   
   DO CASE
   CASE MRPT_SEL = '7'
      MMORE = .T.
      DO WHILE MMORE
         CLOSE DATA
         CLEAR
         @ 00,00 SAY MCOMPANY
         @ 01,68 SAY DATE()
         @ 01,00 SAY MPROGRAM + ' - View Activity for Selected Product/Pak Date'
         @ 2,0 to 22,79
         MPROD_DESC = SPACE(6)
         STORE 0 TO MPAK_DAY, MPAK_YR
         STORE 'D' TO MORDER
         STORE 'D' TO MDISP_PRT
         STORE 'N' TO MOPT_FRZ, MOPT_CUST
         STORE CTOD('') TO MBEGIN, MEND
         
         @ 04,3 SAY 'Enter Product Code:' GET MPROD_DESC PICTURE '@!'
         @ 06,3 SAY 'Select SORT Order - by DATE (D), FREEZER (F), or CUSTOMER (C): ' GET MORDER PICTURE '@!' VALID(MORDER = 'D' .OR. MORDER = 'F' .OR. MORDER = 'C')
         @ 08,3 SAY 'DISPLAY Info (D) -or- PRINT Report (P): ' GET MDISP_PRT PICTURE '@!'
         
         @ 11,3 say 'Select Optional Freezer (Y/N): ' GET MOPT_FRZ PICTURE '@!' VALID(MOPT_FRZ = 'Y' .OR. MOPT_FRZ = 'N')
         @ 13,3 SAY 'Select Optional Customer(Y/N): ' GET MOPT_CUST PICTURE '@!' VALID(MOPT_CUST = 'Y' .OR. MOPT_CUST = 'N')
         @ 15,10 SAY 'Select Optional: Pak Date:    /'
         @ 15,38 GET MPAK_YR PICTURE  '##'
         @ 15,41 GET MPAK_DAY PICTURE '###'
         @ 17,3 SAY 'Select Optional Activity Date:  Begin:               End:'
         @ 17,42 GET MBEGIN
         @ 17,61 GET MEND
         
         READ
         
         IF MPROD_DESC = SPACE(6)
            MMORE = .F.
            LOOP
         ENDIF
         IF MEND <> CTOD('') .AND. MBEGIN = CTOD('')
            STORE MEND TO MBEGIN
         ENDIF
         IF MBEGIN <> CTOD('') .AND. MEND = CTOD('')
            STORE MBEGIN TO MEND
         ENDIF
         STORE SPACE(4) TO MBUY_CODE, MFRZ_CODE
         STORE SPACE(32) TO MBUY_NAME, MFRZ_NAME
         IF MOPT_CUST = 'Y' .OR. MOPT_FRZ = 'Y'
            SAVE SCREEN TO MGRACE
         ENDIF
         IF MOPT_CUST = 'Y'
            MNAME_FD = .F.
            SET PROC TO BUY_PROC
            DO BUY_SEL1
            IF MNAME_FD
               STORE BUY_CODE TO MBUY_CODE
               STORE NAME     TO MBUY_NAME
            ENDIF
         ENDIF
         
         IF MOPT_FRZ = 'Y'
            MNAME_FD = .F.
            SET PROC TO SUP_PROC
            DO SUP_SEL1
            IF MNAME_FD
               STORE SUP_CODE TO MFRZ_CODE
               STORE NAME     TO MFRZ_NAME
            ENDIF
         ENDIF
         IF MOPT_CUST = 'Y' .OR. MOPT_FRZ = 'Y'
            RESTORE SCREEN FROM MGRACE
         ENDIF
         @ 19,1 SAY 'PROCESSING.... PLEASE WAIT'
         *************************************************
         SELECT C
         USE DTLTMP EXCLUSIVE
         DELETE ALL
         PACK
         
         SELECT A
         DO FOX_USE WITH "INVEN", .F.
         IF MPAK_YR <> 0 .OR. MPAK_DAY <> 0
            SET FILTER TO PAK_YR = MPAK_YR .AND. PAK_DAY = MPAK_DAY .AND. PROD_DESC = MPROD_DESC
         ELSE
            SET FILTER TO PROD_DESC = MPROD_DESC
         ENDIF
         GOTO TOP
         
         SELECT B
         DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT", .F.
         MTOT_CASE = 0
         SELECT A
         DO WHILE .NOT. EOF()
            STORE FREEZ_LOC TO MFREEZ_LOC
            STORE LOT_NBR TO MLOT_NBR
            SELECT B
            SEEK MFREEZ_LOC + MLOT_NBR
            DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT_NBR
               IF MBEGIN <> CTOD('')
                  IF ACT_DATE < MBEGIN .OR. ACT_DATE > MEND
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               SELECT C
               APPEND BLANK
               REPLACE FREEZ_LOC WITH B->FREEZ_LOC
               REPLACE PROD_DESC WITH A->PROD_DESC
               REPLACE ACT_DATE  WITH B->ACT_DATE
               REPLACE ACT_CODE  WITH B->ACT_CODE
               REPLACE SALESMAN  WITH B->SALESMAN
               REPLACE PO_NBR    WITH B->PO_NBR
               REPLACE PO_SUFFIX WITH B->PO_SUFFIX
               REPLACE QTY       WITH B->QTY
               REPLACE LOT_NBR   WITH B->LOT_NBR
               REPLACE PAK_YR    WITH A->PAK_YR
               REPLACE PAK_DAY   WITH A->PAK_DAY
               REPLACE SHIP_PRI  WITH A->PRI_LB
               MTOT_CASE = MTOT_CASE + QTY
               SELECT B
               SKIP
            ENDDO
            SELECT A
            SKIP
         ENDDO
         
         *************************************************
         
         SELECT A
         DO FOX_USE WITH "HINVEN INDEX HINVNLOC", .F.
         IF MPAK_YR <> 0 .OR. MPAK_DAY <> 0
            SET FILTER TO PAK_YR = MPAK_YR .AND. PAK_DAY = MPAK_DAY .AND. PROD_DESC = MPROD_DESC
         ELSE
            SET FILTER TO PROD_DESC = MPROD_DESC
         ENDIF
         
         GOTO TOP
         
         SELECT B
         DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT", .F.
         
         
         *************************************************
         SELECT A
         DO WHILE .NOT. EOF()
            STORE FREEZ_LOC TO MFREEZ_LOC
            STORE LOT_NBR TO MLOT_NBR
            SELECT B
            SEEK MFREEZ_LOC + MLOT_NBR
            DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT_NBR
               IF MBEGIN <> CTOD('')
                  IF ACT_DATE < MBEGIN .OR. ACT_DATE > MEND
                     SKIP
                     LOOP
                  ENDIF
               ENDIF
               SELECT C
               APPEND BLANK
               REPLACE FREEZ_LOC WITH B->FREEZ_LOC
               REPLACE PROD_DESC WITH A->PROD_DESC
               REPLACE ACT_DATE  WITH B->ACT_DATE
               REPLACE ACT_CODE  WITH B->ACT_CODE
               REPLACE SALESMAN  WITH B->SALESMAN
               REPLACE PO_NBR    WITH B->PO_NBR
               REPLACE PO_SUFFIX WITH B->PO_SUFFIX
               REPLACE QTY       WITH B->QTY
               REPLACE PAK_YR    WITH A->PAK_YR
               REPLACE PAK_DAY   WITH A->PAK_DAY
               REPLACE SHIP_PRI  WITH A->PRI_LB
               MTOT_CASE = MTOT_CASE + QTY
               REPLACE LOT_NBR   WITH B->LOT_NBR
               SELECT B
               SKIP
            ENDDO
            SELECT A
            SKIP
         ENDDO
         
         
         CLOSE DATA
         
         *************************************************
         ***HERENEWSTUFF
         SELECT C
         USE DTLTMP EXCLUSIVE
         
         SELECT D
         DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
         
         SELECT A
         DO FOX_USE WITH "HINVEN INDEX HINVNLOC", .F.
         
         GOTO TOP
         
         SELECT B
         DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT", .F.
         SET FILTER TO ACTIVITY = 'OUT' .AND. LOT_NBR <> 'U' .AND. LOT_NBR <> 'P'
         GOTO TOP
         
         *************************************************
         DO WHILE .NOT. EOF()
            
            IF MBEGIN <> CTOD('')
               IF ACT_DATE < MBEGIN .OR. ACT_DATE > MEND
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            STORE FREEZ_LOC TO MFREEZ_LOC
            STORE LOT_NBR TO MLOT_NBR
            SELECT A
            SEEK MFREEZ_LOC + MLOT_NBR
            
            IF .NOT. EOF()
               SELECT B
               SKIP
               LOOP
            ENDIF
            
            SELECT D
            SEEK MFREEZ_LOC + MLOT_NBR
            IF EOF()
               SELECT B
               SKIP
               LOOP
            ENDIF
            
            IF MPAK_YR <> 0 .OR. MPAK_DAY <> 0
               IF PAK_YR <> MPAK_YR .OR. PAK_DAY <> MPAK_DAY
                  SELECT B
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            IF D->PROD_DESC <> MPROD_DESC
               SELECT B
               SKIP
               LOOP
            ENDIF
            
            SELECT C
            APPEND BLANK
            REPLACE FREEZ_LOC WITH B->FREEZ_LOC
            REPLACE PROD_DESC WITH D->PROD_DESC
            REPLACE ACT_DATE  WITH B->ACT_DATE
            REPLACE ACT_CODE  WITH B->ACT_CODE
            REPLACE SALESMAN  WITH B->SALESMAN
            REPLACE PO_NBR    WITH B->PO_NBR
            REPLACE PO_SUFFIX WITH B->PO_SUFFIX
            REPLACE QTY       WITH B->QTY
            REPLACE PAK_YR    WITH D->PAK_YR
            REPLACE PAK_DAY   WITH D->PAK_DAY
            REPLACE SHIP_PRI  WITH D->PRI_LB
            MTOT_CASE = MTOT_CASE + QTY
            REPLACE LOT_NBR   WITH B->LOT_NBR
            SELECT B
            SKIP
         ENDDO
         
         CLOSE DATA
         ***HERE-ENDOFNEWSTUFF
         
         SELECT D
         DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
         
         SELECT B
         DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_CODE", .F.
         
         SELECT C
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
         
         *** GET ALL OF THE CUSTOMERS AND SUPPLIERS
         
         SELECT A
         USE DTLTMP EXCLUSIVE
         DO WHILE .NOT. EOF()
            SELECT D
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
            SELECT B
            SEEK D->SUP_CODE
            STORE NAME TO MSHIP_NAME
            
            SELECT C
            SEEK D->BUY_CODE
            STORE NAME TO MPAYEE
            SELECT A
            
            REPLACE SHIP_NAME WITH MSHIP_NAME
            REPLACE PAYEE WITH MPAYEE
            SKIP
         ENDDO
         
         GOTO TOP
         
         DO WHILE .NOT. EOF()
            IF MBUY_NAME <> SPACE(32)
               IF MBUY_NAME <> PAYEE
                  DELETE
               ENDIF
            ENDIF
            
            IF MFRZ_NAME <> SPACE(32)
               IF MFRZ_NAME <> FREEZ_LOC
                  DELETE
               ENDIF
            ENDIF
            SKIP
            
         ENDDO
         
         CLOSE DATA
         
         SELECT A
         USE DTLTMP EXCLUSIVE
         DO CASE
         CASE MORDER = 'D'
            INDEX ON ACT_DATE TO DTLTMP
         CASE MORDER = 'F'
            INDEX ON FREEZ_LOC + STR(YEAR(ACT_DATE),4) + DTOC(ACT_DATE) TO DTLTMP
         OTHERWISE
            INDEX ON PAYEE + STR(YEAR(ACT_DATE),4) + DTOC(ACT_DATE) TO DTLTMP
         ENDCASE
         
         USE DTLTMP INDEX DTLTMP
         
         IF EOF()
            MWAIT = ' '
            @ 17,1 SAY SPACE(78)
            @ 18,1 SAY 'NO ACTIVITY FOR SELECTION - PRESS RETURN TO CONTINUE ' GET MWAIT
            READ
            LOOP
         ENDIF
         IF MDISP_PRT = 'D'
            CLEAR
            @ 3,1 SAY '   Activity for Product ' + trim(MPROD_DESC)
            @ 4,1 SAY '   PO NBR ACT ACT DATE SUP     CUST    FREEZER LOT NBR    CASES   PRICE PAK DT'       
            *                   10        20        30        40        50        60        70                         
            *          123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
            *          XX-XXXX-1 IN  XX/XX/XX 1234567 1234567 1234567 1234567890 XXXXX XX.XXXX PAK DT
            @ 5,1 TO 5,79
            DO WHILE .NOT. EOF()
               MLINE = 6
               @ 6,1 CLEAR TO 22,78
               DO WHILE .NOT. EOF() .AND. MLINE <= 22
                  @ MLINE,1 SAY SALESMAN
                  IF SALESMAN <> '  '
                     @ MLINE,3 SAY '-'
                  ENDIF
                  @ MLINE,4 SAY PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,8 SAY '-' + PO_SUFFIX
                  ENDIF
                  IF ACT_CODE = 'S'
                     @ MLINE,11 SAY 'OUT'
                  ELSE
                     @ MLINE,11 SAY 'IN'
                  ENDIF
                  @ MLINE,15 SAY SUBSTR(DTOC(ACT_DATE),1,6) + SUBSTR(DTOC(ACT_DATE),9,2)
                  @ MLINE,24 SAY SUBSTR(SHIP_NAME,1,7)
                  @ MLINE,32 SAY SUBSTR(PAYEE,1,7)
                  IF FREEZ_LOC = 'PREFERRED'
                     @ MLINE,40 SAY 'PREF ' + SUBSTR(FREEZ_LOC,11,2)
                  ELSE
                     @ MLINE,40 SAY SUBSTR(FREEZ_LOC,1,7)
                  ENDIF
                  @ MLINE,48 SAY LOT_NBR
                  @ MLINE,59 SAY QTY PICTURE '99999'      
                  @ MLINE,65 SAY SHIP_PRI PICTURE '99.9999'
                  @ MLINE,73 SAY STR(PAK_YR,2) + '/' + STR(PAK_DAY,3)
                  MLINE = MLINE + 1
                  SKIP
               ENDDO
               MWAIT = ' '
               IF EOF()
                  @ 24,0 clear
                  @ 24,32 SAY 'Total Cases:'
                  @ 24,58 SAY MTOT_CASE PICTURE '999999'
                  @ 24,4 SAY 'Press Return to Continue ' get mwait
               ELSE
                  @ 24,0 clear
                  @ 24,32 SAY 'Total Cases:'
                  @ 24,58 SAY MTOT_CASE PICTURE '999999'
                  @ 24,4 SAY 'Press Return to Continue to Next Page or "X" to Exit' get mwait picture '@!'
               ENDIF
               READ
               
               IF MWAIT = 'X'
                  GOTO BOTTOM
                  SKIP
               ENDIF
            ENDDO
         ELSE
            MLINE = 99
            
            SET CONSOLE OFF
            IF FILE("C:\COMPINFO\PRINTERS.DBF")
               SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
            ELSE
               SET PRINT TO LPT3
            ENDIF
            SET DEVICE TO PRINT
            SET PRINT ON
            
            *** PRINT IN 12 CPI
            ?? chr(27) + '&k4S'
            
            *** LETTER GOTHIC AND BOLDED PRINT
            ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
            
            *** LETTER SIZE PAPER
            ?? CHR(27) + '&l2A'
            
            *** PORTRAIT MODE
            ?? CHR(27) + '&l0O'
            
            DO CASE
            CASE MORDER = 'D'
               
               DO WHILE .NOT. EOF()
                  IF MLINE > 58
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                     @ 3,1 SAY '   Activity for Product ' + trim(MPROD_DESC)
                     @ 4,1 SAY '   PO NBR  ACT  ACT DATE   SUPPLIER  CUSTOMER  FREEZER  LOT NBR      CASES    PRICE  PAK DT'  
                     *          XX-XXXX-X  XX  XX/XX/XXXX  12345678  12345678  1234567  1234567890  XX,XXX  99.9999  XX/XXX
                     *          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
                     *                   10        20        30       40         50        60        70        80        90                 
                     MLINE = 6
                  ENDIF
                  
                  @ MLINE,1 SAY SALESMAN
                  IF SALESMAN <> '  '
                     @ MLINE,3 SAY '-'
                  ENDIF
                  @ MLINE,4 SAY PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,8 SAY '-' + PO_SUFFIX
                  ENDIF
                  IF ACT_CODE = 'S'
                     @ MLINE,12 SAY 'OUT'
                  ELSE
                     @ MLINE,12 SAY 'IN'
                  ENDIF
                  @ MLINE,16 SAY ACT_DATE
                  @ MLINE,28 SAY SUBSTR(SHIP_NAME,1,8)
                  @ MLINE,38 SAY SUBSTR(PAYEE,1,8)
                  IF FREEZ_LOC = 'PREFERRED'
                     @ MLINE,48 SAY 'PREF ' + SUBSTR(FREEZ_LOC,11,2)
                  ELSE
                     @ MLINE,48 SAY SUBSTR(FREEZ_LOC,1,7)
                  ENDIF
                  @ MLINE,57 SAY LOT_NBR
                  @ MLINE,69 SAY QTY PICTURE '99,999'
                  @ MLINE,77 SAY SHIP_PRI PICTURE '99.9999'
                  @ MLINE,86 SAY STR(PAK_YR,2) + '/' + STR(PAK_DAY,3)
                  
                  MLINE = MLINE + 1
                  SKIP
               ENDDO
            CASE MORDER = 'F'
               DO WHILE .NOT. EOF()
                  STORE FREEZ_LOC TO MFREEZ_LOC
                  STORE 0 TO MFREEZ_TOT
                  DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC
                     IF MLINE > 58
                        IF MLINE <> 99
                           EJECT
                        ENDIF
                        
                        @ 3,1 SAY '   Activity for Product ' + trim(MPROD_DESC)
                        @ 4,1 SAY '   PO NBR  ACT  ACT DATE   SUPPLIER  CUSTOMER  FREEZER  LOT NBR      CASES    PRICE  PAK DT'  
                        *          XX-XXXX-X  XX  XX/XX/XXXX  12345678  12345678  1234567  1234567890  XX,XXX  99.9999  XX/XXX
                        *          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
                        *                   10        20        30       40         50        60        70        80        90                 
                        MLINE = 6
                     ENDIF
                     
                     
                     @ MLINE,1 SAY SALESMAN
                     IF SALESMAN <> '  '
                        @ MLINE,3 SAY '-'
                     ENDIF
                     @ MLINE,4 SAY PO_NBR
                     IF PO_SUFFIX <> ' '
                        @ MLINE,8 SAY '-' + PO_SUFFIX
                     ENDIF
                     IF ACT_CODE = 'S'
                        @ MLINE,12 SAY 'OUT'
                     ELSE
                        @ MLINE,12 SAY 'IN'
                     ENDIF
                     @ MLINE,16 SAY ACT_DATE
                     @ MLINE,28 SAY SUBSTR(SHIP_NAME,1,8)
                     @ MLINE,38 SAY SUBSTR(PAYEE,1,8)
                     IF FREEZ_LOC = 'PREFERRED'
                        @ MLINE,48 SAY 'PREF ' + SUBSTR(FREEZ_LOC,11,2)
                     ELSE
                        @ MLINE,48 SAY SUBSTR(FREEZ_LOC,1,7)
                     ENDIF
                     @ MLINE,57 SAY LOT_NBR
                     @ MLINE,69 SAY QTY PICTURE '99,999'
                     @ MLINE,77 SAY SHIP_PRI PICTURE '99.9999'
                     @ MLINE,86 SAY STR(PAK_YR,2) + '/' + STR(PAK_DAY,3)
                     
                     
                     
                     MFREEZ_TOT = MFREEZ_TOT + QTY
                     MLINE = MLINE + 1
                     SKIP
                  ENDDO
                  MLINE = MLINE
                  @ MLINE,4 SAY 'FREEZER TOTAL:'
                  @ MLINE,71 SAY MFREEZ_TOT PICTURE '999,999'
                  MLINE = MLINE + 2
               ENDDO
               
            OTHERWISE
               DO WHILE .NOT. EOF()
                  STORE PAYEE TO MPAYEE
                  STORE 0 TO MCUST_TOT
                  DO WHILE .NOT. EOF() .AND. PAYEE = MPAYEE
                     IF MLINE > 58
                        IF MLINE <> 99
                           EJECT
                        ENDIF
                        @ 3,1 SAY '   Activity for Product ' + trim(MPROD_DESC)
                        @ 4,1 SAY '   PO NBR  ACT  ACT DATE   SUPPLIER  CUSTOMER  FREEZER  LOT NBR      CASES    PRICE  PAK DT'  
                        *          XX-XXXX-X  XX  XX/XX/XXXX  12345678  12345678  1234567  1234567890  XX,XXX  99.9999  XX/XXX
                        *          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
                        *                   10        20        30       40         50        60        70        80        90                 
                        MLINE = 6
                     ENDIF
                     
                     @ MLINE,1 SAY SALESMAN
                     IF SALESMAN <> '  '
                        @ MLINE,3 SAY '-'
                     ENDIF
                     @ MLINE,4 SAY PO_NBR
                     IF PO_SUFFIX <> ' '
                        @ MLINE,8 SAY '-' + PO_SUFFIX
                     ENDIF
                     IF ACT_CODE = 'S'
                        @ MLINE,12 SAY 'OUT'
                     ELSE
                        @ MLINE,12 SAY 'IN'
                     ENDIF
                     @ MLINE,16 SAY ACT_DATE
                     @ MLINE,28 SAY SUBSTR(SHIP_NAME,1,8)
                     @ MLINE,38 SAY SUBSTR(PAYEE,1,8)
                     IF FREEZ_LOC = 'PREFERRED'
                        @ MLINE,48 SAY 'PREF ' + SUBSTR(FREEZ_LOC,11,2)
                     ELSE
                        @ MLINE,48 SAY SUBSTR(FREEZ_LOC,1,7)
                     ENDIF
                     @ MLINE,57 SAY LOT_NBR
                     @ MLINE,69 SAY QTY PICTURE '99,999'
                     @ MLINE,77 SAY SHIP_PRI PICTURE '99.9999'
                     @ MLINE,86 SAY STR(PAK_YR,2) + '/' + STR(PAK_DAY,3)
                     MCUST_TOT = MCUST_TOT + QTY
                     MLINE = MLINE + 1
                     SKIP
                  ENDDO
                  MLINE = MLINE
                  @ MLINE,4 SAY 'CUSTOMER TOTAL:'
                  @ MLINE,68 SAY MCUST_TOT PICTURE '999,999'
                  MLINE = MLINE + 2
               ENDDO
            ENDCASE
            
            IF MLINE <> 99
               MLINE = MLINE + 2
               @ MLINE,4 SAY 'TOTAL:'
               @ MLINE,68 SAY MTOT_CASE PICTURE '999,999'
               @ MLINE+1,1 SAY ' '
               EJECT
            ENDIF
            
            SET DEVICE TO SCREEN
            SET PRINT OFF
            SET PRINT TO
            SET CONSOLE ON
            IF MPRINTER3 <> 'DONOTPRINT'
               RUN &MPRINTIT3
            ENDIF
            
         ENDIF
         
      ENDDO
      
      CLOSE DATA
      MRPT_SEL   = ' '
      
   CASE MRPT_SEL = '6'
      
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT INVENTORY ACTIVITY -SELECTED LOT'
      @ 2,0 to 22,79
      MFREEZ_LOC = SPACE(32)
      MLOT_NBR = SPACE(10)
      @ 08,3 say 'Enter Freezer Name: ' GET MFREEZ_LOC PICTURE '@!'
      @ 10,3 SAY '  Enter Lot Number: ' GET MLOT_NBR PICTURE '@!'
      
      READ
      
      @ 4,3 CLEAR TO 22,78
      
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      
      MPAGE_LEN = 56
      MPAGE_NO = 0
      MLINE = 99
      
      @ 21,16 SAY SPACE(34)
      @ 21,16 SAY 'PROCESSING............'
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
      
      SELECT C
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      
      SELECT D
      DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
      
      SELECT E
      DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
      
      SELECT F
      DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT", .F.
      
      SELECT B
      DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT", .F.
      
      MTOTAL = 0
      
      SEEK TRIM(MFREEZ_LOC)
      
      IF .NOT. EOF()
         MFREEZ_LOC = FREEZ_LOC
      ENDIF
      SEEK MFREEZ_LOC + MLOT_NBR
      
      DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT_NBR
         
         IF LBS = 0 .OR. QTY = 0
            SKIP
            LOOP
         ENDIF
         
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT
            ENDIF
            STORE SPACE(6) TO MPROD_DESC
            STORE 0 TO MBOX_SZ
            
            SELECT A
            SEEK MFREEZ_LOC + MLOT_NBR
            IF .NOT. EOF()
               STORE PROD_DESC TO MPROD_DESC
               STORE BOX_SZ    TO MBOX_SZ
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,25 SAY MCOMPANY
            @ 2,1 SAY 'Page'
            @ 2,06 say mpage_no picture '99'
            @ 2,20 SAY 'INVENTORY ACTIVITY FOR LOT: ' + MLOT_NBR
            @ 2,65 SAY DTOC(DATE()) + '  ' + TIME()
            
            @ 4,3 SAY 'PRODUCT: ' + MPROD_DESC
            @ 4,20 SAY 'PACKED: ' + TRANSFORM(MBOX_SZ, '999.9')
            
            
            @ 6,3 SAY 'DATE       PO NUMBER   ACT        QTY   CUSTOMER         CUST PO NBR    FREIGHT CARRIER'
            @ 6,01 SAY REPLICATE('_',89)
            MLINE = 8
            SELECT B
         ENDIF
         
         @ MLINE,1 SAY ACT_DATE
         IF SALESMAN <> '  '
            @ MLINE,14 SAY SALESMAN + '-'
         ENDIF
         @ MLINE,17 SAY PO_NBR
         IF PO_SUFFIX <> ' '
            @ MLINE,21 SAY '-' + PO_SUFFIX
         ENDIF
         @ MLINE,26 SAY ACTIVITY
         
         @ MLINE,33  SAY LBS   PICTURE '999,999'
         MTOTAL = MTOTAL + LBS
         SELECT C
         SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
         IF EOF()
            STORE 'CUS NOT ON FILE' TO MCUS_NAME
            STORE 'FRT NOT ON FILE' TO MFRT_NAME
            STORE 'NO CUST PO  '    TO MCUST_PO
         ELSE
            SELECT D
            SEEK C->BUY_CODE
            IF EOF()
               STORE 'CUS NOT ON FILE' TO MCUS_NAME
            ELSE
               STORE SUBSTR(NAME,1,15) TO MCUS_NAME
            ENDIF
            IF C->FRT_CODE1 = 'NONE'
               STORE 'NONE' TO MFRT_NAME
            ELSE
               SELECT E
               SEEK C->FRT_CODE1
               IF EOF()
                  STORE 'FRT NOT ON FILE' TO MFRT_NAME
               ELSE
                  STORE SUBSTR(NAME,1,15) TO MFRT_NAME
               ENDIF
            ENDIF
            STORE C->BUYER_PO TO MCUST_PO
         ENDIF
         @ MLINE,43 SAY MCUS_NAME
         @ MLINE,60 SAY MCUST_PO
         @ MLINE,75 SAY MFRT_NAME
         MLINE = MLINE + 1
         SELECT B
         SKIP
      ENDDO
      
      SELECT F
      SEEK MFREEZ_LOC + MLOT_NBR
      DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT_NBR
         
         IF LBS = 0 .OR. QTY = 0
            SKIP
            LOOP
         ENDIF
         
         @ MLINE,1 SAY ACT_DATE
         IF SALESMAN <> '  '
            @ MLINE,14 SAY SALESMAN + '-'
         ENDIF
         @ MLINE,17 SAY PO_NBR
         IF PO_SUFFIX <> ' '
            @ MLINE,21 SAY '-' + PO_SUFFIX
         ENDIF
         @ MLINE,26 SAY 'HOLD'
         @ MLINE,33  SAY LBS   PICTURE '999,999'
         MTOTAL = MTOTAL + LBS
         SELECT C
         SEEK F->SALESMAN + F->PO_NBR + F->PO_SUFFIX
         IF EOF()
            STORE 'CUS NOT ON FILE' TO MCUS_NAME
            STORE 'FRT NOT ON FILE' TO MFRT_NAME
            STORE 'NO CUST PO  '    TO MCUST_PO
         ELSE
            SELECT D
            SEEK C->BUY_CODE
            IF EOF()
               STORE 'CUS NOT ON FILE' TO MCUS_NAME
            ELSE
               STORE SUBSTR(NAME,1,15) TO MCUS_NAME
            ENDIF
            IF C->FRT_CODE1 = 'NONE'
               STORE 'NONE' TO MFRT_NAME
            ELSE
               SELECT E
               SEEK C->FRT_CODE1
               IF EOF()
                  STORE 'FRT NOT ON FILE' TO MFRT_NAME
               ELSE
                  STORE SUBSTR(NAME,1,15) TO MFRT_NAME
               ENDIF
            ENDIF
            STORE C->BUYER_PO TO MCUST_PO
         ENDIF
         @ MLINE,43 SAY MCUS_NAME
         @ MLINE,60 SAY MCUST_PO
         @ MLINE,75 SAY MFRT_NAME
         MLINE = MLINE + 1
         SELECT F
         SKIP
      ENDDO
      
      IF MLINE <> 99
         MLINE = MLINE + 2
         @ MLINE,1   SAY 'QTY REMAINING:'
         @ MLINE,33  SAY MTOTAL   PICTURE '999,999'
         @ MLINE + 1,1 SAY ' '
         EJECT
      ENDIF
      
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      MRPT_SEL   = ' '
      
      
   CASE MRPT_SEL = '5'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT DAILY ACTIVITY REPORT'    
      @ 2,0 to 22,79
      
      STORE CTOD('') TO MDATE
      STORE 'Y' TO MPEND
      @ 06,3 SAY 'Include Pending Lots (Y/N): ' GET MPEND PICTURE '@!' VALID(MPEND = 'Y' .OR. MPEND = 'N')
      @ 8,3 SAY  'Enter Activity Date: ' GET MDATE
      
      READ
      IF MDATE = CTOD('')
         LOOP
      ENDIF
      @ 4,3 CLEAR TO 22,78
      
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      @ 10,4 SAY 'PRINTING.....'
      MPAGE_LEN = 56
      MPAGE_NO = 0
      MLINE = 99
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 10 CPI
      ?? chr(27) + '&k0S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
      
      SELECT B
      DO FOX_USE WITH "INVN_DTL", .F.
      
      ***********************************
      DO WHILE .NOT. EOF()
         IF SYS_DATE <> MDATE
            SKIP
            LOOP
         ENDIF
         
         IF (SUBSTR(LOT_NBR,1,1) = 'P' .OR. SUBSTR(LOT_NBR,1,1) = 'U') .AND. MPEND = 'N'
            SKIP
            LOOP
         ENDIF
         
         *** PRINT THE DETAIL HERE
         IF MLINE > MPAGE_LEN
            DO ACT_HD10
         ENDIF
         
         @ MLINE,1 SAY LOT_NBR  
         @ MLINE,12 SAY ACTIVITY
         @ MLINE,17 SAY SALESMAN + '-' + PO_NBR         
         IF PO_SUFFIX <> ' '
            @ MLINE,24 SAY '-' + PO_SUFFIX
         ENDIF
         @ MLINE,27 SAY QTY PICTURE '9999'
         *@ MLINE,34 SAY LBS PICTURE '999999.99'
         SELECT A
         SEEK B->FREEZ_LOC + B->LOT_NBR
         @ MLINE,39 SAY PROD_DESC
         SELECT B
         DO CASE
         CASE ACTIVITY = 'OUT'
            @ MLINE,46 SAY SHIP_PRI PICTURE '99.9999'
            @ MLINE,57 SAY SHIP_VAL PICTURE '999999.99'
         CASE ACTIVITY = 'IN'
            @ MLINE,46 SAY A->PRI_LB PICTURE '99.9999'
            @ MLINE,57 SAY A->VALUE PICTURE '999999.99'
         ENDCASE
         MLINE = MLINE + 2
         SKIP
      ENDDO
      
      IF MLINE <> 99     
         @ MLINE+1,1 SAY ' '
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      MRPT_SEL   = ' '
      
      
   CASE MRPT_SEL = '4'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - Check PO Pricing on Items Out of Invn'
      @ 2,0 to 22,79
      MDIV     = SPACE(2)
      MDISP_PRT = 'P'
      STORE CTOD('') TO MBEG_DATE, MEND_DATE
      @ 8,3 SAY  'Beginning Activity Date: ' GET MBEG_DATE
      @ 10,3 SAY '   Ending Activity Date: ' GET MEND_DATE
      @ 14,3 SAY 'Print/Display Rpt (P/D): ' GET MDISP_PRT PICTURE '@!'
      READ
      
      CLEAR
      
      ** IF DATES ARE LEFT BLANK, PICK UP ALL ACTIVITY
      ** BY FORMATTING WITH REAL OLD AND CURRENT BEGIN/END
      IF DTOC(MBEG_DATE) = '  /  /  '
         MBEG_DATE = CTOD('01/01/90')
      ENDIF
      IF DTOC(MEND_DATE) = '  /  /  '
         MEND_DATE = DATE()
      ENDIF
      
      MPAGE_LEN = 56
      MPAGE_NO = 0
      MLINE = 99
      IF MDISP_PRT = 'P'
         SET CONSOLE OFF
         IF FILE("C:\COMPINFO\PRINTERS.DBF")
            SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
         ELSE
            SET PRINT TO LPT3
         ENDIF
         SET DEVICE TO PRINT
         SET PRINT ON
      ENDIF
      
      *** PRINT IN 10 CPI
      ?? chr(27) + '&k0S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
      
      SELECT F
      DO FOX_USE WITH "INVN_DTL INDEX DTL_DATE", .F.
      
      *** GET ALL THE OUT ACTIVITY FROM THE DETAIL FILE
      *** FOR THE SPECIFIED TIME FRAME
      
      IF YEAR(MBEG_DATE) >= YEAR(ACT_DATE)
         SEEK STR(YEAR(MBEG_DATE),4)
      ENDIF
      ** FIRST GET ALL THE SHIPMENTS OUT OF INVENTORY THAT
      ** FALL INTO THIS DATE RANGE
      DO WHILE .NOT. EOF() .AND. ACT_DATE <  MBEG_DATE
         SKIP
      ENDDO
      DO WHILE .NOT. EOF() .AND. ACT_DATE <= MEND_DATE
         
         *** IF THIS IS NOT A SHIPMENT RECORD, SKIP IT
         IF ACT_CODE <> 'S'
            SKIP
            LOOP
         ENDIF
         
         IF SHIP_LBS = 0 .OR. SHIP_CASE = 0
            SKIP
            LOOP
         ENDIF
         
         SELECT A
         SEEK F->FREEZ_LOC + F->LOT_NBR
         IF EOF()
            ? 'NOT ON FILE: ' + F->FREEZ_LOC + '   ' + F->LOT_NBR
            IF MDISP_PRT <> 'P'
               WAIT 'PRESS ENTER TO CONTINUE '
            ENDIF
         ELSE
            IF PRI_LB <> F->SHIP_PRI
               ? 'PRICING DIFF: ' + F->SALESMAN+'-'+F->PO_NBR+'-'+F->PO_SUFFIX + '  LOT: ' + F->LOT_NBR 
               IF MDISP_PRT <> 'P'
                  WAIT 'PRESS ENTER TO CONTINUE '
               ENDIF
            ENDIF
         ENDIF 
         SELECT F
         SKIP
      ENDDO
      
      CLOSE DATA
      
      IF MDISP_PRT = 'P'
         EJECT
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
      ENDIF
      
      MRPT_SEL   = ' '
      
      
      *** OLD REPORT - NOT DONE ANYMORE
      MDO = .F.
      IF MDO
         
         CLEAR
         @ 00,00 SAY MCOMPANY
         @ 01,68 SAY DATE()
         @ 01,00 SAY MPROGRAM + ' - PRINT INVENTORY PRODUCT SUMMARY'
         @ 2,0 to 22,79
         MPROD = SPACE(6)
         MDIV  = SPACE(2)
         MFREEZER = SPACE(40)
         MRPT_PICK = ' '
         @ 5,3 say ' Summary (S) or Detail (D) Report: ' GET MRPT_PICK PICTURE '@!' VALID(MRPT_PICK = 'S' .OR. MRPT_PICK = 'D')
         @ 7,3 SAY '     Enter Optional Division Code: ' GET MDIV PICTURE '@!'
         @ 9,3 SAY '      Enter Optional Product Code: ' GET MPROD  PICTURE '@!'
         @ 11,3 SAY '      Enter Optional Freezer Name: ' GET MFREEZER PICTURE '@!'
         READ
         @ 5,3 CLEAR TO 11,78
         
         MPRT_ACT = 'C'
         
         @ 20,01 CLEAR TO 20,78 
         DO PRT_SET
         IF MPRT_ACT <> 'C'
            LOOP  
         ENDIF
         MPAGE_LEN = 44
         
         MPAGE_NO = 0
         MLINE = 99
         
         @ 21,16 SAY SPACE(34)
         @ 21,16 SAY 'PROCESSING............'
         SET CONSOLE OFF
         IF FILE("C:\COMPINFO\PRINTERS.DBF")
            SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
         ELSE
            SET PRINT TO LPT3
         ENDIF
         SET DEVICE TO PRINT
         SET PRINT ON
         
         *** PRINT IN 12 CPI
         ?? chr(27) + '&k4S'
         
         *** LETTER GOTHIC AND BOLDED PRINT
         ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
         
         *** LANDSCAPE MODE
         ?? CHR(27) + '&l1O'
         
         *** LEGAL SIZE PAPER
         ?? CHR(27) + '&l3A'
         
         
         SELECT E
         DO FOX_USE WITH "&MMASTDBF.DIVISION", .F.
         
         SELECT D 
         DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
         
         SELECT C
         DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
         
         SELECT A
         DO FOX_USE WITH "INVEN INDEX INVNSOLD", .F.
         SEEK ' '
         MTOT_LBS = 0
         MTOT_VAL = 0
         MTOT_CASE = 0
         IF MFREEZER <> SPACE(40)
            MFREEZER = TRIM(MFREEZER)
         ENDIF
         DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' '
            IF MDIV <> SPACE(2)
               IF MDIV <> DIV_CODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            MTOT_DLBS = 0
            MTOT_DVAL = 0
            MTOT_DCAS = 0
            MDIV_CODE = DIV_CODE
            MDIV_NAME = 'DIVISION CODE NOT ON FILE'
            SELECT E
            GOTO TOP
            DO WHILE .NOT. EOF()
               IF MDIV_CODE = DIV_CODE
                  MDIV_NAME = DIV_NAME
                  GOTO BOTTOM
               ENDIF
               SKIP
            ENDDO
            
            SELECT A
            IF MPROD <> SPACE(6)
               IF MPROD <> PROD_DESC
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            IF MFREEZER <> SPACE(40)
               IF FREEZ_LOC <> MFREEZER
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            MPRT_DIV = .T.
            SELECT A
            DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' ' .AND. DIV_CODE = MDIV_CODE
               MSV_PROD = PROD_DESC
               MPROD_LBS = 0
               MPROD_DLR = 0
               MPROD_CASE = 0
               DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' ' .AND. DIV_CODE = MDIV_CODE .AND. MSV_PROD = PROD_DESC
                  IF MPROD <> SPACE(4)
                     IF MPROD <> PROD_DESC
                        SKIP
                        LOOP
                     ENDIF
                  ENDIF
                  
                  IF MFREEZER <> SPACE(40)
                     IF FREEZ_LOC <> MFREEZER
                        SKIP
                        LOOP
                     ENDIF
                  ENDIF
                  IF MLINE > MPAGE_LEN
                     IF MLINE <> 99
                        EJECT 
                     ENDIF
                     
                     MPAGE_NO = MPAGE_NO + 1
                     
                     @ 1,59 SAY MCOMPANY
                     @ 2,1 SAY 'Page'
                     @ 2,06 say mpage_no picture '99'
                     @ 2,50 SAY '    INVENTORY SUMMARY AS OF ' + DTOC(DATE())
                     @ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
                     @ 4,1 SAY '  DATE    LOCATION              LOT #    I #   SALES   SUPPLIER            PROD SIZE PRODUCT           PACK  CASES      POUNDS     PRICE   COST/LB    TOTAL COST'
                     @ 4,01 SAY REPLICATE('_',160)
                     MLINE = 6
                  ENDIF
                  IF MPRT_DIV
                     @ MLINE,1 SAY 'DIVISION: ' + MDIV_NAME
                     @ MLINE,1 SAY REPLICATE('_',42)
                     MPRT_DIV = .F.
                     MLINE = MLINE + 2
                  ENDIF
                  IF MRPT_PICK = 'D'
                     @ MLINE,1 SAY ANIV_DATE
                     @ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
                     @ MLINE,33 SAY LOT_NBR
                     **@ MLINE,42 SAY STR(I_NBR,5)  
                     *** GO FIND THE SALESPERSON NAME
                     IF SALESMAN <> '  '
                        SELECT D
                        SEEK A->SALESMAN
                        IF .NOT. EOF()
                           @ MLINE,48 SAY SUBSTR(NAME,1,7)
                        ELSE
                           @ MLINE,48 SAY A->SALESMAN
                        ENDIF
                        SELECT A
                     ELSE
                        @ MLINE,48 SAY BROK_NAME
                     ENDIF
                     @ MLINE,56 SAY SUPPLIER
                     @ MLINE,76 SAY PROD_SIZE
                     
                     *IF DTOC(PAID_DATE) = '  /  /  '
                     *   @ MLINE,79 SAY 'NO'
                     *ELSE
                     *   @ MLINE,76 SAY PAID_DATE
                     *ENDIF
                  ENDIF
                  SELECT C
                  SEEK 'R' + A->PROD_DESC
                  IF EOF()       
                     MDESC = A->PROD_DESC
                  ELSE
                     MDESC = SUBSTR(DESC,1,15)
                  ENDIF
                  IF MRPT_PICK = 'D'
                     @ MLINE,86 SAY SUBSTR(MDESC,1,15)
                  ENDIF
                  SELECT A
                  MCASE_LEFT = 0
                  MVAL_LEFT = 0
                  MLBS_LEFT = 0
                  DO CALC_CUR
                  IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
                     MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
                  ELSE
                     MPRO_PRI = 0
                     MVAL_LEFT = 0
                  ENDIF
                  IF MRPT_PICK = 'D'
                     @ MLINE,104 SAY BOX_SIZE
                     @ MLINE,111 SAY MCASE_LEFT PICTURE '9999'
                     @ MLINE,118 SAY MLBS_LEFT  PICTURE '999,999.99'
                     @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
                     @ MLINE,140 SAY MPRO_PRI   PICTURE '99.9999'
                     @ MLINE,149 SAY MVAL_LEFT  PICTURE '9,999,999.99'
                  ENDIF
                  MPROD_LBS = MPROD_LBS + LBS_LEFT
                  MPROD_DLR = MPROD_DLR + MVAL_LEFT
                  MPROD_CASE = MPROD_CASE + MCASE_LEFT
                  IF MRPT_PICK = 'D'
                     MLINE = MLINE + 2
                  ENDIF
                  SKIP
               ENDDO
               IF MPROD_LBS <> 0 .AND. MPROD_DLR <> 0
                  @ MLINE,5 SAY TRIM(MDESC) + ' TOTAL:' 
                  @ MLINE,5 SAY REPLICATE('_',22)
                  @ MLINE,109 SAY MPROD_CASE PICTURE '999999'
                  @ MLINE,116 SAY MPROD_LBS  PICTURE '9,999,999.99'
                  @ MLINE,149 SAY MPROD_DLR  PICTURE '9,999,999.99'
                  @ MLINE,109 SAY REPLICATE('_',52)
                  MTOT_DLBS = MTOT_DLBS + MPROD_LBS
                  MTOT_DVAL = MTOT_DVAL + MPROD_DLR
                  MTOT_DCAS = MTOT_DCAS + MPROD_CASE
                  MLINE = MLINE + 3
               ENDIF
            ENDDO
            
            MTOT_LBS = MTOT_LBS + MTOT_DLBS
            MTOT_VAL = MTOT_VAL + MTOT_DVAL
            MTOT_CASE = MTOT_CASE + MTOT_DCAS
            @ MLINE,1 SAY 'DIVISION TOTALS:'
            @ MLINE,109 SAY MTOT_DCAS PICTURE '999999'
            @ MLINE,115 SAY MTOT_DLBS PICTURE '99,999,999.99'
            @ MLINE,148 SAY MTOT_DVAL PICTURE '99,999,999.99'
            MLINE = MLINE + 3
         ENDDO
         
         IF MLINE <> 99     
            MLINE = MLINE + 1
            @ MLINE,1 SAY 'GRAND TOTALS:'
            @ MLINE,109 SAY MTOT_CASE  PICTURE '999999'
            @ MLINE,115 SAY MTOT_LBS PICTURE '99,999,999.99'
            @ MLINE,148 SAY MTOT_VAL PICTURE '99,999,999.99'
            @ MLINE+1,1 SAY ' '
            EJECT
         ENDIF
         
         SET DEVICE TO SCREEN
         SET PRINT OFF
         SET PRINT TO
         SET CONSOLE ON
         IF MPRINTER3 <> 'DONOTPRINT'
            RUN &MPRINTIT3
         ENDIF
         CLOSE DATA
         MRPT_SEL   = ' '
      ENDIF      
      
   CASE MRPT_SEL = '1'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT INVENTORY ACTIVITY REPORT'
      @ 2,0 to 22,79
      MPROD    = SPACE(6)
      MDIV     = SPACE(2)
      MFREEZER = SPACE(40)
      MI_NBR   = 0         
      MIN_OUT  = '    '
      STORE CTOD('') TO MBEG_DATE, MEND_DATE
      MRPT_PICK = ' '
      @ 4,3 say ' Select Report Format (#1 or #2): ' GET MRPT_PICK PICTURE '#' VALID(MRPT_PICK = '1' .OR. MRPT_PICK = '2' .OR. MRPT_PICK = ' ')
      @ 5,3 say ' 1.  All shipments in and all shipments out grouped together'
      @ 6,3 say ' 2.  By I number, shipments in, shipments out'
      @ 8,3 SAY '         Beginning Activity Date: ' GET MBEG_DATE
      @ 10,3 SAY '            Ending Activity Date: ' GET MEND_DATE
      @ 12,3 SAY 'Select Shipments IN, OUT or BOTH: ' GET MIN_OUT PICTURE '@!'
      @ 14,3 SAY '         Enter Optional I Number: ' GET MI_NBR PICTURE '#####'
      @ 16,3 SAY '    Enter Optional Division Code: ' GET MDIV PICTURE '@!'
      @ 18,3 SAY '     Enter Optional Product Code: ' GET MPROD  PICTURE '@!'
      @ 20,3 SAY '     Enter Optional Freezer Name: ' GET MFREEZER PICTURE '@!'
      
      READ
      IF MRPT_PICK = ' '
         LOOP
      ENDIF
      
      @ 4,3 CLEAR TO 22,78
      
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      IF MIN_OUT = '    '
         MIN_OUT = 'BOTH'
      ENDIF
      ** IF DATES ARE LEFT BLANK, PICK UP ALL ACTIVITY
      ** BY FORMATTING WITH REAL OLD AND CURRENT BEGIN/END
      IF DTOC(MBEG_DATE) = '  /  /  '
         MBEG_DATE = CTOD('01/01/90')
      ENDIF
      IF DTOC(MEND_DATE) = '  /  /  '
         MEND_DATE = DATE()
      ENDIF
      MPAGE_LEN = 44
      MPAGE_NO = 0
      MLINE = 99
      
      @ 21,16 SAY SPACE(34)
      @ 21,16 SAY 'PROCESSING............'
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      SELECT E
      DO FOX_USE WITH "&MMASTDBF.DIVISION", .F.
      
      SELECT D 
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      SELECT B
      USE INVNTEMP EXCLUSIVE
      DELETE ALL
      PACK
      DO FOX_USE WITH "INVNTEMP", .F.
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNANIV", .F.
      
      IF MFREEZER <> SPACE(40)
         MFREEZER = TRIM(MFREEZER)
      ENDIF
      IF MIN_OUT = 'IN' .OR. MIN_OUT = 'BOTH'
         
         IF YEAR(MBEG_DATE) >= YEAR(ANIV_DATE)
            SEEK STR(YEAR(MBEG_DATE),4)
         ENDIF
         
         ** FIRST GET ALL THE SHIPMENTS INTO INVENTORY THAT
         ** FALL INTO THIS DATE RANGE - THESE COME FROM THE "INVEN" FILE
         DO WHILE .NOT. EOF() .AND. ANIV_DATE < MBEG_DATE
            SKIP
         ENDDO
         DO WHILE .NOT. EOF() .AND. ANIV_DATE <= MEND_DATE
            
            IF LBS = 0 .OR. CASE_CNT = 0
               SKIP
               LOOP
            ENDIF
            
            ** CHECK DIVISION CODE MATCH
            IF MDIV <> SPACE(2)
               IF MDIV <> DIV_CODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            ** CHECK PRODUCT DESCRIPTION MATCH
            IF MPROD <> SPACE(6)
               IF MPROD <> PROD_DESC
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            ** CHECK FREEZER MATCH
            IF MFREEZER <> '  '
               IF TRIM(FREEZ_LOC) <> MFREEZER
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK I NBR MATCH
            IF MI_NBR <> 0
               IF MI_NBR <> I_NBR
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE SALESMAN    WITH A->SALESMAN
            REPLACE PO_NBR      WITH A->PO_NBR
            REPLACE PO_SUFFIX   WITH A->PO_SUFFIX
            REPLACE FREEZ_LOC   WITH A->FREEZ_LOC
            REPLACE I_NBR       WITH A->I_NBR
            REPLACE DIV_CODE    WITH A->DIV_CODE
            REPLACE PROD_DESC   WITH A->PROD_DESC
            REPLACE BOX_SIZE    WITH A->BOX_SIZE
            REPLACE LOT_NBR     WITH A->LOT_NBR
            REPLACE SUPPLIER    WITH A->SUPPLIER
            REPLACE LBS         WITH A->LBS
            REPLACE PRI_LB      WITH A->PRI_LB
            REPLACE CASE_CNT    WITH A->CASE_CNT
            REPLACE VALUE       WITH A->VALUE
            REPLACE ACT_DATE    WITH A->ANIV_DATE
            REPLACE ACT_CODE    WITH 'I'
            
            UNLOCK
            SELECT A
            SKIP
         ENDDO
      ENDIF
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNINBR", .F.
      
      SELECT F
      DO FOX_USE WITH "INVN_DTL INDEX DTL_DATE", .F.
      
      *** GET ALL THE OUT ACTIVITY FROM THE DETAIL FILE
      *** FOR THE SPECIFIED TIME FRAME
      
      IF MIN_OUT = 'OUT' .OR. MIN_OUT = 'BOTH'
         IF VAL(SUBSTR(DTOC(MBEG_DATE),7)) >= VAL(SUBSTR(DTOC(ACT_DATE),7))
            SEEK SUBSTR(DTOC(MBEG_DATE),7)
         ENDIF
         ** FIRST GET ALL THE SHIPMENTS OUT OF INVENTORY THAT
         ** FALL INTO THIS DATE RANGE
         DO WHILE .NOT. EOF() .AND. ACT_DATE <  MBEG_DATE
            SKIP
         ENDDO
         DO WHILE .NOT. EOF() .AND. ACT_DATE <= MEND_DATE
            *** IF THIS IS NOT A SHIPMENT RECORD, SKIP IT
            IF ACT_CODE <> 'S'
               SKIP
               LOOP
            ENDIF
            
            IF SHIP_LBS = 0 .OR. SHIP_CASE = 0
               SKIP
               LOOP
            ENDIF
            ** CHECK I NBR MATCH
            IF MI_NBR <> 0
               IF MI_NBR <> I_NBR
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT A
            SEEK STR(F->I_NBR,5)
            ** CHECK PRODUCT DESCRIPTION MATCH
            IF MPROD <> SPACE(6)
               IF MPROD <> PROD_DESC
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK DIVISION CODE MATCH
            IF MDIV <> SPACE(2)
               IF MDIV <> DIV_CODE
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK FREEZER MATCH
            IF MFREEZER <> '  '
               IF TRIM(FREEZ_LOC) <> MFREEZER
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE FREEZ_LOC   WITH A->FREEZ_LOC
            REPLACE I_NBR       WITH A->I_NBR
            REPLACE DIV_CODE    WITH A->DIV_CODE
            REPLACE PROD_DESC   WITH A->PROD_DESC
            REPLACE BOX_SIZE    WITH A->BOX_SIZE
            REPLACE LOT_NBR     WITH A->LOT_NBR
            REPLACE SUPPLIER    WITH A->SUPPLIER
            *** GET THIS INFO FROM DETAIL RECORD
            REPLACE SALESMAN    WITH F->SALESMAN
            REPLACE PO_NBR      WITH F->PO_NBR
            REPLACE PO_SUFFIX   WITH F->PO_SUFFIX
            REPLACE LBS         WITH (F->SHIP_LBS * -1)
            REPLACE PRI_LB      WITH F->SHIP_PRI
            REPLACE CASE_CNT    WITH (F->SHIP_CASE * -1)
            REPLACE VALUE       WITH (F->SHIP_VAL * -1)
            REPLACE ACT_DATE    WITH F->ACT_DATE
            REPLACE ACT_CODE    WITH 'S'
            UNLOCK
            SELECT F
            SKIP
         ENDDO
      ENDIF
      
      SELECT B
      USE INVNTEMP EXCLUSIVE
      IF MRPT_PICK = '1'
         INDEX ON DIV_CODE + FREEZ_LOC + PROD_DESC + ACT_CODE + STR(YEAR(ACT_DATE),4) + SUBSTR(DTOC(ACT_DATE),1,5) TO INVNTEMP
      ELSE
         INDEX ON DIV_CODE + FREEZ_LOC + PROD_DESC + STR(I_NBR,5) TO INVNTEMP
      ENDIF
      
      DO FOX_USE WITH "INVNTEMP INDEX INVNTEMP", .F.
      DO CASE
      CASE MRPT_PICK = '1'
         **** ZERO OUT GRAND TOTALS ***
         MTOT_LBS = 0
         MTOT_VAL = 0
         MTOT_CAS = 0
         ***********************************
         SELECT E
         GOTO TOP
         DO WHILE .NOT. EOF()
            MDIV_NAME = DIV_NAME
            MTOT_DLBS = 0
            MTOT_DVAL = 0
            MTOT_DCAS = 0
            SELECT B
            SEEK E->DIV_CODE
            IF EOF()
               SELECT E
               SKIP
               LOOP
            ENDIF
            IF MLINE <> 99
               MLINE = 89
            ENDIF
            
            DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE
               MSV_FREEZ = FREEZ_LOC
               MTOT_FLBS = 0
               MTOT_FVAL = 0
               MTOT_FCAS = 0
               DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ
                  MSV_PROD = PROD_DESC
                  MTOT_PLBS = 0
                  MTOT_PVAL = 0
                  MTOT_PCAS = 0
                  SELECT C
                  SEEK 'R' + MSV_PROD     
                  IF EOF()       
                     MDESC = 'CODE: ' + MSV_PROD
                  ELSE
                     MDESC = SUBSTR(DESC,1,15)
                  ENDIF
                  SELECT B
                  DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ .AND. PROD_DESC = MSV_PROD
                     MSV_ACTCD = ACT_CODE
                     MTOT_ALBS = 0
                     MTOT_AVAL = 0
                     MTOT_ACAS = 0
                     DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ .AND. PROD_DESC = MSV_PROD .AND. MSV_ACTCD = ACT_CODE
                        *** PRINT THE DETAIL HERE
                        IF MLINE > MPAGE_LEN
                           DO ACT_HEAD
                        ENDIF
                        
                        @ MLINE,1 SAY ACT_DATE
                        @ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
                        @ MLINE,33 SAY LOT_NBR
                        **@ MLINE,42 SAY STR(I_NBR,5)  
                        @ MLINE,52 SAY SALESMAN
                        IF SALESMAN <> '  '
                           @ MLINE,54 SAY '-'
                        ENDIF
                        @ MLINE,55 SAY PO_NBR
                        IF PO_SUFFIX <> ' '
                           @ MLINE,59 SAY '-' + PO_SUFFIX
                        ENDIF
                        @ MLINE,62 SAY SUBSTR(SUPPLIER,1,15)
                        IF ACT_CODE = 'I'
                           @ MLINE,79 SAY 'IN'
                        ELSE
                           @ MLINE,79 SAY 'OUT'     
                        ENDIF
                        @ MLINE,86 SAY SUBSTR(MDESC,1,15)
                        @ MLINE,104 SAY BOX_SIZE
                        @ MLINE,110 SAY CASE_CNT  PICTURE '99999'
                        @ MLINE,117 SAY LBS       PICTURE '999,999.99'
                        @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
                        @ MLINE,149 SAY VALUE     PICTURE '9,999,999.99'
                        MTOT_ALBS = MTOT_ALBS + LBS
                        MTOT_AVAL = MTOT_AVAL + VALUE
                        MTOT_ACAS = MTOT_ACAS + CASE_CNT
                        MLINE = MLINE + 1
                        SKIP
                     ENDDO
                     
                     *** DO ACTIVITY (INS AND OUTS) TOTALS
                     IF MSV_ACTCD = 'I'
                        MTOT_WORD = ' IN: ' 
                     ELSE
                        MTOT_WORD = ' OUT: ' 
                     ENDIF
                     MLINE = MLINE + 1
                     @ MLINE,5 SAY TRIM(MDESC) + MTOT_WORD 
                     @ MLINE,5 SAY REPLICATE('_',24)
                     @ MLINE,109 SAY MTOT_ACAS PICTURE '999999'
                     @ MLINE,115 SAY MTOT_ALBS  PICTURE '9,999,999.99'
                     @ MLINE,149 SAY MTOT_AVAL  PICTURE '9,999,999.99'
                     @ MLINE,109 SAY REPLICATE('_',52)
                     MTOT_PLBS = MTOT_PLBS + MTOT_ALBS
                     MTOT_PVAL = MTOT_PVAL + MTOT_AVAL
                     MTOT_PCAS = MTOT_PCAS + MTOT_ACAS 
                     MLINE = MLINE + 2
                     MTOT_ALBS = 0
                     MTOT_AVAL = 0
                     MTOT_ACAS = 0
                  ENDDO
                  *** DO PRODUCT TOTALS
                  *** FINISH UP
                  IF MLINE > MPAGE_LEN
                     DO ACT_HEAD
                  ENDIF
                  @ MLINE,5 SAY TRIM(MDESC) + ' TOTALS: ' 
                  @ MLINE,5 SAY REPLICATE('_',22)
                  @ MLINE,109 SAY MTOT_PCAS PICTURE '999999'
                  @ MLINE,115 SAY MTOT_PLBS  PICTURE '99,999,999.9'
                  @ MLINE,149 SAY MTOT_PVAL  PICTURE '9,999,999.99'
                  @ MLINE,109 SAY REPLICATE('_',52)
                  MTOT_FLBS = MTOT_FLBS + MTOT_PLBS
                  MTOT_FVAL = MTOT_FVAL + MTOT_PVAL
                  MTOT_FCAS = MTOT_FCAS + MTOT_PCAS 
                  MLINE = MLINE + 3
                  MTOT_PLBS = 0
                  MTOT_PVAL = 0
                  MTOT_PCAS = 0
               ENDDO
               *** DO FREEZER TOTALS
               IF MLINE > MPAGE_LEN
                  DO ACT_HEAD
               ENDIF
               @ MLINE,5 SAY TRIM(MSV_FREEZ) + ' TOTALS: ' 
               @ MLINE,109 SAY MTOT_FCAS PICTURE '999999'
               @ MLINE,115 SAY MTOT_FLBS  PICTURE '99,999,999.9'
               @ MLINE,149 SAY MTOT_FVAL  PICTURE '9,999,999.99'
               @ MLINE,05 SAY REPLICATE('_',156)
               MTOT_DLBS = MTOT_DLBS + MTOT_FLBS
               MTOT_DVAL = MTOT_DVAL + MTOT_FVAL
               MTOT_DCAS = MTOT_DCAS + MTOT_FCAS 
               MLINE = MLINE + 3
               MTOT_FLBS = 0
               MTOT_FVAL = 0
               MTOT_FCAS = 0
            ENDDO
            *** DO DIVISION TOTALS
            IF MLINE > MPAGE_LEN
               DO ACT_HEAD
            ENDIF
            @ MLINE,5 SAY 'DIV.-' + TRIM(MDIV_NAME) + ' TOTALS: ' 
            @ MLINE,109 SAY MTOT_DCAS PICTURE '999999'
            @ MLINE,115 SAY MTOT_DLBS  PICTURE '9,999,999.99'
            @ MLINE,149 SAY MTOT_DVAL  PICTURE '9,999,999.99'
            MLINE = MLINE + 1
            @ MLINE,05 SAY REPLICATE('*',156)
            MTOT_LBS = MTOT_LBS + MTOT_DLBS
            MTOT_VAL = MTOT_VAL + MTOT_DVAL
            MTOT_CAS = MTOT_CAS + MTOT_DCAS 
            MLINE = MLINE + 3
            MTOT_DLBS = 0
            MTOT_DVAL = 0
            MTOT_DCAS = 0
            SELECT E
            SKIP
         ENDDO
      OTHERWISE
         ********************************************
         *** REPORT SELECTION # 2
         *** ALL ACTIVITY GROUPED TOGETHER BY I NBR
         ********************************************
         **** ZERO OUT GRAND TOTALS ***
         MTOT_LBS = 0
         MTOT_VAL = 0
         MTOT_CAS = 0
         ***********************************
         SELECT E
         GOTO TOP
         DO WHILE .NOT. EOF()
            MDIV_NAME = DIV_NAME
            MTOT_DLBS = 0
            MTOT_DVAL = 0
            MTOT_DCAS = 0
            SELECT B
            SEEK E->DIV_CODE
            IF EOF()
               SELECT E
               SKIP
               LOOP
            ENDIF
            IF MLINE <> 99
               MLINE = 89
            ENDIF
            
            DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE
               MSV_FREEZ = FREEZ_LOC
               MTOT_FLBS = 0
               MTOT_FVAL = 0
               MTOT_FCAS = 0
               DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ
                  MSV_PROD = PROD_DESC
                  MTOT_PLBS = 0
                  MTOT_PVAL = 0
                  MTOT_PCAS = 0
                  SELECT C
                  SEEK 'R' + MSV_PROD     
                  IF EOF()       
                     MDESC = 'CODE: ' + MSV_PROD
                  ELSE
                     MDESC = SUBSTR(DESC,1,15)
                  ENDIF
                  SELECT B
                  DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ .AND. PROD_DESC = MSV_PROD
                     MSV_I_NBR = I_NBR
                     MTOT_ILBS = 0
                     MTOT_IVAL = 0
                     MTOT_ICAS = 0
                     DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ .AND. PROD_DESC = MSV_PROD .AND. MSV_I_NBR = I_NBR
                        *** PRINT THE DETAIL HERE
                        IF MLINE > MPAGE_LEN
                           DO ACT_HEAD
                        ENDIF
                        
                        @ MLINE,1 SAY ACT_DATE
                        @ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
                        @ MLINE,33 SAY LOT_NBR
                        **@ MLINE,42 SAY STR(I_NBR,5)  
                        @ MLINE,52 SAY SALESMAN
                        IF SALESMAN <> '  '
                           @ MLINE,54 SAY '-'
                        ENDIF
                        @ MLINE,55 SAY PO_NBR
                        IF PO_SUFFIX <> ' '
                           @ MLINE,59 SAY '-' + PO_SUFFIX
                        ENDIF
                        @ MLINE,62 SAY SUBSTR(SUPPLIER,1,15)
                        IF ACT_CODE = 'I'
                           @ MLINE,79 SAY 'IN'
                        ELSE
                           @ MLINE,79 SAY 'OUT'     
                        ENDIF
                        @ MLINE,86 SAY SUBSTR(MDESC,1,15)
                        @ MLINE,104 SAY BOX_SIZE
                        @ MLINE,110 SAY CASE_CNT  PICTURE '99999'
                        @ MLINE,117 SAY LBS       PICTURE '999,999.99'
                        @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
                        @ MLINE,149 SAY VALUE     PICTURE '9,999,999.99'
                        MTOT_ILBS = MTOT_ILBS + LBS
                        MTOT_IVAL = MTOT_IVAL + VALUE
                        MTOT_ICAS = MTOT_ICAS + CASE_CNT
                        MLINE = MLINE + 1
                        SKIP
                     ENDDO
                     
                     *** DO I NUMBER TOTALS HERE
                     MLINE = MLINE + 1
                     @ MLINE,5 SAY 'I ' + STR(MSV_I_NBR,5) + ' TOTAL: '       
                     @ MLINE,5 SAY REPLICATE('_',24)
                     @ MLINE,109 SAY MTOT_ICAS PICTURE '999999'
                     @ MLINE,115 SAY MTOT_ILBS  PICTURE '9,999,999.99'
                     @ MLINE,149 SAY MTOT_IVAL  PICTURE '9,999,999.99'
                     @ MLINE,109 SAY REPLICATE('_',52)
                     MTOT_PLBS = MTOT_PLBS + MTOT_ILBS
                     MTOT_PVAL = MTOT_PVAL + MTOT_IVAL
                     MTOT_PCAS = MTOT_PCAS + MTOT_ICAS 
                     MLINE = MLINE + 2
                  ENDDO
                  *** DO PRODUCT TOTALS
                  *** FINISH UP
                  IF MLINE > MPAGE_LEN
                     DO ACT_HEAD
                  ENDIF
                  @ MLINE,5 SAY TRIM(MDESC) + ' TOTALS: ' 
                  @ MLINE,5 SAY REPLICATE('_',22)
                  @ MLINE,109 SAY MTOT_PCAS PICTURE '999999'
                  @ MLINE,115 SAY MTOT_PLBS  PICTURE '9,999,999.99'
                  @ MLINE,149 SAY MTOT_PVAL  PICTURE '9,999,999.99'
                  @ MLINE,109 SAY REPLICATE('_',52)
                  MTOT_FLBS = MTOT_FLBS + MTOT_PLBS
                  MTOT_FVAL = MTOT_FVAL + MTOT_PVAL
                  MTOT_FCAS = MTOT_FCAS + MTOT_PCAS 
                  MLINE = MLINE + 3
               ENDDO
               *** DO FREEZER TOTALS
               IF MLINE > MPAGE_LEN
                  DO ACT_HEAD
               ENDIF
               @ MLINE,5 SAY TRIM(MSV_FREEZ) + ' TOTALS: ' 
               @ MLINE,109 SAY MTOT_FCAS PICTURE '999999'
               @ MLINE,115 SAY MTOT_FLBS  PICTURE '9,999,999.99'
               @ MLINE,149 SAY MTOT_FVAL  PICTURE '9,999,999.99'
               @ MLINE,05 SAY REPLICATE('_',156)
               MTOT_DLBS = MTOT_DLBS + MTOT_FLBS
               MTOT_DVAL = MTOT_DVAL + MTOT_FVAL
               MTOT_DCAS = MTOT_DCAS + MTOT_FCAS 
               MLINE = MLINE + 3
            ENDDO
            *** DO DIVISION TOTALS
            IF MLINE > MPAGE_LEN
               DO ACT_HEAD
            ENDIF
            @ MLINE,5 SAY 'DIV.-' + TRIM(MDIV_NAME) + ' TOTALS: ' 
            @ MLINE,109 SAY MTOT_DCAS PICTURE '999999'
            @ MLINE,115 SAY MTOT_DLBS  PICTURE '9,999,999.99'
            @ MLINE,149 SAY MTOT_DVAL  PICTURE '9,999,999.99'
            MLINE = MLINE + 1
            @ MLINE,05 SAY REPLICATE('*',156)
            MTOT_LBS = MTOT_LBS + MTOT_DLBS
            MTOT_VAL = MTOT_VAL + MTOT_DVAL
            MTOT_CAS = MTOT_CAS + MTOT_DCAS 
            MLINE = MLINE + 3
            SELECT E
            SKIP
         ENDDO
      ENDCASE
      IF MLINE <> 99     
         IF MLINE > MPAGE_LEN
            DO ACT_HEAD
         ENDIF
         MLINE = MLINE + 1
         @ MLINE,1 SAY 'GRAND TOTALS:'
         @ MLINE,109 SAY MTOT_CAS  PICTURE '999999'
         @ MLINE,114 SAY MTOT_LBS PICTURE '99,999,999.99'
         @ MLINE,148 SAY MTOT_VAL PICTURE '99,999,999.99'
         @ MLINE+1,1 SAY ' '
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      
      CLOSE DATA
      MRPT_SEL   = ' '
      
   CASE MRPT_SEL = '2'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT LOTS WITH APPROACHING ANNIV DATES'
      @ 2,0 to 22,79
      MPROD = SPACE(6)
      MDIV  = SPACE(2)
      MFREEZER = SPACE(40)
      MCUTOFF_DT = CTOD('')
      MRPT_PICK = 'D'
      @ 5,3 SAY '                Enter Report Date: ' GET MCUTOFF_DT
      @ 6,3 SAY '(Will print lots with anniversaries from above date forward 14 days)'
      @ 8,3 SAY '     Enter OPTIONAL Division Code: ' GET MDIV PICTURE '@!'
      @ 10,3 SAY '      Enter OPTIONAL Product Code: ' GET MPROD  PICTURE '@!'
      @ 12,3 SAY '      Enter OPTIONAL Freezer Name: ' GET MFREEZER PICTURE '@!'
      READ
      IF DTOC(MCUTOFF_DT) = '  /  /  '
         LOOP
      ENDIF
      
      @ 5,3 CLEAR TO 12,78
      
      MPRT_ACT = 'C'
      
      @ 20,01 CLEAR TO 20,78 
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      MPAGE_LEN = 44
      
      MPAGE_NO = 0
      MLINE = 99
      
      @ 21,16 SAY SPACE(34)
      @ 21,16 SAY 'PROCESSING............'
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      MDATE = MCUTOFF_DT
      I = 1
      DO WHILE I <= 14
         MI = SUBSTR(STR(I+100,3),2)
         MDAY&MI = SUBSTR(DTOC(MDATE),4,2)
         MDATE = MDATE + 1
         I = I + 1
      ENDDO
      
      SELECT E
      DO FOX_USE WITH "&MMASTDBF.DIVISION", .F.
      
      SELECT D 
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNSOLD", .F.
      SEEK ' '
      MTOT_LBS = 0
      MTOT_VAL = 0
      MTOT_CASE = 0
      IF MFREEZER <> SPACE(40)
         MFREEZER = TRIM(MFREEZER)
      ENDIF
      DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' '
         IF MDIV <> SPACE(2)
            IF MDIV <> DIV_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
         MMATCH = .F.
         I = 1
         DO WHILE I <= 14 .AND. .NOT. MMATCH
            MI = SUBSTR(STR(I+100,3),2)
            IF SUBSTR(DTOC(ANIV_DATE),4,2) = MDAY&MI
               MMATCH = .T.
            ENDIF
            I = I + 1
         ENDDO
         IF .NOT. MMATCH
            SKIP
            LOOP
         ENDIF
         
         MTOT_DLBS = 0
         MTOT_DVAL = 0
         MTOT_DCAS = 0
         MDIV_CODE = DIV_CODE
         MDIV_NAME = 'DIVISION CODE NOT ON FILE'
         SELECT E
         GOTO TOP
         DO WHILE .NOT. EOF()
            IF MDIV_CODE = DIV_CODE
               MDIV_NAME = DIV_NAME
               GOTO BOTTOM
            ENDIF
            SKIP
         ENDDO
         
         SELECT A
         IF MPROD <> SPACE(6)
            IF MPROD <> PROD_DESC
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         IF MFREEZER <> SPACE(40)
            IF FREEZ_LOC <> MFREEZER
               SKIP
               LOOP
            ENDIF
         ENDIF
         MMATCH = .F.
         I = 1
         DO WHILE I <= 14 .AND. .NOT. MMATCH
            MI = SUBSTR(STR(I+100,3),2)
            IF SUBSTR(DTOC(ANIV_DATE),4,2) = MDAY&MI
               MMATCH = .T.
            ENDIF
            I = I + 1
         ENDDO
         IF .NOT. MMATCH
            SKIP
            LOOP
         ENDIF
         
         MPRT_DIV = .T.
         SELECT A
         DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' ' .AND. DIV_CODE = MDIV_CODE
            MSV_PROD = PROD_DESC
            MPROD_LBS = 0
            MPROD_DLR = 0
            MPROD_CASE = 0
            **DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' ' .AND. DIV_CODE = MDIV_CODE .AND. MSV_PROD = PROD_DESC
            IF MPROD <> SPACE(6)
               IF MPROD <> PROD_DESC
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            IF MFREEZER <> SPACE(40)
               IF FREEZ_LOC <> MFREEZER
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            MMATCH = .F.
            I = 1
            DO WHILE I <= 14 .AND. .NOT. MMATCH
               MI = SUBSTR(STR(I+100,3),2)
               IF SUBSTR(DTOC(ANIV_DATE),4,2) = MDAY&MI
                  MMATCH = .T.
               ENDIF
               I = I + 1
            ENDDO
            IF .NOT. MMATCH
               SKIP
               LOOP
            ENDIF
            
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  EJECT 
               ENDIF
               
               MPAGE_NO = MPAGE_NO + 1
               
               @ 1,59 SAY MCOMPANY
               @ 2,1 SAY 'Page'
               @ 2,06 say mpage_no picture '99'
               @ 2,50 SAY '  ANNIVERSARY SUMMARY AS OF ' + DTOC(MDATE)
               @ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
               @ 4,1 SAY '  DATE    LOCATION              LOT #    I #   SALES   SUPPLIER            PROD SIZE PRODUCT           PACK  CASES      POUNDS     PRICE   COST/LB    TOTAL COST'
               @ 4,01 SAY REPLICATE('_',160)
               MLINE = 6
            ENDIF
            IF MPRT_DIV
               @ MLINE,1 SAY 'DIVISION: ' + MDIV_NAME
               @ MLINE,1 SAY REPLICATE('_',42)
               MPRT_DIV = .F.
               MLINE = MLINE + 2
            ENDIF
            IF MRPT_PICK = 'D'
               @ MLINE,1 SAY ANIV_DATE
               @ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
               @ MLINE,33 SAY LOT_NBR
               **@ MLINE,42 SAY STR(I_NBR,5)  
               *** GO FIND THE SALESPERSON NAME
               IF SALESMAN <> '  '
                  SELECT D
                  SEEK A->SALESMAN
                  IF .NOT. EOF()
                     @ MLINE,48 SAY SUBSTR(NAME,1,7)
                  ELSE
                     @ MLINE,48 SAY A->SALESMAN
                  ENDIF
                  SELECT A
               ELSE
                  @ MLINE,48 SAY BROK_NAME
               ENDIF
               @ MLINE,56 SAY SUPPLIER
               @ MLINE,76 SAY PROD_SIZE
               *IF DTOC(PAID_DATE) = '  /  /  '
               *   @ MLINE,79 SAY 'NO'
               *ELSE
               *   @ MLINE,76 SAY PAID_DATE
               *ENDIF
            ENDIF
            SELECT C
            SEEK 'R' + A->PROD_DESC
            IF EOF()       
               MDESC = A->PROD_DESC
            ELSE
               MDESC = SUBSTR(DESC,1,15)
            ENDIF
            IF MRPT_PICK = 'D'
               @ MLINE,86 SAY SUBSTR(MDESC,1,15)
            ENDIF
            SELECT A
            MCASE_LEFT = 0
            MVAL_LEFT = 0
            MLBS_LEFT = 0
            DO CALC_CUR
            IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
               MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
            ELSE
               MPRO_PRI = 0
               MVAL_LEFT = 0
            ENDIF
            IF MRPT_PICK = 'D'
               @ MLINE,104 SAY BOX_SIZE
               @ MLINE,111 SAY MCASE_LEFT PICTURE '9999'
               @ MLINE,117 SAY MLBS_LEFT  PICTURE '999,999.99'
               @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
               @ MLINE,140 SAY MPRO_PRI   PICTURE '99.9999'
               @ MLINE,149 SAY MVAL_LEFT  PICTURE '9,999,999.99'
            ENDIF
            MPROD_LBS = MPROD_LBS + LBS_LEFT
            MPROD_DLR = MPROD_DLR + MVAL_LEFT
            MPROD_CASE = MPROD_CASE + MCASE_LEFT
            IF MRPT_PICK = 'D'
               MLINE = MLINE + 2
            ENDIF
            SKIP
            **ENDDO
            *@ MLINE,5 SAY TRIM(MDESC) + ' TOTAL:' 
            *@ MLINE,5 SAY REPLICATE('_',22)
            *@ MLINE,109 SAY MPROD_CASE PICTURE '999999'
            *@ MLINE,116 SAY MPROD_LBS  PICTURE '9,999,999.9'
            *@ MLINE,149 SAY MPROD_DLR  PICTURE '9,999,999.99'
            *@ MLINE,109 SAY REPLICATE('_',52)
            *MLINE = MLINE + 3
            MTOT_DLBS = MTOT_DLBS + MPROD_LBS
            MTOT_DVAL = MTOT_DVAL + MPROD_DLR
            MTOT_DCAS = MTOT_DCAS + MPROD_CASE
         ENDDO
         
         MTOT_LBS = MTOT_LBS + MTOT_DLBS
         MTOT_VAL = MTOT_VAL + MTOT_DVAL
         MTOT_CASE = MTOT_CASE + MTOT_DCAS
         *@ MLINE,1 SAY 'DIVISION TOTALS:'
         *@ MLINE,109 SAY MTOT_DCAS PICTURE '999999'
         *@ MLINE,115 SAY MTOT_DLBS PICTURE '99,999,999.9'
         *@ MLINE,148 SAY MTOT_DVAL PICTURE '99,999,999.99'
         *MLINE = MLINE + 3
      ENDDO
      
      IF MLINE <> 99     
         *MLINE = MLINE + 1
         *@ MLINE,1 SAY 'GRAND TOTALS:'
         *@ MLINE,109 SAY MTOT_CASE  PICTURE '999999'
         *@ MLINE,115 SAY MTOT_LBS PICTURE '99,999,999.9'
         *@ MLINE,148 SAY MTOT_VAL PICTURE '99,999,999.99'
         
         @ MLINE+1,1 SAY ' '
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      MRPT_SEL   = ' '
      
   CASE MRPT_SEL = '3'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT INVENTORY ACTIVITY BY PO NBR'
      @ 2,0 to 22,79
      MPROD    = SPACE(6)
      MDIV     = SPACE(2)
      MFREEZER = SPACE(40)
      MI_NBR   = 0         
      MIN_OUT  = 'BOTH'
      MIN_TOT  = 0
      MOUT_TOT = 0
      STORE CTOD('') TO MBEG_DATE, MEND_DATE
      MRPT_PICK = '1'
      MTOT_ONLY = 'N'
      @ 8,3 SAY  'Beginning Activity Date: ' GET MBEG_DATE
      @ 10,3 SAY '   Ending Activity Date: ' GET MEND_DATE
      @ 12,3 SAY '  Optionl Division Code: ' GET MDIV PICTURE '@!'
      @ 14,3 SAY ' Activity (IN/OUT/BOTH): ' GET MIN_OUT PICTURE '@!'
      @ 16,3 SAY 'Print totals only (Y/N): ' get mtot_only picture '@!'
      READ
      IF MRPT_PICK = ' '
         LOOP
      ENDIF
      IF MTOT_ONLY <> 'N'
         MTOT_ONLY = 'Y'
      ENDIF
      
      @ 4,3 CLEAR TO 22,78
      
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      IF MIN_OUT = '    '
         MIN_OUT = 'BOTH'
      ENDIF
      ** IF DATES ARE LEFT BLANK, PICK UP ALL ACTIVITY
      ** BY FORMATTING WITH REAL OLD AND CURRENT BEGIN/END
      IF DTOC(MBEG_DATE) = '  /  /  '
         MBEG_DATE = CTOD('01/01/90')
      ENDIF
      IF DTOC(MEND_DATE) = '  /  /  '
         MEND_DATE = DATE()
      ENDIF
      MPAGE_LEN = 44
      MPAGE_NO = 0
      MLINE = 99
      
      @ 21,16 SAY SPACE(34)
      @ 21,16 SAY 'PROCESSING............'
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      SELECT E
      DO FOX_USE WITH "&MMASTDBF.DIVISION", .F.
      
      SELECT D 
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      SELECT B
      USE INVNTEMP EXCLUSIVE
      DELETE ALL
      PACK
      DO FOX_USE WITH "INVNTEMP", .F.
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNANIV", .F.
      
      IF MFREEZER <> SPACE(40)
         MFREEZER = TRIM(MFREEZER)
      ENDIF
      IF MIN_OUT = 'IN' .OR. MIN_OUT = 'BOTH'
         
         IF YEAR(MBEG_DATE) >= YEAR(ANIV_DATE)
            SEEK STR(YEAR(MBEG_DATE),4)
         ENDIF
         
         ** FIRST GET ALL THE SHIPMENTS INTO INVENTORY THAT
         ** FALL INTO THIS DATE RANGE - THESE COME FROM THE "INVEN" FILE
         
         DO WHILE .NOT. EOF() .AND. ANIV_DATE < MBEG_DATE
            SKIP
         ENDDO
         
         DO WHILE .NOT. EOF() .AND. ANIV_DATE <= MEND_DATE
            
            IF LBS = 0 .OR. CASE_CNT = 0
               SKIP
               LOOP
            ENDIF
            
            ** CHECK DIVISION CODE MATCH
            IF MDIV <> SPACE(2)
               IF MDIV <> DIV_CODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            ** CHECK PRODUCT DESCRIPTION MATCH
            IF MPROD <> SPACE(6)
               IF MPROD <> PROD_DESC
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            ** CHECK FREEZER MATCH
            IF MFREEZER <> '  '
               IF TRIM(FREEZ_LOC) <> MFREEZER
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK I NBR MATCH
            IF MI_NBR <> 0
               IF MI_NBR <> I_NBR
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE SALESMAN    WITH A->SALESMAN
            REPLACE PO_NBR      WITH A->PO_NBR
            REPLACE PO_SUFFIX   WITH A->PO_SUFFIX
            REPLACE FREEZ_LOC   WITH A->FREEZ_LOC
            REPLACE I_NBR       WITH A->I_NBR
            REPLACE DIV_CODE    WITH A->DIV_CODE
            REPLACE PROD_DESC   WITH A->PROD_DESC
            REPLACE BOX_SIZE    WITH A->BOX_SIZE
            REPLACE LOT_NBR     WITH A->LOT_NBR
            REPLACE SUPPLIER    WITH A->SUPPLIER
            REPLACE LBS         WITH A->LBS
            REPLACE PRI_LB      WITH A->PRI_LB
            REPLACE CASE_CNT    WITH A->CASE_CNT
            REPLACE VALUE       WITH A->VALUE
            REPLACE ACT_DATE    WITH A->ANIV_DATE
            REPLACE ACT_CODE    WITH 'I'
            UNLOCK
            SELECT A
            SKIP
         ENDDO
      ENDIF
      **HERE      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNINBR", .F.
      
      SELECT F
      DO FOX_USE WITH "INVN_DTL INDEX DTL_DATE", .F.
      
      *** GET ALL THE OUT ACTIVITY FROM THE DETAIL FILE
      *** FOR THE SPECIFIED TIME FRAME
      
      IF MIN_OUT = 'OUT' .OR. MIN_OUT = 'BOTH'
         IF YEAR(MBEG_DATE) >= YEAR(ACT_DATE)
            SEEK STR(YEAR(MBEG_DATE),4)
         ENDIF
         ** FIRST GET ALL THE SHIPMENTS OUT OF INVENTORY THAT
         ** FALL INTO THIS DATE RANGE
         DO WHILE .NOT. EOF() .AND. ACT_DATE <  MBEG_DATE
            SKIP
         ENDDO
         DO WHILE .NOT. EOF() .AND. ACT_DATE <= MEND_DATE
            *** IF THIS IS NOT A SHIPMENT RECORD, SKIP IT
            IF ACT_CODE <> 'S'
               SKIP
               LOOP
            ENDIF
            
            IF SHIP_LBS = 0 .OR. SHIP_CASE = 0
               SKIP
               LOOP
            ENDIF
            ** CHECK I NBR MATCH
            IF MI_NBR <> 0
               IF MI_NBR <> I_NBR
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT A
            SEEK STR(F->I_NBR,5)
            ** CHECK PRODUCT DESCRIPTION MATCH
            IF MPROD <> SPACE(6)
               IF MPROD <> PROD_DESC
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK DIVISION CODE MATCH
            IF MDIV <> SPACE(2)
               IF MDIV <> DIV_CODE
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK FREEZER MATCH
            IF MFREEZER <> '  '
               IF TRIM(FREEZ_LOC) <> MFREEZER
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE FREEZ_LOC   WITH A->FREEZ_LOC
            REPLACE I_NBR       WITH A->I_NBR
            REPLACE DIV_CODE    WITH A->DIV_CODE
            REPLACE PROD_DESC   WITH A->PROD_DESC
            REPLACE BOX_SIZE    WITH A->BOX_SIZE
            REPLACE LOT_NBR     WITH A->LOT_NBR
            REPLACE SUPPLIER    WITH A->SUPPLIER
            *** GET THIS INFO FROM DETAIL RECORD
            REPLACE SALESMAN    WITH F->SALESMAN
            REPLACE PO_NBR      WITH F->PO_NBR
            REPLACE PO_SUFFIX   WITH F->PO_SUFFIX
            REPLACE LBS         WITH (F->SHIP_LBS * -1)
            REPLACE PRI_LB      WITH F->SHIP_PRI
            REPLACE CASE_CNT    WITH (F->SHIP_CASE * -1)
            REPLACE VALUE       WITH (F->SHIP_VAL * -1)
            REPLACE ACT_DATE    WITH F->ACT_DATE
            REPLACE ACT_CODE    WITH 'S'
            UNLOCK
            SELECT F
            SKIP
         ENDDO
      ENDIF
      
      SELECT B
      USE INVNTEMP EXCLUSIVE
      INDEX ON DIV_CODE + SALESMAN + PO_NBR + PO_SUFFIX + STR(YEAR(ACT_DATE),4) + SUBSTR(DTOC(ACT_DATE),1,5) TO INVNTEMP
      **** TO HERE
      DO FOX_USE WITH "INVNTEMP INDEX INVNTEMP", .F.
      **** ZERO OUT GRAND TOTALS ***
      MTOT_LBS = 0
      MTOT_VAL = 0
      MTOT_CAS = 0
      ***********************************
      SELECT E
      GOTO TOP
      DO WHILE .NOT. EOF()
         MDIV_NAME = DIV_NAME
         MTOT_DLBS = 0
         MTOT_DVAL = 0
         MTOT_DCAS = 0
         SELECT B
         SEEK E->DIV_CODE
         IF EOF()
            SELECT E
            SKIP
            LOOP
         ENDIF
         IF MLINE <> 99
            MLINE = 89
         ENDIF
         
         DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE
            MTOT_ALBS = 0
            MTOT_AVAL = 0
            MTOT_ACAS = 0
            MSALESMAN = SALESMAN
            MPO_NBR   = PO_NBR
            MPO_SUFFIX = PO_SUFFIX
            
            DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX     
               
               *** PRINT THE DETAIL HERE
               IF MLINE > MPAGE_LEN
                  DO ACT_HEAD
               ENDIF
               
               IF MTOT_ONLY = 'N'
                  SELECT C
                  SEEK 'R' + B->PROD_DESC 
                  IF EOF()       
                     MDESC = 'CODE: ' + B->PROD_DESC
                  ELSE
                     MDESC = SUBSTR(DESC,1,15)
                  ENDIF
                  
                  SELECT B
                  @ MLINE,1 SAY ACT_DATE
                  **@ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
                  @ MLINE,33 SAY LOT_NBR
                  **@ MLINE,42 SAY STR(I_NBR,5)  
                  @ MLINE,52 SAY SALESMAN
                  IF SALESMAN <> '  '
                     @ MLINE,54 SAY '-'
                  ENDIF
                  @ MLINE,55 SAY PO_NBR
                  IF PO_SUFFIX <> ' '
                     @ MLINE,59 SAY '-' + PO_SUFFIX
                  ENDIF
                  *@ MLINE,62 SAY SUBSTR(SUPPLIER,1,15)
                  IF ACT_CODE = 'I'
                     @ MLINE,79 SAY 'IN'
                  ELSE
                     @ MLINE,79 SAY 'OUT'     
                  ENDIF
                  *@ MLINE,86 SAY SUBSTR(MDESC,1,15)
                  *@ MLINE,104 SAY BOX_SIZE
                  @ MLINE,110 SAY CASE_CNT  PICTURE '99999'
                  @ MLINE,117 SAY LBS       PICTURE '999,999.99'
                  @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
                  @ MLINE,147 SAY VALUE     PICTURE '9,999,999.99'
                  MTOT_ALBS = MTOT_ALBS + LBS
                  MTOT_AVAL = MTOT_AVAL + VALUE
                  MTOT_ACAS = MTOT_ACAS + CASE_CNT
                  MLAST_VAL = VALUE
                  MLINE = MLINE + 1
               ENDIF
               IF ACT_CODE = 'I'
                  MIN_TOT = MIN_TOT + VALUE
               ELSE
                  MOUT_TOT = MOUT_TOT + VALUE
               ENDIF
               SKIP
            ENDDO
            
            IF MTOT_ONLY = 'N' 
               *** DO PO TOTALS
               IF MLAST_VAL = MTOT_AVAL
                  @ MLINE-1,147 SAY REPLICATE('_',12)
                  MLINE = MLINE + 1
               ELSE       
                  @ MLINE,5 SAY 'PO TOTAL:'            
                  @ MLINE,5 SAY REPLICATE('_',09)
                  @ MLINE,109 SAY MTOT_ACAS PICTURE '999999'
                  @ MLINE,115 SAY MTOT_ALBS  PICTURE '9,999,999.99'
                  @ MLINE,147 SAY MTOT_AVAL  PICTURE '9,999,999.99'
                  @ MLINE,147 SAY REPLICATE('_',12)
                  MLINE = MLINE + 2
               ENDIF
            ENDIF
            MTOT_DLBS = MTOT_DLBS + MTOT_ALBS
            MTOT_DVAL = MTOT_DVAL + MTOT_AVAL
            MTOT_DCAS = MTOT_DCAS + MTOT_ACAS 
            MTOT_ALBS = 0
            MTOT_AVAL = 0
            MTOT_ACAS = 0
         ENDDO
         IF MTOT_ONLY = 'N'
            *** DO DIVISION TOTALS
            IF MLINE > MPAGE_LEN
               DO ACT_HEAD
            ENDIF
            @ MLINE,5 SAY 'DIV.-' + TRIM(MDIV_NAME) + ' TOTALS: ' 
            @ MLINE,109 SAY MTOT_DCAS PICTURE '999999'
            @ MLINE,115 SAY MTOT_DLBS  PICTURE '9,999,999.99'
            @ MLINE,147 SAY MTOT_DVAL  PICTURE '9,999,999.99'
            MLINE = MLINE + 3
            @ MLINE,05 SAY REPLICATE('*',156)
            MTOT_LBS = MTOT_LBS + MTOT_DLBS
            MTOT_VAL = MTOT_VAL + MTOT_DVAL
            MTOT_CAS = MTOT_CAS + MTOT_DCAS 
            MLINE = MLINE + 3
            MTOT_DLBS = 0
            MTOT_DVAL = 0
            MTOT_DCAS = 0
         ENDIF
         SELECT E
         SKIP
      ENDDO
      IF MLINE <> 99     
         IF MLINE > MPAGE_LEN
            DO ACT_HEAD
         ENDIF
         MLINE = MLINE + 1
         @ MLINE,1 SAY 'GRAND TOTALS:'
         @ MLINE,109 SAY MTOT_CAS  PICTURE '999999'
         @ MLINE,114 SAY MTOT_LBS PICTURE '99,999,999.99'
         @ MLINE,146 SAY MTOT_VAL PICTURE '99,999,999.99'
         MLINE = MLINE + 3
         @ MLINE,1 SAY 'GRAND TOTALS $ IN: '  
         @ MLINE,22 SAY MIN_TOT PICTURE '99,999,999.99'
         MLINE = MLINE + 1
         @ MLINE,1 SAY 'GRAND TOTALS $ OUT: '  
         @ MLINE,22 SAY MOUT_TOT PICTURE '99,999,999.99'
         
         @ MLINE+1,1 SAY ' '
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      MRPT_SEL   = ' '
      
      
   CASE MRPT_SEL = '5'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT REMAINING INVENTORY REPORT BY I NUMBER'   
      @ 2,0 to 22,79
      MPROD    = SPACE(6)
      MDIV     = SPACE(2)
      MFREEZER = SPACE(40)
      MI_NBR   = 0         
      MIN_OUT  = 'BOTH'
      STORE CTOD('') TO MBEG_DATE, MEND_DATE
      MRPT_PICK = '1'
      STORE CTOD('') TO MEND_DATE
      MRPT_PICK = '1'
      @ 8,3 SAY  'Enter Month Ending Date: ' GET MEND_DATE
      
      READ
      @ 4,3 CLEAR TO 22,78
      
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      @ 10,4 SAY 'PRINTING.....'
      MPAGE_LEN = 44
      MPAGE_NO = 0
      MLINE = 99
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      SELECT D
      DO FOX_USE WITH "&MMASTDBF.DIVISION", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      SELECT B
      DO FOX_USE WITH "INVN_DTL INDEX DTL_DATE", .F.
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNINBR", .F.
      
      MTOT_LBS = 0
      MTOT_VAL = 0
      MTOT_CAS = 0
      ***********************************
      DO WHILE .NOT. EOF()
         IF SOLD_FLG <> ' '
            SKIP
            LOOP
         ENDIF
         IF VAL_LEFT <= 0 .AND. CASE_LEFT <= 0 .AND. LBS_LEFT <= 0
            SKIP
            LOOP
         ENDIF
         IF ANIV_DATE > MEND_DATE
            SKIP
            LOOP
         ENDIF
         
         *** PRINT THE DETAIL HERE
         IF MLINE > MPAGE_LEN
            DO ACT_HD1 
         ENDIF
         MCASE_LEFT =    CASE_LEFT 
         MLBS_LEFT  =    LBS_LEFT   
         
         SELECT B
         SEEK STR(A->I_NBR,5) + 'S'
         DO WHILE .NOT. EOF() .AND. A->I_NBR = I_NBR .AND. ACT_CODE = 'S'
            IF ACT_DATE > MEND_DATE
               MCASE_LEFT = MCASE_LEFT + SHIP_CASE
               MLBS_LEFT  = MLBS_LEFT +  SHIP_LBS
            ENDIF
            SKIP
         ENDDO
         
         SELECT C
         SEEK 'R' + A->PROD_DESC 
         IF EOF()       
            MDESC = 'CODE: ' + A->PROD_DESC
         ELSE
            MDESC = SUBSTR(DESC,1,15)
         ENDIF
         
         SELECT A
         @ MLINE,1 SAY ANIV_DATE
         @ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
         @ MLINE,33 SAY LOT_NBR
         *@ MLINE,42 SAY STR(I_NBR,5)  
         @ MLINE,62 SAY SUBSTR(SUPPLIER,1,15)
         @ MLINE,86 SAY SUBSTR(MDESC,1,15)
         @ MLINE,104 SAY BOX_SIZE
         
         @ MLINE,110 SAY MCASE_LEFT PICTURE '99999'
         @ MLINE,117 SAY MLBS_LEFT  PICTURE '999,999.99'
         @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
         *MVAL_LEFT = ROUND(MLBS_LEFT*PRI_LB,2)
         *@ MLINE,149 SAY MVAL_LEFT  PICTURE '9,999,999.99'
         MTOT_LBS = MTOT_LBS + MLBS_LEFT  
         **MTOT_VAL = MTOT_VAL + MVAL_LEFT 
         MTOT_CAS = MTOT_CAS + MCASE_LEFT 
         MLINE = MLINE + 2
         SKIP
      ENDDO
      
      IF MLINE <> 99     
         IF MLINE > MPAGE_LEN
            DO ACT_HD1  
         ENDIF
         MLINE = MLINE + 1
         @ MLINE,1 SAY 'GRAND TOTALS:'
         @ MLINE,109 SAY MTOT_CAS  PICTURE '999999'
         @ MLINE,114 SAY MTOT_LBS PICTURE '99,999,999.99'
         **@ MLINE,148 SAY MTOT_VAL PICTURE '99,999,999.99'
         @ MLINE+1,1 SAY ' '
         EJECT
      ENDIF
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      MRPT_SEL   = ' '
   CASE MRPT_SEL = '6'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT INVENTORY REPORT BY LOT NUMBER'
      @ 2,0 to 22,79
      MDIV  = SPACE(2)
      MFREEZER = SPACE(40)
      MRPT_ORDER = '    '
      @ 7,3 SAY '     Enter Optional Division Code: ' GET MDIV PICTURE '@!'
      @ 09,3 SAY '      Enter Optional Freezer Name: ' GET MFREEZER PICTURE '@!'
      @ 11,1 SAY 'Print in Lot (LOT) or Date (DATE) Order: ' GET MRPT_ORDER PICTURE '@!'
      READ
      @ 5,1 CLEAR TO 11,78
      
      MPRT_ACT = 'C'
      
      @ 20,01 CLEAR TO 20,78 
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      
      MPAGE_LEN = 44
      MPAGE_NO = 0
      MLINE = 99
      
      @ 21,16 SAY SPACE(34)
      @ 21,16 SAY 'PROCESSING............'
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      SELECT E
      DO FOX_USE WITH "&MMASTDBF.DIVISION", .F.
      
      SELECT D 
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      DO CASE
      CASE MRPT_ORDER = 'LOT'
         SELECT A
         DO FOX_USE WITH "INVEN INDEX INVNLOT", .F.
      OTHERWISE
         SELECT A
         *** DATE ORDER 
         DO FOX_USE WITH "INVEN INDEX INVNANIV", .F.
      ENDCASE
      MTOT_LBS = 0
      MTOT_VAL = 0
      MTOT_CASE = 0
      IF MFREEZER <> SPACE(40)
         MFREEZER = TRIM(MFREEZER)
      ENDIF
      
      I = 1
      DO WHILE I <= 24
         MI = SUBSTR(STR(I+100,3),2)
         STORE 0 TO MNBR&MI
         I = I + 1
      ENDDO
      
      DO WHILE .NOT. EOF()
         IF SOLD_FLG <> ' '
            SKIP
            LOOP
         ENDIF 
         IF MDIV <> SPACE(2)
            IF MDIV <> DIV_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
         IF MFREEZER <> SPACE(40)
            IF FREEZ_LOC <> MFREEZER
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT 
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,59 SAY MCOMPANY
            @ 2,1 SAY 'Page'
            @ 2,06 say mpage_no picture '99'
            @ 2,50 SAY '    INVENTORY REPORT  AS OF ' + DTOC(DATE())
            @ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
            *IF MRPT_ORDER = 'LOT'
            *   @ 3,50 SAY '      WITH ESTIMATED STORAGE'         
            *   @ 5,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK  CASES        UNITS  PUR PRI  PUR+STOR   COST W/STOR'
            *   @ 6,01 SAY REPLICATE('_',160)
            *    MLINE = 8
            *ELSE
            @ 5,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK  CASES        UNITS  PUR PRI     POUNDS      TOTAL $'
            @ 5,01 SAY REPLICATE('_',160)
            MLINE = 7
            *ENDIF
         ENDIF
         @ MLINE,1 SAY ANIV_DATE
         @ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
         @ MLINE,33 SAY LOT_NBR
         **@ MLINE,42 SAY STR(I_NBR,5)  
         *** GO FIND THE SALESPERSON NAME
         IF SALESMAN <> '  '
            SELECT D
            SEEK A->SALESMAN
            IF .NOT. EOF()
               *@ MLINE,48 SAY SUBSTR(NAME,1,7)
            ELSE
               *@ MLINE,48 SAY A->SALESMAN
            ENDIF
            SELECT A
         ELSE
            *@ MLINE,48 SAY BROK_NAME
         ENDIF
         @ MLINE,49 SAY SUBSTR(SUPPLIER,1,16)
         @ MLINE,69 SAY PROD_DESC
         @ MLINE,76 SAY PROD_SIZE
         
         SELECT C
         SEEK 'R' + A->PROD_DESC
         IF EOF()       
            MDESC = A->PROD_DESC
         ELSE
            MDESC = SUBSTR(DESC,1,15)
         ENDIF
         @ MLINE,86 SAY SUBSTR(MDESC,1,15)
         SELECT A
         MCASE_LEFT = 0
         MVAL_LEFT = 0
         MLBS_LEFT = 0
         DO CALC_CUR
         IF MLBS_LEFT <> 0
            *IF SUBSTR(BOX_SIZE,1,1) = 'B'                                  
            *   MSTOR_UNIT = ROUND(VAL(SUBSTR(BOX_SIZE,2))*.0125,4)
            *ELSE
            *   MSTOR_UNIT = .0125
            *ENDIF
            MSTOR_UNIT = 0
            MPRO_PRI = PRI_LB + MSTOR_UNIT                  
            MVAL_LEFT = ROUND(MPRO_PRI * MLBS_LEFT,2)
         ELSE
            MPRO_PRI = 0
            MVAL_LEFT = 0
         ENDIF
         
         @ MLINE,104 SAY BOX_SIZE
         @ MLINE,111 SAY MCASE_LEFT PICTURE '9999'
         MTOT_CASE = MTOT_CASE + MCASE_LEFT
         @ MLINE,118 SAY MLBS_LEFT  PICTURE '999,999.99'
         
         @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
         *IF MRPT_ORDER = 'LOT'
         *   @ MLINE,140 SAY MPRO_PRI   PICTURE '99.9999'
         *ENDIF
         
         IF SUBSTR(box_size,1,1) = 'B'
            mbox_sz = val(substr(box_size,2))
            MLBS = ROUND(mcase_LEFT * mbOX_SZ,2)
         ELSE
            mlbs = mlbs_left                                          
         ENDIF
         @ mline,138 say mlbs picture '999,999.99'
         MTOT_LBS = MTOT_LBS + MLBS
         
         IF MLBS_LEFT <> 0
            @ MLINE,149 SAY MVAL_LEFT  PICTURE '9,999,999.99'
            MTOT_VAL = MTOT_VAL + MVAL_LEFT
            *** NOW ADD IN FOR ANIVERSARY DATE $
            MNO_DATE = CTOD('')
            MANIV_DATE = ANIV_DATE
            MMO = VAL(SUBSTR(DTOC(MANIV_DATE),1,2))
            MMO = MMO + 1
            MMO = SUBSTR(STR(MMO+100,3),2)
            IF MMO = '13'
               MMO = '01'
               MYR = VAL(SUBSTR(DTOC(MANIV_DATE),7))
               MYR = MYR + 1
               MYR = STR(MYR,4)
            ELSE
               MYR = SUBSTR(DTOC(MANIV_DATE),7)
            ENDIF
            MREST = SUBSTR(DTOC(MANIV_DATE),3,4)
            MDY = SUBSTR(DTOC(MANIV_DATE),4,2)
            MANIV_DATE = CTOD(MMO+MREST+MYR)
            ** CHECK FOR VALID DATE
            IF MANIV_DATE = MNO_DATE
               MDAYX = VAL(MDY)
               DO WHILE MANIV_DATE = MNO_DATE
                  MDAYX = MDAYX - 1
                  MX = SUBSTR(STR(MDAYX+100,3),2)
                  MANIV_DATE = CTOD(MMO+'/'+MX+'/'+MYR)
               ENDDO
            ENDIF
            ** END OF VALID DATE CHECK
            I = 0
            DO WHILE MANIV_DATE <= DATE()
               I = I + 1
               MMO = VAL(SUBSTR(DTOC(MANIV_DATE),1,2))
               MMO = MMO + 1
               MMO = SUBSTR(STR(MMO+100,3),2)
               IF MMO = '13'
                  MMO = '01'
                  MYR = VAL(SUBSTR(DTOC(MANIV_DATE),7))
                  MYR = MYR + 1
                  MYR = STR(MYR,4)
               ELSE
                  MYR = SUBSTR(DTOC(MANIV_DATE),7)
               ENDIF
               MREST = SUBSTR(DTOC(MANIV_DATE),3,4)
               MANIV_DATE = CTOD(MMO+MREST+MYR)
               ** CHECK FOR VALID DATE
               IF MANIV_DATE = MNO_DATE
                  MDAYX = VAL(MDY)
                  DO WHILE MANIV_DATE = MNO_DATE
                     MDAYX = MDAYX - 1
                     MX = SUBSTR(STR(MDAYX+100,3),2)
                     MANIV_DATE = CTOD(MMO+'/'+MX+'/'+MYR)
                  ENDDO
               ENDIF
               ** END OF VALID DATE CHECK
            ENDDO
            IF I <> 0
               MI = SUBSTR(STR(I+100,3),2)
               MNBR&MI = MNBR&MI + MVAL_LEFT
            ENDIF
         ENDIF
         MLINE = MLINE + 2
         SKIP
      ENDDO
      
      IF MLINE <> 99     
         MLINE = MLINE + 1
         @ MLINE,1 SAY 'GRAND TOTALS:'
         *@ MLINE,109 SAY MTOT_CASE  PICTURE '999999'
         *@ MLINE,115 SAY MTOT_LBS PICTURE '99,999,999.99'
         @ mline,135 say mTOT_lbs picture '99,999,999.99'
         @ MLINE,148 SAY MTOT_VAL PICTURE '99,999,999.99'
         *@ MLINE+1,1 SAY ' '
         MLINE = MLINE + 3
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT 
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,59 SAY MCOMPANY
            @ 2,1 SAY 'Page'
            @ 2,06 say mpage_no picture '99'
            @ 2,50 SAY '    INVENTORY REPORT  AS OF ' + DTOC(DATE())
            @ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
            *IF MRPT_ORDER = 'LOT'
            *   @ 3,50 SAY '      WITH ESTIMATED STORAGE'         
            *   @ 5,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK  CASES        UNITS  PUR PRI  PUR+STOR   COST W/STOR'
            *   @ 6,01 SAY REPLICATE('_',160)
            *    MLINE = 8
            *ELSE
            @ 5,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK  CASES        UNITS  PUR PRI                 TOTAL $'
            @ 5,01 SAY REPLICATE('_',160)
            MLINE = 7
            *ENDIF
         ENDIF
         @ MLINE,1 SAY 'NUMBER OF ANNIVERSARIES            TOTAL VALUE'
         MLINE = MLINE + 2
         MTOT = 0
         I = 1
         DO WHILE I<= 24
            MI = SUBSTR(STR(I+100,3),2)
            IF MNBR&MI <> 0
               IF MLINE > MPAGE_LEN
                  IF MLINE <> 99
                     EJECT 
                  ENDIF
                  MPAGE_NO = MPAGE_NO + 1
                  @ 1,59 SAY MCOMPANY
                  @ 2,1 SAY 'Page'
                  @ 2,06 say mpage_no picture '99'
                  @ 2,50 SAY '    INVENTORY REPORT  AS OF ' + DTOC(DATE())
                  @ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
                  *IF MRPT_ORDER = 'LOT'
                  *   @ 3,50 SAY '      WITH ESTIMATED STORAGE'         
                  *   @ 5,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK  CASES        UNITS  PUR PRI  PUR+STOR   COST W/STOR'
                  *   @ 6,01 SAY REPLICATE('_',160)
                  *    MLINE = 8
                  *ELSE
                  @ 5,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK  CASES        UNITS  PUR PRI                 TOTAL $'
                  @ 5,01 SAY REPLICATE('_',160)
                  MLINE = 7
                  *ENDIF
               ENDIF
               @ MLINE,11 SAY STR(I,2)
               @ MLINE,33 SAY MNBR&MI PICTURE '999,999,999.99'
               MTOT = MTOT + MNBR&MI
               MLINE = MLINE + 2
            ENDIF
            I = I + 1
         ENDDO
         @ MLINE,1 SAY 'TOTAL REACHING ANNIVERSARY'
         @ MLINE,33 SAY MTOT PICTURE '999,999,999.99' 
         @ MLINE+1,1 SAY ' '
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      MRPT_SEL   = ' '
      
   CASE MRPT_SEL = '7'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT BY LOT NUMBER USING CUTOFF DATE'
      @ 2,0 to 22,79
      MDIV  = SPACE(2)
      MFREEZER = SPACE(40)
      MCUTOFF = CTOD('')
      @ 5,3 say '       Enter Activity Cutoff Date: ' GET MCUTOFF
      @ 7,3 SAY '     Enter Optional Division Code: ' GET MDIV PICTURE '@!'
      @ 09,3 SAY '      Enter Optional Freezer Name: ' GET MFREEZER PICTURE '@!'
      READ
      @ 5,3 CLEAR TO 11,78
      
      MPRT_ACT = 'C'
      
      @ 20,01 CLEAR TO 20,78 
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      
      MPAGE_LEN = 44
      MPAGE_NO = 0
      MLINE = 99
      
      @ 21,16 SAY SPACE(34)
      @ 21,16 SAY 'PROCESSING............'
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      SELECT C
      USE INVNTMP3 EXCLUSIVE               
      DELETE ALL
      PACK
      INDEX ON STR(I_NBR,5) TO INVNTMP3
      DO FOX_USE WITH "INVNTMP3 INDEX INVNTMP3", .F.
      DO FILELOCK
      
      SELECT B
      DO FOX_USE WITH "INVN_DTL INDEX DTL_DATE", .F.
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNSOLD", .F.
      SEEK ' '
      DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' '
         IF ANIV_DATE > MCUTOFF
            SKIP
            LOOP
         ENDIF
         SELECT C
         APPEND BLANK
         REPLACE LOT_NBR WITH A->LOT_NBR
         REPLACE DIV_CODE  WITH A->DIV_CODE
         REPLACE FREEZ_LOC WITH A->FREEZ_LOC
         REPLACE BROK_NAME WITH A->BROK_NAME
         REPLACE I_NBR     WITH A->I_NBR
         
         REPLACE RSUPCODE WITH A->RSUPCODE
         REPLACE SUPPLIER WITH A->SUPPLIER
         REPLACE ANIV_DATE WITH A->ANIV_DATE
         REPLACE SHIP_DATE WITH A->SHIP_DATE
         
         REPLACE PROD_SIZE WITH A->PROD_SIZE
         REPLACE PROD_DESC WITH A->PROD_DESC
         REPLACE BOX_SIZE    WITH A->BOX_SIZE
         REPLACE CASE_LEFT WITH A->CASE_LEFT
         REPLACE LBS_LEFT  WITH A->LBS_LEFT
         REPLACE PRI_LB    WITH A->PRI_LB
         REPLACE CASE_CNT  WITH A->CASE_CNT
         SELECT A
         SKIP
      ENDDO
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNINBR", .F.
      
      MTRAN_YR = SUBSTR(DTOC(MCUTOFF),7)
      MTRAN_MO = SUBSTR(DTOC(MCUTOFF),1,2)
      SELECT B
      SEEK MTRAN_YR+MTRAN_MO
      IF EOF()
         SEEK MTRAN_YR
         IF EOF()
            GOTO TOP 
         ENDIF 
      ENDIF
      
      DO WHILE .NOT. EOF()
         IF ACT_DATE <= MCUTOFF
            SKIP
            LOOP
         ENDIF
         IF ACT_CODE <> 'S'
            SKIP
            LOOP
         ENDIF
         
         SELECT A
         SEEK STR(B->I_NBR,5)
         
         IF MDIV <> SPACE(2)
            IF DIV_CODE <> MDIV
               SELECT B
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         IF EOF() .OR. ANIV_DATE > MCUTOFF
            SELECT B
            SKIP
            LOOP
         ENDIF
         SELECT C
         SEEK STR(B->I_NBR,5)                  
         DO CASE
         CASE EOF()     
            APPEND BLANK
            REPLACE LOT_NBR   WITH B->LOT_NBR
            REPLACE I_NBR     WITH B->I_NBR
            REPLACE CASE_LEFT WITH B->SHIP_CASE      
            REPLACE LBS_LEFT  WITH B->SHIP_LBS       
            SELECT A
            SEEK STR(B->I_NBR,5)              
            SELECT C
            REPLACE DIV_CODE  WITH A->DIV_CODE
            REPLACE FREEZ_LOC WITH A->FREEZ_LOC
            REPLACE BROK_NAME WITH A->BROK_NAME
            REPLACE RSUPCODE WITH A->RSUPCODE
            REPLACE SUPPLIER WITH A->SUPPLIER
            REPLACE ANIV_DATE WITH A->ANIV_DATE
            REPLACE SHIP_DATE WITH A->SHIP_DATE
            REPLACE PROD_SIZE WITH A->PROD_SIZE
            REPLACE PROD_DESC WITH A->PROD_DESC
            REPLACE BOX_SIZE    WITH A->BOX_SIZE
            REPLACE PRI_LB    WITH A->PRI_LB
            REPLACE CASE_CNT  WITH A->CASE_CNT
         OTHERWISE
            REPLACE CASE_LEFT WITH CASE_LEFT +  B->SHIP_CASE 
            REPLACE LBS_LEFT  WITH LBS_LEFT +  B->SHIP_LBS 
         ENDCASE
         SELECT B
         SKIP
      ENDDO
      
      CLOSE DATA
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      SELECT A
      USE INVNTMP3 EXCLUSIVE
      INDEX ON FREEZ_LOC + LOT_NBR TO INVNTMP3
      USE
      
      DO FOX_USE WITH "INVNTMP3 INDEX INVNTMP3", .F.
      
      **** HERE
      MTOT_LBS = 0
      MTOT_VAL = 0
      MTOT_CASE = 0
      IF MFREEZER <> SPACE(40)
         MFREEZER = TRIM(MFREEZER)
      ENDIF
      DO WHILE .NOT. EOF()
         IF MDIV <> SPACE(2)
            IF MDIV <> DIV_CODE
               SKIP
               LOOP
            ENDIF
         ENDIF
         IF MFREEZER <> SPACE(40)
            IF FREEZ_LOC <> MFREEZER
               SKIP
               LOOP
            ENDIF
         ENDIF
         
         IF MLINE > MPAGE_LEN
            IF MLINE <> 99
               EJECT 
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,59 SAY MCOMPANY
            @ 2,1 SAY 'Page'
            @ 2,06 say mpage_no picture '99'
            @ 2,50 SAY '    INVENTORY REPORT  AS OF ' + DTOC(MCUTOFF)
            @ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
            **@ 3,50 SAY '    ESTIMATED STORAGE @ .0125 / LB'
            **@ 5,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK  CASES        UNITS  PUR PRI  PUR+STOR   COST W/STOR'
            @ 5,1 SAY '                                                                                                             CASES        UNITS'
            @ 6,1 SAY '  DATE    LOCATION              LOT #     I #  SUPPLIER             PCODE  PROD SIZE PRODUCT           PACK   LEFT         LEFT  PUR PRI           PURCHASE COST'
            @ 6,01 SAY REPLICATE('_',160)
            MLINE = 8
         ENDIF
         @ MLINE,1 SAY ANIV_DATE
         @ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
         @ MLINE,33 SAY LOT_NBR
         **@ MLINE,42 SAY STR(I_NBR,5)  
         
         @ MLINE,49 SAY SUBSTR(SUPPLIER,1,16)
         @ MLINE,69 SAY PROD_DESC
         @ MLINE,76 SAY PROD_SIZE
         
         SELECT C
         SEEK 'R' + A->PROD_DESC
         IF EOF()       
            MDESC = A->PROD_DESC
         ELSE
            MDESC = SUBSTR(DESC,1,15)
         ENDIF
         @ MLINE,86 SAY SUBSTR(MDESC,1,15)
         SELECT A
         *MCASE_LEFT = 0
         *MVAL_LEFT = 0
         *MLBS_LEFT = 0
         *DO CALC_CUR
         *IF MLBS_LEFT <> 0
         *   IF SUBSTR(BOX_SIZE,1,1) = 'B'                                  
         *      MSTOR_UNIT = ROUND(VAL(SUBSTR(BOX_SIZE,2))*.0125,4)
         *   ELSE
         *      MSTOR_UNIT = .0125
         *   ENDIF
         *   MPRO_PRI = PRI_LB + MSTOR_UNIT                  
         *   MVAL_LEFT = ROUND(MPRO_PRI * MLBS_LEFT,2)
         *ELSE
         *   MPRO_PRI = 0
         *   MVAL_LEFT = 0
         *ENDIF
         
         @ MLINE,104 SAY BOX_SIZE
         @ MLINE,111 SAY CASE_LEFT PICTURE '9999'
         MTOT_CASE = MTOT_CASE + CASE_LEFT
         @ MLINE,118 SAY LBS_LEFT  PICTURE '999,999.99'
         @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
         MVAL1  = PRI_LB * LBS_LEFT
         IF MVAL1 <> 0
            MVAL = INT(MVAL1*100)
            IF (ABS(MVAL1) * 100) - ABS(MVAL) > .49
               IF MVAL1 >= 0
                  MVAL1 = (MVAL + 1) / 100
               ELSE
                  MVAL1 = (MVAL - 1) / 100
               ENDIF
            ELSE
               MVAL1 = MVAL / 100
            ENDIF
         ENDIF
         MVAL_LEFT = MVAL1 
         
         @ MLINE,149 SAY MVAL_LEFT PICTURE '9,999,999.99'
         MTOT_VAL = MTOT_VAL + MVAL_LEFT
         
         *@ MLINE,140 SAY MPRO_PRI   PICTURE '99.9999'
         *IF MLBS_LEFT <> 0
         *   @ MLINE,149 SAY MVAL_LEFT  PICTURE '9,999,999.99'
         *   MTOT_VAL = MTOT_VAL + MVAL_LEFT
         *ENDIF
         MLINE = MLINE + 2
         SKIP
      ENDDO
      
      IF MLINE <> 99     
         MLINE = MLINE + 1
         @ MLINE,1 SAY 'GRAND TOTALS:'
         *@ MLINE,109 SAY MTOT_CASE  PICTURE '999999'
         *@ MLINE,115 SAY MTOT_LBS PICTURE '99,999,999.99'
         @ MLINE,148 SAY MTOT_VAL PICTURE '99,999,999.99'
         *@ MLINE+1,1 SAY ' '
         EJECT
      ENDIF
      
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
      CLOSE DATA
      MRPT_SEL   = ' '
      
   CASE MRPT_SEL = '8'
      CLEAR
      @ 00,00 SAY MCOMPANY
      @ 01,68 SAY DATE()
      @ 01,00 SAY MPROGRAM + ' - PRINT INVENTORY REPORT'
      @ 2,0 to 22,79
      MPROD    = SPACE(6)
      MDIV     = SPACE(2)
      MFREEZER = SPACE(40)
      MI_NBR   = 0         
      MIN_OUT  = '    '
      MSUP_NAME = SPACE(40)
      STORE CTOD('') TO MBEG_DATE, MEND_DATE
      MRPT_PICK = '1'
      *@ 4,3 say ' Select Report Format (#1 or #2): ' GET MRPT_PICK PICTURE '#' VALID(MRPT_PICK = '1' .OR. MRPT_PICK = '2' .OR. MRPT_PICK = ' ')
      *@ 5,3 say ' 1.  All shipments in and all shipments out grouped together'
      *@ 6,3 say ' 2.  By I number, shipments in, shipments out'
      @ 8,3 SAY '         Beginning Activity Date: ' GET MBEG_DATE
      @ 10,3 SAY '            Ending Activity Date: ' GET MEND_DATE
      @ 12,3 SAY '      Select Shipments IN or OUT: ' GET MIN_OUT PICTURE '@!'
      @ 14,3 SAY '         Enter Optional I Number: ' GET MI_NBR PICTURE '#####'
      @ 16,3 SAY '    Enter Optional Division Code: ' GET MDIV PICTURE '@!'
      @ 18,3 SAY '     Enter Optional Product Code: ' GET MPROD  PICTURE '@!'
      @ 20,3 SAY '     Enter Optional Freezer Name: ' GET MFREEZER PICTURE '@!'
      @ 22,3 say '    Enter Optional Supplier Name: ' GET MSUP_NAME PICTURE '@!'
      READ
      IF MRPT_PICK = ' '
         LOOP
      ENDIF
      
      @ 4,3 CLEAR TO 22,78
      
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         LOOP  
      ENDIF
      IF MIN_OUT = '    '
         MIN_OUT = 'OUT '
      ENDIF
      ** IF DATES ARE LEFT BLANK, PICK UP ALL ACTIVITY
      ** BY FORMATTING WITH REAL OLD AND CURRENT BEGIN/END
      IF DTOC(MBEG_DATE) = '  /  /  '
         MBEG_DATE = CTOD('01/01/90')
      ENDIF
      IF DTOC(MEND_DATE) = '  /  /  '
         MEND_DATE = DATE()
      ENDIF
      
      MPAGE_LEN = 44
      MPAGE_NO = 0
      MLINE = 99
      
      @ 21,16 SAY SPACE(34)
      @ 21,16 SAY 'PROCESSING............'
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 12 CPI
      ?? chr(27) + '&k4S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LANDSCAPE MODE
      ?? CHR(27) + '&l1O'
      
      *** LEGAL SIZE PAPER
      ?? CHR(27) + '&l3A'
      
      SELECT E
      DO FOX_USE WITH "&MMASTDBF.DIVISION", .F.
      
      SELECT D 
      DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      SELECT B
      USE INVNTEMP EXCLUSIVE
      DELETE ALL
      PACK
      DO FOX_USE WITH "INVNTEMP", .F.
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNANIV", .F.
      
      IF MFREEZER <> SPACE(40)
         MFREEZER = TRIM(MFREEZER)
      ENDIF
      
      IF MSUP_NAME <> SPACE(40)
         MSUP_NAME = TRIM(MSUP_NAME)
      ENDIF
      
      IF MIN_OUT = 'IN' .OR. MIN_OUT = 'BOTH'
         
         IF YEAR(MBEG_DATE) >= YEAR(ANIV_DATE)
            SEEK STR(YEAR(MBEG_DATE),4)
         ENDIF
         
         ** FIRST GET ALL THE SHIPMENTS INTO INVENTORY THAT
         ** FALL INTO THIS DATE RANGE - THESE COME FROM THE "INVEN" FILE
         DO WHILE .NOT. EOF() .AND. ANIV_DATE < MBEG_DATE
            SKIP
         ENDDO
         DO WHILE .NOT. EOF() .AND. ANIV_DATE <= MEND_DATE
            
            IF LBS = 0 .OR. CASE_CNT = 0
               SKIP
               LOOP
            ENDIF
            
            ** CHECK DIVISION CODE MATCH
            IF MDIV <> SPACE(2)
               IF MDIV <> DIV_CODE
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            IF MSUP_NAME <> SPACE(40)
               IF SUPPLIER <> MSUP_NAME
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK PRODUCT DESCRIPTION MATCH
            IF MPROD <> SPACE(6)
               IF MPROD <> PROD_DESC
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            ** CHECK FREEZER MATCH
            IF MFREEZER <> '  '
               IF TRIM(FREEZ_LOC) <> MFREEZER
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK I NBR MATCH
            IF MI_NBR <> 0
               IF MI_NBR <> I_NBR
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE SALESMAN    WITH A->SALESMAN
            REPLACE PO_NBR      WITH A->PO_NBR
            REPLACE PO_SUFFIX   WITH A->PO_SUFFIX
            REPLACE FREEZ_LOC   WITH A->FREEZ_LOC
            REPLACE I_NBR       WITH A->I_NBR
            REPLACE DIV_CODE    WITH A->DIV_CODE
            REPLACE PROD_DESC   WITH A->PROD_DESC
            REPLACE BOX_SIZE    WITH A->BOX_SIZE
            REPLACE LOT_NBR     WITH A->LOT_NBR
            REPLACE SUPPLIER    WITH A->SUPPLIER
            REPLACE LBS         WITH A->LBS
            REPLACE PRI_LB      WITH A->PRI_LB
            REPLACE CASE_CNT    WITH A->CASE_CNT
            REPLACE VALUE       WITH A->VALUE
            REPLACE ACT_DATE    WITH A->ANIV_DATE
            REPLACE ACT_CODE    WITH 'I'
            UNLOCK
            SELECT A
            SKIP
         ENDDO
      ENDIF
      
      SELECT A
      DO FOX_USE WITH "INVEN INDEX INVNINBR", .F.
      
      SELECT F
      DO FOX_USE WITH "INVN_DTL INDEX DTL_DATE", .F.
      
      *** GET ALL THE OUT ACTIVITY FROM THE DETAIL FILE
      *** FOR THE SPECIFIED TIME FRAME
      
      IF MIN_OUT = 'OUT' .OR. MIN_OUT = 'BOTH'
         IF VAL(SUBSTR(DTOC(MBEG_DATE),7)) >= VAL(SUBSTR(DTOC(ACT_DATE),7))
            SEEK SUBSTR(DTOC(MBEG_DATE),7)
         ENDIF
         ** FIRST GET ALL THE SHIPMENTS OUT OF INVENTORY THAT
         ** FALL INTO THIS DATE RANGE
         DO WHILE .NOT. EOF() .AND. ACT_DATE <  MBEG_DATE
            SKIP
         ENDDO
         DO WHILE .NOT. EOF() .AND. ACT_DATE <= MEND_DATE
            *** IF THIS IS NOT A SHIPMENT RECORD, SKIP IT
            IF ACT_CODE <> 'S'
               SKIP
               LOOP
            ENDIF
            
            IF SHIP_LBS = 0 .OR. SHIP_CASE = 0
               SKIP
               LOOP
            ENDIF
            ** CHECK I NBR MATCH
            IF MI_NBR <> 0
               IF MI_NBR <> I_NBR
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT A
            SEEK STR(F->I_NBR,5)
            ** CHECK PRODUCT DESCRIPTION MATCH
            IF MPROD <> SPACE(6)
               IF MPROD <> PROD_DESC
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK DIVISION CODE MATCH
            IF MDIV <> SPACE(2)
               IF MDIV <> DIV_CODE
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            IF MSUP_NAME <> SPACE(40)
               IF SUPPLIER <> MSUP_NAME
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            ** CHECK FREEZER MATCH
            IF MFREEZER <> '  '
               IF TRIM(FREEZ_LOC) <> MFREEZER
                  SELECT F
                  SKIP
                  LOOP
               ENDIF
            ENDIF
            
            SELECT B
            DO FILELOCK
            APPEND BLANK
            REPLACE FREEZ_LOC   WITH A->FREEZ_LOC
            REPLACE I_NBR       WITH A->I_NBR
            REPLACE DIV_CODE    WITH A->DIV_CODE
            REPLACE PROD_DESC   WITH A->PROD_DESC
            REPLACE BOX_SIZE    WITH A->BOX_SIZE
            REPLACE LOT_NBR     WITH A->LOT_NBR
            REPLACE SUPPLIER    WITH A->SUPPLIER
            REPLACE PRI_LB      WITH A->PRI_LB
            
            *** GET THIS INFO FROM DETAIL RECORD
            REPLACE SALESMAN    WITH F->SALESMAN
            REPLACE PO_NBR      WITH F->PO_NBR
            REPLACE PO_SUFFIX   WITH F->PO_SUFFIX
            REPLACE SHIP_LBS    WITH (F->SHIP_LBS)
            IF F->CUS_PRI <> 0
               REPLACE SHIP_PRI    WITH (F->CUS_PRI)       
            ELSE
               REPLACE SHIP_PRI    WITH A->PRI_LB
            ENDIF
            REPLACE CASE_CNT    WITH (F->SHIP_CASE)
            REPLACE VALUE       WITH (F->SHIP_VAL)
            REPLACE ACT_DATE    WITH F->ACT_DATE
            REPLACE ACT_CODE    WITH 'S'
            UNLOCK
            SELECT F
            SKIP
         ENDDO
      ENDIF
      
      SELECT B
      USE INVNTEMP EXCLUSIVE
      IF MRPT_PICK = '1'
         INDEX ON DIV_CODE + FREEZ_LOC + PROD_DESC + ACT_CODE + STR(YEAR(ACT_DATE),4) + SUBSTR(DTOC(ACT_DATE),1,5) TO INVNTEMP
      ELSE
         INDEX ON DIV_CODE + FREEZ_LOC + PROD_DESC + STR(I_NBR,5) TO INVNTEMP
      ENDIF
      
      DO FOX_USE WITH "INVNTEMP INDEX INVNTEMP", .F.
      DO CASE
      CASE MRPT_PICK = '1'
         **** ZERO OUT GRAND TOTALS ***
         MTOT_LBS = 0
         MTOT_VAL = 0
         MTOT_CAS = 0
         MTOT_NET = 0
         MTOT_SEL = 0
         MTOT_X   = 0
         ***********************************
         SELECT E
         GOTO TOP
         DO WHILE .NOT. EOF()
            MDIV_NAME = DIV_NAME
            MTOT_DLBS = 0
            MTOT_DVAL = 0
            MTOT_DCAS = 0
            MTOT_DNET = 0
            MTOT_DSEL = 0
            MTOT_DX   = 0
            SELECT B
            SEEK E->DIV_CODE
            IF EOF()
               SELECT E
               SKIP
               LOOP
            ENDIF
            IF MLINE <> 99
               MLINE = 89
            ENDIF
            
            DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE
               MSV_FREEZ = FREEZ_LOC
               MTOT_FLBS = 0
               MTOT_FVAL = 0
               MTOT_FCAS = 0
               MTOT_FNET = 0
               MTOT_FSEL = 0
               MTOT_FX   = 0
               DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ
                  MSV_PROD = PROD_DESC
                  MTOT_PLBS = 0
                  MTOT_PVAL = 0
                  MTOT_PCAS = 0
                  MTOT_PNET = 0
                  MTOT_PSEL = 0
                  MTOT_PX   = 0
                  SELECT C
                  SEEK 'R' + MSV_PROD     
                  IF EOF()       
                     MDESC = 'CODE: ' + MSV_PROD
                  ELSE
                     MDESC = SUBSTR(DESC,1,15)
                  ENDIF
                  SELECT B
                  DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ .AND. PROD_DESC = MSV_PROD
                     MSV_ACTCD = ACT_CODE
                     MTOT_ALBS = 0
                     MTOT_AVAL = 0
                     MTOT_ACAS = 0
                     MTOT_ANET = 0
                     MTOT_ASEL = 0
                     MTOT_AX   = 0
                     DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ .AND. PROD_DESC = MSV_PROD .AND. MSV_ACTCD = ACT_CODE
                        *** PRINT THE DETAIL HERE
                        IF MLINE > MPAGE_LEN
                           DO ACT_HED1
                        ENDIF
                        
                        @ MLINE,1 SAY ACT_DATE
                        *@ MLINE,11 SAY SUBSTR(FREEZ_LOC,1,20)
                        @ MLINE,33-22 SAY LOT_NBR
                        **@ MLINE,42-22 SAY STR(I_NBR,5)  
                        @ MLINE,52-22 SAY SALESMAN
                        IF SALESMAN <> '  '
                           @ MLINE,54-22 SAY '-'
                        ENDIF
                        @ MLINE,55-22 SAY PO_NBR
                        IF PO_SUFFIX <> ' '
                           @ MLINE,59-22 SAY '-' + PO_SUFFIX
                        ENDIF
                        @ MLINE,62-22 SAY SUBSTR(SUPPLIER,1,15)
                        IF ACT_CODE = 'I'
                           @ MLINE,79-22 SAY 'IN'
                        ELSE
                           @ MLINE,79-22 SAY 'OUT'     
                        ENDIF
                        @ MLINE,86-22 SAY SUBSTR(MDESC,1,15)
                        @ MLINE,104-22 SAY BOX_SIZE
                        @ MLINE,110-22 SAY CASE_CNT  PICTURE '99999'
                        IF ACT_CODE = 'I'
                           @ MLINE,117-22 SAY LBS       PICTURE '999,999.99'
                           @ MLINE,130-22 SAY PRI_LB    PICTURE '99.9999'
                        ELSE
                           @ MLINE,117-22 SAY SHIP_LBS  PICTURE '999,999.99'
                           @ MLINE,130-22 SAY SHIP_PRI  PICTURE '99.9999'
                        ENDIF
                        MSELL = 0
                        IF ACT_CODE = 'I'
                           @ MLINE,149-22 SAY VALUE     PICTURE '9,999,999.99'
                        ELSE
                           MSELL = ROUND(SHIP_LBS * SHIP_PRI,2)
                           @ MLINE,149-22 SAY MSELL     PICTURE '9,999,999.99'
                        ENDIF
                        IF ACT_CODE <> 'I'
                           MPRI = SHIP_PRI - PRI_LB
                           MNET = ROUND(MPRI * (SHIP_LBS),2)
                           @ MLINE,141 SAY MNET PICTURE '99,999.99'
                           MTOT_ANET = MTOT_ANET + MNET
                           MTOT_ALBS = MTOT_ALBS + SHIP_LBS
                           MTOT_ASEL = MTOT_ASEL + MSELL
                        ELSE
                           MTOT_ALBS = MTOT_ALBS + LBS
                        ENDIF
                        MTOT_AVAL = MTOT_AVAL + VALUE
                        MTOT_ACAS = MTOT_ACAS + CASE_CNT
                        IF SUBSTR(BOX_SIZE,1,1) = 'B'
                           MTOT_AX = MTOT_AX + (VAL(SUBSTR(BOX_SIZE,2)) * CASE_CNT)
                        ELSE
                           IF ACT_CODE <> 'I'
                              MTOT_AX = MTOT_AX + SHIP_LBS
                           ELSE
                              MTOT_AX = MTOT_AX + LBS
                           ENDIF
                        ENDIF
                        MLINE = MLINE + 1
                        SKIP
                     ENDDO
                     
                     *** DO ACTIVITY (INS AND OUTS) TOTALS
                     *IF MSV_ACTCD = 'I'
                     *   MTOT_WORD = ' IN: ' 
                     *ELSE
                     *   MTOT_WORD = ' OUT: ' 
                     *ENDIF
                     *MLINE = MLINE + 1
                     *@ MLINE,5 SAY TRIM(MDESC) + MTOT_WORD 
                     *@ MLINE,5 SAY REPLICATE('_',24)
                     *@ MLINE,109-22 SAY MTOT_ACAS PICTURE '999999'
                     *@ MLINE,115-22 SAY MTOT_ALBS  PICTURE '9,999,999.99'
                     *@ MLINE,149-22 SAY MTOT_AVAL  PICTURE '9,999,999.99'
                     *@ MLINE,138 SAY MTOT_ANET PICTURE '9,999,999.99'
                     *@ MLINE,109-22 SAY REPLICATE('_',63)
                     
                     MTOT_PLBS = MTOT_PLBS + MTOT_ALBS
                     MTOT_PVAL = MTOT_PVAL + MTOT_AVAL
                     MTOT_PCAS = MTOT_PCAS + MTOT_ACAS 
                     MTOT_PNET = MTOT_PNET + MTOT_ANET
                     MTOT_PSEL = MTOT_PSEL + MTOT_ASEL
                     MTOT_PX   = MTOT_PX   + MTOT_AX
                     MLINE = MLINE + 2
                     MTOT_ALBS = 0
                     MTOT_AVAL = 0
                     MTOT_ACAS = 0
                     MTOT_ANET = 0
                     MTOT_ASEL = 0
                     MTOT_AX   = 0
                  ENDDO
                  *** DO PRODUCT TOTALS
                  *** FINISH UP
                  IF MLINE > MPAGE_LEN
                     DO ACT_HED1
                  ENDIF
                  @ MLINE,5 SAY TRIM(MDESC) + ' TOTALS: ' 
                  @ MLINE,5 SAY REPLICATE('_',22)
                  @ MLINE,40 SAY 'LBS= ' + TRANSFORM(MTOT_PX, '99,999,999.9')
                  @ MLINE,109-22 SAY MTOT_PCAS PICTURE '999999'
                  @ MLINE,115-22 SAY MTOT_PLBS  PICTURE '99,999,999.9'
                  
                  IF MIN_OUT = 'IN  '
                     @ MLINE,149-22 SAY MTOT_PVAL  PICTURE '9,999,999.99'
                  ELSE
                     @ MLINE,149-22 SAY MTOT_PSEL  PICTURE '9,999,999.99'
                  ENDIF
                  @ MLINE,138 SAY MTOT_PNET PICTURE '9,999,999.99'
                  @ MLINE,109-22 SAY REPLICATE('_',11)
                  MTOT_FLBS = MTOT_FLBS + MTOT_PLBS
                  MTOT_FVAL = MTOT_FVAL + MTOT_PVAL
                  MTOT_FCAS = MTOT_FCAS + MTOT_PCAS 
                  MTOT_FNET = MTOT_FNET + MTOT_PNET
                  MTOT_FSEL = MTOT_FSEL + MTOT_PSEL
                  MTOT_FX   = MTOT_FX   + MTOT_PX
                  MLINE = MLINE + 3
                  MTOT_PLBS = 0
                  MTOT_PVAL = 0
                  MTOT_PCAS = 0
                  MTOT_PNET = 0
                  MTOT_PSEL = 0
                  MTOT_PX   = 0
               ENDDO
               *** DO FREEZER TOTALS
               IF MLINE > MPAGE_LEN
                  DO ACT_HED1
               ENDIF
               @ MLINE,5 SAY TRIM(MSV_FREEZ) + ' TOTALS: ' 
               @ MLINE,40 SAY 'LBS= ' + TRANSFORM(MTOT_FX, '99,999,999.9')
               @ MLINE,109-22 SAY MTOT_FCAS PICTURE '999999'
               @ MLINE,115-22 SAY MTOT_FLBS  PICTURE '99,999,999.9'
               IF MIN_OUT = 'IN  '
                  @ MLINE,149-22 SAY MTOT_FVAL  PICTURE '9,999,999.99'
               ELSE
                  @ MLINE,149-22 SAY MTOT_FSEL  PICTURE '9,999,999.99'
               ENDIF
               @ MLINE,138 SAY MTOT_FNET PICTURE '9,999,999.99'
               @ MLINE,05 SAY REPLICATE('_',156)
               MTOT_DLBS = MTOT_DLBS + MTOT_FLBS
               MTOT_DVAL = MTOT_DVAL + MTOT_FVAL
               MTOT_DCAS = MTOT_DCAS + MTOT_FCAS 
               MTOT_DNET = MTOT_DNET + MTOT_FNET 
               MTOT_DSEL = MTOT_DSEL + MTOT_FSEL
               MTOT_DX   = MTOT_DX   + MTOT_FX 
               MLINE = MLINE + 3
               MTOT_FLBS = 0
               MTOT_FVAL = 0
               MTOT_FCAS = 0
               MTOT_FNET = 0
               MTOT_FSEL = 0
               MTOT_FX   = 0
            ENDDO
            *** DO DIVISION TOTALS
            IF MLINE > MPAGE_LEN
               DO ACT_HED1
            ENDIF
            
            @ MLINE,5 SAY 'DIV.-' + TRIM(SUBSTR(MDIV_NAME,1,20)) + ' TOTALS: ' 
            @ MLINE,40 SAY 'LBS= ' + TRANSFORM(MTOT_DX, '99,999,999.9')
            @ MLINE,109-22 SAY MTOT_DCAS PICTURE '999999'
            @ MLINE,115-22 SAY MTOT_DLBS  PICTURE '9,999,999.99'
            IF MIN_OUT = 'IN  '
               @ MLINE,149-22 SAY MTOT_DVAL  PICTURE '9,999,999.99'
            ELSE
               @ MLINE,149-22 SAY MTOT_DSEL  PICTURE '9,999,999.99'
            ENDIF
            @ MLINE,138 SAY MTOT_DNET PICTURE '9,999,999.99'
            MLINE = MLINE + 1
            @ MLINE,05 SAY REPLICATE('*',156)
            MTOT_LBS = MTOT_LBS + MTOT_DLBS
            MTOT_VAL = MTOT_VAL + MTOT_DVAL
            MTOT_CAS = MTOT_CAS + MTOT_DCAS 
            MTOT_NET = MTOT_NET + MTOT_DNET
            MTOT_SEL = MTOT_SEL + MTOT_DSEL
            MTOT_X   = MTOT_X   + MTOT_DX
            MLINE = MLINE + 3
            MTOT_DLBS = 0
            MTOT_DVAL = 0
            MTOT_DCAS = 0
            MTOT_DNET = 0
            MTOT_DSEL = 0
            MTOT_DX   = 0
            SELECT E
            SKIP
         ENDDO
      OTHERWISE
         ********************************************
         *** REPORT SELECTION # 2
         *** ALL ACTIVITY GROUPED TOGETHER BY I NBR
         ********************************************
         **** ZERO OUT GRAND TOTALS ***
         MTOT_LBS = 0
         MTOT_VAL = 0
         MTOT_CAS = 0
         MTOT_NET = 0
         ***********************************
         SELECT E
         GOTO TOP
         DO WHILE .NOT. EOF()
            MDIV_NAME = DIV_NAME
            MTOT_DLBS = 0
            MTOT_DVAL = 0
            MTOT_DCAS = 0
            SELECT B
            SEEK E->DIV_CODE
            IF EOF()
               SELECT E
               SKIP
               LOOP
            ENDIF
            IF MLINE <> 99
               MLINE = 89
            ENDIF
            
            DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE
               MSV_FREEZ = FREEZ_LOC
               MTOT_FLBS = 0
               MTOT_FVAL = 0
               MTOT_FCAS = 0
               DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ
                  MSV_PROD = PROD_DESC
                  MTOT_PLBS = 0
                  MTOT_PVAL = 0
                  MTOT_PCAS = 0
                  SELECT C
                  SEEK 'R' + MSV_PROD     
                  IF EOF()       
                     MDESC = 'CODE: ' + MSV_PROD
                  ELSE
                     MDESC = SUBSTR(DESC,1,15)
                  ENDIF
                  SELECT B
                  DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ .AND. PROD_DESC = MSV_PROD
                     MSV_I_NBR = I_NBR
                     MTOT_ILBS = 0
                     MTOT_IVAL = 0
                     MTOT_ICAS = 0
                     DO WHILE .NOT. EOF() .AND. DIV_CODE = E->DIV_CODE .AND. FREEZ_LOC = MSV_FREEZ .AND. PROD_DESC = MSV_PROD .AND. MSV_I_NBR = I_NBR
                        *** PRINT THE DETAIL HERE
                        IF MLINE > MPAGE_LEN
                           DO ACT_HEAD
                        ENDIF
                        
                        @ MLINE,1 SAY ACT_DATE
                        @ MLINE,12 SAY SUBSTR(FREEZ_LOC,1,19)
                        @ MLINE,33 SAY LOT_NBR
                        *@ MLINE,42 SAY STR(I_NBR,5)  
                        @ MLINE,52 SAY SALESMAN
                        IF SALESMAN <> '  '
                           @ MLINE,54 SAY '-'
                        ENDIF
                        @ MLINE,55 SAY PO_NBR
                        IF PO_SUFFIX <> ' '
                           @ MLINE,59 SAY '-' + PO_SUFFIX
                        ENDIF
                        @ MLINE,62 SAY SUBSTR(SUPPLIER,1,15)
                        IF ACT_CODE = 'I'
                           @ MLINE,79 SAY 'IN'
                        ELSE
                           @ MLINE,79 SAY 'OUT'     
                        ENDIF
                        @ MLINE,86 SAY SUBSTR(MDESC,1,15)
                        @ MLINE,104 SAY BOX_SIZE
                        @ MLINE,110 SAY CASE_CNT  PICTURE '99999'
                        @ MLINE,117 SAY LBS       PICTURE '999,999.99'
                        @ MLINE,130 SAY PRI_LB    PICTURE '99.9999'
                        @ MLINE,149 SAY VALUE     PICTURE '9,999,999.99'
                        MTOT_ILBS = MTOT_ILBS + LBS
                        MTOT_IVAL = MTOT_IVAL + VALUE
                        MTOT_ICAS = MTOT_ICAS + CASE_CNT
                        MLINE = MLINE + 1
                        SKIP
                     ENDDO
                     
                     *** DO I NUMBER TOTALS HERE
                     MLINE = MLINE + 1
                     @ MLINE,5 SAY 'I ' + STR(MSV_I_NBR,5) + ' TOTAL: '       
                     @ MLINE,5 SAY REPLICATE('_',24)
                     @ MLINE,109 SAY MTOT_ICAS PICTURE '999999'
                     @ MLINE,115 SAY MTOT_ILBS  PICTURE '9,999,999.99'
                     @ MLINE,149 SAY MTOT_IVAL  PICTURE '9,999,999.99'
                     @ MLINE,109 SAY REPLICATE('_',52)
                     MTOT_PLBS = MTOT_PLBS + MTOT_ILBS
                     MTOT_PVAL = MTOT_PVAL + MTOT_IVAL
                     MTOT_PCAS = MTOT_PCAS + MTOT_ICAS 
                     MLINE = MLINE + 2
                  ENDDO
                  *** DO PRODUCT TOTALS
                  *** FINISH UP
                  IF MLINE > MPAGE_LEN
                     DO ACT_HEAD
                  ENDIF
                  @ MLINE,5 SAY TRIM(MDESC) + ' TOTALS: ' 
                  @ MLINE,5 SAY REPLICATE('_',22)
                  @ MLINE,109 SAY MTOT_PCAS PICTURE '999999'
                  @ MLINE,115 SAY MTOT_PLBS  PICTURE '9,999,999.99'
                  @ MLINE,149 SAY MTOT_PVAL  PICTURE '9,999,999.99'
                  @ MLINE,109 SAY REPLICATE('_',52)
                  MTOT_FLBS = MTOT_FLBS + MTOT_PLBS
                  MTOT_FVAL = MTOT_FVAL + MTOT_PVAL
                  MTOT_FCAS = MTOT_FCAS + MTOT_PCAS 
                  MLINE = MLINE + 3
               ENDDO
               *** DO FREEZER TOTALS
               IF MLINE > MPAGE_LEN
                  DO ACT_HEAD
               ENDIF
               @ MLINE,5 SAY TRIM(MSV_FREEZ) + ' TOTALS: ' 
               @ MLINE,109 SAY MTOT_FCAS PICTURE '999999'
               @ MLINE,115 SAY MTOT_FLBS  PICTURE '9,999,999.99'
               @ MLINE,149 SAY MTOT_FVAL  PICTURE '9,999,999.99'
               @ MLINE,05 SAY REPLICATE('_',156)
               MTOT_DLBS = MTOT_DLBS + MTOT_FLBS
               MTOT_DVAL = MTOT_DVAL + MTOT_FVAL
               MTOT_DCAS = MTOT_DCAS + MTOT_FCAS 
               MLINE = MLINE + 3
            ENDDO
            *** DO DIVISION TOTALS
            IF MLINE > MPAGE_LEN
               DO ACT_HEAD
            ENDIF
            @ MLINE,5 SAY 'DIV.-' + TRIM(MDIV_NAME) + ' TOTALS: ' 
            @ MLINE,109 SAY MTOT_DCAS PICTURE '999999'
            @ MLINE,115 SAY MTOT_DLBS  PICTURE '9,999,999.99'
            @ MLINE,149 SAY MTOT_DVAL  PICTURE '9,999,999.99'
            MLINE = MLINE + 1
            @ MLINE,05 SAY REPLICATE('*',156)
            MTOT_LBS = MTOT_LBS + MTOT_DLBS
            MTOT_VAL = MTOT_VAL + MTOT_DVAL
            MTOT_CAS = MTOT_CAS + MTOT_DCAS 
            MLINE = MLINE + 3
            SELECT E
            SKIP
         ENDDO
      ENDCASE
      IF MLINE <> 99     
         IF MLINE > MPAGE_LEN
            DO ACT_HED1
         ENDIF
         MLINE = MLINE + 1
         @ MLINE,1 SAY 'GRAND TOTALS:'
         @ MLINE,40 SAY 'LBS= ' + TRANSFORM(MTOT_X, '99,999,999.9')
         @ MLINE,109-22 SAY MTOT_CAS  PICTURE '999999'
         @ MLINE,114-22 SAY MTOT_LBS PICTURE '99,999,999.99'
         IF MIN_OUT = 'IN  '
            @ MLINE,148-22 SAY MTOT_VAL  PICTURE '99,999,999.99'
         ELSE
            @ MLINE,148-22 SAY MTOT_SEL  PICTURE '99,999,999.99'
         ENDIF
         @ MLINE,138 SAY MTOT_NET PICTURE '9,999,999.99'
         @ MLINE+1,1 SAY ' '
         IF MIN_OUT = 'OUT'
            MLINE = MLINE + 3
            @ MLINE,1 SAY 'TOTAL PURCHASE $: ' + TRANSFORM(MTOT_VAL, '9,999,999.99')
            @ MLINE+1,1 SAY ' '
         ENDIF
         EJECT
      ENDIF
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      CLOSE DATA
      MRPT_SEL   = ' '
   ENDCASE
ENDDO
RETURN


PROCEDURE ACT_HEAD
IF MLINE <> 99
   EJECT 
ENDIF
MPAGE_NO = MPAGE_NO + 1
@ 1,59 SAY MCOMPANY
@ 2,1 SAY 'Page'
@ 2,06 say mpage_no picture '99'
@ 2,50 SAY 'INVENTORY ACTIVITY BETWEEN ' + DTOC(MBEG_DATE) + ' - ' + DTOC(MEND_DATE)
@ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
@ 4,1 SAY '  DATE     LOCATION             LOT #      I #     PO NBR    SUPPLIER      ACTIVITY  PRODUCT           PACK  CASES      POUNDS     PRICE              $ AMOUNT'
@ 4,01 SAY REPLICATE('_',158)
MLINE = 6
@ MLINE,1 SAY 'DIVISION: ' + MDIV_NAME
@ MLINE,1 SAY REPLICATE('_',42)
MLINE = MLINE + 2
RETURN

PROCEDURE ACT_HED1
IF MLINE <> 99
   EJECT 
ENDIF
MPAGE_NO = MPAGE_NO + 1
@ 1,59 SAY MCOMPANY
@ 2,1 SAY 'Page'
@ 2,06 say mpage_no picture '99'
@ 2,50 SAY 'INVENTORY ACTIVITY BETWEEN ' + DTOC(MBEG_DATE) + ' - ' + DTOC(MEND_DATE)
@ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
@ 4,1 SAY '  DATE    LOT #      I #     PO NBR    SUPPLIER      ACTIVITY  PRODUCT           PACK  CASES       UNITS     PRICE                $ AMOUNT      NET $'
@ 4,01 SAY REPLICATE('_',160)
MLINE = 6
@ MLINE,1 SAY 'DIVISION: ' + MDIV_NAME
@ MLINE,1 SAY REPLICATE('_',42)
MLINE = MLINE + 2
RETURN

PROCEDURE ACT_HD10
IF MLINE <> 99
   EJECT 
ENDIF
MPAGE_NO = MPAGE_NO + 1
@ 1,1 SAY 'Page'
@ 1,06 say mpage_no picture '99'
@ 1,23 SAY MCOMPANY
@ 1,60  SAY DTOC(DATE()) + '  ' + TIME()
@ 2,23 SAY 'DAILY ACTIVITY REPORT FOR: ' + DTOC(MDATE)
MLINE = 4
@ MLINE,1 SAY 'LOT NBR'
@ MLINE,10 SAY 'ACT'
@ MLINE,15 SAY 'PO NBR'
@ MLINE,28 SAY 'QTY'
@ MLINE,36 SAY 'PRODUCT'
*@ MLINE,37 SAY 'POUNDS'
@ MLINE,46 SAY ' PRI/UN'
@ MLINE,61 SAY 'VALUE'
MLINE = 6
RETURN



PROCEDURE ACT_HD1 
IF MLINE <> 99
   EJECT 
ENDIF
MPAGE_NO = MPAGE_NO + 1
@ 1,59 SAY MCOMPANY
@ 2,1 SAY 'Page'
@ 2,06 say mpage_no picture '99'
@ 2,50 SAY 'INVENTORY REPORT BY I NUMBER AS OF: ' + DTOC(MEND_DATE)
@ 2,130 SAY DTOC(DATE()) + '  ' + TIME()
@ 4,1 SAY 'LOT DATE   LOCATION             LOT #      I #               SUPPLIER                PRODUCT           PACK  CASES      POUNDS     PRICE                        '
@ 4,01 SAY REPLICATE('_',145)
MLINE = 6
RETURN


PROCEDURE CALC_CUR

SELECT A
MVAL_LEFT  = VALUE
MLBS_LEFT  = LBS
MCASE_LEFT = CASE_CNT
MTOT_COST = 0    
MTOT_PRO  = 0
MWORK_COST = 0
SELECT B
DO FOX_USE WITH "INVN_DTL INDEX IDTL_DTL, INVN_PO, INVNDISP, DTL_DATE, INVN_DTL, DTL_LOT", .F.
SET ORDER TO 6
*SEEK STR(A->I_NBR,5)
SEEK A->FREEZ_LOC + A->LOT_NBR
DO WHILE .NOT. EOF() .AND. A->FREEZ_LOC = FREEZ_LOC .AND. A->LOT_NBR = LOT_NBR
   
   **DO WHILE .NOT. EOF() .AND. A->I_NBR = I_NBR
   DO CASE    
   CASE ACT_CODE = 'C'
      MTOT_COST = MTOT_COST + COST_AMT
      MWORK_COST = MWORK_COST + COST_AMT
   CASE ACT_CODE = 'S'
      MTHIS_COST =  ROUND(MWORK_COST/MLBS_LEFT,4) * SHIP_LBS
      MLBS_LEFT  = MLBS_LEFT  - SHIP_LBS
      MVAL_LEFT  = MVAL_LEFT  - SHIP_VAL               
      MCASE_LEFT = MCASE_LEFT - SHIP_CASE
      MTOT_PRO  = MTOT_PRO + MTHIS_COST
      MWORK_COST = MWORK_COST - MTHIS_COST
   ENDCASE
   SKIP
ENDDO
MVAL_LEFT = MVAL_LEFT + ( MTOT_COST - MTOT_PRO)
SELECT A
RETURN

PROCEDURE CALCCUR2
MVAL_LEFT  = MVALUE
MLBS_LEFT  = MLBS
MCASE_LEFT = MCASE_CNT
MTOT_COST = 0    
MTOT_PRO  = 0
MWORK_COST = 0
SELECT B
DO FOX_USE WITH "INVN_DTL INDEX IDTL_DTL, INVN_PO, INVNDISP, DTL_DATE, INVN_DTL, DTL_LOT", .F.
SET ORDER TO 6

*SEEK STR(A->I_NBR,5)
SEEK A->FREEZ_LOC + A->LOT_NBR
DO WHILE .NOT. EOF() .AND. A->FREEZ_LOC = FREEZ_LOC .AND. A->LOT_NBR = LOT_NBR
   ***DO WHILE .NOT. EOF() .AND. A->I_NBR = I_NBR
   DO CASE    
   CASE ACT_CODE = 'C'
      MTOT_COST = MTOT_COST + COST_AMT
      MWORK_COST = MWORK_COST + COST_AMT
   CASE ACT_CODE = 'S'
      MTHIS_COST =  ROUND(MWORK_COST/MLBS_LEFT,4) * SHIP_LBS
      MLBS_LEFT  = MLBS_LEFT  - SHIP_LBS
      MVAL_LEFT  = MVAL_LEFT  - SHIP_VAL               
      MCASE_LEFT = MCASE_LEFT - SHIP_CASE
      MTOT_PRO  = MTOT_PRO + MTHIS_COST
      MWORK_COST = MWORK_COST - MTHIS_COST
   ENDCASE
   SKIP
ENDDO
MVAL_LEFT = MVAL_LEFT + ( MTOT_COST - MTOT_PRO)
SELECT A
RETURN


********************************************
**   LOT COSTS                            **
********************************************

PROCEDURE LOT_COST
SELECT C
DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.

SELECT B
DO FOX_USE WITH "INVN_DTL INDEX IDTL_DTL, INVN_PO, INVNDISP, DTL_DATE, INVN_DTL, DTL_LOT", .F.
SELECT A
DO FOX_USE WITH "INVEN INDEX INVNLOT, INVNPO, INVNLOC, INVNSOLD, INVNINBR, INVNANIV", .F.

MMORE = .T.
MINIT_NM = .T.
DO WHILE MMORE
   
   MLOT_NBR    = SPACE(10)
   MI_NBR      = 0          
   MFREEZ_LOC  = SPACE(32)
   MACT_DATE   = CTOD(' ')
   MACT_CODE   = 'C'
   MCOST_AMT   = 0
   MCOST_CODE  = ' ' 
   MPAYEE      = SPACE(32)
   MACTION = 2    
   DO WHILE MACTION = 2
      
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - SELECT LOT'     
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      @  5, 5 SAY 'Enter the following fields:'
      @  8, 5 SAY '     Lot Nbr:'
      @  8,19 GET MLOT_NBR PICTURE '@!'
      @ 10,5  SAY '(OR)   I Nbr: '
      @ 10,19 GET MI_NBR   PICTURE '#####'
      @ 13,5  SAY '   Cost Date:'
      @ 13,19 GET MACT_DATE 
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
      
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      
      
      IF VAL(MLOT_NBR) <> 0 .AND. MI_NBR <> 0   
         IF DTOC(MACT_DATE) = '  /  /  '
            @ 23,0 CLEAR
            STORE ' ' TO MWAIT   
            @ 24,01 SAY 'INVOICE DATE NOT ENTERED - PRESS RETURN TO REENTER  ' GET MWAIT 
            READ
            @ 24,0 CLEAR
            MACTION = 2
            LOOP
         ENDIF
      ENDIF
      READ               
   ENDDO
   IF MACTION = 3                          
      MMORE = .F.
      LOOP
   ENDIF 
   SELECT A
   DO CASE
   CASE MLOT_NBR <> SPACE(10)
      SELECT A
      SET ORDER TO 1
      SEEK MLOT_NBR
      STORE MLOT_NBR TO SRCH_ARG
      IF EOF()                
         @ 23,0 CLEAR
         STORE 'Y' TO MYES_NO
         @ 24,05 SAY 'LOT NBR NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' get MYES_NO PICTURE '@!'
         READ
         LOOP
      ELSE               
         STORE RECNO() TO MFST_REC
         IF LOT_NBR = SRCH_ARG
            MADD = .F.
            MFOUND = .F.
            DO MULTILOT 
            DO CASE 
            CASE MFOUND
               DO STORLOT
            OTHERWISE 
               LOOP 
            ENDCASE
         ELSE
            GOTO MFST_REC
            DO STORLOT
         ENDIF
      ENDIF
   CASE MI_NBR <> 0
      SET ORDER TO 5
      SEEK STR(MI_NBR,5)
      IF EOF() 
         @ 23,0 CLEAR
         STORE 'Y' TO MYES_NO
         @ 24,05 SAY 'I NBR NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' get MYES_NO PICTURE '@!'
         READ
         LOOP              
      ELSE               
         DO STORLOT
      ENDIF
   ENDCASE
   SELECT B
   SEEK STR(MI_NBR,5)
   IF EOF()
      @ 23,0 CLEAR
      STORE ' ' TO MYES_NO
      @ 24,05 SAY 'COST NOT ON FILE - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
      READ
      IF MYES_NO = 'Y'
         DO FILELOCK
         APPEND BLANK
         REPLACE LOT_NBR  WITH MLOT_NBR
         REPLACE I_NBR    WITH MI_NBR
         REPLACE ACT_DATE WITH MACT_DATE
         REPLACE ACT_CODE WITH MACT_CODE
         UNLOCK
      ELSE
         LOOP              
      ENDIF
   ELSE 
      STORE RECNO() TO MFST_REC
      MADD = .F.
      MFOUND = .F.
      DO MULTICST 
      DO CASE 
      CASE MADD
         DO FILELOCK
         APPEND BLANK
         REPLACE LOT_NBR  WITH MLOT_NBR
         REPLACE I_NBR    WITH MI_NBR
         REPLACE ACT_DATE WITH MACT_DATE
         REPLACE ACT_CODE WITH MACT_CODE
         UNLOCK
      CASE MFOUND
         DO STORCOST
      OTHERWISE 
         LOOP 
      ENDCASE
   ENDIF
   
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - VIEW/UPDATE COST INFORMATION'
   DO TEXTCOST
   MACTION = 2
   DO WHILE MACTION = 2
      DO GETCOST
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Cancel'                                     
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MACTION = 3
      LOOP
   ENDIF
   
   DO REPLCOST
ENDDO
RETURN

PROCEDURE STORCOST
MCOST_AMT   = COST_AMT
MCOST_CODE  = COST_CODE
MPAYEE      = PAYEE    
MACT_DATE   = ACT_DATE
RETURN

PROCEDURE REPLCOST
DO RECLOCK
REPLACE COST_AMT   WITH MCOST_AMT
REPLACE COST_CODE  WITH MCOST_CODE
REPLACE PAYEE      WITH MPAYEE    
UNLOCK
SELECT A
MVAL_LEFT  = VALUE
MLBS_LEFT  = LBS
MCASE_LEFT = CASE_CNT
MTOT_COST = 0    
MTOT_PRO  = 0
MWORK_COST = 0

DO CALC_CUR

IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
   MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
ELSE
   MPRO_PRI = 0
   MVAL_LEFT = 0
ENDIF
DO RECLOCK
REPLACE VAL_LEFT  WITH MVAL_LEFT
REPLACE CASE_LEFT WITH MCASE_LEFT
REPLACE PRO_PRI   WITH MPRO_PRI
REPLACE LBS_LEFT  WITH MLBS_LEFT 
IF LBS_LEFT = 0 .OR. CASE_LEFT = 0
   REPLACE SOLD_FLG WITH 'Y'
ELSE
   REPLACE SOLD_FLG WITH ' '
ENDIF
UNLOCK
SELECT B
RETURN

PROCEDURE TEXTCOST
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 22,79
@ 05,01 SAY '       LOT #:' 
@ 05,25 SAY 'FREEZER:'
@ 06,01 SAY '         I #:'  
@ 08,01 SAY 'INVOICE DATE:'
@ 10,01 SAY '       PAYEE:'
@ 12,01 SAY '    $ AMOUNT:'
@ 14,01 SAY '   COST CODE:'

RETURN


PROCEDURE GETCOST
@ 05,15 GET MLOT_NBR   PICTURE '@!'
@ 05,34 GET MFREEZ_LOC PICTURE '@!'
@ 06,15 SAY MI_NBR     PICTURE '#####'
@ 08,15 GET MACT_DATE 
CLEAR GETS
@ 10,15 GET MPAYEE     PICTURE '@!'
@ 12,15 GET MCOST_AMT  PICTURE '999,999.99'
@ 14,15 GET MCOST_CODE PICTURE '@!'

RETURN

PROCEDURE MULTICST
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - MATCH SELECT'
@ 3,0 TO 21,79
@  5, 2 SAY "COSTS ON FILE FOR THIS LOT.  PLEASE SELECT ACTION."
@ 6,5 say 'COST DATE   CODE    PAYEE'
MSEQ_NUM = 0
STORE 0 TO MSEQ_NUM, MSEQ_LST
STORE MFST_REC TO MLST_REC
GOTO MFST_REC

MMULT = .T.
DO WHILE MMULT
   
   MLINE = 7
   STORE RECNO() TO MTOP_REC
   STORE MSEQ_NUM + 1 TO MTOP_SEQ
   STORE .F. TO MORE_FLG
   DO WHILE .NOT. EOF() .AND. I_NBR = MI_NBR .AND. ACT_CODE = 'C'
      MSEQ_NUM = MSEQ_NUM + 1
      IF MSEQ_NUM > MSEQ_LST
         STORE MSEQ_NUM TO MSEQ_LST
         STORE RECNO() TO MLST_REC
      ENDIF
      @ MLINE, 1 SAY STR(MSEQ_NUM,2) + '.'
      @ MLINE,5  SAY ACT_DATE
      @ MLINE,19 SAY COST_CODE
      @ MLINE,25 SAY PAYEE
      @ MLINE,62 SAY COST_AMT PICTURE '999,999.99'
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
   IF .NOT. EOF() .AND. I_NBR = MI_NBR .AND. ACT_CODE = 'C'  
      @ MLINE,59 SAY 'More...'
      MORE_FLG = .T.
   ENDIF
   
   STORE 0 TO MSEL_NUM
   @ 22,01 SAY 'Selection Number: '
   @ 22,19 GET MSEL_NUM PICTURE '##' RANGE 0,MSEQ_LST
   MACTION = 1
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add Cost   5.Cancel'
   
   READ
   
   IF MSEL_NUM <> 0
      STORE 1 TO MSEQ_NUM
      GOTO MFST_REC
      DO WHILE MSEQ_NUM <> MSEL_NUM
         SKIP
         STORE MSEQ_NUM + 1 TO MSEQ_NUM
      ENDDO     
      MFOUND = .T.
      MMULT = .F.
      LOOP 
   ENDIF
   
   MACTION = 1
   @ 24,01 SAY 'Action: '
   @ 24,13 SAY '1.Next Pg.  2.Previous Pg.  3.First Pg.  4.Add Cost   5.Cancel'
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
      MADD = .T. 
      MMULT = .F.
      
   CASE MACTION = 5
      MMULT = .F.
      
   ENDCASE
   
ENDDO
RETURN

********************************************
**   LOT SHIPMENTS                        **
********************************************

PROCEDURE LOT_SHIP
SELECT C
DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.

MMORE = .T.
MINIT_NM = .T.
DO WHILE MMORE
   SELECT B
   DO FOX_USE WITH "INVN_DTL INDEX INVN_PO, IDTL_DTL, INVNDISP, DTL_DATE, INVN_DTL, DTL_LOT", .F.
   SELECT A
   DO FOX_USE WITH "INVEN INDEX INVNLOT, INVNPO, INVNLOC, INVNSOLD, INVNINBR, INVNANIV", .F.
   
   
   MLOT_NBR    = SPACE(10)
   MI_NBR      = 0         
   MSALESMAN   = SPACE(2)
   MPO_NBR     = SPACE(4)
   MPO_SUFFIX  = ' '
   MFREEZ_LOC  = SPACE(32)
   MACT_DATE   = CTOD(' ')
   MACT_CODE   = 'S'
   MSHIP_NAME  = SPACE(32)
   MSHIP_LOC   = SPACE(32)
   MSHIP_LBS   = 0
   MSHIP_CASE  = 0   
   MSHIP_PRI   = 0        
   MSHIP_VAL   = 0
   MCUS_PRI    = 0
   
   MACTION = 2    
   DO WHILE MACTION = 2
      
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - SELECT LOT'     
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      @  5, 5 SAY 'Enter the following fields:'
      @  8, 5 SAY '     Lot Nbr:'
      @  8,19 GET MLOT_NBR PICTURE '@!'
      @  10,5 SAY '(OR)   I Nbr:'
      @ 10,19 GET MI_NBR PICTURE '#####'
      @ 13,2  SAY 'Shipment PO Nbr:   -    - '
      @ 13,19 GET MSALESMAN PICTURE '##'
      @ 13,22 GET MPO_NBR PICTURE '####'
      @ 13,27 GET MPO_SUFFIX PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
      
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      IF (MLOT_NBR <> SPACE(10) .OR. MI_NBR <> 0) .AND. MPO_NBR = SPACE(4)
         @ 24,0 CLEAR
         STORE ' ' TO MWAIT   
         @ 24,01 SAY 'PO NUMBER NOT ENTERED - PRESS RETURN TO REENTER  ' GET MWAIT 
         READ
         @ 24,0 CLEAR
         MACTION = 2
         LOOP
      ENDIF
      READ               
   ENDDO
   IF MACTION = 3 .OR. (MLOT_NBR = SPACE(10) .AND. MI_NBR = 0)
      MMORE = .F.
      LOOP
   ENDIF 
   DO CASE
   CASE MLOT_NBR <> SPACE(10)
      SELECT A
      SET ORDER TO 1
      STORE MLOT_NBR TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF()                 
         @ 24,0 CLEAR
         STORE 'Y' TO MYES_NO
         @ 24,05 SAY 'LOT NBR NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' get MYES_NO PICTURE '@!'
         READ
         LOOP              
      ELSE               
         STORE RECNO() TO MFST_REC
         SKIP
         IF LOT_NBR = SRCH_ARG
            MADD = .F.
            MFOUND = .F.
            DO MULTILOT 
            DO CASE 
            CASE MFOUND
               **DO STORLOT 
               MLOT_NBR    = LOT_NBR       
               MI_NBR      = I_NBR
               MFREEZ_LOC  = FREEZ_LOC
            OTHERWISE 
               LOOP 
            ENDCASE
         ELSE
            GOTO MFST_REC
            MADD = .F.
            MFOUND = .T.
            MLOT_NBR    = LOT_NBR       
            MI_NBR      = I_NBR
            MFREEZ_LOC  = FREEZ_LOC
         ENDIF
      ENDIF
   OTHERWISE        
      SELECT A
      SET ORDER TO 5
      SEEK STR(MI_NBR,5)
      IF EOF()                 
         @ 24,0 CLEAR
         STORE 'Y' TO MYES_NO
         @ 24,05 SAY 'I NBR NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' get MYES_NO PICTURE '@!'
         READ
         LOOP              
      ELSE               
         MADD = .F.
         MFOUND = .T.
         MLOT_NBR    = LOT_NBR       
         MI_NBR      = I_NBR
         MFREEZ_LOC  = FREEZ_LOC
      ENDIF
      
   ENDCASE
   SELECT B
   
   SEEK STR(MI_NBR,5) + MSALESMAN + MPO_NBR + MPO_SUFFIX
   IF .NOT. EOF()
      DO STORSHIP
   ELSE
      @ 24,0 CLEAR
      STORE ' ' TO MYES_NO
      @ 24,05 SAY 'SHIPMENT NOT ON FILE - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!' VALID (MYES_NO = 'Y' .OR. MYES_NO = 'N')
      READ
      IF MYES_NO = 'Y'
         DO FILELOCK
         APPEND BLANK
         REPLACE LOT_NBR  WITH MLOT_NBR
         REPLACE I_NBR    WITH MI_NBR
         REPLACE SALESMAN WITH MSALESMAN
         REPLACE PO_NBR   WITH MPO_NBR  
         REPLACE PO_SUFFIX WITH MPO_SUFFIX
         REPLACE SYS_DATE  WITH DATE()
         UNLOCK
      ELSE
         LOOP              
      ENDIF
   ENDIF
   CLEAR 
   @  1,0  SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - VIEW/UPDATE SHIPMENT INFORMATION'
   DO TEXTSHIP
   MACTION = 2
   DO WHILE MACTION = 2
      DO GETSHIP
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Cancel'                                     
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MACTION = 3
      LOOP
   ENDIF
   
   DO REPLSHIP
ENDDO
RETURN

PROCEDURE STORSHIP
MSHIP_NAME = SHIP_NAME
MACT_DATE  = ACT_DATE
MSHIP_LOC  = SHIP_LOC
MSHIP_LBS  = SHIP_LBS
MSHIP_CASE = SHIP_CASE
MSHIP_PRI  = SHIP_PRI
MSHIP_VAL  = SHIP_VAL
MCUS_PRI   = CUS_PRI
RETURN

PROCEDURE REPLSHIP
DO RECLOCK
REPLACE FREEZ_LOC WITH MFREEZ_LOC
IF I_NBR = 0
   REPLACE I_NBR     WITH MI_NBR
ENDIF
REPLACE SHIP_NAME WITH MSHIP_NAME
REPLACE SHIP_LOC  WITH MSHIP_LOC
REPLACE SHIP_LBS  WITH MSHIP_LBS
REPLACE SHIP_CASE WITH MSHIP_CASE
REPLACE SHIP_PRI  WITH MSHIP_PRI
REPLACE SHIP_VAL  WITH MSHIP_VAL
REPLACE ACT_CODE  WITH MACT_CODE
IF MACT_CODE = 'S'
   REPLACE ACTIVITY WITH 'OUT'
ELSE
   REPLACE ACTIVITY WITH 'IN '
ENDIF
REPLACE ACT_DATE  WITH MACT_DATE
REPLACE CUS_PRI   WITH MCUS_PRI
UNLOCK
SELECT A
MVAL_LEFT  = VALUE
MLBS_LEFT  = LBS
MCASE_LEFT = CASE_CNT
MTOT_COST = 0    
MTOT_PRO  = 0
MWORK_COST = 0
MPRO_PRI   = 0
DO CALC_CUR

IF MVAL_LEFT <> 0 .AND. MLBS_LEFT <> 0
   MPRO_PRI = ROUND(MVAL_LEFT/MLBS_LEFT,4)
ELSE
   MPRO_PRI = 0
   MVAL_LEFT = 0
ENDIF
DO RECLOCK
REPLACE VAL_LEFT  WITH MVAL_LEFT
REPLACE CASE_LEFT WITH MCASE_LEFT
REPLACE PRO_PRI   WITH MPRO_PRI
REPLACE LBS_LEFT  WITH MLBS_LEFT 
IF LBS_LEFT = 0 .OR. CASE_LEFT = 0
   REPLACE SOLD_FLG WITH 'Y'
ELSE
   REPLACE SOLD_FLG WITH ' '
ENDIF
UNLOCK
SELECT B
RETURN

PROCEDURE TEXTSHIP
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 22,79
@ 05,01 SAY '       LOT #:' 
@ 05,25 SAY 'FREEZER:'
@ 06,01 SAY '         I #:'  
@ 08,01 SAY '        PO #:   -    -'
@ 10,01 SAY '   SHIP DATE:'
@ 12,01 SAY '  SHIPPED TO:'
@ 13,01 SAY ' TO LOCATION:'

@ 15,01 SAY '    SHIP CASES:'
@ 16,01 SAY '    SHIP UNITS:'
@ 17,01 SAY ' SHIP PRI/UNIT:'
@ 18,01 SAY '  TOTAL $ SHIP:'    
@ 20,01 SAY 'CUSTOMER PRICE:'  
RETURN


PROCEDURE GETSHIP 
@ 05,15 GET MLOT_NBR   PICTURE '@!'
@ 05,34 GET MFREEZ_LOC PICTURE '@!'
@ 06,15 SAY MI_NBR     PICTURE '#####'
@ 08,15 GET MSALESMAN 
@ 08,18 GET MPO_NBR
@ 08,23 GET MPO_SUFFIX PICTURE '@!'
CLEAR GETS
@ 10,15 GET MACT_DATE
@ 12,15 GET MSHIP_NAME PICTURE '@!'
@ 13,15 GET MSHIP_LOC  PICTURE '@!'
@ 15,17 GET MSHIP_CASE PICTURE '####'
@ 16,17 GET MSHIP_LBS  PICTURE '###,###.##'
@ 17,17 GET MSHIP_PRI  PICTURE '##.####'
@ 18,17 GET MSHIP_VAL  PICTURE '###,###.##'
@ 20,17 GET MCUS_PRI   PICTURE '##.####'
RETURN

PROCEDURE IVIEWCHG
****************************
**** SELECT ONE TO VIEW ****
****************************
SELECT C
DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
SELECT A
DO FOX_USE WITH "INVEN INDEX INVNLOT, INVNPO, INVNLOC, INVNSOLD, INVNINBR, INVNANIV", .F.

MMORE = .T.
MINIT_NM = .T.
DO WHILE MMORE
   
   IF MINIT_NM
      MLOT_NBR    = SPACE(10)
      MFREEZ_LOC  = SPACE(32)
      MSALESMAN   = SPACE(2)
      MPO_NBR     = SPACE(4)
      MPO_SUFFIX  = SPACE(1)
      MI_NBR      = 0        
   ENDIF
   
   MANIV_DATE  = CTOD(' ')
   MSUPPLIER   = SPACE(40)
   MPAID_DATE  = CTOD(' ')
   MPROD_DESC  = SPACE(6)
   MPROD_SIZE  = SPACE(10)
   MBOX_SIZE   = SPACE(4)
   MLBS        = 0        
   MCASE_CNT   = 0        
   MPRI_LB     = 0
   MPRO_PRI    = 0
   MVALUE      = 0
   MLBS_LEFT   = 0        
   MCASE_LEFT  = 0
   MVAL_LEFT   = 0
   MPAK_YR     = 0
   MPAK_DAY    = 0
   MNOTE       = SPACE(72)
   MLOT_FD = .F.
   MPROD_DISP  = SPACE(25)
   MACTION = 2    
   DO WHILE MACTION = 2
      SELECT A
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - SELECT LOT'
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      @  5, 5 SAY 'Enter one of the following search fields:'
      @  8, 5 SAY 'Lot Nbr:'
      @ 11, 5 SAY '  I Nbr:'
      @ 14, 5 say 'Freezer:'
      @ 17, 5 say ' PO Nbr:   -    -' 
      @  8,14 GET MLOT_NBR PICTURE '@!'
      @ 11,14 GET MI_NBR   PICTURE '#####'
      @ 14,14 GET MFREEZ_LOC PICTURE '@!'
      @ 17,14 GET MSALESMAN PICTURE '@!'
      @ 17,17 GET MPO_NBR PICTURE '####'
      @ 17,22 GET MPO_SUFFIX PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MACTION = 3 .OR. (MLOT_NBR = SPACE(10) .AND. MFREEZ_LOC = SPACE(4) .AND. MPO_NBR = SPACE(4) .AND. MI_NBR = 0)
      MMORE = .F.
      LOOP
   ENDIF 
   SELECT A
   DO FOX_USE WITH "INVEN INDEX INVNLOT, INVNPO, INVNLOC, INVNSOLD, INVNINBR, INVNANIV", .F.
   
   DO CASE
   CASE MLOT_NBR <> SPACE(10)
      SELECT A
      SET ORDER TO 1
      SEEK MLOT_NBR
      STORE TRIM(MLOT_NBR) TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF()                     
         DO FOX_USE WITH "HINVEN INDEX HINVNLOC, HINVSOLD", .T.
         INDEX ON LOT_NBR TO HINVNTMP
         DO FOX_USE WITH "HINVEN INDEX HINVNTMP", .F.
         SEEK SRCH_ARG
         IF EOF()
            @ 23,0 CLEAR
            STORE ' ' TO MWAIT   
            @ 24,05 SAY 'LOT NBR NOT ON FILE - PRESS RETURN TO REENTER '  GET MWAIT              
            READ
            MINIT_NM = .F.              
            LOOP
         ELSE
            STORE RECNO() TO MFST_REC
            SKIP
            IF MLOT_NBR = LOT_NBR
               MADD = .F.
               MFOUND = .F.
               DO MULTILOT 
            ELSE
               MADD = .F.
               MFOUND = .T.
               GOTO MFST_REC
            ENDIF
            DO CASE
            CASE MADD
               @ 23,0 CLEAR
               STORE ' ' TO MWAIT   
               @ 24,05 SAY 'CANNOT ADD LOT - PRESS RETURN TO REENTER '  GET MWAIT              
               READ
               MINIT_NM = .F.              
               LOOP
            CASE MFOUND
               DO STORLOT
               SELECT C
               SEEK 'R' + MPROD_DESC
               MPROD_DISP = DESC
               SELECT A
            OTHERWISE 
               MINIT_NM = .T.
               LOOP 
            ENDCASE
         ENDIF
      ELSE
         STORE RECNO() TO MFST_REC
         SKIP
         IF MLOT_NBR = LOT_NBR
            MADD = .F.
            MFOUND = .F.
            DO MULTILOT 
         ELSE
            MADD = .F.
            MFOUND = .T.
            GOTO MFST_REC
         ENDIF
         DO CASE
         CASE MADD
            @ 23,0 CLEAR
            STORE ' ' TO MWAIT   
            @ 24,05 SAY 'CANNOT ADD LOT - PRESS RETURN TO REENTER '  GET MWAIT              
            READ
            MINIT_NM = .F.              
            LOOP
         CASE MFOUND
            DO STORLOT
            SELECT C
            SEEK 'R' + MPROD_DESC
            MPROD_DISP = DESC
            SELECT A
         OTHERWISE 
            MINIT_NM = .T.
            LOOP 
         ENDCASE
      ENDIF
      
   CASE MFREEZ_LOC <> SPACE(32)
      SET ORDER TO 3
      STORE TRIM(MFREEZ_LOC) TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF() .OR. DELETED()
         @ 23,0 CLEAR
         STORE ' ' TO MWAIT  
         @ 24,05 SAY 'NO LOTS ON FILE FOR THIS FREEZER - PRESS RETURN TO REENTER  ' GET MWAIT PICTURE '@!'
         READ
         MINIT_NM = .F.              
         LOOP
      ELSE               
         STORE RECNO() TO MFST_REC
         SKIP
         IF FREEZ_LOC = SRCH_ARG
            GOTO MFST_REC
            MADD = .F.
            MFOUND = .F.
            DO MULTIFRZ  
            DO CASE 
            CASE MADD
               @ 23,0 CLEAR
               STORE ' ' TO MWAIT   
               @ 24,05 SAY 'CANNOT ADD LOT - PRESS RETURN TO REENTER '  GET MWAIT              
               READ
               MINIT_NM = .F.              
               LOOP
            CASE MFOUND
               DO STORLOT
               SELECT C
               SEEK 'R' + MPROD_DESC
               MPROD_DISP = DESC
               SELECT A
            OTHERWISE 
               MINIT_NM = .T.
               LOOP 
            ENDCASE
         ELSE
            GOTO MFST_REC
            DO STORLOT
            SELECT C
            SEEK 'R' + MPROD_DESC
            MPROD_DISP = DESC
            SELECT A
         ENDIF
      ENDIF
      
   CASE MPO_NBR <> SPACE(4)
      SET ORDER TO 2
      STORE MSALESMAN+MPO_NBR+MPO_SUFFIX TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF() .OR. DELETED()
         @ 23,0 CLEAR
         STORE ' ' TO MYES_NO
         MAIT = ' '
         @ 24,05 SAY 'PO NBR NOT ON FILE - PRESS RETURN TO REENTER  ' GET MWAIT  PICTURE '@!'
         READ
         MINIT_NM = .F.              
         LOOP
      ELSE               
         STORE RECNO() TO MFST_REC
         MADD = .F.
         MFOUND = .F.
         DO MULTIPO  
         DO CASE 
         CASE MADD
            @ 23,0 CLEAR
            STORE ' ' TO MWAIT  
            @ 24,05 SAY 'CANNOT ADD LOT FROM THIS FUNCTION - PRESS RETURN TO REENTER  ' GET MWAIT  PICTURE '@!'
            READ
            MINIT_NM = .F.              
            LOOP
         CASE MFOUND
            DO STORLOT
            SELECT C
            SEEK 'R' + MPROD_DESC
            MPROD_DISP = DESC
            SELECT A
         OTHERWISE 
            MINIT_NM = .T.
            LOOP 
         ENDCASE
      ENDIF
      
   CASE MI_NBR <> 0       
      SET ORDER TO 5
      STORE STR(MI_NBR,5) TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF()                 
         @ 23,0 CLEAR
         MWAIT = ' '
         @ 24,05 SAY 'I NBR NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT 
         READ
         MINIT_NM = .F.              
         LOOP
      ELSE               
         DO STORLOT
         SELECT C
         SEEK 'R' + MPROD_DESC
         MPROD_DISP = DESC
         SELECT A
      ENDIF
      
   ENDCASE
   
   CLEAR
   @ 0,0 SAY MCOMPANY + ' INVENTORY'
   @ 7,0 TO 7,79
   @ 9,0 TO 9,79
   *@ 15,0 TO 15,79
   @ 21,0 TO 21,79
   @ 1,0 TO 25,79
   @ 2,1 SAY '   Lot Nbr:               |    Freezer:'
   @ 3,1 SAY '    PO Nbr:               |   Supplier:'
   @ 4,1 SAY '     I Nbr:               |  Prod Code:         Desc:'
   @ 5,1 SAY '   Date In:               |   Box Size:         ProdSz:            PK:    /  '
   @ 6,1 SAY 'Note'
   @ 8,1 SAY 'In:      Units             Cases         Pr/Un           Value'
   @ 10,1 SAY 'Sales Po #   Ship Dt  Case  Units Customer  Pri/Un     Value Pro/Cst Tot Cost'  
   *@ 10,1 SAY 'COST:Date    Cases     Pounds  Reason      Payee           Pr/Un  Total Cost'
   @ 11,1 SAY ' 1'
   @ 12,1 SAY ' 2'
   @ 13,1 SAY ' 3'
   @ 14,1 SAY ' 4'
   @ 15,1 SAY ' 5'
   @ 16,1 SAY ' 6'
   @ 17,1 SAY ' 7'
   @ 18,1 SAY ' 8'
   @ 19,1 SAY ' 9'
   @ 20,1 SAY '10'
   @ 22,60 SAY 'More Ships'
   
   @ 22,1 SAY 'Current Units            Cases        Value'            
   @ 23,1 say ' Remain'
   @ 23,60 SAY 'Action: 1  1. Cont'
   @ 2,13 SAY MLOT_NBR                
   @ 2,41 SAY MFREEZ_LOC
   IF MSALESMAN <> SPACE(2)
      @ 3,13 SAY MSALESMAN + '-'
   ENDIF
   @ 3,16 SAY MPO_NBR
   IF MPO_SUFFIX <> ' '
      @ 3,20 SAY '-' + MPO_SUFFIX
   ENDIF
   @ 3,41 SAY SUBSTR(MSUPPLIER,1,32)
   @ 4,13 SAY MI_NBR PICTURE '99999'
   @ 4,41 SAY MPROD_DESC
   SELECT C
   SEEK 'R' + MPROD_DESC
   MPROD_DISP = DESC
   @ 4,55 SAY SUBSTR(MPROD_DISP,1,22)
   @ 5,13 SAY MANIV_DATE
   @ 5,41 SAY MBOX_SIZE
   @ 5,57 SAY MPROD_SIZE
   @ 5,72 SAY MPAK_DAY PICTURE '999'
   @ 5,76 SAY MPAK_YR  PICTURE '99'
   @ 6,6  SAY MNOTE
   @ 8,16 SAY MLBS      PICTURE '999,999.99'
   @ 8,34 SAY MCASE_CNT PICTURE '9999'
   @ 8,48 SAY MPRI_LB   PICTURE '99.9999'
   @ 8,65 SAY MVALUE    PICTURE '99,999,999.99'
   SELECT B
   SET ORDER TO 1
   MMORE_COST = ' '
   MMORE_SHIP = ' '
   
   MCOST_LINE = 11
   MSHIP_LINE = 11
   SELECT A
   MVAL_LEFT  = VALUE
   MLBS_LEFT  = LBS
   MCASE_LEFT = CASE_CNT
   MTOT_COST = 0    
   MTOT_PRO  = 0
   MWORK_COST = 0
   MLAST_COST = 0
   SELECT B
   DO FOX_USE WITH "INVN_DTL INDEX IDTL_DTL, INVN_PO, INVNDISP, DTL_DATE, INVN_DTL, DTL_LOT", .F.
   SET ORDER TO 6   
   SEEK MFREEZ_LOC + MLOT_NBR
   DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT_NBR
      DO CASE    
      CASE ACT_CODE = 'C'
         IF COST_AMT = 0
            SKIP
            LOOP
         ENDIF
         MTOT_COST = MTOT_COST + COST_AMT
         MWORK_COST = MWORK_COST + COST_AMT
         *** DISPLAY COST INFO       
         IF MCOST_LINE <= 14
            @ MCOST_LINE,4 SAY ACT_DATE
            @ MCOST_LINE,32 SAY COST_CODE
            @ MCOST_LINE,44 SAY SUBSTR(PAYEE,1,13)
            @ MCOST_LINE,67 SAY COST_AMT PICTURE '999,999.99'
            MCOST_LINE = MCOST_LINE + 1
         ELSE
            MMORE_COST = 'Y'
         ENDIF
      CASE ACT_CODE = 'S'
         IF SHIP_LBS = 0
            SKIP
            LOOP
         ENDIF
         MTHIS_COST =  ROUND(ROUND(MWORK_COST/MLBS_LEFT,4) * SHIP_LBS,2)
         *** DISPLAY SHIPMENT INFO       
         IF MSHIP_LINE <= 20
            IF SALESMAN <> SPACE(2)
               @ MSHIP_LINE,4 SAY SALESMAN + '-'
            ENDIF
            @ MSHIP_LINE,7 SAY PO_NBR
            IF PO_SUFFIX <> ' '
               @ MSHIP_LINE,11 SAY '-' + PO_SUFFIX
            ENDIF
            SET CENTURY OFF
            @ MSHIP_LINE,14 SAY ACT_DATE
            SET CENTURY ON
            @ MSHIP_LINE,23 SAY SHIP_CASE  PICTURE '####'
            @ MSHIP_LINE,28 SAY SHIP_LBS   PICTURE '999999'
            @ MSHIP_LINE,35 SAY SUBSTR(SHIP_NAME,1,7)
            @ MSHIP_LINE,44 SAY SHIP_PRI PICTURE '99.9999'
            @ MSHIP_LINE,52 SAY SHIP_VAL PICTURE '999999.99' 
            @ MSHIP_LINE,62 SAY ROUND(MWORK_COST/MLBS_LEFT,4) PICTURE '99.9999'
            @ MSHIP_LINE,70 SAY ROUND(MTHIS_COST,2) PICTURE '99999.99'
            MLAST_COST = MTHIS_COST
            MSHIP_LINE = MSHIP_LINE + 1
         ELSE
            MMORE_SHIP = 'Y'
         ENDIF
         MLBS_LEFT  = MLBS_LEFT  - SHIP_LBS
         MVAL_LEFT  = MVAL_LEFT  - SHIP_VAL               
         MCASE_LEFT = MCASE_LEFT - SHIP_CASE
         MTOT_PRO  = MTOT_PRO + MTHIS_COST
         MWORK_COST = MWORK_COST - MTHIS_COST
      ENDCASE
      SKIP
   ENDDO
   
   SELECT B
   DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT", .F.
   SEEK MFREEZ_LOC + MLOT_NBR
   
   DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT_NBR
      DO CASE    
      CASE ACT_CODE = 'C'
         IF COST_AMT = 0
            SKIP
            LOOP
         ENDIF
         MTOT_COST = MTOT_COST + COST_AMT
         MWORK_COST = MWORK_COST + COST_AMT
         *** DISPLAY COST INFO       
         IF MCOST_LINE <= 14
            @ MCOST_LINE,4 SAY ACT_DATE
            @ MCOST_LINE,32 SAY COST_CODE
            @ MCOST_LINE,44 SAY SUBSTR(PAYEE,1,13)
            @ MCOST_LINE,67 SAY COST_AMT PICTURE '999,999.99'
            MCOST_LINE = MCOST_LINE + 1
         ELSE
            MMORE_COST = 'Y'
         ENDIF
      CASE ACT_CODE = 'S'
         IF SHIP_LBS = 0
            SKIP
            LOOP
         ENDIF
         MTHIS_COST =  ROUND(ROUND(MWORK_COST/MLBS_LEFT,4) * SHIP_LBS,2)
         *** DISPLAY SHIPMENT INFO       
         IF MSHIP_LINE <= 20
            IF SALESMAN <> SPACE(2)
               @ MSHIP_LINE,4 SAY SALESMAN + '-'
            ELSE
               @ MSHIP_LINE,4 SAY 'PE'
            ENDIF
            @ MSHIP_LINE,7 SAY PO_NBR
            IF PO_SUFFIX <> ' '
               @ MSHIP_LINE,11 SAY '-' + PO_SUFFIX
            ENDIF
            SET CENTURY OFF
            @ MSHIP_LINE,14 SAY ACT_DATE
            SET CENTURY ON
            @ MSHIP_LINE,23 SAY SHIP_CASE  PICTURE '####'
            @ MSHIP_LINE,28 SAY SHIP_LBS   PICTURE '999999'
            @ MSHIP_LINE,35 SAY SUBSTR(SHIP_NAME,1,7)
            @ MSHIP_LINE,44 SAY SHIP_PRI PICTURE '99.9999'
            @ MSHIP_LINE,52 SAY SHIP_VAL PICTURE '999999.99' 
            @ MSHIP_LINE,62 SAY ROUND(MWORK_COST/MLBS_LEFT,4) PICTURE '99.9999'
            @ MSHIP_LINE,70 SAY ROUND(MTHIS_COST,2) PICTURE '99999.99'
            MLAST_COST = MTHIS_COST
            MSHIP_LINE = MSHIP_LINE + 1
         ELSE
            MMORE_SHIP = 'Y'
         ENDIF
         MLBS_LEFT  = MLBS_LEFT  - SHIP_LBS
         MVAL_LEFT  = MVAL_LEFT  - SHIP_VAL               
         MCASE_LEFT = MCASE_LEFT - SHIP_CASE
         MTOT_PRO  = MTOT_PRO + MTHIS_COST
         MWORK_COST = MWORK_COST - MTHIS_COST
      ENDCASE
      SKIP
   ENDDO
   
   SELECT A
   
   XLBS_LEFT = LBS_LEFT
   XCASE_LEFT = CASE_LEFT
   XVAL_LEFT = VAL_LEFT
   
   @ 22,15 GET XLBS_LEFT  PICTURE '999,999.99'
   @ 22,32 GET XCASE_LEFT PICTURE '9999'
   @ 22,46 GET XVAL_LEFT  PICTURE '999,999.99'
   
   @ 23,15 GET MLBS_LEFT  PICTURE '999,999.99'
   @ 23,32 GET MCASE_LEFT PICTURE '9999'
   @ 23,46 GET MVAL_LEFT  PICTURE '999,999.99'
   
   CLEAR GETS
   IF MMORE_COST = 'Y' 
      @ 15,72 GET MMORE_COST PICTURE '@!'
   ENDIF
   IF MMORE_SHIP = 'Y'
      @ 22,72 GET MMORE_SHIP PICTURE '@!'
   ENDIF
   IF MMORE_COST = 'Y' .OR. MMORE_SHIP = 'Y'
      READ
      DO CASE
      CASE MMORE_COST = 'X'
         MDO_COST = .T.
         MDO_SHIP = .F.
         SAVE SCREEN TO MGRACE
         DO SHIPCOST
         RESTORE SCREEN FROM MGRACE
         
      CASE MMORE_SHIP = 'X'
         MDO_SHIP = .T.
         MDO_COST = .F.
         SAVE SCREEN TO MGRACE
         DO SHIPCOST
         RESTORE SCREEN FROM MGRACE
      ENDCASE
   ENDIF
   
   MACTION = 1
   @ 23,68 GET MACTION PICTURE '#' RANGE 1,1
   READ
   
   DO CASE
   CASE MACTION = 1
   CASE MACTION = 2 
   CASE MACTION = 3
   CASE MACTION = 4
   OTHERWISE
      MINIT_NM = .T.
   ENDCASE 
ENDDO 
RETURN

PROCEDURE SHIPCOST
CLEAR
IF MDO_COST        
   @ 1,0 SAY MCOMPANY + ' INVENTORY - DISPLAY COSTS'
   @ 03,1 SAY 'COST:Date    Cases     Pounds  Reason      Payee           Pr/Lb  Total Cost'
ELSE
   @ 1,0 SAY MCOMPANY + ' INVENTORY - DISPLAY SHIPMENTS'
   **@ 03,1 SAY 'SALES Po Nbr    Date   Cases   Pounds  Sold To               Pr/Lb  Total Sale'
   @ 03,1 SAY 'Sales Po #   Ship Dt  Case Pounds Customer  Pri/Lb     Value Pro/Cst Tot Cost'  
ENDIF
@ 2,0 to 22,79
@ 04,1 SAY '1.'
@ 05,1 SAY '2.'
@ 06,1 SAY '3.'
@ 07,1 SAY '4.'
@ 08,1 SAY '5.'
@ 09,1 SAY '6.'
@ 10,1 SAY '7.'
@ 11,1 SAY '8.'
@ 12,1 SAY '9.'
@ 13,1 SAY '10.'
@ 14,1 SAY '11.'
@ 15,1 SAY '12.'
@ 16,1 SAY '13.'
@ 17,1 SAY '14.'
@ 18,1 SAY '15.'
@ 19,1 SAY '16.'
@ 20,1 SAY '17.'
@ 21,1 SAY '18.'
@ 22,1 SAY '19.'
@ 24,1 SAY 'Action: 1   1. Return'

MLINE = 4 
SELECT B
***SET ORDER TO 3

DO CASE
CASE MDO_COST
   *** SEEK THOSE COSTS
   SEEK STR(MI_NBR,5) + 'C'
   DO WHILE .NOT. EOF() .AND. I_NBR = MI_NBR .AND. ACT_CODE = 'C' .AND. MLINE <= 22
      @ MLINE,4 SAY ACT_DATE
      @ MLINE,32 SAY COST_CODE
      @ MLINE,44 SAY SUBSTR(PAYEE,1,13)
      @ MLINE,67 SAY COST_AMT PICTURE '999,999.99'
      MLINE = MLINE + 1
      SKIP
   ENDDO
   
CASE MDO_SHIP       
   *** SEEK THOSE SHIPMENTS
   *SEEK STR(MI_NBR,5) + 'S'
   *DO WHILE .NOT. EOF() .AND. I_NBR = MI_NBR .AND. ACT_CODE = 'S' .AND. MLINE <= 22
   *   IF SALESMAN <> SPACE(2)
   *      @ MLINE,4 SAY SALESMAN + '-'
   *   ENDIF
   *   @ MLINE,7 SAY PO_NBR
   *   IF PO_SUFFIX <> ' '
   *      @ MLINE,11 SAY '-' + PO_SUFFIX
   *   ENDIF
   *   @ MLINE,15 SAY ACT_DATE
   *   @ MLINE,25 SAY SHIP_CASE  PICTURE '####'
   *   @ MLINE,31 SAY SHIP_LBS   PICTURE '999,999'
   *   @ MLINE,40 SAY SUBSTR(SHIP_NAME,1,19)
   *   @ MLINE,61 SAY SHIP_PRI PICTURE '9.9999'
   *   @ MLINE,69 SAY SHIP_VAL PICTURE '999,999.99' 
   *   MLINE = MLINE + 1
   *   SKIP
   *ENDDO
   
   SELECT A
   MLBS_LEFT  = LBS
   
   MTOT_COST = 0    
   MTOT_PRO  = 0
   MWORK_COST = 0
   MLAST_COST = 0
   SELECT B
   DO FOX_USE WITH "INVN_DTL INDEX IDTL_DTL, INVN_PO, INVNDISP, DTL_DATE, INVN_DTL, DTL_LOT", .F.
   SET ORDER TO 6
   SEEK A->FREEZ_LOC + A->LOT_NBR
   DO WHILE .NOT. EOF() .AND. A->FREEZ_LOC = FREEZ_LOC .AND. A->LOT_NBR = LOT_NBR
      
      **DO WHILE .NOT. EOF() .AND. A->I_NBR = I_NBR
      IF MLINE > 22
         @ 24,1 SAY 'Action: 1   1. Next Page'
         MACTION = 1
         @ 24,9 GET MACTION PICTURE '#' RANGE 1,1
         READ
         MLINE = 4 
         @ 4,4 CLEAR TO 22,78
         @ 24,0 clear
      ENDIF
      
      DO CASE    
      CASE ACT_CODE = 'C'
         IF COST_AMT = 0
            SKIP
            LOOP
         ENDIF
         MTOT_COST = MTOT_COST + COST_AMT
         MWORK_COST = MWORK_COST + COST_AMT
      CASE ACT_CODE = 'S'
         IF SHIP_LBS = 0
            SKIP
            LOOP
         ENDIF
         MTHIS_COST =  ROUND(ROUND(MWORK_COST/MLBS_LEFT,4) * SHIP_LBS,2)
         *** DISPLAY SHIPMENT INFO       
         IF SALESMAN <> SPACE(2)
            @ MLINE,4 SAY SALESMAN + '-'
         ENDIF
         @ MLINE,7 SAY PO_NBR
         IF PO_SUFFIX <> ' '
            @ MLINE,11 SAY '-' + PO_SUFFIX
         ENDIF
         SET CENTURY OFF
         @ MLINE,14 SAY ACT_DATE
         SET CENTURY ON
         @ MLINE,23 SAY SHIP_CASE  PICTURE '####'
         @ MLINE,28 SAY SHIP_LBS   PICTURE '999999'
         @ MLINE,35 SAY SUBSTR(SHIP_NAME,1,8)
         @ MLINE,44 SAY SHIP_PRI PICTURE '99.9999'
         @ MLINE,52 SAY SHIP_VAL PICTURE '999999.99' 
         @ MLINE,62 SAY ROUND(MWORK_COST/MLBS_LEFT,4) PICTURE '99.9999'
         @ MLINE,70 SAY ROUND(MTHIS_COST,2) PICTURE '99999.99'
         MLAST_COST = MTHIS_COST
         MLINE = MLINE + 1
         MTOT_PRO  = MTOT_PRO + MTHIS_COST
         MWORK_COST = MWORK_COST - MTHIS_COST
         MLBS_LEFT  = MLBS_LEFT  - SHIP_LBS
      ENDCASE
      SKIP
   ENDDO
   
   SELECT B
   DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT", .F.
   SEEK A->FREEZ_LOC + A->LOT_NBR
   
   DO WHILE .NOT. EOF() .AND. A->FREEZ_LOC = FREEZ_LOC .AND. A->LOT_NBR = LOT_NBR
      IF MLINE > 22
         @ 24,1 SAY 'Action: 1   1. Next Page'
         MACTION = 1
         @ 24,9 GET MACTION PICTURE '#' RANGE 1,1
         READ
         MLINE = 4 
         @ 4,4 CLEAR TO 22,78
         @ 24,0 clear
      ENDIF
      
      DO CASE    
      CASE ACT_CODE = 'C'
         IF COST_AMT = 0
            SKIP
            LOOP
         ENDIF
         MTOT_COST = MTOT_COST + COST_AMT
         MWORK_COST = MWORK_COST + COST_AMT
      CASE ACT_CODE = 'S'
         IF SHIP_LBS = 0
            SKIP
            LOOP
         ENDIF
         MTHIS_COST =  ROUND(ROUND(MWORK_COST/MLBS_LEFT,4) * SHIP_LBS,2)
         *** DISPLAY SHIPMENT INFO       
         IF SALESMAN <> SPACE(2)
            @ MLINE,4 SAY SALESMAN + '-'
         ELSE
            @ MLINE,4 SAY 'PE'
         ENDIF
         @ MLINE,7 SAY PO_NBR
         IF PO_SUFFIX <> ' '
            @ MLINE,11 SAY '-' + PO_SUFFIX
         ENDIF
         SET CENTURY OFF
         @ MLINE,14 SAY ACT_DATE
         SET CENTURY ON
         @ MLINE,23 SAY SHIP_CASE  PICTURE '####'
         @ MLINE,28 SAY SHIP_LBS   PICTURE '999999'
         @ MLINE,35 SAY SUBSTR(SHIP_NAME,1,8)
         @ MLINE,44 SAY SHIP_PRI PICTURE '99.9999'
         @ MLINE,52 SAY SHIP_VAL PICTURE '999999.99' 
         @ MLINE,62 SAY ROUND(MWORK_COST/MLBS_LEFT,4) PICTURE '99.9999'
         @ MLINE,70 SAY ROUND(MTHIS_COST,2) PICTURE '99999.99'
         MLAST_COST = MTHIS_COST
         MLINE = MLINE + 1
         MTOT_PRO  = MTOT_PRO + MTHIS_COST
         MWORK_COST = MWORK_COST - MTHIS_COST
         MLBS_LEFT  = MLBS_LEFT  - SHIP_LBS
      ENDCASE
      SKIP
   ENDDO
   
ENDCASE
@ 24,1 SAY 'Action: 1   1. Return'
MACTION = 1
@ 24,9 GET MACTION PICTURE '#' RANGE 1,1
READ

RETURN

PROCEDURE IACT_RPT
********



RETURN

PROCEDURE IMAINT
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
MTITLE = ' - REINDEX FILES'
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 22,79

@ 07,10 SAY 'This will reindex the data files.  It will take a few minutes.'
STORE 'NO ' TO MTEMP
SET CONFIRM ON
@ 11,20 SAY 'ARE YOU READY ?!?!?! (YES/NO) ' GET MTEMP PICTURE '@!'

READ
SET CONFIRM OFF
IF MTEMP = 'YES'
   @ 4,1 CLEAR TO 22,78
   
   @ 17,20 SAY 'MAIN INVENTORY FILE......'
   USE INVEN EXCLUSIVE
   SET TALK ON
   SET ECHO ON
   SET STATUS ON
   
   **PACK
   INDEX ON LOT_NBR TO INVNLOT
   INDEX ON SALESMAN+PO_NBR+PO_SUFFIX TO INVNPO
   INDEX ON FREEZ_LOC + LOT_NBR TO INVNLOC
   INDEX ON SOLD_FLG+DIV_CODE+FREEZ_LOC+PROD_DESC+STR(YEAR(ANIV_DATE),4)+SUBSTR(DTOC(ANIV_DATE),1,2)+SUBSTR(DTOC(ANIV_DATE),4,2) + LOT_NBR TO INVNSOLD
   INDEX ON STR(I_NBR,5) TO INVNINBR
   INDEX ON STR(YEAR(ANIV_DATE),4)+SUBSTR(DTOC(ANIV_DATE),1,5) TO INVNANIV
   INDEX ON IPRODDESC TO INVNCAT 
   
   UNLOCK
   SET TALK OFF
   SET ECHO OFF
   SET STATUS OFF
   
   @ 17,01 SAY SPACE(78)  
   
   @ 17,20 SAY 'HOLDING INVENTORY FILE......'
   USE HINVEN EXCLUSIVE
   SET TALK ON
   SET ECHO ON
   SET STATUS ON
   
   **PACK
   INDEX ON FREEZ_LOC + LOT_NBR TO HINVNLOC
   INDEX ON SOLD_FLG+DIV_CODE+FREEZ_LOC+PROD_DESC+STR(YEAR(ANIV_DATE),4)+SUBSTR(DTOC(ANIV_DATE),1,2)+SUBSTR(DTOC(ANIV_DATE),4,2) TO HINVSOLD
   UNLOCK
   SET TALK OFF
   SET ECHO OFF
   SET STATUS OFF
   
   @ 17,01 SAY SPACE(78)  
   
   @ 17,20 SAY 'INVENTORY ACTIVITY DETAIL FILE....'
   USE INVN_DTL EXCLUSIVE
   SET TALK ON
   SET ECHO ON
   SET STATUS ON
   
   **PACK
   INDEX ON STR(I_NBR,5)+STR(YEAR(ACT_DATE),4)+SUBSTR(DTOC(ACT_DATE),1,2)+SUBSTR(DTOC(ACT_DATE),4,2) TO IDTL_DTL
   INDEX ON STR(I_NBR,5) + SALESMAN + PO_NBR+PO_SUFFIX TO INVN_PO
   INDEX ON STR(I_NBR,5) + ACT_CODE + STR(CTOD('12/31/2099')-ACT_DATE,10) + ACT_CODE TO INVNDISP
   INDEX ON STR(YEAR(ACT_DATE),4)+SUBSTR(DTOC(ACT_DATE),1,5) TO DTL_DATE
   INDEX ON SALESMAN+PO_NBR+PO_SUFFIX+ITEM_NBR+ACT_CODE TO INVN_DTL
   INDEX ON FREEZ_LOC + LOT_NBR + ACT_CODE TO DTL_LOT
   UNLOCK
   
   SET TALK OFF
   SET ECHO OFF
   SET STATUS OFF
   
   @ 17,01 SAY SPACE(78)  
   
   @ 17,20 SAY 'HOLDING INVENTORY DETAIL FILE....'
   USE HINV_DTL EXCLUSIVE
   SET TALK ON
   SET ECHO ON
   SET STATUS ON
   
   ***PACK
   INDEX ON SALESMAN+PO_NBR+PO_SUFFIX+ITEM_NBR+ACT_CODE TO HINV_DTL
   INDEX ON FREEZ_LOC + LOT_NBR + ACT_CODE TO HDTL_LOT
   UNLOCK
   
   SET TALK OFF
   SET ECHO OFF
   SET STATUS OFF
   
   @ 17,01 SAY SPACE(78)  
ENDIF
RETURN


PROCEDURE IPENDUPD 
CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + ' - DELETE OLD PENDING LOT RECORDS'
@ 3,0 TO 22,79
MMORE = .T.
DO WHILE MMORE
   MLOT_NBR = SPACE(10)
   MFREEZ_LOC = SPACE(32)
   @  8, 5 SAY 'Lot Nbr:'
   @ 10,5 SAY  'Freezer:'
   MACTION = 2
   DO WHILE MACTION = 2
      @ 24,0 CLEAR
      @  8,14 GET MLOT_NBR PICTURE '@!'
      @ 10,14 GET MFREEZ_LOC PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
      READ
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   
   IF MACTION = 3 .OR. MLOT_NBR = SPACE(10)
      MMORE = .F.
      LOOP
   ENDIF 
   
   SELECT A
   DO FOX_USE WITH "HINVEN INDEX HINVNLOC, HINVSOLD", .F.
   SEEK MFREEZ_LOC + MLOT_NBR
   ** NO HIT
   MHIT = .F.
   DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT_NBR
      DO RECLOCK
      DELETE
      UNLOCK
      MHIT = .T.
      SKIP
   ENDDO
   
   DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT, HINV_DTL", .F.
   SEEK MFREEZ_LOC + MLOT_NBR
   DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC .AND. LOT_NBR = MLOT_NBR
      DO RECLOCK
      DELETE
      UNLOCK
      MHIT = .T.
      SKIP
   ENDDO
   IF MHIT
      MWAIT = ' '
      @ 24,0 CLEAR
      @ 24,1 SAY 'Lot Record(s) Deleted - Press Return To Continue ' GET MWAIT
      READ
   ELSE
      MWAIT = ' '
      @ 24,0 CLEAR
      @ 24,1 SAY 'No Records Found To Delete - Press Return To Reenter ' GET MWAIT
      READ
   ENDIF
ENDDO
CLOSE DATA
RETURN

PROCEDURE FREEZINQ
MMORE = .T.
DO WHILE MMORE
   CLEAR
   @ 00,00 SAY MCOMPANY
   @ 01,68 SAY DATE()
   @ 01,00 SAY MPROGRAM + ' - View Activity for Selected Freezer/Product/Time'
   @ 2,0 to 22,79
   MFREEZ_LOC = SPACE(32)
   MPROD_DESC = SPACE(6)
   STORE CTOD('') TO MBEGIN, MENDING
   STORE 'D' TO MDISP_PRT
   @ 08,3 say 'Enter Freezer Name: ' GET MFREEZ_LOC PICTURE '@!'
   @ 10,3 SAY 'Enter Product Code: ' GET MPROD_DESC PICTURE '@!'
   @ 12,3 SAY 'Enter Activity Timeframe '
   @ 13,3 SAY 'Begin Date:                 Ending Date:'
   @ 13,15 GET MBEGIN
   @ 13,44 GET MENDING
   @ 16,3  SAY 'Display Info (D) -or- Print Report (P): ' GET MDISP_PRT PICTURE '@!'
   READ
   
   IF MFREEZ_LOC = SPACE(32) .AND. MPROD_DESC = SPACE(6)
      MMORE = .F.
      LOOP
   ENDIF
   
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_NAME", .F.
   SEEK TRIM(MFREEZ_LOC)
   IF .NOT. EOF()
      STORE NAME TO MFREEZ_LOC
   ENDIF
   USE
   
   *************************************************
   SELECT A
   DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
   
   SELECT B
   DO FOX_USE WITH "INVN_DTL INDEX DTL_LOT", .F.
   
   SELECT C
   USE DTLTMP EXCLUSIVE
   DELETE ALL
   PACK
   
   SELECT B
   SEEK MFREEZ_LOC
   
   DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC
      IF ACT_DATE < MBEGIN .OR. ACT_DATE > MENDING       
         SKIP
         LOOP
      ENDIF
      
      SELECT A
      SEEK MFREEZ_LOC + B->LOT_NBR
      
      IF PROD_DESC <> MPROD_DESC
         SELECT B
         SKIP
         LOOP
      ENDIF
      
      SELECT C
      APPEND BLANK
      REPLACE FREEZ_LOC WITH B->FREEZ_LOC
      REPLACE PROD_DESC WITH A->PROD_DESC
      REPLACE ACT_DATE  WITH B->ACT_DATE
      REPLACE ACT_CODE  WITH B->ACT_CODE
      REPLACE SALESMAN  WITH B->SALESMAN
      REPLACE PO_NBR    WITH B->PO_NBR
      REPLACE PO_SUFFIX WITH B->PO_SUFFIX
      REPLACE QTY       WITH B->QTY
      REPLACE LOT_NBR   WITH B->LOT_NBR
      SELECT B
      SKIP
   ENDDO
   
   
   *************************************************
   
   SELECT A
   DO FOX_USE WITH "HINVEN INDEX HINVNLOC", .F.
   
   SELECT D
   DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
   
   SELECT B
   DO FOX_USE WITH "HINV_DTL INDEX HDTL_LOT", .F.
   
   
   *************************************************
   SEEK TRIM(MFREEZ_LOC)
   IF .NOT. EOF()
      MREEZ_LOC = FREEZ_LOC
   ENDIF
   
   DO WHILE .NOT. EOF() .AND. FREEZ_LOC = TRIM(MFREEZ_LOC)
      IF ACT_DATE < MBEGIN .OR. ACT_DATE > MENDING       
         SKIP
         LOOP
      ENDIF
      
      IF ACT_CODE = 'S'
         SELECT D
         SEEK MFREEZ_LOC + B->LOT_NBR
         
         IF PROD_DESC <> MPROD_DESC
            SELECT B
            SKIP
            LOOP
         ENDIF
         
         SELECT C
         APPEND BLANK
         REPLACE FREEZ_LOC WITH B->FREEZ_LOC
         REPLACE PROD_DESC WITH D->PROD_DESC
         REPLACE ACT_DATE  WITH B->ACT_DATE
         REPLACE ACT_CODE  WITH B->ACT_CODE
         REPLACE SALESMAN  WITH B->SALESMAN
         REPLACE PO_NBR    WITH B->PO_NBR
         REPLACE PO_SUFFIX WITH B->PO_SUFFIX
         REPLACE QTY       WITH B->QTY
         REPLACE LOT_NBR   WITH B->LOT_NBR
      ELSE
         
         SELECT A
         SEEK MFREEZ_LOC + B->LOT_NBR
         
         IF PROD_DESC <> MPROD_DESC
            SELECT B
            SKIP
            LOOP
         ENDIF
         
         SELECT C
         APPEND BLANK
         REPLACE FREEZ_LOC WITH B->FREEZ_LOC
         REPLACE PROD_DESC WITH A->PROD_DESC
         REPLACE ACT_DATE  WITH B->ACT_DATE
         REPLACE ACT_CODE  WITH B->ACT_CODE
         REPLACE SALESMAN  WITH B->SALESMAN
         REPLACE PO_NBR    WITH B->PO_NBR
         REPLACE PO_SUFFIX WITH B->PO_SUFFIX
         REPLACE QTY       WITH B->QTY
         REPLACE LOT_NBR   WITH B->LOT_NBR
      ENDIF
      SELECT B
      SKIP
   ENDDO
   
   
   CLOSE DATA
   
   SELECT A
   USE DTLTMP EXCLUSIVE
   INDEX ON ACT_DATE TO DTLTMP
   USE DTLTMP INDEX DTLTMP EXCLUSIVE
   
   MFREEZ_LOC = FREEZ_LOC
   STORE 0 TO MQTY_IN, MQTY_OUT
   IF EOF()
      MWAIT = ' '
      
      @ 18,1 SAY 'NO ACTIVITY FOR SELECTION - PRESS RETURN TO CONTINUE ' GET MWAIT
      READ
      LOOP
   ENDIF
   
   IF MDISP_PRT = 'D'
      @ 3,1 SAY 'Activity for ' + trim(MPROD_DESC) + ' at ' + SUBSTR(MFreez_loc,1,20) + ' for ' + dtoc(mbegin) + ' thru ' + dtoc(mending)
      @ 4,1 SAY 'ACT'
      @ 4,7 SAY 'ACT DATE'
      @ 4,21 SAY 'PO NBR'
      @ 4,29 SAY 'LOT NBR'
      @ 4,41 SAY '  QTY IN     QTY OUT'
      @ 5,1 TO 5,78
      DO WHILE .NOT. EOF()
         MLINE = 6
         @ 6,1 CLEAR TO 22,78
         DO WHILE .NOT. EOF() .AND. MLINE <= 22
            IF ACT_CODE = 'S'
               @ MLINE,1 SAY 'OUT'
            ELSE
               @ MLINE,1 SAY 'IN'
            ENDIF
            @ MLINE,6  SAY ACT_DATE
            @ MLINE,18 SAY SALESMAN
            IF SALESMAN <> '  '
               @ MLINE,20 SAY '-' 
            ENDIF
            @ MLINE,21 SAY PO_NBR
            IF PO_SUFFIX <> ' '
               @ MLINE,25 SAY '-' + PO_SUFFIX
            ENDIF
            @ MLINE,29 SAY LOT_NBR
            IF ACT_CODE = 'S'
               @ MLINE,54 SAY QTY PICTURE '999,999'
               MQTY_OUT = MQTY_OUT + QTY
            ELSE
               @ MLINE,42 SAY QTY PICTURE '999,999'
               MQTY_IN  = MQTY_IN  + QTY
            ENDIF
            MLINE = MLINE + 1
            SKIP
         ENDDO
         MWAIT = ' '
         IF EOF()
            @ 24,0 clear
            @ 24,40 SAY MQTY_IN PICTURE '9,999,999'
            @ 24,52 SAY MQTY_OUT PICTURE '9,999,999'
            @ 24,65 say 'TOTALS'
            @ 24,1 SAY 'Press Return to Continue ' get mwait
         ELSE
            @ 24,0 clear
            @ 24,1 SAY 'Press Return to Continue to Next Page ' get mwait
         ENDIF
         READ
      ENDDO
   ELSE
      MLINE = 99
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 10 CPI
      ?? chr(27) + '&k0S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
      DO WHILE .NOT. EOF()
         IF MLINE > 60
            IF MLINE <> 99
               EJECT
            ENDIF
            @ 3,1 SAY 'Activity for ' + trim(MPROD_DESC) + ' at ' + SUBSTR(MFreez_loc,1,20) + ' for ' + dtoc(mbegin) + ' thru ' + dtoc(mending)
            @ 4,1 SAY 'ACT'
            @ 4,7 SAY 'ACT DATE'
            @ 4,21 SAY 'PO NBR'
            @ 4,29 SAY 'LOT NBR'
            @ 4,41 SAY '  QTY IN     QTY OUT'
            MLINE = 6
         ENDIF
         
         IF ACT_CODE = 'S'
            @ MLINE,1 SAY 'OUT'
         ELSE
            @ MLINE,1 SAY 'IN'
         ENDIF
         @ MLINE,6  SAY ACT_DATE
         @ MLINE,18 SAY SALESMAN
         IF SALESMAN <> '  '
            @ MLINE,20 SAY '-' 
         ENDIF
         @ MLINE,21 SAY PO_NBR
         IF PO_SUFFIX <> ' '
            @ MLINE,25 SAY '-' + PO_SUFFIX
         ENDIF
         @ MLINE,29 SAY LOT_NBR
         IF ACT_CODE = 'S'
            @ MLINE,54 SAY QTY PICTURE '999,999'
            MQTY_OUT = MQTY_OUT + QTY
         ELSE
            @ MLINE,42 SAY QTY PICTURE '999,999'
            MQTY_IN  = MQTY_IN  + QTY
         ENDIF
         MLINE = MLINE + 1
         SKIP
      ENDDO
      IF MLINE <> 99
         MLINE = MLINE + 2
         @ MLINE,1  say 'TOTALS'
         @ MLINE,40 SAY MQTY_IN PICTURE '9,999,999'
         @ MLINE,52 SAY MQTY_OUT PICTURE '9,999,999'
         EJECT
      ENDIF
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
   ENDIF
   
ENDDO

CLOSE DATA
MRPT_SEL   = ' '
RETURN

* EOF: INVNPROC.PRG





*Formatted by: ToolBox Ver. 1.2  on 4/17/17 at 11:54 AM.
