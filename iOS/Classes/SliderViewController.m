//
//  SecondViewController.m
//  Dimlet
//
//  Created by John Boiles on 7/23/09.
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

#import "SliderViewController.h"
#import "DimletAppDelegate.h"

@implementation SliderViewController

- (void)viewDidAppear:(BOOL)animated{
  [self readSliders];
}

//! Send a command based on the values of the sliders
- (void)readSliders{
    DimletAppDelegate *appDelegate = (DimletAppDelegate *)[[UIApplication sharedApplication] delegate];    
    [appDelegate.lightControl sendCommandToLight1:_slider1.value
                                           light2:_slider2.value
                                           light3:_slider3.value
                                           light4:_slider4.value];
}

- (IBAction)sliderValueChange: (UISlider *)sender{
  // If the sliders are locked together, update all of them with value from the sender
  if (_lockSwitch.on) {
    if (sender != _slider1) {
      [_slider1 setValue:sender.value animated:false];
    }
    if (sender != _slider2) {
      [_slider2 setValue:sender.value animated:false];
    }
    if (sender != _slider3) {
      [_slider3 setValue:sender.value animated:false];
    }
    if (sender != _slider4) {
      [_slider4 setValue:sender.value animated:false];
    }
  }
  [self readSliders];
}

@end
