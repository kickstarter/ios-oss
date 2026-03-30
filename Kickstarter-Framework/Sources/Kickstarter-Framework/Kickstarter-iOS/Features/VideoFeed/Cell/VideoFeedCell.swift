import Library
import SwiftUI
import UIKit

/// Right now this is just static full screen color blocks with a centered title label.
/// Will update as the video feed is further built out.
final class VideoFeedCell: UICollectionViewCell, ValueCell {
  static let reuseIdentifier = "VideoFeedCell"

  private var overlayHostingController: UIHostingController<VideoFeedOverlayView>?

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setUpView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpView() {
    contentView.backgroundColor = .init(
      hue: .random(in: 0...1),
      saturation: 0.6,
      brightness: 0.8,
      alpha: 1
    )
  }

  /// Configures the cell with a feed item and adds the VideoFeedOverlayView
  func configureWith(value: VideoFeedItem) {
    let hc = UIHostingController(rootView: VideoFeedOverlayView(item: value))
    hc.view.backgroundColor = .clear
    hc.view.translatesAutoresizingMaskIntoConstraints = false

    self.contentView.addSubview(hc.view)

    NSLayoutConstraint.activate([
      hc.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
      hc.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
      hc.view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      hc.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    ])

    self.overlayHostingController = hc
  }
}
