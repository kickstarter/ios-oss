import Library
import UIKit

/// Right now this is just static full screen color blocks with a centered title label.
/// Will update as the video feed is further built out.
final class VideoFeedCell: UICollectionViewCell, ValueCell {
  static let reuseIdentifier = "VideoFeedCell"

  private let titleLabel = UILabel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setUpView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  func configureWith(value: VideoFeedItem) {
    self.titleLabel.text = value.title
  }

  // MARK: - Setup

  private func setUpView() {
    contentView.backgroundColor = .init(
      hue: .random(in: 0...1),
      saturation: 0.6,
      brightness: 0.8,
      alpha: 1
    )

    self.titleLabel.font = .ksr_title1()
    self.titleLabel.textColor = .white
    self.titleLabel.textAlignment = .center
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.addSubview(self.titleLabel)

    NSLayoutConstraint.activate([
      self.titleLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
      self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
      self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 24),
      self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -24)
    ])
  }
}
