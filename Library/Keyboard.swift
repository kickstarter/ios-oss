import Foundation
import UIKit
import ReactiveSwift
import Result

#if os(iOS)
public final class Keyboard {
  public typealias Change = (frame: CGRect, duration: TimeInterval, options: UIViewAnimationOptions,
    notificationName: Notification.Name)

  public static let shared = Keyboard()
  private let (changeSignal, changeObserver) = Signal<Change, NoError>.pipe()

  public static var change: Signal<Change, NoError> {
    return self.shared.changeSignal
  }

  private init() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(change(_:)), name: .UIKeyboardWillShow, object: nil)

    NotificationCenter.default.addObserver(
      self, selector: #selector(change(_:)), name: .UIKeyboardWillHide, object: nil)
  }

  @objc private func change(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
      let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
      let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
      let curveNumber = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber,
      let curve = UIViewAnimationCurve(rawValue: curveNumber.intValue)
      else {
        return
    }

    self.changeObserver.send(value: (
      frame.cgRectValue,
      duration.doubleValue,
      UIViewAnimationOptions(rawValue: UInt(curve.rawValue)),
      notificationName: notification.name
    ))
  }
}
#endif
