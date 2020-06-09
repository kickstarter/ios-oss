import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias BoldedAttributedLabelData = (boldedString: String, inString: String)
public typealias FacepileViewData = (avatars: [URL], description: String)

public protocol DiscoveryProjectCardViewModelInputs {
  func configure(with value: DiscoveryProjectCellRowValue)
}

public protocol DiscoveryProjectCardViewModelOutputs {
  var backerCountLabelData: Signal<BoldedAttributedLabelData, Never> { get }
  var facepileViewData: Signal<FacepileViewData, Never> { get }
  var facepileViewHidden: Signal<Bool, Never> { get }
  var goalMetIconHidden: Signal<Bool, Never> { get }
  var loadProjectTags: Signal<[DiscoveryProjectTagPillCellValue], Never> { get }
  var percentFundedLabelData: Signal<BoldedAttributedLabelData, Never> { get }
  var projectBlurbLabelText: Signal<String, Never> { get }
  var projectImageURL: Signal<URL, Never> { get }
  var projectNameLabelText: Signal<String, Never> { get }
  var projectStatusIconImageName: Signal<String, Never> { get }
  var projectStatusLabelData: Signal<BoldedAttributedLabelData, Never> { get }
  var tagsCollectionViewHidden: Signal<Bool, Never> { get }
  var youreABackerViewHidden: Signal<Bool, Never> { get }
}

public protocol DiscoveryProjectCardViewModelType {
  var inputs: DiscoveryProjectCardViewModelInputs { get }
  var outputs: DiscoveryProjectCardViewModelOutputs { get }
}

public final class DiscoveryProjectCardViewModel: DiscoveryProjectCardViewModelType,
  DiscoveryProjectCardViewModelInputs, DiscoveryProjectCardViewModelOutputs {
  public init() {
    let project = self.configureWithValueProperty.signal.skipNil().map(first)

    self.projectNameLabelText = project.map(\.name)
    self.projectBlurbLabelText = project.map(\.blurb)
    self.backerCountLabelData = project.map(\.stats.backersCount).map { count in
      (Format.wholeNumber(count), Strings.general_backer_count_backers(backer_count: count))
    }

    self.percentFundedLabelData = project.map { project in
      if project.stats.goalMet {
        return (
          Strings.Goal_met(),
          Strings.Goal_met()
        )
      }

      let percentage = "\(project.stats.percentFunded)%"

      return (percentage, Strings.percentage_funded(percentage: percentage))
    }

    self.goalMetIconHidden = project.map(\.stats.goalMet).negate()
    self.projectImageURL = project.map(\.photo.full).map(URL.init(string:)).skipNil()
    self.facepileViewHidden = project.map(\.personalization.friends).map { friends in
      guard let friends = friends else {
        return true
      }

      return friends.isEmpty
    }
    self.facepileViewData = project.filterMap(\.personalization.friends).filterMap(facepileData(for:))

    self.tagsCollectionViewHidden = self.configureWithValueProperty.signal.skipNil()
      .map { ($0.project, $0.category) }
      .map(projectTagsViewShouldHide(project:category:))

    self.loadProjectTags = self.configureWithValueProperty.signal.skipNil()
      .map { ($0.project, $0.category) }
      .map(projectTags(project:category:))
      .filter { !$0.isEmpty }

    self.projectStatusIconImageName = project.filterMap { project in
      switch project.state {
      case .canceled, .failed: return "icon--prohibit"
      case .successful: return "icon--check"
      case .live: return "icon--clock"
      case .started, .submitted, .suspended, .purged: return nil // there should be no projects in this state
      }
    }

    self.projectStatusLabelData = project.filterMap { project in
      switch project.state {
      case .canceled: return ("", Strings.profile_projects_status_canceled())
      case .failed: return ("", Strings.profile_projects_status_unsuccessful())
      case .successful: return ("", Strings.profile_projects_status_successful())
      case .live:
        let (duration, unit) = Format.duration(
          secondsInUTC: project.dates.deadline,
          abbreviate: false,
          useToGo: true,
          env: AppEnvironment.current
        )

        return (duration, "\(duration) \(unit)")
      case .started, .submitted, .suspended, .purged: return nil // there should be no projects in this state
      }
    }

    self.youreABackerViewHidden = project.map(userIsBackingProject).negate()
  }

  private let configureWithValueProperty = MutableProperty<DiscoveryProjectCellRowValue?>(nil)
  public func configure(with value: DiscoveryProjectCellRowValue) {
    self.configureWithValueProperty.value = value
  }

  public let backerCountLabelData: Signal<BoldedAttributedLabelData, Never>
  public let facepileViewHidden: Signal<Bool, Never>
  public let facepileViewData: Signal<FacepileViewData, Never>
  public let goalMetIconHidden: Signal<Bool, Never>
  public let loadProjectTags: Signal<[DiscoveryProjectTagPillCellValue], Never>
  public let percentFundedLabelData: Signal<BoldedAttributedLabelData, Never>
  public let projectBlurbLabelText: Signal<String, Never>
  public let projectImageURL: Signal<URL, Never>
  public let projectNameLabelText: Signal<String, Never>
  public let projectStatusIconImageName: Signal<String, Never>
  public let projectStatusLabelData: Signal<BoldedAttributedLabelData, Never>
  public let tagsCollectionViewHidden: Signal<Bool, Never>
  public let youreABackerViewHidden: Signal<Bool, Never>

  public var inputs: DiscoveryProjectCardViewModelInputs { return self }
  public var outputs: DiscoveryProjectCardViewModelOutputs { return self }
}

private func projectTagsViewShouldHide(project: Project, category: KsApi.Category?) -> Bool {
  let categoryTagShouldHide = projectCategoryTagShouldHide(for: project, in: category)
  let pwlTagShouldHide = projectPWLTagShouldHide(project: project)

  return categoryTagShouldHide && pwlTagShouldHide
}

private func projectCategoryTagShouldHide(for project: Project, in category: KsApi.Category?) -> Bool {
  guard let category = category, !category.isRoot else {
    // Always show category when filter category is nil, or we're in a root category
    return false
  }

  return project.category.id == category.intID
}

private func projectPWLTagShouldHide(project: Project) -> Bool {
  return !project.staffPick
}

private func projectTags(project: Project, category: KsApi.Category?) -> [DiscoveryProjectTagPillCellValue] {
  let shouldShowCategoryTag = !projectCategoryTagShouldHide(for: project, in: category)
  let shouldShowPWLTag = !projectPWLTagShouldHide(project: project)

  var tags: [DiscoveryProjectTagPillCellValue] = []

  if shouldShowPWLTag {
    let pwlTag = DiscoveryProjectTagPillCellValue(
      type: .green,
      tagIconImageName: "icon--small-k",
      tagLabelText: Strings.Projects_We_Love()
    )

    tags.append(pwlTag)
  }

  if shouldShowCategoryTag {
    let categoryTag = DiscoveryProjectTagPillCellValue(
      type: .grey,
      tagIconImageName: "icon--compass",
      tagLabelText: project.category.name
    )

    tags.append(categoryTag)
  }

  return tags
}

private func facepileData(for friendsList: [User]) -> FacepileViewData? {
  guard !friendsList.isEmpty else { return nil }

  let avatars = friendsList.prefix(3).map(\.avatar.small).compactMap(URL.init(string:))

  let remainingCount = friendsList.count - 1
  let description = Strings.Social_friend_is_backer(
    friend_name: friendsList[0].name,
    remaining_count: remainingCount
  )

  return (avatars, description)
}
