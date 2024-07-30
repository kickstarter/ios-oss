import KsApi
import Prelude
import ReactiveSwift
import UIKit

public enum PostCampaignRewardsSummaryItem {
  case header(PledgeExpandableHeaderRewardCellData)
  case reward(PledgeExpandableHeaderRewardCellData)

  public var data: PledgeExpandableHeaderRewardCellData {
    switch self {
    case let .header(data): return data
    case let .reward(data): return data
    }
  }

  public var isHeader: Bool {
    switch self {
    case .header: return true
    case .reward: return false
    }
  }

  public var isReward: Bool {
    switch self {
    case .header: return false
    case .reward: return true
    }
  }
}

public struct PostCampaignRewardsSummaryViewData {
  public let rewards: [Reward]
  public let selectedQuantities: SelectedRewardQuantities
  public let projectCountry: Project.Country
  public let omitCurrencyCode: Bool
  public let shipping: PledgeShippingSummaryViewData?
}

public protocol PostCampaignPledgeRewardsSummaryViewModelInputs {
  func configureWith(
    rewardsData: PostCampaignRewardsSummaryViewData,
    bonusAmount: Double?,
    pledgeData: PledgeSummaryViewData
  )
  func viewDidLoad()
}

public protocol PostCampaignPledgeRewardsSummaryViewModelOutputs {
  var configurePledgeTotalViewWithData: Signal<PledgeSummaryViewData, Never> { get }
  var loadRewardsIntoDataSource: Signal<[PostCampaignRewardsSummaryItem], Never> { get }
}

public protocol PostCampaignPledgeRewardsSummaryViewModelType {
  var inputs: PostCampaignPledgeRewardsSummaryViewModelInputs { get }
  var outputs: PostCampaignPledgeRewardsSummaryViewModelOutputs { get }
}

public final class PostCampaignPledgeRewardsSummaryViewModel: PostCampaignPledgeRewardsSummaryViewModelType,
  PostCampaignPledgeRewardsSummaryViewModelInputs, PostCampaignPledgeRewardsSummaryViewModelOutputs {
  public init() {
    let data = Signal.combineLatest(
      self.configureWithDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let rewardData = data.map { $0.0 }
    let rewards = data.map(\.0.rewards)
    let selectedQuantities = data.map(\.0.selectedQuantities)
    let bonusAmount = data.map(\.1)

    let latestRewardDeliveryDate = rewards.map { rewards in
      rewards
        .compactMap { $0.estimatedDeliveryOn }
        .reduce(0) { accum, value in max(accum, value) }
    }

    let estimatedDeliveryString = latestRewardDeliveryDate.map { date -> String? in
      guard date > 0 else { return nil }

      let dateString = Format.date(
        secondsInUTC: date,
        template: DateFormatter.monthYear,
        timeZone: UTCTimeZone
      )

      return Strings.backing_info_estimated_delivery_date(delivery_date: dateString)
    }

    let total: Signal<Double, Never> = Signal.combineLatest(
      rewards,
      selectedQuantities
    )
    .map { rewards, selectedQuantities in
      rewards.reduce(0.0) { total, reward in
        let totalForReward = reward.minimum
          .multiplyingCurrency(Double(selectedQuantities[reward.id] ?? 0))

        return total.addingCurrency(totalForReward)
      }
    }

    self.loadRewardsIntoDataSource = Signal.zip(
      rewardData,
      selectedQuantities,
      estimatedDeliveryString,
      bonusAmount,
      total
    )
    .map(items)

    self.configurePledgeTotalViewWithData = data.map { data in
      let (_, _, pledgeSummaryData) = data
      return pledgeSummaryData
    }
  }

  private let configureWithDataProperty =
    MutableProperty<(PostCampaignRewardsSummaryViewData, Double?, PledgeSummaryViewData)?>(nil)
  public func configureWith(
    rewardsData: PostCampaignRewardsSummaryViewData,
    bonusAmount: Double?,
    pledgeData: PledgeSummaryViewData
  ) {
    self.configureWithDataProperty.value = (rewardsData, bonusAmount, pledgeData)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let configurePledgeTotalViewWithData: Signal<PledgeSummaryViewData, Never>
  public let loadRewardsIntoDataSource: Signal<[PostCampaignRewardsSummaryItem], Never>

  public var inputs: PostCampaignPledgeRewardsSummaryViewModelInputs { return self }
  public var outputs: PostCampaignPledgeRewardsSummaryViewModelOutputs { return self }
}

// MARK: - Functions

private func items(
  with data: PostCampaignRewardsSummaryViewData,
  selectedQuantities: SelectedRewardQuantities,
  estimatedDeliveryString: String?,
  bonusAmount: Double?,
  total _: Double
) -> [PostCampaignRewardsSummaryItem] {
  // MARK: Header

  let headerItem = PostCampaignRewardsSummaryItem.header((
    text: estimatedDeliveryString ?? "",
    amount: NSAttributedString(string: "")
  ))

  // MARK: Rewards

  let rewardItems = data.rewards.compactMap { reward -> PostCampaignRewardsSummaryItem? in
    guard let title = reward.title else { return nil }

    let quantity = selectedQuantities[reward.id] ?? 0
    let itemString = quantity > 1 ? "\(Format.wholeNumber(quantity)) x \(title)" : title

    let amount = quantity > 1 ? reward.minimum * Double(quantity) : reward.minimum
    let amountAttributedText = attributedRewardCurrency(
      with: data.projectCountry, amount: amount, omitUSCurrencyCode: data.omitCurrencyCode
    )

    return PostCampaignRewardsSummaryItem.reward((
      text: itemString,
      amount: amountAttributedText
    ))
  }
  var items = [headerItem] + rewardItems

  if featureNoShippingAtCheckout() == false {
    // MARK: Shipping

    if let shipping = data.shipping {
      let shippingAmountAttributedText = attributedRewardCurrency(
        with: data.projectCountry, amount: shipping.total, omitUSCurrencyCode: data.omitCurrencyCode
      )

      let shippingItem = PostCampaignRewardsSummaryItem.reward((
        text: Strings.Shipping_to_country(country: shipping.locationName),
        amount: shippingAmountAttributedText
      ))

      items.append(shippingItem)
    }
  }

  // MARK: Bonus

  if let bonus = bonusAmount {
    let bonusAmountAttributedText = attributedRewardCurrency(
      with: data.projectCountry, amount: bonus, omitUSCurrencyCode: data.omitCurrencyCode
    )

    let bonusItem = PostCampaignRewardsSummaryItem.reward((
      text: Strings.Bonus_support(),
      amount: bonusAmountAttributedText
    ))

    items.append(bonusItem)
  }

  return items
}

private func attributedRewardCurrency(
  with projectCountry: Project.Country,
  amount: Double,
  omitUSCurrencyCode: Bool
) -> NSAttributedString {
  let currencyString = Format.currency(
    amount,
    country: projectCountry,
    omitCurrencyCode: omitUSCurrencyCode,
    maximumFractionDigits: 0,
    minimumFractionDigits: 0
  )

  return NSAttributedString(
    string: currencyString,
    attributes: [
      .foregroundColor: UIColor.ksr_support_400,
      .font: UIFont.ksr_subhead().bolded
    ]
  )
}
