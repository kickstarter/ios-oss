import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol ProjectActivityBackingCellViewModelInputs {
  /// Call when the backing button is pressed.
  func backingButtonPressed()

  /// Call to set the activity and project.
  func configureWith(activity: Activity, project: Project)

  /// Call when the send message button is pressed.
  func sendMessageButtonPressed()
}

public protocol ProjectActivityBackingCellViewModelOutputs {
  /// Emits a URL for the backer's avatar.
  var backerImageURL: Signal<URL?, NoError> { get }

  /// Emits the cell's accessibility label.
  var cellAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the cell's accessibility value.
  var cellAccessibilityValue: Signal<String, NoError> { get }

  /// Emits when the delegate should go to the backing screen.
  var notifyDelegateGoToBacking: Signal<(Project, User), NoError> { get }

  /// Emits when the delegate should go to the send message screen.
  var notifyDelegateGoToSendMessage: Signal<(Project, Backing), NoError> { get }

  /// Emits the new pledge amount.
  var pledgeAmount: Signal<String, NoError> { get }

  /// Emits whether the pledge amount label should be hidden.
  var pledgeAmountLabelIsHidden: Signal<Bool, NoError> { get }

  /// Emits whether the pledge amounts stack view should be hidden.
  var pledgeAmountsStackViewIsHidden: Signal<Bool, NoError> { get }

  /// Emits where the pledge details separator stack view should be hidden.
  var pledgeDetailsSeparatorStackViewIsHidden: Signal<Bool, NoError> { get }

  /// Emits the old pledge amount.
  var previousPledgeAmount: Signal<String, NoError> { get }

  /// Emits whether the previous pledge amount label should be hidden.
  var previousPledgeAmountLabelIsHidden: Signal<Bool, NoError> { get }

  /// Emits a description of the reward.
  var reward: Signal<String, NoError> { get }

  /// Emits whether the reward label should be hidden.
  var rewardLabelIsHidden: Signal<Bool, NoError> { get }

  /// Emits whether the send message button should be hidden.
  var sendMessageButtonAndBulletSeparatorHidden: Signal<Bool, NoError> { get }

  /// Emits the activity's title.
  var title: Signal<String, NoError> { get }
}

public protocol ProjectActivityBackingCellViewModelType {
  var inputs: ProjectActivityBackingCellViewModelInputs { get }
  var outputs: ProjectActivityBackingCellViewModelOutputs { get }
}

public final class ProjectActivityBackingCellViewModel: ProjectActivityBackingCellViewModelType,
ProjectActivityBackingCellViewModelInputs, ProjectActivityBackingCellViewModelOutputs {

    public init() {
    let activityAndProject = self.activityAndProjectProperty.signal.skipNil()
    let activity = activityAndProject.map(first)
    let title = activity.map(title(activity:))

    self.backerImageURL = activityAndProject
      .map { activity, _ in ( activity.user?.avatar.medium).flatMap(URL.init) }

    self.cellAccessibilityLabel = title.map { title in title.htmlStripped() ?? "" }

    self.cellAccessibilityValue = activityAndProject
      .flatMap { activity, project -> SignalProducer<String, NoError> in
        return .init(value: accessibilityValue(activity: activity, project: project))
    }

    self.notifyDelegateGoToBacking = activityAndProject
      .takeWhen(self.backingButtonPressedProperty.signal)
      .flatMap { activity, project -> SignalProducer<(Project, User), NoError> in
        guard let user = activity.user else { return .empty }
        return .init(value: (project, user))
    }

    self.notifyDelegateGoToSendMessage = activityAndProject
      .takeWhen(self.sendMessageButtonPressedProperty.signal)
      .flatMap { activity, project -> SignalProducer<(Project, Backing), NoError> in
        guard let backing = activity.memberData.backing else { return .empty }
        return .init(value: (project, backing))
    }

    self.pledgeAmount = activityAndProject
      .map(amount(activity:project:))

    let pledgeAmountLabelIsHidden = self.pledgeAmount
      .map { $0.isEmpty }

    self.pledgeAmountLabelIsHidden = pledgeAmountLabelIsHidden.skipRepeats()

    self.previousPledgeAmount = activityAndProject
      .map(oldAmount(activity:project:))

    let previousPledgeAmountLabelIsHidden = self.previousPledgeAmount
      .map { $0.isEmpty }

    self.previousPledgeAmountLabelIsHidden = previousPledgeAmountLabelIsHidden.skipRepeats()

    let pledgeAmountsStackViewIsHidden = Signal.zip(
      pledgeAmountLabelIsHidden,
      previousPledgeAmountLabelIsHidden
      )
      .map { $0 && $1 }
      .skipRepeats()

    self.pledgeAmountsStackViewIsHidden = pledgeAmountsStackViewIsHidden

    self.reward = activityAndProject.map(rewardSummary(activity:project:))

    let rewardLabelIsHidden = self.reward
      .map { $0.isEmpty }

    self.rewardLabelIsHidden = rewardLabelIsHidden

    self.sendMessageButtonAndBulletSeparatorHidden = activityAndProject
      .map { .some($1.creator) != AppEnvironment.current.currentUser }

    self.title = title

    self.pledgeDetailsSeparatorStackViewIsHidden = Signal.zip(
      pledgeAmountsStackViewIsHidden,
      rewardLabelIsHidden
      )
      .map { $0 || $1 }
      .skipRepeats()
  }

  fileprivate let backingButtonPressedProperty = MutableProperty()
  public func backingButtonPressed() {
    self.backingButtonPressedProperty.value = ()
  }

  fileprivate let activityAndProjectProperty = MutableProperty<(Activity, Project)?>(nil)
  public func configureWith(activity: Activity, project: Project) {
    self.activityAndProjectProperty.value = (activity, project)
  }

  fileprivate let sendMessageButtonPressedProperty = MutableProperty()
  public func sendMessageButtonPressed() {
    self.sendMessageButtonPressedProperty.value = ()
  }

  public let backerImageURL: Signal<URL?, NoError>
  public let cellAccessibilityLabel: Signal<String, NoError>
  public let cellAccessibilityValue: Signal<String, NoError>
  public let notifyDelegateGoToBacking: Signal<(Project, User), NoError>
  public let notifyDelegateGoToSendMessage: Signal<(Project, Backing), NoError>
  public let pledgeAmount: Signal<String, NoError>
  public let pledgeAmountLabelIsHidden: Signal<Bool, NoError>
  public let pledgeAmountsStackViewIsHidden: Signal<Bool, NoError>
  public let pledgeDetailsSeparatorStackViewIsHidden: Signal<Bool, NoError>
  public let previousPledgeAmount: Signal<String, NoError>
  public let previousPledgeAmountLabelIsHidden: Signal<Bool, NoError>
  public let reward: Signal<String, NoError>
  public let rewardLabelIsHidden: Signal<Bool, NoError>
  public var sendMessageButtonAndBulletSeparatorHidden: Signal<Bool, NoError>
  public let title: Signal<String, NoError>

  public var inputs: ProjectActivityBackingCellViewModelInputs { return self }
  public var outputs: ProjectActivityBackingCellViewModelOutputs { return self }
}

