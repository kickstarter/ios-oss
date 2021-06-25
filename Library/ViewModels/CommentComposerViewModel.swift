import Foundation
import KsApi
import ReactiveSwift

public typealias CommentComposerViewData = (
  avatarURL: URL?,
  canPostComment: Bool,
  hidden: Bool,
  becomeFirstResponder: Bool
)

public enum CommentComposerConstant {
  // The API only supports comments not more than 9000 characters
  public static let characterLimit: Int = 9_000
}

public protocol CommentComposerViewModelInputs {
  /// Call when the comment text changes.
  func bodyTextDidChange(_ text: String?)

  /// Call to configure composer avatar and input area visibility
  func configure(with data: CommentComposerViewData)

  /// Call when the post button is pressed.
  func postButtonPressed()

  /// Call when the input textview of the composer should be reset.
  func resetInput()

  /// Call in `textView(_:shouldChangeTextIn:replacementText:)` `UITextViewDelegate` method.
  func textViewShouldChange(text: String?, in range: NSRange, replacementText: String) -> Bool
}

public protocol CommentComposerViewModelOutputs {
  /// Emits the URL to be used to load user's avatar
  var avatarURL: Signal<URL?, Never> { get }

  /// Emits a string that should be put into the body text view.
  var bodyText: Signal<String?, Never> { get }

  /// Emits when input text view's text should be cleared
  var clearInputTextView: Signal<(), Never> { get }

  /// Emits a boolean that determines if the comment composer view is hidden.
  var commentComposerHidden: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the input area is hidden.
  var inputAreaHidden: Signal<Bool, Never> { get }

  /// Emits when the input textview should become first responder.
  var inputTextViewDidBecomeFirstResponder: Signal<Bool, Never> { get }

  /// Emits when composer notifies view controller of comment submitted.
  var notifyDelegateDidSubmitText: Signal<String, Never> { get }

  /// Emits a boolean that determines if the placeholder label is hidden.
  var placeholderHidden: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the post button is hidden.
  var postButtonHidden: Signal<Bool, Never> { get }

  /// Emits when the input area size should be reset.
  var updateTextViewHeight: Signal<(), Never> { get }
}

public protocol CommentComposerViewModelType {
  var inputs: CommentComposerViewModelInputs { get }
  var outputs: CommentComposerViewModelOutputs { get }
}

public final class CommentComposerViewModel:
  CommentComposerViewModelType,
  CommentComposerViewModelInputs,
  CommentComposerViewModelOutputs {
  public init() {
    self.avatarURL = self.configDataProperty.signal.skipNil().map(\.avatarURL)
    self.bodyText = Signal.merge(
      self.bodyTextDidChangeProperty.signal,
      self.resetInputProperty.signal.mapConst(nil)
    )
    self.inputAreaHidden = self.configDataProperty.signal.skipNil().map(\.canPostComment).negate()

    self.commentComposerHidden = self.configDataProperty.signal.skipNil().map(\.hidden)

    self.notifyDelegateDidSubmitText = self.bodyText.skipNil()
      .takeWhen(self.postButtonPressedProperty.signal)
      .map { $0.trimmed() }

    self.placeholderHidden = Signal.merge(
      self.configDataProperty.signal.mapConst(false).take(first: 1),
      self.bodyText.map { $0?.isEmpty == false }
    )

    self.postButtonHidden = Signal.merge(
      self.configDataProperty.signal.mapConst(true).take(first: 1),
      self.bodyText.map { $0?.trimmed().isEmpty ?? true }
    )

    self.textViewShouldChangeReturnProperty <~ self.textViewShouldChangeProperty.signal.skipNil()
      .map { text, range, replacementText in
        let currentText = text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: replacementText)
        return updatedText.trimmed().count <= CommentComposerConstant.characterLimit
      }

    self.inputTextViewDidBecomeFirstResponder = Signal.merge(
      self.configDataProperty.signal.skipNil().map(\.becomeFirstResponder),
      self.resetInputProperty.signal.map { false }
    )

    self.updateTextViewHeight = self.bodyText.signal.ignoreValues()
    self.clearInputTextView = self.bodyText.filter { $0 == nil }.ignoreValues()
  }

  private let bodyTextDidChangeProperty = MutableProperty<String?>(nil)
  public func bodyTextDidChange(_ text: String?) {
    self.bodyTextDidChangeProperty.value = text
  }

  private let configDataProperty = MutableProperty<CommentComposerViewData?>(nil)
  public func configure(with data: CommentComposerViewData) {
    self.configDataProperty.value = data
  }

  private let postButtonPressedProperty = MutableProperty(())
  public func postButtonPressed() {
    self.postButtonPressedProperty.value = ()
  }

  fileprivate let resetInputProperty = MutableProperty(())
  public func resetInput() {
    self.resetInputProperty.value = ()
  }

  private let textViewShouldChangeProperty = MutableProperty<(String?, NSRange, String)?>(nil)
  private let textViewShouldChangeReturnProperty = MutableProperty<Bool>(false)
  public func textViewShouldChange(text: String?, in range: NSRange, replacementText: String) -> Bool {
    self.textViewShouldChangeProperty.value = (text, range, replacementText)
    return self.textViewShouldChangeReturnProperty.value
  }

  public var avatarURL: Signal<URL?, Never>
  public var bodyText: Signal<String?, Never>
  public var clearInputTextView: Signal<(), Never>
  public var commentComposerHidden: Signal<Bool, Never>
  public var inputAreaHidden: Signal<Bool, Never>
  public var inputTextViewDidBecomeFirstResponder: Signal<Bool, Never>
  public var notifyDelegateDidSubmitText: Signal<String, Never>
  public var placeholderHidden: Signal<Bool, Never>
  public var postButtonHidden: Signal<Bool, Never>
  public var updateTextViewHeight: Signal<(), Never>

  public var inputs: CommentComposerViewModelInputs { return self }
  public var outputs: CommentComposerViewModelOutputs { return self }
}
