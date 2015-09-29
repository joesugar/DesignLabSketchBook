/*
 * NCO - Numerically Controllerd Oscillator for ZPUino.
 *
 * (C) Copyright 2015 Joseph A. Consugar
 */

#ifndef __NCO_H__
#define __NCO_H__

#include <inttypes.h> 
#include <zpuino-types.h>
#include <zpuino.h>
#include "Arduino.h"

class NCO
{
  public:
    /* Initialization.
     */
    NCO();
    void setup(unsigned int wishboneSlot);
    
    /* Frequency property.
     */
    unsigned long getFrequency();
    void setFrequency(unsigned long frequencyHz);
  
  private:
    /* Private variables.
     */
    int wishboneSlot;
    unsigned long frequency_Hz;
    unsigned long clock_frequency_Hz;
    
    /* Private methods.
     */
    unsigned long calculateNcoConstant(
      unsigned long frequencyHz);
};

#endif
