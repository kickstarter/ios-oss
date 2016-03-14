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
    "login_tout.help_sheet.contact": "Mock Contact"
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
    "login_tout.help_sheet.contact": "Contacto"
  ]
]

internal struct MockBundle: NSBundleType {
  private var store: [String:String]!

  func pathForResource(name: String?, ofType ext: String?) -> String? {
    return name
  }

  internal init() {
  }

  internal init(lang: String) {
    store = stores[lang] ?? [:]
  }

  static func create(path path: String) -> NSBundleType? {
    return MockBundle.init(lang: path)
  }

  func localizedStringForKey(key: String, value: String?, table tableName: String?) -> String {
    return self.store[key] ?? value ?? ""
  }
}
