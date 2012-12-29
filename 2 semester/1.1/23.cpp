/*
//Лабораторная работа №1.1
//20.02.2012
*/

#include <stdio.h>
#include <stdlib.h>

int main() {
    const unsigned BEGIN = 6, END = 24, PAUSE = 10, TIME_FOR_DRIVE = 150, HOURS_TO_MIN = 60;
    unsigned Start = BEGIN * HOURS_TO_MIN;
    unsigned Finish = Start + TIME_FOR_DRIVE;

    for (Finish; Finish < END * HOURS_TO_MIN; Finish = Start + TIME_FOR_DRIVE) {
        printf("%02d:%02d - %02d:%02d\n", (Start / HOURS_TO_MIN), (Start % HOURS_TO_MIN), (Finish / HOURS_TO_MIN), (Finish % HOURS_TO_MIN));
        Start = Finish + PAUSE;
    }
    system("pause");
}