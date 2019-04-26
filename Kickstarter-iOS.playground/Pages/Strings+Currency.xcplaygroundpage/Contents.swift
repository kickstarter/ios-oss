import UIKit
@testable import Library

// Currency symbol

attributedCurrencyString(
  currencySymbol: "",
  amount: 99.975,
  fractionDigits: 2,
  font: UIFont.ksr_title1(),
  superscriptFont: UIFont.ksr_body(),
  foregroundColor: UIColor.cyan
)

attributedCurrencyString(
  currencySymbol: "$",
  amount: 99.975,
  fractionDigits: 2,
  font: UIFont.ksr_title1(),
  superscriptFont: UIFont.ksr_body(),
  foregroundColor: UIColor.cyan
)

attributedCurrencyString(
  currencySymbol: "CA$",
  amount: 99.975,
  fractionDigits: 2,
  font: UIFont.ksr_title1(),
  superscriptFont: UIFont.ksr_body(),
  foregroundColor: UIColor.cyan
)

// Amount

attributedCurrencyString(
  currencySymbol: "CA$",
  amount: 0,
  fractionDigits: 2,
  font: UIFont.ksr_title1(),
  superscriptFont: UIFont.ksr_body(),
  foregroundColor: UIColor.cyan
)

attributedCurrencyString(
  currencySymbol: "CA$",
  amount: 99.975,
  fractionDigits: 2,
  font: UIFont.ksr_title1(),
  superscriptFont: UIFont.ksr_body(),
  foregroundColor: UIColor.cyan
)

// Fraction digits

attributedCurrencyString(
  currencySymbol: "CA$",
  amount: 99.975,
  fractionDigits: 0,
  font: UIFont.ksr_title1(),
  superscriptFont: UIFont.ksr_body(),
  foregroundColor: UIColor.cyan
)

attributedCurrencyString(
  currencySymbol: "CA$",
  amount: 99.975,
  fractionDigits: 1,
  font: UIFont.ksr_title1(),
  superscriptFont: UIFont.ksr_body(),
  foregroundColor: UIColor.cyan
)

attributedCurrencyString(
  currencySymbol: "CA$",
  amount: 99.975,
  fractionDigits: 3,
  font: UIFont.ksr_title1(),
  superscriptFont: UIFont.ksr_body(),
  foregroundColor: UIColor.cyan
)

attributedCurrencyString(
  currencySymbol: "CA$",
  amount: 99.975,
  fractionDigits: 5,
  font: UIFont.ksr_title1(),
  superscriptFont: UIFont.ksr_body(),
  foregroundColor: UIColor.cyan
)

// Fonts

attributedCurrencyString(
  currencySymbol: "CA$",
  amount: 99.975,
  fractionDigits: 2,
  font: UIFont.ksr_title1(),
  superscriptFont: UIFont.ksr_body(),
  foregroundColor: UIColor.cyan
)

attributedCurrencyString(
  currencySymbol: "CA$",
  amount: 99.975,
  fractionDigits: 2,
  font: UIFont.ksr_body(),
  superscriptFont: UIFont.ksr_title1(),
  foregroundColor: UIColor.cyan
)

attributedCurrencyString(
  currencySymbol: "CA$",
  amount: 99.975,
  fractionDigits: 2,
  font: UIFont.ksr_title1(),
  superscriptFont: UIFont.ksr_title1(),
  foregroundColor: UIColor.cyan
)

// Foreground color

attributedCurrencyString(
  currencySymbol: "CA$",
  amount: 99.975,
  fractionDigits: 2,
  font: UIFont.ksr_title1(),
  superscriptFont: UIFont.ksr_body(),
  foregroundColor: UIColor.red
)
