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

#include "i2c.h"

i2c i2c;
 
void setup() 
{
  Serial.begin(9600);

  unsigned int wishboneSlot = 5;
  i2c.setup(wishboneSlot);

  Serial.print("Press enter to begin...\r\n");
  while (!Serial.available());
  while (Serial.available())
    Serial.read();
  
  Serial.print("Enabling the I2C...\r\n");
  i2c.begin(5000);
  
  Serial.print("Searching for address...\r\n");
  bool address_found = false;
  for (uint32_t i = 0; i < 128; i++)
  {
    if (i2c.ping(i) == I2C_SUCCESS)
    {
      Serial.print("Address found at ");
      Serial.print(i);
      Serial.print("\r\n");
      address_found = true;
    }
  }
  
  if (!address_found)
  {
    Serial.println("No I2C device found.");
  }
}

void loop() 
{
}
