import UIKit

public extension UINavigationController {
  func pushViewControllerModally(_ viewController: UIViewController) {
    let transition:CATransition = CATransition()
    transition.duration = 0.3
    transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    transition.type = .moveIn
    transition.subtype = .fromTop
    self.view.layer.add(transition, forKey: kCATransition)
    self.pushViewController(viewController, animated: false)
  }
}
