import KsApi
import ReactiveSwift

public enum CommentTableViewFooterViewState {
  case activity
  case error
  case hidden
}

public protocol CommentTableViewFooterViewModelInputs {
  func configure(with value: CommentTableViewFooterViewState)
}

public protocol CommentTableViewFooterViewModelOutputs {
  var activityIndicatorHidden: Signal<Bool, Never> { get }
  var bottomInsetHeight: Signal<Int, Never> { get }
  var retryButtonHidden: Signal<Bool, Never> { get }
  var rootStackViewHidden: Signal<Bool, Never> { get }
}

public protocol CommentTableViewFooterViewModelType {
  var inputs: CommentTableViewFooterViewModelInputs { get }
  var outputs: CommentTableViewFooterViewModelOutputs { get }
}

public final class CommentTableViewFooterViewModel: CommentTableViewFooterViewModelType,
  CommentTableViewFooterViewModelInputs, CommentTableViewFooterViewModelOutputs {
  public init() {
    let state = self.stateProperty.signal.skipNil()

    self.activityIndicatorHidden = state.map { $0 == .activity }.negate()
    self.retryButtonHidden = state.map { $0 == .error }.negate()
    self.rootStackViewHidden = state.map { $0 == .hidden }

    // When the button is visible its content is aligned to top which pushes the text down
    // requiring more space at the bottom.
    self.bottomInsetHeight = state.map { state -> Int in
      if case .error = state { return 4 }
      return 2
    }
  }

  private let stateProperty = MutableProperty<CommentTableViewFooterViewState?>(nil)
  public func configure(with value: CommentTableViewFooterViewState) {
    self.stateProperty.value = value
  }

  public let activityIndicatorHidden: Signal<Bool, Never>
  public let bottomInsetHeight: Signal<Int, Never>
  public let retryButtonHidden: Signal<Bool, Never>
  public let rootStackViewHidden: Signal<Bool, Never>

  public var inputs: CommentTableViewFooterViewModelInputs { return self }
  public var outputs: CommentTableViewFooterViewModelOutputs { return self }
}
