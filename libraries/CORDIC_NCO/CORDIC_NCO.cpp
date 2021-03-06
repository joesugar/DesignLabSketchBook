/*
 * CORDIC NCO
 * Control software for the numericallon controlled oscillator 
 * based on the CORDIC algorithm.
 * 
 * Author: J. Consugar
 * 
 * Copyright (C) 2014 J. Consugar
 * 
 * This source file may be used and distributed without
 * restriction provided that this copyright statement is not
 * removed from the file and that any derivative work contains
 * the original copyright notice and the associated disclaimer
 * 
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT
 * INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE
 */

#include "Arduino.h"
#include "CORDIC_NCO.h"

/* Initialization.
 */
CORDIC_NCO::CORDIC_NCO()
{
}

void CORDIC_NCO::setup(unsigned int wishboneSlot)
{
  (*this).wishboneSlot = wishboneSlot;
  (*this).clock_frequency = CLOCK_FREQUENCY;
}

/* Set/get the transmit frequency.
 */
void CORDIC_NCO::setTransmitFrequencyHz(unsigned transmit_frequency_Hz)
{
  /* Save in local variable.
   */
  (*this).transmit_frequency_Hz = transmit_frequency_Hz;
  
  /* Write to the hardware.
   */
  unsigned dds_increment = CalculateDDSInc(transmit_frequency_Hz);
  PHASE_INC = dds_increment;
}

unsigned CORDIC_NCO::getTransmitFrequencyHz()
{
  /* Return the local variable.
   */
  return (*this).transmit_frequency_Hz;
}

/* Set the signal amplitude.
 * Note:  Amplitudes are signed values in the range from 
 * -32768 to 32767.
 */
void CORDIC_NCO::setAmplitude(int i_amplitude, int q_amplitude)
{
  i_amplitude = (i_amplitude << 16) & 0xFFFF0000;
  q_amplitude = (q_amplitude <<  0) & 0x0000FFFF;
  unsigned iq_amplitude = i_amplitude | q_amplitude;
  IQ_AMP = iq_amplitude;
}

/* Set the signal amplitude.
 * Amplitude is an I/Q pair.  Upper 16 bits is I, 
 * lower 16 bits is Q.  I and Q are interpretted as
 * signed values in the range from -32768 to 32767.
 * This means bit 31 is the sign bit for the I and
 * bit 15 is the sign bit for the Q.
 */
void CORDIC_NCO::setAmplitude(unsigned iq_amplitude)
{
  IQ_AMP = iq_amplitude;
}

/* Get the signal amplitude as I/Q pair.
 */
void CORDIC_NCO::getAmplitude(int *i_amplitude, int *q_amplitude)
{
  unsigned iq_amplitude = IQ_AMP;
  (*i_amplitude) = ((int)((iq_amplitude & 0xFFFF0000) <<  0)) >> 16;
  (*q_amplitude) = ((int)((iq_amplitude & 0x0000FFFF) << 16)) >> 16;
}

/* Get the signal amplitude as a packed I/Q pair.
 * The upper 16 bits are the I, the lower 16 bits are the Q.
 * I and Q are interpretted as signed 16 bit values in the
 * range from -32768 to 32767.
 */
void CORDIC_NCO::getAmplitude(unsigned *iq_amplitude)
{
  (*iq_amplitude) = IQ_AMP;
}

/* Enable the NCO.
 */
void CORDIC_NCO::NcoEnable()
{
  CONTROL_REG = NCO_ENABLE;
}

/* Disable the NCO.
 */
void CORDIC_NCO::NcoDisable()
{
  CONTROL_REG = NCO_DISABLE;
}

/* Return flag indicating if the FIFO is full.
 */
bool CORDIC_NCO::FifoFull()
{
  return NCO_FIFO_FULL;
}
  
/* Return flag indicating if the FIFO is empty.
 */
bool CORDIC_NCO::FifoEmpty()
{
  return NCO_FIFO_EMPTY;
}
    
/* Calculate the phase increment for the DDS.
 */
unsigned CORDIC_NCO::CalculateDDSInc(unsigned frequency_hz)
{
  unsigned quotient = 0;
  unsigned acc = frequency_hz;
    
  for (int i = 0; i < 32; i++)
  {
    quotient = quotient << 1;
    acc = acc << 1;
    if (acc > clock_frequency)
    {
      quotient += 1;
      acc -= clock_frequency;
    }
  }
  return quotient;
}

