****************
* Program.: CUSTMAST.PRG
* Author..: GRACE KELLER
* Date....: 03/07/06
* Notice..: Copyright (C) 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: CUSTOMER PRICING MASTER UPDATE
*

MTITLE = ' - VIEW/ADD/UPDATE PRICING MASTER'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 24,79
MCHOICE = ' '
@ 10,2 SAY 'Supplier or Customer Pricing Master (S/C): ' GET MCHOICE PICTURE '@!' VALID(MCHOICE = ' ' .OR. MCHOICE = 'S' .OR. MCHOICE = 'C')
READ
IF MCHOICE = ' '
   RETURN
ENDIF
DO CASE
CASE MCHOICE = 'C'
   **** SELECT CUSTOMER
   STORE SPACE(32) TO MBBUYNAME
   STORE 2 TO MSEL
   DO WHILE MSEL = 2
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      @ 5,2 SAY 'SELECT BILL TO CUSTOMER:'
      @ 7,2 GET MBBUYNAME PICTURE '@!'
      STORE 1 TO MSEL
      @ 24,01 SAY 'Action: ' + STR(MSEL,1)
      @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
      READ
      @24,09 GET MSEL PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MSEL = 3 .OR. MBBUYNAME = SPACE(32)
      RETURN
   ENDIF
   STORE MBBUYNAME TO MNAME
   MNAME_FD = .F.
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
   DO BBUYSEL2
   IF .NOT. MNAME_FD .OR. MACTION = 3
      CLOSE DATA
      RETURN
   ENDIF
   STORE BBUYCODE TO MCODE
   STORE NAME     TO MNAME
   STORE STREET   TO MSTREET
   STORE CITY     TO MCITY
   STORE STATE    TO MSTATE
   STORE ZIP      TO MZIP
   USE
   
   SELECT C
   DO FOX_USE WITH "&MDBFLOC.NATLMAST INDEX &MDBFLOC.NATLMAST", .F.
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.PRI_MAST INDEX &MDBFLOC.PRI_MAST", .F.
   SET FILTER TO BBUYCODE = MCODE
   GOTO TOP
OTHERWISE
   **** SELECT SUPPLIER
   STORE SPACE(32) TO MRSUPNAME
   STORE 2 TO MSEL
   DO WHILE MSEL = 2
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      @ 5,2 SAY 'SELECT REMIT TO SUPPLIER:'
      @ 7,2 GET MRSUPNAME PICTURE '@!'
      STORE 1 TO MSEL
      @ 24,01 SAY 'Action: ' + STR(MSEL,1)
      @ 24,13 SAY '1. Continue     2. Edit     3. Cancel'                                      
      READ
      @24,09 GET MSEL PICTURE '9' RANGE 1,3
      READ               
   ENDDO
   IF MSEL = 3 .OR. MRSUPNAME = SPACE(32)
      RETURN
   ENDIF
   STORE MRSUPNAME TO MNAME
   MNAME_FD = .F.
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
   DO RSUPSEL2
   IF .NOT. MNAME_FD .OR. MACTION = 3
      CLOSE DATA
      RETURN
   ENDIF
   STORE RSUPCODE TO MCODE
   STORE NAME     TO MNAME
   STORE STREET   TO MSTREET
   STORE CITY     TO MCITY
   STORE STATE    TO MSTATE
   STORE ZIP      TO MZIP
   USE
   SELECT A
   DO FOX_USE WITH "&MDBFLOC.SUP_MAST INDEX &MDBFLOC.SUP_MAST", .F.
   SET FILTER TO RSUPCODE = MCODE
   GOTO TOP
   
ENDCASE

@ 7,2 SAY MNAME
@ 8,2 SAY MSTREET
@ 9,2 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP


DIMENSION MUPDRCD(16)
DIMENSION MCK(16)
DIMENSION MCK_LINE(16)
STORE 0 TO MZERO

MNEXT_ENT = .T.

STORE ' ' TO MENTRY
@ 12,5 say '   Select One of the Following Options:'
@ 14,5 SAY '   (V) - View Master'
@ 15,5 say '   (A) - Add Items to Master'
@ 16,5 say '   (U) - Update Master'
@ 18,1 SAY 'Select:'
@ 18,9 GET MENTRY PICTURE '@!'
READ
IF MENTRY <> 'V' .AND. MENTRY <> 'A' .AND. MENTRY <> 'U'
   CLOSE DATA
   RETURN
ENDIF

