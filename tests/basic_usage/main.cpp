#include <stm32l4xx_hal.h>
#include <gpio.h>

extern "C" void SystemClock_Config(void);

int main() {
    ::HAL_Init();
    ::SystemClock_Config();

    ::MX_GPIO_Init();

    while (1) {
        ::HAL_GPIO_TogglePin(LD2_GPIO_Port, LD2_Pin);
        ::HAL_Delay(100);
    }
}