******************
* Program.: SEL_VW.PRG
* Author..: Grace Keller
* Date....: 05/19/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PURCHASE ORDER VIEW  
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

IF MPICK
   STORE SPACE(32) TO MRSUPNAME, MBBUYNAME, MFRT_NAME
ENDIF
DIMENSION MUPDRCD(15)  
DIMENSION MSELECT(15)

IF MPROG_CODE = 2
   MACTION = 2
   MYES_NO = 'NO '
   DO WHILE MACTION = 2
      CLEAR 
      @  1,0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - PURCHASE ORDER VIEW'
      @  2,0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      @ 10,5 SAY 'Update your inquiry index files (YES/NO)? ' get myes_no
      @ 12,5 say '(NOTE: Select "YES" to update index files if you)'           
      @ 13,5 say '(have added purchase orders since last inquiry.)'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Cancel'                                     
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MACTION = 1 .AND. MYES_NO = 'YES'
      SELECT A
      USE PO_HEAD               
      @ 17,15 SAY 'CREATING INDEX FILES...............'
      INDEX ON BBUYCODE + STR(CTOD('12/31/2099') - SHIP_DATE,10) TO TMP_BUY
      INDEX ON RSUPCODE + STR(CTOD('12/31/2099') - SHIP_DATE,10) TO TMP_SUP
      INDEX ON FRT_CODE1 + STR(CTOD('12/31/2099') - SHIP_DATE,10) TO TMP_FRT
      USE   
   ENDIF
   
ENDIF

