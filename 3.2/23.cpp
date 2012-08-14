/*
//������������ ������ �3.2
//20.03.2012
*/

#include <stdio.h>
#include <stdlib.h>
#include <locale>
#include <conio.h>

void showStatusBar(int rows, int cols);
void showMenu(int rows, int cols);
int getValue(char String[], int min, int max);
char** initArray(int rows, int cols);
void printArray(char **pArray, int rows, int cols);
int getElement(int i, int j);
int odd(int a);
void printMinus(int cols);

void main() {
    int rows = 0, cols = 0;
    char ** pArray = NULL;

    setlocale(LC_ALL, "Russian");

    for (;;) {
        showStatusBar(rows, cols);
        showMenu(rows, cols);

        switch(_getche()) {
        case '1':
            rows = getValue("�����", 1, 1001);
            cols = getValue("��������", 1, 38);
            pArray = initArray(rows, cols);

            if (pArray == NULL) {
                rows = 0;
                cols = 0;

                puts("���������� �����-��!");
                system("pause");
                break;
            }
            break;
        case '2':
            if (rows != 0 && cols != 0)
                printArray(pArray, rows, cols);
            break;
        case '3':
            exit(0);
            break;
        default: // ������� ��� ��������...
            system("cls"); 
            printf("������, ���� �� ������ ������������� ����. ������ ������ ������!\n");
            system("pause");
            break;
        }
    }
}

void showStatusBar(int rows, int cols) {
    system("cls");
    printf(" ------------------------------------------------------------------------------\n");
    printf(" | ��������� ������ | ������� %dx%d |\n", rows, cols);
    printf(" ------------------------------------------------------------------------------\n");
}

void showMenu(int rows, int cols) {
    puts(" 1) ������ �����������");
    if (rows != 0 && cols != 0)
        puts(" 2) ������� �������");
    puts(" 3) �����");
}

int getValue(char *String, int min, int max) {
    int Value = 0;
    do {
        system("cls");
        printf("������� ���������� %s %d < n < %d: ", String, min, max);
        scanf_s("%d", &Value);
        fflush(stdin);
    } while (Value < min && Value > max);
    return Value;
}

char ** initArray(int rows, int cols) {
    char **pArray = (char **) calloc(rows, sizeof(char *));
    if (pArray == NULL)
        return NULL;

    for (int i = 0; i < rows; i++) {
        pArray[i] = (char *) calloc(cols, sizeof(char));
        if (pArray == NULL)
            return NULL;

        for (int j = 0; j < cols; j++)
            pArray[i][j] = getElement(i, j);
    }

    return pArray;
}

void printArray(char **pArray, int rows, int cols) {
    system("cls");
    printMinus(2 * (cols + 1));
    for (int i = 0; i < rows; i++) {
        printf("|");

        for (int j = 0; j < cols; j++)
            printf(" %d", pArray[i][j]);

        printf("|\n");
    }
    printMinus(2 * (cols + 1));
    system("pause");
}

int getElement(int i, int j) {
    if (odd(i))
        return j % 4 + 1;
    else
        return (j + 2) % 4 + 1;
}

int odd(int a) {
    return (a % 2);
}

void printMinus(int cols) {
    for (int i = 0; i < cols; i++)
        printf("-");
    printf("\n");
}