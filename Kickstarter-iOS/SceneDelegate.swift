import Foundation
import KDS
import Kickstarter_Framework
import KsApi
import Library
import ReactiveExtensions
import ReactiveSwift
import SwiftUI
import UIKit

internal final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  private let viewModel: SceneDelegateViewModelType = SceneDelegateViewModel()

  private var rootTabBarController: RootTabBarViewController? {
    self.window?.rootViewController as? RootTabBarViewController
  }

  /// UIKit stops calling the `UIApplicationDelegate` foreground / background / active callbacks once
  /// an app adopts scenes, but the behavior they drive is app-scoped and still belongs to
  /// `AppDelegate`, so this scene delegate calls back through to it.
  /// Safe while `UIApplicationSupportsMultipleScenes` is false and there is only ever one scene.
  private var appDelegate: AppDelegate? {
    UIApplication.shared.delegate as? AppDelegate
  }

  func scene(
    _ scene: UIScene,
    willConnectTo _: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard scene is UIWindowScene else { return }

    self.window?.tintColor = LegacyColors.ksr_create_700.uiColor()

    self.viewModel.outputs.presentViewController
      .observeForUI()
      .observeValues { [weak self] in
        self?.rootTabBarController?.dismiss(animated: true, completion: nil)
        self?.rootTabBarController?.present($0, animated: true, completion: nil)
      }

    self.viewModel.outputs.goToDiscovery
      .observeForUI()
      .observeValues { [weak self] in self?.rootTabBarController?.switchToDiscovery(params: $0) }

    self.viewModel.outputs.goToActivity
      .observeForUI()
      .observeValues { [weak self] in self?.rootTabBarController?.switchToActivities() }

    self.viewModel.outputs.goToLoginWithIntent
      .observeForControllerAction()
      .observeValues { [weak self] intent in
        /// Dismiss OnboardingView if present so that we can correctly present the LoginToutViewController.
        if let onboardingView = self?.rootTabBarController?
          .presentedViewController as? UIHostingController<OnboardingView> {
          onboardingView.dismiss(animated: true)
          AppEnvironment.current.userDefaults.set(true, forKey: AppKeys.hasSeenOnboarding.rawValue)
        }

        let vc = LoginToutViewController.configuredWith(loginIntent: intent)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet

        self?.rootTabBarController?.present(nav, animated: true, completion: nil)
      }

    self.viewModel.outputs.goToMessageThread
      .observeForUI()
      .observeValues { [weak self] in self?.rootTabBarController?.switchToMessageThread($0) }

    self.viewModel.outputs.goToSearch
      .observeForUI()
      .observeValues { [weak self] in self?.rootTabBarController?.switchToSearch() }

    self.viewModel.outputs.goToMobileSafari
      .observeForUI()
      .observeValues { UIApplication.shared.open($0) }

    self.viewModel.outputs.emailVerificationCompleted
      .observeForUI()
      .observeValues { [weak self] message, success in
        self?.rootTabBarController?.dismiss(animated: false, completion: nil)
        self?.rootTabBarController?
          .messageBannerViewController?.showBanner(with: success ? .success : .error, message: message)
      }

    self.viewModel.outputs.findRedirectUrl
      .observeForUI()
      .observeValues { [weak self] in self?.findRedirectUrl($0) }

    self.viewModel.outputs.updateCurrentUserInEnvironment
      .observeForUI()
      .observeValues { user in
        AppEnvironment.updateCurrentUser(user)
        AppEnvironment.current.identify(user: user)
      }

    self.viewModel.outputs.applicationActive
      .observeForUI()
      .observeValues { [weak self] state in
        self?.appDelegate?.applicationActive(state: state)
      }

    self.viewModel.outputs.applicationDidEnterBackground
      .observeForUI()
      .observeValues { [weak self] in
        self?.appDelegate?.applicationDidEnterBackground()
      }

    self.viewModel.outputs.applicationWillEnterForeground
      .observeForUI()
      .observeValues { [weak self] in
        self?.appDelegate?.applicationWillEnterForeground()
      }

    // Cold launch entry points: the app was not running, so these deep-link sources
    // arrive here instead of via the warm-launch scene delegate methods below. At this point
    // the scene is still `.unattached` and the window/root view controller's view has not
    // loaded yet, so any output that depends on the root tab bar controller's view lifecycle
    // (e.g. switching tabs) would silently no-op. Defer to the next run loop turn, by which
    // point UIKit has finished making the window key and visible.
    DispatchQueue.main.async { [weak self] in
      if let urlContext = connectionOptions.urlContexts.first {
        self?.handleOpenURLContext(urlContext)
      }

      if let userActivity = connectionOptions.userActivities.first {
        _ = self?.viewModel.inputs.applicationContinueUserActivity(userActivity)
      }

      if let shortcutItem = connectionOptions.shortcutItem {
        self?.viewModel.inputs.applicationPerformActionForShortcutItem(shortcutItem)
      }
    }
  }

  func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let urlContext = URLContexts.first else { return }
    self.handleOpenURLContext(urlContext)
  }

  func scene(_: UIScene, continue userActivity: NSUserActivity) {
    _ = self.viewModel.inputs.applicationContinueUserActivity(userActivity)
  }

  func windowScene(
    _: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    self.viewModel.inputs.applicationPerformActionForShortcutItem(shortcutItem)
    completionHandler(true)
  }

  // MARK: - Scene lifecycle

  func sceneDidBecomeActive(_: UIScene) {
    self.viewModel.inputs.sceneDidBecomeActive()
  }

  func sceneWillResignActive(_: UIScene) {
    self.viewModel.inputs.sceneWillResignActive()
  }

  func sceneWillEnterForeground(_: UIScene) {
    self.viewModel.inputs.sceneWillEnterForeground()
  }

  func sceneDidEnterBackground(_: UIScene) {
    self.viewModel.inputs.sceneDidEnterBackground()
  }

  private func handleOpenURLContext(_ urlContext: UIOpenURLContext) {
    let app = UIApplication.shared
    let url = urlContext.url

    var options: [UIApplication.OpenURLOptionsKey: Any] = [
      .openInPlace: urlContext.options.openInPlace
    ]
    if let sourceApplication = urlContext.options.sourceApplication {
      options[.sourceApplication] = sourceApplication
    }
    if let annotation = urlContext.options.annotation {
      options[.annotation] = annotation
    }

    // If this is not a Facebook login call, handle the potential deep-link
    guard !AppEnvironment.current.facebookSDK.handleOpenURL(app, open: url, options: options) else {
      return
    }

    _ = self.viewModel.inputs.applicationOpenUrl(
      application: app,
      url: url,
      options: options
    )
  }

  private func findRedirectUrl(_ url: URL) {
    let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    let task = session.dataTask(with: url)
    task.resume()
  }
}

// MARK: - URLSessionTaskDelegate

extension SceneDelegate: URLSessionTaskDelegate {
  public func urlSession(
    _: URLSession,
    task _: URLSessionTask,
    willPerformHTTPRedirection _: HTTPURLResponse,
    newRequest request: URLRequest,
    completionHandler: @escaping (URLRequest?) -> Void
  ) {
    request.url.doIfSome(self.viewModel.inputs.foundRedirectUrl)
    completionHandler(nil)
  }
}
