***********
* Program.: FRT_REC.PRG
* Author..: Grace Keller
* Date....: 03/14/88
* Notice..: Copyright 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MATCH FREIGHT INVOICES RECEIVED WITH PO FOR 2ND FREIGHT CARRIER
*           ONLY USED FOR MFI WHERE PROG_CODE = 2
*
DIMENSION MI_NBR(15)
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
   SET PROC TO REC_PROC
   MTITLE = " - MATCH FREIGHT RECIEVED INVOICES WITH PO'S"
   CLEAR
   @  1, 0 SAY MCOMPANY
   @  1,68 SAY DATE()
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 to 24,79
   DO FRT_SF
   SELECT D
   DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.
   SELECT E
   DO FOX_USE WITH "PO_HEAD INDEX PO_HEAD", .F.
   SELECT B
   DO FOX_USE WITH "FRT_2ND INDEX FRT2_FRT", .F.
   
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
      STORE SPACE(5) TO MI_NBR
      GOTO MRECNO
      MLINE = 08
      CLEAR
      @  1, 0 SAY MCOMPANY
      @  1,68 SAY DATE()
      @  2, 0 SAY MPROGRAM + MTITLE
      @ 3,0 to 24,79
      DO FRT_SF
      DO WHILE .NOT. EOF() .AND. MLINE < 23 .AND. MFRT_CODE = FRT_CODE2 .AND. FRT_REC2 = ' '
         *** IF IT HAS NOT BEEN PROCESSED THRU THE INVOICE PRINT PRG-SKIP IT
         SELECT E
         SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
         SELECT B
         IF E->INV_FLG = ' '
            SKIP
            LOOP
         ENDIF
         I = MLINE - 7 
         STORE RECNO() TO MUPDRCD(I)
         STORE FRT_AMT2 TO MFREIGHT(I) 
         STORE E->INV_NBR TO MI_NBR(I)
         DO FRT_SR 
         SKIP
         MLINE = MLINE + 1
      ENDDO
      MMAX_LINE = MLINE - 1
      STORE RECNO() TO MRECNO
      IF .NOT. EOF() .AND. FRT_CODE2 = MFRT_CODE .AND. FRT_REC2 = ' '
         @ 23,69 SAY "More PO's"
         MBLURP = .T.
      ELSE
         @ 23,69 SAY SPACE(9)
         MBLURP = .F.
      ENDIF
      
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         MLINE = 8
         I = 1
         DO WHILE MLINE <= MMAX_LINE
            DO FRT_GF           
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
               @MLINE,69 SAY MDUE_DATE(I) 
               IF MAMT_BILL(I) = 0
                  STORE MFREIGHT(I) TO MAMT_BILL(I)
                  @ MLINE,58 SAY MAMT_BILL(I) PICTURE '999,999.99'
               ENDIF
            ENDIF
            I = I + 1
            MLINE = MLINE + 1
         ENDDO
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
                  IF MAMT_BILL(I) > MFREIGHT(I)
                     @ 24,0 SAY SPACE(79)
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'AMOUNT BILLED CANNOT BE MORE THAN PO AMT ON LINE' + STR(I,2) + ' - PRESS RETURN  ' GET MWAIT
                     READ 
                     @ 24,0 SAY SPACE(79)
                     MACTION = 2
                     MLINE = 99
                     LOOP
                  ENDIF
                  MDIFF = MFREIGHT(I) - MAMT_BILL(I)
                  IF MDIFF > 0 .AND. MDIFF <= 1000
                     @ 24,0 SAY SPACE(79)
                     STORE ' ' TO MWAIT
                     @ 24,0 SAY 'UNDERBILLING LESS THAN $1000 DIFFERENCE ON LINE' + STR(I,2) + ' -ADJUST PO- PRESS RETURN  ' GET MWAIT
                     READ 
                     @ 24,0 SAY SPACE(79)
                     MACTION = 2
                     MLINE = 99
                     LOOP
                  ENDIF
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
         GOTO MUPDRCD(I)     
         DO RECLOCK  
         REPLACE FRT_REC2 WITH 'Y'
         UNLOCK
         SELECT C   
         DO FILELOCK
         APPEND BLANK
         REPLACE FRT_CODE WITH MFRT_CODE
         REPLACE SALESMAN WITH B->SALESMAN
         REPLACE PO_NBR WITH B->PO_NBR
         REPLACE PO_SUFFIX WITH B->PO_SUFFIX
         REPLACE INV_NBR WITH MI_NBR(I)  
         REPLACE AMT_DUE WITH MAMT_BILL(I)  
         REPLACE DUE_DATE WITH MDUE_DATE(I)
         REPLACE FRT_INV WITH MFRT_INV(I)
         REPLACE FRT_SEQ WITH '2'
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
* EOF: FRT_REC2.PRG
*Formatted by: ToolBox Ver. 1.2  on 5/4/93 at 8:29 AM.
