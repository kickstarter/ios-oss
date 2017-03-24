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

  private let dismissKeyboard = TestObserver<(), NoError>()
  private let didConnectToChat = TestObserver<Bool, NoError>()
  private let openLoginToutViewController = TestObserver<LoginIntent, NoError>()
  private let prependChatMessagesToDataSourceMessages = TestObserver<[LiveStreamChatMessage], NoError>()
  private let prependChatMessagesToDataSourceReload = TestObserver<Bool, NoError>()
  private let presentMoreMenuViewController = TestObserver<(LiveStreamEvent, Bool), NoError>()
  private let shouldCollapseChatInputView = TestObserver<Bool, NoError>()
  private let shouldHideChatTableView = TestObserver<Bool, NoError>()
  private let willConnectToChat = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.didConnectToChat.observe(self.didConnectToChat.observer)
    self.vm.outputs.openLoginToutViewController.observe(self.openLoginToutViewController.observer)
    self.vm.outputs.prependChatMessagesToDataSourceAndReload.map(first).observe(
      self.prependChatMessagesToDataSourceMessages.observer)
    self.vm.outputs.prependChatMessagesToDataSourceAndReload.map(second).observe(
      self.prependChatMessagesToDataSourceReload.observer)
    self.vm.outputs.presentMoreMenuViewController.observe(self.presentMoreMenuViewController.observer)
    self.vm.outputs.shouldCollapseChatInputView.observe(self.shouldCollapseChatInputView.observer)
    self.vm.outputs.shouldHideChatTableView.observe(self.shouldHideChatTableView.observer)
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
      chatMessagesSnapshotsAddedResult: Result(addedMessage),
      chatMessagesSnapshotsValueResult: Result(initialMessages)
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, chatHidden: false)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.prependChatMessagesToDataSourceMessages.assertValues([initialMessages, [addedMessage]])
      self.prependChatMessagesToDataSourceReload.assertValues([true, false])
    }
  }

  func testPrependMessagesToDataSource_AndReload() {
    self.prependChatMessagesToDataSourceMessages.assertValueCount(0)
    self.prependChatMessagesToDataSourceReload.assertValueCount(0)

    let messages = Array(0...30).map { _ in
      LiveStreamChatMessage.template
    }

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, chatHidden: false)
    self.vm.inputs.viewDidLoad()

    self.prependChatMessagesToDataSourceMessages.assertValueCount(1)
    self.prependChatMessagesToDataSourceReload.assertValues([true])
  }
//fixme:
  func testAuthorization_LoggedIn() {
//    self.configureChatHandlerWithUserInfo.assertValueCount(0)
//    self.didAuthorizeChat.assertValueCount(0)
//    self.willAuthorizeChat.assertValueCount(0)
//    self.updateLiveAuthTokenInEnvironment.assertValueCount(0)
//
//    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
//    let apiService = MockService(liveAuthTokenResponse: LiveAuthTokenEnvelope.template)
//    let liveStreamService = MockLiveStreamService(fetchEventResult: Result(LiveStreamEvent.template))
//
//    withEnvironment(apiService: apiService, apiDelayInterval: .seconds(3),
//                    liveStreamService: liveStreamService) {
//      self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, chatHidden: false)
//      self.vm.inputs.viewDidLoad()
//
//      self.scheduler.advance()
//
//      self.configureChatHandlerWithUserInfo.assertValueCount(0)
//      self.didAuthorizeChat.assertValueCount(0)
//      self.willAuthorizeChat.assertValueCount(1)
//      self.updateLiveAuthTokenInEnvironment.assertValueCount(0)
//
//      self.scheduler.advance()
//
//      self.configureChatHandlerWithUserInfo.assertValueCount(0)
//      self.didAuthorizeChat.assertValueCount(0)
//      self.willAuthorizeChat.assertValueCount(1)
//      self.updateLiveAuthTokenInEnvironment.assertValueCount(0)
//
//      self.scheduler.advance(by: .seconds(3))
//
//      self.configureChatHandlerWithUserInfo.assertValueCount(0)
//      self.didAuthorizeChat.assertValueCount(1)
//      self.willAuthorizeChat.assertValueCount(1)
//      self.updateLiveAuthTokenInEnvironment.assertValueCount(1)
//
//      self.scheduler.advance(by: .seconds(3))
//
//      self.configureChatHandlerWithUserInfo.assertValueCount(1)
//      self.didAuthorizeChat.assertValueCount(1)
//      self.willAuthorizeChat.assertValueCount(1)
//      self.updateLiveAuthTokenInEnvironment.assertValueCount(1)
//    }
  }
