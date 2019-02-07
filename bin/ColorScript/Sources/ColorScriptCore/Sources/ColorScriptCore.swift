import Foundation

public enum ColorScriptCoreError: Error {
  case decodeError(String)
  case codeGenerationError(String)
}

extension Dictionary {

  public func withAllValuesFrom(_ other: Dictionary) -> Dictionary {
    return self.merging(other) { $1 }
  }
}

public struct Color {

  public let data: Data

  public init(data: Data) {
    self.data = data
  }

  public func colors() throws -> [(key: String, value: String)]? {
    do {
      let json = try (JSONSerialization.jsonObject(with: self.data, options: []) as? [String: String])
      let colors = json?
        .map { (key: $0, value: $1) }
        .sorted { $0.key < $1.key }
      return colors
    } catch {
      throw ColorScriptCoreError.decodeError(error.localizedDescription)
    }
  }

  public var prettyColors: String? {
    do {
      return try self.colors()?.map { (color, value) in
        return "  \(color): #\(value)"
        }.joined(separator: "\n")
    } catch {
      print("[prettyColors] \(error.localizedDescription)")
    }
    return nil
  }

  public var allColors: [(key: String, value: [(key: Int, value: String)])] {
    do {
      return try self.colors()?
        .reduce([String: [Int: String]]()) { accum, pair in
          let (name, _) = pair

          let components = name.components(separatedBy: "_")
          guard components.count > 1,
            let component = components.last else {
            return accum
          }
          let colorWeight = Int(component)
          let colorName = colorWeight == nil
            ? components.joined(separator: " ") : components[0..<components.count-1].joined(separator: " ")
          let (color, weight) = (colorName, colorWeight ?? 0)
          let label = color.capitalized

          return accum.withAllValuesFrom(
            [label: (accum[label] ?? [:]).withAllValuesFrom([weight: "ksr_\(name)"])]
          )
        }
        .map { (key, value) -> (key: String, value: [(key: Int, value: String)]) in
          let sorted = value
            .map { (key: $0, value: $1) }
            .sorted { $0.key < $1.key }

          return (key: key, value: sorted)
        }
        .sorted { $0.key < $1.key } ?? []
    } catch {
      print("[allColors] \(error.localizedDescription)")
    }
    return []
  }

  public func staticStringsLines() throws -> [String] {

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

    let staticAllColors: [String] = self.allColors.map { label, colors in
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

    do {
      let staticVars: [String]? = try self.colors()?.map { name, hex in
        var staticVar: [String] = []
        staticVar.append("  /// 0x\(hex)")
        staticVar.append("  public static var ksr_\(name): UIColor {")
        staticVar.append("    return .hex(0x\(hex))")
        staticVar.append("  }")
        return staticVar.joined(separator: "\n")
      }
      if let staticVars = staticVars {
        lines.append(staticVars.joined(separator: "\n\n"))
      }
      lines.append("}")
      lines.append("") // trailing newline
      return lines
    } catch {
      throw ColorScriptCoreError.codeGenerationError(error.localizedDescription)
    }
  }
}
