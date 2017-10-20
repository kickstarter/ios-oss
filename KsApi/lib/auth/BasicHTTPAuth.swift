/**
 A type that understands basic HTTP authentication: username and password.
*/
public protocol BasicHTTPAuthType {
  var username: String { get }
  var password: String { get }
}

public func == (lhs: BasicHTTPAuthType, rhs: BasicHTTPAuthType) -> Bool {
  return type(of: lhs) == type(of: rhs) &&
    lhs.username == rhs.username &&
    lhs.password == rhs.password
}

public func == (lhs: BasicHTTPAuthType?, rhs: BasicHTTPAuthType?) -> Bool {
  return type(of: lhs) == type(of: rhs) &&
    lhs?.username == rhs?.username &&
    lhs?.password == rhs?.password
}

extension BasicHTTPAuthType {
  /**
   Contents of the `Authorization` header needed to perform basic HTTP auth.
  */
  var authorizationHeader: String? {
    let string = "\(username):\(password)"
    if let data = string.data(using: .utf8) {
      let base64 = data.base64EncodedString(options: .lineLength64Characters)
      return "Basic \(base64)"
    }
    return nil
  }
}

public struct BasicHTTPAuth: BasicHTTPAuthType {
  public let username: String
  public let password: String

  public static let development: BasicHTTPAuthType = BasicHTTPAuth(
    username: Secrets.BasicHTTPAuth.username,
    password: Secrets.BasicHTTPAuth.password
  )

  public init(username: String, password: String) {
    self.username = username
    self.password = password
  }
}
