import ftd2xx as ft
import sys

from time import sleep
from ftd2xx.defines import *

def main():
    """ Send/receive data from the Papilio FPGA using the high speed
        mode of the FT232H.
    """
    # Create the device list.
    num_devices = ft.createDeviceInfoList()
    if (num_devices == 0):
        print "No devices found."
        sys.exit();
    print "Found {0} devices.".format(num_devices)
    
    # Get the device information for the device with sync FIFO mode.
    device_info = None
    device_index = 0
    for index in range(0, num_devices):
        device_info = ft.getDeviceInfoDetail(devnum = index, update = False)
        if (device_info['description'] == 'UM232H_245FIFO'):
            device_index = index
            break
    if (device_info == None):
        print "Device not found."
        sys.exit()
    
    # Open the device and configure for sync FIFO mode.
    ft.setVIDPID(0x0403, 0x6014)
    device = ft.open(dev = device_index)
    device.setBitMode(0xFF, 0x00)               # Reset mode
    sleep(.01)
    device.setBitMode(0xFF, 0x40)               # Sync FIFO mode
    device.setLatencyTimer(2)                   # Receive buffer timeout in msec
    device.setUSBParameters(4096, 4096)         # Set transfer in/out size to 4096
    device.setFlowControl(FLOW_RTS_CTS, 0, 0)   # Flow control method
    

if (__name__ == "__main__"):
    main()
    
