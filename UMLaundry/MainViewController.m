//
//  MainViewController.m
//  UMLaundry
//
//  Created by Ayush Mehra on 8/31/14.
//  Copyright (c) 2014 amehra. All rights reserved.
//

#import "MainViewController.h"
#import "Reachability.h"


@interface MainViewController()

@end

@implementation MainViewController

@synthesize machineNumberTextField;
@synthesize laundryLocationLabel;
@synthesize numDryersLabel;
@synthesize numWashersLabel;
@synthesize refreshIcon;
@synthesize machineNumberLabel;
@synthesize launchButton;
@synthesize minuteHandImage;
@synthesize hourHandImage;
@synthesize minutesRemainingLabel;
@synthesize machineTypeDryerImage;
@synthesize machineTypeWasherImage;
@synthesize clockImage;
@synthesize minuteLabel;
@synthesize leftLabel;
@synthesize cancelReminderButton;
@synthesize activityIndicator;
@synthesize waveImage;
@synthesize wave2Image;
@synthesize wave3Image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    clockImage.alpha = 0;
    hourHandImage.alpha = 0;
    minuteHandImage.alpha = 0;
    minutesRemainingLabel.alpha = 0;
    minuteLabel.alpha = 0;
    leftLabel.alpha = 0;
    machineTypeWasherImage.alpha = 0;
    machineTypeDryerImage.alpha = 0;
    cancelReminderButton.alpha = 0;
    refreshIcon.alpha = 0.2;
    [cancelReminderButton setEnabled:NO];
    
    waveImage.alpha = 0.0;
    wave2Image.alpha = 0.0;
    wave3Image.alpha = 0.0;
    
    machineTypeCode = 0;
    animationXValue = -320;
   
   [self returnFromBackgroundRefresh];
    
    NSString *bName = [[NSUserDefaults standardUserDefaults]
                       stringForKey:@"bName"];
    NSString *rName = [[NSUserDefaults standardUserDefaults]
                       stringForKey:@"rName"];
    
    if(![[NSUserDefaults standardUserDefaults]
         stringForKey:@"bCode"] || ![[NSUserDefaults standardUserDefaults]
                                     stringForKey:@"rCode"]) {
        bName = @"";
        rName = @"";
    }
    else {
        
        if([self connected]) {
            [self updateNumMachinesAvailable];
            //[self performSelector:@selector(updateNumMachinesAvailable) withObject:nil afterDelay:5.0];
            if(!updateTimer) {
                updateTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateNumMachinesAvailable) userInfo:nil repeats:YES];
            }
            
        }

    }

    laundryLocationLabel.text = [NSString stringWithFormat:@"%@ - %@",bName,rName];
    
    machineNumberTextField.delegate = self;
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    activityIndicator.hidden = YES;
    [activityIndicator startAnimating];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnFromBackgroundRefresh)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
}
         
 -(void)viewDidAppear:(BOOL)animated {
     if(![[NSUserDefaults standardUserDefaults]
          stringForKey:@"bCode"] || ![[NSUserDefaults standardUserDefaults]
                                      stringForKey:@"rCode"]) {
         if([self connected]) {
             [self performSegueWithIdentifier:@"viewLaundrySelectorPage" sender:self];
         }
      }
 }

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [machineNumberTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (IBAction)viewLaundryButtonPressed:(id)sender {
    
    if([self connected]) {
        
        activityIndicator.hidden = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self performSegueWithIdentifier:@"viewLaundrySelectorPage" sender:sender];
        });
        
    }
    
}


