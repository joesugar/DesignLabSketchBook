/*
 SSB Transmitter
 
 Copyright 2015
 Joseph A. Consugar
 
 */

#include "CORDIC_NCO.h"
#include "Timer.h"

CORDIC_NCO cordic;
  
bool timer(void *)
{
  Serial.println(".");
  return true;
}

void setup() 
{
  int i_amplitude = 0;
  int q_amplitude = 0;
  
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
  setTimer(2000);   // 48 kHz
  showFlags();

  waitForEnter();
  getTimer();
  showFlags();
    
  /* Set the amplitude.
   */
  for (unsigned i = 77; i <= 78; i += 1)
  {
    waitForEnter();
    Serial.print("i = "); Serial.println(i);
    i_amplitude = (-1 * i) << 8;
    q_amplitude = 0 << 8;  
    setAmplitude((unsigned)((i_amplitude << 16) | (q_amplitude << 0)));
    showFlags();
  }
}

void loop() 
{
}

void configureNCO()
{
  Serial.println("Configuring NCO...");
  unsigned frequency_hz = 10000000;
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
  Serial.println("Setting amplitude:");
  Serial.print("I = "); Serial.println(i_amplitude);
  Serial.print("Q = "); Serial.println(q_amplitude);
  cordic.setAmplitude(i_amplitude, q_amplitude);
}

void setAmplitude(unsigned iq_amplitude)
{
  Serial.println("Setting amplitude:");
  Serial.print("I/Q = "); Serial.println(iq_amplitude);
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
