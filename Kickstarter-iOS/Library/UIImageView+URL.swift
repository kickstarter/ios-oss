import AlamofireImage
import UIKit

extension UIImageView {

  public func ksr_setImageWithURL(_ url: URL) {

    self.af_setImage(withURL: url,
                     placeholderImage: nil,
                     filter: nil,
                     progress: nil,
                     progressQueue: DispatchQueue.main,
                     imageTransition: .CrossDissolve(0.3),
                     runImageTransitionIfCached: false,
                     completion: nil)
  }
}
