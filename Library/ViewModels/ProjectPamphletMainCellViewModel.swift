import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol HasProjectPamphletMainCellProperties {
  var projectPamphletMainCellProperties: ProjectPamphletMainCellProperties { get }
}

public typealias ProjectPamphletMainCellConfiguration = HasProjectPamphletMainCellProperties &
  ProjectAnalyticsProperties &
  ProjectCreatorConfiguration &
  VideoViewConfiguration

public struct ProjectPamphletMainCellProperties {
  public let param: Param
  public let name: String
  public let blurb: String
  public let creatorName: String
  public let creatorAvatarURL: String
  public let creatorId: Int
  public let isCreatorBlocked: Bool
  public let state: Project.State
  public let stateChangedAt: TimeInterval
  public let photo: String
  public let displayPrelaunch: Bool?
  public let isBacking: Bool?
  public let backersCount: Int
  public let categoryName: String
  public let locationName: String
  public let deadline: TimeInterval?
  public let needsConversion: Bool
  public let fundingProgress: Float
  public let goal: Int
  public let pledged: Int
  public let goalCurrentCurrency: Float?
  public let convertedPledgedAmount: Float?
  public let currentCountry: Project.Country?
  public let pledgedUsd: Float
  public let goalUsd: Float
  public let omitUSCurrencyCode: Bool
  public let currency: String
  public let country: Project.Country
  public let projectNotice: String?
  public let video: (hls: String?, high: String)?
  public let webURL: String

  public init(
    param: Param,
    name: String,
    blurb: String,
    creatorName: String,
    creatorAvatarURL: String,
    creatorId: Int,
    isCreatorBlocked: Bool,
    state: Project.State,
    stateChangedAt: TimeInterval,
    photo: String,
    displayPrelaunch: Bool?,
    isBacking: Bool?,
    backersCount: Int,
    categoryName: String,
    locationName: String,
    deadline: TimeInterval?,
    needsConversion: Bool,
    fundingProgress: Float,
    goal: Int,
    pledged: Int,
    goalCurrentCurrency: Float?,
    convertedPledgedAmount: Float?,
    currentCountry: Project.Country?,
    pledgedUsd: Float,
    goalUsd: Float,
    omitUSCurrencyCode: Bool,
    currency: String,
    country: Project.Country,
    projectNotice: String?,
    video: (hls: String?, high: String)?,
    webURL: String
  ) {
    self.param = param
    self.name = name
    self.blurb = blurb
    self.creatorName = creatorName
    self.creatorAvatarURL = creatorAvatarURL
    self.creatorId = creatorId
    self.isCreatorBlocked = isCreatorBlocked
    self.state = state
    self.stateChangedAt = stateChangedAt
    self.photo = photo
    self.displayPrelaunch = displayPrelaunch
    self.isBacking = isBacking
    self.backersCount = backersCount
    self.categoryName = categoryName
    self.locationName = locationName
    self.deadline = deadline
    self.needsConversion = needsConversion
    self.fundingProgress = fundingProgress
    self.goal = goal
    self.pledged = pledged
    self.goalCurrentCurrency = goalCurrentCurrency
    self.convertedPledgedAmount = convertedPledgedAmount
    self.currentCountry = currentCountry
    self.pledgedUsd = pledgedUsd
    self.goalUsd = goalUsd
    self.omitUSCurrencyCode = omitUSCurrencyCode
    self.currency = currency
    self.country = country
    self.projectNotice = projectNotice
    self.video = video
    self.webURL = webURL
  }
}

