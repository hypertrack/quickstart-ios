# HyperTrack Quickstart for iOS SDK

![GitHub](https://img.shields.io/github/license/hypertrack/quickstart-ios.svg)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/HyperTrack.svg)
[![iOS SDK](https://img.shields.io/badge/iOS%20SDK-4.0.1-brightgreen.svg)](https://cocoapods.org/pods/HyperTrack)

[HyperTrack](https://www.hypertrack.com) lets you add live location tracking to your mobile app. Live location is made available along with ongoing activity, tracking controls and tracking outage with reasons. This repo contains an example iOS app that has everything you need to get started in minutes.

* [Publishable Key](#publishable-key)–Sign up and get your keys
* [Quickstart](#quickstart-app)–Start with a ready-to-go app with reliable background service
* [Create a trip](#create-a-trip)-Create a trip using our REST API to start tracking location
* [Dashboard](#dashboard)–See live location of all your devices on your HyperTrack dashboard
* [Support](#support)–Support

## Publishable Key

We use Publishable Key to identify your devices. To get one:
1. Go to the [Signup page](https://dashboard.hypertrack.com/signup). Enter your email address and password.
2. Open the verification link sent to your email.
3. Open the [Setup page](https://dashboard.hypertrack.com/setup), where you can copy your Publishable Key.

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

Run the app on your phone and you should see the following interface:

![Quickstart app](Images/On_Device.png)

Enable location and activity permissions (choose "Always Allow" for location).

Next you can [create a trip](#create-a-trip) to start tracking using our [REST API](https://docs.hypertrack.com/#references-apis).

After the trip is created check out the [dashboard](#dashboard) to see the live location of your devices on the map.

## Create a trip

You can use our [Postman collection](https://www.getpostman.com/run-collection/a2318d122f1b88fae3c1) to create a trip using [HyperTrack REST API](https://docs.hypertrack.com/#references-apis-trips-post-trips) or use the following cURL request:

```curl
curl -u USERNAME:PASSWORD --location --request POST 'https://v3.api.hypertrack.com/trips/' \
--header 'Content-Type: application/json' \
--data-raw '{
    "device_id": "DEVICEID",
    "destination": {
        "geometry": {
            "type": "Point",
            "coordinates": [LONGITUDE, LATITUDE]
        }
    }
}'
```

Substitute:
* `DEVICEID` for Device ID of your device (can be seen on the app itself or in logs)
* `USERNAME` and `PASSWORD` for `AccountId` and `SecretKey` obtained in the [Setup page](https://dashboard.hypertrack.com/setup)
* `LATITUDE` and `LONGITUDE` for real values of your destination

## Dashboard

Once your app is running, go to the [dashboard](https://dashboard.hypertrack.com/devices) where you can see a list of all your devices and their live location with ongoing activity on the map.

## Support
Join our [Slack community](https://join.slack.com/t/hypertracksupport/shared_invite/enQtNDA0MDYxMzY1MDMxLTdmNDQ1ZDA1MTQxOTU2NTgwZTNiMzUyZDk0OThlMmJkNmE0ZGI2NGY2ZGRhYjY0Yzc0NTJlZWY2ZmE5ZTA2NjI) for instant responses. You can also email us at help@hypertrack.com.
