/* Example Arduino sketch showing how to use the PSK31
 * block for the ZPUino.
 */

#include "PSK31.h"

PSK31 PSK31;

void setup()
{
    /* Initialize the wishbone location.
     */
    PSK.setup(5);
    
    /* Initialize the serial port.
     */
    Serial.begin(9600);

    /* Set the PSK frequency (frequency is in Hz)
     */
    unsigned frequency_hz = 1000;
    PSK31.setTransmitFrequency(frequency_hz);
    PSK31.PskEnable();
}

void loop() 
{
  /* Can't send data unless the transmit register is empty
   * so be sure to check that first.
   */
  if (PSK31.TransmitRegisterIsEmpty())
  {
    /* Transmit register is empty so see if any serial 
     * data is available.
     */
    if (Serial.available() > 0)
    {
      /* Read the incoming byte and send it out.
       */
      int incomingByte = Serial.read();
      unsigned varicode = PSK31.AsciiToVaricode(incomingByte);
      PSK31.Transmit(varicode);
    }
  }
}





