import UIKit

private let fadeAlpha: CGFloat = 0.4
private let fadeTransform = CGAffineTransform(scaleX: 0.5, y: 0.5)

extension UIView {

  internal func attachLiveNowAnimation() {
    self.alpha = fadeAlpha
    self.transform = fadeTransform

    UIView.animate(
      withDuration: 1,
      delay: 0,
      options: [.autoreverse, .repeat, .curveEaseInOut],
      animations: { [weak v = self] in
        v?.alpha = 1
        v?.transform = .identity
      },
      completion: nil)
  }
}
