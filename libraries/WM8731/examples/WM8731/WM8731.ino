/*
 Example code for the WM8731 codec.

 Copyright 2015  Joseph A. Consugar
 
 This code is in the public domain.
 */

#include "WM8731.h"
#include "i2c.h"

WM8731 wm8731;
i2c i2c;
 
void setup() 
{
  /* Set up the cores.
   */
  Serial.begin(9600);
  i2c.setup(5);
  wm8731.setup(6);   
  
  /* Wait for user to press enter...
   */
  Serial.print("Press enter to begin...\r\n");
  while (!Serial.available());
  while (Serial.available())
  Serial.read();
  
  /* Enable the i2c.
   */
  Serial.print("Enabling the I2C...\r\n");
  i2c.begin(5000);
    
  /* Find the WM8731 i2c address.
   */
  Serial.print("Searching for address...\r\n");
  for (uint32_t i = 0; i < 128; i++)
  {
    if (i2c.ping(i) == I2C_SUCCESS)
    {
      Serial.print("Address found at ");
      Serial.print(i);
      Serial.print("\r\n");
    }
  }
    
  Serial.print("Configuring the codec...\r\n");
  if (wm8731.begin(&i2c) != I2C_SUCCESS)
    Serial.print("Error configuring WM8731\r\n");
  Serial.print("Codec configured.\r\n");
}

uint32_t inc32 = 1486;    // 1 kHz
uint32_t acc32 = 0;
int32_t  out_sample = 0;
int32_t  out_sample_left = 0;
int32_t  out_sample_right = 0;
uint32_t i = 0;
void loop() 
{
  /*
  if (!zpu_wm8731.adcFifoIsEmpty())
  {
    zpu_wm8731.readSample(&acc32);
    if (!zpu_wm8731.dacFifoIsFull())
      zpu_wm8731.writeSample(acc32);
  }
  */
  /*
  if (!wm8731.dacFifoIsFull())
  {
    acc32 += inc32;
    if (acc32 > 65535)
      acc32 -= 65536;
        
    if (acc32 < 16384)
      out_sample = acc32;
    else if (acc32 < 32768 + 16384)
      out_sample = 32768 - acc32;
    else
      out_sample = acc32 - 65536;
    wm8731.writeSample(out_sample & 0x0000FFFF, out_sample & 0x0000FFFF); 
  }
  */
  if (!wm8731.dacFifoIsFull())
  {
    acc32 += inc32;
    if (acc32 > 65535)
      acc32 -= 65536;
    out_sample = 65535 - acc32;
    wm8731.writeSample(out_sample & 0x0000FFFF, out_sample & 0x0000FFFF); 
  }  
  /*
  if (!zpu_wm8731.adcFifoIsEmpty())
  {
    zpu_wm8731.readSample(&acc32);
    out_sample_left = ((acc32 >> 16) & 0x0000FFFF) - 32768;
    out_sample_right = ((acc32 >>  0) & 0x0000FFFF) - 32768;
    Serial.print(out_sample_left); 
    Serial.print(", ");
    Serial.print(out_sample_right);
    Serial.print("\r\n");
  }
  */
}
