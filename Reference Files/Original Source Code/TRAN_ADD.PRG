**********
* Program.: TRAN_ADD.PRG
* Author..: Grace Keller
* Date....: 10/13/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: TRANSMITTED ORDER ADD
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT B
DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PRINT, PO_SUP, PO_SHIP, PO_FRT", .F.

SELECT C
DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.

SELECT F
IF MPROG_CODE = 2
   MTRAN_SALE = 'MF'
ENDIF
IF MTRAN_SALE = '  '
   USE TRAN_DTL EXCLUSIVE
   INDEX ON SALESMAN+PO_NBR+PO_SUFFIX+ITEM_NBR TO TRAN_DTL
   USE
ELSE
   MFILE = 'TRAN_D' + MTRAN_SALE
   USE &MFILE EXCLUSIVE
   INDEX ON SALESMAN + PO_NBR+ PO_SUFFIX TO &MFILE   
   INDEX ON SALESMAN+PO_NBR+PO_SUFFIX+ITEM_NBR TO &MFILE   
   USE
ENDIF

MMORE = .T.  
DO WHILE MMORE
   SELECT F
   IF MTRAN_SALE = '  '
      DO FOX_USE WITH "TRAN_PO", .F.
      IF MCOMPANY = 'DIVISION 15' .OR. MPROG_CODE = 2
         SET FILTER TO COR_FLG = ' '
         GOTO TOP
      ENDIF
   ELSE
      MFILE = 'TRAN_P' + MTRAN_SALE
      DO FOX_USE WITH "&MFILE", .F.
      SET FILTER TO COR_FLG = ' '
      GOTO TOP
   ENDIF
   
   IF EOF()
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 8,79
      STORE 'NO MORE TRANSMITTED ORDERS TO ADD - PRESS RETURN TO CONTINUE' TO MERROR
      @ 5,2 GET MERROR
      CLEAR GETS
      STORE ' ' TO MSPACE
      @ 5,64 GET MSPACE
      READ
      MMORE = .F.
      LOOP
   ENDIF
   
   MTITLE = ' - ADD TRANSMITTED PURCHASE ORDER'    
   
   STORE 0 TO MTOT_LBS, MTOT_SELL, MTOT_PURCH, MTOTIPURCH, MTOTISELL 
   STORE 0 TO MNBR_ITM
   STORE 0 TO MMAX_ITM
   **STORE SPACE(32) TO MRSUPNAME, MSUP_NAME, MBBUYNAME, MBUY_NAME
   IF RSUPNAME = 'GLACIER - INVENTORY'
      STORE 'INVENTORY' + SPACE(23) TO MRSUPNAME, MSUP_NAME
      STORE 'INVN' TO MRSUPCODE
   ELSE
      STORE RSUPNAME TO MRSUPNAME           
      IF MPROG_CODE = 2
         STORE SUPNAME TO MSUP_NAME
      ELSE
         STORE RSUPNAME TO MSUP_NAME
      ENDIF
   ENDIF
   STORE RSUPCITY TO MRSUPCITY
   STORE RSUPST   TO MRSUPST
   
   IF BBUYNAME = 'GLACIER - INVENTORY'
      STORE 'INVENTORY' + SPACE(23) TO MBBUYNAME, MBUY_NAME
      STORE 'INVN' TO MBBUYCODE
   ELSE
      STORE BBUYNAME TO MBBUYNAME
      IF MPROG_CODE = 2
         STORE BUYNAME TO MBUY_NAME
      ELSE
         STORE BBUYNAME TO MBUY_NAME
      ENDIF
   ENDIF
   STORE BBUYCITY TO MBBUYCITY
   STORE BBUYST   TO MBBUYST
   STORE NOTE1    TO MNOTE1   
   STORE NOTE2    TO MNOTE2
   STORE NOTE3    TO MNOTE3
   STORE SPACE(4) TO MRSUPCODE, MSUP_CODE, MBBUYCODE, MBUY_CODE
   SET PROC TO I_PROC
   DO TRANPO
   SET PROC TO PO_PROC
   
   MCONT = .T.
   DO WHILE MCONT
      CLEAR
      SET PROC TO PO_PROC
      DO TEXTPO2
      DO GETPO2   
      READ
      IF MSALESMAN = '  ' .AND. MPO_NBR = SPACE(4)
         MCONT = .F.
         MMORE = .F.
         LOOP
      ENDIF
      ***   DO SOME EDITS HERE ON SALESMAN, DUPLICATE PO #'S ETC.
      IF MSALESMAN <> SPACE(2)
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
         SEEK MSALESMAN
         IF .NOT. EOF()
            STORE NAME TO MSAL_NAME
            STORE SALE_PERC TO MSALE_PERC
            IF DTOC(EFF_DT2) <> '  /  /  '
               IF MSHIP_DATE >= EFF_DT2
                  MSALE_PERC = SALE_PER2
               ENDIF
            ENDIF
            IF DTOC(EFF_DT3) <> '  /  /  '
               IF MSHIP_DATE >= EFF_DT3
                  MSALE_PERC = SALE_PER3
               ENDIF
            ENDIF
         ELSE
            **** GIVE AN ERROR HERE
            @ 24,0 CLEAR
            STORE 'SALESPERSON CODE ' + MSALESMAN + ' NOT FOUND - PRESS RETURN TO REENTER' TO MERROR
            @ 24,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,63 GET MSPACE
            READ
            LOOP
         ENDIF
      ELSE
         IF MBROK_NAME = SPACE(5)
            **** GIVE AN ERROR HERE
            @ 24,0 CLEAR
            STORE 'SALESPERSON CODE OR BROKER NAME MUST BE ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @ 24,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,63 GET MSPACE
            READ
            LOOP
         ELSE
            STORE MBROK_NAME TO MSAL_NAME
            STORE 0 TO MSALE_PERC
         ENDIF
      ENDIF
      
      SELECT B
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      IF .NOT. EOF()
         **** PO ALREADY ON FILE 
         @ 23,0 CLEAR
         STORE 'ORDER NBR ALREADY USED - PRESS RETURN TO CONTINUE WITH NEXT ORDER' TO MERROR
         @ 24,1 GET MERROR
         CLEAR GETS
         STORE ' ' TO MSPACE
         @ 24,69 GET MSPACE
         READ
         
         SELECT F
         IF MTRAN_SALE = '  '
            DO FOX_USE WITH "TRAN_PO", .F.
            IF MCOMPANY = 'DIVISION 15'
               SET FILTER TO COR_FLG = ' '
               GOTO TOP
            ENDIF
         ELSE
            MFILE = 'TRAN_P' + MTRAN_SALE
            DO FOX_USE WITH "&MFILE", .F.
         ENDIF
         
         DO WHILE .NOT. EOF()
            IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
               DELETE
            ENDIF
            SKIP
         ENDDO
         
         IF MTRAN_SALE = '  '
            DO FOX_USE WITH "TRAN_DTL INDEX TRAN_DTL", .F.
         ELSE
            MFILE = 'TRAN_D' + MTRAN_SALE
            DO FOX_USE WITH "&MFILE INDEX &MFILE", .F.
         ENDIF
         
         DO WHILE .NOT. EOF()
            IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
               DELETE
            ENDIF
            SKIP
         ENDDO
         
         USE
         MCONT = .F.
         LOOP
      ENDIF
      
      DO CASE
      CASE MCOMPANY = 'DIVISION 15'
         IF MBROKERAGE <> 'Y' .AND. MBROKERAGE <> ' '
            @ 24,0 CLEAR
            STORE 'HOLD STORAGE INDICATOR MUST BE A "Y" OR SPACE - PRESS RETURN TO REENTER'TO MERROR
            @ 24,1 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,1  GET MSPACE
            READ
            LOOP
         ENDIF
      OTHERWISE
         IF MBROKERAGE <> 'X' .AND. MBROKERAGE <> ' '
            @ 24,0 CLEAR
            STORE 'BROKERAGE ORDER INDICATOR MUST BE AN "X" OR SPACE - PRESS RETURN TO REENTER'TO MERROR
            @ 24,1 GET MERROR
            CLEAR GETS
            STORE 'B' TO MSPACE
            @ 24,1  GET MSPACE
            READ
            LOOP
         ENDIF
      ENDCASE
      **** DO SOME EDITS ON SHIP DATE
      IF MPROG_CODE <> 2
         IF MSHIP_DATE > DATE()
            STORE ' ' TO MREENTER
            DO WHILE MREENTER <> 'R'
               @ 24,0 CLEAR
               STORE 'SHIP DATE IS IN THE FUTURE - ENTER AN "R" TO REENTER' TO MERROR
               @ 24,2 GET MERROR
               CLEAR GETS
               STORE ' ' TO MSPACE
               @ 24,0  GET MREENTER PICTURE '@!'
               READ
            ENDDO
            @ 24,0 CLEAR
            LOOP
         ENDIF
      ENDIF
      
      IF DTOC(MSHIP_DATE) = '  /  /  '
         STORE ' ' TO MREENTER
         DO WHILE MREENTER <> 'R'
            @ 24,0 CLEAR
            STORE 'SHIP DATE IS BLANK - ENTER AN "R" TO REENTER' TO MERROR
            @ 24,2 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,0  GET MREENTER PICTURE '@!'
            READ
         ENDDO
         @ 24,0 CLEAR
         LOOP
      ENDIF
      
      IF DATE() - MSHIP_DATE > 7
         @ 24,0 CLEAR
         STORE ' ' TO MERROR
         DO WHILE MERROR <> 'C' .AND. MERROR <> 'E'
            @ 24,0 SAY "SHIP DATE MORE THAN 7 DAYS OLD - ENTER 'C' TO CONTINUE OR 'E' TO EDIT " GET MERROR PICTURE '@!'
            READ
         ENDDO
         @ 24,0 CLEAR
         IF MERROR <> 'C'
            LOOP
         ENDIF
      ENDIF
      
      IF DATE() - MDEL_REQD > 7  .OR. MDEL_REQD > DATE()    
         @ 24,0 CLEAR
         STORE ' ' TO MERROR
         DO WHILE MERROR <> 'C' .AND. MERROR <> 'E'
            @ 24,0 SAY "DELIVERY DATE MAY BE INVALID - ENTER 'C' TO CONTINUE OR 'E' TO EDIT " GET MERROR PICTURE '@!'
            READ
         ENDDO
         @ 24,0 CLEAR
         IF MERROR <> 'C'
            LOOP
         ENDIF
      ENDIF
      
      DO TEXTPO3
      
      **** GET SUPPLIER SHIPPED FROM ADDRESS
      SET PROC TO SUP_PROC
      MGET_NAME = .T.
      DO WHILE MGET_NAME
         @ 13,1 GET MSUP_NAME PICTURE '@!'
         READ
         IF MSUP_NAME = SPACE(32)
            @ 24,0 CLEAR
            STORE 'SHIPPED FROM SUPPLIER NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @ 24,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,58 GET MSPACE
            READ
            LOOP
         ENDIF
         IF MSUP_NAME = 'NONE'
            STORE 'NONE' TO MSUP_CODE
            STORE 'NONE' TO MRSUPCODE
            MGET_NAME = .F.
            LOOP
         ENDIF
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_NAME, &MDBFLOC.SUP_CODE", .F.
         MNAME_FD = .F.
         STORE MSUP_NAME TO MNAME
         STORE MSUP_NAME TO MDIS_NAME
         @ 24,0 CLEAR
         SAVE SCREEN TO MADD_SCRN
         
         *** THIS IS NEW
         DO SUP_TRAN
         *** END OF NEW
         
         RESTORE SCREEN FROM MADD_SCRN
         STORE MDIS_NAME TO MSUP_NAME
         IF MNAME_FD
            STORE NAME TO MSUP_NAME       
            STORE STREET TO MSTREET    
            STORE CITY TO MCITY       
            STORE STATE TO MSTATE
            IF ZIP4 = SPACE(4)
               STORE ZIP TO MZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MZIP 
            ENDIF
            STORE SUP_CODE TO MSUP_CODE
            IF MPROG_CODE <> 2
               STORE RSUPCODE TO MRSUPCODE
            ENDIF
            MGET_NAME = .F.
         ENDIF
      ENDDO
      @ 13,1  SAY MSUP_NAME
      IF MSUP_NAME <> 'NONE'
         @ 14,1  SAY MSTREET
         @ 15,1 SAY  SPACE(35)
         IF MCITY <> SPACE(20) .OR. MSTATE <> SPACE(2)
            @ 15,1  SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
         ENDIF
      ENDIF
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
      IF MPROG_CODE = 2
         MSV_NAME = SPACE(32)
         STORE SPACE(28) TO MSTREET
         STORE SPACE(20) TO MCITY
         STORE SPACE(2) TO MSTATE
         STORE SPACE(5) TO MZIP
      ELSE
         SEEK MRSUPCODE
         IF EOF() .OR. MRSUPCODE = 'NONE'
            STORE SPACE(32) TO MRSUPNAME
            STORE MRSUPNAME TO MSV_NAME
            STORE SPACE(28) TO MSTREET
            STORE SPACE(20) TO MCITY
            STORE SPACE(2) TO MSTATE
            STORE SPACE(5) TO MZIP
         ELSE
            STORE NAME TO MRSUPNAME
            STORE MRSUPNAME TO MSV_NAME
            STORE STREET TO MSTREET
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            IF ZIP4 = SPACE(4)
               STORE ZIP TO MZIP 
            ELSE
               STORE ZIP + '-' + ZIP4 TO MZIP
            ENDIF
         ENDIF
      ENDIF
      MGET_NAME = .T.
      DO WHILE MGET_NAME
         @ 13,40 GET MRSUPNAME PICTURE '@!'
         @ 14,40 SAY MSTREET
         @ 15,40 SAY SPACE(35)
         IF MCITY <> SPACE(20) .OR. MSTATE <> SPACE(2)
            @ 15,40 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
         ENDIF
         READ
         IF MRSUPNAME = SPACE(32)
            @ 24,0 CLEAR
            STORE 'REMIT TO SUPPLIER NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @ 24,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,58 GET MSPACE
            READ
            LOOP
         ENDIF
         IF MRSUPNAME = 'NONE'
            STORE 'NONE' TO MRSUPCODE
            MGET_NAME = .F.
            LOOP
         ENDIF
         IF MRSUPNAME <> MSV_NAME
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME, &MDBFLOC.RSUPCODE", .F.
            MNAME_FD = .F.
            IF MRSUPNAME = 'SAME'
               STORE MSUP_NAME TO MNAME
            ELSE
               STORE MRSUPNAME TO MNAME
            ENDIF
            SAVE SCREEN TO MADD_SCRN
            *     DO RSUPSEL2
            MNAME_FD = .F.
            STORE 1 TO MACTION
            STORE TRIM(MNAME) TO SRCH_ARG
            SEEK SRCH_ARG
            IF EOF() .OR. DELETED()
               @ 24,0 CLEAR
               STORE ' ' TO MSPACE 
               MYES_NO = 'N'
               @ 24,10 SAY 'REMIT TO NAME NOT FOUND ON FILE - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
               READ
               IF MYES_NO = 'Y'
                  MINIT_NM = .F.
                  DO RSUP_ADD
                  IF MACTION <> 4
                     MNAME_FD = .T.
                  ENDIF
               ENDIF
            ELSE               
               STORE RECNO() TO MFST_REC
               SKIP
               IF NAME = SRCH_ARG
                  MADD = .F.
                  DO MUL5RSUP
                  IF MACTION <> 5
                     MNAME_FD = .T.
                  ENDIF
               ELSE
                  GOTO MFST_REC
                  IF ACTIVE = 'I'
                     STORE ' ' TO MSPACE 
                     @ 24,10 SAY 'REMIT TO SUPPLIER IS INACTIVE - CANNOT SELECT ' GET MSPACE
                     READ
                     @ 24,0
                  ELSE 
                     MNAME_FD = .T.
                  ENDIF
               ENDIF
            ENDIF
            RESTORE SCREEN FROM MADD_SCRN 
            @ 24,0 CLEAR
            IF (.NOT. MNAME_FD) .OR. (MNAME = SPACE(32))
               LOOP
            ENDIF
            STORE NAME TO MRSUPNAME       
            STORE STREET TO MSTREET    
            STORE CITY TO MCITY       
            STORE STATE TO MSTATE
            IF ZIP4 = SPACE(4)
               STORE ZIP TO MZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MZIP 
            ENDIF
            STORE RSUPCODE TO MRSUPCODE
         ENDIF
         MGET_NAME = .F.
      ENDDO
      @ 13,40 SAY MRSUPNAME
      IF MRSUPNAME <> 'NONE'
         @ 14,40 SAY MSTREET
         @ 15,40 SAY SPACE(35)
         IF MCITY <> SPACE(20) .OR. MSTATE <> SPACE(2)
            @ 15,40 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
         ENDIF
      ENDIF
      
      ******** here
      ***** NOW GET SHIP TO CUSTOMER
      SET PROC TO BUY_PROC
      MGET_NAME = .T.
      DO WHILE MGET_NAME
         @ 20,1  GET MBUY_NAME PICTURE '@!'
         READ
         IF MBUY_NAME = SPACE(32)
            @ 24,0 CLEAR
            STORE 'SHIP TO CUSTOMER NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @ 24,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,58 GET MSPACE
            READ
            LOOP
         ENDIF
         
         IF MBUY_NAME = 'NONE'
            STORE 'NONE' TO MBUY_CODE
            STORE 'NONE' TO MBBUYCODE
            STORE SPACE(28) TO MSTREET
            STORE SPACE(20) TO MCITY
            STORE SPACE(2) TO MSTATE
            STORE SPACE(5) TO MZIP
            STORE SPACE(4) TO MZIP4
            MGET_NAME = .F.
            LOOP
         ENDIF
         
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_NAME, &MDBFLOC.BUY_CODE", .F.
         MNAME_FD = .F.
         STORE MBUY_NAME TO MNAME
         STORE MBUY_NAME TO MDIS_NAME
         SAVE SCREEN TO MADD_SCRN
         
         *** THIS IS NEW
         DO BUY_TRAN
         *** END OF NEW
         
         RESTORE SCREEN FROM MADD_SCRN
         STORE MDIS_NAME TO MBUY_NAME
         @ 24,0 CLEAR
         IF (.NOT. MNAME_FD) .OR. (MNAME = SPACE(32))
            LOOP
         ENDIF
         STORE NAME TO MBUY_NAME       
         STORE STREET TO MSTREET    
         STORE CITY TO MCITY       
         STORE STATE TO MSTATE
         IF ZIP4 = SPACE(4)
            STORE ZIP TO MZIP
         ELSE
            STORE ZIP + '-' + ZIP4 TO MZIP 
         ENDIF
         STORE BUY_CODE TO MBUY_CODE
         IF MPROG_CODE <> 2        
            STORE BBUYCODE TO MBBUYCODE
         ENDIF
         MGET_NAME = .F.
      ENDDO
      @ 20,1  SAY MBUY_NAME
      IF MBUY_NAME <> 'NONE'
         @ 21,1  SAY MSTREET
         @ 22,1 SAY SPACE(35)
         IF MCITY <> SPACE(20) .OR. MSTATE <> SPACE(2)
            @ 22,1  SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
         ENDIF
      ENDIF
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      IF MPROG_CODE = 2 
         MSV_NAME = SPACE(32)
         STORE SPACE(28) TO MSTREET
         STORE SPACE(20) TO MCITY
         STORE SPACE(2) TO MSTATE
         STORE SPACE(5) TO MZIP
         STORE SPACE(20) TO MPO_WARN
      ELSE
         SEEK MBBUYCODE
         IF .NOT. EOF()
            STORE NAME TO MBBUYNAME, MSV_NAME
            STORE STREET TO MSTREET
            STORE CITY TO MCITY
            STORE STATE TO MSTATE
            IF ZIP4 = SPACE(4)
               STORE ZIP TO MZIP 
            ELSE
               STORE ZIP + '-' + ZIP4 TO MZIP
            ENDIF
            STORE PO_WARN TO MPO_WARN
         ELSE
            STORE SPACE(32) TO MBBUYNAME, MSV_NAME
            STORE SPACE(28) TO MSTREET
            STORE SPACE(20) TO MCITY
            STORE SPACE(2) TO MSTATE
            STORE SPACE(5) TO MZIP
            STORE SPACE(20) TO MPO_WARN
         ENDIF
      ENDIF
      ***** NOW GET BILL TO CUSTOMER
      MGET_NAME = .T.
      DO WHILE MGET_NAME
         @ 20,40 GET MBBUYNAME PICTURE '@!'
         @ 21,40 SAY MSTREET
         @ 22,40 SAY SPACE(35)
         IF MCITY <> SPACE(20) .OR. MSTATE <> SPACE(2)
            @ 22,40 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
         ENDIF
         READ
         IF MBBUYNAME = SPACE(32)
            @ 24,0 CLEAR
            STORE 'BILL TO CUSTOMER NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @ 24,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,58 GET MSPACE
            READ
            LOOP
         ENDIF
         IF MBBUYNAME = 'NONE'
            STORE 'NONE' TO MBBUYCODE, MNAME
            STORE SPACE(28) TO MSTREET
            STORE SPACE(20) TO MCITY
            STORE SPACE(2) TO MSTATE
            STORE SPACE(5) TO MZIP
            STORE SPACE(4) TO MZIP4
            MGET_NAME = .F.
            LOOP
         ENDIF
         
         IF MBBUYNAME <> MSV_NAME
            IF MBBUYNAME = 'SAME'
               STORE MBUY_NAME TO MNAME
            ELSE
               STORE MBBUYNAME TO MNAME
            ENDIF
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME, &MDBFLOC.BBUYCODE", .F.
            MNAME_FD = .F.
            SAVE SCREEN TO MADD_SCRN
            *        DO BBUYSEL2
            MNAME_FD = .F.
            STORE 1 TO MACTION
            STORE TRIM(MNAME) TO SRCH_ARG         
            SEEK SRCH_ARG
            IF EOF() .OR. DELETED()
               @ 24,0 CLEAR
               STORE ' ' TO MSPACE 
               MYES_NO = 'N'
               @ 24,10 SAY 'BILL TO NAME NOT FOUND ON FILE - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
               READ
               IF MYES_NO = 'Y'
                  MINIT_NM = .F.
                  DO BBUY_ADD
                  IF MACTION <> 4
                     MNAME_FD = .T.
                  ENDIF
               ENDIF
            ELSE               
               STORE RECNO() TO MFST_REC
               SKIP
               IF NAME = SRCH_ARG
                  MADD = .F.
                  DO MUL5BBUY
                  IF MACTION <> 5
                     MNAME_FD = .T.
                  ENDIF
               ELSE
                  GOTO MFST_REC
                  IF ACTIVE = 'I'
                     @ 24,0 CLEAR
                     STORE ' ' TO MSPACE 
                     @ 24,10 SAY 'BILL TO CUSTOMER IS INACTIVE - CANNOT SELECT ' GET MSPACE PICTURE '@!'
                     READ
                     @ 24,0
                  ELSE
                     MNAME_FD = .T.
                  ENDIF
               ENDIF
            ENDIF
            RESTORE SCREEN FROM MADD_SCRN
            @ 24,0 CLEAR
            IF (.NOT. MNAME_FD) .OR. (MNAME = SPACE(32))
               LOOP
            ENDIF
            STORE NAME TO MBBUYNAME       
            STORE STREET TO MSTREET    
            STORE CITY TO MCITY       
            STORE STATE TO MSTATE
            IF ZIP4 = SPACE(4)
               STORE ZIP TO MZIP
            ELSE
               STORE ZIP + '-' + ZIP4 TO MZIP 
            ENDIF
            STORE BBUYCODE TO MBBUYCODE
            STORE PO_WARN TO MPO_WARN
         ENDIF
         MGET_NAME = .F.
      ENDDO
      @ 20,40 SAY MBBUYNAME
      IF MBBUYNAME <> 'NONE'
         @ 21,40 SAY MSTREET
         @ 22,40 SAY SPACE(35)
         IF MCITY <> SPACE(20) .OR. MSTATE <> SPACE(2)
            @ 22,40 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
         ENDIF
      ENDIF
      **** IF GOING INTO INVENTORY - SHIPPING THE LAST FEW DAYS OF THE
      **** MONTH - MUST HAVE SHIP DATE AND DELIVERY DATE IN SAME MONTH
      **** OR SPREADSHEET WILL BE DIFFERENT FROM INVENTORY SYSTEM
      IF MBBUYCODE = 'INVN'
         IF VAL(SUBSTR(DTOC(MSHIP_DATE),4,2)) > 27
            IF  SUBSTR(DTOC(MSHIP_DATE),1,2) <> SUBSTR(DTOC(MDEL_REQD),1,2)
               @ 24,0 CLEAR
               STORE ' ' TO MERROR
               DO WHILE MERROR <> 'C' .AND. MERROR <> 'E'
                  @ 24,0 SAY "INVENTORY/MUST SHIP & DELIVER SAME MONTH-ENTER 'C' TO CONT OR 'E' TO EDIT " GET MERROR PICTURE '@!'
                  READ
               ENDDO
               @ 24,0 CLEAR
               IF MERROR <> 'C'
                  LOOP
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      SET PROC TO PO_PROC
      STORE 1 TO MACTION
      @ 24,0 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Item Page      2. Edit      3. Cancel Add    4. Update Notes'
      @ 24,8 GET MACTION PICTURE '#' RANGE 1,4
      
      READ
      
      IF MACTION = 4
         SAVE SCREEN TO MGRACE
         DO UPDNOTES
         RESTORE SCREEN FROM MGRACE
         STORE 1 TO MACTION
         @ 24,0 CLEAR
         @ 24,0 SAY 'Action: '
         @ 24,13 SAY '1. Item Page      2. Edit      3. Cancel Add'
         @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
         READ
      ENDIF
      
      DO CASE
      CASE MACTION = 1
         *  SET PROC TO PO_PROC
         *** WRITE BACK THIS SCREEN OF DATA
         **IF MBBUYNAME = 'SALESPERSON' .OR. MRSUPNAME = 'SALESPERSON'
         IF MBBUYNAME = 'SALESPERSON'
            @ 24,0 CLEAR
            MYES_NO = '   '
            SET CONFIRM ON
            @ 24,1 SAY  'INTRACOMPANY SALE - Do you want to continue with ADD (YES/NO): ' GET MYES_NO PICTURE '@!'
            READ
            SET CONFIRM OFF
            @ 24,0 CLEAR
         ELSE
            MYES_NO = 'YES'
         ENDIF
         IF MYES_NO = 'YES'
            SELECT B
            DO FILELOCK
            APPEND BLANK
            DO REPLPO
            IF MBUYER_PO <> 'HOLD Q'
               SELECT A
               DO FOX_USE WITH "CUST_PO INDEX CUST_PO", .F.
               DO FILELOCK
               APPEND BLANK
               REPLACE SALESMAN WITH MSALESMAN
               REPLACE PO_NBR WITH MPO_NBR
               REPLACE PO_SUFFIX WITH MPO_SUFFIX
               REPLACE BUYER_PO WITH MBUYER_PO
               REPLACE BBUYCODE WITH MBBUYCODE
               UNLOCK
               USE
            ENDIF
            SELECT A
            DO FOX_USE WITH "NOTES INDEX NOTES", .F.
            I = 1
            DO WHILE I<= 3
               MSEQI = STR(I,1)
               IF MNOTE&MSEQI <> SPACE(70)
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE SALESMAN WITH MSALESMAN
                  REPLACE PO_NBR WITH MPO_NBR
                  REPLACE PO_SUFFIX WITH MPO_SUFFIX
                  REPLACE NOTE WITH MNOTE&MSEQI
                  REPLACE SEQ WITH MSEQI
                  UNLOCK
               ENDIF
               I = I + 1
            ENDDO
            USE
            DO TRANIADD 
         ENDIF
         
         SELECT F
         IF MTRAN_SALE = '  '
            DO FOX_USE WITH "TRAN_PO", .F.
            IF MCOMPANY = 'DIVISION 15'
               SET FILTER TO COR_FLG = ' '
               GOTO TOP
            ENDIF
         ELSE
            MFILE = 'TRAN_P' + MTRAN_SALE
            DO FOX_USE WITH "&MFILE", .F.
         ENDIF
         
         DO WHILE .NOT. EOF()
            IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
               DELETE
            ENDIF
            SKIP
         ENDDO
         
         IF MTRAN_SALE = '  '
            DO FOX_USE WITH "TRAN_DTL INDEX TRAN_DTL", .F.
         ELSE
            MFILE = 'TRAN_D' + MTRAN_SALE
            DO FOX_USE WITH "&MFILE INDEX &MFILE", .F.
         ENDIF
         
         DO WHILE .NOT. EOF()
            IF SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
               DELETE
            ENDIF
            SKIP
         ENDDO
         
         USE
         
         *** IF FINISHED HERE COMING BACK FROM FREIGHT - FINISH IT UP
         MCONT = .F.
         *** MMORE = .F.
      CASE MACTION = 2
         LOOP
         
      CASE MACTION = 3
         MCONT = .F.
         LOOP
      ENDCASE 
   ENDDO 
ENDDO
CLOSE DATA       

RETURN
* EOF: PO_ADD.PRG
*Formatted by: ToolBox Ver. 1.2  on 9/19/97 at 10:25 AM.
