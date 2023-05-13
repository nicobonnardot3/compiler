/* TEST TABLEAUX MULTIDIMENSIONNELS MINIC */

int tab[3][4][5][10];
int tab2[10][3];

int main() {
    tab2[0][1] = 4;
    tab[0][1][2][7] = 4;
    tab[1][2][3][4] = (tab[0][1][2][7] - tab2[0][1]);

    return tab[1][2][3][4];
}