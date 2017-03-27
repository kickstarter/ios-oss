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
  /// Call when the view did awake from nib
  func didAwakeFromNib()

  /// Call when send button was tapped
  func sendButtonTapped()

  /// Call when the text field should begin editing
  func textFieldShouldBeginEditing() -> Bool

  /// Call with new value from the input field
  func textDidChange(toText text: String)
}

public protocol LiveStreamChatInputViewModelOutputs {
  /// Emits when the keyboard should dismiss.
  var clearTextFieldAndResignFirstResponder: Signal<(), NoError> { get }

  /// Emits when the message should be sent and the text field cleared
  var notifyDelegateMessageSent: Signal<String, NoError> { get }

  /// Emits when the user taps into the text field when not logged in
  var notifyDelegateRequestLogin: Signal<(), NoError> { get }

  /// Emits the placeholder text
  var placeholderText: Signal<NSAttributedString, NoError> { get }

  /// Emits when the send button should be hidden
  var sendButtonEnabled: Signal<Bool, NoError> { get }
}

public final class LiveStreamChatInputViewModel: LiveStreamChatInputViewModelType,
LiveStreamChatInputViewModelInputs, LiveStreamChatInputViewModelOutputs {

  public init() {
    let textIsEmpty = Signal.merge(
      self.textProperty.signal.skipNil()
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .map { $0.isEmpty },
      self.sendButtonTappedProperty.signal.mapConst(true)
      )

    self.sendButtonEnabled = Signal.merge(
      self.didAwakeFromNibProperty.signal.mapConst(false),
      textIsEmpty.map(negate)
    )

    self.notifyDelegateMessageSent = self.textProperty.signal.skipNil()
      .takeWhen(self.sendButtonTappedProperty.signal)

    self.clearTextFieldAndResignFirstResponder = self.notifyDelegateMessageSent.signal.ignoreValues()

    self.notifyDelegateRequestLogin = self.textFieldShouldBeginEditingProperty.signal
      .filter { AppEnvironment.current.currentUser == nil }

    self.placeholderText = self.didAwakeFromNibProperty.signal
      .map {
        NSAttributedString(
          string: localizedString(key: "Say_something_kind", defaultValue: "Say something kind..."),
          attributes: [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8),
            NSFontAttributeName: UIFont.ksr_body(size: 14)
          ]
        )
    }

    self.textFieldShouldBeginEditingReturnValueProperty <~ self.textFieldShouldBeginEditingProperty.map {
      return AppEnvironment.current.currentUser != nil
    }
  }

  private let didAwakeFromNibProperty = MutableProperty()
  public func didAwakeFromNib() {
    self.didAwakeFromNibProperty.value = ()
  }

  private let sendButtonTappedProperty = MutableProperty()
  public func sendButtonTapped() {
    self.sendButtonTappedProperty.value = ()
  }

  private let textFieldShouldBeginEditingProperty = MutableProperty()
  private let textFieldShouldBeginEditingReturnValueProperty = MutableProperty<Bool>(false)
  public func textFieldShouldBeginEditing() -> Bool {
    self.textFieldShouldBeginEditingProperty.value = ()
    return self.textFieldShouldBeginEditingReturnValueProperty.value
  }

  private let textProperty = MutableProperty<String?>(nil)
  public func textDidChange(toText text: String) {
    self.textProperty.value = text
  }

  public let clearTextFieldAndResignFirstResponder: Signal<(), NoError>
  public let notifyDelegateMessageSent: Signal<String, NoError>
  public let notifyDelegateRequestLogin: Signal<(), NoError>
  public let placeholderText: Signal<NSAttributedString, NoError>
  public let sendButtonEnabled: Signal<Bool, NoError>

  public var inputs: LiveStreamChatInputViewModelInputs { return self }
  public var outputs: LiveStreamChatInputViewModelOutputs { return self }
}
