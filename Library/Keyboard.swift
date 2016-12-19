import Foundation
import UIKit
import ReactiveSwift
import Result

#if os(iOS)
public final class Keyboard {
  public typealias Change = (frame: CGRect, duration: TimeInterval, options: UIViewAnimationOptions)

  public static let shared = Keyboard()
  fileprivate let (changeSignal, changeObserver) = Signal<Change, NoError>.pipe()

  public static var change: Signal<Change, NoError> {
    return self.shared.changeSignal
  }

  fileprivate init() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(change(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

    NotificationCenter.default.addObserver(
      self, selector: #selector(change(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }

  @objc fileprivate func change(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
      let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
      let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
      let curveNumber = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber,
      let curve = UIViewAnimationCurve(rawValue: curveNumber.intValue)
      else {
        return
    }

    self.changeObserver.sendNext((
      frame.CGRectValue(),
      duration.doubleValue,
      UIViewAnimationOptions(rawValue: UInt(curve.rawValue))
    ))
  }
}
#endif
