import UIKit
import AVFoundation
import ReactiveCocoa

internal protocol HLSPlayerViewDelegate: class {
  func playbackStatedChanged(playerView: HLSPlayerView, state: AVPlayerItemStatus)
}

internal final class HLSPlayerView: UIView {
  private let hlsPlayerLayer: AVPlayerLayer
  private weak var delegate: HLSPlayerViewDelegate?

  internal init(hlsStreamUrl: NSURL, delegate: HLSPlayerViewDelegate?) {
    self.delegate = delegate

    /// Required for audio to play even if phone is set to silent
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
    } catch {}

    let playerItem = AVPlayerItem(URL: hlsStreamUrl)
    self.hlsPlayerLayer = AVPlayerLayer(player: AVPlayer(playerItem: playerItem))
    self.hlsPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

    super.init(frame: CGRect())

    self.backgroundColor = .blackColor()

    self.layer.addSublayer(self.hlsPlayerLayer)
    self.delegate?.playbackStatedChanged(self, state: .Unknown)

    // FIXME: maybe we should just use regular KVO
    DynamicProperty(object: playerItem, keyPath: "status").signal.observeNext { [weak self] in
      guard
        let i = $0 as? Int,
        let s = AVPlayerItemStatus(rawValue: i),
        let _self = self
        else { return }

      _self.delegate?.playbackStatedChanged(_self, state: s)
    }

    self.hlsPlayerLayer.player?.play()
  }

  /// AVPlayer must be set to nil to be sure it will be released
  // FIXME: we may have broken this retain cycle by getting rid of hlsPlayer
  internal func destroy() {
    self.hlsPlayerLayer.player = nil
    self.hlsPlayerLayer.removeFromSuperlayer()
    // FIXME: remove after looking at retain cycles
//    self.hlsPlayerLayer = nil
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
