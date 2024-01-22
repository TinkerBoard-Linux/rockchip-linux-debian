#coding=UTF-8
import os
import subprocess
import sys

#Tinker Board R
gpio_a=[11, 8, 16, 147, 83, 81, 108, 150, 106, 100, 101, 17, 99, 23]
gpio_b=[12, 85, 146, 149, 82, 84, 107, 22, 105, 76, 102, 75, 117, 20]
#gpio_a=[252,253, 17,164,167,257,256,254,233,165,168,238]
#gpio_b=[161,160,184,166,162,163,171,255,251,234,239,223]
gpio_c=[122]
FAIL=0

def gpio_export(pin_number):
    if os.path.exists("/sys/class/gpio/gpio%d"%(pin_number)) == True:
       os.popen("./GPIOUnRegister.sh %d"%(pin_number))
       #MyProcess_a=subprocess.Popen("./GPIOUnRegister.sh %d"%(pin_number) , shell=True,stdout=subprocess.PIPE)
       #MyProcess_a.wait()
       #output=MyProcess_a.stdout.read()
       #print "%d-%s"%(pin_number , output)    
    os.popen("./GPIORegister.sh %d"%(pin_number))
    #MyProcess_b=subprocess.Popen("./GPIORegister.sh %d"%(pin_number) , shell=True,stdout=subprocess.PIPE)
    #MyProcess_b.wait()
    #output=MyProcess_b.stdout.read()
    #print "output %s"%(output)

def gpio_selftest(pin_a,pin_b):
    MyProcess_a=subprocess.Popen("./GPIOSelfTest.sh %d %d"%(pin_a , pin_b) , shell=True,stdout=subprocess.PIPE)
    MyProcess_a.wait()
    output=MyProcess_a.stdout.read()
    print "%d => %d \n%s"%(pin_a , pin_b , output)
    if "FAIL" in output:
        exit()

def main():
    times=int(sys.argv[1])
    for j in range(times):
        print "==================================="
        print "times: %d"%(j)
        print "==================================="
        i=0
        for i in range(len(gpio_a)):
            #print "echo %d > /sys/class/gpio/export"%(gpio_a[i])
            #print "echo %d > /sys/class/gpio/export"%(gpio_b[i])

            #prepare to GPIO
            print "prepare %d - %d" %(gpio_a[i] , gpio_b[i])
            gpio_export(gpio_a[i])
            gpio_export(gpio_b[i])


            #test each other
            gpio_selftest(gpio_a[i] , gpio_b[i])
            print "prepare %d - %d" %(gpio_b[i] , gpio_a[i])
            gpio_selftest(gpio_b[i] , gpio_a[i])
   

if __name__ == "__main__":
    main()
