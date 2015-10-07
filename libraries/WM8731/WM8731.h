/*

 WM8731 - Summarize your library here.

 Describe your library here.

 License: GNU General Public License V3

 (C) Copyright (Your Name Here)
 
 For more help on how to make an Arduino style library:
 http://arduino.cc/en/Hacking/LibraryTutorial

 */

#ifndef __WM8731_H__
#define __WM8731_H__

#include <inttypes.h> 
#include <zpuino-types.h>
#include <zpuino.h>
#include "Arduino.h"
#include "i2c.h"

#define WM8731_SAMPLE_RATE 44100
#define WM8731_I2C_ADDRESS  0x1A

/* Define wishbone registers.
*/
#define WM8731_SAMPLE_IN  0
#define WM8731_SAMPLE_OUT 0
#define WM8731_STATUS     1

/* Define status flags.
 */
#define DAC_FIFO_EMPTY 0x01
#define DAC_FIFO_FULL  0x02
#define ADC_FIFO_EMPTY 0x04
#define ADC_FIFO_FULL  0x08

/* Define WM8731 registers.
 */
#define LEFT_LINE_IN            (0x00)  // 0x97
#define RIGHT_LINE_IN           (0x02)  // 0x97
#define LEFT_HEADLINE_OUT       (0x04)  // 0x79
#define RIGHT_HEADLINE_OUT      (0x06)  // 0x79
#define ANALOG_AUDIO_PATH       (0x08)  // 0x30
#define DIGITAL_AUDIO_PATH      (0x0A)  // 0x00
#define POWER_DOWN              (0x0C)  // 0x00 (all power downs disabled)
#define DIGITAL_AUDIO_FORMAT    (0x0E)  // 0x13 (DSP audio format)
#define SAMPLING_CONTROL        (0x10)  // 0x20 (44100 Hz, normal mode)
#define ACTIVE_CONTROL          (0x12)  // 0x00 (not active)
#define RESET_REGISTER          (0x0F)  // None

class WM8731
{
  public:   
    WM8731();   
    void setup(unsigned int wishboneSlot);
    uint32_t begin(i2c* zpu_i2c);
    void end(i2c* zpu_i2c);
    
    uint32_t getFifoStatus();
    uint32_t dacFifoIsEmpty();
    uint32_t dacFifoIsFull();
    uint32_t adcFifoIsEmpty();
    uint32_t adcFifoIsFull();
    
    void writeSample(uint32_t left, uint32_t right);
    void writeSample(uint32_t sample);
    void readSample(uint32_t *left, uint32_t *right);
    void readSample(uint32_t *sample);
      
  private:
    int wishboneSlot;
};

#endif
