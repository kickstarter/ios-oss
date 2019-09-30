import Foundation
import KsApi
import ReactiveSwift
import Prelude

public protocol CancelPledgeViewModelOutputs {
  var cancellationDetailsTextLabelValue: Signal<(amount: String, projectName: String), Never> { get }
}

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
  public init() {
    let initialData = Signal.combineLatest(self.configureWithProjectAndBackingProperty.signal.skipNil(),
                                           self.viewDidLoadProperty.signal)
      .map(first)

    self.cancellationDetailsTextLabelValue = initialData
      .map { project, backing in
        let formattedAmount = Format.currency(backing.amount,
                                     country: project.country,
                                     omitCurrencyCode: project.stats.omitUSCurrencyCode)
        return (formattedAmount, project.name)
    }
  }

  private let configureWithProjectAndBackingProperty = MutableProperty<(Project, Backing)?>(nil)
  public func configure(with project: Project, backing: Backing) {
    self.configureWithProjectAndBackingProperty.value = (project, backing)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let cancellationDetailsTextLabelValue: Signal<(amount: String, projectName: String), Never>

  public var inputs: CancelPledgeViewModelInputs { return self }
  public var outputs: CancelPledgeViewModelOutputs { return self }
}
