// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchRootCategoriesQuery: GraphQLQuery {
  public static let operationName: String = "FetchRootCategories"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchRootCategories { rootCategories { __typename id name analyticsName subcategories { __typename nodes { __typename ...CategoryFragment parentId totalProjectCount } totalCount } totalProjectCount } }"#,
      fragments: [CategoryFragment.self]
    ))

  public init() {}

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("rootCategories", [RootCategory].self),
    ] }

    /// Root project categories.
    public var rootCategories: [RootCategory] { __data["rootCategories"] }

    /// RootCategory
    ///
    /// Parent Type: `Category`
    public struct RootCategory: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Category }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GraphAPI.ID.self),
        .field("name", String.self),
        .field("analyticsName", String.self),
        .field("subcategories", Subcategories?.self),
        .field("totalProjectCount", Int.self),
      ] }

      public var id: GraphAPI.ID { __data["id"] }
      /// Category name.
      public var name: String { __data["name"] }
      /// Category name in English for analytics use.
      public var analyticsName: String { __data["analyticsName"] }
      /// Subcategories.
      public var subcategories: Subcategories? { __data["subcategories"] }
      public var totalProjectCount: Int { __data["totalProjectCount"] }

      /// RootCategory.Subcategories
      ///
      /// Parent Type: `CategorySubcategoriesConnection`
      public struct Subcategories: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CategorySubcategoriesConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
          .field("totalCount", Int.self),
        ] }

        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }
        public var totalCount: Int { __data["totalCount"] }

        /// RootCategory.Subcategories.Node
        ///
        /// Parent Type: `Category`
        public struct Node: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Category }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("parentId", GraphAPI.ID?.self),
            .field("totalProjectCount", Int.self),
            .fragment(CategoryFragment.self),
          ] }

          /// Parent id of the category.
          public var parentId: GraphAPI.ID? { __data["parentId"] }
          public var totalProjectCount: Int { __data["totalProjectCount"] }
          public var id: GraphAPI.ID { __data["id"] }
          /// Category name.
          public var name: String { __data["name"] }
          /// Category name in English for analytics use.
          public var analyticsName: String { __data["analyticsName"] }
          /// Category parent
          public var parentCategory: ParentCategory? { __data["parentCategory"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var categoryFragment: CategoryFragment { _toFragment() }
          }

          public typealias ParentCategory = CategoryFragment.ParentCategory
        }
      }
    }
  }
}
