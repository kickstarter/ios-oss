import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class MessageBannerViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()

    UIView.setAnimationsEnabled(false)
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testBannerSuccess() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language) {
        let banner = Storyboard.Settings.instantiate(MessageBannerViewController.self)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: banner)
        parent.view.frame.size.height = 200

        banner.setBannerType(type: .success, message: "Got it! Your password was saved.")
        banner.showBannerView()

        scheduler.run()
        scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testBannerError() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language) {
        let banner = Storyboard.Settings.instantiate(MessageBannerViewController.self)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: banner)
        parent.view.frame.size.height = 200

        banner.setBannerType(type: .error, message: "Oops! Something went wrong. Please try again.")
        banner.showBannerView()

        scheduler.run()
        scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testBannerInfo() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language) {
        let banner = Storyboard.Settings.instantiate(MessageBannerViewController.self)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: banner)
        parent.view.frame.size.height = 200

        let message = "We need to inform you about something really important. Don't forget this message."
        banner.setBannerType(type: .info,
                             message: message)
        banner.showBannerView()

        scheduler.run()
        scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
