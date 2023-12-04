***************
* Program.: MAINT2.PRG
* Author..: GRACE KELLER
* Date....: 06/07/88
* Notice..: Copyright (C) 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: File Maintenance Program MENU II
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

STORE ' ' TO MSELECT2
STORE ' ' TO MACTION
DIMENSION MUPDRCD(15)  
DIMENSION MSELECT(15)
DIMENSION MDUE(15)
DO WHILE MSELECT2 <> '9'
   CLOSE DATA
   CLEAR
   @ 01,00 SAY MCOMPANY
   @ 02,00 SAY MPROGRAM + ' - FILE MAINTENANCE MENU II'
   @ 02,70 SAY DATE()
   @ 3,0 to 25,79
   
   @ 05,10 SAY "1 - MARK PO'S PAID FOR SUPPLIER/FREIGHT/CUSTOMER"
   @ 07,10 SAY '2 - UPDATE PO TO HAVE SHORTWEIGHTS FLAGGED AS ENTERED'
   @ 09,10 SAY '3 - ARCHIVE MASTER FILE DATA (USE WITH CAUTION !!)'
   @ 11,10 SAY '4 - CONVERT SUPPLIER/CUSTOMER TO DIFFERENT SUPPLIER/CUSTOMER'
   @ 13,10 SAY '5 - RELEASE SUPPLIER UNDERBILLING/STOP PAYMENT FROM PAYMENT HOLD'
   @ 15,10 SAY "6 - LEDGER CONSOLIDATION MASTER UPDATE - SUPP/CUST/BILLBACK ACCTS"
   @ 17,10 say '7 - SS SPREADSHEET - MARK POSTED/SWITCH SHIP DATE AND MONTH'
   @ 19,10 SAY '8 - SS SPREADSHEET - REMOVE OLD PREVIOUS MONTHS ENTRIES'
   @ 21,10 SAY '9 - RETURN TO MAIN MENU'
   
   STORE '1' TO MSELECT2
   @ 23,02 SAY 'CHOICE: '
   @ 23,25 say "('X' TO PAGE TO MAINTENANCE MENU III)"
   @ 23,10 GET MSELECT2 PICTURE '@!'
   READ
   
   DO CASE
   CASE MSELECT2 = 'X'
      DO MAINT3

   CASE MSELECT2 = '1'   
      @ 4,1 CLEAR TO 23,78
      STORE ' ' TO MPICK
      @ 10,10 SAY 'DO YOU WANT TO SELECT SUPPLIERS, FREIGHT, OR CUSTOMERS (S/F/C)? ' GET MPICK PICTURE '@!'
      READ
      STORE SPACE(2)    TO MSALESMAN
      STORE SPACE(4)    TO MPO_NBR
      STORE SPACE(1)    TO MPO_SUFFIX
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PO_SUP, PO_FRT", .F.
      MPO_FD = .F.
      STORE 1 TO MACTION
      MPO_SEL = .T.
      DO WHILE MPO_SEL
         
         CLEAR 
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         MTITLE = ' - SELECT PURCHASE ORDER'
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         @  5, 5 SAY 'Enter Search Field:'
         @  8, 5 SAY 'Purchase Order Number'
         @ 10, 5 GET Msalesman PICTURE '##'
         @ 10,7 say '-'
         @ 10,8 get mpo_nbr picture '####'
         @ 10,12 say '-'
         @ 10,13 get mpo_suffix picture '@!'
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
         @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         
         DO CASE
            
         CASE MACTION = 1
            IF MPO_NBR <> SPACE(4)
               SELECT B
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               IF EOF() .OR. DELETED()
                  @ 24,0 CLEAR
                  MWAIT = ' '
                  @ 24,10 SAY 'PURCHASE ORDER NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
                  READ
                  LOOP
               ELSE
                  DO RECLOCK  
                  DO CASE
                  CASE MPICK = 'S'
                     REPLACE SUP_REC WITH  'Y'
                     REPLACE SUP_PD WITH 'Y'
                  CASE MPICK = 'F'
                     REPLACE FRT_REC WITH  'Y'
                     REPLACE FRT_PD WITH 'Y'
                  CASE MPICK = 'C'
                     REPLACE PAID_FLG WITH 'Y'
                  ENDCASE
                  UNLOCK
                  
               ENDIF
               **** IF FINISHED HERE, GET OUT
               STORE SPACE(2)    TO MSALESMAN
               STORE SPACE(4)    TO MPO_NBR
               STORE SPACE(1)    TO MPO_SUFFIX
               LOOP
            ENDIF     
            
            MPO_SEL = .F.
            LOOP
         CASE MACTION = 2
            LOOP
            
         CASE MACTION = 3
            MPO_SEL = .F.
            
         ENDCASE
         
      ENDDO
      LOOP
      
   CASE MSELECT2 = '2'
      STORE SPACE(2)    TO MSALESMAN
      STORE SPACE(4)    TO MPO_NBR
      STORE SPACE(1)    TO MPO_SUFFIX
      SELECT B
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
      MPO_FD = .F.
      STORE 1 TO MACTION
      MPO_SEL = .T.
      DO WHILE MPO_SEL
         
         CLEAR 
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         MTITLE = ' - SELECT PO TO MARK SHORTWEIGHTS AS ENTERED'
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         @  5, 5 SAY 'Enter Search Field:'
         @  8, 5 SAY 'Purchase Order Number'
         @ 10, 5 GET Msalesman PICTURE '##'
         @ 10,7 say '-'
         @ 10,8 get mpo_nbr picture '####'
         @ 10,12 say '-'
         @ 10,13 get mpo_suffix picture '@!'
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
         @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         
         DO CASE
            
         CASE MACTION = 1
            IF MPO_NBR <> SPACE(4)
               SELECT B
               SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
               IF EOF() .OR. DELETED()
                  @ 24,0 CLEAR
                  MWAIT = ' '
                  @ 24,10 SAY 'PURCHASE ORDER NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
                  READ
                  LOOP
               ELSE
                  DO RECLOCK  
                  REPLACE SHORT_FLG WITH  'Y'
                  UNLOCK
               ENDIF
               **** IF FINISHED HERE, GET OUT
               STORE SPACE(2)    TO MSALESMAN
               STORE SPACE(4)    TO MPO_NBR
               STORE SPACE(1)    TO MPO_SUFFIX
               LOOP
            ENDIF     
            
            MPO_SEL = .F.
            LOOP
         CASE MACTION = 2
            LOOP
            
         CASE MACTION = 3
            MPO_SEL = .F.
            
         ENDCASE
         
      ENDDO
   CASE MSELECT2 = '3'
      MTITLE = ' - ARCHIVE PURCHASE ORDER DATA' 
      MCHOICE = SPACE(6)
      MACTION = 2
      DO WHILE MACTION = 2
         CLEAR 
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         MTITLE = ' - ARCHIVE PURCHASE ORDER DATA'
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         @ 4,10 SAY 'IMPORTANT !! This function deletes data off the'
         @ 5,10 say 'Master DataBase Files.  It will create some'
         @ 6,10 say 'backup files to archive on diskettes.  You must'   
         @ 7,10 say 'have some diskettes formatted and ready to use'
         @ 8,10 say 'for backup when this function completes.  Please'
         @ 9,10 say 'put these diskettes in the Safe Deposit Box'
         @ 10,10 say 'in case this information needs to be restored.'   
         @ 11,10 say 'Make sure this is DEFINITELY what you want to do'
         @ 12,10 say 'before continuing !!!!'
         @ 13,10 SAY 'NOTE: !!! IF THIS IS THE FIRST TIME TO RUN - CALL GRACE !!!!'
         @ 14,10 SAY 'Select Archive Method:'
         @ 15,10 say 'Enter "CONT"   to Continue '
         @ 16,10 SAY '-or-  "CANCEL" to Cancel   : ' get MCHOICE picture '@!' VALID (MCHOICE = 'CONT' .OR. MCHOICE = 'CANCEL')
         MACTION = 1        
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
         @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
      ENDDO
      IF MACTION = 3 
         LOOP   
      ENDIF
      IF MCHOICE <> 'CONT'
         LOOP   
      ENDIF
      MCHOICE = 'SALE'
      
      @ 4,1 CLEAR TO 21,78
      MACTION = 2
      MPICK_SALE = '  '
      MDATE = CTOD('')
      DO WHILE MACTION = 2
         DO CASE   
         CASE MCHOICE = 'SALE'
            @ 8,10 SAY  'SALESPERSON CODE:  ' GET MPICK_SALE              
            @ 9,10 say  "Note: Enter '**' for blank salesperson code."
            @ 11,10 SAY 'LAST ARCHIVE DATE: ' GET MDATE
            @ 12,10 SAY "Note:  All PO's will be archived "
            @ 13,10 say '       that have a ship date equal'
            @ 14,10 say '       or prior to the above date.'
         OTHERWISE
         ENDCASE
         
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
         @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'
         MACTION = 1        
         READ
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
      ENDDO
      ** If any of the above fields are left blank, just get out
      IF MACTION = 3 .OR. MPICK_SALE = '  ' .OR. DTOC(MDATE) = '  /  /  '
         LOOP  
      ENDIF
      IF MPICK_SALE = '**'
         MPICK_SALE = '  '
      ENDIF
      *** IF MCHOICE = SALESMAN, FIND THE LAST PO THAT IS LESS THAN THE 
      *** SELECTED DATE AND SHOW WHAT THAT PURCHASE ORDER NUMBER IS.
      MFIRST_NBR = '9999'
      MLAST_NBR  = '0000'
      IF MCHOICE = 'SALE'
         SELECT A
         DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP", .F.
         DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MDATE
            IF SALESMAN <> MPICK_SALE
               SKIP
               LOOP
            ENDIF
            IF VAL(PO_NBR) < val(MFIRST_NBR)
               MFIRST_NBR = PO_NBR 
            ENDIF
            IF VAL(PO_NBR) > val(MLAST_NBR)
               MLAST_NBR = PO_NBR 
            ENDIF
            SKIP
         ENDDO
         **** THIS IS THE WAY I DID IT AT FIRST ....
         **** DECIDED TO DO IT THE ABOVE WAY TO GET A 
         **** STARTING AND ENDING PO NUMBER
         **MYEAR  = SUBSTR(DTOC(MDATE),7)
         **MMONTH = SUBSTR(DTOC(MDATE),1,2)
         **MDAY   = SUBSTR(DTOC(MDATE),3,2)
         **SELECT B
         **DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP", .F.
         **SEEK MYEAR+MMONTH
         **MLAST_NBR = SPACE(4)
         **DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MDATE
         **   SKIP
         **ENDDO
         **SKIP -1
         **DO WHILE .NOT. BOF() .AND.  MLAST_NBR = SPACE(4)
         **   IF SALESMAN = MPICK_SALE
         **      MLAST_NBR = PO_NBR
         **      LOOP
         **   ENDIF
         **   SKIP -1
         **ENDDO
      ENDIF
      IF vaL(MFIRST_NBR) = 9999     
         MWAIT = ' '
         @ 4,1 CLEAR TO 21,78
         @ 10,10 SAY 'COULD NOT FIND A PO TO ARCHIVE. CHECK DATES!!'
         @ 11,10 SAY 'THIS FUNCTION CANNOT PROCESS - PRESS RETURN TO' 
         @ 12,10 SAY 'GO TO THE MENU.. ' GET MWAIT 
         READ
         LOOP
      ENDIF
      @ 15,10 SAY 'PROCESSING... PLEASE WAIT FOR BEGINNING AND ENDING'
      @ 16,10 SAY 'PO NUMBERS TO DISPLAY.'
      @ 4,1 CLEAR TO 21,78
      
      MWAIT = '        '
      @ 10,10 SAY 'The FIRST po number used for that salesperson'
      @ 11,10 say 'equal or prior to the selected date is: ' + mpick_sale + '-' + MFIRST_NBR         
      @ 13,10 SAY 'The LAST po number used for that salesperson'
      @ 14,10 say 'equal or prior to the selected date is: ' + mpick_sale + '-' + MLAST_NBR          
      @ 16,10 say "Type 'CONTINUE' if you want to continue with"
      @ 17,10 say "this function or 'CANCEL' to return to menu " GET MWAIT PICTURE '@!'
      READ
      IF MWAIT <> 'CONTINUE'
         LOOP
      ENDIF
      MFIRST_NBR = VAL(MFIRST_NBR)             
      MLAST_NBR = VAL(MLAST_NBR)                                  
      @ 19,10 SAY 'THIS ARCHIVE PROCESS WILL TAKE AWHILE... PLEASE WAIT......'
      SELECT B
      USE POARCHVE EXCLUSIVE           
      DELETE ALL
      PACK
      INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO POARCHVE
      DO FOX_USE WITH "POARCHVE INDEX POARCHVE", .F.
      
      SELECT A
      DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP", .F.
      SET FILTER TO SHIP_DATE <= MDATE .AND. SALESMAN = MPICK_SALE
      GOTO TOP
      
      DO WHILE .NOT. EOF()
         
         MSALESMAN  = SALESMAN
         MPO_NBR    = PO_NBR
         MPO_SUFFIX = PO_SUFFIX
         MINV_NBR   = INV_NBR
         MSHIP_DATE = SHIP_DATE
         MBUYER_PO  = BUYER_PO
         MBBUYCODE  = BBUYCODE
         MSHIP_DATE = SHIP_DATE
         
         SELECT B
         DO FILELOCK
         APPEND BLANK
         REPLACE SALESMAN  WITH MSALESMAN
         REPLACE PO_NBR    WITH MPO_NBR
         REPLACE PO_SUFFIX WITH MPO_SUFFIX
         REPLACE SHIP_DATE WITH MSHIP_DATE
         UNLOCK
         
         ******** PO DETAILS
         SELECT C
         DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
            DO RECLOCK
            DELETE
            UNLOCK
            SKIP
         ENDDO
         
         ******** INVOICE HEADER RECORD 
         DO FOX_USE WITH "INV_HEAD INDEX INV_HEAD", .F.
         SEEK MINV_NBR  
         MDELETE = .T.
         DO WHILE .NOT. EOF() .AND. INV_NBR = MINV_NBR
            IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
               DO RECLOCK
               DELETE
               UNLOCK
            ENDIF
            SKIP
         ENDDO
         
         ******* CUSTOMER INVOICE RECORDS
         DO FOX_USE WITH "CUS_INV INDEX CUSIVNBR", .F.
         SEEK MINV_NBR 
         DO WHILE .NOT. EOF() .AND. INV_NBR = MINV_NBR
            IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
               DO RECLOCK
               DELETE
               UNLOCK
            ENDIF
            SKIP
         ENDDO
         
         ******* INVOICE ADJUSTMENT RECORDS
         DO FOX_USE WITH "INV_ADJ INDEX INV_ADJ", .F.
         SEEK MINV_NBR
         DO WHILE .NOT. EOF() .AND. INV_NBR = MINV_NBR
            IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
               DO RECLOCK
               DELETE
               UNLOCK
            ENDIF
            SKIP
         ENDDO
         
         ******* DAILY JOURNAL - SPREADSHEET
         DO FOX_USE WITH "DAILYJRN INDEX JRN_PO", .F.
         SEEK  MSALESMAN + MPO_NBR + MPO_SUFFIX
         DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
            DO RECLOCK
            DELETE
            UNLOCK
            SKIP
         ENDDO
         
         ******** CUSTOMER PURCHASE ORDER KEY FILE
         DO FOX_USE WITH "CUST_PO INDEX CUST_PO", .F.
         SEEK MBBUYCODE + MBUYER_PO
         IF .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX .AND. BBUYCODE = MBBUYCODE
            DO RECLOCK 
            DELETE
            UNLOCK
         ENDIF
         
         ********* SUPPLIER INVOICE FILE
         *DO FOX_USE WITH "SUP_INV", .F.
         *DO WHILE .NOT. EOF()
         *   IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
         *      DO RECLOCK
         *      DELETE 
         *      UNLOCK
         *   ENDIF
         *   SKIP
         *ENDDO
         ******* FREIGHT INVOICE FILE
         *DO FOX_USE WITH "FRT_INV", .F.
         *DO WHILE .NOT. EOF()
         *   IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
         *      DO RECLOCK
         *      DELETE 
         *      UNLOCK
         *   ENDIF
         *   SKIP
         *ENDDO
         ******* ITEM HISTORY FILE
         DO FOX_USE WITH "HIST_DTL INDEX HIST_DTL", .F.
         SEEK MSALESMAN+MPO_NBR+MPO_SUFFIX
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX 
            DO RECLOCK 
            DELETE
            UNLOCK
            SKIP
         ENDDO
         ******* INVOICE AND ADVISEMENT NOTE FILE
         DO FOX_USE WITH "PRT_NOTE INDEX PRT_NOTE", .F.
         SEEK MSALESMAN+MPO_NBR+MPO_SUFFIX
         IF .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX                            
            DO RECLOCK 
            DELETE
            UNLOCK
         ENDIF
         ******** MISCELLANEOUS CHARGE FILE
         *DO FOX_USE WITH "MISC_CHG INDEX MISC_CHG", .F.
         *IF .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX 
         *   DO RECLOCK 
         *   DELETE
         *   UNLOCK
         *ENDIF
         ******** NOTES FILE F1 SCREEN
         DO FOX_USE WITH "NOTES INDEX NOTES", .F.
         SEEK MSALESMAN+MPO_NBR+MPO_SUFFIX
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX 
            DO RECLOCK 
            DELETE
            UNLOCK
            SKIP
         ENDDO
         ******** SHIPED WITH PO FILE
         DO FOX_USE WITH "SHIPWITH INDEX SHIPWITH", .F.
         SEEK MSALESMAN+MPO_NBR+MPO_SUFFIX
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX 
            DO RECLOCK 
            DELETE
            UNLOCK
            SKIP
         ENDDO
         
         *** JUST GO AHEAD AND DELETE RECORDS OUT OF THE CHECK REGISTER
         *** IF THEY GO WITH THOSE RECORDS IN THE CHECK REGISTER FILE
         SELECT D
         DO FOX_USE WITH "CK_REG INDEX CK_REG", .F.
         SELECT C
         DO FOX_USE WITH "DISBJRN INDEX DISB_PO", .F.
         SEEK MSALESMAN+MPO_NBR+MPO_SUFFIX
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX 
            IF CTOD(JRNL_MO+'/'+JRNL_DAY+'/'+JRNL_YR) > MDATE
               SKIP 
               LOOP
            ENDIF
            DO RECLOCK 
            DELETE
            UNLOCK
            SELECT D
            SEEK C->CK_NBR
            DO WHILE .NOT. EOF() .AND. CK_NBR = C->CK_NBR
               IF SYS_DATE > MDATE
                  SKIP
                  LOOP
               ENDIF
               DO RECLOCK 
               DELETE
               UNLOCK
               SKIP
            ENDDO
            SELECT C
            SKIP
         ENDDO
         ****** PAYMENTS - CUSTOMER/MISCELLANEOUS RECEIPTS FILE
         DO FOX_USE WITH "PAYMENTS INDEX PAY_PO", .F.
         SEEK MSALESMAN+MPO_NBR+MPO_SUFFIX
         DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX 
            IF PAID_DATE > MDATE
               SKIP
               LOOP
            ENDIF
            DO RECLOCK 
            DELETE
            UNLOCK
            SKIP
         ENDDO
         ******* COMMISSIONS 3RD PARTY PAYMENT
         USE COMTHD INDEX COMTHD EXCLUSIVE
         DO WHILE .NOT. EOF()
            IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
               DELETE 
            ENDIF
            SKIP
         ENDDO
         ******* MANUAL SPREADSHEET FILE
         *USE SS INDEX SS_YRMO, SS EXCLUSIVE
         *DO WHILE .NOT. EOF()
         *   IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
         *      DELETE 
         *   ENDIF
         *   SKIP
         *ENDDO
         
         *** LAST BUT NOT LEAST, THE PO_HEADER RECORD
         SELECT A
         DO RECLOCK
         DELETE 
         UNLOCK
         SKIP
      ENDDO
      
      *** NOW COPY ALL DELETED RECORDS TO .ARC (ARCHIVE) FILES
      mdo_this = .f.
      if mdo_this
         SUSPEND
         
         USE DAILYJRN.ARC EXCLUSIVE
         DELETE ALL
         PACK
         USE INV_ADJ.ARC EXCLUSIVE
         DELETE ALL
         PACK
         USE MISC_CHG.ARC EXCLUSIVE
         DELETE ALL
         PACK
         USE NOTES.ARC EXCLUSIVE
         DELETE ALL
         PACK
         USE INV_HEAD.ARC EXCLUSIVE
         DELETE ALL
         PACK
         USE PO_DTL.ARC EXCLUSIVE
         DELETE ALL
         PACK
         USE PO_HEAD.ARC EXCLUSIVE
         DELETE ALL
         PACK
         USE CK_REG.ARC EXCLUSIVE
         DELETE ALL
         PACK
         USE PAYMENTS.ARC EXCLUSIVE
         DELETE ALL
         PACK
         USE DISBJRN.ARC EXCLUSIVE
         DELETE ALL
         PACK
         USE CUS_INV.ARC EXCLUSIVE
         DELETE ALL
         PACK
         USE SHIPWITH.ARC EXCLUSIVE
         DELETE ALL
         PACK
         
         USE DAILYJRN EXCLUSIVE
         COPY TO DAILYJRN.ARC FOR DELETED()
         
         USE INV_ADJ EXCLUSIVE
         COPY TO INV_ADJ.ARC FOR DELETED()
         
         USE MISC_CHG EXCLUSIVE
         COPY TO MISC_CHG.ARC FOR DELETED()
         
         USE NOTES EXCLUSIVE
         COPY TO NOTES.ARC FOR DELETED()
         
         USE INV_HEAD EXCLUSIVE
         COPY TO INV_HEAD.ARC FOR DELETED()
         
         USE PO_DTL EXCLUSIVE
         COPY TO PO_DTL.ARC FOR DELETED()
         
         USE PO_HEAD EXCLUSIVE
         COPY TO PO_HEAD.ARC FOR DELETED()
         
         USE CK_REG EXCLUSIVE
         COPY TO CK_REG.ARC FOR DELETED()
         
         USE PAYMENTS EXCLUSIVE
         COPY TO PAYMENTS.ARC FOR DELETED()
         
         USE DISBJRN EXCLUSIVE
         COPY TO DISBJRN.ARC FOR DELETED()
         
         USE CUS_INV EXCLUSIVE
         COPY TO CUS_INV.ARC FOR DELETED()

         USE SHIPWITH EXCLUSIVE
         COPY TO SHIPWITH.ARC FOR DELETED()

         CLOSE DATA
         
         ***** SUSPEND THIS
         SUSPEND
         
         
         ****** NOW READ BACK THRU TO SEE IF THERE ARE RECORDS THAT SHOULD
         ****** NOT BE IN THE FILE
         ***** FINISH THIS UP HERE....
         ***** PACK THE ORIGINAL FILES AND INDEX
         SELECT B
         DO FOX_USE WITH "POARCHVE INDEX POARCHVE", .F.
         SELECT A
         DO FOX_USE WITH "DAILYJRN.ARC", .F.
         MDELETE = .F.
         DO WHILE .NOT. EOF()
            SELECT B
            SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
            IF EOF()
               SELECT A
               DELETE
               MDELETE = .T.
            ELSE
               SELECT A
            ENDIF
            SKIP
         ENDDO
         
         IF MDELETE
            USE DAILYJRN.ARC EXCLUSIVE
            PACK
            USE
         ENDIF
         
         DO FOX_USE WITH "INV_ADJ.ARC", .F.
         MDELETE = .F.
         DO WHILE .NOT. EOF()
            SELECT B
            SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
            IF EOF()
               SELECT A
               DELETE
               MDELETE = .T.
            ELSE
               SELECT A
            ENDIF
            SKIP
         ENDDO
         IF MDELETE
            USE INV_ADJ.ARC EXCLUSIVE
            PACK
            USE
         ENDIF
         
         DO FOX_USE WITH "MISC_CHG.ARC", .F.
         MDELETE = .F.
         DO WHILE .NOT. EOF()
            SELECT B
            SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
            IF EOF()
               SELECT A
               DELETE
               MDELETE = .T.
            ELSE
               SELECT A
            ENDIF
            SKIP
         ENDDO
         IF MDELETE
            USE MISC_CHG.ARC EXCLUSIVE
            PACK
            USE
         ENDIF
         
         DO FOX_USE WITH "NOTES.ARC", .F.
         MDELETE = .F.
         DO WHILE .NOT. EOF()
            SELECT B
            SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
            IF EOF()
               SELECT A
               DELETE
               MDELETE = .T.
            ELSE
               SELECT A
            ENDIF
            SKIP
         ENDDO
         IF MDELETE
            USE NOTES.ARC EXCLUSIVE
            PACK
            USE
         ENDIF
         
         DO FOX_USE WITH "SHIPWITH.ARC", .F.
         MDELETE = .F.
         DO WHILE .NOT. EOF()
            SELECT B
            SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
            IF EOF()
               SELECT A
               DELETE
               MDELETE = .T.
            ELSE
               SELECT A
            ENDIF
            SKIP
         ENDDO
         IF MDELETE
            USE SHIPWITH.ARC EXCLUSIVE
            PACK
            USE
         ENDIF

         DO FOX_USE WITH "INV_HEAD.ARC", .F.
         MDELETE = .F.
         DO WHILE .NOT. EOF()
            SELECT B
            SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
            IF EOF()
               SELECT A
               DELETE
               MDELETE = .T.
            ELSE
               SELECT A
            ENDIF
            SKIP
         ENDDO
         IF MDELETE
            USE INV_HEAD.ARC EXCLUSIVE
            PACK
            USE
         ENDIF
         
         DO FOX_USE WITH "PO_DTL.ARC", .F.
         MDELETE = .F.
         DO WHILE .NOT. EOF()
            SELECT B
            SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
            IF EOF()
               SELECT A
               DELETE
               MDELETE = .T.
            ELSE
               SELECT A
            ENDIF
            SKIP
         ENDDO
         IF MDELETE
            USE PO_DTL.ARC EXCLUSIVE
            PACK
            USE
         ENDIF
         
         DO FOX_USE WITH "PO_HEAD.ARC", .F.
         MDELETE = .F.
         DO WHILE .NOT. EOF()
            SELECT B
            SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
            IF EOF()
               SELECT A
               DELETE
               MDELETE = .T.
            ELSE
               SELECT A
            ENDIF
            SKIP
         ENDDO
         IF MDELETE
            USE PO_HEAD.ARC EXCLUSIVE
            PACK
            USE
         ENDIF
         
         DO FOX_USE WITH "CK_REG.ARC", .F.
         MDELETE = .F.
         DO WHILE .NOT. EOF()
            SELECT B
            SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
            IF EOF()
               SELECT A
               DELETE
               MDELETE = .T.
            ELSE
               SELECT A
            ENDIF
            SKIP
         ENDDO
         IF MDELETE
            USE CK_REG.ARC EXCLUSIVE
            PACK
            USE
         ENDIF
         
         DO FOX_USE WITH "PAYMENTS.ARC", .F.
         MDELETE = .F.
         DO WHILE .NOT. EOF()
            SELECT B
            SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
            IF EOF()
               SELECT A
               DELETE
               MDELETE = .T.
            ELSE
               SELECT A
            ENDIF
            SKIP
         ENDDO
         IF MDELETE
            USE PAYMENTS.ARC EXCLUSIVE
            PACK
            USE
         ENDIF
         
         DO FOX_USE WITH "DISBJRN.ARC", .F.
         MDELETE = .F.
         DO WHILE .NOT. EOF()
            SELECT B
            SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
            IF EOF()
               SELECT A
               DELETE
               MDELETE = .T.
            ELSE
               SELECT A
            ENDIF
            SKIP
         ENDDO
         IF MDELETE
            USE DISBJRN.ARC EXCLUSIVE
            PACK
            USE
         ENDIF
         
         DO FOX_USE WITH "CUS_INV.ARC", .F.
         MDELETE = .F.
         DO WHILE .NOT. EOF()
            SELECT B
            SEEK A->SALESMAN+A->PO_NBR+A->PO_SUFFIX
            IF EOF()
               SELECT A
               DELETE
               MDELETE = .T.
            ELSE
               SELECT A
            ENDIF
            SKIP
         ENDDO
         IF MDELETE
            USE CUS_INV.ARC EXCLUSIVE
            PACK
            USE
         ENDIF
         
         CLOSE DATA
         
         *** THE NEXT STEP PROMPTS FOR BACKUP DISKETTES
         *** 
         MWAIT = ' '
         @ 4,1 CLEAR TO 21,78
         @ 10,10 SAY 'READY TO BACKUP ARCHIVED FILES TO DISKETTE!!'
         @ 11,10 SAY 'PLEASE PRESS RETURN TO CONTINUE... (FOLLOW ' 
         @ 12,10 SAY 'DISKETTE INSTRUCTIONS FROM PROMPT!) ' GET MWAIT 
         READ
         RUN BACKUP &MMASTDBF.*.ARC A:
         
         ** ALL DONE NOW - EXCEPT - BE SURE TO PACK AND REINDEX
         ** THOSE FILES WITH DELETED RECORDS
         MWAIT = ' '
         @ 4,1 CLEAR TO 21,78
         @ 10,10 SAY 'REINDEXING WITH PACK....'
         @ 11,10 SAY 'THIS WILL TAKE AWHILE .. MAKE SURE EVERYONE' 
         @ 12,10 SAY 'IS COMPLETELY OUT OF THE SYSTEM. '
         @ 13,10 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT 
         READ
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'PURCHASE ORDER HEADER FILE....'
         USE PO_HEAD EXCLUSIVE
         SET TALK ON 
         SET ECHO ON 
         SET STATUS ON 
         PACK
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO PO_HEAD
         INDEX ON INV_FLG TO PRINT
         INDEX ON  SUBSTR(DTOC(SHIP_DATE),7) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2) TO PO_SHIP
         INDEX ON RSUPCODE + SUP_REC + SUP_PD + PO_NBR + SUBSTR(DTOC(SHIP_DATE),7) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2) TO PO_SUP
         **INDEX ON FRT_CODE1 + FRT_REC + FRT_PD +  PO_NBR + SUBSTR(DTOC(SHIP_DATE),7) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2) TO PO_FRT
         INDEX ON FRT_CODE1 + FRT_REC + FRT_PD +  SUBSTR(DTOC(SHIP_DATE),7) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2) TO PO_FRT
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'PURCHASE ORDER ITEM FILE....'
         USE PO_DTL EXCLUSIVE
         SET TALK ON 
         SET ECHO ON 
         SET STATUS ON 
         PACK
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + ITEM_NBR TO PO_DTL 
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'ITEM HISTORY FILE....'
         USE HIST_DTL EXCLUSIVE
         SET TALK ON 
         SET ECHO ON 
         SET STATUS ON 
         PACK
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + ITEM_NBR + SUBSTR(DTOC(HIST_DATE),7) + SUBSTR(DTOC(HIST_DATE),1,2) + SUBSTR(DTOC(HIST_DATE),4,2) + HIST_TIME TO HIST_DTL 
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'INVOICE HEADER FILE....'
         USE INV_HEAD EXCLUSIVE
         SET TALK ON
         SET ECHO ON
         SET STATUS ON
         PACK
         INDEX ON INV_NBR TO INV_HEAD 
         INDEX ON  SUBSTR(DTOC(INV_DATE),7) + SUBSTR(DTOC(INV_DATE),1,2) + SUBSTR(DTOC(INV_DATE),4,2) TO INV_DATE
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'CUSTOMER INVOICE/PAYMENT FILE..'
         USE CUS_INV EXCLUSIVE
         SET TALK ON
         SET ECHO ON
         SET STATUS ON
         PACK
         INDEX ON BBUYCODE + PAID_FLG + INV_NBR  TO CUS_INV
         INDEX ON  PAID_FLG + BBUYCODE + SUBSTR(DTOC(INV_DATE),7) + SUBSTR(DTOC(INV_DATE),1,2) + SUBSTR(DTOC(INV_DATE),4,2) TO CUS_DATE
         INDEX ON INV_NBR + DEB_CRD TO CUSIVNBR
         INDEX ON SUBSTR(DTOC(SHIP_DATE),7) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2)  TO CUS_SHIP
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'INVOICE ADJUSTMENT FILE..'
         USE INV_ADJ EXCLUSIVE
         SET TALK ON
         SET ECHO ON
         SET STATUS ON
         PACK
         INDEX ON INV_NBR + SALESMAN + PO_NBR + PO_SUFFIX TO INV_ADJ 
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'RECEIPTS FILE..'
         USE PAYMENTS EXCLUSIVE
         SET TALK ON
         SET ECHO ON
         SET STATUS ON
         PACK
         INDEX ON  SUBSTR(DTOC(PAID_DATE),7) + SUBSTR(DTOC(PAID_DATE),1,2) + SUBSTR(DTOC(PAID_DATE),4,2) + SALESMAN  + BBUYCODE TO PAY_DATE
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + SUBSTR(DTOC(PAID_DATE),7) + SUBSTR(DTOC(PAID_DATE),1,2) + SUBSTR(DTOC(PAID_DATE),4,2) TO PAY_PO
         INDEX ON  SUBSTR(DTOC(SYS_DATE),7) + SUBSTR(DTOC(SYS_DATE),1,2) + SUBSTR(DTOC(SYS_DATE),4,2) + SALESMAN + BBUYCODE TO PAY_CUST
         INDEX ON BBUYCODE + STR(CTOD('12/31/2099') - SYS_DATE,10) TO PAY_SYS 
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'DAILY JOURNAL FILE (SPREADSHEET)....'
         USE DAILYJRN EXCLUSIVE
         SET TALK ON
         SET ECHO ON
         SET STATUS ON
         PACK
         INDEX ON TRAN_YR + TRAN_MO + POST_FLG + INV_COR + INV_NBR TO JRN_MO    
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + POST_FLG + INV_COR + SEQ TO JRN_PO
         INDEX ON SUBSTR(DTOC(JRNL_DATE),7) + SUBSTR(DTOC(JRNL_DATE),1,2) + SUBSTR(DTOC(JRNL_DATE),4,2) + INV_NBR TO JRN_TRAN
         INDEX ON POST_FLG + INV_COR  + SUBSTR(DTOC(TRAN_DATE),7) + SUBSTR(DTOC(TRAN_DATE),1,2) + SUBSTR(DTOC(TRAN_DATE),4,2) + INV_NBR TO POSTED  
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'DISBURSEMENTS JOURNAL FILE..'
         USE DISBJRN EXCLUSIVE
         SET TALK ON
         SET ECHO ON
         SET STATUS ON
         PACK
         INDEX ON JRNL_YR + JRNL_MO + JRNL_DAY + CK_NBR TO DISBJRN 
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + ACCT_TYPE + CATEGORY1 TO DISB_PO
         INDEX ON ACCT_TYPE + ACCT_NBR + BILL_INV TO DISBINV
         INDEX ON ACCT_TYPE + ACCT_NBR + STR(VAL(BILL_INV),12) TO DISBSTR
         INDEX ON ACCT_TYPE + ACCT_NBR + STR(CTOD('12/31/2099') - CTOD(JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR),10) TO DISBINQ
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'CHECK REGISTER FILE..'
         USE CK_REG EXCLUSIVE
         SET TALK ON
         SET ECHO ON
         SET STATUS ON
         PACK
         INDEX ON CK_NBR TO CK_REG
         INDEX ON SUBSTR(DTOC(CK_DATE),7) + SUBSTR(DTOC(CK_DATE),1,2) + SUBSTR(DTOC(CK_DATE),4,2) + CK_NBR TO CK_DATE
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'PURCHASE ORDER NOTES FILE..'
         USE NOTES EXCLUSIVE
         SET TALK ON
         SET ECHO ON
         SET STATUS ON
         PACK
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + SEQ TO NOTES
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'SHIPPED WITH PO FILE.......'
         USE SHIPWITH EXCLUSIVE
         SET TALK ON
         SET ECHO ON
         SET STATUS ON
         PACK
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO SHIPWITH
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF

         @ 17,01 SAY SPACE(78)
         @ 17,20 SAY 'ADVISEMENT/INVOICE COMMENTS FILE..'
         USE PRT_NOTE EXCLUSIVE
         SET TALK ON
         SET ECHO ON
         SET STATUS ON
         PACK
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO PRT_NOTE
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'CUSTOMER PO NUMBER FILE..'
         USE CUST_PO EXCLUSIVE
         PACK
         INDEX ON BBUYCODE + BUYER_PO TO CUST_PO
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF 
         
         @ 17,01 SAY SPACE(78)  
         @ 17,20 SAY 'SS MANUAL SPREADSHEET....'
         USE SS EXCLUSIVE
         PACK
         INDEX ON SUBSTR(DTOC(INV_DATE),7) + SUBSTR(DTOC(INV_DATE),1,2) + SUBSTR(DTOC(INV_DATE),4,2) TO SS
         INDEX ON TRAN_YR+TRAN_MO+SALESMAN+PO_NBR+PO_SUFFIX TO SS_YRMO
         UNLOCK
         SET TALK OFF
         SET ECHO OFF
         SET STATUS OFF 
      ENDIF
      CLOSE DATA
      
      
   CASE MSELECT2 = '4'
      * CLEAR
      * RUN FORMAT A:
      * WAIT
      
      MTITLE = ' - CONVERT SUPPLIER/CUSTOMER' 
      
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      STORE ' ' TO MCHOICE
      SET CONFIRM ON
      @ 10,5 SAY 'Do you want to convert Suppliers (S) or Customers (C)? ' get mchoice picture '@!'
      READ
      SET CONFIRM OFF
      IF MCHOICE <> 'S' .AND. MCHOICE <> 'C'
         LOOP   
      ENDIF
      IF MCHOICE = 'S'
         STORE 'SUPPLIER' TO MWORD
      ELSE
         STORE 'CUSTOMER' TO MWORD
      ENDIF
      @ 10,1 CLEAR TO 10,78
      @ 10,5 SAY 'The next screen will prompt you for the ' + mword + ' you want to convert FROM.' 
      STORE ' ' TO MWAIT
      @ 12,5 say 'Press "Enter" to continue with your selection ' get mwait
      READ
      MNAME_FD = .F.
      DO CASE
      CASE MCHOICE = 'S'
         DO RSUPSEL3
      OTHERWISE
         DO BBUYSEL3
      ENDCASE
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      IF .NOT. MNAME_FD
         @ 15,5 SAY 'No FROM ' + mword + ' selected - press enter to return to menu'
         LOOP  
      ENDIF
      IF MCHOICE = 'S'
         STORE RSUPCODE TO MCODE    
      ELSE
         STORE BBUYCODE TO MCODE
      ENDIF
      STORE NAME TO MOLD_NAME
      STORE STREET TO MOLD_STRT
      STORE CITY   TO MOLD_CITY
      STORE STATE  TO MOLD_STATE
      STORE ZIP    TO MOLD_ZIP
      STORE ACTIVE TO MOLD_ACT
      
      @ 10,5 SAY 'The next screen will prompt you for the ' + mword + ' you want to convert TO.' 
      STORE ' ' TO MWAIT
      @ 12,5 say 'Press "Enter" to continue with your selection ' get mwait
      READ
      MNAME_FD = .F.
      DO CASE
      CASE MCHOICE = 'S'
         DO RSUPSEL3
      OTHERWISE
         DO BBUYSEL3
      ENDCASE
      CLEAR
      @  1, 1  SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      IF .NOT. MNAME_FD
         @ 15,5 SAY 'No TO ' + mword + ' selected - press enter to return to menu'
         LOOP   
      ENDIF
      IF MCHOICE = 'S'
         STORE RSUPCODE TO MNEW_CODE    
      ELSE
         STORE BBUYCODE TO MNEW_CODE
      ENDIF
      STORE LED_CODE TO MLED_CODE
      STORE NAME     TO MNEW_NAME
      STORE STREET TO MNEW_STRT
      STORE CITY   TO MNEW_CITY
      STORE STATE  TO MNEW_STATE
      STORE ZIP    TO MNEW_ZIP
      STORE ACTIVE TO MNEW_ACT
      @ 5,5 SAY MWORD + ' CONVERTING FROM:'
      @ 6,7 SAY MOLD_NAME 
      IF MOLD_ACT <> ' ' 
         @ 6,44 SAY '(' + MOLD_ACT + ')'
      ENDIF
      @ 7,7 SAY MOLD_STRT
      @ 8,7 SAY TRIM(MOLD_CITY) + ', ' + MOLD_STATE + '  ' + MOLD_ZIP
      @ 9,7 SAY 'Old Code: ' + mcode
      
      @ 12,5 SAY MWORD + ' CONVERTING TO:'
      @ 13,7 SAY MNEW_NAME 
      IF MNEW_ACT <> ' ' 
         @ 6,44 SAY '(' + MNEW_ACT + ')'
      ENDIF
      @ 14,7 SAY MNEW_STRT
      @ 15,7 SAY TRIM(MNEW_CITY) + ', ' + MNEW_STATE + '  ' + MNEW_ZIP
      @ 16,7 SAY 'New Code: ' + MNEW_CODE + space(5) + 'New Ledger Code: ' + mled_code
      STORE SPACE(8) TO MWAIT
      @ 19,5 SAY 'Key in "CONTINUE" if you are ready to proceed with the above '
      @ 20,5 say 'conversion.  If you have selected incorrectly, key in "CANCEL". ' GET MWAIT PICTURE '@!'
      SET CONFIRM ON
      READ
      SET CONFIRM OFF
      IF MWAIT <> 'CONTINUE'
         LOOP
      ENDIF
      @ 19,1 CLEAR TO 20,78
      @ 19,5 SAY 'CONVERTING......PLEASE WAIT...'
      DO CASE
      CASE MCHOICE = 'S'
         SELECT C
         DO FOX_USE WITH "PURCHJRN", .F.
         DO FILELOCK
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO TMPJRN
         DO FOX_USE WITH "PURCHJRN INDEX TMPJRN", .F.
         DO FILELOCK
         
         SELECT D
         DO FOX_USE WITH "SUPLED", .F.
         DO FILELOCK
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO TMPLED
         DO FOX_USE WITH "SUPLED INDEX TMPLED, SUPLED, SUPMATCH", .F.
         DO FILELOCK
      OTHERWISE
         SELECT C
         DO FOX_USE WITH "SALESJRN", .F.
         DO FILELOCK
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO TMPJRN
         DO FOX_USE WITH "SALESJRN INDEX TMPJRN", .F.
         DO FILELOCK
         
         SELECT D
         DO FOX_USE WITH "CUSLED", .F.
         DO FILELOCK
         INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO TMPLED
         DO FOX_USE WITH "CUSLED INDEX TMPLED, CUSLED, CUSMATCH", .F.
         DO FILELOCK
      ENDCASE
      
      SELECT A 
      DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PO_SUP", .F.
      
      DO WHILE .NOT. EOF()
         MUPDATE = .F.
         IF MCHOICE = 'S'
            IF RSUPCODE = MCODE
               DO FILELOCK
               ** ? SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX + SPACE(5) + RSUPCODE + SPACE(5) + MNEW_CODE
               REPLACE RSUPCODE WITH MNEW_CODE
               UNLOCK
               MUPDATE = .T.
            ENDIF
         ELSE
            IF BBUYCODE = MCODE
               DO FILELOCK
               ** ? SALESMAN + '-' + PO_NBR + '-' + PO_SUFFIX + SPACE(5) + BBUYCODE + SPACE(5) + MNEW_CODE
               REPLACE BBUYCODE WITH MNEW_CODE
               UNLOCK
               MUPDATE = .T.
            ENDIF
         ENDIF
         DO CASE    
         CASE MUPDATE
            SELECT B
            DO FOX_USE WITH "DAILYJRN INDEX JRN_PO", .F.
            SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
            DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR .AND. PO_SUFFIX = A->PO_SUFFIX
               DO FILELOCK
               IF MCHOICE = 'S'
                  REPLACE RSUPCODE WITH A->RSUPCODE
               ELSE
                  REPLACE BBUYCODE WITH A->BBUYCODE
               ENDIF
               UNLOCK
               SKIP
            ENDDO
            IF MCHOICE = 'S'
               DO FOX_USE WITH "DISBJRN INDEX DISB_PO, DISBINV, DISBSTR, DISBINQ", .F.
               SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
               STORE SPACE(6) TO MCK_NBR
               DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR .AND. PO_SUFFIX = A->PO_SUFFIX
                  IF ACCT_TYPE = 'S'
                     DO FILELOCK
                     REPLACE ACCT_NBR WITH A->RSUPCODE
                     UNLOCK
                     IF CK_NBR <> MCK_NBR
                        STORE CK_NBR TO MCK_NBR
                        SELECT E
                        DO FOX_USE WITH "CK_REG INDEX CK_REG", .F.
                        SEEK MCK_NBR
                        DO WHILE .NOT. EOF() .AND. CK_NBR = MCK_NBR
                           IF PAY_TYPE = 'S'
                              DO FILELOCK
                              REPLACE PAY_CODE WITH A->RSUPCODE
                              UNLOCK
                           ENDIF
                           SKIP
                        ENDDO
                     ENDIF
                  ENDIF
                  SELECT B
                  SKIP
               ENDDO
               STORE 0 TO MREC1, MREC2, MREC3, MREC4
               DO FOX_USE WITH "SUP_INV", .F.
               MI = 1
               DO WHILE .NOT. EOF()
                  IF SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR .AND. PO_SUFFIX = A->PO_SUFFIX
                     DO CASE
                     CASE MI = 1
                        STORE RECNO() TO MREC1
                        MI = MI + 1
                     CASE MI = 2
                        STORE RECNO() TO MREC2
                        MI = MI + 1
                     CASE MI = 3
                        STORE RECNO() TO MREC3
                        MI = MI + 1
                     CASE MI = 4
                        STORE RECNO() TO MREC4
                        MI = MI + 1
                     ENDCASE
                  ENDIF
                  SKIP
               ENDDO
               DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
               IF MREC1 <> 0
                  GOTO MREC1
                  DO FILELOCK
                  REPLACE RSUPCODE WITH A->RSUPCODE
                  UNLOCK
               ENDIF
               IF MREC2 <> 0
                  GOTO MREC2
                  DO FILELOCK
                  REPLACE RSUPCODE WITH A->RSUPCODE
                  UNLOCK
               ENDIF
               IF MREC3 <> 0
                  GOTO MREC3
                  DO FILELOCK
                  REPLACE RSUPCODE WITH A->RSUPCODE
                  UNLOCK
               ENDIF
               IF MREC4 <> 0
                  GOTO MREC4
                  DO FILELOCK
                  REPLACE RSUPCODE WITH A->RSUPCODE
                  UNLOCK
               ENDIF
               *** PURCHASE JOURNAL
               SELECT C
               SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
               DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR .AND. PO_SUFFIX = A->PO_SUFFIX
                  REPLACE RSUPCODE WITH A->RSUPCODE
                  SKIP
               ENDDO
               *** SUPPLIER LEDGER
               SELECT D
               SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
               DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR .AND. PO_SUFFIX = A->PO_SUFFIX
                  REPLACE RSUPCODE WITH A->RSUPCODE
                  REPLACE LED_CODE WITH MLED_CODE
                  SKIP
               ENDDO
            ELSE
               DO FOX_USE WITH "PAYMENTS INDEX PAY_PO, PAY_CUST, PAY_SYS", .F.
               SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
               DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR .AND. PO_SUFFIX = A->PO_SUFFIX
                  IF ACCOUNT = SPACE(4)
                     DO FILELOCK
                     REPLACE BBUYCODE WITH A->BBUYCODE
                     UNLOCK
                  ENDIF
                  SKIP
               ENDDO
               IF A->INV_NBR <> SPACE(5)
                  DO FOX_USE WITH "CUS_INV INDEX CUSIVNBR, CUS_INV, CUS_DATE, CUS_SHIP", .F.
                  SEEK A->INV_NBR
                  DO WHILE .NOT. EOF() .AND. INV_NBR = A->INV_NBR
                     DO FILELOCK
                     *** IF ACCOUNTS RECV. CREDIT ACCOUNT - CONVERT ORIG_BBUY CODE
                     IF BBUYCODE = 'CRED'
                        REPLACE ORIG_BBUY WITH A->BBUYCODE
                     ELSE
                        REPLACE BBUYCODE WITH A->BBUYCODE
                     ENDIF
                     UNLOCK
                     SKIP
                  ENDDO
               ENDIF
               DO FOX_USE WITH "CUST_PO INDEX CUST_PO", .F.
               SEEK MCODE + A->CUST_PO
               IF .NOT. EOF()
                  DO FILELOCK
                  REPLACE BBUYCODE WITH A->BBUYCODE
                  UNLOCK
               ENDIF
               *** SALES JOURNAL FILE
               SELECT C
               SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
               DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR .AND. PO_SUFFIX = A->PO_SUFFIX
                  REPLACE BBUYCODE WITH A->BBUYCODE
                  SKIP
               ENDDO
               *** SALES LEDGER FILE
               SELECT D
               SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
               DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR .AND. PO_SUFFIX = A->PO_SUFFIX
                  REPLACE BBUYCODE WITH A->BBUYCODE
                  REPLACE LED_CODE WITH MLED_CODE
                  SKIP
               ENDDO
            ENDIF
         ENDCASE 
         SELECT A
         SKIP
      ENDDO
      
      UNLOCK ALL
      RUN DEL TMPJRN.IDX
      RUN DEL TMPLED.IDX
      CLOSE DATA
      RETURN
      
      
      
      
      
      
   CASE MSELECT2 = '5'
      MNEXT_CUST = .T.
      
      DO WHILE MNEXT_CUST
         MNAME_FD = .F.
         STORE SPACE(32) TO MNAME
         DO RSUPSEL3
         IF .NOT. MNAME_FD 
            MNEXT_CUST = .F.
            LOOP
         ENDIF
         STORE RSUPCODE TO MRSUPCODE
         STORE NAME TO MNAME
         STORE CITY TO MCITY
         STORE STATE TO MSTATE
         SET PROC TO REC_PROC
         MTOTAL = 0
         MTITLE = ' - RELEASE SUPPLIER UNDERBILLING FROM PAYMENT HOLD'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 25,79
         DO APRV_SF
         SELECT D
         DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
         SELECT B
         DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
         
         SELECT C
         DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
         SEEK MRSUPCODE
         MINV = .F.  
         IF .NOT. EOF()
            STORE RECNO() TO MRECNO
         ELSE
            STORE 0 TO MRECNO
         ENDIF
         DO WHILE .NOT. EOF() .AND. RSUPCODE = MRSUPCODE .AND. .NOT. MINV
            IF ADDL_DUE <> ' ' .OR. HOLD_FLG = 'H'
               MINV = .T.
            ENDIF
            SKIP
         ENDDO
         IF .NOT. MINV
            @ 10,5 SAY 'THERE ARE NO INVOICES ON HOLD FOR THIS SUPPLIER.'
            STORE ' ' TO MWAIT
            @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
            READ
            RETURN
         ENDIF
         GOTO MRECNO
         STORE MRECNO TO MFST_REC
         MPAGE_TOT = 0   
         MMORE = .T.
         DO WHILE MMORE
            STORE ' ' TO MSELECT
            STORE 0 TO MUPDRCD, MADJUST
            GOTO MRECNO
            MLINE = 08
            @ 08,1 CLEAR TO 22,78
            @ 24,0 CLEAR
            DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. MRSUPCODE = RSUPCODE                     
               IF ADDL_DUE = ' ' .AND. HOLD_FLG <> 'H'
                  SKIP
                  LOOP
               ENDIF
               I = MLINE - 7 
               STORE RECNO() TO MUPDRCD(I)
               STORE DUE_DATE TO MDUE_DATE    
               IF SUP_INV = SPACE(12)
                  STORE SUBSTR(REASON,1,12) TO MINV_NBR
               ELSE
                  STORE SUP_INV TO MINV_NBR
               ENDIF
               STORE 0 TO MADJ
               SELECT C
               MDUE(I) = AMT_DUE + MADJ
               
               DO APRV_SR1
               SKIP
               MLINE = MLINE + 1
            ENDDO
            MMAX_LINE = MLINE - 1
            STORE RECNO() TO MRECNO
            MINV = .F.
            DO WHILE .NOT. EOF() .AND. RSUPCODE = MRSUPCODE .AND. .NOT. MINV
               IF ADDL_DUE <> ' ' .OR. HOLD_FLG = 'H'
                  MINV = .T.
                  STORE RECNO() TO MRECNO
                  LOOP
               ENDIF
               SKIP
            ENDDO
            IF MINV
               @ 24,70 SAY "More PO's"
               MBLURP = .T.
            ELSE
               @ 24,70 to 24,78
               MBLURP = .F.
            ENDIF
            STORE 2 TO MACTION
            DO WHILE MACTION = 2
               MLINE = 8
               I = 1
               DO WHILE MLINE <= MMAX_LINE
                  @ MLINE,5 GET MSELECT(I) PICTURE '@!'
                  MLINE = MLINE + 1
                  I = I + 1
               ENDDO
               STORE 1 TO MACTION
               @ 24,01 SAY 'Action: ' + STR(MACTION,1)
               IF MBLURP
                  @ 24,13 SAY '1. Save & Return    2. Edit    3. Next Page    4. Cancel'    
               ELSE
                  @ 24,13 SAY '1. Save & Return    2. Edit    3. Cancel'    
               ENDIF
               
               READ
               IF MBLURP
                  @24,09 GET MACTION PICTURE '9' RANGE 1,4
               ELSE
                  @24,09 GET MACTION PICTURE '9' RANGE 1,3
               ENDIF
               READ               
            ENDDO          
            
            IF .NOT. MBLURP  .AND. MACTION = 3
               MACTION = 4
            ENDIF
            IF MACTION = 4
               MMORE = .F.
               @ 04,1 CLEAR TO 22,78
               @ 24,0 CLEAR
               STORE ' ' TO MYES_NO
               @ 10,5 SAY 'DO YOU WANT TO RELEASE FOR ANOTHER SUPPLIER (Y/N)? ' GET MYES_NO PICTURE '@!'
               READ
               IF MYES_NO <> 'Y'
                  MNEXT_CUST = .F.
               ELSE
                  MPAGE_TOT = 0
               ENDIF
               LOOP
            ENDIF
            
            I = 1 
            DO WHILE I <= 15
               IF MUPDRCD(I) = 0 .OR. MSELECT(I) <> 'X' 
                  I = I + 1
                  LOOP
               ENDIF
               GOTO MUPDRCD(I)
               DO RECLOCK
               IF ADDL_DUE <> ' '
                  REPLACE ADDL_DUE WITH ' '
               ELSE
                  IF HOLD_FLG = 'H'
                     REPLACE HOLD_FLG WITH ' '
                  ENDIF
               ENDIF
               UNLOCK 
               I = I + 1
            ENDDO
            
            IF MACTION <> 3
               MMORE = .F.
               @ 04,1 CLEAR TO 22,78
               @ 24,0 CLEAR
               STORE ' ' TO MYES_NO
               @ 10,5 SAY 'DO YOU WANT TO SELECT ANOTHER SUPPLIER (Y/N)? ' GET MYES_NO PICTURE '@!'
               READ
               IF MYES_NO <> 'Y'
                  MNEXT_CUST = .F.
               ENDIF
            ENDIF
         ENDDO
      ENDDO
   CASE MSELECT2 = '6'
      MTITLE = ' - MARK SUPPLIER/CUSTOMER ACCOUNTS FOR LEDGER CONSOLIDATION'
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 25,79
      MCHOICE = ' '
      @ 10,5 SAY 'Consolidate Suppliers (S) - Customers (C) - Billbacks (B) ? ' GET MCHOICE PICTURE '@!'
      READ
      DO CASE
      CASE MCHOICE = 'S'
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
         
         MNOT_DONE = .T.
         MTITLE = ' - MARK SUPPLIER ACCOUNTS FOR LEDGER CONSOLIDATION'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 25,79
         DO WHILE MNOT_DONE   
            STORE 0 TO MRSUPCODE, MLED_CODE
            STORE 2 TO MACTION
            DO WHILE MACTION = 2
               @ 4,1 CLEAR TO 21,78
               @ 10,1 SAY '             SUPPLIER CODE: ' 
               @ 10,31 GET MRSUPCODE PICTURE '####'
               @ 24,1 SAY 'Action: 1'
               @ 24,13 say '1. Continue      2. Edit       3. Cancel'
               STORE 1 TO MACTION
               @ 24,9 GET MACTION PICTURE '#' RANGE 1,3
               READ
            ENDDO
            
            IF MACTION = 3 .OR. MRSUPCODE = 0
               MNOT_DONE = .F.
               LOOP
            ENDIF
            SEEK STR(MRSUPCODE,4)
            IF EOF()
               @ 24,0 CLEAR
               MWAIT = ' '
               @ 24,0 SAY 'SUPPLIER CODE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
               READ
               LOOP
            ENDIF
            @ 5,31 SAY NAME
            @ 6,31 SAY STREET
            @ 7,31 SAY TRIM(CITY) + ', ' + STATE + '  ' + ZIP
            STORE RECNO() TO MRECNO
            IF LED_CODE = SPACE(4)
               STORE VAL(RSUPCODE) TO MLED_CODE
            ELSE
               STORE VAL(LED_CODE) TO MLED_CODE
            ENDIF
            STORE 2 TO MACTION 
            DO WHILE MACTION = 2
               @ 13,1 SAY 'CONSOLIDATION ACCOUNT CODE: '
               @ 13,31 GET MLED_CODE PICTURE '####'
               @ 24,1 SAY 'Action: 1'
               @ 24,13 say '1. Continue      2. Edit       3. Cancel'
               READ
               IF MLED_CODE <> 0
                  SEEK STR(MLED_CODE,4)
                  IF EOF()
                     @ 24,0 CLEAR
                     MWAIT = ' '
                     @ 24,0 SAY 'LEDGER ACCOUNT CODE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
                     READ
                     @ 24,0 CLEAR
                     LOOP
                  ELSE
                     @ 17,31 SAY NAME
                     @ 18,31 SAY STREET
                     @ 19,31 SAY TRIM(CITY) + ', ' + STATE + '  ' + ZIP
                  ENDIF
               ENDIF
               
               STORE 1 TO MACTION
               @ 24,9 GET MACTION PICTURE '#' RANGE 1,3
               READ
            ENDDO
            IF MACTION = 3 
               MNOT_DONE = .F.
               LOOP
            ENDIF
            GOTO MRECNO
            DO RECLOCK
            REPLACE LED_CODE WITH STR(MLED_CODE,4)
            UNLOCK
         ENDDO
      CASE MCHOICE = 'C'
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         
         MNOT_DONE = .T.
         MTITLE = ' - MARK CUSTOMER ACCOUNTS FOR LEDGER CONSOLIDATION'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 25,79
         DO WHILE MNOT_DONE   
            STORE 0 TO MBBUYCODE, MLED_CODE
            STORE 2 TO MACTION
            DO WHILE MACTION = 2
               @ 4,1 CLEAR TO 21,78
               @ 10,1 SAY '             CUSTOMER CODE: ' 
               @ 10,31 GET MBBUYCODE PICTURE '####'
               @ 24,1 SAY 'Action: 1'
               @ 24,13 say '1. Continue      2. Edit       3. Cancel'
               STORE 1 TO MACTION
               @ 24,9 GET MACTION PICTURE '#' RANGE 1,3
               READ
            ENDDO
            
            IF MACTION = 3 .OR. MBBUYCODE = 0
               MNOT_DONE = .F.
               LOOP
            ENDIF
            SEEK STR(MBBUYCODE,4)
            IF EOF()
               @ 24,0 CLEAR
               MWAIT = ' '
               @ 24,0 SAY 'CUSTOMER CODE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
               READ
               LOOP
            ENDIF
            @ 5,31 SAY NAME
            @ 6,31 SAY STREET
            @ 7,31 SAY TRIM(CITY) + ', ' + STATE + '  ' + ZIP
            STORE RECNO() TO MRECNO
            IF LED_CODE = SPACE(4)
               STORE VAL(bbuycode) TO MLED_CODE
            ELSE
               STORE VAL(LED_CODE) TO MLED_CODE
            ENDIF
            STORE 2 TO MACTION 
            DO WHILE MACTION = 2
               @ 13,1 SAY 'CONSOLIDATION ACCOUNT CODE: '
               @ 13,31 GET MLED_CODE PICTURE '####'
               @ 24,1 SAY 'Action: 1'
               @ 24,13 say '1. Continue      2. Edit       3. Cancel'
               IF MLED_CODE <> 0
                  SEEK STR(MLED_CODE,4)
                  IF EOF()
                     @ 24,0 CLEAR
                     MWAIT = ' '
                     @ 24,0 SAY 'LEDGER ACCOUNT CODE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
                     READ
                     @ 24,0 CLEAR
                     LOOP
                  ELSE
                     @ 17,31 SAY NAME
                     @ 18,31 SAY STREET
                     @ 19,31 SAY TRIM(CITY) + ', ' + STATE + '  ' + ZIP
                  ENDIF
               ENDIF
               STORE 1 TO MACTION
               @ 24,9 GET MACTION PICTURE '#' RANGE 1,3
               READ
            ENDDO
            IF MACTION = 3 
               MNOT_DONE = .F.
               LOOP
            ENDIF
            GOTO MRECNO
            DO RECLOCK
            REPLACE LED_CODE WITH STR(MLED_CODE,4)
            UNLOCK
         ENDDO
         
      CASE MCHOICE = 'B'
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_CODE", .F.
         
         MNOT_DONE = .T.
         MTITLE = ' - UPDATE BILLBACK ACCOUNTS FOR LEDGER CONSOLIDATION'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 25,79
         DO WHILE MNOT_DONE   
            STORE '  ' TO MCOM_CODE, MLED_CODE
            STORE 2 TO MACTION
            DO WHILE MACTION = 2
               @ 4,1 CLEAR TO 21,78
               @ 10,1 SAY '               BILLBACK CODE: ' 
               @ 10,33 GET MCOM_CODE PICTURE '@!'
               @ 24,1 SAY 'Action: 1'
               @ 24,13 say '1. Continue      2. Edit       3. Cancel'
               STORE 1 TO MACTION
               @ 24,9 GET MACTION PICTURE '#' RANGE 1,3
               READ
            ENDDO
            
            IF MACTION = 3 .OR. MCOM_CODE = SPACE(2)
               MNOT_DONE = .F.
               LOOP
            ENDIF
            SEEK MCOM_CODE
            IF EOF()
               @ 24,0 CLEAR
               MWAIT = ' '
               @ 24,0 SAY 'BILLBACK CODE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
               READ
               LOOP
            ENDIF
            @ 5,31 SAY NAME
            @ 6,31 SAY STREET
            @ 7,31 SAY TRIM(CITY) + ', ' + STATE + '  ' + ZIP
            STORE RECNO() TO MRECNO
            IF LED_CODE = SPACE(2)
               STORE COM_CODE TO MLED_CODE
            ELSE
               STORE LED_CODE TO MLED_CODE
            ENDIF
            STORE 2 TO MACTION 
            DO WHILE MACTION = 2
               @ 13,1 SAY 'CONSOLIDATE TO BILLBACK CODE: '
               @ 13,33 GET MLED_CODE PICTURE '@!'
               @ 24,1 SAY 'Action: 1'
               @ 24,13 say '1. Continue      2. Edit       3. Cancel'
               READ
               IF MLED_CODE <> SPACE(2)
                  SEEK MLED_CODE
                  IF EOF()
                     @ 24,0 CLEAR
                     MWAIT = ' '
                     @ 24,0 SAY 'LEDGER ACCOUNT CODE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
                     READ
                     @ 24,0 CLEAR
                     LOOP
                  ELSE
                     @ 17,31 SAY NAME
                     @ 18,31 SAY STREET
                     @ 19,31 SAY TRIM(CITY) + ', ' + STATE + '  ' + ZIP
                  ENDIF
               ENDIF
               
               STORE 1 TO MACTION
               @ 24,9 GET MACTION PICTURE '#' RANGE 1,3
               READ
            ENDDO
            IF MACTION = 3 
               MNOT_DONE = .F.
               LOOP
            ENDIF
            GOTO MRECNO
            DO RECLOCK
            REPLACE LED_CODE WITH MLED_CODE
            UNLOCK
         ENDDO
      ENDCASE
      
   CASE MSELECT2 = '7'
      @ 4,1 CLEAR TO 23,78
      STORE SPACE(2)    TO MSALESMAN, MTRAN_MO
      STORE SPACE(4) TO  MTRAN_YR
      STORE SPACE(4)    TO MPO_NBR
      STORE SPACE(1)    TO MPO_SUFFIX
      SELECT B
      DO FOX_USE WITH "SS INDEX SS_YRMO, SS", .F.
      MPO_FD = .F.
      STORE 1 TO MACTION
      MPO_SEL = .T.
      DO WHILE MPO_SEL
         
         CLEAR 
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         MTITLE = ' - SELECT PURCHASE ORDER'
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         @ 08, 5 SAY '      Business Month:'
         @ 08,28 GET MTRAN_MO PICTURE '##'
         @ 10, 5 say '       Business Year:'
         @ 10,28 GET MTRAN_YR PICTURE '####'
         @ 12,5 say  '           PO Number:'
         @ 12, 28 GET Msalesman PICTURE '##'
         @ 12,30 say '-'
         @ 12,31 get mpo_nbr picture '####'
         @ 12,35 say '-'
         @ 12,36 get mpo_suffix picture '@!'
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
         @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         
         IF MACTION = 2
            LOOP
         ENDIF
         
         IF MACTION = 3 .OR. PO_NBR = SPACE(4)
            MPO_SEL = .F.
         ENDIF
         
         SELECT B
         SEEK MTRAN_YR + MTRAN_MO + MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF EOF() .OR. DELETED()
            @ 24,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'PURCHASE ORDER NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
            READ
            LOOP
         ENDIF
         STORE RECNO() TO MRECNO
         SKIP
         IF TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
            @ 24,0 CLEAR
            MCONT = ' '
            DO WHILE MCONT <> 'C'
               @ 24,10 SAY 'WARNING - DUPLICATES ON FILE.. ENTER A "C" TO CONTINUE ' GET MCONT
               READ
            ENDDO
            @ 24,0 CLEAR
         ENDIF
         GOTO MRECNO
         STORE SHIP_DATE TO MSHIP_DATE
         STORE POST_FLG TO MPOST_FLG
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            @ 14,5 SAY  '  New Business Month:'
            @ 14, 28 GET MTRAN_MO PICTURE '##'
            @ 16,5 SAY  '   New Business Year:'
            @ 16, 28 GET MTRAN_YR picture '####'
            @ 18,5 say '        New Ship Date: '
            @ 18,28 GET MSHIP_DATE
            @ 20,5 SAY '        New Post Fla&MMASTDBF. '    
            @ 20,28 get mpost_flg picture '@!'
            @ 21,5 say '(Note: Post Flag must be a blank or a "P")'
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
            @ 24,13 SAY '1. Continue    2. Edit     3. Finished    4. Delete Entry'                  
            
            READ
            
            @24,09 GET MACTION PICTURE '9' RANGE 1,4
            READ               
         ENDDO
         IF MACTION = 1 .OR. MACTION = 3
            DO FILELOCK
            REPLACE TRAN_MO WITH MTRAN_MO
            REPLACE TRAN_YR WITH MTRAN_YR
            REPLACE SHIP_DATE WITH MSHIP_DATE
            REPLACE POST_FLG WITH MPOST_FLG
            UNLOCK
         ENDIF
         IF MACTION = 4
            DO RECLOCK 
            DELETE
            UNLOCK
         ENDIF
         MPO_SEL = .F.
         LOOP
         
      ENDDO
      LOOP
      
      
   CASE MSELECT2 = '8'
      STORE SPACE(2)    TO MTRAN_MO
      STORE SPACE(4)    TO MTRAN_YR
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         CLEAR 
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         MTITLE = ' - REMOVE OLD ENTRIES FROM THE SS SPREADSHEET'
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 TO 22,79
         @ 08,5 SAY 'Enter the Month/Year of the entries to be deleted.'
         @ 11, 5 SAY '      Business Month:'
         @ 11,28 GET MTRAN_MO PICTURE '##'
         @ 13, 5 say '       Business Year:'
         @ 13,28 GET MTRAN_YR PICTURE '####'
         @ 18,5 SAY 'WARNING: NO ONE CAN BE PRINTING INVOICES OR ENTERING'
         @ 19,5 SAY '         DATA ON THE SS SPREADSHEET AT THIS TIME !!'
         
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
         @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
         
         READ
         
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
         
         IF MACTION = 2
            LOOP
         ENDIF
         
         IF MTRAN_YR = '    ' .OR. MTRAN_MO = '  '
            MACTION = 3  
            LOOP
         ENDIF
         
         SELECT B
         USE SS INDEX SS_YRMO, SS EXCLUSIVE
         SEEK MTRAN_YR + MTRAN_MO
         IF EOF() 
            @ 24,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'NO ENTRIES ON FILE FOR THIS MONTH/YEAR - PRESS RETURN TO CONTINUE' GET MWAIT
            READ
            MACTION = 2
            LOOP
         ENDIF
      ENDDO
      IF MACTION <> 3
         DO WHILE .NOT. EOF() .AND. TRAN_MO = MTRAN_MO .AND. TRAN_YR = MTRAN_YR
            DELETE
            SKIP
         ENDDO
         PACK
      ENDIF
      
      CLOSE DATA
   ENDCASE
   CLOSE DATA
   
ENDDO
RETURN


* EOF: MAINT2.PRG

*Formatted by: ToolBox Ver. 1.2  on 6/26/14 at 3:30 PM.
