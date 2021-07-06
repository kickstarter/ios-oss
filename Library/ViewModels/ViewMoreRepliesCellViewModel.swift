import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ViewMoreRepliesCellViewModelInputs {
  func configureWith()
}

public protocol ViewMoreRepliesCellViewModelOutputs {}

public protocol ViewMoreRepliesCellViewModelType {
  var inputs: ViewMoreRepliesCellViewModelInputs { get }
  var outputs: ViewMoreRepliesCellViewModelOutputs { get }
}

public final class ViewMoreRepliesCellViewModel: ViewMoreRepliesCellViewModelType,
  ViewMoreRepliesCellViewModelInputs, ViewMoreRepliesCellViewModelOutputs {
  public init() {}

  fileprivate let configureWithProperty = MutableProperty(())
  public func configureWith() {
    self.configureWithProperty.value = ()
  }

  public var inputs: ViewMoreRepliesCellViewModelInputs { return self }
  public var outputs: ViewMoreRepliesCellViewModelOutputs { return self }
}
