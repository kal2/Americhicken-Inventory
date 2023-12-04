*************
* Program.: DELTEMP.PRG
* Author..: Grace Keller
* Date....: 11/11/02
* Notice..: Copyright 1987, Solid Software, Inc., All Rights Reserved
* Version.: FOXPRO
* Notes...: DELETE PO DETAIL SAVE RECORD FOR FEDERATED FOODS
*
* ---OPEN FILES
*  MULTI-USER RECORD/FILE LOCKING  +(M1)  FoxPro   Multi-User Code Insertion     
SELECT A
DO FOX_USE WITH "TEMPFED INDEX TEMPFED", .F.
SEEK MSALESMAN + MPO_NBR + MPO_SUFFIX       
IF .NOT. EOF()
   DO RECLOCK
   DELETE
ENDIF
USE
RETURN
* EOF: DELTEMP.PRG
*Formatted by: ToolBox Ver. 1.2  on 6/28/2 at 6:30 AM.
