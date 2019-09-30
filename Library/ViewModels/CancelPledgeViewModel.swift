import Foundation
import KsApi
import ReactiveSwift

public protocol CancelPledgeViewModelOutputs {}

public protocol CancelPledgeViewModelInputs {
  func configure(with project: Project, backing: Backing)
  func viewDidLoad()
}

public protocol CancelPledgeViewModelType {
  var inputs: CancelPledgeViewModelInputs { get }
  var outputs: CancelPledgeViewModelOutputs { get }
}

public final class CancelPledgeViewModel: CancelPledgeViewModelType, CancelPledgeViewModelInputs,
  CancelPledgeViewModelOutputs {
  public init() {}

  private let configureWithProjectAndBackingProperty = MutableProperty<(Project, Backing)?>(nil)
  public func configure(with project: Project, backing: Backing) {
    self.configureWithProjectAndBackingProperty.value = (project, backing)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public var inputs: CancelPledgeViewModelInputs { return self }
  public var outputs: CancelPledgeViewModelOutputs { return self }
}
