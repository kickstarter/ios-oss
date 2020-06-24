import KsApi
import Prelude
import ReactiveSwift

public typealias DiscoveryProjectCellRowValue = (
  project: Project,
  category: KsApi.Category?, // FIXME: consolidate into two parameters: project, filterParams
  params: DiscoveryParams?
)

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
      return PostcardMetadataData(
        iconImage: image(named: "metadata-backing"),
        labelText: Strings.discovery_baseball_card_metadata_backer(),
        iconAndTextColor: .ksr_green_700
      )
    case .featured:
      guard let rootCategory = project.category.parentName else { return nil }
      return PostcardMetadataData(
        iconImage: image(named: "metadata-featured"),
        labelText: Strings.discovery_baseball_card_metadata_featured_project(
          category_name: rootCategory
        ),
        iconAndTextColor: .ksr_soft_black
      )
    }
  }
}

public protocol DiscoveryPostcardViewModelInputs {
  /// Call with the data provided to the view controller.
  func configure(with value: DiscoveryProjectCellRowValue)
}

public protocol DiscoveryPostcardViewModelOutputs {
  /// Emits a string to use for the backers title label.
  var backersTitleLabelText: Signal<String, Never> { get }

  /// Emits a string to use for the backers subtitle label.
  var backersSubtitleLabelText: Signal<String, Never> { get }

  /// Emits the cell label to be read aloud by VoiceOver.
  var cellAccessibilityLabel: Signal<String, Never> { get }

  /// Emits the cell value to be read aloud by VoiceOver.
  var cellAccessibilityValue: Signal<String, Never> { get }

  /// Emits the text for the deadine subtitle label.
  var deadlineSubtitleLabelText: Signal<String, Never> { get }

  /// Emits the text for the deadline title label.
  var deadlineTitleLabelText: Signal<String, Never> { get }

  /// Emits a boolean to determine whether or not to display the funding progress bar view.
  var fundingProgressBarViewHidden: Signal<Bool, Never> { get }

  /// Emits a boolean to determine whether or not to display funding progress container view.
  var fundingProgressContainerViewHidden: Signal<Bool, Never> { get }

  /// Emits a boolean to determine whether or not to display the location stack view
  var locationStackViewHidden: Signal<Bool, Never> { get }

  /// Emits the location label text
  var locationLabelText: Signal<String, Never> { get }

  /// Emits metadata label text
  var metadataLabelText: Signal<String, Never> { get }

  /// Emits metadata icon image
  var metadataIcon: Signal<UIImage?, Never> { get }

  /// Emits icon image tint color
  var metadataIconImageViewTintColor: Signal<UIColor, Never> { get }

  /// Emits metadata text color
  var metadataTextColor: Signal<UIColor, Never> { get }

  /// Emits a boolean to determine whether or not the metadata view should be hidden.
  var metadataViewHidden: Signal<Bool, Never> { get }

  /// Emits the text for the pledged title label.
  var percentFundedTitleLabelText: Signal<String, Never> { get }

  /// Emits a percentage between 0.0 and 1.0 that can be used to render the funding progress bar.
  var progressPercentage: Signal<Float, Never> { get }

  /// Emits a URL to be loaded into the project's image view.
  var projectImageURL: Signal<URL?, Never> { get }

  /// Emits the text to be put into the project name and blurb label.
  var projectNameAndBlurbLabelText: Signal<NSAttributedString, Never> { get }

  /// Emits a boolean that determines if the project state icon should be hidden.
  var projectStateIconHidden: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the project state label should be hidden.
  var projectStateStackViewHidden: Signal<Bool, Never> { get }

  /// Emits the text for the project state subtitle label.
  var projectStateSubtitleLabelText: Signal<String, Never> { get }

  /// Emits the color for the project state title label.
  var projectStateTitleLabelColor: Signal<UIColor, Never> { get }

  /// Emits the text for the project state title label.
  var projectStateTitleLabelText: Signal<String, Never> { get }

  /// Emits a string for the project category label
  var projectCategoryName: Signal<String, Never> { get }

  /// Emits a boolean that determines if the "Projects We Love" label should be hidden
  var projectIsStaffPickLabelHidden: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the project categories should be hidden.
  var projectCategoryViewHidden: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the category stack view should be hidden.
  var projectCategoryStackViewHidden: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the project stats should be hidden.
  var projectStatsStackViewHidden: Signal<Bool, Never> { get }

  /// Emits the URL to be loaded into the social avatar's image view.
  var socialImageURL: Signal<URL?, Never> { get }

  /// Emits the text for the social label.
  var socialLabelText: Signal<String, Never> { get }

  /// Emits a boolean that determines if the social view should be hidden.
  var socialStackViewHidden: Signal<Bool, Never> { get }
}

public protocol DiscoveryPostcardViewModelType {
  var inputs: DiscoveryPostcardViewModelInputs { get }
  var outputs: DiscoveryPostcardViewModelOutputs { get }
}

