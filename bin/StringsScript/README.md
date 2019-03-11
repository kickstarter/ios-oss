# StringsScript

## How to contribute to this script:

Most of the fuctionality lives in StringsScriptCore. Any new functionality should also be added to this framework and tested.

### Good things to know:

* You can build this script from the command line by navigating to the root /StringsScript folder and running `swift build`
	* you can run the debug binary from the command line using `./.build/debug/StringsScript` (from the root StringsScript folder)
* You can run tests in the command line with `swift test`

To build this script for the release configuration, run `swift build -c release -Xswiftc -static-stdlib`. This will create a binary called `StringsScript` located in the `.build/release` folder. Please move the release binary to the `ios-oss/bin` folder using `cp StringsScript ../../../strings-script`
