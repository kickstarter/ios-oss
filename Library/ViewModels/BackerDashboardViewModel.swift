import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol BackerDashboardViewModelInputs {

}

public protocol BackerDashboardViewModelOutputs {

}

public protocol BackerDashboardViewModelType {
  var inputs: BackerDashboardViewModelInputs { get }
  var outputs: BackerDashboardViewModelOutputs { get }
}

public final class BackerDashboardViewModel: BackerDashboardViewModelType, BackerDashboardViewModelInputs,
  BackerDashboardViewModelOutputs {

  public init() {

  }

  public var inputs: BackerDashboardViewModelInputs { return self }
  public var outputs: BackerDashboardViewModelOutputs { return self }
}
