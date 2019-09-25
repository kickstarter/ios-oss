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
  func viewDidLoad()
}

public protocol ManageViewPledgeViewModelOutputs {
  var configurePaymentMethodView: Signal<Project, Never> { get }
  var configurePledgeSummaryView: Signal<Project, Never> { get }
  var configureRewardSummaryView: Signal<(Project, Either<Reward, Backing>), Never> { get }
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
      .map { (project, reward) in (project, .left(reward)) }

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
  }

  private let (projectAndRewardSignal, projectAndRewardObserver) = Signal<(Project, Reward), Never>.pipe()
  public func configureWith(_ project: Project, reward: Reward) {
    self.projectAndRewardObserver.send(value: (project, reward))
  }

  private let (menuButtonTappedSignal, menuButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func menuButtonTapped() {
    self.menuButtonTappedObserver.send(value: ())
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let configurePaymentMethodView: Signal<Project, Never>
  public let configurePledgeSummaryView: Signal<Project, Never>
  public let configureRewardSummaryView: Signal<(Project, Either<Reward, Backing>), Never>
  public let showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never>
  public let title: Signal<String, Never>

  public var inputs: ManageViewPledgeViewModelInputs { return self }
  public var outputs: ManageViewPledgeViewModelOutputs { return self }
}

// MARK: - Functions

private func navigationBarTitle(with project: Project) -> String {
  return project.state == .live ? Strings.Manage_your_pledge() : Strings.Your_pledge()
}
