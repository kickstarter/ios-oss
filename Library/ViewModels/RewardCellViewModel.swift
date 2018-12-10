import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol RewardCellViewModelInputs {
  func boundStyles()
  func configureWith(project: Project, rewardOrBacking: Either<Reward, Backing>)
  func tapped()
}

public protocol RewardCellViewModelOutputs {
  var allGoneHidden: Signal<Bool, NoError> { get }
  var conversionLabelHidden: Signal<Bool, NoError> { get }
  var conversionLabelText: Signal<String, NoError> { get }
  var descriptionLabelHidden: Signal<Bool, NoError> { get }
  var descriptionLabelText: Signal<String, NoError> { get }
  var estimatedDeliveryDateLabelText: Signal<String, NoError> { get }
  var footerLabelText: Signal<String, NoError> { get }
  var footerStackViewHidden: Signal<Bool, NoError> { get }
  var items: Signal<[String], NoError> { get }
  var itemsContainerHidden: Signal<Bool, NoError> { get }
  var manageButtonHidden: Signal<Bool, NoError> { get }
  var minimumAndConversionLabelsColor: Signal<UIColor, NoError> { get }
  var minimumLabelText: Signal<String, NoError> { get }
  var notifyDelegateRewardCellWantsExpansion: Signal<(), NoError> { get }
  var pledgeButtonHidden: Signal<Bool, NoError> { get }
  var pledgeButtonTitleText: Signal<String, NoError> { get }
  var shippingLocationsStackViewHidden: Signal<Bool, NoError> { get }
  var shippingLocationsSummaryLabelText: Signal<String, NoError> { get }
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

