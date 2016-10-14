import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol RewardCellViewModelInputs {
  func boundStyles()
  func configureWith(project project: Project, rewardOrBacking: Either<Reward, Backing>)
  func tapped()
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
  var notifyDelegateRewardCellWantsExpansion: Signal<(), NoError> { get }
  var pledgeButtonHidden: Signal<Bool, NoError> { get }
  var pledgeButtonTitleText: Signal<String, NoError> { get }
  var remainingStackViewHidden: Signal<Bool, NoError> { get }
  var remainingLabelText: Signal<String, NoError> { get }
  var titleLabelHidden: Signal<Bool, NoError> { get }
  var titleLabelText: Signal<String, NoError> { get }
  var titleLabelTextColor: Signal<UIColor, NoError> { get }
  var updateTopMarginsForIsBacking: Signal<Bool, NoError> { get }
  var viewPledgeButtonHidden: Signal<Bool, NoError> { get }
  var youreABackerLabelText: Signal<String, NoError> { get }
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
    let projectAndRewardOrBacking = self.projectAndRewardOrBackingProperty.signal.ignoreNil()
    let project = projectAndRewardOrBacking.map(first)
    let rewardOrBacking = projectAndRewardOrBacking.map(second)
    let reward = projectAndRewardOrBacking
      .map { project, rewardOrBacking -> Reward in
        rewardOrBacking.left
          ?? rewardOrBacking.right?.reward
          ?? backingReward(fromProject: project)
          ?? Reward.noReward
    }
    let projectAndReward = zip(project, reward)

    self.backersCountLabelText = reward
      .map { Strings.general_backer_count_backers(backer_count: $0.backersCount ?? 0) }

    self.conversionLabelHidden = project.map {
      !needsConversion(projectCountry: $0.country, userCountry: AppEnvironment.current.config?.countryCode)
    }

    self.conversionLabelText = projectAndRewardOrBacking
      .filter { p, _ in
        needsConversion(projectCountry: p.country, userCountry: AppEnvironment.current.config?.countryCode)
      }
      .map { project, rewardOrBacking in
        switch rewardOrBacking {
        case let .left(reward):
          let min = minPledgeAmount(forProject: project, reward: reward)
          return Format.currency(max(1, Int(Float(min) * project.stats.staticUsdRate)), country: .US)
        case let .right(backing):
          return Format.currency(Int(ceil(Float(backing.amount) * project.stats.staticUsdRate)), country: .US)
        }
      }
      .map(Strings.rewards_title_about_amount_usd(reward_amount:))

    self.footerStackViewAxis = projectAndReward
      .map { _, _ in AppEnvironment.current.language == .en ? .Horizontal : .Vertical }

    self.footerStackViewAlignment = projectAndReward
      .map { _, _ in AppEnvironment.current.language == .en ? .Center : .Leading }

    self.minimumLabelText = projectAndRewardOrBacking
      .map { project, rewardOrBacking in
        switch rewardOrBacking {
        case let .left(reward):
          let min = minPledgeAmount(forProject: project, reward: reward)
          return Format.currency(min, country: project.country)
        case let .right(backing):
          return Format.currency(backing.amount, country: project.country)
        }
    }

    self.descriptionLabelText = reward
      .map { $0 == Reward.noReward ? "" : $0.description }

    self.remainingStackViewHidden = projectAndReward
      .map { project, reward in
        reward.limit == nil || project.state != .live
    }

    self.remainingLabelText = reward
      .map { $0.remaining ?? 0 }
      .map { Strings.left_left(left: Format.wholeNumber($0)) }

    self.minimumAndConversionLabelsColor = projectAndReward
      .map(minimumRewardAmountTextColor(project:reward:))

    self.titleLabelHidden = reward
      .map { $0.title == nil && $0 != Reward.noReward }

    self.titleLabelText = projectAndReward
      .map(rewardTitle(project:reward:))

    self.titleLabelTextColor = projectAndReward
      .map { project, reward in
        reward.remaining != 0 || userIsBacking(reward: reward, inProject: project) || project.state != .live
          ? .ksr_text_navy_700
          : .ksr_text_navy_500
    }

    let youreABacker = projectAndReward
      .map { project, reward in
        userIsBacking(reward: reward, inProject: project)
      }

    self.youreABackerViewHidden = youreABacker
      .map(negate)

    self.youreABackerLabelText = project
      .map { $0.personalization.backing?.reward == nil }
      .skipRepeats()
      .map { noRewardBacking in
        noRewardBacking
          ? Strings.Your_pledge()
          : Strings.Your_reward()
    }

    let rewardItemsIsEmpty = reward
      .map { $0.rewardsItems.isEmpty }

    self.itemsContainerHidden = Signal.merge(
      reward.map { $0.remaining == 0 || $0.rewardsItems.isEmpty },
      rewardItemsIsEmpty.takeWhen(self.tappedProperty.signal)
      )
      .skipRepeats()

    self.items = reward
      .map { reward in
        reward.rewardsItems.map { rewardsItem in
          rewardsItem.quantity > 1
            ? "(\(Format.wholeNumber(rewardsItem.quantity))) \(rewardsItem.item.name)"
            : rewardsItem.item.name
      }
    }

    let rewardIsCollapsed = projectAndReward
      .map { project, reward in
        reward.remaining == 0
          && !userIsBacking(reward: reward, inProject: project)
          && project.state == .live
    }

    self.allGoneHidden = projectAndReward
      .map { project, reward in
        reward.remaining != 0
          || userIsBacking(reward: reward, inProject: project)
    }

    self.contentViewBackgroundColor = project
      .map { backgroundColor(forCategoryId: $0.category.rootId) }

    let allGoneAndNotABacker = zip(reward, youreABacker)
      .map { reward, youreABacker in reward.remaining == 0 && !youreABacker }

    self.descriptionLabelHidden = Signal.merge(
      rewardIsCollapsed,
      self.tappedProperty.signal.mapConst(false)
    )

    self.footerStackViewHidden = zip(rewardIsCollapsed, reward)
      .map { rewardIsCollapsed, reward in rewardIsCollapsed || reward == .noReward }

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
      $0.personalization.isBacking == true
        ? Strings.Select_this_reward_instead()
        : Strings.Select_this_reward()
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

    self.notifyDelegateRewardCellWantsExpansion = allGoneAndNotABacker
      .takeWhen(self.tappedProperty.signal)
      .filter(isTrue)
      .ignoreValues()
  }
  // swiftlint:enable function_body_length

  private let boundStylesProperty = MutableProperty()
  public func boundStyles() {
    self.boundStylesProperty.value = ()
  }

  private let projectAndRewardOrBackingProperty = MutableProperty<(Project, Either<Reward, Backing>)?>(nil)
  public func configureWith(project project: Project, rewardOrBacking: Either<Reward, Backing>) {
    self.projectAndRewardOrBackingProperty.value = (project, rewardOrBacking)
  }

  private let tappedProperty = MutableProperty()
  public func tapped() {
    self.tappedProperty.value = ()
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
  public let notifyDelegateRewardCellWantsExpansion: Signal<(), NoError>
  public let pledgeButtonHidden: Signal<Bool, NoError>
  public let pledgeButtonTitleText: Signal<String, NoError>
  public let remainingStackViewHidden: Signal<Bool, NoError>
  public let remainingLabelText: Signal<String, NoError>
  public let titleLabelHidden: Signal<Bool, NoError>
  public let titleLabelText: Signal<String, NoError>
  public let titleLabelTextColor: Signal<UIColor, NoError>
  public let updateTopMarginsForIsBacking: Signal<Bool, NoError>
  public let viewPledgeButtonHidden: Signal<Bool, NoError>
  public let youreABackerLabelText: Signal<String, NoError>
  public let youreABackerViewHidden: Signal<Bool, NoError>

  public var inputs: RewardCellViewModelInputs { return self }
  public var outputs: RewardCellViewModelOutputs { return self }
}

