import Foundation

public protocol NSBundleType {
  static func create(path path: String) -> NSBundleType?
  func pathForResource(name: String?, ofType ext: String?) -> String?
  func localizedStringForKey(key: String, value: String?, table tableName: String?) -> String
  var infoDictionary: [String:AnyObject]? { get }
}

extension NSBundleType {
  public var identifier: String {
    return self.infoDictionary?["CFBundleIdentifier"] as? String ?? "Unknown"
  }

  public var shortVersionString: String {
    return self.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  }

  public var version: String {
    return String(self.infoDictionary?["CFBundleVersion"] as? Int) ?? "0"
  }
}

extension NSBundle: NSBundleType {
  public static func create(path path: String) -> NSBundleType? {
    return NSBundle(path: path)
  }
}

public struct LanguageDoubler: NSBundleType {
  private static let mainBundle = NSBundle.mainBundle()

  public init() {
  }

  public static func create(path path: String) -> NSBundleType? {
    return DoublerBundle(path: path)
  }

  public func localizedStringForKey(key: String, value: String?, table tableName: String?) -> String {
    return LanguageDoubler.mainBundle.localizedStringForKey(key, value: value, table: tableName)
  }

  public func pathForResource(name: String?, ofType ext: String?) -> String? {
    return LanguageDoubler.mainBundle.pathForResource(name, ofType: ext)
  }

  public var infoDictionary: [String : AnyObject]? {
    return [:]
  }
}

public final class DoublerBundle: NSBundle {
  public override func localizedStringForKey(key: String,
                                             value: String?,
                                             table tableName: String?) -> String {

    let s = super.localizedStringForKey(key, value: value, table: tableName)
    return "\(s) \(s)"
  }
}
