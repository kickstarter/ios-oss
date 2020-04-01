import KsApi
import ReactiveSwift

public protocol ErroredBackingViewViewModelInputs {
  func configure(with value: GraphBacking)
  func manageButtonTapped()
}

public protocol ErroredBackingViewViewModelOutputs {
  var finalCollectionDateText: Signal<String, Never> { get }
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
    let project = self.backingSignal
      .map(\.project)
      .skipNil()

    self.projectName = self.backingSignal
      .map(\.project?.name)
      .skipNil()

    self.finalCollectionDateText = project
      .map { timeLeftString(date: $0.finalCollectionDate) }

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

  public let finalCollectionDateText: Signal<String, Never>
  public let notifyDelegateManageButtonTapped: Signal<GraphBacking, Never>
  public let projectName: Signal<String, Never>

  public var inputs: ErroredBackingViewViewModelInputs { return self }
  public var outputs: ErroredBackingViewViewModelOutputs { return self }
}

private func timeLeftString(date: String?) -> String {
  let dateFormatter = ISO8601DateFormatter()
  guard let date = date else { return "" }

  guard let finalCollectionDate = dateFormatter.date(from: date) else { return "" }

  let timeInterval = finalCollectionDate.timeIntervalSince1970

  let (time, unit) = Format.duration(
    secondsInUTC: timeInterval
  )
  return Strings.Time_left_left(time_left: time + " " + unit)
}
