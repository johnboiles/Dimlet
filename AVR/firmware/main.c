//
//  main.c
//  Dimlet
//
//  Created by John Boiles on 7/17/09.
//  Copyright 2010 John Boiles. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//  Code to control AC lights using a pulse detection circuit and triac drivers. The ATTiny receives
//  commands through the UART and sets up timing accordingly.
//
//  DMX info from http://www.dmx512-online.com/packt.html

//I believe gcc defines this from the DF_CPU option
//#define F_CPU 8000000UL  // 8 MHz
#include <inttypes.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <util/delay.h>
#include "uart-m88.c"

//Struct to hold important information about a light
struct lightStruct{
    unsigned char id;
	unsigned char intensity;
};
typedef struct lightStruct light;

//Array of lights. Make sure this is volatile so the ISR checks it
#define NUMBEROFLIGHTS 4
volatile light Lights[NUMBEROFLIGHTS];

/* Initialize default values for all the lights */
void initLights(void){
    unsigned char i;
    for(i=0;i< NUMBEROFLIGHTS; i++){
        Lights[i].id= (1 << i);
        Lights[i].intensity=i*64;
    }    
}

struct eventStruct{
    unsigned short time;
    unsigned char lightid;
};
typedef eventStruct event;
event Events[NUMBEROFLIGHTS];
volatile unsigned char EventIterator;

/* Bubble sort - The array is small, and I'm having debugging problems */
void bubbleSort(event* This, unsigned char size){
    unsigned char indx;
    unsigned char indx2;
    event temp;
    event temp2;
    unsigned char flipped;
    
    if (size <= 1)
        return;
    
    indx = 1; 
    do
    {
        flipped = 0;
        for (indx2 = size - 1; indx2 >= indx; --indx2)
        {
            temp = This[indx2];
            temp2 = This[indx2 - 1];
            if (temp2.time > temp.time)
            {
                This[indx2 - 1] = temp;
                This[indx2] = temp2;
                flipped = 1;
            }
        }
    } while ((++indx < size) && flipped);

    
}


/* Insert Sort - Because we only have 4 items */
typedef char (*CMPFUN)(const event*, const event*);
void insertSort(event This[], CMPFUN fun_ptr, unsigned char first, unsigned char last){
/* for small sort, use insertion sort */
    //TODO: optomize this
unsigned char indx;
event prev_val = This[first];
event cur_val;

for (indx = first + 1; indx <= last; ++indx)
{
    cur_val = This[indx];
    if((*fun_ptr)(&prev_val, &cur_val) > 0)
    {
        /* out of order: array[indx-1] > array[indx] */
        unsigned char indx2;
        This[indx] = prev_val; /* move up the larger item first */
        
        /* find the insertion point for the smaller item */
        for (indx2 = indx - 1; indx2 > first; )
        {
            event temp_val = This[indx2 - 1];
            if ((*fun_ptr)(&temp_val, &cur_val) > 0)
            {
                This[indx2--] = temp_val;
                /* still out of order, move up 1 slot to make room */
            }
            else
                break;
        }
        This[indx2] = cur_val; /* insert the smaller item right here */
    }
    else
    {
        /* in order, advance to next element */
        prev_val = cur_val;
    }
}
}
void arraySort(event This[], CMPFUN fun_ptr, unsigned char the_len)
{
    insertSort(This, fun_ptr, 0, the_len - 1);
}
char cmpfun(const event* a, const event* b)
{
    if (a->time > b->time)
        return 1;
    else if (a->time < b->time)
        return -1;
    else
        return 0;
}

/* Input Capture ISR - Happens when a zero-crossing on the ac line is 
 * detected NOTE: PB0 is ICP1 */
ISR (TIMER1_CAPT_vect)
//ISR(TIMER1_COMPB_vect)
{
    //turn everything off immediately, we can only switch the triac off
    //at the zero crossing, we can turn it on very soon if need be
    PORTC &= ~0x0F;
    
    PORTB |= 0x02;
    unsigned char i;    
 
    //Check all lights to see if any need to be turned on or off
    for(i=0;i<NUMBEROFLIGHTS;i++){
        //Because this isr is long, we have to cut off a number of steps close to full brightness
        if(Lights[i].intensity >= 248){
            PORTC |= Lights[i].id;
            Events[i].time = 0;
            //Events[i].id = 0;
        } else if (Lights[i].intensity <= 0) {
            //Already off
            //PORTC &= ~Lights[i].id;
            Events[i].time = 0;
        } else {
            //turn light off (to be turned off later)
            //PORTC &= ~Lights[i].id;
            //Add it to events
            Events[i].time = 8333 - ((Lights[i].intensity * 98) / 3);
            Events[i].lightid = Lights[i].id;
        }
    }
    
    //Sort events
    arraySort(Events,cmpfun,NUMBEROFLIGHTS);
    //bubbleSort(Events,NUMBEROFLIGHTS);
    
    EventIterator = 0;
    //Find the first event, set up OC
    while(EventIterator<NUMBEROFLIGHTS){
        if(Events[EventIterator].time != 0){
            //Enable OC
            TIMSK1 |= _BV(OCIE1A);
            //Clear the flag; it may need to be cleared
            TIFR1 = _BV(OCF1A);
            OCR1A = ICR1 + Events[EventIterator].time;
            //As soon as we set up an event, return
                PORTB &= ~0x02;
            return;
        } else {
            EventIterator++;
        }
    }
        PORTB &= ~0x02;
}

