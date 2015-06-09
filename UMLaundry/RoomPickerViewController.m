//
//  ViewController.m
//  UMLaundry
//
//  Created by Ayush Mehra on 8/27/14.
//  Copyright (c) 2014 amehra. All rights reserved.
//

#import "RoomPickerViewController.h"
#import "Reachability.h"

@interface RoomPickerViewController ()

@end

@implementation RoomPickerViewController
{
    NSArray *buildingNamesArray;
    NSArray *buildingCodesArray;
    NSMutableArray *roomNamesArray;
    NSMutableArray *roomCodesArray;
}

@synthesize housePicker;
@synthesize roomPicker;
@synthesize activityIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    buildingNamesArray = [[NSMutableArray alloc] init];
    buildingCodesArray = [[NSMutableArray alloc] init];
    roomNamesArray = [[NSMutableArray alloc] init];
    roomCodesArray = [[NSMutableArray alloc] init];
    
    [activityIndicator startAnimating];
    activityIndicator.hidden = YES;
    
    housePicker.tag = 1;
    roomPicker.tag = 2;
    
    roomPicker.alpha = 1.0;
    housePicker.alpha = 1.0;
    
    [housePicker setDataSource:self];
    [housePicker setDelegate:self];
    [roomPicker setDataSource:self];
    [roomPicker setDelegate:self];
    
    NSData *allBuildingsData = [[NSData alloc] initWithContentsOfURL:
                              [NSURL URLWithString:@"http://housing.umich.edu/laundry-locator/locations/1234567"]];
    
    //NSString *myString = [[NSString alloc] initWithData:allBuildingsData encoding:NSUTF8StringEncoding];

   
    NSError *error;
    NSMutableDictionary *allBuildings = [NSJSONSerialization
                                       JSONObjectWithData:allBuildingsData
                                       options:NSJSONReadingMutableContainers
                                       error:&error];
    
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        NSArray *buildings = allBuildings[@"locations"];
        for ( NSDictionary *building in buildings )
        {
            
            NSDictionary *loc = building[@"loc"];
            //NSLog(@"Title: %@", loc[@"building"] );
            
            buildingNamesArray = [buildingNamesArray arrayByAddingObject:loc[@"building"]];
            buildingCodesArray = [buildingCodesArray arrayByAddingObject:loc[@"code"]];
            
            
        }
    }
    
    [self updateRoomsPicker:[buildingCodesArray objectAtIndex:0]];
    
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag==1) {
        return buildingNamesArray.count;
    }
    else {
        return roomNamesArray.count;
    }
    
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag==1){
        NSString *buildingName = buildingNamesArray[row];
        NSAttributedString *attributedBuildingName = [[NSAttributedString alloc] initWithString:buildingName attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        return attributedBuildingName;
    }
    else {
        NSString *roomName = roomNamesArray[row];
        NSAttributedString *attributedRoomName = [[NSAttributedString alloc] initWithString:roomName attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        return attributedRoomName;
    }
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if([self connected]) {
    //NSLog(@"%d", row);
        if(pickerView.tag==1) {
            //NSLog(@"Name: %@", [buildingNamesArray objectAtIndex:row]);
            
            roomPicker.alpha = 0.5;
            activityIndicator.hidden = NO;
            
            [self updateRoomsPicker:[buildingCodesArray objectAtIndex:row]];
        }
        
    }
    
}



- (void)updateRoomsPicker: (id)bCode {
    
    NSString *roomsUrl = [NSString stringWithFormat:@"http://housing.umich.edu/laundry-locator/rooms/%@/1234567",bCode];
    
    NSLog(@"%@", roomsUrl);
    
    NSData *allRoomsData = [[NSData alloc] initWithContentsOfURL:
                                [NSURL URLWithString:roomsUrl]];
    
    NSError *error;
    NSMutableDictionary *allRooms = [NSJSONSerialization
                                         JSONObjectWithData:allRoomsData
                                         options:NSJSONReadingMutableContainers
                                         error:&error];
    
    NSLog(@"Rooms in %@", [buildingNamesArray objectAtIndex:[housePicker selectedRowInComponent:0]]);
    
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        
        [roomNamesArray removeAllObjects];
        [roomCodesArray removeAllObjects];
        
        NSArray *rooms = allRooms[@"rooms"];
        for ( NSDictionary *room in rooms )
        {
            
            NSDictionary *roomName = room[@"room"];
            
            [roomNamesArray addObject:roomName[@"name"]];
            [roomCodesArray addObject:roomName[@"code"]];
            
            //NSLog(@"Name: %@", roomName[@"name"]);
            [roomPicker reloadAllComponents];
            activityIndicator.hidden = YES;
            roomPicker.alpha = 1.0;
            
        }
    }

}



















- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateLaundryLocationButtonPressed:(id)sender {
    
    activityIndicator.hidden = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        roomPicker.alpha = 0.3;
        housePicker.alpha = 0.3;
        
    } completion:^(BOOL finished) {}];
    
    [[NSUserDefaults standardUserDefaults] setObject:[buildingCodesArray objectAtIndex:[housePicker selectedRowInComponent:0]] forKey:@"bCode"];
    [[NSUserDefaults standardUserDefaults] setObject:[roomCodesArray objectAtIndex:[roomPicker selectedRowInComponent:0]] forKey:@"rCode"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[buildingNamesArray objectAtIndex:[housePicker selectedRowInComponent:0]] forKey:@"bName"];
    [[NSUserDefaults standardUserDefaults] setObject:[roomNamesArray objectAtIndex:[roomPicker selectedRowInComponent:0]] forKey:@"rName"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self performSegueWithIdentifier:@"viewMainPage" sender:sender];
    });
        
    //[self performSegueWithIdentifier:@"viewMainPage" sender:sender];
}


- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hmmm" message:@"This app requires an internet connection. Please close the app, connect, and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    return networkStatus != NotReachable;
    
}


@end
