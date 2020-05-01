import AlamofireImage
import KsApi
import Library
import Prelude
import UIKit

internal protocol TabBarControllerScrollable {
  func scrollToTop()
}

extension TabBarControllerScrollable where Self: UIViewController {
  func scrollToTop() {
    if let scrollView = self.view as? UIScrollView {
      scrollView.scrollToTop()
    }
  }
}

public final class RootTabBarViewController: UITabBarController {
  private var applicationWillEnterForegroundObserver: Any?
  private var sessionEndedObserver: Any?
  private var sessionStartedObserver: Any?
  private var userUpdatedObserver: Any?
  private var userLocalePreferencesChangedObserver: Any?
  private var voiceOverStatusDidChangeObserver: Any?

  fileprivate let viewModel: RootViewModelType = RootViewModel()

  public override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self

    self.applicationWillEnterForegroundObserver = NotificationCenter
      .default
      .addObserver(
        forName: UIApplication.willEnterForegroundNotification,
        object: nil, queue: nil
      ) { [weak self] _ in
        self?.viewModel.inputs.applicationWillEnterForeground()
      }

    self.sessionStartedObserver = NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
      }

    self.sessionEndedObserver = NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
      }

    self.userUpdatedObserver = NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_userUpdated, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.currentUserUpdated()
      }

    self.voiceOverStatusDidChangeObserver = NotificationCenter
      .default
      .addObserver(
        forName: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil, queue: nil
      ) { [weak self] _ in
        self?.viewModel.inputs.voiceOverStatusDidChange()
      }

    self.viewModel.outputs.updateUserInEnvironment
      .observeValues { user in
        AppEnvironment.updateCurrentUser(user)
        NotificationCenter.default.post(.init(name: .ksr_userUpdated))
      }

    self.userLocalePreferencesChangedObserver = NotificationCenter
      .default
      .addObserver(
        forName: Notification.Name.ksr_userLocalePreferencesChanged,
        object: nil,
        queue: nil,
        using: { [weak self] _ in
          self?.viewModel.inputs.userLocalePreferencesChanged()
        }
      )

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    [
      self.applicationWillEnterForegroundObserver,
      self.sessionStartedObserver,
      self.sessionEndedObserver,
      self.userUpdatedObserver,
      self.userLocalePreferencesChangedObserver,
      self.voiceOverStatusDidChangeObserver
    ]
    .compact()
    .forEach(NotificationCenter.default.removeObserver)
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self.tabBar
      |> UITabBar.lens.tintColor .~ tabBarSelectedColor
      |> UITabBar.lens.barTintColor .~ tabBarTintColor
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.setViewControllers
      .observeForUI()
      .map { $0.map { RootTabBarViewController.viewController(from: $0) }.compact() }
      .map { $0.map(UINavigationController.init(rootViewController:)) }
      .observeValues { [weak self] in
        self?.setViewControllers($0, animated: false)
      }

    self.viewModel.outputs.selectedIndex
      .observeForUI()
      .observeValues { [weak self] in self?.selectedIndex = $0 }

    self.viewModel.outputs.scrollToTop
      .observeForControllerAction()
      .map { [weak self] index -> UIViewController? in
        guard let vcs = self?.viewControllers else { return nil }

        return vcs[clamp(0, vcs.count - 1)(index)]
      }
      .skipNil()
      .map(extractViewController)
      .observeValues(scrollToTop)

    self.viewModel.outputs.tabBarItemsData
      .observeForUI()
      .observeValues { [weak self] in self?.setTabBarItemStyles(withData: $0) }

    self.viewModel.outputs.filterDiscovery
      .observeForControllerAction()
      .map { [weak self] index, param -> (DiscoveryViewController, DiscoveryParams)? in
        self?.viewControllerAndParam(with: index, param: param)
      }
      .skipNil()
      .observeValues { $0.filter(with: $1) }

    self.viewModel.outputs.switchDashboardProject
      .observeForControllerAction()
      .map { [weak self] index, param -> (DashboardViewController, Param)? in
        self?.viewControllerAndParam(with: index, param: param)
      }
      .skipNil()
      .observeValues { $0.switch(toProject: $1) }

    self.viewModel.outputs.setBadgeValueAtIndex
      .observeForUI()
      .observeValues { [weak self] value, index in
        self?.tabBarItem(atIndex: index)?.badgeValue = value
      }
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

  private func viewControllerAndParam<T, P>(with index: RootViewControllerIndex, param: P) -> (T, P)? {
    guard
      let vcs = self.viewControllers,
      let nav = vcs[clamp(0, vcs.count - 1)(index)] as? UINavigationController,
      let vc = nav.children.first as? T
    else { return nil }

    return (vc, param)
  }

  public func switchToMessageThread(_ messageThread: MessageThread) {
    self.switchToProfile()

    guard
      let profileNav = self.selectedViewController as? UINavigationController,
      let profileVC = profileNav.viewControllers.first
    else { return }

    let threadsVC = MessageThreadsViewController.configuredWith(project: nil, refTag: nil)
    let messageThreadVC = MessagesViewController.configuredWith(messageThread: messageThread)

    self.presentedViewController?.dismiss(animated: false, completion: nil)

    profileNav.setViewControllers([profileVC, threadsVC, messageThreadVC], animated: true)
  }

  public func switchToCreatorMessageThread(projectId: Param, messageThread: MessageThread) {
    self.switchToDashboard(project: nil)

    guard
      let dashboardNav = self.selectedViewController as? UINavigationController,
      let dashboardVC = dashboardNav.viewControllers.first as? DashboardViewController
    else { return }

    self.presentedViewController?.dismiss(animated: false, completion: nil)

    dashboardVC.navigateToProjectMessageThread(projectId: projectId, messageThread: messageThread)
  }

  public func switchToProjectActivities(projectId: Param) {
    self.switchToDashboard(project: nil)

    guard
      let dashboardNav = self.selectedViewController as? UINavigationController,
      let dashboardVC = dashboardNav.viewControllers.first as? DashboardViewController
    else { return }

    self.presentedViewController?.dismiss(animated: false, completion: nil)

    dashboardVC.navigateToProjectActivities(projectId: projectId)
  }

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

  static func viewController(from data: RootViewControllerData) -> UIViewController? {
    switch data {
    case .discovery:
      return DiscoveryViewController.instantiate()
    case .activities:
      return ActivitiesViewController.instantiate()
    case .search:
      return SearchViewController.instantiate()
    case let .dashboard(isMember):
      return isMember ? DashboardViewController.instantiate() : nil
    case let .profile(isLoggedIn):
      return isLoggedIn
        ? BackerDashboardViewController.instantiate()
        : LoginToutViewController.configuredWith(loginIntent: .loginTab)
    }
  }

  // MARK: - Accessors

  public func didReceiveBadgeValue(_ value: Int?) {
    self.viewModel.inputs.didReceiveBadgeValue(value)
  }
}

