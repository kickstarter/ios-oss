import AVFoundation
import Foundation
import UIKit

/// A small UIView so that `AVPlayer` can actually show up on screen
/// UIKit only renders video through an `AVPlayerLayer`, so we need to back the video player with one.
public final class VideoFeedPlayerView: UIView {
  public override class var layerClass: AnyClass { AVPlayerLayer.self }

  private var playerLayer: AVPlayerLayer { self.layer as! AVPlayerLayer }

  func setPlayer(_ player: AVPlayer) {
    self.playerLayer.player = player
    self.playerLayer.videoGravity = .resizeAspectFill
  }
}
