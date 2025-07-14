// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class BuildPaymentPlanQuery: GraphQLQuery {
  public static let operationName: String = "BuildPaymentPlan"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query BuildPaymentPlan($slug: String!, $amount: String!) { project(slug: $slug) { __typename paymentPlan(amount: $amount) { __typename amountIsPledgeOverTimeEligible paymentIncrements { __typename ...PaymentIncrementFragment } } } }"#,
      fragments: [PaymentIncrementFragment.self]
    ))

  public var slug: String
  public var amount: String

  public init(
    slug: String,
    amount: String
  ) {
    self.slug = slug
    self.amount = amount
  }

  public var __variables: Variables? { [
    "slug": slug,
    "amount": amount
  ] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("project", Project?.self, arguments: ["slug": .variable("slug")]),
    ] }

    /// Fetches a project given its slug or pid.
    public var project: Project? { __data["project"] }

    /// Project
    ///
    /// Parent Type: `Project`
    public struct Project: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("paymentPlan", PaymentPlan?.self, arguments: ["amount": .variable("amount")]),
      ] }

      /// Build a payment plan given a project id and amount
      public var paymentPlan: PaymentPlan? { __data["paymentPlan"] }

      /// Project.PaymentPlan
      ///
      /// Parent Type: `PaymentPlan`
      public struct PaymentPlan: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PaymentPlan }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("amountIsPledgeOverTimeEligible", Bool.self),
          .field("paymentIncrements", [PaymentIncrement]?.self),
        ] }

        /// Amount is enough to qualify for pledge over time, if project allows
        public var amountIsPledgeOverTimeEligible: Bool { __data["amountIsPledgeOverTimeEligible"] }
        public var paymentIncrements: [PaymentIncrement]? { __data["paymentIncrements"] }

        /// Project.PaymentPlan.PaymentIncrement
        ///
        /// Parent Type: `PaymentIncrement`
        public struct PaymentIncrement: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PaymentIncrement }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(PaymentIncrementFragment.self),
          ] }

          /// The payment increment amount represented in various formats
          public var amount: Amount { __data["amount"] }
          public var scheduledCollection: GraphAPI.ISO8601DateTime { __data["scheduledCollection"] }
          public var state: GraphQLEnum<GraphAPI.PaymentIncrementState> { __data["state"] }
          public var stateReason: GraphQLEnum<GraphAPI.PaymentIncrementStateReason>? { __data["stateReason"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var paymentIncrementFragment: PaymentIncrementFragment { _toFragment() }
          }

          public typealias Amount = PaymentIncrementFragment.Amount
        }
      }
    }
  }
}
