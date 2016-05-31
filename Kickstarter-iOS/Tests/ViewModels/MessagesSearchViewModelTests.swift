import XCTest
@testable import Library
@testable import Kickstarter_iOS
@testable import ReactiveExtensions_TestHelpers
@testable import Models_TestHelpers
@testable import KsApi_TestHelpers
import Models
import ReactiveCocoa
import Result
import Prelude

internal final class MessagesSearchViewModelTests: TestCase {
  private let vm: MessagesSearchViewModelType = MessagesSearchViewModel()

  private let emptyStateIsVisible = TestObserver<Bool, NoError>()
  private let isSearching = TestObserver<Bool, NoError>()
  private let hasMessageThreads = TestObserver<Bool, NoError>()
  private let showKeyboard = TestObserver<Bool, NoError>()
  private let goToMessageThread = TestObserver<MessageThread, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.emptyStateIsVisible.observe(self.emptyStateIsVisible.observer)
    self.vm.outputs.isSearching.observe(self.isSearching.observer)
    self.vm.outputs.messageThreads.map { !$0.isEmpty }.observe(self.hasMessageThreads.observer)
    self.vm.outputs.showKeyboard.observe(self.showKeyboard.observer)
    self.vm.outputs.goToMessageThread.observe(self.goToMessageThread.observer)
  }

  func testKeyboard() {
    self.showKeyboard.assertValues([])

    self.vm.inputs.configureWith(project: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.showKeyboard.assertValues([true])

    self.vm.inputs.viewWillDisappear()

    self.showKeyboard.assertValues([true, false])
  }

  func testSearch_NoProject() {
    self.vm.inputs.configureWith(project: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.hasMessageThreads.assertValues([])
    self.isSearching.assertValues([false])

    self.vm.inputs.searchTextChanged("hello")

    self.hasMessageThreads.assertValues([])
    self.isSearching.assertValues([false, true])
    XCTAssertEqual([], self.trackingClient.events)

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true])
    self.isSearching.assertValues([false, true, false])
    XCTAssertEqual(["Message Threads Search", "Message Inbox Search"], self.trackingClient.events)
    XCTAssertEqual([nil, true], self.trackingClient.properties.map { $0["DEPRECATED"] as! Bool? })
    XCTAssertEqual([nil, nil], self.trackingClient.properties.map { $0["project_pid"] as! Int? })

    self.vm.inputs.searchTextChanged("hello world")

    self.hasMessageThreads.assertValues([true, false])
    self.isSearching.assertValues([false, true, false, true])
    XCTAssertEqual(["Message Threads Search", "Message Inbox Search"], self.trackingClient.events)

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true, false, true])
    self.isSearching.assertValues([false, true, false, true, false])
    XCTAssertEqual(
      ["Message Threads Search", "Message Inbox Search", "Message Threads Search", "Message Inbox Search"],
      self.trackingClient.events)
    XCTAssertEqual([nil, true, nil, true], self.trackingClient.properties.map { $0["DEPRECATED"] as! Bool? })
    XCTAssertEqual([nil, nil, nil, nil], self.trackingClient.properties.map { $0["project_pid"] as! Int? })

    self.vm.inputs.searchTextChanged("")
    self.vm.inputs.searchTextChanged(nil)

    self.hasMessageThreads.assertValues([true, false, true, false])
    self.isSearching.assertValues([false, true, false, true, false])
    XCTAssertEqual(
      ["Message Threads Search", "Message Inbox Search", "Message Threads Search", "Message Inbox Search"],
      self.trackingClient.events)

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true, false, true, false])
    self.isSearching.assertValues([false, true, false, true, false])
    XCTAssertEqual(
      ["Message Threads Search", "Message Inbox Search", "Message Threads Search", "Message Inbox Search"],
      self.trackingClient.events)
  }

  func testSearch_WithProject() {
    let project = Project.template |> Project.lens.id *~ 123

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.hasMessageThreads.assertValues([])

    self.vm.inputs.searchTextChanged("hello")

    self.hasMessageThreads.assertValues([])
    XCTAssertEqual([], self.trackingClient.events)

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true])
    XCTAssertEqual(["Message Threads Search", "Message Inbox Search"], self.trackingClient.events)
    XCTAssertEqual([nil, true], self.trackingClient.properties.map { $0["DEPRECATED"] as! Bool? })
    XCTAssertEqual([project.id, project.id],
                   self.trackingClient.properties.map { $0["project_pid"] as! Int? })

    self.vm.inputs.searchTextChanged("hello world")

    self.hasMessageThreads.assertValues([true, false])
    XCTAssertEqual(["Message Threads Search", "Message Inbox Search"], self.trackingClient.events)

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true, false, true])
    XCTAssertEqual(
      ["Message Threads Search", "Message Inbox Search", "Message Threads Search", "Message Inbox Search"],
      self.trackingClient.events)
    XCTAssertEqual([nil, true, nil, true], self.trackingClient.properties.map { $0["DEPRECATED"] as! Bool? })
    XCTAssertEqual([project.id, project.id, project.id, project.id],
                   self.trackingClient.properties.map { $0["project_pid"] as! Int? })

    self.vm.inputs.searchTextChanged("")

    self.hasMessageThreads.assertValues([true, false, true, false])
    XCTAssertEqual(
      ["Message Threads Search", "Message Inbox Search", "Message Threads Search", "Message Inbox Search"],
      self.trackingClient.events)

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true, false, true, false])
    XCTAssertEqual(
      ["Message Threads Search", "Message Inbox Search", "Message Threads Search", "Message Inbox Search"],
      self.trackingClient.events)
  }

  func testGoToMessageThread() {
    let project = Project.template |> Project.lens.id *~ 123
    let messageThread = MessageThread.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.vm.inputs.tappedMessageThread(messageThread)

    self.goToMessageThread.assertValues([messageThread])
  }
}
