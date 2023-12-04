***************
* Program.: MAINT.PRG
* Author..: GRACE KELLER
* Date....: 10/20/87
* Notice..: Copyright (C) 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: File Maintenance Program
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

STORE ' ' TO MSELECTION
STORE ' ' TO MACTION

DO WHILE MSELECTION <> '9'
   CLOSE DATA
   
   CLEAR
   @ 01,00 SAY MCOMPANY
   @ 02,00 SAY MPROGRAM + ' - FILE MAINTENANCE MENU I'
   @ 02,70 SAY DATE()
   @ 3,0 TO 25,79
   
   @ 05,10 SAY '1 - REINDEX SELECTED MAIN FILES (Normally use this to Reindex)'       
   @ 07,10 SAY '2 - REINDEX ALL/SPECIFIC DATA FILES'
   @ 09,10 SAY '3 - CREATE SUPPLEMENTAL CUST/SUP/FRT INQUIRY FILES'
   @ 11,10 SAY '4 - UPDATE MASTER FILES (CUSTOMERS, SUPPLIERS, PRODUCTS, ETC.)'
   @ 13,10 SAY '5 - NOT USED'
   @ 15,10 SAY '6 - CALCULATE AGING DAYS/OUTSTANDING BALANCES FOR BILL TO CUSTOMERS'
   @ 17,10 say '7 - UPDATE NEXT INVOICE/CHECK/WIRE/DEBIT&CREDIT NBR TO USED'
   @ 19,10 SAY '8 - CHANGE TO NEW POSTING MONTH'
   @ 21,10 SAY '9 - RETURN TO MAIN MENU'
   
   STORE '1' TO MSELECTION
   @ 23,02 SAY 'CHOICE: '
   @ 23,25 say "('X' TO PAGE TO MAINTENANCE MENU II)"
   @ 23,10 GET MSELECTION PICTURE '@!'
   READ
   
   DO CASE
   CASE MSELECTION = 'X'
      DO MAINT2
   CASE MSELECTION = '2'   
      @ 04,01 CLEAR TO 23,78
      @ 07,10 SAY 'This will reindex all/specific data files.  This will not usually'
      @ 09,10 SAY 'be necessary.  It will usually take awhile.'
      @ 11,10 SAY 'WARNING: ALL OTHER USERS MUST BE COMPLETELY OUT OF THE PROGRAM!!!'
      @ 12,10 SAY 'PLEASE INFORM THEM BEFORE CONTINUING WITH THIS FUNCTION.'
      STORE 'NO ' TO MTEMP
      SET CONFIRM ON
      @ 15,20 SAY 'REINDEX DATA FILES (YES/NO)? ' GET MTEMP PICTURE '@!'
      
      READ
      SET CONFIRM OFF
      IF MTEMP = 'YES'
         DIMENSION MINDEX(39)
         STORE SPACE(1) TO MINDEX
         @ 04,01 CLEAR TO 23,78
         @ 4,1 SAY "Select with an 'X' the files to Reindex" 
         @ 5,1 SAY 'Supplier - Ship From (SUPPLIER)........'
         @ 6,1 SAY 'Supplier - Remit To (REM_SUP)..........'
         @ 7,1 say 'Customer - Ship To (BUYER).............' 
         @ 8,1 say 'Customer - Bill To (BIL_BUY)...........'
         @ 9,1 say 'Freight Carriers (FREIGHT).............'
         @ 10,1 say 'Salespersons (SALESMAN)................'
         @ 11,1 say '3rd Comm Payees/Fees(COMPAYEE/BROK_FEE)'
         @ 12,1 say 'Product Master (PRODUCTS)..............'
         @ 13,1 say 'Purchase Order Header(PO_HEAD/FRT2&3)..'
         @ 14,1 say 'Purchase Order Items (PO_DTL)..........'
         @ 15,1 say 'Item & Cus/Sup Hist (HIST_DTL/HIST_PG).'
         @ 16,1 say 'Invoice Header (INV_HEAD)..............'
         @ 17,1 say 'Customer Invoice (CUS_INV).............'
         @ 18,1 say 'Cust. Invoice Ajustments (INV_ADJ).....'
         @ 19,1 say 'Customer Receipts (PAYMENTS)...........'
         @ 20,1 say 'Daily Journal -SpreadSheet (DAILYJRN)..'
         @ 21,1 say 'Aging File (TEMP_AGE)..................'
         @ 22,1 say 'Supplier Matched Invoices (SUP_INV)....'
         @ 23,1 say 'Frt MatchedInv/Confirm(FRT_INV/FRTCONF)'
         @ 5,44 say 'Purchase Journal (PURCHJRN)....'
         @ 6,44 say 'Sales Journal (SALESJRN).......'
         @ 7,44 say 'Freight Journal (FRTJRN)........'
         @ 8,44 say 'Comm/BB Journal (COMJRN/BBKJRN).'
         @ 9,44 say 'Disbursements Journal (DISBJRN).'
         @ 10,44 say 'Purchase Ledger (SUPLED)........'
         @ 11,44 say 'Sales Ledger (CUSLED)...........'
         @ 12,44 say 'Freight Ledger (FRTLED).........'
         @ 13,44 say 'Com/BB Led(COMLED/COMTHD/BBKLED)'
         @ 14,44 say 'Check Register (CK_REG).........'
         @ 15,44 say 'Manual Chk/Payee(MAN_CK/PAYEES).'
         @ 16,44 say 'Comm. Misc. Charges (MISC_CHG)..'
         @ 17,44 say 'Chart of Accounts (ACCOUNTS)....'
         @ 18,44 say 'Comm. Adjustments (COM_ADJ/THD).'
         @ 19,44 say 'PO & Cust Notes (NOTES/BBUYNOTE)'
         @ 20,44 say 'Advisement Comments (PRT_NOTE)..'
         @ 21,44 say 'Customer PO Nbr File (CUST_PO)..'
         @ 22,44 say 'Inven(INVEN/INVN_DTL/FRZ_PULL)..'
         @ 23,44 SAY 'Misc Masters (PRICING/COMM/FEES)'
         MLINE = 5
         MTIMES = 1
         X = 1
         DO WHILE MTIMES <= 2
            DO WHILE MLINE <=23
               IF MTIMES = 1
                  @ MLINE,41 GET MINDEX(X) PICTURE '@!'
               ELSE
                  IF MLINE <= 23
                     @ MLINE,77 GET MINDEX(X) PICTURE '@!'
                  ENDIF
               ENDIF
               MLINE = MLINE + 1
               X = X + 1
            ENDDO
            MLINE = 5
            MTIMES = MTIMES + 1
         ENDDO
         READ
         
         CLOSE DATA
         @ 4,01 CLEAR TO 23,78
         SELECT A
         USE
         IF MINDEX(1) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'REINDEXING SHIP FROM SUPPLIER FILE......'
            USE &MDBFLOC.SUPPLIER EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            
            PACK
            INDEX ON NAME TO &MDBFLOC.SUP_NAME
            INDEX ON SUP_CODE TO &MDBFLOC.SUP_CODE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
            
         ENDIF
         
         IF MINDEX(2) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'REINDEXING REMIT TO SUPPLIER FILE......'
            USE &MDBFLOC.REM_SUP EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            *PACK
            INDEX ON NAME + ACTIVE TO &MDBFLOC.RSUPNAME
            INDEX ON RSUPCODE TO &MDBFLOC.RSUPCODE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(3) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'REINDEXING SHIP TO CUSTOMER FILE .........'
            USE &MDBFLOC.BUYER EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON NAME TO &MDBFLOC.BUY_NAME
            INDEX ON BUY_CODE TO &MDBFLOC.BUY_CODE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(4) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'REINDEXING BILL TO CUSTOMER FILE .........'
            USE &MDBFLOC.BIL_BUY EXCLUSIVE
            SET TALK ON 
            SET ECHO ON 
            SET STATUS ON 
            *PACK
            INDEX ON NAME + ACTIVE TO &MDBFLOC.BBUYNAME
            INDEX ON BBUYCODE TO &MDBFLOC.BBUYCODE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(5) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'REINDEXING FREIGHT CARRIER FILE...'
            USE &MDBFLOC.FREIGHT EXCLUSIVE
            SET TALK ON 
            SET ECHO ON 
            SET STATUS ON 
            *PACK
            INDEX ON NAME TO &MDBFLOC.FRT_NAME
            INDEX ON FRT_CODE TO &MDBFLOC.FRT_CODE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(6) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'REINDEXING SALESPERSON FILE ......'
            USE &MMASTDBF.SALESMAN EXCLUSIVE
            SET TALK ON 
            SET ECHO ON 
            SET STATUS ON 
            *pACK
            INDEX ON NAME TO &MMASTDBF.SAL_NAME
            INDEX ON SALE_CODE TO &MMASTDBF.SAL_CODE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(7) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'REINDEXING 3RD PARTY COMMISSION PAYEE FILE....'
            USE &MDBFLOC.COMPAYEE EXCLUSIVE
            SET TALK ON 
            SET ECHO ON 
            SET STATUS ON 
            *PACK
            INDEX ON NAME TO &MDBFLOC.COM_NAME
            INDEX ON COM_CODE TO &MDBFLOC.COM_CODE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
            
            @ 17,01 SAY SPACE(78)
            @ 17,20 SAY 'REINDEXING 3RD PARTY BROKERAGE FEE FILE.......'
            USE &MMASTDBF.BROK_FEE EXCLUSIVE
            SET TALK ON 
            SET ECHO ON 
            SET STATUS ON 
            *PACK
            INDEX ON COM_CODE + PROD_CODE TO &MMASTDBF.BROK_FEE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(8) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'REINDEXING PRODUCTS FILE....'
            USE &MDBFLOC.PRODUCTS EXCLUSIVE
            SET TALK ON 
            SET ECHO ON 
            SET STATUS ON 
            PACK        
            INDEX ON TYPE + CODE TO &MDBFLOC.PRODUCTS
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(9) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'PURCHASE ORDER HEADER FILE....'
            USE PO_HEAD EXCLUSIVE
            SET TALK ON 
            SET ECHO ON 
            SET STATUS ON 
            PACK
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO PO_HEAD
            INDEX ON INV_FLG + SALESMAN TO PRINT
            INDEX ON STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2) TO PO_SHIP
            INDEX ON RSUPCODE + SUP_REC + SUP_PD + STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2) TO PO_SUP
            ***INDEX ON FRT_CODE1 + FRT_REC + FRT_PD +  PO_NBR TO PO_FRT
            INDEX ON FRT_CODE1 + FRT_REC + FRT_PD + STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2)  TO PO_FRT
            UNLOCK
            USE FRT_2ND EXCLUSIVE
            PACK
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO FRT2_PO
            **INDEX ON FRT_CODE2 + FRT_REC2 + FRT_PD2 + SALESMAN + PO_NBR + PO_SUFFIX TO FRT2_FRT
            INDEX ON FRT_CODE2 + FRT_REC2 + FRT_PD2 + STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2) TO FRT2_FRT
            UNLOCK
            USE FRT_3RD EXCLUSIVE
            PACK
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO FRT3_PO
            **INDEX ON FRT_CODE3 + FRT_REC3 + FRT_PD3 + SALESMAN + PO_NBR + PO_SUFFIX TO FRT3_FRT
            INDEX ON FRT_CODE3 + FRT_REC3 + FRT_PD3 + STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2) TO FRT3_FRT
            UNLOCK
            USE SHIPWITH EXCLUSIVE
            PACK
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO SHIPWITH
            UNLOCK
            USE TEMPFED EXCLUSIVE
            PACK
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO TEMPFED
            UNLOCK
            USE FEDTHD EXCLUSIVE
            PACK
            INDEX ON STR(FED_KEY,5) TO FEDTHD
            UNLOCK
            
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(10) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'PURCHASE ORDER ITEM FILE....'
            USE PO_DTL EXCLUSIVE
            SET TALK ON 
            SET ECHO ON 
            SET STATUS ON 
            PACK
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + ITEM_NBR TO PO_DTL 
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(11) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'ITEM HISTORY FILE....'
            USE HIST_DTL EXCLUSIVE
            SET TALK ON 
            SET ECHO ON 
            SET STATUS ON 
            PACK
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + ITEM_NBR + STR(YEAR(HIST_DATE),4) + SUBSTR(DTOC(HIST_DATE),1,2) + SUBSTR(DTOC(HIST_DATE),4,2) + HIST_TIME TO HIST_DTL 
            UNLOCK
            
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'SUPPLIER/CUSTOMER HISTORY FILE ...'
            USE HIST_PG EXCLUSIVE
            SET TALK ON 
            SET ECHO ON 
            SET STATUS ON 
            PACK
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + STR(YEAR(HIST_DATE),4) + SUBSTR(DTOC(HIST_DATE),1,2) + SUBSTR(DTOC(HIST_DATE),4,2) + HIST_TIME TO HIST_PG  
            UNLOCK
            
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(12) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'INVOICE HEADER FILE....'
            USE INV_HEAD EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON INV_NBR TO INV_HEAD 
            INDEX ON  STR(YEAR(INV_DATE),4) + SUBSTR(DTOC(INV_DATE),1,2) + SUBSTR(DTOC(INV_DATE),4,2) + SUBSTR(DTOC(SHIP_DATE),1,2) TO INV_DATE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(13) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'CUSTOMER INVOICE/PAYMENT FILE..'
            USE CUS_INV EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON BBUYCODE + PAID_FLG + INV_NBR  TO CUS_INV
            INDEX ON  PAID_FLG + BBUYCODE + STR(YEAR(INV_DATE),4) + SUBSTR(DTOC(INV_DATE),1,2) + SUBSTR(DTOC(INV_DATE),4,2) TO CUS_DATE
            INDEX ON INV_NBR + DEB_CRD TO CUSIVNBR
            INDEX ON STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2)  TO CUS_SHIP
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(14) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'INVOICE ADJUSTMENT FILE..'
            USE INV_ADJ EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON INV_NBR + SALESMAN + PO_NBR + PO_SUFFIX TO INV_ADJ 
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(15) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'RECEIPTS FILE..'
            USE PAYMENTS EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON  STR(YEAR(PAID_DATE),4) + SUBSTR(DTOC(PAID_DATE),1,2) + SUBSTR(DTOC(PAID_DATE),4,2) + SALESMAN  + BBUYCODE TO PAY_DATE
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + STR(YEAR(PAID_DATE),4) + SUBSTR(DTOC(PAID_DATE),1,2) + SUBSTR(DTOC(PAID_DATE),4,2) TO PAY_PO
            INDEX ON  STR(YEAR(SYS_DATE),4) + SUBSTR(DTOC(SYS_DATE),1,2) + SUBSTR(DTOC(SYS_DATE),4,2) + SALESMAN + BBUYCODE TO PAY_CUST
            INDEX ON BBUYCODE + STR(CTOD('12/31/2099') - SYS_DATE,10) TO PAY_SYS 
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(16) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'DAILY JOURNAL FILE (SPREADSHEET)....'
            USE DAILYJRN EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            *PACK
            *        INDEX ON STR(YEAR(TRAN_DATE),4) + SUBSTR(DTOC(TRAN_DATE),1,2) + SUBSTR(DTOC(TRAN_DATE),4,2) TO JRN_DATE
            INDEX ON TRAN_YR + TRAN_MO + POST_FLG + INV_COR + INV_NBR TO JRN_MO    
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + POST_FLG + INV_COR + SEQ TO JRN_PO
            INDEX ON STR(YEAR(JRNL_DATE),4) + SUBSTR(DTOC(JRNL_DATE),1,2) + SUBSTR(DTOC(JRNL_DATE),4,2) + INV_NBR TO JRN_TRAN
            INDEX ON POST_FLG + INV_COR  + STR(YEAR(TRAN_DATE),4) + SUBSTR(DTOC(TRAN_DATE),1,2) + SUBSTR(DTOC(TRAN_DATE),4,2) + INV_NBR TO POSTED  
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
            @ 17,20 SAY 'SS MANUAL SPREADSHEET....'
            USE SS EXCLUSIVE
            PACK
            INDEX ON STR(YEAR(INV_DATE),4) + SUBSTR(DTOC(INV_DATE),1,2) + SUBSTR(DTOC(INV_DATE),4,2) TO SS
            INDEX ON TRAN_YR+TRAN_MO+SALESMAN+PO_NBR+PO_SUFFIX TO SS_YRMO
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF 
         ENDIF
         
         IF MINDEX(17) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'TEMPORARY AGING FILE..'
            USE TEMP_AGE EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON NAME + RSUPCODE + STR(YEAR(TRAN_DATE),4) + SUBSTR(DTOC(TRAN_DATE),1,2) + SUBSTR(DTOC(TRAN_DATE),4,2) TO TEMP_AGE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(18) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'SUPPLIER MATCHED INVOICES FILE..'
            USE SUP_INV EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON RSUPCODE + STR(YEAR(DUE_DATE),4) + SUBSTR(DTOC(DUE_DATE),1,2) + SUBSTR(DTOC(DUE_DATE),4,2) TO SUP_INV
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(19) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'FREIGHT MATCHED INVOICES FILE..'
            USE FRT_INV EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON FRT_CODE + STR(YEAR(DUE_DATE),4) + SUBSTR(DTOC(DUE_DATE),1,2) + SUBSTR(DTOC(DUE_DATE),4,2) TO FRT_INV
            UNLOCK
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'FREIGHT CONFIRMATIONS FILE.....'
            USE FRTCONF EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON FRT_CODE + STR(CTOD('12/31/2099') - CONF_DATE,10) TO FRTCONF 
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(20) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'PURCHASE JOURNAL FILE..'
            USE PURCHJRN EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON TRAN_YR + TRAN_MO + STR(YEAR(POST_DATE),4) + SUBSTR(DTOC(POST_DATE),1,2) + SUBSTR(DTOC(POST_DATE),4,2) TO PURCHJRN
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(21) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'SALES JOURNAL FILE..'
            USE SALESJRN EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON TRAN_YR + TRAN_MO + STR(YEAR(POST_DATE),4) + SUBSTR(DTOC(POST_DATE),1,2) + SUBSTR(DTOC(POST_DATE),4,2) TO SALESJRN 
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(22) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'FREIGHT JOURNAL FILE..'
            USE FRTJRN EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON TRAN_YR + TRAN_MO + STR(YEAR(POST_DATE),4) + SUBSTR(DTOC(POST_DATE),1,2) + SUBSTR(DTOC(POST_DATE),4,2) TO FRTJRN 
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(23) = 'X' 
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'COMMISSIONS JOURNAL FILE..'
            USE COMJRN EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON TRAN_YR + TRAN_MO + STR(YEAR(POST_DATE),4) + SUBSTR(DTOC(POST_DATE),1,2) + SUBSTR(DTOC(POST_DATE),4,2) TO COMJRN 
            UNLOCK
            @ 17,20 SAY 'BILLBACK JOURNAL FILE.....'
            USE BBKJRN EXCLUSIVE
            PACK
            INDEX ON TRAN_YR + TRAN_MO + STR(YEAR(POST_DATE),4) + SUBSTR(DTOC(POST_DATE),1,2) + SUBSTR(DTOC(POST_DATE),4,2) TO BBKJRN 
            UNLOCK
            
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(24) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'DISBURSEMENTS JOURNAL FILE..'
            USE DISBJRN EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON JRNL_YR + JRNL_MO + JRNL_DAY + CK_NBR TO DISBJRN 
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + ACCT_TYPE + CATEGORY1 TO DISB_PO
            INDEX ON ACCT_TYPE + ACCT_NBR + BILL_INV TO DISBINV
            INDEX ON ACCT_TYPE + ACCT_NBR + STR(VAL(BILL_INV),12) TO DISBSTR
            INDEX ON ACCT_TYPE + ACCT_NBR + STR(CTOD('12/31/2099') - CTOD(JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR),10) TO DISBINQ
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(25) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'SUPPLIER LEDGER FILE..'
            USE SUPLED EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON TRAN_YR + TRAN_MO + LED_CODE + STR(YEAR(POST_DATE),4) + SUBSTR(DTOC(POST_DATE),1,2) + SUBSTR(DTOC(POST_DATE),4,2) TO SUPLED
            INDEX ON LED_CODE+SALESMAN+PO_NBR+PO_SUFFIX+TRAN_YR+TRAN_MO TO SUPMATCH
            INDEX ON MATCH_FLG+LED_CODE+TRAN_YR+TRAN_MO+SALESMAN+PO_NBR+PO_SUFFIX TO SUPNOMAT
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(26) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'CUSTOMER LEDGER FILE..'
            USE CUSLED EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON TRAN_YR + TRAN_MO + LED_CODE + STR(YEAR(POST_DATE),4) + SUBSTR(DTOC(POST_DATE),1,2) + SUBSTR(DTOC(POST_DATE),4,2) TO CUSLED
            INDEX ON LED_CODE+SALESMAN+PO_NBR+PO_SUFFIX+TRAN_YR+TRAN_MO TO CUSMATCH
            INDEX ON MATCH_FLG + LED_CODE + TRAN_YR + TRAN_MO TO CUSNOMAT
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(27) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'FREIGHT LEDGER FILE..'
            USE FRTLED EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON TRAN_YR + TRAN_MO + FRT_CODE + STR(YEAR(POST_DATE),4) + SUBSTR(DTOC(POST_DATE),1,2) + SUBSTR(DTOC(POST_DATE),4,2) TO FRTLED
            INDEX ON FRT_CODE+SALESMAN+PO_NBR+PO_SUFFIX+TRAN_YR+TRAN_MO TO FRTMATCH
            INDEX ON MATCH_FLG+FRT_CODE+TRAN_YR+TRAN_MO TO FRTNOMAT
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(28) = 'X'
            DO CASE 
            CASE MCOMPANY <> 'DIVISION 15'
               @ 17,01 SAY SPACE(78)  
               @ 17,20 SAY 'COMMISSION LEDGER FILE..'
               USE &MMASTDBF.COMLED EXCLUSIVE
               SET TALK ON
               SET ECHO ON
               SET STATUS ON
               PACK
               INDEX ON TRAN_YR + TRAN_MO + COM_TYPE + COM_CODE + STR(YEAR(POST_DATE),4) + SUBSTR(DTOC(POST_DATE),1,2) + SUBSTR(DTOC(POST_DATE),4,2) TO &MMASTDBF.COMLED
               INDEX ON COM_PD + COM_TYPE + COM_CODE + TRAN_YR + TRAN_MO TO &MMASTDBF.COMPD
               UNLOCK
               
               USE &MMASTDBF.COMTHD EXCLUSIVE
               PACK
               INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + THD_SEQ + COM_PD + COR_FLG + SEQ TO &MMASTDBF.COMTHD
               INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + THD_SEQ + COM_PD+ STR(YEAR(TRAN_DATE),4) + SUBSTR(DTOC(TRAN_DATE),1,2) + SUBSTR(DTOC(TRAN_DATE),4,2) TO &MMASTDBF.COMTDT
               INDEX ON COM_PD + LED_CODE TO &MMASTDBF.COMTPD
               UNLOCK
               
               @ 17,20 SAY 'BILLBACK LEDGER FILE....'
               USE &MMASTDBF.BBKLED EXCLUSIVE
               PACK
               INDEX ON TRAN_YR + TRAN_MO + COM_TYPE + LED_CODE + STR(YEAR(POST_DATE),4) + SUBSTR(DTOC(POST_DATE),1,2) + SUBSTR(DTOC(POST_DATE),4,2) TO &MMASTDBF.BBKLED
               INDEX ON COM_PD + COM_TYPE + LED_CODE + TRAN_YR + TRAN_MO TO &MMASTDBF.BBKPD
               UNLOCK
               
               SET TALK OFF
               SET ECHO OFF
               SET STATUS OFF
            OTHERWISE
               @ 17,01 SAY SPACE(78)  
               @ 17,20 SAY 'SALESPERSON EARNINGS FILE..' 
               USE ERNLED EXCLUSIVE
               SET TALK ON
               SET ECHO ON
               SET STATUS ON
               PACK
               INDEX ON TRAN_YR + TRAN_MO + COM_TYPE + COM_CODE + STR(YEAR(POST_DATE),4) + SUBSTR(DTOC(POST_DATE),1,2) + SUBSTR(DTOC(POST_DATE),4,2) TO ERNLED
               INDEX ON COM_PD + COM_TYPE + COM_CODE + TRAN_YR + TRAN_MO TO ERNPD
               UNLOCK
               SET TALK OFF
               SET ECHO OFF
               SET STATUS OFF
            ENDCASE
         ENDIF
         
         IF MINDEX(29) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'CHECK REGISTER FILE..'
            USE CK_REG EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON CK_NBR TO CK_REG
            INDEX ON STR(YEAR(CK_DATE),4) + SUBSTR(DTOC(CK_DATE),1,2) + SUBSTR(DTOC(CK_DATE),4,2) + CK_NBR TO CK_DATE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(30) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'MANUAL CHECK / PAYEES PRINT FILE..'
            USE MAN_CK EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON NAME TO MAN_CK  
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
            
            USE PAYEES EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON NAME+STREET TO PAYEES  
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(31) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'MISCELLANEOUS CHARGE FILE..'
            USE MISC_CHG EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO MISC_CHG
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(32) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'CHART OF ACCOUNTS FILE ..'
            USE &MMASTDBF.ACCOUNTS EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON ACCOUNT TO &MMASTDBF.ACCOUNTS
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(33) = 'X'
            DO CASE
            CASE MCOMPANY <> 'DIVISION 15'
               @ 17,01 SAY SPACE(78)  
               @ 17,20 SAY 'COMMISSIONS ADJUSTMENT FILE..'
               USE COM_ADJ EXCLUSIVE
               SET TALK ON
               SET ECHO ON
               SET STATUS ON
               PACK
               INDEX ON COM_TYPE + COM_CODE TO COM_ADJ
               UNLOCK
               @ 17,01 SAY SPACE(78)  
               @ 17,20 SAY 'THIRD PARTY ADJUSTMENT FILE..'
               USE THD_ADJ EXCLUSIVE
               SET TALK ON
               SET ECHO ON
               SET STATUS ON
               PACK
               INDEX ON COM_TYPE + COM_CODE TO THD_ADJ
               UNLOCK
               SET TALK OFF
               SET ECHO OFF
               SET STATUS OFF
            OTHERWISE
               @ 17,01 SAY SPACE(78)  
               @ 17,20 SAY 'EARNINGS OP EXPENSE/ADJUSTMENT FILE..'
               USE ERN_ADJ EXCLUSIVE
               SET TALK ON
               SET ECHO ON
               SET STATUS ON
               PACK
               INDEX ON COM_TYPE + COM_CODE TO ERN_ADJ
               UNLOCK
               SET TALK OFF
               SET ECHO OFF
               SET STATUS OFF
            ENDCASE
         ENDIF
         
         IF MINDEX(34) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'PURCHASE ORDER NOTES FILE..'
            USE NOTES EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + SEQ TO NOTES
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'BILL TO CUSTOMER NOTES FILE..'
            USE BBUYNOTE EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON BBUYCODE + SEQ TO BBUYNOTE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(35) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'ADVISEMENT/INVOICE COMMENTS FILE..'
            USE PRT_NOTE EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            PACK
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO PRT_NOTE
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(36) = 'X'
            @ 17,01 SAY SPACE(78)  
            @ 17,20 SAY 'CUSTOMER PO NUMBER FILE..'
            USE CUST_PO EXCLUSIVE
            PACK
            INDEX ON BBUYCODE + BUYER_PO TO CUST_PO
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF 
         ENDIF
         
         IF MINDEX(37) = 'X'
            @ 17,01 SAY SPACE(78)  
            ****** OLD FILE NOT NEEDED
            **@ 17,20 SAY 'SS MANUAL SPREADSHEET....'
            **USE SS EXCLUSIVE
            **PACK
            **INDEX ON STR(YEAR(INV_DATE),4) + SUBSTR(DTOC(INV_DATE),1,2) + SUBSTR(DTOC(INV_DATE),4,2) TO SS
            **INDEX ON TRAN_YR+TRAN_MO+SALESMAN+PO_NBR+PO_SUFFIX TO SS_YRMO
            **UNLOCK
            **SET TALK OFF
            **SET ECHO OFF
            **SET STATUS OFF 
            @ 17,20 SAY 'MAIN INVENTORY FILE......'
            USE INVEN EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            
            PACK
            INDEX ON LOT_NBR TO INVNLOT
            INDEX ON SALESMAN+PO_NBR+PO_SUFFIX TO INVNPO
            INDEX ON FREEZ_LOC + LOT_NBR TO INVNLOC
            INDEX ON SOLD_FLG+DIV_CODE+FREEZ_LOC+PROD_DESC+STR(YEAR(ANIV_DATE),4)+SUBSTR(DTOC(ANIV_DATE),1,2) + SUBSTR(DTOC(ANIV_DATE),4,2) + LOT_NBR TO INVNSOLD
            INDEX ON STR(I_NBR,5) TO INVNINBR
            INDEX ON STR(YEAR(ANIV_DATE),4)+SUBSTR(DTOC(ANIV_DATE),1,5) TO INVNANIV
            INDEX ON IPRODDESC TO INVNCAT 
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
            
            @ 17,01 SAY SPACE(78)  
            
            @ 17,20 SAY 'HOLDING INVENTORY FILE......'
            USE HINVEN EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            
            PACK
            INDEX ON FREEZ_LOC + LOT_NBR TO HINVNLOC
            INDEX ON SOLD_FLG+DIV_CODE+FREEZ_LOC+PROD_DESC+STR(YEAR(ANIV_DATE),4)+SUBSTR(DTOC(ANIV_DATE),1,2) + SUBSTR(DTOC(ANIV_DATE),4,2) TO HINVSOLD
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
            
            @ 17,01 SAY SPACE(78)  
            
            @ 17,20 SAY 'INVENTORY ACTIVITY DETAIL FILE....'
            USE INVN_DTL EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            
            PACK
            INDEX ON STR(I_NBR,5)+STR(YEAR(ACT_DATE),4)+SUBSTR(DTOC(ACT_DATE),1,2) + SUBSTR(DTOC(ACT_DATE),4,2) TO IDTL_DTL
            INDEX ON STR(I_NBR,5) + SALESMAN + PO_NBR+PO_SUFFIX TO INVN_PO
            INDEX ON STR(I_NBR,5) + ACT_CODE + STR(CTOD('12/31/2099')-ACT_DATE,10) + ACT_CODE TO INVNDISP
            INDEX ON STR(YEAR(ACT_DATE),4)+SUBSTR(DTOC(ACT_DATE),1,5) TO DTL_DATE
            INDEX ON SALESMAN+PO_NBR+PO_SUFFIX+ITEM_NBR+ACT_CODE TO INVN_DTL
            INDEX ON FREEZ_LOC + LOT_NBR + ACT_CODE TO DTL_LOT
            UNLOCK
            
            
            @ 17,20 SAY 'HOLDING INVENTORY DETAIL FILE....'
            USE HINV_DTL EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            
            ***PACK
            INDEX ON SALESMAN+PO_NBR+PO_SUFFIX+ITEM_NBR+ACT_CODE TO HINV_DTL
            INDEX ON FREEZ_LOC + LOT_NBR + ACT_CODE TO HDTL_LOT
            UNLOCK
            
            @ 17,20 SAY 'AUTO-PULL FREEZER MASTER FILE....'
            USE FRZ_PULL EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            
            ***PACK
            INDEX ON FREEZ_LOC + BUY_CODE + PROD_DESC TO FRZ_PULL
            UNLOCK
            
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         IF MINDEX(38) = 'X'
            @ 17,01 SAY SPACE(78)  
            **@ 17,20 SAY 'INVENTORY LEDGER.........'
            **USE INVLED EXCLUSIVE
            **PACK
            **INDEX ON TRAN_YR + TRAN_MO + STR(YEAR(POST_DATE),4) + SUBSTR(DTOC(POST_DATE),1,2) + SUBSTR(DTOC(POST_DATE),4,2) TO INVLED
            **UNLOCK
            **SET TALK OFF
            **SET ECHO OFF
            **SET STATUS OFF 
            
            @ 17,20 SAY 'CUSTOMER PRICING MASTER (PRI_MAST).'
            USE &MDBFLOC.PRI_MAST EXCLUSIVE
            SET TALK ON 
            SET ECHO ON 
            SET STATUS ON 
            PACK
            INDEX ON BBUYCODE + PROD_DESC TO &MDBFLOC.PRI_MAST
            UNLOCK
            
            @ 17,20 SAY 'NATIONAL PRICING MASTER (NATLMAST).'
            USE &MDBFLOC.NATLMAST EXCLUSIVE
            PACK
            INDEX ON PROD_DESC TO &MDBFLOC.NATLMAST
            UNLOCK
            
            @ 17,20 SAY 'CUSTOMER BROKER/BILLBACK (CUSTCOMM)'
            USE &MDBFLOC.CUSTCOMM EXCLUSIVE
            PACK
            INDEX ON BBUYCODE TO &MDBFLOC.CUSTCOMM
            UNLOCK
            
            @ 17,20 SAY 'BROKER/BILLBACK FEES (BROK_FEE)....'
            USE BROK_FEE EXCLUSIVE
            PACK
            INDEX ON COM_CODE + PROD_CODE TO BROK_FEE
            UNLOCK
            
            @ 17,20 SAY 'PROMO/INCENTIVES MASTER (PROMOS)...'
            USE &MDBFLOC.PROMOS EXCLUSIVE
            PACK
            INDEX ON BBUYCODE + PROD_DESC TO &MDBFLOC.PROMOS
            UNLOCK
            
            @ 17,20 SAY 'PICKUP ALLOWNCES (PICKUP/PKUPITEM)'
            USE &MDBFLOC.PICKUP EXCLUSIVE
            PACK
            INDEX ON BBUYCODE TO &MDBFLOC.PICKUP  
            UNLOCK

            USE &MDBFLOC.PKUPITEM EXCLUSIVE
            PACK
            INDEX ON BUY_CODE + PROD_DESC TO &MDBFLOC.PKUPITEM  
            UNLOCK
            
            @ 17,20 SAY 'PROMO-CUST OFF ITEM PRICE (CUSIOFF)'
            USE &MDBFLOC.CUSIOFF EXCLUSIVE
            PACK
            INDEX ON BBUYCODE + PROD_DESC TO &MDBFLOC.CUSIOFF   
            UNLOCK
            
            @ 17,20 SAY 'PROMO-CUST OFF INVOICE (CUSIPROM)..'
            USE &MDBFLOC.CUSIPROM EXCLUSIVE
            PACK
            INDEX ON BBUYCODE + PROD_DESC TO &MDBFLOC.CUSIPROM  
            UNLOCK
            
            @ 17,20 SAY 'CUSTOMER DEDUCTIONS (CUST_DED).....'
            USE &MDBFLOC.CUST_DED EXCLUSIVE
            PACK
            INDEX ON BBUYCODE TO &MDBFLOC.CUST_DED  
            UNLOCK
            
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         USE
         
         LOOP
      ENDIF
      
   CASE MSELECTION = '1'   
      STORE ' ' TO MSEL1, MSEL2, MSEL3, MSEL4, MSEL5
      @ 05,00 CLEAR
      @ 3,0 to 25,79
      @ 05,05 SAY 'This will reindex only the files selected with an "X"'
      @ 08,05 SAY 'WARNING: ALL OTHER USERS MUST BE COMPLETELY OUT OF THE PROGRAM!!!'
      @ 10,05 SAY 'PLEASE INFORM THEM BEFORE CONTINUING WITH THIS FUNCTION.'
      
      @ 12,05 SAY '      Purchase Order Header File: ' get msel1 picture '@!'
      @ 13,05 say '           Customer Invoice File: ' get msel2 picture '@!'
      @ 14,05 say 'Daily Journal (Spreadsheet) File: ' get msel3 picture '@!'
      @ 15,05 say '      Disbursements Journal File: ' get msel4 picture '@!'
      @ 16,05 say '           Receipts Journal File: ' get msel5 picture '@!'
      read
      STORE 'N' TO MTEMP
      set confirm on
      @ 19,20 SAY 'OK TO REINDEX FILES? ' GET MTEMP PICTURE '!'
      READ
      set confirm off
      IF MTEMP = 'Y'
         CLOSE DATA
         SELECT A
         IF MSEL1 = 'X'
            @ 21,01 SAY SPACE(78)  
            @ 21,20 SAY 'PURCHASE ORDER HEADER FILE....'
            USE PO_HEAD EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO PO_HEAD
            INDEX ON INV_FLG + SALESMAN TO PRINT
            INDEX ON STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2) TO PO_SHIP
            INDEX ON RSUPCODE + SUP_REC + SUP_PD + STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2) TO PO_SUP
            ***INDEX ON FRT_CODE1 + FRT_REC + FRT_PD +  PO_NBR TO PO_FRT
            INDEX ON FRT_CODE1 + FRT_REC + FRT_PD + STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2)  TO PO_FRT
            USE SHIPWITH EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO SHIPWITH
            
            USE TEMPFED EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX TO TEMPFED
            
            USE FEDTHD EXCLUSIVE
            PACK
            INDEX ON STR(FED_KEY,5) TO FEDTHD
            UNLOCK
            
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         IF MSEL2 = 'X'
            @ 21,01 SAY SPACE(78)  
            @ 21,20 SAY 'CUSTOMER INVOICE/PAYMENT FILE..'
            USE CUS_INV EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            INDEX ON BBUYCODE + PAID_FLG + INV_NBR  TO CUS_INV
            INDEX ON  PAID_FLG + BBUYCODE + STR(YEAR(INV_DATE),4) + SUBSTR(DTOC(INV_DATE),1,2) + SUBSTR(DTOC(INV_DATE),4,2) TO CUS_DATE
            INDEX ON INV_NBR + DEB_CRD TO CUSIVNBR
            INDEX ON STR(YEAR(SHIP_DATE),4) + SUBSTR(DTOC(SHIP_DATE),1,2) + SUBSTR(DTOC(SHIP_DATE),4,2)  TO CUS_SHIP
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         IF MSEL3 = 'X'
            @ 21,01 SAY SPACE(78)  
            @ 21,20 SAY 'DAILY JOURNAL (SPREADSHEET) FILE..'
            USE DAILYJRN EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            INDEX ON TRAN_YR + TRAN_MO + POST_FLG + INV_COR + INV_NBR TO JRN_MO    
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + POST_FLG + INV_COR + SEQ TO JRN_PO
            INDEX ON STR(YEAR(JRNL_DATE),4) + SUBSTR(DTOC(JRNL_DATE),1,2) + SUBSTR(DTOC(JRNL_DATE),4,2) + INV_NBR TO JRN_TRAN
            INDEX ON POST_FLG + INV_COR  + STR(YEAR(TRAN_DATE),4) + SUBSTR(DTOC(TRAN_DATE),1,2) + SUBSTR(DTOC(TRAN_DATE),4,2) + INV_NBR TO POSTED  
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
            @ 17,20 SAY 'SS MANUAL SPREADSHEET....'
            USE SS EXCLUSIVE
            PACK
            INDEX ON STR(YEAR(INV_DATE),4) + SUBSTR(DTOC(INV_DATE),1,2) + SUBSTR(DTOC(INV_DATE),4,2) TO SS
            INDEX ON TRAN_YR+TRAN_MO+SALESMAN+PO_NBR+PO_SUFFIX TO SS_YRMO
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF 
         ENDIF
         IF MSEL5 = 'X'
            @ 21,01 SAY SPACE(78)  
            @ 21,20 SAY 'RECEIPTS FILE..'
            USE PAYMENTS EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            INDEX ON STR(YEAR(PAID_DATE),4) + SUBSTR(DTOC(PAID_DATE),1,2) + SUBSTR(DTOC(PAID_DATE),4,2) + SALESMAN TO PAY_DATE
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + STR(YEAR(PAID_DATE),4) + SUBSTR(DTOC(PAID_DATE),1,2) + SUBSTR(DTOC(PAID_DATE),4,2) TO PAY_PO
            INDEX ON STR(YEAR(SYS_DATE),4) + SUBSTR(DTOC(SYS_DATE),1,2) + SUBSTR(DTOC(SYS_DATE),4,2) + SALESMAN + BBUYCODE TO PAY_CUST
            INDEX ON BBUYCODE + STR(CTOD('12/31/2099') - SYS_DATE,10) TO PAY_SYS 
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         IF MSEL4 = 'X'
            @ 21,01 SAY SPACE(78)  
            @ 21,20 SAY 'DISBURSEMENTS JOURNAL FILE..'
            USE DISBJRN EXCLUSIVE
            SET TALK ON
            SET ECHO ON
            SET STATUS ON
            INDEX ON JRNL_YR + JRNL_MO + JRNL_DAY + CK_NBR TO DISBJRN 
            INDEX ON SALESMAN + PO_NBR + PO_SUFFIX + ACCT_TYPE + CATEGORY1 TO DISB_PO
            INDEX ON ACCT_TYPE + ACCT_NBR + BILL_INV TO DISBINV
            INDEX ON ACCT_TYPE + ACCT_NBR + STR(VAL(BILL_INV),12) TO DISBSTR
            INDEX ON ACCT_TYPE + ACCT_NBR + STR(CTOD('12/31/2099') - CTOD(JRNL_MO + '/' + JRNL_DAY + '/' + JRNL_YR),10) TO DISBINQ
            UNLOCK
            SET TALK OFF
            SET ECHO OFF
            SET STATUS OFF
         ENDIF
         
         USE
      ENDIF
   CASE MSELECTION = '3'   
      CLEAR
      *DO CASE
      *CASE MPROG_CODE = 1
      *   RUN BACKUP &MMASTDBF.*.DBF A:
      *CASE MPROG_CODE = 2
      *   RUN BACKUP C:\MFI\*.DBF A:
      *ENDCASE
      
      WAIT
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 02,00 SAY MPROGRAM + ' - FILE MAINTENANCE MENU'
      @ 02,70 SAY DATE()
      @ 3,0 to 25,79
      @ 17,20 SAY 'CREATING SUPPLEMENTAL PURCHASE ORDER INDEX FILES....'
      USE PO_HEAD EXCLUSIVE
      INDEX ON BBUYCODE + STR(CTOD('12/31/2099') - SHIP_DATE,10) TO TMP_BUY
      INDEX ON RSUPCODE + STR(CTOD('12/31/2099') - SHIP_DATE,10) TO TMP_SUP
      INDEX ON FRT_CODE1 + STR(CTOD('12/31/2099') - SHIP_DATE,10) TO TMP_FRT
      UNLOCK
      
      LOOP
      
   CASE MSELECTION = '4'
      DO MASTER
      
   CASE MSELECTION = '5'
      MSELECTION = ' '
      
   CASE MSELECTION = '6'
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 02,00 SAY MPROGRAM + ' - CALCULATE CUSTOMER AGING DAYS/BALANCES'
      @ 02,68 SAY DATE()
      @ 3,0 to 25,79
      MCHOICE = ' '
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 8,5 SAY 'Calculate aging DAYS (D), BALANCES (B), or BOTH (O)? ' GET MCHOICE PICTURE '@!'
         STORE 1 TO MACTION
         @ 24,01 SAY 'Action: ' + STR(MACTION,1)  
         @ 24,13 SAY '1. Continue    2. Edit     3. Cancel'                                     
         READ
         @24,09 GET MACTION PICTURE '9' RANGE 1,3
         READ               
      ENDDO
      IF MACTION = 3
         LOOP
      ENDIF
      IF MCHOICE = 'D' .OR. MCHOICE = 'O'
         *** CALCULATE TWO TIME PERIODS OF PREVIOUS 6 MONTHS, PREVIOUS 25 DAYS
         STORE DATE() TO MCURRENT
         IF MPROG_CODE = 1
            MBEG_DT180 = MCURRENT - 180
            MBEG_DT25 = MCURRENT - 25
         ELSE
            MBEG_DT180 = MCURRENT - 730
            MBEG_DT25 = MCURRENT - 365 
            
         ENDIF
         STORE MONTH(MBEG_DT180) TO MMONTH
         MMONTH = MMONTH + 100
         STORE SUBSTR(STR(MMONTH,3),2) TO MMONTH
         
         STORE YEAR(MBEG_DT180) TO MYEAR
         STORE STR(MYEAR,4) TO MYEAR
         
         SELECT B
         DO FOX_USE WITH "CUS_INV INDEX CUS_SHIP", .F.
         SELECT C
         DO FOX_USE WITH "PAYMENTS INDEX PAY_PO", .F.
         SELECT A
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         @ 17,15 SAY 'CALCULATING CUSTOMER AGING DAYS - PLEASE WAIT...'
         GOTO TOP
         
         
         DO WHILE .NOT. EOF()
            DO RECLOCK
            REPLACE SHIPS_180 WITH 0
            REPLACE SHIPS_25 WITH 0
            REPLACE DAYS_180 WITH 0
            REPLACE DAYS_25 WITH 0
            UNLOCK
            SKIP
         ENDDO
         SELECT B
         SEEK MYEAR + MMONTH
         IF EOF() .AND. MPROG_CODE = 2 .AND. MBEG_DT180 < CTOD('07/01/1990')
            SEEK '9007'
         ENDIF
         
         DO WHILE .NOT. EOF() .AND. SHIP_DATE <= MCURRENT 
            STORE BBUYCODE TO MBBUYCODE
            IF PAID_FLG = ' ' .OR. SUBSTR(INV_NBR,1,1) = 'A' .OR. DEB_CRD = 'Y' 
               SKIP
               LOOP
            ENDIF
            
            IF SHIP_DATE < MBEG_DT180
               SKIP
               LOOP
            ENDIF
            SELECT C
            SEEK B->SALESMAN + B->PO_NBR + B->PO_SUFFIX
            IF .NOT. EOF()
               MDAYS = (PAID_DATE - B->SHIP_DATE)
               IF B->PO_NBR = '6556' .AND. B->PO_SUFFIX = ' '
                  MDAYS = MDAYS - 30
               ENDIF
               IF MDAYS < 0
                  MDAYS = 0
               ENDIF
               
               SELECT A
               SEEK MBBUYCODE
               IF .NOT. EOF()
                  DO RECLOCK
                  REPLACE SHIPS_180 WITH SHIPS_180 + 1
                  REPLACE DAYS_180 WITH DAYS_180 + MDAYS
                  IF C->PAID_DATE >= MBEG_DT25
                     REPLACE SHIPS_25 WITH SHIPS_25 + 1
                     REPLACE DAYS_25 WITH DAYS_25 + MDAYS
                  ENDIF
                  UNLOCK
               ENDIF
            ENDIF
            SELECT B
            SKIP
         ENDDO
         CLOSE DATA
      ENDIF
      
      IF MCHOICE = 'B' .OR. MCHOICE = 'O'
         @ 17,15 SAY 'CALCULATING CUSTOMER BALANCES.... PLEASE WAIT...'
         SELECT C
         DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
         DO WHILE .NOT. EOF()
            DO RECLOCK
            REPLACE CUS_BAL WITH 0
            UNLOCK
            SKIP
         ENDDO
         SELECT A
         DO FOX_USE WITH "CUS_INV INDEX CUS_DATE", .F.
         SEEK ' '
         
         DO WHILE .NOT. EOF() .AND. PAID_FLG = ' '
            STORE BBUYCODE TO MBBUYCODE
            MBALANCE = 0
            DO WHILE .NOT. EOF() .AND. PAID_FLG = ' ' .AND. BBUYCODE = MBBUYCODE
               MSTILL_DUE = TOT_SELL + CUS_PALL - AMT_PAID
               IF MSTILL_DUE > 0 
                  MBALANCE = MBALANCE + MSTILL_DUE
               ENDIF
               SKIP
            ENDDO
            SELECT C
            SEEK MBBUYCODE
            IF .NOT. EOF()
               DO RECLOCK
               REPLACE CUS_BAL WITH MBALANCE 
               IF CUS_BAL  > HIGH_BAL
                  REPLACE HIGH_BAL WITH CUS_BAL 
               ENDIF
               UNLOCK
            ENDIF
            SELECT A
         ENDDO
      ENDIF
      CLOSE DATA
   CASE MSELECTION = '7'
      *    DO FIXUP  
      CLEAR
      @ 01,00 SAY MCOMPANY
      @ 02,00 SAY MPROGRAM + ' - FILE MAINTENANCE MENU I'
      @ 02,68 SAY DATE()
      @ 3,0 to 23,79
      SELECT A 
      DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
      STORE 0 TO MINV_NBR, mlck_nbr, mwire_nbr, mdc_nbr
      STORE CK_PRINT TO MCK_PRINT
      store space(8) to mequity1, mequity2
      STORE 2 TO MACTION
      DO WHILE MACTION = 2
         @ 04,5 SAY 'The following numbers are the NEXT numbers to be assigned '
         @ 06,5 say '     Invoice Number: '+ STR(inv_nbr+1,5)
         @ 07,5 say '       Check Number: '+ str(lck_nbr,6)
         @ 08,5 say '        Wire Number: ' + str(wire_nbr,6)
         @ 09,5 say 'Debit/Credit Number: ' + str(dc_nbr,6)
         @ 10,5 SAY '      Equity Lot# 1: ' + equity1 + space(10) + 'Equity Lot#2: ' + equity2
         @ 12,5 SAY 'Enter the NEXT/NEW number(s) you want to be assigned'
         @ 13,5 say 'in the appropriate category.'
         @ 15,5 say '     Invoice Number: ' get minv_nbr picture '#####'
         @ 16,5 say '       Check Number: ' get mlck_nbr picture '######'
         @ 17,5 say '        Wire Number: ' get mwire_nbr picture '######'
         @ 18,5 say 'Debit/Credit Number: ' get mdc_nbr picture '######'
         @ 19,5 SAY '      Equity Lot# 1: ' + space(18) + 'Equity Lot#2: '            
         @ 19,27 get mequity1 picture '@!'
         @ 19,59 get mequity2 picture '@!'
         @ 21,2 SAY 'Check Print Flag (Y/N): ' get mck_print picture '@!'
         IF MCK_PRINT = 'Y'
            @ 21,35 SAY '(Check Print in Progress)'
         ELSE
            @ 21,35 SAY '(No Checks Printing Now)'
         ENDIF
         MACTION = 1
         @ 24,1 say 'Action: ' + str(maction,1)
         @ 24,13 say '1. Continue      2. Edit      3. Cancel'
         READ
         @ 24,9 get maction PICTURE '9' range 1,3
         READ
      ENDDO            
      IF MACTION = 1
         IF MINV_NBR <> 0
            DO RECLOCK
            REPLACE INV_NBR WITH MINV_NBR - 1
            UNLOCK
         ENDIF
         IF MLCK_NBR <> 0
            DO RECLOCK
            REPLACE LCK_NBR WITH MLCK_NBR
            UNLOCK
         ENDIF
         IF MWIRE_NBR <> 0
            DO RECLOCK
            REPLACE WIRE_NBR WITH MWIRE_NBR
            UNLOCK
         ENDIF
         IF MDC_NBR <> 0
            DO RECLOCK
            REPLACE WIRE_NBR WITH MWIRE_NBR
            UNLOCK
         ENDIF
         IF MEQUITY1 <> SPACE(8)
            DO RECLOCK
            REPLACE EQUITY1 WITH MEQUITY1 
            UNLOCK
         ENDIF
         
         IF MEQUITY2 <> SPACE(8)
            DO RECLOCK
            REPLACE EQUITY2 WITH MEQUITY2 
            UNLOCK
         ENDIF
         
         DO RECLOCK
         REPLACE CK_PRINT WITH MCK_PRINT
         USE
      ENDIF
      
   CASE MSELECTION = '8'
      @ 4,1 CLEAR TO 23,78
      SELECT A 
      DO FOX_USE WITH "&MMASTDBF.CONTROL", .F.
      STORE TRAN_MO TO MTRAN_MO
      STORE TRAN_YR TO MTRAN_YR  
      MYES_NO = 'YES'
      @ 10,5 SAY 'Change to the NEXT posting month (YES/NO)? ' GET MYES_NO PICTURE '@!'
      READ
      IF MYES_NO <> 'YES'
         @ 10,1 CLEAR TO 10,78
         MYES_NO = SPACE(3)
         @ 10,5 SAY 'Change to the PREVIOUS posting month (YES/NO)? ' GET MYES_NO PICTURE '@!'
         READ
         IF MYES_NO = 'YES'
            STORE VAL(TRAN_MO) TO MTRAN_MO
            STORE VAL(TRAN_YR) TO MTRAN_YR
            IF MTRAN_MO = 1
               MTRAN_MO = 12   
               MTRAN_YR = MTRAN_YR - 1
            ELSE 
               MTRAN_MO = MTRAN_MO - 1
            ENDIF
            STORE SUBSTR(STR(MTRAN_MO+100,3),2) TO MTRAN_MO   
            STORE STR(MTRAN_YR,4) TO MTRAN_YR   
            DO RECLOCK
            REPLACE TRAN_MO WITH MTRAN_MO  
            REPLACE TRAN_YR WITH MTRAN_YR 
            UNLOCK
         ENDIF
         LOOP
      ENDIF
      
      MG = .F.    
      MI = .F.
      MJ = .F.
      MK = .F.
      **** TEMPORARY ****
      SELECT B
      DO FOX_USE WITH "&MMASTDBF.DAILYJRN INDEX &MMASTDBF.JRN_MO", .F.
      SEEK MTRAN_YR + MTRAN_MO + ' '
      IF .NOT. EOF()
         MG = .T.
      ENDIF
      IF MPROG_CODE = 1
         MDOTHIS = .F.
         IF MDOTHIS
            ** I: YUMA, AZ
            DO FOX_USE WITH "I:DAILYJRN INDEX I:JRN_MO", .F.
            SEEK MTRAN_YR + MTRAN_MO + ' '
            IF .NOT. EOF()
               MI = .T.
            ENDIF
            ** J: PRODUCE 
            DO FOX_USE WITH "J:DAILYJRN INDEX J:JRN_MO", .F.
            SEEK MTRAN_YR + MTRAN_MO + ' '
            IF .NOT. EOF()
               MJ = .T.
            ENDIF
            ** K: FOOD SERVICE 
            *DO FOX_USE WITH "K:DAILYJRN INDEX K:JRN_MO", .F.
            *SEEK MTRAN_YR + MTRAN_MO + ' '
            *IF .NOT. EOF()
            *   MK = .T.
            *ENDIF
         ENDIF
      ENDIF
      IF MG .OR. MI .OR. MJ .OR. MK
         @ 5,10 SAY 'SOME ENTRIES FOR MONTH OF ' + MTRAN_MO + ' ARE NOT POSTED !! '
         STORE '   ' TO MYES_NO
         @ 7,10 SAY 'DO YOU WANT A LIST OF THESE ORDERS? ' GET MYES_NO PICTURE '@!'
         READ
         IF MYES_NO = 'YES'
            MPRT_ACT = 'C'
            DO PRT_SET
            IF MPRT_ACT <> 'C'
               LOOP  
            ENDIF
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
            
            IF MG
               DO FOX_USE WITH "&MMASTDBF.DAILYJRN INDEX &MMASTDBF.JRN_MO", .F.
               SEEK MTRAN_YR + MTRAN_MO + ' '
               MLINE = 99
               MPAGE_NO = 0
               DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. POST_FLG = ' '
                  IF MLINE > 58
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                     @ 2,27 SAY MCOMPANY
                     MPAGE_NO = MPAGE_NO + 1
                     @ 3,2 SAY 'PAGE ' + STR(MPAGE_NO,2)
                     @ 3,15 SAY 'ORDERS THAT STILL NEED POSTING FOR MONTH OF ' + MTRAN_MO
                     @ 3,70 SAY DTOC(DATE())
                     @ 5,2 SAY 'PO NUMBER          INVOICE NUMBER      SHIP DATE'
                     MLINE = 7
                  ENDIF
                  IF SALESMAN <> '  '
                     @ MLINE,2 SAY SALESMAN + '-'
                  ENDIF
                  @ MLINE,5 SAY PO_NBR   
                  IF PO_SUFFIX <> ' '
                     @ MLINE,09 SAY '-' + PO_SUFFIX
                  ENDIF
                  @ MLINE,27 SAY INV_NBR
                  @ MLINE,43 SAY SHIP_DATE
                  MLINE = MLINE + 1
                  SKIP
               ENDDO
               EJECT
            ENDIF
            
            IF MH
               DO FOX_USE WITH "H:DAILYJRN INDEX H:JRN_MO", .F.
               SEEK MTRAN_YR + MTRAN_MO + ' '
               MLINE = 99
               MPAGE_NO = 0
               DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. POST_FLG = ' '
                  IF MLINE > 58
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                     @ 2,27 SAY MCOMPANY
                     MPAGE_NO = MPAGE_NO + 1
                     @ 3,2 SAY 'PAGE ' + STR(MPAGE_NO,2)
                     @ 3,15 SAY 'ORDERS THAT STILL NEED POSTING FOR MONTH OF ' + MTRAN_MO
                     @ 3,70 SAY DTOC(DATE())
                     @ 5,2 SAY 'PO NUMBER          INVOICE NUMBER      SHIP DATE'
                     MLINE = 7
                  ENDIF
                  IF SALESMAN <> '  '
                     @ MLINE,2 SAY SALESMAN + '-'
                  ENDIF
                  @ MLINE,5 SAY PO_NBR   
                  IF PO_SUFFIX <> ' '
                     @ MLINE,09 SAY '-' + PO_SUFFIX
                  ENDIF
                  @ MLINE,27 SAY INV_NBR
                  @ MLINE,43 SAY SHIP_DATE
                  MLINE = MLINE + 1
                  SKIP
               ENDDO
               EJECT
            ENDIF
            
            IF MJ
               DO FOX_USE WITH "J:DAILYJRN INDEX J:JRN_MO", .F.
               SEEK MTRAN_YR + MTRAN_MO + ' '
               MLINE = 99
               MPAGE_NO = 0
               DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. POST_FLG = ' '
                  IF MLINE > 58
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                     @ 2,27 SAY MCOMPANY
                     MPAGE_NO = MPAGE_NO + 1
                     @ 3,2 SAY 'PAGE ' + STR(MPAGE_NO,2)
                     @ 3,15 SAY 'ORDERS THAT STILL NEED POSTING FOR MONTH OF ' + MTRAN_MO
                     @ 3,70 SAY DTOC(DATE())
                     @ 5,2 SAY 'PO NUMBER          INVOICE NUMBER      SHIP DATE'
                     MLINE = 7
                  ENDIF
                  IF SALESMAN <> '  '
                     @ MLINE,2 SAY SALESMAN + '-'
                  ENDIF
                  @ MLINE,5 SAY PO_NBR   
                  IF PO_SUFFIX <> ' '
                     @ MLINE,09 SAY '-' + PO_SUFFIX
                  ENDIF
                  @ MLINE,27 SAY INV_NBR
                  @ MLINE,43 SAY SHIP_DATE
                  MLINE = MLINE + 1
                  SKIP
               ENDDO
               EJECT
            ENDIF
            
            IF ML
               DO FOX_USE WITH "L:DAILYJRN INDEX L:JRN_MO", .F.
               SEEK MTRAN_YR + MTRAN_MO + ' '
               MLINE = 99
               MPAGE_NO = 0
               DO WHILE .NOT. EOF() .AND. TRAN_YR = MTRAN_YR .AND. TRAN_MO = MTRAN_MO .AND. POST_FLG = ' '
                  IF MLINE > 58
                     IF MLINE <> 99
                        EJECT
                     ENDIF
                     @ 2,27 SAY MCOMPANY
                     MPAGE_NO = MPAGE_NO + 1
                     @ 3,2 SAY 'PAGE ' + STR(MPAGE_NO,2)
                     @ 3,15 SAY 'ORDERS THAT STILL NEED POSTING FOR MONTH OF ' + MTRAN_MO
                     @ 3,70 SAY DTOC(DATE())
                     @ 5,2 SAY 'PO NUMBER          INVOICE NUMBER      SHIP DATE'
                     MLINE = 7
                  ENDIF
                  IF SALESMAN <> '  '
                     @ MLINE,2 SAY SALESMAN + '-'
                  ENDIF
                  @ MLINE,5 SAY PO_NBR   
                  IF PO_SUFFIX <> ' '
                     @ MLINE,09 SAY '-' + PO_SUFFIX
                  ENDIF
                  @ MLINE,27 SAY INV_NBR
                  @ MLINE,43 SAY SHIP_DATE
                  MLINE = MLINE + 1
                  SKIP
               ENDDO
               EJECT
            ENDIF
            
            SET DEVICE TO SCREEN
            SET PRINT OFF
            SET PRINT TO
            SET CONSOLE ON
            IF MPRINTER3 <> 'DONOTPRINT'
               RUN &MPRINTIT3
            ENDIF
            
            LOOP
         ENDIF
         LOOP
      ENDIF
      SELECT A
      STORE VAL(TRAN_MO) TO MNEW_MONTH
      MNEW_MONTH = MNEW_MONTH + 1
      IF MNEW_MONTH = 13
         MNEW_MONTH = 1  
         STORE VAL(TRAN_YR) TO MNEW_YEAR
         MNEW_YEAR = MNEW_YEAR + 1
         STORE STR(MNEW_YEAR,4) TO MNEW_YEAR
      ELSE
         STORE TRAN_YR TO MNEW_YEAR
      ENDIF
      STORE SUBSTR(STR(MNEW_MONTH+100,3),2) TO MNEW_MONTH
      STORE MNEW_MONTH TO MMO
      SET PROC TO PO_PROC 
      STORE ' ' TO MMONTH
      DO MONTHCO
      STORE '    ' TO MYES_NO 
      @ 10,5 SAY 'The next posting month will be ' + MMONTH     
      @ 12,5 SAY 'The next posting year  will be ' + mnew_year
      @ 15,5 SAY 'Are you SURE you want to change '
      @ 16,5 SAY 'posting to this new month/year (YES/NO) ? ' get myes_no picture '@!'
      READ
      IF MYES_NO = 'YES'
         DO RECLOCK
         REPLACE TRAN_MO WITH MNEW_MONTH
         REPLACE TRAN_YR WITH MNEW_YEAR
         UNLOCK
      ENDIF
      
   ENDCASE
   CLOSE DATA
   
ENDDO
CLOSE DATA

RETURN

* EOF: MAINT.PRG
*Formatted by: ToolBox Ver. 1.2  on 12/10/15 at 11:17 AM.
