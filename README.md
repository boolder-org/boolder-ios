# boolder-ios

TODO

## Mapbox

### Step 1

To be able to download the SDK via Swift Package Manager, you must first configure the secret token.

Edit your `~/.netrc` file to add the following lines:

```
machine api.mapbox.com
login mapbox
password YOUR_SECRET_MAPBOX_ACCESS_TOKEN
```

More info: https://docs.mapbox.com/ios/maps/guides/install/

## Step 2

Store the secret token in the `~/.mapbox` file:

```
YOUR_SECRET_MAPBOX_ACCESS_TOKEN
```

More info: https://docs.mapbox.com/help/troubleshooting/private-access-token-android-and-ios/
