import KsApi
import Prelude
import ReactiveSwift

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
    // TODO: This will be external URL attached to a tap gesture on the label...need to connect this to the label accurately.
    let href = textItem.link ?? ""

    let currentAttributedText = NSMutableAttributedString(string: componentText)
    let fullRange = (componentText as NSString).localizedStandardRange(of: textItem.text)
    let baseFontSize: CGFloat = 16.0
    let baseFont = UIFont.ksr_body(size: baseFontSize)
    let headerFontSize: CGFloat = 20.0
    let headerFont = UIFont.ksr_body(size: headerFontSize).bolded
    let baseFontAttributes = [
      NSAttributedString.Key.font: baseFont,
      NSAttributedString.Key.foregroundColor:
        UIColor.ksr_support_700
    ]

    guard textItem.styles.count > 0 else {
      currentAttributedText.addAttributes(baseFontAttributes, range: fullRange)
      completedAttributedText.append(currentAttributedText)

      continue
    }

    var combinedAttributes = [NSAttributedString.Key: Any]()

    textItem.styles.forEach { textStyleType in
      switch textStyleType {
      case .bold:
        if let existingFont = combinedAttributes[NSAttributedString.Key.font] as? UIFont,
          existingFont == baseFont.italicized {
          combinedAttributes[NSAttributedString.Key.font] = baseFont.boldItalic
        } else {
          combinedAttributes[NSAttributedString.Key.font] = baseFont.bolded
        }

        combinedAttributes[NSAttributedString.Key.foregroundColor] = UIColor.ksr_support_700
      case .emphasis:
        if let existingFont = combinedAttributes[NSAttributedString.Key.font] as? UIFont,
          existingFont == baseFont.bolded {
          combinedAttributes[NSAttributedString.Key.font] = baseFont.boldItalic
        } else {
          combinedAttributes[NSAttributedString.Key.font] = baseFont.italicized
        }

        combinedAttributes[NSAttributedString.Key.foregroundColor] = UIColor.ksr_support_700
      case .link:
        combinedAttributes[NSAttributedString.Key.foregroundColor] = UIColor.ksr_create_700
        combinedAttributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
      case .bulletStart:
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = (textItem.text as NSString).size(withAttributes: baseFontAttributes).width
        paragraphStyle.paragraphSpacing = Styles.grid(1)

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

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 25
        combinedAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
      }
    }

    currentAttributedText.addAttributes(combinedAttributes, range: fullRange)
    completedAttributedText.append(currentAttributedText)
  }

  return SignalProducer(value: completedAttributedText)
}
