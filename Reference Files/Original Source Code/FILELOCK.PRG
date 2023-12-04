YN = "Y"
DO WHILE .NOT. FLOCK() .AND. YN = "Y"
   @ 23,30 SAY "File Is Locked Try Again (Y/N)? " GET YN PICTURE '@!'
   READ
   @ 23,30 SAY SPACE(40)
   IF YN <> 'Y'
      RETURN TO MASTER
   ENDIF
ENDDO
RETURN
         
 