import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamChatViewModelTests: TestCase {
  let vm: LiveStreamChatViewModelType = LiveStreamChatViewModel()

  let appendChatMessagesToDataSource = TestObserver<[LiveStreamChatMessage], NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.appendChatMessagesToDataSource.observe(self.appendChatMessagesToDataSource.observer)
  }

  func testAppendMessagesToDataSource() {
    self.appendChatMessagesToDataSource.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.received(chatMessages: [.template, .template, .template])

    self.appendChatMessagesToDataSource.assertValueCount(1)
  }
}