private func accessibilityValue(activity: Activity, project: Project) -> String {
  switch activity.category {
  case .backing, .backingCanceled:
    return Strings.Amount_reward(
      amount: amount(activity: activity, project: project),
      reward: rewardSummary(activity: activity, project: project).htmlStripped() ?? ""
    )
  case .backingAmount:
    return Strings.Amount_previous_amount(
      amount: amount(activity: activity, project: project),
      previous_amount: oldAmount(activity: activity, project: project))
  case .backingReward:
    return rewardSummary(activity: activity, project: project).htmlStripped() ?? ""
  case .backingDropped, .cancellation, .commentPost, .commentProject, .failure, .follow, .funding,
       .launch, .success, .suspension, .update, .watch, .unknown:
    assertionFailure("Unrecognized activity: \(activity).")
    return ""
  }
}

private func currentUserIsBacker(activity: Activity) -> Bool {
  guard let backing = activity.memberData.backing else { return false }
  return AppEnvironment.current.currentUser?.id == backing.backerId
}

private func rewardSummary(activity: Activity, project: Project) -> String {
  guard let reward = reward(activity: activity, project: project) else { return "" }
  return reward.isNoReward ?
    Strings.dashboard_activity_no_reward_selected() :
    Strings.dashboard_activity_reward_name(reward_name: reward.title ?? reward.description)
}

private func reward(activity: Activity, project: Project) -> Reward? {
  guard let rewardId = activity.memberData.rewardId ?? activity.memberData.newRewardId else { return nil }
  return project.rewards.filter { $0.id == rewardId }.first
}

private func title(activity: Activity) -> String {
  guard let userName = activity.user?.name else { return "" }

  switch activity.category {
  case .backing:
    return currentUserIsBacker(activity: activity) ?
      Strings.dashboard_activity_you_pledged() :
      Strings.dashboard_activity_user_name_pledged(user_name: userName)
  case .backingAmount:
    return currentUserIsBacker(activity: activity) ?
      Strings.dashboard_activity_you_adjusted_your_pledge() :
      Strings.dashboard_activity_user_name_adjusted_their_pledge(user_name: userName)
  case .backingCanceled:
    return currentUserIsBacker(activity: activity) ?
      Strings.dashboard_activity_you_canceled_your_pledge() :
      Strings.dashboard_activity_user_name_canceled_their_pledge(user_name: userName)
  case .backingReward:
    return currentUserIsBacker(activity: activity) ?
      Strings.dashboard_activity_you_changed_your_reward() :
      Strings.dashboard_activity_user_name_changed_their_reward(user_name: userName)
  default:
    assertionFailure("Unrecognized activity: \(activity).")
    return ""
  }
}

private func amount(activity: Activity, project: Project) -> String {
  guard let amount = activity.memberData.amount ?? activity.memberData.newAmount else { return "" }
  return Format.currency(amount, country: project.country)
}

private func oldAmount(activity: Activity, project: Project) -> String {
  guard let amount = activity.memberData.oldAmount else { return "" }
  return Format.currency(amount, country: project.country)
}
