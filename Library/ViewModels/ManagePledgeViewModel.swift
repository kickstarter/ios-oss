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
  func configureWith(_ project: Project)
  func cancelPledgeDidFinish(with message: String)
  func menuButtonTapped()
  func menuOptionSelected(with action: ManagePledgeAlertAction)
  func pledgeViewControllerDidUpdatePledgeWithMessage(_ message: String)
  func viewDidLoad()
}

public protocol ManagePledgeViewModelOutputs {
  var configurePaymentMethodView: Signal<Backing.PaymentSource, Never> { get }
  var configurePledgeSummaryView: Signal<Project, Never> { get }
  var configureRewardReceivedWithProject: Signal<Project, Never> { get }
  var configureRewardSummaryView: Signal<(Project, Either<Reward, Backing>), Never> { get }
  var goToCancelPledge: Signal<(Project, Backing), Never> { get }
  var goToChangePaymentMethod: Signal<(Project, Reward), Never> { get }
  var goToContactCreator: Signal<(MessageSubject, Koala.MessageDialogContext), Never> { get }
  var goToRewards: Signal<Project, Never> { get }
  var goToUpdatePledge: Signal<(Project, Reward), Never> { get }
  var notifyDelegateShouldDismissAndShowSuccessBannerWithMessage: Signal<String, Never> { get }
  var rewardReceivedViewControllerViewIsHidden: Signal<Bool, Never> { get }
  var showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never> { get }
  var showErrorBannerWithMessage: Signal<String, Never> { get }
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
    let initialProject = Signal.combineLatest(self.configureWithProjectSignal, self.viewDidLoadSignal)
      .map(first)

    let refreshProjectEvent = initialProject
      .takeWhen(self.pledgeViewControllerDidUpdatePledgeWithMessageSignal)
      .switchMap { project in
        AppEnvironment.current.apiService.fetchProject(param: Param.id(project.id))
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    let project = Signal.merge(initialProject, refreshProjectEvent.values())
    let backing = project
      .map { $0.personalization.backing }
      .skipNil()
    let projectAndReward = project
      .filterMap { project in
        guard let backing = project.personalization.backing else {
          return nil
        }

        return (project, backing)
      }
      .map { project, backing in (project, reward(from: backing, inProject: project)) }

    self.title = project.map(navigationBarTitle(with:))

    self.configurePaymentMethodView = backing
      .map { $0.paymentSource }
      .skipNil()

    self.configurePledgeSummaryView = project
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
      .filter { _, backing in backing.cancelable }

    self.goToContactCreator = project
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .contactCreator })
      .map { project in (MessageSubject.project(project), .backerModal) }

    self.goToChangePaymentMethod = projectAndReward
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .changePaymentMethod })

    self.notifyDelegateShouldDismissAndShowSuccessBannerWithMessage
      = self.cancelPledgeDidFinishWithMessageProperty.signal.skipNil()
    self.rewardReceivedViewControllerViewIsHidden = projectAndReward
      .map { project, reward in reward.isNoReward || project.personalization.backing?.status != .collected }

    self.showSuccessBannerWithMessage = self.pledgeViewControllerDidUpdatePledgeWithMessageSignal

    let cancelBackingDisallowed = backing
      .map { $0.cancelable }
      .filter(isFalse)

    self.showErrorBannerWithMessage = cancelBackingDisallowed
      .takeWhen(cancelPledgeSelected)
      // swiftlint:disable:next line_length
      .map { _ in Strings.We_dont_allow_cancelations_that_will_cause_a_project_to_fall_short_of_its_goal_within_the_last_24_hours() }

    let managePledgeMenuType: Signal<Koala.ManagePledgeMenuCTAType, Never> = Signal.merge(
      self.menuOptionSelectedSignal.filter { $0 == .updatePledge }.mapConst(.updatePledge),
      self.menuOptionSelectedSignal.filter { $0 == .changePaymentMethod }.mapConst(.changePaymentMethod),
      self.menuOptionSelectedSignal.filter { $0 == .chooseAnotherReward }.mapConst(.chooseAnotherReward),
      self.menuOptionSelectedSignal.filter { $0 == .contactCreator }.mapConst(.contactCreator),
      self.menuOptionSelectedSignal.filter { $0 == .cancelPledge }.mapConst(.cancelPledge)
    )

    // Tracking
    project
      .takePairWhen(managePledgeMenuType)
      .observeValues {
        AppEnvironment.current.koala.trackManagePledgeOptionClicked(project: $0, managePledgeMenuCTA: $1)
    }
  }

  private let (configureWithProjectSignal, configureWithProjectObserver) = Signal<Project, Never>.pipe()
  public func configureWith(_ project: Project) {
    self.configureWithProjectObserver.send(value: project)
  }

  private let cancelPledgeDidFinishWithMessageProperty = MutableProperty<String?>(nil)
  public func cancelPledgeDidFinish(with message: String) {
    self.cancelPledgeDidFinishWithMessageProperty.value = message
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

  public let configurePaymentMethodView: Signal<Backing.PaymentSource, Never>
  public let configurePledgeSummaryView: Signal<Project, Never>
  public let configureRewardReceivedWithProject: Signal<Project, Never>
  public let configureRewardSummaryView: Signal<(Project, Either<Reward, Backing>), Never>
  public let goToCancelPledge: Signal<(Project, Backing), Never>
  public let goToChangePaymentMethod: Signal<(Project, Reward), Never>
  public let goToContactCreator: Signal<(MessageSubject, Koala.MessageDialogContext), Never>
  public let goToRewards: Signal<Project, Never>
  public let goToUpdatePledge: Signal<(Project, Reward), Never>
  public let notifyDelegateShouldDismissAndShowSuccessBannerWithMessage: Signal<String, Never>
  public let rewardReceivedViewControllerViewIsHidden: Signal<Bool, Never>
  public let showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never>
  public let showSuccessBannerWithMessage: Signal<String, Never>
  public let showErrorBannerWithMessage: Signal<String, Never>
  public let title: Signal<String, Never>

  public var inputs: ManagePledgeViewModelInputs { return self }
  public var outputs: ManagePledgeViewModelOutputs { return self }
}

// MARK: - Functions

private func navigationBarTitle(with project: Project) -> String {
  return project.state == .live ? Strings.Manage_your_pledge() : Strings.Your_pledge()
}
