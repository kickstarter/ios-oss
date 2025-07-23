// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchCategoryQuery: GraphQLQuery {
  public static let operationName: String = "FetchCategory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchCategory($id: ID!) { node(id: $id) { __typename ... on Category { analyticsName id name subcategories { __typename nodes { __typename ...CategoryFragment parentId totalProjectCount } totalCount } totalProjectCount } } }"#,
      fragments: [CategoryFragment.self]
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("node", Node?.self, arguments: ["id": .variable("id")]),
    ] }

    /// Fetches an object given its ID.
    public var node: Node? { __data["node"] }

    public init(
      node: Node? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "node": node._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(FetchCategoryQuery.Data.self)
        ]
      ))
    }

    /// Node
    ///
    /// Parent Type: `Node`
    public struct Node: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Interfaces.Node }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .inlineFragment(AsCategory.self),
      ] }

      public var asCategory: AsCategory? { _asInlineFragment() }

      public init(
        __typename: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
          ],
          fulfilledFragments: [
            ObjectIdentifier(FetchCategoryQuery.Data.Node.self)
          ]
        ))
      }

      /// Node.AsCategory
      ///
      /// Parent Type: `Category`
      public struct AsCategory: GraphAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = FetchCategoryQuery.Data.Node
        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Category }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("analyticsName", String.self),
          .field("id", GraphAPI.ID.self),
          .field("name", String.self),
          .field("subcategories", Subcategories?.self),
          .field("totalProjectCount", Int.self),
        ] }

        /// Category name in English for analytics use.
        public var analyticsName: String { __data["analyticsName"] }
        public var id: GraphAPI.ID { __data["id"] }
        /// Category name.
        public var name: String { __data["name"] }
        /// Subcategories.
        public var subcategories: Subcategories? { __data["subcategories"] }
        public var totalProjectCount: Int { __data["totalProjectCount"] }

        public init(
          analyticsName: String,
          id: GraphAPI.ID,
          name: String,
          subcategories: Subcategories? = nil,
          totalProjectCount: Int
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Category.typename,
              "analyticsName": analyticsName,
              "id": id,
              "name": name,
              "subcategories": subcategories._fieldData,
              "totalProjectCount": totalProjectCount,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchCategoryQuery.Data.Node.self),
              ObjectIdentifier(FetchCategoryQuery.Data.Node.AsCategory.self)
            ]
          ))
        }

        /// Node.AsCategory.Subcategories
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

          public init(
            nodes: [Node?]? = nil,
            totalCount: Int
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.CategorySubcategoriesConnection.typename,
                "nodes": nodes._fieldData,
                "totalCount": totalCount,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FetchCategoryQuery.Data.Node.AsCategory.Subcategories.self)
              ]
            ))
          }

          /// Node.AsCategory.Subcategories.Node
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

            public init(
              parentId: GraphAPI.ID? = nil,
              totalProjectCount: Int,
              id: GraphAPI.ID,
              name: String,
              analyticsName: String,
              parentCategory: ParentCategory? = nil
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.Category.typename,
                  "parentId": parentId,
                  "totalProjectCount": totalProjectCount,
                  "id": id,
                  "name": name,
                  "analyticsName": analyticsName,
                  "parentCategory": parentCategory._fieldData,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(FetchCategoryQuery.Data.Node.AsCategory.Subcategories.Node.self),
                  ObjectIdentifier(CategoryFragment.self)
                ]
              ))
            }

            public typealias ParentCategory = CategoryFragment.ParentCategory
          }
        }
      }
    }
  }
}
