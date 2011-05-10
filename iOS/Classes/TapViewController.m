//
//  TapViewController.m
//  Dimlet
//
//  Created by John Boiles on 7/25/09.
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

#import "TapViewController.h"
#import "DimletAppDelegate.h"

@interface TapViewController ()
- (void)reset;
@end


@implementation TapViewController

LightState SmoothRotate[8] =  
  {{1,.75,.5,.25},
  {.875,.625,.375,.125},
  {.75,.5,.25,1},
  {.625,.375,.125,.875},
  {.5,.25,1,.75},
  {.375,.125,.875,.625},
  {.25,1,.75,.5},
  {.125,.875,.625,.375}};

LightState OldSchool[8] = 
  {{1,0,0,0},
  {1,0,0,0},
  {0,0,0,1},
  {0,0,0,1},
  {0,0,1,0},
  {0,0,1,0},
  {0,1,0,0},
  {0,1,0,0}};

LightState CrazyFlashes[8]=
  {{1,0,0,0},
  {0,0,1,0},
  {0,1,0,0},
  {1,0,0,1},
  {0,0,1,0},
  {0,1,0,0},
  {0,0,0,1},
  {0,1,1,0}};

LightState Twos[8]=
  {{1,0,1,0},
  {1,0,1,0},
  {0,1,0,1},
  {0,1,0,1},
  {1,0,1,0},
  {1,0,1,0},
  {0,1,0,1},
  {0,1,0,1}};

LightState OnOff[8]=
  {{1,1,1,1},
  {0,0,0,0},
  {0,0,0,0},
  {0,0,0,0},
  {1,1,1,1},
  {0,0,0,0},
  {1,0,0,1},
  {0,1,1,0}};

LightState TheFourth[8]=
  {{1,.25,0,.25},
  {0,0,0,0},
  {.25,0,.25,1},
  {0,0,0,0},
  {0,.25,1,.25},
  {0,0,0,0},
  {1,1,1,1},
  {0,0,0,0}};

LightState Down[8] = 
  {{1,1,1,1},
  {.875,.875,.875,.875},
  {.75,.75,.75,.75},
  {.625,.625,.625,.625},
  {.5,.5,.5,.5},
  {.375,.375,.375,.375},
  {.25,.25,.25,.25},
  {0.125,.125,.125,.125}};

- (void)dealloc {
  [_timer invalidate];
  _patternPicker.delegate = nil;
  [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self reset];
}

-(void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [_timer invalidate];
  _stateCounter = 0;
  _tapCount = 0;
}

// Reset all variables
- (void)reset{
  _tapCount = 0;
  _stateCounter = 0;
  [_tapper setTitle:@"Tap Me!" forState:UIControlStateNormal];
}

- (void)changeState{
  LightState *pattern;
  switch([_patternPicker selectedRowInComponent:0]) {
      case 0:
          pattern = SmoothRotate;
          break;
      case 1:
          pattern = CrazyFlashes;
          break;
      case 2:
          pattern = Twos;
          break;
      case 3:
          pattern = OnOff;
          break;
      case 4:
          pattern = TheFourth;
          break;
      case 5:
          pattern = Down;
          break;
      case 6:
          pattern = OldSchool;
          break;
  }

  LightState* currentState = &(pattern[_stateCounter]);
  DimletAppDelegate *appDelegate = (DimletAppDelegate *)[[UIApplication sharedApplication] delegate];    
  [appDelegate.lightControl sendCommandToLight1:currentState->light1
                                         light2:currentState->light2
                                         light3:currentState->light3
                                         light4:currentState->light4];
  if (_stateCounter < 7) {
    _stateCounter++;
  } else {
    _stateCounter = 0;
  }
}

- (IBAction)tapButton{
  CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
  if (_tapCount == 0) {
    [_timer invalidate];
    _stateCounter = 0;
    
    [self changeState];
    //Hack so so i go through two states
    _stateCounter++;
  }
  if (_tapCount < 3) {
    _taps[_tapCount] = now;
    _tapCount++;
    [_tapper setTitle:[NSString stringWithFormat:@"%d", 4 - _tapCount] forState:UIControlStateNormal];
    [self changeState];
    _stateCounter++;
  } else {
    _taps[_tapCount] = now;
    _tapCount = 0;
    // Got 4 taps, average time delta
    // average time differences
    double sum = 0;
    for(NSInteger i = 0; i < 3; i++) {
      sum += _taps[i + 1] - _taps[i];
    }

    // We want to do things every eighth note so we divide /3/2
    double deltaTime = sum / 6;
    _timer = [[NSTimer scheduledTimerWithTimeInterval:deltaTime target:self selector:@selector(timerFired:) userInfo:nil repeats:YES] retain];

    // Calculate BPM
    double bpm = (30 / deltaTime);
    [_bpmLabel setText:[NSString stringWithFormat:@"BPM: %2.1f", bpm]];
    [_tapper setTitle:@"Tap Me!" forState:UIControlStateNormal];
    [self changeState];
    _stateCounter = 7;
  }
}

#pragma mark Timer

- (void)timerFired:(NSTimer *)timer{
  [self changeState];
}

#pragma mark UIPickerViewDataSource

// returns the number of columns to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

// returns the number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return 7;
}

#pragma mark UIPickerViewDelegate

// returns the title of each row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  switch(row) {
    case 0:
      return @"SmoothRotate";
      break;
    case 1:
      return @"CrazyFlashes";
      break;
    case 2:
      return @"Twos";
      break;
    case 3:
      return @"OnOff";
      break;
    case 4:
      return @"TheFourth";
      break;
    case 5:
      return @"Down";
      break;
    case 6:
      return @"OldSchool";
      break;
  }
  return @"BUG!";
}

@end
