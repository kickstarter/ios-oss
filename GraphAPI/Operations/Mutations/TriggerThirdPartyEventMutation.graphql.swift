// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  class TriggerThirdPartyEventMutation: GraphQLMutation {
    public static let operationName: String = "triggerThirdPartyEvent"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation triggerThirdPartyEvent($input: TriggerThirdPartyEventInput!) { triggerThirdPartyEvent(input: $input) { __typename success } }"#
      ))

    public var input: TriggerThirdPartyEventInput

    public init(input: TriggerThirdPartyEventInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("triggerThirdPartyEvent", TriggerThirdPartyEvent?.self, arguments: ["input": .variable("input")]),
      ] }

      /// Triggers third party event
      public var triggerThirdPartyEvent: TriggerThirdPartyEvent? { __data["triggerThirdPartyEvent"] }

      /// TriggerThirdPartyEvent
      ///
      /// Parent Type: `TriggerThirdPartyEventPayload`
      public struct TriggerThirdPartyEvent: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.TriggerThirdPartyEventPayload }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("success", Bool.self),
        ] }

        public var success: Bool { __data["success"] }
      }
    }
  }

}