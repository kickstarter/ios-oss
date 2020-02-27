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

  var textColor: UIColor {
    switch self {
    case .green:
      return UIColor.ksr_green_500
    case .grey:
      return UIColor.ksr_soft_black
    }
  }
}

public protocol PillCellViewModelInputs {
  func configure(with value: (String, PillCellStyle))
}

public protocol PillCellViewModelOutputs {
  var backgroundColor: Signal<UIColor, Never> { get }
  var text: Signal<String, Never> { get }
  var textColor: Signal<UIColor, Never> { get }
}

public protocol PillCellViewModelType {
  var inputs: PillCellViewModelInputs { get }
  var outputs: PillCellViewModelOutputs { get }
}

public final class PillCellViewModel: PillCellViewModelType, PillCellViewModelInputs,
  PillCellViewModelOutputs {
  public init() {
    self.backgroundColor = self.configureWithValueProperty.signal.skipNil()
      .map(second)
      .map(\.backgroundColor)

    self.textColor = self.configureWithValueProperty.signal.skipNil()
      .map(second)
      .map(\.textColor)

    self.text = self.configureWithValueProperty.signal.skipNil()
      .map(first)
  }

  private let configureWithValueProperty = MutableProperty<(String, PillCellStyle)?>(nil)
  public func configure(with value: (String, PillCellStyle)) {
    self.configureWithValueProperty.value = value
  }

  public let backgroundColor: Signal<UIColor, Never>
  public let text: Signal<String, Never>
  public let textColor: Signal<UIColor, Never>

  public var inputs: PillCellViewModelInputs { return self }
  public var outputs: PillCellViewModelOutputs { return self }
}
