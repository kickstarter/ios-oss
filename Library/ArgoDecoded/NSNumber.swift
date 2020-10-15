import Foundation

extension NSNumber {
  var isBool: Bool {
    return type(of: self) == type(of: NSNumber(value: true))
  }
}
