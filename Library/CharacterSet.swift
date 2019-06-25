import Foundation

public extension CharacterSet {
  static func ksr_decimalSeparators() -> CharacterSet {
    if let decimalSeparator = AppEnvironment.current.locale.decimalSeparator {
      return CharacterSet(charactersIn: decimalSeparator)
    }
    return CharacterSet()
  }

  static func ksr_numericCharacters() -> CharacterSet {
    return CharacterSet.decimalDigits
  }
}
