D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
IS                      (u|U|l|L)*

%{
#include <stdio.h>
#include "y.tab.h"
void yyerror (char const *s);
int str_length(char str[]);
int yylex();
int column = 1;
%}

%%
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

{L}({L}|{D})*           { column += str_length(yytext); yylval.id = yytext; return IDENTIFICATEUR; } // IDENTIFICATEUR

0[xX]{H}+{IS}?          { column += str_length(yytext); yylval.num = atoi(yytext); return CONSTANTE; } // HEXA DECIMAL
0{D}+{IS}?              { column += str_length(yytext); yylval.num = atoi(yytext); return CONSTANTE; } // DECIMAL
{D}+{IS}?               { column += str_length(yytext); yylval.num = atoi(yytext); return CONSTANTE; } // INT

"+"                     { column += 1; return PLUS; } // PLUS
"-"                     { column += 1; return MOINS; } // MOINS
"*"                     { column += 1; return MUL; } // MULT
"/"                     { column += 1; return DIV; } // DIV

"&"                     { column += 1; return BAND; } // AND
"|"                     { column += 1; return BOR; } // OR
">>"                    { column += 2; return RSHIFT; } // SHIFT
"<<"                    { column += 2; return LSHIFT; } // SHIFT
"&&"                    { column += 2; return LAND; } // AND
"||"                    { column += 2; return LOR; } // OR

"<"                     { column += 1; return LT; } // LT
">"                     { column += 1; return GT; } // GT
"<="                    { column += 2; return LT; } // LT
">="                    { column += 2; return GT; } // GT
"=="                    { column += 2; return EQ; } // EQ
"!="                    { column += 2; return NEQ; } // NEQ
" "                     { column += 1; } // ESPACE

"\n"                    {  column = 1; yylineno++; } // RETOUR A LA LIGNE

[\[(){};=,\]]               { column += 1; return yytext[0]; } // PARENTHESE

"//".*                  {yylineno++; column = 0;}

.                       { char *str; sprintf(str, "Caractere non reconnu : %s\n\tligne : %d\n\t column %d\n", yytext, yylineno, column); yyerror(str); column++; }
%%

int yywrap (void) {return 1;}

int str_length(char* str) {
    int count; 
    for (count = 0; str[count] != '\0'; ++count);
    return count; 
}