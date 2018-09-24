import KsApi
import LiveStream
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol LiveStreamContainerPageViewModelType {
  var inputs: LiveStreamContainerPageViewModelInputs { get }
  var outputs: LiveStreamContainerPageViewModelOutputs { get }
}

public protocol LiveStreamContainerPageViewModelInputs {
  /// Call to configure with the Project and LiveStreamEvent.
  func configureWith(project: Project, liveStreamEvent: LiveStreamEvent,
                     refTag: RefTag, presentedFromProject: Bool)

  /// Call when the chat button is tapped.
  func chatButtonTapped()

  /// Call when the view controllers have been loaded into the data source.
  func didLoadViewControllersIntoPagesDataSource()

  /// Call when the info button is tapped.
  func infoButtonTapped()

  /// Call when the UIPageViewController finishes transitioning.
  func pageTransition(completed: Bool)

  /// Call when the viewDidLoad.
  func viewDidLoad()

  /// Call when the UIPageViewController begins a transition sequence.
  func willTransition(toPage page: LiveStreamContainerPage)
}

public protocol LiveStreamContainerPageViewModelOutputs {
  /// Emits the text color for the chat button.
  var chatButtonTextColor: Signal<UIColor, NoError> { get }

  /// Emits the title font for the chat button.
  var chatButtonTitleFont: Signal<UIFont, NoError> { get }

  /// Emits whether the indicator line view should be hidden.
  var indicatorLineViewHidden: Signal<Bool, NoError> { get }

  /// Emits the X offset position for the indicator line view.
  var indicatorLineViewXPosition: Signal<Int, NoError> { get }

  /// Emits the text color for the info button.
  var infoButtonTextColor: Signal<UIColor, NoError> { get }

  /// Emits the title font for the info button.
  var infoButtonTitleFont: Signal<UIFont, NoError> { get }

  /// Emits the view controller page types to load into the data source.
  var loadViewControllersIntoPagesDataSource: Signal<[LiveStreamContainerPage], NoError> { get }

  /// Emits the page that should be paged to and in which direction.
  var pagedToPage: Signal<(LiveStreamContainerPage, UIPageViewController.NavigationDirection),
    NoError> { get }

  /// Emits whether the pager tab strip stack view should be hidden.
  var pagerTabStripStackViewHidden: Signal<Bool, NoError> { get }
}

