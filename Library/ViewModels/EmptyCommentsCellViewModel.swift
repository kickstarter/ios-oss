import KsApi
import Prelude
import ReactiveSwift

public protocol EmptyCommentsCellViewModelInputs {
  /// Call to configure cell with the project
  func configureWith(project: Project?)
}

public protocol EmptyCommentsCellViewModelOutputs {
  /// Emits author's badge for a comment.
  var emptyText: Signal<String, Never> { get }
}

public protocol EmptyCommentsCellViewModelType {
  var inputs: EmptyCommentsCellViewModelInputs { get }
  var outputs: EmptyCommentsCellViewModelOutputs { get }
}

public final class EmptyCommentsCellViewModel:
  EmptyCommentsCellViewModelType, EmptyCommentsCellViewModelInputs, EmptyCommentsCellViewModelOutputs {
  public init() {
    self.emptyText = self.configured.signal.map { _ in Strings.No_comments_yet() }
  }

  // TODO: Not needed but maybe later we want to personalize the empty comments state of each project.
  fileprivate let configured = MutableProperty<Project?>(nil)
  public func configureWith(project: Project?) {
    self.configured.value = project
  }

  public let emptyText: Signal<String, Never>

  public var inputs: EmptyCommentsCellViewModelInputs { self }
  public var outputs: EmptyCommentsCellViewModelOutputs { self }
}
