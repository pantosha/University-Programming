/*
//Лабораторная работа №2.1
//24.02.2012
*/
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <locale>

typedef struct details {
    double Weight;
    const double Price; //? заработает аль нет
    const char Name[20] ;
} Details;

typedef enum fructs {
    Mandarine, Peach, Grape
} Fructs;

const double Sales = 1.0 - 0.1;

Details Bin[3] = {{0.0, 1.14, "Мандарины"}, {0.0, 1.0, "Персики"}, {0.0, 1.28, "Виноград"}};

void showStatusBar();
void showMenu();
void goMenu();
double add(int Fruct);
void showBin();
void showPrice();
void about();

void main(){
    setlocale(LC_ALL, "Russian");
    do {
        showStatusBar();
        showMenu();
        goMenu();
    } while(1);
}

void about(){
    system("cls");
    printf("Магазин АшотТоргаш.\n      Покупай, разделяй и кушай!\nКонтактная информация: какой купил, такой использую.\nНайти Гоги, спросить Ашота\n");
    system("pause");
}

double add(int Fruct){
    double Weight;

    showStatusBar();
    printf("  Покупаем %s.\n\nТекущая масса: %lf\n", Bin[Fruct].Name, Bin[Fruct].Weight);
    printf("Введите сколько кг вы хотели бы увидеть в корзине: ");

    scanf_s("%5lf", &Weight);
    fflush(stdin);
    if (Weight >= 0 && Weight < 100.0){
        Bin[Fruct].Weight = Weight;
        printf("В корзине теперь %2.2lfкг\n", Weight);
        system("pause");
        return Weight;
    } else {
        printf("\nВведено неверное значение.");
        system("pause");
        return -1;
    }
}

void showBin(){
    showStatusBar();
    for (int i = 0; i < 3; i++){
        printf("%-10s %5.2lf * %5.2lf$\n", Bin[i].Name, Bin[i].Weight, Bin[i].Price);
    }
    system("pause");
}

void showStatusBar(){
    system("cls");
    printf(" ------------------------------------------------------------------------------\n");
    printf(" | Мандарины: %.2lfкг | Персики: %.2lfкг | Виноград: %.2lfкг |\n", Bin[Mandarine].Weight, Bin[Peach].Weight, Bin[Grape].Weight);
    printf(" ------------------------------------------------------------------------------\n");
}

void showMenu(){
    printf("1) Заказ мандаринов (кг).\n");
    printf("2) Заказ персиков (кг).\n");
    printf("3) Заказ винограда (кг).\n");

    /* Отвечает за сокрытие пунктов меню */
    if (!(Bin[Mandarine].Weight == 0 && Bin[Peach].Weight == 0 && Bin[Grape].Weight == 0)) {
        printf("4) Корзина.\n");
        printf("5) Расчет  стоимости  заказа\n");
    }
    printf("6) Обратная  связь\n");
    printf("7) Выход\n");

    printf("Выберите желаемое действие: ");
}

void showPrice() {
    double totalPrice = 0, totalWeight = 0;

    showStatusBar();
    for (int i = 0; i < 3; i++) {
        printf(" %-10s %5.2lf * %4.2lf$\n", Bin[i].Name, Bin[i].Weight, Bin[i].Price);
        totalPrice += Bin[i].Price * Bin[i].Weight;
        totalWeight += Bin[i].Weight;
    }
    printf(" ------------------------\n");
    printf(" Итого %17.2lf$\n", totalPrice);
    if (totalPrice > 100) {
        totalPrice *= Sales;
        printf(" c учётом скидки %7.2lf$\n", totalPrice);
    }

    printf(" -Наём грузчиков---------\n");
    if (totalWeight < 5){
        totalPrice += 1.0;
        printf(" Доставка           1.00$\n");
    } else if (totalWeight < 20) {
        totalPrice += 3.0;
        printf(" Доставка           3.00$\n");
    } else {
        double shipPrice = (totalWeight - 20) * 2;
        totalPrice += shipPrice + 10;
        printf(" Доставка     10$ + %5.2lf$\n", shipPrice);
    }

    printf(" ------------------------\n");
    printf(" ИТОГО: %16.2lf$\n", totalPrice);
    printf(" ------------------------\n");
    system("pause");
}

void goMenu(){
    switch(_getche()){
    case '1':
        add(Mandarine);
        break;
    case '2':
        add(Peach);
        break;
    case '3':
        add(Grape);
        break;
    case '4':
        if (!(Bin[Mandarine].Weight == 0 && Bin[Peach].Weight == 0 && Bin[Grape].Weight == 0))
            showBin();
        break;
    case '5':
        if (!(Bin[Mandarine].Weight == 0 && Bin[Peach].Weight == 0 && Bin[Grape].Weight == 0))
            showPrice();
        break;
    case '6':
        about();
        break;
    case '7':
        exit(0);
        break;
    default:
        system("cls"); 
        printf("Вы промазали. Будьте впредь точнее!\n");
        system("pause");
        break;
    }
}