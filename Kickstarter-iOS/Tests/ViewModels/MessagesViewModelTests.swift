import XCTest
@testable import Library
@testable import Kickstarter_iOS
@testable import ReactiveExtensions_TestHelpers
@testable import Models
@testable import KsApi
@testable import Models_TestHelpers
import ReactiveCocoa
import Result
import Prelude

internal final class MessagesViewModelTests: TestCase {
  private let vm: MessagesViewModelType = MessagesViewModel()

  private let backingAndProject = TestObserver<(Backing, Project), NoError>()
  private let goToBacking = TestObserver<Backing, NoError>()
  private let goToProject = TestObserver<Project, NoError>()
  private let goToRefTag = TestObserver<RefTag, NoError>()
  private let messages = TestObserver<[Message], NoError>()
  private let presentMessageDialog = TestObserver<MessageThread, NoError>()
  private let project = TestObserver<Project, NoError>()
  private let successfullyMarkedAsRead = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backingAndProject.observe(self.backingAndProject.observer)
    self.vm.outputs.goToBacking.map { $0.0 }.observe(self.goToBacking.observer)
    self.vm.outputs.goToProject.map { $0.0 }.observe(self.goToProject.observer)
    self.vm.outputs.goToProject.map { $0.1 }.observe(self.goToRefTag.observer)
    self.vm.outputs.messages.observe(self.messages.observer)
    self.vm.outputs.presentMessageDialog.map { $0.0 }.observe(self.presentMessageDialog.observer)
    self.vm.outputs.project.observe(self.project.observer)
    self.vm.outputs.successfullyMarkedAsRead.observe(self.successfullyMarkedAsRead.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
  }

  func testOutputs_ConfiguredWithThread() {
    let messageThread = MessageThread.template

    self.vm.inputs.configureWith(data: .left(messageThread))
    self.vm.inputs.viewDidLoad()

    self.project.assertValues([messageThread.project])
    self.backingAndProject.assertValueCount(1)
    self.messages.assertValueCount(1)

    XCTAssertEqual(["Message Thread View"], self.trackingClient.events)
  }

  func testOutputs_ConfiguredWithThread_AndBacking() {
    let messageThread = MessageThread.template

    self.vm.inputs.configureWith(data: .left(messageThread))
    self.vm.inputs.viewDidLoad()

    self.project.assertValues([messageThread.project])
    self.backingAndProject.assertValueCount(1)
    self.messages.assertValueCount(1)

    XCTAssertEqual(["Message Thread View"], self.trackingClient.events)
  }

  func testOutputs_ConfiguredWithProject() {
    let project = Project.template |> Project.lens.id *~ 42
    let backing = Backing.template

    self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))
    self.vm.inputs.viewDidLoad()

    self.project.assertValues([project])
    self.backingAndProject.assertValueCount(1)
    self.messages.assertValueCount(1)

    XCTAssertEqual(["Message Thread View"], self.trackingClient.events)
  }

  func testOutputs_ConfiguredWithProject_AndBacking() {
    let project = Project.template |> Project.lens.id *~ 42
    let backing = Backing.template

    self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))
    self.vm.inputs.viewDidLoad()

    self.project.assertValues([project])
    self.backingAndProject.assertValueCount(1)
    self.messages.assertValueCount(1)

    XCTAssertEqual(["Message Thread View"], self.trackingClient.events)
  }

  func testGoToProject() {
    let project = Project.template |> Project.lens.id *~ 42
    let backing = Backing.template

    self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.projectBannerTapped()

    self.goToProject.assertValues([project])
    self.goToRefTag.assertValues([.messageThread])
  }

  func testGoToBacking() {
    let project = Project.template |> Project.lens.id *~ 42
    let backing = Backing.template

    self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.backingInfoPressed()

    self.goToBacking.assertValues([backing])
  }

  func testReplyFlow() {
    let project = Project.template |> Project.lens.id *~ 42
    let backing = Backing.template

    self.vm.inputs.configureWith(data: .right((project: project, backing: backing)))
    self.vm.inputs.viewDidLoad()

    self.messages.assertValueCount(1)

    self.vm.inputs.replyButtonPressed()

    self.presentMessageDialog.assertValueCount(1)

    self.vm.inputs.messageSent(Message.template)

    self.messages.assertValueCount(2)
  }

  func testMarkAsRead() {
    self.vm.inputs.configureWith(data: .left(MessageThread.template))
    self.vm.inputs.viewDidLoad()

    self.successfullyMarkedAsRead.assertValueCount(1)
  }
}
