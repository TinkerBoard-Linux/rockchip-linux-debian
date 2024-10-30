import ASUS.GPIO as GPIO
GPIO.setmode(GPIO.BOARD)
GPIO.setup(4, GPIO.OUT)
GPIO.output(4, GPIO.HIGH)
