// swiftlint:disable file_length
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol BackingViewModelInputs {
  /// Configures the view model with a project.
  func configureWith(project: Project, backer: User?)

  /// Call when the "Message creator" button is pressed.
  func messageCreatorTapped()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the "View messages" button is pressed.
  func viewMessagesTapped()
}

public protocol BackingViewModelOutputs {
  /// Emits the backer avatar to be displayed.
  var backerAvatarURL: Signal<URL?, NoError> { get }

  /// Emits the backer name to be displayed.
  var backerName: Signal<String, NoError> { get }

  /// Emits the backer sequence to be displayed.
  var backerSequence: Signal<String, NoError> { get }

  /// Emits with the project when should go to message creator screen.
  var goToMessageCreator: Signal<(MessageSubject, Koala.MessageDialogContext), NoError> { get }

  /// Emits with the project when should go to messages screen.
  var goToMessages: Signal<(Project, Backing), NoError> { get }

  /// Emits a boolean that determines if the actions stackview should be hidden.
  var hideActionsStackView: Signal<Bool, NoError> { get }

  /// Emits a bool to animate the loader.
  var loaderIsAnimating: Signal<Bool, NoError> { get }

  /// Emits an alpha value for the reward and pledge containers to animate in.
  var opacityForContainers: Signal<CGFloat, NoError> { get }

  /// Emits the backer's pledge amount.
  var pledgeAmount: Signal<String, NoError> { get }

  /// Emits a NSAttributedString for the pledge title label.
  var pledgeSectionTitle: Signal<NSAttributedString, NoError> { get }

  /// Emits the backer's pledge status.
  var pledgeStatus: Signal<String, NoError> { get }

  /// Emits the backer reward description to display.
  var rewardDescription: Signal<String, NoError> { get }

  /// Emits a bool whether to hide the reward section if it's No Reward.
  var rewardSectionAndShippingIsHidden: Signal<Bool, NoError> { get }

  /// Emits the backer reward title to display.
  var rewardSectionTitle: Signal<NSAttributedString, NoError> { get }

  /// Emits the backer reward title and amount to display.
  var rewardTitleWithAmount: Signal<String, NoError> { get }

  /// Emits the axis of the stackview.
  var rootStackViewAxis: Signal<UILayoutConstraintAxis, NoError> { get }

  /// Emits the backer's shipping amount.
  var shippingAmount: Signal<String, NoError> { get }

  /// Emits a NSAttributedString for the status description label.
  var statusDescription: Signal<NSAttributedString, NoError> { get }

  /// Emits text for total pledge amount label.
  var totalPledgeAmount: Signal<String, NoError> { get }
}

public protocol BackingViewModelType {
  var inputs: BackingViewModelInputs { get }
  var outputs: BackingViewModelOutputs { get }
}

