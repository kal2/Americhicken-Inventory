******************
* Program.: VOID_CK.PRG
* Author..: Grace Keller
* Date....: 04/04/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: VOID A CHECK         
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
STORE 0 TO MCK_NBR
STORE CTOD(' ') TO MCK_DATE
SELECT B
DO FOX_USE WITH "DISBJRN INDEX DISBJRN, DISB_PO, DISBINV, DISBSTR, DISBINQ", .F.
SELECT A
DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
MTRAN_MO = TRAN_MO
MTRAN_YR = TRAN_YR
STORE CTOD(MTRAN_MO + '/01/'+ MTRAN_YR) TO MPREV_DATE

DO FOX_USE WITH "CK_REG INDEX CK_REG, CK_DATE", .F.
MPO_FD = .F.
STORE 1 TO MACTION
MPO_SEL = .T.

CLEAR 
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
MTITLE = ' - VOID CHECK'
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 TO 22,79
STORE ' ' TO MYES_NO
STORE 2 TO MACTION
DO WHILE MACTION = 2
   @ 10,5 SAY 'WAS CHECK PRINTED (Y/N) ? ' GET MYES_NO PICTURE '@!'
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   IF MACTION = 1
      IF MYES_NO <> 'Y' .AND. MYES_NO <> 'N'
         @ 24,0 CLEAR
         STORE ' ' TO MWAIT
         @ 24,0 SAY 'MUST ANSWER WITH A "Y" OR "N" - PRESS RETURN TO REENTER ' GET MWAIT
         STORE 2 TO MACTION
         @ 24,0 CLEAR
      ENDIF
   ENDIF
ENDDO
IF MACTION = 3 
   RETURN
