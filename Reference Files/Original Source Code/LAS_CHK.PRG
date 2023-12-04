      *** DO THE NEW LASER PRINT CHECK FORMAT
      
      MCHK_AMT = MTOT
      **** PRINT THE CHECK

      *** FONT LETTER GOTHIC
      ?? CHR(27) + '(s0p10h0s0b4099T'
      *** PRINT IN 8 LINES PER IN/VERTICAL
      ?? chr(27) + '&l8D'
      ? SPACE(13)
      
      *** FONT LETTER GOTHIC BOLD
      ?? CHR(27) + '(s0p10h0s3b4099T'
      ?? SPACE(40) + 'Check No: ' + STR(MCK_NBR,6)
      
      
      ?
      ?
      
      *** FONT LETTER GOTHIC
      ?? CHR(27) + '(s0p10h0s0b4099T'
      
      STORE SPACE(2) TO MPRT_NBR
      
      *** FONT LETTER GOTHIC BOLD
      ?? CHR(27) + '(s0p10h0s3b4099T'
      ??  SPACE(23) + 'Check Date' + space(15) + 'Amount'
      
      *** PRINT IN 16.5 CPI
      ?? chr(27) + '&k2S'
      ?  SPACE(1)
      
      *** PRINT IN 10 CPI
      ?? chr(27) + '&k0S'
      ??  SPACE(11)
      ?? SPACE(35) + MDATE     
      MAMOUNT = '$' + LTRIM(TRANSFORM(MCHK_AMT, "999,999.99"))
      
      ?? SPACE(9)
      ?? SPACE(2+10-LEN(MAMOUNT)) + MAMOUNT
      
      ?
      STORE STR(MCHK_AMT,9,2) TO MTOTC
      
      IF MTOT < 1.00
         IF MTOT > 0.00
            STORE SUBSTR(MTOTC,8,2)+ '/100 Dollars' TO mMTOTstr
         ELSE
            STORE ' Error -- Negative Amount of '+MTOTC TO mMTOTstr
         ENDIF
      ELSE
         STORE '& ' +SUBSTR(MTOTC,8,2)+ '/100 Dollars' TO mMTOTstr
         STORE VAL(SUBSTR(MTOTC,5,2)) TO p
         IF p < 20 .AND. p > 9
            STORE VAL(SUBSTR(MTOTC,6,1)) TO p
            STORE TRIM(SUBSTR('Ten       Eleven    Twelve    Thirteen  Fourteen  ' + ;
               'Fifteen   Sixteen   Seventeen Eighteen  Nineteen    ',p*10+1,10))+' '+ ;
               mMTOTstr TO mMTOTstr
         ELSE
            STORE VAL(SUBSTR(MTOTC,6,1)) TO p
            IF p > 0
               STORE TRIM(SUBSTR('     One  Two  ThreeFour Five Six  '+;
                  'SevenEightNine   ',p*5+1,5))+ ' ' +mMTOTstr TO mMTOTstr
            ENDIF
            STORE VAL(SUBSTR(MTOTC,5,1)) TO p
            IF p > 1
               IF VAL(SUBSTR(MTOTC,6,1)) > 0
                  STORE TRIM(SUBSTR('       Ten    Twenty Thirty Forty  '+;
                     'Fifty  Sixty  SeventyEighty Ninety   ',p*7+1,7))+ '-' +mMTOTstr TO mMTOTstr
               ELSE
                  STORE TRIM(SUBSTR('       Ten    Twenty Thirty Forty  '+;
                     'Fifty  Sixty  SeventyEighty Ninety   ',p*7+1,7))+ ' ' +mMTOTstr TO mMTOTstr
               ENDIF
            ENDIF
         ENDIF
         STORE VAL(SUBSTR(MTOTC,4,1)) TO p
         IF p > 0
            STORE TRIM(SUBSTR('     One  Two  ThreeFour Five Six  Seven'+;
               'EightNine   ',p*5+1,5))+ ' Hundred ' +mMTOTstr TO mMTOTstr
         ENDIF
      ENDIF
      IF MTOT > 999.99
         STORE ' Thousand ' +mMTOTstr TO mMTOTstr
         STORE VAL(SUBSTR(MTOTC,2,2)) TO p
         IF p < 20 .AND. p > 9
            STORE VAL(SUBSTR(MTOTC,3,1)) TO p
            STORE TRIM(SUBSTR('Ten       Eleven    Twelve    Thirteen  Fourteen  '+ ;
               'Fifteen   Sixteen   Seventeen Eighteen  Nineteen    ',p*10+1,10))+ ;
               mMTOTstr TO mMTOTstr
         ELSE
            STORE VAL(SUBSTR(MTOTC,3,1)) TO p
            IF p > 0
               STORE TRIM(SUBSTR('     One  Two  ThreeFour Five Six  Seven'+;
                  'EightNine   ',p*5+1,5))+mMTOTstr TO mMTOTstr
            ENDIF
            STORE VAL(SUBSTR(MTOTC,2,1)) TO p
            IF p > 1
               IF VAL(SUBSTR(MTOTC,3,1)) > 0
                  STORE TRIM(SUBSTR('       Ten    Twenty Thirty Forty  '+;
                     'Fifty  Sixty  SeventyEighty Ninety   ',p*7+1,7))+ '-' +mMTOTstr TO mMTOTstr
               ELSE
                  STORE TRIM(SUBSTR('       Ten    Twenty Thirty Forty  '+;
                     'Fifty  Sixty  SeventyEighty Ninety   ',p*7+1,7))+ ' ' +mMTOTstr TO mMTOTstr
               ENDIF VAL(SUBSTR(MTOTC,3,1)) > 0
            ENDIF
         ENDIF
      ENDIF
      IF MTOT > 99999.99
         STORE VAL(SUBSTR(MTOTC,1,1)) TO p
         STORE TRIM(SUBSTR('     One  Two  ThreeFour Five Six  Seven'+;
            'EightNine   ',p*5+1,5))+ ' Hundred ' +mMTOTstr TO mMTOTstr
      ENDIF
      IF MTOT > 999999.99
         STORE '*************************************** Dollars' ;
            TO mMTOTstr
      ENDIF
      STORE '***'+mMTOTstr TO mMTOTstr
      DO CASE
      CASE MTOT <= 9.99
         STORE '******' + STR(MTOT,4,2) TO mamount
      CASE MTOT <= 99.99
         STORE '*****' + STR(MTOT,5,2) TO mamount
      CASE MTOT <= 999.99
         STORE '****' + STR(MTOT,6,2) TO mamount
      CASE MTOT <= 9999.99
         STORE '***' + SUBSTR(STR(MTOT,7,2),1,1) + ;
            ',' + SUBSTR(STR(MTOT,7,2),2,6) TO mamount
      CASE MTOT <= 99999.99
         STORE '**' + SUBSTR(STR(MTOT,8,2),1,2) + ;
            ',' + SUBSTR(STR(MTOT,8,2),3,6) TO mamount
      CASE MTOT <= 999999.99
         STORE '*' + SUBSTR(STR(MTOT,9,2),1,3) + ;
            ',' + SUBSTR(STR(MTOT,9,2),4,6) TO mamount
      CASE MTOT <= 9999999.99
         STORE SUBSTR(STR(MTOT,10,2),1,4) + ;
            ',' + SUBSTR(STR(MTOT,10,2),5,6) TO mamount
      ENDCASE
      IF MTOT < 0.00
         STORE  '****,***.**' TO mamount
      ENDIF
      ? SPACE(5) + mMTOTstr
      *** FONT LETTER GOTHIC REGULAR
      ?? CHR(27) + '(s0p10h0s0b4099T'
      ? 
      ? 
      ? 'Pay' + space(3) + MNAME
      ? ' To' + SPACE(3) + MSTREET
      ? SPACE(5) + TRIM(MCITY) + ', ' + MSTATE + '  ' + MZIP
      ?
      ?
      ?
      ?
      *** FONT LETTER GOTHIC
      ?? CHR(27) + '(s0p10h0s0b4099T'
      *** PRINT IN 6 LINES PER IN/VERTICAL
      ?? chr(27) + '&l8D'
      ?
      ?
      
      **********************
      **** PRINT THE FIRST STUB
      **** FONT LETTER GOTHIC
      
      ?? CHR(27) + '(s0p10h0s0b4099T'
      *** PRINT IN 6 LINES PER IN/VERTICAL
      ?? chr(27) + '&l6D'
      ?
      ?
      ?
      
      *** PRINT IN 8 LINES PER IN/VERTICAL
      ?? chr(27) + '&l8D'
      ?
      ? SPACE(3) + SPACE(48) + '  Check #: ' + STR(MCK_NBR,6)
