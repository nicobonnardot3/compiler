%code requires {
	#include "functionHashTable/functionHashTable.h"
}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hashTable/HashTable.h"

// ----- Vars -----
extern int* nodeIndex;
extern HashTable* varHashTable;
extern struct FunctionHashTable* functionHashTable;
extern char* inputFile;
extern char* outputFile;
extern struct FunctionError* functionError;

// ----- lex/yacc -----
extern void yyerror (char const *s);
extern int yylex();

// ----- Utils -----
extern char* removeUnwantedChar(char* str);
extern char* extractVarName(char* str);
extern void extractTableVar(char* str, char* input);
extern void extractVarIndex(char* str, int* index, char** src);
extern int parseOperation(int a, int b, char* op);
extern void createError(char* error);
%}

%union {
	int num;
	FunctionParam* params;
	CallTree calltree;
	CallTree** calltree_list;
	char* id;
	char* bin_op;
	char* type;
	int* indexes;
}

%token <id> IDENTIFICATEUR "identifier"
%token <num> CONSTANTE "const"
%token VOID "void" INT "int" FOR "for" WHILE "while" IF "if" ELSE "else" SWITCH "switch" CASE "case" DEFAULT "default"
%token BREAK "break" RETURN "return" PLUS "+" MOINS MUL "*" DIV "/" LSHIFT "<<" RSHIFT ">>" BAND "&&" BOR "||" LAND "&" LOR "|" LT "<" GT ">"
%token GEQ ">=" LEQ "<=" EQ "=" NEQ "-" NOT "!" EXTERN "extern"

%type <calltree> variable appel "appel" condition "condition" instruction "instruction" affectation "affectation" iteration "iteration" selection "selection" saut "saut" bloc "bloc" expression "expression" declarateur "declarateur" fonction "fonction"
%type <calltree_list> liste_expressions "liste_expressions" liste_instructions "liste_instructions" declaration "declaration" liste_declarateurs "declarateurs" liste_declarations "declarations" liste_fonctions "fonctions"
%type <params> liste_params "liste_parametre" param "parametre"
%type <bin_op> binary_op binary_rel binary_comp
%type <type> type
%type <id> declarateur_list
%type <indexes> liste_indexes

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
programme:
	liste_declarations liste_fonctions
	{
		CallTree** functionTree = $2;

		FILE *fptr;
		fptr = fopen(outputFile, "w+");
		if(fptr == NULL) {
			printf("Error!");
			exit(1);
		}

		fprintf(fptr, "digraph Programme {\n");

		int i = 0;
		while (functionTree[i] != NULL) {
			CallTree* node = functionTree[i];
			fprintf(fptr, "%s\n", node->code);
			free(node);
			i++;
		}

		fprintf(fptr, "}");
		fclose(fptr);
		return 0;
	}
;
liste_declarations :
		  	liste_declarations declaration
				{
					CallTree** list = $1;

					if (list == NULL) {
						list = $2;
					} else {
						int size = 0;
						while (list[size] != NULL) size++;

						int size2 = 0;
						while ($2[size2] != NULL) size2++;

						list = (CallTree**) realloc(list, (size + size2 + 3) * sizeof(CallTree*));
						for (int i = 0; i < size2 + 2; i++) {
							CallTree* node = $2[i];
							list[size + i - 1] = node;
						}
						list[size + size2 + 1] = NULL;
					}
					$$ = list;
				}
		|		{ $$ = NULL; }
;
liste_fonctions :
			liste_fonctions fonction
			{
				
				CallTree** functionTree = $1;
				CallTree* node = (CallTree*) malloc(sizeof(CallTree));
				*node = $2;
				int size = 0;
				while (functionTree[size] != NULL) size++;

				functionTree = (CallTree**) realloc(functionTree, (size + 3) * sizeof(CallTree*));

				functionTree[size] = node;
				functionTree[size + 1] = NULL;
				$$ = functionTree;
			}
		|  	fonction
			{
				CallTree** functionTree = (CallTree**) calloc(2, sizeof(CallTree*));
				CallTree* node = (CallTree*) malloc(sizeof(CallTree));
				*node = $1;

				functionTree[0] = node;
				functionTree[1] = NULL;
				$$ = functionTree;
			}
;
declaration :
	type liste_declarateurs ';'
			{
				CallTree** list = $2;
				$$ = list;
			}
;
liste_declarateurs:
			liste_declarateurs ',' declarateur
					{
						CallTree** list = $1;
						int size = 0;
						while (list[size] != NULL) size++;

						list = (CallTree**) realloc(list, (size + 3) * sizeof(CallTree*));
						CallTree* node = (CallTree*) malloc(sizeof(CallTree));
						*node = $3;
						list[size] = node;
						list[size + 1] = NULL;
						$$ = list;
					}
			|	declarateur
					{
						CallTree** list = (CallTree**) calloc(2, sizeof(CallTree*));
						CallTree* node = (CallTree*) malloc(sizeof(CallTree));
						*node = $1;
						list[0] = node;
						list[1] = NULL;
						$$ = list;
					}
