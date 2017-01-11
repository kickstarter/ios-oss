import Foundation

public enum LiveVideoPlaybackError {
  case failedToConnect
  case sessionInterrupted
}

public enum LiveVideoPlaybackState: Equatable {
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

public func == (lhs: LiveVideoPlaybackState, rhs: LiveVideoPlaybackState) -> Bool {
  switch (lhs, rhs) {
  case (.loading, .loading): return true
  case (.playing, .playing): return true
  case (.error(let lhsError), .error(let rhsError)):
    return lhsError == rhsError
  default:
    return false
  }
}

public enum LiveStreamType: Equatable {
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
    default:                            return nil
    }
  }
}

public func == (lhs: LiveStreamType, rhs: LiveStreamType) -> Bool {
  switch (lhs, rhs) {
  case (.hlsStream(let lhsHLSStreamUrl), .hlsStream(let rhsHLSStreamUrl)):
    return lhsHLSStreamUrl == rhsHLSStreamUrl

  case (.openTok(let lhsSessionConfig), .openTok(let rhsSessionConfig)):
    return lhsSessionConfig.apiKey == rhsSessionConfig.apiKey
      && lhsSessionConfig.sessionId == rhsSessionConfig.sessionId
      && lhsSessionConfig.token == rhsSessionConfig.token

  default:
    return false
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
public enum LiveStreamViewControllerState: Equatable {
  case error(error: LiveVideoPlaybackError)
  case greenRoom
  case initializationFailed
  case live(playbackState: LiveVideoPlaybackState, startTime: TimeInterval)
  case loading
  case nonStarter
  case replay(playbackState: LiveVideoPlaybackState, duration: TimeInterval)
}

public func == (lhs: LiveStreamViewControllerState, rhs: LiveStreamViewControllerState) -> Bool {
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
  default:
    return false
  }
}
