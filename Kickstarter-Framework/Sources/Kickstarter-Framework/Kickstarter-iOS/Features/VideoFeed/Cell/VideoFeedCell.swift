import KDS
import Library
import SwiftUI
import UIKit

/// Hosts a `VideoFeedOverlayView` via UIHostingConfiguration and passes
/// right rail callbacks down so the controller can handle navigation.
final class VideoFeedCell: UICollectionViewCell, ValueCell {
  static let reuseIdentifier = "VideoFeedCell"

  var onCloseTapped: (() -> Void)?
  var onCreatorTapped: (() -> Void)?
  var onSaveTapped: (() -> Void)?
  var onShareTapped: (() -> Void)?
  var onMoreTapped: (() -> Void)?

  private let playbackState = VideoFeedPlaybackState()
  private let videoPlayer = VideoFeedVideoPlayer()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.playbackState.videoPlayer = self.videoPlayer
    self.setUpTapGesture()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.onCloseTapped = nil
    self.onCreatorTapped = nil
    self.onSaveTapped = nil
    self.onShareTapped = nil
    self.onMoreTapped = nil
    self.playbackState.isPlaying = true
    self.playbackState.isPlayButtonVisible = false
  }

  // MARK: - Configuration

  func configureWith(value: VideoFeedItem) {
    self.contentConfiguration = UIHostingConfiguration {
      VideoFeedOverlayView(
        item: value,
        playbackState: self.playbackState,
        videoPlayer: self.videoPlayer,
        onCloseTapped: { [weak self] in self?.onCloseTapped?() },
        onCreatorTapped: { [weak self] in self?.onCreatorTapped?() },
        onSaveTapped: { [weak self] in self?.onSaveTapped?() },
        onShareTapped: { [weak self] in self?.onShareTapped?() },
        onMoreTapped: { [weak self] in self?.onMoreTapped?() }
      )
    }
    .margins(.all, 0)
    .background(Color(Colors.Text.secondary.uiColor()))
  }

  // MARK: - Tap gesture

  private func setUpTapGesture() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped))
    tap.cancelsTouchesInView = false
    self.addGestureRecognizer(tap)
  }

  /// Tapping anywhere on the cell pauses playback and shows the play button.
  /// Tapping the play button resumes playback and hides it.
  @objc private func cellTapped() {
    self.playbackState.pause()
  }
}
