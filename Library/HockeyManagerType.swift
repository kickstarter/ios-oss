import class HockeySDK.BITHockeyManager

/**
 *  A type that can act like a HockeySDK manager without necessarily interfacing with Hockey.
 */
public protocol HockeyManagerType {
  func configureWithIdentifier(appIdentifier: String)
  func startManager()
  func appIdentifier() -> String?
  func autoSendReports()
}

extension BITHockeyManager: HockeyManagerType {
  public func autoSendReports() {
    self.crashManager.crashManagerStatus = .AutoSend
  }

  public func appIdentifier() -> String? {
    return "***REMOVED***"
  }
}

/**
 * A fake HockeySDK manager, useful for testing.
 */
internal final class MockHockeyManager: HockeyManagerType {
  internal var configuredAppIdentifier: String? = nil
  internal var managerStarted = false
  internal var isAutoSendingReports = false

  func autoSendReports() {
    self.isAutoSendingReports = true
  }

  internal func configureWithIdentifier(appIdentifier: String) {
    self.configuredAppIdentifier = appIdentifier
  }

  internal func startManager() {
    managerStarted = true
  }

  internal func appIdentifier() -> String? {
    return "deadbeef"
  }
}
