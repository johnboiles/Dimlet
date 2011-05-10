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

@implementation TapViewController

@synthesize tapper;
@synthesize bpmLabel;
@synthesize patternPicker;
volatile int StateCounter = 0; 
CFAbsoluteTime taps[4];
int tapCount;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Reset all variables
- (void)reset{
    tapCount=0;
    StateCounter=0;
    [tapper setTitle:@"Tap Me!" forState:UIControlStateNormal];
    
}

//- (void)viewDidLoad{

    
//}


- (void)viewDidAppear:(BOOL)animated{
    [self reset];
}

//Picker code
// returns the number of columns to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

// returns the number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 7;
}
#pragma mark ---- UIPickerViewDelegate delegate methods ----

// returns the title of each row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	switch(row){
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
    return @"crack";
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/



struct stateStruct {
    float light1;
    float light2;
    float light3;
    float light4;
};
typedef struct stateStruct state;
state SmoothRotate[8] =  
   {{1,.75,.5,.25},
    {.875,.625,.375,.125},
    {.75,.5,.25,1},
    {.625,.375,.125,.875},
    {.5,.25,1,.75},
    {.375,.125,.875,.625},
    {.25,1,.75,.5},
    {.125,.875,.625,.375}};

state OldSchool[8] = 
{{1,0,0,0},
{1,0,0,0},
{0,0,0,1},
{0,0,0,1},
{0,0,1,0},
{0,0,1,0},
{0,1,0,0},
{0,1,0,0}};

state CrazyFlashes[8]=
{{1,0,0,0},
{0,0,1,0},
{0,1,0,0},
{1,0,0,1},
{0,0,1,0},
{0,1,0,0},
{0,0,0,1},
{0,1,1,0}};

state Twos[8]=
{{1,0,1,0},
{1,0,1,0},
{0,1,0,1},
{0,1,0,1},
{1,0,1,0},
{1,0,1,0},
{0,1,0,1},
{0,1,0,1}};

state OnOff[8]=
{{1,1,1,1},
{0,0,0,0},
{0,0,0,0},
{0,0,0,0},
{1,1,1,1},
{0,0,0,0},
{1,0,0,1},
{0,1,1,0}};

state TheFourth[8]=
{{1,.25,0,.25},
{0,0,0,0},
{.25,0,.25,1},
{0,0,0,0},
{0,.25,1,.25},
{0,0,0,0},
{1,1,1,1},
{0,0,0,0}};

state Down[8] = 
{{1,1,1,1},
{.875,.875,.875,.875},
{.75,.75,.75,.75},
{.625,.625,.625,.625},
{.5,.5,.5,.5},
{.375,.375,.375,.375},
{.25,.25,.25,.25},
{0.125,.125,.125,.125}};

- (void)changeState{
    state* pattern;
    switch([patternPicker selectedRowInComponent:0]){
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
    //pattern = SmoothRotate;
    state* curState = &(pattern[StateCounter]);
    DimletAppDelegate *appDelegate = (DimletAppDelegate *)[[UIApplication sharedApplication] delegate];    
    [appDelegate.lightControl sendCommandToLights:curState->light1:curState->light2:curState->light3:curState->light4];
    if(StateCounter < 7){
        StateCounter++;
    } else {
        StateCounter = 0;
    }
    
}

#pragma mark Timer
- (void)timerFired:(NSTimer *)timer{
    [self changeState];
}

- (IBAction)tapButton{
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    if(tapCount == 0){
        [timer invalidate];
        StateCounter = 0;
        
        [self changeState];
        //Hack so so i go through two states
        StateCounter++;
    }
    if(tapCount < 3){
        taps[tapCount] = now;
        tapCount++;
        [tapper setTitle:[NSString stringWithFormat:@"%d",4-tapCount] forState:UIControlStateNormal];
        
        [self changeState];
        StateCounter++;
    } else {
        taps[tapCount] = now;
        tapCount = 0;
        //Got 4 taps, average time delta
        //average time differences
        double sum = 0;
        for(int i=0; i<3; i++){
            sum += taps[i+1] - taps[i];
        }
        //We want to do things every eighth note so we divide /3/2
        double deltaTime = sum / 6;
        timer = [[NSTimer timerWithTimeInterval:deltaTime target:self selector:@selector(timerFired:) userInfo:nil repeats:YES] retain];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        //set the pattern in motion
        //[self restartPatternWithTime: now andInterval: deltaTime];
        //Calculate BPM
        double bpm = (30 / deltaTime);
        [bpmLabel setText:[NSString stringWithFormat:@"BPM: %2.1f",bpm]];
        [tapper setTitle:@"Tap Me!" forState:UIControlStateNormal];
        [self changeState];
        StateCounter = 7;
    }
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

-(void)viewDidDisappear:(BOOL)animated {
    //if(timer != nil){
    [timer invalidate];

    
    StateCounter = 0;
    tapCount = 0;
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
