import Foundation
import KsApi
import Library

enum ReportProjectInfoListItemType {
  case child
  case parent
}

struct ReportProjectInfoListItem: Identifiable, Hashable {
  var id = UUID()
  var type: ReportProjectInfoListItemType
  var flaggingKind: GraphAPI.FlaggingKind?
  var title: String
  var subtitle: String
  var subItems: [ReportProjectInfoListItem]?
  var exampleMenuItems: [ReportProjectInfoListItem]?
}

/// Hierarchical structure of the ReportProjectInfo List View
let listItems =
  [
    ReportProjectInfoListItem(
      type: .parent,
      title: Strings.This_project_breaks(),
      subtitle: Strings
        .Projects_may_not_offer(prohibited_items: HelpType.prohibitedItems
          .url(withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl)?.absoluteString ?? ""),
      subItems: thisProjecBreaksSubListItems
    ),
    ReportProjectInfoListItem(
      type: .parent,
      title: Strings.Report_spam(),
      subtitle: Strings
        .Our(community_guidelines: HelpType.prohibitedItems
          .url(withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl)?.absoluteString ?? ""),
      subItems: reportSpamSubListItems

    ),
    ReportProjectInfoListItem(
      type: .parent,
      title: Strings.Intellectual_property_violation(),
      subtitle: Strings.A_project_is_infringing(),
      subItems: intellectualProperySubListItems
    )
  ]

//// Sub items for This project breaks Our Rules
let thisProjecBreaksSubListItems =
  [
    ReportProjectInfoListItem(
      type: .child,
      flaggingKind: .plagiarism,
      title: Strings.Copying_reselling(),
      subtitle: Strings.Projects_cannot_plagiarize()
    ),
    ReportProjectInfoListItem(
      type: .child,
      flaggingKind: .guidelinesViolation,
      title: Strings.Prototype_misrepresentation(),
      subtitle: Strings.Creators_must_be_transparent()
    ),
    ReportProjectInfoListItem(
      type: .child,
      flaggingKind: .guidelinesViolation,
      title: Strings.Suspicious_creator_behavior(),
      subtitle: Strings.Project_creators_and_their()
    ),
    ReportProjectInfoListItem(
      type: .child,
      flaggingKind: .guidelinesViolation,
      title: Strings.Not_raising_funds(),
      subtitle: Strings.Projects_on()
    )
  ]

//// Sub items for Report spam
let reportSpamSubListItems = [
  ReportProjectInfoListItem(
    type: .child,
    flaggingKind: .spam,
    title: Strings.Spam(),
    subtitle: Strings.Ex_using()
  ),
  ReportProjectInfoListItem(
    type: .child,
    flaggingKind: .abuse,
    title: Strings.Abuse(),
    subtitle: Strings.Ex_posting()
  )
]

//// Sub items for intellectual property
let intellectualProperySubListItems = [
  ReportProjectInfoListItem(
    type: .child,
    flaggingKind: .notProjectOther,
    title: Strings.Intellectual_property_violation(),
    subtitle: Strings.Kickstarter_takes_claims()
  )
]
