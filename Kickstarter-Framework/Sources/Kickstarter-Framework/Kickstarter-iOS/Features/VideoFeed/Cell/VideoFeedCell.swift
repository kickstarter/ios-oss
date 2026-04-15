import KDS
import Library
import SwiftUI
import UIKit

/// Hosts a `VideoFeedOverlayView` via UIHostingConfiguration and passes
/// right rail callbacks down so the controller can handle navigation.
final class VideoFeedCell: UICollectionViewCell, ValueCell {
  static let reuseIdentifier = "VideoFeedCell"

  // MARK: - Callbacks (wired by VideoFeedViewController)

  var onCreatorTapped: (() -> Void)?
  var onSaveTapped: (() -> Void)?
  var onShareTapped: (() -> Void)?
  var onMoreTapped: (() -> Void)?

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.onCreatorTapped = nil
    self.onSaveTapped = nil
    self.onShareTapped = nil
    self.onMoreTapped = nil
  }

  // MARK: - Configuration

  func configureWith(value: VideoFeedItem) {
    self.contentConfiguration = UIHostingConfiguration {
      VideoFeedOverlayView(
        item: value,
        onCreatorTapped: { [weak self] in self?.onCreatorTapped?() },
        onSaveTapped: { [weak self] in self?.onSaveTapped?() },
        onShareTapped: { [weak self] in self?.onShareTapped?() },
        onMoreTapped: { [weak self] in self?.onMoreTapped?() }
      )
    }
    .margins(.all, 0)
    .background(Color(Colors.Text.secondary.uiColor()))
  }
}
