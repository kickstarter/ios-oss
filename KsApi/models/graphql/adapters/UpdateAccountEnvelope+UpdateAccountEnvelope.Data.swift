import Foundation
import ReactiveSwift

extension UpdateAccountEnvelope {
  static func from(_ data: GraphAPI.UpdateUserAccountMutation.Data) -> UpdateAccountEnvelope? {
    guard let updateUserAccount = data.updateUserAccount else {
      return nil
    }

    return UpdateAccountEnvelope(clientMutationId: updateUserAccount.clientMutationId)
  }

  static func producer(from data: GraphAPI.UpdateUserAccountMutation
    .Data) -> SignalProducer<UpdateAccountEnvelope, ErrorEnvelope> {
    guard let envelope = UpdateAccountEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
}
