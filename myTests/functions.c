extern void printd(int i);

int aux(int a, int b) { return a / b; }

int loop(int a, int b) {
    int i;
    for (i = 0; i < 10; i = i + 1) { a = a + b; }
    return a;
}

int fact(int n) {
    if (n <= 1) return 1;
    return n * fact(n - 1);
}

int main() {
    int a;
    int b;
    a = 10;
    b = 2;
    printd(aux(a, b));
    printd(loop(a, b));
    return aux(a, b) + loop(a, b) + fact();
}


int test() { main(); }
