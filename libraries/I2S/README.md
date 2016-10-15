
These files describe a simple I2S receiver with a Wishbone interface.

The receiver was modeled after the SGTL5000 stereo codec.  Only the I2S 
protocol described on page 18 of the datasheet has been implemented.  This
is good and bad.  Limited functionality but since the hardware is 
preconfigured, there's no need for an I2C interface. 

Left channel data is returned in the upper 16 bits of the returned data.
Right channel data is retuned in the lower 16 bits of the returned data.

The point of this was to provide an interface to get audio data into the
Papilio FPGA board for further processing.  Was tested at an audio data
rate of 44.1 kHz but may work at 48 kHz.  It only includes the minimum 
functionality necessary to get audio data into the FPGA.  Hence, inclusion 
of only a single protocol and implementation of the receive portion only.

