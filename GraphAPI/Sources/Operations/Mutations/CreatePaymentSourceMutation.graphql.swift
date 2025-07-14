// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreatePaymentSourceMutation: GraphQLMutation {
  public static let operationName: String = "CreatePaymentSource"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreatePaymentSource($input: CreatePaymentSourceInput!) { createPaymentSource(input: $input) { __typename clientMutationId isSuccessful paymentSource { __typename ...PaymentSourceFragment } } }"#,
      fragments: [PaymentSourceFragment.self]
    ))

  public var input: CreatePaymentSourceInput

  public init(input: CreatePaymentSourceInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createPaymentSource", CreatePaymentSource?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Create a payment source
    public var createPaymentSource: CreatePaymentSource? { __data["createPaymentSource"] }

    /// CreatePaymentSource
    ///
    /// Parent Type: `CreatePaymentSourcePayload`
    public struct CreatePaymentSource: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CreatePaymentSourcePayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("clientMutationId", String?.self),
        .field("isSuccessful", Bool.self),
        .field("paymentSource", PaymentSource?.self),
      ] }

      /// A unique identifier for the client performing the mutation.
      public var clientMutationId: String? { __data["clientMutationId"] }
      public var isSuccessful: Bool { __data["isSuccessful"] }
      public var paymentSource: PaymentSource? { __data["paymentSource"] }

      /// CreatePaymentSource.PaymentSource
      ///
      /// Parent Type: `CreditCard`
      public struct PaymentSource: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CreditCard }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(PaymentSourceFragment.self),
        ] }

        /// When the credit card expires.
        public var expirationDate: GraphAPI.Date { __data["expirationDate"] }
        /// The card ID
        public var id: String { __data["id"] }
        /// The last four digits of the credit card number.
        public var lastFour: String { __data["lastFour"] }
        /// The card's payment type.
        public var paymentType: GraphQLEnum<GraphAPI.CreditCardPaymentType> { __data["paymentType"] }
        /// The card type.
        public var type: GraphQLEnum<GraphAPI.CreditCardTypes> { __data["type"] }
        /// Stripe card id
        public var stripeCardId: String { __data["stripeCardId"] }

        public var asBankAccount: AsBankAccount? { _asInlineFragment() }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var paymentSourceFragment: PaymentSourceFragment { _toFragment() }
        }

        /// CreatePaymentSource.PaymentSource.AsBankAccount
        ///
        /// Parent Type: `BankAccount`
        public struct AsBankAccount: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = CreatePaymentSourceMutation.Data.CreatePaymentSource.PaymentSource
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.BankAccount }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            CreatePaymentSourceMutation.Data.CreatePaymentSource.PaymentSource.self,
            PaymentSourceFragment.AsCreditCard.self,
            PaymentSourceFragment.AsBankAccount.self
          ] }

          /// When the credit card expires.
          public var expirationDate: GraphAPI.Date { __data["expirationDate"] }
          public var id: String { __data["id"] }
          /// The last four digits of the account number.
          public var lastFour: String { __data["lastFour"] }
          /// The card's payment type.
          public var paymentType: GraphQLEnum<GraphAPI.CreditCardPaymentType> { __data["paymentType"] }
          /// The card type.
          public var type: GraphQLEnum<GraphAPI.CreditCardTypes> { __data["type"] }
          /// Stripe card id
          public var stripeCardId: String { __data["stripeCardId"] }
          /// The bank name if available.
          public var bankName: String? { __data["bankName"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var paymentSourceFragment: PaymentSourceFragment { _toFragment() }
          }
        }
      }
    }
  }
}
