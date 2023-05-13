CFLAGS=-ll -Wall -Wno-return-type -Wno-unused-function -Wno-int-conversion -Wformat -D_FORTIFY_SOURCE=2 -fasynchronous-unwind-tables -fstack-clash-protection -O2
DEBUG_FLAGS=-g
# -fsanitize=address
DEBUG_ENV=LSAN_OPTION=verbosity=1:log_threads=1
FILES=main.c callTree/CallTree.c hashTable/HashTable.c functionHashTable/functionHashTable.c y.tab.c lex.yy.c

parser.out: clean lex.yy.c y.tab.c
	gcc $(CFLAGS) -o minigcc $(FILES)

debug: clean lex.yy.c y.tab.c
	$(DEBUG_ENV); gcc $(CFLAGS) $(DEBUG_FLAGS) -o minigcc $(FILES)

lex.yy.c: y.tab.c ANSI-C.l
	lex -o lex.yy.c ANSI-C.l

y.tab.c: miniC.y
	yacc -o y.tab.c -d miniC.y -d -Wno-yacc -Wno-conflicts-sr

clean:
	rm -f lex.yy.c y.tab.c y.tab.h minigcc
