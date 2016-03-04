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

#define FIFO_FULL   0x04
#define FIFO_EMPTY  0x02

/* Status masks
 */
#define NCO_ENABLED     ((STATUS_REG & NCO_ENABLE) != 0)
#define NCO_FIFO_FULL   ((STATUS_REG & FIFO_FULL)  != 0)
#define NCO_FIFO_EMPTY  ((STATUS_REG & FIFO_EMPTY) != 0)

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
    void setAmplitude(unsigned iq_amplitude);
    
    void getAmplitude(int *i_amplitude, int *q_amplitude);
    void getAmplitude(unsigned *iq_amplitude);
    
    void NcoEnable();
    void NcoDisable();
    	  
    bool FifoFull();
    bool FifoEmpty();
    
  private:
    int wishboneSlot;
    int transmit_frequency_Hz;
    unsigned clock_frequency;
    
    unsigned CalculateDDSInc(unsigned frequency_hz);
};

#endif
