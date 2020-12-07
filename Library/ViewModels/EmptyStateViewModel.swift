import Foundation
import ReactiveSwift
import UIKit

public enum EmptyStateViewType {
  case errorPullToRefresh
  case addOnsUnavailable

  var imageName: String? {
    switch self {
    case .errorPullToRefresh: return "icon-exclamation"
    case .addOnsUnavailable: return "icon-globe"
    }
  }

  var leftRightMargins: CGFloat {
    switch self {
    case .errorPullToRefresh: return Styles.grid(10)
    case .addOnsUnavailable: return Styles.grid(3)
    }
  }

  var titleLabelHidden: Bool {
    switch self {
    case .errorPullToRefresh: return true
    case .addOnsUnavailable: return false
    }
  }

  var bodyLabelHidden: Bool {
    return false
  }

  var titleLabelText: String {
    switch self {
    case .errorPullToRefresh: return ""
    case .addOnsUnavailable:
      return Strings.Add_ons_unavailable()
    }
  }

  var bodyLabelText: String {
    switch self {
    case .errorPullToRefresh:
      return Strings.Something_went_wrong_pull_to_refresh()
    case .addOnsUnavailable:
      return Strings.Change_your_shipping_location_or_skip_add_ons_to_continue()
    }
  }

  var bodyLabelTextColor: UIColor {
    switch self {
    case .errorPullToRefresh:
      return .ksr_support_700
    case .addOnsUnavailable:
      return .ksr_support_400
    }
  }
}

public protocol EmptyStateViewModelInputs {
  func configure(with type: EmptyStateViewType)
}

public protocol EmptyStateViewModelOutputs {
  var bodyLabelHidden: Signal<Bool, Never> { get }
  var bodyLabelText: Signal<String, Never> { get }
  var bodyLabelTextColor: Signal<UIColor, Never> { get }
  var imageName: Signal<String?, Never> { get }
  var leftRightMargins: Signal<CGFloat, Never> { get }
  var titleLabelHidden: Signal<Bool, Never> { get }
  var titleLabelText: Signal<String, Never> { get }
}

public protocol EmptyStateViewModelType {
  var inputs: EmptyStateViewModelInputs { get }
  var outputs: EmptyStateViewModelOutputs { get }
}

public final class EmptyStateViewModel: EmptyStateViewModelType, EmptyStateViewModelInputs,
  EmptyStateViewModelOutputs {
  public init() {
    let type = self.configDataProperty.signal.skipNil()

    self.bodyLabelHidden = type.map(\.bodyLabelHidden)
    self.bodyLabelText = type.map(\.bodyLabelText)
    self.bodyLabelTextColor = type.map(\.bodyLabelTextColor)
    self.imageName = type.map(\.imageName)
    self.leftRightMargins = type.map(\.leftRightMargins)
    self.titleLabelHidden = type.map(\.titleLabelHidden)
    self.titleLabelText = type.map(\.titleLabelText)
  }

  private let configDataProperty = MutableProperty<EmptyStateViewType?>(nil)
  public func configure(with data: EmptyStateViewType) {
    self.configDataProperty.value = data
  }

  public let bodyLabelHidden: Signal<Bool, Never>
  public let bodyLabelText: Signal<String, Never>
  public let bodyLabelTextColor: Signal<UIColor, Never>
  public let imageName: Signal<String?, Never>
  public let leftRightMargins: Signal<CGFloat, Never>
  public let titleLabelHidden: Signal<Bool, Never>
  public let titleLabelText: Signal<String, Never>

  public var inputs: EmptyStateViewModelInputs { return self }
  public var outputs: EmptyStateViewModelOutputs { return self }
}