/* Output Compare ISR - Turns off triacs when necessary */
// Note: TCNT is stored in OCR1A
ISR (TIMER1_COMPA_vect)
{
    
    PORTB |= 0x04;

    PORTC |= Events[EventIterator].lightid;
    //see if there's any other events we're supposed to handle do right now
    while((Events[EventIterator].time == Events[EventIterator+1].time)
        && (EventIterator < NUMBEROFLIGHTS)){
        EventIterator++;
        PORTC |= Events[EventIterator].lightid;
    }
    
    //If we are not out of events
    if(EventIterator < NUMBEROFLIGHTS){
        //Set up OC for next event
        EventIterator++;
        
        if(Events[EventIterator].time != 0){
                //Enable OC
                
                //Clear the flag; it may need to be cleared
                TIFR1 = _BV(OCF1A);
                OCR1A = ICR1 + Events[EventIterator].time;
        }
    } else {
        //Out of events: Turn off OC interrupts
        TIMSK1 &= ~_BV(OCIE1A);
    }
    PORTB &= ~0x04;
}

void ioinit (void)         
{
    //Timer1 will time our input captures
	//The clocksource determines the timer's frequency
    //CS = 1 ClkIO = Clk
    //CS = 2 ClkIO = Clk / 8
    //CS = 3 ClkIO = Clk / 64
    //CS = 4 ClkIO = Clk / 256
    //CS = 5 ClkIO = Clk / 1024//CS = 6,7 External Clock
	TCCR1A = 0;
    //Clock / 8 = 1MHz
	TCCR1B |= _BV(CS11); 
    //Rising edge Trigger
    TCCR1B |= _BV(ICES1);
    //Input capture noise canceler
    TCCR1B |= _BV(ICNC1);
	
    //Turn on OC1B for testing
    //TIMSK1 |= _BV(OCIE1B);
    
    /* Enable timer 1 IC interrupt */
    TIMSK1 |= _BV(ICIE1);
    
    
	DDRC = 0xFF;
    PORTC = 0x00;
    //PORTB is used for debug
    //PB0 is Input Capture
    DDRB = 0xFE;
    PORTB &= ~0x02;
    
	sei ();
}

//Tests the lights by fading them independently of eachother
void testPattern()
{
    unsigned char i;
    while(1){
        for(i=0;i<NUMBEROFLIGHTS;i++){
            //change intensity value for lights
            //TODO: this should time out if it takes more than
            //1 second
            Lights[i].intensity += 4;
        }
        _delay_ms(20);

    }
}

//This shows me that the compiler can figure out automatic copying
void eventsTest()
{
    event source;
    event copy;
    source.time= 1500;
    source.lightid = 0x0F;
    copy = source;
    _delay_ms(1000);
    if(copy.time==1500){
        PORTC |= 0x0F;
    }
    _delay_ms(1000);
    if(copy.lightid == 0x0F){
        PORTC |= 0xF0;
    }
    while(1);
}

int main (void)
{
	unsigned char i;
	unsigned char in;
	USART_Init(MYUBRR); 
    initLights();
	ioinit ();
	/* loop forever, the interrupts are doing the rest */
    
	for(;;){  
        //eventsTest();
        //testPattern();
        //Implementing a DMX-like protocol for possible future
        //adaptation to a DMX device
        //wait for command
		in = USART_Receive();
        
        //check if it's a start value (0 for dmx)
        if (in == 0){
            
            //get values for each light. Currently I'm just
            //leaving this as 4, but in the future it could be
            //more.
            //TODO: we shoud have a configureable starting address for DMX
            for(i=0;i<NUMBEROFLIGHTS;i++){
                //change intensity value for lights
                //TODO: this should time out if it takes more than
                //1 second
                Lights[i].intensity = USART_Receive();
         	}
        }
    }
	return (0);
}
