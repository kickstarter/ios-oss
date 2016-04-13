import Foundation

private let pattern = "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@" +
                      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\." +
                      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+"

public func isValidEmail(email: String) -> Bool {

  let regex = try? NSRegularExpression(
    pattern: pattern,
    options: []
  )

  let range = NSRange.init(location: 0, length: email.characters.count)
  return regex?.firstMatchInString(email, options: [], range: range) != nil
}
