import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamChatInputViewModelTests: TestCase {
  let vm: LiveStreamChatInputViewModelType = LiveStreamChatInputViewModel()

  let moreButtonHidden = TestObserver<Bool, NoError>()
  let notifyDelegateMessageSent = TestObserver<String, NoError>()
  let notifyDelegateMoreButtonTapped = TestObserver<(), NoError>()
  let notifyDelegateRequestLogin = TestObserver<(), NoError>()
  let sendButtonHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.moreButtonHidden.observe(self.moreButtonHidden.observer)
    self.vm.outputs.notifyDelegateMessageSent.observe(self.notifyDelegateMessageSent.observer)
    self.vm.outputs.notifyDelegateMoreButtonTapped.observe(self.notifyDelegateMoreButtonTapped.observer)
    self.vm.outputs.notifyDelegateRequestLogin.observe(self.notifyDelegateRequestLogin.observer)
    self.vm.outputs.sendButtonHidden.observe(self.sendButtonHidden.observer)
  }

  func testButtonsShowingHiding() {
    self.moreButtonHidden.assertValueCount(0)
    self.sendButtonHidden.assertValueCount(0)

    self.vm.inputs.layoutSubviews()

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

    self.vm.inputs.layoutSubviews()
    self.vm.inputs.textDidChange(toText: "Typing")
    self.vm.inputs.sendButtonTapped()

    self.notifyDelegateMessageSent.assertValues(["Typing"])
  }

  func testMoreButtonTapped() {
    self.notifyDelegateMoreButtonTapped.assertValueCount(0)

    self.vm.inputs.layoutSubviews()
    self.vm.inputs.moreButtonTapped()

    self.notifyDelegateMoreButtonTapped.assertValueCount(1)
  }

  func testRequestLogin() {
    self.notifyDelegateRequestLogin.assertValueCount(0)

    self.vm.inputs.layoutSubviews()
    self.vm.inputs.textFieldShouldBeginEditing()

    self.notifyDelegateRequestLogin.assertValueCount(1)

    AppEnvironment.login(AccessTokenEnvelope.init(accessToken: "deadbeef", user: User.template))

    self.vm.inputs.textFieldShouldBeginEditing()

    self.notifyDelegateRequestLogin.assertValueCount(1)
  }
}
