import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol ProjectPamphletSubpageCellViewModelInputs {
  /// Call with the ProjectPamphletSubpage
  func configureWith(subpage: ProjectPamphletSubpage)
}

public protocol ProjectPamphletSubpageCellViewModelOutputs {
  /// Emits the background color for the count label
  var countLabelBackgroundColor: Signal<UIColor, Never> { get }

  /// Emits the border color for the count label
  var countLabelBorderColor: Signal<UIColor, Never> { get }

  /// Emits the count label's text
  var countLabelText: Signal<String, Never> { get }

  /// Emits the count label's text color
  var countLabelTextColor: Signal<UIColor, Never> { get }

  /// Emits the cell's primary label text
  var labelText: Signal<String, Never> { get }

  /// Emits the cell's primary label text color
  var labelTextColor: Signal<UIColor, Never> { get }

  /// Emits when the top gradient view should be hidden
  var topSeparatorViewHidden: Signal<Bool, Never> { get }

  /// Emits when the separator view should be hidden
  var separatorViewHidden: Signal<Bool, Never> { get }
}

public protocol ProjectPamphletSubpageCellViewModelType {
  var inputs: ProjectPamphletSubpageCellViewModelInputs { get }
  var outputs: ProjectPamphletSubpageCellViewModelOutputs { get }
}

public final class ProjectPamphletSubpageCellViewModel: ProjectPamphletSubpageCellViewModelType,
  ProjectPamphletSubpageCellViewModelInputs, ProjectPamphletSubpageCellViewModelOutputs {
  public init() {
    let commentsSubpage = self.subpageProperty.signal.skipNil().filter { $0.isComments }
    let updatesSubpage = self.subpageProperty.signal.skipNil().filter { $0.isUpdates }

    self.labelText = Signal.merge(
      commentsSubpage.mapConst(Strings.project_menu_buttons_comments()),
      updatesSubpage.mapConst(Strings.project_menu_buttons_updates())
    )

    self.labelTextColor = Signal.merge(
      commentsSubpage.mapConst(.ksr_support_700),
      updatesSubpage.mapConst(.ksr_support_700)
    )

    self.topSeparatorViewHidden = self.subpageProperty.signal.skipNil()
      .map { $0.position != .first }

    self.separatorViewHidden = self.subpageProperty.signal.skipNil()
      .map { $0.position == .last }

    self.countLabelText = Signal.merge(commentsSubpage, updatesSubpage)
      .map { Format.wholeNumber($0.count ?? 0) }

    self.countLabelTextColor = Signal.merge(commentsSubpage, updatesSubpage).mapConst(.ksr_support_700)
    self.countLabelBorderColor = Signal.merge(commentsSubpage, updatesSubpage).mapConst(.clear)
    self.countLabelBackgroundColor = Signal.merge(commentsSubpage, updatesSubpage).mapConst(.ksr_support_100)
  }

  private let subpageProperty = MutableProperty<ProjectPamphletSubpage?>(nil)
  public func configureWith(subpage: ProjectPamphletSubpage) {
    self.subpageProperty.value = subpage
  }

  public let countLabelText: Signal<String, Never>
  public let countLabelTextColor: Signal<UIColor, Never>
  public let countLabelBorderColor: Signal<UIColor, Never>
  public let countLabelBackgroundColor: Signal<UIColor, Never>
  public let labelText: Signal<String, Never>
  public let labelTextColor: Signal<UIColor, Never>
  public let topSeparatorViewHidden: Signal<Bool, Never>
  public let separatorViewHidden: Signal<Bool, Never>

  public var inputs: ProjectPamphletSubpageCellViewModelInputs { return self }
  public var outputs: ProjectPamphletSubpageCellViewModelOutputs { return self }
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

  public var count: Int? {
    switch self {
    case let .comments(count, _): return count
    case let .updates(count, _): return count
    }
  }

  public var position: ProjectPamphletSubpageCellPosition {
    switch self {
    case let .comments(_, position): return position
    case let .updates(_, position): return position
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
}

extension ProjectPamphletSubpage: Equatable {}
public func == (lhs: ProjectPamphletSubpage, rhs: ProjectPamphletSubpage) -> Bool {
  switch (lhs, rhs) {
  case let (.comments(lhsCount, lhsPos), .comments(rhsCount, rhsPos)):
    return lhsCount == rhsCount && lhsPos == rhsPos
  case let (.updates(lhsCount, lhsPos), .updates(rhsCount, rhsPos)):
    return lhsCount == rhsCount && lhsPos == rhsPos
  default:
    return false
  }
}
