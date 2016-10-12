/*

 Simple_Dac - Summarize your library here.

 Describe your library here.

 License: GNU General Public License V3

 (C) Copyright (Your Name Here)

 For more help on how to make an Arduino style library:
 http://arduino.cc/en/Hacking/LibraryTutorial

 */

#include "Arduino.h"
#include "Simple_Dac.h"

#define AUDIO_SAMPLE    REGISTER(IO_SLOT(wishboneSlot),0)

Simple_Dac::Simple_Dac()
{

}

void Simple_Dac::setup(unsigned int wishboneSlot)
{
	this->wishboneSlot = wishboneSlot;
}

unsigned long Simple_Dac::readSample()
{
	return AUDIO_SAMPLE;
}

void Simple_Dac::writeSample(unsigned long value)
{
	AUDIO_SAMPLE = value;
}
