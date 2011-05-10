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

@implementation FirstViewController

@synthesize sensitivity;
@synthesize baseLevel;
@synthesize directionBased;
@synthesize on;
//save these so we can calibrate when the app first starts
float calibx;
float caliby;

// Constant for the number of times per second (Hertz) to sample acceleration.
#define kAccelerometerFrequency     40

// The designated initializer. Override to perform setup that is required before the view is loaded.
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
- (void)viewDidLoad {
    //if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Configure and start the accelerometer
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
   // }
   // return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewDidAppear:(BOOL)animated{
    self.on = true;
    
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

//filter variables
float oldx[4];
float oldy[4];
float FilterWeight = .5;

// UIAccelerometerDelegate method, called when the device accelerates.
// I believe this should go with the view controller that uses it
// QUESTION: does this still run when we switch views?
// ANSWER: yes it will, it doesn't stop running
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
	float xx = (float) acceleration.x;
	float yy = (float) acceleration.y;
	float zz = (float) acceleration.z;
    DimletAppDelegate *appDelegate = (DimletAppDelegate *)[[UIApplication sharedApplication] delegate];    
    
    //TODO: set up some sensitivity control
    //TODO: be able to swap X and Y axes

    if(self.on){
        if(directionBased.on){
            //Business time
            double scaleFactor = sensitivity.value / 3;
            [appDelegate.lightControl sendCommandToLights: baseLevel.value - (zz * scaleFactor): baseLevel.value+(xx * scaleFactor) : baseLevel.value + (zz * scaleFactor):baseLevel.value-(xx * scaleFactor)];
        } else {
            double brightness = (sensitivity.value * (abs(xx)+abs(yy)+abs(zz)) / 6);
            [appDelegate.lightControl sendCommandToLights: brightness:brightness:brightness:brightness];
        }
    }
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

-(void)viewDidDisappear:(BOOL)animated {

    self.on=false;
}


- (void)dealloc {
    DimletAppDelegate *appDelegate = (DimletAppDelegate *)[[UIApplication sharedApplication] delegate];    

    [appDelegate.lightControl stop];
    //I think this should happen automatically?
    [appDelegate.lightControl dealloc];
    [super dealloc];
}

@end
