import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol ManagePledgeSummaryViewModelInputs {
  func configureWith(_ project: Project)
}

public protocol ManagePledgeSummaryViewModelOutputs {
  var backerNumberText: Signal<String, Never> { get }
  var backingDateText: Signal<String, Never> { get }
  var pledgeAmountText: Signal<NSAttributedString, Never> { get }
  var shippingAmountText: Signal<NSAttributedString, Never> { get }
  var shippingLocationStackViewIsHidden: Signal<Bool, Never> { get }
  var shippingLocationText: Signal<String, Never> { get }
  var totalAmountText: Signal<NSAttributedString, Never> { get }
}

public protocol ManagePledgeSummaryViewModelType {
  var inputs: ManagePledgeSummaryViewModelInputs { get }
  var outputs: ManagePledgeSummaryViewModelOutputs { get }
}

public class ManagePledgeSummaryViewModel: ManagePledgeSummaryViewModelType,
  ManagePledgeSummaryViewModelInputs, ManagePledgeSummaryViewModelOutputs {
  public init() {
    let backing = self.projectSignal
      .map { $0.personalization.backing }
      .skipNil()

    let projectAndBacking = self.projectSignal
      .zip(with: backing)

    self.backerNumberText = backing
      .map { Strings.backer_modal_backer_number(backer_number: Format.wholeNumber($0.sequence)) }

    self.backingDateText = backing
      .map(formattedPledgeDate)

    self.pledgeAmountText = projectAndBacking
      .map { project, backing in
        attributedCurrency(with: project, amount: backing.pledgeAmount)
      }
      .skipNil()

    let shippingAmount = backing
      .map { Double($0.shippingAmount ?? 0) }

    self.shippingAmountText = self.projectSignal
      .combineLatest(with: shippingAmount)
      .map { project, shippingAmount in
        shippingValue(with: project, with: shippingAmount)
      }
      .skipNil()

    self.totalAmountText = projectAndBacking
      .map { project, backing in
        attributedCurrency(with: project, amount: backing.amount)
      }
      .skipNil()

    self.shippingLocationText = backing
      .map { $0.locationName }
      .skipNil()
      .map { Strings.Shipping_to_country(country: $0) }

    self.shippingLocationStackViewIsHidden = self.projectSignal
      .map(shouldHideShippingLocationStackView)
  }

  private let (projectSignal, projectObserver) = Signal<Project, Never>.pipe()
  public func configureWith(_ project: Project) {
    self.projectObserver.send(value: project)
  }

  public let backerNumberText: Signal<String, Never>
  public let backingDateText: Signal<String, Never>
  public let pledgeAmountText: Signal<NSAttributedString, Never>
  public let shippingAmountText: Signal<NSAttributedString, Never>
  public let shippingLocationStackViewIsHidden: Signal<Bool, Never>
  public let shippingLocationText: Signal<String, Never>
  public let totalAmountText: Signal<NSAttributedString, Never>

  public var inputs: ManagePledgeSummaryViewModelInputs { return self }
  public var outputs: ManagePledgeSummaryViewModelOutputs { return self }
}

private func shouldHideShippingLocationStackView(_ project: Project) -> Bool {
  guard let backing = project.personalization.backing,
    let _ = backing.locationName else {
    return true
  }
  if let reward = backing.reward {
    return !reward.shipping.enabled || reward.isNoReward
  }

  return false
}

private func formattedPledgeDate(_ backing: Backing) -> String {
  let formattedDate = Format.date(secondsInUTC: backing.pledgedAt, dateStyle: .long, timeStyle: .none)
  return Strings.As_of_pledge_date(pledge_date: formattedDate)
}

private func attributedCurrency(with project: Project, amount: Double) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
    .withAllValuesFrom([.foregroundColor: UIColor.ksr_green_500])
  let superscriptAttributes = checkoutCurrencySuperscriptAttributes()
  guard
    let attributedCurrency = Format.attributedCurrency(
      amount,
      country: project.country,
      omitCurrencyCode: project.stats.omitUSCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: superscriptAttributes
    ) else { return nil }

  return attributedCurrency
}

private func shippingValue(with project: Project, with shippingRuleCost: Double) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
  let superscriptAttributes = checkoutCurrencySuperscriptAttributes()
  guard
    let attributedCurrency = Format.attributedCurrency(
      shippingRuleCost,
      country: project.country,
      omitCurrencyCode: project.stats.omitUSCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: superscriptAttributes
    ) else { return nil }

  let combinedAttributes = defaultAttributes.withAllValuesFrom(superscriptAttributes)

  return Format.attributedPlusSign(combinedAttributes) + attributedCurrency
}
