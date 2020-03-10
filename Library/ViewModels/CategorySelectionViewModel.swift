import Foundation
import KsApi
import ReactiveSwift

public protocol CategorySelectionViewModelInputs {
  func continueButtonTapped()
  func viewDidLoad()
}

public protocol CategorySelectionViewModelOutputs {
  var goToCuratedProjects: Signal<Void, Never> { get }

  // A tuple of Section Titles: [String], and Categories Section Data: [[(String, PillCellStyle)]]
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
      .on { _ in
        AppEnvironment.current.userDefaults.hasSeenCategoryPersonalizationFlow = true
      }
      .switchMap { _ in
        AppEnvironment.current.apiService
          .fetchGraphCategories(query: rootCategoriesQuery)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { $0.rootCategories }
          .materialize()
      }

    let orderedCategories = categoriesEvent.values().map(categoriesOrderedByPopularity)

    self.loadCategorySections = orderedCategories.map { rootCategories in
      var sectionTitles = [String]()
      let categoriesData = rootCategories.compactMap { category -> [(String, PillCellStyle)]? in
        guard let subcategories = category.subcategories?.nodes else {
          return nil
        }

        sectionTitles.append(category.name)

        let subcategoriesData = subcategories.map { ($0.name, PillCellStyle.grey) }
        let allCategoryProjects = (
          Strings.All_category_name_Projects(category_name: category.name),
          PillCellStyle.grey
        )

        return [allCategoryProjects] + subcategoriesData
      }

      return (sectionTitles, categoriesData)
    }

    self.goToCuratedProjects = self.continueButtonTappedProperty.signal.ignoreValues()
  }

  private let continueButtonTappedProperty = MutableProperty(())
  public func continueButtonTapped() {
    self.continueButtonTappedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let goToCuratedProjects: Signal<Void, Never>
  public let loadCategorySections: Signal<([String], [[(String, PillCellStyle)]]), Never>

  public var inputs: CategorySelectionViewModelInputs { return self }
  public var outputs: CategorySelectionViewModelOutputs { return self }
}

private enum CategoryById: Int, CaseIterable {
  case games = 12
  case design = 7
  case technology = 16
  case art = 1
  case comics = 3
  case fashion = 9
  case publishing = 18
  case food = 10
  case filmAndVideo = 11
  case music = 14
  case crafts = 26
  case photography = 15
  case journalism = 13
  case theater = 17
  case dance = 6
}

private func categoriesOrderedByPopularity(_ categories: [KsApi.Category]) -> [KsApi.Category] {
  let allCategoriesById = CategoryById.allCases
  let categoryIdAndIndex: [CategoryById: Int] = Dictionary(
    uniqueKeysWithValues: zip(allCategoriesById, 0...allCategoriesById.count)
  )
  let categoryIdAndIndexCount = categoryIdAndIndex.keys.count

  // Pre-create an array of the correct size
  var orderedRootCategories: [KsApi.Category?] = [KsApi.Category?](
    repeating: nil,
    count: categoryIdAndIndexCount
  )
  // Any categories returned whose order is unknown will get appended at the end
  var unknownOrderCategories: [KsApi.Category] = []

  categories.forEach { category in
    guard
      let id = category.intID,
      let categoryById = CategoryById(rawValue: id),
      let index = categoryIdAndIndex[categoryById] else {
      unknownOrderCategories.append(category)

      return
    }

    orderedRootCategories[index] = category
  }

  var orderedNonNil = orderedRootCategories.compact()
  orderedNonNil.append(contentsOf: unknownOrderCategories)

  return orderedNonNil
}
