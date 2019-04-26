import Foundation
import UIKit.UIColor
import UIKit.UIFont

public func attributedCurrencyString(
  currencySymbol: String,
  amount: Double,
  fractionDigits: UInt,
  font: UIFont,
  superscriptFont: UIFont,
  foregroundColor: UIColor
  ) -> NSAttributedString {
  // Drop decimal places
  let formattedString = String(format: "\(currencySymbol)%.\(fractionDigits)f", amount)

  let attributedString = NSMutableAttributedString(string: formattedString)
  let franctionDigitsAndSeparator = Int(fractionDigits == 0 ? fractionDigits : fractionDigits + 1)

  // Calculate prefix and suffix ranges
  let preffix = NSRange(location: 0, length: currencySymbol.count)
  let range = NSRange(location: 0, length: attributedString.length)
  let suffix = NSRange(
    location: attributedString.length - franctionDigitsAndSeparator,
    length: franctionDigitsAndSeparator
  )

  // Calculate vertical offset based on the height of a capital character of the two fonts
  let maxCapHeight: CGFloat = max(font.capHeight, superscriptFont.capHeight)
  let minCapHeight: CGFloat = min(font.capHeight, superscriptFont.capHeight)
  let multiplier: CGFloat = font.capHeight > superscriptFont.capHeight ? 1 : 0
  let baselineOffset = NSNumber(value: Float(multiplier * (maxCapHeight - minCapHeight)))

  // Set font for the whole string
  attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
  // Set foreground color for the whole string
  attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: foregroundColor, range: range)
  // Replace preffix font
  attributedString.addAttribute(NSAttributedString.Key.font, value: superscriptFont, range: preffix)
  // Offset preffix vertically from the baseline
  attributedString.addAttribute(NSAttributedString.Key.baselineOffset, value: baselineOffset, range: preffix)
  // Replace suffix font
  attributedString.addAttribute(NSAttributedString.Key.font, value: superscriptFont, range: suffix)
  // Offset suffix vertically from the baseline
  attributedString.addAttribute(NSAttributedString.Key.baselineOffset, value: baselineOffset, range: suffix)

  return NSAttributedString(attributedString: attributedString)
}
