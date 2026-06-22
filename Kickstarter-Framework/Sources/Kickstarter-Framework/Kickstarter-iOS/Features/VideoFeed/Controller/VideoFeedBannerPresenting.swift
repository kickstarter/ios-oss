import Library
import UIKit

protocol VideoFeedBannerPresenting: UIViewController, MessageBannerViewControllerPresenting {
  /// Retained across opens so VM state persists. Also prevents double-tapping while loading.
  var videoFeedVC: VideoFeedViewController? { get set }
}

extension VideoFeedBannerPresenting {
  func presentVideoFeed(from cell: VideoFeedBannerCell) {
    guard self.videoFeedVC == nil else {
      /// Reuse an existing feed VC so VM state (optimistic saves, etc.) persists across opens.
      if let existing = self.videoFeedVC, existing.isBeingPresented == false {
        existing.modalPresentationStyle = .fullScreen
        self.present(existing, animated: true)
      }
      return
    }

    cell.setLoading(true)

    let feedVC = VideoFeedViewController()

    self.videoFeedVC = feedVC

    feedVC.loadViewIfNeeded()

    feedVC.onReadyToPresent = { [weak self, weak cell, weak feedVC] in
      guard let self, let feedVC else { return }

      cell?.setLoading(false)

      feedVC.modalPresentationStyle = .fullScreen

      self.present(feedVC, animated: true)
    }

    feedVC.onFetchFailed = { [weak self, weak cell] in
      guard let self else { return }

      self.videoFeedVC = nil

      cell?.setLoading(false)

      self.messageBannerViewController?.showBanner(
        with: .error,
        message: Strings.Something_went_wrong_please_try_again()
      )
    }

    feedVC.startFetch()
  }
}
