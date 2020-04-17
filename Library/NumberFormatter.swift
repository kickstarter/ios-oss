// swiftformat:disable wrap
import Foundation

final class AttributedNumberFormatter: NumberFormatter {
  // MARK: - Properties

  var defaultAttributes: String.Attributes = [:]
  var currencySymbolAttributes: String.Attributes = [:]
  var decimalSeparatorAttributes: String.Attributes = [:]
  var fractionDigitsAttributes: String.Attributes = [:]

  // MARK: - Attributed string

  override func attributedString(for obj: Any, withDefaultAttributes _: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString? {
    guard
      let number = obj as? NSNumber,
      let string = string(from: number)?.replacingOccurrences(of: String.nbsp + String.nbsp, with: String.nbsp)
    else { return nil }

    let mutableAttributedString = NSMutableAttributedString(
      string: string,
      attributes: self.defaultAttributes
    )

    if let currencySymbolRange = self.currencySymbolRange(for: string), currencySymbolRange.location != NSNotFound {
      mutableAttributedString.addAttributes(
        self.currencySymbolAttributes,
        range: currencySymbolRange
      )
    }

    if let decimalSeparatorRange = self.decimalSeparatorRange(for: string), decimalSeparatorRange.location != NSNotFound {
      mutableAttributedString.addAttributes(
        self.decimalSeparatorAttributes,
        range: decimalSeparatorRange
      )
    }

    if let fractionDigitsRange = self.fractionDigitsRange(for: string), fractionDigitsRange.location != NSNotFound {
      mutableAttributedString.addAttributes(
        self.fractionDigitsAttributes,
        range: fractionDigitsRange
      )
    }

    return NSAttributedString(attributedString: mutableAttributedString)
  }

  // MARK: - Ranges

  private func currencySymbolRange(for string: String) -> NSRange? {
    return self.numberStyle == .currency ? (string as NSString).range(of: self.currencySymbol) : nil
  }

  private func decimalSeparatorRange(for string: String) -> NSRange? {
    return self.minimumFractionDigits > 0 && self.maximumFractionDigits > 0
      ? (string as NSString).range(of: self.decimalSeparator) : nil
  }

  private func fractionDigitsRange(for string: String) -> NSRange? {
    if let decimalSeparatorRange = self.decimalSeparatorRange(for: string), decimalSeparatorRange.location != NSNotFound {
      return NSRange(
        location: decimalSeparatorRange.location + 1,
        length: self.maximumFractionDigits
      )
    } else {
      return nil
    }
  }
}
