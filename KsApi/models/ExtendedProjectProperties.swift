import Foundation
/**
 TODO:
 This model is meant to replace `Project` which has almost been converted to use GraphQL properties.

 We're not replacing it completely right now because it has a lot of large dependencies to other models (`Backing`, `User`, `Reward`).

 Also a lot of `/v1/` endpoints still use this model so we cannot completely clean-up/remove/re-think and adjust in-app functionality to address each property's use-cases.

 This property will eventually replace `Project`, but right now we're using it to build out additional functionality that only comes from GraphQL.
 */

public struct ExtendedProjectProperties {
  public var environmentalCommitments: [ProjectEnvironmentalCommitment]
  public var faqs: [ProjectFAQ]
  public var risks: String
  public var story: ProjectStoryElements
  public var minimumPledgeAmount: Int
}

public struct ProjectFAQ {
  public var answer: String
  public var question: String
  public var id: Int
  public var createdAt: TimeInterval?
}

public struct ProjectStoryElements {
  public var htmlViewElements: [HTMLViewElement]
}

public struct ProjectEnvironmentalCommitment {
  public var description: String
  public var category: ProjectCommitmentCategory
  public var id: Int
}

public enum ProjectCommitmentCategory: String {
  case longLastingDesign = "Long-lasting design"
  case sustainableMaterials = "Sustainable materials"
  case environmentallyFriendlyFactories = "Environmentally friendly factories"
  case sustainableDistribution = "Sustainable distribution"
  case reusabilityAndRecyclability = "Reusability and Recyclability"
  case somethingElse
}
