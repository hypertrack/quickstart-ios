# Example app for onboarding for order tracking on iOS

Once you have completed [onboarding for the order tracking use case](https://dashboard.hypertrack.com/onboarding/order-tracking;step=0.0) at HyperTrack, your app would look like this app. 

## Mock tracking
To use mock data to test, you can make the following changes:

1. replace `startTracking` with `startMockTracking`
2. replace `stopTracking` with `stopMockTracking`

This repo has a branch that uses mock tracking APIs, called `mock-tracking`. You can check out this branch and compile to avoid making the code changes yourself.

```
git pull
git checkout mock-tracking
```