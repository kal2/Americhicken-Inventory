*******************************
** THIS IS FOR SET PRINT
*******************************
IF FILE("C:\PRINTQ\PRINTQ.INI")
   SET PRINT TO C:\PRINTQ\EPSON.TXT
ELSE
   SET PRINT TO LPT2
ENDIF
SET PRINT ON
SET CONSOLE OFF


*******************************
** THIS IS FOR SET DEVICE
*******************************
IF FILE("C:\PRINTQ\PRINTQ.INI")
   SET PRINT TO C:\PRINTQ\HP.TXT
ELSE
   SET PRINT TO LPT3
ENDIF

SET CONSOLE OFF
SET DEVICE TO PRINT


*******************************
*** THIS IS FOR SET DEVICE - BUT NEED TO SEND CHR(27) FIRST
*******************************
IF FILE("C:\PRINTQ\PRINTQ.INI")
   SET PRINT TO C:\PRINTQ\HP.TXT
ELSE
   SET PRINT TO LPT2
ENDIF

SET CONSOLE OFF
SET PRINT ON

*** PRINT IN 12 CPI
?? chr(27) + '&k4S'

SET DEVICE TO PRINT




*****************************************
*** ALL OTHER FORMAT COMMANDS
*****************************************
*** PRINT IN 8 LINES PER IN/VERTICAL
?? chr(27) + '&l8D'

*** PRINT IN 10 CPI
?? chr(27) + '&k0S'

*** PRINT IN 12 CPI
?? chr(27) + '&k4S'

*** PRINT IN 16.5 CPI
?? chr(27) + '&k2S'

*** LANDSCAPE MODE
?? CHR(27) + '&l1O'

*** PORTRAIT MODE
?? CHR(27) + '&l0O'

*** UNDERLINE ON
?? CHR(27) + '&d0D'

*** UNDERLINE OFF
?? CHR(27) + '&d@'

*** BOLDED PRINT
?? CHR(27) + '(s4B'

*** BACK TO MEDIUM STROKE PRINT
?? CHR(27) + '(s0B'

*** FONT COURIER BOLD
?? CHR(27) + '(s0ph0s3b4099T'

*** FONT COURIER REGULAR
?? CHR(27) + '(s0p10h0s0b4099T'

*** FONT NEW CENTURY SCHOOLBOOK BOLD
?? CHR(27) + '(s1p10v0s3b24703T'

*** FONT ARIAL BOLD
?? CHR(27) + '(s1p10v0s3b16602T'


***** MONOSPACED FONTS
*** FONT COURIER
?? CHR(27) + '(s4099T'

*** GOTHIC PRINT
?? CHR(27) + '(s4102T'

**************************************************
** NOTE: GOTHIC OVERLAPS LINES IN 8 LINES PER INCH
**************************************************

*** SELECT TRAY 1
?? CHR(27) + '&l4H'

*** SELECT TRAY 2
?? CHR(27) + '&l1H'

*** SELECT TRAY 3
?? CHR(27) + '&l5H'

*** AUTO SELECT   
?? CHR(27) + '&l7H'

*** LETTER SIZE PAPER
?? CHR(27) + '&l2A'

*** LEGAL SIZE PAPER
?? CHR(27) + '&l3A'

*** RESET TO FACTORY SETTINGS
?? CHR(27) + 'E'

********* COLOR COMMANDS
*** SELECT SIMPLE RGB COLOR PALETTE
?? CHR(27) + '*r3U'

*** BLACK
?? CHR(27) + '*v0S'

*** RED
?? CHR(27) + '*v1S'

*** GREEN
?? CHR(27) + '*v2S'

*** YELLOW
?? CHR(27) + '*v3S'

*** BLUE  (LOOKS LIKE PURPLE)
?? CHR(27) + '*v4S'

*** MAGENTA
?? CHR(27) + '*v5S'

*** CYAN  (LOOKS LIKE AN AQUA BLUE)
?? CHR(27) + '*v6S'

*** WHITE
?? CHR(27) + '*v7S'