-(void)updateNumMachinesAvailable {
    
    if([self connected]) {
        
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            refreshIcon.alpha = 1;
        } completion:^(BOOL finished) {}];
        
        [UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [refreshIcon setTransform:CGAffineTransformRotate(refreshIcon.transform, M_PI)];
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                refreshIcon.alpha = 0.2;
                [refreshIcon setTransform:CGAffineTransformRotate(refreshIcon.transform, M_PI)];
            } completion:^(BOOL finished) {}];
        }];
        
        
        
        
        NSString *bCode = [[NSUserDefaults standardUserDefaults]
                           stringForKey:@"bCode"];
        NSString *rCode = [[NSUserDefaults standardUserDefaults]
                           stringForKey:@"rCode"];
        
        NSString *urlAsString = [NSString stringWithFormat:@"http://housing.umich.edu/laundry-locator/report/%@/%@/%@/%d",bCode,rCode,@"1",arc4random_uniform(999999)];
        
        
        NSURL *url = [NSURL URLWithString:urlAsString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        
        
        [NSURLConnection
         sendAsynchronousRequest:urlRequest
         queue:[[NSOperationQueue alloc] init]
         completionHandler:^(NSURLResponse *response,
                             NSData *data,
                             NSError *error)
         {
             
             if ([data length] >0 && error == nil)
             {
                 availableData = data;
                 
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^(void){
                     
                     //availableData = [[NSData alloc] initWithContentsOfURL:
                     //   [NSURL URLWithString:url]];
                     
                     availableReport = [[NSString alloc] initWithData:availableData encoding:NSUTF8StringEncoding];
                     
                     
                     // NSUInteger numWashers = [[myString componentsSeparatedByString:@"Washer"] count];
                     
                     //returns number of replacements (num of washers)
                     int numWashers = [[availableReport mutableCopy] replaceOccurrencesOfString:@"Washer"
                                                                                     withString:@"Washer"
                                                                                        options:NSLiteralSearch
                                                                                          range:NSMakeRange(0, [availableReport length])];
                     
                     int numDryers = [[availableReport mutableCopy] replaceOccurrencesOfString:@"Dryer"
                                                                                    withString:@"Dryer"
                                                                                       options:NSLiteralSearch
                                                                                         range:NSMakeRange(0, [availableReport length])];
                     
                     //NSLog(@"Number of washers available: %i",numWashers);
                     
                     numWashersLabel.text = [NSString stringWithFormat:@"%d", numWashers];
                     numDryersLabel.text = [NSString stringWithFormat:@"%d", numDryers];
                     
                     //NSLog(@"reached");

                     
                     
                 });
                
             }
             else if ([data length] == 0 && error == nil)
             {
                 NSLog(@"Nothing was downloaded.");
             }
             else if (error != nil){
                 NSLog(@"Error = %@", error);
             }
             
         }];
       
        
    }
    
}



-(void)checkStatus: (NSString *) machineNumber {
    
    NSString *bCode = [[NSUserDefaults standardUserDefaults]
                       stringForKey:@"bCode"];
    NSString *rCode = [[NSUserDefaults standardUserDefaults]
                       stringForKey:@"rCode"];
    
    NSString *url = [NSString stringWithFormat:@"http://housing.umich.edu/laundry-locator/report/%@/%@/%@/%d",bCode,rCode,@"2",arc4random_uniform(999999)];
    
    
    statusData = [[NSData alloc] initWithContentsOfURL:
                                [NSURL URLWithString:url]];
    
    statusReport = [[NSString alloc] initWithData:statusData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",statusReport);
    
    
    int present = [[statusReport mutableCopy] replaceOccurrencesOfString:[NSString stringWithFormat:@"<td>%@</td>",machineNumber]
                                                           withString:@"mymachine"
                                                              options:NSLiteralSearch
                                                                range:NSMakeRange(0, [statusReport length])];
    
    if(present<1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hmmm" message:[NSString stringWithFormat:@"Machine %@ is not in use at this location.",machineNumber] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];

    }
    else {
        //NSLog(@"reached");
        NSRange machineRange = [statusReport rangeOfString:[NSString stringWithFormat:@"<td>%@</td>", machineNumber]];
        statusReport = [statusReport substringFromIndex:machineRange.location];
        
        NSLog(@"%@",statusReport);
        
        NSRange numRange = [statusReport rangeOfString:@"m</td>"];
        
        NSString *machineTypeRemainingString = [statusReport substringToIndex:numRange.location];
        
        NSString *machineType = @"";
        
        if([[machineTypeRemainingString mutableCopy] replaceOccurrencesOfString:@"Washer"
                                                                  withString:@"Washer"
                                                                     options:NSLiteralSearch
                                                                          range:NSMakeRange(0, [machineTypeRemainingString length])]<1) {
            machineType = @"Dryer";
            machineTypeCode = 1;
        }
        else {
            machineType = @"Washer";
            machineTypeCode = 0;
        }
        
        
        
        //NSLog(@"%@",machineTypeRemainingString);
        
        NSString *minRemainingString = [statusReport substringFromIndex:numRange.location-2];
        
        
        minRemainingString = [minRemainingString substringToIndex:2];
        
        
        if([[minRemainingString substringToIndex:1] isEqualToString: @">"]) {
            minRemainingString = [minRemainingString substringFromIndex:1];
        }
        
        
        if([minRemainingString intValue] < 1){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hmmm" message:[NSString stringWithFormat:@"%@ cycle at machine %@ is complete.",machineType, machineNumber] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        else {
            
            //hide input controls and show time remaining
            
            [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
               
               [self updateItemsToDisplay:YES];
                
                if(machineTypeCode<1) {
                    machineTypeWasherImage.alpha = 1;
                }
                else {
                    machineTypeDryerImage.alpha = 1;
                }
                
                
            } completion:^(BOOL finished) {}];
            
            [self initTimeDisplay:minRemainingString machineType: machineType];
            [self startNotificationTimer:minRemainingString machineType: machineType];
            [self startAnimatingWaves: machineType];
            
        }
        
        
        
        
    }
    
    
    
    
    
}


