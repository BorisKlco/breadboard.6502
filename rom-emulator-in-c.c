// In C should higher clock be possible...
// https://github.com/WiringPi/WiringPi/releases/tag/2.61-1
// gcc -o rom-emulator rom-emulator.c -lwiringPi

#include <stdio.h>
#include <wiringPi.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

#define FILENAME "a.out"
#define ADDR_PIN_COUNT 16
#define DATA_PIN_COUNT 8
#define CLOCK_PIN 24
#define RWB_PIN 25

const int addr_pins[ADDR_PIN_COUNT] = {2, 0, 7, 9, 28, 27, 26, 31, 11, 10, 6, 5, 4, 1, 16, 15};
const int data_pins[DATA_PIN_COUNT] = {3, 12, 13, 14, 30, 21, 22, 23};

FILE *file;
unsigned char instructions[65536]; // Max 64KB ROM
struct timespec clock_timing;

void exit_handler(int sig);
void clock_trigger(void);
unsigned short read_address(void);
void set_data(unsigned char data);
unsigned char read_data(void);

void clock_trigger(void)
{
    unsigned char status;
    unsigned short addr;
    double clk_diff, freq;
    struct timespec current_clock;
    clock_gettime(CLOCK_REALTIME, &current_clock);

    clk_diff = (current_clock.tv_sec - clock_timing.tv_sec) * 1000.0;
    clk_diff += (current_clock.tv_nsec - clock_timing.tv_nsec) / 1000000.0;

    freq = 1000.0 / clk_diff;
    clock_timing = current_clock;
    status = digitalRead(RWB_PIN);
    addr = read_address();
    if (status)
    {
        unsigned char data = instructions[addr];
        set_data(data);
        printf("Addr: %04x %s %02x - %.2fms(%.2fHz)\n", addr, (status ? "R" : "W"), data, clk_diff, freq);
    }
    else
    {
        unsigned char data = read_data();
        instructions[addr] = data;
        printf("Addr: %04x %s %02x - %.2fms(%.2fHz)\n", addr, (status ? "R" : "W"), data, clk_diff, freq);
    }
}

unsigned short read_address(void)
{
    unsigned short addr = 0;
    for (int i = 0; i < ADDR_PIN_COUNT; ++i)
        addr = (addr << 1) + digitalRead(addr_pins[i]);
    return addr;
}

void set_data(unsigned char data)
{
    for (int i = 0; i < DATA_PIN_COUNT; ++i)
    {
        pinMode(data_pins[i], OUTPUT);
    }

    for (int i = DATA_PIN_COUNT - 1; i >= 0; --i)
    {
        digitalWrite(data_pins[i], data & 1);
        data = data >> 1;
    }
}

unsigned char read_data(void)
{
    unsigned char data = 0;
    for (int i = 0; i < DATA_PIN_COUNT; ++i)
    {
        pinMode(data_pins[i], INPUT);
    }
    for (int i = 0; i < DATA_PIN_COUNT; ++i)
    {
        data = (data << 1) + digitalRead(data_pins[i]);
    }
    return data;
}

int main(void)
{
    if (wiringPiSetup() == -1)
    {
        fprintf(stderr, "Error: Unable to initialize WiringPi\n");
        exit(EXIT_FAILURE);
    }

    file = fopen(FILENAME, "rb");
    if (!file)
    {
        fprintf(stderr, "Error: Unable to open file\n");
        exit(EXIT_FAILURE);
    }

    fread(instructions, sizeof(instructions), 1, file);
    fclose(file);

    for (int i = 0; i < ADDR_PIN_COUNT; ++i)
        pinMode(addr_pins[i], INPUT);

    pinMode(RWB_PIN, INPUT);
    pinMode(CLOCK_PIN, INPUT);
    wiringPiISR(CLOCK_PIN, INT_EDGE_RISING, &clock_trigger);

    while (1)
        delay(1);

    return 0;
}
