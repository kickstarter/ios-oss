import XCTest
@testable import Library
@testable import Kickstarter_iOS
@testable import ReactiveExtensions_TestHelpers
@testable import Models_TestHelpers
import ReactiveCocoa
import Result
import Models

internal final class MessageDialogViewModelTests: TestCase {
  private let vm: MessageDialogViewModelType = MessageDialogViewModel()

  private let loadingViewIsHidden = TestObserver<Bool, NoError>()
  private let postButtonEnabled = TestObserver<Bool, NoError>()
  private let notifyPresenterCommentWasPostedSuccesfully = TestObserver<Message, NoError>()
  private let notifyPresenterDialogWantsDismissal = TestObserver<(), NoError>()
  private let recipientName = TestObserver<String, NoError>()
  private let keyboardIsVisible = TestObserver<Bool, NoError>()
  private let showAlertMessage = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadingViewIsHidden.observe(self.loadingViewIsHidden.observer)
    self.vm.outputs.postButtonEnabled.observe(self.postButtonEnabled.observer)
    self.vm.outputs.notifyPresenterCommentWasPostedSuccesfully
      .observe(self.notifyPresenterCommentWasPostedSuccesfully.observer)
    self.vm.outputs.notifyPresenterDialogWantsDismissal
      .observe(self.notifyPresenterDialogWantsDismissal.observer)
    self.vm.outputs.recipientName.observe(self.recipientName.observer)
    self.vm.outputs.keyboardIsVisible.observe(self.keyboardIsVisible.observer)
    self.vm.outputs.showAlertMessage.observe(self.showAlertMessage.observer)
  }

  func testRecipientName() {
    let thread = MessageThreadFactory.messageThread()
    self.vm.inputs.configureWith(messageThread: thread, context: .messages)
    self.vm.inputs.viewDidLoad()

    self.recipientName.assertValues([thread.participant.name])
  }

  func testButtonEnabled() {
    self.vm.inputs.viewDidLoad()
    self.postButtonEnabled.assertValues([false])

    self.vm.inputs.bodyTextChanged("hello")
    self.postButtonEnabled.assertValues([false, true])

    self.vm.inputs.bodyTextChanged("hello world")
    self.postButtonEnabled.assertValues([false, true])

    self.vm.inputs.bodyTextChanged("")
    self.postButtonEnabled.assertValues([false, true, false])

    self.vm.inputs.bodyTextChanged("  ")
    self.postButtonEnabled.assertValues([false, true, false])

    self.vm.inputs.bodyTextChanged("hello world")
    self.postButtonEnabled.assertValues([false, true, false, true])
  }

  func testKeyboardIsVisible() {
    self.vm.inputs.configureWith(messageThread: MessageThreadFactory.messageThread(), context: .messages)
    self.vm.inputs.viewDidLoad()
    self.keyboardIsVisible.assertValues([true])

    self.vm.inputs.cancelButtonPressed()
    self.keyboardIsVisible.assertValues([true, false])

    self.vm.inputs.viewDidLoad()
    self.keyboardIsVisible.assertValues([true, false, true])

    self.vm.inputs.bodyTextChanged("HELLO")
    self.vm.inputs.postButtonPressed()
    self.scheduler.advance()
    self.keyboardIsVisible.assertValues([true, false, true, false])
  }

  func testPostingMessage() {
    self.vm.inputs.configureWith(messageThread: MessageThreadFactory.messageThread(), context: .messages)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.bodyTextChanged("HELLO")

    self.loadingViewIsHidden.assertValues([true])
    self.notifyPresenterCommentWasPostedSuccesfully.assertValueCount(0)
    self.notifyPresenterDialogWantsDismissal.assertValueCount(0)

    self.vm.inputs.postButtonPressed()

    self.loadingViewIsHidden.assertValues([true, false])
    self.notifyPresenterCommentWasPostedSuccesfully.assertValueCount(0)
    self.notifyPresenterDialogWantsDismissal.assertValueCount(0)

    self.scheduler.advance()

    self.loadingViewIsHidden.assertValues([true, false, true])
    self.notifyPresenterCommentWasPostedSuccesfully.assertValueCount(1)
    self.notifyPresenterDialogWantsDismissal.assertValueCount(1)

    XCTAssertEqual(["Message Sent"], self.trackingClient.events)
  }
}
