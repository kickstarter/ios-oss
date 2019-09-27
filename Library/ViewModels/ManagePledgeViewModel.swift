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
  func viewDidLoad()
}

public protocol ManagePledgeViewModelOutputs {
  var configurePaymentMethodView: Signal<GraphUserCreditCard.CreditCard, Never> { get }
  var configurePledgeSummaryView: Signal<Project, Never> { get }
  var configureRewardSummaryView: Signal<Reward, Never> { get }
  var showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never> { get }
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

    self.title = projectAndReward
      .map(first)
      .map(navigationBarTitle(with:))

    self.configurePaymentMethodView = projectAndReward
      .map(first)
      .map { $0.personalization.backing?.paymentSource }
      .skipNil()

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

  public let configurePaymentMethodView: Signal<GraphUserCreditCard.CreditCard, Never>
  public let configurePledgeSummaryView: Signal<Project, Never>
  public let configureRewardSummaryView: Signal<Reward, Never>
  public let showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never>
  public let title: Signal<String, Never>

  public var inputs: ManagePledgeViewModelInputs { return self }
  public var outputs: ManagePledgeViewModelOutputs { return self }
}

// MARK: - Functions

private func navigationBarTitle(with project: Project) -> String {
  return project.state == .live ? Strings.Manage_your_pledge() : Strings.Your_pledge()
}
