import Prelude

/**
 Finds a localized string for a provided key and interpolates it with substitutions.

 - parameters:
   - key:           The key of the string to find in a bundle.
   - defaultValue:  Optional value to use in case a string could not be found for the provided key.
   - substitutions: A dictionary of key/value substitutions to be made.
   - env:           An app environment to derive the language from.

 - returns: The localized string. If the key does not exist the `defaultValue` will be returned,
 and if that is not specified an empty string will be returned.
 */
public func localizedString(key key: String,
                                defaultValue: String = "",
                                count: Int? = nil,
                                substitutions: [String:String] = [:],
                                env: Environment = AppEnvironment.current,
                                bundle: NSBundleType = stringsBundle) -> String {

  // When a `count` is provided we need to augment the key with a pluralization suffix.
  let augmentedKey = count
    .flatMap { key + "." + keySuffixForCount($0) }
    .coalesceWith(key)

  let lprojName = lprojFileNameForLanguage(env.language)
  let localized = bundle.pathForResource(lprojName, ofType: "lproj")
    .flatMap(bundle.dynamicType.create(path:))
    .flatMap { $0.localizedStringForKey(augmentedKey, value: defaultValue, table: nil) }

  return substitute(localized, with: substitutions)
}

private func lprojFileNameForLanguage(language: Language) -> String {
  return language.rawValue == "en" ? "Base" : language.rawValue
}

// Returns the pluralization suffx for a count.
private func keySuffixForCount(count: Int) -> String {
  switch count {
  case 0:
    return "zero"
  case 1:
    return "one"
  case 2:
    return "two"
  case 3...5:
    return "few"
  default:
    return "many"
  }
}

// Performs simple string interpolation on keys of the form `%{key}`.
private func substitute(string: String, with substitutions: [String: String]) -> String {

  return substitutions.reduce(string) { accum, sub in
    return accum.stringByReplacingOccurrencesOfString("%{\(sub.0)}", withString: sub.1)
  }
}

private class Pin {}
private let stringsBundle = NSBundle(forClass: Pin.self)
