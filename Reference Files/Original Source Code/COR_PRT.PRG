*************
* Program.: COR_PRT.PRG
* Author..: Grace Keller
* Date....: 10/26/87
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINT INVOICES SHEDULED FOR CORRECTION PRINT
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT A
SEEK 'C'
IF EOF()
   STORE 0 TO MRECNO
ELSE
   STORE RECNO() TO MRECNO
ENDIF
MFIRST_TM = .T.
DO WHILE .NOT. EOF() .AND. INV_FLG = 'C'
   SELECT A
   IF BBUYCODE = 'NONE'
      SKIP
      LOOP
   ENDIF
   STORE INV_SUFF TO MINV_SUFF
   MINV_SUFF = MINV_SUFF + 1
   DO RECLOCK
   REPLACE INV_SUFF WITH MINV_SUFF
   UNLOCK
   MFIRST_LN = .T.
   MHEAD_PRT = .T.
   MTOTAL  = 0
   STORE BUY_CODE TO MBUY_CODE
   STORE BBUYCODE TO MBBUYCODE
   SELECT E
   DO FOX_USE WITH "&MDBFLOC.BUYER INDEX &MDBFLOC.BUY_CODE", .F.
   SEEK MBUY_CODE
   IF .NOT. EOF()
      STORE NAME TO MSHP_NAME       
      STORE STREET TO MSHP_STRT  
      STORE CITY TO MSHP_CITY       
      STORE STATE TO MSHP_STATE
      IF ZIP4 = SPACE(4)
         STORE ZIP + SPACE(5) TO MSHP_ZIP
      ELSE
         STORE ZIP + '-' + ZIP4 TO MSHP_ZIP 
      ENDIF
   ELSE
      STORE 'SHIP TO NOT ON FILE'+ SPACE(13) TO MSHP_NAME
      STORE SPACE(28) TO MSHP_STRT           
      STORE SPACE(20) TO MSHP_CITY            
      STORE SPACE(2) TO MSHP_STATE             
      STORE SPACE(10) TO MSHP_ZIP          
   ENDIF
   
   DO FOX_USE WITH "&MDBFLOC.BIL_BUY INDEX &MDBFLOC.BBUYCODE", .F.
   SEEK MBBUYCODE
   IF .NOT. EOF()
      STORE NAME TO MBIL_NAME       
      STORE STREET TO MBIL_STRT  
      STORE CITY TO MBIL_CITY       
      STORE STATE TO MBIL_STATE
      IF ZIP4 = SPACE(4)
         STORE ZIP + SPACE(5) TO MBIL_ZIP
      ELSE
         STORE ZIP + '-' + ZIP4 TO MBIL_ZIP 
      ENDIF
   ELSE
      STORE 'BILL TO NOT ON FILE' + SPACE(13) TO MBIL_NAME
      STORE SPACE(28) TO MBIL_STRT
      STORE SPACE(20) TO MBIL_CITY
      STORE SPACE(2) TO MBIL_STATE
      STORE SPACE(10) TO MBIL_ZIP
   ENDIF
   
   SELECT A
   STORE SALESMAN TO MSALESMAN
   STORE FRT_CODE1 TO MFRT_CODE1
   STORE FRT_CODE2 TO MFRT_CODE2
   STORE PO_NBR TO MPO_NBR
   STORE PO_SUFFIX TO MPO_SUFFIX
   SELECT E
   DO FOX_USE WITH "&MMASTDBF.SALESMAN INDEX &MMASTDBF.SAL_CODE", .F.
   IF MSALESMAN <> SPACE(2)
      SEEK MSALESMAN
      IF .NOT. EOF()
         STORE NAME TO MSAL_NAME
      ELSE
         STORE 'BROKER NAME NOT FOUND'+ SPACE(3) TO MSAL_NAME
      ENDIF
   ELSE
      SELECT A
      STORE BROK_NAME + SPACE(18) TO MSAL_NAME
   ENDIF
   
   SELECT E
   DO FOX_USE WITH "&MDBFLOC.FREIGHT INDEX &MDBFLOC.FRT_CODE", .F.
   IF MFRT_CODE1 = 'CUST'
      STORE 'CUSTOMER PICK UP' TO MFRT_NAME
   ELSE 
      IF MFRT_CODE1 = 'NONE'
         IF MCOMPANY = 'DIVISION 15'
            STORE 'WILL CALL' TO MFRT_NAME
         ELSE
            STORE 'DELIVERED' TO MFRT_NAME
         ENDIF
      ELSE
         SEEK MFRT_CODE1                
         IF .NOT. EOF()
            STORE NAME TO MFRT_NAME
         ELSE
            STORE SPACE(10) TO MFRT_NAME
         ENDIF
      ENDIF
   ENDIF

   IF MFRT_CODE2 <> SPACE(4)
      SEEK MFRT_CODE2
      IF .NOT. EOF()
         STORE NAME TO MFRT_NAME2
      ENDIF
      STORE SUBSTR(MFRT_NAME,1,15) + '/' + SUBSTR(MFRT_NAME2,1,14) TO MFRT_NAME
   ENDIF

   IF MFRT_CODE3 <> SPACE(4)
      SEEK MFRT_CODE3
      IF .NOT. EOF()
         STORE NAME TO MFRT_NAME3
      ENDIF
      STORE SUBSTR(MFRT_NAME,1,9) + '/' + SUBSTR(MFRT_NAME2,1,9) + '/' + SUBSTR(MFRT_NAME3,1,9) + ' ' TO MFRT_NAME
   ENDIF
  

   MCK_BROK = .T.
   ******** WRITE INVOICE HEADER RECORD

   SELECT C
   DO FILELOCK
   APPEND BLANK
   REPLACE salesman   WITH A->salesman  
   REPLACE po_nbr     WITH A->po_nbr    
   REPLACE po_suffix  WITH A->po_suffix 
   REPLACE buy_code   WITH A->buy_code  
   REPLACE bbuycode   WITH A->bbuycode  
   REPLACE del_reqd   WITH A->del_reqd  
   REPLACE ord_date   WITH A->ord_date  
   REPLACE buyer_po   WITH A->buyer_po  
   REPLACE ship_date  WITH A->ship_date 
   REPLACE tot_lbs    WITH A->tot_lbs   
   REPLACE tot_purch  WITH A->tot_purch 
   REPLACE tot_sell   WITH A->tot_sell  
   REPLACE TOT_NET    WITH A->TOT_NET
   REPLACE frt_code1  WITH A->frt_code1 
   REPLACE frt_code2  WITH A->frt_code2 
   REPLACE frt_amt1   WITH A->frt_amt1  
   REPLACE frt_amt2   WITH A->frt_amt2  
   REPLACE FRT_CODE3  WITH A->FRT_CODE3
   REPLACE FRT_AMT3   WITH A->FRT_AMT3
   REPLACE frt1_adj1  WITH A->frt1_adj1
   REPLACE frt1_adj2  WITH A->frt1_adj2 
   REPLACE frt2_adj1  WITH A->frt2_adj1 
   REPLACE frt2_adj2  WITH A->frt2_adj2 
   REPLACE COM_CODE   WITH A->COM_CODE
   REPLACE comm_amt   WITH A->comm_amt  
   REPLACE COM_CODE2  WITH A->COM_CODE2
   REPLACE COMM_AMT2  WITH A->COMM_AMT2
   REPLACE COM_CODE3  WITH A->COM_CODE3
   REPLACE COMM_AMT3  WITH A->COMM_AMT3
   REPLACE sale_comm  WITH A->sale_comm
   REPLACE SAL_CODE2  WITH A->SAL_CODE2 
   REPLACE SAL_CODE3  WITH A->SAL_CODE3
   REPLACE sale2_amt  WITH A->sale2_amt
   REPLACE SALE3_AMT  WITH A->SALE3_AMT
   REPLACE inv_nbr    WITH STR(minv_nbr,5)
   REPLACE INV_SUFF   WITH MINV_SUFF
   REPLACE inv_date   WITH DATE()       
   REPLACE brok_name  WITH A->brok_name 
   REPLACE pu_loc     WITH A->pu_loc    
   REPLACE sup_amt1   WITH A->sup_amt1  
   REPLACE sup_amt2   WITH A->sup_amt2  
   REPLACE cus_amt1   WITH A->cus_amt1  
   REPLACE cus_amt2   WITH A->cus_amt2  
   REPLACE BROKERage  WITH A->BROKERage 
   UNLOCK
   
   SELECT B
   SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
   DO WHILE .NOT. EOF() .AND. MSALESMAN = SALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
      IF INV_FLG = 'P'
         SKIP
         LOOP
      ENDIF
      IF MHEAD_PRT
         MHEAD_PRT = .F.
         IF MFIRST_TM 
            MFIRST_TM = .F.
         ELSE
            EJECT
            *   CLEAR
         ENDIF
         SELECT A
