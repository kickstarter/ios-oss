import Foundation
import UIKit
import ReactiveSwift
import Result

#if os(iOS)
public final class Keyboard {
  public typealias Change = (frame: CGRect, duration: TimeInterval, options: UIView.AnimationOptions,
    notificationName: Notification.Name)

  public static let shared = Keyboard()
  private let (changeSignal, changeObserver) = Signal<Change, NoError>.pipe()

  public static var change: Signal<Change, NoError> {
    return self.shared.changeSignal
  }

  private init() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(change(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

    NotificationCenter.default.addObserver(
      self, selector: #selector(change(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  @objc private func change(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
      let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
      let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
      let curveNumber = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
      let curve = UIView.AnimationCurve(rawValue: curveNumber.intValue)
      else {
        return
    }

    self.changeObserver.send(value: (
      frame.cgRectValue,
      duration.doubleValue,
      UIView.AnimationOptions(rawValue: UInt(curve.rawValue)),
      notificationName: notification.name
    ))
  }
}
#endif
