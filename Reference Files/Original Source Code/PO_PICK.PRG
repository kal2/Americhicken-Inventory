******************
* Program.: PO_PICK.PRG
* Author..: Grace Keller
* Date....: 05/03/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PURCHASE ORDER SELECT
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
STORE SPACE(2)    TO MSALESMAN, MINV_SLMN
STORE SPACE(4)    TO MPO_NBR
STORE SPACE(1)    TO MPO_SUFFIX
STORE SPACE(5)    TO MINV_NBR
STORE SPACE(12) TO MSUP_INV, MFRT_INV
store space(15) TO MBUYER_PO
STORE SPACE(32) TO MRSUPNAME, MBBUYNAME, MFRT_NAME
STORE DATE() TO MDATE
STORE TIME() TO MTIME
DIMENSION MFLAG(15)
MPO_FD = .F.
MLAST_PG = .F.
MSW_PG = .F.
STORE 1 TO MACTION
MPO_SEL = .T.
DO WHILE MPO_SEL
   SELECT B
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD, PRINT, PO_SUP, PO_SHIP, PO_FRT", .F.
   SELECT C
   DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
   CLEAR 
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   MTITLE = ' - SELECT PURCHASE ORDER EDIT/VIEW'
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   @  4, 5 SAY 'Enter One of the Following Search Fields:'
   @  7, 3 SAY '      Midwest PO Nbr:'
   @ 7,27 say '-'
   @ 7,32 say '-'
   @ 10,3 say  ' Midwest Invoice Nbr:'
   @ 10,27 say '-'
   @ 12,44 SAY 'Name' 
   @ 14,3 say  '     Customer PO Nbr:'
   @ 16,3 say  'Supplier Invoice Nbr:'
   @ 18,3 say  ' Freight Invoice Nbr:'
   
   @ 7,25 GET Msalesman PICTURE '##'
   @ 7,28 get mpo_nbr picture '####'
   @ 7,33 get mpo_suffix picture '@!'
   @ 10,25 get MINV_SLMN picture '##'
   @ 10,28 GET MINV_NBR PICTURE '#####'
   @ 14,25 GET MBUYER_PO PICTURE '@!'
   @ 14,44 GET MBBUYNAME PICTURE '@!'
   @ 16,25 GET MSUP_INV PICTURE '@!'
   @ 16,44 GET MRSUPNAME PICTURE '@!'
   @ 18,25 GET MFRT_INV PICTURE '@!'
   @ 18,44 GET MFRT_NAME PICTURE '@!'
   
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   IF MVIEW
*     @ 24,12 SAY "1.View All Info   2.View SW'S   3.View Last Pg.  4.Edit   5.Finished"                                     
      @ 24,12 SAY "1.View Info  2.View SW'S  3.View Brief  4.Edit  5.Finish  6.Prt Ord"                                     
   ELSE
      @ 24,12 SAY '1. Continue    2. Edit    3. Finished'
   ENDIF
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,5
   READ               
   
   *** THIS IS FOR EDIT PROCESSING
   IF MVIEW 
      IF MACTION = 4
         LOOP
      ENDIF
   ELSE  
      IF MACTION = 2
         LOOP
      ENDIF
   ENDIF
   
   *** THIS IS FOR FINISHED PROCESSING
   IF MVIEW 
      IF MACTION = 5
         MPO_SEL = .F.
         LOOP
      ENDIF
   ELSE
      IF MACTION = 3
         MPO_SEL = .F.
         LOOP
      ENDIF
   ENDIF
   
   IF MVIEW
      IF MACTION = 3
         MLAST_PG = .T.
      ELSE
         IF MACTION = 2
            MSW_PG = .T.
         ENDIF
      ENDIF
   ENDIF

   IF MVIEW .AND. MACTION = 6
      SELECT  B
      SEEK MSALESMAN+MPO_NBR+MPO_SUFFIX
      IF EOF()       
         @ 24,0 CLEAR
         @ 24,1 SAY 'CANNOT PRINT - SALES ORDER NOT ON FILE - PRESS RETURN ' GET MWAIT
      ELSE
         DO PRT_ONE
      ENDIF
      STORE SPACE(2) TO MSALESMAN
      STORE SPACE(4) TO MPO_NBR
      STORE SPACE(1) TO MPO_SUFFIX
      LOOP
   ENDIF
   

   DO CASE
   CASE MPO_NBR <> SPACE(4)
      SELECT B
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      IF EOF() 
         @ 23,0 CLEAR
         MWAIT = ' '
         @ 24,10 SAY 'PURCHASE ORDER NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
         READ
         LOOP
      ENDIF
      
   CASE MINV_NBR <> SPACE(5)
      STORE STR(VAL(MINV_NBR),5) TO MINV_NBR
      SELECT A
      DO FOX_USE WITH "INV_HEAD INDEX INV_HEAD", .F.
      
      SEEK MINV_NBR
      IF EOF() 
         @ 23,0 CLEAR
         MWAIT = ' '
         @ 24,10 SAY 'INVOICE NUMBER NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
         READ
         @ 24,0 CLEAR
         LOOP
      ELSE
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         SELECT B
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF EOF()
            @ 23,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'CANNOT FIND MATCHING PURCHASE ORDER ON FILE - SELECT AGAIN ' GET MWAIT
            READ
            @ 24,0 CLEAR
            LOOP
         ENDIF
         
      ENDIF
      
   CASE MBUYER_PO <> SPACE(15)
      STORE MBBUYNAME TO MNAME
      MNAME_FD = .F.
      STORE TRIM(MNAME) TO SRCH_ARG
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
      SEEK SRCH_ARG
      IF EOF()
         @ 24,0 CLEAR
         STORE ' ' TO MSPACE 
         @ 24,10 SAY 'BILL TO NAME NOT FOUND ON FILE - PLEASE RETURN TO REENTER ' GET MSPACE PICTURE '@!'
         READ
         LOOP
      ELSE 
         STORE RECNO() TO MFST_REC
         SKIP
         IF NAME = SRCH_ARG
            MADD = .F.
            DO MUL1BBUY
            IF MACTION <> 5
               MNAME_FD = .T.
            ENDIF
         ELSE
            GOTO MFST_REC
            MNAME_FD = .T.
         ENDIF
      ENDIF
      
      
      IF .NOT. MNAME_FD
         LOOP              
      ENDIF
      STORE BBUYCODE TO MBBUYCODE
      SELECT A
      DO FOX_USE WITH "CUST_PO INDEX CUST_PO", .F.
      STORE MBBUYCODE + TRIM(MBUYER_PO) TO  SRCH_ARG
      SEEK SRCH_ARG
      IF EOF() 
         @ 23,0 CLEAR
         MWAIT = ' '
         @ 24,10 SAY 'CUSTOMER PO # NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
         READ
         @ 24,0 CLEAR
         LOOP
      ELSE
         STORE RECNO() TO MFST_REC
         SKIP
         IF BBUYCODE+TRIM(BUYER_PO) = SRCH_ARG
            MPO_FD = .F.
            DO MULT_PO 
            IF MACTION <> 4
               MPO_FD = .T.
            ENDIF
         ELSE
            GOTO MFST_REC
            MPO_FD = .T.
         ENDIF
      ENDIF
      IF .NOT. MPO_FD
         LOOP              
      ENDIF
      
      
      STORE SALESMAN TO MSALESMAN
      STORE PO_NBR TO MPO_NBR
      STORE PO_SUFFIX TO MPO_SUFFIX
      SELECT B
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      IF EOF()
         @ 23,0 CLEAR
         MWAIT = ' '
         @ 24,10 SAY 'CANNOT FIND MATCHING PURCHASE ORDER ON FILE - SELECT AGAIN ' GET MWAIT
         READ
         @ 24,0 CLEAR
         LOOP
      ENDIF
      SELECT A
      USE
      SELECT B

   CASE MSUP_INV <> SPACE(12)
      STORE MRSUPNAME TO MNAME
      MNAME_FD = .F.
      STORE TRIM(MNAME) TO SRCH_ARG
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
      SEEK SRCH_ARG
      IF EOF() .OR. DELETED()
         @ 24,0 CLEAR
         STORE ' ' TO MSPACE 
         @ 24,10 SAY 'REMIT TO NAME NOT FOUND ON FILE - PRESS RETURN TO REENTER ' GET MSPACE PICTURE '@!'
         READ
         LOOP
      ELSE               
         STORE RECNO() TO MFST_REC
         SKIP
         IF NAME = SRCH_ARG
            MADD = .F.
            DO MUL1RSUP
            IF MACTION <> 5
               MNAME_FD = .T.
            ENDIF
         ELSE
            GOTO MFST_REC
            MNAME_FD = .T.
         ENDIF
      ENDIF
      IF .NOT. MNAME_FD
         LOOP
      ENDIF
      STORE RSUPCODE TO MACCT_NBR  
      I = 1  
      MCHAR = .F.
      DO WHILE I<=12
         DO CASE  
         CASE SUBSTR(MSUP_INV,I,1) = '0' .OR. SUBSTR(MSUP_INV,I,1) = '1'      
         CASE SUBSTR(MSUP_INV,I,1) = '2' .OR. SUBSTR(MSUP_INV,I,1) = '3'      
         CASE SUBSTR(MSUP_INV,I,1) = '4' .OR. SUBSTR(MSUP_INV,I,1) = '5'      
         CASE SUBSTR(MSUP_INV,I,1) = '6' .OR. SUBSTR(MSUP_INV,I,1) = '7'      
         CASE SUBSTR(MSUP_INV,I,1) = '8' .OR. SUBSTR(MSUP_INV,I,1) = '9'      
         CASE SUBSTR(MSUP_INV,I,1) = ' ' 
         OTHERWISE
            MCHAR = .T.
         ENDCASE
         I = I + 1
      ENDDO 
      IF MCHAR
         SELECT A
         DO FOX_USE WITH "DISBJRN INDEX DISBINV", .F.
         STORE TRIM(MSUP_INV) TO MSRCH
      ELSE
         SELECT A
         DO FOX_USE WITH "DISBJRN INDEX DISBSTR", .F.
         STORE STR(VAL(MSUP_INV),12) TO MSRCH
      ENDIF
      STORE 'S' + MACCT_NBR + MSRCH TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF() 
         USE SUP_INV INDEX SUP_INV
         SEEK MACCT_NBR
         DO WHILE .NOT. EOF() .AND. RSUPCODE = MACCT_NBR .AND. .NOT. MPO_FD
            IF SUP_INV = MSUP_INV
               MPO_FD = .T.
               LOOP
            ENDIF
            SKIP
         ENDDO
         IF .NOT. MPO_FD
            @ 23,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'SUPPLIER INVOICE # NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
            READ
            @ 24,0 CLEAR
            LOOP
         ELSE
            STORE SALESMAN TO MSALESMAN
            STORE PO_NBR TO MPO_NBR
            STORE PO_SUFFIX TO MPO_SUFFIX
            SELECT B
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF EOF()
               @ 23,0 CLEAR
               MWAIT = ' '
               @ 24,10 SAY 'CANNOT FIND MATCHING PURCHASE ORDER ON FILE - SELECT AGAIN ' GET MWAIT
               READ
               @ 24,0 CLEAR
               LOOP
            ENDIF
         ENDIF
      ELSE
         STORE RECNO() TO MFST_REC
         SKIP
         IF MCHAR
            IF ACCT_TYPE + ACCT_NBR + BILL_INV  = SRCH_ARG
               DO MULT_PO1
               IF MACTION <> 4
                  MPO_FD = .T.
               ENDIF
            ELSE
               GOTO MFST_REC
               MPO_FD = .T.
            ENDIF
         ELSE
            IF ACCT_TYPE + ACCT_NBR + STR(VAL(BILL_INV),12) = SRCH_ARG
               DO MULT_PO2
               IF MACTION <> 4
                  MPO_FD = .T.
               ENDIF
            ELSE
               GOTO MFST_REC
               MPO_FD = .T.
            ENDIF
         ENDIF
         IF .NOT. MPO_FD
            LOOP              
         ENDIF
         
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         SELECT B
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF EOF()
            @ 23,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'CANNOT FIND MATCHING PURCHASE ORDER ON FILE - SELECT AGAIN ' GET MWAIT
            READ
            @ 24,0 CLEAR
            LOOP
         ENDIF
      ENDIF
      SELECT A
      USE
      SELECT B
      
   CASE MFRT_INV <> SPACE(12)
      STORE MFRT_NAME TO MNAME
      MNAME_FD = .F.
      STORE TRIM(MNAME) TO SRCH_ARG
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_NAME", .F.
      SEEK SRCH_ARG
      IF EOF()
         @ 24,0 CLEAR
         STORE ' ' TO MSPACE 
         @ 24,10 SAY 'FREIGHT CARRIER NOT FOUND ON FILE - PRESS RETURN TO REENTER ' GET MSPACE PICTURE '@!'
         READ
      ELSE               
         STORE RECNO() TO MFST_REC
         SKIP
         IF NAME = SRCH_ARG
            MADD = .F.
            DO MUL1FRT 
            IF MACTION <> 5
               MNAME_FD = .T.
            ENDIF
         ELSE
            GOTO MFST_REC
            MNAME_FD = .T.
         ENDIF
      ENDIF
      IF .NOT. MNAME_FD
         LOOP
      ENDIF
      STORE FRT_CODE TO MACCT_NBR  
      I = 1  
      MCHAR = .F.
      DO WHILE I<=12
         DO CASE  
         CASE SUBSTR(MFRT_INV,I,1) = '0' .OR. SUBSTR(MFRT_INV,I,1) = '1'      
         CASE SUBSTR(MFRT_INV,I,1) = '2' .OR. SUBSTR(MFRT_INV,I,1) = '3'      
         CASE SUBSTR(MFRT_INV,I,1) = '4' .OR. SUBSTR(MFRT_INV,I,1) = '5'      
         CASE SUBSTR(MFRT_INV,I,1) = '6' .OR. SUBSTR(MFRT_INV,I,1) = '7'      
         CASE SUBSTR(MFRT_INV,I,1) = '8' .OR. SUBSTR(MFRT_INV,I,1) = '9'      
         CASE SUBSTR(MFRT_INV,I,1) = ' ' 
         OTHERWISE
            MCHAR = .T.
         ENDCASE
         I = I + 1
      ENDDO 
      IF MCHAR
         SELECT A
         DO FOX_USE WITH "DISBJRN INDEX DISBINV", .F.
         STORE TRIM(MFRT_INV) TO MSRCH
      ELSE
         SELECT A
         DO FOX_USE WITH "DISBJRN INDEX DISBSTR", .F.
         STORE STR(VAL(MFRT_INV),12) TO MSRCH
      ENDIF
      STORE 'F' + MACCT_NBR + MSRCH TO SRCH_ARG
      SEEK SRCH_ARG
      IF EOF() 
         USE FRT_INV INDEX FRT_INV
         SEEK MACCT_NBR 
         DO WHILE .NOT. EOF() .AND. FRT_CODE = MACCT_NBR .AND. .NOT. MPO_FD
            IF FRT_INV = MFRT_INV
               MPO_FD = .T.
               LOOP
            ENDIF
            SKIP
         ENDDO
         IF MPO_FD
            STORE SALESMAN TO MSALESMAN
            STORE PO_NBR TO MPO_NBR
            STORE PO_SUFFIX TO MPO_SUFFIX
            SELECT B
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF EOF()
               @ 23,0 CLEAR
               MWAIT = ' '
               @ 24,10 SAY 'CANNOT FIND MATCHING PURCHASE ORDER ON FILE - SELECT AGAIN ' GET MWAIT
               READ
               @ 24,0 CLEAR
               LOOP
            ENDIF
         ELSE
            @ 23,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'FREIGHT INVOICE # NOT ON FILE - PRESS RETURN TO SELECT AGAIN ' GET MWAIT
            READ
            @ 24,0 CLEAR
            LOOP
         ENDIF
      ELSE
         STORE RECNO() TO MFST_REC
         SKIP
         IF MCHAR
            IF ACCT_TYPE + ACCT_NBR + BILL_INV  = SRCH_ARG
               DO MULT_PO1
               IF MACTION <> 4
                  MPO_FD = .T.
               ENDIF
            ELSE
               GOTO MFST_REC
               MPO_FD = .T.
            ENDIF
         ELSE
            IF ACCT_TYPE + ACCT_NBR + STR(VAL(BILL_INV),12) = SRCH_ARG
               DO MULT_PO2
               IF MACTION <> 4
                  MPO_FD = .T.
               ENDIF
            ELSE
               GOTO MFST_REC
               MPO_FD = .T.
            ENDIF
         ENDIF
         IF .NOT. MPO_FD
            LOOP              
         ENDIF
         
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         SELECT B
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         IF EOF()
            @ 23,0 CLEAR
            MWAIT = ' '
            @ 24,10 SAY 'CANNOT FIND MATCHING PURCHASE ORDER ON FILE - SELECT AGAIN ' GET MWAIT
            READ
            @ 24,0 CLEAR
            LOOP
         ENDIF
      ENDIF
      SELECT A
      USE
      SELECT B

   OTHERWISE
      MPO_SEL = .F.
      LOOP
   ENDCASE
   
   IF MVIEW
      IF MLAST_PG
         **DO TOT_VIEW
         DO NEW_INQ
      ELSE
         IF MSW_PG
            MGO_BACK = .F.
            DO SW_VIEW
         ELSE
            DO POVWMAIN
         ENDIF
      ENDIF
   ELSE
      DO POVWMAIN
   ENDIF
   STORE SPACE(2)    TO MSALESMAN, MINV_SLMN
   STORE SPACE(4)    TO MPO_NBR
   STORE SPACE(1)    TO MPO_SUFFIX
   STORE SPACE(5)    TO MINV_NBR
   STORE SPACE(12)   TO MSUP_INV, MFRT_INV
   STORE SPACE(15)   TO MBUYER_PO
   STORE SPACE(32)   TO MRSUPNAME, MBBUYNAME, MFRT_NAME
   STORE .F. TO MLAST_PG, MSW_PG  
   
ENDDO

RETURN
* EOF: PO_PICK.PRG


*Formatted by: ToolBox Ver. 1.2  on 2/9/90 at 10:13 AM.
