import Prelude
import ReactiveSwift
import Result
import LiveStream
import KsApi

public protocol ProjectPamphletSubpageCellViewModelInputs {
  /// Call with the ProjectPamphletSubpage
  func configureWith(subpage: ProjectPamphletSubpage)
}

public protocol ProjectPamphletSubpageCellViewModelOutputs {
  /// Emits the background color for the count label
  var countLabelBackgroundColor: Signal<UIColor, NoError> { get }

  /// Emits the border color for the count label
  var countLabelBorderColor: Signal<UIColor, NoError> { get }

  /// Emits the count label's text
  var countLabelText: Signal<String, NoError> { get }

  /// Emits the count label's text color
  var countLabelTextColor: Signal<UIColor, NoError> { get }

  /// Emits when the live now image view should be hidden
  var liveNowImageViewHidden: Signal<Bool, NoError> { get }

  /// Emits the cell's primary label text
  var labelText: Signal<String, NoError> { get }

  /// Emits the cell's primary label text color
  var labelTextColor: Signal<UIColor, NoError> { get }

  /// Emits when the top gradient view should be hidden
  var topGradientViewHidden: Signal<Bool, NoError> { get }

  /// Emits when the separator view should be hidden
  var separatorViewHidden: Signal<Bool, NoError> { get }
}

public protocol ProjectPamphletSubpageCellViewModelType {
  var inputs: ProjectPamphletSubpageCellViewModelInputs { get }
  var outputs: ProjectPamphletSubpageCellViewModelOutputs { get }
}

public final class ProjectPamphletSubpageCellViewModel: ProjectPamphletSubpageCellViewModelType,
ProjectPamphletSubpageCellViewModelInputs, ProjectPamphletSubpageCellViewModelOutputs {

  public init() {
    let commentsSubpage = self.subpageProperty.signal.skipNil().filter { $0.isComments }
    let liveStreamSubpage = self.subpageProperty.signal.skipNil().filter { $0.isLiveStream }
    let updatesSubpage = self.subpageProperty.signal.skipNil().filter { $0.isUpdates }

    let liveStreamDetail = liveStreamSubpage.map { $0.liveStreamEvent }.skipNil()

    self.labelText = Signal.merge(
      commentsSubpage.mapConst(Strings.project_menu_buttons_comments()),
      liveStreamDetail.map(labelTexts(forLiveStreamEvent:)).map(first),
      updatesSubpage.mapConst(Strings.project_menu_buttons_updates())
    )

    self.labelTextColor = Signal.merge(
      commentsSubpage.mapConst(.ksr_text_dark_grey_900),
      liveStreamDetail.map { $0.liveNow ? .ksr_text_green_700 : .ksr_text_dark_grey_900 },
      updatesSubpage.mapConst(.ksr_text_dark_grey_900)
    )

    self.topGradientViewHidden = self.subpageProperty.signal.skipNil()
      .map { $0.position != .first }

    self.separatorViewHidden = self.subpageProperty.signal.skipNil()
      .map { $0.position == .last }

    self.countLabelText = Signal.merge(
      Signal.merge(commentsSubpage, updatesSubpage).map { Format.wholeNumber($0.count ?? 0) },
      liveStreamDetail.map(labelTexts(forLiveStreamEvent:)).map(second)
    )

    self.countLabelTextColor = Signal.merge(
      Signal.merge(commentsSubpage, updatesSubpage).mapConst(.ksr_text_dark_grey_900),
      liveStreamDetail.map { $0.liveNow ? .ksr_text_green_700 : .ksr_text_dark_grey_900 }
    )

    self.countLabelBorderColor = Signal.merge(
      Signal.merge(commentsSubpage, updatesSubpage).mapConst(.clear),
      liveStreamDetail.map { $0.liveNow ? .ksr_green_500 : .clear }
    )

    self.countLabelBackgroundColor = Signal.merge(
      Signal.merge(commentsSubpage, updatesSubpage).mapConst(.ksr_navy_300),
      liveStreamDetail.map { $0.liveNow ? .white : .ksr_navy_300 }
    )

    self.liveNowImageViewHidden = Signal.merge(
      Signal.merge(commentsSubpage, updatesSubpage).mapConst(true),
      liveStreamDetail.map { !$0.liveNow }
    )
  }

  private let subpageProperty = MutableProperty<ProjectPamphletSubpage?>(nil)
  public func configureWith(subpage: ProjectPamphletSubpage) {
    self.subpageProperty.value = subpage
  }

  public let countLabelText: Signal<String, NoError>
  public let countLabelTextColor: Signal<UIColor, NoError>
  public let countLabelBorderColor: Signal<UIColor, NoError>
  public let countLabelBackgroundColor: Signal<UIColor, NoError>
  public let liveNowImageViewHidden: Signal<Bool, NoError>
  public let labelText: Signal<String, NoError>
  public let labelTextColor: Signal<UIColor, NoError>
  public let topGradientViewHidden: Signal<Bool, NoError>
  public let separatorViewHidden: Signal<Bool, NoError>

  public var inputs: ProjectPamphletSubpageCellViewModelInputs { return self }
  public var outputs: ProjectPamphletSubpageCellViewModelOutputs { return self }
}

