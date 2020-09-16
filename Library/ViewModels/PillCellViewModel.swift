import Foundation
import Prelude
import ReactiveSwift
import UIKit

public typealias PillCellData = (
  text: String,
  textColor: UIColor,
  backgroundColor: UIColor
)

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
