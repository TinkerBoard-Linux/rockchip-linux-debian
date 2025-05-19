# Maxim Test Firmware

Firmware built for hardware testing during PCBA production

## Loading OTP Keys and Firmware

Maxim test utilities will be delivered in a simple zip file with a file structure like this:
```
.
└── maxim-test.zip/
    ├── send_scp/
    │   └── src/
    │       ├── send_scp.py
    │       ├── listen.py
    │       └── ...
    ├── test-fw/
    │   ├── packet.list
    │   └── ...
    └── test-otp/
        ├── packet.list
        └── ...
```
Flashing is done via a single python script called `send_scp.py``. It has a help menu but will basically be operated as follows:
```
python3 ./send_scp/src/send_scp.py \
    -c MAX32558 \
    -s <SERIAL PORT> \
    --gpio-reset <RESET GPIO> \
    <DIRECTORY>
```
* **SERIAL PORT**: Path to the serial device file (i.e. /dev/ttyHS2, etc)
* **RESET GPIO**: Pin number of the sysfs GPIO connected to the reset line of the max chip. If you’d like to manually reset it prior to calling the script, you can omit this argument.
* **DIRECTORY**: A directory containing a packet.list file and several packet files


> Note: Python3 is required to run this utility. PySerial is baked in.

To load OTP keys, call above script with `./test-otp` as the directory. Then, call it again with `./test-fw` directory to load the firwmare.

## Getting Test Output

Testing happens autonomously every few seconds. There is no need to actively engage the firmware in any way. Output is dumped over serial port after every test run at baud 115200. You can use the `listen.py` utility to get output:
```
python3 ./send_scp/src/listen.py -s <SERIAL PORT>
```
* **SERIAL PORT**: Path to the serial device file (i.e. /dev/ttyHS2, etc)

The output is a JSON blob that looks like this:
```json
{
  "usn": "b26803111c08f35ffe08082c1a",
  "build_ver": "1.0.0",
  "vbat": 3005,
  "gpio_out": [ 4 ],
  "gpio_in": [
    { "pin": 0, "state": 1 },
    { "pin": 1, "state": 0 },
    { "pin": 2, "state": 0 },
    { "pin": 3, "state": 1 }
  ],
  "secalm": 0,
  "secdiag": 257,
  "secalm_hex": "0x0000",
  "secdiag_hex": "0x0101",
  "rtc": { "seconds": 1695976934, "subseconds": 92 }
}
```
| Syntax      | Description                                                 |
| ----------- | ----------------------------------------------------------- |
| usb         | Serial number unique to each chip                           |
| build_ver   | Firmware build version (for reference only)                 |
| vbat        | Battery voltage in millivolts                               |
| gpio_out    | List of GPIO pins that were output tested. During each test run, these are cycled high-then-low one at a time. |
| gpio_in     | List of GPIO pins that were input tested along with their sampled state |
| secalm      | SECALM value (decimal), which contains info about which mesh pairs are shorted together |
| secdiag     | SECDIAG value (decimal) (for reference only)                |
| secalm_hex  | SECALM value as hex string                                  |
| secdiag_hex | SECDIAG valie as hex string                                 |
| rtc         | Value of real-time clock. Will remain continuous until backup battery is pulled. May start at random value but will tick upwards every second |