extension Project: HasProjectPamphletMainCellProperties {
  public var projectPamphletMainCellProperties: ProjectPamphletMainCellProperties {
    ProjectPamphletMainCellProperties(
      param: .id(self.id),
      name: self.name,
      blurb: self.blurb,
      creatorName: self.creator.name,
      creatorAvatarURL: self.creator.avatar.small,
      creatorId: self.creator.id,
      isCreatorBlocked: self.creator.isBlocked,
      state: self.state,
      stateChangedAt: self.dates.stateChangedAt,
      photo: self.photo.full,
      displayPrelaunch: self.displayPrelaunch,
      isBacking: self.personalization.isBacking,
      backersCount: self.stats.backersCount,
      categoryName: self.category.name,
      locationName: self.location.displayableName,
      deadline: self.dates.deadline,
      needsConversion: self.stats.needsConversion,
      fundingProgress: self.stats.fundingProgress,
      goal: self.stats.goal,
      pledged: self.stats.pledged,
      goalCurrentCurrency: self.stats.goalCurrentCurrency,
      convertedPledgedAmount: self.stats.convertedPledgedAmount,
      currentCountry: self.stats.currentCountry,
      pledgedUsd: self.stats.pledgedUsd,
      goalUsd: self.stats.goalUsd,
      omitUSCurrencyCode: self.stats.omitUSCurrencyCode,
      currency: self.stats.currency,
      country: self.country,
      projectNotice: self.extendedProjectProperties?.projectNotice,
      video: self.video.map { ($0.hls, $0.high) },
      webURL: self.urls.web.project
    )
  }
}

public typealias ProjectPamphletMainCellData = (
  project: any ProjectPamphletMainCellConfiguration,
  refTag: RefTag?
)

public protocol ProjectPamphletMainCellViewModelInputs {
  /// Call when cell awakeFromNib is called.
  func awakeFromNib()

  /// Call with the ProjectPamphletMainCellData provided to the view controller.
  func configureWith(value: ProjectPamphletMainCellData)

  /// Call when the creator button is tapped.
  func creatorButtonTapped()

  /// Call when the delegate has been set on the cell.
  func delegateDidSet()

  /// Call when the project notice learn more button is tapped.
  func projectNoticeLearnMoreTapped()

  func videoDidFinish()
  func videoDidStart()
}

public protocol ProjectPamphletMainCellViewModelOutputs {
  /// Emits a string to use for the backer subtitle label.
  var backersSubtitleLabelText: Signal<String, Never> { get }

  /// Emits a string to use for the backers title label.
  var backersTitleLabelText: Signal<String, Never> { get }

  /// Emits a string to use for the category name label.
  var categoryNameLabelText: Signal<String, Never> { get }

  /// Emits a project when the video player controller should be configured.
  var configureVideoPlayerController: Signal<any ProjectPamphletMainCellConfiguration, Never> { get }

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

  /// Emits the prelaunch project state. Used to hide/show progress bar and stats view.
  var isPrelaunchProject: Signal<Bool, Never> { get }

  /// Emits a string to use for the location name label.
  var locationNameLabelText: Signal<String, Never> { get }

  /// Emits the project when we should go to the creator's view for the project.
  var notifyDelegateToGoToCreator: Signal<any ProjectPamphletMainCellConfiguration, Never> { get }

  /// Emits the project when project notice details should be displayed.
  var notifyDelegateToGoToProjectNotice: Signal<(), Never> { get }

  /// Emits an alpha value for views to create transition after full project loads.
  var opacityForViews: Signal<CGFloat, Never> { get }

  /// Emits the text for the pledged subtitle label.
  var pledgedSubtitleLabelText: Signal<String, Never> { get }

  /// Emits the text for the pledged title label.
  var pledgedTitleLabelText: Signal<String, Never> { get }

  /// Emits the text color of the pledged title label.
  var pledgedTitleLabelTextColor: Signal<UIColor, Never> { get }

  /// Emits a string for the backing label, which could be "you're a backer" or "coming soon".
  var prelaunchProjectBackingText: Signal<String, Never> { get }

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

  /// Emits a boolean that determines if the "you're a backer" or "coming soon" label should be hidden.
  var backingLabelHidden: Signal<Bool, Never> { get }

  /// Emits false if the project notice banner should be shown.
  var projectNoticeBannerHidden: Signal<Bool, Never> { get }
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
    let properties = project.map { $0.projectPamphletMainCellProperties }

