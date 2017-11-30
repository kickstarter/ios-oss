import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol ProjectPamphletMainCellViewModelInputs {
  /// Call when cell awakeFromNib is called.
  func awakeFromNib()

  /// Call with the project provided to the view controller.
  func configureWith(project: Project)

  /// Call when the creator button is tapped.
  func creatorButtonTapped()

  /// Call when the delegate has been set on the cell.
  func delegateDidSet()

  /// Call when the read more button is tapped.
  func readMoreButtonTapped()

  func videoDidFinish()
  func videoDidStart()
}

public protocol ProjectPamphletMainCellViewModelOutputs {

  /// Emits a string to use for the backer subtitle label.
  var backersSubtitleLabelText: Signal<String, NoError> { get }

  /// Emits a string to use for the backers title label.
  var backersTitleLabelText: Signal<String, NoError> { get }

  /// Emits a string to use for the category name label.
  var categoryNameLabelText: Signal<String, NoError> { get }

  /// Emits a project when the video player controller should be configured.
  var configureVideoPlayerController: Signal<Project, NoError> { get }

  /// Emits a boolean that determines if the conversion labels should be hidden.
  var conversionLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a string for the conversion label.
  var conversionLabelText: Signal<String, NoError> { get }

  /// Emits an image url to be loaded into the creator's image view.
  var creatorImageUrl: Signal<URL?, NoError> { get }

  /// Emits text to be put into the creator label.
  var creatorLabelText: Signal<String, NoError> { get }

  /// Emits the text for the deadline subtitle label.
  var deadlineSubtitleLabelText: Signal<String, NoError> { get }

  /// Emits the text for the deadline title label.
  var deadlineTitleLabelText: Signal<String, NoError> { get }

  /// Emits the background color of the funding progress bar view.
  var fundingProgressBarViewBackgroundColor: Signal<UIColor, NoError> { get }

  /// Emits a string to use for the location name label.
  var locationNameLabelText: Signal<String, NoError> { get }

  /// Emits the project when we should go to the campaign view for the project.
  var notifyDelegateToGoToCampaign: Signal<Project, NoError> { get }

  /// Emits the project when we should go to the creator's view for the project.
  var notifyDelegateToGoToCreator: Signal<Project, NoError> { get }

  /// Emits an alpha value for views to create transition after full project loads.
  var opacityForViews: Signal<CGFloat, NoError> { get }

  /// Emits the text for the pledged subtitle label.
  var pledgedSubtitleLabelText: Signal<String, NoError> { get }

  /// Emits the text for the pledged title label.
  var pledgedTitleLabelText: Signal<String, NoError> { get }

  /// Emits the text color of the pledged title label.
  var pledgedTitleLabelTextColor: Signal<UIColor, NoError> { get }

  /// Emits a percentage between 0.0 and 1.0 that can be used to render the funding progress bar.
  var progressPercentage: Signal<Float, NoError> { get }

  /// Emits text to be put into the project blurb label.
  var projectBlurbLabelText: Signal<String, NoError> { get }

  /// Emits a URL to be loaded into the project's image view.
  var projectImageUrl: Signal<URL?, NoError> { get }

  /// Emits text to be put into the project name label.
  var projectNameLabelText: Signal<String, NoError> { get }

  /// Emits a string that should be put into the project state label.
  var projectStateLabelText: Signal<String, NoError> { get }

  /// Emits the text color of the project state label.
  var projectStateLabelTextColor: Signal<UIColor, NoError> { get }

  /// Emits the text color of the backer and deadline title label.
  var projectUnsuccessfulLabelTextColor: Signal<UIColor, NoError> { get }

  /// Emits a boolean that determines if the project state label should be hidden.
  var stateLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a string to use for the stats stack view accessibility value.
  var statsStackViewAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the "you're a backer" label should be hidden.
  var youreABackerLabelHidden: Signal<Bool, NoError> { get }

  var subtitleFont: Signal<UIFont, NoError> { get }

  var titleFont: Signal<UIFont, NoError> { get }
}

public protocol ProjectPamphletMainCellViewModelType {
  var inputs: ProjectPamphletMainCellViewModelInputs { get }
  var outputs: ProjectPamphletMainCellViewModelOutputs { get }
}

