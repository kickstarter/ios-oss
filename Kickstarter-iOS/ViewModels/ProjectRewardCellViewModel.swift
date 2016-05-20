import Library
import Models
import ReactiveCocoa
import Result

internal protocol ProjectRewardCellViewModelInputs {
  func project(project: Project, reward: Reward)
}

internal protocol ProjectRewardCellViewModelOutputs {
  var title: Signal<String, NoError> { get }
  var backers: Signal<String, NoError> { get }
  var backersHidden: Signal<Bool, NoError> { get }
  var description: Signal<String, NoError> { get }
  var limit: Signal<String, NoError> { get }
  var limitHidden: Signal<Bool, NoError> { get }
  var allGoneHidden: Signal<Bool, NoError> { get }
  var rewardDisabled: Signal<Bool, NoError> { get }
  var shippingHidden: Signal<Bool, NoError> { get }
  var estimatedDelivery: Signal<String, NoError> { get }
  var shippingRestrictionsHidden: Signal<Bool, NoError> { get }
  var shippingSummary: Signal<String, NoError> { get }
  var backerLabelHidden: Signal<Bool, NoError> { get }
}

internal protocol ProjectRewardCellViewModelType {
  var inputs: ProjectRewardCellViewModelInputs { get }
  var outputs: ProjectRewardCellViewModelOutputs { get }
}

internal final class ProjectRewardCellViewModel: ProjectRewardCellViewModelType,
ProjectRewardCellViewModelInputs, ProjectRewardCellViewModelOutputs {

  private let projectProperty = MutableProperty<Project?>(nil)
  private let rewardProperty = MutableProperty<Reward?>(nil)
  internal func project(project: Project, reward: Reward) {
    self.projectProperty.value = project
    self.rewardProperty.value = reward
  }

  internal let title: Signal<String, NoError>
  internal let backers: Signal<String, NoError>
  internal let backersHidden: Signal<Bool, NoError>
  internal let description: Signal<String, NoError>
  internal let limit: Signal<String, NoError>
  internal let limitHidden: Signal<Bool, NoError>
  internal let allGoneHidden: Signal<Bool, NoError>
  internal let rewardDisabled: Signal<Bool, NoError>
  internal let shippingHidden: Signal<Bool, NoError>
  internal let estimatedDelivery: Signal<String, NoError>
  internal let shippingRestrictionsHidden: Signal<Bool, NoError>
  internal let shippingSummary: Signal<String, NoError>
  internal let backerLabelHidden: Signal<Bool, NoError>

  internal var inputs: ProjectRewardCellViewModelInputs { return self }
  internal var outputs: ProjectRewardCellViewModelOutputs { return self }

  // swiftlint:disable function_body_length
  internal init() {
    let project = self.projectProperty.signal.ignoreNil()
    let reward = self.rewardProperty.signal.ignoreNil()
    let backing = project.map { $0.backing }

    self.title = combineLatest(project, reward)
      .map { project, reward in (project.country, reward.minimum) }
      .skipRepeats(==)
      .map { country, minimum in
        localizedString(
          key: "rewards.title.pledge_reward_currency_or_more",
          defaultValue: "Pledge %{reward_currency} or more",
          substitutions: ["reward_currency": Format.currency(minimum, country: country)]
        )
    }

    self.backers = reward.map { $0.backersCount ?? 0 }
      .skipRepeats()
      .map {
        localizedString(
          key: "rewards.info.backer_count_backers",
          defaultValue: "%{backer_count} backers",
          count: $0,
          substitutions: ["backer_count": Format.wholeNumber($0)]
        )
    }

    self.backersHidden = reward.map { $0.backersCount == nil }
      .skipRepeats()

    self.description = reward.map { $0.description ?? "" }
      .skipRepeats(==)

    self.limit = reward.map {
      localizedString(
        key: "rewards.info.limited_rewards_remaining_left_of_reward_limit",
        defaultValue: "Limited (%{rewards_remaining} left of %{reward_limit})",
        substitutions: [
          "rewards_remaining": Format.wholeNumber($0.remaining ?? 0),
          "reward_limit": Format.wholeNumber($0.limit ?? 0)
        ]
      )
    }.skipRepeats()

    self.limitHidden = reward.map { $0.limit == nil || $0.remaining == 0 }
      .skipRepeats()

    self.allGoneHidden = reward.map { $0.limit == nil || $0.remaining != 0 }
      .skipRepeats()

    self.rewardDisabled = self.allGoneHidden.map { !$0 }
      .skipRepeats()

    self.shippingHidden = reward.map { !$0.shipping.enabled }
      .skipRepeats()

    self.estimatedDelivery = reward.map { $0.estimatedDeliveryOn ?? 0 }
      .skipRepeats()
      .map { Format.date(secondsInUTC: $0, dateStyle: .MediumStyle, timeStyle: .NoStyle) }

    self.shippingRestrictionsHidden = reward.map { !$0.shipping.enabled }
      .skipRepeats()

    self.shippingSummary = reward.map { $0.shipping.summary ?? "" }
      .skipRepeats()

    self.backerLabelHidden = combineLatest(reward, backing)
      .map { reward, backing in reward.id != backing?.rewardId }
      .skipRepeats()
  }
  // swiftlint:enable function_body_length
}
