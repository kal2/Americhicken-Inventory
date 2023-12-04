***********
* Program.: FRT_REC1.PRG
* Author..: Grace Keller
* Date....: 05/01/97
* Notice..: Copyright 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MATCH FREIGHT INVOICES RECEIVED WITH PO
*
DIMENSION MUPDRCD(15)
DIMENSION MSELECT(15)
DIMENSION MDUE_DATE(15)
DIMENSION MAMT_BILL(15)
DIMENSION MFRT_INV(15)
DIMENSION MFREIGHT(15)
DIMENSION MI_DATE(15)
MTITLE = " - MATCH FREIGHT RECIEVED INVOICES WITH PO'S"
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 24,80
MFRT1 = ' '
MFRT2 = ' '
MFRT3 = ' '
MACTION = 2
DO WHILE MACTION = 2
   @ 08,3 say 'Select with an "X" which carrier to match (only select one):'
   @ 11,3 SAY 'Freight Carrier # 1  (PO Top):    ' GET MFRT1 PICTURE '@!' VALID(MFRT1 = ' ' .OR. MFRT1 = 'X')
   @ 13,3 say 'Freight Carrier # 2  (PO Bottom): ' GET MFRT2 PICTURE '@!' VALID(MFRT2 = ' ' .OR. MFRT2 = 'X')
   @ 15,3 say 'Freight Carrier # 3  (PO Bottom): ' GET MFRT3 PICTURE '@!' VALID(MFRT3 = ' ' .OR. MFRT3 = 'X')
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Continue    2. Edit     3. Cancel'    
   READ
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ
ENDDO
IF MACTION = 3
   RETURN
ENDIF
IF MFRT2 = 'X'
   DO FRT_REC2
   RETURN
ENDIF
IF MFRT3 = 'X'
   DO FRT_REC3
   RETURN
ENDIF

