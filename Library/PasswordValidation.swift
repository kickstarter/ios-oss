import Foundation

public typealias Password = String

public func passwordLengthValid(_ pw: Password) -> Bool {
  return pw.count > 5
}

public func passwordFormValid(_ requirements: (notEmpty: Bool, match: Bool, length: Bool)) -> Bool {
  return requirements.notEmpty && requirements.match && requirements.length
}

public func passwordValidationText(_ length: Bool) -> String? {
  return passwordValidationText((length, true))
}

public func passwordValidationText(_ requirements: (length: Bool, match: Bool)) -> String? {
  if !requirements.length {
    return Strings.Password_min_length_message()
  } else if !requirements.match {
    return Strings.Passwords_matching_message()
  } else {
    return nil
  }
}
