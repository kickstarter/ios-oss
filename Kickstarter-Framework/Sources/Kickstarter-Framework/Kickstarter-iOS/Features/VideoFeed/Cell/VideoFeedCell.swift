import KDS
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

  override func prepareForReuse() {
    super.prepareForReuse()

    self.overlayHostingController?.view.removeFromSuperview()
    self.overlayHostingController = nil
  }

  private func setUpView() {
    self.contentView.backgroundColor = Colors.Background.Accent.Gray.subtle.uiColor()
  }

  // MARK: - Config

  func configureWith(value: VideoFeedItem) {
    guard self.overlayHostingController == nil else {
      self.overlayHostingController?.rootView = VideoFeedOverlayView(item: value)
      return
    }

    let hc = UIHostingController(rootView: VideoFeedOverlayView(item: value))
    hc.view.backgroundColor = .clear
    hc.view.translatesAutoresizingMaskIntoConstraints = false
    /// Since the cell embeds the hosting view directly without `addChild`, UIKit
    /// can propagate the device's safe area insets incorrectly.
    /// Clearing `safeAreaRegions`prevents that and keeps the overlay content positioned correctly.
    hc.safeAreaRegions = []

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
