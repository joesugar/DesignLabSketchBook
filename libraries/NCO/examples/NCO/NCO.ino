/*
 * NCO Example Sketch
 *
 * Copyright 2015 Joseph A. Consugar
 *
 * This code is in the public domain.
 */

#include "NCO.h"

NCO NCO;
 
void setup() 
{
  /* Initialize the serial port.
   */
  Serial.begin(9600);
  
  /* Set up the NCO.
   */
  Serial.println("NCO setup.");
  NCO.setup(5);      // Wishbone slot 5, default frequency.
}

void loop() 
{
  // Set a default frequency of 1000000;
  NCO.setFrequency(1000000);
}
