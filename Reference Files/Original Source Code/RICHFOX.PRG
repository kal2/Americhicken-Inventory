PARAMETERS FILE, EX_USE
FOREVER = .T.
TRYAGAIN = .F.
ON ERROR TRYAGAIN = .T.
DO WHILE FOREVER
   FOREVER = .F.
   IF EX_USE
      USE &FILE EXCLUSIVE
   ELSE
      USE &FILE
   ENDIF
   IF TRYAGAIN 
      TRYAGAIN = .F.
      FOREVER = .T.
      YN = 'Y' 
      @ 23,30 SAY "File is in Use Try Again (Y/N)? " GET YN PICTURE '@!'
      READ
      @ 23,30 TO 23,65
      IF YN <> 'Y'
        ON ERROR
        RETURN TO MASTER
     ENDIF
  ENDIF
ENDDO
*ON ERROR DO ERR_HAND
ON ERROR
RETURN(.F.)
