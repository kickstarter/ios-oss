import AVKit
import Foundation
import Library
import UIKit
import youtube_ios_player_helper

class VideoViewElementCell: UITableViewCell {
  private var videoPlayerLayer: AVPlayerLayer?
  private var embedPlayerView: YTPlayerView?
  private var videoPlayerGestureRecognizer: UIGestureRecognizer?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.initialize()
  }

  override func prepareForReuse() {
    self.videoPlayerLayer?.player?.replaceCurrentItem(with: nil)
    self.videoPlayerLayer?.removeFromSuperlayer()
    self.videoPlayerLayer = nil

    self.embedPlayerView?.stopVideo()
    self.embedPlayerView?.removeFromSuperview()
    self.embedPlayerView = nil

    if let videoPlayerGestureRecognizer = videoPlayerGestureRecognizer {
      removeGestureRecognizer(videoPlayerGestureRecognizer)
    }
  }

  func initialize() {
    backgroundColor = UIColor.gray
  }

  func configureWith(value: VideoViewElement) {
    // The first will play the high quality video (0: high - 1: base)
    // TODO: Be able to remember where the user stopped playing the video
    guard let urlString = value.sourceUrls.first, let url = URL(string: urlString) else {
      return
    }

    // Example Urls
    // https://youtu.be/DEG1qicbAmU
    // https://www.youtube.com/watch?v=i0uU5IV_4ZA
    if url.host == "youtu.be", let videoId = url.pathComponents.last {
      self.configureYouTubeVideo(videoId: videoId)
    } else if url.host == "www.youtube.com", let queryItems = URLComponents(string: urlString)?.queryItems {
      let videoIdItem = queryItems.first { $0.name == "v" }
      if let videoId = videoIdItem?.value {
        self.configureYouTubeVideo(videoId: videoId)
      }
    } else {
      self.configureVideo(videoUrl: url)
    }
  }

  private func configureVideo(videoUrl: URL) {
    let videoPlayer = AVPlayer(url: videoUrl)
    videoPlayerLayer = AVPlayerLayer(player: videoPlayer)

    if let videoPlayerLayer = videoPlayerLayer {
      videoPlayerLayer.frame = bounds
      layer.addSublayer(videoPlayerLayer)
    }

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.togglePlay))
    self.videoPlayerGestureRecognizer = tapGestureRecognizer
    addGestureRecognizer(tapGestureRecognizer)
  }

  private func configureYouTubeVideo(videoId: String) {
    // TODO: ADD Youtube Player to the element to be able to preload the elements
    let videoPlayerView = YTPlayerView()
    embedPlayerView = videoPlayerView
    videoPlayerView.load(withVideoId: videoId)

    addSubview(videoPlayerView)
    videoPlayerView.snp.makeConstraints { make in
      make.leading.trailing.top.bottom.equalToSuperview()
    }
  }

  @IBAction func togglePlay() {
    if let player = videoPlayerLayer?.player {
      player.rate == 1 ? player.pause() : player.play()
    }
  }
}
