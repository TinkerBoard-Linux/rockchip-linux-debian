from serial import *
from optparse import OptionParser, OptionGroup
import sys


if __name__ == "__main__":
    parser = OptionParser(prog="listen.py", usage="listen.py --serial /dev/ttyHS2", version="1.0", epilog="continuously listens to serial port and prints output")

    # Serial Options
    group = OptionGroup(parser, "Serial Options")
    group.add_option("-s", "--serial", dest="serial", type="string", help="Define the serial port to use")
    group.add_option("--serial-baudrate", dest="serial_baudrate", type="int", default=115200, help="Specifies the serial baudrate. By default the baudrate is 115200")
    parser.add_option_group(group)

    (options, args) = parser.parse_args()

    if options.serial is None:
        parser.error("serial arg missing")
        exit(-1)

    print("Opening port %s with baud %d" % (options.serial, options.serial_baudrate), file=sys.stderr)
    print("Use CTRL + C to end", file=sys.stderr)

    # Create serial port
    port = Serial(port=options.serial,
                  baudrate=options.serial_baudrate,
                  timeout=0.1)

    # Reset states and flush
    port.reset_input_buffer()
    port.reset_output_buffer()

    # Loop and continuously print output
    while True:
        # Read some bytes
        b = port.read(1000)
        # Decode as ascii
        string = b.decode('ascii', 'replace')
        # Print them out
        print(string, end='')
