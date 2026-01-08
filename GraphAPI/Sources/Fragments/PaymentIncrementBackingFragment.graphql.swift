// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PaymentIncrementBackingFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PaymentIncrementBackingFragment on PaymentIncrement { __typename amount { __typename amountFormattedInProjectNativeCurrency currency } scheduledCollection state stateReason refundUpdatedAmountInProjectNativeCurrency refundedAmount { __typename currency } stateBadgeName stateBadgeStyle }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PaymentIncrement }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("amount", Amount.self),
    .field("scheduledCollection", GraphAPI.ISO8601DateTime.self),
    .field("state", GraphQLEnum<GraphAPI.PaymentIncrementState>.self),
    .field("stateReason", GraphQLEnum<GraphAPI.PaymentIncrementStateReason>?.self),
    .field("refundUpdatedAmountInProjectNativeCurrency", String?.self),
    .field("refundedAmount", RefundedAmount?.self),
    .field("stateBadgeName", String?.self),
    .field("stateBadgeStyle", String?.self),
  ] }

  /// The payment increment amount represented in various formats
  public var amount: Amount { __data["amount"] }
  public var scheduledCollection: GraphAPI.ISO8601DateTime { __data["scheduledCollection"] }
  /// The state of the payment increment
  public var state: GraphQLEnum<GraphAPI.PaymentIncrementState> { __data["state"] }
  public var stateReason: GraphQLEnum<GraphAPI.PaymentIncrementStateReason>? { __data["stateReason"] }
  /// The original amount minus the refunded amount formatted in the project native currency
  public var refundUpdatedAmountInProjectNativeCurrency: String? { __data["refundUpdatedAmountInProjectNativeCurrency"] }
  /// The total amount that has been refunded on the payment increment, across potentially multiple adjustments
  public var refundedAmount: RefundedAmount? { __data["refundedAmount"] }
  /// A short, localized, user-readable string describing the payment increment.
  public var stateBadgeName: String? { __data["stateBadgeName"] }
  /// badge color
  public var stateBadgeStyle: String? { __data["stateBadgeStyle"] }

  public init(
    amount: Amount,
    scheduledCollection: GraphAPI.ISO8601DateTime,
    state: GraphQLEnum<GraphAPI.PaymentIncrementState>,
    stateReason: GraphQLEnum<GraphAPI.PaymentIncrementStateReason>? = nil,
    refundUpdatedAmountInProjectNativeCurrency: String? = nil,
    refundedAmount: RefundedAmount? = nil,
    stateBadgeName: String? = nil,
    stateBadgeStyle: String? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.PaymentIncrement.typename,
        "amount": amount._fieldData,
        "scheduledCollection": scheduledCollection,
        "state": state,
        "stateReason": stateReason,
        "refundUpdatedAmountInProjectNativeCurrency": refundUpdatedAmountInProjectNativeCurrency,
        "refundedAmount": refundedAmount._fieldData,
        "stateBadgeName": stateBadgeName,
        "stateBadgeStyle": stateBadgeStyle,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PaymentIncrementBackingFragment.self)
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
          ObjectIdentifier(PaymentIncrementBackingFragment.Amount.self)
        ]
      ))
    }
  }

  /// RefundedAmount
  ///
  /// Parent Type: `PaymentIncrementAmount`
  public struct RefundedAmount: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PaymentIncrementAmount }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("currency", String.self),
    ] }

    /// A three-letter currency code for the increment (ie the currency of the project)
    public var currency: String { __data["currency"] }

    public init(
      currency: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.PaymentIncrementAmount.typename,
          "currency": currency,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PaymentIncrementBackingFragment.RefundedAmount.self)
        ]
      ))
    }
  }
}