MPO_FD = .F.
STORE 1 TO MACTION
MPO_SEL = .T.
DO WHILE MPO_SEL
   IF MPICK       
      CLEAR 
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      MTITLE = ' - SELECTION MENU'
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 TO 22,79
      @  4, 5 SAY 'Enter One of the Following Search Fields:'
      @ 08,3 say  'Customer Name:'
      @ 12,3 say  'Supplier Name:'
      @ 16,3 say  ' Freight Name:'
      
      @ 08,18 GET MBBUYNAME PICTURE '@!'
      @ 12,18 GET MRSUPNAME PICTURE '@!'
      @ 16,18 GET MFRT_NAME PICTURE '@!'
      
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
      @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 3
         MPO_SEL = .F.
         LOOP
      ENDIF
   ENDIF

   IF MACTION = 1 .OR. .NOT. MPICK
      DO CASE
      CASE MBBUYNAME <> SPACE(32)
         IF MPICK
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
         ENDIF
         STORE BBUYCODE TO MSVCODE
         STORE NAME TO MNAME
         STORE STREET TO MSTREET
         STORE CITY TO MCITY
         STORE STATE TO MSTATE
         USE       
         SELECT C
         DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
         SELECT B
         DO FOX_USE WITH "PO_HEAD INDEX TMP_BUY", .F.
         SEEK MSVCODE
         IF EOF()
            @ 4,1  CLEAR TO 21,78
            @ 10,5 SAY 'NO PURCHASE ORDERS ON FILE FOR THIS CUSTOMER'
            STORE ' ' TO MWAIT
            @ 12,5 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT 
            READ
            IF .NOT. MPICK
               MPO_SEL = .F.
            ENDIF
            LOOP
         ENDIF
         MTITLE = ' - DISPLAY PURCHASE ORDERS ON FILE FOR CUSTOMER'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         @ 04,1 SAY MNAME
         @ 5,1 SAY TRIM(MSTREET) + ',  ' + TRIM(MCITY) + ',  ' + MSTATE
         @ 06,1 TO 06,78
         @ 07,1  SAY '   Sel  PO Nbr      Inv Nbr   Ship Date  Cust PO Nbr   Supplier          Paid'
         STORE RECNO() TO MVWRECNO
         DO WHILE .NOT. EOF() .AND. BBUYCODE = MSVCODE
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
            SELECT D
            DO FOX_USE WITH "PAYMENTS INDEX PAY_PO", .F.
            STORE ' ' TO MSELECT, MUPDRCD
            SELECT B
            GOTO MVWRECNO
            MLINE = 08
            @ 08,1 CLEAR TO 23,78
            @ 24,0 CLEAR
            DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. BBUYCODE = MSVCODE
               I = MLINE - 7
               @ MLINE,1 SAY STR(I,2) + '.'
               STORE RECNO() TO MUPDRCD(I)
               IF SALESMAN <> SPACE(2)
                  @ MLINE,8 SAY SALESMAN + '-'
               ENDIF
               @ MLINE,12 SAY PO_NBR
               IF PO_SUFFIX <> SPACE(1)
                  @ MLINE,16 SAY '-' + PO_SUFFIX
               ENDIF
               IF SALESMAN <> SPACE(2)
                  @ MLINE,21 SAY SALESMAN + '-'
               ENDIF
               @ MLINE,24 SAY INV_NBR   
               @ MLINE,31 SAY SHIP_DATE
               @ MLINE,42 SAY BUYER_PO
               STORE PAID_FLG TO MPAID
               SELECT A
               SEEK B->RSUPCODE
               IF EOF()
                  STORE 'SUPP NOT ON FILE      ' TO MNAME
               ELSE
                  STORE NAME TO MNAME
               ENDIF
               @ MLINE,56 SAY SUBSTR(MNAME,1,18)
               SELECT D
               SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
               @ MLINE,77 SAY MPAID
               SELECT B
               SKIP
               MLINE = MLINE + 1
            ENDDO
            MVW_MAX = MLINE - 1
            STORE RECNO() TO MVWRECNO
            IF .NOT. EOF() .AND. BBUYCODE = MSVCODE
               @ 25,70 SAY "More PO's"
               MVWBLURP = .T.
            ELSE
               @ 25,70 CLEAR TO 25,78
               MVWBLURP = .F.
            ENDIF
            @ 25,01 SAY 'Action: ' + STR(MACTION,1)
            IF MVWBLURP
               @ 25,13 SAY '1. Continue/Next Page     2. Edit    3. Finished'    
            ELSE
               @ 25,13 SAY '1. Continue/Return     2. Edit     3. Finished'    
            ENDIF
            STORE 2 TO MACTION
            DO WHILE MACTION = 2
               MVWLINE = 8
               MVWI = 1
               DO WHILE MVWLINE <= MVW_MAX
                  @ MVWLINE,5 GET MSELECT(MVWI) PICTURE '@!'
                  READ
                  IF MSELECT(MVWI) = 'X'
                     SELECT A
                     USE 
                     SELECT D
                     USE
                     SELECT B
                     GOTO MUPDRCD(MVWI)
                     SAVE SCREEN TO MVW_SCREEN
                     MVIEW = .T.
                     DO POVWMAIN
                     RESTORE SCREEN FROM MVW_SCREEN
                     MSELECT(MVWI) = ' '
                  ENDIF
                  @ MVWLINE,5 SAY ' '
                  MVWLINE = MVWLINE + 1
                  MVWI = MVWI + 1
               ENDDO
               STORE 1 TO MACTION
               @ 25,9 GET MACTION PICTURE '9' RANGE 1,3
               READ
            ENDDO
            
            IF MACTION = 3 
               SELECT B
               GOTO BOTTOM
               SKIP
               LOOP
            ENDIF
            IF .NOT. MVWBLURP .AND. MACTION = 1
               SELECT B
               GOTO BOTTOM
               SKIP
               LOOP
            ENDIF
            SELECT B
            GOTO MVWRECNO
         ENDDO
         IF .NOT. MPICK
            MPO_SEL = .F.
            SET PROC TO BUY_PROC
            LOOP
         ENDIF
      CASE MRSUPNAME <> SPACE(32)
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
         STORE RSUPCODE TO MSVCODE   
         STORE NAME TO MNAME
         STORE STREET TO MSTREET
         STORE CITY TO MCITY
         STORE STATE TO MSTATE
         
         SELECT C
         DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
         SELECT B
         DO FOX_USE WITH "PO_HEAD INDEX TMP_SUP", .F.
         SEEK MSVCODE
         IF EOF()
            @ 4,1  CLEAR TO 21,78
            @ 10,5 SAY 'NO PURCHASE ORDERS ON FILE FOR THIS SUPPLIER'
            STORE ' ' TO MWAIT
            @ 12,5 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT 
            READ
            LOOP
         ENDIF
         MTITLE = ' - DISPLAY PURCHASE ORDERS ON FILE FOR SUPPLIER'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         @ 04,1 SAY MNAME
         @ 5,1 SAY TRIM(MSTREET) + ',  ' + TRIM(MCITY) + ',  ' + MSTATE
         @ 06,1 TO 06,78
         @ 07,1  SAY '   Sel  PO Nbr      Inv Nbr   Ship Date  Sup Inv Nbr   Customer          Paid'
         STORE RECNO() TO MVWRECNO
         DO WHILE .NOT. EOF() .AND. RSUPCODE = MSVCODE
            SELECT D 
            DO FOX_USE WITH "DISBJRN INDEX DISB_PO", .F.
            SELECT E
            DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
            STORE ' ' TO MSELECT, MUPDRCD
            SELECT B
            GOTO MVWRECNO
            MLINE = 08
            @ 08,1 CLEAR TO 23,78
            @ 24,0 CLEAR
            DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. RSUPCODE = MSVCODE
               I = MLINE - 7
               @ MLINE,1 SAY STR(I,2) + '.'
               STORE RECNO() TO MUPDRCD(I)
               IF SALESMAN <> SPACE(2)
                  @ MLINE,9 SAY SALESMAN + '-'
               ENDIF
               @ MLINE,12 SAY PO_NBR
               IF PO_SUFFIX <> SPACE(1)
                  @ MLINE,16 SAY '-' + PO_SUFFIX
               ENDIF
               IF SALESMAN <> SPACE(2)
                  @ MLINE,21 SAY SALESMAN + '-'
               ENDIF
               @ MLINE,24 SAY INV_NBR    
               @ MLINE,30 SAY SHIP_DATE
               STORE SPACE(12) TO MSUP_INV
               STORE SUP_PD TO MPAID
               IF MPAID <> ' '
                  SELECT D 
                  SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
                  IF .NOT. EOF()
                     DO WHILE .NOT. EOF() .AND. SALESMAN = B->SALESMAN .AND. PO_NBR = B->PO_NBR .AND. PO_SUFFIX = B->PO_SUFFIX                   
                        IF ACCT_TYPE = 'S'
                           STORE BILL_INV TO MSUP_INV
                        ENDIF
                        SKIP
                     ENDDO
                  ENDIF
               ELSE
                  SELECT E
                  SEEK MSVCODE
                  DO WHILE .NOT. EOF() .AND. RSUPCODE = MSVCODE .AND. MSUP_INV = SPACE(12)
                     IF SALESMAN = B->SALESMAN .AND. PO_NBR = B->PO_NBR .AND. PO_SUFFIX = B->PO_SUFFIX
                        STORE SUP_INV TO MSUP_INV
                     ENDIF
                     SKIP
                  ENDDO
               ENDIF
               **** FIND THE SUPPLIER INVOICE NUMBER HERE 
               @ MLINE,42 SAY MSUP_INV
               SELECT A
               SEEK B->BBUYCODE
               IF EOF()
                  STORE 'CUST NOT ON FILE     ' TO MNAME
               ELSE
                  STORE NAME TO MNAME
               ENDIF
               @ MLINE,56 SAY SUBSTR(MNAME,1,18)
               @ MLINE,77 SAY MPAID
               SELECT B
               SKIP
               MLINE = MLINE + 1
            ENDDO
            MVW_MAX = MLINE - 1
            STORE RECNO() TO MVWRECNO
            IF .NOT. EOF() .AND. RSUPCODE = MSVCODE
               @ 25,70 SAY "More PO's"
               MVWBLURP = .T.
            ELSE
               @ 25,70 CLEAR TO 25,78
               MVWBLURP = .F.
            ENDIF
            @ 25,01 SAY 'Action: ' + STR(MACTION,1)
            IF MVWBLURP
               @ 25,13 SAY '1. Continue/Next Page     2. Edit    3. Finished'    
            ELSE
               @ 25,13 SAY '1. Continue/Return     2. Edit     3. Finished'    
            ENDIF
            STORE 2 TO MACTION
            DO WHILE MACTION = 2
               MVWLINE = 8
               MVWI = 1
               DO WHILE MVWLINE <= MVW_MAX
                  @ MVWLINE,5 GET MSELECT(MVWI) PICTURE '@!'
                  READ
                  IF MSELECT(MVWI) = 'X'
                     SELECT D
                     USE
                     SELECT E
                     USE
                     SELECT A
                     USE
                     SELECT B
                     GOTO MUPDRCD(MVWI)
                     SAVE SCREEN TO MVW_SCREEN
                     MVIEW = .T.
                     DO POVWMAIN
                     RESTORE SCREEN FROM MVW_SCREEN
                     MSELECT(MVWI) = ' '
                  ENDIF
                  @ MVWLINE,5 SAY ' '
                  MVWLINE = MVWLINE + 1
                  MVWI = MVWI + 1
               ENDDO
               STORE 1 TO MACTION
               
               @ 25,9 GET MACTION PICTURE '9' RANGE 1,3
               READ
            ENDDO
            
            IF MACTION = 3 
               SELECT B
               GOTO BOTTOM
               SKIP
               LOOP
            ENDIF
            IF .NOT. MVWBLURP .AND. MACTION = 1
               SELECT B
               GOTO BOTTOM
               SKIP
               LOOP
            ENDIF
            SELECT B
            GOTO MVWRECNO
         ENDDO
         
         
      CASE MFRT_NAME <> SPACE(32)
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
         STORE FRT_CODE TO MSVCODE    
         STORE NAME TO MNAME
         STORE STREET TO MSTREET
         STORE CITY TO MCITY
         STORE STATE TO MSTATE
         
         SELECT C
         DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
         SELECT B
         DO FOX_USE WITH "PO_HEAD INDEX TMP_FRT", .F.
         SEEK MSVCODE
         IF EOF()
            @ 4,1  CLEAR TO 21,78
            @ 10,5 SAY 'NO PURCHASE ORDERS ON FILE FOR THIS FREIGHT CARRIER'
            STORE ' ' TO MWAIT
            @ 12,5 SAY 'PRESS RETURN TO CONTINUE ' GET MWAIT 
            READ
            LOOP
         ENDIF
         MTITLE = ' - DISPLAY PURCHASE ORDERS ON FILE FOR FREIGHT CARRIER'
         CLEAR
         @  1, 0 SAY MCOMPANY
         @  1,68 SAY DATE()
         @  2, 0 SAY MPROGRAM + MTITLE
         @ 3,0 to 24,79
         @ 04,1 SAY MNAME
         @ 5,1 SAY TRIM(MSTREET) + ',  ' + TRIM(MCITY) + ',  ' + MSTATE
         @ 06,1 TO 06,78 
         @ 07,1  SAY '   Sel PO Nbr     Inv Nbr  Ship Dt   Frt Inv Nbr   Supplier    Customer  Paid'
         STORE RECNO() TO MVWRECNO
         DO WHILE .NOT. EOF() .AND. FRT_CODE1 = MSVCODE
            SELECT D 
            DO FOX_USE WITH "DISBJRN INDEX DISB_PO", .F.
            SELECT E
            DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
            SELECT A
            DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
            SELECT F
            DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
            STORE ' ' TO MSELECT, MUPDRCD
            SELECT B
            GOTO MVWRECNO
            MLINE = 08
            @ 08,1 CLEAR TO 23,78
            @ 24,0 CLEAR
            DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. FRT_CODE1 = MSVCODE
               I = MLINE - 7
               @ MLINE,1 SAY STR(I,2) + '.'
               STORE RECNO() TO MUPDRCD(I)
               IF SALESMAN <> SPACE(2)
                  @ MLINE,8 SAY SALESMAN + '-'
               ENDIF
               @ MLINE,11 SAY PO_NBR
               IF PO_SUFFIX <> SPACE(1)
                  @ MLINE,15 SAY '-' + PO_SUFFIX
               ENDIF
               IF SALESMAN <> SPACE(2)
                  @ MLINE,19 SAY SALESMAN + '-'
               ENDIF
               @ MLINE,22 SAY INV_NBR   
               @ MLINE,28 SAY SHIP_DATE
               STORE SPACE(12) TO MFRT_INV
               STORE FRT_PD TO MPAID
               IF MPAID <> ' '
                  SELECT D 
                  SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
                  IF .NOT. EOF()
                     DO WHILE .NOT. EOF() .AND. SALESMAN = B->SALESMAN .AND. PO_NBR = B->PO_NBR .AND. PO_SUFFIX = B->PO_SUFFIX                   
                        IF ACCT_TYPE = 'F'
                           STORE BILL_INV TO MFRT_INV
                        ENDIF
                        SKIP
                     ENDDO
                  ENDIF
               ELSE
                  SELECT E
                  SEEK MSVCODE
                  DO WHILE .NOT. EOF() .AND. FRT_CODE = MSVCODE .AND. MFRT_INV = SPACE(12)
                     IF SALESMAN = B->SALESMAN .AND. PO_NBR = B->PO_NBR .AND. PO_SUFFIX = B->PO_SUFFIX
                        STORE FRT_INV TO MFRT_INV
                     ENDIF
                     SKIP
                  ENDDO
               ENDIF
               @ MLINE,39 SAY MFRT_INV
               SELECT A
               SEEK B->RSUPCODE
               IF EOF()
                  STORE 'NOTONFILE' TO MSNAME
               ELSE
                  STORE NAME TO MSNAME
               ENDIF
               
               SELECT F
               SEEK B->BBUYCODE
               IF EOF()
                  STORE 'NOTONFILE' TO MBNAME
               ELSE
                  STORE NAME TO MBNAME
               ENDIF
               @ MLINE,52 SAY SUBSTR(MSNAME,1,9)
               @ MLINE,62 SAY '/'
               @ MLINE,64 SAY SUBSTR(MBNAME,1,9)
               @ MLINE,77 SAY MPAID
               SELECT B
               SKIP
               MLINE = MLINE + 1
            ENDDO
            MVW_MAX = MLINE - 1
            STORE RECNO() TO MVWRECNO
            IF .NOT. EOF() .AND. FRT_CODE1 = MSVCODE
               @ 25,70 SAY "More PO's"
               MVWBLURP = .T.
            ELSE
               @ 25,70 CLEAR TO 25,78
               MVWBLURP = .F.
            ENDIF
            @ 25,01 SAY 'Action: ' + STR(MACTION,1)
            IF MVWBLURP
               @ 25,13 SAY '1. Continue/Next Page     2. Edit    3. Finished'    
            ELSE
               @ 25,13 SAY '1. Continue/Return     2. Edit     3. Finished'    
            ENDIF
            STORE 2 TO MACTION
            DO WHILE MACTION = 2
               MVWLINE = 8
               MVWI = 1
               DO WHILE MVWLINE <= MVW_MAX
                  @ MVWLINE,5 GET MSELECT(MVWI) PICTURE '@!'
                  READ
                  IF MSELECT(MVWI) = 'X'
                     SELECT D
                     USE
                     SELECT E
                     USE
                     SELECT A
                     USE
                     SELECT F
                     USE
                     SELECT B
                     GOTO MUPDRCD(MVWI)
                     SAVE SCREEN TO MVW_SCREEN
                     MVIEW = .T.
                     DO POVWMAIN
                     RESTORE SCREEN FROM MVW_SCREEN
                     MSELECT(MVWI) = ' '
                  ENDIF
                  @ MVWLINE,5 SAY ' '
                  MVWLINE = MVWLINE + 1
                  MVWI = MVWI + 1
               ENDDO
               STORE 1 TO MACTION
               
               @ 25,9 GET MACTION PICTURE '9' RANGE 1,3
               READ
            ENDDO
            
            IF MACTION = 3 
               SELECT B
               GOTO BOTTOM
               SKIP
               LOOP
            ENDIF
            IF .NOT. MVWBLURP .AND. MACTION = 1
               SELECT B
               GOTO BOTTOM
               SKIP
               LOOP
            ENDIF
            SELECT B
            GOTO MVWRECNO
         ENDDO
         
      OTHERWISE
         MPO_SEL = .F.
         LOOP
      ENDCASE
   ENDIF
   STORE SPACE(32)   TO MRSUPNAME, MBBUYNAME, MFRT_NAME
ENDDO

RETURN
* EOF: SEL_VW.PRG


*Formatted by: ToolBox Ver. 1.2  on 4/12/93 at 9:25 AM.
