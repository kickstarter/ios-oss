public enum LiveApiError: Error {
  case chatMessageDecodingFailed
  case failedToInitializeFirebase
  case firebaseAnonymousAuthFailed
  case firebaseCustomTokenAuthFailed
  case sendChatMessageFailed
  case snapshotDecodingFailed(path: String)
  case timedOut
  case genericFailure
  case invalidJson
  case invalidRequest
}

extension LiveApiError: Equatable {
  public static func == (lhs: LiveApiError, rhs: LiveApiError) -> Bool {
    switch (lhs, rhs) {
    case (.chatMessageDecodingFailed, .chatMessageDecodingFailed),
         (failedToInitializeFirebase, .failedToInitializeFirebase),
         (firebaseAnonymousAuthFailed, .firebaseAnonymousAuthFailed),
         (firebaseCustomTokenAuthFailed, .firebaseCustomTokenAuthFailed),
         (sendChatMessageFailed, .sendChatMessageFailed),
         (genericFailure, .genericFailure),
         (invalidJson, .invalidJson),
         (invalidRequest, .invalidRequest),
         (timedOut, timedOut):
      return true
    case let (snapshotDecodingFailed(lhs), .snapshotDecodingFailed(rhs)):
      return lhs == rhs
    case (chatMessageDecodingFailed, _), (failedToInitializeFirebase, _), (firebaseAnonymousAuthFailed, _),
         (firebaseCustomTokenAuthFailed, _), (sendChatMessageFailed, _), (snapshotDecodingFailed, _),
         (genericFailure, _), (invalidJson, _), (invalidRequest, _), (timedOut, _):
      return false
    }
  }
}
