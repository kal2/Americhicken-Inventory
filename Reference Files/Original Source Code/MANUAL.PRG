**********
* Program.: MANUAL.PRG
* Author..: Grace Keller
* Date....: 01/18/88
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: WRITE A MANUAL DAILY JOURNAL ENTRY
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT B
DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
SELECT C
DO FOX_USE WITH "INV_HEAD INDEX INV_HEAD", .F.

CLEAR
@ 01,00 SAY MCOMPANY
@ 02,00 SAY MPROGRAM + ' - ADD / UPDATE MANUAL SPREADSHEET ENTRIES'
@ 02,70 SAY DATE()
@ 3,0 to 22,79
STORE ' ' TO MCHOICE
@ 10,5 SAY 'Do You Want to Add Entries (A) or Update Entries (U) ? ' GET MCHOICE PICTURE '@!'
READ
IF MCHOICE = 'U'
   DO UPDSPRD
   RETURN
ELSE
   IF MCHOICE <> 'A'
      RETURN
   ENDIF
ENDIF
STORE 0 TO MMONTH, MTRAN_YR
STORE 2 TO MACTION
DO WHILE MACTION = 2
   @ 14,5 SAY 'Enter Posting Month: ' get mmonth picture '##' range 1,12
   @ 16,5 SAY '       Posting Year: ' get mtran_yr picture '####' range 1988,2099
   STORE 1 TO MACTION
   @ 24,00 CLEAR
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel'
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
ENDDO
IF MACTION = 3
   RETURN
