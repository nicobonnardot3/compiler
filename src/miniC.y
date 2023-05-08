
%code requires {
	#include "callTree/CallTree.h"
}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hashTable/HashTable.h"

// ----- Vars -----
extern struct CallTree* tree;
extern struct CallTree** functionTree;

extern int* *nodeIndex;
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

%type <calltree> appel "appel" condition "condition" instruction "instruction" affectation "affectation" iteration "iteration" selection "selection" saut "saut" bloc "bloc" expression "expression" declarateur "declarateur" fonction "fonction"
%type <calltree_list> liste_expressions "liste_expressions" liste_instructions "liste_instructions" declaration "declaration" liste_declarateurs "declarateurs" liste_declarations "declarations" liste_fonctions "fonctions"
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
	liste_declarations liste_fonctions
;
liste_declarations :
		  	liste_declarations declaration
				{
					CallTree** list = $1;

					if (list == NULL) {
						list = $2;
					} else {
						size_t size = 0;
						while (list[size] != NULL) size++;

						size_t size2 = 0;
						while ($2[size2] != NULL) size2++;

						list = (CallTree**) realloc(list, (size + size2) * sizeof(CallTree*));
						for (int i = 0; i < size2; i++) list[size + i] = $2[i];
					}
					$$ = list;
				}
		|		{ $$ = NULL; }
;
liste_fonctions :
			liste_fonctions fonction		{
												CallTree* node = $2;
												addParent(node, tree);

												size_t size = sizeof(functionTree) / sizeof(CallTree *) + 1;
												functionTree = (CallTree**) realloc(functionTree, size * sizeof(CallTree*));
												functionTree[size - 1] = node;
												$$ = functionTree;
												}
		|  	fonction						{
												CallTree* node = $1;
												addParent(node, tree);

												functionTree[0] = node;
												$$ = functionTree;
											}
;
declaration :
	type liste_declarateurs ';'
			{
				CallTree** list = $2;
				size_t size = sizeof(list) / sizeof(CallTree*);
				for (int i = 0; i < size; i++) list[i]->type = $1;
				$$ = list;
			}
;
liste_declarateurs  :
			liste_declarateurs ',' declarateur
					{
						CallTree** list = $1;
						size_t size = 0;
						while (list[size] != NULL) size++;

						list = (CallTree**) realloc(list, (size + 2) * sizeof(CallTree*));
						list[size] = $3;
						$$ = list;
					}
			|	declarateur				
					{
						CallTree** list = (CallTree**) calloc(1, sizeof(CallTree*));
						list[0] = $1;
						$$ = list;
					}
;
declarateur :
		IDENTIFICATEUR 
			{
				char* str = removeUnwantedChar($1);

				char* nodeName = (char*) malloc(sizeof(char) * (strlen(str) + 10));
				sprintf(nodeName, "node_%s_%d", str, *nodeIndex);
				*nodeIndex = *nodeIndex + 1;

				CallTree node = createCallTree(nodeName);

				char* code = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen(str) + 40));
				sprintf(code, "\n%s [shape=ellipse label=\"%s\"];", nodeName, str);
				
				addCode(&node, code);
				
				createVar(varHashTable, str, "int");

				$$ = &node;
			}
	|	declarateur_list '[' CONSTANTE ']'	
			{
				size_t size = $3;
				createList(varHashTable, $1->name, size);

				char* nodeName = (char*) malloc(sizeof(char) * (strlen($1->name) + 10));
				sprintf(nodeName, "node_%s_%d", $1->name, *nodeIndex);
				*nodeIndex = *nodeIndex + 1;

				char* code = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen($1->name) + 40));
				sprintf(code, "\n%s [shape=ellipse label=\"%s\"];", nodeName, $1->name);

				CallTree node = createCallTree(nodeName);

				addIndex(&node, $3);
				addCode(&node, code);
				
				$$ = &node;
			}
;
declarateur_list :
		IDENTIFICATEUR 
			{
				char str[255] = "";
				extractVarName(str, $1);
				
				CallTree node = createCallTree(str);
				addCode(&node, "");
				
				$$ = &node;
			}
