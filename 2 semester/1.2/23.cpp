/*
//Лабораторная работа №1.2
//12.02.2012
*/

#include <stdio.h>
#include <stdlib.h>

int main() {
    const int MAX = 10;
    int m = 2, n = 1;

    for(int i = 0; i < MAX; i++, m++, n++)
        printf("%d^2 + %d^2 = %d^2\n", (m*m - n*n), (2 * m * n), (m*m + n*n)); // Строка вывода: "3^2 + 4^2 = 5^2"

    system("pause"); 
}