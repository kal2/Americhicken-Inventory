*************
* Program.: HOLDRPT.PRG
* Author..: Grace Keller
* Date....: 10/26/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: FREIGHT LISTING 
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
CLEAR
@ 00,00 SAY MCOMPANY
@ 01,71 SAY DATE()
@ 01,00 SAY MPROGRAM + ' - ORDERS WITH HOLD STATUS'                 
@ 2,0 to 24,79
MPRT_DISP = 'P'
@ 21,16 SAY SPACE(34)
@ 07,3 SAY 'SELECT FOLLOWING OPTION'
STORE 'D'  TO MCHOICE
STORE 'N'  TO MOPT_ITMS
STORE 'NO ' TO MNEG_NET
STORE CTOD('') TO MCUTOFF
MORD_TYPE = 'C'
@ 07,3 SAY 'Display (D) or Print (P): ' GET MPRT_DISP PICTURE '@!'
@ 09,3 SAY 'INCLUDE Negative Net Orders (YES/NO): ' GET MNEG_NET PICTURE '@!' VALID(MNEG_NET = 'YES' .OR. MNEG_NET = 'NO')
@ 11,3 SAY 'OPTIONAL- Shipment Cutoff Date: ' GET MCUTOFF
@ 13,3 SAY 'INCLUDE ONLY Cust  Orders (C):'
@ 14,3 say '  -OR-  ONLY Inven Orders (I):'
@ 15,3 SAY '  -OR-  BOTH Types Orders (B): ' GET MORD_TYPE PICTURE '@!' VALID(MORD_TYPE = 'I' .OR. MORD_TYPE = 'C' .OR. MORD_TYPE = 'B') 
READ
IF MPRT_DISP <> 'D' .AND. MPRT_DISP <> 'P'
   RETURN
ELSE
   IF MPRT_DISP = 'P'
      MOPT_ITMS = 'Y'
      @ 17,3 SAY 'Print PO Item Details (Y/N):' GET MOPT_ITMS PICTURE '@!'
      READ
      MPAGE_LEN = 56
      MPRT_ACT = 'C'
      DO PRT_SET
      IF MPRT_ACT <> 'C'
         RETURN
      ENDIF
   ELSE
      MPAGE_LEN = 23
   ENDIF
ENDIF
MPAGE_NO = 0
MLINE = 99

SELECT C
DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.

IF MPRT_DISP = 'P'
   @ 19,3 SAY 'NOW SELECTING, PRINTING........'
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
   
ELSE
   CLEAR
ENDIF
SELECT D
DO FOX_USE WITH "PO_DTL INDEX PO_DTL", .F.

SELECT A
DO FOX_USE WITH "CONTROL", .F.
STORE TRAN_MO TO MTRAN_MO
STORE TRAN_YR TO MTRAN_YR

DO FOX_USE WITH "PO_HEAD INDEX PO_SHIP", .F.
SET FILTER TO INV_FLG = ' ' .AND. BROKERAGE = 'H'

MTOT_NET1 = 0
MTOT_NET2 = 0

SELECT B
DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_NAME", .F.

