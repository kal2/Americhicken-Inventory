**********
* Program.: PO_CHG.PRG
* Author..: Grace Keller
* Date....: 12/07/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PURCHASE ORDER EDIT
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
MMORE = .T.  
DO WHILE MMORE
   SET PROC TO PO_PROC
   DO INITPO
   
   STORE 0 TO MTOT_LBS, MTOT_SELL, MTOT_PURCH
   
   STORE 0 TO MNBR_ITM
   STORE 0 TO MMAX_ITM
   STORE SPACE(32) TO MRSUPNAME, MSUP_NAME, MBBUYNAME, MBUY_NAME
   STORE SPACE(4) TO MRSUPCODE, MSUP_CODE, MBBUYCODE, MBUY_CODE
   MCONT = .T.
   DO WHILE MCONT
      CLEAR
      MTITLE = ' - ADD PO'    
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
               IF B->SHIP_DATE >= EFF_DT2
                  MSALE_PERC = SALE_PER2
               ENDIF
            ENDIF
            IF DTOC(EFF_DT3) <> '  /  /  '
               IF B->SHIP_DATE >= EFF_DT3
                  MSALE_PERC = SALE_PER3
               ENDIF
            ENDIF
            
            
         ELSE
            **** GIVE AN ERROR HERE
            @ 24,0 CLEAR
            STORE 'SALESPERSON CODE ' + MSALESMAN + ' NOT FOUND - PRESS RETURN TO REENTER' TO MERROR
            @ 24,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,63 GET MSPACE
            READ
            LOOP
         ENDIF
      ELSE
         STORE MBROK_NAME TO MSAL_NAME
         STORE 0 TO MSALE_PERC
      ENDIF
      SELECT B
      SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
      IF .NOT. EOF()
         **** PO ALREADY ON FILE 
         @ 23,0 CLEAR
         STORE 'PURCHASE ORDER NUMBER ALREADY USED - PRESS RETURN TO REENTER' TO MERROR
         @ 24,5 GET MERROR
         CLEAR GETS
         STORE ' ' TO MSPACE
         @ 24,58 GET MSPACE
         READ
         LOOP
      ENDIF
      *     DO SAYPO1
      DO CASE
      CASE MCOMPANY = 'DIVISION 72'
         IF MBROKERAGE <> 'S' .AND. MBROKERAGE <> 'T' .AND. MBROKERAGE <> 'F' .AND. MBROKERAGE <> 'B' .AND. MBROKERAGE <> 'W'
            @ 24,0 CLEAR
            STORE 'BROKERAGE INDICATOR MUST BE "S, T, F OR B" - PRESS RETURN TO REENTER'TO MERROR
            @ 24,1 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,1  GET MSPACE
            READ
            LOOP
         ENDIF
      CASE MCOMPANY = 'DIVISION 15'
         IF MBROKERAGE <> 'Y' .AND. MBROKERAGE <> ' '
            @ 24,0 CLEAR
            STORE 'HOLD STORAGE INDICATOR MUST BE A "Y" OR SPACE - PRESS RETURN TO REENTER'TO MERROR
            @ 24,1 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,1  GET MSPACE
            READ
            LOOP
         ENDIF
      OTHERWISE
         IF MBROKERAGE <> 'X' .AND. MBROKERAGE <> ' '
            @ 24,0 CLEAR
            STORE 'BROKERAGE ORDER INDICATOR MUST BE AN "X" OR SPACE - PRESS RETURN TO REENTER'TO MERROR
            @ 24,1 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,1  GET MSPACE
            READ
            LOOP
         ENDIF
      ENDCASE
      
      DO TEXTPO3
      
      **** GET SUPPLIER SHIPPED FROM ADDRESS
      MGET_NAME = .T.
      DO WHILE MGET_NAME
         @ 13,1 GET MSUP_NAME PICTURE '@!'
         READ
         IF MSUP_NAME = SPACE(32)
            @ 24,0 CLEAR
            STORE 'SHIPPED FROM SUPPLIER NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @ 24,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,58 GET MSPACE
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
         DO FOX_USE WITH "&MDBFLOC.SUPPLIER INDEX &MDBFLOC.SUP_NAME", .F.
         SET PROC TO SUP_PROC
         MNAME_FD = .F.
         STORE MSUP_NAME TO MNAME
         STORE MSUP_NAME TO MDIS_NAME
         @ 24,0 CLEAR
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
         @ 15,1  SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
      ENDIF
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPCODE", .F.
      SEEK MRSUPCODE
      IF .NOT. EOF()
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
      ELSE
         STORE SPACE(32) TO MRSUPNAME
         STORE MRSUPNAME TO MSV_NAME
         STORE SPACE(28) TO MSTREET
         STORE SPACE(20) TO MCITY
         STORE SPACE(2) TO MSTATE
         STORE SPACE(5) TO MZIP
      ENDIF
      
      
      MGET_NAME = .T.
      DO WHILE MGET_NAME
         @ 13,40 GET MRSUPNAME PICTURE '@!'
         @ 14,40 SAY MSTREET
         @ 15,40 SAY SPACE(35)
         @ 15,40 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
         READ
         IF MRSUPNAME = SPACE(32)
            @ 24,0 CLEAR
            STORE 'REMIT TO SUPPLIER NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @ 24,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,58 GET MSPACE
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
            DO FOX_USE WITH "&MDBFLOC.REM_SUP INDEX &MDBFLOC.RSUPNAME", .F.
            SET PROC TO SUP_PROC
            MNAME_FD = .F.
            IF MRSUPNAME = 'SAME'
               STORE MSUP_NAME TO MNAME
            ELSE
               STORE MRSUPNAME TO MNAME
            ENDIF
            SAVE SCREEN TO MADD_SCRN
            DO RSUPSEL2
            RESTORE SCREEN FROM MADD_SCRN 
            @ 24,0 CLEAR
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
         @ 15,40 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
      ENDIF
      
      ******** here
      ***** NOW GET SHIP TO CUSTOMER
      MGET_NAME = .T.
      DO WHILE MGET_NAME
         @ 20,1  GET MBUY_NAME PICTURE '@!'
         READ
         IF MBUY_NAME = SPACE(32)
            @ 24,0 CLEAR
            STORE 'SHIP TO CUSTOMER NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @ 24,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,58 GET MSPACE
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
         DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_NAME", .F.
         SET PROC TO BUY_PROC
         MNAME_FD = .F.
         STORE MBUY_NAME TO MNAME
         STORE MBUY_NAME TO MDIS_NAME
         SAVE SCREEN TO MADD_SCRN
         DO BUY_SEL2
         RESTORE SCREEN FROM MADD_SCRN
         STORE MDIS_NAME TO MBUY_NAME
         @ 24,0 CLEAR
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
         @ 22,1  SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
      ENDIF
      
      SELECT A
      DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
      SEEK MBBUYCODE
      IF .NOT. EOF()
         STORE NAME TO MBBUYNAME
         STORE MBBUYNAME TO MSV_NAME
         STORE STREET TO MSTREET
         STORE CITY TO MCITY
         STORE STATE TO MSTATE
         IF ZIP4 = SPACE(4)
            STORE ZIP TO MZIP 
         ELSE
            STORE ZIP + '-' + ZIP4 TO MZIP
         ENDIF
      ELSE
         STORE SPACE(32) TO MBBUYNAME
         STORE MBBUYNAME TO MSV_NAME
         STORE SPACE(28) TO MSTREET
         STORE SPACE(20) TO MCITY
         STORE SPACE(2) TO MSTATE
         STORE SPACE(5) TO MZIP
      ENDIF
      
      ***** NOW GET BILL TO CUSTOMER
      MGET_NAME = .T.
      DO WHILE MGET_NAME
         @ 20,40 GET MBBUYNAME PICTURE '@!'
         @ 21,40 SAY MSTREET
         @ 22,40 SAY SPACE(35)
         @ 22,40 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
         READ
         IF MBBUYNAME = SPACE(32)
            @ 24,0 CLEAR
            STORE 'BILL TO CUSTOMER NAME NOT ENTERED - PRESS RETURN TO REENTER' TO MERROR
            @ 24,5 GET MERROR
            CLEAR GETS
            STORE ' ' TO MSPACE
            @ 24,58 GET MSPACE
            READ
            LOOP
         ENDIF
         IF MBBUYNAME = 'NONE'
            STORE 'NONE' TO MBBUYCODE
            STORE SPACE(28) TO MSTREET
            STORE SPACE(20) TO MCITY
            STORE SPACE(2) TO MSTATE
            STORE SPACE(5) TO MZIP
            STORE SPACE(4) TO MZIP4
            MGET_NAME = .F.
            LOOP
         ENDIF
         IF MBBUYNAME = 'SAME'
            STORE MBUY_NAME TO MNAME       
         ELSE
            STORE MBBUYNAME TO MNAME
         ENDIF
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYNAME", .F.
         SET PROC TO BUY_PROC
         MNAME_FD = .F.
         SAVE SCREEN TO MADD_SCRN
         DO BBUYSEL2
         RESTORE SCREEN FROM MADD_SCRN
         @ 24,0 CLEAR
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
         MGET_NAME = .F.
      ENDDO
      @ 20,40 SAY MBBUYNAME
      IF MBBUYNAME <> 'NONE'
         @ 21,40 SAY MSTREET
         @ 22,40 SAY SPACE(35)
         @ 22,40 SAY TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
      ENDIF
      
      STORE 1 TO MACTION
      @ 24,0 SAY 'Action: ' + STR(MACTION,1)
      @ 24,13 SAY '1. Item Page      2. Edit      3. Cancel Add'
      @ 24,8 GET MACTION PICTURE '#' RANGE 1,3
      
      READ
      
      DO CASE      
      CASE MACTION = 1
         SET PROC TO PO_PROC
         *** WRITE BACK THIS SCREEN OF DATA
         SELECT B
         DO FILELOCK
         APPEND BLANK
         UNLOCK
         
         DO REPLPO
         DO NEXT_PG
         *** IF FINISHED HERE COMING BACK FROM FREIGHT - FINISH IT UP
         MCONT = .F.
         *** MMORE = .F.
      CASE MACTION = 2
         LOOP
         
      CASE MACTION = 3
         MMCONT = .F.
         MMORE = .F.
         
      ENDCASE 
   ENDDO 
ENDDO
CLOSE DATA       

RETURN
* EOF: PO_ADD.PRG
*Formatted by: ToolBox Ver. 1.2  on 9/19/97 at 10:25 AM.
