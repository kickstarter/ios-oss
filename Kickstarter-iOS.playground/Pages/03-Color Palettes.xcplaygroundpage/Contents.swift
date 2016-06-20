import Library
import UIKit

let baseColors = UIColor.ksr_allColors.sort { compareColorWhites($0.color, $1.color) }
let basePalette = colorPalette(colors: baseColors.map { ($0.color, $0.name) },
                               columnsCount: 7)
basePalette

let categoryColors = Color.Category.allColors.sort { $0.rawValue < $1.rawValue }
let categoryPalette = colorPalette(colors: categoryColors.map { ($0.toUIColor(), $0.rawValue) })
categoryPalette
