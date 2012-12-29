/*
//Лабораторная работа №3.1
//02.03.2012
*/

#include <stdio.h>
#include <stdlib.h>
#include <locale>
#include <time.h>
#include <conio.h>

typedef struct details {
    int Number;
    int NumberOfRepitions;
} Details;
//unsigned int Range;
int *pArray;

void showMenu(unsigned int Range);
int * initArray (int numFields);
int remRetryElem (int *pArray, int numFields);
void getStat (int *pArray, int numFields);
int random(int Range);
void printArray(int *pArray, int numFields);
unsigned int goMenu(unsigned int Range);

void main() {
    // int *pArray = NULL;
    unsigned int Range = 0;

    setlocale(LC_ALL, "Russian");
    srand(time(NULL));

    for (;;) {
        showMenu(Range);
        Range = goMenu(Range);
    }
}

void showMenu(unsigned int Range){
    system("cls");

    printf("1) Ввести размерность и создать массив.\n");
    if (Range != NULL) {
        printf("2) Узнать статистику по символам.\n");
        printf("3) Удалить повторяющиеся.\n");
        printf("4) Вывести нынешний массив.\n");
    }
    printf("5) Выход.\n");
    printf("\n Желаемое действие: ");
}

int * initArray (int numFields) {
    int *pArray = (int *) calloc(numFields, sizeof(int));

    if (pArray == 0)
        exit(0);

    for (int i = 0; i < numFields; i++) {
        pArray[i] = random(numFields / 2);
    }
    return pArray;
}

void getStat (int *pArray, int numFields) { //правка названия; разобраться с рандомом в результатах
    Details *tempArray;
    int numExclusFields = 1;

    tempArray = (Details *) calloc(numExclusFields, sizeof(Details));
    tempArray[0].Number = pArray[0];
    tempArray[0].NumberOfRepitions = 0;

    for (int i = 0; i < numFields; i++) {
        int j = 0;

        for (j = 0; j < numExclusFields; j++)
            if (tempArray[j].Number == pArray[i]) {
                tempArray[j].NumberOfRepitions++;
                break;
            }

            if (pArray[i] != tempArray[numExclusFields - 1].Number && j == numExclusFields) {
                numExclusFields++;
                tempArray = (Details *) realloc (tempArray, sizeof (Details) * numExclusFields);
                tempArray[numExclusFields - 1].Number = pArray[i];
                tempArray[numExclusFields - 1].NumberOfRepitions = 1;
            }

            /*
            йййййййййййййййййййййййййййййййййййййййаааааааааааааааааааааааааааааааааззззззззззззззззззззззззззззззззззьььььььььььььььььььь!!!!!!!!!!!!!!
            */
    }
    system("cls");
    printf("\n =================\n");
    printf(" |    z    |  %%  |\n");
    printf(" =================\n");
    for (int i = 0; i < numExclusFields; i++) {
        printf(" |%-9d|%5.2lf|\n", tempArray[i].Number, (double)tempArray[i].NumberOfRepitions / (double)numFields * 100.00);
    }
    printf(" =================\n");
    system("pause");
    free (tempArray);
}

/*функция перемещает повторяющиеся элементы, возвращая новую размерность массива*/
int remRetryElem (int *pArray, int numFields) { // для каждого элемента массив прочёсывается до конца, перемещая на место дублей следующие элементы
    for (int i = 0; i < numFields; i++) {
        int k = i + 1;

        for (int j = i; j < numFields; j++) {
            if (pArray[i] != pArray[j]) {
                pArray[k] = pArray[j];
                k++;
            }
        }
        numFields = k;
    }
    return numFields;
}

int random (int Range) {
    return rand() % Range;
}

void printArray(int *pArray, int numFields) {
    if (numFields != NULL || pArray != NULL) {
        printf("\n =================\n");
        printf(" |  i  |    z    |\n");
        printf(" =================\n");
        for (int i = 0; i < numFields; i++) {
            printf(" |%-5d|%9d|\n", i + 1, pArray[i]);
        }
        printf(" =================\n");
    } else {
        printf("Массив не задан.");
        system("cls");
    }
    system("pause");
}

unsigned int goMenu(unsigned int Range) {
    switch(_getche()){
    case '1': // создать новую подборку
        system("cls");
        puts("Введите размерность массива 1 < n < 10001: ");
        scanf_s("%d", &Range);
        fflush(stdin);

        if (Range < 2 || Range > 10000){
            puts("Оставьте мысли о свободе и не выходите за границы");
            system("pause");
            return NULL;
            //continue;
        }

        pArray = initArray(Range);

        puts("Несмотря на проделки товарища Постоянства и мистера Константы, результат Рандома представлен ниже:");
        printArray(pArray, Range);
        return Range;
        break;
    case '2': // узнать составные части подборки и их количество
        if (Range != NULL) {
            getStat(pArray, Range);
        }
        return Range;
        break;
    case '3': // зачем нам идентичные значения? На их место индивидуальностей! А сэкономленное место - раздать нуждающимся
        if (Range != NULL) {
            Range = remRetryElem(pArray, Range);
            pArray = (int *) realloc (pArray, sizeof(int) * Range);
            system("cls");
            puts("После удаления одинакового хлама...");
            printArray(pArray, Range);
        }
        return Range;
        break;
    case '4': // Гутенберг нашего времени
        system("cls");

        printArray(pArray, Range);
        return Range;
        break;
    case '5': // всем спать
        free(pArray);
        exit(0);
    default: // пальцам рук посвящаю...
        system("cls"); 
        printf("Вы промазали. Будьте впредь точнее!\n");
        system("pause");
        return Range;
        break;
    }
}