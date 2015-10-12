/*

 CORDIC_NCO - Summarize your library here.

 Describe your library here.

 License: GNU General Public License V3

 (C) Copyright (Your Name Here)
 
 For more help on how to make an Arduino style library:
 http://arduino.cc/en/Hacking/LibraryTutorial

 */

#ifndef __CORDIC_NCO_H__
#define __CORDIC_NCO_H__

#include <inttypes.h> 
#include <zpuino-types.h>
#include <zpuino.h>
#include "Arduino.h"

/* Defined constants.
 */
#define CLOCK_FREQUENCY  96000000

/* Wishbone registers.
 */
#define NCO_BASE    IO_SLOT(wishboneSlot) 
#define IQ_AMP      REGISTER(NCO_BASE, 0)
#define PHASE_INC   REGISTER(NCO_BASE, 1)
#define CONTROL_REG REGISTER(NCO_BASE, 2)
#define STATUS_REG  REGISTER(NCO_BASE, 2)

/* Control values
 */
#define NCO_ENABLE  0x01
#define NCO_DISABLE 0x00

/* Status masks
 */
#define NCO_ENABLED ((STATUS_REG & NC_ENABLE) != 0)

/* Class definition.
 */
class CORDIC_NCO
{
  public:
    CORDIC_NCO();
	  void setup(unsigned wishboneSlot);
	  
    void setTransmitFrequencyHz(unsigned transmit_frequency_hz);
	  unsigned getTransmitFrequencyHz();

    void setAmplitude(int i_amplitude, int q_amplitude);
    
    void NcoEnable();
    void NcoDisable();
    	  
  private:
    int wishboneSlot;
    int transmit_frequency_Hz;
	  unsigned clock_frequency;
    
    unsigned CalculateDDSInc(unsigned frequency_hz);
};

#endif