extension RootTabBarViewController: UITabBarControllerDelegate {
  public func tabBarController(
    _ tabBarController: UITabBarController,
    shouldSelect viewController: UIViewController
  ) -> Bool {
    let index = tabBarController.viewControllers?.firstIndex(of: viewController)
    self.viewModel.inputs.shouldSelect(index: index)
    return true
  }

  public func tabBarController(
    _ tabBarController: UITabBarController,
    didSelect _: UIViewController
  ) {
    self.viewModel.inputs.didSelect(index: tabBarController.selectedIndex)
  }

  public func tabBarController(
    _: UITabBarController,
    animationControllerForTransitionFrom _: UIViewController,
    to _: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    return CrossDissolveTransitionAnimator()
  }
}

private func scrollToTop(_ viewController: UIViewController) {
  if let scrollable = viewController as? TabBarControllerScrollable {
    scrollable.scrollToTop()
  }
}

private func tabbarAvatarImageFromData(_ data: Data) -> (defaultImage: UIImage?, selectedImage: UIImage?) {
  let avatar = UIImage(data: data, scale: UIScreen.main.scale)?
    .af.imageRoundedIntoCircle()
    .af.imageAspectScaled(toFit: tabBarAvatarSize)
  avatar?.af.inflate()

  let deselectedImage = strokedRoundImage(
    fromImage: avatar,
    size: tabBarAvatarSize,
    color: tabBarDeselectedColor
  )
  let selectedImage = strokedRoundImage(
    fromImage: avatar,
    size: tabBarAvatarSize,
    color: tabBarSelectedColor,
    lineWidth: 2.0
  )

  return (defaultImage: deselectedImage, selectedImage: selectedImage)
}

private func strokedRoundImage(
  fromImage image: UIImage?,
  size: CGSize,
  color: UIColor,
  lineWidth: CGFloat = 2.0
) -> UIImage? {
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

private func extractViewController(_ viewController: UIViewController) -> UIViewController {
  guard
    let navigationController = viewController as? UINavigationController,
    navigationController.viewControllers.count == 1,
    let nestedViewController = navigationController.viewControllers.first else {
    return viewController
  }

  return nestedViewController
}
