//
//  LightControl.m
//  Dimlet
//
//  Created by John Boiles on 7/7/09.
//  Copyright 2009 John Boiles. All rights reserved.
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

#import "LightControl.h"
#import "SendUDP.h"

@implementation LightControl

//@synthesize intensities;

- (id)init {
	self = [super init];
	// Initialize network communications
	SUDP_Init("192.168.1.20");	
    //initializing  Mutable Array 
    //intensities = [[NSMutableArray alloc] initWithObjects:(NSInteger)0,(NSInteger)0,(NSInteger)0,(NSInteger)0,nil];
	return self;
}

- (unsigned char)charify: (float)toChar{
	int value = (int) toChar;
	if (value > 255) {value = 255;}
	if (value < 0) {value = 0;}
	return value = (unsigned char) value;
}

//- (void)sendCommandToLights: (float)motor andSteering: (float)steering {
- (void)sendCommandToLights: (float)light1:(float)light2:(float)light3:(float)light4; {
    // Send the accelerometer data
	// We do all the mathematics at this end so there is less to send
	unsigned char message[5];
    
    //DMX protocol starts with 0. I'm not calling this DMX yet, but maybe working
    //that way
	message[0]=0;
	message[1] = [self charify:(light1*255)];
    message[2]=[self charify:(light2*255)];
    message[3]=[self charify:(light3*255)];
    message[4]=[self charify:(light4*255)];   
    
    SUDP_SendMsg((char*)message,5);
}

- (void)stop {
	[self sendCommandToLights: 0 :0:0:0];
}

- (void)dealloc {
	SUDP_Close();
	[super dealloc];
}
	
@end
