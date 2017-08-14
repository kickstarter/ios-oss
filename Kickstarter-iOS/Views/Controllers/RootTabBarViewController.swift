import AlamofireImage
import KsApi
import Library
import Prelude
import UIKit

public final class RootTabBarViewController: UITabBarController {
  fileprivate let viewModel: RootViewModelType = RootViewModel()

  override public func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_userUpdated, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.currentUserUpdated()
    }

    self.viewModel.inputs.viewDidLoad()
  }

  override public func bindStyles() {
    super.bindStyles()

    _ = self.tabBar
      |> UITabBar.lens.tintColor .~ tabBarSelectedColor
      |> UITabBar.lens.barTintColor .~ tabBarTintColor
  }

  override public func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.setViewControllers
      .observeForUI()
      .observeValues { [weak self] in self?.setViewControllers($0, animated: false) }

    self.viewModel.outputs.selectedIndex
      .observeForUI()
      .observeValues { [weak self] in self?.selectedIndex = $0 }

    self.viewModel.outputs.scrollToTop
      .observeForUI()
      .observeValues(scrollToTop)

    self.viewModel.outputs.tabBarItemsData
      .observeForUI()
      .observeValues { [weak self] in self?.setTabBarItemStyles(withData: $0) }

    self.viewModel.outputs.filterDiscovery
      .observeForUI()
      .observeValues { $0.filter(with: $1) }

    self.viewModel.outputs.switchDashboardProject
      .observeForControllerAction()
      .observeValues { $0.`switch`(toProject: $1) }
  }

  public func switchToActivities() {
    self.viewModel.inputs.switchToActivities()
  }

  public func switchToDashboard(project param: Param?) {
    self.viewModel.inputs.switchToDashboard(project: param)
  }

  public func switchToDiscovery(params: DiscoveryParams?) {
    self.viewModel.inputs.switchToDiscovery(params: params)
  }

  public func switchToLogin() {
    self.viewModel.inputs.switchToLogin()
  }

  public func switchToProfile() {
    self.viewModel.inputs.switchToProfile()
  }

  public func switchToSearch() {
    self.viewModel.inputs.switchToSearch()
  }

  public func switchToMessageThread(_ messageThread: MessageThread) {
    self.switchToProfile()

    guard let profileNav = self.selectedViewController as? UINavigationController,
      let profileVC = profileNav.viewControllers.first
      else { return }

    let threadsVC = MessageThreadsViewController.configuredWith(project: nil)
    let messageThreadVC = MessagesViewController.configuredWith(messageThread: messageThread)

    self.presentedViewController?.dismiss(animated: false, completion: nil)

    profileNav.setViewControllers([profileVC, threadsVC, messageThreadVC], animated: true)
  }

  public func switchToCreatorMessageThread(projectId: Param, messageThread: MessageThread) {
    self.switchToDashboard(project: nil)

    guard let dashboardNav = self.selectedViewController as? UINavigationController,
          let dashboardVC = dashboardNav.viewControllers.first as? DashboardViewController
      else { return }

    self.presentedViewController?.dismiss(animated: false, completion: nil)

     dashboardVC.navigateToProjectMessageThread(projectId: projectId, messageThread: messageThread)
  }

  public func swithchToProjectActivities(projectId: Param) {
    self.switchToDashboard(project: nil)

    guard let dashboardNav = self.selectedViewController as? UINavigationController,
    let dashboardVC = dashboardNav.viewControllers.first as? DashboardViewController
    else { return }

    self.presentedViewController?.dismiss(animated: false, completion: nil)

    dashboardVC.navigateToProjectActivities(projectId: projectId)
  }

  // swiftlint:disable:next cyclomatic_complexity
  // swiftlint:disable:next function_body_length
  fileprivate func setTabBarItemStyles(withData data: TabBarItemsData) {
    data.items.forEach { item in
      switch item {
      case let .home(index):
        _ = tabBarItem(atIndex: index) ?|> homeTabBarItemStyle(isMember: data.isMember)
      case let .activity(index):
        _ = tabBarItem(atIndex: index) ?|> activityTabBarItemStyle(isMember: data.isMember)
      case let .search(index):
        _ = tabBarItem(atIndex: index) ?|> searchTabBarItemStyle
      case let .dashboard(index):
        _ = tabBarItem(atIndex: index) ?|> dashboardTabBarItemStyle
      case let .profile(avatarUrl, index):
        _ = tabBarItem(atIndex: index)
          ?|> profileTabBarItemStyle(isLoggedIn: data.isLoggedIn, isMember: data.isMember)

        guard
          data.isLoggedIn == true,
          let avatarUrl = avatarUrl,
          let dir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
          else { return }

        let hash = avatarUrl.absoluteString.hashValue
        let imagePath = "\(dir)/tabbar-avatar-image-\(hash).dat"
        let imageUrl = URL(fileURLWithPath: imagePath)

        if let imageData = try? Data(contentsOf: imageUrl) {

          let (defaultImage, selectedImage) = tabbarAvatarImageFromData(imageData)
          _ = self.tabBarItem(atIndex: index)
            ?|> profileTabBarItemStyle(isLoggedIn: true, isMember: data.isMember)
            ?|> UITabBarItem.lens.image .~ defaultImage
            ?|> UITabBarItem.lens.selectedImage .~ selectedImage
        } else {
          let sessionConfig = URLSessionConfiguration.default
          let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
          let dataTask = session.dataTask(with: avatarUrl) { [weak self] avatarData, _, _ in
            guard let avatarData = avatarData else { return }
            try? avatarData.write(to: imageUrl, options: [.atomic])

            let (defaultImage, selectedImage) = tabbarAvatarImageFromData(avatarData)
            _ = self?.tabBarItem(atIndex: index)
              ?|> profileTabBarItemStyle(isLoggedIn: true, isMember: data.isMember)
              ?|> UITabBarItem.lens.image .~ defaultImage
              ?|> UITabBarItem.lens.selectedImage .~ selectedImage
          }
          dataTask.resume()
        }
      }
    }
  }

  fileprivate func tabBarItem(atIndex index: Int) -> UITabBarItem? {
    if (self.tabBar.items?.count ?? 0) > index {
      if let item = self.tabBar.items?[index] {
        return item
      }
    }
    return nil
  }
}

