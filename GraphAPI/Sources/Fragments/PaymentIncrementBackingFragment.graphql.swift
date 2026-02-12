// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PaymentIncrementBackingFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PaymentIncrementBackingFragment on PaymentIncrement { __typename amount { __typename amountFormattedInProjectNativeCurrency currency } badge { __typename copy variant } scheduledCollection state refundUpdatedAmountInProjectNativeCurrency refundedAmount { __typename currency } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PaymentIncrement }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("amount", Amount.self),
    .field("badge", Badge?.self),
    .field("scheduledCollection", GraphAPI.ISO8601DateTime.self),
    .field("state", GraphQLEnum<GraphAPI.PaymentIncrementState>.self),
    .field("refundUpdatedAmountInProjectNativeCurrency", String?.self),
    .field("refundedAmount", RefundedAmount?.self),
  ] }

  /// The payment increment amount represented in various formats
  public var amount: Amount { __data["amount"] }
  /// If the payment increment has a backing, return human-readable information about the status of the payment increment
  public var badge: Badge? { __data["badge"] }
  public var scheduledCollection: GraphAPI.ISO8601DateTime { __data["scheduledCollection"] }
  /// The state of the payment increment
  public var state: GraphQLEnum<GraphAPI.PaymentIncrementState> { __data["state"] }
  /// The original amount minus the refunded amount formatted in the project native currency
  public var refundUpdatedAmountInProjectNativeCurrency: String? { __data["refundUpdatedAmountInProjectNativeCurrency"] }
  /// The total amount that has been refunded on the payment increment, across potentially multiple adjustments
  public var refundedAmount: RefundedAmount? { __data["refundedAmount"] }

  public init(
    amount: Amount,
    badge: Badge? = nil,
    scheduledCollection: GraphAPI.ISO8601DateTime,
    state: GraphQLEnum<GraphAPI.PaymentIncrementState>,
    refundUpdatedAmountInProjectNativeCurrency: String? = nil,
    refundedAmount: RefundedAmount? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.PaymentIncrement.typename,
        "amount": amount._fieldData,
        "badge": badge._fieldData,
        "scheduledCollection": scheduledCollection,
        "state": state,
        "refundUpdatedAmountInProjectNativeCurrency": refundUpdatedAmountInProjectNativeCurrency,
        "refundedAmount": refundedAmount._fieldData,
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

  /// Badge
  ///
  /// Parent Type: `PaymentIncrementBadge`
  public struct Badge: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PaymentIncrementBadge }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("copy", String.self),
      .field("variant", GraphQLEnum<GraphAPI.PaymentIncrementBadgeVariant>.self),
    ] }

    /// The title of the badge, representing the payment increment status
    public var copy: String { __data["copy"] }
    /// The variant of the badge, representing how the payment increment status is styled
    public var variant: GraphQLEnum<GraphAPI.PaymentIncrementBadgeVariant> { __data["variant"] }

    public init(
      copy: String,
      variant: GraphQLEnum<GraphAPI.PaymentIncrementBadgeVariant>
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.PaymentIncrementBadge.typename,
          "copy": copy,
          "variant": variant,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PaymentIncrementBackingFragment.Badge.self)
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
