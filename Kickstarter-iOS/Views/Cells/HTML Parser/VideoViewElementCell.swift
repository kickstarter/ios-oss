import AVKit
import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol VideoViewElementCellPlaybackDelegate: AnyObject {
  func pausePlayback() -> CMTime
}

class VideoViewElementCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private let viewModel: VideoViewElementCellViewModelType = VideoViewElementCellViewModel()
  private lazy var playerController: AVPlayerViewController = {
    let playerController = AVPlayerViewController()

    playerController.player = AVPlayer()

    return playerController
  }()

  weak var delegate: VideoViewElementCellPlaybackDelegate?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.delegate = self

    self.configureViews()
    self.bindStyles()
    self.bindViewModel()
  }

  // MARK: Initializers

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    self.playerController.player?.replaceCurrentItem(with: nil)
  }

  func configureWith(value videoElement: VideoViewElement) {
    self.viewModel.inputs.configureWith(videoElement: videoElement)
  }

  // MARK: View Model

  internal override func bindViewModel() {
    self.viewModel.outputs.videoURL
      .observeForUI()
      .observeValues { [weak self] url in
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])

        self?.playerController.player? = AVPlayer(url: url)
//        let asset = AVAsset(url: url)
//
//        asset.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) {
//          // heavy slow down -- move to `ProjectPageViewModel`
//          let playerItem = AVPlayerItem(asset: asset)
//
//          self?.playerController.player?.replaceCurrentItem(with: playerItem)
//        }
      }

    self.viewModel.outputs.seekTime
      .observeForUI()
      .observeValues { [weak self] seekTime in
        let validPlayTime = seekTime.isValid ? seekTime : .zero
        print("*** seek to \(seekTime)")
        self?.playerController.player?.seek(to: validPlayTime)
      }

    self.viewModel.outputs.pauseVideo
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.playerController.player?.pause()

        guard let player = self?.playerController.player else {
          self?.viewModel.inputs.recordSeektime(.zero)

          return
        }

        let currentSeekTime = player.currentTime()

        self?.viewModel.inputs.recordSeektime(currentSeekTime)
      }
  }

  // MARK: View Styles

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> \.separatorInset .~
      .init(
        top: 0,
        left: 0,
        bottom: 0,
        right: self.bounds.size.width + ProjectHeaderCellStyles.Layout.insets
      )

    _ = self.contentView
      |> \.layoutMargins .~ .init(
        topBottom: Styles.gridHalf(3),
        leftRight: Styles.grid(3)
      )

    let aspectRatio = CGFloat(9.0 / 16.0)

    NSLayoutConstraint.activate([
      self.playerController.view.heightAnchor.constraint(
        equalTo: self.contentView.widthAnchor,
        multiplier: aspectRatio
      )
    ]
    )
  }

  // MARK: Helpers

  private func configureViews() {
    _ = (self.playerController.view, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }
}

extension VideoViewElementCell: VideoViewElementCellPlaybackDelegate {
  func pausePlayback() -> CMTime {
    self.viewModel.inputs.pausePlayback()
  }
}
