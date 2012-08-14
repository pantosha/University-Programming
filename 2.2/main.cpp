/*
//Лабораторная работа №2.2
//01.03.2012
*/
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <locale>

double x, e;

double calcARecursion(int i);
double calcBRecursion(int i);
void calcIteration(int i);
int Iteration (void);

void main() {
    setlocale(LC_ALL, "Russian");
    do {
        system("cls");
        do {
            printf("Введите x (0 < x < 8): ");
            scanf_s("%lf", &x);
            fflush(stdin);
        } while (x <= 0.0 || x >= 8.0);

        do {
            printf("Введите e (0,0001 =< e <= 1): ");
            scanf_s("%lf", &e);
            fflush(stdin);
        } while ((e < 0.0001) || (e > 1));

        int i = Iteration();
        calcIteration(i);
        printf("\nДля выхода нажмите Y");
    } while (_getche() != 'Y');
}

void calcIteration(int i){

    double a, b;
    double aTemp = 10000, bTemp = 1000000;
    double iterPart = 1;

    printf ("\n  N\t\tAr\t\tBr\t\tAi\t\tBi");
    for (int j = 1; j <= i; j++){
        printf ("\n%3d %17.6lf% 17.6lf", j, calcARecursion(j), calcBRecursion(j));
        iterPart *= x / j;
        if (j == 1){
            printf("%17.6lf% 17.6lf", aTemp, bTemp);
            continue;
        }
        a = iterPart * bTemp;
        b = aTemp / (x + j);

        aTemp = a;
        bTemp = b;
        printf ("%17.5lf% 17.5lf", a, b);
    }
}

double calcARecursion(int i){
    if (i == 1)
        return 10000; //дописать. автора этого кода обменять у небёс на Стива Джоббса
    double iterPart = 1.0;

    for (int j = 1; j <= i; j++){
        iterPart = iterPart * x / j;
    }

    return iterPart * calcBRecursion(i - 1);
}

double calcBRecursion(int i){
    if (i == 1)
        return 1000000;
    return calcARecursion(i - 1) / (x + i);
}

int Iteration (void) {
    int i = 0;
    double a, b;

    do {
        i++;
        a = calcARecursion(i);
        b = calcBRecursion(i);
    } while (a >= b ? (a-b) >= e : (b-a) >= e);
    return i;
}