// Platform bağımsız bekleme ve ekran temizleme
#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#define WAIT(seconds) Sleep((seconds) * 1000)
#define CLEAR_SCREEN() system("cls")
#else
#include <unistd.h>
#define WAIT(seconds) sleep(seconds)
#define CLEAR_SCREEN() system("clear")
#endif