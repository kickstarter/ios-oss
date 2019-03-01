import Foundation

let oauthToken: String = ProcessInfo.processInfo.environment["KICKSTARTER_API_IOS_OAUTH_TOKEN"] ?? ""

//swiftlint:disable:next line_length
let endpoint: String? = "https://\(Secrets.Api.Endpoint.production)/v1/app/ios/config?client_id=\(Secrets.Api.Client.production)&all_locales=true&oauth_token=\(oauthToken)"

extension Dictionary {
  static func renamed(key fromKey: Key, to toKey: Key) -> ((Dictionary) -> Dictionary) {
    return { dict in
      var result = dict
      result[toKey] = result[fromKey]
      result[fromKey] = nil
      return result
    }
  }
}

extension Array where Element: Hashable {
  public func distincts(_ eq: (Element, Element) -> Bool) -> Array {
    var result = Array()
    forEach { x in
      if !result.contains(where: { eq(x, $0) }) {
        result.append(x)
      }
    }
    return result
  }
}

enum StringsScriptCoreError: Error {
  case stringNotFound(String)
  case unknownError(String)
}

final class Strings {

  let counts = ["zero", "one", "two", "few", "many"]

  func flatten(_ data: [String: AnyObject], prefix: String = "") -> [String: String] {
    return data.reduce([String: String]()) { accum, keyAndNested in
      let (key, nested) = keyAndNested
      let newKey = prefix + key

      if let nested = nested as? [String: AnyObject] {
        return accum.merging(flatten(nested, prefix: newKey + ".")) { $1 }
      }

      if let string = nested as? String {
        var values = [newKey: string]
        if counts.contains(key) && string.contains("_count}") {
          values[prefix] = string
        }
        return accum.merging(values) { $1 }
      }

      return [:]
    }
  }

  func stringsFileContents(_ strings: [String: String]) -> String {

    return strings.keys
      .sorted()
      .filter { key in !key.hasSuffix(".") }
      .map { key in
        if let string = strings[key] {
          return "\"\(key)\" = \"\(escaped(string))\";"
        }
        return ""
      }
      .joined(separator: "\n")
  }

  func funcArgumentNames(_ string: String) -> [String] {
    return string
      .components(separatedBy: "%{")
      .flatMap { $0.components(separatedBy: "}") }
      .enumerated()
      .filter { idx, _ in idx % 2 == 1 }
      .map { _, x in x }
      .distincts(==)
  }

  func funcArguments(_ argumentNames: [String], count: Bool) -> String {
    return argumentNames
      .map { x in
        let type = count && x.hasSuffix("_count") ? "Int" : "String"
        return "\(x): \(type)"
      }
      .joined(separator: ", ")
  }

  func funcCount(_ argumentNames: [String]) -> String {
    return argumentNames
      .filter { $0.hasSuffix("_count") }
      .first ?? "nil"
  }

  func funcSubstitutions(_ string: String, count: Bool) -> String {
    let insides = string
      .components(separatedBy: "%{")
      .flatMap { $0.components(separatedBy: "}") }
      .enumerated()
      .filter { idx, _ in idx % 2 == 1 }
      .map { _, x in "\"\(x)\": \(count && x.hasSuffix("_count") ? "Format.wholeNumber(\(x))" : x)" }
      .distincts(==)
      .joined(separator: ", ")
    if insides.isEmpty {
      return "[:]"
    }
    return "[\(insides)]"
  }

  func escaped(_ string: String) -> String {
    return string
      .replacingOccurrences(of: "\n", with: "\\n")
      .replacingOccurrences(of: "\"", with: "\\\"")
  }

  public lazy var stringsByLocale: [String: [String: String]]? = {
    let stringsByLocale1 = endpoint
      .flatMap(URL.init)
      .flatMap { try? String(contentsOf: $0) }
      .flatMap { $0.data(using: .utf8) }
      .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }

    return stringsByLocale1
      .flatMap { $0 as? [String: AnyObject] }
      .flatMap { $0["locales"] as? [String: [String: AnyObject]] }
      .map(Dictionary.renamed(key: "en", to: "Base"))
      .map {
        $0.reduce([String: [String: String]]()) { accum, localeAndStrings in
          let (locale, strings) = localeAndStrings
          return accum.merging([locale: flatten(strings)]) { $1 }
        }
    }
  }()

  let supportedLocales = ["Base", "de", "en", "es", "fr", "ja"]

  public func localePathsAndContents() -> [(String, String)] {

    var pathsAndContents: [(String, String)] = []
    stringsByLocale?.forEach { locale, strings in
      guard supportedLocales.contains(locale) else { return }
      let content = stringsFileContents(strings)
      let path = "../../Kickstarter-iOS/Locales/\(locale).lproj/Localizable.strings"
      pathsAndContents.append((path, content))
    }
    return pathsAndContents
  }

  public func staticStringsFileContents() throws -> String {
    var staticStringsLines: [String] = []
    staticStringsLines.append("//=======================================================================")
    staticStringsLines.append("//")
    staticStringsLines.append("// This file is computer generated from Localizable.strings. Do not edit.")
    staticStringsLines.append("//")
    staticStringsLines.append("//=======================================================================")
    staticStringsLines.append("")
    staticStringsLines.append("// swiftlint:disable valid_docs")
    staticStringsLines.append("// swiftlint:disable line_length")
    staticStringsLines.append("public enum Strings {")

    do {
      try stringsByLocale?["Base"]?.keys
        .filter { key in counts.reduce(true) { $0 && !key.hasSuffix(".\($1)") } }
        .sorted()
        .forEach { key in
          guard let string = (stringsByLocale?["Base"]?[key]) else {
            throw StringsScriptCoreError.stringNotFound("String not found. Line: \(#line)")
          }
          print(string)
          staticStringsLines.append("  /**")
          staticStringsLines.append("   \"\(string)\"\n")

          if let stringsByLocale = stringsByLocale {
            let sortedKeys = Array(stringsByLocale.keys).sorted()

            for locale in sortedKeys {
              guard let strings = stringsByLocale[locale] else { continue }
              let trueLocale = locale == "Base" ? "en" : locale
              guard supportedLocales.contains(trueLocale), let stringValue = strings[key] else { continue }
              staticStringsLines.append("   - **\(trueLocale)**: \"\(stringValue)\"")
            }
          }

          staticStringsLines.append("  */")
          let pluralCount = key.hasSuffix(".")
          let key = pluralCount ? String(key.dropLast()) : key
          let funcName = key.replacingOccurrences(of: ".", with: "_")
          let argNames = funcArgumentNames(string)
          staticStringsLines.append(
            "  public static func \(funcName)(\(funcArguments(argNames, count: pluralCount))) -> String {"
          )
          staticStringsLines.append("    return localizedString(")
          staticStringsLines.append("      key: \"\(key)\",")
          staticStringsLines.append("      defaultValue: \"\(escaped(string))\",")
          staticStringsLines.append("      count: \(pluralCount ? funcCount(argNames) : "nil"),")
          staticStringsLines
            .append("      substitutions: \(funcSubstitutions(string, count: pluralCount))")
          staticStringsLines.append("    )")
          staticStringsLines.append("  }")
      }
      staticStringsLines.append("}")
      staticStringsLines.append("")
      return staticStringsLines.joined(separator: "\n")
    } catch {
      throw StringsScriptCoreError.unknownError("Error: \(error)\nLine: \(#line)")
    }
  }
}
