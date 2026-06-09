import KDS
import Kickstarter_Framework
import Library
import UIKit

/// Owns the app's window and handles the UIScene-based lifecycle.
///
/// App-level concerns (SDK setup, push-token registration, notification handling) remain on the
/// `AppDelegate`, which also owns the shared lifecycle `viewModel`. This scene delegate forwards
/// scene lifecycle, URL, user-activity and shortcut events into that view model.
internal final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  internal var window: UIWindow?

  private var viewModel: SceneDelegateViewModelType? {
    (UIApplication.shared.delegate as? AppDelegate)?.viewModel
  }

  internal func scene(
    _: UIScene,
    willConnectTo _: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    // The window and its root `RootTabBarViewController` are created automatically from
    // `Main.storyboard` (declared via `UISceneStoryboardFile` in Info.plist); we only finish
    // configuring the window here.
    self.window?.tintColor = LegacyColors.ksr_create_700.uiColor()

    // Handle anything the app was launched with (deep link, Handoff, or a quick action).
    self.handle(urlContexts: connectionOptions.urlContexts)

    connectionOptions.userActivities.forEach { userActivity in
      _ = self.viewModel?.inputs.applicationContinueUserActivity(userActivity)
    }

    if let shortcutItem = connectionOptions.shortcutItem {
      self.viewModel?.inputs.applicationPerformActionForShortcutItem(shortcutItem)
    }
  }

  internal func sceneDidBecomeActive(_: UIScene) {
    self.viewModel?.inputs.applicationActive(state: true)
  }

  internal func sceneWillResignActive(_: UIScene) {
    self.viewModel?.inputs.applicationActive(state: false)
  }

  internal func sceneWillEnterForeground(_: UIScene) {
    self.viewModel?.inputs.applicationWillEnterForeground()
  }

  internal func sceneDidEnterBackground(_: UIScene) {
    self.viewModel?.inputs.applicationDidEnterBackground()
  }

  internal func scene(_: UIScene, continue userActivity: NSUserActivity) {
    _ = self.viewModel?.inputs.applicationContinueUserActivity(userActivity)
  }

  internal func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    self.handle(urlContexts: URLContexts)
  }

  internal func windowScene(
    _: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    self.viewModel?.inputs.applicationPerformActionForShortcutItem(shortcutItem)
    completionHandler(true)
  }

  // MARK: - Functions

  private func handle(urlContexts: Set<UIOpenURLContext>) {
    for context in urlContexts {
      let options = openURLOptions(from: context.options)

      // If this is a Facebook login callback, let the Facebook SDK handle it; otherwise forward
      // the potential deep-link to the view model. Mirrors the previous `AppDelegate` logic.
      guard !AppEnvironment.current.facebookSDK.handleOpenURL(
        UIApplication.shared,
        open: context.url,
        options: options
      ) else {
        continue
      }

      _ = self.viewModel?.inputs.applicationOpenUrl(
        application: UIApplication.shared,
        url: context.url,
        options: options
      )
    }
  }
}

private func openURLOptions(
  from sceneOptions: UIScene.OpenURLOptions
) -> [UIApplication.OpenURLOptionsKey: Any] {
  var options: [UIApplication.OpenURLOptionsKey: Any] = [.openInPlace: sceneOptions.openInPlace]

  if let sourceApplication = sceneOptions.sourceApplication {
    options[.sourceApplication] = sourceApplication
  }

  if let annotation = sceneOptions.annotation {
    options[.annotation] = annotation
  }

  return options
}
