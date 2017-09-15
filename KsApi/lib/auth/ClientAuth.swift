/**
 A type that holds an API client id, which provides anonymous authentication to the API.
*/
public protocol ClientAuthType {
  var clientId: String { get }
}

public func == (lhs: ClientAuthType, rhs: ClientAuthType) -> Bool {
  return type(of: lhs) == type(of: rhs) &&
    lhs.clientId == rhs.clientId
}

public struct ClientAuth: ClientAuthType {
  public fileprivate(set) var clientId: String

  public init(clientId: String) {
    self.clientId = clientId
  }

  public static let production: ClientAuthType = ClientAuth(
    clientId: Secrets.Api.Client.production
  )

  public static let development: ClientAuthType = ClientAuth(
    clientId: Secrets.Api.Client.staging
  )
}
