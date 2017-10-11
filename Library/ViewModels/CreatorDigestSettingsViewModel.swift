import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol CreatorDigestSettingsViewModelInputs {
  func viewDidLoad()
  func dailyDigestTapped(selected: Bool)
  func individualEmailsTapped(selected: Bool)
}

public protocol CreatorDigestSettingsViewModelOutputs {
  var dailyDigestSelected: Signal<Bool, NoError> { get }
  var individualEmailSelected: Signal<Bool, NoError> { get }
}

public protocol CreatorDigestSettingsViewModelType {
  var inputs: CreatorDigestSettingsViewModelInputs { get }
  var outputs: CreatorDigestSettingsViewModelOutputs { get }
}

public final class CreatorDigestSettingsViewModel: CreatorDigestSettingsViewModelType,
CreatorDigestSettingsViewModelInputs, CreatorDigestSettingsViewModelOutputs {
  public var dailyDigestSelected: Signal<Bool, NoError>

  public var individualEmailSelected: Signal<Bool, NoError>


  public init() {
    let initialUser = viewDidLoadProperty.signal
      .flatMap {
        AppEnvironment.current.apiService.fetchUserSelf()
          .wrapInOptional()
          .prefix(value: AppEnvironment.current.currentUser)
          .demoteErrors()
    }
    .skipNil()

    let userAttributeChanged: Signal<(UserAttribute, Bool), NoError> =
      self.dailyDigestTappedProperty.signal.map { (.notification(.creatorDigest), $0) }

  self.dailyDigestSelected = .empty
  self.individualEmailSelected = .empty
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let dailyDigestTappedProperty = MutableProperty(false)
  public func dailyDigestTapped(selected: Bool) {
    self.dailyDigestTappedProperty.value = selected
  }

  fileprivate let individualEmailTappedProperty = MutableProperty(false)
  public func individualEmailsTapped(selected: Bool) {
    self.individualEmailTappedProperty.value = selected
  }

  public var inputs: CreatorDigestSettingsViewModelInputs { return self }
  public var outputs: CreatorDigestSettingsViewModelOutputs { return self }
}

private enum UserAttribute {
  case notification(Notification)

  fileprivate var lens: Lens<User, Bool?> {
    switch self {
    case let .notification(notification):
    switch notification {
    case .creatorDigest:          return User.lens.notifications.creatorDigest
      }
    }
  }
}

private enum Notification {
  case creatorDigest

  fileprivate var trackingString: String {
    switch self {
    case .creatorDigest:  return "Creator digest"
    }
  }
}
