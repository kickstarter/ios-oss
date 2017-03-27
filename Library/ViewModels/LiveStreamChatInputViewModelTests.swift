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
  private let notifyDelegateMessageSent = TestObserver<String, NoError>()
  private let notifyDelegateRequestLogin = TestObserver<(), NoError>()
  private let placeholderText = TestObserver<String, NoError>()
  private let sendButtonEnabled = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.clearTextFieldAndResignFirstResponder.observe(
      self.clearTextFieldAndResignFirstResponder.observer)
    self.vm.outputs.notifyDelegateMessageSent.observe(self.notifyDelegateMessageSent.observer)
    self.vm.outputs.notifyDelegateRequestLogin.observe(self.notifyDelegateRequestLogin.observer)
    self.vm.outputs.placeholderText.map { $0.string }.observe(self.placeholderText.observer)
    self.vm.outputs.sendButtonEnabled.observe(self.sendButtonEnabled.observer)
  }

  func testSendButtonEnabled() {
    self.sendButtonEnabled.assertValueCount(0)

    self.vm.inputs.didAwakeFromNib()

    self.sendButtonEnabled.assertValues([false])

    self.vm.inputs.textDidChange(toText: "Typing")

    self.sendButtonEnabled.assertValues([false, true])

    self.vm.inputs.textDidChange(toText: "    ")

    self.sendButtonEnabled.assertValues([false, true, false])

    self.vm.inputs.textDidChange(toText: "")

    self.sendButtonEnabled.assertValues([false, true, false, false])

    self.vm.inputs.textDidChange(toText: "Typing")

    self.sendButtonEnabled.assertValues([false, true, false, false, true])

    self.vm.inputs.sendButtonTapped()

    self.sendButtonEnabled.assertValues([false, true, false, false, true, false])
  }

  func testMessageSent() {
    self.notifyDelegateMessageSent.assertValueCount(0)

    self.vm.inputs.didAwakeFromNib()

    self.vm.inputs.textDidChange(toText: "Typing")
    self.vm.inputs.sendButtonTapped()

    self.notifyDelegateMessageSent.assertValues(["Typing"])
  }

  func testRequestLogin() {
    self.notifyDelegateRequestLogin.assertValueCount(0)

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

    self.vm.inputs.didAwakeFromNib()

    self.placeholderText.assertValues(["Say something kind..."])
  }

  func testClearTextFieldAndResignFirstResponder() {
    self.clearTextFieldAndResignFirstResponder.assertValueCount(0)

    self.vm.inputs.didAwakeFromNib()

    self.vm.inputs.textDidChange(toText: "Typing")
    self.vm.inputs.sendButtonTapped()

    self.clearTextFieldAndResignFirstResponder.assertValueCount(1)
  }
}
