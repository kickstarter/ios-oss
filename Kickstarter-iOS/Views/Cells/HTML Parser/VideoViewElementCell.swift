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
  private lazy var playerLayer: AVPlayerLayer = { AVPlayerLayer() }()

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

  func configureWith(value: (element: VideoViewElement, item: AVPlayerItem?)) {
    self.viewModel.inputs.configureWith(element: value.element, item: value.item)
  }

  // MARK: View Model

  internal override func bindViewModel() {
    self.viewModel.outputs.videoItem
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.resetPlayerLayer()
      })
      .observeValues { [weak self] playerItem in
        guard let playerWithItem = playerItem else { return }

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])

        self?.playerLayer.player = playerWithItem
        print("*** frame \(self?.playerLayer.frame)")
        print("*** player \(self?.playerLayer.player)")
        print("*** player item status \(self?.playerLayer.player?.currentItem?.status)")
      }

    self.viewModel.outputs.seekTime
      .observeForUI()
      .observeValues { [weak self] seekTime in
        let validPlayTime = seekTime.isValid ? seekTime : .zero

        self?.playerLayer.player?.seek(to: validPlayTime)
      }

    self.viewModel.outputs.pauseVideo
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.playerLayer.player?.pause()

        guard let player = self?.playerLayer.player else {
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
      |> \.backgroundColor .~ .red
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
  }

  // MARK: Helpers

  private func resetPlayerLayer() {
    self.playerLayer.player = nil
  }

  private func configureViews() {
    self.contentView.layer.insertSublayer(self.playerLayer, above: self.contentView.layer.sublayers?.last)
  }
}

extension VideoViewElementCell: VideoViewElementCellPlaybackDelegate {
  func pausePlayback() -> CMTime {
    self.viewModel.inputs.pausePlayback()
  }
}
