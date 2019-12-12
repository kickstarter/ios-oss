import KsApi
import ReactiveSwift

public protocol ErroredBackingViewViewModelInputs {
  func configure(with value: GraphBacking)
  func manageButtonTapped()
}

public protocol ErroredBackingViewViewModelOutputs {
  var notifyDelegateManageButtonTapped: Signal<GraphBacking, Never> { get }
  var projectName: Signal<String, Never> { get }
}

public protocol ErroredBackingViewViewModelType {
  var inputs: ErroredBackingViewViewModelInputs { get }
  var outputs: ErroredBackingViewViewModelOutputs { get }
}

public final class ErroredBackingViewViewModel: ErroredBackingViewViewModelType,
  ErroredBackingViewViewModelInputs, ErroredBackingViewViewModelOutputs {
  public init() {
    self.projectName = self.backingSignal
      .map(\.project?.name)
      .skipNil()

    self.notifyDelegateManageButtonTapped = self.backingSignal
      .takeWhen(self.manageButtonTappedSignal)
  }

  private let (backingSignal, backingObserver) = Signal<GraphBacking, Never>.pipe()
  public func configure(with value: GraphBacking) {
    self.backingObserver.send(value: value)
  }

  private let (manageButtonTappedSignal, manageButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func manageButtonTapped() {
    self.manageButtonTappedObserver.send(value: ())
  }

  public let notifyDelegateManageButtonTapped: Signal<GraphBacking, Never>
  public let projectName: Signal<String, Never>

  public var inputs: ErroredBackingViewViewModelInputs { return self }
  public var outputs: ErroredBackingViewViewModelOutputs { return self }
}
