#!/usr/bin/swift

import Foundation

// swiftlint:disable force_try force_cast force_unwrapping

extension Dictionary {
  func withAllValuesFrom(_ other: Dictionary) -> Dictionary {
    var result = self
    other.forEach { result[$0] = $1 }
    return result
  }
}

let inPath = "Design/Colors.json"
let outPath = "Library/Styles/Colors.swift"

let data = try! Data(contentsOf: URL(fileURLWithPath: inPath))

let colors =
  (try! JSONSerialization.jsonObject(with: data, options: []) as! [String: String])
    .map { (key: $0, value: $1) }
    .sorted { $0.key < $1.key }

let prettyColors = colors.map { (color, value) in
  return "  \(color): #\(value)"
  }.joined(separator: "\n")

print("All colors: \n\(prettyColors)")

let allColors = colors
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

var staticStringsLines: [String] = []

staticStringsLines.append("//===============================================================")
staticStringsLines.append("//")
staticStringsLines.append("// This file is computer generated from Colors.json. Do not edit.")
staticStringsLines.append("//")
staticStringsLines.append("//===============================================================")
staticStringsLines.append("")
staticStringsLines.append("import UIKit")
staticStringsLines.append("")
staticStringsLines.append("// swiftlint:disable valid_docs")
staticStringsLines.append("extension UIColor {")

staticStringsLines.append("  public static var ksr_allColors: [String: [Int: UIColor]] {")
staticStringsLines.append("    return [")

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
staticStringsLines.append(staticAllColors.joined(separator: ",\n\n"))

staticStringsLines.append("    ]")
staticStringsLines.append("  }")
staticStringsLines.append("")

let staticVars: [String] = colors.map { name, hex in
  var staticVar: [String] = []
  staticVar.append("  /* 0x\(hex) */ ")
  staticVar.append("  public static var ksr_\(name): UIColor {")
  staticVar.append("    return .hex(0x\(hex))")
  staticVar.append("  }")
  return staticVar.joined(separator: "\n")
}

staticStringsLines.append(staticVars.joined(separator: "\n\n"))
staticStringsLines.append("}")
staticStringsLines.append("") // trailing newline

try! staticStringsLines
  .joined(separator: "\n")
  .write(toFile: outPath, atomically: true, encoding: .utf8)

print("✨ Done regenerating Colors.swift ✨")
