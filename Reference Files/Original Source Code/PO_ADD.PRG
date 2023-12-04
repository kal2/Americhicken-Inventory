**********
* Program.: PO_ADD.PRG
* Author..: Grace Keller
* Date....: 10/13/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PURCHASE ORDER ADD
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE = .T.  
DO WHILE MMORE
   MTITLE = ' - ADD PO'    
   SET PROC TO PO_PROC
   DO INITPO
   
   STORE 0 TO MTOT_LBS, MTOT_SELL, MTOT_PURCH, MTOTIPURCH, MTOTISELL 
   STORE 0 TO MNBR_ITM
   STORE 0 TO MMAX_ITM
   STORE SPACE(32) TO MRSUPNAME, MSUP_NAME, MBBUYNAME, MBUY_NAME
   STORE SPACE(4) TO MRSUPCODE, MSUP_CODE, MBBUYCODE, MBUY_CODE
   STORE ' ' TO MMAIN_SHIP   
   STORE SPACE(4) TO MPO_SHIP1, MPO_SHIP2, MPO_SHIP3, MPO_SHIP3, MPO_SHIP4, MPO_SHIP5, MPO_SHIP6
   STORE SPACE(1) TO MPO_SUFF1, MPO_SUFF2, MPO_SUFF3, MPO_SUFF3, MPO_SUFF4, MPO_SUFF5, MPO_SUFF6
   IF MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
      STORE 'H' TO MBROKERAGE
      IF MCOMPANY = 'AMERICHICKEN, INC'
         STORE 'AMERI' TO MBROK_NAME
      ENDIF
   ENDIF
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
            @ 25,0 CLEAR
            STORE 'SALESPERSON CODE ' + MSALESMAN + ' NOT FOUND - PRESS RETURN TO REENTER' TO MERROR
            @ 25,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 25,63 GET MSPACE
            READ
            LOOP
         ENDIF
      ELSE
         IF MBROK_NAME = SPACE(5)
            **** GIVE AN ERROR HERE
            @ 25,0 CLEAR
            STORE 'SALESPERSON CODE OR BROKER NAME MUST BE ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @ 25,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 25,63 GET MSPACE
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
         @ 25,0 CLEAR
         STORE 'PURCHASE ORDER NUMBER ALREADY USED - PRESS RETURN TO \' TO MERROR
         @ 25,5 GET MERROR
         CLEAR GETS
         STORE ' ' TO MSPACE
         @ 25,58 GET MSPACE
         READ
         LOOP
      ENDIF
      
      DO CASE
      CASE MCOMPANY = 'DIVISION 72 - LAND'
         IF MBROKERAGE <> 'S' .AND. MBROKERAGE <> 'T' .AND. MBROKERAGE <> 'F' .AND. MBROKERAGE <> 'B' .AND. MBROKERAGE <> 'W' ;
            .AND. MBROKERAGE <> 'C' .AND. MBROKERAGE <> 'L'
            @ 25,0 CLEAR
            STORE 'BROKERAGE INDICATOR MUST BE "W, S, T, F, B, C, OR L" - PRESS RETURN 'TO MERROR
            @ 25,1 GET MERROR
            CLEAR GETS
            STORE 'B' TO MSPACE
            @ 25,1  GET MSPACE
            READ
            LOOP
         ENDIF
      CASE MCOMPANY = 'DIVISION 15'
         IF MBROKERAGE <> 'Y' .AND. MBROKERAGE <> ' '
            @ 25,0 CLEAR
            STORE 'HOLD STORAGE INDICATOR MUST BE A "Y" OR SPACE - PRESS RETURN TO REENTER'TO MERROR
            @ 25,1 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 25,1  GET MSPACE
            READ
            LOOP
         ENDIF
      CASE MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
         IF MBROKERAGE <> 'H' .AND. MBROKERAGE <> ' ' 
            @ 25,0 CLEAR
            STORE 'BROKERAGE ORDER INDICATOR MUST BE AN "H" OR SPACE - PRESS RETURN TO REENTER'TO MERROR
            @ 25,1 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 25,1  GET MSPACE
            READ
            LOOP
         ENDIF
      OTHERWISE
         IF MBROKERAGE <> 'X' .AND. MBROKERAGE <> ' ' 
            @ 25,0 CLEAR
            STORE 'BROKERAGE ORDER INDICATOR MUST BE AN "X" OR SPACE - PRESS RETURN TO REENTER'TO MERROR
            @ 25,1 GET MERROR
            CLEAR GETS
            STORE 'B' TO MSPACE
            @ 25,1  GET MSPACE
            READ
            LOOP
         ENDIF
      ENDCASE
      
      **** DO SOME EDITS ON SHIPPED WITH INFORMATION
      DO CASE
      CASE MMAIN_SHIP <> 'Y'
         IF MPO_SHIP1 <> SPACE(4)
            SELECT A
            DO FOX_USE WITH "SHIPWITH INDEX SHIPWITH", .F.
            SEEK MSALESMAN + MPO_SHIP1 + MPO_SUFF1
            IF EOF()
               @ 25,0 CLEAR
               STORE ' MAIN SHIPPED WITH PO NOT ON FILE - PRESS RETURN TO REENTER'TO MERROR
               @ 25,1 GET MERROR
               CLEAR GETS
               STORE ' ' TO MSPACE
               @ 25,1  GET MSPACE
               READ
               SELECT B
               LOOP
            ELSE
               IF MPO_NBR+MPO_SUFFIX = PO_SHIP1+PO_SUFF1 .OR. MPO_NBR+MPO_SUFFIX= PO_SHIP2+PO_SUFF2 ;
                  .OR. MPO_NBR+MPO_SUFFIX = PO_SHIP3+PO_SUFF3 .OR. MPO_NBR+MPO_SUFFIX= PO_SHIP4+PO_SUFF4 ;
                  .OR. MPO_NBR+MPO_SUFFIX = PO_SHIP5+PO_SUFF5 .OR. MPO_NBR+MPO_SUFFIX= PO_SHIP6+PO_SUFF6  
               ELSE
                  @ 25,0 CLEAR
                  STORE ' PO NOT LISTED ON SHIPPED WITH MAIN PO - PRESS RETURN TO REENTER'TO MERROR
                  @ 25,1 GET MERROR
                  CLEAR GETS
                  STORE ' ' TO MSPACE
                  @ 25,1  GET MSPACE
                  READ
                  SELECT B
                  LOOP
               ENDIF
            ENDIF
         ENDIF
         SELECT B
      OTHERWISE
         IF MPO_NBR+MPO_SUFFIX = MPO_SHIP1+MPO_SUFF1
            @ 25,0 CLEAR
            STORE ' THIS PO CAN NOT BE ON SHIPPED WITH LIST - PRESS RETURN TO REENTER'TO MERROR
            @ 25,1 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 25,1  GET MSPACE
            READ
            SELECT B
            LOOP
         ENDIF
         IF MPO_SHIP1 = SPACE(4)
            @ 25,0 CLEAR
            STORE ' MUST ENTER SHIPPED WITH POS - PRESS RETURN TO REENTER'TO MERROR
            @ 25,1 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 25,1  GET MSPACE
            READ
            SELECT B
            LOOP
         ENDIF
      ENDCASE
      **** DO SOME EDITS ON SHIP DATE
      IF MSHIP_DATE > DATE() .AND. MBROKERAGE <> 'H'
         STORE ' ' TO MREENTER
         DO WHILE MREENTER <> 'R'
            @ 25,0 CLEAR
            STORE 'SHIP DATE IS IN THE FUTURE - ENTER AN "R" TO REENTER' TO MERROR
            @ 25,2 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 25,0  GET MREENTER PICTURE '@!'
            READ
         ENDDO
         @ 25,0 CLEAR
         LOOP
      ENDIF
      
      IF DTOC(MSHIP_DATE) = '  /  /  '
         STORE ' ' TO MREENTER
         DO WHILE MREENTER <> 'R'
            @ 25,0 CLEAR
            STORE 'SHIP DATE IS BLANK - ENTER AN "R" TO REENTER' TO MERROR
            @ 25,2 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 25,0  GET MREENTER PICTURE '@!'
            READ
         ENDDO
         @ 25,0 CLEAR
         LOOP
      ENDIF
      
      IF DATE() - MSHIP_DATE > 30 .OR. DATE() - MSHIP_DATE < -30
         @ 25,0 CLEAR
         STORE ' ' TO MERROR
         DO WHILE MERROR <> 'C' .AND. MERROR <> 'E'
            @ 25,0 SAY "SHIP DATE APPEARS INVALID - ENTER 'C' TO CONTINUE OR 'E' TO EDIT " GET MERROR PICTURE '@!'
            READ
         ENDDO
         @ 25,0 CLEAR
         IF MERROR <> 'C'
            LOOP
         ENDIF
      ENDIF
      
      IF DATE() - MSHIP_DATE > 7
         @ 25,0 CLEAR
         STORE ' ' TO MERROR
         DO WHILE MERROR <> 'C' .AND. MERROR <> 'E'
            @ 25,0 SAY "SHIP DATE MORE THAN 7 DAYS OLD - ENTER 'C' TO CONTINUE OR 'E' TO EDIT " GET MERROR PICTURE '@!'
            READ
         ENDDO
         @ 25,0 CLEAR
         IF MERROR <> 'C'
            LOOP
         ENDIF
      ENDIF
      
      *** DO SOME EDITS ON DELIVERY REQUIRED
      
      IF DTOC(MDEL_REQD) = '  /  /  '
         STORE ' ' TO MREENTER
         DO WHILE MREENTER <> 'R'
            @ 25,0 CLEAR
            STORE 'DELV DATE IS BLANK - ENTER AN "R" TO REENTER' TO MERROR
            @ 25,2 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 25,0  GET MREENTER PICTURE '@!'
            READ
         ENDDO
         @ 25,0 CLEAR
         LOOP
      ENDIF
      
      IF DATE() - MDEL_REQD > 30 .OR. DATE() - MDEL_REQD < -30
         @ 25,0 CLEAR
         STORE ' ' TO MERROR
         DO WHILE MERROR <> 'C' .AND. MERROR <> 'E'
            @ 25,0 SAY "DELV DATE APPEARS INVALID - ENTER 'C' TO CONTINUE OR 'E' TO EDIT " GET MERROR PICTURE '@!'
            READ
         ENDDO
         @ 25,0 CLEAR
         IF MERROR <> 'C'
            LOOP
         ENDIF
      ENDIF
      
      IF DATE() - MDEL_REQD > 7
         @ 25,0 CLEAR
         STORE ' ' TO MERROR
         DO WHILE MERROR <> 'C' .AND. MERROR <> 'E'
            @ 25,0 SAY "DELV DATE MORE THAN 7 DAYS OLD - ENTER 'C' TO CONTINUE OR 'E' TO EDIT " GET MERROR PICTURE '@!'
            READ
         ENDDO
         @ 25,0 CLEAR
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
            @25,0 CLEAR
            STORE 'SHIPPED FROM SUPPLIER NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @25,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @25,58 GET MSPACE
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
         @25,0 CLEAR
         SAVE SCREEN TO MADD_SCRN
         DO SUP_SEL2
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
            STORE RSUPCODE TO MRSUPCODE
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
            @25,0 CLEAR
            STORE 'REMIT TO SUPPLIER NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @25,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @25,58 GET MSPACE
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
               @25,0 CLEAR
               STORE ' ' TO MSPACE 
               MYES_NO = 'N'
               @25,10 SAY 'REMIT TO NAME NOT FOUND ON FILE - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
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
                     @25,10 SAY 'REMIT TO SUPPLIER IS INACTIVE - CANNOT SELECT ' GET MSPACE
                     READ
                     @25,0
                  ELSE 
                     MNAME_FD = .T.
                  ENDIF
               ENDIF
            ENDIF
            RESTORE SCREEN FROM MADD_SCRN 
            @25,0 CLEAR
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
            @25,0 CLEAR
            STORE 'SHIP TO CUSTOMER NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @25,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @25,58 GET MSPACE
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
         DO BUY_SEL2
         RESTORE SCREEN FROM MADD_SCRN
         STORE MDIS_NAME TO MBUY_NAME
         @25,0 CLEAR
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
         STORE BBUYCODE TO MBBUYCODE
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
            @25,0 CLEAR
            STORE 'BILL TO CUSTOMER NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @25,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @25,58 GET MSPACE
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
               @25,0 CLEAR
               STORE ' ' TO MSPACE 
               MYES_NO = 'N'
               @25,10 SAY 'BILL TO NAME NOT FOUND ON FILE - DO YOU WANT TO ADD (Y/N)? ' GET MYES_NO PICTURE '@!'
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
                     @25,0 CLEAR
                     STORE ' ' TO MSPACE 
                     @25,10 SAY 'BILL TO CUSTOMER IS INACTIVE - CANNOT SELECT ' GET MSPACE PICTURE '@!'
                     READ
                     @25,0
                  ELSE
                     MNAME_FD = .T.
                  ENDIF
               ENDIF
            ENDIF
            RESTORE SCREEN FROM MADD_SCRN
            @25,0 CLEAR
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
      SET PROC TO PO_PROC
      STORE 1 TO MACTION
      @25,0 SAY 'Action: ' + STR(MACTION,1)
      @25,13 SAY '1. Item Page      2. Edit      3. Cancel Add    4. Update Notes'
      @25,8 GET MACTION PICTURE '#' RANGE 1,4
      
      READ
      
      IF MACTION = 4
         SAVE SCREEN TO MGRACE
         DO UPDNOTES
         RESTORE SCREEN FROM MGRACE
         STORE 1 TO MACTION
         @25,0 CLEAR
         @25,0 SAY 'Action: '
         @25,13 SAY '1. Item Page      2. Edit      3. Cancel Add'
         @25,8 GET MACTION PICTURE '#' RANGE 1,3
         READ
      ENDIF
      
      IF MACTION = 1
         IF MMAIN_SHIP = ' '
            MMAIN_SHIP = 'N'
         ENDIF
         IF MMAIN_SHIP = 'N' .AND. MPO_SHIP1 <> SPACE(4)
            SELECT B
            SEEK MSALESMAN + MPO_SHIP1 + MPO_SUFF1
            IF BBUYCODE <> MBBUYCODE 
               @25,0 CLEAR
               MWAIT = ' '
               @25,0 SAY 'Shipped with PO not same as Main PO Bill to Customer - REENTER ' GET MWAIT
               READ
               MACTION = 2
            ENDIF
         ENDIF
      ENDIF
      
      DO CASE
      CASE MACTION = 1
         
         IF MBBUYCODE = 'INVN' .AND. MONTH(MSHIP_DATE) <> MONTH(MDEL_REQD)
            @25,0 CLEAR
            MWAIT = ' '
            @25,1 SAY 'INVENTORY SHIPMENT - SHIP AND DELIVERY MONTH MUST BE SAME - REENTER ' GET MWAIT
            READ
            LOOP
         ENDIF
         
         IF MBUYER_PO <> SPACE(15) .AND. MBUYER_PO <> 'HOLD Q'
            SELECT A
            DO FOX_USE WITH "CUST_PO INDEX CUST_PO", .F.
            SEEK MBBUYCODE + MBUYER_PO
            IF .NOT. EOF()
               @25,0 CLEAR
               MWAIT = ' '
               @25,1 SAY 'CUSTOMER/BUYER PO NUMBER ALREADY USED - PLEASE CHECK - REENTER ' GET MWAIT
               READ
               USE
               LOOP
            ENDIF
            USE
         ENDIF
         
         *  SET PROC TO PO_PROC
         *** WRITE BACK THIS SCREEN OF DATA
         SELECT B
         DO FILELOCK
         APPEND BLANK
         DO RECLOCK
         REPLACE PO_DTADD WITH DATE()
         UNLOCK
         DO REPLPO
         IF MBUYER_PO <> SPACE(15) .AND. MBUYER_PO <> 'HOLD Q'
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
         RELEASE MMAIN_SHIP
         RELEASE MPO_SHIP1, MPO_SHIP2, MPO_SHIP3, MPO_SHIP3, MPO_SHIP4, MPO_SHIP5, MPO_SHIP6
         RELEASE MPO_SUFF1, MPO_SUFF2, MPO_SUFF3, MPO_SUFF3, MPO_SUFF4, MPO_SUFF5, MPO_SUFF6
         
         IF MPO_SUFFIX <> 'R' .AND. MBBUYCODE <> 'NONE' .AND. MBBUYCODE <> 'INVN'
            DO PO_AGE
         ENDIF
         
         IF MCOMPANY = 'DIVISION 15' .OR. MCOMPANY = 'AMERICHICKEN, INC' .OR. MCOMPANY = 'MIDWEST FOOD -DIV 11'
            *** THIS IS FOR LOT NUMBER PROCESSING
            @25,0 CLEAR
            IF B->RSUPCODE = 'INVN'
               IF B->SUP_CODE = ' 158' .OR. B->SUP_CODE = '  85' .OR. B->SUP_CODE = '  86' .OR. B->SUP_CODE = ' 158' .or. b->sup_code = ' 243' .OR. B->SUP_CODE = ' 207'
                  IF B->SUP_CODE = '  85' .AND. B->BBUYCODE = ' 435' .AND. B->SHIP_DATE >= CTOD('06/01/2017') .AND. B->SHIP_DATE <= CTOD('06/30/2017')
                     MYES_NO = 'Y'
                  ELSE
                     MYES_NO = 'N'
                  ENDIF
               ELSE
                  MYES_NO = ' '
               ENDIF
               IF MYES_NO = ' '
                  DO WHILE MYES_NO <> 'N' .AND. MYES_NO <> 'Y'
                     @25,0 CLEAR
                     STORE 'Select Inventory by Pulling from Oldest (Y/N):' TO MWAIT
                     @25,1 GET MWAIT
                     CLEAR GETS
                     @25,50 GET MYES_NO PICTURE '@!' VALID(MYES_NO = 'Y' .OR. MYES_NO = 'N')
                     **MYES_NO = ' '
                     READ
                  ENDDO
               ENDIF
               IF MYES_NO = 'Y'
                  *** NOW PLOP OVER INTO AUTO PULL MODE
                  MERROR = .F.
                  SELECT C
                  SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
                  IF .NOT. EOF()
                     @25,0 CLEAR
                     MWAIT = ' '
                     @25,1 SAY 'ORDER ITMS ALREADY ON FILE- CANNOT ENTER A PULL ORDER.. PRESS RETURN..' GET MWAIT
                     READ
                     @25,0 CLEAR
                     MERROR = .T.
                  ENDIF
                  
                  IF B->RSUPCODE = 'INVN' .AND. B->BBUYCODE = 'INVN'
                     @25,0 CLEAR
                     MWAIT = ' '
                     @25,1 SAY 'BOTH INTO/OUT OF INVENTORY - CANNOT ENTER A PULL ORDER.. PRESS RETURN..' GET MWAIT
                     READ
                     @25,0 CLEAR
                     MERROR = .T.
                  ENDIF
                  IF MERROR
                     DO ITEM_ADD
                  ELSE
                     ** SHAMROCK FOODS GETS SPECIAL PRICED PRODUCT - QP HOLD
                     **IF B->BBUYCODE = ' 435' .AND. B->SHIP_DATE >= CTOD('06/01/2017') .AND. B->SHIP_DATE <= CTOD('12/31/2017')
                     IF B->BBUYCODE = ' 435' .AND. B->SHIP_DATE >= CTOD('06/01/2017') .AND. B->SHIP_DATE <= CTOD('06/30/2017')
                        DO ITMQPULL
                     ELSE
                        DO ITEMPULL
                     ENDIF
                  ENDIF
               ELSE
                  DO ITEM_ADD
               ENDIF
            ELSE
               DO ITEM_ADD
            ENDIF
         ELSE
            DO NEXT_PG
         ENDIF
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
*Formatted by: ToolBox Ver. 1.2  on 10/1/19 at 6:17 AM.
