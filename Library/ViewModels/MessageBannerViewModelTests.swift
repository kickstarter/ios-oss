import Foundation
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class MessageBannerViewModelTests: TestCase {
  let vm = MessageBannerViewModel()

  let bannerBackgroundColor = TestObserver<UIColor, Never>()
  let bannerMessage = TestObserver<String, Never>()
  let iconIsHidden = TestObserver<Bool, Never>()
  let iconTintColor = TestObserver<UIColor, Never>()
  let messageBannerViewIsHidden = TestObserver<Bool, Never>()
  let messageTextAlignment = TestObserver<NSTextAlignment, Never>()
  let messageTextColor = TestObserver<UIColor, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.bannerBackgroundColor.observe(self.bannerBackgroundColor.observer)
    self.vm.outputs.bannerMessage.observe(self.bannerMessage.observer)
    self.vm.outputs.iconIsHidden.observe(self.iconIsHidden.observer)
    self.vm.outputs.iconTintColor.observe(self.iconTintColor.observer)
    self.vm.outputs.messageBannerViewIsHidden.observe(self.messageBannerViewIsHidden.observer)
    self.vm.outputs.messageTextAlignment.observe(self.messageTextAlignment.observer)
    self.vm.outputs.messageTextColor.observe(self.messageTextColor.observer)
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
    self.iconTintColor.assertValue(UIColor.ksr_white)
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
      self.vm.inputs.bannerViewWillShow(true)

      self.messageBannerViewIsHidden.assertValues([false], "Message banner should show")

      self.vm.inputs.bannerViewWillShow(false)

      scheduler.advance(by: .seconds(5))

      self.messageBannerViewIsHidden.assertValues([false, true], "Message banner should hide")
    }
  }

  func testShowHideFiltersRepeats() {
    self.vm.inputs.update(with: (.success, "Success"))

    self.vm.inputs.bannerViewWillShow(true)
    self.vm.inputs.bannerViewWillShow(true)

    self.messageBannerViewIsHidden.assertValues([false], "Message banner should show")
  }

  func testHideBannerAutomatically_VoiceOverOff() {
    withEnvironment(isVoiceOverRunning: { false }) {
      self.vm.inputs.update(with: (.success, "Success"))
      self.vm.inputs.bannerViewWillShow(true)

      scheduler.schedule(after: .seconds(3), action: {
        self.messageBannerViewIsHidden.assertValues([false], "Message banner should still be showing")
      })

      scheduler.schedule(after: .seconds(5), action: {
        self.messageBannerViewIsHidden.assertValues([false, true], "Message banner should show then hide")
      })
    }
  }

  func testHideBannerAutomatically_VoiceOverOn() {
    withEnvironment(isVoiceOverRunning: { true }) {
      self.vm.inputs.update(with: (.success, "Success"))
      self.vm.inputs.bannerViewWillShow(true)

      scheduler.schedule(after: .seconds(9), action: {
        self.messageBannerViewIsHidden.assertValues([false, true], "Message banner should still be showing")
      })

      scheduler.schedule(after: .seconds(11), action: {
        self.messageBannerViewIsHidden.assertValues(
          [false, true, true],
          "Message banner should show then hide"
        )
      })
    }
  }
}
