# HyperTrack Quickstart for iOS SDK

[![GitHub](https://img.shields.io/github/license/hypertrack/quickstart-ios?color=orange)](./LICENSE)
[![iOS SDK](https://img.shields.io/badge/iOS%20SDK-5.0.3-brightgreen.svg)](https://github.com/hypertrack/sdk-ios)

[HyperTrack](https://www.hypertrack.com) lets you add live location tracking to your mobile app.
Live location is made available along with ongoing activity, tracking controls and tracking outage with reasons.
This repo contains an example iOS app that has everything you need to get started in minutes.

## Create HyperTrack Account

[Sign up](https://dashboard.hypertrack.com/signup) for HyperTrack and
get your publishable key from the [Setup page](https://dashboard.hypertrack.com/setup).

## Clone Quickstart app

Open `Quickstart.xcodeproj`.

### Set your Publishable Key

Open the Quickstart project and set your Publishable Key by adding a `HyperTrackPublishableKey` key in the Info.plist file with a String value obtained from the [Setup page](https://dashboard.hypertrack.com/setup).

### Setup silent push notifications

Set up silent push notifications to manage on-device tracking using HyperTrack cloud APIs from your server.

Log into the HyperTrack dashboard, and open the [setup page](https://dashboard.hypertrack.com/setup).
Upload your Auth Key (file in the format `AuthKey_KEYID.p8` obtained/created from Apple Developer console > Certificates, Identifiers & Profiles > Keys)
and fill in your Team ID (Can be seen in Account > Membership).

### Run the Quickstart app

Run the app on your phone and you should see the following interface:

![Quickstart app](Images/On_Device.png)

> HyperTrack creates a unique internal device identifier that's used as mandatory key for all HyperTrack API calls.
> Please be sure to get the `device_id` from the app or the logs. The app calls
> [deviceID](https://www.hypertrack.com/docs/references/#references-sdks-ios-deviceid) to retrieve it.

You may also set device name and metadata using the [Devices API](https://www.hypertrack.com/docs/references/#references-apis-devices-set-device-name-and-metadata)

## Start tracking

Now the app is ready to be tracked from the cloud. HyperTrack gives you powerful APIs
to control device tracking from your backend.

> To use the HyperTrack API, you will need the `{AccountId}` and `{SecretKey}` from the [Setup page](https://dashboard.hypertrack.com/setup).

### Track devices during work

Track devices when user is logged in to work, or during work hours by calling the
[Devices API](https://www.hypertrack.com/docs/references/#references-apis-devices-get-device-location-and-status).

To start, call the [start](https://www.hypertrack.com/docs/references/#references-apis-devices-start-tracking) API.

```
curl -X POST \
  -u {AccountId}:{SecretKey} \
  https://v3.api.hypertrack.com/devices/{device_id}/start
```


Get the tracking status of the device by calling
[GET /devices/{device_id}](https://www.hypertrack.com/docs/references/#references-apis-devices-get-device-location-and-status) api.

```
curl \
  -u {AccountId}:{SecretKey} \
  https://v3.api.hypertrack.com/devices/{device_id}
```

To see the device on a map, open the returned embed_url in your browser (no login required, so you can add embed these views directly to you web app).
The device will also show up in the device list in the [HyperTrack dashboard](https://dashboard.hypertrack.com/).

To stop tracking, call the [stop](https://www.hypertrack.com/docs/references/#references-apis-devices-stop-tracking) API.

```
curl -X POST \
  -u {AccountId}:{SecretKey} \
  https://v3.api.hypertrack.com/devices/{device_id}/stop
```

### Track trips with ETA

If you want to track a device on its way to a destination, call the [Trips API](https://www.hypertrack.com/docs/references/#references-apis-trips-start-trip-with-destination)
and add destination.

HyperTrack Trips API offers extra fields to get additional intelligence over the Devices API.
* set destination to track route and ETA
* set scheduled_at to track delays
* share live tracking URL of the trip with customers
* embed live tracking view of the trip in your ops dashboard

```curl
curl -u {AccountId}:{SecretKey} --location --request POST 'https://v3.api.hypertrack.com/trips/' \
--header 'Content-Type: application/json' \
--data-raw '{
    "device_id": "{device_id}",
    "destination": {
        "geometry": {
            "type": "Point",
            "coordinates": [{longitude}, {latitude}]
        }
    }
}'
```

To get `{longitude}` and `{latitude}` of your destination, you can use for example [Google Maps](https://support.google.com/maps/answer/18539?co=GENIE.Platform%3DDesktop&hl=en).

> HyperTrack uses [GeoJSON](https://en.wikipedia.org/wiki/GeoJSON). Please make sure you follow the correct ordering of longitude and latitude.

The returned JSON includes the embed_url for your dashboard and share_url for your customers.

When you are done tracking this trip, call [complete](https://www.hypertrack.com/docs/references/#references-apis-trips-complete-trip) Trip API using the `trip_id` from the create trip call above.
```
curl -X POST \
  -u {AccountId}:{SecretKey} \
  https://v3.api.hypertrack.com/trips/{trip_id}/complete
```

After the trip is completed, use the [Trips API](https://www.hypertrack.com/docs/references/#references-apis-trips) to
retrieve a full [summary](https://www.hypertrack.com/docs/references/#references-apis-trips-get-trip-summary) of the trip.
The summary contains the polyline of the trip, distance, duration and markers of the trip.

```
curl -X POST \
  -u {AccountId}:{SecretKey} \
  https://v3.api.hypertrack.com/trips/{trip_id}
```


### Track trips with geofences

If you want to track a device going to a list of places, call the [Trips API](https://www.hypertrack.com/docs/references/#references-apis-trips)
and add geofences. This way you will get arrival, exit, time spent and route to geofences. Please checkout our [docs](https://www.hypertrack.com/docs/references/#references-apis-trips) for more details.

## Dashboard

Once your app is running, go to the [dashboard](https://dashboard.hypertrack.com/devices) where you can see a list of all your devices and their live location with ongoing activity on the map.

## Documentation

You can find API references in our [docs](https://www.hypertrack.com/docs/references/#references-sdks-ios). There is also a full in-code reference for all SDK methods.

## Support
Join our [Slack community](https://join.slack.com/t/hypertracksupport/shared_invite/enQtNDA0MDYxMzY1MDMxLTdmNDQ1ZDA1MTQxOTU2NTgwZTNiMzUyZDk0OThlMmJkNmE0ZGI2NGY2ZGRhYjY0Yzc0NTJlZWY2ZmE5ZTA2NjI) for instant responses. You can also email us at help@hypertrack.com.