;
fonction :	
		type IDENTIFICATEUR '(' liste_params ')' '{' liste_declarations liste_instructions '}' 
			{ // sous Arbre abstrait, chaque instruction -> fils
				char* type = $1;
				char* name = $2;

				char* filteredName = (char*) malloc(sizeof(char) * 255);
				strcpy(filteredName, name);
				strtok(filteredName, "(");

				char* nodeName = (char*) malloc(sizeof(char) * 255);
				sprintf(nodeName, "%s, %s", filteredName, type);
				
				char* nodeId = (char*) malloc(sizeof(char) * 255);
				sprintf(nodeId, "node_%s_%d", filteredName, *nodeIndex);
				*nodeIndex = *nodeIndex + 1;

				CallTree** liste_declarations = $7;
				CallTree** liste_instructions = $8;

				CallTree node = createCallTree(nodeId);

				char* nodeCode = (char*) malloc(sizeof(char) * 255);
				sprintf(nodeCode, "\n%s [label=\"%s\" shape=invtrapezium color=blue];\n", nodeId, nodeName);

				node.type = type;

				// int i = 0;
				// while (liste_declarations[i] != NULL) {
				// 	addParent(liste_declarations[i], node);

				// 	char* code = (char*) malloc(sizeof(char) * 255);
				// 	sprintf(code, "%s\n", liste_declarations[i]->code);
				// 	strcat(nodeCode, code);
				// 	i++;
				// }

				// i = 0;
				// while (liste_declarations[i] != NULL) {
				// 	char* code = (char*) malloc(sizeof(char) * 255);
				// 	sprintf(code, "%s -> %s\n", nodeId, liste_declarations[i]->name);
				// 	strcat(nodeCode, code);
				// 	i++;
				// }

				int i = 0;
				while (liste_instructions[i] != NULL) {
					addParent(liste_instructions[i], &node);

					char* code = (char*) malloc(sizeof(char) * (strlen(liste_instructions[i]->code) + 2));
					sprintf(code, "%s\n", liste_instructions[i]->code);

					char* codeLien = (char*) malloc(sizeof(char) * (strlen(liste_instructions[i]->name) + strlen(nodeId) + 5 + 1));
					sprintf(codeLien, "%s -> %s\n", nodeId, liste_instructions[i]->name);

					nodeCode = (char*) realloc(nodeCode, sizeof(char) * (strlen(nodeCode) + strlen(code) + strlen(codeLien) + 1));
					strcat(nodeCode, code);
					strcat(nodeCode, codeLien);
					i++;
				}

				addCode(&node, nodeCode);

				printf("nodeCode : %s\n", nodeCode);

				$$ = &node;
			}
	|	EXTERN type IDENTIFICATEUR '(' liste_params ')' ';' 
		{
			char* type = $2;
			char* name = $3;

			char filteredName[255] = "";
			strcpy(filteredName, name);
			strtok(filteredName, "(");
			
			char nodeId[255] = "";
			sprintf(nodeId, "node_%s_%d", filteredName, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeId);

			char nodeCode[255] = "";
			sprintf(nodeCode, "\n%s [label=\"%s\" shape=polygon];\n", nodeId, filteredName);

			node.type = type;

			addCode(&node, nodeCode);

			printf("nodeCode : %s\n", nodeCode);


			$$ = &node;
		}
;
type :	
		VOID { $$ = "void"; }
	|	INT  { $$ = "int"; }
;
liste_params :	
		liste_params ',' param
	| param
	|	
;
param :
	INT IDENTIFICATEUR
