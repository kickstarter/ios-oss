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

  func rewardReceivedTapped(on: Bool)
}

public protocol BackingViewModelOutputs {
  /// Emits the backer avatar to be displayed.
  var backerAvatarURL: Signal<URL?, NoError> { get }

  /// Emits the backer name to be displayed.
  var backerName: Signal<String, NoError> { get }

  /// Emits the backer sequence to be displayed.
  var backerSequence: Signal<String, NoError> { get }

  /// Emits a MessageSubject and Koala.MessageDialogContext when should go to message creator screen.
  var goToMessageCreator: Signal<(MessageSubject, Koala.MessageDialogContext), NoError> { get }

  /// Emits with the project when should go to messages screen.
  var goToMessages: Signal<(Project, Backing), NoError> { get }

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

  /// Emits the value for reward received.
  var rewardReceivedState: Signal<Bool, NoError> { get }
}

public protocol BackingViewModelType {
  var inputs: BackingViewModelInputs { get }
  var outputs: BackingViewModelOutputs { get }
}

public final class BackingViewModel: BackingViewModelType, BackingViewModelInputs, BackingViewModelOutputs {

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
    let projectAndBacking = Signal.combineLatest(project, backing)

    let receivedEvent = projectAndBacking
      .takePairWhen(self.rewardReceivedTappedProperty.signal)
      .switchMap { project in
        AppEnvironment.current.apiService.backingUpdate(
          forProject: project.0.0, forUser: project.0.1.backer!,
                                                        received: project.1)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    let markedReceived = receivedEvent.values().map { $0 }

    self.rewardReceivedState = Signal.merge(backing, markedReceived)
      .map { $0.backerCompleted ?? false }
      .skipRepeats()

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
      emptyStringOnLoad.map(NSAttributedString.init(string:)),
      projectAndBackingAndBackerIsCurrentUser.map(pledgeTitle(for:backing:backerIsCurrentUser:))
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

    self.statusDescription = Signal.merge(
      emptyStringOnLoad.mapConst(NSAttributedString(string: "")),
      projectAndBackingAndBackerIsCurrentUser
      .map { project, backing, backerIsCurrentUser in
        statusDescString(for: backing, project: project, backerIsCurrentUser: backerIsCurrentUser)
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
          return backing.reward?.title.map { currency + " - " + $0 } ?? currency
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

    self.messageButtonTitleText = projectAndBackerAndBackerIsCurrentUser
      .map { _, _, backerIsCurrentUser in
        backerIsCurrentUser
          ? Strings.Contact_creator()
          : localizedString(key: "Contact_backer", defaultValue: "Contact backer")
      }

    self.opacityForContainers = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(0.0),
      projectAndBackingAndBackerIsCurrentUser.mapConst(1.0)
    )

    self.rootStackViewAxis = projectAndBackingAndBackerIsCurrentUser
      .map { _ in AppEnvironment.current.language == .en ? .horizontal : .vertical }

    project.observeValues { AppEnvironment.current.koala.trackViewedPledge(forProject: $0) }
  }

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

  fileprivate let rewardReceivedTappedProperty = MutableProperty(false)
  public func rewardReceivedTapped(on: Bool) {
    self.rewardReceivedTappedProperty.value = on
  }

  public let backerAvatarURL: Signal<URL?, NoError>
  public let backerName: Signal<String, NoError>
  public let backerSequence: Signal<String, NoError>
  public let goToMessageCreator: Signal<(MessageSubject, Koala.MessageDialogContext), NoError>
  public let goToMessages: Signal<(Project, Backing), NoError>
  public let loaderIsAnimating: Signal<Bool, NoError>
  public let messageButtonTitleText: Signal<String, NoError>
  public let opacityForContainers: Signal<CGFloat, NoError>
  public let pledgeAmount: Signal<String, NoError>
  public let pledgeSectionTitle: Signal<NSAttributedString, NoError>
  public let rewardDescription: Signal<String, NoError>
  public let rewardSectionAndShippingIsHidden: Signal<Bool, NoError>
  public var rewardTitleWithAmount: Signal<String, NoError>
  public var rewardSectionTitle: Signal<NSAttributedString, NoError>
  public let rootStackViewAxis: Signal<UILayoutConstraintAxis, NoError>
  public let shippingAmount: Signal<String, NoError>
  public let statusDescription: Signal<NSAttributedString, NoError>
  public let totalPledgeAmount: Signal<String, NoError>

  public let rewardReceivedState: Signal<Bool, NoError>

  public var inputs: BackingViewModelInputs { return self }
  public var outputs: BackingViewModelOutputs { return self }
}

//private func cached(backing: Backing) -> Backing {
//  if let backingCache = AppEnvironment.current.cache[KSCache.ksr_markedReceived] as? [Int: Bool] {
//    let markedReceived = backingCache[backing.id] ?? backing.completed
//    return backing |> Backing.lens.completed .~ markedReceived
//  } else {
//    return backing
//  }
//}
//
//private func cache(backing: Backing, shouldToggle: Bool) {
//  AppEnvironment.current.cache[KSCache.ksr_markedReceived] =
//    AppEnvironment.current.cache[KSCache.ksr_markedReceived] ?? [Int: Bool]()
//
//  var cache = AppEnvironment.current.cache[KSCache.ksr_markedReceived] as? [Int: Bool]
//  cache?[backing.id] = shouldToggle
//
//  AppEnvironment.current.cache[KSCache.ksr_markedReceived] = cache
//}

private func statusDescString(for backing: Backing, project: Project, backerIsCurrentUser: Bool)
  -> NSAttributedString {

  let string: String
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
      NSForegroundColorAttributeName: UIColor.ksr_green_700
    ])
  } else {
    return NSAttributedString(string: string, attributes: [
      NSFontAttributeName: UIFont.ksr_subhead(size: 13),
      NSForegroundColorAttributeName: UIColor.ksr_text_dark_grey_400
    ])
  }
}

