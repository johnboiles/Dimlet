//
//  DimletAppDelegate.m
//  Dimlet
//
//  Created by John Boiles on 7/21/09.
//  Copyright John Boiles 2009. All rights reserved.
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

#import "DimletAppDelegate.h"


@implementation DimletAppDelegate

@synthesize window=_window, tabBarController=_tabBarController, lightControl=_lightControl;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
  // Add the tab bar controller's current view as a subview of the window
  [_window addSubview:_tabBarController.view];
  _lightControl = [[LightControl alloc] init];
}

- (void)dealloc {
  [_lightControl release];
  [super dealloc];
}

@end