private func labelTexts(forLiveStreamEvent liveStreamEvent: LiveStreamEvent) -> (String, String) {
  if liveStreamEvent.liveNow {
    return (Strings.Live_streaming_now(), Strings.Watch_live())
  }

  let now = AppEnvironment.current.dateType.init()

  if now.timeIntervalSince1970 >= liveStreamEvent.startDate.timeIntervalSince1970 {
    return (Strings.Past_live_stream(), Strings.Replay())
  }

  return (Strings.Upcoming_live_stream(),
          Format.relative(secondsInUTC: liveStreamEvent.startDate.timeIntervalSince1970, abbreviate: true))
}

public enum ProjectPamphletSubpageCellPosition {
  case first
  case middle
  case last
}

extension ProjectPamphletSubpageCellPosition: Equatable {}
public func == (lhs: ProjectPamphletSubpageCellPosition, rhs: ProjectPamphletSubpageCellPosition) -> Bool {
  switch (lhs, rhs) {
  case (.first, .first), (.middle, .middle), (.last, .last):
    return true
  default:
    return false
  }
}

public enum ProjectPamphletSubpage {
  case comments(Int?, ProjectPamphletSubpageCellPosition)
  case updates(Int?, ProjectPamphletSubpageCellPosition)
  case liveStream(liveStreamEvent: LiveStreamEvent, ProjectPamphletSubpageCellPosition)

  public var count: Int? {
    switch self {
    case let .comments(count, _): return count
    case let .updates(count, _): return count
    default: return 0
    }
  }

  public var position: ProjectPamphletSubpageCellPosition {
    switch self {
    case let .comments(_, position): return position
    case let .updates(_, position): return position
    case let .liveStream(_, position): return position
    }
  }

  public var isComments: Bool {
    switch self {
    case .comments: return true
    default: return false
    }
  }

  public var isUpdates: Bool {
    switch self {
    case .updates: return true
    default: return false
    }
  }

  public var isLiveStream: Bool {
    switch self {
    case .liveStream: return true
    default: return false
    }
  }

  public var liveStreamEvent: LiveStreamEvent? {
    if case .liveStream(let liveStreamEvent, _) = self {
      return liveStreamEvent
    }
    return nil
  }
}

extension ProjectPamphletSubpage: Equatable {}
public func == (lhs: ProjectPamphletSubpage, rhs: ProjectPamphletSubpage) -> Bool {

  switch (lhs, rhs) {
  case let (.comments(lhsCount, lhsPos), .comments(rhsCount, rhsPos)):
    return lhsCount == rhsCount && lhsPos == rhsPos
  case let (.updates(lhsCount, lhsPos), .updates(rhsCount, rhsPos)):
    return lhsCount == rhsCount && lhsPos == rhsPos
  case let (.liveStream(lhsStream, lhsPos), .liveStream(rhsStream, rhsPos)):
    return lhsStream == rhsStream && lhsPos == rhsPos
  default:
    return false
  }
}