;
liste_instructions  :	
		liste_instructions instruction
			{
				CallTree** list = $1;
				size_t size = 0;
				while (list[size] != NULL) size++;

				list = (CallTree**) realloc(list, (size + 2) * sizeof(CallTree*));
				list[size] = $2;
				$$ = list;
			}
	|	instruction
			{
				CallTree** list = (CallTree**) calloc(1, sizeof(CallTree*));
				list[0] = $1;
				$$ = list;
			}
	|		{
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
			CallTree* affectation1 = $3;
			CallTree* condition = $5;
			CallTree* affectation2 = $7;
			CallTree* instruction = $9;


			char nodeName[255] = "";

			sprintf(nodeName, "node_for_%s_%s_%s_%d", affectation1->name, condition->name, affectation2->name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char code[255] = "";
			sprintf(code, "\n%s [shape=ellipse label=\"FOR\"];\n", nodeName);
			
			char codeLien[255] = "";
			char codeLien2[255] = "";
			char codeLien3[255] = "";
			char codeLien4[255] = "";

			sprintf(codeLien, "%s -> %s\n", nodeName, affectation1->name);
			sprintf(codeLien3, "%s -> %s\n", nodeName, condition->name);
			sprintf(codeLien2, "%s -> %s\n", nodeName, affectation2->name);
			sprintf(codeLien4, "%s -> %s\n", nodeName, instruction->name);
		
			strcat(code, affectation1->code);
			strcat(code, codeLien);
			strcat(code, condition->code);
			strcat(code, codeLien2);
			strcat(code, affectation2->code);
			strcat(code, codeLien3);
			strcat(code, instruction->code);
			strcat(code, codeLien4);
		
			
			addCode(&node, code);

			addParent(affectation1, &node);
			addParent(condition, &node);
			addParent(affectation2, &node);
			addParent(instruction, &node);
			
			$$ = &node;
		}
	|	WHILE '(' condition ')' instruction
		{
			CallTree* condition = $3;
			CallTree* instruction = $5;

			char nodeName[255] = "";
			sprintf(nodeName, "node_while_%s_%d", condition->name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char code[255] = "";
			sprintf(code, "\n%s [shape=ellipse label=\"WHILE\"];\n", nodeName);

			char codeLien[255] = "";
			char codeLien2[255] = "";
			sprintf(codeLien, "%s -> %s\n", nodeName, condition->name);
			sprintf(codeLien2, "%s -> %s\n", nodeName, instruction->name);

			strcat(code, condition->code);
			strcat(code, codeLien);
			strcat(code, instruction->code);
			strcat(code, codeLien2);

			addCode(&node, code);

			addParent(condition, &node);
			addParent(instruction, &node);
			
			$$ = &node;
		}
;
selection :	
		IF '(' condition ')' instruction %prec THEN
		{
			CallTree* condition = $3;
			CallTree* instruction = $5;

			char nodeName[255] = "";
			sprintf(nodeName, "node_if_%s_%d", condition->name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char code[255] = "";
			sprintf(code, "\n%s [shape=ellipse label=\"IF\"];\n", nodeName);

			char codeLien[255] = "";
			char codeLien2[255] = "";
			sprintf(codeLien, "%s -> %s\n", nodeName, condition->name);
			sprintf(codeLien2, "%s -> %s\n", nodeName, instruction->name);
		
			strcat(code, condition->code);
			strcat(code, codeLien);
			strcat(code, instruction->code);
			strcat(code, codeLien2);

			addCode(&node, code);

			addParent(condition, &node);
			addParent(instruction, &node);
			
			$$ = &node;
		}
	|	IF '(' condition ')' instruction ELSE instruction
		{
			CallTree* condition = $3;
			CallTree* instruction1 = $5;
			CallTree* instruction2 = $7;

			char nodeName[255] = "";
			sprintf(nodeName, "node_if_else_%s_%s_%d", condition->name, instruction1->name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char code[255] = "";
			sprintf(code, "\n%s [shape=diam label=\"IF\"];\n", nodeName);
			

			char codeLien[255] = "";
			char codeLien2[255] = "";
			char codeLien3[255] = "";

			sprintf(codeLien, "%s -> %s\n", nodeName, condition->name);
			sprintf(codeLien2, "%s -> %s\n", nodeName, instruction1->name);
			sprintf(codeLien3, "%s -> %s\n", nodeName, instruction2->name);

			strcat(code, condition->code);
			strcat(code, codeLien);
			strcat(code, instruction1->code);
			strcat(code, codeLien2);
			strcat(code, instruction2->code);
			strcat(code, codeLien3);

			addCode(&node, code);

			addParent(condition, &node);
			addParent(instruction1, &node);
			addParent(instruction2, &node);

			$$ = &node;
		}
	|	SWITCH '(' expression ')' instruction
		{
			CallTree* expression = $3;
			CallTree* instruction = $5;

			char nodeName[255] = "";
			sprintf(nodeName, "node_switch_%s_%d", expression->name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char code[255] = "";
			sprintf(code, "\n%s [shape=ellipse label=\"SWITCH\"];\n", nodeName);

			char codeLien[255] = "";
			char codeLien2[255] = "";
			sprintf(codeLien, "%s -> %s\n", nodeName, expression->name);
			sprintf(codeLien2, "%s -> %s\n", nodeName, instruction->name);

			strcat(code, expression->code);
			strcat(code, codeLien);
			strcat(code, instruction->code);
			strcat(code, codeLien2);

			addCode(&node, code);

			addParent(expression, &node);
			addParent(instruction, &node);
			
			$$ = &node;
		}
	|	CASE CONSTANTE ':' instruction
		{
			CallTree* constante = $2;
			CallTree* instruction = $4;

			char nodeName[255] = "";
			sprintf(nodeName, "node_case_%s_%d", constante->name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char code[255] = "";
			sprintf(code, "\n%s [shape=ellipse label=\"CASE\"];\n", nodeName);

			char codeLien[255] = "";
			sprintf(codeLien, "%s -> %s\n", nodeName, constante->name);


			strcat(code, constante->code);
			strcat(code, codeLien);
			strcat(code, instruction->code);

			addCode(&node, code);

			addParent(constante, &node);
			addParent(instruction, &node);
			
			$$ = &node;
		}
	|	DEFAULT ':' instruction
		{
			CallTree* instruction = $3;

			char nodeName[255] = "";
			sprintf(nodeName, "node_default_%s_%d", instruction->name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char code[255] = "";
			sprintf(code, "\n%s [shape=ellipse label=\"DEFAULT\"];\n", nodeName);
			strcat(code, instruction->code);

			char codeLien[255] = "";
			sprintf(codeLien, "%s -> %s\n", nodeName, instruction->name);
		
			strcat(code, codeLien);
			addCode(&node, code);

			addParent(instruction, &node);
			
			$$ = &node;
		}
;
saut :
		BREAK ';'
		{

			char nodeName[255] = "";
			sprintf(nodeName, "node_break_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char code[255] = "";
			sprintf(code, "\n%s [shape=rectangle label=\"BREAK\"];\n", nodeName);

			addCode(&node, code);

			$$ = &node;
		}
	 |	RETURN ';'
		{
			char nodeName[255] = "";
			sprintf(nodeName, "node_return_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char code[255] = "";
			sprintf(code, "\n%s [shape=trapezium label=\"RETURN\"];\n", nodeName);

			addCode(&node, code);

			$$ = &node;
		}
	 |	RETURN expression ';'
		{
			CallTree* expression = $2;

			char nodeName[255] = "";
			sprintf(nodeName, "node_return_%s_%d", expression->name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char code[255] = "";
			sprintf(code, "\n%s [shape=trapezium label=\"RETURN\"];\n", nodeName);
			strcat(code, expression->code);

			char codeLien[255] = "";
			sprintf(codeLien, "%s -> %s\n", nodeName, expression->name);
		
			strcat(code, codeLien);
			addCode(&node, code);

			addParent(expression, &node);
			
			$$ = &node;
		}
;
affectation :	// sous-arbres : := -> nom_var, := -> EXPR
	variable '=' expression
		{
			CallTree* expr = $3;
			CallTree* var = $1;

			char nodeName[255] = "";
			sprintf(nodeName, "node_affect_%s_%s_%d", var->name, expr->name, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			char code[255] = "";
			sprintf(code, "\n%s [label=\":=\" shape=ellipse];\n", nodeName);

			strcat(code, var->code);

			char code2[255] = "";
			sprintf(code2, "%s -> %s\n", nodeName, var->name);
			strcat(code, code2);

			strcat(code, expr->code);

			char code3[255] = "";
			sprintf(code3, "%s -> %s\n", nodeName, expr->name);
			strcat(code, code3);

			addCode(&node, code);

			addParent(var, &node);
			addParent(expr, &node);


			$$ = &node;
		}
;
bloc :
	'{' liste_declarations liste_instructions '}'	// node BLOC
		{
			char nodeName[255] = "";
			sprintf(nodeName, "node_bloc_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			CallTree** list = $2;
			size_t size = sizeof(list) / sizeof(CallTree*);

			for (int i = 0; i < size; i++) {
				addParent(list[i], &node);
			}

			list = $3;
			size = sizeof(list);

			char code[255] = "";
			sprintf(code, "subgraph cluster_0 {\nnode_BLOC [shape=ellipse label=\"BLOC\"];\n");
			
			char codeLien[255] = "";
			for (int i = 0; i < size; i++) {
				addParent(list[i], &node);
				strcat(code, list[i]->code);

				char str[255] = "";
				sprintf(str, "%s -> %s\n", node.name, list[i]->name);
				strcat(codeLien, str);
			}
			
			printf("liens: %s\n", codeLien);
			if (size > 0) {
				strcat(code, codeLien);
			}

			strcat(code, "}\n");
			addCode(&node, code);

			printf("BLOC: %s\n", node.code);

			$$ = &node;
		}
;
appel :
	IDENTIFICATEUR '(' liste_expressions ')' ';'
	{
		char str[255] = "";
		extractVarName(str, $1);

		char nodeName[255] = "";
		sprintf(nodeName, "node_appel_%s_%d", str, *nodeIndex);
		*nodeIndex = *nodeIndex + 1;

		CallTree node = createCallTree(str);

		CallTree** list = $3;
		size_t size = sizeof(list) / sizeof(CallTree*);

		char code[255] = "";
		char codeLien[255] = "";
		sprintf(code, "\n%s [shape=polygon label=\"%s\"];\n", str, nodeName);

		for (int i = 0; i < size; i++) {
			addParent(list[i], &node);
			strcat(code, list[i]->code);
			char str[255] = "";
			sprintf(str, "%s -> %s\n", str, list[i]->name);
			strcat(code, str);
		}

		strcat(code, codeLien);
		addCode(&node, code);
		
		$$ = &node;
	}
;
variable :
		IDENTIFICATEUR
			{
				char str[255] = "";
				extractVarName(str, $1);

				char nodeName[255] = "";
				sprintf(nodeName, "node_var_%s_%d", str, *nodeIndex);
				*nodeIndex = *nodeIndex + 1;

				CallTree node = createCallTree(nodeName);

				int value = symbolVal(varHashTable, str);
				addValue(&node, value);

				char* code = malloc(sizeof(char) * (strlen(nodeName) + strlen(str) + 40));
				sprintf(code, "\n%s [shape=ellipse label=\"%s\"];\n", nodeName, str);
				addCode(&node, code);

				printf("var--: %s\n", node.code);
				// printTree(&node);

				$$ = &node;
			}
	|	variable '[' expression ']' 
		{
			char str[255] = "";
			strcpy(str, $1->name);

			char nodeName[255] = "";
			sprintf(nodeName, "node_var_%s_%d", str, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);

			int index = $3;

			addCode(&node, "");
			addIndex(&node, index);

			$$ = &node;
		}
;
expression  :	// var et const = node, binop = sous arbre
		'(' expression ')' { $$ = $2;}
	|	expression binary_op expression %prec OP	
		{
			char nodeName[255] = "";
			sprintf(nodeName, "node_expr_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);
			
			char code[255] = "";
			sprintf(code, "\n%s [shape=ellipse label=\"%s\"];\n", nodeName, $2);

			CallTree* child1 = $1;
			CallTree* child2 = $3;

			strcat(code, child1->code);
			char tmp[255] = "";
			sprintf(tmp, "%s -> %s\n", nodeName, child1->name);
			strcat(code, tmp);

			strcat(code, child2->code);
			char tmp2[255] = "";
			sprintf(tmp2, "%s -> %s\n", nodeName, child2->name);
			strcat(code, tmp2);

			addCode(&node, code);

			addParent(&node, $1);
			addParent(&node, $3);
			$$ = &node; 
		}
	|	MOINS expression
		{
			char nodeName[255] = "";
			sprintf(nodeName, "node_expr_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);
			
			char code[255] = "";
			sprintf(code, "\n%s [shape=ellipse label=\"-\"];\n", nodeName);

			CallTree* child = $2;

			strcat(code, child->code);
			char tmp[255] = "";
			sprintf(tmp, "%s -> %s\n", nodeName, child->name);
			strcat(code, tmp);

			addCode(&node, code);

			addParent(&node, $2);
			$$ = &node;
		}
	|	CONSTANTE
		{
			char nodeName[100] = "";
			sprintf(nodeName, "node_%d_%d", $1, *nodeIndex);
			
			CallTree node = createCallTree(nodeName);

			char str[255] = "";
			sprintf(str, "\n%s [shape=ellipse label=\"%d\"];", nodeName, $1);
			addCode(&node, str);
			addValue(&node, $1);
			
			$$ = &node; 
		}
	|	variable
		{
			printf("var-expr: %s\n", $1->name);
			$$ = $1;
		}
	|	IDENTIFICATEUR '(' liste_expressions ')'
		{
			// if(!isFunction($1)){
			// 	ajouteErreur(zebi);
			// }

			char nodeName[255] = "";
			sprintf(nodeName, "node_appel_%s_%d", $1, *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);
			addCode(&node, "");
			$$ = &node;
		}
;
liste_expressions :
		liste_expressions ',' expression
		{
			CallTree** list = $1;
			size_t size = 0;
			while (list[size] != NULL) size++;

			list = realloc(list, (size + 2) * sizeof(CallTree*));
			list[size] = $3;

			$$ = list;
		}
	| 	expression
		{
			CallTree** list = (CallTree**) calloc(1, sizeof(CallTree*));
			list[0] = $1;
			$$ = list;
		}
;
condition :	
		NOT '(' condition ')'
		{ 
			char nodeName[255] = "";
			sprintf(nodeName, "node_not_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);
			
			char code[255] = "";
			sprintf(code, "\n%s [shape=ellipse label=\"NOT\"];\n", nodeName);

			CallTree* condition_1 = $3;

			strcat(code, condition_1->code);
			char tmp[255] = "";
			sprintf(tmp, "%s -> %s;\n", nodeName, condition_1->name);
			strcat(code, tmp);

			addCode(&node, code);

			addParent(&node, $3);
			$$ = &node;
		 }
	|	condition binary_rel condition %prec REL
		{ 
			char nodeName[255] = "";
			sprintf(nodeName, "node_rel_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;
			
			CallTree node = createCallTree(nodeName);
			
			char code[255] = "";
			sprintf(code, "\n%s [shape=ellipse label=\"%s\"];\n", nodeName, $2);

			CallTree* condition_1 = $1;
			CallTree* condition_2 = $3;


			strcat(code, condition_1->code);
			char tmp[255] = "";
			sprintf(tmp, "%s -> %s;\n", nodeName, condition_1->name);
			strcat(code, tmp);

			strcat(code, condition_2->code);
			char *tmp2 = (char*) malloc(sizeof(char));
			sprintf(tmp2, "%s -> %s;\n", nodeName, condition_2->name);
			strcat(code, tmp2);

			addCode(&node, code);

			addParent(&node, $1);
			addParent(&node, $3);
			$$ = &node;
		}
	|	'(' condition ')' { $$ = $2; }
	|	expression binary_comp expression 
		{ 
			char *nodeName = (char*) malloc(sizeof(char) * 20);
			sprintf(nodeName, "node_not_%d", *nodeIndex);
			*nodeIndex = *nodeIndex + 1;

			CallTree node = createCallTree(nodeName);
			
			char *code = (char*) malloc(sizeof(char) * (strlen($2) + strlen(nodeName) + 40));
			sprintf(code, "\n%s [shape=ellipse label=\"%s\"];\n", nodeName, $2);

			CallTree* condition_1 = $1;
			CallTree* condition_2 = $3;

			strcat(code, condition_1->code);

			char* tmp = (char*) malloc(sizeof(char) * (strlen(nodeName) + strlen(condition_1->name) + 15));
			sprintf(tmp, "%s -> %s;\n", nodeName, condition_1->name);
			strcat(code, tmp);
			
			strcat(code, condition_2->code);
			char* tmp2 = (char*) malloc(sizeof(char) * (strlen(condition_2->name) + strlen(nodeName)) + 15);

			sprintf(tmp2, "%s -> %s;\n", nodeName, condition_2->name);
			strcat(code, tmp2);

			addCode(&node, code);

			addParent(&node, $1);
			addParent(&node, $3);
			$$ = &node;
		}
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