*        MPRT_NBR = SUBSTR(STR(MINV_NBR+10000,5),2)+ '-' + STR(MINV_SUFF,1)
         IF MINV_NBR < 10000
            MPRT_NBR = SUBSTR(STR(MINV_NBR,5),2)    
         ELSE
            MPRT_NBR = STR(MINV_NBR,5)
         ENDIF
         ?? space(82) + 'INVOICE NUMBER'
         
         ? SPACE(85) 
         IF SALESMAN = SPACE(2)
            ?? SPACE(3) + MPRT_NBR
         ELSE
            ?? SALESMAN + '-' + MPRT_NBR
         ENDIF
         ?
         ?
         ?
         ? SPACE(10) + MBIL_NAME + SPACE(22) + SUBSTR(MSHP_NAME,1,31) 
         ? SPACE(10) + MBIL_STRT + SPACE(26) + MSHP_STRT
         STORE LEN(TRIM(MBIL_CITY)) TO MLEN
         MSPACE = 20 - MLEN 
         ? SPACE(10) + TRIM(MBIL_CITY) + ', ' + MBIL_STATE + '  ' + MBIL_ZIP + SPACE(MSPACE) + space(18) + TRIM(MSHP_CITY) + ', ' + MSHP_STATE + '  ' + MSHP_ZIP
         ?
         ?
         ? SPACE(5) + 'ATTN: Accounts Payable'
         ?
         ? space(4) + DTOC(SHIP_DATE) + space(5) + BUYER_PO + SPACE(3)
         IF SALESMAN = SPACE(2)
            ?? SPACE(3) + PO_NBR
         ELSE
            ?? SALESMAN + '-' + PO_NBR   
         ENDIF
         IF PO_SUFFIX <> ' '
            ?? '-' + PO_SUFFIX
         ELSE
            ?? '  '
         ENDIF
         ?? SPACE(4)
         ?? SUBSTR(MSAL_NAME,1,25) + SPACE(2) + substr(MFRT_NAME,1,22)
         ?
         ?
         ?
         ? SPACE(15) + 'REFER TO ORIGINAL INVOICE: ' + SUBSTR(STR(MINV_NBR+10000,5),2)
         ?
         MLINE = 20
      ENDIF
      MPRT_ONE = .T.
      SELECT A
      IF MCK_BROK
         MCK_BROK = .F.
         IF BROKERAGE = 'X'
            ? SPACE(15) + 'BROKERAGE FEE'
            ?
            MLINE = MLINE + 2
         ENDIF
      ENDIF
      SELECT B
      IF INV_FLG = 'C'
         SELECT D
         SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX
         MRECNO = 0
         DO WHILE SALESMAN = MSALESMAN .AND. PO_NBR = MPO_NBR .AND. PO_SUFFIX = MPO_SUFFIX
            STORE RECNO() TO MRECNO
            SKIP
         ENDDO
         IF MRECNO <> 0
            ****  FIND THE WAY IT WAS LAST TIME INVOICED
            STORE SPACE(6) TO FPART1
            STORE SPACE(8) TO FPART2, FPART3, FPART6
            STORE SPACE(20) TO FPART4
            STORE SPACE(13) TO FPART5
            SELECT C
            DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
            IF D->FRH_FRZ <> SPACE(2)
               SEEK 'F' + D->FRH_FRZ
               IF .NOT. EOF()
                  STORE SUBSTR(DESC,1,6) TO FPART1
               ENDIF
            ENDIF
            IF D->GRADE <> SPACE(1)
               SEEK 'G' + D->GRADE
               IF .NOT. EOF()
                  STORE SUBSTR(DESC,1,8) TO FPART3
               ENDIF
            ENDIF
            IF D->PACKAGED <> SPACE(1)
               SEEK 'D' + D->PACKAGED
               IF .NOT. EOF()
                  STORE SUBSTR(DESC,1,8) TO FPART3
               ENDIF
            ENDIF
            
            IF D->PROD_DESC <> 'BROKERAGE'
               SEEK 'R' + D->PROD_DESC
               IF .NOT. EOF()
                  STORE DESC TO FPART4 
               ENDIF
            ENDIF
            
            IF D->SIZE <> SPACE(5)
               SEEK 'Z' + D->SIZE
               IF .NOT. EOF()
                  STORE SUBSTR(DESC,1,13) TO FPART5
               ENDIF
            ENDIF
            IF D->PACKED <> SPACE(4)
               SEEK 'S' + D->PACKED
               IF .NOT. EOF()
                  STORE SUBSTR(DESC,1,8) TO FPART6
               ENDIF
            ENDIF
            SELECT B
            
            ? SPACE(5) + TRANSFORM(QTY, '@Z 9999') + SPACE(6)
            STORE LEN(TRIM(FPART1)) TO FLEN1
            IF FLEN1 > 0
               FLEN1 = FLEN1 + 1
            ENDIF
            STORE LEN(TRIM(FPART2)) TO FLEN2
            IF FLEN2 > 0
               FLEN2 = FLEN2 + 1
            ENDIF
            STORE LEN(TRIM(FPART3)) TO FLEN3
            IF FLEN3 > 0
               FLEN3 = FLEN3 + 1
            ENDIF
            STORE LEN(TRIM(FPART4)) TO FLEN4
            IF FLEN4 > 0
               FLEN4 = FLEN4 + 1
            ENDIF
            STORE LEN(TRIM(FPART5)) TO FLEN5
            IF FLEN5 > 0
               FLEN5 = FLEN5 + 1
            ENDIF
            STORE LEN(TRIM(FPART6)) TO FLEN6
            IF FLEN6 > 0
               FLEN6 = FLEN6 + 1
            ENDIF
            FTOT_LEN = FLEN1 + FLEN2 + FLEN3 + FLEN4 + FLEN5 + FLEN6
            *     MDIFF = 68 - MTOT_LEN
            MDIFF = 50 - FTOT_LEN
            FSUBSTR5 = 13
            FSUBSTR6 = 8
            IF FDIFF < 0
               IF FDIFF < -8
                  FPART6 = SPACE(8)
                  FDIFF = FDIFF + 8
                  FSUBSTR5 = FDIFF * -1
               ELSE
                  FSUBSTR6 = FDIFF * -1
               ENDIF
            ENDIF
            
            IF FLEN1 <> 0
               ?? TRIM(FPART1) + ' '
            ENDIF
            IF FLEN2 <> 0
               ?? TRIM(FPART2) + ' '
            ENDIF
            IF FLEN3 <> 0
               ?? TRIM(FPART3) + ' '
            ENDIF
            IF FLEN4 <> 0
               ?? TRIM(FPART4) + ' '
            ENDIF
            IF FLEN5 <> 0
               ?? TRIM(SUBSTR(FPART5,1,FSUBSTR5)) + ' '
            ENDIF
            ?? TRIM(SUBSTR(FPART6,1,FSUBSTR6))
            FDIFF = 50 - FTOT_LEN
            ?? SPACE(FDIFF) + SPACE(1)
            ?? TRANSFORM(LBS, '@Z 99,999.99')
            ?? SPACE(2) + TRANSFORM(SEL_PRICE, '@Z 99.9999')
            MSELL = ROUND(LBS * (SEL_PRICE * -1),2)
            ?? SPACE(2) + '-' + TRANSFORM(MSELL, '@Z 999999.99')
            ?
            MTOTAL = MTOTAL + MSELL
            MLINE = MLINE + 2
            **** WRITE FROM BACK AS PART OF INVOICE
            SELECT D
            DO FILELOCK
            APPEND BLANK
            REPLACE salesman   WITH D->salesman  
            REPLACE po_nbr     WITH D->po_nbr    
            REPLACE po_suffix  WITH D->po_suffix 
            REPLACE item_nbr   WITH D->item_nbr  
            REPLACE inv_nbr    WITH STR(minv_nbr,5)   
            REPLACE INV_SUFF   WITH MINV_SUFF
            REPLACE inv_date   WITH DATE()       
            REPLACE qty        WITH D->qty       
            REPLACE frh_frz    WITH D->frh_frz   
            REPLACE grade      WITH D->grade     
            REPLACE packaged   WITH D->packaged  
            REPLACE product    WITH D->product   
            REPLACE prod_desc  WITH D->prod_desc 
            REPLACE size       WITH D->size      
            REPLACE packed     WITH D->packed    
            REPLACE lbs        WITH D->lbs       
            REPLACE pur_price  WITH B->pur_price 
            REPLACE sel_price  WITH B->sel_price * -1
            REPLACE tot_purch  WITH B->tot_purch 
            REPLACE tot_sell   WITH B->tot_sell * -1
            UNLOCK
            
         ENDIF
      ENDIF
      STORE SPACE(6) TO MPART1
      STORE SPACE(8) TO MPART2, MPART3, MPART6
      STORE SPACE(20) TO MPART4
      STORE SPACE(13) TO MPART5
      SELECT C
      DO FOX_USE WITH "&MDBFLOC.PRODUCTS INDEX &MDBFLOC.PRODUCTS", .F.
      IF B->FRH_FRZ <> SPACE(2)
         SEEK 'F' + B->FRH_FRZ
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,6) TO MPART1
         ENDIF
      ENDIF
      IF B->GRADE <> SPACE(1)
         SEEK 'G' + B->GRADE
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,8) TO MPART3
         ENDIF
      ENDIF
      IF B->PACKAGED <> SPACE(1)
         SEEK 'D' + B->PACKAGED
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,8) TO MPART3
         ENDIF
      ENDIF
      
      IF B->PROD_DESC <> 'BROKERAGE'
         SEEK 'R' + B->PROD_DESC
         IF .NOT. EOF()
            STORE DESC TO MPART4 
         ENDIF
      ENDIF
      
      IF B->SIZE <> SPACE(5)
         SEEK 'Z' + B->SIZE
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,13) TO MPART5
         ENDIF
      ENDIF
      IF B->PACKED <> SPACE(4)
         SEEK 'S' + B->PACKED
         IF .NOT. EOF()
            STORE SUBSTR(DESC,1,8) TO MPART6
         ENDIF
      ENDIF
      SELECT B
      
      ? SPACE(5) + TRANSFORM(QTY, '@Z 9999') + SPACE(6)
      STORE LEN(TRIM(MPART1)) TO MLEN1
      IF MLEN1 > 0
         MLEN1 = MLEN1 + 1
      ENDIF
      STORE LEN(TRIM(MPART2)) TO MLEN2
      IF MLEN2 > 0
         MLEN2 = MLEN2 + 1
      ENDIF
      STORE LEN(TRIM(MPART3)) TO MLEN3
      IF MLEN3 > 0
         MLEN3 = MLEN3 + 1
      ENDIF
      STORE LEN(TRIM(MPART4)) TO MLEN4
      IF MLEN4 > 0
         MLEN4 = MLEN4 + 1
      ENDIF
      STORE LEN(TRIM(MPART5)) TO MLEN5
      IF MLEN5 > 0
         MLEN5 = MLEN5 + 1
      ENDIF
      STORE LEN(TRIM(MPART6)) TO MLEN6
      IF MLEN6 > 0
         MLEN6 = MLEN6 + 1
      ENDIF
      MTOT_LEN = MLEN1 + MLEN2 + MLEN3 + MLEN4 + MLEN5 + MLEN6
      *     MDIFF = 68 - MTOT_LEN
      MDIFF = 50 - MTOT_LEN
      MSUBSTR5 = 13
      MSUBSTR6 = 8
      IF MDIFF < 0
         IF MDIFF < -8
            MPART6 = SPACE(8)
            MDIFF = MDIFF + 8
            MSUBSTR5 = MDIFF * -1
         ELSE
            MSUBSTR6 = MDIFF * -1
         ENDIF
      ENDIF
      
      SELECT B
      
      IF MLEN1 <> 0
         ?? TRIM(MPART1) + ' '
      ENDIF
      IF MLEN2 <> 0
         ?? TRIM(MPART2) + ' '
      ENDIF
      IF MLEN3 <> 0
         ?? TRIM(MPART3) + ' '
      ENDIF
      IF MLEN4 <> 0
         ?? TRIM(MPART4) + ' '
      ENDIF
      IF MLEN5 <> 0
         ?? TRIM(SUBSTR(MPART5,1,MSUBSTR5)) + ' '
      ENDIF
      ?? TRIM(SUBSTR(MPART6,1,MSUBSTR6))
      MDIFF = 50 - MTOT_LEN
      ?? SPACE(MDIFF) + SPACE(1)
      ?? TRANSFORM(LBS, '@Z 99,999.99')
      ?? SPACE(2) + TRANSFORM(SEL_PRICE, '@Z 99.9999')
      MSELL = ROUND(LBS * SEL_PRICE,2)
      ?? SPACE(3) + TRANSFORM(MSELL, '@Z 999999.99')
      ?
      
      SELECT D
      DO FILELOCK
      APPEND BLANK
      REPLACE salesman   WITH B->salesman  
      REPLACE po_nbr     WITH B->po_nbr    
      REPLACE po_suffix  WITH B->po_suffix 
      REPLACE item_nbr   WITH B->item_nbr  
      REPLACE inv_nbr    WITH STR(minv_nbr,5)   
      REPLACE INV_SUFF   WITH MINV_SUFF
      REPLACE inv_date   WITH DATE()       
      REPLACE qty        WITH B->qty       
      REPLACE frh_frz    WITH B->frh_frz   
      REPLACE grade      WITH B->grade     
      REPLACE packaged   WITH B->packaged  
      REPLACE product    WITH B->product   
      REPLACE prod_desc  WITH B->prod_desc 
      REPLACE size       WITH B->size      
      REPLACE packed     WITH B->packed    
      REPLACE lbs        WITH B->lbs       
      REPLACE pur_price  WITH B->pur_price 
      REPLACE sel_price  WITH B->sel_price 
      REPLACE tot_purch  WITH B->tot_purch 
      REPLACE tot_sell   WITH B->tot_sell  
      UNLOCK
      MTOTAL = MTOTAL + MSELL
      MLINE = MLINE + 2
      IF MLINE > 50
         MHEAD_PRT = .T.
      ENDIF
      SELECT B
      DO RECLOCK
      REPLACE INV_FLG WITH 'P'
      REPLACE INV_NBR WITH STR(MINV_NBR,5) 
      REPLACE INV_SUFF WITH MINV_SUFF
      UNLOCK
      SKIP
   ENDDO
   SELECT A
   
   DO WHILE MLINE <= 52
      ?
      MLINE = MLINE + 1
   ENDDO
   ?? SPACE(87) + TRANSFORM(MTOTAL, '@Z 99,999.99')
   **** SAVE THIS INFORMATION BACK
   SELECT A
   DO RECLOCK
   REPLACE INV_DATE WITH DATE()
   REPLACE INV_NBR WITH STR(MINV_NBR,5) 
   REPLACE INV_SUFF WITH MINV_SUFF
   UNLOCK
   SKIP
ENDDO
IF MPRT_ONE
   EJECT
ENDIF
SET PRINT OFF
SET CONSOLE ON

IF MPRT_ONE
   DO FOX_USE WITH "PO_HEAD", .F.
   DO FILELOCK
   REPLACE INV_FLG WITH 'P' FOR INV_FLG = 'C'
   INDEX ON INV_FLG TO PRINT
   UNLOCK
ENDIF

RETURN
* EOF: COR_PRT.PRG
*Formatted by: dANALYST Ver. 7.3a on December 10, 1987 at 5:04 PM.
