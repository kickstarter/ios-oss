import Library
@testable import ReactiveExtensions_TestHelpers
import ReactiveSwift
import Result
@testable import KsApi

final class MessageThreadCellViewModelTests: TestCase {
  fileprivate let vm: MessageThreadCellViewModelType = MessageThreadCellViewModel()

  fileprivate let date = TestObserver<String, NoError>()
  fileprivate let dateAccessibilityLabel = TestObserver<String, NoError>()
  fileprivate let messageBody = TestObserver<String, NoError>()
  fileprivate let participantAvatarURL = TestObserver<URL?, NoError>()
  fileprivate let participantName = TestObserver<String, NoError>()
  fileprivate let projectName = TestObserver<String, NoError>()
  fileprivate let replyIndicatorHidden = TestObserver<Bool, NoError>()
  fileprivate let unreadIndicatorHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.date.observe(self.date.observer)
    self.vm.outputs.dateAccessibilityLabel.observe(self.dateAccessibilityLabel.observer)
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
    self.dateAccessibilityLabel.assertValueCount(1)
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

  func testUnreadIndicatorHidden() {
    let thread = MessageThread.template

    self.vm.inputs.configureWith(messageThread: thread)

    self.vm.inputs.setSelected(false)
    self.unreadIndicatorHidden.assertValues([false])

    self.vm.inputs.setSelected(true)
    self.unreadIndicatorHidden.assertValues([false, true])
  }
}