  public init() {
    let projectAndRewardOrBacking: Signal<(Project, Either<Reward, Backing>), NoError> =
      self.projectAndRewardOrBackingProperty.signal.skipNil()

    let project: Signal<Project, NoError> = projectAndRewardOrBacking.map(first)

    let reward: Signal<Reward, NoError> = projectAndRewardOrBacking
      .map { project, rewardOrBacking -> Reward in
        rewardOrBacking.left
          ?? rewardOrBacking.right?.reward
          ?? backingReward(fromProject: project)
          ?? Reward.noReward
    }

    let projectAndReward = Signal.zip(project, reward)

    self.conversionLabelHidden = project.map(needsConversion(project:) >>> negate)
    self.conversionLabelText = projectAndRewardOrBacking
      .filter(first >>> needsConversion(project:))
      .map { project, rewardOrBacking in
        let (country, rate) = zip(
          project.stats.currentCountry,
          project.stats.currentCurrencyRate
        ) ?? (.us, project.stats.staticUsdRate)
        switch rewardOrBacking {
        case let .left(reward):
          let min = minPledgeAmount(forProject: project, reward: reward)
          return Format.currency(max(1, Int(Float(min) * rate)),
                                 country: country,
                                 omitCurrencyCode: project.stats.omitUSCurrencyCode)
        case let .right(backing):
          return Format.currency(Int(ceil(Float(backing.amount) * rate)),
                                 country: country,
                                 omitCurrencyCode: project.stats.omitUSCurrencyCode)
        }
      }
      .map(Strings.About_reward_amount(reward_amount:))

    self.minimumLabelText = projectAndRewardOrBacking
      .map { project, rewardOrBacking in
        switch rewardOrBacking {
        case let .left(reward):
          let min = minPledgeAmount(forProject: project, reward: reward)
          let currency = Format.currency(min,
                                         country: project.country,
                                         omitCurrencyCode: project.stats.omitUSCurrencyCode)
          return reward == Reward.noReward
            ? Strings.rewards_title_pledge_reward_currency_or_more(reward_currency: currency)
            : currency

        case let .right(backing):
          let backingAmount = formattedAmount(for: backing)
          return Format.formattedCurrency(backingAmount,
                                          country: project.country,
                                          omitCurrencyCode: project.stats.omitUSCurrencyCode)
        }
    }

    self.descriptionLabelText = reward
      .map { $0 == Reward.noReward ? "" : $0.description }

    self.minimumAndConversionLabelsColor = projectAndReward
      .map(minimumRewardAmountTextColor(project:reward:))

    self.titleLabelHidden = reward
      .map { $0.title == nil && $0 != Reward.noReward }

    self.titleLabelText = projectAndReward
      .map(rewardTitle(project:reward:))

    self.titleLabelTextColor = projectAndReward
      .map { project, reward in
        reward.remaining != 0 || userIsBacking(reward: reward, inProject: project) || project.state != .live
          ? .ksr_soft_black
          : .ksr_text_dark_grey_500
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

    self.estimatedDeliveryDateLabelText = reward
      .map { reward in
        reward.estimatedDeliveryOn.map {
          Format.date(secondsInUTC: $0, template: "MMMMyyyy", timeZone: UTCTimeZone)
      }
    }
    .skipNil()

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
       shouldCollapse(reward: reward, forProject: project)
    }

    self.allGoneHidden = projectAndReward
      .map { project, reward in
        reward.remaining != 0
          || userIsBacking(reward: reward, inProject: project)
    }

    let allGoneAndNotABacker = Signal.zip(reward, youreABacker)
      .map { reward, youreABacker in reward.remaining == 0 && !youreABacker }

    let isNoReward = reward
      .map { $0.isNoReward }

    self.footerStackViewHidden = Signal.merge(
      projectAndReward
      .map { project, reward in
        reward.estimatedDeliveryOn == nil || shouldCollapse(reward: reward, forProject: project)
        },
        isNoReward.takeWhen(self.tappedProperty.signal)
      )

    self.descriptionLabelHidden = Signal.merge(
      rewardIsCollapsed,
      self.tappedProperty.signal.mapConst(false)
    )

    self.updateTopMarginsForIsBacking = Signal.combineLatest(youreABacker, self.boundStylesProperty.signal)
      .map(first)

    self.manageButtonHidden = Signal.zip(project, youreABacker)
      .map { project, youreABacker in
        project.state != .live || !youreABacker
    }

    self.viewPledgeButtonHidden = Signal.zip(project, youreABacker)
      .map { project, youreABacker in
        project.state == .live || !youreABacker
    }

    self.pledgeButtonHidden = Signal.zip(project, reward, youreABacker)
      .map { project, reward, youreABacker in
        project.state != .live || reward.remaining == 0 || youreABacker
    }

    self.pledgeButtonTitleText = project.map {
      $0.personalization.isBacking == true
        ? Strings.Select_this_reward_instead()
        : Strings.Select_this_reward()
    }

    self.shippingLocationsStackViewHidden = reward.map {
      $0.shipping.summary == nil
    }

    self.shippingLocationsSummaryLabelText = reward.map {
      $0.shipping.summary ?? ""
    }

    self.notifyDelegateRewardCellWantsExpansion = allGoneAndNotABacker
      .takeWhen(self.tappedProperty.signal)
      .filter(isTrue)
      .ignoreValues()
      .take(first: 1)

    self.footerLabelText = projectAndReward
      .map(footerString(project:reward:))

    projectAndReward
      .takeWhen(self.notifyDelegateRewardCellWantsExpansion)
      .observeValues { project, reward in
        AppEnvironment.current.koala.trackExpandedUnavailableReward(
          reward,
          project: project,
          pledgeContext: pledgeContext(forProject: project, reward: reward)
        )
    }
  }
  // swiftlint:enable function_body_length

  private let boundStylesProperty = MutableProperty(())
  public func boundStyles() {
    self.boundStylesProperty.value = ()
  }

  private let projectAndRewardOrBackingProperty = MutableProperty<(Project, Either<Reward, Backing>)?>(nil)
  public func configureWith(project: Project, rewardOrBacking: Either<Reward, Backing>) {
    self.projectAndRewardOrBackingProperty.value = (project, rewardOrBacking)
  }

