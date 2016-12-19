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
  var backerAvatarURL: Signal<NSURL?, NoError> { get }

  /// Emits the backer name to be displayed.
  var backerName: Signal<String, NoError> { get }

  /// Emits the accessibility label for the backer name.
  var backerNameAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the backer's pledge amount and date.
  var backerPledgeAmountAndDate: Signal<String, NoError> { get }

  /// Emits the accessibility label for backer's pledge amount and date.
  var backerPledgeAmountAndDateAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the backer's pledge status.
  var backerPledgeStatus: Signal<String, NoError> { get }

  /// Emits the accessibility label for backer's pledge status.
  var backerPledgeStatusAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the backer reward description to display.
  var backerRewardDescription: Signal<String, NoError> { get }

  /// Emits the accessibility label for backer reward description.
  var backerRewardDescriptionAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the backer sequence to be displayed.
  var backerSequence: Signal<String, NoError> { get }

  /// Emits the accessibility label for backer sequence.
  var backerSequenceAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the backer's shipping amount.
  var backerShippingAmount: Signal<String, NoError> { get }

  /// Emits the accessibility label for backer's shipping amount.
  var backerShippingAmountAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the backer's description of shipping.
  var backerShippingDescription: Signal<String, NoError> { get }

  /// Emits the accessibility label for backer's description of shipping.
  var backerShippingDescriptionAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits with the project when should go to message creator screen.
  var goToMessageCreator: Signal<(MessageSubject, Koala.MessageDialogContext), NoError> { get }

  /// Emits with the project when should go to messages screen.
  var goToMessages: Signal<(Project, Backing), NoError> { get }

  /// Emits a boolean that determines if the actions stackview should be hidden.
  var hideActionsStackView: Signal<Bool, NoError> { get }

  /// Emits the button title for messaging a backer or creator.
  var messageButtonTitleText: Signal<String, NoError> { get }

  /// Emits the axis of the stackview.
  var rootStackViewAxis: Signal<UILayoutConstraintAxis, NoError> { get }
}

public protocol BackingViewModelType {
  var inputs: BackingViewModelInputs { get }
  var outputs: BackingViewModelOutputs { get }
}

public final class BackingViewModel: BackingViewModelType, BackingViewModelInputs, BackingViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let projectAndBackerAndBackerIsCurrentUser = combineLatest(
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

    let projectAndBackingAndBackerIsCurrentUser = projectAndBackerAndBackerIsCurrentUser
      .switchMap { project, backer, backerIsCurrentUser in
        AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: backer)
          .demoteErrors()
          .map { (project, $0, backerIsCurrentUser) }
    }

    let project = projectAndBackingAndBackerIsCurrentUser.map(first)
    let backing = projectAndBackingAndBackerIsCurrentUser.map(second)
    let reward = backing.map { $0.reward }.skipNil()

    self.backerSequence = backing
      .map { Strings.backer_modal_backer_number(backer_number: Format.wholeNumber($0.sequence)) }
    self.backerSequenceAccessibilityLabel = self.backerSequence

    let backer = projectAndBackerAndBackerIsCurrentUser.map(second)

    self.backerName = backer.map { $0.name }
    self.backerNameAccessibilityLabel = self.backerName

    self.backerAvatarURL = backer.map { NSURL(string: $0.avatar.small) }

    self.backerPledgeStatus = backing
      .map { Strings.backer_modal_status_backing_status( backing_status: statusString($0.status)) }

    self.backerPledgeStatusAccessibilityLabel = self.backerPledgeStatus

    self.backerPledgeAmountAndDate = projectAndBackingAndBackerIsCurrentUser
      .map { project, backing, _ in
        Strings.backer_modal_pledge_amount_on_pledge_date(
          pledge_amount: Format.currency(backing.amount, country: project.country),
          pledge_date: Format.date(
            secondsInUTC: backing.pledgedAt,
            dateStyle: .LongStyle,
            timeStyle: .NoStyle
          )
        )
    }
    self.backerPledgeAmountAndDateAccessibilityLabel = self.backerPledgeAmountAndDate.map { "Pledged " + $0 }

    self.backerRewardDescription = combineLatest(project, reward)
      .map { project, reward in
        Strings.backer_modal_reward_amount_reward_description(
          reward_amount: Format.currency(reward.minimum, country: project.country),
          reward_description: reward.description
        )
    }
    self.backerRewardDescriptionAccessibilityLabel = self.backerRewardDescription

    self.backerShippingDescription = reward.map { $0.shipping.summary }.skipNil()
    self.backerShippingDescriptionAccessibilityLabel = self.backerShippingDescription

    self.backerShippingAmount = projectAndBackingAndBackerIsCurrentUser
      .map { project, backing, _ in Format.currency(backing.shippingAmount ?? 0, country: project.country) }
    self.backerShippingAmountAccessibilityLabel = self.backerShippingAmount

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
      .map { project, _, backerIsCurrentUser in
        project.creator == AppEnvironment.current.currentUser
          ? Strings.Message_backer()
          : Strings.Message_creator()
    }

    self.hideActionsStackView = projectAndBackerAndBackerIsCurrentUser
      .map { project, _, backerIsCurrentUser in
        !backerIsCurrentUser && project.creator != AppEnvironment.current.currentUser
    }

    self.rootStackViewAxis = projectAndBackingAndBackerIsCurrentUser
      .map { _ in AppEnvironment.current.language == .en ? .Horizontal : .Vertical }

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

  public let backerAvatarURL: Signal<NSURL?, NoError>
  public let backerName: Signal<String, NoError>
  public let backerNameAccessibilityLabel: Signal<String, NoError>
  public let backerPledgeAmountAndDate: Signal<String, NoError>
  public let backerPledgeAmountAndDateAccessibilityLabel: Signal<String, NoError>
  public let backerPledgeStatus: Signal<String, NoError>
  public let backerPledgeStatusAccessibilityLabel: Signal<String, NoError>
  public let backerRewardDescription: Signal<String, NoError>
  public let backerRewardDescriptionAccessibilityLabel: Signal<String, NoError>
  public let backerSequence: Signal<String, NoError>
  public let backerSequenceAccessibilityLabel: Signal<String, NoError>
  public let backerShippingAmount: Signal<String, NoError>
  public let backerShippingAmountAccessibilityLabel: Signal<String, NoError>
  public let backerShippingDescription: Signal<String, NoError>
  public let backerShippingDescriptionAccessibilityLabel: Signal<String, NoError>
  public let goToMessageCreator: Signal<(MessageSubject, Koala.MessageDialogContext), NoError>
  public let goToMessages: Signal<(Project, Backing), NoError>
  public let hideActionsStackView: Signal<Bool, NoError>
  public let messageButtonTitleText: Signal<String, NoError>
  public let rootStackViewAxis: Signal<UILayoutConstraintAxis, NoError>

  public var inputs: BackingViewModelInputs { return self }
  public var outputs: BackingViewModelOutputs { return self }
}

private func statusString(_ forStatus: Backing.Status) -> String {
    switch forStatus {
    case .canceled:
      return Strings.project_view_pledge_status_canceled()
    case .collected:
      return Strings.project_view_pledge_status_collected()
    case .dropped:
      return Strings.project_view_pledge_status_dropped()
    case .errored:
      return Strings.project_view_pledge_status_errored()
    case .pledged:
      return Strings.project_view_pledge_status_pledged()
    case .preauth:
      fatalError()
  }
}
