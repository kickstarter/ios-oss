import Foundation
import KsApi
import ReactiveSwift

public protocol CategorySelectionViewModelInputs {
  func viewDidLoad()
}

public protocol CategorySelectionViewModelOutputs {
  // A tuple of Section Titles: [String], and Section Data: [[(String, PillCellStyle)]]
  var loadCategorySections: Signal<([String], [[(String, PillCellStyle)]]), Never> { get }
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

    self.loadCategorySections = categoriesEvent.values().map { rootCategories in
      rootCategories.compactMap { category -> (String, [(String, PillCellStyle)])? in
        guard let subcategories = category.subcategories?.nodes else {
          return nil
        }

        let subcategoriesData = subcategories.map { ($0.name, PillCellStyle.grey) }

        return (category.name, subcategoriesData)
      }
    }.map { data in
      let sectionTitles = data.map { $0.0 }
      let sectionData = data.map { $0.1 }

      return (sectionTitles, sectionData)
    }
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadCategorySections: Signal<([String], [[(String, PillCellStyle)]]), Never>

  public var inputs: CategorySelectionViewModelInputs { return self }
  public var outputs: CategorySelectionViewModelOutputs { return self }
}
