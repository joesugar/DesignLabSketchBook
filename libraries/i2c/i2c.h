#ifndef _ZPU_I2C_H_
#define _ZPU_I2C_H_

#include <inttypes.h> 
#include <zpuino-types.h>
#include <zpuino.h>
#include "Arduino.h"

/* Define I2C registers.
 */
#define I2C_PRERlo  0
#define I2C_PRERhi  1
#define I2C_CTR     2
#define I2C_TXR     3
#define I2C_RXR     3
#define I2C_CR      4
#define I2C_SR      4
 
/* I2C core control register bit definitions.
 */
#define CTR_EN 0x80     // i2c core enable bit.
                        // When set to ‘1’, the core is enabled.
                        // When set to ‘0’, the core is disabled.
#define CTR_IEN 0x40    // i2c core interrupt enable bit.
                        // When set to ‘1’, interrupt is enabled.
                        // When set to ‘0’, interrupt is disabled.
 
/* I2C core command register bit definitions.
 */
#define CR_STA  0x80    // generate (repeated) start condition
#define CR_STO  0x40    // generate stop condition
#define CR_RD   0x20    // read from slave
#define CR_WR   0x10    // write to slave
#define CR_ACK  0x08    // when a receiver, send ACK (ACK = ‘0’) or NACK (ACK = ‘1’)
#define CR_IACK 0x01    // interrupt acknowledge. When set, clears a pending interrupt.
 
/* I2C status register bit definitions.
 */
#define SR_RxACK 0x80   // received acknowledge from slave.
                        // This flag represents acknowledge from the addressed slave.
                        // ‘1’ = No acknowledge received
                        // ‘0’ = Acknowledge received
#define SR_BUSY 0x40    // i2c bus busy
                        // ‘1’ after START signal detected
                        // ‘0’ after STOP signal detected
#define SR_AL 0x20      // arbitration lost
                        // This bit is set when the core lost arbitration.
                        // Arbitration is lost when:
                        // a STOP signal is detected, but non requested
                        // The master drives SDA high, but SDA is low.
#define SR_TIP 0x02     // transfer in progress.
                        // ‘1’ when transferring data
                        // ‘0’ when transfer complete
#define SR_IF 0x01      // interrupt Flag. This bit is set when an
                        // interrupt is pending, which will cause a
                        // processor interrupt request if the IEN bit is set.
                        // The Interrupt Flag is set when:
                        // one byte transfer has been completed
                        // arbitration is lost
 
/* I2C core read/write flags.
 */
#define I2C_M_WR 0x00
#define I2C_M_RD 0x01
 
/* Define I2C device address.
 */
#define HIGH_SPEED_CLOCK  1
#define LOW_SPEED_CLOCK   0

#define CLOCK_SPEED 96000000
#define LO_SPEED      100000
#define HI_SPEED      400000

#define I2C_SUCCESS 0

class i2c
{
  public:   
    i2c();  
    void setup(unsigned int wishboneSlot); 
    void begin();
    void begin(uint32_t clock_speed);
    void end();
        
    void setSpeed(uint32_t clock_speed);
    uint32_t write(uint32_t address, uint32_t registerAddress, uint32_t data);
    uint32_t read(uint32_t address, uint32_t register, uint32_t *dataBuffer);
    uint32_t ping(uint32_t address);
        
  private:
    int wishboneSlot;      
};
    
#endif
