#!/usr/bin/swift
import Foundation
import ColorScriptCore

// swiftlint:disable force_try force_cast force_unwrapping

let inPath = "../../../../../Design/Colors.json"
let outPath = "../../../../../Library/Styles/Colors.swift"

let data = try! Data(contentsOf: URL(fileURLWithPath: inPath))
let c = ColorScriptCore.Color(data: data)

print("All colors: \n\(c.prettyColors)")

try! c.staticStringsLines()
  .joined(separator: "\n")
  .write(toFile: outPath, atomically: true, encoding: .utf8)

print("✨ Done regenerating Colors.swift ✨")
