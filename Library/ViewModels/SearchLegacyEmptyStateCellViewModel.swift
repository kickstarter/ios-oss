import KsApi
import ReactiveSwift

public protocol SearchLegacyEmptyStateCellViewModelInputs {
  func configureWith(param: DiscoveryParams)
}

public protocol SearchLegacyEmptyStateCellViewModelOutputs {
  var searchTermNotFoundLabelText: Signal<String, Never> { get }
}

public protocol SearchLegacyEmptyStateCellViewModelType {
  var inputs: SearchLegacyEmptyStateCellViewModelInputs { get }
  var outputs: SearchLegacyEmptyStateCellViewModelOutputs { get }
}

public final class SearchLegacyEmptyStateCellViewModel: SearchLegacyEmptyStateCellViewModelType,
  SearchLegacyEmptyStateCellViewModelInputs, SearchLegacyEmptyStateCellViewModelOutputs {
  public init() {
    self.searchTermNotFoundLabelText = self.paramProperty.signal
      .skipNil()
      .map { param in Strings.We_couldnt_find_anything_for_search_term(search_term: param.query ?? "") }
  }

  fileprivate let paramProperty = MutableProperty<DiscoveryParams?>(nil)
  public func configureWith(param: DiscoveryParams) {
    self.paramProperty.value = param
  }

  public let searchTermNotFoundLabelText: Signal<String, Never>

  public var inputs: SearchLegacyEmptyStateCellViewModelInputs { return self }
  public var outputs: SearchLegacyEmptyStateCellViewModelOutputs { return self }
}
