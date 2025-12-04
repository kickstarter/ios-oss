// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ShippableLocationsForProjectQuery: GraphQLQuery {
  public static let operationName: String = "ShippableLocationsForProject"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ShippableLocationsForProject($id: Int!) { project(pid: $id) { __typename shippableCountriesExpanded { __typename ...LocationFragment } } }"#,
      fragments: [LocationFragment.self]
    ))

  public var id: Int

  public init(id: Int) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("project", Project?.self, arguments: ["pid": .variable("id")]),
    ] }

    /// Fetches a project given its slug or pid.
    public var project: Project? { __data["project"] }

    public init(
      project: Project? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "project": project._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ShippableLocationsForProjectQuery.Data.self)
        ]
      ))
    }

    /// Project
    ///
    /// Parent Type: `Project`
    public struct Project: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("shippableCountriesExpanded", [ShippableCountriesExpanded].self),
      ] }

      /// All countries in which this project has a shippable reward. Expands results to the country level (ie EU -> [ Austria, Belgium ...])Returns all countries if the project has an unrestricted reward. If this project has only digital or local rewards, returns an empty array.
      public var shippableCountriesExpanded: [ShippableCountriesExpanded] { __data["shippableCountriesExpanded"] }

      public init(
        shippableCountriesExpanded: [ShippableCountriesExpanded]
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Project.typename,
            "shippableCountriesExpanded": shippableCountriesExpanded._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ShippableLocationsForProjectQuery.Data.Project.self)
          ]
        ))
      }

      /// Project.ShippableCountriesExpanded
      ///
      /// Parent Type: `Location`
      public struct ShippableCountriesExpanded: GraphAPI.SelectionSet {
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

        public init(
          country: String,
          countryName: String? = nil,
          displayableName: String,
          id: GraphAPI.ID,
          name: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Location.typename,
              "country": country,
              "countryName": countryName,
              "displayableName": displayableName,
              "id": id,
              "name": name,
            ],
            fulfilledFragments: [
              ObjectIdentifier(ShippableLocationsForProjectQuery.Data.Project.ShippableCountriesExpanded.self),
              ObjectIdentifier(LocationFragment.self)
            ]
          ))
        }
      }
    }
  }
}
