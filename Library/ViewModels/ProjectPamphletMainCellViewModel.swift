import KsApi
import Prelude
import ReactiveSwift
import UIKit

public typealias ProjectPamphletMainCellData = (
  project: Project,
  refTag: RefTag?
)

public protocol ProjectPamphletMainCellViewModelInputs {
  /// Call when cell awakeFromNib is called.
  func awakeFromNib()

  /// Call with the ProjectPamphletMainCellDataProjectPamphletMainCellData provided to the view controller.
  func configureWith(value: ProjectPamphletMainCellData)

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
  var backersSubtitleLabelText: Signal<String, Never> { get }

  /// Emits a string to use for the backers title label.
  var backersTitleLabelText: Signal<String, Never> { get }

  /// Emits a hide/show `Bool` for the read more campaign button if the compaign tab is enabled.
  var campaignTabShown: Signal<Bool, Never> { get }

  /// Emits a string to use for the category name label.
  var categoryNameLabelText: Signal<String, Never> { get }

  /// Emits a project when the video player controller should be configured.
  var configureVideoPlayerController: Signal<Project, Never> { get }

  /// Emits a boolean that determines if the conversion labels should be hidden.
  var conversionLabelHidden: Signal<Bool, Never> { get }

  /// Emits a string for the conversion label.
  var conversionLabelText: Signal<String, Never> { get }

  /// Emits an image url to be loaded into the creator's image view.
  var creatorImageUrl: Signal<URL?, Never> { get }

  /// Emits text to be put into the creator label.
  var creatorLabelText: Signal<String, Never> { get }

  /// Emits the text for the deadline subtitle label.
  var deadlineSubtitleLabelText: Signal<String, Never> { get }

  /// Emits the text for the deadline title label.
  var deadlineTitleLabelText: Signal<String, Never> { get }

  /// Emits the background color of the funding progress bar view.
  var fundingProgressBarViewBackgroundColor: Signal<UIColor, Never> { get }

  /// Emits a string to use for the location name label.
  var locationNameLabelText: Signal<String, Never> { get }

  /// Emits the project and ref tag when we should go to the campaign view for the project.
  var notifyDelegateToGoToCampaignWithData: Signal<ProjectPamphletMainCellData, Never> { get }

  /// Emits the project when we should go to the creator's view for the project.
  var notifyDelegateToGoToCreator: Signal<Project, Never> { get }

  /// Emits an alpha value for views to create transition after full project loads.
  var opacityForViews: Signal<CGFloat, Never> { get }

  /// Emits the text for the pledged subtitle label.
  var pledgedSubtitleLabelText: Signal<String, Never> { get }

  /// Emits the text for the pledged title label.
  var pledgedTitleLabelText: Signal<String, Never> { get }

  /// Emits the text color of the pledged title label.
  var pledgedTitleLabelTextColor: Signal<UIColor, Never> { get }

  /// Emits a percentage between 0.0 and 1.0 that can be used to render the funding progress bar.
  var progressPercentage: Signal<Float, Never> { get }

  /// Emits text to be put into the project blurb label.
  var projectBlurbLabelText: Signal<String, Never> { get }

  /// Emits a URL to be loaded into the project's image view.
  var projectImageUrl: Signal<URL?, Never> { get }

  /// Emits text to be put into the project name label.
  var projectNameLabelText: Signal<String, Never> { get }

  /// Emits a string that should be put into the project state label.
  var projectStateLabelText: Signal<String, Never> { get }

  /// Emits the text color of the project state label.
  var projectStateLabelTextColor: Signal<UIColor, Never> { get }

  /// Emits the text color of the backer and deadline title label.
  var projectUnsuccessfulLabelTextColor: Signal<UIColor, Never> { get }

  /// Emits a boolean that determines if the project state label should be hidden.
  var stateLabelHidden: Signal<Bool, Never> { get }

  /// Emits a string to use for the stats stack view accessibility value.
  var statsStackViewAccessibilityLabel: Signal<String, Never> { get }

  /// Emits a boolean that determines if the "you're a backer" label should be hidden.
  var youreABackerLabelHidden: Signal<Bool, Never> { get }
}

public protocol ProjectPamphletMainCellViewModelType {
  var inputs: ProjectPamphletMainCellViewModelInputs { get }
  var outputs: ProjectPamphletMainCellViewModelOutputs { get }
}

