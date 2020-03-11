import Foundation
import Prelude
import ReactiveSwift
import UIKit

public enum PillCellStyle {
  case green
  case grey

  var backgroundColor: UIColor {
    switch self {
    case .green:
      return UIColor.ksr_green_500.withAlphaComponent(0.06)
    case .grey:
      return UIColor.ksr_grey_400.withAlphaComponent(0.8)
    }
  }

  var cornerRadius: CGFloat {
    switch self {
      case .green:
        return Styles.grid(1)
      case .grey:
        return Styles.grid(3)
    }
  }

  var selectedBackgroundColor: UIColor {
    switch self {
    case .green:
      return UIColor.ksr_green_500.withAlphaComponent(0.06)
    case .grey:
      return UIColor.ksr_trust_700.withAlphaComponent(0.1)
    }
  }

  var textColor: UIColor {
    switch self {
    case .green:
      return UIColor.ksr_green_500
    case .grey:
      return UIColor.ksr_soft_black
    }
  }

  var textColorSelected: UIColor {
    switch self {
    case .green:
      return UIColor.ksr_green_500
    case .grey:
      return UIColor.ksr_trust_700
    }
  }

  var layoutMargins: UIEdgeInsets {
    switch self {
      case .green:
        return .init(topBottom: Styles.gridHalf(2), leftRight: Styles.gridHalf(3))
      case .grey:
        return .init(all: Styles.grid(2))
    }
  }
}

public protocol PillCellViewModelInputs {
  func configure(with value: String)
}

public protocol PillCellViewModelOutputs {
  var text: Signal<String, Never> { get }
}

public protocol PillCellViewModelType {
  var inputs: PillCellViewModelInputs { get }
  var outputs: PillCellViewModelOutputs { get }
}

public final class PillCellViewModel: PillCellViewModelType, PillCellViewModelInputs,
PillCellViewModelOutputs {
  public init() {
    self.text = self.configureWithValueProperty.signal.skipNil()
  }

  private let configureWithValueProperty = MutableProperty<String?>(nil)
  public func configure(with value: String) {
    self.configureWithValueProperty.value = value
  }

  public let text: Signal<String, Never>

  public var inputs: PillCellViewModelInputs { return self }
  public var outputs: PillCellViewModelOutputs { return self }
}
