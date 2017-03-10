import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class MessagesThreadViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {

    let backer = .template
      |> User.lens.avatar.large .~ ""
      |> User.lens.avatar.medium .~ ""
      |> User.lens.avatar.small .~ ""

    let creator = .template
      |> User.lens.name .~ "Native Squad"

    let anotherCreator = .template
      |> User.lens.name .~ "Bob"

    let project = .template
      |> Project.lens.creator .~ creator

    let message = .template
      |> Message.lens.body .~ "Hello there. Thanks for backing!"
      |> Message.lens.recipient .~ backer

    let messageRead = .template
      |> Message.lens.body .~ "Hi there. Thanks for backing this project!"
      |> Message.lens.recipient .~ backer

    let message1 =  .template
      |> MessageThread.lens.participant .~ creator
      |> MessageThread.lens.lastMessage .~ message

    let message2 =  .template
      |> MessageThread.lens.participant .~ anotherCreator
      |> MessageThread.lens.lastMessage .~ messageRead
      |> MessageThread.lens.unreadMessagesCount .~ 0

    let messageThreads = [message1, message2]

    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchMessageThreadsResponse: messageThreads
      ),
      currentUser: backer,
      mainBundle: Bundle.framework
    )

    Language.allLanguages.forEach { language in
        withEnvironment(language: language) {
          let controller = MessageThreadsViewController.configuredWith(project: project)

          let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
          parent.view.frame.size.height = 600

          self.scheduler.run()

          FBSnapshotVerifyView(parent.view, identifier: "MessagesThread - lang_\(language)")
        }
      }

    AppEnvironment.popEnvironment()
  }
}
