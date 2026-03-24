import KDS
import Library
import SwiftUI
import UIKit

internal protocol VideoFeedBannerCellDelegate: AnyObject {
  func videoFeedBannerCellDidTapTryItNow(_ cell: VideoFeedBannerCell)
}

internal final class VideoFeedBannerCell: UITableViewCell, ValueCell {
  internal weak var delegate: VideoFeedBannerCellDelegate?

  private enum Constants {
    static let horizontalPadding: CGFloat = Spacing.unit_03
    static let verticalPadding: CGFloat = Spacing.unit_03
  }

  private var hostingController: UIHostingController<VideoFeedBannerView>?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.setUp()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.setUp()
  }

  internal func configureWith(value _: Void) {}

  private func setUp() {
    self.selectionStyle = .none
    self.backgroundColor = .clear
    self.contentView.backgroundColor = .clear

    var bannerView = VideoFeedBannerView()

    bannerView.onTryItNowTapped = { [weak self] in
      guard let self else { return }

      self.delegate?.videoFeedBannerCellDidTapTryItNow(self)
    }

    let host = UIHostingController(rootView: bannerView)
    host.view.translatesAutoresizingMaskIntoConstraints = false
    host.view.backgroundColor = .clear

    self.contentView.addSubview(host.view)

    NSLayoutConstraint.activate([
      host.view.leadingAnchor.constraint(
        equalTo: self.contentView.leadingAnchor,
        constant: Constants.horizontalPadding
      ),
      host.view.trailingAnchor.constraint(
        equalTo: self.contentView.trailingAnchor,
        constant: -Constants.horizontalPadding
      ),
      host.view.topAnchor.constraint(
        equalTo: self.contentView.topAnchor,
        constant: Constants.verticalPadding
      ),
      host.view.bottomAnchor.constraint(
        equalTo: self.contentView.bottomAnchor,
        constant: -Constants.verticalPadding
      )
    ])

    self.hostingController = host
  }

  func addHostingControllerToParent(_ parent: UIViewController) {
    guard let host = self.hostingController, host.parent == nil else { return }

    parent.addChild(host)

    host.didMove(toParent: parent)
  }
}
