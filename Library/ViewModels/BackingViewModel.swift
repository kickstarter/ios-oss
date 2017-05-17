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

  /// Emits the button title for messaging a backer or creator.
  var messageButtonTitleText: Signal<String, NoError> { get }

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
  var rewardSectionIsHidden: Signal<Bool, NoError> { get }

  /// Emits the backer reward title to display.
  var rewardSectionTitle: Signal<NSAttributedString, NoError> { get }

  /// Emits the backer reward title and amount to display.
  var rewardTitleWithAmount: Signal<String, NoError> { get }

  /// Emits the axis of the stackview.
  var rootStackViewAxis: Signal<UILayoutConstraintAxis, NoError> { get }

  /// Emits the backer's shipping amount.
  var shippingAmount: Signal<String, NoError> { get }

  /// Emits a bool whether shipping stack view should be hidden.
  var shippingStackViewIsHidden: Signal<Bool, NoError> { get }

  /// Emits text for status description label.
  var statusDescription: Signal<String, NoError> { get }

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
          "+ " + Format.currency(backing.shippingAmount ?? 0, country: project.country)
      }
    )

    self.shippingStackViewIsHidden = backing.map { $0.shippingAmount == .some(0) }

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
      emptyStringOnLoad,
      projectAndBackingAndBackerIsCurrentUser
      .map { project, backing, backerIsCurrentUser in
        return description(for: backing.status, project: project, backerIsCurrentUser: backerIsCurrentUser)
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

    self.rewardSectionIsHidden = backing.map { $0.reward?.title == nil }

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

    self.messageButtonTitleText = projectAndBackerAndBackerIsCurrentUser
      .map { project, _, _ in
        project.creator == AppEnvironment.current.currentUser
          // todo: is this something we are doing or just hiding the button?
          ? localizedString(key: "todo", defaultValue: "Contact backer")
          : Strings.Contact_creator()
    }

    self.hideActionsStackView = projectAndBackerAndBackerIsCurrentUser
      .map { project, _, backerIsCurrentUser in
        userIsCreator(for: project, backerIsCurrentUser: backerIsCurrentUser)
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
  public let messageButtonTitleText: Signal<String, NoError>
  public let opacityForContainers: Signal<CGFloat, NoError>
  public let pledgeAmount: Signal<String, NoError>
  public let pledgeSectionTitle: Signal<NSAttributedString, NoError>
  public let pledgeStatus: Signal<String, NoError>
  public let rewardDescription: Signal<String, NoError>
  public let rewardSectionIsHidden: Signal<Bool, NoError>
  public var rewardTitleWithAmount: Signal<String, NoError>
  public var rewardSectionTitle: Signal<NSAttributedString, NoError>
  public let rootStackViewAxis: Signal<UILayoutConstraintAxis, NoError>
  public let shippingAmount: Signal<String, NoError>
  public let shippingStackViewIsHidden: Signal<Bool, NoError>
  public let statusDescription: Signal<String, NoError>
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

private func description(for status: Backing.Status, project: Project, backerIsCurrentUser: Bool) -> String {
  let isCreator = userIsCreator(for: project, backerIsCurrentUser: backerIsCurrentUser)

  switch status {
  case .canceled:
    return isCreator
      ? Strings.Either_the_pledge_or_the_project_was_canceled()
      : Strings.Your_pledge_was_canceled_or_the_creator_canceled()
  case .collected:
    return isCreator
      ? Strings.Payment_method_was_successfully_charged()
      : Strings.Your_payment_method_was_successfully_charged()
  case .dropped:
    return isCreator
      ? Strings.Pledge_was_dropped()
      : Strings.Your_pledge_was_dropped()
  case .errored:
    return localizedString(key: "todo", defaultValue: "There was a problem with this payment.")
  case .pledged:
    let isCanceledOrFailed = (project.state == .canceled || project.state == .failed)
    return isCreator
      ? (isCanceledOrFailed
          ? Strings.Either_the_pledge_or_the_project_was_canceled()
          : Strings.Backer_has_pledged_to_this_project()
        )
      : (isCanceledOrFailed
          ? Strings.Your_pledge_was_canceled_or_the_creator_canceled()
          : Strings.Youve_pledged_to_support_this_project()
        )
  case .preauth:
    fatalError()
  }
}

private func pledgeTitle(for backing: Backing, project: Project, backerIsCurrentUser: Bool)
  -> NSAttributedString {

  let date = Format.date(secondsInUTC: backing.pledgedAt, dateStyle: .long, timeStyle: .none)
  let isCreator = userIsCreator(for: project, backerIsCurrentUser: backerIsCurrentUser)

  let titleString = isCreator
    ? localizedString(key: "Pledged_on_date",
                      defaultValue: "<b>Pledged</b> on %{pledge_date}",
                      substitutions: ["pledge_date": date])
    : localizedString(key: "You_pledged_on_date",
                      defaultValue: "<b>You pledged</b> on %{pledge_date}",
                      substitutions: ["pledge_date": date])

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

  let isCreator = userIsCreator(for: project, backerIsCurrentUser: backerIsCurrentUser)
  let date = Format.date(secondsInUTC: estimatedDate,
                         dateStyle: .short,
                         timeStyle: .none,
                         timeZone: UTCTimeZone)

  let titleString = isCreator
    ? localizedString(key: "Reward_estimated_for_delivery_on_date",
                      defaultValue: "<b>Reward</b> estimated for delivery on %{delivery_date}",
                      substitutions: ["delivery_date": date])
    : localizedString(key: "Your_reward_estimated_for_delivery_on_date",
                      defaultValue: "<b>Your reward</b> estimated for delivery on %{delivery_date}",
                      substitutions: ["delivery_date": date])

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

private func userIsCreator(for project: Project, backerIsCurrentUser: Bool) -> Bool {
  return !backerIsCurrentUser && project.creator != AppEnvironment.current.currentUser
}
// swiftlint:enable file_length
