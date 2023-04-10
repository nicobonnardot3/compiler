%{
#include <stdio.h>
#include <stdlib.h>
#include "hashTable/HashTable.h"

extern HashTable* varHashTable;
extern int parseOperation(int a, int b, char* op);
extern void createVar(HashTable *table, char* key, char *type);
extern void updateVar(HashTable *table, char* str, int val);
extern int symbolVal(HashTable *table, char* str);
extern void yyerror (char const *s);
extern int yylex();
extern char* removeUnwantedChar(char* str);
extern void extractVarName(char* dest, char* str);

%}

%union {
	int num;
	char* id;
	char* bin_op;
}

%token <id> IDENTIFICATEUR
%token <num> CONSTANTE
%token VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT
%token GEQ LEQ EQ NEQ NOT EXTERN

%type <num> expression condition
%type <id> variable declarateur_list
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
	liste_declarations liste_fonctions
;
liste_declarations :
		  	liste_declarations declaration 
		|
;
liste_fonctions :
			liste_fonctions fonction
		|   fonction
;
declaration :
	type liste_declarateurs ';'
;
liste_declarateurs  :	
			liste_declarateurs ',' declarateur
		|	declarateur
;
declarateur :	
		IDENTIFICATEUR					{
									char* str = removeUnwantedChar($1);
									createVar(varHashTable, str, "int");
								}
	|	declarateur_list '[' CONSTANTE ']'		{
									int size = $3;
									char* type = "int list";
									createList(varHashTable, $1, size);
								}
;
fonction :	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' // sous Arbre abstrait, chaque instruction -> fils
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
	INT IDENTIFICATEUR
;
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
affectation :		// sous-arbres : := -> nom_var, := -> EXPR
	variable '=' expression {
					char str[255] = "";
					extractVarName(str, $1);
					updateVar(varHashTable, str, $3);
				}
;
bloc :
	'{' liste_declarations liste_instructions '}'	// node BLOC
;
appel :
	IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable :	
		IDENTIFICATEUR					{ $$ = $1; }
	|	variable '[' expression ']' 				
;
expression  :	// var et const = node, binop = sous arbre
		'(' expression ')'				{ $$ = $2; }
	|	expression binary_op expression %prec OP	{ $$ = parseOperation($1, $3, $2); }
	|	MOINS expression				{ $$ = -$2; }
	|	CONSTANTE					{ $$ = $1; }
	|	variable					{
									char str[255] = "";
									extractVarName(str, $1);
									$$ = symbolVal(varHashTable, str);
								}
	|	IDENTIFICATEUR '(' liste_expressions ')'	{ $$ = 0; }
;
liste_expressions :
		liste_expressions ',' expression
	| 	expression
;
condition :	
		NOT '(' condition ')' 				{ $$ = !$3; }
	|	condition binary_rel condition %prec REL 	{ $$ = parseOperation($1, $3, $2); }
	|	'(' condition ')' 				{ $$ = $2; }
	|	expression binary_comp expression 		{ $$ = parseOperation($1, $3, $2); }
;
binary_op :	
		PLUS 	{ $$ = "+"; }
	|   	MOINS	{ $$ = "-"; }
	|	MUL 	{ $$ = "*"; }
	|	DIV 	{ $$ = "/"; }
	|   	LSHIFT	{ $$ = "<<"; }
	|   	RSHIFT	{ $$ = ">>"; }
	|	BAND	{ $$ = "&"; }
	|	BOR	{ $$ = "|"; }
;
binary_rel :
		LAND 	{ $$ = "&&"; }
	|	LOR 	{ $$ = "||"; }
;
binary_comp :
		LT		{ $$ = "<"; }
	|	GT		{ $$ = ">"; }
	|	GEQ		{ $$ = ">="; }
	|	LEQ		{ $$ = "<="; }
	|	EQ		{ $$ = "=="; }
	|	NEQ		{ $$ = "!="; }
;
%%