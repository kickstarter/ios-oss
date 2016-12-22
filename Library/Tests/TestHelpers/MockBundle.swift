@testable import Library
import Prelude

private let stores = [
  "Base": [
    "test_count.zero": "zero",
    "test_count.one": "one",
    "test_count.two": "two",
    "test_count.few": "%{the_count} few",
    "test_count.many": "%{the_count} many",
    "hello": "world",
    "echo": "echo",
    "hello_format": "hello %{a} %{b}",
    "placeholder_password": "password",
    "dates.just_now": "just now",
    "dates.time_hours_ago.zero": "%{time_count} hours ago",
    "dates.time_hours_ago.one": "%{time_count} hour ago",
    "dates.time_hours_ago.two": "%{time_count} hours ago",
    "dates.time_hours_ago.few": "%{time_count} hours ago",
    "dates.time_hours_ago.many": "%{time_count} hours ago",
    "dates.time_hours_ago_abbreviated.zero": "%{time_count} hrs ago",
    "dates.time_hours_ago_abbreviated.one": "%{time_count} hr ago",
    "dates.time_hours_ago_abbreviated.two": "%{time_count} hrs ago",
    "dates.time_hours_ago_abbreviated.few": "%{time_count} hrs ago",
    "dates.time_hours_ago_abbreviated.many": "%{time_count} hrs ago",
  ],
  "de": [
    "test_count.zero": "de_zero",
    "test_count.one": "de_one",
    "test_count.two": "de_two",
    "test_count.few": "de_%{the_count} few",
    "test_count.many": "de_%{the_count} many",
    "hello": "de_world",
    "echo": "echo",
    "hello_format": "de_hello %{a} %{b}",
    "dates.time_hours_ago.one": "vor %{time_count} Stunde",
    "dates.time_hours_ago_abbreviated.one": "vor %{time_count} Std",
  ],
  "es": [
    "placeholder_password": "el secreto",
  ]
]

internal struct MockBundle: NSBundleType {
  internal let bundleIdentifier: String?
  fileprivate let store: [String:String]

  internal func path(forResource name: String?, ofType ext: String?) -> String? {
    return name
  }

  internal init(bundleIdentifier: String? = "com.bundle.mock", lang: String = "Base") {
    self.bundleIdentifier = bundleIdentifier
    self.store = stores[lang] ?? [:]
  }

  internal static func create(path: String) -> NSBundleType? {
    return MockBundle(lang: path)
  }

  internal func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
    // A real `NSBundle` will return the key if the key is missing and value is `nil`.
    return self.store[key] ?? value ?? key ?? ""
  }

  internal  var infoDictionary: [String : Any]? {
    var result: [String:Any] = [:]
    result["CFBundleIdentifier"] = self.bundleIdentifier
    result["CFBundleVersion"] = "1234567890"
    result["CFBundleShortVersionString"] = "1.2.3.4.5.6.7.8.9.0"
    return result
  }
}
