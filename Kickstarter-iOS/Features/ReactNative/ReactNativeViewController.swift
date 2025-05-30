import UIKit
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider
import KsApi
import Library
import ReactiveSwift
import ReactiveExtensions

class ReactViewController: UIViewController {
  var reactNativeFactory: RCTReactNativeFactory?
  var reactNativeFactoryDelegate: RCTReactNativeFactoryDelegate?
  private var environmentObserver: Disposable?
  private var rootView: RCTRootView?
  private var bridge: RCTBridge?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupReactNative()
    observeEnvironmentChanges()
  }

  deinit {
    environmentObserver?.dispose()
    bridge?.invalidate()
  }

  private func setupReactNative() {
    reactNativeFactoryDelegate = ReactNativeDelegate()
    reactNativeFactoryDelegate!.dependencyProvider = RCTAppDependencyProvider()
    reactNativeFactory = RCTReactNativeFactory(delegate: reactNativeFactoryDelegate!)
    
    // Create initial props
    let props = getEnvironmentProps()
    
    // Create bridge
    let bridge = RCTBridge(delegate: reactNativeFactoryDelegate!, launchOptions: nil)!
    self.bridge = bridge
    
    // Create root view explicitly
    rootView = RCTRootView(
      bridge: bridge,
      moduleName: "KickstarterMobile",
      initialProperties: props
    )
    
    // Configure root view
    rootView?.backgroundColor = .systemBackground
    rootView?.loadingView = UIActivityIndicatorView(style: .large)
    
    // Add to view hierarchy
    if let rootView = rootView {
      view.addSubview(rootView)
      rootView.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        rootView.topAnchor.constraint(equalTo: view.topAnchor),
        rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
    }
  }

  private func observeEnvironmentChanges() {
    // Observe AppEnvironment changes
    environmentObserver = NotificationCenter.default
      .reactive
      .notifications(forName: .ksr_sessionStarted)
      .observeValues { [weak self] _ in
        self?.updateEnvironmentProps()
      }

    environmentObserver?.dispose()
    environmentObserver = NotificationCenter.default
      .reactive
      .notifications(forName: .ksr_sessionEnded)
      .observeValues { [weak self] _ in
        self?.updateEnvironmentProps()
      }

    environmentObserver?.dispose()
    environmentObserver = NotificationCenter.default
      .reactive
      .notifications(forName: .ksr_userUpdated)
      .observeValues { [weak self] _ in
        self?.updateEnvironmentProps()
      }
  }

  private func updateEnvironmentProps() {
    let props = getEnvironmentProps()
    rootView?.appProperties = props
  }

  private func getEnvironmentProps() -> [String: Any] {
    let env = AppEnvironment.current
    
    return [
      "oauthToken": env!.apiService.oauthToken?.token ?? "",
      "graphQLEndpoint": env!.apiService.serverConfig.graphQLEndpointUrl.absoluteString,
      "language": env!.language.rawValue,
      "currency": env!.apiService.currency,
      "buildVersion": env!.apiService.buildVersion,
      "deviceIdentifier": env!.apiService.deviceIdentifier,
      "appId": env!.apiService.appId,
      "isLoggedIn": env!.currentUser != nil,
      "currentUserId": env!.currentUser?.id ?? "",
      "currentUserEmail": env!.currentUserEmail ?? ""
    ]
  }
}

class ReactNativeDelegate: RCTDefaultReactNativeFactoryDelegate {
    override func sourceURL(for bridge: RCTBridge) -> URL? {
      self.bundleURL()
    }

    override func bundleURL() -> URL? {
      #if DEBUG
      RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
      #else
      Bundle.main.url(forResource: "main", withExtension: "jsbundle")
      #endif
    }
}
