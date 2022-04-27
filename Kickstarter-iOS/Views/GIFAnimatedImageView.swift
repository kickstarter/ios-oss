import Kingfisher
import UIKit

final class GIFAnimatedImageView: AnimatedImageView {
  private var scaledImageSize: CGSize = .zero

//  override var intrinsicContentSize: CGSize {
//    self.scaledImageSize
//  }

  func setImageWith(_ image: UIImage?, scaledImageSize _: CGSize) {
    self.image = image
    // self.scaledImageSize = scaledImageSize
  }
}