  private let tappedProperty = MutableProperty(())
  public func tapped() {
    self.tappedProperty.value = ()
  }

  public let allGoneHidden: Signal<Bool, NoError>
  public let conversionLabelHidden: Signal<Bool, NoError>
  public let conversionLabelText: Signal<String, NoError>
  public let descriptionLabelHidden: Signal<Bool, NoError>
  public let descriptionLabelText: Signal<String, NoError>
  public let estimatedDeliveryDateLabelText: Signal<String, NoError>
  public let footerLabelText: Signal<String, NoError>
  public let footerStackViewHidden: Signal<Bool, NoError>
  public let items: Signal<[String], NoError>
  public let itemsContainerHidden: Signal<Bool, NoError>
  public let manageButtonHidden: Signal<Bool, NoError>
  public let minimumAndConversionLabelsColor: Signal<UIColor, NoError>
  public let minimumLabelText: Signal<String, NoError>
  public let notifyDelegateRewardCellWantsExpansion: Signal<(), NoError>
  public let pledgeButtonHidden: Signal<Bool, NoError>
  public let pledgeButtonTitleText: Signal<String, NoError>
  public let shippingLocationsStackViewHidden: Signal<Bool, NoError>
  public let shippingLocationsSummaryLabelText: Signal<String, NoError>
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

private func minimumRewardAmountTextColor(project: Project, reward: Reward) -> UIColor {
  if project.state != .successful && project.state != .live && reward.remaining == 0 {
    return .ksr_text_dark_grey_500
  } else if project.state == .live && reward.remaining == 0 &&
    userIsBacking(reward: reward, inProject: project) {
    return .ksr_green_700
  } else if project.state != .live && reward.remaining == 0 &&
    userIsBacking(reward: reward, inProject: project) {
    return .ksr_text_dark_grey_500
  } else if (project.state == .live && reward.remaining == 0) ||
    (project.state != .live && reward.remaining == 0) {
    return .ksr_text_dark_grey_400
  } else if project.state == .live {
    return .ksr_green_700
  } else if project.state != .live {
    return .ksr_soft_black
  } else {
    return .ksr_soft_black
  }
}

private func needsConversion(project: Project) -> Bool {
  return project.stats.needsConversion
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

private func rewardTitle(project: Project, reward: Reward) -> String {

  guard project.personalization.isBacking == true else {
    return reward == Reward.noReward
      ? Strings.Id_just_like_to_support_the_project()
      : (reward.title ?? "")
  }

  return reward.title ?? Strings.Thank_you_for_supporting_this_project()
}

private func footerString(project: Project, reward: Reward) -> String {
  var parts: [String] = []

  if let endsAt = reward.endsAt, project.state == .live
      && endsAt > 0
      && endsAt >= AppEnvironment.current.dateType.init().timeIntervalSince1970 {

    let (time, unit) = Format.duration(secondsInUTC: min(endsAt, project.dates.deadline),
                                       abbreviate: true,
                                       useToGo: false)

    parts.append(Strings.Time_left_left(time_left: time + " " + unit))
  }

  if let remaining = reward.remaining, reward.limit != nil && project.state == .live {
    parts.append(Strings.Left_count_left(left_count: remaining))
  }

  if let backersCount = reward.backersCount {
    parts.append(Strings.general_backer_count_backers(backer_count: backersCount))
  }

  return parts
    .map { part in part.nonBreakingSpaced() }
    .joined(separator: " • ")
}

private func formattedAmount(for backing: Backing) -> String {
  let amount = backing.amount
  let backingAmount = floor(amount) == backing.amount
    ? String(Int(amount))
    : String(format: "%.2f", backing.amount)
  return backingAmount
}

private func shouldCollapse(reward: Reward, forProject project: Project) -> Bool {
  return reward.remaining == .some(0)
    && !userIsBacking(reward: reward, inProject: project)
    && project.state == .live
}
