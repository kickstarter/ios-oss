import Foundation

// swiftlint:disable force_unwrapping
// swiftlint:disable force_cast
// swiftlint:disable force_try

extension Dictionary {
  public func withAllValuesFrom(_ other: Dictionary) -> Dictionary {
    var result = self
    other.forEach { result[$0] = $1 }
    return result
  }
}

public struct Color {

  public let data: Data

  public init(data: Data) {
    self.data = data
  }

  public func colors() -> [(key: String, value: String)] {
    return (try! JSONSerialization.jsonObject(with: data, options: []) as! [String: String])
      .map { (key: $0, value: $1) }
      .sorted { $0.key < $1.key }
  }

  public var prettyColors: String {
    return colors().map { (color, value) in
      return "  \(color): #\(value)"
      }.joined(separator: "\n")
  }

  public var allColors: [(key: String, value: [(key: Int, value: String)])] {
    return colors()
      .reduce([String: [Int: String]]()) { accum, pair in
        let (name, _) = pair

        let components = name.components(separatedBy: "_")
        guard components.count > 1 else { return accum }
        let colorWeight: Int? = Int(components.last!)
        let colorName = colorWeight == nil
          ? components.joined(separator: " ") : components[0..<components.count-1].joined(separator: " ")
        let (color, weight) = (colorName, colorWeight ?? 0)
        let label = color.capitalized

        return accum.withAllValuesFrom(
          [label: (accum[label] ?? [:]).withAllValuesFrom([weight: "ksr_\(name)"])]
        )
      }
      .map { (k, v) -> (key: String, value: [(key: Int, value: String)]) in
        let sorted = v
          .map { (key: $0, value: $1) }
          .sorted { $0.key < $1.key }

        return (key: k, value: sorted)
      }
      .sorted { $0.key < $1.key }
  }

  public func staticStringsLines() -> [String] {

    var lines: [String] = []

    lines.append("//===============================================================")
    lines.append("//")
    lines.append("// This file is computer generated from Colors.json. Do not edit.")
    lines.append("//")
    lines.append("//===============================================================")
    lines.append("")
    lines.append("import UIKit")
    lines.append("")
    lines.append("// swiftlint:disable valid_docs")
    lines.append("extension UIColor {")

    lines.append("  public static var ksr_allColors: [String: [Int: UIColor]] {")
    lines.append("    return [")

    let staticAllColors: [String] = allColors.map { label, colors in
      var staticVar: [String] = []
      staticVar.append("      \"\(label)\": [")

      let pairs = colors
        .map { weight, name in "        \(weight): .\(name)" }
        .joined(separator: ",\n")
      staticVar.append(pairs)

      staticVar.append("      ]")
      return staticVar.joined(separator: "\n")
    }
    lines.append(staticAllColors.joined(separator: ",\n\n"))

    lines.append("    ]")
    lines.append("  }")
    lines.append("")

    let staticVars: [String] = colors().map { name, hex in
      var staticVar: [String] = []
      staticVar.append("  /// 0x\(hex)")
      staticVar.append("  public static var ksr_\(name): UIColor {")
      staticVar.append("    return .hex(0x\(hex))")
      staticVar.append("  }")
      return staticVar.joined(separator: "\n")
    }

    lines.append(staticVars.joined(separator: "\n\n"))
    lines.append("}")
    lines.append("") // trailing newline

    return lines
  }
}
