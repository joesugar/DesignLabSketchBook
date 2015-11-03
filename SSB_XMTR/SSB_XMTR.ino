/*
 SSB Transmitter
 
 Copyright 2015
 Joseph A. Consugar
 
 */

#include "CORDIC_NCO.h"
#include "Timer.h"
#include "math.h"

CORDIC_NCO cordic;
  
bool timer(void *)
{
  Serial.println(".");
  return true;
}

void setup() 
{
  int i_amplitude = 32 << 2;
  int q_amplitude = 32 << 2;
  
  /* Initialization.
   */
  cordic.setup(5); 
  Serial.begin(9600);
  
  /* Configure the NCO.
   */
  waitForEnter();
  configureNCO();
  showFlags();
  
  /* Configure the timer.
   */
  waitForEnter();
  setTimer(1920);
  showFlags();

  waitForEnter();
  getTimer();
  showFlags();
    
  /* Set the amplitude.
   */
  int i_amp = 32767;
  int q_amp = 32767;
  while (true)
  {
    if (!cordic.FifoFull())
    {
      i_amp = i_amp * -1;
      setAmplitude(i_amp, q_amp);
    }
  } 
}

void loop() 
{
}

void configureNCO()
{
  Serial.println("Configuring NCO...");
  unsigned frequency_hz = 100000;
  cordic.setTransmitFrequencyHz(frequency_hz);
  cordic.NcoEnable();  
  Serial.println("NCO configured.");
}
  
void showFlags()
{
  if (cordic.FifoFull())
    Serial.println("FIFO is full.");
  else if (cordic.FifoEmpty())
    Serial.println("FIFO is empty.");
  else
    Serial.println("Data in FIFO.");
}

void setTimer(unsigned timer_inc)
{
  Serial.print("Setting timer inc = "); Serial.println(timer_inc);
  cordic.setTimer(timer_inc);
}

unsigned getTimer()
{
  unsigned timer_inc = cordic.getTimer();
  Serial.print("Current timer inc = "); Serial.println(timer_inc);
}

void setAmplitude(int i_amplitude, int q_amplitude)
{
  //Serial.println("Setting amplitude:");
  //Serial.print("I = "); Serial.println(i_amplitude);
  //Serial.print("Q = "); Serial.println(q_amplitude);
  cordic.setAmplitude(i_amplitude, q_amplitude);
}

void setAmplitude(unsigned iq_amplitude)
{
  //Serial.println("Setting amplitude:");
  //Serial.print("I/Q = "); Serial.println(iq_amplitude);
  cordic.setAmplitude(iq_amplitude);
}

void getAmplitude()
{
  int i_amplitude = 0;
  int q_amplitude = 0;
  unsigned iq_amplitude = 0;
  cordic.getAmplitude(&iq_amplitude);
  Serial.println("Getting amplitude:");
  Serial.print("I/Q = "); Serial.println(iq_amplitude);
  //Serial.print("I = "); Serial.println(i_amplitude);
  //Serial.print("Q = "); Serial.println(q_amplitude); 
}
  
void waitForEnter()
{
  Serial.print("Press enter to continue...\r\n");
  while (!Serial.available());
  while (Serial.available())
  Serial.read();
}
