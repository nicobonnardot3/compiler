%{
#include <stdio.h>
#include <stdlib.h>
#include "hashTable/HashTable.h"

extern HashTable *hashTable;
extern int parseOperation(int a, int b, char op);
extern void createSymbol(HashTable* table, char* key);
extern void updateSymbol(char *str, int val);
extern int symbolVal(char *str);
extern void yyerror (char const *s);
extern int yylex();

%}

%union {
	int num;
	char id;
	char bin_op;

}

%token <id> IDENTIFICATEUR 
%token <num> CONSTANTE 
%token VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT
%token GEQ LEQ EQ NEQ NOT EXTERN

%type <num> expression condition
%type <id> variable
%type <bin_op> binary_op binary_rel binary_comp

%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%left OP
%left REL
%nonassoc THEN
%nonassoc ELSE

%start programme


%%
programme :
	liste_declarations liste_fonctions;
liste_declarations  : 
		  	liste_declarations declaration 
		| 	;
liste_fonctions :
			liste_fonctions fonction
		|   fonction
;
declaration :
	type liste_declarateurs ';';
liste_declarateurs  :	
			liste_declarateurs ',' declarateur
		|	declarateur
;
declarateur :	
		IDENTIFICATEUR					{ printf("variable: int %s;\n", $1 ); createSymbol(hashTable, $1);}
	|	declarateur '[' CONSTANTE ']'
;
fonction :	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}'
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
;
type :	
		VOID
	|	INT
;
liste_parms :	
		liste_parms ',' parm
	| parm
	|	
;
parm :
	INT IDENTIFICATEUR;
liste_instructions  :	
		liste_instructions instruction
	|	instruction
;
instruction :	
		iteration
	|	selection
	|	saut
	|	affectation ';'
	|	bloc
	|	appel
;
iteration :	
		FOR '(' affectation ';' condition ';' affectation ')' instruction
	|	WHILE '(' condition ')' instruction
;
selection :	
		IF '(' condition ')' instruction %prec THEN
	|	IF '(' condition ')' instruction ELSE instruction
	|	SWITCH '(' expression ')' instruction
	|	CASE CONSTANTE ':' instruction
	|	DEFAULT ':' instruction
;
saut :
		BREAK ';'
	 |	RETURN ';'
	 |	RETURN expression ';'
;
affectation :
	variable '=' expression 					{ printf("variable: int %s;\n", $1 ); updateSymbol($1, $3);};
bloc :
	'{' liste_declarations liste_instructions '}';
appel :
	IDENTIFICATEUR '(' liste_expressions ')' ';';
variable :	
		IDENTIFICATEUR								{ $$ = $1;}
	|	variable '[' expression ']' 				
;
expression  :
		'(' expression ')'							{ $$ = $2; printf("%d \n", $2);}
	|	expression binary_op expression %prec OP	{ $$ = parseOperation($1, $3, $2); printf("%d %c %d = %d \n", $1, $2, $3, $$);}
	|	MOINS expression							{ $$ = -$2; printf("%d \n", $2);}
	|	CONSTANTE									{ $$ = $1; printf("%d \n", $1);}
	|	variable									{ $$ = symbolVal($1); printf("%d \n", $$);}
	|	IDENTIFICATEUR '(' liste_expressions ')'	{ $$ = 0; printf("%d \n", $$);}
;
liste_expressions :	
		liste_expressions ',' expression
	| 	expression
;
condition :	
		NOT '(' condition ')' 					{ $$ = !$3;}
	|	condition binary_rel condition %prec REL { $$ = parseOperation($1, $3, $2);}
	|	'(' condition ')' 						{ $$ = $2;}
	|	expression binary_comp expression 		{ $$ = parseOperation($1, $3, $2);}
;
binary_op :	
		PLUS 	{ $$ = '+'; }
	|   MOINS	{ $$ = '-'; }
	|	MUL 	{ $$ = '*'; }
	|	DIV 	{ $$ = '/'; }
	|   LSHIFT	{ $$ = '<<'; }
	|   RSHIFT	{ $$ = '>>'; }
	|	BAND	{ $$ = '&'; }
	|	BOR		{ $$ = '|'; }
;
binary_rel :
		LAND 	{ $$ = '&&'; }
	|	LOR 	{ $$ = '||'; }
;
binary_comp :
		LT		{ $$ = '<'; }
	|	GT		{ $$ = '>'; }
	|	GEQ		{ $$ = '>='; }
	|	LEQ		{ $$ = '<='; }
	|	EQ		{ $$ = '=='; }
	|	NEQ		{ $$ = '!='; }
;
%%