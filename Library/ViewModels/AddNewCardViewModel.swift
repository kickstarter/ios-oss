import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol AddNewCardViewModelInputs {
  func paymentInfo(valid: Bool)
}

public protocol AddNewCardViewModelOutputs {
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }
}

public protocol AddNewCardViewModelType {
  var inputs: AddNewCardViewModelInputs { get }
  var outputs: AddNewCardViewModelOutputs { get }
}

public final class AddNewCardViewModel: AddNewCardViewModelType, AddNewCardViewModelInputs, AddNewCardViewModelOutputs {

  public init() {

    self.saveButtonIsEnabled = self.paymentInfoIsValidProperty.signal

  }

  fileprivate let paymentInfoIsValidProperty = MutableProperty(false)
  public func paymentInfo(valid: Bool) {
    self.paymentInfoIsValidProperty.value = valid
  }

  public let saveButtonIsEnabled: Signal<Bool, NoError>

  public var inputs: AddNewCardViewModelInputs { return self }
  public var outputs: AddNewCardViewModelOutputs { return self }
}