//fixme:
  func testAuthorization_LoggedOut() {
//    self.configureChatHandlerWithUserInfo.assertValueCount(0)
//    self.didAuthorizeChat.assertValueCount(0)
//    self.willAuthorizeChat.assertValueCount(0)
//    self.updateLiveAuthTokenInEnvironment.assertValueCount(0)
//
//    let apiService = MockService(liveAuthTokenResponse: LiveAuthTokenEnvelope.template)
//    let liveStreamService = MockLiveStreamService(fetchEventResult: Result(LiveStreamEvent.template))
//
//    withEnvironment(apiService: apiService, apiDelayInterval: .seconds(3),
//                    liveStreamService: liveStreamService) {
//      self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, chatHidden: false)
//      self.vm.inputs.viewDidLoad()
//
//      self.scheduler.advance()
//
//      self.configureChatHandlerWithUserInfo.assertValueCount(0)
//      self.didAuthorizeChat.assertValueCount(0)
//      self.willAuthorizeChat.assertValueCount(0)
//      self.updateLiveAuthTokenInEnvironment.assertValueCount(0)
//
//      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
//      self.vm.inputs.userSessionStarted()
//
//      self.scheduler.advance()
//
//      self.configureChatHandlerWithUserInfo.assertValueCount(0)
//      self.didAuthorizeChat.assertValueCount(0)
//      self.willAuthorizeChat.assertValueCount(1)
//      self.updateLiveAuthTokenInEnvironment.assertValueCount(0)
//
//      self.scheduler.advance(by: .seconds(3))
//
//      self.configureChatHandlerWithUserInfo.assertValueCount(0)
//      self.didAuthorizeChat.assertValueCount(1)
//      self.willAuthorizeChat.assertValueCount(1)
//      self.updateLiveAuthTokenInEnvironment.assertValueCount(1)
//
//      self.scheduler.advance(by: .seconds(3))
//
//      self.configureChatHandlerWithUserInfo.assertValueCount(1)
//      self.didAuthorizeChat.assertValueCount(1)
//      self.willAuthorizeChat.assertValueCount(1)
//      self.updateLiveAuthTokenInEnvironment.assertValueCount(1)
//    }
  }

  func testChatInputViewRequestedLogin() {
    self.openLoginToutViewController.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, chatHidden: false)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.chatInputViewRequestedLogin()

    self.openLoginToutViewController.assertValues([.liveStreamChat])
  }

  func testShouldHideTableView() {
    self.shouldHideChatTableView.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, chatHidden: false)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.didSetChatHidden(hidden: true)

    self.shouldHideChatTableView.assertValues([false, true])
  }

  func testPresentMoreMenuViewController() {
    self.presentMoreMenuViewController.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template, chatHidden: false)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.moreMenuButtonTapped()

    self.presentMoreMenuViewController.assertValueCount(1)
  }

  func testShouldCollapseChatInputView_Live() {
    self.shouldCollapseChatInputView.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent, chatHidden: false)
    self.vm.inputs.viewDidLoad()

    self.shouldCollapseChatInputView.assertValues([false])
  }

  func testShouldCollapseChatInputView_Replay() {
    self.shouldCollapseChatInputView.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent, chatHidden: false)
    self.vm.inputs.viewDidLoad()

    self.shouldCollapseChatInputView.assertValues([true])
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
}
