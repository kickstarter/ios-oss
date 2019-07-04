import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeShippingLocationCellViewModelInputs {
  func configureWith(isLoading: Bool, project: Project, selectedShippingRule: ShippingRule?)
  func shippingLocationButtonTapped()
}

public protocol PledgeShippingLocationCellViewModelOutputs {
  var amountAttributedText: Signal<NSAttributedString, Never> { get }
  var shippingLocation: Signal<String, Never> { get }
  var shippingLocationSelected: Signal<ShippingRule, Never> { get }
}

public protocol PledgeShippingLocationCellViewModelType {
  var inputs: PledgeShippingLocationCellViewModelInputs { get }
  var outputs: PledgeShippingLocationCellViewModelOutputs { get }
}

public final class PledgeShippingLocationCellViewModel: PledgeShippingLocationCellViewModelType,
  PledgeShippingLocationCellViewModelInputs, PledgeShippingLocationCellViewModelOutputs {
  public init() {
    let projectAndSelectedShippingRule = Signal.combineLatest(
      self.configureWithDataProperty.signal.skipNil().map(second),
      self.configureWithDataProperty.signal.skipNil().map(third).skipNil()
    )

    self.amountAttributedText = projectAndSelectedShippingRule
      .map { project, selectedShippingRule in shippingValue(of: project, with: selectedShippingRule.cost) }
      .skipNil()

    self.shippingLocation = projectAndSelectedShippingRule
      .map { _, selectedShippingRule in selectedShippingRule.location.localizedName }

    self.shippingLocationSelected = projectAndSelectedShippingRule
      .map(second)
      .takeWhen(self.shippingLocationButtonTappedProperty.signal)
  }

  private let configureWithDataProperty = MutableProperty<(Bool, Project, ShippingRule?)?>(nil)
  public func configureWith(isLoading: Bool, project: Project, selectedShippingRule: ShippingRule?) {
    self.configureWithDataProperty.value = (isLoading, project, selectedShippingRule)
  }

  private let shippingLocationButtonTappedProperty = MutableProperty(())
  public func shippingLocationButtonTapped() {
    self.shippingLocationButtonTappedProperty.value = ()
  }

  public let amountAttributedText: Signal<NSAttributedString, Never>
  public let shippingLocation: Signal<String, Never>
  public let shippingLocationSelected: Signal<ShippingRule, Never>

  public var inputs: PledgeShippingLocationCellViewModelInputs { return self }
  public var outputs: PledgeShippingLocationCellViewModelOutputs { return self }
}

// MARK: - Functions

private func shippingValue(of project: Project, with shippingRuleCost: Double) -> NSAttributedString? {
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

  let combinedAttributes = defaultAttributes.merging(superscriptAttributes) { _, new in new }

  return Format.attributedPlusSign(combinedAttributes) + attributedCurrency
}
