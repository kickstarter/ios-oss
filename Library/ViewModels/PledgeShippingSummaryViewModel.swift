import Foundation
import KsApi
import Prelude
import ReactiveSwift

public struct PledgeShippingSummaryViewData: Equatable {
  public let locationName: String
  public let omitUSCurrencyCode: Bool
  public let projectCountry: Project.Country
  public let total: Double
}

public protocol PledgeShippingSummaryViewModelInputs {
  func configure(with data: PledgeShippingSummaryViewData)
}

public protocol PledgeShippingSummaryViewModelOutputs {
  var amountLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var locationLabelText: Signal<String, Never> { get }
}

public protocol PledgeShippingSummaryViewModelType {
  var inputs: PledgeShippingSummaryViewModelInputs { get }
  var outputs: PledgeShippingSummaryViewModelOutputs { get }
}

public class PledgeShippingSummaryViewModel: PledgeShippingSummaryViewModelType,
  PledgeShippingSummaryViewModelInputs, PledgeShippingSummaryViewModelOutputs {
  public init() {
    let configData = self.configureWithDataProperty.signal.skipNil()

    self.locationLabelText = configData.map(\.locationName)

    self.amountLabelAttributedText = configData.map {
      data in (data.projectCountry, data.omitUSCurrencyCode, data.total)
    }
    .map(attributedCurrency)
    .skipNil()
  }

  private let configureWithDataProperty = MutableProperty<PledgeShippingSummaryViewData?>(nil)
  public func configure(with data: PledgeShippingSummaryViewData) {
    self.configureWithDataProperty.value = data
  }

  public let amountLabelAttributedText: Signal<NSAttributedString, Never>
  public let locationLabelText: Signal<String, Never>

  public var inputs: PledgeShippingSummaryViewModelInputs { return self }
  public var outputs: PledgeShippingSummaryViewModelOutputs { return self }
}

private func attributedCurrency(
  with projectCountry: Project.Country,
  omitCurrencyCode: Bool,
  total: Double
) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
  let superscriptAttributes = checkoutCurrencySuperscriptAttributes()
  guard
    let attributedCurrency = Format.attributedCurrency(
      total,
      country: projectCountry,
      omitCurrencyCode: omitCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: superscriptAttributes
    ) else { return nil }

  let combinedAttributes = defaultAttributes.withAllValuesFrom(superscriptAttributes)

  return Format.attributedPlusSign(combinedAttributes) + attributedCurrency
}
