import KsApi
import Prelude
import ReactiveSwift
import Result

public struct PostcardMetadataData {
  public let iconImage: UIImage?
  public let labelText: String
  public let iconAndTextColor: UIColor
}

private enum PostcardMetadataType {
  case backing
  case featured

  fileprivate func data(forProject project: Project) -> PostcardMetadataData? {
    switch self {
    case .backing:
      return PostcardMetadataData(iconImage: image(named: "metadata-backing"),
                                  labelText: Strings.discovery_baseball_card_metadata_backer(),
                                  iconAndTextColor: .ksr_green_700)
    case .featured:
      guard let rootCategory = project.category.parent?.name else { return nil }
      return PostcardMetadataData(iconImage: image(named: "metadata-featured"),
                                  labelText: Strings.discovery_baseball_card_metadata_featured_project(
                                    category_name: rootCategory),
                                  iconAndTextColor: .ksr_dark_grey_900)
    }
  }
}

public protocol DiscoveryPostcardViewModelInputs {
  /// Call with the project provided to the view controller.
  func configureWith(project: Project, category: KsApi.Category?)
}

public protocol DiscoveryPostcardViewModelOutputs {
  /// Emits a string to use for the backers title label.
  var backersTitleLabelText: Signal<String, NoError> { get }

  /// Emits a string to use for the backers subtitle label.
  var backersSubtitleLabelText: Signal<String, NoError> { get }

  /// Emits the cell label to be read aloud by voiceover.
  var cellAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the cell value to be read aloud by voiceover.
  var cellAccessibilityValue: Signal<String, NoError> { get }

  /// Emits the text for the deadine subtitle label.
  var deadlineSubtitleLabelText: Signal<String, NoError> { get }

  /// Emits the text for the deadline title label.
  var deadlineTitleLabelText: Signal<String, NoError> { get }

  /// Emits a boolean to determine whether or not to display the funding progress bar view.
  var fundingProgressBarViewHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean to determine whether or not to display funding progress container view.
  var fundingProgressContainerViewHidden: Signal<Bool, NoError> { get }

  /// Emits metadata label text
  var metadataLabelText: Signal<String, NoError> { get }

  /// Emits metadata icon image
  var metadataIcon: Signal<UIImage?, NoError> { get }

  /// Emits icon image tint color
  var metadataIconImageViewTintColor: Signal<UIColor, NoError> { get }

  /// Emits metadata text color
  var metadataTextColor: Signal<UIColor, NoError> { get }

  /// Emits a boolean to determine whether or not the metadata view should be hidden.
  var metadataViewHidden: Signal<Bool, NoError> { get }

  /// Emits the text for the pledged title label.
  var percentFundedTitleLabelText: Signal<String, NoError> { get }

  /// Emits a percentage between 0.0 and 1.0 that can be used to render the funding progress bar.
  var progressPercentage: Signal<Float, NoError> { get }

  /// Emits a URL to be loaded into the project's image view.
  var projectImageURL: Signal<URL?, NoError> { get }

  /// Emits the text to be put into the project name and blurb label.
  var projectNameAndBlurbLabelText: Signal<NSAttributedString, NoError> { get }

  /// Emits a boolean that determines if the project state icon should be hidden.
  var projectStateIconHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the project state label should be hidden.
  var projectStateStackViewHidden: Signal<Bool, NoError> { get }

  /// Emits the text for the project state subtitle label.
  var projectStateSubtitleLabelText: Signal<String, NoError> { get }

  /// Emits the color for the project state title label.
  var projectStateTitleLabelColor: Signal<UIColor, NoError> { get }

  /// Emits the text for the project state title label.
  var projectStateTitleLabelText: Signal<String, NoError> { get }

  /// Emits a string for the project category label
  var projectCategoryName: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the "Projects We Love" label should be hidden
  var projectIsStaffPickLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the project categories should be hidden.
  var projectCategoryViewHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the category stack view should be hidden.
  var projectCategoryStackViewHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the project stats should be hidden.
  var projectStatsStackViewHidden: Signal<Bool, NoError> { get }

  /// Emits the URL to be loaded into the social avatar's image view.
  var socialImageURL: Signal<URL?, NoError> { get }

  /// Emits the text for the social label.
  var socialLabelText: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the social view should be hidden.
  var socialStackViewHidden: Signal<Bool, NoError> { get }
}

public protocol DiscoveryPostcardViewModelType {
  var inputs: DiscoveryPostcardViewModelInputs { get }
  var outputs: DiscoveryPostcardViewModelOutputs { get }
}

