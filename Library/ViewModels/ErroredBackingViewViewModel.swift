import KsApi
import ReactiveSwift

public protocol ErroredBackingViewViewModelInputs {
  func configure(with value: GraphBacking)
  func manageButtonTapped()
}

public protocol ErroredBackingViewViewModelOutputs {
  var notifyDelegateManageButtonTapped: Signal<GraphBacking, Never> { get }
  var projectName: Signal<String, Never> { get }
  var finalCollection: Signal<String, Never> { get }
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

    self.finalCollection = project
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

  public let notifyDelegateManageButtonTapped: Signal<GraphBacking, Never>
  public let projectName: Signal<String, Never>
  public let finalCollection: Signal<String, Never>

  public var inputs: ErroredBackingViewViewModelInputs { return self }
  public var outputs: ErroredBackingViewViewModelOutputs { return self }
}

private func timeLeftString(date: String?) -> String {
  let dateFormatter = ISO8601DateFormatter()
  let currentDate = Date()

  guard let date = date else {
    let count = 0
    return Strings.Time_left_left(time_left: "\(count)" + " " + "days")
  }
  guard let finalCollectionDate = dateFormatter.date(from: date) else {
    let count = 0
    return Strings.Time_left_left(time_left: "\(count)" + " " + "days")
  }

  let timeInterval = currentDate.timeIntervalSince(finalCollectionDate)

  let (time, unit) = daysLeft(
    secondsInUTC: timeInterval
  )

   return Strings.Time_left_left(time_left: time + " " + unit)
}

private func daysLeft(
   secondsInUTC seconds: TimeInterval,
   env: Environment = AppEnvironment.current
 ) -> (time: String, unit: String) {
   let components = env.calendar.dateComponents(
    [.day, .hour, .minute, .second],
     from: env.dateType.init().date,
     to: env.dateType.init(timeIntervalSince1970: seconds).date
   )

   let (day, hour, minute, second) = (
    components.day ?? 0,
    components.hour ?? 0,
    components.minute ?? 0,
    components.second ?? 0
  )

   let string: String
   if day > 1 {
       string = Strings.dates_time_days(time_count: day)
   } else if day == 1 || hour > 0 {
       let count = 1
       string = Strings.dates_time_days(time_count: count)
   } else if minute > 0, second >= 0 {
      let count = 1
      string = Strings.dates_time_days(time_count: count)
   } else if second <= 0 {
      let count = 0
      string = Strings.dates_time_days(time_count: count)
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
