/*
//��������,  �����  ��,  ���  �  ���������  �����,  ���������  ������  �� 
//����,  ����  �  ��������,  �����  ��������  ��������  ����  ����� 
//���������� ����.
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
            puts("���������, ����� ����������� ��� ��������������!");
            if (fp != NULL)
				fclose(fp);
            exit(1);
        default:
            puts("���� ������ �������.");
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


void showStatusBar() { // ����� ��� �� ���������
    system("cls");
    printf(" ------------------------------------------------------------------------------\n");
    printf(" | ������������ ������ �4.2 | ������ ����: %s|\n", filename);
    printf(" ------------------------------------------------------------------------------\n");
}


void showMenu(FILE *fp) {
    puts(" 1) ������� ����");
    if (fp != NULL)
        puts(" 2) ������ �����");
    puts(" 3) �����");
}


FILE *openFile(FILE *temp) {
    system("cls");
    puts("�������� ��� �����");
    puts(" 1) \"����������\"");
    puts(" 2) \"������������\"");
    
    switch (_getch()) {
    default:
        puts("�� ������, ��� ������. �������� \"����������\" ����."); // ��-�� ���������� break ���������� ��������� case.
    case '1':
        strCopy(filename, "right.dat");
        break;
    case '2':
        strCopy(filename, "wrong.dat");
        break;
    }

    if (temp != NULL)
        fclose(temp); // ������ ��� ������, �� ���� ������ � ����.

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


/*���, ������� �� ��������. ��� �� ���� ����������� ����.*/
/*� ���������� � ����������� ����, �������� ������� Compare � �������� 0, -1, 1 � ������ �������,
//� ���������� ��������� �� ���� �, ��� �������, ��������� �� ��������*/
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

// �� ����� ����� ���������� ��� ��������� � ������ �����
    char compare[10];
    if (counterWord > counterSum)
        strCopy(compare, "������");
    else if (counterWord < counterSum)
        strCopy(compare, "������");
    else
        strCopy(compare, "�����");

    system("cls");
    printf("���������� ���� (%d) %s ����� ���� (%d)\n", counterWord, compare, counterSum);
    system("pause");
}