// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PaymentIncrementFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PaymentIncrementFragment on PaymentIncrement { __typename amount { __typename amountFormattedInProjectNativeCurrency currency } scheduledCollection }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PaymentIncrement }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("amount", Amount.self),
    .field("scheduledCollection", GraphAPI.ISO8601DateTime.self),
  ] }

  /// The payment increment amount represented in various formats
  public var amount: Amount { __data["amount"] }
  public var scheduledCollection: GraphAPI.ISO8601DateTime { __data["scheduledCollection"] }

  public init(
    amount: Amount,
    scheduledCollection: GraphAPI.ISO8601DateTime
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.PaymentIncrement.typename,
        "amount": amount._fieldData,
        "scheduledCollection": scheduledCollection,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PaymentIncrementFragment.self)
      ]
    ))
  }

  /// Amount
  ///
  /// Parent Type: `PaymentIncrementAmount`
  public struct Amount: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PaymentIncrementAmount }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("amountFormattedInProjectNativeCurrency", String.self),
      .field("currency", String.self),
    ] }

    /// The increment amount represented as a float with the currency symbol, ie $37.50
    public var amountFormattedInProjectNativeCurrency: String { __data["amountFormattedInProjectNativeCurrency"] }
    /// A three-letter currency code for the increment (ie the currency of the project)
    public var currency: String { __data["currency"] }

    public init(
      amountFormattedInProjectNativeCurrency: String,
      currency: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.PaymentIncrementAmount.typename,
          "amountFormattedInProjectNativeCurrency": amountFormattedInProjectNativeCurrency,
          "currency": currency,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PaymentIncrementFragment.Amount.self)
        ]
      ))
    }
  }
}
