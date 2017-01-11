import UIKit
import AVFoundation
import ReactiveSwift

private let statusKeyPath = "status"

internal protocol HLSPlayerViewDelegate: class {
  func playbackStatedChanged(playerView: HLSPlayerView, state: AVPlayerItemStatus)
}

internal final class HLSPlayerView: UIView {
  private let playerItem: AVPlayerItem
  private let hlsPlayerLayer: AVPlayerLayer
  private weak var delegate: HLSPlayerViewDelegate?

  internal init(hlsStreamUrl: URL, delegate: HLSPlayerViewDelegate?) {
    self.delegate = delegate

    /// Required for audio to play even if phone is set to silent
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
    } catch {}

    self.playerItem = AVPlayerItem(url: hlsStreamUrl as URL)
    self.hlsPlayerLayer = AVPlayerLayer(player: AVPlayer(playerItem: self.playerItem))
    self.hlsPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

    super.init(frame: CGRect())

    self.backgroundColor = .black

    self.layer.addSublayer(self.hlsPlayerLayer)
    self.delegate?.playbackStatedChanged(playerView: self, state: .unknown)

    self.playerItem.addObserver(self, forKeyPath: statusKeyPath, options: .new, context: nil)

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

  internal override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {

    if keyPath == statusKeyPath {
      self.delegate?.playbackStatedChanged(playerView: self, state: self.playerItem.status)
    }
  }
}
