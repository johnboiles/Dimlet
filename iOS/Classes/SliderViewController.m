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

@synthesize slider1;
@synthesize slider2;
@synthesize slider3;
@synthesize slider4;
@synthesize lockSwitch;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/*
- (void)viewDidLoad {
    [super viewDidLoad];

}
*/

- (void)viewDidAppear:(BOOL)animated{
    [self readSliders];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction)lockSwitchChange{
    
}

//Send a command based on the values of the sliders
- (void)readSliders{
    DimletAppDelegate *appDelegate = (DimletAppDelegate *)[[UIApplication sharedApplication] delegate];    
    [appDelegate.lightControl sendCommandToLights:slider1.value:slider2.value:slider3.value:slider4.value];
}

- (IBAction)sliderValueChange: (UISlider *)sender{
    //If the sliders are locked together, update all of them with value from the sender
    if(lockSwitch.on){
        if(sender != slider1){
            [slider1 setValue:sender.value animated:false];
        }
        if(sender != slider2){
            [slider2 setValue:sender.value animated:false];
        }
        if(sender != slider3){
            [slider3 setValue:sender.value animated:false];
        }
        if(sender != slider4){
            [slider4 setValue:sender.value animated:false];
        }
    }
    
    [self readSliders];
}

- (void)dealloc {
    [super dealloc];
}


@end
