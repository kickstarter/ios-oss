import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ProjectHeaderViewModelInputs {
  /// Call when the campaign tab button is tapped.
  func campaignTabButtonTapped()

  /// Call when the comments button is tapped.
  func commentsButtonTapped()

  /// Call with the project provided to the view controller.
  func configureWith(project project: Project)

  /// Call when the rewards button is tapped.
  func rewardsButtonTapped()

  /// Call when the rewards tab button is tapped.
  func rewardsTabButtonTapped()

  /// Call when the updates button is tapped.
  func updatesButtonTapped()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view appears.
  func viewWillAppear()
}

public protocol ProjectHeaderViewModelOutputs {
  /// Emits a string to use for the stats stack view accessibility value.
  var allStatsStackViewAccessibilityValue: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the "you're a backer" label should be hidden.
  var youreABackerLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a string to use for the backers title label.
  var backersTitleLabelText: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the campaign button is selected.
  var campaignButtonSelected: Signal<Bool, NoError> { get }

  /// Emits when the campaign selected indicator view should be shown/hidden.
  var campaignSelectedViewHidden: Signal<Bool, NoError> { get }

  /// Emits a string to use for the comments button accessibility label.
  var commentsButtonAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the text of the comments label.
  var commentsLabelText: Signal<String, NoError> { get }

  /// Emits a project that should be used to configure video view controller.
  var configureVideoViewControllerWithProject: Signal<Project, NoError> { get }

  /// Emits a boolean that determines if the conversion labels should be hidden.
  var conversionLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a string for the conversion label.
  var conversionLabelText: Signal<String, NoError> { get }

  /// Emits the text for the deadine subtitle label.
  var deadlineSubtitleLabelText: Signal<String, NoError> { get }

  /// Emits the text for the deadline title label.
  var deadlineTitleLabelText: Signal<String, NoError> { get }

  /// Emits the project when we should navigate to the comments of that project.
  var goToComments: Signal<Project, NoError> { get }

  /// Emits the project when we should navigate to the updates of that project.
  var goToUpdates: Signal<Project, NoError> { get }

  /// Emits when the delegate should be notified to show the campaign tab.
  var notifyDelegateToShowCampaignTab: Signal<(), NoError> { get }

  /// Emits when the delegate should be notified to show the rewards tab.
  var notifyDelegateToShowRewardsTab: Signal<(), NoError> { get }

  /// Emits the text for the pledged subtitle label.
  var pledgedSubtitleLabelText: Signal<String, NoError> { get }

  /// Emits the text for the pledged title label.
  var pledgedTitleLabelText: Signal<String, NoError> { get }

  /// Emits a percentage between 0.0 and 1.0 that can be used to render the funding progress bar.
  var progressPercentage: Signal<Float, NoError> { get }

  /// Emits a URL to be loaded into the project's image view.
  var projectImageUrl: Signal<NSURL?, NoError> { get }

  /// Emits the text to be put into the project name and blurb label.
  var projectNameAndBlurbLabelText: Signal<NSAttributedString, NoError> { get }

  /// Emits a boolean that determines if the project state label should be hidden.
  var projectStateLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a string that should be put into the project state label.
  var projectStateLabelText: Signal<String, NoError> { get }

  /// Emits the accessibility label for the rewards subpage button.
  var rewardsButtonAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the rewards button is selectd.
  var rewardsTabButtonSelected: Signal<Bool, NoError> { get }

  /// Emits the title of the rewards button.
  var rewardsTabButtonTitleText: Signal<String, NoError> { get }

  /// Emits the title of the rewards label.
  var rewardsLabelText: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the rewards selected indicator view is hidden.
  var rewardsSelectedViewHidden: Signal<Bool, NoError> { get }

  /// Emits the accessibility label for the updates button.
  var updatesButtonAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the text for the updates label
  var updatesLabelText: Signal<String, NoError> { get }
}

public protocol ProjectHeaderViewModelType {
  var inputs: ProjectHeaderViewModelInputs { get }
  var outputs: ProjectHeaderViewModelOutputs { get }
}

