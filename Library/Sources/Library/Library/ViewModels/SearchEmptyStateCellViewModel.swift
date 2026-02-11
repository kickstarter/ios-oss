import KsApi
import ReactiveSwift

public struct SearchEmptyStateSearchData {
  public let query: String?
  public let hasFilters: Bool

  public init(query: String?, hasFilters: Bool) {
    self.query = query
    self.hasFilters = hasFilters
  }
}

public protocol SearchEmptyStateCellViewModelInputs {
  func configureWith(data: SearchEmptyStateSearchData)
}

public protocol SearchEmptyStateCellViewModelOutputs {
  var titleText: Signal<String, Never> { get }
  var subtitleText: Signal<String, Never> { get }
  var hideClearFiltersButton: Signal<Bool, Never> { get }
}

public protocol SearchEmptyStateCellViewModelType {
  var inputs: SearchEmptyStateCellViewModelInputs { get }
  var outputs: SearchEmptyStateCellViewModelOutputs { get }
}

public final class SearchEmptyStateCellViewModel: SearchEmptyStateCellViewModelType,
  SearchEmptyStateCellViewModelInputs, SearchEmptyStateCellViewModelOutputs {
  public init() {
    self.titleText = self.searchDataProperty.signal
      .skipNil()
      .map { searchData in
        if let query = searchData.query, query.count > 0 {
          return Strings.No_results_for(query: query)
        }
        return Strings.No_results()
      }

    self.subtitleText = self.searchDataProperty.signal
      .skipNil()
      .map { searchData in
        if searchData.hasFilters && searchData.query?.isEmpty == false {
          return Strings.Try_rephrasing_your_search_or_adjusting_the_filters()
        } else if searchData.hasFilters {
          return Strings.Try_adjusting_the_filters()
        }
        return Strings.Try_rephrasing_your_search()
      }

    self.hideClearFiltersButton = self.searchDataProperty.signal
      .skipNil()
      .map { !$0.hasFilters }
  }

  fileprivate let searchDataProperty = MutableProperty<SearchEmptyStateSearchData?>(nil)
  public func configureWith(data: SearchEmptyStateSearchData) {
    self.searchDataProperty.value = data
  }

  public let titleText: Signal<String, Never>
  public let subtitleText: Signal<String, Never>
  public let hideClearFiltersButton: Signal<Bool, Never>

  public var inputs: SearchEmptyStateCellViewModelInputs { return self }
  public var outputs: SearchEmptyStateCellViewModelOutputs { return self }
}
