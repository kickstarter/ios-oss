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
  /// Call when the view lays out its subviews
  func layoutSubviews()

  /// Call when more button was tapped
  func moreButtonTapped()

  /// Call when send button was tapped
  func sendButtonTapped()

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

  /// Emits when the send button should be hidden
  var sendButtonHidden: Signal<Bool, NoError> { get }
}

public final class LiveStreamChatInputViewModel: LiveStreamChatInputViewModelType,
LiveStreamChatInputViewModelInputs, LiveStreamChatInputViewModelOutputs {

  public init() {
    let textIsEmpty = Signal.merge(
      self.textProperty.signal.skipNil()
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .map { $0.isEmpty },
      self.layoutSubviewsProperty.signal.take(first: 1).mapConst(true),
      self.sendButtonTappedProperty.signal.mapConst(true)
      )

    self.moreButtonHidden = textIsEmpty.map(negate)
    self.sendButtonHidden = textIsEmpty

    self.notifyDelegateMoreButtonTapped = self.moreButtonTappedProperty.signal

    self.notifyDelegateMessageSent = self.textProperty.signal.skipNil()
      .takeWhen(self.sendButtonTappedProperty.signal)
  }

  private let layoutSubviewsProperty = MutableProperty()
  public func layoutSubviews() {
    self.layoutSubviewsProperty.value = ()
  }

  private let moreButtonTappedProperty = MutableProperty()
  public func moreButtonTapped() {
    self.moreButtonTappedProperty.value = ()
  }

  private let sendButtonTappedProperty = MutableProperty()
  public func sendButtonTapped() {
    self.sendButtonTappedProperty.value = ()
  }

  private let textProperty = MutableProperty<String?>(nil)
  public func textDidChange(toText text: String) {
    self.textProperty.value = text
  }

  public let moreButtonHidden: Signal<Bool, NoError>
  public var notifyDelegateMessageSent: Signal<String, NoError>
  public var notifyDelegateMoreButtonTapped: Signal<(), NoError>
  public let sendButtonHidden: Signal<Bool, NoError>

  public var inputs: LiveStreamChatInputViewModelInputs { return self }
  public var outputs: LiveStreamChatInputViewModelOutputs { return self }
}
