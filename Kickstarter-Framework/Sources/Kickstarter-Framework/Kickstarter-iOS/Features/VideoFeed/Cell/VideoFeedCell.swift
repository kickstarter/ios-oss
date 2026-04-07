import KDS
import Library
import SwiftUI
import UIKit

/// Right now this is just static full screen color blocks with a centered title label.
/// Will update as the video feed is further built out.
final class VideoFeedCell: UICollectionViewCell, ValueCell {
  static let reuseIdentifier = "VideoFeedCell"

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func configureWith(value: VideoFeedItem) {
    self.contentConfiguration = UIHostingConfiguration {
      VideoFeedOverlayView(item: value)
    }
    .margins(.all, 0)
    .background(Color(Colors.Text.secondary.uiColor()))
  }
}
