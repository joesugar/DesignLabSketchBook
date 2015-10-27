/*
 SSB Transmitter
 
 Copyright 2015
 Joseph A. Consugar
 
 */

#include "CORDIC_NCO.h"
#include "Timer.h"

CORDIC_NCO CORDIC_NCO;
  
bool timer(void *)
{
  Serial.println(".");
  return true;
}

void setup() 
{
  /* Initialization.
   */
  CORDIC_NCO.setup(5); 
  Serial.begin(9600);
  
  /* Wait for user to press enter...
   */
  Serial.print("Press enter to begin...\r\n");
  while (!Serial.available());
  while (Serial.available())
  Serial.read();

  /* Set the operating frequency (frequency is in Hz)
   */
  Serial.println("Configuring NCO...");
  unsigned frequency_hz = 10000000;
  CORDIC_NCO.setTransmitFrequencyHz(frequency_hz);
  CORDIC_NCO.NcoEnable();  
  CORDIC_NCO.setAmplitude(32 << 8, 32 << 8);
  Serial.println("NCO configured.");
  
  /* Configure the timer.
   */
  Serial.println("Configuring timers...");
  Timers.begin();
  int r = Timers.periodicHz(1, timer, 0, 1);
  if (r<0) 
  {
    Serial.println("Fatal error!");
  }   
  Serial.println("Timer configured.");
}

void loop() 
{
}
