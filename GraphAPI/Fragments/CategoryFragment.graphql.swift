// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CategoryFragment: GraphAPI.SelectionSet, Fragment {
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

  public init(
    id: GraphAPI.ID,
    name: String,
    analyticsName: String,
    parentCategory: ParentCategory? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Category.typename,
        "id": id,
        "name": name,
        "analyticsName": analyticsName,
        "parentCategory": parentCategory._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CategoryFragment.self)
      ]
    ))
  }

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

    public init(
      id: GraphAPI.ID,
      name: String,
      analyticsName: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Category.typename,
          "id": id,
          "name": name,
          "analyticsName": analyticsName,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CategoryFragment.ParentCategory.self)
        ]
      ))
    }
  }
}
