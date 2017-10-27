//
//  ViewController.m
//  HyperTrackOnboarding
//
//  Created by Piyush on 09/05/17.
//  Copyright © 2017 Hypertrack. All rights reserved.
//

#import "ViewController.h"
@import HyperTrack;
@import UIKit;
@import CoreLocation;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;

@end

@implementation ViewController

- (void) viewDidAppear:(BOOL)animated {
    // Check if user is logged in already
    if ([HyperTrack isTracking]) {
//         Start User Session by starting LogoutViewController
        ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"logout"];
        [self presentViewController:vc animated:true completion:nil];    
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Call this method to attempt user login. This method will create a User on HyperTrack Server
// and configure the SDK using this generated UserId.
- (IBAction)onLoginClick:(id)sender {
    
    // Get User details, if specified
    NSString *userName = _userNameField.text;
    NSString *phoneNumber = _phoneNumberField.text;
    NSString *lookupId = _phoneNumberField.text;
    HTMockLocationParams * locationParams = [[HTMockLocationParams alloc]initWithDestination:CLLocationCoordinate2DMake(0.0, 0.0)];
    [HyperTrack startMockTrackingWithParams:locationParams];
    // Get or Create a User for given lookupId on HyperTrack Server here to login
    // your user & configure HyperTrack SDK with this generated HyperTrack UserId.
    // OR
    // Implement your API call for User Login and get back a HyperTrack UserId
    // from your API Server to be configured in the HyperTrack SDK.
    [HyperTrack getOrCreateUser:userName _phone:phoneNumber :lookupId
              completionHandler:^(HyperTrackUser * _Nullable user,
                                  HyperTrackError * _Nullable error) {
                  if (user) {
                      // Handle createUser success here, if required
                      // HyperTrack SDK auto-configures UserId on createUser API call,
                      // so no need to call [HyperTrack setUserId:@"USER_ID"] API
                      
                      // Handle createUser API success here
                      [self onUserLoginSuccess];
                      
                  } else {
                      // Handle createUser error here, if required
                      [self showAlert:@"Error while creating user" message:error.debugDescription];
                      NSLog(@"%@", error.debugDescription);
                  }
              }];
}

// Call this method when user has successfully logged in
- (void) onUserLoginSuccess {
    
    // Start tracking the user on successful login. This indicates the user
    // is online.
    [HyperTrack startTracking];
    
    // Start User Session by starting LogoutViewController
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"logout"];
    [self presentViewController:vc animated:true completion:nil];
}

- (void) showAlert: (NSString *)title
           message: (nullable NSString *)message {
    
    // create the alert
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:message
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    // create the alert
    [alertView show];
}

- (void)didSelectPlaceWithPlace:(HyperTrackPlace *)place pickerView:(HTPlacePickerView *)pickerView{
    
}
-(void )didCancelPlaceSelectionWithPickerView:(HTPlacePickerView *)pickerView{
    
}

@end
