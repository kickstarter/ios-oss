import Prelude
import ReactiveSwift
import Result
import KsApi

public protocol ProjectPamphletSubpageCellViewModelInputs {
  func configureWith(subpage: ProjectPamphletSubpage)
}

public protocol ProjectPamphletSubpageCellViewModelOutputs {
  var countLabelBackgroundColor: Signal<UIColor, NoError> { get }
  var countLabelBorderColor: Signal<UIColor, NoError> { get }
  var countLabelText: Signal<String, NoError> { get }
  var countLabelTextColor: Signal<UIColor, NoError> { get }
  var liveNowImageViewHidden: Signal<Bool, NoError> { get }
  var labelText: Signal<String, NoError> { get }
  var labelTextColor: Signal<UIColor, NoError> { get }
  var topGradientViewHidden: Signal<Bool, NoError> { get }
  var separatorViewHidden: Signal<Bool, NoError> { get }
}

public protocol ProjectPamphletSubpageCellViewModelType {
  var inputs: ProjectPamphletSubpageCellViewModelInputs { get }
  var outputs: ProjectPamphletSubpageCellViewModelOutputs { get }
}

public final class ProjectPamphletSubpageCellViewModel: ProjectPamphletSubpageCellViewModelType,
ProjectPamphletSubpageCellViewModelInputs, ProjectPamphletSubpageCellViewModelOutputs {
  var st: String?
  public init() {
    let commentsSubpage = self.subpageProperty.signal.skipNil().filter { $0.isComments }
    let liveStreamSubpage = self.subpageProperty.signal.skipNil().filter { $0.isLiveStream }
    let updatesSubpage = self.subpageProperty.signal.skipNil().filter { $0.isUpdates }

    let liveStreamDetail = liveStreamSubpage.map { $0.liveStream }.skipNil()

    self.labelText = Signal.merge(
      commentsSubpage.mapConst(Strings.project_menu_buttons_comments()),
      liveStreamDetail.map { $0.isLiveNow ? Strings.Live_Streaming_now() : Strings.Live_Stream()},
      updatesSubpage.mapConst(Strings.project_menu_buttons_updates())
    )

    self.labelTextColor = Signal.merge(
      commentsSubpage.mapConst(.ksr_text_navy_700),
      liveStreamDetail.map { $0.isLiveNow ? .ksr_text_green_700 : .ksr_text_navy_700 },
      updatesSubpage.mapConst(.ksr_text_navy_700)
    )

    self.topGradientViewHidden = self.subpageProperty.signal.skipNil()
      .map { $0.position != .first }

    self.separatorViewHidden = self.subpageProperty.signal.skipNil()
      .map { $0.position == .last }

    self.countLabelText = Signal.merge(
      Signal.merge(commentsSubpage, updatesSubpage).map { String($0.count) },
      liveStreamDetail.map(labelText(forLiveStream:))
    )

    self.countLabelTextColor = Signal.merge(
      Signal.merge(commentsSubpage, updatesSubpage).mapConst(.ksr_text_navy_700),
      liveStreamDetail.map { $0.isLiveNow ? .ksr_text_green_700 : .ksr_text_navy_700 }
    )

    self.countLabelBorderColor = Signal.merge(
      Signal.merge(commentsSubpage, updatesSubpage).mapConst(.clear),
      liveStreamDetail.map { $0.isLiveNow ? .ksr_green_500 : .clear }
    )

    self.countLabelBackgroundColor = Signal.merge(
      Signal.merge(commentsSubpage, updatesSubpage).mapConst(.ksr_navy_300),
      liveStreamDetail.map { $0.isLiveNow ? .white : .ksr_navy_300 }
    )

    self.liveNowImageViewHidden = Signal.merge(
      Signal.merge(commentsSubpage, updatesSubpage).mapConst(true),
      liveStreamDetail.map { !$0.isLiveNow }
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

private func labelText(forLiveStream liveStream: Project.LiveStream) -> String {
  if liveStream.isLiveNow {
    return Strings.Watch_live()
  }

  let now = AppEnvironment.current.dateType.init()

  if now.timeIntervalSince1970 >= liveStream.startDate {
    return Strings.Replay()
  }

  return Format.relative(secondsInUTC: liveStream.startDate, abbreviate: true)
}

public enum ProjectPamphletSubpageCellPosition {
  case first
  case middle
  case last
}

public enum ProjectPamphletSubpage {
  case comments(Int, ProjectPamphletSubpageCellPosition)
  case updates(Int, ProjectPamphletSubpageCellPosition)
  case liveStream(liveStream: Project.LiveStream, ProjectPamphletSubpageCellPosition)

  public var count: Int {
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

  public var liveStream: Project.LiveStream? {
    if case .liveStream(let liveStream, _) = self {
      return liveStream
    }
    return nil
  }
}
