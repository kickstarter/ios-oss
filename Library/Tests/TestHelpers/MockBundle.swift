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
  ],
  "de": [
    "test_count.zero": "de_zero",
    "test_count.one": "de_one",
    "test_count.two": "de_two",
    "test_count.few": "de_%{the_count} few",
    "test_count.many": "de_%{the_count} many",
    "hello": "de_world",
    "echo": "echo",
    "hello_format": "de_hello %{a} %{b}"
  ],
  "es": [
    "placeholder_password": "el secreto",
  ]
]

internal struct MockBundle: NSBundleType {
  private var store: [String:String]!

  internal func pathForResource(name: String?, ofType ext: String?) -> String? {
    return name
  }

  internal init() {
  }

  internal init(lang: String) {
    store = stores[lang] ?? [:]
  }

  internal static func create(path path: String) -> NSBundleType? {
    return MockBundle.init(lang: path)
  }

  internal func localizedStringForKey(key: String, value: String?, table tableName: String?) -> String {
    // A real `NSBundle` will return the key if the key is missing and value is `nil`.
    return self.store[key] ?? value ?? key ?? ""
  }

  internal var infoDictionary: [String : AnyObject]? {
    return [
      "CFBundleVersion": 1234567890,
      "CFBundleShortVersionString": "1.2.3.4.5.6.7.8.9.0"
    ]
  }
}
