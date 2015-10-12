/*

 CORDIC_NCO - Summarize your library here.

 Describe your library here.

 License: GNU General Public License V3

 (C) Copyright (Your Name Here)
 
 For more help on how to make an Arduino style library:
 http://arduino.cc/en/Hacking/LibraryTutorial

 */

#include "Arduino.h"
#include "CORDIC_NCO.h"

/* Initialization.
 */
CORDIC_NCO::CORDIC_NCO()
{
}

void CORDIC_NCO::setup(unsigned int wishboneSlot)
{
  (*this).wishboneSlot = wishboneSlot;
  (*this).clock_frequency = CLOCK_FREQUENCY;
}

/* Set/get the transmit frequency.
 */
void CORDIC_NCO::setTransmitFrequencyHz(unsigned transmit_frequency_Hz)
{
  /* Save in local variable.
   */
  (*this).transmit_frequency_Hz = transmit_frequency_Hz;
  
  /* Write to the hardware.
   */
  unsigned dds_increment = CalculateDDSInc(transmit_frequency_Hz);
  PHASE_INC = dds_increment;
}

unsigned CORDIC_NCO::getTransmitFrequencyHz()
{
  /* Return the local variable.
   */
  return (*this).transmit_frequency_Hz;
}

/* Set/get the signal amplitude.
 * Note:  Amplitudes are signed values in the range from 
 * -32768 to 32767.
 */
void CORDIC_NCO::setAmplitude(int i_amplitude, int q_amplitude)
{
  i_amplitude = (i_amplitude << 16) & 0xFFFF0000;
  q_amplitude = (q_amplitude <<  0) & 0x0000FFFF;
  unsigned iq_amplitude = i_amplitude | q_amplitude;
  IQ_AMP = iq_amplitude;
}

/* Enable/disable the PSK hardware.
 */
void CORDIC_NCO::NcoEnable()
{
  CONTROL_REG = NCO_ENABLE;
}

void CORDIC_NCO::NcoDisable()
{
  CONTROL_REG = NCO_DISABLE;
}

/* Calculate the phase increment for the DDS.
 */
unsigned CORDIC_NCO::CalculateDDSInc(unsigned frequency_hz)
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

