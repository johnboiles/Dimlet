//
//  LightControl.h
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

#import "SendUDP.h"

@interface LightControl : NSObject { }

- (void)stop;

- (void)sendCommandToLight1:(float)light1 light2:(float)light2 light3:(float)light3 light4:(float)light4;

@end
