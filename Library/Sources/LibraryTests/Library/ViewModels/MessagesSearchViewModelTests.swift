@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class MessagesSearchViewModelTests: TestCase {
  fileprivate let vm: MessagesSearchViewModelType = MessagesSearchViewModel()

  fileprivate let emptyStateIsVisible = TestObserver<Bool, Never>()
  fileprivate let isSearching = TestObserver<Bool, Never>()
  fileprivate let hasMessageThreads = TestObserver<Bool, Never>()
  fileprivate let showKeyboard = TestObserver<Bool, Never>()
  fileprivate let goToMessageThread = TestObserver<MessageThread, Never>()

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

    XCTAssertEqual([], self.segmentTrackingClient.events)

    self.vm.inputs.viewDidLoad()

    self.vm.inputs.viewWillAppear()

    self.hasMessageThreads.assertValues([])
    self.isSearching.assertValues([false])

    self.vm.inputs.searchTextChanged("hello")

    self.hasMessageThreads.assertValues([])
    self.isSearching.assertValues([false, true])

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true])
    self.isSearching.assertValues([false, true, false])

    withEnvironment(apiService: MockService(fetchMessageThreadsResponse: [])) {
      self.vm.inputs.searchTextChanged("hello world")

      self.hasMessageThreads.assertValues([true, false])
      self.isSearching.assertValues([false, true, false, true])

      self.scheduler.advance()

      self.hasMessageThreads.assertValues([true, false])
      self.isSearching.assertValues([false, true, false, true, false])

      self.vm.inputs.searchTextChanged("")
      self.vm.inputs.searchTextChanged(nil)

      self.hasMessageThreads.assertValues([true, false])
      self.isSearching.assertValues([false, true, false, true, false])

      self.scheduler.advance()

      self.hasMessageThreads.assertValues([true, false])
      self.isSearching.assertValues([false, true, false, true, false])
    }
  }

  func testSearch_WithProject() {
    let project = Project.template |> Project.lens.id .~ 123

    self.vm.inputs.configureWith(project: project)

    XCTAssertEqual([], self.segmentTrackingClient.events)

    self.vm.inputs.viewDidLoad()

    self.vm.inputs.viewWillAppear()

    self.hasMessageThreads.assertValues([])

    self.vm.inputs.searchTextChanged("hello")

    self.hasMessageThreads.assertValues([])

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true])

    self.vm.inputs.searchTextChanged("hello world")

    self.hasMessageThreads.assertValues([true, false])

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true, false, true])

    self.vm.inputs.searchTextChanged("")

    self.hasMessageThreads.assertValues([true, false, true, false])

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true, false, true, false])
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

    XCTAssertEqual([], self.segmentTrackingClient.events)

    self.vm.inputs.viewDidLoad()

    self.vm.inputs.viewWillAppear()

    self.hasMessageThreads.assertValues([])

    self.vm.inputs.searchTextChanged("hello")

    self.hasMessageThreads.assertValues([])

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true])

    self.vm.inputs.clearSearchText()

    self.hasMessageThreads.assertValues([true, false])
  }

  func testClearSearchTerm_WithProject() {
    let project = Project.template |> Project.lens.id .~ 123

    self.vm.inputs.configureWith(project: project)

    XCTAssertEqual([], self.segmentTrackingClient.events)

    self.vm.inputs.viewDidLoad()

    self.vm.inputs.viewWillAppear()

    self.hasMessageThreads.assertValues([])

    self.vm.inputs.searchTextChanged("hello")

    self.hasMessageThreads.assertValues([])

    self.scheduler.advance()

    self.hasMessageThreads.assertValues([true])

    self.vm.inputs.clearSearchText()

    self.hasMessageThreads.assertValues([true, false])
  }
}
