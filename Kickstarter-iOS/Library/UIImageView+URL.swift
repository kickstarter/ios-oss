import AlamofireImage
import UIKit

extension UIImageView {

  public func ksr_setImageWithURL(url: NSURL) {

    self.af_setImageWithURL(url,
                            placeholderImage: nil,
                            filter: nil,
                            progress: nil,
                            progressQueue: dispatch_get_main_queue(),
                            imageTransition: .CrossDissolve(0.3),
                            runImageTransitionIfCached: false,
                            completion: nil)
  }
}
