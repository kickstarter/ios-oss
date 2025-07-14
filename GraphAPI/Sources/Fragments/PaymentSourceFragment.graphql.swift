// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PaymentSourceFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PaymentSourceFragment on PaymentSource { __typename ... on CreditCard { expirationDate id lastFour paymentType type stripeCardId } ... on BankAccount { id lastFour bankName } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Unions.PaymentSource }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .inlineFragment(AsCreditCard.self),
    .inlineFragment(AsBankAccount.self),
  ] }

  public var asCreditCard: AsCreditCard? { _asInlineFragment() }
  public var asBankAccount: AsBankAccount? { _asInlineFragment() }

  public init(
    __typename: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": __typename,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PaymentSourceFragment.self)
      ]
    ))
  }

  /// AsCreditCard
  ///
  /// Parent Type: `CreditCard`
  public struct AsCreditCard: GraphAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = PaymentSourceFragment
    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CreditCard }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("expirationDate", GraphAPI.Date.self),
      .field("id", String.self),
      .field("lastFour", String.self),
      .field("paymentType", GraphQLEnum<GraphAPI.CreditCardPaymentType>.self),
      .field("type", GraphQLEnum<GraphAPI.CreditCardTypes>.self),
      .field("stripeCardId", String.self),
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

    public init(
      expirationDate: GraphAPI.Date,
      id: String,
      lastFour: String,
      paymentType: GraphQLEnum<GraphAPI.CreditCardPaymentType>,
      type: GraphQLEnum<GraphAPI.CreditCardTypes>,
      stripeCardId: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.CreditCard.typename,
          "expirationDate": expirationDate,
          "id": id,
          "lastFour": lastFour,
          "paymentType": paymentType,
          "type": type,
          "stripeCardId": stripeCardId,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PaymentSourceFragment.self),
          ObjectIdentifier(PaymentSourceFragment.AsCreditCard.self)
        ]
      ))
    }
  }

  /// AsBankAccount
  ///
  /// Parent Type: `BankAccount`
  public struct AsBankAccount: GraphAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = PaymentSourceFragment
    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.BankAccount }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("id", String.self),
      .field("lastFour", String.self),
      .field("bankName", String?.self),
    ] }

    public var id: String { __data["id"] }
    /// The last four digits of the account number.
    public var lastFour: String { __data["lastFour"] }
    /// The bank name if available.
    public var bankName: String? { __data["bankName"] }

    public init(
      id: String,
      lastFour: String,
      bankName: String? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.BankAccount.typename,
          "id": id,
          "lastFour": lastFour,
          "bankName": bankName,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PaymentSourceFragment.self),
          ObjectIdentifier(PaymentSourceFragment.AsBankAccount.self)
        ]
      ))
    }
  }
}
