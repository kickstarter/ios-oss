// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ValidateCheckoutQuery: GraphQLQuery {
  public static let operationName: String = "ValidateCheckout"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ValidateCheckout($checkoutId: ID!, $paymentSourceId: String!, $paymentIntentClientSecret: String!) { checkout(id: $checkoutId) { __typename isValidForOnSessionCheckout( stripePaymentMethodId: $paymentSourceId paymentIntentClientSecret: $paymentIntentClientSecret ) { __typename valid messages } } }"#
    ))

  public var checkoutId: ID
  public var paymentSourceId: String
  public var paymentIntentClientSecret: String

  public init(
    checkoutId: ID,
    paymentSourceId: String,
    paymentIntentClientSecret: String
  ) {
    self.checkoutId = checkoutId
    self.paymentSourceId = paymentSourceId
    self.paymentIntentClientSecret = paymentIntentClientSecret
  }

  public var __variables: Variables? { [
    "checkoutId": checkoutId,
    "paymentSourceId": paymentSourceId,
    "paymentIntentClientSecret": paymentIntentClientSecret
  ] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("checkout", Checkout?.self, arguments: ["id": .variable("checkoutId")]),
    ] }

    /// Fetches a checkout given its id.
    public var checkout: Checkout? { __data["checkout"] }

    public init(
      checkout: Checkout? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "checkout": checkout._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ValidateCheckoutQuery.Data.self)
        ]
      ))
    }

    /// Checkout
    ///
    /// Parent Type: `Checkout`
    public struct Checkout: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Checkout }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("isValidForOnSessionCheckout", IsValidForOnSessionCheckout.self, arguments: [
          "stripePaymentMethodId": .variable("paymentSourceId"),
          "paymentIntentClientSecret": .variable("paymentIntentClientSecret")
        ]),
      ] }

      /// Checks whether the checkout is valid prior to charging the user's card.
      public var isValidForOnSessionCheckout: IsValidForOnSessionCheckout { __data["isValidForOnSessionCheckout"] }

      public init(
        isValidForOnSessionCheckout: IsValidForOnSessionCheckout
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Checkout.typename,
            "isValidForOnSessionCheckout": isValidForOnSessionCheckout._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ValidateCheckoutQuery.Data.Checkout.self)
          ]
        ))
      }

      /// Checkout.IsValidForOnSessionCheckout
      ///
      /// Parent Type: `Validation`
      public struct IsValidForOnSessionCheckout: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Validation }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("valid", Bool.self),
          .field("messages", [String].self),
        ] }

        /// Whether a value is valid.
        public var valid: Bool { __data["valid"] }
        /// Error messages associated with the value
        public var messages: [String] { __data["messages"] }

        public init(
          valid: Bool,
          messages: [String]
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Validation.typename,
              "valid": valid,
              "messages": messages,
            ],
            fulfilledFragments: [
              ObjectIdentifier(ValidateCheckoutQuery.Data.Checkout.IsValidForOnSessionCheckout.self)
            ]
          ))
        }
      }
    }
  }
}
