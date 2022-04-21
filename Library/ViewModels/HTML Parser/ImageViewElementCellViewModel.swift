import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol ImageViewElementCellViewModelInputs {
  /// Call to configure with a `ImageViewElement`  representing raw HTML along with an optional displayable image
  func configureWith(imageElement: ImageViewElement, image: UIImage?)
}

public protocol ImageViewElementCellViewModelOutputs {
  /// Emits optional attributed text containing content of image caption after styling has been applied.
  var attributedText: Signal<NSAttributedString?, Never> { get }

  /// Emits an optional image for image view
  var image: Signal<UIImage?, Never> { get }
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
    self.attributedText = self.imageData.signal
      .skipNil()
      .switchMap { (imageElement, _) -> SignalProducer<NSAttributedString?, Never> in
        attributedTextFrom(imageElement)
      }

    self.image = self.imageData.signal
      .skipNil()
      .switchMap { (_, image) -> SignalProducer<UIImage?, Never> in
        guard let displayableImage = image else {
          return SignalProducer(value: nil)
        }

        return SignalProducer(value: displayableImage)
      }
  }

  fileprivate let imageData = MutableProperty<(ImageViewElement, UIImage?)?>(nil)
  public func configureWith(imageElement: ImageViewElement, image: UIImage?) {
    self.imageData.value = (imageElement, image)
  }

  public let attributedText: Signal<NSAttributedString?, Never>
  public let image: Signal<UIImage?, Never>

  public var inputs: ImageViewElementCellViewModelInputs { self }
  public var outputs: ImageViewElementCellViewModelOutputs { self }
}

private func attributedTextFrom(_ imageElement: ImageViewElement)
  -> SignalProducer<NSAttributedString?, Never> {
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
