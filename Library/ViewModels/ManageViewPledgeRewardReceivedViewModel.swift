import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol ManageViewPledgeRewardReceivedViewModelInputs {
  func configureWith(_ project: Project)
  func rewardReceivedToggleTapped(isOn: Bool)
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

    let backer = project
      .map { _ in AppEnvironment.current.currentUser }
      .skipNil()

    let rewardReceivedEvent = Signal.combineLatest(
      project,
      backer
    )
    .takePairWhen(self.rewardReceivedToggleTappedProperty.signal)
    .map(unpack)
    .switchMap { project, backer, received in
      AppEnvironment.current.apiService.backingUpdate(
        forProject: project, forUser: backer, received: received
      )
      .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
      .materialize()
    }

    let markedReceivedBacking = rewardReceivedEvent.values().map { $0 }

    let initialRewardReceived = project
      .map { $0.personalization.backing?.backerCompleted }
      .map { $0.coalesceWith(false) }

    let updatedRewardReceived = markedReceivedBacking
      .map { $0.backerCompleted.coalesceWith(false) }

    self.rewardReceived = Signal.merge(
      initialRewardReceived,
      updatedRewardReceived
    )
  }

  private let configureWithProjectProperty = MutableProperty<Project?>(nil)
  public func configureWith(_ project: Project) {
    self.configureWithProjectProperty.value = project
  }

  private let rewardReceivedToggleTappedProperty = MutableProperty<Bool>(false)
  public func rewardReceivedToggleTapped(isOn: Bool) {
    self.rewardReceivedToggleTappedProperty.value = isOn
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let rewardReceived: Signal<Bool, Never>

  public var inputs: ManageViewPledgeRewardReceivedViewModelInputs { return self }
  public var outputs: ManageViewPledgeRewardReceivedViewModelOutputs { return self }
}
