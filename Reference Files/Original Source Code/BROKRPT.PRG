*************
* Program.: BROKRPT.PRG
* Author..: Grace Keller
* Date....: 10/26/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: BROKER REPORT
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
CLEAR
@ 00,00 SAY MCOMPANY
@ 01,68 SAY DATE()
@ 01,00 SAY MPROGRAM + ' - PRINT BY LOT NUMBER (optional cutoff)'
@ 2,0 to 22,79
MFILE = 'INVNTMP'
MCUTOFF = CTOD('')  
MPEND = 'N'
MTOT_ONLY = 'N'
MACTION = 2
STORE 'N' TO MYES_NO
DO WHILE MACTION = 2
   **@ 06,3 SAY 'Include Pending Lots (Y/N): ' GET MPEND PICTURE '@!' VALID(MPEND = 'Y' .OR. MPEND = 'N')
   @ 08,3 SAY 'Enter Activity Cutoff Date: ' GET MCUTOFF
   @ 10,3 SAY 'Note: All activity up to and including above    '
   @ 11,3 say '      date will be included.  Any activity after'
   @ 12,3 say '      above date will not be included.          '
   @ 13,3 SAY '      LEAVE CUTOFF DATE BLANK IF CURRENT STATUS '
   @ 14,3 SAY '      OF INVENTORY PRINT DESIRED !              '
   @ 16,3 SAY 'Print Remaining Dollar Amount (Y/N): ' GET MYES_NO PICTURE '@!' VALID(MYES_NO = 'Y' .OR. MYES_NO = 'N')
   @ 18,3 SAY '                  TOTALS ONLY (Y/N): ' GET MTOT_ONLY PICTURE '@!' VALID(MTOT_ONLY = 'Y' .OR. MTOT_ONLY = 'N')
   STORE 1 TO MACTION
   @ 24,0 SAY 'Action: ' + STR(MACTION,1)
   @ 24,13 SAY '1. Continue    2. Edit    3. Cancel Report'          
   READ
   @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
   READ
ENDDO
IF MACTION = 3                         
   CLOSE DATA
   RETURN
ENDIF
@ 3,1 CLEAR TO 21,78
MPRT_DISP = 'P'
MPRT_ACT = 'C'
DO PRT_SET
IF MPRT_ACT <> 'C'
   CLOSE DATA
   RETURN
ENDIF
MPAGE_LEN = 56

MPAGE_NO = 0
MLINE = 99

@ 21,16 SAY SPACE(34)
@ 21,16 SAY 'PROCESSING/PRINTING......'

SET CONSOLE OFF
IF FILE("C:\COMPINFO\PRINTERS.DBF")
   SET PRINT TO C:\COMPINFO\PRT_FILE.TXT
ELSE
   SET PRINT TO LPT3
ENDIF
SET DEVICE TO PRINT
SET PRINT ON

*** PRINT IN 12 CPI
?? chr(27) + '&k4S'

*** LETTER GOTHIC AND BOLDED PRINT
?? chr(27) + '(s4102T' + chr(27) + '(s3B' + chr(27) + '(s3B'

*** LETTER SIZE PAPER
?? CHR(27) + '&l2A'

*** PORTRAIT MODE
?? CHR(27) + '&l0O'


IF MCUTOFF = CTOD('')
   STORE DATE() + 90 TO MCUTOFF
