//swiftlint:disable file_length
import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamChatViewModelTests: TestCase {
  private let vm: LiveStreamChatViewModelType = LiveStreamChatViewModel()

  private let collapseChatInputView = TestObserver<Bool, NoError>()
  private let dismissKeyboard = TestObserver<(), NoError>()
  private let didConnectToChat = TestObserver<Bool, NoError>()
  private let hideChatTableView = TestObserver<Bool, NoError>()
  private let notifyDelegateLiveStreamApiErrorOccurred = TestObserver<LiveApiError, NoError>()
  private let prependChatMessagesToDataSourceMessages = TestObserver<[LiveStreamChatMessage], NoError>()
  private let prependChatMessagesToDataSourceReload = TestObserver<Bool, NoError>()
  private let presentLoginToutViewController = TestObserver<LoginIntent, NoError>()
  private let presentMoreMenuViewController = TestObserver<(LiveStreamEvent, Bool), NoError>()
  private let willConnectToChat = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.collapseChatInputView.observe(self.collapseChatInputView.observer)
    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.didConnectToChat.observe(self.didConnectToChat.observer)
    self.vm.outputs.hideChatTableView.observe(self.hideChatTableView.observer)
    self.vm.outputs.notifyDelegateLiveStreamApiErrorOccurred.observe(
      self.notifyDelegateLiveStreamApiErrorOccurred.observer)
    self.vm.outputs.prependChatMessagesToDataSourceAndReload.map(first).observe(
      self.prependChatMessagesToDataSourceMessages.observer)
    self.vm.outputs.prependChatMessagesToDataSourceAndReload.map(second).observe(
      self.prependChatMessagesToDataSourceReload.observer)
    self.vm.outputs.presentLoginToutViewController.observe(self.presentLoginToutViewController.observer)
    self.vm.outputs.presentMoreMenuViewController.observe(self.presentMoreMenuViewController.observer)
    self.vm.outputs.willConnectToChat.observe(self.willConnectToChat.observer)
  }

  func testPrependMessagesToDataSource() {
    self.prependChatMessagesToDataSourceMessages.assertValueCount(0)
    self.prependChatMessagesToDataSourceReload.assertValueCount(0)

    let initialMessages = Array(1...100).map { value in
      LiveStreamChatMessage.template
        |> LiveStreamChatMessage.lens.id .~ String(value)
    }

    let addedMessage = LiveStreamChatMessage.template
      |> LiveStreamChatMessage.lens.id .~ "101"

    let liveStreamService = MockLiveStreamService(
      chatMessagesSnapshotsAddedResult: Result([addedMessage]),
      chatMessagesSnapshotsValueResult: Result([initialMessages])
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, chatHidden: false)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.prependChatMessagesToDataSourceMessages.assertValues([initialMessages, [addedMessage]])
      self.prependChatMessagesToDataSourceReload.assertValues([true, false])
    }
  }

  func testChatInputViewRequestedLogin() {
    self.presentLoginToutViewController.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, chatHidden: false)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.chatInputViewRequestedLogin()

    self.presentLoginToutViewController.assertValues([.liveStreamChat])
  }

  func testHideTableView() {
    self.hideChatTableView.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, chatHidden: false)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.didSetChatHidden(hidden: true)

    self.hideChatTableView.assertValues([false, true])
  }

  func testPresentMoreMenuViewController() {
    self.presentMoreMenuViewController.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, chatHidden: false)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.moreMenuButtonTapped()

    self.presentMoreMenuViewController.assertValueCount(1)
  }

  func testCollapseChatInputView_Live() {
    self.collapseChatInputView.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent, chatHidden: false)
    self.vm.inputs.viewDidLoad()

    self.collapseChatInputView.assertValues([false])
  }

  func testCollapseChatInputView_Replay() {
    self.collapseChatInputView.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent, chatHidden: false)
    self.vm.inputs.viewDidLoad()

    self.collapseChatInputView.assertValues([true])
  }

  func testDismissKeyboard() {
    self.dismissKeyboard.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent, chatHidden: false)
    self.vm.inputs.deviceOrientationDidChange(orientation: .portrait)

    self.dismissKeyboard.assertValueCount(1)

    self.vm.inputs.deviceOrientationDidChange(orientation: .landscapeLeft)

    self.dismissKeyboard.assertValueCount(2)

    self.vm.inputs.deviceOrientationDidChange(orientation: .portrait)

    self.dismissKeyboard.assertValueCount(3)
  }

  func testConnectingToChat() {
    self.willConnectToChat.assertValueCount(0)
    self.didConnectToChat.assertValueCount(0)

    let initialLiveStreamEvent = .template
      |> LiveStreamEvent.lens.firebase .~ nil

    let liveStreamEvent = LiveStreamEvent.template

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent)
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: initialLiveStreamEvent,
                                   chatHidden: false)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.willConnectToChat.assertValueCount(1)
      self.didConnectToChat.assertValueCount(1)
    }
  }

  func testSendMessage_Success() {
    self.notifyDelegateLiveStreamApiErrorOccurred.assertValueCount(0)

    let initialLiveStreamEvent = .template
      |> LiveStreamEvent.lens.firebase .~ nil

    let liveStreamEvent = LiveStreamEvent.template

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent)
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: initialLiveStreamEvent,
                                   chatHidden: false)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.didSendMessage(message: "Test message")

      self.notifyDelegateLiveStreamApiErrorOccurred.assertValueCount(0)
    }
  }

  func testSendMessage_Failed() {
    self.notifyDelegateLiveStreamApiErrorOccurred.assertValueCount(0)

    let initialLiveStreamEvent = .template
      |> LiveStreamEvent.lens.firebase .~ nil

    let liveStreamEvent = LiveStreamEvent.template

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent),
      sendChatMessageResult: Result(error: .sendChatMessageFailed)
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: initialLiveStreamEvent,
                                   chatHidden: false)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.didSendMessage(message: "Test message")

      self.notifyDelegateLiveStreamApiErrorOccurred.assertValues([.sendChatMessageFailed])
    }
  }
}
