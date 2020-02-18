import Foundation
import ReactiveSwift
import KsApi

public struct CategorySection {
  let parentCategory: KsApi.Category
  let subcategories: [KsApi.Category]
}

public protocol CategorySelectionViewModelInputs {
  func viewDidLoad()
}

public protocol CategorySelectionViewModelOutputs {
  var loadCategorySections: Signal<[KsApi.Category], Never> { get }
}

public protocol CategorySelectionViewModelType {
  var inputs: CategorySelectionViewModelInputs { get }
  var outputs: CategorySelectionViewModelOutputs { get }
}


public final class CategorySelectionViewModel: CategorySelectionViewModelType,
CategorySelectionViewModelInputs, CategorySelectionViewModelOutputs {
  public init() {

    let categoriesEvent = self.viewDidLoadProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService
          .fetchGraphCategories(query: rootCategoriesQuery)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { $0.rootCategories }
          .materialize()
    }

    self.loadCategorySections = categoriesEvent.values()
  }


  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadCategorySections: Signal<[KsApi.Category], Never>

  public var inputs: CategorySelectionViewModelInputs { return self }
  public var outputs: CategorySelectionViewModelOutputs { return self }
}
