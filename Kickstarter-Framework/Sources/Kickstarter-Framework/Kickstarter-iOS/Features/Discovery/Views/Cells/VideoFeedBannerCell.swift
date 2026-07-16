import KDS
import Library
import SwiftUI
import UIKit

internal protocol VideoFeedBannerCellDelegate: AnyObject {
  func videoFeedBannerCellDidTapTryItNow(_ cell: VideoFeedBannerCell)
}

@Observable
final class VideoFeedBannerViewState {
  var isLoading: Bool = false
  var horizontalContentPadding: CGFloat = Spacing.unit_03
}

// MARK: - Cell

internal final class VideoFeedBannerCell: UITableViewCell, ValueCell {
  internal weak var delegate: VideoFeedBannerCellDelegate?

  private enum Constants {
    static let verticalPadding: CGFloat = Spacing.unit_03
  }

  /// Set by the host view controller in willDisplay so the banner matches the
  /// project card width for that specific view (discovery vs. search).
  var horizontalInset: CGFloat = Styles.grid(2) {
    didSet {
      self.contentView.preservesSuperviewLayoutMargins = false
      self.contentView.layoutMargins = .init(
        top: 0,
        left: self.horizontalInset,
        bottom: 0,
        right: self.horizontalInset
      )

      let isIPad = self.horizontalInset >= Styles.grid(20)
      self.bannerState.horizontalContentPadding = isIPad ? Spacing.unit_04 : Spacing.unit_03
    }
  }

  private var hostingController: UIHostingController<VideoFeedBannerView>?
  private let bannerState = VideoFeedBannerViewState()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.setUp()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  internal func configureWith(value _: Void) {}

  // MARK: - Loading

  func setLoading(_ loading: Bool) {
    withAnimation(.easeInOut(duration: 0.2)) {
      self.bannerState.isLoading = loading
    }
  }

  // MARK: - Setup

  private func setUp() {
    self.selectionStyle = .none
    self.backgroundColor = .clear
    self.contentView.backgroundColor = .clear
    self.contentView.preservesSuperviewLayoutMargins = false

    var bannerView = VideoFeedBannerView(state: self.bannerState)

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
        equalTo: self.contentView.layoutMarginsGuide.leadingAnchor
      ),
      host.view.trailingAnchor.constraint(
        equalTo: self.contentView.layoutMarginsGuide.trailingAnchor
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
