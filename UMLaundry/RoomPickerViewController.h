//
//  ViewController.h
//  UMLaundry
//
//  Created by Ayush Mehra on 8/27/14.
//  Copyright (c) 2014 amehra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomPickerViewController : UIViewController
{
    
}

@property (strong, nonatomic) IBOutlet UIPickerView *housePicker;

@property (strong, nonatomic) IBOutlet UIPickerView *roomPicker;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)updateLaundryLocationButtonPressed:(id)sender;

@end
