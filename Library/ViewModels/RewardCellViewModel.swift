import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol RewardCellViewModelInputs {
  func boundStyles()
  func configureWith(project project: Project, reward: Reward)
}

public protocol RewardCellViewModelOutputs {
  var allGoneHidden: Signal<Bool, NoError> { get }
  var backersCountLabelText: Signal<String, NoError> { get }
  var cardViewBackgroundColor: Signal<UIColor, NoError> { get }
  var cardViewDropShadowHidden: Signal<Bool, NoError> { get }
  var contentViewBackgroundColor: Signal<UIColor, NoError> { get }
  var conversionLabelHidden: Signal<Bool, NoError> { get }
  var conversionLabelText: Signal<String, NoError> { get }
  var descriptionLabelHidden: Signal<Bool, NoError> { get }
  var descriptionLabelText: Signal<String, NoError> { get }
  var footerStackViewAlignment: Signal<UIStackViewAlignment, NoError> { get }
  var footerStackViewHidden: Signal<Bool, NoError> { get }
  var footerStackViewAxis: Signal<UILayoutConstraintAxis, NoError> { get }
  var items: Signal<[String], NoError> { get }
  var itemsContainerHidden: Signal<Bool, NoError> { get }
  var manageButtonHidden: Signal<Bool, NoError> { get }
  var minimumAndConversionLabelsColor: Signal<UIColor, NoError> { get }
  var minimumLabelText: Signal<String, NoError> { get }
  var pledgeButtonHidden: Signal<Bool, NoError> { get }
  var pledgeButtonTitleText: Signal<String, NoError> { get }
  var remainingStackViewHidden: Signal<Bool, NoError> { get }
  var remainingLabelText: Signal<String, NoError> { get }
  var titleLabelHidden: Signal<Bool, NoError> { get }
  var titleLabelText: Signal<String, NoError> { get }
  var titleLabelTextColor: Signal<UIColor, NoError> { get }
  var updateTopMarginsForIsBacking: Signal<Bool, NoError> { get }
  var viewPledgeButtonHidden: Signal<Bool, NoError> { get }
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
    let project = projectAndReward.map(first)
    let reward = projectAndReward.map(second)

    self.backersCountLabelText = reward
      .map { Strings.general_backer_count_backers(backer_count: $0.backersCount ?? 0) }

    self.conversionLabelHidden = project.map {
      !needsConversion(projectCountry: $0.country, userCountry: AppEnvironment.current.config?.countryCode)
      }

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

    self.footerStackViewAlignment = projectAndReward
      .map { _, _ in AppEnvironment.current.language == .en ? .Center : .Leading }

    self.minimumLabelText = projectAndReward
      .map { project, reward in
        Format.currency(reward.minimum, country: project.country)
    }

    self.descriptionLabelText = reward
      .map { $0.description }

    self.remainingStackViewHidden = reward
      .map { $0.limit == nil }

    self.remainingLabelText = reward
      .map { $0.remaining ?? 0 }
      .map { Strings.left_left(left: Format.wholeNumber($0)) }

    self.minimumAndConversionLabelsColor = reward
      .map { $0.remaining == 0 ? .ksr_text_navy_500 : .ksr_text_green_700 }

    self.titleLabelHidden = reward
      .map { $0.title == nil }

    self.titleLabelText = reward
      .map { $0.title ?? "" }

    self.titleLabelTextColor = reward
      .map { $0.remaining == 0 ? .ksr_text_navy_500 : .ksr_text_navy_700 }

    let youreABacker = projectAndReward
      .map { project, reward in
        project.personalization.backing?.rewardId == reward.id
          || project.personalization.backing?.reward?.id == reward.id
      }

    self.youreABackerViewHidden = youreABacker
      .map(negate)

    self.itemsContainerHidden = reward
      .map { $0.rewardsItems.isEmpty || $0.remaining == 0 }

    self.items = reward
      .map { reward in
        reward.rewardsItems.map { rewardsItem in
          rewardsItem.quantity > 1
            ? "(\(Format.wholeNumber(rewardsItem.quantity))) \(rewardsItem.item.name)"
            : rewardsItem.item.name
      }
    }

