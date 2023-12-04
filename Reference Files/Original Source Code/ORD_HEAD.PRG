************  
* Program.: ORD_HEAD.PRG
* Author..: Grace Keller
* Date....: 01/21/97
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINT ORDER HEADER                
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

?? SPACE(3) + 'PRINT DATE'

** THIS IS THE PRINT ROUTINE
*** FONT ARIAL BOLD
?? CHR(27) + '(s1p10v0s3b16602T'

*** POINT HEIGHT 20 - DEFAULT IS 12
?? CHR(27) + '(s20V'

??  SPACE(20) + 'AMERICHICKEN, INC' + SPACE(15)

IF MSALESMAN <> SPACE(2)
   ?? MSALESMAN + '-'
ELSE
   ?? SPACE(3)
ENDIF
?? MPO_NBR
IF MPO_SUFFIX <> ' '
   ?? '-' + MPO_SUFFIX
ENDIF

** GOTHIC 12 BOLD
?? CHR(27) + '(s0p12h0s3b4102T'

?
? SPACE(3)   
?? SPACE(1) + DTOC(DATE()) + SPACE(15)

** THIS IS THE PRINT ROUTINE
*** FONT ARIAL BOLD
?? CHR(27) + '(s1p10v0s3b16602T'

*** POINT HEIGHT 20 - DEFAULT IS 12
?? CHR(27) + '(s20V'

?? '          '

?? SPACE(4) + 'PAGE: '
MPAGE_NBR = MPAGE_NBR + 1

?? STR(MPAGE_NBR,1)

** GOTHIC 12 BOLD
?? CHR(27) + '(s0p12h0s3b4102T'
?
?
MLINE = 7
RETURN

* EOF: ORD_HEAD.PRG
*Formatted by: ToolBox Ver. 1.2  on 1/7/16 at 10:29 AM.