-(void)initTimeDisplay:(NSString *)time machineType:(NSString *)machineType {
    
    
    minutesRemainingLabel.text = time;
    
    int timeRemaining = [time intValue];
    if(timeRemaining==60) {
        timeRemaining = 59; //so that wedge is drawn
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    
    int minute = [components minute];
    int hour = [components hour];
    
    
    int endMinute = (minute+timeRemaining)%60;
    
    if(hour>12) {
        hour-=12;
    }
    
    NSLog(@"minute: %i", minute);
    NSLog(@"hour: %i", hour);

    
    //float startAngle = 0; //(M_PI/2)+(((60-minute)/60.0)*2*M_PI);
    float startAngle = (2*M_PI*(minute/60.0))-(M_PI/2);
    
    NSLog(@"start angle: %f", startAngle);
    //float endAngle = (M_PI/6); //startAngle-((timeRemaining/60.0)*2*M_PI);
    float endAngle = (2*M_PI*(endMinute/60.0))-(M_PI/2);
    
    
    slice = [CAShapeLayer layer];
    slice.fillColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    slice.strokeColor = [UIColor whiteColor].CGColor;
    slice.lineWidth = 0;
    
    CGFloat angle = startAngle;
    CGFloat end= endAngle;
    CGPoint center = CGPointMake(51, 200);
    CGFloat radius = 43.0;
    
    UIBezierPath *piePath = [UIBezierPath bezierPath];
    [piePath moveToPoint:center];
    
    [piePath addLineToPoint:CGPointMake(center.x + radius * cosf(angle), center.y + radius * sinf(angle))];
    
    [piePath addArcWithCenter:center radius:radius startAngle:angle endAngle:end clockwise:YES];
    
    //   [piePath addLineToPoint:center];
    [piePath closePath]; // this will automatically add a straight line to the center
    slice.path = piePath.CGPath;
    
    [self.view.layer insertSublayer:slice atIndex:0];

    
    minuteHandImage.transform = CGAffineTransformMakeRotation(startAngle+(M_PI/2));
    
    float hourHandAngle = ((hour/12.0)*2*M_PI)+((2*M_PI)/12)*(minute/60.0);
    
    hourHandImage.transform = CGAffineTransformMakeRotation(hourHandAngle);
    
    if([machineType isEqualToString:@"Washer"]) {
        //machineTypeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"water_icon.png"]];
        machineTypeDryerImage.alpha = 0;
        machineTypeWasherImage.alpha = 1;
    }
    else {
        //machineTypeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heat_icon.png"]];
        machineTypeDryerImage.alpha = 1;
        machineTypeWasherImage.alpha = 0;
    }
    
    
}



//limit textfield to two characters
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range     replacementString:(NSString *)string
{
    if (textField.text.length >= 2 && range.length == 0)
        return NO;
    return YES;
}


- (IBAction)reminderButtonPressed:(id)sender {
    [machineNumberTextField resignFirstResponder];
    NSLog(@"%@",machineNumberTextField.text);
    
    NSString *machineNumber = machineNumberTextField.text;
    if([machineNumber hasPrefix:@"0"]) {
        machineNumber = [machineNumber substringFromIndex:1];
    }
    
    machineNumberTextField.text = machineNumber;
    
    if([self connected]) {
        if(![machineNumber isEqualToString:@""]) {
            [self checkStatus:machineNumber];
        }
    }
    
}


- (IBAction)cancelReminderButtonPressed:(id)sender {
    
    UIAlertView *confirmCancelAlertView = [[UIAlertView alloc]
                              initWithTitle:@"Cancel Reminder"
                              message:@"Are you sure you want to cancel your reminder?"
                              delegate:self
                              cancelButtonTitle:@"Yes"
                              otherButtonTitles:nil];
    
    [confirmCancelAlertView addButtonWithTitle:@"No, don't cancel"];
    [confirmCancelAlertView show];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) { //cancel reminder
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
           
           [self updateItemsToDisplay:NO];
            
        } completion:^(BOOL finished) {}];
        
        [machineNumberTextField setText:@""];
        [self stopAnimatingWaves];
        
        
    }
}


