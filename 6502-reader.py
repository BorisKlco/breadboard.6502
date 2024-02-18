import RPi.GPIO as GPIO
import time

#Read output from W65C02 - tested only on manual clock

#A15-A0
addr_pins = [14,15,18,23,24,25,8,7,1,12,16,20,3,4,17,27]
#D7-D0
data_pins = [22,10,9,11,0,5,6,13]
# PHI2
clock_pin = 19
#R/W
rwb_pin = 26

# ---🧹---#
GPIO.cleanup()
time.sleep(0.1)

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
GPIO.setup(clock_pin, GPIO.IN)
GPIO.setup(rwb_pin, GPIO.IN)

for i in addr_pins:
    GPIO.setup(i, GPIO.IN)
for i in data_pins:
    GPIO.setup(i, GPIO.IN)

#For monostable, manual clock
while True:
    if GPIO.input(clock_pin):
        addr = read_addr()
        data = read_data()
        status = 'r' if GPIO.input(rwb_pin) else 'W'
        reading = 'Addr: {:04x} {} {:02x} - ({:016b})'.format(addr,status, data, addr)
        print(reading)
        time.sleep(0.3)
