// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  struct CategoryFragment: GraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment CategoryFragment on Category { __typename id name analyticsName parentCategory { __typename id name analyticsName } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Category }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", GraphAPI.ID.self),
      .field("name", String.self),
      .field("analyticsName", String.self),
      .field("parentCategory", ParentCategory?.self),
    ] }

    public var id: GraphAPI.ID { __data["id"] }
    /// Category name.
    public var name: String { __data["name"] }
    /// Category name in English for analytics use.
    public var analyticsName: String { __data["analyticsName"] }
    /// Category parent
    public var parentCategory: ParentCategory? { __data["parentCategory"] }

    /// ParentCategory
    ///
    /// Parent Type: `Category`
    public struct ParentCategory: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Category }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GraphAPI.ID.self),
        .field("name", String.self),
        .field("analyticsName", String.self),
      ] }

      public var id: GraphAPI.ID { __data["id"] }
      /// Category name.
      public var name: String { __data["name"] }
      /// Category name in English for analytics use.
      public var analyticsName: String { __data["analyticsName"] }
    }
  }

}