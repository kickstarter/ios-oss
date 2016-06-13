import Library
@testable import ReactiveExtensions_TestHelpers
import ReactiveCocoa
import Result
@testable import KsApi
@testable import KsApi_TestHelpers

final class MessageThreadCellViewModelTests: TestCase {
  private let vm: MessageThreadCellViewModelType = MessageThreadCellViewModel()

  private let date = TestObserver<String, NoError>()
  private let messageBody = TestObserver<String, NoError>()
  private let participantAvatarURL = TestObserver<NSURL?, NoError>()
  private let participantName = TestObserver<String, NoError>()
  private let projectName = TestObserver<String, NoError>()
  private let replyIndicatorHidden = TestObserver<Bool, NoError>()
  private let unreadIndicatorHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.date.observe(self.date.observer)
    self.vm.outputs.messageBody.observe(self.messageBody.observer)
    self.vm.outputs.participantAvatarURL.observe(self.participantAvatarURL.observer)
    self.vm.outputs.participantName.observe(self.participantName.observer)
    self.vm.outputs.projectName.observe(self.projectName.observer)
    self.vm.outputs.replyIndicatorHidden.observe(self.replyIndicatorHidden.observer)
    self.vm.outputs.unreadIndicatorHidden.observe(self.unreadIndicatorHidden.observer)
  }

  func testOutputs() {
    let thread = MessageThread.template
    self.vm.inputs.configureWith(messageThread: thread)

    self.date.assertValueCount(1)
    self.messageBody.assertValues([thread.lastMessage.body])
    self.participantAvatarURL.assertValueCount(1)
    self.participantName.assertValues([thread.participant.name])
    self.projectName.assertValues([thread.project.name])
    self.unreadIndicatorHidden.assertValues([false])
  }

  func testReplyIndicatorHidden() {
    let thread = MessageThread.template

    self.vm.inputs.configureWith(messageThread: thread)
    self.replyIndicatorHidden.assertValues([true])

    withEnvironment(currentUser: thread.lastMessage.sender) {
      self.vm.inputs.configureWith(messageThread: thread)
      self.replyIndicatorHidden.assertValues([true, false])
    }
  }
}
