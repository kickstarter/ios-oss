import Combine
import Foundation

protocol FilterCategory: Identifiable, Equatable {
  var name: String { get }
}

protocol FilterCategoryViewModelInputs {
  associatedtype T: FilterCategory
  func selectCategory(_ category: T)
  func seeResults()
  func close()
  func resetSelection()
}

protocol FilterCategoryViewModelOutputs {
  associatedtype T: FilterCategory
  var selectedCategory: AnyPublisher<T?, Never> { get }
  var seeResultsTapped: AnyPublisher<Void, Never> { get }
  var closeTapped: AnyPublisher<Void, Never> { get }
  var categories: [T] { get }
  var canReset: Bool { get }
  var isLoading: Bool { get }
  func isCategorySelected(_ category: T) -> Bool
}

typealias FilterCategoryViewModelType =
  FilterCategoryViewModelInputs &
  FilterCategoryViewModelOutputs & ObservableObject

class FilterCategoryViewModel<T: FilterCategory>: FilterCategoryViewModelType {
  @Published private(set) var categories: [T] = []
  @Published private(set) var canReset: Bool = false
  @Published private var currentCategory: T? = nil

  var isLoading: Bool {
    self.categories.isEmpty
  }

  init(with categories: [T]) {
    self.categories = categories

    self.selectedCategorySubject
      .map { $0 != nil }
      .receive(on: RunLoop.main)
      .assign(to: &self.$canReset)

    self.selectedCategorySubject
      .receive(on: RunLoop.main)
      .assign(to: &self.$currentCategory)
  }

  // MARK: - Inputs

  func selectCategory(_ category: T) {
    self.selectedCategorySubject.send(category)
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

  var selectedCategory: AnyPublisher<T?, Never> {
    self.selectedCategorySubject.eraseToAnyPublisher()
  }

  var seeResultsTapped: AnyPublisher<Void, Never> {
    self.seeResultsTappedSubject.eraseToAnyPublisher()
  }

  var closeTapped: AnyPublisher<Void, Never> {
    self.closeTappedSubject.eraseToAnyPublisher()
  }

  private let selectedCategorySubject = PassthroughSubject<T?, Never>()
  private let seeResultsTappedSubject = PassthroughSubject<Void, Never>()
  private let closeTappedSubject = PassthroughSubject<Void, Never>()

  func isCategorySelected(_ category: T) -> Bool {
    return self.currentCategory?.id == category.id
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
}
