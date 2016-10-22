/*
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2016 Joseph A. Consugar                       ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
----     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ----
---- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ----
---- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ----
---- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ----
---- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ----
---- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ----
---- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ----
---- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ----
---- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ----
---- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ----
---- POSSIBILITY OF SUCH DAMAGE.                                 ----
----                                                             ----
---------------------------------------------------------------------
*/

#ifndef __I2S_H__
#define __I2S_H__

#include <inttypes.h>
#include <zpuino-types.h>
#include <zpuino.h>
#include "Arduino.h"

/* Class definition
 */
class I2S
{
  public:
    /* Constructor.
     */
    I2S();

    /* Initializer.
     */
    void setup(unsigned int wishboneSlot);

    /* Read the most recent sample from the I2S interface.
     * Sample is 32 bits where the upper 16 bits are
     * the left channel, the lower 16 bits are the
     * right channel.  The 16 bit sample is taken to
     * be twos-complement.
     */
    unsigned long readSample();

    /* Write the control value to the register.
     * Bit 0 - LRALIGN.  If 0 audio data is not aligned with the
     *                   left/right clock.  If 1 the audio data is
     *                   left aligned with the left/right clock.
     */
    void writeControl(unsigned long value);

    /* Read the status value from the register.
     * Bit 0 - LRALIGN.  If 0 audio data is not aligned with the
     *                   left/right clock.  If 1 the audio data is
     *                   left aligned with the left/right clock.
     * Bit 1 - DATA_RDY  If 1 there is an audio sample ready to be
     *                   read.  If 0, it's already been read.
     */
    unsigned long readStatus();

    /* Helper routines to read the status bits.
     */
    bool sampleIsReady();

  private:
    int wishboneSlot;
};

#endif
