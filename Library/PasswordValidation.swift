import Foundation

public typealias Password = String

public func passwordsMatch(_ pwds: (first: Password, second: Password)) -> Bool {
  return pwds.first == pwds.second
}

public func passwordLengthValid(_ pw: Password) -> Bool {
  return pw.count > 5
}

public func passwordFormValid(_ requirements: (empty: Bool, match: Bool, length: Bool)) -> Bool {
  return requirements.empty && requirements.match && requirements.length
}

public func passwordValidationText(_ requirements: (match: Bool, length: Bool)) -> String? {
  if !requirements.length {
    return Strings.Password_min_length_message()
  } else if !requirements.match {
    return Strings.Passwords_matching_message()
  } else {
    return nil
  }
}
