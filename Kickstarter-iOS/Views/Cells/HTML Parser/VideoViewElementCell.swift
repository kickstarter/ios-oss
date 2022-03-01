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
    let controller = AVPlayerViewController()

    controller.player = AVPlayer()

    return controller
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

  func configureWith(value: (element: VideoViewElement, player: AVPlayer?)) {
    self.viewModel.inputs.configureWith(element: value.element, player: value.player)
  }

  // MARK: View Model

  internal override func bindViewModel() {
    self.viewModel.outputs.videoItem
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.resetPlayer()
      })
      .observeValues { [weak self] playerItem in
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])

        self?.playerController.player = playerItem
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
        equalTo: self.contentView.layoutMarginsGuide.widthAnchor,
        multiplier: aspectRatio
      )
    ])
  }

  // MARK: Helpers

  private func resetPlayer() {
    self.playerController.player = nil
  }

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
