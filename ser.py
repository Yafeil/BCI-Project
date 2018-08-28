# coding:utf-8
import serial

ser = serial.Serial('COM3',
                    baudrate=115200,
                    bytesize=8,
                    parity='N',
                    stopbits=1,
                    timeout=0.5)

cmd_conf = '11 22 33 44 01 00 18 00 05 00 00 00 02 00 00 00 05 00 00 00 02 00 00 00 05 00 00 00 02 00 00 00'
cmd_start = '11 22 33 44 02 00 18 00 05 00 00 00 02 00 00 00 05 00 00 00 02 00 00 00 05 00 00 00 02 00 00 00'
cmd_stop = '11 22 33 44 03 00 18 00 05 00 00 00 02 00 00 00 05 00 00 00 02 00 00 00 05 00 00 00 02 00 00 00'


cmd = bytes.fromhex(cmd_stop)
print(ser.portstr)
ser.write(cmd)
ser.close()



