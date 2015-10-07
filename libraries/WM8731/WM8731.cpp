/*

 WM8731 - Library for reading from/writing to the WM8731 core.

 (C) Copyright 2015  Joseph A. Consugar

 */

#include "Arduino.h"
#include "WM8731.h"
#include "i2c.h"

/* Constructor
 */
WM8731::WM8731()
{
}

/* Set up the core.
 */
void WM8731::setup(unsigned int wishboneSlot)
{
	this->wishboneSlot = wishboneSlot;
}

/* Initialize and enable the codec.
 */
uint32_t WM8731::begin(i2c *i2c)
{
    /* Reset the codec and load the registers.
     */
    while ((*i2c).write(WM8731_I2C_ADDRESS, RESET_REGISTER, 0x00) != I2C_SUCCESS);
    while ((*i2c).write(WM8731_I2C_ADDRESS, LEFT_LINE_IN, 0x17) != I2C_SUCCESS);
    while ((*i2c).write(WM8731_I2C_ADDRESS, RIGHT_LINE_IN, 0x17) != I2C_SUCCESS);
    while ((*i2c).write(WM8731_I2C_ADDRESS, LEFT_HEADLINE_OUT, 0x79) != I2C_SUCCESS);
    while ((*i2c).write(WM8731_I2C_ADDRESS, RIGHT_HEADLINE_OUT, 0x79) != I2C_SUCCESS);
    while ((*i2c).write(WM8731_I2C_ADDRESS, ANALOG_AUDIO_PATH, 0x12) != I2C_SUCCESS);
    while ((*i2c).write(WM8731_I2C_ADDRESS, DIGITAL_AUDIO_PATH, 0x00) != I2C_SUCCESS);
    while ((*i2c).write(WM8731_I2C_ADDRESS, POWER_DOWN, 0x00) != I2C_SUCCESS);
    while ((*i2c).write(WM8731_I2C_ADDRESS, DIGITAL_AUDIO_FORMAT, 0x13) != I2C_SUCCESS);
    while ((*i2c).write(WM8731_I2C_ADDRESS, SAMPLING_CONTROL, 0x20) != I2C_SUCCESS);
    while ((*i2c).write(WM8731_I2C_ADDRESS, ACTIVE_CONTROL, 0x01) != I2C_SUCCESS);
    return I2C_SUCCESS;
}

/* Shut down the codec.
 */
void WM8731::end(i2c *i2c)
{
    while ((*i2c).write(WM8731_I2C_ADDRESS, RESET_REGISTER, 0x00) != I2C_SUCCESS);
}

/* Return FIFO status register.
 */
uint32_t WM8731::getFifoStatus()
{
    return REGISTER(IO_SLOT(wishboneSlot),WM8731_STATUS);
}

/* Return TRUE if DAC FIFO is empty.
 */
uint32_t WM8731::dacFifoIsEmpty()
{
    return REGISTER(IO_SLOT(wishboneSlot),WM8731_STATUS) & DAC_FIFO_EMPTY;
}

/* Return TRUE if DAC FIFO is full.
 */
uint32_t WM8731::dacFifoIsFull()
{
    return REGISTER(IO_SLOT(wishboneSlot),WM8731_STATUS) & DAC_FIFO_FULL;
}

/* Return TRUE if DAC FIFO is empty.
 */
uint32_t WM8731::adcFifoIsEmpty()
{
    return REGISTER(IO_SLOT(wishboneSlot),WM8731_STATUS) & ADC_FIFO_EMPTY;
}

/* Return TRUE if DAC FIFO is full.
 */
uint32_t WM8731::adcFifoIsFull()
{
    return REGISTER(IO_SLOT(wishboneSlot),WM8731_STATUS) & ADC_FIFO_FULL;
}

/* Write a pair of samples to the DAC.
 */
void WM8731::writeSample(uint32_t left, uint32_t right)
{
    REGISTER(IO_SLOT(wishboneSlot),WM8731_SAMPLE_IN) = 
      (((left & 0x0000FFFF) << 16) | ((right & 0x0000FFFF) << 0));
}

/* Write a pair of samples to the DAC.
 */
void WM8731::writeSample(uint32_t sample)
{
    REGISTER(IO_SLOT(wishboneSlot),WM8731_SAMPLE_IN) = sample;
}

/* Read a pair of samples from the DAC.
 */
void WM8731::readSample(uint32_t *left, uint32_t *right)
{
    *left = REGISTER(IO_SLOT(wishboneSlot),WM8731_SAMPLE_OUT);
    *right = ((*left) >>  0) & 0x0000FFFF;
    *left  = ((*left) >> 16) & 0x0000FFFF;
}

/* Read a pair of samples from the DAC.
 */
void WM8731::readSample(uint32_t *sample)
{
    *sample = REGISTER(IO_SLOT(wishboneSlot),WM8731_SAMPLE_OUT);
}
