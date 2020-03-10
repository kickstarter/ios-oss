import Foundation
import Prelude
import ReactiveSwift
import UIKit

public enum PillCellStyle {
  case green
  case grey

  var allowSelection: Bool {
    switch self {
      case .green: return false
      case .grey: return true
    }
  }
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
//    switch self {
//      case .green:
//        return .init(topBottom: Styles.gridHalf(2), leftRight: Styles.gridHalf(3))
//      case .grey:
//        return .init(all: Styles.grid(2))
//    }

//    return .init(topBottom: Styles.gridHalf(3), leftRight: Styles.gridHalf(3))
    return .init(all: Styles.gridHalf(3))
  }
}

public protocol PillCellViewModelInputs {
  func configure(with value: (String, PillCellStyle, IndexPath?))
  func pillCellTapped()
  func setIsSelected(selected: Bool)
}

public protocol PillCellViewModelOutputs {
  var backgroundColor: Signal<UIColor, Never> { get }
  var cornerRadius: Signal<CGFloat, Never> { get }
  var layoutMargins: Signal<UIEdgeInsets, Never> { get }
  var notifyDelegatePillCellTapped: Signal<IndexPath, Never> { get }
  var tapGestureRecognizerIsEnabled: Signal<Bool, Never> { get }
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
    self.tapGestureRecognizerIsEnabled = self.configureWithValueProperty.signal.skipNil()
      .map(second)
      .map { $0.allowSelection }

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

    self.notifyDelegatePillCellTapped = self.configureWithValueProperty.signal
      .skipNil()
      .map(third)
      .skipNil()
      .takeWhen(self.pillCellTappedProperty.signal)

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

  private let configureWithValueProperty = MutableProperty<(String, PillCellStyle, IndexPath?)?>(nil)
  public func configure(with value: (String, PillCellStyle, IndexPath?)) {
    self.configureWithValueProperty.value = value
  }

  private let pillCellTappedProperty = MutableProperty(())
  public func pillCellTapped() {
    self.pillCellTappedProperty.value = ()
  }

  private let isSelectedProperty = MutableProperty<Bool>(false)
  public func setIsSelected(selected: Bool) {
    self.isSelectedProperty.value = selected
  }

  public let backgroundColor: Signal<UIColor, Never>
  public let cornerRadius: Signal<CGFloat, Never>
  public let layoutMargins: Signal<UIEdgeInsets, Never>
  public let notifyDelegatePillCellTapped: Signal<IndexPath, Never>
  public let tapGestureRecognizerIsEnabled: Signal<Bool, Never>
  public let text: Signal<String, Never>
  public let textColor: Signal<UIColor, Never>

  public var inputs: PillCellViewModelInputs { return self }
  public var outputs: PillCellViewModelOutputs { return self }
}
