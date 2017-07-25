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

  private let chatInputViewMessageLengthCountLabelText = TestObserver<String, NoError>()
  private let chatInputViewMessageLengthCountLabelTextColor = TestObserver<UIColor, NoError>()
  private let chatInputViewPlaceholderText = TestObserver<String, NoError>()
  private let clearTextFieldAndResignFirstResponder = TestObserver<(), NoError>()
  private let collapseChatInputView = TestObserver<Bool, NoError>()
  private let dismissKeyboard = TestObserver<(), NoError>()
  private let prependChatMessagesToDataSourceMessages = TestObserver<[LiveStreamChatMessage], NoError>()
  private let prependChatMessagesToDataSourceReload = TestObserver<Bool, NoError>()
  private let presentLoginToutViewController = TestObserver<LoginIntent, NoError>()
  private let sendButtonEnabled = TestObserver<Bool, NoError>()
  private let showErrorAlert = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.chatInputViewMessageLengthCountLabelText
      .observe(self.chatInputViewMessageLengthCountLabelText.observer)
    self.vm.outputs.chatInputViewMessageLengthCountLabelTextColor
      .observe(self.chatInputViewMessageLengthCountLabelTextColor.observer)
    self.vm.outputs.chatInputViewPlaceholderText.map { $0.string }
      .observe(self.chatInputViewPlaceholderText.observer)
    self.vm.outputs.clearTextFieldAndResignFirstResponder
      .observe(self.clearTextFieldAndResignFirstResponder.observer)
    self.vm.outputs.collapseChatInputView.observe(self.collapseChatInputView.observer)
    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.prependChatMessagesToDataSourceAndReload.map(first).observe(
      self.prependChatMessagesToDataSourceMessages.observer)
    self.vm.outputs.prependChatMessagesToDataSourceAndReload.map(second).observe(
      self.prependChatMessagesToDataSourceReload.observer)
    self.vm.outputs.presentLoginToutViewController.observe(self.presentLoginToutViewController.observer)
    self.vm.outputs.sendButtonEnabled.observe(self.sendButtonEnabled.observer)
    self.vm.outputs.showErrorAlert.observe(
      self.showErrorAlert.observer)
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
    let shouldBegin = self.vm.inputs.textFieldShouldBeginEditing()
    XCTAssertFalse(shouldBegin)

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

    self.dismissKeyboard.assertValueCount(0)

    self.vm.inputs.deviceOrientationDidChange(orientation: .landscapeLeft)

    self.dismissKeyboard.assertValueCount(1)

    self.vm.inputs.deviceOrientationDidChange(orientation: .portrait)

    self.dismissKeyboard.assertValueCount(1)
  }

  func testConnectingToChat_LoggedIn() {
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

      self.showErrorAlert.assertValueCount(0)
    }
  }

  func testConnectingToChat_LoggedOut() {
    let initialLiveStreamEvent = .template
      |> LiveStreamEvent.lens.firebase .~ nil

    let liveStreamEventWithToken = LiveStreamEvent.template

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(initialLiveStreamEvent)
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: initialLiveStreamEvent)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()
    }

    let liveStreamServiceWithToken = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEventWithToken),
      signInToFirebaseWithCustomTokenResult: Result(["deadbeef"])
    )

    withEnvironment(liveStreamService: liveStreamServiceWithToken) {
      AppEnvironment.login(AccessTokenEnvelope.init(accessToken: "deadbeef", user: User.template))
      self.vm.inputs.userSessionStarted()

      self.scheduler.advance()

      self.showErrorAlert.assertValueCount(0)
    }
  }

  func testConnectingToChat_Failed() {
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

      self.scheduler.advance()

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

      self.scheduler.advance()

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

    self.sendButtonEnabled.assertValues([false, true, false])

    self.vm.inputs.textDidChange(toText: "Typing")

    self.sendButtonEnabled.assertValues([false, true, false, true])

    self.vm.inputs.sendButtonTapped()

    self.sendButtonEnabled.assertValues([false, true, false, true, false])

    self.vm.inputs.textDidChange(toText: nil)

    self.sendButtonEnabled.assertValues([false, true, false, true, false])
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

  func testTrackSentChatMessage() {
    XCTAssertEqual([], self.trackingClient.events)

    let initialLiveStreamEvent = .template
      |> LiveStreamEvent.lens.firebase .~ nil

    let liveStreamEvent = LiveStreamEvent.template

    let liveStreamService = MockLiveStreamService(
      fetchEventResult: Result(liveStreamEvent),
      sendChatMessageResult: Result([()])
    )

    withEnvironment(liveStreamService: liveStreamService) {
      self.vm.inputs.configureWith(project: .template, liveStreamEvent: initialLiveStreamEvent)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      XCTAssertEqual([], self.trackingClient.events)

      self.vm.inputs.textDidChange(toText: "Test message")

      XCTAssertEqual([], self.trackingClient.events)

      self.vm.inputs.sendButtonTapped()

      self.scheduler.advance()

      XCTAssertEqual(["Sent Live Stream Message"], self.trackingClient.events)
    }
  }

  func testMessageLengthCountLabelTextAndColor() {
    let fiftyCharString = (0...49).map { _ in "x" }.reduce("", +)
    let oneFortyCharString = (0...139).map { _ in "x" }.reduce("", +)
    let oneFortyOneCharString = (0...140).map { _ in "x" }.reduce("", +)
    let twoHundredCharString = (0...199).map { _ in "x" }.reduce("", +)

    self.chatInputViewMessageLengthCountLabelText.assertValueCount(0)
    self.chatInputViewMessageLengthCountLabelTextColor.assertValueCount(0)
    self.sendButtonEnabled.assertValueCount(0)

    self.vm.inputs.configureWith(project: .template, liveStreamEvent: .template)
    self.vm.inputs.viewDidLoad()

    let normalColor = UIColor.white.withAlphaComponent(0.8)
    let exceededColor = UIColor.ksr_red_400

    self.chatInputViewMessageLengthCountLabelText.assertValues(["140"])
    self.chatInputViewMessageLengthCountLabelTextColor.assertValues([normalColor])
    self.sendButtonEnabled.assertValues([false])

    self.vm.inputs.textDidChange(toText: fiftyCharString)

    self.chatInputViewMessageLengthCountLabelText.assertValues(["140", "90"])
    self.chatInputViewMessageLengthCountLabelTextColor.assertValues([normalColor])
    self.sendButtonEnabled.assertValues([false, true])

    self.vm.inputs.textDidChange(toText: oneFortyCharString)

    self.chatInputViewMessageLengthCountLabelText.assertValues(["140", "90", "0"])
    self.chatInputViewMessageLengthCountLabelTextColor.assertValues([normalColor])
    self.sendButtonEnabled.assertValues([false, true])

    self.vm.inputs.textDidChange(toText: oneFortyOneCharString)

    self.chatInputViewMessageLengthCountLabelText.assertValues(["140", "90", "0", "-1"])
    self.chatInputViewMessageLengthCountLabelTextColor.assertValues([normalColor, exceededColor])
    self.sendButtonEnabled.assertValues([false, true, false])

    self.vm.inputs.textDidChange(toText: twoHundredCharString)

    self.chatInputViewMessageLengthCountLabelText.assertValues(["140", "90", "0", "-1", "-60"])
    self.chatInputViewMessageLengthCountLabelTextColor.assertValues([normalColor, exceededColor])
    self.sendButtonEnabled.assertValues([false, true, false])

    self.vm.inputs.textDidChange(toText: fiftyCharString)

    self.chatInputViewMessageLengthCountLabelText.assertValues(["140", "90", "0", "-1", "-60", "90"])
    self.chatInputViewMessageLengthCountLabelTextColor.assertValues([normalColor, exceededColor, normalColor])
    self.sendButtonEnabled.assertValues([false, true, false, true])
  }
}
