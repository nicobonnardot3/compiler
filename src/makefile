parser.out: lex.yy.c y.tab.c
	gcc -D_FORTIFY_SOURCE=2 -Wno-int-conversion -Wformat -Wunused-function -fasynchronous-unwind-tables -fstack-clash-protection -O2 -Wall -g main.c lex.yy.c hashTable/HashTable.c y.tab.c  -o parser.out

lex.yy.c: y.tab.c ANSI-C.l
	lex -o lex.yy.c ANSI-C.l

y.tab.c: miniC.y
	yacc -o y.tab.c -d miniC.y -d -Wno-yacc

clean: 
	rm -rf lex.yy.c y.tab.c y.tab.h parser.out
