#include <stdint.h>
#include <stdbool.h>

#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data   (*(volatile uint32_t*)0x02000008)

// Accelerator Registers (Base 0x04000000)
#define ACCEL_BASE 0x04000000
#define REG_ACCEL_CTRL   (*(volatile uint32_t*)(ACCEL_BASE + 0x00)) 
#define REG_ACCEL_STATUS (*(volatile uint32_t*)(ACCEL_BASE + 0x04)) 
#define REG_ACCEL_DATA   (*(volatile uint32_t*)(ACCEL_BASE + 0x08)) 

void putchar(char c);
void print(const char *p);

void main()
{
    reg_uart_clkdiv = 104;

    print("\n--- SIMULATION START ---\n");

    // ---------------------------------------------------------
    // PHASE 1: MODE 1 (INVERT)
    // ---------------------------------------------------------
    print("Setting Mode: 1 (INVERT)\n");
    REG_ACCEL_CTRL = 1; 

    // Process first 64 pixels
    for (int i = 0; i < 64; i++) {
        // Wait for Valid bit (Bit 0)
        while ((REG_ACCEL_STATUS & 1) == 0);
        
        // Read Pixel (Trigger next fetch)
        uint32_t pixel = REG_ACCEL_DATA; 
    }
    print("Mode 1 Finished.\n");

    // ---------------------------------------------------------
    // PHASE 2: MODE 2 (EDGE DETECT)
    // ---------------------------------------------------------
    print("Switching to Mode: 2 (EDGE DETECT)\n");
    REG_ACCEL_CTRL = 2; // <--- This switches the hardware mode

    // Process next 128 pixels (Edge detect needs more pixels to fill buffer)
    for (int i = 0; i < 256; i++) {
        while ((REG_ACCEL_STATUS & 1) == 0);
        uint32_t pixel = REG_ACCEL_DATA;
    }
    print("Mode 2 Finished.\n");
    print("--- DONE ---\n");
}

void putchar(char c) {
    if (c == '\n') putchar('\r');
    reg_uart_data = c;
}

void print(const char *p) {
    while (*p) putchar(*(p++));
}