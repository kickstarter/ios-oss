import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol PledgeViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func continueButtonTapped()
  func userSessionStarted()
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var goToLoginSignup: Signal<LoginIntent, Never> { get }
  var reloadWithData: Signal<(Project, Reward, Bool), Never> { get }
}

public protocol PledgeViewModelType {
  var inputs: PledgeViewModelInputs { get }
  var outputs: PledgeViewModelOutputs { get }
}

public class PledgeViewModel: PledgeViewModelType, PledgeViewModelInputs, PledgeViewModelOutputs {
  public init() {
    let projectAndReward = Signal.combineLatest(
      self.configureProjectAndRewardProperty.signal, self.viewDidLoadProperty.signal
    )
    .map(first)
    .skipNil()

    let project = projectAndReward.map(first)
    let reward = projectAndReward.map(second)
    let isLoggedIn = Signal.merge(projectAndReward.ignoreValues(), userSessionStartedSignal)
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    self.reloadWithData = Signal.combineLatest(project, reward, isLoggedIn)

    self.goToLoginSignup = continueButtonTappedSignal
      .map { _ in LoginIntent.backProject }
  }

  private let (continueButtonTappedSignal, continueButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func continueButtonTapped() {
    self.continueButtonTappedObserver.send(value: ())
  }

  private let configureProjectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.configureProjectAndRewardProperty.value = (project, reward)
  }

  private let (userSessionStartedSignal, userSessionStartedObserver) = Signal<Void, Never>.pipe()
  public func userSessionStarted() {
    self.userSessionStartedObserver.send(value: ())
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let goToLoginSignup: Signal<LoginIntent, Never>
  public let reloadWithData: Signal<(Project, Reward, Bool), Never>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}
