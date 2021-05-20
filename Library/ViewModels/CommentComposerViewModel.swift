import Foundation
import KsApi
import ReactiveSwift

public typealias CommentComposerViewData = (avatarURL: URL?, isBackingProject: Bool)
private let characterLimit: Int = 9_000

public protocol CommentComposerViewModelInputs {
  /// Call to configure composer avatar and input area visibility
  func configure(with data: CommentComposerViewData)

  /// Call when the comment text changes.
  func bodyTextDidChange(_ text: String)

  /// Call when the post button is pressed.
  func postButtonPressed()

  /// Call in  `textView(_:shouldChangeTextIn:replacementText:)` UITextView delegate method.
  func textViewShouldChange(text: String?, in range: NSRange, replacementText: String) -> Bool
}

public protocol CommentComposerViewModelOutputs {
  /// Emits a string that should be put into the body text view.
  var bodyText: Signal<String, Never> { get }

  /// Emits the URL to be used to load user's avatar
  var avatarURL: Signal<URL?, Never> { get }

  /// Emits a boolean that determines if the input area is hidden.
  var inputAreaHidden: Signal<Bool, Never> { get }

  /// Emits when composer notifies view controller of comment submitted.
  var notifyDelegateDidSubmitText: Signal<String, Never> { get }

  /// Emits a boolean that determines if the post button is hidden.
  var postButtonHidden: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the placeholder label is hidden.
  var placeholderHidden: Signal<Bool, Never> { get }
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
    self.bodyText = self.bodyTextDidChangeProperty.signal.skipNil()
    self.avatarURL = self.configDataProperty.signal.skipNil().map(\.avatarURL)
    self.inputAreaHidden = self.configDataProperty.signal.skipNil().map(\.isBackingProject).negate()

    self.notifyDelegateDidSubmitText = self.bodyText
      .takeWhen(self.postButtonPressedProperty.signal)
      .map { $0.trimmed() }

    self.placeholderHidden = Signal.merge(
      self.configDataProperty.signal.mapConst(false).take(first: 1),
      self.bodyText.map { !$0.isEmpty }
    )

    self.postButtonHidden = Signal.merge(
      self.configDataProperty.signal.mapConst(true).take(first: 1),
      self.bodyText.map { $0.trimmed().isEmpty }
    )

    self.textViewShouldChangeReturnProperty <~ self.textViewShouldChangeProperty.signal.skipNil()
      .map { text, range, replacementText in
        let currentText = text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: replacementText)
        return updatedText.trimmed().count <= characterLimit
      }
  }

  private let configDataProperty = MutableProperty<CommentComposerViewData?>(nil)
  public func configure(with data: CommentComposerViewData) {
    self.configDataProperty.value = data
  }

  private let bodyTextDidChangeProperty = MutableProperty<String?>(nil)
  public func bodyTextDidChange(_ text: String) {
    self.bodyTextDidChangeProperty.value = text
  }

  private let postButtonPressedProperty = MutableProperty(())
  public func postButtonPressed() {
    self.postButtonPressedProperty.value = ()
  }

  private let textViewShouldChangeProperty = MutableProperty<(String?, NSRange, String)?>(nil)
  private let textViewShouldChangeReturnProperty = MutableProperty<Bool>(false)
  public func textViewShouldChange(text: String?, in range: NSRange, replacementText: String) -> Bool {
    self.textViewShouldChangeProperty.value = (text, range, replacementText)
    return self.textViewShouldChangeReturnProperty.value
  }

  public var bodyText: Signal<String, Never>
  public var avatarURL: Signal<URL?, Never>
  public var inputAreaHidden: Signal<Bool, Never>
  public var notifyDelegateDidSubmitText: Signal<String, Never>
  public var postButtonHidden: Signal<Bool, Never>
  public var placeholderHidden: Signal<Bool, Never>

  public var inputs: CommentComposerViewModelInputs { return self }
  public var outputs: CommentComposerViewModelOutputs { return self }
}
