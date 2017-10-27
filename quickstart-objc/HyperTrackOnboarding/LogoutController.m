//
//  LogoutController.m
//  HyperTrackOnboarding
//
//  Created by Piyush on 09/05/17.
//  Copyright © 2017 Hypertrack. All rights reserved.
//

#import "LogoutController.h"
@import HyperTrack;

@interface LogoutController ()

@end

@implementation LogoutController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapAcceptOrderButton:(id)sender {
    // Check if the user is already on an order or not
    NSString * actionID = [[NSUserDefaults standardUserDefaults] stringForKey:@"hypertrack_action_id"];
    if (actionID != nil) {
        [self showAlert:@"Error" message:@"Please compelete assigned action before assigning another"];
        return;
    }
    
    // You can specify a lookup_id to Actions which maps to your internal id of the
    // order that is going to be tracked. This will help you search for the order on
    // HyperTrack dashboard, and get custom views for the specific order tracking.
    //
    // @NOTE: A randomly generated UUID is used as the lookup_id here. This will be the actual
    // orderID in your case which will be fetched from either your server or generated locally.
    NSString * orderID = [[NSUUID UUID] UUIDString];
    
    // Accept the order by creating a deliver action for the orderID
    [self acceptOrder:orderID];
}

- (void) acceptOrder: (NSString *) orderID {
    // Construct a place object for Action's expected place.
    // @NOTE: Pass either the address or the location for the expected place.
    // Both have been passed here only to show how it can be done, in case
    // the data is available.
    HyperTrackPlace * expectedPlace = [[HyperTrackPlace alloc] init];
    [expectedPlace setAddress:@"2200 Sand Hill Road, Menlo Park, CA, USA"];
    
    // Create ActionParams object specifying the Delivery Type Action parameters including ExpectedPlace,
    // ExpectedAt time and Lookup_id.
    HyperTrackActionParams * htActionParams = [[HyperTrackActionParams alloc] init];
    [htActionParams setExpectedPlace:expectedPlace];
    [htActionParams setType:@"delivery"];
    [htActionParams setLookupId:orderID];
    
    // Call createAndAssignAction to assign Delivery action to the current
    // user configured in the SDK using the Place object created above.
    [HyperTrack createAndAssignAction:htActionParams :^(HyperTrackAction * _Nullable action,
                                                        HyperTrackError * _Nullable error) {
        if (action) {
            // Handle createAndAssignAction API success here
            [self showAlert:@"Success" message:@"You have created an action. Mark it complete once it is completed!"];
            
            // Save Action id and use this to query the stats of the action later.
            [[NSUserDefaults standardUserDefaults] setValue:[action id] forKey:@"hypertrack_action_id"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        } else {
            // Handle createAndAssignAction API error here
            [self showAlert:@"Error" message:error.debugDescription];
            NSLog(@"Error while acceptOrder: %@", error.debugDescription);
        }
    }];
}

- (IBAction)didTapCompleteOrderButton:(id)sender {
    // Get saved ActionId corresponding to the ongoing order
    NSString * actionID = [[NSUserDefaults standardUserDefaults] stringForKey:@"hypertrack_action_id"];
    
    // Check if the user is already on an order or not
    if (actionID == nil) {
        [self showAlert:@"Error" message:@"Please create an action before trying to completing it."];
        return;
    }
    
    // Complete Action when the order is marked complete using the saved ActionId
    [HyperTrack completeAction:actionID];
    
    // Clear saved ActionId
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hypertrack_action_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showAlert:@"Success" message:@"Action is completed"];
}

- (IBAction)didTapLogoutButton:(id)sender {
    // Check if the user is already on an order or not
    NSString * actionID = [[NSUserDefaults standardUserDefaults] stringForKey:@"hypertrack_action_id"];
    if (actionID != nil) {
        [self showAlert:@"Error" message:@"Please complete ongoing action before logging out."];
        return;
    }
    
    // Stop tracking the user on successful logout. This indicates the user
    // is now offline.
    [HyperTrack stopTracking];
    
    // Stop User Session for a fresh UserLogin by starting ViewController
    LogoutController *lc = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
    [self presentViewController:lc animated:true completion:nil];
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

@end
