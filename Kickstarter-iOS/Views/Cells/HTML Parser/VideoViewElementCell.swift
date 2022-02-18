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
  private lazy var playerController = AVPlayerViewController()
  private lazy var playButton: UIButton = { UIButton(frame: .zero) }()

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
    self.playButton.rac.hidden = self.viewModel.outputs.playButtonHidden

    self.viewModel.outputs.videoURL
      .observeForUI()
      .observeValues { [weak self] url in
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])

        self?.playerController.player = AVPlayer(url: url)
      }

    self.viewModel.outputs.seekTime
      .observeForUI()
      .observeValues { [weak self] seekTime in
        let validPlayTime = seekTime.isValid ? seekTime : .zero

        self?.playerController.player?.seek(to: validPlayTime)
      }

    self.viewModel.outputs.playVideo
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.playerController.player?.play()
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

    _ = self.playButton
      |> UIButton.lens.image(for: .normal) .~ Library.image(named: "play-arrow-icon")
      <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_white.withAlphaComponent(0.5)
      <> UIButton.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_play_video() }

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
    self.playButton.addTarget(self, action: #selector(self.playButtonTapped), for: .touchUpInside)

    _ = (self.playerController.view, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.playButton, self.playerController.view)
      |> ksr_addSubviewToParent()
  }

  @objc private func playButtonTapped() {
    self.viewModel.inputs.playButtonTapped()
  }
}

extension VideoViewElementCell: VideoViewElementCellPlaybackDelegate {
  func pausePlayback() -> CMTime {
    self.viewModel.inputs.pausePlayback()
  }
}
