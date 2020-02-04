# HyperTrack Quickstart for iOS SDK

![GitHub](https://img.shields.io/github/license/hypertrack/quickstart-ios.svg)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/HyperTrack.svg)
[![iOS SDK](https://img.shields.io/badge/iOS%20SDK-4.0.1-brightgreen.svg)](https://cocoapods.org/pods/HyperTrack)

[HyperTrack](https://www.hypertrack.com) lets you add live location tracking to your mobile app. Live location is made available along with ongoing activity, tracking controls and tracking outage with reasons. This repo contains an example iOS app that has everything you need to get started in minutes.

* [Publishable Key](#publishable-key)–Sign up and get your keys
* [Quickstart](#quickstart-app)–Start with a ready-to-go app with reliable background service
* [Integrate the SDK](#integrate-the-sdk)–Integrate the SDK into your app
* [Dashboard](#dashboard)–See live location of all your devices on your HyperTrack dashboard
* [FAQs](#frequently-asked-questions)–Frequently asked questions
* [Support](#support)–Support

## Publishable Key

We use Publishable Key to identify your devices. To get one:
1. Go to the [Signup page](https://dashboard.hypertrack.com/signup). Enter your email address and password.
2. Open the verification link sent to your email.
3. Open the [Setup page](https://dashboard.hypertrack.com/setup), where you can copy your Publishable Key.

![Signup flow](Images/Signup_flow.png)

Next, you can [start with the Quickstart app](#quickstart-app), or can [integrate the SDK](#integrate-the-sdk) in your app.

## Quickstart app

1. [Clone this repo](#step-1-clone-this-repo)
2. [Install the SDK dependency](#step-2-install-the-sdk-dependency)
3. [Set your Publishable Key](#step-3-set-your-publishable-key)
4. [Setup silent push notifications](#step-4-setup-silent-push-notifications)
5. [Run the Quickstart app](#step-5-run-the-quickstart-app)

### Step 1: Clone this repo
```bash
git clone https://github.com/hypertrack/quickstart-ios.git
cd quickstart-ios
```
### Step 2: Install the SDK dependency

Quickstart app uses [CocoaPods](https://cocoapods.org) dependency manager to install the latest version of the SDK. Using the latest version of CocoaPods is advised.

If you don't have CocoaPods, [install it first](https://guides.cocoapods.org/using/getting-started.html#installation).

Run `pod install` inside the cloned directory. After CocoaPods creates the `Quickstart.xcworkspace` workspace file, open it with Xcode.

### Step 3: Set your Publishable Key

Open the Quickstart project inside the workspace and set your [Publishable Key](#publishable-key) inside the placeholder in the `AppDelegate.swift` file.

### Step 4: Setup silent push notifications

Log into the HyperTrack dashboard, and open the [setup page](https://dashboard.hypertrack.com/setup). Upload your Auth Key (file in the format `AuthKey_KEYID.p8` obtained/created from Apple Developer console > Certificates, Identifiers & Profiles > Keys) and fill in your Team ID (Can be seen in Account > Membership).

### Step 5: Run the Quickstart app

Run the app on your phone and you should see the following control interface:

![Quickstart app](Images/On_Device.png)

After enabling location and activity permissions (choose "Always Allow" if you want the app to collect location data in the background), you can start or stop tracking using the [REST API](https://docs.hypertrack.com/#references-apis).

Check out the [dashboard](#dashboard) to see the live location of your devices on the map.

## Integrate the SDK

### Requirements

HyperTrack SDK supports iOS 9 and above, using Swift or Objective-C.

### Step by step instructions

1. [Add HyperTrack SDK to your Podfile](#step-1-add-hypertrack-sdk-to-your-podfile)
2. [Enable background location updates](#step-2-enable-background-location-updates)
3. [Handle location and motion permissions](#step-3-handle-location-and-motion-permissions)
4. [Initialize the SDK](#step-4-initialize-the-sdk)
5. [Enable remote notifications](#step-5-enable-remote-notifications)
6. [(optional) Identify devices](#step-7-optional-identify-devices)
7. [(optional) Set trip markers](#step-7-optional-set-a-trip-marker)


#### Step 1. Add HyperTrack SDK to your Podfile

We use [CocoaPods](https://cocoapods.org) to distribute the SDK, you can [install it here](https://guides.cocoapods.org/using/getting-started.html#installation).

Using command line run `pod init` in your project directory to create a Podfile. Put the following code (changing target placeholder to your target name) in the Podfile:

```ruby
platform :ios, '9.0'
inhibit_all_warnings!

target 'YourApp' do
  use_frameworks!
  pod 'HyperTrack', '4.0.1'
end
```

Run `pod install`. CocoaPods will build the dependencies and create a workspace (`.xcworkspace`) for you.

If your project uses Objective-C only, you need to configure `SWIFT_VERSION` in your project's Build Settings. Alternatively, you can create an empty Swift file, and Xcode will create this setting for you.

If you are using Xcode 10.1, which doesn't support Swift 5, add this `post_install` script at the bottom of your Podfile:

<details>
<summary>Show code block</summary>

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['GRDB.swift'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
```

</details>

#### Step 2. Enable background location updates

Enable Background Modes in your project target's Capabilities tab. Choose "Location updates".

![Capabilities tab in Xcode](Images/Background_Modes.png)

#### Step 3. Handle location and motion permissions

Set the following purpose strings in the `Info.plist` file:

![Always authorization location](Images/Always_Authorization.png)

HyperTrack SDK requires "Always" permissions to reliably track user's location.
Be advised, purpose strings are mandatory.

Your app needs to make sure that it has location and motion permissions for location tracking to work. See [this F.A.Q. page](#what-are-the-best-practices-for-handling-permissions-on-ios) for details on permissions best practices.

#### Step 4. Initialize the SDK

Put the initialization call inside your `AppDelegate`'s `application:didFinishLaunchingWithOptions:` method:

##### Swift

<details>
<summary>Handling production/development errors:</summary>

```swift
let publishableKey = HyperTrack.PublishableKey("PASTE_YOUR_PUBLISHABLE_KEY_HERE")!

switch HyperTrack.makeSDK(publishableKey: publishableKey) {
case let .success(hyperTrack):
  // Use `hyperTrack` instance
case let .failure(fatalError):
  // Handle errors, for example using switch
}
```

</details>

<details>
<summary>Ignoring any errors:</summary>

```swift
let publishableKey = HyperTrack.PublishableKey("PASTE_YOUR_PUBLISHABLE_KEY_HERE")!

if let hyperTrack = try? HyperTrack(publishableKey: publishableKey) {
  // Use `hyperTrack` instance
}
```

</details>

##### Objective-C

Import the SDK:

```objc
@import HyperTrack;
```

Initialize the SDK.

<details>
<summary>Handling production/development errors:</summary>

```objc
NSString *publishableKey = @"PASTE_YOUR_PUBLISHABLE_KEY_HERE";

HTResult *result = [HTSDK makeSDKWithPublishableKey:publishableKey];
if (result.hyperTrack != nil) {
  // Use `hyperTrack` instance from `result.hyperTrack`
} else {
  // Handle errors, for example using switch:
  switch ([result.error code]) {
    case HTFatalErrorProductionLocationServicesUnavalible:
    case HTFatalErrorProductionMotionActivityServicesUnavalible:
      // Handle a case where device is fully untrackable (either iPhone 5 or lower
      // or not an iPhone
      break;
    case HTFatalErrorProductionMotionActivityPermissionsDenied:
      // Handle motion permissions denied error. Enabling permissions will
      // restart the app
    default:
      // Other errors should only happen during development
      break;
  }
}
```

</details>

<details>
<summary>Ignoring errors:</summary>

```objc
NSString *publishableKey = @"PASTE_YOUR_PUBLISHABLE_KEY_HERE";

HTSDK *hyperTrack = [[HTSDK alloc] initWithPublishableKey:publishableKey];
if (hyperTrack != nil) {
  // Use `hyperTrack` instance
}
```

</details>

##### NSNotifications

Restorable and Unrestorable error notifications are called if the SDK encounters an error that prevents it from tracking. SDK can recover in runtime from Restorable errors if the error reason is resolved. Errors include:
  - Initialization errors, like denied Location or Motion permissions (`RestorableError.locationPermissionsDenied`)
  - Authorization errors from the server. If the trial period ends and there is no credit card tied to the account, this is the error that will be called (`RestorableError.trialEnded`)
  - Incorrectly typed Publishable Key (`UnrestorableError.invalidPublishableKey`)

###### Swift

<details>
<summary>If you want to handle errors using the same selector:</summary>

```swift
NotificationCenter.default.addObserver(
  self,
  selector: #selector(trackingError(notification:)),
  name: HyperTrack.didEncounterUnrestorableErrorNotification,
  object: nil
)
NotificationCenter.default.addObserver(
  self,
  selector: #selector(trackingError(notification:)),
  name: HyperTrack.didEncounterRestorableErrorNotification,
  object: nil
)

...

@objc func trackingError(notification: Notification) {
  if let trackingError = notification.hyperTrackTrackingError() {
    // Handle TrackingError, which is an enum of Restorable or Unrestorable error
  }
}
```

</details>

<details>
<summary>If you want to handle errors separately, or handle only Restorable or only Unrestorable errors:</summary>

```swift
NotificationCenter.default.addObserver(
  self,
  selector: #selector(unrestorableError(notification:)),
  name: HyperTrack.didEncounterUnrestorableErrorNotification,
  object: nil
)
NotificationCenter.default.addObserver(
  self,
  selector: #selector(restorableError(notification:)),
  name: HyperTrack.didEncounterRestorableErrorNotification,
  object: nil
)

...

@objc func restorableError(notification: Notification) {
  if let restorableError = notification.hyperTrackRestorableError() {
    // Handle RestorableError
  }
}

@objc func unrestorableError(notification: Notification) {
  if let unrestorableError = notification.hyperTrackUnrestorableError() {
    // Handle UnrestorableError
  }
}
```

</details>

###### Objective-C

<details>
<summary>If you want to handle errors using the same selector:</summary>

```objc
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(hyperTrackEncounteredTrackingError:)
                                             name:HTSDK.didEncounterRestorableErrorNotification
                                           object:nil];
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(hyperTrackEncounteredTrackingError:)
                                             name:HTSDK.didEncounterUnrestorableErrorNotification
                                           object:nil];

...

- (void)hyperTrackEncounteredTrackingError:(NSNotification *)notification {
  // Use tracking error helper
  NSError *error = [notification hyperTrackTrackingError];
  if (error != nil) {
    if ([[error domain] isEqualToString:NSError.HTRestorableErrorDomain]) {
      // Handle restorable error
    } else if ([[error domain] isEqualToString:NSError.HTUnrestorableErrorDomain]) {
      // Handle unrestorable error
    }
  }
}

```

</details>

<details>
<summary>If you want to handle errors separately, or handle only Restorable or only Unrestorable errors:</summary>

```objc
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(hyperTrackEncounteredRestorableError:)
                                             name:HTSDK.didEncounterRestorableErrorNotification
                                           object:nil];
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(hyperTrackEncounteredUnrestorableError:)
                                             name:HTSDK.didEncounterUnrestorableErrorNotification
                                           object:nil];

...

- (void)hyperTrackEncounteredRestorableError:(NSNotification *)notification {
  NSError *restorableError = [notification hyperTrackRestorableError]);
  // Handle RestorableError
 }

- (void)hyperTrackEncounteredUnrestorableError:(NSNotification *)notification {
  NSError *unrestorableError = [notification hyperTrackUnrestorableError]);
  // Handle UnrestorableError
}
```

</details>

---

You can also observe when SDK starts and stops tracking and update the UI:

###### Swift

```swift
NotificationCenter.default.addObserver(
  self,
  selector: #selector(self.trackingStarted),
  name: HyperTrack.startedTrackingNotification,
  object: nil
)
NotificationCenter.default.addObserver(
  self,
  selector: #selector(self.trackingStopped),
  name: HyperTrack.stoppedTrackingNotification,
  object: nil
)
```

###### Objective-C

```objc
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(trackingStarted)
                                             name:HTSDK.startedTrackingNotification
                                           object:nil];

[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(trackingStopped)
                                             name:HTSDK.stoppedTrackingNotification
                                           object:nil];
```

#### Step 5. Enable remote notifications

The SDK has a bi-directional communication model with the server. This enables the SDK to run on a variable frequency model, which balances the fine trade-off between low latency tracking and battery efficiency, and improves robustness. For this purpose, the iOS SDK uses APNs silent remote notifications.

> This guide assumes you have configured APNs in your application. If you haven't, read the [iOS documentation on APNs](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns).

##### Configure APNs on the dashboard

Log into the HyperTrack dashboard, and open the [setup page](https://dashboard.hypertrack.com/setup). Upload your Auth Key (file in the format `AuthKey_KEYID.p8`) and fill in your Team ID.

This key will only be used to send silent push notifications to your apps.

##### Enable remote notifications in the app

In the app capabilities, ensure that **remote notifications** inside background modes is enabled.

![Remote Notifications in Xcode](Images/Remote_Notifications.png)

In the same tab, ensure that **push notifications** is enabled.

![Push Notifications in Xcode](Images/Push_Notifications.png)

##### Registering and receiving notifications

The following changes inside AppDelegate will register the SDK for push notifications and route HyperTrack notifications to the SDK.

###### Register for notifications

Inside `didFinishLaunchingWithOptions`, use the SDK method to register for notifications.

**Swift**

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    HyperTrack.registerForRemoteNotifications()
    return true
}
```

**Objective-C**

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [HTSDK registerForRemoteNotifications];
    return YES;
}
```

###### Register device token

Inside and `didRegisterForRemoteNotificationsWithDeviceToken` and `didFailToRegisterForRemoteNotificationsWithError` methods, add the relevant lines so that HyperTrack can register the device token.

**Swift**

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    HyperTrack.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
}

func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    HyperTrack.didFailToRegisterForRemoteNotificationsWithError(error)
}
```

**Objective-C**

```objc
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [HTSDK didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [HTSDK didFailToRegisterForRemoteNotificationsWithError:error];
}
```

###### Receive notifications

Inside the `didReceiveRemoteNotification` method, add the HyperTrack receiver. This method parses only the notifications sent from HyperTrack.

**Swift**

```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    HyperTrack.didReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
}
```

**Objective-C**

```objc
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [HTSDK didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}
```

If you want to make sure to only pass HyperTrack notifications to the SDK, you can use the "hypertrack" key:

**Swift**

```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if userInfo["hypertrack"] != nil {
        // This is HyperTrack's notification
        HyperTrack.didReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
    } else {
        // Handle your server's notification here
    }
}
```

**Objective-C**

```objc
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (userInfo[@"hypertrack"] != nil) {
        // This is HyperTrack's notification
        [HTSDK didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    } else {
        // Handle your server's notification here
    }
}

```

#### Step 6. (optional) Identify devices
All devices tracked on HyperTrack are uniquely identified using [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier). You can get this identifier programmatically in your app by calling `getDeviceId` after initialization.
Another approach is to tag device with a name that will make it easy to distinguish them on HyperTrack Dashboard.

##### Swift

```swift
hyperTrack.setDeviceName("Device name")
```

##### Objective-C

```objc
hyperTrack.deviceName = @"Device name";
```

You can additionaly tag devices with custom metadata. Metadata should be representable in JSON.


##### Swift

```swift
if let metadata = HyperTrack.Metadata(rawValue: ["key": "value"]) {
  hyperTrack.setDeviceMetadata(metadata)
} else {
  // Metadata can't be represented in JSON
}
```

##### Objective-C

```objc
NSDictionary *dictionary = @{@"key": @"value"};

HTMetadata *metadata = [[HTMetadata alloc] initWithDictionary:dictionary];
if (metadata != nil) {
  [self.hyperTrack setDeviceMetadata:metadata];
} else {
  // Metadata can't be represented in JSON
}
```

#### Step 7. (optional) Set a trip marker

Use this optional method if you want to tag the tracked data with trip markers that happen in your app. E.g. user marking a task as done, user tapping a button to share location, user accepting an assigned job, device entering a geofence, etc.

The process is the same as for device metadata:

##### Swift

```swift
if let metadata = HyperTrack.Metadata(rawValue: ["status": "PICKING_UP"]) {
  hyperTrack.addTripMarker(metadata)
} else {
  // Metadata can't be represented in JSON
}
```

##### Objective-C

```objc
NSDictionary *dictionary = @{@"status": @"PICKING_UP"};

HTMetadata *metadata = [[HTMetadata alloc] initWithDictionary:dictionary];
if (metadata != nil) {
  [self.hyperTrack addTripMarker:metadata];
} else {
  // Metadata can't be represented in JSON
}

```

#### You are all set

You can now run the app and start using HyperTrack. You can see your devices on the [dashboard](#dashboard).

## Dashboard

Once your app is running, go to the [dashboard](https://dashboard.hypertrack.com/devices) where you can see a list of all your devices and their live location with ongoing activity on the map.

![Dashboard](Images/Dashboard.png)


## Frequently Asked Questions
- [Error: Access to Activity services has not been authorized](#error-access-to-activity-services-has-not-been-authorized)
- [What are the best practices for handling permissions on iOS?](#what-are-the-best-practices-for-handling-permissions-on-ios)


### Error: Access to Activity services has not been authorized
You are running the quickstart app on the iOS simulator, which currently does not support CoreMotion services. You can test the quickstart app on real iOS devices only.

### What are the best practices for handling permissions on iOS?
In [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/app-architecture/requesting-permission/) Apple recommends:
- Requesting permissions only when they are needed in the flow of the app. If you app is centered around location tracking, then asking for permissions at the app launch can be understandable for users. On the other hand, if location tracking is just one of the features, then it makes sense to request them only when the feature is activated.
- Providing short and specific purpose string. Purpose string should explain the value that location and motion tracking provides. Examples of motion tracking benefits: improves battery life by using algorithms based on motion tracking data, provides story-like details for historical tracking data, gives live feedback on current activity.

In addition a lot of great apps [provide a special screen](https://pttrns.com/?scid=56) explaining the need for permissions before asking them. If permissions are denied you can guide the user to the specific page in the Settings.app to change permissions (see [this guide](https://www.macstories.net/ios/a-comprehensive-guide-to-all-120-settings-urls-supported-by-ios-and-ipados-13-1/) for special deep-links for the Settings.app).

On iOS 13 Apple introduced a new "Provisional Always" authorization state (see [this SO answer](https://stackoverflow.com/a/58822468/1352537) for details). In short:

- there is no API to detect this state
- during this state there are no location events in background
- user sees his permissions as granted and sees "While Using" state in Settings.app
- app sees permissions as granted with "Always" state.

HyperTrack is working on ways to detect this state and provide APIs that would enable app developers to display explanation screens that will guide the user back to Settings.app to switch permissions from "While Using" to "Always".

## Support
Join our [Slack community](https://join.slack.com/t/hypertracksupport/shared_invite/enQtNDA0MDYxMzY1MDMxLTdmNDQ1ZDA1MTQxOTU2NTgwZTNiMzUyZDk0OThlMmJkNmE0ZGI2NGY2ZGRhYjY0Yzc0NTJlZWY2ZmE5ZTA2NjI) for instant responses. You can also email us at help@hypertrack.com.
