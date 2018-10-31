import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class MessageThreadViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {
    let project = Project.template

    let backer = User.template
      |> \.avatar.large .~ ""
      |> \.avatar.medium .~ ""
      |> \.avatar.small .~ ""

    let nativeSquadTheCreator = User.template
      |> \.name .~ "Native Squad"

    let bobTheCreator = User.template
      |> \.name .~ "Bob"

    let unreadMessage = .template
      |> Message.lens.body .~ "Hello there. You have not read this message."
      |> Message.lens.recipient .~ backer

    let readMessage = .template
      |> Message.lens.body .~ "Hi there. You read this message."
      |> Message.lens.recipient .~ backer

    let repliedToMessage = .template
      |> Message.lens.body .~ "Hey there. You replied to this message."
      |> Message.lens.sender .~ backer

    let unreadMessageThread =  .template
      |> MessageThread.lens.participant .~ nativeSquadTheCreator
      |> MessageThread.lens.lastMessage .~ unreadMessage

    let readMessageThread =  .template
      |> MessageThread.lens.participant .~ bobTheCreator
      |> MessageThread.lens.lastMessage .~ readMessage
      |> MessageThread.lens.unreadMessagesCount .~ 0

    let repliedMessageThread = .template
      |> MessageThread.lens.lastMessage .~ repliedToMessage
      |> MessageThread.lens.unreadMessagesCount .~ 0

    let messageThreads = [unreadMessageThread, readMessageThread, repliedMessageThread]

    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchMessageThreadsResponse: messageThreads
      ),
      currentUser: backer,
      mainBundle: Bundle.framework
    )

    [Device.phone4_7inch, Device.phone5_8inch, Device.pad].forEach { device in

      let controller = MessageThreadsViewController.configuredWith(project: project, refTag: nil)

      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

      self.scheduler.run()

      FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
    }

    AppEnvironment.popEnvironment()
  }
}
