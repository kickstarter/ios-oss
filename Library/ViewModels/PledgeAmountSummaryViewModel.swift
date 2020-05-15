import Foundation
import KsApi
import Prelude
import ReactiveSwift

public struct PledgeAmountSummaryViewData {
  public let projectCountry: Project.Country
  public let pledgeAmount: Double
  public let pledgedOn: TimeInterval
  public let shippingAmount: Double?
  public let locationName: String?
  public let omitUSCurrencyCode: Bool
}

public protocol PledgeAmountSummaryViewModelInputs {
  func configureWith(_ data: PledgeAmountSummaryViewData)
  func viewDidLoad()
}

public protocol PledgeAmountSummaryViewModelOutputs {
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
          $0.projectCountry,
          ksr_pledgeAmount($0.pledgeAmount, subtractingShippingAmount: $0.shippingAmount),
          $0.omitUSCurrencyCode
        )
      }
      .map(attributedCurrency(with:amount:omitUSCurrencyCode:))
      .skipNil()

    self.shippingAmountText = data.map { ($0.projectCountry, $0.shippingAmount ?? 0, $0.omitUSCurrencyCode) }
      .map(shippingValue(with:amount:omitUSCurrencyCode:))
      .skipNil()

    self.shippingLocationText = data.map { $0.locationName }
      .skipNil()
      .map { Strings.Shipping_to_country(country: $0) }

    self.shippingLocationStackViewIsHidden = data.map { $0.locationName }.map(isNil)
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
    .withAllValuesFrom([.foregroundColor: UIColor.ksr_green_500])
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

private func shippingValue(
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
