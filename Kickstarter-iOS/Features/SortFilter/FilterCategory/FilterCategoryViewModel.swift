import Combine
import Foundation

typealias CategoryAndSubcategory<T> = (category: T, subcategory: T?)

protocol FilterCategory: Identifiable, Equatable {
  var name: String { get }
  var availableSubcategories: [Self]? { get }
}

protocol FilterCategoryViewModelInputs {
  associatedtype T: FilterCategory
  func selectCategory(_ category: T, subcategory: T?)
}

protocol FilterCategoryViewModelOutputs {
  associatedtype T: FilterCategory
  var selectedCategory: AnyPublisher<CategoryAndSubcategory<T>?, Never> { get }
  var categories: [T] { get }
  var isLoading: Bool { get }
  func isCategorySelected(_ category: T) -> Bool
  func isSubcategorySelected(_ category: T?) -> Bool
}

typealias FilterCategoryViewModelType =
  FilterCategoryViewModelInputs &
  FilterCategoryViewModelOutputs & ObservableObject

class FilterCategoryViewModel<T: FilterCategory>: FilterCategoryViewModelType {
  @Published private(set) var categories: [T] = []
  @Published private(set) var canReset: Bool = false
  @Published private var currentCategory: T? = nil
  @Published private var currentSubcategory: T? = nil

  private var cancellables: Set<AnyCancellable> = []

  var isLoading: Bool {
    self.categories.isEmpty
  }

  init(with categories: [T], selectedCategory: T? = nil) {
    self.categories = categories

    self.selectedCategorySubject
      .map { $0 != nil }
      .receive(on: RunLoop.main)
      .assign(to: &self.$canReset)

    self.selectedCategorySubject
      .map { $0?.category }
      .receive(on: RunLoop.main)
      .assign(to: &self.$currentCategory)

    self.selectedCategorySubject
      .map { $0?.subcategory }
      .receive(on: RunLoop.main)
      .assign(to: &self.$currentSubcategory)

    if let category = selectedCategory {
      self.selectInitialCategory(selectedCategory: category)
    }
  }

  private func selectInitialCategory(selectedCategory: T) {
    for category in self.categories {
      if category == selectedCategory {
        self.selectCategory(category, subcategory: nil)
        return
      }

      guard let subcategories = category.availableSubcategories else {
        continue
      }

      for subcategory in subcategories {
        if subcategory == selectedCategory {
          self.selectCategory(category, subcategory: subcategory)
          return
        }
      }
    }
  }

  // MARK: - Inputs

  func selectCategory(_ category: T, subcategory: T? = nil) {
    self.selectedCategorySubject.send((category: category, subcategory: subcategory))
  }

  func resetSelection() {
    self.selectedCategorySubject.send(nil)
  }

  // MARK: - Outputs

  var selectedCategory: AnyPublisher<CategoryAndSubcategory<T>?, Never> {
    self.selectedCategorySubject.eraseToAnyPublisher()
  }

  private let selectedCategorySubject = PassthroughSubject<CategoryAndSubcategory<T>?, Never>()

  func isCategorySelected(_ category: T) -> Bool {
    self.currentCategory?.id == category.id
  }

  func isSubcategorySelected(_ subcategory: T?) -> Bool {
    self.currentSubcategory == subcategory
  }
}

internal enum ConcreteFilterCategory: String, FilterCategory, CaseIterable {
  case categoryOne = "Category One"
  case categoryTwo = "Category Two"
  case categoryThree = "Category Three"
  case categoryFour = "Category Four"
  case categoryFive = "Category Five"

  var id: Int {
    return self.rawValue.hashValue
  }

  var name: String {
    return self.rawValue
  }

  var availableSubcategories: [ConcreteFilterCategory]? {
    return Self.allCases
  }
}
