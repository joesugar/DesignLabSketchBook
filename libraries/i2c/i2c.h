/*

 i2c - Summarize your library here.

 Describe your library here.

 License: GNU General Public License V3

 (C) Copyright (Your Name Here)
 
 For more help on how to make an Arduino style library:
 http://arduino.cc/en/Hacking/LibraryTutorial

 */

#ifndef __i2c_H__
#define __i2c_H__

#include <inttypes.h> 
#include <zpuino-types.h>
#include <zpuino.h>
#include "Arduino.h"

/* Define I2C registers.
*/
#define I2C_BASE   IO_SLOT(wishboneSlot)
#define I2C_PRERlo REGISTER(I2C_BASE, 0)
#define I2C_PRERhi REGISTER(I2C_BASE, 1)
#define I2C_CTR    REGISTER(I2C_BASE, 2)
#define I2C_TXR    REGISTER(I2C_BASE, 3)
#define I2C_RXR    REGISTER(I2C_BASE, 3)
#define I2C_CR     REGISTER(I2C_BASE, 4)
#define I2C_SR     REGISTER(I2C_BASE, 4)
 
/* I2C core control register bit definitions.
*/
#define CTR_EN  0x80  // i2c core enable bit.
                      // When set to ‘1’, the core is enabled.
                      // When set to ‘0’, the core is disabled.
#define CTR_IEN 0x40  // i2c core interrupt enable bit.
                      // When set to ‘1’, interrupt is enabled.
                      // When set to ‘0’, interrupt is disabled.

/* I2C core command register bit definitions.
*/
#define CR_STA  0x80  // generate (repeated) start condition
#define CR_STO  0x40  // generate stop condition
#define CR_RD   0x20  // read from slave
#define CR_WR   0x10  // write to slave
#define CR_ACK  0x08  // when a receiver, send ACK (ACK = ‘0’) or NACK (ACK = ‘1’)
#define CR_IACK 0x01  // interrupt acknowledge. When set, clears a pending interrupt.

/* I2C status register bit definitions.
*/
#define SR_RxACK 0x80 // received acknowledge from slave.
                      // This flag represents acknowledge from the addressed slave.
                      // ‘1’ = No acknowledge received
                      // ‘0’ = Acknowledge received
#define SR_BUSY  0x40 // i2c bus busy
                      // ‘1’ after START signal detected
                      // ‘0’ after STOP signal detected
#define SR_AL    0x20 // arbitration lost
                      // This bit is set when the core lost arbitration.
                      // Arbitration is lost when:
                      // a STOP signal is detected, but non requested
                      // The master drives SDA high, but SDA is low.
#define SR_TIP   0x02 // transfer in progress.
                      // ‘1’ when transferring data
                      // ‘0’ when transfer complete
#define SR_IF    0x01 // interrupt Flag. This bit is set when an
                      // interrupt is pending, which will cause a
                      // processor interrupt request if the IEN bit is set.
                      // The Interrupt Flag is set when:
                      // one byte transfer has been completed
                      // arbitration is lost

/* I2C core register definitions.
*/
#define REG_CLKOE   0x09
#define REG_DIV1    0x0C
#define REG_XDRV    0x12
#define REG_CAPLOAD 0x13
#define REG_PBHI    0x40
#define REG_PBLO    0x41
#define REG_QCNT    0x42
#define REG_MATRIX1 0x44
#define REG_MATRIX2 0x45
#define REG_MATRIX3 0x46
#define REG_DIV2    0x47
 
/* I2C core read/write flags.
*/
#define I2C_M_WR    0x00
#define I2C_M_RD    0x01


class i2c
{
  public:
    i2c();
	void setup(unsigned int wishboneSlot);
    unsigned long readButtons();
    void writeLEDs(unsigned long value);
  private:
    int wishboneSlot;
};

#endif
