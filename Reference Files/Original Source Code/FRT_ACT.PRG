****************
* Program.: FRT_ACT.PRG
* Author..: GRACE KELLER
* Date....: 09/04/91
* Notice..: Copyright (C) 1991, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: FREIGHT DOLLARS/LBS ACTIVITY
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion      
MTITLE = ' - DOLLAR/POUNDS ACTIVITY FOR FREIGHT CARRIERS'
CLEAR
@  1, 1  SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
MSALE_ACT = 'N'
@ 10,5 SAY 'Separate activity by salesperson (Y/N) ? ' GET MSALE_ACT PICTURE '@!'
READ
DO CASE
CASE MSALE_ACT = 'Y'
   @  10,1 SAY SPACE(78)
   STORE 'D' TO MDISP_PRT
   MYES_NO = ' '
   @ 10,5 SAY 'Select a specific freight carrier (Y/N)? ' get myes_no picture '@!' VALID(MYES_NO = 'Y' .OR. MYES_NO = 'N')
   READ
   IF MYES_NO = 'Y'
      MNAME_FD = .F.
      DO FRT_SEL1
      IF .NOT. MNAME_FD
         RETURN
      ENDIF
      STORE FRT_CODE TO MFRT_CODE
      STORE NAME TO MNAME
      STORE CITY TO MCITY
      STORE STATE TO MSTATE
   ELSE
      MFRT_CODE = SPACE(4)
      MDISP_PRT = 'P'
   ENDIF
   CLOSE DATA
   
   CLEAR
   @  1, 1  SAY MCOMPANY
   @  1,68 SAY DATE()
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   **** GET FIRST AND LAST DATES FOR THIS REPORT
   STORE CTOD(' ') TO MSTART, MLAST
   MOPT_SALES = '**'
   STORE 2 TO MACTION      
   DO WHILE MACTION = 2      
      IF MYES_NO = 'Y'
         @ 5,10 SAY NAME
         @ 6,10 SAY TRIM(MCITY) + ', ' + MSTATE
      ENDIF
      @ 09,2 say '        BEGINNING DATE: '
      @ 09,27 GET MSTART
      @ 11,2 SAY '           ENDING DATE: '
      @ 11,27 GET MLAST
      @ 13,2 SAY '  OPTIONAL SALESPERSON: ' 
      @ 13,26 GET MOPT_SALES PICTURE '@!'
      IF MYES_NO = 'Y'
         @ 15,2 SAY 'DISPLAY OR PRINT (D/P): '
         @ 15,27 GET MDISP_PRT PICTURE '@!'
      ENDIF
      
      STORE 1 TO MACTION
      @ 24,00 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'                     
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 1
         IF DTOC(MSTART) = '  /  /  ' .AND. DTOC(MLAST) = '  /  /  '
            MACTION = 3
         ENDIF
      ENDIF
      
      IF MACTION = 1
         IF (DTOC(MSTART) <> '  /  /  ' .AND. DTOC(MLAST) = '  /  /  ') .OR. (DTOC(MSTART) = '  /  /  ' .AND. DTOC(MLAST) <> '  /  /  ')
            @ 23,0 CLEAR
            mwait = ' '
            @ 23,1 SAY 'Only One Date Entered - Both Begin and End Dates Must be Entered'
            @ 24,1 say 'Press Any Key to Reenter ' get mwait
            READ
            MACTION = 2
            @ 23,0 clear
            LOOP 
         ENDIF
      ENDIF
   ENDDO
   IF MACTION = 3
      RETURN 
   ENDIF  
   
   MPRT_ACT = 'C'
   
   IF MDISP_PRT = 'P'
      DO PRT_SET
      
      IF MPRT_ACT <> 'C'
         RETURN
      ENDIF
      MPAGE_LEN = 56
   ELSE
      MPAGE_LEN = 20
   ENDIF
   SELECT B 
   USE SALESUM EXCLUSIVE 
   DELETE ALL
   PACK
   INDEX ON SALESMAN + FRT_CODE TO TMPSALE
   UNLOCK
   DO FOX_USE WITH "SALESUM INDEX TMPSALE", .F.
   
   SELECT C 
   DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
   
   SELECT D 
   DO FOX_USE WITH "SALESMAN INDEX SAL_CODE", .F.
   
   SELECT A 
   DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP", .F.
   
   STORE MONTH(MSTART) TO MSTRT_MO   
   MSTRT_MO = MSTRT_MO + 100
   STORE SUBSTR(STR(MSTRT_MO,3),2) TO MSTRT_MO
   
   STORE MONTH(MLAST) TO MLAST_MO   
   MLAST_MO = MLAST_MO + 100
   STORE SUBSTR(STR(MLAST_MO,3),2) TO MLAST_MO
   
   STORE YEAR(MSTART) TO MSTRT_YR
   STORE STR(MSTRT_YR,4) TO MSTRT_YR
   
   STORE YEAR(MLAST) TO MLAST_YR
   STORE STR(MLAST_YR,4) TO MLAST_YR
   
   STORE DAY(MSTART) TO MSTRT_DAY
   MSTRT_DAY = MSTRT_DAY + 100
   STORE SUBSTR(STR(MSTRT_DAY,3),2) TO MSTRT_DAY
   
   STORE DAY(MLAST) TO MLAST_DAY
   MLAST_DAY = MLAST_DAY + 100
   STORE SUBSTR(STR(MLAST_DAY,3),2) TO MLAST_DAY
   SELECT A
   SEEK MSTRT_YR + MSTRT_MO + MSTRT_DAY
   IF EOF()
      SEEK MSTRT_YR + MSTRT_MO 
      IF EOF()
         SEEK MSTRT_YR
         IF EOF()
            GOTO TOP
         ENDIF
      ENDIF
   ENDIF
   DO WHILE .NOT. EOF() .AND. SHIP_DATE < MSTART
      SKIP
   ENDDO
   MPAGE_NO = 0
   MLINE = 99 
   @ 19,16 SAY 'PROCESSING........'
   IF MDISP_PRT = 'P'
      
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 10 CPI
      ?? chr(27) + '&k0S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
      
   ENDIF
   
   
   DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MLAST
      IF (FRT_AMT1 + FRT1_ADJ1 + FRT1_ADJ2+ FRT_PALL) = 0
         SKIP
         LOOP
      ENDIF
      IF MFRT_CODE <> SPACE(4)
         IF FRT_CODE1 <> MFRT_CODE
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      IF MOPT_SALES <> '**'     
         IF SALESMAN  <> MOPT_SALES
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      SELECT B
      SEEK A->SALESMAN + A->FRT_CODE1
      IF EOF()
         DO FILELOCK
         APPEND BLANK
         REPLACE SALESMAN WITH A->SALESMAN
         REPLACE FRT_CODE WITH A->FRT_CODE1
      ENDIF
      DO RECLOCK
      REPLACE FREIGHT WITH FREIGHT + A->FRT_AMT1 + A->FRT1_ADJ1 + A->FRT1_ADJ2+ A->FRT_PALL  
      REPLACE LBS WITH LBS + A->TOT_LBS
      REPLACE NBR_SHIPS WITH NBR_SHIPS + 1
      * REPLACE REGION WITH REGION CODE OF CUSTOMER
      SELECT A
      SKIP
   ENDDO
   MTOT_FRT = 0
   MTOT_LBS = 0
   MTOT_SHIP = 0
   SELECT B
   GOTO TOP
   DO WHILE .NOT. EOF()
      MSALESMAN = SALESMAN
      MSALE_FRT = 0
      MSALE_LBS = 0
      MSALE_SHIP = 0
      
      DO WHILE .NOT. EOF() .AND. SALESMAN = MSALESMAN
         
         IF MLINE > MPAGE_LEN
            IF MDISP_PRT <> 'P'
               IF MLINE = 99 
                  CLEAR
               ELSE
                  STORE ' ' TO MWAIT
                  @ 24,0 SAY 'Press Return to Continue to Next Page ' GET MWAIT
                  READ
                  CLEAR    
               ENDIF
            ENDIF
            MPAGE_NO = MPAGE_NO + 1
            @ 1,27 SAY MCOMPANY
            @ 1,60 SAY DTOC(DATE())
            @ 1,70 SAY TIME()
            @ 2,1 SAY 'Page'
            @ 2,06 say mpage_no picture '99'
            @ 2,13 SAY 'FREIGHT DOLLAR ACTIVITY TOTAL FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
            @ 4,1 SAY 'SALES  FREIGHT CARRIER                POUNDS      DOLLARS    FRT/LB   NBR SHIPS'
            IF MDISP_PRT = 'P'
               @ 4,01 SAY REPLICATE('_',80)
            ENDIF
            MLINE = 7
         ENDIF
         @ MLINE,2 SAY SALESMAN
         SELECT C
         SEEK B->FRT_CODE
         @ MLINE,8 SAY SUBSTR(NAME,1,20)
         SELECT B
         @ MLINE,34 SAY LBS PICTURE '999,999,999'
         @ MLINE,47 SAY FREIGHT PICTURE '999,999,999'
         @ MLINE,62 SAY ROUND(FREIGHT / LBS,4) PICTURE '9.9999'
         @ MLINE,73 SAY NBR_SHIPS PICTURE '999,999'
         MSALE_FRT = MSALE_FRT + FREIGHT
         MSALE_LBS = MSALE_LBS + LBS
         MSALE_SHIP = MSALE_SHIP + NBR_SHIPS
         MLINE = MLINE + 2
         SKIP
      ENDDO
      SELECT D
      SEEK MSALESMAN
      @ MLINE,2 SAY 'TOTALS: ' + SUBSTR(NAME,1,20)      
      @ MLINE,2 SAY REPLICATE('_',28)
      SELECT B
      @ MLINE,34 SAY MSALE_LBS PICTURE '999,999,999'
      @ MLINE,47 SAY MSALE_FRT PICTURE '999,999,999'
      @ MLINE,62 SAY ROUND(MSALE_FRT / MSALE_LBS,4) PICTURE '9.9999'
      @ MLINE,73 SAY MSALE_SHIP PICTURE '999,999'
      MLINE = MLINE + 2
      
      MTOT_FRT = MTOT_FRT + MSALE_FRT
      MTOT_LBS = MTOT_LBS + MSALE_LBS
      MTOT_SHIP = MTOT_SHIP + MSALE_SHIP
   ENDDO
   MLINE = MLINE + 1
   
   @ MLINE,34 SAY MTOT_LBS PICTURE '999,999,999'
   @ MLINE,47 SAY MTOT_FRT PICTURE '999,999,999'
   @ MLINE,62 SAY ROUND(MTOT_FRT / MTOT_LBS,4) PICTURE '9.9999'
   @ MLINE,73 SAY MTOT_SHIP PICTURE '999,999'
   
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
   
   CLOSE DATA
   
