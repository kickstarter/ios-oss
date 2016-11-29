import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude
import KsLive

public protocol LiveStreamCountdownViewModelType {
  var inputs: LiveStreamCountdownViewModelInputs { get }
  var outputs: LiveStreamCountdownViewModelOutputs { get }
}

public protocol LiveStreamCountdownViewModelInputs {
  func closeButtonTapped()
  func configureWith(project project: Project, now: NSDate?)
  func setLiveStreamEvent(event event: LiveStreamEvent)
  func setNow(date date: NSDate)
  func subscribeButtonTapped()
  func setSubcribed(subscribed subscribed: Bool)
  func viewDidLoad()
}

public protocol LiveStreamCountdownViewModelOutputs {
  var categoryId: Signal<Int, NoError> { get }
  var creatorAvatarUrl: Signal<NSURL, NoError> { get }
  var creatorName: Signal<String, NoError> { get }
  var daysString: Signal<(String, String), NoError> { get }
  var description: Signal<String, NoError> { get }
  var dismiss: Signal<(), NoError> { get }
  var hoursString: Signal<(String, String), NoError> { get }
  var introText: Signal<String, NoError> { get }
  var minutesString: Signal<(String, String), NoError> { get }
  var projectImageUrl: Signal<NSURL, NoError> { get }
  var retrieveEventInfo: Signal<String, NoError> { get }
  var secondsString: Signal<(String, String), NoError> { get }
  var showActivityIndicator: Signal<Bool, NoError> { get }
  var showSubscribeButtonActivityIndicator: Signal<Bool, NoError> { get }
  var subscribeButtonText: Signal<String, NoError> { get }
  var subscribeButtonImage: Signal<UIImage?, NoError> { get }
  var subscribed: Signal<Bool, NoError> { get }
  var title: Signal<String, NoError> { get }
  var toggleSubscribe: Signal<(), NoError> { get }
  var viewControllerTitle: Signal<String, NoError> { get }
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

    self.categoryId = project.map { $0.category.rootId }.ignoreNil()
    self.dismiss = self.closeButtonTappedProperty.signal
    self.viewControllerTitle = viewDidLoadProperty.signal.mapConst("Livestream countdown")

    self.retrieveEventInfo = project.map { String($0.id) }
    self.subscribed = Signal.merge(
      self.subscribedProperty.signal,
      self.liveStreamEventProperty.signal.ignoreNil().map { $0.stream.isSubscribed }
    )

    self.introText = self.liveStreamEventProperty.signal.ignoreNil().mapConst("Upcoming")
    self.creatorAvatarUrl = self.liveStreamEventProperty.signal.ignoreNil()
      .map { NSURL(string: $0.creator.avatar) }
      .ignoreNil()
    self.creatorName = self.liveStreamEventProperty.signal.ignoreNil().map { $0.creator.name }
    self.title = self.liveStreamEventProperty.signal.ignoreNil().map { $0.stream.projectName }
    self.description = self.liveStreamEventProperty.signal.ignoreNil().map { $0.stream.description }

    self.subscribeButtonImage = self.subscribed.map {
      $0 ? UIImage(named: "postcard-checkmark") : nil
    }

    self.subscribeButtonText = self.subscribed.map {
      $0 ? "Subscribed" : "Subscribe"
    }

    self.showActivityIndicator = Signal.merge(
      self.retrieveEventInfo.mapConst(true),
      self.liveStreamEventProperty.signal.ignoreNil().mapConst(false)
    )

    self.showSubscribeButtonActivityIndicator = Signal.merge(
      self.subscribed.mapConst(false),
      self.subscribeButtonTappedProperty.signal.mapConst(true)
    )

    self.toggleSubscribe = self.subscribeButtonTappedProperty.signal
  }

  private let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project, now: NSDate? = NSDate()) {
    self.projectProperty.value = project
    self.nowProperty.value = now
  }

  private let nowProperty = MutableProperty<NSDate?>(nil)
  public func setNow(date date: NSDate) {
    self.nowProperty.value = date
  }

  private let liveStreamEventProperty = MutableProperty<LiveStreamEvent?>(nil)
  public func setLiveStreamEvent(event event: LiveStreamEvent) {
    self.liveStreamEventProperty.value = event
  }

  private let subscribedProperty = MutableProperty(false)
  public func setSubcribed(subscribed subscribed: Bool) {
    self.subscribedProperty.value = subscribed
  }

  private let subscribeButtonTappedProperty = MutableProperty()
  public func subscribeButtonTapped() {
    self.subscribeButtonTappedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let categoryId: Signal<Int, NoError>
  public let creatorAvatarUrl: Signal<NSURL, NoError>
  public let creatorName: Signal<String, NoError>
  public let daysString: Signal<(String, String), NoError>
  public let description: Signal<String, NoError>
  public let dismiss: Signal<(), NoError>
  public let hoursString: Signal<(String, String), NoError>
  public let introText: Signal<String, NoError>
  public let minutesString: Signal<(String, String), NoError>
  public let projectImageUrl: Signal<NSURL, NoError>
  public let retrieveEventInfo: Signal<String, NoError>
  public let secondsString: Signal<(String, String), NoError>
  public let showActivityIndicator: Signal<Bool, NoError>
  public let showSubscribeButtonActivityIndicator: Signal<Bool, NoError>
  public let subscribeButtonText: Signal<String, NoError>
  public let subscribeButtonImage: Signal<UIImage?, NoError>
  public let subscribed: Signal<Bool, NoError>
  public let toggleSubscribe: Signal<(), NoError>
  public let title: Signal<String, NoError>
  public let viewControllerTitle: Signal<String, NoError>

  public var inputs: LiveStreamCountdownViewModelInputs { return self }
  public var outputs: LiveStreamCountdownViewModelOutputs { return self }
}