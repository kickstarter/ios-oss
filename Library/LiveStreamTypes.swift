import Foundation
import ReactiveSwift
import LiveStream

public struct NewLiveStreamChatMessage: NewLiveStreamChatMessageProtocol {
  public fileprivate(set) var message: String
  public fileprivate(set) var name: String
  public fileprivate(set) var profilePic: String
  public fileprivate(set) var userId: String

  public init(message: String, name: String, profilePic: String, userId: String) {
    self.message = message
    self.name = name
    self.profilePic = profilePic
    self.userId = userId
  }

  public func toFirebaseDictionary() -> [String: Any] {
    return [
      "message": self.message,
      "name": self.name,
      "profilePic": self.profilePic,
      "userId": self.userId
    ]
  }
}

public enum LiveVideoPlaybackError {
  case failedToConnect
  case sessionInterrupted
}

public enum LiveVideoPlaybackState {
  case error(error: LiveVideoPlaybackError)
  case loading
  case playing(videoEnabled: Bool)

  public var isError: Bool {
    if case .error = self {
      return true
    }
    return false
  }

  public var isPlaying: Bool {
    if case .playing = self {
      return true
    }
    return false
  }

  public var error: LiveVideoPlaybackError? {
    guard case let .error(error) = self else { return nil }
    return error
  }
}

extension LiveVideoPlaybackState: Equatable {
  public static func == (lhs: LiveVideoPlaybackState, rhs: LiveVideoPlaybackState) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading): return true
    case (.playing(let lhsVideoEnabled), .playing(let rhsVideoEnabled)):
      return lhsVideoEnabled == rhsVideoEnabled
    case (.error(let lhsError), .error(let rhsError)):
      return lhsError == rhsError
    case (.loading, _), (.playing, _), (.error, _):
      return false
    }
  }
}

public enum LiveStreamType {
  case hlsStream(hlsStreamUrl: String)
  case openTok(sessionConfig: OpenTokSessionConfig)

  public var hlsStreamUrl: String? {
    switch self {
    case let .hlsStream(url): return url
    default:                  return nil
    }
  }

  public var openTokSessionConfig: OpenTokSessionConfig? {
    switch self {
    case let .openTok(sessionConfig):  return sessionConfig
    default:                           return nil
    }
  }
}

extension LiveStreamType: Equatable {
  public static func == (lhs: LiveStreamType, rhs: LiveStreamType) -> Bool {
    switch (lhs, rhs) {
    case let (.hlsStream(lhs), .hlsStream(rhs)):
      return lhs == rhs

    case let (.openTok(lhs), .openTok(rhs)):
      return lhs == rhs

    case (.hlsStream, _), (.openTok, _):
      return false
    }
  }
}

public struct OpenTokSessionConfig: Equatable {
  public fileprivate(set) var sessionId: String
  public fileprivate(set) var apiKey: String
  public fileprivate(set) var token: String

  public init(apiKey: String, sessionId: String, token: String) {
    self.apiKey = apiKey
    self.sessionId = sessionId
    self.token = token
  }
}

public func == (lhs: OpenTokSessionConfig, rhs: OpenTokSessionConfig) -> Bool {
  return lhs.apiKey == rhs.apiKey &&
    lhs.sessionId == rhs.sessionId &&
    lhs.token == rhs.token
}

public protocol OTStreamType {
  var streamId: String { get }
}
public protocol OTErrorType {}

public protocol OTSubscriberVideoEventReasonType {
  var isQualityChangedReason: Bool { get }
}
