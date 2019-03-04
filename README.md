# HyperTrack SDK Quickstart for iOS

![GitHub](https://img.shields.io/github/license/hypertrack/quickstart-ios.svg)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/HyperTrackCore.svg)

[HyperTrack](https://www.hypertrack.com) lets you add live location tracking to your mobile app. This repo contains an example client app that has everything you need to get started in minutes.

First, you need Publishable Key so that we can identify your devices. You can get it [here]().
Then you can [start with the Quickstart app](#starting-with-quickstart-app) that is ready to go or you can [integrate the SDK](#integrating-the-SDK-in-your-app) in your app.

## Starting with Quickstart app

### Step 1: Clone this repo
```bash
git clone https://github.com/hypertrack/quickstart-ios.git
cd quickstart-ios
```
### Step 2: Install the SDK dependency

Quickstart app uses CocoaPods dependency manager to install the latest version of the SDK.

If you don't have CocoaPods, [install it first](https://guides.cocoapods.org/using/getting-started.html#installation).

Run `pod install` inside the cloned directory. After CocoaPods creates the `Quickstart.xcworkspace` workspace file, open it with Xcode.

### Step 3: Set your Publishable Key

Open the Quickstart project inside the workspace and set your Publishable Key inside the placeholder in `AppDelegate.swift` file.

### You are all set

Run the app on your phone, and you should see the following control interface:

![Quickstart app](Images/On_Device.png)

After enabling location and activity permissions (choose "Always Allow" if you want the app to collect location data in the background), SDK starts collecting location data. You can pause or resume the tracking with the button below.

## Integrating the SDK in your app

### Requirements

HyperTrack SDK supports iOS 9 and above, using Swift or Objective-C. 

### Step by step instructions

#### Step 1: Add HyperTrackCore SDK to your Podfile

We use [CocoaPods](https://cocoapods.org) to distribute the SDK, you can [install it here](https://guides.cocoapods.org/using/getting-started.html#installation).

Using command line run `pod init` in your project directory to create a Podfile. Put `pod 'HyperTrackCore'` in the the Podfile:

```ruby
platform :ios, '9.0'
inhibit_all_warnings!

target '<#Your app name#>' do
  use_frameworks!
  pod 'HyperTrackCore'
end
```

Run `pod install`. CocoaPods will build the dependencies and create a workspace (`.xcworkspace`) for you.

#### Step 2: Enable background location updates

Enable Background Modes in your project target's Capabilities tab. Choose "Location updates."

![Capabilities tab in Xcode](Images/Background_Modes.png)

#### Step 3: Add authorization description keys

If you want to know the users' locations at all times, set the following description keys with the corresponding text in the `Info.plist` file:

![Always authorization location](Images/Always_Authorization.png)

Include `Privacy - Location Always Usage Description` key only when you need iOS 10 compatibility.

You can ask for "When In Use" location access only, but be advised, the user will see a constant blue bar at the top while your app is running.

![In use authorization location](Images/In_Use_Authorization.png)

#### Step 4: Ask the user for permissions

In your app, use our convenience functions to ask for the location and activity permissions. HyperTrack SDK needs both to generate enriched location data.

##### Swift

```swift
HyperTrackCore.requestLocationPermission { (error) in
    /// handle errors if any
}

HyperTrackCore.requestActivityPermission { (error) in
    /// handle errors if any
}
```

##### Objective-C

```objc
[HTCore requestLocationPermissionWithCompletionHandler:^(HTCoreError * _Nullable error) {
    /// handle errors if any
}];

[HTCore requestActivityPermissionWithCompletionHandler:^(HTCoreError * _Nullable error) {
    /// handle errors if any
}];
```

#### Step 5: Initialize the SDK

Put the initialization code inside your `AppDelegate`'s `application:didFinishLaunchingWithOptions:` method 

##### Swift

```swift
HyperTrackCore.initialize(publishableKey: "<#Paste your Publishable Key here#>") { (error) in
    /// perform post initialization actions
    /// handle errors if any
}
```

##### Objective-C

```objc
[HTCore initializeWithPublishableKey:@"<#Paste your Publishable Key here#>" completionHandler:^(HTCoreError * _Nullable error) {
    /// perform post initialization actions
    /// handle errors if any
}];
```

#### You are all set

You can run the app and start using HyperTrack.
