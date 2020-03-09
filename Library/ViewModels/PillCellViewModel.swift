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
      return UIColor.ksr_trust_700.withAlphaComponent(0.8)
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
  func configure(with value: (String, PillCellStyle))
  func setIsSelected(selected: Bool)
}

public protocol PillCellViewModelOutputs {
  var backgroundColor: Signal<UIColor, Never> { get }
  var cornerRadius: Signal<CGFloat, Never> { get }
  var layoutMargins: Signal<UIEdgeInsets, Never> { get }
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
    let defaultBackgroundColor = self.configureWithValueProperty.signal.skipNil()
      .map(second)
      .map(\.backgroundColor)
    let selectedBackgroundColor = self.configureWithValueProperty.signal.skipNil().map(second)
      .takePairWhen(self.isSelectedProperty.signal)
      .map { style, isSelected in isSelected ? style.selectedBackgroundColor : style.backgroundColor }

    self.backgroundColor = Signal.merge(defaultBackgroundColor, selectedBackgroundColor)

    let defaultTextColor = self.configureWithValueProperty.signal.skipNil()
      .map(second)
      .map(\.textColor)

    let selectedTextColor = self.configureWithValueProperty.signal.skipNil().map(second)
    .takePairWhen(self.isSelectedProperty.signal)
    .map { style, isSelected in isSelected ? style.textColorSelected : style.textColor }

    self.textColor = Signal.merge(defaultTextColor, selectedTextColor)

    self.text = self.configureWithValueProperty.signal.skipNil()
      .map(first)

    self.cornerRadius = self.configureWithValueProperty.signal.skipNil()
      .map(second)
      .map(\.cornerRadius)

    self.layoutMargins = self.configureWithValueProperty.signal.skipNil()
      .map(second)
      .map(\.layoutMargins)
  }

  private let configureWithValueProperty = MutableProperty<(String, PillCellStyle)?>(nil)
  public func configure(with value: (String, PillCellStyle)) {
    self.configureWithValueProperty.value = value
  }

  private let isSelectedProperty = MutableProperty<Bool>(false)
  public func setIsSelected(selected: Bool) {
    self.isSelectedProperty.value = selected
  }

  public let backgroundColor: Signal<UIColor, Never>
  public let cornerRadius: Signal<CGFloat, Never>
  public let layoutMargins: Signal<UIEdgeInsets, Never>
  public let text: Signal<String, Never>
  public let textColor: Signal<UIColor, Never>

  public var inputs: PillCellViewModelInputs { return self }
  public var outputs: PillCellViewModelOutputs { return self }
}
