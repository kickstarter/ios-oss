import LiveStream
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol LiveStreamChatInputViewModelType {
  var inputs: LiveStreamChatInputViewModelInputs { get }
  var outputs: LiveStreamChatInputViewModelOutputs { get }
}

public protocol LiveStreamChatInputViewModelInputs {
  /// Call with the chat view controller's visibility status
  func configureWith(chatHidden: Bool)

  /// Call when the chat view controller's visibility was changed
  func didSetChatHidden(hidden: Bool)

  /// Call when more button was tapped
  func moreButtonTapped()

  /// Call when send button was tapped
  func sendButtonTapped()

  /// Call when the text field should begin editing
  func textFieldShouldBeginEditing()

  /// Call with new value from the input field
  func textDidChange(toText text: String)
}

public protocol LiveStreamChatInputViewModelOutputs {
  /// Emits when the more button should be hidden
  var moreButtonHidden: Signal<Bool, NoError> { get }

  /// Emits when the message should be sent and the text field cleared
  var notifyDelegateMessageSent: Signal<String, NoError> { get }

  /// Emits when the message should be sent and the text field cleared
  var notifyDelegateMoreButtonTapped: Signal<(), NoError> { get }

  /// Emits when the user taps into the text field when not logged in
  var notifyDelegateRequestLogin: Signal<(), NoError> { get }

  /// Emits the placeholder text
  var placeholderText: Signal<NSAttributedString, NoError> { get }

  /// Emits when the send button should be hidden
  var sendButtonHidden: Signal<Bool, NoError> { get }
}

public final class LiveStreamChatInputViewModel: LiveStreamChatInputViewModelType,
LiveStreamChatInputViewModelInputs, LiveStreamChatInputViewModelOutputs {

  public init() {
    let configData = self.chatHiddenProperty.signal

    let textIsEmpty = Signal.merge(
      self.textProperty.signal.skipNil()
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .map { $0.isEmpty },
      configData.mapConst(true),
      self.sendButtonTappedProperty.signal.mapConst(true)
      )

    self.moreButtonHidden = textIsEmpty.map(negate)
    self.sendButtonHidden = textIsEmpty

    self.notifyDelegateMoreButtonTapped = self.moreButtonTappedProperty.signal

    self.notifyDelegateMessageSent = self.textProperty.signal.skipNil()
      .takeWhen(self.sendButtonTappedProperty.signal)

    self.notifyDelegateRequestLogin = self.textFieldShouldBeginEditingProperty.signal
      .filter { AppEnvironment.current.currentUser == nil }

    self.placeholderText = Signal.merge(
      configData,
      self.didSetChatHiddenProperty.signal
      )
      .map {
        return $0
          ? localizedString(key: "Chat_is_hidden", defaultValue: "Chat is hidden.")
          : localizedString(key: "Say_something_kind", defaultValue: "Say something kind...")
      }
      .map {
        return NSAttributedString(
          string: $0,
          attributes: [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8),
            NSFontAttributeName: UIFont.ksr_body(size: 14)
          ]
        )
    }
  }

  private let chatHiddenProperty = MutableProperty(false)
  public func configureWith(chatHidden: Bool) {
    self.chatHiddenProperty.value = chatHidden
  }

  private let didSetChatHiddenProperty = MutableProperty(false)
  public func didSetChatHidden(hidden: Bool) {
    self.didSetChatHiddenProperty.value = hidden
  }

  private let moreButtonTappedProperty = MutableProperty()
  public func moreButtonTapped() {
    self.moreButtonTappedProperty.value = ()
  }

  private let sendButtonTappedProperty = MutableProperty()
  public func sendButtonTapped() {
    self.sendButtonTappedProperty.value = ()
  }

  private let textFieldShouldBeginEditingProperty = MutableProperty()
  public func textFieldShouldBeginEditing() {
    self.textFieldShouldBeginEditingProperty.value = ()
  }

  private let textProperty = MutableProperty<String?>(nil)
  public func textDidChange(toText text: String) {
    self.textProperty.value = text
  }

  public let moreButtonHidden: Signal<Bool, NoError>
  public let notifyDelegateMessageSent: Signal<String, NoError>
  public let notifyDelegateMoreButtonTapped: Signal<(), NoError>
  public let notifyDelegateRequestLogin: Signal<(), NoError>
  public let placeholderText: Signal<NSAttributedString, NoError>
  public let sendButtonHidden: Signal<Bool, NoError>

  public var inputs: LiveStreamChatInputViewModelInputs { return self }
  public var outputs: LiveStreamChatInputViewModelOutputs { return self }
}
