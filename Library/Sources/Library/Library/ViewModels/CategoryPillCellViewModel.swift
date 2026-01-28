import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias CategoryPillCellValue = (name: String, category: KsApi.Category, indexPath: IndexPath?)

public protocol CategoryPillCellViewModelInputs {
  func configure(with value: CategoryPillCellValue)
  func pillCellTapped()
  func setIsSelected(selected: Bool)
}

public protocol CategoryPillCellViewModelOutputs {
  var buttonTitle: Signal<String, Never> { get }
  var isSelected: Signal<Bool, Never> { get }
  var notifyDelegatePillCellTapped: Signal<(IndexPath, KsApi.Category), Never> { get }
}

public protocol CategoryPillCellViewModelType {
  var inputs: CategoryPillCellViewModelInputs { get }
  var outputs: CategoryPillCellViewModelOutputs { get }
}

public final class CategoryPillCellViewModel: CategoryPillCellViewModelType,
  CategoryPillCellViewModelInputs, CategoryPillCellViewModelOutputs {
  public init() {
    self.notifyDelegatePillCellTapped = self.configureWithValueProperty.signal
      .skipNil()
      .takeWhen(self.pillCellTappedProperty.signal)
      .compactMap { value in
        guard let index = value.indexPath else {
          return nil
        }

        return (index, value.category)
      }

    self.isSelected = self.isSelectedProperty.signal.skipRepeats()

    self.buttonTitle = self.configureWithValueProperty.signal.skipNil()
      .map(first)
  }

  private let configureWithValueProperty = MutableProperty<CategoryPillCellValue?>(nil)
  public func configure(with value: CategoryPillCellValue) {
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

  public let buttonTitle: Signal<String, Never>
  public let isSelected: Signal<Bool, Never>
  public let notifyDelegatePillCellTapped: Signal<(IndexPath, KsApi.Category), Never>

  public var inputs: CategoryPillCellViewModelInputs { return self }
  public var outputs: CategoryPillCellViewModelOutputs { return self }
}
