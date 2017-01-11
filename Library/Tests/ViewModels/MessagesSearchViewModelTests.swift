import XCTest
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi
import KsApi
import ReactiveSwift
import Result
import Prelude

internal final class MessagesSearchViewModelTests: TestCase {
  fileprivate let vm: MessagesSearchViewModelType = MessagesSearchViewModel()

  fileprivate let emptyStateIsVisible = TestObserver<Bool, NoError>()
  fileprivate let isSearching = TestObserver<Bool, NoError>()
  fileprivate let hasMessageThreads = TestObserver<Bool, NoError>()
  fileprivate let showKeyboard = TestObserver<Bool, NoError>()
  fileprivate let goToMessageThread = TestObserver<MessageThread, NoError>()

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

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Message Search"], self.trackingClient.events)

    self.vm.inputs.viewWillAppear()

    self.hasMessageThreads.assertValues([])
    self.isSearching.assertValues([false])

    self.vm.inputs.searchTextChanged("hello")

    self.hasMessageThreads.assertValues([])
    self.isSearching.assertValues([false, true])
    XCTAssertEqual(["Viewed Message Search"], self.trackingClient.events)

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true])
    self.isSearching.assertValues([false, true, false])
    XCTAssertEqual(
      [
        "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results"
      ],
      self.trackingClient.events)
    XCTAssertEqual([nil, true, true, nil],
                   self.trackingClient.properties.map { $0[Koala.DeprecatedKey] as! Bool? })
    XCTAssertEqual([nil, nil, nil, nil], self.trackingClient.properties.map { $0["project_pid"] as! Int? })
    XCTAssertEqual([nil, nil, nil, true], self.trackingClient.properties.map { $0["has_results"] as! Bool? })

    withEnvironment(apiService: MockService(fetchMessageThreadsResponse: [])) {
      self.vm.inputs.searchTextChanged("hello world")

      self.hasMessageThreads.assertValues([true, false])
      self.isSearching.assertValues([false, true, false, true])
      XCTAssertEqual(
        [
          "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
          "Viewed Message Search Results"
        ],
        self.trackingClient.events)

      self.scheduler.advance()

      self.hasMessageThreads.assertValues([true, false])
      self.isSearching.assertValues([false, true, false, true, false])
      XCTAssertEqual(
        [
          "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
          "Viewed Message Search Results", "Message Threads Search", "Message Inbox Search",
          "Viewed Message Search Results"
        ],
        self.trackingClient.events)
      XCTAssertEqual([nil, true, true, nil, true, true, nil],
        self.trackingClient.properties.map { $0[Koala.DeprecatedKey] as! Bool? })
      XCTAssertEqual([nil, nil, nil, nil, nil, nil, nil],
        self.trackingClient.properties.map { $0["project_pid"] as! Int? })
      XCTAssertEqual([nil, nil, nil, true, nil, nil, false],
        self.trackingClient.properties.map { $0["has_results"] as! Bool? })

      self.vm.inputs.searchTextChanged("")
      self.vm.inputs.searchTextChanged(nil)

      self.hasMessageThreads.assertValues([true, false])
      self.isSearching.assertValues([false, true, false, true, false])
      XCTAssertEqual(
        [
          "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
          "Viewed Message Search Results", "Message Threads Search", "Message Inbox Search",
          "Viewed Message Search Results"
        ],
        self.trackingClient.events)

      self.scheduler.advance()

      self.hasMessageThreads.assertValues([true, false])
      self.isSearching.assertValues([false, true, false, true, false])
      XCTAssertEqual(
        [
          "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
          "Viewed Message Search Results", "Message Threads Search", "Message Inbox Search",
          "Viewed Message Search Results"
        ],
        self.trackingClient.events)
    }
  }

  func testSearch_WithProject() {
    let project = Project.template |> Project.lens.id .~ 123

    self.vm.inputs.configureWith(project: project)

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Message Search"], self.trackingClient.events)

    self.vm.inputs.viewWillAppear()

    self.hasMessageThreads.assertValues([])

    self.vm.inputs.searchTextChanged("hello")

    self.hasMessageThreads.assertValues([])
    XCTAssertEqual(["Viewed Message Search"], self.trackingClient.events)

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true])
    XCTAssertEqual(
      [
        "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results"
      ],
      self.trackingClient.events)
    XCTAssertEqual([nil, true, true, nil],
                   self.trackingClient.properties.map { $0[Koala.DeprecatedKey] as! Bool? })
    XCTAssertEqual([project.id, project.id, project.id, project.id],
                   self.trackingClient.properties.map { $0["project_pid"] as! Int? })

    self.vm.inputs.searchTextChanged("hello world")

    self.hasMessageThreads.assertValues([true, false])
    XCTAssertEqual(
      [
        "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results"
      ],
      self.trackingClient.events)

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true, false, true])
    XCTAssertEqual(
      [
        "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results"
      ],
      self.trackingClient.events)
    XCTAssertEqual([nil, true, true, nil, true, true, nil],
                   self.trackingClient.properties.map { $0[Koala.DeprecatedKey] as! Bool? })
    XCTAssertEqual([project.id, project.id, project.id, project.id, project.id, project.id, project.id],
                   self.trackingClient.properties.map { $0["project_pid"] as! Int? })

    self.vm.inputs.searchTextChanged("")

    self.hasMessageThreads.assertValues([true, false, true, false])
    XCTAssertEqual(
      [
        "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results"
      ],
      self.trackingClient.events)

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true, false, true, false])
    XCTAssertEqual(
      [
        "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results"
      ],
      self.trackingClient.events)
  }

  func testGoToMessageThread() {
    let project = Project.template |> Project.lens.id .~ 123
    let messageThread = MessageThread.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.vm.inputs.tappedMessageThread(messageThread)

    self.goToMessageThread.assertValues([messageThread])
  }

  func testClearSearchTerm_NoProject() {
    self.vm.inputs.configureWith(project: nil)

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Message Search"], self.trackingClient.events)

    self.vm.inputs.viewWillAppear()

    self.hasMessageThreads.assertValues([])

    self.vm.inputs.searchTextChanged("hello")

    self.hasMessageThreads.assertValues([])
    XCTAssertEqual(["Viewed Message Search"], self.trackingClient.events)

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true])
    XCTAssertEqual(
      [
        "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results"
      ],
      self.trackingClient.events)
    XCTAssertEqual([nil, true, true, nil],
                   self.trackingClient.properties.map { $0[Koala.DeprecatedKey] as! Bool? })
    XCTAssertEqual([nil, nil, nil, nil],
                   self.trackingClient.properties.map { $0["project_pid"] as! Int? })

    self.vm.inputs.clearSearchText()

    self.hasMessageThreads.assertValues([true, false])
    XCTAssertEqual(
      [
        "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results", "Cleared Message Search Term"
      ],
      self.trackingClient.events)
    XCTAssertEqual([nil, true, true, nil, nil],
                   self.trackingClient.properties.map { $0[Koala.DeprecatedKey] as! Bool? })
    XCTAssertEqual([nil, nil, nil, nil, nil],
                   self.trackingClient.properties.map { $0["project_pid"] as! Int? })
  }

  func testClearSearchTerm_WithProject() {
    let project = Project.template |> Project.lens.id .~ 123

    self.vm.inputs.configureWith(project: project)

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Message Search"], self.trackingClient.events)

    self.vm.inputs.viewWillAppear()

    self.hasMessageThreads.assertValues([])

    self.vm.inputs.searchTextChanged("hello")

    self.hasMessageThreads.assertValues([])
    XCTAssertEqual(["Viewed Message Search"], self.trackingClient.events)

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true])
    XCTAssertEqual(
      [
        "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results"
      ],
      self.trackingClient.events)
    XCTAssertEqual([nil, true, true, nil],
                   self.trackingClient.properties.map { $0[Koala.DeprecatedKey] as! Bool? })
    XCTAssertEqual([project.id, project.id, project.id, project.id],
                   self.trackingClient.properties.map { $0["project_pid"] as! Int? })

    self.vm.inputs.clearSearchText()

    self.hasMessageThreads.assertValues([true, false])
    XCTAssertEqual(
      [
        "Viewed Message Search", "Message Threads Search", "Message Inbox Search",
        "Viewed Message Search Results", "Cleared Message Search Term"
      ],
      self.trackingClient.events)
    XCTAssertEqual([nil, true, true, nil, nil],
                   self.trackingClient.properties.map { $0[Koala.DeprecatedKey] as! Bool? })
    XCTAssertEqual([project.id, project.id, project.id, project.id, project.id],
                   self.trackingClient.properties.map { $0["project_pid"] as! Int? })
  }
}
