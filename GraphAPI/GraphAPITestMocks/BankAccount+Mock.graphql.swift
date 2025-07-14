// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class BankAccount: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.BankAccount
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<BankAccount>>

  public struct MockFields {
    @Field<String>("bankName") public var bankName
    @Field<String>("id") public var id
    @Field<String>("lastFour") public var lastFour
  }
}

public extension Mock where O == BankAccount {
  convenience init(
    bankName: String? = nil,
    id: String? = nil,
    lastFour: String? = nil
  ) {
    self.init()
    _setScalar(bankName, for: \.bankName)
    _setScalar(id, for: \.id)
    _setScalar(lastFour, for: \.lastFour)
  }
}
