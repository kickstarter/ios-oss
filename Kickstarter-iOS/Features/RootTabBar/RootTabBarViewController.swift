import AlamofireImage
import KDS
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

// MARK: - Floating Tab Bar Stuff

public var isFloatingTabBarEnabled: Bool = true

public final class RootTabBarViewController: UITabBarController, MessageBannerViewControllerPresenting {
  private var applicationWillEnterForegroundObserver: Any?
  public var messageBannerViewController: MessageBannerViewController?
  private var sessionEndedObserver: Any?
  private var sessionStartedObserver: Any?
  private var userUpdatedObserver: Any?
  private var userLocalePreferencesChangedObserver: Any?
  private var voiceOverStatusDidChangeObserver: Any?

  fileprivate let viewModel: RootViewModelType = RootViewModel()

  // MARK: - Floating Tab Bar Stuff

  /// SwiftUI hosting controller that renders the new floating tab bar instead of the legacy tab bar.
  private var floatingTabBarController: FloatingTabBarHostingController?
  /// Cached profile tab images so the floating tab bar can reuse the same profile image
  /// that we already generate for the existing UITabBar.
  private var profileDefaultImage: UIImage?
  private var profileSelectedImage: UIImage?

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
      .observeValues { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        NotificationCenter.default.post(.init(name: .ksr_userUpdated))

        guard let self = self, isFloatingTabBarEnabled else { return }

        /// When the user object changes (login/logout), reset cached floating tab bar profile tab.
        self.profileDefaultImage = nil
        self.profileSelectedImage = nil

        /// Keep the floating tab bar state in sync with the current user and tab selection.
        self.updateFloatingTabBar()
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

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    /// When the floating tab bar is enabled, build it once and hide the legacy UITabBar
    if isFloatingTabBarEnabled {
      self.setupFloatingTabBar()
      self.tabBar.isHidden = true
    }

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }

  // MARK: - Floating Tab Bar Stuff

