import UIKit
import Library
import Prelude

internal final class RootTabBarViewController: UITabBarController {
  private let viewModel: RootViewModelType = RootViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self

    self.viewModel.inputs.viewDidLoad()

    NSNotificationCenter
      .defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    NSNotificationCenter
      .defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }

    NSNotificationCenter
      .defaultCenter()
      .addObserverForName(CurrentUserNotifications.userUpdated, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.currentUserUpdated()
    }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.setViewControllers
      .observeForUI()
      .observeNext { [weak self] vcs in
        self?.setViewControllers(vcs, animated: false)
    }

    self.viewModel.outputs.selectedIndex
      .observeForUI()
      .observeNext { [weak self] index in
        self?.selectedIndex = index
    }

    self.viewModel.outputs.scrollToTop
      .observeForUI()
      .observeNext(scrollToTop)
  }
}

extension RootTabBarViewController: UITabBarControllerDelegate {

  func tabBarController(tabBarController: UITabBarController,
                        didSelectViewController viewController: UIViewController) {
    self.viewModel.inputs.didSelectIndex(tabBarController.selectedIndex)
  }
}

private func scrollToTop(viewController: UIViewController) {

  // Try finding a scroll view inside `viewController`.
  guard let scrollView = (viewController.view as? UIScrollView) ??
    ((viewController as? UINavigationController)?.viewControllers.first?.view as? UIScrollView) else {
      return
  }

  scrollView.setContentOffset(CGPoint(x: 0.0, y: -scrollView.contentInset.top), animated: true)
}
