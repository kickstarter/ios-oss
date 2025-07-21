// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PledgeOverTimeFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PledgeOverTimeFragment on Project { __typename isPledgeOverTimeAllowed pledgeOverTimeCollectionPlanChargeExplanation pledgeOverTimeCollectionPlanChargedAsNPayments pledgeOverTimeCollectionPlanShortPitch pledgeOverTimeMinimumExplanation }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("isPledgeOverTimeAllowed", Bool.self),
    .field("pledgeOverTimeCollectionPlanChargeExplanation", String?.self),
    .field("pledgeOverTimeCollectionPlanChargedAsNPayments", String?.self),
    .field("pledgeOverTimeCollectionPlanShortPitch", String?.self),
    .field("pledgeOverTimeMinimumExplanation", String?.self),
  ] }

  /// Whether a project is enrolled in plot
  public var isPledgeOverTimeAllowed: Bool { __data["isPledgeOverTimeAllowed"] }
  /// Backer-facing summary of when the incremental charges will occur
  public var pledgeOverTimeCollectionPlanChargeExplanation: String? { __data["pledgeOverTimeCollectionPlanChargeExplanation"] }
  /// Quick summary of the amount of increments pledges will be spread over
  public var pledgeOverTimeCollectionPlanChargedAsNPayments: String? { __data["pledgeOverTimeCollectionPlanChargedAsNPayments"] }
  /// Backer-facing short summary of this project's number of payment increments to split over
  public var pledgeOverTimeCollectionPlanShortPitch: String? { __data["pledgeOverTimeCollectionPlanShortPitch"] }
  /// The minimum pledge amount to be eligible for PLOT, localized to the project currency and backer language
  public var pledgeOverTimeMinimumExplanation: String? { __data["pledgeOverTimeMinimumExplanation"] }

  public init(
    isPledgeOverTimeAllowed: Bool,
    pledgeOverTimeCollectionPlanChargeExplanation: String? = nil,
    pledgeOverTimeCollectionPlanChargedAsNPayments: String? = nil,
    pledgeOverTimeCollectionPlanShortPitch: String? = nil,
    pledgeOverTimeMinimumExplanation: String? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Project.typename,
        "isPledgeOverTimeAllowed": isPledgeOverTimeAllowed,
        "pledgeOverTimeCollectionPlanChargeExplanation": pledgeOverTimeCollectionPlanChargeExplanation,
        "pledgeOverTimeCollectionPlanChargedAsNPayments": pledgeOverTimeCollectionPlanChargedAsNPayments,
        "pledgeOverTimeCollectionPlanShortPitch": pledgeOverTimeCollectionPlanShortPitch,
        "pledgeOverTimeMinimumExplanation": pledgeOverTimeMinimumExplanation,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PledgeOverTimeFragment.self)
      ]
    ))
  }
}
