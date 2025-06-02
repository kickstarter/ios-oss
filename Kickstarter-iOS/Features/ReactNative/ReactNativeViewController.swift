import Foundation
import KsApi
import Library
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider
import ReactiveExtensions
import ReactiveSwift
import UIKit

class ReactViewController: UIViewController {
  var reactNativeFactory: RCTReactNativeFactory?
  var reactNativeFactoryDelegate: RCTReactNativeFactoryDelegate?
  private var rootView: RCTRootView?
  private static var sharedBridge: RCTBridge?
  private var bridge: RCTBridge? {
    get { Self.sharedBridge }
    set { Self.sharedBridge = newValue }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupReactNative()
    self.observeEnvironmentChanges()
  }

  private func setupReactNative() {
    self.reactNativeFactoryDelegate = ReactNativeDelegate()
    self.reactNativeFactoryDelegate!.dependencyProvider = RCTAppDependencyProvider()
    self.reactNativeFactory = RCTReactNativeFactory(delegate: self.reactNativeFactoryDelegate!)

    // Create initial props
    let props = self.getEnvironmentProps()

    let environmentLocation = ProcessInfo.processInfo
      .environment["KSR_JS_LOCATION"]
    if let environmentLocation {
      UserDefaults.standard.set(environmentLocation, forKey: "KSR_JS_LOCATION")
    }
    let localStorageLocation = UserDefaults.standard.string(forKey: "KSR_JS_LOCATION")
    RCTBundleURLProvider.sharedSettings().jsLocation = environmentLocation ?? localStorageLocation

    // Use or create shared bridge
    if Self.sharedBridge == nil {
      Self.sharedBridge = RCTBridge(delegate: self.reactNativeFactoryDelegate!, launchOptions: nil)
    }
    self.bridge = Self.sharedBridge

    // Create root view explicitly
    rootView = RCTRootView(
      bridge: self.bridge!,
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
    NotificationCenter.default
      .reactive
      .notifications(forName: .ksr_sessionStarted)
      .observeValues { [weak self] _ in
        self?.updateEnvironmentProps()
      }

    NotificationCenter.default
      .reactive
      .notifications(forName: .ksr_sessionEnded)
      .observeValues { [weak self] _ in
        self?.updateEnvironmentProps()
      }

    NotificationCenter.default
      .reactive
      .notifications(forName: .ksr_userUpdated)
      .observeValues { [weak self] _ in
        self?.updateEnvironmentProps()
      }
  }

  private func updateEnvironmentProps() {
    let props = self.getEnvironmentProps()
    self.rootView?.appProperties = props
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
  override func sourceURL(for _: RCTBridge) -> URL? {
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