;
declarateur :
		IDENTIFICATEUR
			{
				char* str = removeUnwantedChar($1);

				if (inCurrentScope(str) == 1) {
					char *error = (char*) malloc(sizeof(char) * (strlen(str) + 50));
					sprintf(error, "Error: variable %s already declared", str);
					createError(error);
				}
				char* nodeName = (char*) malloc(sizeof(char) * (strlen(str) + 20));
				sprintf(nodeName, "node_%s_%d", str, *nodeIndex);
				*nodeIndex = *nodeIndex + 1;

				CallTree node = createCallTree(nodeName);

				char* code = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen(str) + 60));
				sprintf(code, "%s [shape=ellipse label=\"%s, int\"];", nodeName, str);

				addCode(&node, code);
				free(code);
				initVar(str);

				$$ = node;
			}
	|	declarateur_list liste_indexes
			{
				if (inCurrentScope($1) == 1) {
					char *error = (char*) malloc(sizeof(char) * (strlen($1) + 50));
					sprintf(error, "Error: variable %s already declared", $1);
					createError(error);
				}

				int *sizes = $2;
				initList($1, sizes);

				char* nodeName = (char*) malloc(sizeof(char) * (strlen($1) + 30));
				sprintf(nodeName, "node_%s_%d", $1, *nodeIndex);
				*nodeIndex = *nodeIndex + 1;

				char* code = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen($1) + 60));
				sprintf(code, "\n%s [shape=ellipse label=\"%s\"];", nodeName, $1);

				CallTree node = createCallTree(nodeName);

				addIndex(&node, $2);
				addCode(&node, code);

				free(nodeName);
				free(code);

				$$ = node;
			}
;
declarateur_list:
		IDENTIFICATEUR 
			{
				char* str = extractVarName($1);
				$$ = str;
			}
;
liste_indexes:
		liste_indexes '[' CONSTANTE ']'
			{
				int *indexes = $1;
				int size = 0;
				while (indexes[size] != -1) size++;

				indexes = (int *) realloc(indexes, (size + 2) * sizeof(int));
				
				indexes[size] = $3;
				indexes[size + 1] = -1;

				$$ = indexes;
			}
	|	'[' CONSTANTE ']'
			{
				int *indexes = (int *) calloc(2, sizeof(int));
				indexes[0] = $2;
				indexes[1] = -1;
				$$ = indexes;
			}
;
fonction :
		type IDENTIFICATEUR '(' liste_params ')' '{' liste_declarations liste_instructions '}'
			{ // sous Arbre abstrait, chaque instruction -> fils
				char* type = $1;
				char* name = $2;

				char* filteredName = (char*) malloc(sizeof(char) * (strlen(name) + 20));
				strcpy(filteredName, name);
				strtok(filteredName, "(");

				char* nodeName = (char*) malloc(sizeof(char) * (strlen(filteredName) + strlen(type) + 5));
				sprintf(nodeName, "%s, %s", filteredName, type);

				char* nodeId = (char*) malloc(sizeof(char) * (strlen(filteredName) + strlen(type) + 10));
				sprintf(nodeId, "node_%s_%d", filteredName, *nodeIndex);
				*nodeIndex = *nodeIndex + 1;

				// CallTree** liste_declarations = $7;
				CallTree** liste_instructions = $8;

				CallTree node = createCallTree(nodeId);
				
				char* blocName = (char*) malloc(sizeof(char) * 40);
				sprintf(blocName, "node_bloc_%d", *nodeIndex);
				
				char* codeBloc = (char*) malloc(sizeof(char) * (2 * strlen(blocName) + strlen(nodeId) + 60));
				sprintf(codeBloc, "%s [shape=ellipse label=\"BLOC\"];\n%s -> %s\n", blocName,  nodeId, blocName);

				char* nodeCode = (char*) malloc(sizeof(char) * (strlen(codeBloc) + strlen(nodeId) + strlen(nodeName) + 70));
				sprintf(nodeCode, "\n%s [label=\"%s\" shape=invtrapezium color=blue];\n%s", nodeId, nodeName, codeBloc);

				node.type = type;

				int i = 0;
				while (liste_instructions != NULL && liste_instructions[i] != NULL) {

					char* codeLien = (char*) malloc(sizeof(char) * (strlen(liste_instructions[i]->name) + strlen(blocName) + 255));
					sprintf(codeLien, "\n%s -> %s\n", blocName, liste_instructions[i]->name);

					nodeCode = (char*) realloc(nodeCode, sizeof(char) * (strlen(nodeCode) + strlen(liste_instructions[i]->code) + strlen(codeLien) + 255));
					strcat(nodeCode, liste_instructions[i]->code);
					strcat(nodeCode, codeLien);
					i++;
				}

				addCode(&node, nodeCode);

				free(nodeId);
				free(nodeCode);
				free(blocName);
				free(codeBloc);
				free(filteredName);
				free(nodeName);

				FunctionHtItem *item = (FunctionHtItem*) malloc(sizeof(FunctionHtItem));
				*item = createFunctionHtItem(name, $1, $4);
				addFunction(item);

				FunctionError *tmpFunctionError = functionError;
				while (tmpFunctionError != NULL) {
					if (strcmp(tmpFunctionError->message, "") != 0) {
						if (strcmp(tmpFunctionError->name, name) != 0) {
							createError(tmpFunctionError->message);
						}
					}
					if (strcmp(tmpFunctionError->name, name) == 0) {
						CallTree** nodes = tmpFunctionError->nodes;
						int valid = verifyParams(item, nodes);
						if (valid != 0) {
							char* error = malloc(sizeof(char) * (strlen(name) + 60));
							switch(valid) {
								case 1:
									sprintf(error, "Error : Too many arguments for function %s", tmpFunctionError->name);
									break;
								case 2:
									sprintf(error, "Error : Too few arguments for function %s", tmpFunctionError->name);
									break;
								default:
									sprintf(error, "Error : Wrong type of arguments for function %s", tmpFunctionError->name);
									break;
							}
							createError(error);
						}
					} else if (strcmp(tmpFunctionError->name, "") != 0) {
						CallTree** nodes = tmpFunctionError->nodes;
						FunctionHtItem *function = searchFunction(tmpFunctionError->name);
						if (function == NULL) {
							char* error = malloc(sizeof(char) * (strlen(tmpFunctionError->name) + 60));
							sprintf(error, "Error : Function %s not found", tmpFunctionError->name);
							createError(error);
						}

						int valid = verifyParams(function, nodes);
						if (valid != 0) {
							char* error = malloc(sizeof(char) * (strlen(name) + 60));
							switch(valid) {
								case 1:
									sprintf(error, "Error : Too many arguments for function %s", tmpFunctionError->name);
									break;
								case 2:
									sprintf(error, "Error : Too few arguments for function %s", tmpFunctionError->name);
									break;
								default:
									sprintf(error, "Error : Wrong type of arguments for function %s", tmpFunctionError->name);
									break;
							}
							createError(error);
						}
					}
					tmpFunctionError = tmpFunctionError->prev;
				}

				functionError = NULL;
				$$ = node;
			}
	|	EXTERN type IDENTIFICATEUR '(' liste_params ')' ';'
		{
			char* type = $2;
			char* name = $3;

			char filteredName[255] = "";
			strcpy(filteredName, name);
			strtok(filteredName, "(");
			
			char* nodeId = (char*) malloc(sizeof(char) * (strlen(filteredName) + strlen(type) + 20));
			sprintf(nodeId, "node_%s_%d", filteredName, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeId);

			char* nodeCode = (char*) malloc(sizeof(char) * (strlen(nodeId) + strlen(filteredName) + 60));
			sprintf(nodeCode, "\n%s [label=\"%s\" shape=polygon];\n", nodeId, filteredName);

			node.type = type;

			addCode(&node, nodeCode);

			free(nodeId);
			free(nodeCode);

			FunctionHtItem *item = (FunctionHtItem*) malloc(sizeof(FunctionHtItem));
			*item = createFunctionHtItem(name, $2, $5);
			addFunction(item);

			FunctionError *tmpFunctionError = functionError;
				while (tmpFunctionError != NULL) {
					if (strcmp(tmpFunctionError->name, name) == 0) {
						CallTree** nodes = tmpFunctionError->nodes;
						int valid = verifyParams(item, nodes);
						if (valid != 0) {
							char* error = malloc(sizeof(char) * (strlen(name) + 60));
							switch(valid) {
								case 1:
									sprintf(error, "Error : Too many arguments for function %s", tmpFunctionError->name);
									break;
								case 2:
									sprintf(error, "Error : Too few arguments for function %s", tmpFunctionError->name);
									break;
								default:
									sprintf(error, "Error : Wrong type of arguments for function %s", tmpFunctionError->name);
									break;
							}
							createError(error);
						}
					} else if (strcmp(tmpFunctionError->name, "") != 0) {
						CallTree** nodes = tmpFunctionError->nodes;
						FunctionHtItem *function = searchFunction(tmpFunctionError->name);
						if (function == NULL) {
							char* error = malloc(sizeof(char) * (strlen(tmpFunctionError->name) + 60));
							sprintf(error, "Error : Function %s not found", tmpFunctionError->name);
							createError(error);
						}

						int valid = verifyParams(function, nodes);
						if (valid != 0) {
							char* error = malloc(sizeof(char) * (strlen(name) + 60));
							switch(valid) {
								case 1:
									sprintf(error, "Error : Too many arguments for function %s", tmpFunctionError->name);
									break;
								case 2:
									sprintf(error, "Error : Too few arguments for function %s", tmpFunctionError->name);
									break;
								default:
									sprintf(error, "Error : Wrong type of arguments for function %s", tmpFunctionError->name);
									break;
							}
							createError(error);
						}
					}
					tmpFunctionError = tmpFunctionError->prev;
				}

				functionError = NULL;


			$$ = node;
		}
