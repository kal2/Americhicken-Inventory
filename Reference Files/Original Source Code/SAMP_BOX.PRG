************  
* Program.: SAMPLE BOX.PRG
* Author..: Grace Keller
* Date....: 01/21/97
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: PRINT SAMPLE BOX HEADER               
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     

*** FONT ARIAL BOLD
?? CHR(27) + '(s1p10v0s3b16602T'

*** POINT HEIGHT 20 - DEFAULT IS 12
?? CHR(27) + '(s20V'

@  1,16 say ' ออออออออออออออออออออออออออออ '
@  2,16 say 'ณ' + SPACE(69) + 'ณ'
@  3,16 say 'ณ' + SPACE(69) + 'ณ'
@  3,35 SAY  '     SAMPLE      '
@  4,16 say 'ณ' + SPACE(69) + 'ณ'
@  5,16 say ' ออออออออออออออออออออออออออออ '
@  6,16 SAY ' '

** GOTHIC 12 BOLD
?? CHR(27) + '(s0p12h0s3b4102T'

RETURN

* EOF: SAMP_BOX.PRG
*Formatted by: ToolBox Ver. 1.2  on 1/7/16 at 2:34 PM.
