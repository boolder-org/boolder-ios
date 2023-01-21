# Boolder iOS

Boolder is the best way to discover bouldering in Fontainebleau.

The app is available at https://www.boolder.com/en/app

## Contribute

Want to help us improve the app for thousands of climbers? Great!

Here are a few ways you can contribute:
- Open an issue if you find a bug
- Open an issue if you want to suggest an improvement
- Open a Pull Request (please get in touch with us beforehand, though)

We already have a lot of features waiting to be built, and lots of new ideas to try out!
We'd be happy to share the fun with you :)

As the project is still young, the best way to get started is to drop us a line at hello@boolder.com


## Build the app

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

### Step 2

Store the secret token in the `~/.mapbox` file:

```
YOUR_SECRET_MAPBOX_ACCESS_TOKEN
```

More info: https://docs.mapbox.com/help/troubleshooting/private-access-token-android-and-ios/
