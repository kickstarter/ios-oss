import class UIKit.UIView
import AVFoundation

class AVPlayerView: UIView {
  override class func layerClass() -> AnyClass {
    return AVPlayerLayer.self
  }

  var playerLayer: AVPlayerLayer? {
    return self.layer as? AVPlayerLayer
  }
}
