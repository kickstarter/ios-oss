import KsApi
import Prelude
import ReactiveSwift

public protocol ImageViewElementCellViewModelInputs {
  /// Call to configure with a ImageElement representing raw HTML
  func configureWith(imageElement: ImageViewElement)
}

public protocol ImageViewElementCellViewModelOutputs {
  /// Emits attributed text containing content of image caption after styling has been applied.
  var attributedText: Signal<NSAttributedString, Never> { get }

  /// Emits an optional image data for image view
  var imageData: Signal<Data?, Never> { get }
}

public protocol ImageViewElementCellViewModelType {
  var inputs: ImageViewElementCellViewModelInputs { get }
  var outputs: ImageViewElementCellViewModelOutputs { get }
}

public final class ImageViewElementCellViewModel:
  ImageViewElementCellViewModelType, ImageViewElementCellViewModelInputs,
  ImageViewElementCellViewModelOutputs {
  // MARK: Helpers

  public init() {
    let attributedText = self.imageElement.signal
      .skipNil()
      .switchMap(attributedText(imageElement:))
      .skipNil()

    self.attributedText = attributedText

    let imageData = self.imageElement.signal
      .skipNil()
      .switchMap { imageElement -> SignalProducer<Data?, Never> in
        guard let data = imageElement.data else {
          return SignalProducer(value: nil)
        }

        return SignalProducer(value: data)
      }

    self.imageData = imageData
  }

  fileprivate let imageElement = MutableProperty<ImageViewElement?>(nil)
  public func configureWith(imageElement: ImageViewElement) {
    self.imageElement.value = imageElement
  }

  public let attributedText: Signal<NSAttributedString, Never>
  public let imageData: Signal<Data?, Never>

  public var inputs: ImageViewElementCellViewModelInputs { self }
  public var outputs: ImageViewElementCellViewModelOutputs { self }
}

private func attributedText(imageElement: ImageViewElement) -> SignalProducer<NSAttributedString?, Never> {
  guard let captionText = imageElement.caption, !captionText.isEmpty else {
    return SignalProducer(value: nil)
  }

  let completedAttributedText = NSMutableAttributedString()
  let paragraphStyle = NSMutableParagraphStyle()
  let currentAttributedText = NSMutableAttributedString(string: captionText)
  let fullRange = (captionText as NSString).localizedStandardRange(of: captionText)
  let baseFontSize: CGFloat = 12.0
  let baseFont = UIFont.ksr_body(size: baseFontSize).italicized
  paragraphStyle.minimumLineHeight = 22
  let baseFontAttributes = [
    NSAttributedString.Key.font: baseFont,
    NSAttributedString.Key.foregroundColor: UIColor.ksr_support_400,
    NSAttributedString.Key.paragraphStyle: paragraphStyle
  ]

  var combinedAttributes: [NSAttributedString.Key: Any] = baseFontAttributes

  if let validURLString = imageElement.href,
    let validURL = URL(string: validURLString) {
    combinedAttributes[NSAttributedString.Key.foregroundColor] = UIColor.ksr_create_700
    combinedAttributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
    combinedAttributes[NSAttributedString.Key.link] = validURL
  }

  currentAttributedText.addAttributes(combinedAttributes, range: fullRange)
  completedAttributedText.append(currentAttributedText)

  return SignalProducer(value: completedAttributedText)
}
