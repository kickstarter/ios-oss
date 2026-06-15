import Library
import UIKit

protocol VideoFeedBannerPresenting: UIViewController, MessageBannerViewControllerPresenting {
  var pendingVideoFeedVC: VideoFeedViewController? { get set }
}

extension VideoFeedBannerPresenting {
  func presentVideoFeed(from cell: VideoFeedBannerCell) {
    guard self.pendingVideoFeedVC == nil else { return }

    cell.setLoading(true)

    let feedVC = VideoFeedViewController()

    self.pendingVideoFeedVC = feedVC

    feedVC.loadViewIfNeeded()

    feedVC.onReadyToPresent = { [weak self, weak cell, weak feedVC] in
      guard let self, let feedVC else { return }

      self.pendingVideoFeedVC = nil

      cell?.setLoading(false)

      feedVC.modalPresentationStyle = .fullScreen

      self.present(feedVC, animated: true)
    }

    feedVC.onFetchFailed = { [weak self, weak cell] in
      guard let self else { return }

      self.pendingVideoFeedVC = nil

      cell?.setLoading(false)

      self.messageBannerViewController?.showBanner(
        with: .error,
        message: Strings.Something_went_wrong_please_try_again()
      )
    }

    feedVC.startFetch()
  }
}
