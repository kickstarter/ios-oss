import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamChatMessageCellViewModelTests: TestCase {
  let vm: LiveStreamChatMessageCellViewModelType = LiveStreamChatMessageCellViewModel()

  let avatarImageUrl = TestObserver<String, NoError>()
  let creatorViewsHidden = TestObserver<Bool, NoError>()
  let message = TestObserver<String, NoError>()
  let senderName = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.avatarImageUrl.map { $0?.absoluteString }.skipNil().observe(self.avatarImageUrl.observer)
    self.vm.outputs.creatorViewsHidden.observe(self.creatorViewsHidden.observer)
    self.vm.outputs.message.observe(self.message.observer)
    self.vm.outputs.name.observe(self.senderName.observer)
  }

  func testAvatarImageUrl() {
    let chatMessage = .template
      |> LiveStreamChatMessage.lens.profilePictureUrl .~ "http://www.kickstarter.com/avatar.jpg"

    self.avatarImageUrl.assertValueCount(0)

    self.vm.inputs.configureWith(chatMessage: chatMessage)

    self.avatarImageUrl.assertValues(["http://www.kickstarter.com/avatar.jpg"])
  }

  func testCreatorViewsHidden_Unknown() {
    let chatMessage = .template
      |> LiveStreamChatMessage.lens.isCreator .~ nil

    self.creatorViewsHidden.assertValueCount(0)

    self.vm.inputs.configureWith(chatMessage: chatMessage)

    self.creatorViewsHidden.assertValues([true])
  }

  func testCreatorViewsHidden() {
    let chatMessage = .template
      |> LiveStreamChatMessage.lens.isCreator .~ false

    self.creatorViewsHidden.assertValueCount(0)

    self.vm.inputs.configureWith(chatMessage: chatMessage)

    self.creatorViewsHidden.assertValues([true])
  }

  func testCreatorViewsShown() {
    let chatMessage = .template
      |> LiveStreamChatMessage.lens.isCreator .~ true

    self.creatorViewsHidden.assertValueCount(0)

    self.vm.inputs.configureWith(chatMessage: chatMessage)

    self.creatorViewsHidden.assertValues([false])
  }

  func testMessage() {
    let chatMessage = .template
      |> LiveStreamChatMessage.lens.message .~ "Test Message"

    self.senderName.assertValueCount(0)

    self.vm.inputs.configureWith(chatMessage: chatMessage)

    self.message.assertValues(["Test Message"])
  }

  func testSenderName() {
    let chatMessage = .template
      |> LiveStreamChatMessage.lens.name .~ "Test Sender Name"

    self.senderName.assertValueCount(0)

    self.vm.inputs.configureWith(chatMessage: chatMessage)

    self.senderName.assertValues(["Test Sender Name"])
  }
}
