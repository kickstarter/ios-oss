import Foundation
import ReactiveSwift

extension UpdateUserEnvelope {
  /**
   Map `GraphAPI.UpdateUserAccountMutation.Data` to a `UpdateUserEnvelope`, otherwise return `nil`
   */
  static func from(_ data: GraphAPI.UpdateUserAccountMutation.Data) -> UpdateUserEnvelope? {
    guard let updateUserAccount = data.updateUserAccount else {
      return nil
    }

    return UpdateUserEnvelope(clientMutationId: updateUserAccount.clientMutationId)
  }
  
  /**
   Map `GraphAPI.UpdateUserProfileMutation.Data` to a `UpdateUserEnvelope`, otherwise return `nil`
   */
  static func from(_ data: GraphAPI.UpdateUserProfileMutation.Data) -> UpdateUserEnvelope? {
    guard let updateUserProfile = data.updateUserProfile else {
      return nil
    }

    return UpdateUserEnvelope(clientMutationId: updateUserProfile.clientMutationId)
  }

  /**
   Return a signal producer containing `UpdateUserEnvelope` or `ErrorEnvelope` from a `GraphAPI.UpdateUserAccountMutation`
   */
  static func producer(from data: GraphAPI.UpdateUserAccountMutation
    .Data) -> SignalProducer<UpdateUserEnvelope, ErrorEnvelope> {
    guard let envelope = UpdateUserEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
  
  /**
   Return a signal producer containing `UpdateUserEnvelope` or `ErrorEnvelope` from a `GraphAPI.UpdateUserProfileMutation`
   */
  static func producer(from data: GraphAPI.UpdateUserProfileMutation
    .Data) -> SignalProducer<UpdateUserEnvelope, ErrorEnvelope> {
    guard let envelope = UpdateUserEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
}
