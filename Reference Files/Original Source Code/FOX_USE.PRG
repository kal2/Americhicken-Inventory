PARAMETERS FILE, EX_USE
FOREVER = .T.
ON ERROR FOREVER = .T.
DO WHILE FOREVER
   FOREVER = .F.
   IF EX_USE
      USE &FILE EXCLUSIVE
   ELSE
      USE &FILE
   ENDIF
   IF FOREVER
      YN = 'Y' 
      @ 23,30 SAY "File is in Use Try Again (Y/N)? " GET YN PICTURE '@!'
      if ex_use
      @ 24,30 say 'exclusive ' + &file
      else
      @ 24,30 say 'not excl  ' + &file
      endif
      READ
    SUSPEND
      IF YN <> 'Y'
        ON ERROR
        RETURN TO MASTER
      ENDIF
   ENDIF
ENDDO
*ON ERROR DO ERR_HAND
ON ERROR
RETURN(.F.)
