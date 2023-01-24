#include <stm32l4xx_hal.h>
#include <gpio.h>
#include <main.h>
extern "C" void SystemClock_Config(void);

int main()
{
    ::HAL_Init();
    ::SystemClock_Config();

    ::MX_GPIO_Init();
    return ::my_very_important_function(); // defined in main.c
}