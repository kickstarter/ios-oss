import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol ManageViewPledgeRewardReceivedViewModelInputs {
  func configureWith(_ project: Project)
  func viewDidLoad()
}

public protocol ManageViewPledgeRewardReceivedViewModelOutputs {
  var rewardReceived: Signal<Bool, Never> { get }
}

public protocol ManageViewPledgeRewardReceivedViewModelType {
  var inputs: ManageViewPledgeRewardReceivedViewModelInputs { get }
  var outputs: ManageViewPledgeRewardReceivedViewModelOutputs { get }
}

public class ManageViewPledgeRewardReceivedViewModel:
  ManageViewPledgeRewardReceivedViewModelType,
  ManageViewPledgeRewardReceivedViewModelInputs,
ManageViewPledgeRewardReceivedViewModelOutputs {
  public init() {
    let project = Signal.combineLatest(
      self.configureWithProjectProperty.signal,
      self.viewDidLoadSignal
    )
    .map(first)
    .skipNil()

    self.rewardReceived = project
      .map { $0.personalization.backing?.backerCompleted }
      .map { $0.coalesceWith(false) }
  }

  private let configureWithProjectProperty = MutableProperty<Project?>(nil)
  public func configureWith(_ project: Project) {
    self.configureWithProjectProperty.value = project
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }


  public let rewardReceived: Signal<Bool, Never>

  public var inputs: ManageViewPledgeRewardReceivedViewModelInputs { return self }
  public var outputs: ManageViewPledgeRewardReceivedViewModelOutputs { return self }
}
