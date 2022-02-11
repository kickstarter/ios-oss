import UIKit

protocol PinchToZoomDelegate: AnyObject {
  func pinchZoomDidBegin(_ gestureRecognizer: UIPinchGestureRecognizer, frame: CGRect, image: UIImage)
  func pinchZoomDidChange(_ gestureRecognizer: UIPinchGestureRecognizer)
  func pinchZoomDidEnd(_ gestureRecognizer: UIPinchGestureRecognizer)
}

struct PinchToZoomData {
  var referenceFrame: CGRect
  var referenceCenter: CGPoint
  var imageView: UIImageView
}
