import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

//swiftlint:disable:next type_name
internal final class LiveStreamContainerMoreMenuViewModelTests: TestCase {

  private let vm: LiveStreamContainerMoreMenuViewModelType = LiveStreamContainerMoreMenuViewModel()

  private let loadDataSource = TestObserver<[LiveStreamContainerMoreMenuItem], NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadDataSource.observe(self.loadDataSource.observer)
  }

  func testLoadDataSource_ChatHidden() {
    self.loadDataSource.assertValueCount(0)

    let liveStreamEvent = LiveStreamEvent.template

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent, chatHidden: true)
    self.vm.inputs.viewDidLoad()

    let hideChat = LiveStreamContainerMoreMenuItem.hideChat(hidden: true)
    let share = LiveStreamContainerMoreMenuItem.share(liveStreamEvent: liveStreamEvent)
    let cancel = LiveStreamContainerMoreMenuItem.cancel

    self.loadDataSource.assertValues([[hideChat, share, cancel]])
  }

  func testLoadDataSource_ChatShowm() {
    self.loadDataSource.assertValueCount(0)

    let liveStreamEvent = LiveStreamEvent.template

    self.vm.inputs.configureWith(liveStreamEvent: liveStreamEvent, chatHidden: false)
    self.vm.inputs.viewDidLoad()

    let hideChat = LiveStreamContainerMoreMenuItem.hideChat(hidden: false)
    let share = LiveStreamContainerMoreMenuItem.share(liveStreamEvent: liveStreamEvent)
    let cancel = LiveStreamContainerMoreMenuItem.cancel

    self.loadDataSource.assertValues([[hideChat, share, cancel]])
  }
}
