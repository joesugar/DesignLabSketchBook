/*

 i2c - Summarize your library here.

 Describe your library here.

 License: GNU General Public License V3

 (C) Copyright (Your Name Here)
 
 For more help on how to make an Arduino style library:
 http://arduino.cc/en/Hacking/LibraryTutorial

 */

#include "Arduino.h"
#include "i2c.h"

/* Constructor.
 */
i2c::i2c()
{

}

/* Setup routine
 */
void i2c::setup(unsigned int wishboneSlot)
{
  this->wishboneSlot = wishboneSlot;
}

unsigned long i2c::readRegister()
{

}

void i2c::writeRegister(unsigned long value)
{

}

 

 
/* Define I2C devivce address.
*/
#define I2C_DEVICE_ADDRESS 0x69
void setup()
{
   pinMode(I2C_SCL_O, OUTPUT);
   pinModePPS(I2C_SCL_O, HIGH);
   outputPinForFunction(I2C_SCL_O, I2C_SCL);
 
   pinMode(I2C_SCL_I, INPUT );
   inputPinForFunction (I2C_SCL_I, I2C_SCL);
 
   pinMode(I2C_SDA_O, OUTPUT);
   pinModePPS(I2C_SDA_O, HIGH);
   outputPinForFunction(I2C_SDA_O, I2C_SDA);
 
   pinMode(I2C_SDA_I, INPUT );
   inputPinForFunction (I2C_SDA_I, I2C_SDA);
 
   Serial.begin(9600);
}
 
int count = 0;
void loop()
{
   Serial.print("Calculating tuned frequency...\r\n");
   while (!Serial.available());
   while (Serial.available())
      Serial.read();
 
   // Write the value to the device register.
   int lengthTransferred = 0;
 
   // Write the device address.
   I2C_TXR = 0x69 << 1;
   I2C_CR = CR_WR | CR_STA;
   while ((I2C_SR & SR_TIP) != 0);
 
   // Get the acknowledgement.
   lengthTransferred = ((I2C_SR & SR_RxACK) == 0) ? 1 : 0;
   if (lengthTransferred == 1)
   {
      // Write the register.
      I2C_TXR = REG_DIV1;
      I2C_CR = CR_WR;
      while ((I2C_SR & SR_TIP) != 0);
 
      // Get the acknowledgement.
      lengthTransferred = ((I2C_SR & SR_RxACK) == 0) ? 2 : 0;
   }
 
   if (lengthTransferred == 2)
   {
      // Write the value.
      I2C_TXR = count;
      I2C_CR = CR_WR | CR_STO;
      while ((I2C_SR & SR_TIP) != 0);
 
      // Get the acknowledgement.
      lengthTransferred = ((I2C_SR & SR_RxACK) == 0) ? 3 : 0;
   }
 
   Serial.print("Length transferred during write = ");
   Serial.print(lengthTransferred);
   Serial.print("\r\n");
 
   // Read the value back from the device.
   lengthTransferred = 0;
 
   // Write the device address.
   I2C_TXR = (0x69 << 1);
   I2C_CR = CR_WR | CR_STA;
   while ((I2C_SR & SR_TIP) != 0);
 
   // Get the acknowledgement.
   lengthTransferred = ((I2C_SR & SR_RxACK) == 0) ? 1 : 0;
 
   // Write the register.
   if (lengthTransferred == 1)
   {
      // Write the register.
      I2C_TXR = REG_DIV1;
      I2C_CR = CR_WR;
      while ((I2C_SR & SR_TIP) != 0);
 
      // Get the acknowledgement.
      lengthTransferred = ((I2C_SR & SR_RxACK) == 0) ? 2 : 0;
   }
 
   // Write the read address.
   if (lengthTransferred == 2)
   {
      // Write the read address...
      I2C_TXR = (0x69 << 1) | 0x01;
      I2C_CR = CR_WR | CR_STA;
      while ((I2C_SR & SR_TIP) != 0);
 
      // Get the acknowledgement.
      lengthTransferred = ((I2C_SR & SR_RxACK) == 0) ? 3 : 0;
   }
 
   // Read the value.
   int value = 0;
   if (lengthTransferred = 3)
   {
      // Read the value.
      I2C_CR = CR_RD | CR_STO | CR_ACK;
      while ((I2C_SR & SR_TIP) != 0);
      value = I2C_RXR;
      lengthTransferred = 4;
   }
   else
   {
      I2C_CR = CR_STO;
      while ((I2C_SR & SR_TIP) != 0);
   }
 
   Serial.print("Length transferred during read = ");
   Serial.print(lengthTransferred);
   Serial.print("\r\n");
   Serial.print("Value read = ");
   Serial.print(value);
   Serial.print("\r\n");
   count++;
}
