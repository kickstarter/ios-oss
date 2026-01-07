import Foundation
import ReactiveSwift

public protocol CategoryCollectionViewSectionHeaderViewModelInputs {
  func configure(with value: String)
}

public protocol CategoryCollectionViewSectionHeaderViewModelOutputs {
  var text: Signal<String, Never> { get }
}

public protocol CategoryCollectionViewSectionHeaderViewModelType {
  var inputs: CategoryCollectionViewSectionHeaderViewModelInputs { get }
  var outputs: CategoryCollectionViewSectionHeaderViewModelOutputs { get }
}

public final class CategoryCollectionViewSectionHeaderViewModel:
  CategoryCollectionViewSectionHeaderViewModelType, CategoryCollectionViewSectionHeaderViewModelInputs,
  CategoryCollectionViewSectionHeaderViewModelOutputs {
  public init() {
    self.text = self.configureWithValueProperty.signal.skipNil()
  }

  private let configureWithValueProperty = MutableProperty<String?>(nil)
  public func configure(with value: String) {
    self.configureWithValueProperty.value = value
  }

  public let text: Signal<String, Never>

  public var inputs: CategoryCollectionViewSectionHeaderViewModelInputs { return self }
  public var outputs: CategoryCollectionViewSectionHeaderViewModelOutputs { return self }
}
