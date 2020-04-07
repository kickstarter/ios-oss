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
    self.projectName = self.backingSignal
      .map(\.project?.name)
      .skipNil()

    let collectionDate = self.backingSignal
      .map(\.project?.finalCollectionDate)
      .skipNil()

    self.finalCollectionDateText = collectionDate
      .map { timeLeftString(date: $0) }
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

  public let finalCollectionDateText: Signal<String, Never>
  public let notifyDelegateManageButtonTapped: Signal<GraphBacking, Never>
  public let projectName: Signal<String, Never>

  public var inputs: ErroredBackingViewViewModelInputs { return self }
  public var outputs: ErroredBackingViewViewModelOutputs { return self }
}

private func timeLeftString(date: String) -> String? {
  let dateFormatter = ISO8601DateFormatter.cachedFormatter()
  guard let finalCollectionDate = dateFormatter.date(from: date) else { return nil }

  let timeInterval = finalCollectionDate.timeIntervalSince1970

  let (time, unit) = timeLeft(
    secondsInUTC: timeInterval
  )
  return Strings.Time_left_left(time_left: time + " " + unit)
}

private func timeLeft(
  secondsInUTC seconds: TimeInterval,
  env: Environment = AppEnvironment.current
)
  -> (time: String, unit: String) {
  let components = env.calendar.dateComponents(
    [.day, .hour],
    from: env.dateType.init().date,
    to: env.dateType.init(timeIntervalSince1970: seconds).date
  )

  let (day, hour) = (
    components.day ?? 0,
    components.hour ?? 0
  )

  let string: String
  if day > 1 {
    string = Strings.dates_time_days(time_count: day)
  } else if day == 1 || hour > 0 {
    let count = day * 24 + hour
    string = Strings.dates_time_hours(time_count: count)
  } else if hour <= 1 {
    let count = 1
    string = Strings.dates_time_hours(time_count: count)
  } else {
    string = ""
  }

  let split = string
    .replacingOccurrences(of: "(\\d+) *", with: "$1 ", options: .regularExpression)
    .components(separatedBy: " ")

  guard split.count >= 1 else { return ("", "") }

  let result = (
    time: split.first ?? "",
    unit: split.suffix(from: 1).joined(separator: " ")
  )

  return result
}
