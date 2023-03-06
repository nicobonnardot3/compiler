#include <stdio.h>
#include "test.h"

extern int yylex();
extern int yylineno;
extern char* yytext;

int main()
{
    int ntoken, vtoken;
    ntoken = yylex();

    while(ntoken)
    {
        
        printf("Token %d, Line %d, Text %s \n", ntoken, yylineno, yytext);
        
        ntoken = yylex();
    }
    return 0;
}