ENDIF
DO CASE
CASE MCUTOFF <> CTOD('')  
   SELECT C
   *** INVNTMP3
   MFILENM = MFILE + '3'
   USE &MFILENM EXCLUSIVE               
   DELETE ALL
   PACK
   INDEX ON FREEZ_LOC + PROD_DESC + LOT_NBR TO &MFILENM
   DO FOX_USE WITH "&MFILENM INDEX &MFILENM", .F.
   DO FILELOCK
   SELECT B
   DO FOX_USE WITH "INVN_DTL INDEX DTL_DATE", .F.
   
   SELECT A
   DO FOX_USE WITH "INVEN INDEX INVNSOLD", .F.
   SEEK ' '
   DO WHILE .NOT. EOF() .AND. SOLD_FLG = ' '
      IF ANIV_DATE > MCUTOFF
         SKIP
         LOOP
      ENDIF
      SELECT C
      APPEND BLANK
      REPLACE LOT_NBR WITH A->LOT_NBR
      REPLACE FREEZ_LOC WITH A->FREEZ_LOC
      REPLACE RSUPCODE WITH A->RSUPCODE
      REPLACE ANIV_DATE WITH A->ANIV_DATE
      REPLACE SIZE    WITH A->SIZE
      REPLACE GRADE   WITH A->GRADE
      REPLACE PROD_DESC WITH A->PROD_DESC
      *REPLACE SUP_PREFX WITH A->SUP_PREFX 
      *REPLACE SUP_PCODE WITH A->SUP_PCODE
      REPLACE BOX_SZ    WITH A->BOX_SZ
      REPLACE CASE_LEFT WITH A->CASE_LEFT
      REPLACE LBS_LEFT  WITH A->LBS_LEFT
      REPLACE PRI_LB    WITH A->PRI_LB + A->STOR_LB
      REPLACE CASE_CNT  WITH A->CASE_CNT
      *REPLACE STOR_LB   WITH A->STOR_LB
      REPLACE PACKED    WITH A->PACKED
      SELECT A
      SKIP
   ENDDO
   
   SELECT A
   DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
   
   MTRAN_YR = STR(YEAR(MCUTOFF),4)
   MTRAN_MO = SUBSTR(DTOC(MCUTOFF),1,2)
   SELECT B
   SEEK MTRAN_YR+MTRAN_MO
   IF EOF()
      SEEK MTRAN_YR
      IF EOF()
         GOTO TOP 
      ENDIF 
   ENDIF
   
   DO WHILE .NOT. EOF()
      IF ACT_DATE <= MCUTOFF
         SKIP
         LOOP
      ENDIF
      IF ACTIVITY = 'IN '
         SKIP
         LOOP
      ENDIF
      
      SELECT A
      SEEK B->FREEZ_LOC + B->LOT_NBR
      IF EOF()
         STORE SPACE(8) TO MPROD_DESC
      ELSE
         STORE PROD_DESC TO MPROD_DESC
      ENDIF
      
      SELECT C
      SEEK B->FREEZ_LOC + MPROD_DESC + B->LOT_NBR   
      
      DO CASE
      CASE EOF()     
         SELECT A
         IF EOF() .OR. ANIV_DATE > MCUTOFF
            SELECT B
            SKIP
            LOOP
         ENDIF
         SELECT C
         *** GET ALL THE DETAIL STUFF
         APPEND BLANK
         REPLACE FREEZ_LOC WITH B->FREEZ_LOC
         REPLACE LOT_NBR WITH B->LOT_NBR
         REPLACE CASE_LEFT WITH B->QTY * -1
         REPLACE LBS_LEFT  WITH B->LBS * -1 
         **** GET ALL THE HEADER STUFF
         REPLACE SIZE    WITH A->SIZE
         REPLACE GRADE   WITH A->GRADE
         REPLACE PROD_DESC WITH A->PROD_DESC
         REPLACE RSUPCODE WITH A->RSUPCODE
         REPLACE ANIV_DATE WITH A->ANIV_DATE
         *REPLACE SUP_PREFX WITH A->SUP_PREFX 
         *REPLACE SUP_PCODE WITH A->SUP_PCODE
         REPLACE BOX_SZ    WITH A->BOX_SZ
         REPLACE PACKED    WITH A->PACKED
         REPLACE PRI_LB    WITH A->PRI_LB + A->STOR_LB
         REPLACE CASE_CNT  WITH A->CASE_CNT
         *REPLACE STOR_LB   WITH A->STOR_LB
      OTHERWISE
         REPLACE CASE_LEFT WITH CASE_LEFT + B->QTY * -1
         REPLACE LBS_LEFT  WITH LBS_LEFT + B->LBS * -1 
      ENDCASE
      SELECT B
      SKIP
   ENDDO
   
   CLOSE DATA
   SELECT A
   *** INVNTMP3
   MFILENM = MFILE + '3'
   DO FOX_USE WITH "&MFILENM INDEX &MFILENM", .F.
   USE INVNTMP3 INDEX INVNTMP3 EXCLUSIVE
