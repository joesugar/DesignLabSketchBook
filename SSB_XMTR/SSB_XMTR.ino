/*
 SSB Transmitter
 
 Copyright 2015
 Joseph A. Consugar
 
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
  unsigned frequency_hz = 10000000;
  CORDIC_NCO.setTransmitFrequencyHz(frequency_hz);
  CORDIC_NCO.setAmplitude(32 << 8, 32 << 8);
  CORDIC_NCO.NcoEnable();  
}

void loop() 
{
}
