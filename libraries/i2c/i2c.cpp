/*
 * i2c - Class to use the OpenCores Wishbone I2C interface.
 */

#include "Arduino.h"
#include "i2c.h"

/* Constructor.
 */
i2c::i2c()
{

}

/* Setup routine
 */
void i2c::setup(unsigned int wishboneSlot)
{
  this->wishboneSlot = wishboneSlot;
}

/* Enable the core using the default low clock speed.
 */
void i2c::begin()
{ 
  setSpeed(LO_SPEED);
  REGISTER(IO_SLOT(wishboneSlot), I2C_CTR) = CTR_EN;
}

/* Enable the core using the specified clock speed.
 */
void i2c::begin(uint32_t clock_speed)
{
  setSpeed(clock_speed);
  REGISTER(IO_SLOT(wishboneSlot), I2C_CTR) = CTR_EN;
}

/* Disable the core.
 */
void i2c::end()
{
  REGISTER(IO_SLOT(wishboneSlot), I2C_CTR) = 0x00;
}

/* Set I2C clock speed.
 */
void i2c::setSpeed(uint32_t clock_speed)
{
  /* Register value calculation taken from I2C-Master Core Specification.
   */
  uint32_t reg_value = (CLOCK_SPEED / (5 * clock_speed)) - 1;
  REGISTER(IO_SLOT(wishboneSlot), I2C_PRERhi) = (reg_value >> 8) & 0x00FF;
  REGISTER(IO_SLOT(wishboneSlot), I2C_PRERlo) = (reg_value >> 0) & 0x00FF;
}

/* Write value to a specified register.
 */
uint32_t i2c::write(
    uint32_t i2c_address, uint32_t register_address, uint32_t data)
{
  int state_value = 0;

  /* Write the device address.
   */
  if (state_value == 0)
  {
    REGISTER(IO_SLOT(wishboneSlot), I2C_TXR) = i2c_address << 1;
    REGISTER(IO_SLOT(wishboneSlot), I2C_CR) = CR_WR | CR_STA;
    while ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_TIP) != 0);
    state_value = ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_RxACK) == 0) ? 1 : 0;
  }
    
  /* Write the register to which data is to be sent.
   */
  if (state_value == 1)
  {
    REGISTER(IO_SLOT(wishboneSlot), I2C_TXR) = register_address;
    REGISTER(IO_SLOT(wishboneSlot), I2C_CR) = CR_WR;
    while ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_TIP) != 0);
    state_value = ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_RxACK) == 0) ? 2 : 0;
  }
 
  /* Write the value.
   */
  if (state_value == 2)
  {
    REGISTER(IO_SLOT(wishboneSlot), I2C_TXR) = data;
    REGISTER(IO_SLOT(wishboneSlot), I2C_CR) = CR_WR | CR_STO;
    while ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_TIP) != 0);
    state_value = ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_RxACK) == 0) ? 3 : 0;
  }
  return (state_value == 0) ? ~I2C_SUCCESS : I2C_SUCCESS;
}

/* Read value from a specified register.
 */
uint32_t i2c::read(
    uint32_t i2c_address, uint32_t register_address, uint32_t *data_buffer)
{
  uint32_t state_value = 0;

  /* Write the device device address.
   */
  if (state_value == 0)
  {
    REGISTER(IO_SLOT(wishboneSlot), I2C_TXR) = (i2c_address << 1);
    REGISTER(IO_SLOT(wishboneSlot), I2C_CR) = CR_WR;
    while ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_TIP) != 0);
    state_value = ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_RxACK) == 0) ? 1 : 0;
  }
    
  /* Write the register from which data is to be read.
   */
  if (state_value == 1)
  {
    REGISTER(IO_SLOT(wishboneSlot), I2C_TXR) = register_address;
    REGISTER(IO_SLOT(wishboneSlot), I2C_CR) = CR_WR;
    while ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_TIP) != 0);
    state_value = ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_RxACK) == 0) ? 2 : 0;
  }

  /* Write the device read address.
   */
  if (state_value == 2)
  {
    REGISTER(IO_SLOT(wishboneSlot), I2C_TXR) = (i2c_address << 1) | 0x01;
    REGISTER(IO_SLOT(wishboneSlot), I2C_CR) = CR_WR | CR_STA;
    while ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_TIP) != 0);
    state_value = ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_RxACK) == 0) ? 3 : 0;
  }
 
  /* Read the value.
   */
  if (state_value = 3)
  {
    REGISTER(IO_SLOT(wishboneSlot), I2C_CR) = CR_RD | CR_STO | CR_ACK;
    while ((I2C_SR & SR_TIP) != 0);
    state_value = ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_RxACK) == 0) ? 4 : 0;
    *data_buffer = REGISTER(IO_SLOT(wishboneSlot), I2C_RXR);
  }
  /* Or stop on error (state_value == 0)
   */
  else
  {
    REGISTER(IO_SLOT(wishboneSlot), I2C_CR) = CR_STO;
    while ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_TIP) != 0);
  }
  return (state_value == 0) ? ~I2C_SUCCESS : I2C_SUCCESS;
}

/* Ping a specified address.
 */
uint32_t i2c::ping(
    uint32_t address)
{
  int step_value = 0;
  bool ack = false;
  
  /* Write the device address.
   */
  if (step_value == 0)
  {
    step_value = 1;
    REGISTER(IO_SLOT(wishboneSlot), I2C_TXR) = ((address << 1) | 0x00);
    REGISTER(IO_SLOT(wishboneSlot), I2C_CR) = CR_WR | CR_STA;
    while ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_TIP) != 0);
    ack = ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_RxACK) == 0);
  }

  /* Send stop on successful ack.
   */
  if (ack)
  {
    step_value = 2;
    REGISTER(IO_SLOT(wishboneSlot), I2C_CR) = CR_STO;
    while ((REGISTER(IO_SLOT(wishboneSlot), I2C_SR) & SR_TIP) != 0);
  }
  
  /* Return SUCCESS or FAILURE
   */
  return (ack) ? I2C_SUCCESS : step_value;
}
