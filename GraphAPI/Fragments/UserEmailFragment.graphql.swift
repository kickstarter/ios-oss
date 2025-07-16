// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct UserEmailFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment UserEmailFragment on User { __typename email }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("email", String?.self),
  ] }

  /// A user's email address.
  public var email: String? { __data["email"] }

  public init(
    email: String? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.User.typename,
        "email": email,
      ],
      fulfilledFragments: [
        ObjectIdentifier(UserEmailFragment.self)
      ]
    ))
  }
}
