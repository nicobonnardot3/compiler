CFLAGS=-D_FORTIFY_SOURCE=2 -Wno-int-conversion -Wformat -Wunused-function -fasynchronous-unwind-tables -fstack-clash-protection -O2 -Wall
DEBUG_FLAGS=-g -fsanitize=address
DEBUG_ENV=LSAN_OPTION=verbosity=1:log_threads=1

all: debug

parser.out: clean lex.yy.c y.tab.c
	gcc $(CFLAGS) -o parser.out main.c callTree/CallTree.c hashTable/HashTable.c y.tab.c lex.yy.c -ll

debug: clean lex.yy.c y.tab.c
	$(DEBUG_ENV); gcc $(CFLAGS) $(DEBUG_FLAGS) -o parser.out main.c callTree/CallTree.c hashTable/HashTable.c y.tab.c lex.yy.c -ll

lex.yy.c: y.tab.c ANSI-C.l
	lex -o lex.yy.c ANSI-C.l

y.tab.c: miniC.y
	yacc -o y.tab.c -d miniC.y -d -Wno-yacc

clean:
	rm -rf lex.yy.c y.tab.c y.tab.h parser.out
