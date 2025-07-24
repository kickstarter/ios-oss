// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class BuildPaymentPlanQuery: GraphQLQuery {
  public static let operationName: String = "BuildPaymentPlan"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query BuildPaymentPlan($slug: String!, $amount: String!, $includeRefundedAmount: Boolean!) { project(slug: $slug) { __typename paymentPlan(amount: $amount) { __typename amountIsPledgeOverTimeEligible paymentIncrements { __typename ...PaymentIncrementFragment } } } }"#,
      fragments: [PaymentIncrementFragment.self]
    ))

  public var slug: String
  public var amount: String
  public var includeRefundedAmount: Bool

  public init(
    slug: String,
    amount: String,
    includeRefundedAmount: Bool
  ) {
    self.slug = slug
    self.amount = amount
    self.includeRefundedAmount = includeRefundedAmount
  }

  public var __variables: Variables? { [
    "slug": slug,
    "amount": amount,
    "includeRefundedAmount": includeRefundedAmount
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

    public init(
      project: Project? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "project": project._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(BuildPaymentPlanQuery.Data.self)
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
        .field("paymentPlan", PaymentPlan?.self, arguments: ["amount": .variable("amount")]),
      ] }

      /// Build a payment plan given a project id and amount
      public var paymentPlan: PaymentPlan? { __data["paymentPlan"] }

      public init(
        paymentPlan: PaymentPlan? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Project.typename,
            "paymentPlan": paymentPlan._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(BuildPaymentPlanQuery.Data.Project.self)
          ]
        ))
      }

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

        public init(
          amountIsPledgeOverTimeEligible: Bool,
          paymentIncrements: [PaymentIncrement]? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.PaymentPlan.typename,
              "amountIsPledgeOverTimeEligible": amountIsPledgeOverTimeEligible,
              "paymentIncrements": paymentIncrements._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(BuildPaymentPlanQuery.Data.Project.PaymentPlan.self)
            ]
          ))
        }

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
          /// The total amount that has been refunded on the payment increment, across potentially multiple adjustments
          public var refundedAmount: RefundedAmount? { __data["refundedAmount"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var paymentIncrementFragment: PaymentIncrementFragment { _toFragment() }
          }

          public init(
            amount: Amount,
            scheduledCollection: GraphAPI.ISO8601DateTime,
            state: GraphQLEnum<GraphAPI.PaymentIncrementState>,
            stateReason: GraphQLEnum<GraphAPI.PaymentIncrementStateReason>? = nil,
            refundedAmount: RefundedAmount? = nil
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.PaymentIncrement.typename,
                "amount": amount._fieldData,
                "scheduledCollection": scheduledCollection,
                "state": state,
                "stateReason": stateReason,
                "refundedAmount": refundedAmount._fieldData,
              ],
              fulfilledFragments: [
                ObjectIdentifier(BuildPaymentPlanQuery.Data.Project.PaymentPlan.PaymentIncrement.self),
                ObjectIdentifier(PaymentIncrementFragment.self)
              ]
            ))
          }

          public typealias Amount = PaymentIncrementFragment.Amount

          public typealias RefundedAmount = PaymentIncrementFragment.RefundedAmount
        }
      }
    }
  }
}
