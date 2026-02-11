import UIKit

protocol PinchToZoomDelegate: AnyObject {
  func pinchZoomDidBegin(_ gestureRecognizer: UIPinchGestureRecognizer, frame: CGRect, image: UIImage)
  func pinchZoomDidChange(_ gestureRecognizer: UIPinchGestureRecognizer, completionHandler: () -> Void)
  func pinchZoomDidEnd(_ gestureRecognizer: UIPinchGestureRecognizer, completionHandler: @escaping () -> Void)
}

struct PinchToZoomData {
  var referenceFrame: CGRect
  var referenceCenter: CGPoint
  var imageView: UIImageView
}
