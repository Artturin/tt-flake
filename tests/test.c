#define GPIO_BASE (0x48000000U) // Base address for GPIO port (e.g., GPIOA on STM32)
#define RCC_BASE  (0x40021000U) // Base address for RCC (Reset and Clock Control)

#define RCC_AHB2ENR (*(volatile unsigned int *)(RCC_BASE + 0x4C))
#define GPIOA_MODER (*(volatile unsigned int *)(GPIO_BASE + 0x00))
#define GPIOA_ODR   (*(volatile unsigned int *)(GPIO_BASE + 0x14))

#define LED_PIN 5 // Assume the LED is connected to GPIO pin 5

void delay(volatile unsigned int count) {
    while (count--);
}

int main(void) {
    // Enable the clock for GPIOA
    RCC_AHB2ENR |= (1 << 0); // Enable GPIOA clock

    // Set GPIOA pin 5 to output mode (01)
    GPIOA_MODER &= ~(3 << (LED_PIN * 2)); // Clear mode bits for pin 5
    GPIOA_MODER |=  (1 << (LED_PIN * 2)); // Set mode to 01 (output)

    while (1) {
        // Toggle the LED
        GPIOA_ODR ^= (1 << LED_PIN);

        // Delay
        delay(100000);
    }

    return 0;
}
