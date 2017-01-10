import class AVFoundation.AVPlayerLayer
import class UIKit.UIView

public final class AVPlayerView: UIView {
  public override class var layerClass: AnyClass {
    return AVPlayerLayer.self
  }

  public var playerLayer: AVPlayerLayer? {
    return self.layer as? AVPlayerLayer
  }
}
