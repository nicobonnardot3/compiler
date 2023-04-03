ANSI-C: lex.yy.c y.tab.c
	gcc -g lex.yy.c hashTable/HashTable.c y.tab.c  -o parser.out

lex.yy.c: y.tab.c ANSI-C.l
	lex ANSI-C.l

y.tab.c: miniC.y
	yacc -d miniC.y

clean: 
	rm -rf lex.yy.c y.tab.c y.tab.h parser.out