    self.allGoneHidden = projectAndReward
      .map { project, reward in
        reward.remaining != 0 || project.personalization.backing?.rewardId == reward.id
      }

    self.contentViewBackgroundColor = project
      .map { backgroundColor(forCategoryId: $0.category.rootId) }

    let allGoneAndNotABacker = zip(reward, youreABacker)
      .map { reward, youreABacker in reward.remaining == 0 && !youreABacker }

    self.descriptionLabelHidden = allGoneAndNotABacker
    self.footerStackViewHidden = allGoneAndNotABacker

    self.updateTopMarginsForIsBacking = combineLatest(youreABacker, self.boundStylesProperty.signal)
      .map(first)

    self.manageButtonHidden = zip(project, youreABacker)
      .map { project, youreABacker in
        project.state != .live || !youreABacker
    }

    self.viewPledgeButtonHidden = zip(project, youreABacker)
      .map { project, youreABacker in
        project.state == .live || !youreABacker
    }

    self.pledgeButtonHidden = zip(project, reward, youreABacker)
      .map { project, reward, youreABacker in
        project.state != .live || reward.remaining == 0 || youreABacker
    }

    self.pledgeButtonTitleText = project.map {
      $0.personalization.isBacking == true ? Strings.Change_to_this_reward() : Strings.Select_this_reward()
    }

    let tappable = zip(project, reward, youreABacker)
      .map { project, reward, youreABacker in
        (project.state == .live && reward.remaining != 0) || youreABacker
    }

    self.cardViewDropShadowHidden = combineLatest(
      tappable.map(negate),
      self.boundStylesProperty.signal
      )
      .map(first)

    self.cardViewBackgroundColor = combineLatest(allGoneAndNotABacker, self.boundStylesProperty.signal)
      .map(first)
      .map { $0 ? .ksr_grey_100 : .whiteColor() }
  }
  // swiftlint:enable function_body_length

  private let boundStylesProperty = MutableProperty()
  public func boundStyles() {
    self.boundStylesProperty.value = ()
  }

  private let projectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project project: Project, reward: Reward) {
    self.projectAndRewardProperty.value = (project, reward)
  }

  public let allGoneHidden: Signal<Bool, NoError>
  public let backersCountLabelText: Signal<String, NoError>
  public let cardViewBackgroundColor: Signal<UIColor, NoError>
  public let cardViewDropShadowHidden: Signal<Bool, NoError>
  public let contentViewBackgroundColor: Signal<UIColor, NoError>
  public let conversionLabelHidden: Signal<Bool, NoError>
  public let conversionLabelText: Signal<String, NoError>
  public let descriptionLabelHidden: Signal<Bool, NoError>
  public let descriptionLabelText: Signal<String, NoError>
  public let footerStackViewAlignment: Signal<UIStackViewAlignment, NoError>
  public let footerStackViewHidden: Signal<Bool, NoError>
  public let footerStackViewAxis: Signal<UILayoutConstraintAxis, NoError>
  public let items: Signal<[String], NoError>
  public let itemsContainerHidden: Signal<Bool, NoError>
  public let manageButtonHidden: Signal<Bool, NoError>
  public let minimumAndConversionLabelsColor: Signal<UIColor, NoError>
  public let minimumLabelText: Signal<String, NoError>
  public let pledgeButtonHidden: Signal<Bool, NoError>
  public let pledgeButtonTitleText: Signal<String, NoError>
  public let remainingStackViewHidden: Signal<Bool, NoError>
  public let remainingLabelText: Signal<String, NoError>
  public let titleLabelHidden: Signal<Bool, NoError>
  public let titleLabelText: Signal<String, NoError>
  public let titleLabelTextColor: Signal<UIColor, NoError>
  public let updateTopMarginsForIsBacking: Signal<Bool, NoError>
  public let viewPledgeButtonHidden: Signal<Bool, NoError>
  public let youreABackerViewHidden: Signal<Bool, NoError>

  public var inputs: RewardCellViewModelInputs { return self }
  public var outputs: RewardCellViewModelOutputs { return self }
}

private func needsConversion(projectCountry projectCountry: Project.Country, userCountry: String?) -> Bool {
  return userCountry == "US" && projectCountry != .US
}
