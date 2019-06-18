import Library
import Prelude
import ReactiveSwift

public protocol FacebookLoginViewModelInputs {
  /// Call when the application finishes launching.
  func applicationDidFinishLaunching(
    application: UIApplication?, launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  )

  /// Call to open a url that was sent to the app
  func applicationOpenUrl(
    application: UIApplication?,
    url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  ) -> Bool
}

public protocol FacebookLoginViewModelOutputs {
  /// The value to return from the delegate's `application:didFinishLaunchingWithOptions:` method.
  var applicationDidFinishLaunchingReturnValue: Bool { get }

  /// Return this value in the delegate method.
  var facebookOpenURLReturnValue: MutableProperty<Bool> { get }
}

public protocol FacebookLoginViewModelType {
  var inputs: FacebookLoginViewModelInputs { get }
  var outputs: FacebookLoginViewModelOutputs { get }
}

public final class FacebookLoginViewModel: FacebookLoginViewModelType, FacebookLoginViewModelInputs,
  FacebookLoginViewModelOutputs {
  public init() {
    self.applicationLaunchOptionsProperty.signal.skipNil()
      .take(first: 1)
      .observeValues { appOptions in
        _ = AppEnvironment.current.facebookAppDelegate.application(
          appOptions.application ?? UIApplication.shared,
          didFinishLaunchingWithOptions: appOptions.options
        )
      }

    let openUrl = self.applicationOpenUrlProperty.signal.skipNil()

    self.facebookOpenURLReturnValue <~ openUrl
      .map { options -> Bool in
        AppEnvironment.current.facebookAppDelegate.application(
          options.application ?? UIApplication.shared,
          open: options.url,
          options: options.options
        )
      }
  }

  public var inputs: FacebookLoginViewModelInputs { return self }
  public var outputs: FacebookLoginViewModelOutputs { return self }

  fileprivate typealias ApplicationWithOptions = (
    application: UIApplication?, options: [UIApplication.LaunchOptionsKey: Any]?
  )
  fileprivate let applicationLaunchOptionsProperty = MutableProperty<ApplicationWithOptions?>(nil)
  public func applicationDidFinishLaunching(
    application: UIApplication?,
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) {
    self.applicationLaunchOptionsProperty.value = (application, launchOptions)
  }

  fileprivate typealias ApplicationOpenUrl = (
    application: UIApplication?,
    url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  )
  fileprivate let applicationOpenUrlProperty = MutableProperty<ApplicationOpenUrl?>(nil)
  public func applicationOpenUrl(
    application: UIApplication?,
    url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  ) -> Bool {
    self.applicationOpenUrlProperty.value = (application, url, options)
    return self.facebookOpenURLReturnValue.value
  }

  fileprivate let applicationDidFinishLaunchingReturnValueProperty = MutableProperty(true)
  public var applicationDidFinishLaunchingReturnValue: Bool {
    return self.applicationDidFinishLaunchingReturnValueProperty.value
  }

  public let facebookOpenURLReturnValue = MutableProperty(false)
}
