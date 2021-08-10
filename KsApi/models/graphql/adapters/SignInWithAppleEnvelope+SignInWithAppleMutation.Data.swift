import Foundation
import ReactiveSwift

extension SignInWithAppleEnvelope {
  /**
   Map `GraphAPI.SignInWithAppleMutation.Data` to a `SignInWithAppleEnvelope`, otherwise return `nil`
   */
  static func from(_ data: GraphAPI.SignInWithAppleMutation.Data) -> SignInWithAppleEnvelope? {
    guard let signInWithApple = data.signInWithApple,
      let apiAccessToken = signInWithApple.apiAccessToken,
      let user = signInWithApple.user else {
      return nil
    }

    return SignInWithAppleEnvelope(signInWithApple: SignInWithApple(
      apiAccessToken: apiAccessToken,
      user: User(uid: user.uid)
    ))
  }

  /**
   Return a signal producer containing `SignInWithAppleEnvelope` or `ErrorEnvelope`
   */
  static func producer(from data: GraphAPI.SignInWithAppleMutation
    .Data) -> SignalProducer<SignInWithAppleEnvelope, ErrorEnvelope> {
    guard let envelope = SignInWithAppleEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
}
