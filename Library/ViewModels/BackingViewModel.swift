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

  /// Emits the backer's pledge amount and date.
  var backerPledgeAmountAndDate: Signal<String, NoError> { get }

  /// Emits the backer's pledge status.
  var backerPledgeStatus: Signal<String, NoError> { get }

  /// Emits the backer reward amount to display.
  var backerRewardAmount: Signal<String, NoError> { get }

  /// Emits the backer reward description to display.
  var backerRewardDescription: Signal<String, NoError> { get }

  /// Emits the backer reward title to display.
  var backerRewardTitle: Signal<String, NoError> { get }

  /// Emits a bool whether to hide the reward title if it's empty.
  var backerRewardTitleIsHidden: Signal<Bool, NoError> { get }

  /// Emits the backer sequence to be displayed.
  var backerSequence: Signal<String, NoError> { get }

  /// Emits the backer's shipping amount.
  var backerShippingAmount: Signal<String, NoError> { get }

  /// Emits the estimated delivery date.
  var estimatedDeliveryDateLabelText: Signal<String, NoError> { get }

  /// Emits a boolean that determines if estimated deliver should be hidden.
  var estimatedDeliveryStackViewHidden: Signal<Bool, NoError> { get }

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

  /// Emits the axis of the stackview.
  var rootStackViewAxis: Signal<UILayoutConstraintAxis, NoError> { get }

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

    self.backerPledgeStatus = Signal.merge(
      emptyStringOnLoad,
      projectAndBackingAndBackerIsCurrentUser.map { project, backing, _ in
        statusString(for: backing.status, project: project)
      }
    )

    self.statusDescription = Signal.merge(
      emptyStringOnLoad,
      projectAndBackingAndBackerIsCurrentUser
      .map { project, backing, backerIsCurrentUser in
        let isCreator = !backerIsCurrentUser && project.creator != AppEnvironment.current.currentUser
        return description(for: backing.status, project: project, isCreator: isCreator)
      }
    )

    self.backerPledgeAmountAndDate = Signal.merge(
      emptyStringOnLoad,
      projectAndBackingAndBackerIsCurrentUser.map { project, backing, _ in
        let basicPledge = backing.amount - (backing.shippingAmount ?? 0)
        return Strings.backer_modal_pledge_amount_on_pledge_date(
          pledge_amount: Format.currency(basicPledge, country: project.country),
          pledge_date: Format.date(secondsInUTC: backing.pledgedAt, dateStyle: .long, timeStyle: .none)
        )
      }
    )

    self.totalPledgeAmount = Signal.merge(
      emptyStringOnLoad,
      projectAndBackingAndBackerIsCurrentUser.map { project, backing, _ in
        Format.currency(backing.amount, country: project.country)
      }
    )

    self.backerRewardAmount = Signal.merge(
      emptyStringOnLoad,
      projectAndBackingAndBackerIsCurrentUser
        .map { project, backing, _ in
        Format.currency(backing.reward?.minimum ?? 0, country: project.country)
      }
    )

    self.backerRewardDescription = Signal.merge(
      emptyStringOnLoad,
      reward.map { $0.description }
    )

    self.backerRewardTitle = Signal.merge(
      emptyStringOnLoad,
      reward.map { $0.title ?? "" }
    )

    self.backerRewardTitleIsHidden = self.backerRewardTitle.map { $0.isEmpty }

    self.backerShippingAmount = Signal.merge(
      emptyStringOnLoad,
      projectAndBackingAndBackerIsCurrentUser
        .map { project, backing, _ in
          Format.currency(backing.shippingAmount ?? 0, country: project.country)
      }
    )

    self.shippingStackViewIsHidden = backing.map { $0.shippingAmount == .some(0) }

    self.estimatedDeliveryDateLabelText = Signal.merge(
      emptyStringOnLoad,
      reward.map {
        $0.estimatedDeliveryOn.map {
          Format.date(secondsInUTC: $0, dateFormat: "MMMM yyyy", timeZone: UTCTimeZone)
        }
      }.skipNil()
    )

    self.estimatedDeliveryStackViewHidden = reward
      .map { $0.estimatedDeliveryOn == nil }

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
          ? localizedString(key: "todo", defaultValue: "Contact backer")
          : localizedString(key: "todo", defaultValue: "Contact creator")
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
  public let backerPledgeAmountAndDate: Signal<String, NoError>
  public let backerPledgeStatus: Signal<String, NoError>
  public let backerRewardAmount: Signal<String, NoError>
  public let backerRewardDescription: Signal<String, NoError>
  public let backerRewardTitle: Signal<String, NoError>
  public let backerRewardTitleIsHidden: Signal<Bool, NoError>
  public let backerSequence: Signal<String, NoError>
  public let backerShippingAmount: Signal<String, NoError>
  public let estimatedDeliveryDateLabelText: Signal<String, NoError>
  public let estimatedDeliveryStackViewHidden: Signal<Bool, NoError>
  public let goToMessageCreator: Signal<(MessageSubject, Koala.MessageDialogContext), NoError>
  public let goToMessages: Signal<(Project, Backing), NoError>
  public let hideActionsStackView: Signal<Bool, NoError>
  public let loaderIsAnimating: Signal<Bool, NoError>
  public let messageButtonTitleText: Signal<String, NoError>
  public let opacityForContainers: Signal<CGFloat, NoError>
  public let rootStackViewAxis: Signal<UILayoutConstraintAxis, NoError>
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

private func description(for status: Backing.Status, project: Project, isCreator: Bool) -> String {
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
