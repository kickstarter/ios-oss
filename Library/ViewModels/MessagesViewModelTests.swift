// swiftlint:disable force_cast
import XCTest
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi
@testable import KsApi
import ReactiveSwift
import Result
import Prelude

internal final class MessagesViewModelTests: TestCase {
  fileprivate let vm: MessagesViewModelType = MessagesViewModel()

  fileprivate let backingAndProjectAndIsFromBacking = TestObserver<(Backing, Project, Bool), NoError>()
  fileprivate let emptyStateIsVisible = TestObserver<Bool, NoError>()
  fileprivate let emptyStateMessage = TestObserver<String, NoError>()
  fileprivate let goToBackingProject = TestObserver<Project, NoError>()
  fileprivate let goToBackingUser = TestObserver<User, NoError>()
  fileprivate let goToProject = TestObserver<Project, NoError>()
  fileprivate let goToRefTag = TestObserver<RefTag, NoError>()
  fileprivate let messages = TestObserver<[Message], NoError>()
  fileprivate let presentMessageDialog = TestObserver<MessageThread, NoError>()
  fileprivate let project = TestObserver<Project, NoError>()
  fileprivate let replyButtonIsEnabled = TestObserver<Bool, NoError>()
  fileprivate let successfullyMarkedAsRead = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backingAndProjectAndIsFromBacking.observe(self.backingAndProjectAndIsFromBacking.observer)
    self.vm.outputs.emptyStateIsVisibleAndMessageToUser.map { $0.0 }
      .observe(self.emptyStateIsVisible.observer)
    self.vm.outputs.emptyStateIsVisibleAndMessageToUser.map { $0.1 }.observe(self.emptyStateMessage.observer)
    self.vm.outputs.goToBacking.map(first).observe(self.goToBackingProject.observer)
    self.vm.outputs.goToBacking.map(second).observe(self.goToBackingUser.observer)
    self.vm.outputs.goToProject.map { $0.0 }.observe(self.goToProject.observer)
    self.vm.outputs.goToProject.map { $0.1 }.observe(self.goToRefTag.observer)
    self.vm.outputs.messages.observe(self.messages.observer)
    self.vm.outputs.presentMessageDialog.map { $0.0 }.observe(self.presentMessageDialog.observer)
    self.vm.outputs.project.observe(self.project.observer)
    self.vm.outputs.replyButtonIsEnabled.observe(self.replyButtonIsEnabled.observer)
    self.vm.outputs.successfullyMarkedAsRead.observe(self.successfullyMarkedAsRead.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
  }

