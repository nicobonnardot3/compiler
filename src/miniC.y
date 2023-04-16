%{
#include <stdio.h>
#include <stdlib.h>
#include "hashTable/HashTable.h"

extern int *list_index;

extern HashTable* varHashTable;
extern int parseOperation(int a, int b, char* op);
extern void createVar(HashTable *table, char* key, char *type);
extern void createList(HashTable *table, char *key, int size);
extern void updateVar(HashTable *table, char* str, int val);
extern void updateListVar(HashTable *table, char *listKey, int index, int value);
extern int symbolVal(HashTable *table, char* str);
extern void yyerror (char const *s);
extern int yylex();
extern char* removeUnwantedChar(char* str);
extern void extractVarName(char* dest, char* str);
extern void extractTableVar(char* str, int* index, char* input);


%}


%union {
	int num;
	char* id;
	char* bin_op;
}


%token <id> IDENTIFICATEUR "identifier"
%token <num> CONSTANTE "const"
%token VOID "void" INT "int" FOR "for" WHILE "while" IF "if" ELSE "else" SWITCH "switch" CASE "case" DEFAULT "default"
%token BREAK "break" RETURN "return" PLUS "+" MOINS MUL "*" DIV "/" LSHIFT "<<" RSHIFT ">>" BAND "&&" BOR "||" LAND "&" LOR "|" LT "<" GT ">"
%token GEQ ">=" LEQ "<=" EQ "=" NEQ "-" NOT "!" EXTERN "extern"

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

%define parse.error verbose


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
					if (list_index == NULL || list_index == -1) {
						char str[255] = "";
						extractVarName(str, $1);
						updateVar(varHashTable, str, $3);
					} else {
						updateListVar(varHashTable, $1, *list_index, $3);
					}
				}
;
bloc :
	'{' liste_declarations liste_instructions '}'	// node BLOC
;
appel :
	IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable :
		IDENTIFICATEUR					{  *list_index = -1; $$ = $1; }
	|	variable '[' expression ']'			{
									char* str[255];
									extractTableVar(str, list_index, $1);
									printf("str: %s; index: %d\n", str, *list_index);
									$$ = str;
								}
;
expression  :	// var et const = node, binop = sous arbre
		'(' expression ')'				{ $$ = $2; }
	|	expression binary_op expression %prec OP	{ $$ = parseOperation($1, $3, $2); }
	|	MOINS expression				{ $$ = -$2; }
	|	CONSTANTE					{ $$ = $1; }
	|	variable					{
									if (*(list_index) == -1) {
										char str[255] = "";
										extractVarName(str, $1);
										$$ = symbolVal(varHashTable, str);
									} else {
										printf("$1 = %s\n", $1);
										$$ = tableValue(varHashTable, $1, *list_index);
									}
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