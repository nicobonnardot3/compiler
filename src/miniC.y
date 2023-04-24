
%code requires {
	#include "callTree/CallTree.h"

}

%{
#include <stdio.h>
#include <stdlib.h>
#include "hashTable/HashTable.h"

// ----- Vars -----
extern int *list_index;
extern HashTable* varHashTable;

// ----- lex/yacc -----
extern void yyerror (char const *s);
extern int yylex();

// ----- Utils -----
extern char* removeUnwantedChar(char* str);
extern void extractVarName(char* dest, char* str);
extern void extractTableVar(char* str, char* input);
extern void extractVarIndex(char* str, int* index, char** src);
extern int parseOperation(int a, int b, char* op);

%}

%union {
	int num;
	CallTree* calltree;
	CallTree** calltree_list;
	char* id;
	char* bin_op;
	char* type;
}

%token <id> IDENTIFICATEUR "identifier"
%token <num> CONSTANTE "const"
%token VOID "void" INT "int" FOR "for" WHILE "while" IF "if" ELSE "else" SWITCH "switch" CASE "case" DEFAULT "default"
%token BREAK "break" RETURN "return" PLUS "+" MOINS MUL "*" DIV "/" LSHIFT "<<" RSHIFT ">>" BAND "&&" BOR "||" LAND "&" LOR "|" LT "<" GT ">"
%token GEQ ">=" LEQ "<=" EQ "=" NEQ "-" NOT "!" EXTERN "extern"

%type <calltree> declarateur "declarateur" declaration "declaration" fonction "fonction"
%type <calltree_list> liste_declarateurs "declarateurs" liste_declarations "declarations" liste_fonctions "fonctions"
%type <num> expression condition
%type <calltree> variable declarateur_list
%type <bin_op> binary_op binary_rel binary_comp
%type <type> type

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
	liste_declarations liste_fonctions		{
												CallTree* node = (CallTree*) malloc(sizeof(CallTree));
												createCallTree(node, "programme");
												addCode(node, "");

												printf("Programme :\n");
												printTree(node);

												printf("Liste de declarations :\n");
												CallTree** list = $1;
												int size = sizeof(list) / sizeof(list[0]);
												for (int i = 0; i < size; i++) {
													addParent(list[i], node);
													printTree(list[i]);
												}

												printf("Liste de fonctions :\n");
												list = $2;
												size = sizeof(list) / sizeof(list[0]);
												for (int i = 0; i < size; i++) {
													addParent(list[i], node);
													printTree(list[i]);
												}
											}
;
liste_declarations :
		  	liste_declarations declaration  {
												CallTree* node = (CallTree*) malloc(sizeof(CallTree));
												createCallTree(node, "liste_declarations");
												addCode(node, "");

												if ($1 != NULL) {
													CallTree** list = $1;
													int size = sizeof(list) / sizeof(list[0]) + 1;
													list = (CallTree**) realloc(list, size * sizeof(CallTree*));
													list[size - 1] = node;
													$$ = list;
												}
												else {
													CallTree** list = (CallTree**) calloc(1, sizeof(CallTree*));
													list[0] = node;
													$$ = list;
												}
											}
		|									{
												$$ = NULL;
											}
;
liste_fonctions :
			liste_fonctions fonction		{
												CallTree* node = (CallTree*) malloc(sizeof(CallTree));
												createCallTree(node, $2->name);
												addCode(node, "");
												printTree(node);

												CallTree** list = $1;
												int size = sizeof(list) / sizeof(list[0]) + 1;
												list = (CallTree**) realloc(list, size * sizeof(CallTree*));
												list[size - 1] = node;
												$$ = list;
												}
		|  	fonction						{
												CallTree* node = (CallTree*) malloc(sizeof(CallTree));
												createCallTree(node, $1->name);
												addCode(node, "");
												printTree(node);

												CallTree** list = (CallTree**) calloc(1, sizeof(CallTree*));
												list[0] = node;
												$$ = list;
											}
;
declaration :
	type liste_declarateurs ';'	{
									CallTree** list = $2;
									CallTree* node = (CallTree*) malloc(sizeof(CallTree));
									createCallTree(node, "declaration");
									addCode(node, "");
									int size = sizeof(list) / sizeof(list[0]);
									for (int i = 0; i < size; i++) {
										addParent(list[i], node);
										printTree(list[i]);
									}
									$$ = node;
								}
;
liste_declarateurs  :
			liste_declarateurs ',' declarateur {
												CallTree* node = (CallTree*) malloc(sizeof(CallTree));
												createCallTree(node, $3);
												addCode(node, "");
												printTree(node);
												CallTree** list = $1;
												int size = sizeof(list) / sizeof(list[0]) + 1;
												list = (CallTree**) realloc(list, size * sizeof(CallTree*));
												list[size - 1] = node;
												$$ = list;
												}
				|	declarateur				{
												CallTree* node = (CallTree*) malloc(sizeof(CallTree));
												createCallTree(node, $1);
												addCode(node, "");
												printTree(node);
												CallTree** list = (CallTree**) calloc(1, sizeof(CallTree*));
												list[0] = node;
												$$ = list;
											}
;
declarateur :	
		IDENTIFICATEUR					{
									char* str = removeUnwantedChar($1);
									createVar(varHashTable, str, "int");
//									strcpy($$, str);
								}
	|	declarateur_list '[' CONSTANTE ']'		{
									int size = $3;
									createList(varHashTable, $1, size);
								}
;
declarateur_list :
		IDENTIFICATEUR 					{
									char str[255] = "";
                                                                  	extractVarName(str, $1);
                                                                  	$$ = str;
								}
;
fonction :	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' { // sous Arbre abstrait, chaque instruction -> fils
																									CallTree* node = (CallTree*) malloc(sizeof(CallTree));
																									createCallTree(node, $2);
																									addCode(node, "");
																									node->type = $1;
																									printTree(node);
																									
																									CallTree** list = $7;
																									int size = sizeof(list) / sizeof(list[0]);
																									
																									for (int i = 0; i < size; i++) {
																										addParent(list[i], node);
																										printTree(list[i]);
																									}

																									// list = $8;
																									// size = sizeof(list) / sizeof(list[0]);

																									// for (int i = 0; i < size; i++) {
																									// 	addParent(list[i], node);
																									// 	printTree(list[i]);
																									// }

																									$$ = node;
																							}
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
;
type :	
		VOID { $$ = "void"; }
	|	INT  { $$ = "int"; }
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
	|
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
					int *index = (int *) malloc(sizeof(int));

					printf("$1 = %s\n", *$1);

					extractVarIndex(str, index, $1);

//					if (*index == -1) {
//						updateVar(varHashTable, str, $3);
//					} else {
//						updateListVar(varHashTable, str, *index, $3);
//					}
				}
;
bloc :
	'{' liste_declarations liste_instructions '}'	// node BLOC
;
appel :
	IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable :
		IDENTIFICATEUR					{
									char str[255] = "";
									extractVarName(str, $1);

									printf("indent str: %s\n", str);

									char out[255] = "";
									sprintf(out, "%s,%d", str, -1);
									printf("str: %s\n", out);
									$$ = &out;
								 }
	|	variable '[' expression ']'			{
									char* str[255];
									extractTableVar(str, $1);
									printf("str: %s\n", str);
									$$ = str;
								}
;
expression  :	// var et const = node, binop = sous arbre  | valeur
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