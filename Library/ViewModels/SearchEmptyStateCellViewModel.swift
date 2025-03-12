import KsApi
import ReactiveSwift

public protocol SearchEmptyStateCellViewModelInputs {
  func configureWith(queryString: String?)
}

public protocol SearchEmptyStateCellViewModelOutputs {
  var searchTermNotFoundLabelText: Signal<String, Never> { get }
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
      .map { param in Strings.We_couldnt_find_anything_for_search_term(search_term: param) }
  }

  fileprivate let paramProperty = MutableProperty<String?>(nil)
  public func configureWith(queryString: String?) {
    self.paramProperty.value = queryString
  }

  public let searchTermNotFoundLabelText: Signal<String, Never>

  public var inputs: SearchEmptyStateCellViewModelInputs { return self }
  public var outputs: SearchEmptyStateCellViewModelOutputs { return self }
}
