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

  private let chatInputViewPlaceholderText = TestObserver<String, NoError>()
  private let clearTextFieldAndResignFirstResponder = TestObserver<(), NoError>()
  private let collapseChatInputView = TestObserver<Bool, NoError>()
  private let dismissKeyboard = TestObserver<(), NoError>()
  private let didConnectToChat = TestObserver<Bool, NoError>()
  private let prependChatMessagesToDataSourceMessages = TestObserver<[LiveStreamChatMessage], NoError>()
  private let prependChatMessagesToDataSourceReload = TestObserver<Bool, NoError>()
  private let presentLoginToutViewController = TestObserver<LoginIntent, NoError>()
  private let sendButtonEnabled = TestObserver<Bool, NoError>()
  private let showErrorAlert = TestObserver<String, NoError>()
  private let willConnectToChat = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.chatInputViewPlaceholderText.map { $0.string }
      .observe(self.chatInputViewPlaceholderText.observer)
    self.vm.outputs.clearTextFieldAndResignFirstResponder
      .observe(self.clearTextFieldAndResignFirstResponder.observer)
    self.vm.outputs.collapseChatInputView.observe(self.collapseChatInputView.observer)
    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.didConnectToChat.observe(self.didConnectToChat.observer)
    self.vm.outputs.prependChatMessagesToDataSourceAndReload.map(first).observe(
      self.prependChatMessagesToDataSourceMessages.observer)
    self.vm.outputs.prependChatMessagesToDataSourceAndReload.map(second).observe(
      self.prependChatMessagesToDataSourceReload.observer)
    self.vm.outputs.presentLoginToutViewController.observe(self.presentLoginToutViewController.observer)
    self.vm.outputs.sendButtonEnabled.observe(self.sendButtonEnabled.observer)
    self.vm.outputs.showErrorAlert.observe(
      self.showErrorAlert.observer)
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
      chatMessagesAddedResult: Result([addedMessage]),
      initialChatMessagesResult: Result([initialMessages])
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.prependChatMessagesToDataSourceMessages.assertValues([initialMessages, [addedMessage]])
      self.prependChatMessagesToDataSourceReload.assertValues([true, false])
    }
  }

  func testFetchInitialChatMessagesError() {
    self.prependChatMessagesToDataSourceMessages.assertValueCount(0)
    self.prependChatMessagesToDataSourceReload.assertValueCount(0)

    let liveStreamService = MockLiveStreamService(
      initialChatMessagesResult: Result(error: .chatMessageDecodingFailed)
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.prependChatMessagesToDataSourceMessages.assertValueCount(0)
      self.prependChatMessagesToDataSourceReload.assertValueCount(0)

      self.showErrorAlert.assertValues(["Something went wrong, please try again."])
    }
  }

  func testPresentLoginToutViewController() {
    self.presentLoginToutViewController.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template)
    self.vm.inputs.viewDidLoad()
    _ = self.vm.inputs.textFieldShouldBeginEditing()

    self.presentLoginToutViewController.assertValues([.liveStreamChat])
  }

  func testCollapseChatInputView_Live() {
    self.collapseChatInputView.assertValueCount(0)

    let initialLiveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ true

    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent)
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: initialLiveStreamEvent)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.collapseChatInputView.assertValues([false])
    }
  }

  func testCollapseChatInputView_Replay() {
    self.collapseChatInputView.assertValueCount(0)

    let initialLiveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false

    let liveStreamEvent = LiveStreamEvent.template

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent)
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: initialLiveStreamEvent)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.collapseChatInputView.assertValues([true])
    }
  }

  func testDismissKeyboard() {
    self.dismissKeyboard.assertValueCount(0)

    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.liveNow .~ false

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: liveStreamEvent)
    self.vm.inputs.deviceOrientationDidChange(orientation: .portrait)

    self.dismissKeyboard.assertValueCount(1)

    self.vm.inputs.deviceOrientationDidChange(orientation: .landscapeLeft)

    self.dismissKeyboard.assertValueCount(2)

    self.vm.inputs.deviceOrientationDidChange(orientation: .portrait)

    self.dismissKeyboard.assertValueCount(3)
  }

  func testConnectingToChat_LoggedIn() {
    self.willConnectToChat.assertValueCount(0)
    self.didConnectToChat.assertValueCount(0)

    let initialLiveStreamEvent = .template
      |> LiveStreamEvent.lens.firebase .~ nil

    let liveStreamEvent = LiveStreamEvent.template

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent),
      signInToFirebaseWithCustomTokenResult: Result(["deadbeef"])
    )

    AppEnvironment.login(AccessTokenEnvelope.init(accessToken: "deadbeef", user: User.template))

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: initialLiveStreamEvent)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.willConnectToChat.assertValueCount(2)
      self.didConnectToChat.assertValueCount(1)
    }
  }

  func testConnectingToChat_LoggedOut() {
    self.willConnectToChat.assertValueCount(0)
    self.didConnectToChat.assertValueCount(0)

    let initialLiveStreamEvent = .template
      |> LiveStreamEvent.lens.firebase .~ nil

    let liveStreamEvent = LiveStreamEvent.template

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent),
      signInToFirebaseWithCustomTokenResult: Result(["deadbeef"])
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: initialLiveStreamEvent)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.willConnectToChat.assertValueCount(2)
      self.didConnectToChat.assertValueCount(0)

      AppEnvironment.login(AccessTokenEnvelope.init(accessToken: "deadbeef", user: User.template))
      self.vm.inputs.userSessionChanged(session: .loggedIn(token: "feedbeef"))

      self.didConnectToChat.assertValueCount(1)
    }
  }

  func testConnectingToChat_Failed() {
    self.willConnectToChat.assertValueCount(0)
    self.didConnectToChat.assertValueCount(0)

    let initialLiveStreamEvent = .template
      |> LiveStreamEvent.lens.firebase .~ nil

    let liveStreamEvent = LiveStreamEvent.template

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent),
      signInToFirebaseWithCustomTokenResult: Result(error: .firebaseCustomTokenAuthFailed)
    )

    AppEnvironment.login(AccessTokenEnvelope.init(accessToken: "deadbeef", user: User.template))

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: initialLiveStreamEvent)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.willConnectToChat.assertValueCount(2)
      self.didConnectToChat.assertValueCount(0)

      self.showErrorAlert.assertValues(["We were unable to connect to the live stream chat."])
    }
  }

  func testSendMessage_Success() {
    self.showErrorAlert.assertValueCount(0)

    let initialLiveStreamEvent = .template
      |> LiveStreamEvent.lens.firebase .~ nil

    let liveStreamEvent = LiveStreamEvent.template

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent)
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: initialLiveStreamEvent)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.textDidChange(toText: "Test message")
      self.vm.inputs.sendButtonTapped()

      self.showErrorAlert.assertValueCount(0)
    }
  }

  func testSendMessage_Failed() {
    self.showErrorAlert.assertValueCount(0)

    let initialLiveStreamEvent = .template
      |> LiveStreamEvent.lens.firebase .~ nil

    let liveStreamEvent = LiveStreamEvent.template

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent),
      sendChatMessageResult: Result(error: .sendChatMessageFailed)
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: initialLiveStreamEvent)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.textDidChange(toText: "Test message")
      self.vm.inputs.sendButtonTapped()

      self.showErrorAlert.assertValues(["Your chat message wasn't sent successfully."])
    }
  }

  func testSendButtonEnabled() {
    self.sendButtonEnabled.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.sendButtonEnabled.assertValues([false])

    self.vm.inputs.textDidChange(toText: "Typing")

    self.sendButtonEnabled.assertValues([false, true])

    self.vm.inputs.textDidChange(toText: "    ")

    self.sendButtonEnabled.assertValues([false, true, false])

    self.vm.inputs.textDidChange(toText: "")

    self.sendButtonEnabled.assertValues([false, true, false, false])

    self.vm.inputs.textDidChange(toText: "Typing")

    self.sendButtonEnabled.assertValues([false, true, false, false, true])

    self.vm.inputs.sendButtonTapped()

    self.sendButtonEnabled.assertValues([false, true, false, false, true, false])
  }

  func testPlaceholderText() {
    self.chatInputViewPlaceholderText.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.chatInputViewPlaceholderText.assertValues(["Say something kind..."])
  }

  func testClearTextFieldAndResignFirstResponder() {
    self.clearTextFieldAndResignFirstResponder.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.vm.inputs.textDidChange(toText: "Typing")
    self.vm.inputs.sendButtonTapped()

    self.clearTextFieldAndResignFirstResponder.assertValueCount(1)
  }
}
