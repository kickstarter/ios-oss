import Foundation
import KsApi
import ReactiveSwift

public protocol CancelBackingViewModelOutputs {

}

public protocol CancelBackingViewModelInputs {
  func configure(with project: Project, backing: Backing)
  func viewDidLoad()
}

public protocol CancelBackingViewModelType {
  var inputs: CancelBackingViewModelInputs { get }
  var outputs: CancelBackingViewModelOutputs { get }
}


public final class CancelBackingViewModel: CancelBackingViewModelType, CancelBackingViewModelInputs,
CancelBackingViewModelOutputs {
  public init() {}

  private let configureWithProjectAndBackingProperty = MutableProperty<(Project, Backing)?>(nil)
  public func configure(with project: Project, backing: Backing) {
    self.configureWithProjectAndBackingProperty.value = (project, backing)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public var inputs: CancelBackingViewModelInputs { return self }
  public var outputs: CancelBackingViewModelOutputs { return self }
}
