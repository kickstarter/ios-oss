import UIKit
import AVFoundation
import ReactiveCocoa

internal protocol HLSPlayerViewDelegate: class {
  func playbackStatedChanged(playerView: HLSPlayerView, state: AVPlayerItemStatus)
}

internal final class HLSPlayerView: UIView {
  private var hlsPlayerLayer: AVPlayerLayer!
  private var hlsPlayer: AVPlayer!
  private weak var delegate: HLSPlayerViewDelegate?

  internal init(hlsStreamUrl: NSURL, delegate: HLSPlayerViewDelegate?) {
    self.delegate = delegate

    super.init(frame: CGRect())

    /// Required for audio to play even if phone is set to silent
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
    } catch {}

    self.backgroundColor = UIColor.blackColor()

    let playerItem = AVPlayerItem(URL: hlsStreamUrl)
    self.hlsPlayer = AVPlayer(playerItem: playerItem)
    self.hlsPlayerLayer = AVPlayerLayer(player: self.hlsPlayer)
    self.hlsPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    self.layer.addSublayer(self.hlsPlayerLayer)
    self.hlsPlayer.play()

    self.delegate?.playbackStatedChanged(self, state: .Unknown)

    DynamicProperty(object: playerItem, keyPath: "status").signal.observeNext { [weak self] in
      guard
        let i = $0 as? Int,
        let s = AVPlayerItemStatus(rawValue: i),
        let _self = self
        else { return }

      self?.delegate?.playbackStatedChanged(_self, state: s)
    }
  }

  /// AVPlayer must be set to nil to be sure it will be released
  internal func destroy() {
    self.hlsPlayer = nil
    self.hlsPlayerLayer.removeFromSuperlayer()
    self.hlsPlayerLayer = nil
    self.removeFromSuperview()
  }

  internal required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.hlsPlayerLayer.frame = self.bounds
  }
}
