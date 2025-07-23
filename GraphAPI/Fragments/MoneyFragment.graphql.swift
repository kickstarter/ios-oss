// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MoneyFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment MoneyFragment on Money { __typename amount currency symbol }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("amount", String?.self),
    .field("currency", GraphQLEnum<GraphAPI.CurrencyCode>?.self),
    .field("symbol", String?.self),
  ] }

  /// Floating-point numeric value of monetary amount represented as a string
  public var amount: String? { __data["amount"] }
  /// Currency of the monetary amount
  public var currency: GraphQLEnum<GraphAPI.CurrencyCode>? { __data["currency"] }
  /// Symbol of the currency in which the monetary amount appears
  public var symbol: String? { __data["symbol"] }

  public init(
    amount: String? = nil,
    currency: GraphQLEnum<GraphAPI.CurrencyCode>? = nil,
    symbol: String? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Money.typename,
        "amount": amount,
        "currency": currency,
        "symbol": symbol,
      ],
      fulfilledFragments: [
        ObjectIdentifier(MoneyFragment.self)
      ]
    ))
  }
}
