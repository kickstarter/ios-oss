import Foundation

public enum KickstarterBundleIdentifier: String {
  case alpha = "com.kickstarter.kickstarter.alpha"
  case beta = "com.kickstarter.kickstarter.beta"
  case release = "com.kickstarter.kickstarter"
}

public protocol NSBundleType {
  var bundleIdentifier: String? { get }
  static func create(path: String) -> NSBundleType?
  func path(forResource name: String?, ofType ext: String?) -> String?
  func localizedString(forKey key: String, value: String?, table tableName: String?) -> String
  var infoDictionary: [String: Any]? { get }
}

extension NSBundleType {
  public var identifier: String {
    return self.infoDictionary?["CFBundleIdentifier"] as? String ?? "Unknown"
  }

  public var shortVersionString: String {
    return self.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  }

  public var version: String {
    return self.infoDictionary?["CFBundleVersion"] as? String ?? "0"
  }

  public var isAlpha: Bool {
    return self.identifier == KickstarterBundleIdentifier.alpha.rawValue
  }

  public var isBeta: Bool {
    return self.identifier == KickstarterBundleIdentifier.beta.rawValue
  }

  public var isRelease: Bool {
    return self.identifier == KickstarterBundleIdentifier.release.rawValue
  }
}

extension Bundle: NSBundleType {
  public static func create(path: String) -> NSBundleType? {
    return Bundle(path: path)
  }
}

public struct LanguageDoubler: NSBundleType {
  fileprivate static let mainBundle = Bundle.main

  public init() {
  }

  public let bundleIdentifier: String? = "com.language.doubler"

  public static func create(path: String) -> NSBundleType? {
    return DoublerBundle(path: path)
  }

  public func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
    return LanguageDoubler.mainBundle.localizedString(forKey: key, value: value, table: tableName)
  }

  public func path(forResource name: String?, ofType ext: String?) -> String? {
    return LanguageDoubler.mainBundle.path(forResource: name, ofType: ext)
  }

  public var infoDictionary: [String: Any]? {
    return [:]
  }
}

public final class DoublerBundle: Bundle {
  public override func localizedString(forKey key: String,
                                       value: String?,
                                       table tableName: String?) -> String {

    let s = super.localizedString(forKey: key, value: value, table: tableName)
    return "\(s) \(s)"
  }
}
