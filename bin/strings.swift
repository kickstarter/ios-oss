import Foundation

let endpoint: String? =
  "https://\(Secrets.Api.Endpoint.production)/v1/app/ios/config?client_id=\(Secrets.Api.Client.production)&all_locales=true"

extension Dictionary {
  public func withAllValuesFrom(other: Dictionary) -> Dictionary {
    var result = self
    other.forEach { result[$0] = $1 }
    return result
  }

  static func renamed(key fromKey: Key, to toKey: Key) -> (Dictionary -> Dictionary) {
    return { dict in
      var result = dict
      result[toKey] = result[fromKey]
      result[fromKey] = nil
      return result
    }
  }
}

extension Array where Element: Hashable {
  public func distincts(@noescape eq: (Element, Element) -> Bool) -> Array {
    var result = Array()
    forEach { x in
      if !result.contains({ eq(x, $0) }) {
        result.append(x)
      }
    }
    return result
  }
}

let counts = ["zero", "one", "two", "few", "many"]

func flatten(data: [String:AnyObject], prefix: String = "") -> [String:String] {
  return data.reduce([String: String]()) { accum, keyAndNested in
    let (key, nested) = keyAndNested
    let newKey = prefix + key

    if let nested = nested as? [String:AnyObject] {
      return accum.withAllValuesFrom(flatten(nested, prefix: newKey + "."))
    }

    if let string = nested as? String {
      var values = [newKey: string]
      if (counts.contains(key) && string.containsString("_count}")) {
        values[prefix] = string
      }
      return accum.withAllValuesFrom(values)
    }

    return [:]
  }
}

func stringsFileContents(strings: [String:String]) -> String {
  return strings.keys.sort()
    .filter { key in !key.hasSuffix(".") }
    .map { key in "\"\(key)\" = \"\(escaped(string: strings[key]!))\";" }
    .joinWithSeparator("\n")
}

func funcArgumentNames(string: String) -> [String] {
  return string
    .componentsSeparatedByString("%{")
    .flatMap { $0.componentsSeparatedByString("}") }
    .enumerate()
    .filter { idx, _ in idx % 2 == 1 }
    .map { _, x in x }
    .distincts(==)
}

func funcArguments(argumentNames: [String], count: Bool) -> String {
  return argumentNames
    .enumerate()
    .map { _, x in
      let type = count && x.hasSuffix("_count") ? "Int" : "String"
      return "\(x): \(type)"
    }
    .joinWithSeparator(", ")
}

func funcCount(argumentNames: [String]) -> String {
  return argumentNames
    .filter { $0.hasSuffix("_count") }
    .first ?? "nil"
}

func funcSubstitutions(string: String, count: Bool) -> String {
  let insides = string
    .componentsSeparatedByString("%{")
    .flatMap { $0.componentsSeparatedByString("}") }
    .enumerate()
    .filter { idx, _ in idx % 2 == 1 }
    .map { _, x in "\"\(x)\": \(count && x.hasSuffix("_count") ? "Format.wholeNumber(\(x))" : x)" }
    .distincts(==)
    .joinWithSeparator(", ")
  if insides.characters.isEmpty {
    return "[:]"
  }
  return "[\(insides)]"
}

func escaped(string string: String) -> String {
  return string
    .stringByReplacingOccurrencesOfString("\n", withString: "\\n")
    .stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
}

let stringsByLocale = endpoint
  .flatMap(NSURL.init)
  .flatMap { try? String(contentsOfURL: $0) }
  .flatMap { $0.dataUsingEncoding(NSUTF8StringEncoding) }
  .flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: []) }
  .flatMap { $0 as? [String:AnyObject] }
  .flatMap { $0["locales"] as? [String:[String:AnyObject]] }
  .map(Dictionary.renamed(key: "en", to: "Base"))
  .map {
    $0.reduce([String: [String: String]]()) { accum, localeAndStrings in
      let (locale, strings) = localeAndStrings
      return accum.withAllValuesFrom([locale: flatten(strings)])
    }
}

stringsByLocale?.forEach { locale, strings in
  guard locale != "it" else { return }
  let contents = stringsFileContents(strings)
  let path = "Kickstarter-iOS/Locales/\(locale).lproj/Localizable.strings"
  try! contents.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
}

var staticStringsLines: [String] = []

staticStringsLines.append("//=======================================================================")
staticStringsLines.append("//")
staticStringsLines.append("// This file is computer generated from Localizable.strings. Do not edit.")
staticStringsLines.append("//")
staticStringsLines.append("//=======================================================================")
staticStringsLines.append("")
staticStringsLines.append("")
staticStringsLines.append("")
staticStringsLines.append("// swiftlint:disable valid_docs")
staticStringsLines.append("// swiftlint:disable line_length")
staticStringsLines.append("// swiftlint:disable file_length")
staticStringsLines.append("// swiftlint:disable type_body_length")
staticStringsLines.append("public enum Strings {")

stringsByLocale?["Base"]?.keys
  .filter { key in counts.reduce(true) { $0 && !key.hasSuffix(".\($1)") } }
  .sort()
  .forEach { key in
    let string = (stringsByLocale?["Base"]?[key])!

    staticStringsLines.append("  /**")
    staticStringsLines.append("   \"\((stringsByLocale?["Base"]?[key])!)\"\n")
    stringsByLocale?.forEach { locale, strings in
      let trueLocale = locale == "Base" ? "en" : locale
      staticStringsLines.append("   - **\(trueLocale)**: \"\(strings[key]!)\"")
    }
    staticStringsLines.append("  */")
    let pluralCount = key.hasSuffix(".")
    let key = pluralCount ? String(key.characters.dropLast()) : key
    let funcName = key.stringByReplacingOccurrencesOfString(".", withString: "_")
    let argumentNames = funcArgumentNames(string)
    staticStringsLines.append("  public static func \(funcName)(\(funcArguments(argumentNames, count: pluralCount))) -> String {")
    staticStringsLines.append("    return localizedString(")
    staticStringsLines.append("      key: \"\(key)\",")
    staticStringsLines.append("      defaultValue: \"\(escaped(string: string))\",")
    staticStringsLines.append("      count: \(pluralCount ? funcCount(argumentNames) : "nil"),")
    staticStringsLines.append("      substitutions: \(funcSubstitutions(string, count: pluralCount))")
    staticStringsLines.append("    )")
    staticStringsLines.append("  }")
  }

staticStringsLines.append("}")
staticStringsLines.append("")

let staticStringsFileContents = staticStringsLines.joinWithSeparator("\n")
try! staticStringsFileContents.writeToFile(
  "Library/Strings.swift",
  atomically: true,
  encoding: NSUTF8StringEncoding
)