public final class BackingViewModel: BackingViewModelType, BackingViewModelInputs, BackingViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let projectAndBackerAndBackerIsCurrentUser = Signal.combineLatest(
      self.projectAndBackerProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)
      .map { (project, backer) -> (Project, User, Bool) in
        let currentUser = AppEnvironment.current.currentUser

        guard let backer = backer ?? currentUser else {
          fatalError("Backer was not supplied.")
        }
        return (project, backer, currentUser == backer)
    }

    let projectAndBackingAndBackerIsCurrentUserEvent = projectAndBackerAndBackerIsCurrentUser
      .switchMap { project, backer, backerIsCurrentUser in
        AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: backer)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .retry(upTo: 3)
          .map { (project, $0, backerIsCurrentUser) }
          .materialize()
    }

    let projectAndBackingAndBackerIsCurrentUser = projectAndBackingAndBackerIsCurrentUserEvent.values()

    let project = projectAndBackingAndBackerIsCurrentUser.map(first)
    let backing = projectAndBackingAndBackerIsCurrentUser.map(second)
    let reward = backing.map { $0.reward }.skipNil()
    let basicBacker = projectAndBackerAndBackerIsCurrentUser.map(second)
    let emptyStringOnLoad = self.viewDidLoadProperty.signal.mapConst("")

    self.backerSequence = Signal.merge(
      self.viewDidLoadProperty.signal
        .mapConst(Strings.backer_modal_backer_number(backer_number: Format.wholeNumber(0))),
      backing.map {
        Strings.backer_modal_backer_number(backer_number: Format.wholeNumber($0.sequence))
      }
    )

    self.loaderIsAnimating = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      projectAndBackingAndBackerIsCurrentUserEvent.filter { $0.isTerminating }.mapConst(false)
    )

    self.backerName = basicBacker.map { $0.name }

    self.backerAvatarURL = basicBacker.map { URL(string: $0.avatar.small) }

    self.pledgeSectionTitle = Signal.merge(
      emptyStringOnLoad.map { NSAttributedString(string: $0) },
      projectAndBackingAndBackerIsCurrentUser.map { project, backing, backerIsCurrentUser in
        pledgeTitle(for: backing, project: project, backerIsCurrentUser: backerIsCurrentUser)
      }
    )

    self.pledgeAmount = Signal.merge(
      emptyStringOnLoad,
      projectAndBackingAndBackerIsCurrentUser.map { project, backing, _ in
        let basicPledge = backing.amount - (backing.shippingAmount ?? 0)
        return Format.currency(basicPledge, country: project.country)
      }
    )

    self.shippingAmount = Signal.merge(
      emptyStringOnLoad,
      projectAndBackingAndBackerIsCurrentUser
        .map { project, backing, _ in
          Format.currency(backing.shippingAmount ?? 0, country: project.country)
      }
    )

    self.totalPledgeAmount = Signal.merge(
      emptyStringOnLoad,
      projectAndBackingAndBackerIsCurrentUser.map { project, backing, _ in
        Format.currency(backing.amount, country: project.country)
      }
    )

    self.pledgeStatus = Signal.merge(
      emptyStringOnLoad,
      projectAndBackingAndBackerIsCurrentUser.map { project, backing, _ in
        statusString(for: backing.status, project: project)
      }
    )

    self.statusDescription = Signal.merge(
      emptyStringOnLoad.mapConst(NSAttributedString(string: "")),
      projectAndBackingAndBackerIsCurrentUser
      .map { project, backing, backerIsCurrentUser in
        return statusDescString(for: backing, project: project, backerIsCurrentUser: backerIsCurrentUser)
      }
    )

    self.rewardSectionTitle = Signal.merge(
      emptyStringOnLoad.map { NSAttributedString(string: $0) },
      projectAndBackingAndBackerIsCurrentUser
        .map { project, backing, backerIsCurrentUser in
          rewardTitle(for: backing.reward, project: project, backerIsCurrentUser: backerIsCurrentUser)
      }
    )

    self.rewardTitleWithAmount = Signal.merge(
      emptyStringOnLoad,
      projectAndBackingAndBackerIsCurrentUser
        .map { project, backing, _ in
          let currency = Format.currency(backing.reward?.minimum ?? 0, country: project.country)
          if let rewardTitle = backing.reward?.title {
            return currency + " - " + rewardTitle
          } else {
            return currency
          }
      }
    )

    self.rewardDescription = Signal.merge(
      emptyStringOnLoad,
      reward.map { $0.description }
    )

    self.rewardSectionAndShippingIsHidden = backing.map { $0.reward?.isNoReward == .some(true) }

    self.goToMessages = projectAndBackingAndBackerIsCurrentUser
      .map { project, backing, _ in (project, backing) }
      .takeWhen(self.viewMessagesTappedProperty.signal)

    self.goToMessageCreator = projectAndBackingAndBackerIsCurrentUser
      .takeWhen(self.messageCreatorTappedProperty.signal)
      .map { project, backing, backerIsCurrentUser in
        backerIsCurrentUser
          ? (MessageSubject.project(project), .backerModal)
          : (MessageSubject.backing(backing), .backerModal)
    }

    self.hideActionsStackView = projectAndBackerAndBackerIsCurrentUser
      .map { project, _, backerIsCurrentUser in
        !backerIsCurrentUser && project.creator != AppEnvironment.current.currentUser
    }

    self.opacityForContainers = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(0.0),
      projectAndBackingAndBackerIsCurrentUser.mapConst(1.0)
    )

    self.rootStackViewAxis = projectAndBackingAndBackerIsCurrentUser
      .map { _ in AppEnvironment.current.language == .en ? .horizontal : .vertical }

    project.observeValues { AppEnvironment.current.koala.trackViewedPledge(forProject: $0) }
  }
  // swiftlint:enable function_body_length

  fileprivate let messageCreatorTappedProperty = MutableProperty()
  public func messageCreatorTapped() {
    self.messageCreatorTappedProperty.value = ()
  }

  fileprivate let projectAndBackerProperty = MutableProperty<(Project, User?)?>(nil)
  public func configureWith(project: Project, backer: User?) {
    self.projectAndBackerProperty.value = (project, backer)
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewMessagesTappedProperty = MutableProperty()
  public func viewMessagesTapped() {
    self.viewMessagesTappedProperty.value = ()
  }

  public let backerAvatarURL: Signal<URL?, NoError>
  public let backerName: Signal<String, NoError>
  public let backerSequence: Signal<String, NoError>
  public let goToMessageCreator: Signal<(MessageSubject, Koala.MessageDialogContext), NoError>
  public let goToMessages: Signal<(Project, Backing), NoError>
  public let hideActionsStackView: Signal<Bool, NoError>
  public let loaderIsAnimating: Signal<Bool, NoError>
  public let opacityForContainers: Signal<CGFloat, NoError>
  public let pledgeAmount: Signal<String, NoError>
  public let pledgeSectionTitle: Signal<NSAttributedString, NoError>
  public let pledgeStatus: Signal<String, NoError>
  public let rewardDescription: Signal<String, NoError>
  public let rewardSectionAndShippingIsHidden: Signal<Bool, NoError>
  public var rewardTitleWithAmount: Signal<String, NoError>
  public var rewardSectionTitle: Signal<NSAttributedString, NoError>
  public let rootStackViewAxis: Signal<UILayoutConstraintAxis, NoError>
  public let shippingAmount: Signal<String, NoError>
  public let statusDescription: Signal<NSAttributedString, NoError>
  public let totalPledgeAmount: Signal<String, NoError>

  public var inputs: BackingViewModelInputs { return self }
  public var outputs: BackingViewModelOutputs { return self }
}

