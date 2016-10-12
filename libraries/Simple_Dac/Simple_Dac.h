/*

 Simple_Dac - Summarize your library here.

 Describe your library here.

 License: GNU General Public License V3

 (C) Copyright (Your Name Here)

 For more help on how to make an Arduino style library:
 http://arduino.cc/en/Hacking/LibraryTutorial

 */

#ifndef __Simple_Dac_H__
#define __Simple_Dac_H__

#include <inttypes.h>
#include <zpuino-types.h>
#include <zpuino.h>
#include "Arduino.h"

class Simple_Dac
{
  public:
    Simple_Dac();
    void setup(unsigned int wishboneSlot);
    unsigned long readSample();
    void writeSample(unsigned long value);
  private:
    int wishboneSlot;
};

#endif