DO WHILE .NOT. EOF()
   
   SELECT A
   GOTO TOP
   
   DO WHILE .NOT. EOF()

      DO CASE
      CASE MORD_TYPE = 'I'
         ** ONLY PICK STUFF GOING INTO INVENTORY
         IF BBUYCODE <> 'INVN'
            SKIP
            LOOP
         ENDIF
      CASE MORD_TYPE = 'C'
         ** SKIP OVER STUFF GOING INTO INVENTORY
         IF BBUYCODE = 'INVN'
            SKIP
            LOOP
         ENDIF
      OTHERWISE
         *** LET BOTH TYPES INVEN & CUSTOMER ORDERS THRU
      ENDCASE

      IF BUY_CODE <> B->BUY_CODE
         SKIP
         LOOP
      ENDIF
      
      IF MCUTOFF <> CTOD('')
         IF SHIP_DATE > MCUTOFF
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      IF MNEG_NET = 'NO'
         IF TOT_NET < 0
            SKIP
            LOOP
         ENDIF
      ENDIF
      
      IF MLINE > MPAGE_LEN
         IF MPRT_DISP = 'P'
            IF MLINE <> 99
               EJECT        
            ENDIF
         ELSE
            IF MLINE <> 99
               STORE ' ' TO MWAIT
               @ 24,1 SAY 'PRESS RETURN/ENTER FOR NEXT PAGE ' GET MWAIT
               READ
            ENDIF
            CLEAR
         ENDIF
         MPAGE_NO = MPAGE_NO + 1
         MLINE = 1
         @ MLINE,1  SAY 'PAGE NBR: ' + STR(MPAGE_NO,2)
         @ MLINE,20 SAY MCOMPANY + SPACE(12) + DTOC(DATE())
         MLINE = MLINE + 1
         @ MLINE,20 SAY 'ORDERS ON HOLD REPORT' 
         MLINE = MLINE + 2
         @ MLINE,1 SAY 'PO NUMBER'
         @ MLINE,11 SAY 'SHIP DATE'
         @ MLINE,23 SAY 'DELIVERY'
         @ MLINE,35 SAY 'CUSTOMER'
         @ MLINE,60 SAY '       NET'
         @ MLINE,72 SAY 'FREIGHT'
         MLINE = 6
      ENDIF
      
      IF SALESMAN <> '  '
         @ MLINE,1 SAY SALESMAN
         @ MLINE,3 SAY '-'         
      ENDIF
      @ MLINE,4 SAY PO_NBR
      IF PO_SUFFIX <> ' '
         @ MLINE,8 SAY '-' + PO_SUFFIX
      ENDIF
      @ MLINE,11 SAY SHIP_DATE
      @ MLINE,23 SAY DEL_REQD
      @ MLINE,35 SAY SUBSTR(B->NAME,1,20)
      @ MLINE,60 SAY TOT_NET PICTURE '999,999.99'
      
      MCHECK =  STR(YEAR(SHIP_DATE),4) + SUBSTR(STR(MONTH(SHIP_DATE)+100,3),2)
      MCHECK = VAL(MCHECK)
      DO CASE
      CASE MCHECK <= VAL(MTRAN_YR+MTRAN_MO)
         MTOT_NET1 = MTOT_NET1 + TOT_NET
      OTHERWISE
         MTOT_NET2 = MTOT_NET2 + TOT_NET
      ENDCASE
      
      IF FRT_CODE1 = 'NONE'
         @ MLINE,72 SAY 'NONE'
      ELSE
         SELECT C
         SEEK A->FRT_CODE1
         IF EOF()
            @ MLINE,72 SAY 'UNKNOWN'
         ELSE
            @ MLINE,72 SAY SUBSTR(NAME,1,8)
         ENDIF
         SELECT A
      ENDIF
      
      IF MOPT_ITMS = 'Y'
         MLINE = MLINE + 1
         SELECT D
         SEEK A->SALESMAN + A->PO_NBR + A->PO_SUFFIX
         DO WHILE .NOT. EOF() .AND. SALESMAN = A->SALESMAN .AND. PO_NBR = A->PO_NBR .AND. PO_SUFFIX = A->PO_SUFFIX
            IF MLINE > MPAGE_LEN
               IF MLINE <> 99
                  EJECT        
               ENDIF
               MPAGE_NO = MPAGE_NO + 1
               MLINE = 1
               @ MLINE,1  SAY 'PAGE NBR: ' + STR(MPAGE_NO,2)
               @ MLINE,20 SAY MCOMPANY + SPACE(12) + DTOC(DATE())
               MLINE = MLINE + 1
               @ MLINE,20 SAY 'ORDERS ON HOLD REPORT' 
               MLINE = MLINE + 2
               @ MLINE,1 SAY 'PO NUMBER'
               @ MLINE,11 SAY 'SHIP DATE'
               @ MLINE,23 SAY 'DELIVERY'
               @ MLINE,35 SAY 'CUSTOMER'
               @ MLINE,60 SAY '       NET'
               @ MLINE,72 SAY 'FREIGHT'
               MLINE = 6
            ENDIF
            @ MLINE,11 SAY PROD_DESC
            @ MLINE,23 SAY QTY PICTURE '9999'
            IF IN_LOT <> SPACE(10)
               @ MLINE,35 SAY 'IN: ' + IN_LOT
            ENDIF
            IF OUT_LOT <> SPACE(10)
               @ MLINE,48 SAY 'OUT: ' + OUT_LOT
            ENDIF
            MLINE = MLINE + 1
            SKIP
         ENDDO

         MLINE = MLINE + 2
         SELECT A
         SKIP
         
      ELSE
         MLINE = MLINE + 2
         SELECT A
         SKIP
      ENDIF
   ENDDO
   SELECT B
   SKIP
   
ENDDO

IF MLINE =  99
   @ 10,3 SAY 'NO ORDERS ON HOLD SELECTED FOR REPORT'                            
ELSE
   IF MPRT_DISP = 'D'
      @ 23,1 CLEAR
      MLINE = 23
   ENDIF
   @ MLINE,1 SAY 'TOTAL NET CURRENT MONTH: ' + TRANSFORM(MTOT_NET1, '9,999,999.99')
   IF MTOT_NET2 <> 0
      **@ MLINE,45 SAY 'NET OTHER MONTH: ' + TRANSFORM(MTOT_NET2, '9,999,999.99')
   ENDIF
ENDIF

IF MPRT_DISP = 'P'
   EJECT
   
   SET DEVICE TO SCREEN
   SET PRINT OFF
   SET PRINT TO
   SET CONSOLE ON
   IF MPRINTER3 <> 'DONOTPRINT'
      RUN &MPRINTIT3
   ENDIF
   
ELSE
   STORE ' ' TO MWAIT
   @ 24,1 SAY 'PRESS RETURN TO FINISH ' GET MWAIT
   READ
ENDIF

CLOSE DATA
MRPT_SEL   = ' '
RETURN

* EOF: HOLDRPT.PRG
*Formatted by: ToolBox Ver. 1.2  on 5/18/21 at 9:31 AM.
