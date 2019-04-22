import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol PledgeDescriptionCellViewModelInputs {
  func tapped()
}

public protocol PledgeDescriptionCellViewModelOutputs {
  var presentTrustAndSafety: Signal<Void, NoError> { get }
}

public protocol PledgeDescriptionCellViewModelType {
  var inputs: PledgeDescriptionCellViewModelInputs { get }
  var outputs: PledgeDescriptionCellViewModelOutputs { get }
}

public final class PledgeDescriptionCellViewModel: PledgeDescriptionCellViewModelType,
PledgeDescriptionCellViewModelInputs, PledgeDescriptionCellViewModelOutputs {

  public init() {
    self.presentTrustAndSafety = self.tappedProperty.signal.map {
      $0
      print("THIS")
    }
  }

  private let tappedProperty = MutableProperty(())
  public func tapped() {
    self.tappedProperty.value = ()
  }

  public let presentTrustAndSafety: Signal<Void, NoError>

  public var inputs: PledgeDescriptionCellViewModelInputs { return self }
  public var outputs: PledgeDescriptionCellViewModelOutputs { return self }
}