ENDIF
STORE SUBSTR(STR(MMONTH+100,3),2) TO MTRAN_MO
STORE STR(MTRAN_YR,4) TO MTRAN_YR
CLEAR
@ 01,00 SAY MCOMPANY
@ 02,00 SAY MPROGRAM + ' - ADD MANUAL SPREADSHEET ENTRY'
@ 02,70 SAY DATE()
@ 3,0 to 22,79
STORE DATE() TO MPOST_DATE
MMORE_ENT = .T.
DO WHILE MMORE_ENT
   @ 4,1 CLEAR TO 20,78
   STORE SPACE(5) TO MINV_NBR
   STORE SPACE(4) TO MPO_NBR
   STORE SPACE(1) TO MPO_SUFFIX
   STORE SPACE(2) TO MSALESMAN
   STORE SPACE(32) TO MRSUPNAME, MBBUYNAME, MFRT_NAME1, MFRT_NAME2, MSAL2_NAME, MCOM_NAME, MCOM_NAME2
   STORE 0 TO MTOT_PUR1, MTOT_PUR2, MTOT_SEL1, MTOT_SEL2, M1ST_FRT1, M1ST_FRT2
   STORE 0 TO M2ND_FRT1, M2ND_FRT2, MSALE_COM1, MSALE_COM2, MSAL2_COM1, MSAL2_COM2
   STORE 0 TO MCOM_COM1, MCOM_COM2, MMISC_AMT1, MMISC_AMT2
   STORE 0 TO MFRT_PAL1, MFRT_PAL2, MCUS_PAL1, MCUS_PAL2, MSUP_PAL1, MSUP_PAL2
   STORE SPACE(2) TO MCOM_CODE, MSAL_CODE2, MCOM_CODE2
   STORE SPACE(4) TO MFRT_CODE1             
   MEDIT_ENT = .T.    
   DO WHILE MEDIT_ENT   
      MEDIT = .T.
      DO WHILE MEDIT
         MACTION = 1
         @ 4,1 SAY 'INVOICE NBR: '    
         @ 4,16 GET MINV_NBR PICTURE '#####'
         
         @ 4,25 SAY 'PO NUMBER: ' 
         @ 4,38 GET MSALESMAN
         @ 4,40 SAY '-'
         @ 4,41 GET MPO_NBR PICTURE '####'
         @ 4,45 SAY '-'
         @ 4,46 GET MPO_SUFFIX PICTURE '@!'
         @ 4,53 SAY 'POSTING DATE: '
         @ 4,67 GET MPOST_DATE
         READ
         IF MINV_NBR = SPACE(5) .AND. MSALESMAN = SPACE(2) .AND. MPO_NBR = SPACE(4)
            MMORE_ENT = .F.
            MEDIT = .F.
            MEDIT_ENT = .F.
            LOOP
         ENDIF
         IF MPO_NBR <> SPACE(4)
            SELECT B
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF .NOT. EOF()
               @ 24,0 CLEAR
               STORE 'N' TO MYES_NO
               @ 24,0 SAY 'PO ON FILE - DO YOU WANT TO CONTINUE WITH THIS ENTRY (Y/N)? ' GET MYES_NO PICTURE '@!'
               READ
               @ 24,0 CLEAR
               IF MYES_NO <> 'Y'
                  MEDIT_ENT = .F.
                  MEDIT = .F.
                  MACTION = 3
                  LOOP
               ELSE
                  STORE INV_NBR TO MINV_NBR
               ENDIF
            ENDIF
         ELSE
            IF MINV_NBR <> SPACE(5)
               MINV_NBR = STR(VAL(MINV_NBR),5)    
               SELECT C
               SEEK MINV_NBR
               IF .NOT. EOF()
                  @ 24,0 CLEAR
                  STORE 'N' TO MYES_NO
                  @ 24,0 SAY 'INVOICE ON FILE - DO YOU WANT TO CONTINUE WITH THIS ENTRY (Y/N)? ' GET MYES_NO PICTURE '@!'
                  READ
                  @ 24,0 CLEAR
                  IF MYES_NO <> 'Y'
                     MEDIT_ENT = .F.
                     MEDIT = .F.
                     MACTION = 3
                     LOOP
                  ELSE
                     STORE SALESMAN TO MSALESMAN
                     STORE PO_NBR TO MPO_NBR
                     STORE PO_SUFFIX TO MPO_SUFFIX
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
         IF MSALESMAN <> SPACE(2)
            SELECT A
            DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
            SEEK MSALESMAN
            IF .NOT. EOF()
               STORE NAME TO MSAL_NAME
               MEDIT = .F.
            ELSE
               @ 24,0 CLEAR
               STORE ' ' TO MWAIT
               @ 24,0 SAY 'INVALID SALESPERSON CODE - PRESS RETURN TO REENTER ' GET MWAIT
               READ
               @ 24,0 CLEAR
               LOOP
            ENDIF
         ELSE
            MEDIT = .F.
         ENDIF
      ENDDO
      IF .NOT. MMORE_ENT .OR. MACTION = 3
         LOOP
      ENDIF
      
      @ 4,16 SAY MINV_NBR
      @ 4,38 SAY MSALESMAN
      @ 4,41 SAY MPO_NBR
      @ 4,46 SAY MPO_SUFFIX
      @ 4,67 SAY MPOST_DATE
      @ 6,51 SAY '1ST ENTRY AMT'
      @ 6,66 SAY '2ND ENTRY AMT'
      
      MDO_THIS = .T.
      DO WHILE MDO_THIS
         ***** CUSTOMER INFORMATION
         @ 8,1 SAY '       CUSTOMER:'
         @ 8,18 GET MBBUYNAME PICTURE '@!'
         READ
         STORE MBBUYNAME TO MNAME
         IF MNAME <> 'NONE'
            MNAME_FD = .F.
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
            DO BBUYSEL2
            IF .NOT. MNAME_FD .OR. MACTION = 3
               LOOP
            ENDIF
            STORE NAME TO MBBUYNAME
            STORE BBUYCODE TO MBBUYCODE
            @ 8,18 SAY MBBUYNAME
            @ 9,1 SAY '  CUST. PALLETS:'
            
            @ 8,52 GET MTOT_SEL1 PICTURE '###,###.##'
            @ 8,67 GET MTOT_SEL2 PICTURE '###,###.##'
            @ 9,52 GET MCUS_PAL1 PICTURE '###,###.##'
            @ 9,67 GET MCUS_PAL2 PICTURE '###,###.##'
            READ
            MDO_THIS = .F.
         ELSE
            STORE MNAME TO MBBUYNAME
            STORE 'NONE' TO MBBUYCODE
            @ 8,18 SAY MBBUYNAME
            MDO_THIS = .F.
         ENDIF
      ENDDO
      
      MDO_THIS = .T.
      DO WHILE MDO_THIS
         *** SUPPLIER INFORMATION
         @ 10,1 SAY '       SUPPLIER:'
         @ 10,18 GET MRSUPNAME PICTURE '@!'
         READ
         STORE MRSUPNAME TO MNAME
         IF MNAME <> 'NONE'
            MNAME_FD = .F.
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
            DO RSUPSEL2
            IF .NOT. MNAME_FD .OR. MACTION = 3
               LOOP
            ENDIF
            STORE NAME TO MRSUPNAME
            STORE RSUPCODE TO MRSUPCODE
            @ 10,18 SAY MRSUPNAME
            @ 11,1 SAY '   SUP. PALLETS:'
            @ 10,52 GET MTOT_PUR1 PICTURE '###,###.##'
            @ 10,67 GET MTOT_PUR2 PICTURE '###,###.##'
            @ 11,52 GET MSUP_PAL1 PICTURE '###,###.##'
            @ 11,67 GET MSUP_PAL2 PICTURE '###,###.##'
            MDO_THIS = .F.
            READ
         ELSE
            STORE MNAME TO MRSUPNAME
            STORE 'NONE' TO MRSUPCODE
            @ 10,18 SAY MRSUPNAME
            MDO_THIS = .F.
         ENDIF
      ENDDO
      
      MDO_THIS = .T.
      DO WHILE MDO_THIS
         ***** FIRST FREIGHT CARRIER
         @ 12,1 SAY '   FREIGHT COMP:'
         @ 12,18 GET MFRT_NAME1 PICTURE '@!'
         READ
         STORE MFRT_NAME1 TO MNAME
         IF MNAME <> 'NONE'
            MNAME_FD = .F.
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
            DO FRT_SEL3
            IF .NOT. MNAME_FD .OR. MACTION = 3
               LOOP
            ENDIF
            STORE NAME TO MFRT_NAME1
            STORE FRT_CODE TO MFRT_CODE1
            @ 12,18 SAY MFRT_NAME1
            @ 12,1 SAY '   FRT. PALLETS:'
            @ 12,52 GET M1ST_FRT1 PICTURE '###,###.##'
            @ 12,67 GET M1ST_FRT2 PICTURE '###,###.##'
            @ 13,52 GET MFRT_PAL1 PICTURE '###,###.##'
            @ 13,67 GET MFRT_PAL2 PICTURE '###,###.##'
            READ
            MDO_THIS = .F.
         ELSE
            STORE MNAME TO MFRT_NAME1
            STORE 'NONE' TO MFRT_CODE1
            @ 12,18 SAY MFRT_NAME1
            MDO_THIS = .F.
         ENDIF
      ENDDO 
      
      IF MSALESMAN <> SPACE(2)
         @ 14,1 SAY '    SALESPERSON: '
         @ 14,18 SAY MSAL_NAME
         @ 14,52 GET MSALE_COM1 PICTURE '###,###.##'
         @ 14,67 GET MSALE_COM2 PICTURE '###,###.##'
         READ
      ENDIF
      
      @ 15,1 SAY 'INTERCOMP SALMN:'
      MEDIT = .T.
      DO WHILE MEDIT
         @ 15,18 GET MSAL2_NAME PICTURE '@!'
         READ
         IF MSAL2_NAME = SPACE(32)
            @ 15,18 SAY MSAL2_NAME
            MEDIT = .F.
            LOOP
         ENDIF
         STORE MSAL2_NAME TO MNAME
         MNAME_FD = .F.
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
         SEEK TRIM(MNAME)
         IF EOF()
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY 'INTERCOMPANY SALESPERSON NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
            READ
            @ 24,0 CLEAR
         ELSE
            STORE NAME TO MSAL2_NAME
            STORE SALE_CODE TO MSAL_CODE2
            @ 15,18 SAY MSAL2_NAME
            MEDIT = .F.
         ENDIF
         
      ENDDO
      
      IF MSAL2_NAME <> SPACE(32)
         @ 15,52 GET MSAL2_COM1 PICTURE '###,###.##'
         @ 15,67 GET MSAL2_COM2 PICTURE '###,###.##'
         READ
      ENDIF
      
      ***** THIRD PARTY COMMISSIONS
      
      @ 16,1 SAY 'THIRD PARTY COM:'
      MEDIT = .T.
      DO WHILE MEDIT
         @ 16,18 GET MCOM_NAME PICTURE '@!'
         READ
         IF MCOM_NAME = SPACE(32)
            @ 16,18 SAY MCOM_NAME
            MEDIT = .F.
            LOOP
         ENDIF
         STORE MCOM_NAME TO MNAME
         MNAME_FD = .F.
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
         SEEK TRIM(MCOM_NAME)
         IF EOF()
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY 'THIRD PARTY PAYEE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
            READ
            @ 24,0 CLEAR
         ELSE
            STORE NAME TO MCOM_NAME
            STORE COM_CODE TO MCOM_CODE
            @ 16,18 SAY MCOM_NAME
            MEDIT = .F.
         ENDIF
      ENDDO
      IF MCOM_NAME <> SPACE(32)
         @ 16,52 GET MCOM_COM1 PICTURE '###,###.##'
         @ 16,67 GET MCOM_COM2 PICTURE '###,###.##'
         READ
      ENDIF
      
      ***** THIRD PARTY COMMISSIONS
      @ 17,1 SAY 'THIRD PARTY COM:'
      MEDIT = .T.
      DO WHILE MEDIT
         @ 17,18 GET MCOM_NAME2 PICTURE '@!'
         READ
         IF MCOM_NAME2 = SPACE(32)
            @ 17,18 SAY MCOM_NAME2
            MEDIT = .F.
            LOOP
         ENDIF
         STORE MCOM_NAME2 TO MNAME
         MNAME_FD = .F.
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.COMPAYEE INDEX &MDBFLOC.COM_NAME", .F.
         SEEK TRIM(MCOM_NAME2)
         IF EOF()
            @ 24,0 CLEAR
            STORE ' ' TO MWAIT
            @ 24,1 SAY 'THIRD PARTY PAYEE NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
            READ
            @ 24,0 CLEAR
         ELSE
            STORE NAME TO MCOM_NAME2
            STORE COM_CODE TO MCOM_CODE2
            @ 17,18 SAY MCOM_NAME2
            MEDIT = .F.
         ENDIF
      ENDDO
      IF MCOM_NAME2 <> SPACE(32)
         @ 17,52 GET MCOM2_COM1 PICTURE '###,###.##'
         @ 17,67 GET MCOM2_COM2 PICTURE '###,###.##'
         READ
      ENDIF
      
      @ 18,1 SAY '  MISCELLANEOUS:'
      @ 18,52 GET MMISC_AMT1 PICTURE '###,###.##'
      @ 18,67 GET MMISC_AMT2 PICTURE '###,###.##'
      READ
      MGROSS1 = MTOT_SEL1 - MTOT_PUR1
      MTOT_NET1 = MGROSS1 - M1ST_FRT1 - M2ND_FRT1 - MSALE_COM1 - MSAL2_COM1 - MCOM_COM1 - MCOM2_COM1 - MMISC_AMT1
      MGROSS2 = MTOT_SEL2 - MTOT_PUR2
      MTOT_NET2 = MGROSS2 - M1ST_FRT2 - M2ND_FRT2 - MSALE_COM2 - MSAL2_COM2 - MCOM_COM2 - MCOM2_COM2 - MMISC_AMT2
      @ 19,52 TO 19,61
      @ 19,67 TO 19,76
      @ 20,1 SAY '            NET:'
      @ 20,52 GET MTOT_NET1 PICTURE '###,###.##'
      @ 20,67 GET MTOT_NET2 PICTURE '###,###.##'
      STORE 1 TO MACTION
      @ 24,0 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue     2. Edit      3. Cancel Entry'
      @ 24,9 GET MACTION PICTURE '9' range 1,3
      READ
      IF MACTION <> 2
         MEDIT_ENT = .F.
      ENDIF
   ENDDO
   
   IF MMORE_ENT 
      IF MACTION <> 3
         
         SELECT E
         DO FOX_USE WITH "DAILYJRN INDEX JRN_MO, JRN_PO, JRN_TRAN, POSTED", .F.
         DO FILELOCK
         
         *** PUT IN FIRST ENTRY
         APPEND BLANK
         REPLACE salesman   WITH MSALESMAN  
         REPLACE po_nbr     WITH MPO_NBR    
         REPLACE po_suffix  WITH MPO_SUFFIX 
         REPLACE RSUPCODE   WITH MRSUPCODE
         REPLACE bbuycode   WITH MBBUYCODE  
         REPLACE tot_sell   WITH MTOT_SEL1  
         REPLACE CUS_PALL   WITH MCUS_PAL1
         REPLACE TOT_PURCH  WITH MTOT_PUR1 
         REPLACE SUP_PALL   WITH MSUP_PAL1
         REPLACE TOT_NET    WITH MTOT_NET1
         REPLACE GROSS      WITH MGROSS1
         REPLACE FRT_CODE1  WITH MFRT_CODE1
         REPLACE FRT_AMT1   WITH M1ST_FRT1 
         REPLACE FRT_PALL   WITH MFRT_PAL1
         REPLACE COM_CODE   WITH MCOM_CODE
         REPLACE COMM_AMT   WITH MCOM_COM1 
         REPLACE COM_CODE2  WITH MCOM_CODE2
         REPLACE COMM_AMT2  WITH MCOM2_COM1
         REPLACE SALE_COMM  WITH MSALE_COM1
         REPLACE SAL_CODE2  WITH MSAL_CODE2 
         REPLACE SALE2_AMT  WITH MSAL2_COM1
         REPLACE MISC_AMT   WITH MMISC_AMT1
         IF VAL(MINV_NBR) < 10000
            MINV_NBR = STR(VAL(MINV_NBR),5)    
         ENDIF
         REPLACE INV_NBR    WITH MINV_NBR   
         REPLACE TRAN_DATE  WITH MPOST_DATE   
         REPLACE SHORT_FLG   WITH 'Y'
         REPLACE JRNL_DATE   WITH MPOST_DATE
         REPLACE TRAN_MO     WITH MTRAN_MO
         REPLACE TRAN_YR     WITH MTRAN_YR
         REPLACE INV_COR     WITH 'C'
         REPLACE SEQ         WITH '1'
         **** PUT IN THE NEW ENTRY IF THERE NEEDS TO BE 
         IF MTOT_PUR2 <> 0 .OR. MTOT_SEL2 <> 0 .OR. M1ST_FRT2 <> 0 .OR. M2ND_FRT2 <> 0 ;
            .OR. MSALE_COM2 <> 0 .OR. MSAL2_COM2 <> 0 .OR. MCOM_COM2 <> 0 .OR. MMISC_AMT2 <> 0 ;
            .OR. MCUS_PAL2 <> 0 .OR. MSUP_PAL2 <> 0 .OR. MFRT_PAL2 <> 0
            APPEND BLANK
            REPLACE salesman   WITH MSALESMAN  
            REPLACE po_nbr     WITH MPO_NBR    
            REPLACE po_suffix  WITH MPO_SUFFIX 
            REPLACE RSUPCODE   WITH MRSUPCODE
            REPLACE bbuycode   WITH MBBUYCODE  
            REPLACE tot_sell   WITH MTOT_SEL2  
            REPLACE CUS_PALL   WITH MCUS_PAL2
            REPLACE TOT_PURCH  WITH MTOT_PUR2 
            REPLACE SUP_PALL   WITH MSUP_PAL2
            REPLACE TOT_NET    WITH MTOT_NET2
            REPLACE GROSS      WITH MGROSS2
            REPLACE FRT_CODE1  WITH MFRT_CODE1
            REPLACE FRT_AMT1   WITH M1ST_FRT2 
            REPLACE FRT_PALL   WITH MFRT_PAL2
            REPLACE COM_CODE   WITH MCOM_CODE
            REPLACE COMM_AMT   WITH MCOM_COM2 
            REPLACE COM_CODE2  WITH MCOM_CODE2
            REPLACE COMM2_AMT  WITH MCOM2_COM2 
            REPLACE SALE_COMM  WITH MSALE_COM2        
            REPLACE SAL_CODE2  WITH MSAL_CODE2 
            REPLACE SALE2_AMT  WITH MSAL2_COM2
            REPLACE MISC_AMT   WITH MMISC_AMT2
            REPLACE INV_NBR    WITH MINV_NBR   
            REPLACE TRAN_DATE  WITH MPOST_DATE   
            REPLACE SHORT_FLG   WITH 'Y'
            REPLACE JRNL_DATE   WITH DATE()
            REPLACE TRAN_MO     WITH MTRAN_MO   
            REPLACE TRAN_YR     WITH MTRAN_YR
            REPLACE INV_COR     WITH 'C'
            REPLACE SEQ WITH '2'
         ENDIF
         UNLOCK
      ENDIF
   ENDIF
ENDDO
RETURN
* EOF: MANUAL.PRG
*Formatted by: dANALYST Ver. 7.3a on July 20, 1988 at 12:34 PM.