SELECT A
DO CASE
CASE MENTRY  = 'A'
   @ 3,0 CLEAR
   @ 3,0 TO 6,79
   @ 4,2 SAY TRIM(MNAME) + ', ' + TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
   @ 05,1  SAY ' Product Cd  Price1   Begin Dt1    Price2   Begin Dt2    Price3   Begin Dt3'
   
   @ 23,0 TO 23,79
   MMORE = .T.
   MLINE = 8
   MPROD_DESC = SPACE(6)   
   MPRICE = 0
   MBEG_DT = CTOD('')
   DO WHILE MMORE .AND. MLINE <= 22
      
      @ MLINE,2 GET MPROD_DESC PICTURE '@!'            
      READ
      IF MPROD_DESC = SPACE(6)
         MMORE = .F.
         LOOP
      ENDIF
      
      SELECT A
      SEEK MCODE + MPROD_DESC
      IF .NOT. EOF()
         STORE PRICE1 TO MPRICE1
         STORE PRICE2 TO MPRICE2
         STORE PRICE3 TO MPRICE3
         STORE BEG_DT1 TO MBEG_DT1
         STORE BEG_DT2 TO MBEG_DT2
         STORE BEG_DT3 TO MBEG_DT3
      ELSE
         IF MCHOICE = 'C'
            *** IF CUSTOMER, GET PRICE OFF OF NATIONAL PRICING MASTER
            SELECT C
            SEEK MPROD_DESC
            MPRICE1 = PRICE
         ELSE
            STORE 0 TO MPRICE1
         ENDIF
         MBEG_DT1 = DATE()
         STORE 0 TO MPRICE2, MPRICE3
         STORE CTOD('') TO MBEG_DT2, MBEG_DT3
      ENDIF
      
      @ MLINE,14 GET MPRICE1 PICTURE '99.9999'
      @ MLINE,23 GET MBEG_DT1
      @ MLINE,36 GET MPRICE2 PICTURE '99.9999'
      @ MLINE,45 GET MBEG_DT2
      @ MLINE,58 GET MPRICE3 PICTURE '99.9999'
      @ MLINE,67 GET MBEG_DT3
      READ
      
      SELECT A
      SEEK MCODE + MPROD_DESC
      IF EOF()
         DO FILELOCK
         APPEND BLANK
         REPLACE PROD_DESC WITH MPROD_DESC
         IF MCHOICE = 'C'
            REPLACE BBUYCODE  WITH MCODE
         ELSE
            REPLACE RSUPCODE  WITH MCODE
         ENDIF
         UNLOCK
      ENDIF
      DO RECLOCK
      REPLACE PRICE1 WITH MPRICE1
      REPLACE BEG_DT1 WITH MBEG_DT1
      REPLACE PRICE2 WITH MPRICE2
      REPLACE BEG_DT2 WITH MBEG_DT2
      REPLACE PRICE3 WITH MPRICE3
      REPLACE BEG_DT3 WITH MBEG_DT3
      
      UNLOCK
      MLINE = MLINE + 1
      MPROD_DESC = SPACE(10)
      MBEG_DT    = CTOD('')
      MPRICE = 0
   ENDDO
   
