/*

 I2S - Summarize your library here.

 Describe your library here.

 License: GNU General Public License V3

 (C) Copyright (Your Name Here)

 For more help on how to make an Arduino style library:
 http://arduino.cc/en/Hacking/LibraryTutorial

 */

#ifndef __I2S_H__
#define __I2S_H__

#include <inttypes.h>
#include <zpuino-types.h>
#include <zpuino.h>
#include "Arduino.h"

class I2S
{
  public:
    I2S();
    void setup(unsigned int wishboneSlot);

    unsigned long readSample();

    unsigned long readData();
    void writeData(unsigned long value);

  private:
    int wishboneSlot;
};

#endif