MTOT = 0
MSW_DIFF = 0
MNEXT_FRT = .T.
DO WHILE MNEXT_FRT
   MNAME_FD = .F.
   DO FRT_SEL1 
   IF .NOT. MNAME_FD
      MNEXT_FRT = .F.
      LOOP
   ENDIF
   STORE NAME TO MNAME
   STORE FRT_CODE TO MFRT_CODE
   STORE STREET TO MSTREET
   STORE CITY TO MCITY
   STORE STATE TO MSTATE
   STORE ZIP TO MZIP
   STORE 21 TO MTERM_DAYS
   STORE 0 TO MGRND_FRT, MGRND_BILL
   SET PROC TO REC_PROC
   MTITLE = " - MATCH FREIGHT RECIEVED INVOICES WITH PO'S"
   CLEAR
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 to 24,80
   DO FRT_SF1
   SELECT D
   DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
   SELECT B
   DO FOX_USE WITH "PO_HEAD INDEX PO_FRT", .F.
   
   SEEK MFRT_CODE + ' '
   IF EOF()
      @ 14,1 SAY "THERE ARE NO OUTSTANDING PO'S TO MATCH FOR THIS FREIGHT CARRIER"
      @ 16,1 SAY 'PLEASE REENTER THE FREIGHT CARRIER SELECTED'
      @ 17,1 SAY ' '
      WAIT 'PRESS RETURN TO CONTINUE'
      LOOP
   ENDIF
   
   STORE RECNO() TO MRECNO, MFST_REC
   SELECT C
   DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
   
   MBALANCE = 0
   STORE MFST_REC TO MRECNO  
   MMORE = .T.
   DO WHILE MMORE
      SELECT B
      STORE ' ' TO MSELECT
      STORE 0 TO MUPDRCD, MAMT_BILL, MTOT_FRT
      STORE SPACE(12) TO MFRT_INV
      STORE CTOD(' ') TO MDUE_DATE, MI_DATE
      GOTO MRECNO
      MLINE = 08
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,80
      DO FRT_SF1
      DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. MFRT_CODE = FRT_CODE1 .AND. FRT_REC = ' '
         *** IF IT HAS NOT BEEN PROCESSED THRU THE INVOICE PRINT PRG-SKIP IT
         IF INV_FLG = ' '
            SKIP
            LOOP
         ENDIF
         I = MLINE - 7 
         STORE RECNO() TO MUPDRCD(I)
         *** MAKE THIS BE WITH THE TOT_FRT + S/W + ADJUSTMENTS
         *** what about pallets here
         SELECT B
         IF FRT_PALL <= 0
            STORE FRT_AMT1 TO MFREIGHT(I) 
         ELSE
            STORE FRT_AMT1 + FRT_PALL TO MFREIGHT(I) 
         ENDIF
         MAMT_BILL(I) = FRT_AMT1+FRT1_ADJ1+FRT1_ADJ2+FRT_PALL
         SELECT B
         DO FRT_SR1
         SKIP
         MLINE = MLINE + 1
      ENDDO
      MMAX_LINE = MLINE - 1
      STORE RECNO() TO MRECNO
      IF .NOT. EOF() .AND. FRT_CODE1 = MFRT_CODE .AND. FRT_REC = ' '
         @ 24,69 SAY "More PO's"
         MBLURP = .T.
      ELSE
         @ 24,69 SAY SPACE(9)   
         MBLURP = .F.
      ENDIF
      
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         STORE 0 TO MPG_FRT, MPG_BILL
         MLINE = 8
         I = 1
         DO WHILE MLINE <= MMAX_LINE
            DO FRT_GF1          
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
            IF MSELECT(I) = 'X'
               MDUE_DATE(I) = MI_DATE(I) + MTERM_DAYS
               @ MLINE,69 SAY MDUE_DATE(I) 
               MPG_FRT  = MPG_FRT  + MFREIGHT(I)
               MPG_BILL = MPG_BILL + MAMT_BILL(I)
            ENDIF
            I = I + 1
            MLINE = MLINE + 1
         ENDDO

         @ 5,55 SAY MPG_FRT  + MGRND_FRT  PICTURE '999,999.99'
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
               IF MSELECT(I) = 'X' 
                  IF MFRT_INV(I) = SPACE(12)        
                     @ 24,0 SAY SPACE(79)
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'INVOICE NBR NOT ENTERED ON LINE ' + STR(I,2) + ' - PRESS RETURN TO REENTER ' GET MWAIT
                     READ 
                     @ 24,0 SAY SPACE(79)
                     MACTION = 2
                     MLINE = 99
                     LOOP
                  ENDIF
                  IF DTOC(MI_DATE(I)) = '  /  /  '
                     @ 24,0 SAY SPACE(79)
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'INVOICE DATE NOT ENTERED ON LINE ' + STR(I,2) + ' - PRESS RETURN TO REENTER ' GET MWAIT
                     READ 
                     @ 24,0 SAY SPACE(79)
                     MACTION = 2
                     MLINE = 99
                     LOOP
                  ENDIF
                  GOTO MUPDRCD(I)
                  IF MI_DATE(I) < SHIP_DATE
                     @ 24,0 SAY SPACE(79)
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'INVOICE DATE IS BEFORE THE PO SHIP DATE '+ DTOC(SHIP_DATE) + ' ON LINE ' + STR(I,2) + ' - PRESS RETURN ' GET MWAIT
                     READ 
                     @ 24,0 SAY SPACE(79)
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
      
      I = 1 
      DO WHILE I <= 15
         IF MSELECT(I) <> 'X'
            I = I + 1
            LOOP
         ENDIF

         MGRND_FRT  = MGRND_FRT  + MFREIGHT(I)
         MGRND_BILL = MGRND_BILL + MAMT_BILL(I)

         GOTO MUPDRCD(I)
         DO RECLOCK  
         REPLACE FRT_REC WITH 'Y'
         UNLOCK
         SELECT C
         DO FILELOCK
         APPEND BLANK
         REPLACE FRT_CODE WITH MFRT_CODE
         REPLACE SALESMAN WITH B->SALESMAN
         REPLACE PO_NBR WITH B->PO_NBR
         REPLACE PO_SUFFIX WITH B->PO_SUFFIX
         REPLACE INV_NBR WITH B->INV_NBR
         REPLACE AMT_DUE WITH MFREIGHT(I)  
         REPLACE DUE_DATE WITH MDUE_DATE(I)
         REPLACE FRT_INV WITH MFRT_INV(I)
         UNLOCK 
         SELECT B
         I = I + 1
      ENDDO
      IF MACTION <> 3
         MMORE = .F.
      ENDIF
   ENDDO
ENDDO
CLOSE DATA

RETURN
* EOF: FRT_REC1.PRG
*Formatted by: ToolBox Ver. 1.2  on 8/19/14 at 3:19 PM.
