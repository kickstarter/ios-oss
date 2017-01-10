import UIKit
import AVFoundation
import ReactiveCocoa

private let statusKeyPath = "status"

internal protocol HLSPlayerViewDelegate: class {
  func playbackStatedChanged(playerView: HLSPlayerView, state: AVPlayerItemStatus)
}

internal final class HLSPlayerView: UIView {
  private let playerItem: AVPlayerItem
  private let hlsPlayerLayer: AVPlayerLayer
  private weak var delegate: HLSPlayerViewDelegate?

  internal init(hlsStreamUrl: NSURL, delegate: HLSPlayerViewDelegate?) {
    self.delegate = delegate

    /// Required for audio to play even if phone is set to silent
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
    } catch {}

    self.playerItem = AVPlayerItem(URL: hlsStreamUrl)
    self.hlsPlayerLayer = AVPlayerLayer(player: AVPlayer(playerItem: self.playerItem))
    self.hlsPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

    super.init(frame: CGRect())

    self.backgroundColor = .blackColor()

    self.layer.addSublayer(self.hlsPlayerLayer)
    self.delegate?.playbackStatedChanged(self, state: .Unknown)

    self.playerItem.addObserver(self, forKeyPath: statusKeyPath, options: .New, context: nil)

    self.hlsPlayerLayer.player?.play()
  }

  internal required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.hlsPlayerLayer.frame = self.bounds
  }

  //FIXME: make sure this gets deinit'd when multiple are created
  deinit {
    self.hlsPlayerLayer.player = nil
    self.playerItem.removeObserver(self, forKeyPath: statusKeyPath)
  }

  internal override func observeValueForKeyPath(keyPath: String?,
                                                ofObject object: AnyObject?,
                                                change: [String : AnyObject]?,
                                                context: UnsafeMutablePointer<Void>) {

    if keyPath == statusKeyPath {
      self.delegate?.playbackStatedChanged(self, state: self.playerItem.status)
    }
  }
}