;
type :
		VOID { $$ = "void"; }
	|	INT  { $$ = "int"; }
;
liste_params :
		liste_params ',' param
			{
				if ($1 != NULL) $1->next = $3;
				$$ = $1;
			}
	| param
		{ $$ = $1; }
	|	{ $$ = NULL; }
;
param:
	INT IDENTIFICATEUR
		{
			char* type = "int";
			char* name = $2;

			initVar(name);
			updateVar(name, 1);

			FunctionParam *params = (FunctionParam*) malloc(sizeof(FunctionParam));
			*params = createParam(name, type);

			$$ = params;
		}
;
liste_instructions:
		liste_instructions instruction
			{
				CallTree** list = $1;
				int size = 0;
				while (list[size] != NULL) 
					size++;
				
				if (size > 100)
					list = (CallTree**) realloc(list, (size + 1) * sizeof(CallTree *));

				CallTree *node = (CallTree*) malloc(sizeof(CallTree));
				*node = $2;
				list[size] = node;
				$$ = list;
			}
	|	instruction
			{
				CallTree** list = (CallTree**) calloc(100, sizeof(CallTree*));
				CallTree *node = (CallTree*) malloc(sizeof(CallTree));
				*node = $1;
				list[0] = node;
				$$ = list;
			}
	|
			{ 
				$$ = NULL; 
			}
;
instruction :
		iteration 		{ $$ = $1; }
	|	selection 		{ $$ = $1; }
	|	saut	  		{ $$ = $1; }
	|	affectation ';' { $$ = $1; }
	|	bloc 			{ $$ = $1; }
	|	appel 			{ $$ = $1; }