extension RootTabBarViewController: UITabBarControllerDelegate {
  public func tabBarController(_ tabBarController: UITabBarController,
                               didSelect viewController: UIViewController) {
    self.viewModel.inputs.didSelectIndex(tabBarController.selectedIndex)
  }
}

private func scrollToTop(_ viewController: UIViewController) {

  if let scrollView = (viewController.view as? UIScrollView) ??
    ((viewController as? UINavigationController)?.viewControllers.first?.view as? UIScrollView) {

    scrollView.scrollToTop()
  }
}

private func tabbarAvatarImageFromData(_ data: Data) -> (defaultImage: UIImage?, selectedImage: UIImage?) {
  let avatar = UIImage(data: data, scale: UIScreen.main.scale)?
    .af_imageRoundedIntoCircle()
    .af_imageAspectScaled(toFit: tabBarAvatarSize)
  avatar?.af_inflate()

  let deselectedImage = strokedRoundImage(fromImage: avatar,
                                          size: tabBarAvatarSize,
                                          color: tabBarDeselectedColor)
  let selectedImage = strokedRoundImage(fromImage: avatar,
                                        size: tabBarAvatarSize,
                                        color: tabBarSelectedColor,
                                        lineWidth: 2.0)

  return (defaultImage: deselectedImage, selectedImage: selectedImage)
}

private func strokedRoundImage(fromImage image: UIImage?,
                               size: CGSize,
                               color: UIColor,
                               lineWidth: CGFloat = 1.0) -> UIImage? {

  UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
  defer { UIGraphicsEndImageContext() }

  let innerRect = CGRect(x: 1.0, y: 1.0, width: size.width - 2.0, height: size.height - 2.0)
  image?.draw(in: innerRect)
  let circle = UIBezierPath(ovalIn: innerRect)
  color.setStroke()
  circle.lineWidth = lineWidth
  circle.stroke()

  return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
}