public final class ProjectHeaderViewModel: ProjectHeaderViewModelType, ProjectHeaderViewModelInputs,
ProjectHeaderViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let project = combineLatest(self.projectProperty.signal.ignoreNil(), self.viewDidLoadProperty.signal)
      .map(first)

    self.configureVideoViewControllerWithProject = project

    self.projectNameAndBlurbLabelText = project
      .map(projectAttributedNameAndBlurb)

    self.projectStateLabelHidden = project.map { $0.state == .live }

    self.projectStateLabelText = project
      .filter { $0.state != .live }
      .map(fundingStatus(forProject:))

    self.projectImageUrl = project.map { NSURL(string: $0.photo.full) }

    let rewardsCount = project
      .map { project in project.rewards.filter { !$0.isNoReward }.count }

    self.rewardsLabelText = rewardsCount
      .map { String($0) }

    self.commentsLabelText = project
      .map { Format.wholeNumber($0.stats.commentsCount ?? 0) }

    self.updatesLabelText = project
      .map { String($0.stats.updatesCount ?? 0) }

    self.rewardsTabButtonTitleText = rewardsCount
      .map { "\(Strings.project_subpages_menu_buttons_rewards()) (\($0))" }

    self.campaignSelectedViewHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      self.campaignTabButtonTappedProperty.signal.mapConst(false),
      self.rewardsTabButtonTappedProperty.signal.mapConst(true),
      self.rewardsButtonTappedProperty.signal.mapConst(true)
      )
      .skipRepeats()

    self.campaignButtonSelected = self.campaignSelectedViewHidden.map(negate)

    self.rewardsSelectedViewHidden = self.campaignSelectedViewHidden.map(negate)
    self.rewardsTabButtonSelected = self.campaignButtonSelected.map(negate)

    self.notifyDelegateToShowCampaignTab = combineLatest(
      self.viewWillAppearProperty.signal.take(1),
      self.campaignButtonSelected.filter(isTrue).ignoreValues()
      )
      .map(first)
    self.notifyDelegateToShowRewardsTab = combineLatest(
      self.viewWillAppearProperty.signal.take(1),
      self.rewardsTabButtonSelected.filter(isTrue).ignoreValues()
      )
      .map(first)

    self.youreABackerLabelHidden = project.map { $0.personalization.isBacking != true }
    self.backersTitleLabelText = project.map { Format.wholeNumber($0.stats.backersCount) }

    let deadlineTitleAndSubtitle = project.map {
      return Format.duration(secondsInUTC: $0.dates.deadline, useToGo: true) ?? ("", "")
    }

    self.deadlineTitleLabelText = deadlineTitleAndSubtitle.map(first)
    self.deadlineSubtitleLabelText = deadlineTitleAndSubtitle.map(second)

    let projectAndNeedsConversion = project.map { project -> (Project, Bool) in
      (
        project,
        AppEnvironment.current.config?.countryCode == "US" && project.country != .US
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

    self.pledgedTitleLabelText = projectAndNeedsConversion.map { project, needsConversion in
      needsConversion
        ? Format.currency(project.stats.pledgedUsd, country: .US)
        : Format.currency(project.stats.pledgedUsd, country: project.country)
    }

    self.pledgedSubtitleLabelText = projectAndNeedsConversion.map { project, needsConversion in
      if needsConversion {
        return Strings.activity_project_state_change_pledged_of_goal(
          goal: Format.currency(project.stats.goalUsd, country: .US)
        )
      }
      return Strings.activity_project_state_change_pledged_of_goal(
        goal: Format.currency(project.stats.goal, country: project.country)
      )
    }

    self.goToComments = project.takeWhen(self.commentsButtonTappedProperty.signal)

    self.goToUpdates = project.takeWhen(self.updatesButtonTappedProperty.signal)

    self.allStatsStackViewAccessibilityValue = project
      .map { project in

      let pledged = Format.currency(project.stats.pledged, country: project.country)
      let goal = Format.currency(project.stats.goal, country: project.country)
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

    self.rewardsButtonAccessibilityLabel = rewardsCount
      .map { Strings.rewards_count_rewards(rewards_count: Format.wholeNumber($0)) }

    self.commentsButtonAccessibilityLabel = project
      .map { p in
        Strings.comments_count_comments(comments_count: Format.wholeNumber(p.stats.commentsCount ?? 0))
    }

    self.updatesButtonAccessibilityLabel = project
      .map { p in
        Strings.updates_count_updates(updates_count: Format.wholeNumber(p.stats.updatesCount ?? 0))
    }

    self.progressPercentage = project
      .map(Project.lens.stats.fundingProgress.view)
      .map(clamp(0, 1))
  }
  // swiftlint:enable function_body_length

  private let campaignTabButtonTappedProperty = MutableProperty()
  public func campaignTabButtonTapped() {
    self.campaignTabButtonTappedProperty.value = ()
  }

  private let commentsButtonTappedProperty = MutableProperty()
  public func commentsButtonTapped() {
    self.commentsButtonTappedProperty.value = ()
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  private let rewardsButtonTappedProperty = MutableProperty()
  public func rewardsButtonTapped() {
    self.rewardsButtonTappedProperty.value = ()
  }

  private let rewardsTabButtonTappedProperty = MutableProperty()
  public func rewardsTabButtonTapped() {
    self.rewardsTabButtonTappedProperty.value = ()
  }

  private let updatesButtonTappedProperty = MutableProperty()
  public func updatesButtonTapped() {
    self.updatesButtonTappedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let allStatsStackViewAccessibilityValue: Signal<String, NoError>
  public let youreABackerLabelHidden: Signal<Bool, NoError>
  public let backersTitleLabelText: Signal<String, NoError>
  public let campaignButtonSelected: Signal<Bool, NoError>
  public let campaignSelectedViewHidden: Signal<Bool, NoError>
  public let commentsButtonAccessibilityLabel: Signal<String, NoError>
  public let commentsLabelText: Signal<String, NoError>
  public let configureVideoViewControllerWithProject: Signal<Project, NoError>
  public let conversionLabelHidden: Signal<Bool, NoError>
  public let conversionLabelText: Signal<String, NoError>
  public let deadlineSubtitleLabelText: Signal<String, NoError>
  public let deadlineTitleLabelText: Signal<String, NoError>
  public let goToComments: Signal<Project, NoError>
  public var goToUpdates: Signal<Project, NoError>
  public let notifyDelegateToShowCampaignTab: Signal<(), NoError>
  public let notifyDelegateToShowRewardsTab: Signal<(), NoError>
  public let pledgedSubtitleLabelText: Signal<String, NoError>
  public let pledgedTitleLabelText: Signal<String, NoError>
  public let progressPercentage: Signal<Float, NoError>
  public let projectImageUrl: Signal<NSURL?, NoError>
  public let projectNameAndBlurbLabelText: Signal<NSAttributedString, NoError>
  public let projectStateLabelHidden: Signal<Bool, NoError>
  public let projectStateLabelText: Signal<String, NoError>
  public let rewardsButtonAccessibilityLabel: Signal<String, NoError>
  public let rewardsTabButtonSelected: Signal<Bool, NoError>
  public let rewardsTabButtonTitleText: Signal<String, NoError>
  public let rewardsLabelText: Signal<String, NoError>
  public let rewardsSelectedViewHidden: Signal<Bool, NoError>
  public let updatesButtonAccessibilityLabel: Signal<String, NoError>
  public let updatesLabelText: Signal<String, NoError>

  public var inputs: ProjectHeaderViewModelInputs { return self }
  public var outputs: ProjectHeaderViewModelOutputs { return self }
}

private func fundingStatus(forProject project: Project) -> String {
  let date = Format.date(secondsInUTC: project.dates.stateChangedAt,
                         dateStyle: .MediumStyle,
                         timeStyle: .NoStyle)

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
