%{
#include <stdio.h>
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
#include "hashTable/HashTable.h"

int yylex();
int column = 0;
int countColumns(char *str);
int countLines(char *str);
extern void yyerror (char const *s);
%}


D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
IS                      (u|U|l|L)*

%option yylineno

%%


"("                     { column += 1; return *yytext; }
")"                     { column += 1; return *yytext; }

"["                     { column += 1; return *yytext; }
"]"                     { column += 1; return *yytext; }

"{"                     { createScope(); column += 1; return *yytext; }    
"}"                     { deleteScope(); column += 1; return *yytext; }
[:;=,]                  { column += 1; return *yytext; }

"int"                   { column += 3; return INT; }
"void"                  { column += 4; return VOID; }

"switch"                { column += 6; return SWITCH; }
"case"                  { column += 4; return CASE; }
"break"                 { column += 5; return BREAK; }
"default"               { column += 7; return DEFAULT; }

"if"                    { column += 2; return IF; }
"else"                  { column += 4; return ELSE; }

"for"                   { column += 3; return FOR; }
"while"                 { column += 5; return WHILE; }

"return"                { column += 6; return RETURN; }
"extern"                { column += 6; return EXTERN; }

{L}({L}|{D})*           {
                            column += strlen(yytext);
                            yylval.id = strdup(yytext);
                            return (IDENTIFICATEUR);
                        }
0[xX]{H}+{IS}?          {
                            column += strlen(yytext); 
                            yylval.num = atoi(yytext); 
                            return CONSTANTE; 
                        }
0{D}+{IS}?              { column += strlen(yytext); yylval.num = atoi(yytext); return CONSTANTE; }
{D}+{IS}?               { column += strlen(yytext); yylval.num = atoi(yytext); return CONSTANTE; }

"+"                     { column += 1; return PLUS; }
"-"                     { column += 1; return MOINS; }
"*"                     { column += 1; return MUL; }
"/"                     { column += 1; return DIV; }

"&&"                    { column += 1; return BAND; }
"||"                    { column += 1; return BOR; }
">>"                    { column += 2; return RSHIFT; }
"<<"                    { column += 2; return LSHIFT; }
"&"                     { column += 2; return LAND; }
"|"                     { column += 2; return LOR; }

"<"                     { column += 1; return LT; }
">"                     { column += 1; return GT; }
"<="                    { column += 2; return LEQ; }
">="                    { column += 2; return GEQ; }
"=="                    { column += 2; return EQ; }
"!="                    { column += 2; return NEQ; }
" "                     { column += 1; }
"\t"                    { column += 1; }
"\n"                    {  column = 0; }

"/*"([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/  { column = countColumns(yytext); }
"//".*                  {yylineno++; column = 0;}

.                       {
                            char errorString[255] = "";
                            sprintf(errorString, "Char not recognized: %s", yytext);
                            yyerror(errorString);
                            column++;
                        }
%%

int yywrap (void) {return 1;}

int countColumns(char *str) {
    int count = 0;
    char *p = str;
    while (*p) {
        if (*p == '\n')
            count = 0;
        else
            count++;
        p++;
    }
    return count;
}