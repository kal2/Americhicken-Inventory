****************
* Program.: PRODRPTS.PRG
* Author..: GRACE KELLER
* Date....: 01/08/88
* Notice..: Copyright (C) 1988, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRODUCT REPORT MENU    
*
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion      
CLOSE DATA

STORE '  ' TO MSELECTION

DO WHILE VAL(MSELECTION) <> 99
   CLOSE DATA
   CLEAR
   @ 01,00 SAY MCOMPANY
   @ 02,00 SAY MPROGRAM + ' - SPECIAL REPORTS MENU'
   @ 02,70 SAY DATE()
   @ 3,0 to 25,79
   
   @ 04,10 SAY ' 1 - QTY & LBS QUARTERLY ACCRUAL REPORTS            (SPEC 1)'         
   @ 05,10 SAY ' 2 - QUARTERLY ACCRUAL REPORTS                      (SPEC 3)'

   @ 07,10 SAY ' 3 - PRODUCT - BY WEEK                              (SPEC 2)'
   @ 08,10 say ' 4 - PRODUCT - PO DETAILS - BY SUPPLIER             (SPEC 4)'
   @ 09,10 SAY ' 5 - PRODUCT - CUSTOMERS/SUPPLIERS BUYING/SELLING   (SPEC18)'

   @ 11,10 SAY ' 6 - PRODUCT COST - BY PRODUCT                      (SPEC 8)'
   @ 12,10 SAY ' 7 - PRODUCT COST - BY PO                           (SPEC 9)'
   @ 13,10 SAY ' 8 - PRODUCT COST - CUSTOMER AVERAGES               (SPEC14)'
   @ 14,10 SAY ' 9 - PRODUCT TOTS - CUSTOMERS for BROKER            (SPEC14A)'

   @ 16,10 SAY '10 - BILLBACK LEDGER                                (SPEC17)'
   @ 17,10 say '12 - THIRD PARTY BROKER COMMISSIONS                 (SPEC 6)'

   @ 19,10 SAY '12 - FREIGHT                                        (SPEC10)'
   @ 20,10 SAY '13 - STATE REPORT / SHIP TO CUSTS / PRODUCTS        (SPEC19)'

   @ 22,10 SAY '99 - RETURN TO REPORTS MENU'
   
   STORE '  ' TO MSELECTION

   @ 23,02 SAY 'CHOICE: '
   @ 23,10 GET MSELECTION PICTURE '##'
   READ
   
   DO CASE
      
   CASE VAL(MSELECTION) = 1     
      DO MPECIAL1
   CASE VAL(MSELECTION) = 2 
      DO MPECIAL3
   CASE VAL(MSELECTION) = 3 
      DO MPECIAL2
   CASE VAL(MSELECTION) = 4 
      DO MPECIAL4
   CASE VAL(MSELECTION) = 5 
      DO MPEC18   
   CASE VAL(MSELECTION) = 6 
      DO MPECIAL8
   CASE VAL(MSELECTION) = 7 
      DO MPECIAL9
   CASE VAL(MSELECTION) = 8
      DO MPEC14   
   CASE VAL(MSELECTION) = 9 
      DO MPEC14A
   CASE VAL(MSELECTION) = 10
      DO MPEC17  
   CASE VAL(MSELECTION) = 11
      DO MPECIAL6 
   CASE VAL(MSELECTION) = 12
      DO MPEC10   
   CASE VAL(MSELECTION) = 13
      DO MPEC19   
   ENDCASE
   
ENDDO

RETURN


* EOF: SPECRPTS.PRG
*Formatted by: ToolBox Ver. 1.2  on 7/23/14 at 1:27 PM.
