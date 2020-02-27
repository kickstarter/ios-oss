import Foundation
import KsApi
import ReactiveSwift
import Prelude

public protocol CategorySelectionCellViewModelInputs {
  func categorySelected(at index: Int) -> Bool
  func configure(with value: KsApi.Category)
}

public protocol CategorySelectionCellViewModelOutputs {
  var categoryTitleText: Signal<String, Never> { get }
  var loadSubCategories: Signal<[(String, PillCellStyle)], Never> { get }
}

public protocol CategorySelectionCellViewModelType {
  var inputs: CategorySelectionCellViewModelInputs { get }
  var outputs: CategorySelectionCellViewModelOutputs { get }
}

public final class CategorySelectionCellViewModel: CategorySelectionCellViewModelType,
CategorySelectionCellViewModelInputs, CategorySelectionCellViewModelOutputs {
  public init() {
    self.categoryTitleText = self.configureWithCategoryProperty.signal
      .skipNil()
      .map(\.name)

    let subcategories = self.configureWithCategoryProperty.signal
      .skipNil()
      .map(\.subcategories)
      .skipNil()
      .map(\.nodes)

    self.loadSubCategories = Signal.zip(self.categoryTitleText, subcategories)
      .map { titleAndSubcategories -> [(String, PillCellStyle)] in
        let (title, subcategories) = titleAndSubcategories
        var categoryNames = subcategories.map { $0.name }
        categoryNames.insert("All \(title) Projects", at: 0)
        
        return categoryNames.map { ($0, PillCellStyle.grey) }
    }

    let selectedIndexes = self.categorySelectedAtIndexProperty.signal
      .skipNil()
      .scan(Set<Int>()) { selectedIndexes, index in
        var newSelectedIndexes = selectedIndexes

        if newSelectedIndexes.contains(index) {
          newSelectedIndexes.remove(index)
        } else {
          newSelectedIndexes.insert(index)
        }

        return newSelectedIndexes
    }

    self.shouldSelectCategoryProperty <~ self.categorySelectedAtIndexProperty.signal.skipNil()
      .takePairWhen(selectedIndexes)
      .map { selectedIndex, selectedIndexes in selectedIndexes.contains(selectedIndex) }
  }

  private let configureWithCategoryProperty = MutableProperty<KsApi.Category?>(nil)
  public func configure(with value: KsApi.Category) {
    self.configureWithCategoryProperty.value = value
  }

  private let categorySelectedAtIndexProperty = MutableProperty<Int?>(nil)
  private let shouldSelectCategoryProperty = MutableProperty<Bool>(false)
  public func categorySelected(at index: Int) -> Bool {
    self.categorySelectedAtIndexProperty.value = index

    return shouldSelectCategoryProperty.value
  }

  public let categoryTitleText: Signal<String, Never>
  public let loadSubCategories: Signal<[(String, PillCellStyle)], Never>

  public var inputs: CategorySelectionCellViewModelInputs { return self }
  public var outputs: CategorySelectionCellViewModelOutputs { return self }
}
