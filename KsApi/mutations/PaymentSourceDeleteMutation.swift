import Foundation

public struct PaymentSourceDeleteMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    let desc = """
    mutation paymentSourceDelete($input: PaymentSourceDeleteInput!) {
      paymentSourceDelete(input: $input) {
        clientMutationId
        user {
          storedCards {
            nodes {
              expirationDate
              id
              lastFour
              type
            }
          }
        }
      }
    }
    """

    return desc
  }
}
