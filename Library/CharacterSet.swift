import Foundation

public extension CharacterSet {
  static func ksr_decimalSeparators() -> CharacterSet {
    return CharacterSet(charactersIn: AppEnvironment.current.locale.decimalSeparator ?? "")
  }

  static func ksr_numericCharacters() -> CharacterSet {
    return CharacterSet.decimalDigits
  }
}