ENDIF
@ 10,5 SAY SPACE(70)
DO WHILE MPO_SEL
   @  5, 5 SAY 'Enter Check Number to Void'
   @  7,14 get mck_nbr picture '#####'
   IF MYES_NO = 'Y'    
      STORE CTOD(' ') TO MCK_DATE
      @ 10,5 SAY '    Enter Check Date  '
      @ 12,13 get MCK_DATE
   ELSE
      STORE DATE() TO MCK_DATE
      @ 10,5 SAY '     Enter Void Date  '
      @ 12,13 get MCK_DATE
   ENDIF
   @ 18,5 say 'PLEASE VERIFY CHECK NUMBER AND DATE BEFORE CONTINUING !!!!'
   STORE 1 TO MACTION
   @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
   @ 24,13 SAY '1. Continue    2. Edit     3. Finished'                                     
   
   READ
   
   @24,09 GET MACTION PICTURE '9' RANGE 1,3
   READ               
   
   DO CASE
      
   CASE MACTION = 1 .OR. MACTION = 3
      IF MCK_NBR = 0
         MPO_SEL = .F.
         LOOP
      ENDIF
      @ 14,5 say 'Processing Void.....'
      IF MYES_NO = 'Y'
         STORE DTOC(MCK_DATE) TO MCK_DATE
         STORE SUBSTR(MCK_DATE,1,2) TO MJRNL_MO
         STORE SUBSTR(MCK_DATE,4,2) TO MJRNL_DAY
         STORE SUBSTR(MCK_DATE,7) TO MJRNL_YR
         STORE STR(MCK_NBR,6) TO MNBR
         
         SELECT B
         SEEK MJRNL_YR + MJRNL_MO + MJRNL_DAY + MNBR   
         IF EOF()
            STORE 'CHECK NUMBER NOT FOUND ON FILE WITH THIS DATE - PRESS RETURN TO REENTER ' TO MMSG
            @ 16,1 SAY SPACE(78)
            @ 16,1 GET MMSG
            READ  
            @ 16,1 SAY SPACE(78)
            LOOP
         ELSE
            DO CASE
            CASE POST_FLG = ' '
               STORE 'V' TO MVOID
               IF VOID_MAN = 'V'
                  STORE 'N' TO MYES_NO
                  @ 16,1 SAY 'CHECK IS ALREADY VOIDED... DO YOU WANT TO UN-VOID (Y/N)?? '
                  @ 16,61 GET MYES_NO PICTURE '@!'
                  READ
                  IF MYES_NO = 'Y'
                     STORE ' ' TO MVOID
                  ENDIF
               ENDIF
               DO WHILE .NOT. EOF() .AND. CK_NBR = MNBR .AND. JRNL_YR = MJRNL_YR .AND. JRNL_DAY = MJRNL_DAY .AND. JRNL_MO = MJRNL_MO
                  DO FILELOCK
                  REPLACE VOID_MAN WITH MVOID
                  UNLOCK
                  IF MVOID = 'V'
                     **** SET RECORDS BACK OUT THERE IF REALLY VOIDING
                     DO CASE
                     CASE ACCT_TYPE = 'S'
                        ** SUPPLIER CHECKS
                        SELECT D
                        DO FOX_USE WITH "SUP_INV INDEX SUP_INV", .F.
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE RSUPCODE WITH B->ACCT_NBR
                        REPLACE SALESMAN WITH B->SALESMAN
                        REPLACE PO_NBR WITH B->PO_NBR
                        REPLACE PO_SUFFIX WITH B->PO_SUFFIX
                        REPLACE INV_NBR WITH B->INV_NBR
                        REPLACE AMT_DUE WITH B->AMOUNT1              
                        REPLACE DUE_DATE WITH DATE()           
                        REPLACE SUP_INV WITH B->BILL_INV  
                        REPLACE DEB_CRD WITH 'Y'
                        UNLOCK
                        USE   
                        SELECT B
                     CASE ACCT_TYPE = 'F'
                        ** FREIGHT CHECKS
                        SELECT D
                        DO FOX_USE WITH "FRT_INV INDEX FRT_INV", .F.
                        DO FILELOCK
                        APPEND BLANK
                        REPLACE FRT_CODE WITH B->ACCT_NBR
                        REPLACE SALESMAN WITH B->SALESMAN
                        REPLACE PO_NBR WITH B->PO_NBR
                        REPLACE PO_SUFFIX WITH B->PO_SUFFIX
                        REPLACE INV_NBR WITH B->INV_NBR
                        REPLACE AMT_DUE WITH B->AMOUNT1              
                        REPLACE DUE_DATE WITH DATE()           
                        REPLACE FRT_INV WITH B->BILL_INV  
                        REPLACE DEB_CRD WITH 'Y'
                        *** MAYBE NOT RIGHT FOR MFI
                        ***REPLACE FRT_SEQ WITH '1'
                        UNLOCK
                        USE   
                        SELECT B
                     ENDCASE
                  ENDIF
                  SKIP
               ENDDO
               
               SELECT A
               SEEK MNBR    
               DO WHILE .NOT. EOF() .AND. CK_NBR = MNBR
                  IF DTOC(CK_DATE) = MCK_DATE
                     DO FILELOCK
                     REPLACE VOID_MAN WITH MVOID 
                     UNLOCK
                  ENDIF
                  SKIP
               ENDDO
            OTHERWISE
               DO WHILE .NOT. EOF() .AND. CK_NBR = MNBR .AND. JRNL_YR = MJRNL_YR .AND. JRNL_DAY = MJRNL_DAY .AND. JRNL_MO = MJRNL_MO
                  STORE RECNO() TO MRECNO
                  STORE SALESMAN TO MSALESMAN
                  STORE PO_NBR TO MPO_NBR
                  STORE PO_SUFFIX TO MPO_SUFFIX
                  STORE ADJUST  TO MADJUST
                  STORE AMOUNT1 TO MAMOUNT1
                  STORE AMOUNT2 TO MAMOUNT2
                  STORE AMOUNT3 TO MAMOUNT3
                  STORE AMOUNT4 TO MAMOUNT4
                  STORE CATEGORY1 TO MCATEGORY1
                  STORE INV_NBR TO MINV_NBR
                  STORE ACCT_TYPE TO MACCT_TYPE
                  STORE ACCT_NBR TO MACCT_NBR
                  STORE ACCT_NAME TO MACCT_NAME
                  STORE BILL_INV TO MBILL_INV
                  DO FILELOCK
                  APPEND BLANK
                  REPLACE JRNL_MO WITH MTRAN_MO
                  REPLACE JRNL_YR WITH MTRAN_YR
                  REPLACE JRNL_DAY WITH '15'
                  REPLACE CK_NBR WITH MNBR
                  REPLACE SALESMAN WITH MSALESMAN
                  REPLACE INV_NBR WITH MINV_NBR
                  REPLACE PO_NBR WITH MPO_NBR
                  REPLACE PO_SUFFIX WITH MPO_SUFFIX
                  REPLACE ADJUST  WITH MADJUST * -1
                  REPLACE AMOUNT1 WITH MAMOUNT1 * -1
                  REPLACE AMOUNT2 WITH MAMOUNT2 * -1
                  REPLACE AMOUNT3 WITH MAMOUNT3 * -1
                  REPLACE AMOUNT4 WITH MAMOUNT4 * -1
                  REPLACE CATEGORY1 WITH MCATEGORY1
                  REPLACE ACCT_TYPE WITH MACCT_TYPE
                  REPLACE ACCT_NBR WITH MACCT_NBR
                  REPLACE ACCT_NAME WITH MACCT_NAME
                  REPLACE BILL_INV WITH MBILL_INV
                  REPLACE SYS_DATE WITH DATE()
                  GOTO MRECNO
                  REPLACE VOID_MAN WITH 'V'
                  UNLOCK
                  SKIP
               ENDDO
               SELECT A
               SEEK MNBR    
               DO WHILE .NOT. EOF() .AND. CK_NBR = MNBR
                  IF DTOC(CK_DATE) = MCK_DATE
                     STORE RECNO() TO MRECNO
                     STORE PAY_CODE TO MPAY_CODE
                     STORE AMOUNT TO MAMOUNT
                     STORE PAY_TYPE TO MPAY_TYPE
                     STORE PAY_NAME TO MPAY_NAME
                     STORE DESCRIP TO MDESCRIP
                     DO FILELOCK
                     APPEND BLANK
                     REPLACE PAY_CODE WITH MPAY_CODE
                     REPLACE CK_NBR WITH MNBR
                     REPLACE CK_DATE WITH CTOD(MTRAN_MO+'/15/'+MTRAN_YR)
                     REPLACE AMOUNT WITH MAMOUNT * -1
                     REPLACE PAY_TYPE WITH MPAY_TYPE
                     REPLACE PAY_NAME WITH MPAY_NAME
                     REPLACE DESCRIP WITH MDESCRIP
                     REPLACE SYS_DATE WITH DATE()
                     REPLACE CLEAR_FLG WITH 'Y'
                     GOTO MRECNO
                     REPLACE VOID_MAN WITH 'V'
         
                     UNLOCK
                  ENDIF
                  SKIP
               ENDDO
            ENDCASE
         ENDIF
      ELSE
         **STORE MONTH(DATE()) TO MMONTH
         **STORE DAY(DATE()) TO MDAY
         **STORE YEAR(DATE()) TO MYEAR

         STORE MONTH(MCK_DATE) TO MMONTH
         STORE DAY(MCK_DATE) TO MDAY
         STORE YEAR(MCK_DATE) TO MYEAR
         STORE SUBSTR(STR(MMONTH+100,3),2) TO MMONTH
         STORE SUBSTR(STR(MDAY+100,3),2) TO MDAY
         STORE STR(MYEAR,4) TO MYEAR
         
         SELECT B
         DO FILELOCK
         APPEND BLANK
         REPLACE CK_NBR WITH STR(MCK_NBR,6)
         REPLACE SYS_DATE WITH DATE()
         REPLACE ACCT_TYPE WITH 'O'
         REPLACE JRNL_MO WITH MMONTH
         REPLACE JRNL_DAY WITH MDAY
         REPLACE JRNL_YR WITH MYEAR
         REPLACE VOID_MAN WITH 'V'
         UNLOCK
         SELECT A
         DO FILELOCK
         APPEND BLANK
         REPLACE CK_NBR WITH STR(MCK_NBR,6)
         REPLACE SYS_DATE WITH DATE()
         REPLACE PAY_TYPE WITH 'O' 
         REPLACE CK_DATE WITH DATE()
         REPLACE VOID_MAN WITH 'V'
         UNLOCK
      ENDIF
      MPO_SEL = .F.
      
   CASE MACTION = 2
      LOOP
      
   ENDCASE
   
ENDDO
CLOSE DATA
RETURN
* EOF: VOID_CK.PRG
*Formatted by: ToolBox Ver. 1.2  on 3/22/94 at 9:53 AM.