OTHERWISE
   
   @ 3,0 CLEAR
   @ 3,0 TO 6,79
   IF MENTRY = 'U'
      @ 04,1  SAY 'Sel Prod Cd  Price1   Begin Dt1    Price2   Begin Dt2    Price3   Begin Dt3'
   ELSE
      @ 04,1  SAY '    Prod Cd  Price1   Begin Dt1    Price2   Begin Dt2    Price3   Begin Dt3'
   ENDIF
   @ 23,0 TO 23,79

   IF EOF()
      store ' ' to mwait
      @ 10,1 SAY 'No Product Master Information on File - Press Return to Continue ' get mwait
      READ
      @ 10,1 CLEAR
      CLOSE DATA
      RETURN
   ENDIF
   MMORE = .T.
   STORE RECNO() TO MRECNO
   DO WHILE MMORE 
      
      GOTO MRECNO
      MLINE = 7
      I = 1
      
      STORE 0 TO MCK_LINE, MUPDRCD   
      STORE SPACE(1) TO MCK
      
      DO WHILE .NOT. EOF() .AND. MMORE .AND. MLINE <= 22
         
         @ MLINE,6 SAY SUBSTR(PROD_DESC,1,6)             
         
         SELECT A
         IF PRICE1 <> 0
            @ MLINE,14 SAY PRICE1 PICTURE '99.9999'
            @ MLINE,23 SAY BEG_DT1
         ENDIF
         IF PRICE2 <> 0
            @ MLINE,36 SAY PRICE2 PICTURE '99.9999'
            @ MLINE,45 SAY BEG_DT2
         ENDIF
         IF PRICE3 <> 0
            @ MLINE,58 SAY PRICE3 PICTURE '99.9999'
            @ MLINE,67 SAY BEG_DT3
         ENDIF
         
         STORE MLINE TO MCK_LINE(I)
         STORE RECNO() TO MUPDRCD(I)
         
         MLINE = MLINE + 1
         I = I + 1
         SKIP
         STORE RECNO() TO MRECNO
         IF EOF()
            MMORE = .F.
         ENDIF
      ENDDO
      
      STORE I-1 TO MMAX_I
      
      
      IF MENTRY = 'U'
         STORE 2 TO MACTION
         DO WHILE MACTION = 2
            I = 1
            STORE SPACE(1) TO MCK(I)
            DO WHILE I<= MMAX_I
               @ MCK_LINE(I),2 GET MCK(I) PICTURE '@!'
               READ
               IF MCK(I) = 'D'
                  GOTO MUPDRCD(I)
                  DO RECLOCK
                  DELETE
                  UNLOCK
                  STORE MCK_LINE(I) TO MLINE
                  @ MLINE,1  SAY SPACE(78)
               ELSE 
                  IF MCK(I) = 'X' .OR. MCK(I) = 'C'
                     GOTO MUPDRCD(I)
                     STORE PRICE1 TO MPRICE1
                     STORE PRICE2 TO MPRICE2
                     STORE PRICE3 TO MPRICE3
                     STORE BEG_DT1 TO MBEG_DT1
                     STORE BEG_DT2 TO MBEG_DT2
                     STORE BEG_DT3 TO MBEG_DT3
                     @ MCK_LINE(I),14 GET MPRICE1 PICTURE '99.9999'
                     @ MCK_LINE(I),23 GET MBEG_DT1
                     @ MCK_LINE(I),36 GET MPRICE2 PICTURE '99.9999'
                     @ MCK_LINE(I),45 GET MBEG_DT2
                     @ MCK_LINE(I),58 GET MPRICE3 PICTURE '99.9999'
                     @ MCK_LINE(I),67 GET MBEG_DT3
                     
                     READ
                     DO RECLOCK
                     REPLACE PRICE1 WITH MPRICE1
                     REPLACE PRICE2 WITH MPRICE2
                     REPLACE PRICE3 WITH MPRICE3
                     IF MPRICE1 = 0
                        REPLACE BEG_DT1 WITH CTOD('')
                     ELSE
                        REPLACE BEG_DT1 WITH MBEG_DT1
                     ENDIF
                     IF MPRICE2 = 0
                        REPLACE BEG_DT2 WITH CTOD('')
                     ELSE
                        REPLACE BEG_DT2 WITH MBEG_DT2
                     ENDIF
                     IF MPRICE3 = 0
                        REPLACE BEG_DT3 WITH CTOD('')
                     ELSE
                        REPLACE BEG_DT3 WITH MBEG_DT3
                     ENDIF
                     UNLOCK
                  ENDIF
               ENDIF
               @ MCK_LINE(I),2 SAY MCK(I)
               I = I + 1
            ENDDO
            
            STORE 1 TO MACTION
            @ 24,01 SAY 'Action: ' + STR(MACTION,1)
            @ 24,13 SAY '1. Continue/Next Page     2. Edit      3. Finished'
            @ 24,9 GET MACTION PICTURE '9' range 1,3
            READ
         ENDDO
         IF MACTION = 3
            MMORE = .F.  
            LOOP
         ELSE
            IF MCHOICE = 'C'
               IF EOF() .OR. BBUYCODE <> MCODE
                  MMORE = .F.
               ELSE
                  @ 6,0 CLEAR TO 23,79
               ENDIF
            ELSE
               IF EOF() .OR. RSUPCODE <> MCODE
                  MMORE = .F.
               ELSE
                  @ 6,0 CLEAR TO 23,79
               ENDIF
            ENDIF
         ENDIF
      ELSE
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         @ 24,13 SAY '1. Continue/Next Page     2. Finished'
         @ 24,9 GET MACTION PICTURE '9' range 1,2
         READ
         IF MACTION = 2
            MMORE = .F.  
            LOOP
         ELSE
            IF MCHOICE = 'C'
               IF EOF() .OR. BBUYCODE <> MCODE
                  MMORE = .F.
               ELSE
                  @ 6,0 CLEAR TO 23,79
               ENDIF
            ELSE
               IF EOF() .OR. RSUPCODE <> MCODE
                  MMORE = .F.
               ELSE
                  @ 6,0 CLEAR TO 23,79
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      
   ENDDO
ENDCASE
CLOSE DATA
RETURN
* EOF: CUSTMAST.PRG
*Formatted by: ToolBox Ver. 1.2  on 3/23/6 at 2:00 PM.
