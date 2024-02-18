import RPi.GPIO as GPIO
import signal
import sys
import time

#Read output from 6502 

#A15-A0
addr_pins = [27, 17, 4, 3, 20, 16, 12, 1, 7, 8, 25, 24, 23, 18, 15, 14]
#D7-D0
data_pins = [22,10,9,11,0,5,6,13]
# PHI2
clock_pin = 19
#R/W
rwb_pin = 26

# ---🧹---#
GPIO.cleanup()
time.sleep(0.1)

def exit_handler(sig, frame):
    GPIO.cleanup()
    sys.exit(0)

def clock_trigger(pin):
    addr = read_addr()
    data = read_data()
    status = 'r' if GPIO.input(rwb_pin) else 'W'
    reading = 'Addr: {:04x} {} {:02x} - ({:016b})'.format(addr,status, data, addr)
    print(reading)

def read_addr():
    addr = 0
    for i in addr_pins:
        addr = (addr << 1) + GPIO.input(i)
    return addr

def read_data():
    data = 0
    for i in data_pins:
        data = (data << 1) + GPIO.input(i)
    return data

GPIO.setmode(GPIO.BCM)
GPIO.setup(rwb_pin, GPIO.IN)
GPIO.setup(clock_pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)

for i in addr_pins:
    GPIO.setup(i, GPIO.IN)
for i in data_pins:
    GPIO.setup(i, GPIO.IN)

#Tested on manual clock
GPIO.add_event_detect(clock_pin, GPIO.FALLING, 
        callback=clock_trigger, bouncetime=100)

signal.signal(signal.SIGINT,exit_handler)
signal.pause()