    self.projectNameLabelText = properties.map { $0.name }
    self.projectBlurbLabelText = properties.map { $0.blurb }

    self.creatorLabelText = properties.map {
      Strings.project_creator_by_creator(creator_name: $0.creatorName)
    }

    self.creatorImageUrl = properties.map { URL(string: $0.creatorAvatarURL) }

    self.stateLabelHidden = properties.map { $0.state == .live }

    self.projectStateLabelText = properties
      .filter { $0.state != .live }
      .map(fundingStatus(forProperties:))

    self.projectStateLabelTextColor = properties
      .filter { $0.state != .live }
      .map { $0.state == .successful ? UIColor.ksr_create_700 : UIColor.ksr_support_400 }

    self.fundingProgressBarViewBackgroundColor = properties
      .map(progressColor(forProperties:))

    self.projectUnsuccessfulLabelTextColor = properties
      .map { $0.state == .successful || $0.state == .live ?
        UIColor.ksr_support_400 : UIColor.ksr_support_400
      }

    self.pledgedTitleLabelTextColor = properties
      .map { $0.state == .successful || $0.state == .live ?
        UIColor.ksr_create_700 : UIColor.ksr_support_400
      }

    self.prelaunchProjectBackingText = properties
      .map { $0.displayPrelaunch == .some(true) ?
        Strings.Coming_soon() : Strings.Youre_a_backer()
      }

    self.projectImageUrl = properties.map { URL(string: $0.photo) }

    self.projectNoticeBannerHidden = properties.map {
      ($0.projectNotice ?? "") == ""
    }

    let videoIsPlaying = Signal.merge(
      project.take(first: 1).mapConst(false),
      self.videoDidStartProperty.signal.mapConst(true),
      self.videoDidFinishProperty.signal.mapConst(false)
    )

    self.backingLabelHidden = Signal.combineLatest(properties, videoIsPlaying)
      .map { properties, videoIsPlaying in
        guard let displayPrelaunch = properties.displayPrelaunch else {
          return true
        }

        guard !displayPrelaunch else {
          return false
        }

        return properties.isBacking != true || videoIsPlaying
      }
      .skipRepeats()

    let backersTitleAndSubtitleText = properties.map { properties -> (String?, String?) in
      let string = Strings.Backers_count_separator_backers(backers_count: properties.backersCount)
      let parts = string.split(separator: "\n").map(String.init)
      return (parts.first, parts.last)
    }

    self.backersTitleLabelText = backersTitleAndSubtitleText.map { title, _ in title ?? "" }
    self.backersSubtitleLabelText = backersTitleAndSubtitleText.map { _, subtitle in subtitle ?? "" }

    self.categoryNameLabelText = properties.map { $0.categoryName }

    let deadlineTitleAndSubtitle = properties.map { properties -> (String, String) in
      var durationValue = ("", "")

      if let deadline = properties.deadline {
        durationValue = Format.duration(secondsInUTC: deadline, useToGo: true)
      }

      return durationValue
    }

    self.deadlineTitleLabelText = deadlineTitleAndSubtitle.map(first)
    self.deadlineSubtitleLabelText = deadlineTitleAndSubtitle.map(second)

    let propertiesAndNeedsConversion = properties.map { properties -> (
      ProjectPamphletMainCellProperties,
      Bool
    ) in
      (
        properties,
        properties.needsConversion
      )
    }

    self.conversionLabelHidden = propertiesAndNeedsConversion.map(second).map(negate)

    self.locationNameLabelText = properties.map { $0.locationName }

    self.pledgedTitleLabelText = propertiesAndNeedsConversion.map { properties, needsConversion in
      pledgedText(for: properties, needsConversion)
    }

    self.pledgedSubtitleLabelText = propertiesAndNeedsConversion.map { properties, needsConversion in
      goalText(for: properties, needsConversion)
    }

    self.conversionLabelText = propertiesAndNeedsConversion.filter(second).map(first).map { properties in
      conversionText(for: properties)
    }