private func pledgeTitle(for project: Project, backing: Backing, backerIsCurrentUser: Bool)
  -> NSAttributedString {

  let date = Format.date(secondsInUTC: backing.pledgedAt, dateStyle: .long, timeStyle: .none)

  let titleString = backerIsCurrentUser
    ? Strings.You_pledged_on_date(pledge_date: date)
    : Strings.Pledged_on_date(pledge_date: date)

  return titleString.simpleHtmlAttributedString(
    base: [
      NSFontAttributeName: UIFont.ksr_subhead(size: 13),
      NSForegroundColorAttributeName: UIColor.ksr_dark_grey_900
    ],
    bold: [
      NSFontAttributeName: UIFont.ksr_headline(size: 15),
      NSForegroundColorAttributeName: UIColor.ksr_dark_grey_900
    ])
    ?? .init()
}

private func rewardTitle(for reward: Reward?, project: Project, backerIsCurrentUser: Bool)
  -> NSAttributedString {

  guard let estimatedDate = reward?.estimatedDeliveryOn else { return .init() }

  let date = Format.date(secondsInUTC: estimatedDate,
                         template: "MMMyyyy",
                         timeZone: UTCTimeZone)

  let titleString = backerIsCurrentUser
    ? Strings.Your_reward_estimated_for_delivery_in_date(delivery_date: date)
    : Strings.Reward_estimated_for_delivery_in_date(delivery_date: date)

  return titleString.simpleHtmlAttributedString(
    base: [
      NSFontAttributeName: UIFont.ksr_subhead(size: 13),
      NSForegroundColorAttributeName: UIColor.ksr_dark_grey_900
    ],
    bold: [
      NSFontAttributeName: UIFont.ksr_headline(size: 15),
      NSForegroundColorAttributeName: UIColor.ksr_dark_grey_900
    ])
    ?? .init()
}
