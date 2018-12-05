import Foundation
import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class MessageBannerViewModelTests: TestCase {
  let vm = MessageBannerViewModel()

  let bannerBackgroundColor = TestObserver<UIColor, NoError>()
  let bannerMessage = TestObserver<String, NoError>()
  let iconIsHidden = TestObserver<Bool, NoError>()
  let iconTintColor = TestObserver<UIColor, NoError>()
  let messageBannerViewIsHidden = TestObserver<Bool, NoError>()
  let messageTextAlignment = TestObserver<NSTextAlignment, NoError>()
  let messageTextColor = TestObserver<UIColor, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.bannerBackgroundColor.observe(bannerBackgroundColor.observer)
    self.vm.outputs.bannerMessage.observe(bannerMessage.observer)
    self.vm.outputs.iconIsHidden.observe(iconIsHidden.observer)
    self.vm.outputs.iconTintColor.observe(iconTintColor.observer)
    self.vm.outputs.messageBannerViewIsHidden.observe(messageBannerViewIsHidden.observer)
    self.vm.outputs.messageTextAlignment.observe(messageTextAlignment.observer)
    self.vm.outputs.messageTextColor.observe(messageTextColor.observer)
  }

  func testWithSuccessConfiguration() {
    self.vm.inputs.update(with: (.success, Strings.Got_it_your_changes_have_been_saved()))

    self.bannerBackgroundColor.assertValue(MessageBannerType.success.backgroundColor)
    self.bannerMessage.assertValue(Strings.Got_it_your_changes_have_been_saved())
    self.iconIsHidden.assertValue(false)
    self.messageTextAlignment.assertValue(.left)
    self.messageTextColor.assertValue(MessageBannerType.success.textColor)
  }

  func testErrorConfiguration() {
    self.vm.inputs.update(with: (.error, Strings.general_error_oops()))

    self.bannerBackgroundColor.assertValue(MessageBannerType.error.backgroundColor)
    self.bannerMessage.assertValue(Strings.general_error_oops())
    self.iconIsHidden.assertValue(false)
    self.iconTintColor.assertValue(UIColor.black)
    self.messageTextAlignment.assertValue(.left)
    self.messageTextColor.assertValue(MessageBannerType.error.textColor)
  }

  func testInfoConfiguration() {
    self.vm.inputs.update(with: (.info, Strings.Verification_email_sent()))

    self.bannerBackgroundColor.assertValue(MessageBannerType.info.backgroundColor)
    self.bannerMessage.assertValue(Strings.Verification_email_sent())
    self.iconIsHidden.assertValue(true)
    self.messageTextAlignment.assertValue(.center)
    self.messageTextColor.assertValue(MessageBannerType.info.textColor)
  }

  func testShowHideBannerManual() {
    withEnvironment {
      self.vm.inputs.update(with: (.success, "Success"))
      self.vm.inputs.showBannerView(shouldShow: true)

      self.messageBannerViewIsHidden.assertValues([false], "Message banner should show")

      self.vm.inputs.showBannerView(shouldShow: false)

      scheduler.advance(by: .seconds(5))

      self.messageBannerViewIsHidden.assertValues([false, true], "Message banner should hide")
    }

  }

  func testShowHideFiltersRepeats() {
    self.vm.inputs.update(with: (.success, "Success"))

    self.vm.inputs.showBannerView(shouldShow: true)
    self.vm.inputs.showBannerView(shouldShow: true)

    self.messageBannerViewIsHidden.assertValues([false], "Message banner should show")
  }

  func testHideBannerAutomatically() {
    withEnvironment {
      self.vm.inputs.update(with: (.success, "Success"))

      self.vm.inputs.showBannerView(shouldShow: true)

      scheduler.schedule(after: .seconds(5), action: {
        self.messageBannerViewIsHidden.assertValues([false, true],
                                                            "Message banner should show then hide")
      })
    }
  }
}