private func minimumRewardAmountTextColor(project project: Project, reward: Reward) -> UIColor {
   if (project.state == .live && reward.remaining == 0 &&
    userIsBacking(reward: reward, inProject: project)) {
      return .ksr_text_green_700
  } else if (project.state != .live && reward.remaining == 0 &&
    userIsBacking(reward: reward, inProject: project)) {
      return .ksr_text_navy_700
  } else if (project.state == .live && reward.remaining == 0) ||
    (project.state != .live && reward.remaining == 0) {
      return .ksr_text_navy_500
  } else if project.state == .live {
      return .ksr_text_green_700
  } else if project.state != .live {
      return .ksr_text_navy_700
  } else {
      return .ksr_text_navy_700
  }
}

private func needsConversion(projectCountry projectCountry: Project.Country, userCountry: String?) -> Bool {
  return userCountry == "US" && projectCountry != .US
}

private func userIsBacking(reward reward: Reward, inProject project: Project) -> Bool {
  return project.personalization.backing?.rewardId == reward.id
    || project.personalization.backing?.reward?.id == reward.id
    || (project.personalization.backing?.reward == nil && reward == Reward.noReward)
}

private func backingReward(fromProject project: Project) -> Reward? {

  guard let backing = project.personalization.backing else {
    return nil
  }

  return project.rewards
    .filter { $0.id == backing.rewardId || $0.id == backing.reward?.id }
    .first
    .coalesceWith(.noReward)
}

private func minPledgeAmount(forProject project: Project, reward: Reward?) -> Int {

  // The country on the project cannot be trusted to have the min/max values, so first try looking
  // up the country in our launched countries array that we get back from the server config.
  let country = AppEnvironment.current.launchedCountries.countries
    .filter { $0 == project.country }
    .first
    .coalesceWith(project.country)

  switch reward {
  case .None, .Some(Reward.noReward):
    return country.minPledge ?? 1
  case let .Some(reward):
    return reward.minimum
  }
}

private func rewardTitle(project project: Project, reward: Reward) -> String {

  guard project.personalization.isBacking == true else {
    return reward == Reward.noReward
      ? Strings.Id_just_like_to_support_the_project()
      : (reward.title ?? "")
  }

  return reward.title ?? Strings.Thank_you_for_supporting_this_project()
}
