import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude

public protocol LiveStreamCountdownViewModelType {
  var inputs: LiveStreamCountdownViewModelInputs { get }
  var outputs: LiveStreamCountdownViewModelOutputs { get }
}

public protocol LiveStreamCountdownViewModelInputs {
  func configureWith(project project: Project, now: NSDate?)
  func setNow(date: NSDate)
  func viewDidLoad()
}

public protocol LiveStreamCountdownViewModelOutputs {
  var categoryId: Signal<Int, NoError> { get }
  var daysString: Signal<(String, String), NoError> { get }
  var hoursString: Signal<(String, String), NoError> { get }
  var minutesString: Signal<(String, String), NoError> { get }
  var secondsString: Signal<(String, String), NoError> { get }
  var projectImageUrl: Signal<NSURL, NoError> { get }
}

public final class LiveStreamCountdownViewModel: LiveStreamCountdownViewModelType,
LiveStreamCountdownViewModelInputs, LiveStreamCountdownViewModelOutputs {

  public init() {
    let project = combineLatest(
      self.projectProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal)
      .map(first)

    // TODO: replace with project's live stream date once we have that in the model
    let components = NSDateComponents()
    components.year = 2017
    components.day = 5
    components.month = 1
    components.hour = 8

    let date = NSCalendar.currentCalendar().dateFromComponents(components)!

    let dateComponents = combineLatest(
      project.mapConst(date),
      self.nowProperty.signal.ignoreNil()
      )
      .map {
        NSCalendar.currentCalendar().components(
          [.Day, .Hour, .Minute, .Second],
          fromDate: $1,
          toDate: $0,
          options: []
        )
    }

    self.daysString = dateComponents
      .map { $0.day }
      .skipRepeats()
      .filter { $0 >= 0 }
      .map { (String(format: "%02d", $0), "days") }

    self.hoursString = dateComponents
      .map { $0.hour }
      .skipRepeats()
      .filter { $0 >= 0 }
      .map { (String(format: "%02d", $0), "hours") }

    self.minutesString = dateComponents
      .map { $0.minute }
      .skipRepeats()
      .filter { $0 >= 0 }
      .map { (String(format: "%02d", $0), "minutes") }

    self.secondsString = dateComponents
      .map { $0.second }
      .skipRepeats()
      .filter { $0 >= 0 }
      .map { (String(format: "%02d", $0), "seconds") }

    self.projectImageUrl = project
      .map { NSURL(string: $0.photo.full) }
      .ignoreNil()

    self.categoryId = project.map { $0.category.color }.ignoreNil()
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project, now: NSDate? = NSDate()) {
    self.projectProperty.value = project
    self.nowProperty.value = now
  }

  private let nowProperty = MutableProperty<NSDate?>(nil)
  public func setNow(date: NSDate) {
    self.nowProperty.value = date
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let categoryId: Signal<Int, NoError>
  public let daysString: Signal<(String, String), NoError>
  public let hoursString: Signal<(String, String), NoError>
  public let minutesString: Signal<(String, String), NoError>
  public let projectImageUrl: Signal<NSURL, NoError>
  public let secondsString: Signal<(String, String), NoError>

  public var inputs: LiveStreamCountdownViewModelInputs { return self }
  public var outputs: LiveStreamCountdownViewModelOutputs { return self }
}