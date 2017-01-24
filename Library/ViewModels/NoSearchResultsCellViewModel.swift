import KsApi
import ReactiveSwift
import Result

public protocol NoSearchResultsCellViewModelInputs {
  func configureWith(param: DiscoveryParams)
}

public protocol NoSearchResultsCellViewModelOutputs {
  var searchTermNotFound: Signal<String, NoError> { get }
}

public protocol NoSearchResultsCellViewModelType {
  var inputs: NoSearchResultsCellViewModelInputs { get }
  var outputs: NoSearchResultsCellViewModelOutputs { get }
}

public final class NoSearchResultsCellViewModel: NoSearchResultsCellViewModelType,
NoSearchResultsCellViewModelInputs, NoSearchResultsCellViewModelOutputs {

  public init() {
    self.searchTermNotFound = self.paramProperty.signal
      .skipNil()
      .map { param in Strings.We_couldnt_find_anything_for_search_term(search_term: param.query ?? "") }
  }

  fileprivate let paramProperty = MutableProperty<DiscoveryParams?>(nil)
  public func configureWith(param: DiscoveryParams) {
    self.paramProperty.value = param
  }

  public let searchTermNotFound: Signal<String, NoError>

  public var inputs: NoSearchResultsCellViewModelInputs { return self }
  public var outputs: NoSearchResultsCellViewModelOutputs { return self }
}
