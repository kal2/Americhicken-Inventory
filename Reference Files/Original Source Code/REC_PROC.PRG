***************
* Program.: REC_PROC.PRG
* Author..: Grace Keller
* Date....: 01/21/88
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO PLUS
* Notes...: PROCEDURE file for SUPPLIER INVOICES


PROCEDURE REC_SF
@ 04,1  SAY 'Supplier:'
@ 04,11 say mname
@ 04,53 SAY 'Tot Bill Amt   Tot To Pay'
@ 05,11 say trim(mcity) + ', ' + mstate + '  ' + mzip
@ 06,1 to 06,78 
@ 06,1 say "OUTSTANDING PO'S"            
@ 07,1  SAY '    P.O. Nbr.     Amt Due   Sel Invoice Nbr. Inv Date   Amt Billed  Due Date'
*                xx-xxxx-x   999,999.99   x  123456789012 xx/xx/xx  999,999.99  xx/xx/xxxx 
*            123456789012345678901234567890123456789012345678901234567890123456789012345678
*                     10        20        30        40        50        60        70
RETURN

PROCEDURE REC_SR 
@ MLINE,1 SAY STR(I,2) + '.'
IF SALESMAN <> '  '
   @ mline,5  say salesman + '-'
ENDIF                        
@ MLINE,8 SAY PO_NBR
IF PO_SUFFIX <> ' '
   @ MLINE,12 SAY '-' + PO_SUFFIX
ENDIF
@ MLINE,17 SAY MPURCH(I) PICTURE '999,999.99'
RETURN

PROCEDURE REC_GF 
@ MLINE,30 GET MSELECT(I) PICTURE '@!'
@ MLINE,33 GET MSUP_INV(I) PICTURE '@!'
@ MLINE,46 GET MI_DATE(I)
@ MLINE,57 GET MAMT_BILL(I) PICTURE '###,###.##'
RETURN
 

PROCEDURE APRV_SF 
@ 04,1 SAY MNAME
@ 05,1 SAY TRIM(MCITY) + ', ' + MSTATE
@ 5,40 SAY 'AMT APPROVED:'
@ 06,1 TO 06,78
@ 07,1  SAY '   Select   Amt Billed      Amt Due   Invoice Nbr.    Due Date    P.O. Nbr.'
*                  x     999,999.99   999,999.99   123456789012    xx/xx/xx    xx-xxxx-x    
*            123456789012345678901234567890123456789012345678901234567890123456789012345678   
*                     10        20        30        40        50        60        70
RETURN

PROCEDURE APRV_SR 
@ MLINE,1 SAY STR(I,2) + '.'
@ MLINE,13 SAY AMT_DUE PICTURE '999,999.99'
@ MLINE,26 SAY MDUE(I) PICTURE '999,999.99'
@ MLINE,39 SAY MINV_NBR
@ MLINE,55 SAY MDUE_DATE
IF SALESMAN <> '  '
   @ mline,67  say salesman + '-'
ENDIF                        
@ MLINE,70 SAY PO_NBR
IF PO_SUFFIX <> ' '
   @ MLINE,74 SAY '-' + PO_SUFFIX
ENDIF
RETURN

PROCEDURE APRV_SF1
@ 2,55 SAY 'AMT APPROVED:'
@ 04,1  SAY '   Sel Supplier     Amt Billed     Amt Due  Invoice Nbr.  Due Date  P.O. Nbr.'
*                x  xxxxxxxxxxx  999,999.99  999,999.99  123456789012  xx/xx/xx  xx-xxxx-x    
*            123456789012345678901234567890123456789012345678901234567890123456789012345678   
*                     10        20        30        40        50        60        70
RETURN

PROCEDURE APRV_SR1  
@ MLINE,1 SAY STR(I,2) + '.'
@ MLINE,8 SAY SUBSTR(MNAME,1,11)
@ MLINE,21 SAY AMT_DUE PICTURE '999,999.99'
@ MLINE,33 SAY MDUE(I) PICTURE '999,999.99'
@ MLINE,45 SAY MINV_NBR
@ MLINE,58 SAY MDUE_DATE
IF SALESMAN <> '  '
   @ mline,69  say salesman + '-'
ENDIF                        
@ MLINE,72 SAY PO_NBR
IF PO_SUFFIX <> ' '
   @ MLINE,76 SAY '-' + PO_SUFFIX
ENDIF
RETURN

PROCEDURE FRT_SF
@ 04,1  SAY ' Freight:'
@ 04,11 say mname
@ 05,11 say trim(mcity) + ', ' + mstate + '  ' + mzip
@ 04,53 SAY 'Tot Bill Amt   Tot To Pay'
@ 06,1 to 06,78
@ 06,1 say "OUTSTANDING PO'S"            
@ 07,1  SAY 'P.O. Nbr.  Amt Due   Shipped  Sel Invoice Nbr. Inv Date  Amt Billed Due Date'
RETURN

