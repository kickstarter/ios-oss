import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ProjectPamphletMainCellViewModelInputs {
  /// Call with the project provided to the view controller.
  func configureWith(project project: Project)
}

public protocol ProjectPamphletMainCellViewModelOutputs {
  /// Emits a string to use for the stats stack view accessibility value.
  var allStatsStackViewAccessibilityValue: Signal<String, NoError> { get }

  /// Emits a string to use for the backers title label.
  var backersTitleLabelText: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the conversion labels should be hidden.
  var conversionLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a string for the conversion label.
  var conversionLabelText: Signal<String, NoError> { get }

  /// Emits an image url to be loaded into the creator's image view.
  var creatorImageUrl: Signal<NSURL?, NoError> { get }

  /// Emits text to be put into the creator label.
  var creatorLabelText: Signal<String, NoError> { get }

  /// Emits the text for the deadine subtitle label.
  var deadlineSubtitleLabelText: Signal<String, NoError> { get }

  /// Emits the text for the deadline title label.
  var deadlineTitleLabelText: Signal<String, NoError> { get }

  /// Emits the text for the pledged subtitle label.
  var pledgedSubtitleLabelText: Signal<String, NoError> { get }

  /// Emits the text for the pledged title label.
  var pledgedTitleLabelText: Signal<String, NoError> { get }

  /// Emits a percentage between 0.0 and 1.0 that can be used to render the funding progress bar.
  var progressPercentage: Signal<Float, NoError> { get }

  /// Emits text to be put into the project blurb label.
  var projectBlurbLabelText: Signal<String, NoError> { get }

  /// Emits a URL to be loaded into the project's image view.
  var projectImageUrl: Signal<NSURL?, NoError> { get }

  /// Emits text to be put into the project name label.
  var projectNameLabelText: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the project state label should be hidden.
  var projectStateLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a string that should be put into the project state label.
  var projectStateLabelText: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the "you're a backer" label should be hidden.
  var youreABackerLabelHidden: Signal<Bool, NoError> { get }
}

public protocol ProjectPamphletMainCellViewModelType {
  var inputs: ProjectPamphletMainCellViewModelInputs { get }
  var outputs: ProjectPamphletMainCellViewModelOutputs { get }
}

public final class ProjectPamphletMainCellViewModel: ProjectPamphletMainCellViewModelType,
ProjectPamphletMainCellViewModelInputs, ProjectPamphletMainCellViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let project = self.projectProperty.signal.ignoreNil()

    self.projectNameLabelText = project.map(Project.lens.name.view)
    self.projectBlurbLabelText = project.map(Project.lens.blurb.view)

    self.creatorLabelText = project.map {
      Strings.project_creator_by_creator(creator_name: $0.creator.name)
    }

    self.creatorImageUrl = project.map { NSURL(string: $0.creator.avatar.small) }

    self.projectStateLabelHidden = project.map { $0.state == .live }

    self.projectStateLabelText = project
      .filter { $0.state != .live }
      .map(fundingStatus(forProject:))

    self.projectImageUrl = project.map { NSURL(string: $0.photo.full) }

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
      guard needsConversion else {
        return Strings.activity_project_state_change_pledged_of_goal(
          goal: Format.currency(project.stats.goal, country: project.country)
        )
      }

      return Strings.activity_project_state_change_pledged_of_goal(
        goal: Format.currency(project.stats.goalUsd, country: .US)
      )
    }

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

    self.progressPercentage = project
      .map(Project.lens.stats.fundingProgress.view)
      .map(clamp(0, 1))
  }
  // swiftlint:enable function_body_length

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  public let allStatsStackViewAccessibilityValue: Signal<String, NoError>
  public let backersTitleLabelText: Signal<String, NoError>
  public let conversionLabelHidden: Signal<Bool, NoError>
  public let conversionLabelText: Signal<String, NoError>
  public let creatorImageUrl: Signal<NSURL?, NoError>
  public let creatorLabelText: Signal<String, NoError>
  public let deadlineSubtitleLabelText: Signal<String, NoError>
  public let deadlineTitleLabelText: Signal<String, NoError>
  public let pledgedSubtitleLabelText: Signal<String, NoError>
  public let pledgedTitleLabelText: Signal<String, NoError>
  public let progressPercentage: Signal<Float, NoError>
  public let projectBlurbLabelText: Signal<String, NoError>
  public let projectImageUrl: Signal<NSURL?, NoError>
  public let projectNameLabelText: Signal<String, NoError>
  public let projectStateLabelHidden: Signal<Bool, NoError>
  public let projectStateLabelText: Signal<String, NoError>
  public let youreABackerLabelHidden: Signal<Bool, NoError>

  public var inputs: ProjectPamphletMainCellViewModelInputs { return self }
  public var outputs: ProjectPamphletMainCellViewModelOutputs { return self }
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
