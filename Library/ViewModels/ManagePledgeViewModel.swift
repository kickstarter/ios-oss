import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public enum ManagePledgeAlertAction: CaseIterable {
  case updatePledge
  case changePaymentMethod
  case chooseAnotherReward
  case contactCreator
  case cancelPledge
}

public protocol ManagePledgeViewModelInputs {
  func configureWith(_ project: Project, reward: Reward)
  func menuButtonTapped()
  func menuOptionSelected(with action: ManagePledgeAlertAction)
  func pledgeViewControllerDidUpdatePledgeWithMessage(_ message: String)
  func viewDidLoad()
}

public protocol ManagePledgeViewModelOutputs {
  var configurePaymentMethodView: Signal<GraphUserCreditCard.CreditCard, Never> { get }
  var configurePledgeSummaryView: Signal<Project, Never> { get }
  var configureRewardReceivedWithProject: Signal<Project, Never> { get }
  var configureRewardSummaryView: Signal<(Project, Either<Reward, Backing>), Never> { get }
  var goToCancelPledge: Signal<(Project, Backing), Never> { get }
  var goToChangePaymentMethod: Signal<Void, Never> { get }
  var goToContactCreator: Signal<Void, Never> { get }
  var goToRewards: Signal<Project, Never> { get }
  var goToUpdatePledge: Signal<(Project, Reward), Never> { get }
  var rewardReceivedViewControllerViewIsHidden: Signal<Bool, Never> { get }
  var showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never> { get }
  var showSuccessBannerWithMessage: Signal<String, Never> { get }
  var title: Signal<String, Never> { get }
}

public protocol ManagePledgeViewModelType {
  var inputs: ManagePledgeViewModelInputs { get }
  var outputs: ManagePledgeViewModelOutputs { get }
}

public final class ManagePledgeViewModel:
  ManagePledgeViewModelType, ManagePledgeViewModelInputs, ManagePledgeViewModelOutputs {
  public init() {
    let projectAndReward = self.projectAndRewardSignal
      .takeWhen(self.viewDidLoadSignal.ignoreValues())

    let project = projectAndReward.map(first)
    let backing = project
      .map { $0.personalization.backing }
      .skipNil()

    self.title = projectAndReward
      .map(first)
      .map(navigationBarTitle(with:))

    self.configurePaymentMethodView = projectAndReward
      .map(first)
      .map { $0.personalization.backing?.paymentSource }
      .skipNil()

    self.configurePledgeSummaryView = projectAndReward
      .map(first)

    self.configureRewardReceivedWithProject = project

    self.configureRewardSummaryView = projectAndReward
      .map { project, reward in (project, .left(reward)) }

    self.showActionSheetMenuWithOptions = project
      .takeWhen(self.menuButtonTappedSignal)
      .map { project -> [ManagePledgeAlertAction] in
        if project.state == .live {
          return ManagePledgeAlertAction.allCases
        } else {
          return [.contactCreator]
        }
      }

    self.goToUpdatePledge = projectAndReward
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .updatePledge })

    self.goToRewards = project
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .chooseAnotherReward })

    let cancelPledgeSelected = self.menuOptionSelectedSignal
      .filter { $0 == .cancelPledge }
      .ignoreValues()

    self.goToCancelPledge = Signal.combineLatest(project, backing)
      .takeWhen(cancelPledgeSelected)

    self.goToContactCreator = self.menuOptionSelectedSignal
      .filter { $0 == .contactCreator }
      .ignoreValues()

    self.goToChangePaymentMethod = self.menuOptionSelectedSignal
      .filter { $0 == .changePaymentMethod }
      .ignoreValues()

    self.rewardReceivedViewControllerViewIsHidden = projectAndReward
      .map { project, reward in reward.isNoReward || project.personalization.backing?.status != .collected }

    self.showSuccessBannerWithMessage = self.pledgeViewControllerDidUpdatePledgeWithMessageSignal
  }

  private let (projectAndRewardSignal, projectAndRewardObserver) = Signal<(Project, Reward), Never>.pipe()
  public func configureWith(_ project: Project, reward: Reward) {
    self.projectAndRewardObserver.send(value: (project, reward))
  }

  private let (menuButtonTappedSignal, menuButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func menuButtonTapped() {
    self.menuButtonTappedObserver.send(value: ())
  }

  private let (menuOptionSelectedSignal, menuOptionSelectedObserver) = Signal<ManagePledgeAlertAction, Never>
    .pipe()
  public func menuOptionSelected(with action: ManagePledgeAlertAction) {
    self.menuOptionSelectedObserver.send(value: action)
  }

  private let (
    pledgeViewControllerDidUpdatePledgeWithMessageSignal,
    pledgeViewControllerDidUpdatePledgeWithMessageObserver
  ) = Signal<String, Never>.pipe()
  public func pledgeViewControllerDidUpdatePledgeWithMessage(_ message: String) {
    self.pledgeViewControllerDidUpdatePledgeWithMessageObserver.send(value: message)
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let configurePaymentMethodView: Signal<GraphUserCreditCard.CreditCard, Never>
  public let configurePledgeSummaryView: Signal<Project, Never>
  public let configureRewardReceivedWithProject: Signal<Project, Never>
  public let configureRewardSummaryView: Signal<(Project, Either<Reward, Backing>), Never>
  public let goToCancelPledge: Signal<(Project, Backing), Never>
  public let goToChangePaymentMethod: Signal<Void, Never>
  public let goToContactCreator: Signal<Void, Never>
  public let goToRewards: Signal<Project, Never>
  public let goToUpdatePledge: Signal<(Project, Reward), Never>
  public let rewardReceivedViewControllerViewIsHidden: Signal<Bool, Never>
  public let showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never>
  public let showSuccessBannerWithMessage: Signal<String, Never>
  public let title: Signal<String, Never>

  public var inputs: ManagePledgeViewModelInputs { return self }
  public var outputs: ManagePledgeViewModelOutputs { return self }
}

// MARK: - Functions

private func navigationBarTitle(with project: Project) -> String {
  return project.state == .live ? Strings.Manage_your_pledge() : Strings.Your_pledge()
}
