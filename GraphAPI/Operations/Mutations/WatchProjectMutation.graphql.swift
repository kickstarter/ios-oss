// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class WatchProjectMutation: GraphQLMutation {
  public static let operationName: String = "watchProject"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation watchProject($input: WatchProjectInput!) { watchProject(input: $input) { __typename clientMutationId project { __typename id isWatched watchesCount } } }"#
    ))

  public var input: WatchProjectInput

  public init(input: WatchProjectInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("watchProject", WatchProject?.self, arguments: ["input": .variable("input")]),
    ] }

    public var watchProject: WatchProject? { __data["watchProject"] }

    public init(
      watchProject: WatchProject? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "watchProject": watchProject._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(WatchProjectMutation.Data.self)
        ]
      ))
    }

    /// WatchProject
    ///
    /// Parent Type: `WatchProjectPayload`
    public struct WatchProject: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.WatchProjectPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("clientMutationId", String?.self),
        .field("project", Project?.self),
      ] }

      /// A unique identifier for the client performing the mutation.
      public var clientMutationId: String? { __data["clientMutationId"] }
      public var project: Project? { __data["project"] }

      public init(
        clientMutationId: String? = nil,
        project: Project? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.WatchProjectPayload.typename,
            "clientMutationId": clientMutationId,
            "project": project._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(WatchProjectMutation.Data.WatchProject.self)
          ]
        ))
      }

      /// WatchProject.Project
      ///
      /// Parent Type: `Project`
      public struct Project: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GraphAPI.ID.self),
          .field("isWatched", Bool.self),
          .field("watchesCount", Int?.self),
        ] }

        public var id: GraphAPI.ID { __data["id"] }
        /// Is the current user watching this project?
        public var isWatched: Bool { __data["isWatched"] }
        /// Number of watchers a project has.
        public var watchesCount: Int? { __data["watchesCount"] }

        public init(
          id: GraphAPI.ID,
          isWatched: Bool,
          watchesCount: Int? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Project.typename,
              "id": id,
              "isWatched": isWatched,
              "watchesCount": watchesCount,
            ],
            fulfilledFragments: [
              ObjectIdentifier(WatchProjectMutation.Data.WatchProject.Project.self)
            ]
          ))
        }
      }
    }
  }
}
