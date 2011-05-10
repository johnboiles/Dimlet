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

- (id)init {
  if ((self = [super init])) {
    // Initialize network communications
    SUDP_Init("192.168.1.20");  
  }
  return self;
}

- (void)dealloc {
  SUDP_Close();
  [super dealloc];
}

- (unsigned char)charify:(float)toChar{
  int value = (int)toChar;
  if (value > 255) {value = 255;}
  if (value < 0) {value = 0;}
  return value = (unsigned char) value;
}

- (void)sendCommandToLight1:(float)light1 light2:(float)light2 light3:(float)light3 light4:(float)light4 {
  unsigned char message[5];
    
  // DMX protocol starts with 0. I'm not calling this DMX yet, but maybe working towards that
  message[0] = 0;
  message[1] = [self charify:(light1 * 255)];
  message[2] = [self charify:(light2 * 255)];
  message[3] = [self charify:(light3 * 255)];
  message[4] = [self charify:(light4 * 255)];   

  SUDP_SendMsg((char*)message,5);
}

- (void)stop {
  [self sendCommandToLight1:0 light2:0 light3:0 light4:0];
}
  
@end
