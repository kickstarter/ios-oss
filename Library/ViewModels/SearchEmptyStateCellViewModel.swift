import KsApi
import ReactiveSwift
import Result

public protocol SearchEmptyStateCellViewModelInputs {
  func configureWith(param: DiscoveryParams)
}

public protocol SearchEmptyStateCellViewModelOutputs {
  var searchTermNotFoundLabelText: Signal<String, NoError> { get }
}

public protocol SearchEmptyStateCellViewModelType {
  var inputs: SearchEmptyStateCellViewModelInputs { get }
  var outputs: SearchEmptyStateCellViewModelOutputs { get }
}

public final class SearchEmptyStateCellViewModel: SearchEmptyStateCellViewModelType,
SearchEmptyStateCellViewModelInputs, SearchEmptyStateCellViewModelOutputs {

  public init() {
    self.searchTermNotFoundLabelText = self.paramProperty.signal
      .skipNil()
      .map { param in Strings.We_couldnt_find_anything_for_search_term(search_term: param.query ?? "") }
  }

  fileprivate let paramProperty = MutableProperty<DiscoveryParams?>(nil)
  public func configureWith(param: DiscoveryParams) {
    self.paramProperty.value = param
  }

  public let searchTermNotFoundLabelText: Signal<String, NoError>

  public var inputs: SearchEmptyStateCellViewModelInputs { return self }
  public var outputs: SearchEmptyStateCellViewModelOutputs { return self }
}
