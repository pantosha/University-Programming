/*
����  n  ������.  ��������  ������� �  ������,  �  ������  ������ 
��������  ����  �����.  �������  ��  ������  ���  ���������� (�����, 
������� ����� � ������ �������� ���������). ���������� ������� 
�������.
*/

// 1) ������� �������
//		0) �������� ������ ��� ����� �������
//	--  �) ��������� �����
//		�) ��c����� �������
//		�) ������� �������������� ������� �, �������� ������ ��������, ������� ��, ������� ������

#include <stdio.h>
#include <stdlib.h>
#include <locale>
#include <time.h>
#include <conio.h>

#define MAX_ABC 'z'
#define MIN_ABC 'a'
#define MAX_LEN 7
#define RATIO 2
#define DIM_MIN 2
#define DIM_MAX 6


int isPalindrom(char *str, size_t size);
char ***createMatrix(int size);
void freeMatrix(char ***Matrix, size_t size);
char *genPalindrom(size_t size, char *str = NULL);
char *genSimple(size_t size, char *str = NULL);
int random(int Range);
int putMatrix(char ***Matrix, size_t size);
int putCheckMatrix(char ***Matrix, size_t size);
char *genWord(size_t size);
int strLen(const char* str);
void repch(char ch = '-', int num = 60);

// ��������� ������ ���������
void showStatusBar(size_t size);
void showMenu();
int getDimension();

void main() {
    setlocale(LC_ALL, "Russian");
	srand(time(NULL));

    size_t size = 0;
    char ***Matrix = NULL;

    for (;;) {
        showStatusBar(size);
        showMenu();

        switch(_getche()) {
        case '1':
            if (Matrix)
                freeMatrix(Matrix, size);

            size = getDimension();
            
            Matrix = createMatrix(size);
			break;
        case '2':
            system("cls");

            puts("���������� ������������ ���������� ������� ��������� �� ����:");
            //repch();
            putMatrix(Matrix, size);
            
            puts("\n�� �� ����, ������ ��� ���������:");
            putCheckMatrix(Matrix, size);
            
            system("pause");
            break;
        case '3':
            puts("���������, ����� ����������� ��� ��������������!");
			freeMatrix(Matrix, size);
            exit(1);
        default:
            puts("���� ������ �������.");
            break;
        }
    }

    putCheckMatrix(createMatrix(4), 4);
    system("pause");
}


void showStatusBar(size_t size) {
    system("cls");
    printf(" ------------------------------------------------------------------------------\n");
    printf(" | ������������ ������ �4.1 | �����������: %d|\n", size);
    printf(" ------------------------------------------------------------------------------\n");
}


void showMenu() {
    puts(" 1) ������ ����������� � ������� �������");
    puts(" 2) ��������");
    puts(" 3) �����");
    puts(" ?) ��� ����� ���������?");
}


int getDimension() {
    int dim;

    do {
        system("cls");
        printf_s("������� ����������� ������� (�� %d �� %d): ", DIM_MIN, DIM_MAX);
        scanf_s("%d", &dim);
        fflush(stdin);
    } while ((dim < DIM_MIN) || (dim > DIM_MAX));
    
    return dim;
}


char ***createMatrix(int size) {
    char ***Matrix;
	Matrix = (char ***)calloc(size, sizeof(char **));
	for (int i = 0; i < size; i++)
		Matrix[i] = (char **)calloc(size, sizeof(char *));

	for (int i = 0; i < size; i++)
		for (int j = 0; j < size; j++) 
            Matrix[i][j] = genWord(random(MAX_LEN) + 2);
    return Matrix;
}


void freeMatrix(char ***Matrix, size_t size) {
    for (unsigned i = 0; i < size; i++) {

        for (unsigned j = 0; j < size; j++)
            free(Matrix[i][j]);

        free(Matrix[i]);
    }

    free(Matrix);
}


int isPalindrom(char *str, size_t size) {
	if (size < 2)
		return 1;
	else
		if (*str == *(str + size - 1))
			isPalindrom(str + 1, size - 2);
		else
			return 0;
}


void repch(char ch, int num) {
    while (num--)
        putch(ch);
}


int random (int Range) {
	return rand() % Range;
}


int putMatrix(char ***Matrix, size_t size) {
	if (Matrix == NULL)
        return NULL;

    repch('-', size*11 + 1);	
	for (unsigned i = 0; i < size; i++) {
        putch('\n');
		for (unsigned j = 0; j < size; j++)
			printf("|%10s", Matrix[i][j]);
        puts("|");
        repch('-', size*11 + 1);
    }
    putch('\n');
}


int putCheckMatrix(char ***Matrix, size_t size) {
	if (Matrix == NULL)
        return -1;
	
    repch('-', size*11 + 1);
	for (unsigned i = 0; i < size; i++) {
        putch('\n');
		for (unsigned j = 0; j < size; j++)
			printf("|%10s", isPalindrom(Matrix[i][j], strLen(Matrix[i][j])) ? "<�����>" : Matrix[i][j]);
        puts("|");
        repch('-', size*11 + 1);
    }
    putch('\n');
}


int strLen(const char* str) {
	const char *s;

	for (s = str; *s; ++s)
		;
	return (s - str);
}


char *genWord(size_t size) {
    if ((rand() % 10) > RATIO)
        return genSimple(size);
    else
        return genPalindrom(size);
}


char *genPalindrom(size_t size, char *str) {
	if (str == NULL)
		str = (char *)malloc((size + 1 )* sizeof(char));
	
    char *ptemp = str;
    int length = size; // ���� ��� size_t ���������� �� ��������������� ������, ���������� ������������� ������ �����

	while (length > 0) {
		*ptemp = ptemp[length - 1] = MIN_ABC + random(MAX_ABC - MIN_ABC);
		length -= 2;
		ptemp++;
	}

    str[size] = '\0';
	return str;
}


char *genSimple(size_t size, char *str) {
    if (str == NULL)
		str = (char *)malloc((size + 1 )* sizeof(char));

    for (unsigned i = 0; i < size; i++)
        str[i] = MIN_ABC + random(MAX_ABC - MIN_ABC);
    
    str[size] = '\0';
    return str;
}

// if (size < 2) return 1; else if (*str == *(str+ size - 1)) isPalindrom(str+1,size-2); else return 0;
// return (size < 2) ? 1 : (*str == *(str + size - 1)) ? isPalindrom(str + 1, size - 2) : 0;

/*
int numStr(FILE *fp) {
	if (fp) {
	
		int counter = 0;
		while (!feof(fp)) {
			fgets(fp); ///!!!!!
			counter++;
		}
		rewind(fp);
		return counter;
	} else {
		return -1;
	}
}
*/
