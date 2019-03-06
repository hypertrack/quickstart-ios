# HyperTrack SDK Quickstart for iOS

![GitHub](https://img.shields.io/github/license/hypertrack/quickstart-ios.svg)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/HyperTrackCore.svg)

[HyperTrack](https://www.hypertrack.com) lets you add live location tracking to your mobile app. This repo contains an example client app that has everything you need to get started in minutes.

* [Publishable Key](#publishable-key) - How to get your Publishable Key
* [Quickstart](#quickstart) - Start with a ready-to-go app
* [Install the SDK](#install-the-sdk) - Integrate the SDK into your app
* [Dashboard](#dashboard) - See all your devices' locations in Dashboard

## Publishable Key

We use Publishable Key to identify your devices.

To get one:

1. Go to the [Signup page](https://v3.dashboard.hypertrack.com/signup). Enter your email address and password.
2. Open the verification link sent to your inbox.
3. Open the [Keys page](https://v3.dashboard.hypertrack.com/account/keys), where you can copy your Publishable Key.

![Signup flow](Images/Signup_flow.png)

Next, you can [start with the Quickstart app](#quickstart) that is ready to go or you can [integrate the SDK](#install-the-sdk) in your app.

## Quickstart

1. [Clone this repo](#step-1:-clone-this-repo)
2. [Install the SDK dependency](#step-2:-install-the-sdk-dependency)
3. [Set your Publishable Key](#step-3:-set-your-publishable-key)
4. [Run the Quickstart app](#step-4:-run-the-quickstart-app)

### Step 1: Clone this repo
```bash
git clone https://github.com/hypertrack/quickstart-ios.git
cd quickstart-ios
```
### Step 2: Install the SDK dependency

Quickstart app uses [CocoaPods](https://cocoapods.org) dependency manager to install the latest version of the SDK. Using the latest version is advised.

If you don't have CocoaPods, [install it first](https://guides.cocoapods.org/using/getting-started.html#installation).

Run `pod install` inside the cloned directory. After CocoaPods creates the `Quickstart.xcworkspace` workspace file, open it with Xcode.

### Step 3: Set your Publishable Key

Open the Quickstart project inside the workspace and set your [Publishable Key](#publishable-key) inside the placeholder in the `AppDelegate.swift` file.

### Step 4: Run the Quickstart app

Run the app on your phone, and you should see the following control interface:

![Quickstart app](Images/On_Device.png)

After enabling location and activity permissions (choose "Always Allow" if you want the app to collect location data in the background), SDK starts collecting location data. You can pause or resume the tracking with the button below.

[Check out the Dashboard](#dashboard) to see your device live on the map.

## Install the SDK

### Requirements

HyperTrack SDK supports iOS 9 and above, using Swift or Objective-C. 

### Step by step instructions

#### Step 1: Add HyperTrackCore SDK to your Podfile

We use [CocoaPods](https://cocoapods.org) to distribute the SDK, you can [install it here](https://guides.cocoapods.org/using/getting-started.html#installation).

Using command line run `pod init` in your project directory to create a Podfile. Put `pod 'HyperTrack'` in the Podfile:

```ruby
platform :ios, '9.0'
inhibit_all_warnings!

target '<Your app name>' do
  use_frameworks!
  pod 'HyperTrack'
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

You can run the app and start using HyperTrack. You can see your devices in the [Dashboard](#dashboard).

## Dashboard

Once your app is running go to the [Dashboard page](https://v3.dashboard.hypertrack.com/devices) where you can see a list of all your devices and their location on the map.

![Dashboard](Images/Dashboard.png)