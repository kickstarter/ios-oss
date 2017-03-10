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
  /// Call to configure with the Project, LiveStreamEvent and LiveStreamChatHandler.
  func configureWith(project: Project, liveStreamEvent: LiveStreamEvent,
                     liveStreamChatHandler: LiveStreamChatHandler, refTag: RefTag, presentedFromProject: Bool)

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
  func willTransition(toPage nextPage: Int)
}

public protocol LiveStreamContainerPageViewModelOutputs {
  /// Emits the text color for the chat button.
  var chatButtonTextColor: Signal<UIColor, NoError> { get }

  /// Emits the title font for the chat button.
  var chatButtonTitleFont: Signal<UIFont, NoError> { get }

  /// Emits the X offset position for the indicator line view.
  var indicatorLineViewXPosition: Signal<Int, NoError> { get }

  /// Emits the text color for the info button.
  var infoButtonTextColor: Signal<UIColor, NoError> { get }

  /// Emits the title font for the info button.
  var infoButtonTitleFont: Signal<UIFont, NoError> { get }

  /// Emits the view controller page types to load into the data source.
  var loadViewControllersIntoPagesDataSource: Signal<[LiveStreamContainerPage], NoError> { get }

  /// Emits the page that should be paged to and in which direction.
  var pagedToPage: Signal<(LiveStreamContainerPage, UIPageViewControllerNavigationDirection), NoError> { get }
}

public final class LiveStreamContainerPageViewModel: LiveStreamContainerPageViewModelType,
LiveStreamContainerPageViewModelInputs, LiveStreamContainerPageViewModelOutputs {

  //swiftlint:disable:next function_body_length
  public init() {
    let configData = Signal.combineLatest(
      self.configDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    ).map(first)

    self.loadViewControllersIntoPagesDataSource = configData.map { project, liveStreamEvent,
      liveStreamChatHandler, refTag, presentedFromProject in
      [
        .info(project: project, liveStreamEvent: liveStreamEvent, refTag: refTag,
              presentedFromProject: presentedFromProject),
        .chat(project: project, liveStreamEvent: liveStreamEvent,
              liveStreamChatHandler: liveStreamChatHandler)
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

    let pageControllerPagedToPage = Signal.combineLatest(
      self.loadViewControllersIntoPagesDataSource,
      self.willTransitionToPageProperty.signal
        .takeWhen(self.pageTransitionCompletedProperty.signal.filter(isTrue))
      )
      .map { $0[$1] }

    let firstPage = self.loadViewControllersIntoPagesDataSource
      .takeWhen(self.didLoadViewControllersIntoPagesDataSourceProperty.signal)
      .map { $0.filter { $0.isChatPage }.first }
      .skipNil()
      .map { ($0, UIPageViewControllerNavigationDirection.forward) }

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

    self.indicatorLineViewXPosition = pageChangedToPage
      .map(indexFor(page:))
  }

  private let configDataProperty = MutableProperty<(Project, LiveStreamEvent, LiveStreamChatHandler,
    RefTag, Bool)?>(nil)
  public func configureWith(project: Project, liveStreamEvent: LiveStreamEvent,
                            liveStreamChatHandler: LiveStreamChatHandler, refTag: RefTag,
                            presentedFromProject: Bool) {
    self.configDataProperty.value = (project, liveStreamEvent, liveStreamChatHandler, refTag,
                                     presentedFromProject)
  }

  private let chatButtonTappedProperty = MutableProperty()
  public func chatButtonTapped() {
    self.chatButtonTappedProperty.value = ()
  }

  private let didLoadViewControllersIntoPagesDataSourceProperty = MutableProperty()
  public func didLoadViewControllersIntoPagesDataSource() {
    self.didLoadViewControllersIntoPagesDataSourceProperty.value = ()
  }

  private let infoButtonTappedProperty = MutableProperty()
  public func infoButtonTapped() {
    self.infoButtonTappedProperty.value = ()
  }

  private let pageTransitionCompletedProperty = MutableProperty(false)
  public func pageTransition(completed: Bool) {
    self.pageTransitionCompletedProperty.value = completed
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let willTransitionToPageProperty = MutableProperty<Int>(0)
  public func willTransition(toPage nextPage: Int) {
    self.willTransitionToPageProperty.value = nextPage
  }

  public let chatButtonTextColor: Signal<UIColor, NoError>
  public let chatButtonTitleFont: Signal<UIFont, NoError>
  public let indicatorLineViewXPosition: Signal<Int, NoError>
  public let infoButtonTextColor: Signal<UIColor, NoError>
  public let infoButtonTitleFont: Signal<UIFont, NoError>
  public let loadViewControllersIntoPagesDataSource: Signal<[LiveStreamContainerPage], NoError>
  public let pagedToPage: Signal<(LiveStreamContainerPage, UIPageViewControllerNavigationDirection), NoError>

  public var inputs: LiveStreamContainerPageViewModelInputs { return self }
  public var outputs: LiveStreamContainerPageViewModelOutputs { return self }
}

private func indexFor(page: LiveStreamContainerPage) -> Int {
  switch page {
  case .info:
    return 0
  case .chat:
    return 1
  }
}

public enum LiveStreamContainerPage {
  case info(project: Project, liveStreamEvent: LiveStreamEvent, refTag: RefTag, presentedFromProject: Bool)
  case chat(project: Project, liveStreamEvent: LiveStreamEvent, liveStreamChatHandler: LiveStreamChatHandler)

  var isInfoPage: Bool {
    switch self {
    case .info:
      return true
    default:
      return false
    }
  }

  var isChatPage: Bool {
    switch self {
    case .chat:
      return true
    default:
      return false
    }
  }

  func pageDirection(toPage: LiveStreamContainerPage) -> UIPageViewControllerNavigationDirection {
    switch (self, toPage) {
    case (.info, .chat):
      return .forward
    case (.chat, .info):
      return .reverse
    default:
      return .forward
    }
  }
}
