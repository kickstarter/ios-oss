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

public protocol ManageViewPledgeViewModelInputs {
  func configureWith(_ project: Project, reward: Reward)
  func menuButtonTapped()
  func menuOptionSelected(with action: ManagePledgeAlertAction)
  func viewDidLoad()
}

public protocol ManageViewPledgeViewModelOutputs {
  var configurePaymentMethodView: Signal<Project, Never> { get }
  var configurePledgeSummaryView: Signal<Project, Never> { get }
  var configureRewardSummaryView: Signal<Reward, Never> { get }
  var goToCancelPledge: Signal<Void, Never> { get }
  var goToChangePaymentMethod: Signal<Void, Never> { get }
  var goToContactCreator: Signal<Void, Never> { get }
  var goToRewards: Signal<Project, Never> { get }
  var goToUpdatePledge: Signal<Project, Never> { get }

  var showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never> { get }
  var title: Signal<String, Never> { get }
}

public protocol ManageViewPledgeViewModelType {
  var inputs: ManageViewPledgeViewModelInputs { get }
  var outputs: ManageViewPledgeViewModelOutputs { get }
}

public final class ManageViewPledgeViewModel:
  ManageViewPledgeViewModelType, ManageViewPledgeViewModelInputs, ManageViewPledgeViewModelOutputs {
  public init() {
    let projectAndReward = self.projectAndRewardSignal
      .takeWhen(self.viewDidLoadSignal.ignoreValues())

    self.title = projectAndReward
      .map(first)
      .map(navigationBarTitle(with:))

    self.configurePaymentMethodView = projectAndReward
      .map(first)

    self.configurePledgeSummaryView = projectAndReward
      .map(first)

    self.configureRewardSummaryView = projectAndReward
      .map(second)

    let project = projectAndReward.map(first)

    self.showActionSheetMenuWithOptions = project
      .takeWhen(self.menuButtonTappedSignal)
      .map { project -> [ManagePledgeAlertAction] in
        if project.state == .live {
          return ManagePledgeAlertAction.allCases
        } else {
          return [.contactCreator]
        }
      }

    self.goToUpdatePledge = project
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .updatePledge })

    self.goToRewards = project
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .chooseAnotherReward })

    self.goToCancelPledge = self.menuOptionSelectedSignal
      .filter { $0 == .cancelPledge }
      .ignoreValues()

    self.goToContactCreator = self.menuOptionSelectedSignal
      .filter { $0 == .contactCreator }
      .ignoreValues()

    self.goToChangePaymentMethod = self.menuOptionSelectedSignal
      .filter { $0 == .changePaymentMethod }
      .ignoreValues()
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

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let configurePaymentMethodView: Signal<Project, Never>
  public let configurePledgeSummaryView: Signal<Project, Never>
  public let configureRewardSummaryView: Signal<Reward, Never>
  public let goToCancelPledge: Signal<Void, Never>
  public let goToChangePaymentMethod: Signal<Void, Never>
  public let goToContactCreator: Signal<Void, Never>
  public let goToRewards: Signal<Project, Never>
  public let goToUpdatePledge: Signal<Project, Never>
  public let showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never>
  public let title: Signal<String, Never>

  public var inputs: ManageViewPledgeViewModelInputs { return self }
  public var outputs: ManageViewPledgeViewModelOutputs { return self }
}

// MARK: - Functions

private func navigationBarTitle(with project: Project) -> String {
  return project.state == .live ? Strings.Manage_your_pledge() : Strings.View_your_pledge()
}
