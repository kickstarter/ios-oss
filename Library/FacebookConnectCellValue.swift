public enum FacebookConnectionType {
  case connect
  case reconnect
}

public struct FacebookConnectCellValue {
  let source: FriendsSource
  let connectionType: FacebookConnectionType

  public init(source: FriendsSource, connectionType: FacebookConnectionType) {
    self.source = source
    self.connectionType = connectionType
  }
}
