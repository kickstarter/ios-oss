import KDS
import Library
import UIKit

internal protocol VideoFeedBannerCellDelegate: AnyObject {
  func videoFeedBannerCellDidTapTryItNow(_ cell: VideoFeedBannerCell)
}

internal final class VideoFeedBannerCell: UITableViewCell, ValueCell {
  internal weak var delegate: VideoFeedBannerCellDelegate?

  private let bannerView = VideoFeedBannerView()

  // MARK: - Constants

  private enum Constants {
    static let horizontalPadding: CGFloat = Spacing.unit_03
    static let verticalPadding: CGFloat = Spacing.unit_03
  }

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

    NSLayoutConstraint.activate([
      self.bannerView.leadingAnchor.constraint(
        equalTo: self.contentView.leadingAnchor,
        constant: Constants.horizontalPadding
      ),
      self.bannerView.trailingAnchor.constraint(
        equalTo: self.contentView.trailingAnchor,
        constant: -Constants.horizontalPadding
      ),
      self.bannerView.topAnchor.constraint(
        equalTo: self.contentView.topAnchor,
        constant: Constants.verticalPadding
      ),
      self.bannerView.bottomAnchor.constraint(
        equalTo: self.contentView.bottomAnchor,
        constant: -Constants.verticalPadding
      )
    ])

    self.bannerView.onTryItNowTapped = { [weak self] in
      guard let self else { return }

      self.delegate?.videoFeedBannerCellDidTapTryItNow(self)
    }
  }
}
