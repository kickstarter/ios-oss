import Foundation
import ColorScriptCore

let colorScript = ColorScript()

do {
  try colorScript.run()
} catch {
  print("Error: \(error)")
}
