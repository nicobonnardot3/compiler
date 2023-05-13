extern int printd(int a);

int main() {
    int i;
    for (i = 0; i < 10; i = i + 1) printd(i);

    i = 0;
    while (i < 10) {
        printd(i);
        i = i + 1;
    }

    return 0;
}