OTHERWISE
   MNAME_FD = .F.
   DO FRT_SEL1
   IF .NOT. MNAME_FD
      RETURN
   ENDIF
   STORE FRT_CODE TO MFRT_CODE
   STORE NAME TO MNAME
   STORE CITY TO MCITY
   STORE STATE TO MSTATE
   MTITLE = ' - TOTAL DOLLAR ACTIVITY FOR FREIGHT CARRIERS'
   CLEAR
   @  1, 1  SAY MCOMPANY
   @  1,68 SAY DATE()
   @  2, 0 SAY MPROGRAM + MTITLE
   @ 3,0 TO 22,79
   **** GET FIRST AND LAST DATES FOR THIS REPORT
   STORE CTOD(' ') TO MSTART, MLAST
   STORE 'D' TO MDISP_PRT
   
   STORE 2 TO MACTION      
   DO WHILE MACTION = 2      
      @ 5,10 SAY NAME
      @ 6,10 SAY TRIM(MCITY) + ', ' + MSTATE
      @ 09,2 say '        BEGINNING DATE: '
      @ 09,27 GET MSTART
      @ 11,2 SAY '           ENDING DATE: '
      @ 11,27 GET MLAST
      @ 13,2 SAY 'DISPLAY OR PRINT (D/P): '
      @ 13,27 GET MDISP_PRT PICTURE '@!'
      STORE 1 TO MACTION
      @ 24,00 CLEAR
      @ 24,01 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Continue    2.  Edit    3. Cancel Report'                     
      
      READ
      
      @24,09 GET MACTION PICTURE '9' RANGE 1,3
      READ               
      IF MACTION = 1
         IF DTOC(MSTART) = '  /  /  ' .AND. DTOC(MLAST) = '  /  /  '
            MACTION = 3
         ENDIF
      ENDIF
      
      IF MACTION = 1
         IF (DTOC(MSTART) <> '  /  /  ' .AND. DTOC(MLAST) = '  /  /  ') .OR. (DTOC(MSTART) = '  /  /  ' .AND. DTOC(MLAST) <> '  /  /  ')
            @ 23,0 CLEAR
            mwait = ' '
            @ 23,1 SAY 'Only One Date Entered - Both Begin and End Dates Must be Entered'
            @ 24,1 say 'Press Any Key to Reenter ' get mwait
            READ
            MACTION = 2
            @ 23,0 clear
            LOOP 
         ENDIF
      ENDIF
   ENDDO
   IF MACTION = 3
      RETURN 
   ENDIF  
   
   MPRT_ACT = 'C'
   
   IF MDISP_PRT = 'P'
      DO PRT_SET
      
      IF MPRT_ACT <> 'C'
         RETURN
      ENDIF
      MPAGE_LEN = 56
   ELSE
      MPAGE_LEN = 20
   ENDIF
   SELECT A 
   DO FOX_USE WITH "PO_HEAD INDEX  PO_SHIP", .F.
   STORE 0 TO MDLRS           
   
   STORE MONTH(MSTART) TO MSTRT_MO   
   MSTRT_MO = MSTRT_MO + 100
   STORE SUBSTR(STR(MSTRT_MO,3),2) TO MSTRT_MO
   
   STORE MONTH(MLAST) TO MLAST_MO   
   MLAST_MO = MLAST_MO + 100
   STORE SUBSTR(STR(MLAST_MO,3),2) TO MLAST_MO
   
   STORE YEAR(MSTART) TO MSTRT_YR
   STORE STR(MSTRT_YR,4) TO MSTRT_YR
   
   STORE YEAR(MLAST) TO MLAST_YR
   STORE STR(MLAST_YR,4) TO MLAST_YR
   
   STORE DAY(MSTART) TO MSTRT_DAY
   MSTRT_DAY = MSTRT_DAY + 100
   STORE SUBSTR(STR(MSTRT_DAY,3),2) TO MSTRT_DAY
   
   STORE DAY(MLAST) TO MLAST_DAY
   MLAST_DAY = MLAST_DAY + 100
   STORE SUBSTR(STR(MLAST_DAY,3),2) TO MLAST_DAY
   SELECT A
   SEEK MSTRT_YR + MSTRT_MO + MSTRT_DAY
   IF EOF()
      SEEK MSTRT_YR + MSTRT_MO 
      IF EOF()
         SEEK MSTRT_YR
         IF EOF()
            GOTO TOP
         ENDIF
      ENDIF
   ENDIF
   DO WHILE .NOT. EOF() .AND. SHIP_DATE < MSTART
      SKIP
   ENDDO
   MPAGE_NO = 0
   MLINE = 99 
   @ 19,16 SAY 'PROCESSING........'
   IF MDISP_PRT = 'P'
      SET CONSOLE OFF
      IF FILE("C:\COMPINFO\PRINTERS.DBF")
         SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
      ELSE
         SET PRINT TO LPT3
      ENDIF
      SET DEVICE TO PRINT
      SET PRINT ON
      
      *** PRINT IN 10 CPI
      ?? chr(27) + '&k0S'
      
      *** LETTER GOTHIC AND BOLDED PRINT
      ?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'
      
      *** LETTER SIZE PAPER
      ?? CHR(27) + '&l2A'
      
      *** PORTRAIT MODE
      ?? CHR(27) + '&l0O'
   ENDIF
   
   DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MLAST
      IF FRT_CODE1 <> MFRT_CODE
         SKIP
         LOOP
      ENDIF
      MDLRS = MDLRS + FRT_AMT1 + FRT1_ADJ1 + FRT1_ADJ2+ FRT_PALL  
      SKIP
   ENDDO
   
   IF MLINE > MPAGE_LEN
      IF MDISP_PRT <> 'P'
         IF MLINE = 99 
            CLEAR
         ELSE
            STORE ' ' TO MWAIT
            @ 24,0 SAY 'Press Return to Continue to Next Page ' GET MWAIT
            READ
            CLEAR    
         ENDIF
      ENDIF
      MPAGE_NO = MPAGE_NO + 1
      @ 1,27 SAY MCOMPANY
      @ 1,60 SAY DTOC(DATE())
      @ 1,70 SAY TIME()
      @ 2,1 SAY 'Page'
      @ 2,06 say mpage_no picture '99'
      @ 2,13 SAY 'FREIGHT DOLLAR ACTIVITY TOTAL FOR ' + DTOC(MSTART) + ' - ' + DTOC(MLAST)
      @ 3,13 SAY TRIM(MNAME) + ',   ' + TRIM(MCITY) + ', ' + MSTATE
      IF MDISP_PRT = 'P'
         @ 3,01 SAY REPLICATE('_',77)
      ENDIF
      @ 05,05 SAY '               TOTAL DOLLARS '
      MLINE = 7
   ENDIF
   @ MLINE,20 SAY MDLRS PICTURE '999,999,999.99' 
   IF MDISP_PRT = 'P'
      MLINE = MLINE + 1
      @ mline+1,1 say ' '
      eject
      SET DEVICE TO SCREEN
      SET PRINT OFF
      SET PRINT TO
      SET CONSOLE ON
      IF MPRINTER3 <> 'DONOTPRINT'
         RUN &MPRINTIT3
      ENDIF
      
   ELSE
      MPRT_SEL = ' '
      @ 24,00 SAY 'End Of Report - Press Return to Continue ' GET MPRT_SEL
      READ
   ENDIF
ENDCASE

CLOSE DATA
*Formatted by: ToolBox Ver. 1.2  on 12/9/15 at 10:36 AM.
