import Combine
import Foundation
import Library

public protocol SortOption: Identifiable, Equatable {
  var name: String { get }
}

protocol SortViewModelInputs {
  associatedtype T: SortOption
  func selectSortOption(_ option: T)
  func close()
}

protocol SortViewModelOutputs {
  associatedtype T: SortOption
  var selectedSortOption: AnyPublisher<T, Never> { get }
  var closeTapped: AnyPublisher<Void, Never> { get }
  var sortOptions: [T] { get }
  func isSortOptionSelected(_ option: T) -> Bool
}

typealias SortViewModelType = ObservableObject &
  SortViewModelInputs &
  SortViewModelOutputs

class SortViewModel<T: SortOption>: SortViewModelType {
  @Published private(set) var sortOptions: [T]
  @Published private var currentSortOption: T

  init(sortOptions: [T], selectedSortOption sortOption: T) {
    self.currentSortOption = sortOption

    self.sortOptions = sortOptions

    self.selectedSortOptionSubject
      .receive(on: RunLoop.main)
      .assign(to: &self.$currentSortOption)
  }

  // MARK: - Inputs

  func selectSortOption(_ option: T) {
    self.selectedSortOptionSubject.send(option)
  }

  func close() {
    self.closeTappedSubject.send()
  }

  // MARK: - Outputs

  var selectedSortOption: AnyPublisher<T, Never> {
    self.selectedSortOptionSubject.eraseToAnyPublisher()
  }

  var closeTapped: AnyPublisher<Void, Never> {
    self.closeTappedSubject.eraseToAnyPublisher()
  }

  private let selectedSortOptionSubject = PassthroughSubject<T, Never>()
  private let closeTappedSubject = PassthroughSubject<Void, Never>()

  func isSortOptionSelected(_ option: T) -> Bool {
    return self.currentSortOption == option
  }
}

internal enum ConcreteSortOption: String, SortOption, CaseIterable {
  var name: String {
    return self.rawValue
  }

  var id: Int {
    return self.rawValue.hashValue
  }

  case sortOne = "Sort One"
  case sortTwo = "Sort Two"
  case sortThree = "Sort Three"
}
