D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
IS                      (u|U|l|L)*

%{
#include <stdio.h>
#include "y.tab.h"
void yyerror (char *s);
int yylex();
%}

%%
"int"                   { return INT; }
"void"                  { return VOID; }

"switch"                { return SWITCH; }
"case"                  { return CASE; }
"break"                 { return BREAK; }
"default"               { return DEFAULT; }

"if"                    { return IF; }
"else"                  { return ELSE; }

"for"                   { return FOR; }
"while"                 { return WHILE; }

"return"                { return RETURN; }
"extern"                { return EXTERN; }

{L}({L}|{D})*           { return IDENTIFICATEUR; } // IDENTIFICATEUR

0[xX]{H}+{IS}?          { return CONSTANTE; } // HEXA DECIMAL
0{D}+{IS}?              { return CONSTANTE; } // OCTAL
{D}+{IS}?               { return CONSTANTE; } // INT

"+"                     { return PLUS; } // PLUS
"-"                     { return MOINS; } // MOINS
"*"                     { return MUL; } // MULT
"/"                     { return DIV; } // DIV

"&"                     { return BAND; } // AND
"|"                     { return BOR; } // OR
">>"                    { return RSHIFT; } // SHIFT
"<<"                    { return LSHIFT; } // SHIFT
"&&"                    { return LAND; } // AND
"||"                    { return LOR; } // OR

"<"                     { return LT; } // LT
">"                     { return GT; } // GT
"<="                    { return LT; } // LT
">="                    { return GT; } // GT
"=="                    { return EQ; } // EQ
"!="                    { return NEQ; } // NEQ
" "                     {  } // ESPACE

.                       { return yytext[0]; }
%%

int yywrap (void) {return 1;}