/*

 I2S - Summarize your library here.

 Describe your library here.

 License: GNU General Public License V3

 (C) Copyright (Your Name Here)

 For more help on how to make an Arduino style library:
 http://arduino.cc/en/Hacking/LibraryTutorial

 */

#include "Arduino.h"
#include "I2S.h"

/* Define the registers.
*/
#define I2S_DATA      REGISTER(IO_SLOT(wishboneSlot), 0)
#define I2S_SAMPLE    REGISTER(IO_SLOT(wishboneSlot), 1)

I2S::I2S()
{

}

void I2S::setup(unsigned int wishboneSlot)
{
    this->wishboneSlot = wishboneSlot;
}

unsigned long I2S::readSample()
{
    return I2S_SAMPLE;
}

unsigned long I2S::readData()
{
    return I2S_DATA;
}

void I2S::writeData(unsigned long value)
{
    I2S_DATA = value;
}