public final class LiveStreamContainerPageViewModel: LiveStreamContainerPageViewModelType,
LiveStreamContainerPageViewModelInputs, LiveStreamContainerPageViewModelOutputs {

  public init() {
    let configData = Signal.combineLatest(
      self.configDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    ).map(first)

    self.loadViewControllersIntoPagesDataSource = configData
      .map { project, liveStreamEvent, refTag, presentedFromProject in
        let pages: [LiveStreamContainerPage] = [
          .info(project: project,
                liveStreamEvent: liveStreamEvent,
                refTag: refTag,
                presentedFromProject: presentedFromProject)
        ]

        guard AppEnvironment.current.config?.features["ios_live_stream_chat"] != .some(false) else {
          return pages
        }

        return pages + [
          .chat(project: project,
                liveStreamEvent: liveStreamEvent)
        ]
    }

    let infoButtonPage = self.loadViewControllersIntoPagesDataSource
      .map {
        $0.filter { $0.isInfoPage }.first
      }
      .skipNil()

    let chatButtonPage = self.loadViewControllersIntoPagesDataSource
      .map {
        $0.filter { $0.isChatPage }.first
      }
      .skipNil()

    let pageControllerPagedToPage = self.willTransitionToPageProperty.signal
      .skipNil()
      .takeWhen(self.pageTransitionCompletedProperty.signal.filter(isTrue))

    let firstPage = self.loadViewControllersIntoPagesDataSource
      .takeWhen(self.didLoadViewControllersIntoPagesDataSourceProperty.signal)
      .filterMap { $0.filter { $0.isInfoPage }.first }
      .map { ($0, UIPageViewController.NavigationDirection.forward) }

    let pagedToPage = Signal.merge(
      firstPage.map(first),
      infoButtonPage.takeWhen(self.infoButtonTappedProperty.signal),
      chatButtonPage.takeWhen(self.chatButtonTappedProperty.signal)
      )
      .combinePrevious()
      .map { prev, current in
        (current, prev.pageDirection(toPage: current))
    }

    self.pagedToPage = Signal.merge(
      firstPage,
      pagedToPage
    )

    let pageChangedToPage = Signal.merge(
      pageControllerPagedToPage,
      self.pagedToPage.map(first)
    )

    let isInfoPage = pageChangedToPage
      .map { $0.isInfoPage }

    let isChatPage = pageChangedToPage
      .map { $0.isChatPage }

    self.infoButtonTextColor = isInfoPage
      .map { $0 ? .white : .ksr_grey_500 }

    self.chatButtonTextColor = isChatPage
      .map { $0 ? .white : .ksr_grey_500 }

    self.infoButtonTitleFont = isInfoPage
      .map { $0 ? .ksr_headline(size: 14) : .ksr_body(size: 14) }

    self.chatButtonTitleFont = isChatPage
      .map { $0 ? .ksr_headline(size: 14) : .ksr_body(size: 14) }

    self.indicatorLineViewXPosition = self.loadViewControllersIntoPagesDataSource
      .takePairWhen(pageChangedToPage)
      .map { $0.index(of: $1) }
      .skipNil()

    let chatFeatureFlagDisabled = self.viewDidLoadProperty.signal
      .map {
        return AppEnvironment.current.config?.features["ios_live_stream_chat"] != .some(false)
      }
      .map(negate)

    self.indicatorLineViewHidden = chatFeatureFlagDisabled
    self.pagerTabStripStackViewHidden = chatFeatureFlagDisabled
  }

  private let configDataProperty = MutableProperty<(Project, LiveStreamEvent,
    RefTag, Bool)?>(nil)
  public func configureWith(project: Project, liveStreamEvent: LiveStreamEvent,
                            refTag: RefTag, presentedFromProject: Bool) {
    self.configDataProperty.value = (project, liveStreamEvent, refTag, presentedFromProject)
  }

  private let chatButtonTappedProperty = MutableProperty(())
  public func chatButtonTapped() {
    self.chatButtonTappedProperty.value = ()
  }

  private let didLoadViewControllersIntoPagesDataSourceProperty = MutableProperty(())
  public func didLoadViewControllersIntoPagesDataSource() {
    self.didLoadViewControllersIntoPagesDataSourceProperty.value = ()
  }

  private let infoButtonTappedProperty = MutableProperty(())
  public func infoButtonTapped() {
    self.infoButtonTappedProperty.value = ()
  }

  private let pageTransitionCompletedProperty = MutableProperty(false)
  public func pageTransition(completed: Bool) {
    self.pageTransitionCompletedProperty.value = completed
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let willTransitionToPageProperty = MutableProperty<LiveStreamContainerPage?>(nil)
  public func willTransition(toPage page: LiveStreamContainerPage) {
    self.willTransitionToPageProperty.value = page
  }

  public let chatButtonTextColor: Signal<UIColor, NoError>
  public let chatButtonTitleFont: Signal<UIFont, NoError>
  public let indicatorLineViewHidden: Signal<Bool, NoError>
  public let indicatorLineViewXPosition: Signal<Int, NoError>
  public let infoButtonTextColor: Signal<UIColor, NoError>
  public let infoButtonTitleFont: Signal<UIFont, NoError>
  public let loadViewControllersIntoPagesDataSource: Signal<[LiveStreamContainerPage], NoError>
  public let pagedToPage: Signal<(LiveStreamContainerPage, UIPageViewController.NavigationDirection), NoError>
  public let pagerTabStripStackViewHidden: Signal<Bool, NoError>

  public var inputs: LiveStreamContainerPageViewModelInputs { return self }
  public var outputs: LiveStreamContainerPageViewModelOutputs { return self }
}

public enum LiveStreamContainerPage {
  case info(project: Project, liveStreamEvent: LiveStreamEvent, refTag: RefTag, presentedFromProject: Bool)
  case chat(project: Project, liveStreamEvent: LiveStreamEvent)

  fileprivate var isInfoPage: Bool {
    switch self {
    case .info:
      return true
    case .chat:
      return false
    }
  }

  fileprivate var isChatPage: Bool {
    switch self {
    case .chat:
      return true
    case .info:
      return false
    }
  }

  fileprivate func pageDirection(toPage: LiveStreamContainerPage)
    -> UIPageViewController.NavigationDirection {
    switch (self, toPage) {
    case (.info, .chat):
      return .forward
    case (.chat, .info):
      return .reverse
    case (.chat, .chat):
      return .forward
    case (.info, .info):
      return .forward
    }
  }
}

extension LiveStreamContainerPage: Equatable {
  public static func == (lhs: LiveStreamContainerPage, rhs: LiveStreamContainerPage) -> Bool {
    switch (lhs, rhs) {
    case let (.info(lhs), .info(rhs)):
      return lhs == rhs
    case let (.chat(lhs), .chat(rhs)):
      return lhs == rhs
    case (.info, _), (.chat, _):
      return false
    }
  }
}
