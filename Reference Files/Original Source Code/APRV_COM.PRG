**********
* Program.: APRV_COM.PRG
* Author..: Grace Keller
* Date....: 05/17/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: dBASE III
* Notes...: SELECTIVELY APPROVE MIDWEST COMMISSIONS FOR PAYMENT 
*
MTITLE = ' - SELECTIVELY APPROVE MIDWEST COMMISSIONS FOR PAYMENT'
CLEAR
@  1, 1 SAY MCOMPANY
@  1,70 SAY DATE()
@  2, 1 SAY MPROGRAM + MTITLE
@ 3,0 TO 23,79
MNEXT_COM = .T.
DIMENSION MUPDRCD(15)  
DIMENSION MSELECT(15)
DIMENSION MAMT(15)

DO WHILE MNEXT_COM
   STORE SPACE(32) TO MNAME
   STORE 2 TO MACTION
   DO WHILE MACTION = 2
      @ 10,5 SAY 'SALESPERSON NAME'
      @ 12,5 GET MNAME PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2. Edit    3. Cancel'    
      READ
      @ 24,9 GET MACTION PICTURE '9' RANGE 1,3
      READ
      IF MACTION = 1
         SELECT A
         DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_NAME", .F.
         SEEK TRIM(MNAME)
         IF EOF()
            @ 24,0 CLEAR 
            STORE ' ' TO MWAIT
            @ 24,1 SAY 'SALESPERSON NOT ON FILE - PRESS RETURN TO REENTER ' GET MWAIT
            READ
            @ 24,0 CLEAR
            MACTION = 2
         ELSE
            STORE NAME TO MNAME
            STORE SALE_CODE TO MCOM_CODE
         ENDIF
      ENDIF
   ENDDO
   IF MACTION = 3
      MNEXT_COM = .F.
      LOOP
   ENDIF
   
   SELECT B
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
   SELECT E
   DO FOX_USE WITH "CUS_INV INDEX CUSIVNBR", .F.
   
   SELECT C
   DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMPD", .F.
   
   MTOTAL = 0
   MTITLE = ' - SELECTIVELY APPROVE SALESPERSON COMMISSIONS FOR PAYMENT'
   CLEAR
   @  1, 1 SAY MCOMPANY
   @  1,70 SAY DATE()
   @  2, 1 SAY MPROGRAM + MTITLE
   @ 3,0 TO 23,79
   @ 04,1 SAY MNAME
   @ 4,40 SAY 'AMT APPROVED'
   @ 06,1 TO 06,78
   
   @ 07,1  SAY '     Sel      Amt Due     P.O. Nbr.     Inv. Nbr    Inv/Cor'
   SEEK ' S' + MCOM_CODE
   IF EOF()
      @ 10,5 SAY 'THERE ARE NO COMMISSIONS TO PAY FOR THIS SALESPERSON'
      STORE ' ' TO MWAIT
      @ 12,5 SAY 'PRESS ANY KEY TO CONTINUE ' GET MWAIT
      READ
      RETURN
   ENDIF
   
   STORE RECNO() TO MRECNO, MFST_REC
   MTOTAL = 0   
   MMORE = .T.
   DO WHILE MMORE
      STORE ' ' TO MSELECT
      STORE 0 TO MUPDRCD, MADJUST
      GOTO MRECNO
      MLINE = 08
      @ 08,1 CLEAR TO 22,78
      @ 24,0 CLEAR
      MPAGE_TOT = 0
      DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. COM_PD = ' ' .AND. COM_TYPE = 'S' .AND. COM_CODE = MCOM_CODE .AND. MMORE
         STORE SALESMAN TO MSALESMAN
         STORE PO_NBR TO MPO_NBR
         STORE PO_SUFFIX TO MPO_SUFFIX
         IF INV_NBR = SPACE(5)
            MINV_NBR = SPACE(5)
            SELECT B
            DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
            SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
            IF .NOT. EOF()
               STORE INV_NBR TO MINV_NBR
            ENDIF
         ELSE
            STORE INV_NBR TO MINV_NBR
         ENDIF
         MPAID = .T.
         SELECT E
         DO FOX_USE WITH "CUS_INV INDEX CUSIVNBR", .F.
         SEEK MINV_NBR
         IF .NOT. EOF()
            IF PAID_FLG = ' '
               MPAID = .F.
            ENDIF
         ENDIF
         **** TEMPORARY
         MSKIP = .F.
         *IF MCOM_CODE = '44'
         *   SELECT B
         *   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
         *   SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         *   IF .NOT. EOF()
         *      ** SKIP OVER CENTER MEAT = ' 843'
         *      ** SKIP OVER MEADOW FARMS = ' 279'
         *      IF BBUYCODE = ' 843' .OR. BBUYCODE = ' 279'
         *         MSKIP = .T.
         *      ENDIF
         *   ENDIF
         *   SELECT C
         *ENDIF
         
         SELECT C
         I = MLINE - 7 
         STORE RECNO() TO MUPDRCD(I)
         STORE AMOUNT TO MAMT(I)
         IF APRVD_FLG <> ' '
            STORE 'X' TO MSELECT(I)
            MPAGE_TOT = MPAGE_TOT + MAMT(I)  
         ELSE 
            DO CASE
               *CASE MSKIP
               *  STORE 'S' TO MSELECT(I)
            CASE MPAID
               STORE ' ' TO MSELECT(I)
            OTHERWISE
               STORE 'N' TO MSELECT(I)
            ENDCASE
         ENDIF
         @ MLINE,1 SAY STR(I,2) + '.'
         
         @ MLINE,12 SAY AMOUNT PICTURE '999,999.99'
         IF SALESMAN <> SPACE(2)
            @ MLINE,27 SAY SALESMAN + '-'
         ENDIF
         @ MLINE,30 SAY PO_NBR
         IF PO_SUFFIX <> ' '
            @ MLINE,34 SAY '-' + PO_SUFFIX
         ENDIF
         IF SALESMAN <> SPACE(2)
            @ MLINE,41 SAY SALESMAN + '-'
         ENDIF
         @ MLINE,44 SAY MINV_NBR
         IF COR_FLG = 'I' .OR. COR_FLG = ' '
            @ MLINE,53 SAY 'INVOICE'
         ELSE
            @ MLINE,53 SAY 'CORRECTION'
         ENDIF
         SKIP
         MLINE = MLINE + 1
      ENDDO
      MMAX_LINE = MLINE - 1
      STORE RECNO() TO MRECNO
      IF .NOT. EOF() .AND. COM_PD = ' ' .AND. COM_TYPE = 'S' .AND. COM_CODE = MCOM_CODE
         @ 23,70 SAY "More PO's"
         MBLURP = .T.
      ELSE
         @ 23,70 to 23,78
         MBLURP = .F.
      ENDIF
      @ 5,41 SAY MTOTAL + MPAGE_TOT PICTURE '999,999.99'
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         MLINE = 8
         I = 1
         DO WHILE MLINE <= MMAX_LINE
            IF MSELECT(I) = 'N' .OR. MSELECT(I) = 'S'
               @ MLINE,7 SAY MSELECT(I)
            ELSE
               @ MLINE,7 GET MSELECT(I) PICTURE '@!'
            ENDIF
            MLINE = MLINE + 1
            I = I + 1
         ENDDO
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)
         IF MBLURP
            @ 24,13 SAY '1. Next Page    2. Edit    3. Save & Return    4. Cancel'    
         ELSE
            @ 24,13 SAY '1. Save & Return    2. Edit    3. Cancel'    
         ENDIF
         
         READ
         MPAGE_TOT = 0
         I = 1
         DO WHILE I <= 15
            IF MUPDRCD(I) = 0
               I = I + 1
               LOOP
            ENDIF
            IF MSELECT(I) <> 'N' .AND. MSELECT(I) <> ' ' .AND. MSELECT(I) <> 'X' .AND. MSELECT(I) <> 'S'
               @ 24,0 CLEAR
               MWAIT = ' '
               @ 24,0 SAY "SELECT OPTION MUST BE ' ' OR 'X' - PRESS RETURN TO REENTER " GET MWAIT
               READ
               @ 24,0 CLEAR
               I = 99
               MACTION = 2
               LOOP
            ENDIF
            IF MSELECT(I) = 'N' .OR. MSELECT(I) = 'S'
               I = I + 1
               LOOP
            ENDIF
            IF MSELECT(I) = 'X'
               MPAGE_TOT = MPAGE_TOT + MAMT(I)
            ENDIF
            I = I + 1
         ENDDO
         **** THIS IS AN ERROR
         IF MLINE = 99
            LOOP
         ENDIF
         @ 5,41 SAY MTOTAL + MPAGE_TOT PICTURE '999,999.99'
         
         IF MBLURP
            @24,09 GET MACTION PICTURE '9' RANGE 1,4
         ELSE
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
         ENDIF
         READ               
      ENDDO          
      
      IF .NOT. MBLURP      
         IF MACTION = 3
            MACTION = 4
         ENDIF
      ELSE
         IF MACTION = 1
            MACTION = 3
         ELSE
            IF MACTION = 3
               MACTION = 1
            ENDIF
         ENDIF
      ENDIF
      IF MACTION = 4
         MMORE = .F.
         @ 04,1 CLEAR TO 22,78
         @ 23,50 TO 23,78
         @ 24,0 CLEAR
         STORE ' ' TO MYES_NO
         @ 10,5 SAY 'DO YOU WANT TO APPROVE MORE COMMISSIONS (Y/N)? ' GET MYES_NO PICTURE '@!'
         READ
         IF MYES_NO <> 'Y'
            MNEXT_COM = .F.
         ENDIF
         @ 10,5 SAY SPACE(60)
         LOOP
      ENDIF
      MPAGE_TOT = 0
      I = 1 
      DO WHILE I <= 15
         IF MUPDRCD(I) = 0
            I = I + 1
            LOOP
         ENDIF
         ** THIS IS ALSO TEMPORARY
         IF MSELECT(I) = 'N' .OR. MSELECT(I) = 'S'
            ** COMMENT OUT ABOVE LINE IF UPDATING APRVD FLAG WITH 'S'
            **IF MSELECT(I) = 'N'
            I = I + 1
            LOOP
         ENDIF
         GOTO MUPDRCD(I)
         DO RECLOCK
         
         DO CASE
            
            *** THIS IS TEMPORARY FOR WORKING WITH AL/SUE COMMISSIONS 
            **CASE MSELECT(I) = 'S'
            **   REPLACE APRVD_FLG WITH 'S'
            ** TO SET UP WORKING RECORDS
            
         CASE MSELECT(I) = 'X'
            REPLACE APRVD_FLG WITH 'Y'       
            MPAGE_TOT = MPAGE_TOT + MAMT(I)
         OTHERWISE
            REPLACE APRVD_FLG WITH ' '
         ENDCASE
         
         UNLOCK 
         I = I + 1
      ENDDO
      MTOTAL = MTOTAL + MPAGE_TOT
      @ 5,41 SAY MTOTAL PICTURE '999,999.99'
      
      IF MACTION <> 3
         MMORE = .F.
         @ 04,1 CLEAR TO 22,78
         @ 24,0 CLEAR
         @ 23,50 TO 23,78
         STORE ' ' TO MYES_NO
         @ 10,5 SAY 'DO YOU WANT TO APPROVE MORE COMMISSIONS (Y/N)? ' GET MYES_NO PICTURE '@!'
         READ
         IF MYES_NO <> 'Y'
            MNEXT_COM = .F.
         ENDIF
         @ 10,5 SAY SPACE(60)
      ENDIF
   ENDDO
ENDDO

CLOSE DATA
RETURN
* EOF: APRV_COM.PRG

*Formatted by: ToolBox Ver. 1.2  on 12/9/97 at 1:30 PM.
