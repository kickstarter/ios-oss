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
  let bulletPrefix = "•  "

  for textItem in textElement.components {
    var componentText = textItem.text
    // TODO: This will be external URL attached to a tap gesture on the label...need to connect this to the label accurately.
    let href = textItem.link ?? ""

    // - The end list style will be applied only to the LAST child of the LI element
    if textItem.styles.contains(.listEnd) {
      let updatedLastListBulletText = bulletPrefix + componentText + "\n"

      componentText = updatedLastListBulletText
    }

    let currentAttributedText = NSMutableAttributedString(string: componentText)
    let fullRange = (componentText as NSString).localizedStandardRange(of: componentText)
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

    textItem.styles.forEach { textStyleType in
      switch textStyleType {
      case .bold:
        let attributes = [
          NSAttributedString.Key.font: baseFont.bolded,
          NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
        ]

        currentAttributedText.addAttributes(attributes, range: fullRange)
      case .emphasis:
        let attributes = [
          NSAttributedString.Key.font: baseFont.italicized,
          NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
        ]

        currentAttributedText.addAttributes(attributes, range: fullRange)
      case .link:
        let attributes: String.Attributes = [
          .font: UIFont.ksr_subhead(size: baseFontSize),
          .underlineStyle: NSUnderlineStyle.single.rawValue,
          .foregroundColor: UIColor.ksr_create_700
        ]

        currentAttributedText.addAttributes(attributes, range: fullRange)
      case .list:
        let defaultAttributes: [NSAttributedString.Key: Any] = [
          .font: UIFont.ksr_callout()
        ]

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = (bulletPrefix as NSString).size(withAttributes: defaultAttributes).width
        paragraphStyle.paragraphSpacing = Styles.grid(1)

        let updatedTextWithBulletAndNewLine = bulletPrefix + componentText + "\n"

        let fullRangeWithBulletAndNewline = (updatedTextWithBulletAndNewLine as NSString)
          .localizedStandardRange(of: updatedTextWithBulletAndNewLine)

        let bulletedListAttributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle]

        let updatedCurrentAttributedText =
          NSMutableAttributedString(string: updatedTextWithBulletAndNewLine)

        updatedCurrentAttributedText
          .addAttributes(bulletedListAttributes, range: fullRangeWithBulletAndNewline)

      case .header:
        let attributes = [
          NSAttributedString.Key.font: headerFont,
          NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
        ]

        currentAttributedText.addAttributes(attributes, range: fullRange)
      default:
        currentAttributedText.addAttributes(baseFontAttributes, range: fullRange)
      }

      completedAttributedText.append(currentAttributedText)
    }
  }

  return SignalProducer(value: completedAttributedText)
}
