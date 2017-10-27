# ios-sdk-onboarding-objc

App link: https://github.com/hypertrack/ios-sdk-onboarding-objc

# Install the SDK - 1
The HyperTrack SDK is available via CocoaPods. Add the following lines to your Podfile to install the SDK.

In case you haven't setup CocoaPods for your app, refer to their website and setup a Podfile, and then add these lines. 

> **Xcode project**
> Remember to use the .xcworkspace file to open your project in Xcode, instead of the .xcodeproj file, from here on.

* https://github.com/hypertrack/ios-sdk-onboarding-objc/blob/master/Podfile

# Install the SDK - 2
Now that the SDK has been installed, you can use the SDK methods inside Xcode. Configure your publishable key and initialise the SDK.

* https://github.com/hypertrack/ios-sdk-onboarding-objc/blob/master/HyperTrackOnboarding/AppDelegate.m

> **Account keys**
> Sign up to get account keys if you haven't already.

# Enable location
Go to the capabilities tab in your app settings, scroll to background modes and switch it on for:
* Location updates
* Background fetch
* Remote notifications

Go to the Info tab in your app settings and add permission strings for:
* Privacy - Location Always Usage Description
* Privacy - Motion Usage Description" 

* https://github.com/hypertrack/ios-sdk-onboarding-objc/blob/master/HyperTrackOnboarding/AppDelegate.m

# Identify device
The SDK needs a **User** object to identify the device. The SDK has a convenience method `getOrCreateUser()` to lookup an existing user using a unique identifier (called `lookupId`) or create one if necessary.

Method parameters
| Parameter | Description |
|-----------|-------------|
| userName  | Name of the user entity |
| phone     | Phone number of the user entity |
| lookupId  | Unique identifier for your user |

Use this API in conjunction to your app's login flow, and call `getOrCreate` at the end of a successful login flow. This API is a network call, and needs to be done only once in the user session lifecycle.

* https://github.com/hypertrack/ios-sdk-onboarding-objc/blob/master/HyperTrackOnboarding/ViewController.m

> Waiting for your app to run

# Start tracking
Use the `startTracking()` method to start tracking. Once the user starts tracking, you can see **Trips** and **Stops** of the user.

This is a non-blocking API call, and will also work when the device is offline. 

* https://github.com/hypertrack/ios-sdk-onboarding-objc/blob/master/HyperTrackOnboarding/ViewController.m

> Waiting for your app to run

> **View on the dashboard**
> View the user's trips and stops here.

# Stop tracking
Use the `stopTracking()` method to stop tracking. This can be done when the user logs out.

* https://github.com/hypertrack/ios-sdk-onboarding-objc/blob/master/HyperTrackOnboarding/LogoutController.m

> **Ready to deploy!**
> Your iOS app is all set to be deployed to the App Store. As your users update and log in, their live location will be visualized on this dashboard.

## Next steps
* Add team members to the HyperTrack dashboard
* Follow one of our use-case tutorials to build your live location feature
