import KsApi
import ReactiveCocoa
import Result

public protocol RewardCellViewModelInputs {
  func configureWith(project project: Project, reward: Reward)
}

public protocol RewardCellViewModelOutputs {
  var allGoneHidden: Signal<Bool, NoError> { get }
  var backersCountLabelText: Signal<String, NoError> { get }
  var conversionLabelHidden: Signal<Bool, NoError> { get }
  var conversionLabelText: Signal<String, NoError> { get }
  var footerStackViewAlignment: Signal<UIStackViewAlignment, NoError> { get }
  var footerStackViewAxis: Signal<UILayoutConstraintAxis, NoError> { get }
  var items: Signal<[String], NoError> { get }
  var itemsContainerHidden: Signal<Bool, NoError> { get }
  var minimumAndConversionLabelsColor: Signal<UIColor, NoError> { get }
  var minimumLabelText: Signal<String, NoError> { get }
  var descriptionLabelText: Signal<String, NoError> { get }
  var remainingStackViewHidden: Signal<Bool, NoError> { get }
  var remainingLabelText: Signal<String, NoError> { get }
  var titleLabelHidden: Signal<Bool, NoError> { get }
  var titleLabelText: Signal<String, NoError> { get }
  var titleLabelTextColor: Signal<UIColor, NoError> { get }
  var youreABackerViewHidden: Signal<Bool, NoError> { get }
}

public protocol RewardCellViewModelType {
  var inputs: RewardCellViewModelInputs { get }
  var outputs: RewardCellViewModelOutputs { get }
}

public final class RewardCellViewModel: RewardCellViewModelType, RewardCellViewModelInputs,
RewardCellViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let projectAndReward = self.projectAndRewardProperty.signal.ignoreNil()

    self.backersCountLabelText = projectAndReward
      .map { _, reward in Strings.general_backer_count_backers(backer_count: reward.backersCount ?? 0) }

    self.conversionLabelHidden = projectAndReward.map { p, _ in
      !needsConversion(projectCountry: p.country, userCountry: AppEnvironment.current.config?.countryCode)
      }
      .skipRepeats()

    self.conversionLabelText = projectAndReward
      .filter { p, _ in
        needsConversion(projectCountry: p.country, userCountry: AppEnvironment.current.config?.countryCode)
      }
      .map { project, reward in
        Format.currency(Int(Float(reward.minimum) * project.stats.staticUsdRate), country: .US)
      }
      .map(Strings.rewards_title_about_amount_usd(reward_amount:))

    self.footerStackViewAxis = projectAndReward
      .map { _, _ in AppEnvironment.current.language == .en ? .Horizontal : .Vertical }
      .skipRepeats()

    self.footerStackViewAlignment = projectAndReward
      .map { _, _ in AppEnvironment.current.language == .en ? .Center : .Leading }
      .skipRepeats()

    self.minimumLabelText = projectAndReward.map { project, reward in
      return Format.currency(reward.minimum, country: project.country)
    }

    self.descriptionLabelText = projectAndReward
      .map { _, reward in reward.description }

    self.remainingStackViewHidden = projectAndReward
      .map { _, reward in reward.limit == nil }
      .skipRepeats()

    self.remainingLabelText = projectAndReward
      .map { _, reward in reward.remaining ?? 0 }
      .map {
        localizedString(
          key: "todo",
          defaultValue: "%{left} left",
          count: $0,
          substitutions: ["left": Format.wholeNumber($0)]
        )
    }

    self.minimumAndConversionLabelsColor = projectAndReward
      .map { _, reward in reward.remaining == 0 ? .ksr_text_navy_500 : .ksr_text_green_700 }
      .skipRepeats()

    self.titleLabelHidden = projectAndReward
      .map { _, reward in reward.title == nil }
      .skipRepeats()

    self.titleLabelText = projectAndReward
      .map { _, reward in reward.title ?? "" }

    self.titleLabelTextColor = projectAndReward
      .map { _, reward in reward.remaining == 0 ? .ksr_text_navy_500 : .ksr_text_navy_700 }
      .skipRepeats()

    self.youreABackerViewHidden = projectAndReward
      .map { project, reward in project.personalization.backing?.rewardId != reward.id }
      .skipRepeats()

    self.itemsContainerHidden = projectAndReward
      .map { _, reward in reward.rewardsItems.isEmpty }
      .skipRepeats()

    self.items = projectAndReward.map { _, reward in
      reward.rewardsItems.map { rewardsItem in
        rewardsItem.quantity > 1
          ? "(\(Format.wholeNumber(rewardsItem.quantity))) \(rewardsItem.item.name)"
          : rewardsItem.item.name
      }
    }

    self.allGoneHidden = projectAndReward
      .map { project, reward in
        reward.remaining != 0 ||
          project.personalization.backing?.rewardId == reward.id
      }
      .skipRepeats()
  }
  // swiftlint:enable function_body_length

  private let projectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project project: Project, reward: Reward) {
    self.projectAndRewardProperty.value = (project, reward)
  }

  public let allGoneHidden: Signal<Bool, NoError>
  public let backersCountLabelText: Signal<String, NoError>
  public let conversionLabelHidden: Signal<Bool, NoError>
  public let conversionLabelText: Signal<String, NoError>
  public let descriptionLabelText: Signal<String, NoError>
  public let footerStackViewAlignment: Signal<UIStackViewAlignment, NoError>
  public let footerStackViewAxis: Signal<UILayoutConstraintAxis, NoError>
  public let items: Signal<[String], NoError>
  public let itemsContainerHidden: Signal<Bool, NoError>
  public let minimumAndConversionLabelsColor: Signal<UIColor, NoError>
  public let minimumLabelText: Signal<String, NoError>
  public let remainingStackViewHidden: Signal<Bool, NoError>
  public let remainingLabelText: Signal<String, NoError>
  public let titleLabelHidden: Signal<Bool, NoError>
  public let titleLabelText: Signal<String, NoError>
  public let titleLabelTextColor: Signal<UIColor, NoError>
  public let youreABackerViewHidden: Signal<Bool, NoError>

  public var inputs: RewardCellViewModelInputs { return self }
  public var outputs: RewardCellViewModelOutputs { return self }
}

private func needsConversion(projectCountry projectCountry: Project.Country, userCountry: String?) -> Bool {
  return userCountry == "US" && projectCountry != .US
}
