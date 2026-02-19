import Library
import UIKit

internal protocol VideoFeedBannerCellDelegate: AnyObject {
  func videoFeedBannerCellDidTapTryItNow(_ cell: VideoFeedBannerCell)
}

internal final class VideoFeedBannerCell: UITableViewCell, ValueCell {
  internal weak var delegate: VideoFeedBannerCellDelegate?

  private let bannerView = VideoFeedBannerView()

  // MARK: - Init

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.setUpView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    self.setUpView()
  }

  internal func configureWith(value _: Void) {
    self.bannerView.configure()
  }

  // MARK: - Setup

  private func setUpView() {
    self.selectionStyle = .none
    self.backgroundColor = .clear
    self.contentView.backgroundColor = .clear

    self.contentView.addSubview(self.bannerView)

    /// Make the banner fill the cell with standard horizontal padding
    NSLayoutConstraint.activate([
      self.bannerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
      self.bannerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
      self.bannerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
      self.bannerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8)
    ])

    self.bannerView.onTryItNowTapped = { [weak self] in
      guard let self else { return }

      self.delegate?.videoFeedBannerCellDidTapTryItNow(self)
    }
  }
}
