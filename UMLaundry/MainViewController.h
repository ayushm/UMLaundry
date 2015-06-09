//
//  MainViewController.h
//  UMLaundry
//
//  Created by Ayush Mehra on 8/31/14.
//  Copyright (c) 2014 amehra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<UITextFieldDelegate> {
    NSData *availableData;
    NSString *availableReport;
    
    NSData *statusData;
    NSString *statusReport;
    CAShapeLayer *slice;
    int machineTypeCode;
    NSTimer *updateTimer;
    
    NSTimer *animationTimer;
    int animationXValue;
}
- (IBAction)viewLaundryButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *machineNumberTextField;
@property (strong, nonatomic) IBOutlet UILabel *laundryLocationLabel;
@property (strong, nonatomic) IBOutlet UILabel *numWashersLabel;
@property (strong, nonatomic) IBOutlet UILabel *numDryersLabel;
@property (strong, nonatomic) IBOutlet UIImageView *refreshIcon;
- (IBAction)reminderButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *minutesRemainingLabel;
@property (strong, nonatomic) IBOutlet UILabel *machineNumberLabel;
@property (strong, nonatomic) IBOutlet UIButton *launchButton;
@property (strong, nonatomic) IBOutlet UIImageView *minuteHandImage;
@property (strong, nonatomic) IBOutlet UIImageView *hourHandImage;
@property (strong, nonatomic) IBOutlet UIImageView *clockImage;
@property (strong, nonatomic) IBOutlet UILabel *minuteLabel;
@property (strong, nonatomic) IBOutlet UILabel *leftLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelReminderButton;
- (IBAction)cancelReminderButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *machineTypeWasherImage;
@property (strong, nonatomic) IBOutlet UIImageView *machineTypeDryerImage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *waveImage;
@property (strong, nonatomic) IBOutlet UIImageView *wave2Image;
@property (strong, nonatomic) IBOutlet UIImageView *wave3Image;

@end