public final class DiscoveryPostcardViewModel: DiscoveryPostcardViewModelType,
  DiscoveryPostcardViewModelInputs, DiscoveryPostcardViewModelOutputs {
  public init() {
    let configuredProject = self.configureWithValueProperty.signal.skipNil().map(first)
    let configuredCategory = self.configureWithValueProperty.signal.skipNil().map(second)

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
      .map { $0.state == .successful ? .ksr_green_700 : .ksr_soft_black }
      .skipRepeats()

    self.projectStateTitleLabelText = configuredProject
      .map(fundingStatusText(forProject:))

    self.projectCategoryName = configuredProject
      .map { $0.category.name }

    self.projectCategoryViewHidden = Signal.combineLatest(
      configuredProject,
      configuredCategory
    ).map { project, category in
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
      self.projectIsStaffPickLabelHidden.signal
    )

    self.projectCategoryStackViewHidden = projectCategoryViewsHidden
      .map { projectCategoryViews in
        projectCategoryViews.0 && projectCategoryViews.1
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

    let params = self.configureWithValueProperty.signal.skipNil().map(third)

    self.locationStackViewHidden = params.map { params in
      guard let params = params, let tagId = params.tagId else { return true }

      return tagId != DiscoveryParams.TagID.lightsOn
    }

    self.locationLabelText = configuredProject.map(\.location.name)
  }

  fileprivate let configureWithValueProperty = MutableProperty<DiscoveryProjectCellRowValue?>(nil)
  public func configure(with value: DiscoveryProjectCellRowValue) {
    self.configureWithValueProperty.value = value
  }

  public let backersTitleLabelText: Signal<String, Never>
  public let backersSubtitleLabelText: Signal<String, Never>
  public let cellAccessibilityLabel: Signal<String, Never>
  public let cellAccessibilityValue: Signal<String, Never>
  public let deadlineSubtitleLabelText: Signal<String, Never>
  public let deadlineTitleLabelText: Signal<String, Never>
  public let fundingProgressBarViewHidden: Signal<Bool, Never>
  public let fundingProgressContainerViewHidden: Signal<Bool, Never>
  public let locationLabelText: Signal<String, Never>
  public let locationStackViewHidden: Signal<Bool, Never>
  public let metadataLabelText: Signal<String, Never>
  public let metadataIcon: Signal<UIImage?, Never>
  public let metadataIconImageViewTintColor: Signal<UIColor, Never>
  public let metadataTextColor: Signal<UIColor, Never>
  public let metadataViewHidden: Signal<Bool, Never>
  public let percentFundedTitleLabelText: Signal<String, Never>
  public let progressPercentage: Signal<Float, Never>
  public let projectImageURL: Signal<URL?, Never>
  public let projectNameAndBlurbLabelText: Signal<NSAttributedString, Never>
  public let projectStateIconHidden: Signal<Bool, Never>
  public let projectStateStackViewHidden: Signal<Bool, Never>
  public let projectStatsStackViewHidden: Signal<Bool, Never>
  public let projectStateSubtitleLabelText: Signal<String, Never>
  public let projectStateTitleLabelText: Signal<String, Never>
  public var projectCategoryName: Signal<String, Never>
  public let projectIsStaffPickLabelHidden: Signal<Bool, Never>
  public var projectCategoryViewHidden: Signal<Bool, Never>
  public var projectCategoryStackViewHidden: Signal<Bool, Never>
  public let projectStateTitleLabelColor: Signal<UIColor, Never>
  public let socialImageURL: Signal<URL?, Never>
  public let socialLabelText: Signal<String, Never>
  public let socialStackViewHidden: Signal<Bool, Never>

  public var inputs: DiscoveryPostcardViewModelInputs { return self }
  public var outputs: DiscoveryPostcardViewModelOutputs { return self }
}

private func socialText(forFriends friends: [User]) -> String? {
  if friends.count == 1 {
    return Strings.project_social_friend_is_backer(friend_name: friends[0].name)
  } else if friends.count == 2 {
    return Strings.project_social_friend_and_friend_are_backers(
      friend_name: friends[0].name,
      second_friend_name: friends[1].name
    )
  } else if friends.count > 2 {
    let remainingCount = max(0, friends.count - 2)
    return Strings.discovery_baseball_card_social_friends_are_backers(
      friend_name: friends[0].name,
      second_friend_name: friends[1].name,
      remaining_count: remainingCount
    )
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

  let userHasBacked = userIsBackingProject(project)
  let projectIsFeaturedToday = project.isFeaturedToday(today: today)

  if userHasBacked {
    return PostcardMetadataType.backing.data(forProject: project)
  } else if projectIsFeaturedToday {
    return PostcardMetadataType.featured.data(forProject: project)
  } else {
    return nil
  }
}