-(void)startNotificationTimer:(NSString *)timeRemaining machineType:(NSString *)machineTypeString {
    
    int minRemaining = [timeRemaining intValue];
    
    UILocalNotification* notif = [[UILocalNotification alloc] init];
    
    notif.fireDate = [NSDate dateWithTimeIntervalSinceNow: 60*minRemaining];
    
    notif.soundName = @"chime.wav";
    
    notif.applicationIconBadgeNumber = 1;
    
    notif.alertBody = [NSString stringWithFormat:@"%@ cycle is complete",machineTypeString];
    
    [[UIApplication sharedApplication] scheduleLocalNotification: notif];
    
    [NSTimer scheduledTimerWithTimeInterval:60
                                     target:self
                                   selector:@selector(updateTimeDisplay)
                                   userInfo:nil
                                    repeats:YES];
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   [defaults setObject:machineTypeString forKey:@"machineType"];
   [defaults synchronize];
   
    
}


-(void)updateTimeDisplay {
    
    int minRemaining = [minutesRemainingLabel.text intValue];
    
    minRemaining--;
    
    if(minRemaining>0) {
        [minutesRemainingLabel setText:[NSString stringWithFormat:@"%d",minRemaining]];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
        
        int minute = [components minute];
        int hour = [components hour];
        
        if(hour>12) {
            hour-=12;
        }
        
        float startAngle = (2*M_PI*(minute/60.0))-(M_PI/2);
        
        minuteHandImage.transform = CGAffineTransformMakeRotation(startAngle+(M_PI/2));
        
        float hourHandAngle = ((hour/12.0)*2*M_PI)+((2*M_PI)/12)*(minute/60.0);
        
        hourHandImage.transform = CGAffineTransformMakeRotation(hourHandAngle);
        
        if(minRemaining<2) {
            [minuteLabel setText:@"minute"];
        }
        
    }
    else {
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            machineNumberLabel.alpha = 1;
            machineNumberTextField.alpha = 1;
            launchButton.alpha = 1;
            [launchButton setEnabled:YES];
            [machineNumberTextField setEnabled:YES];
            
            clockImage.alpha = 0;
            hourHandImage.alpha = 0;
            minuteHandImage.alpha = 0;
            minutesRemainingLabel.alpha = 0;
            minuteLabel.alpha = 0;
            leftLabel.alpha = 0;
            machineTypeDryerImage.alpha = 0;
            machineTypeWasherImage.alpha = 0;
            cancelReminderButton.alpha = 0;
            [cancelReminderButton setEnabled:NO];
            slice.hidden = YES;
            
        } completion:^(BOOL finished) {}];
        
        [machineNumberTextField setText:@""];
        [minuteLabel setText:@"minutes"];
        [self stopAnimatingWaves];
    }
    
}


