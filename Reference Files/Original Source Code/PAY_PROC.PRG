***************
* Program.: PAY_PROC.PRG
* Author..: Grace Keller
* Date....: 01/05/88
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO PLUS
* Notes...: PROCEDURE file for PAYMENTS     


PROCEDURE PAY_SF
@ 04,1  SAY 'Customer:'
@ 04,11 say mname
@ 05,11 say trim(mcity) + ', ' + mstate + '  ' + mzip
IF MPROG_CODE = 1
   @ 06,1  say 'Check Nbr       Check Amt       Payment Date   Dep Location'
ELSE
   @ 06,1  say 'Check Nbr       Check Amt       Payment Date'
ENDIF
@ 09,1 to 09,78 
@ 09,1 say 'OUTSTANDING INVOICES/CREDITS'
IF MPROG_CODE = 1
   @ 10,1  SAY '    Inv Nbr  PO Number Inv Date     Amt Due  Pay Sel    Amt Paid'
ELSE
   @ 10,1  SAY '       PO #   Inv Date     Amt Due  Pay Sel   Amt Paid    Reason'      
ENDIF
RETURN

PROCEDURE PAY_GF1
*@ 04,48 SAY 'Current Balance: '   
*@ 04,66 say mbalance picture '9,999,999.99'
@ 7,2 get mck_nbr 
@ 7,17 get mck_amt picture '999999.99'
@ 7,35 get mpaid_date
IF MPROG_CODE = 1
   **@ 7,54 get mloc_code picture '@!'
   @ 7,50 get mlocation  picture '@!'
  
ENDIF
RETURN

PROCEDURE PAY_SR 
@ MLINE,1 SAY STR(MI,2) + '.'
MDUE(MI) = (mamt(mi) + mshrt(mi)) - MAMT_PAID
IF MPROG_CODE = 1
   IF MDEB_CRD = 'Y' .AND. SUBSTR(MINV_NBR,1,1) <> 'A'
      @ MLINE,5 SAY 'A'
   ENDIF
   @ mline,6  say minv_nbr
   @ mline,14 say msalesman
   IF MSALESMAN <> '  '
      @ MLINE,16 SAY '-'
   ENDIF
   @ MLINE,17 SAY MPO_NBR
   IF MPO_SUFFIX <> ' '
      @ MLINE,21 SAY '-' + MPO_SUFFIX
   ENDIF
   @ mline,24 say minv_date
   @ mline,35 SAY MDUE(MI) picture '999,999.99'
ELSE
   IF MSALESMAN <> '  '  
      @ MLINE,5  SAY MSALESMAN
      @ MLINE,7  SAY '-'
   ENDIF
   @ MLINE,8  SAY MPO_NBR
   IF MPO_SUFFIX <> ' '
      @ MLINE,12 SAY '-'
      @ MLINE,13 SAY MPO_SUFFIX
   ENDIF
   @ mline,14 say minv_date     
   @ mline,25 SAY MDUE(MI) picture '999,999.99'
ENDIF
*@ mline,24 say mamt(mi) picture '999,999.99'
*@ mline,37 say (mshrt(mi) * -1)picture '99,999.99'
*@ mline,48 SAY MDUE(MI) picture '999,999.99'
RETURN

PROCEDURE PAY_GF2
*@ MLINE,63 GET MCK(MI) PICTURE '@!'
*@ MLINE,69 GET MPD_AMT(MI) PICTURE '999,999.99'
IF MPROG_CODE = 1
   @ MLINE,48 GET MCK(MI) PICTURE '@!'
   @ MLINE,56 GET MPD_AMT(MI) PICTURE '999,999.99'
ELSE
   @ MLINE,39 GET MCK(MI) PICTURE '@!'
   @ MLINE,45 GET MPD_AMT(MI) PICTURE '999,999.99'
   @ MLINE,62 GET MCRED_REAS(MI) PICTURE '@!'
ENDIF
RETURN


PROCEDURE PAYCRDSF
@ 04,1  SAY 'Customer:'
@ 04,11 say mname
@ 05,11 say trim(mcity) + ', ' + mstate + '  ' + mzip
*@ 07,1 say 'OUTSTANDING CREDITS'
@ 07,1  SAY '    Inv Nbr  Inv Date     Crd Amt     Pay Sel'  
RETURN

PROCEDURE PAYCRDSR
@ MLINE,1 SAY STR(MI,2) + '.'
IF MDEB_CRD = 'Y' .AND. SUBSTR(MINV_NBR,1,1) <> 'A'
   @ MLINE,5 SAY 'A'
ENDIF
@ mline,6  say minv_nbr
@ mline,13 say minv_date     
@ mline,24 say mamt(mi) picture '999,999.99'
RETURN

PROCEDURE PAYCRDGF
@ MLINE,42 GET MCK(MI) PICTURE '@!'
RETURN


