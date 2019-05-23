import UIKit
@testable import Library

let defaultAttributes: String.Attributes = [
  .font: UIFont.ksr_title1(),
  .foregroundColor: UIColor.cyan
]

let superscriptAttributes: String.Attributes = [
  .font: UIFont.ksr_body(),
  .baselineOffset: UIFont.ksr_body().baselineOffsetToSuperscript(of: UIFont.ksr_title1())
]

Format.attributedCurrency(
  99.975,
  country: .us,
  omitCurrencyCode: true,
  defaultAttributes: defaultAttributes,
  superscriptAttributes: superscriptAttributes
)

Format.attributedCurrency(
  99.975,
  country: .us,
  defaultAttributes: defaultAttributes,
  superscriptAttributes: superscriptAttributes
)

Format.attributedCurrency(
  99.975,
  country: .ca,
  defaultAttributes: defaultAttributes,
  superscriptAttributes: superscriptAttributes
)

Format.attributedCurrency(
  0,
  country: .ca,
  defaultAttributes: defaultAttributes,
  superscriptAttributes: superscriptAttributes
)