  func testOutputs_ConfiguredWithThread() {
    let messageThread = MessageThread.template

    self.vm.inputs.configureWith(data: .left(messageThread))
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.project.assertValues([messageThread.project])
    self.backingAndProjectAndIsFromBacking.assertValueCount(1)
    self.messages.assertValueCount(1)

    XCTAssertEqual(["Message Thread View", "Viewed Message Thread"], self.trackingClient.events)
    XCTAssertEqual([true, nil],
                   self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
  }

  func testOutputs_ConfiguredWithThread_AndBacking() {
    let messageThread = MessageThread.template

    self.vm.inputs.configureWith(data: .left(messageThread))
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.project.assertValues([messageThread.project])
    self.backingAndProjectAndIsFromBacking.assertValueCount(1)
    self.messages.assertValueCount(1)

    XCTAssertEqual(["Message Thread View", "Viewed Message Thread"], self.trackingClient.events)
  }

  func testOutputs_ConfiguredWithProject() {
    let project = Project.template |> Project.lens.id .~ 42
    let backing = Backing.template

    let messageThread = .template
      |> MessageThread.lens.project .~ project
      |> MessageThread.lens.participant .~ .template

    let apiService = MockService(fetchMessageThreadResult: Result(value: messageThread))

    withEnvironment(apiService: apiService, currentUser: .template) {
      self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.project.assertValues([project])
      self.backingAndProjectAndIsFromBacking.assertValueCount(1)
      self.messages.assertValueCount(1)

      XCTAssertEqual(["Message Thread View", "Viewed Message Thread"], self.trackingClient.events)
    }
  }

  func testOutputs_ConfiguredWithProject_Error() {
    let project = Project.template |> Project.lens.id .~ 42
    let backing = Backing.template

    let errorUnknown = ErrorEnvelope(
      errorMessages: ["Something went wrong yo."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    let apiService = MockService(fetchMessageThreadResult: Result(error: errorUnknown))

    withEnvironment(apiService: apiService, currentUser: .template) {
      self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.project.assertValues([project])
      self.backingAndProjectAndIsFromBacking.assertValueCount(0)
      self.messages.assertValueCount(0)

      XCTAssertEqual(["Message Thread View", "Viewed Message Thread"], self.trackingClient.events)
    }
  }

  func testOutputs_ConfiguredWithProject_AndBacking() {
    let project = Project.template |> Project.lens.id .~ 42
    let backing = Backing.template
    let messageThread = .template
      |> MessageThread.lens.project .~ project
      |> MessageThread.lens.participant .~ .template

    let apiService = MockService(fetchMessageThreadResult: Result(value: messageThread))

    withEnvironment(apiService: apiService, currentUser: .template) {
      self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.project.assertValues([project])
      self.backingAndProjectAndIsFromBacking.assertValueCount(1)
      self.messages.assertValueCount(1)

      XCTAssertEqual(["Message Thread View", "Viewed Message Thread"], self.trackingClient.events)
    }
  }

  func testGoToProject() {
    let project = Project.template |> Project.lens.id .~ 42
    let backing = Backing.template

    self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.vm.inputs.projectBannerTapped()

    self.goToProject.assertValues([project])
    self.goToRefTag.assertValues([.messageThread])
  }

  func testGoToBacking_CurrentUserIsBacker() {
    let project = Project.template
      |> Project.lens.id .~ 42
      |> Project.lens.personalization.isBacking .~ true
    let backing = Backing.template
    let currentUser = User.template
      |> User.lens.id .~ 42
    let messageThread = .template
      |> MessageThread.lens.project .~ project
      |> MessageThread.lens.participant .~ .template

    let apiService = MockService(fetchMessageThreadResult: Result(value: messageThread))

    withEnvironment(apiService: apiService, currentUser: currentUser) {
      self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.goToBackingProject.assertDidNotEmitValue()
      self.goToBackingUser.assertDidNotEmitValue()

      self.vm.inputs.backingInfoPressed()

      self.goToBackingProject.assertValues([project])
      self.goToBackingUser.assertValues([currentUser])
    }
  }

  func testGoToBacking_CurrentUserIsNotBacker() {
    let project = Project.template
      |> Project.lens.id .~ 42
    let backing = Backing.template
    let currentUser = User.template
      |> User.lens.id .~ 42
    let messageThread = .template
      |> MessageThread.lens.project .~ project
      |> MessageThread.lens.participant .~ .template

    let apiService = MockService(fetchMessageThreadResult: Result(value: messageThread))

    withEnvironment(apiService: apiService, currentUser: currentUser) {
      self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.goToBackingProject.assertDidNotEmitValue()
      self.goToBackingUser.assertDidNotEmitValue()

      self.vm.inputs.backingInfoPressed()

      self.goToBackingProject.assertValues([project])
      self.goToBackingUser.assertValues([messageThread.participant])
    }
  }

  func testReplyFlow() {
    let project = Project.template |> Project.lens.id .~ 42
    let backing = Backing.template
    let messageThread = .template
      |> MessageThread.lens.project .~ project
      |> MessageThread.lens.participant .~ .template

    let apiService = MockService(fetchMessageThreadResult: Result(value: messageThread))

    withEnvironment(apiService: apiService, currentUser: .template) {
      self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))

      self.replyButtonIsEnabled.assertValueCount(0)
      self.emptyStateIsVisible.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.messages.assertValueCount(0)
      self.replyButtonIsEnabled.assertValues([false])
      self.emptyStateIsVisible.assertValues([false])

      self.scheduler.advance()

      self.messages.assertValueCount(1)
      self.replyButtonIsEnabled.assertValues([false, true])
      self.emptyStateIsVisible.assertValues([false], "Empty state does not emit again.")

      self.vm.inputs.replyButtonPressed()

      self.presentMessageDialog.assertValueCount(1)

      self.vm.inputs.messageSent(Message.template)

      self.scheduler.advance()

      self.messages.assertValueCount(2)
    }
  }

  func testMarkAsRead() {
    self.vm.inputs.configureWith(data: .left(MessageThread.template))
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.successfullyMarkedAsRead.assertValueCount(1)
  }

  func testEmptyStateIsVisibleAndMessage_CurrentUserIsBacker() {
    let project = .template
      |> Project.lens.id .~ 42
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.creator..User.lens.id .~ 20
    let backing = .template
      |> Backing.lens.backer .~ .template

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))

      self.emptyStateIsVisible.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.emptyStateIsVisible.assertValues([false])
      self.emptyStateMessage.assertValues([""])

      self.scheduler.advance()

      self.emptyStateIsVisible.assertValues([false, true])
      self.emptyStateMessage.assertValues(["", Strings.messages_empty_state_message_backer()])
    }
  }

  func testEmptyStateIsVisibleAndMessage_CurrentUserIsCreator() {
    let creator = .template |> User.lens.id .~ 20
    let project = .template
      |> Project.lens.id .~ 42
      |> Project.lens.creator .~ creator
      |> Project.lens.memberData.permissions .~ [.post, .viewPledges, .comment]

    withEnvironment(currentUser: creator) {
      self.vm.inputs.configureWith(data: .right((project: project, backing: .template)))

      self.emptyStateIsVisible.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.emptyStateIsVisible.assertValues([false])
      self.emptyStateMessage.assertValues([""])

      self.scheduler.advance()

      self.emptyStateIsVisible.assertValues([false, true])
      self.emptyStateMessage.assertValues(["", Strings.messages_empty_state_message_creator()])
    }
  }

  func testEmptyStateIsVisibleAndMessage_CurrentUserIsCollaboratorAndBacker() {
    let collaborator = .template |> User.lens.id .~ 20
    let project = .template
      |> Project.lens.creator..User.lens.id .~ 40
      |> Project.lens.memberData.permissions .~ [.viewPledges]
    let backing = .template
      |> Backing.lens.backer .~ collaborator

    withEnvironment(currentUser: collaborator) {
      self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))

      self.emptyStateIsVisible.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.emptyStateIsVisible.assertValues([false])
      self.emptyStateMessage.assertValues([""])

      self.scheduler.advance()

      self.emptyStateIsVisible.assertValues([false, true])
      self.emptyStateMessage.assertValues(["", Strings.messages_empty_state_message_backer()])
    }
  }
}
