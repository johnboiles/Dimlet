//
//  SecondViewController.h
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

#import <UIKit/UIKit.h>


@interface SliderViewController : UIViewController {
    IBOutlet UISlider* slider1;
    IBOutlet UISlider* slider2;
    IBOutlet UISlider* slider3;
    IBOutlet UISlider* slider4;
    IBOutlet UISwitch* lockSwitch;
}

@property (nonatomic, retain) UISlider *slider1;
@property (nonatomic, retain) UISlider *slider2;
@property (nonatomic, retain) UISlider *slider3;
@property (nonatomic, retain) UISlider *slider4;
@property (nonatomic, retain) UISwitch *lockSwitch;

- (IBAction)sliderValueChange: (UISlider *)sender;
- (IBAction)lockSwitchChange;
- (void)readSliders;

@end