-(void)returnFromBackgroundRefresh {
    
    NSArray *eventArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSLog(@"1");
    int numNotifications = [eventArray count];
    NSLog(@"2");
    NSLog(@"count: %lu",(unsigned long)[eventArray count]);
    NSLog(@"numNotifications: %d",numNotifications);
    
    
                            
    if(numNotifications<1 && clockImage.alpha>0) {
        NSLog(@"3");
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
           
           [self updateItemsToDisplay:NO];
            
        } completion:^(BOOL finished) {}];
        [self stopAnimatingWaves];
    }
    else if(numNotifications>0) {
        NSLog(@"4");
        UILocalNotification *notification = [eventArray objectAtIndex:0];
        NSLog(@"reached");
        NSDate *notifDate = notification.fireDate;
        NSCalendar *c = [NSCalendar currentCalendar];
        NSDate *d1 = [NSDate date];
        NSDateComponents *components = [c components:NSSecondCalendarUnit fromDate:d1 toDate:notifDate options:0];
        int diff = ((components.second)/60)+1;
       
       if(clockImage.alpha<1) {
          NSLog(@"adsfasdf");
          
          NSString *machineType = [[NSUserDefaults standardUserDefaults] objectForKey:@"machineType"];
          
          [self initTimeDisplay:[NSString stringWithFormat:@"%d",diff] machineType:machineType];
          [self updateItemsToDisplay:YES];
          
          [self startAnimatingWaves:machineType];

       } else {
          [minutesRemainingLabel setText:[NSString stringWithFormat:@"%d",diff]];
          [self updateTimeDisplay];
       }
        
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    
}

-(void)updateItemsToDisplay:(BOOL)timerOn {
   if(timerOn) {
      machineNumberLabel.alpha = 0;
      machineNumberTextField.alpha = 0;
      launchButton.alpha = 0;
      [launchButton setEnabled:NO];
      [machineNumberTextField setEnabled:NO];
      
      clockImage.alpha = 1;
      hourHandImage.alpha = 1;
      minuteHandImage.alpha = 1;
      minutesRemainingLabel.alpha = 1;
      minuteLabel.alpha = 1;
      leftLabel.alpha = 1;
      cancelReminderButton.alpha = 1;
      [cancelReminderButton setEnabled:YES];
   } else {
      machineNumberLabel.alpha = 1;
      machineNumberTextField.alpha = 1;
      launchButton.alpha = 1;
      [launchButton setEnabled:YES];
      [machineNumberTextField setEnabled:YES];
      
      clockImage.alpha = 0;
      hourHandImage.alpha = 0;
      minuteHandImage.alpha = 0;
      minutesRemainingLabel.alpha = 0;
      minuteLabel.alpha = 0;
      leftLabel.alpha = 0;
      machineTypeDryerImage.alpha = 0;
      machineTypeWasherImage.alpha = 0;
      cancelReminderButton.alpha = 0;
      [cancelReminderButton setEnabled:NO];
      slice.hidden = YES;
   }
}


-(void)startAnimatingWaves:(NSString *) machineType {
   
   if([machineType isEqualToString:@"Washer"]) {
      [waveImage setImage:[UIImage imageNamed:@"wave1.png"]];
      [wave2Image setImage:[UIImage imageNamed:@"wave2.png"]];
      [wave3Image setImage:[UIImage imageNamed:@"wave3.png"]];
   } else {
      [waveImage setImage:[UIImage imageNamed:@"heat1.png"]];
      [wave2Image setImage:[UIImage imageNamed:@"heat3.png"]];
      [wave3Image setImage:[UIImage imageNamed:@"heat2.png"]];
   }
   
   [UIView animateWithDuration:2.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
      waveImage.alpha = 1.0;
      wave2Image.alpha = 1.0;
      wave3Image.alpha = 1.0;
   } completion:^(BOOL finished) {}];
   
   animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.025
                                                     target:self
                                                   selector:@selector(animateWaves)
                                                   userInfo:nil
                                                    repeats:YES];
}


-(void)animateWaves {
   if(animationXValue<0) {
      animationXValue+=1;
   }
   else {
      animationXValue = -320;
   }
   waveImage.frame = CGRectMake(animationXValue, 485, 640, 90);
   wave2Image.frame = CGRectMake(-320-animationXValue, 500, 640, 90);
   wave3Image.frame = CGRectMake(animationXValue, 515, 640, 90);
}

-(void)stopAnimatingWaves {
   
   [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
      waveImage.alpha = 0.0;
      wave2Image.alpha = 0.0;
      wave3Image.alpha = 0.0;
   } completion:^(BOOL finished) {
      [animationTimer invalidate];
      animationTimer = nil;
   }];
   
   
   
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hmmm" message:@"This app requires an internet connection. Please connect and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    return networkStatus != NotReachable;
    
}






@end
