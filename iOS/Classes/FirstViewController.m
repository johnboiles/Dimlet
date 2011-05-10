//
//  FirstViewController.m
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

#import "FirstViewController.h"
#import "DimletAppDelegate.h"

// Number of times per second (Hertz) to sample acceleration.
#define kAccelerometerFrequency 40

@implementation FirstViewController

- (void)dealloc {
  [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
  [super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated {
  _on = false;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
  [[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  _on = true;
}

#pragma mark Delegates (UIAccelerometer)

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
  UIAccelerationValue xx = acceleration.x;
  UIAccelerationValue yy = acceleration.y;
  UIAccelerationValue zz = acceleration.z;
  DimletAppDelegate *appDelegate = (DimletAppDelegate *)[[UIApplication sharedApplication] delegate];    

  // TODO(johnboiles): Support swapping X and Y axes
  if (_on) {
    if (_directionBasedSwitch.on) {
      // Business time
      double scaleFactor = _sensitivitySlider.value / 3;
      [appDelegate.lightControl sendCommandToLight1:_baseLevelSlider.value - (zz * scaleFactor)
                                             light2:_baseLevelSlider.value + (xx * scaleFactor)
                                             light3:_baseLevelSlider.value + (zz * scaleFactor)
                                             light4:_baseLevelSlider.value - (xx * scaleFactor)];
    } else {
      double brightness = (_sensitivitySlider.value * (abs(xx) + abs(yy) + abs(zz)) / 6);
      [appDelegate.lightControl sendCommandToLight1:brightness
                                             light2:brightness
                                             light3:brightness
                                             light4:brightness];
    }
  }
}

@end
