import class Foundation.NSBundle

public protocol NSBundleType {
  func pathForResource(name: String?, ofType ext: String?) -> String?
  func localizedStringForKey(key: String, value: String?, table tableName: String?) -> String
  static func create(path path: String) -> NSBundleType?
}

extension NSBundle: NSBundleType {
  public static func create(path path: String) -> NSBundleType? {
    return NSBundle(path: path)
  }
}

public struct LanguageDoubler: NSBundleType {
  private static let mainBundle = NSBundle.mainBundle()

  public static func create(path path: String) -> NSBundleType? {
    return DoublerBundle(path: path)
  }

  public init() {
  }
  
  public func localizedStringForKey(key: String, value: String?, table tableName: String?) -> String {
    return LanguageDoubler.mainBundle.localizedStringForKey(key, value: value, table: tableName)
  }

  public func pathForResource(name: String?, ofType ext: String?) -> String? {
    return LanguageDoubler.mainBundle.pathForResource(name, ofType: ext)
  }
}

public class DoublerBundle: NSBundle {
  public override func localizedStringForKey(key: String, value: String?, table tableName: String?) -> String {

    let s = super.localizedStringForKey(key, value: value, table: tableName)
    return "\(s) \(s)"
  }
}