public final class ProjectPamphletMainCellViewModel: ProjectPamphletMainCellViewModelType,
  ProjectPamphletMainCellViewModelInputs, ProjectPamphletMainCellViewModelOutputs {
  public init() {
    let data = Signal.combineLatest(
      self.dataProperty.signal.skipNil(),
      self.awakeFromNibProperty.signal
    )
    .map(first)

    let project = data.map(first)

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
      .map { $0.state == .successful ? UIColor.ksr_create_700 : UIColor.ksr_support_400 }

    self.fundingProgressBarViewBackgroundColor = project
      .map(progressColor(forProject:))

    self.projectUnsuccessfulLabelTextColor = project
      .map { $0.state == .successful || $0.state == .live ?
        UIColor.ksr_support_400 : UIColor.ksr_support_400
      }

    self.pledgedTitleLabelTextColor = project
      .map { $0.state == .successful || $0.state == .live ?
        UIColor.ksr_create_700 : UIColor.ksr_support_400
      }

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
      let parts = string.split(separator: "\n").map(String.init)
      return (parts.first, parts.last)
    }

    self.backersTitleLabelText = backersTitleAndSubtitleText.map { title, _ in title ?? "" }
    self.backersSubtitleLabelText = backersTitleAndSubtitleText.map { _, subtitle in subtitle ?? "" }

    self.categoryNameLabelText = project.map { $0.category.name }

    let deadlineTitleAndSubtitle = project.map {
      Format.duration(secondsInUTC: $0.dates.deadline, useToGo: true)
    }

    self.deadlineTitleLabelText = deadlineTitleAndSubtitle.map(first)
    self.deadlineSubtitleLabelText = deadlineTitleAndSubtitle.map(second)

    let projectAndNeedsConversion = project.map { project -> (Project, Bool) in
      (
        project,
        project.stats.needsConversion
      )
    }

    self.conversionLabelHidden = projectAndNeedsConversion.map(second).map(negate)

    self.locationNameLabelText = project.map { $0.location.displayableName }

    self.pledgedTitleLabelText = projectAndNeedsConversion.map { project, needsConversion in
      pledgedText(for: project, needsConversion)
    }

    self.pledgedSubtitleLabelText = projectAndNeedsConversion.map { project, needsConversion in
      goalText(for: project, needsConversion)
    }

    self.conversionLabelText = projectAndNeedsConversion.filter(second).map(first).map { project in
      conversionText(for: project)
    }

    self.statsStackViewAccessibilityLabel = projectAndNeedsConversion
      .map(statsStackViewAccessibilityLabelForProject(_:needsConversion:))

    self.progressPercentage = project
      .map(Project.lens.stats.fundingProgress.view)
      .map(clamp(0, 1))

    self.notifyDelegateToGoToCampaignWithData = data
      .takeWhen(self.readMoreButtonTappedProperty.signal)

    self.notifyDelegateToGoToCreator = project
      .takeWhen(self.creatorButtonTappedProperty.signal)

    self.configureVideoPlayerController = Signal.combineLatest(project, self.delegateDidSetProperty.signal)
      .map(first)
      .take(first: 1)

    self.opacityForViews = Signal.merge(
      self.dataProperty.signal.skipNil().mapConst(1.0),
      self.awakeFromNibProperty.signal.mapConst(0.0)
    )

    // Tracking

    self.notifyDelegateToGoToCampaignWithData
      .observeValues { project, _ in
        AppEnvironment.current.ksrAnalytics.trackCampaignDetailsButtonClicked(project: project)
      }

    self.notifyDelegateToGoToCreator.observeValues { project in
      AppEnvironment.current.ksrAnalytics.trackGotoCreatorDetailsClicked(project: project)
    }

    self.campaignTabShown = project.ignoreValues()
      .map(campaignTabEnabled)
  }

  private let awakeFromNibProperty = MutableProperty(())
  public func awakeFromNib() {
    self.awakeFromNibProperty.value = ()
  }

  fileprivate let dataProperty
    = MutableProperty<ProjectPamphletMainCellData?>(nil)
  public func configureWith(value: ProjectPamphletMainCellData) {
    self.dataProperty.value = value
  }

  fileprivate let creatorButtonTappedProperty = MutableProperty(())
  public func creatorButtonTapped() {
    self.creatorButtonTappedProperty.value = ()
  }

  fileprivate let delegateDidSetProperty = MutableProperty(())
  public func delegateDidSet() {
    self.delegateDidSetProperty.value = ()
  }

  fileprivate let readMoreButtonTappedProperty = MutableProperty(())
  public func readMoreButtonTapped() {
    self.readMoreButtonTappedProperty.value = ()
  }

  fileprivate let videoDidFinishProperty = MutableProperty(())
  public func videoDidFinish() {
    self.videoDidFinishProperty.value = ()
  }

  fileprivate let videoDidStartProperty = MutableProperty(())
  public func videoDidStart() {
    self.videoDidStartProperty.value = ()
  }

  public let backersSubtitleLabelText: Signal<String, Never>
  public let backersTitleLabelText: Signal<String, Never>
  public let categoryNameLabelText: Signal<String, Never>
  public let campaignTabShown: Signal<Bool, Never>
  public let configureVideoPlayerController: Signal<Project, Never>
  public let conversionLabelHidden: Signal<Bool, Never>
  public let conversionLabelText: Signal<String, Never>
  public let creatorImageUrl: Signal<URL?, Never>
  public let creatorLabelText: Signal<String, Never>
  public let deadlineSubtitleLabelText: Signal<String, Never>
  public let deadlineTitleLabelText: Signal<String, Never>
  public let fundingProgressBarViewBackgroundColor: Signal<UIColor, Never>
  public let locationNameLabelText: Signal<String, Never>
  public let notifyDelegateToGoToCampaignWithData: Signal<ProjectPamphletMainCellData, Never>
  public let notifyDelegateToGoToCreator: Signal<Project, Never>
  public let opacityForViews: Signal<CGFloat, Never>
  public let pledgedSubtitleLabelText: Signal<String, Never>
  public let pledgedTitleLabelText: Signal<String, Never>
  public let pledgedTitleLabelTextColor: Signal<UIColor, Never>
  public let progressPercentage: Signal<Float, Never>
  public let projectBlurbLabelText: Signal<String, Never>
  public let projectImageUrl: Signal<URL?, Never>
  public let projectNameLabelText: Signal<String, Never>
  public let projectStateLabelText: Signal<String, Never>
  public let projectStateLabelTextColor: Signal<UIColor, Never>
  public let projectUnsuccessfulLabelTextColor: Signal<UIColor, Never>
  public let stateLabelHidden: Signal<Bool, Never>
  public let statsStackViewAccessibilityLabel: Signal<String, Never>
  public let youreABackerLabelHidden: Signal<Bool, Never>

  public var inputs: ProjectPamphletMainCellViewModelInputs { return self }
  public var outputs: ProjectPamphletMainCellViewModelOutputs { return self }
}

