import Foundation
import KsApi
import ReactiveSwift

public typealias CommentComposerViewData = (avatarURL: URL?, isBackingProject: Bool)

public protocol CommentComposerViewModelInputs {
  func configure(with data: CommentComposerViewData)
  func textDidChange(_ text: String)
  func postButtonPressed()
}

public protocol CommentComposerViewModelOutputs {
  var text: Signal<String, Never> { get }
  var avatarURL: Signal<URL?, Never> { get }
  var inputAreaVisible: Signal<Bool, Never> { get }
  var postComment: Signal<(), Never> { get }
  var inputEmpty: Signal<Bool, Never> { get }
}

public protocol CommentComposerViewModelType {
  var inputs: CommentComposerViewModelInputs { get }
  var outputs: CommentComposerViewModelOutputs { get }
}

public final class CommentComposerViewModel: CommentComposerViewModelType, CommentComposerViewModelInputs,
  CommentComposerViewModelOutputs {
  public init() {
    self.text = self.textDidChangeProperty.signal.skipNil()
    self.avatarURL = self.configDataProperty.signal.skipNil().map(\.avatarURL)
    self.inputAreaVisible = self.configDataProperty.signal.skipNil().map(\.isBackingProject)
    self.postComment = self.postButtonPressedProperty.signal
    self.inputEmpty = Signal.merge(
      self.configDataProperty.signal.mapConst(true).take(first: 1),
      self.text.map { $0.isEmpty }
    )
  }

  private let configDataProperty = MutableProperty<CommentComposerViewData?>(nil)
  public func configure(with data: CommentComposerViewData) {
    self.configDataProperty.value = data
  }

  private let textDidChangeProperty = MutableProperty<String?>(nil)
  public func textDidChange(_ text: String) {
    self.textDidChangeProperty.value = text
  }

  private let postButtonPressedProperty = MutableProperty(())
  public func postButtonPressed() {
    self.postButtonPressedProperty.value = ()
  }

  public var text: Signal<String, Never>
  public var avatarURL: Signal<URL?, Never>
  public var inputAreaVisible: Signal<Bool, Never>
  public var postComment: Signal<(), Never>
  public var inputEmpty: Signal<Bool, Never>

  public var inputs: CommentComposerViewModelInputs { return self }
  public var outputs: CommentComposerViewModelOutputs { return self }
}
