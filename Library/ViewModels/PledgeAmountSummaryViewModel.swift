import Foundation
import KsApi
import Prelude
import ReactiveSwift

public struct PledgeAmountSummaryViewData {
  public let bonusAmount: Double?
  public let bonusAmountHidden: Bool
  public let isNoReward: Bool
  public let locationName: String?
  public let omitUSCurrencyCode: Bool
  public let projectCurrencyCountry: Project.Country
  public let pledgedOn: TimeInterval
  public let rewardMinimum: Double
  public let shippingAmount: Double?
  public let shippingAmountHidden: Bool
  public let rewardIsLocalPickup: Bool
}

public protocol PledgeAmountSummaryViewModelInputs {
  func configureWith(_ data: PledgeAmountSummaryViewData)
  func viewDidLoad()
}

public protocol PledgeAmountSummaryViewModelOutputs {
  var bonusAmountText: Signal<NSAttributedString, Never> { get }
  var bonusAmountStackViewIsHidden: Signal<Bool, Never> { get }
  var pledgeAmountText: Signal<NSAttributedString, Never> { get }
  var shippingAmountText: Signal<NSAttributedString, Never> { get }
  var shippingLocationStackViewIsHidden: Signal<Bool, Never> { get }
  var shippingLocationText: Signal<String, Never> { get }
}

public protocol PledgeAmountSummaryViewModelType {
  var inputs: PledgeAmountSummaryViewModelInputs { get }
  var outputs: PledgeAmountSummaryViewModelOutputs { get }
}

public class PledgeAmountSummaryViewModel: PledgeAmountSummaryViewModelType,
  PledgeAmountSummaryViewModelInputs, PledgeAmountSummaryViewModelOutputs {
  public init() {
    let data = Signal.combineLatest(
      self.configureWithDataSignal,
      self.viewDidLoadProperty.signal
    )
    .map(first)

    self.pledgeAmountText = data
      .map {
        (
          $0.projectCurrencyCountry,
          $0.isNoReward ? ($0.bonusAmount ?? 0) : $0.rewardMinimum,
          $0.omitUSCurrencyCode
        )
      }
      .map(attributedCurrency)
      .skipNil()

    self.bonusAmountText = data
      .map { data in (data.projectCurrencyCountry, data.bonusAmount ?? 0, data.omitUSCurrencyCode) }
      .map(plusSignAmount)
      .skipNil()

    self.shippingAmountText = data
      .map { ($0.projectCurrencyCountry, $0.shippingAmount ?? 0, $0.omitUSCurrencyCode) }
      .map(plusSignAmount)
      .skipNil()

    self.shippingLocationText = data.map { $0.locationName }
      .skipNil()
      .map { Strings.Shipping_to_country(country: $0) }

    self.bonusAmountStackViewIsHidden = data.map { $0.isNoReward || $0.bonusAmountHidden }
    self.shippingLocationStackViewIsHidden = data.map {
      let nonLocalPickupShippingLocationStackViewIsHiddenConditions = ($0.locationName == nil || $0
        .shippingAmountHidden)

      return $0.rewardIsLocalPickup ? true : nonLocalPickupShippingLocationStackViewIsHiddenConditions
    }
  }

  private let (configureWithDataSignal, configureWithDataObserver)
    = Signal<PledgeAmountSummaryViewData, Never>.pipe()
  public func configureWith(_ data: PledgeAmountSummaryViewData) {
    self.configureWithDataObserver.send(value: data)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let bonusAmountText: Signal<NSAttributedString, Never>
  public let bonusAmountStackViewIsHidden: Signal<Bool, Never>
  public let pledgeAmountText: Signal<NSAttributedString, Never>
  public let shippingAmountText: Signal<NSAttributedString, Never>
  public let shippingLocationStackViewIsHidden: Signal<Bool, Never>
  public let shippingLocationText: Signal<String, Never>

  public var inputs: PledgeAmountSummaryViewModelInputs { return self }
  public var outputs: PledgeAmountSummaryViewModelOutputs { return self }
}

private func formattedPledgeDate(_ backing: Backing) -> String {
  let formattedDate = Format.date(secondsInUTC: backing.pledgedAt, dateStyle: .long, timeStyle: .none)
  return Strings.As_of_pledge_date(pledge_date: formattedDate)
}

private func attributedCurrency(
  with projectCountry: Project.Country,
  amount: Double,
  omitUSCurrencyCode: Bool
) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
  let superscriptAttributes = checkoutCurrencySuperscriptAttributes()
  guard
    let attributedCurrency = Format.attributedCurrency(
      amount,
      country: projectCountry,
      omitCurrencyCode: omitUSCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: superscriptAttributes
    ) else { return nil }

  return attributedCurrency
}

private func plusSignAmount(
  with projectCountry: Project.Country,
  amount: Double,
  omitUSCurrencyCode: Bool
) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
  let superscriptAttributes = checkoutCurrencySuperscriptAttributes()
  guard
    let attributedCurrency = Format.attributedCurrency(
      amount,
      country: projectCountry,
      omitCurrencyCode: omitUSCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: superscriptAttributes
    ) else { return nil }

  let combinedAttributes = defaultAttributes.withAllValuesFrom(superscriptAttributes)

  return Format.attributedPlusSign(combinedAttributes) + attributedCurrency
}
