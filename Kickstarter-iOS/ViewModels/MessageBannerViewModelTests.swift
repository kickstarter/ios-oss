import Foundation
import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import ReactiveExtensions_TestHelpers

internal final class MessageBannerViewModelTests: TestCase {
  let vm = MessageBannerViewModel()

  let bannerBackgroundColorObserver = TestObserver<UIColor, NoError>()
  let bannerMessageObserver = TestObserver<String, NoError>()
  let iconIsHiddenObserver = TestObserver<Bool, NoError>()
  let messageBannerViewIsHiddenObserver = TestObserver<Bool, NoError>()
  let messageTextAlignmentObserver = TestObserver<NSTextAlignment, NoError>()
  let messageTextColorObserver = TestObserver<UIColor, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.bannerBackgroundColor.observe(bannerBackgroundColorObserver.observer)
    self.vm.outputs.bannerMessage.observe(bannerMessageObserver.observer)
    self.vm.outputs.iconIsHidden.observe(iconIsHiddenObserver.observer)
    self.vm.outputs.messageBannerViewIsHidden.observe(messageBannerViewIsHiddenObserver.observer)
    self.vm.outputs.messageTextAlignment.observe(messageTextAlignmentObserver.observer)
    self.vm.outputs.messageTextColor.observe(messageTextColorObserver.observer)
  }

  func testWithSuccessConfiguration() {
    self.vm.inputs.setBannerType(type: .success)
    self.vm.inputs.setBannerMessage(message: "Success")

    self.bannerBackgroundColorObserver.assertValue(MessageBannerType.success.backgroundColor)
    self.bannerMessageObserver.assertValue("Success")
    self.iconIsHiddenObserver.assertValue(false)
    self.messageTextAlignmentObserver.assertValue(.left)
    self.messageTextColorObserver.assertValue(MessageBannerType.success.textColor)
  }

  func testErrorConfiguration() {
    self.vm.inputs.setBannerType(type: .error)
    self.vm.inputs.setBannerMessage(message: "Something went wrong")

    self.bannerBackgroundColorObserver.assertValue(MessageBannerType.error.backgroundColor)
    self.bannerMessageObserver.assertValue("Something went wrong")
    self.iconIsHiddenObserver.assertValue(false)
    self.messageTextAlignmentObserver.assertValue(.left)
    self.messageTextColorObserver.assertValue(MessageBannerType.error.textColor)
  }

  func testInfoConfiguration() {
    self.vm.inputs.setBannerType(type: .info)
    self.vm.inputs.setBannerMessage(message: "Some information")

    self.bannerBackgroundColorObserver.assertValue(MessageBannerType.info.backgroundColor)
    self.bannerMessageObserver.assertValue("Some information")
    self.iconIsHiddenObserver.assertValue(true)
    self.messageTextAlignmentObserver.assertValue(.center)
    self.messageTextColorObserver.assertValue(MessageBannerType.info.textColor)
  }

  func testShowHideBannerManual() {
    withEnvironment {
      self.vm.inputs.setBannerMessage(message: "Success")
      self.vm.inputs.setBannerType(type: .success)
      self.vm.inputs.showBannerView(shouldShow: true)

      self.messageBannerViewIsHiddenObserver.assertValues([false], "Message banner should show")

      self.vm.inputs.showBannerView(shouldShow: false)

      scheduler.advance(by: .seconds(5))

      self.messageBannerViewIsHiddenObserver.assertValues([false, true], "Message banner should hide")
    }

  }

  func testShowHideFiltersRepeats() {
    self.vm.inputs.setBannerMessage(message: "Success")
    self.vm.inputs.setBannerType(type: .success)

    self.vm.inputs.showBannerView(shouldShow: true)
    self.vm.inputs.showBannerView(shouldShow: true)

    self.messageBannerViewIsHiddenObserver.assertValues([false], "Message banner should show")
  }

  func testHideBannerAutomatically() {
    withEnvironment {
      self.vm.inputs.setBannerMessage(message: "Success")
      self.vm.inputs.setBannerType(type: .success)

      self.vm.inputs.showBannerView(shouldShow: true)

      scheduler.schedule(after: .seconds(5), action: {
        self.messageBannerViewIsHiddenObserver.assertValues([false, true],
                                                            "Message banner should show then hide")
      })
    }
  }
}
