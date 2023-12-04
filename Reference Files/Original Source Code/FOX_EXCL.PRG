*  FILE NAME: NET_EXCL.PRG
*  BY: Rich Comeau
*  DATE: April 19, 1987
*  DESC: Use data EXCLUSIVE under PACK REINDEX ZAP for the 4 enviroments.
*  CALLED BY:
*  DATA FILES:
PARAMETERS ACTION
STORE 1 TO dLOOP
STORE "" TO dA_
STORE DBF() TO dFILE
DO WHILE LEN(NDX(dLOOP)) > 0
   STORE dLOOP + 1 TO dLOOP
   STORE LTRIM(STR(dLOOP - 1)) TO dS
   STORE NDX(dLOOP - 1) TO dA_&dS
ENDDO

IF dLOOP > 1
   STORE dLOOP -1 TO dLOOP
   DO CASE
   CASE dLOOP = 1
      USE &dFILE INDEX &dA_1 EXCLUSIVE
   CASE dLOOP = 2
      USE &dFILE INDEX &dA_1, &dA_2 EXCLUSIVE
   CASE dLOOP = 3
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3 EXCLUSIVE
   CASE dLOOP = 4
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3, &dA_4  EXCLUSIVE
   CASE dLOOP = 5
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3, &dA_4, &dA_5  EXCLUSIVE
   CASE dLOOP = 6
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3, &dA_4, &dA_5, &dA_6  EXCLUSIVE
   CASE dLOOP = 7
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3, &dA_4, &dA_5, &dA_6, &dA_7  EXCLUSIVE
   CASE dLOOP = 8
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3, &dA_4, &dA_5, &dA_6, &dA_7, &dA_8  EXCLUSIVE
   CASE dLOOP = 9
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3, &dA_4, &dA_5, &dA_6, &dA_7, &dA_8, &dA_9  EXCLUSIVE
   ENDCASE
   STORE dLOOP +1 TO dLOOP
ELSE
   USE &dFILE
ENDIF
DO CASE
CASE ACTION = 'P'
   PACK
CASE ACTION = 'R'
   REINDEX
CASE ACTION = 'Z'
   ZAP
ENDCASE



*********  QUICKSILVER USERS WILL NEED TO HAVE SHARED COMMAND TACKED ON TO 
*********  THE END OF THE FOLLOWING USE LINES

IF dLOOP > 1
   STORE dLOOP -1 TO dLOOP
   DO CASE
   CASE dLOOP = 1
      USE &dFILE INDEX &dA_1 
   CASE dLOOP = 2
      USE &dFILE INDEX &dA_1, &dA_2 
   CASE dLOOP = 3
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3 
   CASE dLOOP = 4
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3, &dA_4 
   CASE dLOOP = 5
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3, &dA_4, &dA_5 
   CASE dLOOP = 6
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3, &dA_4, &dA_5, &dA_6 
   CASE dLOOP = 7
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3, &dA_4, &dA_5, &dA_6, &dA_7 
   CASE dLOOP = 8
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3, &dA_4, &dA_5, &dA_6, &dA_7, &dA_8 
   CASE dLOOP = 9
      USE &dFILE INDEX &dA_1, &dA_2, &dA_3, &dA_4, &dA_5, &dA_6, &dA_7, &dA_8, &dA_9 
   ENDCASE
ELSE
   USE &dFILE
ENDIF
*Formatted by: dANALYST Ver. 6.9  on April 19, 1987.
