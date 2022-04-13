import AVKit
import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol AudioVideoViewElementCellPlaybackDelegate: AnyObject {
  func pausePlayback() -> CMTime
  func isPlaying() -> Bool
}

class AudioVideoViewElementCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private let viewModel: AudioVideoViewElementCellViewModelType = AudioVideoViewElementCellViewModel()
  private let observerKeyPath = "timeControlStatus"
  private lazy var playerController: AVPlayerViewController = { AVPlayerViewController() }()

  weak var delegate: AudioVideoViewElementCellPlaybackDelegate?

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

  func configureWith(value: (element: AudioVideoViewElement, player: AVPlayer?, thumbnailImage: UIImage?)) {
    self.viewModel.inputs.configureWith(
      element: value.element,
      player: value.player,
      thumbnailImage: value.thumbnailImage
    )
  }

  // MARK: View Model

  internal override func bindViewModel() {
    self.viewModel.outputs.audioVideoItem
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.resetPlayer()
      })
      .observeValues { [weak self] player in
        guard let strongSelf = self else { return }

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])

        strongSelf.playerController.player = player
      }

    self.viewModel.outputs.thumbnailImage
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.playerController.contentOverlayView?.subviews.forEach { $0.removeFromSuperview() }
      })
      .observeValues { [weak self] image in
        guard let strongSelf = self else { return }

        strongSelf.playerController.player?.addObserver(
          strongSelf,
          forKeyPath: strongSelf.observerKeyPath,
          options: [.old, .new],
          context: nil
        )

        if let contentOverlayView = strongSelf.playerController.contentOverlayView {
          let imageView = UIImageView()
          imageView.image = image

          _ = imageView
            |> thumbnailImageViewStyle
            |> \.isUserInteractionEnabled .~ false

          _ = (imageView, contentOverlayView)
            |> ksr_addSubviewToParent()
            |> ksr_constrainViewToMarginsInParent()
        }
      }

    self.viewModel.outputs.pauseAudioVideo
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

  override func observeValue(forKeyPath keyPath: String?,
                             of _: Any?,
                             change _: [NSKeyValueChangeKey: Any]?,
                             context _: UnsafeMutableRawPointer?) {
    if keyPath == self.observerKeyPath {
      self.playerController.contentOverlayView?.subviews.forEach { $0.removeFromSuperview() }
      self.playerController.player?.removeObserver(self, forKeyPath: self.observerKeyPath, context: nil)
    }
  }

  private func resetPlayer() {
    self.playerController.player = nil
    self.playerController.contentOverlayView?.subviews.forEach { $0.removeFromSuperview() }
  }

  private func configureViews() {
    _ = (self.playerController.view, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }
}

extension AudioVideoViewElementCell: AudioVideoViewElementCellPlaybackDelegate {
  func pausePlayback() -> CMTime {
    self.viewModel.inputs.pausePlayback()
  }

  func isPlaying() -> Bool {
    self.playerController.player?.timeControlStatus == .playing
  }
}