  /// Adds the floating tab bar and pins it to the bottom safe area.
  private func setupFloatingTabBar() {
    let tabBar = FloatingTabBarHostingController(
      selected: FloatingTabBarTab(rawValue: self.selectedIndex) ?? .discovery,
      onSelect: { [weak self] tab in
        self?.switchToTab(tab)
      },
      profileDefaultImage: self.profileDefaultImage,
      profileSelectedImage: self.profileSelectedImage
    )

    self.addChild(tabBar)
    self.view.addSubview(tabBar.view)
    tabBar.didMove(toParent: self)

    tabBar.view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      tabBar.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      tabBar.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
    ])

    self.floatingTabBarController = tabBar
  }

  /// Rebuilds the SwiftUI floating tab bar with the current selected tab + cached profile images
  /// so it stays visually aligned with UITabBar’s  state.
  private func updateFloatingTabBar() {
    guard let tabBarController = self.floatingTabBarController else { return }

    let selectedTab = FloatingTabBarTab(rawValue: self.selectedIndex) ?? .discovery
    tabBarController.update(
      selected: selectedTab,
      profileDefaultImage: self.profileDefaultImage,
      profileSelectedImage: self.profileSelectedImage
    )
  }

  /// Bridgesthe new floating tab bar taps into the existing tab-selection flow so that our new
  /// UI can be a  wrapper over the same tab bar  behavior.
  private func switchToTab(_ tab: FloatingTabBarTab) {
    switch tab {
    case .discovery:
      self.selectedIndex = FloatingTabBarTab.discovery.rawValue

    case .search:
      self.selectedIndex = FloatingTabBarTab.search.rawValue

    case .profile:
      self.selectedIndex = FloatingTabBarTab.profile.rawValue
    }

    if isFloatingTabBarEnabled {
      self.updateFloatingTabBar()
    }
  }

  private func styleTabBarTransparent() {
    let appearance = UITabBarAppearance()
    appearance.configureWithTransparentBackground()

    tabBar.standardAppearance = appearance
    tabBar.scrollEdgeAppearance = appearance
    tabBar.backgroundImage = UIImage()
    tabBar.shadowImage = UIImage()
    tabBar.isTranslucent = true
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

    /// When the floating tab bar is enabled we bypass legacy UITabBar styling
    guard isFloatingTabBarEnabled == false else { return }

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
      .observeValues { [weak self] controllers in
        guard let self = self else { return }

        self.setViewControllers(controllers, animated: false)

        /// After controllers are set, make sure the floating tab bar points at the correct
        /// initial tab so we don’t show an “unselected” state on first load.
        if isFloatingTabBarEnabled {
          self.selectedIndex = FloatingTabBarTab.discovery.rawValue
          self.updateFloatingTabBar()
        }
      }

    self.viewModel.outputs.selectedIndex
      .observeForUI()
      .observeValues { [weak self] index in
        guard let self = self else { return }

        self.selectedIndex = index

        /// Anytime the VM changes the selected tab, sync that change down
        /// into the SwiftUI floating tab bar so the highlight matches.
        if isFloatingTabBarEnabled {
          self.profileDefaultImage = nil
          self.profileSelectedImage = nil

          self.updateFloatingTabBar()
        }
      }

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

    self.viewModel.outputs.setBadgeValueAtIndex
      .observeForUI()
      .observeValues { [weak self] value, index in
        self?.tabBarItem(atIndex: index)?.badgeValue = value
      }
  }

  public func switchToActivities() {
    self.viewModel.inputs.switchToActivities()
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

  fileprivate func setTabBarItemStyles(withData data: TabBarItemsData) {
    data.items.forEach { item in
      switch item {
      case let .home(index):
        _ = self.tabBarItem(atIndex: index) ?|> homeTabBarItemStyle

      case let .activity(index):
        _ = self.tabBarItem(atIndex: index) ?|> activityTabBarItemStyle

      case let .search(index):
        _ = self.tabBarItem(atIndex: index) ?|> searchTabBarItemStyle

      case let .profile(avatarUrl, index):
        _ = self.tabBarItem(atIndex: index)
          ?|> profileTabBarItemStyle(isLoggedIn: data.isLoggedIn)

        if data.isLoggedIn == true, let avatarUrl = avatarUrl {
          /// Logged in: existing behavior for the legacy tab bar.
          self.setProfileImage(with: data, avatarUrl: avatarUrl, index: index)
        } else if isFloatingTabBarEnabled {
          /// When logged out and floating tab bar is enabled, explicitly clear the cached profile image
          /// so the floating tab bar falls back to the generic tab icon.
          self.profileDefaultImage = nil
          self.profileSelectedImage = nil

          if let tabBar = self.floatingTabBarController {
            let selectedTab = FloatingTabBarTab(rawValue: self.selectedIndex) ?? .discovery
            tabBar.update(
              selected: selectedTab,
              profileDefaultImage: nil,
              profileSelectedImage: nil
            )
          }
        }
      }
    }
  }

  fileprivate func setProfileImage(with data: TabBarItemsData, avatarUrl: URL?, index: Int) {
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
        ?|> profileTabBarItemStyle(isLoggedIn: true)
        ?|> UITabBarItem.lens.image .~ defaultImage
        ?|> UITabBarItem.lens.selectedImage .~ selectedImage

      if isFloatingTabBarEnabled {
        /// When profile image  is ready, mirror the same default/selected images into
        /// the floating tab bar so both tab UIs stay visually consistent.
        self.profileDefaultImage = defaultImage
        self.profileSelectedImage = selectedImage
        self.floatingTabBarController?.update(
          selected: FloatingTabBarTab(rawValue: self.selectedIndex) ?? .discovery,
          profileDefaultImage: defaultImage,
          profileSelectedImage: selectedImage
        )
      }
    } else {
      let sessionConfig = URLSessionConfiguration.default
      let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
      let dataTask = session.dataTask(with: avatarUrl) { [weak self] avatarData, _, _ in
        guard let avatarData = avatarData else { return }
        try? avatarData.write(to: imageUrl, options: [.atomic])

        let (defaultImage, selectedImage) = tabbarAvatarImageFromData(avatarData)
        _ = self?.tabBarItem(atIndex: index)
          ?|> profileTabBarItemStyle(isLoggedIn: true)
          ?|> UITabBarItem.lens.image .~ defaultImage
          ?|> UITabBarItem.lens.selectedImage .~ selectedImage

        if isFloatingTabBarEnabled {
          /// Same as above, but for the async-load path: once we have the profile image,
          /// push it into the floating tab bar view as well.
          self?.profileDefaultImage = defaultImage
          self?.profileSelectedImage = selectedImage
          self?.floatingTabBarController?.update(
            selected: FloatingTabBarTab(
              rawValue: self?.selectedIndex ?? FloatingTabBarTab.discovery
                .rawValue
            ) ?? .discovery,
            profileDefaultImage: defaultImage,
            profileSelectedImage: selectedImage
          )
        }
      }
      dataTask.resume()
    }
  }

  fileprivate func isTabBarItemLastItem(for index: Int) -> Bool {
    guard let tabBarItemEndIndex = self.tabBar.items?.endIndex else {
      return false
    }

    return tabBarItemEndIndex - 1 == index
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
    case .pledgedProjectsAndActivities:
      return PPOContainerViewController.instantiate()
    case .search:
      return SearchViewController.instantiate()
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

    /// Keep floating tab bar selection in sync when the user taps the legacy tab bar,
    /// in case the feature flag is toggled while both UIs are visible during dev.
    if isFloatingTabBarEnabled {
      self.updateFloatingTabBar()
    }
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

  /// When the floating tab bar is enabled, we reuse different border colors for the avatar
  /// to better match the new nav design, but otherwise we keep the legacy colors.
  let deselectedImageBorderColor: UIColor = isFloatingTabBarEnabled ?
    UIColor(Colors.Nav.profileIconImageBorderColorDefault.swiftUIColor()) : tabBarDeselectedColor
  let selectedImageBorderColor: UIColor = isFloatingTabBarEnabled ?
    UIColor(Colors.Nav.profileIconImageBorderColorSelected.swiftUIColor()) : tabBarSelectedColor

  let deselectedImage = strokedRoundImage(
    fromImage: avatar,
    size: tabBarAvatarSize,
    color: deselectedImageBorderColor
  )
  let selectedImage = strokedRoundImage(
    fromImage: avatar,
    size: tabBarAvatarSize,
    color: selectedImageBorderColor,
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

  if isFloatingTabBarEnabled {
    return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysTemplate)
  } else {
    return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
  }
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