public final class DiscoveryPostcardViewModel: DiscoveryPostcardViewModelType,
  DiscoveryPostcardViewModelInputs, DiscoveryPostcardViewModelOutputs {

  public init() {
    let configuredProject = self.projectProperty.signal.skipNil()

    let backersTitleAndSubtitleText = configuredProject.map { project -> (String?, String?) in
      let string = Strings.Backers_count_separator_backers(backers_count: project.stats.backersCount)
      let parts = string.split(separator: "\n").map(String.init)
      return (parts.first, parts.last)
    }

    self.backersTitleLabelText = backersTitleAndSubtitleText.map { title, _ in title ?? "" }
    self.backersSubtitleLabelText = backersTitleAndSubtitleText.map { _, subtitle in subtitle ?? "" }

    let deadlineTitleAndSubtitle = configuredProject
      .map {
        $0.state == .live
          ? Format.duration(secondsInUTC: $0.dates.deadline, useToGo: true)
          : ("", "")
    }

    self.deadlineTitleLabelText = deadlineTitleAndSubtitle.map(first)
    self.deadlineSubtitleLabelText = deadlineTitleAndSubtitle.map(second)

    let possibleMetadataData = configuredProject.map(postcardMetadata(forProject:))

    self.metadataViewHidden = possibleMetadataData.map { $0 == nil }

    let metadataData = possibleMetadataData.skipNil()

    self.metadataIcon = metadataData.map { $0.iconImage }
    self.metadataLabelText = metadataData.map { $0.labelText }
    self.metadataTextColor = metadataData.map { $0.iconAndTextColor }
    self.metadataIconImageViewTintColor = metadataData.map { $0.iconAndTextColor }

    self.percentFundedTitleLabelText = configuredProject
      .map { $0.state == .live ? Format.percentage($0.stats.percentFunded) : "" }

    self.progressPercentage = configuredProject
      .map(Project.lens.stats.fundingProgress.view)
      .map(clamp(0, 1))

    self.projectImageURL = configuredProject.map { $0.photo.full }.map(URL.init(string:))

    self.projectNameAndBlurbLabelText = configuredProject
      .map(projectAttributedNameAndBlurb)

    self.projectStateIconHidden = configuredProject
      .map { $0.state != .successful }

    self.projectStateStackViewHidden = configuredProject.map { $0.state == .live }.skipRepeats()

    self.projectStateSubtitleLabelText = configuredProject
      .map {
        $0.state != .live
          ? Format.date(secondsInUTC: $0.dates.stateChangedAt, dateStyle: .medium, timeStyle: .none)
          : ""
    }

    self.projectStateTitleLabelColor = configuredProject
      .map { $0.state == .successful ? .ksr_green_700 : .ksr_text_dark_grey_900 }
      .skipRepeats()

    self.projectStateTitleLabelText = configuredProject
      .map(fundingStatusText(forProject:))

    self.projectCategoryName = configuredProject
      .map { $0.category.name }

    self.projectCategoryViewHidden = Signal.combineLatest(
      self.projectProperty.signal.skipNil(),
      self.categoryProperty.signal
      ).map { (project, category) in
        guard let category = category else {
          // Always show category when filter category is nil
          return false
        }

        // if we are in a subcategory, compare categories
        if !category.isRoot {
          return Int(project.category.id) == category.intID
        }

        // otherwise, always show category
        return false
      }

    self.projectIsStaffPickLabelHidden = configuredProject
      .map { $0.staffPick }
      .negate()

    let projectCategoryViewsHidden = Signal.combineLatest(
      self.projectCategoryViewHidden.signal,
      self.projectIsStaffPickLabelHidden.signal)

    self.projectCategoryStackViewHidden = projectCategoryViewsHidden
      .map { projectCategoryViews in
          return projectCategoryViews.0 && projectCategoryViews.1
      }

    self.projectStatsStackViewHidden = self.projectStateStackViewHidden.map(negate)

    self.socialImageURL = configuredProject
      .map { $0.personalization.friends?.first.flatMap { URL(string: $0.avatar.medium) } }

    self.socialLabelText = configuredProject
      .map { $0.personalization.friends.flatMap(socialText(forFriends:)) ?? "" }

    self.socialStackViewHidden = configuredProject
      .map { $0.personalization.friends == nil || $0.personalization.friends?.count ?? 0 == 0 }
      .skipRepeats()

    self.fundingProgressContainerViewHidden = configuredProject
      .map { $0.state == .canceled || $0.state == .suspended }

    self.fundingProgressBarViewHidden = configuredProject
      .map { $0.state == .failed }

    // a11y
    self.cellAccessibilityLabel = configuredProject.map(Project.lens.name.view)

    self.cellAccessibilityValue = Signal.zip(configuredProject, self.projectStateTitleLabelText)
      .map { project, projectState in "\(project.blurb). \(projectState)" }
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  fileprivate let categoryProperty = MutableProperty<KsApi.Category?>(nil)

  public func configureWith(project: Project, category: KsApi.Category? = nil) {
    self.projectProperty.value = project
    self.categoryProperty.value = category
  }

  public let backersTitleLabelText: Signal<String, NoError>
  public let backersSubtitleLabelText: Signal<String, NoError>
  public let cellAccessibilityLabel: Signal<String, NoError>
  public let cellAccessibilityValue: Signal<String, NoError>
  public let deadlineSubtitleLabelText: Signal<String, NoError>
  public let deadlineTitleLabelText: Signal<String, NoError>
  public let fundingProgressBarViewHidden: Signal<Bool, NoError>
  public let fundingProgressContainerViewHidden: Signal<Bool, NoError>
  public let metadataLabelText: Signal<String, NoError>
  public let metadataIcon: Signal<UIImage?, NoError>
  public let metadataIconImageViewTintColor: Signal<UIColor, NoError>
  public let metadataTextColor: Signal<UIColor, NoError>
  public let metadataViewHidden: Signal<Bool, NoError>
  public let percentFundedTitleLabelText: Signal<String, NoError>
  public let progressPercentage: Signal<Float, NoError>
  public let projectImageURL: Signal<URL?, NoError>
  public let projectNameAndBlurbLabelText: Signal<NSAttributedString, NoError>
  public let projectStateIconHidden: Signal<Bool, NoError>
  public let projectStateStackViewHidden: Signal<Bool, NoError>
  public let projectStatsStackViewHidden: Signal<Bool, NoError>
  public let projectStateSubtitleLabelText: Signal<String, NoError>
  public let projectStateTitleLabelText: Signal<String, NoError>
  public var projectCategoryName: Signal<String, NoError>
  public let projectIsStaffPickLabelHidden: Signal<Bool, NoError>
  public var projectCategoryViewHidden: Signal<Bool, NoError>
  public var projectCategoryStackViewHidden: Signal<Bool, NoError>
  public let projectStateTitleLabelColor: Signal<UIColor, NoError>
  public let socialImageURL: Signal<URL?, NoError>
  public let socialLabelText: Signal<String, NoError>
  public let socialStackViewHidden: Signal<Bool, NoError>

  public var inputs: DiscoveryPostcardViewModelInputs { return self }
  public var outputs: DiscoveryPostcardViewModelOutputs { return self }
}

private func socialText(forFriends friends: [User]) -> String? {
  if friends.count == 1 {
    return Strings.project_social_friend_is_backer(friend_name: friends[0].name)
  } else if friends.count == 2 {
    return Strings.project_social_friend_and_friend_are_backers(friend_name: friends[0].name,
                                                                second_friend_name: friends[1].name)
  } else if friends.count > 2 {
    let remainingCount = max(0, friends.count - 2)
    return Strings.discovery_baseball_card_social_friends_are_backers(friend_name: friends[0].name,
                                                                      second_friend_name: friends[1].name,
                                                                      remaining_count: remainingCount)
  } else {
    return nil
  }
}

private func fundingStatusText(forProject project: Project) -> String {
  switch project.state {
  case .canceled:
    return Strings.Project_cancelled()
  case .failed:
    return Strings.dashboard_creator_project_funding_unsuccessful()
  case .successful:
    return Strings.Funding_successful()
  case .suspended:
    return Strings.dashboard_creator_project_funding_suspended()
  case .live, .purged, .started, .submitted:
    return ""
  }
}

// Returns the disparate metadata data for a project based on metadata precedence.
private func postcardMetadata(forProject project: Project) -> PostcardMetadataData? {
  let today = AppEnvironment.current.dateType.init().date

  if project.personalization.isBacking == true {
    return PostcardMetadataType.backing.data(forProject: project)
  } else if project.isFeaturedToday(today: today) {
    return PostcardMetadataType.featured.data(forProject: project)
  } else {
    return nil
  }
}