PROCEDURE FRT_SF1
@ 04,1  SAY ' Freight:'
@ 04,11 say mname
@ 05,11 say trim(mcity) + ', ' + mstate + '  ' + mzip
@ 04,53 SAY 'Tot Bill Amt   Tot To Pay'
@ 06,1 to 06,78 
@ 06,1 say "OUTSTANDING PO'S"            
@ 07,1  SAY 'P.O. Nbr.  Bill Amt Ship Dt   Amt to Pay Sel Invoice Nbr Inv Date   Due Date'
RETURN


PROCEDURE FRT_SR 
*@ MLINE,1 SAY STR(I,2) + '.'
IF SALESMAN <> '  '
   @ mline,1  say salesman + '-'
ENDIF                        
@ MLINE,4 SAY PO_NBR
IF PO_SUFFIX <> ' '
   @ MLINE,08 SAY '-' + PO_SUFFIX
ENDIF
@ MLINE,11 SAY MFREIGHT(I) PICTURE '99,999.99'
@ mline,21 SAY SHIP_DATE
RETURN

PROCEDURE FRT_GF 
@ MLINE,32 GET MSELECT(I) PICTURE '@!'
@ MLINE,35 GET MFRT_INV(I) PICTURE '@!'
@ MLINE,48 GET MI_DATE(I)
@ MLINE,59 GET MAMT_BILL(I) PICTURE '##,###.##'
RETURN
 
PROCEDURE FRT_SR1
IF SALESMAN <> '  '
   @ mline,1  say salesman + '-'
ENDIF                        
@ MLINE,4 SAY PO_NBR
IF PO_SUFFIX <> ' '
   @ MLINE,08 SAY '-' + PO_SUFFIX
ENDIF
@ MLINE,11 SAY MFREIGHT(I) PICTURE '99,999.99'
@ MLINE,21 SAY SHIP_DATE
@ MLINE, 32 SAY MAMT_BILL(I) PICTURE '99,999.99'
RETURN

PROCEDURE FRT_GF1
@ MLINE,43 GET MSELECT(I) PICTURE '@!'
@ MLINE,45 GET MFRT_INV(I) PICTURE '@!'
@ MLINE,58 GET MI_DATE(I)
RETURN

PROCEDURE APRVFSF 
@ 04,1 SAY MNAME
@ 05,1 SAY TRIM(MCITY) + ', ' + MSTATE
@ 5,40 SAY 'AMT APPROVED:'
@ 06,1 TO 06,78
@ 07,1  SAY '   Select   Amt Billed      Amt Due   Invoice Nbr.    Due Date    P.O. Nbr.'
*                  x     999,999.99   999,999.99   123456789012    xx/xx/xx    xx-xxxx-x    
*            123456789012345678901234567890123456789012345678901234567890123456789012345678   
*                     10        20        30        40        50        60        70
RETURN

PROCEDURE APRVFSR 
@ MLINE,1 SAY STR(I,2) + '.'
@ MLINE,13 SAY AMT_DUE PICTURE '999,999.99'
@ MLINE,26 SAY MDUE(I) PICTURE '999,999.99'
@ MLINE,39 SAY MINV_NBR
@ MLINE,55 SAY MDUE_DATE
IF SALESMAN <> '  '
   @ mline,67  say salesman + '-'
ENDIF                        
@ MLINE,70 SAY PO_NBR
IF PO_SUFFIX <> ' '
   @ MLINE,74 SAY '-' + PO_SUFFIX
ENDIF
RETURN

PROCEDURE APRVFSF1
@ 2,55 SAY 'AMT APPROVED:'
@ 04,1  SAY '   Sel Supplier     Amt Billed     Amt Due  Invoice Nbr.  Due Date  P.O. Nbr.'
*                x  xxxxxxxxxxx  999,999.99  999,999.99  123456789012  xx/xx/xx  xx-xxxx-x    
*            123456789012345678901234567890123456789012345678901234567890123456789012345678   
*                     10        20        30        40        50        60        70
RETURN

PROCEDURE APRVFSR1  
@ MLINE,1 SAY STR(I,2) + '.'
@ MLINE,8 SAY SUBSTR(MNAME,1,11)
@ MLINE,21 SAY AMT_DUE PICTURE '999,999.99'
@ MLINE,33 SAY MDUE(I) PICTURE '999,999.99'
@ MLINE,45 SAY MINV_NBR
@ MLINE,58 SAY MDUE_DATE
IF SALESMAN <> '  '
   @ mline,69  say salesman + '-'
ENDIF                        
@ MLINE,72 SAY PO_NBR
IF PO_SUFFIX <> ' '
   @ MLINE,76 SAY '-' + PO_SUFFIX
ENDIF
RETURN

*Formatted by: dANALYST Ver. 6.0C on February 4, 1987.
