int loop(int a, int b) {
    int i;
    for (i = 0; i < 10; i = i + 1) { a = a + b; }
    return a;
}

int main() {
    loop(a, b, 23);
    return 0;
}