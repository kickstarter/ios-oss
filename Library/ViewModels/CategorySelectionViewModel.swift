import Foundation
import KsApi
import ReactiveSwift

public protocol CategorySelectionViewModelInputs {
  func categorySelected(at index: IndexPath)
  func continueButtonTapped()
  func viewDidLoad()
}

public protocol CategorySelectionViewModelOutputs {
  var continueButtonEnabled: Signal<Bool, Never> { get }
  var goToCuratedProjects: Signal<[Int], Never> { get }
  // A tuple of Section Titles: [String], and Categories Section Data: [[String]]
  var loadCategorySections: Signal<([String], [[String]]), Never> { get }
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

    self.loadCategorySections = orderedCategories.map { rootCategories in
      var sectionTitles = [String]()
      let categoriesData = rootCategories.compactMap { category -> [String]? in
        guard let subcategories = category.subcategories?.nodes else {
          return nil
        }

        let subcategoryNames = subcategories.map { $0.name }
        sectionTitles.append(category.name)

        return [Strings.All_category_name_Projects(category_name: category.name)] + subcategoryNames
      }

      return (sectionTitles, categoriesData)
    }

    let selectedCategoryIndexes = self.categorySelectedAtIndexPathProperty.signal.skipNil()
      .scan(Set<IndexPath>.init()) { (selectedIndexes, currentIndexPath) -> Set<IndexPath> in
        var updatedIndexes = selectedIndexes

        if selectedIndexes.contains(currentIndexPath) {
          updatedIndexes.remove(currentIndexPath)
        } else {
          updatedIndexes.insert(currentIndexPath)
        }

        return updatedIndexes
      }

    self.selectCellAtIndexProperty <~ selectedCategoryIndexes
      .takePairWhen(self.shouldSelectCellAtIndexProperty.signal.skipNil())
      .map { selectedCategoryIndexes, shouldSelectIndex in
        selectedCategoryIndexes.contains(shouldSelectIndex)
      }

    self.goToCuratedProjects = Signal.combineLatest(selectedCategoryIndexes, orderedCategories)
      .takeWhen(self.continueButtonTappedProperty.signal)
      .map(selectedCategoryIds(from:allCategories:))

    let selectedCategoriesCount = selectedCategoryIndexes.map { $0.count }

    self.continueButtonEnabled = Signal.merge(self.viewDidLoadProperty.signal.mapConst(0),
                                              selectedCategoriesCount)
      .map {  0 < $0 && $0 < CategorySelectionViewModel.minimumCategorySelectionCount }

    self.warningLabelIsHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(0),
      selectedCategoriesCount
    )
      .map { $0 > CategorySelectionViewModel.minimumCategorySelectionCount }
      .negate()
  }

  private let categorySelectedAtIndexPathProperty = MutableProperty<IndexPath?>(nil)
  public func categorySelected(at index: IndexPath) {
    self.categorySelectedAtIndexPathProperty.value = index
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
  public let loadCategorySections: Signal<([String], [[String]]), Never>
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

// TODO: this is the naive approach - refactor to send categoryId as part of `categorySelected` input
private func selectedCategoryIds(from selectedIndexes: Set<IndexPath>, allCategories: [KsApi.Category])
  -> [Int] {
  var selectedCategoryIds = [Int?](repeating: nil, count: selectedIndexes.count)

  selectedIndexes.forEach { indexPath in
    let parentCategory = allCategories[indexPath.section]

    if indexPath.row == 0 {
      // First pill in every section is the "All [Category] Projects", so we just use the parent category id

      selectedCategoryIds.append(parentCategory.intID)

      return
    }

    let subcategoryId = parentCategory.subcategories?.nodes[indexPath.row - 1].intID

    selectedCategoryIds.append(subcategoryId)
  }

  return selectedCategoryIds.compact()
}
