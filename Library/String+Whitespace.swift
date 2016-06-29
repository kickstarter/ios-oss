import Foundation

extension String {
  public func trimmed() -> String {
    return stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
  }
}
