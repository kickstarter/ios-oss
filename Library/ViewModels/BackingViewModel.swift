import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol BackingViewModelInputs {
  /// Configures the view model with a project
  func configureWith(project project: Project, backer: User?)

  /// Call when the "Message creator" button is pressed.
  func messageCreatorTapped()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the "View messages" button is pressed.
  func viewMessagesTapped()
}

public protocol BackingViewModelOutputs {
  /// Emits the backer avatar to be displayed
  var backerAvatarURL: Signal<NSURL?, NoError> { get }

  /// Emits the backer name to be displayed
  var backerName: Signal<String, NoError> { get }

  /// Emits the backer's pledge amount and date of pledge
  var backerPledgeAmountAndDate: Signal<String, NoError> { get }

  /// Emits the backer's pledge status
  var backerPledgeStatus: Signal<String, NoError> { get }

  /// Emits the backer reward description to display
  var backerRewardDescription: Signal<String, NoError> { get }

  /// Emits the backer sequence to be displayed
  var backerSequence: Signal<String, NoError> { get }

  /// Emits the backer's shipping costs
  var backerShippingCost: Signal<String, NoError> { get }

  /// Emits the backer's description of shipping
  var backerShippingDescription: Signal<String, NoError> { get }

  /// Emits with the project when should go to messages screen.
  var goToMessages: Signal<(Project, Backing), NoError> { get }
}

public protocol BackingViewModelType {
  var inputs: BackingViewModelInputs { get }
  var outputs: BackingViewModelOutputs { get }
}

public final class BackingViewModel: BackingViewModelType, BackingViewModelInputs, BackingViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let projectAndBacker = combineLatest(
      self.projectAndBackerProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)
      .map { (project, backer) -> (Project, User) in
        guard let backer = backer ?? AppEnvironment.current.currentUser else {
          fatalError("Backer was not supplied.")
        }
        return (project, backer)
    }

    let projectAndBacking = projectAndBacker
      .switchMap { project, backer in
        AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: backer)
          .demoteErrors()
          .map { (project, $0) }
    }

    let project = projectAndBacking.map(first)
    let backing = projectAndBacking.map(second)
    let reward = backing.map { $0.reward }.ignoreNil()

    self.backerSequence = backing
      .map { Strings.backer_modal_backer_number(backer_number: Format.wholeNumber($0.sequence)) }

    let backer = projectAndBacker.map(second)

    self.backerName = backer.map { $0.name }
    self.backerAvatarURL = backer.map { NSURL(string: $0.avatar.small) }

    self.backerPledgeStatus = projectAndBacking
      .map { Strings.backer_modal_status_backing_status( backing_status: statusString($1.status)) }

    self.backerPledgeAmountAndDate = projectAndBacking
      .map { project, backing in
        Strings.backer_modal_pledge_amount_on_pledge_date(
          pledge_amount: Format.currency(backing.amount, country: project.country),
          pledge_date: Format.date(
            secondsInUTC: backing.pledgedAt,
            dateStyle: .LongStyle,
            timeStyle: .NoStyle
          )
        )
    }

    self.backerRewardDescription = combineLatest(project, reward)
      .map { project, reward in
        Strings.backer_modal_reward_amount_reward_description(
          reward_amount: Format.currency(reward.minimum, country: project.country),
          reward_description: reward.description
        )
    }

    self.backerShippingDescription = reward.map { $0.shipping.summary }.ignoreNil()

    self.backerShippingCost = projectAndBacking
      .map { project, backing in Format.currency(backing.shippingAmount ?? 0, country: project.country) }

    self.goToMessages = projectAndBacking.takeWhen(self.viewMessagesTappedProperty.signal)

    project
      .takeWhen(self.viewDidLoadProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackViewedPledge(forProject: $0) }
  }
  // swiftlint:enable function_body_length

  private let messageCreatorTappedProperty = MutableProperty()
  public func messageCreatorTapped() {
    self.messageCreatorTappedProperty.value = ()
  }

  private let projectAndBackerProperty = MutableProperty<(Project, User?)?>(nil)
  public func configureWith(project project: Project, backer: User?) {
    self.projectAndBackerProperty.value = (project, backer)
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewMessagesTappedProperty = MutableProperty()
  public func viewMessagesTapped() {
    self.viewMessagesTappedProperty.value = ()
  }

  public let backerAvatarURL: Signal<NSURL?, NoError>
  public let backerName: Signal<String, NoError>
  public let backerPledgeAmountAndDate: Signal<String, NoError>
  public let backerPledgeStatus: Signal<String, NoError>
  public let backerRewardDescription: Signal<String, NoError>
  public let backerSequence: Signal<String, NoError>
  public let backerShippingDescription: Signal<String, NoError>
  public let backerShippingCost: Signal<String, NoError>
  public let goToMessages: Signal<(Project, Backing), NoError>


  public var inputs: BackingViewModelInputs { return self }
  public var outputs: BackingViewModelOutputs { return self }
}

private func statusString(forStatus: Backing.Status) -> String {
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
