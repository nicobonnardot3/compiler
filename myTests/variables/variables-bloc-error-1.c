int main() {
    int a, c;

    a = 10;
    c = a;

    {
        int b;
        b = 20;
        c = b;
    }

    return b;
}

int test() { return a; }