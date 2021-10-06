import Foundation
/**
 TODO:
 This model is meant to replace `Project` which has almost been converted to use GraphQL properties.

 We're not replacing it completely right now because it has a lot of large dependencies to other models (`Backing`, `User`, `Reward`).

 Also a lot of `/v1/` endpoints still use this model so we cannot completely clean-up/remove/re-think and adjust in-app functionality to address each property's use-cases.

 This property will eventually replace `Project`, but right now we're using it to build out additional functionality that only comes from GraphQL.
 */

public struct ExtendedProjectProperties: Decodable {
  public var environmentalCommitments: [EnvironmentalCommitment]
  public var faqs: [ProjectFAQ]
  public var risks: String
  public var story: String
  public var minimumPledgeAmount: Int

  public struct ProjectFAQ: Decodable {
    public var answer: String
    public var question: String
    public var id: Int
    public var createdAt: TimeInterval?
  }

  public struct EnvironmentalCommitment: Decodable {
    public var description: String
    public var category: CommitmentCategory
    public var id: Int
  }

  public enum CommitmentCategory: String, Decodable {
    case longLastingDesign
    case sustainableMaterials
    case environmentallyFriendlyFactories
    case sustainableDistribution
    case reusabilityAndRecyclability
    case somethingElse
  }
}
