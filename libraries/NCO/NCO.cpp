/*
 * NCO - Numerically Controllerd Oscillator for ZPUino.
 *
 * (C) Copyright 2015 Joseph A. Consugar
 */

#include "Arduino.h"
#include "NCO.h"

/* Constructor.
 */
NCO::NCO()
{
  /* Initialize
   */
  frequency_Hz = 1000;             // Default frequency = 1 kHz.
  clock_frequency_Hz = 96000000;   // Clock frequency = 96 MHz.
}


/* Configure the class and hardware.
 */
void NCO::setup(unsigned int wishboneSlot)
{
  /* Set the ZPUino wishbone slot.
   */
  (*this).wishboneSlot = wishboneSlot;

  /* Set the default frequency.
   */
  unsigned long nco_constant = calculateNcoConstant(
    (*this).frequency_Hz);
  REGISTER(IO_SLOT(wishboneSlot),0) = nco_constant;
}


/* Frequency property.
 */
unsigned long NCO::getFrequency()
{
  return (*this).frequency_Hz;
}

void NCO::setFrequency(unsigned long frequencyHz)
{
  (*this).frequency_Hz = frequencyHz;
  
  /* Set the frequency in hardware.
   */
  unsigned long nco_constant = calculateNcoConstant(
    frequencyHz);
  REGISTER(IO_SLOT(wishboneSlot),0) = nco_constant;
}


/* Calculate the NCO constant corresponding to the given frequency.
 */
unsigned long NCO::calculateNcoConstant(
  unsigned long frequency_Hz)
{
  /* This algorithm is basically a binary division optimized
   * for calculating DDS frequency constants.
   *
   * Loop 32 times for 32 bit numbers.
   */
  unsigned long frequency_acc = frequency_Hz;
  unsigned long nco_constant = 0;
  for (int ii = 0; ii < 32; ii++)
  {
    nco_constant = (nco_constant << 1);
    frequency_acc = (frequency_acc << 1);
    if (frequency_acc >= (*this).clock_frequency_Hz)
    {
      nco_constant += 1;
      frequency_acc -= (*this).clock_frequency_Hz;
    }
  }
  return nco_constant;
}

