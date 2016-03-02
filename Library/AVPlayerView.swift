import class UIKit.UIView
import AVFoundation

public final class AVPlayerView: UIView {
  public override class func layerClass() -> AnyClass {
    return AVPlayerLayer.self
  }

  public var playerLayer: AVPlayerLayer? {
    return self.layer as? AVPlayerLayer
  }
}
