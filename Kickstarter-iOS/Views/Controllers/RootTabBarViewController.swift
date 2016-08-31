import AlamofireImage
import KsApi
import Library
import Prelude
import UIKit

public final class RootTabBarViewController: UITabBarController {
  private let viewModel: RootViewModelType = RootViewModel()

  override public func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self

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

    self.viewModel.inputs.viewDidLoad()
  }

  override public func bindStyles() {
    super.bindStyles()

    self.tabBar
      |> UITabBar.lens.tintColor .~ tabBarSelectedColor
      |> UITabBar.lens.barTintColor .~ tabBarTintColor
  }

  override public func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.setViewControllers
      .observeForControllerAction()
      .observeNext { [weak self] in self?.setViewControllers($0, animated: false) }

    self.viewModel.outputs.selectedIndex
      .observeForControllerAction()
      .observeNext { [weak self] in self?.selectedIndex = $0 }

    self.viewModel.outputs.scrollToTop
      .observeForControllerAction()
      .observeNext(scrollToTop)

    self.viewModel.outputs.tabBarItemsData
      .observeForControllerAction()
      .observeNext { [weak self] in self?.setTabBarItemStyles(withData: $0) }

    self.viewModel.outputs.profileTabBarItemData
      .observeForControllerAction()
      .observeNext { [weak self] in self?.setProfileImage(withData: $0) }

    self.viewModel.outputs.filterDiscovery
      .observeForControllerAction()
      .observeNext { $0.filter(with: $1) }

    self.viewModel.outputs.switchDashboardProject
      .observeForControllerAction()
      .observeNext { $0.`switch`(toProject: $1) }
  }

  public func switchToActivities() {
    self.viewModel.inputs.switchToActivities()
  }

  public func switchToDashboard(project param: Param?) {
    self.viewModel.inputs.switchToDashboard(project: param)
  }

  public func switchToDiscovery(params params: DiscoveryParams?) {
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

  // swiftlint:disable cyclomatic_complexity
  private func setTabBarItemStyles(withData data: TabBarItemsData) {
    data.items.forEach { item in
      switch item {
      case let .home(index):
        tabBarItem(atIndex: index) ?|> homeTabBarItemStyle(isMember: data.isMember)
      case let .activity(index):
        tabBarItem(atIndex: index) ?|> activityTabBarItemStyle(isMember: data.isMember)
      case let .search(index):
        tabBarItem(atIndex: index) ?|> searchTabBarItemStyle
      case let .dashboard(index):
        tabBarItem(atIndex: index) ?|> dashboardTabBarItemStyle
      case let .profile(index):
        tabBarItem(atIndex: index) ?|> profileTabBarItemStyle(isLoggedIn: data.isLoggedIn,
          isMember: data.isMember)
      }
    }
  }
  // swiftlint:enable cyclomatic_complexity

  private func setProfileImage(withData data: ProfileTabBarItemData) {
    guard let avatarUrl = data.avatarUrl else { return }

    let dir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first
    let style = profileTabBarItemStyle(isLoggedIn: true, isMember: data.isMember)

    if let dir = dir {
      let imagePath = dir + ("/tabbar-avatar-image-\(avatarUrl.absoluteString.hashValue).dat")

      if let imageData = NSData(contentsOfFile: imagePath) {
        let (defaultImage, selectedImage) = tabbarAvatarImageFromData(imageData)
        if case let .profile(index) = data.item {
          self.tabBarItem(atIndex: index)
            ?|> style
            ?|> UITabBarItem.lens.image .~ defaultImage
            ?|> UITabBarItem.lens.selectedImage .~ selectedImage
        }
      } else {
        if let url = data.avatarUrl {
          let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
          let session = NSURLSession(configuration: sessionConfig,
                                     delegate: nil,
                                     delegateQueue: NSOperationQueue.mainQueue())
          let dataTask = session.dataTaskWithURL(url) { [weak self] (avatarData, response, error) in
            if let avatarData = avatarData {
              avatarData.writeToFile(imagePath, atomically: true)

              let (defaultImage, selectedImage) = tabbarAvatarImageFromData(avatarData)
              if case let .profile(index) = data.item {
                self?.tabBarItem(atIndex: index)
                  ?|> style
                  ?|> UITabBarItem.lens.image .~ defaultImage
                  ?|> UITabBarItem.lens.selectedImage .~ selectedImage
              }
            }
          }
          dataTask.resume()
        }
      }
    }
  }

  private func tabBarItem(atIndex index: Int) -> UITabBarItem? {
    if self.tabBar.items?.count > index {
      if let item = self.tabBar.items?[index] {
        return item
      }
    }
    return nil
  }
}

extension RootTabBarViewController: UITabBarControllerDelegate {
  public func tabBarController(tabBarController: UITabBarController,
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

private func tabbarAvatarImageFromData(data: NSData) -> (defaultImage: UIImage?, selectedImage: UIImage?) {
  let avatar = UIImage(data: data, scale: UIScreen.mainScreen().scale)?
    .af_imageRoundedIntoCircle()
    .af_imageAspectScaledToFitSize(tabBarAvatarSize)
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
  image?.drawInRect(innerRect)
  let circle = UIBezierPath(ovalInRect: innerRect)
  color.setStroke()
  circle.lineWidth = lineWidth
  circle.stroke()

  return UIGraphicsGetImageFromCurrentImageContext().imageWithRenderingMode(.AlwaysOriginal)
}
