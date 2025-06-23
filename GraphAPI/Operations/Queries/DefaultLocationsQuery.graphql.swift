// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  class DefaultLocationsQuery: GraphQLQuery {
    public static let operationName: String = "DefaultLocations"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query DefaultLocations($first: Int) { locations(useSessionLocation: true, first: $first) { __typename nodes { __typename ...LocationFragment } } }"#,
        fragments: [LocationFragment.self]
      ))

    public var first: GraphQLNullable<Int>

    public init(first: GraphQLNullable<Int>) {
      self.first = first
    }

    public var __variables: Variables? { ["first": first] }

    public struct Data: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("locations", Locations?.self, arguments: [
          "useSessionLocation": true,
          "first": .variable("first")
        ]),
      ] }

      /// Searches locations.
      public var locations: Locations? { __data["locations"] }

      /// Locations
      ///
      /// Parent Type: `LocationsConnection`
      public struct Locations: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.LocationsConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
        ] }

        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        /// Locations.Node
        ///
        /// Parent Type: `Location`
        public struct Node: GraphAPI.SelectionSet {
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
      }
    }
  }

}