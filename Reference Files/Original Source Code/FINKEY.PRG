PROCEDURE FINKEY
MSELECTION = INKEY(60)
IF MSELECTION = 0
   SET COLOR TO W/N
   CLEAR
   DO CASE
   CASE MUSER = 'KEN'
      SET COLOR TO W+/B+,W+/R+
   CASE MUSER = 'BOB'
      SET COLOR TO GR+/B+,GR+/GR    
   OTHERWISE
      SET COLOR TO W/N,N/W
   ENDCASE
   
   MSELECTION = INKEY(0)
   MSELECTION = '0'
ELSE
   DO CASE
   CASE MSELECTION < 0
      IF MSELECTION = -4
         SET PROC TO BUY_PROC
         DO CUSTINQ      
         SET PROC TO PO_PROC     
      ELSE              
      ENDIF
      MSELECTION = '0'
   OTHERWISE
      IF MSELECTION = 13
         MSELECTION = '1'
      ELSE
         MSELECTION = CHR(MSELECTION)
      ENDIF
   ENDCASE
ENDIF
RETURN MSELECTION
