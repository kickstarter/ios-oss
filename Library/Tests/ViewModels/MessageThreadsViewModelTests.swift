import XCTest
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi
import ReactiveCocoa
import Result

internal final class MessageThreadsViewModelTests: TestCase {
  private let vm: MessageThreadsViewModelType = MessageThreadsViewModel()

  private let emptyStateIsVisible = TestObserver<Bool, NoError>()
  private let loadingFooterIsHidden = TestObserver<Bool, NoError>()
  private let goToSearch = TestObserver<(), NoError>()
  private let mailboxName = TestObserver<String, NoError>()
  private let hasMessageThreads = TestObserver<Bool, NoError>()
  private let refreshControlEndRefreshing = TestObserver<(), NoError>()
  private let showMailboxChooserActionSheet = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.emptyStateIsVisible.observe(self.emptyStateIsVisible.observer)
    self.vm.outputs.loadingFooterIsHidden.observe(self.loadingFooterIsHidden.observer)
    self.vm.outputs.goToSearch.observe(self.goToSearch.observer)
    self.vm.outputs.mailboxName.observe(self.mailboxName.observer)
    self.vm.outputs.messageThreads.map { !$0.isEmpty }.observe(self.hasMessageThreads.observer)
    self.vm.outputs.refreshControlEndRefreshing.observe(self.refreshControlEndRefreshing.observer)
    self.vm.outputs.showMailboxChooserActionSheet.observe(self.showMailboxChooserActionSheet.observer)
  }

  func testLoadingMessages_NoProject() {
    self.vm.inputs.configureWith(project: nil)
    self.vm.inputs.viewDidLoad()

    self.loadingFooterIsHidden.assertValues([false], "Loading footer is visible at beginning.")
    self.refreshControlEndRefreshing.assertValueCount(0, "Doesn't emit at beginning.")
    self.hasMessageThreads.assertValues([], "No threads emit.")
    XCTAssertEqual(["Message Threads View", "Message Inbox View"], self.trackingClient.events,
                   "View event and its deprecated version are tracked.")
    XCTAssertEqual([nil, true], self.trackingClient.properties.map { $0["DEPRECATED"] as! Bool? },
                   "Deprecated property is tracked in deprecated event.")

    // Wait enough time to get API response
    self.scheduler.advance()

    self.loadingFooterIsHidden.assertValues([false, true], "Loading footer is hidden after API response.")
    self.refreshControlEndRefreshing.assertValueCount(1, "Refresh control stopped refreshing.")
    self.hasMessageThreads.assertValues([true], "Threads are emitted.")

    // Pull-to-refresh
    self.vm.inputs.refresh()

    self.loadingFooterIsHidden.assertValues([false, true], "Loading footer doesn't change visibility.")
    self.refreshControlEndRefreshing.assertValueCount(1, "Refresh control didn't change.")
    self.hasMessageThreads.assertValues([true, false], "Threads clear immediately.")

    // Wait enough time to get API response
    self.scheduler.advance()

    self.loadingFooterIsHidden.assertValues([false, true], "Loading footer doesn't change visibility.")
    self.refreshControlEndRefreshing.assertValueCount(2, "Refresh control stopped refreshing.")
    self.hasMessageThreads.assertValues([true, false, true], "Threads are emitted.")

    // Scroll to bottom of threads
    self.vm.inputs.willDisplayRow(3, outOf: 4)

    self.loadingFooterIsHidden.assertValues([false, true, false], "Loading footer is visible.")
    self.refreshControlEndRefreshing.assertValueCount(2, "Refresh control didn't change.")
    self.hasMessageThreads.assertValues([true, false, true], "No threads emit.")

    // Wait enough time to get API response
    self.scheduler.advance()

    self.loadingFooterIsHidden.assertValues([false, true, false, true], "Loading footer is hidden.")
    self.refreshControlEndRefreshing.assertValueCount(3, "Refresh control stopped refreshing.")
    self.hasMessageThreads.assertValues([true, false, true, true], "More threads are emitted.")
  }

  func testLoadingMessages_WithProject() {
    self.vm.inputs.configureWith(project: Project.template)
    self.vm.inputs.viewDidLoad()

    self.loadingFooterIsHidden.assertValues([false], "Loading footer is visible at beginning.")
    self.refreshControlEndRefreshing.assertValueCount(0, "Doesn't emit at beginning.")
    self.hasMessageThreads.assertValues([], "No threads emit.")

    // Wait enough time to get API response
    self.scheduler.advance()

    self.loadingFooterIsHidden.assertValues([false, true], "Loading footer is hidden after API response.")
    self.refreshControlEndRefreshing.assertValueCount(1, "Refresh control stopped refreshing.")
    self.hasMessageThreads.assertValues([true], "Threads are emitted.")

    // Pull-to-refresh
    self.vm.inputs.refresh()

    self.loadingFooterIsHidden.assertValues([false, true], "Loading footer doesn't change visibility.")
    self.refreshControlEndRefreshing.assertValueCount(1, "Refresh control didn't change.")
    self.hasMessageThreads.assertValues([true, false], "Threads clear immediately.")

    // Wait enough time to get API response
    self.scheduler.advance()

    self.loadingFooterIsHidden.assertValues([false, true], "Loading footer doesn't change visibility.")
    self.refreshControlEndRefreshing.assertValueCount(2, "Refresh control stopped refreshing.")
    self.hasMessageThreads.assertValues([true, false, true], "Threads are emitted.")

    // Scroll to bottom of threads
    self.vm.inputs.willDisplayRow(3, outOf: 4)

    self.loadingFooterIsHidden.assertValues([false, true, false], "Loading footer is visible.")
    self.refreshControlEndRefreshing.assertValueCount(2, "Refresh control didn't change.")
    self.hasMessageThreads.assertValues([true, false, true], "No threads emit.")

    // Wait enough time to get API response
    self.scheduler.advance()

    self.loadingFooterIsHidden.assertValues([false, true, false, true], "Loading footer is hidden.")
    self.refreshControlEndRefreshing.assertValueCount(3, "Refresh control stopped refreshing.")
    self.hasMessageThreads.assertValues([true, false, true, true], "More threads are emitted.")
  }

  func testSwitchingMailbox() {
    self.vm.inputs.configureWith(project: nil)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    XCTAssertEqual(["Message Threads View", "Message Inbox View"], self.trackingClient.events,
                   "View event and its deprecated version are tracked.")
    XCTAssertEqual([nil, true], self.trackingClient.properties.map { $0["DEPRECATED"] as! Bool? },
                   "Deprecated property is tracked in deprecated event.")

    self.loadingFooterIsHidden.assertValues([false, true],
                                            "Loading footer is shown/hidden while loading threads.")
    self.refreshControlEndRefreshing.assertValueCount(1, "Refresh control isn't refershing.")
    self.hasMessageThreads.assertValues([true], "Threads are emitted.")
    self.emptyStateIsVisible.assertValues([false])

    self.vm.inputs.mailboxButtonPressed()

    self.showMailboxChooserActionSheet.assertValueCount(1, "Mailbox action sheet is shown.")
    self.emptyStateIsVisible.assertValues([false])

    self.vm.inputs.switchTo(mailbox: .sent)

    self.loadingFooterIsHidden.assertValues([false, true, false], "Loading footer is shown.")
    self.refreshControlEndRefreshing.assertValueCount(1, "Refresh control ends refreshing.")
    self.hasMessageThreads.assertValues([true, false], "Threads clear immediately.")
    self.emptyStateIsVisible.assertValues([false])
    XCTAssertEqual(
      ["Message Threads View", "Message Inbox View", "Message Threads View", "Message Inbox View"],
      self.trackingClient.events,
      "View event and its deprecated version are tracked.")
    XCTAssertEqual([nil, true, nil, true],
                   self.trackingClient.properties.map { $0["DEPRECATED"] as! Bool? },
                   "Deprecated property is tracked in deprecated event.")

    self.scheduler.advance()

    self.loadingFooterIsHidden.assertValues([false, true, false, true], "Loading footer is hidden.")
    self.refreshControlEndRefreshing.assertValueCount(2, "Refresh control isn't refreshing.")
    self.hasMessageThreads.assertValues([true, false, true], "Threads are emitted.")
    self.emptyStateIsVisible.assertValues([false])
  }

  func testGoToSearch() {
    self.vm.inputs.viewDidLoad()

    self.goToSearch.assertValueCount(0)

    self.vm.inputs.searchButtonPressed()

    self.goToSearch.assertValueCount(1)
  }

  func testEmptyState() {
    withEnvironment(apiService: MockService(fetchMessageThreadsResponse: [])) {
      self.vm.inputs.configureWith(project: nil)
      self.vm.inputs.viewDidLoad()

      self.emptyStateIsVisible.assertValues([], "No empty state emits immediately.")
      self.loadingFooterIsHidden.assertValues([false], "Loading footer is visible")

      self.scheduler.advance()

      self.emptyStateIsVisible.assertValues([true], "Empty state is shown.")
      self.loadingFooterIsHidden.assertValues([false, true], "Loading view is hidden.")

      // NB: This tests an implementation detail and can be removed if we find a better way to handle this.
      // When the empty state shows it causes `willDisplayRow` to be called with `(0, 1)`. That triggers
      // the loading footer to become visible. Right now we are explicitly checking for that in order to
      // prevent that.
      self.vm.inputs.willDisplayRow(0, outOf: 1)

      self.emptyStateIsVisible.assertValues([true], "The empty state is still visible.")
      self.loadingFooterIsHidden.assertValues([false, true], "The loading view did not change.")
    }
  }
}
