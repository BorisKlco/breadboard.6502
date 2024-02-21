import RPi.GPIO as GPIO
import signal
import sys
import time

#ROM emulation for 6502

with open("a.out", mode='rb') as file:
    instructions = bytearray(file.read())

#A15-A0
addr_pins = [27, 17, 4, 3, 20, 16, 12, 1, 7, 8, 25, 24, 23, 18, 15, 14]
#D7-D0
data_pins = [22,10,9,11,0,5,6,13]
# PHI2
clock_pin = 19
#R/W
rwb_pin = 26
clock_timing = time.time()

def exit_handler(sig, frame):
    GPIO.cleanup()
    sys.exit(0)
    
def clock_trigger(pin):
    global clock_timing
    r_w = GPIO.input(rwb_pin)
    status = 'r' if r_w else 'W'
    addr = read_addr()
    current_clock = time.time()
    clk_diff = (current_clock - clock_timing) * 1000
    freq = 1/(current_clock - clock_timing)
    clock_timing = current_clock
    if r_w:
        data = instructions[addr]
        set_data(data)
        #reading = 'Addr: {:04x} {} {:02x} - ({:016b}) - {:.2f}ms({:.2f}Hz)'.format(addr,status, data, addr, clk_diff, freq)
        reading = 'Addr: {:04x} {} {:02x} - {:.2f}ms({:.2f}Hz)'.format(addr,status, data, clk_diff, freq)
        print(reading)
    else:
        data = read_data()
        #writing = 'Addr: {:04x} {} {:02x} - ({:016b}) - {:.2f}ms({:.2f}Hz)'.format(addr,status, data, addr, clk_diff, freq)
        writing = 'Addr: {:04x} {} {:02x} - {:.2f}ms({:.2f}Hz)'.format(addr,status, data, clk_diff, freq)
        instructions[addr] = data
        print(writing)

def read_addr():
    addr = 0
    for i in addr_pins:
        addr = (addr << 1) + GPIO.input(i)
    return addr

def set_data(data):
    for i, pin in enumerate(reversed(data_pins)):
        GPIO.setup(pin, GPIO.OUT)
        GPIO.output(pin, data & 1)
        data = data >> 1

def read_data():
    for i in data_pins:
        GPIO.setup(i, GPIO.IN)
    data = 0
    for i in data_pins:
        data = (data << 1) + GPIO.input(i)
    return data

GPIO.setmode(GPIO.BCM)
GPIO.setup(rwb_pin, GPIO.IN)
#GPIO.setup(clock_pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(clock_pin, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

for i in addr_pins:
    GPIO.setup(i, GPIO.IN)

# GPIO.add_event_detect(clock_pin, GPIO.FALLING, 
#         callback=clock_trigger, bouncetime=20)

GPIO.add_event_detect(clock_pin, GPIO.RISING, 
        callback=clock_trigger)

signal.signal(signal.SIGINT,exit_handler)
signal.pause()
