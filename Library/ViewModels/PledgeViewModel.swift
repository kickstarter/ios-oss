import KsApi
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol PledgeViewModelInputs {
  func configure(with project: Project)
}

public protocol PledgeViewModelOutputs {

}

public protocol PledgeViewModelType {
  var inputs: PledgeViewModelInputs { get }
  var outputs: PledgeViewModelOutputs { get }
}

public class PledgeViewModel:
  PledgeViewModelType,
  PledgeViewModelInputs,
PledgeViewModelOutputs {
  public init() {
    self.configureProjectProperty.signal
      .skipNil()
      .observeValues { project in
        print("*** :\(project.name)")
    }
  }

  private let configureProjectProperty = MutableProperty<Project?>(nil)
  public func configure(with project: Project) {
    self.configureProjectProperty.value = project
  }

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}
