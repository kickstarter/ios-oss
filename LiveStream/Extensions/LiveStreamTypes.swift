import Foundation
import ReactiveSwift

public struct NewLiveStreamChatMessage {
  public let message: String
  public let name: String
  public let profilePic: String
  public let userId: String

  public init(message: String, name: String, profilePic: String, userId: String) {
    self.message = message
    self.name = name
    self.profilePic = profilePic
    self.userId = userId
  }

  public func toFirebaseDictionary() -> [String:Any] {
    return [
      LiveStreamChatMessageDictionaryKey.message.rawValue: self.message,
      LiveStreamChatMessageDictionaryKey.name.rawValue: self.name,
      LiveStreamChatMessageDictionaryKey.profilePic.rawValue: self.profilePic,
      LiveStreamChatMessageDictionaryKey.userId.rawValue: self.userId
    ]
  }
}

public enum LiveStreamChatMessageDictionaryKey: String {
  case id
  case creator
  case message
  case name
  case profilePic
  case timestamp
  case userId
}

public enum LiveStreamSession {
  case anonymous
  case loggedIn(token: String)

  public var isAnonymous: Bool {
    switch self {
    case .anonymous:
      return true
    case .loggedIn:
      return false
    }
  }

  public var isLoggedIn: Bool {
    switch self {
    case .anonymous:
      return false
    case .loggedIn:
      return true
    }
  }
}

public enum LiveVideoPlaybackError {
  case failedToConnect
  case sessionInterrupted
}

public enum LiveVideoPlaybackState {
  case error(error: LiveVideoPlaybackError)
  case loading
  case playing

  public var isError: Bool {
    if case .error = self {
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
    case (.playing, .playing): return true
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
    case (.hlsStream(let lhsHLSStreamUrl), .hlsStream(let rhsHLSStreamUrl)):
      return lhsHLSStreamUrl == rhsHLSStreamUrl

    case (.openTok(let lhsSessionConfig), .openTok(let rhsSessionConfig)):
      return lhsSessionConfig.apiKey == rhsSessionConfig.apiKey
        && lhsSessionConfig.sessionId == rhsSessionConfig.sessionId
        && lhsSessionConfig.token == rhsSessionConfig.token

    case (.hlsStream, _), (.openTok, _):
      return false
    }
  }
}

/**
 - error:                The LiveVideoPlaybackError returned by the LiveVideoViewController.
 - greenRoom:            The green room is active (streamer not ready to go live yet).
 - initializationFailed: LiveStreamViewController initialization failed.
 - live:                 The LiveStreamViewController is Live along with its respective LiveVideoPlaybackState
                         and startTime.
 - loading:              The LiveStreamViewController is loading.
 - nonStarter:           The event failed to start and has no replay.
 - replay:               The LiveStreamViewController is Replay along with its respective 
                         LiveVideoPlaybackState and duration.
 */
public enum LiveStreamViewControllerState {
  case error(error: LiveVideoPlaybackError)
  case greenRoom
  case initializationFailed
  case live(playbackState: LiveVideoPlaybackState, startTime: TimeInterval)
  case loading
  case nonStarter
  case replay(playbackState: LiveVideoPlaybackState, duration: TimeInterval)
}

extension LiveStreamViewControllerState: Equatable {
  public static func == (lhs: LiveStreamViewControllerState, rhs: LiveStreamViewControllerState) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading):
      return true
    case (.greenRoom, .greenRoom):
      return true
    case (.live(let lhsPlaybackState, let lhsStartTime), .live(let rhsPlaybackState, let rhsStartTime)):
      return lhsPlaybackState == rhsPlaybackState && lhsStartTime == rhsStartTime
    case (.replay(let lhsPlaybackState, let lhsDuration), .replay(let rhsPlaybackState, let rhsDuration)):
      return lhsPlaybackState == rhsPlaybackState && lhsDuration == rhsDuration
    case (.error(let lhsError), .error(let rhsError)):
      return lhsError == rhsError
    case (.nonStarter, .nonStarter):
      return true
    case (.initializationFailed, .initializationFailed):
      return true
    case (.loading, _), (.greenRoom, _), (.live, _), (.replay, _), (.error, _), (.nonStarter, _),
         (.initializationFailed, _):
      return false
    }
  }
}