;
iteration :
		FOR '(' affectation ';' condition ';' affectation ')' instruction
		{
			CallTree affectation1 = $3;
			CallTree condition = $5;
			CallTree affectation2 = $7;
			CallTree instruction = $9;


			char* nodeName = (char*) malloc(sizeof(char) * (strlen(affectation1.name) + strlen(condition.name) + strlen(affectation2.name) + 40));
			sprintf(nodeName, "node_for_%s_%s_%s_%d", affectation1.name, condition.name, affectation2.name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char *codeLien = (char*) malloc(sizeof(char) * (strlen(affectation1.name) + strlen(nodeName) + 255));
			char *codeLien2 = (char*) malloc(sizeof(char) * (strlen(condition.name) + strlen(nodeName) + 255));
			char *codeLien3 = (char*) malloc(sizeof(char) * (strlen(affectation2.name) + strlen(nodeName) + 255));
			char *codeLien4 = (char*) malloc(sizeof(char) * (strlen(instruction.name) + strlen(nodeName) + 255));

			sprintf(codeLien, "%s -> %s\n", nodeName, affectation1.name);
			sprintf(codeLien2, "%s -> %s\n", nodeName, condition.name);
			sprintf(codeLien3, "%s -> %s\n", nodeName, affectation2.name);
			sprintf(codeLien4, "%s -> %s\n", nodeName, instruction.name);

			char* code = (char*) malloc(sizeof(char) * (strlen(affectation1.code) + strlen(condition.code) + strlen(affectation2.code) + strlen(instruction.code) + strlen(codeLien) + strlen(codeLien2) + strlen(codeLien3) + strlen(codeLien4) + strlen(nodeName) + 255));
			sprintf(code, "\n%s [shape=ellipse label=\"FOR\"];\n", nodeName);
		
			strcat(code, affectation1.code);
			strcat(code, codeLien);
			strcat(code, condition.code);
			strcat(code, codeLien2);
			strcat(code, affectation2.code);
			strcat(code, codeLien3);
			strcat(code, instruction.code);
			strcat(code, codeLien4);
		
			addCode(&node, code);

			free(code);
			free(nodeName);
			free(codeLien);
			free(codeLien2);
			free(codeLien3);
			free(codeLien4);
			
			$$ = node;
		}
	|	WHILE '(' condition ')' instruction
		{
			CallTree condition = $3;
			CallTree instruction = $5;

			char* nodeName = malloc(sizeof(char) * (strlen(condition.name) + 40));
			sprintf(nodeName, "node_while_%s_%d", condition.name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char *codeLien = malloc(sizeof(char) * (strlen(nodeName) + strlen(condition.name) + 10));
			char *codeLien2 = malloc(sizeof(char) * (strlen(nodeName) + strlen(instruction.name) + 10));
			sprintf(codeLien, "%s -> %s\n", nodeName, condition.name);
			sprintf(codeLien2, "%s -> %s\n", nodeName, instruction.name);


			char* code = (char*) malloc(sizeof(char) * (strlen(condition.code) + strlen(instruction.code) + strlen(codeLien) + strlen(codeLien2) + strlen(nodeName) + 60));
			sprintf(code, "\n%s [shape=ellipse label=\"WHILE\"];\n", nodeName);

			strcat(code, condition.code);
			strcat(code, codeLien);
			strcat(code, instruction.code);
			strcat(code, codeLien2);

			addCode(&node, code);

			free(code);
			free(nodeName);
			free(codeLien);
			free(codeLien2);

			$$ = node;
		}
;
selection :
		IF '(' condition ')' instruction %prec THEN
		{
			CallTree condition = $3;
			CallTree instruction = $5;

			char* nodeName = malloc(sizeof(char) * (strlen(condition.name) + 60));
			sprintf(nodeName, "node_if_%s_%d", condition.name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char *codeLien = malloc(sizeof(char) * (strlen(nodeName) + strlen(condition.name) + 10));
			char *codeLien2 = malloc(sizeof(char) * (strlen(nodeName) + strlen(instruction.name) + 10));
			sprintf(codeLien, "%s -> %s\n", nodeName, condition.name);
			sprintf(codeLien2, "%s -> %s\n", nodeName, instruction.name);
		
			char* code = (char*) malloc(sizeof(char) * (strlen(condition.code) + strlen(instruction.code) + strlen(codeLien) + strlen(codeLien2) + strlen(nodeName) + 60));
			sprintf(code, "\n%s [shape=diamond label=\"IF\"];\n", nodeName);
			
			strcat(code, condition.code);
			strcat(code, codeLien);
			strcat(code, instruction.code);
			strcat(code, codeLien2);

			addCode(&node, code);

			free(code);
			free(nodeName);
			free(codeLien);
			free(codeLien2);
			
			$$ = node;
		}
	|	IF '(' condition ')' instruction ELSE instruction
		{
			CallTree condition = $3;
			CallTree instruction1 = $5;
			CallTree instruction2 = $7;

			char* nodeName = malloc(sizeof(char) * (strlen(condition.name) + strlen(instruction1.name) + 50));
			sprintf(nodeName, "node_if_else_%s_%s_%d", condition.name, instruction1.name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);
			

			char *codeLien = (char*) malloc(sizeof(char) * strlen(nodeName) + strlen(condition.name) + 50);
			char *codeLien2 = (char*) malloc(sizeof(char) * strlen(nodeName) + strlen(instruction1.name) + 50);
			char *codeLien3 = (char*) malloc(sizeof(char) * strlen(nodeName) + strlen(instruction2.name) + 50);

			sprintf(codeLien, "%s -> %s\n", nodeName, condition.name);
			sprintf(codeLien2, "%s -> %s\n", nodeName, instruction1.name);
			sprintf(codeLien3, "%s -> %s\n", nodeName, instruction2.name);
			
			char* code = (char*) malloc(sizeof(char) * (strlen(condition.code) + strlen(instruction1.code) + strlen(instruction2.code) + strlen(codeLien) + strlen(codeLien2) + strlen(codeLien3) + strlen(nodeName) + 60));
			sprintf(code, "\n%s [shape=diamond label=\"IF\"];\n", nodeName);

			strcat(code, condition.code);
			strcat(code, codeLien);
			strcat(code, instruction1.code);
			strcat(code, codeLien2);
			strcat(code, instruction2.code);
			strcat(code, codeLien3);

			addCode(&node, code);

			free(code);
			free(nodeName);
			free(codeLien);
			free(codeLien2);
			free(codeLien3);

			$$ = node;
		}
	|	SWITCH '(' expression ')' instruction
		{
			CallTree expression = $3;
			CallTree instruction = $5;

			char* nodeName = malloc(sizeof(char) * (strlen(expression.name) + 40));
			sprintf(nodeName, "node_switch_%s_%d", expression.name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char *codeLien = malloc(sizeof(char) * (strlen(nodeName) + strlen(expression.name) + 10));
			char *codeLien2 = malloc(sizeof(char) * (strlen(nodeName) + strlen(instruction.name) + 10));
			sprintf(codeLien, "%s -> %s\n", nodeName, expression.name);
			sprintf(codeLien2, "%s -> %s\n", nodeName, instruction.name);

			char* code = (char*) malloc(sizeof(char) * (strlen(expression.code) + strlen(instruction.code) + strlen(codeLien) + strlen(codeLien2) + strlen(nodeName) + 60));
			sprintf(code, "\n%s [shape=diamond label=\"SWITCH\"];\n", nodeName);

			strcat(code, expression.code);
			strcat(code, codeLien);
			strcat(code, instruction.code);
			strcat(code, codeLien2);

			addCode(&node, code);

			free(code);
			free(nodeName);
			free(codeLien);
			free(codeLien2);
			
			$$ = node;
		}
	|	CASE CONSTANTE ':' instruction
		{
			int constante = $2;
			CallTree instruction = $4;

			char* nodeName = malloc(sizeof(char) * (255));
			sprintf(nodeName, "node_case_%d_%d", constante, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char *codeLien = malloc(sizeof(char) * (strlen(nodeName) + strlen(instruction.name) + 255));
			sprintf(codeLien, "%s -> %d\n", nodeName, constante);

			char *codeLien2 = malloc(sizeof(char) * (strlen(nodeName) + strlen(instruction.name) + 255));
			sprintf(codeLien2, "%s -> %s\n", nodeName, instruction.name);

			char* code = (char*) malloc(sizeof(char) * (strlen(instruction.code) + strlen(codeLien) + strlen(codeLien2) + strlen(nodeName) + 255));
			sprintf(code, "\n%s [shape=ellipse label=\"CASE\"];\n", nodeName);

			strcat(code, codeLien);
			strcat(code, instruction.code);
			strcat(code, codeLien2);

			addCode(&node, code);

			free(code);
			free(nodeName);
			free(codeLien);
			free(codeLien2);

			
			$$ = node;
		}
	|	DEFAULT ':' instruction
		{
			CallTree instruction = $3;

			char* nodeName = malloc(sizeof(char) * (strlen(instruction.name) + 40));
			sprintf(nodeName, "node_default_%s_%d", instruction.name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char *codeLien = malloc(sizeof(char) * (strlen(nodeName) + strlen(instruction.name) + 10));
			sprintf(codeLien, "%s -> %s\n", nodeName, instruction.name);

			char* code = (char*) malloc(sizeof(char) * (strlen(instruction.code) + strlen(codeLien) + strlen(nodeName) + 60));
			sprintf(code, "\n%s [shape=ellipse label=\"DEFAULT\"];\n", nodeName);
			strcat(code, instruction.code);
			strcat(code, codeLien);

			addCode(&node, code);

			free(code);
			free(nodeName);
			free(codeLien);

			
			$$ = node;
		}
;
saut :
		BREAK ';'
		{
			char* nodeName = malloc(sizeof(char) * 40);
			sprintf(nodeName, "node_break_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char* code = (char*) malloc(sizeof(char) * (strlen(nodeName) + 60));
			sprintf(code, "\n%s [shape=rectangle label=\"BREAK\"];\n", nodeName);

			addCode(&node, code);

			free(code);
			free(nodeName);

			$$ = node;
		}
	 |	RETURN ';'
		{
			char* nodeName = malloc(sizeof(char) * 40);
			sprintf(nodeName, "node_return_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char* code = (char*) malloc(sizeof(char) * (strlen(nodeName) + 60));
			sprintf(code, "\n%s [shape=trapezium label=\"RETURN\" color=blue];\n", nodeName);

			addCode(&node, code);

			free(code);
			free(nodeName);


			$$ = node;
		}
	 |	RETURN expression ';'
		{
			CallTree expression = $2;

			char* nodeName = malloc(sizeof(char) * (strlen(expression.name) + 40));
			sprintf(nodeName, "node_return_%s_%d", expression.name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char *codeLien = malloc(sizeof(char) * (strlen(nodeName) + strlen(expression.name) + 40));
			sprintf(codeLien, "%s -> %s\n", nodeName, expression.name);

			char* code = (char*) malloc(sizeof(char) * (strlen(expression.code) + strlen(codeLien) + strlen(nodeName) + 60));
			sprintf(code, "\n%s [shape=trapezium label=\"RETURN\" color=blue];\n", nodeName);
			strcat(code, expression.code);
		
			strcat(code, codeLien);
			addCode(&node, code);

			free(code);
			free(nodeName);
			free(codeLien);

			
			$$ = node;
		}
;
affectation : // sous-arbres : := -> nom_var, := -> EXPR
	variable '=' expression
		{
			CallTree var = $1;
			CallTree expr = $3;
      
			if (findScope(var.var_name) == NULL) {
				char* error = malloc(sizeof(char) * (strlen(var.var_name) + 60));
				sprintf(error, "Error : The variable %s is not declared", var.var_name);
				createError(error);
			}
			
			if (expr.var_name != NULL && findScope(expr.var_name) == NULL) {
				char* error = malloc(sizeof(char) * (strlen(expr.var_name) + 60));
				sprintf(error, "Error : The variable %s is not declared", expr.var_name);
				createError(error);
			}
      
	  		if (strcmp(var.type, "int") == 0) updateVar(var.var_name, expr.value);
			else updateListVar(var.var_name, var.indexes, expr.value);
			
			char* nodeName = malloc(sizeof(char) * (strlen(var.name) + strlen(expr.name) + 60));
			sprintf(nodeName, "node_affect_%s_%s_%d", var.name, expr.name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			char* code2 = (char*) malloc(sizeof(char) * (strlen(var.name) + strlen(nodeName) + 60));
			sprintf(code2, "%s -> %s\n", nodeName, var.name);

			char* code3 = (char*) malloc(sizeof(char) * (strlen(expr.name) + strlen(nodeName) + 60));
			sprintf(code3, "%s -> %s\n", nodeName, expr.name);

			char* code = (char*) malloc(sizeof(char) * (strlen(var.code) + strlen(expr.code) + strlen(code2) + strlen(code3) + strlen(nodeName) + 60));
			sprintf(code, "\n%s [label=\":=\" shape=ellipse];\n", nodeName);
			
			strcat(code, var.code);
			strcat(code, code2);
			strcat(code, expr.code);
			strcat(code, code3);

			CallTree node = createCallTree(nodeName);

			addCode(&node, code);

			free(code);
			free(nodeName);
			free(code2);
			free(code3);


			$$ = node;
		}
;
bloc :
	'{' liste_declarations liste_instructions '}'	// node BLOC
		{
			char* nodeName = malloc(sizeof(char) * 40);
			sprintf(nodeName, "node_bloc_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			CallTree** list = $3;
			int size = 0;
			while (list[size] != NULL) size++;
			

			char* code = (char*) malloc(sizeof(char) * (strlen(nodeName) + 255));
			sprintf(code, "\n%s [shape=ellipse label=\"BLOC\"];\n", nodeName);
			*nodeIndex = *nodeIndex + 1;
			
			for (int i = 0; i < size; i++) {

				char* tmp = malloc(sizeof(char) * (strlen(code) + strlen(list[i]->code) + strlen(node.name) + strlen(list[i]->name) + 60));
				sprintf(tmp, "%s%s%s -> %s\n", code, list[i]->code, node.name, list[i]->name);
				free(code);
				code = tmp;
			}

			addCode(&node, code);

			free(code);
			free(nodeName);

			$$ = node;
		}
;
appel :
	IDENTIFICATEUR '(' liste_expressions ')' ';'
	{
		char *str = extractVarName($1);

		CallTree** list = $3;

		FunctionHtItem *function = searchFunction(str);
		FunctionError *tmp = functionError;
		functionError = (FunctionError*) malloc(sizeof(FunctionError));
		if (function == NULL) {
			char* error = malloc(sizeof(char) * (strlen(str) + 60));
			sprintf(error, "Error : Function \"%s\" not declared", str);
			functionError->message = (char*) malloc(sizeof(char) * (strlen(error) + 1));
			strcpy(functionError->message, error);
		} else {
			functionError->message = "";
		}

		functionError->name = (char*) malloc(sizeof(char) * (strlen(str) + 1));
		strcpy(functionError->name, str);
		int size = 0;
		while (list[size] != NULL) size++;

		CallTree** nodes = (CallTree**) calloc(size + 1, sizeof(CallTree*));
		memcpy(nodes, list, (size + 1) * sizeof(CallTree *));
		functionError->nodes = nodes;
		functionError->prev = tmp;

		char *nodeName = (char*) malloc(sizeof(char) * (strlen(str) + 50));
		sprintf(nodeName, "node_appel_%s_%d", str, *nodeIndex);
		*nodeIndex = *nodeIndex + 1;

		CallTree node = createCallTree(nodeName);

		char* code = (char*) malloc(sizeof(char) * (strlen(str) + strlen(nodeName) + 255));
		sprintf(code, "\n%s [shape=septagon label=\"%s\"];\n", nodeName, str);

		for (int i = 0; i < size; i++) {
			char* codeLien = (char *) malloc(sizeof(char) * (strlen(str) + strlen(list[i]->name) + 40));
			sprintf(codeLien, "%s -> %s\n", nodeName, list[i]->name);

			char* tmp = malloc(sizeof(char) * (strlen(code) + strlen(list[i]->code) + strlen(codeLien) + 60));
			sprintf(tmp, "%s%s%s", code, list[i]->code, codeLien);

			
			free(code);
			free(codeLien);
			code = tmp;
		}

		addCode(&node, code);

		free(code);
		free(nodeName);

		$$ = node;
	}
;
variable:
		IDENTIFICATEUR
			{
				char* str = extractVarName($1);
        
				char* nodeName = (char*) malloc(sizeof(char) * (strlen(str) + 50));
				sprintf(nodeName, "node_var_%s_%d", str, *nodeIndex);
				*nodeIndex = *nodeIndex + 1;

				CallTree node = createCallTree(nodeName);
				node.var_name = strdup(str);
				node.type = "int";

				int value = symbolVal(str);
				addValue(&node, value);

				char* code = malloc(sizeof(char) * (strlen(nodeName) + strlen(str) + 60));
				sprintf(code, "\n%s [shape=ellipse label=\"%s\"];\n", nodeName, str);
				addCode(&node, code);

				free(code);
				free(nodeName);
				free(str);

				$$ = node;
			}
	|	variable liste_indexes
		{
			CallTree var = $1;

			char *str = (char*) malloc(sizeof(char) * strlen(var.var_name) + 10);
			strcpy(str, var.var_name);

			char *nodeName = (char*) malloc(sizeof(char) * strlen(str) + 20);
			sprintf(nodeName, "node_var_%s_%d", str, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);
			node.var_name = strdup(str);
			node.type = "int List";
      
      		int *indexes = $2;
     		int size = 0;
			while (indexes[size] != -1) size++;

			char* codeLien = malloc(sizeof(char) * (strlen(nodeName) + strlen(var.name) + 255));
			sprintf(codeLien, "%s%s -> %s;\n", var.code, nodeName, var.name);

			for (int i = 0; i < size; i++) {
				char* indexName = (char*)malloc(sizeof(char) * 255);
				sprintf(indexName, "node_index_%d_%d", indexes[i], *nodeIndex);

				char* index = (char*) malloc(sizeof(char) * (strlen(indexName) + strlen(nodeName) + 255));
				*nodeIndex = *nodeIndex + 1;
				sprintf(index, "%s [shape=ellipse label=\"%d\"];\n%s -> %s;\n", indexName, indexes[i], nodeName, indexName);
				codeLien = realloc(codeLien, sizeof(char) * (strlen(codeLien) + strlen(index)  + 60));
				strcat(codeLien, index);
			}

			char* code = malloc(sizeof(char) * (strlen(nodeName) + strlen(codeLien) + 60));
			sprintf(code, "\n%s [shape=ellipse label=\"TAB\"];\n", nodeName);
			strcat(code, codeLien);

			addCode(&node, code);

			free(code);
			free(codeLien);
			free(nodeName);
			free(str);

			addIndex(&node, indexes);


			int value = tableValue(str, indexes);
			addValue(&node, value);

			free(indexes);

			$$ = node;
		}
;
expression:	// var et const = node, binop = sous arbre
		'(' expression ')' { $$ = $2;}
	|	expression binary_op expression %prec OP
		{
			char *nodeName = (char*) malloc(sizeof(char) * 40);
			sprintf(nodeName, "node_expr_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			CallTree child1 = $1;
			CallTree child2 = $3;

			char *tmp = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen(child1.name) + 10));
			sprintf(tmp, "%s -> %s\n", nodeName, child1.name);

			char *tmp2 = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen(child2.name) + 10));
			sprintf(tmp2, "%s -> %s\n", nodeName, child2.name);

			char *code = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen($2) + strlen(child1.code) + strlen(child2.code) + strlen(tmp) + strlen(tmp2) + 60));
			sprintf(code, "\n%s [shape=ellipse label=\"%s\"];\n", nodeName, $2);
			strcat(code, child1.code);
			strcat(code, tmp);
			strcat(code, child2.code);
			strcat(code, tmp2);

			addCode(&node, code);

			int value = parseOperation(child1.value, child2.value, $2);

			node.type = "int";

			addValue(&node, value);

			free(code);
			free(tmp);
			free(tmp2);
			free(nodeName);


			$$ = node; 
		}
	|	MOINS expression
		{
			char *nodeName = (char*) malloc(sizeof(char) * 40);
			sprintf(nodeName, "node_expr_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);
			CallTree child = $2;

			char *tmp = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen(child.name) + 30));
			sprintf(tmp, "%s -> %s\n", nodeName, child.name);

			char *code = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen(child.code) + strlen(tmp) + 60));
			sprintf(code, "\n%s [shape=ellipse label=\"-\"];\n", nodeName);
			strcat(code, child.code);
			strcat(code, tmp);

			addCode(&node, code);

			int value = -child.value;
			addValue(&node, value);

			node.type = child.type;

			free(code);
			free(tmp);
			free(nodeName);

			$$ = node;
		}
	|	CONSTANTE
		{
			char *nodeName = (char*) malloc(sizeof(char) * 20);
			sprintf(nodeName, "node_%d_%d", $1, *nodeIndex);
			
			CallTree node = createCallTree(nodeName);

			char *code = (char*) malloc(sizeof(char) * (strlen(nodeName) + 40));
			sprintf(code, "\n%s [shape=ellipse label=\"%d\"];\n", nodeName, $1);
			addCode(&node, code);
			addValue(&node, $1);
			node.type = "int";

			free(code);
			free(nodeName);
			
			
			$$ = node;
		}
	|	variable
		{
			CallTree node = $1;
			if (strcmp(node.type, "int") == 0) {
				if (symbolIsDeclared(node.var_name) == 0) {
					char* error = (char*) malloc(sizeof(char) * (strlen(node.var_name) + 255));
					sprintf(error, "Error : The variable %s is not declared!", node.var_name);
					createError(error);
				}

				if (symbolhasValue(node.var_name) == 0){
					printf("val : %d\n", symbolVal(node.var_name));
					char* error = (char*) malloc(sizeof(char) * (strlen(node.var_name) + 255));
					sprintf(error, "Error : The variable %s has no value!", node.var_name);
					createError(error);
				}
			}

			if (strcmp(node.type, "int List") == 0) {
				if (symbolIsDeclared(node.var_name) == 0) {
					char* error = (char*) malloc(sizeof(char) * (strlen(node.var_name) + 255));
					sprintf(error, "Error : The variable %s is not declared!", node.var_name);
					createError(error);
				}

				if (strcmp(node.type, "int List") == 0 && tableitemHasValue(node.var_name, node.indexes) == 0) {
					char* error = (char*) malloc(sizeof(char) * (strlen(node.name) + 255));
					sprintf(error, "Error : The array has %s no value at specified indexes!", node.var_name);
					createError(error);
				}
			}

			$$ = node;
		}
	|	IDENTIFICATEUR '(' liste_expressions ')'
		{
			char *nodeName = (char*) malloc(sizeof(char) * (strlen($1) + 40));
			sprintf(nodeName, "node_appel_%s_%d", $1, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree** list = $3;
			int size = 0;
			while (list[size] != NULL) size++;

			CallTree node = createCallTree(nodeName);

			char* code = (char*) malloc(sizeof(char) * (strlen($1) + strlen(nodeName) + 60));
			sprintf(code, "\n%s [shape=septagon label=\"%s\"];\n", nodeName, $1);

			for (int i = 0; i < size; i++) {
				char* codeLien = malloc(sizeof(char) * (strlen($1) + strlen(list[i]->name) + 40));
				sprintf(codeLien, "%s -> %s\n", nodeName, list[i]->name);

				char* tmp = malloc(sizeof(char) * (strlen(code) + strlen(list[i]->code) + strlen(codeLien) + 60));
				sprintf(tmp, "%s%s%s", code, list[i]->code, codeLien);
				
				free(code);
				free(codeLien);

				code = tmp;
			}

			addCode(&node, code);

			FunctionHtItem *function = searchFunction($1);
			FunctionError *tmp = functionError;
			functionError = (FunctionError*) malloc(sizeof(FunctionError));
			if (function == NULL) {
				char* error = malloc(sizeof(char) * (strlen($1) + 60));
				sprintf(error, "Error : Function \"%s\" not declared", $1);
				functionError->message = (char*) malloc(sizeof(char) * (strlen(error) + 1));
				strcpy(functionError->message, error);
			} else {
				functionError->message = "";
				node.type = function->type;
			}
			functionError->name = (char*) malloc(sizeof(char) * (strlen($1) + 1));
			strcpy(functionError->name, $1);
			CallTree** nodes = (CallTree**) calloc(size + 1, sizeof(CallTree*));
			for (int i = 0; i < size; i++) {
				nodes[i] = list[i];
			}
			functionError->nodes = nodes;
			functionError->prev = tmp;

			addValue(&node, 0);

			free(code);
			free(nodeName);

			$$ = node;
		}
;
liste_expressions :
		liste_expressions ',' expression
		{
			CallTree** list = $1;
			int size = 0;
			while (list[size] != NULL) size++;

			list = realloc(list, (size + 3) * sizeof(CallTree *));
			CallTree* tmp = (CallTree*) malloc(sizeof(CallTree));
			*tmp = $3;
			list[size] = tmp;
			list[size + 1] = NULL;

			$$ = list;
		}
	| 	expression
		{
			CallTree** list = (CallTree**) calloc(2, sizeof(CallTree *));
			CallTree* tmp = (CallTree*) malloc(sizeof(CallTree));
			*tmp = $1;
			list[0] = tmp;
			list[1] = NULL;
			$$ = list;
		}
	|	{ $$ = (CallTree**) calloc(1, sizeof(CallTree *)); }
;
condition :
		NOT '(' condition ')'
		{
			char *nodeName = (char*) (malloc(sizeof(char) * 40));
			sprintf(nodeName, "node_not_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			CallTree condition_1 = $3;

			char *tmp = (char*) malloc(sizeof(char) * (strlen(condition_1.name) + strlen(nodeName) + 30));
			sprintf(tmp, "%s -> %s;\n", nodeName, condition_1.name);

			char *code = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen(condition_1.code) + strlen(tmp) + 60));
			sprintf(code, "\n%s [shape=ellipse label=\"NOT\"];\n", nodeName);

			strcat(code, condition_1.code);
			strcat(code, tmp);

			addCode(&node, code);

			free(code);
			free(tmp);
			free(nodeName);


			$$ = node;
		 }
	|	condition binary_rel condition %prec REL
		{ 
			char *nodeName = (char*) malloc(sizeof(char) * 30);
			sprintf(nodeName, "node_rel_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;
			
			CallTree node = createCallTree(nodeName);
			
			CallTree condition_1 = $1;
			CallTree condition_2 = $3;


			char *tmp = (char*) malloc(sizeof(char) * (strlen(condition_1.name) + strlen(nodeName) + 20));
			sprintf(tmp, "%s -> %s;\n", nodeName, condition_1.name);

			char *tmp2 = (char*) malloc(sizeof(char) * (strlen(condition_2.name) + strlen(nodeName) + 20));
			sprintf(tmp2, "%s -> %s;\n", nodeName, condition_2.name);

			char *code = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen(condition_1.code) + strlen(condition_2.code) + strlen(tmp) + strlen(tmp2) + 60));
			sprintf(code, "\n%s [shape=ellipse label=\"%s\"];\n", nodeName, $2);
			strcat(code, condition_1.code);
			strcat(code, tmp);
			strcat(code, condition_2.code);
			strcat(code, tmp2);

			addCode(&node, code);

			free(code);
			free(tmp);
			free(tmp2);
			free(nodeName);

			$$ = node;
		}
	|	'(' condition ')' { $$ = $2; }
	|	expression binary_comp expression 
		{ 
			char *nodeName = (char*) malloc(sizeof(char) * 40);
			sprintf(nodeName, "node_comp_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);
		

			CallTree condition_1 = $1;
			CallTree condition_2 = $3;


			char* tmp = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen(condition_1.name) + 30));
			sprintf(tmp, "%s -> %s;\n", nodeName, condition_1.name);
			
			char* tmp2 = (char*) malloc(sizeof(char) * (strlen(condition_2.name) + strlen(nodeName) + 30));
			sprintf(tmp2, "%s -> %s;\n", nodeName, condition_2.name);

			char *code = (char*) malloc(sizeof(char) * (strlen($2) + strlen(nodeName) + strlen(condition_1.code) + strlen(condition_2.code) + strlen(tmp) + strlen(tmp2) + 60));
			sprintf(code, "\n%s [shape=ellipse label=\"%s\"];\n", nodeName, $2);

			strcat(code, condition_1.code);
			strcat(code, tmp);
			strcat(code, condition_2.code);
			strcat(code, tmp2);
			addCode(&node, code);

			free(code);
			free(tmp);
			free(tmp2);
			free(nodeName);

			$$ = node;
		}
;
binary_op :	
		PLUS 	{ $$ = "+"; }
	|   MOINS	{ $$ = "-"; }
	|	MUL 	{ $$ = "*"; }
	|	DIV 	{ $$ = "/"; }
	|   LSHIFT	{ $$ = "<<"; }
	|   RSHIFT	{ $$ = ">>"; }
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



