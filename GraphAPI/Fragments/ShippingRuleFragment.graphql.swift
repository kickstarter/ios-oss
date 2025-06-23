// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  struct ShippingRuleFragment: GraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ShippingRuleFragment on ShippingRule { __typename cost { __typename ...MoneyFragment } id location { __typename ...LocationFragment } estimatedMin { __typename amount currency } estimatedMax { __typename amount currency } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ShippingRule }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("cost", Cost?.self),
      .field("id", GraphAPI.ID.self),
      .field("location", Location.self),
      .field("estimatedMin", EstimatedMin?.self),
      .field("estimatedMax", EstimatedMax?.self),
    ] }

    /// The shipping cost for this location.
    public var cost: Cost? { __data["cost"] }
    public var id: GraphAPI.ID { __data["id"] }
    /// The shipping location to which the rule pertains.
    public var location: Location { __data["location"] }
    /// The estimated minimum shipping cost
    public var estimatedMin: EstimatedMin? { __data["estimatedMin"] }
    /// The estimated maximum shipping cost
    public var estimatedMax: EstimatedMax? { __data["estimatedMax"] }

    /// Cost
    ///
    /// Parent Type: `Money`
    public struct Cost: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }

      /// Floating-point numeric value of monetary amount represented as a string
      public var amount: String? { __data["amount"] }
      /// Currency of the monetary amount
      public var currency: GraphQLEnum<GraphAPI.CurrencyCode>? { __data["currency"] }
      /// Symbol of the currency in which the monetary amount appears
      public var symbol: String? { __data["symbol"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var moneyFragment: MoneyFragment { _toFragment() }
      }
    }

    /// Location
    ///
    /// Parent Type: `Location`
    public struct Location: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Location }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(LocationFragment.self),
      ] }

      /// The country code.
      public var country: String { __data["country"] }
      /// The localized country name.
      public var countryName: String? { __data["countryName"] }
      /// The displayable name. It includes the state code for US cities. ex: 'Seattle, WA'
      public var displayableName: String { __data["displayableName"] }
      public var id: GraphAPI.ID { __data["id"] }
      /// The localized name
      public var name: String { __data["name"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var locationFragment: LocationFragment { _toFragment() }
      }
    }

    /// EstimatedMin
    ///
    /// Parent Type: `Money`
    public struct EstimatedMin: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("amount", String?.self),
        .field("currency", GraphQLEnum<GraphAPI.CurrencyCode>?.self),
      ] }

      /// Floating-point numeric value of monetary amount represented as a string
      public var amount: String? { __data["amount"] }
      /// Currency of the monetary amount
      public var currency: GraphQLEnum<GraphAPI.CurrencyCode>? { __data["currency"] }
    }

    /// EstimatedMax
    ///
    /// Parent Type: `Money`
    public struct EstimatedMax: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("amount", String?.self),
        .field("currency", GraphQLEnum<GraphAPI.CurrencyCode>?.self),
      ] }

      /// Floating-point numeric value of monetary amount represented as a string
      public var amount: String? { __data["amount"] }
      /// Currency of the monetary amount
      public var currency: GraphQLEnum<GraphAPI.CurrencyCode>? { __data["currency"] }
    }
  }

}