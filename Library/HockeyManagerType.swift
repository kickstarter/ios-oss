import class HockeySDK.BITHockeyManager

/**
 *  A type that can act like a HockeySDK manager without necessarily interfacing with Hockey.
 */
public protocol HockeyManagerType {
  func configureWithIdentifier(appIdentifier: String!)
  func startManager()
  func appIdentifier() -> String?
}

extension BITHockeyManager: HockeyManagerType {
  public func appIdentifier() -> String? {
    return AppEnvironment.current.mainBundle
      .pathForResource("hockeyapp", ofType: "config")
      .flatMap { file in try? String(contentsOfFile: file) }
  }
}

/**
 * A fake HockeySDK manager, useful for testing.
 */
internal final class MockHockeyManager: HockeyManagerType {
  internal var configuredAppIdentifier: String? = nil
  internal var managerStarted = false

  internal func configureWithIdentifier(appIdentifier: String!) {
    self.configuredAppIdentifier = appIdentifier
  }

  internal func startManager() {
    managerStarted = true
  }

  internal func appIdentifier() -> String? {
    return "deadbeef"
  }
}
