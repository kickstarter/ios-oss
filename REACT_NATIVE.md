1. Install Node.js v20 or higher (I used v22.14.0), either via the [Node.js website](https://nodejs.org), via the [Homebrew node formula](https://formulae.brew.sh/formula/node), or one of the node version managers.
2. Install Cocoapods, either via the `gem install` method or via the [Homebrew cocoapods formula](https://cocoapods.org).
3. Run `RCT_NEW_ARCH_ENABLED=0 pod install` from the iOS repository root. If you don't include the `RCT_NEW_ARCH_ENABLED=0` bit, React Native will install with the new architecture enabled, which seems to be broken.
4. Run `npm install` from the iOS repository root.
5. Run `npm install` from the `react-native` folder in the iOS repository.
6. Because I set the project up wrong, it's expecting the iOS folder's `node_modules` folder to be in the parent folder of the iOS repository root. Copy or symlink the node_modules folder into its parent directory.
7. You should be able to run `npm start` from the `react-native` folder and see the Metro bundler. This is what is serving the React Native JavaScript bundle to the mobile app. It must be running for the app to work in dev mode.
8. Build and run the app, and you should be able to see the app running inside the React Native view.
9. If you want to run the app on a physical device, you need to set the environment variable `KSR_JS_LOCATION` to the IP and port of your Metro server. For me this is `10.0.1.20:8081`. Metro will tell you what port it's using when it starts.

# Notes

- Do not run the format script. It will format the code in your Pods folder, and that will cause a bunch of problems.
- If you get weird errors with JavaScript, you can run `npm start --reset-cache` to rebuild the JavaScript bundle.
- You MUST run the app via `Kickstarter.xcworkspace`, instead of the normal `Kickstarter.xcodeproj` we're used to. This is because of the addition of CocoaPods.
- If you use the Nix package manager, things may break if you dont have Node/Cocoapods/Gem installed globally. If you don't know what this is, it doesn't affect you.
