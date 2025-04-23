import Combine
import Foundation

protocol FilterCategory: Identifiable, Equatable {
  var name: String { get }
  var availableSubcategories: [Self]? { get }
  var projectCount: Int? { get }
}

protocol FilterCategoryViewModelInputs {
  associatedtype T: FilterCategory
  func selectCategory(_ category: T, subcategory: T?)
  func seeResults()
  func close()
  func resetSelection()
}

protocol FilterCategoryViewModelOutputs {
  associatedtype T: FilterCategory
  var selectedCategory: AnyPublisher<(T, subcategory: T?)?, Never> { get }
  var seeResultsTapped: AnyPublisher<Void, Never> { get }
  var closeTapped: AnyPublisher<Void, Never> { get }
  var categories: [T] { get }
  var canReset: Bool { get }
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
      .map { $0?.0 }
      .receive(on: RunLoop.main)
      .assign(to: &self.$currentCategory)

    self.selectedCategorySubject
      .map { $0?.1 }
      .receive(on: RunLoop.main)
      .assign(to: &self.$currentSubcategory)

    if let category = selectedCategory {
      self.selectCategory(category, subcategory: nil)
    }
  }

  // MARK: - Inputs

  func selectCategory(_ category: T, subcategory: T? = nil) {
    self.selectedCategorySubject.send((category, subcategory: subcategory))
  }

  func resetSelection() {
    self.selectedCategorySubject.send(nil)
  }

  func seeResults() {
    self.seeResultsTappedSubject.send()
  }

  func close() {
    self.closeTappedSubject.send()
  }

  // MARK: - Outputs

  var selectedCategory: AnyPublisher<(T, subcategory: T?)?, Never> {
    self.selectedCategorySubject.eraseToAnyPublisher()
  }

  var seeResultsTapped: AnyPublisher<Void, Never> {
    self.seeResultsTappedSubject.eraseToAnyPublisher()
  }

  var closeTapped: AnyPublisher<Void, Never> {
    self.closeTappedSubject.eraseToAnyPublisher()
  }

  private let selectedCategorySubject = PassthroughSubject<(T, subcategory: T?)?, Never>()
  private let seeResultsTappedSubject = PassthroughSubject<Void, Never>()
  private let closeTappedSubject = PassthroughSubject<Void, Never>()

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

  var projectCount: Int? {
    42
  }
}