OTHERWISE
   SELECT A
   DO FOX_USE WITH "INVEN INDEX INVNLOC", .F.
ENDCASE

MPAGE_NO = 0
MTOT_LBS = 0
MTOT_CASE = 0
MTOT_VAL = 0
MCANCEL = .F.

DO WHILE .NOT. EOF()
   STORE FREEZ_LOC TO MFREEZ_LOC
   MPRT_FREEZ = .T.
   STORE 0 TO MFREEZ_TOT
   DO WHILE .NOT. EOF() .AND. FREEZ_LOC = MFREEZ_LOC
      IF SOLD_FLG <> ' '
         SKIP 
         LOOP
      ENDIF
      IF SUBSTR(LOT_NBR,1,1) = 'P' .AND. MPEND = 'N'
         SKIP
         LOOP
      ENDIF
      
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      
      MPRT_IT = TRIM(A->SIZE)
      
      IF A->GRADE <> ' '
         DO CASE
         CASE A->GRADE = 'M'
            MGRADE = 'MAR'               
         CASE A->GRADE = 'S'
            MGRADE = 'SMK'              
         CASE A->GRADE = 'O'
            MGRADE = 'OVR'               
         OTHERWISE
            MGRADE = '   '
         ENDCASE
      ELSE
         MGRADE = '   '
      ENDIF
      
      MGRADE = TRIM(MGRADE)
      IF LEN(MPRT_IT) > 1
         IF LEN(MGRADE) > 1
            MPRT_IT = MPRT_IT + ' ' + MGRADE
         ENDIF     
      ELSE
         MPRT_IT = MGRADE
      ENDIF
      
      MPRT_IT = TRIM(MPRT_IT)
      IF LEN(MPRT_IT) > 1
         MPRT_IT = MPRT_IT + ' '
      ENDIF
      MLEN = LEN(MPRT_IT)
      MLEN = 21 - MLEN
      
      SEEK 'R' + A->PROD_DESC    
      IF EOF()       
         MPRT_PROD = MPRT_IT   
      ELSE
         MPRT_PROD = MPRT_IT + SUBSTR(DESC,1,MLEN)
      ENDIF
      
      DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
      SEEK A->RSUPCODE
      IF EOF()
         MPRT_SUP = A->RSUPCODE + ' '   
      ELSE
         MPRT_SUP = SUBSTR(NAME,1,5)
      ENDIF
      SELECT A
      
      IF MLINE > MPAGE_LEN
         IF MLINE <> 99
            EJECT        
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         @ 1,0 SAY 'PAGE: ' + STR(MPAGE_NO,2)
         @ 1,25 SAY TRIM(MCOMPANY) + ' INVENTORY' + SPACE(13) + DTOC(DATE())
         MLINE = 2
         IF MCUTOFF <> DATE() + 90
            @ MLINE,25 SAY 'CUTOFF DATE AS OF: ' + DTOC(MCUTOFF)
            MLINE = MLINE + 1
         ENDIF
         MLINE = MLINE + 1
         @ MLINE,0 SAY 'LOCATION/'
         *@ MLINE,16 SAY '*PENDING*'
         *@ MLINE,30 SAY 'PROD'
         @ MLINE,47 SAY 'BOX    CASE'
         @ MLINE,69 SAY 'UNIT'
         @ MLINE,76 SAY 'CASE' 
         IF MYES_NO = 'Y'
            @ MLINE,84 SAY '$ AMOUNT'
         ENDIF
         MLINE = MLINE + 1
         @ MLINE,0 SAY 'LOT NBR'
         @ MLINE,10 SAY 'SUPLR' 
         @ MLINE,17 SAY 'DATE IN'
         @ MLINE,31 SAY 'PRODUCT '
         @ MLINE,48 SAY 'SZ    LEFT'
         @ MLINE,69 SAY 'COST' 
         @ MLINE,76 SAY 'SOLD'
         IF MYES_NO = 'Y'
            @ MLINE,83 SAY 'REMAINING'
         ENDIF
         @ MLINE,0 SAY REPLICATE('_',92)
         MLINE = MLINE + 2
         MPRT_FREEZ = .T.      
      ENDIF
      
      IF MTOT_ONLY = 'N'
         IF MPRT_FREEZ
            MLINE = MLINE + 1
            @ MLINE,0 SAY MFREEZ_LOC
            STORE LEN(TRIM(MFREEZ_LOC)) TO MLEN
            @ MLINE,0 SAY REPLICATE('_',MLEN)
            MPRT_FREEZ = .F.
            MLINE = MLINE + 2
         ENDIF
         @ MLINE,0 SAY LOT_NBR
         @ MLINE,10 SAY MPRT_SUP
         @ MLINE,17 SAY SUBSTR(DTOC(ANIV_DATE),1,6) + SUBSTR(DTOC(ANIV_DATE),9)
         *@ MLINE,15 SAY DTOC(ANIV_DATE)
         IF SUBSTR(LOT_NBR,1,1) = 'P' .OR. SUBSTR(LOT_NBR,1,1) = 'O'
            *@ MLINE,15 SAY '*'
            *@ MLINE,23 SAY '*'
         ENDIF
         **@ MLINE,24 SAY MPRT_SIZE
         @ MLINE,31 SAY PROD_DESC
         IF BOX_SZ = 0    
            *@ MLINE,46 SAY ' CWT'
         ELSE
            IF BOX_SZ - INT(BOX_SZ) <> 0
               @ MLINE,46 SAY BOX_SZ PICTURE '99.9' 
            ELSE
               @ MLINE,46 SAY BOX_SZ PICTURE '9999'
            ENDIF
         ENDIF
         *** NOW - FIGURE OUT WHAT IS LEFT
         @ MLINE,54 SAY CASE_LEFT PICTURE '9999'
         IF SUBSTR(PACKED,1,1) = 'B'
            *MLBS_LEFT = ROUND(LBS_LEFT * BOX_SZ,2)
            *@ MLINE,56 SAY MLBS_LEFT PICTURE '999999.99'
            *MSTOR_UNIT = (STOR_LB * MLBS_LEFT) / LBS_LEFT
            *MSTOR_UNIT = ROUND(MSTOR_UNIT,4)
            *MSTOR_UNIT = 0
            **@ MLINE,66 SAY PRI_LB + MSTOR_UNIT PICTURE '99.9999'
            @ MLINE,66 SAY PRI_LB  PICTURE '99.9999'
            *MPRI_LB = PRI_LB / BOX_SZ                     
            *MPRI_LB = ROUND(MPRI_LB,4)
            **@ MLINE,74 SAY MPRI_LB + STOR_LB PICTURE '9.9999'
            **@ MLINE,74 SAY MPRI_LB  PICTURE '9.9999'
            @ MLINE,76 SAY CASE_CNT - CASE_LEFT PICTURE '9999'
         ELSE
            *@ MLINE,56 SAY LBS_LEFT PICTURE '999999.99'
            **@ MLINE,66 SAY PRI_LB+STOR_LB PICTURE '99.9999'
            *@ MLINE,74 SAY PRI_LB + STOR_LB PICTURE '9.9999'
            @ MLINE,66 SAY PRI_LB PICTURE '99.9999'
            **@ MLINE,74 SAY PRI_LB PICTURE '9.9999'
            @ MLINE,76 SAY CASE_CNT - CASE_LEFT PICTURE '9999'
         ENDIF
         IF MYES_NO = 'Y'
            IF SUBSTR(PACKED,1,1) = 'B' .OR. PRI_LB >= 10 .OR. LOT_NBR = 'H0 '
               MVAL_LEFT = ROUND(CASE_LEFT * PRI_LB,2)
               @ MLINE,82  SAY ROUND(CASE_LEFT * PRI_LB,2) PICTURE '999,999.99'
               MTOT_VAL = MTOT_VAL + MVAL_LEFT
            ELSE
               IF PACKED = 'CWT'
                  MLBS_LEFT = LBS_LEFT
                  MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
                  @ MLINE,82 SAY MVAL_LEFT PICTURE '999,999.99'
                  MTOT_VAL = MTOT_VAL + MVAL_LEFT
               ELSE
                  MLBS_LEFT = ROUND(CASE_LEFT * BOX_SZ,2)
                  MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
                  @ MLINE,82 SAY MVAL_LEFT PICTURE '999,999.99'
                  MTOT_VAL = MTOT_VAL + MVAL_LEFT
               ENDIF
            ENDIF
            MFREEZ_TOT = MFREEZ_TOT + MVAL_LEFT
         ENDIF
         MLINE = MLINE + 2
      ELSE
         IF SUBSTR(PACKED,1,1) = 'B' .OR. PRI_LB >= 10 .OR. LOT_NBR = 'H0 '
            MVAL_LEFT = ROUND(CASE_LEFT * PRI_LB,2)
            MTOT_VAL = MTOT_VAL + MVAL_LEFT
            REPLACE VAL_LEFT WITH MVAL_LEFT
            REPLACE QTY_LEFT WITH CASE_LEFT
         ELSE
            IF PACKED = 'CWT'
               MLBS_LEFT = LBS_LEFT
               MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
               MTOT_VAL = MTOT_VAL + MVAL_LEFT
               REPLACE VAL_LEFT WITH MVAL_LEFT
               REPLACE QTY_LEFT WITH LBS_LEFT
            ELSE
               MLBS_LEFT = ROUND(CASE_LEFT * BOX_SZ,2)
               MVAL_LEFT = ROUND(MLBS_LEFT * PRI_LB,2)
               MTOT_VAL = MTOT_VAL + MVAL_LEFT
               REPLACE VAL_LEFT WITH MVAL_LEFT
               REPLACE QTY_LEFT WITH MLBS_LEFT
            ENDIF
         ENDIF
      ENDIF
      SKIP
   ENDDO
   IF MTOT_ONLY = 'N' .AND. MYES_NO = 'Y' .AND. MFREEZ_TOT <> 0
      @ MLINE,0 SAY '********'
      @ MLINE,10 SAY 'FREEZER TOTAL: '
      @ MLINE,80  SAY MFREEZ_TOT PICTURE '9,999,999.99'
      MLINE = MLINE + 3
   ENDIF
ENDDO
IF MLINE =  99
   @ 4,1 SAY 'NO INVENTORY DATA SELECTED FOR REPORT'                            
ELSE
   IF MYES_NO = 'Y'
      MLINE = MLINE + 1
      @ MLINE,1 SAY 'TOTAL INVENTORY: '
      @ MLINE,80 SAY MTOT_VAL PICTURE '9,999,999.99'
   ENDIF
ENDIF
@ MLINE+1,1 SAY ' '
EJECT

SET DEVICE TO SCREEN
SET PRINT OFF
SET PRINT TO
SET CONSOLE ON
IF MPRINTER3 <> 'DONOTPRINT'
   RUN &MPRINTIT3
ENDIF

CLOSE DATA
RETURN           
*Formatted by: ToolBox Ver. 1.2  on 7/22/14 at 2:30 PM.
