import Foundation

public func isValidEmail(email: String) -> Bool {

  let regex = try? NSRegularExpression(
    pattern: "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+",
    options: []
  )

  return regex?.firstMatchInString(email, options: [], range: NSMakeRange(0, email.characters.count)) != nil
}
