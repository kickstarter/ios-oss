import Foundation

public enum OptimizelyFeature {
  public enum Key: String {
    case commentThreading = "ios_comment_threading"
    case commentFlagging = "ios_comment_threading_comment_flagging"
    case lightsOn = "ios_lights_on"
    case signInWithAppleKillswitch = "ios_sign_in_with_apple_killswitch"
  }
}
