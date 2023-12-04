**********
* Program.: MARK_COM.PRG
* Author..: Grace Keller
* Date....: 01/23/92
* Notice..: Copyright 1986, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: MARK COMMISSIONS PAID THAT ARE APPROVED
*
MTITLE = ' - MARK APPROVED COMMISSIONS TO BE PAID (SALARIED)'
CLEAR
@  1, 0 SAY MCOMPANY
@  1,68 SAY DATE()
@  2, 0 SAY MPROGRAM + MTITLE
@ 3,0 to 24,79
@ 4,5 SAY 'The following salespersons have approved order amounts:'
MLINE = 6
MNEGATIVE = .F.
SELECT A
DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMPD", .F.
SEEK ' S'
DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. COM_TYPE = 'S'
   STORE COM_CODE TO MCOM_CODE
   MTOT = 0
   DO WHILE .NOT. EOF() .AND. COM_PD = ' ' .AND. COM_TYPE = 'S' .AND. COM_CODE = MCOM_CODE
      IF APRVD_FLG <> 'Y'
         SKIP
         LOOP
      ENDIF
      MTOT = MTOT + AMOUNT 
      SKIP
   ENDDO
   IF MTOT <> 0
      @ MLINE,5 SAY 'Salesperson - ' + mcom_code + SPACE(5) + TRANSFORM(MTOT, '9,999,999.99')
      MLINE = MLINE + 1
      IF MTOT < 0
         MNEGATIVE = .T.
      ENDIF
   ENDIF
   
ENDDO
IF MLINE = 6   
   STORE ' ' TO MWAIT
   @ MLINE,1 SAY 'There are NO orders approved - press return to continue ' get mwait
   READ
   CLOSE DATA
   RETURN
ELSE  
   MLINE = MLINE + 1
   IF MNEGATIVE
      STORE ' ' TO MWAIT
      @ MLINE,5 SAY 'Cannot continue.  At least one person has a negative amount' 
      @ mline+1,5 say 'approved.  Unapprove until they have zero or positive amount. ' GET MWAIT
      READ
      CLOSE DATA
      RETURN
   ELSE
      store '   ' to myes_no
      DO WHILE MYES_NO <> 'YES' .AND. MYES_NO <> 'NO'
         @ MLINE,5 SAY 'Do you want to continue (YES/NO)? ' get myes_no picture '@!'
         READ
      ENDDO
      IF MYES_NO <> 'YES'
         CLOSE DATA
         RETURN
      ENDIF
   ENDIF
ENDIF
IF MCHOICE <> 'C'
   CLOSE DATA
   RETURN
ENDIF
MPRT_ONE = .F.

CLOSE DATA
SELECT A
DO FOX_USE WITH "&MMASTDBF.COMLED INDEX &MMASTDBF.COMLED, &MMASTDBF.COMPD", .F.
DO WHILE .NOT. EOF()
   IF COM_PD <> ' ' .OR. COM_TYPE <> 'S'
      SKIP
      LOOP
   ENDIF
   IF APRVD_FLG = 'Y'
      DO FILELOCK 
      REPLACE COM_PD WITH 'Y'
      REPLACE PAID_DATE WITH DATE()
      UNLOCK
   ENDIF
   SKIP
ENDDO
CLOSE DATA
RETURN
* EOF: MARK_COM.PRG
*Formatted by: ToolBox Ver. 1.2  on 1/23/92 at 10:24 AM.
