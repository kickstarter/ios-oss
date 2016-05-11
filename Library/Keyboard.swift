import Foundation
import UIKit
import ReactiveCocoa
import Result

#if os(iOS)
public final class Keyboard {
  public typealias Change = (frame: CGRect, duration: NSTimeInterval, options: UIViewAnimationOptions)

  public static let shared = Keyboard()
  private let (changeSignal, changeObserver) = Signal<Change, NoError>.pipe()

  public static var change: Signal<Change, NoError> {
    return self.shared.changeSignal
  }

  private init() {
    NSNotificationCenter.defaultCenter().addObserver(
      self, selector: #selector(change(_:)), name: UIKeyboardWillShowNotification, object: nil)

    NSNotificationCenter.defaultCenter().addObserver(
      self, selector: #selector(change(_:)), name: UIKeyboardWillHideNotification, object: nil)
  }

  @objc private func change(notification: NSNotification) {
    guard let userInfo = notification.userInfo,
      frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
      duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
      curveNumber = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber,
      curve = UIViewAnimationCurve(rawValue: curveNumber.integerValue)
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
