import UIKit
import Library

let baseColors = Color.allColors.sort { compareColorWhites($0.toUIColor(), $1.toUIColor()) }
let basePalette = colorPalette(colors: baseColors.map { ($0.toUIColor(), $0.rawValue) }, columnsCount: 7)
basePalette

let categoryColors = Color.Category.allColors.sort { $0.rawValue < $1.rawValue }
let categoryPalette = colorPalette(colors: categoryColors.map { ($0.toUIColor(), $0.rawValue) })
categoryPalette

let socialColors = Color.Social.allColors
let socialPalette = colorPalette(colors: socialColors.map { ($0.toUIColor(), $0.rawValue) }, size: CGSize(width: 400.0, height: 200.0), columnsCount: 2)
socialPalette
