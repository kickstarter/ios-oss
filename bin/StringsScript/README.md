# StringsScript

## How to contribute to this script:

Most of the fuctionality lives in StringsScriptCore. Any new functionality should also be added to this framework and tested.

## Good things to know:

* You can build this script from the command line by navigating to the root `bin/StringsScript` folder and running `swift build`
    * If you get the error `use of unresolved identifier 'Secrets'`, copy the file `Secrets.swift` located at `Frameworks/native-secrets/ios/Secrets.swift` to the  `bin/StringsScript/Sources/StringsScriptCore` folder. Make sure that the option `Copy items if needed` is unchecked and set its Target Membership to `StringsScriptCore`.
    * you can run the debug binary from the command line using `./.build/debug/StringsScript ./Library/Strings.swift ./Kickstarter-iOS/Locales` (from the root StringsScript folder). Where `./Library/Strings.swift` and  `Kickstarter-iOS/Locales`  are the paths where the files will be created.
	* any time you make changes to the script, you'll have to rebuild it in order to see your changes
* You can run tests in the command line with `swift test`

Once you're happy with your changes to the script, you'll need to rebuild it with the release configuration to create the release binary that others will use. To build this script for the release configuration, run `swift build -c release -Xswiftc -static-stdlib`. This will create a binary called `StringsScript` located in the `.build/release` folder. Please move the release binary to the `ios-oss/bin` folder using `cp StringsScript ../../../strings-script`