    self.statsStackViewAccessibilityLabel = propertiesAndNeedsConversion
      .map(statsStackViewAccessibilityLabelForProperties(_:needsConversion:))

    self.isPrelaunchProject = properties.map { $0.displayPrelaunch }.skipNil()

    self.progressPercentage = properties.map { $0.fundingProgress }.map(clamp(0, 1))

    self.notifyDelegateToGoToCreator = project
      .takeWhen(self.creatorButtonTappedProperty.signal)

    self.notifyDelegateToGoToProjectNotice = self.projectNoticeLearnMoreTappedProperty.signal

    self.configureVideoPlayerController = Signal.combineLatest(project, self.delegateDidSetProperty.signal)
      .map(first)
      .take(first: 1)

    self.opacityForViews = Signal.merge(
      self.dataProperty.signal.skipNil().mapConst(1.0),
      self.awakeFromNibProperty.signal.mapConst(0.0)
    )

    // Tracking

    self.notifyDelegateToGoToCreator.observeValues { project in
      AppEnvironment.current.ksrAnalytics.trackGotoCreatorDetailsClicked(project: project)
    }
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

  fileprivate let projectNoticeLearnMoreTappedProperty = MutableProperty(())
  public func projectNoticeLearnMoreTapped() {
    self.projectNoticeLearnMoreTappedProperty.value = ()
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
  public let configureVideoPlayerController: Signal<any ProjectPamphletMainCellConfiguration, Never>
  public let conversionLabelHidden: Signal<Bool, Never>
  public let conversionLabelText: Signal<String, Never>
  public let creatorImageUrl: Signal<URL?, Never>
  public let creatorLabelText: Signal<String, Never>
  public let deadlineSubtitleLabelText: Signal<String, Never>
  public let deadlineTitleLabelText: Signal<String, Never>
  public let isPrelaunchProject: Signal<Bool, Never>
  public let fundingProgressBarViewBackgroundColor: Signal<UIColor, Never>
  public let locationNameLabelText: Signal<String, Never>
  public let notifyDelegateToGoToCreator: Signal<any ProjectPamphletMainCellConfiguration, Never>
  public let notifyDelegateToGoToProjectNotice: Signal<(), Never>
  public let opacityForViews: Signal<CGFloat, Never>
  public let pledgedSubtitleLabelText: Signal<String, Never>
  public let pledgedTitleLabelText: Signal<String, Never>
  public let pledgedTitleLabelTextColor: Signal<UIColor, Never>
  public let prelaunchProjectBackingText: Signal<String, Never>
  public let progressPercentage: Signal<Float, Never>
  public let projectBlurbLabelText: Signal<String, Never>
  public let projectImageUrl: Signal<URL?, Never>
  public let projectNameLabelText: Signal<String, Never>
  public let projectStateLabelText: Signal<String, Never>
  public let projectStateLabelTextColor: Signal<UIColor, Never>
  public let projectUnsuccessfulLabelTextColor: Signal<UIColor, Never>
  public let stateLabelHidden: Signal<Bool, Never>
  public let statsStackViewAccessibilityLabel: Signal<String, Never>
  public let backingLabelHidden: Signal<Bool, Never>
  public let projectNoticeBannerHidden: Signal<Bool, Never>

  public var inputs: ProjectPamphletMainCellViewModelInputs { return self }
  public var outputs: ProjectPamphletMainCellViewModelOutputs { return self }
}

private func statsStackViewAccessibilityLabelForProperties(
  _ properties: ProjectPamphletMainCellProperties,
  needsConversion: Bool
) -> String {
  let projectCurrencyData = pledgeAmountAndGoalAndCountry(
    forProperties: properties,
    needsConversion: needsConversion
  )

  let pledged = Format.currency(
    projectCurrencyData.pledgedAmount,
    country: projectCurrencyData.country,
    omitCurrencyCode: properties.omitUSCurrencyCode
  )
  let goal = Format.currency(
    projectCurrencyData.goalAmount,
    country: projectCurrencyData.country,
    omitCurrencyCode: properties.omitUSCurrencyCode
  )

  let backersCount = properties.backersCount
  var (time, unit) = ("", "")

  if let deadline = properties.deadline {
    (time, unit) = Format.duration(secondsInUTC: deadline, useToGo: true)
  }

  let timeLeft = time + " " + unit

  return properties.state == .live
    ? Strings.dashboard_graphs_funding_accessibility_live_stat_value(
      pledged: pledged, goal: goal, backers_count: backersCount, time_left: timeLeft
    )
    : Strings.dashboard_graphs_funding_accessibility_non_live_stat_value(
      pledged: pledged, goal: goal, backers_count: backersCount, time_left: timeLeft
    )
}

private func fundingStatus(forProperties properties: ProjectPamphletMainCellProperties) -> String {
  let date = Format.date(
    secondsInUTC: properties.stateChangedAt,
    dateStyle: .medium,
    timeStyle: .none
  )

  switch properties.state {
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

typealias ConvertedCurrrencyProjectData = (pledgedAmount: Int, goalAmount: Int, country: Project.Country)

private func pledgeAmountAndGoalAndCountry(
  forProperties properties: ProjectPamphletMainCellProperties,
  needsConversion: Bool
) -> ConvertedCurrrencyProjectData {
  guard needsConversion else {
    let pledgedCurrencyCountry = projectCountry(forCurrency: properties.currency) ?? properties.country
    return (properties.pledged, properties.goal, pledgedCurrencyCountry)
  }

  guard let goalCurrentCurrency = properties.goalCurrentCurrency,
        let pledgedCurrentCurrency = properties.convertedPledgedAmount,
        let currentCountry = properties.currentCountry else {
    return (Int(properties.pledgedUsd), Int(properties.goalUsd), Project.Country.us)
  }

  return (Int(pledgedCurrentCurrency), Int(goalCurrentCurrency), currentCountry)
}

private func goalText(for properties: ProjectPamphletMainCellProperties, _ needsConversion: Bool) -> String {
  let projectCurrencyData = pledgeAmountAndGoalAndCountry(
    forProperties: properties,
    needsConversion: needsConversion
  )

  return Strings.activity_project_state_change_pledged_of_goal(
    goal: Format.currency(
      projectCurrencyData.goalAmount,
      country: projectCurrencyData.country,
      omitCurrencyCode: properties.omitUSCurrencyCode
    )
  )
}

private func pledgedText(
  for properties: ProjectPamphletMainCellProperties,
  _ needsConversion: Bool
) -> String {
  let projectCurrencyData = pledgeAmountAndGoalAndCountry(
    forProperties: properties,
    needsConversion: needsConversion
  )

  return Format.currency(
    projectCurrencyData.pledgedAmount,
    country: projectCurrencyData.country,
    omitCurrencyCode: properties.omitUSCurrencyCode
  )
}

private func conversionText(for properties: ProjectPamphletMainCellProperties) -> String {
  let pledgedCurrencyCountry = projectCountry(forCurrency: properties.currency) ?? properties.country

  let goalCurrencyCountry = projectCountry(forCurrency: properties.currency) ??
    pledgedCurrencyCountry

  return Strings.discovery_baseball_card_stats_convert_from_pledged_of_goal(
    pledged: Format.currency(
      properties.pledged,
      country: pledgedCurrencyCountry,
      omitCurrencyCode: properties.omitUSCurrencyCode
    ),
    goal: Format.currency(
      properties.goal,
      country: goalCurrencyCountry,
      omitCurrencyCode: properties.omitUSCurrencyCode
    )
  )
}

private func progressColor(forProperties properties: ProjectPamphletMainCellProperties) -> UIColor {
  switch properties.state {
  case .canceled, .failed, .suspended:
    return .ksr_support_400
  default:
    return .ksr_create_700
  }
}
