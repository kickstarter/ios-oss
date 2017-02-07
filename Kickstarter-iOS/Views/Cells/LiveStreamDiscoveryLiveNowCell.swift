import AVFoundation
import AVKit
import Library
import LiveStream
import Prelude
import UIKit

internal final class LiveStreamDiscoveryLiveNowCell: UITableViewCell, ValueCell {
  private let viewModel: LiveStreamDiscoveryLiveNowCellViewModelType
    = LiveStreamDiscoveryLiveNowCellViewModel()

  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var creatorImageView: UIImageView!
  @IBOutlet private weak var creatorLabel: SimpleHTMLLabel!
  @IBOutlet private weak var creatorStackView: UIStackView!
  @IBOutlet private weak var imageOverlayView: UIView!
  @IBOutlet private weak var liveContainerView: UIView!
  @IBOutlet private weak var liveLabel: UILabel!
  @IBOutlet private weak var streamImageView: UIImageView!
  @IBOutlet private weak var streamPlayerView: AVPlayerView!
  @IBOutlet private weak var streamTitleContainerView: UIView!
  @IBOutlet private weak var streamTitleLabel: UILabel!
  @IBOutlet private weak var topGradientView: GradientView!

  internal func configureWith(value: LiveStreamEvent) {
    self.viewModel.inputs.configureWith(liveStreamEvent: value)
  }

  internal func didEndDisplay() {
    self.viewModel.inputs.didEndDisplay()
  }

  // swiftlint:disable:next function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { insets, cell in
        cell.traitCollection.isVerticallyCompact
          ? .init(top: Styles.grid(2), left: insets.left * 6, bottom: Styles.grid(4), right: insets.right * 6)
          : .init(top: Styles.grid(2), left: insets.left, bottom: Styles.grid(4), right: insets.right)
    }

    _ = self.cardView
      |> cardStyle()
      |> dropShadowStyle()

    _ = self.creatorLabel
      |> SimpleHTMLLabel.lens.boldFont .~ UIFont.ksr_title3(size: 14).bolded
      |> SimpleHTMLLabel.lens.baseFont .~ UIFont.ksr_title3(size: 14)
      |> SimpleHTMLLabel.lens.baseColor .~ .white
      |> SimpleHTMLLabel.lens.numberOfLines .~ 0

    _ = self.liveContainerView
      |> roundedStyle()
      |> UIView.lens.backgroundColor .~ .ksr_green_500
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.gridHalf(1), leftRight: Styles.gridHalf(3))

    _ = self.liveLabel
      |> UILabel.lens.text %~ { _ in Strings.Live() }
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_title3(size: 13)
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.streamTitleContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: Styles.grid(3))

    _ = self.streamTitleLabel
      |> UILabel.lens.font .~ .ksr_title3(size: 16)
      |> UILabel.lens.textColor .~ .ksr_text_navy_900
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.streamImageView
      |> UIImageView.lens.clipsToBounds .~ true

    _ = self.imageOverlayView
      |> UIView.lens.backgroundColor .~ UIColor.ksr_navy_900.withAlphaComponent(0.4)

    _ = self.creatorStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    self.topGradientView.startPoint = .init(x: 0, y: 0)
    self.topGradientView.endPoint = .init(x: 0, y: 1)
    self.topGradientView.setGradient(
      [
        (UIColor.black.withAlphaComponent(0.6), 0),
        (UIColor.black.withAlphaComponent(0), 1)
      ]
    )
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.creatorImageView.rac.imageUrl = self.viewModel.outputs.creatorImageUrl
    self.creatorLabel.rac.html = self.viewModel.outputs.creatorLabelText

    self.viewModel.outputs.playVideoUrl
      .observeForUI()
      .observeValues { [weak self] in self?.loadVideo(url: $0) }

    self.streamImageView.rac.imageUrl = self.viewModel.outputs.streamImageUrl
    self.streamTitleLabel.rac.text = self.viewModel.outputs.streamTitleLabel

    self.viewModel.outputs.stopVideo
      .observeForUI()
      .observeValues { [weak self] in self?.stopVideo() }
  }

  private func stopVideo() {
    self.streamPlayerView.alpha = 0
    self.streamPlayerView.playerLayer?.player?.pause()
    self.streamPlayerView.playerLayer?.player = nil
  }

  private func loadVideo(url: URL?) {
    self.streamPlayerView.alpha = 0

    self.streamPlayerView.playerLayer?.player = url.map(AVPlayer.init(url:))
    self.streamPlayerView.playerLayer?.player?.play()
    self.streamPlayerView.playerLayer?.player?.isMuted = true
    self.streamPlayerView.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
    self.streamPlayerView.backgroundColor = .black

    UIView.animate(withDuration: 0.3) {
      self.streamPlayerView.alpha = 1
    }
  }
}
