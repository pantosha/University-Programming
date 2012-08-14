/*
//Выяснить,  верно  ли,  что  в  текстовом  файле,  состоящем  только  из 
//цифр,  букв  и  пробелов,  сумма  числовых  значений  цифр  равна 
//количеству слов.
*/

#include <stdio.h>
#include <stdlib.h>
#include <locale>
#include <conio.h>

#define True 1
#define False 0

char filename[10];

void showStatusBar();
void showMenu(FILE *fp);
FILE *openFile(FILE *temp);
void fileAnalyze(FILE *fp);
void strCopy(char *dst, char *src);
int charToInt(char ch);
int isDigit(int ch);
int isAlpha(int ch);

void main() {
    FILE *fp = NULL;
    
    setlocale(LC_ALL, "Russian");

    for (;;) {
        showStatusBar();
        showMenu(fp);

        switch(_getche()) {
        case '1':
            fp = openFile(fp);
			break;
        case '2':
            if (fp != NULL)
                fileAnalyze(fp);                
            break;
        case '3':
            puts("Осторожно, прога закрывается без предупреждений!");
            if (fp != NULL)
				fclose(fp);
            exit(1);
        default:
            puts("Была нажата клавиша.");
            break;
        }
    }
}


int charToInt(char ch) {
	return ch - '0';
}


int isDigit(int ch) {
	if ('0' < ch && ch < '9')
		return True;
	else
		return False;
}


int isAlpha(int ch) {
	if (('a' <= ch && ch <= 'z') || ('A' <= ch && ch <= 'Z'))
		return True;
	else
		return False;
}


void showStatusBar() { // птицы ещё не прилетели
    system("cls");
    printf(" ------------------------------------------------------------------------------\n");
    printf(" | Лабораторная работа №4.2 | Открыт файл: %s|\n", filename);
    printf(" ------------------------------------------------------------------------------\n");
}


void showMenu(FILE *fp) {
    puts(" 1) Выбрать файл");
    if (fp != NULL)
        puts(" 2) Узнать тайну");
    puts(" 3) Выход");
}


FILE *openFile(FILE *temp) {
    system("cls");
    puts("Выберите тип файла");
    puts(" 1) \"Правильный\"");
    puts(" 2) \"Неправильный\"");
    
    switch (_getch()) {
    default:
        puts("Не хотите, как хотите. Выбираем \"Правильный\" файл."); // из-за отсутствия break выполнится следующий case.
    case '1':
        strCopy(filename, "right.dat");
        break;
    case '2':
        strCopy(filename, "wrong.dat");
        break;
    }

    if (temp != NULL)
        fclose(temp); // первый раз ничего, но ведь бывает и хуже.

    temp = fopen(filename, "r");
    if (temp == NULL) {
        printf("Stupid boy");
        system("pause");
        return NULL;
    }
    else
        return temp;
}


void strCopy(char *dst, char *src) {
    while (*src) {
        *dst = *src;
        dst++;
        src++;
    }
    *dst = '\0';
}


/*Код, который не работает. Уже во всех устройствах мира.*/
/*в дополнение к написанному ниже, обозвать функцию Compare и получать 0, -1, 1 в разных случаях,
//а передавать указатель на файл и, как вариант, указатели на счётчики*/
void fileAnalyze(FILE *fp) {
    int symbol;
    int counterWord = 0;
    int counterSum = 0;
    int Sym = 0;
    rewind(fp);

/*    while ((symbol = fgetc(fp)) != EOF) {
        if (isAlpha(symbol))
            counterWord++;
        else if (isDigit(symbol)) {
            counterWord++;
            counterSum += charToInt(symbol);
        }
*/
    while ((symbol = fgetc(fp)) != EOF) {
        if (symbol == ' ') {
            if (Sym != 0)
                counterWord++;
        } else if (isAlpha(symbol))
            Sym++;
        else if (isDigit(symbol)) {
            Sym++;
            counterSum += charToInt(symbol);
        }
    }

// от этого можно отказаться или перенести в другое место
    char compare[10];
    if (counterWord > counterSum)
        strCopy(compare, "больше");
    else if (counterWord < counterSum)
        strCopy(compare, "меньше");
    else
        strCopy(compare, "равно");

    system("cls");
    printf("Количество слов (%d) %s суммы цифр (%d)\n", counterWord, compare, counterSum);
    system("pause");
}