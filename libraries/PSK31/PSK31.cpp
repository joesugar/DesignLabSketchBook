/*

 PSK31 - Summarize your library here.

 Describe your library here.

 License: GNU General Public License V3

 (C) Copyright (Your Name Here)
 
 For more help on how to make an Arduino style library:
 http://arduino.cc/en/Hacking/LibraryTutorial

 */

#include "Arduino.h"
#include "PSK31.h"

/* Constructor.
 */
PSK31::PSK31()
{

}

/* Initialize the class.
 */
void PSK31::setup(unsigned int wishboneSlot)
{
  /* Set the wishbone slot.
   */
  (*this).wishboneSlot = wishboneSlot;
  (*this).clock_frequency = 96000000;
}


/* Set/get the transmit frequency.
 */
void PSK31::setTransmitFrequencyHz(unsigned transmit_frequency_Hz)
{
  /* Save in local variable.
   */
  (*this).transmit_frequency_Hz = transmit_frequency_Hz;
  
  /* Write to the hardware.
   */
  unsigned dds_increment = CalculateDDSInc(transmit_frequency_Hz);
  DDS_DATA = dds_increment;
}

unsigned PSK31::getTransmitFrequencyHz()
{
  /* Return the local variable.
   */
  return (*this).transmit_frequency_Hz;
}
    
    
/* Translate an ascii character to varicode.
 */
unsigned PSK31::AsciiToVaricode(int ascii)
{
  int index = 2 * ascii;
  unsigned return_code = 
    ((varicode[index+0] & 0x00FF) << 8) +
    ((varicode[index+1] & 0x00FF) << 0);
  return return_code;
}


/* Enable/disable the PSK hardware.
 */
void PSK31::PskEnable()
{
  CONTROL_REG = PSK_ENABLE;
}

void PSK31::PskDisable()
{
  CONTROL_REG = PSK_DISABLE;
}


/* Return flag indicating if the transmit register is empty.
 * TRUE if register is empty.
 * FALSE otherwise.
 */
boolean PSK31::TransmitRegisterIsEmpty()
{
  return DATA_REG_EMPTY;
}


/* Transmit varicode.
 */
void PSK31::Transmit(unsigned varicode)
{
  PSK_DATA = varicode;
}


/* Calculate the phase increment for the DDS.
 */
unsigned PSK31::CalculateDDSInc(unsigned frequency_hz)
{
    unsigned quotient = 0;
    unsigned acc = frequency_hz;
    
    for (int i = 0; i < 32; i++)
    {
        quotient = quotient << 1;
        acc = acc << 1;
        if (acc > clock_frequency)
        {
            quotient += 1;
            acc -= clock_frequency;
        }
    }
    return quotient;
}
