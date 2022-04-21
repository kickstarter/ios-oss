import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol TextViewElementCellViewModelInputs {
  /// Call to configure with a TextElement representing raw HTML
  func configureWith(textElement: TextViewElement)
}

public protocol TextViewElementCellViewModelOutputs {
  /// Emits attributed text containing content of HTML after styling has been applied.
  var attributedText: Signal<NSAttributedString, Never> { get }
}

public protocol TextViewElementCellViewModelType {
  var inputs: TextViewElementCellViewModelInputs { get }
  var outputs: TextViewElementCellViewModelOutputs { get }
}

public final class TextViewElementCellViewModel:
  TextViewElementCellViewModelType, TextViewElementCellViewModelInputs, TextViewElementCellViewModelOutputs {
  // MARK: Helpers

  public init() {
    let attributedText = self.textElement.signal
      .skipNil()
      .switchMap(attributedText(textElement:))

    self.attributedText = attributedText
  }

  fileprivate let textElement = MutableProperty<TextViewElement?>(nil)
  public func configureWith(textElement: TextViewElement) {
    self.textElement.value = textElement
  }

  public let attributedText: Signal<NSAttributedString, Never>

  public var inputs: TextViewElementCellViewModelInputs { self }
  public var outputs: TextViewElementCellViewModelOutputs { self }
}

private func attributedText(textElement: TextViewElement) -> SignalProducer<NSAttributedString, Never> {
  let completedAttributedText = NSMutableAttributedString()

  for textItemIndex in 0..<textElement.components.count {
    let textItem = textElement.components[textItemIndex]
    let componentText = textItem.text
    let paragraphStyle = NSMutableParagraphStyle()
    let currentAttributedText = NSMutableAttributedString(string: componentText)
    let fullRange = (componentText as NSString).localizedStandardRange(of: textItem.text)
    let baseFontSize: CGFloat = 16.0
    let baseFont = UIFont.ksr_body(size: baseFontSize)
    let headerFontSize: CGFloat = 20.0
    let headerFont = UIFont.ksr_body(size: headerFontSize).bolded
    paragraphStyle.minimumLineHeight = 22
    let baseFontAttributes = [
      NSAttributedString.Key.font: baseFont,
      NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700,
      NSAttributedString.Key.paragraphStyle: paragraphStyle
    ]

    guard textItem.styles.count > 0 else {
      currentAttributedText.addAttributes(baseFontAttributes, range: fullRange)
      completedAttributedText.append(currentAttributedText)

      continue
    }

    var combinedAttributes: [NSAttributedString.Key: Any] = baseFontAttributes

    textItem.styles.forEach { textStyleType in
      switch textStyleType {
      case .bold:
        if let existingFont = combinedAttributes[NSAttributedString.Key.font] as? UIFont,
          existingFont == baseFont.italicized {
          combinedAttributes[NSAttributedString.Key.font] = baseFont.boldItalic
        } else {
          combinedAttributes[NSAttributedString.Key.font] = baseFont.bolded
        }
      case .emphasis:
        if let existingFont = combinedAttributes[NSAttributedString.Key.font] as? UIFont,
          existingFont == baseFont.bolded {
          combinedAttributes[NSAttributedString.Key.font] = baseFont.boldItalic
        } else {
          combinedAttributes[NSAttributedString.Key.font] = baseFont.italicized
        }
      case .link:
        combinedAttributes[NSAttributedString.Key.foregroundColor] = UIColor.ksr_create_700
        combinedAttributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue

        if let validURLString = textItem.link,
          let validURL = URL(string: validURLString) {
          combinedAttributes[NSAttributedString.Key.link] = validURL
        }
      case .bulletStart:
        paragraphStyle.headIndent = (textItem.text as NSString).size(withAttributes: baseFontAttributes).width
        combinedAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
      case .bulletEnd:
        let moreBulletPointsExist = !textElement.components[textItemIndex..<textElement.components.count]
          .compactMap { component -> TextComponent? in
            if !component.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
              return component
            }

            return nil
          }
          .isEmpty

        if moreBulletPointsExist {
          completedAttributedText.append(NSAttributedString(string: "\n"))
        }
      case .header:
        combinedAttributes[NSAttributedString.Key.font] = headerFont
        combinedAttributes[NSAttributedString.Key.foregroundColor] = UIColor.ksr_support_700
        paragraphStyle.minimumLineHeight = 25
        combinedAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
      }
    }

    currentAttributedText.addAttributes(combinedAttributes, range: fullRange)
    completedAttributedText.append(currentAttributedText)
  }

  return SignalProducer(value: completedAttributedText)
}
