#include <stdio.h>
#include <string.h>

static char *poczatek_napisu;
int dlugosc_tekstu;

%%{
  machine gr3;

  action Poczatek_Napisu { poczatek_napisu = fpc; }
  action pisz_zmienna
   {
    dlugosc_tekstu = fpc - poczatek_napisu;
    if (dlugosc_tekstu > 0) {
      printf("[%.*s]", dlugosc_tekstu, poczatek_napisu);
    }
   }
  action pisz_puste
   {
    dlugosc_tekstu = fpc - poczatek_napisu;
    if (dlugosc_tekstu > 0) {
      printf("<%.*s>", dlugosc_tekstu, poczatek_napisu);
    }
   }
  action pisz_stala
   {
    dlugosc_tekstu = fpc - poczatek_napisu;
    printf("{%.*s}\n", dlugosc_tekstu, poczatek_napisu);
   }
  action pisz_przecinek
   { printf(","); }
  action pisz_enter
   { printf("\n"); }

  whitespace = [ \t\v\f] >Poczatek_Napisu %pisz_puste ;
  enter      = [\r\n] ;
  string     = (alnum | '_')+ >Poczatek_Napisu %pisz_zmienna ;
  number     = ('+'|'-')?[0-9]+'.'[0-9]+( [eE] ('+'|'-')? [0-9]+ )? >Poczatek_Napisu %pisz_stala ;
  var        = string | number ;
  koniec     = (';' | enter) %pisz_enter ;
  line       = var whitespace* ( ',' %pisz_przecinek whitespace* var ) whitespace* koniec ;

  main:= whitespace* ( line )* ;

}%%

%% write data;

int main(void)
{
 char bufor[4096];
 size_t przeczytano;
 int cs;
 char *p = NULL;
 char *pe = NULL;
 char *eof = NULL;
 FILE *plik;

  plik = fopen("gr-dane.txt", "r");
  %% write init;

  do
  {
   przeczytano = fread(bufor, 1, sizeof(bufor), plik);
   p = bufor;
   pe = p + przeczytano;
   if (przeczytano < sizeof(bufor) && feof(plik)) eof = pe;

   %% write exec;

   if (eof || cs == %%{ write error; }%%) break;
  } while (1);

 fclose(plik);

return 0;
}