private func statsStackViewAccessibilityLabelForProject(_ project: Project, needsConversion: Bool) -> String {
  let projectCurrencyData = pledgeAmountAndGoalAndCountry(
    forProject: project,
    needsConversion: needsConversion
  )

  let pledged = Format.currency(
    projectCurrencyData.pledgedAmount,
    country: projectCurrencyData.country,
    omitCurrencyCode: project.stats.omitUSCurrencyCode
  )
  let goal = Format.currency(
    projectCurrencyData.goalAmount,
    country: projectCurrencyData.country,
    omitCurrencyCode: project.stats.omitUSCurrencyCode
  )

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
  let date = Format.date(
    secondsInUTC: project.dates.stateChangedAt,
    dateStyle: .medium,
    timeStyle: .none
  )

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

private func campaignTabEnabled() -> Bool {
  featureProjectPageStoryTabEnabled()
}

typealias ConvertedCurrrencyProjectData = (pledgedAmount: Int, goalAmount: Int, country: Project.Country)

private func pledgeAmountAndGoalAndCountry(
  forProject project: Project,
  needsConversion: Bool
) -> ConvertedCurrrencyProjectData {
  guard needsConversion else {
    let pledgedCurrencyCountry = projectCountry(forCurrency: project.stats.currency) ?? project
      .country
    return (project.stats.pledged, project.stats.goal, pledgedCurrencyCountry)
  }

  guard let goalCurrentCurrency = project.stats.goalCurrentCurrency,
    let pledgedCurrentCurrency = project.stats.convertedPledgedAmount,
    let currentCountry = project.stats.currentCountry else {
    return (Int(project.stats.pledgedUsd), Int(project.stats.goalUsd), Project.Country.us)
  }

  return (Int(pledgedCurrentCurrency), Int(goalCurrentCurrency), currentCountry)
}

private func goalText(for project: Project, _ needsConversion: Bool) -> String {
  let projectCurrencyData = pledgeAmountAndGoalAndCountry(
    forProject: project,
    needsConversion: needsConversion
  )

  return Strings.activity_project_state_change_pledged_of_goal(
    goal: Format.currency(
      projectCurrencyData.goalAmount,
      country: projectCurrencyData.country,
      omitCurrencyCode: project.stats.omitUSCurrencyCode
    )
  )
}

private func pledgedText(for project: Project, _ needsConversion: Bool) -> String {
  let projectCurrencyData = pledgeAmountAndGoalAndCountry(
    forProject: project,
    needsConversion: needsConversion
  )

  return Format.currency(
    projectCurrencyData.pledgedAmount,
    country: projectCurrencyData.country,
    omitCurrencyCode: project.stats.omitUSCurrencyCode
  )
}

private func conversionText(for project: Project) -> String {
  let pledgedCurrencyCountry = projectCountry(forCurrency: project.stats.currency) ?? project
    .country

  let goalCurrencyCountry = projectCountry(forCurrency: project.stats.currency) ??
    pledgedCurrencyCountry

  return Strings.discovery_baseball_card_stats_convert_from_pledged_of_goal(
    pledged: Format.currency(
      project.stats.pledged,
      country: pledgedCurrencyCountry,
      omitCurrencyCode: project.stats.omitUSCurrencyCode
    ),
    goal: Format.currency(
      project.stats.goal,
      country: goalCurrencyCountry,
      omitCurrencyCode: project.stats.omitUSCurrencyCode
    )
  )
}

private func progressColor(forProject project: Project) -> UIColor {
  switch project.state {
  case .canceled, .failed, .suspended:
    return .ksr_support_400
  default:
    return .ksr_create_700
  }
}
