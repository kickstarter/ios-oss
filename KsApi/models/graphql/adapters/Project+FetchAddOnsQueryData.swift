import Foundation
import ReactiveSwift

extension Project {
  static func projectProducer(
    from data: GraphAPI.FetchAddOnsQuery.Data
  ) -> SignalProducer<Project, ErrorEnvelope> {
    guard let project = Project.project(from: data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: project)
  }

  static func project(from data: GraphAPI.FetchAddOnsQuery.Data) -> Project? {
    let addOns = data.project?.addOns?.nodes?
      .compactMap { node -> (GraphAPI.RewardFragment, [ShippingRule]?)? in
        guard let rewardFragment = node?.fragments.rewardFragment else { return nil }

        let expandedShippingRules = node?.shippingRulesExpanded?.nodes?
          .compactMap { node in node?.fragments.shippingRuleFragment }
          .compactMap(ShippingRule.shippingRule(from:))

        return (rewardFragment, expandedShippingRules)
      }
      .compactMap { fragment, expandedShippingRules in
        Reward.reward(from: fragment, expandedShippingRules: expandedShippingRules)
      }

    guard
      let fragment = data.project?.fragments.projectFragment,
      let project = Project.project(from: fragment, addOns: addOns, currentUserChosenCurrency: nil)
    else { return nil }

    return project
  }
}
