import Foundation
import KsApi
import ReactiveSwift

public protocol RewardsUseCaseOutputs {
  var goToLoginWithIntent: Signal<LoginIntent, Never> { get }
  var goToRewards: Signal<Void, Never> { get }
}

public protocol RewardsUseCaseType {
  var outputs: RewardsUseCaseOutputs { get }
}

public final class RewardsUseCase: RewardsUseCaseType, RewardsUseCaseOutputs {
  public init(
    secretRewardToken: Signal<String?, Never>,
    userSessionStarted: Signal<Void, Never>,
    goToRewardsTapped: Signal<Void, Never>
  ) {
    // `goToRewardsTapped` emits when the "View rewards", "View your rewards"
    // or "Back this project" button is tapped.
    let initialIsLoggedIn = goToRewardsTapped
      .compactMap {
        AppEnvironment.current.currentUser != nil
      }

    let isLoggedIn = Signal.merge(
      initialIsLoggedIn,
      userSessionStarted.mapConst(true)
    )

    let isSecretReward = secretRewardToken
      .map { secretRewardToken -> Bool in
        guard let secretRewardToken = secretRewardToken else {
          return false
        }

        return !secretRewardToken.isEmpty
      }

    // Determines if login is required.
    // This is necessary when a secret reward token is present,
    // since calling `addUserToSecretRewardGroup` requires the user to be logged in.
    let requiresLoginForSecretRewards = isSecretReward
      .combineLatest(with: isLoggedIn)
      .compactMap { isSecretReward, isLoggedIn -> Bool in
        guard featureSecretRewardEnabled() else { return false }

        return isSecretReward && !isLoggedIn
      }

    self.goToRewards = requiresLoginForSecretRewards
      .takeWhen(goToRewardsTapped)
      .filter { $0 == false }
      .ignoreValues()

    // This signal emits to prompt login when accessing a secret reward token
    // while the user is currently logged out.
    self.goToLoginWithIntent = requiresLoginForSecretRewards
      .takeWhen(goToRewardsTapped)
      .filter { $0 == true }
      .map { _ -> LoginIntent in
        LoginIntent.backProject
      }
  }

  // MARK: Properties

  public var goToLoginWithIntent: ReactiveSwift.Signal<LoginIntent, Never>
  public var goToRewards: Signal<Void, Never>

  // MARK: Type

  public var outputs: any RewardsUseCaseOutputs { return self }
}