private func statusString(for status: Backing.Status, project: Project) -> String {
    switch status {
    case .canceled:
      return Strings.project_view_pledge_status_canceled()
    case .collected:
      return Strings.profile_projects_status_successful()
    case .dropped:
      return Strings.project_view_pledge_status_dropped()
    case .errored:
      return Strings.project_view_pledge_status_errored()
    case .pledged:
      return (project.state == .canceled || project.state == .failed)
        ? Strings.project_view_pledge_status_canceled()
        : Strings.project_view_pledge_status_pledged()
    case .preauth:
      fatalError()
  }
}

private func statusDescString(for backing: Backing, project: Project, backerIsCurrentUser: Bool)
  -> NSAttributedString {

  var string = ""
  switch backing.status {
  case .canceled:
    string = backerIsCurrentUser
      ? Strings.Your_pledge_was_canceled_or_the_creator_canceled()
      : Strings.Either_the_pledge_or_the_project_was_canceled()
  case .collected:
    string = backerIsCurrentUser
      ? Strings.Your_payment_method_was_successfully_charged()
      : Strings.Payment_method_was_successfully_charged()
  case .dropped:
    string = backerIsCurrentUser
      ? Strings.Your_pledge_was_dropped()
      : Strings.Pledge_was_dropped()
  case .errored:
    string = Strings.There_was_a_problem_with_this_payment()
  case .pledged:
    let isCanceledOrFailed = (project.state == .canceled || project.state == .failed)
    string = backerIsCurrentUser
      ? (isCanceledOrFailed
          ? Strings.Your_pledge_was_canceled_or_the_creator_canceled()
          : Strings.Youve_pledged_to_support_this_project()
        )
      : (isCanceledOrFailed
          ? Strings.Either_the_pledge_or_the_project_was_canceled()
          : Strings.Backer_has_pledged_to_this_project()
        )
  case .preauth:
    fatalError()
  }

  if backing.status == .collected {
    return NSAttributedString(string: string, attributes: [
      NSFontAttributeName: UIFont.ksr_headline(size: 13),
      NSForegroundColorAttributeName: UIColor.ksr_text_green_700
    ])
  } else {
    return NSAttributedString(string: string, attributes: [
      NSFontAttributeName: UIFont.ksr_subhead(size: 13),
      NSForegroundColorAttributeName: UIColor.ksr_text_navy_500
    ])
  }
}

private func pledgeTitle(for backing: Backing, project: Project, backerIsCurrentUser: Bool)
  -> NSAttributedString {

  let date = Format.date(secondsInUTC: backing.pledgedAt, dateStyle: .long, timeStyle: .none)

  let titleString = backerIsCurrentUser
    ? Strings.You_pledged_on_date(pledge_date: date)
    : Strings.Pledged_on_date(pledge_date: date)

  return titleString.simpleHtmlAttributedString(
    base: [
      NSFontAttributeName: UIFont.ksr_subhead(size: 13),
      NSForegroundColorAttributeName: UIColor.black
    ],
    bold: [
      NSFontAttributeName: UIFont.ksr_headline(size: 15),
      NSForegroundColorAttributeName: UIColor.black
    ])
    ?? NSAttributedString(string: "")
}

private func rewardTitle(for reward: Reward?, project: Project, backerIsCurrentUser: Bool)
  -> NSAttributedString {

  guard let reward = reward else { return NSAttributedString(string: "") }
  guard let estimatedDate = reward.estimatedDeliveryOn else { return NSAttributedString(string: "") }

  let date = Format.date(secondsInUTC: estimatedDate,
                         dateFormat: "MMM YYYY",
                         timeZone: UTCTimeZone)

  let titleString = backerIsCurrentUser
    ? Strings.Your_reward_estimated_for_delivery_in_date(delivery_date: date)
    : Strings.Reward_estimated_for_delivery_in_date(delivery_date: date)

  return titleString.simpleHtmlAttributedString(
    base: [
      NSFontAttributeName: UIFont.ksr_subhead(size: 13),
      NSForegroundColorAttributeName: UIColor.black
    ],
    bold: [
      NSFontAttributeName: UIFont.ksr_headline(size: 15),
      NSForegroundColorAttributeName: UIColor.black
    ])
    ?? NSAttributedString(string: "")
}
// swiftlint:enable file_length
