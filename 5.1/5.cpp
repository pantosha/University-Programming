#include <stdio.h>
#include <stdlib.h>
#include <locale>
#include <conio.h>
#include <time.h>

typedef struct item Item;
struct item {
    int value;
	Item *next;
};

typedef struct queue {
    Item *head;
	Item *tail;
} Queue;

Item *newitem(int value);
void applyQueue(Queue _queue, void (*fn)(Item *, void *), void * arg); //��� ������ ��������� ������� ����� ��������� ���������, ��������� � ������� (*fn)
Item *addback(Item *tail, Item *newp);
Item *read(Queue *in);
Queue createQueue(int count);
void printItem(Item *_item, void *arg);
int random (int Range);
Queue makeOne(Queue *first, Queue *second);
size_t getLength(char *name);
void freeItem(Item *_item, void *arg);

void showMenu();
void goMenu(size_t *qLen1, size_t *qLen2);
void repch(char ch, int num);
void showStatusBar(const int len1, const int len2);

void temp(Queue tr){
    tr.head++;
    tr.tail++;
}

void main() {
    size_t qLen1 = 7, qLen2 = 7;
    Queue dte = {NULL, NULL};
    temp(dte);
    srand(time(NULL));
    setlocale(LC_ALL, "Russian");

    for (;;) {
        showStatusBar(qLen1,qLen2);
        showMenu();
        goMenu(&qLen1, &qLen2);
    }
}

void goMenu(size_t *qLen1, size_t *qLen2) {
    Queue q1, q2, q3;

    switch(_getche()) {
    case '1':
        *qLen1 = getLength("������");
        *qLen2 = getLength("������");
		break;
    case '2':
        system("cls");

        q1 = createQueue(*qLen1);
        applyQueue(q1, printItem, " %d");
        puts("");
            
        q2 = createQueue(*qLen2);
        applyQueue(q2, printItem, " %d");
        puts("");

        q3 = makeOne(&q1, &q2);
        applyQueue(q3, printItem, " %d"); //������
        puts("");

        applyQueue(q3, freeItem, NULL); //�������
        system("pause"); //��������
        break;
    case '3':
        puts("���������, ����� ����������� ��� ��������������!");
        exit(1);
    default:
        puts("���� ������ �������.");
        break;
    }
}

void showStatusBar(const int len1, const int len2) { // ����� ��� �� ���������
    system("cls");
    repch('-', 80);
    printf(" | ������������ ������ �5 | ����� ������� �1: %d, �2: %d |\n", len1, len2);
    repch('-', 80);
}

void showMenu() {
    puts(" 1) ������� ����� ��������"); //��� �� ��� � �����������.
    puts(" 2) ���������� �������");
    puts(" 3) �����");    
}

size_t getLength(char *name) {
    size_t length = 0;
    
    system("cls");
    printf("������� ����� %s �������: ", name);
    scanf_s("%d", &length);
    fflush(stdin);
    return length;
}

void repch(char ch, int num) {
    while (num--)
        putch(ch);
}

Item *newitem(int value) {
	Item *newp = (Item *)malloc(sizeof(Item));
    
    newp->value = value;
    newp->next = NULL;

    return newp;
}

//��� �������? � ���� �� ����...
Item *addback(Item *tail, Item *newp) { //������ ����� push��� �������
	if (tail == NULL)
        return newp;
    tail->next = newp;
    return newp;
}

void add(Queue *in, Item *newp) {
    if (in->tail == NULL) {
        in->tail = in->head = newp;
        return;
    }

    if (in->tail->value != newp->value) {
        in->tail->next = newp;
        in->tail = newp;
    } else
        free(newp);
}

Item *read(Queue *in) { // ������ pop���� ��� ������� ��������..
    Item *t;
    if (in->head == NULL)
        return NULL;

    t = in->head;
    in->head = in->head->next;
    return t;
}

/*
Item *read(Item *buf, Item *head) {
    if (head == NULL)
		return NULL;
	buf = head;
	return head->next;
}
*/

/*Queue *createQueue(int count) {
	Queue *newqueue;

    if (count < 1)
        return NULL;

    newqueue->tail = newqueue->head = newitem(1 + random(5)); // � ���� ����� ���: newqueue.tail = newqueue.head = addback(newqueue.tail, newitem(1 + random(5)));
	for (int i = 1; i < count; i++) {
        newqueue->tail = addback(newqueue->tail, newitem(random(newqueue->tail->value)));
	}

    return newqueue;
}*/

Queue createQueue(int count) {
	Queue newqueue;
    memset(&newqueue, 0, sizeof(newqueue));

    if (count < 1)
        return newqueue;

    newqueue.tail = newqueue.head = newitem(1 + random(5)); // � ���� ����� ���: newqueue.tail = newqueue.head = addback(newqueue.tail, newitem(1 + random(5)));
	for (int i = 1; i < count; i++) {
        newqueue.tail = addback(newqueue.tail, newitem(random(newqueue.tail->value)));
	}

    return newqueue;
}

Queue makeOne(Queue *first, Queue *second) {
	Queue unique;
    memset(&unique, 0, sizeof(unique));

    Item *fv, *sv;

    fv = read(first);
    sv = read(second);
    
    while (fv != NULL && sv != NULL) {
        if (fv->value < sv->value) {
            add(&unique, fv);
            fv = read(first);
        } else {
            add(&unique, sv);
            sv = read(second);
        }
    }
    
    if (fv) {
        unique.tail->next = fv;
        unique.tail = first->tail;
    }
    else if (sv) {
        unique.tail->next = sv;
        unique.tail = second->tail;
    } else
        printf("�������...\n");

    return unique;

/*
    // 1) ���������� ���������� � ���� ��������
    // 2) ��������� � ��������� ��� �� ��������� � �������� �������
    while ((fv = read(first)) > sv) {
        addback();
    }

    while (first->head->next != NULL || second->head->next != NULL) {// ������� ��������, �������� ������� � ������� �����, � ������� ������? ��� �����..
        if (first->head->value < second->head->value)
            if (first->head->value != unique.tail->value)


    }

    while ((fv = read(first)) != NULL || (sv = read(second)) != NULL) {
        
    }
    */
}

/*
void applyQueue(Queue _queue, void (*fn)(Item *, void *), void * arg) {
	while (_queue.head) {
		(*fn)(_queue.head, arg);
		_queue.head = _queue.head->next;
	}
}
*/

void applyQueue(Queue _queue, void (*fn)(Item *, void *), void * arg) {
	Item *temp;

    while (_queue.head) {
        temp = _queue.head;
        _queue.head = _queue.head->next;
		(*fn)(temp, arg);
	}
}

void printItem(Item *_item, void *arg) {
    char *str = (char *)arg;
    printf(str, _item->value);
}

void freeItem(Item *_item, void *arg) {
    free(_item);
}

int random (int Range) {
	return Range + rand() % Range;
}