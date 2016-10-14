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

#include "Arduino.h"
#include "Simple_Dac.h"

#define AUDIO_SAMPLE    REGISTER(IO_SLOT(wishboneSlot),0)

/* Constructor.
 */
Simple_Dac::Simple_Dac()
{

}

/* Initialization routine.
 * Used to set the wishbone slot being used.
 */
void Simple_Dac::setup(unsigned int wishboneSlot)
{
	this->wishboneSlot = wishboneSlot;
}

/* Read the sample back from the DAC.
 * Sample is 32 bits where the upper 16 bits are
 * the left channel, the lower 16 bits are the
 * right channel.  The 16 bit sample is taken to
 * be twos-complement.
 */
unsigned long Simple_Dac::readSample()
{
	return AUDIO_SAMPLE;
}

/* Write the sample to the DAC.
 * Sample is 32 bits where the upper 16 bits are
 * the left channel, the lower 16 bits are the
 * right channel.  The 16 bit sample is taken to
 * be twos-complement.
 */
void Simple_Dac::writeSample(unsigned long value)
{
	AUDIO_SAMPLE = value;
}
