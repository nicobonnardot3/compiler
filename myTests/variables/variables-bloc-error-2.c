int main() {
    int a, c;

    a = 10;

    {
        int b;
        b = 20;
        c = b;
    }

    return c;
}

int test() { return a; }