import Combine
import Foundation

protocol FilterCategoryViewModelInputs {
  func selectCategory(_ category: FilterCategory)
  func seeResults()
  func close()
  func resetSelection()
}

protocol FilterCategoryViewModelOutputs {
  var selectedCategory: AnyPublisher<FilterCategory?, Never> { get }
  var seeResultsTapped: AnyPublisher<Void, Never> { get }
  var closeTapped: AnyPublisher<Void, Never> { get }
  var categories: [FilterCategory] { get }
  var canReset: Bool { get }
  var isLoading: Bool { get }
  func isCategorySelected(_ category: FilterCategory) -> Bool
}

typealias FilterCategoryViewModelType =
  FilterCategoryViewModelInputs &
  FilterCategoryViewModelOutputs & ObservableObject

class FilterCategoryViewModel: FilterCategoryViewModelType {
  @Published private(set) var categories: [FilterCategory] = []
  @Published private(set) var canReset: Bool = false
  @Published private var currentCategory: FilterCategory? = nil

  var isLoading: Bool {
    self.categories.isEmpty
  }

  init(with categories: [FilterCategory] = []) {
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

  func selectCategory(_ category: FilterCategory) {
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

  var selectedCategory: AnyPublisher<FilterCategory?, Never> {
    self.selectedCategorySubject.eraseToAnyPublisher()
  }

  var seeResultsTapped: AnyPublisher<Void, Never> {
    self.seeResultsTappedSubject.eraseToAnyPublisher()
  }

  var closeTapped: AnyPublisher<Void, Never> {
    self.closeTappedSubject.eraseToAnyPublisher()
  }

  private let selectedCategorySubject = PassthroughSubject<FilterCategory?, Never>()
  private let seeResultsTappedSubject = PassthroughSubject<Void, Never>()
  private let closeTappedSubject = PassthroughSubject<Void, Never>()

  func isCategorySelected(_ category: FilterCategory) -> Bool {
    return self.currentCategory?.id == category.id
  }
}

struct FilterCategory: Identifiable, Equatable {
  let id: String
  let name: String

  static func == (lhs: FilterCategory, rhs: FilterCategory) -> Bool {
    lhs.id == rhs.id
  }
}
