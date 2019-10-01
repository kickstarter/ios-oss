import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol CancelPledgeViewModelInputs {
  func configure(with project: Project, backing: Backing)
  func goBackButtonTapped()
  func traitCollectionDidChange()
  func viewDidLoad()
}

public protocol CancelPledgeViewModelOutputs {
  var cancellationDetailsTextLabelValue: Signal<(amount: String, projectName: String), Never> { get }
  var popCancelPledgeViewController: Signal<Void, Never> { get }
}

public protocol CancelPledgeViewModelType {
  var inputs: CancelPledgeViewModelInputs { get }
  var outputs: CancelPledgeViewModelOutputs { get }
}

public final class CancelPledgeViewModel: CancelPledgeViewModelType, CancelPledgeViewModelInputs,
  CancelPledgeViewModelOutputs {
  public init() {
    let initialData = Signal.combineLatest(
      self.configureWithProjectAndBackingProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    self.cancellationDetailsTextLabelValue = Signal.merge(
      initialData,
      initialData.takeWhen(self.traitCollectionDidChangeProperty.signal)
    )
    .map { project, backing in
      let formattedAmount = Format.currency(
        backing.amount,
        country: project.country,
        omitCurrencyCode: project.stats.omitUSCurrencyCode
      )
      return (formattedAmount, project.name)
    }

    self.popCancelPledgeViewController = self.goBackButtonTappedProperty.signal
  }

  private let configureWithProjectAndBackingProperty = MutableProperty<(Project, Backing)?>(nil)
  public func configure(with project: Project, backing: Backing) {
    self.configureWithProjectAndBackingProperty.value = (project, backing)
  }

  private let goBackButtonTappedProperty = MutableProperty(())
  public func goBackButtonTapped() {
    self.goBackButtonTappedProperty.value = ()
  }

  private let traitCollectionDidChangeProperty = MutableProperty(())
  public func traitCollectionDidChange() {
    self.traitCollectionDidChangeProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let cancellationDetailsTextLabelValue: Signal<(amount: String, projectName: String), Never>
  public let popCancelPledgeViewController: Signal<Void, Never>

  public var inputs: CancelPledgeViewModelInputs { return self }
  public var outputs: CancelPledgeViewModelOutputs { return self }
}
