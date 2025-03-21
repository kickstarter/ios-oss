import Combine
import Foundation
import Library

protocol SortViewModelInputs {
  func selectSortOption(_ option: SortOption)
  func close()
}

protocol SortViewModelOutputs {
  var selectedSortOption: AnyPublisher<SortOption, Never> { get }
  var closeTapped: AnyPublisher<Void, Never> { get }
  var sortOptions: [SortOption] { get }
  func isSortOptionSelected(_ option: SortOption) -> Bool
}

typealias SortViewModelType = ObservableObject &
  SortViewModelInputs &
  SortViewModelOutputs

class SortViewModel: SortViewModelType {
  @Published private(set) var sortOptions: [SortOption]
  @Published private var currentSortOption: SortOption

  init(sortOption: SortOption = .recommended) {
    self.currentSortOption = sortOption

    self.sortOptions = SortOption.allCases

    self.selectedSortOptionSubject
      .receive(on: RunLoop.main)
      .assign(to: &self.$currentSortOption)
  }

  // MARK: - Inputs

  func selectSortOption(_ option: SortOption) {
    self.selectedSortOptionSubject.send(option)
  }

  func close() {
    self.closeTappedSubject.send()
  }

  // MARK: - Outputs

  var selectedSortOption: AnyPublisher<SortOption, Never> {
    self.selectedSortOptionSubject.eraseToAnyPublisher()
  }

  var closeTapped: AnyPublisher<Void, Never> {
    self.closeTappedSubject.eraseToAnyPublisher()
  }

  private let selectedSortOptionSubject = PassthroughSubject<SortOption, Never>()
  private let closeTappedSubject = PassthroughSubject<Void, Never>()

  func isSortOptionSelected(_ option: SortOption) -> Bool {
    return self.currentSortOption == option
  }
}

enum SortOption: Int, Identifiable, CaseIterable {
  case recommended
  case popularity
  case newest
  case endDate

  var id: Int {
    self.rawValue
  }

  var name: String {
    switch self {
    case .recommended: Strings.Recommended()
    case .popularity: Strings.Popularity()
    case .newest: Strings.Newest()
    case .endDate: Strings.End_date()
    }
  }
}
