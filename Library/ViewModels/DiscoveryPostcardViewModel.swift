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
  case potd
  case starred

  fileprivate func data(forProject project: Project) -> PostcardMetadataData? {
    switch self {
    case .backing:
      return PostcardMetadataData(iconImage: image(named: "metadata-backing"),
                                  labelText: Strings.discovery_baseball_card_metadata_backer(),
                                  iconAndTextColor: .ksr_text_green_700)
    case .featured:
      if let rootCategory = project.category.parent?.name {
        return PostcardMetadataData(iconImage: image(named: "metadata-featured"),
                                    labelText: Strings.discovery_baseball_card_metadata_featured_project(
                                      category_name: rootCategory),
                                    iconAndTextColor: .ksr_text_navy_700)
      } else { return nil }
    case .potd:
      return PostcardMetadataData(iconImage: nil,
                                  labelText: Strings.discovery_baseball_card_metadata_project_of_the_Day(),
                                  iconAndTextColor: .ksr_text_navy_700)
    case .starred:
      return PostcardMetadataData(iconImage: image(named: "metadata-starred"),
                                  labelText: Strings.You_saved_this_project(),
                                  iconAndTextColor: .ksr_text_navy_700)
    }
  }
}

public protocol DiscoveryPostcardViewModelInputs {
  /// Call with the project provided to the view controller.
  func configureWith(project: Project)

  /// Call when share button is tapped.
  func shareButtonTapped()

  /// Call when star button is tapped.
  func starButtonTapped()
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

  /// Emits the disparate data to be displayed on the metadata view label.
  var metadataData: Signal<PostcardMetadataData, NoError> { get }

  /// Emits a boolean to determine whether or not the metadata view should be hidden.
  var metadataViewHidden: Signal<Bool, NoError> { get }

  /// Emits when we should notify the delegate that the share button was tapped.
  var notifyDelegateShareButtonTapped: Signal<ShareContext, NoError> { get }

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
    let project = self.projectProperty.signal.skipNil()

    let backersTitleAndSubtitleText = project.map { project -> (String?, String?) in
      let string = Strings.Backers_count_separator_backers(backers_count: project.stats.backersCount)
      let parts = string.characters.split(separator: "\n").map(String.init)
      return (parts.first, parts.last)
    }

    self.backersTitleLabelText = backersTitleAndSubtitleText.map { title, _ in title ?? "" }
    self.backersSubtitleLabelText = backersTitleAndSubtitleText.map { _, subtitle in subtitle ?? "" }

    let deadlineTitleAndSubtitle = project
      .map {
        $0.state == .live
          ? Format.duration(secondsInUTC: $0.dates.deadline, useToGo: true)
          : ("", "")
    }

    self.deadlineTitleLabelText = deadlineTitleAndSubtitle.map(first)
    self.deadlineSubtitleLabelText = deadlineTitleAndSubtitle.map(second)

    self.metadataViewHidden = project
      .map { p in
        let today = AppEnvironment.current.dateType.init().date
        let noMetadata = (p.personalization.isBacking == nil || p.personalization.isBacking == false) &&
                         (p.personalization.isStarred == nil || p.personalization.isStarred == false) &&
          !p.isPotdToday(today: today) && !p.isFeaturedToday(today: today)

        return noMetadata
      }
      .skipRepeats()

    self.metadataData = project.map(postcardMetadata(forProject:)).skipNil()

    self.percentFundedTitleLabelText = project
      .map { $0.state == .live ? Format.percentage($0.stats.percentFunded) : "" }

    self.progressPercentage = project
      .map(Project.lens.stats.fundingProgress.view)
      .map(clamp(0, 1))

    self.projectImageURL = project.map { $0.photo.full }.map(URL.init(string:))

    self.projectNameAndBlurbLabelText = project
      .map(projectAttributedNameAndBlurb)

    self.projectStateIconHidden = project
      .map { $0.state != .successful }

    self.projectStateStackViewHidden = project.map { $0.state == .live }.skipRepeats()

    self.projectStateSubtitleLabelText = project
      .map {
        $0.state != .live
          ? Format.date(secondsInUTC: $0.dates.stateChangedAt, dateStyle: .medium, timeStyle: .none)
          : ""
    }

    self.projectStateTitleLabelColor = project
      .map { $0.state == .successful ? .ksr_text_green_700 : .ksr_text_navy_700 }
      .skipRepeats()

    self.projectStateTitleLabelText = project
      .map(fundingStatusText(forProject:))

    self.projectStatsStackViewHidden = self.projectStateStackViewHidden.map(negate)

    self.socialImageURL = project
      .map { $0.personalization.friends?.first.flatMap { URL(string: $0.avatar.medium) } }

    self.socialLabelText = project
      .map { $0.personalization.friends.flatMap(socialText(forFriends:)) ?? "" }

    self.socialStackViewHidden = project
      .map { $0.personalization.friends == nil || $0.personalization.friends?.count ?? 0 == 0 }
      .skipRepeats()

    self.fundingProgressContainerViewHidden = project
      .map { $0.state == .canceled || $0.state == .suspended }

    self.fundingProgressBarViewHidden = project
      .map { $0.state == .failed }

    self.notifyDelegateShareButtonTapped = project
      .map(ShareContext.discovery)
      .takeWhen(self.shareButtonTappedProperty.signal)

    // a11y
    self.cellAccessibilityLabel = project.map(Project.lens.name.view)

    self.cellAccessibilityValue = Signal.zip(project, self.projectStateTitleLabelText)
      .map { project, projectState in "\(project.blurb). \(projectState)" }
  }
  // swiftlint:enable function_body_length

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  fileprivate let shareButtonTappedProperty = MutableProperty()
  public func shareButtonTapped() {
    self.shareButtonTappedProperty.value = ()
  }

  fileprivate let starButtonTappedProperty = MutableProperty()
  public func starButtonTapped() {
    self.starButtonTappedProperty.value = ()
  }

  public let backersTitleLabelText: Signal<String, NoError>
  public let backersSubtitleLabelText: Signal<String, NoError>
  public let cellAccessibilityLabel: Signal<String, NoError>
  public let cellAccessibilityValue: Signal<String, NoError>
  public let deadlineSubtitleLabelText: Signal<String, NoError>
  public let deadlineTitleLabelText: Signal<String, NoError>
  public let fundingProgressBarViewHidden: Signal<Bool, NoError>
  public let fundingProgressContainerViewHidden: Signal<Bool, NoError>
  public let metadataData: Signal<PostcardMetadataData, NoError>
  public let metadataViewHidden: Signal<Bool, NoError>
  public let notifyDelegateShareButtonTapped: Signal<ShareContext, NoError>
  public let percentFundedTitleLabelText: Signal<String, NoError>
  public let progressPercentage: Signal<Float, NoError>
  public let projectImageURL: Signal<URL?, NoError>
  public let projectNameAndBlurbLabelText: Signal<NSAttributedString, NoError>
  public let projectStateIconHidden: Signal<Bool, NoError>
  public let projectStateStackViewHidden: Signal<Bool, NoError>
  public let projectStatsStackViewHidden: Signal<Bool, NoError>
  public let projectStateSubtitleLabelText: Signal<String, NoError>
  public let projectStateTitleLabelText: Signal<String, NoError>
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
  } else if project.personalization.isStarred == true {
    return PostcardMetadataType.starred.data(forProject: project)
  } else if project.isPotdToday(today: today) {
    return PostcardMetadataType.potd.data(forProject: project)
  } else if project.isFeaturedToday(today: today) {
    return PostcardMetadataType.featured.data(forProject: project)
  } else {
    return nil
  }
}
