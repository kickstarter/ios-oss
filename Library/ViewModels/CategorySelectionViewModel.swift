import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol CategorySelectionViewModelInputs {
  func categorySelected(with value: (IndexPath, Int))
  func continueButtonTapped()
  func viewDidLoad()
}

public protocol CategorySelectionViewModelOutputs {
  var continueButtonEnabled: Signal<Bool, Never> { get }
  var goToCuratedProjects: Signal<[Int], Never> { get }
  // A tuple of Section Titles: [String], and Categories Section Data (Name and Id): [[String, Int]]
  var loadCategorySections: Signal<([String], [[(String, Int)]]), Never> { get }
  func shouldSelectCell(at index: IndexPath) -> Bool
  var warningLabelIsHidden: Signal<Bool, Never> { get }
}

public protocol CategorySelectionViewModelType {
  var inputs: CategorySelectionViewModelInputs { get }
  var outputs: CategorySelectionViewModelOutputs { get }
}

public final class CategorySelectionViewModel: CategorySelectionViewModelType,
  CategorySelectionViewModelInputs, CategorySelectionViewModelOutputs {
  private static let minimumCategorySelectionCount: Int = 5

  public init() {
    let categoriesEvent = self.viewDidLoadProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService
          .fetchGraphCategories(query: rootCategoriesQuery)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { $0.rootCategories }
          .materialize()
      }

    let orderedCategories = categoriesEvent.values().map(categoriesOrderedByPopularity)

    self.loadCategorySections = orderedCategories.map(categoryData(from:))

    let selectedCategoryIndexes = self.categorySelectedWithValueProperty.signal.skipNil()
      .map(first)
      .scan(Set<IndexPath>.init(), updatedSelectedValues(selectedValues:currentValue:))

    let selectedCategoryIds = self.categorySelectedWithValueProperty.signal.skipNil()
      .map(second)
      .scan(Set<Int>.init(), updatedSelectedValues(selectedValues:currentValue:))

    self.selectCellAtIndexProperty <~ selectedCategoryIndexes
      .takePairWhen(self.shouldSelectCellAtIndexProperty.signal.skipNil())
      .map { selectedCategoryIndexes, shouldSelectIndex in
        selectedCategoryIndexes.contains(shouldSelectIndex)
      }

    self.goToCuratedProjects = selectedCategoryIds
      .takeWhen(self.continueButtonTappedProperty.signal)
      .map { $0.sorted() }
      .map(Array.init)

    let selectedCategoriesCount = selectedCategoryIndexes.map { $0.count }

    self.continueButtonEnabled = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(0),
      selectedCategoriesCount
    )
    .map { $0 > 0 && $0 <= CategorySelectionViewModel.minimumCategorySelectionCount }
    .skipRepeats()

    self.warningLabelIsHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(0),
      selectedCategoriesCount
    )
    .map { $0 > CategorySelectionViewModel.minimumCategorySelectionCount }
    .negate()
    .skipRepeats()
  }

  private let categorySelectedWithValueProperty = MutableProperty<(IndexPath, Int)?>(nil)
  public func categorySelected(with value: (IndexPath, Int)) {
    self.categorySelectedWithValueProperty.value = value
  }

  private let continueButtonTappedProperty = MutableProperty(())
  public func continueButtonTapped() {
    self.continueButtonTappedProperty.value = ()
  }

  private let shouldSelectCellAtIndexProperty = MutableProperty<IndexPath?>(nil)
  private let selectCellAtIndexProperty = MutableProperty<Bool>(false)
  public func shouldSelectCell(at index: IndexPath) -> Bool {
    self.shouldSelectCellAtIndexProperty.value = index

    return self.selectCellAtIndexProperty.value
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let continueButtonEnabled: Signal<Bool, Never>
  public let goToCuratedProjects: Signal<[Int], Never>
  public let loadCategorySections: Signal<([String], [[(String, Int)]]), Never>
  public let warningLabelIsHidden: Signal<Bool, Never>

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

private func categoryData(from rootCategories: [KsApi.Category]) -> ([String], [[(String, Int)]]) {
  var sectionTitles = [String]()
  let categoriesData = rootCategories.compactMap { category -> [(String, Int)]? in
    guard let categoryId = category.intID, let subcategories = category.subcategories?.nodes else {
      return nil
    }

    sectionTitles.append(category.name)

    let subcategoryData = subcategories.compactMap { subcategory -> (String, Int)? in
      guard let subcategoryId = subcategory.intID else {
        return nil
      }

      return (subcategory.name, subcategoryId)
    }

    let allProjects = (Strings.All_category_name_Projects(category_name: category.name), categoryId)

    return [allProjects] + subcategoryData
  }

  return (sectionTitles, categoriesData)
}

private func updatedSelectedValues<T: Hashable>(selectedValues: Set<T>, currentValue: T) -> Set<T> {
  var updatedValues = selectedValues

  if selectedValues.contains(currentValue) {
    updatedValues.remove(currentValue)
  } else {
    updatedValues.insert(currentValue)
  }

  return updatedValues
}
