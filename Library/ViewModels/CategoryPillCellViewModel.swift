import Foundation
import ReactiveSwift
import Prelude

public protocol CategoryPillCellViewModelInputs {
  func configure(with value: (String, IndexPath?))
  func pillCellTapped()
  func setIsSelected(selected: Bool)
}

public protocol CategoryPillCellViewModelOutputs {
  var isSelected: Signal<Bool, Never> { get }
  var notifyDelegatePillCellTapped: Signal<IndexPath, Never> { get }
  var text: Signal<String, Never> { get }
}

public protocol CategoryPillCellViewModelType {
  var inputs: CategoryPillCellViewModelInputs { get }
  var outputs: CategoryPillCellViewModelOutputs { get }
}


public final class CategoryPillCellViewModel: CategoryPillCellViewModelType, CategoryPillCellViewModelInputs, CategoryPillCellViewModelOutputs {
  public init() {
    self.notifyDelegatePillCellTapped = self.configureWithValueProperty.signal
      .skipNil()
      .map(second)
      .skipNil()
      .takeWhen(self.pillCellTappedProperty.signal)

    self.isSelected = self.isSelectedProperty.signal

    self.text = self.configureWithValueProperty.signal.skipNil()
      .map(first)
  }

  private let configureWithValueProperty = MutableProperty<(String, IndexPath?)?>(nil)
  public func configure(with value: (String, IndexPath?)) {
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

  public let isSelected: Signal<Bool, Never>
  public let notifyDelegatePillCellTapped: Signal<IndexPath, Never>
  public let text: Signal<String, Never>

  public var inputs: CategoryPillCellViewModelInputs { return self }
  public var outputs: CategoryPillCellViewModelOutputs { return self }
}
