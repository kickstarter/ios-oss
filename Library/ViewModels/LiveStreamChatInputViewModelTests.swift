import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamChatInputViewModelTests: TestCase {
  private let vm: LiveStreamChatInputViewModelType = LiveStreamChatInputViewModel()

  private let clearTextFieldAndResignFirstResponder = TestObserver<(), NoError>()
  private let moreButtonHidden = TestObserver<Bool, NoError>()
  private let notifyDelegateMessageSent = TestObserver<String, NoError>()
  private let notifyDelegateMoreButtonTapped = TestObserver<(), NoError>()
  private let notifyDelegateRequestLogin = TestObserver<(), NoError>()
  private let placeholderText = TestObserver<String, NoError>()
  private let sendButtonHidden = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.clearTextFieldAndResignFirstResponder.observe(
      self.clearTextFieldAndResignFirstResponder.observer)
    self.vm.outputs.moreButtonHidden.observe(self.moreButtonHidden.observer)
    self.vm.outputs.notifyDelegateMessageSent.observe(self.notifyDelegateMessageSent.observer)
    self.vm.outputs.notifyDelegateMoreButtonTapped.observe(self.notifyDelegateMoreButtonTapped.observer)
    self.vm.outputs.notifyDelegateRequestLogin.observe(self.notifyDelegateRequestLogin.observer)
    self.vm.outputs.placeholderText.map { $0.string }.observe(self.placeholderText.observer)
    self.vm.outputs.sendButtonHidden.observe(self.sendButtonHidden.observer)
  }

  func testButtonsShowingHiding() {
    self.moreButtonHidden.assertValueCount(0)
    self.sendButtonHidden.assertValueCount(0)

    self.vm.inputs.configureWith(chatHidden: false)

    self.moreButtonHidden.assertValues([false])
    self.sendButtonHidden.assertValues([true])

    self.vm.inputs.textDidChange(toText: "Typing")

    self.moreButtonHidden.assertValues([false, true])
    self.sendButtonHidden.assertValues([true, false])

    self.vm.inputs.textDidChange(toText: "    ")

    self.moreButtonHidden.assertValues([false, true, false])
    self.sendButtonHidden.assertValues([true, false, true])

    self.vm.inputs.textDidChange(toText: "")

    self.moreButtonHidden.assertValues([false, true, false, false])
    self.sendButtonHidden.assertValues([true, false, true, true])

    self.vm.inputs.textDidChange(toText: "Typing")

    self.moreButtonHidden.assertValues([false, true, false, false, true])
    self.sendButtonHidden.assertValues([true, false, true, true, false])

    self.vm.inputs.sendButtonTapped()

    self.moreButtonHidden.assertValues([false, true, false, false, true, false])
    self.sendButtonHidden.assertValues([true, false, true, true, false, true])
  }

  func testMessageSent() {
    self.notifyDelegateMessageSent.assertValueCount(0)

    self.vm.inputs.configureWith(chatHidden: false)
    self.vm.inputs.textDidChange(toText: "Typing")
    self.vm.inputs.sendButtonTapped()

    self.notifyDelegateMessageSent.assertValues(["Typing"])
  }

  func testMoreButtonTapped() {
    self.notifyDelegateMoreButtonTapped.assertValueCount(0)

    self.vm.inputs.configureWith(chatHidden: false)
    self.vm.inputs.moreButtonTapped()

    self.notifyDelegateMoreButtonTapped.assertValueCount(1)
  }

  func testRequestLogin() {
    self.notifyDelegateRequestLogin.assertValueCount(0)

    self.vm.inputs.configureWith(chatHidden: false)
    let should1 = self.vm.inputs.textFieldShouldBeginEditing()

    XCTAssertFalse(should1)
    self.notifyDelegateRequestLogin.assertValueCount(1)

    AppEnvironment.login(AccessTokenEnvelope.init(accessToken: "deadbeef", user: User.template))

    let should2 = self.vm.inputs.textFieldShouldBeginEditing()

    XCTAssertTrue(should2)

    self.notifyDelegateRequestLogin.assertValueCount(1)
  }

  func testPlaceholderText() {
    self.placeholderText.assertValueCount(0)

    self.vm.inputs.configureWith(chatHidden: false)

    self.placeholderText.assertValues(["Say something kind..."])

    self.vm.inputs.didSetChatHidden(hidden: true)

    self.placeholderText.assertValues(["Say something kind...", "Chat is hidden."])

    self.vm.inputs.didSetChatHidden(hidden: false)

    self.placeholderText.assertValues(["Say something kind...", "Chat is hidden.", "Say something kind..."])
  }

  func testClearTextFieldAndResignFirstResponder() {
    self.clearTextFieldAndResignFirstResponder.assertValueCount(0)

    self.vm.inputs.configureWith(chatHidden: false)
    self.vm.inputs.textDidChange(toText: "Typing")
    self.vm.inputs.sendButtonTapped()

    self.clearTextFieldAndResignFirstResponder.assertValueCount(1)
  }
}