public final class ProjectPamphletMainCellViewModel: ProjectPamphletMainCellViewModelType,
ProjectPamphletMainCellViewModelInputs, ProjectPamphletMainCellViewModelOutputs {

    public init() {
    let project = self.projectProperty.signal.skipNil()

    self.projectNameLabelText = project.map(Project.lens.name.view)
    self.projectBlurbLabelText = project.map(Project.lens.blurb.view)

    self.creatorLabelText = project.map {
      Strings.project_creator_by_creator(creator_name: $0.creator.name)
    }

    self.creatorImageUrl = project.map { URL(string: $0.creator.avatar.small) }

    self.stateLabelHidden = project.map { $0.state == .live }

    self.projectStateLabelText = project
      .filter { $0.state != .live }
      .map(fundingStatus(forProject:))

    self.projectStateLabelTextColor = project
      .filter { $0.state != .live }
      .map { $0.state == .successful ? UIColor.ksr_green_700 : UIColor.ksr_text_dark_grey_400 }

    self.fundingProgressBarViewBackgroundColor = project
      .map(progressColor(forProject:))

    self.projectUnsuccessfulLabelTextColor = project
      .map { $0.state == .successful || $0.state == .live ?
        UIColor.ksr_text_dark_grey_500 : UIColor.ksr_text_dark_grey_500 }

    self.pledgedTitleLabelTextColor = project
      .map { $0.state == .successful  || $0.state == .live ?
        UIColor.ksr_green_700 : UIColor.ksr_text_dark_grey_500 }

    self.projectImageUrl = project.map { URL(string: $0.photo.full) }

    let videoIsPlaying = Signal.merge(
      project.take(first: 1).mapConst(false),
      self.videoDidStartProperty.signal.mapConst(true),
      self.videoDidFinishProperty.signal.mapConst(false)
    )

    self.youreABackerLabelHidden = Signal.combineLatest(project, videoIsPlaying)
      .map { project, videoIsPlaying in
        project.personalization.isBacking != true || videoIsPlaying
      }
      .skipRepeats()

    let backersTitleAndSubtitleText = project.map { project -> (String?, String?) in
      let string = Strings.Backers_count_separator_backers(backers_count: project.stats.backersCount)
      let parts = string.characters.split(separator: "\n").map(String.init)
      return (parts.first, parts.last)
    }

    self.backersTitleLabelText = backersTitleAndSubtitleText.map { title, _ in title ?? "" }
    self.backersSubtitleLabelText =  backersTitleAndSubtitleText.map { _, subtitle in subtitle ?? "" }

    self.categoryNameLabelText = project.map { $0.category.name }

    let deadlineTitleAndSubtitle = project.map {
      return Format.duration(secondsInUTC: $0.dates.deadline, useToGo: true)
    }

    self.deadlineTitleLabelText = deadlineTitleAndSubtitle.map(first)
    self.deadlineSubtitleLabelText = deadlineTitleAndSubtitle.map(second)

    let projectAndNeedsConversion = project.map { project -> (Project, Bool) in
      (
        project,
        AppEnvironment.current.config?.countryCode == "US" && project.country != .us
      )
    }

    self.conversionLabelHidden = projectAndNeedsConversion.map(second).map(negate)

    self.conversionLabelText = projectAndNeedsConversion
      .filter(second)
      .map(first)
      .map { project in
        Strings.discovery_baseball_card_stats_convert_from_pledged_of_goal(
          pledged: Format.currency(project.stats.pledged, country: project.country),
          goal: Format.currency(project.stats.goal, country: project.country)
        )
    }

    self.locationNameLabelText = project.map { $0.location.displayableName }

    self.pledgedTitleLabelText = projectAndNeedsConversion.map { project, needsConversion in
      needsConversion
        ? Format.currency(project.stats.pledgedUsd, country: .us)
        : Format.currency(project.stats.pledged, country: project.country)
    }

    self.pledgedSubtitleLabelText = projectAndNeedsConversion.map { project, needsConversion in
      guard needsConversion else {
        return Strings.activity_project_state_change_pledged_of_goal(
          goal: Format.currency(project.stats.goal, country: project.country)
        )
      }

      return Strings.activity_project_state_change_pledged_of_goal(
        goal: Format.currency(project.stats.goalUsd, country: .us)
      )
    }

    self.statsStackViewAccessibilityLabel = projectAndNeedsConversion
      .map(statsStackViewAccessibilityLabel(forProject:needsConversion:))

    self.progressPercentage = project
      .map(Project.lens.stats.fundingProgress.view)
      .map(clamp(0, 1))

    self.notifyDelegateToGoToCampaign = project
      .takeWhen(self.readMoreButtonTappedProperty.signal)

    self.notifyDelegateToGoToCreator = project
      .takeWhen(self.creatorButtonTappedProperty.signal)

    self.configureVideoPlayerController = Signal.combineLatest(project, self.delegateDidSetProperty.signal)
      .map(first)
      .take(first: 1)

    self.opacityForViews = Signal.merge(
      self.projectProperty.signal.skipNil().mapConst(1.0),
      self.awakeFromNibProperty.signal.mapConst(0.0)
    )
  }

  private let awakeFromNibProperty = MutableProperty()
  public func awakeFromNib() {
    self.awakeFromNibProperty.value = ()
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  fileprivate let creatorButtonTappedProperty = MutableProperty()
  public func creatorButtonTapped() {
    self.creatorButtonTappedProperty.value = ()
  }

  fileprivate let delegateDidSetProperty = MutableProperty()
  public func delegateDidSet() {
    self.delegateDidSetProperty.value = ()
  }

  fileprivate let readMoreButtonTappedProperty = MutableProperty()
  public func readMoreButtonTapped() {
    self.readMoreButtonTappedProperty.value = ()
  }

  fileprivate let videoDidFinishProperty = MutableProperty()
  public func videoDidFinish() {
    self.videoDidFinishProperty.value = ()
  }

  fileprivate let videoDidStartProperty = MutableProperty()
  public func videoDidStart() {
    self.videoDidStartProperty.value = ()
  }

  public let backersSubtitleLabelText: Signal<String, NoError>
  public let backersTitleLabelText: Signal<String, NoError>
  public let categoryNameLabelText: Signal<String, NoError>
  public let configureVideoPlayerController: Signal<Project, NoError>
  public let conversionLabelHidden: Signal<Bool, NoError>
  public let conversionLabelText: Signal<String, NoError>
  public let creatorImageUrl: Signal<URL?, NoError>
  public let creatorLabelText: Signal<String, NoError>
  public let deadlineSubtitleLabelText: Signal<String, NoError>
  public let deadlineTitleLabelText: Signal<String, NoError>
  public let fundingProgressBarViewBackgroundColor: Signal<UIColor, NoError>
  public let locationNameLabelText: Signal<String, NoError>
  public let notifyDelegateToGoToCampaign: Signal<Project, NoError>
  public let notifyDelegateToGoToCreator: Signal<Project, NoError>
  public let opacityForViews: Signal<CGFloat, NoError>
  public let pledgedSubtitleLabelText: Signal<String, NoError>
  public let pledgedTitleLabelText: Signal<String, NoError>
  public let pledgedTitleLabelTextColor: Signal<UIColor, NoError>
  public let progressPercentage: Signal<Float, NoError>
  public let projectBlurbLabelText: Signal<String, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let projectNameLabelText: Signal<String, NoError>
  public let projectStateLabelText: Signal<String, NoError>
  public let projectStateLabelTextColor: Signal<UIColor, NoError>
  public let projectUnsuccessfulLabelTextColor: Signal<UIColor, NoError>
  public let stateLabelHidden: Signal<Bool, NoError>
  public let statsStackViewAccessibilityLabel: Signal<String, NoError>
  public let youreABackerLabelHidden: Signal<Bool, NoError>

  public let subtitleFont: Signal<UIFont, NoError>
  public let titleFont: Signal<UIFont, NoError>

  public var inputs: ProjectPamphletMainCellViewModelInputs { return self }
  public var outputs: ProjectPamphletMainCellViewModelOutputs { return self }
}

private func statsStackViewAccessibilityLabel(forProject project: Project, needsConversion: Bool) -> String {

  let pledged = needsConversion
    ? Format.currency(project.stats.pledged, country: project.country)
    : Format.currency(project.stats.pledgedUsd, country: .us)
  let goal = needsConversion
    ? Format.currency(project.stats.goal, country: project.country)
    : Format.currency(project.stats.goalUsd, country: .us)

  let backersCount = project.stats.backersCount
  let (time, unit) = Format.duration(secondsInUTC: project.dates.deadline, useToGo: true)
  let timeLeft = time + " " + unit

  return project.state == .live
    ? Strings.dashboard_graphs_funding_accessibility_live_stat_value(
      pledged: pledged, goal: goal, backers_count: backersCount, time_left: timeLeft
      )
    : Strings.dashboard_graphs_funding_accessibility_non_live_stat_value(
      pledged: pledged, goal: goal, backers_count: backersCount, time_left: timeLeft
  )
}

private func fundingStatus(forProject project: Project) -> String {
  let date = Format.date(secondsInUTC: project.dates.stateChangedAt,
                         dateStyle: .medium,
                         timeStyle: .none)

  switch project.state {
  case .canceled:
    return Strings.discovery_baseball_card_status_banner_canceled_date(date: date)
  case .failed:
    return Strings.creator_project_preview_subtitle_funding_unsuccessful_on_deadline(deadline: date)
  case .successful:
    return Strings.project_status_project_was_successfully_funded_on_deadline(deadline: date)
  case .suspended:
    return Strings.discovery_baseball_card_status_banner_suspended_date(date: date)
  case .live, .purged, .started, .submitted:
    return ""
  }
 }

private func progressColor(forProject project: Project) -> UIColor {
  switch project.state {
  case .canceled, .failed, .suspended:
    return .ksr_dark_grey_400
  default:
    return .ksr_green_700
  }
}
