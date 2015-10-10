/*
 Gadget Factory
 Template to make your own Schematic Symbol and Community Core Library for the Papilio FPGA and DesignLab

 To use this sketch do the following steps:
  1) 
  
 Tools for generating your own libraries:
 

 Tutorials:
   http://learn.gadgetfactory.net
   http://gadgetfactory.net/learn/2013/10/29/papilio-schematic-library-getting-started/
  

 created 2014
 by Jack Gassett
 http://www.gadgetfactory.net
 
 This example code is in the public domain.
 */

#include "CORDIC_NCO.h"

CORDIC_NCO CORDIC_NCO;
 
void setup() 
{
  /* Initialization.
   */
  CORDIC_NCO.setup(5); 
  Serial.begin(9600);

  /* Set the operating frequency (frequency is in Hz)
   */
  unsigned frequency_hz = 1000000;
  CORDIC_NCO.setTransmitFrequencyHz(frequency_hz);
  CORDIC_NCO.NcoEnable();  
}

void loop() 
{
}
