# Boolder iOS

Boolder is the best way to discover bouldering in Fontainebleau.

The app is available at https://www.boolder.com/en/app

More info: https://www.boolder.com/en/about

## Build the app

### Mapbox setup

#### Step 1

Create an account on https://www.mapbox.com and go to the [Tokens]([url](https://account.mapbox.com/access-tokens/)) page to create 2 tokens:
- 1 public token with all the public `scopes` (or use the default token)
- 1 secret token with all the public `scopes` + the `DOWNLOADS:READ` scope

#### Step 2: set up the public token

Store the secret token in `~/.mapbox` like so:

```
YOUR_PUBLIC_MAPBOX_ACCESS_TOKEN
```

More info [here](https://docs.mapbox.com/help/troubleshooting/private-access-token-android-and-ios/#ios).

#### Step 3: set up the secret token

To be able to download the SDK via Swift Package Manager, you must first configure the secret token.

Edit your `~/.netrc` file to add the following lines:

```
machine api.mapbox.com
  login mapbox
  password YOUR_SECRET_MAPBOX_ACCESS_TOKEN
```

More info [here](https://docs.mapbox.com/ios/maps/guides/install/).

## Contribute

Want to help us improve the app for thousands of climbers? Great!

Here are a few ways you can contribute:
- Open an issue if you find a bug
- Open an issue if you want to suggest an improvement
- Open a Pull Request (please get in touch with us beforehand, though)

We already have a lot of features waiting to be built, and lots of new ideas to try out!
We'd be happy to share the fun with you :)

As the project is still young, the best way to get started is to drop us a line at hello@boolder.com

You can also contribute to our mapping efforts at https://www.boolder.com/en/contribute
