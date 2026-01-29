import KsApi
import Prelude
import ReactiveSwift

public struct PledgeLocalPickupViewData: Equatable {
  public let locationName: String
}

public protocol PledgeLocalPickupViewModelInputs {
  func configure(with data: PledgeLocalPickupViewData)
}

public protocol PledgeLocalPickupViewModelOutputs {
  var locationLabelText: Signal<String, Never> { get }
}

public protocol PledgeLocalPickupViewModelType {
  var inputs: PledgeLocalPickupViewModelInputs { get }
  var outputs: PledgeLocalPickupViewModelOutputs { get }
}

public class PledgeLocalPickupViewModel: PledgeLocalPickupViewModelType,
  PledgeLocalPickupViewModelInputs, PledgeLocalPickupViewModelOutputs {
  public init() {
    let configData = self.configureWithDataProperty.signal.skipNil()

    self.locationLabelText = configData.map(\.locationName)
  }

  private let configureWithDataProperty = MutableProperty<PledgeLocalPickupViewData?>(nil)
  public func configure(with data: PledgeLocalPickupViewData) {
    self.configureWithDataProperty.value = data
  }

  public let locationLabelText: Signal<String, Never>

  public var inputs: PledgeLocalPickupViewModelInputs { return self }
  public var outputs: PledgeLocalPickupViewModelOutputs { return self }
}
