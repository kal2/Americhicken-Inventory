**********
* Program.: SUP_REC.PRG
* Author..: Grace Keller
* Date....: 01/22/88
* Notice..: Copyright 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MATCH SUPPLIER INVOICES RECEIVED WITH PO
*
DIMENSION MUPDRCD(15)  
DIMENSION MSELECT(15)
DIMENSION MDUE_DATE(15)
DIMENSION MAMT_BILL(15)
DIMENSION MSUP_INV(15)
DIMENSION MPURCH(15)
DIMENSION MI_DATE(15)
MTOT = 0
MSW_DIFF = 0
MNEXT_CUST = .T.
DO WHILE MNEXT_CUST
   MNAME_FD = .F.
   DO RSUPSEL3
   IF .NOT. MNAME_FD
      MNEXT_CUST = .F.
      LOOP
   ENDIF
   STORE NAME TO MNAME
   STORE RSUPCODE TO MRSUPCODE
   STORE STREET TO MSTREET
   STORE CITY TO MCITY
   STORE STATE TO MSTATE
   STORE ZIP TO MZIP
   STORE NET_DAYS TO MTERM_DAYS
   IF MTERM_DAYS = 0
      STORE 14 TO MTERM_DAYS
   ENDIF
   STORE 0 TO MGRND_SUP, MGRND_BILL
   SET PROC TO REC_PROC
   MTITLE = " - MATCH SUPPLIER RECIEVED INVOICES WITH PO'S"
   CLEAR
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 to 24,79
   DO REC_SF
   SELECT D
   DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
   SELECT B
   DO FOX_USE WITH "PO_HEAD INDEX PO_SUP", .F.
   
   SEEK MRSUPCODE + ' ' 
   IF EOF()
      @ 14,1 SAY "THERE ARE NO OUTSTANDING PO'S TO MATCH FOR THIS SUPPLIER"
      @ 16,1 SAY 'PLEASE REENTER THE SUPPLIER SELECTED'
      @ 17,1 SAY ' '
      WAIT 'PRESS RETURN TO CONTINUE'
      LOOP
   ENDIF
   
   STORE RECNO() TO MRECNO, MFST_REC
   SELECT C
   DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
   *** DO FILELOCK
   MBALANCE = 0
   STORE MFST_REC TO MRECNO  
   MMORE = .T.
   DO WHILE MMORE
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      DO REC_SF

      SELECT B
      STORE ' ' TO MSELECT
      STORE 0 TO MUPDRCD, MAMT_BILL, MTOT_PURCH
      STORE SPACE(12) TO MSUP_INV
      STORE CTOD(' ') TO MDUE_DATE, MI_DATE
      GOTO MRECNO
      MLINE = 08

      DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. MRSUPCODE = RSUPCODE .AND. SUP_REC = ' '
         *IF INV_NBR = SPACE(5) .AND. BBUYCODE <> 'NONE' .AND. BBUYCODE <> 'INVN'
         IF INV_NBR = SPACE(5) .AND. BBUYCODE <> 'NONE' .AND. BBUYCODE <> 'I'
            SKIP
            LOOP
         ENDIF
         I = MLINE - 7 
         STORE RECNO() TO MUPDRCD(I)
         *** MAKE THIS BE WITH THE TOT_PURCH + S/W + ADJUSTMENTS
         *** what about pallets here
         DO TOTSUP
         SELECT B
         *        IF SUP_PALL <= 0
         *           STORE TOT_PURCH + SW_PURCH - SUP_AMT1 - SUP_AMT2 + BILL_ADJ + MSW_DIFF TO MPURCH(I) 
         *        ELSE
         *           STORE TOT_PURCH + SW_PURCH - SUP_AMT1 - SUP_AMT2 + SUP_PALL + BILL_ADJ + MSW_DIFF TO MPURCH(I) 
         *        ENDIF
         STORE MTOT TO MPURCH(I) 
         *DO CASE
         *CASE MPROG_CODE = 2
         *   MPURCH(I) = MPURCH(I) + SUP_AMT1 + SUP_AMT2 + SUP_PALL
         *OTHERWISE
            IF SUP_PALL > 0
               MPURCH(I) = MPURCH(I) + SUP_PALL
            ENDIF
         *ENDCASE
         
         SELECT B
         DO REC_SR
         SKIP
         MLINE = MLINE + 1
      ENDDO
      MMAX_LINE = MLINE - 1
      STORE RECNO() TO MRECNO
      IF .NOT. EOF() .AND. RSUPCODE = MRSUPCODE .AND. SUP_REC = ' '
         @ 23,70 SAY "More PO's"
         MBLURP = .T.
      ELSE
         @ 23,70 clear to 23,78
         MBLURP = .F.
      ENDIF
      
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         STORE 0 TO MPG_SUP, MPG_BILL
         MLINE = 8
         I = 1
         DO WHILE MLINE <= MMAX_LINE
            DO REC_GF           
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
         I = 1
         MLINE = 8
         DO WHILE MLINE <= MMAX_LINE
            IF MSELECT(I) = 'X' .OR. MSELECT(I) = 'H'
               MDUE_DATE(I) = MI_DATE(I) + MTERM_DAYS
               @mline,68 say MDUE_DATE(I) 
               IF MAMT_BILL(I) = 0
                  STORE MPURCH(I) TO MAMT_BILL(I)
                  @ MLINE,57 SAY MAMT_BILL(I) PICTURE '999,999.99'
               ENDIF
               MPG_SUP  = MPG_SUP  + MPURCH(I)
               MPG_BILL = MPG_BILL + MAMT_BILL(I)
            ENDIF
            I = I + 1
            MLINE = MLINE + 1
         ENDDO
         @ 5,55 SAY MPG_SUP  + MGRND_SUP  PICTURE '999,999.99'
         @ 5,68 SAY MPG_BILL + MGRND_BILL PICTURE '999,999.99'

         IF MBLURP
            @24,09 GET MACTION PICTURE '9' RANGE 1,4
         ELSE
            @24,09 GET MACTION PICTURE '9' RANGE 1,3
         ENDIF
         READ               
         
         IF .NOT. MBLURP .AND. MACTION = 3
            MACTION = 4
         ENDIF
         IF MACTION <> 2 .AND. MACTION <> 4
            MLINE = 8
            I = 1
            DO WHILE MLINE <= MMAX_LINE
               IF MSELECT(I) = 'X'  .OR. MSELECT(I) = 'H'
                  IF MAMT_BILL(I) = 0
                      I = I + 1
                      MLINE = MLINE + 1
                      LOOP
                  ENDIF
                  IF MAMT_BILL(I) > MPURCH(I)
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'AMOUNT BILLED CANNOT BE MORE THAN PO AMT ON LINE' + STR(I,2) + ' - PRESS RETURN  ' GET MWAIT
                     READ 
                     @ 24,0 CLEAR
                     MACTION = 2
                     MLINE = 99
                     LOOP
                  ENDIF
                  MDIFF = MPURCH(I) - MAMT_BILL(I)
                  IF MDIFF > 0 .AND. MDIFF <= 1000
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     DO WHILE MWAIT <> 'C'
                        @ 24,0 SAY 'NOTE: UNDERBILLING LESS THAN $1000 ON LINE ' + STR(I,2) + '-ENTER "C" TO CONTINUE ' GET MWAIT PICTURE '@!'
                        READ 
                     ENDDO
                     @ 24,0 CLEAR
                  ENDIF

                  IF MSUP_INV(I) = SPACE(12)        
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'INVOICE NBR NOT ENTERED ON LINE ' + STR(I,2) + ' - PRESS RETURN TO REENTER ' GET MWAIT
                     READ 
                     @ 24,0 CLEAR
                     MACTION = 2
                     MLINE = 99
                     LOOP
                  ENDIF
                  IF DTOC(MI_DATE(I)) = '  /  /  '
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'INVOICE DATE NOT ENTERED ON LINE ' + STR(I,2) + ' - PRESS RETURN TO REENTER ' GET MWAIT
                     READ 
                     @ 24,0 CLEAR
                     MACTION = 2
                     MLINE = 99
                     LOOP
                  ENDIF
                  GOTO MUPDRCD(I)
                  IF MI_DATE(I) < SHIP_DATE
                     @ 24,0 CLEAR
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'INVOICE DATE IS BEFORE THE PO SHIP DATE '+ DTOC(SHIP_DATE) + ' ON LINE ' + STR(I,2) + ' - PRESS RETURN ' GET MWAIT
                     READ 
                     @ 24,0 CLEAR
                     MACTION = 2
                     MLINE = 99
                     LOOP
                  ENDIF
               ENDIF
               MLINE = MLINE + 1
               I = I + 1
            ENDDO
         ENDIF
      ENDDO          
      
      IF MACTION = 4
         MMORE = .F.
         LOOP
      ENDIF
      DO FILELOCK
      I = 1 
      DO WHILE I <= 15
         IF MSELECT(I) <> 'X' .AND. MSELECT(I) <> 'H'
            I = I + 1
            LOOP
         ENDIF
         MGRND_SUP  = MGRND_SUP  + MPURCH(I)
         MGRND_BILL = MGRND_BILL + MAMT_BILL(I)
         GOTO MUPDRCD(I)     
         REPLACE SUP_REC WITH 'Y'
         SELECT C   
         DO FILELOCK
         APPEND BLANK
         REPLACE RSUPCODE WITH MRSUPCODE
         REPLACE SALESMAN WITH B->SALESMAN
         REPLACE PO_NBR WITH B->PO_NBR
         REPLACE PO_SUFFIX WITH B->PO_SUFFIX
         REPLACE INV_NBR WITH B->INV_NBR
         REPLACE AMT_DUE WITH MAMT_BILL(I)  
         REPLACE DUE_DATE WITH MDUE_DATE(I)
         REPLACE SUP_INV WITH MSUP_INV(I)
         IF MSELECT(I) = 'H'
           REPLACE HOLD_FLG WITH 'Y'
         ENDIF
         UNLOCK
         SELECT B
         I = I + 1
      ENDDO
      FLUSH 
      UNLOCK
      IF MACTION <> 3
         MMORE = .F.
      ENDIF
   ENDDO
ENDDO
SELECT C
UNLOCK
CLOSE DATA

RETURN
* EOF: SUP_REC.PRG
*Formatted by: dANALYST Ver. 7.3a on April 27, 1988 at 12:27 PM.
