/*
�  ��������� ����� ���������� ������������ �����. ��������� �� 
���  ������  ��������  ������  ������,  ������  ����  �������� 
�������� �����. ������� �� ������ �� �����, � ������� ����������� 
��� � ����� ������� ���� ���������� ��������. 
*/

#include <stdio.h>
#include <stdlib.h>
//#include <locale>
#include <conio.h>
#include <time.h>
#include <string>
#include <Windows.h>

#define MAXVOCAL 3
#define MAXLEN 1024

typedef struct list List; 
struct list {
    char *word;
    List *left;
    List *right;
};
char filename[] = "text.txt";
char vocals[] = "aeyuio";

List *insert(List *ptree, List *pnew);
List *newList(char *str);
void showStatusBar();
void showMenu();
void applyInOrder(List *ptree, void (*fn)(List *, void *), void *arg);
    void printList(List *ptree, void *arg);
    void printWordWithThree(List *ptree, void *arg);
void applyPostOrder(List *ptree, void (*fn)(List *, void *), void *arg);
    void freeList(List *ptree, void *arg);

int main() {
    SetConsoleCP(1251);
    SetConsoleOutputCP(1251);

    char *str, *word, *temp;
    List *tree = NULL;
    FILE *pFile = fopen(filename, "r");
    
    if (pFile == NULL) {
        perror ("Error opening file");
        exit(1);
    }

    str = (char *)malloc(MAXLEN * sizeof(char));
    
    while(fgets(str, MAXLEN, pFile)) {
        word = strtok_s(str, " ,.:;-!?", &temp);
        while (word != NULL) {
            tree = insert(tree, newList(word));
            word = strtok_s(NULL, " ,.:;-!?", &temp);
        }
    }
    for (;;) {
        showStatusBar();
        showMenu();
        switch(_getche()) {
        case '1':
            system("cls");
            applyInOrder(tree, printList, "%s\n");
            system("pause");
            break;
        case '2':
            system("cls");
            applyInOrder(tree, printWordWithThree, "%s\n");
            system("pause");
            break;
        case '3':
            free(str);
            applyPostOrder(tree, freeList, NULL);
            puts("���������, ����� ����������� ��� ��������������!");
            exit(1);
        default:
            puts("���� ������ �������.");
            break;
        }
    }
}

void showStatusBar() { // ����� ��� �� ���������
    system("cls");
    printf(" ------------------------------------------------------------------------------\n");
    printf(" | ������������ ������ �6 | ������ ����: %s|\n", filename);
    printf(" ------------------------------------------------------------------------------\n");
}

void showMenu() {
    puts(" 1) ������� ��� �����");
    puts(" 2) ������� ������ �����, ��� ������ ��� �������");
    puts(" 3) �����");    
}

List *newList(char *str) {
    List *pnew = (List *)malloc(sizeof(List));
    if ((pnew->word = strdup(str)) == NULL) {
        free(pnew);
        return NULL;
    }
    pnew->right = pnew->left = NULL;
    return pnew;
}

/* applyPostOrder - �������������� ����� ������ � ����������� ������� fn */
void applyPostOrder(List *ptree, void (*fn)(List *, void *), void *arg) {
    if (ptree == NULL)
        return;
    applyPostOrder(ptree->left, fn, arg);
    applyPostOrder(ptree->right, fn, arg);
    (*fn)(ptree, arg);
}

/* ������� ��� applyPostOrder. ������� �������*/
void freeList(List *ptree, void *arg) {
    free(ptree->word);
    return free(ptree);
}

List *insert(List *ptree, List *pnew) {
    int cmp;
    
    if (ptree == NULL)
        return pnew;
    cmp = strcmp(pnew->word, ptree->word);
    if (cmp == 0)
        freeList(pnew, NULL); //��� - � ����
    else if (cmp < 0)
        ptree->left = insert(ptree->left, pnew);
    else
        ptree->right = insert(ptree->right, pnew);
    return(ptree);
}

/* applyInOrder - ������������ ����� ������ � ����������� ������� fn */
void applyInOrder(List *ptree, void (*fn)(List *, void *), void *arg) {
    if (ptree == NULL)
        return;
    applyInOrder(ptree->left, fn, arg);
    (*fn)(ptree, arg);
    applyInOrder(ptree->right, fn, arg);
}

/* ������� ��� applyInOrder. �������� ������� � ������������ � ������������ ���������� */
void printList(List *ptree, void *arg) {
    char *str = (char *)arg;
    printf(str, ptree->word);
}

/* ������� ��� applyInOrder. ��������� ������� ��� �������, ��� � ����� ���������� ������� ������ MAXVOCAL*/
void printWordWithThree(List *ptree, void *arg) {
    char *word, *tvocals;
    char *str = (char *)arg;
    char i = 0;

    for (word = ptree->word; (*word != '\0') && (i < MAXVOCAL); word++) {
        for (tvocals = vocals; *tvocals != '\0' && *tvocals != *word; tvocals++)
            ;
        if (*tvocals != '\0')
            i++;
    }

    if (i >= MAXVOCAL)
        printf(str, ptree->word);
}